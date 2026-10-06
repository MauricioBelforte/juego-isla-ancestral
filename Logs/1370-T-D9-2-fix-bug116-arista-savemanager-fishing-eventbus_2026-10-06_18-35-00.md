# Log 1370: T-D9 (2/4) - fix BUG-116/BUG-069 - invertir la arista SaveManager -> Fishing por EventBus

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 18:35:00 (UTC)  [local -0300: 15:35]
**Modulo:** M62 (arquitectura de servicios) + M59 (guardado) + M34 (pesca) - frente T-D9
**Tarea:** T-D9 (2/4) "ciclos entre servicios" (L103 / BUG-069) - alcance (B)
**Estado:** COMPLETADO - commit LOCAL; push PENDIENTE por restriccion del director (msg 49, sec.6)

## 1. Que se hizo

Alcance (B) confirmado por el director (msg 49): romper el SCC de 7 con la unica arista
`SaveManager -> Fishing`, invertida por EventBus. Se ejecuto al vencer la autorizacion a
12 h (s2 no respondio; el director autorizo explicitamente arrancar igual).

**Sin cambios en `quality.yml` / `interaction_manager` / `service_registry`** (ajenos).

## 2. Registro previo del bug (pedido del director)

`DOCUMENTACION/11-BUGS.md`: **BUG-116** agregado (fila de tabla + seccion detallada,
severidad Menor, prioridad Media, estado [->] En progreso). **NO se commiteo** ese archivo:
estaba sucio en el worktree con **+481 lineas de ling-3.1-flash** (BUG-108..115, sin
commitear). Commitearlo habria arrastrado trabajo ajeno (trampa 87). Queda en el worktree
para que lo commitee su dueno.

## 3. Auditor ANTES (condicion 2 del director)

```
autoloads 114 | aristas 229
A1 componentes con ciclo ... 2
   SCC 7: CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather
   SCC 2: ThemeService, UIManager
A2 refs fuera de orden ..... 11
B carga sincrona .......... 0
C pureza save ............. 0
NUEVOS .................... 0
EXIT 0
```

## 4. Cambio (3 archivos de produccion; +25/-6)

1. `scripts/core/event_bus.gd` (+11): dominio nuevo `fishing`
   (`var fishing := FishingEvents.new()`) + `class FishingEvents` con
   `sesion_iniciada(sesion)` y `sesion_terminada(sesion)`.
   EventBus se declara en `project.godot:22`, ANTES de Fishing (`:67`) -> sin A2 nueva.
2. `scripts/fishing/fishing_manager.gd` (+9): en `iniciar_sesion()` y `_terminar()` se emite
   tambien por el bus (`get_node_or_null("/root/EventBus")` + `bus.fishing.*.emit`).
   Se conservan las senales locales.
3. `scripts/saving/save_manager.gd` (+5/-6): el bloque que hacia
   `get_node_or_null("/root/Fishing")` + guard `has_signal(...)` se reemplaza por la
   suscripcion al bus (`bus.fishing.sesion_iniciada/terminada`). Se elimino ademas un
   bloque muerto (`if bus.travel != null and bus.has_user_signal("pesca_iniciada"): pass`).

### Hallazgo clave (bug latente, BUG-116)
La conexion anterior estaba **MUERTA en runtime**: guardaba con
`fm.has_signal("sesion_iniciada")`, pero `fishing_manager.gd` solo declara `sesion_terminada`
(su senal de inicio es `picada_iniciada`). `grep -rn "sesion_iniciada"` en todo el proyecto =
solo las 2 lineas de `save_manager.gd`. El guard siempre fallaba -> "bloquear el guardado
durante la pesca" NO funcionaba. El auditor veia la arista (por el `get_node_or_null`), por
eso nadie la cazo: el grafo existe, el runtime no. El fix repara el ciclo Y la feature.

### Trampa cazada en este turno
`EventBus.fishing...` (nombre global del autoload) **NO compila** en este proyecto:
`--check-only` dio `SCRIPT ERROR: Identifier not found: EventBus`. El convenio real es
`get_node_or_null("/root/EventBus")` (los `EventBus.` que aparecen en otros scripts son
comentarios). Corregido ANTES de medir.

## 5. Auditor DESPUES (condicion 2)

```
autoloads 114 | aristas 229
A1 componentes con ciclo ... 1   (solo ThemeService, UIManager)
A2 refs fuera de orden ..... 10
B carga sincrona .......... 0
C pureza save ............. 0
NUEVOS .................... 0
Aviso: 2 entradas de PERMITIDOS ya no se observan (se pueden borrar):
     A1|CollectionRegistry,Fishing,GameTime,Inventario,SaveManager,TimeCalendar,Weather
     A2|SaveManager->Fishing
```

**A1: 2 -> 1** (el SCC de 7 desaparecio). **A2: 11 -> 10** (desaparecio la mayor, delta +37).
Las 2 entradas de PERMITIDOS las borra **s2** (dueno del Architecture Guard).

## 6. Sonda nueva (headless)

`game/isla-ancestral/scripts/saving/test_fishing_save_block.gd` (`extends SceneTree`).
Afirma que `SaveManager.set_save_blocked()` responde a `EventBus.fishing.sesion_iniciada/
terminada` **sin depender de Fishing**: 2 ciclos completos + control positivo.

- **x3: 11 checks / 0 fallos / EXIT 0.**
- **Piso `CHECKS_MINIMOS := 11` MEDIDO** (no estimado).
- **Guardian EN ROJO:** con piso 12 -> `TEST FISHING-SAVE-BLOCK FALLIDO - solo 11 checks
  (piso 12)` -> **EXIT 1**. Restaurado a 11 -> EXIT 0.

## 7. Regresion

- `test_autosave_m59.gd` -> 0 fallos / EXIT 0.
- `test_rotate_m59.gd` -> OK / EXIT 0.
- `test_slots_m59.gd` -> OK / EXIT 0.
- `--check-only` de los 3 archivos de produccion + la sonda -> EXIT 0.

## 8. NO sella 21.8

El fix es de autor; la verificacion 21.8 (verificador != autor) es de otro agente.

## 9. Numeracion / pool

- Log: **1370** (pool head justo antes: 1370).
- Reporte al director: **50** (pool de mi carpeta). Aviso a s2: **46** (pool de su carpeta).
- No se commitea el pool.

## 10. Push - PENDIENTE POR RESTRICCION

El director (msg 49, sec.6) indica "sin push sin autorizacion expresa". Se commiteo
**LOCAL** (commit aislado) y **NO se empujo**. Se pide autorizacion en el reporte (canal 50).
