**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 63: Cargas y Streaming

## ID del Módulo
- **Código:** M63 (plan maestro: sección 62 — Cargas y Streaming)
- **Carpeta:** `DOCUMENTACION/63-Cargas-Y-Streaming/`
- **Dependencias:** M08 (mundo voxel), M61 (rendimiento — presupuestos). Relaciones: M45-M47 (assets), M12 (cámara), M29 (GameClock)
- **Delegable desde:** hoy (diseño completo; implementación tras M08 y presupuestos de M61)

## 1. Problema

Cargar el mundo y los recursos sin congelar el juego: pantallas de carga con progreso real, streaming de chunks (cercanos/lejanos), carga asíncrona de escenas, NPCs, audio, texturas y shaders — con movimientos rápidos (Gran Vapor/teletransporte) sin huecos visibles.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Pantalla de carga | Animada (cozy), progreso REAL de la operación (nunca fake), consejos de mundo, pausable con M29 |
| RF2 | Cargas asíncronas | `load_threaded_request` para escenas y recursos; sin bloqueos del hilo principal |
| RF3 | Streaming de chunks | Cargar chunks cercanos (prioridad por distancia a la cámara), descargar lejanos (budget LRU) |
| RF4 | Streaming actor/recursos | NPCs cerca del jugador, audio regional, texturas por LOD y shaders en caché |
| RF5 | Precalentamiento | Pre-como en menú principal: mundo inicial, shaders y bancos de audio antes de spawnear |
| RF6 | Progreso real | Callbacks/semáforos de progreso por operación (contador de ítems cargados/total) |
| RF7 | Océano/subterráneo/islas | Estrategias propias por tipo de mundo (ver sección 3) |
| RF8 | Anti-congelamiento | Nadie puede bloquear el hilo main: comprobable en tests (frame deltas < 50 ms en streaming) |

## 3. Requisitos No Funcionales

- **Cozy:** sin pantallas de carga vacías; el viaje nunca se siente de espera fea; progreso de carga con arte del mundo.
- **Rendimiento (M61):** presupuesto < 50 ms en frames de streaming; cero hitching perceptible; memoria con tope (LRU + pool).
- **Persistencia:** las partidas (M29) no interfieren con el streaming; carga de partida = escena mundo + rehidratación.
- Pausa correcta (M29) durante pantalla de carga: el reloj no avanza en pantalla de carga.

## 4. Criterios de Aceptación

1. Los 15 puntos de la sección 62 resueltos.
2. Arquitectura de pantalla de carga con progreso real documentada.
3. Encolado y presupuestos de streaming voxel/océano/subterráneo/islas definidos.
4. Reglas anti-congelamiento y de descarga (LRU) especificadas.
5. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Streaming de chunks |
| **M061** — Rendimiento | Streaming optimizado |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |
| **M061** — Rendimiento | Depende de este módulo |

