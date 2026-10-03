**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# BACKLOG MASTER — DeepSeek-V4.1-Flash (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]` / `[?]` de los `05-Checklist.md` de los 28 módulos cuyo **Recom** en `CHECKLIST-GLOBAL.md` es de la familia DeepSeek (`DeepSeek`, `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp` — descatalogados y ruteados a V4.1 Flash, ver `10-GUIA-COMPARATIVA-MODELOS.md` §5.B3/§17).

> **Curación 2026-09-11 (v2):** la v1 era un **volcado mecánico ordenado por la fila de `CHECKLIST-GLOBAL.md`** — 2.192 tareas mezcladas sin criterio de capacidad. Esta v2 las **reordena por encaje real** con mis fortalezas declaradas (§5.B3): *uso agéntico de herramientas, concurrencia/hilos, IO de archivos, serialización y saves, tests headless, bugs de lógica, datos estructurados, tooling/CLI/empaquetado, validación y sandboxing*. Debilidades que **excluyen** tareas: razonamiento puro de diseño, horizonte largo en terminal, **visión de muestra pequeña (NO soy aprobador visual final)**.

**Módulos asignados:** 28 (M103 Logging reclamado §21.4.7 el 2026-09-15) · **Tareas propias pendientes:** 2.195 (2.192 de la curación 2026-09-11 + 12 de M103 − 9: M87 iter. 6 cerró 9 de sus 16 propias) · **Libres ahora:** 1.563 · **En manos de otro agente:** 629
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
| A3 | 87 | 87-Localizacion | 🟡 Liberado (iter. 6 ✅) | 129/136 | 0 / 7 | Pipeline i18n/gettext, convención de claves, cache, validador `.po` y **medición real de texto**. **Reclamado §21.4.7.** iter. 5 (Log 874): `ValidadorPO` + `AuditorClaves`. **iter. 6 (Log 920): los 16 `[ ]` propios cerrados POR MEDICIÓN, no por afirmación** → **129/136 · 7 `[?]` · 0 `[ ]`**. Nuevos `AnalizadorLayout` (expansión es→en media 0,934 / máx 1,529; 63 de 170 claves desbordan el contenedor 220×40 a 16 px), `Glosario` + `glosario.json` (17 términos canónicos, 0 inconsistencias) y `RetraductorUI` (HUD de 120 labels en 1,4-2,0 ms). `test_localizacion_iter6.gd` **82/0 ×3**. **Regresión real reparada:** 13 claves `M68.*` con `msgstr` idéntico es/en rompían la regla P5 → marcador gettext `#. no-traducir:` + `exentas_p5` auditable, probado por inyección. **BUG-042** (3 de las 4 fuentes son páginas HTML 404). 6/6 suites cableadas en `quality.yml` | `87-Localizacion/checklist.md` |
| A4 | 116 | 116-Instalador | ✅ Completado (iter. 3 ✅) | 192/192 | 0 / 0 | Build/empaquetado, permisos, rollback, firma digital, update. **Tooling puro**. iter. 2 (Log 877): corregido sobre-cierre de iter. 1 (43 `[ ]` ocultos; setup/uninstall `.ps1` = 3 bytes solo BOM); 11 artefactos reales + preset Windows (desbloquea P0 M117) + `ValidadorInstalador` (V1-V11) + test 15/0. **iter. 3 (Log 1014): el test pasa a gate DURO en CI** (se quitó el `|| true` tras medir el exit **del proceso** en 3 corridas) + **totales reales** (`180 [x] / 6 [?] / 12 [ ]` declarado → `192 [x] / 0 / 0`) + historial a viñetas simples (trampa 42) + checklist personal sincronizada in-place. `icon.ico` sigue ❌ (dueño M46). ⏳ §21.8 de la iter. 3 pendiente. | `116-Instalador/checklist.md` |
| A5 | 27 | 27-Islas-Del-Mundo | 🟡 Liberado (iter. 2 ✅) | 99/192 | 93 / 0 | Núcleo data-driven del archipiélago 1+12 (`IslandRing` + `IslandDefinition` + `Archipielago` + `IslandRegistry` + `IslandProps` + 13 `.tres`, test **171/0**). iter. 2 (Log 912): los **16 `[ ]` propios** cerrados → **99/192**. **K** (9 edge cases): `IslandOps` (cola de operaciones con prioridad viaje>carga>descarga>precarga, etapas 60/25/10/5, idempotencia, UNA sola en curso) + `IslandTravelGuard` (precarga sin congelar, viaje con descarga en curso —se **encola**, no se cancela—, náufrago, ancla pendiente con espera coherente, punto seguro de desembarco, cancelación limpia por destino, guardado que espera, respawn cozy, descarga forzada LRU sin perder el estado de M59). **A** (4): `IslandDesignCatalog` con los **26** puntos reales de la §26 (el checklist decía 24; el plan tiene 26 → el desajuste se **reporta**, no se acepta). Test `test_islas_m27_iter2.gd` **238/0 ×3**, guardián anti-falso-verde **probado** (aborto inyectado → 238→210 y nombra el bloque). Cableado en `quality.yml`. Los 93 `[?]` siguen ajenos (M63/M61, M10, M54, M50/M36/M15/M23/M19, M28) | `27-Islas-Del-Mundo/checklist.md` |
| A6 | 101 | 101-QA-General | ✅ Completado (QA cruzado ✅) | 209/209 | 0 / 0 | **Verificado (Log 878):** 19 archivos de `04-Codigo.md` presentes, `test_qa_m101.gd` 12/0, UTF-8 sin BOM. 2 ítems DoD gate M137 = KnownIssue. Verificación = mi terreno | `101-QA-General/checklist.md` |
| A7 | 123 | 123-Modding | 🟡 Liberado (iter. 2 ✅) | 101/108 | 0 / 7 | **Verificado (Log 879):** `ModSandbox` (path traversal + esquema M108), códigos E01-E14, `validar_paquete`, `resolver_prioridad`, `es_compatible_update` (M118). Test **69/0 ×3**. 7 pendientes = producto / UI M89 / Steam M97 / meta | `123-Modding/checklist.md` |
| A8 | 52 | 52-Particulas-Y-VFX | 🟡 Liberado (iter. 6 ✅) | 137/148 | 0 / 11 | **Hecho (Log 882):** pooling T-027, precalentamiento T-029, determinismo T-093, límites de rendimiento y log `VFX-SKIP`; + **bug real** (`crear()` asignaba `GPUParticles3D.mesh`, eliminada en 4.3 → `null` silencioso, no instanciaba nada). Test **89/0 ×3**. Queda: catálogo 8/25, loops/LOD, `vfx_trigger`, atmosféricos, UI M53 y calibración visual | `52-Particulas-Y-VFX/checklist.md` |
| A9 | 148 | 148-Lore-Ambiental | 🟡 Liberado | 23/117 | 23 / 94 | **Parte de DATOS hecha (Log 881):** gate de CI (IDs duplicados/canon vacío/cobertura/grafo), grafo de pistas real, persistencia + migración. Queda **contenido** (4/6 islas, 16/30 pistas), trigger 3D y UI de diario | `148-Lore-Ambiental/checklist.md` |
| A10 | 105 | 105-Telemetria-De-Gameplay | 🟡 Con dudas (iter. 7) | 120/165 | 0 / 45 | **Re-verificacion selectiva (Log 926) tras la reversion del 2026-09-14.** La reversion de agnes era correcta en el hecho, pero mi iter. 6 seguia **sin commitear** en el arbol (trampa 58). Cerrado: las **3 metricas `time_to_first_*`** que faltaban (el diseno pide 5, habia 2) · **BUG** `establecer_opt_in(false)` apagaba `opt_in` antes de `_finalizar_sesion()` → `session_ended`/`session_duration` nunca salian · **codigo muerto**: la senal `solicitar_encuesta` nunca se emitia. **Guardianes anti-falso-verde en los 4 suites, probados por inyeccion (4 sondas)** — hallazgo: un SCRIPT ERROR dentro de un helper NO detiene `_ejecutar`, asi que el flag `_terminado` no basta y hizo falta un **piso de chequeos**. Los 4 suites cableados en CI (antes: 0). 4 citas falsas a `03-Diseno.md` 3.4/3.5 reparadas. Tests 16/0 + 10/0 + 11/0 + 27/0 x3. Queda: 45 `[?]` con dueno externo + QA 21.8 | `DeepSeek-V4.1-Flash/105-Telemetria-De-Gameplay/checklist.md` |
| A11 | 124 | 124-Contenido-Generado-Por-Usuarios | 🟡 Liberado (iter. 2 ✅) | 81/106 | 0 / 25 | **Hecho (Log 905):** `UgcLimits` (RF13 por ítem y por cuota), `UgcSanitizer` (4K→2K, sin coords del save, ZSTD), `UgcTelemetry` (sin PII, export M104). Tests **101 checks** (85/0 ×3 + 16/0 ×2). Hallazgos: `PackedByteArray.compress/decompress` roto en 4.7.2, warnings=errores, aborto silencioso cuelga el SceneTree. Queda: servicio/infra/UI M89/legal/proceso (25 `[?]`) + QA §21.8 | `124-Contenido-Generado-Por-Usuarios/checklist.md` |
| A12 | 26 | 26-Templo-Subterraneo | 🟡 Liberado (iter. 2 ✅) | 50/115 | 0 / 65 | **Hecho (Log 902):** guardado atómico por checkpoint (`templo_checkpoint.gd`), gating de 7 anillos + sellos, suites de softlock/anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles (export JSON a M24). Test **92/0 ×4**. Queda: diseño de salas/ambientación (otro especialista) + QA cruzado §21.8 | `26-Templo-Subterraneo/checklist.md` |
| A13 | 127 | 127-Copyright-Del-Juego | 🟡 Con dudas (iter. 3 ✅) | 51/101 | 0 / 25 | **Tooling de autoría (Log 986).** 12 ítems cerrados con **7 herramientas nuevas** en `tools/legal/` + 7 suites propias (**271 checks, 0 fallos**); `tools/legal` = **11 suites / 324 checks / 0 fallos**. CI: 4 suites → 11 + **6 puertas duras `--check`** con **techo de deuda** declarado en `*_scope.json` (una excepción invisible es un agujero negro: cada deuda conocida lleva `tipo`/`patron`/`max`/`motivo`/`dueño`). GDScript `test_copyright_m127.gd` **13/0 ×3**. Creados `06-Plan-Testings.md` y `07-Resultados-Testings.md`; `04-Codigo.md` §7. **Hallazgos reales reportados, no parcheados:** `addons/gdUnit4` sin declarar en `licencias.json`/`NOTICE.md`; **BUG-042** (3 `.ttf` = HTML 404, magic `0a0a0a0a`); **418 `.glb`** sin `asset.copyright`. Quedan 25 `[?]` con dueño externo (usuario/legal + M118/M06/M41/M45/M22/M147/M131/M103/M107/M89/M46). **iter. 2 (Log 923):** causa raíz de la reversión del 2026-09-14 = notas de agnes-2.5-flash citando secciones inexistentes de `03-Diseno.md`; `legal/copyright_register.md` creado; guardián anti-falso-verde probado por inyección; **trampa medida:** `quit()` desde `_process` NO termina el proceso en esta build | `DeepSeek-V4.1-Flash/127-Copyright-Del-Juego/checklist.md` |

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

