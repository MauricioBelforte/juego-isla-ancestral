# L-03 — Auditoría de robustez y seguridad del sistema de guardado (M59)

**Modelo:** ling-3.1-flash
**Plataforma:** Kilo Gateway
**Fecha:** 2026-10-06 09:24
**Alcance:** `game/isla-ancestral/scripts/saving/` (13 archivos, 1915 líneas) + proveedores de guardado del código + documentación M59.
**Tipo:** Auditoría de solo lectura. No se modificó código del juego.

---

## 1. Metodología

**Orden de lectura (archivo por archivo, completo, no por encima):**

1. `save_manager.gd` (280) — autoload, cola, slots, bloqueo, metadatos, auto-save
2. `save_loader.gd` (135) — carga validada, checksum, migración, recuperación
3. `save_writer.gd` (112) — escritura atómica, checksum SHA-256, parseo
4. `save_schema.gd` (183) — versión, defaults, `completar`, `validate`, `_es_entero`
5. `validate_save.gd` (170) — suite QA headless
6. `save_snapshot.gd` (63) — recolección/restauración vía proveedores
7. `save_backup.gd` (65) — rotación local, backup manual
8. `player_save_provider.gd` (83) — sección "player"
9. `save_provider.gd` (35) — contrato ISaveProvider
10. `auditar_aliasing.gd` (62) — detector de aliasing en proveedores
11. `test_rotate_m59.gd` (352) — suite del camino real + rotación
12. `test_slots_m59.gd` (228) — suite de metadatos + versión futura
13. `test_autosave_m59.gd` (147) — suite de auto-save/dirty/providers

**Total núcleo: 1915 líneas** (verificado: 280+135+112+183+170+63+65+83+35+62+352+228+147 = 1915).

**Proveedores leídos completos** (los relevantes para las preguntas de la auditoría):
`economia/economy_manager.gd` (199), `inventario/inventario_service.gd` (421), `inventario/inventario_contenedor.gd` (156), `inventario/inventory_slot.gd` (57), `inventario/container_type.gd` (43), `time/game_clock.gd` (persistencia), `time/time_calendar.gd` (persistencia), `combat/gem_currency.gd` (108), `combat/gem_save_provider.gd` (31).

**Documentación M59:** `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` (320 líneas, con el historial de iteraciones y bugs ya corregidos).

**Método de verificación:** cada sospecha del enunciado se rastreó hasta el código real y se citó `archivo:línea`. Donde el sistema es sólido, se cita el código que lo demuestra (sección 3). No se inventó ninguna vulnerabilidad: cada hallazgo de la sección 2 tiene una cadena de llamadas verificable.

**Búsqueda de proveedores:** `grep` de `get_section_name` sobre todo `scripts/` → **56 proveedores** registrados (inventario, economía, gemas, tiempo, clima, historia, amistad, eventos, coleccionables, crafting, farm, construcción, herramientas, hardware, audio, viajes, minería, fauna, museo, NPC, vehículos, transporte, progresión, tutorial, diario, lore, etc.). Se auditaron en profundidad los de mayor impacto en seguridad/robustez (economía, inventario, gemas, tiempo).

---

## 2. Hallazgos (S-01 … S-10)

### S-01 — 🟡 MEDIO: El restore de inventario confía en las claves de la sección como índices de contenedor, y no valida `stack_max` → un save manipulado inyecta cantidades ilimitadas de ítems válidos

**Archivos:** `inventario_service.gd:400-407`, `inventario_contenedor.gd:122-138`, `inventory_slot.gd:48-57`.

**Cadena de llamada (verificada):**

`inventario_service.gd:400-407`:
```gdscript
func restore_save_data(data: Dictionary) -> void:
	for id in data:
		var c := int(id)                 # ← clave → int, sin validar que sea numérica
		if contenedores.has(c):
			var lista: Variant = data[id]
			if typeof(lista) == TYPE_ARRAY:
				contenedores[c].deserializar(lista)
```

