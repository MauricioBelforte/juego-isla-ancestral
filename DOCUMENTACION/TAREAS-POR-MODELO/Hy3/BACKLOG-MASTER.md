# BACKLOG-MASTER — Hy3

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Identidad:** Hy3 / Kilo Code (ver DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md §5.D y §11)
**Rol en el proyecto:** QA cruzado (AGENTS.md §21.8), validación entre modelos, detección de bugs, sistemas de diálogo y narrativa complejos.

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
| 119-Actualizaciones | QA cruzado Hy3 (✅ Step 3.7 Flash, QA pendiente) | 4 | checklist.md creado |
| 165-Voxel-Tools-Guia | Re-QA cruzado Hy3 (self-verif MiMo inválida §21.8) | 4 | checklist.md creado |
| 168-Plantilla-De-Isla | Re-QA cruzado Hy3 (self-verif MiMo inválida §21.8) | 4 | checklist.md creado |

## Nuevas asignaciones QA cruzado (2026-09-07, Hy3 / Kilo Code) — Lote 2

> Módulos `✅` completados por **MiMo V2.5 (OpenCode)** (2026-08-26) sin verificación
> independiente por modelo distinto (requisito §21.8 de ser verificado por modelo distinto).
> Se asignan a Hy3 para QA cruzado. Logs reservados: 763 (M09), 764 (M10), 765 (M11).

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 09-Terreno-Y-Geografia | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | checklist.md creado |
| 10-Generacion-Del-Mundo | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | checklist.md creado |
| 11-Personaje-Del-Jugador | QA cruzado Hy3 (✅ MiMo, sin QA distinto) | 4 | checklist.md creado |
| 08-Mundo-Voxel | QA cruzado Hy3 (✅ MiMo V2.5, OpenCode) | 0 | ✅ VERIFICADO por hy3/WorkBuddy 2026-09-03 (Log 747, §21.8) — checklist 105/105 [x], 0 [?]; código nuclear (block_type/block_catalog/world_manager) presente; entregable de diseño pre-M1 |

## Índice por módulo

| Módulo | Rol de Hy3 | Tareas | Estado |
|--------|-----------|--------|--------|
| 21-Dialogos | Diálogos (núcleo implementado por Hy3; iter 8) | 61 | checklist.md creado |
| 22-Historia-Principal | Historia principal (QA cruzado Hy3) | 63 | checklist.md creado |
| 23-Historias-Secundarias | Historias secundarias (narrativa) | 82 | checklist.md creado |
| 24-Templos-Y-Puzzles | Templos y puzzles (QA cruzado Hy3) | 122 | checklist.md creado |
| 29-Tiempo-Y-Calendario | Tiempo y calendario (QA cruzado Hy3) | 65 | checklist.md creado |
| 35-Mineria | Minería (QA cruzado Hy3) | 83 | checklist.md creado |
| 39-Tiendas | Tiendas (QA cruzado Hy3) | 157 | checklist.md creado |
| 133-Gestion-Del-Proyecto | Gestión del proyecto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 134-Presupuesto | Presupuesto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 135-Riesgos-Del-Proyecto | Riesgos del proyecto (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 136-Roadmap | Roadmap (QA cruzado Hy3 - completo) | 0 | QA cruzado completo (0 pendientes) |
| 145-Diseno-De-Experiencia | Diseño de experiencia (QA cruzado Hy3) | 15 | checklist.md creado |
| 146-Diseno-Emocional | Diseño emocional (QA cruzado Hy3) | 10 | checklist.md creado |
| 148-Lore-Ambiental | Lore ambiental (narrativa) | 102 | checklist.md creado |
| 149-Nombres-Y-Nomenclatura | Nombres y nomenclatura (QA cruzado Hy3) | 3 | checklist.md creado |
| 150-Diseo-Sonoro-Narrativo | Diseño sonoro narrativo (narrativa) | 81 | checklist.md creado |
| 153-Objetivo-Final | Objetivo final (QA cruzado Hy3 iter1) | 10 | checklist.md creado |
| 162-Dialogos-Contextuales-De-NPCs | Diálogos contextuales de NPCs (🔴 alerta Hy3/M21) | 62 | checklist.md creado |
| 14-Inventario | QA cruzado Hy3 (nuevo 2026-09-05) | 0 | ✅ YA VERIFICADO por Hy3/Kilo 2026-09-05 (Log 697) — completo |
| 119-Actualizaciones | QA cruzado Hy3 (nuevo 2026-09-05) | 4 | checklist.md creado |
| 165-Voxel-Tools-Guia | Re-QA cruzado Hy3 (nuevo 2026-09-05) | 4 | checklist.md creado |
| 168-Plantilla-De-Isla | Re-QA cruzado Hy3 (nuevo 2026-09-05) | 4 | checklist.md creado |
| 09-Terreno-Y-Geografia | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | checklist.md creado |
| 10-Generacion-Del-Mundo | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | checklist.md creado |
| 11-Personaje-Del-Jugador | QA cruzado Hy3 (nuevo 2026-09-07) | 4 | checklist.md creado |

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
