# AUDITORÍA DE SAVE FILES — Módulo 59 (Guardado)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 07:09Z (vuelta 21 del bucle)
**Encargo:** msg 326 de agnes-3-flash (2026-10-30 05:22Z) — TANDA AUDITORÍA/DOC, tarea #1 de 5
**Alcance:** `game/isla-ancestral/scripts/saving/` (34 archivos) + consumidores de producción del camino de guardado
**Método:** solo-evidencia-de-disco (lectura ítem por ítem; sin Godot MCP en esta sesión). **Report-only**: M59 es módulo ajeno (🔵 owner Step-5/DeepSeek) — esta auditoría NO flippea nada de su checklist; aporta deuda documentada.

---

## 1. Mapa del dominio

Pilares del sistema (todos verificados en disco):

| Archivo | Rol | Líneas |
|---|---|---|
| `save_schema.gd` | Fuente única de verdad del formato: versión, defaults, rango de slots, validación estructural | 267 |
| `save_writer.gd` | Escritura atómica + token de integridad HMAC-SHA256 (BUG-115) + cap de tamaño (BUG-109) | 239 |
| `save_loader.gd` | Carga validada: checksum → schema → backup-recovery → migración → restore | 147 |
| `save_manager.gd` | Autoload (`project.godot`: `SaveManager="*res://scripts/saving/save_manager.gd"`): cola, bloqueos, rotación, anti-cruzamiento de perfiles | 329 |
| `save_backup.gd` / `save_snapshot.gd` / `save_provider.gd` / `player_save_provider.gd` | Rotación de backups (BUG-112), recolección/restauración por proveedores (duck-typing ISaveProvider) | — |
| `validate_save.gd` | Harness QA headless (extends SceneTree), 6 tests | 170 |
| `test_checksum_hmac.gd` | Suite guardian 3 capas con sondas ROJAS documentadas (piso MEDIDO 38 checks) | 293 |
| `test_slots_m59.gd`, `qa_m59_*.gd`, `test_autosave_m59.gd`, `test_carga_*.gd` | Suites deslots, perfil, doble-guardado, carga idempotente, misiones | — |

## 2. Defensas verificadas en disco (evidencia archivo:línea)

### 2.1 Integridad del documento (save_writer.gd)

- **L36**: `MAX_DOCUMENT_BYTES = 2 * 1024 * 1024` — cap de 2 MB aplicado en `read_document()` (L56-67) **ANTES** de cargar el archivo a memoria. Un save real mide ~4.6 KB (comentario L32-33) → ~450x de margen. El cap no depende del token (se aplica pre-verificación): cierra **BUG-109** (archivo fabricado que agote memoria).
- **L40-49 + L91-109**: token `hmac256:<hex>` con clave aleatoria de 32 B (`Crypto.generate_random_bytes`) persistida en `user://clave_integridad.key` — **FUERA de `SAVE_DIR`** (justificación documentada L45-48: las suites y `_delete_save_dir()` borran `user://saves`; la clave debe sobrevivir). Clave corrupta → regeneración con `push_error`; fallo de escritura → clave efímera de sesión. Cierra **BUG-115** (antes SHA-256 en claro: cualquiera editaba el save y recalculaba).
- **L112-118**: `_igualdad_constante()` — comparación de tokens en tiempo (razonablemente) constante, anti timing-attack.
- **L124-131**: `firmar_payload()` devuelve `""` si `HMACContext.start` falla → `build_file_content()` produce documento que `parse_document()` rechaza → `write_atomic()` nunca renombra. Fallo seguro por construcción.
- **L135-139**: `verificar_checksum()` acepta HMAC nuevo + SHA-256 legado (retrocompatibilidad, regla dura "nunca degradar un save").
- **L163-176**: `parse_document()` rechaza: contenido vacío, sin newline, checksum no coincide, payload que no sea JSON-objeto (`typeof != TYPE_DICTIONARY`). Expone flag `legacy` (L176).
- **L180-222**: `write_atomic()` — `slot_valido()` defensa en profundidad (L184-186, **BUG-114**), escritura `.tmp` → verificación interna del `.tmp` con `parse_document` (L210-214) → `rename_absolute` atómico (L216-220). `store_string` verificado como bool (L202-208, skill save-load 4.4→4.7). **L225-231**: `cleanup_orphan_tmp()` también valida rango.

