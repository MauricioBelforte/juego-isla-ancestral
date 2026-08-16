**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 11: Personaje del Jugador

## 1. Carácter del Componente

Módulo que **especifica el personaje jugable** (físicas, FSM, interacción, luz, HUD) para implementarse en el prototipo del hito M1. No crea scripts todavía (la implementación acompaña al primer playable con Voxel Tools). Sin 06/07 por ahora (el plan de testings irá con M1 — movimiento, colisiones, estados).

## 2. Archivos involucrados (implementación prevista)

```
scripts/player/player_controller.gd     → CharacterBody3D + entrada (M05)
scripts/player/player_fsm.gd            → máquina de estados (autoload PlayerState)
scripts/player/interaction_service.gd   → raycast + prompts
scripts/player/light_collector.gd       → esporas de luz
scripts/player/player_energy.gd         → stamina (sin penalización)
data/player/player_motion.tres          → constantes de movimiento
```

## 3. Contratos de integración

- **Entrada:** New Input System de Godot (action map `Player`: move, sprint, jump, interact, dive).
- **Salida:** `PlayerState` observable (position, velocity, stamina, current_interactable) → EventBus (M07) + GameState.M11.
- **Consume:** bloque bajo los pies (bioma → audio de pasos) de M08; IInteractable de cualquier módulo.
- **Publica:** `player_state_changed`, `player_fatigue(30%)`, `light_collected(count)`.
- **Conecta:** M12 (cámara), M13 (herramientas), M14 (inventario de luz), M31 (camas).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementar FSM + físicas en el playable | Prototipo M1 |
| Morfología final del personaje (skin voxel) | M65 (assets) |
| Validar sensación de salto/agua en el motor | M1 playtest |
| Sistema de bienestar (dieta/sueño) | M29 (re-evalúa) |
| Cosmética y vestimenta | M65 + eventos |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 04:15:00
**Estado:** Completado (especificación; implementación en M1)

### Lo que hice
- Resolví los 30 puntos de la sección 10 del plan maestro.
- FSM completa con 10 estados y tabla de permisos.
- Constantes físicas consumibles (hitbox 0.6×1.8, velocidades, salto, aire de buceo, stamina) en data/.
- Sistema de interacción (F + highlight + prompt) y esporas de luz (M14).
- Filosofía cozy aplicada: sin daño de caída, fatiga con aviso, buceo nunca fatal.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar físicas → requiere motor (M1).
- Definir la morfología final del avatar → assets M65.
- Calibrar sensaciones (salto, agua) → playtest en M1.
- Volar/levitar → post-v1.0 (temporada).

### Recomendaciones para el próximo agente
- M12 (Cámara) consume el pivot tras el hombro: no mover cámara con física del cuerpo.
- Mantener el air-control al 60% (cozy ≠ parkour).
- La stamina debe informar, no bloquear: el jugador siempre puede caminar.