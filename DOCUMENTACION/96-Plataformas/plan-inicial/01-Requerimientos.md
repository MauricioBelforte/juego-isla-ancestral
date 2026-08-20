**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 96: Plataformas

## 1. Problema
El juego debe decidir **en qué plataformas publica y con qué prioridad**, analizando costes, certificación, SDKs, logros, cloud saves, soporte de control y cross-save/cross-play de cada una (PC/Steam/Epic/GOG/Microsoft Store/PlayStation/Xbox/Nintendo/Steam Deck/Linux/macOS), para no comprometer recursos antes de tiempo y para definir la estrategia de lanzamiento de M149/M143.

## 2. Objetivo del módulo
Definir el **plan de plataformas** del juego: matriz de análisis (costes, certificación, SDK, logros, cloud, controller, cross-save, cross-play), prioridad de publicación, fechas y decisiones tácticas (Linux/macOS si corresponde), alineado con la monetización (M95) y la preparación de la certificación (M142/M149).

## 3. Alcance (dererivado del plan maestro: sección 95 "PLATAFORMAS")
1. **PC (ventana principal)** — base de la audiencia objetivo.
2. **Steam** — tienda principal: SDK, logros, cloud, workshop (opcional).
3. **Epic Games Store** — requisito del EGS: SDK, logros (EGS), cloud.
4. **GOG** — DRM-free, sin logros obligatorios; requisitos de distribución.
5. **Microsoft Store** — requisitos UWP/Xbox Game Pass si corresponde.
6. **PlayStation** — consola: PS SDK, requisitos de certificación, logros de plataforma.
7. **Xbox** — consola: XDK, requisitos, Play Anywhere (si aplica).
8. **Nintendo** — Switch: requisitos NDA, eShop y políticas de contenido.
9. **Steam Deck** — compatibilidad verificada (verde/plata) en el SDK de Steam.
10. **Linux si corresponde** — nativo vs Proton (decisión técnica).
11. **macOS si corresponde** — Apple Silicon + Intel? (decisión técnica).
12. **Definir prioridad** — matriz por alcance/coste/recurso/timeline.
13. **Analizar certificación** — requisitos de cada tienda/consola.
14. **Analizar costes** — devkits, registros, fees, testing.
15. **Analizar SDK** — versión, dependencias, mantenimiento.
16. **Analizar logros** — API por plataforma y mapeo (M59).
17. **Analizar cloud saves** — API de cloud por plataforma (M60).
18. **Analizar controller support** — gamepad completo (M57/M58) en cada plataforma.
19. **Analizar cross-save** — si un save viaja entre plataformas.
20. **Analizar cross-play** — si hay multiplayer (NO hay: se documenta la decisión).

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Matriz de plataformas 20 pts: soporte/timeline/coste/recurso por fila |
| RF2 | Prioridad de publicación definida (P0-P3) con fechas estimadas |
| RF3 | Decisión PC: Steam primero, luego EGS/GOG según coste/beneficio |
| RF4 | Decisión consolas: Play/Switch/Xbox quintada según devkits y presupuesto |
| RF5 | Decisión portátil: Steam Deck verificado (verde/plata) |
| RF6 | Decisión Linux/macOS documentada (nativo vs Proton/transpilación) |
| RF7 | Análisis de certificación: checklist por plataforma (feed a M142) |
| RF8 | Análisis de costes: tabla de gastos por plataforma (devkit, fee, testing) |
| RF9 | Análisis de SDK: versiones y mantenimiento por plataforma |
| RF10 | Mapeo de logros y cloud saves por plataforma (M59/M60) |
| RF11 | Controller support completo (M57/M58) verificado en cada plataforma |
| RF12 | Decisión cross-play: NO aplica (sin multiplayer) documentada |
| RF13 | Decisión cross-save: si aplica, con el mecanismo definido (M60) |

## 5. Criterios de aceptación (DoD del módulo)
1. Matriz de 20 puntos completa con datos verificables (no opiniones).
2. Prioridades P0-P3 definidas con fechas y recursos asignados.
3. Decisión Steam/EGS/GOG/Microsoft Store con costes y timeline.
4. Decisión consolas remitida a contrato de plataforma (o marcada como "a definir con presupuesto").
5. Steam Deck verificado (o plan de verificación fechado).
6. Linux/macOS con decisión técnica y de soporte.
7. Mapeo de logros/cloud por plataforma y controller support en checklist.
8. Documentación plan-actual actualizada y firmada.

## 6. Restricciones
- **Aplican:** M95 (monetización — precios por plataforma), M142 (certificación), M149 (marketing/plataformas), M59/M60 (saves/cloud/logros), M57/M58 (gamepad/accesibilidad), M22 (sin multiplayer → sin cross-play).
- Los SDKs de consolas requieren NDAs; la documentación solo lista requisitos, no expone contratos.
- Sin recursos: las decisiones de consolas son "GATE por presupuesto" hasta la fase Beta.
- El juego es single-player: cross-play no aplica; cross-save opcional por valor para el jugador.

## 7. Dependencias
- M04 (Arquitectura de código/plataformas base), M95 (Monetización — precios), M149 (Plataformas/Marketing — preparación de tiendas), M59/M60 (Logros/Cloud), M57/M58 (Gamepad/Accesibilidad), M142 (Certificación), M143 (Lanzamiento).

## 8. Entregables del módulo
1. Matriz de plataformas (20 puntos × 11 plataformas).
2. Plan de prioridades y fechas de publicación.
3. Decisiones técnicas (Linux/macOS, Steam Deck, cross-save).
4. Tabla de costes por plataforma.
5. Checklist de certificación por plataforma (feed a M142).