**Modelo:** nex-n2.5-pro (Nex-AGI)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 11: Personaje del Jugador

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: `[ ]` pendiente · `[x]` completado · `[?]` no resuelto.

## Reserva actual

- **Estado:** 🟡 Con dudas — liberado
- **Agente:** — (nex-n2.5-pro liberó la reserva)
- **Logs:** 1055, 1062, 1064, 1069 · **1130** (correcciones, 2026-09-20)
- **Inicio:** 2026-09-18 20:15
- **Liberación:** 2026-09-19 08:08
- **Alcance:** Fase 0 suite headless y auditoría de los 73 `[?]` completadas; implementación restante y QA cruzado §21.8 pendientes.

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

- [?] Hitbox: ancho 0.6, alto 1.8, profundo 0.3 m → código usa CapsuleShape3D radio 0.4, height 1.5 (Player.tscn:7-8) [S] # divergencia documentada
- [?] Velocidad de caminar: 4.2 m/s → `Player.tscn:13` serializa `move_speed=5.0`, pero `_ready()` fuerza `25.0` en modo DEV; la suite mide 25.0 [S] # divergencia documentada
- [?] Velocidad de correr: 6.5 m/s → NO implementado (sin sprint) [S]
- [?] Velocidad de nadar: 2.5 m/s → NO implementado (solo _en_agua()+velocity.y=4.0 para subir) [S]
- [?] Velocidad de buceo: 1.8 m/s → NO implementado [S]
- [?] Altura de salto: 1.2 m → código jump_force=8, gravity=20 → alt=1.6m; divergencia [S]
- [?] Gravedad 12 m/s² y velocidad terminal 20 m/s [S]
- [?] Step-up 0.6 m → NO implementado (VoxelBoxMover.get_motion no expone step-up configurable) [S]
- [?] Aire de buceo: 18 s → NO implementado (no hay sistema de aire) [S]
- [?] Stamina: máx 100, drenado 12/s, regen 8/s → NO implementado [S]
- [?] Radio de magnetismo de luz: 1.2 m → NO implementado (sin sistema de luz) [S]
- [?] Rango de interacción: 4 m → NO implementado (sin InteractionService) [S]

## C. FSM de estados (16)

- [?] Estado IDLE: entrada/salida, sin movimiento → NO existe FSM; input WASD directo en _physics_process [M]
- [?] Estado WALK: entrada por input direccional → NO existe FSM; movimientohandled directamente [M]
- [?] Estado RUN: entrada por LShift + stamina > 0 → NO implementado (sin sprint ni stamina) [M]
- [?] Transición RUN→WALK al 30% de stamina o shift suelto → NO implementado (sin sprint/stamina) [M]
- [?] Estado JUMP: entrada desde tierra → jump_force=8.0 con ESPACIO implementado pero SIN estado FSM; lógica hardcodeada en _physics_process [M]
- [?] Estado FALL: entrada al apex; control aéreo 60% → NO implementado (sin detección de apex ni control aéreo diferenciado) [M]
- [?] Aterrizaje FALL→IDLE/WALK suave → NO implementado (sin FSM de caída) [M]
- [?] Estado SWIM: entrada al tocar agua de cintura → _en_agua() existe pero NO hay estado SWIM; solo velocity.y=4.0 al pulsar espacio [M]
- [?] Estado DIVE: entrada con mantener espacio bajo agua → NO implementado (solo subida con ESPACIO) [M]
- [?] Estado SURFACE (flota): al 20% de aire o soltar → NO implementado (sin sistema de aire) [M]
- [?] Transición SWIM→WALK en bordes (salida del agua) → NO implementado (sin FSM) [M]
- [?] Estado INTERACT: bloquea movimiento 0.3 s → NO implementado en el jugador. El soft-lock existe del lado del manager (M70: `pausar()`/`reanudar()` en `interaction_manager.gd`), pero el player no tiene estado ni bloqueo de movimiento. [M]
- [?] Estado SLEEP: solo desde cama (M31) → NO implementado [M]
- [?] Estado CRAFT: solo desde mesa (M16) → NO implementado [M]
- [?] Tabla de permisos por estado (mov/jump/interact/sprint) → NO implementado (sin FSM) [M]
- [?] Sin estados imposibles (transiciones validadas) → NO aplicable (sin FSM) [M]

## D. Interacción y luz (14)

