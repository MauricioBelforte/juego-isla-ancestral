# Reporte: Auto-save, estado del juego, save-points y checkpoints

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 04:27 (UTC, sesión)  
**Alcance analizado:** `game/isla-ancestral/scripts/saving/`, `game/isla-ancestral/scripts/interfaces/i_saveable.gd`, `game/isla-ancestral/scripts/core/recovery/checkpoint_manager.gd`, proveedores `*_save_provider.gd` y tests de guardado.

---

## 1) ¿Cómo funciona el guardado automático?

### Arquitectura general
El sistema está centralizado en el autoload `SaveManager` (`game/isla-ancestral/scripts/saving/save_manager.gd`) y se apoya en:

- **`SaveSnapshot`** (`save_snapshot.gd`): registra proveedores por sección y recolecta/restaura el estado.
- **`ISaveProvider`** (`save_provider.gd`): contrato `get_section_name()`, `get_save_data()`, `restore_save_data()`.
- **`SaveWriter`** (`save_writer.gd`): serializa payload, firma/integridad, escritura atómica `.tmp` → `.save`.
- **`SaveBackup`** (`save_backup.gd`): rotación local de backups (`slot_N_r1.bak`, `r2`).
- **`SaveLoader`** (`save_loader.gd`): carga validada, recuperación desde backup, control de versión/migración.
- **`SaveSchema`** (`save_schema.gd`): versión de esquema, defaults, validación y rango de slots.

### Disparadores de auto-save
En `SaveManager._conectar_eventos()` (líneas ~73-106):
- **Fin/inicio de día**: `EventBus.calendar.day_started` → `_on_auto_save_dia()` → `request_save(current_slot, "auto_dia")` (L107-109). También marca dirty (L79).
- **Misión completada**: `EventBus.quest.quest_completed` → `_on_auto_save_mision()` → `request_save(..., "auto_mision")` (L111-113, L91).
- **Evento terminado**: conexión directa a `EventManager.evento_terminado` si existe → `_on_auto_save_evento()` → `request_save(..., "auto_evento")` (L92-118).
- **Temporizador**: en `_process()` (L157-165), si `auto_save_interval > 0` (export, default `300.0` s) acumula `_auto_save_timer`; al vencer llama `request_save(current_slot, "timer")` **solo si hay `current_slot >= 1`**.

### Bloqueos (puntos sensibles)
- **Diálogo**: `EventBus.ui.dialog_requested` bloquea (`set_save_blocked(true)`), `dialog_finished` desbloquea (L103-124).
- **Pesca/minijuego**: `EventBus.fishing.sesion_iniciada/terminada` bloquea/reanuda (L97-102). Testeado en `test_fishing_save_block.gd` (11 checks, BUG-116/T-D9).
- Si está bloqueado, `request_save()` emite `auto_save_skipped` y no encola (L183-186).

### Cola y procesamiento
- `request_save()` valida rango (`1..SLOT_COUNT`, `SaveSchema.SLOT_COUNT=3`, L21-22, L187-189), encola `{"slot","reason"}` y dispara `_process_queue()` si no hay escritura en curso (L190-192).
- `_process_queue()` procesa **un request a la vez** (`_writing` guard), toma el primero de la cola, construye payload con `_payload_para_slot()` (sella `meta.last_saved` y `meta.profile_id`, L200-208), **rota backup ANTES de escribir** (`SaveBackup.rotate`), luego `SaveWriter.write_atomic` (L211-246). BUG-113/orden corregido: rotar antes evita perder el save anterior (comentario L222-232).
- Al éxito: actualiza `current_slot`, limpia dirty, emite `save_completed`; al fallo emite `save_failed` (L239-246). Procesa el resto de la cola recursivamente (L248-249).

### Dirty tracking
- `_dirty` se marca por eventos del `EventBus` (inventario, economía, quests, NPC gift, bloques mundo, calendario; L78-87) y se limpia al completar save (L241). `is_dirty()/mark_dirty()/clear_dirty()` expuestos (L61-68). Test básico en `test_autosave_m59.gd` (L45-60).
- Nota: existe `ISaveable` (`interfaces/i_saveable.gd`) con `has_unsaved_changes()/mark_saved()/validate_save_data()`, pero el pipeline central usa proveedores `ISaveProvider` + dirty global del `SaveManager`; no hay evidencia de integración automática de `ISaveable` en el snapshot.

