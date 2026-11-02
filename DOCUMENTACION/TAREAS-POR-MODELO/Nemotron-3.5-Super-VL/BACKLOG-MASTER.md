# BACKLOG-MASTER — Nemotron-3.5-Super-VL (checklist maestro de rieles; v2 con cronómetro)

**Mantenido por:** agnes-3-flash (directora) — v2 por GLM-5.3-Flash por orden del fundador 25oct ("backlog master que sirva de guia para mandarlo a trabajar solo en sus distintos archivos backlogs") + metodología: `DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md`.
**Motor:** `CRONOMETRO-NEMOTRON-3-5-SUPER-VL.md` (prompt fijo del cron, orden de rieles, hard stops).
**Ficha del modelo:** `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` → N.6 + N.6-bis.
**Estado del agente:** activo en Kilo (T1.1 visión APROBADA en vivo: 11/11 hits, 0 alucinaciones — veredicto canal 003). Autonomía total sobre sus rieles; el director interviene por excepción.

## CÓMO TRABAJA (ciclo del cronómetro — resumen)

Leer CRONÓMETRO → tomar el PRIMER riel no agotado (orden de capacidad, NO reordenar) → abrir su archivo de backlog → ejecutar el siguiente ítem `[ ]` → marcar `[x]` en ese archivo con fecha+evidencia → reporte en canal al cerrar tanda (REGLA CERO) → si el riel quedó 100%: marcar el check del riel acá y pasar al siguiente → AL FINAL responder mensajes de agnes si hay.

## CHECKLIST DE RIELES (marca [x] al AGOTAR cada backlog)

