# Reporte — Sistema de Guardado/Carga (`game/isla-ancestral/scripts/saving/`)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (glyph-cluster, Agent Manager)  
**Fecha:** 2026-11-08  
**Alcance:** archivos `.gd` en `game/isla-ancestral/scripts/saving/` (núcleo + pruebas/QA auxiliares observados).  
**Método:** inspección estática de código con referencias a archivos y líneas; no se ejecutaron pruebas headless en esta sesión.

## Archivos relevantes (núcleo)

| Archivo | Rol |
|---|---|
| `save_manager.gd` | Autoload/orquestador: cola, dirty tracking, auto-save por eventos, bloqueos, carga, metadatos, cierre de ventana. |
| `save_writer.gd` | Escritura atómica `.tmp -> .save`, formato `token\npayload`, HMAC-SHA256/legado SHA-256, lectura con tope de tamaño, verificación. |
| `save_loader.gd` | Carga: existencia, parseo/checksum, completar schema, validar, versión futura, migración, recuperación desde backups. |
| `save_schema.gd` | Versión de schema, defaults, rango de slots, validación estructural/tipos/rangos, completado de secciones faltantes, helper `dia_de`. |
| `save_snapshot.gd` | Registro de proveedores `ISaveProvider`/duck-typed; `collect()` y `restore()` tolerantes. |
| `save_backup.gd` | Rotación local `r1..rN`, backup manual fechado, lectura por rotación. |
| `save_provider.gd` | Contrato base `ISaveProvider` (interfaz por `assert`/métodos a implementar). |
| `player_save_provider.gd` | Proveedor de sección `player`; guarda/restaura posición y campos expuestos por duck-typing. |
| `project.godot:30` | Autoload `SaveManager="*res://scripts/saving/save_manager.gd"`. |

También existen múltiples scripts `test_*.gd`, `qa_m59_*.gd`, `validate_save.gd` y `auditar_aliasing.gd` en el mismo directorio (observados por glob); se citan solo cuando aportan evidencia de comportamiento.

## 1) ¿Cómo se serializan y deserializan los datos?

### Serialización (guardar)

1. **Recolección de snapshot por proveedores.** `SaveManager._payload_para_slot()` llama `snapshot.collect("slot_%d" % slot)` (`save_manager.gd:200-208`). `SaveSnapshot.collect()` parte de `SaveSchema.default_payload(profile_id)` y, para cada proveedor registrado, obtiene `raw := provider.get_save_data()`; solo acepta `Dictionary` y reemplaza la sección completa (`save_snapshot.gd:46-63`). Los proveedores no registrados conservan defaults del schema (`save_snapshot.gd:14-18,47`).
2. **Sellado de metadatos del manager.** Tras `collect()`, `SaveManager` sella `meta.last_saved` con `Time.get_datetime_string_from_system()` y `meta.profile_id` desde `/root/DataStore` si está disponible (`save_manager.gd:202-207`). Esto compensa que ningún proveedor emite `meta` (`save_manager.gd:196-199`).
3. **Serialización JSON canónica del payload.** `SaveWriter.serialize_payload()` usa `JSON.stringify(payload)` (`save_writer.gd:141-143`).
4. **Documento con token de integridad.** `build_file_content()` produce `firmar_payload(payload_str) + "\n" + payload_str` (`save_writer.gd:145-148`). El token se calcula sobre la cadena JSON literal (`payload_str`), no sobre un objeto re-serializado, evitando indeterminismo (`save_writer.gd:14-16`).
5. **Escritura atómica.** `write_atomic()` valida rango de slot (`save_writer.gd:184-186`), asegura directorio (`187-192`), escribe `slot_N.tmp` (`194-208`), verifica que el `.tmp` parsea correctamente (`210-214`), y hace `DirAccess.rename_absolute(tmp_path, final_path)` (`216-220`). Nunca escribe directo sobre el `.save` final (`save_writer.gd:6-9`).
6. **Orden de backup + escritura.** En el camino normal, `SaveManager._process_queue()` rota el save anterior con `SaveBackup.rotate(slot)` **antes** de `SaveWriter.write_atomic()` (`save_manager.gd:222-238`). Este orden fue corregido para evitar perder el `.save` cargable; si `write_atomic` falla, el backup anterior queda recuperable (`save_manager.gd:230-232`). El cierre de ventana replica la misma lógica síncrona (`save_manager.gd:129-150`).

### Deserialización (cargar)

