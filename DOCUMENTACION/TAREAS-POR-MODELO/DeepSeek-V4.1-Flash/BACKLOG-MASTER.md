**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# BACKLOG MASTER — DeepSeek-V4.1-Flash (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]` / `[?]` de los `05-Checklist.md` de los 28 módulos cuyo **Recom** en `CHECKLIST-GLOBAL.md` es de la familia DeepSeek (`DeepSeek`, `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp` — descatalogados y ruteados a V4.1 Flash, ver `10-GUIA-COMPARATIVA-MODELOS.md` §5.B3/§17).

> **Curación 2026-09-11 (v2):** la v1 era un **volcado mecánico ordenado por la fila de `CHECKLIST-GLOBAL.md`** — 2.192 tareas mezcladas sin criterio de capacidad. Esta v2 las **reordena por encaje real** con mis fortalezas declaradas (§5.B3): *uso agéntico de herramientas, concurrencia/hilos, IO de archivos, serialización y saves, tests headless, bugs de lógica, datos estructurados, tooling/CLI/empaquetado, validación y sandboxing*. Debilidades que **excluyen** tareas: razonamiento puro de diseño, horizonte largo en terminal, **visión de muestra pequeña (NO soy aprobador visual final)**.

**Módulos asignados:** 28 (M103 Logging reclamado §21.4.7 el 2026-09-15) · **Tareas propias pendientes:** 2.204 (2.192 de la curación 2026-09-11 + 12 de M103) · **Libres ahora:** 1.563 · **En manos de otro agente:** 629
**Núcleo de especialidad (encaje ALTO, verificable headless):** 302 tareas nombradas en módulos libres

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Criterio de encaje (3 niveles)

| Nivel | Qué es | Mi rol |
|-------|--------|--------|
| **A — Núcleo de especialidad** | Código, infra, datos, IO, serialización, tests headless, tooling, validación | **Ejecuto de punta a punta** (código + test + log) |
| **B — Sistemas con criterio de diseño** | Sistemas de gameplay con lógica + decisión de diseño; documentación técnica | Ejecuto la **parte técnica/verificable**; la decisión de diseño la dejo anotada `[?]` con dueño |
| **C — Visual / arte / audio / contenido** | Animación, VFX, arte, marketing, narrativa, música | **NO soy aprobador visual.** Puedo hacer el *plumbing* data-driven (catálogo, `.tres`, validador) pero la aprobación final es de otro especialista / visión del usuario |

---

## Nivel A — Núcleo de especialidad (tomar primero)

Ordenados por encaje, no por fila global.

