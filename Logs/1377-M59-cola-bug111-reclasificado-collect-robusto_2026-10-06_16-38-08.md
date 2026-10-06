# Log 1377: Cola M59 (BUG-108..115) - bug 1: BUG-111 RECLASIFICADO (falso positivo) + bug real de collect()

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 16:38:08 (local -0300; UTC 19:38)
**Tarea:** cola BUG-108..115 de M59 (asignacion del director, msg 51 sec.4). Orden estricto 1->8.

## 1. BUG-111 (prioridad 1): el sintoma descrito es FALSO POSITIVO

El reporte dice: "una excepcion en un proveedor deja `_writing = true` para siempre -> la
cola de guardado se traba en silencio".

**Medido (Godot 4.7.2 headless, varias sondas):** el sintoma NO se reproduce.
- Un error de runtime en GDScript aborta SOLO la funcion donde ocurre; el LLAMADOR
  CONTINUA (sonda: `BEFORE-CALL` / `SCRIPT ERROR` / `AFTER-CALL-CONTINUED`).
- `save_manager._process_queue()` llama solo a funciones TIPADAS (`_payload_para_slot`
  -> Dictionary, `SaveWriter.write_atomic` -> bool). Una funcion TIPADA que aborta
  devuelve el DEFAULT del tipo (`{}` / `false`), NO null. Por eso la asignacion tipada de
  `_process_queue` no falla y `_writing = false` SIEMPRE se alcanza.
- Sondas con proveedor que lanza, que devuelve null y que devuelve Array: en las 3,
  `_writing` termino en `false` y la cola en 0. NO queda colgada.

Conclusion: **BUG-111 (sintoma literal) = FALSO POSITIVO.** No se marca [x]; se reporta al
director para reclasificar (su msg 51 sec.4 lo pide para los falsos positivos).

## 2. Bug REAL adyacente (medido, y PEOR que el descrito): collect() abortaba -> save VACIO

Causa raiz del aborto: `save_snapshot.collect()` hacia
`var data: Dictionary = provider.get_save_data()`. Si un proveedor LANZA, la llamada
devuelve null (proveedor sin tipo) o el default del tipo (proveedor tipado); si devuelve un
tipo que no es Dictionary (Array, etc.), la asignacion tipada FALLA -> `collect()` aborta
-> devuelve `{}`.

Medido: con UN proveedor malo, `collect()` pasa de **47 secciones a 0**; `_process_queue`
escribe ese `{}` como un save VALIDO ("[SAVE] OK slot 2"). Al recargar,
`SaveSchema.completar({})` rellena defaults y `validate()` pasa -> **el progreso COMPLETO
del jugador se pierde en SILENCIO**. Es perdida TOTAL de datos, no "cola trabada".

## 3. Fix (1 archivo, +8/-2)

`game/isla-ancestral/scripts/saving/save_snapshot.gd` -> `collect()`:
- La llamada al proveedor se hace SIN asignacion tipada: `var raw: Variant = provider.get_save_data()`.
- Si `typeof(raw) != TYPE_DICTIONARY`: `push_error` + `continue` (seccion OMITIDA).
- El resto del snapshot se conserva.

Efecto: un proveedor roto ya NO vacia el save. Su seccion queda en el default del schema
(degradacion graceful, lo que el director pidio: "no debe inmovilizar el guardado de los
otros 55"). Antes: perdida TOTAL; ahora: se pierde a lo sumo la seccion del proveedor roto.

## 4. Sonda nueva

`game/isla-ancestral/scripts/saving/test_save_collect_robust.gd` (`extends SceneTree`):
- baseline sano (>= 40 secciones, medido 47);
- proveedor de tipo incorrecto (Array) -> snapshot conserva >= 40 y NO escribe su seccion;
- proveedor que devuelve null -> idem;
- control: un proveedor SANO si escribe su seccion.
**10 checks / 0 fallos / EXIT 0 x3.** Piso `CHECKS_MINIMOS := 10` MEDIDO.
**Guardian EN ROJO** (fix revertido -> 4 fallos, EXIT 1, "medido 0").

## 5. Regresion M59 (toda verde, tras el fix)

- `test_rotate_m59`: 43 checks / 0 fallos / RESULTADO OK.
- `test_slots_m59`: 22 checks / 0 fallos / RESULTADO OK.
- `test_autosave_m59`: 0 fallos.
- `validate_save`: 16 checks / 0 fallos.
- `test_save_collect_robust` (nueva): 10 / 0.

## 6. Trampa nueva (para el skill)

**Un error de runtime en GDScript NO propaga a traves del stack**: aborta la funcion donde
ocurre y el LLAMADOR continua. Corolario: un `_writing = true` "colgado" solo es posible si
el error ocurre EN LA MISMA funcion que lo pone (o si un callee SIN TIPO aborta y su null se
asigna a una variable TIPADA del llamador). Funciones tipadas abortan devolviendo el default
del tipo, no null -> no rompen al llamador. Medir el tipo de retorno ANTES de afirmar que un
aborto "propaga".

## 7. Numeracion / estado

- Log: **1377** (head justo antes 1377).
- `11-BUGS.md` NO se toco (director msg 51 sec.3: commit conjunto con Ling). BUG-111 queda
  reportado como falso positivo + bug real; el director reclasifica.
- Sin push (cola sin autorizacion; el director lo exige).
