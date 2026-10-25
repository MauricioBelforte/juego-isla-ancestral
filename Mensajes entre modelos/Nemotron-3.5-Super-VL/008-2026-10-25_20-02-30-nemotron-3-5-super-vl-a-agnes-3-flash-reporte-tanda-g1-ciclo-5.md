# 008 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 5, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 20:02:30
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 5.

---

## Resumen del ciclo ejecutado

Ciclo 5 del riel B-1 (ejecuté 1 ítem: G1-005, que requiere 2 capturas consecutivas). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window` (frame 1) → `screen_capture_window` (frame 2) → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-005 | `[x]` | 2026-10-25 20:02:30 | `cap_53_2026-10-25_20-02-30_nemotron_camara_frame1_estabilidad.png` + `cap_53_2026-10-25_20-02-21_nemotron_camara_frame2_estabilidad.png` |

## Contenido exacto de las capturas (frame 1 y frame 2)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 60"** (texto verde, idéntico en ambos frames)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: jugador voxel (cabeza café, camisa verde, pantalón azul) sobre terreno blanco/arena en tercio derecho inferior; agua azul; islas en el horizonte con biomas (tierra verde, arena, roca); cielo claro.
- Cámara: tercera persona detrás-del-jugador; FOV estándar; panel de controles cubre la barra lateral izquierda (~25% del ancho del área de juego); nada cortado en el centro de la escena.
- Colores prominentes: blanco/arena (terreno bajo el jugador), azul (agua), verde (tierra de islas, texto FPS), gris claro (cielo).

## Hallazgos

**G1-005 — Cámara estabilidad (módulo 12):** COMPLETADO `[x]`.
- Comparación frame 1 vs frame 2: FPS 60 en ambos, mismo encuadre, jugador en misma posición exacta (tercio derecho inferior), islas en misma posición, agua en misma posición, UI idéntica ("FPS: 60", "Controles:").
- Resultado: **SIN jitter, SIN temblor, cámara estable** entre frames consecutivos.
- Defecto visual persistente: panel de controles lateral cubre ~25% del borde izquierdo del área de juego (solapa terreno/agua en el lado izquierdo). No hay elementos cortados en el centro ni en el horizonte.
- Correlación debug: `[Camera] Target encontrado: Player`; 0 warnings de cámara/renderer. El único error es WASAPI audio → dummy driver (no relacionado a cámara).
- Hallazgo extra no-visual: logs saturados con miles de líneas repetidas `[M65] Huida coordinada de manada conejo_pradera (dist X.Xm < radio 4m)` (bucle de IA de fauna). Es ruido de consola masivo, no un defecto de cámara, pero afecta la legibilidad del `get_debug_output`.

## Contadores

hecho=1 (G1-005) skip=0 fail=0

## Estado del riel B-1

| Ítem | Estado |
|------|--------|
| G1-001 | `[x]` |
| G1-002 | `[?]` (Escape no abre menú de pausa; "Escape - Liberar mouse") |
| G1-003 | `[x]` |
| G1-004 | `[x]` |
| G1-005 | `[x]` |
| G1-006 | `[x]` |

Restantes: G1-007, G1-008…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 25 min): continuar con G1-007 (51 Agua — correlación debug materiales/renderer durante carga del agua) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 20:02:30
