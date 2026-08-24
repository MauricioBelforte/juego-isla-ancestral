**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 01-Requerimientos.md — Módulo 105: Telemetría de Gameplay

## ID del Módulo
- **Código:** M105 (plan maestro: sección 104 — Telemetría de Gameplay)
- **Carpeta:** `DOCUMENTACION/105-Telemetria-De-Gameplay/`
- **Dependencias:** M104 (Analytics), M71 (Progresión), M22 (Historia Principal), M102 (Bug Tracking)
- **Carácter:** Módulo de telemetría de gameplay para medir comportamiento de jugadores

## 1. Problema

El proyecto necesita un sistema de **telemetría de gameplay** para medir cómo los jugadores interactúan con el juego, identificar patrones de comportamiento, detectar problemas de diseño y mejorar la experiencia. Debe medir eventos clave (primer tutorial completado, primer recurso recolectado, primera casa, primer NPC, primer puzzle, primer Sello, primer viaje, primera isla, primer museo, primer festival, primer proyecto comunitario), tiempos (hasta primer descubrimiento, hasta primer viaje), abandonos (puzzle abandonado, zonas ignoradas), dificultad percibida, y usar datos para mejorar diseño.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Primer tutorial completado | Medir cuando el jugador completa el tutorial por primera vez |
| RF2 | Primer recurso recolectado | Medir cuando el jugador recolecta el primer recurso |
| RF3 | Primera casa | Medir cuando el jugador construye la primera casa |
| RF4 | Primer NPC | Medir cuando el jugador interactúa con el primer NPC |
| RF5 | Primer puzzle | Medir cuando el jugador completa el primer puzzle |
| RF6 | Primer Sello | Medir cuando el jugador obtiene el primer Sello |
| RF7 | Primer viaje | Medir cuando el jugador hace el primer viaje entre islas |
| RF8 | Primera isla | Medir cuando el jugador descubre la primera isla |
| RF9 | Primer museo | Medir cuando el jugador visita el primer museo |
| RF10 | Primer festival | Medir cuando el jugador participa en el primer festival |
| RF11 | Primer proyecto comunitario | Medir cuando el jugador completa el primer proyecto comunitario |
| RF12 | Tiempo hasta primer descubrimiento | Medir tiempo desde inicio hasta primer descubrimiento importante |
| RF13 | Tiempo hasta primer viaje | Medir tiempo desde inicio hasta primer viaje entre islas |
| RF14 | Puzzle abandonado | Medir puzzles que el jugador abandona sin completar |
| RF15 | Dificultad percibida | Medir dificultad percibida de puzzles y actividades |
| RF16 | Zonas ignoradas | Medir zonas que el jugador no explora |
| RF17 | Uso de datos para mejorar diseño | Analizar datos para identificar problemas de diseño y mejorar experiencia |

## 3. Requisitos No Funcionales

- Telemetría debe ser opcional y con opt-in explícito (cumplimiento GDPR)
- Datos deben ser anonimizados (sin identificadores personales)
- Telemetría no debe afectar rendimiento del juego
- Telemetría debe enviar datos en batch (no individualmente por evento)
- Telemetría debe ser offline-first (caché local cuando no hay conexión)
- Telemetría debe ser compatible con M104 (Analytics)

## 4. Criterios de Aceptación

1. Los 17 puntos de la sección 104 del plan maestro resueltos.
2. Sistema de telemetría con opt-in explícito y GDPR-compliant.
3. Eventos de telemetría medidos correctamente (17 eventos clave).
4. Sistema de medición de tiempos (hasta primer descubrimiento, hasta primer viaje).
5. Sistema de detección de abandonos (puzzle abandonado, zonas ignoradas).
6. Sistema de medición de dificultad percibida.
7. Sistema de análisis de datos para mejorar diseño.
8. Integración con M104 (Analytics) para envío de datos.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M104** — Analytics | Base para analytics |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M104** — Analytics | Depende de este módulo |

