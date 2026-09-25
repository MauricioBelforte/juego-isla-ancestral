# Log 1163: P-48 — reclasificación del merge por autoría REAL (buckets B / C / scratch / otros)

**Fecha:** 2026-09-25
**Hora:** 05:34
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** el pool dio **primero=1163** justo antes de reservar (el encargo decía 1160; 1160/1161/1162
los consumieron otros entre el encargo y mi turno). Al cerrar, el pool arranca en **1164**. 0 conflictos.

## Resumen

Encargo (P-48, **solo reporte**): aplicar mi método de atribución (autoría por las **líneas AÑADIDAS**
del diff, nunca por el header del archivo) a **todos** los archivos sucios + untracked y entregar:
**(a)** mi bucket B final (lo del coordinador), **(b)** bucket C (conflicto real), **(c)** scratch a
descartar, **(d)** buckets de otros modelos. Reglas: **no commitear nada más que mis logs/backlog**;
si un archivo "mío" tiene hunks ajenos mezclados → **C, no B**; Push NEGATIVO.

**Universo medido:** `git status --porcelain` = **429** entradas (**M 155 · D 34 · ?? 240**).
Se clasificaron las **429**; **0 sin resolver**.

## Resultado — tabla de buckets

| Bucket | N | Confianza |
|---|---:|---|
| B | 149 | {'MEDIDO': 137, 'DEBIL': 1, 'CARPETA': 10, 'CABECERA': 1} |
| SCRATCH | 134 | {'MEDIDO': 132, 'CABECERA': 2} |
| OTRO:mimo | 37 | {'MEDIDO': 18, 'DEBIL': 15, 'CARPETA': 2, 'CABECERA': 2} |
| BORRADO | 34 | {'MEDIDO': 34} |
| OTRO:agnes | 27 | {'MEDIDO': 16, 'CABECERA': 2, 'DEBIL': 3, 'CARPETA': 6} |
| OTRO:glm-5.3 | 13 | {'CABECERA': 2, 'MEDIDO': 7, 'DEBIL': 3, 'CARPETA': 1} |
| C | 11 | {'MEDIDO': 11} |
| AMBIGUO | 5 | {'AMBIGUO': 5} |
| OTRO:hy4 | 5 | {'CABECERA': 5} |
| OTRO:nex | 5 | {'CARPETA': 1, 'MEDIDO': 4} |
| EOL | 3 | {'EOL': 3} |
| OTRO:deepseek-v4-flash* | 3 | {'MEDIDO': 1, 'CARPETA': 2} |
| OTRO:gemini | 1 | {'CARPETA': 1} |
| OTRO:step-3.7 | 1 | {'CARPETA': 1} |
| OTRO:deepseek-v4.1-flash | 1 | {'DEBIL': 1} |

> Confianza: **MEDIDO** = firma en las líneas añadidas (o en el archivo si es untracked);
> **CARPETA** = carpeta dueño `TAREAS-POR-MODELO/<dueño>/`; **CABECERA** = `**Modelo:**`/`# Modelo:` del
> propio archivo (último autor commiteado → *probable*, no medido); **DEBIL** = módulo→agente del mapa;
> **AMBIGUO** = evidencia contradictoria; **EOL** = solo fin de línea.

## Método (iterado v1→v6, cada refinamiento nace de un falso positivo MEDIDO)

1. **v1** (heredado de P-45): autoría por marcadores en líneas añadidas. Falso positivo: la regex
   `**Modelo:**` matcheaba una **mención entre backticks** (`\`**Modelo:** kimi-k3\`` dentro de un log) →
   atribuía al que se *cita*. **Fix:** anclar la cabecera a **inicio de línea** (`^`).
2. **v2/v3**: + `TAREAS-POR-MODELO/<dueño>/` como señal **estructural** (el dueño declara su carpeta).
3. **v4**: + `# Modelo:` (comentario GDScript/Python), `(BUG-N, modelo)`, `(AAAA-MM-DD, modelo)`,
   `M<n> iter. modelo`, `Helper temporal (modelo)`, `Iteración <modelo>`.
4. **v5**: los **logs** son artefactos de **UN** autor → manda su **primera** cabecera; las menciones
   a otros modelos **no** crean conflicto. Y `**Totales:**` **solo** = ruido (cualquiera pone totales);
   la firma de drift **real** es la nota "auditoría de drift (X / …)".
