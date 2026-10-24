# 04 — Código — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash (documentación base)
**Plataforma:** OpenCode (documentación base)
**Fecha:** 2026-08-17 (documentación base)
**Actualizado:** Step 3.7 Flash / Kilo Code — 2026-09-02 05:09 (iter. 1 núcleo)

## Archivos creados (iter. 1 núcleo)

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `scripts/historias/quest_chain.gd` | Resource | Estructura de cadena: id, título, contexto, pasos, recompensa, consecuencia, diálogo posterior, oculta, postgame |
| `scripts/historias/quest_chain_service.gd` | Autoload (`Historias`) | Servicio: carga JSON desde `data/historias/`, validación anti-repetición, consultas por tipo/estado, señales de progreso, persistencia M59 |
| `scripts/historias/validate_quest_chains.gd` | EditorScript | Validador batch para Editor/CI: contexto >= 10 chars, 3+ pasos, recompensa única, sin referencias rotas |
| `data/historias/cadenas_ejemplo.json` | Datos | 3 cadenas de ejemplo: faro (vecinos), biblioteca (lugares), plaza (postgame) |

## API clave (implementación GDScript)

```gdscript
# QuestChain (Resource)
class_name QuestChain extends Resource
@export var id: String
@export var titulo: String
@export var contexto: String
@export var pasos: Array[Dictionary]
@export var recompensa: Dictionary
@export var consecuencia: Dictionary
@export var dialogo_posterior: String
@export var oculta: bool
@export var postgame: bool
func validar() -> Array  # errores vacío = OK

# QuestChainService (Autoload "Historias")
signal cadena_descubierta(chain: QuestChain)
signal cadena_completada(chain: QuestChain)
signal paso_completado(chain_id: String, paso_id: String)
func get_cadena(chain_id: String) -> QuestChain
func get_cadenas_por_tipo(tipo: String) -> Array
func get_cadenas_disponibles() -> Array
func get_cadenas_ocultas() -> Array
func get_cadenas_postgame() -> Array
func marcar_paso_completado(chain_id: String, paso_id: String) -> void
func get_consecuencias_pendientes() -> Array
func validar_todas() -> Array  # para Editor/CI
```

## Reglas de implementación (resumen)

1. Las cadenas viven en JSON bajo `data/historias/`; el validador corre en Editor y CI.
2. El campo `contexto` es obligatorio (anti-repetición dura); mínimo 10 caracteres.
3. Las consecuencias se aplican vía hook a M22/M68 y se persisten atómicamente (M59).
4. Las recompensas narrativas/cosméticas son únicas, nunca otorgan stats (visión cozy).
5. Los diálogos posteriores se guardan por NPC + estado global.
6. No tocar M22 (trama) ni M68 (ejecución) — solo contratos y datos.

## Notas del Agente

**Modelo:** Step 3.7 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 05:17
**Estado:** Parcial — núcleo data-driven verificado y QA cruzado aprobado; liberado 🟡.

### Lo que hice
- Creé `quest_chain.gd` como Resource con campos: id, título, contexto, pasos, recompensa, consecuencia, diálogo_posterior, oculta, postgame.
- Creé `quest_chain_service.gd` como autoload `Historias`: carga JSON desde `data/historias/`, validación anti-repetición en `_registrar_cadena`, consultas por tipo/estado, señales `cadena_descubierta`, `cadena_completada`, `paso_completado`, persistencia M59 (`build_save_data`/`restore_save_data`).
- Creé `validate_quest_chains.gd` como EditorScript para validación batch en Editor/CI.
- Creé `data/historias/cadenas_ejemplo.json` con 3 cadenas de ejemplo (faro, biblioteca, plaza postgame).
- Actualicé 04-Codigo.md con la API implementada y reglas de implementación.
- Ejecuté test headless `test_historias.gd` con Godot 4.7.2: **0 fallos** en carga, validador, cadena completa, entrega con inventario, ocultas, postgame y persistencia.

