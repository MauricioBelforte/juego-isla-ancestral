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
- **6 scripts previstos no existen** (diagnóstico original — ver actualización abajo): `player_controller.gd`, `player_fsm.gd`,
  `interaction_service.gd`, `light_collector.gd`, `player_energy.gd` y
  `character_selector.gd`; `terrain_detector.gd` existe fuera de M11, en `scripts/terrain/`.
  Los 3 `.tres` previstos tampoco existen y `data/player/` no existe.
  > **Actualizado 2026-10-16 (GLM-5.3-Flash, encargo del director — evidencia agnes msg 487, verificada con `git ls-files`):** 3 de los 6 ya EXISTEN en `game/isla-ancestral/scripts/player/`: **`player_fsm.gd`, `player_energy.gd` y `character_selector.gd`** (implementados, ver tabla de archivos más abajo; junto a `player_core_m11.gd` y el módulo de equipamiento M155). Siguieron sin existir: `player_controller.gd`, `interaction_service.gd` y `light_collector.gd` (0 hits en el repo). `terrain_detector.gd` sigue fuera de M11 (ahora en `scripts/terrain/` y `scripts/terrenos/`).
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

## 9. Núcleo aditivo de M11 — FSM, energía y selección (2026-10-10 — Log 1576, DeepSeek-V4.1-Flash)

### 9.1 Corrección de premisa (medida antes de escribir)

El mensaje 133 del director asigna «M11-Sistema-De-Combate». La medición dice otra cosa:

| Premisa del mensaje 133 | Medición |
|---|---|
| «M11-Sistema-De-Combate» | `CHECKLIST-GLOBAL.md:89` → **`11-Personaje-Del-Jugador`** (Alta, complejidad 4). El combate de **M164** depende de M11, pero **M11 no es un módulo de combate**: su `05-Checklist.md` no tiene sección de combate (A–J son físicas / FSM / interacción-luz / energía-bienestar / animación-audio / documentación / verificación / selección / terrenos). |
| «53/123 con 70 `[ ]`» | **`53 [x]` / `70 [?]` / `0 [ ]` = 123.** El conteo 53/123 es correcto; el glifo es **`[?]`**, no `[ ]`: **0 huecos reales**. |
| Dueño | La fila ya dice `DeepSeek-V4.1-Flash` (reasignado P-14, Log 1130). |

### 9.2 Decisión de alcance: núcleo ADITIVO, `player.gd` intacto

`player.gd` está **sucio por un refactor ajeno no commiteado** (M156): `git diff HEAD --numstat` = `42/13`, y **borró `_equip_speed_mult`**. Por eso:

- **NO** se reimplementa la FSM dentro de `player.gd`: mezclaría trabajo propio con ajeno y rompería la suite existente (su bloque C5 accede a `_equip_speed_mult` → `SCRIPT ERROR` contra el worktree).
- El núcleo va en **3 scripts nuevos aditivos** (`RefCounted`, sin escena ni autoload):

| Archivo | Qué modela | Sección del checklist |
|---|---|---|
| `scripts/player/player_fsm.gd` | FSM pura: 11 estados, permisos, grafo de transiciones validado, `derivar(snapshot)` | C (FSM) |
| `scripts/player/player_energy.gd` | Energía cozy: correr 1/min, regen 1/min **siempre** → balance neto 0/min, fatiga al 30%, auto-descanso, sin deuda permanente | E (energía/bienestar) |
| `scripts/player/character_selector.gd` | Catálogo de 6 personajes (todos con stats iguales), selección, serialización | I (selección) |

### 9.3 Contratos publicados (modelo puro, aún NO cableados al runtime)