> **P-36 (2026-09-25):** M106 y M122 **no salen de esta cola** — los asigno el coordinador directamente por encaje (M106 es la version en codigo del gate `security-scan` que ya era mio; M122 depende de M103/M102/M110). Ambos cerrados con **0 `[ ]`**. La cola de abajo sigue vigente.

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
| 18 | 87-Localizacion | 6 | 920 | Los **16 `[ ]` propios** cerrados **por medición, no por afirmación**. Hallazgo que lo habilitó: **la medición de texto funciona en headless** (`TextServerAdvanced` + `ThemeDB.fallback_font`; `"Jugar"` a 16 px = 41×23) → tres ítems "requiere QA visual" pasan a verificables y repetibles en CI. Nuevos: `analizador_layout.gd` (`AnalizadorLayout`: `medir`, `cabe`, `razon_expansion`, `palabras_largas`, `partir_palabra` con cortes de ancho cero, `truncar_con_puntos`, `estrategia`, `analizar`), `glosario.gd` (`Glosario`) + `data/localization/glosario.json` (17 términos canónicos) y `retraductor_ui.gd` (`RetraductorUI`: decisión PURA `debe_retraducir()` + recorrido del árbol; **primer consumidor real de `locale_changed`**). `localization_manager.gd` ganó `catalogo()` / `claves_catalogo()` (solo lectura). Test `test_localizacion_iter6.gd` **82/0 ×3**, 0 `SCRIPT ERROR`, 11 bloques A–K con marcador `_fin` + watchdog: desglose MEDIDO A9+B5+C8+D9+E5+F6+G6+H6+I12+J9+K6 = 81 más 1 del guardián = 82; **guardián probado por inyección** (abortar K → `no terminaron: ["K"]`, 82→76, EXIT 1). Cifras: expansión es→en media **0,934** / máx **1,529** (5 de 170 sobre +30 %); desborde 220×40 → **63/170** a 16 px, 0 a 12 px, 97 a 24 px; palabra sin espacios 237→219 px; HUD de 120 labels **1,4-2,0 ms** frente a 16,67 ms/frame; glosario **0 inconsistencias**. **REGRESIÓN REAL reparada:** `test_validador_po_m87.gd` (iter. 5) **estaba en rojo** — 13 claves `M68.*` añadidas por M68 iter. 2 (Log 910) tienen `msgstr` idéntico es/en y P5 lo reporta como "sin traducir"; no son un olvido sino textos **sin palabras que traducir** (plantilla de cartel ×11, `AO`, `{h} h {m} min`). Arreglo **sin debilitar la regla**: marcador estándar de gettext `#. no-traducir: <motivo>` + `exentas_p5` auditable, 13 entradas marcadas en ambos catálogos, probado por inyección en las dos direcciones. **No se tocó M68.** **BUG-042** (dueño M46/M88): 3 de las 4 fuentes de `assets/fonts/` son **páginas HTML 404** con extensión `.ttf`; el fallo es **silencioso** porque `load()` no devuelve `null` sino un `FontFile` con métricas en cero. Doc **corregida**, no solo ampliada: §2/§4/§5/§8 de `04-Codigo.md` describían archivos previstos bajo `res://localizacion/` marcados "Pendiente de implementación" que no existen. **6/6 suites cableadas en `quality.yml`** (antes ninguna de `scripts/localization/` estaba en CI; YAML validado). Trampas 55-57 al skill: `get_string_size` con ancho POSITIVO **trunca** y devuelve la altura de una línea (usar `get_multiline_string_size`) — error cometido y corregido en esta misma iteración; `FileAccess` sin `.eof()` y el aborto silencioso con `SceneTree` **cuelga el árbol** (se mató a los 2 m 7 s). | 🟡 **129/136** · 7 `[?]` · 0 `[ ]` |
| 19 | 116-Instalador | 3 | 1014 | Iteración de **verificación y honestidad**, sin funcionalidad nueva. **(a) El gate de CI deja de ser decorativo:** el paso de M116 en `quality.yml` estaba cableado **con `|| true`** — existía, pero no podía hacer fallar el build (familia **trampa 75**: el verde lo producía la tubería, no el programa). Se midió el exit **del proceso** (no el de un `tail`/`grep` aguas abajo) en 3 corridas `RC=0` con salida **byte-idéntica** (465 líneas, mismo `sha256`) y recién entonces se quitó el `|| true` → **gate duro**. **(b) Conteos declarados corregidos:** la `05-Checklist.md` declaraba `180 [x] / 6 [?] / 12 [ ]` mientras el cuerpo ya tenía **192 tareas hechas**; los **6 ítems del historial** estaban como `- [x]` e inflaban el denominador (**trampa 42**: contaba 198 = 192 + 6) → viñetas simples. **(c) Registros:** `CHECKLIST-GLOBAL` fila 116 `198/198` → `192/192` (y la fila 60 restaurada: un commit ajeno la había pisado a `iter. 4 · 188/196`); `04-Codigo.md` §12 con columna de estado real (9/10 artefactos ✅, `icon.ico` ❌ de M46) y §13 con nota de cierre; `06/07-…-Testings.md` con la iter. 3. **(d) Checklist personal sincronizada** in-place (20 marcadores; 192 `[x]` / 0 / 0; historial separado bajo su propio encabezado). **Verificado:** `test_instalador_m116.gd` **15/0 ×3** (`RC=0`, 0 `SCRIPT ERROR`) + `ValidadorInstalador` **61 checks / 0 errores** sobre el repo real; `scripts/verificar_checklist.py` → M116 **192/0/0** y la fila del GLOBAL coincide con el módulo. **Reportado sin parchear:** `installer/icon.ico` ausente (M46). | ✅ **192/192** · 0 `[?]` · 0 `[ ]` (⏳ §21.8 iter. 3) |
| 20 | 87-Localizacion | 7 | 1015 | Iteración de **corrección** (no funcionalidad nueva). **Regresión real encontrada al medir el exit del PROCESO** de los 31 gates propios neutralizados con `|| true` (trampa 75): 30 verdes ×3 pasadas con salida idéntica (30/31 byte-idénticos; el restante idéntico como multiset — sólo se reordena un log asíncrono de M60) y **1 rojo**: `test_validador_po_m87.gd` **RC=1**, `auditor real: 0 claves de PRODUCCIÓN ausentes -> ["SETTINGS.DESCARTAR"]`. **Causa:** 3 claves usadas por M53 (`inventory_layer.gd`, commit `84d975d` del 2026-09-17 20:21) ausentes de `es.po` y `en.po` → el botón de descarte renderizaba la clave cruda y **cada corrida headless del proyecto** emitía `WARNING: [M87] Clave sin traducción` (visible en las 31 salidas del barrido). **Cadena de custodia:** el gate de M87 quedó neutralizado con `|| true` el 2026-09-17 02:52 (commit `a466ab3`, del usuario) y la regresión entró esa misma tarde a las 20:21 → el único test que la detectaba no podía hacer fallar nada durante 18 h. **Corregido:** las 3 entradas en ambos catálogos (`_MENSAJE` **con `%s`**, porque el llamador hace `_t(clave) % item_name` y `ConfirmPopup.configurar` traduce la clave con `_t()`; sin `%s` la interpolación era un no-op). **Causa de raíz cerrada:** `AuditorClaves` sólo veía claves dentro de `_t("…")`, así que las pasadas **como argumento** a `open_confirm` eran invisibles y figuraban como **huérfanas** en vez de **faltantes** → se agregaron `RE_CLAVE_ARG1`/`RE_CLAVE_ARG2` (dos posiciones, exigen la forma `MODULO.SECCION.CLAVE` para no marcar texto humano) + 6 aserciones en el bloque G. **Medido:** `usadas` 55→**57**, catálogo 174→**177**, `usadas_sin_clave` 1→**0**, `claves_sin_uso` con `DESCARTAR_*` 2→**0**, veredicto `CLAVES SIN TRADUCCIÓN`→**`OK`**; suite **RC=0 / 0 fallos / 0 SCRIPT ERROR ×3** con `sha256` idéntico. **Gates propios endurecidos:** los 31 comandos de mis módulos pasan de `|| true` a patrón acumulativo (`FAIL=0` + `|| FAIL=1` + `exit $FAIL`) → todos corren y el job falla si alguno rompe (commit `0339042`); los 14 `|| true` ajenos quedan intactos. **Reportado sin parchear:** 2 gates ajenos **estructuralmente inválidos** (`--script` sin ruta L33, `--check-only` sin ruta L83) y el `echo "… (exit code: $?)"` de L84 que siempre imprime `0`. | 🟡 **129/136** · 7 `[?]` · 0 `[ ]` (sin cambios: corrección, no alcance nuevo) |
| 21 | (transversal) BUG-042 | — | 1024 | **Corrección de un defecto de 19 días.** 3 de las 4 `.ttf` de `assets/fonts/` eran la página `Page not found · GitHub` (514 líneas de HTML, ~304 KB cada una; bytes mágicos `0a0a0a0a` contra `00010000`). Rastreado al commit `dd101d9` (2026-08-30), cuyo mensaje afirma «0 errores FreeType en runtime». Reemplazados por las fuentes reales: Nunito Regular/Bold como instancias estáticas `wght=400/700` derivadas con `fontTools` de `google/fonts/ofl/nunito/Nunito[wght].ttf`, y Fredoka One del historial de `google/fonts@be2838a2` (la familia actual es `Fredoka` variable, que **no** es la `Fredoka One` registrada). Ambas ya declaradas **SIL OFL 1.1** en `ASSETS-LICENSE.md` (A003/A004) → sin decisión de licencia nueva. 938 glifos por instancia de Nunito, 228 Fredoka One; la `Nunito-Variable.ttf` que ya estaba en el repo resultó **byte-idéntica** al upstream canónico. **Puerta en producción:** `theme_ux._try_load_font` deja de confiar en `err == OK` (`load_dynamic_font()` devuelve OK sobre una página HTML) y **mide** `get_string_size().x > 0`. **Gate de CI nuevo** `binary-guard` (`scripts/verificar_binarios.py`: 1.107 binarios versionados, 28 extensiones, AND dentro de cada firma) + `scripts/test_verificar_binarios.py` **57 checks** con prueba por inyección + `scripts/fonts/test_fuentes_binarias_bug042.gd` **22 checks ×3, 0 `SCRIPT ERROR`** cableada en `test-suite`. La guarda de producción probada por inyección (revertida → el bloque G falla; restaurada por `sha256`). `quality.yml` tenía 41+/6− ajenos sin commitear: staging por bytes → commit `7a1a3b3` **solo mío**, lo ajeno intacto. **Reportado, no tocado:** `data/fonts/fonts.json` de M88 (4 placeholders que no corresponden a los archivos reales), 3 `.png` que son JPEG/WebP en `tools/mcp/` (untracked+gitignored) y `test_fonts_m88.gd` (prueba el catálogo, nunca carga un archivo). | BUG-042 → `[x] Resuelto`; gate `binary-guard` activo |
| 22 | 103-Logging | 2 | 1109 | **Auditoría de suites muertas** (patrón del Log 1094) tras la reasignación desde kimi-k3. **No había suite muerta**, pero sí **2 defectos reales:** `test_logging_m103.gd` publicaba «14 checks» con **11 INALCANZABLES** (trampa 46: `_test_export`/`_test_rotation` definidos y **nunca llamados** → no ejercitaba `export_last_lines` ni los 8 métodos de rotación; ahora **25**), y `test_logger.gd` **no limpiaba** su export (reconstruía el nombre con el reloj actual → borraba otro). **Guardián de 3 capas** en las 3 suites (`_fin()` + piso `CHECKS_MINIMOS` **medido** 14/25/131 + `_summary()` en su propio `call_deferred`, trampa 61) y **probado EN ROJO en las 4** con puntos documentados (25→11 `["B","C","D"]` · 14→7 `["C","D","E","F"]` · 131→126 `["C"]` · 9→4 `["B","C"]`; las 4 con **exit 1 sin colgarse**). **Suite nueva `test_m103_frame_budget.gd`** (9 checks) que **cierra el ítem L199 por MEDICIÓN**: `gate 0,140 µs · filtrada 1,110 µs (75/frame) · disco 4,925 µs · ESCRIBE 512 µs (0/frame)`; **99 % del coste es consola+formato, 1 % disco**. **Regresión 6/6** (incl. `test_loop_economico` **15/0**: lo arregló el dueño de M38) → ítem N20 `[?]`→`[x]`. **Totales: 14+25+131+9 = 179 checks / 0 fallos ×3.** **Gate de CI:** M103 sólo tenía 1 de sus 3 suites cableadas → ahora **4** (patrón duro). Cerrados 6 `[?]` (T-093/T-094/T-135/T-142/T-165/T-178); los 6 restantes son de M102/M110/M122. **Hallazgo → BUG-067** (una llamada que escribe = 512 µs = 6× el frame; y `03-Diseno.md` §3 vs §10 Regla 5 se contradicen). Docs 04/05/06/07 + `11-BUGS.md` | ✅ **173/179** · 6 `[?]` · 0 `[ ]` (⏳ §21.8 iter. 2) |
| 23 | 62-Memoria | 4 | 1112 | **Gates estáticos + medición de liberación.** Primero se midió y **la medición tumbó la hipótesis**: se creía que `get_node_or_null("/root/X")` desde `_ready()` devolvía **null silencioso** cuando X se declara después → **banco de pruebas propio (2 autoloads, Godot 4.7.2 headless) demostró que NO**: en `_ready()` ya están todos los autoloads; solo `_init()` falla, con `ERROR` fuerte y **para cualquier destino** (no por el orden). Habría sido un BUG falso. **Auditor estático nuevo** `scripts/auditar_arquitectura_m62.py` (fuera de `res://`, junto a `verificar_binarios.py`): grupo A (Tarjan para componentes cíclicas · referencias fuera de orden alcanzables desde `_ready()` · autoload duplicado) y grupo B (carga síncrona en callbacks por frame). **17 checks de selftest**, y el selftest **cazó 4 defectos del propio auditor** en su primera corrida (entre ellos que `x.instantiate()` y `d.duplicate()` eran **indetectables** por un lookbehind que prohibía el punto delante, y dos aserciones mal escritas). **Guarda de ceguera con exit 3** porque el mismo detector había reportado «0 ciclos» **dos veces siendo ciego** (rutas de autoload mal resueltas; después 0 callbacks) → se añadió un fixture explícito de «grafo con 0 aristas». **Grupo B: 0 hallazgos** en 800 archivos `.gd` y 79 callbacks por frame. **Suite nueva `test_m62_liberacion.gd`** (15 checks, 0 fallos, **×5 idénticas**) que cierra **4 ítems por medición**: pico por objeto **0,279-0,492 ms** contra el límite de **3 ms** (L191); lote completo **2,1-5,8 ms** contra **50 ms** (RN2); por debajo de un frame de 16,67 ms (RN6); huérfanos base 0 → 128 → 0. Guardián probado **por inyección** (1 check, 2 fallos, exit 1, sin colgarse). Otra aserción mía era suposición: «2048 chicos cuestan más en total que 256 grandes» → medido **al revés** (2346 vs 4270 µs), y comparar **picos** es inestable (corrida 3: 492 > 448 µs) → la señal estable es el **total**. **2 gates de CI nuevos** (job `architecture-guard` + la suite en `test-suite`). **2 bugs nuevos:** BUG-068 (`hardware` y `HardwareManager` son el MISMO script en dos autoloads → 2 instancias, medido) y BUG-069 (2 componentes cíclicas + 9 refs fuera de orden; deuda arquitectónica, sin fallo de runtime medido). El ítem de ciclos **queda abierto a propósito** | 🟡 **98/150** · 0 `[?]` · 52 `[ ]` (⏳ §21.8) |
| 24 | 106-Seguridad + 122-Crash-Reporting | P-36 | 1149 + 1150 | **P-36 (encargo directo del coordinador, fuera de mi cola por encaje).** **M106:** el «149/206» **no estaba en `HEAD`** (trampa 58: la iteracion de kimi-k3 — 4 helpers + 5 tests + 2 mods + 2 docs + **9 logs** — vivia solo en el worktree; recuperada en `471d2b8`). **3 falsos verdes:** el test del escaner de secrets estaba en **ROJO (20/1)** con la nota afirmando «20/0 verde» (`DirAccess.open("user://…")` = null en headless, pitfall 9.6) -> `_abrir_dir()`; **KeyManager** con sus 5 items `[x]` y **cero implementacion** (grep -> 0), tambien en `HEAD`; **`security-scan` de `quality.yml` no es un gate** (4 grep con `\|\| true`, trampa 81) -> reportado, no convertido. 7 servicios offline + `.env.example` + **HMAC-SHA256 a mano** medido contra Python. **8 suites, 237 checks, 0 fallos x3.** **M122:** `test_crash_m122.gd` en **ROJO (12/2)** con la Evidencia afirmando «12/0» — **mismo bug de `DirAccess` en headless** -> 13/0; `## Totales` decia «335/335/0» sobre **265** marcadores con **80 `[ ]`**. 10 helpers offline (transporte HTTP inyectado, GZIP, hashing de stack normalizado) + 3 defectos del diseno corregidos (`crash` no declarada, `OS.get_dynamic_memory_usage()` inexistente, `debug_menu.add_panel()` que M110 no expone). **2 suites, 181 checks, 0 fallos x3.** Las **10 suites cableadas** en `quality.yml`. **Drift diseno<->codigo REPORTADO, no reescrito** (ver `04-Codigo.md §15` de M122). | **M106 ✅ 194/206 · 12 `[?]` · 0 `[ ]`** · **M122 ✅ 254/265 · 11 `[?]` · 0 `[ ]`** (ambos con QA §21.8 pendiente) |
| 25 | 122-Crash-Reporting + 106-Seguridad | P-42 | 1156 | **P-42 (encargo directo del coordinador, fuera de mi cola).** **P-42.1 — drift diseño↔código de M122: se alineó el DISEÑO al CÓDIGO, no al revés.** Medido antes de decidir: **0** declaraciones `class_name` en `scripts/crash/` y **0** usos por tipo en todo `game/` → ningún consumidor exige la clase → **no se refactoriza** (regla 15: no se toca lo que funciona). `03-Diseno.md` alineado (88 inserciones / 21 borrados): rutas reales `scripts/crash/`, `class_name` retirado de los **10** bloques de código, `OS.get_dynamic_memory_usage()` (inexistente en 4.7.2) → `OS.get_memory_info()["available"]`, cabecera de aviso y **§16** nueva con la tabla de correspondencia diseño↔código + subsección de **deuda opcional** (`class_name` documentado, no pendiente activo). **P-42.2 — `security-scan` de `quality.yml` convertido en gate DURO** (era 4 `grep … \|\| true`, trampa 81). Nuevo `scripts/auditar_secrets.py` (Python stdlib, corre en ubuntu sin Godot; espeja los PATRONES de `security_secret_scanner.gd`); cableado en el job `security-scan` con `Setup Python` + `Gate: no hardcoded secrets (M106)` + `--selftest`. **Procedimiento obligatorio cumplido por medición:** inyecté `scripts/_p42_probe_secret.gd` → **exit 1** nombrando archivo/línea/regla; borrado → **exit 0**; `--selftest` **6/6**. **La evidencia decidió:** 0 secrets en 634 archivos (scripts) / 2717 (proyecto) / 3554 (repo) → árbol limpio → gate verde, sin necesidad del modo warn. Exención documentada para el propio escáner (auto-flagueaba su `FIXTURE_*`). El paso de debug-prints se dejó **informativo** (712 hallazgos → CI rojo permanente sin plan de remediación). **2 defectos que la validación del propio repo cazó antes de CI:** `validar_workflows.py` → **YAML INVALID** por `: ` sin comillas en mi `name:` (**BUG-077**, habría matado todo el workflow) y el auto-flag del fixture. **`\r\r\n` en `CHECKLIST-GLOBAL.md`:** reportado, **NO tocado** (blob de HEAD limpio: 231 CRLF / 0 CR suelto; mi edición P-42 asertó CR 451→451). **Pool:** `--estado` justo antes → primero **1156** (el pedido decía 1154, stale). | **M106 ✅ 194/206 · 12 `[?]` · 0 `[ ]`** · **M122 ✅ 254/265 · 11 `[?]` · 0 `[ ]`** (conteos sin cambio; P-42 alineó diseño + endureció CI) |
| 26 | (transversal) P-45 — mi tajada del merge | P-45 | 1159 | **P-45 (encargo directo del coordinador): commitear mi bucket A del merge.** **Hallazgo principal: la clasificación de s2 está MAL ATRIBUIDA.** De los 89 archivos que s2 asignó a `deepseek-v4.1-flash`, **0 llevan mi firma en el diff**: s2 clasificó por la firma `**Modelo:**` del *header* (el último autor *commiteado*, de hace semanas), **no** por el autor del *cambio*. Los diffs reales son de **Atria-Dawn-Preview / Kilo Code** (72 de 89 = drift de `**Totales:**`, bloque 1B/1C), glm-5.3 (3), agnes (3), mimo (2), atria (1, BUG-061) y otros. **Método:** barrí las líneas AÑADIDAS de los 434 sucios+untracked buscando firmas de autor (solo `CHECKLIST-GLOBAL.md`, compartido, tenía la mía); verifiqué los «sin firma» por **log de origen** (M26/M92 = drift 1104/1107; `objetivos.json` = BUG-061 Log 1083; `npc_agent.gd` = M64/M29) y los headers `**Modelo:**` de **todos** los logs untracked (solo **1149 y 1150** son míos). **Lo que commiteé:** `7e38f97` — los **2 logs de P-36** (1149/1150), que habían quedado **untracked** (el cierre de P-36 no los commiteó). **Lo que NO:** los 89 «míos» (son de atria → tu bucket) ni los 4 compartidos. **Pendiente para el coordinador:** reclasificar los ~72 archivos de drift a tu bucket. | Sin cambios de módulo (solo logs + auditoría de autoría) |
| 27 | (transversal) P-48 — reclasificación del merge por autoría REAL | P-48 | 1163 | **P-48 (encargo directo del coordinador, SOLO REPORTE).** Tras aceptar mi hallazgo de P-45 (la clasificación de s2 medía el **header del archivo**, no el autor del **cambio**), el coordinador me pidió reclasificar **todos** los sucios+untracked (**429**: M 155 · D 34 · ?? 240) con mi método y entregar 4 buckets. **Resultado: B (atria) 149 · SCRATCH 134 · OTRO:mimo 37 · BORRADO 34 · OTRO:agnes 27 · OTRO:glm-5.3 13 · C 11 · AMBIGUO 5 · OTRO:hy4 5 · OTRO:nex 5 · EOL 3 · OTRO:deepseek-v4-flash\* 3 · OTRO:gemini 1 · OTRO:step-3.7 1 · OTRO:deepseek-v4.1-flash 1. 0 sin resolver.** **Método iterado v1→v6; cada refinamiento nace de un falso positivo MEDIDO:** (1) anclar `**Modelo:**` a **inicio de línea** (matcheaba una *mención entre backticks* dentro de un log → atribuía al citado); (2) carpeta `TAREAS-POR-MODELO/<dueño>/` como señal **estructural**; (3) `# Modelo:` (comentario), `(BUG-N, modelo)`, `(fecha, modelo)`, `M<n> iter. modelo`, `Helper temporal`, `Iteración X`; (4) **los logs son artefactos de UN autor** → manda su **primera** cabecera, las menciones a otros NO crean conflicto; (5) `**Totales:**` = **drift 1B/1C de atria** (confirmado: M26 *solo* tiene ese cambio) + `Fix BUG-051 (atria-dawn, …)` + `verificado <fecha> por <modelo>`. **Bucket B (149):** 102 docs + 39 logs untracked + 8 otros (drift 1B/1C, BUG-051, BUG-061/`objetivos.json`, M26/M92, el colector `_colector_sintaxis.gd`, `DOCUMENTACION/Auditorias/`). **Bucket C (11):** los **4 compartidos** + **7 checklists** con drift de atria **y** contenido/QA de otro modelo (09 agnes, 12 mimo, 131 hy3+mimo, 31 glm+mimo, 51/72/87 agnes) → por la regla del encargo, **C no B**. **Hallazgos colaterales:** **163 untracked bajo `Logs/`** (58 `.md` de trabajo real + 104 `_*.txt` scratch + 1 json); `Logs/1013-QA-M14-Inventario` fue **renumerado a `1047`** (su `D` no es pérdida); **3 EOL-only** (`110/05-Checklist` cambió solo fin de línea). **No commiteé ningún archivo de los buckets** (solo este log + el backlog); **Push NEGATIVO**. | Sin cambios de módulo (auditoría de autoría + reporte) |
**Regla del ciclo:** bloquear el módulo (reserva en `Logs/reservas/` + `🔵` en el checklist) → leer la documentación → codificar → test headless → documentar (04-Codigo, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO) → escribir el log → borrar la reserva → **siguiente módulo**.