| # | ID | Módulo | Estado | Progreso | Encaje-A / pend. propias | Por qué encaja | Subcarpeta |
|---|----|--------|--------|----------|--------------------------|----------------|------------|
| A1 | 60 | 60-Datos-Y-Serializacion | 🟡 Liberado (iter. 4 ✅) | 188/196 | 4 / 4 | **Serialización, IO, checksum, migración de schema, compresión ZIP.** Mi fortaleza #1. iter. 4 (Log 916): re-verificación **selectiva** tras la reversión total de la auditoría del 2026-09-14 (que había dejado en 0/196 también mis `[x]` con test headless). 3 suites **378/0 ×3**, 0 `SCRIPT ERROR`, guardián anti-falso-verde probado por inyección. 8 defectos reales corregidos + **BUG-041** (M103) reportado y **reclasificado a falso positivo** con sonda aislada | `60-Datos-Y-Serializacion/checklist.md` |
| A2 | 68 | 68-Transporte-Y-Navegacion | 🟡 Liberado (iter. 2 ✅) | 70/131 | 14 / 47 | Grafo `.tres`, API, eventos, dijkstra, persistencia de waypoints: **data-driven + headless**. iter. 2 (Log 910): planificador de viaje (7 fases, cozy <4 s, orientación, regla «nunca perder al jugador»), viajes especiales M74/M31, narrativos M22/M23, eventos de ruta, puente M69, localización 12h/24h y validador unificado. Test **199/0** ×3 (iter. 1: 177/0) → **376/0** | `68-Transporte-Y-Navegacion/checklist.md` |
| A3 | 87 | 87-Localizacion | 🟡 Liberado (iter. 5 ✅) | 120/136 | 0 / 16 | Pipeline i18n/gettext, convención de claves, cache, validador `.po`. **Reclamado §21.4.7.** iter. 5 (Log 874): `ValidadorPO` + `AuditorClaves` + 5/5 suites green; los 16 pendientes son UI/visión/arte/decisión | `87-Localizacion/checklist.md` |
| A4 | 116 | 116-Instalador | 🟡 Liberado (iter. 2 ✅) | 182/198 | 6 / 10 | Build/empaquetado, permisos, rollback, firma digital, update. **Tooling puro**. iter. 2 (Log 877): corregido sobre-cierre de iter. 1 (43 `[ ]` ocultos; setup/uninstall `.ps1` = 3 bytes solo BOM); 11 artefactos reales + preset Windows (desbloquea P0 M117) + `ValidadorInstalador` (V1-V11) + test 15/0. | `116-Instalador/checklist.md` |
| A5 | 27 | 27-Islas-Del-Mundo | 🟡 Liberado (iter. 2 ✅) | 99/192 | 93 / 0 | Núcleo data-driven del archipiélago 1+12 (`IslandRing` + `IslandDefinition` + `Archipielago` + `IslandRegistry` + `IslandProps` + 13 `.tres`, test **171/0**). iter. 2 (Log 912): los **16 `[ ]` propios** cerrados → **99/192**. **K** (9 edge cases): `IslandOps` (cola de operaciones con prioridad viaje>carga>descarga>precarga, etapas 60/25/10/5, idempotencia, UNA sola en curso) + `IslandTravelGuard` (precarga sin congelar, viaje con descarga en curso —se **encola**, no se cancela—, náufrago, ancla pendiente con espera coherente, punto seguro de desembarco, cancelación limpia por destino, guardado que espera, respawn cozy, descarga forzada LRU sin perder el estado de M59). **A** (4): `IslandDesignCatalog` con los **26** puntos reales de la §26 (el checklist decía 24; el plan tiene 26 → el desajuste se **reporta**, no se acepta). Test `test_islas_m27_iter2.gd` **238/0 ×3**, guardián anti-falso-verde **probado** (aborto inyectado → 238→210 y nombra el bloque). Cableado en `quality.yml`. Los 93 `[?]` siguen ajenos (M63/M61, M10, M54, M50/M36/M15/M23/M19, M28) | `27-Islas-Del-Mundo/checklist.md` |
| A6 | 101 | 101-QA-General | ✅ Completado (QA cruzado ✅) | 209/209 | 0 / 0 | **Verificado (Log 878):** 19 archivos de `04-Codigo.md` presentes, `test_qa_m101.gd` 12/0, UTF-8 sin BOM. 2 ítems DoD gate M137 = KnownIssue. Verificación = mi terreno | `101-QA-General/checklist.md` |
| A7 | 123 | 123-Modding | 🟡 Liberado (iter. 2 ✅) | 101/108 | 0 / 7 | **Verificado (Log 879):** `ModSandbox` (path traversal + esquema M108), códigos E01-E14, `validar_paquete`, `resolver_prioridad`, `es_compatible_update` (M118). Test **69/0 ×3**. 7 pendientes = producto / UI M89 / Steam M97 / meta | `123-Modding/checklist.md` |
| A8 | 52 | 52-Particulas-Y-VFX | 🟡 Liberado (iter. 5 ✅) | 78/139 | 9 / 52 | **Hecho (Log 882):** pooling T-027, precalentamiento T-029, determinismo T-093, límites de rendimiento y log `VFX-SKIP`; + **bug real** (`crear()` asignaba `GPUParticles3D.mesh`, eliminada en 4.3 → `null` silencioso, no instanciaba nada). Test **89/0 ×3**. Queda: catálogo 8/25, loops/LOD, `vfx_trigger`, atmosféricos, UI M53 y calibración visual | `52-Particulas-Y-VFX/checklist.md` |
| A9 | 148 | 148-Lore-Ambiental | 🟡 Liberado | 23/117 | 23 / 94 | **Parte de DATOS hecha (Log 881):** gate de CI (IDs duplicados/canon vacío/cobertura/grafo), grafo de pistas real, persistencia + migración. Queda **contenido** (4/6 islas, 16/30 pistas), trigger 3D y UI de diario | `148-Lore-Ambiental/checklist.md` |
| A10 | 105 | 105-Telemetria-De-Gameplay | 🟡 Liberado (iter. 6) | 157/163 | 1 / 6 | Módulo **cerrado por mí**; quedan 6 `[?]` con dueño externo (datos reales, hooks M22, integración M102) | `105-Telemetria-De-Gameplay/checklist.md` |
| A11 | 124 | 124-Contenido-Generado-Por-Usuarios | 🟡 Liberado (iter. 2 ✅) | 81/106 | 0 / 25 | **Hecho (Log 905):** `UgcLimits` (RF13 por ítem y por cuota), `UgcSanitizer` (4K→2K, sin coords del save, ZSTD), `UgcTelemetry` (sin PII, export M104). Tests **101 checks** (85/0 ×3 + 16/0 ×2). Hallazgos: `PackedByteArray.compress/decompress` roto en 4.7.2, warnings=errores, aborto silencioso cuelga el SceneTree. Queda: servicio/infra/UI M89/legal/proceso (25 `[?]`) + QA §21.8 | `124-Contenido-Generado-Por-Usuarios/checklist.md` |
| A12 | 26 | 26-Templo-Subterraneo | 🟡 Liberado (iter. 2 ✅) | 50/115 | 0 / 65 | **Hecho (Log 902):** guardado atómico por checkpoint (`templo_checkpoint.gd`), gating de 7 anillos + sellos, suites de softlock/anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles (export JSON a M24). Test **92/0 ×4**. Queda: diseño de salas/ambientación (otro especialista) + QA cruzado §21.8 | `26-Templo-Subterraneo/checklist.md` |

## Nivel B — Sistemas con lógica + criterio de diseño

