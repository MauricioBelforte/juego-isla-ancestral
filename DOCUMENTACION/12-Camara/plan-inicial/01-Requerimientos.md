**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 12: Cámara

## ID del Módulo
- **Código:** M12 (plan maestro: sección 11 — Cámara)
- **Carpeta:** `DOCUMENTACION/12-Camara/`
- **Dependencias:** M11 (Personaje del Jugador, pivot). Dependen de este: M13 (Herramientas), M15 (Recursos), M74 (Eventos)

## 1. Problema

La cámara debe **acompañar** al personaje en tercera persona sin marear al jugador (cozy), nunca atravesar bloques del mundo voxel y dar planos de juego limpios para explorar, construir e interactuar.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Cámara 3ª persona fija | Tras el hombro derecho, angulo 30°, distancia 5 m |
| RF2 | Spring-arm con colisión | La cámara no atraviesa bloques; se acerca suavemente |
| RF3 | Zoom | 3 niveles: cercano (2.5 m), estándar (5 m), lejano (8 m) |
| RF4 | Cámara de construcción | Al construir, cámara ortográfica sugerida (vista aérea) |
| RF5 | Cámara de menú/diálogo | Cutscene simple: encuadre a la escena (no libre) |
| RF6 | Shake suave | Solo feedback de eventos (terremoto del vórtice, etc.) |
| RF7 | Minimapa | Supervisor: vista aérea del mundo (2D) |
| RF8 | Transiciones | Fade + lerp al cambiar escena/punto (sin saltos) |

## 3. Requisitos No Funcionales

- Sin mareo: sin fov dinámico salvaje, sin motion blur fuerte; aceleración angular limitada tras el hombro.
- Presupuesto: el render de cámara = 1 cámara activa + 1 cámara del minimapa (baja resolución 128×128).
- Configurable en settings: sensibilidad, distancia, zoom por defecto.

## 4. Criterios de Aceptación

1. Los 20 puntos del plan maestro (sección 11) resueltos.
2. Spring-arm con colisión especificado (radio, margen, lerp).
3. Modos de cámara (exploración, construcción, diálogo, cutscene, minimapa) con reglas de activación.
4. Sin contradicciones con M11 (pivot, hitbox) ni con la filosofía cozy.