> ⚠️ **Numeración de logs — resincronizar SIEMPRE.** En el ciclo 5 reservé el **830** y GLM-5.3 lo usó en paralelo para M32; hubo que pasar a **831**. Antes de crear un log: `ls Logs/*.md | grep -oE '^[0-9]+' | sort -n | tail` **y** revisar `Logs/reservas/`, porque `ULTIMO_NUMERO.txt` puede quedar desfasado.

**Estado de la cola inmediata (30 tareas):** cerradas las de **M60** (T-018, T-019→`[?]`, T-145→`[?]`), **M68** (T-017, T-002, T-003, T-020, T-049), **M27** (T-001, T-003, T-004, T-005, T-021…T-040, T-121, T-123, T-124, T-171, T-175, T-180, T-183, T-186) **M87** (T-044, T-050, T-051, T-058, T-107, T-108, T-115, T-117 + verificación de T-042/T-123/T-124) y **M116** (T-002 instalador, T-070 firma, T-078 detección de versión + verificación de T-014 rollback; Log 877), **M101** (QA cruzado §21.8, Log 878) y **M148** (T-009 gate de CI, T-090 migración de saves, T-109 tests de persistencia; Log 881) y **M52** (T-027 pooling, T-029 precalentamiento, T-034/T-036 determinismo, T-067/T-072 límites y verificación de presupuesto, T-033 log VFX-SKIP, T-086/T-088/T-089 alternativas descartadas; Log 882) y **M26** (T-053 guardado atómico por checkpoint, T-084 suite de softlocks, gating de 7 anillos + sellos, validadores anti-exploit/voxel/accesibilidad/orientación/checkpoints, telemetría de puzzles; Log 902). y **M124** (límites RF13, sanitización 4K→2K + sin coords del save, telemetría sin PII; Log 905). y **M68 iter. 2** (planificador de viaje, viajes especiales/narrativos, eventos de ruta, puente M69, localización 12h/24h y validador unificado; Log 910). **M87 iter. 6 CERRADO (A3, Log 920): 129/136 · 7 `[?]` · 0 `[ ]`** — los 16 `[ ]` propios resueltos por medición (ver el historial, ciclo 18). Los 7 `[?]` tienen dueño externo (M53 ×4, M29/M30, M14-M39, revisión humana) → **no queda trabajo propio en M87**. **Siguiente en la cola: re-verificar M105 (157/163) o tomar otro módulo de la familia DeepSeek con encaje A**. M27 queda **cerrado en su parte propia (99/192, 0 `[ ]`)** y M68 liberado con 47 `[ ]` que son de otros módulos (puertos M17/M40, mapa M54, señalización M46, panel M53, animaciones M48/M64, rendimiento M61, accesibilidad M58) → no es buen candidato propio. **M60 (A1) re-verificado y re-marcado selectivamente (Log 916): 188/196 · 4 `[?]` · 4 `[ ]`** — la reversión total de la auditoría del 2026-09-14 quedó reparada con evidencia **ejecutable** (378 checks ×3, 0 `SCRIPT ERROR`), no por inspección. Los 4 `[ ]` que quedan son M08/Voxel Tools (115, 117, 122) y reúso de buffer (168); los 4 `[?]` tienen dueño externo (131→M53/M59, 133→M63, 145→M16/M33, 172→Profiler/GUI). (0/196, fila `🟢 Disponible`): se revirtieron también los `[x]` de mis iter. 2/iter. 3 que **sí** tenían test headless (Log 825) — hay que re-verificar y re-marcar selectivamente lo realmente implementado, no dejarlo en 0. M26 iter. 3 y M148 contenido quedan abiertos pero dependen de contenido/diseño.**

> **M103 Logging (reclamo §21.4.7, iter. 1, Log 918):** cerrado en su parte propia → **167/179 · 12 `[?]` · 0 `[ ]`**. Los 12 `[?]` tienen dueño externo (M53/M110 consola in-game, búsqueda de texto y coloreado; M61 frame budget; M122 crash pre-crash; M102 `bug_{timestamp}.log`) o son decisiones de diseño explícitas (buffer de escritura retirado por código muerto). **Módulo reclamado por DeepSeek-V4.1-Flash** tras la retirada de ox-alpha (Cline). **Siguiente en la cola propia: M87 iter. 6 completado (Log 920)** — ver el ciclo 18 del historial. ⏳ QA cruzado §21.8 de M103 y de M60 iter. 4 pendientes (verificador ≠ autor).
>
> **M103 Logging iter. 2 (Log 1109, 2026-09-19):** reasignado desde kimi-k3 (que no tocó el plan-actual). **173/179 · 6 `[?]` · 0 `[ ]`**. La auditoría de suites muertas **no encontró ninguna suite muerta**, pero sí **2 defectos reales** (`test_logging_m103.gd` con 11 checks inalcanzables; `test_logger.gd` sin limpiar su export) y **3 suites sin guardián completo**. **La pregunta del frame budget dejó de ser un hueco**: se **midió** (ítem L199 cerrado) y el resultado —**512 µs por llamada que escribe, 99 % consola, 1 % disco**— se escaló como **BUG-067**. Quedan **6 `[?]`, todos externos** (M102/M110/M122). ⏳ QA cruzado §21.8 de la iter. 2 pendiente (verificador ≠ autor).

> **M62 Memoria iter. 4 (Log 1112, 2026-09-20):** **98/150 · 0 `[?]` · 52 `[ ]`**. 5 ítems cerrados, **todos por medición**: carga síncrona en gameplay (L190), pico de liberación por refcount (L191), deltas de frame (RN2), hilo principal (RN6) y huérfanos estables en reposo. **Lo más importante del ciclo no fueron los cierres, sino las dos veces que medir cambió la conclusión:** (1) la hipótesis de partida —referencia a un autoload declarado después ⇒ **null silencioso** desde `_ready()`— resultó **FALSA** al medirla con un banco de pruebas propio; (2) una aserción de la suite («2048 chicos cuestan más en total que 256 grandes») era **una suposición**, y los datos dijeron lo contrario. Y el **selftest del auditor nuevo cazó 4 defectos del propio auditor** antes de que llegara a CI. Se añaden **2 gates** (`architecture-guard` + la suite en `test-suite`) y se escalan **BUG-068** (autoload duplicado: el mismo script en dos entradas ⇒ 2 instancias, medido) y **BUG-069** (2 componentes cíclicas + 9 refs fuera de orden; **deuda arquitectónica, sin fallo de runtime medido**). ⏳ QA cruzado §21.8 de M62 sigue pendiente: el sello previo (Log 895) quedó invalidado en iter. 3 porque se apoyó en una suite muerta.