`inventario_contenedor.gd:122-138` (`deserializar`):
```gdscript
func deserializar(lista: Array) -> void:
	for s in slots:
		s.vaciar()                        # limpia antes de cargar (bien: no duplica)
	for d in lista:
		var idx := int(d.get("slot", -1))
		if idx >= 0 and idx < slots.size():      # ← idx sí está bounds-checked
			var slot := InventorySlot.deserializar(d)
			if slot.item_id != "":
				var db = ...get_node_or_null("/root/ItemDatabase")
				if db != null and db.get_item(slot.item_id) == null:
					push_warning(...); continue   # ← item_id SÍ se valida contra el catálogo
				if slot.cantidad <= 0:
					push_warning(...); continue   # ← solo rechaza cantidad <= 0
			slots[idx] = slot                     # ← NO hay chequeo de cantidad > stack_max
```

`inventory_slot.gd:51`: `s.cantidad = int(d.get("n", 0))` — sin clamp.

**Por qué es real (evidencia irrefutable):**
- El propio proyecto documenta el mecanismo en `save_schema.gd:117-123`: *"inventario_service.restore_save_data() hace `for id in data: int(id)` y trata la clave como indice de contenedor, asi que una clave como 'items' se leeria como el contenedor 0"*. Es decir, `int("items") == 0 == ContainerType.Id.BOLSILLO` (`container_type.gd:11-18`).
- Los IDs de contenedor son 0..5 (`container_type.gd:11-18`), y `int()` de cualquier cadena no numérica devuelve 0 en GDScript. Cualquier clave no numérica (`"items"`, `"x"`, `"evil"`) mapea a BOLSILLO.
- El checksum **no** es un obstáculo: no hay secreto (ver S-08), así que un atacante edita el payload y recalcula el SHA-256.

**Reproducción:** craftear un save con:
```json
{"schema_version":1, "profile_id":"p", ...,
 "inventory": {"cualquier_clave": [{"slot":0, "id":"madera", "n":999999999}]}, ...}
```
recalcular el SHA-256 del payload, escribir `checksum\npayload` en `user://saves/slot_1.save`, y cargar. Resultado: BOLSILLO queda con 999999999 de "madera" (o cualquier ítem que exista en `ItemDatabase`).

**Impacto real y por qué es 🟡 y no 🟠:** el `item_id` SÍ se valida contra el catálogo (`inventario_contenedor.gd:130-134`), así que no se pueden inyectar ítems inexistentes; y es un juego single-player cozy, donde el "atacante" es el propio jugador editando su save (no hay integridad multijugador en juego). Pero es una brecha auténtica de validación de datos cargados: el juego verifica *qué* ítem pero no *cuánto*, y la clave de sección se interpreta como índice sin validación. El `stack_max` solo se aplica en `add_item` (`inventario_contenedor.gd:50, 74`), nunca en la carga.

**Propuesta (no aplicada):** en `restore_save_data`, validar que cada clave sea numérica y esté en rango antes de `int(id)` (ej: `if not id.is_valid_int() or not contenedores.has(int(id)): continue`); y en `deserializar`, clampear `cantidad` a `_stack_max_de(item_id)` tras el chequeo `> 0`.

---

### S-02 — 🟡 MEDIO: Sin límite de tamaño antes de leer un save completo a memoria

**Archivos:** `save_loader.gd:41`, `save_manager.gd:253`, `save_backup.gd:62`.

```gdscript
# save_loader.gd:41
var content := FileAccess.get_file_as_string(path)      # lee TODO el archivo
# save_manager.gd:253 (slot_metadata)
var content: String = FileAccess.get_file_as_string(SaveWriter.path_for(slot))
# save_backup.gd:62 (read_latest_backup)
return FileAccess.get_file_as_string(path)
```

**Falla:** no hay `file_exists` + `get_size()` + cap antes de `get_file_as_string`. Un archivo `slot_N.save` de, por ejemplo, 4 GB (con checksum válido, trivial de fabricar) se lee íntegro en un `String` antes de cualquier validación → consumo de memoria masivo / OOM. La pregunta del enunciado ("payload enorme") queda sin mitigación en los tres puntos de lectura.

**Impacto:** en single-player el usuario controla sus propios saves, por eso 🟡. Pero es un sanity check estándar en cualquier sistema de save (cap de 1-10 MB es lo habitual) y aquí está ausente.

