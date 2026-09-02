# Log 529: M58 Accesibilidad — Iteración 1: config + WCAG verificados (contraste 15.42 AAA)

**Fecha:** 2026-09-02
**Hora:** 07:20
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 1 del módulo M58 (Accesibilidad, V1): configuración data-driven de accesibilidad + validador + **función de contraste WCAG** — con la medición real de la UI actual: 15.42 (blanco sobre paneles oscuros, AAA) y 4.94 (pasto/arena). El HUD del juego cumple contraste, y quedó la base para aplicar la config a la UI.

## Cambios Realizados

- `data/accesibilidad/config.json` — tamaño de texto (pequeño/medio/grande), contraste (alto/medio/bajo), modo daltonismo (ninguno/protanopia/deuteranopia/tritanopia), reducir efectos/parpadeo, alta visibilidad de interactivos, sonido visual, subtítulos (ON), sensor respeto, persistencia.
- `scripts/accesibilidad/accesibilidad_schema.gd` — validación de la config + `contraste_relativo()` (WCAG luminancia) y `_luminancia()`.
- `scripts/accesibilidad/test_accesibilidad_headless.gd` — 8/8 checks OK, exit 0.

## Verificación

- **Contraste WCAG medido:** blanco sobre fondo oscuro del HUD = **15.42** (AAA ≥ 7); pasto/arena del mundo = **4.94** (legible ≥ 3). La UI actual cumple accesibilidad de contraste (coherente con el análisis visual de legibilidad M88).
- Defaults correctos (medio/alto/ninguno/subtítulos ON/reducción OFF) y detección de config inválida.

## Pendientes con dueño

- Aplicar la config a la UI (tamaño/contraste en runtime con M53): iter 2 (dueño: deepseek-v4-flash-vision-exp).

## Archivos Modificados/Creados

- Creados: `data/accesibilidad/config.json`, `scripts/accesibilidad/accesibilidad_schema.gd`, `scripts/accesibilidad/test_accesibilidad_headless.gd`
- Modificados: `DOCUMENTACION/58-Accesibilidad/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 58 → 🟡 8/174), `Logs/ULTIMO_NUMERO.txt` (→529)
