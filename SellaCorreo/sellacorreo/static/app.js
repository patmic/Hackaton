(() => {
  // ---- Inicio: el puntero da la vuelta completa; al llegar a una zona activa se detiene y su tarjeta se muestra completa
  const stage = document.getElementById("sc-home-stage");
  if (stage) {
    const dial = stage.querySelector(".sc-dial");
    const pointer = stage.querySelector(".sc-dial__pointer");
    const cards = Array.from(stage.querySelectorAll("[data-home-card]"));
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");
    const SPEED = 35;        // grados por segundo (la mitad que antes)
    const FOCUS_SPEED = 240; // al pasar el cursor o enfocar una tarjeta
    const HOLD = 2200;       // ms detenido en la zona activa
    const HALF = 26;         // semiancho de cada zona activa, en grados
    let zones = [], angle = 0, active = null, holdUntil = 0, inside = null, last = performance.now();

    const dist = (a, b) => { const d = Math.abs(a - b) % 360; return Math.min(d, 360 - d); };
    const applyPills = () => zones.forEach((z) => z.card.classList.toggle("sc-hcard--pill", !reduce.matches && z.kind !== active));
    // Ángulo de cada tarjeta desde el centro del dial (0 = arriba, sentido horario), medido con el diseño completo
    const measure = () => {
      stage.classList.add("is-measuring");
      cards.forEach((c) => c.classList.remove("sc-hcard--pill"));
      const d = dial.getBoundingClientRect();
      const cx = d.left + d.width / 2, cy = d.top + d.height / 2;
      zones = cards.map((card) => {
        const b = card.getBoundingClientRect();
        const a = Math.atan2(b.left + b.width / 2 - cx, -(b.top + b.height / 2 - cy)) * 180 / Math.PI;
        return { kind: card.dataset.homeCard, card, angle: (a + 360) % 360 };
      });
      // En móvil las tarjetas quedan apiladas bajo el dial y comparten ángulo: se separan a ambos lados
      if (zones.length > 1 && zones.every((z) => dist(z.angle, zones[0].angle) < 2 * HALF)) {
        const mid = zones[0].angle, step = 360 / zones.length;
        zones.forEach((z, i) => { z.angle = (mid + (i - (zones.length - 1) / 2) * step + 360) % 360; });
      }
      stage.classList.remove("is-measuring");
      applyPills();
    };
    const zoneAt = (a) => zones.find((z) => dist(a, z.angle) < HALF) || null;
    const setActive = (kind) => {
      if (kind === active) return;
      active = kind;
      if (kind) stage.dataset.show = kind; else delete stage.dataset.show;
      applyPills();
    };
    const frame = (now) => {
      const dt = Math.min(64, now - last) / 1000;
      last = now;
      const focus = stage.dataset.focus;
      const target = focus && zones.find((z) => z.kind === focus);
      if (target) {
        // El puntero va a la tarjeta enfocada por la ruta más corta y se queda allí
        const d = (((target.angle - angle) % 360) + 540) % 360 - 180;
        if (Math.abs(d) > 0.5) angle = (angle + Math.sign(d) * Math.min(FOCUS_SPEED * dt, Math.abs(d)) + 360) % 360;
        setActive(focus);
      } else if (now >= holdUntil) {
        angle = (angle + SPEED * dt) % 360;
        const z = zoneAt(angle);
        if (z && inside !== z.kind) { inside = z.kind; holdUntil = now + HOLD; } // se detiene al entrar
        if (!z) inside = null;
        setActive(z ? z.kind : null);
      }
      pointer.style.transform = `rotate(${angle}deg)`;
      requestAnimationFrame(frame);
    };
    cards.forEach((card) => {
      const kind = card.dataset.homeCard;
      const on = () => { stage.dataset.focus = kind; };
      const off = () => { if (stage.dataset.focus === kind) delete stage.dataset.focus; };
      let touch = false, wasOn = false;
      card.addEventListener("pointerdown", (e) => { touch = e.pointerType !== "mouse"; wasOn = stage.dataset.focus === kind; });
      card.addEventListener("mouseenter", on);
      card.addEventListener("mouseleave", off);
      card.addEventListener("focus", on);
      card.addEventListener("blur", off);
      // En táctil: el primer toque activa la tarjeta y el segundo navega
      card.addEventListener("click", (e) => { if (touch && !wasOn) { e.preventDefault(); on(); } });
    });
    document.addEventListener("pointerdown", (e) => { if (!e.target.closest("[data-home-card]")) delete stage.dataset.focus; });
    window.addEventListener("resize", measure);
    const start = () => {
      measure();
      pointer.style.transform = `rotate(${angle}deg)`;
      if (!reduce.matches) requestAnimationFrame(frame); // con movimiento reducido el puntero queda fijo
    };
    if (document.readyState === "complete") start(); else window.addEventListener("load", start);
  }

  // ---- GenKey: mapa de nodos con líneas curvas y anillo de progreso
  const map = document.getElementById("sc-map");
  if (map) {
    const svg = document.getElementById("sc-lines");
    const hub = document.getElementById("sc-hub");
    const ring = document.getElementById("sc-progress");
    const form = document.getElementById("genkey-form");
    const NS = "http://www.w3.org/2000/svg";
    const draw = () => {
      svg.innerHTML = "";
      if (getComputedStyle(svg).display === "none") return;
      const m = map.getBoundingClientRect(), h = hub.getBoundingClientRect();
      const cx = h.left + h.width / 2 - m.left, cy = h.top + h.height / 2 - m.top, r = h.width / 2;
      const path = (d, cls) => { const p = document.createElementNS(NS, "path"); p.setAttribute("d", d); if (cls) p.setAttribute("class", cls); svg.appendChild(p); };
      map.querySelectorAll("[data-node]").forEach((node) => {
        const b = node.getBoundingClientRect(), left = node.classList.contains("sc-node--left");
        const x = (left ? b.right : b.left) - m.left, y = b.top + b.height / 2 - m.top;
        // izquierda: convergen en el borde del sello; derecha: se abren desde el conector
        const ex = left ? cx - r : cx + r + 7, ey = left ? cy + (y - cy) * 0.25 : cy, k = (ex - x) * 0.55;
        path(`M${x},${y} C${x + k},${y} ${ex - k},${ey} ${ex},${ey}`, node.querySelector("input").checked ? "is-on" : "");
      });
    };
    const policies = () => {
      form.querySelectorAll(".sc-policy").forEach((f) => {
        const on = form.querySelector(`[name="${f.dataset.for}"]`).checked;
        // un campo oculto se desactiva: no se envía al servidor
        f.hidden = !on; f.querySelectorAll("input,select").forEach((i) => { i.disabled = !on; i.required = on; });
      });
    };
    const progress = () => {
      const steps = [!!form.querySelector('[name="taxonomia"]:checked'),
        form.querySelectorAll("[data-policy]:checked").length > 0,
        !form.querySelector('[name="pol_asunto"]').checked || form.asunto.value.trim().length > 0,
        !form.querySelector('[name="pol_palabra"]').checked || form.palabra.value.trim().length >= 3];
      ring.style.strokeDashoffset = String(100 - steps.filter(Boolean).length * 25);
    };
    const update = () => { policies(); progress(); draw(); };
    form.addEventListener("change", update);
    form.addEventListener("input", progress);
    // las líneas se recalculan con las posiciones reales: al cargar, al terminar de cargar las fuentes,
    // al cambiar el tamaño del mapa y al cambiar de ventana
    window.addEventListener("resize", draw);
    window.addEventListener("load", draw);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(draw);
    if ("ResizeObserver" in window) new ResizeObserver(() => draw()).observe(map);
    update();
  }
  // Copiar texto (enlace / HTML)
  document.querySelectorAll("[data-copy]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const el = document.getElementById(btn.dataset.copy);
      try { await navigator.clipboard.writeText(el.value); } catch (_) { el.select(); document.execCommand("copy"); }
      const t = btn.textContent; btn.textContent = "Copiado"; setTimeout(() => (btn.textContent = t), 1500);
    });
  });
  // Copiar la imagen con su enlace como contenido enriquecido (para pegar en Outlook o Gmail)
  document.querySelectorAll("[data-copy-html]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const box = document.getElementById(btn.dataset.copyHtml);
      const html = box.innerHTML;
      try {
        await navigator.clipboard.write([new ClipboardItem({
          "text/html": new Blob([html], { type: "text/html" }),
          "text/plain": new Blob([box.querySelector("a").href], { type: "text/plain" }),
        })]);
      } catch (_) {
        const range = document.createRange(); range.selectNode(box);
        const sel = window.getSelection(); sel.removeAllRanges(); sel.addRange(range);
        document.execCommand("copy"); sel.removeAllRanges();
      }
      const t = btn.textContent; btn.textContent = "Copiado: péguelo en su correo"; setTimeout(() => (btn.textContent = t), 2000);
    });
  });
})();
