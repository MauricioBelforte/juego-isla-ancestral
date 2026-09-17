**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Log:** 905

# 07-Resultados-Testings.md — Módulo 124: Contenido Generado por Usuarios (iter. 2)

## 1. Resultado

```
=== Resumen M124: 85 checks, 0 fallos ===
TEST M124 OK — todos los checks pasaron
EXIT 0
SCRIPT ERROR: 0
```
Corridas: **×3** (`85/0`, `EXIT 0`, `SCRIPT ERROR: 0` en las tres).
Regresión iter. 1 (`test_ugc_m124.gd`): **16/0 ×2**, `EXIT 0`, `SCRIPT ERROR: 0`.

**Total M124: 101 checks, 0 fallos.**

## 2. Conteo por bloque (medido, no estimado)

| Bloque | Foco | Checks | Fallos |
|--------|------|--------|--------|
| A | catálogo y límites data-driven | 12 | 0 |
| B | `UgcLimits` por ítem | 12 | 0 |
| C | `UgcLimits` por cuota | 12 | 0 |
| D | `UgcSanitizer` (4K→2K, sobre, ZSTD) | 21 | 0 |
| E | `UgcTelemetry` sin PII | 18 | 0 |
| F | regresión iter. 1 | 4 | 0 |
| M | marcadores `_fin()` de los 6 bloques | 6 | 0 |
| | **Total** | **85** | **0** |

## 3. Bugs y hallazgos reales

### 3.1 `PackedByteArray.compress()` + `.decompress()` no cierran el ciclo (motor)
Medido con sonda sobre 33 B de JSON:

| Llamada | Resultado |
|---------|-----------|
| `compress(ZSTD)` → 42 B, luego `decompress(true)` | **1 B** (no descomprime) |
| `compress(DEFLATE)` → 41 B, luego `decompress(false, 33)` | **0 B** |
| `compress()` → 35 B, luego `decompress(true)` | **1 B** |

El motor tira `func_PackedByteArray_decompress (core/variant/variant_call.cpp:818)`.
El fallo se manifestaba como `Unicode parsing error ... Invalid UTF-8 leading byte (b5)`
(0xB5 es parte de la magic de ZSTD: la "descompresión" devolvía la entrada cruda).
Además **`decompress()` exige el primer argumento** (`dynamic_size`): sin él es un
**Parse Error**, no un default.

**Decisión:** la compresión del módulo va por
`FileAccess.open_compressed(ruta, WRITE/READ, COMPRESSION_ZSTD)` — roundtrip verificado
(CP D-18/D-19). Si en el futuro se arregla la API de `PackedByteArray`, se puede
volver a ella sin cambiar la interfaz pública de `UgcSanitizer`.

### 3.2 Warnings de GDScript tratados como ERRORES (entorno)
`var limpio := _limpiar(bp, ...)` (la función devuelve `Variant`) →
`Parse Error: The variable type is being inferred from a Variant value, so it will be
typed as Variant. (Warning treated as error.)` → `Failed to compile depended scripts`
→ el script dependiente **no carga** y el bloque de test que lo usa **aborta en silencio**.

Corregido en `ugc_sanitizer.gd`, `ugc_limits.gd` y `ugc_telemetry.gd`:
anotación explícita (`var limpio: Variant = ...`) y casts (`x as Dictionary`).
**Regla operativa:** nada de `:=` sobre valores que vienen de `Variant`; nada de
acceder a métodos de un `Node` sin tipo (usar `call()`).

### 3.3 Un aborto silencioso CUELGA el proceso (no solo da falso verde)
Con `extends SceneTree` + `call_deferred("_run")`, si algo aborta dentro de `_run()`,
**nunca se llega a `quit()`** y el `SceneTree` sigue corriendo para siempre. Al matar
el proceso se pierde además el stdout (buffering), así que el síntoma visible es
"la corrida no devuelve nada", no un error.

**Mitigación implementada** en `test_ugc_m124_iter2.gd`: **watchdog en `_process`** que
cierra con código 1 tras `FRAMES_MAX` (300) frames si `_run()` no terminó, imprimiendo
un `!! WATCHDOG: ...`. Es la segunda red, además de los marcadores `_fin()`.

### 3.4 Bug propio del test (cazado por el propio suite)
CP D-18 falló en la primera corrida (roundtrip de compresión) → el fallo era de la
**API del motor** (§3.1), no del test. Se cambió la implementación, no la aserción.

## 4. Cifras verificadas de la documentación previa

| Dato del checklist/docs | Real | Acción |
|---|---|---|
| `data/legal/ugc/ugc_catalog.json` | `data/ugc/ugc_catalog.json` | corregido en `04-Codigo.md` |
| `scripts/legal/UgcValidator.gd` | `scripts/ugc/ugc_validator.gd` | corregido |
| "106 ítems resueltos, 0 pendientes" | **41 `[ ]` reales** de 106 | marcados honestamente |
| Fila `CHECKLIST-GLOBAL` = `10/106` | el checklist tenía **65 `[x]`** | desincronización fila↔checklist (se corrige a 81/106) |
| `04-Codigo.md` = rutas Unity/C# | **no existen** en el repo | reescrito con los archivos Godot reales |

## 5. Casos NO cubiertos
Ver `06-Plan-Testings.md` §5. Resumen: backend de servicio, CDN/bucket, moderación con
IA, cola humana, apelaciones, UI de galería/perfil, cableado con M56/M18/M100, región de
datos (M80), derecho al olvido operativo, ToS/DMCA, rate limit (M106) y re-codificación
real de imágenes (no hay codificador JPEG/WebP en GDScript puro).

## 6. Conclusión
La **parte verificable headless** del módulo queda implementada y testeada: límites
RF13 (por ítem y por cuota, con mensajes claros), sanitización del UGC (4K→2K, sobre sin
coords del save, compresión ZSTD) y telemetría sin PII con gancho a M104.
Los 25 ítems restantes son **servicio / infra / UI / legal / proceso** y quedan `[?]`
con dueño externo.

**Pendiente:** QA cruzado §21.8 por otro agente (verificador ≠ autor).

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-15
