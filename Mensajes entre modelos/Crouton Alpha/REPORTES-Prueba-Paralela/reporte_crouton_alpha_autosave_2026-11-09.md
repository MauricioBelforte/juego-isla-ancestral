# Reporte: Guardado Automático (Auto-Save) — Crouton Alpha

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09

**Alcance:** análisis de `game/isla-ancestral/scripts/saving/*.gd` y de los sistemas de checkpoint relacionados (`scripts/templos/templo_checkpoint.gd`, `scripts/core/recovery/checkpoint_manager.gd`).

**Nota de naming:** en el código no existe un "checkpoint de guardado" como concepto de save-point del jugador (hito alcanzable que dispara guardado al tocarlo). Los "checkpoints" que existen son dos sistemas independientes y con distinto propósito:

- **M66 CheckpointManager** (`scripts/core/recovery/checkpoint_manager.gd`) — anti-softlock: 3 slots rotativos por bioma + 1 slot global de emergencia, escritura atómica reusando el patrón de M59. Página de recuperación, no save-points de gameplay.
- **M26 TemploCheckpoint** (`scripts/templos/templo_checkpoint.gd`) — los 5 checkpoints del Templo Subterráneo (porte, vestíbulo, vientos, central, sello) con guardado atómico `tmp → .bak → rename`. Es un sistema propio de mazmorra, separado del sistema de guardado global.

Ninguno de los dos es disparado por zonas del mundo ni por interacción del jugador como save-points tradicionales.

---

## 1. ¿Cómo funciona el auto-save?

**Núcleo:** `save_manager.gd` (autoload `SaveManager`), módulo M59. Cola de peticiones, una escritura a la vez (`_writing`), delegación a `SaveWriter.write_atomic()` y rotación de backup con `SaveBackup.rotate()`.

**Disparadores (4 vías):**

1. **Temporizado:** `_process()` cada `auto_save_interval` segundos (exportado, default **300 s**), en `save_manager.gd:25` y `save_manager.gd:183-191`. Solo si hay `current_slot >= 1`.
2. **Inicio de día (B1):** conexión a `bus.calendar.day_started` en `save_manager.gd:103` → `_on_auto_save_dia()` (`save_manager.gd:121-123`), motivo `"auto_dia"`.
3. **Misión completada (B2):** conexión a `bus.quest.quest_completed` en `save_manager.gd:105` → `_on_auto_save_mision()` (`save_manager.gd:125-127`), motivo `"auto_mision"`. Nota: los emisores reales M22/M23 están pendientes (comentario en `save_manager.gd:104`); hoy solo se dispara en tests.
4. **Evento de temporada finalizado (B1-bis):** conexión a `EventManager.evento_terminado` en `save_manager.gd:108-110` → `_on_auto_save_evento()` (`save_manager.gd:130-132`), motivo `"auto_evento"`.
5. **Cierre de ventana (B3):** `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` en `save_manager.gd:143-176`. Camino síncrono directo (fuera de cola) porque el árbol está por terminar; se salta si `_writing == true` (para no intercalar una escritura en curso) y si `_blocked`.

**Bloqueos:** `_blocked` vía `set_save_blocked()` (`save_manager.gd:196-200`). Se activa durante diálogo (`bus.ui.dialog_requested` → `_on_dialogo_abierto()`, `save_manager.gd:134-138`) y durante minijuegos de pesca (`bus.fishing.sesion_iniciada/terminada`, `save_manager.gd:115-116`). El intento bloqueado emite `auto_save_skipped(reason)` (`save_manager.gd:19`, `save_manager.gd:210-212`).

**Dirty tracking (A4):** `_dirty` se marca vía EventBus (día, estación, moneda, inventario, quest, regalo NPC, bloques colocados/retirados) en `save_manager.gd:93-101` y se limpia al completar un guardado (`save_manager.gd:285`). Uso: la UI de guardado manual (M53) consulta `is_dirty()`.

**Constante de juego:** `game_constants.gd:12` declara `AUTO_SAVE_INTERVAL_SECONDS = 120.0`, pero el autoload usa su default exportado de **300 s** (`save_manager.gd:25`). Si algún sistema no pasa por la escena que ajusta el export, el intervalo efectivo es 300 s y no 120 s — hay dos fuentes de verdad para el intervalo.

**Motivos emitidos:** `timer`, `auto_dia`, `auto_mision`, `auto_evento` (vía `_process_queue()` en `save_manager.gd:237-293`) y `cierre` (en `_notification`).

---

