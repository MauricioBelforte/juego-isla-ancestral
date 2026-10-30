# Log 2246 - M55 - Cableado de `test_diario_persist.gd` en `quality.yml`

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-29
**Modulo:** M55 Diario del Jugador
**Entrada:** mensaje **452** de agnes-3-flash (acuse de mi 451)
**Rama:** RAMA 1 (mensaje del director > tracker 450)

---

## 1. Que pedia la entrada

El mensaje 452 responde a mis 6 pedidos del 451. **Una sola tarea ejecutable**
(punto 1), el resto son decisiones ya tomadas por la directora:

1. **Cablear `test_diario_persist.gd` en `quality.yml` -> GO.** Lo hago yo, en el
   bloque de suites del job `test-suite`, junto a `test_diario_idiomas_m55`.
   Debia **confirmar el EXIT al cablear**.
2. Commit de 3 paths -> lo hace su **Cron C**. Yo dejo los archivos en disco.
3. L130 cuenta como evidencia del cierre 1-nov. M55 se queda en **92**.
4. BUG-151 -> ella ya lo marco `[x] Resuelto` en `11-BUGS.md`.
5. Pool del canal desincronizado -> no es suyo, queda para el saneo del fundador.
6. Problemas de numeracion de `reservar_log.py` -> ajenos, no los toco.

Cierre declarado: "no hace falta que respondas mas, quedas en cierre".

---

## 2. Medido ANTES de tocar el archivo

    $ godot --headless --script scripts/diario/test_diario_persist.gd
    [bloque padre] checks acumulados: 10
    === Resumen M55 PERSISTENCIA (padre): 10 checks, 0 fallos ===
    EXIT=0     SCRIPT ERROR=0

Y el estado del gate en el archivo de CI, medido por grep:

    $ grep -n "test_diario_persist" .github/workflows/quality.yml
    (sin resultados)  -> la suite NO estaba cableada

Baseline del YAML (antes del cambio):

    jobs: 13
    sha256 quality.yml: a6440b03b5bbf6d1d89d2d3805871aa7a2f51ea76ac821a1c381da7096f6e3cd
    invocaciones `suite --script`: 97
    invocaciones `py_suite`: 3
    EOL: i/lf  w/lf (git ls-files --eol)

---

## 3. Cambio aplicado (11 lineas, 1 archivo)

`.github/workflows/quality.yml`, justo despues de `test_diario_idiomas_m55.gd`
(la linea cableada queda en **L679**):

- 10 lineas de comentario con: la cita del 05-Checklist (L130), que son DOS
  procesos Godot encadenados por `OS.execute`, el GO de la directora, la cifra
  MEDIDA antes de cablear, las 5 capas del guardian y que es gate duro.
- 1 linea: `suite --script scripts/diario/test_diario_persist.gd`

No se toco ninguna otra linea del archivo ni ningun otro archivo.

---

## 4. Verificacion despues del cambio

    jobs: 13                      (sin cambio)
    sha256 quality.yml: 8efd9c3754f78c557c808ffbe95bf59f77aa63a8adf8c3b8e0c16d1ef10010f4
    invocaciones `suite --script`: 98   (97 + 1)
    invocaciones `py_suite`: 3          (sin cambio)
    test_diario_persist.gd cableada: 1  (una sola vez, sin duplicado)
    BOM: False    CRLF en el archivo: 0    EOL: i/lf w/lf

Parseo: `yaml.safe_load` sin excepcion -> el job `test-suite` sigue teniendo
4 steps (Checkout / Setup Godot / Import / Run validation tests).

---

## 5. Confirmacion del EXIT (lo que pidio la directora)

Se ejecuto **la misma invocacion que usa `suite()` en CI** (cwd =
`game/isla-ancestral`, `godot --headless --script <ruta>`, sin `--path`), x3:

    run1 EXIT=0  10 checks, 0 fallos  SCRIPT ERROR=0
    run2 EXIT=0  10 checks, 0 fallos  SCRIPT ERROR=0
    run3 EXIT=0  10 checks, 0 fallos  SCRIPT ERROR=0

Mas una corrida con la forma `--path game/isla-ancestral --script res://...`
(tambien EXIT 0, 10/0). Total 4 corridas verdes, 0 SCRIPT ERROR.

---

## 6. Sonda EN ROJO del gate ya cableado (anti-falso-verde)

Un `suite` que devuelve 0 siempre seria decorativo. Se probo que el cableado
puede fallar, con mutacion + restauracion por sha256:

    sha256 antes      : 22b37cc7...300e563c25
    control verde     : EXIT=0  "10 checks, 0 fallos"
    inyeccion         : CHECKS_MINIMOS_PADRE 10 -> 999
    sonda piso 999    : EXIT=1
                        [FAIL] solo 10 checks ejecutados en la fase padre (minimo medido 999)
    restaurado        : True   sha256 == 22b37cc7...300e563c25  (identico)
    control post      : EXIT=0  "10 checks, 0 fallos"
    wrapper           : script inexistente -> EXIT=1 (suite() emite ::error::FALLO)
    VEREDICTO         : GATE VIVO

Nota de honestidad: la sonda piso+1 prueba el camino "menos checks de los
esperados -> EXIT 1"; los otros 6 casos (aborto de runtime en el padre, aborto
en el hijo, `_fin` suprimido, piso hijo+1, asercion falsa) ya se probaron en la
vuelta anterior (Log 2245) con 7 sondas y no se repitieron aqui.

---

## 7. Lo que NO se toco

- **0 commits / 0 push.** El commit de los 3 paths lo hace el Cron C de la
  directora. `git status` deja `quality.yml` en `M` para que lo tome.
- **0 flips de marca.** M55 sigue **92 / 37 / 2 = 131** (no se re-midio el
  checklist porque no habia nada que cambiar: la directora ya cerro L130).
- No toque `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `project.godot`, el
  `05-Checklist` de ningun modulo, ni el backlog de otro modelo.
- El archivo de la suite quedo con el **mismo sha256** que tenia al empezar
  (`22b37cc7...`), verificado tras la sonda.

---

## 8. Pools y numeracion

- **Log:** cabeza medida justo antes de reservar = **2246**; ultimo log en
  `Logs/` = 2245 -> `ultimo + 1` = 2246. Consistente. Pool no commiteado.
- **Canal:** max(archivos) = **452** -> mensaje **453**. El head de
  `NUMEROS_DISPONIBLES.txt` sigue en **423** (desincronizado, **9.a vuelta**):
  reportado, no tocado.

---

## 9. Pedidos que quedan abiertos (sin accion mia)

1. Commit de los 3 paths + `quality.yml` (ahora 4 paths) por Cron C.
2. Saneo del pool del canal (423 vs 453) -> fundador.
3. El system-prompt de esta sesion sigue declarando director a GLM-5.3-Flash;
   la directora real es agnes-3-flash (ella ya lo escalo al fundador, msg 452).

**Estado:** cierre. No hay tarea ejecutable pendiente en mi rama.
