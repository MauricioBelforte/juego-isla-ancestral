# Log 2211 - M48 Validacion de animacion (implementada) + revert T224 de M60

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-27 01:34 (GMT-3)
**Modulo:** M48-Animacion (principal) / M60-Datos-Y-Serializacion (revert)
**Entrada:** mensajes 426 y 427 del director (agnes-3-flash). RAMA 1.
**Estado:** cerrado con evidencia medida. 0 commits, 0 push, 0 flips fuera de orden.

## 1. Entrada

- msg 426: acuse de 425; 5 flips de M55 pre-aprobados, commit M55 pendiente de GO del fundador.
- msg 427: tanda M48 (items 1-3) + M60 (items 4-5). 5 items, sin depender del GO.

Tracker previo: 424. Procesados: 426 y 427. Tracker nuevo: 427.

## 2. Premisa medida antes de trabajar

| Premisa | Medicion | Resultado |
|---|---|---|
| `import_animation_defaults.gd` ausente | `git ls-files` + `find` | CIERTO: 0 en repo, 0 en disco |
| `validate_animation.gd` ausente | idem | CIERTO: 0 en repo, 0 en disco |
| "M48 tiene 113/10/0" (dir.) | conteo por prefijo | CIERTO: 113 [x] / 10 [ ] / 0 [?] = 123 |
| "revert = 4 flips + Totales 189/3/4" | diff contra baseline 216c1a1 | FALSO: son **7** flips. Con 4 el total da 192/0/4, no 189/3/4 |

**Como se midio el punto 4:** `git diff a7a3a6b~1 a7a3a6b -- 05-Checklist.md` muestra
exactamente **4** transiciones `[?] -> [x]` (las etiquetadas `T224-60`). Pero contra el
baseline `216c1a1` (20-sep, `189 [x] / 4 [?] / 3 [ ]`) hay **7**: los 3 restantes son los
items M08 (L184/L186/L191), que el lote no etiqueto. El numero `189/3/4` que el director
escribio solo cierra con 7, y coincide con la linea `**Totales:**` que el archivo ya
declaraba. **Las marcas eran lo inflado, no el total.**

## 3. Trabajo en M48: se implemento, no se degrado

La orden era "implementar O degradar". Se implemento porque el contrato existia:
`03-Diseno.md` sec 2.3 (validacion al importar), sec 3.1 (tabla fps/duracion/blend),
sec 5 (subset de huesos por familia), sec 6 (plantilla de import, senales L199) y
`04-Codigo.md` sec 3 (firmas de `AnimationValidator`).

**Desvio de ruta declarado:** sec 2.5 preveia `scripts/editor/`; se uso
`scripts/animacion/validacion/` porque el validador no es herramienta de editor: corre con
`--script` y su logica la consumen suites headless.

Archivos nuevos (4):

1. `game/isla-ancestral/scripts/animacion/validacion/animation_validator.gd`
   `AnimationValidator extends RefCounted`. Naming `anim_<actor>_<accion>[_<variante>]`,
   fps y topes por categoria (tabla 3.1), grilla de keyframes, redundancia, subset de huesos,
   presupuesto de actor (60 actores / 4 blend trees / estado sin clip).
2. `game/isla-ancestral/scripts/animacion/validacion/import_animation_defaults.gd`
   `ImportAnimationDefaults extends RefCounted`. step por fps de categoria, `loop_mode` por
   sufijo `_loop`, remapeo de prefijos de vendor, subset por familia.
3. `game/isla-ancestral/scripts/animacion/validacion/validate_animation_cli.gd`
   Gate headless. Exit 0 limpio / 1 hallazgos / 2 uso / **3 DETECTOR CIEGO**.
4. `game/isla-ancestral/scripts/animacion/test_validacion_m48.gd`
   Suite, 7 bloques (A-G), guardia de 3 capas.

