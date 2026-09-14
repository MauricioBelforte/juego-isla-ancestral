# Log 827: M60-Datos-Y-Serializacion iter 3 — Construcciones, backups rotativos, compresión y catálogos perezosos

**Fecha:** 2026-09-11
**Hora:** 20:59
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M60-Datos-Y-Serializacion
**Reserva:** `Logs/reservas/827-DeepSeek-V4.1-Flash-M60.txt`
**Entrada:** M59 🟡 (providers `npc`/`fauna_registry` operativos), M60 🟡 182/196 (Log 825)
**Visión:** V0 (módulo sin necesidad de recursos visuales)

## Resumen

Iteración 3 de M60, sobre el núcleo de iter. 1 (deepseek-v4-flash) y el guardado asincrónico de iter. 2 (Log 825). Se cierran **9 `[x]`** y se dejan **5 `[?]` honestos con dueño** (antes había 1 `[ ]` de contrato externo). El módulo pasa de **182/196 a 191/196**, con 0 `[ ]`.

Ejes de la iteración:

1. **RF3 construcciones (T-018).** `EstructurasCodec` (codec puro de la sección `buildings`) + `BuildingsSaveProvider` (ISaveProvider). Normaliza ordenando por `id` → el CRC32 es determinista (RN9).
2. **Backups rotativos (T-075).** `GestorBackups` con ventana de 3 copias; `WriterAtomico` delega en él (sin dependencia circular).
3. **Compresión ZIP_DEFLATE (T-111/T-166).** `mundo_voxel.bin` → `.deflate` bajo umbral de 64 KiB; la lectura prefiere el comprimido.
4. **Catálogos perezosos (T-145/T-201).** `CatalogosEstaticos` indexa por nombre de archivo (sin `load()`) y carga por item.
5. **Progreso del guardado (T-130).** Señal `guardado_async_progreso(slot, pct)` + `progreso_guardado()`.
6. **Marcado de gaps.** `RF10` y `M62: IO en hilo` y `doble guardado` ya estaban implementados en iter. 2 pero quedaron sin marcar → se marcan ahora.

**Tests:** iter. 3 **132 checks / 0 fallos** (nuevo) · regresión `test_datos_m60.gd` **94/0** · `auditar_aliasing.gd` **ALIASING (0) / OK (9)**.
**Presupuestos medidos (headless, `Time.get_ticks_msec()`):** guardar **123 ms** · cargar **15 ms** · **22.537 bytes**.

## Cambios Realizados

**Código nuevo — `game/isla-ancestral/scripts/datos/`:**

1. **`estructuras_codec.gd`** (`class_name EstructurasCodec extends RefCounted`, static) — codec de la sección `buildings`. `SECCION="buildings"`, `MAX_ESTRUCTURAS=20000`, `CLAVES=["id","tipo","pos","rot_y","planta","variante"]`. `normalizar()` (orden por `id`), `pos_a_int32()`, `rot_normalizada()` (múltiplo de 90 en [0,270]), `validar() -> Array[String]` (tipos, ids duplicados, límite), `a_seccion()`/`desde_seccion()`, `contar()`, `huella()` (CRC32 hex del JSON canónico).
2. **`buildings_save_provider.gd`** (`class_name BuildingsSaveProvider extends RefCounted`) — `ISaveProvider` de `buildings`. `fuente()` **re-evaluada en cada llamada** (M17 puede registrarse después); `get_save_data()` devuelve `{"structures": []}` sin fuente (**nunca** referencias vivas — BUG-014); `restore_save_data()` no-op tolerante con warning; `get_section_name()` → `"buildings"`.
3. **`gestor_backups.gd`** (`class_name GestorBackups extends RefCounted`, static) — `SUFIJO_BAK=".bak"`, `MAX_BACKUPS=3`; `ruta_copia(base,i)`, `rotar(base)`, `listar()`, `contar()`, `restaurar(base,i=0)`, `limpiar_antiguos()`, `espacio_usado()`, `mantener_slot()`. **No** referencia `WriterAtomico` (evita el ciclo).
4. **`test_datos_m60_iter3.gd`** — 132 checks. Clases internas `FuenteFake`/`FuenteSoloLectura extends Node` que implementan `obtener_estructuras`/`restaurar_estructuras` para probar el provider con y sin método de restauración.

**Modificados:**

5. **`writer_atomico.gd`** — los dos bloques que hacían `DirAccess.remove_absolute(ruta_bak)` (un único `.bak`) se reemplazan por `GestorBackups.rotar(ruta)`. `restaurar_backup(ruta)` delega en `GestorBackups.restaurar(ruta, 0)`; nuevos `restaurar_backup_indice(ruta, indice)` y `copias_backup(ruta)`.
6. **`data_store.gd`** — señal `guardado_async_progreso(slot, porcentaje)`; constantes `UMBRAL_COMPRESION_BYTES=65536`, `SUFIJO_DEFLATE=".deflate"`; `_registrar_provider_buildings()` en `_ready()` (idempotente/tolerante); `_progreso_hilo` escrito por el worker y publicado por `_process` (0.05/0.25/0.60/0.75/0.95 → 1.0); `progreso_guardado()`; `comprimir_mundo_voxel(slot)` / `descomprimir_mundo_voxel(slot)` (4 casos: ya comprimido / bajo umbral / no reduce / comprime OK); `cargar_mundo_voxel()` prefiere `.deflate`; `copias_backup()`, `restaurar_backup(slot, indice=0)`, `mantener_backups(slot)` (llamada al guardar).
7. **`catalogos_estaticos.gd`** — reescrito: índice `id → ruta` por `DirAccess` sin `load()`; `obtener_item()` carga y cachea; `tiene_item()`/`contar_items()` consultan el índice; `contar_cargados()`, `cargar_todos()`, `rutas_indexadas()`, `_reset_para_test()`.

