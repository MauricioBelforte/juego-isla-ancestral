# RIEL-I1 — INVESTIGACIÓN + NUEVO FUEL (nicho de análisis largo; 20 items)

**Armado por:** GLM-5.3-Flash (orden fundador 25oct) | **Fecha:** 2026-10-25
**Nicho:** contexto largo + análisis. Fuente: las 4 vías de reposición identificadas tras agotar el fuel estructurado (informes 78/79/80 a agnes). Output: nuevos candidatos de ítems con L# y cubo A-DEF/B/C — SIN apilar en `tareas/` sin GO de la directora (el apilado lo hace el director o su delegado).

## Fuente 1 — Plan inicial mínimo (600+ puntos de control)

| # | Tarea |
|---|---|
| I1-001 | Escanear `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`: listar los puntos de control SIN correspondencia en ningún 05-Checklist actual (propuesta: lista de ítems migrables, módulo destino y cubo) |
| I1-002 | Escanear `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md`: tareas de producción no absorbidas por módulos (mism formato) |
| I1-003 | Comparativa: puntos del plan inicial marcados como críticos (P1/P2) vs su estado actual en los 05 (¿dónde viven hoy?) |
| I1-004 | Lista de promesas del plan inicial que no existen ni como ítem ni como tarea en ningún 05 (huecos duros) |
| I1-005 | Desglose del plan de producción por disciplina (art/code/design/audio) cruzado con los agentes activos: qué disciplina tiene menor cobertura |

## Fuente 2 — 5-FUTURAS-MEJORAS (directivas del fundador)

| # | Tarea |
|---|---|
| I1-006 | Leer `DOCUMENTACION/5-FUTURAS-MEJORAS.md`: convertir cada idea pendiente (nivel Alta 🔴) en ítems concretos con módulo destino y cubo |
| I1-007 | Ídem nivel Media 🟡 |
| I1-008 | Ídem nivel Baja 🟢 + ideas duplicadas o ya implementadas sin marcar |
| I1-009 | Propuesta de orden/ejecución de las mejoras de nivel Alta por dependencias (qué desbloquea qué) |
| I1-010 | Cheqquear qué ideas de 5-FUTURAS-MEJORAS ya quedaron cubiertas por trabajo de la flota posterior a su redacción (sin marcarlas: solo informe) |

## Fuente 3 — GUIA-GODOT (lecciones pendientes de plasmarse)

| # | Tarea |
|---|---|
| I1-011 | Leer `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md`: proponer ítems de verificación para los errores sin ítem de regression en su módulo |
| I1-012 | Ídem con `02-voxel-tools.md` (patrones VoxelTool que los módulos deberían respetar) |
| I1-013 | Ídem con `08-terreno-voxel.md` + `18-impostores-terreno.md` (checklist de impostores pendiente?) |
| I1-014 | Ídem con `19-diagnostico-tildes.md` (causas C-01..C-11: cuáles tienen guardas de regression en el código actual) |
| I1-015 | Ídem con `16-zoom-camara-personaje.md` y `17-disco-plano-verde.md` (recetas aplicadas o pendientes por módulo) |

## Fuente 4 — Derivaciones pendientes del ex-director (estado_director.json)

| # | Tarea |
|---|---|
| I1-016 | Señales sin productor documentadas (M14…M92): listar cada una con módulo dueño y propuesta de productor (formulación de spec de señal como Cubo A-DEF; el código lo hace quien corresponda) |
| I1-017 | M74 festivales hacia M140: migración restante — inventario exacto de los ítems migrados vs pendientes |
| I1-018 | M53/M37 tooltips sin traducir: censo de tooltips ES hardcodeados restantes (módulo, L#, texto) — insumo para la ronda i18n |
| I1-019 | M56 fotografía: revisar los ítems de integración con M19/M36 que Beam dejó a medios y completar el mapa de dependencias |
| I1-020 | M107 Bloque 0 (GCP/Drive/OAuth): doc de investigación sin tocar la cuenta del fundador — preparar informe de qué haría falta SI el fundador da GO (procedimiento M107 §5.1) |

**Regla:** estos ítems producen INFORMES+PROPUESTAS en tu canal, no apilados directos. La directora valida y arma las tandas TASCHE finales (anti-duplicado contra la cola de Beam T057-T265 antes de publicar).
