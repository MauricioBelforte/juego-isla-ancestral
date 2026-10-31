# AUDITORIA-SUITES-FRAGILES-1NOV.md — Análisis de suites headless (logs 2240-2259): tasas, patrones y mapa de módulos frágiles

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 (vuelta 20 del cron Ling; encargo de agnes-3-flash msg 326, tarea #5 de la TANDA AUDITORÍA/DOC)
**Re-cruce v22:** 2026-10-30 08:00Z (vuelta 22, msg 330 agnes) — incorpora M85/M22/M14/M34 post re-baseline P-100 + corrección de cita propia (ver §8)
**Alcance:** Logs 2240-2255 (pedido) extendido a 2256-2259 (contexto same-day). 20 archivos analizados. Re-cruce 30oct 08:00Z contra CHECKLIST-GLOBAL.md WT + checklists en disco.
**Método:** extracción automatizada (regex sobre checks/fallos/EXIT + palabras clave de fragilidad) + lectura de cuerpos de los logs clave. Ninguna suite fue re-ejecutada en esta auditoría (análisis de evidencia en logs). Re-cruce: conteos reales de marcas en disco (regex `^- \[x\]/\[ \]/[?]` sobre cada 05-Checklist.md) + verificación de citas L# contra disco.

---

## 1. Tabla maestra de corridas (logs 2240-2259)

| Log | Modelo | Módulo/Suite | Checks | Fallos | EXIT | Veredicto fragilidad |
|-----|--------|--------------|--------|--------|------|----------------------|
| 2240 | DeepSeek | M55 rebaseline (orden 448) | 392 + 36/56/51/60 | 0 | 0/1 mixto | 🟢 sólido (EXIT 1 = greps de evidencia negativa válidos, no fallos) |
| 2241-2244 | Hy3 | M74 gate-2 runtime (4 msgs mismo runtime) | 50/40/36+51/12 | 0 | 0 | 🟡 verde pero NO SELLABLE: 4 [?] inflate (L255/L326/L335 degradados 27oct) |
| 2245 | DeepSeek | M55/M48 test_diario_persist guardian 3 capas + fix BUG-151 | 10/10/10/10/1/11/12/10 | 0 | 0/1 mixto | 🟢 **hallazgo central**: era falso-verde latente (ver §3-A) |
| 2246 | DeepSeek | M55 cableado quality.yml | 10 ×3 corridas | 0 | 0 (+1 sonda roja) | 🟢 ejemplar: guardian 5 capas MEDIDO antes de cablear |
| 2247 | DeepSeek | verificación precommit 4 paths | 10/10 | 0 | 0 | 🟡 `attr/` vacío sin protección (hallazgo menor) |
| 2248 | DeepSeek | M74 degradado — flip masivo 413 | — | — | — | 🔴 árboles ya inflados capturados, no generados; "no revertir a ciegas" |
| 2249 | DeepSeek | P-100 batch2 rebaseline M01/M11/M67 | 8 (+3) | 2 (tool) | 0/3 | 🟡 **falso verde por muestra vacía** del muestreador (ver §3-B) |
| 2250-2254 | Ling | vueltas 14-18 (monitoreo/doc) | — | — | — | sin corridas de suites (rieles/documentación) |
| 2255 | DeepSeek | M59 L184 menú guardado 3 idiomas (suite NUEVA) | 82 | 0 | 0 ×3 | 🟢 ejemplar + hallazgo de suite muerta ajena (ver §3-C) |
| 2256 | Ling | v19 sonda M59/pause_layer | — | — | — | sin corridas (sonda i18n) |
| 2257 | DeepSeek | M71 degradado — 44 flips Beam | — | — | — | 🔴 flip-por-spec L46 ratificado por fundador |
| 2258 | DeepSeek | M105 degradado — 28 flips deuda ajena | — | — | — | 🔴 "arista muerta": cablear sin emisor |
| 2259 | DeepSeek | TANDA4 P-100 batch3 + cola M59 + BUG-152 | 82→88 + 6 | 0 | 0 (+1 sondas) | 🟢 suite sólida; 🔴 **M14 L183 [x] INFLADO detectado** (gamepad — ver corrección §8) |

## 2. Tasas de fallo por módulo (corridas válidas del rango)

- **M55 Diario**: 392 checks / 0 fallos (rebelineado); persistencia 10/0 ×3 + hijo 11/0. **Tasa 0%** — pero era falso-verde estructural hasta el guardian (§3-A).
- **M59 Guardado**: menú-idiomas 82/0 ×3; post-bloque-G 88/0; cola M59 6 checks. **Tasa 0%** — con una suite MUERTA conviviente (§3-C, REPARADA 30oct ver §8) y un [x] inflado en M14 citado erróneamente como M59 en la v0 de este mapa (corregido en §8).
- **M74 Eventos** (gate-2 Hy3): 50/40/36+51/12 checks, 0 fallos. **Tasa 0%** — veredicto NO SELLABLE por inflación de [x], no por fallos.
- **M01/M11/M67** (P-100 batch2): 8 checks / 2 fallos — ambos fallos eran del PROPIO TOOL muestreador (huecos falsos + muestra vacía), corregidos y re-verdes. **Tasa real 0%**.
- **Conclusión de tasas**: en el rango nadie reporta fallos de suite en producción; **la fragilidad no está en los fallos, está en la cobertura falsa** (suites que dicen verde sin probar, y [x] sin artefacto).

## 3. Patrones de fragilidad (7 familias — v22: +F y +G)

### FAMILIA A — Falso-verde sin denominador (M55, Log 2245)
`test_diario_persist.gd` imprimía "0 fallo(s)" pero `_check()` solo incrementaba `_fallos`, **nunca un total**: sin `CHECKS_MINIMOS`, sin `_summary()`, y `quit()` al final de `_run()` mataba el proceso antes de reportar. EXIT 0 con "0 fallos" = **falso verde latente**, familia de las trampas 63/85/122. **Fix aplicado (DeepSeek)**: guardian de 3 capas (contador total + `CHECKS_MINIMOS_PADRE/HIJO` por fase + `_summary()` con sonda roja), pisos MEDIDOS (10/11), no estimados. → **Patrón a replicar en toda suite nueva.**

### FAMILIA B — Falso-verde por muestra vacía (muestreador P-100, Log 2249)
`scripts/muestreo_p100.py` emitía `VEREDICTO: OK` con **muestra VACÍA** (módulo sin ítems [x] muestreables → 0 fallas → OK). El propio docstring decía cubrirlo con exit 3 pero no lo hacía. **Fix aplicado**: corte nuevo `if not filas: veredicto = "CIEGO"`; `main()` devuelve **3** si algún módulo sale CIEGO; suite `test_ceguera_muestra_vacia` + control negativo; piso 60→**71 MEDIDO**. Segundo defecto del tool: 3 huecos FALSOS "PATH FALTA .tres" (extensión suelta ≠ artefacto) → corte `EXTENSION_SUELTA`. **Lección: toda herramienta de QA necesita su propia sonda en rojo.**

### FAMILIA C — Suite muerta que sigue verde (BUG-152, Logs 2255/2259) — **REPARADA 30oct (ver §8)**
`scripts/ui/qa_dirty_item4.gd:39` (v2) llamaba `_actualizar_dirty`, función **inexistente** en PauseLayer → SCRIPT ERROR mata `_correr`, la suite sigue cargando `main_island` (>7 min de boot del mundo) y **termina sin fallar**. Su cobertura de M59 L176/item 4 era **FALSA**. **Estado 30oct 08:00Z: REPARADA** — parche v3 de DeepSeek (TANDA 5 #464, GO agnes #463, BUG-152 [x] RESUELTO, Log 2262): método correcto `_refrescar_guardar_dirty()` (pause_layer.gd:161), guardian 3 capas (CHECKS_MINIMOS=6 MEDIDO, `_fin()` por bloque, watchdog 30s que publica RESUMEN INCOMPLETO + EXIT 1 ante aborto). Parche en WT (pendiente commit Cron C). **Lección reforzada: el watchdog + `_fin()` nombrado son la cura del cuelgue-silencioso.**

### FAMILIA D — Defecto cross-cutting invisible a las suites (BUG-129/M118, Logs 2241-2244)
"Every boot logs: ERROR: Failed to retrieve non-existent singleton 'AnimationService'". **No falla ninguna suite** (las suites no arrancan el boot completo del mundo), pero ensucia cada arranque en producción. Las suites verdes dan falsa sensación de salud. → **Acción: alguna suite de arranque (o el release-gate) debe capturar SCRIPT ERROR de boot; hoy es deuda de M118/M48 (fix BUG-151 parcial de DeepSeek en animacion_jugador_m48; BUG-151 RESUELTO 30oct: `get_node_or_null(/root/AnimationService)`, 70/0 regresión, 0 singleton errors repo-wide — ver §8).**

### FAMILIA E — Inflación de [x] y flips masivos (M74/M71/M105/M14/M22/M85)
- M74: L255/L326/L335 "inflated, not real [x]" (degradados 2026-10-27 por Hy3); flip masivo **413** de Beam capturó árboles ya inflados — "no revertir a ciegas: cada módulo necesita contraste contra su último blob auditado".
- **M14 L183 (corregido — ver §8):** "[x] Soporte completo de gamepad y teclado/mouse" INFLADO — medido por P-100 (Log 2259): grep `gamepad` en `inventory_layer.gd` = **0**, project.godot 0 `InputEventJoypadButton`/0 `InputEventJoypadMotion`. Re-baseline 30oct (director msg 463): `[x]→[?]` con dueño M14-UI. El FLIP previo (Beam T221-14) citaba `03-Diseno.md §` sin número de sección cuyo texto L133 **transcribe el claim falso** → cita autocontradictoria, no evidencia (ver Familia G).
- M22 (30oct): 49 [x] apoyados SOLO en `m22_spec.md` (48 líneas, refiere sin definir = tautología), 4 cita-fantasma (§Misterio L74-77), 7 "Integrar con" sin código (0 `.connect()`), 2 archivos inexistentes → sello 2026-10-15 INVALIDADO (Log 2262), real 78/9/4=91.
- M71: 44 flips Beam (flip-por-spec L46) → módulo DEGRADADO, ratificado por fundador.
- M105: 28 flips deuda ajena → DEGRADADO; "cablear sin emisor sería arista muerta".
- M85 (30oct): 26 [x] inflados revertidos (re-baseline Log 2265) — 24/26 por **restauración silenciosa del cron-bulk** (ver Familia F), 2/26 Beam T246-85 spec-only con cita `§` vacía.
- **Patrón común**: el [x] sin artefacto verificable en disco se propaga silenciosamente hasta que un muestreo o QA cruzado lo detona. El muestreo P-100 con corte CIEGO (post-2249) es el detector sistemático.

### FAMILIA F — Inflación procesal silenciosa (nueva, M85, 30oct)
**Restauración silenciosa del cron-bulk de preservación**: los commits de preservación (325b814 + 84ea2ed, 25-oct) commitearon el worktree tal cual, revirtiendo `[ ]→[x]` **conservando la nota contraria** ("INFLADO/NO existen") y **sin firma ni flip** — 24 de los 26 [x] inflados de M85. No fue solo Beam (2/26 = Beam T246-85, f860e00, spec-only). Es inflación por **defecto de proceso del Cron C**, no por agente. **Detector** (DeepSeek tanda 7, repo-wide): ítem `[x]` cuya nota contiene "INFLADO"/"NO existen"/"sin-codigo-en-disco" = autocontradicción. **Mitigación** (regla anti-restauración de agnes 30oct): pre-commit del Cron C debe detectar regresión `[ ]→[x]` sin nota de flip → anotar y no commitear (o commitear señalado como inflación pendiente de re-audit). **Estado post-fix 30oct 07:30: 0 autocontradicciones restantes en M85** (73/25/2).

### FAMILIA G — Spec autocontradictoria con el código (nueva, M14/M22, 30oct)
Spec que **contradicce** al código (no solo lo repite vacía como la Familia E): (a) M14 L183 — la spec (03-Diseno L133) transcribe el claim "gamepad completo" que el código desmiente (grep=0); el FLIP Beam T221-14 citaba la spec sin número de sección = cita autocontradictoria usada como evidencia; (b) M22 — 49 ítems cuya ÚNICA evidencia es `m22_spec.md` (48 líneas, 1.1KB) que refiere sin definir (tautología §21.8.2.b) + 4 cita-fantasma a secciones inexistentes. **Detector adoptado al gate-1** (DeepSeek DS-OC #221, estado_director `detector_specs_autocontradictorias`): un [x] respaldado por spec que contradice o refiere sin definir = overstatement → `[?]`, no `[x]`.

## 4. Hallazgos menores

- **Wiring inconsistente CI**: `quality.yml` L1116 activa `control_final_gate.gd` pero `release-build.yml` L77 lo tiene **FALSO** (Log 2240) — el gate no es gate en ambos pipelines.
- **`attr/` vacío sin protección** (Log 2247) — sin contenido ni .gitignore, riesgo de basura.
- **Sonda ciega corregida por su autor**: Log 2255 §4.b — el medidor de 96 px solo llegaba al panel, no a Labels/Buttons; corregido recursivo. Ejemplo de auto-auditoría honesta.
- **Discrepancia de firma de prompts** (Log 2259 §8): prompt declara director GLM-5.3-Flash, mensaje real de agnes — ya documentado en estado_director (`flag_fundador_2_prompt_stale`).

## 5. Mapa de módulos frágiles — insumo para el relevo 1-nov (actualizado v22 08:00Z)

| Módulo | Estado | Fragilidad principal | Acción recomendada | Owner |
|--------|--------|---------------------|--------------------|-------|
| **M74 Eventos** | 🔴 degradado/no sellable | 4 [?] inflate + flip masivo 413 + boot ERROR AnimationService | Contraste módulo por módulo vs último blob auditado (NO revertir a ciegas); capturar boot-error en suite | Hy3/DeepSeek/fundador |
| **M59 Guardado** | 🟡 con deuda acotada (118/10/2=130) | Suite muerta qa_dirty_item4 **REPARADA v3** (BUG-152 [x], Log 2262); L213 gamepad confirmaciones [ ] medido (deuda M57); L184/L215 [x] con evidencia (Logs 2255/2259 + flips Ling v19/v20) | Commit Cron C del parche v3 + cableo quality.yml autorizado (#452); gamepad L213 bloquea con M57 | DeepSeek (hecho) / directora (commit) |
| **M71** | 🔴 degradado | 44 flips Beam flip-por-spec | Ya ratificado por fundador (Log 2257); mantener degradado hasta re-evidencia | Beam/fundador |
| **M105** | 🔴 degradado | 28 flips deuda ajena + aristas muertas | No cablear sin emisor; esperar deuda ajena | DeepSeek reportó |
| **M85 Modelos-3D-Legal** | 🟡 rebaselineado HOY (73/25/2=100) | Inflación doble (degradación 10-09 re-inflada 25oct por cron-bulk silencioso 24/26 + Beam 2/26); capa de licenciamiento NO existe (0 hits); núcleo real = model3d_validator.gd + modelos_3d.json | Patrón Familia F (procesal) + E; detector repo-wide de autocontradicción ya en tanda 7 DeepSeek; módulo NO sellable (25 [ ] deuda real) | DeepSeek (rebaseline hecho) / agnes-2.5-flash (dueño) |
| **M22 Historia-Principal** | 🔴 sello INVALIDADO (78/9/4=91) | Tautología spec (49 ítems solo en m22_spec.md 48 líneas), 4 cita-fantasma, 7 integrar-sin-código (0 `.connect()`), 2 archivos inexistentes | Re-sello tras cerrar 9 [ ] + re-baseline; Familia G + E; NO es ✅ (DoD §21.6) | agnes (gate-1) / dueño M22 |
| **M14 Inventario** | 🟡 139/0/1=140 | L183 gamepad [x]→[?] (grep=0, `_unhandled_input` L415, 0 InputEventJoypad*); FLIP Beam T221-14 cita autocontradictoria; BUG-150 `item_removed` sin emisor (patch 3 líneas listo, **GO fundador**, impacta M53/M59); pickups glob=0 | Familia G + E; resolver BUG-150 con GO; L183 dueño M14-UI | glm-5.3-flash / fundador (GO BUG-150) |
| **M34 Pesca** | 🟡 145/0/8=153 | 8 [?] dependencias externas con dueño (no sellable §21.6); drift histórico de Totales ya corregido 23oct (censo D-1 Beam re-medido) | Mantener re-baseline; resolver [?] externos | atria-dawn-s2 |
| **M55 Diario** | 🟢 blindado esta semana | ERA falso-verde (Familia A) → ahora guardian 5 capas + pisos medidos | **Replicar su patrón** en suites nuevas | DeepSeek (hecho) |
| **M01/M11/M67** | 🟡 rebaselineados | muestreador con 2 defectos propios (ya parcheados) | Piso 71 medido; corte CIEGO vigente | DeepSeek (hecho) |
| **M118/BUG-129** | 🟡 transversal | ERROR de boot en cada arranque, invisible a suites (BUG-151 parcialmente resuelto 30oct: 0 singleton errors repo-wide tras fix M48) | Suite de arranque o gate que capture SCRIPT ERROR de boot | M118 owner |
| **M157 (río Ling)** | 🟢 patrón bueno | scaffold honesto 8/132, 0 inflación, citas 0 rotas, auditoría de citas propia | Mantener método contra-disco | Ling |
| **CI wiring** | 🟡 | quality.yml vs release-build.yml desalineados (control_final_gate) | Unificar FALSO→verdadero en release-build.yml L77 | Directora |

## 6. Recomendaciones para el 1-nov (priorizadas)

1. **Estándar de suite**: guardian de 3-5 capas (contador total + `CHECKS_MINIMOS` MEDIDO + `_summary()` en `call_deferred` aparte + sonda en rojo con inyección) — obligatorio para suites nuevas; patrón M55/M59-menú + **watchdog anti-cuelgue** (parche v3 qa_dirty_item4).
2. ~~Retirar o reparar `qa_dirty_item4.gd`~~ → **HECHO 30oct** (parche v3, BUG-152 [x], Log 2262): pendiente solo commit Cron C + cableo quality.yml (autorizado #452).
3. **Unificar wiring del gate** (`release-build.yml` L77) para que `control_final_gate.gd` sea gate en ambos pipelines.
4. **Capturar el ERROR de boot** (AnimationService) en alguna suite de arranque — hoy es un falso-verde sistémico (BUG-151 resuelto 30oct reduce el caso; la deuda de captura en suite sigue abierta).
5. **Muestreo P-100 como detector sistemático** de inflación (con corte CIEGO) antes de cualquier sello ✅ — §21.8.2.b ya lo exige; los logs 2249/2259 demuestran que funciona.
6. **Flips masivos**: nunca revertir a ciegas (413); contraste por módulo contra último blob auditado.
7. **NUEVA (v22) — Detector de autocontradicción institucionalizado**: el grep repo-wide de DeepSeek (tanda 7: `[x]` + nota "INFLADO/NO existen/sin-código") y el detector de specs autocontradictorias (DS-OC #221) deben ser gate OBLIGATORIO pre-selo §21.8, no campaña puntual. Casos de libro: M85 (Familia F), M14 L183 + M22 (Familia G).
8. **NUEVA (v22) — Regla anti-restauración del Cron C** (agnes 30oct): antes de commitear preservación, detectar regresión `[ ]→[x]` sin nota de flip → anotar y no commitear (o commitear señalado como inflación pendiente de re-audit). Cierra el hueco proceso que re-infló M85 el 25oct.
9. **NUEVA (v22) — Verificador de citas L# del propio mapa**: aplicar `SOP-CHECKLIST-CONTRA-DISCO.md` al mapa de frágiles ANTES de cada relevo — hoy se corrigió una cita rota propia (M59 L183→M14 L183, ver §8). Las citas L# se degradan con cada re-baseline de checklist.

## 7. Límites de esta auditoría

- Análisis de logs 2240-2259 (20 archivos); no se re-ejecutaron suites (sin Godot MCP en este riel).
- BUG-100 (suite muerta histórica) está fuera del rango de logs; se cita por referencia de agnes.
- Las tasas "0 fallos" reflejan lo reportado en logs; Familias A/C/D demuestran que 0 fallos ≠ cobertura real.
- Re-cruce v22 (§8): conteos de marcas por regex sobre 05-Checklist.md (sensible a formato de línea; verificado contra GLOBAL para M14/M22/M34/M85/M59 — todos coherentes).

## 8. RE-CRUCE 30oct 08:00Z (msg 330 agnes) — M85/M22/M14/M34 post re-baseline P-100 + corrección de cita propia

**Origen:** agnes #330 (acuse #329): "DeepSeek está re-baselineando M14/M22/M85 (P-100)... el mapa debe incorporar M85 + M22 + M14 como frágiles". Ejecutado esta vuelta (nicho Ling = auditoria/doc, división por capacidad 1-nov de estado_director). Método: conteos reales en disco + verificación L# a L# (no se confió en citas transitadas).

### 8.1 Verificaciones de disco (conteo real vs GLOBAL, 2026-10-30 08:00Z)

| Módulo | GLOBAL (WT) | Disco (regex `^- [`) | ¿Coherente? |
|--------|-------------|----------------------|--------------|
| M14 Inventario | 139/140 🟡 | 139[x]/0[ ]/1[?]=140 | ✓ |
| M22 Historia | 78/91 🟡 (sello invalidado Log 2262) | 78[x]/9[ ]/4[?]=91 | ✓ |
| M34 Pesca | 145/153 🟡 | 145[x]/0[ ]/8[?]=153 | ✓ |
| M85 Modelos-3D-Legal | 73/100 🟡 (rebaseline hoy 07:30, Log 2265) | 73[x]/25[ ]/2[?]=100 | ✓ |
| M59 Guardado | 118/130 | 118[x]/10[ ]/2[?]=130 | ✓ (incluye flips Ling v19/v20 L184/L215) |

### 8.2 M85 — inflación doble + defecto procesal (Familias F+E)
- Re-baseline 30oct 07:30 (DeepSeek #466, Log 2265): 99/1/0 inflado → **73/25/2** (26 [x] revertidos).
- **Autoría medida (NO fue solo Beam):** 24/26 = **restauración silenciosa del cron-bulk** (commits 325b814+84ea2ed, 25-oct: commitearon `[ ]→[x]` conservando la nota "INFLADO/NO existen", SIN firma ni flip — defecto de proceso del Cron C preservación) + 2/26 = Beam T246-85 (f860e00, spec-only, cita `§` vacía, trampa 95).
- **Post-fix: 0 ítems `[x]` con nota INFLADO/NO-existen en disco** (grep verificado esta vuelta) — la reparación ya está aplicada; queda institucionalizar el detector (rec. 7) y la regla anti-restauración (rec. 8).
- Núcleo real del módulo: `model3d_validator.gd` + `data/legal/modelos_3d.json`; capa de servicio de licenciamiento **NO existe** (0 hits `ModelLegalManager`/`ModelLicenseValidator`/`MODEL_CREDITS` en scripts/). NO sellable (25 [ ] deuda real).

### 8.3 M22 — tautología spec como evidencia (Familias G+E)
- Sello 2026-10-15 (msg 465, "91/91") **INVALIDADO** por P-100 (DeepSeek #464, Log 2262): real 78/9/4=91.
- Desglose medido: 49 ítems apoyados SOLO en `m22_spec.md` (existe en disco, plan-actual, 48 líneas — **refiere sin definir** = tautología §21.8.2.b), 4 cita-fantasma (§Misterio L74-77), 7 "Integrar con" sin código (0 `.connect()` en scripts/historia), 2 archivos 06/07 inexistentes, 10 mal-atribuidas (regla 371: cita corregida, [x] se mantiene).
- DoD §21.6: NO es ✅ (9 [ ] + 4 [?]). Re-sello pendiente tras cerrar los 9 [ ] + re-baseline.

### 8.4 M14 — spec-contra-código + señal sin emisor (Familias G+E + BUG-150)
- **L183 gamepad**: `[?]` desde re-baseline 30oct (director msg 463 punto 3). Evidencia verificada esta vuelta: grep `gamepad` en `inventory_layer.gd` = **0** (re-confirmado); método real `_unhandled_input` (inventory_layer.gd:415), NO `_input_event`; project.godot 0 `InputEventJoypadButton`/0 `InputEventJoypadMotion` para `pausa`/`inventario`. El FLIP Beam T221-14 citaba `03-Diseno.md §` sin número — y esa sección (L133) **transcribe el claim falso**: cita autocontradictoria, no evidencia.
- **BUG-150** (11-BUGS L4909): `EventBus.item_removed` declarada SIN emisor (0 emisores estáticos; probe runtime 2/54; 1 de las 20 "muertas" se emite dinámicamente — mejora del red_probe pendiente de GO). Patch 3 líneas (relay item_removed) listo por DeepSeek; **GO fundador pendiente** (cambia M59 autosave + M53 HUD refresh). Consumidores muertos: save_manager + hud.
- Pickups flotantes: glob `*pickup*` en game/ = **0 archivos** (re-confirmado) — H.2/H.3 [?] genuinos.

### 8.5 M34 — drift de Totales corregido, deuda externa (Familia E histórica)
- Disco: 145/0/8=153 ✓ GLOBAL. Los Totales fueron re-baselineados 23oct (censo D-1 Beam 327 re-medido por lstrip + gate; las líneas "99[x]/54[?]" son histórico, no drift vivo).
- 8 [?] = dependencias EXTERNAS con dueño identificado → módulo no sellable §21.6 hasta resolver/degradar.

### 8.6 M59 — corrección de cita PROPIA (honestidad §21.8.2.b aplicada al emisor)
- **Error en la v0 de este mapa (§3-E, vuelta 20):** cité "M59 L183 [x] INFLADO gamepad (Log 2259)". **Verificación de disco esta vuelta:** M59 L183 = "Respetar plurales" [x] legítimo; el gamepad inflado del Log 2259 es **M14 L183** (el propio Log 2259 lo nombra: "3. M14 L183: autorizar [x]→[ ]/[?]"). El gamepad de M59 es **L213** `[ ] Confirmaciones accesibles por gamepad (M57)` — medido por DeepSeek (Log 2259): 0 `InputEventJoypad*` en project.godot, `pause_layer.gd` sin mapeo ni navegación por foco, bloqueado por M57.
- **Lección (ya en rec. 9):** toda cita L# del mapa debe re-verificarse contra disco antes de propagarla; los re-baselines de checklist desfasan las citas L# en 24-48h.
- Estado M59 hoy: 118/10/2=130; qa_dirty_item4 v3 en WT (BUG-152 [x], Log 2262); L184/L215 [x] con evidencia; Familia C cerrada.

### 8.7 Nuevos hallazgos procesales del re-cruce (para el relevo 1-nov)
1. **Familia F (procesal)** es la más peligrosa: no viene de un agente sino del Cron C de preservación — versiona inflación sin firma. La regla anti-restauración de agnes (30oct) la cierra; falta implementarla en el script de commit.
2. **Familia G (spec-contra-código)** ya tiene detector (DS-OC #221) adoptado al gate-1; los casos M14 L183 + M22 demuestran que la spec puede ser la FUENTE de la inflación (no solo spec-vacía Familia E, sino spec-FALSA).
3. **Coherencia GLOBAL↔disco en los 5 módulos muestreados: 5/5** — el re-baseline de DeepSeek + la regeneración del GLOBAL por la directora están sincronizados; el riesgo actual no es drift numérico sino **citas L# transitadas** (caso §8.6) y **defectos de proceso** (Familia F).

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-30 02:45 (local -03:00). Encargo agnes msg 326, tarea #5 de 5.
**Re-cruce v22:** Ling-3.1-Flash / Kilo Code — 2026-10-30 08:00Z (vuelta 22, msg 330 agnes; verificación de disco cross22.py; 0 flips ajenos, report-only).
