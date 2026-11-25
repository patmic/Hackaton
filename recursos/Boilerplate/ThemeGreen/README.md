# ThemeGreen · Design System (UI Kit base)

Origen: `epnJISIC` (XIV JISIC, sitio de eventos). Tema **oscuro**, acento **verde lima**, superficies tipo vidrio, tipografía Plus Jakarta Sans + IBM Plex Mono.

Todos los valores se extrajeron de `frontend/src/css/style.css` y de los `<style>` de `pages/inicio`, `pages/comite` y `pages/XIV_JISIC`. No se inventó ningún valor.

## Contenido

```
ThemeGreen/
├── README.md
├── tokens/
│   ├── tokens.css     # variables CSS (:root)
│   └── tokens.json    # mismos tokens en JSON (Figma Tokens / Style Dictionary)
└── components/
    └── components.css # clases tg-* listas para usar
```

## Cómo usarlo en un proyecto nuevo

1. Copia `tokens/` y `components/` a tu proyecto.
2. Importa en este orden:
   ```html
   <link rel="stylesheet" href="tokens/tokens.css">
   <link rel="stylesheet" href="components/components.css">
   ```
3. Aplica la clase `tg-body` al `<body>`.
4. Usa las clases de componente, por ejemplo:
   ```html
   <a class="tg-btn tg-btn--solid" href="#">Inscribirme</a>
   <a class="tg-linkcard tg-linkcard--green" href="#">…</a>
   ```

Las fuentes se cargan con Google Fonts. El `@import` está en `tokens.css`. Si tu proyecto no puede usar Google Fonts, cambia `--font` y `--mono` por fuentes locales.

## Tokens principales

| Grupo | Token | Valor |
|---|---|---|
| Fondo | `--bg` | `#070807` |
| Texto | `--ink` / `--ink-dim` / `--ink-faint` | `#f4f6f1` / `#8b918a` / `#4a4f49` |
| Acento | `--lime` | `#9dff32` |
| Texto sobre acento | `--on-lime` | `#0c1206` |
| Secundarios | `--blue`, `--sky`, `--cyan`, `--live`, `--warn` | `#4c8dff`, `#8ec6ea`, `#4fd3e6`, `#ff4d6d`, `#ff8b6b` |
| Categorías de evento | `--cat-conferencia`, `--cat-workshop`, `--cat-networking`, `--cat-concurso`, `--cat-podcast` | `#6ea8ff`, `#ffb454`, `#ff7ab8`, `#ffd84d`, `#2fe0c8` |
| Tipografía | `--font` / `--mono` | Plus Jakarta Sans / IBM Plex Mono |
| Títulos | `--fs-display`, `--fs-h1`, `--fs-h2`, `--fs-h3` | `clamp(46px,7.4vw,108px)`, `clamp(32px,4vw,56px)`, `clamp(30px,4.4vw,58px)`, `clamp(20px,2vw,28px)` |
| Radios | `--r-pill`, `--r-xl`, `--r-lg`, `--r-md`, `--r-sm` | `999px`, `26px`, `18px`, `16px`, `12px` |
| Sombras | `--shadow-card`, `--glow-md`, `--glow-lg` | `0 30px 70px -30px rgba(0,0,0,.85)` y los glows verdes |

## Componentes incluidos

