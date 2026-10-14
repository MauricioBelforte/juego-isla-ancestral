# 07-Resultados-Testings.md — Módulo 108: Pipeline de Assets

**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14
**Entorno:** Godot 4.7.2.stable oficial, Windows 10, headless (`C:\Temp\godot\godot472.exe`)

## 1. Resultados (todos ejecutados 2026-10-14, hora local 18:05-18:15 UTC-3)

| # | Test | Resultado | Evidencia |
|---|---|---|---|
| U-1 | Memory reporter vs caso conocido (`run_m108_memory_test.gd`) | **PASS** | 4 fixtures de tamaño exacto (png 1 MiB, glb 2 MiB, ogg 0.5 MiB, png vacío): RAM 1.00/2.00/0.50/0.00 MB y VRAM 0.80/3.00/0.00/0.00 MB verificados uno a uno; totales **RAM 3.50 MB / VRAM 3.80 MB** exactos; path de error "TAMAÑO: archivo vacío 'm108_test_d.png'" verificado; `assets/final/` quedó vacío (self-contained) |
| U-2/I-1 | Test headless M108 (`scenes/tests/test_m108.tscn`) | **PASS — 0 fallos, exit code 0** | `=== TEST M108: 5 checks, 0 fallos ===` · `Todos los checks pasaban.` · `Exit code: 0` (verificado empíricamente: `HasExited: True`, `ExitCode test_m108: 0`); staging vacío → "Pipeline validado: 0 errores, 0 aprobados"; reporte en `tools/reportes/_validacion_staging.md` |
| U-3 | Validador auditoría total (`tools/asset_validator.gd`) | **PASS CI — 0 errores, exit 0** | `=== Resultado: 418 assets, 198 OK, 0 error(es), 220 aviso(s) ===` en `tools/reportes/asset_validation.txt`; exit 0 por código (`asset_validator.gd:66`: `quit(1 if errores > 0 else 0)` con 0 errores) |
| I-2 | Escena preview (`scenes/asset_preview.tscn`) | **PASS** | `[M108] asset_preview: escena lista — caja de referencia de 1 m + cámara orbitante`; `--auto-quit` → shutdown limpio (sesión_fin, NPCs desregistrados); sin script errors |

## 2. Reparaciones de código asociadas (M108, 2026-10-14)

1. **`run_m108_test.gd`** (L360): migrado de API `Dictionary` obsoleta a `ResultadoPipeline` real (`validar_pipeline` retorna la clase tipada). Causa raíz del revertido previo (BUG-070): el `_ready` crasheaba en la asignación `var resultado: Dictionary = ...` y el test colgaba en headless sin output.
2. **`asset_validator_logic.gd` → `escribir_reporte`**: el reporte de validación de staging se escribía **dentro de staging** (`assets/staging/_reporte_validacion.md`), que el propio recorrido validaba → 3 errores en la segunda corrida (no idempotente). Ahora escribe en `tools/reportes/_validacion_staging.md`. El fósil `assets/staging/_reporte_validacion.md` (fecha 2026-09-02, 3 errores) fue retirado.
3. **Regularización de fichas**: 95 fichas nuevas en `assets/fichas/` (161 totales) para los 220 GLB que entraron fuera del pipeline (M16/M18/M19/M25/M27/M33/M35/M36/M40/M45/M50). Estado honesto `PENDIENTE-REVIEW`: no se reclama aprobación visual E-13 sin ejecutarla.
4. **Nuevos artefactos**: `scenes/asset_preview.tscn` + `scripts/assets/asset_preview.gd` (L164); `tools/asset_pipeline/run_m108_memory_test.gd` (U-1).

## 3. Deuda pendiente honesta (no cerrada)

- **220 avisos** en el validador: fichas regularizadas con `PENDIENTE-REVIEW` → aprobación visual E-13 pendiente con el dueño de cada módulo productor. El CI está verde (0 errores) pero la revisión visual de la tanda ampliada no se ejecutó (no es tarea de M108).
- **RF5 (presets por tipo)**, **RF9 (LOD/shadow meshes)**, **RF1 (flujo staging con assets reales)**: bloqueados por dueños de otros módulos (ver 05-Checklist.md, ítems `[?]` y `[ ]` con "espera: depende de...").

## 4. Conclusión

El pipeline de assets (M108) está **operativo y verde en headless**: validador CI 0 errores sobre los 418 assets del árbol, test de staging 0 fallos exit 0, memory reporter verificado contra caso conocido, y escena de preview funcional. La deuda restante es de revisión visual (E-13) y de definición de presets/LOD, ambas con dueño fuera de M108.
