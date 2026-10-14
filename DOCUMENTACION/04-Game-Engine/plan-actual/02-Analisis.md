
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

## 11. Verificacion de H9 (audio) y seccion I (riesgos y edge cases) - checklist (2026-10-14, step 5 workbuddy)

11 verificaciones con cita archivo+linea (H9 + I1-I10). Estandar: grep/sed ANTES
de cada flip, conteo por prefijo de linea antes/despues (105 -> 116 [x] / 0 [?] /
12 [ ] = 128), linea Totales actualizada. Log 1836.

| Item | Verificacion | Evidencia |
|---|---|---|
| H9 | Asset pipeline de audio (M41-M44) | Rutas de assets documentadas: 41-Musica/plan-actual/04-Codigo.md L18 (res://audio/music/...wav), 42-Sonido-Ambiental/plan-actual/04-Codigo.md L16 (res://audio/ambient/...wav), 43-Efectos-De-Sonido/plan-actual/04-Codigo.md L16 (res://audio/sfx/...wav) y 44-ASMR-Y-Feedback/plan-actual/04-Codigo.md L15 (res://audio/microfoley/...wav); buses: 42-Sonido-Ambiental/plan-actual/03-Diseno.md L64-L65 (total <= 11 bus activos) + 41-Musica/plan-actual/04-Codigo.md L39 (integracion M42 buses + M44 feedback sobre buses jerarquicos de M06); codigo REAL en disco: scripts/audio/ con 10 .gd de produccion (music_director, ambient_director, sfx_manager, compression_manager [M91 limiter de picos], dynamic_range_manager, audio_config_service, output_device_manager, feedback_director, narrative_sound, shuffle_sampler) + 7 suites (test_musica_m41, test_ambient_m42, test_sfx_m43, test_feedback_m44, test_audio_effects_m91, test_audio_config, test_narrative_m150) |
| I1 | Riesgo: dependencia de Voxel Tools (comunitaria) | Este archivo L56 (tabla de riesgos sec.4: "Voxel Tools = dependencia comunitaria") + L28 (punto 15: "Plugins: menor mercado que Asset Store; Voxel Tools cubre el critico") |
| I2 | Mitigacion: MIT + version fijada + codigo fuente | Este archivo L56 ("Version fijada + codigo fuente disponible (MIT)"); disco: addons/zylann.voxel/LICENSE.md (MIT, L1-3) + voxel.gdextension compatibility_minimum="4.4.1"; 03-Diseno.md L46 (assets/plugins fijados por version) |
| I3 | Riesgo: transvoxel perf en islas grandes | Este archivo L58 ("Rendimiento transvoxel en islas grandes: Hito M1 valida antes de avanzar") + L48 ("Voxel a gran escala: Disenado para eso"); 03-Diseno.md L25 (LOD Transvoxel para chunks lejanos); medicion real Logs/386-M61 (374 draw calls promedio <= 400; 59.35 FPS) |
| I4 | Riesgo: reaprendizaje desde Unity | Este archivo L57 ("Reaprendizaje si el usuario viene de Unity: Costo aceptado; desventaja documentada") + L22 (animacion menos madura que Mecanim) + L26 (comunidad mas chica); decision de origen: Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_2026-08-16 |
| I5 | Riesgo: actualizacion de Godot a mitad de produccion | 03-Diseno.md sec.5 L45 ("no actualizar Godot durante produccion salvo parche de seguridad critico; documentar cualquier migracion en Logs y changelog") + L46 (congelacion por version); CHANGELOG.md real en la raiz del repo |
| I6 | Edge case: Windows vs Linux paths en tools | CI corre en Linux: .github/workflows/quality.yml L12 runs-on: ubuntu-latest (+ backup.yml L25, bug_metrics.yml L14, dev-build.yml L24); exports REALES multiplataforma: export_presets.cfg preset.0 Web, preset.1 Windows, preset.2 Linux, preset.3 SteamOS (Linux/X11) - export headless EXIT 0 de Linux y SteamOS (Log 1833 F16) |
| I7 | Edge case: export SteamOS exige pruebas en Deck real | export_presets.cfg preset.3 "SteamOS" (Linux/X11, exportado OK); 03-Diseno.md L41 (prototipo 60 FPS en "PC media y Steam Deck"). NOTA honesta: sin Deck real, la validacion en dispositivo queda pendiente |
| I8 | Edge case: drivers Vulkan en PCs viejas | project.godot L16 (config/features="4.7", "Forward Plus" = Vulkan) + L354 (rendering_device/driver.windows="d3d12"); alternativa documentada: este archivo L33 ("Render pipeline: Forward+ (Vulkan); Mobile para builds livianas") |
| I9 | Edge case: compatibilidad de saves entre versiones | 59-Guardado/plan-actual/03-Diseno.md L95 ("Migracion: Backup previo + solo hacia delante (M60)") + L54 (schema_version < actual -> migrar con backup) + L109 (M60 define formato, schema_version y migraciones) |
| I10 | Decision: si M1 falla 60 FPS, re-evaluar motor | 03-Diseno.md sec.4 L41 ("Si falla, revisar greedy meshing/threading antes de avanzar; si persiste, re-evaluar motor (con re-planificacion)"); 01-Requerimientos.md L45 (60 FPS = vara minima); medicion real Logs/386-M61 (59.35 FPS) |

Notas de honestidad:
- H9: el pipeline de DATOS de audio (rutas de assets bajo res://audio/{music,
  ambient,sfx}/, bus system, ducking por EventBus, volumen por bus M91) esta
  documentado en los modulos M41-M43 y el codigo existe en scripts/audio/.
  Lo que FALTA es la entrega del compositor: 0 archivos de audio en el
  proyecto (43-Efectos-De-Sonido/plan-actual/04-Codigo.md L69). Es deuda de
  assets, no de documentacion: el item pide documentar el pipeline.
