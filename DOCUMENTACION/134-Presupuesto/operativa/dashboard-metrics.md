**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 134-Presupuesto
**Estado:** Implementación operativa (entregable M134)

---

# Métricas del Dashboard (`dashboard-metrics`) — Módulo 134

> **Adaptación honesta:** no existe (ni se necesita en modo costo cero) un servicio de dashboard "en tiempo real". El dashboard es una **pestaña de la hoja Google Sheets** con fórmulas sobre el registro de gastos (`expense-tracking.md` §1), actualizada al registrar cada gasto y revisada en el reporte mensual. Costo: 0.

## 1. KPIs financieros clave

| KPI | Fórmula | Modo actual |
|---|---|---|
| **Burn rate** | gastos del mes (USD) | 0 (solo si el fundador registra gastos) |
| **Runway** | fondos disponibles / burn rate promedio mensual | ∞ (sin burn) |
| **% presupuesto consumido** | gastos acumulados / presupuesto del período | ~0 % / USD 100 (Steam fee pendiente) |
| **Varianza real vs. plan** | real − planificado por categoría | 0 (sin plan de gasto activo) |
| **Neto promedio por copia** | ingresos netos / copias vendidas | n/d (pre-lanzamiento) |
| **Copias para break-even restantes** | (costo total − ingresos netos) / neto por copia | 7 al lanzamiento |

## 2. Contenido del reporte mensual de presupuesto

Se entrega con la plantilla `templates/reporte-mensual.md` e incluye obligatoriamente:

1. Burn rate y runway del mes.
2. Varianza real vs. plan por categoría.
3. Proyección de fin de mes (gasto proyectado al ritmo actual).
4. Top 5 gastos del mes (o "sin gastos" en modo costo cero).
5. Uso de reserva de imprevistos (si hubo: motivo + decisión).
6. Actualización de break-even si cambió el presupuesto.

**Distribución y revisión (adaptado a 1 persona):** no hay leads a quienes distribuir semanalmente; el reporte mensual se revisa en la **revisión de estado mensual** integrada al ciclo de M133 (`guia-sprints.md` §2, cierre de bloque) y se archiva en `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/reportes/` o junto a este módulo. Al escalar (M132), la reunión de revisión financiera mensual se formaliza con acta.

## 3. Alertas automáticas (fórmulas de la hoja)

| Alerta | Fórmula sugerida (Google Sheets) | Acción (ver `expense-tracking.md` §6) |
|---|---|---|
| Gasto sin comprobante | `=CONTAR.SI(Comprobante;"")>0` | Completar antes del cierre |
| Desvío >10 % de categoría | `=(Real-Plan)/Plan>0,1` | Proceso de ajuste §7 |
| Reserva tocada | `=SUMA(Reserva_Usada)>0` | Registro + decisión del fundador |
| Runway < 3 meses | `=Runway<3` | Plan de contingencia (`revenue-projections.md` §8) |

## 4. Checklist de cierre trimestral (auditoría documental, ítem I)

- [ ] Todos los gastos del trimestre con comprobante y URL.
- [ ] Reconciliación mensual firmada (3 de 3).
- [ ] 3 reportes mensuales archivados.
- [ ] Break-even y escenarios recalculados si hubo cambios de precio/alcance.
- [ ] Política de retención aplicada (documentos financieros se conservan; el mínimo legal de años lo define el contador del fundador fuera del repo).
- [ ] Lecciones aprendidas financieras del trimestre documentadas (qué se subestimó, qué regla falló, qué ajustar) — se agregan como notas en este módulo o ADR si cambian reglas.
- [ ] Backup del trimestre dentro del esquema 3-2-1 (M107).

## 5. Acceso restringido y datos sensibles

- Los documentos de este módulo contienen **solo categorías y montos agregados**: nunca datos bancarios, CUIT/datos personales ni credenciales (coherente con M80/M106).
- La hoja Google Sheets con el detalle real es privada del fundador; el repo recibe las plantillas y los reportes agregados.

## 6. Proceso de cierre contable y decisiones financieras

1. Cierre mensual: registro → reconciliación → reporte → archivo.
2. Cierre trimestral: checklist §4 + revisión de techos del escenario financiado (`budget-breakdown.md` §2).
3. Toda decisión financiera relevante (gasto nuevo, cambio de precio, uso de reserva) queda registrada: fila del registro + reporte del mes +, si cambia una regla, ADR en M133.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
