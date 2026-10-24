# 06 — Plan de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 a 2026-10-22 (iter. 2 a iter. 10)
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

### Bloques (18)

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
| O | Las 6 historias de amistad (iter. 10): carga, fuente del principal, unicidad de las 6 consecuencias nuevas vs las 27 preexistentes, 6 capitulos de diario unicos y corrida end-to-end de las 6 (npc REAL de `data/villagers/`; `OBJ-ROP-005`, `OBJ-ITE-036`, `OBJ-NAT-022`, `OBJ-NAT-023`, `OBJ-ITE-035` y `OBJ-NAT-004` REALES de `data/items/`; puzzle) con `ws_has()` de `regalo_favorito_entregado` / `sentadilla_de_pesca_amistosa` / `paseo_con_amiga` / `historia_de_ficcion_escrita` / `puesto_de_mercedes_ordenado` / `correspondencia_retomada` | M14, M21, M55 |
| P | Las 5 cadenas secretas ocultas (iter. 11): carga, fuente del principal, marca `oculta`, ocultamiento en `cadenas_disponibles()` antes de iniciar y visibilidad tras iniciarse, unicidad de las 5 consecuencias nuevas vs las 33 preexistentes, 5 capitulos de diario unicos y corrida end-to-end de 2 (npc REAL de `data/villagers/`; `OBJ-SEC-002` y `OBJ-ART-004` REALES de `data/items/`; puzzle) con `ws_has()` de `sendero_secreto_revelado` / `mascara_ceremonial_restaurada` | M14, M21, M55 |
| Q | Las 3 historias de comerciantes (iter. 12): carga, fuente del principal, marca no-oculta y visibilidad en `cadenas_disponibles()` desde el inicio (regla opuesta a las secretas del bloque P), unicidad de las 3 consecuencias nuevas vs las 38 preexistentes, 3 capitulos de diario unicos y corrida end-to-end de 2 (npc REAL de `data/villagers/`; `OBJ-ITE-052` «Moneda de oro» y `OBJ-ITE-010` «Tela» REALES de `data/items/`; puzzle) con `ws_has()` de `ruta_comercial_reabierta` / `telas_reunidas` | M14, M21, M55 |
| R | Los clusters Puzzles (6, 03-Diseno L46: templos 24/25/26 + ruinas del barrizal/manantial/acantilado) e Investigacion (5, L45: faro, biblioteca, geodesia, mapas + cartas estelares) consolidados en UN bloque (iter. 13, regla del fundador msg 183): carga, fuente del principal, marca no-oculta y visibilidad en `cadenas_disponibles()` desde el inicio, unicidad GLOBAL de flags medida sobre la carga real (52 consecuencias sobre 52 cadenas, reemplaza la lista transcrita a mano), NPC REALES por efecto (`FileAccess.file_exists` sobre `data/villagers/`), objetos REALES por campo id dentro del `.tres` (`_ids_items_reales()`), 11 capitulos de diario distintos y corrida end-to-end de 3 (`cadena-registro-del-faro` con vera_ardilla + `OBJ-LUZ-012` «Linterna»; `cadena-templo-de-las-24-marcas` con pablo_pato + `OBJ-TAL-004` «Rueda de alfarero»; `cadena-ruinas-del-barrizal` con catalina_oso + `OBJ-ITE-021` «Pan») con `ws_has()` de `registro_del_faro_recuperado` / `templo_de_las_24_marcas_abierto` / `ruinas_del_barrizal_leidas` | M14, M21, M55 |

### Guarda anti-falso-verde (obligatoria, iter. 2)

1. `_check()` cuenta cada verificación (`_checks`).
2. `_fin("X")` por bloque + lista `BLOQUES`: el resumen nombra el bloque que no corrió.
3. `CHECKS_MINIMOS` = **456** desde la iter. 13 (MEDIDO en verde el 2026-10-22 con 18
   bloques; la cadena fue 40 con 7 -> 59 con 8 -> 70 con 9 -> 98 con 10 -> 129 con 11
   -> 169 con 12 -> 227 con 13 -> 258 con 14 -> 316 con 15 -> 351 con 16 -> 379 con 17
   -> 456 con 18). No estimado.