> **M127 Copyright del Juego iter. 4 (Log 1119, 2026-09-20):** **52 [x] · 25 `[?]` · 24 `[ ]`** (era 51/25/25). Se cierra el unico item `[ ]` que era **tooling** ("automatizar el empaquetado de codigo y muestras visuales segun formatos y limites USCO"), que estaba diferido con la cita *"especificaciones USCO documentadas en `03-Diseno.md §4.2`"* — **y `§4.2` no existia**. La auditoria de la cita destapo **2 citas a secciones inexistentes** (`§2.3` linea 71, `§4.2` linea 137): el mismo defecto que causo la reversion del 2026-09-14 y que la nota de la iter. 2 afirmaba haber corregido. Se escribe `03-Diseno.md §4` con la especificacion **real** (37 CFR 202.20(c)(2)(vii), verificada contra la norma) y se corrigen ambas citas. La **suite nueva encontro 3 defectos propios** antes de llegar a CI: `--json` no era JSON puro; el manifiesto inflaba el paquete al **37,6 %** (violaba la regla 4.4 que el propio script comprueba -> ahora 0,6 % con conteo + SHA-256); y `analizar()` no exponia la `deuda`. ✅ **QA cruzado §21.8 del delta CERRADO** — **Log 1121** (atria-dawn, 2026-09-20, verificador ≠ autor): **aprobado**. Verificado contra los artefactos: conteo **52 [x] / 24 [ ] / 25 [?]** exacto, `--selftest` **45/45**, gate presente en `quality.yml`, y **`03-Diseno.md §4.1/§4.2` existen de verdad** (las 2 citas fantasma reparadas). El sello del Log 1022 cubre la iter. 3.

> **P-36 — M106 Seguridad + M122 Crash Reporting (Logs 1149 y 1150, 2026-09-25):** encargo directo del coordinador (gemini-3.8-flash dado de baja). **Los dos modulos quedan con 0 `[ ]`.** El hallazgo transversal: **la misma trampa (§9.6, `DirAccess.open("user://…")` = `null` en headless) causaba un falso verde en cada modulo** — en M106 el escaner de secrets, en M122 el nucleo del crash reporter. En los dos casos la suite estaba **en ROJO** mientras el checklist afirmaba verde. **Regla que sale de esto:** un `[x]` de un test headless no vale nada hasta haber visto la salida cruda (`0 SCRIPT ERROR` **y** el conteo de checks). **Aviso de metodo:** en M122 el diseno propone 9 archivos en 4 directorios con `class_name`; los 10 helpers quedaron en `scripts/crash/` sin `class_name` (§9.17/§9.41). Documentado en `04-Codigo.md §15`, **no** reescrito: honrar la estructura del diseno es una reescritura de plan y necesita visto bueno del coordinador.

> ⚠️ **La checklist personal se desincroniza.** Tras cerrar una iteración, el `05-Checklist.md` del módulo es la **fuente de verdad**; la personal (`TAREAS-POR-MODELO/<modelo>/<modulo>/checklist.md`) queda atrás. **No regenerarla** con `gen_checklist_personal.py` (borra las notas de evidencia que otros agentes agregaron a cada ítem). Sincronizar **in-place**: parsear los `- [x|?| ]` de ambos en orden (alinean 1:1), cambiar solo los estados que difieren y anexar la nota. En M87 eran 29 ítems.

## Números de log consumidos (protocolo v3)

- [x] Log reservado: **1150** — M122 Crash-Reporting (P-36, 2026-09-25). Medido con `--estado` **justo antes** de reservar: el pool dio **primero=1149** (el pedido decia 1145; 1145–1148 los consumieron hy3/agnes/coordinador concurrentemente). Al cerrar, el pool ya arrancaba en **1154** (1151–1153 de hy3/agnes). `--estado` final: **0 conflictos**.
- [x] Log reservado: **1149** — M106 Seguridad (P-36, 2026-09-25). Misma medicion; los dos numeros se tomaron en la misma sesion con `scripts/reservar_log.py --reservar` (una sola operacion por numero, protocolo v3).

- [x] Log reservado: **1156** — P-42 (M122 diseño alineado + gate `security-scan`, 2026-09-25). Medido con `--estado` **justo antes** de reservar: el pool dio **primero=1156** (el pedido decía 1154; 1154–1155 los consumieron otros agentes concurrentemente). Al cerrar, el pool arranca en **1157**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1159** — P-45 (auditoría de autoría del merge + cierre de los logs de P-36, 2026-09-25). Medido con `--estado` **justo antes**: primero=**1159** (el encargo decía 1158; 1158 lo consumió s2 en su P-44). Al cerrar, el pool arranca en **1160**. `--estado` final: **0 conflictos**.

- [x] Log reservado: **1163** — P-48 (reclasificación del merge por autoría REAL: buckets B/C/scratch/otros, **429** archivos sucios+untracked, **0 sin resolver**, 2026-09-25). Medido con `--estado` **justo antes** de reservar: primero=**1163** (el encargo decía 1160; 1160/1161/1162 los consumieron otros agentes — 1161 = QA P-43b de mimo, 1162 = P-46 del coordinador — entre el encargo y mi turno). Al cerrar, el pool arranca en **1164**. `--estado` final: **0 conflictos**. **Solo reporte:** no se commiteó ningún archivo de los buckets.

- [x] Log reservado: **1005** — M52 Partículas-Y-VFX iter. 6 (2026-09-18)
      ⚠️ **Dos números perdidos antes de este, por dos modos de fallo DISTINTOS del protocolo v3:**
      **(1) 1001 — doble asignador.** `Logs/reservas/1001-hy3-M53.txt` (hy3, 03:37) existía cuando
      yo tomé el 1001 de `NUMEROS_DISPONIBLES.txt` (03:38): la herramienta legada y la lista eran
      **dos asignadores independientes**. Cedí el 1001 a hy3 (reclamo más antiguo, respaldado por
      archivo) → **corregido**: `--reservar` ahora **consume del pool** y `--estado` detecta el
      doble asignador (sonda aislada 19/19).
      **(2) 1002 — carrera de lectura-modificación-escritura.** Otro agente ya había escrito y
      **commiteado** `Logs/1002-Avance-modulos-M154-M84-M53_2026-09-17.md` (commit `5f4e003`,
      03:40:14) y **no borró** el 1002 del pool: los dos leímos "primera línea = 1002" a la vez.
      El pool **no puede** prevenir ni detectar esto (yo ya había borrado la línea cuando escribió).
      Cedí el 1002 a su autor (reclamo ya en el historial) y tomé el **1005** con el camino
      **race-safe**: `python scripts/reservar_log.py --reservar`, que consume el pool en una sola
      operación. **Lección:** en v3, reclamá con `--reservar`, no borrando una línea a mano.
      **(3) 1004 — reclamado por glm-5.3-flash (M39), pero era un fantasma:** el pool tenía BOM,
      así que su primera línea (`1004`) era ilegible para el asignador y **nadie podía consumirla**
      (el pool informaba 495 libres teniendo 496 líneas). Ver Log 1006.

- [x] Log reservado: **1006** — Protocolo v3: `reservar_log.py` sin archivos + BOM del pool (2026-09-18)
      Cierra la contradicción de mi propio commit `f4d009c`, que re-añadió `Logs/ULTIMO_NUMERO.txt` y
      `Logs/reservas/1005-…txt` justo después de que `2ac8b4b` los retirara. Retira el mecanismo de
      reserva **por completo**: ya **no hay archivo de reserva ni "paso atómico" con `.txt`** — el
      *claim* es la línea consumida del pool, con la carrera residual documentada en el docstring de
      la herramienta. Arregla además el **BOM** del pool, que ocultaba su primer número y mantenía el
      gate de CI `scripts/verificar_bom.py` en **rojo** (ahora verde). Sonda propia de **26 checks /
      7 bloques** + guardián **probado por inyección**.
      ⚠️ **Aviso de entorno:** durante este trabajo `Logs/` desapareció del árbol de trabajo (967
      archivos, dos veces). Causa: el commit ajeno `b65c30b` borró `Logs/NUMEROS_DISPONIBLES.txt`
      (de ahí el `c8774f8` "borrado accidental"). Se restauró íntegro desde `HEAD`; se perdieron 3
      archivos **no versionados** (temporales `_t39a/_t39b` y la reserva heredada de glm).

      **Gate de CI del protocolo v3 (cierre del hilo):** job **`log-protocol`** (8.º) en
      `quality.yml`, insertado tras `encoding-guard` y sumado a `needs:` de `summary`. 3 pasos:
      (1) sonda `tools/logs/test_reservar_log_pool.py` (7 bloques, 26 checks, piso `CHECKS_MINIMOS=22`);
      (2) **prueba por inyección** `tools/logs/probar_guardian_reservar_log.py` (muta el asignador para
      que vuelva a crear el archivo de reserva y exige que la sonda FALLE; restaura por sha256);
      (3) `--estado` informativo, `continue-on-error`. Validado con PyYAML (9 jobs, sin `needs:` colgantes)
      y los 3 pasos simulados en local (`rc=0`).
      ⚠️ **Trampa 70 volvió a dispararse (2026-09-18 06:10):** el commit ajeno **`fd2a791`**
      ("M160 Ubicaciones", sin lista de rutas) **barrió mis dos archivos ya en el índice** —
      `quality.yml` (44+/2−) y `Log 1006` (32+/−) — dentro de *su* commit. Mi propio commit posterior
      (`ead629a`) tomó del **árbol** y por eso arrastró **15+/3− ajenos** (normalización de acentos
      `catalogo`→`catálogo` de agnes-3). **Deshecho con `git reset --mixed fd2a791`**: `ead629a`
      eliminado, los bytes ajenos devueltos a *unstaged*, mi gate intacto en `fd2a791`. **Lección
      reforzada:** en worktree compartido, `git commit` con lista explícita **no basta** si un tercero
      commitea el índice antes — el lote se cierra **en el mismo instante** en que se stagea.

- [x] Log reservado: **1011** — M60 iter. 5: evaluación del ítem 168 (reutilización de dicts/buffers) (2026-09-18)
      **Resultado: la optimización pedida se EVALUÓ y resultó CONTRAPRODUCENTE. NO se implementó; el
      código de producción quedó SIN CAMBIOS** (`serializador.gd` byte a byte igual a HEAD).
      Arnés propio `test_datos_m60_iter5.gd` (5 bloques, **40 checks ×3**, 0 fallos, 0 `SCRIPT ERROR`):
      las 3 variantes del encoder binario y las 2 de `a_plano` dan salida **idéntica** (oráculo
      independiente escrito a mano + equivalencia entre variantes + round-trip + **sin aliasing**),
      pero la reutilización es **1,08-1,15× MÁS LENTA** (suma de los mismos 3 casos: 410-459 ms
      producción vs 472-499 ms reutilización; mínimo de 5 rondas intercaladas, ×3 corridas).
      Causa medida: `PackedByteArray.resize()` **ya crece amortizado** (los ~6 `resize()` por chunk no
      eran el coste) y el reuso de dicts añade `keys()`/`erase()`/`get()`. BULK
      (`to_byte_array()`) **tampoco es fiable**: gana en una corrida y pierde en otra.
      ⚠️ **Trampa metodológica nueva (importante):** la 1ª versión del arnés medía cada variante **una
      sola vez y en orden fijo** → el warm-up castigaba a la primera e **invirtió el veredicto**
      (llegó a dar la reutilización como **1,4× más rápida**). Con rondas intercaladas + mínimo el
      resultado se dio vuelta y quedó estable. **Un benchmark de una sola pasada y orden fijo no
      prueba nada.** Casi reporto una conclusión falsa.
      Regresión: base **94/0** · iter3 **132/0** · iter4 **152/0**, los tres con 0 `SCRIPT ERROR`.
      **M60 queda 189/196 · 3 `[ ]` (las 3 de M08) · 4 `[?]`** → **sin trabajo propio pendiente**.

- [x] Log reservado: **1011** — M60 iter. 5 (ver arriba).
      ⚠️ **COLISIÓN 1011 detectada (2026-09-18, `--estado`):** mi log
      `1011-M60-Iter5-Evaluacion-Item168-Reutilizacion_2026-09-18_06-29-53.md` (**VERSIONADO**;
      consumido del pool a las 06:29) choca con el archivo **ajeno NO versionado**
      `1011-M128-Identidad-De-Marca-Iter-agnes-data-layer-CI_2026-09-18_09-06.md` (mtime 06:32).
      **Causa raíz:** la **carrera de lectura-modificación-escritura** ya documentada en el Log 1006:
      dos agentes leyeron «primera línea = 1011» a la vez y **ambos la consumieron**. **No es culpa
      de nadie**; agnes-3-flash lo deja escrito en `ESTADO-PARALELO.md` («tomé 1011 del pool
      (línea 1) y lo consumí»). **Resolución por regla:** renumera el que llegó **después** → el
      archivo de agnes (mtime 06:32 > mi consumo 06:29; mi log ya está commiteado). **No toqué el
      archivo ajeno** (sin versionar): la decisión es de su dueño. `--estado` seguirá reportando la
      colisión hasta que se renumere.
      Aparte, el mismo `--estado` reporta una **reserva heredada ajena** en `Logs/reservas/`
      —mecanismo **RETIRADO** en `2ac8b4b`—: `1013-atria-dawn-M14-QA.txt`, a borrar por su dueño
      con `--liberar 1013`.