- `PlayerFSM.derivar(snapshot: Dictionary) -> int` — estado derivado; prioridad sleep/craft/interact > agua(aire) > aire(salto/caída) > suelo.
- `PlayerFSM.transicionar(destino) -> bool` — única vía validada de cambio explícito; **rechaza** transiciones no declaradas (no hay «estados imposibles»).
- `PlayerFSM.permite(accion) -> bool` — fail-closed.
- `PlayerEnergy.actualizar(delta, corriendo, en_movimiento) -> bool`; `puede_correr()`; `recargar_dormir()` (+100%); `recargar_descanso()` (+30%). Constantes: `COSTO_CORRER_POR_MINUTO = 1.0` y `REGEN_POR_MINUTO = 1.0` (regen **siempre**, incluso en movimiento) → **balance neto 0/min** (ver §9.4, D1 resuelta).
- `CharacterSelector.serializar()/deserializar(data)`.

### 9.4 Divergencias de diseño — D1 RESUELTA; D2/D3 reportadas

El director advirtió: *«si el diseño y el código divergen, reporta la divergencia, no la resuelvas tú»*. Medidas:

| # | Divergencia | Fuentes (medidas) | Qué hizo el núcleo |
|---|---|---|---|
| **D1** | **Ritmo de energía ×720.** `03-Diseno.md:18` → `DRAIN_RUN = 12/s` y `REGEN = 8/s`; `01-Requerimientos.md:63,66` → correr `1/minuto` y regen `1/minuto`. Además `01-Requerimientos.md:70` fija la regla cozy *«la energía NUNCA llega a cero por caminar o correr»*, que los valores de `03-Diseno` **contradicen** (100 / 12 = 8,3 s corriendo para agotar). | 03-Diseno §1 vs 01-Requerimientos §6.1 | **RESUELTA por el director (msg 137): gana `01-Requerimientos`.** El núcleo usa `COSTO_CORRER_POR_MINUTO = 1.0` y `REGEN_POR_MINUTO = 1.0` (regen **siempre**, L66) → **balance neto 0/min**: la energía **no baja** por caminar/correr (solo por herramientas, M13). La suite afirma 1/min y el neto 0 (ver nota debajo). |
| **D2** | **Nº de estados.** `01-Requerimientos.md:23` (RF4) lista **9** (idle, run, sprint, jump, swim, dive, interact, sleep, craft — sin WALK/FALL/SURFACE); `03-Diseno.md:25-32` (§2) enumera **11**; `03-Diseno.md:101` dice «10 clips». El histórico del QA habla de «FSM de 10 estados». | 01-Req §2 vs 03-Diseno §2/§7 | Implementa los **11** de `03-Diseno §2` (el documento técnico del módulo). |
| **D3** | **Rango de interacción.** `03-Diseno.md:20` → `RANGO_INTERAC = 4 m`; el `interaction_manager.gd` real (M70) usa `DEFAULT_RANGO := 2.5`. | 03-Diseno §1 vs 04-Codigo §2 | No se toca (es M70). Ya documentado; se repite aquí por completitud. |

> **Nota de diseño (D1) — por qué L70 emerge estructuralmente.**
> La regla cozy de `01-Requerimientos.md:70` («la energía NUNCA llega a cero por caminar o
> correr») **no es un clamp cosmético**: emerge de las constantes. Correr cuesta `1/min` y la
> regeneración es `1/min` **siempre** (incluso en movimiento, L66) → el balance de correr es
> **neto 0/min**. El próximo agente que toque estas constantes debe entender que **no puede subir
> `COSTO_CORRER_POR_MINUTO` sin bajar `REGEN_POR_MINUTO`** (o volver condicional la regen al
> movimiento): hacerlo **violaría L70** — la energía empezaría a bajar por correr. Los checks
> B14/B15 de la suite (correr 100 min desde el máximo → energía `> 0` **y `== 100`**) fijan ese
> caso extremo y delatan cualquier clamp mágico que se introduzca.

### 9.5 Qué NO cubre este núcleo