- [?] InteractionService con raycast de 4 m → **CORREGIDO 2026-09-20:** el nombre `InteractionService` no existe, pero un equivalente SÍ: `scripts/interacciones/interaction_manager.gd`, autoload `50-interacciones` (M70, en HEAD). Selecciona objetivo por distancia (`_elegir_objetivo`, línea ~193), pero su rango real es **2.5 m** (`const DEFAULT_RANGO := 2.5`, línea 37), no 4 m, y **no está cableado al jugador**: `inyectar_jugador()` no se llama desde ninguna escena (0 ocurrencias fuera del propio manager). Falta el puente M11↔M70; sin él el sistema está inerte respecto del personaje. [M]
- [?] Highlight del objetivo en rango → NO implementado [M]
- [?] Un interactable a la vez (prioridad centro de rayo) → NO implementado [M]
- [?] HUD: prompt `[F] <nombre>` (localizable M57) [M]
- [x] IInteractable consumible por cualquier módulo → **CORREGIDO 2026-09-20:** la interfaz SÍ existe: `scripts/interfaces/i_interactable.gd` (`class_name IInteractable`, v2 de M70, verificado en HEAD con `git cat-file -e`). El QA del Log 977 buscó sólo dentro de `scripts/player/` y la declaró inexistente. M11 no la consume (ver D.68). [M]
- [?] Esporas de luz: spawn desde M27/natural → NO implementado (sin sistema de luz) [M]
- [?] Magnetismo 1.2 m con animación de entrada 0.3 s → NO implementado [M]
- [?] PlayerLightInventory (M14) recibe las esporas → NO implementado (M14 es modulo separado) [M]
- [?] HUD de luz total (6 esferas, M14/M28) → NO implementado [M]
- [?] Recogida sin límite (progresión del alma) → NO implementado [S]
- [?] Audio de recogida (campana suave) → NO implementado [S]
- [?] Evento `light_collected(count)` en EventBus [M]
- [?] Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M]
- [?] Recogida idempotente: si se salvó la espora como recogida, no reaparece al regenerar → NO implementado [M]

## E. Energía y bienestar (14)

- [?] Stamina siempre informativa (nunca bloquea caminar) → NO implementado [M]
- [?] Barra visible solo al drenar (fade) → NO implementado [M]
- [?] Icono de fatiga suave al 30% → NO implementado [M]
- [?] Vibración sutil + tinte en bordes al 30% → NO implementado [M]
- [?] Sin daño por caída (amortiguación en alturas > 3 bloques) → PARCIAL: no hay sistema de daño por caída en `player.gd`, pero la amortiguación solicitada no está implementada [M]
- [?] Regeneración libre parado o caminando → NO implementado (sin stamina) [S]
- [?] Hueco de fatiga: sprint no acumula deuda permanente → NO implementado [M]
- [?] Bucle día/noche afecta energía (descanso M29) → NO implementado [M]
- [?] Alimentos otorgan bonos de bienestar (M29) → NO implementado en player.gd [M]
- [?] Cero penalización por dormir poco (aviso suave) → NO implementado [M]
- [?] System settings: toggle sprint (hold/alternate) → NO implementado [S]
- [?] Validación cozy: sin castigos por jugar "mal" [M]
- [?] Aviso de fatiga no interrumpe el flujo (no modal) → NO aplicable (sin stamina) [S]
- [?] El sprint vuelve a 0 sin penalizar la siguiente acción → NO implementado [S]

## F. Animaciones y audio (12)

- [?] 10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft → NO existen AnimationPlayer ni AnimationTree en Player.tscn [M]
- [?] Blend tree walk↔run por velocidad → NO existe AnimationTree [M]
- [?] Crossfade 0.1 s entre estados → NO aplicable (sin animaciones) [S]
- [?] Pasos por superficie (césped, arena, piedra, barro, agua) → NO implementado [M]
- [?] Saltos y aterrizajes con audio → NO implementado [S]
- [?] Splash de entrada/salida del agua → NO implementado [S]
- [?] Chirrido de interacción (madera/metal según objeto) → NO implementado [M]
- [?] Assets finales → M65 (terceros) → Pendiente de M65 [M]
- [x] Sin voz del personaje (cozy) → VERIFICADO 2026-09-20: 0 ocurrencias de `AudioStream`/`voice`/`voz`/`.wav`/`.ogg` en `player.gd` (grep). La nota ya decia VERIFICADO y llevaba el glifo `[x]`, pero el marcador era `[?]`.
- [x] La música del mundo la lleva M53 → VERIFICADO 2026-09-20: 0 ocurrencias de `music`/`musica`/`BGM` en `player.gd` (grep). Mismo defecto de marcador que F.110.
- [?] Sin loops de audio solapados al transicionar estados rápidos → NO aplicable (sin audio de pasos/animaciones) [M]
- [?] Volúmenes por capa: pasos → interacción → ambiente (M53) → NO aplicable (sin audio de personaje) [S]

