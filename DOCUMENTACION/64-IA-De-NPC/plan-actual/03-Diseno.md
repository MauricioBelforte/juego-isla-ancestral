**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 64: IA de NPC

## 1. Arquitectura

```
                NPCDirector.gd (autoload, única autoridad de agentes)
   ┌──────────────┬───────────────┬──────────────┬──────────────┐
   ▼              ▼               ▼              ▼              ▼
FSM núcleo    Agenda/Rutinas  Interruptores Nav/mesh      Simulación
(transiciones) (perfiles .tres) (señales M29/  (Navigation   parcial
                              M31/M32/M17)   Server3D)     (burbuja)
   │              │               │              │              │
   └──────────────┴───────┬───────┴──────────────┴──────────────┘
                          ▼
              Presupuesto: ≤ 60 plena · resto receta (tick 1 s)
                          ▼
              Logs DOM-IA (stuck, fallbacks) — M111/103
```

## 2. FSM núcleo (estados y transiciones)

```
        ┌────────┐   evento   ┌────────┐
        │ Idle   │──────────►│ Mover  │──► Actividad (trabajar/comer/social)
        └────────┘  plan      └────────┘       ▲ ▼ memoria
           ▲  ▲  │interrupción(│clima/obras/   │ │
        fin│  │  ▼jugador)     └───────────────┘ │
        └──┴──┴─────── Reaccionar ──► volver a plan (índice guardado)
        └──── Fallback: IrACasa (siempre navegable) / Quieto + teleport suave
```

Transiciones: eventos del mundo (señales M29/M31/M32/M17/M21/M69) → `interrumpir(motivo)`.

## 3. Perfiles de rutina (Rutina.tres)

| Perfil | Despertar | Trabajo | Almuerzo | Tarde | Social | Dormir |
|---|---|---|---|---|---|---|
| Granjero | 06:00 | parcela 08-12 / 13-17 | 12-13 | parcela | plaza 20-22 | 22:30 |
| Pescador | 05:30 | muelle 07-12 / 14-17 | 12-14 | muelle | cantina | 22:00 |
| Comerciante | 07:00 | tienda 09-18 | 13-14 | tienda | mercado | 22:30 |
| Artesano | 06:30 | taller 08-17 | 12-13 | taller | templo | 23:00 |
| Niño | 07:30 | escuela 09-13 | 13-14 | juegos | plaza | 21:00 |
| Anciano | 08:00 | banco/parque | 12-13 | parque | templo | 20:30 |

Variación ±30 min (PRNG M29). Estaciones y clima desplazan indoor/outdoor (P9/P10).

## 4. Navegación

- `NavigationServer3D` con navmesh global regenerada por M08 (regiones caminables); coste por bioma (césped 1, arena 1.2, roca 1.4).
- Cada NPC con `NavigationAgent3D`: `path_desired_distance` 1.0, `target_desired_distance` 1.5, `path_max_distance` 4.0.
- Obstáculos dinámicos: `NavigationObstacle3D` (carretas, andamiajes M17); prioridad de ruptura: el NPC más cercano re-planea (cooldown 0.5 s).
- Nada de pathfinding a destinos fuera de navmesh: la capa POI valida (P20).

## 5. Interrupciones y recuperación

- Fuentes de interrupción: clima (M32) con 2 ticks de anticipación; obras (M17) al cambiar navmesh; diálogo (M21) cercano; eventos M73; jugador corriendo (desvío).
- Memoria: `plan_reanudar = {indice, hora_restante}` — al volver, el NPC reanuda la actividad exacta (no empieza la rutina de cero).
- Errores: destino inalcanzable → 2 reintentos con alternativas (POI secundario) → fallback IrACasa → log DOM-IA.

## 6. Anti-atascos y anti-solapamiento

- Detector de stuck: posición sin cambio > 2 s → re-path; > 6 s → teleport discreto a caminable cercano + log.
- Separación radial entre NPCs: fuerza de empuje suave (máx 0.3 m de interpenetración); ceiling de 12 NPCs en un mismo tile de plaza → destinos escalonados al planificar.
- Ningún NPC empuja al jugador: la avoidance se desactiva para el jugador (el NPC cede el paso).

## 7. Simulación parcial (burbuja)

- Burbuja del jugador: radio 64 m (zona activa IA completa).
- Fuera de burbuja: estado "receta" — tick 1 s: `estado = agenda[hora]`, `destino = poid[id]`, sin pathfinding.
- Al volver a la burbuja: rehidratación — el NPC se coloca en el destino de su receta (fade en punto lejano al jugador si es necesario).
- Presupuesto: ≤ 60 plena; si la zona tiene más (ciudad), el excedente alterna a receta "elegante" por las más lejanas.

## 8. Presupuesto y rendimiento (M61)

| Métrica | Tope |
|---|---|
| NPC a plena IA en burbuja | 60 |
| FSM ticks totales | ≤ 8 ms (promedio) |
| Pathfinding simultáneos | ≤ 8 por frame |
| Avoidance updates | ≤ 30 por frame |
| Tick de receta (lejanos) | 1 s |
| Allocs en camino IA | 0 (pool de caminos) |

## 9. QA

- Test M112: rutinas cumplen horario (spot-check 24 h simuladas), interrupciones reanudan plan, stuck se recupera, presupuestos respetados (profiler M113).
- Recorrido M114: pueblo vivo durante 3 días de juego; sin NPCs superpuestos ni atascados; reacciones correctas a lluvia/obras/jugador.