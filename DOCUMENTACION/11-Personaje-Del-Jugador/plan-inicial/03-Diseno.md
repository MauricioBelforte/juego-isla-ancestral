**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 11: Personaje del Jugador

## 1. Modelo físico (constantes consumibles)

```
TAMAÑO_HITBOX  = 0.6 (ancho) × 1.8 (alto) × 0.3 (profundo)   # 1 bloque y medio de alto
VEL_WALK       = 4.2 m/s
VEL_RUN        = 6.5 m/s
VEL_SWIM       = 2.5 m/s  |  VEL_DIVE = 1.8 m/s
ALTURA_SALTO   = 1.2 m (2 bloques)  |  TIEMPO_AEREO = 0.6 s
GRAVEDAD       = 12 m/s²  |  VEL_TERMINAL = 20 m/s
STEP_UP        = 0.6 m (no escala paredes, sí rampas)
AIRE_BUCEO     = 18 s  →  flota automático (nunca fatal)
STAMINA_MAX    = 100  |  DRAIN_RUN = 12/s  |  REGEN = 8/s parado
RADIO_MAGNET   = 1.2 m (destellos de luz)
RANGO_INTERAC  = 4 m
```

- Todas en `data/player/player_motion.tres` (knobs sin recompilar).

## 2. FSM por estados (detalle de transiciones)

- **IDLE → WALK** (input direccional) · **WALK → RUN** (LShift + stamina > 0)
- **RUN → WALK** (stamina = 30 min o shift soltado) — sin bloqueo: siempre puede caminar.
- **→ JUMP** (espacio) desde tierra; **JUMP → FALL** al apex; **FALL → IDLE/WALK** al aterrizar (air-control 60%).
- **→ SWIM** (agua a cintura + nada); **SWIM → DIVE** (espacio sostenido bajo agua); **DIVE → SURFACE** (flota automático si aire < 20%).
- **→ INTERACT** desde tierra/aire si objetivo en rango (tecla F).
- **→ SLEEP/CRAFT** solo cuando el interactable lo permite (cama/mesa).

## 3. Interacción y prompts

- `InteractionService` (M07) emite `interactable_in_range(enabled, label)`: el HUD muestra `[F] Cogote de agua`.
- Highlight: outline del objetivo dentro del rayo de 4 m.
- La acción F ejecuta el `IInteractable` en el objeto del mundo (puerta, NPC, mesa, cama, cofre, bloque puzzle).
- Regla: un interactable por vez (prioridad: el más cercano al centro del rayo).

## 4. Sistema de luz (destellos)

- Los destellos son **esporas de luz** flotantes (spawn de M27 o recogida natural).
- Contacto en radio 1.2 m → el destello "entra" al jugador (magnetismo animado 0.3 s) → `PlayerLightInventory` (M14).
- Punto de luz total visible en el HUD (pantalla de 6 esferas — M14/M28).
- Sin límite de recogida; cuenta como progresión del alma (sin monetización).

## 5. Animaciones y audio

- **Animaciones:** idle, walk, run, jump, fall, swim, dive, interact, sleep, craft (10 clips placeholder; final → M65 assets de terceros).
- **Blend trees:** walk↔run por velocidad; crossfade 0.1 s.
- **Audios:** pasos por material de superficie (detección por bloque bajo la hitbox), salto/caída, splash (entrada/salida del agua), interacción (chirrido de madera/metal), recogida (campana suave).
- Música del personaje: no (el mundo lleva la música, M53).

## 6. HUD y feedback (cozy)

- Barra de stamina: solo visible al drenar (entra/sale con fade) + icono de "cansado" suave.
- Al 30% de stamina: vibración sutil + tinte azul en bordes (aviso, sin penalización).
- Buenos aires: indicador de aire solo en DIVE.
- Prompt de interacción con nombre del objeto (localizable, M57).

## 7. Spawn y sesión

- `SpawnPoint` = hogar del jugador (M31); si no existe, el muelle del puerto.
- Guardado: posición, rotación, stamina, dirección de la cámara → GameState.M11 (M59).
- Session id: la partida se reanuda en el último punto de guardado (M60 descansar en cama).