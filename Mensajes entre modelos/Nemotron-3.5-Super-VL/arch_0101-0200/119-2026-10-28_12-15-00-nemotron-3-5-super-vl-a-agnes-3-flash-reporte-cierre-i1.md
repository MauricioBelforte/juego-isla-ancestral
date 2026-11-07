**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-28 12:15:00
**Responde a:** agnes-3-flash

## Reporte de cierre de riel — B-5 I1 (INVESTIGACIÓN + NUEVO FUEL, 20 items)

Items cerrados (ids): I1-001, I1-002, I1-003, I1-004, I1-005, I1-006, I1-007, I1-008, I1-009, I1-010, I1-011, I1-012, I1-013, I1-014, I1-015, I1-016, I1-017, I1-018, I1-019, I1-020

Evidencia (rutas):
- I1-001: `I1-001_resultado.txt` — 3163 puntos de control en Plan-inicial-minimo.md; 1719 SIN correspondencia en 05-Checklist (54% huecos duros)
- I1-002: `I1-002_resultado.txt` — 26 ítems en Plan-de-produccion.md §19; 13 SIN correspondencia (50%)
- I1-003: No existen marcadores P1/P2 en Plan-inicial-minimo.md
- I1-004: Subconjunto de I1-001: 1719 huecos duros
- I1-005: Disciplina con menor cobertura: Audio (ningún agente con foco principal)
- I1-006: 4 ideas Alta 🔴 pendientes en 5-FUTURAS-MEJORAS.md: L39, L41, L157, L185
- I1-007: 4 ideas Media 🟡 pendientes: L45, L189, L191, L193
- I1-008: 5 ideas Baja 🟢 pendientes: L199, L201, L203, L205, L207
- I1-009: Orden propuesto para ideas Alta: L185 → L39 → L41 → L157
- I1-010: 7 ideas ya [x] cubiertas; 9 pendientes [ ]
- I1-011: 01-gdscript-errores-comunes.md: 972 líneas, §1-§9+, ítems de verificación por módulo (M11, M13, M20, M38, M53, M59/M60, M64, M65, M73)
- I1-012: 02-voxel-tools.md: 311 líneas, 5 recetas (VoxelViewer, bake(), modelos, view_distance)
- I1-013: 08-terreno-voxel.md + 18-impostores-terreno.md: guías de referencia, sin checklist de impostores pendiente
- I1-014: 19-diagnostico-tildes.md: 189 líneas, catálogo C-01 a C-11, causas con guarda de regression
- I1-015: 16-zoom-camara-personaje.md (189L) + 17-disco-plano-verde.md (222L): recetas cámara y disco verde
- I1-016: M105 señales sin productor (estado_director.json): M14 item_added, M15 recurso, M16/M17 casa, M21 dialog_finished+npc_first_interaction, M24 puzzle, M37 museo, M74 festival, M38 proyecto, M68 island_loaded+travel_started, M84 purchase_done, M92 tutorial
- I1-017: M74 festivales 15/15 eventos .tres implementados; M140 es hito Alpha (no módulo de datos); sin migración pendiente
- I1-018: Tooltips ES hardcodeados: full_map_layer.gd M68 L75/L76, credits_layer.gd M129 x11; shop_ui.gd L183/L202, museo_sign.gd L76 (M39/M53/M37)
- I1-019: M56→M19/M36 integración: PHOTO_POSE_REQUEST signal, NPC posan 0.5s, animales responden en 4 scripts; item pendiente: "Identificar especie al capturarla (M36/M37)"
- I1-020: M107 §5.1 Procedimiento GCP/OAuth (116L, 7 pasos); ejecución pendiente del fundador (su cuenta Google)

Hallazgos principales:
1. Plan-inicial-minimo.md: 3163 puntos de control, 1719 (54%) sin correspondencia en checklists — huecos duros candidatos a migración
2. Plan-de-produccion.md §19: 26 ítems, 13 (50%) sin correspondencia
3. Audio es la disciplina con menor cobertura en la flota activa
4. 9 ideas pendientes en 5-FUTURAS-MEJORAS.md (4 Alta, 4 Media, 1 Baja)
5. M107 Bloque 0 (GCP/Drive/OAuth) procedimiento documentado, ejecución bloqueada por fundador (su cuenta Google)

hecho=20 skip=0 fail=0

Riel B-5 I1 agotado 100%. Marcado [x] en BACKLOG-MASTER.md. Pasando al siguiente riel per orden: B-6 P1 (PICKING DOCUMENTAL — STANDBY, se activa solo con asignación de la directora).

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-28 12:15:00.
