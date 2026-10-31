**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-30

# Auditoría de autocontradicciones en los `05-Checklist.md` (barrido repo-wide)

> **Encargo:** TANDA 7, bloque 1 (msg 467 de agnes-3-flash). El caso M85 (26 ítems `[x]` con nota
> "INFLADO"/"los artefactos NO existen") se detectó a mano; este barrido busca el resto.
>
> **Herramienta:** `scripts/auditar_autocontradicciones.py` (nueva, `--selftest` 20/20 y guarda de
> ceguera `exit 3`). Reproducible: `python scripts/auditar_autocontradicciones.py [--json]`.

## 1. Qué se midió

- **168 checklists** `plan-actual/05-Checklist.md` (todos los módulos con plan vigente).
- **24204 ítems** totales; **22995 marcados `[x]`**.
- Solo se audita la **nota** del ítem (lo que va después del primer separador `—`, `|`, `→`,
  `--`): la **descripción** puede decir "sin implementar" porque es el enunciado del requisito.
- Se agrupan las **notas partidas en varias líneas** (el grep de una línea no las ve).

## 2. Resultado

| Clase | Cantidad | Qué significa |
|---|---|---|
| **AUTOCONTRADICCIÓN** | **44** | `[x]` + veredicto negativo sobre el propio artefacto, **sin** cierre posterior |
| MIXTO (leer) | 130 | veredicto negativo **+** marca de cierre posterior (flip/restaurado/corregido) |
| SOSPECHOSO | 6 | solo vocabulario ambiguo ("inexistente") sin contexto de comportamiento |

De las **44** autocontradicciones, **38** se confirmaron leyendo el ítem y
**6** resultaron **falsos positivos** del detector (sección 4). Precisión medida:
**38/44 = 86 %**.

> **⚠️ ESTA CIFRA FUE CORREGIDA EN LA MISMA VUELTA.** Re-verificadas las 38 contra disco, **5 no
> eran autocontradicciones** (el artefacto se había creado después del veredicto, o el cierre venía
> con backticks). Cifra vigente: **39 hallazgos, 33 reales, precisión 33/39 = 85 %**. Detalle y
> evidencia ítem por ítem en la **sección 9**. Las secciones 1-8 se conservan como registro de la
> primera medición.

Reparto por módulo: **M140 (21), M137 (6), M139 (4), M10 (2), M94 (2), M157 (1), M38 (1), M65 (1)**.

## 3. Las 38 autocontradicciones confirmadas

> Lectura: el ítem está `[x]` y su propia nota dice que el artefacto no existe, que está degradado
> o que sigue pendiente. **Ninguna marca se tocó:** los flips los aplica el director.

