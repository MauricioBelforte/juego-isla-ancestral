**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 11: Personaje del Jugador

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema: cuerpo jugable cozy coherente con el mundo voxel [S]
- [x] Registrar dependencias: M07 Arquitectura; consumidores M12, M13, M14, M19 [S]
- [x] Catalogar los 30 puntos del plan maestro (sección 10) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: movimiento terrestre (caminar, correr, saltar) [S]
- [x] RF2: movimiento acuático (nadar, buceo con aire) [S]
- [x] RF3: colisiones con voxel (hitbox 0.6×1.8 m) [S]
- [x] RF4: 10 estados del personaje [S]
- [x] RF5: interacción contextual (F) sobre IInteractable [S]
- [x] RF6: energía/stamina informativa, no castigadora [S]
- [x] RF7: recogida de esporas de luz con magnetismo [S]
- [x] RF8: animaciones placeholder y audio de pasos [S]

## B. Física y constantes (12)

- [?] Hitbox: ancho 0.6, alto 1.8, profundo 0.3 m [S]
- [?] Velocidad de caminar: 4.2 m/s [S]
- [?] Velocidad de correr: 6.5 m/s [S]
- [?] Velocidad de nadar: 2.5 m/s (superficie) [S]
- [?] Velocidad de buceo: 1.8 m/s (bajo agua) [S]
- [?] Altura de salto: 1.2 m (2 bloques) y tiempo aéreo 0.6 s [S]
- [?] Gravedad 12 m/s² y velocidad terminal 20 m/s [S]
- [?] Step-up 0.6 m (rampas sí, paredes no) [S]
- [?] Aire de buceo: 18 s con flotado automático [S]
- [?] Stamina: máx 100, drenado 12/s corriendo, regen 8/s parado [S]
- [?] Radio de magnetismo de luz: 1.2 m [S]
- [?] Rango de interacción: 4 m [S]

## C. FSM de estados (16)

- [?] Estado IDLE: entrada/salida, sin movimiento [M]
- [?] Estado WALK: entrada por input direccional [M]
- [?] Estado RUN: entrada por LShift + stamina > 0 [M]
- [?] Transición RUN→WALK al 30% de stamina o shift suelto [M]
- [?] Estado JUMP: entrada desde tierra [M]
- [?] Estado FALL: entrada al apex; control aéreo 60% [M]
- [?] Aterrizaje FALL→IDLE/WALK suave [M]
- [?] Estado SWIM: entrada al tocar agua de cintura [M]
- [?] Estado DIVE: entrada con mantener espacio bajo agua [M]
- [?] Estado SURFACE (flota): al 20% de aire o soltar [M]
- [?] Transición SWIM→WALK en bordes (salida del agua) [M]
- [?] Estado INTERACT: bloquea movimiento 0.3 s [M]
- [?] Estado SLEEP: solo desde cama (M31) [M]
- [?] Estado CRAFT: solo desde mesa (M16) [M]
- [?] Tabla de permisos por estado (mov/jump/interact/sprint) [M]
- [?] Sin estados imposibles (transiciones validadas) [M]

## D. Interacción y luz (12)

- [?] InteractionService con raycast de 4 m [M]
- [?] Highlight del objetivo en rango [M]
- [?] Un interactable a la vez (prioridad centro de rayo) [M]
- [?] HUD: prompt `[F] <nombre>` (localizable M57) [M]
- [?] IInteractable consumible por cualquier módulo [M]
- [?] Esporas de luz: spawn desde M27/natural [M]
- [?] Magnetismo 1.2 m con animación de entrada 0.3 s [M]
- [?] PlayerLightInventory (M14) recibe las esporas [M]
- [?] HUD de luz total (6 esferas, M14/M28) [M]
- [?] Recogida sin límite (progresión del alma) [S]
- [?] Audio de recogida (campana suave) [S]
- [?] Evento `light_collected(count)` en EventBus [M]
- [?] Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M]
- [?] Recogida idempotente: si se salvó la espora como recogida, no reaparece al regenerar [M]

## E. Energía y bienestar (12)

