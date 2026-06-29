// =============================================
// CAMPINHO — Seletor visual de artilheiro
// Copa do Mundo 2026
// Uso: campinhoRender(jogoId, homeNome, awayNome, artilheiroAtual, onSelect)
// =============================================

// Monta a escalação para o campinho:
// GK: só o titular (1), DEF: até 5, MID e FWD: todos (para reservas aparecerem)
function _escalacao(nomeTime) {
  const e = typeof ELENCOS !== 'undefined' ? ELENCOS[nomeTime] : null;
  if (!e) return { GK: [], DEF: [], MID: [], FWD: [] };
  return {
    GK:  (e.GK  || []).slice(0, 1),
    DEF: (e.DEF || []).slice(0, 5),
    MID: e.MID || [],
    FWD: e.FWD || [],
  };
}

// Gera HTML de um círculo de jogador
function _circuloJogador(nome, selected, jogoId, onSelectAttr) {
  const foto = typeof FOTOS !== 'undefined' ? getFoto(nome) : null;
  const initials = nome.split(' ').map(p => p[0]).slice(0, 2).join('').toUpperCase();
  const imgContent = foto
    ? `<img src="${foto}" alt="${nome}" onerror="this.parentNode.innerHTML='<span class=\\'cpn-ini\\'>${initials}</span>'">`
    : `<span class="cpn-ini">${initials}</span>`;

  return `
    <div class="cpn-jogador ${selected ? 'cpn-selecionado' : ''}"
      onclick="${onSelectAttr}(this.dataset.nome)"
      data-nome="${nome}"
      title="${nome}">
      <div class="cpn-foto">${imgContent}</div>
      <div class="cpn-nome">${_nomeExibicao(nome)}</div>
    </div>`;
}

function _nomeExibicao(nome) {
  const partes = nome.split(' ');
  if (partes.length === 1) return nome;

  const first = partes[0];
  const last  = partes[partes.length - 1];

  // "VINI JR.", "NEYMAR JR" — apelido especial, mantém tudo
  if (last === 'JR.' || last === 'JR' || last === 'SR.') return nome;

  // "BRUNO G.", "ALEX B." — última parte é inicial, mantém tudo
  if (/^[A-ZÁÉÍÓÚÃÕ]\.$/.test(last)) return nome;

  // "L. HENRIQUE", "H. ITO", "J ALVAREZ" — primeira parte é inicial, mostra o resto
  if (/^[A-ZÁÉÍÓÚÃÕ]\.?$/.test(first)) return partes.slice(1).join(' ');

  // "BRAUT HAALAND", "ALEX SANDRO" → só o último nome
  return last;
}

// Gera uma fileira de jogadores
function _fileira(jogadores, posLabel, selected, onSelectAttr) {
  if (!jogadores.length) return '';
  return `
    <div class="cpn-fileira">
      <div class="cpn-pos-label">${posLabel}</div>
      <div class="cpn-jogadores-row">
        ${jogadores.map(n => _circuloJogador(n, n === selected, null, onSelectAttr)).join('')}
      </div>
    </div>`;
}

// Função principal: retorna o HTML do campinho
function campinhoHTML(jogoId, homeNome, awayNome, artilheiroAtual) {
  const cbName = `_campinhoSelect_${jogoId.replace(/-/g,'_')}`;
  const escHome = _escalacao(homeNome);
  const escAway = _escalacao(awayNome);

  const posLabels = { GK: 'GOL', DEF: 'DEF', MID: 'MEI', FWD: 'ATA' };
  const ordemAtaque = ['FWD', 'MID', 'DEF', 'GK'];

  const homeHTML = ordemAtaque.map(pos =>
    _fileira(escHome[pos], posLabels[pos], artilheiroAtual, cbName)
  ).join('');

  const awayHTML = [...ordemAtaque].reverse().map(pos =>
    _fileira(escAway[pos], posLabels[pos], artilheiroAtual, cbName)
  ).join('');

  return `
    <div class="campinho" id="cpn-${jogoId}">
      <div class="cpn-team-header cpn-home">
        <span class="cpn-flag">${_getFlagTime(homeNome)}</span>
        <span class="cpn-team-nome">${homeNome}</span>
      </div>
      <div class="cpn-meio-campo cpn-home-campo">
        ${homeHTML}
      </div>
      <div class="cpn-linha-centro"><span>── CENTRO ──</span></div>
      <div class="cpn-meio-campo cpn-away-campo">
        ${awayHTML}
      </div>
      <div class="cpn-team-header cpn-away">
        <span class="cpn-flag">${_getFlagTime(awayNome)}</span>
        <span class="cpn-team-nome">${awayNome}</span>
      </div>
      ${artilheiroAtual ? `
        <div class="cpn-selecionado-bar">
          ⚽ Goleador: <strong>${artilheiroAtual}</strong>
          <button onclick="${cbName}(null)" class="cpn-limpar">✕</button>
        </div>` : ''}
    </div>`;
}

