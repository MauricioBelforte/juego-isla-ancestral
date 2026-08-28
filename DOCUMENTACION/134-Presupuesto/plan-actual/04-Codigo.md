# Módulo 134: Presupuesto — Código

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (spec original por Nemotron 3 Ultra)
**Estado:** Implementación operativa completa (pendiente de QA cruzado)

> **Adaptación de rutas:** el spec original ubicaba los documentos en `docs/budget/` y `templates/`. Por la convención de estructura del proyecto (`AGENTS.md` §3), la implementación real vive en `DOCUMENTACION/134-Presupuesto/operativa/` y `operativa/templates/`. El contenido especificado se conservó íntegro.

## Archivos Implementados (2026-08-28)

| Spec original | Archivo real | Estado |
|---|---|---|
| `docs/budget/budget-breakdown.md` | `operativa/budget-breakdown.md` | ✅ Implementado (modo vigente + techos de escenario financiado + supuestos + límites de aprobación) |
| `docs/budget/expense-tracking.md` | `operativa/expense-tracking.md` | ✅ Implementado (registro, aprobación 3 niveles, reconciliación, reembolsos, alertas, ajuste, auditoría) |
| `docs/budget/revenue-projections.md` | `operativa/revenue-projections.md` | ✅ Implementado (precio M95, 3 escenarios, break-even, cash flow, umbrales por fase, contingencias) |
| `docs/budget/dashboard-metrics.md` | `operativa/dashboard-metrics.md` | ✅ Implementado (6 KPIs, contenido del reporte, fórmulas de alerta, cierre trimestral) |
| `templates/budget-template.csv` | `operativa/templates/budget-template.csv` | ✅ Implementado (15 categorías + Steam fee, montos 0 en modo actual) |
| — (añadido) | `operativa/templates/registro-de-gastos.csv` | ✅ Plantilla de registro append-only |
| — (añadido) | `operativa/templates/proyeccion-ingresos.csv` | ✅ Plantilla de escenarios y break-even |
| — (añadido) | `operativa/templates/reporte-mensual.md` | ✅ Plantilla del reporte mensual |
| — (añadido) | `operativa/guia-uso-plantillas.md` | ✅ Herramienta elegida (Google Sheets) + flujo de uso |

## Archivos a Modificar

No hay archivos de código a modificar. Este módulo es documentación financiera.

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Gestión del Proyecto (M133) | Usa presupuesto para planificación; costo por sprint = 0; ceremonias sin costo |
| Producción (M132) | Alimenta estimaciones de horas (costo implícito, no facturado) |
| Riesgos (M135) | Incluye costos de mitigación; M135 consumirá los triggers/umbráles de `revenue-projections.md` §8 y `expense-tracking.md` §6 |
| Roadmap (M136) | Alimenta schedule con budget (umbrales de inversión por fase, `revenue-projections.md` §5) |
| Marketing (M99/M143) | Marketing día 0 orgánico; reinversión post-lanzamiento acotada |
| Plataformas (M96/M97) | Comisiones 30 % Steam/GOG y Steam fee en `revenue-projections.md` §2 |

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 20:00:00
**Estado:** Completado (pendiente de QA cruzado)

### Lo que hice
- Implementé los 5 entregables del spec + 4 añadidos (registro de gastos, proyección CSV, reporte mensual, guía de uso) en `operativa/`.
- Definí el presupuesto real del proyecto (USD 0/mes + Steam fee USD 100) y el escenario financiado paramétrico con techos por categoría y reserva protegida (mín 11 % / objetivo 20 %).
- Calculé break-even del modo actual (≈7 copias) y documenté 3 escenarios de ventas de 3 años con supuestos conservadores basados en M95 (USD 24.99 premium).
- Documenté umbrales de inversión por fase (go/no-go financiero por milestone), contingencias (incluida la decisión de NO establecer línea de crédito) y el proceso de reporting mensual/trimestral integrado a M133.
- Marqué el checklist 100/100 con evidencia por ítem y documenté las adaptaciones a 1 persona/costo cero como notas explícitas (sin `[?]`).

### Lo que NO pude hacer (honestidad obligatoria)
- No registré gastos reales (no existen aún: el registro inicia cuando el fundador haga el primer gasto, ej: Steam fee).
- Las obligaciones legales/contables específicas (impuestos, moneda local) quedan para el contador del fundador; el repo solo maneja agregados sin datos personales.
- Los escenarios de ventas son supuestos conservadores documentados, no promesas ni decisiones de marketing.

### Recomendaciones para el próximo agente
- QA cruzado rápido: verificar que los 9 archivos de `operativa/` existan, que el checklist esté 100/100 sin `[?]`, y que los números (24.99, 17.49, 100, 7 copias) sean coherentes entre documentos.
- Al implementar M135 (Riesgos), conectar su registro con los triggers de reserva y las alertas de `expense-tracking.md` §6 (columna de impacto financiero).
- El primer reporte mensual real se genera cuando exista el primer gasto o al cierre de septiembre, con `templates/reporte-mensual.md`.