**Propuesta:** helper `leer_save_capped(path, max_bytes)` que haga `FileAccess.open` → `get_length()` → si `> max_bytes` (ej: 8 MB) devolver `""`/error sin leer; usarlo en los tres sitios.

---

### S-03 — 🟡 MEDIO: La recuperación de backup solo intenta la rotación 1, nunca la rotación 2 (que sí se conserva)

**Archivos:** `save_backup.gd:58-62`, `save_loader.gd:91-96`.

```gdscript
# save_backup.gd:58-62
static func read_latest_backup(slot: int) -> String:
	var path := latest_backup(slot)          # = _bak_path(slot, 1)  ← SOLO r1
	if path.is_empty() or not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)
```

`MAX_ROTATIONS = 2` (`save_backup.gd:12`), y `rotate()` (`save_backup.gd:17-30`) mantiene `slot_N_r1.bak` y `slot_N_r2.bak`. Pero `read_latest_backup` lee **solo r1**, y `_try_recover` (`save_loader.gd:93`) lo llama una sola vez. Si r1 está corrupto y r2 es íntegro (dos escrituras corruptas consecutivas, o corrupción que alcanzó al save que rotó a r1), el loader reporta `CORRUPTED` aunque existe un backup bueno en r2 que nunca se prueba.

**Por qué es real:** la rotación gasta I/O y disco en conservar r2 (`save_backup.gd:23-27` lo desplaza y lo mantiene), pero ningún camino de lectura lo consulta. Es un backup muerto: se guarda pero jamás se usa. Eso derrota el propósito de `MAX_ROTATIONS = 2`.

**Propuesta:** `_try_recover` debe iterar `for i in range(1, SaveBackup.MAX_ROTATIONS + 1)` y probar cada rotación hasta una que pase `parse_document` + `validate`, en orden de frescura.

---

### S-04 — 🟡 MEDIO: Sin guarda ante excepciones en la cola de guardado — un proveedor que lance en `get_save_data()` deja `_writing = true` para siempre y silencia todos los guardados futuros

**Archivo:** `save_manager.gd:194-228`.

```gdscript
func _process_queue() -> void:
	if _queue.is_empty() or _writing:
		return
	_writing = true                              # 197
	var req: Dictionary = _queue.pop_front()     # 198
	...
	var payload := _payload_para_slot(slot)      # 203 ← llama a TODOS los get_save_data()
	SaveBackup.rotate(slot)                       # 216
	var ok := SaveWriter.write_atomic(slot, payload)  # 217
	...
	_writing = false                             # 226 ← NUNCA se alcanza si 203/216/217 lanza
	if not _queue.is_empty():
		_process_queue()                         # 228
```

**Falla:** `_payload_para_slot` → `snapshot.collect()` (`save_snapshot.gd:37-46`) itera **todos** los proveedores registrados y llama a `provider.get_save_data()`. Si cualquiera lanza (un `precios.serializar()` con estado inconsistente, un nodo liberado, etc.), la excepción propaga fuera de `_process_queue` y `_writing` queda en `true` permanentemente. Todo `request_save` posterior hace `_queue.append(...)` y luego `_process_queue` retorna inmediato (`_writing` es `true`) → **la cola nunca se drena y el juego deja de guardar en silencio** hasta reiniciar. No hay `try/finally` porque GDScript no los tiene, y no hay reset diferido.

**Por qué es real:** el proyecto mantiene `auditar_aliasing.gd` precisamente porque los proveedores han tenido bugs de aliasing que corrompen estado; `collect()` toca a todos por cada guardado. Un solo proveedor malo inmoviliza el guardado de los otros 55. El impacto (pérdida silenciosa de todo guardado futuro) es alto; la probabilidad (excepción en un `get_save_data` defensivamente codificado) es baja-media → 🟡.

**Propuesta:** poner `_writing = false` *antes* de las operaciones riesgosas (o resetearlo vía `call_deferred` al inicio), de modo que un fallo no deje la cola trabada; y/o envolver el cuerpo en un helper que garantice el reset.

---

### S-05 — 🟢 BAJO: La rotación ignora los códigos de retorno de `DirAccess.rename_absolute`

**Archivo:** `save_backup.gd:23-30`.

