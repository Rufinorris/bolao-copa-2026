// =============================================
// VERSION-CHECK — auto-atualização quando sai versão nova
// Busca /version.json (sem cache) no load e a cada 60s. Quando o número muda
// (novo deploy), recarrega a página sozinho — assim os amigos não precisam
// limpar cache nem saber que saiu versão nova.
// O carimbo de versão é atualizado a cada deploy pelo scripts/redeploy.ps1.
// =============================================

(function () {
  let versaoApp = null;
  let recarregando = false;

  async function checar() {
    if (recarregando) return;
    try {
      const r = await fetch('/version.json?_=' + Date.now(), { cache: 'no-store' });
      if (!r.ok) return;
      const d = await r.json();
      const v = d && d.v;
      if (!v) return;
      if (versaoApp === null) { versaoApp = v; return; } // primeira leitura: guarda
      if (v !== versaoApp) {
        recarregando = true;
        avisar();
        setTimeout(() => location.reload(), 1200);
      }
    } catch (_) { /* offline ou erro: ignora */ }
  }

  function avisar() {
    const el = document.createElement('div');
    el.textContent = 'Atualizando para a nova versão…';
    el.style.cssText = 'position:fixed;left:50%;bottom:24px;transform:translateX(-50%);z-index:99999;' +
      'background:linear-gradient(135deg,#7c6bff,#5b4de8);color:#fff;padding:11px 20px;border-radius:12px;' +
      "font-family:'Inter',system-ui,sans-serif;font-size:13px;font-weight:700;box-shadow:0 8px 28px rgba(0,0,0,.45)";
    document.body.appendChild(el);
  }

  function iniciar() {
    checar();
    setInterval(checar, 60000);
    // checa também quando a aba volta a ficar visível (volta pro app no celular)
    document.addEventListener('visibilitychange', () => { if (!document.hidden) checar(); });
  }

  if (document.readyState === 'complete') iniciar();
  else window.addEventListener('load', iniciar);
})();
