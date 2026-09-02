# Log 338: M60 Datos y Serialización — Núcleo Iter. 1

**Fecha:** 2026-09-01
**Hora:** 04:20
**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code

## Resumen

Se implementó el núcleo del Módulo 60 (Datos y Serialización): el autoload `DataStore` y sus 7 componentes de soporte, según el contrato de `plan-actual/` (03-Diseno y 04-Codigo). Test headless 66/0 OK, regresión M59 13/13 OK, boot del proyecto sin errores del módulo.

## Cambios Realizados

1. **Guía 10 comparativa de modelos:** agregada §9 "Autoevaluación honesta — deepseek-v4-flash / Kilo Code" con confirmación de perfil, capacidades con evidencia del proyecto, límites y propuestas de delegación (§9.5).

2. **Implementación en `game/isla-ancestral/scripts/datos/`:**
   - `data_store.gd` — autoload `DataStore` (registrado en `project.godot` y en ServiceRegistry como `"datos"`). API: `guardar_partida`, `cargar_partida`, `migrar`, `borrar_slot`, `listar_slots`, `guardar_config`, `cargar_config`, `cargar_mundo_voxel`. Señales `guardado_slot`, `cargado_slot`, `config_lista`, `config_guardada`.
   - `serializador.gd` — `Serializer` (JSON pretty UTF-8 sin BOM, `a_json_canonico`, `a_plano` para Vector2/3/Color/Vector3i, binario voxel con magic `IAVX1`).
   - `versionador.gd` — `Versionador` (VERSION_ACTUAL=1, migraciones como funciones puras en orden estricto, rechazo de versión futura).
   - `validador.gd` — `Validador` (CRC32 tabla 0xEDB88320, contrato v1 por `_esquema_para`, normalización float→int de JSON por hallazgo §9.54).
   - `writer_atomico.gd` — `WriterAtomico` (.bak→.tmp→rename→restauración; patrón checksum cadena-exacta §9.11; variante cruda para ConfigFile).
   - `gestor_slot.gd` — `GestorSlot` (rutas `user://saves/slot_N/{save.json,mundo_voxel.bin,meta.json,.bak}` compatibles con M59 sin pisar `slot_N.save`).
   - `gestor_config.gd` — `GestorConfig` (ConfigFile `user://config.cfg` con secciones graficos/audio/accesibilidad y defaults).
   - `catalogos_estaticos.gd` — `CatalogosEstaticos` (carga única de `res://data/items/*.tres` reales de M159: 19 items; fallback limpio).

3. **`project.godot`:** autoload `DataStore="*res://scripts/datos/data_store.gd"` agregado.

4. **Test headless:** `test_datos_m60.gd` (66 checks) cubre: Serializer JSON ida/vuelta, a_plano, binario voxel round-trip, CRC32 determinista, contrato v1, migraciones/versión futura, escritura atómica + corrupción + restauración de backup, GestorSlot, GestorConfig defaults/merge/claves futuras, CatalogosEstaticos reales, y DataStore end-to-end (guardar→cargar→igualdad, corrupción sin crash, borrado).

5. **Guía Godot 07:** agregadas §9.54 (`JSON.parse_string` devuelve FLOAT para enteros en Godot 4.7) y §9.55 (`FileAccess` sin `.close()` bloquea borrado en Windows); actualizada la firma y el histórico de versiones.

6. **Documentación del módulo:** `plan-actual/04-Codigo.md` actualizado con el estado real (ubicación de archivos real vs prevista, API pública, convenciones, DoD cumplido) y Notas del Agente del nuevo implementador. `05-Checklist.md` relevado a 179/197.

7. **Registros de coordinación actualizados:** `CHECKLIST-GLOBAL.md` (fila 60 → 🟡 179/197), guía 08 (fila M60 → liberado núcleo), `ESTADO-PARALELO.md` (fila M60 cerrada).

## Archivos Modificados/Creados

**Creados:**
- `game/isla-ancestral/scripts/datos/data_store.gd`
- `game/isla-ancestral/scripts/datos/serializador.gd`
- `game/isla-ancestral/scripts/datos/versionador.gd`
- `game/isla-ancestral/scripts/datos/validador.gd`
- `game/isla-ancestral/scripts/datos/writer_atomico.gd`
- `game/isla-ancestral/scripts/datos/gestor_slot.gd`
- `game/isla-ancestral/scripts/datos/gestor_config.gd`
- `game/isla-ancestral/scripts/datos/catalogos_estaticos.gd`
- `game/isla-ancestral/scripts/datos/test_datos_m60.gd`

**Modificados:**
- `game/isla-ancestral/project.godot` (autoload DataStore)
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (§9 autoevaluación deepseek-v4-flash)
- `DOCUMENTACION/07-GUIA-GODOT.md` (§9.54, §9.55, firma, histórico)
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/04-Codigo.md` (estado real)
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md` (179/197)
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`
- `Logs/ULTIMO_NUMERO.txt` (322)

## Verificación

- Test M60: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd` → **66 checks, 0 fallos**.
- Regresión M59: `--script res://scripts/saving/validate_save.gd` → **13/13 OK**.
- Boot del proyecto headless: `DataStore` registrado en ServiceRegistry y listo, sin errores del módulo M60 (los errores de NPCAgent/npc_manager son preexistentes del M64, ajenos a este cambio).

## Pendientes honestos (18 ítems de checklist)

- [ ] RF10 guardado en hilo secundario (dueño: M62/M63 presupuesto de frame; la escritura síncrona actual mide 10 ms).
- [ ] Contrato "edits" del mundo voxel alineado al formato real de Voxel Tools (dueño: M08 al conectar).
- [ ] Recetas/cultivos como `.tres` (dueño: M16/M33 al producir datos).
- [ ] Compresión ZIP_DEFLATE opcional del binario voxel, política de rotación .bak con M107, doble guardado concurrente, etc. (íntegra lista en 05-Checklist).