```gdscript
for i in range(MAX_ROTATIONS - 1, 0, -1):
	var older := _bak_path(slot, i)
	var newer := _bak_path(slot, i + 1)
	if FileAccess.file_exists(older):
		var _e := DirAccess.rename_absolute(older, newer)   # ← retorno ignorado
DirAccess.rename_absolute(final_path, _bak_path(slot, 1))   # ← retorno ignorado
```

**Falla:** si un rename falla (disco lleno, permisos, archivo bloqueado), la rotación queda parcial o no ocurre, y `_process_queue` (`save_manager.gd:216`) procede a `write_atomic` de todos modos. Consecuencia: el `.bak` puede no contener el save anterior, así que si la escritura posterior falla, no hay nada de qué recuperar. El error no es "silencioso" en el sentido de no loguearse — es que **no se loguea ni se propaga**: `rotate()` devuelve `void` y descarta `_e`.

**Impacto:** bajo (la escritura atómica propia sí está bien manejada, ver sección 3), pero rompe la premisa de "siempre hay un backup válido" que S-03 y el camino de recuperación asumen.

**Propuesta:** hacer `rotate()` devolver `bool` (o `int` de errores), loguear `push_error` en cada rename fallido, y que `_process_queue` lo tenga en cuenta.

---

### S-06 — 🟢 BAJO: El guardado de cierre bypassa la cola y la rotación, y no chequea `_writing`

**Archivo:** `save_manager.gd:130-137`.

```gdscript
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and current_slot >= 1 and not _blocked:
		var payload := _payload_para_slot(current_slot)
		if SaveWriter.write_atomic(current_slot, payload):   # ← directo, sin rotate(), sin cola
			_dirty = false
			...
```

**Falla (dos partes):**
1. Escribe directamente sin `SaveBackup.rotate()` primero → el guardado de cierre **no rota el save anterior a `.bak`**, así que no hay backup del estado previo al cierre (inconsistente con el camino normal, `save_manager.gd:216`).
2. No chequea `_writing`. Hoy es seguro porque GDScript es single-thread y `_process_queue` es síncrono (no hay `await`), pero si M61 convierte la escritura en asíncrona (deuda declarada en `04-Codigo.md:146`), este handler puede intercalar una escritura con una en curso → carrera. Es un riesgo latente, no un bug activo.

**Impacto:** bajo (cierre es best-effort por diseño, comentario L127-129).

**Propuesta:** cuando M61 aterrice, encolar el guardado de cierre en vez de escribir directo, o al menos rotar antes y respetar `_writing`.

---

### S-07 — 🟢 BAJO: `write_atomic` / `cleanup_orphan_tmp` / `save_exists` aceptan slots fuera de rango (no validan 1..SLOT_COUNT)

**Archivo:** `save_writer.gd:62, 101, 107`.

`request_save` sí valida (`save_manager.gd:174`: `if slot < 1 or slot > SLOT_COUNT`) y `load_slot` también (`save_manager.gd:233`), pero las estáticas de `SaveWriter` no: `write_atomic(99, ...)` escribe `user://saves/slot_99.save` sin protestar. `test_slots_m59.gd:27` incluso define `SLOT_FANTASMA = 99` y lo usa para probar `slot_metadata` (que sí valida por su lado). Como los slots son `int` y las rutas usan `%d`, **no hay path traversal** (ver sección 3), pero sí se pueden crear archivos fuera del contrato de 3 slots si algún llamador interno pasa un valor no validado.

**Impacto:** bajo (hoy todos los llamadores validan; es defensa-en-profundidad ausente).

**Propuesta:** validar `slot` en `write_atomic` (y opcionalmente en las otras estáticas) y devolver `false`/`{}` si está fuera de 1..SLOT_COUNT.

---

### S-08 — ⚪ INFORMATIVO: El checksum detecta corrupción accidental, pero NO es anti-trampas (no hay secreto/HMAC)

**Archivo:** `save_writer.gd:24-41`.

El SHA-256 se calcula sobre el payload en claro y se almacena como primera línea. Cualquiera puede editar el payload y recalcular el checksum; no hay clave secreta, no hay HMAC, no hay cifrado. La propia documentación lo reconoce: `04-Codigo.md:43` — *"Cifrado para datos sensibles ⬜ Pendiente (recomendado antes de logros M72)"*.

