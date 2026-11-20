# Backlog 34 — P-04 Segunda pasada logs e i18n (índice cruzado)

**Agente:** hy4-flash  
**Origen:** director 068 (P-04 aprobada, "cuando quieras")  
**Fecha:** 2026-11-19  
**Estado:** CERRADO — diagnóstico; sin borrados, sin ediciones ajenas

## Método

- Universo i18n: 276 msgid de `game/isla-ancestral/locales/es.po` (excluida cabecera).
- Índice cruzado: 7.129 archivos bajo `game/isla-ancestral/` y `DOCUMENTACION/`
  (`.gd`, `.tscn`, `.tres`, `.json`, `.cfg`, `.txt`, `.csv`, `.xml`, `.po`, `.md`;
  excluidos `.godot/` y el propio `es.po`).
- **Corrección metodológica clave:** los `msgid` que aparecen solo en `locales/en.po`
  o `data/localizacion/strings_en.json` NO son uso: son otro catálogo. Se excluyeron
  como evidencia de uso y se clasifican `SOLO_CATALOGO`.
- Universo logs: 2.345 `Logs/*.md`; se reprodujeron las regex exactas de la pasada 28
  (`Modelo:`, `Plataforma:`, `Fecha: AAAA-MM-DD`, fecha válida, primeros 6000 bytes).
- Segunda capa: búsqueda tolerante de la misma información con otros rótulos
  (`Agente / Modelo:`, `Firmado por:`, mención de WorkBuddy/Kilo Code, fecha en el texto).

## i18n — resultado

| Clase (sobre los 70 huérfanos viejos) | Cantidad |
|---|---:|
| Con evidencia fuera de `scripts/` (40 confirmados + 29 dinámicos) | 69 |
| └ `USADO_DATOS` (JSON/recursos de datos) | 30 |
| └ `USADO_ESCENA` (`.tres`) | 10 |
| └ `DINAMICO_POSIBLE` (prefijo en scripts, requiere revisión) | 29 |
| `SOLO_CATALOGO` (solo en otro `.po`) | 1 |
| `ORPHAN_REAL` (sin rastro en ningún corpus) | 0 |

**Falsos positivos confirmados por índice cruzado: 40** (30 datos + 10 escenas).
**Candidatos a falso positivo por construcción dinámica: 29** (prefijos `MAIN_MENU.`,
`SETTINGS.`, etc.; no se cuentan como recuperados confirmados).

### Lista por área — recuperados confirmados

**M68** (40)
- `M68.ROUTE.r_aurora_brisa` → `game/isla-ancestral/data/transporte/m68_catalogo.json:23` (USADO_DATOS)
- `M68.ROUTE.r_aurora_espejo` → `game/isla-ancestral/data/transporte/m68_catalogo.json:24` (USADO_DATOS)
- `M68.ROUTE.r_aurora_estacion` → `game/isla-ancestral/data/transporte/m68_catalogo.json:25` (USADO_DATOS)
- `M68.ROUTE.r_aurora_este` → `game/isla-ancestral/data/transporte/m68_catalogo.json:26` (USADO_DATOS)
- `M68.ROUTE.r_aurora_muelle` → `game/isla-ancestral/data/transporte/m68_catalogo.json:27` (USADO_DATOS)
- `M68.ROUTE.r_aurora_plataforma` → `game/isla-ancestral/data/transporte/m68_catalogo.json:28` (USADO_DATOS)
- `M68.ROUTE.r_aurora_sur` → `game/isla-ancestral/data/transporte/m68_catalogo.json:29` (USADO_DATOS)
- `M68.ROUTE.r_estacion_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:30` (USADO_DATOS)
- `M68.ROUTE.r_este_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:31` (USADO_DATOS)
- `M68.ROUTE.r_este_muelle` → `game/isla-ancestral/data/transporte/m68_catalogo.json:32` (USADO_DATOS)
- `M68.ROUTE.r_festival_muelle` → `game/isla-ancestral/data/transporte/m68_catalogo.json:33` (USADO_DATOS)
- `M68.ROUTE.r_muelle_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:34` (USADO_DATOS)
- `M68.ROUTE.r_muelle_este` → `game/isla-ancestral/data/transporte/m68_catalogo.json:35` (USADO_DATOS)
- `M68.ROUTE.r_muelle_festival` → `game/isla-ancestral/data/transporte/m68_catalogo.json:36` (USADO_DATOS)
- `M68.ROUTE.r_muelle_sur` → `game/isla-ancestral/data/transporte/m68_catalogo.json:37` (USADO_DATOS)
- `M68.ROUTE.r_norte_plataforma` → `game/isla-ancestral/data/transporte/m68_catalogo.json:38` (USADO_DATOS)
- `M68.ROUTE.r_plataforma_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:39` (USADO_DATOS)
- `M68.ROUTE.r_plataforma_norte` → `game/isla-ancestral/data/transporte/m68_catalogo.json:40` (USADO_DATOS)
- `M68.ROUTE.r_sur_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:41` (USADO_DATOS)
- `M68.ROUTE.r_sur_muelle` → `game/isla-ancestral/data/transporte/m68_catalogo.json:42` (USADO_DATOS)
- `M68.SIGN.estacion_central` → `game/isla-ancestral/data/transporte/m68_catalogo.json:44` (USADO_DATOS)
- `M68.SIGN.muelle_raiz_sur` → `game/isla-ancestral/data/transporte/m68_catalogo.json:45` (USADO_DATOS)
- `M68.SIGN.plataforma_norte` → `game/isla-ancestral/data/transporte/m68_catalogo.json:46` (USADO_DATOS)
- `M68.SIGN.puerto_aurora` → `game/isla-ancestral/data/transporte/m68_catalogo.json:47` (USADO_DATOS)
- `M68.SIGN.puerto_brisa` → `game/isla-ancestral/data/transporte/m68_catalogo.json:48` (USADO_DATOS)
- `M68.SIGN.puerto_espejo` → `game/isla-ancestral/data/transporte/m68_catalogo.json:49` (USADO_DATOS)
- `M68.SIGN.puerto_este` → `game/isla-ancestral/data/transporte/m68_catalogo.json:50` (USADO_DATOS)
- `M68.SIGN.puerto_festival` → `game/isla-ancestral/data/transporte/m68_catalogo.json:51` (USADO_DATOS)
- `M68.SIGN.puerto_norte` → `game/isla-ancestral/data/transporte/m68_catalogo.json:52` (USADO_DATOS)
- `M68.SIGN.puerto_sur` → `game/isla-ancestral/data/transporte/m68_catalogo.json:53` (USADO_DATOS)
- `M68.STOP.estacion_central` → `game/isla-ancestral/data/transporte/transport_network.tres:212` (USADO_ESCENA)
- `M68.STOP.muelle_raiz_sur` → `game/isla-ancestral/data/transporte/transport_network.tres:190` (USADO_ESCENA)
- `M68.STOP.plataforma_norte` → `game/isla-ancestral/data/transporte/transport_network.tres:200` (USADO_ESCENA)
- `M68.STOP.puerto_aurora` → `game/isla-ancestral/data/transporte/transport_network.tres:182` (USADO_ESCENA)
- `M68.STOP.puerto_brisa` → `game/isla-ancestral/data/transporte/transport_network.tres:256` (USADO_ESCENA)
- `M68.STOP.puerto_espejo` → `game/isla-ancestral/data/transporte/transport_network.tres:269` (USADO_ESCENA)
- `M68.STOP.puerto_este` → `game/isla-ancestral/data/transporte/transport_network.tres:234` (USADO_ESCENA)
- `M68.STOP.puerto_festival` → `game/isla-ancestral/data/transporte/transport_network.tres:280` (USADO_ESCENA)
- `M68.STOP.puerto_norte` → `game/isla-ancestral/data/transporte/transport_network.tres:245` (USADO_ESCENA)
- `M68.STOP.puerto_sur` → `game/isla-ancestral/data/transporte/transport_network.tres:223` (USADO_ESCENA)

### Candidatos dinámicos (prefijo encontrado en scripts, clave exacta no)

- `MAIN_MENU.OPTIONS` → prefijo en `game/isla-ancestral/scripts/dialogos/test_localizacion_dialogos.gd:71`
- `ITEMS.MADERA` → prefijo en `game/isla-ancestral/scripts/localization/localization_manager.gd:157`
- `ITEMS.MADERA_DESC` → prefijo en `game/isla-ancestral/scripts/localization/localization_manager.gd:157`
- `SETTINGS.SAVE_CORRUPTO` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.SAVE_RECUPERADO` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.SAVE_DISCO_LLENO` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.HORAS_H` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.HORAS_1` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.MIN_M` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.MIN_1` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.ULTIMO_GUARDADO` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `SETTINGS.SIN_GUARDADO_PREVIO` → prefijo en `game/isla-ancestral/scripts/crafting/crafting_ui.gd:124`
- `CLOCK.ESTACIONES.1` → prefijo en `game/isla-ancestral/scripts/clock/debug_po.gd:14`
- `CLOCK.ESTACIONES.2` → prefijo en `game/isla-ancestral/scripts/clock/debug_po.gd:14`
- `CLOCK.ESTACIONES.3` → prefijo en `game/isla-ancestral/scripts/clock/debug_po.gd:14`
- `DIARY.ENTRADAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_PERSONAJES` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_CRIATURAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_PLANTAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_MINERALES` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_RECETAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_PISTAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_SELLOS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_RUINAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_CARTAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_DESCUBRIMIENTOS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_MISIONES` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_EVENTOS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`
- `DIARY.CAT_FOTOGRAFIAS` → prefijo en `game/isla-ancestral/scripts/diario/secciones_lore.gd:28`

### No recuperados

- `DIALOGOS.VECINO_SALUDO` → SOLO_CATALOGO; catálogo `game/isla-ancestral/locales/en.po:32`; doc `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/00-Backlog-Original-PreSplit.md:199`

## Logs — resultado

| Métrica | Cantidad |
|---|---:|
| Logs totales | 2345 |
| Con campo faltante según pasada 28 (reproducido) | 453 |
| Falsos positivos de formato (información presente con otro rótulo) | 370 |
| Con laguna real (falta información incluso en búsqueda tolerante) | 83 |

### Falsos positivos de formato — por dueño inferido del nombre

