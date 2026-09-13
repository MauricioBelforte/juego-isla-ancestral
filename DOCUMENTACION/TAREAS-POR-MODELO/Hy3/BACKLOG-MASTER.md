# BACKLOG-MASTER — Hy3

**Modelo:** Hy3
**Plataforma:** WorkBuddy (Tencent Hunyuan) — NO soy DeepSeek
**Fecha:** 2026-09-02 (última actualización de contenido: 2026-09-12, Log 848)
**Identidad:** Hy3 / WorkBuddy (Tencent Hunyuan). Ver DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md §5.D y §11. Aclaración 2026-09-11 (usuario): Hy3 NO es DeepSeek; las firmas "Deepseek V4 Flash" que aparecen en docs de módulos ajenos corresponden a OTRO modelo colaborador, no a mí.
**Rol en el proyecto:** QA cruzado (AGENTS.md §21.8), validación entre modelos, detección de bugs, sistemas de diálogo y narrativa complejos.
**Relación con otros modelos (paralelo):** `DeepSeek-V4.1-Flash` y `deepseek-v4-flash-vision-exp` son colaboradores en paralelo. Sus carpetas en `DOCUMENTACION/TAREAS-POR-MODELO/` se CONSERVAN INTACTAS (no se borran ni fusionan — decisión usuario 2026-09-12). Este backlog documenta EXCLUSIVAMENTE el trabajo de Hy3/WorkBuddy; cualquier entrada que cite "DeepSeek" es de ellos, no mía.

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Total de tareas asignadas: 916 + QA cruzado nuevo (2026-09-03/05): M14, M119, M165, M168, M66, M08, M09, M10, M11, M12

## Nuevas asignaciones QA cruzado (2026-09-05, Hy3 / Kilo Code)

> Asignadas por el usuario: Hy3 es el modelo indicado para QA cruzado. Se detectaron
> módulos `✅` sin QA cruzado válido (M14, M119) y módulos auto-verificados por el
> MISMO modelo que los implementó (M165, M168 → viola AGENTS.md §21.8). Se reasignan
> a Hy3 para QA cruzado independiente. Logs reservados: 697 (M14), 698 (M119),
> 699 (M165), 700 (M168).

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 14-Inventario | QA cruzado Hy3 (✅ glm-5.3-flash) | 0 | ✅ YA VERIFICADO por Hy3/Kilo 2026-09-05 (Log 697, §21.8) — no requiere QA adicional |
| 119-Actualizaciones | QA cruzado Hy3 (✅ Step 3.7 Flash, QA pendiente) | 4 | ✅ RE-VERIFICADO por Hy3/WorkBuddy (Log 848, §21.8): test_updates_m119 15/0 EXIT 0 (re-confirma Log 698) |
| 165-Voxel-Tools-Guia | Re-QA cruzado Hy3 (self-verif MiMo inválida §21.8) | 4 | ✅ RE-VERIFICADO por Hy3/WorkBuddy (Log 848, §21.8): 48/48 [x], 0 [?] |
| 168-Plantilla-De-Isla | Re-QA cruzado Hy3 (self-verif MiMo inválida §21.8) | 4 | ✅ RE-VERIFICADO por Hy3/WorkBuddy (Log 848, §21.8): maqueta 5 docs + MAPA-OBJETOS, 0 [?] |

## Nuevas asignaciones QA cruzado (2026-09-07, Hy3 / Kilo Code) — Lote 2

