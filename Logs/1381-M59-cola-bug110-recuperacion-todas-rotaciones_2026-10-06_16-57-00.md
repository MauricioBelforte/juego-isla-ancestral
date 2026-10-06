# Log 1381 - M59 - Cola de bugs, bug 4: BUG-110 (recuperacion de todas las rotaciones)

- Modelo: DeepSeek-V4.1-Flash
- Plataforma: WorkBuddy
- Fecha: 2026-10-06 16:57
- Agente: deepseek-v4.1-flash
- Modulo: M59 (saving) - cola de bugs derivada de M59
- Autorizacion: mensaje 51 del director (atria-Dawn-Preview / Kilo Code), seccion 4, orden 1->8
- Log reservado: 1381 (protocolo v3)
- Estado: COMMIT LOCAL, SIN PUSH

## 1. BUG-110 - backup muerto (r2 nunca se lee)

Reporte original: "MAX_ROTATIONS = 2 y rotate() mantiene slot_N_r1.bak y
slot_N_r2.bak, pero read_latest_backup() lee solo r1 y _try_recover() lo llama una
sola vez. Si r1 esta corrupto y r2 es integro, el loader reporta CORRUPTED aunque
existe un backup bueno en r2. Es un backup muerto: se gasta I/O y disco en
conservarlo pero ningun camino de lectura lo consulta."

Evidencia: save_backup.gd:12 (MAX_ROTATIONS=2), :17-30 (rotate), :58-62
(read_latest_backup lee solo r1), save_loader.gd:91-96 (_try_recover llama una vez).

## 2. Fix aplicado (2 archivos)

### game/isla-ancestral/scripts/saving/save_backup.gd

- Nuevo `static func read_backup(slot, rotation) -> String`: lee la rotacion pedida
  (1 = mas reciente) usando `SaveWriter.read_document` (respeta el cap de BUG-109).
  Devuelve "" si no existe.
- `read_latest_backup(slot)` se reimplementa como `read_backup(slot, 1)` (mantiene
  la API existente; ya no duplica la lectura).

### game/isla-ancestral/scripts/saving/save_loader.gd (_try_recover)

- Se sustituye la lectura unica de r1 por un bucle
  `for rotation in range(1, SaveBackup.MAX_ROTATIONS + 1)` que prueba cada rotacion
  EN ORDEN DE FRESCURA (r1, luego r2, ...) hasta una que pase parse_document +
  completar + validate.
- Se conserva la semantica dura: si la rotacion mas fresca legible es de version
  FUTURA, se devuelve FUTURE_VERSION y NO se cae a rotaciones mas antiguas (caer a
  una mas vieja seria DEGRADAR el save, prohibido).
- Si ninguna rotacion es valida -> CORRUPTED (antes: si r1 no servia, CORRUPTED
  directo).

## 3. Sonda nueva (probada en rojo por inyeccion)

Archivo: game/isla-ancestral/scripts/saving/test_backup_rotations.gd
- 7 checks. Piso `CHECKS_MINIMOS := 6` (MEDIDO en verde = 7).
- Usa un slot de prueba aislado (97) y documentos VALIDOS con marca distinguible
  (meta.last_saved) para saber de que rotacion se recupero.
- Casos: (A) r1 valido -> RECOVERED desde r1; (B) r1 corrupto + r2 valido ->
  RECOVERED desde r2 (nucleo de BUG-110); (C) solo r2 presente -> RECOVERED;
  (D) r1 y r2 corruptos -> CORRUPTED.
- VERDE: 7 checks, 0 fallos, EXIT 0 x3.
- ROJO por INYECCION (limitando el bucle a r1, range(1, 2)): 7 checks, 3 fallos,
  EXIT 1. Fallan exactamente los casos que dependen de r2:
    "r1 corrupto + r2 valido -> RECOVERED (BUG-110)"
    "se recupero la marca de r2 (no la de r1)"
    "solo r2 presente -> RECOVERED"

## 4. Regresion (despues del fix, todo verde)

- test_rotate_m59.gd          : 43 checks, 0 fallos
- test_slots_m59.gd           : 22 checks, 0 fallos
- test_autosave_m59.gd        : 0 fallos
- test_fishing_save_block.gd  : 11 checks, 0 fallos
- test_save_collect_robust.gd : 10 checks, 0 fallos (Log 1377)
- test_save_size_cap.gd       : 7 checks, 0 fallos (Log 1380)
- test_backup_rotations.gd    : 7 checks, 0 fallos (nueva)
- test_inventario.gd          : 0 fallos (M14)
- test_inventario_iter5.gd    : 0 fallos (M14)
- test_inventario_restore_robusto.gd : 12 checks, 0 fallos (Log 1378)
- test_m62_pureza_save.gd     : 59 checks, 0 fallos (M62)

## 5. Observaciones de canal (no tocadas)

- El pool de logs sigue reportando 2 colisiones AJENAS: 1290 y 1368.
- DOCUMENTACION/11-BUGS.md: NO tocado (espera commit conjunto con s3/Ling).

## 6. Estado y pendientes

- Commit local del fix + sonda + este log. SIN PUSH.
- GRUPO 1-4 DE LA COLA COMPLETO: BUG-111 (Log 1377), BUG-108 (Log 1378),
  BUG-109 (Log 1380), BUG-110 (este Log 1381). Corresponde REPORTAR al director.
- Pendiente grupo 5-8: BUG-112, BUG-113, BUG-114, BUG-115 (grupo trivial).
