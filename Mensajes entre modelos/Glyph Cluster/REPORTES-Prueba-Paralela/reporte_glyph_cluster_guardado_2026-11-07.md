# Reporte — Sistema de guardado/carga (M59)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code / Agent Manager  
**Fecha:** 2026-11-07  
**Alcance:** `game/isla-ancestral/scripts/saving/` + contratos relacionados (`scripts/interfaces/i_saveable.gd`)  
**Autoload:** `SaveManager="*res://scripts/saving/save_manager.gd"` (`game/isla-ancestral/project.godot:30`)

Archivos núcleo analizados:
- `game/isla-ancestral/scripts/saving/save_manager.gd`
- `game/isla-ancestral/scripts/saving/save_snapshot.gd`
- `game/isla-ancestral/scripts/saving/save_provider.gd`
- `game/isla-ancestral/scripts/saving/save_loader.gd`
- `game/isla-ancestral/scripts/saving/save_writer.gd`
- `game/isla-ancestral/scripts/saving/save_backup.gd`
- `game/isla-ancestral/scripts/saving/save_schema.gd`
- `game/isla-ancestral/scripts/saving/player_save_provider.gd`
- `game/isla-ancestral/scripts/interfaces/i_saveable.gd`

## 1) ¿Cómo se serializan y deserializan los datos?

### Formato de documento (determinista)
- `SaveWriter.build_file_content()` arma el archivo como `token\npayload_json` (`save_writer.gd:147-148`). El token de integridad se calcula sobre el **payload literal serializado** (no se re-serializa al verificar), lo que evita indeterminismo.
- Archivos por slot: `user://saves/slot_N.save` (final) y `slot_N.tmp` (temporal) (`save_writer.gd:26-29,195-196,238-239`).

### Serialización (guardar)
- **Payload:** `SaveWriter.serialize_payload()` usa `JSON.stringify(payload)` (`save_writer.gd:142-143`).
- **Construcción del snapshot:** `SaveSnapshot.collect(profile_id)` parte de `SaveSchema.default_payload()` (schema estable con secciones presentes aunque vacías) y reemplaza cada sección con el dato del proveedor registrado (`save_snapshot.gd:46-63`; `save_schema.gd:39-106`).
- **Contrato de proveedores:** `ISaveProvider` define `get_section_name/get_save_data/restore_save_data` (`save_provider.gd:20-35`). Los proveedores se registran en `SaveManager.register_provider()` → `SaveSnapshot.register_provider()` (`save_manager.gd:176-180`; `save_snapshot.gd:27-33`). Acepta duck-typing (autoloads Node).
- **Metadatos sellados por el manager:** `SaveManager._payload_para_slot()` recolecta y sella `meta.last_saved` y `meta.profile_id` (ningún proveedor emite `meta`) (`save_manager.gd:194-208`).
- **Escritura atómica:** `SaveWriter.write_atomic(slot, payload)` valida rango `1..SLOT_COUNT`, asegura `user://saves`, escribe a `.tmp`, comprueba que `store_string` tuvo éxito, verifica el `.tmp` con `parse_document()` y solo entonces hace `DirAccess.rename_absolute(tmp -> save)` (`save_writer.gd:180-222`). Regla dura: nunca escribir sobre el save actual.

### Deserialización (cargar)
- **Lectura acotada:** `SaveWriter.read_document()` verifica existencia/tamaño **antes** de leer; rechaza > 2 MB (`save_writer.gd:31-67`).
- **Parseo:** `SaveWriter.parse_document()` separa token/payload, verifica integridad, hace `JSON.parse_string()` y exige `Dictionary`; expone `legacy` si el token no tiene prefijo HMAC (`save_writer.gd:163-176`).
- **Flujo de `SaveLoader.load(slot)`:** lee principal; si falta y hay backup intenta recuperación; parsea/verifica; normaliza `schema_version` a `int` (JSON devuelve números como `float`); completa secciones faltantes con defaults (`SaveSchema.completar`, sin tocar interior de secciones para no romper dialectos de proveedores); valida estructura; rechaza versión futura; migra solo hacia delante si versión < actual (con backup manual previo); restaura sistemas vía `SaveSnapshot.restore()` (`save_loader.gd:29-88`).
- **Restauración:** `SaveSnapshot.restore()` llama `restore_save_data()` solo si existe proveedor y la sección es `Dictionary`; tolera secciones sin proveedor (`save_snapshot.gd:65-72`).
- **Ejemplo concreto:** `PlayerSaveProvider` guarda/restaura posición y, por duck-typing, `spawn_position/zone` solo si el nodo las expone; no asigna `name` (evita renombrar el nodo) (`player_save_provider.gd:44-83`).

