**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 04: Game Engine

## 1. Decisión adoptada

> **Motor: Godot 4.x** — recomendación explícita del `Plan-de-produccion.md §2` (línea 111): *"Godot 4.x es la opción más defendible por defecto"* para este proyecto (voxel como pilar, equipo chico, sin presupuesto asegurado). Adoptada como decisión de documentación; el usuario puede revertirla antes del hito M1.

## 2. Análisis de los 30 puntos del plan maestro (§3)

| # | Punto | Resolución |
|---|---|---|
| 1 | Elegir Unity | ❌ Descartado por defecto: costo por asiento > USD 200k ingresos, ecosistema sí maduro pero voxel sin soporte nativo |
| 2 | Evaluar Godot | ✅ **Elegido**: gratis (MIT), sin regalías, native Linux/SteamOS |
| 3 | Evaluar Unreal | ❌ Descartado: overkill para cozy sim, voxel manual, tasa del 5% |
| 4 | Comparar costes | ✅ Plan-producción §2: Godot gratis siempre vs Unity hasta USD 200k/año |
| 5 | Soporte multiplataforma | ✅ Godot: export Windows/Linux/macOS + Deck nativo sin Proton |
| 6 | Soporte voxel | ✅ **Voxel Tools (godot_voxel, Zylann)**: C++/GDExtension, terreno editable, colisiones, streaming, LOD Transvoxel — caso de uso exacto del juego |
| 7 | Herramientas de terreno | ✅ Voxel Tools + editor propio de chunks |
| 8 | Iluminación | ⚠️ Godot 4: SDFGI/SSIL suficientes para estética pastel suave |
| 9 | Animación | ⚠️ Mejor en Unity (Mecanim) pero Godot 4 cubre rigging básico para cozy |
| 10 | Audio | ✅ AudioServer + bus system; suficiente |
| 11 | UI | ✅ UGUI de Godot (Control nodes) suficiente para HUD/inventario |
| 12 | Networking | ⚠️ No necesita en v1.0 (multijugador fuera de alcance) — Godot tiene high-level multiplayer |
| 13 | Comunidad | ✅ Activa y motivada; más chica que Unity |
| 14 | Documentación | ✅ Docs estables desde 4.x |
| 15 | Plugins | ⚠️ Menor mercado que Asset Store; Voxel Tools cubre el crítico |
| 16 | Elegir versión | ✅ Godot 4.x LTS estable (fijar exacta al crear proyecto) |
| 17 | Fijar versión | ✅ Congelada en `04-Codigo.md` |
| 18 | Evitar actualizar arbitrariamente | ✅ Regla de producción |
| 19 | Crear proyecto base | ⏳ Hito M1 (prototipo) |
| 20 | Render pipeline | ✅ Forward+ (Vulkan); Mobile para builds livianas |
| 21+ | Calidad/resolución/framerate | ✅ 60 FPS objetivo, resolución ajustable, VSync opcional |
| 24 | Input system | ✅ Input Map de Godot (teclado + mando) |
| 25 | Físicas | ✅ Jolt Physics (activa en project.godot L344); colisiones voxel vía Voxel Tools. Actualizado 2026-10-13 — el project.godot real usa Jolt (L344); el diseno original decia Godot Physics. Divergencia resuelta por director. |
| 26-27 | Capas/Tags | ✅ Layer system de Godot |
| 28 | Escenas iniciales | ⏳ Al crear proyecto base (M1) |
| 29 | Build profiles | ⏳ Export presets (Windows/Linux/Web) en M1 |

## 3. Comparativa resumida (fuente: Plan-de-produccion §2)

| Criterio | Unity | Godot 4.x |
|---|---|---|
| Costo | Gratis < USD 200k; Pro ~USD 2.300/año | **Gratis siempre** |
| Voxel nativo | No — terceros | **Voxel Tools (C++)** |
| IA/MCP | Oficial en beta + Unity MCP (12.7k★) | Comunitarios sólidos (GDAI MCP) |
| Voxel a gran escala | Depende del asset | **Diseñado para eso** |
| Deck | Vía Proton | **Nativo SteamOS** |

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Comunidad Godot más chica para arte/animation | Contratar solo lo puntual; tutorials oficiales |
| Voxel Tools = dependencia comunitaria | Versión fijada + código fuente disponible (MIT) |
| Reaprendizaje si el usuario viene de Unity | Costo aceptado; desventaja documentada |
| Rendimiento transvoxel en islas grandes | Hito M1 valida antes de avanzar |

