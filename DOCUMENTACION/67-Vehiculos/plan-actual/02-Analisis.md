**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 67: Vehículos

## 1. Análisis del Dominio

El dominio de los vehículos de Aurora se descompone en siete subsistemas:

### 1.1 Tipos de vehículo
- **Dominio:** barco (agua M51), dirigible (aire), submarino (subagua), locomotora (condicional a M68).
- **Clave:** cada tipo es un `VehiclePreset` con parámetros de física (velocidad, giro, frenado, altitud máx.) y capacidades (almacenamiento, mejoras). La locomotora se agrega SOLO si M68 define el ferrocarril; el diseño base queda listo.

### 1.2 Física y controles
- **Dominio:** presets de control (no simulación de fluidos): aceleración, giro, frenado, reversa; KinematicBody/RigidBody con masa fija por tipo.
- **Clave (M61):** la física del vehículo es un "controller" simple: no físicas de empuje de olas (M51 simula el agua; el barco lee el nivel para la flotación visual, no física de fluidos).

### 1.3 Streaming (crítico para el dirigible)
- **Dominio:** el chunk loader (M10/M61) prioriza la posición del vehículo: `chunk_target = vehicle.global_position` (cargar alrededor del vehículo ANTES que alrededor del jugador si viaja lejos).
- **Clave:** regla dura: el dirigible a gran altura NO rompe la generación — la distancia de carga escala con la altitud (LOD de chunks M61) y el terreno se genera a menor resolución en altura.

### 1.4 Interacción y docking
- **Dominio:** el jugador entra al vehículo por interacción (M70); al acercarse a un muelle (M28), el docking activa magnetismo suave (ajustar posición/rotación del vehículo al muelle).
- **Clave:** nunca "atascar": si el docking falla (ángulo), se desactiva y el jugador reintenta.

### 1.5 Almacenamiento, mejoras y personalización
- **Dominio:** baúl integrado (M14) con slots por tipo; mejoras (velocidad, giro, faroles, baúl) que son upgrades persistentes (M59); personalización visual (pintura, banderas, nombre — M46/M87).
- **Clave:** los upgrades se guardan con el vehículo (persistencia M59/M60); la pintura usa materiales del pool de M49/M45.

### 1.6 Sonido y animación
- **Dominio:** motor/agua/viento por vehículo con LOD de audio (M43): el sonido se atenúa con la distancia y se silencia > 40 m; animaciones (M48): timón, olas, hélices, banderas con viento (M50) y pasajeros.
- **Clave:** al salir del vehículo, todos los sonidos/animaciones se detienen (sin fuga).

### 1.7 Rendimiento y validación
- **Dominio:** presupuesto por vehículo (draw calls, audio, luces M49 en pool, sin partículas M52 excepto estela de barco vía trigger M52); `validate_vehicles.gd` verifica física, streaming, colisiones y presupuestos.
- **Clave:** la estela del barco y el vapor del dirigible son VFX por eventos (M52), no emisores persistentes.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Simulación de fluidos (barcos) | **Descartado** | Costo; el agua es M51; presets de control |
| Física completa de presión (submarino) | **Descartado** | Visibilidad + flotabilidad simple |
| Dirigible sin LOD de chunks | **Descartado** | Rompe el streaming (M61) — prioridad del chunk target |
| Combustible con tanqueo | **Descartado** | Cozy: sin grindeo de combustible |
| Reparaciones bloqueantes | **Descartado** | Mantenimiento opcional (M15) |
| Barco con físicas de olas en tiempo real | **Descartado** | M51 simula el agua; el barco lee la superficie |
| Locomotora por defecto | **Descartado** | Condicional a M68 (ferrocarril) |

## 3. Decisiones del Módulo

1. **Presets de vehículo** (`VehiclePreset`): barco, dirigible, submarino + plantilla locomotora (si M68 la exige).
2. **Física acotada:** controller simple (velocidad/giro/frenado), sin fluidos.
3. **Streaming:** el vehículo es el `chunk_target` prioritario (M10/M61); LOD de chunks por altitud.
4. **Docking con magnetismo suave** en muelles (M28), sin atascos.
5. **Sin combustible; reparaciones opcionales** (M15); baúl (M14) y mejoras persistentes (M59).
6. **Personalización cozy:** pintura, banderas, nombre (M46/M87).
7. **Audio/animaciones con LOD** (M43/M48); VFX de estela/vapor por eventos (M52).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Dirigible rompe el streaming | Media | Alto | chunk_target del vehículo + LOD por altitud |
| Barco atascado en rocas | Media | Medio | Colisiones suaves + docking y desatascado manual |
| Física de agua inconsistente | Media | Medio | El barco lee la superficie de M51 (visual), no simula |
| Submarino con cámara mareante | Baja | Medio | Cámara 3ª persona con zoom suave (M57) |
| Presupuesto de audio/luces | Media | Medio | LOD de audio (M43) y pool de luces (M49) |
| Vehículo que degrada el render | Media | Medio | Presupuesto por vehículo + validación (M61) |
| Vehículo con VFX persistentes | Media | Medio | VFX solo por eventos (M52) |