### Evidencia de testeo (2026-09-02)
- Comando: `"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral" --script "res://scripts/historias/test_historias.gd"`
- Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) ===`
- Cadenas ejercitadas: `cadena-faro`, `cadena-invernadero`, `cadena-secretta-luciernagas`, `cadena-epilogo-plaza`.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé las 40+ cadenas del catálogo completo (solo 4 de ejemplo en `secundarias.json`).
- No integré ejecución real de pasos "puzzle" con M25/M26 (el motor valida evidencia; la resolución la hacen dueños).
- No implementé diálogos posteriores completos ni contenido narrativo de las 60 cadenas.
- No implementé recompensas cosméticas visibles ni consecuencias visuales del mundo.

### Recomendaciones para el próximo agente
- Ejecutar `validate_quest_chains.gd` desde el Editor para verificar las cadenas antes de commit.
- Ampliar `secundarias.json` a 40+ cadenas con contexto verificable y respetar el validador anti-repetición.
- Integrar con M22 (consecuencias) y M68 (objetivos) cuando esos módulos estén estables.
- M25/M26: reportar `reportar_paso(cadena_id, "puzzle", ref)` al resolver puzzles asociados.
- M55: asegurar entradas `mision_{cadena_id}` en el catálogo de diario.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 16:45:00
**Estado:** Parcial (motor + validador + cadenas ejemplo implementados y verificados; módulo liberado 🟡)

### Lo que hice
- SecondaryStoriesService autoload (scripts/historias/secondary_stories_service.gd): motor de cadenas del esquema del diseño — iniciar_cadena (ocultas/postgame gating), reportar_paso con validación de tipo y evidencia (hablar/explorar/puzzle/entregar), reportar_entrega que consume el objeto del inventario M14, _completar_cadena con consecuencia → WorldState M21 (flags tipo faro_encendido), recompensa.diario → M55 (registrada en la categoría misiones) y recompensa.cosmetico → quest_updated (M71 escucha), señales quest_started/quest_completed M07 (M55/M71 ya consumían).
- Validador anti-repetición (§regla dura): contexto no vacío (>=10 chars), pasos >= 3, tipos conocidos (hablar/explorar/puzzle/entregar), ids de paso únicos, recompensa/consecuencia presentes, títulos únicos. El catálogo base pasa limpio.
- Ocultas (§misiones ocultas): no figuran en cadenas_disponibles() hasta iniciarse; postgame (§postgame) requiere final_elegido de M22.
- Persistencia ISaveProvider M59 sección "secondary_stories" (activas + completadas; huérfanas purgadas).
- Catálogo data/historias/secundarias.json con 4 cadenas ejemplo (faro, invernadero, epílogo plaza postgame, luciérnagas secreta).
- Validador como script ejecutable: validar_cadenas() (para CI/editor — checklist QA).
- Test test_historias.gd: carga, validador, cadena completa (4 pasos con tipos mixtos + rechazo de tipo incorrecto + consecuencia aplicada + registro en M55), entrega con/sin objeto, ocultas, postgame (bloqueada sin final de M22, abre tras final), persistencia con huérfana → **0 fallos**.
- Regresiones: test_diario M55 0 fallos, test_progresion M71 0 fallos, test_historia M22 0 fallos.
- Checklist: 10 ítems [x] del núcleo relevados.

### Lo que NO pude hacer (honestidad obligatoria)
- Contenido narrativo de las 60 cadenas del catálogo (escritura con contexto real): 4 cadenas ejemplo entregadas; la escritura es iteración con dueño (recomiendo DeepSeek/narrativa).
- Diálogo posterior de NPCs (diálogo_posterior del esquema): requiere hooks M21 — con dueño.
- Recompensas cosméticas visibles (ropa/sombreros): requiere M53/M45 — la señal quest_updated ya emite.
- Consecuencias visuales del mundo (faro encendido visible): M17/M18/M27 — los flags de WorldState ya están aplicados.
- M68 (misiones: cada cadena como objetivos): M68 no existe; las señales quest_started/updated/completed ya siguen el contrato.
- Ejecución de pasos "puzzle" real: la ejecución del puzzle la hace M25/M26 (el motor valida evidencia); con dueño.

### Recomendaciones para el próximo agente
- Escritura de cadenas: seguir el esquema del 03-Diseno (contexto narrativo >= 10 chars — el validador rechaza "recoge N" genéricos); validar con validar_cadenas() antes de commit.
- M55: agregar la entrada "mision_{cadena_id}" al diario_catalog.json por cada cadena nueva (o extender M55 para auto-purgar categorías de cadenas).
- M25/M26: al implementar puzzles, reportar reportar_paso(cadena_id, "puzzle", ref) cuando el jugador resuelva el puzzle asociado.
- La evidencia de pasos se compara con _slug (minúsculas/sin tildes) — mantener ids ascii-plana.

---

## Notas del Agente — Iteración 2 (Step-5-WorkBuddy, 2026-10-21, Log 2082)

**Modelo:** Step-5-WorkBuddy · **Plataforma:** WorkBuddy · **Fecha:** 2026-10-21
**Estado:** núcleo reverificado con binario real + suite endurecida; 43/104 [x], 61 [ ] honestos
(contenido narrativo y dueños externos). QA §21.8 pendiente de verificador independiente.

### Lo que hice
- **Re-corrí `test_historias.gd` con el binario real ANTES de cualquier flip** (plan ratificado
  por el director, msg 148): 3 corridas -> **40 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR**.
- **Endurecí la suite contra el falso verde** (la versión original imprimía «0 fallos» sin
  contador ni marcadores: un SCRIPT ERROR en un bloque abortaba en silencio y daba igual verde):
  `_check()` cuenta, `_fin("X")` por bloque con lista `BLOQUES`, `CHECKS_MINIMOS = 40`
  **medido en verde**, y `_summary()` en un `call_deferred` **separado** del de `_run()`.
- **Guardíán probado EN ROJO** por inyección de runtime (`var _n: Node = null; _n.free()`
  tras el bloque B): EXIT 1, nombra los bloques C/D/E/F/G, «solo 11 checks (mínimo 40)»,
  y el proceso **termina** (no cuelga). Sonda borrada en la misma operación: 0 sondas en el repo.
- **Bloque postgame extendido a los 4 finales de M22** (`data/historia/historia_principal.json`:
  final_principal / final_regresar / final_guardian / final_secreto), con estado limpio por
  iteración: bloqueada sin final + abierta tras cada uno.
- **Clasifiqué los 80 `[ ]` por verbo y dueño con cita en disco** y flipé **19** ítems
  (24 -> 43 [x]). Criterio: «Definir/Diseñar/Documentar» flippa solo con cita en
  02-Analisis/03-Diseno/04-Codigo o implementación; «Crear» flippa solo con el artefacto en disco.
- Creé `06-Plan-Testings.md` y `07-Resultados-Testings.md` (no existían).

### Clasificación de los 61 `[ ]` que quedan (honestos)
- **Contenido narrativo ausente (~46 ítems «Crear»):** `data/historias/secundarias.json` tiene
  **4 cadenas** de las ~89 del catálogo de 03-Diseno; 0 capítulos `capitulo-*` en el catálogo M55
  (`data/diario/diario_catalog.json`); 0 cosméticos; 0 consecuencias jardín/taller/cofradía.
  No se inventa contenido: quedan `[ ]` con nota.
- **Dueño externo (11 ítems):** M32 (siembra/vendimia/marea/eclipse + variantes de agricultura),
  M28 (reconstrucción del puente), M68/M36/M37 (integraciones), M24 (sin cita en disco: M24 no
  se menciona en 02-Analisis ni 03-Diseno — pendiente de definir).

### Hallazgos medidos (reportados al director, no tocados)
1. **`cadenas_ejemplo.json` está huérfano:** el servicio solo carga `secundarias.json`
   (`RUTA_CATALOGO`, `secondary_stories_service.gd` L22). Sus 3 cadenas (faro, biblioteca,
   postgame-plaza) no las ve nadie en runtime.
2. **`[x]` sin apoyo en disco:** «Crear la consecuencia molino funcionando» (05-Checklist L110)
   — `grep molino_funcionando` sobre `data/` + `scripts/` = **0 archivos**. Reportado; la marca
   no se tocó (decisión del director).
3. **Recompensas `diario` apuntan a entradas inexistentes de M55:** las cadenas declaran
   `capitulo-faro` / `capitulo-invernadero` / `capitulo-plaza`, pero el catálogo M55 tiene 0
   `capitulo-*`. El registro efectivo es `mision_{cadena_id}` (sí existe).
4. **Un rojo propio durante la iteración:** la 1a versión del bloque F resetea el estado de M23
   (`restore_save_data({})`) y el bloque G afirmaba un id fijo que ya no estaba completada
   («round-trip restaura completadas»). Corregido verificando **todas** las completadas del
   snapshot. Lección: cambiar un bloque puede invalidar la premisa de otro.

### Regresiones de integración (binario real, 2026-10-21)
M22 `test_historia.gd` 41/0 · M55 `test_diario.gd` 0 fallos · M71 `test_progresion.gd` 83/0 ·
M59 `validate_save.gd` 16/0 «VALIDACIÓN OK» — todos EXIT 0, 0 SCRIPT ERROR.

## Notas del Agente — Iteración 3 (Step-5-WorkBuddy, 2026-10-21, Log 2083)

- **Merge de `cadenas_ejemplo.json`** (GO del director, msg 151): `RUTA_CATALOGO_EJEMPLOS` cableada en `secondary_stories_service.gd` con merge por id sobre el principal (`_leer_catalogo()` + `_mergear_ejemplos()`). El principal gana los conflictos; las cadenas nuevas que no pasan el validador se rechazan con sus errores; las válidas se añaden con fuente "ejemplos". MEDIDO en carga: 5 cadenas (+1 añadida, 1 conflicto, 1 rechazada).
- **Validador refactorizado**: `_errores_de_cadena()` extraído — UNA implementación para el merge gate y `validar_cadenas()` (semántica y mensajes idénticos).
- **Consultas nuevas**: `fuente_cadena()` y `merge_ejemplos_reporte()` ({anadidas, conflictos, rechazadas}).
- **Rechazo medido**: `cadena-postgame-plaza` usa el tipo de paso "construir", ausente de `TIPOS_PASO` y de 03-Diseno (solo hablar/explorar/puzzle/entregar; 0 usos del token en scripts/). No se integró sin respaldo de diseño; el merge la rechaza con el error nombrado y el reporte la expone.
- **Conflicto medido**: `cadena-faro` existe en ambos archivos con distinto contenido (la de ejemplos trae `ref: M25-faro-linterna` y consecuencia `estado_mundo.faro_encendido`). Ganó la variante del principal (`faro-linterna`, `faro_encendido`), que es la que ya testeaba el bloque C.
- **Suite iter. 3**: bloque A actualizado (5 cadenas + conflicto + mergeada + rechazada) y bloque H nuevo (reporte del merge + corrida end-to-end de `cadena-biblioteca`: hablar bibliotecaria / explorar biblioteca / entregar tomo_antiguo / completada). 3× verde con binario real: 59 checks / 0 fallos / EXIT 0. Piso `CHECKS_MINIMOS` 40 → 59 MEDIDO. Guardia probada EN ROJO por inyección de abort en el bloque H (EXIT 1, bloque H nombrado, "solo 47 checks (mínimo 59)"; sonda borrada en la misma operación).
- **Regresiones medidas**: M55 diario 0 fallos, M55 persistencia 0 fallos, M59 payload sections RESULTADO=OK.
- **Hallazgos**: (1) el puente M23→M55 degrada en silencio — `diary_service.registrar()` exige la entrada en el catálogo de M55 y solo existen `mision_cadena-faro` / `mision_cadena-invernadero` (no `mision_cadena-biblioteca`): la recompensa de diario de la mergeada no aterriza (contenido de M55); (2) el archivo de ejemplos usa claves de consecuencia `estado_mundo.*` vs flags pelados del principal — la mergeada aplica `flag_estado_mundo.biblioteca_iluminada`; no normalicé datos sin orden.
- **Flips**: 05 L32 (biblioteca) → [x]; L34 (plaza) sigue [ ] con nota del rechazo. Refresco de mis anotaciones: conteo del bloque de clasificación y nota del Total (el director ya había degradado el molino a [?] y ajustado el Total a 42/61/1).

## Notas del Agente — Iteración 4 (Step-5-WorkBuddy, 2026-10-21, Log 2085)

- **Normalización de claves `estado_mundo.*` → flags pelados** (GO del director, msg 153,
  decisión 4): data-only en `data/historias/cadenas_ejemplo.json`. Las 5 claves con prefijo
  (`condicion` de faro/biblioteca y `consecuencia` de faro/biblioteca/plaza) quedaron peladas:
  `faro_apagado`, `biblioteca_abierta`, `faro_encendido`, `biblioteca_iluminada`,
  `plaza_decorada`. Dirección medida, no elegida: el motor aplica la clave de `consecuencia`
  LITERAL a WorldState (`ws.set_flag(String(flag), ...)`, secondary_stories_service.gd) y el
  catálogo de producción (`secundarias.json`) ya usaba flags pelados (`faro_encendido`,
  `plaza_decorada`...), que es lo que consume el resto del juego. El prefijo habría creado
  flags que nadie lee.
- **`quest_chain.gd` L19**: el comentario del esquema decía `{estado_mundo.xxx = true/false}`,
  que NO coincidía con el motor ni con producción. Actualizado al esquema canónico
  (clave pelada, aplicada literal a WorldState). Solo comentario, 0 cambio de comportamiento.
- **Suite iter. 4**: bloque H ahora afirma la clave PELADA (`biblioteca_iluminada`) y que la
  prefija NO se aplica; bloque I nuevo (`_test_esquema_consistente`) afirma que AMBAS cargas
  quedan en el mismo esquema — ejemplos crudo sin prefijos (condicion + consecuencia),
  principal sin consecuencia prefijada, carga mergeada en runtime sin prefijos, y los flags
  compartidos con el MISMO deletreo en los dos catálogos (`faro_encendido`, `plaza_decorada`).
  3x verde con binario real: 70 checks / 0 fallos / EXIT 0. Piso `CHECKS_MINIMOS` 59 → 70
  MEDIDO.
- **Guardián probado EN ROJO por 2 inyecciones** (terminan, no cuelgan):
  (1) aborto de runtime en el bloque I (copia-sonda con llamada sobre instancia null) →
  EXIT 1 nombrando «el bloque I NO se ejecuto» + «solo 61 checks (minimo 70)»;
  (2) regresión de datos — prefijo `estado_mundo.` re-inyectado en una clave del fichero de
  ejemplos → EXIT 1 con 4 fallos que nombran la clave («cadena-biblioteca/consecuencia/
  estado_mundo.biblioteca_iluminada» en bloque I; las 2 afirmaciones de H). Fichero
  restaurado y verificado por sha256 (0 prefijos).
  TRAMPA propia durante la inyección 1: la primera corrida usó `--path` relativo equivocado
  (`game/` en vez de `game/isla-ancestral/`) y dio EXIT 1 por «script not found» — un rojo
  FALSO que se parecía al guardián. Corregido el path y rehecho: la evidencia válida es la
  que NOMBRA el bloque.
- **Trampa propia en el bloque I**: la primera versión contaba las cadenas cargadas
  recorriendo `ejemplos + principal`, donde `cadena-faro` está en los DOS catálogos → contó 6
  y publicó un falso rojo («5 cadenas cargadas: 6»). Corregido a ids únicos (diccionario).
  Lección: un conflicto de merge es una cadena en dos catálogos; concatenar listas la duplica.
- **Regresiones medidas** (binario real, mismo run): M22 `test_historia.gd` 41/0 ·
  M55 `test_diario.gd` 0 fallos · M55 `test_diario_persist.gd` 0 fallos · M59
  `validate_save.gd` 16/0 · M71 `test_progresion.gd` 83/0 — todos EXIT 0, 0 SCRIPT ERROR.
- **Decisión 1 del director (msg 153) ejecutada**: rechazo de `cadena-postgame-plaza`
  PERSISTENTE (no se agrega el tipo "construir" sin respaldo de diseño; el dato no se migra
  sin orden). En 05-Checklist: L34 documenta la decisión y el flip sigue [ ]; nuevo ítem [?]
  «Definir el tipo de paso "construir"» con dueños M22/M17 (el contenido ya existe escrito).
  M23 = 43 [x] / 60 [ ] / 2 [?] = 105; la línea «Totales» (L200) estaba desactualizada desde
  iter. 2 (decía 24/80/0) y quedó sincronizada con las marcas.
- **Residual reportado, NO tocado**: `secundarias.json` (principal) mantiene UNA `condicion`
  con prefijo (`cadena-faro` p1: `estado_mundo.faro_apagado`). Es declarativa — 0 consumidores
  de `condicion` en `scripts/` (grep: solo el comentario de esquema y la declaración del
  campo) — y el GO del director era data-only en el fichero de ejemplos. Si el director
  extiende el GO, se normaliza en una línea.
- **Hallazgo que sigue abierto**: el puente M23→M55 degrada en silencio para la entrada
  `mision_cadena-biblioteca` (ausente del catálogo de M55; contenido de M55, dueño).


## Iter. 5 — Historias de vecinos (Log 2107, 2026-10-22, Step-5-WorkBuddy)

Tanda del 03-Diseno L31: de los 8 vecinos del diseño, el farero ya estaba cubierto por
`cadena-faro` (iter. 3). Se agregaron al catálogo principal
(`game/isla-ancestral/data/historias/secundarias.json`, 4 → 10 cadenas) las 6 que faltaban,
una por vecino, con el patrón de producción (npc = id de `data/villagers/`, lugares y
objetos narrativos salvo los que existen en `data/items/`):

| id | título | npc (villager medido) | pasos | entrega |
|---|---|---|---|---|
| `cadena-panadera` | El Pan de la Abuela | `catalina_oso` (cocinera) | hablar/explorar/puzzle/entregar | `pan_fiesta` (narrativo) |
| `cadena-carpintero` | El Banco Roto | `bruno_sapo` (carpintero) | hablar/explorar/entregar/puzzle | `madera_roble` (item REAL) |
| `cadena-tejedora` | El Manto de la Niebla | `olivia_nutria` (sastra) | hablar/explorar/entregar/puzzle | `fibra_algodon` (item REAL) |
| `cadena-pescador` | La Red del Viejo | `finneas_zorro` (pescador) | hablar/explorar/puzzle/entregar | `carrete_nuevo` (narrativo) |
| `cadena-guarda` | El Sendero Cuidado | `nico_gato` (guardabosques) | hablar/explorar/entregar/puzzle | `madera_roble` (item REAL) |
| `cadena-alquimista` | El Jarabe de la Luna | `teo_conejo` (herbolario) | hablar/explorar/puzzle/entregar | `jarabe_lunar` (narrativo) |

- **Mapeo honesto de roles**: el diseño pide "panadera/doctora/tejedora/guarda/alquimista";
  en disco NO existen esos roles — los 14 villagers medidos son trovadora, carpintero,
  cocinera, pescador, artesana, granjero, mercader, guardabosques, sastra, ceramista,
  herrero, bibliotecaria, herbolario y farera. Se usó el villager de rol más cercano
  (cocinera→panadera, sastra→tejedora, guardabosques→guarda, herbolario→alquimista).
- **La doctora queda `[?]`**: 0 NPC médicos en `data/villagers/`. NO se inventa el personaje
  (crear un villager es contenido de otro dueño); el flip se otorga cuando el asset exista.
- Consecuencias con clave PELADA y única (anti-repetición): `pan_fiesta_horneado`,
  `banco_plaza_reparado`, `manto_niebla_terminado`, `red_pescador_reparada`,
  `sendero_bosque_senalado`, `jarabe_lunar_listo`.
- Suite `test_historias.gd`: bloque J nuevo (28 checks) con carga, fuente del principal,
  unicidad de consecuencias y corrida end-to-end de DOS (`cadena-carpintero` con
  `madera_roble` real del inventario y `cadena-alquimista` con objeto narrativo sembrado).
  Piso 70 → **98 medido en verde** (98/0/EXIT 0, binario real).
- Guardián probado EN ROJO por inyección de runtime en el bloque J
  (`root.call("probe_inyeccion_rojo")`, aborta la función): EXIT 1 nombrando
  «el bloque J NO se ejecuto» + «solo 71 checks (mínimo 98)». Inyección revertida y
  verde restaurado verificado (98/0/EXIT 0).
- Los objetos narrativos (`pan_fiesta`, `carrete_nuevo`, `jarabe_lunar`) siguen el patrón
  de producción de `farol_cargado`/`semilla_antigua`/`tomo_antiguo`: el motor solo exige
  que el objeto esté en el Inventario al reportar la entrega, no que exista `.tres`.


## Iter. 6 — Historias de lugares (Log 2117, 2026-10-22, Step-5-WorkBuddy)

Tanda del 03-Diseno L31 (cluster Lugares). De los lugares con cadena propia del diseno,
faro (`cadena-faro`, iter. 3) y biblioteca (`cadenas_ejemplo.json`, iter. 4) ya estaban
cubiertos; plaza e invernadero tenian las suyas desde el lanzamiento. Se agregaron al
catalogo principal (`game/isla-ancestral/data/historias/secundarias.json`, 10 -> 13
cadenas) las 3 que faltaban, con el patron de produccion (npc = id de `data/villagers/`,
objetos e items REALES de `data/items/`):

| id | titulo | npc (villager medido) | pasos | entrega | puzzle |
|---|---|---|---|---|---|
| `cadena-jardines` | Los Jardines de la Niebla | `mateo_mapache` (granjero) | hablar/explorar/entregar/puzzle | `baya_roja` (REAL) | `semillas-perdidas` |
| `cadena-cofradia` | Los Sellos de la Cofradia | `mercedes_lince` (mercader) | hablar/explorar/entregar/puzzle | `fragmento_ancestral` (REAL) | `sellos-antiguos` |
| `cadena-molino` | El Molino que Canta | `aria_ciervo` (trovadora) | hablar/explorar/entregar/puzzle | `fibra_algodon` (REAL) | `melodia-del-molino` |

- **NPCs e items REALES verificados en disco**: `aria_ciervo.tres`, `mateo_mapache.tres`,
  `mercedes_lince.tres` (`data/villagers/`) y `baya_roja.tres`, `fibra_algodon.tres`,
  `fragmento_ancestral.tres` (`data/items/`). Los refs de puzzle (`semillas-perdidas`,
  `sellos-antiguos`, `melodia-del-molino`) son ids narrativos, mismo patron que
  `faro-linterna` / `destilacion-lunar`: el motor exige el puzzle resuelto, no un archivo.
- **Consecuencias con clave PELADA y unica** (anti-repeticion): `jardin_florecido`,
  `cofradia_activa`, `molino_funcionando`. 13 consecuencias unicas sobre 13 cadenas.
- **`molino_funcionando` re respaldada**: el flag figuraba en el checklist (L112) pero
  tenia 0 cadenas que lo aplicaran desde el Log 2082 (degradado a `[?]` por el director
  en su msg 151). `cadena-molino` lo aplica de punta a punta: el bloque K mide
  `ws_has("molino_funcionando")` tras la corrida end-to-end. Flip ofrecido a revertir.
- **Hallazgo (dueno M55)**: el puente M23->M55 degrada en silencio tambien para las 3
  nuevas — `diary_service` exige la entrada en el catalogo de M55 y
  `not diary.esta_registrada("mision_cadena-jardines")` (idem cofradia/molino). Las
  recompensas `diario` apuntan a `capitulo-jardines` / `capitulo-cofradia` /
  `capitulo-molino`, que tampoco existen en el catalogo de M55. Es el mismo residual
  medido en iter. 3 para `cadena-biblioteca`; NO se toca (contenido de M55).
- Suite `test_historias.gd`: bloque K nuevo (`_test_lugares`) al FINAL de `_run()`
  (trampa M23: no alterar la premisa de otros bloques) con `restore_save_data({})`,
  carga y fuente del principal, unicidad de las 3 consecuencias vs las 11 preexistentes,
  3 capitulos de diario unicos y corrida end-to-end de las 3 cadenas con siembra del
  item REAL y el puzzle. **31 checks ejecutados (delta medido 98 -> 129)**.
  Piso 98 -> **129 MEDIDO en verde**: 129/0/EXIT 0 x4 con binario real.
- Guardian probado EN ROJO por inyeccion de runtime en el bloque K
  (`var _sonda_v: Variant = _h.cadenas_disponibles()` seguido de
  `var _sonda_boom: Dictionary = _sonda_v`, abort real de GDScript): EXIT 1 nombrando
  «el bloque K NO se ejecuto» + «solo 99 checks (minimo 129)». Inyeccion revertida y
  verde restaurado verificado (129/0/EXIT 0); sha256 del original comprobado; sonda
  borrada (0 sondas en el repo).
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0, M71 `test_flujo_xp_recompensa_m71_hy3.gd` 37/0, M59
  rotacion 43/0, M55 `test_diario.gd` 26/0.

## Iter. 7 — Historias de ruinas (Log 2125, 2026-10-22, Step-5-WorkBuddy)

Tanda del 03-Diseno L33 (cluster Ruinas: biblioteca quemada, observatorio, estacion,
puente). Se agregaron al catalogo principal (`game/isla-ancestral/data/historias/secundarias.json`,
13 -> 17 cadenas) con el patron de produccion (npc = id de `data/villagers/`, objetos REALES
de `data/items/` donde existen):

| id | titulo | npc (villager medido) | pasos | entrega | puzzle |
|---|---|---|---|---|---|
| `cadena-biblioteca-quemada` | La Biblioteca Quemada | `sofia_buho` (bibliotecaria) | hablar/explorar/entregar/puzzle | `tomo_carbonizado` (narrativo) | `cenizas-legibles` |
| `cadena-observatorio` | El Observatorio Ciego | `vera_ardilla` (farera) | hablar/explorar/entregar/puzzle | `ancient_crystal` (REAL) | `alineacion-estelar` |
| `cadena-estacion` | La Estacion Silenciosa | `ramon_tejon` (herrero) | hablar/explorar/entregar/puzzle | `iron_ore` (REAL) | `engranajes-oxidados` |
| `cadena-puente` | El Puente de Piedra | `luna_zorra` (artesana) | hablar/explorar/entregar/puzzle | `piedra_caliza` (REAL) | `arco-de-piedra` |

- **NPCs REALES verificados en disco**: `sofia_buho.tres` (bibliotecaria — unico match de
  rol real del cluster), `vera_ardilla.tres` (farera), `ramon_tejon.tres` (herrero) y
  `luna_zorra.tres` (artesana) en `data/villagers/` (14 villagers medidos). Los 4 quedaban
  sin cadena propia tras las iters. 5-6 (mapeo honesto por rol, mismo criterio que iter. 5).
- **Items REALES**: `ancient_crystal.tres`, `iron_ore.tres` y `piedra_caliza.tres` en
  `data/items/`. `tomo_carbonizado` es narrativo: 0 items de tipo libro/tomo en
  `data/items/` (medido), mismo patron que `farol_cargado` / `jarabe_lunar` /
  `semilla_antigua`.
- **Consecuencias con clave PELADA y unica** (anti-repeticion):
  `biblioteca_quemada_rescatada`, `observatorio_alineado`, `estacion_reparada` y
  `puente_cruzable` — 17 consecuencias unicas sobre 17 cadenas. `estacion_reparada` y
  `puente_cruzable` son consecuencias del listado del 03-Diseno L53.
- **Hallazgo (dueno M55)**: el puente M23->M55 degrada en silencio tambien para las 4
  nuevas (`not diary.esta_registrada("mision_cadena-puente")` medido en el bloque L).
  Mismo residual de las iters. 3 y 6; NO se toca (contenido de M55).
- Suite `test_historias.gd`: bloque L nuevo (`_test_ruinas`) al FINAL de `_run()` con
  `restore_save_data({})`, carga y fuente del principal, unicidad de las 4 consecuencias
  vs las 14 preexistentes, 4 capitulos de diario unicos y corrida end-to-end de las 4
  con siembra del item y el puzzle. **40 checks ejecutados (delta medido 129 -> 169)**.
  Piso 129 -> **169 MEDIDO en verde**: 169/0/EXIT 0 x3 con el binario real.
- Guardian probado EN ROJO por inyeccion de runtime en el bloque L
  (`var _v: Variant = _h.cadenas_count()` + `var _boom: Dictionary = _v`): EXIT 1
  nombrando «el bloque L NO se ejecuto» + «solo 130 checks (minimo 169)». Inyeccion
  revertida y verde restaurado (169/0/EXIT 0); sha256 del original comprobado; sonda
  borrada (0 sondas en el repo).
- Correccion propia en la suite: la lista `existentes` del bloque K decia
  `sendero_bosque_senalizado` (con z) pero el flag real en datos es
  `sendero_bosque_senalado` — la lista no habria detectado una colision con el flag real.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71 `test_progresion.gd`
  83/0, M59 `test_rotate_m59.gd` 43/0 (9 bloques) + `test_backup_rotate_return.gd` 4/0 y
  M55 `test_diario.gd` 0 fallos. Todas EXIT 0 con el binario real, 0 SCRIPT ERROR.
- Flip del 05-Checklist con cita: «Crear historias de 4 ruinas» [ ] -> [x] (Log 2125).
  M23 = 56 [x] / 47 [ ] / 2 [?] = 105.

## Iter. 8 — Historias de objetos legendarios (Step-5-WorkBuddy, 2026-10-22, Log 2127)

Cluster **Objetos** del 03-Diseno (catalogo L34: relicto, gema, carta, llave, farol,
brujula). 6 cadenas nuevas en `data/historias/secundarias.json` (17 -> 23; 10850 ->
14768 bytes, LF puro sin BOM, diff puramente aditivo verificado por re-parseo):

| Cadena | NPC (REAL, data/villagers/) | Objeto (p3 entregar) | Puzzle (p4) | Consecuencia |
|---|---|---|---|---|
| cadena-relicto «La Reliquia Oculta» | teo_conejo (herbolario) | OBJ-SEC-004 «Reliquia oculta» (REAL) | sellos-del-relicto | relicto_devuelto |
| cadena-gema «La Gema del Barro» | pablo_pato (ceramista) | gemstone «Gema» (REAL) | gema-encastrada | gema_devuelta |
| cadena-carta «La Carta de la Abuela» | catalina_oso (cocinera) | carta_sellada (narrativo) | tinta-borrada | receta_heredada |
| cadena-llave «La Llave del Armario» | bruno_sapo (carpintero) | OBJ-SEC-001 «Llave oculta» (REAL) | cerradura-oxidada | llave_encontrada |
| cadena-farol «El Farol del Guardabosques» | nico_gato (guardabosques) | OBJ-LUZ-005 «Farol» (REAL) | mecanismo-del-farol | patrulla_nocturna |
| cadena-brujula «La Brujula del Pescador» | finneas_zorro (pescador) | brujula_desorientada (narrativo) | aguja-imantada | brujula_calibrada |

- Mapeo honesto medido en disco: los 6 NPC son `.tres` reales de `data/villagers/`
  (pablo_pato era el unico villager sin cadena; los demas ya tenian 1-2, patron de
  reuse existente). Los 4 objetos reales se verificaron por el campo `id` dentro del
  `.tres` (item_database.gd indexa por ese id: OBJ-SEC-001/004 y OBJ-LUZ-005 son
  items de data/items/, gemstone es id simple). carta_sellada y
  brujula_desorientada son narrativos con justificacion medida: 0 items de carta y
  0 de brujula en data/items/ (barrido grep sobre los 250+ .tres), mismo patron que
  tomo_carbonizado en iter. 7.
- Anti-repeticion: 6 consecuencias peladas nuevas sin colision con las 18 previas
  (17 en datos + biblioteca_iluminada de diseno) y 6 capitulos-* de diario nuevos
  sin colision con los 16 existentes; puzzles nuevos sin colision con los 15 previos.
- Suite `scripts/historias/test_historias.gd`: bloque M `_test_objetos()` (58 checks:
  12 carga/fuente + 2 unicidad de flags + 1 diarios + 7x6 end-to-end + 1 puente
  diario) al FINAL de `_run()`. Piso 169 -> **227 checks / 0 fallos / EXIT 0 x3**
  (binario real). Conteos de los bloques A e I actualizados 17/18 -> 23/24 (medidos).
  Guardian EN ROJO por inyeccion de runtime (Variant con int -> Dictionary tipado)
  sobre el bloque M: EXIT 1, «el bloque M NO se ejecuto» + «solo 170 checks
  ejecutados (minimo 227)»; sonda borrada, sha256 del original verificado.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0, M59 `test_rotate_m59.gd` 43/0 (9 bloques) +
  `test_backup_rotate_return.gd` 4/0 + `test_backup_rotations.gd` 7/0 y M55
  `test_diario.gd` 0 fallos. Todas EXIT 0 con el binario real, 0 SCRIPT ERROR.
  (Los tres .gd de M59 viven en `scripts/saving/`: las rutas `scripts/rotate/` y
  `scripts/backup/` usadas en logs anteriores NO existen — name-drift corregido.)
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien
  para las 6 nuevas (`mision_cadena-brujula` ausente del catalogo de M55; mismo
  patron que cadena-biblioteca en H, cadena-jardines en K y cadena-puente en L).
- Flips del 05-Checklist con cita: «Crear las historias de 6 objetos legendarios»
  [ ] -> [x] y «Documentar historias de lugares, ruinas y objetos» [ ] -> [x]
  (compuesta: con iter. 8 los tres clusters tienen contenido y documentacion).
  M23 = 58 [x] / 45 [ ] / 2 [?] = 105 (verificado por prefijo de linea).

## Iter. 9 — Historias de familias (Step-5-WorkBuddy, 2026-10-22, Log 2129)

Cluster **Familias** del 03-Diseno L35 (molinera, pescadores, guardas): 3 cadenas
nuevas en `data/historias/secundarias.json` (23 -> 26).

- `cadena-molinera` — NPC REAL `mateo_mapache` (granjero, `data/villagers/`), lugar
  `molino`, objeto REAL `OBJ-REL-003` «Reloj de arena» (`data/items/`, verificado por
  campo id dentro del .tres — `item_database.gd` indexa por ese id), puzzle
  `piedras-de-molienda`. Consecuencia pelada `molienda_familiar_restaurada`.
- `cadena-pescadores` — NPC REAL `finneas_zorro` (pescador), lugar `muelle_viejo`,
  objeto REAL `OBJ-HER-014` «Red de captura», puzzle `nudo-del-abuelo`. Consecuencia
  pelada `red_del_abuelo_reparada` (distinta de `red_pescador_reparada` de iter. 5).
- `cadena-guardas` — NPC REAL `nico_gato` (guardabosques), lugar `bosque_nocturno`,
  objeto REAL `OBJ-LUZ-011` «Candil», puzzle `ronda-de-los-guardas`. Consecuencia
  pelada `vigilia_de_los_guardas` (distinta de `patrulla_nocturna` de iter. 8).

Anti-repetición: 3 consecuencias peladas nuevas sin colisión con las 24 previas
(23 en datos + `biblioteca_iluminada` de ejemplos) y 3 capítulos `capitulo-*` de diario
nuevos sin colisión; contextos narrativos >= 10 caracteres, 4 pasos cada una
(hablar/explorar/entregar/puzzle), validados por el validador del servicio.

- Suite `scripts/historias/test_historias.gd`: bloque N `_test_familias()` (31 checks:
  6 carga/fuente + 2 unicidad de flags + 1 diarios + 7x3 end-to-end + 1 puente diario)
  al FINAL de `_run()`. Piso 227 -> **258 checks / 0 fallos / EXIT 0 x3** (binario real).
  Conteos de los bloques A e I actualizados 24/23 -> 27/26 (medidos; la 1a corrida dio
  3 fallos de conteo, corregidos). Guardián EN ROJO por inyección de runtime
  (Variant con Array -> Dictionary tipado) sobre el bloque N: EXIT 1, «el bloque N NO
  se ejecuto» + «solo 228 checks ejecutados (minimo 258)»; sonda borrada, sha256 del
  original verificado.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0 + `test_flujo_xp_recompensa_m71_hy3.gd` 37/0, M59
  `test_rotate_m59.gd` 43/0 (9 bloques) + `test_backup_rotate_return.gd` 4/0 +
  `test_backup_rotations.gd` 7/0 y M55 `test_diario.gd` 0 fallos. Todas EXIT 0 con el
  binario real, 0 SCRIPT ERROR.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien para
  las 3 nuevas (`mision_cadena-guardas` ausente del catalogo de M55; mismo patron que
  cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L y cadena-brujula
  en M).
- Flips del 05-Checklist con cita: «Crear la historia de la familia molinera»,
  «...pescadores» y «...guardas» [ ] -> [x] (L44-L46). M23 = 61 [x] / 42 [ ] / 2 [?]
  = 105 (verificado por prefijo de línea). Las DOS líneas de totales estaban
  desincronizadas (L170 mentía 55/48/2: los flips de iter. 7 y iter. 8 no se habían
  volcado): ambas sincronizadas a 61/42/2.


## Iter. 10 — Historias de amistad (Step-5-WorkBuddy, 2026-10-22, Log 2131)

Cluster Amistad del 03-Diseno L44 («regalo favorito, sentadilla de pesca, paseos,
ficción»; el 02-Analisis L25 pide 6 misiones con 5 temas nombrados — la 6.a, «cartas
de amistad», es extensión declarada del cluster, sin dueño externo). 6 cadenas nuevas
en `data/historias/secundarias.json` (26 -> 32) con NPC REALES de data/villagers/
(olivia_nutria tejedora, finneas_zorro pescador, sofia_buho bibliotecaria, aria_ciervo
trovadora, mercedes_lince mercader, luna_zorra artesana) y objetos REALES de
data/items/ (OBJ-ROP-005 «Bufanda», OBJ-ITE-036 «Té», OBJ-NAT-022 «Flor rara»,
OBJ-NAT-023 «Flor luminiscente», OBJ-ITE-035 «Miel», OBJ-NAT-004 «Flor silvestre»,
verificados por campo id dentro del .tres, que es el índice de item_database.gd).
Contextos narrativos >= 10 caracteres, 4 pasos cada una (hablar/explorar/entregar/
puzzle), 6 consecuencias peladas únicas (32/32 sobre el catálogo) y 6 capítulos de
diario únicos (31/31).

- Suite `scripts/historias/test_historias.gd`: bloque O `_test_amistad()` (58 checks:
  12 carga/fuente + 2 unicidad de flags + 1 diarios + 7x6 end-to-end + 1 puente diario)
  al FINAL de `_run()`. Piso 258 -> **316 checks / 0 fallos / EXIT 0 x3** (binario real).
  Guardián EN ROJO por inyección de runtime (`Variant` con `Array` -> `Dictionary`) al
  inicio del bloque O: EXIT 1, «el bloque O NO se ejecuto» + «solo 259 checks ejecutados
  (minimo 316)»; sonda borrada en la misma operación, sha256 del original verificado.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0, M59 `test_rotate_m59.gd` 43/0 (9 bloques) +
  `test_backup_rotate_return.gd` 4/0 + `test_backup_rotations.gd` 7/0 y M55
  `test_diario.gd` 0 fallos. Todas EXIT 0 con el binario real, 0 SCRIPT ERROR.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien para
  las 6 nuevas (`mision_cadena-regalo-favorito` ausente del catalogo de M55; mismo
  patron que cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L,
  cadena-brujula en M y cadena-guardas en N).
- Flips del 05-Checklist con cita: «Crear 6 misiones de amistad (regalo, pesca,
  paseos, ficción)» [ ] -> [x] (L84). M23 = 62 [x] / 41 [ ] / 2 [?] = 105 (verificado
  por prefijo de línea). Las DOS líneas de totales sincronizadas a 62/41/2.
- Nota de cierre: la corrida que ejecutó la tanda dejó la marca y los datos en disco
  (committeados por el CRON) pero se cortó antes de escribir esta sección, el Log 2131
  y el reporte al director. La verificación (suite x3, guardián en rojo, regresiones)
  se rehizo íntegra en la corrida de cierre del mismo día: los números de este apartado
  son MEDIDOS, no heredados.

## Iter. 11 — Cadenas secretas ocultas (Step-5-WorkBuddy, 2026-10-22, Log 2134)

Cluster Secretas (ocultas) del 03-Diseno L38 («5 cadenas desbloqueadas por mundo»;
regla de descubrimiento ya implementada y verificada en el bloque E:
`oculta:true` -> invisibles en `cadenas_disponibles()` hasta iniciarse,
`secondary_stories_service.gd` L71). 5 cadenas nuevas en
`data/historias/secundarias.json` (32 -> 37) con NPC REALES de data/villagers/
(nico_gato guardabosques, vera_ardilla farera, sofia_buho bibliotecaria, teo_conejo
herbolario, luna_zorra artesana) y objetos REALES de data/items/ verificados por
campo id dentro del .tres (OBJ-SEC-002 «Mapa secreto», OBJ-SEC-003 «Cristal oculto»,
OBJ-SEC-005 «Diario antiguo», OBJ-ART-002 «Pergamino místico», OBJ-ART-004 «Máscara
ceremonial»). Contextos narrativos >= 10 caracteres, 4 pasos cada una
(hablar/explorar/entregar/puzzle), 5 consecuencias peladas únicas (37/37 sobre el
catálogo, sin colisión con las 33 previas) y 5 capítulos de diario únicos (37/37).
Edición puramente aditiva sobre el JSON (+75/-0 líneas, formato Godot preservado,
LF puro sin BOM verificado por bytes).

- Suite `scripts/historias/test_historias.gd`: bloque P `_test_secretas()` (35 checks:
  15 carga/fuente/oculta + 2 ocultamiento + 1 visibilidad + 2 unicidad de flags +
  1 diarios + 2x7 end-to-end + 1 reset de estado + 1 puente diario) al FINAL de
  `_run()`. Piso 316 -> **351 checks / 0 fallos / EXIT 0 x3** (binario real).
  Guardián EN ROJO por inyección de runtime (`Variant` con `Array` -> `Dictionary`)
  al inicio del bloque P: EXIT 1, «el bloque P NO se ejecuto» + «solo 317 checks
  ejecutados (minimo 351)»; sonda borrada en la misma operación, git status del
  directorio verificado vacío salvo la suite.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0, M59 `test_rotate_m59.gd` 43/0 (9 bloques) +
  `test_backup_rotate_return.gd` 4/0 + `test_backup_rotations.gd` 7/0 y M55
  `test_diario.gd` + `test_diario_persist.gd` 0 fallos. Todas EXIT 0 con el binario
  real, 0 SCRIPT ERROR.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien
  para las 5 nuevas (`mision_cadena-mapa-secreto` ausente del catalogo de M55; mismo
  patron que cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L,
  cadena-brujula en M, cadena-guardas en N y cadena-regalo-favorito en O). No se
  inventa contenido de M55.
- Flip del 05-Checklist con cita: «Crear 5 cadenas secretas ocultas» [ ] -> [x]
  (L56). M23 = 63 [x] / 40 [ ] / 2 [?] = 105 (verificado por prefijo de línea). Las
  DOS líneas de totales sincronizadas a 63/40/2. El ítem «Documentar historias
  estacionales y secretas» (L58) sigue [ ]: es compuesto y las estacionales son de
  M32 (0 en disco) — no se flippa por la mitad (patrón anti-inflación de iter. 6).

## Iter. 12 — Historias de comerciantes (Step-5-WorkBuddy, 2026-10-22, Log 2135)

Cluster Comerciantes del 03-Diseno L36 («3 cadenas de rutas y secretos»). La
integración con M37 (ítem L152 del checklist) queda EXCLUIDA por orden del
director (msg 181, 2026-10-22): la tanda cubre solo las cadenas M23. 3 cadenas
nuevas en `data/historias/secundarias.json` (37 -> 40) con NPC REALES de
data/villagers/ (mercedes_lince **mercader** — el rol real del dato en disco —,
olivia_nutria sastra, ramon_tejon herrero) y objetos REALES de data/items/
verificados por campo id dentro del .tres (OBJ-ITE-052 «Moneda de oro»,
OBJ-ITE-010 «Tela», OBJ-TAL-002 «Yunque»). Contextos narrativos >= 10 caracteres,
4 pasos cada una (hablar/explorar/entregar/puzzle) y lugares de exploración
nuevos sin colisión (ruta_comercial, almacen_del_camino, taller_viejo). A
diferencia de las secretas de iter. 11, las 3 nacen visibles (`oculta:false`):
son rutas de trueque que se descubren hablando, no secretos de mundo. 3
consecuencias peladas únicas (40/40 sobre el catálogo) y 3 capítulos de diario
únicos (39/39: una cadena preexistente no declara diario). Verificación de
colisiones ANTES de escribir: ids, consecuencias, diarios, refs de puzzle y
lugares = 0 colisiones con las 37 previas. Edición puramente aditiva sobre el
JSON (+45 líneas, formato Godot preservado, LF puro sin BOM verificado por
bytes).

- Suite `scripts/historias/test_historias.gd`: bloque Q `_test_comerciantes()`
  (28 checks: 9 carga/fuente/no-oculta + 1 visibilidad en disponibles + 2
  unicidad de flags + 1 diarios + 2x7 end-to-end + 1 puente diario) al FINAL de
  `_run()`; BLOQUES A-Q y conteos de A/I actualizados (38 -> 41 cargadas,
  principal 37 -> 40). Piso 351 -> **379 checks / 0 fallos / EXIT 0 x3**
  (binario real, 0 SCRIPT ERROR).
- Guardián EN ROJO por inyección de runtime (`Variant` con `Array` ->
  `Dictionary`) al inicio del bloque Q: EXIT 1, «el bloque Q NO se ejecuto» +
  «solo 352 checks ejecutados (minimo 379)»; sonda borrada en la misma
  operación y sha256 del archivo restaurado byte-exacto
  (56f5878ba31bb4e1c68478a7613355543624864a5428c898a3ca2b83647ebfe6).
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0, M59 `test_rotate_m59.gd` 43/0 (9 bloques) +
  `test_backup_rotate_return.gd` 4/0 + `test_backup_rotations.gd` 7/0 y M55
  `test_diario.gd` + `test_diario_persist.gd` 0 fallos. Todas EXIT 0 con el
  binario real, 0 SCRIPT ERROR.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio
  tambien para las 3 nuevas (`mision_cadena-ruta-del-mercader` ausente del
  catálogo de M55; mismo patrón que cadena-biblioteca en H, cadena-jardines en
  K, cadena-puente en L, cadena-brujula en M, cadena-guardas en N,
  cadena-regalo-favorito en O y cadena-mapa-secreto en P). No se inventa
  contenido de M55.
- Flips del 05-Checklist con cita: «Crear las historias de 3 comerciantes» [ ]
  -> [x] (L47) y «Documentar historias de familias y comerciantes» [ ] -> [x]
  (L48, compuesta: §Iter. 9 + §Iter. 12). M23 = 65 [x] / 38 [ ] / 2 [?] = 105
  (verificado por prefijo de línea). Las DOS líneas de totales sincronizadas a
  65/38/2. El ítem «Integrar con M37 (comerciantes)» (L152) sigue [ ] con su
  dueño externo.
- Autocorrección de la corrida: el primer cálculo de totales del script de
  flip dio 66/37/2 (3 cadenas contadas como 3 flips); la verificación por
  prefijo integrada al script lo detectó ANTES de escribir — son 2 flips
  (L47 + L48) -> 65/38/2. El archivo nunca se escribió con la cifra falsa.

## Iter. 13 — Puzzles e Investigación (Step-5-WorkBuddy, 2026-10-22, Log 2137)

Clusters Puzzles (03-Diseno L46: «6 misiones de puzzles — templos 24/25/26,
ruinas ocultas») e Investigación (03-Diseno L45: «5 misiones de investigación
— faro, biblioteca, geodesia, mapas»), consolidados en UNA sola tanda por
orden del director (msg 183, 2026-10-22). 11 cadenas nuevas en
`data/historias/secundarias.json` (40 -> 51; 52 con la de ejemplo que suma la
carga).

Investigación (5): registro del faro (vera_ardilla farera + OBJ-LUZ-012
«Linterna», puzzle alturas-de-la-luz, lugar faro), catálogo perdido
(sofia_buho bibliotecaria + OBJ-EST-006 «Vitrina», signos-en-los-margenes,
biblioteca), medidas de la isla (pablo_pato ceramista + OBJ-REL-002 «Reloj de
péndulo», sombras-del-mediodia, observatorio), mapa de las plantas
(teo_conejo herbolario + OBJ-HER-015 «Lupa», tinta-de-hojas, jardines) y
cartas estelares (sofia_buho + OBJ-LUZ-008 «Lámpara de cristal»,
reloj-de-estrellas, observatorio — extensión declarada del núcleo de
investigación: el 03-Diseno L45 nombra 4 temas y el ítem pide 5).

Puzzles (6): templo de las 24 marcas (pablo_pato + OBJ-TAL-004 «Rueda de
alfarero», sellos-de-arcilla, templo_24), templo de los 25 engranajes
(bruno_sapo carpintero + OBJ-HER-018 «Sierra», mecanismo-escondido,
templo_25), templo de las 26 mareas (luna_zorra artesana + OBJ-PLA-004
«Orquídea», tintes-del-templo, templo_26), ruinas del barrizal (catalina_oso
cocinera + OBJ-ITE-021 «Pan», ofrenda-de-la-ruina, barrizal), ruinas del
manantial (teo_conejo + OBJ-NAT-024 «seta», raices-en-la-piedra, manantial) y
ruinas del acantilado (vera_ardilla + OBJ-LUZ-004 «Veladora»,
eco-de-las-ruinas, acantilado).

NPC REALES de data/villagers/ (7, cada uno con su rol en disco: vera_ardilla
farera, sofia_buho bibliotecaria, pablo_pato ceramista, teo_conejo herbolario,
bruno_sapo carpintero, luna_zorra artesana, catalina_oso cocinera) y objetos
REALES de data/items/ verificados por campo id dentro del .tres (11 objetos,
ninguno reutilizado de cadenas previas). Contextos >= 10 (medidos: 111-138
caracteres), 4 pasos cada una (hablar/explorar/entregar/puzzle) y las 11
nacen visibles (`oculta:false`): se descubren hablando, como las comerciantes
de iter. 12. Verificación de colisiones ANTES de escribir: ids,
consecuencias, capítulos de diario y refs de puzzle = 0 colisiones con las 40
previas; lugares = 4 nuevos (templo_24, templo_25, templo_26, biblioteca) y 6
reutilizados por diseño (faro, jardines, observatorio, barrizal, manantial,
acantilado — los que nombra el 03-Diseno L45/L46). Consecuencias peladas
únicas: 51/51 sobre el catálogo en disco (52/52 sobre la carga con el
ejemplo) y 11 capítulos de diario únicos (50 cadenas con diario sobre 52
cargadas: 2 preexistentes no declaran). Edición puramente aditiva sobre el
JSON (+396 líneas, 0 borradas; formato Godot preservado, LF puro sin BOM
verificado por bytes).

- Suite `scripts/historias/test_historias.gd`: bloque R
  `_test_puzzles_investigacion()` (77 checks: 33 carga/fuente/no-oculta + 1
  visibilidad en disponibles + 2 unicidad GLOBAL de flags medida sobre la
  carga real — reemplaza la lista transcrita a mano, que podía omitir un flag
  y dar un falso verde de unicidad — + 7 NPC REALES por efecto + 11 objetos
  REALES por campo id + 1 diarios + 3x7 end-to-end + 1 puente diario) al
  FINAL de `_run()`; BLOQUES A-R y conteos de A/I actualizados (41 -> 52
  cargadas, principal 40 -> 51). Piso 379 -> **456 checks / 0 fallos /
  EXIT 0 x3** (binario real, 0 SCRIPT ERROR).
- Guardián EN ROJO por inyección de runtime (`Node` null -> `free()`) al
  inicio del bloque R: EXIT 1, «el bloque R NO se ejecuto (posible SCRIPT
  ERROR que aborto la funcion)» + «solo 380 checks ejecutados (minimo 456)»;
  sonda borrada en la misma operación, sha256 del archivo restaurado
  byte-exacto y `git status` de scripts/historias/ vacío.
- Regresiones medidas tras la tanda: M55 `test_diario.gd` y
  `test_diario_persist.gd` 0 fallos, M59 `test_autosave_m59.gd` 0 fallos,
  M71 `test_bug_reevaluar_m71_hy3.gd` 8/2 (los 2 fallos son la reproducción
  del BUG-143 conocido, previa a la tanda). El validador
  `validate_quest_chains.gd` no se pudo medir: cuelga en modo `--script`
  headless (SceneTree sin `quit()`, condición previa ajena a la tanda).
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio
  también para cadena-registro-del-faro (`mision_cadena-registro-del-faro`
  ausente del catálogo de M55; mismo patrón que los bloques H/K/L/M/N/O/P/Q).
  No se inventa contenido de M55.
- Flips del 05-Checklist con cita: «Crear 5 misiones de investigación» [ ]
  -> [x] (L85), «Documentar misiones de amistad e investigación» [ ] -> [x]
  (L87, compuesta: §Iter. 10 + §Iter. 13), «Crear 6 misiones de puzzles» [ ]
  -> [x] (L91) y «Documentar misiones de puzzles» [ ] -> [x] (L93). M23 =
  69 [x] / 34 [ ] / 2 [?] = 105 (verificado por prefijo de línea). Las DOS
  líneas de totales sincronizadas a 69/34/2.

## Iter. 14 — Consecuencias con respaldo en disco + sincronización de la cola (Step-5-WorkBuddy, 2026-10-23, Log 2163)

Tanda de cierre documental, no de contenido nuevo: la COLA ACTIVA del
BACKLOG-MASTER estaba desincronizada con el módulo y la sección «Consecuencias y
diálogos posteriores» tenía ítems `[ ]` cuyo respaldo ya existía en disco.

- **Des sincronización de la cola (medida):** los ítems «Crear las historias de 3
  comerciantes» y «Documentar historias de familias y comerciantes» figuraban
  `[ ]` en la COLA ACTIVA del `DOCUMENTACION/TAREAS-POR-MODELO/step-5-workbuddy/
  BACKLOG-MASTER.md`, pero están `[x]` en este checklist (L47/L48) desde la
  **iter. 12 (Log 2135)**: `cadena-ruta-del-mercader`, `cadena-cargamento-de-telas`
  y `cadena-secreto-del-yunque` existen en `data/historias/secundarias.json` con
  NPC REALES (`mercedes_lince` mercader, `olivia_nutria`, `ramon_tejon`). Se
  sincroniza la cola (mi archivo), no el módulo.
- **Cobertura de las 12 consecuencias (03-Diseno L53) medida sobre los dos
  catálogos reales:** 8 con respaldo (`faro_encendido`, `jardin_florecido`,
  `plaza_decorada`, `puente_cruzable`, `cofradia_activa`, `molino_funcionando`,
  `estacion_reparada`, `biblioteca_iluminada`) y 4 sin respaldo
  (`taller_abierto`, `kiosko_abierto`, `camino_al_faro_despejado`,
  `puerto_ampliado`). Primera medición hecha solo sobre `secundarias.json` daba
  7/5: `biblioteca_iluminada` la aplica `cadena-biblioteca` del catálogo de
  ejemplos, que está mergeado y vivo desde la iter. 3 (Log 2083). El universo se
  mide antes de publicar la cifra.
- **Flips con cita:** «Crear la consecuencia "jardín florecido"» [ ] -> [x]
  (L108) y «Crear la consecuencia "cofradía activa"» [ ] -> [x] (L111). El
  respaldo no es el nombre en el diseño: es el flag aplicado por una cadena a
  WorldState (M21) vía `secondary_stories_service.gd` L232-236
  (`ws.set_flag(String(flag), bool(consec[flag]))` al completar la cadena),
  verificado end-to-end en el bloque S nuevo. «Crear la consecuencia "taller
  abierto"» (L109) queda `[ ]` honesto: 0 cadenas aplican el flag en ninguno de
  los dos catálogos y 0 hits del token en `res://data`.
