**Modelo:** glm-5.3-flash (último modificador; núcleo por ox-alpha)

**Plataforma:**Kilo Code

# 04-Codigo.md — Módulo 59: Guardado

## 0. Implementación Real (2026-08-25, ox-alpha)

> El diseño original asumía `Assets/_Project/Saving/` (plantilla Unity). La implementación real vive en el proyecto Godot 4.7: **`game/isla-ancestral/scripts/saving/`**, con `SaveManager` registrado como autoload en `project.godot`.

| Archivo real | Rol | Estado |
|---|---|---|
| `scripts/saving/save_schema.gd` | Esquema: SCHEMA_VERSION=1, defaults de las 14 secciones, validación de estructura | ✅ Implementado |
| `scripts/saving/save_writer.gd` | Escritura atómica `.tmp`+rename, token de integridad HMAC-SHA256 por instalación (retrocompatible con el SHA-256 legado), parseo verificado | ✅ Implementado |
| `scripts/saving/save_backup.gd` | Rotación local (`slot_N_rK.bak`, MAX_ROTATIONS=2), backups manuales fechados | ✅ Implementado |
| `scripts/saving/save_loader.gd` | Carga validada (checksum→estructura→versión), recuperación desde backup, migración solo-hacia-delante | ✅ Implementado |
| `scripts/saving/save_snapshot.gd` | Colecta/restaura vía ISaveProvider registrados; secciones sin proveedor quedan con defaults | ✅ Implementado |
| `scripts/saving/save_provider.gd` | Contrato ISaveProvider (get_save_data / restore_save_data / get_section_name) | ✅ Implementado |
| `scripts/saving/save_manager.gd` | Autoload: cola (1 guardado a la vez), slots 1-3, bloqueo, metadatos por slot, auto-save temporizado configurable | ✅ Implementado |
| `scripts/saving/validate_save.gd` | QA headless: **16 checks MEDIDOS** (atómico, checksum, corrupción, backup, rotación, schema, camino feliz de carga) — **VALIDACIÓN OK, exit 0** | ✅ Implementado |
| `scripts/saving/test_checksum_hmac.gd` | QA headless BUG-115: **38 checks MEDIDOS** (formato HMAC, tampering de payload/token, retrocompatibilidad legado, end-to-end, clave persistente, validate no vacua) — **EXIT 0** | ✅ Implementado |
| `save_menu.gd` / `save_toast.gd` | UI (M53/M44) | ⬜ Pendiente (requiere visión/UI) |

### Decisiones técnicas clave (desviaciones justificadas del diseño original)

1. **Formato de archivo determinista:** `línea 1 = token de integridad`, `línea 2+ = payload JSON`. El token se calcula sobre la cadena EXACTA del payload. El diseño original (checksum dentro de un dict JSON) era **no determinista**: al re-serializar el payload parseado el orden/round-trip producía hashes distintos y falsos positivos de corrupción (detectado y corregido durante la validación). Desde BUG-115 (iter. 4) el token es `hmac256:<hex>`; un token sin prefijo se interpreta como el SHA-256 legado y se sigue aceptando.
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
| Cifrado para datos sensibles | 🟡 Parcial (BUG-115): **integridad** con HMAC-SHA256 + clave por instalación; el **cifrado** del payload sigue pendiente (recomendado antes de logros M72) |

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
- **FALLO DETECTADO Y CORREGIDO:** el diseño original calculaba el checksum sobre `JSON.stringify(payload)` y lo guardaba dentro del documento JSON. Al cargar, re-serializar el payload parseado producía un hash DISTINTO (round-trip JSON no determinista para hashing) → falsos positivos de corrupción y backups "corruptos". Solución: formato determinista `checksum\npayload` donde el hash se calcula sobre la cadena exacta almacenada. Documentado como descubrimiento para GUIA-GODOT/INDICE.md.
- Escritura síncrona encolada en vez de hilo: simplifica y evita condiciones de carrera; suficiente para el tamaño actual de saves.

### Recomendaciones para el próximo agente
- Ejecutar siempre la suite antes de tocar el módulo: `Godot --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd` (debe terminar exit 0).
- Al crear el primer sistema persistente (ej. M14 Inventario), escribir su provider extendiendo `ISaveProvider` y registrarlo con `SaveManager.register_provider()` — no tocar el núcleo.
- El error de parse de `main_island.tscn` línea 36 es PRE-EXISTENTE (trabajo sin commitear de otro módulo, zona terreno/voxel) — no confundir con este módulo.
- Cuando exista M07 EventBus, conectar las señales de hitos a `SaveManager.request_save(slot, reason)` y agregar el flag dirty.
- Considerar cifrado opcional del payload antes del checksum si se agregan logros (M72/M97).

### Descubrimiento para GUIA-GODOT/INDICE.md (§8)
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

---

