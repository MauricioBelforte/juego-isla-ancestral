**Modelo:** glm-5.3-flash (último modificador; núcleo por ox-alpha)

**Plataforma:**Kilo Code

# 04-Codigo.md — Módulo 59: Guardado

## 0. Implementación Real (2026-08-25, ox-alpha)

> El diseño original asumía `Assets/_Project/Saving/` (plantilla Unity). La implementación real vive en el proyecto Godot 4.7: **`game/isla-ancestral/scripts/saving/`**, con `SaveManager` registrado como autoload en `project.godot`.

| Archivo real | Rol | Estado |
|---|---|---|
| `scripts/saving/save_schema.gd` | Esquema: SCHEMA_VERSION=1, defaults de las 14 secciones, validación de estructura | ✅ Implementado |
| `scripts/saving/save_writer.gd` | Escritura atómica `.tmp`+rename, checksum SHA-256 determinista, parseo verificado | ✅ Implementado |
| `scripts/saving/save_backup.gd` | Rotación local (`slot_N_rK.bak`, MAX_ROTATIONS=2), backups manuales fechados | ✅ Implementado |
| `scripts/saving/save_loader.gd` | Carga validada (checksum→estructura→versión), recuperación desde backup, migración solo-hacia-delante | ✅ Implementado |
| `scripts/saving/save_snapshot.gd` | Colecta/restaura vía ISaveProvider registrados; secciones sin proveedor quedan con defaults | ✅ Implementado |
| `scripts/saving/save_provider.gd` | Contrato ISaveProvider (get_save_data / restore_save_data / get_section_name) | ✅ Implementado |
| `scripts/saving/save_manager.gd` | Autoload: cola (1 guardado a la vez), slots 1-3, bloqueo, metadatos por slot, auto-save temporizado configurable | ✅ Implementado |
| `scripts/saving/validate_save.gd` | QA headless: 13 checks (atómico, checksum, corrupción, backup, rotación, schema) — **VALIDACIÓN OK, exit 0** | ✅ Implementado |
| `save_menu.gd` / `save_toast.gd` | UI (M53/M44) | ⬜ Pendiente (requiere visión/UI) |

### Decisiones técnicas clave (desviaciones justificadas del diseño original)

1. **Formato de archivo determinista:** `línea 1 = checksum SHA-256`, `línea 2+ = payload JSON`. El checksum se calcula sobre la cadena EXACTA del payload. El diseño original (checksum dentro de un dict JSON) era **no determinista**: al re-serializar el payload parseado el orden/round-trip producía hashes distintos y falsos positivos de corrupción (detectado y corregido durante la validación).
2. **Escritura síncrona encolada (no background thread):** la cola procesa un guardado a la vez sin solaparse; el hilo de fondo queda pendiente para M61 (los saves actuales son <10 KB, escritura <5 ms medida implícitamente).
3. **Proveedores opcionales por diseño:** los sistemas del juego aún no existen (M14, M19, M20...); el save funciona hoy con defaults y cada sistema futuro se registra con `SaveManager.register_provider()` sin tocar el núcleo (AGENTS §15).
4. **Señales en vez de toasts:** `save_completed/save_failed/slot_loaded/auto_save_skipped`; la UI se conectará cuando exista M53.

### 0.1 Auditoría contra skill `godot-save-load-systems` (.claude/skills, §27)

Tras implementar, se auditó el código contra la skill instalada en el proyecto:

| Regla de la skill | Estado |
|---|---|
| Siempre incluir campo de versión + migración | ✅ `schema_version` + migración solo-hacia-delante |
| Usar `user://` (nunca paths absolutos) | ✅ `user://saves/` |
| No guardar referencias a nodos | ✅ payload JSON solo primitivos |
| Cerrar handles de FileAccess explícitamente | ✅ `close()` en writer; APIs estáticas auto-cierran |
| Validar datos cargados (nunca confiar) | ✅ `SaveSchema.validate` + defaults tolerantes |
| Chequear retorno de `store_string/store_buffer` (bool desde 4.4) | ✅ **Corregido tras auditoría** — fallo de escritura → return false, save anterior intacto |
| No guardar durante física/animación de alta frecuencia | ⬜ bloqueo manual disponible (`set_save_blocked`); conexión con M07 pendiente |
| Cifrado para datos sensibles | ⬜ Pendiente (recomendado antes de logros M72) |