1. **Lectura segura del documento.** `SaveWriter.read_document()` verifica existencia, abre archivo, comprueba `size <= MAX_DOCUMENT_BYTES` (2 MiB) **antes** de leer, y devuelve `""` en caso de exceso/error (`save_writer.gd:31-67`).
2. **Parseo del formato `token\npayload`.** `parse_document()` separa primera línea (token) y resto (payload), verifica token, parsea JSON con `JSON.parse_string()`, exige objeto `Dictionary` y marca `legacy` si el token no tiene prefijo `hmac256:` (`save_writer.gd:150-176`).
3. **Normalización previa a validación.** `SaveLoader.load()` normaliza `schema_version` a `int` (`save_loader.gd:49-52`), completa secciones faltantes con `SaveSchema.completar()` (`54-58`), valida estructura con `SaveSchema.validate()` (`60-63`), rechaza versión futura (`65-73`), migra solo hacia delante si aplica (`75-78`), y finalmente llama `snapshot.restore(payload)` (`80-82`).
4. **Restauración tolerante.** `SaveSnapshot.restore()` solo restaura secciones con proveedor registrado y cuyo valor sea `Dictionary` (`save_snapshot.gd:68-72`). Secciones sin proveedor se ignoran (diseño opcional/forward-compatible, `save_provider.gd:15-18`).

## 2) ¿Hay validación de integridad de datos guardados?

Sí, en varias capas:

- **Tope de tamaño antes de lectura:** `MAX_DOCUMENT_BYTES = 2 * 1024 * 1024` evita cargar documentos fabricados/abusivos completos en memoria (`save_writer.gd:31-36,56-67`; usado por `save_loader.gd:42`, `save_manager.gd:258,301`, `save_backup.gd:81-85`).
- **Token de integridad sobre payload literal:** nuevos documentos se firman con HMAC-SHA256 + clave por instalación (`hmac256:<hex>`) (`save_writer.gd:38-49,84-109,120-131`). La verificación acepta HMAC nuevo y SHA-256 legado sin prefijo (`135-139`), manteniendo retrocompatibilidad (`150-176`, `legacy` flag).
- **Verificación antes de confirmar escritura:** tras escribir `.tmp`, el contenido se relee y se exige `parse_document(...).ok == true` antes del rename (`save_writer.gd:210-214`).
- **Checksum en metadatos/UI:** `SaveManager.slot_metadata()` usa `parse_document()`; si el checksum/parseo falla devuelve `{}` (`save_manager.gd:292-307`).
- **Validación de estructura/schema:** `SaveSchema.validate()` verifica presencia/tipos básicos, `schema_version`, `profile_id` string, secciones requeridas como `Dictionary`, rangos del reloj en ambos dialectos (`hora/minuto/dia/mes/anio/acumulador` y `hour/minute/day/season`), y tipos/rangos de campos meta no críticos (`save_schema.gd:194-267`). `SaveSchema.completar()` rellena secciones faltantes con defaults sin tocar el interior de secciones existentes (`167-174`).
- **Protección de versión:** saves/backups con `schema_version > SCHEMA_VERSION` se rechazan como `FUTURE_VERSION` sin degradar (`save_loader.gd:65-73,122-127`).
- **Anti-cruzamiento de perfil:** `SaveManager.load_slot()` rechaza cargar un slot sellado con `profile_id` distinto al activo (`save_manager.gd:253-279`).
- **Validación de rango de slot:** defensa centralizada en `SaveSchema.slot_valido()`/`SLOT_COUNT`; `SaveManager.request_save/load_slot` y `SaveWriter.write_atomic/cleanup_orphan_tmp` la aplican (`save_schema.gd:19-34`, `save_manager.gd:187-189,268-269`, `save_writer.gd:181-186,225-228`).

**Limitación explícita documentada:** HMAC no hace el save a prueba de manipulación local; la clave vive en `user://` (`save_writer.gd:45-49,154-162`) y los tokens legados SHA-256 siguen aceptándose por compatibilidad (`162,135-139,176`).

## 3) ¿Hay manejo de errores en carga/guardado?

Sí, amplio y mayormente defensivo:

- **Guardado bloqueado/rango/cola:** rechaza si `_blocked`, slot fuera de rango, y encola escrituras; emite `save_failed`/`auto_save_skipped` según caso (`save_manager.gd:169-192,244-246`).
- **Errores de I/O y atomicidad:** creación de directorio, apertura/escritura de `.tmp`, verificación post-escritura y rename atómico reportan error y devuelven `false` sin romper el save anterior (`save_writer.gd:187-222`). `cleanup_orphan_tmp()` limpia `.tmp` huérfanos al arrancar (`save_writer.gd:224-231`, `save_manager.gd:326-329`).
- **Rotación con propagación de fallos:** `SaveBackup.rotate()` loguea cada rename fallido y devuelve estado (`save_backup.gd:24-45`); `SaveManager` advierte pero prioriza escribir el save sobre conservar backup perfecto (`save_manager.gd:236-238,142-143`).
- **Resiliencia de proveedores:** `SaveSnapshot.collect()` aísla proveedores que devuelven tipo incorrecto/null (BUG-111-bis) con `push_error` y omite solo esa sección (`save_snapshot.gd:39-62`). Evidencia de prueba: `test_save_collect_robust.gd` cubre tipo incorrecto, `null` y proveedor sano (`test_save_collect_robust.gd:32-103`).
- **Recuperación en carga:** si falta `.save` pero hay backups, intenta recuperar (`save_loader.gd:31-40`); si el principal está corrupto/inválido, `_try_recover()` prueba todas las rotaciones `r1..MAX_ROTATIONS`, valida cada backup con el mismo rigor (parseo, normalización, completar, validate, versión futura) y devuelve `RECOVERED`, `FUTURE_VERSION` o `CORRUPTED` (`save_loader.gd:90-138`). `SaveBackup.read_backup()` también aplica cap de tamaño (`save_backup.gd:76-85`).
- **Resultados tipados:** `SaveLoader.LoadResult` expone `OK/NOT_FOUND/CORRUPTED/RECOVERED/FUTURE_VERSION/PROFILE_MISMATCH/EMPTY_SLOT` (`save_loader.gd:15-23`); `SaveManager` emite `slot_loaded` con código (`save_manager.gd:267-288`).
- **Cierre de ventana best-effort:** usa escritura síncrona, respeta `_writing`, rota antes de escribir y limpia dirty solo si escribe OK (`save_manager.gd:129-150`).
- **Auto-save condicionado:** respeta `_blocked`, slot actual, diálogos/minijuegos/eventos y marca dirty desde EventBus (`save_manager.gd:53-124,157-166,183-186`).
- **Mensajería:** uso consistente de `push_warning`/`push_error`/`print` en rutas críticas (`save_manager.gd`, `save_writer.gd`, `save_loader.gd`, `save_backup.gd`, `save_snapshot.gd`).

**Punto a vigilar:** el guardado se procesa síncronamente en el hilo principal (`_process_queue` llama serialización + disco + rename dentro del frame, `save_manager.gd:211-249`), aunque el comentario dice “sin bloquear el frame” (`210`). Puede causar tirones con payloads grandes o I/O lento.

## 4) ¿Hay dependencias circulares en el sistema de persistencia?

**No se observan dependencias circulares de carga/`preload` entre los módulos del núcleo de persistencia.**

Evidencia:
- Los módulos núcleo usan `class_name` y referencias por nombre global/estático (`SaveWriter`, `SaveLoader`, `SaveSnapshot`, `SaveBackup`, `SaveSchema`, `PlayerSaveProvider`) sin `preload()`/`load()` cruzados entre ellos (inspección de `save_manager.gd`, `save_writer.gd`, `save_loader.gd`, `save_snapshot.gd`, `save_backup.gd`, `save_provider.gd`, `player_save_provider.gd`).
- `SaveManager` compone `SaveSnapshot` y `SaveLoader` (`save_manager.gd:37-40`) y llama estáticos de `SaveSchema/SaveWriter/SaveBackup`; `SaveLoader` depende de `SaveWriter/SaveBackup/SaveSchema/SaveSnapshot`; `SaveWriter` depende de `SaveSchema`; `SaveBackup` depende de `SaveWriter/SaveSchema`; `SaveSnapshot` depende de `SaveSchema`; `PlayerSaveProvider` es independiente del orquestador.
- La relación conceptual `SaveSnapshot <-> proveedores` no es circular en carga: el snapshot mantiene proveedores (`save_snapshot.gd:11,27-33`) y los llama, pero los proveedores no referencian a `SaveSnapshot`/`SaveManager`; la documentación indica registro vía `SaveManager.register_provider()` (`save_snapshot.gd:8`, `save_provider.gd:13`), y `PlayerSaveProvider` no accede al manager.

