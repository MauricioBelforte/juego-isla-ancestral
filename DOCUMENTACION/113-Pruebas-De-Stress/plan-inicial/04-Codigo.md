**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 113: Pruebas de Stress

## 1. Archivos involucrados

### 1.1 Nuevos (`Assets/_Project/Scripts/Testing/` — asmdef IslaAncestral.Stress)
| Archivo | Propósito |
|---------|-----------|
| `scripts/stress/stress_runner.gd` | Orquestador headless (batch mode) |
| `scripts/stress/stress_scenario.gd` | Clase base: Setup/Execute/Teardown |
| `Core/StressReport.cs` _(diseno heredado)_ | Métricas p50/p95, memoria, tiempos, status |
| `Escenarios/BlockStress.cs` _(diseno heredado)_ | Miles de bloques modificados |
| `Escenarios/NpcStress.cs` _(diseno heredado)_ | Muchos NPC |
| `Escenarios/FaunaStress.cs` _(diseno heredado)_ | Muchos animales |
| `Escenarios/VegetationStress.cs` _(diseno heredado)_ | Mucha vegetación |
| `Escenarios/ObjectStress.cs` _(diseno heredado)_ | Muchos objetos |
| `Escenarios/WorldStress.cs` _(diseno heredado)_ | Mundo muy grande |
| `scripts/stress/escenarios/inventory_stress.gd` | Inventario enorme |
| `Escenarios/BuildingStress.cs` _(diseno heredado)_ | Muchas construcciones |
| `Escenarios/LongSessionStress.cs` _(diseno heredado)_ | Sesión de muchas horas |
| `Escenarios/TravelStress.cs` _(diseno heredado)_ | Viajes repetidos |
| `Escenarios/DoorStress.cs` _(diseno heredado)_ | Entradas y salidas repetidas |
| `scripts/stress/escenarios/save_load_stress.gd` | Guardados y cargas repetidos |
| `Escenarios/WeatherStress.cs` _(diseno heredado)_ | Clima cambiante |
| `Escenarios/SeasonStress.cs` _(diseno heredado)_ | Estaciones cambiantes |
| `Escenarios/ParticleStress.cs` _(diseno heredado)_ | Multitud de partículas |
| `Escenarios/LightStress.cs` _(diseno heredado)_ | Muchas luces |
| `Escenarios/WaterStress.cs` _(diseno heredado)_ | Mucha agua |
| `Escenarios/CaveStress.cs` _(diseno heredado)_ | Muchas cuevas |
| `Escenarios/ChunkStress.cs` _(diseno heredado)_ | Muchos chunks activos |
| `CI/stress_report.json` | Salida de cada corrida (artifact) |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `Assets/_Project/Scripts/DebugMenu` (M110) | Exponer API para spawn/teleport desde stress |
| CI pipeline (M112) | Pipelines `stress-full`, `stress-save`, `stress-long`, `stress-gate` |
| `PerfGate` (M61) | Consumir `stress_report.json` para gates |

## 2. Funciones clave
```csharp
// StressRunner
public void RunAll(string seed);                     // batch: los 20 escenarios
public void RunEscenario(string name);               // uno solo
public StressReport CompararConBaseline();           // contra perf_base.json

// StressScenario (base)
public abstract class StressScenario {
    public abstract string Nombre { get; }
    public virtual void Setup();                     // mundo/listas de prueba
    public abstract void Execute(float duracion);    // spawn/acciones/mediciones
    public virtual void Teardown();                  // reset del mundo
    public void RegistrarMetrica(float valor);       // p50/p95/max
}

// StressReport
public string ToJson();                              // salida artefacto CI
public bool SuperaBaseline(float tolerancia);        // ±5%
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Límites por entidad/plataforma | `perf_limits.json` (repo) | M96/M61 |
| Baseline | `perf_base.json` (versionado) | Comparación |
| Seeds de escenarios | Config del runner (seed fija por escenario) | M10 |
| Umbrales de gate | Config de CI (yaml) | M112 |

## 4. Tests (M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `StressUnitTests` | EditMode | Cálculo de p50/p95/reporte |
| `SaveLoadIntegrityTests` | PlayMode | 100 ciclos sin corrupción |
| `BlockEditStressTests` | PlayMode | Edición 100k bloques, memoria estable |
| `NpcAiStressTests` | PlayMode | 60 NPC, frame AI < umbral |
| `BaselineCompareTests` | EditMode | Comparación ±5% correcta |

## 5. CI / gates
| Pipeline | Frecuencia | Comando |
|----------|-----------|---------|
| `stress-save` | Por PR | `StressRunner RunEscenario=SaveLoadStress ciclos=10` |
| `stress-full` | Nocturno | `StressRunner RunAll seed=fija` |
| `stress-long` | Semanal | `StressRunner RunEscenario=LongSessionStress horas=8` |
| `stress-gate` | Pre-RC/Beta | `stress-full + CompararConBaseline` |
- Falla el PR si `stress-save` no pasa; los reportes van a artifact del pipeline.

## 6. Notas de integración
- Los consumidores son M61 (perf gate) y M62 (memoria); los hallazgos nutren M102.
- Depuración con Debug Menu (M110) y profiling (M61).
- M96 entrega los límites máximos por plataforma (usados en ×1.5).