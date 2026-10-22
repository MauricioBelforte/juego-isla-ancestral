# 06 — Plan de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 a 2026-10-22 (iter. 2 a iter. 7)
**Módulo:** M23 Historias Secundarias — `scripts/historias/`, `data/historias/`

## Alcance

El núcleo de M23 es data-driven: catálogo JSON + motor (`SecondaryStoriesService`,
autoload `Historias`) + validador anti-repetición + persistencia (M59). El plan cubre
el motor y sus integraciones reales (M21 WorldState, M22 Historia, M14 Inventario,
M55 Diary, M07 EventBus, M59 SaveManager). El contenido narrativo (60+ cadenas) y
las integraciones con dueño externo (M68/M32/M36/M37) **no** se testean acá: son
trabajo de esos módulos.

## Suite principal

`game/isla-ancestral/scripts/historias/test_historias.gd` — `extends SceneTree`,
corre con el binario real:

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd
```

### Bloques (14)

| Bloque | Contenido | Integraciones ejercitadas |
|---|---|---|
| A | Carga del catálogo mergeado (5 cadenas: 4 del principal + 1 de ejemplos; conflicto `cadena-faro` resuelto a favor del principal; cadena rechazada no cargada; sección `secondary_stories`, acceso por id) | JSON |
| B | Validador anti-repetición sobre el catálogo base (contexto >= 10, pasos >= 3, tipos, ids únicos, recompensa/consecuencia, título único) | — |
| C | Cadena completa de 4 pasos con tipos mixtos, rechazo de tipo/evidencia incorrecta, consecuencia → WorldState (M21), recompensa diario → M55, señal `quest_started` (M07) | M21, M55, M07, M14 |
| D | Entrega con inventario: rechazo sin objeto + avance con objeto (consume del inventario) | M14, M21 |
| E | Ocultas: invisibles en `cadenas_disponibles()` hasta iniciarse | — |
| F | Postgame: bloqueada sin final de M22 y abierta tras **cada uno de los 4 finales** (principal/regresar/guardian/secreto), con estado limpio por iteración | M22 |
| G | Persistencia: snapshot `activas`+`completadas`, round-trip, purga de huérfanas | M59 |
| H | Merge de `cadenas_ejemplo.json`: reporte {anadidas, conflictos, rechazadas} + corrida end-to-end de `cadena-biblioteca` (hablar/explorar/entregar → completada) | M14, M21, M55 |
| I | Esquema de consecuencias: AMBAS cargas (crudas y mergeadas) con flags pelados y flags compartidos con el mismo deletreo (regresión de datos con prefijo re-inyectado = rojo) | M21 |
| J | Las 6 historias de vecinos: carga, fuente del principal, unicidad de consecuencias y corrida end-to-end de DOS (`cadena-carpintero` con `madera_roble` real + `cadena-alquimista` con objeto narrativo sembrado) | M14, M21, M55 |
| K | Las 3 historias de lugares: carga, fuente del principal, unicidad de las 3 consecuencias nuevas vs las 11 preexistentes, 3 capitulos de diario unicos y corrida end-to-end de las 3 (npc REAL de `data/villagers/`, item REAL de `data/items/`, puzzle) con `ws_has()` de `jardin_florecido` / `cofradia_activa` / `molino_funcionando` | M14, M21, M55 |
| L | Las 4 historias de ruinas (iter. 7): carga, fuente del principal, unicidad de las 4 consecuencias nuevas vs las 14 preexistentes, 4 capitulos de diario unicos y corrida end-to-end de las 4 (npc REAL de `data/villagers/`, item REAL de `data/items/` salvo `tomo_carbonizado` narrativo, puzzle) con `ws_has()` de `biblioteca_quemada_rescatada` / `observatorio_alineado` / `estacion_reparada` / `puente_cruzable` | M14, M21, M55 |
| M | Las 6 historias de objetos legendarios (iter. 8): carga, fuente del principal, unicidad de las 6 consecuencias nuevas vs las 18 preexistentes, 6 capitulos de diario unicos y corrida end-to-end de las 6 (npc REAL de `data/villagers/`; `gemstone`, `OBJ-SEC-004`, `OBJ-SEC-001` y `OBJ-LUZ-005` REALES de `data/items/`, `carta_sellada` y `brujula_desorientada` narrativos; puzzle) con `ws_has()` de `relicto_devuelto` / `gema_devuelta` / `receta_heredada` / `llave_encontrada` / `patrulla_nocturna` / `brujula_calibrada` | M14, M21, M55 |
| N | Las 3 historias de familias (iter. 9): carga, fuente del principal, unicidad de las 3 consecuencias nuevas vs las 24 preexistentes, 3 capitulos de diario unicos y corrida end-to-end de las 3 (npc REAL de `data/villagers/`; `OBJ-REL-003`, `OBJ-HER-014` y `OBJ-LUZ-011` REALES de `data/items/`; puzzle) con `ws_has()` de `molienda_familiar_restaurada` / `red_del_abuelo_reparada` / `vigilia_de_los_guardas` | M14, M21, M55 |

### Guarda anti-falso-verde (obligatoria, iter. 2)

1. `_check()` cuenta cada verificación (`_checks`).
2. `_fin("X")` por bloque + lista `BLOQUES`: el resumen nombra el bloque que no corrió.
3. `CHECKS_MINIMOS` = **258** desde la iter. 9 (MEDIDO en verde el 2026-10-22 con 14
   bloques; la cadena fue 40 con 7 -> 59 con 8 -> 70 con 9 -> 98 con 10 -> 129 con 11
   -> 169 con 12 -> 227 con 13 -> 258 con 14). No estimado.
4. `_summary()` en un `call_deferred` **separado** del de `_run()`: si `_run()` aborta
   por un `SCRIPT ERROR` de runtime, el resumen corre igual, nombra los bloques
   faltantes, dispara el piso y sale con `quit(1)` — la suite **no cuelga**.
5. Guardián probado EN ROJO por inyección de runtime, nueve veces:
   - iter. 2 (`var _n: Node = null; _n.free()` tras el bloque B): EXIT 1, nombra
     C/D/E/F/G, «solo 11 checks (mínimo 40)».
   - iter. 3 (abort a mitad del bloque H, el nuevo): EXIT 1, nombra H, «solo 47 checks
     (mínimo 59)».
   - iter. 4, dos inyecciones: abort de runtime en el bloque I y regresión de datos con
     el prefijo `estado_mundo.` re-inyectado (ambas EXIT 1 nombrando bloque/clave).
   - iter. 5 (abort de runtime al inicio del bloque J): EXIT 1, «el bloque J NO se
     ejecuto» + «solo 71 checks (mínimo 98)». La PRIMERA versión (`null.metodo()`) fue
     PARSE ERROR estático y no probaba nada: rehecha como abort real.
   - iter. 6 (abort de runtime al inicio del bloque K, asignación tipada
     `Variant` -> `Dictionary`): EXIT 1, «el bloque K NO se ejecuto» + «solo 99 checks
     (mínimo 129)», 2 fallos.
   - iter. 7 (abort de runtime al inicio del bloque L, asignación tipada
     `Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1, «el bloque L NO se
     ejecuto» + «solo 130 checks (mínimo 169)», 2 fallos.
   - iter. 8 (abort de runtime al inicio del bloque M, asignación tipada
     `Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1, «el bloque M NO se
     ejecuto» + «solo 170 checks (mínimo 227)», 2 fallos.
   - iter. 9 (abort de runtime al inicio del bloque N, asignación tipada
     `Variant` con `Array` -> `Dictionary`): EXIT 1, «el bloque N NO se ejecuto» +
     «solo 228 checks (mínimo 258)», 2 fallos.
   Sonda borrada en la misma operación; sha256 del original verificado; 0 sondas en el
   repo.

## Regresiones de integración (módulos que M23 toca)

| Suite | Motivo |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | el bloque F usa el grafo y `final_elegido` de M22 |
| `scripts/diario/test_diario.gd` (M55) | recompensa `diario` → registro `mision_{cadena_id}` |
| `scripts/progresion/test_progresion.gd` (M71) | señal `quest_updated` de cosméticos |
| `scripts/saving/validate_save.gd` (M59) | sección `secondary_stories` del snapshot |

## Casos que quedan fuera (honestidad)

- E2E de 10 cadenas completas como test diseñado (ítem de checklist `[ ]` honesto): el
  catálogo vivo tiene 24 y varios bloques corren cadenas end-to-end individuales, pero
  el test E2E de 10 encadenadas no está diseñado ni corrido.
- Contenido narrativo, capítulos de diario (`capitulo-*` no existen en el catálogo
  M55), cosméticos y consecuencias visuales: dueños de contenido/M53/M45/M17/M18/M27.
- Variaciones de postgame *por tipo de final* (variantes narrativas): el gate
  implementado es binario (final elegido sí/no); la variación es de M22/contenido.
