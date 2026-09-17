**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 04-Codigo.md — Módulo 124: Contenido Generado por Usuarios

> **Reescrito 2026-09-15 (iter. 2, Log 905).** La versión anterior describía una
> proyección **Unity/C#** (`scripts/ugc/ugc_manager.gd`,
> `ModerationPipeline.cs` _(diseno heredado)_, `services/ugc/db.sql`…) que **no existe en el repo**.
> Ver §5 "Diseño original NO implementado".

## 1. Archivos reales (Godot 4.7.2 / GDScript)

### 1.1 Existentes (iter. 1 — 2026-09-02)
| Archivo | Rol |
|---------|-----|
| `game/isla-ancestral/scripts/ugc/ugc_manager.gd` | **Autoload `UgcManager`** (`project.godot`: `UgcManager="*res://scripts/ugc/ugc_manager.gd"`). Catálogo data-driven: `contenido(id)`, `por_estado()`, `por_tipo()`, `tipos_validos()`, `estados_validos()`, `politica()`. Se registra en `ServiceRegistry` como `ugc`. |
| `game/isla-ancestral/scripts/ugc/ugc_validator.gd` | `class_name UgcValidator`: `validar(data) -> Array[String]` (IDs únicos, tipos/estados válidos, política presente) y `reporte(errores) -> String`. |
| `game/isla-ancestral/data/ugc/ugc_catalog.json` | Catálogo: 3 piezas, 5 tipos, 4 estados, política + (iter. 2) `limites` y `claves_prohibidas_blueprint`. |
| `game/isla-ancestral/scripts/ugc/test_ugc_m124.gd` | Test headless iter. 1 — **16 checks**. |

### 1.2 Nuevos (iter. 2 — 2026-09-15)
| Archivo | Rol |
|---------|-----|
| `scripts/ugc/ugc_limits.gd` | `class_name UgcLimits` — límites de almacenamiento **RF13**, data-driven desde `limites`. |
| `scripts/ugc/ugc_sanitizer.gd` | `class_name UgcSanitizer` — 4K→2K, formatos, blueprint sin coords del save, compresión ZSTD. |
| `scripts/ugc/ugc_telemetry.gd` | `class_name UgcTelemetry` — eventos publicar/ver/descargar/reportar **sin PII**, export a M104. |
| `scripts/ugc/test_ugc_m124_iter2.gd` | Test headless iter. 2 — **85 checks**, 6 bloques con marcador `_fin()` + watchdog. |

## 2. API real (iter. 2)

### 2.1 `UgcLimits` (RF13)
```gdscript
static func desde_catalogo(config: Dictionary) -> UgcLimits
func items_activos_max() -> int          # 200
func fotos_por_dia_max() -> int          # 50
func blueprints_por_dia_max() -> int     # 20
func bytes_por_dia_max() -> int          # 10 485 760 (10 MB)
func peso_max(tipo: String) -> int       # foto 3 MB · blueprint 256 KB · construccion 512 KB
func lado_max_foto_px() -> int           # 2048
func formatos_foto() -> Array            # ["jpg", "webp"]
func sla_reporte_horas(categoria) -> int # nsfw/violencia/odio 24 · copyright/privacidad 48 · spam 72
func validar_item(tipo, bytes, formato) -> Dictionary
func validar_cuota(uso, tipo, bytes) -> Dictionary
func validar_subida(uso, tipo, bytes, formato) -> Dictionary
func consumir(uso, tipo, bytes, formato) -> Dictionary   # valida y descuenta
func uso_vacio() -> Dictionary           # {items_activos, fotos_hoy, blueprints_hoy, bytes_hoy}
```
Todos los validadores devuelven `{ok, motivo, mensaje}`:
- `motivo` es una **constante** (`MOTIVO_OK`, `MOTIVO_PESO_EXCEDIDO`, `MOTIVO_FORMATO_NO_SOPORTADO`,
  `MOTIVO_BYTES_INVALIDOS`, `MOTIVO_TIPO_DESCONOCIDO`, `MOTIVO_CUOTA_ITEMS`,
  `MOTIVO_CUOTA_DIARIA`, `MOTIVO_CUOTA_BYTES`) — para que el test no compare strings sueltos.