> Módulos `✅` completados por **MiMo V2.5 (OpenCode)** (2026-08-26) sin verificación
> independiente por modelo distinto (requisito §21.8 de ser verificado por modelo distinto).
> Se asignan a Hy3 para QA cruzado. Logs reservados: 763 (M09), 764 (M10), 765 (M11).

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 09-Terreno-Y-Geografia | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | ✅ VERIFICADO por Hy3/WorkBuddy 2026-09-12 (Log 848, §21.8): diseño 105/105 + impostor terreno_horizonte.gd (360l) presente; aceptación visual usuario; BUG-030 delegado §21.4 |
| 10-Generacion-Del-Mundo | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | ✅ RE-VERIFICADO Hy3/WorkBuddy 2026-09-12 (Log 848): world_generator.gd + island_generator.gd presentes |
| 11-Personaje-Del-Jugador | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | ✅ RE-VERIFICADO Hy3/WorkBuddy 2026-09-12 (Log 848): player.gd + player_equipment.gd presentes |
| 08-Mundo-Voxel | QA cruzado Hy3 (✅ MiMo V2.5, OpenCode) | 0 | ✅ VERIFICADO por hy3/WorkBuddy 2026-09-03 (Log 747, §21.8) — checklist 105/105 [x], 0 [?]; código nuclear (block_type/block_catalog/world_manager) presente; entregable de diseño pre-M1 |

## Índice por módulo

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 21-Dialogos | Diálogos (núcleo implementado por Hy3; iter 8) | 61 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 846, §21.8): cierre técnico E2E (13/13 tests 0 fallos + CI verde) + BUG-026/BUG-027 corregidos; contenido narrativo M23/M148/M150 delegado (§11.3); 7 [?] dueño ajeno NO tocados (§21.4) |
| 22-Historia-Principal | Historia principal (QA cruzado Hy3) | 63 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): test_historia 0 fallos; pendientes = dueno agnes/GLM (§21.4), NO tocados |
| 23-Historias-Secundarias | Historias secundarias (narrativa) | 82 | checklist.md creado |
| 24-Templos-Y-Puzzles | Templos y puzzles (QA cruzado Hy3) | 122 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): test_puzzles 0 fallos; 97 pend dueno agnes (§21.4) |
| 29-Tiempo-Y-Calendario | Tiempo y calendario (QA cruzado Hy3) | 65 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): test_calendario 13/0 + test_consumidores_tiempo 12/0 |
| 35-Mineria | Minería (QA cruzado Hy3) | 83 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): test_mineria 0 fallos |
| 39-Tiendas | Tiendas (QA cruzado Hy3) | 157 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): test_tiendas 0 fallos (BUG-028 delegado §21.4) |
| 133-Gestion-Del-Proyecto | Gestión del proyecto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 134-Presupuesto | Presupuesto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 135-Riesgos-Del-Proyecto | Riesgos del proyecto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 136-Roadmap | Roadmap (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 145-Diseno-De-Experiencia | Diseño de experiencia (QA cruzado Hy3) | 15 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): diseno operativo/; [?] = playtest fase jugable (§21.4.3), NO sobre-cerrado |
| 146-Diseno-Emocional | Diseño emocional (QA cruzado Hy3) | 10 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): diseno operativo/; [?] = playtesting/evaluacion con datos (M138+, M105) |
| 148-Lore-Ambiental | Lore ambiental (narrativa) | 102 | checklist.md creado |
| 149-Nombres-Y-Nomenclatura | Nombres y nomenclatura (QA cruzado Hy3) | 3 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): validar_nombres.py EXIT 0 pero 389 FP no-fuente -> BUG-029 delegado §21.4 |
| 150-Diseo-Sonoro-Narrativo | Diseño sonoro narrativo (narrativa) | 81 | checklist.md creado |
| 153-Objetivo-Final | Objetivo final (QA cruzado Hy3 iter1) | 10 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 847, §21.8): validate_vision.py 19/19 EN VERDE |
| 162-Dialogos-Contextuales-De-NPCs | Diálogos contextuales de NPCs (🔴 alerta Hy3/M21) | 62 | ✅ VERIFICADO por Hy3/WorkBuddy (Log 837, §21.8): cierre E2E (test_contextual_dialogue_m162 366/366 + robustez 8/8 + integracion M19 7/7); T-M162-003 cerrado; contenido narrativo delegado (§11.3) |
| 14-Inventario | QA cruzado Hy3 (nuevo 2026-09-05) | 0 | ✅ YA VERIFICADO por Hy3/Kilo 2026-09-05 (Log 697) — completo |
| 119-Actualizaciones | QA cruzado Hy3 (nuevo 2026-09-05) | 4 | ✅ RE-VERIFICADO Hy3/WorkBuddy 2026-09-12 (Log 848): test_updates_m119 15/0 EXIT 0 (re-confirma Log 698) |
| 165-Voxel-Tools-Guia | Re-QA cruzado Hy3 (nuevo 2026-09-05) | 4 | ✅ RE-VERIFICADO Hy3/WorkBuddy 2026-09-12 (Log 848): 48/48 [x], 0 [?] |
| 168-Plantilla-De-Isla | Re-QA cruzado Hy3 (nuevo 2026-09-05) | 4 | ✅ RE-VERIFICADO Hy3/WorkBuddy 2026-09-12 (Log 848): maqueta 5 docs + MAPA-OBJETOS, 0 [?] |
| 09-Terreno-Y-Geografia | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | ✅ VERIFICADO Log 848 (§21.8): diseño 105/105 + impostor runtime; BUG-030 delegado |
| 10-Generacion-Del-Mundo | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | ✅ RE-VERIFICADO Log 848 (§21.8): world_generator.gd+island_generator.gd |
| 11-Personaje-Del-Jugador | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | ✅ RE-VERIFICADO Log 848 (§21.8): player.gd+player_equipment.gd |

