**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 64: IA de NPC

## ID del Módulo
- **Código:** M64 (plan maestro: sección 63 — IA de NPC)
- **Carpeta:** `DOCUMENTACION/64-IA-De-NPC/`
- **Dependencias:** M19 (NPCs), M61 (rendimiento). Relaciones: M29/M31/M32 (clima/tiempo), M36 (animales), M21 (diálogos), M24/26 (puzzles), M69 (fast travel)
- **Delegable desde:** hoy (diseño completo; implementación tras NPC base y presupuestos M61)

## 1. Problema

Dar vida a los habitantes de Aurora sin máquinas de estado tontas ni costosas: NPCs con horarios y rutinas creíbles, reacción a clima/estaciones/obras/jugador, navegación robusta (NavigationServer3D), prioridades e interrupciones — todo bajo presupuesto de agentes (simulación parcial para la multitud).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Máquina de estados | FSM jerárquica: Idle / Mover / Trabajar / Socializar / Comer / Dormir / Reaccionar / Interactuar |
| RF2 | Navegación y pathfinding | NavigationServer3D (Godot) con navmesh del mundo; obstáculos dinámicos con prioridad |
| RF3 | Prioridades y rutinas | Agenda diaria por NPC (Rutina): qué hace, dónde, cuándo (horario M29/M31) |
| RF4 | Comportamiento social | Saludos, charlas breves, reagrupación por afinidad; sin conversaciones largas bloqueantes |
| RF5 | Contextual y ambiental | Reacción al clima (lluvia → refugio), estaciones (M29 M32), obras del jugador (M17), al jugador |
| RF6 | Búsqueda de lugares | Sistema de "lugares" (POI) donde ir: hogar, trabajo, mercado, parque, templo |
| RF7 | Interrupciones y recuperación | Planes interrumpibles con memoria; recuperación de errores y fallbacks |
| RF8 | Anti-atascos | Detección de stuck, desvío, respawn de navegación; anti-solapamiento entre NPCs |
| RF9 | Optimización | Simulación parcial: NPCs lejanos en modo ligero (sin FSM completa); presupuesto de agentes |

## 3. Requisitos No Funcionales

- **Cozy:** NPCs amables; cero comportamiento agresivo; reacciones suaves y lógicas.
- **Rendimiento (M61):** máx 60 NPCs a plena IA en la zona activa; el resto simulación ligera (tick 1 s, sin pathfinding continuo); FSM tick ≤ 8 ms total.
- **Determinismo suave:** decisiones por PRNG de partida (M29) para coherencia entre guardados.
- Pausa con GameClock (M29) congela agentes sin desincronizar horarios.

## 4. Criterios de Aceptación

1. Los 22 puntos de la sección 63 resueltos.
2. FSM + rutinas + prioridades + fallbacks diseñados.
3. Presupuesto de agentes y simulación parcial definidos.
4. Anti-atascos/superposición con reglas concretas.
5. Delegable para implementación.