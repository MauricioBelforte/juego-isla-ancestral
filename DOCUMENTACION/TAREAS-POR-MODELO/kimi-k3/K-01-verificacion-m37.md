# K-01 — Verificación empírica del trabajo de kimi-k3 sobre M37-Museos-Y-Colecciones

**Modelo:** ling-3.1-flash
**Plataforma:** Kilo Gateway
**Fecha:** 2026-10-07
**Auditor:** ling-3.1-flash (K-01, encargo del director)
**Sujeto:** kimi-k3 (Verdent) — M37 reservado 2026-10-03 19:40, iter. 4
**Alcance:** SOLO LECTURA sobre M37. Entregable único: este archivo.

---

## 0. Resumen ejecutivo

- **Conteo:** el 36/148 declarado **coincide** con las marcas reales (medición regex: 36 `[x]`, 112 `[ ]`, 0 `[?]`, 148 total).
- **Evidencia por `[x]`:** de los 36, **30 tienen evidencia real en disco** (archivo:linea verificada), **5 son SIN EVIDENCIA** (L51, L53, L56, L68, L91 — heredados de iter. 1-3, sin implementación en disco) y **1 está DEGRADADO** (L213, documentación no alineada).
- **Suite headless:** **PASA** — `test_museo.gd` → **85 checks, 0 fallos, EXIT 0** con el binario real (godot472.exe). Los 12 bloques A-L cierran.
- **Trazabilidad de kimi-k3:** el código de iter. 4 (C.12 versionado + RF5 arte + bloques K/L + guardián anti-falso-verde) **existe y funciona**, pero la trazabilidad es de claims: **no hay Log 1253** (citado en el header del código), **no hay informe en su canal** (0 mensajes de kimi-k3), **no hay commit** (trampa 58: +320 líneas solo en working tree), **no marcó los ítems que implementó** (RF5 y C.12 siguen `[ ]`).
- **Veredicto:** kimi-k3 trabaja con **evidencia real en código** (el código compila y pasa headless), pero con **trazabilidad de claims** (log/channel/commit/marcas ausentes). 30/36 `[x]` verificados, 5/36 sin evidencia, 1/36 degradado.

---

## 1. Metodología

1. Lectura completa de `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` (259 líneas).
2. Conteo de marcas por regex sobre el archivo crudo (no sobre el claim).
3. Verificación de cada uno de los 36 `[x]` contra disco: `scripts/museum/`, `data/museum/`, `project.godot`, glob multi-ruta para archivos citados o esperados.
4. Ejecución de la suite headless con el binario real (dos variantes: con y sin `--check-only`).
5. Sonda T-4 (EventBus) sobre los 1853 `.gd` del proyecto.
6. Verificación de trazabilidad: `git status`, `git diff HEAD`, `git log --author`, pool `Logs/NUMEROS_DISPONIBLES.txt`, canal `Mensajes entre modelos/kimi-k3/`, backlog personal.
7. Verificación de drift: citas § contra `03-Diseno.md`, rutas contra `04-Codigo.md`, fila 37 contra `CHECKLIST-GLOBAL.md`.

---

## 2. Tabla item por item de los 36 `[x]`

Leyenda: OK = evidencia real en disco citada a archivo:linea · SIN EVIDENCIA = ningún artifacto en disco · DEGRADADO = evidencia parcial o contradicha.

