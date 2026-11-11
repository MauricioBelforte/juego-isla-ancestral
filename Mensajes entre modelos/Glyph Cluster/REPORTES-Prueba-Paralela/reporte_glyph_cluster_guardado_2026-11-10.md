# Reporte: Sistema de guardado/carga y persistencia (Glyph Cluster)

**Modelo:** Glyph Cluster  
**Plataforma:** (no especificada por el entorno)  
**Fecha:** 2026-11-10  
**Alcance analizado:** `game/isla-ancestral/scripts/` (énfasis en `scripts/saving/`, autoloads y validadores relacionados)

## 1) Archivos relevantes identificados

| Componente | Archivo(s) | Rol principal |
|---|---|---|
| Autoload principal de slots/savegame | `game/isla-ancestral/scripts/saving/save_manager.gd` | Orquesta cola, proveedores, auto-save, carga, metadatos, cierre seguro (`project.godot:30` registra `SaveManager`) |
| Escritura atómica + documento firmado | `game/isla-ancestral/scripts/saving/save_writer.gd` | Serializa, firma/verifica integridad, escribe `.tmp` y renombra a `.save` |
| Carga/recuperación/migración | `game/isla-ancestral/scripts/saving/save_loader.gd` | Lee, valida, migra, recupera desde backups, restaura snapshot |
| Esquema/contrato y prevalidación | `game/isla-ancestral/scripts/saving/save_schema.gd` | Versión de schema, defaults, validación estructural/rangos, prevalidación antes de guardar |
| Recolección/restauración por secciones | `game/isla-ancestral/scripts/saving/save_snapshot.gd` | Registro de proveedores, `collect()`/`restore()`, tolerancia a fallos de proveedores |
| Contrato de proveedor | `game/isla-ancestral/scripts/saving/save_provider.gd` | Interfaz base (`get_section_name/get_save_data/restore_save_data`) |
| Proveedor de jugador | `game/isla-ancestral/scripts/saving/player_save_provider.gd` | Persiste/restaura posición del jugador (sección `player`) |
| Rotación de backups locales | `game/isla-ancestral/scripts/saving/save_backup.gd` | Rotaciones `.bak`, backup manual, lectura por rotación |
| QA/validación headless del módulo | `game/isla-ancestral/scripts/saving/validate_save.gd` | Pruebas de escritura atómica, checksum, corrupción, recuperación, rotación, migración |
| Persistencia complementaria (autoload M60) | `game/isla-ancestral/scripts/datos/data_store.gd` | Guardado/carga de partida JSON+CRC32, voxel binario, config, async/thread; autoload `DataStore` (`project.godot:89`) |
| Tests específicos M59 (muestra) | `game/isla-ancestral/scripts/saving/test_*.gd`, `qa_m59_*.gd` | Cobertura de slots, rotación, idempotencia, prevalidación, autosave, cierres, etc. |

> Nota: existen múltiples sistemas de persistencia en `scripts/` (p. ej. config/audio, backups de categorías M107, analytics). Este reporte se centra en el núcleo de savegames/slots (`scripts/saving`) y su integración/autoload.

## 2) ¿Cómo se serializan y deserializan los datos de juego?

### 2.1 Modelo de datos y secciones
- **Schema único y versionado:** `SaveSchema.SCHEMA_VERSION = 1`, con `SLOT_COUNT = 3` y directorio `user://saves` (`save_schema.gd:14`, `:17`, `:23`).
- **Payload completo por defecto:** `default_payload()` define secciones estables (`world`, `player`, `inventory`, `buildings`, `npc`, `quests`, `friendship`, `economy`, `time`, `events`, `collections`, `diary`, `photos`, `meta`, etc.), favoreciendo forward-compatibilidad (`save_schema.gd:67-134`).
- **Recolecta por proveedores:** `SaveSnapshot.collect()` parte de defaults y reemplaza secciones registradas con `provider.get_save_data()` (`save_snapshot.gd:55-77`).
- **Registro dinámico de proveedores:** `SaveManager.register_provider()` delega en `snapshot.register_provider()`; evita duplicados por sección (`save_manager.gd:205-207`, `save_snapshot.gd:36-43`). El jugador se registra en `_ready()` vía `PlayerSaveProvider` (`save_manager.gd:70`, `:179-182`).
- **Contrato de proveedor:** interfaz `ISaveProvider` con `get_save_data()`, `restore_save_data()`, `get_section_name()` (`save_provider.gd:22-35`).
- **Ejemplo concreto:** `PlayerSaveProvider` serializa `position/spawn_position/zone` (arrays numéricos) y restaura con duck-typing tolerante (`player_save_provider.gd:44-83`).

