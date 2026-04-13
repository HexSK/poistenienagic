const THEME_KEY = 'poistenieNagic:theme';

export function getTheme() {
  const stored = localStorage.getItem(THEME_KEY);
  if (stored === 'light' || stored === 'dark') return stored;
  const prefersDark = window.matchMedia?.('(prefers-color-scheme: dark)')?.matches;
  return prefersDark ? 'dark' : 'light';
}

export function applyTheme(theme) {
  const safeTheme = theme === 'light' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-bs-theme', safeTheme);
  return safeTheme;
}

export function setTheme(theme) {
  const applied = applyTheme(theme);
  localStorage.setItem(THEME_KEY, applied);
  return applied;
}

export function initTheme() {
  return applyTheme(getTheme());
}

export function toggleTheme() {
  const next = getTheme() === 'dark' ? 'light' : 'dark';
  return setTheme(next);
}

