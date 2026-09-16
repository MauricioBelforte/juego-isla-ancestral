# Log 905 — M124 Contenido Generado por Usuarios — Iteración 2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Módulo:** 124-Contenido-Generado-Por-Usuarios (A11)
**Reserva:** `Logs/reservas/905-DSV41F-M124.txt` (borrada al cerrar)
**Reclamo:** §21.4.7 — dueño `deepseek-v4-flash-vision-exp` descatalogado

---

## 1. Contexto

El módulo estaba en `🟡 Con dudas | 10/106` con la nota "Verificado (Log 530): 16/16 tests OK".
Al abrirlo aparecieron **tres problemas de fondo**:

1. **Sobre-cierre**: el bloque de totales del `05-Checklist.md` declaraba
   "106 resueltos, 0 pendientes" cuando el cuerpo tenía **41 `[ ]` reales** (recontado
   sobre los ítems de lista, no sobre el texto del banner).
2. **`04-Codigo.md` describía Unity/C#**: `Assets/_Project/Scripts/Online/UgcManager.cs`,
   `ModerationPipeline.cs`, `Apelaciones.cs`, `GaleriaView.cs`, `services/ugc/db.sql`…
   **nada de eso existe** en el repo. Es la misma proyección muerta que en M26/M52/M148.
3. **Rutas falsas** en la nota de QA de Hy3: `data/legal/ugc/ugc_catalog.json` y
   `scripts/legal/UgcValidator.gd` no existen (los reales son `data/ugc/` y
   `scripts/ugc/`). Además esa línea tenía un **vertical tab (0x0B)** donde iba la `v`
   de `validar()` y una `r` comida en `eporte()`.

Lo que **sí** existía (iter. 1, 2026-09-02): autoload `UgcManager` (catálogo
data-driven), `UgcValidator` (validación del catálogo), `data/ugc/ugc_catalog.json`
y `test_ugc_m124.gd` (16 checks).

## 2. Qué se implementó (la parte verificable headless)

| Archivo | Qué hace |
|---------|----------|
| `scripts/ugc/ugc_limits.gd` | `UgcLimits` — **RF13** data-driven desde el bloque `limites` del catálogo. Validación **por ítem** (peso, formato) y **por cuota** (ítems activos, fotos/día, blueprints/día, bytes/día). Devuelve `{ok, motivo, mensaje}` con `motivo` como **constante** y `mensaje` listo para mostrar. `consumir()` valida y descuenta. |
| `scripts/ugc/ugc_sanitizer.gd` | `UgcSanitizer` — redimensión **4K→2K** con `Image.resize()` (CPU, headless-safe), formatos soportados, **blueprint sin coords del save** (claves prohibidas exactas + subcadenas) y compresión **ZSTD**. |
| `scripts/ugc/ugc_telemetry.gd` | `UgcTelemetry` — eventos publicar/ver/descargar/reportar **sin PII**: del alias solo queda un hash FNV-1a 32 bits; `registrar()` rechaza payloads con claves PII (incluso anidadas) y no suma contadores. Reloj inyectable. `exportar_a_m104()`. |
| `scripts/ugc/test_ugc_m124_iter2.gd` | 85 checks en 6 bloques con marcador `_fin()` + **watchdog** anti-cuelgue. |

`data/ugc/ugc_catalog.json` se extendió de forma **aditiva** con `limites` y
`claves_prohibidas_blueprint`: la iter. 1 (3 piezas / 5 tipos / 4 estados) sigue verde.

### Decisión de diseño (documentada y testeada)
Las claves de **contenido** (`piezas`, `bloques`, `partes`, `items`, `contenido`) se
copian **intactas**. Las posiciones de las piezas son **relativas al blueprint** y son
el contenido; las "coords del save" que hay que eliminar son las del **sobre** (dónde
está el jugador, qué slot se usó, qué cuenta). CP D-14 lo verifica explícitamente.

## 3. Bugs y hallazgos reales

### 3.1 `PackedByteArray.compress()` + `.decompress()` NO cierran el ciclo (motor)
Medido con sonda sobre 33 B de JSON:

| Llamada | Resultado |
|---------|-----------|
| `compress(ZSTD)` → 42 B, `decompress(true)` | **1 B** |
| `compress(DEFLATE)` → 41 B, `decompress(false, 33)` | **0 B** |
| `compress()` → 35 B, `decompress(true)` | **1 B** |

