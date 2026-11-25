# ThemeLight · Design System (UI Kit base)

Origen: `epnPoliEmpleo` (portal de empleo PoliEmpleo, Next.js + Tailwind v4). Tema **claro**, color de acción **azul-petróleo `#145962`**, barra superior oscura `#0a1a26`, tipografía Google Sans + Geist Mono + EB Garamond para la hoja de CV.

Valores extraídos de `src/app/globals.css`, `src/components/ui.tsx`, `layout.tsx` y los componentes `Navbar`, `Footer`, `JobCard`, `Flash`, `ChoiceChips`, `SubmitButton`. No se inventó ningún valor.

## Contenido

```
ThemeLight/
├── README.md
├── tokens/
│   ├── tokens.css     # variables CSS + bloque @theme inline para Tailwind v4
│   └── tokens.json    # mismos tokens en JSON
└── components/
    └── components.css # clases tl-* (equivalentes de ui.tsx)
```

## Cómo usarlo en un proyecto nuevo

### Opción A · Proyecto Next.js + Tailwind v4 (igual que epnPoliEmpleo)
1. Copia el contenido de `tokens/tokens.css` (`:root` y `@theme inline`) dentro de `src/app/globals.css`.
2. Mantén `@import "tailwindcss";` al inicio.
3. Usa las utilidades ya mapeadas: `bg-theme`, `text-theme`, `border-theme/30`, `bg-muted`, `text-muted-foreground`, `rounded-md`, etc.
4. Los componentes de `ui.tsx` se pueden copiar tal cual.

### Opción B · HTML plano o cualquier framework
```html
<link rel="stylesheet" href="tokens/tokens.css">
<link rel="stylesheet" href="components/components.css">
<body class="tl-body">
  <button class="tl-btn tl-btn--default">Guardar</button>
  <span class="tl-badge tl-badge--success">Seleccionado</span>
</body>
```

## Tokens principales

| Grupo | Token | Valor |
|---|---|---|
| Acción | `--theme-color` / `--theme-color-hover` | `#145962` / `rgba(20,89,98,.9)` |
| Marca | `--brand` / `--deep` / `--nav-bg` | `#355872` / `#0e434b` / `#0a1a26` |
| Fondo de página | `--page-bg` | `#f8fafc` |
| Superficie | `--background` / `--card` | `oklch(1 0 0)` (blanco) |
| Texto | `--foreground` / `--muted-foreground` | `oklch(0.145 0 0)` / `oklch(0.556 0 0)` |
| Bordes | `--border` / `--input` / `--slate-300` | `oklch(0.922 0 0)` / idem / `#cbd5e1` |
| Destructivo | `--destructive` | `oklch(0.58 0.22 27)` |
| Estados | `--status-ok-*`, `--status-warn-*`, `--status-err-*` | emerald / amber / red (50 y 800) |
| Gráficos | `--chart-1` … `--chart-5` | verde-teal, de claro a oscuro |
| Radios | `--radius` | `0.625rem`, con `--r-sm`, `--r-md`, `--r-lg`, `--r-xl`, `--r-2xl` |
| Controles | `--btn-h` / `--input-h` / `--badge-h` | `34px` / `36px` / `20px` |
| Tipografía | `--font-sans` / `--font-mono` / `--font-garamond` | Google Sans / Geist Mono / EB Garamond |

## Componentes incluidos