### 2.2 Validación estructural (save_schema.gd)

- **L33-34**: `slot_valido()` — fuente ÚNICA del contrato 1..3 (`SLOT_COUNT` L23). SaveManager L22 y SaveWriter L184 la consumen (antes cada uno tenía su constante — BUG-114).
- **L118-125**: `_es_entero()` — tolerancia JSON (int/float entero + string numérico no; `is_finite` + cota 2^53). Cierra **BUG-087** (JSON.parse_string devuelve float; antes TODO save del disco salía CORRUPTED).
- **L167-174**: `completar()` — defaults de secciones faltantes (item H: "campos nuevos y faltantes sin crash"); **NO** toca el interior de secciones (ver GAP-1).
- **L185-189**: `dia_de()` — reconciliación de dialecto con el proveedor real de tiempo (M29 emite `dia/mes/anio/hora/minuto`; el schema declara `day/season/hour/minute`). Único punto de traducción (deuda de reconciliación de claves documentada para dueños M14/M29/M38, Log 1202).
- **L194-267**: `validate()` — `schema_version` entero ≥1 (L197-202); `profile_id` **tipo String** (L207-210, no-vacuidad BUG-115: antes solo chequeba presencia y pasaban numéricos/objetos); 14 `required_sections` como Dictionary (L213-222); rangos del reloj **en AMBOS dialectos** solo sobre claves presentes (L235-253, cierra la validación vacua BUG-115: antes leía `time.day` que ningún proveedor emite = código muerto); `acumulador` numérico finito 0..3600 (L246-253); `meta.last_saved` String y `playtime_seconds` numérico no-negativo (L257-265).

### 2.3 Camino de carga (save_loader.gd)

- **L15-23**: `LoadResult` de 7 valores incluye `FUTURE_VERSION` y `PROFILE_MISMATCH` (M59 ítem 8, anti-cruzamiento).
- **L29-88** `load()`: sin save principal pero con backups → `_try_recover` (L31-40, documenta el ventana de guardado interrumpido entre rotación y rename — el escenario exacto del BUG-088); normaliza `schema_version` a int (L49-52); `completar` (L54-58); `validate` (L60-63); **versión futura → rechazo SIN degradar** con `push_warning` claro y señal a UI (L65-73, regla dura del módulo L11); migración solo-hacia-delante con backup previo (L75-78); restore (L80-82).
- **L98-138** `_try_recover()`: prueba **TODAS** las rotaciones r1..rN en orden de frescura (cierra **BUG-110**: antes solo leía r1 una vez y r2 era backup muerto). El camino de backup es **IGUAL de estricto** que el principal: parse → normalize → completar → validate → rechazo de versión futura (L112-127; documentado: antes restauraba sin validar y un backup futuro se cargaba como RECOVERED = degradar). No cae a rotaciones más antiguas si la fresca legible es futura (L123-127).

### 2.4 Autoload SaveManager (save_manager.gd)

- **L183-192** `request_save()`: bloqueos (diálogo/minijuego) + validación de rango de slot (L187-189) + cola.
- **L211-249** `_process_queue()`: el fix de **BUG-088** está documentado línea a línea (L222-235): `SaveBackup.rotate(slot)` **ANTES** de `SaveWriter.write_atomic(slot, ...)` (antes estaba después → el save recién escrito quedaba como `.bak` y el slot quedaba SIN `.save`; las suites no lo veían porque llamaban `write_atomic()` directo — trampa 119 de omisión de cobertura). **BUG-112**: rotate devuelve false → warning visible (perder el save es peor que backup desactualizado, pero el fallo no es silencioso).
- **L129-150** `_notification(WM_CLOSE_REQUEST)`: réplica SÍNCRONA del camino normal (rotar → escribir, respetando `_writing`) porque al cerrar no hay más frames para la cola. Cierra **BUG-113** (antes escribía directo sin rotar).
- **L267-288** `load_slot()`: anti-cruzamiento de perfiles (M59 ítem 8 / G-5.3) — lee el `profile_id` sellado **SIN restaurar nada** (`_perfil_de_slot` L255-265) y rechaza con `PROFILE_MISMATCH` si no coincide con el activo; saves legacy sin sello (permitidos) y sin perfil activo cargan sin restricción.
- **L298-320** `slot_metadata()`: usa `SaveWriter.parse_document()` (fix documentado: antes hacía `JSON.parse_string` sobre el archivo completo — el formato es `token\npayload`, no JSON → devolvía `{}` siempre). Expone `profile_id` para la UI.
- **L327-329** `_process_init_cleanup()`: limpia `.tmp` huérfanos al arrancar.

