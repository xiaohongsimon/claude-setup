#!/bin/bash
# Claude Code Hook → 钉钉单聊推送（企业内部机器人 oToMessages API）
# 从 transcript 提取上下文，推送富信息通知

# 加载密钥
ENV_FILE="$HOME/.dynasty.env"
if [ ! -f "$ENV_FILE" ]; then
  exit 0
fi
set -a
source "$ENV_FILE"
set +a
[ -z "$DINGTALK_APP_KEY" ] || [ -z "$DINGTALK_APP_SECRET" ] || [ -z "$DINGTALK_STAFF_ID" ] && exit 0
: "${DINGTALK_ROBOT_CODE:=$DINGTALK_APP_KEY}"

# 免打扰：23:30 ~ 07:30
HOUR=$(date +%H)
MIN=$(date +%M)
T=$((HOUR * 60 + MIN))
if [ $T -ge 1410 ] || [ $T -lt 450 ]; then
  exit 0
fi

# 从 stdin 读取 hook JSON，存到临时文件（因为后面 python heredoc 会占用 stdin）
INPUT=$(cat)
INPUT_FILE=$(mktemp)
echo "$INPUT" > "$INPUT_FILE"
trap "rm -f $INPUT_FILE" EXIT

# 解析事件 + 从 transcript 提取上下文
NOTIFY_TEXT=$(python3 - "$INPUT_FILE" << 'PYEOF'
import sys, json, os

def extract_context(transcript_path, max_lines=50):
    """从 transcript 尾部提取最近的用户指令和 assistant 最后输出"""
    try:
        with open(transcript_path, 'r') as f:
            lines = f.readlines()
    except:
        return "", "", []

    last_user_text = ""
    last_assistant_text = ""
    last_tool_calls = []

    for raw in reversed(lines[-max_lines:]):
        try:
            entry = json.loads(raw.strip())
        except:
            continue
        msg = entry.get('message', {})
        role = msg.get('role', '')
        content = msg.get('content', '')

        if role == 'user' and not last_user_text:
            if isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get('type') == 'text':
                        last_user_text = block['text'][:300]
                        break
            elif isinstance(content, str):
                last_user_text = content[:300]

        if role == 'assistant':
            if isinstance(content, list):
                for block in content:
                    if not isinstance(block, dict):
                        continue
                    btype = block.get('type', '')
                    if btype == 'text' and not last_assistant_text:
                        last_assistant_text = block['text'][:500]
                    elif btype == 'tool_use' and len(last_tool_calls) < 3:
                        name = block.get('name', '')
                        inp = block.get('input', {})
                        if name == 'AskUserQuestion':
                            qs = inp.get('questions', [])
                            if qs:
                                q = qs[0]
                                question = q.get('question', '')
                                opts = q.get('options', [])
                                opt_lines = []
                                for i, o in enumerate(opts, 1):
                                    label = o.get('label', '')
                                    desc = o.get('description', '')
                                    opt_lines.append(f"  {i}. {label}" + (f" — {desc[:60]}" if desc else ""))
                                last_tool_calls.append(f"❓ {question}\n" + '\n'.join(opt_lines))
                        elif name == 'Bash':
                            cmd = inp.get('command', '')[:120]
                            if cmd:
                                last_tool_calls.append(f"⚡ {cmd}")
                        elif name in ('Read', 'Write', 'Edit'):
                            fp = inp.get('file_path', '').split('/')[-1]
                            last_tool_calls.append(f"📄 {name}: {fp}")
                        elif name == 'Agent':
                            desc = inp.get('description', name)
                            last_tool_calls.append(f"🤖 Agent: {desc}")
                        else:
                            last_tool_calls.append(f"🔧 {name}")

        if last_user_text and last_assistant_text:
            break

    return last_user_text, last_assistant_text, last_tool_calls

try:
    input_file = sys.argv[1]
    with open(input_file, 'r') as f:
        d = json.load(f)

    event = d.get('hook_event_name', 'unknown')
    ntype = d.get('notification_type', '')
    project = d.get('cwd', '').split('/')[-1] or 'unknown'
    transcript = d.get('transcript_path', '')

    user_text, assistant_text, tools = extract_context(transcript)

    parts = []

    # 标题行
    if event == 'Notification':
        if ntype == 'permission_prompt':
            parts.append(f"**需要审批** [{project}]")
        elif ntype == 'idle_prompt':
            parts.append(f"**等待输入** [{project}]")
        else:
            parts.append(f"**需要注意** [{project}]")
    elif event == 'Stop':
        parts.append(f"**任务完成** [{project}]")
    else:
        parts.append(f"**{event}** [{project}]")

    # 你的指令
    if user_text:
        parts.append(f"\n---")
        parts.append(f"📝 你: {user_text[:200]}")

    # Claude 最后说了什么（如果有 AskUserQuestion 就跳过文本，避免重复）
    has_question = any('❓' in t for t in tools)
    if assistant_text and not has_question:
        text = assistant_text.strip()
        if len(text) > 250:
            text = text[:250] + "..."
        parts.append(f"\n🤖 Claude: {text}")

    # Claude 正在做什么 / 问什么
    # Stop 事件：只要 Claude 总结，不展示工具噪音
    # Notification 有问题：只展示问题
    # 其他：展示工具调用
    if tools and event != 'Stop':
        questions = [t for t in tools if t.startswith('❓')]
        if questions:
            parts.append(f"\n---")
            for t in questions[:2]:
                parts.append(t[:400])
        else:
            parts.append(f"\n---")
            for t in tools[:3]:
                parts.append(t[:200])

    print('\n'.join(parts))

except Exception as e:
    print(f"通知触发（解析异常: {e}）")
PYEOF
)

# 提取标题（第一行去掉 markdown 星号）
TITLE=$(echo "$NOTIFY_TEXT" | head -1 | sed 's/\*//g')
[ -z "$TITLE" ] && TITLE="Claude Code"

# 获取 access token
TOKEN=$(curl -s -X POST "https://api.dingtalk.com/v1.0/oauth2/accessToken" \
  -H "Content-Type: application/json" \
  -d "{\"appKey\":\"${DINGTALK_APP_KEY}\",\"appSecret\":\"${DINGTALK_APP_SECRET}\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('accessToken',''))" 2>/dev/null)

[ -z "$TOKEN" ] && exit 1

# 发送单聊消息
PAYLOAD=$(python3 -c "
import json, sys, os
title = sys.argv[1]
text = sys.argv[2]
print(json.dumps({
    'robotCode': os.environ['DINGTALK_ROBOT_CODE'],
    'userIds': [os.environ['DINGTALK_STAFF_ID']],
    'msgKey': 'sampleMarkdown',
    'msgParam': json.dumps({'title': title, 'text': text[:2000]})
}))
" "$TITLE" "$NOTIFY_TEXT")

curl -s -X POST "https://api.dingtalk.com/v1.0/robot/oToMessages/batchSend" \
  -H "x-acs-dingtalk-access-token: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" > /dev/null 2>&1
