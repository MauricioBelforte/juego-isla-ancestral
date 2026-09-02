**Modelo:** Hy3
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-01
**Tipo:** QA cruzado §21.8 (verificación entre modelos)
**Módulo:** M70 — Interacciones (liberado por minimax-m3-free / Kilo Code, Log 311, 2026-09-01)

---

## 1. Objetivo del QA cruzado

M70 estaba marcado como *"Listo para QA cruzado (Hy3 en WorkBuddy)"* en `CHECKLIST-GLOBAL.md`.
Como modelo distinto al implementador (perfil de guía 10: Hy3 = QA cruzado + diálogos/narrativa),
ejecuto la verificación §21.8: revisión de código, validación de la DoD §21.6 y detección/corrección
de bugs de integración. Hy3 **no tiene Godot** en su entorno, así que la verificación combina:
revisión estática del código + simulación Python de la lógica del manager (`Logs/378-QA-sim-m70.py`)
+ regresiones GDScript añadidas para que el dueño las ejecute en su runner.

## 2. Reserva (bloqueo) de los 4 registros

| Registro | Cambio |
|---|---|
| `CHECKLIST-GLOBAL.md` (fila M70) | Estado → `🔵 En curso (QA cruzado Hy3)`; `Agente actual` → `Hy3 (WorkBuddy)`; nota de QA en `Notas`. |
| `08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M70) | Corregida la lista de archivos obsoleta (`interaction_target/interaction_prompt` no existen) por los 4 archivos reales de `scripts/interacciones/`. |
| `05-Checklist.md` | Bloque `## Reserva actual` + sección `## Nota del agente (QA cruzado — Hy3 / WorkBuddy, Log 378)`. |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Fila `QA cruzado M70 Interacciones` en el registro Hy3. |

## 3. Bugs de integración detectados y corregidos

### Bug C — CRÍTICO: crash del manager sobre cualquier consumidor real
`interaction_manager.gd` → `_evaluar_y_seleccionar()` llama `it.obtener_prioridad()` para cada
interactuable. `InteractableBase` (la clase base que usarán cofres, puertas, NPCs, cosechas, animales)
**no implementaba** `obtener_prioridad()` y extiende `Node3D`, no `IInteractable`. Resultado: el
manager CRASHEA con *"Nonexistent function 'obtener_prioridad'"* en el primer `_process` apenas
evalúa un consumidor real. El suite original pasaba solo porque `test_mock_interactable.gd` SÍ
define el método (lo enmascaraba).

**Fix:** se añadió `func obtener_prioridad() -> int: return prioridad` a `InteractableBase`.

### Bug A — CRÍTICO: soft-lock de todas las interacciones tras una interacción instantánea
`presionar_interact()` pasaba el gestor a `INTERACTUANDO` y solo lo devolvía a `SELECCIONANDO` si el
consumidor llamaba `finalizar_interaccion`. Para interacciones instantáneas (duración 0, p. ej.
"recoger flor"), el consumidor rara vez lo hace → el gestor **queda pegado en INTERACTUANDO** y
bloquea TODAS las interacciones siguientes (exactamente lo que M66 vigila como anti-softlock).

**Fix:** tras `obj.interactuar(datos)`, si la interacción es instantánea se auto-finaliza:
`if _estado == INTERACTUANDO and obj.obtener_duracion_esperada() <= 0.0: finalizar_interaccion(obj, true)`.
Si el consumidor ya llamó `finalizar_interaccion` dentro de `interactuar`, `_estado` ya volvió a
`SELECCIONANDO` y el bloque no hace nada (sin doble emisión).

### Bug B — MEDIO: la histéresis mantiene un objetivo ya inválido
La condición de mantener objetivo usaba `_objetivo_actual in _interactuables` (registro completo).
Si el objetivo actual pasaba a `OCULTO`/`INTERACTUANDO` o dejaba de cumplir requisitos, seguía
"pegado" como objetivo aunque hubiera un candidato válido a <=0.15 m, impidiendo interactuar con él.

**Fix:** se construye `objs_validos` (solo candidatos válidos) y la histéresis ahora solo mantiene
el objetivo si `_objetivo_actual in objs_validos`.