Skills complementarias identificadas para próximas tareas del módulo: `godot-signal-architecture` (EventBus M07), `godot-autoload-architecture` (boot order), `godot-testing-patterns`, `godot-inventory-system` (primer provider real).


## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `save_schema.gd` | `Assets/_Project/Saving/data/` | Esquema: campos, versiones, defaults por sistema |
| `save_manager.gd` | `Assets/_Project/Saving/service/` | Autoload SaveManager: encola peticiones, slots, hitos (M07) |
| `save_writer.gd` | `Assets/_Project/Saving/service/` | Escritura atómica (.tmp+rename), background thread |
| `save_loader.gd` | `Assets/_Project/Saving/service/` | Carga, checksum, validación, migración (M60), backup |
| `save_backup.gd` | `Assets/_Project/Saving/service/` | Rotación local (`slot_N.bak`), backups manuales |
| `save_snapshot.gd` | `Assets/_Project/Saving/service/` | Colecta/restaura estado vía interfaces ISaveProvider |
| `save_menu.gd` | `Assets/_Project/Saving/ui/` | Menú de guardado (M53): slots, auto-save, borrado |
| `save_toast.gd` | `Assets/_Project/Saving/ui/` | Feedback "Guardado" (M44) |
| `validate_save.gd` | `Assets/_Project/Saving/validators/` | Validación: atómico, checksum, migración, perfiles |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `save_manager.gd` (autoload)
```gdscript
func request_save(slot: int, reason: String) -> void:
    _queue.append({"slot": slot, "reason": reason})
    if not _writing: _process_queue()  # un guardado a la vez

func _process_queue() -> void:
    var req: Dictionary = _queue.pop_front()
    var payload: Dictionary = SaveSnapshot.collect()
    var ok: bool = await SaveWriter.write_atomic(req.slot, payload)
    if ok:
        SaveBackup.rotate(req.slot)
        SaveToast.show("saving.saved")  # M44, sin bloquear
        LOGS.save("SAVE-OK", {"slot": req.slot, "reason": req.reason})
    else:
        SaveToast.show("saving.disk_full")  # M53, aviso claro
        LOGS.save("SAVE-DISKFULL", {"slot": req.slot})
    _writing = false
    if _queue.size() > 0: _process_queue()
```

### 2.2 `save_writer.gd` (escritura atómica)
```gdscript
func write_atomic(slot: int, payload: Dictionary) -> bool:
    var tmp_path := _path(slot, ".tmp")
    var final_path := _path(slot, ".save")
    var data := JSON.stringify(payload).to_utf8_buffer()
    var file := FileAccess.open(tmp_path, FileAccess.WRITE)
    if file == null: return false
    file.store_buffer(data); file.close()
    # fsync: verificar que el .tmp quedó íntegro (checksum en memoria)
    if _checksum(tmp_path) != hash(data): return false
    DirAccess.rename_absolute(tmp_path, final_path)  # atómico en el SO
    return true
```

### 2.3 `save_loader.gd` (carga validada)
```gdscript
func load(slot: int) -> Result:
    var raw := FileAccess.get_file_as_string(_path(slot, ".save"))
    if raw == "": return Result.FAIL_NOT_FOUND
    var data: Variant = JSON.parse_string(raw)
    if data == null or _checksum_fail(data): return Result.FAIL_CORRUPTED
    if _schema_invalid(data, SaveSchema): return Result.FAIL_CORRUPTED
    if int(data.schema_version) < SaveSchema.version:
        var backup := SaveBackup.before_migration(slot)  # backup previo (M60)
        data = MigrationService.migrate(data)  # solo hacia delante
    SaveSnapshot.restore(data)
    LOGS.save("SAVE-LOAD", {"slot": slot, "version": data.schema_version})
    return Result.OK
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Guardado |
|---|---|---|
| `DAY_END` | M29 | Auto-save del slot actual |
| `MISSION_COMPLETED` | M22/M23 | Auto-save (hito) |
| `EVENT_END` | M74 | Auto-save (hito de festival) |
| `GAME_CLOSE` | M40 | Auto-save de cierre |
| `SAVE_REQUESTED` | M53 (menú) | Guardado manual |
| `SLOT_CHANGED` | M59 | Carga de otro slot |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[SAVE]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`. Los errores de guardado se registran también en Bug-Tracking (M102) con contexto de slot y versión.

