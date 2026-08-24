**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 68: Transporte y Navegación

## ID del Módulo
- **Código:** M68 (CHECKLIST-GLOBAL: ID 68 — Transporte y Navegación; plan maestro: sección 67 "TRANSPORTE Y NAVEGACIÓN")
- **Carpeta:** `DOCUMENTACION/68-Transporte-Y-Navegacion/`
- **Dependencias:** M28 (Viajes), M67 (Vehículos), M54 (Mapa), M53 (UI/UX). Relaciones: M69 (Fast Travel — coordinación), M29 (Tiempo — horarios), M38 (Economía — costes), M22/M23 (Historia — viajes narrativos), M74 (Eventos — viajes especiales), M61 (Rendimiento), M9/M10 (Mundo — POI), M57 (Interfaz de Control), M64 (IA de NPC — pasajeros)
- **Delegable desde:** M28 (viajes), M54 (mapa), M67 (vehículos)

## 1. Problema

Aurora es un archipiélago con puertos, estaciones y rutas: el jugador necesita moverse entre islas (M28) y puntos del mundo (M54) de forma comprensible. Sin un sistema de transporte y navegación, el juego degenera en: rutas invisibles (el jugador no sabe qué conexiones existen), puertos sin señalización (se pierde el barco), costes arbitrarios, o un viaje que "pierde al jugador" durante la transición. El plan maestro lista 20 exigencias: puerto, estaciones, rutas, mapas, waypoints, señalización, carteles, marcadores, fast travel, costes, desbloqueo, restricciones, animaciones, tiempos, transiciones, viajes especiales, viajes narrativos, eventos de ruta, probar navegación y evitar perder al jugador. El objetivo es que el transporte de la isla sea claro y cozy: todo destino visible en el mapa (M54), costes justos (M38), transiciones sin perder al jugador y rutas que conectan con la historia (M22/M23).

## 2. Objetivo

Definir el sistema de transporte y navegación de la isla: infraestructura física (puertos, estaciones y muelles), rutas navegables entre POI (M54), mapas de transporte en la UI (M53), waypoints y señalización en el mundo (carteles, marcadores), coordinación con fast travel (M69), costes por ruta (M38), desbloqueos por progreso (M71), restricciones (horarios M29, clima M32), animaciones y tiempos de viaje (M48), transiciones sin perder al jugador (M61), viajes especiales (festivales M74) y viajes narrativos (M22). El resultado debe ser una red de transporte que se siente parte del mundo: el jugador nunca duda hacia dónde va, nunca se pierde en la transición y las rutas recompensan la exploración.

## 3. Alcance

### 3.1 Dentro del alcance
- Puerto principal y puertos secundarios (M28/M67): muelles con docking (M67).
- Estaciones: de tren (si M67 define la locomotora) y de dirigible (plataformas).
- Rutas: conexiones navegables entre POI (M54) con duración y coste.
- Mapas: vista de transporte en el mapa del juego (M54) con rutas dibujadas.
- Waypoints: puntos de ruta automáticos (seguimiento en viaje) y manuales (marcas del jugador).
- Señalización: carteles en el mundo (direcciones, distancias) y marcadores de paradas.
- Fast travel: coordinación con M69 (teletransporte pago); este módulo define las "estaciones" y M69 el salto.
- Costes: por ruta (M38), con descuentos (relaciones M20).
- Desbloqueo: rutas se descubren al construir infraestructura o por progreso (M71).
- Restricciones: horarios (M29), clima (M32), estación (M29).
- Animaciones (M48): puertas, banderas, NPC pasajeros (M64).
- Tiempos: duración de cada ruta (real vs montaje "fade").
- Transiciones: viaje con pantalla de transición cozy (M53/M44); sin perder al jugador.
- Viajes especiales: festivales (M74), noches de luna (M31), tours turísticos.
- Viajes narrativos: rutas que avanzan la historia (M22/M23) (ej: trayecto a la isla de la historia).
- Eventos de ruta: encuentros aleatorios suaves (NPC en la ruta, M64) sin peligro.
- Validación: `validate_transport.gd` (rutas, costes, transiciones, señalización).

