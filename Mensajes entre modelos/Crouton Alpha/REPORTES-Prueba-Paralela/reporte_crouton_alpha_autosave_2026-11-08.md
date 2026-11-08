**Modelo:** Crouton Alpha
**Plataforma:** Kilo / Crouton Alpha
**Fecha:** 2026-11-08

# Reporte — Auto-save, checkpoints y recuperación de guardado

## Alcance

Análisis de `game/isla-ancestral/scripts/saving/` (M59 Guardado) y de los
sistemas de checkpoints del proyecto (M66 `CheckpointManager`, M26
`TemploCheckpoint`):

| Archivo | Rol |
|---|---|
| `scripts/saving/save_manager.gd` (329 líneas) | Autoload `SaveManager`: cola de guardado, temporizador, disparadores por eventos, bloqueo, orden de rotación/escritura |
| `scripts/saving/save_writer.gd` (239 líneas) | Escritura atómica tmp→rename con HMAC-SHA256, cap de 2 MB, verificación interna del `.tmp` |
| `scripts/saving/save_snapshot.gd` (80 líneas) | Registro de proveedores por sección, recolección tolerante a fallos y restauración |
| `scripts/saving/save_loader.gd` (147 líneas) | Carga validada, recuperación desde backups, migración y rechazo de versión futura |
| `scripts/saving/save_backup.gd` (88 líneas) | Rotación local (2 rotaciones `slot_N_r1/r2.bak`) y backups manuales fechados |
| `scripts/saving/save_schema.gd` (267 líneas) | Contrato único de formato: versión, 3 slots, defaults, validación de estructura y dialectos |
| `scripts/core/recovery/checkpoint_manager.gd` (138 líneas) | M66: 3 checkpoints rotativos por bioma + slot global, mismo patrón atómico |
| `scripts/templos/templo_checkpoint.gd` (204 líneas) | M26: 5 checkpoints del templo con guardado atómico tmp→.bak→rename |
| `scripts/saving/test_autosave_m59.gd` (147 líneas) | Suite de auto-save: dirty, bloqueo en diálogo, `auto_dia`, `auto_mision`, `auto_evento` |
| `scripts/saving/validate_save.gd` (170 líneas) | Validación headless: atomicidad, checksum, recuperación, migración |

## 1. ¿Cómo funciona el auto-save?

El auto-save vive en `save_manager.gd` y responde a **cuatro caminos** que
convergen en `request_save()`:

1. **Temporizador** — `_process()` (`save_manager.gd:157-165`) acumula `delta`
   y, al superar `auto_save_interval` (exportado en `save_manager.gd:25` con
   valor **300.0 s**), llama a `request_save(current_slot, "timer")`.
   Si no hay slot cargado, lo omite con aviso (`save_manager.gd:164-165`).
2. **Cambio de día** — `bus.calendar.day_started` → `_on_auto_save_dia()`
   (`save_manager.gd:89,107-109`), motivo `"auto_dia"`.
3. **Misión completada** — `bus.quest.quest_completed` → `_on_auto_save_mision()`
   (`save_manager.gd:91,111-113`), motivo `"auto_mision"`.
4. **Evento de temporada finalizado** — `EventManager.evento_terminado` →
   `_on_auto_save_evento()` (`save_manager.gd:94-96,116-118`), motivo `"auto_evento"`.

`request_save()` (`save_manager.gd:183-192`) descarta si `_blocked` es
verdadero (emite `auto_save_skipped`) o si el slot está fuera de `1..3`
(`SLOT_COUNT = 3`, `save_schema.gd:23`), y encola en `_queue`. `_process_queue()`
(`save_manager.gd:211-249`) procesa de a uno: **rota el save anterior a
`.bak` y recién después** llama a `SaveWriter.write_atomic()` (orden
corregido en M59 iter. 2 por un bug crítico documentado en
`save_manager.gd:222-235`, donde el orden invertido hacía que el slot quedara
sin `.save` cargable). Al completar, limpia el flag `_dirty` y emite
`save_completed(slot, reason)` (`save_manager.gd:242`).

El guardado al cerrar la ventana es un camino aparte:
`_notification(NOTIFICATION_WM_CLOSE_REQUEST)` (`save_manager.gd:129-150`)
replica el flujo normal de forma síncrona (rotar → escribir), respetando
`_writing`; si hay una escritura en curso, la omite con aviso en vez de
intercalarla.

### Checkpoints (save-points)

- **M66 `CheckpointManager`** (`scripts/core/recovery/checkpoint_manager.gd:42-55`):
  `registrar_checkpoint(bioma, evento, payload)` escribe de forma atómica
  (`_escribir_checkpoint_atomico`, líneas 58-80: tmp → verificación con
  `parse_document` → `.bak` del anterior → rename) con **3 slots rotativos
  por bioma** (`SLOTS_POR_BIOMA = 3`, línea 14) más un slot global de
  emergencia (`SLOT_GLOBAL = -1`, línea 17), en `user://checkpoints/`.