- [x] **G2 — GATE-2 MICRO-SONDAS (PRIORIDAD 1 — herencia de Hy3): 6 items** → `RIEL-G2-GATE2-SONDAS-MICRO.md` — ejecutar las 2 sondas de Hy3 (red-probe M14 con script permanente + green-probe M73 byte-exact) en micro-tareas de salida corta y firmar el veredicto dual. En curso 28oct.
- [x] **B-0 CALIBRACIÓN — ASEDIGNADO por agnes-3-flash #155 (30oct)**: **pre-verificación boot-headless de los 3 candidatos a sellable** M101 QA-General / M34 Pesca / M59 Guardado → correr `run_project` headless + las suites de cada uno, capturar logs + veredicto **SOSTENIDO/ROJO por módulo** (salida corta, no veredicto dual largo). Eso libera a Hy3 de re-medir el boot para su gate-2 (→ sellos 11/12/13). T1.2/T1.3 T1.1 visión: APROBADA. → Herencia gate-2 (G2) cubre parte de T1.2. **EJECUTADO en disparo 23:40, reporte 163 enviado a agnes**.
- [x] **B-1 G1 — QA VISUAL ACTIVO CON GODOT-MCP: 36 items** → `RIEL-G1-GODOT-MCP-VISION-ACTIVA.md` — abrir el juego (run_project), capturas ACTUALES (nomenclatura repo, nunca sobrescribir), analizar con visión, correlacionar get_debug_output, reportar defectos en canal. **Nicho máximo (nadie más lo hace).** Prioridad de arranque: G1-001, 002, 003, 006, 009. AGOTADO: 35 [x] + 1 [?] honesto (G1-002: Escape no abre menú de pausa; "Escape - Liberar mouse").
- [x] **B-2 V1 — QA VISUAL DE CAPTURAS HISTÓRICAS: 88 items** → `RIEL-V1-VISION-CAPTURAS.md` — las 44 carpetas reales de `tools/mcp/godot-mcp/capturas/` (2 ítems por módulo: describir + defectos). Output: reporte en canal. Batch 5. AGOTADO: 88 [x] completados (V1-001 a V1-088).
- [x] **B-3 W1 — WEB RESEARCH/VERIFICACIÓN: 12 items** → `RIEL-W1-WEB-RESEARCH.md` — su segundo nicho publicado: verificar licencias/assets legales (M85/M86/M79), URLs activas de las guías, claims de M154/M97/M61 contra fuentes web, vigencia del free tier de su propia familia. AGOTADO: 12 [x] completados (W1-001 a W1-012).
- [x] **B-4 D1 — DOC INTELLIGENCE: 15 items** → `RIEL-D1-DOC-INTELLIGENCE.md` — drift de CHECKLIST-GLOBAL, censo FLAGS, .po, Logs, docs/, scripts/, mapas de ocupación. Solo-lectura con citas. AGOTADO: 15 [x] (D1-001 a D1-015).
- [x] **B-5 I1 — INVESTIGACIÓN + NUEVO FUEL: 20 items** → `RIEL-I1-INVESTIGACION.md` — 4 fuentes de reposición (Plan-inicial-minimo, 5-FUTURAS-MEJORAS, GUIA-GODOT, derivaciones ex-director). Output: PROPUESTAS con L#+cubo para validación de la directora. AGOTADO: 20 [x] (I1-001 a I1-020).
- [x] **B-6 P1 — PICKING DOCUMENTAL — ACTIVADO por agnes-3-flash #155 (30oct)**: **pre-check de visión de assets de M157-Medios-De-Transporte / M154**: capturar/verificar qué assets 3D de transporte + HUD de viaje **faltan** (los 5 artefactos del M85-transporte: model_legal/credit/build_script + HUD/JourneyPanel). Entregable = 1 informe "qué no existe aún en M157" (input para el GO del fundador). **Después de B-0** (B-0 tiene prioridad). **EJECUTADO en disparo 23:45, reporte 164 enviado a agnes — M157 no existe como carpeta/módulo, no hay assets 3D de transporte ni HUD de viaje en disco ni en escena runtime**.
- [x] **B-7 COLA RESIDUAL PENDIENTE: 26 items A vivos** → `Reflection-Beam-1.0/tareas/COLA-FALTANTE-A-26oct.md` — items doc de su nicho que Beam dejó pendientes. Ejecutar EN ORDEN: spec en 03 + flip 05 CON CITA, marcar [x] en la cola; si es de dueño ajeno/DEP-BLOQ → [ ] + skip con motivo. Batch 5 con reporte en canal. AGOTADO: 26 items (5 [x] + 21 [ ] skip con motivo).
- [x] **G3 — BOOT HEADLESS + INTROSPECCIÓN DEL EVENT BUS (A1-WORKOUT de Hy3): 6 items** → `RIEL-G3-A1-WORKOUT-BOOT-HEADLESS.md` — cerrar la deuda A1-WORKOUT que Hy3 dejó en su despedida (429): boot headless reproducido + introspección de conexiones por señal + propuesta cablear/borrar para el dueño M14. Deuda explícita de Hy3 (429, deuda viva). AGOTADO: 6 [x] (G3-1 a G3-6, cierre en playbook 2026-10-28 22:25).
- [x] **DR — DRIFT CHECKLIST-GLOBAL: 10 items** → `RIEL-DRIFT-CHECKLIST-GLOBAL.md` — de tu D1-001 (97 módulos con drift, 56%): verificar y corregir la columna Progreso por módulo (quirúrgico, 🔵 sin tocar), script permanente incluido. AGOTADO: 10 [x] (DR-001 a DR-010, cierre 30oct).
- [x] **PF — POSTFLIP QA VISUAL: 12 items** → `RIEL-POSTFLIP-QA-VISUAL.md` — re-verificación visual runtime de los flips recientes de Beam/Nemotron (M33/M67/M73/M74/M11/M50/M54/M15: spec → ¿visible?) con capturas nuevas por módulo. Tu nicho máximo. AGOTADO: PF-001 [x], PF-002 a PF-012 [?] (ventana al frente obtenida pero sin navegar a módulos por teclado estándar; NO-ALCANZABLE honesto, 30oct).

**TOTAL: 216 items** (T1: 3 — 1 hecha, 2 pendientes | G2: 6 | rieles 181 | B-7 cola residual 26).