**Consecuencia práctica:** la única barrera contra un save editado son los clamps por proveedor (sección 3, punto 8). Por eso S-01 es explotable: el checksum no detiene al editor, solo la validación de datos cargados lo haría — y ahí está el hueco.

**Por qué es ⚪ y no un defecto:** en un single-player cozy, el anti-trampas no es un requisito (el jugador se perjudica a sí mismo). Pero la auditoría debe dejarlo explícito: **no hay integridad criptográfica contra manipulación**, solo contra bit-rot.

---

### S-09 — ⚪ INFORMATIVO: `SaveSchema.validate()` es prácticamente vacua contra saves reales (su único chequeo de rango nunca se dispara)

**Archivo:** `save_schema.gd:178-181`.

```gdscript
if payload.has("time") and typeof(payload["time"]) == TYPE_DICTIONARY:
	var time_dict: Dictionary = payload["time"]
	if time_dict.has("day") and not _es_entero(time_dict["day"]):   # ← "day" NO existe en disco
		errors.append("time.day no es int")
```

El schema declara `time: {day, season, hour, minute}` (`save_schema.gd:63-68`), pero el proveedor real (`game_clock.gd:240-247`) emite el dialecto `hora/minuto/dia/mes/anio/acumulador/...`. Como `collect()` reemplaza la sección entera (`save_snapshot.gd:44-45`), en disco **no hay `time.day`**, así que `time_dict.has("day")` es siempre `false` y el único chequeo de rango de `validate()` nunca corre. La documentación lo admite: `04-Codigo.md:292` — *"SaveSchema.validate() es prácticamente vacua contra saves reales"*.

**Consecuencia:** la validación de esquema no es una barrera real; toda la defensa de rangos vive en los proveedores (que sí clanean, ver sección 3 punto 8). Esto es deuda técnica conocida, no un bug activo — pero significa que "pasar `validate()`" no garantiza nada sobre los valores.

---

### S-10 — ⚪ INFORMATIVO: Validaciones de tipo ausentes en campos no críticos

- `save_schema.gd:162-163`: `profile_id` solo se chequea por **presencia**, no por tipo. Un save con `profile_id: [1,2,3]` o `{"x":1}` pasa `validate()`; `completar` (`save_schema.gd:125`) hace `String(...)` y lo stringifica. No se usa para nada sensible hoy.
- `game_clock.gd:255`: `_acumulador = float(data.get("acumulador", 0.0))` — **sin clamp**. Un save con `acumulador: 1e30` carga ese valor (haría avanzar el reloj muy rápido; los clamps de `dia/mes` contienen el desbordamiento de fecha, pero no el salto de tiempo). `float("abc")` devuelve `0.0`, así que no hay crash.
- `save_writer.gd:62`: `write_atomic` no valida rango de slot (ver S-07).

---

## 3. Lo que está BIEN (con `archivo:línea`)

Un auditor honesto reporta ambas caras. Estos puntos me convencieron de que el núcleo es sólido:

1. **Escritura atómica correcta.** `save_writer.gd:62-98`: escribe `.tmp` → verifica que el `.tmp` no quedó vacío/corrupto re-parseándolo (L87-90) → `rename_absolute` atómico del SO (L93). Ante cualquier fallo, el `.save` anterior queda intacto. Además verifica el retorno de `store_string` (L80-84), que es `bool` desde Godot 4.4 — un pitfall documentado que muchos proyectos ignoran.

2. **Checksum determinista bien diseñado.** `save_writer.gd:11-15, 38-41`: el formato es `checksum\npayload` y el hash se calcula sobre la cadena **exacta** almacenada, no sobre un re-serializado. La documentación (`04-Codigo.md:152, 163`) explica por qué: el round-trip JSON no es determinista para hashear. Esto evita falsos positivos de corrupción.

3. **Recuperación ante corte mid-write.** Si el juego muere entre la rotación y la escritura, queda `.bak` sin `.save` → `save_loader.gd:30-39` lo detecta y devuelve `RECOVERED` en vez de `NOT_FOUND`. Si muere durante la escritura, queda un `.tmp` huérfano y el `.save` anterior intacto → `save_manager.gd:278-280` (`_process_init_cleanup`) lo borra al arrancar. Ambos caminos están probados: `test_rotate_m59.gd:137-151` (b3) y `test_rotate_m59.gd:204-218` (b7).