- **M26 `TemploCheckpoint`** (`scripts/templos/templo_checkpoint.gd:27-31`):
  5 checkpoints del templo (`porte, vestibulo, vientos, central, sello`) con
  el mismo patrón atómico tmp → `.bak` → rename, e implementa
  `cargar_con_respaldo()` para recuperar desde el `.bak` si el principal falla.

## 2. ¿Hay validación antes de guardar automáticamente?

**Sí, en tres capas.** Antes del auto-save propiamente dicho no hay
validación de contenido: `request_save()` solo comprueba el flag `_blocked` y
el rango del slot (`save_manager.gd:183-189`). La validación ocurre
**después** de serializar, dentro de `SaveWriter.write_atomic()`
(`save_writer.gd:180-222`):

1. **Rango del slot** — `SaveSchema.slot_valido()` (`save_writer.gd:184-186`),
   defensa en profundidad frente a llamadas directas con slot inválido.
2. **Verificación del `.tmp` antes del rename** — `parse_document(written)` debe
   dar `ok == true` (`save_writer.gd:210-214`). Esto comprueba que el archivo
   no quedó vacío ni corrupto y que el HMAC firma correctamente el payload
   exacto serializado.
3. **Retorno de `store_string()` comprobado** — desde Godot 4.4+,
   `save_writer.gd:204` verifica `write_ok`; un disco lleno o permisos
   denegados abortan antes del rename. Si la escritura falla, el save
   anterior queda intacto (en el slot o en el `.bak` ya rotado).

Además, el **cierre de ventana** y la **rotación al guardar** validan el
resultado de `SaveBackup.rotate()` (`save_manager.gd:142-143,236-237`): si la
rotación falla, se continúa escribiendo (el save es prioritario) pero el
fallo se loguea.

La validación **estructural** del payload contra el esquema ocurre al
**cargar** (`SaveSchema.validate`, ver §4), no al guardar; el guardado no
pasa el payload por `validate()` antes de escribirlo.

## 3. ¿Hay problemas de guardado parcial o corrupto?

El diseño **prevé y mitiga** el guardado parcial en varios puntos, pero
quedan dos limitaciones conocidas y documentadas en el propio código:

**Protecciones existentes:**

- **Escritura atómica** (`save_writer.gd:4-9, 194-222`): nunca se escribe
  sobre `slot_N.save`; todo pasa por `slot_N.tmp` + rename atómico del SO.
  Ante cualquier fallo, el save anterior queda intacto.
- **Verificación interna del `.tmp`** antes del rename (`save_writer.gd:210-214`):
  si el `.tmp` no verifica, no se renombra.
- **Limpieza de `.tmp` huérfanos** al arrancar: `_process_init_cleanup()`
  (`save_manager.gd:327-329`) + `cleanup_orphan_tmp()` (`save_writer.gd:225-231`).
- **Cap de lectura** de 2 MB (`MAX_DOCUMENT_BYTES`, `save_writer.gd:36,56-67`):
  un archivo fabricado o corrupto no puede agotar memoria por lectura total.
- **Proveedores tolerantes al fallo** (`save_snapshot.gd:46-63`,
  BUG-111-bis): si un proveedor lanza o devuelve algo distinto de
  `Dictionary`, su sección se omite con `push_error`; antes este camino
  escribía un **save vacío** y se perdía todo el progreso en silencio.
- **Protección contra saves vacíos** en `write_atomic()`: el `.tmp` se
  verifica con `parse_document()` antes del rename (`save_writer.gd:212`).

**Limitaciones conocidas y documentadas:**

1. **Cierre durante una escritura en curso** (`save_manager.gd:138-140`):
   si la ventana se cierra mientras `_writing == true`, el guardado de
   cierre se **omite** para no intercalar escrituras. El progreso de ese
   instante (salvo el último auto-save) se pierde. Es la decisión deliberada
   de no corromper el save en curso, pero es una ventana real de pérdida.
2. **Clave HMAC legible junto a los saves** (`save_writer.gd:154-162`):
   la clave vive en `user://clave_integridad.key`. El propio código
   reconoce que el HMAC **no convierte el save en a prueba de manipulación
   local**: con acceso al sistema de archivos se puede recalcular un token
   legado. Aporta detección de corrupción accidental y de tampering no
   reproducido por el algoritmo público, no seguridad anti-trampas local.
3. **Saves con token legado (SHA-256 en claro) se aceptan** por
   retrocompatibilidad (`save_writer.gd:38-40, 135-139`): un save anterior
   a BUG-115 valida igual. La constante `legacy` en `parse_document()`
   (`save_writer.gd:176,163`) expone el caso para que la UI pueda avisarlo.

## 4. ¿Hay recuperación de saves corruptos?

**Sí, en dos niveles**, en `save_loader.gd`:

**Nivel 1 — Recuperación desde backups locales** (`_try_recover()`,
`save_loader.gd:98-138`, BUG-110):
- Si el `.save` falta (`save_loader.gd:31-40`, guardado interrumpido entre
  rotación y rename) o falla checksum/validación (`save_loader.gd:44-45,62-63`),
  se recorren **todas las rotaciones en orden de frescura** `r1, r2`
  (`MAX_ROTATIONS = 2`, `save_backup.gd:12`).
