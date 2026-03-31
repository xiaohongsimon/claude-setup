/* ============================================
   Shared Navigation — Scroll-snap + Keyboard
   ============================================ */

(function () {
  'use strict';

  const slides = document.querySelectorAll('.slide');
  const total = slides.length;
  let current = 0;

  // --- Progress bar ---
  const bar = document.createElement('div');
  bar.id = 'progress-bar';
  document.body.prepend(bar);

  // --- Slide counter ---
  const counter = document.createElement('div');
  counter.id = 'slide-counter';
  document.body.appendChild(counter);

  function updateUI() {
    const pct = total > 1 ? ((current + 1) / total) * 100 : 100;
    bar.style.width = pct + '%';
    counter.textContent = (current + 1) + ' / ' + total;
  }

  // --- IntersectionObserver ---
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const idx = Array.from(slides).indexOf(entry.target);
          if (idx !== -1) {
            current = idx;
            updateUI();
          }
        }
      });
    },
    { threshold: 0.5 }
  );

  slides.forEach((s) => observer.observe(s));

  // --- Keyboard navigation ---
  document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowDown' || e.key === 'ArrowRight' || e.key === ' ') {
      e.preventDefault();
      if (current < total - 1) {
        current++;
        slides[current].scrollIntoView({ behavior: 'smooth' });
      }
    } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
      e.preventDefault();
      if (current > 0) {
        current--;
        slides[current].scrollIntoView({ behavior: 'smooth' });
      }
    } else if (e.key === 'Home') {
      e.preventDefault();
      current = 0;
      slides[0].scrollIntoView({ behavior: 'smooth' });
    } else if (e.key === 'End') {
      e.preventDefault();
      current = total - 1;
      slides[current].scrollIntoView({ behavior: 'smooth' });
    }
  });

  // --- Animate bars on intersection ---
  const barFills = document.querySelectorAll('.bar-fill');
  const barObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.style.width = entry.target.dataset.width;
        }
      });
    },
    { threshold: 0.3 }
  );
  barFills.forEach((b) => {
    b.dataset.width = b.style.width;
    b.style.width = '0%';
    barObserver.observe(b);
  });

  // --- Init ---
  updateUI();
})();