## Decisiones

1. **D-codec — orden por `id` antes de la huella.** Sin normalizar el orden, dos saves con las mismas construcciones en distinto orden de iteración darían CRC distinto (viola RN9). Coste O(n log n) despreciable frente al IO.
2. **D-provider tolerante — no cachear la fuente.** M17 (Construcción) **no tiene código todavía** (módulo reclamado por otro agente) → cachear en `_ready()` habría fijado `null` para siempre. Re-evaluar por llamada cuesta un recorrido del árbol, aceptable en una operación de guardado.
3. **D-backups — `GestorBackups` no conoce `WriterAtomico`.** Aunque `WriterAtomico` lo usa, la dependencia inversa crearía un ciclo entre `class_name` (GDScript no lo admite).
4. **D-compresión — umbral, no siempre.** Comprimir un voxel diminuto cuesta más que el ahorro; con 64 KiB el caso real (edits densos) comprime y el caso trivial no toca nada. El formato interno `IAVX1` **no cambia** (se comprime el archivo, no el contrato).
5. **D-progreso — `float` compartido, no señales desde el hilo.** El worker escribe `_progreso_hilo`; `_process` (hilo principal) compara con `_ultimo_progreso_emitido` y emite. Emitir señales desde el worker sería inseguro.
6. **Caracterización honesta en vez de verde falso.** El check de la sección `npc` se dejó como `keys != schema_keys` (documenta la divergencia real) y se registró **BUG-025**, en lugar de forzarlo a pasar.

## Errores nuevos (documentados)

- **E-nuevo (registro de `class_name`).** Los `class_name` nuevos no son visibles a `--script` hasta regenerar `.godot/global_script_class_cache.cfg` → `--headless --path game/isla-ancestral --editor --quit`. Confirmados los 3 (caché con 456 clases).
- **E-nuevo (inferencia de tipo).** `var x := obj.metodo()` cuando la base es un `Node`/`Node3D` (autoload) o un `String(...)` → *"Cannot infer the type"*. Solución: anotar explícitamente (`var a: Dictionary = ...`). ~25 sitios.
- **E-nuevo (`.tmp` no superó verificación).** `WriterAtomico.escribir_atomicamente` exige JSON válido en `_verificar_documento`; el test escribía payloads no-JSON (`"v1"`) → `err=16`. Corregido con `construir_con_checksum('{"v":"%s"}')`.
- **E-nuevo (contrato v1).** El validador exige 5 bloques (`jugador/inventario/tiempo/mundo_voxel/meta`); los payloads de prueba de presupuestos no los tenían → *"Falta bloque"*. Añadidos.

## Hallazgo cruzado → BUG-025

`M19` (`VillagerManager.get_save_data()`) serializa la sección `npc` con las claves `["visitantes","llegadas","partidas","avisos","enfriamientos","hogares","memoria"]`, mientras el default del schema de M59 (`SaveSchema`) espera `["npcs","dialogs_seen"]`. Además, `npc_manager.gd` reclama la sección `npc_ai`, ausente de `SaveSchema._reserved_sections`. Registrado como **BUG-025** (🟡 Menor, `[?] Delegado`) en `DOCUMENTACION/11-BUGS.md`, dueño **M19**. No lo arreglé: la sección es su contrato.

## Archivos

- `game/isla-ancestral/scripts/datos/estructuras_codec.gd` (nuevo)
- `game/isla-ancestral/scripts/datos/buildings_save_provider.gd` (nuevo)
- `game/isla-ancestral/scripts/datos/gestor_backups.gd` (nuevo)
- `game/isla-ancestral/scripts/datos/test_datos_m60_iter3.gd` (nuevo)
- `game/isla-ancestral/scripts/datos/writer_atomico.gd` (modificado)
- `game/isla-ancestral/scripts/datos/data_store.gd` (modificado)
- `game/isla-ancestral/scripts/datos/catalogos_estaticos.gd` (reescrito)
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/04-Codigo.md` (API + Notas del Agente iter. 3)
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md` (9 `[x]`, 5 `[?]`, reserva iter. 3 cerrada)
- `DOCUMENTACION/11-BUGS.md` (BUG-025)
- `CHECKLIST-GLOBAL.md` (fila 60 → 191/196)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M60 iter. 3)

## Ítems cerrados

`RF3 construcciones y casas` · `RF10 fuera del hilo` · `rotación/limpieza .bak` · `compresión ZIP_DEFLATE` · `M62 IO en hilo` · `M62 progreso visible` · `doble guardado concurrente` · `compresión bajo demanda` · `carga perezosa de catálogos`.

## Ítems en `[?]` (honestos, con dueño)

- `RF3 fauna y vecinos` → **M19** (BUG-025).
- `M08: contrato de edits` → **M08** (heredado).
- `M62: UI deshabilitada durante guardado` → **M53/M59**.
- `M15/M16/M33: .tres de recetas y cultivos` → **M16/M33**.
- `presupuestos RN con el Profiler` → **QA/build** (el Profiler no corre en headless).

## Próximo agente

- Conectar **M17**: implementar `obtener_estructuras()`/`restaurar_estructuras()` en el gestor de construcción; el provider ya los detecta sin cambios.
- **M19**: alinear la sección `npc` con el schema (BUG-025) o registrar su propia sección en `SaveSchema`.
- Test iter. 3: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter3.gd` (132 checks).
- Regresión: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd` (94 checks).

---

**Firmado:** DeepSeek-V4.1-Flash (WorkBuddy) — 2026-09-11 20:59
