**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 44: ASMR y Feedback

## ID del Módulo
- **Código:** M44 (plan maestro: sección 43 — ASMR y Feedback)
- **Carpeta:** `DOCUMENTACION/44-ASMR-Y-Feedback/`
- **Dependencias:** M42 (ambiente), M43 (SFX), M41 (música), M34 (animación), M29 (GameClock), M13/M17 (voxel/acción). Relaciones: M58 (accesibilidad)
- **Delegable desde:** hoy (diseño completo; implementación tras sistema de audio base)

## 1. Problema

Convertir cada acción en una **sensación física placentera** (pilar cozy): microfoley, sincronía sonido-animación, estratificación de capas y ajustes contextuales (volumen, distancia, reverb, oclusión) — con reglas explícitas para **no agredir** (nada estridente, nada saturado).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Sensaciones de acción | Cortar madera, cavar, picar piedra, colocar bloques, cosechar, cocinar, abrir cajas: cada una una experiencia ASMR propia |
| RF2 | Pasos por superficie | Caminar diferente audiblemente (refuerza M43 con microfoley suave) |
| RF3 | Sincronía animación-sonido | Los SFX se disparan en los keyframes de la animación (M34), no antes ni después |
| RF4 | Capas de sonido | Estructura: base (ambiente M42) + acción (M43) + microfoley (M44) + respuesta musical (M41) |
| RF5 | Microfeedback | Chasquidos, crujidos, golpes suaves que "premian" cada paso del jugador |
| RF6 | Reglas anti-agresión | Prohibidos: distorsión, picos, drones agresivos, scare chords |
| RF7 | Ajustes contextuales | Volumen por contexto, distancia max, reverb por interior, oclusión por pasaje |

## 3. Requisitos No Funcionales

- **Cozy estricto:** ningún sonido supera -3 LUFS de pico momento; sin sustos; sin latencia perceptible (≤ 60 ms disparo).
- **Rendimiento:** M44 NO agrega fuentes nuevas: reutiliza el pool de M43 (24 voces); microfoley comparte canales P2/P3.
- **Accesibilidad (M58):** opción "feedback reducido" (-6 dB microfoley) y "sonido direccional" para quien lo necesite.
- Pausa con GameClock (M29). Config por bus (M91).

## 4. Criterios de Aceptación

1. Los 17 puntos de la sección 43 resueltos (0-12 son sensaciones/reglas; 13-17 ajustes).
2. Reglas anti-agresión y anti-saturación explícitas y verificables.
3. Mapa sensación→capas de sonido (qué capas se apilan en cada acción).
4. Sincronía con keyframes de M34 definida.
5. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M043** — Efectos de Sonido | ASMR con SFX |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M043** — Efectos de Sonido | Depende de este módulo |

