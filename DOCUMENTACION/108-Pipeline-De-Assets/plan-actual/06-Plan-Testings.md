# 06-Plan-Testings.md — Módulo 108: Pipeline de Assets

**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14

> Plan de testings del pipeline de assets. Ejecutado en `07-Resultados-Testings.md` (2026-10-14).

## 1. Testings unitarios (lógica pura, headless)

| # | Test | Qué verifica | Criterio de éxito |
|---|---|---|---|
| U-1 | `run_m108_memory_test.gd` | Estimación VRAM/RAM por extensión (png/webp x0.8 RAM, glb/gltf x1.5 VRAM, ogg/wav VRAM 0) y path de error de archivo vacío | Totales del caso conocido exactos (RAM 3.50 / VRAM 3.80 MB); 1 archivo con errores; exit 0 |
| U-2 | `asset_validator_logic.gd` vía `run_m108_test.gd` | Validación de staging: nombre, extensión, ficha, .import de texturas, WAV ≤ 5 s | staging conforme → 0 errores, exit 0 |
| U-3 | `asset_validator.gd` (auditoría total) | Recorrido completo de `assets/3d/{media,baja,alta}`: formato, nombre `{NN}-{Modulo}_{snake_case}`, tamaño ≤ 8 MB, ficha, licencia IA | 0 errores, exit 0 (avisos de ficha sin APROBADO no fallan CI) |

## 2. Testings de integración (escena / runtime)

| # | Test | Qué verifica | Criterio de éxito |
|---|---|---|---|
| I-1 | `scenes/tests/test_m108.tscn` | Pipeline staging extremo a extremo en escena headless | "=== TEST M108: 5 checks, 0 fallos ===", exit code 0 |
| I-2 | `scenes/asset_preview.tscn` | Carga de la escena de preview (RF9): caja de referencia 1 m + cámara orbitante + carga opcional `--asset` | Print "escena lista", sin script errors, shutdown limpio con `--auto-quit` |

## 3. Edge cases cubiertos

- **Archivo vacío (0 B)**: el memory reporter emite ERROR "TAMAÑO: archivo vacío" (U-1, fixture `m108_test_d.png`).
- **Staging vacío**: validación 0 errores / 0 aprobados (I-1).
- **Ficha sin estado APROBADO**: el validador emite AVISO (no error) — no rompe CI (U-3).
- **Asset > 8 MB**: aviso de tamaño (U-3, regla `TAMANO_AVISO_MB`).
- **Idempotencia**: los tests no dejan rastro (`assets/final/` y `assets/staging/` vacíos tras la corrida; el reporte del validador de staging va a `tools/reportes/`, no a staging).
- **Nombre no ASCII / espacios / > 64 chars**: rechazados por el validador (reglas de nombre, U-3).

## 4. Pendientes (no cerrables por M108 solo)

- **Presets de importación (RF5)**: dueño M45/M47 — entrarán cuando texturas/audio entren en producción.
- **LOD / shadow meshes en glb de referencia (RF9)**: dueño M45 — requiere glb con LODs reales.
- **Revisión visual E-13 de la tanda regularizada (2026-10-14)**: dueños de módulos M16/M18/M19/M25/M27/M33/M35/M36/M40/M45/M50 — 220 avisos pendientes de aprobación.
- **Flujo `assets/staging/` → aprobación con assets reales (RF1)**: primera tanda M45.

## 5. Comandos de ejecución

```
godot --headless --path game/isla-ancestral -s res://tools/asset_pipeline/run_m108_memory_test.gd
godot --headless --path game/isla-ancestral scenes/tests/test_m108.tscn
godot --headless --path game/isla-ancestral -s res://tools/asset_validator.gd
godot --headless --path game/isla-ancestral scenes/asset_preview.tscn --auto-quit
```
