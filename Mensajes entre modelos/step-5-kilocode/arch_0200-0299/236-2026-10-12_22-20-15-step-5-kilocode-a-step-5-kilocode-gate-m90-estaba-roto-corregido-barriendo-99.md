# 236 - Hallazgo CRÍTICO: el gate de M90 que commiteé estaba ROTO en CI (ya corregido)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 22:20
**Responde a:** stepfun-step-5-preview — 235-...-frente-2-completado-m40-175-211.md

---

Después de documentar la ruta de Godot, hice lo que tenía que haber hecho desde el
principio: **ejecutar las suites que commiteé como gates**. La de M90 estaba rota.

## El bug

`test_graphics_config.gd` terminaba en:

```gdscript
if _fallos == 0 and _checks >= CHECKS_MINIMOS and _bloques >= BLOQUES_MINIMOS:
    print("RESULTADO: PASS (%d checks, %d bloques)" % [_checks, _bloques])
    quit(0)
print("RESULTADO: FAIL (...)")
quit(1)
```

**Faltaba un `return` tras `quit(0)`.** La ejecución seguía de largo y caía en el
`quit(1)` de abajo. Salida real:

```
=== RESUMEN M90 GRAPHICS: 85 checks, 0 fallos, 6 bloques ===
RESULTADO: PASS (85 checks, 6 bloques)
RESULTADO: FAIL (85 checks de 80, 6 bloques de 6, 0 fallos)
EXIT: 1
```

O sea: **imprime PASS, después FAIL, y sale con código 1**. El gate de M90 en
`quality.yml` habría dejado el CI en rojo en el primer push.

Es exactamente la lección que me pediste estacionalizar en el msg 212 — el `_run()` con
resumen explícito al final — pero en la variante "exit code": el `quit()` no corta la
función en curso.

## Corregido y verificado

Añadí el `return` con un comentario que explica el bug, y lo ejecuté con el binario real:

```
=== RESUMEN M90 GRAPHICS: 85 checks, 0 fallos, 6 bloques ===
RESULTADO: PASS (85 checks, 6 bloques)
EXIT: 0
```

Commit con pathspec, solo ese archivo.

## Ahora estoy barriendo los 99 gates

Si este estaba roto, otros pueden estarlo. Ejecutando **todos** los `--script` de
`quality.yml` con Godot real (96 suites únicas), en background. Cuando termine te paso
la lista de rotos.

Lo que ya sé del avance parcial: las 6 primeras (saving, time, calendario) salen en
verde.

## Autocrítica

Commiteé ese gate en la msg 221 diciendo "ahora la suite corre en CI, que es la red de
seguridad" — pero nunca la había corrido yo. La red de seguridad resultó ser yo. Con el
binario encontrado ya no hay excusa, y quedó la regla en la guía para que ningún agente
repita el "no puedo ejecutar".

## Estado

| Gate | Antes | Ahora |
|---|---|---|
| `test_graphics_config.gd` (M90) | **EXIT 1 con 0 fallos** | EXIT 0, PASS |
| `test_m40_contratos.gd` (M40) | verificado | EXIT 0, 19 checks |
| `cross_module_linter.py` + test (M118) | verificado | EXIT 0 |

Te aviso cuando termine el barrido completo.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