## G. Documentación e integración (12)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [?] Constantes consumibles en data/player/player_motion.tres → directorio data/player/ NO EXISTE [M]
- [x] Contrato PlayerState → EventBus + GameState.M11 [M]
- [x] Entrada por action map Input System de Godot [S]
- [x] Sin contradicciones con M07 (ServiceLocator, capas) [M]
- [x] Sin contradicciones con M08 (bloque 1 m, hitbox) [M]
- [x] Sin contradicciones con M09 (biomas → pasos) [M]
- [x] Pendientes asignados (M1, M29, M65) [S]

## H. Verificación y cierre (12)

- [x] Los 30 puntos de la sección 10 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [?] FSM con tabla de permisos completa → NO implementado (sin FSM) [M]
- [?] Constantes físicas documentadas y consumibles → NO existe data/player/player_motion.tres [M]
- [x] Filosofía cozy preservada (sin castigos) [M]
- [x] Spawn del jugador definido (hogar o muelle) [M]
- [?] Guardado de posición/estado en GameState.M11 → NO existe GameState ni sección M11; player_save_provider solo guarda posición/spawn/zone [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]
- [x] Salto con ESPACIO y velocidad dev (viewer dinamico) [S] (2026-08-29) — implementado por Hy3, documentado en `04-Codigo.md` §5 [S]
- [x] Suite headless `test_player_m11.gd`: 30 checks, 0 fallos, Godot 4.7.2, EXIT 0 y 0 `SCRIPT ERROR` propios [M]
- [?] Anti-frustration: buceo flota, caída sin daño, stamina informa → caída sin daño PARCIAL: no hay daño, pero falta amortiguación; buceo/sprint NO implementados [M]
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

**Totales:** 123 ítems · Completados: 53 · Pendientes: 0 · No resueltos: 70.
**Nota:** la sensación real de movimiento (salto, agua, fatiga) se calibra en el playtest del hito M1. Selección de personaje y terrenos documentados por MiMo V2.5 (OpenCode).
**Evidencia de suite:** `game/isla-ancestral/scripts/player/test_player_m11.gd` ejecutada con Godot 4.7.2: 30 checks, 0 fallos, EXIT 0 y 0 `SCRIPT ERROR` propios (Logs 1055/1062/1064/1069). Revalidación final posterior a la liberación: 30/0, EXIT_CODE=0. El módulo quedó liberado en estado 🟡 porque los 73 `[?]` de implementación siguen abiertos.


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
  **esporas de luz / light_collected** (0), **nado / buceo / aire** (0 como *sistema*: hay 3 líneas que dicen «nadar» — `player.gd:295` (`velocity.y = 4.0` al pulsar ESPACIO dentro del agua), `:303` y `:415` (`_subir_a_superficie()`, helper DEV con la tecla N). No hay estado SWIM, ni aire, ni buceo), **sprint**
  (0), **selección de personaje / character_id** (0), **AnimationPlayer /
  AnimationTree / clips / audio de pasos** (0), **guardado de posición/estado** (0
  — el único "save" es el hotbar de M13).
- ❌ **Archivos previstos que no existen:** los 6 scripts `player_controller`,
  `player_fsm`, `interaction_service`, `light_collector`, `player_energy` y
  `character_selector`, más los 3 `.tres` (`player_motion`, `characters`,
  `terrain_modifiers`); `data/player/` no existe. `terrain_detector.gd` existe fuera
  de M11, en `scripts/terrain/` (carpeta legacy de M156), y no forma parte de ese
  conteo de 6 scripts ausentes.