## 2) ¿Hay validación de integridad de datos guardados?

Sí, en varias capas:

- **Integridad del documento (token):** `SaveWriter.verificar_checksum()` verifica **HMAC-SHA256 con clave por instalación** (`hmac256:<hex>`). La clave se genera/carga desde `user://clave_integridad.key` (hex, 32 bytes) con caché en memoria (`save_writer.gd:38-53,84-109,120-139`). **Retrocompatibilidad:** acepta SHA-256 legado sin prefijo (saves previos al fix) (`save_writer.gd:74-82,136-139,176`). La carga rechaza si no coincide (`save_loader.gd:42-45`).
- **Límite de tamaño antes de cargar a memoria:** cap `MAX_DOCUMENT_BYTES = 2 MB` aplicado antes de leer, independiente del token (`save_writer.gd:31-37,56-67`).
- **Validación estructural/tipos/rangos:** `SaveSchema.validate()` exige `schema_version` entero semántico `>= 1`, `profile_id` presente y `String`, secciones requeridas como `Dictionary`, validación de reloj `time` en **ambos dialectos** (real M29: `hora/minuto/dia/mes/anio/acumulador` y schema: `day/season/hour/minute`), tipos/rangos de `meta.last_saved`/`meta.playtime_seconds`. Tolera `int`/`float` por el comportamiento de `JSON.parse_string()` (`save_schema.gd:108-129,131-152,194-267`).
- **Versión futura:** rechazada sin degradar (`SaveLoader.LoadResult.FUTURE_VERSION`) tanto en save principal como en backups (`save_loader.gd:65-73,122-127`).
- **Anti-cruzamiento de perfiles:** `SaveManager.load_slot()` lee `meta.profile_id` sin restaurar y rechaza con `PROFILE_MISMATCH` si difiere del perfil activo; saves legacy sin sello o sin perfil activo se permiten (`save_manager.gd:255-279,319`).
- **Rango de slots (defensa en profundidad):** fuente única `SaveSchema.SLOT_COUNT`/`slot_valido()` aplicada en writer/cleanup/manager (`save_schema.gd:23-34`; `save_writer.gd:184-186,226-228`; `save_manager.gd:22,183-189,268-269`).
- **Validación del `.tmp` antes del rename:** `write_atomic()` parsea el contenido escrito y solo renombra si `parse_document().ok` (`save_writer.gd:210-222`).

**Matices/limitaciones:**
- La integridad **no es a prueba de manipulación local**: la clave HMAC vive en `user://` y el SHA-256 legado sigue aceptándose; un atacante con acceso al FS podría recalcular el legado (limitación documentada en `save_writer.gd:153-163`). El HMAC sí detecta corrupción/alteraciones no reproducidas por el algoritmo público en saves nuevos.
- La validación profunda es principalmente de estructura/tipos/rangos globales; no hay validación de invariantes de dominio por sección/proveedor (más allá de “sección es `Dictionary`” y reglas de `time/meta` en schema). `scripts/interfaces/i_saveable.gd` define `validate_save_data()`, pero no está integrado al flujo de `SaveManager/SaveSnapshot`.

## 3) ¿Hay manejo de errores en carga/guardado?

Sí, es robusto y con múltiples correcciones históricas documentadas:

- **Escritura segura:** atómica vía `.tmp` + verificación + `rename_absolute`; si falla escritura/verificación/rename, el save anterior queda intacto (`save_writer.gd:198-222`).
- **Serialización de escrituras y estado:** cola `_queue`, flag `_writing`, bloqueo `_blocked` (diálogo/minijuego), señales `save_completed/save_failed/slot_loaded/auto_save_skipped` (`save_manager.gd:15-19,27-35,170-174,183-193,210-249`).
- **Orden backup → escritura (bug crítico corregido):** `SaveBackup.rotate()` mueve el save anterior a `.bak` **antes** de `write_atomic()`; si la escritura falla, el anterior queda íntegro en backup y el loader puede recuperarlo (`save_manager.gd:222-246`). En cierre de ventana (`NOTIFICATION_WM_CLOSE_REQUEST`) replica el flujo síncrono y omite si `_writing` para no intercalar (`save_manager.gd:129-150`).
- **Rotación con errores visibles:** `SaveBackup.rotate()` ya no descarta el retorno de `rename_absolute`; loguea fallos y devuelve `false`. El manager advierte pero prioriza guardar el progreso (`save_backup.gd:24-45`; `save_manager.gd:236-238,142-143`).
- **Recuperación ante corrupción/ausencia del principal:** si no existe `.save` pero hay backups, o si el documento es inválido/corrupto, `SaveLoader._try_recover()` prueba **todas** las rotaciones `r1..rN` en orden de frescura, aplica el mismo rigor (parseo, normalización, `completar`, validación, rechazo de versión futura sin degradar a rotaciones viejas) y devuelve `RECOVERED/CORRUPTED/FUTURE_VERSION` (`save_loader.gd:31-138`; lectura por `SaveBackup.read_backup` con cap de tamaño, `save_backup.gd:72-85`).
- **Tolerancia a proveedores defectuosos:** `SaveSnapshot.collect()` captura fallos de `get_save_data()`/tipos no `Dictionary` por sección (usa `Variant` + chequeo), omite la sección con `push_error` y **no aborta** todo el save (`save_snapshot.gd:37-63`). `restore()` tolera secciones faltantes o sin proveedor (`save_snapshot.gd:65-72`).
- **Compatibilidad/defensas de datos:** `SaveSchema.completar()` añade secciones de nivel superior faltantes sin tocar interior (evita romper dialectos/proveedores) (`save_schema.gd:153-174`); `_es_entero()` tolera `float` entero por JSON (`save_schema.gd:108-129`); `dia_de()` traduce dialectos `dia/day` (`save_schema.gd:176-189`).
- **Limpieza operativa:** eliminación de `.tmp` huérfanos al arrancar (`save_manager.gd:327-329`; `save_writer.gd:224-231`).
- **Límites y fallas seguras:** si `HMACContext.start` falla, `firmar_payload()` devuelve `""` y el documento no superará verificación (`save_writer.gd:124-131,210-214`). Cap de tamaño evita lecturas desmedidas (`save_writer.gd:31-67`). Migraciones reales aún no implementadas (v1 sin transformaciones; infraestructura lista, `save_loader.gd:140-147`).

## 4) ¿Hay dependencias circulares en el sistema de persistencia?

**No se observan dependencias circulares directas** en el núcleo `scripts/saving/`.

- Grafo acíclico en la práctica: `SaveManager` (autoload, `extends Node`) orquesta `SaveSnapshot`, `SaveLoader`, `SaveWriter`, `SaveBackup`, `SaveSchema` (`save_manager.gd:1,37-40,194-249,280-288`). `SaveLoader` usa `SaveWriter/SaveBackup/SaveSchema/SaveSnapshot` (`save_loader.gd:29-147`). `SaveSnapshot` usa `SaveSchema` y llama métodos del contrato de proveedores (`save_snapshot.gd:46-72`). `SaveBackup` usa `SaveWriter/SaveSchema` (`save_backup.gd:24-88`). `SaveWriter` usa `SaveSchema` (`save_writer.gd:56-239`).
- No hay `preload/load` cruzado entre módulos de `saving/`; usan `class_name`/referencias estáticas.
- Integración externa desacoplada por señales: dirty/auto-save/bloqueos se conectan vía `EventBus` (y conexión opcional por `has_signal` a `EventManager`), evitando acoplar `SaveManager` a sistemas como `Fishing` (corrección BUG-116 documentada, `save_manager.gd:73-106`).

