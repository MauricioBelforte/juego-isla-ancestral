**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 59: Guardado

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

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 59 completo (diseño técnico de Godot 4): SaveManager con encolado, escritura atómica (.tmp+rename), checksum + validación de estructura, migración solo-hacia-delante (M60) con backup previo, rotación local de backups, snapshot por sistema vía interfaces ISaveProvider, manejo de disco lleno y múltiples slots.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Confirmar el rendimiento real del guardado en background thread (la API de hilos de Godot 4 y el envío de datos entre hilos se validarán en implementación con M61); el diseño asume < 80 ms de escritura.

### Intentos fallidos / decisiones
- Decidí la escritura atómica (.tmp+rename) como regla dura anti-corrupción: es la práctica estándar (igual que los databases) y evita saves a medias.
- Decidí que los saves de configuración (M90/M91) viven en un slot SEPARADO del progreso: nunca se mezclan.
- Decidí que las fotos (M56) se referencian por id en el save: embebidas inflarían el archivo.

### Recomendaciones para el próximo agente
- Al implementar: probar el apagado a mitad de escritura en cada plataforma (Windows/macOS/Linux) — el rename atómico varía por SO.
- Probar migraciones con saves falsos de 2 versiones atrás (M60) y verificar que el backup previo exista antes de migrar.
- Coordinar con M107 (Backups) la rotación externa y con M97 la nube de Steam si se agrega.
- Considerar cifrado/hashing del save para parche de achievements (M97/M72) si se añade más adelante.