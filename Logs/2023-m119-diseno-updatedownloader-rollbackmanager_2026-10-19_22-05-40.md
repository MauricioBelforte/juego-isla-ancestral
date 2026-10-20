# Log 2023 - M119-Actualizaciones: diseno de UpdateDownloader y RollbackManager (T-022, T-049..T-056)

**Agente:** Step-5-WorkBuddy
**Modulo:** 119-Actualizaciones
**Fecha:** 2026-10-19 22:05 (GMT-3)
**Vuelta:** RAMA 1 (msg 099 del director) + RAMA 2 (items 31-39 de la REPOBLACION V3)

## Contexto

- El tracker llego en 099 (actualizado por el director a las 21:02) pero el msg 099
  (internamente fechado 2026-10-20 00:05, "acuse-098-infraccion-97") NO tenia respuesta
  mia: patron del caso 081 (tracker adelantado por renumeracion ajena). Procesado esta
  vuelta y acusado con msg 100.
- Contenido del 099: correccion del tercer incidente de padding suyo en mi canal (su
  acuse renumerrado a 097-PADDED, mi 098 intacto, gate de padding en cada Cron C); tanda
  M50 ABIERTA con los 8 [ ] honestos como deuda conocida con duenio/definicion; orden:
  item 31 (M119) o COLA ACTIVA - GO.

## Medicion previa (hoy, no heredada)

- 119-Actualizaciones/plan-actual/05-Checklist.md: 109 [x] / 0 [?] / 9 [ ] = 118 (coincide
  con la auditoria del 2026-10-15 y con la fila GLOBAL L55). Bytes: 15.559, CRLF 171,
  21 LF sueltos, sin BOM.
- Disco HOY: update_manager.gd = 3.187 B / 92 lineas / 10 funciones (_ready,
  _cargar_versions, _registrar_servicio, comparar_versiones, _parsear, hay_actualizacion,
  version_remota, set_canal, politica, _guardar_version) - SIN descarga ni rollback.
- find game -name {game_version,update_checker,update_downloader,save_migrator,
  rollback_manager}.gd = 0 archivos. grep class_name de las 5 clases = 0 hits.
- 03-Diseno.md (LF puro, 5.664 B) tenia diseno de GameVersion (L49-69), UpdateChecker
  (L139-158) y SaveMigrator (L160-183); UpdateDownloader y RollbackManager SIN seccion.
- 04-Codigo.md (LF puro, 12.245 B): tabla L231-232 declaraba ambas clases "sin diseno" y
  L240-241 pedia "diseno antes que codigo".

## Trabajo hecho

- Documentadas 2 secciones nuevas en 03-Diseno.md sec. 3:
  * ### UpdateDownloader (Node) (L183-225): clase con download()/cancelar()/
    verificar_integridad(); DIR_TMP user://updates/tmp/; resume por cabecera Range;
    SHA-256 contra UpdateInfo.sha256; 3 reintentos con backoff 1/5/15 s; control de
    espacio con DirAccess.get_space_left() (NO OS.get_static_memory_usage(), que mide
    RAM); cancelacion con borrado del .tmp parcial; un download a la vez; sin segundo
    sistema de versionado (se apoya en UpdateManager + versions.json vigentes).
  * ### RollbackManager (Node) (L227-268): restore_previous_version()/
    listar_versiones()/verificar_integridad(); reglas T-049 a T-056 (backup por version
    en user://updates/versiones/<X.Y.Z>/, retencion min_versiones_atras, disparo
    automatico o manual, verificacion fail-closed por hash, restauracion del
    save_001_backup_v<X.Y.Z>.tres, UI popup + settings, notificacion y registro,
    re-verificacion de .pck y save antes de arrancar).
- 2 flips con cita real: 05-Checklist L146 (T-022) y L150 (T-049..T-056) [ ] -> [x].
  Totales L163: 109 -> 111 [x] / 7 [ ]. M119 = 111 [x] / 0 [?] / 7 [ ] = 118.
- Nota de cierre agregada al 05-Checklist (historial preservado: la correccion del
  2026-10-15 de step-5-kilocode queda citada y confirmada hoy byte a byte).
- 4 referencias obsoletas de 04-Codigo.md actualizadas (tabla L231/L232, nota de atria
  L220-221, recomendacion L240-241): 0 "sin diseno" restantes en el archivo.
- Suite test_updates_m119.gd corrida HOY con el binario real
  (Godot_v4.7.2-stable_win64_console.exe --headless): 15 checks / 0 fallos / EXIT 0,
  15 [OK] nominales en la salida. Los 3 SCRIPT ERROR de la corrida son de
  pause_layer.gd / ui_root.gd (construccion de la UI al arrancar la escena), AJENOS a
  M119: reportados, no tocados.

## Por que NO se flippearon los otros 7 items (31-37)

Los items L24/L25/L27/L35/L48/L61/L87 son verbos de IMPLEMENTACION ("Crear Resource",
"Implementar metodo", "Crear clase") con la funcionalidad AUSENTE en disco (hoy:
find = 0 archivos, 0 class_name, update_manager.gd sin descarga ni rollback). Fueron
revertidos por Familia A de BUG-070 (P-41, Log 1157): re-flippearlos sin codigo seria
re-inflar. Duenos externos M59/M96/M118/M107. Quedan [ ] honestos (precedente M50:
feature inexistente en disco = [ ]).

## Medidas por bytes (post-tanda)

- 03-Diseno.md: 5.664 -> 9.621 B, LF puro (332 LF, 0 CRLF), sin BOM, 0 FFFD.
- 04-Codigo.md: 12.245 -> 12.717 B, LF puro (246 LF), sin BOM, 0 FFFD.
- 05-Checklist.md: 15.559 -> 18.263 B, CRLF 171 -> 173, 21 LF sueltos preservados,
  sin BOM, 0 FFFD. Conteo por prefijo: 111 [x] / 0 [?] / 7 [ ] = 118.

## Limites

0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md,
quality.yml, AGENTS.md, project.godot / 0 auto-sellos 21.8. Los 2 flips son de MI modulo
(M119) y se ofrecen a revertir.

## Pendientes al director

- Commit de la tanda (03-Diseno.md, 04-Codigo.md y 05-Checklist.md de M119, Log 2023,
  msg 100, BACKLOG-MASTER, tracker).
- QA 21.8 de M119 a rutear (no auto-sello).
- Arrastrados: commit M55/M93/M109/M36/M50; gate ASCII para Logs/; gate legal por los
  300 PNG de M159; "16 Totales" (criterio ya cruzado en el item 57).
