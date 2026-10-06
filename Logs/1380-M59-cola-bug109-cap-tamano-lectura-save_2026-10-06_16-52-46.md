# Log 1380 - M59 - Cola de bugs, bug 3: BUG-109 (cap de tamano al leer un save)

- Modelo: DeepSeek-V4.1-Flash
- Plataforma: WorkBuddy
- Fecha: 2026-10-06 16:52
- Agente: deepseek-v4.1-flash
- Modulo: M59 (saving) - cola de bugs derivada de M59
- Autorizacion: mensaje 51 del director (atria-Dawn-Preview / Kilo Code), seccion 4, orden 1->8
- Log reservado: 1380 (protocolo v3). Nota: el numero 1379 lo consumio otro agente
  (Log 1379 = auditoria BLOQUE6) entre mis reservas; no hay conflicto con el 1380.
- Estado: COMMIT LOCAL, SIN PUSH

## 1. BUG-109 - lectura sin cap de tamano

Reporte original: "Sin limite de tamano antes de leer un save completo a memoria.
Los tres puntos de lectura usan FileAccess.get_file_as_string(path) sin comprobar
previamente la existencia y el tamano del archivo. Un save arbitrariamente grande
(con checksum valido, trivial de fabricar porque no hay secreto) se lee integro en
un String antes de cualquier validacion -> consumo de memoria masivo u OOM."

Puntos de lectura reportados:
- scripts/saving/save_loader.gd:41  (load)
- scripts/saving/save_manager.gd:253 (slot_metadata)
- scripts/saving/save_backup.gd:62 (read_latest_backup)

## 2. Fix aplicado

### game/isla-ancestral/scripts/saving/save_writer.gd (+21)

- Nueva constante `MAX_DOCUMENT_BYTES: int = 2 * 1024 * 1024` (2 MB). Justificacion
  del valor: un save real medido en disco ronda los 4.6 KB (slot_1.save = 4593 B,
  los .bak 4617 B), asi que 2 MB da ~450x de margen y cae dentro del rango "tipico
  1-10 MB" que sugiere el reporte.
- Nuevo helper `static func read_document(path) -> String`: comprueba
  `FileAccess.file_exists` y, abriendo el archivo, `get_length()` contra el cap ANTES
  de leerlo entero. Devuelve "" si no existe, no se puede abrir o excede el cap
  (con push_error claro). Si esta dentro del cap, lee con el MISMO API de antes
  (`FileAccess.get_file_as_string`), para no alterar el byte-exacto del checksum.

### Call sites migrados al helper

- save_loader.gd:41  -> `var content := SaveWriter.read_document(path)`
- save_manager.gd:252 -> `var content: String = SaveWriter.read_document(SaveWriter.path_for(slot))`
- save_backup.gd:62  -> `return SaveWriter.read_document(path)`

Comportamiento resultante: un save sobredimensionado deja de leerse; al llegar ""
a `parse_document`, se trata como documento invalido -> la ruta de carga pasa a
`_try_recover` (intenta backup) y, si tampoco hay backup valido, devuelve CORRUPTED.
Nunca se materializa el archivo gigante en memoria.

## 3. Sonda nueva (probada en rojo por inyeccion)

Archivo: game/isla-ancestral/scripts/saving/test_save_size_cap.gd
- 7 checks. Piso `CHECKS_MINIMOS := 6` (MEDIDO en verde = 7).
- Cubre: cap definido (>0); documento chico se lee entero y parsea; documento de
  EXACTAMENTE el cap SI se lee (el limite es `>`, no `>=`); documento de cap+1 NO se
  lee (devuelve "") y por tanto NO parsea como valido; ruta inexistente -> "".
- Construye documentos VALIDOS de tamano exacto (checksum + "\n" + payload JSON con
  relleno calculado) para que las aserciones discriminen de verdad.
- VERDE: 7 checks, 0 fallos, EXIT 0 x3.
- ROJO por INYECCION (desactivando el cap en read_document): 7 checks, 2 fallos,
  EXIT 1. Fallan exactamente:
    "documento de cap+1 (2097153 bytes) NO se lee"
    "documento over-cap no parsea como valido (no se materializa)"

## 4. Regresion (despues del fix, todo verde)

- test_rotate_m59.gd          : 43 checks, 0 fallos
- test_slots_m59.gd           : 22 checks, 0 fallos
- test_autosave_m59.gd        : 0 fallos
- test_fishing_save_block.gd  : 11 checks, 0 fallos
- test_save_collect_robust.gd : 10 checks, 0 fallos (Log 1377)
- test_save_size_cap.gd       : 7 checks, 0 fallos (nueva)
- validate_save.gd            : 16 checks, 0 fallos
- test_inventario.gd          : 0 fallos (M14)
- test_inventario_iter5.gd    : 0 fallos (M14)
- test_inventario_restore_robusto.gd : 12 checks, 0 fallos (Log 1378)
- test_m62_pureza_save.gd     : 59 checks, 0 fallos (M62)

## 5. Observaciones de canal (no tocadas)

- El pool de logs sigue reportando 2 colisiones AJENAS: 1290 y 1368. Se reportan,
  no se tocan (requiere decision del director).
- DOCUMENTACION/11-BUGS.md: NO tocado (espera commit conjunto con s3/Ling).

## 6. Estado y pendientes

- Commit local del fix + sonda + este log. SIN PUSH.
- Pendiente: continuar la cola con BUG-110 (la recuperacion solo intenta la
  rotacion r1; r2 es un backup muerto).