### Guardado al cerrar (best-effort)
- `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` intenta guardar síncronamente el `current_slot` si no está bloqueado (L129-150). Replica el camino normal: respeta `_writing` (omite si hay escritura en curso), rota y escribe; BUG-113 corregido. Testeado en `test_close_save.gd`.

### Checkpoints de recovery (distintos del save de slots)
- `CheckpointManager` (`scripts/core/recovery/checkpoint_manager.gd`) mantiene checkpoints rotativos por bioma (3 slots) y global, con escritura atómica reutilizando `SaveWriter` (tmp+verify+bak+rename, L58-87). Es un mecanismo de **anti-softlock/recovery**, no el auto-save de progreso del jugador en slots.

---

## 2) ¿Hay validación antes de guardar?

### Validaciones presentes
- **Rango de slot**: `request_save()` rechaza slots fuera de `1..SLOT_COUNT` (L187-189). `SaveWriter.write_atomic()` también defiende en profundidad con `SaveSchema.slot_valido()` (L180-186, BUG-114). `load_slot()` rechaza rango (L267-269).
- **Directorio de saves**: `write_atomic()` crea `user://saves` si falta (L187-192).
- **Verificación post-escritura del `.tmp`**: antes del rename atómico, relee el `.tmp` y exige `parse_document(...).ok` (L210-214). Esto valida formato `checksum\npayload` y parseo JSON del payload escrito.
- **Integridad/token**: `SaveWriter.build_file_content()` firma con **HMAC-SHA256** por instalación (`hmac256:<hex>`, clave en `user://clave_integridad.key`, BUG-115, L38-148). `parse_document()` verifica HMAC o acepta SHA-256 legado por retrocompatibilidad (L150-176).
- **Escritura**: comprueba retorno de `store_string()` (Godot 4.4+, L204-208).
- **Schema al cargar**: `SaveLoader.load()` normaliza `schema_version` a int, completa secciones faltantes con `SaveSchema.completar()` (defaults de nivel superior, sin tocar interior de secciones), valida estructura con `SaveSchema.validate()` (L48-73). `validate()` verifica `schema_version`, `profile_id` string (BUG-115), secciones requeridas como `Dictionary`, rangos/tipos del reloj en ambos dialectos y tipos de `meta` (L194-267).
- **Validación QA**: `scripts/saving/validate_save.gd` ejecutable headless cubre escritura atómica, carga válida (camino feliz), detección de corrupción por checksum, recuperación de backup, rotaciones y migración (exit code 1 si falla).

### Validaciones parciales / ausentes antes de persistir
- **No hay validación de esquema/semántica del payload completo antes de `write_atomic()`** en el camino normal. `SaveManager` recolecta y escribe; no llama `SaveSchema.validate(payload)` ni valida tamaños/valores de negocio del snapshot antes de persistir. La verificación es estructural del documento escrito (checksum+JSON parse), no “este estado de juego es coherente”.
- **Proveedores sin contrato forzado**: `ISaveProvider` es un `RefCounted` con `assert(false)` en métodos base (no interfaz estricta). `SaveSnapshot` usa duck-typing (L27-33, L52-63) y tolera fallos de tipo/lanzamientos omitiendo la sección (BUG-111-bis, L58-62) — bueno para robustez, pero **puede guardar un snapshot incompleto** si un proveedor crítico falla.
- **`ISaveable.validate_save_data()` existe** pero no se invoca en el pipeline de `SaveManager/SaveSnapshot`.
- **Anti-cruzamiento de perfil** se valida al **cargar** (`load_slot`, L270-279, `PROFILE_MISMATCH`), no al guardar; guardar sella `meta.profile_id` (L205-207).

---

## 3) ¿Hay problemas de guardado parcial o corrupto?