## Notas del Agente — Iteración 1: carga, metadatos y versión futura (historial, no borra las anteriores)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-02 20:04:00
**Estado:** Parcial (3 bugs reales corregidos y MEDIDOS; módulo 🔵 En curso, Log 1197)

### BUG CRÍTICO: `SaveLoader.load()` no podía cargar NINGÚN save válido

**Causa raíz (medida con sonda, no inferida).** `JSON.parse_string()` de Godot 4.7 devuelve `float` para todo número:

```
JSON round-trip de {"a":1}      -> typeof=3 (TYPE_FLOAT) valor=1.0
save válido leído del disco     -> schema_version=1.0 (FLOAT), time.day=5.0 (FLOAT)
SaveSchema.validate()           -> ["schema_version no es int", "time.day no es int"]
SaveLoader.load() (sin backup)  -> result=2 (CORRUPTED)
SaveLoader.load() (con backup)  -> result=3 (RECOVERED); cargó día 5.0 mientras el disco tenía 99
```

`SaveSchema.validate()` exigía `typeof(x) == TYPE_INT` para `schema_version` y `time.day`. Como el payload que vuelve del disco SIEMPRE trae floats, `validate()` fallaba siempre y `load()` caía a `_try_recover()`: con backup cargaba **el save anterior en silencio** (pérdida de progreso), sin backup devolvía `CORRUPTED`.

**Fix (2 piezas):**
- `save_schema.gd`: nuevo `_es_entero(v)` — acepta `int`, o `float` con valor entero (`is_finite(f) and f == floorf(f) and absf(f) <= 2^53`). `validate()` lo usa para `schema_version` y `time.day`. El schema exige un entero *semántico*; JSON no preserva el tipo, así que validar el tipo crudo era un error de diseño.
- `save_loader.gd`: tras el parseo, `payload["schema_version"] = int(...)`, restaurando el contrato del campo que el propio loader compara.

### BUG: `slot_metadata()` devolvía `{}` siempre
`JSON.parse_string(archivo_completo)` sobre un archivo cuyo formato es `checksum\npayload` (la 1ª línea es un SHA-256 hex) → el parseo fallaba siempre → `{}` para cualquier slot. Ahora usa `SaveWriter.parse_document()` (valida el checksum y extrae el payload).

### BUG: `FUTURE_VERSION` sin aviso
`SaveLoader` devolvía `FUTURE_VERSION` en silencio. Añadido `push_warning` explícito. El rechazo ya era correcto: no migra hacia atrás, no toca el archivo y `SaveManager.load_slot()` no fija `current_slot`.

### La suite que no lo vio (y cómo se cerró la ceguera)
`validate_save.gd` estaba en 13/13 verde. **Ningún test afirmaba `LoadResult.OK`:**
- `_test_checksum_detection` aceptaba `RECOVERED or CORRUPTED` (disyunción laxa) y luego fijaba `CORRUPTED` — pero solo ejercitaba el camino de ERROR.
- `_test_migration_path` llamaba `SaveSchema.validate()` sobre el `default_payload()` **en memoria** (que conserva los int), nunca sobre un payload leído del disco.

Añadido `_test_carga_valida()` (3 checks): el payload del disco debe pasar `validate()`, `load()` debe dar `OK` y el día debe conservarse. **Probado EN ROJO antes del fix: 16 checks, 3 fallos, EXIT 1**, nombrando los errores exactos. Con el fix: **16 checks, 0 fallos, EXIT 0** (×3). Además el gate pasó de `|| true` (no-op, trampa 81) a `|| FAIL=1`.

### Medición de rendimiento (sección R, "background thread")
Detalle en `05-Checklist.md` (ítem marcado `[?]`, dueño M61). Resumen: `write_atomic` de 4,2 KB = **22,66 ms** de mediana; `request_save()` end-to-end = **48,20 ms**; el coste lo domina el I/O del SO (rename/crear/borrar ≈ 17-40 ms), no el payload (`serialize` 0,27 ms).

### Recomendaciones para el próximo agente
- **Correr las dos suites** antes de tocar M59: `validate_save.gd` (16 checks) y `test_slots_m59.gd` (22 checks). Ambas son gate duro en `quality.yml`.
- **Nunca afirmar que "el camino feliz funciona" sin una aserción explícita de `LoadResult.OK`.**
- Campos numéricos del schema: validar con `_es_entero()`, nunca con `typeof == TYPE_INT` (JSON los devuelve float).
- `slot_metadata()` es el backend de la UI de slots (M53): usar esa API, no re-parsear el archivo a mano.

---

## Notas del Agente — Iteración 2: rotación, carga interrumpida y dialecto (DeepSeek-V4.1-Flash, 2026-10-02)

### Flujo de guardado CORREGIDO (`SaveManager._process_queue`)