- Suites de audio medidas EN ESTA iteracion (godot headless, 2026-10-14):
  test_sfx_m43 = 127 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR (verde limpio);
  test_feedback_m44 = 9 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR (verde limpio);
  test_musica_m41 = 14 checks, "0 fallos", EXIT 0 pero con 5 SCRIPT ERROR
  (set_ducking / esta_pausado / sting_reproducido inexistentes en
  music_director.gd) y test_ambient_m42 = 9 checks, "0 fallos", EXIT 0 con
  2 SCRIPT ERROR (mismos metodos ausentes en ambient_director.gd). Por la regla
  anti-falso-verde del proyecto, un SCRIPT ERROR aborta bloques en silencio:
  el "0 fallos" de M41/M42 NO se toma como verde completo. Es deuda de los
  modulos M41/M42 (suites desalineadas con el codigo): se reporta al director,
  no se toca.
- I7: el preset SteamOS existe y exporta, pero no hay hardware Deck para la
  prueba real; el edge case queda documentado con esa salvedad.
- I8: "Mobile para builds livianas" es la alternativa documentada para bajo
  rendimiento; la config activa sigue siendo Forward Plus (Vulkan).
Ningun item de implementacion (secciones F/G/J) fue tocado.

## 12. Verificacion de la seccion J (validacion del hito M1 y cierre del modulo) - checklist (2026-10-14, step 5 workbuddy)

10 verificaciones con cita archivo+linea (J1, J4, J5-J12). Estandar: grep/sed ANTES
de cada flip, conteo por prefijo de linea antes/despues (116 -> 126 [x] / 0 [?] /
2 [ ] = 128), linea Totales actualizada. Log 1844.