**Decision de diseno: severidad en TRES niveles.** `E#` error de contrato (rompe el gate),
`A#` aviso justificable (se reporta), `NV#` no verificable headless (se declara). Un validador
de dos niveles obliga a elegir entre mentir y bloquear: T-pose, fps de origen y compresion de
import salen como `NV`, no como OK silencioso.

## 4. Evidencia medida

### Suite nueva

```
run1 EXIT=0 === Resumen M48-validacion: 50 checks, 0 fallos ===
run2 EXIT=0 === Resumen M48-validacion: 50 checks, 0 fallos ===
run3 EXIT=0 === Resumen M48-validacion: 50 checks, 0 fallos ===
```

Piso `CHECKS_MINIMOS = 50` MEDIDO en verde (no estimado; la primera version declaro 33).

### Gate headless sobre la libreria real

```
=== RESUMEN M48: librerias=1 clips=3 errores=0 avisos=2 no_verificable=5 ===
EXIT CLI=0
   A  A1 'anim_jugador_idle' dura 2.000 s > tope 1.600 s de 'locomocion'
   A  A2 'anim_jugador_run' 1 key(s) fuera de la grilla de 30 fps
   NV NV1 x3 (los clips animan ModeloVoxel:position:y, no huesos) + NV2 + NV3
```

Dos hallazgos reales sobre `jugador_lib.tres`, medidos y NO corregidos (clips placeholder de
Fase 1; Fase 3 no esta autorizada):
- `anim_jugador_idle` dura 2.0 s con tope de 1.6 s para locomotion.
- `anim_jugador_run` tiene un key en 0.25 s = 7.5 frames a 30 fps (fuera de grilla).

### Sondas EN ROJO (4, con restauracion sha256)

| Sonda | Inyeccion | Resultado |
|---|---|---|
| S1 | `nombre_valido()` devuelve `true` siempre | EXIT 1, 5 fallos (A2/A3/A5/A6/G2) |
| S2 | aborto de RUNTIME en `_run()` via intermedio sin tipo | EXIT 1, nombra bloques D/E/F/G + piso 19<50 |
| S3 | `CHECKS_MINIMOS` 50 -> 51 | EXIT 1, "solo 50 checks (minimo 51)" |
| S4 | se suprime `_fin("D")` | EXIT 1, "[FAIL] bloque D NO se ejecuto" |
| CONTROL | sin mutar | EXIT 0, 50/0 |

sha256 antes y despues identicos en los 2 archivos mutados: `validador=170db50d1870`,
`suite=5d8fe4d0f4ee`. Restauracion con 6 reintentos (trampa del `OSError [Errno 22]` de
Windows ya anotada).

### Regresion

`test_animacion_service.gd` 8/0 EXIT 0; `test_animacion_play_m48.gd` 12/0 EXIT 0.

## 5. Trabajo en M60: revert T224

7 marcas devueltas a su estado real, cada una con nota `REVERT 2026-10-27 ... - **<dueno>**`:

| Linea | Item | Marca original restaurada |
|---|---|---|
| L200 | M62 UI deshabilitada durante guardado | `[?]` (dueno M53/M59) |
| L202 | M63 carga de escena < 2 s | `[?]` (dueno M63) |
| L214 | M15/M16/M33 recetas y cultivos .tres | `[?]` (dueno M16/M33) |
| L241 | Profiler de Godot | `[?]` (build GUI) |
| L184 | M08 mundo procedural con semilla | `[ ]` (dueno M08) |
| L186 | M08 contrato de edits Voxel Tools | `[ ]` (dueno M08) |
| L191 | M08 log de chunks editados | `[ ]` (dueno M08; su nota dice "no existe") |

Se restauro la marca ORIGINAL de cada item (los 4 del Beam estaban en `[?]`, los 3 de M08 en
`[ ]`), no una marca uniforme: eso es lo que reproduce `189/3/4`.

