# 01 — Requerimientos — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

La isla ancestral contiene templos con puzzles que deben ser **justos, coherentes y rejugables**: nunca arbitrarios, nunca ambiguos, con ayuda disponible y que no bloqueen la partida (ver M66 Anti-Softlock). El módulo define la filosofía, dificultad y tutorialización, y diseña 15 familias de puzzles con pistas, sistema de ayuda, checkpoints, reinicios y recompensas.

## Objetivos

- Resolver los 26 puntos de la sección 23 del plan maestro.
- **Framework emisor→receptor** (nota de la tabla global): todo puzzle es un grafo de emisores (acciones) y receptores (efectos) conectados por reglas — el jugador percibe causa-efecto inmediato y lógica.
- Dificultad progresiva por zona del templo con tutorialización integral (primera vez ⇨ pista ⇨ solución parcial ⇨ solución completa, ver "sistema de ayuda").
- Coherente con M66 (reinicio de puzzles), M08 (terreno), M26 (Templo Subterráneo) y M13 (dependencia declarada).

## Alcance

- Filosofía, dificultad y tutorialización.
- 15 familias: luz, espejos, agua, hielo, presión, bloques, gravedad, movimiento, sonido, secuencia, símbolos, ambientales, con herramientas, multilaterales.
- Pistas, sistema de ayuda, anti-arbitrariedad, anti-ambigüedad.
- Pruebas con jugadores externos, medición de tiempo de resolución, checkpoints, reinicio y recompensas.

## Fuera de alcance

- Construcción física de los templos (M25 Ruinas / M26 Templo Subterráneo) y sus assets (M45 Arte 3D, M47 Texturas).
- Audio del puzzle (M43) y cinematografía (M33); solo se definen hooks.
- Diálogos de los NPC guardianes (M22/M23); solo se definen señales visuales.

## Restricciones

- **Nunca arbitrarios ni ambiguos:** cada puzzle tiene exactamente una solución lógica verificable; las reglas del framework emisor→receptor lo garantizan (ver 03-Diseño).
- **Cozy:** prohibido el "te encajes y resuelvas con prueba-error infinito"; el sistema de ayuda nunca penaliza (pista gratis pero diferida).
- **Presupuesto:** el framework es datos-driven; el runtime del puzzle no debe superar 1 ms por tick (M61); sin allocations en Update.
- **Checkpoint y reinicio** según el contrato de M66 (IRecoverable).
- Documentación `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 26 puntos de la sección 23 cumplidos y verificables por tests automatizados + playtests externos.
2. El framework emisor→receptor exporta cada puzzle como datos serializables (JSON/YAML) y los tests los verifican sin escena.
3. Tiempo medio de resolución medido por familia (playtests) y sesgo de dificultad documentado.
4. Cero softlocks por puzzle (integración con M66) y cero excepciones en Consola.