- **Suite `scripts/historias/test_historias.gd`: bloque S
  `_test_consecuencias()`** (21 checks) al FINAL de `_run()`: cobertura de las 12
  consecuencias (8 con / 4 sin respaldo, con la fuente de `biblioteca_iluminada`
  afirmada), negativo acotado del token `taller_abierto` sobre `res://data` y
  end-to-end de `cadena-jardines` (mateo_mapache, jardines, baya_roja REAL,
  semillas-perdidas) y `cadena-cofradia` (mercedes_lince, cofradia,
  fragmento_ancestral REAL, sellos-antiguos) con `ws_has(...)` de los dos flags.
  Helper nuevo `_token_en_arbol(token, raiz)` con recorrido DirAccess recursivo.
  BLOQUES A-S. Piso 456 -> **477 checks / 0 fallos / EXIT 0 x2** (binario real,
  0 SCRIPT ERROR).
- **TRAMPA NUEVA (la estrella de la vuelta): el negativo se auto-pisó.** La
  primera versión del guardián buscaba el token `taller_abierto` en
  `res://data` Y `res://scripts`... y el propio archivo de test nombra el token
  en su lista de las 12, así que el guardian fallaba siempre contra sí mismo
  (1 hit = `res://scripts/historias/test_historias.gd`). Además, una mención en
  un script no es "respaldo" de la consecuencia: solo lo es el flag aplicado por
  una cadena. El negativo se acotó a `res://data` (datos del juego) y el alcance
  quedó declarado en el comentario y en el mensaje del check.