| # | Item (L checklist) | Texto corto | Estado | Evidencia en disco / razón de degradación |
|---|---|---|---|---|
| 1 | L27 | Definir el problema: museo como sistema coleccionable | OK | `01-Requerimientos.md:13-15` (§1 Problema) — documental, no requiere código |
| 2 | L31 | RF2: donación fauna avistada desde M36 | OK | `data/museum/exhibiciones.json:34-43` (fauna, 7 especies reales M36); `test_museo.gd:135,285-287,301-308` |
| 3 | L32 | RF3: donación peces capturados desde M34 | OK | `exhibiciones.json:4-13` (peces: trucha_cascada, bacalao_nube, gobio_mar, anguila_brisa); `test_museo.gd:221-239` |
| 4 | L33 | RF4: donación fósiles y piezas de ruinas desde M25 | OK | `exhibiciones.json:14-23` (fosiles: fragmento_ancestral) |
| 5 | L35 | RF6: exposiciones completables con recompensa | OK | `collection_registry.gd:235-246` (otorgar_recompensa idempotente §4.2.4); `test_museo.gd:195-216` |
| 6 | L36 | RF7+RF8: registro de donaciones/colecciones/recompensas en M55 | OK | `donation_service.gd:52-55` (puente `bus.diary.entrada_nueva`); `test_museo.gd:314-332` |
| 7 | L45 | Decidir: CollectionRegistry como autoridad única | OK | `project.godot:73` (autoload); `collection_registry.gd:1-328` |
| 8 | L46 | Decidir: DonationService separado para validación y consumo | OK | `project.godot:74` (autoload); `donation_service.gd:1-95` |
| 9 | L51 | Clase Museum como nodo raíz de la escena del edificio | **SIN EVIDENCIA** | No existe `museum.gd` ni `museum.tscn` (glob `**/museum.gd` y `**/*museum*.tscn` = 0 resultados en todo el repo). `04-Codigo.md:15` lo lista como si existiera (drift) |
| 10 | L52 | Clase CollectionRegistry como autoload de registro y persistencia | OK | `collection_registry.gd:274-328` (get_section_name/get_save_data/restore_save_data, sección "collections" M59); `project.godot:73` |
| 11 | L53 | Clase ExhibitSlot para vitrinas instanciables por pieza | **SIN EVIDENCIA** | No existe `exhibit_slot.gd` (glob `**/*exhibit*` = 0 resultados en todo el repo). `04-Codigo.md:16` lo lista (drift) |
| 12 | L54 | Clase DonationService como autoload orquestador de donaciones | OK | `donation_service.gd:20-22` (3 señales tipadas); `project.godot:74` |
| 13 | L55 | Clase ExhibitionData (Resource) con lista de piezas y recompensa | OK (adaptado) | Adaptación data-driven honesta: `exhibiciones.json:1-55` (5 exposiciones); `collection_registry.gd:50-73` (_cargar_exposiciones). El propio item reconoce la adaptación |
| 14 | L56 | Clase ExhibitData (Resource) con metadatos de la pieza | **SIN EVIDENCIA** | No existe `exhibit_data.gd` (glob `**/*exhibit*` = 0). `04-Codigo.md:12` lo lista (drift) |
| 15 | L57 | Clase DonationResult con estado aceptado y motivo de rechazo | OK | `donation_result.gd:7-20` (`class_name DonationResult`, accepted/reason/exhibition_id/item_id) |
| 16 | L58 | IDs únicos por pieza (exposicion_id + item_id) como clave | OK | `collection_registry.gd:126-127` (is_registered por clave), `93-108` (register_item no-op idempotente §4.4.3); `test_museo.gd:174-175,209-211` |
| 17 | L59 | Esquema de carpetas res:// definido para scripts, escenas y datos | OK | `scripts/museum/` (4 .gd + test) y `data/museum/exhibiciones.json` existen. Nota: `scenes/interior/museum/` NO existe (el esquema está definido en `04-Codigo.md`, no creado) |
| 18 | L60 | Desacople total UI vs sistema de colección mediante señales | OK | `collection_registry.gd:30-31` (item_registered/exhibition_completed); `donation_service.gd:20-22` (donation_accepted/rejected/reward_granted) |
| 19 | L61 | Compatibilidad de extensión: nuevas exposiciones sin cambios estructurales | OK | `collection_registry.gd:50-73` (carga data-driven; agregar entrada al JSON sin tocar scripts); `test_museo.gd:131-136` |
| 20 | L68 | Puertas de salas funcionales con transición interior suave | **SIN EVIDENCIA** | No hay `museum.tscn` ni código de puertas/transiciones en `scripts/`. Ningún artifacto en disco |
| 21 | L91 | clear() devuelve el slot al estado libre sin perder configuración | **SIN EVIDENCIA** | No hay `exhibit_slot.gd`. Los 4 `func clear()` del proyecto (`typewriter_effect.gd:68`, `equipment_slot.gd:45`, `plan_stack.gd:90`, `npc_blackboard.gd:40`) son ajenos a M37 |
| 22 | L98 | Validación de item existente en el catálogo de la exposición | OK | `donation_service.gd:66-80` (validate() con pertenece()); `test_museo.gd:167-190` |
| 23 | L99 | Donación duplicada rechazada con motivo "duplicate" | OK | `donation_service.gd:75-76`; `test_museo.gd:174-175` |
| 24 | L100 | Donación de item de otra exposición rechazada "wrong_exhibition" | OK | `donation_service.gd:72-73,83-87` (_existe_en_otra); `test_museo.gd:180-182` |
| 25 | L101 | Donación de item inexistente rechazada "invalid_item" | OK | `donation_service.gd:68-69,74`; `test_museo.gd:184-185` |
| 26 | L102 | Donación de item no poseído rechazada "not_owned" | OK | `donation_service.gd:77-79`; `test_museo.gd:177-178` |
| 27 | L107 | Señal donation_accepted para UI, audio y diario | OK | `donation_service.gd:20,46`; `test_museo.gd:151-158` (señal emitida afirmada) |
| 28 | L135 | Notificación especial visual y de audio al completar exposición | OK (toast; audio dueño M43) | `collection_registry.gd:111-123` (_emitir_toast_completada vía `bus.ui.notify`, dominio interno UIEvents); `test_museo.gd:244-267` |
| 29 | L136 | Compatibilidad con el sistema de logros (M71) | OK | `donation_service.gd:48-51` (`profile.incrementar("donaciones_museo", 1)` duck-typed); `test_museo.gd:293-309` (afirma +1) |
| 30 | L141 | Registro de cada donación aceptada en el diario (M55) | OK | `donation_service.gd:52-55`; `test_museo.gd:314-332` |
| 31 | L146 | Emisión de señales tipadas sin acoplarse a la UI del diario | OK | `donation_service.gd:20-22` (señales propias; receptor M55 duck-typed, no importado) |
| 32 | L152 | Donación duplicada rechazada sin consumir inventario | OK | `donation_service.gd:29-32` (validate() ANTES de consumir; §4.3.3); `test_museo.gd:186-188` (inventario intacto afirmado) |
| 33 | L167 | Estado del registro guardado con la partida | OK | `collection_registry.gd:278-286` (get_save_data), `292-298` (restore_save_data); `test_museo.gd:337-349` (round-trip) |
| 34 | L168 | Estado de recompensas otorgadas guardado | OK | `collection_registry.gd:285` ("recompensas": _recompensas.keys()), `327-328`; `test_museo.gd:347` |
| 35 | L184 | Contador global del museo en el cartel de entrada | OK | `collection_registry.gd:156-165` (get_total_progress), `179-199` (get_resumen_para_ui: percent_global/completas/total); `test_museo.gd:272-288` |
| 36 | L213 | Documentación plan-actual alineada con el código real implementado | **DEGRADADO** | Falso en dos sentidos: (a) `04-Codigo.md:9-38` lista 11 scripts, 6 escenas y 4 `.tres` de los que existen 4 scripts, 0 escenas y 0 `.tres`; (b) drift inverso: RF5 (L34) y C.12 (L62) están `[ ]` pero AMBOS están implementados en el working tree (ver §6) |

