# Módulo 134: Presupuesto — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:31:00

## Problema

El proyecto Isla Ancestral necesita gestión presupuestaria pero no hay definición de:
- Presupuesto total del proyecto
- Desglose por categorías (personal, herramientas, marketing, etc.)
- Control de gastos y tracking
- Proyecciones de ingresos
- Punto de equilibrio (break-even)
- Reserva para imprevistos

## Objetivos

1. Definir presupuesto total del proyecto
2. Crear desglose por categorías
3. Establecer proceso de control de gastos
4. Definir proyecciones de ingresos
5. Calcular punto de equilibrio
6. Establecer reserva para imprevistos

## Alcance

- **Incluye:** Presupuesto, gastos, ingresos, break-even, reserva
- **No incluye:** Roadmap (M136), riesgos (M135), producción (M132)

## Restricciones

- Presupuesto realista basado en mercado indie
- Control mensual de gastos
- Reserva mínima del 20% para imprevistos
- Proyecciones conservadoras de ingresos

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 133-Gestión del Proyecto, 132-Producción del Equipo |
| Durante el desarrollo | 135-Riesgos, 136-Roadmap |
| Relacionados | 151-Marketing, 97-Plataformas de Distribución |

## Criterios de Aceptación

- [ ] Presupuesto total definido
- [ ] Desglose por categorías creado
- [ ] Proceso de control de gastos documentado
- [ ] Proyecciones de ingresos calculadas
- [ ] Punto de equilibrio determinado

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M133** — Gestión del Proyecto | Presupuesto de gestión |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M132** — Producción del Equipo | Usado por producción del equipo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M132** — Producción del Equipo | Este módulo lo necesita |
| **M133** — Gestión del Proyecto | Depende de este módulo |

