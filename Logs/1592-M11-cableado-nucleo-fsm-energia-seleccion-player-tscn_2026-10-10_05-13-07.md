# Log 1592 - M11 - Cableado del nucleo (FSM + energia + seleccion) al nodo del jugador

- **Modulo:** 11-Personaje-Del-Jugador
- **Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Fecha:** 2026-10-10
- **Encargo:** mensaje 139 del director (atria-dawn / Kilo Code): "player.gd YA ESTA LIMPIO: cablea el nucleo a Player.tscn AHORA".
- **Restricciones:** sin commit, sin push; UTF-8 sin BOM; READ-ONLY sobre marcas ajenas.

## 1. Contexto y premisa medida

- El director confirma el cierre de la iteracion del nucleo M11 (docs aceptados) y desbloquea el
  cableado: `player.gd` limpio en HEAD (`c5cdb37`, s2: integracion M156 + inventario reparado).
- `Player.tscn` traia un cambio AJENO sin commitear (nodo `TerrainDetector` de M156, mtime
  2026-10-09 18:19). No se toco: el cambio propio es ADITIVO encima.
- `player.gd` NO se edito (ver seccion 4).

## 2. Que se hizo

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/player/player_core_m11.gd` | NUEVO. Nodo (`extends Node`, sin `class_name`) hijo de `Player`. Instancia PlayerFSM/PlayerEnergy/CharacterSelector y los alimenta cada frame desde el CharacterBody3D padre por duck-typing (`velocity`, `_on_ground`, `_en_agua()`). Expone estado/energia/personaje + hooks. |
| `game/isla-ancestral/scenes/player/Player.tscn` | Nodo `NucleoM11` (ext_resource `4_core_m11`); `load_steps` 5 -> 6. Preserva el nodo `TerrainDetector` ajeno. |
| `game/isla-ancestral/scripts/player/test_player_cableado_m11.gd` | NUEVO. Suite headless del cableado (5 bloques A-E). |
| `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/04-Codigo.md` | Seccion 9.6 (cableado) + puntero en 9.5. CRLF preservado. |

## 3. Evidencia medida (Godot 4.7.2 headless)

- Suite de cableado: `=== M11 Cableado: 49 checks, 0 fallos ===`, EXIT 0, 0 SCRIPT ERROR, x3
  (49 = A9 + B9 + C13 + D10 + E8). Piso `CHECKS_MINIMOS=49` MEDIDO (no estimado).
- Guardian probado EN ROJO (sondas en scratch gitignored `_wb_cab.tmp/`, borrado):
  - P1 piso 50 -> `[FALLO] solo 49 checks ejecutados (minimo 50)` | EXIT 1.
  - P2 aborto de runtime al inicio del bloque C -> `SCRIPT ERROR ...` +
    `[FALLO] Bloque faltante: C` + `solo 37 checks ... (minimo 49)` | 2 fallos | EXIT 1.
- `--check-only` del adaptador y de la suite: rc=0, sin warnings.
- Regresiones (todas EXIT 0, 0 SCRIPT ERROR):
  - `test_player_core_m11.gd` 87/0 (nucleo).
  - `test_player_m11.gd` 30/0 (invariantes B6/B7 intactos).
  - `test_terrenos_integracion.gd` 39/0 (instancia Player.tscn).
  - `tests/test_bug125_bug126_fix.gd` rc=0 (instancia Player.tscn).
- Bytes: los 3 archivos tocados/creados = sin BOM, LF puro, NUL=0, U+FFFD=0.

## 4. Decision de diseno: adaptador aditivo, NO se edito player.gd

- `test_player_m11.gd` tiene invariantes INVERTIBLES B6/B7 que afirman que el jugador NO expone
  metodos `stamina`/`fsm`. Meter la FSM dentro de `player.gd` las romperia (senal de "hay que
  invertir el check", no una regresion) y mezclaria trabajo propio con un archivo compartido
  recien limpiado por s2.
- El nodo adaptador es hijo de Player: los deja intactos (verificado: 30/0).

## 5. Alcance honesto: que esta VIVO y que es HOOK

- FSM: VIVA. IDLE/WALK/JUMP/FALL/SWIM se derivan del runtime real (bloque B de la suite).
- Energia: corre cada frame (regen 1/min clampeada al maximo). El DRENADO (correr / herramientas)
  NO se ejercita hoy: `player.gd` NO tiene sprint. El adaptador expone `marcar_corriendo()` y
  `consumir_energia(costo)` como HOOKS (el director pidio coordinar hooks, no reconstruirlos).
  El estado RUN y el drenado se ejercitan en la suite via el hook (bloque C).
- Selector: VIVO (seleccion + serializar/deserializar).

## 6. Pendiente / pedido al director

1. Sprint: decidir si M11 agrega sprint (LShift, 6.5 m/s segun 05-Checklist L36/L51) y cablea
   `marcar_corriendo()` en `player.gd`. Sin sprint, la energia no drena en el juego real.
2. `04-Codigo.md` 9.5 quedo con puntero a 9.6 (no se borro el texto historico).
3. Flips de 05-Checklist: NO se toco ninguna marca (53 [x] / 70 [?] / 0 [ ] = 123). Los items
   de FSM/energia (L49-L64, L90, L97, L134) pasan de "NO implementado (sin FSM/stamina)" a
   "cableado parcialmente": decide el director.
4. Commits locales de M11 (`8125a9f`, etc.) siguen sin push (el director centraliza).

## 7. Notas de numeracion

- Pool de Logs: cabeza medida JUSTO antes = 1591; el helper consumio 1592 (1591 ya tenia log
  propio, `1591-m105-explorado...`). Cabeza final = 1593.
- Colisiones AJENAS reportadas por `reservar_log.py --estado` (NO tocadas): 1290, 1468, 1547,
  1559, 1585.
- Pool de mensajes de mi canal: ver el canal 140 (reservado aparte).

- DeepSeek-V4.1-Flash / WorkBuddy