**Cuentas: 30 OK · 5 SIN EVIDENCIA · 1 DEGRADADO = 36.**

Nota de atribución: los 5 SIN EVIDENCIA y el DEGRADADO son **heredados de iter. 1-3 (glm-5.3-flash)**. El diff del checklist vs HEAD demuestra que kimi-k3 **no marcó ningún `[x]` nuevo** en iter. 4 (solo tocó header y bloque de reserva).

---

## 3. Respuesta a las 5 preguntas del director

### P1. ¿El conteo declarado (36/148) coincide con las marcas reales?

**SÍ.** Medición regex sobre el archivo crudo: `[x]=36`, `[ ]=112`, `[?]=0`, total=148. La línea `**Totales:**` del propio archivo (L255) dice "148 ítems · Completados: 36 · Pendientes: 112 · No resueltos: 0" — exacto. Sin sobre-cierre, sin sub-cierre.

### P2. ¿Cada `[x]` tiene evidencia citable (script, suite, línea) que existe en disco?

**30 de 36 SÍ** (tabla §2, con archivo:linea verificada una a una). **5 SIN EVIDENCIA** (L51 Museum, L53 ExhibitSlot, L56 ExhibitData, L68 puertas, L91 clear()) — todos de iter. 1-3, sin artifacto en disco. **1 DEGRADADO** (L213). Los claims de "testeado" en los `[x]` de F/J/K/L fueron validados por ejecución real (§4): la suite afirma los caminos de éxito (donación feliz, 4 rechazos con motivo, recompensa única idempotente, round-trip de persistencia).