No cablea nada a `Player.tscn`: no hay HUD de stamina, no hay consumo del snapshot desde el jugador real, no hay persistencia en `GameState`, no hay animación/audio. Es **modelo + contrato** — la parte verificable sin tocar el archivo sucio ajeno. La integración con el runtime sigue pendiente (dueño: M11, tras resolverse D2).


> **Actualización (§9.6, 2026-10-10 — Log 1592):** el cableado aditivo al nodo del jugador ya está
> implementado (FSM viva, energía corriendo por frame, selector con persistencia). Lo que sigue
> pendiente del runtime es el **sprint** (input `correr`), el HUD de stamina (M53) y la persistencia
> en M59. El texto de arriba se conserva como estado histórico de la iteración del núcleo.

### 9.6 Cableado del núcleo al nodo del jugador (2026-10-10 — Log 1592, DeepSeek-V4.1-Flash)

`player.gd` quedó limpio (commit `c5cdb37`, s2: integración M156 + inventario reparado). Con el
bloqueo resuelto, el núcleo se cablea de forma **aditiva** — **sin editar `player.gd`**:

| Archivo | Rol |
|---|---|
| `scripts/player/player_core_m11.gd` | Nodo (`extends Node`, **sin `class_name`**) **hijo de `Player`** en `Player.tscn` (nodo `NucleoM11`). Instancia la FSM, la energía y el selector, y los alimenta cada frame de física desde el `CharacterBody3D` padre por **duck-typing** (`velocity`, `_on_ground`, `_en_agua()`). Expone estado/energía para el HUD (M53) y la selección para la persistencia (M59). |
| `scripts/player/test_player_cableado_m11.gd` | Suite headless: **49 checks / 0 fallos / EXIT 0 ×3**, piso `CHECKS_MINIMOS=49` MEDIDO; guardián probado **en rojo** (P1 piso+1 → EXIT 1; P2 aborto de runtime en el bloque C → nombra el bloque + EXIT 1). |

**Qué está VIVO (medido) y qué es HOOK:**

- **FSM: viva.** IDLE/WALK/JUMP/FALL/SWIM se derivan del runtime real (velocidad + `_on_ground` del
  padre); bloque B de la suite.
- **Energía: corre cada frame** (regen 1/min clampeada al máximo). El **drenado** (correr /
  herramientas) NO se ejercita hoy porque `player.gd` **no tiene sprint**: el adaptador expone
  `marcar_corriendo()` y `consumir_energia(costo)` como **hooks**, sin inventar un sprint (el
  director pidió coordinar los hooks, no reconstruirlos). El estado RUN y el drenado se ejercitan en
  la suite vía el hook.
- **Selector: vivo** (selección + `serializar`/`deserializar`).

**Por qué NO se editó `player.gd`:** su suite (`test_player_m11.gd`) tiene invariantes **invertibles**
B6/B7 que afirman que el jugador NO expone métodos `stamina`/`fsm`; meter la FSM dentro de `player.gd`
las rompería (señal de "invertir el check", no una regresión) y mezclaría trabajo propio con un
archivo compartido recién limpiado. El nodo adaptador las deja intactas (verificado: 30/0).

> **Actualización (§9.7, 2026-10-10 — Log 1594):** el **sprint** ya está implementado en el adaptador
> (autorizado por el director en el canal 141, que aceptó el cableado 49/0). El texto de §9.6 se
> conserva como estado de la iteración del cableado (Log 1592). Lo que sigue **pendiente** del
> runtime es el HUD de stamina (M53), la persistencia en M59 y los hooks de telemetría (s2,
> **encolados** por el director para no pisarse sobre `Player.tscn`).

### 9.7 Sprint en el adaptador — drenado real y L70 estructural (2026-10-10 — Log 1594, DeepSeek-V4.1-Flash)