El orden de escritura es una **regla dura** del módulo. Desde iter. 2:

1. `SaveBackup.rotate(slot)` — el save ANTERIOR pasa a `slot_N_r1.bak` (y `_r1` → `_r2`).
2. `SaveWriter.write_atomic(slot, payload)` — `.tmp` → `.save` (rename atómico).

**Por qué el orden importa (bug crítico de iter. 2):** `write_atomic()` renombra `.tmp → .save` con semántica de REEMPLAZO, así que si `rotate()` corre DESPUÉS, mueve el save **recién escrito** a `.bak` y el slot queda SIN `.save` → `load_slot()` = `NOT_FOUND`. `request_save()` (auto-save, timer, UI) nunca dejaba un save cargable. Las suites heredadas no lo veían porque llamaban a `write_atomic()` directo.

### Carga (`SaveLoader.load`)

- Si el `.save` **no existe** pero hay `.bak`, se recupera (`RECOVERED`) en vez de devolver `NOT_FOUND`: cubre el corte entre la rotación y la escritura.
- `_try_recover()` es tan estricto como el camino principal: normaliza `schema_version`, valida estructura (`SaveSchema.validate`) y **rechaza `FUTURE_VERSION`** (antes un backup de versión futura se cargaba como `RECOVERED` y degradaba un save más nuevo).

### Metadatos (`SaveManager.slot_metadata` + `meta.last_saved`)

- `slot_metadata().day` lee el **dialecto real** del proveedor de tiempo (`dia`) y cae a `day`. Antes leía solo `day` (clave del schema) que NO existe en disco → devolvía SIEMPRE 0.
- El manager sella `meta.last_saved` en `_payload_para_slot(slot)` (usado por la cola y por el guardado de cierre). Ningún proveedor emite `meta`, así que antes salía SIEMPRE vacío.

### Deuda de integración: dialecto schema ↔ proveedores

`collect()` hace `payload[seccion] = data` y **reemplaza la sección entera**. Los proveedores reales NO usan las claves del schema: `time` usa `dia/mes/anio/hora/minuto`, `inventory` usa índices `"0".."5"`, `economy` usa `saldo/precios/historial/reputacion`. Consecuencia original: `SaveSchema.validate()` era **prácticamente vacua contra saves reales**. **Reconciliar las CLAVES sigue siendo de los dueños de M14/M29/M38**; M59 mitiga lo suyo leyendo el dialecto real, sellando su propia sección `meta` y —desde la iter. 4 (BUG-115)— **validando AMBOS dialectos** (ver más abajo), así que la validación ya no es vacua sin tocar el contrato de los proveedores.

### Suite nueva

`scripts/saving/test_rotate_m59.gd` (28 checks, 7 bloques) cubre el **camino real** (`request_save`) y la rotación. Guardia de 3 capas: `_fin(clave)` por bloque, `CHECKS_MINIMOS = 28` medido en verde, `_summary()` en `call_deferred` separado.

---

## Notas del Agente — Iteración 3: defaults al cargar y contrato del proveedor `player` (DeepSeek-V4.1-Flash, 2026-10-02)

### Completar defaults al cargar (item H)

`SaveSchema.completar(payload)` rellena con los defaults del schema toda **sección de nivel superior** que falte. `SaveLoader.load()` y `SaveLoader._try_recover()` lo llaman **antes** de `validate()`. Antes, un save sin una sección fallaba `validate()` ("Falta sección: X") → CORRUPTED y no se podía cargar.

**NO toca el INTERIOR de las secciones, a propósito.** 15 proveedores iteran las claves de su sección en `restore_save_data()`, y `inventario_service` hace `for id in data: int(id)` tratando la clave como índice de contenedor: inyectar `items` (del schema) se leería como el contenedor `0` y **borraría su contenido**. El interior de una sección es responsabilidad de su proveedor.

### Dialecto: una sola traducción

`SaveSchema.dia_de(payload)` es la ÚNICA traducción del dialecto del proveedor de tiempo (`dia` de M29) al del schema (`day`). Si los dueños de M14/M29/M38 reconcilian las claves, se cambia solo ahí.

### `PlayerSaveProvider` — contrato completo

- `get_save_data()`: lee `spawn_position` y `zone` del nodo **si las expone** (duck-typing con `prop in nodo`); si no, `spawn_position` es la posición actual (punto de reanudación) y `zone` es `""`.
- `restore_save_data()`: restaura `position` (siempre), y `spawn_position`/`zone` **si el nodo las expone**.
- **Nunca asigna `name`**: en un `Node`, `name` es `Node.name`; asignarlo renombraría el nodo y rompería `find_child("Player")`.

### Suite

`test_rotate_m59.gd`: **43 checks, 9 bloques** (b8 = item H + control negativo; b9 = contrato del proveedor con nodo inyectado, incluido un nodo con `spawn_position`/`zone` creado con `GDScript` en runtime). Piso `CHECKS_MINIMOS = 43` medido en verde.