### 3.2 Fuera del alcance
- El sistema de vehículos (física, controles): M67.
- El teletransporte directo (fast travel puro): M69 (aquí solo la coordinación de estaciones).
- El sistema de economía: M38 (aquí solo el coste de rutas).
- El mapa de exploración completo: M54 (aquí solo la capa de transporte sobre él).

## 4. Restricciones

- **UI Godot 4 (Control):** panel de transporte en M53; mapa con capa de rutas en M54.
- **Sin perder al jugador:** la transición de viaje SIEMPRE muestra de dónde sale y adónde llega; la cámara reaparece orientada al destino.
- **Costes justos:** definidos contra M38; sin precios arbitrarios sin razón de diseño.
- **Horarios:** las rutas respetan hora del día (M29) y clima (M32); si el jugador llega "fuera de horario", aviso y espera opcional.
- **Rendimiento:** la red de transporte no agrega draw calls (señalización en atlas M46/M61); la transición usa SceneTransition reutilizable (M61).
- **Cozy:** transiciones breves (< 4 s), sin pantallas de carga frías (M44/MSG de progreso, M08).
- **Validable:** `validate_transport.gd` sin errores en consola.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Puerto | Puertos en islas principales (M28) con docking (M67) |
| RF2 | Estaciones | De tren (si M67) y de dirigible (plataformas) |
| RF3 | Rutas | Conexiones entre POI (M54) con duración y coste |
| RF4 | Mapas | Capa de transporte en el mapa (M54) con rutas dibujadas |
| RF5 | Waypoints | De ruta (automáticos) y manuales (marcas del jugador) |
| RF6 | Señalización | Carteles con direcciones en el mundo (M46) |
| RF7 | Carteles | De paradas con horarios |
| RF8 | Marcadores | Marcas de paradas en el mapa (M54) |
| RF9 | Fast travel | Coordinación con M69 (estaciones → salto pago) |
| RF10 | Costes | Por ruta (M38); descuentos por amistad (M20) |
| RF11 | Desbloqueo | Rutas por infraestructura o progreso (M71) |
| RF12 | Restricciones | Horarios (M29), clima (M32), estación (M29) |
| RF13 | Animaciones | Puertas, banderas, pasajeros (M48/M64) |
| RF14 | Tiempos | Duración por ruta (real o montaje con fade) |
| RF15 | Transiciones | Cozy, < 4 s, sin perder al jugador (M61) |
| RF16 | Viajes especiales | Festivales (M74), luna (M31), tours |
| RF17 | Viajes narrativos | Rutas de historia (M22/M23) |
| RF18 | Eventos de ruta | Encuentros suaves (NPC M64) sin peligro |
| RF19 | Probar navegación | Test de todas las rutas sin bugs |
| RF20 | No perder al jugador | Siempre orientado al destino; avisos claros |

## 6. Criterios de Aceptación (Verificables)

1. Todas las rutas del mapa (M54) son navegables y muestran coste/horario.
2. La señalización del mundo (carteles) coincide con el mapa de transporte.
3. Viajar nunca "pierde al jugador": la cámara reaparece orientada al destino.
4. Los costes respetan M38 y los descuentos de M20.
5. Las restricciones de horario/clima (M29/M32) se cumplen y avisan.
6. Los viajes narrativos (M22) y especiales (M74) funcionan sin fallos.
7. La coordinación con M69 (fast travel) no duplica rutas ni costes.
8. La capa de transporte no degrada el rendimiento (M61).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M028** — Viajes | Base para viajes |
| **M067** — Vehículos | Base para vehículos |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M028** — Viajes | Depende de este módulo |
| **M067** — Vehículos | Depende de este módulo |

