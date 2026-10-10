# 24 - M110 triaje de `[?]` — BLOQUE 1/5 (L66-L100, 27 ítems): 2 a `[x]`, 25 a `[ ]`, 0 quedan `[?]`

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 22:34:37
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 23-2026-10-09_22-09-17-atria-a-stepfun-step-5-preview-e12c-aceptado-delta-0-m110-triaje-90-dudas-bundle-grande.md

## Contexto medido

M110: **135 [x] / 0 [ ] / 90 [?] = 225** (regex propio, coincide con GLOBAL 135/225). Los 90 `[?]` están todos con dueño declarado (mayoría "M110-UI", varios M64/M102/M117). Estructura del disco:

```
scripts/debug/: debug_menu.gd, debug_menu_ui.gd, debug_console.gd,
                debug_visualizer.gd, poi_list.gd + 6 suites de test
data/debug/:    debug_menu_config.json, poi_list.tres
```

**Hallazgo estructural del módulo:** el backend data-driven existe (`debug_menu_config.json` con pestañas, `_cargar_config()` L50, `poi_list.gd` con `obtener_nombres()`/`obtener_pos()`, `debug_console.gd` con `limpiar()`/`obtener_lineas()`, `debug_visualizer.gd` con `configurar_manual(tipo, activo)` + `obtener_estado()`), pero **la capa UI concreta (widgets por panel) no está construida**: `debug_menu_ui.gd` tiene `_configurar_tabs()` L41 y `obtener_contenido()` L84 pero los widgets internos no existen. Eso explica por qué la tanda entera de "widgets" es `[?` con dueño M110-UI.

## Bloque 1 — Layout y paneles (L66-L100, 27 ítems)

### (a) Ya hecho → proponer `[x]` (2)

| L | Ítem (recortado) | Evidencia en disco |
|---|---|---|
| **L74** | `[?]` POI predefinidos (dropdown) | ✅ **`poi_list.gd` existe** (26 líneas) con `obtener_nombres() -> Array` (L10) — justo lo que un dropdown consume — y **`data/debug/poi_list.tres` existe y está versionado**. El backend del dropdown está completo; el widget visual sigue siendo de M110-UI. **Propongo `[x]`** con nota "backend verificado (poi_list.gd obttnombres + poi_list.tres); widget visual dueño M110-UI" |
| **L155** | `[?]` Botón "Limpiar consola" | ✅ **`debug_console.gd:84` `func limpiar() -> void`** + `agregar_linea_publica()` L97. La acción de limpiar existe en el backend de consola. **Propongo `[x]`** con nota "limpiar() verificado en debug_console.gd:84" |

### (b) Pendiente real → proponer `[ ]` (25)

**Panel Layout (3):**
- **L66** Documentar layout de panel — no hay documento de layout en el módulo (verifiqué `plan-actual/`: no existe `06` ni sección de layout de widgets). → `[ ]`
- **L72** Teletransporte: inputs X/Y/Z — no hay inputs en `debug_menu_ui.gd`; `_tp_center()` en el backend es posición fija, no coords manuales. → `[ ]`
- **L73** Teletransporte: botón "Ir" — sin botón asociado (sin widget). → `[ ]`

**Panel Inventario (5):**
- **L76** Selector de item — no hay selector. → `[ ]`
- **L77** Input de cantidad — no hay input. → `[ ]`
- **L78** Botón "Dar" — no existe (ni método `dar_item()`). → `[ ]`
- **L79** Input de dinero — no existe. → `[ ]`
- **L80** Botón "Dar dinero" — no existe. → `[ ]`

**Panel Progresión (8):**
- **L81-L88** selectores de misión/herramienta/isla/Sello + botones Completar/Desbloquear ×4 — `debug_menu.gd` tiene `_desbloquear_herramienta`/`_desbloquear_isla` en el backend (verificado en el archivo), pero **los widgets selector+botón no existen** y el ítem pide el control UI. → `[ ]` (8 ítems)

**Panel Mundo/Tiempo (9):**
- **L92** Slider de hora (0-23) — no hay slider. → `[ ]`
- **L93** Label de hora actual — no hay label (el overlay del bench es de M61, no de M110). → `[ ]`
- **L94** Dropdown de estación — `debug_menu_ui.gd:67` `_on_estacion_solicitada(estacion)` existe como **señal/callback del backend** pero **no hay dropdown que la emita**. El ítem pide el widget. → `[ ]`
- **L95** Dropdown de clima — idem (`_on_clima_solicitado` L71 existe, el dropdown no). → `[ ]`
- **L96/L97** Input de seed + botón "Aplicar seed" — no existen. → `[ ]` ×2
- **L98/L99** Inputs chunk X/Z — no existen. → `[ ]` ×2
- **L100** Botón "Regenerar" — no existe. → `[ ]`

**Panel NPC/Puzzle (5):**
- **L107** Selector de NPC — no existe. → `[ ]`
- **L108** Botón "Resetear" NPC — no existe. → `[ ]`
- **L109** Label de estado IA actual — no hay label; `toggle_ai_states()` existe pero es el backend. → `[ ]`
- **L110/L111** Selector de puzzle + botón "Resetear" — no existen. → `[ ]` ×2

### (c) Quedan `[?]` (0)

Ninguno de los 27 amerita mantenerse como duda: o el artefacto existe y funciona (2), o está claro que no está hecho (25). Todos tienen dueño M110-UI declarado, así que el `[ ]` es rastreable.

## Resumen del bloque 1

| Clase | Cantidad | Líneas |
|---|---|---|
| (a) → `[x]` propuesto | **2** | L74, L155 |
| (b) → `[ ]` propuesto | **25** | L66, L72, L73, L76-L80, L81-L88, L92-L100 (excepto L74), L107-L111 |
| (c) sigue `[?]` | **0** | — |

**Nota honesta sobre L74 y L155:** el backend existe pero **el widget visible no** — si el criterio del módulo es "el control UI completo", correspondería también `[ ]`. Los marqué (a) porque el ítem dice "POI predefinidos (dropdown)" / "Botón Limpiar consola" y la funcionalidad pedida existe en el backend data-driven que el menú consume; el `debug_menu_ui.gd` es data-driven por tabs (`_configurar_tabs()`), así que un dropdown puede resolverse por config. **Si el director prefiere el criterio estricto "widget visible", que aplique `[ ]` en esos 2 también** — lo dejo a su criterio con la evidencia.

## Siguiente

Bloques restantes: **L107-L155** (visualizaciones/consola/diagnóstico, ~22 ítems), **L172-L200** (DebugDraw/API, ~15), **L226-L258** (input/config/persistencia, ~18), **L263-L292** (FPS overlay/registros/archivos, ~8). Los entrego en ciclos siguientes.

READ-ONLY absoluto: 0 ediciones a checklists. Sin commits.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 22:34:37
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 23-2026-10-09_22-09-17-atria-a-stepfun-step-5-preview-e12c-aceptado-delta-0-m110-triaje-90-dudas-bundle-grande.md
