# 01 — Requerimientos — M65: Animales IA

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

La isla ancestral necesita fauna viva que habite cada bioma (sección 35 del plan maestro) sin degradar el rendimiento. Cada animal debe tener comportamientos creíbles según su especie (herbívoro, acuático, aéreo, nocturno, migratorio, estacional), con ciclos de descanso, alimentación, reproducción y respuesta al entorno y al jugador — todo bajo el **núcleo cozy**: huida no violenta, cero agresión, muerte jamás visible.

## Objetivos

- Simular los 19 puntos de la sección 64 del plan maestro (comportamientos, ciclo vital, spawns/despawns, optimización, terreno modificado).
- Fauna como sistema vivo de "segundo plano": ambientación + registro (M36) sin mecánicas de daño.
- Población regulada y presupuesto de rendimiento estricto (M61).
- Integrar con el sistema IA de M64 (navegación, burbuja de simulación, anti-atascos).

## Alcance

- Especies por bioma con perfiles: herbívoros (ciervos, cabras), aves (pájaros, búhos), fauna acuática (peces, cangrejos), fauna de refugio.
- Comportamientos: herbívoro, acuático, aéreo, nocturno, migratorio, estacional, reproducción, descanso, alimentación, huida no violenta, curiosidad, interacción con entorno.
- Spawns/despawns por región con validación de terreno, población limitada, rehidratación de estado.
- Optimización: comparte sistema de simulación parcial (burbuja 64 m, tick 1 s) y pooling con M64.

## Fuera de alcance

- Daño al jugador, animales agresivos o caza con loot (prohibido por vision cozy).
- Economía asociada a animales vivos (M37) o monturas (M66 Vehículos).
- Peces de pesca, fósiles y museo (M36 se integra, no se documenta aquí).
- Domesticación o inventario de mascotas (anotado como futuro).

## Restricciones

- **Nada de muerte visible:** al bajar la salud de hambre, el animal "emigra" (despawn suave), jamás se ve un cadáver.
- **Sin explotación:** prohibido criar/recolectar crías, molestar nidos o tráfico animal para lucro (alineado con "Evitar explotación" y "Conservación" de la sección 35).
- **Presupuesto:** los animales activos comparten el frame budget de IA de M61 (FSM ≤ 8 ms + pathfinding ≤ 6 ms total entre NPC y fauna). No se excede el límite; si sobra menos de 1 ms, se reduce la burbuja de fauna antes que la de NPC.
- **Reuso obligatorio:** no se duplica el sistema de M64; la fauna es una "capa" del mismo orquestador (`NPCManager` → `FaunaManager`).
- Documentación completa en `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo vigente).

## Criterios de éxito

1. Cada bioma muestra su fauna esperada con densidades dentro del presupuesto.
2. Los 19 puntos de la sección 64 cumplidos, verificables con pruebas automatizadas (06-Plan-Testings).
3. Población estable: nunca crece sin tope ni colapsa por un solo despawn.
4. Sin errores en Consola ni bloqueos al entrar en Play Mode.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M036** — Fauna | IA de animales |
| **M064** — IA de NPC | Patrones de IA reutilizados |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M036** — Fauna | Depende de este módulo |
| **M064** — IA de NPC | Depende de este módulo |