### 2.2 Serialización a disco (formato documento)
- **JSON del payload:** `serialize_payload()` usa `JSON.stringify(payload)` (`save_writer.gd:142-144`).
- **Documento determinista con firma:** `build_file_content()` construye `token\npayload_str`, donde el token se calcula sobre la cadena JSON exacta (`save_writer.gd:146-149`, cabecera `:10-24`).
- **Metadatos sellados por el manager:** antes de escribir, `SaveManager._payload_para_slot()` sella `meta.last_saved` y `meta.profile_id` (`save_manager.gd:226-235`).

### 2.3 Escritura atómica
- **Flujo atómico:** escribe a `slot_N.tmp`, verifica con `parse_document()`, y luego `DirAccess.rename_absolute(tmp -> slot_N.save)` (`save_writer.gd:195-222`).
- **Validación previa de escritura de string:** comprueba `store_string()` y evita asumir éxito (`save_writer.gd:204-209`).
- **Limpieza de temporales huérfanos:** al iniciar, `SaveManager` llama `SaveWriter.cleanup_orphan_tmp(i)` para slots 1..N (`save_manager.gd:371-373`, `save_writer.gd:225-232`).
- **Rutas:** `slot_%d.save/.tmp/.bak` bajo `SaveSchema.SAVE_DIR` (`save_writer.gd:26-29`, `:235-239`, `save_backup.gd:14`, `:88`).

### 2.4 Deserialización/carga
- **Lectura segura con tope:** `SaveWriter.read_document()` verifica existencia/tamaño (`MAX_DOCUMENT_BYTES = 2MB`) antes de cargar (`save_writer.gd:35-37`, `:56-68`).
- **Parseo del documento:** `parse_document()` separa `checksum\npayload`, verifica integridad y parsea JSON objeto (`save_writer.gd:150-176`).
- **Carga validada:** `SaveLoader.load()` obtiene documento, normaliza `schema_version` a int, completa secciones faltantes con defaults, valida estructura, rechaza versión futura, migra si aplica y restaura proveedores (`save_loader.gd:29-89`).
- **Metadatos para UI:** `SaveManager.slot_metadata()` lee sin restaurar usando `SaveWriter.parse_document()` y traduce el día tolerando dialectos (`save_manager.gd:342-364`, `save_schema.gd:213-218`).

### 2.5 Persistencia complementaria (M60 / DataStore)
- **Otro autoload de datos:** `DataStore` (`project.godot:89`) maneja partidas JSON+CRC32, mundo voxel binario, config `ConfigFile` y guardado async en hilo (`data_store.gd:29-32`, `:143-339`, `:421-525`, `:589-608`).
- **Relación con M59:** sistemas pueden integrarse con M59 vía proveedores `ISaveProvider`; M60 también registra provider `buildings` en `SaveManager` si está disponible (`data_store.gd:78-96`). Son capas distintas, no el mismo formato de slot `.save` de M59.

## 3) ¿Hay validación de integridad de datos guardados?

**Sí, en varias capas:**

| Capa | Mecanismo | Evidencia |
|---|---|---|
| Integridad criptográfica/HMAC (nuevo) + legado | Token `hmac256:<hex>` con clave por instalación (`user://clave_integridad.key`), comparación constante; acepta SHA-256 legado sin prefijo para retrocompatibilidad | `save_writer.gd:39-53`, `:85-139`, `:150-176` |
| Integridad estructural del documento | `parse_document()` rechaza vacío, formato inválido, checksum no coincidente, payload no-dict | `save_writer.gd:164-176` |
| Prevalidación antes de escribir | `SaveSchema.validar_previo_a_guardar()` combina `validate()` + detección de secciones críticas omitidas por proveedor roto; aborta guardado sin tocar disco | `save_schema.gd:36-63`, `save_manager.gd:247-264`, `:158-169` (cierre) |
| Validación de schema/rangos | `validate()` exige `schema_version`, `profile_id` string, secciones dict, y rangos/tipos en `time/meta` con tolerancia a dialectos int/float JSON | `save_schema.gd:146-295` |
| Integridad al cargar | `SaveLoader` parsea/verifica, completa defaults, valida, rechaza futuro, migra y solo restaura si es seguro | `save_loader.gd:42-89` |
| Recuperación ante corrupción | Si checksum/estructura falla, intenta backups r1..rN y aplica mismas validaciones; `RECOVERED` solo si backup es válido | `save_loader.gd:90-139`, `validate_save.gd:97-143` |
| Protección de tamaño | Cap de lectura 2MB antes de cargar documento en memoria (anti-DoS/memoria) | `save_writer.gd:35-37`, `:56-68` |

