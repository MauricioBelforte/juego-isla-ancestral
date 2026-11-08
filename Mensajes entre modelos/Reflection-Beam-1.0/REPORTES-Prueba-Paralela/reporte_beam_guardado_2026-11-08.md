**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code

# Reporte de Análisis — Sistema de Guardado/Carga (isla-ancestral)

**Fecha:** 2026-11-08
**Ruta analizada:** `game/isla-ancestral/scripts/saving/` y dependencias en `scripts/`
**Archivos clave:** `save_manager.gd`, `save_writer.gd`, `save_loader.gd`, `save_backup.gd`, `save_schema.gd`, `save_snapshot.gd`, `save_provider.gd`, `player_save_provider.gd`

---

## 1. Serialización y deserialización de datos

- **Serialización:** `SaveWriter.serialize_payload()` usa `JSON.stringify(payload)` (línea ~120 de `save_writer.gd`). El payload es un `Dictionary` recolectado por `SaveSnapshot.collect()` (`save_snapshot.gd`), que parte de `SaveSchema.default_payload()` y sobrescribe cada sección con el `get_save_data()` del proveedor registrado.
- **Formato de archivo:** `token\npayload` (`SaveWriter.build_file_content`, línea ~130). Línea 1 = token de integridad; líneas 2+ = JSON del payload. La escritura es **atómica**: se escribe a `slot_N.tmp`, se verifica internamente con `parse_document`, y se renombra con `DirAccess.rename_absolute` a `slot_N.save` (`write_atomic`, líneas ~150-185).
- **Deserialización:** `SaveLoader.load()` (`save_loader.gd`):
  1. `SaveWriter.read_document()` con cap `MAX_DOCUMENT_BYTES` (2 MB).
  2. `SaveWriter.parse_document()` valida el token y parsea JSON.
  3. `SaveSchema.completar()` rellena secciones faltantes con defaults.
  4. `SaveSchema.validate()` valida estructura/tipos.
  5. Verificación de versión (`FUTURE_VERSION` si `version > SCHEMA_VERSION`).
  6. Migración solo hacia delante (`_migrate`).
  7. `SaveSnapshot.restore(payload)` restaura cada sistema registrado.
- **Backups:** `SaveBackup.rotate()` rota el save anterior a `slot_N_r1.bak`/`r2.bak` (max 2) **antes** de escribir (orden corregido por BUG crítico documentado). Recuperación prueba todas las rotaciones en orden de frescura (`_try_recover`, `save_loader.gd`).

## 2. Validación de integridad de datos guardados

- **Checksum/HMAC:** `SaveWriter` firma el payload con **HMAC-SHA256** con clave por instalación (`firmar_payload`, `_cargar_o_generar_clave`). La clave vive en `user://clave_integridad.key` (fuera de `SAVE_DIR` para sobrevivir a borrados de pruebas). Comparación en tiempo constante (`_igualdad_constante`).
- **Retrocompatibilidad:** token sin prefijo `hmac256:` se interpreta como SHA-256 legado y se acepta (`verificar_checksum`). Esto permite cargar saves antiguos pero debilita la protección frente a manipulación local (documentado como limitación deliberada).
- **Validación estructural:** `SaveSchema.validate()` valida `schema_version`, `profile_id` (String), secciones requeridas como Dictionary, rangos del reloj (`hora 0..23`, `minuto 0..59`, etc.), `meta.last_saved` String, `playtime_seconds` no negativo.
- **Cap de tamaño:** `MAX_DOCUMENT_BYTES = 2 MB` aplicado antes de leer (BUG-109).
- **Anti-cruzamiento de perfiles:** `SaveManager.load_slot()` rechaza slots sellados con un `profile_id` distinto al activo (`PROFILE_MISMATCH`).
- **Versión futura:** saves con `schema_version > SCHEMA_VERSION` se rechazan sin degradarlos (`FUTURE_VERSION`).

## 3. Manejo de errores en carga/guardado