- **Segunda trampa de la vuelta: la primera medición de cobertura usaba UN solo
  catálogo.** Hecha sobre `secundarias.json` daba 7 con respaldo / 5 sin; sobre
  los dos catálogos (el de ejemplos está mergeado y vivo) da 8 / 4. La suite
  corrigió la cifra antes de que se publicara: los checks 1 y 2 del bloque S
  fallaron en la primera corrida con los números del universo chico.
- **Guardián EN ROJO por inyección de runtime:** sonda con
  `var _v: Variant = get_node_or_null(...)` -> `var _sonda: Dictionary = _v`
  (Variant -> Dictionary tipado) al inicio del bloque S. EXIT 1 con
  «el bloque S NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)» +
  «solo 457 checks ejecutados (minimo 477)» (2 fallos). La primera versión de la
  sonda asignaba directo `Node` a `Dictionary` y era error de PARSE: el archivo
  entero no compilaba y la prueba no probaba nada (falso rojo). La inyección
  válida pasa por un `Variant` intermedio. Sonda borrada, 0 archivos `*sonda*`
  en `scripts/historias/` y `git status` limpio de ese directorio.
- **Regresiones medidas tras la tanda (binario real, EXIT 0):** la propia suite
  477/0 x2; M22 `test_m22*.gd` y M71 progresión no se re-corrieron en esta
  vuelta (no hubo cambio de código de producción: la tanda edita datos de
  documentación y el archivo de test). Cambios de código de producción: 0.