| # | ID | Módulo | Estado | Progreso | Pend. propias | Nota de encaje |
|---|----|--------|--------|----------|---------------|----------------|
| B1 | 03 | 03-Documentacion-Del-Proyecto | 🟢 Disponible | 0/133 | 133 | Documentación técnica del repo (estructura, `.gitignore`, scripts de automatización): **verificable contra disco** |
| B2 | 94 | 94-Retencion-Sin-FOMO | 🟡 Con dudas | 65/113 | 41 | Reglas de diseño + migración v3.1→v3.2 y ausencia de telemetría manipuladora (parte técnica) |
| B3 | 120 | 120-DLC-Y-Expansiones | 🟢 Disponible | 6/222 | 59 | Estrategia + compatibilidad de saves entre DLC (parte técnica: versionado) |
| B4 | 02 | 02-Vision-Y-Concepto | 🟢 Disponible | 0/172 | 172 | Pilares/pitch/posicionamiento → **criterio de diseño, no mi fuerte**; derivar requisitos técnicos sí |
| B5 | 01 | 01-Fundamentos-Del-Proyecto | 🟢 Disponible | 0/152 | 152 | ⚠️ **Su checklist personal está corrupta**: `T-001..T-152` son una línea por módulo del plan maestro (dump del índice), no tareas de M01. Ver "Anomalías" |

## Nivel C — Visual / arte / audio / contenido (NO aprobador visual)

| # | ID | Módulo | Estado | Progreso | Pend. propias | Qué puedo hacer yo / qué no |
|---|----|--------|--------|----------|---------------|-----------------------------|
| C1 | 99 | 99-Marketing | 🟢 Disponible | 3/169 | 162 | Puedo: estructura de sitio, export PNG/SVG, traducción del sitio (M87). **No**: moodboard, paleta, identidad visual |
| C2 | 98 | 98-Trailer | 🟢 Disponible | 1/102 | 98 | Puedo: export H.264/WebM, compresión por plataforma. **No**: montaje, encuadre, plano a plano |
| C3 | 52 | 52-Particulas-Y-VFX | 🟡 Con dudas | 21/130 | (ver A8) | Los 25 efectos y su look: **otro especialista** |
| C4 | 26 | 26-Templo-Subterraneo | 🟡 Con dudas | 50/115 | (ver A12) | Diseño de salas, pórticos, ambientación: **otro especialista** |
| C5 | 120 | 120-DLC-Y-Expansiones | 🟢 Disponible | 6/222 | (ver B3) | "Diseñar nuevas ruinas / bundle / marketing": **otro especialista** |

## NO TOCAR — módulos con agente activo (regla §21.4)

| ID | Módulo | Dueño actual | Progreso | Pend. propias |
|----|--------|--------------|----------|---------------|
| 48 | 48-Animacion | glm-5.3-flash | 8/123 | 114 |
| 63 | 63-Cargas-Y-Streaming | glm-5.3-flash | 16/101 | 85 |
| 65 | 65-Animales-IA | glm-5.3-flash | 84/89 | 5 |
| 75 | 75-Postgame | glm-5.3-flash | 14/130 | 113 |
| 95 | 95-Monetizacion | glm-5.3-flash | 24/108 | 94 |
| 156 | 156-Terrenos-Y-Movimiento | glm-5.3-flash (Kilo Code) | 199/302 | 101 |
| 159 | 159-Catalogo-De-Objetos | ox-alpha | 69/146 | 77 |
| 162 | 162-Dialogos-Contextuales-De-NPCs | glm-5.3-flash (fix BUG-012) | 84/120 | 40 |

> Reclamo solo por **§21.4.7** (reserva >24 h de un agente inactivo/descatalogado) y dejando nota en `Mensajes entre modelos/ESTADO-PARALELO.md`. M87 es el único candidato claro de relevo (dueño `deepseek-v4-flash`, descatalogado el 2026-09-10).

---

## Cola de trabajo inmediata (tareas nombradas, encaje ALTO)

Primeras ~30 tareas que tomo por orden de encaje, todas en módulos libres:

| Orden | Módulo | Tarea | Qué es | Por qué yo |
|-------|--------|-------|--------|-----------|
| 1 | 60 | T-018 | RF3: serialización de construcciones y casas (M17/M18) | Serialización pura |
| 2 | 60 | T-019 | RF3: serialización de fauna y vecinos (M36/M19) | Serialización pura |
| 3 | 60 | T-145 | Recetas y cultivos como Resources tipados (`.tres` M16/M33) | Datos estructurados |
| 4 | 68 | T-017 | `transport_network.tres` como única fuente de verdad | Dataset + contrato |
| 5 | 68 | T-002 | Cargar el grafo de paradas/rutas desde el `.tres` | IO + parser |
| 6 | 68 | T-003 | Exponer API `list_routes`/`buy_ticket` a la UI (M53) | API/contrato |
| 7 | 68 | T-020 | Testear el grafo con ruta corta (dijkstra, orden de paradas) | Test headless |
| 8 | 68 | T-049 | Persistencia de waypoints (M59) | Save/IO |
| 9 | 27 | T-011 | `IslandDefinition` como Resource con `@export` de metadatos | Datos tipados |
| 10 | 27 | T-030 | 12 `.tres`, uno por satélite | Dataset |
| 11 | 27 | T-041 | Registro sin duplicados: ids únicos al cargar `.tres` | Validación |
| 12 | 27 | T-045 | Fallback: si falta un `.tres` → ERROR + Aurora siempre carga | Robustez |
| 13 | 27 | T-036 | `posicion_ancla(id)` con cache de M10 | Cache/logic |
| 14 | 87 | T-050 | Convención de claves `MODULO.SECCION.CLAVE` | Tooling i18n |
| 15 | 87 | T-044 | Compatibilidad de los `.po` con Poedit/gettext | Validador |
| 16 | 87 | T-058 | Cache de traducciones frecuentes | Optimización |
| 17 | 116 | T-002 | Crear instalador | Tooling/packaging |
| 18 | 116 | T-014 | Validar rollback | Robustez |
| 19 | 116 | T-070 | Firma digital del instalador (.exe/.msi) | Seguridad |
| 20 | 116 | T-078 | Detectar versión instalada | Lógica/IO |
| 21 | 123 | T-022 | Esquema data idéntico al de M108 | Contrato de datos |
| 22 | 148 | T-009 | Gate de CI ante IDs duplicados o `canonRef` vacío | CI + validación |
| 23 | 148 | T-090 | Migración v3.1 para saves sin el campo | Migración de schema |
| 24 | 148 | T-109 | Tests de trigger/persistencia en PlayMode | Test |
| 25 | 52 | T-027 | Pool de emisores one-shot prestados/liberados | Pooling |
| 26 | 52 | T-029 | Precalentamiento del pool (8 emisores) | Precalentamiento |
| 27 | 52 | T-093 | Riesgo de determinismo roto → semillas + validador | Determinismo/test |
| 28 | 26 | T-053 ✅ | Guardado atómico en cada checkpoint (Log 902) | Save atómico |
| 29 | 26 | T-084 ✅ | Testear softlocks por zona (suite M66) — Log 902 | Suite de tests |
| 30 | 101 | — | QA cruzado §21.8 del módulo + cierre formal de "Con dudas" | Verificación |

---

## Vectores de expansión (candidatos, NO reclamar sin relevo)

Módulos cuyo **Recom no me nombra** pero cuya materia es 100 % mi especialidad (infra/tooling/validación). Solo se toman si el dueño libera o cae en §21.4.7, y con nota en `ESTADO-PARALELO.md`:

| ID | Módulo | Recom actual | Por qué encajaría |
|----|--------|--------------|-------------------|
| 117 | 117-Build-System | Step 3.7 Flash | Build/empaquetado = tooling |
| 118 | 118-CI-CD | — (glm-5.3-flash, iter. 3) | Pipelines = automatización |
| 122 | 122-Crash-Reporting | Step 3.7 Flash | Captura/parseo de crashes = IO + robustez |
| 108 | 108-Pipeline-De-Assets | Step 3.7 Flash | Pipeline de datos |
| 109 | 109-Herramientas-Internas | Step 3.7 Flash | Tooling interno |
| 110 | 110-Debug-Menu | agnes-2.5-flash | Menú de debug = tooling |
| 113 | 113-Pruebas-De-Stress | agnes-2.5-flash | Stress/headless = mi terreno |
| 61 | 61-Rendimiento | agnes-2.5-flash | Medición/benchmark headless |
| 62 | 62-Memoria | (Recom corrupto: `3`) | Pool/leaks = concurrencia + IO |

---

## Anomalías detectadas en la auditoría (2026-09-11)

1. **M01 — checklist personal corrupta:** sus 152 "tareas" son una línea por módulo del plan maestro (`T-002 **M02** Documentación…`, `T-003 **M03** Game Engine…`). Es un **dump del índice**, no trabajo de M01. Sus 45 "encaje-A" son falsos positivos.
2. **`CHECKLIST-GLOBAL.md` tiene anchos de fila inconsistentes** (12 a 16 celdas; 4 filas con 14, 39 con 15, 15 con 12, 1 con 10). Cualquier parseo por índice de columna es frágil → los datos de esta tabla se extraen **anclando en la celda `N/M` de Progreso**, y la propiedad del módulo se lee de `ESTADO-PARALELO.md`, no de la tabla.
3. **M101 "Con dudas" con 209/209 `[x]`:** no hay pendientes pero el módulo no está cerrado → falta **QA cruzado §21.8 + cierre formal**, no implementación.
4. **M87 sin dueño activo:** su último agente (`deepseek-v4-flash`) fue descatalogado el 2026-09-10 → **relevo legítimo §21.4.7**.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]`/`[?]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo (fuente de verdad).
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso) **y** `Mensajes entre modelos/ESTADO-PARALELO.md`.
4. Ciclo: reservar log → implementar/verificar → test headless 0 fallos → documentar → liberar → siguiente.

---

**v1 creada:** 2026-09-11 por DeepSeek-V4.1-Flash / WorkBuddy
**v2 (curada por encaje):** 2026-09-11 por DeepSeek-V4.1-Flash / WorkBuddy

---

## Historial de ciclos ejecutados

