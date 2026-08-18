**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 60: Datos y Serialización

> ⚠️ Todos los archivos de este módulo son **Pendiente de implementación**: esta documentación define contratos y firmas para el agente implementador.

## 1. Ubicación de archivos previstos

```
res://datos/
├── data_store.gd               ← Autoload DataStore (registrar en project.godot)
├── data_store_main.gd (opcional si se prefiere separar)   ← ALT descartada: un solo autoload
├── serializador.gd             ← Serializer (JSON y binario voxel)
├── versionador.gd              ← Versionador (VERSION_ACTUAL, migrar)
├── validador.gd                ← Validador (CRC32, contrato por versión)
├── writer_atomico.gd           ← Escritura atómica + backup .bak
├── gestor_slot.gd              ← Slots de guardado (contrato M59)
├── gestor_config.gd            ← ConfigFile (M58/90/91)
├── catalogos_estaticos.gd      ← Recursos .tres del juego (M15/16/33)
├── esquemas/
│   └── esquema_v1.gd           ← Contrato de campos de la versión 1
├── migraciones/
│   └── (por salto cuando suba VERSION_ACTUAL)
└── data/
    ├── catalogos.tres          ← Resources: items (M15), recetas (M16), cultivos (M33)
    └── (más .tres por catálogo si conviene separarlos)
```

Todos los archivos listados arriba: **Pendiente de implementación**.

## 2. Registro en project.godot

```
[autoload]
DataStore="*res://datos/data_store.gd"
```

## 3. Firmas de funciones previstas (GDScript)

### 3.1 `data_store.gd` — API pública del módulo

```gdscript
class_name DataStore
extends Node

signal guardado_slot(slot: int, ok: bool, duracion_ms: int, bytes: int)
signal cargado_slot(slot: int, ok: bool, error: String)
signal config_lista(config: Dictionary)
signal config_guardada(ok: bool)

const VERSION_ACTUAL: int = 1

## Guarda la partida completa en el slot indicado (ver flujo 3.1 de 03-Diseno.md).
## Devuelve metadata del guardado para el menú (M59/M53).
func Guardar(slot: int) -> Dictionary: pass

## Carga y entrega la partida del slot (ver flujo 3.2 de 03-Diseno.md).
## Aplica migraciones y validación; nunca crashea: devuelve {ok: false, error: ...} en fallo.
func Cargar(slot: int) -> Dictionary: pass

## Migra un Dictionary de save desde su versión actual hasta VERSION_ACTUAL (en memoria).
func migrar(datos: Dictionary) -> Dictionary: pass

## Borrado seguro de un slot (con confirmación del llamador).
func borrar_slot(slot: int) -> bool: pass

## Lista slots existentes leyendo solo meta.json (rápido, sin deserializar saves).
func listar_slots() -> Array: pass

## Guardado de configuración (M58/90/91) en user://config.cfg.
func guardar_config(datos: Dictionary) -> Error: pass

## Carga de configuración con defaults para claves ausentes (RN: opción nueva de versión futura).
func cargar_config() -> Dictionary: pass

## Entrega al M08 el payload del mundo voxel guardado.
func cargar_mundo_voxel(slot: int) -> PackedByteArray: pass
```

### 3.2 `serializador.gd`

```gdscript
class_name Serializer

## JSON pretty (2 espacios), UTF-8 sin BOM. No incluye checksum.
static func a_json(datos: Dictionary) -> String: pass

## JSON.parse con chequeo de error; devuelve {} + error en log M103 si falla.
static func desde_json(texto: String) -> Dictionary: pass

## Formato IAVX1: magic + count + chunks (coord int32 x3 + PackedByteArray de voxeles).
static func a_binario_voxel(chunks: Array) -> PackedByteArray: pass

## Detecta magic "IAVX1"; si no coincide devuelve {} (corrupto/futuro).
static func desde_binario_voxel(data: PackedByteArray) -> Dictionary: pass

## Normaliza floats del save a 4 decimales para checksum estable.
static func normalizar_float(valor: float) -> float: pass
```

### 3.3 `versionador.gd`

```gdscript
class_name Versionador

const VERSION_ACTUAL: int = 1   # Sube con cada cambio rotacional de esquema
const MIGRACIONES: Array[Callable] = [
    # migrar_v1_a_v2,
]

## Aplica migraciones en orden estricto desde datos.version hasta VERSION_ACTUAL.
## Devuelve los datos migrados o {ok: false, error: String} sin mutar el original.
static func migrar(datos: Dictionary) -> Dictionary: pass

## true si el save es de una versión más nueva que este juego (rechazar carga).
static func version_futura(datos: Dictionary) -> bool: pass

## Asigna la version en el dict (por convención: siempre al final de cada migración).
static func set_version(datos: Dictionary, v: int) -> void: pass
```

### 3.4 `validador.gd`

```gdscript
class_name Validador

## CRC32 sobre el JSON canónico del dict (sin campo checksum).
static func calcular_crc32(datos: Dictionary) -> int: pass

## Contrato de la versión: Array[String] de errores (vacío = OK).
## Chequea campos obligatorios y tipos exactos (int, float, String, Array, Dictionary, bool).
static func validar_contrato(datos: Dictionary, version: int) -> Array[String]: pass

## Devuelve true si el checksum del save coincide con el calculado.
static func verificar_integridad(datos: Dictionary, checksum_guardado: int) -> bool: pass
```

