**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Módulo 11: Personaje del Jugador

## 1. Carácter del Componente

Módulo que **especifica el personaje jugable** (físicas, FSM, interacción, luz, HUD, selección, terrenos) para implementarse en el prototipo del hito M1. No crea scripts todavía (la implementación acompaña al primer playable con Voxel Tools). Sin 06/07 por ahora (el plan de testings irá con M1 — movimiento, colisiones, estados).

## 2. Archivos involucrados (implementación prevista)

```
scripts/player/player_controller.gd     → CharacterBody3D + entrada (M05)
scripts/player/player_fsm.gd            → máquina de estados (autoload PlayerState)
scripts/player/interaction_service.gd   → raycast + prompts
scripts/player/light_collector.gd       → esporas de luz
scripts/player/player_energy.gd         → stamina (sin penalización)
scripts/player/character_selector.gd    → sistema de selección de personaje
scripts/player/terrain_detector.gd      → detección de terreno bajo los pies
data/player/player_motion.tres          → constantes de movimiento
data/player/characters.tres             → catálogo de personajes (6 opciones)
data/player/terrain_modifiers.tres      → modificadores de velocidad por terreno
```

## 3. Contratos de integración

- **Entrada:** Input System de Godot (action map `Player`: move, sprint, jump, interact, dive).
- **Salida:** `PlayerState` observable (position, velocity, stamina, current_interactable, character_id, current_terrain) → EventBus (M07) + GameState.M11.
- **Consume:** bloque bajo los pies (bioma → audio de pasos) de M08; IInteractable de cualquier módulo; datos de terreno de M156; datos de equipamiento de M155.
- **Publica:** `player_state_changed`, `player_fatigue(30%)`, `light_collected(count)`, `terrain_changed(terrain_type)`.
- **Conecta:** M12 (cámara), M13 (herramientas), M14 (inventario de luz), M31 (camas), M155 (vestimenta), M156 (terrenos).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementar FSM + físicas en el playable | Prototipo M1 |
| Morfología final del personaje (skin voxel) | M65 (assets) |
| Validar sensación de salto/agua en el motor | M1 playtest |
| Sistema de bienestar (dieta/sueño) | M29 (re-evalúa) |
| Sistema de vestimenta funcional | M155 (nuevo módulo) |
| Modificadores de terreno | M156 (nuevo módulo) |
| Selección de personaje (pantalla + persistencia) | M11 (este módulo) |

## 5. Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22
**Estado:** Expandido con selección de personaje, vestimenta funcional y terrenos

### Lo que hice
- Resolví los 30 puntos de la sección 10 del plan maestro.
- FSM completa con 10 estados y tabla de permisos.
- Constantes físicas consumibles (hitbox 0.6×1.8, velocidades, salto, aire de buceo, stamina) en data/.
- Sistema de interacción (F + highlight + prompt) y esporas de luz (M14).
- Filosofía cozy aplicada: sin daño de caída, fatiga con aviso, buceo nunca fatal.
- Agregué sistema de selección de personaje (6 opciones, puramente visual).
- Agregué tabla de modificadores de velocidad por terreno y equipamiento.
- Agregué feedback visual por terreno (barro, pavimento, arena, etc.).
- Definí integración con M155 (vestimenta) y M156 (terrenos).

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar físicas → requiere motor (M1).
- Definir la morfología final del avatar → assets M65.
- Calibrar sensaciones (salto, agua) → playtest en M1.
- Volar/levitar → post-v1.0 (temporada).

### Recomendaciones para el próximo agente
- M12 (Cámara) consume el pivot tras el hombro: no mover cámara con física del cuerpo.
- Mantener el air-control al 60% (cozy ≠ parkour).
- La stamina debe informar, no bloquear: el jugador siempre puede caminar.
- El sistema de selección de personaje es puramente visual: no agregar stats diferentes.
- Los modificadores de terreno son suaves (+5-15%): nunca bloquear movimiento completo.
- Conectar con M155 para equipamiento y M156 para detección de terreno.


## Notas del Agente (2026-08-29 — Hy3/Kilo): salto + velocidad dev

- Salto con ESPACIO: velocity.y = 7.0 + _on_ground = false (gravity 20 => ~1.2 bloques)
- Velocidad dev 25: la escena Player.tscn PISA el @export move_speed (5.0) — los cambios
  en el script no aplicaban (40/120/300/2000/100 ignorados). Fix: forzar en _ready.
- Sub-stepping de get_motion RECHAZADO (1 FPS con velocidad 2000) — no repetir.

## 6. QA Cruzado — Notas del Agente (atria-dawn)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-17 08:30
**Estado:** QA realizado — módulo revierte `✅` → `🟡` (73 ítems a `[?]`)

### Veredicto
Sobre-cierre profundo. Los QAs previos (hy3 Log 835 + Hy3 Log 848 — mismo modelo)
verificaron "player.gd + player_equipment.gd **presentes**": puro chequeo de
presencia. Las secciones B–F del checklist afirman sistemas implementados (FSM de
10 estados, stamina, interacción, nado, esporas de luz, animaciones) que **no existen
en el código**. Ver detalle y tabla de constantes en la sección "K. QA Cruzado" de
`05-Checklist.md`.

### La realidad del código
- `scripts/player/player.gd` (1160 l.) + `scenes/player/Player.tscn` implementan:
  movimiento CharacterBody3D + **VoxelBoxMover**, salto (jump_force 8 / gravity 20),
  detección de terreno + bono M155 (**live** en boot), edición de bloques
  (edit_distance 8), hotbar persistente M13, modelo voxel visual.
- **0 menciones** de: stamina, StateMachine/FSM, IInteractable/interact, luz,
  nado/buceo, sprint, character_id/selección, AnimationPlayer/Tree, audio de pasos,
  guardado de posición.
- **6 de 7 scripts previstos en §2 no existen**; los 3 `.tres` tampoco; `data/player/`
  no existe. `terrain_detector.gd` vive en `scripts/terrain/` (legacy M156).
- Los contratos §3 (`PlayerState` observable, `player_fatigue(30%)`,
  `light_collected(count)`, `terrain_changed`) **nunca se publicaron**.

### Lo que está bien
- El núcleo de movimiento-colisión-terreno-edición **funciona y está integrado**
  (boot headless limpio, player spawneando, EquipmentManager conectado).
- Secciones I y J: diseño honesto con verbo "Definir", y la integración J↔M155 está
  realmente cableada.
- Salto real implementado por Hy3 (2026-08-29), documentado en §5.

### Correcciones aplicadas en este QA
- `05-Checklist.md`: 73 flips a [?] (secciones B–F íntegras + G.113 + H.125/H.126/
  H.129/H.131); Totales corregido de "121" (off-by-one) a 122 = 49 [x] / 73 [?];
  sección K de QA anexa con tabla de constantes vs código real.

### Recomendaciones para el próximo agente
1. Decidir alcance: implementar FSM+stamina+interacción+nado+selección, o reescribir
   B–F como spec alineada al código real (gravity 20, jump 8, move_speed 5, capsule
   radio 0.4 × alto 1.5).
2. Corregir §2/§3 de este archivo (paths y contratos fantasma).
3. Si el diseño requiere persistir la posición del jugador, es trabajo nuevo (hoy el
   spawn es por escena).
4. Verificar que M12/M13/M14 no estén esperando los eventos de §3 que nunca se
   publicaron.
