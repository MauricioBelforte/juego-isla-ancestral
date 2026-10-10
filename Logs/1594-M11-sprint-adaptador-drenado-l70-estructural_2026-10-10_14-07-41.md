# Log 1594 - M11 - Sprint en el adaptador: drenado real y L70 estructural

- **Modulo:** 11-Personaje-Del-Jugador
- **Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Fecha:** 2026-10-10
- **Encargo:** mensaje 141 del director (atria-dawn / Kilo Code): sprint SI, "en el adaptador, NO en player.gd".
- **Restricciones:** sin commit, sin push; UTF-8 sin BOM; READ-ONLY sobre 05-Checklist / CHECKLIST-GLOBAL / player.gd; no tocar multiplicadores M13.

## 1. Contexto y alcance autorizado

- El director ACEPTO el cableado M11 (49/0) y autorizo el sprint (canal 141):
  1. agregar sprint a `player_core_m11.gd` (LShift, ~6.5 m/s) EN EL ADAPTADOR;
  2. cablear `marcar_corriendo()` al drenado de energia (COSTO_CORRER_POR_MINUTO = 1.0);
  3. verificar que L70 sigue ESTRUCTURAL (costo 1/min - regen 1/min = neto 0/min); si el sprint rompe el neto 0, parar y reportar;
  4. suite nueva o extender la existente con checks de sprint + drenado.
- Lo que NO tocar: `player.gd`; multiplicadores de equipamiento (M13) si el sprint los necesitara.
- Flips de `05-Checklist` (L49-L64, L90, L97, L134): decision del director.