### Mitigaciones implementadas (sólidas)
- **Escritura atómica**: nunca escribe directo sobre el `.save`; usa `.tmp`, verifica y `DirAccess.rename_absolute(tmp_path, final_path)` (L194-222). `.tmp` huérfanos se limpian al inicio (`_process_init_cleanup`, L327-329).
- **Orden rotate→write corregido**: BUG crítico (M59 iter.2) — antes rotaba después y dejaba el slot sin `.save`; ahora rota el anterior a `.bak` y luego escribe el nuevo (L222-238, comentario detallado).
- **Backups locales**: rotación hasta `MAX_ROTATIONS=2` (`_bak_path` r1/r2) y `backup_manual()` fechado (L11-59).
- **Recuperación**: `SaveLoader` intenta `.save`; si falta y hay backup, recupera “guardado interrumpido” (L31-40). Si corrupto, prueba **todas** las rotaciones r1→rN (BUG-110, L98-138). Aplica normalización/completado/validación y rechaza versión futura también en backups (no degrada).
- **Robustez de recolección**: `SaveSnapshot.collect()` omite proveedores que lanzan o devuelven no-Dictionary (BUG-111-bis, L37-63), evitando abortar todo el snapshot.
- **Bloqueos por minijuego/diálogo** reducen riesgo de capturar estado inconsistente (testeado).
- **Cap de lectura**: `MAX_DOCUMENT_BYTES = 2MB` antes de leer a memoria (BUG-109).
- **Versión futura**: rechazada sin tocar el save (`FUTURE_VERSION`, L67-73, L123-127).

### Riesgos / problemas residuales
1. **Guardado parcial por fallo de proveedor (pérdida silenciosa de sección)**: si un proveedor devuelve tipo incorrecto o falla, `collect()` lo omite con `push_error` y **guarda el resto** (L58-62). Esto evita corrupción total del archivo, pero produce un **save válido pero incompleto** para esa sección (la sección queda con default del schema al recolectar sobre `default_payload`, o sin datos actualizados del proveedor). El jugador puede perder progreso de un subsistema sin que el guardado “falle”.
2. **Sin transaccionalidad multi-sección / sin pre-validación global**: no hay “todo o nada” lógico entre secciones. Tampoco se valida el payload agregado antes de persistir.
3. **Escritura síncrona en el hilo principal**: `SaveWriter.write_atomic()` hace I/O, serialización y HMAC síncronamente; `_process_queue()` lo ejecuta en el flujo normal. Con payloads grandes podría causar stutter (hoy acotado por cap y tamaño típico ~KB).
4. **Cola sin deduplicación/coalescing**: múltiples `request_save()` del mismo slot (p.ej. varios eventos seguidos) se encolan como entradas separadas (`_queue.append`, L190) y se procesan secuencialmente, generando escrituras redundantes.
5. **`auto_save_interval` (timer) corre aunque esté bloqueado**: el timer avanza en `_process` y al vencer llama `request_save`, que se omite con `auto_save_skipped` (L157-165, L183-186). No corrompe, pero genera intentos/logs y no “pausa” el intervalo durante bloqueos.
6. **Cierre durante `_writing` omite el guardado** (L138-140): defensivo para no intercalar, pero si hay una escritura async futura o un estado raro, el best-effort de cierre puede no persistir el último estado.
7. **Integridad HMAC con limitación conocida**: BUG-115 documenta que la clave vive en `user://` junto a los saves; detecta corrupción/tampering no reproducido, pero **no es prueba de manipulación local** (un atacante con acceso FS podría recalcular en formato legado; el HMAC protege parcialmente a saves nuevos). Esto es relevante para anti-cheat, no para corrupción accidental.
8. **Dialecto de campos `time` inconsistente**: `SaveSchema` tolera ambos dialectos (`day/season/hour/minute` vs `dia/mes/…`, L228-245; `dia_de`, L185-189) y hay deuda documentada (Log 1202) entre proveedores M14/M29/M38. Riesgo de datos no leídos correctamente por UI si se asume un dialecto.
9. **CheckpointManager y SaveManager son sistemas separados**: `CheckpointManager` (recovery/bioma) no se integra con los 3 slots de `SaveManager`. Un “checkpoint” de anti-softlock no equivale a un save-point de progreso persistente del jugador.

---

## 4) ¿Hay recuperación de saves corruptos?

Sí, en varios niveles:

- **Checksum/integridad inválida o formato inválido**: `SaveLoader._try_recover()` intenta backups en orden r1→rN (L98-138).
- **Estructura inválida**: si `SaveSchema.validate()` falla en el `.save`, pasa a recuperación (L60-63). Los backups también se normalizan (`completar`), validan estructura y rechazan versión futura (L112-127).
- **Save principal ausente pero backup presente** (guardado interrumpido tras rotar antes de escribir): `load()` detecta `has_any_backup` y recupera (L31-40).
- **`.tmp` huérfano**: limpiado al arrancar (L327-329).
- **Versionado**: versión futura no se carga/degrada (`FUTURE_VERSION`); versión menor migra con `backup_manual()` previo (L75-78). `_migrate()` hoy es infraestructura (v1 sin migraciones reales, L140-147).
- **Perfil cruzado**: no es corrupción, pero protege consistencia rechazando carga de otro perfil (`PROFILE_MISMATCH`, L270-279).
- **Límites**: si **ninguna** rotación es válida, devuelve `CORRUPTED` (L137-138). Solo hay `MAX_ROTATIONS=2` locales; el backup 3-2-1 externo se delega a M107 (comentario `save_backup.gd` L7-9).

