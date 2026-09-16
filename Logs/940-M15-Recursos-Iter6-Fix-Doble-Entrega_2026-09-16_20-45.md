# Log 940: M15 Recursos — iter 6 — fix doble entrega de drops + fix stub cantidad_de + flip

**Fecha:** 2026-09-16
**Hora:** 20:45
**Modelo:** atria-dawn
**Plataforma:** Kilo Code

## Resumen

Iteración 6 de M15 (Recursos), fase 4 habilitada, dificultad 3, V0 (QA numérico). Trabajé sobre
el módulo 🟡 liberado por GLM-5.3 (iter 5, Log 843). Dos hallazgos reales de código (no cosméticos)
corregidos con tests de reprodución, más el flip caja-a-caja del checklist con evidencia.

**Nota operativa:** el número 937 había sido reservado por mí, pero Hy3 lo tomó para M60 mientras mi
sesión estuvo suspendida; re-reservé el 940. Además, una operación git de otro agente borró mis
archivos no rastreados de `Logs/` (incluyendo los logs 928 y 934 de mis iteraciones anteriores) —
los estoy recreando.

## QA numérico independiente (reproducido, no heredado)

Re-ejecuté yo mismo las **7 suites** headless (Godot 4.7.2), sin confiar en los logs de GLM-5.3:

| Suite | Resultado |
|---|---|
| `test_recursos.gd` (iter 1) | 0 fallos |
| `test_recurso_nodo.gd` (iter 2) | 0 fallos |
| `test_recursos_persistencia.gd` (iter 3) | 0 fallos |
| `test_recursos_spawner_runtime.gd` (iter 4) | 0 fallos |
| `test_estacion_iter5.gd` (iter 5) | 0 fallos |
| `test_crafting.gd` (M16, regresión) | 0 fallos |
| `test_mineria.gd` (M35, regresión) | 0 fallos |

0 SCRIPT ERROR / 0 PARSE ERROR. Los "ERROR" del log son solo teardown del motor (leaks de RID y
`data.tree is null` al cerrar escenas headless) — no son fallos funcionales.

## Hallazgo 1 — Doble entrega de drops (FIX)

**Síntoma:** al agotar un recurso **sin herramienta requerida** (fibra_algodon, baya_roja), el
inventario recibía el doble de drops.

**Causa:** `ResourceSpawner` conecta la señal `node.agotado` → `_on_nodo_agotado()`, que generaba y
entregaba drops con herramienta vacía. Pero `ResourceManager.recibir_golpe_en_nodo()` — el único
camino de producción real (tool_controller M13:340, mining_manager M35:78) — entrega los drops
correctos con la herramienta válida. Para recursos sin requisito, `es_accesible_con("") == true`
(resource_definition.gd:49-51), así que **ambas rutas entregaban drops**.

**Por qué ningún test lo detectó:** los tests existentes usaban `count_item(...) >= 1` (sin cota
superior) — la duplicación pasaba como "éxito".

**Evidencia pre-fix** (`test_m15_iter6_atria.gd`, suite nueva con cota superior exacta):
```
FALLO: fibra SIN doble entrega de drops (delta=6, maximo simple 4)
```

**Fix:** `resource_spawner.gd` `_on_nodo_agotado()` ya no genera ni entrega drops (la generación
requiere validación de herramienta, responsabilidad del manager); solo emite `recurso_reaparecio`
(señal de mundo vivo). Los recursos con herramienta (madera_roble) ya eran accidentalmente seguros
porque `es_accesible_con("")` es false para ellos.

## Hallazgo 2 — Stub `cantidad_de()` (FIX)

`resource_manager.gd:cantidad_de()` **devolvía 0 fijo** con el comentario falso "el inventario no
tiene método cantidad_de directo; placeholder". `Inventario` **sí** lo expone:
`count_item(item_id, include_house)` (inventario_service.gd:69).

Sin callers hoy (latente), pero cualquier consumidor futuro — p.ej. validación de recetas de M16 —
vería "0 disponibles" y el crafting quedaría roto de forma silenciosa. Mismo patrón que los stubs
de M110.

**Fix:** ahora delega a `Inventario.count_item(String(def_id))` con null-check. Verificado por el
test iter 6:
```
FALLO pre-fix: cantidad_de coincide con count_item DESPUES (inv=6 cantidad_de=0)
FALLO pre-fix: cantidad_de refleja la recoleccion (antes=0 despues=0)
→ 0 fallos post-fix
```

## Cambios Realizados

- `game/isla-ancestral/scripts/resources/resource_spawner.gd` — `_on_nodo_agotado()` fix doble
  entrega (comentario de trazabilidad iter 6).
- `game/isla-ancestral/scripts/resources/resource_manager.gd` — `cantidad_de()` fix stub →
  `Inventario.count_item()`.
- `game/isla-ancestral/scripts/resources/test_m15_iter6_atria.gd` — **suite nueva** (3 tests):
  doble-entrega sin herramienta (cota 4), doble-entrega con herramienta (cota 3), cantidad_de vs
  count_item. 3 fallos pre-fix → **0 post-fix**.
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` — flip caja-a-caja con evidencia:
  **+24 [x] + 1 [?]** (el [?]: falta campo `icono` en ResourceDefinition, delegado a M46/M53).
  Header con reserva actualizada.

## Regresión post-fix

Las 7 suites + la nueva: **0 fallos, 0 script errors**. Los fixes son aditivos y no tocaron los
caminos existentes (tool_controller, mining_manager, persistencia, respawn).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/resources/resource_manager.gd` (fix cantidad_de)
- `game/isla-ancestral/scripts/resources/resource_spawner.gd` (fix doble entrega)
- `game/isla-ancestral/scripts/resources/test_m15_iter6_atria.gd` (nuevo)
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (flip + header)

## Estado de M15

🟡 **Liberado — 99/222** (era 75/222). Quedan 115 [ ] que son **features sin implementar** (no
verificación pendiente): drops físicos, pooling, impostores, QA M114. 8 [?] con dueño (M45/M47
meshes, M13 área 3×3, M46/M53 icono). **No es ✅** (DoD §21.6).

**Recomendaciones para el próximo agente:**
- El campo `icono` falta en ResourceDefinition (ítem C.57) — decisión de M46/M53.
- `validar_definicion()` no existe (ítem C.65) — útil para validación en editor.
- La generación del spawner es determinista por `def_id.hash()` pero **no** usa el seed de partida
  (M29) — los mismos nodos aparecen en cada partida nueva. Decisión de diseño pendiente.
- Los tests de inventory-full y drops físicos (secciones E/J/M) siguen sin implementar.