| Clase | Qué es | Origen en epnJISIC |
|---|---|---|
| `.tg-btn` + `--solid`, `--ghost`, `--outline`, `--key`, `--live`; `--sm`, `--lg`; `:disabled` | Botón en píldora | `.hbtn`, `.ctl button`, `.pc__cta` |
| `.tg-icon-btn` + `--solid` | Botón circular de icono | `.tc-nav button`, `.searchfield__submit` |
| `.tg-pillnav` | Barra de navegación en píldora (`aria-current="page"`) | `.topbar__nav` |
| `.tg-segmented` | Selector segmentado (`aria-selected="true"`) | `.segmented` |
| `.tg-tabs` / `.tg-tab` | Pestañas pequeñas | `.hor__tabs label` |
| `.tg-drop` / `.tg-drop__menu` | Menú desplegable | `.nav-drop` |
| `.tg-search` | Campo de búsqueda con botón | `.searchfield` |
| `.tg-eyebrow`, `.tg-chip` (`--soon`), `.tg-pill` | Etiquetas | `.stage__eyebrow`, `.chip`, `.pc__info li` |
| `.tg-cat` + `--conferencia`, `--workshop`, `--networking`, `--concurso`, `--podcast` | Badge de categoría | `.cat--*` |
| `.tg-card` (`--plain`) | Panel grande con gradiente azul y verde | `.pc` |
| `.tg-linkcard` + `--green`, `--violet`, `--amber`, `--teal` | Tarjeta enlace con acento | `.hcard--*` |
| `.tg-countdown` / `.tg-countdown__box` (`--accent`) | Cuenta regresiva | `.countdown`, `.pc__timer` |
| `.tg-avatar` (`--sm`) | Foto circular con anillo lima | `.pc__photo` |
| `.tg-tip` | Tooltip mono | `.evt__tip`, `.pagept__tip` |
| `.tg-dots` | Puntos de paginación | `.tc-dots` |
| `.tg-agenda` | Lista de agenda con hora | `.hor__p` |
| `.tg-rail` / `.tg-rail__fill` | Barra de progreso vertical | `.rail` |
| `.tg-nav`, `.tg-foot` | Barra superior y pie | `.site-nav`, `.site-foot` |
| Tipos: `.tg-display`, `.tg-h1`, `.tg-h2-gradient`, `.tg-h3`, `.tg-sub`, `.tg-lead`, `.tg-body-lg`, `.tg-label` | Escala tipográfica | `.hero__*`, `.stage__*`, `.xj__*` |

## Reglas de uso

- Fondo siempre oscuro (`--bg`). No uses texto negro sobre este tema.
- El acento lima se reserva para la acción principal y el estado activo. No lo uses como decoración.
- Las categorías de evento siempre llevan su color (`--cat-*`) con su ícono.
- Los gradientes de fondo de `.tg-card` y `.tg-linkcard` son parte del estilo. Si los quitas, pierde identidad.
- Respeta `prefers-reduced-motion`. Las clases de animación ya lo hacen.

## Responsive

Breakpoints usados en origen: `760px` (móvil) y `820px` (tablet). Hay reglas incluidas para la barra y el pie. Lo demás usa `clamp()`.

## Límites

- El kit **no incluye** la animación de scroll (`ascent`), el canvas `bloom`/`neuro` ni el carrusel de comité (`main.js`, `carousel.js`). Son comportamiento, no estilo. Si los necesitas, copia `src/js/` aparte.
- Las reglas `.ascent`, `.spine` y `.countdown` de origen, con posiciones absolutas para la línea de tiempo, no se incluyeron. Son específicas de esa página.
- Hay una regla `.month` y `.today` (línea de tiempo) que no se incluyó por el mismo motivo.
- Los `<style>` de `XIII_JISIC`, `XII_JISIC` y `XI_JISIC` no se revisaron. Son páginas de precedentes.
- Hay dos versiones de `style.css` en `epnJISIC` (`frontend/` y `JISIC_EPN/frontend/`). Esta base usa la de `frontend/`, que es la más reciente (2026-11-11).

## Home base de validación (`home/index.html`)

Página de prueba con los tokens y componentes del tema, más animaciones de **motion 14.14.0**: entrada escalonada, aparición al hacer scroll y hover/press en tarjetas y botones. Un indicador abajo a la derecha muestra `motion 14.14.0: OK` o el error.

**Cómo abrirla**
- Doble clic en `home/index.html`, o abrirla desde el navegador como `file://`. No requiere Docker ni servidor.
- Para evitar problemas de módulos en algunos navegadores, también puedes servir la carpeta: `python -m http.server 8080` y abrir `http://localhost:8080/home/`.

**Cómo carga motion**
1. Primero intenta el CDN (`cdn.jsdelivr.net/npm/motion@14.14.0/+esm`).
2. Si el CDN no responde, usa la copia local `../../../../node_modules/motion/dist/motion.js`. Esta ruta solo funciona si la carpeta está en `epnHackaton/recursos/Boilerplate/ThemeGreen/home/` y ya corriste `npm install` en `epnHackaton`.
3. Si ambas fallan, la página se ve igual, sin animación, y el indicador muestra el error.

**Docker:** no hace falta para ver la página. Docker solo sirve para correr el proyecto completo con su `npm ci`. Para validar motion dentro de la imagen, usa el `docker run` del Dockerfile de `epnHackaton`.
