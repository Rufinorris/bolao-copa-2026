// =============================================
// CROPPER — editor de enquadramento por arraste (reutilizável)
// Abre um overlay: a pessoa arrasta a imagem dentro do quadro (na proporção do
// destino) e o resultado é recortado via canvas, já na posição escolhida.
// Uso: const blob = await enquadrarImagem(file, aspect, maxW);  // null se cancelar
//   aspect = largura/altura do destino (1 = quadrado p/ avatar; ~3 = faixa p/ capa)
// =============================================

function enquadrarImagem(file, aspect, maxW) {
  maxW = maxW || 900;
  return new Promise((resolve) => {
    if (!file || !file.type || !file.type.startsWith('image/')) { resolve(null); return; }
    const url = URL.createObjectURL(file);
    const img = new Image();

    img.onload = () => {
      const ov = document.createElement('div');
      ov.className = 'crop-overlay';
      ov.innerHTML =
        '<div class="crop-box">' +
          '<div class="crop-frame" id="_cropFrame"><img id="_cropImg" draggable="false" alt=""></div>' +
          '<div class="crop-hint">Arraste a foto para enquadrar</div>' +
          '<div class="crop-actions">' +
            '<button type="button" class="crop-btn crop-cancel" id="_cropCancel">Cancelar</button>' +
            '<button type="button" class="crop-btn crop-ok" id="_cropOk">Usar foto</button>' +
          '</div>' +
        '</div>';
      document.body.appendChild(ov);

      const frame = ov.querySelector('#_cropFrame');
      const imgEl = ov.querySelector('#_cropImg');
      imgEl.src = url;

      // Dimensões do quadro (proporção do destino)
      const fw = Math.min(window.innerWidth - 48, 360);
      const fh = Math.round(fw / aspect);
      frame.style.width = fw + 'px';
      frame.style.height = fh + 'px';
      if (Math.abs(aspect - 1) < 0.01) frame.style.borderRadius = '50%'; // avatar: prévia circular

      // Escala "cover": a imagem cobre todo o quadro
      const escala = Math.max(fw / img.naturalWidth, fh / img.naturalHeight);
      const dw = img.naturalWidth * escala;
      const dh = img.naturalHeight * escala;
      imgEl.style.width = dw + 'px';
      imgEl.style.height = dh + 'px';

      let ox = (fw - dw) / 2, oy = (fh - dh) / 2;
      const minX = fw - dw, minY = fh - dh;
      const clamp = () => { ox = Math.min(0, Math.max(minX, ox)); oy = Math.min(0, Math.max(minY, oy)); };
      const apply = () => { imgEl.style.transform = 'translate(' + ox + 'px,' + oy + 'px)'; };
      clamp(); apply();

      let dragging = false, sx = 0, sy = 0, oxs = 0, oys = 0;
      const down = (e) => { dragging = true; const p = e.touches ? e.touches[0] : e; sx = p.clientX; sy = p.clientY; oxs = ox; oys = oy; };
      const move = (e) => {
        if (!dragging) return;
        const p = e.touches ? e.touches[0] : e;
        ox = oxs + (p.clientX - sx); oy = oys + (p.clientY - sy);
        clamp(); apply();
        if (e.cancelable) e.preventDefault();
      };
      const up = () => { dragging = false; };
      frame.addEventListener('mousedown', down);
      frame.addEventListener('touchstart', down, { passive: true });
      window.addEventListener('mousemove', move);
      window.addEventListener('touchmove', move, { passive: false });
      window.addEventListener('mouseup', up);
      window.addEventListener('touchend', up);

      const cleanup = () => {
        window.removeEventListener('mousemove', move);
        window.removeEventListener('touchmove', move);
        window.removeEventListener('mouseup', up);
        window.removeEventListener('touchend', up);
        ov.remove();
        URL.revokeObjectURL(url);
      };

      ov.querySelector('#_cropCancel').onclick = () => { cleanup(); resolve(null); };
      ov.querySelector('#_cropOk').onclick = () => {
        const canvasW = maxW, canvasH = Math.round(maxW / aspect);
        const srcX = -ox / escala, srcY = -oy / escala;
        const srcW = fw / escala, srcH = fh / escala;
        const canvas = document.createElement('canvas');
        canvas.width = canvasW; canvas.height = canvasH;
        canvas.getContext('2d').drawImage(img, srcX, srcY, srcW, srcH, 0, 0, canvasW, canvasH);
        canvas.toBlob((b) => { cleanup(); resolve(b); }, 'image/jpeg', 0.85);
      };
    };

    img.onerror = () => { URL.revokeObjectURL(url); resolve(null); };
    img.src = url;
  });
}