**Limitación documentada en código:** el modo legado SHA-256 sigue aceptándose por retrocompatibilidad, por lo que un atacante con acceso local al FS puede falsificar un documento legado recalculando SHA-256; la clave HMAC vive en `user://` (misma superficie local). Esto está explícitamente advertido en `save_writer.gd:152-163`.

## 4) ¿Hay manejo de errores en carga/guardado?

**Sí, amplio y mayormente defensivo:**

- **Guardado (cola normal):** slots fuera de rango, bloqueos (`_blocked`), cola secuencial `_writing`, prevalidación con rechazo y señal `save_failed`, rotación fallida logueada pero no bloqueante, errores de escritura emitidos por señal y `push_error` (`save_manager.gd:209-219`, `:237-293`).
- **Guardado al cerrar app:** usa camino síncrono replicando rotación+prevalidación+escritura; omite si `_writing` para no intercalar; emite fallo si payload inválido (`save_manager.gd:143-177`).
- **Escritura atómica:** valida rango de slot, crea directorio, detecta fallo de `store_string`, verifica `.tmp` parseable, detecta fallo de rename (`save_writer.gd:180-223`).
- **Carga:** resultados tipados `LoadResult` (`OK/NOT_FOUND/CORRUPTED/RECOVERED/FUTURE_VERSION/PROFILE_MISMATCH/EMPTY_SLOT`) (`save_loader.gd:15-24`).
- **Recuperación:** ante falta de `.save` principal intenta backups si existen; ante corrupción/estructura inválida recorre todas las rotaciones (`save_loader.gd:31-41`, `:90-139`).
- **Anti-cruzamiento de perfiles:** rechaza carga si `profile_id` del slot difiere del activo (sin restaurar estado) (`save_manager.gd:299-333`).
- **Tolerancia en snapshot:** proveedor que lanza o devuelve no-Dictionary se omite, se registra en `ultimas_omitidas/ultimos_errores` y no aborta todo el guardado (`save_snapshot.gd:55-77`, test `test_save_collect_robust.gd` referenciado en `rg`).
- **Señales/observabilidad:** `save_completed`, `save_failed`, `slot_loaded`, `auto_save_skipped` (`save_manager.gd:15-20`).
- **DataStore (M60):** valida slot/rangos, maneja corrupción con intento de restauración `.bak`, rechaza versión futura, migración en memoria sin tocar disco si falla, fallback sincrónico si no puede crear hilo, cierre ordenado de thread (`data_store.gd:143-187`, `:222-339`, `:340-397`, `:609-618`, `:99-107`).

## 5) ¿Hay dependencias circulares en el sistema de persistencia?

**No se observan dependencias circulares estáticas evidentes en el núcleo `scripts/saving/`:**

- `SaveManager` usa `SaveSnapshot`, `SaveLoader`, `SaveSchema`, `SaveWriter`, `SaveBackup`, `PlayerSaveProvider` (`save_manager.gd:37-41`, `:180`, `:226-229`, `:247`, `:281`, `:324`, `:342`, etc.).
- `SaveSnapshot` usa `SaveSchema` (`save_snapshot.gd:56`) y llama proveedores por duck-typing.
- `SaveLoader` usa `SaveWriter`, `SaveBackup`, `SaveSchema` y restaura vía `SaveSnapshot` inyectado (`save_loader.gd:30`, `:43-44`, `:77-83`, `:101`, `:129-131`).
- `SaveWriter` depende de `SaveSchema` para rutas/rangos y de APIs estándar (`FileAccess/DirAccess/HMACContext`) (`save_writer.gd:67`, `:184-199`, `:229-239`).
- `SaveSchema` es `RefCounted` utilitario sin referencias a manager/loader/writer (`save_schema.gd:1-295`).
- `SaveBackup` depende de `SaveWriter`/`SaveSchema` (`save_backup.gd:25-28`, `:54`, `:88`).
- `SaveProvider` y `PlayerSaveProvider` son contratos/proveedores sin referencias inversas al manager (`save_provider.gd`, `player_save_provider.gd`).

**Riesgos/consideraciones (no ciclos duros):**
- **Acoplamiento runtime por autoload/nombres globales:** `SaveManager` y muchos proveedores usan `get_node_or_null("/root/SaveManager")`, `/root/EventBus`, `/root/DataStore`, etc. (`save_manager.gd:88`, `:231`, `:317`; múltiples proveedores en `rg` de `register_provider`). Esto evita ciclos de carga de scripts, pero crea acoplamiento implícito al árbol de autoloads.
- **Doble ecosistema de persistencia:** `DataStore` (M60) y `SaveManager` (M59) coexisten; `DataStore` puede registrar provider en M59 (`data_store.gd:85-96`), lo que es una dependencia unidireccional en runtime, no circular.

