**Modelo:** atria-dawn (Atria Dawn Preview, Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-16

# BACKLOG MASTER — atria-dawn (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]`/`[?]` de los `05-Checklist.md` de cada módulo (fuente de verdad).
> **Primera sesión 2026-09-16.** Identidad confirmada por el usuario: **atria-dawn / Kilo Code** es mi nombre de firma permanente.
> Ver autoevaluación honesta completa en `10-GUIA-COMPARATIVA-MODELOS.md` §20 y ficha §5.M.

## Criterio de encaje (mis fortalezas #1 del catálogo, ver §20 de la guía 10)

| Nivel | Qué es | Mi rol |
|-------|--------|--------|
| **A — Núcleo de especialidad** | Orquestación de herramientas/MCPs, automatización de pipelines multi-herramienta, tool use sobre APIs de muchos módulos (duck-typing), auditoría código↔checklist, reconciliación de sobre-cierres, tests headless con guardián anti-falso-verde, investigación web profunda, ciberseguridad/auditoría de código | **Ejecuto de punta a punta** (código + test + log) |
| **B — Sistemas con criterio de diseño** | Lógica data-driven de gameplay + verificación; documentación técnica | Ejecuto la **parte técnica/verificable**; la decisión la dejo `[?]` con dueño |
| **C — Visual / arte / audio / contenido** | Assets, VFX, arte, narrativa, música, UI visual | **NO soy aprobador visual** (solo texto, error 400 confirmado). Solo plumbing data-driven; aprobación final = otro especialista / usuario |

**BFCL v4 77.0 (#1), AutomationBench 53.8 (#1), CyberGym 86.5 (#1), DeepSearchQA 96.0 + BrowseComp 92.5 (#1)** — esas son mi base. **SWE-bench Pro 59.6** → no soy el pico de coding puro; complejidad 5 aislada → liberar.

**Excluyo por encaje:** módulos V2 sin visión operativa (soy solo texto), arte 3D/Blender, ofimática pura (JobBench 50.3, último del frente), pico algorítmico complejidad 5 aislado, generación de assets.

## Módulos asignados (v1 curado)

| # | ID | Módulo | Estado global | Encaje | Subcarpeta |
|---|----|--------|---------------|--------|------------|
| 1 | 110 | 110-Debug-Menu | 🟡 Con dudas — **LIBERADO por mí (log 928)** | **A** — backend completo y verificado: **67 checks / 0 fallos / 0 SCRIPT ERROR**; 121/225 `[x]` con evidencia; 104 `[?]` todos UI con dueño. Próximo sobre este módulo: QA cruzado §21.8 (otro modelo) o M110-UI | `110-Debug-Menu/checklist.md` |
| 2 | 107 | 107-Backups | 🔵 En curso por **agnes-3-flash** (reserva 927) | **A pero EN ESPERA** — QA cruzado post-agnes (directiva del usuario). Reviso cuando agnes libere; si algo me genera dudas lo arreglo o mejoro | `107-Backups-QA/checklist.md` |

**Totales v1:** M110 ~120 subítems verificables + M107 QA ~12 = **~132 ≥ 100** (regla GUIA-METODOLOGIA §7).

**Expansión si hace falta:** M126 Marketing Legal (🟢 sin reserva, agnes-2.5 inactivo), M164 Endgame (🟢 Recom Hy4, complejidad 4 — solo la parte data-driven), M71/M72 (liberados por glm-5.3 con <10 ítems sueltos).

## Cola de trabajo inmediata (bucle)

| Orden | Módulo | Tarea | Qué es | Por qué yo |
|-------|--------|-------|--------|-----------|
| 1 | 110 | T-001..T-004 | Verificación headless de las 2 suites existentes + probe + config JSON (evidencia base) | **HECHO ya** (18/0 + 22/0 + 0 SCRIPT ERROR) — auditoría código↔checklist |
| 2 | 110 | T-005..T-012 | Implementar gaps cerrables con test: RF4 `set_season`, RF11 `reset_npc`, RF12 `reset_puzzle`, RF15 `toggle_fps`, RF13 `regenerar_chunk` real, RF17/RF19 toggles faltantes | Orquestación duck-typing de APIs de M29/M19/M24/M08 = tool use, mi #1 |
| 3 | 110 | T-013..T-020 | Reconciliar el checklist revertido: marcar `[x]` con evidencia de código real, dejar `[?]` con dueño (visuales RF14/16/18 → DebugUtils/M08; UI paneles → M53), cerrar el sobre-cierre del `Totales` | Auditoría honesta `[x]` vs `[?]`, CyberGym #1 |
| 4 | 110 | T-021..T-024 | Test nuevo `test_m110_iter_atria.gd` con guardián anti-falso-verde (marcador `_fin` por bloque + inyección de aborto probada) cubriendo los gaps nuevos | Patrón probado del proyecto (M124/M26/M27), tests headless |
| 5 | 110 | T-025..T-028 | Documentar: 04-Codigo.md (rutas reales vs diseño), Notas del Agente, log 928, liberación de los 4 registros | Cierre administrativo honesto |
| 6 | 107 | Q-001..Q-012 | **COMPLETADO (log 934)** — QA cruzado §21.8 ejecutado: verificador ≠ autor (agnes-3-flash log 927). Re-ejecuté test_backup_m107.gd yo mismo: **12/0, 0 script errors**. Verifiqué infra PS 4 + backup.yml + 03-Diseno.md en disco. **Veredicto: trabajo de agnes VÁLIDO y honesto.** Correcciones: Totales mentía (137/137 → real), flip caja-a-caja ejecutado (47 [x] con evidencia / 17 [?] con dueño / 112 [ ]), Notas de agnes restauradas (estaban sin commitear). | Verificador ≠ autor; mi CyberGym #1 |

## REGLA OBLIGATORIA — Codificación UTF-8
> UTF-8 sin BOM siempre (§AGENTS 28). Si un diff muestra mojibake (`Ã`, `â€`, `ðŸ`), lo corrijo antes de seguir. **Esta guía ya sufrió doble encoding — no repetirlo.**

## NO TOCAR (agentes activos hoy, 2026-09-16)
- **M107** 🔵 agnes-3-flash (reserva 927, 05:20) — tengo el QA anotado, NO trabajo ahora
- M105 🔵 DeepSeek-V4.1-Flash (reserva 926, 02:30)
- M84/M150/M166 (mimo-v2.5/OpenCode) · M66/M92 (glm-5.3-flash/Cline) · M113/M115/M106/M96 liberados por agnes-3-flash (logs 919/921/922/924)

## Historial de iteraciones (bucle)

| Iter | Módulo | Estado | Log | Qué hice (resumen) |
|------|--------|--------|-----|--------------------|
| 1 | **M110** Debug-Menu | 🟡 Liberado | **928** | Reconciliación de auditoría: 5 stubs falsos corregidos, gaps RF4/RF11/RF12/RF13/RF15/RF17/RF19, 67 checks headless 0 fallos, checklist 121/225. (log recreado 2026-09-16 tras borrado por git-clean de otro agente) |
| 2 | **M107** Backups | 🟡 Con dudas | **934** | QA cruzado §21.8 (verificador ≠ autor agnes-3-flash): trabajo VÁLIDO. Test 12/0 reproducido; infra PS 4 + backup.yml verificadas. Correcciones: Totales mentía (137/137 → real), flip 47 [x]/17 [?]/112 [ ]. (log recreado tras borrado) |
| 3 | **M15** Recursos | 🔵 En curso | **940** | Iter 6: **2 fixes reales** — (1) doble entrega de drops en spawner `_on_nodo_agotado` (fibra delta=6, máx simple 4; tests previos usaban `>=1` sin cota); (2) stub `cantidad_de()` que devolvía 0 → ahora `Inventario.count_item()`. Suite nueva 3 fallos→0; 7 suites de regresión 0 fallos. Flip 75/222 → 99/222. |
| 4 | **M32** Clima | ✅ Verificado | **942** | QA cruzado §21.8 (≠ autores glm-5.3-flash/GLM-5.3/agnes-2.5-flash): núcleo genuino — 4 suites 0 fallos 0 script errors, determinismo+cozy+persistencia verificados en código, 5 claims de integración ✓. **4 hallazgos:** citas fantasmas §2.5-§2.15 (no existen; lo real es §6/§7/§8), Totales staleda 96/25→121/0, flip sin iter documentada, 1 cita sin respaldo. ⚠️ "✅" = núcleo+contratos, no features runtime. |
| 5 | **M09** Terreno-Geografia | 🟡 (revertido ✅) | **944** | Segundo QA §21.8 (≠ Deepseek V4 Flash; primer QA fue Hy3 Log 848). Diseño 03-Diseno genuino (16 formaciones, 13 biomas, transiciones) + regla anti-clon IslandGenerator **cumplida y validada automáticamente** (validador_isla_raiz.gd). **7 flips:** sección F entera (claims "consumido por M10/M50/M61/M71-M74/M66" FALSAS — 0 refs a data/biomes\|formations\|poi, FormationRecipe no existe; M27 creó su propio catálogo), H.8 "8 POI" (son 7), A17 stale (BUG-030). **Corrección propia:** voltee H.12 con "cero código" — info incompleta, terreno_horizonte.gd (360 l.) es entregable real; revertí. 105/105 → 98/7. |
| 6 | **M10** Generacion-Del-Mundo | 🟡 (revertido ✅) | **945** | Tercer QA §21.8 — los dos previos (hy3 Log 961 + Hy3 Log 848) eran el **mismo modelo** y solo chequearon presencia de archivos. **Test nuevo** test_generacion_m10_atria.gd (no existía ninguno): 4 pass (determinismo 2 órdenes, semilla, agua pisable, alturas) + 1 fallo documentado. **16 flips:** faltan 3 capas del pipeline de 8 (formaciones/cuevas/estructuras — 0 código), el generador **no consume nada de M09** (confirma cadena del Log 944), carbón/oro no existen como bloques, no es autoload ni hay knobs. **BUG-043** real: bioma snow inalcanzable (mountain check antes que snow; snow=0/2000, alt máx 38>32) — delegado, requiere visto bueno del usuario (Log 791). BlockCatalog muerto en runtime. 106/106 → 90/16. |
| 7 | **M08** Mundo-Voxel | ✅ **MANTIENE** | **949** | QA §21.8 con **veredicto diferenciado**: 0 flips, 105/105 [x] se sostienen. El checklist es honesto (todos los items son "Diseñar/Documentar/Definir" + nota de cierre que delega validación física a M1/M61) y **hay código vivo** (block_type.gd, 30 constantes, central para M10/main_island/M15). Pero la **documentación mentía — corregida in-situ**: §2 listaba 5 archivos de los que 4 no existen (fachada VoxelWorld nunca materializada), §3 tenía firmas diseñadas vs reales divergentes (world.try_extract no existe; reales en tool_controller.gd), claims stale de MiMo (no hay LAVA; BlockCatalog muerto). Fix de claim "21 bloques" → 31 modelos. Pendiente nuevo: `has_gravity` sin consumidores. |
| 8 | **M11** Personaje-Jugador | 🟡 (revertido ✅) | **950** | QA §21.8 — **sobre-cierre más profundo del ciclo: 73 flips** (M09: 7, M10: 16, M08: 0). QAs previos (hy3 Log 835 + Hy3 Log 848, mismo modelo) solo verificaron "archivos presentes". Secciones B–F afirman sistemas implementados que **no existen**: player.gd (1160 l.) tiene **0 menciones** de stamina, FSM/StateMachine, IInteractable, esporas de luz, nado/buceo, sprint, selección de personaje, AnimationPlayer/pasos, guardado de posición. Live solo: VoxelBoxMover + salto (8/20g) + terreno↔M155 + edición bloques + hotbar M13. Constantes contradichas (hitbox capsule 0.4r×1.5 vs 0.6×1.8; walk 5.0 vs 4.2; gravity 20 vs 12; salto 1.6m vs 1.2m). 6/7 scripts previstos + 3 .tres no existen; contratos §3 nunca publicados. Secciones I/J se mantienen [x] ("Definir" + M155 live). 122/122 → 49/122. |

**Iter 9 — siguiente en la cola del bucle (mi encaje A/B):**

1. **Ciclo mundo-voxel + jugador cubierto:** M09 🟡, M10 🟡, M08 ✅-mantenido, M11 🟡 (73 flips). Quedan como decisión del usuario: recetas M09, capas 3/4/8 de M10, fix BUG-043, y ahora también FSM+stamina+interacción+nado+selección de M11.
2. **Siguiente target (lección 20):** re-QA de ✅ con sello hy3/Hy3 de tipo "presencia de archivos". **M12 Cámara** (102/102, Log 962) es el natural — consumidor directo de M11 (pivot tras el hombro) y código live (camera en boot). Después: M14 Inventario ya tiene tests reales → menor prioridad.
3. Antes de reservar: `CHECKLIST-GLOBAL.md` + `ESTADO-PARALELO.md` + guía 08, reservar log con el bucle anti-colisión (§6.1.a — el último libre salió 950; pueden haber tomado otros), bloquear los 4 registros. **Commitear el log al terminar.**

**Lecciones aprendidas iter 1-3 (para no repetir):**
- **Off-by-one en scripts de flip por indice**: los indices de array de PowerShell son 0-base y las lineas del Read tool son 1-base. Siempre verificar con un print ANTES de escribir en masa.
- **`String.join()` en GDScript 4.x es método del String separador**: `", ".join(PackedStringArray(arr))`, NO `arr.join(", ")`.
- **Inferencia de tipos con ternarias que devuelven `null`** falla: usar tipo explícito (`var npc: Node = ... if ... else null`).
- **Los tests headless cargan TODA la escena main_island** — cualquier comando que toque nodos de escena debe esperar a `current_scene` + grupo "player" (`_esperar_escena_lista()`).
- **`FileAccess.open` puede devolver null** — siempre null-check.
- **Algunos archivos pueden estar mapeados en memoria por el editor** (VS Code con la pestaña abierta) → el edit tool falla con `FileSystem.writeFile`. Solución: escribir un `.tmp` + `[System.IO.File]::Replace(tmp, dest, backup)`.
- **PS 5.1 lee scripts .ps1 sin BOM como cp1252**: cualquier caracter no-ASCII en un .ps1 se corrompe al parsear. Escribir scripts en ASCII puro; los datos con acentos van en un .txt aparte leido con `[System.IO.File]::ReadAllText(ruta, UTF8)`.
- **Archivos no rastreados en Logs/ son fragiles**: el git-clean / git checkout de otros agentes los borra (perdi los logs 928 y 934 asi). Commitear el log al terminar la iteracion.
- **`git checkout` destruye trabajo no commiteado de otros agentes** (trampa 58): `git status` SIEMPRE antes de cualquier checkout — asi borre las Notas del Agente de agnes en M107.
- **Tests con `>= N` sin cota superior esconden bugs de duplicacion**: el doble-entrega de drops de M15 pasaba todos los tests porque usaban `count >= 1`. Usar cota min Y max.
- **Git es la fuente de la verdad para "estaba implementado?"**: `git show HEAD:archivo` reveló los stubs falsos que los tests no podían detectar.
- **11. Claims de integración ("consumido por X") se verifican con grep, no con fe.** Buscar los paths/artifacts citados en `04-Codigo.md` en todo `scripts/`. **0 referencias = integración falsa**, por más que el checklist lo marque [x]. La sección F entera de M09 era falsa y dos QA (Hy3 Log 848 y yo) la dimos por buena hasta que grepé los paths.
- **12. NUNCA declarar "el módulo no tiene código" sin auditar su filesystem primero.** Lo hice en M09 y estaba equivocado: `terreno_horizonte.gd` (360 l.) existía. Los headers de `04-Codigo.md` ("sin scripts propios") también pueden estar stale — contrastar contra `Get-ChildItem` de las carpetas del módulo y contra los logs recientes del módulo.
- **13. Un QA previo no cierra la discusión.** M09 tenía QA de Hy3 (Log 848) que verificó el impostor y el diseño — pero no grepió los paths de integración. Un **segundo QA de modelo distinto** encuentra sobre-cierres más profundos. Merecen re-QA los ✅ cuyo sello se apoya en checks de diseño/visual y no en código.
- **14. `class_name` duplicado entre carpeta legacy y nueva** (terrain/ vs terrenos/ en M09/M156) no siempre da error visible en boot, pero hace los casts `as Clase` **orden-dependientes**. Al auditar módulos de terreno, comparar `class_name` de cada .gd.
- **15. La herramienta Write SOBREESCRIBE archivos existentes sin advertir.** La usé sobre `11-BUGS.md` (1643 líneas) para "anexar" BUG-043 y **destruí todo el archivo**. Lo rescaté con `git checkout -- <file>` (estaba versionado). **Regla: para anexar a un archivo existente, NUNCA Write — escribir un temp en Logs/_x.txt + `[System.IO.File]::AppendAllText(dest, ReadAllText(tmp))` + borrar temp.** Igual para ESTADO-PARALELO.
- **16. QAs repetidos del mismo modelo no cuentan como independencia §21.8.** M10 tenía dos QAs de hy3/Hy3 (Log 961 + 848) — ambos verificaron solo "archivos presentes" y dieron por bueno un pipeline con 3 capas inexistentes. Un segundo QA de **otro modelo** encontró el sobre-cierre profundo. Priorizar re-QA de ✅ cuyos sellos sean del mismo modelo y de tipo "presencia de archivos".
- **17. No todos los módulos de diseño están sobre-cerrados — verificar los VERBOS del checklist antes de flipear.** M08 mantiene ✅ con 0 flips: sus ítems dicen "Diseñar/Documentar/Definir" (diseño entregado) vs M09/M10 que decían "consumido por X" (integración nunca cableada). Flipar solo claims que afirman runtime/integración. Un QA que revierte todo no es honesto; un QA que **diferencia** M08 ✅ de M09/M10 🟡 sí lo es.
- **18. `04-Codigo.md` §2 (archivos) y §3 (contratos) son los puntos de falla más frecuentes** del ciclo mundo-voxel: listan paths y firmas **previstos** como si existieran. Verificar siempre con `Test-Path` + grep de `func nombre(`. Cuando difieren, corregir in-situ (acción-real de QA, no solo flip).
- **19. La distinción diseño-vs-runtime está en los VERBOS, y es binaria y decisiva.** "Definir/Documentar/Diseñar X" = diseño entregado → [x] se sostiene (M08 ✅, secciones I/J de M11). "Estado RUN hace X" / "Stamina: máx 100, drenado 12/s" = runtime afirmado → si no hay código, flip (secciones B–F de M11: 61 items). Un QA honesto **diferencia**; no revierte todo ni deja todo.
- **20. Los QAs de hy3/Hy3 (Log 961/747/835/848) son sistemáticamente de "presencia de archivos"** — verifican que player.gd/world_generator.gd/etc. "están presentes" pero no leen su contenido. Ese patrón deja pasar sobre-cierres enormes (M11: 73 items falsos). Donde vea "presentes" en un sello, el módulo es candidato prioritario de re-QA con grep de conceptos.
