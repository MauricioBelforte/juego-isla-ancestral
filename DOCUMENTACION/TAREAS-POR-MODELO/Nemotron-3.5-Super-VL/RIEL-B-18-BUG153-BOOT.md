# RIEL-B-18 — Boot pre-check 10 módulos BUG-153 (ACTUALIZADO con lote 2/2)

**Creado por:** Nemotron-3.5-Super-VL (agente / Kilo Code) | **Fecha:** 2026-11-01
**Origen:** agnes-3-flash #223 — B-18 Boot pre-check 10 módulos BUG-153 top por densidad FG
**Método:** godot_run_project headless + get_debug_output: MXX carga + 0 SCRIPT_ERROR → SOSTENIDO/ROJO

| Sub-ítem | Módulo | Resultado | Evidencia (L# del log de boot) |
|----------|--------|-----------|-------------------------------|
| B-18-01 | M34 Pesca | [x] SOSTENIDO | `[M34] Catálogo: 25 peces, 4 cebos, 3 cañas` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-02 | M156 Terrenos | [x] SOSTENIDO | `[M156] Terrenos cargados: 7` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-03 | M27 Islas | [?] NO_VERIFICABLE | NO en boot log tras 2 verificaciones (no verificable en este boot) |
| B-18-04 | M162 Dialogos | [?] NO_VERIFICABLE | NO en boot log tras 2 verificaciones (no verificable en este boot) |
| B-18-05 | M106 Seguridad | [x] SOSTENIDO | `[M106] SecurityManager listo (4 políticas)` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-06 | M117 | [x] SOSTENIDO | `[M117] BuildConfigManager listo (4 targets, 4 presets)` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-07 | M160 | [x] SOSTENIDO | `[M160] conexiones bidireccionales reflejadas: 10` / `catálogo JSON: 39 cargadas, 0 omitidas (.tres), 0 errores` / `Ubicaciones cargadas: 48` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-08 | M82 | [?] NO_VERIFICABLE | NO en boot log tras 2 verificaciones (no verificable en este boot) |
| B-18-09 | M69 | [x] SOSTENIDO | `[M69] FastTravelService listo (4 anclas, 4 desbloqueadas)` / `FastTravelService montado (anclas + provider fast_travel)` — boot EXIT 0, 0 SCRIPT_ERROR |
| B-18-10 | M50 | [x] SOSTENIDO | `[M50] VegetationSpawner: poblando isla...`, `[M50] Plan generado: 109 items`, `[M50] TerrainLocator: found`, `[M50] VegetationSpawner: 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)` — boot EXIT 0, 0 SCRIPT_ERROR |

## Veredicto final B-18: 7 SOSTENIDO, 3 NO en boot log

Boot headless EXIT 0, 0 SCRIPT_ERROR en todos los casos. Los 3 módulos no verificables (M27, M162, M82) no tienen registro de carga en este boot — pueden cargar bajo demanda o no tener log de boot. No es ROJO, es NO_VERIFICABLE.

**7 de 10 módulos verificados SOSTENIDO.** Los 3 restantes (M27 Islas, M162 Dialogos, M82) quedan [ ] pendientes de verificación en un boot donde aparezcan sus logs.

Firma: Nemotron-3.5-Super-VL (Kilo Code) — 2026-11-01 04:05:00.