## 2. ¿Hay validación antes de guardar automáticamente?

**Sí, pre-validación obligatoria** (crítico de la evaluación Nemotron, 2026-11-08).

Flujo en `save_manager.gd:253-264` (`_process_queue()`): antes de rotar y escribir, se llama a `SaveSchema.validar_previo_a_guardar(payload, snapshot.ultimas_omitidas)`.

Esa función (`save_schema.gd:53-62`) combina:

1. `validate(payload)` — estructura/tipos del payload completo (`save_schema.gd:222-295`): presencia de `schema_version` y `profile_id` (String), presencia de las 14 secciones como Dictionary, rangos del reloj (ambos dialectos M29 `hora/minuto/dia/mes/anio/acumulador` y schema `hour/minute/day/season`), tipos de `meta.last_saved` y `meta.playtime_seconds`.
2. Las secciones que `SaveSnapshot.collect()` tuvo que omitir (`save_snapshot.gd:17`, `save_snapshot.gd:69-75`, `save_snapshot.gd:55-77`). Si una de ellas es **crítica** — `["world", "player", "inventory", "buildings", "quests"]` (`save_schema.gd:40`) — el guardado se **rechaza**: no se toca el disco (no rota, no escribe), se emite `save_failed`, se incrementa `_guardados_rechazados` y se guardan los errores en `ultimos_errores_guardado` (`save_manager.gd:56-65`, `save_manager.gd:254-263`). El guardado de cierre también valida (`save_manager.gd:158-168`).

Antes de este fix, el código escribía un save incompleto y la UI reportaba `save_completed`: progreso perdido en silencio. La suite de cobertura es `test_prevalidacion_payload_m59.gd` (18 checks mínimos, bloque C verifica que ante un proveedor crítico roto el save anterior queda intacto byte por byte, `test_prevalidacion_payload_m59.gd:198-201`).

**Nota:** una sección NO crítica omitida (ej. `friendship`, `events`, `collections`) se permite guardar; el payload se escribe sin esa sección y al cargar se completa con los defaults del schema (`save_schema.gd:195-202`, `save_loader.gd:58`).

---

## 3. ¿Hay problemas de guardado parcial o corrupto?

El sistema está diseñado para que el guardado parcial sea estructuralmente imposible; hay cuatro capas que lo garantizan, más un historial de bugs reales ya corregidos:

**Capa 1 — Escritura atómica (`save_writer.gd:180-222`):**
- Se escribe a `slot_N.tmp`, se verifica que el `.tmp` no quedó vacío ni corrompido (`parse_document`, `save_writer.gd:210-214`) y recién entonces se renombra a `slot_N.save` con `DirAccess.rename_absolute()` (`save_writer.gd:217-220`).
- Regla dura del módulo: NUNCA escribir sobre el save actual (`save_writer.gd:6-9`).
- Limpieza de `.tmp` huérfanos al arrancar: `_process_init_cleanup()` en `save_manager.gd:370-373` iterando `SaveWriter.cleanup_orphan_tmp()` (`save_writer.gd:225-231`).

**Capa 2 — Orden de rotación (`save_manager.gd:266-281`):**
- Bug crítico corregido en M59 iter. 2: `rotate()` estaba DESPUÉS de `write_atomic()`, lo que reemplazaba el save anterior y luego movía el recién escrito a `.bak`, dejando el slot sin `slot_N.save` cargable. Orden correcto: rotar primero, escribir después. Si `rotate()` falla (BUG-112), se loguea warning y se escribe igual (`save_manager.gd:280-281`) — el save es prioritario sobre el backup.

**Capa 3 — Integridad (`save_writer.gd`):**
- Formato: `hmac256:<hex>\npayload_json`. HMAC-SHA256 con clave por instalación en `user://clave_integridad.key` (`save_writer.gd:91-109`, BUGB-115). Comparación en tiempo constante (`save_writer.gd:112-118`).
- Cap de 2 MB antes de leer el documento entero (`save_writer.gd:36`, `save_writer.gd:56-67`, BUG-109) para que un archivo fabricado no agote la memoria.
- Limitación conocida y deliberada (`save_writer.gd:154-162`): se sigue aceptando el SHA-256 legado sin prefijo por retrocompatibilidad, así que un atacante con acceso al sistema de archivos podría forjar un save recalculando el SHA-256 público. El HMAC detecta corrupción accidental y tampering no reproducido por el algoritmo público en saves nuevos; no convierte el save en a prueba de manipulación local porque la clave vive en `user://` junto a los saves.

