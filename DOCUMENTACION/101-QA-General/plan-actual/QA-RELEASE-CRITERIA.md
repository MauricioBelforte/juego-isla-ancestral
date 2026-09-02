**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-RELEASE-CRITERIA.md — DoD de QA y Criterios de Release (Módulo 101)

> **Propósito:** define objetivamente cuándo una build está apta para avanzar de hito (M137→M138→M139→M140→M141→M142). **Sin el DoD de QA, la build NO avanza de hito** (regla del protocolo multiagente, §21.6 AGENTS.md).

## DoD de QA — 7 puntos

Una build cumple el **DoD de QA** si y solo si cumple TODOS:

| # | Criterio | Verificación | Evidencia |
|---|---|---|---|
| 1 | **Smoke aprobado** sobre la build exacta | QA-SMOKE.md completo sin fallos | Veredicto en la sesión |
| 2 | **Checklists de áreas** del hito 100% `[x]` (cero `[?]` sin razón con dueño y fecha) | QA-CHECKLIST.md del hito | Resultados por ítem en sesión |
| 3 | **0 bugs críticos** abiertos; altos abiertos con dueño y fecha de fix | Issues M102 (tipo criticidad) | Query issues en GitHub |
| 4 | **Suite M112 en verde** corriendo sobre la misma build | `godot --headless res://scenes/test_runner.tscn` (o CI M118) | Salida consola 0 fallos |
| 5 | **Sesión documentada** con plantilla QA-SESSION.md y firma | `sesiones/` del módulo | Archivo sesión con conclusión + firma |
| 6 | **Flujos estables sin regresión** (§16 AGENTS.md) | QA-REGRESION.md completo | Notas de regresión en sesión |
| 7 | **Extras M141/M142:** crash rate cero (M122), backlog documentado, release notes preliminares | M122 + issues cerrados | Informe M122 + releases |

## Veredictos de severidad y efecto en el hito (tomados de M102, no redefinidos)

| Severidad | Definición (M102) | Efecto en hito |
|---|---|---|
| **Crítica** | Bloquea jugabilidad o corrompe datos | Frena el hito; fix obligatorio antes de avanzar |
| **Alta** | Funcionalidad rota con workaround molesto | Dueño + fix planificado en el mismo hito |
| **Media** | Impacto parcial / pulido negado | Backlog del hito siguiente |
| **Baja** | Cosmético / sugerencia | Backlog libre (puede ir a 5-FUTURAS-MEJORAS) |

## Criterios de entrada/salida por hito (resumen; detalle en `sesiones/QA-HITO-M1XX.md`)

| Hito | Criterio de entrada | Criterio de salida clave |
|---|---|---|
| M137 Prototipo | Core voxel operativo (M08/M09/M10/M11/M12/M13/M14) | Sin bugs bloqueantes en core; loop básico jugable |
| M138 Vertical Slice | M137 + slice completa | Slice completable de inicio a fin sin workarounds |
| M139 Pre-Alpha | M138 + sistemas base integrados | 0 críticos/altos abiertos; suite M112 en verde |
| M140 Alpha | M139 + feature-complete | 100% de áreas del checklist verde |
| M141 Beta | M140 + contenido completo | 0 críticos; crash rate cero (M122) |
| M142 RC | M141 | Punto 7 del DoD (crash rate cero + release notes) |

## Consecuencias de NO cumplir

1. La build **no avanza de hito** — se itera fixes y se re-sesiona el área afectada.
2. El módulo reclamado en CHECKLIST-GLOBAL NO se marca `✅` sin el QA cruzado (§21.8) que respeta estos criterios.
3. Los bugs críticos abiertos de una sesión anterior bloquean la siguiente (regla del 24h, §4 de 01-Requerimientos).
