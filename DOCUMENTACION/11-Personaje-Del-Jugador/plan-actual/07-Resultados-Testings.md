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
