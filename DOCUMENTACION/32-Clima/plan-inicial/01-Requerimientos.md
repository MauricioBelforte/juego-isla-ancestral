**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 32: Clima

## ID del Módulo
- **Código:** M32 (plan maestro: sección 31 — Clima)
- **Carpeta:** `DOCUMENTACION/32-Clima/`
- **Dependencias:** M29 (GameClock/calendario — estaciones), M31 (fases de luz). Consumidores: M19 (NPC), M33 (Agricultura), M34 (Pesca), M36 (Fauna), M41-M44 (Audio), M49/M50/M51 (iluminación/vegetación/agua), M63 (Cargas)
- **Delegable desde:** hoy (diseño completo; implementación tras M29/M31)

## 1. Problema

Definir el sistema de clima del mundo: tipos, frecuencia estacional, duración, transiciones y efectos sobre jugabilidad — **sin que el clima jamás moleste, bloquee o frustre** (pilar cozy/anti-FOMO) y con opciones de accesibilidad.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tipos de clima | Soleado, parcialmente nublado, lluvia, tormenta, niebla, nieve (solo invierno), viento, tormenta tropical (rara, verano) y especiales (aurora, arcoíris) |
| RF2 | Frecuencia | Probabilidades por estación (M29): determinista por semilla + fecha (mismo día = mismo clima) |
| RF3 | Duración | Ciclos cortos y agradables: 2-4 h de juego; duración máxima fijada por tipo |
| RF4 | Transición | Crossfade gradual 60-90 s de juego; sin cortes bruscos |
| RF5 | Partículas | Lluvia/nieve/hojas con GPU particles; 1 sistema compartido; pausables |
| RF6 | Sonidos/música | Buses M42 + variantes M41 por clima; truenos lejanos y suaves |
| RF7 | Iluminación | Atenuación del sol según tipo (lluvia -30%, tormenta -65%); nieve más brillante |
| RF8 | Efectos de mundo | Vegetación con sway (M50), agua agitada (M51), nieve acumulada visual (M08) |
| RF9 | Comportamiento | NPC buscan refugio en tormenta (nunca castigante); fauna se refugia; agricultura recibe riego gratis con lluvia |
| RF10 | Eventos especiales | Aurora boreal (invierno), arcoíris tras lluvia, lluvia de estrellas solo con cielo despejado (M31) |
| RF11 | Anti-molestia | Nada del progreso exige un clima específico; aviso de tormenta 1 día antes (M29) |
| RF12 | Accesibilidad | Reducir lluvia/niebla/truenos desde ajustes (M58) |

## 3. Requisitos No Funcionales

- **Determinismo:** dado seed + fecha (M29) → clima del día calculable (evita bugs de recarga y trampas de re-roll).
- **Rendimiento:** presupuesto ≤ 1 ms GPU en pico (partículas, niebla, agua); cero overhead cuando hace sol.
- Sin daños: el clima NO destruye cosechas, NO deja al jugador varado, NO fuerza sesiones.
- Transiciones sin parpadeos; partículas pausan con el juego (M29 pausa).

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 31 resueltos (tabla punto por punto).
2. Tabla de probabilidades estacionales + duración por tipo fijadas.
3. Regla anti-molestia documentada (qué NO puede hacer el clima nunca).
4. Determinismo explicado con su fórmula.
5. Módulo marcado delegable (implementación → AGENTE DELEGADO tras M29/M31).