**deepseek** (1)
- `952-DeepSeek-Auditoria-Referencias-Logs-Preservacion-Huerfanos_2026-09-17.md` — Modelo≈`DeepSeek` @ Logs/952-DeepSeek-Auditoria-Referencias-Logs-Preservacion-Huerfanos_2026-09-17.md:1; Plataforma≈`WorkBuddy` @ Logs/952-DeepSeek-Auditoria-Referencias-Logs-Preservacion-Huerfanos_2026-09-17.md:1

**hy3** (84)
- `1038-hy3-REAFIRMACION-QA-M46-M117-M126-M128.md` — Plataforma≈`WorkBuddy` @ Logs/1038-hy3-REAFIRMACION-QA-M46-M117-M126-M128.md:4
- `1056-hy3-QA-CRUZADO-M153-OBJETIVO-FINAL.md` — Modelo≈`hy3` @ Logs/1056-hy3-QA-CRUZADO-M153-OBJETIVO-FINAL.md:1; Plataforma≈`WorkBuddy` @ Logs/1056-hy3-QA-CRUZADO-M153-OBJETIVO-FINAL.md:3
- `1057-hy3-QA-CRUZADO-M64-IA-NPC.md` — Modelo≈`hy3` @ Logs/1057-hy3-QA-CRUZADO-M64-IA-NPC.md:1; Plataforma≈`WorkBuddy` @ Logs/1057-hy3-QA-CRUZADO-M64-IA-NPC.md:3
- `1071-hy3-M116-QA_2026-09-19_04-50-00.md` — Modelo≈`hy3` @ Logs/1071-hy3-M116-QA_2026-09-19_04-50-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1071-hy3-M116-QA_2026-09-19_04-50-00.md:1
- `1072-hy3-M118-QA_2026-09-19_04-50-00.md` — Modelo≈`hy3` @ Logs/1072-hy3-M118-QA_2026-09-19_04-50-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1072-hy3-M118-QA_2026-09-19_04-50-00.md:1
- `1073-hy3-M13-QA_2026-09-19_04-50-00.md` — Modelo≈`hy3` @ Logs/1073-hy3-M13-QA_2026-09-19_04-50-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1073-hy3-M13-QA_2026-09-19_04-50-00.md:1
- `1075-hy3-M109-TRAZABILIDAD_2026-09-19_05-10-00.md` — Modelo≈`hy3` @ Logs/1075-hy3-M109-TRAZABILIDAD_2026-09-19_05-10-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1075-hy3-M109-TRAZABILIDAD_2026-09-19_05-10-00.md:1
- `1087-hy3-M09-QA_2026-09-19_05-45-00.md` — Modelo≈`hy3` @ Logs/1087-hy3-M09-QA_2026-09-19_05-45-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1087-hy3-M09-QA_2026-09-19_05-45-00.md:1; Fecha≈`2026-09-19` @ Logs/1087-hy3-M09-QA_2026-09-19_05-45-00.md:3
- `1092-hy3-M149-QA_2026-09-19_03-45-49.md` — Modelo≈`hy3` @ Logs/1092-hy3-M149-QA_2026-09-19_03-45-49.md:3; Plataforma≈`WorkBuddy` @ Logs/1092-hy3-M149-QA_2026-09-19_03-45-49.md:3
- `1097-hy3-QA-CRUZADO-10-MODULOS_2026-09-19_22-46-31.md` — Modelo≈`hy3` @ Logs/1097-hy3-QA-CRUZADO-10-MODULOS_2026-09-19_22-46-31.md:1; Plataforma≈`WorkBuddy` @ Logs/1097-hy3-QA-CRUZADO-10-MODULOS_2026-09-19_22-46-31.md:1
- `1100-hy3-M25-DISENO_2026-09-19_22-50-00.md` — Modelo≈`hy3` @ Logs/1100-hy3-M25-DISENO_2026-09-19_22-50-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1100-hy3-M25-DISENO_2026-09-19_22-50-00.md:1
- `1111-hy3-BUG050-LOTE_2026-09-19_22-50-00.md` — Plataforma≈`WorkBuddy` @ Logs/1111-hy3-BUG050-LOTE_2026-09-19_22-50-00.md:1
- `1117-hy3-CADENA-A-VERIFICACION_2026-09-19_04-30-00.md` — Plataforma≈`WorkBuddy` @ Logs/1117-hy3-CADENA-A-VERIFICACION_2026-09-19_04-30-00.md:1
- `1125-hy3-M118-REVERT-CASO-A-BUG072_2026-09-19_05-35-00.md` — Plataforma≈`WorkBuddy` @ Logs/1125-hy3-M118-REVERT-CASO-A-BUG072_2026-09-19_05-35-00.md:1
- `1128-hy3-M62-reverif-21.8-Memoria_2026-09-20_05-35-00.md` — Modelo≈`hy3` @ Logs/1128-hy3-M62-reverif-21.8-Memoria_2026-09-20_05-35-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1128-hy3-M62-reverif-21.8-Memoria_2026-09-20_05-35-00.md:1
- `1129-hy3-M103-reverif-21.8-Logging_2026-09-20_05-35-00.md` — Modelo≈`hy3` @ Logs/1129-hy3-M103-reverif-21.8-Logging_2026-09-20_05-35-00.md:1; Plataforma≈`WorkBuddy` @ Logs/1129-hy3-M103-reverif-21.8-Logging_2026-09-20_05-35-00.md:1
- `1140-hy3-verificacion-firmas-P20-P25_2026-09-24_21-44-40.md` — Plataforma≈`WorkBuddy` @ Logs/1140-hy3-verificacion-firmas-P20-P25_2026-09-24_21-44-40.md:1
- `1144-hy3-P31-QA-M32-M36-M167_2026-09-24_23-27-57.md` — Plataforma≈`WorkBuddy` @ Logs/1144-hy3-P31-QA-M32-M36-M167_2026-09-24_23-27-57.md:1
- `1214-m101-qa21.8-hy3_2026-10-03.md` — Modelo≈`hy3` @ Logs/1214-m101-qa21.8-hy3_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1214-m101-qa21.8-hy3_2026-10-03.md:4
- `1215-m123-qa21.8-hy3_2026-10-03.md` — Modelo≈`hy3` @ Logs/1215-m123-qa21.8-hy3_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1215-m123-qa21.8-hy3_2026-10-03.md:4
- `1216-m154-qa21.8-hy3_2026-10-03.md` — Modelo≈`hy3` @ Logs/1216-m154-qa21.8-hy3_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1216-m154-qa21.8-hy3_2026-10-03.md:4
- `1217-m84-qa21.8-hy3_2026-10-03.md` — Modelo≈`hy3` @ Logs/1217-m84-qa21.8-hy3_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1217-m84-qa21.8-hy3_2026-10-03.md:4
- `1218-m93-qa21.8-hy3_2026-10-03.md` — Modelo≈`hy3` @ Logs/1218-m93-qa21.8-hy3_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1218-m93-qa21.8-hy3_2026-10-03.md:4
- `1342-hy3-qa21.8-m53-reverificacion_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1342-hy3-qa21.8-m53-reverificacion_2026-10-05.md:1; Plataforma≈`WorkBuddy` @ Logs/1342-hy3-qa21.8-m53-reverificacion_2026-10-05.md:4
- `1352-hy3-qa21.8-m64-ia-npc_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1352-hy3-qa21.8-m64-ia-npc_2026-10-05.md:1; Plataforma≈`WorkBuddy` @ Logs/1352-hy3-qa21.8-m64-ia-npc_2026-10-05.md:5
- `1353-hy3-qa21-8-m55-lote2_2026-10-06.md` — Modelo≈`Hy3` @ Logs/1353-hy3-qa21-8-m55-lote2_2026-10-06.md:1; Plataforma≈`WorkBuddy` @ Logs/1353-hy3-qa21-8-m55-lote2_2026-10-06.md:4
- `1404-hy3-bug115-m72-qa218-veredicto_2026-10-06_23-30-48.md` — Modelo≈`Hy3` @ Logs/1404-hy3-bug115-m72-qa218-veredicto_2026-10-06_23-30-48.md:1; Plataforma≈`WorkBuddy` @ Logs/1404-hy3-bug115-m72-qa218-veredicto_2026-10-06_23-30-48.md:1; Fecha≈`2026-10-06` @ Logs/1404-hy3-bug115-m72-qa218-veredicto_2026-10-06_23-30-48.md:3
- `1430-hy3-m112-qa218-veredicto_2026-10-07_05-51-54.md` — Modelo≈`Hy3` @ Logs/1430-hy3-m112-qa218-veredicto_2026-10-07_05-51-54.md:1; Plataforma≈`WorkBuddy` @ Logs/1430-hy3-m112-qa218-veredicto_2026-10-07_05-51-54.md:1; Fecha≈`2026-10-07` @ Logs/1430-hy3-m112-qa218-veredicto_2026-10-07_05-51-54.md:3
- `1455-hy3-reconteo-recorrida-legacy-m103-m106-m117-m122-m87_2026-10-08_02-51-15.md` — Modelo≈`Hy3` @ Logs/1455-hy3-reconteo-recorrida-legacy-m103-m106-m117-m122-m87_2026-10-08_02-51-15.md:3; Plataforma≈`WorkBuddy` @ Logs/1455-hy3-reconteo-recorrida-legacy-m103-m106-m117-m122-m87_2026-10-08_02-51-15.md:3; Fecha≈`2026-10-08` @ Logs/1455-hy3-reconteo-recorrida-legacy-m103-m106-m117-m122-m87_2026-10-08_02-51-15.md:4
- `1476-hy3-capa-alerta-bug070-lote1_2026-10-08_17-37-39.md` — Modelo≈`Hy3` @ Logs/1476-hy3-capa-alerta-bug070-lote1_2026-10-08_17-37-39.md:1; Plataforma≈`WorkBuddy` @ Logs/1476-hy3-capa-alerta-bug070-lote1_2026-10-08_17-37-39.md:5
- `1477-hy3-m106-qa218-estatica-bloqueo-binario_2026-10-08_17-40-30.md` — Modelo≈`Hy3` @ Logs/1477-hy3-m106-qa218-estatica-bloqueo-binario_2026-10-08_17-40-30.md:1; Plataforma≈`WorkBuddy` @ Logs/1477-hy3-m106-qa218-estatica-bloqueo-binario_2026-10-08_17-40-30.md:5
- `1486-hy3-m122-qa218-veredicto_2026-10-08_19-30-32.md` — Modelo≈`Hy3` @ Logs/1486-hy3-m122-qa218-veredicto_2026-10-08_19-30-32.md:1; Plataforma≈`WorkBuddy` @ Logs/1486-hy3-m122-qa218-veredicto_2026-10-08_19-30-32.md:4
- `1685-hy3-m128-lote1-brandconfig-contraste_2026-10-11_19-50-19.md` — Modelo≈`Hy3` @ Logs/1685-hy3-m128-lote1-brandconfig-contraste_2026-10-11_19-50-19.md:1; Plataforma≈`WorkBuddy` @ Logs/1685-hy3-m128-lote1-brandconfig-contraste_2026-10-11_19-50-19.md:2; Fecha≈`2026-10-11` @ Logs/1685-hy3-m128-lote1-brandconfig-contraste_2026-10-11_19-50-19.md:4
- `1882-hy3-qa223-m09-terreno_2026-10-16_00-14-20.md` — Modelo≈`Hy3` @ Logs/1882-hy3-qa223-m09-terreno_2026-10-16_00-14-20.md:1; Plataforma≈`WorkBuddy` @ Logs/1882-hy3-qa223-m09-terreno_2026-10-16_00-14-20.md:4; Fecha≈`2026-09-18` @ Logs/1882-hy3-qa223-m09-terreno_2026-10-16_00-14-20.md:11
- `1890-hy3-m91-qa218_2026-10-16_03-01-09.md` — Modelo≈`Hy3` @ Logs/1890-hy3-m91-qa218_2026-10-16_03-01-09.md:1; Plataforma≈`WorkBuddy` @ Logs/1890-hy3-m91-qa218_2026-10-16_03-01-09.md:4
- `1891-hy3-m118-qa218_2026-10-16_03-01-09.md` — Modelo≈`Hy3` @ Logs/1891-hy3-m118-qa218_2026-10-16_03-01-09.md:1; Plataforma≈`WorkBuddy` @ Logs/1891-hy3-m118-qa218_2026-10-16_03-01-09.md:4
- `1892-hy3-m26-qa218_2026-10-16_03-01-09.md` — Modelo≈`Hy3` @ Logs/1892-hy3-m26-qa218_2026-10-16_03-01-09.md:1; Plataforma≈`WorkBuddy` @ Logs/1892-hy3-m26-qa218_2026-10-16_03-01-09.md:4
- `1893-hy3-m117-qa218_2026-10-16_03-01-09.md` — Modelo≈`Hy3` @ Logs/1893-hy3-m117-qa218_2026-10-16_03-01-09.md:1; Plataforma≈`WorkBuddy` @ Logs/1893-hy3-m117-qa218_2026-10-16_03-01-09.md:4
- `2014-hy3-crossqa-m32-m94_2026-10-19_01-44-34.md` — Modelo≈`Hy3` @ Logs/2014-hy3-crossqa-m32-m94_2026-10-19_01-44-34.md:1; Plataforma≈`WorkBuddy` @ Logs/2014-hy3-crossqa-m32-m94_2026-10-19_01-44-34.md:3
- `2017-hy3-qa218-m102-reverificacion_2026-10-19_02-50-48.md` — Modelo≈`Hy3` @ Logs/2017-hy3-qa218-m102-reverificacion_2026-10-19_02-50-48.md:1
- `2020-hy3-qa21-8-m153_2026-10-19_04-33-30.md` — Modelo≈`Hy3` @ Logs/2020-hy3-qa21-8-m153_2026-10-19_04-33-30.md:1; Plataforma≈`WorkBuddy` @ Logs/2020-hy3-qa21-8-m153_2026-10-19_04-33-30.md:3
- `2030-hy3-smoke-core-reverif_2026-10-20_01-15-28.md` — Modelo≈`Hy3` @ Logs/2030-hy3-smoke-core-reverif_2026-10-20_01-15-28.md:1; Plataforma≈`WorkBuddy` @ Logs/2030-hy3-smoke-core-reverif_2026-10-20_01-15-28.md:3; Fecha≈`2026-10-20` @ Logs/2030-hy3-smoke-core-reverif_2026-10-20_01-15-28.md:5
- `2058-hy3-qa-m103-cross-21.8_2026-10-21_01-39-26.md` — Modelo≈`Hy3` @ Logs/2058-hy3-qa-m103-cross-21.8_2026-10-21_01-39-26.md:1; Plataforma≈`WorkBuddy` @ Logs/2058-hy3-qa-m103-cross-21.8_2026-10-21_01-39-26.md:2; Fecha≈`2026-10-21` @ Logs/2058-hy3-qa-m103-cross-21.8_2026-10-21_01-39-26.md:4
- `2074-hy3-m104-qa218_2026-10-21_06-40-35.md` — Modelo≈`Hy3` @ Logs/2074-hy3-m104-qa218_2026-10-21_06-40-35.md:1; Plataforma≈`WorkBuddy` @ Logs/2074-hy3-m104-qa218_2026-10-21_06-40-35.md:3
- `2147-hy3-island-travel-guard-m28-m27-viajes-gating_2026-10-22_22-39-31.md` — Modelo≈`Hy3` @ Logs/2147-hy3-island-travel-guard-m28-m27-viajes-gating_2026-10-22_22-39-31.md:1; Plataforma≈`WorkBuddy` @ Logs/2147-hy3-island-travel-guard-m28-m27-viajes-gating_2026-10-22_22-39-31.md:2; Fecha≈`2026-10-22` @ Logs/2147-hy3-island-travel-guard-m28-m27-viajes-gating_2026-10-22_22-39-31.md:4
- `2150-hy3-m110-debug-croqs_2026-10-23_02-46-12.md` — Modelo≈`Hy3` @ Logs/2150-hy3-m110-debug-croqs_2026-10-23_02-46-12.md:1; Plataforma≈`WorkBuddy` @ Logs/2150-hy3-m110-debug-croqs_2026-10-23_02-46-12.md:10
- `2159-hy3-m20-runtime-amistad-ciclo_2026-10-23_20-42-24.md` — Modelo≈`Hy3` @ Logs/2159-hy3-m20-runtime-amistad-ciclo_2026-10-23_20-42-24.md:1; Plataforma≈`WorkBuddy` @ Logs/2159-hy3-m20-runtime-amistad-ciclo_2026-10-23_20-42-24.md:10
- `2201-Hy3-gate2-M77-M60-verificacion_2026-10-26_02-42-53.md` — Modelo≈`Hy3` @ Logs/2201-Hy3-gate2-M77-M60-verificacion_2026-10-26_02-42-53.md:1; Plataforma≈`WorkBuddy` @ Logs/2201-Hy3-gate2-M77-M60-verificacion_2026-10-26_02-42-53.md:40; Fecha≈`2026-10-26` @ Logs/2201-Hy3-gate2-M77-M60-verificacion_2026-10-26_02-42-53.md:2
- `2207-hy3-gate2-m72_2026-10-26_22-32-52.md` — Modelo≈`Hy3` @ Logs/2207-hy3-gate2-m72_2026-10-26_22-32-52.md:1; Plataforma≈`WorkBuddy` @ Logs/2207-hy3-gate2-m72_2026-10-26_22-32-52.md:3; Fecha≈`2026-10-26` @ Logs/2207-hy3-gate2-m72_2026-10-26_22-32-52.md:5
- `2231-hy3-tanda-gate2-t1-t5_2026-10-28_04-25-44.md` — Modelo≈`Hy3` @ Logs/2231-hy3-tanda-gate2-t1-t5_2026-10-28_04-25-44.md:1; Plataforma≈`WorkBuddy` @ Logs/2231-hy3-tanda-gate2-t1-t5_2026-10-28_04-25-44.md:3; Fecha≈`2026-10-28` @ Logs/2231-hy3-tanda-gate2-t1-t5_2026-10-28_04-25-44.md:4
- `2322-hy3-encuesta-m144-postlanzamiento_2026-11-05_22-44-35.md` — Modelo≈`Hy3` @ Logs/2322-hy3-encuesta-m144-postlanzamiento_2026-11-05_22-44-35.md:1
- `2394-hy3-verif-saneo-m46-m61-m76-regresion-m21_2026-11-10_20-59-03.md` — Modelo≈`Hy3` @ Logs/2394-hy3-verif-saneo-m46-m61-m76-regresion-m21_2026-11-10_20-59-03.md:1
- `2395-Hy3-TANDA14nov-QA-Volumen3_2026-11-10_22-31-00.md` — Modelo≈`Hy3` @ Logs/2395-Hy3-TANDA14nov-QA-Volumen3_2026-11-10_22-31-00.md:1
- `2398-Hy3-acuse552-GOs-saneo-M80-M88-M94_2026-11-11_20-48-16.md` — Modelo≈`Hy3` @ Logs/2398-Hy3-acuse552-GOs-saneo-M80-M88-M94_2026-11-11_20-48-16.md:1; Plataforma≈`WorkBuddy` @ Logs/2398-Hy3-acuse552-GOs-saneo-M80-M88-M94_2026-11-11_20-48-16.md:4
- `2400-Hy3-TANDA15nov-QA-Volumen4_2026-11-11_21-17-53.md` — Modelo≈`Hy3` @ Logs/2400-Hy3-TANDA15nov-QA-Volumen4_2026-11-11_21-17-53.md:1; Plataforma≈`WorkBuddy` @ Logs/2400-Hy3-TANDA15nov-QA-Volumen4_2026-11-11_21-17-53.md:4
- `2406-hy3-tanda16nov-ejecucion_2026-11-12_20-10-02.md` — Modelo≈`Hy3` @ Logs/2406-hy3-tanda16nov-ejecucion_2026-11-12_20-10-02.md:1
- `2409-hy3-tanda17nov-qa-vol6_2026-11-13_01-53-12.md` — Modelo≈`Hy3` @ Logs/2409-hy3-tanda17nov-qa-vol6_2026-11-13_01-53-12.md:1
- `2416-hy3-tanda19nov-qa12tareas_2026-11-13_19-08-14.md` — Modelo≈`Hy3` @ Logs/2416-hy3-tanda19nov-qa12tareas_2026-11-13_19-08-14.md:1
- `2427-hy3-tanda22nov-qa-11mods_2026-11-15_22-09-10.md` — Modelo≈`Hy3` @ Logs/2427-hy3-tanda22nov-qa-11mods_2026-11-15_22-09-10.md:1; Plataforma≈`WorkBuddy` @ Logs/2427-hy3-tanda22nov-qa-11mods_2026-11-15_22-09-10.md:1
- `723-HY3-M11-QA-CRUZADO_2026-09-07.md` — Modelo≈`hy3` @ Logs/723-HY3-M11-QA-CRUZADO_2026-09-07.md:3
- … y 24 más (misma clase)

