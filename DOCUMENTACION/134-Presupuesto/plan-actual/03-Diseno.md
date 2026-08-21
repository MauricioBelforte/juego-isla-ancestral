# Módulo 134: Presupuesto — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:31:00

## 1. Estructura del Presupuesto

### Desglose por Categorías

```
[PRESUPUESTO TOTAL]
       │
       ├── PERSONAL (55%)
       │      ├── Programadores (30%)
       │      ├── Artistas (15%)
       │      ├── Diseñadores (5%)
       │      ├── Audio (3%)
       │      └── QA/Producción (2%)
       │
       ├── HERRAMIENTAS (10%)
       │      ├── Software (5%)
       │      ├── Hardware (3%)
       │      └── Licencias (2%)
       │
       ├── MARKETING (20%)
       │      ├── Ads digitales (8%)
       │      ├── Events/Convenciones (5%)
       │      ├── PR/Comunidad (4%)
       │      └── Assets de marketing (3%)
       │
       ├── OPERACIONES (5%)
       │      ├── Servicios (2%)
       │      ├── Legal (2%)
       │      └── Contabilidad (1%)
       │
       └── RESERVA (10%)
              └── Imprevistos, overruns
```

## 2. Tabla de Presupuesto

### Plantilla de Presupuesto

| Categoría | Subcategoría | Costo Mensual | Duración | Total | % |
|-----------|-------------|---------------|----------|-------|---|
| Personal | Programador Senior | $X | N meses | $X | — |
| Personal | Programador Junior | $X | N meses | $X | — |
| Personal | Artista 3D | $X | N meses | $X | — |
| Personal | Artista 2D | $X | N meses | $X | — |
| Personal | Game Designer | $X | N meses | $X | — |
| Personal | Audio Lead | $X | N meses | $X | — |
| Personal | QA | $X | N meses | $X | — |
| Herramientas | Unity/Godot | — | — | $0 | — |
| Herramientas | Adobe Suite | $X | N meses | $X | — |
| Herramientas | Perforce/Git | $X | N meses | $X | — |
| Marketing | Ads | $X | N meses | $X | — |
| Marketing | Events | — | — | $X | — |
| Marketing | PR | $X | N meses | $X | — |
| Operaciones | Legal | — | — | $X | — |
| Operaciones | Contabilidad | $X | N meses | $X | — |
| Reserva | 20% del total | — | — | $X | 20% |
| **TOTAL** | | | | **$X** | **100%** |

## 3. Control de Gastos

### Flujo de Control

```
[Gasto Propuesto] ──► [Revisión de Budget]
                            │
                            ▼
                    [¿Dentro del Budget?]
                            │
                    SÍ ──► [Aprobar + Registrar]
                    NO ──► [Evaluar Alternativas]
                                    │
                                    ▼
                            [¿Aprobado por Director?]
                                    │
                            SÍ ──► [Aprobar + Ajustar Budget]
                            NO ──► [Rechazar]
```

### Registro de Gastos

| Fecha | Categoría | Subcategoría | Descripción | Monto | Aprobado por | Notas |
|-------|-----------|-------------|-------------|-------|--------------|-------|
| AAAA-MM-DD | Personal | Programador | Pago mensual | $X | Director | — |
| AAAA-MM-DD | Herramientas | Software | Licencia anual | $X | Director | — |

## 4. Proyecciones de Ingresos

### Escenarios

| Escenario | Precio | Ventas Año 1 | Ventas Año 2 | Ventas Año 3 | Ingresos Totales |
|-----------|--------|-------------|-------------|-------------|-----------------|
| **Pesimista** | $15 | 5,000 | 3,000 | 1,000 | $135,000 |
| **Realista** | $15 | 15,000 | 10,000 | 5,000 | $450,000 |
| **Optimista** | $15 | 30,000 | 20,000 | 10,000 | $900,000 |

### Break-Even

```
Break-Even = Presupuesto Total / (Precio - Costo por Venta)

Ejemplo:
- Presupuesto: $200,000
- Precio: $15
- Costo por venta (30% plataforma): $4.50
- Margen: $10.50

Break-Even = $200,000 / $10.50 = ~19,048 ventas
```

## 5. Dashboard de Presupuesto

### Métricas Clave

| Métrica | Fórmula | Objetivo |
|---------|---------|----------|
| **Burn Rate** | Gasto mensual | Dentro del budget mensual |
| **Runway** | Cash remaining / Burn rate | >6 meses |
| **% Completado** | Gasto real / Presupuesto total | Seguir cronograma |
| **Varianza** | (Real - Plan) / Plan | <10% |
| **Break-Even Sales** | Presupuesto / Margen unitario | Conocer la meta |
