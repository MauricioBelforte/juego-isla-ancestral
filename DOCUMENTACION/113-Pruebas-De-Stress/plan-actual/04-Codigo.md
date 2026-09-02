**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (implementación iter. 1 núcleo; diseño original Unity/C# por Deepseek V4 Flash / OpenCode 2026-08-20)

# 04-Codigo.md — Módulo 113: Pruebas de Stress

## 1. Archivos involucrados (REAL — Godot 4.7 / GDScript)

### 1.1 Nuevos (`game/isla-ancestral/scripts/stress/`)
| Archivo | Propósito |
|---------|-----------|
| `stress_runner.gd` | Orquestador headless (batch mode) — SceneTree, registra escenarios, ejecuta setup→execute→teardown, consolida métricas, genera reporte JSON |
| `stress_scenario.gd` | Clase base `StressScenario`: `setup()/execute()/teardown()`, `_registrar_metrica()`, `_medir_ms()`, `_resumen_metrica()` con p50/p95/max |
| `escenarios/block_edit_stress.gd` | Edición simulada de 100k bloques (PRNG determinista, 3125 chunks, mide ops/s) |
| `escenarios/save_load_stress.gd` | 100 ciclos guardar/cargar vía DataStore M60 (p50 guardar_ms, cargar_ms, integridad 100%) |
| `test_stress_m113.gd` | Test headless: base StressScenario (p50/p95), BlockEdit (100k ops), SaveLoad (100 ciclos) |

### 1.2 Diferencias vs diseño original (Unity/C#)
- El diseño original (04-Codigo.md previo) proponía C# con `StressRunner.cs`, `StressScenario.cs`, `StressReport.cs` y 19 escenarios `.cs` en asmdef `IslaAncestral.Stress`. Se adaptó a Godot 4.7/GDScript con preloads (pitfall §9.50/§9.52).
- `StressReport` se integró dentro del runner como salida JSON directa (sin clase separada).
- 2 escenarios implementados (SaveLoadStress, BlockEditStress); los otros 17 escenarios quedan documentados con su diseño original para implementación futura con los módulos reales (M08/M19/M50/M65/M14/M17/M28/M32/M31/M52/M49/M51/M25).
- El reporte se escribe en `user://stress_report.json` (no en artifact de CI aún).

## 2. Funciones clave

### 2.1 `stress_scenario.gd` — StressScenario (base)
```gdscript
class_name StressScenario extends RefCounted
func nombre() -> String
func setup() -> void
func execute() -> Dictionary
func teardown() -> void
func _registrar_metrica(nombre: String, valor: float) -> void
func _medir_ms(callable: Callable) -> Dictionary  # {ms, resultado}
func _resumen_metrica(muestras: Array) -> Dictionary  # {p50, p95, max, count}
func resumen_metricas() -> Dictionary  # consolidado de todas las métricas
```

### 2.2 `stress_runner.gd` — StressRunner (SceneTree)
```gdscript
extends SceneTree
# CLI: Godot --headless --path game/isla-ancestral --script res://scripts/stress/stress_runner.gd
# Escribe user://stress_report.json con métricas, status, memoria.
# Exit code 0 si todos los escenarios están en status "ok".
```

### 2.3 Reporte JSON (ejemplo real)
```json
{
  "generado_iso": "2026-09-01T15:15:16",
  "duracion_total_ms": 1271,
  "memoria_static_inicial_kb": 77575,
  "memoria_static_final_kb": 77679,
  "escenarios": [
    {"escenario": "SaveLoadStress", "status": "ok", "duracion_ms": 1101,
     "metricas": {"guardar_ms": {"p50": 11, "p95": 15, "max": 20, "count": 100},
                  "cargar_ms": {"p50": 1, "p95": 1, "max": 13, "count": 100},
                  "carga_ok_ms": {"p50": 1, "p95": 1, "max": 1, "count": 100}}},
    {"escenario": "BlockEditStress", "status": "ok", "duracion_ms": 170,
     "metricas": {"operaciones_ok": {"p50": 50500, "p95": 95050, "max": 100000, "count": 100},
                  "ops_s": {"p50": 595165, "p95": 666667, "max": 1000000, "count": 100}}}
  ]
}
```

## 3. Verificación
- Test M113: `Godot --headless --path game/isla-ancestral --script res://scripts/stress/test_stress_m113.gd` → **19 checks, 0 fallos**.
- Runner batch: `--script res://scripts/stress/stress_runner.gd` → **2 escenarios OK, reporte JSON generado**.
- Regresión M60: **66/0 OK** (SaveLoadStress usa DataStore M60 como prueba de integración real).

## 4. Pendientes honestos (111 ítems de checklist)
- Baseline versionado `perf_base.json` + comparación automática ±5%.
- Hardware fijo / label CI, gates `stress-save`/`stress-full` en pipeline.
- 17 escenarios restantes (NPC, fauna, vegetación, objetos, mundo grande, inventario, construcciones, sesión larga, viajes, entradas/salidas, clima, estaciones, partículas, luces, agua, cuevas, chunks) — requieren módulos reales (M08/M19/M50/M65/M14/M17/M28 etc.).
- Integración con Debug Menu (M110) para spawn/teleport.
- Progreso visual durante stress (AGENTS.md §8).

## Notas del Agente

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 liberado

### Lo que hice
- Framework de stress completo: StressRunner (SceneTree, batch mode), StressScenario base (Setup/Execute/Teardown + métricas p50/p95/max), reporte JSON con duración, memoria y status por escenario.
- 2 escenarios demostrativos: SaveLoadStress (100 ciclos guardar/cargar vía M60 DataStore, verifica integridad ciclo a ciclo) y BlockEditStress (100k operaciones simuladas con PRNG determinista, 3125 chunks, ~595k ops/s).
- Test headless 19/0 OK + runner batch verificado + regresión M60 66/0 OK.

### Lo que NO pude hacer (honestidad obligatoria)
- [M] Los 17 escenarios restantes dependen de módulos no implementados aún (M08/M19/M50/M65/M14/M17/M28/M32/M31/M52/M49/M51/M25). Quedan documentados en el diseño original (04-Codigo.md previo).
- [M] Baseline comparativo y gates CI: requieren M112 (testing automático, GdUnit4) y pipeline CI definido.
- [M] Debug Menu hook (M110) para spawn/teleport desde stress.

### Recomendaciones para el próximo agente
- Para implementar BlockEditStress real: conectar a M08 (VoxelTool) y sustituir la simulación de dict por ediciones reales en chunks con medición de FPS (Performance singleton).
- Para implementar NPCStress/FaunaStress: esperar M19/M64 (NPC) y M65 (fauna) con su AI y pathfinding.
- Para CI gates: el runner ya produce JSON estructurado; solo falta un script que compare contra baseline y decida el gate.
## 4. Iteración 2 (2026-09-01 22:47, deepseek-v4-flash-vision-exp / Kilo Code)

- **Escenarios nuevos** (mismos patrones, módulos REALES):
  - escenarios/inventory_stress.gd — InventoryStress: 100.000 add + 100.000 remove + 10.000 swap (PRNG seed 42) sobre /root/Inventario (M14). Resultado: dd_ms p50=1974, remove_ms p50=277, swap_ms p50=29, integridad_ok=1.0 → **~91k ops/s, 0 corrupción**.
  - escenarios/equipment_stress.gd — EquipmentStress: 500 ciclos de equipar las 16 prendas + desequipar (M155). Resultado: equip_ms p50=160, unequip_ms p50=2, integridad_ok=1.0 (slots vacíos al cierre).
- **stress_runner.gd**: 2 escenarios más registrados → **4 escenarios, status ok, exit 0** (duración total 4.323 ms)
- Reporte: user://stress_report.json (2286 bytes, 4 escenarios, 2286 B) + smoke visual del mundo: FPS 60, sin regresiones (captura 167).
