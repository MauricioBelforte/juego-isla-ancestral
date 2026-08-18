**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 60: Datos y Serialización

## 1. Análisis del Dominio

### 1.1 Tipos de datos en Isla Ancestral

| Tipo | Ejemplos | Ciclo de vida | Dónde vive |
|---|---|---|---|
| Datos estáticos | Items (M15), recetas (M16), cultivos (M33), configs de mundo | Inmutable (solo cambia con actualización del juego) | `res://datos/data/*.tres` |
| Configuración | Gráficos (M90), audio (M91), accesibilidad (M58) | Persistente por dispositivo, no por partida | `user://config.cfg` (ConfigFile) |
| Datos de partida | Jugador, inventario, tiempo, clima, progresión | Persistente por slot de guardado (M59) | `user://saves/slot_N/save.json` |
| Mundo voxel (M08) | Edits del jugador sobre el mundo procedural | Persistente por slot, puede ser grande | `user://saves/slot_N/mundo_voxel.bin` |
| Metadata de slot | Nombre, fecha, duración, miniatura | Derivada, para el menú de guardado | `user://saves/slot_N/meta.json` |

### 1.2 JSON vs Binario: cuándo cada formato

| Criterio | JSON (`JSON.stringify` / `JSON.parse`) | Binario (`FileAccess.store_var` / `var_to_bytes`) |
|---|---|---|
| Legibilidad | Alta: debuggable, diffable en git, editable a mano | Nula: solo legible por el juego |
| Compatibilidad Godot | Estable entre versiones (strings, numbers, arrays, dicts) | `var_to_bytes` puede cambiar internamente entre versiones de Godot → riesgo de compatibilidad |
| Tamaño | Mayor (claves repetidas) → compensar con `ZIP_DEFLATE`/`gzip` (aumenta CPU) | Menor sin comprimir |
| Error tolerance | Tolerante: campos faltantes se detectan como clave ausente | Rígido: un offset corrido corrompe todo |
| Uso recomendado | **Saves de partida** (portables entre versiones, migrables) | **Mundo voxel** (bloques densos: `PackedByteArray` con `store_var` + compresión opcional) y **config** no aplica |

**Decisión D1:** partida en **JSON** (con `variant_to_str` controlado y checksum CRC32); mundo voxel en **binario** (`PackedByteArray` de vóxeles editados) por densidad y tamaño. JSON sobre binario en saves porque priorizamos **estabilidad entre versiones** y migraciones (requisito central del módulo).

### 1.3 Resources de Godot vs archivos crudos

| Criterio | Resources `.tres` (`.tres` text / `.res` binary) | Archivos crudos (`JSON`, `CSV`, binario propio) |
|---|---|---|
| Edición | Editor de Godot nativo, inspector, herencia de Resources | Fuera del editor; tooling propio |
| Tipado | Recursos tipados con `@export`, referencias a otros Resources, `load()` con cache | Dicts sueltos, validación manual |
| Uso recomendado | **Datos estáticos del juego** (M15/16/33): items, recetas, cultivos, presets | **Datos de usuario** (saves, config) y **volúmenes grandes** (voxel) |

**Decisión D2:** los datos estáticos del juego viven como `Resource` tipados en `res://datos/data/` (`.tres` en texto, legibles en git). Los datos de usuario jamás usan Resources (el jugador no los edita en el editor y `res://` es solo lectura en build).

### 1.4 Versionado de esquema y migraciones

- Cada save incluye `version: int`. `DataStore.VERSION_ACTUAL` es la versión actual del juego.
- Al cargar: `version == VERSION_ACTUAL` → carga directa. `version < VERSION_ACTUAL` → aplicar migraciones `migrar_v1_a_v2`, `migrar_v2_a_v3`, ... en orden. `version > VERSION_ACTUAL` → **rechazar carga** (save de un juego más nuevo) con mensaje claro.
- Reglas de migración: aditivas o transformadoras; cada migración es una **función pura** `(dict_save: Dictionary) -> Dictionary`; testeable de forma aislada.
- Un save solo se marca "migrado" cuando todas las migraciones pasaron; si una falla, se restaura el `.bak` y se registra el error (M103).
- La migración se hace sobre una **copia en memoria**; el archivo original se reescribe solo tras validación exitosa.

### 1.5 DataStore (autoload) — patrón

Alternativa A: cada sistema guarda por su cuenta → saves incoherentes, formatos divergentes (descartado).
Alternativa B: un singleton `DataStore` como autoload + serializadores especializados por dominio (jugador, mundo voxel, config) → una única puerta de entrada, contratos claros, testable con inyección de dependencias en tests (M112). **Decisión D3:** B, con ServiceLocator (M07).