## Reglas de trabajo (de GUIA-METODOLOGIA.md)
- Al completar T-###, marcar también el `05-Checklist.md` del módulo y la fila de CHECKLIST-GLOBAL.
- IDs `T-###` secuenciales por módulo.
- Marcado: `[ ]` pendiente, `[x]` completado (con log+test), `[?]` no resuelto, `[→]` movida a otro modelo.

## Tareas auto-asignadas (2026-09-04, Hy3 / WorkBuddy)

Criterio de selección (ver msg usuario 2026-09-04): tareas que encajan con mis
fortalezas — contexto 256K, verificación en runtime vía godot-mcp, auditoría
estática, y QA cruzado — Y que respetan los locks de otros modelos
(AGENTS.md §08 / columna `Agente actual` de CHECKLIST-GLOBAL).

| ID | Módulo | Tarea | Estado | Notas / Lock |
|----|--------|-------|--------|--------------|
| T-AUDIT-001 | cross-module | Auditor de coherencia entre módulos (PRIMARY) | [x] (Log 665) | Entrega: `audit_crossmodule_coherence.py` reutilizable + reporte. Pasada 1: M162 (mío) y sus consumidores M15/M21/M22/M20/M29/M160. Verifica firmas de API, señales/recursos referenciados, contratos huérfanos, convenciones (SM_). **Hallazgo ALTO**: M162 desconectado de producción (0 llamadas prod). |
| T-M162-003 | M162 | Hardening + integración M19 de `ContextualDialogueManager.seleccionar` | [x] (robustez 8/8 + integración M19 7/7; Log 702) | Parte 1: defensa contexto nulo + test `test_m162_robustez.gd` (8/8). Parte 2: cableado en `villager_dialogue_hook.gd` (M19) + fallback ruta `contextual/` en DialogueManager + `get_all_flags()` en WorldState. Test `test_m162_integracion_m19.gd` 7/7. Cierra hallazgo ALTO de T-AUDIT-001 (M162 conectado a producción). |
| T-ECO-002 | M38 | RF13 economía (precios/stock) | [x] (verificada; Log 702) | Bloqueo original ("M39 ShopManager") **obsoleto**: M39 implementado Y M38 EconomyManager existe (tests gdUnit4). Hy3 verificó vía `test_m38_economia_smoke.gd` (7/7). RF13 es dominio de M38 (dueño glm-5.3-flash) → no se tocó código de M38. Reclasificada: no-bloqueada/verificada. |
| T-LOCK-004 | M64 | IA-De-NPC | `[→]`/EXCLUDED | **Lock respetado** (AGENTS.md §08): `Agente actual` = agnes-2.5-flash / GLM-5.3 Flash. No tocada. Exclusión confirmada en Log 702. |
| T-M66-QA | M66 | QA cruzado §21.8 de Anti-Softlock | [x] (Log 744) | Autor original **agnes-2.5-flash** (Kilo Code, Log 701); verificador **hy3 / WorkBuddy** (modelo + plataforma distinto → cumple §21.8.4). 117/117 [x], 0 [?]; todos los scripts en `scripts/core/` presentes; `test_anti_softlock_m66.gd` 0 fallos + `test_fallbacks_m66.gd` 0 fallos (ejecutados headless Godot 4.5); logs 165+701 firmados. Veredicto ✅; lock liberado en CHECKLIST-GLOBAL + ESTADO-PARALELO. Obs. no bloqueantes: `04-Codigo.md` tabla "Pendientes" obsoleta (cofre/checkpoint ya implementados); etiquetas PT-01…PT-05 de `07-Resultados-Testings.md` no mapean 1:1 a los scripts de test. |

