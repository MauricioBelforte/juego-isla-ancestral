**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 134-Presupuesto
**Estado:** Implementación operativa (entregable M134)

---

# Control de Gastos (`expense-tracking`) — Módulo 134

## 1. Registro de gastos

- **Plantilla fuente:** `templates/registro-de-gastos.csv` (versionada en el repo).
- **Herramienta activa:** copia en **Google Sheets** (decisión de §Herramientas de `guia-uso-plantillas.md`); el CSV del repo es la fuente durable y portable (RN10 de M133: estados versionados).
- **Regla de oro (modo costo cero):** cada gasto real, por chico que sea, se registra **el mismo día**. Si no hay gastos, el registro queda vacío y el reporte mensual lo declara (`gastos del mes: USD 0`).

### Columnas del registro

`Fecha · Descripción · Categoría · Subcategoría · Monto (USD) · Método de pago · Aprobado por · Comprobante/URL · Notas`

## 2. Flujo de aprobación (3 niveles, adaptado a 1 persona)

| Nivel | Quién | Cuándo aplica |
|---|---|---|
| 1. Decisión | Fundador | Todo gasto (modo actual: no existe gasto sin su decisión) |
| 2. Verificación | Fundador (auto-auditoría) | Al registrar: monto, comprobante y categoría correcta |
| 3. Revisión | Reporte mensual | El gasto queda consolidado en el reporte y visible en la tabla global si afecta a un módulo |

Preparado para escalar: si se suman colaboradores (M132), nivel 1 pasa a ser "colaborador propone → fundador aprueba"; los agentes de IA nunca aprueban gastos.

## 3. Frecuencia de revisión

- **Semanal (15 min):** dentro de la revisión de estado de M133 (`guia-sprints.md` §2) — revisar que el registro esté al día y sin pendientes de comprobante.
- **Mensual:** reporte de presupuesto (plantilla `templates/reporte-mensual.md`) con burn rate, runway y varianza (`dashboard-metrics.md`).

## 4. Reconciliación "bancaria" (adaptada)

1. Al cierre de mes: comparar cada fila del registro contra el resumen real del método de pago (estado bancario/tarjeta).
2. Corregir diferencias con una nueva fila `AJUSTE` (no borrar filas; el registro es append-only).
3. Firmar la reconciliación en el reporte mensual (`Reconciliado: sí/no`).

## 5. Reembolsos y facturación

- **Reembolsos:** gasto hecho por el fundador con dinero del proyecto ↔ devolución registrada con fila espejo (`Categoría: Reembolso`); en modo costo cero el caso normal es que no existan.
- **Facturación:** todo gasto ≥ USD 10 conserva comprobante (captura/PDF) con URL en la columna Comprobante; compras con factura legal (ej: Steam Direct Fee) se archivan para M78/M80 (legal/impuestos).

## 6. Alertas de exceso de presupuesto

| Alerta | Umbral | Acción |
|---|---|---|
| Gasto no planificado | Cualquier gasto fuera del plan del mes | Revisar en la revisión semanal; justificar o revertir |
| Desvío de categoría | >10 % del techo del escenario financiado | Proceso de ajuste (§7) |
| Quema de reserva | Cualquier uso de la reserva de imprevistos | Registro obligatorio + motivo + decisión del fundador |
| Runway | <3 meses (solo aplica si hay financiamiento) | Plan de contingencia financiero (`revenue-projections.md` §contingencia) |

## 7. Proceso de ajuste de presupuesto

1. Detectar el desvío (alerta o revisión).
2. Identificar causa (subestimación, gasto nuevo, error de registro).
3. Decidir el ajuste: mover fondos entre categorías (respetando la reserva mínima) o recortar alcance (M136).
4. Registrar la decisión como nota en el reporte mensual; si cambia una regla del módulo, ADR en M133.

## 8. Auditoría (proceso documental)

- El registro del repo es append-only y auditado por diff de git.
- Cierre trimestral (ítem I): verificar que todos los gastos del trimestre tengan comprobante, reconciliación firmada y reporte mensual correspondiente (checklist en `dashboard-metrics.md` §cierre-trimestral).

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