4. **Orden de rotación corregido (regla dura).** `save_manager.gd:205-216`: `rotate()` corre **antes** de `write_atomic()`. El comentario (L205-215) documenta el bug crítico ya corregido (rotar después dejaba el slot sin `.save`). `test_rotate_m59.gd:103-132` (b1, b2) verifica que el `.bak` conserva el save **anterior**, no el recién escrito.

5. **Rechazo de versión futura sin degradar.** `save_loader.gd:66-72` (camino principal) y `save_loader.gd:116-118` (camino de backup): un save de versión superior se rechaza con `FUTURE_VERSION` y aviso claro, **sin tocar el archivo**. El camino de backup es igual de estricto que el principal (corregido en iter. 2). Probado en `test_slots_m59.gd:135-174` y `test_rotate_m59.gd:155-168`.

6. **Sin path traversal.** Los slots son `int` y las rutas usan `%d` (`save_writer.gd:71-72, 102, 108, 111`); `request_save` valida `1..SLOT_COUNT` (`save_manager.gd:174`) y `load_slot` igual (`save_manager.gd:233`). Un slot llamado `../../algo` es imposible: no hay forma de inyectar texto en la ruta. `backup_manual` sanitiza el timestamp (`save_backup.gd:38`: reemplaza `:` y espacio). **Este punto del enunciado está bien defendido.**

7. **Sin duplicación al cargar.** `inventario_contenedor.gd:122-124`: `deserializar` **limpia todos los slots antes de cargar** (`for s in slots: s.vaciar()`), así que un load sobre estado ya cargado no acumula. Economía y gemas usan **asignación**, no acumulación: `economy_manager.gd:178` (`saldo = clampi(...)`) y `gem_currency.gd:101` (`_gemas = max(0, ...)`). **La pregunta 6 del enunciado (duplicar items/recursos) está respondida: no hay duplicación.**

8. **Clamps por proveedor (la defensa real de rangos).** Aunque `validate()` es vacua (S-09), los proveedores clanean al restaurar:
   - Economía: `economy_manager.gd:178` — `saldo = clampi(int(data.get("saldo", SALDO_INICIAL)), 0, MAX_SALDO)`. **Un save con `monedas = -9999` queda en 0; con `monedas = "abc"` → `int("abc")=0` → saldo 0; con `monedas = 99999999` → clamp a 999999.** La pregunta 1 del enunciado está respondida para economía: **no pasa valores fuera de rango**.
   - Gemas: `gem_currency.gd:101` — `_gemas = max(0, int(...))` (nunca negativo).
   - Tiempo: `game_clock.gd:250-254` — `hora` clamp [0,23], `minuto` [0,59], `dia` [1, DIAS_POR_MES], `mes` [1, MESES], `anio` ≥ 1. **Un `dia` negativo o gigante queda clampeado.**
   - Historial de economía: `economy_manager.gd:183-195` sanea cada tx (tipo `str`, montos `int`) y acota a `HISTORIAL_MAX`.

9. **`item_id` validado contra el catálogo en carga.** `inventario_contenedor.gd:130-134`: un ítem que no existe en `ItemDatabase` se ignora con `push_warning`. Esto mitiga S-01 (no se pueden inyectar ítems inventados), aunque no las cantidades.

10. **Manejo de JSON corrupto robusto.** `save_writer.gd:45-58` (`parse_document`): contenido vacío, sin newline, checksum no coincide, y payload que no es Dictionary — los cuatro casos devuelven `{"ok": false, ...}` sin lanzar. `JSON.parse_string` devuelve `null` ante error de sintaxis (comentarios, truncado, basura) y el `typeof != TYPE_DICTIONARY` (L56) lo atrapa. **La pregunta 2 del enunciado (truncado/comentarios/claves duplicadas) está cubierta: no crashea, devuelve corrupto.** Claves duplicadas: el parser de Godot se queda con la última; no hay crash.