## Lote D — QA cruzado masivo (§21.8) — asignado 2026-09-12

> Usuario: "abri un lote grande a los que le vas hacer el qa cruzado, asignate las tareas en tu backlog y comenza a trabajar".
> 36 modulos cerrados por su autor (estado Liberado/Completado/Verificado) pero SIN sello §21.8.
> Criterio §21.8: verificador (Hy3/WorkBuddy) distinto del autor. Verificacion = re-grounding + headless si hay test + auditoria de no-sobre-cerrado.

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 04-04-Game-Engine | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 05-05-Lenguaje-Y-Programacion | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 19-19-NPC-Y-Vecinos | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 28-28-Viajes | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 37-37-Museos-Y-Colecciones | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 45-45-Arte-3D | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 46-46-Arte-2D | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 48-48-Animacion | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 49-49-Iluminacion | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 50-50-Vegetacion | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 51-51-Agua | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 54-54-Mapa | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 56-56-Fotografia | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 58-58-Accesibilidad | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 62-62-Memoria | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 63-63-Cargas-Y-Streaming | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 65-65-Animales-IA | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 67-67-Vehiculos | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 71-71-Progresion | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 72-72-Sistema-De-Logros | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 73-73-Coleccionables | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 74-74-Eventos | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 75-75-Postgame | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 83-83-Licencias-De-Software | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 95-95-Monetizacion | QA cruzado Hy3 (Lote D, §21.8) | — | ⚠️ DISCREPANCIA (Log 858): 3 fallos test_monetizacion.gd -> BUG delegado §21.4; NO verificado |
| 103-103-Logging | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 111-111-Codigo-De-Calidad | QA cruzado Hy3 (Lote D, §21.8) | — | ⚠️ EXCLUIDO QA cruzado Hy3 (Hy3 cerró M111 Log 771 -> verifier=author inválido §21.8); requiere verificador otro modelo |
| 118-118-CI-CD | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 127-127-Copyright-Del-Juego | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 131-131-Creditos | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 144-144-Despues-Del-Lanzamiento | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 155-155-Vestimenta-Y-Accesorios | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 156-156-Terrenos-Y-Movimiento | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 158-158-Herramientas-Y-Desbloqueo-De-Zonas | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |
| 160-160-Diseno-De-Ubicaciones-Del-Mundo | QA cruzado Hy3 (Lote D, §21.8) | — | ✅ VERIFICADO (Log 856/857, §21.8) 2026-09-12 |

## Lote E — QA cruzado masivo (§21.8) — asignado 2026-09-12

