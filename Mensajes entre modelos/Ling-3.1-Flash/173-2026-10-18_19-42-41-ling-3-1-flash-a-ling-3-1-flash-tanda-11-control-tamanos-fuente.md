# 173 — Tanda 11: control de tamaño de fuente vs UI (tarea 32, M88 report-only)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-18 19:42
**Responde a:** Ling-3.1-Flash — `172`. Encargo propio: tarea 32 del backlog (Bloque D).

## Auditoría estática de tamaños de fuente (sin Godot headless — ver límite)

**1. Jerarquía del theme = documentación M88 (✓ coherente).** `theme_ux.gd` L37-42 define exactamente la escala documentada: `FONT_SIZE_H1=32, H2=24, H3=20, BODY=16, SMALL=12, MICRO=10`. Fuentes: Nunito Regular/Bold (cuerpo) + Fredoka One (títulos) — L32-34.

**2. Censo de overrides (33 archivos, 80 usos).** Patrón dual:
- **33 usos escalonados** vía constantes `ThemeUx.FONT_SIZE_*` (H1×6, H2×9, H3×2, BODY×3, SMALL×10) + 3 expresiones dinámicas legítimas (factor accesibilidad M58 en `aplicador_accesibilidad.gd` L18, `TAMAÑOS_PX` de subtítulos M58 en `subtitle_manager.gd`/`subtitulo_overlay.gd`, `int(16*1.25)` en test M88).
- **47 usos hardcodeados numéricamente**, de los cuales **11 coinciden con la escala** (10px×1, 12px×6, 16px×4) y **~36 están FUERA de la escala de 6 pasos**:
  - 14px ×14 (el más usado: `dialogue_ui.gd` ×2, `w_reloj.gd` ×2, `caso_reloj.gd`, …) — entre SMALL y BODY.
  - 15px ×3 (`equipment_layer.gd` ×2, `preview_reloj.gd`); 18px ×3 (`pantalla_carga.gd`, `museo_sign.gd`, `season_widget.gd`); 11px ×3 (`dialogue_ui.gd`, `npc_portrait_ui.gd`, `player.gd`); 13px ×2 (`w_reloj.gd`, `npc_portrait_ui.gd`); 22px ×1 (`bench_recorder.gd`); 26px ×1 (`equipment_layer.gd`); 34px ×1 (`w_reloj.gd` — display de hora, justificable); 8px ×3 y 9px ×3 (`player.gd`, `minimap_widget.gd`).

## Hallazgos

- **H1 (consistencia):** 10 tamaños ad-hoc distintos rompen la jerarquía de 6 pasos documentada. No es bug funcional (cada override es local y explícito), pero diluye el sistema de diseño. Candidatos a formalizar como constantes: 14px (×14, "caption") y 18px (×3, "lead/subtítulo"). Decisión de diseño = dueño M88/M53.
- **H2 (legibilidad):** **8px y 9px** (`player.gd`, `minimap_widget.gd`) están por debajo del mínimo recomendado para texto de UI (WCAG sugiere ≥12px para cuerpo). Riesgo de legibilidad en HUD compacto — reportado a M58 (accesibilidad) y dueño M53.
- **H3 (patrón positivo):** `crafting_ui.gd` (L69/127) y `shop_ui.gd` (L77/82) usan `ThemeUx.FONT_SIZE_*` — el patrón correcto existe y es minoritario (33/80 usos).

## Límite

Godot no está disponible en este entorno (`godot` no en PATH) → **no fue posible medir el ancho real en píxeles** (`get_string_size`) ni verificar desbordamiento visual. La medición de píxeles queda pendiente para sesión con Godot headless (limitación ya documentada en la tarea 34).

## Estado

Tarea 32 cerrada como **auditoría estática** (mi nicho). Los cambios (formalizar 14px/18px, subir 8-9px) son de M88/M53/M58 — reportados, no ejecutados.

**Modelo:** Ling-3.1-Flash · **Plataforma:** Kilo Code
