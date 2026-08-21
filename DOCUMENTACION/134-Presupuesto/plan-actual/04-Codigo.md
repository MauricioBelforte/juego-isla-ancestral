# Módulo 134: Presupuesto — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:31:00

## Archivos a Crear

### 1. `docs/budget/budget-breakdown.md` — Desglose del presupuesto

Documento con:
- Tabla de presupuesto por categoría y subcategoría
- Porcentajes asignados a cada categoría
- Supuestos de estimación
- Fuentes de financiamiento

### 2. `docs/budget/expense-tracking.md` — Control de gastos

Documento con:
- Template de registro de gastos
- Flujo de aprobación
- Proceso de reconciliación
- Reportes mensuales

### 3. `docs/budget/revenue-projections.md` — Proyecciones de ingresos

Documento con:
- Tres escenarios (pesimista, realista, optimista)
- Cálculo de break-even
- Supuestos de ventas por plataforma
- Proyección de ingresos por año

### 4. `docs/budget/dashboard-metrics.md` — Métricas del dashboard

Documento con:
- Burn rate y runway
- % de presupuesto consumido
- Varianza real vs. plan
- Alertas automáticas

### 5. `templates/budget-template.csv` — Plantilla CSV

Plantilla para importar en hoja de cálculo:
```
Categoría,Subcategoría,Costo Mensual,Duración,Total,Porcentaje
Personal,Programador Senior,5000,12,60000,30
Personal,Artista 3D,4000,12,48000,24
...
```

## Archivos a Modificar

No hay archivos de código a modificar. Este módulo es documentación financiera.

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Gestión del Proyecto (M133) | Usa presupuesto para planificación |
| Producción (M132) | Alimenta estimaciones de horas |
| Riesgos (M135) | Incluye costos de mitigación |
| Roadmap (M136) | Alimenta schedule con budget |
| Marketing (M151) | Define presupuesto de marketing |
| Plataformas (M97) | Considera costos de distribución |