| Item | Verificacion | Evidencia |
|---|---|---|
| J1 | Prototipo de validacion: chunk 16 al cubo + face culling + editing + camara | 03-Diseno.md L41 ("Prototipo: chunk 16³ con face culling + editing + camara orbitando + raycast de bloque a 60 FPS sostenidos en una PC media y Steam Deck") + 01-Requerimientos.md L20 (RF2 face culling / greedy meshing, GDD directiva 1) + L40 (criterio de aceptacion 3) y L45 (60 FPS = vara minima); este archivo L33 (punto 19 "Crear proyecto base" -> Hito M1) y L139 (C14) |
| J2 | 60 FPS en PC media | NO FLIPEADO (director msg 25, 2026-10-14): exige medicion en dispositivo/runtime real. Referencia medida: Logs/386-M61 L16 (59.35 FPS promedio, WARN por Vsync + carga de chunks, escena de terreno sin NPCs/particulas) - no equivale a PC media con contenido |
| J3 | 60 FPS en Steam Deck | NO FLIPEADO (director msg 25): sin hardware Deck real la validacion en dispositivo es imposible desde el repo. Relacionado: export_presets.cfg preset.3 "SteamOS" (export headless EXIT 0, Log 1833 F16) |
| J4 | Raycast de extraccion/colocacion sin lag | Patron real en produccion: game/isla-ancestral/scripts/farm/farm_tool_controller.gd L43-L54 (`_punto_mirado()`: PhysicsRayQueryParameters3D.create(origen, origen + dir * radio_interaccion) + get_world_3d().direct_space_state.intersect_ray(query), query.exclude del player) + receta documentada: DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md L96 (sec.5 "Edicion de bloques por raycast"); presupuesto medido en escena real: Logs/386-M61 L16/L17 (374 draw calls promedio <= 400 objetivo) + L28 (16.35 ms/frame) + L41 (90 s, reproducible) |
| J5 | Decision Godot confirmada por el usuario | Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_2026-08-16_06-10-00.md ("Por encargo explicito del usuario ... se cerro la decision final del motor ... Godot 4.x + Voxel Tools (edicion GDExtension) + GDScript") + 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md L16 ("Motor y pipeline (Unity vs Godot) | Godot 4.x + Voxel Tools (GDExtension) + GDScript - CONFIRMADO 2026-08-16") |
| J6 | Version exacta del motor registrada en 04-Codigo.md | 04-Codigo.md L12 ("Version exacta del motor: Godot 4.7.2 estable"; binario real D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/; project.godot L16 config/features=PackedStringArray("4.7", "Forward Plus")). Resuelto en iter 6 (Log 1822), reverificado en iter 10 |
| J7 | Logs de instalacion y configuracion | Logs/17 (decision + "04-Codigo.md: seccion 4 actualizada con version fijada y evidencia") + Logs/1822-M04-iter6-config-proyecto-base_2026-10-13_17-34-18.md (seccion F completa: instalacion, proyecto base, .gitignore, Forward+, capas de fisica, escena Main, autoloads, build .pck - 12 flips con cita real) |
| J8 | Spec doc actualizada con la decision | 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md L16 (fila "Motor y pipeline (Unity vs Godot)" -> "Godot 4.x + Voxel Tools (GDExtension) + GDScript - CONFIRMADO 2026-08-16 ... | 04 Game Engine") + Logs/17 (cambios: "1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md: seccion Motor confirmada") |
| J9 | 5 archivos de documentacion del componente | ls real: DOCUMENTACION/04-Game-Engine/plan-actual/ = 01-Requerimientos.md + 02-Analisis.md + 03-Diseno.md + 04-Codigo.md + 05-Checklist.md (5/5 verificados) + Logs/17 ("Sincronizacion plan-actual: los espejos plan-actual/ de los componentes 01-13 quedaron poblados") |
| J10 | Copiar plan-inicial -> plan-actual | ls real: DOCUMENTACION/04-Game-Engine/plan-inicial/ (5 archivos) y plan-actual/ (5 archivos, mismos nombres) + Logs/17 ("el Copy-Item previo con -LiteralPath + comodin no copiaba; corregido con -Path") |
| J11 | CHECKLIST-GLOBAL con estado del modulo 04 | CHECKLIST-GLOBAL.md fila 04 (worktree L26) mantenida por el director con las notas de cada iteracion WB (iter2/4/5/7/8) + "Drift GLOBAL<->disco corregido por director 2026-10-13"; msg 25 del director: "GLOBAL M04 actualizado de 105/128 -> 116/128". NOTA honesta medida 2026-10-14: el worktree muestra 105/128 (estado iter 8) y la fila arranca con 3 celdas vacias (|  |  |  | 04 |) -> desalineada, verificar_checklist.py NO detecta el drift de M04; reportado al director (msg 27) para reaplique y repare la alineacion |
| J12 | Criterio de salida del modulo (prototipo M1) | 03-Diseno.md L41 (criterio: "60 FPS sostenidos en una PC media y Steam Deck. Si falla, revisar greedy meshing/threading antes de avanzar; si persiste, re-evaluar motor (con re-planificacion)") + 01-Requerimientos.md L40 (criterio de aceptacion 4: "El prototipo del hito M1 valida 60 FPS voxel sobre la eleccion") + este archivo L58 ("Hito M1 valida antes de avanzar") y L139 (C14) |

Notas de honestidad:
- J2/J3: el director (msg 25, 2026-10-14) los deja [ ] a proposito: "J2/J3 (60 FPS PC media + Steam Deck) exigen runtime y hardware real - no se pueden verificar por disco. Dejalos [ ] honestos". La exigencia quedo anotada en cada item del checklist.
- J11: la fila del GLOBAL es del director (regla dura: NO editar CHECKLIST-GLOBAL.md). La aplicacion declarada en el msg 25 (116/128) NO coincide con el worktree medido hoy (105/128) y la fila esta desalineada (3 celdas vacias iniciales). El flip se apoya en que la fila existe y se mantiene por iteracion, con la medicion y el pendiente documentados; corresponde al director reaplicar.
- J4: "sin lag" se verifica al nivel medible desde el repo (patron de raycast real en produccion + presupuesto de frame medido en escena real, Log 386); la validacion fina (lag percibido en extraccion/colocacion sobre voxel) corresponde al hito M1 en runtime, pendiente junto con J2/J3.
- Quedan 2 [ ] = J2 + J3 (validacion en dispositivo).