**Observaciones (acoplamiento/duplicidad, no ciclos):**
- Coexisten **dos contratos paralelos**: `ISaveProvider` (`save_provider.gd`, `RefCounted`, integrado a `SaveManager/SaveSnapshot`) e `ISaveable` (`scripts/interfaces/i_saveable.gd`, `Resource`, API distinta: `get_save_id/load_save_data(version)/validate_save_data/has_unsaved_changes`). No están conectados entre sí.
- Divergencia de dialectos por sección (p.ej. `time`: `dia/mes/anio` vs `day/season`) obliga a compatibilidad centralizada en schema/manager (`save_schema.gd:176-189,224-245`; `save_manager.gd:308-314`).

## 5) Dos mejoras concretas de diseño

### Mejora 1 — Unificar contrato de persistencia y migración/versionado por sección
**Problema:** coexisten `ISaveProvider` (usado por el core) e `ISaveable` (no integrado, con capacidades útiles como `validate_save_data`, `get_save_version`, dirty flag). Además, los dialectos de datos de proveedores (p.ej. `time`) se resuelven con lógica especial en `SaveSchema`/`SaveManager`, y la migración global en `SaveLoader._migrate()` es un placeholder.

**Propuesta concreta:**
- Definir un **contrato canónico** (o hacer de `ISaveProvider` el canónico y crear un **adaptador** para `ISaveable`) que incluya: `section_id`, `section_version`, `export_save() -> Dictionary`, `import_save(data, version)`, `validate(data) -> Array[String]`, y opcionalmente `migrate(data, from_version)`.
- En `SaveSnapshot.collect/restore`, ejecutar `validate` por proveedor antes de persistir/aplicar; si falla, degradar con `push_error` por sección (manteniendo la tolerancia actual).
- Mover la migración al **nivel de sección** (aprovechando la infraestructura de `SaveLoader._migrate`, `save_loader.gd:140-147`) y registrar la versión de sección en el payload/meta. Esto permitiría reconciliar dialectos (`dia/day`) dentro del proveedor o su migrador, eliminando traducciones centrales como `SaveSchema.dia_de()` (`save_schema.gd:176-189`).
- Resultado: menos acoplamiento del core a proveedores concretos, menos duplicidad de contratos y migraciones seguras “hacia delante” por dominio.

### Mejora 2 — Endurecer integridad: contexto firmado y migración transparente de saves legados
**Problema:** el HMAC actual protege el payload, pero no vincula explícitamente el **contexto** (`slot`, `profile_id`, `schema_version`) y el sistema mantiene aceptación de SHA-256 legado; la clave vive en `user://` junto a los saves (limitación documentada en `save_writer.gd:49,153-163,136-139`). Esto deja una ventana de “recalcular SHA-256 y pasa” para atacantes con acceso local al FS.

**Propuesta concreta:**
- **Firmar contexto además del payload:** incluir en el material firmado una cabecera canónica (p.ej. `slot|profile_id|schema_version|payload_str`) o verificar coherencia estricta post-parseo, de modo que un payload válido no pueda reusarse en otro slot/perfil sin detección.
- **Migración transparente de integridad:** cuando `parse_document()` devuelva `ok && legacy == true`, tras una carga/restauración exitosa y con backup previo, re-escribir el slot en formato `hmac256` (manteniendo la regla de no degradar datos). Opcional: política configurable (aceptar legado / solo leer / forzar re-firma).
- **Gestión de clave:** conservar la clave fuera de `user://saves` (ya está en raíz `user://`) y documentar/implementar un flujo de recuperación (p.ej. regeneración invalida solo HMAC, conservando datos; o rotación controlada). Si en el futuro hay plataforma con keystore/secret store, abstraer `_cargar_o_generar_clave()`.
- Complemento: integrar `validate_save_data()` (u equivalente por proveedor) antes de `write_atomic()` para detectar corrupción lógica temprana, sin romper la tolerancia de `collect()`.

## Conclusión
El sistema M59 implementa un pipeline de persistencia maduro para Godot 4.x: JSON determinista con `token\npayload`, escritura atómica `.tmp`→`.save`, backups rotados, recuperación multi-rotación, validación estructural/tolerancia de dialectos, anti-cruzamiento de perfiles y manejo de errores defensivo. Las brechas principales son de **gobierno de contratos/versionado por sección** (dos interfaces no unificadas, migración por proveedor ausente) y de **endurecimiento de integridad contextual/migración de legados**, ambas abordables sin romper compatibilidad ni la regla de “nunca degradar un save”.
