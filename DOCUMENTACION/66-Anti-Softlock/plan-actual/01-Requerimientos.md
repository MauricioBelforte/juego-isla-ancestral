# 01 — Requerimientos — M66: Anti-Softlock

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

Un juego de mundo abierto con misiones, objetos únicos, terreno modificable (M08) y cierres inesperados puede quedar **atascado sin solución**: objetos clave inaccesibles, NPC perdidos, misiones imposibles, puzzles irresolubles o el jugador trabado. El módulo garantiza que **toda partida sea completable** pase lo que pase.

## Objetivos

- Resolver los 15 puntos de la sección 65 del plan maestro: objetos inaccesibles, NPC atascados, misiones imposibles, objetos únicos perdibles, recuperación de objetos clave, reinicio de puzzles, estados inválidos, recuperación automática, checkpoints, fallback de misiones, restauración de NPC, recuperación de vehículos, recuperación del jugador, cierres inesperados y terreno modificado extremo.
- Sistema central de vigilancia + recuperación, no parches sueltos por misión.
- Nunca romper la progresión del jugador ni borrar su esfuerzo (guardado, checkpoints, M3X persistencia).

## Alcance

- **Detector global de estados inválidos** (cada guardado/transición de escena + tick de bajo costo): objetos clave, posición del jugador, NPC, misiones, puzzles, vehículos.
- **Recuperaciones automáticas** con reglas por categoría (clave, misión, NPC, puzzle, vehículo, jugador).
- **Checkpoints** de respaldo por escena y por evento crítico estable.
- **Fallbacks de misión** por objetivo (alternativa verificable si el original colapsa).
- **Tester de recuperación** automatizable (Edit Mode/Play Mode, ver 06-Plan-Testings).

## Fuera de alcance

- Diseño de la historia en sí (M22) ni de puzzles (M24/M26): el módulo solo vigila y recupera.
- Cheatos o debug menu (M110 ya cubre herramientas de desarrollo).
- Undo completo de la partida (solo respaldo de estados clave).

## Restricciones

- **Presupuesto:** el detector hogar corre cada 60 s + en eventos de guardado/transición; costo ≤ 0.5 ms; sin I/O síncrona en Update.
- **Nuance cozy:** la recuperación nunca castiga; el respaldo es silencioso y el jugador lo nota solo en pantalla de eventos (toast ligero).
- **Coherencia con la persistencia** del proyecto: respetar el esquema de guardado atómico (tmp+rename+,bak) ya definido en módulos de persistencia.
- Reuso del watchdog anti-atasco de M64 (NPC) y del sistema de navegación NavigationServer3D.
- Documentación en `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 15 puntos de la sección 65 cumplidos y verificables por pruebas automatizadas.
2. **Garantía demostrable:** suite de tests que provoca cada softlock y verifica la recuperación.
3. Ningún objeto clave queda perdido salvo que la misión lo permita narrativamente.
4. Sin excepciones en Consola y sin degradar el frame en ninguna escena de la isla.