**hy4** (36)
- `1189-HY4-AUDITORIA-ARTEFACTOS-DOCUMENTADOS-INEXISTENTES.md` — Plataforma≈`WorkBuddy` @ Logs/1189-HY4-AUDITORIA-ARTEFACTOS-DOCUMENTADOS-INEXISTENTES.md:3
- `2312-HY4-B11-AUDITORIA-BLENDER-ARBOLES-Y-ESTRELLA_2026-11-05_21-42-26.md` — Plataforma≈`WorkBuddy` @ Logs/2312-HY4-B11-AUDITORIA-BLENDER-ARBOLES-Y-ESTRELLA_2026-11-05_21-42-26.md:3
- `2318-HY4-B12-P01-CI-ENCODING-GUARD_2026-11-05_22-15-19.md` — Plataforma≈`WorkBuddy` @ Logs/2318-HY4-B12-P01-CI-ENCODING-GUARD_2026-11-05_22-15-19.md:3
- `2319-HY4-B13-FALSO-VERDE-GUARDIA-ESCALAS-3-PERFILES_2026-11-05_22-20-41.md` — Plataforma≈`WorkBuddy` @ Logs/2319-HY4-B13-FALSO-VERDE-GUARDIA-ESCALAS-3-PERFILES_2026-11-05_22-20-41.md:3
- `2320-HY4-D03-FLIPS-EVIDENCIA-POSITIVA_2026-11-05_22-32-46.md` — Plataforma≈`WorkBuddy` @ Logs/2320-HY4-D03-FLIPS-EVIDENCIA-POSITIVA_2026-11-05_22-32-46.md:3
- `2321-HY4-D01-REHORNEADO-10-GLB-M50-MEDIA_2026-11-05_22-36-41.md` — Plataforma≈`WorkBuddy` @ Logs/2321-HY4-D01-REHORNEADO-10-GLB-M50-MEDIA_2026-11-05_22-36-41.md:3
- `2323-HY4-T01A-BARQUITA-AURORA-3-GLB_2026-11-05_23-07-57.md` — Plataforma≈`WorkBuddy` @ Logs/2323-HY4-T01A-BARQUITA-AURORA-3-GLB_2026-11-05_23-07-57.md:3
- `2325-HY4-T01B-GLOBO-DEL-VIENTO-3-GLB_2026-11-06_00-31-23.md` — Plataforma≈`WorkBuddy` @ Logs/2325-HY4-T01B-GLOBO-DEL-VIENTO-3-GLB_2026-11-06_00-31-23.md:3
- `2327-HY4-T01C-PERLA-ANCESTRAL-3-GLB_2026-11-06_00-59-41.md` — Plataforma≈`WorkBuddy` @ Logs/2327-HY4-T01C-PERLA-ANCESTRAL-3-GLB_2026-11-06_00-59-41.md:3
- `2328-HY4-T01D-GRAN-VAPOR-3-GLB_2026-11-06_01-23-00.md` — Modelo≈`HY4` @ Logs/2328-HY4-T01D-GRAN-VAPOR-3-GLB_2026-11-06_01-23-00.md:1; Plataforma≈`WorkBuddy` @ Logs/2328-HY4-T01D-GRAN-VAPOR-3-GLB_2026-11-06_01-23-00.md:4; Fecha≈`2026-11-06` @ Logs/2328-HY4-T01D-GRAN-VAPOR-3-GLB_2026-11-06_01-23-00.md:3
- `2332-HY4-T02-CARRETA-M157-3-GLB_2026-11-06_02-36-14.md` — Modelo≈`HY4` @ Logs/2332-HY4-T02-CARRETA-M157-3-GLB_2026-11-06_02-36-14.md:1; Plataforma≈`WorkBuddy` @ Logs/2332-HY4-T02-CARRETA-M157-3-GLB_2026-11-06_02-36-14.md:4; Fecha≈`2026-11-06` @ Logs/2332-HY4-T02-CARRETA-M157-3-GLB_2026-11-06_02-36-14.md:3
- `2335-HY4-B10BIS-EXPORT-6-GLB-COLUMNA-ROTA-M25_2026-11-06_03-19-06.md` — Modelo≈`HY4` @ Logs/2335-HY4-B10BIS-EXPORT-6-GLB-COLUMNA-ROTA-M25_2026-11-06_03-19-06.md:1; Plataforma≈`WorkBuddy` @ Logs/2335-HY4-B10BIS-EXPORT-6-GLB-COLUMNA-ROTA-M25_2026-11-06_03-19-06.md:4; Fecha≈`2026-11-06` @ Logs/2335-HY4-B10BIS-EXPORT-6-GLB-COLUMNA-ROTA-M25_2026-11-06_03-19-06.md:3
- `2338-HY4-M25-COLUMNA-ENTERA-CAPITEL-3-GLB_2026-11-06_04-51-59.md` — Modelo≈`HY4` @ Logs/2338-HY4-M25-COLUMNA-ENTERA-CAPITEL-3-GLB_2026-11-06_04-51-59.md:1; Plataforma≈`WorkBuddy` @ Logs/2338-HY4-M25-COLUMNA-ENTERA-CAPITEL-3-GLB_2026-11-06_04-51-59.md:4; Fecha≈`2026-11-06` @ Logs/2338-HY4-M25-COLUMNA-ENTERA-CAPITEL-3-GLB_2026-11-06_04-51-59.md:3
- `2341-HY4-M18BIS-MANSION-14X10-3-GLB_2026-11-06_06-19-18.md` — Modelo≈`HY4` @ Logs/2341-HY4-M18BIS-MANSION-14X10-3-GLB_2026-11-06_06-19-18.md:1; Plataforma≈`WorkBuddy` @ Logs/2341-HY4-M18BIS-MANSION-14X10-3-GLB_2026-11-06_06-19-18.md:4; Fecha≈`2026-11-06` @ Logs/2341-HY4-M18BIS-MANSION-14X10-3-GLB_2026-11-06_06-19-18.md:3
- `2356-HY4-B10TER-EXPORT-3-GLB-CASA-VECINO_2026-11-07_03-55-45.md` — Modelo≈`HY4` @ Logs/2356-HY4-B10TER-EXPORT-3-GLB-CASA-VECINO_2026-11-07_03-55-45.md:1; Plataforma≈`WorkBuddy` @ Logs/2356-HY4-B10TER-EXPORT-3-GLB-CASA-VECINO_2026-11-07_03-55-45.md:4; Fecha≈`2026-11-07` @ Logs/2356-HY4-B10TER-EXPORT-3-GLB-CASA-VECINO_2026-11-07_03-55-45.md:3
- `2357-HY4-B11-AUDITORIA-LEGADO-18BIS-MIMO_2026-11-07_05-35-31.md` — Modelo≈`HY4` @ Logs/2357-HY4-B11-AUDITORIA-LEGADO-18BIS-MIMO_2026-11-07_05-35-31.md:1; Plataforma≈`WorkBuddy` @ Logs/2357-HY4-B11-AUDITORIA-LEGADO-18BIS-MIMO_2026-11-07_05-35-31.md:4; Fecha≈`2026-11-07` @ Logs/2357-HY4-B11-AUDITORIA-LEGADO-18BIS-MIMO_2026-11-07_05-35-31.md:3
- `2361-HY4-B12-TRIANGULOS-RUNTIME-676-VS-530_2026-11-07_18-40-16.md` — Modelo≈`HY4` @ Logs/2361-HY4-B12-TRIANGULOS-RUNTIME-676-VS-530_2026-11-07_18-40-16.md:1; Plataforma≈`WorkBuddy` @ Logs/2361-HY4-B12-TRIANGULOS-RUNTIME-676-VS-530_2026-11-07_18-40-16.md:4; Fecha≈`2026-11-07` @ Logs/2361-HY4-B12-TRIANGULOS-RUNTIME-676-VS-530_2026-11-07_18-40-16.md:3
- `2364-HY4-B13-CORPUS-M166-RUNTIME-30-GLB_2026-11-07_18-56-02.md` — Modelo≈`HY4` @ Logs/2364-HY4-B13-CORPUS-M166-RUNTIME-30-GLB_2026-11-07_18-56-02.md:1; Plataforma≈`WorkBuddy` @ Logs/2364-HY4-B13-CORPUS-M166-RUNTIME-30-GLB_2026-11-07_18-56-02.md:3; Fecha≈`2026-11-07` @ Logs/2364-HY4-B13-CORPUS-M166-RUNTIME-30-GLB_2026-11-07_18-56-02.md:4
- `2366-HY4-B15-BLOQUE-PIEDRA-TALLADA-M25_2026-11-07_20-05-23.md` — Modelo≈`HY4` @ Logs/2366-HY4-B15-BLOQUE-PIEDRA-TALLADA-M25_2026-11-07_20-05-23.md:1; Plataforma≈`WorkBuddy` @ Logs/2366-HY4-B15-BLOQUE-PIEDRA-TALLADA-M25_2026-11-07_20-05-23.md:3; Fecha≈`2026-11-07` @ Logs/2366-HY4-B15-BLOQUE-PIEDRA-TALLADA-M25_2026-11-07_20-05-23.md:4
- `2369-HY4-B16-DINTEL-CAIDO-M25_2026-11-08_00-33-21.md` — Modelo≈`HY4` @ Logs/2369-HY4-B16-DINTEL-CAIDO-M25_2026-11-08_00-33-21.md:1; Plataforma≈`WorkBuddy` @ Logs/2369-HY4-B16-DINTEL-CAIDO-M25_2026-11-08_00-33-21.md:3; Fecha≈`2026-11-08` @ Logs/2369-HY4-B16-DINTEL-CAIDO-M25_2026-11-08_00-33-21.md:4
- `2372-HY4-B17-ESTRUCTURA-SUMERGIDA-M25_2026-11-08_02-22-42.md` — Modelo≈`HY4` @ Logs/2372-HY4-B17-ESTRUCTURA-SUMERGIDA-M25_2026-11-08_02-22-42.md:1; Plataforma≈`WorkBuddy` @ Logs/2372-HY4-B17-ESTRUCTURA-SUMERGIDA-M25_2026-11-08_02-22-42.md:3; Fecha≈`2026-11-08` @ Logs/2372-HY4-B17-ESTRUCTURA-SUMERGIDA-M25_2026-11-08_02-22-42.md:4
- `2374-HY4-B18-VALLA-MADERA-M40_2026-11-08_21-10-00.md` — Modelo≈`HY4` @ Logs/2374-HY4-B18-VALLA-MADERA-M40_2026-11-08_21-10-00.md:1; Plataforma≈`WorkBuddy` @ Logs/2374-HY4-B18-VALLA-MADERA-M40_2026-11-08_21-10-00.md:3; Fecha≈`2026-11-08` @ Logs/2374-HY4-B18-VALLA-MADERA-M40_2026-11-08_21-10-00.md:4
- `2376-HY4-B19-CANA-PESCAR-M35_2026-11-08_22-55-55.md` — Modelo≈`HY4` @ Logs/2376-HY4-B19-CANA-PESCAR-M35_2026-11-08_22-55-55.md:1; Plataforma≈`WorkBuddy` @ Logs/2376-HY4-B19-CANA-PESCAR-M35_2026-11-08_22-55-55.md:3; Fecha≈`2026-11-08` @ Logs/2376-HY4-B19-CANA-PESCAR-M35_2026-11-08_22-55-55.md:4
- `2380-HY4-B20-CARRITO-VIAS-M35_2026-11-09_00-43-36.md` — Modelo≈`HY4` @ Logs/2380-HY4-B20-CARRITO-VIAS-M35_2026-11-09_00-43-36.md:1; Plataforma≈`WorkBuddy` @ Logs/2380-HY4-B20-CARRITO-VIAS-M35_2026-11-09_00-43-36.md:3; Fecha≈`2026-11-09` @ Logs/2380-HY4-B20-CARRITO-VIAS-M35_2026-11-09_00-43-36.md:4
- `2381-HY4-B21-CANGREJO-ERMITANO-M36_2026-11-09_01-48-31.md` — Modelo≈`HY4` @ Logs/2381-HY4-B21-CANGREJO-ERMITANO-M36_2026-11-09_01-48-31.md:1; Plataforma≈`WorkBuddy` @ Logs/2381-HY4-B21-CANGREJO-ERMITANO-M36_2026-11-09_01-48-31.md:3; Fecha≈`2026-11-09` @ Logs/2381-HY4-B21-CANGREJO-ERMITANO-M36_2026-11-09_01-48-31.md:4
- `2393-HY4-B22-PEZ-TROPICAL-M36_2026-11-10_00-20-00.md` — Modelo≈`HY4` @ Logs/2393-HY4-B22-PEZ-TROPICAL-M36_2026-11-10_00-20-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2393-HY4-B22-PEZ-TROPICAL-M36_2026-11-10_00-20-00.md:5; Fecha≈`2026-11-10` @ Logs/2393-HY4-B22-PEZ-TROPICAL-M36_2026-11-10_00-20-00.md:4
- `2396-HY4-B23-LAGARTO-ISLA-M36_2026-11-10_23-10-00.md` — Modelo≈`HY4` @ Logs/2396-HY4-B23-LAGARTO-ISLA-M36_2026-11-10_23-10-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2396-HY4-B23-LAGARTO-ISLA-M36_2026-11-10_23-10-00.md:5; Fecha≈`2026-11-10` @ Logs/2396-HY4-B23-LAGARTO-ISLA-M36_2026-11-10_23-10-00.md:4
- `2399-HY4-B24-CABRA-M36_2026-11-11_21-00-00.md` — Modelo≈`HY4` @ Logs/2399-HY4-B24-CABRA-M36_2026-11-11_21-00-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2399-HY4-B24-CABRA-M36_2026-11-11_21-00-00.md:5; Fecha≈`2026-11-11` @ Logs/2399-HY4-B24-CABRA-M36_2026-11-11_21-00-00.md:4
- `2401-HY4-B25-GALLINA-M36_2026-11-11_21-25-00.md` — Modelo≈`HY4` @ Logs/2401-HY4-B25-GALLINA-M36_2026-11-11_21-25-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2401-HY4-B25-GALLINA-M36_2026-11-11_21-25-00.md:5; Fecha≈`2026-11-11` @ Logs/2401-HY4-B25-GALLINA-M36_2026-11-11_21-25-00.md:4
- `2410-HY4-B26-MARIPOSA-M36_2026-11-13_00-45-00.md` — Modelo≈`HY4` @ Logs/2410-HY4-B26-MARIPOSA-M36_2026-11-13_00-45-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2410-HY4-B26-MARIPOSA-M36_2026-11-13_00-45-00.md:5; Fecha≈`2026-11-13` @ Logs/2410-HY4-B26-MARIPOSA-M36_2026-11-13_00-45-00.md:4
- `2412-HY4-B27-AUDITORIA-COLA-ACTIVA_2026-11-13_15-50-00.md` — Modelo≈`HY4` @ Logs/2412-HY4-B27-AUDITORIA-COLA-ACTIVA_2026-11-13_15-50-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2412-HY4-B27-AUDITORIA-COLA-ACTIVA_2026-11-13_15-50-00.md:5; Fecha≈`2026-11-13` @ Logs/2412-HY4-B27-AUDITORIA-COLA-ACTIVA_2026-11-13_15-50-00.md:4
- `2414-HY4-B28-COLUMNA-ENTERA-GLB_2026-11-13_16-25-00.md` — Modelo≈`HY4` @ Logs/2414-HY4-B28-COLUMNA-ENTERA-GLB_2026-11-13_16-25-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2414-HY4-B28-COLUMNA-ENTERA-GLB_2026-11-13_16-25-00.md:5; Fecha≈`2026-11-13` @ Logs/2414-HY4-B28-COLUMNA-ENTERA-GLB_2026-11-13_16-25-00.md:4
- `2419-HY4-B29-COLUMNA-ROTA-BLENDS_2026-11-14_06-10-00.md` — Modelo≈`HY4` @ Logs/2419-HY4-B29-COLUMNA-ROTA-BLENDS_2026-11-14_06-10-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2419-HY4-B29-COLUMNA-ROTA-BLENDS_2026-11-14_06-10-00.md:5; Fecha≈`2026-11-14` @ Logs/2419-HY4-B29-COLUMNA-ROTA-BLENDS_2026-11-14_06-10-00.md:4
- `2420-HY4-B30-DEUDA-RESTANTE_2026-11-14_06-35-00.md` — Modelo≈`HY4` @ Logs/2420-HY4-B30-DEUDA-RESTANTE_2026-11-14_06-35-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2420-HY4-B30-DEUDA-RESTANTE_2026-11-14_06-35-00.md:5; Fecha≈`2026-11-14` @ Logs/2420-HY4-B30-DEUDA-RESTANTE_2026-11-14_06-35-00.md:4
- `2421-HY4-B31-BARRIDO-REGRESION_2026-11-15_00-45-00.md` — Modelo≈`HY4` @ Logs/2421-HY4-B31-BARRIDO-REGRESION_2026-11-15_00-45-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2421-HY4-B31-BARRIDO-REGRESION_2026-11-15_00-45-00.md:5; Fecha≈`2026-11-15` @ Logs/2421-HY4-B31-BARRIDO-REGRESION_2026-11-15_00-45-00.md:4
- `2426-HY4-B32-CIERRE-TRACKER_2026-11-15_22-15-00.md` — Modelo≈`HY4` @ Logs/2426-HY4-B32-CIERRE-TRACKER_2026-11-15_22-15-00.md:2; Plataforma≈`WorkBuddy` @ Logs/2426-HY4-B32-CIERRE-TRACKER_2026-11-15_22-15-00.md:5; Fecha≈`2026-11-15` @ Logs/2426-HY4-B32-CIERRE-TRACKER_2026-11-15_22-15-00.md:4