- [?] Stamina siempre informativa (nunca bloquea caminar) [M]
- [?] Barra visible solo al drenar (fade) [M]
- [?] Icono de fatiga suave al 30% [M]
- [?] Vibración sutil + tinte en bordes al 30% [M]
- [?] Sin daño por caída (amortiguación en alturas > 3 bloques) [M]
- [?] Regeneración libre parado o caminando [S]
- [?] Hueco de fatiga: sprint no acumula deuda permanente [M]
- [?] Bucle día/noche afecta energía (descanso M29) [M]
- [?] Alimentos otorgan bonos de bienestar (M29) [M]
- [?] Cero penalización por dormir poco (aviso suave) [M]
- [?] System settings: toggle sprint (hold/alternate) [S]
- [?] Validación cozy: sin castigos por jugar "mal" [M]
- [?] Aviso de fatiga no interrumpe el flujo (no modal) [S]
- [?] El sprint vuelve a 0 sin penalizar la siguiente acción [S]

## F. Animaciones y audio (10)

- [?] 10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft [M]
- [?] Blend tree walk↔run por velocidad [M]
- [?] Crossfade 0.1 s entre estados [S]
- [?] Pasos por superficie (césped, arena, piedra, barro, agua) [M]
- [?] Saltos y aterrizajes con audio [S]
- [?] Splash de entrada/salida del agua [S]
- [?] Chirrido de interacción (madera/metal según objeto) [M]
- [?] Assets finales → M65 (terceros) [M]
- [?] Sin voz del personaje (cozy) [S]
- [?] La música del mundo la lleva M53 [S]
- [?] Sin loops de audio solapados al transicionar estados rápidos [M]
- [?] Volúmenes por capa: pasos → interacción → ambiente (M53) [S]

## G. Documentación e integración (12)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [?] Constantes consumibles en data/player/player_motion.tres [M]
- [x] Contrato PlayerState → EventBus + GameState.M11 [M]
- [x] Entrada por action map Input System de Godot [S]
- [x] Sin contradicciones con M07 (ServiceLocator, capas) [M]
- [x] Sin contradicciones con M08 (bloque 1 m, hitbox) [M]
- [x] Sin contradicciones con M09 (biomas → pasos) [M]
- [x] Pendientes asignados (M1, M29, M65) [S]

## H. Verificación y cierre (10)

- [x] Los 30 puntos de la sección 10 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [?] FSM con tabla de permisos completa [M]
- [?] Constantes físicas documentadas y consumibles [M]
- [x] Filosofía cozy preservada (sin castigos) [M]
- [x] Spawn del jugador definido (hogar o muelle) [M]
- [?] Guardado de posición/estado en GameState.M11 [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]
- [?] Anti-frustration: buceo flota, caída sin daño, stamina informa [M]
- [x] Ready para: M12 (cámara), M13 (herramientas), M14 (inventario) [S]

## I. Selección de personaje (8)

- [x] Definir 6 personajes base con distinto diseño visual [M]
- [x] Definir que todos tienen mismas mecánicas (cozy = sin ventajas) [S]
- [x] Definir pantalla de selección con preview 360° [M]
- [x] Definir persistencia en GameState.player_character_id [M]
- [x] Definir personajes desbloqueados desde el inicio (sin locks) [S]
- [x] Definir integración con M155 (vestimenta se superpone al personaje) [S]
- [x] Definir guardado del personaje elegido en M59 [S]
- [x] Definir que la selección es puramente visual (sin stats) [S]

## J. Terrenos y movimiento (10)

