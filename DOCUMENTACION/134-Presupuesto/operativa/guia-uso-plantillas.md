**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 134-Presupuesto
**Estado:** Implementación operativa (entregable M134)

---

# Guía de Uso de Plantillas — Módulo 134

## 1. Herramienta de hoja de cálculo (decisión)

**Google Sheets** (plan gratuito): multiplataforma, colaboración simple si se escala, importación nativa de CSV. **Excel** queda como alternativa válida para el fundador si prefiere escritorio (los CSV son compatibles con ambos). Ningún software de pago.

Principio: **el repo es la fuente durable** (los CSV/plantillas versionadas); la hoja de cálculo es la herramienta activa de trabajo (RN10 de M133). Al cierre de cada mes se exporta la vista consolidada al reporte.

## 2. Plantillas disponibles

| Plantilla | Uso | Cuándo se usa |
|---|---|---|
| `templates/budget-template.csv` | Desglose maestro de presupuesto por categoría | Al crear el presupuesto (modo vigente ya definido en `budget-breakdown.md`) y al activar el escenario financiado |
| `templates/registro-de-gastos.csv` | Registro append-only de gastos reales | Cada vez que existe un gasto (misma regla: mismo día) |
| `templates/reporte-mensual.md` | Reporte mensual de presupuesto | 1 vez por mes (contenido obligatorio en `dashboard-metrics.md` §2) |

## 3. Cómo usarlas (flujo estándar)

1. **Importar a Sheets:** `Archivo → Importar` el CSV correspondiente. Conservar los encabezados exactos (los documentos de este módulo los referencian).
2. **Registrar gasto:** agregar fila al final del registro (append-only, nunca editar/borrar filas); completar todas las columnas; adjuntar comprobante y anotar su URL.
3. **Dashboard:** en la pestaña de métricas, usar las fórmulas de `dashboard-metrics.md` §3 (alertas) y §1 (KPIs).
4. **Reporte mensual:** copiar `reporte-mensual.md`, completarlo, archivarlo y referenciarlo en el log de la tarea (M133 §6).
5. **Sincronizar con el repo:** actualizar los CSV del repo si cambiaron filas/categorías (commit en español, pasado descriptivo).

## 4. Reglas

- Los montos de ejemplo de `budget-template.csv` son **ilustrativos** (marcados en la columna Notas): no representan decisiones de gasto.
- Sin gastos en el mes, el reporte se presenta igual con "USD 0" (el reporte vacío es evidencia de que el control funciona).
- Los agentes de IA pueden preparar y actualizar plantillas/reportes, pero **nunca autorizan gastos** (`budget-breakdown.md` §4).
- Capacitación del equipo (adaptado): con equipo de 1 persona, esta guía cumple el rol de capacitación; si se suman colaboradores (M132), su onboarding incluye leer esta guía y la de M133.

**Firma del último agente que modificó esta guía:**

**Modelo:** GLM
**Plataforma:** Kilo