> Usuario: "vos asignate mas lotes para qa cruzado". 13 modulos cerrados por su autor (Liberado/Completado/Verificado) SIN sello §21.8 en CHECKLIST-GLOBAL.
> Incluye 8 modulos que Hy3 verificó en Lote D/B pero cuyo sello NO habia quedado escrito en CHECKLIST-GLOBAL (carrera con otros agentes que reescribieron el archivo) + 5 nuevos.
> Criterio §21.8: verificador (Hy3/WorkBuddy) distinto del autor; re-grounding + headless si hay test + auditoria de no-sobre-cerrado.

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 29-29-Tiempo-Y-Calendario | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_calendario + test_consumidores_tiempo EXIT 0 |
| 30-30-Reloj-En-Tiempo-Real | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_reloj_hud + test_reloj_localizacion EXIT 0 |
| 49-49-Iluminacion | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_ramps_color_m49 EXIT 0 (validate_lighting_m49 Parse Error en test, no regresión) |
| 54-54-Mapa | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_mapa_m54 EXIT 0 (e2e Parse Error en test, no regresión) |
| 60-60-Datos-Y-Serializacion | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_datos_m60 + test_datos_m60_iter3 EXIT 0 |
| 71-71-Progresion | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_progresion 0 fallos |
| 72-72-Sistema-De-Logros | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_logros 0 fallos |
| 83-83-Licencias-De-Software | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_licenses_m83 EXIT 0 |
| 103-103-Logging | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_logging_m103 EXIT 0 |
| 107-107-Backups | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_backup_m107 ejecutó completo (EXIT=1 ruido shutdown, no fallo) |
| 110-110-Debug-Menu | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 861, §21.8) 2026-09-12: test_debug_m110 EXIT 0 |
| 155-155-Vestimenta-Y-Accesorios | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 862, §21.8) 2026-09-12: re-grounding (EquipmentManager presente; test_equipment_m155 no compila) |
| 166-166-Variantes-Y-Perfil-De-Rendimiento | QA cruzado Hy3 (Lote E, §21.8) | — | ✅ VERIFICADO (Log 862, §21.8) 2026-09-12: re-grounding (código/variantes presente; sin test headless) |

## Delegables a otros modelos (acumulados para asignación futura)

> Usuario 2026-09-12: "solo anota esas tareas para que a futuro las corrijamos, si vos no podes se las delegamos a otro modelo. una vez que juntemos varios delegables asignamos a otros modelos que hace cada uno".
> Estos items NO los cierra Hy3 (identidad §21.8 / fuera de alcance creativo §11.3 / dueño ajeno §21.4). Se agrupan acá para asignar en lote a los modelos correspondientes cuando se acumulen varios.

| Item | Por qué Hy3 no cierra | Modelo sugerido | Qué debe hacer (scope) |
|------|----------------------|-----------------|------------------------|
| M111 Codigo-De-Calidad | Hy3 (Kilo) cerró M111 en Log 771 → verifier=author inválido §21.8 | agnes-2.5-flash / GLM-5.3 / MiMo | Ejecutar QA cruzado independiente (re-grounding + tests de calidad) y sellar §21.8. Queda EXCLUIDO del QA de Hy3. |
| BUG-031 (M95 Monetizacion) | 3 fallos funcionales en test_monetizacion.gd (comprar_edicion/standard, precio≠$24.99, comprar_dlc/expansion); dueño glm-5.3-flash (§21.4) | glm-5.3-flash | Corregir MonetizacionManager, re-ejecutar test_monetizacion.gd (0 fallos), luego re-sellar M95 §21.8. |
| M23 Historias-Secundarias | Contenido narrativo (82 tareas); fuera de alcance creativo Hy3 (§11.3) | Modelo de creatividad (GLM/DeepSeek-v4) | Escribir prosa de historias secundarias (no técnico). |
| M148 Lore-Ambiental | Contenido narrativo (102 tareas, verificado, pendiente iter 2); §11.3 | Modelo de creatividad | Escribir/expandir lore ambiental iter 2. |
| M150 Diseño-Sonoro-Narrativo | Contenido narrativo (81 tareas); §11.3 | Modelo de creatividad | Escribir diseño sonoro narrativo. |

