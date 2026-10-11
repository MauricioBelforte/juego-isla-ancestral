**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-20
**Log:** 1130

# 07-Resultados-Testings.md — Módulo 11: Personaje del Jugador

## 1. Resultado de la suite (medido, 3 corridas)

Comando canónico (el del CI, **sin** `--quit`):

```bash
godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_m11.gd
```

| corrida | resultado | EXIT | `SCRIPT ERROR` |
|---|---|---|---|
| 1 | `=== M11 Player: 30 checks, 0 fallos ===` | 0 | 0 |
| 2 | `=== M11 Player: 30 checks, 0 fallos ===` | 0 | 0 |
| 3 | `=== M11 Player: 30 checks, 0 fallos ===` | 0 | 0 |

**Desglose por bloque** (suma 30, cuadra con el total del resumen):

```
[FIN] bloque A (+5 checks)
[FIN] bloque B (+10 checks)
[FIN] bloque C (+5 checks)
[FIN] bloque D (+4 checks)
[FIN] bloque E (+6 checks)
```

Godot 4.7.2.stable. Salida con `=== Bootstrap Completado ===` **antes** del resumen: los autoloads
ya están arriba cuando corre el `_run()` diferido (por eso se pudo eliminar el helper
`_esperar_autoloads()`, que era un no-op).

## 2. Guardianes probados EN ROJO (medición, no confianza)

| Sonda | Antes del fix | Después del fix |
|---|---|---|
| C — aborto al inicio de un helper de bloque | (el guardián ya funcionaba) | `[FALLO] Bloque faltante: C` · **26 checks / 2 fallos** · EXIT 1 |
| D — aborto dentro de `_run()`, **sin** `--quit` | **EXIT 124**: colgado 60 s, **sin veredicto** | **EXIT 1 en 4,6 s** · `[FALLO] Bloque faltante: A,B,C,D,E` + `solo 5 checks ejecutados (minimo 30)` |
| D — aborto dentro de `_run()`, **con** `--quit` | **EXIT 0** y **sin línea de resumen** = falso verde | **EXIT 1** con veredicto |

Las sondas eran archivos `_probe_m11_*.gd` temporales, **borrados** al terminar (`ls` posterior: no
existen; `git status` de la carpeta: sólo el archivo real).

**Un resultado negativo que se reporta tal cual:** la sonda de la **trampa 63** (aborto dentro de un
helper *anidado* cuyo bloque igual cierra) **no aplica a esta suite**: el helper inyectado no
contenía checks propios, así que el conteo no bajaba (30/0 sin cambios). No se infló el hallazgo
para justificar el piso; el piso se agregó igual porque fija el total publicado.

## 3. Gate de CI

`quality.yml:352` → `godot --headless --script scripts/player/test_player_m11.gd 2>&1 || FAIL=1`.

| medición | resultado |
|---|---|
| ¿el archivo estaba versionado? | **NO** (`git cat-file -e HEAD:` → no existe) → **BUG-078** |
| efecto de `godot --script <inexistente>` | **EXIT 1** (`File not found`) → el job queda **ROJO** en checkout limpio |
| estado tras el fix | versionado en `5ce3aa9`; `validar_workflows.py` ya no lo reporta como deuda |

## 4. Verificadores del repo

| comando | resultado |
|---|---|
| `python scripts/validar_workflows.py --selftest` | **6/6** fixtures |
| `python scripts/validar_workflows.py` | 0 problemas · **7 avisos** de deuda ajena (BUG-078: 5×M64, M116, M117) |
| `python scripts/verificar_checklist.py` | M11 ya **no** figura como inconsistencia (fila global alineada a `53/123`) |

## 5. Conclusión

La suite **pasa y ahora puede fallar de forma confiable**, pero **no es evidencia de que el módulo
esté implementado**: 4 de sus 30 checks afirman justamente que stamina, FSM, interacción y luz
**no existen**. Los 73 `[?]` siguen abiertos y siguen siendo la verdad del módulo.

## 6. Resultados de la suite del núcleo aditivo (2026-10-10 — Log 1576, DeepSeek-V4.1-Flash)

### 6.1 Control (3 corridas)

Comando canónico:

```bash
godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_core_m11.gd
```

| corrida | resultado | EXIT | `SCRIPT ERROR` |
|---|---|---|---|
| 1 | `=== M11 Nucleo: 87 checks, 0 fallos ===` | 0 | 0 |
| 2 | `=== M11 Nucleo: 87 checks, 0 fallos ===` | 0 | 0 |
| 3 | `=== M11 Nucleo: 87 checks, 0 fallos ===` | 0 | 0 |

Desglose por bloque (suma 87, cuadra con el resumen):

```
[FIN] bloque A (+33 checks)
[FIN] bloque B (+28 checks)
[FIN] bloque C (+20 checks)
[FIN] bloque D (+6 checks)
```

### 6.2 Guardianes probados EN ROJO (medición, no confianza)

| Sonda | Qué inyecta | Resultado medido |
|---|---|---|
| P1 | piso inflado a `CHECKS_MINIMOS := 88` | `[FALLO] solo 87 checks ejecutados (minimo 88): aborto parcial` · 1 fallo · EXIT 1 |
| P2 | aborto en runtime al inicio del bloque C (intermedio **sin tipo**, para que no lo cace el compilador) | `SCRIPT ERROR: Invalid call. Nonexistent function 'free' in base 'Nil'.` → `[FALLO] Bloque faltante: C` + `solo 68 checks…` · 2 fallos · EXIT 1 |

Las sondas se escribieron en `game/isla-ancestral/_wb_m11.tmp/` (**verificado gitignored**), se **borraron**, y una corrida de control posterior re-confirmó verde (87/0).

### 6.3 `--check-only` (requisito del director antes de entregar)

```
player_fsm.gd             rc=0   sin errores
player_energy.gd          rc=0   sin errores
character_selector.gd     rc=0   sin errores
test_player_core_m11.gd   rc=0   sin errores
```

### 6.4 Higiene de bytes (UTF-8 sin BOM; LF, convención de `.gd`)

| Archivo | bytes | BOM | CRLF | LF solo | `U+FFFD` |
|---|---|---|---|---|---|
| `player_fsm.gd` | 7453 | No | 0 | 182 | 0 |
| `player_energy.gd` | 4958 | No | 0 | 124 | 0 |
| `character_selector.gd` | 3360 | No | 0 | 95 | 0 |
| `test_player_core_m11.gd` | 14796 | No | 0 | 312 | 0 |

### 6.5 Línea base: la suite ORIGINAL está ROJA en el worktree (hallazgo, no regresión propia)

```
=== M11 Player: 30 checks, 1 fallos ===   EXIT 1
[FALLO] Bloque faltante: C
```

Causa: el bloque C5 de `test_player_m11.gd` accede a `instance._equip_speed_mult`, que **no existe en el `player.gd` del worktree** (lo borró el refactor ajeno M156). En `HEAD` sí existe (`git show HEAD:… | grep -c _equip_speed_mult` = 5; worktree = 0) → **CI verde en checkout limpio, worktree rojo**. No se tocó (READ-ONLY sobre un archivo sucio ajeno). **Reportado al director.**

### 6.6 Conclusión

El núcleo aditivo **pasa y puede fallar de forma confiable** (2 sondas rojas). **No es evidencia de que M11 esté implementado**: es la porción de FSM/energía/selección modelable sin tocar `player.gd`. Los **70 `[?]` siguen abiertos** y siguen siendo la verdad del módulo. **No se flipó ninguna marca.**
