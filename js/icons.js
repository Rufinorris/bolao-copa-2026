// =============================================
// ICONS — ícones SVG de traço (line icons), coesos e nítidos em qualquer device.
// Substituem os emojis "utilitários" (navegação/ações) que destoavam do visual.
// Os emojis expressivos/temáticos (⚽ 🥇 🔥 🎯 🔴) continuam no conteúdo.
// Uso: icon('trophy')  ou  icon('settings', 18)
//      Herdam a cor via currentColor — basta definir color no elemento pai.
// =============================================

const ICON_PATHS = {
  back:     '<polyline points="15 18 9 12 15 6"/>',
  target:   '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.5"/>',
  trophy:   '<path d="M8 21h8"/><path d="M12 17v4"/><path d="M7 4h10v5a5 5 0 0 1-10 0V4z"/><path d="M17 5h2a2 2 0 0 1 0 4h-2"/><path d="M7 5H5a2 2 0 0 0 0 4h2"/>',
  bracket:  '<path d="M5 5v4a2 2 0 0 0 2 2h4"/><path d="M5 19v-4a2 2 0 0 1 2-2h4"/><line x1="11" y1="12" x2="15" y2="12"/><rect x="15" y="9.5" width="5" height="5" rx="1"/>',
  rules:    '<path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><polyline points="14 3 14 8 19 8"/><line x1="8" y1="12.5" x2="15" y2="12.5"/><line x1="8" y1="16" x2="13" y2="16"/>',
  share:    '<circle cx="18" cy="5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="19" r="2.5"/><line x1="8.2" y1="10.8" x2="15.8" y2="6.4"/><line x1="8.2" y1="13.2" x2="15.8" y2="17.6"/>',
  chart:    '<line x1="6" y1="20" x2="6" y2="13"/><line x1="12" y1="20" x2="12" y2="5"/><line x1="18" y1="20" x2="18" y2="9"/>',
  settings: '<line x1="4" y1="7" x2="20" y2="7"/><circle cx="15" cy="7" r="2.5"/><line x1="4" y1="17" x2="20" y2="17"/><circle cx="9" cy="17" r="2.5"/>',
  refresh:  '<polyline points="21 4 21 10 15 10"/><path d="M21 10a9 9 0 1 0-2.6 6.4"/>',
  camera:   '<path d="M5 8h3l1.5-2h5L16 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><circle cx="12" cy="13" r="3.2"/>',
};

function icon(name, size) {
  const s = size || 20;
  const p = ICON_PATHS[name] || '';
  return `<svg class="icon" viewBox="0 0 24 24" width="${s}" height="${s}" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${p}</svg>`;
}