Estado final medido: **189 [x] / 4 [?] / 3 [ ] = 196**. La linea `**Totales:**` ya decia
`189/3/4` desde el 20-sep: **no hubo que editarla**. El verificador confirma: M60 **no**
aparece en la lista de inconsistencias.

Item 5: se agrego `## Notas del Agente - iter. 6 (2026-10-27)` a `04-Codigo.md` con la tabla
de deuda externa (5 filas con dueno y evidencia), el metodo de medicion de los 7 flips y lo
que NO se pudo cerrar.

## 6. Documentacion M48

- `04-Codigo.md` sec 2.5: las 2 filas de `Pendiente` pasan a implementadas con ruta real.
  Se agrego la seccion "Implementacion - validacion e import" con API, severidades, medicion
  real y lo que NO esta hecho.
- `05-Checklist.md`: evidencia agregada a L32, L166 y L236; linea `**Totales:**` medida
  (123 items, 113/10/0). Las 2 lineas anteriores quedan como historial (estaban STALE).

## 7. Hallazgos para el director

1. **`Animation.length` NO puede valer 0**: el motor lo clampa a 0.001. Mi primer criterio
   `length <= 0` era **rama inalcanzable** (check muerto). Se cambio a "menor a 1 frame".
   Lo destapo la propia suite al fallar, no una lectura del codigo.
2. **El revert era de 7, no de 4.** Las 3 sin etiqueta (M08) pasaron desapercibidas a la
   auditoria T-D7 del 06-oct y al QA cruzado sec 21.8 del mismo dia, que declararon
   "189 [x] / 4 [?] / 3 [ ]" mientras el archivo tenia 196 [x].
3. **La cita de L166 tiene el numero de seccion VACIO**: `03-Diseno.md sec ` sin numero. La
   seccion real es 2.3. Es la familia de la cita fantasma; no la edite (es la nota del flip
   de Beam), la deje senalada.
4. **`CHECKLIST-GLOBAL.md` fila 48 esta duplicada** (L150 y L151, ambas con `43/123`) y las
   dos estan STALE: el 05-Checklist tiene **113/123**. `verificar_checklist.py` la reporta.
   No la toco (archivo NO TOCAR). Texto exacto propuesto en el mensaje 428.
5. **La nota "Fase 2-3 NO autorizadas" del cierre anterior de M48** queda superada para
   Fase 2 por el msg 427. Fase 3 (clips reales con Blender) sigue sin autorizar.

## 8. Limites respetados

0 commits, 0 push, 0 auto-sellos, 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`,
`AGENTS.md`, `project.godot` ni a un `05-Checklist` ajeno. `jugador_lib.tres` NO se toco.
El pool de logs se consumio con la herramienta (2211); el pool NO se commitea.

## 9. Pools

- Log: **2211** (`reservar_log.py --reservar`, cabeza previa 2211, nueva cabeza 2212).
- Canal: **428**. Discrepancia medida y reportada: el head de
  `NUMEROS_DISPONIBLES.txt` del canal era **423** (stale, 423/424/425/426/427 ya usados),
  mientras el ultimo archivo real era **427**. Se uso `ultimo+1 = 428`, no el head stale.

## 10. Trampas nuevas (para el skill)

1. **`Animation.length` tiene minimo 0.001.** Un criterio de validacion "duracion <= 0" es
   codigo muerto: el motor no permite construir el caso. Para medir "clip invalido por
   duracion" hay que usar el frame minimo de la categoria, no el cero.
2. **Una suite que exige `is_empty()` sobre la lista de un validador con nivel `NV` no puede
   pasar nunca.** Si el validador declara lo no verificable en la MISMA lista, la asercion
   correcta es "ningun E y ningun A", no "lista vacia".
3. **El revert de un lote de flips se mide contra el BASELINE, no contra la etiqueta.** Un
   lote puede etiquetar 4 de 7 flips; el diff contra el commit etiquetado solo ve 4. El
   baseline (fecha del ultimo conteo auditado) es lo que revela los 3 sin etiqueta.
