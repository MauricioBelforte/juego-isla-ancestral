**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 113: Pruebas de Stress

## 1. Arquitectura del framework de stress
```
Assets/_Project/Scripts/Testing/ (asmdef: IslaAncestral.Stress)
├── Core/
│   ├── StressRunner.cs         ← orquestador headless de escenarios
│   ├── StressScenario.cs       ← base de escenario (Setup/Execute/Teardown)
│   └── StressReport.cs         ← métricas p50/p95, memoria, tiempos
├── Escenarios/
│   ├── BlockStress.cs          ← miles de bloques modificados
│   ├── NpcStress.cs            ← muchos NPC
│   ├── FaunaStress.cs          ← muchos animales
│   ├── VegetationStress.cs     ← mucha vegetación
│   ├── ObjectStress.cs         ← muchos objetos
│   ├── WorldStress.cs          ← mundo muy grande
│   ├── InventoryStress.cs      ← inventario enorme
│   ├── BuildingStress.cs       ← muchas construcciones
│   ├── LongSessionStress.cs    ← sesión de muchas horas
│   ├── TravelStress.cs         ← viajes repetidos
│   ├── DoorStress.cs           ← entradas/salidas repetidas
│   ├── SaveLoadStress.cs       ← guardados/cargas repetidos
│   ├── WeatherStress.cs        ← clima cambiante
│   ├── SeasonStress.cs         ← estaciones cambiantes
│   ├── ParticleStress.cs       ← multitud de partículas
│   ├── LightStress.cs          ← muchas luces
│   ├── WaterStress.cs          ← mucha agua
│   ├── CaveStress.cs           ← muchas cuevas
│   └── ChunkStress.cs          ← muchos chunks activos
└── CI/
    └── stress_report.json      ← salida de cada corrida
```

## 2. Escenarios y métricas objetivo
| Escenario | Cantidad objetivo (×1.5 límite) | Métrica/Success |
|-----------|-------------------------------|-----------------|
| BloqueStress | 100 000 bloqueos modificados | FPS ≥ 30 p95; edit 60/s |
| NpcStress | 60 NPC activos | AI frame < 4 ms; pathfinding ok |
| FaunaStress | 200 animales | Física frame < 5 ms |
| VegetationStress | 50 000 instancias vegetales | Culling ok; memoria < umbral |
| ObjectStress | 10 000 objetos | Pooling sin GC spikes |
| WorldStress | Seed máxima de M10 | Streaming < 30 s; memoria < 4 GB |
| InventoryStress | 5 000 items | UI < 16 ms en abrir/ordenar |
| BuildingStress | 500 estructuras (M17) | Edición y guardado estable |
| LongSessionStress | 8-24 h continua | Memoria ±5%; FPS > 30 |
| TravelStress | 500 viajes entre islas | Transición < 5 s cada una |
| DoorStress | 1 000 entradas/salidas | Carga/descarga sin leak |
| SaveLoadStress | 100 ciclos guardar/cargar | 0 corrupción; < 30 s carga |
| WeatherStress | 200 transiciones | Frame < 16 ms con FX |
| SeasonStress | 100 ciclos estacionales | Terreno/eventos correctos |
| ParticleStress | 5 000 partículas activas | Frame < 8 ms adicional |
| LightStress | 300 luces dinámicas | Batching ok; < 20 ms |
| WaterStress | Mar completo + ríos | Reflexiones < 12 ms |
| CaveStress | 50 cuevas simuladas | Culling + colisiones ok |
| ChunkStress | 49 chunks activos | Meshing < 16 ms; memoria ok |

## 3. StressRunner — ciclo
```
Setup(seed)          → genera mundo de prueba (M10)
Por cada escenario:  → Setup → Execute(T=duracion) → Registrar métricas → Teardown
Reporte final       → JSON {escenario, p50, p95, max, memoria, tiempo, status}
```
- Headless via `Application.isBatchMode`.
- Usa el Debug Menu (M110) para spawn/teleport automático.
- Descarga el mundo entre escenarios (reset).

## 4. Baseline y comparación
| Archivo | Contenido |
|---------|-----------|
| `perf_base.json` | Métricas del último build estable (versionado en repo) |
| `stress_report.json` | Salida de la última corrida |
- Comparación automática (±5% FPS/memoria/carga) → status por escenario.
- Gate en CI: falla si cualquier escenario regresa > 5% o excede mínimo.

## 5. CI (M112) — nightlies
| Pipeline | Frecuencia | Alcance |
|----------|-----------|---------|
| `stress-full` | Nocturno | 20 escenarios (~4 h) en hardware fijo |
| `stress-save` | Por PR (rápido) | SaveLoadStress 10 ciclos + ChunkStress |
| `stress-long` | Semanal | LongSessionStress 8-24 h |
| `stress-gate` | Pre-M141/M142/M143 | 20 escenarios + baseline dentro de umbrales |

## 6. Reportes
- JSON técnico + dif con baseline.
- Gráfico (opcional, en CI artifact) con FPS p50/p95 por escenario.
- Integración con M61 (consumidor) y M102 (bugs de perf).

## 7. Prohibiciones técnicas
1. El framework de stress no se incluye en el build de jugador (asmdef Testing excluida).
2. Los escenarios usan seeds fijas de M10 (reproducibilidad).
3. No se permite activar escenarios desde el build final (solo dev/QA/CI).