- Cada backup se verifica con `parse_document()` (checksum HMAC) **y** con
  `SaveSchema.validate()` + `completar()` (paridad estricta con el camino
  principal, `save_loader.gd:116-121`), y se rechaza si es de versión futura
  sin caer a rotaciones más antiguas (`save_loader.gd:123-127`, "nunca
  degradar un save"). Si una rotación es válida → `LoadResult.RECOVERED`
  (`save_loader.gd:132-136`).
- Sin backup válido → `LoadResult.CORRUPTED` (`save_loader.gd:137-138`).

**Nivel 2 — Completado con defaults y migración** (`save_loader.gd:54-78`):
- `SaveSchema.completar()` (`save_schema.gd:167-174`) rellena secciones de
  nivel superior que falten con sus defaults antes de validar, para que un
  save antiguo no resulte `CORRUPTED` por una sección nueva.
- La **versión futura** se rechaza sin tocar el archivo
  (`FUTURE_VERSION`, `save_loader.gd:67-73`), con aviso claro para actualizar
  el juego. La **migración** hacia delante crea backup manual previo
  (`save_loader.gd:77`) y hoy es un pass-through en v1
  (`save_loader.gd:143-147`).

Resultados posibles (`save_loader.gd:15-23`): `OK`, `NOT_FOUND`,
`CORRUPTED`, `RECOVERED`, `FUTURE_VERSION`, `PROFILE_MISMATCH`, `EMPTY_SLOT`.
Existe además un sello anti-cruzamiento: `load_slot()` rechaza slots de otro
perfil activo (`save_manager.gd:267-279`, `PROFILE_MISMATCH`).

**Cobertura de pruebas:** `validate_save.gd` prueba detección de checksum
(`_test_checksum_detection`, líneas 96-114) y recuperación desde backup
(`_test_backup_recovery`, líneas 116-142); `test_autosave_m59.gd` cubre los
disparadores y el camino feliz. La rotación devuelve `false` si algún rename
falla (BUG-112, `save_backup.gd:24-45`), lo que hace visibles los fallos en
disco.

## 5. Mejoras sugeridas

1. **Validación estructural antes de escribir el auto-save (guardar solo si `validate()` pasa).**
   Hoy el guardar no ejecuta `SaveSchema.validate()` sobre el payload: un
   payload con secciones inválidas se escribe, firma y pasa la verificación
   interna del `.tmp` (el HMAC valida el formato, no la estructura). El error
   solo aparecería al cargar. Recomendación: en `_process_queue()`
   (`save_manager.gd:211-249`), tras `_payload_para_slot()`, pasar el payload
   por `SaveSchema.validate()`; si hay errores, abortar el guardado, emitir
   `save_failed` y registrar el detalle en el log, conservando el save
   anterior. Esto mueve la detección del momento de carga al momento de
   escritura, donde aún se puede descartar el payload inválido sin perder
   nada.

2. **Cola de cierre y sello de escritura pendientes (evitar la ventana de pérdida al cerrar).**
   Hoy, si `_writing` es verdadero al solicitarse el cierre, el guardado de
   cierre se omite (`save_manager.gd:138-140`) y el estado intermedio se
   pierde. Recomendación: al recibir `NOTIFICATION_WM_CLOSE_REQUEST` con
   `_writing == true`, en vez de omitir, **terminar la escritura en curso
   de forma bloqueante** (esperar al resultado de `write_atomic()` /
   `SaveWriter` sincrónico en ese slot) antes de dejar que el árbol cierre,
   o encolar un `request_save()` sincrono con prioridad y bloquear el cierre
   hasta procesarlo. Esto elimina la única ventana actual de pérdida de
   progreso entre el último auto-save y el cierre de la ventana, sin romper
   la garantía de no intercalar escrituras.

## Conclusión final

El sistema de auto-save de Isla Ancestral (M59, más checkpoints M66 y M26) es
**sólido y maduro**: cuatro disparadores reales (temporizador 300 s, cambio
de día, misión completada, evento finalizado) convergen en una cola
secuencial que rota el backup **antes** de escribir; la escritura es atómica
(tmp → verificación → rename) con HMAC-SHA256 y cap anti-OOM; la carga
valida checksum, estructura y versión, y **recupera desde hasta 2 backups**
(`RECOVERED`), rechazando versiones futuras sin degradar. Los bugs históricos
más graves (orden de rotación, save vacío por proveedor roto, validación
`int` vs `float` de JSON) ya están corregidos y cobiertos por suites
headless. Le quedan dos frentes accionables: validar estructura **antes** de
escribir el auto-save y cerrar la ventana de pérdida de progreso al cerrar la
ventana durante una escritura en curso. Todo lo demás —atomicidad, rotación,
recuperación, perfiles, migración— está implementado y probado.