| Ciclo | Módulo | Iter. | Log | Resultado | Estado del módulo |
|-------|--------|-------|-----|-----------|-------------------|
| 1 | 60-Datos-Y-Serializacion | 2 | 825 | RF10 guardado asincrónico (`Thread` + cola prof. 1). Test 94/0 | 🟡 182/196 |
| 2 | 105-Telemetria-De-Gameplay | 6 | 826 | Auditoría de 33 `[ ]` → 27 `[x]` + 6 `[?]`; fix `zone_ignored`. Tests 11/11 · 10/10 · 16/16 | 🟡 157/163 |
| 3 | 60-Datos-Y-Serializacion | 3 | 827 | Construcciones (`EstructurasCodec`+`BuildingsSaveProvider`), backups rotativos, compresión ZIP_DEFLATE, catálogos perezosos, progreso del guardado. Test **132/0**; regresión 94/0. **BUG-025** (M19) | 🟡 **191/196** · 5 `[?]` · 0 `[ ]` |
| 4 | 68-Transporte-Y-Navegacion | 1 | 828 | Reclamado §21.4.7. Núcleo data-driven desde 0: grafo Resource + `TransportManager` + `.tres` (10 paradas/20 rutas) + generador + test **177/0** | 🟡 **36/131** · 10 `[?]` · 85 `[ ]` |
| 5 | 27-Islas-Del-Mundo | 1 | 831 | Reclamado §21.4.7. Archipiélago 1+12 desde 0 (sólo había 4 islas en JSON): `IslandDefinition`/`Archipielago`/`IslandRegistry`/`IslandProps` + 13 `.tres` + generador + test **171/0** (×3). Regresiones: M27 legacy 5/0 · M60 132/0 y 94/0 · M68 177/0 · aliasing OK(9) | 🟡 **83/192** · 93 `[?]` · 16 `[ ]` |
| 6 | 87-Localizacion | 5 | 874 | Reclamado §21.4.7. `ValidadorPO` (R1-R13/P1-P5: BOM §28, CRLF, cabecera gettext, plurales, convención RF20) + `AuditorClaves` (barrido de 702 `.gd`: usadas sin clave, sin uso, prefijos dinámicos) + `test_validador_po_m87.gd` (8 bloques, marcadores `_fin()`). Catálogo 64→85 claves; 7 claves que la UI renderizaba crudas. Bug real de rendimiento: tormenta de `push_warning` (~16 ms c/u) → dedup + `claves_faltantes()`. **Falso verde detectado** (un `SCRIPT ERROR` abortaba el bloque del auditor y el suite igual decía "0 fallos"). 5/5 suites green, 0 SCRIPT ERROR. 10 hallazgos H-1..H-10 documentados | 🟡 **120/136** · 0 `[?]` · 16 `[ ]` |
| 7 | 116-Instalador | 2 | 877 | Reclamado §21.4.7. Corregido sobre-cierre de iter. 1 (43 `[ ]` ocultos; setup/uninstall `.ps1` = 3 bytes solo BOM). Implementados: setup/uninstall `.ps1`, pipeline Inno Setup 6 (5 `.iss`), `code_signing.bat`, `verificar_requisitos.ps1`, `build_installer.bat`, `license.txt` + preset Windows en `export_presets.cfg` (desbloquea P0 de M117). `ValidadorInstalador` (V1-V11) + `test_instalador_m116.gd`: **15/0** (×3). Regresión M117 14/0. | 🟡 **182/198** · 6 `[?]` · 10 `[ ]` |
| 8 | 101-QA-General | — | 878 | QA cruzado §21.8 (no implementación): verificados los 19 archivos de `04-Codigo.md` (no sobre-cerrado), 27 áreas + 173 ítems + 12 EB en `QA-CHECKLIST.md`, `test_qa_m101.gd` **12/0** (×2), UTF-8 sin BOM. Módulo cerrado: "Con dudas" → Completado. | ✅ **209/209** · 2 ítems DoD gate M137 (KnownIssue) |
| 9 | 123-Modding | 2 | 879 | Sobre-cierre corregido (24 `[ ]` reales, no 0) + BOM §28 eliminado. Nuevo `ModSandbox` (path traversal + esquema M108), códigos E01-E14, `validar_paquete`, `resolver_prioridad`, `es_compatible_update` (M118). Test **69/0** (×3). | 🟡 **101/108** · 7 `[ ]` (producto/UI/Steam/meta) |
| 10 | 148-Lore-Ambiental | 2 | 881 | Sobre-cierre corregido (declaraba 114/114 con **99 `[ ]`** reales de 117) + BOM §28 + cifras falsas (68 piezas / islas 18-17-17-16 vs reales 60 / 18-14-14-14) + convención reparada. `04-Codigo.md` describía **Unity/C#** inexistente → reescrito con archivos Godot reales. Nuevo **`LoreGate`** (CI, `exit 1`) cableado en `quality.yml`; **grafo de pistas real** (`consumidores.json`, 18) + `LoreAuditor.validar_grafo()`; **`LoreSaveProvider`** (sección `lore` vía punto de extensión de M59, sin tocar M59) con migración de saves sin el campo. Test **85/0** (×3). 2 bugs reales: `String(x)` no es constructor válido en Godot 4 (abortaba `migrar()` en silencio) y el chequeo de IDs duplicados del auditor era **código muerto**. | 🟡 **23/117** · 2 `[?]` · 92 `[ ]` (contenido/escena/UI) |