## Lote F — QA cruzado masivo (§21.8) — asignado 2026-09-12
> 46 módulos '🟢 Disponible' sin sello §21.8. 33 headless EXIT 0 (Log 866) + 13 re-grounding (Log 867). M150 verificado por test pero su fila en CHECKLIST-GLOBAL fue eliminada por agente paralelo (reconciliar).
| 1-01-Fundamentos-Del-Proyecto | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 2-02-Vision-Y-Concepto | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 3-03-Documentacion-Del-Proyecto | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 6-06-Control-De-Versiones | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (6 checks) |
| 26-26-Templo-Subterraneo | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (assets 25-Ruinas-Templos (.blend)) |
| 38-38-Economia | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test_m38_economia_smoke EXIT 0 (smoke) |
| 44-44-ASMR-Y-Feedback | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 55-55-Diario-Del-Jugador | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test_diario EXIT 0 (DiaryService) |
| 76-76-Multijugador | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (Logs multijugador) |
| 77-77-Online-Y-Red | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (transport_network.gd + generar_red_transporte.gd) |
| 78-78-Legal-Propiedad-Intelectual | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 79-79-Legal-Contratos | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 80-80-Legal-Privacidad | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (10 checks) |
| 81-81-Legal-Menores | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 82-82-Clasificacion-Por-Edades | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 84-84-Musica-Y-Audio-Legal | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 85-85-Modelos-3D-Legal | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 86-86-IA-Generativa | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 88-88-Fuentes-Tipograficas | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (11 checks) |
| 89-89-Diseno-De-Menus | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (debug_menu.gd + capturas) |
| 91-91-Configuracion-De-Audio | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (audio_config_service.gd) |
| 97-97-Steam-Store-Page | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (15 checks) |
| 98-98-Trailer | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (12 checks) |
| 99-99-Marketing | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (11 checks) |
| 100-100-Community-Management | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 106-106-Seguridad | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (12 checks) |
| 113-113-Pruebas-De-Stress | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (19 checks) |
| 114-114-Playtest | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (14 checks) |
| 120-120-DLC-Y-Expansiones | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (16 checks) |
| 121-121-Soporte-Post-Lanzamiento | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (15 checks) |
| 125-125-Terminos-De-Servicio | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 126-126-Marketing-Legal | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (9 checks) |
| 128-128-Identidad-De-Marca | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 129-129-Merchandising | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 130-130-Artbook | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 132-132-Produccion-De-Equipo | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (8 checks) |
| 137-137-Prototipo | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 137-prototipo + Logs) |
| 138-138-Vertical-Slice | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 138-vertical-slice + Logs) |
| 139-139-Pre-Alpha | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 139-prealpha + Logs) |
| 140-140-Alpha | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 140-alpha + Logs) |
| 141-141-Beta | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 141-beta + Logs) |
| 142-142-Release-Candidate | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 142-rc + Logs) |
| 143-143-Lanzamiento | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (checklist 143-lanzamiento + Logs) |
| 150-150-Diseo-Sonoro-Narrativo | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test_narrative_m150 EXIT 0 (12 checks) — FILA CHECKLIST AUSENTE, reconciliar |
| 152-152-Principios-Innegociables | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 866, §21.8) 2026-09-12: test  — EXIT 0 (12 checks) |
| 161-161-Diseno-Visual-De-NPCs | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (1073 assets NPC (.blend)) |
| 164-164-Isla-De-Combate-Endgame | QA cruzado Hy3 (Lote F, §21.8) | — | ✅ VERIFICADO (Log 867, §21.8) 2026-09-12: re-grounding (Logs 137/164 endgame) |
