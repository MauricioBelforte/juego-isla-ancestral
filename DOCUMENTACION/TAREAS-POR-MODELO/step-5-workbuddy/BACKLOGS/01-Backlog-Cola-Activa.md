# Step-5-WorkBuddy — Cola activa 100+ tareas (M156/M31/M17 + bloques)
**Fuente:** BACKLOG-MASTER.md Step-5-WorkBuddy (sección dividida 5nov por fundador)
**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Rol:** EJECUTOR PRINCIPAL del director
**Estado:** [→] Activo

# (A) COLA ACTIVA — 100+ TAREAS (tandas curadas por el director)

# BACKLOG 100+ TAREAS PARA STEP-5-WORKBUDDY — Investigación previa por GLM-5.3-Flash

**Modelo:** GLM-5.3-Flash (encargo del fundador 2026-10-16)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:00
**Nicho del modelo** (AGENTS §30.1 — **EJECUTOR PRINCIPAL del director**, único frente Step 5 desde 2026-10-15): velocidad + precisión + honestidad (informes Patrón D con conteos, muestreos y confesión de errores propios). Recibe tareas variadas apiladas; primero le atiende el director, después la cola.
**Autoridad:** CANDIDATOS para el director/fundador — nada se arranca sin encargo o reclamo §21.3. Conteos estimados a validar contra `05-Checklist.md` al reclamar.

## Reglas del reparto

- Confirmar en CHECKLIST-GLOBAL + ESTADO-PARALELO que el módulo no esté 🔵/🔴 de otro agente.
- Reporte Patrón D obligatorio al cerrar (conteo antes/después, cita de evidencia, fallos propios confesados).
- Un módulo por agente a la vez; 3 lugares al cerrar + reporte al director (REGLA CERO).

## LAS 100+ TAREAS

### Registro de delegaciones (mantenido por GLM-5.3-Flash — ultima pasada 2026-10-16 02:25)

- **M31-Ciclo Dia/Noche → DELEGADO por el director (canal Step-5-WorkBuddy msg 49, 2026-10-15 23:00: sello M94 denegado/commit ok, siguiente M31).** Tareas 5-7 marcadas en vuelo de Step 5 — no re-clamar.

### Bloque A — Sus módulos grandes abiertos (vuelo bajo, alto volumen)

