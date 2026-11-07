# 095 - Reporte W1-005 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:35 (GMT-3)
**Responde a:** (cierre del ítem W1-005 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-005

**Tarea:** Inventario de habilidades: mejores prácticas oficiales de Godot para UI/temas (Comparison: settings del proyecto vs docs) — referencias para M53.

## Fuentes consultadas (fecha de consulta: 2026-10-28)

| Fuente | URL | Fecha de consulta |
|--------|-----|-------------------|
| Godot 4.7 docs — User interface (UI) index | https://docs.godotengine.org/en/stable/tutorials/ui/index.html | 2026-10-28 |
| Godot 4.7 docs — Introduction to GUI skinning | https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html | 2026-10-28 |
| Godot 4.7 docs — Using the theme editor | https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html | 2026-10-28 |
| Godot 4.7 docs — Keyboard/Controller Navigation and Focus | https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html | 2026-10-28 |
| M53 01-Requerimientos.md | `DOCUMENTACION/53-UI-UX/plan-actual/01-Requerimientos.md` | 2026-10-28 |

## Resumen de mejores prácticas oficiales de Godot 4.x para UI/temas

### Sistema de skinning/theming (gui_skinning.html)
1. **Theme resource** es el núcleo: items de tipo Color, Constant, Font, Font size, Icon, StyleBox, organizados por *theme type* (una clase por tipo: Label, Button, etc.)
2. **Lookup cascada de tema**: 1) local override del control → 2) propiedad `theme` del control (árbol hacia arriba) → 3) project-wide theme (`GUI > Theme > Custom`) → 4) default theme de Godot
3. **Project settings relevantes**: `GUI > Theme > Custom` (tema personalizado a nivel de proyecto) y `GUI > Theme > Custom Font` (fuente de respaldo por defecto)
4. **StyleBox** para fondos de paneles; `focus` stylebox se dibuja como overlay (debe ser outline/translucent para que el fondo siga visible)
5. **Theme type variations**: permite múltiples presets de la misma clase (ej. `Header` como variación de `Label`)
6. **Local overrides**: cada control puede sobrescribir items de tema individualmente (Inspector o script)

### Navegación y foco (gui_navigation.html)
1. Acciones de input por defecto: `ui_up`, `ui_down`, `ui_focus_next`, etc. (configurables en Input Map del proyecto)
2. **Focus neighbors**: configurar nodos vecinos para navegación 4 direccional (flechas/D-pad) y Next/Previous (Tab)
3. **Focus mode**: `All` (click + teclado/mando), `Click` (solo click), `None` (sin foco); default varía por control (Label=None, Button=All)
4. **`grab_focus()`**: necesario al iniciar escena para que el foco funcione (sin esto, pulsar botones/teclas no hace nada)

### Containers de layout
- `BoxContainer`, `MarginContainer`, `ScrollContainer`, `TabContainer`, `Popup` — controles de layout recomendados por docs

## Comparación con M53 (01-Requerimientos.md)

| Aspecto | Práctica oficial Godot 4.x | Lo que declara M53 | Estado |
|---------|---------------------------|-------------------|--------|
| Tema a nivel de proyecto | `GUI > Theme > Custom` + `Custom Font` project settings | "Un solo tema visual" (RF8), no especifica cómo se aplica | ⚠️ Parcial |
| Lookup cascada | local → control.theme → project theme → default theme | No especifica la cascada de aplicación | ⚠️ Parcial |
| Focus inicial | `grab_focus()` al iniciar escena | No mencionado | ❌ Ausente |
| Navegación keyboard/mando | `ui_up/down`, focus neighbors, focus mode All/Click/None | "Navegables al 100% con gamepad, teclado y ratón" (RF2) | ✅ Coincide |
| Theme type variations | Presets por clase (ej. Header variación de Label) | No mencionado | ❌ Ausente |
| StyleBox para paneles | StyleBox con focus overlay | "StyleBoxFlat redondeado" (RF8) | ✅ Coincide |
| Fuentes | Font + Font size items por tema type | Nunito Bold 18px / Regular 14px; Fredoka One 24px | ✅ Coincide |
| Colores de tema | Color items por tema type | Paleta definida (#FFD4A3, #A8D8B9, etc.) | ✅ Coincide |
| Espaciado | Constant items (separación BoxContainer, etc.) | 8px/16px/24px | ✅ Coincide |
| Containers de layout | BoxContainer, MarginContainer, ScrollContainer, TabContainer, Popup | No especifica containers concretos | ⚠️ Parcial |

## Hallazgos / Brechas para M53

1. **M53 no especifica cómo se aplica el tema a nivel de proyecto** — debería usar `GUI > Theme > Custom` project setting para un tema único a nivel de proyecto, o bien `control.theme` property en la raíz de cada escena de UI
2. **M53 no menciona `grab_focus()`** — requerido por docs oficiales para que la navegación keyboard/controller funcione al iniciar cada escena de UI
3. **M53 no menciona Theme Type Variations** — útil para presets de botones/ventanas/popups (diferentes estilos dentro de la misma clase)
4. **M53 no especifica containers de layout concretos** — docs recomiendan BoxContainer, MarginContainer, ScrollContainer, TabContainer, Popup
5. **RF10 (UIManager, UILayer, HUDScreen, pila de capas modales, process_mode)** es arquitectura propia del juego más allá del sistema de tema de Godot — no entra en conflicto con las docs, es complementario

## Veredicto

M53 declara un diseño de UI coherente y alineado con los conceptos de Godot 4.x (tema único, fuentes, paleta, estilo redondeado, navegación multi-input), pero **omite referencias a las prácticas oficiales concretas**: project settings `GUI > Theme > Custom`/`Custom Font`, `grab_focus()` para focus inicial, Theme Type Variations, y containers de layout recomendados. Estas omisiones no son bloqueantes pero conviene documentarlas en el 03-Diseno.md o 04-Codigo.md de M53 para alineamiento total con Godot 4.x.

- hecho=1 (W1-005)
- skip=0
- fail=0

El riel W1 lleva 5 de 12 items completados; restan W1-006 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