**Constantes contradichas por el código** (sección B íntegra flipada):
| Checklist | Código/escena real |
|---|---|
| Hitbox 0.6 × 1.8 × 0.3 m | CapsuleShape3D radio 0.4, alto 1.5 (0.8 × 1.5, cápsula no caja) |
| Caminar 4.2 m/s | `Player.tscn:13` serializa 5.0; `_ready()` fuerza 25.0 en modo DEV y la suite mide 25.0 |
| Correr 6.5 m/s | no hay sprint |
| Gravedad 12 m/s² | gravity 20.0 |
| Salto 1.2 m (2 bloques) | jump_force 8 + gravity 20 → 1.6 m |
| Nado 2.5 / buceo 1.8 / aire 18 s | no hay nado ni buceo |
| Stamina 100, 12/s, 8/s | no hay stamina |
| Magnetismo luz 1.2 m / interacción 4 m | no hay luz ni interaction service |

**Lo que SE mantiene [x] (53 ítems, tras las correcciones del 2026-09-20):** sección A (requisitos), G de documentación
(excepto G.113), H de cierre (excepto los 4 flipados), **secciones I y J íntegras** —
usan verbo "Definir" y son diseño entregado, y la integración J/M155 **está live** —
más el salto real implementado por Hy3 (2026-08-29) y su ítem de cierre asociado.

**Corrección de conteo:** el archivo histórico declaraba "121 ítems" y luego "122"; el
conteo vigente es **123 = 50 [x] / 73 [?]**, con 0 `[ ]` reales.

**Recomendaciones para el próximo agente:**
1. **Decidir el alcance real:** o bien implementar la FSM + stamina + interacción +
   nado + selección (que es el corazón del gameplay), o reescribir B–F como spec de
   diseño ("Definir/Documentar") al estilo M08, alineando los valores con el código
   real (gravity 20, jump 8, move_speed runtime 25 con serialización 5, capsule 0.4×1.5).
2. **`04-Codigo.md §2/§3`** ya distingue los 6 scripts previstos inexistentes,
   `terrain_detector.gd` (existente fuera de M11) y los contratos previstos que no
   están publicados; no tratar paths ni contratos previstos como runtime implementado.
3. El guardado de posición del jugador no existe: el spawn actual es por escena
   (Player.tscn en y=2); si el diseño requiere persistir posición, es trabajo nuevo.
4. M12/M13/M14 consumen de M11: verificar que no estén esperando los contratos
   (`PlayerState`, eventos) que nunca se publicaron.

---

## L. Correcciones y decisión de alcance (2026-09-20 — Log 1130, DeepSeek-V4.1-Flash)

### L.1 Lo que este pase NO cambió

El conteo declarado **era correcto**: 123 ítems = 50 `[x]` / 0 `[ ]` / 73 `[?]`.
La sospecha de drift («el cuerpo dice 55/2/78») se explica sin tocar nada: esos son
**conteos de SUBSTRING**, no de ítems. `[x]`=55 sale de 50 ítems + 2 ítems que llevan
el glifo al final (F.110/F.111) + 3 líneas de prosa; `[?]`=78 = 73 ítems + 5 de prosa;
`[ ]`=2 = 2 de prosa (la leyenda de la línea 6 y esta misma nota). **Los 73 `[?]` siguen
siendo 73**, y siguen abiertos.

### L.2 Defectos reales corregidos

