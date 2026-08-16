**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 02: Documentación del Proyecto

## 1. Carácter del Componente

Módulo **documental** (infraestructura documental): no genera código de juego. Su "código de ejecución" es el sistema de documentación en sí (convenciones, flujos, archivos). **No aplican testings 06/07** (no hay código); la verificación del módulo es documental (trazabilidad + consistencia).

## 2. Archivos involucrados

### Entradas
| Archivo | Rol |
|---|---|
| `AGENTS.md` | Reglamento: estructura, reglas, protocolo, convenciones |
| `CHECKLIST-GLOBAL.md` | Tabla maestra con prioridades y dependencias |
| `Plan-inicial-minimo.md` | Backlog (152 módulos) y sección 2 (25 puntos) |
| `Plan-de-produccion.md` | Milestones sugeridos, roadmap post-lanzamiento, riesgos |

### Salidas (de este componente)
| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | Problema, objetivos, alcance, criterios |
| `plan-inicial/02-Analisis.md` | Estado de los 25 puntos, análisis de convenciones, decisiones |
| `plan-inicial/03-Diseno.md` | Catálogo, convenciones, estructura, estándar, versionado, tareas, hitos, backlog |
| `plan-inicial/05-Checklist.md` | 100+ ítems del módulo |
| `plan-actual/*` | Espejo vigente |

### Generados por este módulo (raíz de DOCUMENTACION)
| Archivo | Estado |
|---|---|
| `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` | Esqueleto (contenido por módulos técnicos) |
| `2-DOCUMENTO-DISENO-ACTUAL.md` | Esqueleto (contenido por módulos de gameplay) |
| `3-DOCUMENTO-TAREAS-ACTUAL.md` | Esqueleto (se completa en cada tarea) |
| `4-DOCUMENTO-EJECUCION-ACTUAL.md` | Esqueleto (se completa en cada implementación) |
| `5-FUTURAS-MEJORAS.md` | Anotador del usuario (vacio hasta directivas) |

## 3. "Funciones clave" del sistema documental (flujos que otros módulos ejecutan)

| Función | Descripción | Consumida en |
|---|---|---|
| Crear componente | Sección 11 AGENTS: numerar (README), crear plan-inicial + plan-actual, 5 archivos | Todo módulo nuevo |
| Actualizar documentación | Documentación primero (AGENTS §13) | Todo cambio |
| Registrar log | `Logs/{NN}-...` + ULTIMO_NUMERO | Todo módulo |
| Actualizar global | CHECKLIST-GLOBAL (manual o `scripts/generar_checklist_global.py`) | Fin de turno |
| Verificar consistencia | `scripts/verificar_checklist.py` + `scripts/test_scripts.py` | Antes de producción |
| Backup pre-cambio grande | `Obsoletos/AAAA-MM-DD_HH-MM-SS_nombre.ext` | Refactors |
| Actualizar *-ACTUAL.md | Cuando el cambio es significativo (AGENTS §3) | Tareas de impacto |

## 4. Verificación del Módulo

- Los 25 puntos del plan maestro tienen estado y dueño (02-Analisis §1).
- Checklist ≥100 ítems, ítems verificables, estados honestos.
- Convenciones verificadas contra AGENTS.md (no contradictorias).
- 5 esqueletos `*-ACTUAL.md` creados y firmados.
- CHECKLIST-GLOBAL + DOCUMENTACION/README + Logs actualizados.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 00:50:00
**Estado:** Completado (documental)

### Lo que hice
- Catalogué los 25 puntos del plan maestro con estado y módulo dueño.
- Formalicé convenciones, estructura, estándar, versionado, tareas/prioridades, hitos y backlog.
- Definí milestones M1-M5 + roadmap post (Cenizas → Cielo → Elysia → 4 finales) alineado al Plan-de-produccion.
- Creé los 5 documentos generales `*-ACTUAL.md` (esqueletos con estado y firma).

### Lo que NO pude hacer (honestidad obligatoria)
- Contenido substantivo de los 5 `*-ACTUAL.md` → depende de módulos técnicos/gameplay futuros (se dejó esqueleto honesto, no contenido inventado).
- Documentos especializados (arte, audio, legal, publicación, técnica) → dueños asignados, sin escribir contenido.
- Fechas fijas de milestones → a propósito (proyecto 1 persona, metodología ágil liviana).

### Recomendaciones para el próximo agente
- M03 (Game Engine): usar el catálogo (documento Técnico) y el hito M1 como contrato de salida del prototipo.
- Los pendientes de M02 con dueño (M78 legal, M45 arte, etc.) deben enlazarse desde los componentes destino al completarse.
- Actualizar `2-DOCUMENTO-DISENO-ACTUAL.md` y `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` apenas se cierre la decisión Unity vs Godot.