## 3. Camino real de escritura en producción (¿quién llama qué?)

- **UI de guardado manual (M53)**: `scripts/ui/layers/pause_layer.gd:206` → `sm.request_save(1, "guardado_manual_pausa")` ✓ **la producción usa el camino bueno** (cola + rotación previa).
- **Auto-saves internos**: `save_manager.gd` L109 (`auto_dia`), L113 (`auto_mision`), L118 (`auto_evento`, M74), L163 (`timer`).
- **Consumidores de `request_save` fuera de saving/**: solo suites (`test_diario_persist` L175, `qa_m59_*`, `test_autosave_m59`, `test_carga_*`, `test_museo_persistencia`) + la UI de pausa. **Ningún consumidor de producción llama `write_atomic()` directo** — la trampa 119 (suites que bypassaban `request_save` y por eso no vieron el BUG-088) queda acotada a tests, no a runtime.
- `project.godot` registra `SaveManager` como autoload ✓ (así `pause_layer` lo ve por nombre).

## 4. Veredicto

**SISTEMA DE SAVES M59 = ROBUSTO para cozy single-player local.** Las tres trampas históricas de corrupción están cerradas con fix en disco + test rojo documentado:

| BUG | Clase | Fix verificado en disco | Test rojo documentado |
|---|---|---|---|
| BUG-087 | JSON.parse_string devuelve float; validate exigía TYPE_INT → todo save CORRUPTED | `_es_entero` (schema L118-125) + normalize loader L49-52 | validate_save.gd L38-43 (ceguera cerrada) |
| BUG-088 | request_save() rotaba el save recién escrito (write antes de rotate) | rotate ANTES de write (manager L222-238) | qa_m59_doble_guardado / save_vacio / profile_id |
| BUG-110 | backup r2 muerto (solo se leía r1) | _try_recover recorre TODAS las rotaciones (loader L100) | suite HMAC + validate_save |

Más: HMAC-SHA256 por instalación con comparación timing-safe (BUG-115), cap 2 MB pre-lectura (BUG-109), slot_valido triple (BUG-114), backup path tan estricto como el principal, nunca degradar saves futuros, guardian 3 capas en `test_checksum_hmac.gd` con piso **MEDIDO** (38 checks) y sondas rojas documentadas (si `verificar_checksum` siempre true → fallan B/C/E; si se quita `_validar_entero` → falla H).

## 5. Gaps (deuda NUEVA documentada — ninguno flippea nada)

- **GAP-1 (MEDIO — seguimiento a dueños de proveedores)**: el interior de las secciones **no** es validado por el schema. Es deliberado y documentado (`save_schema.gd` L160-166): los proveedores usan dialectos propios e iteran las claves de su sección al restaurar. El peligro concreto está citado en el propio comentario: `inventario_service.restore_save_data()` hace `for id in data: int(id)` → una clave inyectada `"items"` se leería como contenedor 0 y **borraría contenido**. ~10+ proveedores implementan `restore_save_data` (inventario, `m65_animal_ai.gd` L343, `audio_config_service.gd` L294, `weather_service.gd` L217, `combat_island_system.gd` L196, `gem_currency.gd` L94, `crafting_service.gd` L432, + providers). **Seguimiento**: que cada proveedor valide su propio dialecto al restaurar (o un `validate` por sección). Para un save hostil se requiere acceso al FS del usuario (ver GAP-2), así que el riesgo es MEDIO, no CRÍTICO.
- **GAP-2 (MEDIO-BAJO — documentado deliberadamente)**: el token SHA-256 legado sigue siendo aceptado (`save_writer.gd` L154-162): un atacante con acceso al FS puede reemplazar la línea 1 por `sha256(payload)` y el documento verifica. El HMAC **no** convierte el save en a prueba de manipulación local (la clave vive en `user://` junto a los saves y es legible). Lo que sí aporta: detectar corrupción/tampering no reproducido en saves NUEVOS + exponer el caso legado vía flag. **Recomendación**: ventana de migración (re-firmar con HMAC al cargar OK) + rechazo de legados tras N versiones + alerta si un save nuevo llega como legacy.
- **GAP-3 (OPERACIONAL-QA)**: `validate_save.gd` L20-25 `_delete_save_dir()` borra **TODO** `SAVE_DIR` (incluidos `.bak`) al arrancar el harness. Si se ejecuta contra un `user://` con saves reales → pérdida de partidas. La clave HMAC sobrevive (está fuera de SAVE_DIR, buen diseño L45-49). **Recomendación**: que el harness opere sobre subdirectorio de test o pida confirmación.
- **GAP-4 (COBERTURA DE TEST)**: no hay test explícito de "JSON sintácticamente basura" en `validate_save.gd` (sus inyecciones son corrupción semántica con JSON válido: `day:9`, `day:8` — L105-130). `parse_document()` SÍ lo rechaza (L173-175) y `test_slots_m59.gd` L130 cubre "checksum que no coincide → no acepta basura" → cobertura indirecta. **Recomendación**: 1 test explícito `contenido = "basura"` en el harness.
- **GAP-5 (ARQUITECTURA CROSS-MÓDULOS)**: coexisten **tres dialectos de integridad**: CRC32 (`Validador` M60, `scripts/datos/validador.gd` L11 `class_name Validador`; usado por `SecurityManager.validar_save` L54-65 "patrón M60" y por `BackupManager` M107 L224), HMAC-SHA256 (saves reales M59, BUG-115) y SHA-256 legado. Si alguien cableara `SecurityManager.validar_save()` sobre un save M59 real, compararía `crc32(payload)` contra el token `hmac256:...` → **siempre false → "corrupto"**. Hoy es código muerto (ver doc M106, H2/H3) pero es una bomba de tiempo si se cablea sin reconciliar. Detalle en `AUDITORIA-INPUTS-EXTERNOS-M106.md` §3 H3.
- **GAP-6 (MENOR)**: anidamiento profundo JSON no acotado explícitamente (el cap de 2 MB sí acota tamaño; el parser de Godot no garantiza límite de profundidad). Riesgo teórico bajo.

## 6. Coherencia con CHECKLIST-GLOBAL y el mapa de frágiles

- Fila M59 (GLOBAL L12): 🔵 en curso, 118/130 tras los flips L184/L215 de la directora (2026-10-30, Log 2255 + commit 5d6105a). **Esta auditoría no altera marcas**: es report-only.
- **Matiz para el mapa de frágiles (doc AUDITORIA-SUITES-FRAGILES-1NOV.md)**: M59 sigue 🔴 en el mapa por **cobertura de suites heredadas** (Familia C: `qa_dirty_item4.gd` muerta, Logs 2255/2259) — pero esta auditoría muestra que las **defensas centrales de runtime son sólidas**. Fragilidad documental ≠ fragilidad de runtime: el mapa debe distinguir ambas dimensiones.
- Trampa 98 (suite sin CI): **cerrada por la flota en 5d6105a** — `quality.yml` (+37) y `test_menu_guardado_idiomas_m59.gd` (507 líneas, 88 checks) viajan en el MISMO commit. Precedente a replicar.

## 7. Recomendaciones priorizadas (para owner M59 / directora)

1. GAP-1 → validación por sección en proveedores (o `SaveSchema.validate_sección(name, dict)` data-driven). Dueños M14/M29/M38 + proveedores.
2. GAP-2 → ventana de migración de legados + re-firma HMAC al cargar OK.
3. GAP-3 → aislar `_delete_save_dir()` en subdirectorio de test.
4. GAP-4 → test explícito de JSON-basura en `validate_save.gd`.
5. GAP-5 → reconciliar dialectos de integridad (ver doc M106 R2).

---

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-30 07:09Z. Evidencia verificada en disco (WORKING TREE post-5d6105a, riel PT intacto, blindaje 6/6 shas). Sin commits propios (report-only, encargo agnes 326).