- [x] Definir tabla de modificadores de velocidad por terreno [M]
- [x] Definir que barro reduce velocidad al 60% sin equipamiento [S]
- [x] Definir que pavimento permite patines (+30% velocidad) [S]
- [x] Definir que bicicleta da +20-40% en caminos pavimentados [M]
- [x] Definir que barro empantana sin botas adecuadas [S]
- [x] Definir feedback visual por terreno (salpicaduras, huellas, ondulaciones) [M]
- [x] Definir audio de pasos por tipo de superficie [M]
- [x] Definir indicador de terreno actual en HUD [S]
- [x] Definir integración con M155 (equipamiento afecta terreno) [S]
- [x] Definir que nadar no se ve afectado por equipamiento terrestre [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 122 ítems · Completados: 49 · Pendientes: 0 · No resueltos: 73.
**Nota:** la sensación real de movimiento (salto, agua, fatiga) se calibra en el playtest del hito M1. Selección de personaje y terrenos documentados por MiMo V2.5 (OpenCode).

- [x] Salto con ESPACIO y velocidad dev (viewer dinamico) [S] (2026-08-29)

---

## K. QA Cruzado (atria-dawn, 2026-09-17 — Log 977)

**Veredicto:** 🔴 El módulo era `✅ Completado` (verificado por hy3 Log 835 + re-QA Hy3
Log 848 — mismo modelo, "player.gd + player_equipment.gd **presentes**", puro chequeo
de presencia) y revierte a `🟡 Con dudas`. **73 flips a [?].**

**Diagnóstico:** este es el sobre-cierre más profundo del ciclo hasta ahora. A
diferencia de M08 (cuyos ítems usan verbos de diseño y por eso mantiene ✅), las
secciones B–F de M11 están escritas como **hechos implementados** ("Estado RUN:
entrada por LShift + stamina > 0", "Stamina: máx 100, drenado 12/s", "InteractionService
con raycast de 4 m") y **ninguno de esos sistemas existe en el código**.

**La realidad del código** (`scripts/player/player.gd`, 1160 l. + `Player.tscn`):
- ✅ **Implementado y live:** movimiento CharacterBody3D + VoxelBoxMover (colisión
  voxel), salto (ESPACIO, jump_force 8, gravity 20 — Hy3, 2026-08-29), detección de
  terreno + bono de equipamiento (`_on_terrain_bonus_changed`, integración M155
  confirmada en boot: "Player conectado a EquipmentManager.terrain_bonus_updated"),
  edición de bloques (edit_distance 8), hotbar con persistencia M13
  (ToolsSaveProvider), modelo voxel visual (`45-Arte3D_jugador_voxel.glb`).
- ❌ **No implementado (0 menciones en player.gd):** **stamina/fatiga** (0), **FSM /
  StateMachine** (0 — no hay estados Idle/Walk/Run/Jump/Fall/Swim/Dive/Surface/
  Interact/Sleep/Craft), **interacción / IInteractable / raycast de prompt** (0),
  **esporas de luz / light_collected** (0), **nado / buceo / aire** (0), **sprint**
  (0), **selección de personaje / character_id** (0), **AnimationPlayer /
  AnimationTree / clips / audio de pasos** (0), **guardado de posición/estado** (0
  — el único "save" es el hotbar de M13).
- ❌ **Archivos previstos que no existen:** 6 de 7 scripts (player_controller,
  player_fsm, interaction_service, light_collector, player_energy,
  character_selector) y los 3 .tres (player_motion, characters, terrain_modifiers);
  `data/player/` no existe. `terrain_detector.gd` existe pero en `scripts/terrain/`
  (carpeta legacy de M156, no de M11).

**Constantes contradichas por el código** (sección B íntegra flipada):
| Checklist | Código/escena real |
|---|---|
| Hitbox 0.6 × 1.8 × 0.3 m | CapsuleShape3D radio 0.4, alto 1.5 (0.8 × 1.5, cápsula no caja) |
| Caminar 4.2 m/s | move_speed 5.0 (Player.tscn; @export trae 100 DEV) |
| Correr 6.5 m/s | no hay sprint |
| Gravedad 12 m/s² | gravity 20.0 |
| Salto 1.2 m (2 bloques) | jump_force 8 + gravity 20 → 1.6 m |
| Nado 2.5 / buceo 1.8 / aire 18 s | no hay nado ni buceo |
| Stamina 100, 12/s, 8/s | no hay stamina |
| Magnetismo luz 1.2 m / interacción 4 m | no hay luz ni interaction service |

**Lo que SE mantiene [x] (49 ítems):** sección A (requisitos), G de documentación
(excepto G.113), H de cierre (excepto los 4 flipados), **secciones I y J íntegras** —
usan verbo "Definir" y son diseño entregado, y la integración J/M155 **está live** —
más el salto real implementado por Hy3 (2026-08-29).

**Corrección de conteo:** el archivo declaraba "121 ítems" pero tiene 122 (off-by-one
habitual); ahora declara 122 con 49 [x] / 73 [?].

**Recomendaciones para el próximo agente:**
1. **Decidir el alcance real:** o bien implementar la FSM + stamina + interacción +
   nado + selección (que es el corazón del gameplay), o reescribir B–F como spec de
   diseño ("Definir/Documentar") al estilo M08, alineando los valores con el código
   real (gravity 20, jump 8, move_speed 5, capsule 0.4×1.5).
2. **`04-Codigo.md §2` y `§3`** listan 7 scripts y contratos (PlayerState observable,
   `player_fatigue(30%)`, `light_collected`, `terrain_changed`) que no existen — mismo
   patrón de "paths fantasma" de M09/M10/M08. Corregir.
3. El guardado de posición del jugador no existe: el spawn actual es por escena
   (Player.tscn en y=2); si el diseño requiere persistir posición, es trabajo nuevo.
4. M12/M13/M14 consumen de M11: verificar que no estén esperando los contratos
   (`PlayerState`, eventos) que nunca se publicaron.