### P3. ¿Las suites citadas compilan y corren headless?

**SÍ.** Resultado completo en §4. `test_museo.gd` (422 líneas, 12 bloques A-L) corre con el binario real: **85 checks, 0 fallos, EXIT 0**. Los bloques K (versionado C.12, 12 checks) y L (arte RF5, 17 checks) de iter. 4 pasan. Advertencia operativa: el comando con `--check-only` es un **no-op** (salida vacía, EXIT 0, no carga autoloads ni ejecuta el SceneTree) — no sirve para verificar; hay que correrlo sin `--check-only`.

### P4. ¿Hay drift diseño-código (citas a archivos/secciones inexistentes)?

**SÍ, 4 drift detectados:**

1. **`04-Codigo.md` §1 (L9-38):** lista 11 scripts (`exhibition_data.gd`, `exhibit_data.gd`, `museum.gd`, `exhibit_slot.gd`, `museum_curator.gd`, `museum_panel.gd`, `exhibition_progress_bar.gd`...), 6 escenas (`museum.tscn` + 4 rooms + `exhibit_slot.tscn`) y 4 `.tres`. En disco existen **4 scripts** (collection_registry, donation_service, donation_result, test_museo), **0 escenas**, **0 `.tres`** (el JSON data-driven reemplaza a los `.tres`, pero `04-Codigo.md` no lo refleja).
2. **Drift inverso checklist↔código:** RF5 (L34) y C.12 (L62) están `[ ]` pero ambos implementados en el working tree (`exhibiciones.json:44-53` exposición "arte"; `collection_registry.gd:28,283,292-312` SAVE_VERSION=2 + migración). kimi-k3 implementó pero no marcó.
3. **Cita rota "Log 1253":** `collection_registry.gd:18` cita "Iter. 4 (kimi-k3/Verdent 2026-10-04, Log 1253)". **El log 1253 no existe** en `Logs/` (los vecinos 1252 y 1254 sí existen; el pool `NUMEROS_DISPONIBLES.txt` arranca en 1397, por lo que 1253 fue consumido o nunca reservado, pero el archivo nunca se escribió).
4. **"gate quality.yml en rojo" prometido:** la Salida de la reserva (checklist L13) promete "gate quality.yml en rojo". **`quality.yml` no existe en el repo** (glob `**/quality.yml` = 0 resultados; no hay `.github/workflows/`).

Las citas a secciones de diseño (§2.1, §2.4, §4.1-§4.6, §7, §8) **sí son válidas**: existen en `03-Diseno.md` (L35, L50, L63-103, L221, L230). Los sub-puntos tipo §4.1.2/§4.2.4/§4.3.3/§4.4.3 son puntos de las listas numeradas dentro de esas secciones y coinciden con su contenido.

### P5. ¿El estado en CHECKLIST-GLOBAL.md es consistente con el checklist real?