// Registra o callback de seleção no escopo global
function campinhoRender(jogoId, homeNome, awayNome, artilheiroAtual, onSelect) {
  const cbName = `_campinhoSelect_${jogoId.replace(/-/g,'_')}`;

  // Registra função de callback global
  window[cbName] = function(nome) {
    onSelect(nome);
    // Re-renderiza o campinho com o novo selecionado
    const el = document.getElementById(`cpn-${jogoId}`);
    if (el) {
      el.outerHTML = campinhoHTML(jogoId, homeNome, awayNome, nome);
      // Re-registra callback após re-render
      window[cbName] = arguments.callee;
    }
  };

  return campinhoHTML(jogoId, homeNome, awayNome, artilheiroAtual);
}

function _getFlagTime(nome) {
  if (typeof FLAGS_MAP !== 'undefined' && FLAGS_MAP[nome]) return FLAGS_MAP[nome];
  return '🏴';
}

// =============================================
// CSS do campinho — injeta uma vez
// =============================================
(function injectCampinhoCSS() {
  if (document.getElementById('campinho-css')) return;
  const style = document.createElement('style');
  style.id = 'campinho-css';
  style.textContent = `
    .campinho {
      background: linear-gradient(180deg, #1a7a1a 0%, #166b16 48%, #1a7a1a 100%);
      border-radius: 14px;
      overflow: hidden;
      padding: 4px 0;
      border: 2px solid rgba(255,255,255,0.15);
      user-select: none;
    }
    .cpn-team-header {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 14px 4px;
      font-size: 13px;
      font-weight: 700;
      color: rgba(255,255,255,0.9);
    }
    .cpn-flag { font-size: 20px; }
    .cpn-meio-campo { padding: 4px 6px; }
    .cpn-fileira {
      display: flex;
      align-items: center;
      gap: 6px;
      margin: 6px 0;
    }
    .cpn-pos-label {
      font-size: 9px;
      font-weight: 800;
      color: rgba(255,255,255,0.5);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      width: 28px;
      flex-shrink: 0;
      text-align: center;
    }
    .cpn-jogadores-row {
      display: flex;
      gap: 6px;
      flex-wrap: wrap;
    }
    .cpn-jogador {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 3px;
      cursor: pointer;
      opacity: 0.9;
      transition: all 0.15s;
    }
    .cpn-jogador:active { transform: scale(0.92); }
    .cpn-foto {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      overflow: hidden;
      border: 2px solid rgba(255,255,255,0.25);
      background: rgba(0,0,0,0.35);
      display: flex;
      align-items: center;
      justify-content: center;
      transition: border-color 0.15s;
    }
    .cpn-foto img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .cpn-ini {
      font-size: 14px;
      font-weight: 800;
      color: rgba(255,255,255,0.85);
    }
    .cpn-nome {
      font-size: 9px;
      color: rgba(255,255,255,0.8);
      text-align: center;
      max-width: 52px;
      overflow: hidden;
      word-break: break-word;
      line-height: 1.2;
      font-weight: 600;
    }
    .cpn-selecionado .cpn-foto {
      border-color: #FFD700;
      box-shadow: 0 0 10px rgba(255,215,0,0.6);
    }
    .cpn-selecionado .cpn-nome { color: #FFD700; font-weight: 800; }
    .cpn-linha-centro {
      text-align: center;
      font-size: 10px;
      color: rgba(255,255,255,0.3);
      border-top: 1px solid rgba(255,255,255,0.15);
      border-bottom: 1px solid rgba(255,255,255,0.15);
      padding: 4px;
      margin: 2px 0;
      letter-spacing: 1px;
    }
    .cpn-selecionado-bar {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 8px;
      background: rgba(255,215,0,0.12);
      border-top: 1px solid rgba(255,215,0,0.25);
      font-size: 13px;
      font-weight: 600;
      color: #FFD700;
    }
    .cpn-limpar {
      background: none;
      border: none;
      color: rgba(255,215,0,0.6);
      cursor: pointer;
      font-size: 14px;
      font-family: inherit;
      padding: 0 4px;
    }
  `;
  document.head.appendChild(style);
})();
