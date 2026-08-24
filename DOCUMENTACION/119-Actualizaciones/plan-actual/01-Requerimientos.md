# Módulo 119: Actualizaciones — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## Problema

El juego Isla Ancestral necesita un sistema de actualizaciones post-lanzamiento, pero no hay definición de:
- Cómo entregar parches y actualizaciones a los jugadores
- Cómo manejar saves compatibles entre versiones
- Cómo notificar al jugador sobre actualizaciones disponibles
- Cómo rollback si una actualización causa problemas
- Cómo gestionar actualizaciones de contenido (DLC, free updates)

## Objetivos

1. Definir estrategia de distribución de actualizaciones
2. Crear sistema de notificación de actualizaciones
3. Implementar compatibilidad de saves entre versiones
4. Definir proceso de rollback de actualizaciones
5. Gestionar actualizaciones de contenido (DLC, patches)

## Alcance

- **Incluye:** Sistema de updates, notificación, compatibilidad de saves, rollback
- **No incluye:** Build pipeline (M117), CI/CD (M118), DLC (M120), soporte post-lanzamiento (M121)

## Restricciones

- Las actualizaciones no deben corromper saves existentes
- El jugador debe poder rechazar actualizaciones (opcional)
- Las actualizaciones deben ser incrementales (no descargar todo de nuevo)
- Rollback debe ser posible si la actualización falla

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 117-Build System, 59-Guardado |
| Durante el desarrollo | 120-DLC y Expansiones |
| Relacionados | 121-Soporte Post-Lanzamiento, 141-Beta |

## Criterios de Aceptación

- [ ] Estrategia de actualizaciones documentada
- [ ] Sistema de notificación de updates
- [ ] Compatibilidad de saves entre versiones
- [ ] Proceso de rollback definido
- [ ] Integración con plataformas (Steam, etc.)

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M059** — Guardado | Base para guardado |
| **M117** — Build System | Updates con build |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M059** — Guardado | Depende de este módulo |
| **M117** — Build System | Depende de este módulo |