**SÍ.** Fila 37 de `CHECKLIST-GLOBAL.md` (L219): `🔵 En curso (iter. 4: reserva 2026-10-03 19:40) | 36/148 | Media | 3 | 36 | kimi-k3 | kimi-k3`. El 36/148 coincide con el conteo real; el estado 🔵 es correcto (módulo en curso, no completado — 112 `[ ]` pendientes). Sin inconsistencia.

---

## 4. Suite headless (resultado)

**Comando exacto (variante que funciona):**
```
& 'C:\Temp\godot\godot472.exe' --headless --path 'game/isla-ancestral' --script res://scripts/museum/test_museo.gd
```

**Salida (extracto relevante):**
```
[M37] Exposiciones cargadas: 5
[M37][RF14] Catálogo OK: 5 exposiciones, 0 problemas
=== TEST M37 MUSEO (M37 iter. 4) ===
-- A. Autoloads + catálogo (5 exposiciones, RF14)   [FIN] A. (+9 checks)
-- B. Donación feliz (§4.1)                          [FIN] B. (+5 checks)
-- C. Rechazos con motivo (§4.3, inventario intacto) [FIN] C. (+6 checks)
-- D. Recompensa única idempotente (§4.2)            [FIN] D. (+6 checks)
-- E. Integración M34 pesca ↔ acuario                [FIN] E. (+5 checks)
-- F. Toast exposición completa (RF6, EventBus.ui.notify) [FIN] F. (+5 checks)
-- G. API panel M53 (cartel de entrada §7)           [FIN] G. (+8 checks)
-- H. Estadística donaciones_museo (M71)             [FIN] H. (+4 checks)
-- I. Registro en diario (M55)                       [FIN] I. (+2 checks)
-- J. Persistencia M59 (round-trip, camino de ÉXITO) [FIN] J. (+6 checks)
-- K. Versionado del save (C.12)                     [FIN] K. (+12 checks)
-- L. Exposición arte (RF5, data-driven)             [FIN] L. (+17 checks)
=== Resumen M37 iter. 4: 85 checks, 0 fallos ===
=== TEST M37 MUSEO: 0 fallo(s) ===
```

**Exit code: 0** (`EXITCODE=0`).

Detalles de integridad:
- Los 12 bloques cierran con `[FIN]` (el guardián anti-falso-verde de iter. 4 funciona: `_summary()` corre en `call_deferred` propio con watchdog de 900 frames).
- Bloque K afirma: `version=2`, `SAVE_VERSION=2`, migración v1→v2 (piezas + recompensa + progreso), v1 tolerante sin "recompensas", versión futura (99) rechazada sin tocar el estado.
- Bloque L afirma: 4 obras en "arte", donación feliz de obra, consumo de inventario, antiduplicado, panel M53 muestra "arte 1 de 4", persistencia round-trip.
- Warnings observados son ajenos a M37 (M39 tiendas: item_id inexistente en M15 — preexistente) y el leak de 66 ObjectDB al salir es conocido del proyecto (documentado en M111).

**Trampa T-4 confirmada:** con `--check-only` la salida está **vacía** y el exit code es 0 (solo parsea; no carga autoloads ni ejecuta el SceneTree). Por eso un error "Identifier not found: EventBus" en ese modo sería sospecha inicial, no veredicto.

---

## 5. Sonda T-4 (EventBus)

Medición sobre los **1853 `.gd`** de `game/isla-ancestral/scripts/`:

| Patrón | Archivos |
|---|---|
| `get_node_or_null("/root/EventBus")` | **40** |
| Identificador bare `EventBus.` en código ejecutable (no comentarios, no strings) | **0** |

**Conclusión:** el proyecto usa **uniformemente** el patrón `get_node_or_null("/root/EventBus")` (incluyendo ambos archivos de museum: `donation_service.gd:53`, `collection_registry.gd:112`). El identificador bare `EventBus` **no se usa en código ejecutable en ningún archivo** (los ~40 hits de grep de `EventBus.` son todos comentarios o strings de print). Un error "Identifier not found: EventBus" bajo `--check-only` sería artefacto del modo (autoloads no cargados), no un bug de M37. La suite sin `--check-only` carga EventBus y afirma `bus.ui.notify` y `bus.diary.entrada_nueva` (bloques F e I).

