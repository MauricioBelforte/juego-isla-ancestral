**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 60: Datos y Serialización

> ⚠️ **ESTADO 2026-09-01: núcleo IMPLEMENTADO** por deepseek-v4-flash (Kilo Code). La estructura de archivos real difiere de la prevista (res://datos/ → res://scripts/datos/ por convención del proyecto); las firmas públicas se respetan con nombres reales.

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
├── catalogos_estaticos.gd      ← class_name CatalogosEstaticos (carga res://data/items/*.tres)
└── test_datos_m60.gd           ← Test headless (66 checks, 0 fallos)
```

**Diferencias vs plan previsto:** la ruta `res://datos/` del plan se implementó como `res://scripts/datos/` (convención real del proyecto, guía 07 §4.1: scripts en `scripts/`). `migraciones/` y `esquemas/` se integraron en versionador.gd y validador.gd respectivamente (funciones puras + `_esquema_para`). `CatalogosEstaticos` lee los `.tres` reales de M159 en `res://data/items/` (19 items detectados).

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

guardar_partida(slot, datos_sistemas) -> Dictionary   # {ok, error, duracion_ms, bytes, checksum}
cargar_partida(slot) -> Dictionary                    # {ok, slot, datos|error}
migrar(datos) -> Dictionary                           # delega a Versionador
borrar_slot(slot) -> bool
listar_slots() -> Array
guardar_config(datos) -> Error
cargar_config() -> Dictionary
cargar_mundo_voxel(slot) -> PackedByteArray
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
`cargar()` (una vez, lee res://data/items/*.tres), `obtener_item(id)`, `tiene_item(id)`, `contar_items()`. Fallback limpio si falta el directorio (tabla vacía, sin crash).

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

## Notas del Agente

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
- El test corre con: `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd` (66 checks).