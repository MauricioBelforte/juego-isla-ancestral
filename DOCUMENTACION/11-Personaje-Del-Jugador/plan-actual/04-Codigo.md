**Modelo:** nex-n2.5-pro (Nex-AGI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19

# 04-Codigo.md — Módulo 11: Personaje del Jugador

## 1. Carácter del Componente

Módulo de personaje jugable. El núcleo runtime actual está en `scripts/player/player.gd` y
`scenes/player/Player.tscn`: CharacterBody3D, movimiento, colisión voxel, salto, edición de
bloques, hotbar e integración de bonos de equipamiento. La FSM, stamina, interacción, nado/buceo,
luz, animaciones, selección de personaje y guardado de estado siguen pendientes; no se presentan
como implementados.

## 2. Archivos y estado real

### Código live
- `scripts/player/player.gd` — CharacterBody3D, entrada, salto, VoxelBoxMover, edición y hotbar.
- `scenes/player/Player.tscn` — jugador, cápsula de colisión y valores serializados.
- `scripts/player/test_player_m11.gd` — suite headless de 30 checks.
- `.github/workflows/quality.yml` — gate CI de la suite M11.

### Archivos previstos que no existen
Los paths del plan inicial `scripts/player/player_controller.gd`, `player_fsm.gd`,
`interaction_service.gd`, `light_collector.gd`, `player_energy.gd`, `character_selector.gd` y los
recursos `data/player/*.tres` no están implementados. `terrain_detector.gd` existe fuera de M11,
en `scripts/terrain/`.

> **Corrección 2026-09-20 (Log 1130, DeepSeek-V4.1-Flash).** «No existe en `scripts/player/`» **no**
> es lo mismo que «no existe». Dos piezas que el QA del Log 977 declaró inexistentes **sí están en
> el repositorio**, fuera de M11 y verificadas con `git cat-file -e HEAD:`:
>
> | Pieza | Ruta real | Dueño | Estado respecto de M11 |
> |---|---|---|---|
> | `IInteractable` | `scripts/interfaces/i_interactable.gd` (`class_name IInteractable`) | M70 (v2) | **Existe**. M11 no la consume. |
> | Gestor de interacción | `scripts/interacciones/interaction_manager.gd` (autoload `50-interacciones`) | M70 | **Existe y corre**, pero **no está cableado al jugador**: `inyectar_jugador()` no se llama desde ninguna escena (0 ocurrencias fuera del propio manager). Su rango real es **2.5 m** (`const DEFAULT_RANGO := 2.5`, línea 37), no los 4 m de la spec. |
>
> Consecuencia para el diseño: el trabajo pendiente de interacción **no** es escribir el sistema
> desde cero, es **cablear el puente M11↔M70 y decidir el rango**. Un falso positivo contra otro
> módulo contamina el registro igual que un falso verde propio.

## 3. Contratos de integración previstos

Los contratos siguientes describen el diseño pendiente; no están publicados en el runtime actual:
- **Entrada prevista:** Input System de Godot (action map `Player`: move, sprint, jump, interact,
  dive).
- **Salida prevista:** `PlayerState` observable (position, velocity, stamina,
  current_interactable, character_id, current_terrain) hacia EventBus (M07) y GameState.M11.
- **Consumo previsto:** bioma bajo los pies (M08), IInteractable, datos de terreno (M156) y
  equipamiento (M155).
- **Señales previstas:** `player_state_changed`, `player_fatigue(30%)`, `light_collected(count)`,
  `terrain_changed(terrain_type)`.
- **Conexiones previstas:** M12, M13, M14, M31, M155 y M156.

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Completar FSM y físicas del playable | M11 / prototipo M1 |
| Morfología final del personaje (skin voxel) | M65 (assets) |
| Validar sensación de salto/agua en el motor | M1 playtest |
| Sistema de bienestar (dieta/sueño) | M29 (re-evalúa) |
| Sistema de vestimenta funcional | M155 (nuevo módulo) |
| Modificadores de terreno | M156 (nuevo módulo) |
| Selección de personaje (pantalla + persistencia) | M11 (este módulo) |

## 5. Notas históricas del agente (MiMo V2.5 / OpenCode, 2026-08-22)

> Registro histórico del plan inicial. Las afirmaciones de implementación de esta sección no
> representan el estado verificado del runtime; el QA de 2026-09-17 las contrastó contra el código
> y las dejó como deuda documentada.

### Lo que el registro histórico declaró
- Se resolvieron los 30 puntos de la sección 10 del plan maestro.
- Se declararon FSM de 10 estados, constantes físicas en `data/`, interacción, luz, selección de
  personaje y modificadores de terreno.

### Estado verificado posteriormente
- El QA de Atria-Dawn-Preview (Log 977) encontró que FSM, stamina, interacción, nado/buceo, luz,
  animaciones, selección y guardado de estado no existen en el runtime actual.
- El núcleo live confirmado es movimiento, colisión voxel, salto, edición, hotbar y el bono de
  equipamiento M155.


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
- **6 scripts previstos no existen**: `player_controller.gd`, `player_fsm.gd`,
  `interaction_service.gd`, `light_collector.gd`, `player_energy.gd` y
  `character_selector.gd`; `terrain_detector.gd` existe fuera de M11, en `scripts/terrain/`.
  Los 3 `.tres` previstos tampoco existen y `data/player/` no existe.
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
  H.129/H.131); conteo vigente corregido a **123 = 50 [x] / 73 [?]**, con 0 `[ ]` reales.