| Módulo | Línea | Regla | Nota (recortada) |
|---|---|---|---|
| M10 | 26 | A7 | - DEGRADADO 2026-10-15 (step-5 410, muestreo Patron D): fractal_octaves reales 2/3/4 (terrain 4, island 3, biome 2) vs 4-6 requeridas en el item · evi |
| M10 | 53 | A7 | - DEGRADADO 2026-10-15 (step-5 412, grep repo-wide): 0 hits de reaplicacion de diffs; regenerar_chunk (debug_menu.gd L554-566) solo hace vt.invalidate |
| M38 | 41 | A6 | - PARCIAL: saldo (núcleo) + historial (iter.2, log 538) + reputación (iter.3, log 544) persisten; inventarios de tienda pendientes (M39) *(QA atria-da |
| M65 | 115 | A7 | - **⚠️ QA agnes-3-flash (Log 1145, P-31): degradado [x]->[?] por BUG-080.** La "verificación estática" de pack/school queda invalidada: el test `tests |
| M94 | 55 | A7 | -> agnes-2.5-flash 2026-09-12: diseño documentado in 03-Diseno.md §14.3 (final mystery 5h+ in postgame); content deferred to M22/M23. Policy defined.  |
| M94 | 60 | A7 | -> agnes-2.5-flash 2026-09-12: spec documented in 03-Diseno.md §15.2 (5h+ postgame content); content deferred to M22/M27. Policy defined. - **DEGRADAD |
| M137 | 10 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - no existe `prototipo_isla.tscn`; la escena principal en project.godot es `res://scenes/mai |
| M137 | 11 | A7 | - DEGRADADO 2026-10-14 (step-5-kilocode): verificado contra disco - la carpeta `game/isla-ancestral/scenes/prototipo/` NO existe (las carpetas de scen |
| M137 | 13 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - no existe `game_state_proto.gd` (hay `GameState` y `save_*.gd` de producción, no el autolo |
| M137 | 15 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - no existe `world_seed.gd` y hay 0 hits de la semilla fija 20260819 en scripts/. · evidenci |
| M137 | 17 | A3,A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - la carpeta `game/isla-ancestral/docs/prototipo/` no existe (docs/ tiene 1 archivo suelto). |
| M137 | 210 | A7 | - DEGRADADO 2026-10-14 (step-5-kilocode): muestreo de 5 scripts con class_name (event_bus, fishing_manager, island_registry, save_schema, accesibilida |
| M139 | 74 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): conteo verificado en disco - de 1691 items con id en data/, solo 31 tienen campo de precio. Faltan ~30  |
| M139 | 158 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): de los 5 buses que pide el item, 4 existen verificados en audio_config_service.gd (Master base + Music, |
| M139 | 190 | A8 | - PENDIENTE DE EJECUCION 2026-10-14 (step-5-kilocode): no verificable por disco - requiere abrir el juego en Play Mode y comprobar la consola. Anotado |
| M139 | 192 | A8 | - PENDIENTE DE EJECUCION 2026-10-14 (step-5-kilocode): requiere Play Mode real (menu -> nuevo juego -> Aurora -> templo -> viaje a Coral -> guardar/ca |
| M140 | 15 | A2,A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): la interfaz `ICondicionDeSello` NO existe en disco (verificado). Queda definido su contrato (persistida |
| M140 | 24 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco - data/balance/quests.json tiene solo **2 misiones**. La tabla 2.3 pide 30+. De |
| M140 | 32 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco - data/balance/crafting.json tiene solo **7 recetas** de las 60+ que pide el it |
| M140 | 39 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): hay XP (4 hits) y niveles (80) pero 0 hits de 'habilidad' y 0 de 'ventaja' en scripts/progresion/. Sist |
| M140 | 40 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): no hay menu de progresion en scripts/ui/ (los hits de UI son de donation, museo y equipment). Pieza de  |
| M140 | 48 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits de regalo fabricado en scripts/. La integracion no existe. No inflado. |
| M140 | 50 | A3,A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): cadena cortada - los artefactos pasivos no existen (verificado en la seccion 2). No se puede probar. No |
| M140 | 54 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits en scripts/. Hoy el tiempo pasa por TimeCalendar (autoload) y el clima por weather_service.gd; l |
| M140 | 55 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits. Contrato definido en 2.7.1 (orquesta actos y sellos sin conocer misiones individuales) pero sin |
| M140 | 69 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco - data/balance/crafting.json tiene solo 7 recetas de las 60+ que pide M16. El b |
| M140 | 77 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - scripts/npc/ tiene 9 scripts y el elenco de M139 definio 8 NPC. Faltan ~16-22 NPC para el  |
| M140 | 78 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - data/coleccionables/catalog.json tiene solo 15 items de los 80 pedidos. Brecha de 65. No i |
| M140 | 79 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): el modulo 37-Museo existe y M139 definio 5 secciones (Naturaleza, Geologia, Botanica, Marina, Pesca), p |
| M140 | 80 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): hay 30 hits de fiesta/festival y catalogo_eventos.json (analytics), pero los 4 eventos base (1 por esta |
| M140 | 81 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - data/balance/crafting.json tiene solo 7 recetas de las 60+. Brecha de 53 (arrastra desde l |
| M140 | 84 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): no verificable por disco sin telemetria de sesion real. Queda anotado como verificacion de runtime. No  |
| M140 | 146 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado - el save esta en v1 (SCHEMA_VERSION=1) y save_loader.gd documenta 'v1 es la primera version |
| M140 | 156 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): los modos de color existen (8 hits: accesibilidad_schema, gestor_config, mapa_manager) pero hay 0 hits  |
| M140 | 157 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits de la combinacion diario+gamepad (si hay 29 hits de gamepad en general, incluido control_input.g |
| M140 | 158 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): los 5 hits son de otros sistemas; no hay un patron de estado vacio para colecciones. Definido en 4.2 co |
| M140 | 166 | A6 | - PENDIENTE REAL 2026-10-14 (step-5-kilocode): no verificable por disco - requiere Play Mode real en las 4 islas de Alpha. Anotado como verificacion d |
| M157 | 148 | A2 | - evidencia disco: `plan-actual/04-Codigo.md` lista 20 scripts "A Crear" + contratos. **ADVERTENCIA anti-drift (patrón M119): los scripts listados NO  |

### 3.1 Los dos casos más graves