| 11 | 52-Particulas-Y-VFX | 5 | 882 | Bug real PREEXISTENTE: `VfxFactory.crear()` asignaba `GPUParticles3D.mesh`, propiedad **eliminada en Godot 4.3** (hoy `draw_pass_1`); el error abortaba la función en silencio, `crear()` devolvía `null` y **no se instanciaba ningún VFX** pese a que los 3 tests previos daban verde (solo probaban funciones puras). Nuevos: `vfx_pool.gd` (`VfxPool`: prestar/liberar/reuso por `id`, `max_emisores`/`max_particulas` con reciclado del más antiguo, `semilla_de()` FNV-1a 32, `validar_semillas()`) y `test_vfx_pool_m52.gd` (**89/0 ×3**, 0 SCRIPT ERROR, 6 bloques con marcador `_fin`; ejercita la **ruta de runtime** que los tests puros nunca tocaban). Reescritos `vfx_director.gd` (sobre el pool) y `vfx_factory.gd` (`nuevo_emisor` + `redisparar`). Determinismo: `restart()` re-aleatoriza `seed` (2694543342→2659173778) → semilla DESPUÉS de `restart()`. **Log `VFX-SKIP` implementado de verdad** (señal `emision_descartada` → `GameLogger`); antes estaba `[x]` sin existir. 3 tests heredados 4/8/4 green → **105 checks M52**; 4 cableados en `quality.yml`. Auditoría de sobre-cierre: 5 `[x]` de RF1 sin entrada en el catálogo → `[?]` (catálogo real 8/25). `04-Codigo.md` describía rutas Unity inexistentes → reescrito. | 🟡 **78/139** · 8 `[?]` · 52 `[ ]` |
| 12 | 26-Templo-Subterraneo | 2 | 902 | Gating real (7 anillos/sellos/glifos + salida bloqueada), validadores anti-exploit/softlock (BFS), **5 checkpoints atómicos** (`templo_checkpoint.gd`: tmp→bak→cp), telemetría de puzzles (export JSON a M24) + 6 suites de validación. `test_templo_m26.gd` **92/0 ×4**, 0 SCRIPT ERROR (7 bloques con marcador `_fin`). **BUG-035 de proyecto:** `backup_manager.gd` (M107) usaba `DirAccess.new()` (clase **abstracta**) → parse error que mataba el autoload y ensuciaba todo run headless; corregido → M107 9/0 ×3. Trampa medida: `DirAccess.open("user://…")` = `null` en headless con `--path` relativo. `04-Codigo.md` describía Unity/C# → reescrito. 2 contradicciones de diseño → `[?]` | 🟡 **50/115** · 8 `[?]` · 57 `[ ]` |
| 13 | 124-Contenido-Generado-Por-Usuarios | 2 | 905 | Reclamo §21.4.7. Parte verificable headless: `UgcLimits` (RF13: por ítem y por cuota, motivo constante + mensaje claro, `consumir()`), `UgcSanitizer` (4K→2K con `Image.resize()` headless, formatos, **blueprint sin coords del save** — sobre sí, contenido de piezas intacto — y compresión ZSTD) y `UgcTelemetry` (alias hasheado FNV-1a, rechazo de PII anidada, reloj inyectable, `exportar_a_m104()`). `test_ugc_m124_iter2.gd` **85/0 ×3** (6 bloques con marcador `_fin` + **watchdog** anti-cuelgue) + regresión iter. 1 **16/0 ×2** = **101 checks**, 0 SCRIPT ERROR. **3 hallazgos reales:** `PackedByteArray.compress()`/`decompress()` no cierran el ciclo en 4.7.2 (33 B → 42 B → **1 B**); los **warnings de GDScript son errores** en este proyecto (un `:=` sobre `Variant` aborta el bloque en silencio); y un aborto silencioso en `_run()` con `call_deferred` **cuelga el SceneTree** para siempre. **Sobre-cierre corregido:** declaraba "106 resueltos, 0 pendientes" con 41 `[ ]` reales → 81 `[x]` / 25 `[?]` / 0 `[ ]`. `04-Codigo.md` describía Unity/C# → reescrito. 2 tests cableados en `quality.yml` (20 tests) | 🟡 **81/106** · 25 `[?]` · 0 `[ ]` |
| 14 | 68-Transporte-Y-Navegacion | 2 | 910 | 7 módulos headless nuevos (`TransportTripPlanner` 7 fases + regla "nunca perder al jugador", `TransportSpecialTrips` 5 festivales M74 reales + luna M31, `TransportNarrativeTrips` sobre `historia_principal.json`, `TransportRouteEvents` sobre NPCs reales, `TransportM69Bridge` regla `max(ceil(b×1.6), b+10)`, `TransportLocalizer` 89 claves ×2 locales, `ValidateTransport` 9 bloques) + 5 integraciones en `TransportManager` + 89 claves aplicadas a los `.po`. Test **199/0** ×3 (`SCRIPT ERROR: 0`); iter. 1 177/0 → **376/0**. **Falso verde por aborto silencioso reproducido** (169 checks / "0 fallos" con un bloque saltado) y **guarda probada con sonda**. Corregido 1 `[x]` optimista de iter. 1 (4 cumplen / 6 violan por diseño / 10 sin alternativa). Hallazgo: M69 y M68 no comparten estaciones (dueño M69). | 🟡 **70/131** · 14 `[?]` · 47 `[ ]` |
| 15 | 27-Islas-Del-Mundo | 2 | 912 | Los **16 `[ ]` propios** cerrados como lógica pura headless. Nuevos: `island_ops.gd` (`IslandOps`: cola de operaciones, 4 etapas con pesos 60/25/10/5, prioridad viaje>carga>descarga>precarga, idempotencia por (tipo, isla), UNA sola en curso, cancelación por id y por isla, `validar()`/`informe()`), `island_travel_guard.gd` (`IslandTravelGuard`: los 9 edge cases K1–K9 sobre una vista de islas por duck-typing — K1 precarga con `MAX_OPS_POR_FRAME == 1` y `no_congela`, K2 el destino en descarga se **encola** en vez de cancelarse, K3 náufrago con salvavidas dentro del radio de seguridad, K4 `ancla_pendiente` con `espera_coherente`, K5 `punto_seguro()` proyectando al interior del disco, K6 `limpio` **por destino**, K7 guardado que espera, K8 respawn cozy, K9 descarga forzada LRU que nunca toca la principal ni la actual) y `island_design_catalog.gd` (`IslandDesignCatalog`: los **26** puntos de la §26 con grupo/estado/resolución, 15 resueltos / 7 declarativos / 4 externos con dueño, `claves_localizacion()` para M87, `validar()` que falla si el plan deja de tener 26 puntos). Test `test_islas_m27_iter2.gd` **238/0 ×3** (`SCRIPT ERROR: 0`), 8 bloques con marcador `_fin` y **guardián anti-falso-verde probado en vivo** (aborto silencioso inyectado en el bloque D → la suite FALLA, nombra el bloque y cae de 238 a 210 checks). Regresiones: iter. 1 **171/0** · legacy **5/0** · `sincronizar_islas_mapa` OK (4 islas + 9 POIs). **2 hallazgos reales:** (a) `registro_desde_definicion()` fijaba `descubierta/visitada` en `false` y `vista_desde_registry()` no leía el registry → la guardia no podía cumplir su promesa de K9; ahora la vista refleja M59 y hay `sincronizar_estado_partida()`; (b) el checklist decía 24 puntos y el plan tiene 26. Sin M10 las 13 islas reales están sin ancla y la guardia reporta `ancla_pendiente` sin crashear. Nadie llama todavía a las 2 clases: el cableado es de M63 y M28. | 🟡 **99/192** · 93 `[?]` · 0 `[ ]` |
| 16 | 60-Datos-Y-Serializacion | 4 | 916 | Re-verificación **selectiva** tras la reversión total de la auditoría del 2026-09-14 (0/196, fila `🟢 Disponible`). **8 defectos reales** corregidos: `borrar_slot` mentía (`true` en slot vacío) y filtraba `mundo_voxel.bin.deflate` + todas las copias `.bak`; no había `.bak` para `mundo_voxel.bin`; no se regeneraba `meta.json` si faltaba; no se logueaba migración ni contrato; no había validación temprana al guardar; el motor de migración era **inalcanzable** (MIGRACIONES vacío con VERSION_ACTUAL=1) → se partió en `migrar_con_cadena(datos, cadena, objetivo)` inyectable + 3 patrones puros (`renombrar_campo`/`eliminar_campo`/`transformar_valor`); no existía `CatalogosEstaticos.validar_ids()`. Suites base **94/0** · iter. 3 **132/0** · iter. 4 **152/0** = **378 checks / 0 fallos ×3**, 0 `SCRIPT ERROR`, exit 0. Guardián anti-falso-verde **probado en vivo** (aborto silencioso inyectado en el bloque D → la suite FALLA, nombra `["D"]`, cae de 152 a 128 checks y sale EXIT 1). Nuevos `06-Plan-Testings.md` y `07-Resultados-Testings.md`. **BUG-041** (M103) reportado y **RECLASIFICADO A FALSO POSITIVO** con sonda aislada: `GameLogger` **sí registra**; el residuo real es `log_buffer` como código muerto (Baja) | 🟡 **188/196** · 4 `[?]` · 4 `[ ]` |
| 17 | 103-Logging | 1 | 918 | **Reclamo §21.4.7** tras la retirada de ox-alpha (Cline) del proyecto (el módulo estaba en `0/183` por la reversión del 2026-09-14). Suite nueva `test_logging_m103_iter1.gd` **131 checks / 0 fallos ×3**, 0 `SCRIPT ERROR`, guardián anti-falso-verde probado por inyección. **7 fixes reales:** `log_buffer` eliminado (código muerto, `_flush()` era no-op) · rotación ahora disparada desde `_log()` con contador `_bytes_written` (antes el archivo podía crecer sin límite) · **JSON con contexto era INVÁLIDO** (faltaba coma ante `context`) · **`export_by_date(hours)` era un no-op** (comparaba en días y su regex exigía espacio, pero Godot emite `T` → devolvía TODO) · `export_by_level`/`export_by_category` ahora entienden JSON · `_json_escape` escapa CR/TAB · `LogRotator.get_size()` devolvía caracteres, no bytes. Convención del checklist reparada (decía `[ ] cumplido · [ ] pendiente`), mojibake eliminado, historial sin checkbox, cifras corregidas a 158 diseño + 21 implementación = 179. Hallazgos: `logger_config.json` huérfano (contradice el `.tres`) · `LogRotator.rotate()` no renombra un archivo abierto (Windows, error silencioso) · **ajeno:** `test_loop_economico.gd` 14/1 por precio de compra (M38, cambios sin commitear de otro agente; NO es regresión de M103). Docs 04/05/06/07 + `quality.yml` | ✅ **167/179** · 12 `[?]` · 0 `[ ]` |
**Regla del ciclo:** bloquear el módulo (reserva en `Logs/reservas/` + `🔵` en el checklist) → leer la documentación → codificar → test headless → documentar (04-Codigo, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO) → escribir el log → borrar la reserva → **siguiente módulo**.