`SaveManager.slot_recoverable()` expone si hay backups (L322-324) y `slot_metadata()` lee metadatos con parsing/validación del documento (L298-320). Señal `slot_loaded` reporta el resultado (incl. `RECOVERED`).

---

## 5) Sugerencias de mejora (2)

### Mejora 1 — Pre-validación del payload + política explícita ante proveedor fallido (evitar guardado parcial silencioso)
**Problema:** `SaveSnapshot.collect()` omite proveedores rotos y `SaveManager` persiste sin validar el payload agregado. Un fallo puede producir un save “OK” pero incompleto.  
**Acción concreta:**
- En `SaveManager._process_queue()` (o en `_payload_para_slot`), tras `snapshot.collect()`: ejecutar `SaveSchema.validate(payload)` y/o un chequeo de **secciones críticas obligatorias** (p.ej. `player`, `world`, `time`, `inventory` si están registradas). Si falla, emitir `save_failed` con razón clara y **no sobrescribir** (aprovechar que ya se rotó: considerar estrategia de rollback/copia desde backup o posponer escritura hasta validar).
- En `SaveSnapshot.collect()`, devolver además metadatos `{payload, omitted_sections, errors}` o emitir señal/log estructurado; si una sección crítica fue omitida, marcar el guardado como **degradado** y notificar a UI/telemetría en vez de reportar éxito total.
- Agregar test: proveedor crítico falla → no se debe reportar `save_completed` como estado íntegro (o se marca degradado).  
**Archivos:** `save_manager.gd` (~L200-246), `save_snapshot.gd` (~L46-63), `save_schema.gd` (validación), tests `scripts/saving/test_*.gd`.

### Mejora 2 — Coalescing de cola + checkpoint de save-point integrado con bloqueo de escena crítica
**Problema:** la cola no deduplica (`_queue` guarda cada request), el timer no se pausa semánticamente durante bloqueos, y los “checkpoints” de anti-softlock (`CheckpointManager`) están desacoplados del save de slots.  
**Acción concreta:**
- Implementar **coalescing por slot** en `_queue`: si ya hay un request pendiente para el mismo slot, actualizar `reason` (p. ej. combinar/priorizar) o descartar duplicados, manteniendo FIFO entre slots distintos. Reduce I/O y escrituras redundantes.
- Hacer el auto-save por timer **respetar bloqueos sin encolar ruido** (p. ej. no disparar `request_save` si `_blocked`, o diferir el timer) y/o exponer “próximo auto-save” a UI.
- Definir un **save-point explícito** (API tipo `request_checkpoint_save(slot, reason, force=false)`) para transiciones seguras (cambio de zona/escena, fin de combate/templo), integrable con `SceneManager`/M40 (la deuda B3 parcial ya está anotada en L126-128) y opcionalmente alineado con `CheckpointManager` para recovery rápido.  
**Archivos:** `save_manager.gd` (cola/timer, L157-249), coordinación con `core/recovery/checkpoint_manager.gd` y M40; tests de estrés/cola.

---

## Conclusión final
El sistema de guardado del proyecto **Isla Ancestral** (M59) es **maduro para un entorno Godot 4.x** y muestra evidencia clara de hardening iterativo (BUG-109 a BUG-116, orden rotate→write, recuperación multi-backup, tolerancia a proveedores rotos, HMAC con retrocompatibilidad, pruebas headless). La **escritura atómica + verificación del `.tmp` + rotación previa + recuperación desde backups** cubren bien los escenarios típicos de corrupción accidental e interrupción.

Las debilidades principales no están en la corrupción binaria del archivo (bien mitigada), sino en la **consistencia lógica del snapshot**: un proveedor fallido puede omitirse y aun así producir un guardado reportado como exitoso en flujo general, generando pérdida parcial silenciosa; además falta coalescing de peticiones y una integración más explícita entre auto-save, save-points de transición y checkpoints de recovery. Priorizar la **pre-validación/política de secciones críticas** y el **coalescing + save-points** aumentaría la confiabilidad percibida por el jugador sin reescribir la base atómica ya existente.