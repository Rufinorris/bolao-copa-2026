// =============================================
// UPLOAD DE IMAGENS — compressão client-side + Supabase Storage
// Bucket "imagens". Guarda no banco apenas a URL pública (texto curto).
// As fotos ficam no CDN do Storage — não pesam o payload das telas.
// Uso: const url = await uploadImagem(file, 'capas'|'avatares', { max, quality })
// =============================================

async function _comprimirImagem(file, max, quality) {
  const bitmap = await createImageBitmap(file);
  const scale = Math.min(1, max / Math.max(bitmap.width, bitmap.height));
  const w = Math.round(bitmap.width * scale);
  const h = Math.round(bitmap.height * scale);
  const canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  canvas.getContext('2d').drawImage(bitmap, 0, 0, w, h);
  if (bitmap.close) bitmap.close();
  return new Promise((res, rej) =>
    canvas.toBlob(b => b ? res(b) : rej(new Error('Falha ao processar imagem')), 'image/jpeg', quality)
  );
}

// Sobe um Blob já pronto (ex: recortado pelo cropper) sem recomprimir.
async function uploadBlob(blob, prefixo) {
  const id = (crypto.randomUUID ? crypto.randomUUID() : Date.now() + '-' + Math.random().toString(36).slice(2));
  const path = `${prefixo}/${id}.jpg`;
  const { error } = await db.storage.from('imagens').upload(path, blob, {
    contentType: 'image/jpeg',
    cacheControl: '86400',
    upsert: false,
  });
  if (error) throw error;
  return db.storage.from('imagens').getPublicUrl(path).data.publicUrl;
}

async function uploadImagem(file, prefixo, opts = {}) {
  const { max = 640, quality = 0.82 } = opts;
  if (!file || !file.type.startsWith('image/')) throw new Error('Selecione uma imagem válida');
  const blob = await _comprimirImagem(file, max, quality);
  return uploadBlob(blob, prefixo);
}
