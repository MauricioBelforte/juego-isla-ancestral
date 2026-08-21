# Módulo 134: Presupuesto — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:31:00

## 1. Análisis del Dominio

### Categorías de Presupuesto para un Juego Indie

| Categoría | % del Total | Ejemplo |
|-----------|-------------|---------|
| **Personal** | 50-70% | Salarios, contratistas, beneficios |
| **Herramientas** | 5-10% | Software, hardware, licencias |
| **Marketing** | 15-25% | Ads, events, PR, comunidad |
| **Operaciones** | 5-10% | Oficina, servicios, legal |
| **Reserva** | 10-20% | Imprevistos, overruns |

### Presupuestos Típicos de Juegos Indie

| Escala | Presupuesto Total | Equipo | Duración |
|--------|-------------------|--------|----------|
| **Micro** | $10K-50K | 1-3 | 6-12 meses |
| **Pequeño** | $50K-200K | 3-8 | 12-18 meses |
| **Medio** | $200K-1M | 8-20 | 18-36 meses |
| **Grande** | $1M+ | 20+ | 3+ años |

### Fuentes de Financiamiento

| Fuente | Ventajas | Desventajas |
|--------|----------|-------------|
| **Ahorros propios** | Control total | Riesgo personal |
| **Crowdfunding** | Validación + marketing | Requiere comunidad |
| **Inversores** | Capital sin deuda | Pérdida de control |
| **Publishers** | Soporte + distribución | Pérdida de margen |
| **Grants** | No diluye | Competitivo |

## 2. Decisiones de Diseño

### Decisión 1: Modelo de Presupuesto

**Opción A:** Presupuesto fijo (top-down)
- Pro: Claro, controlable
- Contra: Puede ser poco realista

**Opción B:** Presupuesto basado en actividades (bottom-up)
- Pro: Más preciso
- Contra: Más trabajo de estimación

**Decisión:** Bottom-up para categorías principales + 20% de reserva para imprevistos.

### Decisión 2: Control de Gastos

**Opción A:** Hoja de cálculo manual
- Pro: Simple, flexible
- Contra: Propenso a errores

**Opción B:** Herramienta especializada (ej: QuickBooks)
- Pro: Automatizado, preciso
- Contra: Costo adicional

**Decisión:** Hoja de cálculo inicial + migrar a herramienta especializada si el equipo crece.

### Decisión 3: Proyecciones de Ingresos

**Opción A:** Proyección optimista
- Pro: Motiva al equipo
- Contra: Puede causar problemas si no se cumple

**Opción B:** Proyección conservadora
- Pro: Realista, seguro
- Contra: Puede desmotivar

**Decisión:** Tres escenarios: pesimista, realista, optimista. Usar el realista para planificación.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Sobrecosto en personal | Media | Alto | Contratos con tope, estimación conservadora |
| Herramientas más caras de esperado | Baja | Medio | Evaluar alternativas gratuitas |
| Marketing subestimado | Alta | Alto | Reserva del 20% para marketing |
| Ingresos menores a esperados | Media | Crítico | Proyección conservadora + reserva |
| Cambios de alcance | Alta | Alto | Proceso de change request |