**sin dueño en el nombre** (249)
- `1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md` — Modelo≈`Agente / Modelo:` @ Logs/1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md:5; Plataforma≈`WorkBuddy` @ Logs/1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md:5; Fecha≈`2026-09-18` @ Logs/1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md:3
- `1014-M116-Iter3-Gate-CI-Duro-Totales-Reales_2026-09-18_06-58.md` — Modelo≈`DeepSeek` @ Logs/1014-M116-Iter3-Gate-CI-Duro-Totales-Reales_2026-09-18_06-58.md:3; Plataforma≈`WorkBuddy` @ Logs/1014-M116-Iter3-Gate-CI-Duro-Totales-Reales_2026-09-18_06-58.md:3
- `1015-M87-Iter7-Fix-Regresion-M53-Gate-CI-Acumulativo_2026-09-18_16-10.md` — Modelo≈`DeepSeek` @ Logs/1015-M87-Iter7-Fix-Regresion-M53-Gate-CI-Acumulativo_2026-09-18_16-10.md:3; Plataforma≈`WorkBuddy` @ Logs/1015-M87-Iter7-Fix-Regresion-M53-Gate-CI-Acumulativo_2026-09-18_16-10.md:3
- `1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md` — Modelo≈`DeepSeek` @ Logs/1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md:3; Plataforma≈`WorkBuddy` @ Logs/1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md:3
- `1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md` — Modelo≈`DeepSeek` @ Logs/1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md:3; Plataforma≈`WorkBuddy` @ Logs/1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md:3
- `1109-M103-Logging-Iter2-Auditoria-Suites-Endurecimiento-Frame-Budget_2026-09-19.md` — Modelo≈`DeepSeek` @ Logs/1109-M103-Logging-Iter2-Auditoria-Suites-Endurecimiento-Frame-Budget_2026-09-19.md:3; Plataforma≈`WorkBuddy` @ Logs/1109-M103-Logging-Iter2-Auditoria-Suites-Endurecimiento-Frame-Budget_2026-09-19.md:3
- `1112-M62-Memoria-Iter4-Gates-Arquitectura-Presupuesto-Liberacion_2026-09-20_01-12-34.md` — Modelo≈`Modelo:` @ Logs/1112-M62-Memoria-Iter4-Gates-Arquitectura-Presupuesto-Liberacion_2026-09-20_01-12-34.md:4; Plataforma≈`Plataforma` @ Logs/1112-M62-Memoria-Iter4-Gates-Arquitectura-Presupuesto-Liberacion_2026-09-20_01-12-34.md:5; Fecha≈`2026-09-20` @ Logs/1112-M62-Memoria-Iter4-Gates-Arquitectura-Presupuesto-Liberacion_2026-09-20_01-12-34.md:3
- `1119-M127-Copyright-Iter4-Deposito-USCO-y-Citas-Falsas_2026-09-20_01-28-13.md` — Modelo≈`DeepSeek` @ Logs/1119-M127-Copyright-Iter4-Deposito-USCO-y-Citas-Falsas_2026-09-20_01-28-13.md:4; Plataforma≈`WorkBuddy` @ Logs/1119-M127-Copyright-Iter4-Deposito-USCO-y-Citas-Falsas_2026-09-20_01-28-13.md:4; Fecha≈`2026-09-20` @ Logs/1119-M127-Copyright-Iter4-Deposito-USCO-y-Citas-Falsas_2026-09-20_01-28-13.md:3
- `1136-P22-cierre-cruce-sellos_2026-09-20_22-19.md` — Modelo≈`hy3` @ Logs/1136-P22-cierre-cruce-sellos_2026-09-20_22-19.md:1; Plataforma≈`WorkBuddy` @ Logs/1136-P22-cierre-cruce-sellos_2026-09-20_22-19.md:1
- `1146-qa-p33-4modulos-reconciliacion-m167_2026-09-25_00-45-00.md` — Modelo≈`hy3` @ Logs/1146-qa-p33-4modulos-reconciliacion-m167_2026-09-25_00-45-00.md:3; Plataforma≈`WorkBuddy` @ Logs/1146-qa-p33-4modulos-reconciliacion-m167_2026-09-25_00-45-00.md:3; Fecha≈`2026-09-25` @ Logs/1146-qa-p33-4modulos-reconciliacion-m167_2026-09-25_00-45-00.md:3
- `1192-M63-iter5-lado-63-handshake-precalentamiento-regiones_2026-10-02_18-32-06.md` — Modelo≈`Modelo:` @ Logs/1192-M63-iter5-lado-63-handshake-precalentamiento-regiones_2026-10-02_18-32-06.md:3; Plataforma≈`WorkBuddy` @ Logs/1192-M63-iter5-lado-63-handshake-precalentamiento-regiones_2026-10-02_18-32-06.md:3; Fecha≈`2026-10-02` @ Logs/1192-M63-iter5-lado-63-handshake-precalentamiento-regiones_2026-10-02_18-32-06.md:4
- `1193-M63-iter6-consejos-rotando-fade-documentacion_2026-10-02_19-21-25.md` — Modelo≈`Modelo:` @ Logs/1193-M63-iter6-consejos-rotando-fade-documentacion_2026-10-02_19-21-25.md:3; Plataforma≈`WorkBuddy` @ Logs/1193-M63-iter6-consejos-rotando-fade-documentacion_2026-10-02_19-21-25.md:3; Fecha≈`2026-10-02` @ Logs/1193-M63-iter6-consejos-rotando-fade-documentacion_2026-10-02_19-21-25.md:4
- `1196-M62-iter6-pureza-save-L98_2026-10-02_19-44-25.md` — Modelo≈`Modelo:` @ Logs/1196-M62-iter6-pureza-save-L98_2026-10-02_19-44-25.md:3; Plataforma≈`Plataforma` @ Logs/1196-M62-iter6-pureza-save-L98_2026-10-02_19-44-25.md:4; Fecha≈`2026-10-02` @ Logs/1196-M62-iter6-pureza-save-L98_2026-10-02_19-44-25.md:5
- `1197-M59-iter1-3-bugs-carga-metadatos-version-futura_2026-10-02_20-04-18.md` — Modelo≈`Modelo:` @ Logs/1197-M59-iter1-3-bugs-carga-metadatos-version-futura_2026-10-02_20-04-18.md:3; Plataforma≈`Plataforma` @ Logs/1197-M59-iter1-3-bugs-carga-metadatos-version-futura_2026-10-02_20-04-18.md:4; Fecha≈`2026-10-02` @ Logs/1197-M59-iter1-3-bugs-carga-metadatos-version-futura_2026-10-02_20-04-18.md:5
- `1211-M17-Construccion-iter1-nucleo_2026-10-03.md` — Modelo≈`DeepSeek` @ Logs/1211-M17-Construccion-iter1-nucleo_2026-10-03.md:5; Plataforma≈`WorkBuddy` @ Logs/1211-M17-Construccion-iter1-nucleo_2026-10-03.md:5
- `1212-m167-qa21.8-cierre_2026-10-03.md` — Plataforma≈`WorkBuddy` @ Logs/1212-m167-qa21.8-cierre_2026-10-03.md:3
- `1222-m63-qa21.8-reverificacion_2026-10-03.md` — Modelo≈`hy3` @ Logs/1222-m63-qa21.8-reverificacion_2026-10-03.md:4; Plataforma≈`WorkBuddy` @ Logs/1222-m63-qa21.8-reverificacion_2026-10-03.md:4; Fecha≈`2026-10-03` @ Logs/1222-m63-qa21.8-reverificacion_2026-10-03.md:3
- `1223-m62-qa21.8-iter56_2026-10-03.md` — Modelo≈`hy3` @ Logs/1223-m62-qa21.8-iter56_2026-10-03.md:4; Plataforma≈`WorkBuddy` @ Logs/1223-m62-qa21.8-iter56_2026-10-03.md:4; Fecha≈`2026-10-03` @ Logs/1223-m62-qa21.8-iter56_2026-10-03.md:3
- `1224-m70-qa21.8_2026-10-03.md` — Modelo≈`hy3` @ Logs/1224-m70-qa21.8_2026-10-03.md:5; Plataforma≈`WorkBuddy` @ Logs/1224-m70-qa21.8_2026-10-03.md:5; Fecha≈`2026-10-03` @ Logs/1224-m70-qa21.8_2026-10-03.md:3
- `1225-m91-qa21.8_2026-10-03.md` — Modelo≈`hy3` @ Logs/1225-m91-qa21.8_2026-10-03.md:5; Plataforma≈`WorkBuddy` @ Logs/1225-m91-qa21.8_2026-10-03.md:5; Fecha≈`2026-10-03` @ Logs/1225-m91-qa21.8_2026-10-03.md:3
- `1226-m54-qa21.8_2026-10-03.md` — Modelo≈`agnes` @ Logs/1226-m54-qa21.8_2026-10-03.md:4; Plataforma≈`WorkBuddy` @ Logs/1226-m54-qa21.8_2026-10-03.md:5; Fecha≈`2026-10-03` @ Logs/1226-m54-qa21.8_2026-10-03.md:3
- `1227-seccion-n-drift-audit_2026-10-03.md` — Modelo≈`hy3` @ Logs/1227-seccion-n-drift-audit_2026-10-03.md:4; Plataforma≈`WorkBuddy` @ Logs/1227-seccion-n-drift-audit_2026-10-03.md:4; Fecha≈`2026-10-03` @ Logs/1227-seccion-n-drift-audit_2026-10-03.md:3
- `1230-seccion-o-citas-rotas_2026-10-03.md` — Modelo≈`hy3` @ Logs/1230-seccion-o-citas-rotas_2026-10-03.md:4; Plataforma≈`WorkBuddy` @ Logs/1230-seccion-o-citas-rotas_2026-10-03.md:4; Fecha≈`2026-10-03` @ Logs/1230-seccion-o-citas-rotas_2026-10-03.md:3
- `1233-m59-qa21.8_2026-10-03.md` — Modelo≈`hy3` @ Logs/1233-m59-qa21.8_2026-10-03.md:1; Plataforma≈`WorkBuddy` @ Logs/1233-m59-qa21.8_2026-10-03.md:1
- `1234-bug090-cuarentena_2026-10-03.md` — Modelo≈`hy3` @ Logs/1234-bug090-cuarentena_2026-10-03.md:6; Plataforma≈`WorkBuddy` @ Logs/1234-bug090-cuarentena_2026-10-03.md:6
- `1235-cita-1036-anulada_2026-10-03.md` — Modelo≈`hy3` @ Logs/1235-cita-1036-anulada_2026-10-03.md:5; Plataforma≈`WorkBuddy` @ Logs/1235-cita-1036-anulada_2026-10-03.md:5
- `1241-M17-Construccion-iter2-catalogo-preview-ghost_2026-10-03_21-11-40.md` — Modelo≈`Modelo:` @ Logs/1241-M17-Construccion-iter2-catalogo-preview-ghost_2026-10-03_21-11-40.md:3; Plataforma≈`WorkBuddy` @ Logs/1241-M17-Construccion-iter2-catalogo-preview-ghost_2026-10-03_21-11-40.md:3; Fecha≈`2026-10-03` @ Logs/1241-M17-Construccion-iter2-catalogo-preview-ghost_2026-10-03_21-11-40.md:4
- `1244-M17-Construccion-iter3-hud-mesh-follow-permisos-stress_2026-10-04_02-26.md` — Modelo≈`Modelo:` @ Logs/1244-M17-Construccion-iter3-hud-mesh-follow-permisos-stress_2026-10-04_02-26.md:3; Plataforma≈`WorkBuddy` @ Logs/1244-M17-Construccion-iter3-hud-mesh-follow-permisos-stress_2026-10-04_02-26.md:3; Fecha≈`2026-10-04` @ Logs/1244-M17-Construccion-iter3-hud-mesh-follow-permisos-stress_2026-10-04_02-26.md:4
- `1251-M68-Transporte-iter3-waypoints-edge-cases_2026-10-04_03-21.md` — Modelo≈`Modelo:` @ Logs/1251-M68-Transporte-iter3-waypoints-edge-cases_2026-10-04_03-21.md:3; Plataforma≈`WorkBuddy` @ Logs/1251-M68-Transporte-iter3-waypoints-edge-cases_2026-10-04_03-21.md:3; Fecha≈`2026-10-04` @ Logs/1251-M68-Transporte-iter3-waypoints-edge-cases_2026-10-04_03-21.md:4
- `1258-m125-reverify-21.8_2026-10-04.md` — Plataforma≈`WorkBuddy` @ Logs/1258-m125-reverify-21.8_2026-10-04.md:4
- `1262-m79-reverify-21.8_2026-10-04.md` — Plataforma≈`WorkBuddy` @ Logs/1262-m79-reverify-21.8_2026-10-04.md:4
- `1265-m132-reverify-21.8_2026-10-04.md` — Modelo≈`Hy3` @ Logs/1265-m132-reverify-21.8_2026-10-04.md:1; Plataforma≈`WorkBuddy` @ Logs/1265-m132-reverify-21.8_2026-10-04.md:1
- `1268-BUG093-subfrente-conversion-gdunit4-headless_2026-10-04_07-30-00.md` — Plataforma≈`WorkBuddy` @ Logs/1268-BUG093-subfrente-conversion-gdunit4-headless_2026-10-04_07-30-00.md:3
- `1269-m39-reverify-21.8_2026-10-04.md` — Modelo≈`Hy3` @ Logs/1269-m39-reverify-21.8_2026-10-04.md:1; Plataforma≈`WorkBuddy` @ Logs/1269-m39-reverify-21.8_2026-10-04.md:1; Fecha≈`2026-10-04` @ Logs/1269-m39-reverify-21.8_2026-10-04.md:3
- `1272-m130-reverify-21.8_2026-10-04.md` — Modelo≈`Hy3` @ Logs/1272-m130-reverify-21.8_2026-10-04.md:1; Plataforma≈`WorkBuddy` @ Logs/1272-m130-reverify-21.8_2026-10-04.md:1
- `1276-m43-reverify-21.8_2026-10-04.md` — Modelo≈`Hy3` @ Logs/1276-m43-reverify-21.8_2026-10-04.md:1; Plataforma≈`WorkBuddy` @ Logs/1276-m43-reverify-21.8_2026-10-04.md:1
- `1290-th2-bloque1-reverify-21.8_2026-10-04.md` — Plataforma≈`WorkBuddy` @ Logs/1290-th2-bloque1-reverify-21.8_2026-10-04.md:4
- `1298-th2-bloque2-reverify-21.8_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1298-th2-bloque2-reverify-21.8_2026-10-05.md:3; Plataforma≈`WorkBuddy` @ Logs/1298-th2-bloque2-reverify-21.8_2026-10-05.md:3
- `1301-th2-bloque3-familia-log866-completa_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1301-th2-bloque3-familia-log866-completa_2026-10-05.md:3; Plataforma≈`WorkBuddy` @ Logs/1301-th2-bloque3-familia-log866-completa_2026-10-05.md:3
- `1303-th4-qa21.8-m126-marketinglegal_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1303-th4-qa21.8-m126-marketinglegal_2026-10-05.md:3; Plataforma≈`WorkBuddy` @ Logs/1303-th4-qa21.8-m126-marketinglegal_2026-10-05.md:3
- `1309-th5-qa21.8-m152-principiosinnegociables_2026-10-05.md` — Modelo≈`Hy3` @ Logs/1309-th5-qa21.8-m152-principiosinnegociables_2026-10-05.md:1; Plataforma≈`WorkBuddy` @ Logs/1309-th5-qa21.8-m152-principiosinnegociables_2026-10-05.md:7; Fecha≈`2026-10-05` @ Logs/1309-th5-qa21.8-m152-principiosinnegociables_2026-10-05.md:3
- `1351-th6-qa21.8-cola-log867-m89-m26-m91-m161_2026-10-05.md` — Modelo≈`hy3` @ Logs/1351-th6-qa21.8-cola-log867-m89-m26-m91-m161_2026-10-05.md:3; Plataforma≈`WorkBuddy` @ Logs/1351-th6-qa21.8-cola-log867-m89-m26-m91-m161_2026-10-05.md:3
- `1361-m88-qa21-8-verificacion_2026-10-06_03-44-02.md` — Plataforma≈`WorkBuddy` @ Logs/1361-m88-qa21-8-verificacion_2026-10-06_03-44-02.md:3
- `1374-m150-qa21-8-verificacion_2026-10-06_16-30-00.md` — Modelo≈`hy3` @ Logs/1374-m150-qa21-8-verificacion_2026-10-06_16-30-00.md:4; Plataforma≈`WorkBuddy` @ Logs/1374-m150-qa21-8-verificacion_2026-10-06_16-30-00.md:4
- `1378-M59-cola-bug108-restore-inventario-robusto_2026-10-06_16-45-45.md` — Modelo≈`Modelo:` @ Logs/1378-M59-cola-bug108-restore-inventario-robusto_2026-10-06_16-45-45.md:3; Plataforma≈`Plataforma` @ Logs/1378-M59-cola-bug108-restore-inventario-robusto_2026-10-06_16-45-45.md:4; Fecha≈`2026-10-06` @ Logs/1378-M59-cola-bug108-restore-inventario-robusto_2026-10-06_16-45-45.md:5
- `1380-M59-cola-bug109-cap-tamano-lectura-save_2026-10-06_16-52-46.md` — Modelo≈`Modelo:` @ Logs/1380-M59-cola-bug109-cap-tamano-lectura-save_2026-10-06_16-52-46.md:3; Plataforma≈`Plataforma` @ Logs/1380-M59-cola-bug109-cap-tamano-lectura-save_2026-10-06_16-52-46.md:4; Fecha≈`2026-10-06` @ Logs/1380-M59-cola-bug109-cap-tamano-lectura-save_2026-10-06_16-52-46.md:5
- `1381-M59-cola-bug110-recuperacion-todas-rotaciones_2026-10-06_16-57-00.md` — Modelo≈`Modelo:` @ Logs/1381-M59-cola-bug110-recuperacion-todas-rotaciones_2026-10-06_16-57-00.md:3; Plataforma≈`Plataforma` @ Logs/1381-M59-cola-bug110-recuperacion-todas-rotaciones_2026-10-06_16-57-00.md:4; Fecha≈`2026-10-06` @ Logs/1381-M59-cola-bug110-recuperacion-todas-rotaciones_2026-10-06_16-57-00.md:5
- `1382-M59-cola-bug112-113-114-115-grupo-trivial_2026-10-06_17-05-10.md` — Modelo≈`Modelo:` @ Logs/1382-M59-cola-bug112-113-114-115-grupo-trivial_2026-10-06_17-05-10.md:3; Plataforma≈`Plataforma` @ Logs/1382-M59-cola-bug112-113-114-115-grupo-trivial_2026-10-06_17-05-10.md:4; Fecha≈`2026-10-06` @ Logs/1382-M59-cola-bug112-113-114-115-grupo-trivial_2026-10-06_17-05-10.md:5
- `1397-M59-BUG115-hmac-validacion-no-vacua_2026-10-06_21-39-49.md` — Modelo≈`Modelo:` @ Logs/1397-M59-BUG115-hmac-validacion-no-vacua_2026-10-06_21-39-49.md:3; Plataforma≈`WorkBuddy` @ Logs/1397-M59-BUG115-hmac-validacion-no-vacua_2026-10-06_21-39-49.md:3; Fecha≈`2026-10-06` @ Logs/1397-M59-BUG115-hmac-validacion-no-vacua_2026-10-06_21-39-49.md:4
- `1402-M24-PLAN-ITER1-PUSH-NOOP-HALLAZGO-DRIFT_2026-10-06_22-45-00.md` — Modelo≈`DeepSeek` @ Logs/1402-M24-PLAN-ITER1-PUSH-NOOP-HALLAZGO-DRIFT_2026-10-06_22-45-00.md:4; Plataforma≈`WorkBuddy` @ Logs/1402-M24-PLAN-ITER1-PUSH-NOOP-HALLAZGO-DRIFT_2026-10-06_22-45-00.md:4
- `1407-M24-Iter1-PuzzleDef-Datos-DRIVEN_2026-10-06_23-50-15.md` — Modelo≈`DeepSeek` @ Logs/1407-M24-Iter1-PuzzleDef-Datos-DRIVEN_2026-10-06_23-50-15.md:4; Plataforma≈`WorkBuddy` @ Logs/1407-M24-Iter1-PuzzleDef-Datos-DRIVEN_2026-10-06_23-50-15.md:4
- `1415-M24-Iter2-Framework-Docs-Multilateral_2026-10-07_02-25-07.md` — Modelo≈`DeepSeek` @ Logs/1415-M24-Iter2-Framework-Docs-Multilateral_2026-10-07_02-25-07.md:4; Plataforma≈`WorkBuddy` @ Logs/1415-M24-Iter2-Framework-Docs-Multilateral_2026-10-07_02-25-07.md:4
- `1420-M24-Push-Autorizado-NOOP-Huella-4-3-Plan-Iter3_2026-10-07_03-31.md` — Modelo≈`DeepSeek` @ Logs/1420-M24-Push-Autorizado-NOOP-Huella-4-3-Plan-Iter3_2026-10-07_03-31.md:4; Plataforma≈`WorkBuddy` @ Logs/1420-M24-Push-Autorizado-NOOP-Huella-4-3-Plan-Iter3_2026-10-07_03-31.md:4
- `1426-M24-Iter3-Bloques-Testings_2026-10-07_03-56.md` — Modelo≈`DeepSeek` @ Logs/1426-M24-Iter3-Bloques-Testings_2026-10-07_03-56.md:4; Plataforma≈`WorkBuddy` @ Logs/1426-M24-Iter3-Bloques-Testings_2026-10-07_03-56.md:4
- `1431-M24-Iter4-Gate-Luz-Espejos_2026-10-07_18-41.md` — Modelo≈`DeepSeek` @ Logs/1431-M24-Iter4-Gate-Luz-Espejos_2026-10-07_18-41.md:4; Plataforma≈`WorkBuddy` @ Logs/1431-M24-Iter4-Gate-Luz-Espejos_2026-10-07_18-41.md:4
- `1438-M24-Iter5-Agua-Hielo-Gravedad-Sonido-Pistas-Gate_2026-10-07_21-20.md` — Modelo≈`DeepSeek` @ Logs/1438-M24-Iter5-Agua-Hielo-Gravedad-Sonido-Pistas-Gate_2026-10-07_21-20.md:4; Plataforma≈`WorkBuddy` @ Logs/1438-M24-Iter5-Agua-Hielo-Gravedad-Sonido-Pistas-Gate_2026-10-07_21-20.md:4
- `1473-m118-bug122-gemelo-quality-yml-m105-familiab_2026-10-08_17-19-25.md` — Modelo≈`DeepSeek` @ Logs/1473-m118-bug122-gemelo-quality-yml-m105-familiab_2026-10-08_17-19-25.md:1; Plataforma≈`Plataforma` @ Logs/1473-m118-bug122-gemelo-quality-yml-m105-familiab_2026-10-08_17-19-25.md:5; Fecha≈`2026-10-08` @ Logs/1473-m118-bug122-gemelo-quality-yml-m105-familiab_2026-10-08_17-19-25.md:3
- `1490-barrido-pisos-96-suites-sin-evidencia-m155-fix_2026-10-08_20-37-30.md` — Modelo≈`DeepSeek` @ Logs/1490-barrido-pisos-96-suites-sin-evidencia-m155-fix_2026-10-08_20-37-30.md:3; Plataforma≈`WorkBuddy` @ Logs/1490-barrido-pisos-96-suites-sin-evidencia-m155-fix_2026-10-08_20-37-30.md:3
- `1495-lote1-27-suites-sin-dueno-instrumentadas-3-capas_2026-10-08_21-51-17.md` — Modelo≈`DeepSeek` @ Logs/1495-lote1-27-suites-sin-dueno-instrumentadas-3-capas_2026-10-08_21-51-17.md:3; Plataforma≈`WorkBuddy` @ Logs/1495-lote1-27-suites-sin-dueno-instrumentadas-3-capas_2026-10-08_21-51-17.md:3
- `1501-lote2-24-suites-propias-instrumentadas-3-capas_2026-10-08_23-14-17.md` — Modelo≈`DeepSeek` @ Logs/1501-lote2-24-suites-propias-instrumentadas-3-capas_2026-10-08_23-14-17.md:3; Plataforma≈`WorkBuddy` @ Logs/1501-lote2-24-suites-propias-instrumentadas-3-capas_2026-10-08_23-14-17.md:3
- … y 189 más (misma clase)

### Lagunas reales — por dueño inferido del nombre

**hy3** (19)
- `Logs/1472-hy3-barrido-familia-a-bug070_2026-10-08_16-59-25.md` — sin evidencia de: Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/1645-hy3-m51-m58-reqa218_2026-10-11_03-56-25.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/1871-hy3-m141-m52-muestreo-patron-d_2026-10-15_20-19-27.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2139-hy3-m77-encuesta-anticipo_2026-10-22_19-44-05.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2140-hy3-m151-encuesta-anticipo_2026-10-22_19-44-05.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2149-hy3-cross-qa-m87-localizacion_2026-10-23_01-23-59.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2241-hy3-gate2-runtime_2026-10-29_00-00-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2242-hy3-gate2-runtime_2026-10-29_00-00-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2243-hy3-gate2-runtime_2026-10-29_00-00-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2244-hy3-gate2-runtime_2026-10-29_00-00-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2324-hy3-m16-encuesta_2026-11-06_01-07-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2373-Hy3-TANDA-9nov-QA-cross_2026-11-08_04-35-22.md` — sin evidencia de: Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2384-hy3-tanda12nov-reqa-cascada_2026-11-09_09-30-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2386-hy3-rama2-bloque-c-tanda12nov_2026-11-09_19-27-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2388-hy3-rama1-procesar-539-540-saneo-m62-m51-m163-muestreo_2026-11-09_19-57-45.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2389-hy3-rama1-acuse-542-tanda13-breve_2026-11-09_20-08-17.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2391-hy3-rama1-procesar-543-545-tanda13_2026-11-09_20-36-30.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/2411-hy3-qa-tanda17nov-medido_2026-11-13_15-45-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2413-hy3-qa-tanda18nov-medido_2026-11-13_16-00-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)

