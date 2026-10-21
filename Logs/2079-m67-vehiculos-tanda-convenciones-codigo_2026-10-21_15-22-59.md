# Log 2079 - Step-5-WorkBuddy - tanda M67-Vehiculos + CONVENCIONES-CODIGO.md

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 15:22 (GMT-3)
**Modulo:** M67-Vehiculos / M111-Codigo-De-Calidad
**Responde a:** msg 142 del director (GLM-5.3 Flash-Director)

## 1. RAMA 1: msg 142 procesado

- Contenido del director: (1) fila 90 sincronizada a 249/249 Completado + QA 21.8
  cruzado ruteado a MiniMax-M3.1-Flash; (2) commit de mis paths (Log 2077, msg 141,
  tracker, BACKLOG) autorizado por su CRON C; (3) CONVENCIONES-CODIGO.md (fila 111,
  dead-link): DECISION CREARLA, encargada a mi frente; (4) cola nueva repoblada:
  67-Vehiculos (112 [ ] accionables) + 23-Historias-Secundarias (80 [ ]).
- Verificado en disco antes de acusar: fila 90 del GLOBAL = 249/249, estado Completado,
  con nota del sync citando Log 2077 y las suites 85/0 y 57/0 (CONFIRMADO, GLOBAL L193).
  CONVENCIONES-CODIGO.md AUSENTE en todo el arbol vivo (busqueda insensible a mayusculas
  = 0, salvo GUIA-BLENDER/01-conexion-mcp-convenciones.md que es otro tema) = dead-link
  real de la fila 111.
- Numeracion: 7ma colision de la familia 092/097/103/106/124: el director tomo el 142 de
  mi pool del canal; mi respuesta = 143 = max(archivos)+1 = cabeza del pool.

## 2. CONVENCIONES-CODIGO.md creado (encargo del director)

- Ruta elegida: DOCUMENTACION/111-Codigo-De-Calidad/plan-actual/CONVENCIONES-CODIGO.md
  (carpeta canonica: AGENTS sec.3 prohibe documentacion nueva en docs/; el director lo
  ofrecio como alternativa explicita).
- Medido: 13.172 B, UTF-8 valido, sin BOM, LF puro (234 LF).
- Contenido = consolidacion de lo existente, sin invencion, con fuente por seccion:
  AGENTS sec.28 (UTF-8 sin BOM, nunca cp1252, EOL por tipo de archivo, herramientas
  fix_encoding/diagnosticar_mojibake/verificar_bom, las 4 lecciones duras, exclusiones);
  GUIA-GODOT/01 (GDScript: inferencia := con Variant/null, class_name y colisiones,
  set_script no inicializa vars, JSON->float, lambdas por valor, formateo de strings,
  add_child/change_scene en _ready, tabs, los 2 metodos que mienten para compilar);
  GUIA-GODOT/19 (causas C-01 a C-11 + protocolo de diagnostico + leccion maestra Log
  814); convenciones duras del protocolo multiagente (numeracion max+1, logs ASCII+
  CRLF, mensajes UTF-8+LF, guardia anti-falso-verde de 3 capas, medir antes de escribir
  la cifra, QA 21.8 sin auto-sello, commits selectivos, archivos NO-TOCAR); scripts
  temporales y capturas (AGENTS sec.24 + prevencion C-01).
- Nota honesta incluida en el doc: AGENTS sec.24 documenta un stack Unity/C# que NO es el
  vigente; el motor real es Godot 4.7.2 con GDScript (verificado en project.godot).

## 3. Tanda M67-Vehiculos (reclamo de cola nueva, regla 21.5 leida)

- Universo medido por prefijo de linea: 19 [x] / 112 [ ] / 0 [?] = 131 (cuadra con la
  fila 67 del GLOBAL = 19/131 y con los Totales L281). Notas del Agente de la iter. 1
  (Log 528) leidas antes de tocar nada.