- **Flips del 05-Checklist con cita:** L108 y L111 `[ ]` -> `[x]`; L109 queda
  `[ ]` con la medición escrita. M23 = **71 [x] / 32 [ ] / 2 [?] = 105**
  (verificado por prefijo de línea). Las DOS líneas de totales sincronizadas a
  71/32/2 (L170 arrastraba el valor de la iter. 11, 63/40/2, y ni la iter. 13
  ni esta se habían volcado ahí).
- **Sincronización de la COLA ACTIVA del BACKLOG-MASTER:** 2 ítems `[ ]` ->
  `[x]` con cita (comerciantes y documentar familias+comerciantes), más la nota
  de esta vuelta. La cola queda en 13 `[x]` / 103 `[ ]`.

## Iter. 15 — Misiones de exploración (Step-5-WorkBuddy, 2026-10-23, Log 2166)

Cluster Exploración del catálogo (03-Diseno L39: «| Exploración | 8 | brújula,
fauna (M65), cronitado de ruinas |»). El diseño nombra 3 temas para 8 misiones;
las 5 restantes son extensión declarada con el mismo patrón que Amistad (4+2) e
Investigación (4+1).

- **Las 8 cadenas en `data/historias/secundarias.json` (51 -> 59; 60 en carga
  con el merge de ejemplos):**
  1. `cadena-cartografia-de-la-isla` — «El Mapa de la Isla» (finneas_zorro;
     faro; OBJ-HER-016 «Lupa mejorada» REAL; puzzle rumbos-de-la-carta) —
     tema **brújula**.
  2. `cadena-fauna-de-la-isla` — «El Censo de Fauna» (teo_conejo; bosque;
     OBJ-NAT-027 «Liana» REAL; puzzle recuento-de-huellas) — tema **fauna**.
  3. `cadena-cronologia-de-las-ruinas` — «La Cronica de las Ruinas»
     (sofia_buho; biblioteca_quemada; OBJ-REL-004 «Reloj ancestral» REAL;
     puzzle orden-de-las-ruinas) — tema **cronitar ruinas**.
  4. `cadena-mirador-del-acantilado` — «El Amanecer del Acantilado»
     (aria_ciervo; acantilado; OBJ-LUZ-015 «Lámpara de lava» REAL).
  5. `cadena-grutas-del-manantial` — «El Agua de las Grutas» (catalina_oso;
     manantial; OBJ-LUZ-013 «Lámpara de sal» REAL).
  6. `cadena-playas-del-sur` — «El Relevamiento de las Playas» (olivia_nutria;
     playa_sur; OBJ-ITE-009 «Cuerda» REAL).
  7. `cadena-sendero-del-bosque` — «El Sendero Despejado» (nico_gato; bosque;
     OBJ-HER-004 «Hoz» REAL).
  8. `cadena-muelle-viejo` — «El Muelle Recuperado» (ramon_tejon; muelle_viejo;
     OBJ-ITE-013 «Clavos» REAL).
  Las 8 nacen visibles (`oculta:false`): se descubren hablando, como
  Comerciantes (iter. 12) y a diferencia de las Secretas (iter. 11).