Autorizado por el director (canal **141**): «Agregá sprint a `player_core_m11.gd` (LShift, ~6.5 m/s)
— **en el adaptador, NO en `player.gd`**», «Cableá `marcar_corriendo()` al drenado de energía
(`COSTO_CORRER_POR_MINUTO = 1.0`)», «Verificá que **L70 se mantiene estructural**», «Suite nueva o
extender la existente con checks de sprint + drenado».

**Implementación (todo dentro de `scripts/player/player_core_m11.gd`; `player.gd` intacto):**

- **Constantes de diseño** (`03-Diseno.md` §1 / `05-Checklist` L35-L36): `VELOCIDAD_CAMINAR := 4.2`,
  `VELOCIDAD_CORRER := 6.5`, `FACTOR_SPRINT := VELOCIDAD_CORRER / VELOCIDAD_CAMINAR` (≈ **1.548**).
- **Entrada**: `leer_sprint()` usa la acción `correr` del InputMap **si existiera**; hoy **no existe**
  (medido: `project.godot` no la declara), así que cae a `Input.is_key_pressed(KEY_SHIFT)` — **LShift**
  directo, como `player.gd` sondea el resto de sus teclas. En headless se fuerza con el hook
  `forzar_sprint_test(0|1|-1)` (no se inyectan `InputEventKey` en modo `--script`).
- **Gate del sprint** (un tic en `actualizar()`): `quiere_correr = _corriendo (hook) OR leer_sprint()`;
  el sprint **efectivo** exige además **movimiento** (`magnitud_direccion ≥ 0.1`), **permiso de la FSM**
  (`fsm.permite("correr")` → no corre en JUMP/SWIM/…) y **energía disponible** (`energia.puede_correr()`).
- **Velocidad**: `_aplicar_velocidad_sprint()` **escala** el `move_speed` del padre por `FACTOR_SPRINT`
  (capturando la base la 1ª vez) y la **restaura** al soltar. Se escala — **no** se fija a 6.5 — para
  **preservar** el multiplicador por terreno y por equipamiento (M156/M13) que `player.gd` ya aplica en
  `_current_effective_speed`. Es el **único** campo que el adaptador escribe; la API pública de `Player`
  no cambia.
- **Drenado**: `marcar_corriendo()` se OR-ea con el input y entra al mismo gate; con el sprint efectivo,
  `PlayerEnergy.actualizar()` ejerce el costo (`COSTO_CORRER_POR_MINUTO = 1.0`).
- **L70 se mantiene ESTRUCTURAL** (no clamp): costo 1/min + regen 1/min (la regen corre **siempre**) =
  **balance neto 0/min** → correr **no** baja la energía. Medido: correr **100 min** deja la energía
  **exactamente** donde estaba (50.0) y **nunca** agota (bloque G3/G4). El gasto real solo entra por
  `consumir_energia()` (herramientas, M13). No se forzó nada para que el neto diera 0: es consecuencia
  de las constantes del modelo (D1, §9.4).

**Suite** (`scripts/player/test_player_cableado_m11.gd`, extendida con los bloques **F** y **G**):
**71 checks / 0 fallos / EXIT 0 ×3**, piso `CHECKS_MINIMOS = 71` **MEDIDO** (9 A + 9 B + 13 C + 10 D +
8 E + 13 F + 9 G). Guardián re-probado **en rojo**: P1 (piso+1 → 71/1, EXIT 1) y P2 (aborto de runtime
tras el bloque A → nombra B/C/D/E/F/G faltantes + fallo de piso, EXIT 1). El bloque F cubre input,
constantes, estado RUN, `corriendo()`, `factor_velocidad()`, `base_move_speed()` y el escalado/restauro
de `move_speed`; el bloque G cubre el **drenado aplicado** (correr 60 s da 50, no 51 → el costo se
aplica) y **L70 estructural**.

**Regresiones (todas EXIT 0):** `test_player_core_m11` 87/0 · `test_player_m11` 30/0 ·
`test_terrenos_b3` 28/0 · `test_terrenos` 27/0 · `test_terrenos_integracion` 39/0.

