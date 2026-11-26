(() => {
  'use strict';

  const params = new URLSearchParams(window.location.search);
  const code = params.get('codigo') || '';
  const hash = params.get('hash') || '';
  const timestamp = params.get('fecha') || '';
  const expectedCode = /^[a-f\d]{64}$/i.test(hash)
    ? `IESS-${hash.slice(0, 4)}-${hash.slice(4, 8)}`.toUpperCase()
    : '';
  const isValid = Boolean(expectedCode && code.toUpperCase() === expectedCode);
  const status = document.getElementById('verificationStatus');

  document.getElementById('verificationCode').textContent = code || 'No disponible';
  document.getElementById('verificationHash').textContent = hash || 'No disponible';

  const date = new Date(timestamp);
  document.getElementById('verificationDate').textContent = timestamp && !Number.isNaN(date.getTime())
    ? date.toLocaleString('es-EC')
    : 'No disponible';

  document.getElementById('verificationTitle').textContent = isValid
    ? 'Correo verificado correctamente'
    : 'No se pudo validar el sello';
  document.getElementById('verificationMessage').textContent = isValid
    ? 'El código de verificación coincide con la huella SHA-256 asociada a este sello digital IESS.'
    : 'El código y la huella no coinciden o faltan datos. No confíes en este sello.';

  if (!isValid) {
    status.classList.add('smtp-verification__status--bad');
    document.getElementById('verificationIcon').textContent = '×';
  }
})();