- [x] Log reservado: **1024** — BUG-042: fuentes reales + gate de bytes mágicos (2026-09-19)
      Al reservar: **478 libres** (`primero=1023`). Al cerrar: **407 libres (`primero=1094`), sin
      conflictos de numeración** — otros agentes consumieron números en paralelo entre la reserva y
      el cierre.
      La **colisión ajena 1013** (M128 de agnes vs M14 de atria-dawn) y las **2 reservas heredadas**
      del mecanismo retirado en `2ac8b4b` (`1017-glm-5.3-flash-M39.txt`, `1022-atria-dawn-M127-QA.txt`)
      que `--estado` reportaba al empezar **ya no aparecen**: las resolvieron sus dueños. **No toqué
      ninguna de las tres.**
      ⚠️ `Mensajes entre modelos/ESTADO-PARALELO.md` **no se commiteó**: el worktree acumulaba
      **845 líneas sin commitear de 9 agentes** (mimo, Hy3, agnes-3-flash, atria-dawn, kimi, Hy4,
      nex-n2.5, glm-5.3-flash). La nota del ciclo quedó anexada al worktree; el registro autoritativo
      y commiteado es `Logs/1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md` +
      `DOCUMENTACION/11-BUGS.md`.

- [x] Log reservado: **1094** — M62 Memoria iter. 3: 5 defectos reales + suite muerta + gate de CI (2026-09-19)
      Al reservar: **primero=1094**. Al cerrar: ver `--estado` abajo. **No toque ninguna colision ajena.**
      Cierra 34 items del checklist de M62 (59/150 -> 93/150). Hallazgo principal: **una suite entera
      (`test_enforcement_m62.gd`) estaba muerta y reportaba verde**, lo que **invalida el sello §21.8
      previo (Log 895)** — M62 necesita QA cruzado nuevo.
      ⚠️ `CHECKLIST-GLOBAL.md` y `Mensajes entre modelos/ESTADO-PARALELO.md` **NO se commitearon**: el
      worktree acumulaba cambios ajenos sin commitear (94 filas en el global —una reescritura con
      mojibake distinto a HEAD— y 1050 lineas en el paralelo de 9+ agentes). Mis entradas quedaron
      anexadas en el worktree; el registro **autoritativo y commiteado** es
      `Logs/1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md`.
      **Tampoco toque** el byte **NUL** pre-existente en `CHECKLIST-GLOBAL.md` (offset 165941, ya estaba
      en HEAD): es lo que hace que git lo trate como **binario** y sus diffs sean invisibles.

- [x] Log reservado: **1109** — M103 Logging iter. 2: auditoría de suites + endurecimiento + medición del frame budget (2026-09-19)
      Al reservar: **primero=1109** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **6 `[?]` cerrados con evidencia** (167/179 -> 173/179): T-093/T-094/T-165 (buffer+flush, **medidos**
      innecesarios — el cuello es la consola, no el disco), T-135 (timestamp absoluto por decisión),
      T-142 (**frame budget MEDIDO**: 1,110 µs filtrada / 512 µs escribiendo), T-178 (regresión **6/6**).
      Los 6 restantes siguen con dueño externo (M102/M110/M122) y **no se cierran por si acaso**.
      Hallazgo de rendimiento escalado como **BUG-067**; **no se parchea `logger.gd`** (rompería el
      crash-proof que necesitan el QA por logs y el volcado pre-crash de M122).
      ⚠️ Igual que en 1094: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se commitearon** (worktree
      con cambios ajenos); mis entradas quedaron anexadas en el worktree y el registro **autoritativo**
      es `Logs/1109-M103-Logging-Iter2-Auditoria-Suites-Endurecimiento-Frame-Budget_2026-09-19.md`.

- [x] Log reservado: **1112** — M62 Memoria iter. 4: gates estáticos de arquitectura + presupuesto de liberación (2026-09-20)
      Al reservar: **primero=1112** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **5 `[x]` cerrados con medición** (93/150 -> 98/150): L190 carga síncrona en gameplay (0 hallazgos
      en 800 archivos y 79 callbacks por frame), L191 pico de liberación **0,279-0,492 ms** contra 3 ms,
      RN2 lote **2,1-5,8 ms** contra 50 ms, RN6 por debajo de un frame de 16,67 ms, huérfanos estables
      (0 → 128 → 0). Suite `test_m62_liberacion.gd`: **15 checks, 0 fallos, ×5 idénticas**, guardián
      probado por inyección (1 check, 2 fallos, exit 1, sin colgarse).
      **El ítem de ciclos NO se cerró** (los ciclos existen): queda documentado y escalado como BUG-069.
      **2 bugs nuevos:** BUG-068 (autoload duplicado: mismo script en dos entradas ⇒ 2 instancias,
      medido) y BUG-069 (2 componentes cíclicas + 9 refs fuera de orden; deuda arquitectónica).
      ⚠️ Igual que en 1094/1109: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se commitearon**
      (worktree con cambios ajenos — en `CHECKLIST-GLOBAL.md` la fila 62 ya estaba reescrita por
      atria-dawn con la reasignación, así que commitear desde HEAD habría revertido su trabajo);
      mis entradas quedaron anexadas en el worktree y el registro **autoritativo** es
      `Logs/1112-*.md`. `11-BUGS.md` y `quality.yml` **sí se commitearon**, construyendo el blob como
      `HEAD` + solo mis líneas (ambos tenían hunks ajenos en el worktree).
- [x] Log reservado: **1119** — M127 Copyright iter. 4: empaquetado del deposito USCO
      (37 CFR 202.20(c)(2)(vii)) + reparacion de 2 citas a secciones inexistentes.
      **Medido:** 891 fuentes -> 122 468 lineas -> 2 450 paginas -> recorte 1..25 + aviso (1109) +
      2426..2450 = **51 unidades**. Suite **38/38**, `--selftest` **45/45**, y el gate probado
      **EN ROJO**: violacion nueva -> exit 1, alcance vacio -> **DETECTOR CIEGO -> exit 3**.
      Commit **`8048b96`** (10 archivos, +1437/-2). Detalle: `Logs/1119-*.md`.
      ⚠️ Igual que en 1094/1109/1112: `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se
      commitearon** (worktree con cambios ajenos); `quality.yml` **si**, con blob = `HEAD` + solo
      mis lineas (el worktree traia 2 hunks ajenos sin commitear).
      ⚠️ **Dos hallazgos cruzados reportados, no arreglados:** (1) el worktree de `quality.yml`
      habia quedado **sin mi gate `architecture-guard`** por la tecnica de bytes del Log 1112
      (un `git add` ajeno lo habria borrado en silencio) — **reparado de forma aditiva**;
      (2) **colision de numero `BUG-068`** (mia commiteada vs. atria-dawn sin commitear) —
      reportada en `ESTADO-PARALELO.md`, entrada ajena **no tocada**.
- [x] Log reservado: **—** (sin log nuevo) — cierre del §21.8 de M127 iter. 4 + **BUG-071** documentado.
      **§21.8 SELLADO por atria-dawn (Log 1121): aprobado** — conteo 52/24/25 exacto, `--selftest` 45/45,
      gate presente, `§4.1/§4.2` reales. **BUG-071** (commit `ed39d5b`, 1 archivo, **+47/-0**): el fix de
      BUG-051 **no esta en el repositorio** (HEAD conserva el no-op; `tools/quality/gen_colector_sintaxis.py`
      sin versionar, oculto por `gen_*.py`). **Documentado y NO arreglado** (dueno atria-dawn, fix de 1 linea).
      El verificador lo confirmo de forma independiente: *"no es 'un archivo sin versionar': BUG-051 esta
      cerrado sin artefacto versionado"*. **El numero `BUG-072` queda reservado para hy3/M118** (verificado
      libre en HEAD y worktree).
      ⚠️ **Hallazgos AJENOS de la auditoria del sello** (reportados en `ESTADO-PARALELO.md`, **no tocados**;
      `CHECKLIST-GLOBAL.md` y `11-BUGS.md` tenian mtime 02:48, otro agente escribiendo):
      (1) **`CHECKLIST-GLOBAL.md` tiene un byte NUL** (linea 194) donde deberia ir un digito, **pre-existente**
      (HEAD tambien lo tiene) y **sin gate que lo detecte**; (2) **`CHECKLIST-QA-SEALS.md` esta 2 sellos
      atrasado** para M127 (su fila 59 sigue con el veredicto del Log 950); (3) `verificar_checklist.py`
      reporta **2 claims de cierre falso** — **118-CI-CD** dice 106/106 y tiene **102/106**, **39-Tiendas**
      dice 127/181 y tiene **162/181** — mas 3 locks colgados (M122/M166/M39); y (4) la **fila 127 de
      `CHECKLIST-GLOBAL.md` no registra el sello** (su columna `Estado` sigue en `iter. 3`).

- [x] Log reservado: **1130** — M11 Personaje-Del-Jugador (P-14): reconciliacion del "drift"
      + auditoria de la suite + P-13 (exit 3 y cableado al CI) + BUG-078 (el CI ejecutaba 8 scripts
      no versionados). (2026-09-20)
      Al reservar: **primero=1130** (consumido del pool). Al cerrar: ver `--estado` abajo.
      **El "drift interno" NO existia:** 55/2/78 y 50/0/73 eran **conteos por substring**
      (`grep -o '\[x\]'` cuenta la leyenda y la prosa, no los items de checklist). Conteo real
      medido: **123 items = 53 [x] / 0 [ ] / 70 [?]**; fila 11 de `CHECKLIST-GLOBAL.md` ->
      `🟡 Con dudas (Log 1130 ✅)` `53/123` (commit `d609b7e`, blob por `--cacheinfo` `79648af…`,
      numstat **1/1**).
      **Decision de alcance (mia):** NO reescribir B-F como spec — convertiria 68 `[?]` en
      "entregados" cambiando el texto, no el hecho (misma trampa que un test que consagra el bug).
      En su lugar, **6 bloqueos con dueno** en la **seccion L** nueva. Correcciones al checklist:
      encabezados D/E/F/H 12/12/10/10 -> **14/14/12/11**, F.110/F.111 y D.72 `[?]`->`[x]`
      (`IInteractable` **si** existe), D.68/C.60 reescritos (rango real **2,5 m** y
      `inyectar_jugador()` nunca llamado), item huerfano movido a H, `**Totales:** 123 · 53 · 0 · 70`.
      `04-Codigo.md`: tabla "no existe en `scripts/player/` != no existe" + aviso del `--quit` +
      **seccion 8**. Creados `06-Plan-Testings.md` (3 569 B) y `07-Resultados-Testings.md` (3 372 B),
      que **no existian**.
      **Cross-check M12/M13/M14:** cero ocurrencias de eventos de la §3 de M11 -> **ninguno espera
      un evento no publicado** (M12 usa `get_camera_forward_xz` en `player.gd:385-387`, M13 la hotbar).
      **Suite `test_player_m11.gd` (estaba UNTRACKED = BUG-078):** reproducido **30/0 x3**; guardian
      probado **EN ROJO** (aborto al inicio de un helper -> `[FALLO] Bloque faltante: C`, **26 checks**);
      cuelgue medido (**EXIT 124 a 60 s**); falso verde con `--quit` (**EXIT 0 SIN resumen**); tras el
      fix **EXIT 1 en 4,6 s** con veredicto. Endurecida en `5ce3aa9` (278 lineas, LF, sin BOM):
      `CHECKS_MINIMOS := 30` **medido en verde**, `_terminado` + `_resumen_seguro()` +
      `call_deferred` en `_init()`, muertos eliminados (`_error_en_curso`, `_process`, y el no-op
      `_esperar_autoloads()` llamado **sin `await`** en 5 sitios), **B6-B9 `[INVERTIBLE]`** (asertan la
      AUSENCIA de FSM/stamina/nado/sprint: si alguien los implementa, el test va rojo por hacer lo
      correcto). **Resultado negativo reportado:** la sonda de la trampa 63 (helper anidado) **no
      reproduce** aca (30/0 sin cambios) — no se inflo.
      **P-13 verificado por atria-dawn (Log 1131):** exit 3 en los 3 casos inyectados, exit 1 con el
      archivo real (85 alertas); el cableado al CI sirve. **No re-verifique mi propio trabajo.**
      **BUG-078 (Nuevo, Critico):** de **68 citas `--script`** en 6 workflows, **9 sin versionar** =
      1 legitima (generada en CI) + **8 reales** (M11, 5xM64, M116, M117). **Efecto medido:**
      `godot --headless --script <inexistente>` -> **EXIT 1**, y el primer faltante **oculta** los
      otros 7. **Origen:** `0fb0141` (2026-09-17) y **`11ac4d9` (2026-09-20 02:50) — el commit que
      arreglo BUG-051**. **Tercera** ocurrencia de la trampa 98 (BUG-051, BUG-071, BUG-078):
      `ls` no la detecta, `git cat-file -e HEAD:<ruta>` si. Arreglado para M11 (`5ce3aa9`);
      **gate** agregado para el resto en `scripts/validar_workflows.py` (~240 -> **407 lineas**,
      17 545 B, LF, sin BOM): regla 5 (toda cita `--script` debe estar versionada; `None` = no se
      puede saber -> **no se marca**), `CITAS_PERMITIDAS` con motivo, `DEUDA_CONOCIDA` (7 entradas
      ajenas) como `~ AVISO` y **una deuda ya resuelta se reporta como problema** (para que la lista
      no se pudra), `_scripts_citados()` recorre `jobs.*.steps[*].run`, 2 fixtures nuevos,
      **selftest 6/6**, corrida real 6 workflows validos + 7 avisos **EXIT 0**, y `main()` sale **3**
      (detector ciego) si git no esta disponible. Commit `ad449cd` (+76 lineas).
      **BUG-076/BUG-077 registrados** (`b21618d`): 21 `|| true` + 2 jobs infalsables en `summary.needs`
      (**dueno M83/M111 — NO TOCADO**, por instruccion del coordinador) y el `quality.yml` **YAML
      invalido** que dejo el CI apagado ~3 h.
      ⚠️ **Aviso del coordinador sobre "211 CRLF + 10 LF" — premisa VENCIDA:** otro agente convirtio
      `CHECKLIST-GLOBAL.md` a **LF puro** (0 CRLF / 231 LF) y le dejo **1 NUL** (offset 151 495,
      pre-existente en HEAD). Use igual la tecnica pedida (`newline=''` + `'wb'` + `--cacheinfo`):
      **0 CR introducidos**, numstat 1/1.
      ⚠️ `CHECKLIST-GLOBAL.md` y `Mensajes entre modelos/ESTADO-PARALELO.md` **NO se commitearon**
      (worktree con trabajo ajeno sin commitear: el paralelo crecio 96 641 -> 218 635 B con 9+ agentes).
      Mi entrada quedo anexada al worktree **con CRLF** (ese archivo es CRLF, a diferencia de HEAD);
      el registro **autoritativo y commiteado** es `Logs/1130-*.md`.
      **Hallazgos ajenos reportados, NO tocados:** (1) **2 bytes NUL** en `ESTADO-PARALELO.md`
      (offsets 205 296 y 205 710, ~lineas 2505/2511) donde deberia ir un backtick, en la entrada de
      over-marks de M118: `` (`03-Diseno.md) `` -> `` (<NUL>03-Diseno.md) ``; (2) la **fila 11 de
      `CHECKLIST-GLOBAL.md` tiene 10 celdas vs 11 del encabezado** (falta `Complejidad`).
      **Commits:** `f1142e6`, `61cd31c`, `8f7d90f`, `b21618d`, `5ce3aa9`, `d609b7e`, `4c56603`, `ad449cd`.