- `mensaje` es texto listo para mostrar (checklist §14, ítem 144). Si el redondeo humano
  dejaría dos valores iguales ("3.0 MB de 3.0 MB"), cae a **bytes crudos**.

Los topes son **inclusivos**: 3 MB exactos pasa, 3 MB + 1 byte no.

### 2.2 `UgcSanitizer`
```gdscript
# Fotos (headless-safe: Image.resize() es CPU, no necesita viewport)
static func necesita_redimension(tam: Vector2i, lado_max := 2048) -> bool
static func factor_escala(tam: Vector2i, lado_max := 2048) -> float
static func tamano_escalado(tam: Vector2i, lado_max := 2048) -> Vector2i
static func redimensionar(img: Image, lado_max := 2048) -> Image
static func preparar_foto(img: Image, lado_max := 2048) -> Dictionary
static func formato_de_ruta(ruta: String) -> String

# Blueprints
static func claves_prohibidas_presentes(bp: Dictionary) -> Array
static func sanitizar_blueprint(bp: Dictionary) -> Dictionary   # {datos, eliminadas, limpio}

# Compresión
static func json_compacto(datos) -> String
static func bytes_de_json(datos) -> int
static func comprimir_a_archivo(datos, ruta) -> bool
static func leer_de_archivo(ruta) -> Dictionary
static func peso_archivo_comprimido(datos, ruta) -> int
```
**Decisión de diseño (documentada y testeada):** las claves de **contenido**
(`piezas`, `bloques`, `partes`, `items`, `contenido`) se copian **intactas**. Las
posiciones de las piezas son **relativas al blueprint** y son el contenido; las
"coords del save" que hay que eliminar son las del **sobre** (dónde está el jugador,
qué slot se usó, qué cuenta). `CLAVES_PROHIBIDAS` (exactas) + `SUBCADENAS_PROHIBIDAS`
(atrapan `world_coords_2`, `my_steam_id`…).

### 2.3 `UgcTelemetry` (RF7 / M104)
```gdscript
static func hash_alias(alias: String) -> String      # FNV-1a 32 bits -> 8 hex
static func claves_pii(datos: Dictionary) -> Array
static func tiene_pii(datos: Dictionary) -> bool
func avanzar(delta_s: float) -> void                 # reloj inyectable
func registrar(evento, item_id, alias := "", extra := {}) -> bool
func cantidad(evento) -> int
func items_unicos() / autores_unicos() -> int
func resumen() -> Dictionary
func exportar_json() -> String
func cargar_json(txt: String) -> bool
func exportar_a_m104() -> Array
```
Del alias **solo** se guarda el hash: no se puede recuperar. `registrar()` devuelve
`false` (y **no** suma contadores) si el evento no es válido o si `extra` trae
cualquier clave PII, incluso anidada.

## 3. Datos / config
| Dato | Ubicación | Notas |
|------|-----------|-------|
| Catálogo UGC | `res://data/ugc/ugc_catalog.json` | `contenido`, `tipos_validos`, `estados_validos`, `politica` |
| Límites | mismo archivo, clave `limites` | RF13, data-driven (el código tiene defaults si falta) |
| Claves prohibidas | mismo archivo, `claves_prohibidas_blueprint` | informativo; la fuente efectiva es `UgcSanitizer.CLAVES_PROHIBIDAS` |
| Backend de servicio | **NO EXISTE** | área de servicio post-V2 (ver §5) |

## 4. Tests
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `scripts/ugc/test_ugc_m124.gd` | headless (iter. 1) | catálogo, por estado/tipo, `UgcValidator` — **16 checks** |
| `scripts/ugc/test_ugc_m124_iter2.gd` | headless (iter. 2) | límites, sanitización, telemetría, regresión iter. 1 — **85 checks** |

Total M124: **101 checks**. Ver `06-Plan-Testings.md` y `07-Resultados-Testings.md`.

## 5. ⚠️ Diseño original NO implementado (proyección Unity/C#)
La tabla de la versión anterior de este documento era una **proyección post-V2**
escrita en C#/Unity. Nada de eso existe en el repo. Mapeo honesto:

| Proyección (no existe) | Estado real |
|------------------------|-------------|
| `scripts/ugc/ugc_manager.gd` | **Existe en GDScript**: `scripts/ugc/ugc_manager.gd` (catálogo local, sin red) |
| `Assets/_Project/Scripts/Moderacion/ModerationPipeline.cs` _(diseno heredado)_ | **NO existe**. Solo hay política en el JSON (`requiere_revision`) y la cola humana es un proceso |
| `Assets/_Project/Scripts/Moderacion/Apelaciones.cs` _(diseno heredado)_ | **NO existe** |
| `Assets/_Project/Scripts/UI/GaleriaView.cs` _(diseno heredado)_, `CompartirView.cs` _(diseno heredado)_ | **NO existe** (M89 no tiene estas vistas) |
| `services/ugc/` + `db.sql` | **NO existe** (backend de servicio, post-V2) |
| `CameraManager` (M56) botón "Compartir" | **NO cableado** |
| `BuildPlans` (M18) export a UGC | **NO cableado** |
| `ComunidadManager` (M100) reportes | **NO cableado** |
| Telemetría M104 | **Sí**: `UgcTelemetry.exportar_a_m104()` (gancho listo, sin consumidor) |
| ToS (M125) cláusula UGC | Documento, no código |

**Lo que sí es verificable headless y está hecho:** límites (RF13), sanitización
(4K→2K, sin coords del save, compresión) y telemetría sin PII. Lo demás es
**servicio/infra/UI/legal** y queda `[?]` con dueño externo.

## 6. Trampas medidas en este módulo (Godot 4.7.2)
1. **`PackedByteArray.compress()` + `.decompress()` NO cierran el ciclo.** Medido:
   `compress(ZSTD)` → 42 B y `decompress(true)` → **1 B**; `compress(DEFLATE)` → 41 B y
   `decompress(false, 33)` → **0 B**; `compress()` → 35 B y `decompress(true)` → 1 B.
   El motor tira `func_PackedByteArray_decompress (core/variant/variant_call.cpp)`.
   **Vía que sí funciona:** `FileAccess.open_compressed(ruta, WRITE/READ, COMPRESSION_ZSTD)`.
2. **`decompress()` exige el primer argumento** (`dynamic_size`): sin él es un
   **Parse Error**, no un default.
3. **El proyecto trata los WARNINGS de GDScript como errores.** Un `:=` sobre un valor
   `Variant` (`var limpio := _limpiar(...)`, que devuelve `Variant`) es
   `Parse Error: The variable type is being inferred from a Variant value
   (Warning treated as error.)`. Anotar siempre: `var limpio: Variant = ...`.
   Igual con `Dictionary`/`Array` que salen de `Variant`: usar `x as Dictionary`.
4. **Un error dentro de `_run()` con `call_deferred` cuelga el `SceneTree` para siempre**
   y el stdout se pierde por buffering al matar el proceso. En `--script` el proceso
   nunca llega a `quit()`. Mitigación: **watchdog en `_process`** que cierra tras N frames
   (implementado en `test_ugc_m124_iter2.gd`).
5. **`Image.create_empty()` y `Image.create()` existen ambos** en este build;
   `Image.resize()` con `INTERPOLATE_LANCZOS` funciona **headless** (es CPU, no
   necesita viewport). Las imágenes grandes (4096×2160) tardan pero no cuelgan.
6. `JSON.stringify()` sin `indent` ya produce JSON compacto.

## 7. Notas de integración
- **M123 Modding**: el UGC no ejecuta scripts (misma regla que M123).
- **M109**: la validación de límites del diseño al compartir se resuelve en el cliente
  con `UgcLimits.validar_subida()` / `consumir()`.
- **M80 (privacidad)**: consentimiento y región son proceso/servicio → `[?]`.
- **M104 (telemetría)**: `exportar_a_m104()` deja el evento en el shape esperado; falta
  el consumidor.
- **M125 (ToS) / M127 (copyright)**: cláusula UGC y licencia son texto legal → `[?]`.
- **M106 (seguridad)**: auth + rate limit del servicio → `[?]` (no hay servicio).