- **M94 L55 y L60**: la nota dice *"DEGRADADO por el director (2026-10-10, QA §21.8): M114
  deferral disfrazado — el contenido/artefacto afirmado no existe hoy"* y **la marca sigue `[x]`**.
  Una degradación **ordenada** que nunca se aplicó al checklist.
- **M65 L115**: la nota dice *"degradado `[x]`→`[?]` por BUG-080"* y la marca es `[x]`: el flip
  está escrito en la nota pero no en el carácter de marca.

### 3.2 El bloque M140 (21 ítems)

Los 21 son del mismo tipo: ítem de definición marcado `[x]` con nota `PENDIENTE REAL 2026-10-14`
que mide la brecha contra disco (p. ej. *"quests.json tiene solo 2 misiones; la tabla pide 30+"*).
No son 21 casos distintos: son **una tanda de medición** que documentó la deuda y dejó la marca en
`[x]`. Es la decisión más grande pendiente del barrido (una sola política resuelve 21 ítems).

## 4. Falsos positivos del detector (6, con causa)

| Módulo | Línea | Por qué NO es contradicción |
|---|---|---|
| M26 | 183 | Habla del documento VIEJO (rutas Unity/C# que ya se reescribieron). No es veredicto sobre el ítem. |
| M53 | 149 | El QA concluyó que la paleta vive en código (`theme_ux.gd:13-14`): equivalencia aceptada, no falta artefacto. |
| M53 | 151 | QA aceptó el parcial con alias documentado: decisión ya firmada, no contradicción nueva. |
| M87 | 387 | Describe una convención inexistente (`items.<id>.name`) que el propio ítem da por descartada. No es veredicto sobre el ítem. |
| M92 | 149 | La premisa del ítem se anuló (el módulo 92 no tiene carpeta `ui/`): no hay artefacto que falte. |
| M156 | 127 | Sustitución data-driven documentada (la función vive en `data/terrenos/terrenos.json`): el `.gd` no existe pero el ítem tiene sustituto. **Decisión del director.** |

## 5. La clase MIXTO (130) no se descarta: se lee

Una nota puede decir "estaba inflado" **y** "FLIP aplicado" en la misma frase; ahí la marca es
legítima. El detector las separa para que nadie las confunda con deuda, pero **no** las declara
limpias: son 130 ítems donde el veredicto negativo y su cierre conviven y solo un humano
decide si el cierre alcanza. Muestra de por qué hay que leerlas:

```
M01 L68: - sol, lluvia, tormenta, niebla, nieve, transiciones, accesibilidad - REVERT iter.8 (sello denegado/degradado posterior; DeepSeek 
M01 L136: - Propiedad Intelectual [M] 🔴 - marcas, autoría, licencias, terceros - REVERT iter.8 (sello denegado/degradado posterior; DeepSeek
M01 L180: - miles de bloques, muchos NPC, sesiones largas - REVERT iter.8 (sello denegado/degradado posterior; DeepSeek 376)
M03 L64: \| REVERIFICADO 2026-10-15 (step-5-kilocode): `Logs/NUMEROS_DISPONIBLES.txt` existe y funciona (es el pool que uso a diario). La c
M09 L229: - tabla por bioma con rangos PCS y con formula de noise que divide como tu M129 (cita de "Presupuestos numericos II" 03) - FORMULA
```

## 6. Control positivo: M85 y M22 dan 0

El barrido **no** marca M85 (el caso que originó el encargo): tras el re-baseline 99/1/0 → 73/25/2
del 2026-10-30 ya no queda ningún `[x]` con nota "INFLADO". Tampoco M22. Un detector que marca
todo no distingue nada; estos dos ceros son la prueba de que discrimina.

## 7. Límites declarados del detector

- **Solo `plan-actual/`.** Los `plan-inicial/` son históricos y no se auditan.
- **Vocabulario cerrado.** Una nota que diga "falta implementar" o "no hay quien lo llame" sin usar
  ninguna de las 8 formas registradas **no** se detecta. El detector es de alta precisión, no de
  exhaustividad: un 0 no prueba que el módulo esté limpio.
- **No decide.** Clasifica. El flip de una marca es del director (regla del proyecto).
- **Semántica de "degradado".** Se excluye el contexto técnico (texturas/mallas) y las notas de lote
  que hablan de otros ítems; aun así quedan 6 falsos positivos de 44 (medidos, sección 4).

## 8. Cómo se probó la herramienta

- `--selftest`: **20/20**, con fixtures de ítem sucio, limpio y ambiguo, nota partida en dos líneas,
  control negativo (`[ ]` y `[?]` no cuentan) y **tres** casos de ceguera.
- **Sonda 1 (rojo):** romper la regla `A1` → 3 checks del selftest fallan, `EXIT 1`.
- **Sonda 2 (rojo):** neutralizar `evaluar_ceguera()` → los 3 checks de ceguera fallan, `EXIT 1`.
- Guarda de ceguera en producción: sin checklists, con checklist de 0 bytes o con 0 ítems `[x]`
  sale **`exit 3` (DETECTOR CIEGO)**, no `exit 0`.

## 9. Corrección de precisión (re-verificación contra disco, misma vuelta)

El barrido de la sección 2 se hizo sobre el **texto** de las notas. Al re-leer las 38 con
la intención de armar el dossier aparecieron **5 falsos positivos más**, todos por la misma
causa: **el detector no reconocía dos formas de cierre** que el propio ítem documenta.

| FP | Ítem | Qué dice la nota | Por qué no es autocontradicción |
|---|---|---|---|
| 1 | M137 L11 | "la carpeta `scenes/prototipo/` NO existe" | `· evidencia: carpeta creada en game/isla-ancestral/scenes/prototipo/ (Reflection-Beam-1.0, T47, 2026-10-22)` — **medido: la carpeta existe** |
| 2 | M137 L13 | "no existe `game_state_proto.gd`" | `· evidencia: scripts/prototipo/game_state_proto.gd creado (autoload)` — **medido: el archivo existe** |
| 3 | M137 L15 | "no existe `world_seed.gd` y 0 hits de 20260819" | `· evidencia: ... creado con SEED=20260819` — **medido: existe y la semilla está en L3** |
| 4 | M137 L17 | "la carpeta `docs/prototipo/` no existe" | `· evidencia: carpeta creada` — **medido: la carpeta existe** |
| 5 | M65 L115 | "degradado `[x]`→`[?]` por BUG-080" | cierra con `Marcado `[?]`→`[x]` (P-38, Log 1154)`; el patrón de flip no toleraba los **backticks** entre corchete y flecha |

**Causa raíz y arreglo (código, no opinión):**

- `RE_POSITIVO` no incluía `evidencia: <ruta> creado/creada` → los 4 de M137 entraban como
  autocontradicción. Añadido, **exigiendo la palabra `creado/creada`**: `evidencia: documentado
  en plan-actual` **no** cierra nada (es spec-only) y sigue contando como autocontradicción.
- El patrón de flip exigía `[?]->[x]` sin nada en medio; el texto real trae backticks
  (`` `[?]`→`[x]` ``). Añadido `` `? `` a ambos lados de la flecha.
- **Fallo de recall encontrado de paso:** `RE_COMPORTAMIENTO` excluía cualquier nota con `→`
  (pensado para derivaciones `→ agnes-2.5-flash`), y esa misma flecha aparece en los flips. Un
  ítem con flip quedaba **excluido** y su autocontradicción se perdía. Corregido con lookahead
  `(?:->|→)(?!\s*`?\[x\])`.

**Medición después del arreglo** (misma corrida, mismos 168 checklists):

| | Antes | Después |
|---|---|---|
| AUTOCONTRADICCIÓN | 44 | **39** |
| MIXTO | 130 | **135** |
| SOSPECHOSO | 6 | 6 |
| `--selftest` | 20/20 | **27/27** |

De los 39, siguen siendo falsos positivos los **6 ya documentados** en la sección 4 (M53 ×2,
M26, M87, M92, M156), que necesitan criterio semántico y no un patrón. **Reales: 33.**
Precisión corregida: **33/39 = 85 %** (la de la primera medición, 86 %, era sobre una base
que incluía 5 FP).

## 10. Dossier: ¿la nota sigue siendo cierta hoy?

Una nota de degradación fechada el 2026-10-14 puede haber caducado: si el artefacto se
implementó después, el `[x]` es legítimo y lo que está mal es la nota. Se midió **cada**
afirmación de las 33 reales contra el disco de hoy (31 sondas; 2 agrupan varios ítems).

**Veredicto:** VIVA = la nota sigue siendo cierta → el `[x]` es indefendible. MUERTA = ya no es
cierta → el `[x]` se sostiene y hay que corregir la nota. RUNTIME = no decidible por disco.

| Ítem | Veredicto | Medición de hoy |
|---|---|---|
| M10 L26 | **VIVA** | octaves en world_gen: [2, 3, 4] |
| M10 L53 | **VIVA** | hits reaplic/reaplicar diffs: 0 |
| M137 L10 | **VIVA** | tscn encontrados: 0; main_scene=res://scenes/main_island.tscn |
| M137 L210 | **VIVA** | gd=1564 con class_name=602 |
| M139 L74 | **VIVA** | items con id=2246, con precio=6 |
| M139 L158 | **VIVA** | buses=['Music', 'SFX', 'Ambient', 'Voice', 'UI', 'Cinematic']; ASMR presente=False |
| M140 L15 | **VIVA** | hits ICondicionDeSello: 0 |
| M140 L24 | **VIVA** | quests.json: clave=misiones n=2 |
| M140 L32/69/81 | **VIVA** | crafting.json: clave=recetas n=7 |
| M140 L39 | **VIVA** | habilidad=0 ventaja=0 |
| M140 L40 | **VIVA** | hits progresion en scripts/ui: 0 |
| M140 L48 | **VIVA** | hits regalo.*fabric: 0 |
| M140 L54 | **VIVA** | hits Almanaque: 0 |
| M140 L55 | **VIVA** | hits HistoriaMaster: 0 |
| M140 L77 | **VIVA** | scripts/npc .gd = 9 |
| M140 L78 | **MUERTA** | coleccionables: clave=(raiz) n=81 |
| M140 L146 | **VIVA** | SCHEMA_VERSION=1 |
| M140 L156 | **VIVA** | hits espejo/sombra en accesibilidad_aplicador.gd=0 |
| M140 L157 | **VIVA** | hits diario.{0,60}gamepad\|gamepad.{0,60}diario: 0 |
| M157 L148 | **VIVA** | citados=24, no existen en disco=23 (CartTransport.gd, CombatEvent.gd, DialogueEvent.gd, DiscoveryEvent.gd, EmergencyEvent.gd) |
| M38 L41 | **VIVA** | autoload=True; llamadores de guardar_estado=0 (produccion=0) |
| M65 L115 | **MUERTA** | test_m65.gd existe=True; hits PackLogic/SchoolLogic=30 *(FP #5 de la seccion 9: el item ya documenta su cierre)* |
| M140 L50 | **VIVA** | hits artefacto pasivo/progresion=0 |
| M140 L79 | **VIVA** | catalogos de museo en data/=0, entradas=0 |
| M140 L80 | **MUERTA** | festivals.tres: 5 festivales ['festival_primavera', 'festival_verano', 'festival_otono', 'festival_invierno', 'festival_luces'], estaciones cubiertas=[0, 1, 2, 3] |
| M140 L158 | **VIVA** | hits estado_vacio en scripts/ui=0 |
| M139 L190 | **RUNTIME** | no verificable por disco |
| M139 L192 | **RUNTIME** | no verificable por disco |
| M140 L84 | **RUNTIME** | no verificable por disco |
| M140 L166 | **RUNTIME** | no verificable por disco |
| M94 L55/L60 | **VIVA** | nota del propio director (QA 21.8): veredicto ya emitido |

**Resumen medido:** 27 VIVA · 2 MUERTA · 4 RUNTIME = **33 ítems reales**
(31 sondas; la de `M140 L32/69/81` cubre 3 ítems y la de `M94 L55/L60`, 2).

### 10.1 Qué implica cada veredicto (propuesta, no flip)

- **27 VIVA** → el `[x]` no se sostiene por el criterio del 2026-10-30 (artefacto que
  implemente la función **y** la ejercite por ruta real). Candidatos a degradar. M140 aporta
  **17 de 27**: es **un solo barrido**, no 17 casos distintos.
- **2 MUERTA** → M140 L78, M140 L80. El `[x]` queda bien; lo que hay que reescribir es la nota (dejarla
  fechada como histórica). **No es un flip.**
- **4 RUNTIME** → M139 L190, M139 L192, M140 L84, M140 L166. Ni `[x]` ni `[ ]` son honestos: el proyecto ya tiene la marca `[?]`
  para esto. Propuesta: `[?]` con la nota "requiere Play Mode / telemetría".

### 10.2 Límites de este dossier

- Se midió **presencia en disco y llamadores**, no comportamiento en ejecución. Un `0 hits`
  prueba ausencia de la cadena buscada, no que la función no exista con otro nombre.
- Cuatro sondas se rehicieron porque la primera versión medía otra cosa (dos contaban claves
  de JSON que en este repo son **dict** y no listas; una hacía grep repo-wide de
  "espejo/sombra" cuando la nota habla **del manager**; una contaba `estacional` en
  `scripts/` cuando la nota habla de **datos**). Las cuatro están corregidas en la tabla; las
  versiones erróneas se descartaron **antes** de publicar cifra.