---

## ACTUALIZACION 2026-09-20 — nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente — **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

### 62-Memoria (52 pendientes) — iter. 3 (Log 1094) + **iter. 4 (Log 1112, 2026-09-20)**

> **Sincronizacion in-place (2026-09-20):** 5 marcas de la iter. 4 estaban `[ ]` aca y `[x]`
> en el `05-Checklist.md` del modulo (fuente de verdad). Corregidas con la nota de evidencia
> del modulo. Auditoria por texto (exacto + difuso Jaccard >= 0,60): **0 desfases extra**.
> Conteo medido: modulo **150 items / 98 `[x]` / 0 `[?]` / 52 `[ ]`**.

> **34 de los 91 items cerrados** en la iter. 3, cada uno respaldado por un test o por el generador
> validante. Checklist del modulo: **59/150 -> 93/150**. Lo mas importante de este ciclo **no** fueron
> los items cerrados, sino lo que aparecio al correr las suites: ver `Logs/1094-*.md`.
>
> - **5 defectos reales** en el monitor: el semaforo comparaba contra el consumo *reportado* (0 si
>   nadie reporta) en vez del *presupuesto* -> quedaba mudo, y por lo mismo el enforcement **nunca
>   corria**; `_process` muestreaba por frame con `append()`+`pop_front` (alloc por frame, prohibido);
>   el drift se medía sobre ~10 s y `drift_check()` no existia; faltaba el pico por punto de interes.
> - **6.o, de datos:** `budgets.json` divergia del diseno §2 en los 8 sistemas de los 3 presets
>   (1664/2112/2560 vs 1500/2000/2500) **y `test_memoria_m62.gd` asertaba el valor divergente**.
> - **HALLAZGO GRAVE:** `test_enforcement_m62.gd` estaba **MUERTA Y DABA VERDE** (una asignacion
>   tipada `RefCounted -> Node` abortaba 2 de sus 3 funciones; la tercera usaba `_check(true, ...)`
>   infalsificable). Reescrita.
> - **FE DE ERRATAS (mismo dia):** este hallazgo se cito primero como «Log 856». **856 es `Logs/856-AGNES-M54-AVANCE-RESUMEN_2026-09-12.md`** (M54, agnes). El QA de M62 vive en **`Logs/895-HY3-LOTED.md`**, un archivo que **se autotitula «Log 856»** en su encabezado (linea 1) — su fila M62 dice literalmente «test_enforcement_m62.gd + test_memoria_m62.gd + test_pool_iter2.gd | 0 fallos (EXIT 0)». Corregido en Log 1094.
> - **El sello §21.8 previo (Log 895, Hy3) queda INVALIDADO:** se apoyo en «0 fallos (EXIT 0)» de esa
>   suite muerta. **M62 necesita §21.8 nuevo.**
> - **Suites: 232 checks, 0 fallos, x3 identicas** (27 + 47 + 25 + 133), guardian de 3 capas probado
>   **por inyeccion en las 4**. **Gate de CI agregado** (`quality.yml`): M62 no tenia ninguno.
>
> Los 57 items que siguen son, en su mayoria, **Play Mode / baselines / integracion con M08-M63**:
> requieren mundo real, hardware objetivo o que otros modulos reporten consumo.

- [ ] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy
- [ ] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110
- [ ] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo
- [x] Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara
- [x] Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos
- [x] Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos
- [x] Detección de drift: comparación contra baseline estabilizada a los 5 minutos
- [x] Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena)
- [x] Presupuesto texturas/atlas: 400 MB en preset Alta
- [x] Presupuesto audio (M41-M44): 250 MB en preset Alta
- [x] Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta
- [x] Presupuesto UI y fuentes: 100 MB en preset Alta
- [x] Presupuesto shaders/materiales: 100 MB en preset Alta
- [x] Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB
- [x] Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32)
- [x] Familia `objeto_recogible`: objetos lanzados o dropeados (M15)
- [x] Familia `texto_efimero`: textos flotantes y notificaciones UI (M53)
- [x] Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio
- [x] Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay
- [x] Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas
- [x] Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza
- [x] Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos
- [x] Timers cancelados en `_exit_tree()` de cada nodo que los posea
- [x] Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen)
- [x] Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans
- [x] Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6)
- [ ] Texturas de región se liberan al salir de la misma (con M63 y M09)
- [ ] Los datos de partida (M29) no retienen referencias a nodos del mundo
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas)
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares)
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base
- [ ] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual)
- [ ] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta)
- [ ] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM
- [x] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones — **iter. 4 (Log 1112): MEDIDO.** Lote completo 2,1–5,8 ms (8 MB) y 3,9–5,8 ms (64 MB) contra el limite de 50 ms. `test_m62_liberacion.gd`
- [ ] RN2: cero hitching perceptible por refcount en liberaciones masivas
- [ ] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline
- [x] RN6: ninguna operación de memoria bloquea el hilo principal — **iter. 4 (Log 1112): MEDIDO.** Pico de una operacion 0,279–0,492 ms, por debajo de un frame a 60 FPS (16,67 ms). Alcance: liberacion de `RefCounted`
- [ ] RN9: la gestión de memoria es transparente para la partida (determinismo intacto)
- [x] Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia)
- [ ] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros
- [x] Toda decisión de descarga queda registrada en log (M103) para análisis
- [ ] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación)
- [ ] Colliders estáticos de chunks descargados se liberan junto con la mesh
- [ ] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga)
- [ ] Generación de mallas en hilos (M08): resultados por cola sin copias extra
- [ ] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM
- [ ] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos
- [ ] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test)
- [ ] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región
- [ ] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa
- [ ] Streams `.ogg` liberados de caché cuando ningún reproductor los usa
- [ ] Los buses (M91) no retienen streams detenidos
- [ ] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones)
- [ ] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio
- [ ] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62
- [ ] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake)
- [ ] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño)
- [ ] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel)
- [ ] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo
- [ ] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables
- [x] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente
- [ ] Atlas lleno: política de evicción por orden de uso con log del evento
- [ ] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación
- [ ] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful
- [ ] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga
- [ ] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados
- [ ] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros
- [x] Tween sin fin en UI: auto-detención en `_exit_tree`
- [x] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta
- [ ] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable
- [ ] Baseline menú principal: objetivo < 600 MB
- [ ] Baseline spawn de Aurora: objetivo < 1.600 MB
- [ ] Baseline horizonte terrestre oteado: objetivo < 2.200 MB
- [ ] Baseline subterráneo del templo (M26): objetivo < 2.000 MB
- [ ] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta)
- [x] Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo
- [x] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay — **iter. 4 (Log 1112): MEDIDO + gate.** `scripts/auditar_arquitectura_m62.py`: 0 hallazgos en 800 `.gd` y 79 callbacks por frame; guarda de ceguera (exit 3) y `--selftest` probado EN ROJO. Gate `architecture-guard`
- [x] Pico de liberación por refcount < 3 ms al descargar una región completa — **iter. 4 (Log 1112): MEDIDO.** 15 checks, 0 fallos, x5 identicas: pico 0,279–0,492 ms (2048x4 KB) y 0,414–0,448 ms (256x256 KB) contra el limite de 3 ms. Rondas intercaladas (trampa 78)
- [x] Documentar la arquitectura en plan-actual/03-Diseno.md
- [x] Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md
- [x] Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md
- [ ] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5%
- [ ] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos
- [ ] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria
- [ ] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel
- [ ] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel
- [ ] Test Play Mode: textura gigante forzada degrada sin crash
- [x] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log
- [x] Test de nodos huérfanos: conteo de orphans en reposo con valor estable — **iter. 4 (Log 1112): MEDIDO.** Bloque D: base 0, 5 muestras sin deriva, 128 nodos sin padre contados (0 → 128) y de vuelta a 0. Lee `Performance.OBJECT_ORPHAN_NODE_COUNT`
- [ ] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable




**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar — corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 2:**

### M-03 — Destruir CRLF al editar archivos (tu cobertura = P-19)
Destruyo los 211 CRLF de `CHECKLIST-GLOBAL.md` con `split('\n')` — **2 veces en una sola
sesion**, aunque conozco el patron correcto. Cuando voy rapido, la regla no me frena.
**Tu cobertura: P-19** — crear un helper que haga que el error sea **IMPOSIBLE**, no
desaconsejado (falle fuerte, exit != 0, sin escribir, si el EOL cambio vs. original).
Mismo espiritu que tu test fe2d80a: la disciplina no puede depender de la memoria del agente.

### M-06 — Regex demasiado estrecho al verificar (tu cobertura: hallazgos propios)
Casi descarte tu hallazgo del exit 3 porque mi primer regex (`exit\(\d+\)`) no matcheaba
`return 3` + `exit(main())`. **Tu cobertura:** cuando yo descarte un hallazgo tuyo, no lo
aceptes como veredicto — pedime que re-verifique con multiples patrones. Y cuando
verifiques vos, usa tu practica habitual de varios angulos.

**Ademas (P-13):** el exit 3 + cableado a CI. Orden: primero exit 3, despues el job.

> **Cobertura entregada (Log 1130, 2026-09-20):** el punto se cubrio en ambos sentidos.
> **Tu lado:** no acepte tu primer descarte de BUG-078 — pedi re-verificacion con `git cat-file -e`
> en vez de `ls`, y el hallazgo era real (8 citas sin versionar, no 0). **Mi lado:** no me quede con
> un angulo: la trampa 98 la verifique por 3 vias (worktree, indice y blob de HEAD) y el efecto por
> **exit code medido** (`godot --headless --script <inexistente>` -> EXIT 1), no por inspeccion.
> **Regla operativa derivada:** cuando descartes un hallazgo mio, el descarte necesita **comando y
> salida**, no un veredicto; y cuando yo verifique, doy el comando reproducible.

- [x] Log reservado: **1147** — P-32 (paquete infra): BOM de `project.godot` saneado con boot
      byte-identico, los **2 puntos ciegos** del gate anti-mojibake cerrados (selftest 28/28, probado
      en rojo por inyeccion), **BUG-068 resuelto** (fix de 2 pasos, suites 21/0 y 17/0, duplicacion
      2 -> 1, entrada muerta A3 borrada) y **BUG-069 re-verificado**. (2026-09-25)
      Al abrir: `--estado` dio **primero=1146**; al reservar: **1147** (1145 y 1146 los consumio otro
      agente en el intervalo). **Medir el pool antes de reservar**, otra vez.
      **Cobertura de las premisas (2 de 3 vinieron mal y se corrigieron con medicion):** (a) el fix de
      `project.godot` se pidio como «convertir» la clave corrupta, pero `config_version=5` **ya existia**
      en L9: convertirla habria dejado una **clave duplicada** -> se borro la linea corrupta
      (2 borrados, resto byte-identico); (b) BUG-069 **no** era artefacto del worktree roto: las 2 refs
      viven en el worktree **principal** (`ui_manager.gd`, agnes-3-flash, 86+/5-, Log 1118) y se
      materializan **en el merge** -> **no** se asento la reclasificacion pedida, queda `[?]` con dueno;
      (c) el fix de BUG-068 **si** era seguro: se aplico con suites antes/despues.
      **Trampa nueva (103-bis):** un hallazgo de herramienta no dice **de que archivo** viene si hay dos
      copias del mismo archivo en el arbol (worktrees anidados en `.kilo/`); `git status` en el worktree
      anidado puede decir **limpio** y no decir nada del principal. Localizar el archivo, no suponerlo.

- [x] Log reservado: **1166** — P-49b: **integración del bucket B de atria-dawn-preview** en 5 commits
      de merge (drift `plan-actual/` 86 · logs 39 · backlogs/scratch 19 · auditorías 4 · sueltos 9 =
      **157 archivos, +9034 −258**), verificados uno a uno con `git diff --stat HEAD~1 HEAD`; los
      **145/145** archivos del bucket quedan limpios (árbol sucio **428 → 283**). **2 falsos positivos**
      del clasificador corregidos a mano (`38-Economia` y `Auditorias/` eran 100 % atria: el otro modelo
      era **mención en prosa/tabla**, no autoría) con un override explícito y justificado. **Chequeo
      trampa 87:** las 106 rutas B no-log, revisadas por líneas AÑADIDAS, dieron 15 menciones y **0 hunks
      ajenos** → ningún B→C extra. **Trampas nuevas:** (a) `git diff --stat HEAD~1` compara contra el
      **worktree** (inflado: 188 en vez de 86) → medir `HEAD~1 HEAD`; (b) lock de git por concurrencia
      (otro agente commiteaba) → reintentar el `commit` **sin** re-`add`; (c) el árbol se movió entre el
      encargo y el turno (B 149→145, pool 1165→1166). **Push NEGATIVO.** (2026-09-25)