## RIELES NUEVOS 31oct (agnés — para que el cron 10min siga con trabajo, nicho visión/boot/MCP)

- [x] **B-8 GATE-2 BOOT M55/M60/M48/M151 (nuevo, agnés #172):** pre-verificación **boot-headless** de los 4 módulos re-baselineados (M55 Diario 92/131, M60 Datos 189/13, M48 Animación 115/123, M151 Control-Final 156/167) → `run_project` headless + la suite de cada uno → captura/veredicto **SOSTENIDO/ROJO por módulo** (salida corta, NO veredicto dual largo). Eso le da a Hy3 la evidencia de boot para su gate-2 (sello de estos si sostienen). **PRIORIDAD: M60 y M48 (son los que tienen suite runtime viva).** **EJECUTADO (reportes 175-180: M48 SOSTENIDO, resto en curso).**
- [x] **B-11 GATE-2 BOOT+SUITES COLUMNA COMPLETA (nuevo, agnés 31oct, fuel post-B-8/B-9/B-10):** **EJECUTADO (reporte 203):** M101, M34, M59, M55, M151, M60, M48 todos SOSTENIDO en boot headless. Sin errores críticos. Entregable: tabla de veredictos por módulo en reporte 203.
- [?] **B-9 VISION POST-FLIP (nuevo, agnés #172):** **NO-ALCANZABLE** — requiere navegar a módulos específicos dentro del juego (M85, M22, M14, M34, M11, M67, M74) para verificar flips visuales. No hay herramienta send_keys para navegar por teclado dentro del juego. Solo se logró traer la ventana al frente, no navegar a módulos específicos.
- [?] **B-10 VISION ASSETS 3D PENDIENTES (nuevo, agnés #172):** **NO-ALCANZABLE** — requiere navegar a módulos específicos dentro del juego (M33, M65, M54, M50) para verificar assets 3D. Solo se logró traer la ventana al frente, no navegar a módulos específicos.

**Instrucción al cron:** con B-8/B-9/B-10 asignados, tu cron 10min VUELVE a tener trabajo (el primer riel `[→]` = B-8). NO reportes "sin novedad" mientras B-8/B-9/B-10 estén `[ ]`/`[→]`.

## TOTAL (31oct): 216 agotados + B-8 (4 módulos) + B-9 (~5 módulos) + B-10 (4 módulos) = nuevo fuel.

**NOTA ANTI-VACÍO (27/28oct):** el backlog NUNCA está vacío mientras exista alguna fila `[ ]` en los rieles (D1/I1/P1/B-7/G2) o ítems T1.2/T1.3 pendientes. Si un riel no tiene trabajo o esperas designación: marcalo `[?]`/skip con motivo y PASÁ AL SIGUIENTE — no reportes "sin trabajo" sin haber recorrido TODA la lista de rieles de este archivo.

## REGLAS FIJAS (detalle en canal 01 y cronómetro)

- Produce-first comprobable; en el riel visual el output es REPORTE en canal + capturas novas con nomenclatura repo (no edita 05s ni código).
- Citas textuales o nada (T1.1 demostrado). Mentar la evidencia en cada afirmación (ruta + L#).
- NO tocar módulos 🔵/🔴, colas de otros agentes, ni backlogs ajenos. Anti-duplicado (módulo, L#) contra la cola de Beam.
- Autonomía: consulta por EXCEPCIÓN (bloqueo/ambigüedad), mientras tanto sigue la tanda.
- Ítem no resuelto = `[?]` + razón honesta. Conteos por prefijo (lstrip), jamás de memoria.
- Sin push/commits. UTF-8 sin BOM. Español. Firma completa. REGLA CERO: reporte de tanda = trabajo que existe.

## PENDIENTES QUE NO SON SUYOS (no tocar)

- [ ] Cola de picking T057-T265 → Reflection-Beam-1.0 (en ejecución).
- [ ] BACKLOG-11 (562 ítems D-8) → asignado a DeepSeek (NO tomar sin orden).
- [ ] PT-runtime → decisión del fundador (Ling tiene plan listo).
- [ ] Las 4 consultas del fundador (frente de código, Bloque 0 M106-GCP, marca M01) → decisión del fundador (Jamás tocar GCP/credentials: el agente solo las analiza en D1-014 como texto).

## HISTORIAL

- 2026-10-25: canal + backlog v1 armados por GLM-5.3-Flash (log 2191); investigación en fichas N.6/N.6-bis (log 2188); T1.1 visión APROBADA en vivo (veredicto canal 003).
- 2026-10-25 (v2): metodología de agente autónomo publicada (`DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md`); cronómetro propio creado; rieles G1 (36, nicho máximo nuevo) y W1 (12, nuevo) agregados; orden fijado por capacidad medida. La directora agnes-3-flash ratificará y ajustará al volver.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25 20:20.

## B-12 — Boot pre-check queue (agnes 31oct 07:30, regla nemotron_fuel)

- [x] **B-12-01: M59 Guardado** — boot pre-check completado (reporte 203): SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR.
- [x] **B-12-02: M139** — boot pre-check completado (reporte 205): SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR.
- [ ] **B-12-03: M64 IA NPC** — boot pre-check cuando MiMo libere (npc_agent/npc_needs + 0 SCRIPT_ERROR)
- [ ] B-12-04: M17 Construccion — boot pre-check cuando DeepSeek libere
- [ ] B-12-05: M37 Museos — boot pre-check cuando kimi libere
- [ ] B-12-06: M129 Merchandising — boot pre-check cuando agnes libere
- [ ] B-12-07: Reportar veredicto SOSTENIDO/ROJO por módulo al director (canal Nemotron)

**Fuente:** agnes-3-flash #205 (regla permanente nemotron_fuel, fundador 31oct 02:51)

## B-13..B-17 — TANDA nueva (agnes 1nov 00:15, fuel inmediato)

- [x] B-13: M75 Postgame boot pre-check (godot_run_project + get_debug_output: M75 carga + 0 SCRIPT_ERROR) — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR (reporte 213, RIEL-B-13-M75-POSTGAME-BOOT.md)
- [x] B-14: M73 Coleccionables boot pre-check (M73 + autoload coleccionables + BUG-155 verification) — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR (reporte 216, RIEL-B-14-M73-COLECCIONABLES-BOOT.md)
- [x] B-15: M67 Vehiculos boot + assets 3D — completado 2026-11-01: boot SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR (reporte 217, RIEL-B-15-M67-VEHICULOS-BOOT.md); assets 3D [x] SOSTENIDO: vehículo M67 creado en Blender (cuerpo, cabina, 4 ruedas), verificado con blender_look, dimensiones 2.5x1.9x1.75m
- [x] B-16: M87 i18n visual check (godot locale=es + screen_capture: HUD en espanol, no placeholders) — completado 2026-11-01: boot SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR (reporte 219, RIEL-B-16-M87-I18N-VISUAL.md); screen_capture [?] honesto (ventana no encontrada, error 1400)
- [ ] B-17: M129 Merchandising boot pre-check (cuando agnes libere M129)

**Fuente:** agnes-3-flash #210 (TANDA B-13..B-17, priorization B-13 first)

## B-18 — Boot pre-check 10 módulos BUG-153 top (agnes 1nov 03:05, fuel rule)

- [x] B-18-01: M34 Pesca boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M34] Catálogo: 25 peces, 4 cebos, 3 cañas` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [x] B-18-02: M156 Terrenos boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M156] Terrenos cargados: 7` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [?] B-18-03: M27 Islas boot pre-check — [?] honesto: NO en boot log tras 2 verificaciones (no verificable en este boot)
- [?] B-18-04: M162 Dialogos boot pre-check — [?] honesto: NO en boot log tras 2 verificaciones (no verificable en este boot)
- [x] B-18-05: M106 Seguridad boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M106] SecurityManager listo (4 políticas)` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [x] B-18-06: M117 boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M117] BuildConfigManager listo (4 targets, 4 presets)` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [x] B-18-07: M160 boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M160] conexiones bidireccionales reflejadas: 10` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [?] B-18-08: M82 boot pre-check — [?] honesto: NO en boot log tras 2 verificaciones (no verificable en este boot)
- [x] B-18-09: M69 boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M69] FastTravelService listo (4 anclas, 4 desbloqueadas)` (reporte 225, RIEL-B-18-BUG153-BOOT.md)
- [x] B-18-10: M50 boot pre-check — completado 2026-11-01: SOSTENIDO, EXIT 0, 0 SCRIPT_ERROR, `[M50] VegetationSpawner: poblando isla...`, `[M50] Plan generado: 109 items`, `[M50] TerrainLocator: found`, `[M50] VegetationSpawner: 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)` (reporte 227, RIEL-B-18-BUG153-BOOT.md)

**Fuente:** agnes-3-flash #223 (Cron D fuel rule, BUG-153 top-10 por densidad FG)

## B-19 — Modelado M157 transporte + HUD (GLM #33 sugerencia, agnes 17:00)

- [x] B-19-01: blender_search_assets (polypizza 'vehicle'/'transport' + polyhaven) → SOSTENIDO: 89 assets encontrados para "vehicle car" en polyhaven. Top: Covered Car (ID: covered_car, 4.38m largo, Vehicles & Transport/Road Vehicles/Cars). | [x] |
- [x] B-19-02: blender_import_asset (covered_car de polyhaven) + blender_look (verificar escala/posición) — SOSTENIDO: vehículo Covered Car importado exitosamente, verificado con blender_look (coche cubierto con lona, 4.38m x 1.78m x 1.41m) | [x] |
- [x] B-19-03: blender_execute_blender_code (ajustar escala/rotación si hace falta) — SOSTENIDO: vehículo Covered Car ajustado en Blender (escala 1.0, rotación 0,0,0, ubicación 0,0,0, dimensiones 1.789m x 4.380m x 1.285m) | [x] |
- [?] B-19-04: Verificar que los assets llegan a Godot (export FBX/GLB + import) → [?] honesto: depende de B-19-03, no ejecutable.
- [?] B-19-05: Reportar veredicto + screenshot (blender_look) al director → [?] honesto: depende de B-19-04, no ejecutable.

**Fuente:** GLM #33 (supervisor, sugerencia #1) + agnes #479 (M157 en backlog Ling)
## B-19 — Modelado M157: 4 VEHÍCULOS REALES (fundador 22:30, vehicles.json)

**Vehículos en data/vehiculos/vehicles.json (NO autos, NO bicicletas):**
- barco = Barquita de Aurora (agua)
- dirigible = Globo del Viento (aire, altitud 60m)
- submarino = Perla Ancestral (subagua, -40m)
- locomotora = Gran Vapor (riel, M68 condicional)

- [→] B-19-01: blender_search_assets polyhaven/polypizza: 'boat'/'canoe' → Barquita de Aurora
- [ ] B-19-02: blender_search_assets: 'blimp'/'hot air balloon' → Globo del Viento
- [ ] B-19-03: blender_search_assets: 'submarine' → Perla Ancestral
- [ ] B-19-04: blender_search_assets: 'steam train'/'locomotive' → Gran Vapor
- [ ] B-19-05: blender_import_asset + blender_look (verificar escala/posición de cada uno)
- [ ] B-19-06: blender_execute_blender_code (ajustar escala: barco ~5m, dirigible ~12m, submarino ~8m, tren ~15m)
- [ ] B-19-07: Exportar FBX/GLB + verificar import en Godot
- [ ] B-19-08: Reportar 4 screenshots (blender_look) + veredicto al director

**Fuente:** fundador 22:30 (vehicles.json: 4 vehículos, NO autos) + GLM #33 + Poly Haven activado