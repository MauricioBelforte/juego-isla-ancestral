# Reporte Crouton Alpha — Sistema de Guardado/Carga (2026-11-08)

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08

## Archivos analizados

Núcleo del sistema (9 archivos):
- `game/isla-ancestral/scripts/saving/save_manager.gd` (329 líneas)
- `game/isla-ancestral/scripts/saving/save_loader.gd` (147 líneas)
- `game/isla-ancestral/scripts/saving/save_writer.gd` (239 líneas)
- `game/isla-ancestral/scripts/saving/save_snapshot.gd` (80 líneas)
- `game/isla-ancestral/scripts/saving/save_schema.gd` (267 líneas)
- `game/isla-ancestral/scripts/saving/save_provider.gd` (35 líneas)
- `game/isla-ancestral/scripts/saving/save_backup.gd` (88 líneas)
- `game/isla-ancestral/scripts/saving/validate_save.gd` (170 líneas, QA headless)
- `game/isla-ancestral/scripts/saving/player_save_provider.gd` (83 líneas)

## (1) Serialización y deserialización

### Serialización — `save_writer.gd`

- **Formato JSON:** `serialize_payload()` (líneas 142-143) usa `JSON.stringify(payload)`. El payload es un `Dictionary` construido por `SaveSnapshot.collect()` (`save_snapshot.gd:46-63`) que junta `SaveSchema.default_payload()` con secciones de proveedores.
- **Envoltura determinista:** `build_file_content()` (líneas 147-148) produce `token\npayload_str`, donde `token` es HMAC-SHA256 (`firmar_payload()`, líneas 124-131) con clave por instalación de 32 bytes (`_cargar_o_generar_clave()`, líneas 91-109, almacenada en `user://clave_integridad.key`, `KEY_PATH` línea 49). La firma se calcula sobre el string literal, por lo que re-serializar no introduce indeterminismo (comentario líneas 11-15).
- **Escritura atómica:** `write_atomic()` (líneas 180-222) escribe a `slot_N.tmp`, verifica que el `.tmp` parsea (`parse_document()`, líneas 210-214) y luego `DirAccess.rename_absolute()` lo mueve a `slot_N.save` (líneas 217-220). Regla dura documentada líneas 6-9: nunca escribir sobre el save actual.
- **Cap anti-DoS:** `read_document()` (líneas 56-67) rechaza documentos > 2 MB (`MAX_DOCUMENT_BYTES`, línea 36, BUG-109) antes de cargarlos a memoria.

### Deserialización — `save_writer.gd:parse_document()` + `save_loader.gd:load()`

1. `parse_document()` (líneas 163-176): separa línea 1 (token) y resto (JSON), verifica token con `verificar_checksum()` (líneas 135-139) y parsea con `JSON.parse_string()`. Devuelve `{ok, reason, checksum, payload_str, payload, legacy}`.
2. `save_loader.load()` (`save_loader.gd:29-88`): normaliza `schema_version` a int (líneas 52), completa secciones faltantes con `SaveSchema.completar()` (línea 58), valida con `SaveSchema.validate()` (línea 61), rechaza versiones futuras (líneas 67-73) y migra hacia adelante si aplica (líneas 76-78, con `_migrate()` líneas 143-147).
3. `SaveSnapshot.restore()` (`save_snapshot.gd:68-72`): iteración tolerante sobre proveedores registrados; secciones sin proveedor se ignoran.

Detalle clave: JSON no preserva int vs float (`save_schema.gd` líneas 108-125). Por eso `_es_entero()` acepta floats con valor entero y `save_loader.gd:52` normaliza el tipo. Es el fix documentado de un falso CORRUPTED masivo (M59 iter. 1).

## (2) Validación de integridad

