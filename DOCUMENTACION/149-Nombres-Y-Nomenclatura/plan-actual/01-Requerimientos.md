# Módulo 149: Nombres y Nomenclatura — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:35:00

## Problema

El proyecto necesita un sistema de nombres consistente para:
- Nombres de NPCs y su significado
- Nombres de lugares de la isla
- Nombres de eventos y festivales
- Nomenclatura de archivos y carpetas del proyecto
- Convenciones de nombres en código (variables, funciones, clases)
- Tags y categorías de assets

Sin un sistema, cada desarrollador nombrará diferente, generando inconsistencias.

## Objetivos

1. Definir guía de nombres para NPCs (significado, origen cultural)
2. Definir guía de nombres para lugares (toponimia)
3. Definir convenciones de nombres de archivos y carpetas
4. Definir convenciones de nombres en código
5. Crear tabla de referencia rápida
6. Establecer proceso de validación de nombres

## Alcance

- **Incluye:** Nombres de NPCs, lugares, eventos, convenciones de código, naming conventions
- **No incluye:** Localización/i18n (M103), Audio (M41-44)

## Restricciones

- Nombres con significado (no aleatorios)
- Orígenes culturales variados (árabe, bereber, español)
- Fáciles de pronunciar
- Sin nombres ofensivos o problemáticos
- Consistencia en todo el proyecto

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 22-Historia, 23-NPCs, 30-Mundo |
| Durante el desarrollo | Todos los módulos de código |
| Relacionados | 103-Localización, 41-44-Audio |

## Criterios de Aceptación

- [ ] Guía de nombres de NPCs completada
- [ ] Guía de nombres de lugares completada
- [ ] Convenciones de código documentadas
- [ ] Tabla de referencia creada
- [ ] Proceso de validación establecido

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M147** — World Building | Nombres en world building |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M150** — Diseño Sonoro Narrativo | Diseño sonoro narrativo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M147** — World Building | Depende de este módulo |
| **M150** — Diseño Sonoro Narrativo | Este módulo lo necesita |

