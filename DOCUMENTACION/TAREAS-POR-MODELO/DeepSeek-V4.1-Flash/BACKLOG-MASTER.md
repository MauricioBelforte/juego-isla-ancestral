**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# BACKLOG MASTER — DeepSeek-V4.1-Flash (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]` / `[?]` de los `05-Checklist.md` de los 27 módulos cuyo **Recom** en `CHECKLIST-GLOBAL.md` es de la familia DeepSeek (`DeepSeek`, `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp` — descatalogados y ruteados a V4.1 Flash, ver `10-GUIA-COMPARATIVA-MODELOS.md` §5.B3/§17).

> **Curación 2026-09-11 (v2):** la v1 era un **volcado mecánico ordenado por la fila de `CHECKLIST-GLOBAL.md`** — 2.192 tareas mezcladas sin criterio de capacidad. Esta v2 las **reordena por encaje real** con mis fortalezas declaradas (§5.B3): *uso agéntico de herramientas, concurrencia/hilos, IO de archivos, serialización y saves, tests headless, bugs de lógica, datos estructurados, tooling/CLI/empaquetado, validación y sandboxing*. Debilidades que **excluyen** tareas: razonamiento puro de diseño, horizonte largo en terminal, **visión de muestra pequeña (NO soy aprobador visual final)**.

**Módulos asignados:** 27 · **Tareas propias pendientes:** 2.192 · **Libres ahora:** 1.563 · **En manos de otro agente:** 629
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
| A1 | 60 | 60-Datos-Y-Serializacion | 🟡 Liberado (iter. 3 ✅) | 191/196 | 0 / 5 | **Serialización, IO, checksum, migración de schema, compresión ZIP.** Mi fortaleza #1 | `60-Datos-Y-Serializacion/checklist.md` |
| A2 | 68 | 68-Transporte-Y-Navegacion | 🟡 Liberado (iter. 1 ✅) | 36/131 | 10 / 95 | Grafo `.tres`, API, eventos, dijkstra, persistencia de waypoints: **data-driven + headless** | `68-Transporte-Y-Navegacion/checklist.md` |
| A3 | 87 | 87-Localizacion | 🟡 Con dudas | 90/136 | 16 / 45 | Pipeline i18n/gettext, convención de claves, cache, validador `.po`. **Predecesor `deepseek-v4-flash` → reclamable §21.4.7** | `87-Localizacion/checklist.md` |
| A4 | 116 | 116-Instalador | 🟡 Con dudas | 91/198 | 21 / 41 | Build/empaquetado, permisos, rollback, firma digital, update. **Tooling puro** | `116-Instalador/checklist.md` |
| A5 | 27 | 27-Islas-Del-Mundo | 🟡 Liberado (iter. 1 ✅) | 83/192 | 93 / 16 | Núcleo data-driven del archipiélago 1+12: `IslandRing` + `IslandDefinition` (13 biomas M09, `validar()` 13 errores) + `Archipielago` + `IslandRegistry` (autoload) + `IslandProps` + generador del dataset (13 `.tres`) + test **171/0** | `27-Islas-Del-Mundo/checklist.md` |
| A6 | 101 | 101-QA-General | 🟡 Con dudas | 209/209 | 0 / 0 | **0 `[ ]` pero "Con dudas": falta QA cruzado §21.8 y cierre formal.** Verificación = mi terreno | `101-QA-General/checklist.md` |
| A7 | 123 | 123-Modding | 🟡 Con dudas | 20/106 | 4 / 24 | Esquema data, carpeta `assets/` por id, log del módulo, sandbox de mods | `123-Modding/checklist.md` |
| A8 | 52 | 52-Particulas-Y-VFX | 🟡 Con dudas | 21/130 | 10 / 72 | **Solo la parte no-visual:** pooling (M62), precalentamiento, determinismo por semilla, límites de rendimiento | `52-Particulas-Y-VFX/checklist.md` |
| A9 | 148 | 148-Lore-Ambiental | 🟡 Con dudas | 14/114 | 12 / 100 | **Solo la parte de datos:** gate de CI por IDs duplicados, migración v3.1, tests de persistencia | `148-Lore-Ambiental/checklist.md` |
| A10 | 105 | 105-Telemetria-De-Gameplay | 🟡 Liberado (iter. 6) | 157/163 | 1 / 6 | Módulo **cerrado por mí**; quedan 6 `[?]` con dueño externo (datos reales, hooks M22, integración M102) | `105-Telemetria-De-Gameplay/checklist.md` |
| A11 | 124 | 124-Contenido-Generado-Por-Usuarios | 🟡 Con dudas | 10/106 | 3 / 41 | **Solo infra:** compresión 4K→2K, límite de tamaño, sin coords del save, telemetría sin PII | `124-Contenido-Generado-Por-Usuarios/checklist.md` |
| A12 | 26 | 26-Templo-Subterraneo | 🟢 Disponible | 0/115 | 21 / 111 | **Solo lo verificable:** guardado atómico por checkpoint, suites de softlock/exploit, telemetría de puzzles | `26-Templo-Subterraneo/checklist.md` |

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
| C4 | 26 | 26-Templo-Subterraneo | 🟢 Disponible | 0/115 | (ver A12) | Diseño de salas, pórticos, ambientación: **otro especialista** |
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
| 28 | 26 | T-053 | Guardado atómico en cada checkpoint | Save atómico |
| 29 | 26 | T-084 | Testear softlocks por zona (suite M66) | Suite de tests |
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

**Regla del ciclo:** bloquear el módulo (reserva en `Logs/reservas/` + `🔵` en el checklist) → leer la documentación → codificar → test headless → documentar (04-Codigo, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO) → escribir el log → borrar la reserva → **siguiente módulo**.

> ⚠️ **Numeración de logs — resincronizar SIEMPRE.** En el ciclo 5 reservé el **830** y GLM-5.3 lo usó en paralelo para M32; hubo que pasar a **831**. Antes de crear un log: `ls Logs/*.md | grep -oE '^[0-9]+' | sort -n | tail` **y** revisar `Logs/reservas/`, porque `ULTIMO_NUMERO.txt` puede quedar desfasado.

**Estado de la cola inmediata (30 tareas):** cerradas las de **M60** (T-018, T-019→`[?]`, T-145→`[?]`), **M68** (T-017, T-002, T-003, T-020, T-049) y **M27** (T-001, T-003, T-004, T-005, T-021…T-040, T-121, T-123, T-124, T-171, T-175, T-180, T-183, T-186). **Siguiente en la cola: M87 (Localización)** — pipeline i18n/gettext, convención de claves, cache, validador `.po` (§21.4.7 reclaim).
