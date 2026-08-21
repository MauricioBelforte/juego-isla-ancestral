# Módulo 145: Diseño de Experiencia — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:32:00

## Archivos a Crear

### 1. `docs/ux/player-journey.md` — Player Journey

Documento con:
- Fases del journey (descubrimiento → postgame)
- Mapa de emociones por fase
- Puntos de decisión del jugador
- Métricas clave por fase

### 2. `docs/ux/onboarding.md` — Sistema de Onboarding

Documento con:
- Eventos guiados (no tutoriales)
- Prerrequisitos de cada evento
- Flujo de onboarding orgánico
- Opciones para saltar tutorial

### 3. `docs/ux/menu-architecture.md` — Arquitectura de Menús

Documento con:
- Estructura de menú principal
- Estructura de menú in-game
- Reglas de navegación
- Atajos de teclado

### 4. `docs/ux/feedback-system.md` — Sistema de Feedback

Documento con:
- Tipos de feedback (visual, sonoro, háptico, textual)
- Mapeo de feedback por acción
- Reglas de feedback cozy
- Presupuesto de feedback por escena

### 5. `docs/ux/accessibility-standards.md` — Estándares de Accesibilidad

Documento con:
- Requisitos mínimos (subtítulos, color-blindness, etc.)
- Checklist de accesibilidad
- Referencia a M58 (Accesibilidad)

### 6. `docs/ux/metrics.md` — Métricas de Experiencia

Documento con:
- Métricas de onboarding (tasa de completado, tiempo)
- Métricas de retención (DAU, MAU, sesiones)
- Métricas de satisfacción (reviews, encuestas)
- Dashboard de métricas

## Archivos a Modificar

No hay archivos de código a modificar. Este módulo es diseño de experiencia.

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| UI/UX (M53) | Implementa menús y navegación |
| Accesibilidad (M58) | Implementa estándares aquí definidos |
| Arte 2D (M46) | Crea assets según guidelines de feedback |
| Historia (M22) | Integra narrativa en player journey |
| Mecánicas (M11-13) | Enseña mecánicas vía onboarding |
