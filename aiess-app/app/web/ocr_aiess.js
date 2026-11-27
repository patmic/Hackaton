// Lectura de PDF e imágenes EN EL NAVEGADOR (privacidad: el archivo nunca sale del equipo de la persona).
// - Imágenes: OCR con Tesseract.js (español).
// - PDF: texto con PDF.js; si una página es escaneada (sin texto), se dibuja y se le aplica OCR.
// Las librerías se cargan solo la primera vez que se usan.
(function () {
  const TESSERACT = 'https://cdn.jsdelivr.net/npm/tesseract.js@5.1.1/dist/tesseract.min.js';
  const PDFJS = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/build/pdf.min.js';
  const PDFJS_WORKER = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/build/pdf.worker.min.js';
  const MAX_PAGINAS = 5;

  function cargar(src) {
    return new Promise(function (ok, mal) {
      if (document.querySelector('script[src="' + src + '"]')) return ok();
      const s = document.createElement('script');
      s.src = src;
      s.onload = function () { ok(); };
      s.onerror = function () { mal(new Error('No se pudo cargar ' + src)); };
      document.head.appendChild(s);
    });
  }

  async function ocr(imagen) {
    await cargar(TESSERACT);
    const r = await window.Tesseract.recognize(imagen, 'spa');
    return (r && r.data && r.data.text) || '';
  }

  window.aiessLeerImagen = async function (bytes) {
    return await ocr(new Blob([bytes]));
  };

  window.aiessLeerPdf = async function (bytes) {
    await cargar(PDFJS);
    window.pdfjsLib.GlobalWorkerOptions.workerSrc = PDFJS_WORKER;
    const doc = await window.pdfjsLib.getDocument({ data: bytes }).promise;
    const partes = [];
    for (let i = 1; i <= Math.min(doc.numPages, MAX_PAGINAS); i++) {
      const pagina = await doc.getPage(i);
      const contenido = await pagina.getTextContent();
      let texto = contenido.items.map(function (x) { return x.str; }).join(' ').trim();
      if (texto.length < 20) {
        // Página escaneada: se dibuja y se lee con OCR.
        const vista = pagina.getViewport({ scale: 2 });
        const lienzo = document.createElement('canvas');
        lienzo.width = vista.width;
        lienzo.height = vista.height;
        await pagina.render({ canvasContext: lienzo.getContext('2d'), viewport: vista }).promise;
        texto = await ocr(lienzo);
      }
      partes.push(texto);
    }
    return partes.join('\n\n');
  };
})();
