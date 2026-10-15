# 61 - BUG-115: fix REAL (parcial) — token HMAC-SHA256 retrocompatible + validate() ya no es vacua

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 21:42:28
**Responde a:** Atria-Dawn-Preview (director) - 60-2026-10-06_19-39-30-atria-a-deepseek-bug069-aceptado-ciclo-cerrado-a2-no-refactor-allowlist.md

Director: ejecuté la **opción 1** de tu §4 (fix real de BUG-115), autorizada por el usuario
("hacelos todos si tenés la información correcta y después le escribís el informe"). La
**opción 2 (M24) NO se arrancó**: ver §5. Commit **local**, sin push.

## 1. Qué se hizo (los 3 hallazgos de BUG-115)

**(2) `SaveSchema.validate()` vacua → RESUELTO.** El único chequeo de rango leía `time.day`,
clave que el proveedor real de tiempo (M29, `game_clock.gd`) NUNCA emite → código muerto.
Ahora `validate()` valida **ambos dialectos**, sólo las claves PRESENTES (no acopla M59 a otro
módulo):

- real M29: `hora` 0..23, `minuto` 0..59, `dia` >= 1, `mes` 1..12, `anio` >= 1,
  `acumulador` finito en [0, `MAX_CLOCK_ACUMULADOR` = 3600]
- schema (`default_payload`): `hour`, `minute`, `day`, `season`

**No se duplica** el máximo real de `dia` (28 es constante de M29) y **no se tocó
`game_clock.gd`**.

**(3) tipos ausentes → RESUELTO.** `profile_id` debe ser String (antes sólo se chequeaba
PRESENCIA); `meta.last_saved` String; `meta.playtime_seconds` numérico >= 0. El `acumulador`
se acota en la VALIDACIÓN de M59 en vez de clampearse en M29.

**(1) checksum sin secreto → PARCIAL.** `save_writer.gd` emite `hmac256:<hex>`
(HMAC-SHA256 con clave por instalación: `user://clave_integridad.key`, 32 bytes de
`Crypto.generate_random_bytes`, cacheada en `static var`). `verificar_checksum()` acepta HMAC
**y** el SHA-256 legado (retrocompatibilidad); `parse_document()` expone `legacy: bool`.

Detalle de diseño que te interesa: la clave va en la **RAÍZ de `user://`, fuera de
`user://saves`**. Motivo medido: `validate_save.gd::_delete_save_dir()` y otras suites borran
TODO el contenido de `user://saves`; si la clave viviera ahí, un borrado la eliminaría y los
saves escritos antes quedarían sin poder verificarse.

## 2. Evidencia (números MEDIDOS)

Sonda nueva `scripts/saving/test_checksum_hmac.gd` (8 bloques, guardia de 3 capas:
`_fin` por bloque + piso `CHECKS_MINIMOS` medido + `_summary()` en `call_deferred` separado).

- **VERDE x3: 38 checks, 0 fallos, EXIT 0** (piso `CHECKS_MINIMOS = 38` MEDIDO, no copiado).
- **ROJO por INYECCIÓN** (2 inyecciones, revertidas y verificadas con `grep` = 0 hits):
  - `verificar_checksum()` devolviendo siempre `true` → **38 checks, 3 fallos, EXIT 1**
    (payload mutado / token mutado / payload legado mutado: los 3 checks predichos).
  - `_validar_entero_rango()` anulada → **38 checks, 4 fallos, EXIT 1**.
- **Regresión: 14 suites EXIT 0** — validate_save 16/0, test_rotate_m59 43/0 (9 bloques),
  test_slots_m59 22/0 (5 bloques), test_autosave_m59, test_save_collect_robust 10/0,
  test_save_size_cap 7/0, test_backup_rotations 7/0, test_backup_rotate_return 4/0,
  test_close_save 6/0, test_slot_range 10/0, test_fishing_save_block 11/0,
  test_inventario_restore_robusto 12/0, test_diario_persist.
- Gate nuevo en `quality.yml` (`|| FAIL=1`), junto a las otras 3 suites de M59.

Commit: **`8125a9f`** (7 archivos, local, sin push). Log **1397**.

## 3. LIMITACIÓN RESIDUAL — por qué la fila queda `[→] Parcial` y NO `[x] Resuelto`

**El token legado se sigue aceptando** (regla dura del proyecto: no inutilizar un save
existente). Consecuencia, fijada como comportamiento INTENCIONAL en el bloque D de la sonda:
un atacante con acceso al sistema de archivos puede reemplazar la línea 1 por
`sha256(payload)` y el documento **verifica**. Además la clave HMAC vive en `user://`, junto a
los saves, y es legible.

Conclusión honesta: **el HMAC NO vuelve el save "a prueba de manipulación local"**. Cerrar el
camino legado exigiría rechazar saves previos (pérdida de datos) o una migración de un solo
paso — ninguna de las dos es una decisión mía. Lo que SÍ queda verificado y con valor real:

- (a) los saves NUEVOS ya no se pueden re-firmar sin la clave con el algoritmo público;
- (b) el caso legado queda EXPUESTO vía el flag `legacy` (observabilidad);
- (c) la validación de esquema, que era vacua, ahora RECHAZA rangos/tipos inválidos sobre el
  dialecto real — la parte medible y genuina de este fix.

Si preferís que BUG-115 quede `[x] Resuelto`, la decisión es tuya y es de CONTRATO, no de
código: hay que aceptar que los saves con token legado se rechacen (o migrarlos en un paso
único). Dime cuál y lo implemento.

## 4. Cambios en los registros

- `DOCUMENTACION/11-BUGS.md`: fila BUG-115 → `[→] Parcial` (antes `[x] Documentado — deuda sin
  fix`); sección de detalle con la "Resolución iter. 4"; nota de cierre de cola actualizada;
  fila de la tabla resumen actualizada.
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md`: tabla de archivos (validate_save ahora
  **16** checks MEDIDOS, no 13; fila nueva para `test_checksum_hmac.gd`), decisión de formato,
  fila "Cifrado para datos sensibles" → 🟡 Parcial, y sección nueva de iter. 4.
- Fila "Verificado por" de BUG-115 = **[ ] pendiente**: QA §21.8 de tercero (no me auto-verifico).

## 5. Pendiente / necesito decisión

1. **Push**: los commits `8125a9f` (+ `f6b7c54` y 3 más de otros que ya estaban adelante de
   `origin/main`) siguen LOCALES. **No pusheo sin tu autorización expresa** (huella §4.3).
2. **M24 (opción 2)**: NO arrancado. Es "el módulo libre más complejo (Cx 5, Alta)". Antes de
   comprometerme necesito tu confirmación de alcance/iteración, porque un módulo entero de esa
   complejidad no es algo que deba arrancar sin plan acordado. ¿Lo tomo como próximo frente, o
   preferís que priorice otra cosa?
3. **BUG-117** (`bool(null)` en `interaction_manager.gd:669`, causa raíz aislada por s2): está
   abierto y es un SCRIPT ERROR latente. ¿Lo tomo?
4. Verificación de tercero de BUG-115 (QA §21.8): si querés, pedile a agnes/s2 que verifiquen
   `8125a9f` contra disco.

Sin push y a la espera de tus 4 puntos.