**hy4** (2)
- `Logs/2306-HY4-REINGRESO-Y-REGRESION-GATE-BOM_2026-11-04_04-38-59.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2311-HY4-B10-COLUMNA-ROTA-M25-AUTORIA-HEADLESS_2026-11-04_18-43-24.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)

**sin dueño en el nombre** (62)
- `Logs/1371-m151-qa21-8-verificacion_2026-10-06_15-36-16.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/1373-m153-qa21-8-verificacion_2026-10-06_16-22-14.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/171-Implementacion-M38-Economia-Nucleo_2026-08-26.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/173-Implementacion-M20-Amistad-Nucleo_2026-08-26.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/174-Implementacion-M29-GameClock_2026-08-26.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/2016-M62-Ciclos-Cero-Y-Aviso-FALLO-CI_2026-10-19_02-14-41.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2024-tqa09-m78-verif_2026-10-19_22-41-30.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2081-qa-cruzado-m159-b2-300-300_2026-10-21_16-04-55.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2087-bloque-c53-m60-roundtrip_2026-10-21_19-17-42.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2114-m67-tanda4-mejoras-niveles_2026-10-22_03-04-05.md` — sin evidencia de: Fecha (campos marcados: Plataforma, Fecha)
- `Logs/2117-m23-iter6-lugares_2026-10-22_04-22-44.md` — sin evidencia de: Fecha (campos marcados: Plataforma, Fecha)
- `Logs/2125-m23-iter7-ruinas_2026-10-22_06-13-33.md` — sin evidencia de: Fecha (campos marcados: Plataforma, Fecha)
- `Logs/2130-m102-consolidacion-entradas-duplicadas_2026-10-22_13-21-43.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2170-realineacion-global-iter12_2026-10-24_17-38-37.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/219-M112-testing-automatico-avance-2026-08-28.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/224-renumeracion-logs-duplicados_2026-08-28_23-45-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2294-M01-B3-Filas-Global-Etiqueta-Vs-Atraso_2026-11-01_17-59-32.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2298-verif-backlogs-checklists_2026-11-01_20-45-58.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2302-m110-refactor-exporter-commands-panelbase_2026-11-01_23-52-00.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/231-M166-QA-Visual-Correcciones-Post-Fix-2026-08-29_06-30-00.md` — sin evidencia de: Modelo (campos marcados: Modelo, Plataforma)
- `Logs/2329-encuesta-m77-online-rama2_2026-11-06_01-24-10.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/233-M166-Tier-ALTA-Mergeada-Fix-Palanca-2026-08-29_14-15-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/234-M166-Promocion-Frontera-Concha-Muelle-2026-08-29_15-50-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2346-m37-m64-bugmouse-verificacion_2026-11-06_19-24-45.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/2370-regression-m21-m162-dialogos_2026-11-08_01-59-50.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/2424-tanda21nov-qa-13mods_2026-11-15_04-09-16.md` — sin evidencia de: Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/247-M166-Creacion-Puente-Troncos_2026-08-29_22-33-38.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/248-M166-Rediseno-Palanca-Madera_2026-08-29_23-05-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/252-M166-Cierre-Pendientes-Presupuesto-Pipeline-Godot_2026-08-30_00-15-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/273-M166-Modulo-Variantes-Perfil-Rendimiento-2026-08-28_21-30-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/274-M166-Procesamiento-Lote-41-Assets-2026-08-28_21-55-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/275-M166-QA-Visual-13-Herramientas-2026-08-28_22-50-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/276-M166-Re-QA-Visual-13-Herramientas-2026-08-29_00-36-44.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/277-M166-Auditoria-Numerica-82-Variantes-2026-08-29_04-13-16.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/279-M166-Rotacion-Herramientas-Fix-Capturas_2026-08-29_15-20-35.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/280-M166-Tier-D-Cuerda-Antorcha-Pared_2026-08-29_17-55-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/281-M166-Antorcha-Pared-v2-Fix-Placa-Flotando_2026-08-29_18-25-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/283-M166-Fix-Separacion-Herramientas-Mano_2026-08-29_19-35-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/284-M166-Auditoria-E27-7-Assets_2026-08-29_19-55-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/285-M166-Creacion-Puente-Cuerda_2026-08-29_21-12-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/286-M166-Creacion-Pozo-Piedra_2026-08-29_21-37-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/287-M166-Creacion-Vieira-Playa_2026-08-29_20-51-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/290-Cierre-Doc-Pendientes-Sin-Vision_2026-08-30_01-45-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/297-M21-Consumo-gift-given-M20_2026-08-30.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/298-M21-L82-eventos-dialogo-M53-reaccion_2026-08-30.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/299-M21-retrato-grafico-expresion_2026-08-30.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/300-M21-reaccion-nivel-DialogGraphValidator_2026-08-30.md` — sin evidencia de: Plataforma (campos marcados: Plataforma)
- `Logs/301-M166-QA-Visual-Barrido-BAJA-Completo_2026-08-31_01-10-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/342-M166-QA-Fix-E50-Domo-VetaHierro-VetaOro_2026-08-31_03-30-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/344-M166-QA-Fix-E50-RocaComun-RocaPedernal_2026-08-31_03-55-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/425-M80-Legal-Privacidad-Nucleo-Iter1_2026-09-02_02-20-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/433-M126-Marketing-Legal-Nucleo-Iter1_2026-09-02_03-40-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/491-M01-Fundamentos-Del-Proyecto-Nucleo-Iter1_2026-09-02_04-50-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/509-M101-QA-General-Iter1_2026-09-02_05-25-00.md` — sin evidencia de: Modelo, Plataforma (campos marcados: Modelo, Plataforma)
- `Logs/511-M110-Debug-Menu-Nucleo-Iter1_2026-09-02_05-35-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/512-M116-Instalador-Nucleo-Iter1_2026-09-02_05-45-00.md` — sin evidencia de: Modelo, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/514-M54-Mapa-Nucleo-Iter1_2026-09-02_06-00-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/516-M87-Localizacion-Nucleo-Iter1_2026-09-02_06-15-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/523-M103-Logging-Verificacion-Liberacion_2026-09-02_06-30-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/524-M104-Analytics-Verificacion-Liberacion_2026-09-02_06-45-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/526-M115-Hardware-Nucleo-Iter1_2026-09-02_07-05-00.md` — sin evidencia de: Modelo, Fecha (campos marcados: Modelo, Plataforma, Fecha)
- `Logs/578-M130-Artbook-Nucleo-Iter1_2026-09-02_04-20-00.md` — sin evidencia de: Modelo, Plataforma, Fecha (campos marcados: Modelo, Plataforma, Fecha)

## Límites

- No borré ni edité ningún `.po`, JSON, `.tres`, log ni documento ajeno.
- `DINAMICO_POSIBLE` es hipótesis: requiere leer el call site; no lo cuento como recover.
- La inferencia de dueño por nombre de archivo es orientativa, no autoritativa.
- Sin commits ni push.

**Firma:** hy4-flash