- **NPC y objetos REALES medidos en disco antes de escribir:** los 8 NPC
  existen en `data/villagers/` y los 8 objetos existen en `data/items/` **por
  campo id** (efecto, no nombre de archivo); ninguno de los 8 objetos estaba
  usado por otra cadena. Consecuencias (8 flags nuevos, únicos contra las 51
  previas) y capítulos de diario (8, únicos). «Cronitar ruinas» se interpreta
  como **fechar/ordenar las ruinas** (02-Analisis L20: «cronitar ruinas»).
- **M65 (fauna) queda FUERA**, por el patrón que fijó el director para
  Comerciantes con M37 (msg 181): se crean las cadenas M23, no la integración
  con el sistema de fauna. No existe ítem de «foto» en `data/items/` (medido: 0
  coincidencias de foto/camara): el «llevar una foto a un punto» del 02-Analisis
  L20 se cubre con el paso `explorar` de cada misión.
- **Suite `scripts/historias/test_historias.gd`: bloque T
  `_test_exploracion()`** (66 checks) al FINAL de `_run()`: carga + fuente +
  no-oculta de las 8, exposición en `cadenas_disponibles()`, unicidad local de
  las 8 consecuencias y de los 8 diarios, 8 NPC REALES, 8 objetos REALES por
  campo id y end-to-end de 3 (cartografía, fauna, cronología) con
  `ws_has(...)`. BLOQUES A-T. Conteos globales actualizados: 51 -> 59
  principal, 52 -> 60 cargadas, 52 -> 60 flags de consecuencia. Piso
  477 -> **543 checks / 0 fallos / EXIT 0 x3** (binario real, 0 SCRIPT ERROR).
