**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11 (último modificador)

# 04-Codigo.md — Módulo 60: Datos y Serialización

> ⚠️ **ESTADO 2026-09-11: iter. 3 IMPLEMENTADA** por DeepSeek-V4.1-Flash (WorkBuddy). Núcleo iter. 1 por deepseek-v4-flash (Kilo Code, 2026-09-01) · guardado asincrónico iter. 2 (2026-09-11) · construcciones/backups/compresión/catálogos perezosos iter. 3 (2026-09-11). La estructura de archivos real difiere de la prevista (res://datos/ → res://scripts/datos/ por convención del proyecto); las firmas públicas se respetan con nombres reales.

## 1. Ubicación de archivos (REAL, implementado)

```
game/isla-ancestral/scripts/datos/
├── data_store.gd               ← Autoload "DataStore" (registrado en project.godot)
├── serializador.gd             ← class_name Serializer (JSON + binario IAVX1 + a_plano)
├── versionador.gd              ← class_name Versionador (VERSION_ACTUAL=1 + migraciones)
├── validador.gd                ← class_name Validador (CRC32 + contrato por versión)
├── writer_atomico.gd           ← class_name WriterAtomico (.bak→.tmp→rename + variante cruda para config)
├── gestor_slot.gd              ← class_name GestorSlot (rutas user://saves/slot_N/)
├── gestor_config.gd            ← class_name GestorConfig (ConfigFile user://config.cfg con defaults)
├── catalogos_estaticos.gd      ← class_name CatalogosEstaticos (índice perezoso de res://data/items/)
├── estructuras_codec.gd        ← class_name EstructurasCodec (codec sección "buildings") — iter. 3
├── buildings_save_provider.gd  ← class_name BuildingsSaveProvider (ISaveProvider "buildings") — iter. 3
├── gestor_backups.gd           ← class_name GestorBackups (ventana de 3 copias .bak) — iter. 3
├── test_datos_m60.gd           ← Test headless de regresión (94 checks, 0 fallos)
├── test_datos_m60_iter3.gd     ← Test headless iter. 3 (132 checks, 0 fallos)
└── test_datos_m60_iter4.gd     ← Test headless iter. 4 (152 checks, 0 fallos)
```

**Diferencias vs plan previsto:** la ruta `res://datos/` del plan se implementó como `res://scripts/datos/` (convención real del proyecto, guía 07 §4.1: scripts en `scripts/`). `migraciones/` y `esquemas/` se integraron en versionador.gd y validador.gd respectivamente (funciones puras + `_esquema_para`). `CatalogosEstaticos` lee los `.tres` reales de M159 en `res://data/items/` (**111 items reales** a 2026-09-15; el plan decía 19, el catálogo creció).

## 2. Registro en project.godot (REAL)

```
[autoload]
DataStore="*res://scripts/datos/data_store.gd"
```

## 3. API pública implementada

### 3.1 `data_store.gd` — autoload (sin class_name, §9.17/§9.41)

```gdscript
signal guardado_slot(slot, ok, duracion_ms, bytes)
signal cargado_slot(slot, ok, error)
signal config_lista(config)
signal config_guardada(ok)
# iter. 2 (RF10):
signal guardado_async_iniciado(slot)
signal guardado_async_encolado(slot, reemplazo)

# iter. 3 (progreso visible, M62):
signal guardado_async_progreso(slot, porcentaje)   # 0.0 → 1.0

guardar_partida(slot, datos_sistemas) -> Dictionary   # {ok, error, duracion_ms, bytes, checksum}
cargar_partida(slot) -> Dictionary                    # {ok, slot, datos|error}
migrar(datos) -> Dictionary                           # delega a Versionador
borrar_slot(slot) -> bool
listar_slots() -> Array
guardar_config(datos) -> Error
cargar_config() -> Dictionary
cargar_mundo_voxel(slot) -> PackedByteArray

# iter. 2 (RF10) — guardado fuera del hilo principal:
guardar_partida_async(slot, datos_sistemas) -> Dictionary  # {ok, aceptado, encolado, reemplazo, error}
guardado_en_curso() -> bool
slot_en_curso() -> int
ultimo_resultado_async() -> Dictionary                 # mismo formato que guardar_partida
```

### 3.2 `serializador.gd` — Serializer (static)
`a_json`, `desde_json`, `a_json_canonico` (claves ordenadas), `a_plano` (Vector2/3/Vector2i/3i/Color/float → arrays planos RN9), `normalizar_float` (4 dec), `vector3i_a_array`, `a_binario_voxel`/`desde_binario_voxel` (magic `IAVX1`, int32 x3 coord + int32 num + int32 voxeles).

### 3.3 `versionador.gd` — Versionador (static)
`VERSION_ACTUAL=1`, `MIGRACIONES` (Array[Callable], vacío en v1), `migrar(datos)` (copia en memoria, orden estricto, nunca salta), `version_futura`, `set_version`, `migrar_v1_a_v2` (función pura de ejemplo testeable).

### 3.4 `validador.gd` — Validador (static)
Contrato v1: `version` (int — normaliza float→int de JSON, §9.54), bloques obligatorios `[jugador, inventario, tiempo, mundo_voxel, meta]`, tipos internos (jugador.pos Array, inventario.slots Array, meta Dictionary). `calcular_crc32` (tabla estándar 0xEDB88320 sobre JSON canónico sin checksum), `verificar_integridad`, `crc32_hex`.

### 3.5 `writer_atomico.gd` — WriterAtomico (static)
`escribir_atomicamente(ruta, contenido_str)` (patrón §9.11: backup→.tmp→verify→rename→restauración), `restaurar_backup`, `construir_con_checksum` (CRC32 línea 1 + payload exacto), `parsear_documento`, y variante cruda `escribir_atomicamente_crudo`/`parsear_documento_crudo`/`construir_con_checksum_crudo` para ConfigFile (no es JSON).

### 3.6 `gestor_slot.gd` — GestorSlot (static)
Rutas `user://saves/slot_N/save.json` + `mundo_voxel.bin` + `meta.json` + `.bak`. `asegurar_directorio`, `existe_slot`, `borrar_slot`, `listar_slots` (solo meta.json, rápido), `leer_meta`, `escribir_meta`, `meta_default`.

### 3.7 `gestor_config.gd` — GestorConfig (static)
`cargar_config` (defaults + merge de claves futuras), `guardar_config` (ConfigFile → wrapper crudo con checksum). Secciones `graficos/audio/accesibilidad`. Config independiente de slots (user://config.cfg).

### 3.8 `catalogos_estaticos.gd` — CatalogosEstaticos (static)

**iter. 3 — carga perezosa (T-145/T-201).** Ya NO carga todos los `.tres` al arranque: construye un **índice** `id → ruta` leyendo los NOMBRES de archivo de `res://data/items/` con `DirAccess` (sin `load()`), y carga el Resource recién al pedirlo, con caché.

`indexar()` (una vez), `obtener_item(id)` (carga perezosa + caché), `tiene_item(id)` (consulta el índice, sin cargar), `contar_items()` (tamaño del índice), `contar_cargados()`, `cargar_todos()` (precarga explícita), `rutas_indexadas()`, `_reset_para_test()`. El dict `items` se conserva por compatibilidad. Fallback limpio si falta el directorio (índice vacío, sin crash).

### 3.9 `estructuras_codec.gd` — EstructurasCodec (static) — iter. 3

Codec puro de la sección `buildings` (construcciones/casas, RF3 M17/M18). No conoce el árbol de escena ni a M17.

- `SECCION = "buildings"`, `MAX_ESTRUCTURAS = 20000`, `CLAVES = ["id","tipo","pos","rot_y","planta","variante"]`.
- `normalizar(estructuras) -> Array` — ordena por `id` → **checksum determinista** (RN9); normaliza `pos` a int32 y `rot_y` a múltiplo de 90 en [0,270].
- `pos_a_int32(v) -> Array`, `rot_normalizada(v) -> int`.
- `validar(estructuras) -> Array[String]` (vacío = OK): tipos, ids duplicados, límite.
- `a_seccion(estructuras) -> Dictionary` / `desde_seccion(seccion) -> Array` — ida y vuelta tolerante.
- `contar(estructuras) -> int`, `huella(estructuras) -> String` (CRC32 hex del JSON canónico, para diagnóstico).

### 3.10 `buildings_save_provider.gd` — BuildingsSaveProvider (ISaveProvider) — iter. 3

Provider de la sección `buildings` para el `SaveManager` de M59. Duck-typing, re-evaluado en cada llamada:

- `fuente() -> Object` — busca en el árbol un nodo con `obtener_estructuras`/`restaurar_estructuras` (patrón `PlayerSaveProvider._buscar_jugador()`). **Se re-evalúa por llamada**: M17 puede registrarse más tarde sin re-crear el provider.
- `tiene_fuente() -> bool`.
- `get_save_data() -> Dictionary` → `{"structures": []}` cuando no hay fuente (**nunca** devuelve referencias vivas — regla anti-aliasing BUG-014).
- `restore_save_data(datos)` — no-op tolerante con warning si la fuente no expone el método de restauración.
- `get_section_name() -> String` → `"buildings"`.

`DataStore._ready()` lo registra en el `SaveManager` de forma idempotente y tolerante (si M59 no está, no falla).

### 3.11 `gestor_backups.gd` — GestorBackups (static) — iter. 3

Ventana de copias de seguridad coordinada con M107 (T-075). **No** referencia `WriterAtomico` (evita dependencia circular).

- `SUFIJO_BAK = ".bak"`, `MAX_BACKUPS = 3`.
- `ruta_copia(base, i)` — `i<=0` → `.bak`, `i>0` → `.bak.i`.
- `rotar(base) -> int` — descarta la más vieja, corre las demás, `.bak` → `.bak.1`.
- `listar(base) -> Array[String]`, `contar(base) -> int`.
- `restaurar(base, i := 0) -> Error` (M107), `limpiar_antiguos(base) -> int`, `espacio_usado(base) -> int`, `mantener_slot(slot) -> Dictionary`.

`WriterAtomico` delega: `restaurar_backup(ruta)` → `GestorBackups.restaurar(ruta, 0)`; nuevos `restaurar_backup_indice(ruta, indice)` y `copias_backup(ruta)`. La rotación reemplazó los dos bloques que hacían `remove_absolute` de un único `.bak`.

### 3.12 Compresión ZIP_DEFLATE del voxel — iter. 3 (T-111/T-166)

`DataStore.comprimir_mundo_voxel(slot)` comprime `mundo_voxel.bin` a `mundo_voxel.bin.deflate` con `FileAccess.open_compressed(..., COMPRESSION_DEFLATE)` cuando el archivo supera `UMBRAL_COMPRESION_BYTES = 65536`. Casos: ya comprimido / bajo el umbral / no reduce / comprime OK. `cargar_mundo_voxel(slot)` **prefiere** el `.deflate` si existe y cae al plano. `descomprimir_mundo_voxel(slot)` revierte. El formato interno `IAVX1` NO cambia.

### 3.13 APIs de la iter. 4 (cierre de huecos verificables) — iter. 4

**`Versionador`**
- `migrar_con_cadena(datos, cadena, objetivo) -> {ok, datos|error}`: motor de migración con **cadena y objetivo inyectables**. `migrar(datos)` ahora delega aquí (`migrar_con_cadena(datos, MIGRACIONES, VERSION_ACTUAL)`) — el comportamiento de producción NO cambia. Permite probar en headless los caminos que la producción todavía no alcanza con `MIGRACIONES` vacío: N saltos reales, cadena incompleta, migración que no avanza versión, save sin versión, idempotencia y post-validación contra el contrato destino.
- Patrones puros reutilizables: `renombrar_campo(datos, viejo, nuevo, por_defecto)` · `eliminar_campo(datos, campo)` · `transformar_valor(datos, campo, fn)`. Ninguno muta la entrada.

**`DataStore`**
- `_log_m60(nivel, mensaje)`: registro centralizado en M103 (antes: 4 bloques `get_node_or_null("/root/GameLogger")` duplicados). Tolerante: sin M103 no hace nada.
- La carga registra el **salto real de versión** (`save del slot N migrado vX -> vY`) y el **resultado del contrato** cuando falla.
- `VALIDAR_AL_GUARDAR = true`: validación de contrato **antes** de escribir, como **detección temprana NO bloqueante** (avisa al log, jamás impide guardar: un save parcial legítimo no debe perderse).
- `_regenerar_meta_si_falta(slot)`: si un slot conserva `save.json` pero perdió `meta.json`, la regenera al cargar → el menú de M59/M53 vuelve a listarlo.
- `_guardar_voxel_binario` rota `.bak` del **binario voxel** (misma ventana de 3 copias que el save).

**`GestorSlot.borrar_slot`**
- Ahora borra también `mundo_voxel.bin.deflate` y las copias de backup del save **y** del voxel (antes quedaban huérfanas: el directorio del slot no se podía eliminar y el espacio no se recuperaba).
- Devuelve `false` si el slot no tenía **ningún** archivo (antes devolvía `true` sin haber borrado nada: mentía al llamador).

**`CatalogosEstaticos.validar_ids(ids) -> Array[String]`**
- Contrasta una lista de ids referenciados (por código, por save o por recetas) contra el catálogo real y devuelve los que **no existen**, en el orden recibido. No carga Resources (usa el índice), así que es barato llamarlo en QA.

## 4. Convenciones respetadas
- GDScript puro (Godot 4.7), errores como valores de retorno, jamás excepciones en el hilo de carga.
- Todo IO en `user://`; nunca `res://` para escritura (RN5).
- DataStore sin conocimiento de UI: señales + dicts/bytes (RN7).
- Logs: DataStore registra en ServiceRegistry como "datos" y loguea vía GameLogger (M103) cuando existe.
- IDs estables, snake_case, checksum sobre cadena exacta (patrón §9.11 de guía 07).

## 5. Definición de listo (DoD) — cumplimiento 2026-09-01
1. ✅ DataStore autoload registrado y sin errores; boot limpio (get_debug_output sin errores del módulo).
2. ✅ Guardar/cargar slot completo (JSON + checksum CRC32 + binario voxel IAVX1) verificado end-to-end.
3. ✅ Migración v0→v1 y función pura v1→v2 testeada en aislamiento (fixture).
4. ✅ Save corrupto detectado por checksum sin crash + restauración de .bak probada.
5. ✅ Config guardada/leída con defaults y claves nuevas de "versión futura".
6. ✅ Tiempos medidos (guardado 10 ms en test; cargar << 1 s objetivo RN1).
7. ✅ Checklist del módulo actualizado; test headless 66/0 OK; regresión M59 13/13 OK.

## Notas del Agente — iter. 1 (2026-09-01)

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 con pendientes NO bloqueantes

### Lo que hice
- Implementé los 8 componentes + test headless en `scripts/datos/` (66 checks, 0 fallos) según el contrato del plan (03-Diseno/04-Codigo).
- Integré con M59: el DataStore usa sus propias rutas `user://saves/slot_N/` SIN pisar los `.save` planos de M59 (`user://saves/slot_N.save`); M59 Sigue siendo el dueño del autosave/UI; M60 es la capa de datos/versionado estandarizada (contrato §3.6 del 03-Diseno). El Snapshot de M59 sigue intacto.
- Registré el autoload `DataStore` y el servicio `datos` en ServiceRegistry.
- Integré CatalogosEstaticos con los `.tres` reales de M159 (19 items cargados).
- Documenté 2 errores nuevos en guía 07 (§9.54 JSON float round-trip, §9.55 FileAccess close en Windows).

### Lo que NO pude hacer (honestidad obligatoria)
- [M] El guardado en hilo secundario (RF10/RN1 asíncrono) NO se implementó en esta iteración: la escritura atómica actual es síncrona pero < 300 ms en test (10 ms). El hilo/WorkerThreadPool es tarea de M62/M63 (debido a su presupuesto de frame). Verificado: el objetivo RN1 se cumple en sincrono para el tamaño actual.
- [M] La implementación de `chunks` del mundo voxel usa la estructura contractual `{coord: Vector3i, voxeles: PackedInt32Array}`; el formato real de Voxel Tools (M08) requiere confirmación del agente de M08 al conectar (documentado en plan-inicial).
- [M] No se implementó UI de slots (es M53/M59, fuera de alcance §3.2).
- [M] CatalogosEstaticos lee solo items (M159); recetas/cultivos (M16/M33) se agregan cuando existan sus .tres (fallback limpio garantizado).

### Intentos fallidos / decisiones
- **Decisión D-núcleo:** el checksum final se calcula sobre la cadena EXACTA del payload (línea 1 + payload literal, patrón §9.11) y NO sobre un dict re-serializado (round-trip NO determinista, ya documentado). Se mantiene `calcular_crc32(dict)` como fingerprint canónico para comparaciones puras.
- **Error resuelto:** `JSON.parse_string` devuelve float para enteros en Godot 4.7 → validador normaliza version (1.0→1). Documentado §9.54.
- **Error resuelto:** `FileAccess.open(...).store_string(...)` sin `.close()` deja el archivo bloqueado en Windows → borrar falla. Documentado §9.55.

### Recomendaciones para el próximo agente
- Conectar M08: confirmar si el `chunk edits` real usa el contrato documentado o requiere adaptación (`desde_binario_voxel` ya valida magic y límites).
- Cuando suba `VERSION_ACTUAL`: agregar migración NUEVA en `MIGRACIONES` + `migrar_vN_a_vN1` pura; jamás editar las existentes.
- Para hilo secundario (RF10): envolver `guardar_partida` con `WorkerThreadPool.add_task` cuando M62 defina el presupuesto; la señal `guardado_slot` ya está prevista para el progreso UI.

## Notas del Agente — iter. 2 (2026-09-11)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Estado:** RF10 implementado (iter. 2), 🟡 con pendientes NO bloqueantes (los mismos de iter. 1 salvo los cerrados aquí)
**Log:** 825

### Lo que hice
- **RF10 — guardado asincrónico real.** `guardar_partida_async(slot, datos)` arranca un `Thread` que hace SOLO IO (serializar → checksum → `WriterAtomico` → meta → voxel). El hilo principal nunca toca disco: `_process` hace un poll barato (`is_alive()`) y recién al terminar une el hilo (`wait_to_finish()`), emite `guardado_slot` y arranca la cola. Cerré: `RF10: serialización de guardado fuera del hilo principal [C]`, `M62: IO del guardado en hilo secundario [C]`, `Optimización: IO en hilo secundario, UI nunca bloqueada [M]`, `Testings: test de hilo [C]`.
- **Edge case doble guardado concurrente → COLA (no bloqueo).** Si ya hay un guardado en curso, la segunda petición se encola con **profundidad 1 y "la última gana"** (`_cola_guardado` se reemplaza, `reemplazo=true`). Nunca se escriben dos veces el mismo archivo en paralelo. Cerré: `Edge case: doble guardado concurrente [M]`.
- **Thread-safety sin locks.** El `Dictionary` se copia con `duplicate(true)` en el hilo llamador: el consumidor puede seguir mutando su copia sin corromper la escritura en curso. Los helpers (`Serializer`/`Validador`/`WriterAtomico`/`GestorSlot`) son `class_name ... extends RefCounted` (estáticos, sin árbol de escena) → seguros desde un hilo. `DataStore` es el único autoload y NO se accede a él desde el hilo.
- **Cierre ordenado.** `_exit_tree()` une el hilo si quedó vivo (evita el warning `ObjectDB leaked` por Thread).
- **§28 — saneo de BOM.** `data_store.gd` tenía BOM en el working tree (HEAD limpio); se removieron los 3 bytes y se re-verificó el test (94/0).
- **Fallback seguro.** Si `Thread.start()` falla (err != OK), cae al camino sincrónico: nunca se pierde un guardado por falta de hilo.
- **Test headless de hilo** (`_test_datastore_async`, 28 checks nuevos): verifica que la llamada no bloquea (< 50 ms), que el hilo queda en curso, que el 2.º guardado se encola y el 3.º lo reemplaza, la secuencia de señales `iniciado(2)→fin(2)→iniciado(2)→fin(2)`, que el disco queda con la ÚLTIMA petición y que el encolado descartado no escribió. **Total M60: 94 checks / 0 fallos** (antes 66/0). Estable en 3 corridas.

### Lo que NO pude hacer (honestidad obligatoria)
- [C] **Compresión ZIP_DEFLATE** de `mundo_voxel.bin` (`Compresión ZIP_DEFLATE opcional`, `Optimización: compresión bajo demanda`) — NO hecha: requiere tocar el contrato binario `IAVX1` y no hay todavía un caso real que supere el presupuesto de tamaño.
- [S] **Carga perezosa de catálogos** — NO hecha: riesgo de regresión en `CatalogosEstaticos` (usado por M15/M16/M33) sin beneficio medido aún.
- [M] **UI de progreso + UI deshabilitada durante guardado** (`M62: progreso visible`, `M62: UI interactiva deshabilitada`) — fuera de alcance de M60: son de UI (M53/M59). El DataStore ya expone las señales necesarias (`guardado_async_iniciado`, `guardado_async_encolado`, `guardado_slot`); falta el consumo en la capa de UI.
- [M] **Presupuestos RN verificados con el Profiler** — no verificado: requiere build con GUI; en headless solo se miden duraciones por `Time.get_ticks_msec()`.
- [C] **Contrato de "edits" de M08** — sigue pendiente de confirmación del agente de M08 (heredado de iter. 1).
- [S] **Rotación/limpieza de `.bak`** — pendiente de coordinación con M107 (heredado de iter. 1).

### Intentos fallidos / decisiones
- **Decisión D-hilo:** se usó `Thread` (no `WorkerThreadPool`). Motivo: el guardado es una operación **única, larga y con orden estricto** (serializar → escribir → meta → voxel) y necesita un resultado tipado (`wait_to_finish()` devuelve el Dictionary); con `WorkerThreadPool` habría que agregar sincronización manual para recuperar el resultado. La recomendación de iter. 1 apuntaba a `WorkerThreadPool`; se documenta el cambio. Si M62 exige paralelismo con otras tareas, migrar es directo: `_tarea_guardado` ya es una función pura de IO.
- **Decisión D-cola:** profundidad 1 ("la última gana") en vez de cola ilimitada o bloqueo. Un doble guardado concurrente casi siempre es el mismo estado actualizado (autosave + guardado manual) → encolar N escrituras es desperdicio y bloqueo de la UI; quedarse con la última es lo correcto y acota memoria.
- **Observación (no es un fallo de M60):** el test ahora corre varios frames (`await process_frame`) y eso deja que el mundo (terreno voxel con meshing en hilos propios, NPCs, UI) se construya más antes del `quit()`. Resultado: el warning `ObjectDB instances were leaked at exit` sube de 58 (test sin frames) a 385 (test con frames). Verificado con `--verbose`: **cero `Leaked instance: Thread`** → no es una fuga introducida por M60, es un artefacto preexistente de cierre del proyecto que escala con los frames corridos. Se deja registrado para quien audite fugas.

### Recomendaciones para el próximo agente
- Conectar la UI (M53/M59) a las señales nuevas: `guardado_async_iniciado` para mostrar progreso, `guardado_async_encolado` para avisar "se guardará al terminar", `guardado_slot` para el confirm final. Deshabilitar el botón de guardar mientras `guardado_en_curso()` sea `true` (o confiar en la cola, que ya es segura).
- Si se agrega `VERSION_ACTUAL` nueva: migración NUEVA en `MIGRACIONES`; jamás editar las existentes.
- Si M62 pide paralelismo: migrar `_tarea_guardado` a `WorkerThreadPool` es un cambio localizado (la cola y el poll de `_process` se reemplazan por `is_task_completed`).

- El test corre con: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd` (94 checks).

## Notas del Agente — iter. 3 (2026-09-11)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Estado:** soporte de M59 completado (iter. 3), 🟡 con 5 `[?]` honestos y 0 `[ ]`
**Log:** 827

### Lo que hice
- **RF3 construcciones (T-018).** `EstructurasCodec` (codec puro) + `BuildingsSaveProvider` (ISaveProvider). La sección `buildings` queda normalizada (**orden por `id`** → el CRC32 es determinista, RN9), con validación de tipos/duplicados/límite (20000) y `pos` a int32 (`Vector3i`/`Vector3` → `[x,y,z]`). El provider **re-evalúa la fuente en cada llamada** (M17 puede registrarse después) y, sin fuente, devuelve `{"structures": []}` — nunca referencias vivas (BUG-014). `DataStore._ready()` lo registra de forma idempotente y tolerante.
- **Backups con rotación (T-075).** `GestorBackups`: ventana de 3 copias (`.bak`, `.bak.1`, `.bak.2`), `rotar`/`restaurar`/`limpiar_antiguos`/`espacio_usado`. `WriterAtomico` delega en él (sin dependencia circular) y expone `restaurar_backup_indice`/`copias_backup`. `DataStore` rota automáticamente al guardar (`mantener_backups`).
- **Compresión ZIP_DEFLATE (T-111/T-166).** `comprimir_mundo_voxel` con `open_compressed(..., COMPRESSION_DEFLATE)` y umbral 64 KiB; `cargar_mundo_voxel` prefiere `mundo_voxel.bin.deflate`. El formato `IAVX1` no cambia.
- **Catálogos perezosos (T-145/T-201).** `CatalogosEstaticos` ahora indexa por **nombre de archivo** (sin `load()`) y carga/cachea por item. `contar_items()` no despierta ningún Resource.
- **Progreso del guardado (T-130).** Señal `guardado_async_progreso(slot, pct)` emitida desde `_process` solo cuando cambia + `progreso_guardado()`. El hilo escribe un `float` (`_progreso_hilo`), el hilo principal lo publica — sin señales desde el worker.
- **Presupuestos RN medidos (T-172, parcial).** `guardar=123 ms · cargar=15 ms · bytes=22537` en headless con `Time.get_ticks_msec()`.

### Lo que NO pude hacer (honestidad obligatoria)
- [?] **T-019 fauna/vecinos → BUG-025.** M19 ya serializa (`VillagerManager.get_save_data`), pero su sección `npc` (`visitantes/llegadas/partidas/avisos/enfriamientos/hogares/memoria`) NO coincide con el default del schema de M59 (`npcs`/`dialogs_seen`). `npc_manager.gd` además reclama `npc_ai`, ausente de `SaveSchema._reserved_sections`. **Delegado a M19** (no lo arreglé: la sección es su contrato).
- [?] **T-117 contrato de `edits` de M08.** Sigue sin confirmación del agente de M08 (heredado de iter. 1).
- [?] **T-131 UI deshabilitada durante guardado.** Capa de UI (M53/M59); M60 expone `guardado_en_curso()`/`progreso_guardado()`.
- [?] **T-145 `.tres` de recetas/cultivos.** Las clases tipadas **ya existen** (`CraftingRecipe`/`CropDefinition extends Resource`) pero se cargan desde `data/balance/{crafting,farming}.json` vía `CraftingService`/`FarmService`; los `.tres` son de M16/M33.
- [?] **T-172 verificación con el Profiler.** El Profiler no corre en headless; queda para la fase de build con GUI.

### Intentos fallidos / decisiones
- **Decisión D-codec:** la sección `buildings` se normaliza **ordenando por `id`** antes de calcular la huella. Sin ese orden, dos saves con las mismas construcciones en distinto orden de iteración darían CRC distinto (RN9 violado). Coste O(n log n) despreciable frente al IO.
- **Decisión D-provider-tolerante:** `BuildingsSaveProvider` no cachea la fuente. M17 (Construcción) **no tiene código todavía** (módulo reclamado por otro agente) → cachear en `_ready()` habría fijado `null` para siempre. Re-evaluar por llamada cuesta un `get_children()` sobre el árbol, aceptable en una operación de guardado.
- **Decisión D-backups:** `GestorBackups` NO referencia `WriterAtomico` aunque `WriterAtomico` sí lo usa. Evita la dependencia circular (GDScript no admite ciclos entre `class_name`).
- **Error resuelto (E-nuevo):** los `class_name` nuevos (`EstructurasCodec`, `BuildingsSaveProvider`, `GestorBackups`) no eran visibles a `--script` hasta regenerar `.godot/global_script_class_cache.cfg` → `--headless --editor --quit`. Documentado.
- **Error resuelto (E-nuevo):** `var x := ds.algo()` con base `Node`/`String(...)` → *"Cannot infer the type"*. Se anota explícitamente (`var a: Dictionary = ...`). ~25 sitios.
- **Error resuelto:** el test escribía payloads no-JSON (`"v1"`) por `WriterAtomico.escribir_atomicamente`, que exige JSON válido en `_verificar_documento` → `err=16`. Corregido con `construir_con_checksum('{"v":"%s"}')`.
- **Error resuelto:** el contrato v1 exige 5 bloques (`jugador/inventario/tiempo/mundo_voxel/meta`); los payloads de prueba de presupuestos no los tenían → "Falta bloque". Añadidos.
- **Caracterización honesta en vez de verde falso:** el check de la sección `npc` se dejó como `keys != schema_keys` (documenta la divergencia) y se registró BUG-025, en lugar de forzarlo a pasar.

### Recomendaciones para el próximo agente
- Conectar M17: implementar `obtener_estructuras()`/`restaurar_estructuras()` en el gestor de construcción; el provider ya los detecta sin cambios.
- M19: alinear la sección `npc` con el schema (BUG-025) o registrar su sección propia en `SaveSchema`.
- Si `VERSION_ACTUAL` sube: migración NUEVA en `MIGRACIONES`; jamás editar las existentes.
- Test: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter3.gd` (132 checks). Regresión: `test_datos_m60.gd` (94).

## Notas del Agente — iter. 4 (2026-09-15)

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy · **Log:** 916

**Contexto.** La auditoría del 2026-09-14 revirtió **todo** el checklist a `0/196` porque `agnes-2.5-flash` había marcado el módulo como completado sin verificación real. La reversión fue correcta en el fondo pero **demasiado ancha**: se llevó también los ítems de las iter. 2 y 3 del propio autor (DeepSeek-V4.1-Flash), que **sí** tenían test headless (94 y 132 checks, verdes hoy). Esta iteración re-marca **selectivamente** con evidencia y cierra los huecos que quedaban sin prueba ejecutable.

### Lo que hice

**1. Suite iter. 4 — 152 checks, 0 fallos ×3, 0 `SCRIPT ERROR`.** `test_datos_m60_iter4.gd`, 8 bloques con guardián anti-falso-verde (`_fin()` por bloque + watchdog `quit(1)`):
- **A (29)** motor de migración inyectable · **B (18)** patrones renombrar/eliminar/transformar · **C (27)** atomicidad, rotación y tamaños RN · **D (18)** slots y meta · **E (15)** catálogo y `validar_ids` · **F (15)** log M103 · **G (21)** integración (ServiceRegistry, SaveManager, orden del voxel) · **H (12)** formato y determinismo.
- **El guardián se probó en vivo:** aborto inyectado en el bloque D → el resumen detectó `bloques que no terminaron: ["D"]`, el conteo cayó de 152 a 128 y la salida fue `EXIT 1`. Sin ese guardián, un error de script habría dejado la suite en "0 fallos" (falso verde).

**2. Huecos REALES cerrados (no cosmética):**
- **`borrar_slot` mentía:** devolvía `true` aunque el slot no tuviera ningún archivo. Ahora devuelve `false` si no había nada que borrar.
- **Fuga de disco en `borrar_slot`:** no borraba `mundo_voxel.bin.deflate` ni las copias `.bak`/`.bak.1`/`.bak.2` del save ni del voxel → el directorio del slot no se podía eliminar y el espacio no se recuperaba. Corregido.
- **`mundo_voxel.bin` sin backup:** era el único archivo de slot sin `.bak`. Ahora rota con la misma ventana de 3 copias (ítem 120 del checklist).
- **Slot sin `meta.json`:** el slot existía y cargaba, pero `listar_slots()` no lo devolvía → el menú lo "perdía". Ahora se regenera la meta al cargar (ítem 155).
- **Sin log de migración ni de validación:** la carga no registraba el salto de versión real ni el motivo del rechazo de contrato. Ahora sí (ítems 56 y 69).
- **Sin validación al guardar:** se agregó como **detección temprana NO bloqueante** (ítem 66) — avisa al log, nunca impide escribir.
- **Motor de migración no testeable:** `migrar()` se partió en `migrar_con_cadena(datos, cadena, objetivo)` (inyectable). Sin esto, con `MIGRACIONES` vacío era imposible probar N saltos, fallo de migración o idempotencia. `migrar()` delega; producción intacta.
- **Sin patrones de migración reutilizables:** `renombrar_campo` / `eliminar_campo` / `transformar_valor` (ítems 51/52/53).
- **Sin validación de ids contra el catálogo:** `CatalogosEstaticos.validar_ids(ids)` (ítem 143).

**3. Re-marcado selectivo del checklist:** `0/196` → **`188 [x] · 4 [ ] · 4 [?]`**. Los 4 abiertos son trabajo de M08/Voxel Tools (115, 117, 122) y una optimización no implementada (168). Los 4 `[?]` honestos tienen dueño: 131 (UI de M53/M59), 133 (build de M63), 145 (`.tres` de M16/M33), 172 (Profiler, requiere build con GUI).

**4. Reconciliación de la fila 60 de `CHECKLIST-GLOBAL.md`,** que estaba en estado contradictorio: decía `🟢 Disponible | 0/196` en las columnas de estado y, en `Notas`, `✅ COMPLETADO ... 196/196`.

### Lo que NO pude hacer (honestidad obligatoria)
- **[ ] 115** — "el resto del mundo se regenera con la semilla": eso es M08 (Voxel Tools). M60 guarda y devuelve la semilla (verificado), pero no regenera nada.
- **[ ] 117** — el contrato de `edits` ajustado al formato real de Voxel Tools sigue esperando a M08.
- **[ ] 122** — no hay log con la cantidad de chunks **cargados** (sí hay `print` al guardar). Se dejó abierto en vez de marcarlo por simpatía.
- **[ ] 168** — "reutilización de dicts y buffers en bucles de guardado" no está implementada.
- **[?] 131/133/145/172** — dependen de otros módulos o de un build con GUI.

### Hallazgo colateral: BUG-041 (M103) → **FALSO POSITIVO** (verificado con sonda)
Se había reportado que **`GameLogger` no registra nada** (dos defectos: `log_buffer` nunca escrito y `categories_enabled` arrancando `{}`). **La sonda aislada demostró lo contrario** y el bug quedó reclasificado:

- `categories_enabled` **sí** se puebla en `_ready()`: `_load_config()` lo llena desde `logging_config.tres` (líneas 66-70) o **habilita TODAS** las categorías como fallback (71-73). Está poblado ya en el **frame 1**.
- `_log()` **sí emite y sí escribe a disco** (`line_emitted.emit()` + `print()` + `store_line()` + `flush()`, líneas 127-136). El archivo contiene las líneas.
- `export_all()` y `export_last_lines()` leen el **archivo**, no el buffer → devuelven contenido real.

El fallo original del bloque F era **de la propia suite** (diagnóstico mal aislado): al retirar el forzado `categories_enabled[1] = true`, el bloque F pasa **15/15** y la suite **152/0 ×3** — el forzado era un **no-op**. Ya se retiró del suite y de los comentarios.

**Residuo real (Baja, sí de M103):** `log_buffer` es **código muerto** — se declara y `_flush()` lo recorre/limpia, pero nadie hace `append`, así que `_flush()` es un no-op permanente. **No afecta al logging.** Detalle y evidencia en `DOCUMENTACION/11-BUGS.md` → BUG-041.

Los ítems 32/56/69/194 quedan `[x]` por el lado de M60: las llamadas son correctas y están **verificadas contra el logger real, tal cual** (sin forzar nada).

### Intentos fallidos / decisiones
- **Error resuelto:** `var x := ds.metodo()` con `ds` tipado `Node` → *"Cannot infer the type of ... variable"* (~37 sitios). Se anota explícitamente. Misma lección que la iter. 3, ahora con la causa exacta: **un `Node` no expone los tipos de retorno de su script**.
- **Error resuelto:** `--check-only` daba *"Static function `validar_ids()` not found"* hasta regenerar `.godot/global_script_class_cache.cfg` (`--headless --editor --quit`). Trampa ya conocida, repetida.
- **Error propio (proceso):** mandar **dos ediciones en paralelo al mismo archivo** hizo que la segunda pisara a la primera y `validar_ids` no se guardara. Lección: las ediciones sobre un mismo archivo van **secuenciales**.
- **Decisión D-validación-temprana:** validar al guardar **sin bloquear**. Rechazar el guardado habría roto a cualquier consumidor que mande un save parcial; el ítem pide "detección temprana", no "rechazo".
- **Decisión D-motor-inyectable:** se prefirió partir `migrar()` antes que subir `VERSION_ACTUAL` a 2 solo para poder testear (eso habría cambiado el esquema de todos los saves).
- **Decisión D-ventana-de-backups:** el test necesitaba 4 guardados para ver 3 copias (el 1.º no crea `.bak`). El fallo inicial del test era del test, no del código.

### Recomendaciones para el próximo agente
- **BUG-041 (M103) quedó en falso positivo** — no hay nada roto en el logging. Queda como **limpieza opcional de M103**: eliminar `log_buffer`/`_flush()` o alimentarlos de verdad.
- **M08:** al implementar el contrato de `edits`, cerrar los ítems 115/117 y agregar el log de chunks cargados (122).
- **Si `VERSION_ACTUAL` sube:** registrar la migración en `MIGRACIONES` usando los patrones nuevos; jamás editar las existentes. La rama de log `migrado vX -> vY` se activará sola.
- **Tests:** `test_datos_m60.gd` (94) · `test_datos_m60_iter3.gd` (132) · `test_datos_m60_iter4.gd` (152). Los tres deben correr ×3 y con `grep "SCRIPT ERROR"` = 0.
- **Regresión conocida:** `borrar_slot` ahora devuelve `false` para un slot in-range vacío. Si algún consumidor dependía del `true`, debe ajustarse.

---

## Notas del Agente — iter. 5 (2026-09-18)

Ítem 168 del checklist: *"Optimización: reutilización de dicts y buffers en bucles de guardado [S]"*.

### Lo que hice
- **Evalué la optimización pedida con un arnés propio** (`test_datos_m60_iter5.gd`, 5 bloques, **40 checks ×3**, 0 fallos, 0 `SCRIPT ERROR`) en vez de implementarla a ciegas.
- El arnés **no toca producción**: define localmente las variantes (buffer reutilizado, dict de destino reutilizado, BULK) y las compara contra `Serializer` **tal cual está**.
- Bloques A/B/C/D = aserciones duras: equivalencia **byte a byte con un oráculo independiente** (codificador little-endian escrito a mano, sin `encode_s32`), round-trip, equivalencia entre las 3 variantes del encoder y las 2 de `a_plano`, y **sin aliasing** de la entrada.
- Bloque E sólo **mide**: 5 rondas intercaladas, mínimo por variante, ×3 corridas.

### Resultado (medido, no afirmado)
| caso | producción (actual) | reuso de buffer/dict | BULK |
|---|---|---|---|
| 6000 chunks × 1 vóxel | **52-64 ms** | 61-80 ms | 51-69 ms |
| 400 chunks × 60 vóxeles | **38-49 ms** | 44-50 ms | 40-41 ms |
| payload de 60 entidades | **315-369 ms** | 339-394 ms | — |

Suma de los **mismos 3 casos**, mínimo de 5 rondas: **producción 410-459 ms vs reutilización 472-499 ms** → la reutilización es **1,08-1,15× MÁS LENTA**.

### Por qué la premisa era falsa
- **`PackedByteArray.resize()` ya crece de forma amortizada.** Los ~6 `resize()` por chunk que la optimización pretendía eliminar **no eran el coste**; añadir una pasada previa para calcular el tamaño exacto cuesta más de lo que ahorra.
- **El reuso de dicts añade libro mayor:** `keys()` (que asigna un Array nuevo), `erase()` y `get()` por clave cuestan más que asignar el árbol nuevo en GDScript.
- **BULK (`PackedInt32Array.to_byte_array()`) no es fiable:** gana en una corrida (40 vs 49 ms) y pierde en otra (41 vs 38 ms). Perfil inestable → no se adopta.

### Lo que NO pude hacer (honestidad obligatoria)
- **No existe una versión de la reutilización que gane.** No es que mi implementación sea mejorable: la premisa (que reusar ahorra) no se sostiene en este motor. **No la implementé y no se cambió el código de producción.**
- **La medición es de un entorno headless** (Godot 4.7.2, Windows). El orden de magnitud (reuso ≥ producción) es lo que se afirma, no los valores exactos.
- **No medí el efecto en el juego real** (presión de GC / frame-time): el arnés mide *throughput*, no latencia de frame.

### Trampa metodológica (nueva)
La **primera** versión del arnés medía cada variante **una sola vez y en orden fijo**. Eso castiga a la primera con el warm-up y **invirtió el veredicto** (llegó a dar la reutilización como 1,4× *más rápida*). Al re-medir con **rondas intercaladas y mínimo** el resultado se dio vuelta y quedó estable en 3 corridas. **Lección: un benchmark de una sola pasada y orden fijo no prueba nada.**

### Recomendaciones para el próximo agente
- **No reabrir el ítem 168 sin una medición nueva.** El arnés está ahí para eso. Si cambia la forma de los datos (chunks con muchos más vóxeles, payloads mucho más grandes), **re-medir antes de concluir**.
- **Si algún día se busca un win real en el encoder**, el candidato medido es BULK, pero sólo cuando hay **muchos enteros por chunk**; hoy no es fiable.
- **Tests:** `test_datos_m60.gd` (94) · `test_datos_m60_iter3.gd` (132) · `test_datos_m60_iter4.gd` (152) · `test_datos_m60_iter5.gd` (40). Los cuatro ×3 y con `grep "SCRIPT ERROR"` = 0.
