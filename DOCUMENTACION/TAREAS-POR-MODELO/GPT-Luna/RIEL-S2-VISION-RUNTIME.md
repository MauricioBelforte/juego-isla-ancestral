# RIEL-S2 — VISIÓN RUNTIME DEL JUEGO (capturas + descripción verbatim + defectos; 8 items)

**Creado por:** GLM-5.3-Flash (31oct) para GPT-5.6 Luna | **Nicho:** tu visión certificada (MMMU-Pro 78.4, LMArena Vision 1257)

**POR CAPTURA:** corre `run_project` → screen capture → describe ELEMENTOS VISIBLES verbatim (textos de UI literales, contadores, botones) + defectos si los hay + guarda la captura en la carpeta del módulo (`tools/mcp/godot-mcp/capturas/<ID-Modulo>/cap_<ID>_<fecha>_gpt-luna_<nota>.png`, nunca sobrescribir). Salida CORTA (anti-truncamiento). Si la ventana está ocupada o el juego no abre: `[?]` + motivo y seguís.

| # | Módulo/Objetivo | Tarea | Estado |
|---|---|---|---|
| S2-001 | Escena principal (spawn) | Captura 1: describe verbatim (HUD, FPS, panel de controles, jugador voxel, agua, isla en horizonte — como el patrón de la flota) | [x] |
| S2-002 | Escena principal + 60 frames | Captura tras 60 frames: qué cambió (animación de agua, movimiento, FPS estables), defectos de movimiento visible | [x] |
| S2-003 | Menú/pausa si alcanzable | Probar teclas estándar (Esc/P/M en orden, UNA por captura): qué abre cada una — si ninguna abre menú, declararlo (patrón del caso G1-002: "Escape - Liberar mouse") | [x] |
| S2-004 | Inventario (tecla I si funciona) | Captura del inventario: slots, textos, ítems visibles verbatim | [ ] SKIP — I y B no respondieron; no apareció inventario |
| S2-005 | Mundo — agua | Captura del mar/agua de cerca: shader/superficie, espuma en orillas, defectos | [x] |
| S2-006 | Mundo — vegetación | Captura de vegetación cercana: densidad, popping, elementos flotando | [ ] SKIP — no se identificó vegetación cercana inequívoca |
| S2-007 | Mundo — iluminación | Captura con la condición de luz actual: sombras, zonas quemadas/oscuras | [x] |
| S2-008 | Mundo — NPCs | Captura de un NPC cercano (si visible): skin, pose, animación; incoherencias | [ ] SKIP — no se identificó un NPC separado del avatar |

## Evidencia runtime — 2026-10-31

Ventana usada: `isla-ancestral (DEBUG)`, runtime ya abierto. En las capturas completas, la barra de título muestra literalmente `isla-ancestral (DEBUG)`; la primera captura de spawn no la conserva completa. Para las pruebas de teclas confirmé el foreground con `AppActivate` y comprobé el PID de la ventana activa. Para acercarme al borde usé W físico (scancode `0x11`) durante 400 ms con el juego al frente. No reinicié ni cerré la instancia.

### S2-001 — Spawn

Captura: `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-10-31_gpt-luna_spawn.png`.

- La primera toma tiene recortados ambos bordes de contenido y un rectángulo negro en la franja superior izquierda. Fragmentos literales visibles: `59`, `roles:`, `0 - Mover`, `Zoom in/out`, `Pausa / Liberar mouse`, `blar con NPC`; en la tarjeta derecha se distinguen `1` y `Lunes, 1 c…` (cortados). No completo los textos truncados.
- Se ve una figura humanoide voxel de frente, orilla clara, mar azul/cian, tiras bajas verdes en el horizonte, tres barras de colores abajo a la izquierda y formas angulares naranja/amarillas/marrones a la derecha (sin asignarles identidad).
- Defecto de esta toma: el encuadre impide leer el HUD completo; no atribuyo el recorte al juego.

### S2-002 — Más de 60 frames

Captura: `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-10-31_gpt-luna_mas-60-frames.png`.

- Texto literal: `FPS: 60`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.
- Frente a la captura de spawn no se aprecia desplazamiento del avatar ni cambio de silueta de costa/islas; FPS mostrado: `60`. En una pareja de imágenes fijas no se puede confirmar animación del agua ni descartar popping entre frames.
- Se distinguen superficies de agua lisas por bandas de cian y bordes escalonados; no se ve espuma.

### S2-003 — Esc, P y M

Capturas de cada tecla:

- Esc: `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-31_gpt-luna_tecla-esc-foreground.png`. Abre un panel titulado `Pausa` con `Continuar`, `Ajustes`, `Guardar`, `Borrar slot 1` y `Volver al menú principal`. `Guardar` aparece atenuado. Detrás del panel aún se leen, atenuados, `FPS: 59`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse` y `E - Hablar con NPC`. El borde de foco de `Continuar` es visible. La acción `pausa` está ligada a Escape en `game/isla-ancestral/project.godot:283-285`.
- P, con el juego activo: `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-31_gpt-luna_tecla-p-juego-activo.png`. No aparece un menú. En esa captura solo quedan legibles `Escape - Pausa / Liberar mouse` y `E - Hablar con NPC`; el bloque de FPS/controles y las barras no se ven. El InputMap asigna P a `tomar_foto` (`game/isla-ancestral/project.godot:328-330`) y el manejador llama a `tomar_foto()` (`game/isla-ancestral/scripts/foto/photo_service.gd:240-243`), pero no se observó un aviso ni se confirmó visualmente un archivo de foto: el resultado consignado es únicamente lo visible en la captura.
- M, con el juego activo: `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-31_gpt-luna_tecla-m-juego-activo.png`. No abre menú ni aparece una superposición nueva. Texto literal visible: `FPS: 60`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.
- Las capturas `cap_53_2026-10-31_gpt-luna_tecla-p.png` y `cap_53_2026-10-31_gpt-luna_tecla-m.png` registran intentos con la pausa abierta; no se usan para inferir el efecto de P/M. La conclusión anterior se apoya únicamente en las capturas con el juego activo.

Defecto visible del panel de pausa: el texto de controles del mundo trasluce por la superficie del panel y queda debajo de varios botones.

### S2-004 — Inventario

**SKIP — [ ]**. Se probó I con el juego en foreground y no apareció panel. Se verificó que el InputMap asigna `inventario` a B (`game/isla-ancestral/project.godot:222-224`); B también se probó con el juego al frente y tampoco abrió inventario. No hay slots ni ítems visibles para transcribir.

Capturas negativas: `tools/mcp/godot-mcp/capturas/14-Inventario/cap_14_2026-10-31_gpt-luna_tecla-i-sin-respuesta.png` y `tools/mcp/godot-mcp/capturas/14-Inventario/cap_14_2026-10-31_gpt-luna_inventario-sin-respuesta-b-foreground.png`. La segunda conserva el HUD normal: `FPS: 60`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`; no hay menú de inventario.

