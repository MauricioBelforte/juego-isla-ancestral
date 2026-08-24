# 01 — Requerimientos — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

El Templo de la Brisa (nota de la tabla global) es la culminación subterránea de la cadena de templos (M24/M25): una dungeona lineal-ramificada con tutorial integrado, puzzles progresivos, sala central con el mecanismo principal, la Cámara del Sello y un cierre narrativo. Debe ser navegable, orientable y accesible, sin softlocks ni exploits.

## Objetivos

- Resolver los 26 puntos de la sección 25 del plan maestro.
- Definir la experiencia completa: entrada → vestíbulo → tutorial → habitaciones intermedias → caminos alternativos → salas secretas → sala central (mecanismo) → puzzle final → Cámara del Sello → salida.
- Definir los sistemas de soporte: checkpoints, iluminación, sonido, partículas, materiales, texturas, iconografía, arquitectura, navegación, telemetría de puzzles.
- Garantizar: sin softlocks (M66), sin exploits, buena orientación y accesibilidad (M58).

## Alcance

- 26 puntos de la sección 25 (diseño y sistemas).
- Telemetría de puzzles (datos de intentos por puzzle, alimenta M24).
- Coordinación de referencias para M45/M47 (materiales/texturas), M43 (sonido/partículas).

## Fuera de alcance

- Implementación física post-voxel (requiere M08 voxel + M61): el diseño debe ser **voxel-compatible**.
- Lore/historia del sello (M22) y diálogos (M23) — solo hooks.
- El tren de espectáculo de la entrada (M66 vehículos) — solo su amarre.
- IA de guardianes (M64) y fauna (M65) dentro del templo — solo puestos de aparición.

## Restricciones

- **Voxel-compatible:** el diseño describe volúmenes cúbicos y corredores que la generación volumétrica de M08 pueda producir; prohibido diseño barroco no voxelizable.
- **Orientación:** corredores con mojones visuales cada 40 m, marcadores direccionales y mapa simple por zona (M58).
- **Accesibilidad (M58):** contrastes, letras grandes en iconografía, tiempos de puzzle sin presión.
- **Cero softlocks (M66)** y **cero exploits** (no avanzar de piso sin el mecanismo, no duplicar llaves).
- Documentación `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 26 puntos de la sección 25 cumplidos y verificables.
2. El diseño voxeliza en M08 sin retrabajo (metría por corredor/pieza).
3. La suite de testings cubre softlocks, exploits, orientación y accesibilidad.
4. Telemetría por puzzle operativa y exportable para balance (M24).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M024** — Templos y Puzzles | Base para templos y puzzles |
| **M025** — Ruinas | Base para ruinas |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M066** — Anti-Softlock | Usado por anti-softlock |
| **M138** — Vertical Slice | Usado por vertical slice |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M024** — Templos y Puzzles | Depende de este módulo |
| **M025** — Ruinas | Depende de este módulo |
| **M066** — Anti-Softlock | Este módulo lo necesita |
| **M138** — Vertical Slice | Este módulo lo necesita |