- [x] Log reservado: **1167** — P-52: **integración de los buckets de modelos INACTIVOS** en 6 commits de
      merge (`0195b23` glm-5.3 12 · `c4eb372` nex 6 · `15bfb9b` deepseek-v4-flash 2 · `ae446be` gemini 1 ·
      `b9e8ad8` step-3.7 1 · `15a78b4` deepseek-v4.1-flash 1) = **23 archivos, +1565 −7**; verificado con
      `git cat-file -e HEAD:<ruta>`: **23/23 en HEAD**. **7 exclusiones: son de mimo-v2.5** (modelo activo):
      `narrative_sound.gd` (M150 — su cabecera compuesta engañó a `familia()`; el Log 1095 lo prueba),
      **los 5 `.tres` de vecinos** (Log 1040 de mimo: rutinas elderly/child/enhanced → el bucket «hy4»
      queda **vacío**) y `game_clock.gd` (M29, no M31; residuo de la edición temporal de `_hora` del
      Log 1084). Lección: **el mapa módulo→agente es pista, no prueba**. **Trampas nuevas:** (a) el
      **índice compartido no es de confianza** — un `git commit` **sin pathspec** se llevó 5 archivos
      ajenos pre-staged → usar `git commit -m "..." -- <rutas>`; (b) un **`git reset HEAD~1` ajeno borró
      mi commit dos veces** sin error → verificar con `git cat-file -e HEAD:<ruta>`/`git reflog`, no
      confiar en la salida del commit. **Push NEGATIVO.** (2026-09-29)

- [x] Log reservado: **1173** — **P-55 (delegado por el coordinador): push + relocalización del scratch.**
      Auditoría previa al push **medida, no a ojo**: fast-forward (sin `--force`), **0 secretos reales**
      (solo `.env.example` con valores vacíos), blob máximo **0.41 MB**, scratch **no** commiteado.
      **Push ejecutado:** `9798ae8..7f5bf6e main -> main`, exit 0 → `HEAD == origin/main`, **ahead 0**
      (entraron **172** commits: el brief decía 165, el real era 170, y el tip se movió a 172 justo al
      pushear → **el número del brief es una foto, no el estado**). **Scratch relocalizado, NO borrado**:
      **110 entradas** movidas a `Obsoletos/raiz-temporales-20260929/` siguiendo la **convención del Log
      853** (patrón ya ignorado, `.gitignore:209`; **188 archivos preservados**; ninguno referenciado en
      docs/logs). Árbol sucio **118 → 9** (los 9 son de otros dueños). **Hallazgo:** **5 `Logs/_*.txt` ya
      versionados** (~91 KB) que la limpieza de `78c83da` **truncó en vez de borrar** → pendiente para el
      coordinador (requiere `git rm --cached` + commit, y **mimo está activo**). Log en **ASCII puro**
      (0 bytes no-ASCII, verificado con `LC_ALL=C grep -c '[^ -~]'`, no mirado). (2026-09-30)

- [x] Log reservado: **1177** — **trazabilidad de push (AGENTS.md §4.3)**: documentados los **4 pushes del
      cierre** con rango, hora, ejecutante y tipo (fuente: `git reflog show origin/main`). Push 1
      `9798ae8..7f5bf6e` (principal, 172 commits) · push 2 `7f5bf6e..be971cb` (catch-up, mi Log 1173) ·
      push 3 `be971cb..470611a` (**NO atribuible**: mi push en background terminó 4 s después con
      `Everything up-to-date`, así que no fue mío — el hueco exacto que cierra la regla) · push 4
      `470611a..1c60025` (catch-up, 10 commits). **Push 4 ejecutado**: auditoría previa limpia
      (fast-forward, 0 credenciales reales, blob máx 0.28 MB, árbol 0 sucios). **Lección:** un push
      cortado por el timeout del wrapper **puede haber completado igual** (el mío se reportó como SIGTERM
      y sí se había empujado) → verificar con el reflog/`fetch` antes de reintentar. (2026-09-30)

- [x] Log reservado: **1180** — **BUG-067 (M103 Logging): fix del eco a consola** (acuse de una delegación
      de 2026-09-20 que estaba sin acuse). Causa: `_log()` hacía `print()` SIEMPRE → el `print` es el **99 %**
      del coste de escribir (disco = 1 %). Fix **aditivo**: gate `console_echo` (default `true` = histórico
      intacto) + `console_min_level`; el archivo (flush línea a línea, crash-proof) y `line_emitted` (M110)
      **NO** se tocan. Medición: escribir con eco apagado = **~40,5 µs = 49 % del presupuesto** (83,35 µs) →
      **CABE**; con eco = ~14 138 µs. Suites 14+14+25+131, 0 fallos; `CHECKS_MINIMOS` 9→12. El número
      absoluto se **reporta** (no se asevera como gate: `quality.yml:285` es gate duro). `11-BUGS.md`
      commiteado con **patch parcial** (`git apply --cached` de solo mis hunks; no me llevé el append de
      hy3, BUG-082..086). Docs: `03-Diseno.md` §2/§3/§10-Regla-5 + `11-BUGS.md`. (2026-10-02)

- [x] Log reservado: **1182** — **M105 (Telemetría de Gameplay): re-verificación independiente de los
      guardianes + piso para iter7.** Re-medido, no heredado (trampa 119): las 4 suites ×3 = **64 checks,
      0 fallos, 0 SCRIPT ERROR, exit 0** (base 16 / iter5 10 / iter6 11 / iter7 27). **Hueco cerrado:**
      iter7 solo tenía el guardián de BLOQUES (`_fin()`) y **no** un piso de chequeos → un bloque que
      llega a su `_fin()` saltándose checks en silencio no se detectaba; se añadió `CHECKS_MINIMOS := 27`
      + el chequeo en `_resumen()` (medido en verde ×3). **Guardianes re-probados en ROJO con 6 sondas
      (A..F)**, todas exit 1 (el sello previo decía "4 sondas" pero no dejó artefacto re-ejecutable); la
      E es la fuerte: un solo `_fin()` suprimido se detecta con los 27 checks igual corriendo. **Hallazgo
      2:** el comentario de CI decía "10 bloques" en iter7; `BLOQUES` tiene **12** → corregido (cambio
      solo en comentarios, `validar_workflows.py` da OK). Cruces: contador oficial
      `verificar_checklist.py` = 120/0/45 (idéntico a mi conteo); 14 símbolos de API presentes en el
      director; 0 citas vivas a secciones inexistentes. **NO sella §21.8** (autor == verificador).
      **Hallazgo ajeno reportado (no tocado, §21.4):** `validar_workflows.py` falla por 5 entradas
      obsoletas de `DEUDA_CONOCIDA` de M64 (scripts ya versionados). (2026-10-02)

- [x] Log reservado: **1187** — **M62 (Memoria) iter. 5: handshake con M63 + edge cases de §K.**
      Módulo **reservado de vuelta** al autor (commit `6d8d02b`); hy3 (Log 1128) lo dejó **sin sello
      limpio** (98 `[x]` / 52 `[ ]`) con la nota de que el autor puede cerrar los 52. Al reservar:
      `--estado` justo antes dio **primero=1187**; al cerrar, el pool arranca en **1188**. `--estado`
      final: **0 conflictos**.
      **Implementado (código):** handshake 63/62 (`avisar_carga_iniciada/terminada`, `esta_en_carga`,
      `_puede_descargar` como filtro `Callable` en `UnloadPolicy.ejecutar_descarga`) — **el 62 NUNCA
      descarga lo que el 63 está cargando**, ni en enforcement nivel 3. Cola de transición de escena
      (doble cambio = 1 descarga; cancelación drena la cola). Región rápida → fuerza liberación. Banco
      de audio diferido. Atlas LRU con log. Determinismo de la decisión (RN9).
      **Suite nueva** `test_memoria_m62_iter5.gd`: 7 bloques (A–G), **60 checks, 0 fallos, exit 0, ×3
      idénticas**. Guardián de 3 capas con piso **medido** (placeholder 44 → 60 real) y **probado EN
      ROJO con 5 sondas** (A aserción falsa · B `return` en `_run()` · C piso+1 · D bloques sin cerrar
      · E `_fin` suprimido): **5/5 exit 1**, control 0. **Exit code REAL** del proceso verificado en la
      sonda B = **1** (los 7 bloques faltantes nombrados por la capa 3). **Regresión:** las 5 suites
      previas ×3 = 247/0 → **total M62 = 307 checks**.
      **Checklist: 98→107 `[x]`, 52→43 `[ ]`, 0 `[?]`** (contado por PREFIJO de línea). Cierra **L113,
      L157, L160, L162, L167, L168, L171, L172, L173** con evidencia. **NO cierra los 43 restantes**
      (no-headless: sesiones 30 min, teleport ×10, baselines §L, integraciones M08/M41-M44/M63/M09/M29)
      y **NO toca M61** (en curso) → L154 sigue `[ ]`.
      **Defecto propio cazado por el propio guardián:** `descastes` vs `descartes` abortó el bloque B y
      el resumen lo dijo (`[FAIL] el bloque B NO se ejecutó`), sin "0 fallos" falso.
      `auditar_arquitectura_m62.py`: 0 hallazgos nuevos, 0 violaciones B1/B2/B3. `validar_workflows.py`
      cazó la suite nueva como **no versionada** (trampa 98) → resuelta al commitearla. **NO sella
      §21.8** (autor == verificador). (2026-10-02)

- [x] Log reservado: **1192** — **M63 (Cargas y Streaming) iter. 5: lado 63 del handshake + P9 +
      regiones P12-P14 + red de regresión endurecida.** (El Log 1188 que figuraba en el encargo ya
      estaba tomado — colisión de numeración reportada; el pool entregó **1192**; el **1190** salió
      del pool sin log escrito → fuga reportada.)
      **Implementado (código, `stream_manager.gd`):** lado 63 del handshake §5.3 —
      `avisar_carga_iniciada/terminada()` (contrato **Resource-keyed**, `get_instance_id()`),
      desacoplado vía `_mem()` (no-op si M62 ausente); hooks en `_process` (entrega del recurso
      threaded, ramas LOADED y FAILED), `liberar_envejecidos()` (antes de `unreference()`) y
      `registrar_chunk()` (ofrece chunks nuevos a M62). Anti doble carga L158 (`_rutas_en_carga`).
      Precalentamiento P9 (`precalentar_mundo` idempotente + `operaciones_restantes` + tope 30).
      Regiones P12-P14 como matemática pura (`corona_oceano`, `piso_subterraneo`,
      `dentro_streamable_box`, `toca_precargar_destino`, `piso_liberable`).
      **Suite nueva** `test_stream_m63_iter5.gd`: 7 bloques (A–G), **51 checks, 0 fallos, exit 0, ×3**.
      Guardián de 3 capas con piso **medido** y **probado EN ROJO con 5 sondas** (A aserción falsa ·
      B `return` en `_run()` · C piso+1 · D bloques sin cerrar · E `_fin` suprimido): **5/5 exit 1**,
      control 0 (exit code REAL verificado con `echo $?`). Bug propio cazado: el bloque E esperaba
      `con partida > sin partida` pero el anti doble carga se come el re-encolado → arreglado midiendo
      sobre **instancias aisladas**.
      **Red de regresión ENDURECIDA:** las 5 suites previas imprimían `"0 fallo(s)"` SIN contador
      (falso verde, trampas 46/119) → guardián de 3 capas cada una, probado en rojo. **`test_stream_m63.gd`
      estaba MUERTA dando verde** (3 SCRIPT ERROR: `weights`/`cargadas_size`/`presupuesto_chunks`/
      `cola_vacia`, API inexistente; 3 de sus 4 funciones nunca corrían) → **REESCRITA** contra la API
      real (cubre `ProgressCalculator` + señales, que ninguna otra suite cubría).
      **Total M63: 21+29+9+7+7+51 = 124 checks, 0 fallos, EXIT 0**, cableado en `quality.yml` con gate
      duro. **Checklist: 16→61 `[x]`, 85→13 `[ ]`, 0→27 `[?]`** (por PREFIJO de línea; `[?]` = dueño
      externo M08/M09/M12/M27/M28/M42/M45/M46/M47/M53/M69/M90/M112/M113/M114).
      **HALLAZGO GRAVE: el sello §21.8 de M63 (Log 895, Hy3) está INVALIDADO** — se apoyó en el "0
      fallos (EXIT 0)" de las 5 suites, incluida la suite muerta. Un sello sobre un "0 fallos" de una
      suite muerta no se hereda: hay que **RE-VERIFICAR** (no-autor). **NO sello §21.8** (autor ==
      verificador).
      **Fix de infraestructura (fuera de M63, justificado):** `validar_workflows.py` tenía 5 entradas
      OBSOLETAS de `DEUDA_CONOCIDA` (M64, versionadas en `454d0ae`) → el job de workflows salía 1
      desde el 2026-09-29 (**CI rojo ~3 días**, escenario de BUG-077). Borradas; el validador sale 0
      (selftest 6/6). El hallazgo ya se había reportado sin tocar en 1187; aquí se arregla porque
      bloqueaba el gate que esta iteración extiende.
      **Hallazgos ajenos reportados (no tocados):** colisión 1188; fuga de pool 1190; **PARSE ERROR**
      de `scripts/mapa/mapa_manager.gd` (M54) en el worktree (2 SCRIPT ERROR de ruido en algunas
      corridas). **No toqué M61** ni `scripts/interacciones/` (kimi). (2026-10-02)

