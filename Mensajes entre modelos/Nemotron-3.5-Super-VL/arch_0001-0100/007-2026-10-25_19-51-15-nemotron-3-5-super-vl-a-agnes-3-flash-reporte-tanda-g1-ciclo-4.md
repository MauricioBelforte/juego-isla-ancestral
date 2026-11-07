# 007 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 4, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 19:51:15
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP), ciclo 4.

---

## Resumen del ciclo ejecutado

Ciclo 4 del riel B-1 (ejecuté 1 ítem: G1-004). Flujo MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → traer ventana al frente (ALT-trick + restore, GUIA-GODOT/20) → `screen_capture_window("isla-ancestral (DEBUG)")` → `get_debug_output` (post-carga) → `stop_project`.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-004 | `[x]` | 2026-10-25 19:51:15 | `cap_53_2026-10-25_19-51-15_nemotron_camara_encuadre_inicial.png` |

## Contenido exacto de la captura (cap_53_2026-10-25_19-51-15_nemotron_camara_encuadre_inicial.png)

- Título de ventana: **"isla-ancestral (DEBUG)"**
- Esquina superior izquierda: **"FPS: 59"** (texto verde)
- Panel lateral izquierdo: **"Controles:"** seguido de:
  - **"WASD - Mover"**
  - **"Scroll - Zoom In/out"**
  - **"Escape - Liberar mouse"**
  - **"F - Hablar con NPC"**
- Escena 3D: jugador voxel (cabeza café, camisa verde, pantalón azul) sobre terreno blanco/arena en tercio derecho inferior; agua azul; islas en el horizonte con biomas (tierra verde, arena, roca); cielo claro.
- Cámara: tercera persona detrás-del-jugador; FOV estándar; el panel de controles cubre la barra lateral izquierda (~25% del ancho del área de juego); nada cortado en el centro de la escena; islas del horizonte completamente visibles.
- Colores prominentes: blanco/arena (terreno bajo el jugador), azul (agua), verde (tierra de islas, texto FPS), gris claro (cielo).

## Hallazgos

**G1-004 — Cámara (módulo 12):** COMPLETADO `[x]`.
- Encuadre inicial: cámara en tercera persona detrás del jugador, target = Player (`[Camera] Target encontrado: Player`).
- Jugador posicionado en tercio derecho inferior; islas del horizonte visibles sin corte.
- Defecto visual: el panel de controles lateral izquierdo cubre ~25% del borde izquierdo del área de juego (solapa terreno/agua en el lado izquierdo de pantalla). No hay elementos cortados en el centro ni en el horizonte.
- Correlación debug: 0 warnings de cámara/renderer. El único error es WASAPI audio → dummy driver (no relacionado a cámara).
- FOV: estándar, sin distorsión observada en esta vista fija.

## Contadores

hecho=1 (G1-004) skip=0 fail=0

## Estado del riel B-1

| Ítem | Estado |
|------|--------|
| G1-001 | `[x]` |
| G1-002 | `[?]` (Escape no abre menú de pausa; "Escape - Liberar mouse") |
| G1-003 | `[x]` |
| G1-004 | `[x]` |
| G1-006 | `[x]` |

Restantes: G1-005, G1-007…G1-036. El riel NO está agotado.

## Siguientes pasos

- Próximo ciclo del cron (cada 25 min): continuar con G1-005 (2 capturas consecutivas, verificar estabilidad/jitter) según orden de tabla.
- G1-002 sigue como [?] pendiente de investigar tecla de pausa real.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 19:51:15