**Capa 4 — Validación estructural en carga (`save_loader.gd`):**
- Checksum, luego `SaveSchema.validate()` estructura, luego `SaveSchema.completar()` defaults, luego versión (`save_loader.gd:29-88`). Una versión FUTURA se rechaza sin tocar el archivo (`save_loader.gd:66-73`) — regla dura "nunca degradar un save".
- El backup de respaldo también se normaliza y valida al recuperarse (`save_loader.gd:116-123`), igual que el principal.

**Bugs históricos corregidos (todos medidos con suite):**
- BUG-110: r2 era un backup muerto; `_try_recover()` ahora itera todas las rotaciones (`save_loader.gd:98-138`). Suite: `test_backup_rotations.gd`.
- BUG-111-bis: un proveedor que lanzaba abortaba `collect()` completo y se escribía un save vacío (`save_snapshot.gd:47-75`).
- BUG-109: cap anti-agotamiento de memoria al leer (`save_writer.gd:36`).
- BUG-112: `rotate()` silencioso ante renames fallidos (`save_backup.gd:24-45`).
- BUG-114: `SLOT_COUNT` unificado en `SaveSchema` (`save_schema.gd:23`) y `write_atomic` con defensa en profundidad (`save_writer.gd:184-186`).
- BUG-115: HMAC + validación de tipos de `profile_id`/`meta` + validación real del dialecto M29 (antes código muerto) (`save_schema.gd:252-293`).
- BUG-113: guardado de cierre escribía sin rotar y sin respetar `_writing` (`save_manager.gd:144-176`).

**Riesgo residual menor:** si el proceso muere entre `rotate()` y `rename_absolute()` del nuevo save, queda `.bak` pero no `.save`. El loader lo cubre: `save_loader.gd:32-40` recupera desde backup cuando falta el save principal (guardado interrumpido en la ventana de rotación).

---

## 4. ¿Hay recuperación de saves corruptos?

**Sí, recuperación por backups en cascada (`save_loader.gd:98-138`):**

1. Si el save principal está corrupto (checksum inválido, estructura inválida, formato roto), `_try_recover()` prueba las rotaciones `r1`, `r2` (hasta `MAX_ROTATIONS = 2`, `save_backup.gd:12`) en orden de frescura.
2. Cada backup pasa por `parse_document` → `SaveSchema.completar()` → `SaveSchema.validate()` → chequeo de versión futura antes de restaurarse (`save_loader.gd:105-136`).
3. Si una rotación válida existe, devuelve `LoadResult.RECOVERED` y restaura los sistemas vía `snapshot.restore()` (`save_loader.gd:129-130`). Si no, devuelve `LoadResult.CORRUPTED` (`save_loader.gd:137-138`).

**Resultados de carga (enum `save_loader.gd:15-23`):** `OK`, `NOT_FOUND`, `CORRUPTED`, `RECOVERED`, `FUTURE_VERSION`, `PROFILE_MISMATCH`, `EMPTY_SLOT`. El manager expone `slot_recoverable(slot)` (`save_manager.gd:367-368`) que delega en `SaveBackup.has_any_backup()` para la UI de recuperación.

**Cobertura:** `validate_save.gd:116-142` (recuperación tras corrupción del principal), `validate_save.gd:96-114` (detección de corrupción sin backup → `CORRUPTED`), `test_backup_rotations.gd` (BUG-110, caso B: r1 corrupto + r2 válido → `RECOVERED`).

**Deuda en esta superficie:**
- Solo hay 2 rotaciones locales (`save_backup.gd:12`). El backup 3-2-1 externo es responsabilidad del módulo M107 (mencionado en `save_backup.gd:8`), no del módulo 59.
- Los backups manuales fechados (`backup_manual`, `save_backup.gd:49-59`) se crean solo antes de una migración (`save_loader.gd:76-78`), no hay disparador manual desde la UI identificado en este módulo. El writer de checkpoints del templo (`templo_checkpoint.gd`) tiene su propio `.bak` por checkpoint, independiente del sistema global.
- `CheckpointManager` (M66) escribe en `user://checkpoints/` con tmp+rename+.bak propios (`checkpoint_manager.gd:57-60`) y NO reutiliza `SaveWriter` para el checksum/HMAC: replica el patrón atómico en un formato más simple (JSON directo). Mantener dos implementaciones atómicas distintas es un riesgo de divergencia.

---

## 5. Dos mejoras sugeridas

### Mejora 1 — Unificar la fuente de verdad del intervalo y añadir un save-point de gameplay