El motor tira `func_PackedByteArray_decompress (core/variant/variant_call.cpp:818)`.
El síntoma en el test era `Unicode parsing error ... Invalid UTF-8 leading byte (b5)`
(0xB5 es parte de la magic de ZSTD: la "descompresión" devolvía la entrada cruda).
Además **`decompress()` exige el primer argumento** (`dynamic_size`): sin él es un
**Parse Error**, no un default.

**Solución:** comprimir con `FileAccess.open_compressed(ruta, WRITE/READ, COMPRESSION_ZSTD)`
— roundtrip verificado (CP D-18/D-19).

### 3.2 El proyecto trata los WARNINGS de GDScript como ERRORES
`var limpio := _limpiar(bp, ...)` (la función devuelve `Variant`) →
`Parse Error: The variable type is being inferred from a Variant value, so it will be
typed as Variant. (Warning treated as error.)` → `Failed to compile depended scripts`
→ el script no carga y **el bloque de test aborta en silencio**.

Corregido con anotación explícita (`var limpio: Variant = ...`) y casts (`x as Dictionary`)
en `ugc_sanitizer.gd`, `ugc_limits.gd` y `ugc_telemetry.gd`.

### 3.3 Un aborto silencioso CUELGA el proceso (no solo da falso verde)
Con `extends SceneTree` + `call_deferred("_run")`, si algo aborta dentro de `_run()`
**nunca se llega a `quit()`** y el `SceneTree` corre para siempre. Al matar el proceso
se pierde el stdout (buffering), así que el síntoma es "la corrida no devuelve nada".

**Mitigación:** watchdog en `_process` que cierra con código 1 tras `FRAMES_MAX` (300)
frames e imprime `!! WATCHDOG: ...`. Es la segunda red, además de los marcadores `_fin()`.

### 3.4 Bug propio del test
CP D-18 falló en la primera corrida (roundtrip de compresión). La causa era la **API del
motor** (§3.1), no la aserción: se cambió la implementación, no el test.

### 3.5 Documentación
- `04-Codigo.md` reescrito con los archivos Godot reales + sección
  "⚠️ Diseño original NO implementado" con el mapeo de los `.cs` de Unity.
- `05-Checklist.md`: convención reparada (`[x]` estaba como "pendiente"), **16 ítems
  pasados a `[x]`** con nota de evidencia, **25 a `[?]`** con dueño, bloque de totales
  corregido + nota de sobre-cierre, y la línea corrupta (0x0B) reparada.
- `06-Plan-Testings.md` y `07-Resultados-Testings.md` creados.

## 4. Evidencia

```
=== Resumen M124: 85 checks, 0 fallos ===
TEST M124 OK — todos los checks pasaron
EXIT 0 · SCRIPT ERROR: 0        (×3)
```
Regresión iter. 1 (`test_ugc_m124.gd`): **16/0 ×2**, `EXIT 0`, `0 SCRIPT ERROR`.
**Total M124: 101 checks.**

Bloques medidos (no estimados): A 12 · B 12 · C 12 · D 21 · E 18 · F 4 · marcadores 6 = 85.

## 5. Cierre del ciclo

- `05-Checklist.md` → **81 `[x]` · 25 `[?]` · 0 `[ ]`** (108 líneas de ítem reales).
- **CI:** `test_ugc_m124.gd` y `test_ugc_m124_iter2.gd` cableados en la job `test-suite`
  de `.github/workflows/quality.yml` (20 tests, YAML validado con PyYAML, 6 jobs).
- **Fila 124 de `CHECKLIST-GLOBAL.md`:** `🟡 Con dudas | 10/106` → `🟡 Con dudas / Liberado (iter. 2 ✅) | 81/106`.
- `Mensajes entre modelos/ESTADO-PARALELO.md` y
  `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` actualizados
  (A11 + ciclo 13).
- Reserva `905-DSV41F-M124.txt` borrada.

## 6. Pendientes

- **QA cruzado §21.8 de M124** por otro agente (verificador ≠ autor).
- 25 ítems `[?]` con dueño externo: backend/CDN/bucket (infra), moderación con IA y
  cola humana (servicio/ops), UI de galería/perfil (M89), cableado con M56/M18/M100,
  región de datos (M80), derecho al olvido operativo, ToS/DMCA (M125/M127), rate limit
  (M106), y las 3 decisiones de GATE del §1.
- Re-codificación real de imágenes (JPEG/WebP): el módulo valida el **formato declarado**;
  no hay codificador en GDScript puro.

---

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-15
