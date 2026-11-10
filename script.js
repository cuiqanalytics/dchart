(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // theme toggle and saved choice live in brand/brand.js

  document.querySelectorAll('[data-tabs]').forEach((box) => {
    const tabs = [...box.querySelectorAll('[role="tab"]')];
    const select = (tab) => {
      tabs.forEach((t) => {
        const on = t === tab;
        t.setAttribute('aria-selected', on);
        t.tabIndex = on ? 0 : -1;
        document.getElementById(t.getAttribute('aria-controls')).hidden = !on;
      });
    };
    box.selectTab = select;
    tabs.forEach((t, i) => {
      t.addEventListener('click', () => { box.dataset.touched = '1'; select(t); });
      t.addEventListener('keydown', (e) => {
        if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
        const next = tabs[(i + (e.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length];
        box.dataset.touched = '1'; select(next); next.focus();
      });
    });
    // install box: show the Windows command to Windows visitors (tabs: macOS & Linux, Windows)
    if (box.matches('.install') && /Win/.test(navigator.userAgentData?.platform || navigator.platform || '')) select(tabs[1]);
  });

  // Hero: alternate between the first crawl and the cached re-run until the visitor picks one.
  const board = document.querySelector('.runboard[data-tabs], .gallery[data-tabs]');
  if (board && !reduceMotion) {
    const tabs = [...board.querySelectorAll('[role="tab"]')];
    let i = 0;
    setInterval(() => {
      if (board.dataset.touched || document.hidden) return;
      i = (i + 1) % tabs.length;
      board.selectTab(tabs[i]);
    }, 5000);
  }

  document.querySelectorAll('.copy').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try { await navigator.clipboard.writeText(btn.dataset.copy); } catch {
        const ta = Object.assign(document.createElement('textarea'), { value: btn.dataset.copy });
        document.body.append(ta); ta.select(); document.execCommand('copy'); ta.remove();
      }
      btn.textContent = 'Copied'; btn.classList.add('done');
      setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('done'); }, 1600);
    });
  });
})();