## 2. Alternativas consideradas y descartadas

| Alternativa | Motivo de descarte |
|---|---|
| Guardar todo el mundo voxel completo en el save | Tamaño gigante (> 100 MB); el mundo es procedural: solo se guardan **edits** + semilla + cambios de chunks modificados (M08) |
| SQLite / base de datos | Overkill para un cozy de un jugador; suma dependencia nativa y complejidad de migración |
| Solo binario (`var_to_bytes`) para todo | Compatibilidad frágil entre versiones de Godot; imposible migrar/editar a mano |
| Resources para saves del jugador | `res://` es solo lectura en exportación; los Resources no están diseñados para escritura de usuario |
| JSON sin versionado ni checksum | Incompatible con el requisito de estabilidad entre versiones; corrupto = save perdido |
| Guardado sincrónico en hilo principal | Freezes perceptibles (RN1); M62 exige presupuesto de frame |

## 3. Decisiones de diseño

| # | Decisión | Justificación |
|---|---|---|
| D1 | Partida en JSON (+CRC32), voxel en binario | Estabilidad + tamaño; ver 1.2 |
| D2 | Estáticos en Resources `.tres` tipados | Tooling del editor, integridad de tipos |
| D3 | `DataStore` autoload central | Modularidad M09, una API para todos los sistemas |
| D4 | Escritura atómica (`tmp` + rename) + `.bak` | Un crash a mitad de escritura nunca corrompe el save |
| D5 | Migraciones como funciones puras encadenadas | Testeables, orden estricto, reversibles vía backup |
| D6 | Guardado en hilo secundario (`Thread`/`WorkerThreadPool`) con `await` | RN1: sin freezes; UI de progreso (regla UX M08) |
| D7 | Config en `ConfigFile` de Godot | API nativa (secciones/claves), robusta y portable |
| D8 | IDs estables como strings (`"item.manzana"`) | Renombrar/agregar items no rompe inventarios (RN9) |
| D9 | Validación con contrato de campos (tipo + obligatorio) por versión | Dato faltante/campo nuevo → default o migración, jamás crash |
| D10 | Metadata de slot separada de los datos | El menú de guardado no deserializa todo el save (carga rápida, M63) |

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Godot cambia `var_to_bytes` entre versiones menores | Solo se usa para binario de voxel con re-test tras actualizar Godot; el resto es JSON |
| Save de versión futura | Rechazo con mensaje ("guardado de una versión más nueva") y backup intacto |
| Corrupción por corte de energía | Escritura atómica + `.bak` + checksum en dos puntos (validación al guardar y al cargar) |
| Migración con bug | Copia en memoria + `[?]` honesto + rollback al `.bak` + logs M103 |
| Mundo voxel enorme | Solo edits + compresión `ZIP_DEFLATE` opcional; presupuesto en M08/M63 |
| Encodings raros (RN6) | UTF-8 sin BOM siempre; `JSON.parse` con `err` chequeado |

## 5. Esquemas de referencia (borradores)

### 5.1 `save.json` (v1, parcial)
```json
{
  "version": 1,
  "checksum": "8f2a...",
  "meta": {"nombre": "Aurora Año 1", "fecha_iso": "2026-08-17T12:00:00Z", "segundos_jugados": 3600},
  "jugador": {"pos": [12, 34, 56], "rot": 1.5, "vida": 100, "energia": 80},
  "inventario": {"slots": [{"id": "item.madera", "n": 25}]},
  "tiempo": {"dia_anio": 1, "hora": 6.0, "estacion": "primavera"},
  "mundo_voxel": {"semilla": 12345, "archivo": "mundo_voxel.bin", "chunks_editados": 42},
  "progresion": {"misiones": {"m01": "completada"}}
}
```

### 5.2 `config.cfg` (v1)
```ini
[graficos]
calidad = "media"
vsync = true

[audio]
volumen_maestro = 0.8
volumen_musica = 0.7

[accesibilidad]
tamano_texto = 1.0
daltonismo = false
```

### 5.3 `mundo_voxel.bin` (v1)
Encabezado mágico `"IAVX1"` + contador de chunks editados + por chunk: `chunk_coord (Vector3i)`, `num_voxeles`, `PackedByteArray` de vóxeles editados `[x, y, z, tipo]`. Nada más: el resto del mundo se regenera con la semilla (M08/M10).