5. **v6 (final)**: `**Totales:**` vuelve a contar como **drift 1B/1C de atria** (confirmado por el
   coordinador: M26 es suyo y M26 **solo** tiene el cambio `**Total:**`→`**Totales:**`); +
   `BUG-N (modelo, fecha)` (forma `Fix BUG-051 (atria-dawn, …)`); + `verificado <fecha> por <modelo>`
   (con salto de línea `>` intermedio); + carpeta dueño con **prioridad** sobre menciones internas
   (una carpeta `atria-dawn-s2/` con un `.txt` que *lista* modelos sigue siendo de s2).

**Regla dura aplicada en todo momento (trampa 107/109):** la autoría se mide en las **líneas AÑADIDAS**
del diff, **nunca** en el header `**Modelo:**` del archivo (ese es el **último autor commiteado**, de
hace semanas). El header del archivo solo se usa como *probable* (conf. CABECERA).

## (a) Mi bucket B final — lo del coordinador (atria): **149**

Composición: **102** en `DOCUMENTACION/`, **39** logs `.md` untracked, **8** otros.
Núcleo = **drift 1B/1C** (`**Totales:**` recalculado + nota "auditoría de drift (atria-dawn-preview…)"),
**BUG-051** (fix de tests: `BUG-051 (atria-dawn, 2026-09-18)`), **BUG-061** (`objetivos.json`, M94),
**M26/M92** (checklists), el **colector** `_colector_sintaxis.gd` ("fix BUG-051, atria-dawn"), las
**auditorías** de `DOCUMENTACION/Auditorias/` (cabecera Atria-Dawn-Preview) y los **logs de drift**.

### B · logs untracked (39)

- `Logs/1034-INVESTIGACION-10-MODELOS-ALTA-NEX-ASIGNACION_2026-09-18_19-34-38.md`
- `Logs/1039-BUG-051-CI-GATE-DURO-AUDITORIA-M39-M15_2026-09-18_23-05-00.md`
- `Logs/1044-FIX-BOOT-GET2ARGS-RESOURCE_2026-09-19_00-30.md`
- `Logs/1047-QA-M14-Inventario_2026-09-18_10-05.md`
- `Logs/1048-RECONCILIACION-M126-M128-M149_2026-09-19_01-15-00.md`
- `Logs/1054-RONDA3-limpieza-locks-stale_2026-09-19_01-09-24.md`
- `Logs/1058-QA-21.8-lote-13-modulos_2026-09-19_02-29-24.md`
- `Logs/1059-Auditoria-Amarillos-Estancados_2026-09-19_02-57-05.md`
- `Logs/1063-AUDITORIA-AMARILLOS-ESTANCADOS_2026-09-19_06-20.md`
- `Logs/1065-BATERIA-M110-bloqueado-sobrecierre-drift_2026-09-19_04-20-47.md`
- `Logs/1070-ALTA-KIMI-K3-GUIA-MODELOS_2026-09-19_07-05.md`
- `Logs/1083-bug061-m94-json-esquema_2026-09-19_05-20-00.md`
- `Logs/1085-bug062-m84-test-parseo_2026-09-19_05-26-00.md`
- `Logs/1089-qa-m109-causas-bugs_2026-09-19_05-32-00.md`
- `Logs/1090-EVALUACION-EMPIRICA-MODELOS_2026-09-19_08-36.md`
- `Logs/1091-BATERIA-PROMPTS_2026-09-20_21-05.md`
- `Logs/1093-barrido-historico-doc-empirico_2026-09-20_21-45-00.md`
- `Logs/1098-drift-totales-lote1_2026-09-19_22-37-49.md`
- `Logs/1099-drift-totales-lote3_2026-09-19_22-46-41.md`
- `Logs/1101-COORD-nex-fuera-flujo-colision1095_2026-09-20_01-55-00.md`
- `Logs/1102-drift-totales-lote5_2026-09-19_22-56-33.md`
- `Logs/1103-drift-totales-lote2_2026-09-19_22-42-38.md`
- `Logs/1104-drift-totales-lote4_2026-09-19_22-50-33.md`
- `Logs/1105-drift-totales-bloque1b_2026-09-19_23-11-56.md`
- `Logs/1106-drift-totales-bloque1c_2026-09-19_23-17-51.md`
- `Logs/1107-drift-totales-lote6_2026-09-19_22-59-21.md`
- `Logs/1108-colision-1103-residual-sync-numeracion_2026-09-19_23-33-19.md`
- `Logs/1110-reversion-dod-m14-m29-m153_2026-09-20_00-10-28.md`
- `Logs/1113-COORD-review-ronda-nex-definitivo-agnes-pausa_2026-09-20_03-10-00.md`
- `Logs/1114-COORD-correccion-bug050-politica-overmarks_2026-09-20_04-10-00.md`
- `Logs/1116-overmarks-familia-a-reversion_2026-09-20_01-13-40.md`
- `Logs/1120-T-L11-correccion-atribucion-sellos_2026-09-20_02-05-34.md`
- `Logs/1121-COORD-repara-11bugs-verifica-m127_2026-09-20_05-00-00.md`
- `Logs/1122-familia-b-reparto-duenos_2026-09-20_02-16-59.md`
- `Logs/1135-P-23-CIERRE-SESION_2026-09-20_08-25-00.md`
- `Logs/1152-Soporte-Merge-QA_2026-09-25_01-12-00.md`
- `Logs/1155-P-40-M07-drift-T102_2026-09-25_03-34-00.md`
- `Logs/1158-P-44-Merge-Huerfanos_2026-09-25_04-34-00.md`
- `Logs/1162-P-46-Untracked_2026-09-25_05-21-00.md`