- **Escritura:** `write_atomic` devuelve `bool`; verifica `store_string` (Godot 4.4+), re-verifica el `.tmp` con `parse_document` antes del rename, y maneja errores de `DirAccess`.
- **Cola serializada:** `SaveManager._process_queue()` procesa una escritura a la vez (`_writing`), evitando concurrencia. Al cerrar la ventana, `_notification(WM_CLOSE_REQUEST)` replica el camino de forma síncrona respetando `_writing`.
- **Proveedores rotos:** `SaveSnapshot.collect()` captura proveedores que devuelven no-Dictionary o lanzan (BUG-111-bis), omitiendo la sección sin abortar todo el save.
- **Recuperación:** `_try_recover` prueba todas las rotaciones r1..rN; si todas fallan devuelve `CORRUPTED`.
- **Limpieza:** `_process_init_cleanup()` borra `.tmp` huérfanos al arrancar.
- **Señales:** `save_completed` / `save_failed` / `slot_loaded` notifican a la UI; `auto_save_skipped` cuando está bloqueado.
- **Bloqueo:** `set_save_blocked()` desactiva guardado durante diálogos/minijuegos (conectado vía EventBus, no directamente a sistemas — evita aristas SaveManager→Fishing, BUG-069).

## 4. Dependencias circulares en el sistema de persistencia

- **No hay ciclos directos** entre los módulos de persistencia: la cadena es lineal `SaveSchema → SaveWriter → SaveBackup → SaveLoader → SaveSnapshot → SaveManager`.
- **Acoplamiento en runtime vía autoloads:** `SaveManager` obtiene `EventBus`, `EventManager` y `DataStore` con `get_node_or_null("/root/...")` (líneas 73-105, 205, 273). Estos autoloads registran proveedores en `SaveManager` (llamando a `/root/SaveManager.register_provider`), lo que crea una dependencia indirecta SaveManager↔servicios mediada por el árbol de escena, no por `class_name`. No es un ciclo de compilación, pero sí un acoplamiento implícito que dificulta testear en aislamiento (los tests headless deben montar los autoloads).
- **SaveManager ↔ PlayerSaveProvider:** `PlayerSaveProvider` busca el nodo "Player" en el árbol en cada llamada (búsqueda perezosa), sin referencia directa al manager; sin ciclo.
- **SaveLoader.snapshot** se asigna por `SaveManager._ready()` (línea 54), inyectando la dependencia; `SaveLoader` no instancia `SaveSnapshot` por sí mismo.

## 5. Sugerencias de diseño (2 mejoras concretas)

1. **Eliminar la aceptación del checksum legado (SHA-256 sin secreto) en saves nuevos y migrar.** Hoy `verificar_checksum` acepta tokens sin prefijo `hmac256:`; esto permite que un atacante recalcule el checksum tras editar el payload (limitación documentada). Propuesta: al cargar un save legado, re-firmarlo con HMAC y reescribirlo (migración de integridad) o, como mínimo, marcarlo `legacy: true` y forzar re-guardado. Esto cierra la ventana de tampering documentada en `save_writer.gd` (comentario de `parse_document`).

2. **Inyectar dependencias (EventBus/DataStore/EventManager) por constructor/registro en lugar de `get_node_or_null("/root/...")`.** Esto desacopla `SaveManager` de los autoloads concretos, facilita tests unitarios sin árbol de escena y elimina el riesgo de orden de inicialización (autoloads que se registran antes de que `SaveManager._ready()` corra). Además, unificar los dos dialectos de tiempo (`dia/mes/anio` vs `day/season/hour`) en el proveedor M29, eliminando el helper `SaveSchema.dia_de` y el deuda documentada en `save_manager.gd:308-313`.

---

## Conclusión final

El sistema de persistencia es **robusto y bien diseñado**: escritura atómica con verificación interna, HMAC con clave por instalación, recuperación desde múltiples rotaciones, validación estructural y de versión, anti-cruzamiento de perfiles, y manejo defensivo de proveedores fallidos. Las principales deudas son la retrocompatibilidad del checksum legado (debilita la integridad) y el acoplamiento implícito a autoloads vía `get_node_or_null`, que complica el testing aislado. No se detectaron dependencias circulares de compilación; el acoplamiento es de runtime y mediado por el árbol de escena.
