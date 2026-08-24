**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 67: Vehículos

## ID del Módulo
- **Código:** M67 (CHECKLIST-GLOBAL: ID 67 — Vehículos; plan maestro: sección 66 "VEHÍCULOS")
- **Carpeta:** `DOCUMENTACION/67-Vehiculos/`
- **Dependencias:** M61 (Rendimiento — streaming, presupuestos), M48 (Animación), M43 (Efectos de Sonido), M49 (Iluminación). Relaciones: M28 (Viajes), M51 (Agua — barcos/submarino), M50 (Vegetación), M12 (Mundo), M10 (Terreno/Chunks — streaming), M57 (Interfaz de Control), M14 (Inventario — almacenamiento), M27 (Islas del Mundo), M68 (Transporte y Navegación)
- **Delegable desde:** M61 (rendimiento/streaming), M28 (viajes)

## 1. Problema

Aurora es un archipiélago: la exploración entre islas (M27/M28) exige vehículos. Sin vehículos bien diseñados, el juego degenera en: barcos que se atascan con las olas, dirigibles que rompen el streaming de chunks (M10/M61), submarinos con física rota bajo el agua, o un vehículo con cámara mareante. El plan maestro lista 21 exigencias: barco, dirigible, submarino, locomotora (si existe), física, velocidad, controles, combustible (si existe), reparaciones (si existen), almacenamiento, mejoras, personalización, sonidos, animaciones, cámara, entrada/salida, docking, navegación, colisiones, limitaciones y streaming. El objetivo es que los vehículos de la isla sean: 3 tipos (barco, dirigible, submarino) + locomotora solo si el diseño la exige, con física acotada (nada de física compleja de fluidos), controles simples (M57), sin romper el streaming ni el rendimiento, y con personalización cozy (pintura, banderas).

## 2. Objetivo

Definir el sistema de vehículos de la isla: barco (principal, costa y ríos), dirigible (vuelo entre islas), submarino (buceo M51) y locomotora (opcional, si el ferrocarril existe en el diseño), con: física de vehículo simplificada (movimiento por aguas/vuelo con presets, no simulación fluida), velocidades y controles definidos (M57), sin combustible ni reparaciones (decisiones cozy: mantenimiento simple o nulo), almacenamiento integrado (cofre/baúl M14), mejoras y personalización (pintura, banderas, faroles — M46/M49), sonidos (M43), animaciones (M48), cámara de conducción (M49), entrada/salida con dock (M28), navegación asistida (M68), colisiones y limitaciones (sin atravesar muros, sin volar sobre ciertas zonas), y streaming optimizado (M61 — el dirigible no rompe los chunks). El resultado debe ser vehículos cozy: fáciles de usar, sin fricción y sin bugs de streaming.

## 3. Alcance

### 3.1 Dentro del alcance
- Barco: navegación por agua (M51), vela, dock (M28).
- Dirigible: vuelo libre con altitud, aterrizaje en plataformas.
- Submarino: buceo (M51), visibilidad bajo agua (M49).
- Locomotora: SOLO si el diseño de M68 (Transporte) la exige (ver Nota); diseño condicional.
- Física: presets por vehículo (velocidad, giro, frenado) sin simulación de fluidos; física por KinematicBody/RigidBody acotada.
- Velocidades y controles: definidos y configurables (M57), con gamepad.
- Combustible: NO (decisión cozy; sin grindeo de tanqueo).
- Reparaciones: SI (mantenimiento simple con materiales M15, opcional — no bloqueante).
- Almacenamiento: baúl integrado (M14) con límite por tipo.
- Mejoras: velocidad, giro, faroles, baúl más grande.
- Personalización: pintura, banderas, nombre del vehículo (M46/M87).
- Sonidos (M43): motor/agua/viento con distancia y LOD.
- Animaciones (M48): timón, olas, hélices, pasajeros.
- Cámara: 3ª persona con zoom (M49/M56 no interfiere).
- Entrada/salida: interacción (M70) con dock (M28); sin quedarse atascado.
- Docking: atraque en muelles con magnetismo suave.
- Navegación: asistida (M68) sin mapa abierto.
- Colisiones: con islas, rocas, vegetación (M50); sin atravesar.
- Limitaciones: no en tierra (barco/submarino), altitud máxima (dirigible), sin volar sobre templos (si aplica).
- Streaming: chunks cargados alrededor del vehículo (M10/M61); el dirigible no rompe la generación.
- Validación: `validate_vehicles.gd` (física, streaming, colisiones, audio, animaciones).

