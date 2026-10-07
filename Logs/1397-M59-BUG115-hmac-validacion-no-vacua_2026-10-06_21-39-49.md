# Log 1397 - M59 - BUG-115 fix real: HMAC + validacion no vacua

- Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
- Fecha: 2026-10-06 21:39:49
- Modulo: M59 (Guardado) - cola de bugs, ultimo item
- Autorizacion: director (canal 60, seccion 4) + usuario "hacelos todos si
  tenes la informacion correcta y despues le escribis el informe"

## 1. Contexto

BUG-115 era una DEUDA agrupada de 3 partes, documentada sin fix en `3ad8630`
(Log 1382):

  (a) el token de integridad era un SHA-256 del payload EN CLARO, sin secreto
      -> solo protegia contra bit-rot, no contra manipulacion;
  (b) `SaveSchema.validate()` era VACUA contra saves reales: su unico chequeo de
      rango leia `time.day`, clave que el proveedor real de tiempo (M29,
      `game_clock.gd`) NUNCA emite (usa `hora/minuto/dia/mes/anio/acumulador`),
      asi que era CODIGO MUERTO;
  (c) tipos ausentes en campos no criticos (`profile_id` solo se chequeaba por
      PRESENCIA, no por tipo; `meta` sin validacion).

## 2. Que se hizo

### 2.1 `scripts/saving/save_writer.gd` - HMAC-SHA256 retrocompatible

- Nuevo formato de linea 1: `hmac256:<64 hex>` (HMAC-SHA256 con clave por
  instalacion). Antes: `<64 hex>` = SHA-256 del payload en claro.
- Clave por instalacion: `user://clave_integridad.key` (hex de 32 bytes de
  `Crypto.generate_random_bytes`). Se genera una vez; se cachea en un `static
  var` para no releerla en cada escritura.
  - DECISION: la clave vive en la RAIZ de `user://`, NO dentro de `user://saves`.
    Motivo medido: `validate_save.gd::_delete_save_dir()` y otras suites borran
    TODO el contenido de `user://saves`; si la clave viviera ahi, un borrado la
    eliminaria y los saves escritos antes quedarian sin poder verificarse.
- `firmar_payload(payload_str)` -> `hmac256:<hex>`.
- `verificar_checksum(payload_str, checksum)` -> acepta HMAC (con prefijo) y
  SHA-256 legado (sin prefijo). Comparacion en tiempo razonablemente constante.
- `parse_document()` ahora devuelve ademas `legacy: bool` (observabilidad).
- `build_file_content()` emite HMAC. La autoverificacion interna de
  `write_atomic()` (escribe .tmp -> lo relee -> `parse_document().ok`) sigue
  siendo SIMETRICA: ambos lados usan el mismo formato, asi que no se rompe.

### 2.2 `scripts/saving/save_schema.gd` - `validate()` deja de ser vacua

- Se validan AMBOS dialectos del bloque `time`, solo las claves PRESENTES (no se
  acopla la validacion a un dialecto):
  - real (M29): `hora` 0..23, `minuto` 0..59, `dia` >= 1, `mes` 1..12,
    `anio` >= 1, `acumulador` finito en [0, 3600];
  - schema (`default_payload`): `hour` 0..23, `minute` 0..59, `day` >= 1,
    `season` >= 0.
- NO se duplica el maximo real de `dia` (28, constante de M29): seria acoplar M59
  a una decision de diseno de otro modulo. Cotas inferiores + rangos universales.
- `profile_id`: ahora debe ser String (antes solo se chequeaba presencia).
- `meta.last_saved` String y `meta.playtime_seconds` numerico >= 0.
- Nueva constante `MAX_CLOCK_ACUMULADOR = 3600.0` (cota de sanidad; el proveedor
  real drena el acumulador mientras sea >= 1.0, asi que en operacion normal queda
  en [0, 1)). NO se toco `game_clock.gd` (M29, no es mio).

## 3. Evidencia (numeros MEDIDOS, no estimados)

Sonda nueva: `scripts/saving/test_checksum_hmac.gd` (guardia de 3 capas: `_fin`
por bloque, piso `CHECKS_MINIMOS` MEDIDO, `_summary()` en call_deferred
separado). 8 bloques: formato / tampering de payload / tampering de token /
legado aceptado / legado manipulado / end-to-end write_atomic+SaveLoader / clave
persistente / validate no vacua.

