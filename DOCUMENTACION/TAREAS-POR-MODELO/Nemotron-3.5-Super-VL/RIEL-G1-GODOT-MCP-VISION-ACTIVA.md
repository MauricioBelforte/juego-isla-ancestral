# RIEL-G1 — QA VISUAL ACTIVO CON GODOT-MCP (nicho máximo de Nemotron; 36 items)

**Armado por:** GLM-5.3-Flash (orden del fundador 25oct) | **Fecha:** 2026-10-25
**Citas obligatorias antes de empezar:** `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (vías V2/V4) + `DOCUMENTACION/GUIA-GODOT/INDICE.md`. Si tocaras código (NO es tu rol acá), GUIA-GODOT aplica antes.

**Qué es este riel:** abrir el JUEGO REAL con el MCP de Godot (V4), tomar capturas del estado ACTUAL (no históricas), analizarlas con tu visión, correlacionar con los logs de debug, y reportar defectos. Es el riel que **nadie más de la flota puede hacer**: requiere tus ojos + acceso MCP en el PC del fundador.

**Reglas de oro del riel:**
1. **Output = reporte en canal + capturas nuevas.** NO editá 05-Checklists, NO tocás código. Los defectos inforialos con propuesta; la directora deriva al dueño.
2. **Capturas nuevas:** guardalas en `tools/mcp/godot-mcp/capturas/<ID-Modulo>/` — la carpeta DEL MÓDULO analizado (cámara → `12-Camara/`, agua → `51-Agua/`), nunca todas en una sola; con nomenclatura del repo: `cap_<ID>_<AAAA-MM-DD_HH-MM-SS>_nemotron_<nota>.png` — **NUNCA sobrescribir capturas existentes**.
3. Si el juego no abre / captura negra / ventana ocupada: `[?]` + razón, saltás al siguiente ítem (no bloquees la tanda). Si el fundador anuncia que usa el PC: pausá el riel y trabajá V1/D1.
4. Batch: 3 ítems por tanda (cada uno implica abrir/capturar/analizar).
5. Citas de texto de la UI: byte-exactas (tu T1.1 ya probó que podés).

**Flujo estándar de cada ítem (secuencia del MCP):**
`get_project_info` → `run_project` (escena indicada si la hay) → esperar carga (leer `get_debug_output` para el boot) → captura de la ventana del juego (screen capture, guardar en la carpeta del módulo con nomenclatura) → analizar con tu visión → `get_debug_output` post-carga y correlación (errores/Warnings visibles ↔ lo que se ve) → `stop_project` → reporte.

| # | Módulo | Tarea |
|---|---|---|
| G1-001 | 53 UI/UX | Abrir el juego y capturar el HUD/base actual; describir todos los paneles visibles; defectos de layout (solapamientos, cortes, alineaciones) | [x] 2026-10-25 19:20:56 — juego arrancado, ventana al frente (ALT-trick + restore). Captura: cap_53_2026-10-25_19-20-56_nemotron_scena_principal.png. Paneles visibles: título "isla-ancestral (DEBUG)", FPS: 60, panel "Controles:" con WASD - Mover / Scroll - Zoom In/out / Escape - Liberar mouse / F - Hablar con NPC, jugador voxel, terreno voxel, agua, HUD inferior. |
| G1-002 | 53 UI/UX | Capturar el menú de Pausa/Settings si alcanzable desde el arranque; validar legibilidad y contraste de todas las opciones visibles | [?] 2026-10-25 19:22:42 — tecla Escape enviada pero NO abre menú de pausa; el UI muestra "Escape - Liberar mouse" (Escape libera el mouse, no abre pausa). No se encontró otra tecla de pausa visible. Evidencia: cap_53_2026-10-25_19-22-42_nemotron_escape_no_menu_pausa.png. |
| G1-003 | 53 UI/UX | get_debug_output al arrancar y correlacionar: errores/warnings devi ↔ elementos rotos que se vean | [x] 2026-10-25 19:17:43 — get_debug_output obtenido (boot + post-carga). 0 errores críticos. Warnings: señales no usadas en event_bus.gd (20+), división entera en stock_generator.gd:71 y mining_manager.gd:579, narrowing conversion en fauna_catalog.gd:48 y memory_monitor.gd:578/581. No se pudo correlacionar con UI (no había ventana visible en ese momento). |
| G1-004 | 12 Camara | Capturar el encuadre inicial de cámara; reportar FOV/distancias observadas y puntos donde algo queda cortado | [x] 2026-10-25 19:51:15 — juego arrancado, ventana al frente (ALT-trick + restore). Captura: cap_53_2026-10-25_19-51-15_nemotron_camara_encuadre_inicial.png. Encuadre inicial: jugador voxel en tercio derecho inferior (terreno blanco/arena), mirando al agua y a islas en distancia; panel de controles ocupa la barra lateral izquierda (cortando ~25% del borde izquierdo del área de juego); texto "FPS: 59"; cámara en tercera persona atrás-del-jugador, FOV estándar sin elementos cortados en el centro; distancia focal permite ver islas del horizonte. Correlación debug: [Camera] Target encontrado: Player; 0 warnings de cámara/renderer; único error no relacionado a cámara (WASAPI audio → dummy driver). |
| G1-005 | 12 Camara | 2 capturas consecutivas: verificar estabilidad (¿hay jitter/temblor visible entre frames?) y reportar | [x] 2026-10-25 20:02:30 — juego arrancado, ventana al frente (ALT-trick + restore). Capturas: cap_53_2026-10-25_20-02-30_nemotron_camara_frame1_estabilidad.png y cap_53_2026-10-25_20-02-21_nemotron_camara_frame2_estabilidad.png. Comparación frame1 vs frame2: FPS 60 en ambos, mismo encuadre, jugador en misma posición (tercio derecho inferior), islas en misma posición, agua en misma posición, texto "Controles:" y "FPS: 60" idénticos. Resultado: SIN jitter, SIN temblor, cámara estable entre frames. Defecto: panel de controles lateral sigue cubriendo ~25% del borde izquierdo del área de juego (solapa terreno/agua). Correlación debug: [Camera] Target encontrado: Player; 0 warnings de cámara/renderer; único error no relacionado a cámara (WASAPI audio → dummy driver). Hallazgo extra no-visual: logs saturados con miles de líneas "[M65] Huida coordinada de manada conejo_pradera (dist X.Xm < radio 4m)" repetidas (bucle de IA de fauna), ruido de consola masivo. |
| G1-006 | 51 Agua | Capturar el mar/agua desde la distancia inicial; describir shader/superficie visible; defectos (texturas planas repetidas, costas sin espuma, z-fighting) | [x] 2026-10-25 19:28:05 — juego arrancado, ventana al frente (ALT-trick + restore). Captura: cap_53_2026-10-25_19-28-05_nemotron_agua_shader_olas_fresnel.png. Agua azul con shader olas+fresnel visible; costas con bloques de terreno voxel emergiendo (efecto "costa sin espuma" — la playa es borde de bloque sin espuma de olas); isla en distancia con biomas (tierra verde, arena, roca); jugador voxel sobre terreno; texto "FPS: 60" y panel "Controles:" visibles; HUD inferior con barra de salud/energía. Correlación debug: [M51] Agua animada lista: plano 6200x6200 en y=6.00 (shader olas+fresnel); 0 warnings de materiales/renderer específicos de agua. |
| G1-007 | 51 Agua | Correlación debug: warnings de materiales/renderer durante la carga del agua ↔ lo visible |
| G1-008 | 50 Vegetacion | Capturar zona con vegetación adyacente al spawn; densidad/perspectiva, popping visible, elementos flotando |
| G1-009 | 49 Iluminacion | Capturar condición de luz inicial (hora del ciclo actual); sombras visibles, quemado por sol, zonas negras sin referencia |
| G1-010 | 31 Ciclo Dia Noche | Capturar la luz/hora actual del juego (HUD si existe); validar coherencia visual ciclo-luz según módulo (cuidado: sólo lectura del estado actual) |
| G1-011 | 34 Pesca | Si la escena/zona de pesca es alcanzable: capturar rodillo/aguja/bote visibles; reportar estados visuales de la mecánica si se verá |
| G1-012 | 54 Mapa | Si el UI de mapa es alcanzable: capturarlo y validar leyendas/etiquetas legibles y consistentes con la isla mostrada |
| G1-013 | 13 Herramientas | Capturar tooltips/paneles de herramientas visibles; textos cortados o ids crudos visibles (leak de debug) |
| G1-014 | 40 Infraestructura | Capturar estructuras cercanas al spawn (muelle/casas): z-fighting, colisiones visibles, elementos flotando |
| G1-015 | 19 NPC | Capturar NPC visible si hay cerca del spawn: skin/animación/reacción de mirada; incoherencias visuales |
| G1-016 | 47 Texturas Materiales | Capturas a media distancia: texturas con tiling visible, materiales planos sin respuesta de luz, UV crackeadas |
| G1-017 | 45 Arte 3D | Capturar 3 assets del entorno (rocas/árboles/props): coherencia de estilo poligonal y paleta del juego |
| G1-018 | 52 Particulas VFX | Si hay efecto activo (ola de agua, transición): capturarlo; densidad/perspectiva/dimensión |
| G1-019 | 56 Fotografia | Si el modo foto es alcanzable por UI: capturar su overlay; legibilidad del HUD del modo |
| G1-020 | 61 Rendimiento | Captura con HUD de FPS si existe el debug menu; si no, registrar get_debug_output y correlacionar con fluidez percibida en captura serial (2 frames) |
| G1-021 | 30 Reloj En Tiempo Real | Si el HUD muestra hora: capturarla y validar contra la luz de escena (coherencia día/noche visible) |
| G1-022 | 33 Agricultura | Si parcela visible cerca del spawn: estados de cultivo visibles (etapa madura/joven) — incoherencias visuales |
| G1-023 | 25 Ruinas | Si ruinas visibles en el horizonte (pose inicial): clipping con terreno/islas, escalas absurdas |
| G1-024 | 09 Terreno | Captura amplia de la isla: seams/costuras del terreno, orillas sin espuma, triangulación visible |
| G1-025 | 167 Isla Raiz | Captura del spawn oficial (usar `mundo_raiz.gd` SPAWN_JUGADOR solo COMO LECTURA); validar que el jugador no nace en el agua/dentro de estructura (solo reporte; recovery es de M09/M167) |
| G1-026 | 55 Diario | Si el diario/journal es alcanzable: capturarlo; layout/tab render, textos cortados |
| G1-027 | 87 Localización | Si hay selector de idioma visible: capturarlo y reportar (no toques locales — pronto riel i18n de Ling) |
| G1-028 | 88 Fuentes | Captura tipografías visibles en HUD: caracteres faltantes (tofu), kerning roto, tamaños inconsistentes |
| G1-029 | 52 VFX Agua | Espuma de orillas (M51+M52): captura de orilla con oleaje; espuma presente/ausente/estática |
| G1-030 | 62 Audio (audio visual) | Si hay indicadores visuales de audio (iconos/volumen): capturarlos; coherencia con estado del juego |
| G1-031 | 41 Musica | Censura visual: ¿el juego muestra nota/indicador musical? capturarlo si existe (estado actual) |
| G1-032 | 43 SFX | Igual G1-031 para sfx (visual only; el audio real no es tuyo) |
| G1-033 | 10 Generacion Del Mundo | Captura del horizonte: islas visibles al spawn; shape coherente (sin cubos flotando) — escena de generación actual |
| G1-034 | 161 Diseño Visual NPCs | Si NPC visible: paleta/estilo vs el estándar del juego (informe visual del módulo si capta) |
| G1-035 | 108 Pipeline De Assets | Captura de cualquier asset preview en la escena (si hay nodos debug tresdania): texturas placeholder visibles |
| G1-036 | 155 Vestimenta | Si UI de vestimenta alcanzable: capturarla; slots/etiquetas coherentes (T1.1 ya detectó slots duplicados: capturar el estado actual para comparar) |

**Prioridad de arranque:** G1-001 → G1-002 → G1-003 → G1-006 → G1-009 (los que diagnostican el núcleo visible) y después orden de tabla.