1. M156-Terrenos-Y-Movimiento (202/307): diagnóstico de los 105 restantes + plan por lotes — 10 [C]
2. M156 b1: lote de terrain-movement (tokens por bioma) — 10 [C]
3. M156 b2: continua (islas nuevas según 168-plantilla) — 10 [C]
4. M156 b3: continua (movimiento: dash/esquiva) — 10 [C]
5. M31-Ciclo-Día/Noche (120/169): 49 pendientes → lote 1 (skybox/luces programadas) — 10 [C]
6. M31 b2: sistema de eventos ligado al ciclo — 10 [C]
7. M31 b3: cierre con test de transiciones — 8 [C]
8. M17-Construccion (81/175): 94 pendientes → lote 1 (fundaciones/edificables) — 10 [C]
9. M17 b2: continuar (modos colocación) — 10 [C]
10. M17 b3: continuar (materiales M14/M16) — 10 [C]
11. M18-Casas (114/149): 35 pendientes → lote (interiores/mobiliario) — 10 [C]
12. M18 b2: cierre con validación de spawn/puertas — 8 [C]
13. M27-Islas-Del-Mundo (127/192): 65 pendientes → lote 1 (círculo de islas) — 10 [C]
14. M27 b2: continuar (biomas por isla) — 10 [C]
15. M27 b3: cierre (viajes entre islas M28) — 8 [C]
16. M28-Viajes (50/130): 80 pendientes → lote (barcas/rutas) — 10 [C]
17. M68-Transporte (99/131): 32 pendientes — 8 [C]
18. M67-Vehiculos (19/131): arranque honesto (física base + 1 vehículo) — 10 [C]
19. M157-Medios-De-Transporte (0/106): arranque desde cero con plan — 10 [C]
20. M163-Encantamientos (98/120): 22 pendientes — 10 [C]
21. M164-Combate-Endgame (125/129): 4 pendientes — 4 [S]
22. M34-Pesca (99/153): 54 pendientes → lote 1 (cañas/carnadas) — 10 [C]
23. M35-Minería (101/142): 41 pendientes → lote (picos/niveles) — 10 [C]
24. M33-Agricultura (106/153): 47 pendientes → lote (semillas/estaciones) — 10 [C] — **[x] HECHO 2026-10-25 (Step-5-WorkBuddy, Log 2180, canal 219/220):** riel liberado por la directora (msg 218). Disco media 117/38 (NO 106/47: el item estaba stale). 5 suites de scripts/farm/ re-corridas HOY con binario real: 153 checks / 0 fallos / 0 SCRIPT ERROR / EXIT 0. Guardian del lote EN ROJO por inyeccion (CON piso EXIT 1 27<30; SIN piso EXIT 0 = falso verde). 03-Diseno.md reparado (BOM + mojibake cp1252: 19.589 -> 17.214 B). Creados 06/07. 10 flips con cita -> **M33 = 127 [x] / 28 [ ] / 0 [?] = 155**. Ofrecidos a revertir. **EXTENDIDO 2026-10-25 02:50 (Step-5-WorkBuddy, Log 2182, canales 222/223, corrida 2):** 6 flips mas con cita (P11/P13/P15/P23/P24 + L188) tras implementar catalogo schema 2 (9 cultivos: trigo invernal, higo, maiz ancestral, 2 flores, lirio hibrido, trigo estelar raro, palma y flor de coral), TABLA_CRUCES + cruce_flores() + puede_desbloquear() en farm_service.gd y la suite nueva test_farm_features_m33.gd (39/0, piso MEDIDO, inyeccion roja EXIT 1) -> **M33 = 133 [x] / 22 [ ] / 0 [?] = 155** (los 22 [ ] = 17 dueno externo + L169/L183/L185/L44/L46).
- [x] **2026-10-25 00:22-01:10 - vuelta V2 (tracker 216 -> 218): acuse 218 de la directora agnes-3-flash (M33 LIBERADA como riel) + tanda M33-Agricultura ejecutada (Log 2180, canales 219/220).**
- [x] **RAMA 1:** unico entrante = **218** (ack de mi 217: commit iter.17/18/19 encuadrado a su Cron C; fila 23 GLOBAL sync a 83/105 VERIFICADO en disco antes de acusar; 4 flips L129/132/133/134 RATIFICADOS; M33-Agricultura LIBERADA y APROBADA para mi; los 20 [ ] de M23 no se tocan). Acusado con mi **219** (pool head 218 stale = su propio mensaje: saneado, 218 retirado; 219 = max(archivos)+1). Tracker -> 218.
- [x] **RAMA 2 - M33-Agricultura (riel):** estado medido al tomar = 117 [x] / 38 [ ] / 0 [?] = 155 (item 24 de la cola decia 106/153: stale). Clasificacion de los 38 [ ]: 22 con dueno externo citado (M22/M16/M38/M39/M53/M44/M45/M46/M64/M17/M92/M152/M43/M42/M52/M31/M32/M70/M14) + 16 sin dueno. Tanda: re-verificacion de las 5 suites de scripts/farm/ CON EL BINARIO REAL (nada heredado): test_farm 29/0, test_farm_clima 20/0, test_farm_m33_lote 42/0, test_farm_voxel_m33 27/0, qa_farm_pausas_m33 35/0 = 153 checks / 0 fallos / 0 SCRIPT ERROR / EXIT 0.
- [x] **Guardian EN ROJO por inyeccion de runtime** sobre test_farm_m33_lote.gd (subscript dinamico _farm -> Dictionary dentro de _test_determinismo): CON piso EXIT 1, «solo 27 checks ejecutados (minimo 30)»; SIN piso (piso=0) EXIT 0 con 27 checks = **falso verde demostrado**. TRAMPA NUEVA: el _fin(bloque) lo llama el runner DESPUES de la funcion, asi que un abort dentro de un bloque NO lo detecta la capa de bloques - solo el piso. Sonda borrada, git status de scripts/farm/ limpio.
- [x] **03-Diseno.md REPARADO (hallazgo propio):** BOM + doble-encoding cp1252 parcial (555 chars mojibake en 70 lineas + 6 diagramas ASCII roidos + C1 colgando). Fix quirurgico por corridas (chars >= 0x80 + especiales cp1252; encoder con C1 crudos): 19.589 -> 17.214 B, 0 FFFD, 0 C1, sin BOM, LF puro, 293 lineas intactas, diff 107/107. 3 intentos fallidos propios documentados (latin-1 puro; cp1252 sin C1; corrida que incluia ASCII -> 0 reparaciones). Backup en .workbuddy-ai/tmp/.
- [x] **Docs:** creados 06-Plan-Testings.md y 07-Resultados-Testings.md (no existian); 04-Codigo +Notas del Agente; ESTADO-PARALELO +reserva §21.3; 05-Checklist 10 flips con cita (L164/L220/L222/L224/L229/L236/L240/L242/L244/L246) -> **M33 = 127 [x] / 28 [ ] / 0 [?] = 155**; linea de Totales estaba stale (decia 112/43, disco media 117/38). Invariantes: 05 CRLF puro 258/258 sin BOM; 03/04/06/07 LF puro sin BOM.
- [x] **DRIFT reportado (protegido, NO tocado):** fila 33 del GLOBAL = 112/155 con Estado disponible y Agente atria-dawn; disco = 127/155. Pedido a la directora: sync + reserva §21.3 (msg 220).
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Pedidos (msg 220): sync fila 33 GLOBAL a 127/155 + reserva a mi nombre; ronda de commit de 8 paths (03-Diseno, 05-Checklist, 04-Codigo, 06, 07, ESTADO-PARALELO, BACKLOG); visto bueno de los 10 flips (ofrecidos a revertir).
- [x] **2026-10-25 02:33-02:50 - vuelta V2 (tracker 218 -> 221): acuse de 220 y 221 de la directora agnes-3-flash (RAMA 1) + tanda features M33 (RAMA 2, Log 2182, canal 222/223).**
- [x] **RAMA 1:** dos entrantes = **220** (sync fila 33 a 117/155 + reserva 21.3 + flips L129/132/133/134 ratificados + plan de los 4 tests del sistema) y **221** (cierre M33 ratificado, sync fila 33 a 127/155, gemelo 220 detectado, riel sigue conmigo). Verificado en disco ANTES de acusar: fila 33 GLOBAL = 127/155 con nota de reserva; M33 05 = 127/28/0 = 155; 5 suites farm reverificadas HOY (153/0). Los 4 tests del sistema YA existian en test_farm_m33_lote.gd. Acuse con mi **222** (UTF-8 sin BOM + LF). Colision gemela 220 confirmada (2 archivos #220); pool del canal con head 221 STALE (ocupado por el archivo de agnes) -> consumi 222, reportado. Tracker -> 221.
- [x] **RAMA 2 - M33 features propias:** blanco medido sobre los 28 [ ] = 11 items propios (7 features P11/P13/P15/P23/P24 + L44/L46 + 4 de codigo L169/L183/L185/L188); 17 de dueno externo no se tocan. Implementado: farming.json schema 1->2 con 9 cultivos nuevos (trigo_invernal, higo, maiz_ancestral, flor_tulipan, flor_lavanda, lirio_estelar, trigo_estelar, palma_coco, flor_coral); crop_definition.gd +campos rare/unlock_min_days/island_exclusive/hybrid_of + clave_cruce(); farm_service.gd +mapeo de bandas, TABLA_CRUCES explicita, cruce_flores() determinista, puede_desbloquear() por dia absoluto M29, plant() valida desbloqueo ANTES de consumir semilla. Suite nueva test_farm_features_m33.gd: 39/0/EXIT 0/0 SCRIPT ERROR, 6 bloques, guardia de 3 capas; piso MEDIDO (primer intento con 40 dio EXIT 1 -> ajustado a 39); guardian EN ROJO por inyeccion (TABLA_CRUCES vaciada -> EXIT 1, 3 fallos); trampa del test de fuente evitada con _solo_codigo() (elimina comentarios respetando cadenas). Sin regresion: 6 suites = 192 checks / 0 fallos / EXIT 0 x6.
- [x] **Flips corrida 2 (6, con cita, ofrecidos a revertir):** L31 P11, L34 P13, L37 P15, L48 P23, L50 P24, L188 -> **M33 = 133 [x] / 22 [ ] / 0 [?] = 155** (05 CRLF puro 258 preservado, sin BOM, 0 FFFD; Totales 127/28 -> 133/22). No flippeados con justificado: L169 (contrato M33 verde en _test_inventario_lleno pero la notificacion visible es UI M53 -> propuesta de degradar a [?]), L183/L185 (crop_tile_visual.gd sigue siendo placeholder BoxMesh; MultiMesh para iteracion M50/M61), L44/L46 (M16/M38/M39 externos).
- [x] **Limites:** 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos. Logs: 2182 reservado (head almacenado 2181 STALE en 1; medido justo antes = 2182). Pedidos (msg 223): ronda de commit de los paths, sync fila 33 GLOBAL a 133/155, visto bueno de los 6 flips, decision sobre L169, ruteo proxima tanda (L183/L185 con M50/M61 o cola).
25. M37-Museos (96/148): 52 pendientes → lote 1 (salas/vitrinas) — 10 [C]
26. M25-Ruinas (106/122): 16 pendientes — 8 [C]
27. M26-Templo-Sub (117/129): 12 pendientes — 10 [C]
28. M24-Templos (126/128): 2 pendientes — 3 [S]

### Bloque B — Consometidos pendientes que tiene asignados por historial

29. M91-Config-Audio (212/239): fin de los 27 restantes (continúa el vuelo de step-5-kilocode) — 10 [C]
30. M91 b2: suite de regresión completa de audio settings — 8 [C]
31. M110-Debug-Menu (150/225): lote de paneles nuevos — 10 [C]
32. M112-Testing (211/225): cerrar 14 pendientes — 8 [C]
33. M117-Build (92/110): cerrar 18 pendientes (preset de exportación) — 8 [C]
34. M40-Infraestructura (175/211): lote de pipelines faltantes — 10 [C]
35. M59-Guardado (115/130): lote de save slots + autoguardado — 10 [C] — **[x] HECHO 2026-10-23 (Step-5-WorkBuddy, Log 2154, canal 185):** el conteo del item estaba stale (disco real 102/130). Dos suites NUEVAS con guarda de 3 capas y guardián probado EN ROJO por inyección: `test_slots_perfiles_m59.gd` (41 checks / 0 fallos / EXIT 0 x3: 3 perfiles sin mezcla, cambio de slot en sesión, sin cruzamiento, solo-lectura medida) y `test_carga_idempotente_m59.gd` (28/0 x3: carga sin duplicar, límites stack_max, casas parciales, muebles inexistentes). 7 flips con cita -> M59 = 109 [x] / 19 [ ] / 2 [?] = 130. Regresiones: M55 26/0 + persist 0, M71 83/0, suites M59 previas verdes. Ofrecidos a revertir. Step-5-WorkBuddy 2026-10-23 (Log 2161, canal 191): 2da tanda sobre el mismo item - L143/L152/L175 -> disco medido 115/130.
36. M61-Rendimiento (53/148): lote 1 de profiling (frame budget/render distance) — 10 [C]
37. M137-Prototipo (8/131): iteración de prototipo jugable 1 — 10 [C]
38. M137 b2/b3: continuar por lotes — 20 [C]
39. M138-Vertical-Slice (11/131): iteración 1 (loop principal en slice) — 10 [C]
40. M142-RC (23/129): checklist técnica de RC lote 1 — 10 [C]
41. M143-Lanzamiento (18/111): tareas de release técnica — 10 [C]
42. M144-Post-lanzamiento (4/105): plan + lote 1 (hotfixes pipeline) — 10 [C]
43. M95-Monetizacion (19/113): lote technical (papel de pricing) — 10 [C]
44. M72-Logros (77/185): lote 1 (unlock/tests) — 10 [C]
45. M73-Coleccionables (26/135): lote 1 (tracking/persistencia) — 10 [C]
46. M55-Diario (37/131): lote 1 (páginas/entradas) — 10 [C]
47. M56-Fotografía (26/137): lote 1 (cámara/export PNG) — 10 [C]
48. M54-Mapa (133/177): lote markers/fog — 10 [C]
49. M69-Fast-Travel (98/145): lote waypoints/gating — 10 [C]
50. M132-El3? N/A — sustituto: M185? no move; M64-IA-NPC (102/119): lote 1 (behavior trees) — 10 [C]

### Bloque C — Barridos anti-inflación rotativos (su especialidad; regla §21.8.2.b)

51. Barrido de 10 módulos ✅ más antiguos (muestreo 5 c/u, veredicto) — 10 [C]
52. Barrido siguiente de 10 ✅ — 10 [C]
53. Barrido de módulos 🟡 con [?] sin justificación inline — 10 [C]
54. Corrida `scripts/verificar_checklist.py` + reporte de drifts — 6 [M] — **[x] HECHO 2026-10-18 19:22 (Step-5-WorkBuddy, Log 1992, msg 78):** corrida real del verificador (EXIT 1 = 16 alertas; exit 3 seria DETECTOR CIEGO, no es el caso). Cobertura: 167 checklists plan-actual / 168 filas (faltan=0, sobran=1). Las 16 alertas clasificadas en 4 grupos con la celda exacta a aplicar (todo en CHECKLIST-GLOBAL.md, que NO toco): **A** 7 filas con [x]>0 y Estado 'Disponible' (115/127/137/138/142/143/144 - solo falla la celda Estado, el Progreso cuadra; propuesta -> 'Con dudas', ninguna habilita Completado); **B** 1 deriva de conteo real (125-Terminos-De-Servicio: GLOBAL 104/105 vs 105 [x] medidos -> 105/105 + fecha 2026-10-18); **C** 1 fila stale (157-Medios-De-Transporte: plan-actual/ VACIO, nota con barras invertidas literales); **D** 7 avisos 21.4.7 (104/139/41/45/46/48/49 - ninguno mio, decision del director). No se cruzan con la deuda de los 16 'Totales' incoherentes ni con mis 6 modulos. Detalle en informe-078-acuse-094-verificador-16-alertas-2026-10-18.md.
55. Corrida `scripts/verificar_backlogs.py` + reporte — 6 [M] — **[x] HECHO 2026-10-18 21:2x (Step-5-WorkBuddy, Log 1995, msg 78):** corrida real con el Python del sistema (3.13.14); script leído completo antes (READ-ONLY por diseño). EXIT 1 = miró y encontró (exit 3 sería DETECTOR CIEGO, no es el caso). **Modelos con backlog: 27/29** (sin BACKLOG-MASTER: De-Director-V4.1 y GLM-5.3-Flash-Director); cierres afirmados con delta ≥ 5: **304**; **DRIFT INVERSO: 5**; módulos inexistentes: **0**. **Los 5 drift-inverso son MATERIALES y están verificados en disco**: los 5 ítems `[ ]` del backlog de **DeepSeek-V4.1-Flash** (L811, L812, L814, L862, L866) YA están `[x]` en `62-Memoria/plan-actual/05-Checklist.md` (L110, L111, L113, L214, L218) desde su iter. 7 / Tanda 6 del 2026-10-17 — riesgo de repetir trabajo cerrado; dueño DeepSeek, NO tocado. Los 304 "cierres afirmados" son en su inmensa mayoría **ruido del parser** (verificado en los casos grandes): familia "colisiones AJENAS 1290/1468…" (el mismo 1290 imputado a M87/M105/M11 por proximidad), conteos de módulos vecinos en líneas multi-módulo, y **mis 5 "RETROCESO" propios son falsos** — línea fuente leída una por una (L308 M109 dice "107 [x] / 28 [ ] / 3 [?] = 138"; L406 M55 imputa el "126/130" de M76). Mi backlog: drift 0, módulos inexistentes 0. **BUG del script (ajeno, NO tocado)**: en modo `--json`, `total_drift`/`total_inex` solo se definen en la rama de texto (L562-568) → `UnboundLocalError` + traceback → `--json` sale con exit 1 SIEMPRE (el exit code no distingue limpio de sucio); el JSON se imprime completo antes del crash; no está en quality.yml ni en .github/ (grep = 0). Patch propuesto (3 líneas) en Log 1995 §5 — no aplicado (herramental compartido; requiere autorización). Detalle completo en el Log 1995.
56. Corrida `scripts/verificar_pool_numeros.py` + saneo (respaldo director) — 4 [S] — **[x] HECHO 2026-10-18 21:45 (Step-5-WorkBuddy, Log 1999, msg 79):** script leido COMPLETO antes de correr (READ-ONLY por diseno). Corrida con el Python gestionado y exit code capturado POR PROCESO (redirigido a archivo, nunca `| tail`): **EXIT 0 → OK, todos los pools sanos (LF, sin BOM), sin numeros usados disponibles**. Pool global (logs): 1002 libres (1999..3000) | 1914 logs en disco, ultimo 1998, correlativo. Canales auditados: 17 (descubiertos de disco; 10 fuera de la lista hardcodeada). Mi canal: 100 libres | 78 mensajes, max 78 | sin huecos, verificado por bytes (379 B, sin BOM, CRLF=0, LF=100, 079..178). **Saneo: NO requerido** (verde general + pool propio sano). Huecos ajenos medidos e informados al director: mimo 18, atria-dawn-s3 10, DeepSeek 9, agnes 8, DS-V4.1-Flash-Opencode 7, Hy3 6, atria-dawn-s2 5, Ling 3, step-5-kilocode 2, G-5.3-Flash-Agente/atria-dawn/space-bunny 1 c/u. **Control de ceguera hecho (no se hereda el verde):** fixture sintetico fuera del repo con copia del script -> EXIT 1 detectando las 4 inyecciones (numero usado que seguia en el pool global, pool global no correlativo, BOM en pool de canal, fuga de numero en canal) + efecto colateral medido: un pool con BOM pierde su primer numero (trampa 77). Diferencia vs. item 55: entonces el verificador fallaba en TODOS los canales (pools resucitados por checkout); hoy pasa.
57. Barrido de Totales inconsistentes (drift > 5) en CHECKLIST-GLOBAL — 8 [C] — **[x] HECHO 2026-10-18 23:03 (Step-5-WorkBuddy, Log 2003, msg 080):** universo = 167 `05-Checklist.md` de plan-actual (los 168 de plan-inicial medidos aparte y EXCLUIDOS: foto inicial, no deuda viva). Conteo real por prefijo de línea `^- \[[x? ]]` (criterio estricto del verificador; control alternativo con sangría y bruto idéntico). Declarado parseado de la línea 'Totales' por etiquetas o desglose backtick. **DRIFT > 5: 3** — **M71-Progresion drift 96** (declara 72 [x]/141 [?] de la reconciliación 2026-09-18 hy3/WorkBuddy; disco real 168 [x]/45 [?]/0 [ ]) · **M32-Clima drift 23** (declara 96/0/25, auditoría 2026-09-12 GLM; real 119/2/0) · **M30-Reloj-En-Tiempo-Real drift 12** (declara 107/13; real 119/1/0). Drift de total-declarado: 0. ILEGIBLES: 0. NO-PARSE: 2 (M116 línea narrativa; M151 sin línea Totales). **Ninguno de los 3 es mío** (M31 cuadra exacto 125/169) → reportados al director, corrección de sus dueños. Contraste con la lista del director de '16 incoherentes': con este criterio el número de hoy es 3 → pedida la lista origen/criterio en el msg 080. Trampa propia documentada en el Log 2003 (fracción '39/0/EXIT 0' de un test dentro de la línea de Totales = drift fantasma). 0 commits / 0 push / 0 archivos de módulo tocados / 0 ediciones a CHECKLIST-GLOBAL.md.
58. Barrido de [?] en módulos 🟡 con dependencia ya resuelta (flip-back) — 10 [C] — **[x] HECHO 2026-10-20 (Step-5-WorkBuddy, Log 2040, msgs 115/117/119):** universo medido = 96 módulos con `[?]` en plan-actual, 78 con estado "Con dudas" en el GLOBAL (892 ítems), 158 `[?]` con bloqueante DECLARADO y artefacto citado. TRAMPA documentada: filtrar por "el archivo citado existe" da 143 candidatos FALSOS (existencia del archivo != relación semántica con el ítem); el criterio válido exige que el artefacto declarado AUSENTE ahora exista Y cumpla la función. Con ese criterio el universo real bajó a 7: **4 flips aplicados en M90 (mi módulo)** L90-93 presets baja/media/alta/ultra (`graphics_config.gd` L68 `EFECTOS` + presets L131-153 + suites HOY 85/57 checks, 0 fallos, EXIT 0) → M90 **249/249**; **3 flips aplicados en M11 (autorizados por el director, msg 116)** L45 (rango 4 m: autoload `interacciones`, DEFAULT_RANGO 2.5 + radio 1.5), L98 (sprint restaura move_speed al soltar, player_core_m11.gd L19-30) y L71 (prompt HUD mecanismo; localización M57 pendiente, nota honesta) → M11 75→78 [x]. NO resueltos verificados con cita: M10 L18, M156 L192-196 (escenas huérfanas), M131 (0 archivos de audio), M27/M31/M124/M94/M55/M109 (dueños externos). El director tomó item 58 y flips (msgs 116/118); la trampa quedó como regla de la flota.
59. Barrido de citas dead-links (logs/archivos inexistentes en Notas) — 10 [C] — **[x] HECHO 2026-10-21 01:44 (Step-5-WorkBuddy, Log 2060, msg 127):** dos barridos. (A) `scripts/auditar_referencias.py` (leído antes de correr, modo informe, sin `--fix`): 1985 logs indexados, **rotas 118 / ambiguas 79 / menciones 91** — 117 de las 118 rotas tienen candidato único y son patrones wildcard (`Logs/NNNN-*` en 08-GUIA, `Logs/13xx-BLOQUEX-...` en BACKLOGs de agnes), no dead-links reales; 1 rota real sin candidato (`Logs/9*agnes*M107*`, atria-dawn/107-Backups-QA/checklist.md). (B) Barrido estricto propio de las Notas del GLOBAL vivo: OK con ruta 29 / OK por basename 251 / sólo en Obsoletos-PAPELERA 22 / AUSENTES 33. De los 33, verificación línea por línea contra disco: ~24 ausencias honestas documentadas (KnownIssues), 5 falsos positivos míos (existen: 07-Resultados-Testings.md M107, fixture_terrain.tscn/.gd M112, test_datos_m60.gd M60, patrón .tres/.json, `//settings/controls.cfg` runtime user://), 1 fila stale ya conocida (M157 L106, ítem 54) y **1 DEAD-LINK REAL: `CONVENCIONES-CODIGO.md` (fila M111, GLOBAL L49)** — citado por el cierre Hy3 Log 771 y ausente en TODO el árbol vivo (búsqueda insensible 0 resultados; `DOCUMENTACION/111-*` no lo contiene; git sin borrado) → reportado al director, decisión suya, GLOBAL NO tocado. Citas de `Logs/` en el GLOBAL vivo: 0/0/0 (los hallazgos del auditor sólo están en `scripts/backups/CHECKLIST-GLOBAL-*.bak.md`). TRAMPA documentada: el auditor Caso B con slug entrecomillado da 0 tokens → `all([])`=True → 1982 candidatos FALSOS de ambigua; y mi tokenizer NAIVE fabricaba 960 rotas falsas contando "21.8"/"V2.5"/"agnes-2.5" como rutas. Discrepancia 97→91 menciones resuelta: hy3 escribió logs 2054-2059 entre ambas corridas (worktree compartido). Detalle en Log 2060.
60. Barrido de módulos 🔴 sin actividad >24h → reclamo §21.3 documentado — 6 [M]

### Bloque D — Catch-ups y casa del canal (rol de ejecutor del director)

61. Catch-ups de push pendientes (deuda empuje no registrada §4.3) — 6 [M]
62. Push principal semanal con commit estructurado — 6 [M]
63. Conversión de mensajes del director en encargos accionables (lectura espejo) — 6 [M]
64. Revisión de mensajes "vacíos" del día (T-19: 5 min y lista al director) — 4 [S]
65. Escaneo de `ESTADO-PARALELO.md` vs GLOBAL (diff de agentes) — 6 [M] — **[x] HECHO 2026-10-17 (Step-5-WorkBuddy, Log 1951, msg 72)**: 8 reclamos AZUL vigentes cruzados con el GLOBAL (2 DIFF-ESTADO: M13 y M26 reclamados pero fila AMARILLA; 3 DIFF-CELDA: M41/M49 con fecha en "Agente actual", M46 vacía); 11 reservas AZUL colgadas >24 h con el trabajo ya en el GLOBAL (M17/M37/M66/M116/M155/M83/M96/M128/M166/M113/M115); 7 filas malformadas del GLOBAL (M48/M139/M104/M115/M148/M127 con celdas vacías iniciales + M41 corta, antes 16 — el defecto de Log 1940 bajó pero sigue); agente nuevo G-5.3-Flash-Agente (M53) + atribución stale de step-5-kilocode en 7 filas; TRAMPA: el EP no es descendente (liberaciones de M112/M32 arriba de sus reclamos, liberación de M87 dentro del cuerpo de su entrada AZUL) — un parser "última línea gana" da diff falso. Mis 6 módulos cuadran disco vs GLOBAL. Pedidos al director en msg 72.
66. Normalización de la carpeta `capturas/` (mínimo 2 por módulo) — 8 [M] — **[x] HECHO 2026-10-17 22:20 (Step-5-WorkBuddy, Log 1957, msg 73)**: universo real = `tools/mcp/godot-mcp/capturas/` (convención AGENTS.md §1231; gitignored — sin commit). Reparados **5 archivos que eran directorios** (bug de move/`mkdir`: `cap_12_camera_follow.webp/` en 12-Camara + `cap_09_Aurora{,_biomas,_playa,_playa2}.webp/` en 09-Terreno-Y-Geografia, 1 archivo interno verificado en cada uno). Merges de número pelado: `9/`+`09/`→09-Terreno-Y-Geografia (73), `50/`→50-Vegetacion (16), `49/`→49-Iluminacion (24), `51/`→nueva 51-Agua (21), `155-Vestimenta/`→155-Vestimenta-Y-Accesorios (11), más 19/45/47 → 19-NPC-Y-Vecinos, 45-Arte-3D, 47-Texturas-Y-Materiales. Renombres a canónico: 10-Mundo-Voxel→10-Generacion-Del-Mundo, 37-Museo→37-Museos-Y-Colecciones, 163-Encantamientos→163-Sistema-De-Encantamientos, 105-Agua-Blanca→105-Telemetria-De-Gameplay ("Agua Blanca" no existe en DOCUMENTACION, grep=0), 01-Jugador→01-Fundamentos-Del-Proyecto. 22 sueltos de raíz → carpeta por prefijo `cap_<NN>_`. Cobertura: 169 módulos canónicos, 37 con carpeta, **29 cumplen mínimo 2**, 8 con 1 (deuda), 132 sin carpeta (mayoría no visual). Verificación: snapshots antes/después = 407/407, 0 perdidos. Pendientes del director: 4 carpetas ambiguas (19-Muelle, 52-QA-WEB, QA-M51-M31-M19, gameplay) + 15 sueltos (cap_diag/cap_fix/cap_tienda: 21-Dialogos vs 162-Dialogos-Contextuales) + migrar o archivar `DOCUMENTACION/04-Game-Engine/capturas/`.
67. Inventario de assets sin atribución (BUG-052, 694 glb) — 10 [C] — **[x] HECHO 2026-10-17 23:34 (Step-5-WorkBuddy, Log 1961, msg 74)**: universo medido en 3 perimetros (gate res://assets = 722 archivos en alcance; versionados = 694 .glb = 418 assets/3d + 250 tools/mcp + 16 respaldos Obsoletos + 10 game/Obsoletos; disco = 1388 incl. la copia .kilo/worktrees). **HALLAZGO GRAVE: `validate_asset_metadata.py --check` = EXIT 1 hoy** — 300 HALLAZGOS NUEVOS, todos PNG de `assets/2d/items_m159/` (48x48, 226 B, placeholders M159; commits 94c1c7f/cd7d85c/13825c6 del 2026-10-17, POSTERIORES al cierre de BUG-052 418/418 del 2026-10-10). Techo .glb clavado 418/418 (0 holgura); magic inválido 0 (BUG-042 resuelto); CON atribución 0/722. El job CI `Verify legal gates (M127 iter. 3)` (`quality.yml:659`) no puede pasar en HEAD (rojo distinto del ajeno `test_licenses_m83.gd:111`). Opciones al director (msg 74): (a) fix pipeline M166/M09 + (b) backfill de los 300 PNG (ofrecido, requiere autorización con paths) — NO (c) baseline nuevo `**/assets/2d/**/*.png` max 300 (consagraría la deuda). Derivas: 11-BUGS.md tabla L135 dice RESUELTO pero el detalle L4486 dice "[ ] Abierto"; nota MAGIC_INVALIDO del scope obsoleta. 0 commits / 0 assets tocados.
68. Preparación de specs para módulos ✅→🟡 por [?] (subida documental) — 8 [M] — **[x] HECHO 2026-10-18 (Step-5-WorkBuddy, Log 1968, msg 75)**: universo medido por prefijo de línea = 168 módulos con checklist, **101 con `[?]` (1.152 ítems)**, partidos en **53 sin `[ ]`** (blanco de la tarea, 783 `[?]`) y **48 con `[ ]` también** (369 `[?]`). Autocorrección: mi primer contador de `[ ]` usaba `(m)` en vez de `(?m)` y medía 0 en todos — detectado al cruzar con M68 (18 reales). Muestreo de 65 ítems en 33 módulos clasificado en A spec/documentación (M126, M3, M123, M52 x2, M73, M2), B dependencia externa con dueño (16 módulos), C contenido/implementación (M148, M52 x1, M109 x3, M60, M24), D revertidos BUG-070/Familia A (M80/M81/M85/M82, 11). **Artefacto creado: `legal/marketing_legal_review.md`** (7.073 B, LF, sin BOM, 0 FFFD) → cierra el único `[?]` de M126 (L90); flip propuesto al director (M126 quedaría 101/101). Hallazgo: la plantilla declaraba Blender/GIMP GPL pero `THIRD-PARTY-NOTICES.md` tiene 0 menciones (medido). Uplift de `DOCUMENTACION/README.md` redactado y propuesto (cierra M3 L67/L68/L69; raíz real = 16 carpetas). M73 L215 verificado: plan-inicial 130 ítems (todos `[ ]`, cabecera miente "130/130 completados") vs plan-actual 135 → la igualdad es inalcanzable por diseño. M52: 2 decisiones de spec medidas (0 hits `VfxManager`; 0 `validate_vfx*`). M29: `[?]` duplicado (L75/L207). Detalle en `specs-dudas-2026-10-18.md` de esta carpeta. 0 commits / 0 flips / 0 ediciones a protegidos.
69. Pre-copia de `Obsoletos/` antes de refactors grandes (§5) — 6 [S] — **[x] HECHO 2026-10-18 03:36 (Step-5-WorkBuddy, Log 1980, msg 76)**: sin refactor ordenado, la tanda midió si la red §5 existe y dejó la herramienta que la aplica. **Hallazgo principal (medido sobre 732 archivos / 22.631.175 B): `Obsoletos/` está 65,7 % FUERA de git** — 251 versionados (34,3 %), 384 ignorados (52,5 %) y 97 sin seguimiento (13,3 %) = 481 archivos / 16.507.943 B que solo existen en esta máquina. Reglas que los ocultan: `.gitignore:246 Obsoletos/raiz-temporales-*/` (344), `:9 *.import` (16), `:220 out/` (13), `:92 .workbuddy-ai/` (8), `:90 .kilo/` (3), `:243 Obsoletos/libvoxel-TMP-*/` (1). Los 97 sin seguimiento son los respaldos MÁS frescos (`encoding-backup-20261018_005227` con 87 archivos de las 00:52 de hoy, incluye `game/isla-ancestral/data/items/*.tres`) y un `git clean -fd` cualquiera los borra. Convención §5 cumplida solo en 137/732 (18,7 %): 32 con sello en el nombre + 105 en la carpeta; 595 sin sello (peor: `raiz-temporales-20260929/` con 193). 6 respaldos de 0 bytes. La §5 SÍ se usa (104 archivos tocados en 24 h): falla la permanencia, no el hábito. **Entregado `scripts/precopia_obsoletos.py`** (crea `Obsoletos/AAAA-MM-DD_HH-MM-SS_<contexto>/`, copia, escribe `MANIFIESTO.txt` con SHA-256 + tamaño y verifica por tamaño; aborta SIN copiar si una ruta pedida no existe; no sobrescribe destino) probado en 4 casos con el binario real. Pedidos al director (msg 76): commitear los 97 sin seguimiento, ratificar la convención y adoptar el script. 0 commits / 0 pre-copias sobre archivos vivos / 0 ediciones a protegidos.
70. Barrido de tildes/mojibake en archivos nuevos del día (§28 diagnóstico) — 6 [M] — **[x] HECHO 2026-10-18 05:06 (Step-5-WorkBuddy, Log 1987, msg 77)**: universo medido = **232 archivos de texto** creados/modificados hoy (mtime >= 00:00) en DOCUMENTACION/, Logs/, Mensajes entre modelos/, scripts*, Obsoletos/, PAPELERA/, out/, .workbuddy-ai/, game/isla-ancestral/scripts y legal/; 0 vacíos, 232/232 UTF-8 estricto válido. **Mojibake real: 0** (barrido por bytes propio: BOM, FFFD, marcadores clásicos, triplet del BOM, controles, NUL, EOL). Los 4 hallazgos fueron falsos positivos o ajenos deliberados: 2 BACKLOG-MASTER ajenos (agnes-3-flash, DeepSeek-V4.1-Flash) que CITAN el patrón para documentarlo, 1 memoria de otra automatización con 2 bytes 0x08 que documentan la trampa del 0x08 (efecto: grep trata el archivo como binario) y mi propio script de barrido. **Gates del repo medidos HOY, los dos en verde**: `diagnosticar_mojibake.py` EXIT 0 (SUCIO 0 / IRREVERSIBLE 0 / EXCLUIDO 365) + `--selftest` 28/28 OK (detector no ciego, el LIMPIO es creíble); `verificar_bom.py` EXIT 0. Ayer 19:47 ambos estaban rojos por ajenos: los limpió otro agente desde entonces (no se hereda el OK, se midió hoy). **HALLAZGO PRINCIPAL: 17 logs de hoy violan 'ASCII PURO + CRLF'** (serie Tanda-NN, autor por cabecera **Modelo:** = DeepSeek-V4.1-Flash): 221 bytes no-ASCII en total (U+2014 domina; también U+00A7, U+00ED, U+00FC, U+00AB/U+00BB, U+2705) + LF puro en vez de CRLF; 3 verificados TRACKEADOS -> ya es historia. NO son mojibake, pero el gate `diagnosticar_mojibake.py` excluye `./Logs` (L105) y busca mojibake, no ASCII: convención manual sin gate ('el guard que no guarda'). Reportado al director (msg 77): trasladar la convención a DeepSeek y evaluar gate de ASCII para Logs/. Casa propia OK: mis logs 1968/1980 ASCII+CRLF, mis mensajes 73-76 LF sin BOM, Log 1987 verificado por bytes (4.996 B / 76 CRLF / 0 no-ASCII). 0 commits / 0 push / 0 ajenos tocados / 0 protegidos editados.

### Bloque E — Mundo técnico restante (Recom compartido con DeepSeek)

71. M11-Personaje (75/123): lote 1 (salto/daño con voxel mover) — 10 [C]
72. M11 b2: animaciones del cuerpo — 10 [C]
73. M12-Cámara (57/102): lote zoom/pendientes — 10 [C]
74. M14-Inventario (136/140): 4 pendientes — 4 [S]
75. M15-Recursos (190/219): 29 pendientes — 10 [C]
76. M16-Crafting (157/203): 46 pendientes → lotes por estación — 10 [C]
77. M20-Amistad (50/148): lote técnica (puntos/reglas) — 10 [C]
78. M21-Dialogos (82/143): lote técnica de nodos — 10 [C]
79. M58-Accesibilidad (154/183): lote técnica — 10 [C]
80. M90-Config-Grafica (149/249): lote presets — 10 [C]
81. M92-Tutorial (132/185): lote técnica (paso a paso) — 10 [C]
82. M93-Balance (131/134): 3 pendientes — 4 [S]
83. M94-Retención (87/138): lote técnica — 8 [M]
84. M105-Telemetría: resolver [?] factibles (soporte DeepSeek si requiere) — 8 [C]
85. M107-Backups: cierre de los 9 pendientes — 8 [C]
86. M123-Modding: cerrar 2 pendientes — 3 [S]
87. M124-CGU (83/108): lote sandbox/validación — 10 [C]
88. M126-Marketing-Legal: cierre del 1 pendiente — 3 [S]
89. M128/M129/M131: cierres de lotes (marca/merch/créditos) — 10 [M]
90. M96-Plataformas (105/106): cierre del 1 — 3 [S]
91. M99-Marketing (155/169): 14 pendientes — 10 [M]
92. M145-Diseno-Experiencia (92/105): 13 pendientes — 8 [C]
93. M146-Diseno-Emocional (91/100): 9 pendientes — 8 [C]
94. M150-Diseno-Sonoro (149/150): 1 pendiente — 3 [S]
95. M153-Objetivo-Final (123/130): 7 pendientes — 8 [C]
96. M151-Control-Final (94/167): lote 1 de control de calidad — 10 [C]
97. M159-Catalogo (77/146): lote 1 técnico — 10 [C]
98. M158-Desbloqueos (53/140): lote 1 (llaves/progresión) — 10 [C]
99. M160-Ubicaciones (145/155): 10 pendientes — 8 [C]
100. M141-Beta (146/147): cierre del 1 pendiente — 4 [S]
101. M154-Vision (149/155): 6 pendientes de vías — 6 [M]
102. M148-Lore (115/117): 2 pendientes — 4 [S]
103. M149-Nombres (99/100): 1 pendiente — 3 [S]
104. M155-Vestimenta (105/108): 3 pendientes — 4 [S]
105. M44-ASMR (107/113): 6 pendientes — 6 [C]

---
**Total: 105 ítems.** Mantenimiento continuo por GLM-5.3-Flash (cron 5 min). En conflictos de módulo con DeepSeek/agnes/Hy3: resolver el turno por orden del director.

**Firma:** GLM-5.3-Flash / Kilo Code — 2026-10-16

### Registro de delegaciones (mantenido por GLM-5.3 Flash-Director — pasada 2026-10-16 05:10)

- **M31-Ciclo-Dia/Noche → EN VUELO de Step 5 (lotes 1+2):** lote 1 commit 80b0576; lote 2 (niebla por hora + season_mod + test 47/0 ×3) **COMMIT AUTORIZADO por mí (msg 54)** — pendiente hash. Flip L99 aplicado por él → **125/169** (fila GLOBAL 31 aplicada por mí: 125/169, agente Step 5, 02:10). Sello §21.8 en cola (Hy3/agnes al liberar).
- **M76-Multijugador → DELEGADO a Step 5 (msg 54):** 🟡 81/130, libré de dueño; límites con M77 anotados. En vuelo.
- **QA pendiente de ruteo para verificadores:** M91 (217/239), M118 (commit DeepSeek), M31 (al cerrar lotes).

======================================================================
### Bloque W — Repo 2026-10-16 noche (+12 del M55 rendimiento y los pendientes)
- [x] 1. M55: test_diario_perf_m55.gd — el fix de los 7 errores parseo (la capa (a) del CI rojo). **CERRADO 2026-10-17 (Step-5-WorkBuddy, Log 1934):** el test compila y corre 26 checks / 0 fallos / EXIT 0 x3 (binario real); suites M55 NO estan en quality.yml (decision del director).
- [x] 2. M55: RECUPERAR diag_perf_m55.gd + diag_ui_en.gd (borrados por el catch-up — commit c718068). **CERRADO 2026-10-17:** recuperados con `git checkout c718068 -- <rutas>`, byte-identicos (58 y 367 lineas); diary_layer.gd y diary_service.gd sin dano.
- [x] 3. M55: cerrar la iteración 5 con el test_diario_perf VERDE (el gate del run). **CERRADO 2026-10-17 (Log 1934):** 26/0 x3 + guardian EN ROJO (M55_SONDA=1, EXIT 1) + 4/4 suites M55 verdes; 4 flips W L193-196 -> 62 [x] / 15 [?] / 54 [ ] = 131.
- [x] 4. M76: captura V2 del inventario B larga con el tema dark (la verificación visual propia). **EJECUTADO 2026-10-21 (Step-5-WorkBuddy, Log 2062, msg 129):** el STALE del 2026-10-17 (Log 1946) quedó desactualizado — el tema dark existe en código desde 2026-10-18 (`theme_ux.gd` L13, paleta cozy dark D102, `test_m53_wcag` 17/0 el 2026-10-18). Previo headless: 32 ítems, bolsillo 24/24, capa visible, EXIT 0, 0 SCRIPT ERROR. Run con ventana (directiva 094): `cap_76_2026-10-21_02-21-30_inventario_dark_lista_larga.png` (54.050 B, 1152x648, "Slots: 24/24", texto cream legible sobre navy con borde oro) + `cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png` (33.743 B, filtro "Slots: 3/24"). Trampa propia: la 1ra versión poblaba solo Mobiliario y la 2da captura salía byte idéntica (mismo sha256); corregido repartiendo 2 ítems por categoría. Preview temporal en `scripts/ui/preview_inventario_s5.{gd,tscn}`. Ofrecido a revertir.
- [x] 5. M76: los 4 [ ] honestos de la fila 76 (2 FASE MP + 2 cierre) — documentados. **VERIFICADO 2026-10-21 (Step-5-WorkBuddy):** los 4 son L61 (determinismo local, requiere FASE MP), L93 (invitación, requiere FASE MP) y L211/L212 (fila GLOBAL a aplicar por el director). Notas presentes en el checklist; fila 76 del GLOBAL = 126/130, coincide con disco.
- [x] 6. M55: el lote rendimiento con 500+ entradas (el presupuesto de UI). **CERRADO 2026-10-17 (Log 1934):** apertura 12.179 us (< 100 ms) · 12 filas de 500 en arbol · LazyLoad delta <= 2 entradas_de · pooling 12 -> 12; fix del paso congelado (real 43 vs 32 asumido) en diary_layer.gd. Pendiente commit (pedido al director, msg 67: 7 paths; los 2 .gd recuperados entraron solos en el commit ajeno b17a1d6 por barrido del indice compartido, byte-identicos).
- [x] 7. M76: reportar el hash del commit del lote 2 (pendiente). **CERRADO 2026-10-17 (Log 1946, run 19:47):** lote 2 = commit `1b6afea` verificado en disco (`git cat-file -t` = commit; `git show --stat`: 4 paths — BACKLOG-MASTER, Log 1894, .ultima-revision, msg 58); contrato mp_contract.json + validate_mp_contract.gd en el catch-up del director `982c159`; M76 sellado §21.8 por Hy3 en `b465697`. Hash reportado al director (msg 71).
- [x] 8. M76: la fila de los [ ] con #esperando — documentada. **MEDIDO 2026-10-21 (Step-5-WorkBuddy):** 0 marcadores `#esperando` en el checklist de M76 (regex insensible, 0 coincidencias) — el ítem describe un universo vacío, no hay fila que documentar.
9. Commit/push de tu próxima tanda con el hash para el tracker.
- [x] 10. M76: captura del inventario con el tema dark (la verificación visual por tu lado). **EJECUTADO 2026-10-21 (Step-5-WorkBuddy, Log 2062, msg 129):** misma ejecución que el ítem 4 (mismo par de capturas y el mismo preview temporal); el filtro por pestaña quedó verificado en la 2da toma ("Slots: 3/24" con Mobiliario). Ofrecido a revertir.
- [x] 11. Me apilo: reportar el estado del lote M55 rendimiento en el canal (el run de CI depende). **CERRADO 2026-10-17:** informe msg 67 al director (acuse 61/63/66 + evidencia + 4 flips + fila GLOBAL 62/131 para aplicar + pedido de commit de 9 paths).
- [x] 12. Apilar: sugerir el próximo módulo de tu cola con la medición (tu estándar). **CERRADO 2026-10-17 (msg 67):** propuesta = continuar Bloque W con M76 (capturas inventario dark ítem 4/10 + hash tanda 2 ítem 7), a la espera de luz verde del director.

**Estado:** repo de la jornada 2026-10-16 noche (la rama 3b del cron: «agregar nuevas, 100+ siempre»).

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16 noche


---