### S2-005 — Agua

Capturas: `tools/mcp/godot-mcp/capturas/51-Agua/cap_51_2026-10-31_gpt-luna_agua-costa-cercana.png` y `tools/mcp/godot-mcp/capturas/51-Agua/cap_51_2026-10-31_gpt-luna_agua-costa-w-confirmado.png`.

- En la toma cercana el avatar queda junto a una orilla escalonada. La superficie ocupa gran parte del encuadre; pasa de cian claro a verde oliva oscuro entre tomas. No se distingue espuma ni textura de onda en las imágenes fijas.
- Texto legible en la toma cercana: `FPS: 60`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.
- No concluyo que el shader sea estático: las capturas no permiten valorar el movimiento temporal.

### S2-006 — Vegetación

**SKIP — [ ]**. Se acercó la vista con W físico y foco confirmado. Las capturas `tools/mcp/godot-mcp/capturas/50-Vegetacion/cap_50_2026-10-31_gpt-luna_vegetacion-tras-acercamiento.png` y `tools/mcp/godot-mcp/capturas/50-Vegetacion/cap_50_2026-10-31_gpt-luna_vegetacion-tras-w-confirmado.png` muestran bandas verdes escalonadas en islas al otro lado del agua y un óvalo verde pequeño sobre la plataforma; la imagen no permite identificarlo como planta ni decidir si está flotando. No hay vegetación cercana inequívoca para medir densidad o popping. En la segunda captura se leen `FPS: 59`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.

### S2-007 — Iluminación

Capturas: `tools/mcp/godot-mcp/capturas/49-Iluminacion/cap_49_2026-10-31_gpt-luna_luz-runtime.png` y `tools/mcp/godot-mcp/capturas/49-Iluminacion/cap_49_2026-10-31_gpt-luna_luz-runtime-cambio-observado.png`.

- Entre tomas el cielo y el terreno pasan de tonos muy claros a gris rosado/ocre, y el agua de cian a verde oliva oscuro; la causa no se determina aquí. La sombra visible del avatar es corta y tenue. No se aprecia una zona negra total; el cielo es uniforme y con poco detalle.
- Texto literal visible: `FPS: 60`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.

### S2-008 — NPCs

**SKIP — [ ]**. Capturas tras el acercamiento: `tools/mcp/godot-mcp/capturas/19-NPC-Y-Vecinos/cap_19_2026-10-31_gpt-luna_sin-npc-visible.png` y `tools/mcp/godot-mcp/capturas/19-NPC-Y-Vecinos/cap_19_2026-10-31_gpt-luna_sin-npc-visible-acercamiento.png`. Solo se ve una figura voxel de espaldas (avatar); no identifico un NPC separado ni una animación de NPC. El texto `E - Hablar con NPC` sí está en pantalla, pero no basta para afirmar que haya uno visible. La última toma muestra `FPS: 59`, `Controles:`, `WASD - Mover`, `Scroll - Zoom in/out`, `Escape - Pausa / Liberar mouse`, `E - Hablar con NPC`.

### Micro-revisión de la captura de pausa

Puntuación Atlas v2 (solo receptores aplicables a esa captura; no es una calificación global): `HIER-FOVEAL-CLEAR 2/2` (el centro del mundo queda abierto), `CTRST-PLATE-OPACITY 1/2` (panel legible, pero trasluce texto de fondo), `CTRST-FOCUS-30 2/2` (borde de foco de Continuar claro), `AFF-DISABLED 1/2` (Guardar solo se distingue por atenuación) y `TYPE-GLYPH-INTEGRITY 2/2` (texto español legible).

**Defectos observables principales:** (1) el inventario no responde a I ni a la acción B configurada; (2) los controles subyacentes se filtran visualmente a través del panel de pausa; (3) no se aprecia espuma ni detalle de onda en las capturas estáticas de agua.

**Cierre S-2:** parcial; S2-001, S2-002, S2-003, S2-005 y S2-007 tienen evidencia. S2-004, S2-006 y S2-008 quedan sin marcar por los SKIP documentados; por ello no se marca el riel completo ni se modifica el sub-backlog.

## AL TERMINAR

- Cada captura en su carpeta con su nombre; UN reporte de cierre en tu canal con: ruta de cada captura + 2-3 defectos top + ítems `[?]` si los hubo.
- Marcar este riel `[x]` acá y en el BACKLOG-MASTER.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-31 23:47.

**Actualización de estados:** GPT-5.6 Luna — Copilot SDK en VS Code — 2026-10-31 20:57 (UTC−03:00).
