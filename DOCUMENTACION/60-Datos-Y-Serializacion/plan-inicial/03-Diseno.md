**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 60: Datos y Serialización

## 1. Arquitectura General

```
┌────────────────────────────────────────────────────────────┐
│                        Capa de Juego (M07/M09)             │
│  Jugador · Inventario · Tiempo · Progresión · Mundo (M08)  │
└──────────────────────────┬─────────────────────────────────┘
                           │ llama API pública (contratos, sin acoplar)
┌──────────────────────────▼─────────────────────────────────┐
│              DataStore (autoload, ServiceLocator M07)      │
│                                                            │
│  ┌────────────┐ ┌─────────────┐ ┌───────────────────────┐  │
│  │ Serializer │ │ Versionador │ │ Validador             │  │
│  │ (JSON/bin) │ │ (VERSION_   │ │ (CRC32, contrato de   │  │
│  │            │ │  ACTUAL +   │ │  campos, tipos)       │  │
│  │            │ │  migraciones)│ │                       │  │
│  └────────────┘ └─────────────┘ └───────────────────────┘  │
│  ┌────────────┐ ┌─────────────┐ ┌───────────────────────┐  │
│  │ GestorSlot │ │ Writer      │ │ GestorConfig          │  │
│  │ (M59)      │ │ (atómico+   │ │ (ConfigFile M58/90/91)│  │
│  │            │ │  backup)    │ │                       │  │
│  └────────────┘ └─────────────┘ └───────────────────────┘  │
└──────────┬──────────────────────────────┬──────────────────┘
           │                              │
    ┌──────▼───────┐              ┌────────▼────────┐
    │ user://saves │              │ user://config   │
    │ /slot_N/     │              │ config.cfg      │
    │  save.json   │              └─────────────────┘
    │  mundo_voxel │
    │  .bin        │   ┌──────────────┐
    │  save.json   │   │ res://datos/ │ ← Resources .tres (M15/16/33)
    │  .bak        │   │ data/*.tres  │   solo lectura en build
    │  meta.json   │   └──────────────┘
    └──────────────┘
```

## 2. Componentes

### 2.1 `DataStore` (autoload `DataStore`) — servicio central
- Registrado en `project.godot` como autoload (`[autoload] DataStore="*res://datos/data_store.gd"`).
- Expone la API pública: `guardar_partida(slot)`, `cargar_partida(slot)`, `guardar_config()`, `cargar_config()`, `guardar_mundo_voxel()`, `cargar_mundo_voxel()`.
- Delega en: `Serializer`, `Versionador`, `Validador`, `GestorSlot`, `WriterAtomico`, `GestorConfig`.
- No conoce detalles de UI (M53) ni de gameplay: recibe/entrega Dictionaries y PackedByteArray.

### 2.2 `Serializer` — codificación
- `a_json(datos: Dictionary) -> String` con `JSON.stringify(datos, "  ")` (pretty para debugging) y UTF-8 sin BOM.
- `desde_json(texto: String) -> Dictionary` con chequeo de `err` de `JSON.parse`.
- `a_binario_voxel(edits: PackedByteArray, coord_chunks: PackedVector3Array) -> PackedByteArray` (formato `IAVX1`).
- `desde_binario_voxel(data: PackedByteArray) -> Dictionary` (devuelve chunks y bytes, o `{}` si el magic no coincide).
- Tipos admitidos en JSON: `String`, `int`, `float`, `bool`, `Vector2/3` (como arrays), `Dictionary`, `Array`, `Color` (como array).
- Estrategia de números: `float` con precisión suficiente (posiciones con 4 decimales tras `snappedf`).

### 2.3 `Versionador` — versionado y migraciones
- `VERSION_ACTUAL: int = 1` (constante; sube con cada cambio de esquema rotacional).
- Registro de migraciones: `Array` de `Callable` en orden ascendente: `[migrar_v1_a_v2, ...]`.
- `migrar(datos: Dictionary) -> Dictionary`: aplica en bucle `for v in range(datos.version, VERSION_ACTUAL)` la migración correspondiente; nunca salta versiones.
- Regla: cada migración es función pura y guarda su propia `"version"` al final.
- `version_futura(datos) -> bool`: `datos.version > VERSION_ACTUAL` → rechazo de carga.
- Migraciones en `res://datos/migraciones/` (un script por salto, testable en aislamiento).

### 2.4 `Validador` — integridad
- `calcular_crc32(datos: Dictionary) -> int`: hash sobre el JSON canónico (sin el campo `checksum`).
- `validar_contrato(datos: Dictionary, version: int) -> Array[String]`: lista de errores encontrados (campo faltante, tipo incorrecto).
- Contrato por versión en `res://datos/esquemas/esquema_v{version}.gd` (Dictionary con `{campo: tipo_esperado}` y lista de obligatorios).
- Devuelve siempre `Array[String]` de errores (vacía = OK); nunca lanza excepción.

### 2.5 `WriterAtomico` — escritura segura
- `escribir_atomicamente(ruta: String, bytes: PackedByteArray) -> Error`:
  1. Backup: copiar `archivo` → `archivo.bak` (si existe).
  2. Escribir `archivo.tmp`.
  3. `DirAccess.rename_absolute` `archivo.tmp` → `archivo`.
  4. Si falla el rename, restaurar `.bak`.