**Dependencias externas/runtime (no ciclos internos):** `SaveManager` consulta autoloads opcionales por ruta (`/root/EventBus`, `/root/EventManager`, `/root/DataStore`, `save_manager.gd:74,94,205,273`) y registra `PlayerSaveProvider` (`154`). `PlayerSaveProvider` usa `Engine.get_main_loop()`/árbol para buscar `Player` (`player_save_provider.gd:28-34`). Estas son dependencias de escena/autoload, no ciclos de módulo.

## 5) Sugerencias concretas de diseño (2)

### Mejora 1 — Extraer un “repositorio de documento”/IO desacoplado de formato y rutas

**Problema observado:** `SaveWriter` mezcla responsabilidades: formato de documento (`serialize/build/parse/verify`), criptografía de integridad (clave HMAC, caché, comparación), rutas/sufijos, tamaño máximo y operaciones de archivo (`save_writer.gd:1-239`). `SaveBackup` también conoce formato indirectamente al delegar lectura/verificación (`save_backup.gd:81-85`) y rutas (`54,88`). Esto dificulta probar I/O sin filesystem real, cambiar el backend de almacenamiento, o auditar el formato por separado.

**Diseño propuesto:**
- Crear `SaveDocumentCodec` (puro, `RefCounted`): `encode(payload)->String`, `decode(content)->Dictionary`, `verify(...)`, `is_legacy(...)`, sin acceso a disco.
- Crear `SaveIntegrityService`: gestión de clave HMAC y firma/verificación; inyectable para tests (clave efímera determinista).
- Crear `SaveFileStore` (o interfaz): `read(path)`, `write_atomic(path,tmp,content)`, `exists(path)`, `rename/remove`, aplicando `MAX_DOCUMENT_BYTES` y política atómica.
- Mantener `SaveWriter` como fachada delgada para compatibilidad API, delegando a codec+store.

**Beneficio:** menor acoplamiento, pruebas unitarias más simples, posibilidad futura de compresión/cifrado/versionado de contenedor sin tocar loader/manager, y límites de seguridad concentrados.

### Mejora 2 — Formalizar versionado/migraciones por pasos y contrato estricto de proveedores

**Problema observado:** `_migrate()` existe pero solo asigna `schema_version` actual sin pasos registrados (`save_loader.gd:140-147`). Además, el schema tolera dialectos de tiempo (`dia/day`, `hora/hour`) porque los proveedores no son consistentes (`save_schema.gd:176-189,224-245`, `save_manager.gd:308-314`), y `SaveSchema.completar()` evita tocar interiores de sección por riesgo de romper proveedores que iteran claves como índices (`save_schema.gd:160-166`). `SaveSnapshot` ya tuvo que volverse tolerante a proveedores rotos (`save_snapshot.gd:39-62`).

**Diseño propuesto:**
- Introducir un `SaveMigrator` con tabla `from_version -> Callable` aplicada secuencialmente (`1->2->3...`), con backup previo obligatorio antes de cada cadena (ya hay patrón en loader), pruebas por migración y rechazo explícito de saltos no soportados.
- Definir un contrato de payload por sección (tipos esperados + adaptadores de dialecto) y mover la normalización `dia/day` etc. a un punto único antes de `validate()`/`restore()`.
- Endurecer el contrato de proveedor: validar `get_section_name()` no vacío/único contra secciones conocidas, registrar metadatos de versión de sección, y opcionalmente exponer `validate_section(data)->Array[String]` para fallar/omitir con diagnóstico antes de persistir o restaurar datos peligrosos.

**Beneficio:** evolución segura del schema (M60 real), menos deuda por dialectos, menor riesgo de corrupción lógica al restaurar, y diagnósticos más claros cuando un proveedor rompe el contrato.

## Conclusión

El sistema de persistencia en `scripts/saving/` muestra un diseño modular y notablemente endurecido por bugs reales documentados: escritura atómica con verificación, token de integridad HMAC con retrocompatibilidad legada, validación/completado de schema, recuperación multi-rotación de backups, rechazo de versiones futuras y perfiles cruzados, y recolección tolerante ante proveedores defectuosos. Los puntos principales a mejorar son (1) el acoplamiento entre formato/integridad/rutas/I/O en `SaveWriter` y (2) la ausencia de una migración versionada por pasos junto con la deuda de dialectos/contratos de sección. No se detectan ciclos de dependencia internos en el núcleo; las dependencias son jerárquicas/estáticas y las integraciones con autoloads se resuelven en runtime de forma opcional o defensiva.