### B · documentación (102) y otros (8)
- `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/05-Checklist.md`
- `DOCUMENTACION/07-Arquitectura-General/plan-actual/04-Codigo.md`
- `DOCUMENTACION/07-Arquitectura-General/plan-actual/05-Checklist.md`
- `DOCUMENTACION/101-QA-General/plan-actual/05-Checklist.md`
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md`
- `DOCUMENTACION/108-Pipeline-De-Assets/plan-actual/05-Checklist.md`
- `DOCUMENTACION/109-Herramientas-Internas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/111-Codigo-De-Calidad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`
- `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md`
- `DOCUMENTACION/114-Playtest/plan-actual/05-Checklist.md`
- `DOCUMENTACION/115-Hardware/plan-actual/05-Checklist.md`
- `DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md`
- `DOCUMENTACION/123-Modding/plan-actual/05-Checklist.md`
- `DOCUMENTACION/124-Contenido-Generado-Por-Usuarios/plan-actual/05-Checklist.md`
- `DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md`
- `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md`
- `DOCUMENTACION/14-Inventario/plan-actual/05-Checklist.md`
- `DOCUMENTACION/140-Alpha/plan-actual/05-Checklist.md`
- `DOCUMENTACION/141-Beta/plan-actual/05-Checklist.md`
- `DOCUMENTACION/142-Release-Candidate/plan-actual/05-Checklist.md`
- `DOCUMENTACION/143-Lanzamiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/144-Despues-Del-Lanzamiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/147-World-Building/plan-actual/05-Checklist.md`
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/05-Checklist.md`
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/151-Control-Final/plan-actual/05-Checklist.md`
- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/16-Crafting/plan-actual/05-Checklist.md`
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md`
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/165-Voxel-Tools-Guia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/167-Isla-Raiz/plan-actual/05-Checklist.md`
- `DOCUMENTACION/168-Plantilla-De-Isla/plan-actual/05-Checklist.md`
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/22-Historia-Principal/plan-actual/05-Checklist.md`
- `DOCUMENTACION/23-Historias-Secundarias/plan-actual/05-Checklist.md`
- `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/05-Checklist.md`
- `DOCUMENTACION/25-Ruinas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/26-Templo-Subterraneo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/28-Viajes/plan-actual/05-Checklist.md`
- `DOCUMENTACION/33-Agricultura/plan-actual/05-Checklist.md`
- `DOCUMENTACION/35-Mineria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/36-Fauna/plan-actual/05-Checklist.md`
- `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md`
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/40-Infraestructura/plan-actual/05-Checklist.md`
- `DOCUMENTACION/45-Arte-3D/plan-actual/05-Checklist.md`
- `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/05-Checklist.md`
- `DOCUMENTACION/48-Animacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md`
- `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`
- `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/57-Interfaz-De-Control/plan-actual/05-Checklist.md`
- `DOCUMENTACION/58-Accesibilidad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md`
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/05-Checklist.md`
- `DOCUMENTACION/67-Vehiculos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/70-Interacciones/plan-actual/05-Checklist.md`
- `DOCUMENTACION/73-Coleccionables/plan-actual/05-Checklist.md`
- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md`
- `DOCUMENTACION/76-Multijugador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/77-Online-Y-Red/plan-actual/05-Checklist.md`
- `DOCUMENTACION/78-Legal-Propiedad-Intelectual/plan-actual/05-Checklist.md`
- `DOCUMENTACION/79-Legal-Contratos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/80-Legal-Privacidad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/82-Clasificacion-Por-Edades/plan-actual/05-Checklist.md`
- `DOCUMENTACION/86-IA-Generativa/plan-actual/05-Checklist.md`
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/05-Checklist.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/05-Checklist.md`
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md`
- `DOCUMENTACION/94-Retencion-Sin-FOMO/plan-actual/05-Checklist.md`
- `DOCUMENTACION/95-Monetizacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/96-Plataformas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/97-Steam-Store-Page/plan-actual/05-Checklist.md`
- `DOCUMENTACION/98-Trailer/plan-actual/05-Checklist.md`
- `DOCUMENTACION/99-Marketing/plan-actual/05-Checklist.md`
- `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/BACKLOG-MASTER.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn/BACKLOG-MASTER.md`
- `game/isla-ancestral/data/motivacion/objetivos.json`
- `game/isla-ancestral/scripts/coleccionables/collectible_category.gd`
- `game/isla-ancestral/tests/unit/interfaces/test_i_damageable.gd`
- `game/isla-ancestral/tests/unit/interfaces/test_i_interactable.gd`
- `game/isla-ancestral/tests/unit/interfaces/test_i_saveable.gd`
- `DOCUMENTACION/Auditorias/`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/clasificacion_final.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/clasificacion_preliminar.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/clasificacion_ronda2.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/compartidos_hunks.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/git_status_snapshot.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/modulo_agente_map.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/qa_documental.txt`
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn/prompts-2026-09-20/`
- `Mensajes entre modelos/2026-09-20_02-18-09_1-DEEPSEEK-BUG067-M103-logger-delegacion.md`
- `game/isla-ancestral/scripts/debug/test_m110_iter_atria.gd`
- `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd`

