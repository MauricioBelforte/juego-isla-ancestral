# 02 — Análisis — M66: Anti-Softlock

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 65 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Evitar objetos inaccesibles | Todo objeto clave nace con 2+ caminos verificables o está justificado narrativamente; validación en el detector con raycasts de navegación |
| Evitar NPC atascados | Watchdog global reusado del M64: 2 s re-path / 6 s teleport discreto; además teleport al nodo "hogar" si escena inválida |
| Evitar misiones imposibles | Cada objetivo tiene un `Fallback` declarable; el detector compara estado de objetivos contra condición de imposibilidad |
| Evitar objetos únicos perdibles | Inventario único se serializa en el guardado; si el objeto no existe en el mundo + no se posee, se devuelve al cofre de recuperación |
| Permitir recuperación de objetos clave | "Cofre de recuperación" por zona (aldea/templo): índice de objetos recuperados con 1 copia inmutable por clave |
| Permitir reinicio de puzzles | PuzzleState: si no es resoluble en 30 s de diagnóstico → reinicio a estado inicial del slot (con log de evento) |
| Detectar estados inválidos | Detector de invariantes: jugador vivo y sobre mundo, misiones con objetivos existentes, NPC con nodo válido, vehículo en el mundo |
| Crear recuperación automática | Recuperador por categoría con prioridad ≤ 15 segundos tras detectar el estado inválido |
| Crear checkpoints | Checkpoint por evento: al entrar a bioma, completar misión, estabilizar vehículo; respaldo por escena en slot rotativo |
| Crear fallback de misiones | Fallback alternativo por objetivo "crítico" (ej: 'convencer al anciano' → alternativo 'traer carta'); equivalente en progresión |
| Crear restauración de NPC | Rehidratar NPC: posición hogar, agenda reset (M64), inventario de la última transacción persistente |
| Crear recuperación de vehículos | Si un vehículo queda fuera del mundo (colisión, fuera de mapa), reaparece en su amarre tras 30 s |
| Crear recuperación del jugador | Si el jugador queda fuera del mundo o en geometría inválida → teletransporte al último checkpoint con efectos suaves |
| Testear cierres inesperados | Respaldo antes de cada guardado (guardado atómico) + test que simula corte a mitad de escritura |
| Testear modificaciones extremas del terreno | Suite con M08/M28: hundir el suelo bajo objetos clave → el detector reubica/recupera dentro del mismo chunk |

## Alternativas descartadas

1. **Solo checkpoints (sin detector de invariantes):** descartado — no repara partidas corruptas por cierres/terreno; el detector es obligatorio.
2. **Undo global de partida:** descartado — castiga el progreso; solo respaldo local de estados clave.
3. **Recuperación "invisible" total:** descartado — el jugador debería ver un toast ligero para no pensar que "perdió" algo.
4. **Fijar cada sistema con parches ad-hoc por misión:** descartado — sin mantener los 15 puntos y sin suite de pruebas es inviable en 60+ módulos.

## Decisiones

- **Detector de invariantes centralizado** (`SoftlockGuard`, singleton del módulo) con reglas declarativas por categoría; las misiones publican sus `Fallback` en un registro estático.
- **Cofre de recuperación** como mecanismo único para todo objeto único perdido (una copia inmutable por clave, jamás duplicable: al tomarse, marca "recuperado").
- **Checkpoints rotativos:** 3 slots por bioma + 1 slot global de emergencia; nunca más de 4 escrituras en disco por evento (atómico).
- **Recuperación en cascada:** primero reparar en el lugar (teleport de NPC/vehículo), luego devolver objeto al cofre, recién al final reiniciar el puzzle — jamás borrar datos del jugador.
- La suite de tests provoca cada softlock artificialmente (estados injertados) y verifica la recuperación ≤ 15 s (ver 06-Plan-Testings).