- VERDE x3: **38 checks, 0 fallos, EXIT 0** (las 3 corridas).
- ROJO por INYECCION (probado antes de confiar en el guardian):
  - `verificar_checksum()` devolviendo siempre `true` -> **38 checks, 3 fallos,
    EXIT 1** (payload mutado, token mutado, payload legado mutado: los 3 checks
    de tampering, exactamente los predichos).
  - `_validar_entero_rango()` anulada -> **38 checks, 4 fallos, EXIT 1**
    (hora 99, minuto 60, mes 13, hora String).
  - Inyecciones REVERTIDAS; `grep INJECT-BUG115` sobre `scripts/` = 0 hits.

Regresion completa (14 suites, todas EXIT 0):

| suite | resultado |
| --- | --- |
| saving/validate_save.gd | 16 checks, 0 fallos |
| saving/test_rotate_m59.gd | 43 checks, 0 fallos, 9 bloques |
| saving/test_slots_m59.gd | 22 checks, 0 fallos, 5 bloques |
| saving/test_autosave_m59.gd | EXIT 0 |
| saving/test_save_collect_robust.gd | 10 checks, 0 fallos |
| saving/test_save_size_cap.gd | 7 checks, 0 fallos |
| saving/test_backup_rotations.gd | 7 checks, 0 fallos |
| saving/test_backup_rotate_return.gd | 4 checks, 0 fallos |
| saving/test_close_save.gd | 6 checks, 0 fallos |
| saving/test_slot_range.gd | 10 checks, 0 fallos |
| saving/test_fishing_save_block.gd | 11 checks, 0 fallos |
| inventario/test_inventario_restore_robusto.gd | 12 checks, 0 fallos |
| diario/test_diario_persist.gd | EXIT 0 |
| saving/test_checksum_hmac.gd (nueva) | 38 checks, 0 fallos |

Cableado CI: `test_checksum_hmac.gd` agregada como GATE DURO (`|| FAIL=1`) en
`.github/workflows/quality.yml`, junto a las otras 3 suites de M59.

## 4. LIMITACION RESIDUAL (honesta, NO es un sello de "a prueba de trampas")

El token LEGADO (SHA-256 sin prefijo) se sigue ACEPTANDO, por la regla dura del
proyecto de no inutilizar un save existente. Consecuencia MEDIDA por diseno: un
atacante con acceso al sistema de archivos puede reemplazar la linea 1 por
`sha256(payload)` y el documento verifica (bloque D de la sonda lo fija como
comportamiento INTENCIONAL). Ademas la clave HMAC vive en `user://`, junto a los
saves, y es legible.

Conclusion honesta: el HMAC NO vuelve el save "a prueba de manipulacion local".
Lo que SI aporta y esta verificado:
  (1) los saves NUEVOS ya no se pueden re-firmar sin la clave con el algoritmo
      publico (sube el costo de un tampering casual);
  (2) el caso legado queda EXPUESTO y observable via el flag `legacy`;
  (3) la validacion de esquema, que era vacua, ahora RECHAZA valores fuera de
      rango/tipo sobre el dialecto real -> esa es la parte con valor real y
      verificable de este fix.
Por eso la fila de BUG-115 en `11-BUGS.md` pasa a `[->] Parcial`, NO a `[x]
Resuelto`.

## 5. Archivos

- `game/isla-ancestral/scripts/saving/save_writer.gd` (modificado)
- `game/isla-ancestral/scripts/saving/save_schema.gd` (modificado)
- `game/isla-ancestral/scripts/saving/test_checksum_hmac.gd` (nuevo)
- `.github/workflows/quality.yml` (gate nuevo)
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` (docs)
- `DOCUMENTACION/11-BUGS.md` (fila + seccion de BUG-115)
- `Logs/1397-M59-BUG115-hmac-validacion-no-vacua_2026-10-06_21-39-49.md` (este)

Eliminado: `scripts/saving/_tmp_probe_crypto.gd` (sonda temporal de la API de
cripto, NO versionada; verifico KEY_LEN=32, HMACContext.start=0, round-trip hex).

## 6. Pendiente / no hecho

- M24 (opcion 2 del canal 60): NO se arranco en este log.
- Push: sin autorizacion expresa; los commits quedan LOCALES.