## 5. Alternativas consideradas y descartadas

- **Unity + asset voxel de pago:** costo anual + dependencia comercial; solo si hubiera presupuesto de contratación.
- **Unreal + Custom Voxel:** demasiado motor para el género; curva y tasa eliminatorias.
- **Motor propio voxel**: descartado (reinventar el mundo; plan-producción no lo contempla).

## 6. Verificación de costos y licencias — sección B del checklist (2026-10-12, step 5 workbuddy)

Auditoría de los 10 ítems de la sección B (`05-Checklist.md`, líneas 35-44) contra evidencia
en disco. Cada flip del checklist cita esta sección.

| # | Ítem | Evidencia (archivo + línea) |
|---|---|---|
| B1 | Costo Godot: gratis siempre, MIT, sin regalías | Este archivo L15 ("gratis (MIT), sin regalías") y L45 ("Gratis siempre"). Fuente primaria: godotengine.org/license (MIT, "free to use... for any purpose", verificado 2026-10-12) |
| B2 | Costo Unity: gratis < USD 200k, Pro ~USD 2.300/asiento/año | Este archivo L45: "Gratis < USD 200k; Pro ~USD 2.300/año" (tabla comparativa §3) |
| B3 | Episodio Runtime Fee 2023 y su cancelación | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` L100: "El 'Runtime Fee' de 2023 generó una fuga masiva a Godot/Unreal; Unity lo canceló por completo en septiembre de 2024 y volvió al modelo por asiento" |
| B4 | Caso Unreal: 5% tras USD 1M de ingresos | Este archivo L16 ("tasa del 5%"). Umbral verificado 2026-10-12 en fuente oficial unrealengine.com/release: "5% royalty on worldwide gross revenue over the first $1 million USD" |
| B5 | Modelo autofinanciado compatible con Godot | `01-Requerimientos.md` L23 (RF5 "Costo cero o bajo — autofinanciado sin presupuesto asegurado") y L30 (RNF "Sin regalías ni fee por instalación que pongan en riesgo el modelo autofinanciado"), cruzado con este archivo L15 |
| B6 | Costos de assets/plugins a futuro (presupuesto separado) | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` §15 "Presupuesto y financiamiento" (L420) y L271 (middleware FMOD/Wwise: licencias gratuitas bajo umbrales, confirmar umbral vigente) |
| B7 | Voxel Tools es MIT y gratuito | `game/isla-ancestral/addons/zylann.voxel/LICENSE.md` L1-3 ("MIT License — Copyright (c) 2016-2024 Marc Gilleron"); refuerzo: este archivo L56 |
| B8 | Licencias de exportación sin fees (Vulkan/drivers) | Motor MIT (B1: godotengine.org/license) => exportar no arrastra fee. Drivers de video Vulkan/OpenGL: bibliotecas del sistema operativo, sin licencia con costo. Evidencia de exportación real en el repo: `build/` (`.pck` + `.wasm` distribuibles) |
| B9 | Costo cero como factor decisivo del análisis | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` L111: "el costo cero pase lo que pase con tus ingresos... son dos ventajas que pesan mucho para un equipo con recursos limitados" |
| B10 | Costo de herramientas de apoyo registrado en módulo de arte | `DOCUMENTACION/46-Arte-2D/plan-actual/02-Analisis.md` L43 ("Herramientas: Inkscape (gratuita), Krita (pintura), Blender solo como soporte 3D→2D") |

Nota de método: los ítems B4 y B8 combinan cita interna (este archivo / addon) con verificación
de fuente externa oficial fechada (2026-10-12). Sin fuente externa no se escribió el dato.


## 7. Verificacion de la evaluacion de candidatos - seccion A del checklist (2026-10-13, step 5 workbuddy)

Auditoria de los 12 items de la seccion A (`05-Checklist.md`, lineas 20-31) contra
evidencia en disco. Cada flip del checklist cita esta seccion. Todas las lineas citadas
fueron verificadas por grep/sed sobre el archivo en disco ANTES de escribir el flip
(guardrail del director, msg 5 del 2026-10-13: "grep obligatorio antes de cada flip").

| # | Item | Evidencia (archivo + linea, verificada en disco) |
|---|---|---|
| A1 | Evaluar Unity contra los requisitos | Este archivo L14 (punto 1 del plan maestro: "Descartado por defecto: costo por asiento > USD 200k ingresos, ecosistema si maduro pero voxel sin soporte nativo") + L45 (tabla comparativa: costo Unity) |
| A2 | Evaluar Godot contra los requisitos | Este archivo L15 (punto 2: "Elegido: gratis (MIT), sin regalias, native Linux/SteamOS") + L8 (decision adoptada, §1) |
| A3 | Evaluar Unreal Engine contra los requisitos | Este archivo L16 (punto 3: "Descartado: overkill para cozy sim, voxel manual, tasa del 5%") |
| A4 | Documentar por que Unity queda descartado (costo >200k, voxel sin nativo) | Este archivo L14 + L45 ("Gratis < USD 200k; Pro ~USD 2.300/ano") + L46 ("Voxel nativo | No - terceros") |
| A5 | Documentar por que Unreal queda descartado (overkill, tasa 5%, curva) | Este archivo L16 + L63 ("demasiado motor para el genero; curva y tasa eliminatorias") + L76 (§6 B4: tasa 5% tras USD 1M, umbral verificado en unrealengine.com/release el 2026-10-12) |
| A6 | Registrar la recomendacion del Plan-de-produccion §2 como fuente de la decision | Este archivo L8, que cita `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` L111 ("Godot 4.x es la opcion mas defendible por defecto"; linea reverificada por sed el 2026-10-13) |
| A7 | Adoptar Godot 4.x como motor del proyecto | Este archivo L8 + L15 + L29 (punto 16: "Godot 4.x LTS estable"). Proyecto real: `game/isla-ancestral/project.godot` L16 (`config/features=PackedStringArray("4.7", "Forward Plus")`). Cierre de la decision: `Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_2026-08-16_06-10-00.md` |
| A8 | Documentar la comparativa Unity vs Godot en tabla (costo/voxel/IA/deck) | Este archivo §3 L43-49 (tabla: Costo L45 / Voxel nativo L46 / IA-MCP L47 / Voxel a gran escala L48 / Deck L49) |
| A9 | Documentar que la decision es revisable SOLO antes del hito M1 | Este archivo L8 ("Adoptada como decision de documentacion; el usuario puede revertirla antes del hito M1") |
| A10 | Confirmar con el usuario la adopcion de Godot (veto pendiente) | `Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_2026-08-16_06-10-00.md`: "Por encargo explicito del usuario... se cerro la decision final del motor... se descarta el 'volantazo'"; el propio log registra "05-Checklist.md: item de confirmacion -> [x]". Refuerzo: `05-Checklist.md` L159 (seccion J, mismo respaldo) |
| A11 | Documentar el trade-off de animacion (Godot menos maduro que Mecanim) | Este archivo L22 (punto 9: "Mejor en Unity (Mecanim) pero Godot 4 cubre rigging basico para cozy") |
| A12 | Documentar el trade-off de bolsa de talento (comunidad Godot mas chica) | Este archivo L26 (punto 13: "Activa y motivada; mas chica que Unity") + L55 (§4, riesgo "Comunidad Godot mas chica para arte/animation" con su mitigacion) |

Nota de metodo: los 12 items son de evaluacion/documentacion cuya evidencia ya existia en
este archivo (secciones 1-5, autoria del modulo) y en `Logs/17`. La iteracion 2 no crea
contenido nuevo: verifica cada item contra su cita en disco y marca el checklist. Ningun
item de implementacion (secciones F/G/J) fue tocado.


## 8. Verificacion de soporte voxel y rendimiento - seccion C del checklist (2026-10-13, step 5 workbuddy)

Auditoria de los 14 items de la seccion C (`05-Checklist.md`, lineas 48-61) contra evidencia
en disco. Cada flip del checklist cita esta seccion. Todas las lineas citadas fueron
verificadas por grep/sed sobre el archivo en disco ANTES de escribir el flip (guardrail del
director, msgs 5 y 9 del 2026-10-13: "grep/sed por item antes del flip").

| # | Item | Evidencia (archivo + linea, verificada en disco) |
|---|---|---|
| C1 | Voxel Tools (Zylann) como modulo clave | Este archivo L19 (punto 6 del plan maestro: "Voxel Tools (godot_voxel, Zylann)... caso de uso exacto del juego") + L20 (punto 7: "Voxel Tools + editor propio de chunks"); `03-Diseno.md` L12 (stack: "Terreno voxel | Voxel Tools (Zylann) - GDExtension C++"); addon real en disco: `game/isla-ancestral/addons/zylann.voxel/` (LICENSE.md MIT de Marc Gilleron, `bin/` con libvoxel.*.dll/.so, `voxel.gdextension`) |
| C2 | Voxel Tools es C++/GDExtension orientado a rendimiento | Este archivo L19 ("C++/GDExtension") + L46 (tabla comparativa: "Voxel Tools (C++)"); `03-Diseno.md` L12 ("GDExtension C++"); binario compilado en disco `addons/zylann.voxel/bin/libvoxel.windows.editor.x86_64.dll` (+ .so/.dylib del resto de plataformas) |
| C3 | Soporte de terreno editable en tiempo real | Este archivo L19 ("terreno editable") + L20 ("editor propio de chunks"); `03-Diseno.md` L12; `DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md` seccion 5 L106 (edicion por raycast: `vt.do_ray(origin, direction, 50.0)`, `vt.do_point`, `vt.set_voxel`); runtime: `05-Checklist.md` L13 ("sistema VoxelTerrain + VoxelGeneratorNoise2D + colision operativos") |
| C4 | Colisiones voxel tipo Minecraft del modulo | `01-Requerimientos.md` L19 (RF1: "Terreno por bloques, extraccion/colocacion, colisiones voxel, rendimiento 60 FPS"); este archivo L19 ("colisiones") + L36 (punto 25: "colisiones voxel via Voxel Tools"); `03-Diseno.md` L12; runtime: `05-Checklist.md` L13 |
| C5 | Streaming de chunks infinito | Este archivo L19 ("streaming") + L48 ("Voxel a gran escala | Disenado para eso"); `01-Requerimientos.md` L22 (RF4: "LOD y streaming | Chunks lejanos con menos detalle; streaming entre islas"); `03-Diseno.md` L26 (streaming por isla con carga diegetica). Nota de honestidad: los docs del modulo documentan el streaming del addon (L19) y el streaming entre islas (L26); la palabra "infinito" no aparece afirmada explicitamente - se cita lo que existe |
| C6 | LOD Transvoxel para terreno suave | Este archivo L19 ("LOD Transvoxel"); `03-Diseno.md` L25 ("LOD Transvoxel para chunks lejanos; transicion suave al editar"); `01-Requerimientos.md` L22 (RF4) |
| C7 | Meshing multihilo (sin bloquear hilo principal) | `03-Diseno.md` L24 ("Remallado en hilos secundarios; nunca bloquear el hilo principal") + L12 ("meshing multihilo"); `01-Requerimientos.md` L21 (RF3: "Threading de generacion | Remallado de chunks sin bloquear el hilo principal") |
| C8 | Face culling como requisito innegociable (GDD directiva 1) | `01-Requerimientos.md` L20 (RF2: "Face culling / greedy meshing | Solo caras visibles (GDD directiva 1)"); `03-Diseno.md` L23 ("Face culling + greedy meshing obligatorios (GDD directiva 1)"); `DOCUMENTACION/02-Vision-Y-Concepto/plan-actual/03-Diseno.md` L86 ("voxel con face culling (solo caras visibles) desde el dia 1 (GDD seccion 5 directiva 1)") |
| C9 | Greedy meshing como optimizacion a evaluar | `01-Requerimientos.md` L20 (RF2, mismo requisito que C8); `03-Diseno.md` L23. Nota de honestidad: el diseno del modulo lo fija como OBLIGATORIO (GDD directiva 1), mas firme que el "a evaluar" del item; se cita el estado real documentado |
| C10 | Diffs de chunk para persistencia (no guardar mundo entero) | `03-Diseno.md` L27 ("Persistencia por diffs de chunk (no guardar el mundo entero)") - coincidencia textual con el item |
| C11 | Conteo de draw calls del terreno mesheado | Medicion real: `Logs/386-M61-Rendimiento-Mediciones-Reales_2026-09-01_19-05-00.md` L17 ("Draw calls promedio 374.0 | objetivo <= 400 (E.59) | Dentro") y L28 ("~374 draw calls y 16.35 ms/frame - margen para el contenido que entrara"); `DOCUMENTACION/08-Mundo-Voxel/plan-actual/03-Diseno.md` L115 ("Metricas: draw calls/chunk, ms de remesh, radio optimo"); `61-Rendimiento/plan-actual/01-Requerimientos.md` L52 (RF5: "Draw calls, overdraw, shader cost por render pas") |
| C12 | Presupuesto de particulas/vfx del motor | `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/03-Diseno.md` seccion 3.1 L73-95 (catalogo con "Particulas max" por efecto: 24 a 1.000) + L32 ("respeta el presupuesto por escena") + L41 ("emisores activos < 12"); `61-Rendimiento/plan-actual/02-Analisis.md` L46 ("GPUParticles + pool para las de larga vida... el pool da control de presupuesto"); `32-Clima/plan-actual/04-Codigo.md` L84 (particulas_clima "Con M61 (presupuesto 1 ms)") |
| C13 | Raycast voxel para herramientas (pala/pico/hacha) | `DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md` seccion 5 L96-116 ("Terrateniente - Edicion de bloques por raycast": obtener VoxelTool, `vt.do_ray`, colocar en hit_pos + hit_normal); `03-Diseno.md` L14 ("Colisiones voxel via raycast de Voxel Tools"); este archivo L20 (punto 7) |
| C14 | Validacion 60 FPS como criterio de aceptacion del motor | `03-Diseno.md` seccion 4 L41 (prototipo: "chunk 16 al cubo con face culling + editing + camara orbitando + raycast de bloque a 60 FPS sostenidos en una PC media y Steam Deck. Si falla, revisar greedy meshing/threading antes de avanzar; si persiste, re-evaluar motor"); `01-Requerimientos.md` L40 (criterio de aceptacion 4) + L45 ("El GDD exige voxel a 60 FPS: esa es la vara minima del motor"); este archivo L58 (riesgo transvoxel -> "Hito M1 valida antes de avanzar"); `Log 386` L16 (59.35 FPS promedio medidos en bench real, WARN por Vsync) |

Nota de metodo: los 14 items son de documentacion cuya evidencia ya existia en los docs del
modulo (secciones 1-5 y `01-Requerimientos`/`03-Diseno`), en el addon instalado en disco, en
`GUIA-GODOT/08` y en el bench real del Log 386. La iteracion 3 no crea contenido nuevo:
verifica cada item contra su cita en disco y marca el checklist. Ningun item de implementacion
(secciones F/G/J) fue tocado. Notas de honestidad explicitas en C5 ("infinito" no afirmado
textualmente) y C9 (el diseno es mas firme que el item: obligatorio, no "a evaluar").


## 9. Verificacion del ecosistema del motor - seccion D del checklist (2026-10-13, step 5 workbuddy)

Auditoria de los 10 items de la seccion D (`05-Checklist.md`, lineas 65-74) contra
evidencia en disco. Cada flip del checklist cita esta seccion. Todas las lineas
citadas fueron verificadas por grep/sed sobre el archivo en disco ANTES de escribir
el flip (guardrail del director, msgs 5/9/11 del 2026-10-13). Encargo: msg 11
(iter 4 = seccion D, elegida por el director sobre E).

| # | Item | Evidencia (archivo + linea, verificada en disco) |
|---|---|---|
| D1 | Estado de la comunidad Godot (activa, en crecimiento) | Este archivo L26 (punto 13 del plan maestro: "Comunidad | Activa y motivada; mas chica que Unity") + L55 (riesgo "Comunidad Godot mas chica para arte/animation" con mitigacion "tutorials oficiales"); `01-Requerimientos.md` L31 (RNF "Comunidad y documentacion suficientes para resolver problemas sin freelance") |
| D2 | Documentacion oficial estable de Godot 4.x | Este archivo L27 (punto 14: "Documentacion | Docs estables desde 4.x"); `01-Requerimientos.md` L31 (mismo RNF) |
| D3 | Mercado de plugins (Voxel Tools + dialogos + UI) | Este archivo L28 (punto 15: "Plugins | Menor mercado que Asset Store; Voxel Tools cubre el critico") + L24 (punto 11: UI con Control nodes, sin plugin). Dialogos tambien resueltos sin plugin: sistema propio en disco `game/isla-ancestral/scripts/dialogos/dialogue_graph.gd` |
| D4 | Opciones MCP de Godot para IA (GDAI MCP, godot-mcp) | Este archivo L47 (tabla comparativa §3: "IA/MCP | ... Comunitarios solidos (GDAI MCP)"); `01-Requerimientos.md` L26 (RF8: "Integracion con herramientas IA/MCP | El usuario desarrolla con agentes IA"); MCP REAL en el repo: `tools/mcp/godot-mcp/` (README.md, build/, capturas/) |
| D5 | Comparativa MCP vs Unity (MCP oficial beta + Unity MCP 12.7k estrellas) | Este archivo L47 ("Oficial en beta + Unity MCP (12.7k★)"). Verificacion externa 2026-10-13: CoplayDev/unity-mcp existe y esta listado en el MCP Registry oficial (github.com/mcp/coplaydev/unity-mcp) - consistente con "oficial"; el conteo de estrellas es dato volatil citado del doc del modulo, no reverificado |
| D6 | Editores de dialogo (sistema de nodos de Godot) | `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/02-Analisis.md` L92: "NO escribir dialogo en codigo. Usar editor visual (sistema de nodos de Godot / Yarn Spinner o Ink en Unity)"; sistema propio implementado en disco: `scripts/dialogos/dialogue_graph.gd` + `dialogue_manager.gd` + `dialog_graph_validator.gd` |
| D7 | Pipeline de audio cubre lo-fi + ASMR | Este archivo L23 (punto 10: "Audio | AudioServer + bus system; suficiente"); `03-Diseno.md` L17 ("AudioServer + buses | Musica lo-fi + SFX ASMR"); `01-Requerimientos.md` L25 (RF7); codigo real: `game/isla-ancestral/scripts/audio/` con 17 .gd (music_director.gd, sfx_manager.gd, ambient_director.gd, dynamic_range_manager.gd, narrative_sound.gd, audio_config_service.gd, compression_manager.gd...) |
| D8 | UI de Control nodes cubre HUD/inventario/hotbar | Este archivo L24 (punto 11: "UI | UGUI de Godot (Control nodes) suficiente para HUD/inventario"); `03-Diseno.md` L16 ("UI | Control nodes (le da a UGUI) | Canvas/HUD del juego"); acciones reales en `game/isla-ancestral/project.godot` L222 (seccion [input] inventario={) y L243 (hotbar_1={); autoloads L36 (`inventario_service.gd`) y L56 (`hotbar_state.gd`) |
| D9 | Networking no es requisito v1.0 | Este archivo L25 (punto 12: "Networking | No necesita en v1.0 (multijugador fuera de alcance) - Godot tiene high-level multiplayer") |
| D10 | Estado del editor de particulas (GPU particles) | El sistema de particulas del proyecto es GPU: `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/03-Diseno.md` §3.1 L73-95 (los 20 efectos del catalogo usan GPUParticles3D/GPUParticles2D); codigo real: `scripts/particles/vfx_factory.gd`, `vfx_pool.gd`, `vfx_director.gd`, `preview_particles.gd` (todos con GPUParticles) |

Nota de metodo: los 10 items son de documentacion/verificacion sobre el ecosistema.
La evidencia combina (a) docs del modulo (secciones 1-5, autoria del modulo) y de
modulos relacionados (M01 Fundamentos, M52 Particulas), (b) artefactos REALES en
disco (tools/mcp/godot-mcp, scripts/dialogos, scripts/audio, scripts/particles,
acciones de input en project.godot) y (c) una verificacion externa fechada
(2026-10-13, MCP Registry) solo para el item D5, donde el dato es volatil. Ningun
item de implementacion (secciones F/G/J) fue tocado.

## 10. Verificacion de version y gestion del motor - seccion E del checklist (2026-10-13, step 5 workbuddy)

10 verificaciones con cita archivo+linea. Estandar: grep/sed ANTES de cada flip,
conteo por prefijo de linea antes/despues (60 -> 70 [x] / 0 [?] / 58 [ ] = 128),
linea Totales actualizada. Log 1812.

| Item | Verificacion | Evidencia |
|---|---|---|
| E1 | Regla de fijar la version del motor | 03-Diseno.md sec.5 L44 ("Version exacta fijada al crear el proyecto y registrada en 04-Codigo.md"); disco real: project.godot L16 config/features=PackedStringArray("4.7", "Forward Plus") |
| E2 | Regla de NO actualizar arbitrariamente | 03-Diseno.md sec.5 L45 ("Regla: no actualizar Godot durante produccion...") |
| E3 | Campo Version exacta como pendiente del hito M1 | 03-Diseno.md sec.5 L44 exige registrarla en 04-Codigo.md; grep sobre 04-Codigo.md: NO registra la version exacta del motor -> campo PENDIENTE del hito M1; project.godot L16 fija "4.7" como referencia |
| E4 | Pinneado de Voxel Tools contra la version de Godot | 03-Diseno.md sec.5 L46 ("Voxel Tools pinned contra la version de Godot"); addon REAL en disco: addons/zylann.voxel/voxel.gdextension compatibility_minimum="4.4.1" |
| E5 | Procedimiento de migracion (log + changelog) | 03-Diseno.md sec.5 L45 ("documentar cualquier migracion en Logs y changelog"); CHANGELOG.md real en la raiz del repo ([0.0.6]) |
| E6 | Parche de seguridad critico como unica excepcion | 03-Diseno.md sec.5 L45 ("salvo parche de seguridad critico") |
| E7 | Congelacion de assets/plugins por version | 03-Diseno.md sec.5 L46 ("Los assets/plugins se fijan por version") |
| E8 | Renderer elegido: Forward+ (Vulkan) | project.godot L16 config/features=PackedStringArray("4.7", "Forward Plus") + 02-Analisis.md L33 ("Render pipeline | Forward+ (Vulkan)") |
| E9 | Renderer Mobile como alternativa para builds livianas | 02-Analisis.md L33 ("Render pipeline | Forward+ (Vulkan); Mobile para builds livianas") |
| E10 | Decision de fisica (Godot Physics, Jolt si hace falta) | 02-Analisis.md L36 ("Fisicas | Godot Physics; colisiones voxel via Voxel Tools"); DIVERGENCIA medida: project.godot L344 3d/physics_engine="Jolt Physics" (la config real ya usa Jolt) |

Notas de honestidad:
- E3: el item pide REGISTRAR el campo como pendiente, no rellenarlo. La version
  exacta del motor (4.7.2) no esta registrada en 04-Codigo.md (verificado por
  grep); solo "4.7" en project.godot L16. Queda pendiente del hito M1.
- E10: el documento de diseno dice "Godot Physics" pero el project.godot REAL
  tiene 3d/physics_engine="Jolt Physics" (L344). Es una divergencia diseno-
  implementacion que se reporta al director; el item se marca con la decision
  documentada mas la medida real.
- E9: "Mobile para builds livianas" es una alternativa documentada en el
  analisis; no es la config activa (Forward Plus si lo es).
Ningun item de implementacion (secciones F/G/J) fue tocado.