## (b) Bucket C — conflicto real (multi-autor / hunks mezclados): **11**

Los **4 compartidos** (los toca todo el mundo) + **7 checklists** donde conviven el drift de atria
y contenido/QA de otro modelo (agnes, mimo, glm, hy3). Por la regla del encargo → **C, no B**.

- `CHECKLIST-GLOBAL.md`
- `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/11-BUGS.md`
- `DOCUMENTACION/12-Camara/plan-actual/05-Checklist.md`
- `DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md`
- `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md`
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md`
- `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md`
- `Logs/NUMEROS_DISPONIBLES.txt`
- `Mensajes entre modelos/ESTADO-PARALELO.md`

## (c) Scratch a descartar: **134** (+ 34 borrados, ver abajo)

Patrones: `**/scripts-prueba/**`, `**/capturas/**`, `**/reservas/**`, `**/Obsoletos/**`, `**/PAPELERA/**`,
`Logs/_*` (incl. los 104 `.txt` untracked), `*.out`/`*.err`/`*.pyc`, `out/`,`tmp/`,`build/`,
`game/isla-ancestral/reports/`, `tools/probe_mesh_tmp.gd`.

## BORRADOS (D) en worktree: **34**

33 son **limpieza de scratch** (`Logs/_*.txt`, `Logs/_*.py`). **1 es renumeración**:
`Logs/1013-QA-M14-Inventario_2026-09-18_10-05.md` fue **renumerado a `Logs/1047-…`** (mismo título/fecha;
existe untracked). `Logs/reservas/1013-atria-dawn-M14-QA.txt` = reserva vieja consumida.

- `Logs/1013-QA-M14-Inventario_2026-09-18_10-05.md`
- `Logs/_bug028_map.txt`
- `Logs/_dec39.txt`
- `Logs/_diag39.txt`
- `Logs/_diag39_run.txt`
- `Logs/_diag39b.txt`
- `Logs/_estado_final39.txt`
- `Logs/_final39.txt`
- `Logs/_fix39.txt`
- `Logs/_ids39c.txt`
- `Logs/_ids39d.txt`
- `Logs/_ids39e.txt`
- `Logs/_idsA.txt`
- `Logs/_idsA2.txt`
- `Logs/_idsF.txt`
- `Logs/_idsFIX.txt`
- `Logs/_idsG.txt`
- `Logs/_idsH.txt`
- `Logs/_idsM.txt`
- `Logs/_idsX.txt`
- `Logs/_ids_final.txt`
- `Logs/_ids_m39_map.txt`
- `Logs/_m14_flip.py`
- `Logs/_m14_t1.txt`
- `Logs/_map39.txt`
- `Logs/_mapA.txt`
- `Logs/_map_ids.txt`
- `Logs/_mapa39.txt`
- `Logs/_mapa_ids.txt`
- `Logs/_rep.txt`
- `Logs/_rep_ids.txt`
- `Logs/_state39.txt`
- `Logs/_t39_loop_out.txt`
- `Logs/reservas/1013-atria-dawn-M14-QA.txt`

## (d) Buckets de otros modelos

### OTRO:mimo — 37
- `DOCUMENTACION/12-Camara/plan-actual/03-Diseno.md`
- `DOCUMENTACION/12-Camara/plan-actual/04-Codigo.md`
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/03-Diseno.md`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/04-Codigo.md`
- `game/isla-ancestral/data/audio/narrative_sound.json`  _(conf: DEBIL — modulo 84 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/backup/test_backup_m107.gd`
- `game/isla-ancestral/scripts/camera/camera_rig.gd`
- `game/isla-ancestral/scripts/camera/camera_spring.gd`
- `game/isla-ancestral/scripts/camera/simple_camera.gd`
- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/npc_manager.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/npc_needs.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/state_machine.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/legal/audio_legal_manager.gd`  _(conf: DEBIL — modulo 84 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/legal/test_audio_licenses_m84.gd`  _(conf: DEBIL — modulo 84 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/legal/test_credits_m131_v2.gd`  _(conf: DEBIL — modulo 131 -> mimo-v2.5)_
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.5/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `Logs/1040-M64-FSM-PlanStack-Watchdog-TestSuite_AAAA-MM-DD_HH-MM-SS.md`
- `Logs/1046-M64-TestSuites-Navegacion-Social-Rendimiento-Persistencia_2026-09-18_21-45.md`
- `Logs/1061-QA-Visual-Fauna-Hy4-Drift-M12_2026-09-19_03-05.md`
- `Logs/1068-M107-Backups-Implementacion-RF1-RF15_2026-09-19_06-45.md`
- `Logs/1078-M115-Reconciliacion-post-revert_2026-09-19_06-30.md`
- `Logs/1079-M12-Camara-FASE3-Cierre_2026-09-19_06-55.md`
- `Logs/1095-M150-iter2-M31-reconciliacion_2026-09-20_22-30-00.md`
- `Logs/1161-P43b-QA-cruzado-M106-M122_2026-09-25_05-09-00.md`
- `game/isla-ancestral/data/backup/backup_categories.json`  _(conf: CABECERA — M107 (hermano test_backup_m107.gd = mimo))_
- `game/isla-ancestral/data/ia/`  _(conf: CABECERA — M64 (mapa: mimo-v2.5))_
- `game/isla-ancestral/scenes/preview_antorcha_m25.tscn`  _(conf: DEBIL — modulo 25 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/npc_needs_config.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/npc_watchdog.gd`
- `game/isla-ancestral/scripts/ia_npc/plan_stack.gd`
- `game/isla-ancestral/scripts/ia_npc/test_ia_npc_m64_iterN.gd`
- `game/isla-ancestral/scripts/ia_npc/test_navegacion_m64.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/test_persistencia_m64.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/test_rendimiento_m64.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_
- `game/isla-ancestral/scripts/ia_npc/test_social_m64.gd`  _(conf: DEBIL — modulo 64 -> mimo-v2.5)_

### OTRO:agnes — 27
- `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/04-Codigo.md`
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/04-Codigo.md`
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/04-Codigo.md`
- `game/isla-ancestral/scripts/player/test_equipment_m155.gd`  _(conf: CABECERA — cabecera '# Modelo: agnes-2.5-flash')_
- `game/isla-ancestral/tests/integration/test_inventory_economy.gd`  _(conf: DEBIL — ref a log: agnes)_
- `game/isla-ancestral/tests/unit/inventario/test_contenedor_inventario.gd`  _(conf: DEBIL — ref a log: agnes)_
- `game/isla-ancestral/tests/unit/inventario/test_inventory_slot.gd`  _(conf: DEBIL — ref a log: agnes)_
- `game/isla-ancestral/tests/unit/player/test_equipment_manager.gd`  _(conf: CABECERA — M155 (hermano test_equipment_m155.gd = agnes))_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-2.5-flash/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/126-Marketing-Legal/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/128-Identidad-De-Marca/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/66-Anti-Softlock/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/72-Sistema-De-Logros/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/83-Licencias-De-Software/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `Logs/1035-M166-M09-AUDITORIA-COPYRIGHT-GLB-Y-QA-VISUAL_2026-09-18_20-37-00.md`
- `Logs/1049-M19-V3-AntorchaPared-Fix-E80_2026-09-19_03-19-00.md`
- `Logs/1050-M31-QA-VISUAL-K2_2026-09-19_03-19-00.md`
- `Logs/1051-M51-TRIAGE-V6-V7-DUPLICADOS_2026-09-19_03-19-00.md`
- `Logs/1052-M52-QA-VISUAL-CALIBRACION_2026-09-19_03-19-00.md`
- `Logs/1115-QA-VISUAL-M09-IMPOSTOR_2026-09-20_01-10-00.md`
- `Logs/1127-QA-M14-Inventario-P18_2026-09-20_06-25-00.md`
- `game/isla-ancestral/scripts/particles/preview_vfx_m52.gd`
- `game/isla-ancestral/scripts/ruinas/colocar_props_m25.gd`
- `game/isla-ancestral/scripts/ruinas/preview_antorcha_m25.gd`
- `game/isla-ancestral/scripts/ruinas/test_colocar_props_m25.gd`
- `scripts/auditar_copyright_glb.py`

### OTRO:glm-5.3 — 13
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/quick-reference.md`  _(conf: CABECERA — cabecera '**Modelo:** GLM')_
- `DOCUMENTACION/39-Tiendas/plan-actual/04-Codigo.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/03-Diseno.md`  _(conf: DEBIL — modulo 92 -> glm-5.3-flash)_
- `DOCUMENTACION/92-Tutorial/plan-actual/04-Codigo.md`
- `game/isla-ancestral/scripts/economia/price_manager.gd`
- `game/isla-ancestral/scripts/time/game_clock.gd`  _(conf: DEBIL — modulo 31 -> GLM-5.3 Flash)_
- `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd`  _(conf: DEBIL — modulo 92 -> glm-5.3-flash)_
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `game/isla-ancestral/scripts/shops/test_tiendas_iter_glm.gd`
- `game/isla-ancestral/scripts/tutorial/test_tutorial_iter4.gd`
- `scripts/reporte_ids_items.py`  _(conf: CABECERA — M39/M149 tool (glm); BUG-028)_
- `scripts/run_diag39.bat`
- `scripts/run_shops_tests.bat`

### OTRO:hy4 — 5
- `game/isla-ancestral/data/villagers/bruno_sapo.tres`  _(conf: CABECERA — M19 NPCs (Hy4))_
- `game/isla-ancestral/data/villagers/finneas_zorro.tres`  _(conf: CABECERA — M19 NPCs (Hy4))_
- `game/isla-ancestral/data/villagers/luna_zorra.tres`  _(conf: CABECERA — M19 NPCs (Hy4))_
- `game/isla-ancestral/data/villagers/mateo_mapache.tres`  _(conf: CABECERA — M19 NPCs (Hy4))_
- `game/isla-ancestral/data/villagers/mercedes_lince.tres`  _(conf: CABECERA — M19 NPCs (Hy4))_

### OTRO:nex — 5
- `DOCUMENTACION/TAREAS-POR-MODELO/nex-n2.5-pro/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `Logs/1055-M11-PLAYER-SUITE-HEADLESS-V1-GATE-CI_2026-09-19_01-11-36.md`
- `Logs/1062-M11-T010-INYECCION-ERROR-GATE-CI_2026-09-19_03-22-55.md`
- `Logs/1064-M11-AUDITORIA-B-H-73-CUESTIONES-DOCUMENTADAS_2026-09-19_03-28-03.md`
- `Logs/1069-M11-SUITE-HEADLESS-VALIDACION-FINAL_2026-09-19_04-22-38.md`

### OTRO:deepseek-v4-flash* — 3
- `game/isla-ancestral/scripts/audio/narrative_sound.gd`
- `DOCUMENTACION/TAREAS-POR-MODELO/deepseek-v4-flash-vision-exp/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_
- `DOCUMENTACION/TAREAS-POR-MODELO/deepseek-v4-flash/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_

### OTRO:gemini — 1
- `DOCUMENTACION/TAREAS-POR-MODELO/gemini-3.8-flash/106-Seguridad/`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_

### OTRO:step-3.7 — 1
- `DOCUMENTACION/TAREAS-POR-MODELO/step-3.7-flash/FAMILIA-B-REPLANIFICACION.md`  _(conf: CARPETA — carpeta dueño TAREAS-POR-MODELO)_

### OTRO:deepseek-v4.1-flash — 1
- `game/isla-ancestral/scenes/preview_vfx_m52.tscn`  _(conf: DEBIL — modulo 52 -> DeepSeek-V4.1-Flash)_

## Ambiguos y EOL (revisar a mano)

### AMBIGUO — 5
- `.gitignore`  _(conf: AMBIGUO — M106 T-007 (kimi-k3 o DeepSeek-V4.1-Flash))_
- `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`  _(conf: AMBIGUO — cabecera DeepSeek-V4.1-Flash; diff agrega filas de asignacion)_
- `game/isla-ancestral/scripts/economia/economy_manager.gd`  _(conf: AMBIGUO — cabecera ox-alpha; cambio M39 parece glm)_
- `scripts/auditar_flotacion_glb.py`  _(conf: AMBIGUO — QA flotacion M166 (dominio M166, dueño por confirmar))_
- `tools/legal/flotacion_glb.json`  _(conf: AMBIGUO — salida QA flotacion M166 (dueño por confirmar))_

### EOL — 3 (solo fin de línea, sin contenido)
- `DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md`
- `Logs/_d39.txt`
- `Logs/_estado39.txt`

## Límites del método (honestidad de medición)

- La confianza **MEDIDO** solo es posible si el cambio **dejó firma en la línea añadida**. Un cambio
  limpio (solo datos, sin comentario) no deja firma → cae a **CARPETA/DEBIL/AMBIGUO**.
- **CARPETA** asume que la carpeta del modelo es suya; es fuerte pero no infalible (otro pudo escribir ahí).
- **CABECERA** es el punto débil declarado: el header del archivo es el **último autor commiteado**, no el
  autor del cambio. Los 5 **AMBIGUO** son justo esos casos (`.gitignore` M106, `economy_manager.gd`
  ox-alpha-vs-glm, `GUIA-METODOLOGIA.md`, la QA de flotación M166). **Recomiendo que el dueño confirme.**
- Los `**Totales:**` como firma de atria dependen de que el drift 1B/1C sea suyo (lo confirmó el
  coordinador para M26). Si algún `**Totales:**` fuera de otro autor, el archivo pasaría a **C** — no a B.

## Qué NO hice (por regla del encargo)

- **No commiteé ningún archivo de los buckets.** P-48 es **solo reporte**. Lo único que commiteo en esta
  tarea es **este log (1163)** y mi **BACKLOG-MASTER.md**.
- **Push NEGATIVO** (no empujé nada).
- No toqué `CHECKLIST-GLOBAL.md`, el pool ni `ESTADO-PARALELO.md` (quedan en worktree, los commitea el
  coordinador).

## Datos crudos

- `.workbuddy-ai/tmp/p48/buckets_final.json` — los 429 con bucket + confianza + evidencia.
- `.workbuddy-ai/tmp/p48/audit_v6.py` — el clasificador final (reproducible).
- `.workbuddy-ai/tmp/p48/log_autores.json` — mapa log→autor (1110 logs).

**Fin del reporte.**