### Bug D — robustez: la persistencia era un no-op en la clase base
`InteractableBase` no implementaba `aplicar_estado_guardado`, así que `GameState.M70` no restauraba
nada al re-registrar (RF18/M59 quedaba sin efecto para la base).

**Fix:** se añadió `func aplicar_estado_guardado(saved): if saved.has("estado"): estado = int(saved["estado"])`.

## 4. Evidencia (simulación)

`Logs/378-QA-sim-m70.py` replica fielmente el algoritmo del manager (selección por
prioridad/distancia/registro, histéresis 0.15 m, despacho, cancelación) y corre los 3 escenarios
en modo PRE-FIX y POST-FIX. Resultado resumido:

```
[C] InteractableBase sin obtener_prioridad
    PRE-FIX  -> CRASH: Nonexistent function 'obtener_prioridad'
    POST-FIX -> OBJETIVO SELECCIONADO (OK)
[A] Interaccion instantanea (duracion 0)
    PRE-FIX  -> estado=INTERACTUANDO tras 1er E; 2do E NO despacha (soft-lock)
    POST-FIX -> tras 1er E vuelve a SELECCIONANDO; 2do E re-despacha
[B] Objetivo valido se vuelve OCULTO; aparece otro valido a 0.05m
    PRE-FIX  -> mantiene 'a' (OCULTO)
    POST-FIX -> cambia a 'b' (el anterior ya no es valido)
```

## 5. Tests añadidos (regresión GDScript)

En `scripts/interacciones/test_interacciones.gd` (deben ejecutarse con
`godot --headless --path game/isla-ancestral --script res://scripts/interacciones/test_interacciones.gd`):

- `_test_interactable_base_obtener_prioridad` → Bug C.
- `_test_despacho_instantaneo_auto_finaliza` → Bug A.
- `_test_histeresis_no_mantiene_objetivo_invalido` → Bug B.
- `_test_persistencia_restaura_estado_base` → Bug D.

Además `_test_despacho_y_cozy_no_objetivo` ahora usa un mock de interacción **LARGA** (duración 1.0 s)
para no codificar el bug A (antes asertaba `INTERACTUANDO` tras el despacho, que era el comportamiento
bugueado). Total: +7 asserts de regresión.

## 6. Hallazgo de honestidad (documentación)

- El claim original **"41 OK / 0 fallos"** es **internamente inconsistente**: `_test_interactable_base_auto_register`
  ya asertaba `obtener_prioridad() == 5`, lo que habría **FALLADO** contra el código original con Bug C.
  Hy3 no pudo reproducirlo (sin Godot) y lo señala como no verificable.
- El conteo **60/198** declarado en `CHECKLIST-GLOBAL.md` y en la cola del `05-Checklist.md` **NO coincide**
  con el archivo real (0 `[x]` de 198 ítems). Se requiere que el dueño tilde los subítems realmente
  implementados; **no se fabrican checkmarks** en este QA.

## 7. Archivos modificados en este QA

- `game/isla-ancestral/scripts/interacciones/interactable_base.gd` — +`obtener_prioridad()`, +`aplicar_estado_guardado()`.
- `game/isla-ancestral/scripts/interacciones/interaction_manager.gd` — Fix A (auto-finaliza instantáneas) + Fix B (hystéresis sobre `objs_validos`).
- `game/isla-ancestral/scripts/interacciones/test_interacciones.gd` — 4 tests nuevos + mock largo en test existente.
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — fila M70: archivos corregidos.
- `DOCUMENTACION/70-Interacciones/plan-actual/05-Checklist.md` — bloque Reserva + Nota QA.
- `CHECKLIST-GLOBAL.md` / `Mensajes entre modelos/ESTADO-PARALELO.md` — registros de QA.
- `Logs/378-QA-sim-m70.py` — simulación de evidencia.

## 8. Estado final

M70 **permanece 🟡** (QA cruzado completado por Hy3; **NO marcado ✅** porque los prompts visuales
M53/M154 y la integración con 10 consumidores siguen fuera de iter 1, y el cierre lo hace el dueño).
El bloqueo de QA se libera: `Agente actual` vuelve a `—` en `CHECKLIST-GLOBAL.md`.

**Modelo:** Hy3
**Plataforma:** WorkBuddy

