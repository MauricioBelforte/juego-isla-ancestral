# Log 1582: M11 — D1 ejecutado (energía 1/minuto), suite 87/0, L70 estructural

**Fecha:** 2026-10-10
**Hora:** 02:32
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

## Resumen

El director respondió al mensaje 134 (msg **135**): aceptó las 2 correcciones de premisa y el núcleo
aditivo, y resolvió las divergencias — **D1: 1/minuto gana**, **D2: 11 estados** (sin cambios),
**D3: no es mío (M70)**. Derivó M156/`player.gd` a s2. Ejecuté D1: cambié las constantes de energía
a 1/minuto, re-corrí la suite (**81 → 87 checks, 0 fallos**), y re-probé el guardián en rojo.

## Cambios realizados

### `game/isla-ancestral/scripts/player/player_energy.gd`
- `COSTO_CORRER_POR_MINUTO = 1.0` (01-Req L63), `REGEN_POR_MINUTO = 1.0` (01-Req L66).
- Eliminadas `DRENADO_CORRER = 12`, `REGEN_PARADO = 8`, `REGEN_CAMINANDO = 4`.
- Nuevos helpers de contrato: `regen_por_segundo()`, `costo_correr_por_segundo()`.
- **L70 estructural:** regen 1/min SIEMPRE (también corriendo) + costo correr 1/min = balance neto
  0/min → la energía NO puede bajar por correr/caminar. Solo baja por herramientas (M13).
- Interpretación reportada al director (si quería neto −2/min, hace falta un piso > 0; no lo inventé).

### `game/isla-ancestral/scripts/player/test_player_core_m11.gd`
- Bloque B reescrito: 22 → **28 checks** (constantes 1/min, conversión 1/60, regen siempre, neto 0,
  **L70: correr 100 min no agota**, fatiga, dormir/descanso, clamp, delta<=0).
- `CHECKS_MINIMOS`: 81 → **87** (medido). Total: A+33 B+28 C+20 D+6 = 87.

### NO tocados
- `player_fsm.gd` (D2 = 11 estados, sin cambio), `character_selector.gd`, `player.gd` (sucio ajeno).
- `04-Codigo.md` / `06-Plan-Testings.md` / `07-Resultados-Testings.md`: **NO los toqué** porque el
  director dijo «yo actualizo los docs de M11». **OJO: quedan 3 puntos stale** (§9.4 fila D1 con
  12/s; §5.4 piso 81 y 12/s; §6.1/§6.2 con 81 checks y sondas 82/62). Listados en el reporte 136.
- `05-Checklist.md` NO tocado (READ-ONLY): 53/70/0 sin cambio.

## Mediciones

- Suite (comando del CI, sin `--quit`): `=== M11 Nucleo: 87 checks, 0 fallos ===` EXIT 0,
  0 SCRIPT ERROR, **x3**. Bloques A+33, B+28, C+20, D+6.
- Guardián EN ROJO (re-probado, el piso cambió): P1 (piso 88) → `[FALLO] solo 87 checks ejecutados
  (minimo 88)` EXIT 1; P2 (aborto runtime bloque C) → `SCRIPT ERROR … 'free' in base 'Nil'` +
  `[FALLO] Bloque faltante: C` + `solo 68 checks` EXIT 1. Sondas en `_wb_m11.tmp/` (gitignored),
  borradas; control posterior 87/0 EXIT 0.
- `--check-only`: 4/4 rc=0.
- Bytes: `player_energy.gd` 4958 B, `test_player_core_m11.gd` 14796 B — UTF-8 sin BOM, LF puro,
  0 `U+FFFD`.
- Pool logs: 4 colisiones, **todas ajenas** (1290 / 1468 / 1547 / 1559).

## Numeración / límites

- Log **1582** reservado (head 1582→1583). Mensaje **136** (canal DeepSeek, head 136→137).
- Tracker `.ultima-revision-deepseek.txt`: 133 → **136**.
- **Sin commit / sin push.** No toqué `quality.yml` ni `CHECKLIST-GLOBAL.md`.

## Pendiente (para el director)

1. Confirmar la interpretación de D1 (neto 0/min vs neto −2/min con piso).
2. Actualizar los 3 puntos stale de los docs M11 (§9/§5/§6) — o autorizarme a hacerlo.
3. Cablear el núcleo a `Player.tscn` sin tocar `player.gd` (o tras el commit de s2).

## Firmas

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-10 02:32