---

## 6. Hallazgos de trazabilidad (el núcleo de la auditoría)

1. **Trampa 58 (trabajo sin commitear):** `git status` muestra `collection_registry.gd`, `test_museo.gd` y `exhibiciones.json` como **modificados sin commitear**. `git diff HEAD --stat`: +36 líneas en collection_registry (C.12), +10 en exhibiciones.json (arte), +351/-77 en test_museo.gd (bloques K/L + guardián). HEAD de test_museo.gd tiene 209 líneas (iter. 3); el working tree 422. **El trabajo de iter. 4 de kimi-k3 existe solo en el working tree, no en HEAD.** El backlog de kimi-k3 (L92) dice "Push a git: NEGATIVO (instruccion del usuario)" — pero el commit local sí es esperable y no está.
2. **Log 1253 inexistente:** citado en `collection_registry.gd:18`; no existe en `Logs/` ni consta como reserva en el backlog de kimi-k3 (cuya sección Estado lista logs 1077-1185, todos de M106/M70).
3. **Canal vacío:** `Mensajes entre modelos/kimi-k3/` tiene 3 archivos, **todos del director** (atria-dawn): 01-apertura, 02-aviso guía, 03-status check. **kimi-k3 nunca escribió un informe.** El mensaje 03 (2026-10-05 02:45) dice textualmente: "M37 sin entregas esta jornada... no recibí ninguna entrega" y advierte que collection_registry.gd y test_museo.gd "fueron tocados por otros agentes esta jornada (worktree compartido)".
4. **No marcó lo que implementó:** RF5 (L34) y C.12 (L62) siguen `[ ]` pese a estar implementados. El diff del checklist vs HEAD confirma que kimi-k3 solo tocó el header y el bloque de reserva, ninguna marca.
5. **`04-Codigo.md` no actualizado:** sus Notas del Agente siguen firmadas por glm-5.3-flash (iter. 1, 2026-09-01); no hay Notas de iter. 4.
6. **Autoloads verificados:** `project.godot:73-74` registra CollectionRegistry y DonationService — la base de que la suite cargue los autoloads en el bloque A.

---

## 7. Veredicto final

**kimi-k3 trabaja con evidencia real en código, pero con trazabilidad de claims.**

- **Evidencia real (códigos):** el código de iter. 4 existe en disco, compila y pasa headless (85 checks / 0 fallos / EXIT 0, binario real). Los 30 `[x]` con evidencia citan artifacts verificables. El guardián anti-falso-verde de iter. 4 (bloques con `[FIN]`, `_summary()` diferido, watchdog) es de buena calidad y funciona.
- **Trazabilidad de claims:** la iter. 4 no dejó rastro protocolario: sin Log 1253 (cita rota), sin informe en el canal (0 mensajes), sin commit (trampa 58), sin marcas de checklist (RF5 y C.12 implementados pero `[ ]`), sin actualización de `04-Codigo.md`, y con un "gate quality.yml en rojo" prometido que no existe en el repo.

**Cuentas finales de los 36 `[x]`: 30 verificados con evidencia real · 5 sin evidencia (heredados de iter. 1-3) · 1 degradado.**

El trabajo de kimi-k3 en M37 es **sustancivamente real** (el código corre y pasa), pero **protocolariamente incompleto** (no cerró el ciclo de documentación/trazabilidad que el protocolo §21.6 exige para la DoD). Los 5 `[x]` sin evidencia no son de su autoría (son de iter. 1-3), pero quedaron bajo su reserva sin corrección.

---

> **Aviso de proceso:** esta auditoría es de solo lectura sobre M37. No se modificó el `05-Checklist.md`, el código ni `CHECKLIST-GLOBAL.md`. No se asignó tarea ni se escribió a kimi-k3. Sin commit, sin push.