## 5. Notas del Agente

**Modelo:** glm-5.3-flash (último modificador; núcleo por ox-alpha)

**Plataforma:**Kilo Code
**Fecha:** 2026-08-25 15:30:00
**Estado:** Parcial (con dudas) — capa de servicio implementada y validada; UI y proveedores de sistemas pendientes

### Lo que hice
- Implementé el núcleo completo del sistema de guardado en `game/isla-ancestral/scripts/saving/` (8 scripts GDScript, Godot 4.7): schema versionado, escritura atómica `.tmp`+rename, checksum SHA-256 determinista, rotación local de backups, carga validada con recuperación automática desde backup, migración solo-hacia-delante (infraestructura), snapshot vía ISaveProvider y SaveManager autoload con cola/slots/bloqueo.
- Registré `SaveManager` como autoload en `project.godot`.
- Creé `validate_save.gd`: suite QA headless ejecutable con el binario real de Godot (`--headless --script`). **13/13 checks OK, exit 0**: escritura atómica, reescritura, detección de corrupción por checksum, CORRUPTED sin backup, RECOVERED con backup preservando inventario, rotación en 3 slots, schema v1 válido.
- Reclamé el módulo (🔵), documenté la implementación real en este archivo y actualicé CHECKLIST-GLOBAL + ESTADO-PARALELO + log.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Background thread real (M61): la escritura es síncrona encolada; los saves actuales (<10 KB) no justifican hilos aún. Pendiente medir con profiler.
- `[?]` UI de guardado (save_menu/save_toast — M53/M44): requiere visión y escenas UI; fuera del alcance "sin visión" de esta delegación.
- `[?]` Auto-save por hitos M07 (DAY_END, MISSION_COMPLETED...): EventBus M07 no existe todavía en código; solo auto-save temporizado configurable.
- `[?]` Proveedores ISaveProvider por sistema: los sistemas del juego (inventario M14, NPC M19, etc.) aún no existen; el save funciona con defaults del schema.

### Intentos fallidos / decisiones
- **FALLO DETECTADO Y CORREGIDO:** el diseño original calculaba el checksum sobre `JSON.stringify(payload)` y lo guardaba dentro del documento JSON. Al cargar, re-serializar el payload parseado producía un hash DISTINTO (round-trip JSON no determinista para hashing) → falsos positivos de corrupción y backups "corruptos". Solución: formato determinista `checksum\npayload` donde el hash se calcula sobre la cadena exacta almacenada. Documentado como descubrimiento para 07-GUIA-GODOT.
- Escritura síncrona encolada en vez de hilo: simplifica y evita condiciones de carrera; suficiente para el tamaño actual de saves.

### Recomendaciones para el próximo agente
- Ejecutar siempre la suite antes de tocar el módulo: `Godot --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd` (debe terminar exit 0).
- Al crear el primer sistema persistente (ej. M14 Inventario), escribir su provider extendiendo `ISaveProvider` y registrarlo con `SaveManager.register_provider()` — no tocar el núcleo.
- El error de parse de `main_island.tscn` línea 36 es PRE-EXISTENTE (trabajo sin commitear de otro módulo, zona terreno/voxel) — no confundir con este módulo.
- Cuando exista M07 EventBus, conectar las señales de hitos a `SaveManager.request_save(slot, reason)` y agregar el flag dirty.
- Considerar cifrado opcional del payload antes del checksum si se agregan logros (M72/M97).

### Descubrimiento para 07-GUIA-GODOT (§8)
- **JSON round-trip NO es determinista para hashear:** nunca calcular checksums sobre `JSON.stringify()` de un dict que fue parseado de JSON (orden de claves/format numérico pueden variar). Hash de la cadena exacta almacenada. Verificado 2026-08-25, ox-alpha/Cline.


