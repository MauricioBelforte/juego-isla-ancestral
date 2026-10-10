# Log 1576: M11 (Personaje del Jugador) — núcleo aditivo FSM + energía + selección; suite 81/0; 3 divergencias de diseño reportadas

**Fecha:** 2026-10-10
**Hora:** 01:55
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

## Resumen

Encargo del mensaje 133 (canal DeepSeek, atria / Kilo Code): «M11-Sistema-De-Combate», 53/123 con
70 `[ ]`, READ-ONLY sobre marcas, `--check-only` antes de entregar, sin commits/push, UTF-8 sin BOM.
Se midió la premisa, se implementó un **núcleo aditivo** (FSM + energía + selección) **sin tocar
`player.gd`** (sucio por refactor ajeno M156), con **suite headless 81/0** probada en rojo por 2
sondas. **No se flipó ninguna marca.** Se reportan 3 divergencias de diseño (no se resuelven).

## Correcciones de premisa (medidas)

| Premisa del msg 133 | Medición |
|---|---|
| «M11-Sistema-De-Combate» | `CHECKLIST-GLOBAL.md:89` -> `11-Personaje-Del-Jugador` (Alta). M11 **no** es módulo de combate; M164 (Isla De Combate) depende de M11. |
| «53/123 con 70 `[ ]`» | `53 [x] / 70 [?] / 0 [ ]` = 123. El conteo es correcto; el glifo es `[?]` (0 huecos reales). |
| dueño | La fila ya dice DeepSeek-V4.1-Flash (reasignado P-14). |

## Cambios realizados (4 archivos nuevos de código, 3 docs)

### Código nuevo (aditivo, `RefCounted`, sin tocar `player.gd`)
- `game/isla-ancestral/scripts/player/player_fsm.gd` (7453 B) — FSM pura: 11 estados, tabla de
  PERMISOS, TRANSICIONES validadas, `derivar(snapshot)`, `permite()`, `transicionar()` (rechaza
  transiciones no declaradas), `AIRE_UMBRAL_SURFACE = 0.20`.
- `game/isla-ancestral/scripts/player/player_energy.gd` (4123 B) — energía cozy: `DRENADO_CORRER`
  12/s, `REGEN_PARADO` 8/s, `UMBRAL_FATIGA` 30, auto-descanso, `sin_deuda_permanente()`.
- `game/isla-ancestral/scripts/player/character_selector.gd` (3360 B) — 6 personajes (stats
  iguales), `seleccionar()`, `serializar()/deserializar()`.
- `game/isla-ancestral/scripts/player/test_player_core_m11.gd` (13574 B) — suite 81 checks,
  guardián de 3 capas.

### Docs actualizados (M11)
- `04-Codigo.md` §9 (nuevo): premisa, decisión de alcance, contratos, divergencias D1/D2/D3,
  alcance no cubierto.
- `06-Plan-Testings.md` §5 (nuevo): alcance y guardianes de la suite nueva.
- `07-Resultados-Testings.md` §6 (nuevo): control 3 corridas, sondas rojas, `--check-only`,
  higiene de bytes, baseline roja.
- `05-Checklist.md`: **NO TOCADO** (READ-ONLY sobre marcas; 53/70/0 sin cambio).

## Mediciones (herramientas reales)

### Suite nueva (3 corridas, comando del CI sin `--quit`)
```
=== M11 Nucleo: 81 checks, 0 fallos ===   EXIT 0   0 SCRIPT ERROR
[FIN] bloque A (+33) B (+22) C (+20) D (+6)
```

### Guardianes probados en rojo (sondas)
- P1 `CHECKS_MINIMOS := 82` -> `[FALLO] solo 81 checks ejecutados (minimo 82): aborto parcial`, EXIT 1.
- P2 aborto en runtime al inicio del bloque C -> `[FALLO] Bloque faltante: C` + `solo 62 checks`,
  2 fallos, EXIT 1.
Sondas en `game/isla-ancestral/_wb_m11.tmp/` (verificado gitignored), borradas; control posterior verde.

### `--check-only` (requisito del director)
4/4 archivos rc=0, sin errores.

### Higiene de bytes
Los 4 `.gd` UTF-8 sin BOM, LF puro, 0 `U+FFFD`. Los 3 docs de M11 en CRLF (worktree), como estaban.

### Baseline (hallazgo, no regresión propia)
`test_player_m11.gd` -> `30 checks, 1 fallos, EXIT 1`, `[FALLO] Bloque faltante: C`. Causa: su bloque
C5 accede a `_equip_speed_mult`, borrado del `player.gd` del worktree por el refactor ajeno M156
(`HEAD`=5, worktree=0). CI verde en checkout limpio, worktree rojo. **Reportado, no tocado.**

## Divergencias de diseño REPORTADAS (no resueltas)
- **D1** energía: `03-Diseno.md:18` (12/s drain, 8/s regen) vs `01-Requerimientos.md:63,66`
  (1/minuto). Además `01-Requerimientos.md:70` fija la regla cozy «la energía NUNCA llega a cero por
  caminar o correr», que el 12/s **contradice** (100/12 = 8,3 s). Factor ×720.
- **D2** estados: `01-Req` RF4 (9) vs `03-Diseno` §2 (11) vs §7 (10 clips).
- **D3** rango de interacción: `03-Diseno` 4 m vs `interaction_manager.gd` real 2.5 m (M70).

## Colisión de pool ajena nueva (reportada, no tocada)
`reservar_log.py --estado` reporta **4** colisiones: 1290, 1468, 1547 (ya conocidas) + **1559 (NUEVA)**:
`1559-m100-bloque-3-170-221-11-flips_2026-10-10_03-10.md` y
`1559-qa-21-8-m156-94-checks-0-fallos-sellable-2026-10-10_00-52-00.md`.

## Archivos Modificados/Creados
- (código) los 4 `.gd` nuevos de arriba.
- (docs) `04-Codigo.md`, `06-Plan-Testings.md`, `07-Resultados-Testings.md` de M11.
- `Logs/1576-M11-nucleo-aditivo-fsm-energia-seleccion-81-checks-3-divergencias_2026-10-10_01-55-40.md` (este).
- Informe en el canal DeepSeek (mensaje siguiente).

## Pendiente
- Decisión del director sobre **D1/D2** (bloquea cablear el núcleo al runtime).
- Cableado real a `Player.tscn` (tras D1/D2).
- Baseline roja del worktree (refactor ajeno M156): decidir quién la resuelve.
- Sin commit/push (no autorizado).

## Firmas
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-10 01:55
