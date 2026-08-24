**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 113: Pruebas de Stress

## 1. Problema
El juego es un mundo voxel generado con **mucha entidad, cantidad y duración** (miles de bloques, muchos NPC/animales/vegetación/objetos, mundo grande, sesiones largas). Sin pruebas de stress automáticas y repetibles, el juego puede degradarse (FPS, memoria, tiempos de carga, corrupción de saves) justo en el lanzamiento (M143), cuando la comunidad lo juegue de verdad.

## 2. Objetivo del módulo
Diseñar y documentar el **plan de pruebas de stress**: escenarios de carga máxima (bloques, NPC, fauna, vegetación, objetos, mundo grande, inventario enorme, construcciones), resistencia a sesión larga (viajes/entradas/guardados repetidos), variedad de simulación (clima, estaciones, partículas, luces, agua, cuevas, chunks) y metas de rendimiento medibles (M61/M62) con informes comparables que alimenten la optimización y los gates de M140/M141/M142.

## 3. Alcance (derivado del plan maestro: sección 112 "PRUEBAS DE STRESS")
1. **Miles de bloques modificados** — stress de edición voxel (M08): undo, chunks, guardado.
2. **Muchos NPC** — decenas de NPC (M19): AI, rutinas, interacción.
3. **Muchos animales** — manadas (M65): pathfinding, reproducción.
4. **Mucha vegetación** — densidad vegetal (M50): culling y memoria.
5. **Muchos objetos** — items en el mundo (M14): pooling y física.
6. **Mundo muy grande** — seeds grandes (M10): generación, streaming, guardado.
7. **Inventario enorme** — miles de items (M14): UI, orden, persistencia.
8. **Muchas construcciones** — casas/estructuras (M17/18): editabilidad y molinos.
9. **Sesión de muchas horas** — 8-24 h (M135): leaks, desgaste de memoria.
10. **Viajes repetidos** — navegación entre islas (M28): streaming, cooldowns.
11. **Entradas y salidas repetidas** — casas/ruinas/cuevas (M63): carga/descarga.
12. **Guardados repetidos** — auto-save continuo (M59): integridad y velocidad.
13. **Cargas repetidas** — reload de saves (M59): corrupción y tiempos.
14. **Clima cambiante** — transiciones climáticas (M32): partículas y audio.
15. **Estaciones cambiantes** — ciclos estacionales (M31): terreno y eventos.
16. **Multitud de partículas** — niebla/lluvia/humo (M52): frame budget.
17. **Muchas luces** — iluminación densa (M49): rendimiento y horocasting.
18. **Mucha agua** — océanos y ríos (M51): reflexiones y física.
19. **Muchas cuevas** — cavernas (M08/M25): culling y colisiones.
20. **Muchos chunks activos** — frontera de chunks (M08): networking local, meshing.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | 20 escenarios de stress definidos con objetivos medibles |
| RF2 | Escenarios automatizables en CI/perf (M61/M112) |
| RF3 | Métricas comparables: FPS p50/p95, memoria, tiempos de carga, GC |
| RF4 | Escenario de "sesión larga" de 8-24 h con telemetría de leaks |
| RF5 | Escenarios de integridad de saves (guardar+cargar × N) |
| RF6 | Límites máximos de entidades definidos por plataforma (M96) |
| RF7 | Reporte automático de cada corrida (JSON + gráfica) |
| RF8 | Integración con gates: M140/M141/M142 (perf objectives) |
| RF9 | Benchmarks de referencia para comparar regresiones |
| RF10 | Priorización de fixes por impacto (crítico/alto/media/baja) |

## 5. Criterios de aceptación (DoD del módulo)
1. 20 escenarios documentados con pasos, cantidad objetivo y métrica de éxito.
2. Framework de stress testing (modo automático headless) definido y automatizable.
3. Métricas base: FPS ≥ 30 (p95) en target mínimo; memoria < umbral; carga < 30 s (M61).
4. Sesión larga de 8 h sin crecimiento de memoria > 5%.
5. Save íntegro tras 100 ciclos guardar/cargar.
6. Reportes comparables entre corridas (baseline versionado).
7. Gate de stress activo en CI (M112) para builds nocturnos.

## 6. Restricciones
- **Aplican:** M61 (rendimiento), M62 (memoria), M63 (cargas/streaming), M112 (testing automático), M96 (objetivos por plataforma), M140-M143 (gates de producción).
- Los stress tests corren en batch mode (no requieren interacción humana) y utilizan Debug Menu flag de carga máxima (M110/M109).
- No afectan el build de jugador (solo dev/QA/CI).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M112** — Testing Automático | Base para testing automático |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M112** — Testing Automático | Depende de este módulo |