- **HMAC-SHA256 con clave por instalación** (BUG-115, `save_writer.gd:17-23, 124-139`): nuevos saves se firman con clave en `user://`. Comparación en tiempo constante (`_igualdad_constante()`, líneas 112-118). Firma vía `HMACContext` (líneas 126-131). Los saves LEGADOS con SHA-256 en claro (sin prefijo `hmac256:`) se aceptan por retrocompatibilidad (`verificar_checksum()` línea 139, `parse_document()` línea 176) — el propio comentario (líneas 154-162) admite que esto no protege contra manipulación local, solo detecta corrupción no reproducida por algoritmo público.
- **Contenido vacío:** `parse_document()` rechaza contenido vacío (línea 164-165) y formato sin `\n` (líneas 167-168).
- **Estructura:** `SaveSchema.validate()` (`save_schema.gd:194-267`) valida presencia de `schema_version`/`profile_id`, tipo String de `profile_id` (líneas 207-210, fix BUG-115), presencia de las 14 secciones requeridas, rangos del reloj de juego en ambos dialectos (líneas 235-253) y tipos de `meta` (líneas 257-265), incluyendo cotas de sanidad `MAX_CLOCK_ACUMULADOR` (línea 30).
- **Verificación pre-rename:** el `.tmp` se re-parsea antes de promoverse a `.save` (`save_writer.gd:211-214`).
- **Tamaño:** cap de 2 MB pre-lectura (`save_writer.gd:64-66`).

## (3) Manejo de errores en carga/guardado

- **Escritura:** `write_atomic()` devuelve `bool` y reporta cada fallo con `printerr`/`push_error` (creación de directorio líneas 190-192, apertura `.tmp` líneas 199-201, `store_string` líneas 206-208 — nota que `store_string` devuelve bool desde Godot 4.4+, líneas 202-203, rename líneas 218-220). Validación de rango de slot (BUG-114) en líneas 184-186. La cola de `SaveManager` emite `save_failed` ante fallo (`save_manager.gd:244-246`) y el guardado de cierre también (`save_manager.gd:148-149`).
- **Backup previo:** `SaveManager._process_queue()` rota ANTES de escribir (`save_manager.gd:236-237`); si la rotación falla, se loguea como warning pero la escritura continúa (líneas 233-237, BUG-112). `SaveBackup.rotate()` (`save_backup.gd:24-45`) propaga el fallo con `push_error` por cada rename.
- **Proveedor roto:** `SaveSnapshot.collect()` (`save_snapshot.gd:53-61`) trata el retorno como `Variant` a propósito (BUG-111-bis) para que un proveedor que devuelva null/no-Dictionary no aborte todo el save; se omite con `push_error` y el resto se guarda. Antes ese bug escribía un save vacío en silencio.
- **Carga con recuperación:** `SaveLoader.load()` ante fallo de checksum/estructura intenta backups en `_try_recover()` (`save_loader.gd:98-138`), que prueba TODAS las rotaciones en orden de frescura (BUG-110) y es tan estricto como el principal (valida y rechaza versiones futuras sin degradar, líneas 116-127, fix iter. 2). Devuelve `LoadResult` enumerado (`OK, NOT_FOUND, CORRUPTED, RECOVERED, FUTURE_VERSION, PROFILE_MISMATCH, EMPTY_SLOT`, líneas 15-23).
- **Slots:** rango validado en `SaveManager.request_save()` (`save_manager.gd:187-189`) y `load_slot()` (líneas 268-269), con defensa en profundidad en `SaveWriter` (BUG-114). `_process_init_cleanup()` (`save_manager.gd:327-329`) limpia `.tmp` huérfanos al arrancar.
- **Guardado de cierre:** `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` (`save_manager.gd:129-150`) replica rotación + escritura síncrona y omite si hay escritura en curso (líneas 138-140, BUG-113).
- **Anti-cruzamiento de perfiles:** `load_slot()` (`save_manager.gd:267-288`) lee el sello `profile_id` sin restaurar y rechaza con `PROFILE_MISMATCH` si el perfil activo difiere; saves legacy sin sello cargan sin restricción (líneas 270-279).

## (4) Dependencias circulares