- Se anexó la sección K de QA con la tabla de constantes versus código real.

### Recomendaciones para el próximo agente
1. Decidir alcance: implementar FSM+stamina+interacción+nado+selección, o reescribir
   B–F como spec alineada al código real (gravity 20, jump 8, move_speed runtime 25 con
   serialización 5, capsule radio 0.4 × alto 1.5).
2. `04-Codigo.md §2/§3` ya distingue archivos y contratos live de los previstos; no tratar los
   paths/contratos previstos como runtime implementado.
3. Si el diseño requiere persistir la posición del jugador, es trabajo nuevo (hoy el
   spawn es por escena).
4. Verificar que M12/M13/M14 no estén esperando los eventos de §3 que nunca se
   publicaron.

## 7. Suite headless M11

- **Script:** `game/isla-ancestral/scripts/player/test_player_m11.gd`
- **Comando:** `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --quit --script res://scripts/player/test_player_m11.gd`
- **Resultado:** 30 checks, 0 fallos, EXIT 0, 0 `SCRIPT ERROR` propios.

> ⚠️ **`--quit` enmascara los abortos (medido el 2026-09-20, Log 1130).** Antes de endurecer la
> suite, un `SCRIPT ERROR` dentro de `_run()` dejaba el proceso **colgado** sin `--quit` (EXIT 124
> a los 60 s, sin veredicto) y con `--quit` salía **EXIT 0 sin imprimir resumen** — un falso verde
> con el comando documentado. Ya está corregido (`_summary()` registrado con `call_deferred`), pero
> **el comando canónico es el del CI, que NO lleva `--quit`**: así el veredicto lo decide la suite,
> no el motor. Ver §8.
- **Revalidación final:** 30 checks, 0 fallos, EXIT_CODE=0; bloques A +5, B +10, C +5, D +4, E +6.
- **Cobertura:** constantes y escena del jugador, hitbox, movimiento, EquipmentManager/M155 y API nativa de Voxel Tools.
- **Decisión de API:** `VoxelBoxMover` y `VoxelTerrain` se verifican mediante `ClassDB` porque son clases nativas. `VoxelTerrain` expone `get_voxel_tool()`, pero no `get_height()`; la altura corresponde a `TerrainLocator`/`IslandGenerator`.
- **Alcance:** no se modificó `player.gd` ni otro script de gameplay.

## Notas del Agente (2026-09-19 — nex-n2.5-pro/Kilo)

**Estado:** Parcial; M11 liberado a 🟡 Con dudas (50/123), con 73 `[?]` de implementación abiertos.

### Lo que hice
- Corregí la suite para usar la API nativa real de Voxel Tools y mantiene 30 assertions.
- Verifiqué el gate con inyección de error sintáctico: falla con EXIT 1 y se recupera a 30/0.
- Sincronicé la evidencia en checklist, backlog, guía de orden, estado paralelo y CI.

### Lo que NO pude hacer
- No implementé FSM, stamina, nado/buceo, interacción, luz, animaciones ni guardado de estado.
- No realicé QA cruzado §21.8 con otro modelo.