- `restaurar_backup(ruta: String) -> Error` para recuperación manual (M107).

### 2.6 `GestorSlot` — slots de guardado (contrato para M59)
- `rutas_slot(slot: int) -> Dictionary` con rutas de `save.json`, `mundo_voxel.bin`, `meta.json`, `.bak`.
- `listar_slots() -> Array` (solo lee `meta.json`, sin deserializar saves).
- `borrar_slot(slot: int)`, `existe_slot(slot: int) -> bool`.
- `meta_json(slot) -> Dictionary` para el menú (M59/M53).

### 2.7 `GestorConfig` — configuración (M58/90/91)
- `cargar_config() -> Dictionary` desde `user://config.cfg` (ConfigFile) con defaults para claves ausentes (opción nueva de una versión posterior → default sano).
- `guardar_config(datos: Dictionary) -> Error` con escritura atómica igual que los saves.
- Secciones: `[graficos]`, `[audio]`, `[accesibilidad]` (marcadas "Pendiente de implementación" de los módulos consumidores).

### 2.8 `CatalogosEstaticos` — datos estáticos (Resources M15/16/33)
- `catalogos: Array[Resource]` cargados con `load("res://datos/data/catalogos.tres")` al arranque (una sola carga, cache de Godot).
- Acceso por ID estable: `obtener_item(id: String) -> Resource` (D8).
- Si un `.tres` falta en build → log de error M103, tabla vacía y grilla limpia al registrar (validación del catálogo contra IDs referenciados en código).

## 3. Flujos

### 3.1 Flujo de guardado (manual o autosave M59)
```
1. DataStore.guardar_partida(slot)
2. Recopilar datos de los sistemas (jugador, inventario, tiempo, progresión) → Dictionary bruto
3. Versionador.set_version(datos, VERSION_ACTUAL)
4. Serializer.a_json(datos) → save.json
5. Serializer.a_binario_voxel(edits_m08) → mundo_voxel.bin
6. Validador.calcular_crc32(datos) → escribir checksum en el JSON
7. (Hilo) WriterAtomico.escribir_atomicamente(save.json) y (mundo_voxel.bin)
8. Actualizar meta.json (nombre, fecha, segundos jugados, miniatura)
9. Log M103: "Save slot N escrito (2.4 KB, 43 ms)"
10. Señal DataStore "guardado_slot(slot)" para UI (M53/M59)
```

### 3.2 Flujo de carga
```
1. DataStore.cargar_partida(slot)
2. Leer meta.json → validar que el slot existe
3. WriterAtomico/lectura de save.json → String
4. Serializer.desde_json → Dictionary (err → corrupto)
5. Validador.calcular_crc32(stdin canónico) == checksum guardado? No → corrupción → restaurar .bak y reintentar una vez
6. Versionador.version_futura? Sí → rechazar con mensaje "versión más nueva"
7. version < VERSION_ACTUAL → Versionador.migrar(datos) (en memoria) → validar contrato de la versión destino
8. Cargar mundo_voxel.bin → payload de voxel → entrega a M08 (fuera de alcance del 60)
9. Entregar datos migrados y validados a los sistemas destino
10. Log M103 + señal DataStore "cargado_slot(slot, ok)": UI reacciona (progreso/error M53)
```

### 3.3 Flujo de config
```
Arranque: GestorConfig.cargar_config() → defaults para claves faltantes → señal "config_lista"
Cambio de opción (M58/90/91): sistema escribe → DataStore.guardar_config() → escritura atómica → log
```

## 4. Convenciones de datos (contrato interno)
- Nombres de campos en snake_case.
- IDs de items: `"item.nombre"` estables (D8).
- Coordenadas voxel: `Vector3i` → `[x, y, z]` en JSON; `int32` con signo en binario.
- Fechas ISO 8601 para metadata.
- Los `float`s JSON del save se `snappedf` a ≤ 4 decimales para checksum estable.
- El checksum se calcula sobre el JSON **sin** el campo `checksum` y **sin** pretty-print extra.

## 5. Integración con otros módulos

| Módulo | Relación |
|---|---|
| M08/M10 | `mundo_voxel.bin` guarda solo edits; la semilla en `save.json` regenera el resto |
| M59 | Contrato de slots (`GestorSlot`); el 60 expone API, el 59 decide cuándo autoguardar |
| M15/16/33 | Datos estáticos en `res://datos/data/*.tres` (Resources) |
| M58/90/91 | ConfigFile compartido con secciones propias de cada uno |
| M62/M63 | Guardado/carga en hilo; tiempos dentro del presupuesto de M63 |
| M14/M71 | Bloques `inventario` y `progresion` del save (agentes proveedores de datos) |
| M29/M32 | Bloques `tiempo` y `clima` del save |
| M103 | Logs de cada operación (éxito/fallo, duración, bytes) |
| M107 | Cooperación del backup `.bak` (política de rotación) |
| M112 | Tests unitarios de migraciones, validadores y serializadores (Edit Mode) |

## 6. Presupuestos objetivo (RN1/RN2)
- Guardar completo: < 300 ms en hilo secundario (medición con `Time.get_ticks_msec()`).
- Cargar + validar + migrar: < 1 s en hilo principal (objetivo M63).
- Save principal < 1 MB; meta.json < 10 KB; config.cfg < 50 KB.
- Migración simple (1 salto): < 100 ms.