## 2. Que se hizo

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/player/player_core_m11.gd` | Sprint aditivo: constantes VELOCIDAD_CAMINAR=4.2 / VELOCIDAD_CORRER=6.5 / FACTOR_SPRINT=6.5/4.2; metodos `leer_sprint()`, `forzar_sprint_test()`, `corriendo()`, `factor_velocidad()`, `velocidad_sprint()`, `base_move_speed()`, `_aplicar_velocidad_sprint()`; `actualizar()` reescrito con el gate del sprint. |
| `game/isla-ancestral/scripts/player/test_player_cableado_m11.gd` | Bloques F (sprint: input, constantes, estado RUN, velocidad) y G (drenado aplicado + L70 estructural). BLOQUES_ESPERADOS A..G; piso CHECKS_MINIMOS=71 MEDIDO. |
| `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/04-Codigo.md` | Seccion 9.7 (nueva) + nota de actualizacion al final de 9.6. CRLF preservado. |

## 3. Diseno del sprint (dentro del adaptador)

- Entrada: `leer_sprint()` usa la accion `correr` del InputMap SI EXISTIERA; MEDIDO: `project.godot` NO la declara -> cae a `Input.is_key_pressed(KEY_SHIFT)` (LShift directo, como sondea player.gd).
- En headless no hay teclado: se fuerza con `forzar_sprint_test(0|1|-1)` (no se inyectan InputEventKey en modo --script).
- Gate (por tic): `quiere_correr = _corriendo (hook) OR leer_sprint()`; el sprint EFECTIVO exige ademas MOVIMIENTO (magnitud_direccion >= 0.1), permiso de la FSM (`fsm.permite("correr")`) y energia (`energia.puede_correr()`).
- Velocidad: `_aplicar_velocidad_sprint()` ESCALA `move_speed` del padre por FACTOR_SPRINT (captura la base la 1a vez) y la RESTAURA al soltar. Se ESCALA (no se fija a 6.5) para PRESERVAR el multiplicador por terreno/equipo que player.gd ya aplica en `_current_effective_speed`. UNICO campo escrito; la API publica de Player no cambia.
- Drenado: con el sprint efectivo, `energia.actualizar(delta, true, en_mov)` ejerce el costo (1/min).

## 4. L70 se mantiene ESTRUCTURAL (medido, no clamp)

- Costo 1/min + regen 1/min (la regen corre SIEMPRE) = balance NETO 0/min -> correr NO baja la energia.
- Medido (bloque G): desde 50, correr 60 s -> 50 (si el sprint NO estuviera cableado daria 51); correr 100 min -> 50 exacto, nunca agota.
- No se forzo nada para que el neto diera 0: es consecuencia de las constantes del modelo (D1, 04-Codigo 9.4). El sprint NO lo rompio -> no hubo que parar ni reportar bloqueo.

## 5. Evidencia medida (Godot 4.7.2 headless)

- Suite del cableado: `=== M11 Cableado: 71 checks, 0 fallos ===`, EXIT 0, 0 SCRIPT ERROR, x3 (71 = A9 + B9 + C13 + D10 + E8 + F13 + G9). Piso CHECKS_MINIMOS=71 MEDIDO (no estimado: estime 69 y el real fue 71).
- Guardian re-probado EN ROJO:
  - P1 piso+1 (72) -> `[FALLO] solo 71 checks ejecutados (minimo 72)` | 71 checks, 1 fallos | EXIT 1.
  - P2 aborto de runtime tras el bloque A -> `!! _run() NO llego al final` + `[FALLO] Bloque faltante: B/C/D/E/F/G` + `solo 15 checks (minimo 71)` | 15 checks, 8 fallos | EXIT 1.
  - Ambas inyecciones REVERTIDAS; corrida final 71/0 EXIT 0.
- `--check-only` del adaptador: rc=0.
- Regresiones (todas EXIT 0, 0 SCRIPT ERROR):
  - `test_player_core_m11.gd` 87/0 (nucleo).
  - `test_player_m11.gd` 30/0 (invariantes B6/B7 intactos). NOTA: figuraba como baseline roja (30/1, bloque C5 por `_equip_speed_mult`); hoy el worktree la da VERDE.
  - `test_terrenos_b3.gd` 28/0; `test_terrenos.gd` 27/0; `test_terrenos_integracion.gd` 39/0.
- AJENA / pre-existente (NO mia): `test_equipment_m155.gd` 3 fallos (slot feet inicializado / skates en pavement / skates en mud). Probado CON y SIN mis cambios (stash de mis 2 archivos): IDENTICO -> no es mia (M155, otro dueno).
- Bytes: archivos escritos = sin BOM, NUL=0, U+FFFD=0; .gd y 04-Codigo.md en CRLF (worktree).

## 6. Que NO se toco

- `player.gd` (no editado; el sprint solo ESCALA su `move_speed` por duck-typing).
- `05-Checklist.md` de M11: 0 marcas tocadas (los flips son del director).
- `CHECKLIST-GLOBAL.md`, `quality.yml`: no tocados.
- Multiplicadores M13: no reimplementados (no hicieron falta: se escala la base que ya los incluye).
- Hooks de telemetria (s2): encolados por el director; no entre.

## 7. Notas de numeracion

- Pool de Logs: cabeza medida JUSTO antes = 1594; el helper consumio 1594 (sin archivo de reserva, protocolo v3). Al cerrar, la cabeza es 1596 (el 1595 lo tomo otro agente: `1595-m145-qa-21-8-amarillo-15-m114`).
- Colisiones AJENAS reportadas por `reservar_log.py --estado` (NO tocadas): 1290, 1468, 1547, 1559, 1585.
- Colision AJENA en MI canal de mensajes: DOS archivos `139-*` (ambos `atria-a-deepseek`, mismo timestamp 2026-10-10_04-34-17). Reportada, no tocada.
- Pool de mensajes de mi canal: cabeza 142 -> reserve 142 (archivo `142-2026-10-10_14-07-41-deepseek-a-atria-m11-sprint-adaptador-drenado-l70-estructural-suite-71.md`).

- DeepSeek-V4.1-Flash / WorkBuddy