### 3.2 Fuera del alcance
- El sistema de viajes entre islas y el mapa: M28 (aquí solo el vehículo; la lógica de viaje es M28/M68).
- El sistema de agua completo: M51 (aquí solo la interacción del vehículo con el agua).
- El sistema de transporte público (tren como red): M68 (aquí solo el vehículo locomotora si existe).
- La economía de combustible: no existe (decisión).
- El fast travel: M69 (separado de los vehículos).

## 4. Restricciones

- **UI Godot 4:** sin templates HTML; HUD del vehículo en M53.
- **Física acotada:** sin simulación de fluidos (el agua es M51, el vehículo usa presets de control); el submarino usa visibilidad, no física compleja de presión.
- **Sin romper el streaming (M61):** el vehículo es un "follow target" del chunk loader (M10): los chunks alrededor del vehículo se cargan en primer lugar.
- **Rendimiento:** presupuesto por vehículo (pooling M62, LOD de audio M43, luces de farol en pool M49); el dirigible no incrementa el draw call budget (M61).
- **Cozy:** sin combustible, sin reparaciones bloqueantes, sin fallas aleatorias que rompan la inmersión.
- **Controles (M57):** teclado + gamepad, con indicador de dirección en el HUD.
- **Validable:** `validate_vehicles.gd` sin errores en consola.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Barco | Navegación por agua (M51) con vela y timón; velocidad de crucero y rápida |
| RF2 | Dirigible | Vuelo con altitud, aterrizaje en plataformas y muelles |
| RF3 | Submarino | Buceo (M51) con visibilidad nocturna (M49) y luces (M49) |
| RF4 | Locomotora | Solo si M68 la exige (condicional); diseño base definido |
| RF5 | Física | Presets por vehículo (velocidad, giro, frenado); KinematicBody/RigidBody acotado |
| RF6 | Velocidad | Definida por tipo; sin velocidades que rompan el streaming |
| RF7 | Controles | Teclado (WASD) + gamepad (M57); giro suave; reversa |
| RF8 | Combustible | NO existe (decisión cozy) |
| RF9 | Reparaciones | Mantenimiento simple con materiales (M15) — opcional, no bloqueante |
| RF10 | Almacenamiento | Baúl integrado (M14) con límite por tipo y slots |
| RF11 | Mejoras | Velocidad, giro, faroles, baúl más grande, pintura especial |
| RF12 | Personalización | Pintura, banderas, nombre del vehículo (M46/M87) |
| RF13 | Sonidos | Motor/agua/viento por vehículo con LOD y distancia (M43) |
| RF14 | Animaciones | Timón, olas, hélices, pasajeros, banderas (M48) |
| RF15 | Cámara | 3ª persona con zoom; sin mareo (M57) |
| RF16 | Entrada/salida | Interacción (M70) con dock (M28); sin quedarse atascado |
| RF17 | Docking | Atraque con magnetismo suave en muelles |
| RF18 | Navegación | Asistida (M68) sin abrir el mapa |
| RF19 | Colisiones | Con islas, rocas y vegetación (M50); sin atravesar |
| RF20 | Limitaciones | No en tierra (barco/submarino); altitud máxima (dirigible) |
| RF21 | Streaming | Chunks alrededor del vehículo priorizados (M10/M61); dirigible sin romper generación |

## 6. Criterios de Aceptación (Verificables)

1. Los 3 vehículos (barco, dirigible, submarino) se controlan con teclado y gamepad sin bugs.
2. El barco navega el agua (M51) sin atravesar islas ni atascarse en rocas.
3. El dirigible vuela entre islas sin romper el streaming de chunks (M10/M61).
4. El submarino bucea y emerge sin errores de física ni de cámara.
5. La entrada/salida con dock (M28) funciona sin quedarse atascado.
6. El baúl (M14), las mejoras y la personalización persisten correctamente (M59).
7. El vehículo no degrada el rendimiento (M61) ni supera el presupuesto de audio/luces (M43/M49).
8. Los sonidos y animaciones (M43/M48) se detienen correctamente al salir del vehículo.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M028** — Viajes | Base para viajes |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M068** — Transporte y Navegación | Usado por transporte y navegación |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M028** — Viajes | Depende de este módulo |
| **M068** — Transporte y Navegación | Este módulo lo necesita |

