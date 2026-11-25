LOG 2442 - b62: verificacion de implementables M01/M20 (Nemotron DOC-INT-4)
Fecha: 2026-11-25 08:46:04 (GMT-3). Agente: HY4 Flash.
Autoridad: mensaje 150 (agnes-3-flash), tanda b62. Regla del backlog: flip [ ]->[x]
solo si el artefacto concreto existe en disco (grep >= 1 hit). Sin evidencia = [ ] + pendiente.

== PREMISAS MEDIDAS ANTES DE EDITAR ==
- msg 150 dice "10 tareas" y "3564[x] + 10 = 3574". El backlog 62 tiene 15
  casillas numeradas (T62-01..T62-15): 10 en A + 5 en B.
- Recuento canonico ^\s*- \[x\] sobre los 63 archivos de
  DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS: 3539 [x] / 15 [ ] / 0 [?].
  El 3564 del msg 150 no es reproducible con esa expresion: delta 25.
- DOC-INT-4 localizado en el canal de Nemotron, mensaje 320. Su categoria (c)
  "implementable ahora" significa trabajo PENDIENTE que puede hacerse, no trabajo
  ya implementado. Por eso cada caso se verifico contra disco, no contra la lista.

== METODO ==
Solo fuentes reales bajo game/isla-ancestral (scripts/, data/, scenes/); excluidos
.godot/, imported/, exported/. Se buscaron los archivos y tokens concretos de cada
item, no coincidencias genericas. No se tocaron checklists de modulo, ni codigo,
ni archivos protegidos. Sin commit/push.

== A. M01 (10/10 verificadas) ==
T62-01 M12 Herramientas: scripts/herramientas158/tool_tier_system.gd,
  jar_manager.gd, scripts/tools/tool_controller.gd. 13 archivos / 106 hits.
T62-02 M16 Construccion: scripts/construccion/build_manager.gd,
  construccion_mundo.gd, build_hud.gd, build_ghost.gd (21 .gd en la carpeta).
T62-03 M36 Museos: scripts/museum/museum.gd, collection_registry.gd,
  donation_service.gd + scenes/museo/museum.tscn (3 archivos / 6 hits).
T62-04 M39 Infraestructura: scripts/core/test_infraestructura_m40.gd (7 bloques,
  piso CHECKS_MINIMOS=60) y autoloads GameFlowManager/SceneManager; 109 archivos
  / 373 hits de muelle/puente/faro/plaza/farola en fuentes reales. Nota: indice
  M01 va desplazado +1, por eso el script se llama m40.
T62-05 M44 Arte-3D: scripts/arte3d/materiales_recursos.gd y
  scripts/validadores/validador_autoloads.gd (4 archivos / 85 hits). Deuda aparte:
  validate_mesh.gd y asset_catalog.json = 0 hits en todo el repo (b61).
T62-06 M50 Agua: scripts/world/agua_animada.gd, validate_water.gd,
  block_catalog.gd (WATER=17), scripts/terrenos/terrain_detector.gd:217.
  10 archivos / 34 hits.
T62-07 M58 Guardado: scripts/saving/save_manager.gd, save_backup.gd,
  save_loader.gd, save_writer.gd, save_schema.gd; 24 archivos / 69 hits.
T62-08 M66 Vehiculos: scripts/vehiculos/vehicle_manager.gd (autoload Vehiculos),
  vehicle_controller.gd, vehicle_preset.gd, validate_vehicles.gd (13 hits).
T62-09 M68 Fast-Travel: scripts/fasttravel/fast_travel_service.gd,
  fast_travel_effect.gd, test_fast_travel_headless.gd (3 archivos / 9 hits).
  Las 3 [?] de la checklist propia de M69 quedan fuera de esta casilla.
T62-10 M108 Herramientas Internas: scripts/editor/tools/recipe_tool.gd,
  dialogos_auditor.gd, scripts/editor/plugin_herramientas.gd,
  scripts/tools/tool_controller.gd (4 archivos / 7 hits). scenes/dialogo_ui.tscn
  sigue ausente (deuda M21 documentada en b61).

== B. M20 (3/5 verificadas, 2 pendientes) ==
T62-11 L30 nombres de nivel: PENDIENTE. 0 hits exactos de Conocido/Confidente/
  Mejor amigo como terminos aislados en scripts/ + data/. Los 57 hits anchos son
  "desconocido" o logging. amistad_config.tres solo tiene umbrales y recompensas.
T62-12 L32 acceso eventos por nivel minimo: VERIFICADO.
  scripts/eventos/condicion_evento.gd L18 enum AMISTAD_MIN; L55-59 aplica
  nivel >= ctx.umbral_amistad sobre ctx.amistad_npcs. 0 .tres de eventos usan
  hoy esa condicion: deuda de contenido, no ausencia del mecanismo.
T62-13 L33 desbloqueo historias por nivel: VERIFICADO. 61 archivos
  data/dialogues/contextual/*_amistad60.json y *_amistad90.json con variantes
  HISTORIA; test_contextual_dialogue_m162.gd L116-135 mide el gating por
  amistad_<npc>; CondicionEvento.HISTORIA_PROGRESO en L19 y L61-63. Nota:
  secondary_stories_service.gd no tiene gate de nivel M23.
T62-14 L38 feedback nivel subido: VERIFICADO. event_bus.gd:87 senial
  friendship_level_up; data/vfx/vfx_catalog.json:649 vfx_regalo_amistad
  (corazones, bus npc.friendship_level_up); dialogue_manager.gd:65-70 emite
  level_up_reaction y abre dialogo. Nota: lista de desbloqueos = 0 hits.
T62-15 L191+L192+L193: PENDIENTE 1/3. L193 SI: cartas.json trae
  adjunto_retorno FLOR_SILVESTRE/PASTEL y friendship_service.gd:464-473 agrega
  el item al inventario al responder. L191 NO: 0 hits de despedida por nivel;
  solo linea_despedida fija por vecino en data/villagers/*.tres. L192 NO:
  0 hits de get_recuerdos en scripts/dialogos/ (memoria existe, nadie la habla).

== RESULTADO ==
13/15 casillas con artefacto verificado; 2 pendientes (T62-11, T62-15).
Total BACKLOGS: 3539 [x] + 13 = 3552 [x], 2 [ ], 0 [?].
No se flippearon filas del indice M01: su criterio exige checklist propia cerrada
y fila GLOBAL en OK; un grep no prueba ese criterio.
Formato backlog: UTF-8 sin BOM, LF. Sin fixes de codigo ni commits/push.