> ⚠️ **Numeración de logs — resincronizar SIEMPRE.** En el ciclo 5 reservé el **830** y GLM-5.3 lo usó en paralelo para M32; hubo que pasar a **831**. Antes de crear un log: `ls Logs/*.md | grep -oE '^[0-9]+' | sort -n | tail` **y** revisar `Logs/reservas/`, porque `ULTIMO_NUMERO.txt` puede quedar desfasado.

**Estado de la cola inmediata (30 tareas):** cerradas las de **M60** (T-018, T-019→`[?]`, T-145→`[?]`), **M68** (T-017, T-002, T-003, T-020, T-049), **M27** (T-001, T-003, T-004, T-005, T-021…T-040, T-121, T-123, T-124, T-171, T-175, T-180, T-183, T-186) **M87** (T-044, T-050, T-051, T-058, T-107, T-108, T-115, T-117 + verificación de T-042/T-123/T-124) y **M116** (T-002 instalador, T-070 firma, T-078 detección de versión + verificación de T-014 rollback; Log 877), **M101** (QA cruzado §21.8, Log 878) y **M148** (T-009 gate de CI, T-090 migración de saves, T-109 tests de persistencia; Log 881) y **M52** (T-027 pooling, T-029 precalentamiento, T-034/T-036 determinismo, T-067/T-072 límites y verificación de presupuesto, T-033 log VFX-SKIP, T-086/T-088/T-089 alternativas descartadas; Log 882) y **M26** (T-053 guardado atómico por checkpoint, T-084 suite de softlocks, gating de 7 anillos + sellos, validadores anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles; Log 902). y **M124** (límites RF13, sanitización 4K→2K + sin coords del save, telemetría sin PII; Log 905). y **M68 iter. 2** (planificador de viaje, viajes especiales/narrativos, eventos de ruta, puente M69, localización 12h/24h y validador unificado; Log 910). **Siguiente en la cola: M87 iter. 6 (A3, 16 `[ ]` propios — pipeline i18n, mi especialidad)**. M27 queda **cerrado en su parte propia (99/192, 0 `[ ]`)** y M68 liberado con 47 `[ ]` que son de otros módulos (puertos M17/M40, mapa M54, señalización M46, panel M53, animaciones M48/M64, rendimiento M61, accesibilidad M58) → no es buen candidato propio. **M60 (A1) re-verificado y re-marcado selectivamente (Log 916): 188/196 · 4 `[?]` · 4 `[ ]`** — la reversión total de la auditoría del 2026-09-14 quedó reparada con evidencia **ejecutable** (378 checks ×3, 0 `SCRIPT ERROR`), no por inspección. Los 4 `[ ]` que quedan son M08/Voxel Tools (115, 117, 122) y reúso de buffer (168); los 4 `[?]` tienen dueño externo (131→M53/M59, 133→M63, 145→M16/M33, 172→Profiler/GUI). (0/196, fila `🟢 Disponible`): se revirtieron también los `[x]` de mis iter. 2/iter. 3 que **sí** tenían test headless (Log 825) — hay que re-verificar y re-marcar selectivamente lo realmente implementado, no dejarlo en 0. M26 iter. 3 y M148 contenido quedan abiertos pero dependen de contenido/diseño.**