4. `_summary()` en un `call_deferred` **separado** del de `_run()`: si `_run()` aborta
   por un `SCRIPT ERROR` de runtime, el resumen corre igual, nombra los bloques
   faltantes, dispara el piso y sale con `quit(1)` — la suite **no cuelga**.
5. Guardián probado EN ROJO por inyección de runtime, trece veces:
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
   - iter. 10 (abort de runtime al inicio del bloque O, asignación tipada
     `Variant` con `Array` -> `Dictionary`): EXIT 1, «el bloque O NO se ejecuto» +
     «solo 259 checks (mínimo 316)», 2 fallos. Re-ejecutada en la corrida de cierre
     del mismo día (la nota del checklist afirmaba la inyección, pero la corrida
     original no dejó registro en la memoria del agente): mismo resultado.
   - iter. 11 (abort de runtime al inicio del bloque P, asignación tipada
     `Variant` con `Array` -> `Dictionary`): EXIT 1, «el bloque P NO se ejecuto» +
     «solo 317 checks (mínimo 351)», 2 fallos.
   - iter. 12 (abort de runtime al inicio del bloque Q, asignación tipada
     `Variant` con `Array` -> `Dictionary`): EXIT 1, «el bloque Q NO se ejecuto» +
     «solo 352 checks (mínimo 379)», 2 fallos.
   - iter. 13 (abort de runtime al inicio del bloque R, asignación tipada
     `Node` null -> `free()`): EXIT 1, «el bloque R NO se ejecuto (posible SCRIPT
     ERROR que aborto la funcion)» + «solo 380 checks ejecutados (mínimo 456)»,
     2 fallos. Re-ejecutada en el cierre de la tanda (la corrida original quedó
     interrumpida por el límite de frecuencia de la API): mismo resultado.
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
  catálogo vivo tiene 51 (52 con el merge de ejemplos) y varios bloques corren cadenas
  end-to-end individuales, pero
  el test E2E de 10 encadenadas no está diseñado ni corrido.
- Contenido narrativo, capítulos de diario (`capitulo-*` no existen en el catálogo
  M55), cosméticos y consecuencias visuales: dueños de contenido/M53/M45/M17/M18/M27.
- Variaciones de postgame *por tipo de final* (variantes narrativas): el gate
  implementado es binario (final elegido sí/no); la variación es de M22/contenido.

## Iter. 14 (Log 2163) — bloque S `_test_consecuencias`

Cubre la sección «Consecuencias y diálogos posteriores» del checklist (L106-L115):

1. **Cobertura de las 12 consecuencias** de 03-Diseno L53 sobre los dos catálogos
   reales (`secundarias.json` + `cadenas_ejemplo.json`): 8 con respaldo / 4 sin
   respaldo, con las dos listas afirmadas por contenido y la fuente de
   `biblioteca_iluminada` (catálogo de ejemplos, mergeado y vivo) afirmada aparte.
2. **Negativo acotado del token `taller_abierto`** sobre `res://data`
   (`.json`/`.tres`, recorrido DirAccess recursivo). Alcance declarado: mide
   DATOS, no scripts — una mención en un script no es respaldo de la consecuencia
   y, además, el propio test nombra el token (auto-pis medido en la corrida 1).
3. **End-to-end de las 2 cadenas cuyos ítems se flippean** (`cadena-jardines` y
   `cadena-cofradia`) con `ws_has(...)` de `jardin_florecido` y
   `cofradia_activa` sobre WorldState (M21).

Piso: 456 -> **477** (`CHECKS_MINIMOS` MEDIDO en verde, no estimado). Bloques
A-S. Guardián EN ROJO por inyección de runtime Variant -> Dictionary tipado
(EXIT 1 nombrando el bloque S + piso no cumplido). Ver 07-Resultados-Testings.