11. **Cola serializada (un guardado a la vez).** `save_manager.gd:194-228`: `_writing` + cola FIFO evitan que un auto-save pise un guardado manual en curso. Ambos van por `request_save`. **La pregunta 4 (race autosave vs manual) está mitigada en el modelo single-thread actual** (el riesgo latente es S-06, solo si M61 lo hace async).

12. **`slot_metadata` usa el parser validado, no `JSON.parse_string` crudo.** `save_manager.gd:250-256`: usa `SaveWriter.parse_document()` (que valida checksum) en vez de parsear el archivo completo — bug ya corregido (el archivo no es JSON puro, su primera línea es el SHA-256). Probado en `test_slots_m59.gd:91-132` (b1, b2: save ilegible y checksum falso → `{}` sin crash).

13. **Defaults tolerantes al cargar.** `save_schema.gd:124-131` (`completar`) rellena secciones de nivel superior faltantes con defaults, y **deliberadamente no toca el interior** de las secciones (documentado en `save_schema.gd:117-123` y `04-Codigo.md:306`) para no inyectar claves del schema dentro de secciones con proveedor. Un save con secciones faltantes carga completando (probado en `test_rotate_m59.gd:223-246`, b8).

14. **Detección de aliasing en proveedores.** `auditar_aliasing.gd` es una herramienta headless que detecta proveedores cuyo `get_save_data()` retorna referencias vivas (si un `restore_save_data({})` vacía también el snapshot, hay aliasing). Es una defensa proactiva contra corrupción silenciosa.

15. **Suites con guardia anti-falso-verde.** `test_rotate_m59.gd` y `test_slots_m59.gd` usan triple guardia: `_fin(clave)` por bloque (un bloque que no cierra no corrió), `CHECKS_MINIMOS` medido en verde (piso, no estimado), y `_summary()` en `call_deferred` separado (sobrevive a un script error y decide el exit code). `validate_save.gd` cerró la ceguera del camino feliz con `_test_carga_valida` (aserción explícita de `LoadResult.OK`, `validate_save.gd:44-69`).

---

## 4. Respuesta directa a las 9 preguntas del enunciado

| # | Pregunta | Respuesta |
|---|---|---|
| 1 | ¿`validate` valida TIPOS y RANGOS? ¿`monedas=-9999`/`"abc"` pasa? | `validate()` solo presencia + tipo de sección + `schema_version` (`save_schema.gd:151-183`); su único chequeo de rango (`time.day`) es código muerto contra saves reales (S-09). **Pero** los proveedores clanean: `monedas=-9999`→0, `"abc"`→0, exceso→999999 (`economy_manager.gd:178`). **No pasa fuera de rango.** El hueco real es la cantidad de ítems (S-01). |
| 2 | ¿JSON truncado/comentarios/claves duplicadas/payload enorme? | Truncado/comentarios/basura → checksum o parseo falla → `CORRUPTED`, sin crash (`save_writer.gd:45-58`). Claves duplicadas: última gana, sin crash. **Payload enorme: sin cap de tamaño (S-02).** |
| 3 | ¿Sanity checks en load (negativos, tipos, arrays vacíos, IDs inexistentes)? | Sí por proveedor: clamps de economía/gemas/tiempo (punto 8 de sección 3), `item_id` contra catálogo (`inventario_contenedor.gd:130-134`), `idx` bounds-checked (`inventario_contenedor.gd:127`). **No**: cantidad vs `stack_max` (S-01), tamaño de archivo (S-02), claves de sección como índices (S-01). |
| 4 | ¿Race autosave vs manual? ¿Locks? ¿Cierre mid-write? | Cola serializada con `_writing` (`save_manager.gd:194-228`) → no se pisan en single-thread. Sin locks de archivo (dos instancias simultáneas podrían intercalar, caso límite). Cierre mid-write: `.tmp` huérfano + `.save` intacto + recuperación desde `.bak` (punto 3 de sección 3). Riesgo latente si M61 hace async (S-06). |
| 5 | ¿Backup y rotación se pisan? ¿Save corrupto reemplaza al backup bueno? | Usan nombres distintos (`slot_N_rK.bak` vs `slot_N_manual_*.bak`, `save_backup.gd:39, 65`) → no colisionan. La rotación preserva el save **anterior** (orden corregido, punto 4 de sección 3). **Pero**: rotación ignora errores de rename (S-05) y recuperación solo prueba r1, no r2 (S-03). |
| 6 | ¿Duplicación al cargar? | **No.** `deserializar` limpia antes de cargar (`inventario_contenedor.gd:122-124`); economía/gemas asignan, no acumulan. |
| 7 | ¿Path traversal? ¿Slot `../../algo`? | **Defendido.** Slots son `int` con `%d` en rutas + validación de rango (`save_manager.gd:174, 233`; `save_writer.gd:71-72`). No hay forma de inyectar texto en la ruta. |
| 8 | ¿Errores silenciados? | Sí, puntuales: rotación ignora retornos de rename (`save_backup.gd:27, 30`); `cleanup_orphan_tmp` ignora el retorno de `remove_absolute` (`save_writer.gd:104`); y el mayor: un proveedor que lanza deja `_writing=true` para siempre (S-04). Los `push_warning`/`push_error` del núcleo sí se emiten (no se tragan). |
| 9 | ¿Anti-trampas / checksums / confianza ciega? | Checksum SHA-256 contra corrupción **accidental** (`save_writer.gd:24-41`), **no anti-trampas** (sin secreto/HMAC, S-08). Confianza en el contenido: parcial — se valida estructura y `item_id`, pero no cantidades (S-01) ni tamaño (S-02). Cifrado pendiente (`04-Codigo.md:43`). |