**Contexto:** hoy hay dos intervalos (120 s en `game_constants.gd:12` vs 300 s exportado en `save_manager.gd:25`) y no existe ningún save-point del jugador: el auto-save depende de eventos (día, misión, evento) o de un timer. Si el jugador muere o el proceso muere entre un evento y el siguiente, pierde todo lo avanzado desde el último evento. Los dos sistemas "checkpoint" existentes (M66 y templo) no están conectados a zonas del mundo ni sirven como puntos de retorno del jugador.

**Propuesta concreta (reutilizando la infraestructura existente):**
- Hacer que `SaveManager` lea el intervalo desde `GameConstants.AUTO_SAVE_INTERVAL_SECONDS` en su `_ready()` (o en el setter del export) para eliminar la dupla 120/300.
- Añadir un disparador de auto-save al entrar en zonas clave (spawn, biomas, templos) reutilizando el mecanismo `request_save(current_slot, "auto_zona")` de `save_manager.gd:209` — sin crear un sistema nuevo, solo conectando señales existentes. Los checkpoint IDs del templo (M26, `CP_IDS` en `templo_checkpoint.gd:31`) y los biomas del CheckpointManager (M66) ya definen esos lugares; falta el puente que invoque `request_save` al activar uno.
- Documentar el comportamiento en la guía de jugador: qué eventos disparan auto-save y con qué frecuencia, para que no sea un misterio.

**Beneficio:** eliminar la divergencia 120/300 y dar al jugador un punto de guardado predecible en los momentos de "sin retorno" (entrar a un templo o cambiar de bioma), en vez de depender solo del reloj.

### Mejora 2 — Unificar la escritura atómica y endurecer el camino de recuperación

**Contexto:** hay dos implementaciones atómicas (M59 `SaveWriter` con HMAC/checksum y M66 `CheckpointManager._escribir_checkpoint_atomico` sin integridad, más la de `TemploCheckpoint.guardar()` con `.bak` propio). Además, la recuperación local se limita a 2 rotaciones y los backups manuales solo se crean en migraciones.

**Propuesta concreta:**
- Refactorizar `CheckpointManager._escribir_checkpoint_atomico()` y `TemploCheckpoint.guardar()` para que escriban vía `SaveWriter.write_atomic()` (adaptando el payload al formato) en vez de replicar el patrón tmp+rename+.bak. Un solo camino de escritura = un solo lugar donde pueden surgir los bugs de orden (como el BUG de rotación recíproca de M59 iter. 2) y un solo formato de integridad.
- Subir `MAX_ROTATIONS` de 2 a 3 o añadir una rotación fechada periódica (p. ej. un `backup_manual` al completar cada auto-save de día) para que la ventana de recuperación no dependa de solo dos generaciones. Es barato: el save pesa ~4,6 KB (medido en `save_writer.gd:32`).
- La suite `validate_save.gd` y `test_backup_rotations.gd` ya cubren el camino feliz y el BUG-110; añadir un caso donde el `.tmp` queda a medias tras una muerte simulada (sin rename) verificando que el loader recupera el `.bak` — el contrato ya existe en `save_loader.gd:32-40`, falta su test de regresión.

**Beneficio:** una sola superficie de escritura atómica con integridad HMAC para todos los sistemas, una ventana de recuperación más amplia y un test que fije el contrato de "muerte entre rotate y rename".

---

## Conclusión final

El sistema de guardado automático de M59 es maduro y defensivo: escritura atómica con verificación del `.tmp` antes del rename, HMAC por instalación con retrocompatibilidad documentada, pre-validación obligatoria que impide saves incompletos silenciosos (crítico Nemotron 2026-11-08), rotación de backups antes de escribir, recuperación en cascada por rotaciones, rechazo de versiones futuras sin degradar el archivo y limpieza de temporales huérfanos al arrancar. El historial de bugs corregidos (BUG-109 a BUG-115) está medido con suites headless (`test_autosave_m59.gd`, `test_prevalidacion_payload_m59.gd`, `test_backup_rotations.gd`, `validate_save.gd`).

Las dos deudas reales son de alcance, no de corrección: (1) el intervalo de auto-save tiene dos fuentes de verdad (120 s vs 300 s) y no existe ningún save-point de gameplay conectado a zonas; (2) la escritura atómica está duplicada entre M59, M66 y el templo, la recuperación local se limita a 2 rotaciones y el contrato de recuperación tras muerte en plena rotación no tiene test de regresión. Ambas se cierran reutilizando la infraestructura existente, sin sistemas nuevos.