## 6) ¿Hay versionado de datos guardados para migrar versiones?

**Sí, con infraestructura básica (forward-only), pero migraciones reales aún no implementadas:**

- **Versión en schema:** `SCHEMA_VERSION = 1` (`save_schema.gd:14`); `schema_version` es obligatorio y entero >= 1 (`save_schema.gd:225-231`).
- **Normalización al cargar:** convierte `schema_version` float->int por semántica JSON (`save_loader.gd:49-53`, `:116-117`, `save_schema.gd:137-154`).
- **Rechazo de versión futura (sin degradar):** si `version > SCHEMA_VERSION` devuelve `FUTURE_VERSION` tanto en save principal como en recuperación (`save_loader.gd:66-74`, `:122-128`).
- **Migración hacia delante:** si `version < SCHEMA_VERSION`, crea backup manual previo y llama `_migrate()`; `_migrate()` hoy solo fija `schema_version` al actual (sin transformaciones de v2+) (`save_loader.gd:76-79`, `:140-147`).
- **Validación/QA existente:** `validate_save.gd` incluye chequeo de infraestructura de migración v1 (`validate_save.gd:155-161`).
- **M60/DataStore:** mantiene `VERSION_ACTUAL = 1` y flujo de migración/validación propio para su formato (`data_store.gd:48`, `:338-402`), distinto al documento de slots M59.

**Estado práctico:** hay versionado, protección ante saves futuros y punto de extensión para migraciones, pero no hay pasos de migración entre versiones de schema (porque solo existe v1).

## 7) Dos mejoras concretas sugeridas

1. **Implementar migraciones versionadas y verificables (tabla de pasos vN→vN+1) con tests de regresión por versión**
   - **Problema actual:** `_migrate()` no transforma datos (`save_loader.gd:140-147`), y la infraestructura asume v1 (`validate_save.gd:155-161`, `save_schema.gd:14`). Cuando suba `SCHEMA_VERSION`, no hay mecanismo real ni pruebas de compatibilidad histórica.
   - **Mejora:** introducir un registro ordenado de migradores (`1->2`, `2->3`, ...) aplicado secuencialmente, con validación post-migración (`SaveSchema.validate`) y telemetría/log de versión origen/destino; agregar fixtures de saves antiguos en `scripts/saving/test_*` y extender `validate_save.gd` para cubrir cada salto.
   - **Impacto:** reduce riesgo de romper partidas existentes al evolucionar el formato; hace explícito el contrato "solo hacia delante".

2. **Unificar/explicitar estrategia de integridad y manejo de claves HMAC (rotación, fallo y política de legado)**
   - **Problema actual:** la clave HMAC se guarda en `user://clave_integridad.key` fuera de `user://saves` y se regenera si falta/corrupta (`save_writer.gd:48-109`), mientras se aceptan tokens SHA-256 legados por compatibilidad (`save_writer.gd:133-139`, `:150-163`). Esto es pragmático, pero deja ambigüedad operativa: pérdida de clave invalida verificabilidad HMAC de saves nuevos previos, y el legado sigue siendo falsificable localmente.
   - **Mejora:** (a) persistir metadata de formato/algoritmo en el documento o policy clara de re-firma al cargar OK; (b) definir política de deprecación del legado (p. ej. aceptar y reescribir en HMAC en próxima escritura segura); (c) exponer estado de integridad (`hmac`/`legacy`/`clave_regenerada`) a UI/telemetría para diagnóstico.
   - **Impacto:** mejora auditabilidad y endurece gradualmente la integridad sin romper saves existentes.

## Conclusión

El sistema de guardado/carga principal (M59, `scripts/saving/`, autoload `SaveManager`) está bien estructurado y orientado a robustez: serialización JSON en documento `checksum\npayload`, escritura atómica `.tmp -> .save`, validación estructural y de rangos, prevalidación que evita guardar progreso incompleto, recuperación por rotaciones de backup, manejo explícito de errores/resultados y versionado con rechazo de saves futuros. La migración está preparada a nivel de infraestructura pero aún no tiene transformaciones reales (v1). No se aprecian dependencias circulares estáticas en el núcleo; el acoplamiento es principalmente dinámico vía autoloads/proveedores. Las prioridades de mejora más concretas son implementar migraciones reales con pruebas por versión y endurecer/clarificar la estrategia de integridad HMAC+legado para operación y mantenimiento a largo plazo.
