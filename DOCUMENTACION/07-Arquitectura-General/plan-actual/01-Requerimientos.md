**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 07: Arquitectura General

## ID del Módulo
- **Código:** M07 (plan maestro: sección 6 — Arquitectura General)
- **Carpeta:** `DOCUMENTACION/07-Arquitectura-General/`
- **Dependencias:** M04 (Godot), M05 (Lenguaje/patrones). **Dependen de este:** M08 en adelante (todos los módulos de sistema)

## 1. Problema

Sin una arquitectura fijada: managers inventados por módulo, dependencias circulares, GameManager gigante, y el GameState esparcido. Con 152 módulos por implementar, la arquitectura ES la garantía de que el proyecto no colapsa al integrar sistemas.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Arquitectura modular por dominio | Un manager/sistema por dominio (economía, mundo, IA…) |
| RF2 | Sin GameManager monolítico | Solo orquestación fina (Bootstrap) |
| RF3 | Sin dependencias circulares | Regla de capas de dependencia estricta |
| RF4 | Sistema de eventos global tipado | EventBus (M05) como columna vertebral |
| RF5 | GameState central | Fuente de verdad serializable/versionada (M59) |
| RF6 | Capas de dependencia | UI → Servicios → Sistemas → Datos (nunca inversa) |
| RF7 | 27 sistemas del plan maestro mapeados | Tabla de diseño en 03-Diseno |

## 3. Requisitos No Funcionales

- Un módulo nuevo se integra sin tocar otros (regla de diseño).
- Testing: cada manager unit-testable (inyección de servicios).
- Rendimiento: el bus de eventos no degrada a 60 FPS (eventos síncronos ligeros + cola para pesados).
- Documentación: diagrama de dependencias mantenible en `04-Codigo.md`.

## 4. Criterios de Aceptación

1. Los 27 puntos del plan maestro (sección 6) resueltos.
2. Diagrama de managers + capas con dependencias NO circulares (verificable por script en M1).
3. Contrato de integración: "agregar un sistema = crear módulo + registrarlo en Bootstrap + escuchar EventBus".
4. Sin acceso directo a GameState desde gameplay (vía servicios).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M004** — Game Engine | Service Locator, capas, EventBus |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M008** — Mundo Voxel | Mundo voxel |
| **M011** — Personaje del Jugador | Personaje |
| **M029** — Tiempo y Calendario | Tiempo/calendario |
| **M036** — Fauna | Fauna |
| **M049** — Iluminación | Iluminación |
| **M059** — Guardado | Usado por guardado |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M004** — Game Engine | Depende de este módulo |
| **M008** — Mundo Voxel | Este módulo lo necesita |
| **M011** — Personaje del Jugador | Este módulo lo necesita |
| **M029** — Tiempo y Calendario | Este módulo lo necesita |
| **M036** — Fauna | Este módulo lo necesita |
| **M049** — Iluminación | Este módulo lo necesita |
| **M059** — Guardado | Este módulo lo necesita |