### 3.5 `writer_atomico.gd`

```gdscript
class_name WriterAtomico

## Escribe de forma atómica: .bak → .tmp → rename. Restaura .bak si el rename falla.
static func escribir_atomicamente(ruta: String, bytes: PackedByteArray) -> Error: pass

## Restaura el .bak sobre el archivo principal (recuperación manual, M107).
static func restaurar_backup(ruta: String) -> Error: pass
```

### 3.6 `gestor_slot.gd`

```gdscript
class_name GestorSlot

const RAIZ_SAVES: String = "user://saves"

static func rutas_slot(slot: int) -> Dictionary: pass   # save.json, mundo_voxel.bin, meta.json, .bak
static func existe_slot(slot: int) -> bool: pass
static func borrar_slot(slot: int) -> bool: pass
static func leer_meta(slot: int) -> Dictionary: pass    # solo meta.json
static func escribir_meta(slot: int, meta: Dictionary) -> Error: pass
```

### 3.7 `gestor_config.gd`

```gdscript
class_name GestorConfig

const RUTA_CONFIG: String = "user://config.cfg"
const SECCIONES: Array[String] = ["graficos", "audio", "accesibilidad"]

static func cargar_config(defaults: Dictionary) -> Dictionary: pass
static func guardar_config(datos: Dictionary) -> Error: pass
```

### 3.8 `catalogos_estaticos.gd`

```gdscript
class_name CatalogosEstaticos

## Carga única de res://datos/data/catalogos.tres al arranque (cache de Godot).
static func cargar() -> void: pass

## Acceso por ID estable tipo "item.madera". null si no existe (validar en caller).
static func obtener_item(id: String) -> Resource: pass
```

## 4. Convenciones de implementación
- Nada de C#: todo GDScript, Godot 4.x (usar `JSON.stringify`, `JSON.parse`, `ConfigFile`, `FileAccess`, `DirAccess`, `Thread`/`WorkerThreadPool`).
- Errores como valores de retorno (`Error`, `Array[String]` de errores), jamás excepciones no controladas en el hilo de carga.
- Todo IO del save en `user://`; jamás escribir en `res://`.
- El DataStore no conoce UI: emite señales y devuelve dicts/bytes; la UI reacciona (M53).
- Logs en M103 para: guardar, cargar, migrar, validar, restaurar, config (éxito/fallo, bytes, ms).

## 5. Definición de listo (DoD del módulo)
1. `DataStore` autoload registrado y sin errores en la consola de Godot.
2. Guardar/cargar un slot completo (JSON + binario voxel) con checksum verificado.
3. Migración v1→vN probada con un save viejo de test (fixture).
4. Save corrupto de prueba → detectado, backup restaurado, sin crash.
5. Config guardada/leída con defaults.
6. Tiempos dentro de RN1/RN2 medidos.
7. Checklist del módulo al 100 % y documentación plan-actual al día.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 60 (plan-inicial y plan-actual): requerimientos (12 RF + 10 RN + criterios), análisis (JSON vs binario, Resources vs archivos, versionado, migraciones, DataStore, alternativas descartadas, riesgos), diseño (arquitectura con 8 componentes, 3 flujos, contrato interno, integraciones y presupuestos) y código (8 archivos previstos en `res://datos/`, firmas GDScript, convenciones y DoD).
- Checklist del módulo con más de 125 ítems completados (formato `- [x]` con marcador [S]/[M]/[C]).
- Decidí y documenté: partida en JSON + CRC32 (estabilidad entre versiones), mundo voxel en binario IAVX1 (solo edits, M08), config en ConfigFile, data estática en Resources `.tres`, escritura atómica con backup `.bak`, migraciones como funciones puras.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé código: el módulo queda **delegable para implementar** (no hay motor Godot configurado en esta sesión para verificar ejecución).
- M59 (Guardado) está sin documentar: me referencé a su contrato (`GestorSlot`) sin bloquear el módulo; el agente de M59 debe validar la interoperabilidad.
- No probé tiempos reales (RN1/RN2): los presupuestos son objetivos de diseño, no mediciones.

### Recomendaciones para el próximo agente
- Implementar en orden: `writer_atomico` → `serializador` → `validador` → `versionador` → `gestor_slot` → `gestor_config` → `data_store`; cada paso testable (M112).
- Al registrar el autoload, verificar que `res://datos/data/catalogos.tres` exista o que la carga falle limpia (validación catálogos).
- Al conectar M08: confirmar el formato de "edits" que entrega el voxel world (PackedByteArray por chunk) y ajustar `a_binario_voxel` si difiere.
- Al conectar M59: no duplicar lógica de slots; consumir `GestorSlot` desde el 60.
- Probar migraciones con fixtures reales de saves viejos (crearlos con una versión anterior deliberadamente).
- Al subir `VERSION_ACTUAL`, agregar SIEMPRE una migración nueva en `MIGRACIONES` y una entrada de contrato nueva en `esquemas/`; jamás editar migraciones existentes (rompe cadenas).
- Re-ejecutar el checklist de testings del módulo y actualizar `CHECKLIST-GLOBAL.md` con el progreso real.