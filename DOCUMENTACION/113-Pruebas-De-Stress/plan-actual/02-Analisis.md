**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 113: Pruebas de Stress

## 1. Análisis del dominio
El contenido del juego es data-driven (SO/MODs: M108) y el mundo es generado proceduralmente (M10). Los datos viven en ScriptableObjects/MODs y el editor importa/exporta. El toolset debe: 1) editar datos con validación, 2) depurar en runtime, 3) medir performance, 4) generar contenido reproducible.

## 2. Alternativas consideradas y decisiones

### D1: Automatización de stress
- **A1 (tests manuales de QA)**: lento, no repetible, no cuantificable en equipo grande.
- **A2 (framework headless automatizado en batch mode)**: reproducible, versionable, con baseline y CI; QA solo pule y tria excedentes.
- **Decisión:** **A2** — stress framework headless (ej. `StressRunner` con escenarios parametrizados) + nightly CI (M112) + reporte JSON/graph. QA ejecuta variantes manuales focalizadas (input real, sesiones largas con usuario).

### D2: Métricas y baseline
- **A1 (métricas sueltas sin baseline)**: sin comparación no hay regresión.
- **A2 (baseline versionada y comparación p50/p95)**: cada commit con signos de regresión se marca automáticamente.
- **Decisión:** **A2** — baseline `perf_base.json` del último build estable; comparación porcentual en FPS/memoria/carga; umbral de regresión ±5% para gate.

### D3: Límite de entidades
- **A1 (sin límite: "el mundo es todo")**: riesgo de desastre de rendimiento.
- **A2 (límites por plataforma documentados)**: máximo recomendado por entidad/plataforma (M96) con advertencia en editor (M109) y amplitud de diseño.
- **Decisión:** **A2** — tabla de límites por categoría (NPC, fauna, objetos, vegetación, luces) y por plataforma; los escenarios de stress usan esos máximos ×1.5 para margen.

### D4: Sesión larga
- **A1 (sesión de 8 h una vez al mes)**: poco frecuente.
- **A2 (sesión larga automatizada nightly de 8 h)**: detecta leaks de memoria y degradación gradual en cada nightly.
- **Decisión:** **A2** — nightly de 8 h (sin UI, mundo denso, teleport cíclico); alerta si memoria crece > 5% o FPS decae > 10%.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Riesgo de P2 en lanzamiento (crash por límite) | Alta | Alta | Stress nightlies + gates M140-143 |
| Semanas de trabajo perdiendo perf | Alta | Media | Baseline y comparación automática por PR |
| Falsos positivos del baseline (hardware distinto) | Media | Media | Runner en hardware fijo (CI dedicado con label) |
| Carga sintética diferente a la real | Media | Media | Telemetría real (M105) retro-alimenta los escenarios |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Framework** | StressRunner headless, métricas, baseline, reporte |
| **F2 Escenarios A** | Bloques, NPC, fauna, vegetación, objetos, mundo grande |
| **F3 Escenarios B** | Inventario, construcciones, sesión larga, viajes, entradas/salidas |
| **F4 Persistencia** | Guardados/cargas repetidos, integridad |
| **F5 Simulación** | Clima, estaciones, partículas, luces, agua, cuevas, chunks |

## 5. Métricas de éxito
1. 20 escenarios corren en < 4 h total (nightly).
2. Regresión detectada en < 24 h desde el commit que la causó.
3. 0 crashes en los 20 escenarios con límites ×1.5 en el RC (M142).
4. Memoria de sesión larga estable (±5%) en 8 h.
5. Save íntegro tras 100 ciclos guardar/cargar (sin corrupción).
6. Reporte JSON con p50/p95 por métrica en cada corrida.
7. Gate de stress verde en noche previa a M141 (Beta) y M142 (RC).

## 6. Notas para integración
- El StressRunner usa el Debug Menu (M110) para spawnear/teleportar sin UI.
- Los reportes alimentan M61 (optimizaciones) y M62 (memoria) con datos reales.
- Los límites por plataforma retroalimentan M96 (matriz de plataformas).