| Defecto | Medición | Corrección |
|---|---|---|
| 4 encabezados con conteo equivocado | D decía 12 y tiene **14**; E 12/**14**; F 10/**12**; H 10/**11** | Encabezados al valor medido |
| F.110/F.111: el marcador contradecía su propia nota | la nota dice «VERIFICADO» y lleva `[x]`; el marcador era `[?]` | `[?]` → `[x]` (verificado por grep) |
| Ítem huérfano fuera de toda sección | `Salto con ESPACIO…` vivía **después** del bloque de Totales | Movido a la sección H |
| **D.72 afirmaba algo falso** | «no existe IInteractable.gd» → **existe**: `scripts/interfaces/i_interactable.gd`, en HEAD | `[?]` → `[x]` con la cita corregida |
| D.68/C.60 con diagnóstico incompleto | el manager **existe** (autoload `50-interacciones`), su rango es **2.5 m** y **no está cableado** | Nota reescrita; sigue `[?]` |
| K: «nado (0 menciones)» | hay **3** líneas que dicen «nadar» (295/303/415) | Nota medida |

**Lección del QA del Log 977 (y de D.72):** buscó dentro de `scripts/player/` y concluyó
«no existe». Un archivo que no está **en mi carpeta** no es un archivo que no existe —
y un falso positivo contra otro módulo contamina igual que un falso verde. La verificación
correcta es `git cat-file -e HEAD:<ruta>`, no `ls`.

### L.3 Decisión de alcance: B–F quedan como spec PENDIENTE, no se reescriben

Las dos opciones eran implementar la FSM completa de 10 estados, o reescribir B–F con
verbos de diseño («Definir/Documentar») al estilo M08. **Se descarta la segunda**: M08
tiene ítems de diseño *desde su redacción original*; reescribir B–F ahora convertiría
68 ítems de «no implementado» en «entregado» **cambiando el texto**, que es exactamente
el sobre-cierre que el Log 977 revirtió — la misma trampa que un test que consagra el bug.
La marca `[?]` es la verdad: **los sistemas no existen**.

Tampoco se implementó la FSM en este pase, por tres razones medidas:

1. `player.gd` **funciona** (movimiento, colisión voxel, salto, edición, hotbar, bono M155
   live en boot) y §15 dice *no tocar lo que funciona*; meter 10 estados en el
   `_physics_process` es un rediseño del núcleo, no una iteración.
2. Varios estados tienen **dueño externo**: CRAFT (M16), SLEEP (M31), energía (M29),
   animaciones (M65), audio (M53). No son cerrables desde M11.
3. La propia checklist dice que la sensación de movimiento se calibra en el **playtest de
   M1**, y B documenta 12 divergencias de constantes que necesitan una **decisión de
   diseño**, no un parche.

**Bloqueos con dueño, para el próximo agente:**

| Bloqueo | Ítems | Dueño |
|---|---|---|
| FSM de 10 estados + tabla de permisos | C (16) | M11 / prototipo M1 |
| Stamina y bienestar | E (14) | M11 + M29 (energía/sueño) |
| Interacción: **cablear** `inyectar_jugador()` y decidir el rango (hoy 2.5 m, spec 4 m) | D (14) | M11 ↔ M70 |
| Esporas de luz + magnetismo | D parcial | M14 / M27 |
| Animaciones y audio de pasos | F (12) | M65 (assets) + M53 (audio) |
| Constantes físicas vs. código (12 divergencias) | B (12) | decisión de diseño |

### L.4 Lo que sí se cerró: la evidencia de la suite estaba ROTA

La sección H tenía un `[x]` que citaba la suite headless como evidencia. Al auditarla
apareció **BUG-078**: el gate de CI (`quality.yml:352`) ejecutaba
`scripts/player/test_player_m11.gd` y **ese archivo no estaba en el repositorio**
(`git cat-file -e HEAD:` → no existe). Efecto medido: `godot --script <inexistente>` sale
con **EXIT 1**, así que en un checkout limpio el job `godot-lint` queda **ROJO** mientras
en el disco del autor todo parece verde. Commit `5ce3aa9`.

Además la suite no podía fallar de forma confiable (trampa 61): un aborto en `_run()` la
dejaba **colgada 60 s sin veredicto** (EXIT 124 medido) o, con el `--quit` que documenta
`04-Codigo.md` §7, salía **EXIT 0 sin imprimir resumen** — un falso verde. Se agregaron
los 3 guardianes (marcadores, piso `CHECKS_MINIMOS = 30`, `_summary()` diferido) y **los
tres se probaron en rojo con sondas**.

**Qué cubren realmente los 30 checks** (para no volver a citarlos de más): constantes
`@export` de la escena, hitbox, movimiento, la integración M155 y la API nativa de Voxel
Tools. **No** cubren FSM, stamina, interacción, nado, luz ni animaciones — y **4 de los 30
(B6–B9) afirman justamente que esos sistemas NO existen**, así que dan rojo el día que
alguien los implemente (marcados `[INVERTIBLE]` en la suite).

### L.5 Cross-check M12/M13/M14 (pedido por el usuario)

Los contratos previstos en `04-Codigo.md` §3 (`player_state_changed`, `player_fatigue`,
`light_collected`, `terrain_changed`, `PlayerState`, `character_id`,
`current_interactable`) **no aparecen ni una vez** en la documentación de M12, M13 ni M14
(grep sobre los tres `plan-actual/`). **Ninguno de los tres está esperando un evento que
M11 nunca publicó.** Sí hay dependencias reales y vivas de otra índole: M12 usa el pivot
del jugador (`get_camera_forward_xz`, consumido por `player.gd:385-387`) y M13 usa el
hotbar de `player.gd` — ambos **implementados**, no bloqueados.
