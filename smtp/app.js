/* =====================================================================
   IESS · Generador de Firma Digital y Sello de Cera (SHA-256 + Salt)
   - Calcula SHA-256 + Salt (Web Crypto API + fallback puro JS)
   - Genera sello de cera verde limón IESS en SVG y PNG (Canvas)
   - Copia firma HTML enriquecida (imagen + metadatos) lista para pegar
     en Gmail, Outlook o Webmail
   ===================================================================== */

(() => {
  'use strict';

  const TIPOLOGIAS = {
    T1: { nombre: 'Informativo', color: '#2f6e05', bg: '#ecfccb' },
    T2: { nombre: 'Financiero / Previsional', color: '#1e40af', bg: '#dbeafe' },
    T3: { nombre: 'Trámites / Clínico', color: '#0f766e', bg: '#ccfbf1' }
  };

  // Estado actual del último sello generado
  let currentSeal = null;
  let currentSealPngDataUrl = '';
  let currentSealPngBlob = null;
  let toastTimer = null;

  // Referencias DOM
  const el = {
    tabGenerar: document.getElementById('tabGenerar'),
    tabVerificar: document.getElementById('tabVerificar'),
    panelGenerar: document.getElementById('panelGenerar'),
    panelVerificar: document.getElementById('panelVerificar'),

    form: document.getElementById('sealForm'),
    emisorId: document.getElementById('emisorId'),
    tipologia: document.getElementById('tipologia'),
    asunto: document.getElementById('asunto'),
    cuerpo: document.getElementById('cuerpo'),
    saltInput: document.getElementById('saltInput'),
    btnToggleSalt: document.getElementById('btnToggleSalt'),
    btnNewSalt: document.getElementById('btnNewSalt'),
    btnLimpiar: document.getElementById('btnLimpiar'),

    waxSealContainer: document.getElementById('waxSealContainer'),
    shortCode: document.getElementById('shortCode'),
    timestampLabel: document.getElementById('timestampLabel'),
    emailSignaturePreview: document.getElementById('emailSignaturePreview'),
    fullHashOutput: document.getElementById('fullHashOutput'),
    saltOutput: document.getElementById('saltOutput'),
    contentHashOutput: document.getElementById('contentHashOutput'),
    jsonPayloadOutput: document.getElementById('jsonPayloadOutput'),

    btnCopyEmailBlock: document.getElementById('btnCopyEmailBlock'),
    btnCopyPng: document.getElementById('btnCopyPng'),
    btnDownloadPng: document.getElementById('btnDownloadPng'),
    btnCopyHash: document.getElementById('btnCopyHash'),
    btnCopyJson: document.getElementById('btnCopyJson'),

    btnCargarActual: document.getElementById('btnCargarActual'),
    vEmisorId: document.getElementById('vEmisorId'),
    vTipologia: document.getElementById('vTipologia'),
    vTimestamp: document.getElementById('vTimestamp'),
    vSalt: document.getElementById('vSalt'),
    vAsunto: document.getElementById('vAsunto'),
    vCuerpo: document.getElementById('vCuerpo'),
    vHashEsperado: document.getElementById('vHashEsperado'),
    btnEjecutarVerificacion: document.getElementById('btnEjecutarVerificacion'),
    verifyResult: document.getElementById('verifyResult'),

    toast: document.getElementById('toast')
  };

  /* -------------------------------------------------------------------
     1. Utilidades criptográficas: Salt seguro + SHA-256 (con fallback)
     ------------------------------------------------------------------- */

  function generateSalt(byteLength = 16) {
    const bytes = new Uint8Array(byteLength);
    if (window.crypto && window.crypto.getRandomValues) {
      window.crypto.getRandomValues(bytes);
    } else {
      for (let i = 0; i < byteLength; i++) {
        bytes[i] = Math.floor(Math.random() * 256);
      }
    }
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  }

  function normalizeText(text) {
    return (text || '')
      .replace(/\r\n/g, '\n')
      .replace(/[ \t]+/g, ' ')
      .trim();
  }

  // Fallback puro JS de SHA-256 (por si se abre en contexto no-HTTPS de LAN)
  function sha256Fallback(ascii) {
    const rightRotate = (v, a) => (v >>> a) | (v << (32 - a));
    const maxWord = Math.pow(2, 32);
    const words = [];
    const utf8 = unescape(encodeURIComponent(ascii));
    const asciiBitLength = utf8.length * 8;

    const hash = [
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ];
    const k = [
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ];

    const padded = utf8 + '\x80';
    let len = padded.length;
    while (len % 64 - 56) len++;
    const full = padded + '\x00'.repeat(len - padded.length);

    for (let i = 0; i < full.length; i++) {
      words[i >> 2] |= full.charCodeAt(i) << ((3 - i) % 4) * 8;
    }
    words[words.length] = (asciiBitLength / maxWord) | 0;
    words[words.length] = asciiBitLength;

    for (let j = 0; j < words.length;) {
      const w = words.slice(j, j += 16);
      const oldHash = hash.slice(0);
      for (let i = 0; i < 64; i++) {
        const w15 = w[i - 15], w2 = w[i - 2];
        const a = hash[0], e = hash[4];
        const temp1 = hash[7]
          + (rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25))
          + ((e & hash[5]) ^ ((~e) & hash[6]))
          + k[i]
          + (w[i] = (i < 16) ? w[i] : (
            w[i - 16]
            + (rightRotate(w15, 7) ^ rightRotate(w15, 18) ^ (w15 >>> 3))
            + w[i - 7]
            + (rightRotate(w2, 17) ^ rightRotate(w2, 19) ^ (w2 >>> 10))
          ) | 0);
        const temp2 = (rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22))
          + ((a & hash[1]) ^ (a & hash[2]) ^ (hash[1] & hash[2]));

        hash.unshift((temp1 + temp2) | 0);
        hash[4] = (hash[4] + temp1) | 0;
        hash.pop();
      }
      for (let i = 0; i < 8; i++) hash[i] = (hash[i] + oldHash[i]) | 0;
    }

    let result = '';
    for (let i = 0; i < 8; i++) {
      for (let j = 3; j + 1; j--) {
        const b = (hash[i] >> (j * 8)) & 255;
        result += ((b < 16) ? '0' : '') + b.toString(16);
      }
    }
    return result;
  }

  async function sha256Hex(message) {
    if (window.crypto && window.crypto.subtle) {
      const data = new TextEncoder().encode(message);
      const buf = await window.crypto.subtle.digest('SHA-256', data);
      return Array.from(new Uint8Array(buf), (b) => b.toString(16).padStart(2, '0')).join('');
    }
    return sha256Fallback(message);
  }

  async function computeDigitalSeal({ emisorId, tipologia, timestamp, asunto, cuerpo, salt }) {
    const normalizedContent = `${normalizeText(asunto)}\n${normalizeText(cuerpo)}`;
    const contentHash = await sha256Hex(normalizedContent);
    const canonicalPayload = `${emisorId}|${tipologia}|${timestamp}|${contentHash}|${salt}`;
    const finalHash = await sha256Hex(canonicalPayload);
    const shortCode = `IESS-${finalHash.slice(0, 4).toUpperCase()}-${finalHash.slice(4, 8).toUpperCase()}`;

    return {
      contentHash,
      finalHash,
      shortCode
    };
  }

  /* -------------------------------------------------------------------
     2. Generador del Sello de Cera IESS (Color Verde Limón) en SVG + PNG
     ------------------------------------------------------------------- */

  function buildWaxSealSvg(shortCode, tipologia) {
    // Silueta orgánica de sello de cera prensado a mano (16 lóbulos suaves)
    const cx = 150;
    const cy = 150;
    const points = 96;
    let d = '';
    for (let i = 0; i < points; i++) {
      const angle = (i / points) * Math.PI * 2;
      // Ondulación orgánica simulando cera derretida y sellada
      const r = 128
        + Math.sin(angle * 11) * 5.2
        + Math.cos(angle * 7 + 0.9) * 4.4
        + Math.sin(angle * 3 - 0.5) * 3.1;
      const x = cx + Math.cos(angle) * r;
      const y = cy + Math.sin(angle) * r;
      d += (i === 0 ? 'M ' : ' L ') + x.toFixed(2) + ' ' + y.toFixed(2);
    }
    d += ' Z';

    const safeCode = escapeXml(shortCode || 'IESS-SEAL');
    const safeTip = escapeXml(tipologia || 'T2');

    return `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300" width="300" height="300" role="img" aria-label="Sello de cera digital IESS verde limón ${safeCode}">
  <defs>
    <!-- Gradiente principal de cera verde limón -->
    <radialGradient id="waxBodyGrad" cx="34%" cy="28%" r="72%">
      <stop offset="0%" stop-color="#dcff8a"/>
      <stop offset="28%" stop-color="#a8ff3e"/>
      <stop offset="68%" stop-color="#76dc16"/>
      <stop offset="92%" stop-color="#4e9e08"/>
      <stop offset="100%" stop-color="#356e04"/>
    </radialGradient>

    <!-- Relieve interno hundido del cuño -->
    <radialGradient id="waxInnerWell" cx="62%" cy="66%" r="68%">
      <stop offset="0%" stop-color="#b6ff57"/>
      <stop offset="55%" stop-color="#85eb1f"/>
      <stop offset="100%" stop-color="#4c9c07"/>
    </radialGradient>

    <!-- Brillo especular de la cera -->
    <linearGradient id="waxGloss" x1="15%" y1="10%" x2="80%" y2="85%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.52"/>
      <stop offset="35%" stop-color="#ffffff" stop-opacity="0.08"/>
      <stop offset="100%" stop-color="#173302" stop-opacity="0.28"/>
    </linearGradient>

    <!-- Sombra exterior del sello -->
    <filter id="waxShadow" x="-12%" y="-12%" width="124%" height="124%">
      <feDropShadow dx="0" dy="7" stdDeviation="6" flood-color="#0a1602" flood-opacity="0.42"/>
    </filter>

    <!-- Relieve del emblema -->
    <filter id="emboss" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="1.4" stdDeviation="0.6" flood-color="#e5ffaa" flood-opacity="0.65"/>
      <feDropShadow dx="0" dy="-1.2" stdDeviation="0.6" flood-color="#224702" flood-opacity="0.55"/>
    </filter>

    <!-- Trayectorias circulares para texto grabado -->
    <path id="topArc" d="M 58,150 A 92,92 0 1,1 242,150" fill="none"/>
    <path id="bottomArc" d="M 242,150 A 92,92 0 1,1 58,150" fill="none"/>
  </defs>

  <!-- Cuerpo orgánico de cera verde limón -->
  <g filter="url(#waxShadow)">
    <path d="${d}" fill="url(#waxBodyGrad)" stroke="#3e8205" stroke-width="2.5"/>
    <path d="${d}" fill="url(#waxGloss)"/>
  </g>

  <!-- Borde elevado del sello (anillo exterior) -->
  <circle cx="150" cy="150" r="109" fill="none" stroke="#d8ff82" stroke-opacity="0.65" stroke-width="5"/>
  <circle cx="150" cy="150" r="106" fill="none" stroke="#316603" stroke-opacity="0.55" stroke-width="3"/>

  <!-- Pozo interior prensado -->
  <circle cx="150" cy="150" r="103" fill="url(#waxInnerWell)" stroke="#3a7804" stroke-width="2"/>
  <circle cx="150" cy="150" r="80" fill="none" stroke="#285402" stroke-opacity="0.42" stroke-width="1.4" stroke-dasharray="3.5 3.5"/>
  <circle cx="150" cy="150" r="75" fill="none" stroke="#d9ff86" stroke-opacity="0.45" stroke-width="1.2"/>

  <!-- Texto circular superior -->
  <text font-family="Plus Jakarta Sans, Segoe UI, Arial, sans-serif" font-size="11.5" font-weight="800" fill="#183802" letter-spacing="2.4">
    <textPath href="#topArc" startOffset="50%" text-anchor="middle">★ IESS · FIRMA DIGITAL ★</textPath>
  </text>

  <!-- Texto circular inferior -->
  <text font-family="IBM Plex Mono, Consolas, monospace" font-size="10.2" font-weight="700" fill="#1d4203" letter-spacing="1.6">
    <textPath href="#bottomArc" startOffset="50%" text-anchor="middle">SHA-256 + SALT · ${safeTip}</textPath>
  </text>

  <!-- Emblema central IESS en relieve -->
  <g filter="url(#emboss)">
    <!-- Escudo institucional minimalista -->
    <path d="M150 93 L188 106 V142 C188 168 171 186 150 197 C129 186 112 168 112 142 V106 Z"
          fill="#62bf0f" stroke="#1b3d02" stroke-width="2.4"/>
    <path d="M150 99 L182 110 V141 C182 163 168 179 150 189 C132 179 118 163 118 141 V110 Z"
          fill="none" stroke="#d7ff82" stroke-opacity="0.65" stroke-width="1.4"/>

    <!-- Cruz / símbolo de seguridad social arriba -->
    <path d="M147 109 H153 V114 H158 V120 H153 V125 H147 V120 H142 V114 H147 Z" fill="#e9ffba"/>

    <!-- Siglas IESS -->
    <text x="150" y="153" text-anchor="middle"
          font-family="Plus Jakarta Sans, Segoe UI, Arial, sans-serif"
          font-weight="900" font-size="29" letter-spacing="-0.8" fill="#102601">IESS</text>

    <!-- Línea separadora y código corto -->
    <line x1="127" y1="160" x2="173" y2="160" stroke="#1b3d02" stroke-opacity="0.5" stroke-width="1.4"/>
    <text x="150" y="173" text-anchor="middle"
          font-family="IBM Plex Mono, Consolas, monospace"
          font-weight="700" font-size="8.6" letter-spacing="0.4" fill="#102601">${safeCode}</text>
  </g>

  <!-- Destello superior izquierdo tipo cera pulida -->
  <ellipse cx="102" cy="84" rx="28" ry="12" transform="rotate(-32 102 84)" fill="#ffffff" fill-opacity="0.26"/>
</svg>`.trim();
  }

  function escapeXml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }

  function svgToPng(svgString, size = 480) {
    return new Promise((resolve, reject) => {
      const svgBlob = new Blob([svgString], { type: 'image/svg+xml;charset=utf-8' });
      const url = URL.createObjectURL(svgBlob);
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = size;
        canvas.height = size;
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, size, size);
        ctx.drawImage(img, 0, 0, size, size);
        URL.revokeObjectURL(url);

        const dataUrl = canvas.toDataURL('image/png');
        canvas.toBlob((blob) => {
          resolve({ dataUrl, blob });
        }, 'image/png');
      };
      img.onerror = (err) => {
        URL.revokeObjectURL(url);
        reject(err);
      };
      img.src = url;
    });
  }

  /* -------------------------------------------------------------------
     3. Bloque HTML de firma digital compatible con Gmail / Outlook
     ------------------------------------------------------------------- */

  function buildEmailSignatureHtml(seal, sealImgSrc) {
    const tip = TIPOLOGIAS[seal.tipologia] || TIPOLOGIAS.T1;
    const hashShort = `${seal.hash.slice(0, 18)}…${seal.hash.slice(-12)}`;
    const fechaLocal = new Date(seal.timestamp).toLocaleString('es-EC', {
      dateStyle: 'medium',
      timeStyle: 'short'
    });
    const verificationUrl = escapeXml(buildVerificationUrl(seal));

    return `
<table cellpadding="0" cellspacing="0" border="0" style="font-family:'Segoe UI',Arial,Helvetica,sans-serif;border-collapse:collapse;max-width:560px;width:100%;background:#f9fef3;border:1.5px solid #a3e635;border-radius:14px;">
  <tr>
    <td style="padding:14px 16px;vertical-align:middle;width:106px;text-align:center;">
      <a href="${verificationUrl}" aria-label="Verificar sello digital IESS ${escapeXml(seal.shortCode)}">
        <img src="${sealImgSrc}" alt="Sello Digital IESS ${escapeXml(seal.shortCode)}" width="96" height="96" style="display:block;margin:0 auto;border:0;width:96px;height:96px;">
      </a>
    </td>
    <td style="padding:14px 16px 14px 4px;vertical-align:middle;color:#142606;">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:#3f7d07;margin-bottom:3px;">
        Sello Digital Institucional · IESS
      </div>
      <div style="font-size:14px;font-weight:700;color:#0f172a;margin-bottom:4px;">
        ${escapeXml(seal.emisorNombre)}
      </div>
      <div style="margin-bottom:7px;">
        <span style="display:inline-block;padding:2px 8px;border-radius:999px;font-size:11px;font-weight:700;background:${tip.bg};color:${tip.color};border:1px solid rgba(0,0,0,0.08);">
          ${escapeXml(seal.tipologia)} · ${escapeXml(tip.nombre)}
        </span>
        <span style="display:inline-block;margin-left:6px;font-size:11px;color:#475569;">
          ${escapeXml(fechaLocal)}
        </span>
      </div>
      <div style="font-family:Consolas,'Courier New',monospace;font-size:11.5px;background:#ffffff;border:1px solid #d9f99d;border-radius:8px;padding:6px 9px;color:#1a2e05;line-height:1.45;">
        <strong>Código:</strong> ${escapeXml(seal.shortCode)}<br>
        <strong>SHA-256:</strong> ${escapeXml(hashShort)}
      </div>
      <div style="font-size:10.5px;color:#4b5563;margin-top:6px;line-height:1.35;">
        Correo protegido con huella SHA-256 + Salt. Verifica este código únicamente en el canal oficial del IESS.
      </div>
    </td>
  </tr>
</table>`.trim();
  }

  function buildVerificationUrl(seal) {
    const url = new URL('verificar.html', window.location.href);
    url.searchParams.set('codigo', seal.shortCode);
    url.searchParams.set('hash', seal.hash);
    url.searchParams.set('fecha', seal.timestamp);
    return url.href;
  }

  function buildEmailSignaturePlainText(seal) {
    const tip = TIPOLOGIAS[seal.tipologia] || TIPOLOGIAS.T1;
    return [
      '--------------------------------------------------',
      'SELLO DIGITAL INSTITUCIONAL · IESS (SHA-256 + SALT)',
      `Emisor: ${seal.emisorNombre} (${seal.emisorId})`,
      `Tipología: ${seal.tipologia} — ${tip.nombre}`,
      `Código de verificación: ${seal.shortCode}`,
      `SHA-256: ${seal.hash}`,
      `Fecha UTC: ${seal.timestamp}`,
      'Verifica este correo únicamente en el canal oficial del IESS.',
      '--------------------------------------------------'
    ].join('\n');
  }

  /* -------------------------------------------------------------------
     4. Renderizado y acciones principales
     ------------------------------------------------------------------- */

  async function generateAndRender(animateStamp = true) {
    const emisorOpt = el.emisorId.options[el.emisorId.selectedIndex];
    const emisorId = el.emisorId.value;
    const emisorNombre = emisorOpt ? emisorOpt.dataset.nombre : emisorId;
    const tipologia = el.tipologia.value;
    const asunto = el.asunto.value.trim();
    const cuerpo = el.cuerpo.value.trim();
    let salt = el.saltInput.value.trim();

    if (!salt) {
      salt = generateSalt(16);
      el.saltInput.value = salt;
    }

    if (!asunto && !cuerpo) {
      showToast('Escribe al menos un asunto o contenido para sellar el correo.', 'error');
      return;
    }

    const timestamp = new Date().toISOString();
    const { contentHash, finalHash, shortCode } = await computeDigitalSeal({
      emisorId,
      tipologia,
      timestamp,
      asunto,
      cuerpo,
      salt
    });

    currentSeal = {
      emisorId,
      emisorNombre,
      tipologia,
      asunto,
      cuerpo,
      salt,
      timestamp,
      contentHash,
      hash: finalHash,
      shortCode
    };
    el.waxSealContainer.href = buildVerificationUrl(currentSeal);

    // 1. Renderizar SVG interactivo del sello de cera verde limón
    const svgMarkup = buildWaxSealSvg(shortCode, tipologia);
    el.waxSealContainer.innerHTML = svgMarkup;

    if (animateStamp) {
      el.waxSealContainer.classList.remove('is-stamping');
      void el.waxSealContainer.offsetWidth;
      el.waxSealContainer.classList.add('is-stamping');
    }

    // 2. Convertir a PNG (para vista previa de correo, portapapeles y descarga)
    try {
      const png = await svgToPng(svgMarkup, 480);
      currentSealPngDataUrl = png.dataUrl;
      currentSealPngBlob = png.blob;
    } catch (err) {
      console.error('Error generando PNG del sello:', err);
      currentSealPngDataUrl = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svgMarkup);
      currentSealPngBlob = null;
    }

    // 3. Actualizar textos y vista previa del correo
    el.shortCode.textContent = shortCode;
    el.timestampLabel.textContent = `Emitido: ${new Date(timestamp).toLocaleString('es-EC')} · Salt 128-bit`;
    el.emailSignaturePreview.innerHTML = buildEmailSignatureHtml(currentSeal, currentSealPngDataUrl);

    // 4. Actualizar detalles técnicos
    el.fullHashOutput.textContent = finalHash;
    el.saltOutput.textContent = salt;
    el.contentHashOutput.textContent = contentHash;

    const apiPayload = {
      emisor_id: emisorId,
      emisor_nombre: emisorNombre,
      tipologia,
      asunto_resumen: asunto.slice(0, 120),
      hash: finalHash,
      codigo_corto: shortCode,
      timestamp,
      ttl_dias: 30
    };
    el.jsonPayloadOutput.textContent = JSON.stringify(apiPayload, null, 2);
  }

  /* -------------------------------------------------------------------
     5. Copiado al portapapeles (Rich HTML para correo + PNG + Texto)
     ------------------------------------------------------------------- */

  async function copyEmailBlock() {
    if (!currentSeal) return;
    const html = buildEmailSignatureHtml(currentSeal, currentSealPngDataUrl);
    const plain = buildEmailSignaturePlainText(currentSeal);

    try {
      if (navigator.clipboard && window.ClipboardItem) {
        const item = new ClipboardItem({
          'text/html': new Blob([html], { type: 'text/html' }),
          'text/plain': new Blob([plain], { type: 'text/plain' })
        });
        await navigator.clipboard.write([item]);
        showToast('Sello de cera + firma copiados. Pega con Ctrl+V en tu correo.');
        return;
      }
    } catch (err) {
      console.warn('ClipboardItem HTML falló, usando fallback de selección:', err);
    }

    // Fallback clásico de selección DOM (funciona incluso en file://)
    try {
      const range = document.createRange();
      range.selectNodeContents(el.emailSignaturePreview);
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
      const ok = document.execCommand('copy');
      sel.removeAllRanges();
      if (ok) {
        showToast('Sello de cera + firma copiados. Pega con Ctrl+V en tu correo.');
        return;
      }
    } catch (err) {
      console.warn('execCommand copy falló:', err);
    }

    await copyPlainText(plain, 'Firma en texto plano copiada al portapapeles.');
  }

  async function copySealPng() {
    if (!currentSealPngBlob) {
      showToast('No se pudo preparar la imagen PNG. Usa "Descargar PNG".', 'error');
      return;
    }
    try {
      if (navigator.clipboard && window.ClipboardItem) {
        await navigator.clipboard.write([
          new ClipboardItem({ 'image/png': currentSealPngBlob })
        ]);
        showToast('Imagen del sello de cera verde limón copiada. Pégala con Ctrl+V.');
        return;
      }
    } catch (err) {
      console.warn('No se pudo copiar PNG directo:', err);
    }
    showToast('Tu navegador bloqueó copiar imagen directa. Usa "Descargar PNG".', 'error');
  }

  function downloadSealPng() {
    if (!currentSeal || !currentSealPngDataUrl) return;
    const a = document.createElement('a');
    a.href = currentSealPngDataUrl;
    a.download = `sello-cera-${currentSeal.shortCode.toLowerCase()}.png`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    showToast(`Descargado: sello-cera-${currentSeal.shortCode.toLowerCase()}.png`);
  }

  async function copyPlainText(text, successMsg) {
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text);
        showToast(successMsg);
        return;
      }
    } catch (_) {}

    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    ta.remove();
    showToast(successMsg);
  }

  /* -------------------------------------------------------------------
     6. Verificador de integridad
     ------------------------------------------------------------------- */

  function loadCurrentIntoVerifier() {
    if (!currentSeal) return;
    el.vEmisorId.value = currentSeal.emisorId;
    el.vTipologia.value = currentSeal.tipologia;
    el.vTimestamp.value = currentSeal.timestamp;
    el.vSalt.value = currentSeal.salt;
    el.vAsunto.value = currentSeal.asunto;
    el.vCuerpo.value = currentSeal.cuerpo;
    el.vHashEsperado.value = currentSeal.hash;
    el.verifyResult.hidden = true;
    showToast('Datos del último sello cargados en el verificador.');
  }

  async function runVerification() {
    const expected = el.vHashEsperado.value.trim().toLowerCase();
    if (!expected) {
      showToast('Ingresa el hash SHA-256 esperado para verificar.', 'error');
      return;
    }

    const { finalHash } = await computeDigitalSeal({
      emisorId: el.vEmisorId.value.trim(),
      tipologia: el.vTipologia.value,
      timestamp: el.vTimestamp.value.trim(),
      asunto: el.vAsunto.value,
      cuerpo: el.vCuerpo.value,
      salt: el.vSalt.value.trim()
    });

    const match = finalHash === expected;
    el.verifyResult.hidden = false;
    el.verifyResult.className = `verify-banner ${match ? 'verify-banner--ok' : 'verify-banner--bad'}`;
    el.verifyResult.innerHTML = match
      ? `<strong>✔ FIRMA VÁLIDA — Correo íntegro y auténtico</strong><br>El hash recalculado coincide exactamente con el sello institucional.<code>${finalHash}</code>`
      : `<strong>✖ FIRMA INVÁLIDA — Posible alteración o suplantación</strong><br>El contenido, metadatos o salt no coinciden con el sello original.<code>Calculado: ${finalHash}</code>`;
  }

  /* -------------------------------------------------------------------
     7. Navegación, Toast y Eventos
     ------------------------------------------------------------------- */

  function showToast(message, tone = 'ok') {
    el.toast.textContent = message;
    el.toast.dataset.tone = tone;
    el.toast.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
      el.toast.hidden = true;
    }, 3400);
  }

  function switchTab(mode) {
    const isGen = mode === 'generar';
    el.panelGenerar.hidden = !isGen;
    el.panelVerificar.hidden = isGen;
    if (isGen) {
      el.tabGenerar.setAttribute('aria-current', 'page');
      el.tabVerificar.removeAttribute('aria-current');
    } else {
      el.tabVerificar.setAttribute('aria-current', 'page');
      el.tabGenerar.removeAttribute('aria-current');
    }
  }

  el.tabGenerar.addEventListener('click', () => switchTab('generar'));
  el.tabVerificar.addEventListener('click', () => switchTab('verificar'));

  el.form.addEventListener('submit', (e) => {
    e.preventDefault();
    generateAndRender(true);
    showToast('Nuevo sello de cera SHA-256 + Salt generado.');
  });

  el.btnNewSalt.addEventListener('click', () => {
    el.saltInput.value = generateSalt(16);
    generateAndRender(true);
    showToast('Salt regenerado y firma recalculada.');
  });

  el.btnToggleSalt.addEventListener('click', () => {
    const hidden = el.saltInput.type === 'password';
    el.saltInput.type = hidden ? 'text' : 'password';
    el.btnToggleSalt.textContent = hidden ? 'Ocultar' : 'Mostrar';
  });

  el.btnLimpiar.addEventListener('click', () => {
    el.asunto.value = '';
    el.cuerpo.value = '';
    el.saltInput.value = generateSalt(16);
    el.asunto.focus();
  });

  el.btnCopyEmailBlock.addEventListener('click', copyEmailBlock);
  el.btnCopyPng.addEventListener('click', copySealPng);
  el.btnDownloadPng.addEventListener('click', downloadSealPng);
  el.btnCopyHash.addEventListener('click', () => {
    if (!currentSeal) return;
    copyPlainText(currentSeal.hash, 'Hash SHA-256 (64 hex) copiado.');
  });
  el.btnCopyJson.addEventListener('click', () => {
    copyPlainText(el.jsonPayloadOutput.textContent, 'JSON para API White List copiado.');
  });

  el.btnCargarActual.addEventListener('click', loadCurrentIntoVerifier);
  el.btnEjecutarVerificacion.addEventListener('click', runVerification);

  // Inicialización automática con un sello de demostración listo para usar
  el.saltInput.value = generateSalt(16);
  generateAndRender(false);
})();