---

## 5. Autoevaluación

**¿Me sentí cómoda en el nicho de seguridad?** Sí, marcadamente más que en L-01/L-02. La diferencia es que aquí el método es naturalmente adversarial: "pensá como un atacante y como un usuario con un save corrupto" encaja con trazar cadenas de llamada buscando dónde la entrada no validada toca estado mutable. L-01 (auditoría de skills) y L-02 (cierre honesto de M150) eran tareas de inventario y de honestidad documental; esta fue de rastreo de flujo de datos, que es el corazón del análisis de seguridad.

**¿Fue distinto de L-01/L-02?** Sí. En L-01/L-02 el riesgo era la omisión (no ver un archivo o no registrar un `[?]`). Aquí el riesgo es el opuesto: inventar vulnerabilidades que no existen o pasarlas por alto leyendo por encima. Me obligué a verificar cada sospecha contra el código real antes de escribirla, y a citar `archivo:línea` para cada claim — incluyendo los puntos donde el sistema es sólido (sección 3), que son la mitad del trabajo de un auditor honesto.

**¿CyberGym 87.9 se reflejó o fue ojo clínico general?** Mezcla, y quiero ser honesta sobre la proporción. Lo que vino del entrenamiento de seguridad: el patrón "validar tipos y rangos en la frontera de entrada", "checksum sin secreto ≠ anti-tamper", "no confiar en claves de diccionario como índices", "cap de tamaño antes de leer a memoria", "un error en medio de una sección crítica debe dejar el sistema en estado recuperable". Lo que fue específico del proyecto y requirió lectura real: el dialecto schema-vs-proveedores (`dia` vs `day`), el `int(id)`→0 documentado por el propio proyecto, el orden rotate→write, y los clamps por proveedor que neutralizan varias de mis sospechas iniciales (empecé pensando que `monedas=-9999` pasaba; la lectura de `economy_manager.gd:178` demostró que no). Esa corrección —descartar una sospecha al verificarla— es exactamente lo que separa una auditoría válida de una que inventa bugs. No habría podido saber que el proyecto ya documentaba el `int("items")→0` sin leer `save_schema.gd:117-123`.

**Balance honesto:** encontré 4 defectos medios (S-01 a S-04), 3 bajos (S-05 a S-07) y 3 informativos (S-08 a S-10), y 15 puntos sólidos verificados. El más sustantivo es S-01 (inyección de cantidad de ítems vía clave de sección + falta de `stack_max` en carga), con cadena de llamada completa y corroboración en la propia documentación del proyecto. No inventé ninguna vulnerabilidad: cada hallazgo tiene una ruta de ejecución verificable, y cada "esto está bien" tiene el código que lo demuestra.

---

**Modelo:** ling-3.1-flash
**Plataforma:** Kilo Gateway
**Fecha:** 2026-10-06 09:24