### Recomendaciones
- M11 queda 🟡 Con dudas hasta resolver o delegar formalmente los 73 `[?]` y realizar QA cruzado §21.8.
- No cambiar constantes de movimiento sin una decisión de diseño documentada.

## 8. Auditoría de la suite y de su gate (2026-09-20 — Log 1130, DeepSeek-V4.1-Flash)

### 8.1 BUG-078: el gate ejecutaba un archivo que NO estaba en el repositorio

`quality.yml:352` corre `godot --headless --script scripts/player/test_player_m11.gd`, y ese
archivo **no estaba versionado** (`git cat-file -e HEAD:` -> no existe; `git log -S` no lo
encuentra nunca). Efecto **medido**, no inferido:

| medición | resultado |
|---|---|
| `godot --script <ruta inexistente>` | **EXIT 1** — `ERROR: Attempt to open script … 'File not found'` |
| consecuencia | en un checkout limpio el job `godot-lint` queda **ROJO**; en el disco del autor el archivo existe y todo parece verde |

Es la trampa 98, y ya había pasado dos veces en este repo (BUG-051, BUG-071). Resuelto en
`5ce3aa9` (se versionó la suite). El barrido completo de los workflows encontró **8** casos, no 1:
5 de M64, 1 de M116, 1 de M117 y este de M11. Los 7 ajenos quedaron declarados en
`DEUDA_CONOCIDA` de `scripts/validar_workflows.py`, que ahora **falla** ante cualquier cita nueva
sin versionar.

### 8.2 La suite no podía fallar de forma confiable (3 defectos medidos)

| Defecto | Medición ANTES del fix | DESPUÉS |
|---|---|---|
| `_summary()` al final de `_run()` | aborto en `_run()` -> **EXIT 124** (colgado 60 s, sin veredicto) sin `--quit`; **EXIT 0 sin resumen** con `--quit` | `call_deferred("_summary")` en `_init()` -> **EXIT 1 en 4,6 s**, con el motivo y los bloques faltantes |
| sin piso de checks | un aborto parcial bajaba el conteo en silencio | `CHECKS_MINIMOS = 30` (medido en verde) |
| guard `_error_en_curso` | código **muerto**: la bandera nunca se ponía en `true` | eliminado |

También se eliminó `_esperar_autoloads()`, que se llamaba **sin `await`** en 5 sitios (no-op: el
`await` nunca llegaba al llamador). Los autoloads ya están arriba cuando corre el `_run()` diferido
— la salida lo muestra: `=== Bootstrap Completado ===` sale **antes** del resumen.

Los tres guardianes se probaron **en rojo con sondas**, no se confió en ellos:

- aborto al inicio del bloque C -> `[FALLO] Bloque faltante: C`, 26 checks / 2 fallos / EXIT 1;
- aborto dentro de `_run()` -> `[FALLO] Bloque faltante: A..E` + `solo 5 checks ejecutados
  (minimo 30)`, EXIT 1;
- se midió además que la sonda de la **trampa 63 no aplica** a esta suite (el helper inyectado no
  contenía checks, así que el conteo no bajaba). Se dice tal cual en vez de inflar el hallazgo.

### 8.3 Qué cubren realmente los 30 checks

Constantes `@export` de la escena, hitbox (`CapsuleShape3D`), movimiento, la integración M155 y la
API nativa de Voxel Tools. **No** cubren FSM, stamina, interacción, nado, luz ni animaciones.

⚠️ **4 de los 30 (B6–B9) afirman que esos sistemas NO existen.** Están marcados `[INVERTIBLE]`: el
día que alguien implemente stamina/FSM/interacción/luz van a dar **ROJO**, y eso no es una
regresión — es la señal de que hay que invertir el check y actualizar `05-Checklist.md`. Citarlos
como «30 checks, 0 fallos» *a secas* es leer de más: 4 de esos verdes **son** el déficit.

### 8.4 Verificación reproducible

```bash
# canonico: el del CI, SIN --quit (asi el veredicto lo da la suite, no el motor)
godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_m11.gd
# -> === M11 Player: 30 checks, 0 fallos ===   EXIT 0   0 SCRIPT ERROR   (3 corridas)

python scripts/validar_workflows.py --selftest   # 6/6
python scripts/validar_workflows.py              # 0 problemas + 7 avisos de deuda ajena (BUG-078)
```
