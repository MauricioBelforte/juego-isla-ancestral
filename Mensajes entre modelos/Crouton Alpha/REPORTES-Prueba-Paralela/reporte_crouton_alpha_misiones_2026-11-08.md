# Reporte — Sistemas de misiones / quests / objetivos

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` (GDScript) + datos en `game/isla-ancestral/data/historias/` y `data/historia/`

> Nota: no existe carpeta `scripts/misiones/` ni `scripts/quests/`. El sistema vive repartido en tres subsistemas: historia principal (M22), historias secundarias (M23) y objetivos de retención (M94), más un invariante anti-softlock (M66) y validadores/tests.

## 1. Archivos relevados

### 1.1 Historia principal — M22
| Archivo | Líneas | Rol |
|---|---|---|
| `scripts/historia/story_manager.gd` | 255 | Autoload `Historia`. Grafo de nodos data-driven (`data/historia/historia_principal.json`: 12 nodos, 4 finales `principal/regresar/guardian/secreto`, 7 sellos). API: `puede_entrar(id)` (líneas 141-167), `completar_nodo(id)` (197-210), `marcar_sello` (172-188), `siguientes_disponibles` (214-219), `finales_alcanzables` (223-231). Persistencia sección `historia` (236-255). |
| `scripts/historia/validar_historia.gd` | 125 | Validador headless (SceneTree): huérfanos, DAG por capítulo, finales alcanzables BFS, requisitos conocidos, sellos ≤ sellos_totales, piso `CHECKS_MINIMOS := 79` (línea 19). |
| `scripts/historia/test_historia.gd` | — | Test/integración del grafo. |

### 1.2 Historias secundarias / cadenas de misiones — M23 (núcleo real de "misiones")
| Archivo | Líneas | Rol |
|---|---|---|
| `scripts/historias/secondary_stories_service.gd` | 470 | Autoload `Historias`. Motor principal: `iniciar_cadena` (267-282), `reportar_paso(cadena_id, tipo, evidencia)` (305-324), `reportar_entrega` (328-345, consume inventario), `ref_paso_actual` (290-300), `_completar_cadena` (348-384: consecuencias a `WorldState`, recompensa de diario, señal `cosmetico_desbloqueado` y `quest_completed`). Catálogos: `secundarias.json` (81 cadenas) + merge de `cadenas_ejemplo.json` (3, 1 añadida `cadena-biblioteca`, 1 conflicto `cadena-faro`, 1 rechazada). Persistencia sección `secondary_stories` (447-470). |
| `scripts/historias/quest_chain.gd` | 59 | `Resource QuestChain` con `validar()` (28-45): contexto ≥10 chars, ≥3 pasos, recompensa con `diario` o `cosmetico`. **Es código legado/duplicado: ningún cargador lo usa** (ver §5). |
| `scripts/historias/quest_chain_service.gd` | 173 | Servicio paralelo `QuestChainService` (autoload alternativo, `marcar_paso_completado` línea 123, `validar_todas` 167-173, sección save `historias`). **Duplicado de `secondary_stories_service.gd` con esquema de estado distinto** (`paso_actual` id string vs índice entero). |
| `scripts/historias/validate_quest_chains.gd` | 33 | EditorScript que carga `quest_chain_service.gd` y llama `validar_todas` (línea 12-23). Valida el servicio legado, no el motor vigente. |
| `scripts/historias/puzzle_bridge_m24.gd` | 182 | Puente M23↔M24 (`PuzzleBridgeM24`): clasifica `ref` puzzle en tiers `m24/narrativo/vacio` (líneas 80-114), construye salas M24 y reporta el paso al completarse (148-182). Documenta el estado medido: 78 pasos puzzle, 78 `ref` distintos, 0 resolven contra el catálogo M24 de 28 puzzles (líneas 8-15). |
| `scripts/historias/cosmeticos_catalog.gd` | — | Catálogo de recompensas cosméticas. |
| `scripts/historias/test_historias.gd` | >930 | Suite principal M23 (bloques A–AB, piso `CHECKS_MINIMOS := 923`, línea 189): carga, validador, cadena completa, entrega/inventario, ocultas, postgame ×4 finales, persistencia, merge, clusters end-to-end. |
| `scripts/historias/test_m23_l92_m24.gd` | 343 | Suite del puente L92 (piso 36 checks, línea 26): catálogo M24, clasificación, inverso, puente, ceguera, contrato. |

Datos secundarios (conteo directo disco, 2026-11-08):
- `data/historias/secundarias.json`: **81 cadenas**; `cadenas_ejemplo.json`: **3**; total JSON: **84** (332 pasos).
- Pasos por tipo: `hablar` 87, `explorar` 83, `entregar` 83, `puzzle` 78, `construir` 1 (en `cadena-postgame-plaza`, tipo desconocido → esa cadena es rechazada por el validador, ver `test_historias.gd:293`).
- `oculta`: 7 cadenas · `postgame`: 5 cadenas.
- 0 cadenas sin recompensa, 0 sin consecuencia, 0 con <3 pasos.

### 1.3 Objetivos de retención (sin FOMO) — M94
| Archivo | Líneas | Rol |
|---|---|---|
| `scripts/motivacion/objetivo_data.gd` | 23 | `Resource ObjetivoData`: `Plazo {DIARIO, SEMANAL, MENSUAL}`, `condicion`, `cantidad_requerida`, recompensa. Data-driven desde JSON. |
| `scripts/motivacion/objetivo_activo.gd` | 49 | Estado vivo: `progreso`, `cobrado`, `ciclo`, `completado`; `avanzar(cantidad, delta)` (25-32) retorna `true` solo en la transición a completado; `a_diccionario/desde_diccionario` (34-49) para guardado. |

### 1.4 Invariante anti-softlock — M66
| Archivo | Líneas | Rol |
|---|---|---|
| `scripts/core/invariants/mision_invariant.gd` | 81 | `MisionInvariant`: `_check()` (42-49) falla si un objetivo activo no tiene fallback declarado; `activar_fallback` (60-72) avisa en el diario M55; `registrar_recompensa_entregada/recompensa_ya_entregada` (76-81) anti-duplicación de recompensa. |

### 1.5 Señales y consumidores
- `scripts/core/event_bus.gd:74-82` (`QuestEvents`): `quest_started(quest_id)`, `quest_updated(quest_id, objective, progress)`, `quest_completed(quest_id)`, `prereq_met(seal_id)`.
- Consumidores: `scripts/diario/diary_service.gd:104-111` (sellos → categoría `sellos`, misiones → `misiones` vía `registrar("mision_"+slug, "misiones")`); `scripts/progresion/progression_manager.gd:158-164` (contador `misiones_completadas`); `scripts/saving/save_manager.gd:84,91` (auto-save por `quest_completed`); `scripts/logros/achievement_service.gd:146-147`; `scripts/audio/narrative_sound.gd:52-53`.
- Debug: `scripts/debug/debug_menu.gd:963-970` (`completar_mision` → `Historia.completar_nodo`).
- Guardado de NPC/misiones: `scripts/saving/test_carga_npc_misiones_m59.gd`.

## 2. ¿Cómo se gestionan las misiones?

**Modelo general: data-driven + motor con reporte explícito, sin eventos automáticos de mundo.**

1. **Dos grafos separados (M22 + M23).**
   - M22 (`story_manager.gd`): grafo de historia principal JSON. `completar_nodo` revalida `puede_entrar` (capítulo previo / sellos / flag `WorldState` / objeto de inventario, líneas 141-167). `marcar_sello` valida contra el catálogo de sellos y emite `prereq_met`.
   - M23 (`secondary_stories_service.gd`): cadenas secundarias JSON. Flujo: `iniciar_cadena` → pasos en orden estricto → `reportar_paso`/`reportar_entrega` → `_completar_cadena` (consecuencias literales a `WorldState`, recompensa de diario, cosmético, `quest_completed`).

2. **Reporte pasivo, no reactivo.** El motor no observa el mundo: cada paso exige que el sistema dueño (diálogo M19, puzzle M24/M25, inventario M14) llame a `reportar_paso` con tipo y evidencia, y `reportar_paso` valida tipo + evidencia esperada (`ref_paso_actual`, líneas 290-319) y avanza el índice. El paso `entregar` además consume el objeto del inventario (líneas 328-345).

3. **Gating:** postgame exige `final_elegido() != ""` de M22 (líneas 273-276 y `cadenas_disponibles` 222-237); ocultas no listan hasta iniciarse.

4. **Persistencia:** ambos motores implementan `ISaveProvider` M59 (secciones `historia`, `secondary_stories`); las huérfanas al cargar se purgan con aviso (`secondary_stories_service.gd:463-470`).

5. **Recompensas:** (a) diario M55 por capítulo declarado `recompensa.diario` (líneas 365-370, sin derivación de id desde iter. 21); (b) cosmético con señal dedicada `cosmetico_desbloqueado(cadena_id, cosmetico_id)` (líneas 42, 375-377) porque la antigua `quest_updated(id, "cosmetico", 1)` no identificaba qué cosmético era; (c) consecuencias = flags pelados a `WorldState` (líneas 353-357).

6. **Objetivos M94** son independientes: `ObjetivoActivo.avanzar` con transición idempotente a completado y ciclo de rotación; no comparten estado con M22/M23.

## 3. ¿Hay validación de progreso de misiones?

**Sí, en tres capas, con un hueco medido.**

| Capa | Qué valida | Evidencia |
|---|---|---|
| Runtime M22 | `puede_entrar` antes de completar cada nodo; `completar_nodo` revalida (contrato M66) | `story_manager.gd:141-167, 197-210` |
| Runtime M23 | Tipo y evidencia de cada paso; inventario para entregas; estado `activa/completada` | `secondary_stories_service.gd:305-345` |
| Validador esquema M23 | `validar_cadenas`/`_errores_de_cadena` (387-431): contexto ≥10, ≥3 pasos, tipos en `["hablar","explorar","puzzle","entregar"]`, ids únicos, recompensa y consecuencia presentes, títulos únicos (anti-repetición) | `secondary_stories_service.gd:387-431` |
| Validador M22 | Grafo DAG, huérfanos, finales alcanzables, requisitos conocidos, sellos ≤ total, piso 79 checks | `validar_historia.gd:19-118` |
| Invariante M66 | Todo objetivo activo debe tener fallback o es "condición imposible"; recompensa no duplicada | `mision_invariant.gd:42-81` |
| Tests | Suite M23 (923 checks, bloques A–AB) + suite puente M24 (36 checks) + `validar_cosmeticos` (cruce catálogo↔contenido, `secondary_stories_service.gd:201-214`) | `test_historias.gd:189`, `test_m23_l92_m24.gd:26` |

**Hueco medido:** `validar_cadenas()` **no valida referencias** (npc/lugar/objeto/ref) contra el mundo real. El propio `puzzle_bridge_m24.gd:14-15` lo declara: las 78 referencias puzzle colgantes "eran invisibles" para el validador. El puente clasifica `ref` puzzle en tiers, pero los pasos `hablar/explorar/entregar` dependen de que NPC/lugar/objeto existan, y eso solo lo afirman los tests caso por caso (NPC reales de `data/villagers/`, objetos reales de `data/items/`), no una regla general.

## 4. ¿Hay misiones que no se pueden completar?

**Sí.** Hallazgos con evidencia:

1. **Pasos puzzle sin runtime (78 pasos, Tier B "narrativo").** `puzzle_bridge_m24.gd:8-15` (medido 2026-10-26): 78 pasos `tipo: "puzzle"` con 78 `ref` distintos; catálogo M24 real = 28 puzzles; cruce = **0 de 78 resuelven**; `reportar_paso(..., "puzzle", ...)` tenía **0 llamadas de runtime** (solo tests). El puente (`sala_de`/`conectar`, líneas 148-182) es el mecanismo que haría completables los Tier A, pero con 0/78 en Tier A hoy, **todo paso puzzle depende de que un sistema narrativo reporte la evidencia a mano**. Conteo propio 2026-11-08: 78 pasos puzzle, 78 `ref` únicos, 0 vacíos; 28 ficheros JSON en `data/templos/puzzles/`. Confirmado vigente.

2. **Sin emisores de runtime para los pasos no-puzzle.** `reportar_paso`/`reportar_entrega`/`iniciar_cadena` solo aparecen en `secondary_stories_service.gd`, `puzzle_bridge_m24.gd` (puente) y tests. No hay ningún caller de producción (diálogo M19, mundo, UI) que inicie cadenas ni reporte pasos `hablar/explorar/entregar`. Consecuencia: **las 84 cadenas cargan y validan, y los tests las completan end-to-end, pero en el juego real ningún paso se dispara** (salvo el puente puzzle, que tampoco está conectado a escenas). La única vía de progreso real hoy es M22 vía menús de debug (`debug_menu.gd:963-970`).

3. **Recompensa de diario que degrada en silencio (77 de ~79 capítulos).** `_completar_cadena` registra `recompensa.diario` en M55 (líneas 365-370), pero el catálogo `data/diario/diario_catalog.json` solo tiene 2 entradas (`mision_cadena-faro`, `mision_cadena-invernadero`); el resto retorna `false` sin error. Medido y afirmado en `test_historias.gd:167-180, 489-497, 729-735`. No bloquea la misión, pero la recompensa principal (diario) **no se otorga** en 77 cadenas: es contenido de M55 (dueño), reportado a la dirección.

4. **Finales que exigen flags externas.** `validar_historia.gd:92-104` advierte: finales `secreto` (y según grafo, `guardian`) exigen flags seteadas por M25/M147 (`pistas_secreto_completas`, `templo_brisa_abierto`); sin esas banderas el final es in-alcanzable. `story_manager.gd:156-164` lo refleja: requisito `flag` con `WorldState` ausente → motivo `bandera faltante`. Por diseño, pero es un camino no completado si M25/M147 no setean el flag (el test los setea a mano, `test_historias.gd:394-414`).

5. **Cadena rechazada por esquema.** `cadena-postgame-plaza` (ejemplos, tipo `construir` desconocido) es rechazada en el merge y nunca carga (`test_historias.gd:293`, `secondary_stories_service.gd:108-125`). No es "misión imposible en runtime" sino contenido que el motor descarta silenciosamente en la práctica.

6. **Objetos narrativos en entregas.** Varias cadenas entregan objetos que no existen en `data/items/` (`farol_cargado`, `jarabe_lunar`, `tomo_carbonizado`, `carta_sellada`, `brujula_desorientada`): los tests los siembran a mano (`inv.agregar_items`, p. ej. `test_historias.gd:327-331`). Si el juego real no otorga esos objetos en algún paso previo, la entrega falla con `objeto no disponible` (`secondary_stories_service.gd:341-342`). El test de entrega lo confirma: sin semilla → rechazada (`test_historias.gd:344-363`). Este es el patrón más frágil: **`reportar_entrega` es completabilidad real condicionada a un ítem que ningún sistema garantiza**.

> Lo que **no** es un problema: pasos `hablar/explorar` referencian NPC/lugares reales (los tests afirman NPC reales de `data/villagers/` por cluster) y las cadenas ocultas/postgame tienen gating coherente (verificación en `test_historias.gd` bloques E y F, postgame ×4 finales).

## 5. Observación estructural: dos motores paralelos

Coexisten `secondary_stories_service.gd` (autoload `Historias`, vigente, 470 líneas, dicts de cadena, estado por índice) y `quest_chain_service.gd` (173 líneas, `QuestChain` Resource, estado por id de paso) con `quest_chain.gd` y `validate_quest_chains.gd` que lo validan. Ambos vuelcan en secciones save distintas (`secondary_stories` vs `historias`). El glosario (`QuestEvents`) y los tests usan el primero; el segundo no tiene callers de producción detectados. Es deuda de duplicación: dos esquemas de estado (`paso_actual` int vs string) para el mismo concepto.

## 6. Dos mejoras sugeridas

### Mejora 1 — Validador de referencias para pasos no-puzzle + piso de completabilidad real
Extender `validar_cadenas()` (`secondary_stories_service.gd:390`) con la misma técnica del puente: cruzar cada `npc` contra `data/villagers/`, cada `objeto` contra `data/items/`, y cada `lugar` contra el registro de ubicaciones; publicar el resultado como lista de errores en CI (como `validar_historia.gd` con piso de checks). Esto convierte el hueco declarado en `puzzle_bridge_m24.gd:14-15` ("las referencias colgantes eran invisibles") en un gate medible, y evita que futuras cadenas nazcan con NPC/objeto inexistentes. Añadir al mismo validador la regla inversa de M24 (`m24_sin_uso`, `puzzle_bridge_m24.gd:131-140`).

### Mejora 2 — Emisores runtime reales (cablear el reporte) o marcar explícitamente el estado "contenido sin cablear"
Hoy `reportar_paso` no tiene ningún caller de producción (§4.2): el sistema está probado pero **no conectado al juego**. Dos opciones:
- **(a) Cablear:** subscribir a `Historias` los eventos reales que ya existen (diálogo terminado M19, `PuzzleRoom.completada` vía `PuzzleBridgeM24.conectar`, entrega confirmada por inventario) usando `ref_paso_actual` como única fuente de verdad de evidencia (ya es el contrato, `secondary_stories_service.gd:290-300`). Así las 84 cadenas dejan de ser deuda de cableado.
- **(b) Si el cableado se difiere:** exponer `ResumenCompletabilidad` (por cadena: Tier A/B, objeto con fuente de obtención, catálogo de diario con/sin respaldo) en UI de QA y en el log de arranque, de modo que "no completadle" sea un estado explícito y auditable, no un silencio.

Ambas variantes resuelven la causa raíz de §4.2 y §4.6 (objetos narrativos sin fuente garantizada): `reportar_entrega` pasaría a verificar no solo posesión, sino **fuente de obtención registrada** del objeto.

## 7. Conclusión final

El sistema de misiones de Isla Ancestral está **bien modelado y bien validado en estática** (M22 grafo DAG con validador de 79 checks, M23 con 84 cadenas JSON, 332 pasos, validador de esquema, suite de 923 checks + puente M24, invariante anti-softlock M66, persistencia M59 en ambos motores), pero **no está conectado al juego**: `reportar_paso`/`iniciar_cadena` no tienen emisores de producción. Las misiones no completables son entonces tres clases medibles: (1) **78 pasos puzzle** sin contraparte M24 ni emisor runtime, (2) **toda la cadena secundaria** sin cableado de inicio/progreso, (3) **objetos narrativos y recompensas de diario** sin fuente garantizada (77 diarios degradan en silencio). Hay además deuda estructural: dos motores paralelos (`secondary_stories_service.gd` vigente vs `quest_chain_service.gd` + `quest_chain.gd` legados). Las dos mejoras propuestas (validador de referencias con gate CI, y cableado runtime o estado explícito de completabilidad) cierran exactamente esos huecos, sin rediseñar el modelo, que es sano.

## Anexos — comandos y conteos propios (2026-11-08)

- `data/historias/secundarias.json`: 81 cadenas; `cadenas_ejemplo.json`: 3; `cosmeticos.json`: 0 cadenas. Total 84 cadenas, 332 pasos (`hablar` 87, `explorar` 83, `entregar` 83, `puzzle` 78, `construir` 1).
- Pasos puzzle: 78, `ref` únicos: 78, vacíos: 0. Ficheros puzzle M24 en `data/templos/puzzles/`: 28.
- `data/historia/historia_principal.json`: 12 nodos, finales `['principal','regresar','guardian','secreto']`, `sellos_totales: 7`.
- `git grep -n "reportar_paso\|reportar_entrega" -- "*.gd"` (desde `game/isla-ancestral`): hits solo en `secondary_stories_service.gd`, `puzzle_bridge_m24.gd` y tests.
- Sin carpeta `scripts/misiones/` ni `scripts/quests/` en `game/isla-ancestral/scripts/` (verificado por glob y por listado de subcarpetas).