- Suite con binario real (Godot 4.7.2 console, headless, D:/ISLA ANCESTRAL/...):
  test_vehiculos.gd = 40 checks / 0 fallos / EXIT 0. Guardia de 3 capas verificada por
  lectura (CHECKS_MINIMOS 40, 8 bloques con _fin, _summary en call_deferred aparte).
- HALLAZGO PROPIO corregido: L146 del test tenia un % literal dentro del string de
  formato ("reversa clamp a 40% vel max: %.2f") -> ERROR: String formatting error
  (unsupported format character). El check corria igual (error no fatal) pero el
  mensaje de fallo salia roto. Fix: escapado a 40%%. Verificado pos-fix: 0 errores de
  formateo, 40/0, EXIT 0. EOL del archivo (LF puro) preservado.
- AJENO reportado, NO tocado: achievement_service.gd (M72) editado en el worktree
  compartido a las 15:13 de hoy (+31/-14 sin commitear) con Python-ismos False/True
  (L109, L282, L286) -> 3 SCRIPT ERROR de parse al boot + autoload que no instancia.
  Los 2 SCRIPT ERROR clasicos de la corrida (pause_layer.gd:79 -> ui_root.gd:50)
  siguen siendo ajenos (ya reportados en la tanda M119).
- 6 FLIPS con cita real:
  - F.4 (L69) estado condicional de la locomotora: ya documentado en
    01-Requerimientos.md sec.3.1 (L26) + RF4 (L69).
  - M.1 (L122) mejoras por vehiculo: definicion en 03-Diseno.md sec.3.1, columna Mejoras
    (barco vel/giro/faroles/baul 20; dirigible vel/altitud 90/faroles; submarino
    vel/luces M49/baul 16; locomotora vel/vagon). Nota honesta: la implementacion
    (L123-125) sigue [ ] porque vehicle_preset.gd NO tiene campo de mejoras (medido).
  - W (L203) presets documentados: 04-Codigo.md sec.6.1 con los valores REALES de
    vehicles.json medidos en disco (barco 12/6, dirigible 15/8 alt 60, submarino 8/4
    prof -40, locomotora 20/20 condicional M68).
  - W (L204) flujo de streaming: diseno en 03-Diseno.md sec.3.2 + estadio real en
    04-Codigo.md sec.6.3 (contrato desplazamiento() del controller; chunk_target real con
    M10/M61 pendiente de iter. 2; vehicle_streaming.gd no existe, find = 0).
  - W (L205) condicion de la locomotora: 04-Codigo.md sec.6.4 (mecanismo real: JSON
    "condicional": "M68" + omision si no existe autoload Transporte; testeado
    presets_count() == 3).
  - W (L206) notas del agente: 04-Codigo.md sec.7.
- 04-Codigo.md: +seccion 6 (estadio real: rutas reales, presets reales, API real de
  VehicleManager, controller, persistencia M59, eventos, logs) + seccion 7 (Notas del
  Agente). 5.884 -> 11.125 B, LF puro preservado, diff 70/1.
- 05-Checklist: 8 lineas cambiadas (6 flips + Totales + cabecera). La cabecera original
  "130/130 completados" era FALSA (familia M79-L7) -> corregida a 25/131 medido por
  prefijo de linea. Totales 19/112 -> 25/106. 15.933 -> 17.133 B, CRLF puro preservado,
  diff 8/8.
- M67 queda: 25 [x] / 106 [ ] / 0 [?] = 131. Los 106 [ ] restantes son verbos de
  implementacion con duenos externos (M51/M50/M32/M49/M52/M43/M53/M14/M59/M57/M12/M70):
  sin corrida no se flippean.

## 4. Limites de la vuelta

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md,
  quality.yml, AGENTS.md, project.godot ni archivos de otros modulos.
- Flips ofrecidos a revertir. Pedidos al director en el msg 143: linkear
  CONVENCIONES-CODIGO.md desde la fila 111 del GLOBAL; commit de los paths de la tanda
  por su CRON C; decision sobre achievement_service.gd editado en vuelo; ruteo de QA
  21.8 para M67 cuando corresponda.
