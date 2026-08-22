**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

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

## 3. Selección de personaje

### 3.1 Personajes disponibles (4-6 base)

| ID | Nombre | Género | Rasgo visual | Bioma de origen |
|----|--------|--------|-------------|-----------------|
|char_01 | Sol | F | Piel morena, cabello negro ondulado | Playa/costa |
| char_02 | Kai | M | Piel trigueña, cabello corto | Bosque |
| char_03 | Luna | F | Piel clara, pecas, cabello rojizo | Montaña |
| char_04 | Tide | M | Piel oscura, cabello trenzas | Ciudad/pueblo |
| char_05 | Sage | NB | Piel oliva, cabello corto Plateado | Ruinas/templo |
| char_06 | Ember | F | Piel bronceada, cabello largo | Volcán/desierto |

### 3.2 Sistema de selección

- **Pantalla de selección** al iniciar nueva partida: muestra los 6 personajes en rotación 360° (modo voxel preview).
- **Preview:** nombre, bioma de origen, frase característica (localizable).
- **Selección:** clic o tecla para confirmar. Sin preview de stats (todos son iguales mecánicamente).
- **Persistencia:** el personaje elegido se guarda en `GameState.player_character_id` y se carga en cada sesión.
- **Sinlocks:** todos los personajes desbloqueados desde el inicio (cozy = sin barreras).

### 3.3 Integración con vestimenta (M155)

- Cada personaje tiene 4 slots de equipamiento: cabeza, cuerpo, pies, accesorio.
- Las prendas se superponen al modelo base del personaje seleccionado.
- Las bonificaciones de terreno (M156) aplican independientemente del personaje elegido.
- La ropa cosmética no afecta stats; solo las prendas "funcionales" dan bonos.

## 4. Interacción y prompts

- `InteractionService` (M07) emite `interactable_in_range(enabled, label)`: el HUD muestra `[F] Cogote de agua`.
- Highlight: outline del objetivo dentro del rayo de 4 m.
- La acción F ejecuta el `IInteractable` en el objeto del mundo (puerta, NPC, mesa, cama, cofre, bloque puzzle).
- Regla: un interactable por vez (prioridad: el más cercano al centro del rayo).

## 5. Sistema de luz (destellos)

- Los destellos son **esporas de luz** flotantes (spawn de M27 o recogida natural).
- Contacto en radio 1.2 m → el destello "entra" al jugador (magnetismo animado 0.3 s) → `PlayerLightInventory` (M14).
- Punto de luz total visible en el HUD (pantalla de 6 esferas — M14/M28).
- Sin límite de recogida; cuenta como progresión del alma (sin monetización).

## 6. Integración con terrenos (M156)

### 6.1 Modificadores de velocidad por terreno

| Terreno | Vel. base | Botas barro | Patines pavimento | Bicicleta camino | Natación agua |
|---------|-----------|-------------|-------------------|------------------|---------------|
| Césped | 100% | 100% | 90% | 120% | — |
| Barro | 60% | 95% | 40% | 50% | — |
| Pavimento | 100% | 100% | 130% | 140% | — |
| Arena | 70% | 80% | 30% | 60% | — |
| Agua | 0% (nada) | — | — | — | 100% |
| Nieve | 75% | 85% | 50% | 70% | — |
| Rocas | 90% | 90% | 80% | — | — |

### 6.2 Feedback visual por terreno

- **Barro:** salpicaduras marrones al caminar, sonido de "squish".
- **Pavimento:** sonido de pasos nítidos, sin partículas.
- **Arena:** huellas temporales, sonido suave.
- **Agua:** ondulaciones, splash al entrar/salir.
- **Nieve:** crujido al pisar, huellas blancas.
- **Césped:** césped se mueve al pasar, sonido suave.

## 7. Animaciones y audio

- **Animaciones:** idle, walk, run, jump, fall, swim, dive, interact, sleep, craft (10 clips placeholder; final → M65 assets de terceros).
- **Blend trees:** walk↔run por velocidad; crossfade 0.1 s.
- **Audios:** pasos por material de superficie (detección por bloque bajo la hitbox), salto/caída, splash (entrada/salida del agua), interacción (chirrido de madera/metal), recogida (campana suave).
- Música del personaje: no (el mundo lleva la música, M53).

## 8. HUD y feedback (cozy)

- Barra de stamina: solo visible al drenar (entra/sale con fade) + icono de "cansado" suave.
- Al 30% de stamina: vibración suave + tinte azul en bordes (aviso, sin penalización).
- Buenos aires: indicador de aire solo en DIVE.
- Prompt de interacción con nombre del objeto (localizable, M57).
- Indicador de terreno actual: icono sutil en HUD mostrando tipo de superficie pisando.
- Indicador de equipamiento activo: mini-icono de la prenda funcional equipada.

## 9. Spawn y sesión

- `SpawnPoint` = hogar del jugador (M31); si no existe, el muelle del puerto.
- Guardado: posición, rotación, stamina, dirección de la cámara, personaje_elegido → GameState.M11 (M59).
- Session id: la partida se reanuda en el último punto de guardado (M60 descansar en cama).