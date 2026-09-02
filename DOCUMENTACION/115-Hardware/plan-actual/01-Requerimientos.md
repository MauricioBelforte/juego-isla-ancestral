# Módulo 115: Hardware — Requerimientos

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

## Problema

El juego Isla Ancestral debe funcionar en una variedad de hardware del jugador, pero no hay definición de:
- Requisitos mínimos y recomendados de hardware
- Detección automática de capacidades del sistema
- Gestión de calidad gráfica según hardware
- Optimización por plataforma (PC, consolas, mobile)
- Manejo de dispositivos de entrada variados

## Objetivos

1. Definir requisitos de hardware mínimos y recomendados
2. Implementar sistema de detección de hardware
3. Crear sistema de ajuste automático de calidad
4. Definir perfiles de rendimiento por categoría de hardware
5. Gestionar dispositivos de entrada (teclado, mouse, gamepad, touch)

## Alcance

- **Incluye:** Requisitos de hardware, detección, ajuste automático, perfiles de rendimiento
- **No incluye:** Configuración gráfica (M90), rendimiento (M61), plataformas de distribución (M97)

## Restricciones

- El juego debe ser jugable en hardware mínimo definido
- Detección automática no debe causar lag al inicio
- Ajuste de calidad debe ser transparente al jugador
- Soporte para gamepads populares (Xbox, PlayStation, Switch)
- Touch screen para mobile/tablet

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 4-Game Engine, 61-Rendimiento |
| Durante el desarrollo | 57-Interfaz de Control, 90-Configuración Gráfica |
| Relacionados | 72-Validación de Builds, 141-Beta |

## Criterios de Aceptación

- [ ] Requisitos de hardware documentados
- [ ] Sistema de detección de hardware funcional
- [ ] Sistema de ajuste automático de calidad
- [ ] Perfiles de rendimiento por categoría
- [ ] Soporte para gamepads principales

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M004** — Game Engine | Detección de hardware |
| **M061** — Rendimiento | Ajuste por hardware |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M004** — Game Engine | Depende de este módulo |
| **M061** — Rendimiento | Depende de este módulo |

## Nota del agente (2026-09-01, minimax-m3-free / Kilo Code)

> **Iter 1 cerrada (log 327).** 4 archivos nuevos + 1 mod (project.godot). 30 OK / 0 fallos. 50/132 [x] + resto [?] con dueño claro (M90 aplicar calidad, M57 dispositivos, M97 docs Steam/FAQ).
>
> Lo que M115 cubre en este plan:
> - A (3/10): mínimos CPU/RAM/GPU detectados en runtime; OS soportados via OS.get_name().
> - B (15/15): Resource HardwareProfile + Detector + get_input_devices + save/load + fallback.
> - C (10/10): enum QualityPreset, scoring 100pts, bordes ULTRA..VERY_LOW, override.
> - D (0/15): fuera de M115 (M90 Configuración Gráfica aplica al viewport).
> - E (9/10): autoload, init, load, save, set_preset, get_active_preset, runtime; falta signal preset_changed (iter 2 si M90 lo pide).
> - F (10/10): detección via Input.get_connected_joypads + hot-plug + dead zones + vibración.
> - G (10/10): test_hardware.gd cubre detección, scoring, bordes, persistencia, override, gamepad fallback.
> - H (5/10): autoload registrado, OS cross-platform, M90/M61/M57 referenciados; M72/Steam Deck/build pendientes.
> - I (5/10): funciones documentadas con XML docs, logs de cambios; FAQ/Steam pendientes (M97).
>
> El archivo `05-Checklist.md` tiene la cobertura detallada de las 132 tareas.