---

## Notas del Agente — Iteración 4: cola de bugs y fix real de BUG-115 (DeepSeek-V4.1-Flash, 2026-10-06)

### Cola de 8 bugs (Logs 1377-1382)

Se recorrió la cola BUG-108..115 del módulo: 6 cerrados con sonda roja probada por inyección, 1 reclasificado (BUG-111 = falso positivo, con un bug real adyacente en `collect()` → **BUG-111-bis** resuelto) y 1 (BUG-115) quedó como deuda informativa. Detalle en los logs citados y en las filas de `11-BUGS.md`.

### BUG-115 — fix real: token HMAC + validación no vacua (Log 1397)

**Antes** (deuda documentada en `3ad8630`): el token era un SHA-256 del payload EN CLARO, sin secreto; `validate()` era **vacua** (su único chequeo de rango leía `time.day`, clave que el proveedor real de tiempo —M29, `game_clock.gd`— nunca emite: usa `hora/minuto/dia/mes/anio/acumulador`); y `profile_id` se chequeaba solo por PRESENCIA, no por tipo.

**Ahora:**

1. `save_writer.gd` — token `hmac256:<hex>` (HMAC-SHA256 con clave por instalación). La clave vive en `user://clave_integridad.key` (32 bytes de `Crypto.generate_random_bytes`, hex) y se cachea en un `static var`.
   - DECISIÓN: la clave va en la RAÍZ de `user://`, **fuera** de `user://saves`. Motivo medido: `validate_save.gd::_delete_save_dir()` y otras suites borran TODO el contenido de `user://saves`; si la clave viviera ahí, un borrado la eliminaría y los saves escritos antes quedarían sin poder verificarse.
   - `verificar_checksum()` acepta HMAC (con prefijo) y, por RETROCOMPATIBILIDAD, el SHA-256 legado (sin prefijo). `parse_document()` expone además `legacy: bool`.
   - La autoverificación interna de `write_atomic()` (`.tmp` → releer → `parse_document().ok`) sigue siendo SIMÉTRICA: ambos lados usan el mismo formato.
2. `save_schema.gd` — `validate()` valida **ambos dialectos** de `time`, solo las claves PRESENTES (no acopla la validación a un dialecto): real (`hora` 0..23, `minuto` 0..59, `dia` ≥ 1, `mes` 1..12, `anio` ≥ 1, `acumulador` finito en [0, 3600]) y schema (`hour`, `minute`, `day`, `season`). Además `profile_id` debe ser String y `meta.last_saved`/`meta.playtime_seconds` se validan. Nueva constante `MAX_CLOCK_ACUMULADOR = 3600.0`.
   - NO se duplica el máximo real de `dia` (28 es una constante de M29): sería acoplar M59 a una decisión de otro módulo. **No se tocó `game_clock.gd`.**

**Evidencia:** `test_checksum_hmac.gd` (8 bloques, guardia de 3 capas) — **38 checks, 0 fallos, EXIT 0 ×3**; guardián probado **EN ROJO por inyección** (2 inyecciones, revertidas y verificadas con `grep`): `verificar_checksum()` devolviendo siempre `true` → 3 fallos, EXIT 1; `_validar_entero_rango()` anulada → 4 fallos, EXIT 1. Regresión: **14 suites EXIT 0** (validate_save 16/0, test_rotate_m59 43/0, test_slots_m59 22/0, test_autosave_m59, test_save_collect_robust 10/0, test_save_size_cap 7/0, test_backup_rotations 7/0, test_backup_rotate_return 4/0, test_close_save 6/0, test_slot_range 10/0, test_fishing_save_block 11/0, test_inventario_restore_robusto 12/0, test_diario_persist). Gate nuevo en `quality.yml` (`|| FAIL=1`, junto a las otras 3 suites de M59).

**LIMITACIÓN RESIDUAL (honesta — NO es un sello de "a prueba de trampas"):** el token legado se sigue aceptando (regla dura del proyecto: no inutilizar un save existente), así que un atacante con acceso al sistema de archivos puede reemplazar la línea 1 por `sha256(payload)` y el documento verifica; y la clave HMAC vive en `user://`, junto a los saves, y es legible. El HMAC **no** vuelve el save a prueba de manipulación local. Lo que SÍ queda verificado: (a) los saves NUEVOS ya no se pueden re-firmar sin la clave con el algoritmo público; (b) el caso legado queda expuesto vía el flag `legacy`; (c) la validación de esquema, que era vacua, ahora rechaza rangos/tipos inválidos sobre el dialecto real — la parte con valor real y medible de este fix. Por eso la fila de BUG-115 en `11-BUGS.md` queda en `[->] Parcial`, no en `[x] Resuelto`.