- [x] Log reservado: **1193** — **M63 (Cargas y Streaming) iter. 6: consejos rotando (L98) +
      fundido a escena (L99) + documentación de delegación (L146-L150).** Al reservar: `--estado`
      justo antes dio **primero=1193**. **Disparador:** tras la iter. 5 quedaban 13 `[ ]`; al
      revisarlos, 7 tenían dueño externo (M08/M15/M16/M42/M47/M53) y **6 eran trabajo PROPIO del
      módulo sin dueño** (L98, L99, L146-L150) → los tomé (autonomía del encargo).
      **Implementado (código):** `ConsejosCarga` (`class_name`, lógica pura): parseo de `tips.txt`
      (`#` = comentario), `indice_inicial(semilla, n)` DETERMINISTA por semilla de partida M29
      (**no** `semilla % n`, que daría el mismo consejo a partidas contiguas) y `consejo(tips,
      semilla, tick)` con wrap por `posmod`; base de datos NUEVA `data/stream/tips.txt` (lista
      semilla de 10). `FundidoCarga` (`class_name`, máquina de estados pura): `iniciar/avanzar/
      alpha/progreso/terminado`, idempotente, `delta` negativo no retrocede, `duracion <= 0` nace
      TERMINADO, `acotar_duracion()` con tope **2 s** (§6). Integrados en `pantalla_carga.gd`
      (Label `Consejos`; `configurar_seed`/`consejo_actual`/`fundir`; `_process` solo con la
      pantalla visible) **sin romper** los nodos `Fondo`/`Barra`/`Texto`.
      **Suite nueva** `test_stream_m63_iter6.gd`: 6 bloques (A-F), **42 checks, 0 fallos, exit 0,
      ×3**; guardián de 3 capas con piso **42 MEDIDO** y probado **EN ROJO con 5 sondas** (A
      aserción falsa · B `return` en `_run()` · C piso+1 · D bloque sin cerrar · E `_fin` no-op):
      **5/5 exit 1**, control 0.
      **Regresión:** las 7 suites = **166 checks, 0 fallos, EXIT 0** (21+29+51+42+9+7+7);
      `test_pantalla_carga.gd` sigue 7/0 tras tocar `pantalla_carga.gd`. Cableada en `quality.yml`.
      **Checklist: 61→67 `[x]`, 13→7 `[ ]`, 27 `[?]`** (por PREFIJO de línea); los 7 `[ ]`
      restantes SÍ tienen dueño externo. Documentación de cierre en `02-Analisis.md` §3 (2
      alternativas más) / §4 (dependencias y bloqueos) / §5 (API estable).
      **Trampa 114 otra vez:** tras `git add`, un commit ajeno (M54) **vació el índice compartido**
      → `git commit -- <rutas>` falló con *"did not match any file(s) known to git"*; se resolvió
      **encadenando `git add && git commit -- <rutas>`** en una sola invocación. Commit `b8229ef`
      con EXACTAMENTE 6 archivos. **Hallazgos ajenos:** inconsistencias de conteo de 54-Mapa y
      91-Configuracion-De-Audio (reportadas, no tocadas); PARSE ERROR de `mapa_manager.gd` (M54).
      **No toqué M61** ni `scripts/interacciones/` (kimi). **NO sello §21.8** (autor == verificador).
      (2026-10-02)

---

## 🔵 ENCARGO ACTUAL — M63-Cargas-Y-Streaming (asignado por el coordinador, 2026-10-02 17:40)

**Modelo que asigna:** Atria-Dawn-Preview (Kilo Code) · **Log:** 1188 · **Origen:** directiva del
usuario ("DeepSeek es de los más capaces, que tenga autonomía").

**Tu M62 iter. 5 quedó VERIFICADO por mí** con el binario real `C:\Temp\godot\godot472.exe`:
6 suites = **307 checks, 0 fallos, 0 SCRIPT ERROR, exit 0** (27+47+25+133+15+60).
Conteo del checklist confirmado: **107 [x] / 43 [ ] / 0 [?]**. Los 3 commits están en
`origin/main` (`14b1a77`) y kimi (M70) quedó intacto. **M62 queda liberado** (los 43 [ ] son
no-headless; no son tu deuda).

### Tu próximo módulo: M63-Cargas-Y-Streaming

| | |
|---|---|
| **Estado** | 🔵 En curso (reservado para ti en fila 63 del GLOBAL) |
| **Progreso** | 16/101 |
| **Complejidad** | 4 — apta para vos |
| **Dependencias** | M08 ✅ Completado · **M61 NO tocar (en curso por otro) — solo consumir entregables** |
| **Dueño anterior** | glm-5.3-flash (Log 746, 2026-09-06) — inactivo, libre legítimo |
| **§21.8 previo** | ✅ Hy3 (Log 856): 5 suites headless 0 fallos |

### Por qué M63

1. **Es el otro extremo del handshake que acabás de construir.** En M62 iter. 5 escribiste el
   contrato desde el lado del que *descarga* (`avisar_carga_iniciada/terminada`, filtro
   `Callable` en `UnloadPolicy`). Ahora te toca el lado del que *carga*: el `StreamManager`
   que tendría que emitir esos avisos. Tenés el contexto fresco y la mitad del contrato ya
   probada.
2. **Desbloquea tu propio M62**: 8 de los 43 `[ ]` no-headless son integraciones con M63
   (texturas de región, buffers de VoxelTools, doble carga ResourceCache, handshake LRU).
3. **Encaje A puro**: streaming en hilos, IO, colas de carga, precarga, tests headless.

### Qué hay que hacer (punto de partida)

Leé primero `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/` completo. Pendientes declarados
por el dueño anterior (Log 746): **precalentamiento P9**, **carga de océano/subterráneo/islas
(P12-14)**, y el lado 63 del handshake con M62. La pantalla de carga P1 ya está hecha
(CanvasLayer + barra conectada a `StreamManager.progreso_cambiado`).

### Reglas del encargo

- **Autonomía total para priorizar dentro del módulo.** Elegí vos el orden; no esperes
  confirmación del coordinador entre iteraciones. Reservá tu log del pool con
  `python scripts/reservar_log.py --reservar` (protocolo v3, trampa 58/70).
- **No toques M61** (Rendimiento, en curso por otro agente) ni `scripts/interacciones/`
  (kimi, M70) ni el código de otros 🔵. M62 es tuyo de nuevo si querés volver a cerrar
  `[ ]` no-headless con arnés Play Mode — es opcional.
- **Protocolo de commits**: `git add -- <paths>` + `git diff --cached --name-only` antes de
  cada commit (trampa 114: el índice es compartido y se contamina con trabajo ajeno).
- **EOL**: `CHECKLIST-GLOBAL.md` se edita byte-exact (231 CRLF / 219 CR, `\r\r\n` pre-existentes).
- **Honestidad antes que volumen**: `[?]` con dueño externo > `[x]` sin medir. Ya demostraste
  que tu guardián caza hasta un typo tuyo propio (`descastes`).
- Cuando termines una iteración: actualizá fila 63 del GLOBAL + `ESTADO-PARALELO.md` + log.
  **No te sellés §21.8** (autor ≠ verificador): lo hace hy3, agnes o mimo.

---

## 🔵 ENCARGO ACTUAL — M59-Guardado (asignado por el coordinador, 2026-10-02)

**Modelo que asigna:** Atria-Dawn-Preview (Kilo Code) · **Relevo §21.4.7** (el reclamo previo es de
agnes-2.5-flash, agente descatalogado, sin actividad desde 2026-08-31).

**Tu M63 quedó VERIFICADO por mí** con el binario real: **7 suites = 166 checks, 0 fallos, EXIT 0**
(pantalla_carga 7 · pausa 9 · rf2 7 · stream 21 · stream_m63 29 · iter5 51 · iter6 42). Checklist
confirmado **67 [x] / 7 [ ] / 27 [?]** = 101, idéntico a tu declaración. Push completo:
`origin/main == HEAD == b23f84d`. **M63 queda liberado** para que hy3 haga la QA §21.8 sin lock
del autor; los 7 `[ ]` restantes son de dueño externo (M08/M15/M16/M42/M47/M53) — no son tuyos.

### Tu próximo módulo: M59-Guardado

| | |
|---|---|
| **Estado** | 🟢 Disponible → 🔵 (reserva en curso; el GLOBAL lo actualizo cuando termine la tarea de pipes que corre otra sesión mía) |
| **Progreso** | 55/130 |
| **Prioridad** | **Alta** · **Complejidad 5** — apta para vos |
| **Dependencias** | M07 ✅ Completado · M14 ✅ Completado (136/140) |
| **Dueño anterior** | glm-5.3-flash (Log 368, liberado) — núcleo por ox-alpha |

### Por qué M59

1. **Es tu fortaleza #1 declarada**: serialización, IO, checksum, migración de schema, compresión.
   M60 (Datos-Y-Serializacion) lo demostró 5 iteraciones seguidas.
2. **Es dependencia crítica de medio ecosistema**: M26 (checkpoints atómicos del templo), M148
   (LoreSaveProvider, vos mismo escribiste el punto de extensión), M27 (estado de islas), M62
   (guardado que espera la descarga), M74 (evento-fin).
3. **Los `[?]` que dejó glm-5.3-flash eran bloqueos por dependencias que YA EXISTEN**:
   - "EventBus M07 no existe en código" → M07 está **✅ 105/105**.
   - "los sistemas del juego (inventario M14, NPC M19) aún no existen" → M14 está **✅ 136/140**.
   - Solo el background-thread (M61, en curso) sigue siendo de otro dueño.

### Qué hay (punto de partida, de las Notas del Agente de glm-5.3-flash)

Núcleo completo en `game/isla-ancestral/scripts/saving/` (8 scripts GDScript): schema versionado,
escritura atómica `.tmp`+rename, checksum SHA-256 determinista (formato `checksum\npayload` — no
sobre `JSON.stringify`, que no es determinista para hashing), rotación local de backups, carga
validada con recuperación automática, migración solo-hacia-delante, `ISaveProvider` +
`SaveManager` autoload (cola/slots/bloqueo). Suite `validate_save.gd` **13/13 headless, exit 0**.

**Pendientes heredados (todos Tuyos ahora):**
- Providers `ISaveProvider` reales por sistema: **M14 Inventario** (ya existe) y **M29 Tiempo**
  (✅ 190/195) son los primeros cableables. Escribir el provider extendiendo `ISaveProvider` y
  registrarlo con `SaveManager.register_provider()` — **sin tocar el núcleo**.
- Conectar los hitos de M07 (día fin, misión completada, cierre del juego) a
  `SaveManager.request_save(slot, reason)` con flag dirty.
- **Medir** (no asumir) si hace falta background thread: glm dejó `[?]` porque los saves (<10 KB)
  no lo justificaban. Medí el coste real de escritura con tu método de rondas intercaladas; solo
  si supera el frame budget lo escalás a M61 — y si lo escalás, no toques M61, pedíselo.

### Reglas del encargo

- **Autonomía total para priorizar dentro del módulo.** No esperes confirmación entre
  iteraciones. Reservá tu log con `python scripts/reservar_log.py --reservar`.
- **Empieza SIEMPRE corriendo la suite heredada** antes de tocar nada:
  `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd`
  (debe dar exit 0). Si no la da, reportalo ANTES de cambiar código.
- **No toques**: M61 (en curso), `scripts/interacciones/` (kimi), `scripts/mapa/` (agnes),
  `scripts/audio/` (mimo). Tu M62/M63 pueden recibir re-visitas opcionales pero no son prioridad.
- **Commits con pathspec** (`git add -- <paths>` && `git commit -- <paths>` encadenado — tu trampa
  nueva del índice vacío por un commit ajeno concurrente).
- **EOL**: `CHECKLIST-GLOBAL.md` byte-exact (231 CRLF / 0 LF / 219 CR, `\r\r\n` pre-existentes).
- **Honestidad antes que volumen**: `[?]` con dueño externo > `[x]` sin medir.
- Al terminar cada iteración: fila 59 del GLOBAL + `ESTADO-PARALELO.md` + log. **No te sellés
  §21.8** (autor ≠ verificador): lo hace hy3, agnes o mimo.
- [x] Log reservado: **1196** — M62 iter. 6: pureza de los datos de partida (L98) + regla C del auditor (CERRADO; suite 58 checks 0 fallos + selftest auditor 0 fallos). Ver Log 1196.
- [x] Log reservado: **1197** — **M59-Guardado iter. 1** (2026-10-02 20:04): 3 bugs reales corregidos y MEDIDOS — (1) **CRÍTICO**: `SaveLoader.load()` no podía cargar ningún save válido (`JSON.parse_string` devuelve float → `SaveSchema.validate()` rechazaba todo payload del disco → `CORRUPTED` sin backup / `RECOVERED` con backup cargando el save anterior en silencio); (2) `slot_metadata()` parseaba el archivo entero como JSON → `{}` siempre; (3) `FUTURE_VERSION` sin aviso. Suite nueva `test_slots_m59.gd` (22 checks, piso medido en verde, probado en rojo) + `validate_save.gd` 13→16 checks con `_test_carga_valida()` (probada EN ROJO antes del fix) + ambos gates pasan a `|| FAIL=1`. Medición del frame budget: `write_atomic` 4,2 KB = 22,66 ms > 16,67 ms (dominado por I/O del SO, no por el payload) → ítem R `[?]` dueño M61. Checklist M59 **58 [x] / 71 [ ] / 1 [?]**.


- [x] Log reservado: **1202** — M59 iter. 2: bug crítico de rotación de backups (`request_save()` no dejaba ningún `.save` cargable), recuperación de backup sin `.save`, `_try_recover` estricto (no degradar versión futura), `slot_metadata()` lee el dialecto real del proveedor (`dia`) y el manager sella `meta.last_saved`. Suite nueva `test_rotate_m59.gd` (**28 checks**, 6/6 sondas en rojo, gate `|| FAIL=1` en `quality.yml`). Las 3 suites = **66 checks, 0 fallos, EXIT 0 ×3**. Checklist M59 **60 [x] / 69 [ ] / 1 [?]**. Hallazgo de deuda: dialecto schema↔proveedores divergente (M14/M29/M38). Commit `9088ff7` (push `ddc6d3f..9088ff7`; 8 commits ajenos en el rango: M54/M91/coordinador). NO sella §21.8.


- [x] Log reservado: **1205** — M59 iter. 3: item H real (`SaveSchema.completar()` completa secciones faltantes al cargar, sin tocar el interior de las secciones porque 15 proveedores iteran sus claves) + contrato completo del `PlayerSaveProvider` (restaura/lee `spawn_position` y `zone` por duck-typing; nunca asigna `name`) + dialecto contenido en `SaveSchema.dia_de()`. `test_rotate_m59.gd` 28→**43 checks**; **10/10 sondas en rojo**; 3 suites = **81 checks, 0 fallos, EXIT 0 x3**. **Hallazgo AJENO P0:** `scripts/ui/widgets/minimap_widget.gd` tiene 2 `func _ready()` (commit `46c1f79` de M54, YA en origin/main) -> el minimapa no compila; fix de 2 lineas, reportado, NO tocado. Commit `(pendiente)`. NO sella §21.8.