**Veredicto: no hay dependencia circular entre los archivos del módulo `saving/`.** La cadena es un DAG dirigido: `SaveManager` → `SaveSnapshot`/`SaveLoader`/`SaveWriter`/`SaveBackup`; `SaveLoader` → `SaveSchema`/`SaveWriter`/`SaveBackup`/`SaveSnapshot`; `SaveWriter` → `SaveSchema`; `SaveSnapshot` → `SaveSchema`. Ninguno de estos apunta de vuelta a `SaveManager` desde el código productivo (solo referencias en comentarios, p. ej. `save_loader.gd:71` menciona la señal de `SaveManager` pero no la llama).

Acoplamientos conocidos, no circulares:

1. **SaveManager → EventBus / EventManager / DataStore:** conexiones dinámicas vía `get_node_or_null("/root/...")` (`save_manager.gd:74, 94, 205, 273`). El propio código documenta que se eliminó la arista directa a `FishingManager` (BUG-069) para ir por el bus (`save_manager.gd:97-102`). Si EventBus no existe, se degrada con warning (`save_manager.gd:75-77`).
2. **Dialecto dual de `time`:** `SaveSchema` valida ambos dialectos (M29 `hora/minuto/dia/mes/anio/acumulador` y schema `day/season/hour/minute`, `save_schema.gd:226-253`) y `dia_de()` (`save_schema.gd:185-189`) es la única traducción. Es deuda deliberada entre módulos (M14/M29/M38, Log 1202 citado en `save_manager.gd:308-313`), no ciclo.
3. **Duck-typing de proveedores:** el registro (`save_manager.gd:179-180`, `save_snapshot.gd:27-33`) no exige el tipo `ISaveProvider` porque los proveedores reales son autoloads `Node`. Esto crea un acoplamiento implícito de contrato, pero no una referencia circular en código.
4. **Dos dueños de `meta`:** los proveedores no emiten `meta`; el manager sella `last_saved` y `profile_id` en `_payload_para_slot()` (`save_manager.gd:200-208`). No es ciclo, pero sí doble responsabilidad sobre el payload.

## (5) Dos mejoras concretas de diseño

**Mejora A — Versionado por secciones con migraciones por sección.** Hoy solo hay `schema_version` global y la migración es un no-op (`save_loader.gd:143-147`: "v1 es la primera, sin migraciones por ahora"). Con 14 secciones y proveedores de módulos distintos (M14 inventario, M29 tiempo, M38, etc.), cada sección debería llevar `sect_version` propia en su dict y `SaveSchema` registrar reglas `migracion(seccion, desde, hasta)`. Así un cambio en el inventario no obliga a migrar el tiempo, y la deuda de dialectos (Log 1202) se resuelve migrando secciones en lugar de validando dos dialectos a la vez (`save_schema.gd:226-253`).

**Mejora B — Guardado asíncrono por fragmentos con journaling.** La escritura es síncrona (`save_writer.gd:198-220`) y el comentario en `save_manager.gd:134-137` admite que el camino de cierre respeta `_writing` de forma defensiva ante "el async declarado de M61". El pre-chequeo de cancelación al cerrar (`save_manager.gd:138-140`) descarta el save si una escritura está en curso. Una cola con `threading` real + diario (write-ahead log por sección) eliminaría esa ventana de pérdida: cada sección se escribiría a su propio journal y el commit sería un solo rename. Además se movería fuera del `_process()` del frame (`save_manager.gd:157-165`), evitando el hitch del auto-save temporizado.

## Conclusión final

El sistema de guardado del Módulo 59 es un pipeline bien ordenado (4.6 KB típicos, atómico, checksum con HMAC + legado SHA-256, backups r1/r2 con recuperación estricta, cola serializada, dirty-tracking por EventBus) con un historial raro de bugs reales corregidos y documentados (BUG-109/110/111/112/113/114/115/116, más los de M59 iter. 1/2/3). No hay dependencias circulares dentro del módulo; los acoplamientos residuales son externos y acotados (EventBus/DataStore por `get_node_or_null`, duck-typing de proveedores, dialecto dual de `time` como deuda registrada). Las dos mejoras propuestas (migraciones por sección y escritura asíncrona con journaling) son incrementales y no rompen el contrato actual: el formato `token\npayload` y el protocolo `ISaveProvider` se mantienen.