> **M103 Logging (reclamo §21.4.7, iter. 1, Log 918):** cerrado en su parte propia → **167/179 · 12 `[?]` · 0 `[ ]`**. Los 12 `[?]` tienen dueño externo (M53/M110 consola in-game, búsqueda de texto y coloreado; M61 frame budget; M122 crash pre-crash; M102 `bug_{timestamp}.log`) o son decisiones de diseño explícitas (buffer de escritura retirado por código muerto). **Módulo reclamado por DeepSeek-V4.1-Flash** tras la retirada de ox-alpha (Cline). **Siguiente en la cola propia: M87 iter. 6** (A3, 16 `[ ]` propios — pipeline i18n). ⏳ QA cruzado §21.8 de M103 y de M60 iter. 4 pendientes (verificador ≠ autor).

> ⚠️ **La checklist personal se desincroniza.** Tras cerrar una iteración, el `05-Checklist.md` del módulo es la **fuente de verdad**; la personal (`TAREAS-POR-MODELO/<modelo>/<modulo>/checklist.md`) queda atrás. **No regenerarla** con `gen_checklist_personal.py` (borra las notas de evidencia que otros agentes agregaron a cada ítem). Sincronizar **in-place**: parsear los `- [x|?| ]` de ambos en orden (alinean 1:1), cambiar solo los estados que difieren y anexar la nota. En M87 eran 29 ítems.