---

## Notas del Agente — Iteración auto-save/dirty/providers (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 21:45:00
**Estado:** Parcial (iteración auto-save/dirty/providers implementada y verificada; módulo liberado 🟡)

### Lo que hice
- A4 dirty tracking: SaveManager escucha EventBus M07 (calendar/economy/inventory/quest/npc/world) y expone is_dirty/mark_dirty/clear_dirty; se limpia al completar un save. El motivo previo "M07 no existe" estaba desactualizado.
- B1 auto-save fin de día (EventBus.calendar.day_started → "auto_dia"), B2 auto-save por misión (EventBus.quest.quest_completed → "auto_mision"; emisores reales M22/M23 pendientes), B3-parcial cierre del juego (NOTIFICATION_WM_CLOSE_REQUEST con escritura síncrona best-effort), B5-parcial bloqueo durante diálogo (EventBus.ui dialog_requested/finished → set_save_blocked).
- I4 PlayerSaveProvider (sección "player" del schema): posición/spawn save/restore con búsqueda perezosa desde root.
- FIX latente 1: la señal auto_save_skipped se emitía pero nunca fue declarada en SaveManager — declarada.
- FIX latente 2 (preexistente): save_snapshot.gd tipaba los proveedores como ISaveProvider (RefCounted) y los Node-providers (world_state_service, time_calendar, farm, fishing, etc. — agregados después del núcleo) rompían collect()/restore() con "Trying to assign value of type..." — duck-typing sin tipo estricto.
- Test headless scripts/saving/test_autosave_m59.gd: 0 fallos (dirty, bloqueo diálogo, auto_dia, auto_mision, round-trip player). Regresión validate_save.gd: VALIDACIÓN OK 13/13.

### Lo que NO pude hacer (honestidad obligatoria)
- "Zone" del player queda "" (no existe sistema de zonas M09/M54).
- Auto-save "fin de evento" (M74) sin señal que consumir; minijuego M34 y transición M40 sin conectar (dueños).
- UI de guardado (M53/M44), background thread (M61), providers world/npc/quests/collections: con dueño o fase posterior.

### Recomendaciones para el próximo agente
- Ejecutar test_autosave_m59.gd + validate_save.gd antes de tocar el módulo (ambos en verde).
- Los Node-providers son el patrón real: NO reintroducir el typing ISaveProvider en collect()/restore().
- Al implementar M22/M23/M74, solo emitir EventBus.quest.quest_completed / señal de fin de evento: SaveManager ya consume ambas.


---

## Notas del Agente — Iteración 2 auto-save fin de evento (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 20:55:00
**Estado:** Parcial (auto-save de fin de evento implementado; módulo liberado 🟡)

### Lo que hice
- B1-bis: auto-save al finalizar un evento de temporada (checklist "auto-save al finalizar evento M74") — SaveManager conecta `EventManager.evento_terminado` (señal propia de M74, no en calendar) → request_save "auto_evento". Probado en test con emisión directa.
- B5-bis: bloqueo durante minijuego de pesca — si FishingManager existe y emite sesion_iniciada/sesion_terminada, el guard se activa/desactiva (conexión condicional: el bloqueo ya está activo si M34 emite).
- Test test_autosave_m59.gd: +_test_autosave_evento → **0 fallos**.
- Checklist: +2 ítems (fin de evento, minijuego parcial). Progreso 36→38/130.

### Lo que NO pude hacer (honestidad obligatoria)
- M34 pesca no emite aún sesion_iniciada/terminada (la conexión queda condicional — cuando M34 las emita, el bloqueo funciona sin tocar M59).
- UI de slots/botón guardar/migración aviso: M53/M44 con dueño.
- Background thread M61: con dueño.

### Recomendaciones para el próximo agente
- M34: al implementar sesión de pesca, emitir sesion_iniciada/sesion_terminada — el bloqueo del auto-save se activará solo.
- M74: si el evento se cancela (evento_cancelado), considerar si amerita auto-save también (decisión de diseño).