- **Guardián EN ROJO por inyección de runtime:** sonda con
  `var _sonda: Variant = 0` -> `var _roto: Dictionary = _sonda` al inicio del
  bloque T. EXIT 1 con «el bloque T NO se ejecuto (posible SCRIPT ERROR que
  aborto la funcion)» + «solo 478 checks ejecutados (minimo 543)» (2 fallos) +
  SCRIPT ERROR «Trying to assign value of type 'int' to a variable of type
  'Dictionary'». Sonda borrada y archivo restaurado byte-exacto (sha256
  3ab0c089... verificado antes y después).
- **Regresiones medidas tras la tanda (binario real, EXIT 0):** la propia
  suite 543/0 x3. No se re-corrieron M22/M71/M59/M55: la tanda no cambia código
  de producción (solo datos JSON y el archivo de test).
- **Flips del 05-Checklist con cita:** L64 «Crear 8 misiones de exploración» y
  L65 «Documentar cadenas y misiones de exploración» `[ ]` -> `[x]`. M23 =
  **73 [x] / 30 [ ] / 2 [?] = 105** (verificado por prefijo de línea). Las DOS
  líneas de totales sincronizadas a 73/30/2.
- **Hallazgo (dueño M55, no tocado):** el puente M23 -> M55 degrada en silencio
  también para las 8 nuevas (0 entradas `mision_cadena-*` en el catálogo de
  M55); mismo residual de las iteraciones 3/6/7/8/9/10/11/12/13/14. Verificado
  con el check del puente en el bloque T.