| Clase | Equivale a (`ui.tsx`) | Variantes |
|---|---|---|
| `.tl-btn` | `Button`, `buttonClass` | `--default`, `--secondary`, `--cancel`, `--ghost`, `--destructive`, `--link`; tamaños `--sm`, `--xs`, `--lg`, `--icon` |
| `.tl-badge` | `Badge` | `--default`, `--secondary`, `--outline`, `--destructive`, `--success`, `--warning`, `--theme` |
| `.tl-card` (`__head`, `__body`, `__desc`) | `Card`, `CardHeader`, `CardBody` | `--hover` |
| `.tl-stat` | `Stat` | |
| `.tl-input`, `.tl-textarea`, `.tl-select`, `.tl-field` | `Input`, `Textarea`, `Select`, `Field` | `aria-invalid="true"` |
| `.tl-chips` / `.tl-chip` | `ChoiceChips` | `aria-checked="true"` |
| `.tl-score` (`--high`, `--mid`, `--low`) | `ScoreBadge` | ≥70 verde, 40–69 ámbar, <40 rojo |
| `.tl-alert` (`--theme`, `--destructive`, `--ok`) | `Alert`, `Flash` | |
| `.tl-empty` | `Empty` | |
| `.tl-page-head`, `.tl-h1`, `.tl-page-desc` | `PageHeader` | |
| `.tl-avatar` (`--sm`, `--lg`) | `Avatar` | |
| `.tl-steps` (`.tl-step--done`) | `Stepper` | |
| `.tl-bars` | `BarList` | |
| `.tl-nav`, `.tl-nav__*` | `Navbar` | |
| `.tl-foot` | `Footer` | |
| `.tl-cv` | Hoja de CV Harvard (serif) | |
| `.tl-marquee`, `.tl-flow-line`, `.tl-ring`, `.tl-draw-in` | Animaciones de `globals.css` | respetan `prefers-reduced-motion` |

## Reglas de uso

- El color de acción es `--theme-color`. Úsalo solo para acciones principales y estados activos.
- Los estados (Seleccionado, Entrevista, Rechazado) usan los pares `--status-*`. No inventes colores nuevos.
- Usa `text-muted-foreground` para texto de apoyo, no gris a mano.
- Bordes de tarjeta: `--slate-300` (`tl-card`), no `--border`.
- Fondo de página `--page-bg`, con tarjetas blancas encima.
- En pantallas de datos, el número de estadística usa `tabular-nums`.

## Responsive

Contenedor máximo `72rem` (`max-w-6xl`). El pie pasa de columna a fila a partir de `768px`. La barra superior hace wrap en cualquier ancho.

## Límites

- No incluye la lógica de `Navbar`, `SearchBar` ni `UserMenu`. Solo el estilo.
- Los **mapas de color y de ícono** de `Navbar` (`Icon`) no se incluyeron. Son SVG y dependen del proyecto.
- Hay colores usados una sola vez en componentes específicos (por ejemplo, `shadow-[0_0_50px_rgba(20,89,98,0.18)]` en la página de inicio). Quedó como `--shadow-hero`, pero no se aplicó en `components.css`.
- Las carpetas `data/`, `backup/` y los logos de empresas no se copiaron. Son datos, no diseño.
- Se usa `oklch()`. Navegadores antiguos (sin soporte) necesitan un fallback en hex.

## Home base de validación (`home/index.html`)

Página de prueba con los tokens y componentes del tema, más animaciones de **motion 14.14.0**: entrada escalonada, aparición al hacer scroll, hover/press en tarjetas y botones, y animación de chips al seleccionar. Un indicador abajo a la derecha muestra `motion 14.14.0: OK` o el error.

**Cómo abrirla**
- Doble clic en `home/index.html`, o abrirla como `file://`. No requiere Docker ni servidor.
- Alternativa: `python -m http.server 8080` y abrir `http://localhost:8080/home/`.

**Cómo carga motion**
1. Primero intenta el CDN (`cdn.jsdelivr.net/npm/motion@14.14.0/+esm`).
2. Si el CDN no responde, usa la copia local `../../../../node_modules/motion/dist/motion.js`. Solo funciona si la carpeta está en `epnHackaton/recursos/Boilerplate/ThemeLight/home/` y ya corriste `npm install` en `epnHackaton`.
3. Si ambas fallan, la página se ve igual, sin animación, y el indicador muestra el error.

**Fuentes:** la página carga Google Sans, Geist Mono y EB Garamond desde Google Fonts. Sin conexión, usa las de respaldo del sistema.

**Docker:** no hace falta para ver la página. Para validar motion dentro de la imagen, usa el `docker run` del Dockerfile de `epnHackaton`.