- **Nota de numeración:** mi informe de cierre de la vuelta anterior iba a ser
  el 196 y el director tomó ese número del pool; reenumerado a 197 = max+1.
  Esta vuelta: mensajes 199 (acuse) y el de cierre. La corrida que ejecutó la
  tanda reservó primero el 2164 (head medido 2164 justo antes), colisionó y
  re-reservó el 2166 (número que quedó citado en la suite y en el 05) pero se
  cortó antes de escribir el log: esta cita quedó en 2164. **Cierre del
  2026-10-24 (Log 2166):** la tanda fue re-verificada íntegra (un verde no se
  hereda) y los entregables reparados. Medidas propias del cierre: suite
  **543 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR**; guardián EN ROJO por
  inyección de runtime `Variant` -> `Dictionary` sobre el bloque T:
  **EXIT 1, 478 checks, 2 fallos** (nombra el bloque T + piso no cumplido),
  sonda borrada y suite intacta por sha256 (bec8fcae...); 16/16 NPC y objetos
  REALES verificados en disco por campo `id` (14 villgers, 300 ítems); 0
  consecuencias duplicadas. Regresiones corridas en el cierre (la corrida
  original no las había corrido): M59 rotate 43/0 (9 bloques) +
  backup_rotate_return 4/0 + backup_rotations 7/0; M71 flujo XP 37/0; M55
  diario perf 26/0 + persistencia 0 fallos; M71 `test_bug_reevaluar` 8/2
  EXIT 1 = **BUG-143 preexistente** (abierto, dueño M71). El 2164 consumido
  por la corrida cortada queda como hueco inocuo; el log de la iter. 15 es el
  2166.

## Iter. 16 — Misiones de construcción (Step-5-WorkBuddy, 2026-10-24, Log 2169)

Cluster Construcción del 05-Checklist (L69/L70/L71/L72/L73). Cierra L69; L70
queda [ ] con dueño M28 y L73 (compuesta: construcción Y agricultura) no se
flippa por la mitad.

- **Hallazgo de estado (familia It. 10 / It. 15):** al abrir la tanda,
  `data/historias/secundarias.json` tenía **62 cadenas**, no 59: 3 cadenas
  nuevas de construcción (`cadena-construccion-plaza` -> `plaza_empedrada`,
  `cadena-construccion-senderos` -> `senderos_del_pueblo_reparados`,
  `cadena-construccion-kiosko` -> `kiosko_abierto`) con mtime 2026-10-24
  04:04:54, posteriores al cierre de la iter. 15 (msg 201, 03:01), **sin log,
  sin mensaje y sin bloque de suite**: corrida cortada de este automatismo.
  El CRON las barrió en `f6a07c6` (04:13). Con el dato nuevo la suite quedó
  **ROJA: 6 fallos / 543 checks / EXIT 1** (medido 05:13) — todos asserts de
  conteo que esperaban 59/60.
- **Regla aplicada: NO rehacer — RE-VERIFICAR íntegra y REPARAR** (regla de
  recuperación ratificada por el director en su msg 202).
- **Realidad verificada por campo `id` (no por nombre de archivo):** NPC REALES
  `bruno_sapo` (carpintero), `nico_gato` (guardabosques), `pablo_pato`
  (ceramista) en `data/villagers/`; objetos REALES `OBJ-ITE-002` "Piedra",
  `gravel` "Grava" y `OBJ-ITE-001` "Madera" en `data/items/` (leídos del campo
  `id` de cada `.tres`). Las 3 cadenas son válidas de schema (4 pasos, tipos
  conocidos, contexto >= 10 chars, recompensa + consecuencia, títulos únicos).
- **Suite `test_historias.gd` — bloque U `_test_construccion()` NUEVO** (+37
  checks): carga/fuente/no-oculta de las 3 cadenas + los 3 temas con cadena
  previa (cofradía, jardines, puente), expuestas en `cadenas_disponibles()`,
  unicidad local de consecuencias y de capítulos de diario, NPC/objetos REALES
  por campo id, 2 end-to-end con `ws_has` (`kiosko_abierto`,
  `senderos_del_pueblo_reparados`), puente diario M23->M55 como finding medido
  e higiene de flags. Reparados los 6 asserts de conteo (59/60 -> 62/63).
- **Evidencia:** suite **580 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR
  (binario real). Piso 543 -> **580 MEDIDO en verde**. Guardián EN ROJO por
  inyección de runtime `Variant` -> `Dictionary` sobre el bloque U:
  **EXIT 1, 544 checks, 2 fallos** («el bloque U NO se ejecuto» + «solo 544
  checks (minimo 580)»); sonda borrada y suite restaurada byte-exacta (LF
  puro, sin BOM).
- **Corrección de la cobertura de las 12 consecuencias (03-Diseno L53):**
  8 -> **9 con respaldo** y 4 -> **3 sin respaldo**; `kiosko_abierto` pasa a
  tener respaldo real vía `cadena-construccion-kiosko`. Quedan sin respaldo
  `taller_abierto` (guarda del ítem L109), `camino_al_faro_despejado` y
  `puerto_ampliado`.
- **Regresiones (binario real):** M59 rotate 7/0 + backup_rotate_return 4/0 +
  slots/perfiles 41/0 + carga NPC/misiones 63/0; M71 flujo XP 37/0; M55 diario
  perf 26/0 + persistencia 0 fallos.
- **Flips del 05-Checklist con cita:** L69 «Crear 6 misiones de construcción
  (puentes, cofradía, plaza, senderos, kiosko, jardín)`[ ]` -> `[x]` — los 6
  temas con cadena en disco (cofradía/jardines iter. 6, puente iter. 7 con tema
  de reparación, plaza/senderos/kiosko esta iterada). M23 = **74 [x] / 29 [ ] /
  2 [?] = 105** (prefijo de línea). Las DOS líneas de totales sincronizadas.
- **Hallazgo (dueño M55, no tocado):** el puente M23 -> M55 degrada en silencio
  también para las 3 nuevas (0 entradas `mision_cadena-*` en el catálogo de
  M55); mismo residual de las iteraciones 3/6/7/8/9/10/11/12/13/14/15.
  Verificado con el check del puente en el bloque U.
