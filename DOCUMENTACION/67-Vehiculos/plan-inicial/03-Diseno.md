**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 67: Vehículos

## 1. Arquitectura

```
Assets/_Project/Vehicles/
├── data/
│   ├── vehicle_preset.gd           (modelo: tipo, física, capacidades, mejoras)
│   └── vehicles_catalog.tres       (catálogo: barco, dirigible, submarino, locomotora-plantilla)
├── service/
│   ├── vehicle_manager.gd          (autoload: estado, vehículo activo, entrada/salida, dock)
│   ├── vehicle_controller.gd       (física acotada: velocidad/giro/frenado/altitud)
│   ├── vehicle_streaming.gd        (chunk_target del vehículo, LOD por altitud, M10/M61)
│   ├── vehicle_cargo.gd            (baúl M14, mejoras, personalización, persistencia M59)
│   └── vehicle_dock.gd             (docking con magnetismo suave, M28)
├── ui/
│   ├── vehicle_hud.gd              (HUD del vehículo en M53: velocidad, dirección, baúl)
│   └── vehicle_customize.gd        (pantalla de pintura/banderas/nombre)
└── validators/
    └── validate_vehicles.gd        (validación: física, streaming, colisiones, presupuestos)
```

`VehicleManager` (autoload) orquesta: al entrar (M70), activa `vehicle_controller` (física) + `vehicle_streaming` (chunk_target) + HUD (M53); `vehicle_dock` maneja el atraque (M28); `vehicle_cargo` el baúl (M14) y las mejoras (persistencia M59); los sonidos (M43) y animaciones (M48) se activan con el vehículo y se detienen al salir. Los VFX (M52) se emiten por eventos (estela, vapor).

## 2. Diagramas de Flujo (texto)

### 2.1 Entrada al vehículo (docking)

```
jugador cerca del vehículo + interacción (M70)
  → VehicleManager.enter(vehicle):
    → 1) validar estado (docked y en superficie para barco)
    → 2) activar controller con preset del vehículo
    → 3) vehicle_streaming: chunk_target = vehículo (M10/M61)
    → 4) activar HUD (M53) y cámara 3ª persona (M57)
    → 5) activar sonidos (M43) y animaciones (M48)
    → 6) log VEH-ENTER
```

### 2.2 Conducción (barco como ejemplo)

```
input del jugador (WASD/gamepad, M57)
  → vehicle_controller._process(delta):
    → 1) aceleración/giro/frenado según preset (velocidad máx por tipo)
    → 2) el barco lee la superficie del agua (M51) para flotación visual
    → 3) colisiones con islas/rocas (M50) sin atravesar
    → 4) streaming: chunks alrededor del vehículo priorizados
    → 5) sonidos con LOD (M43); animaciones de timón/olas (M48)
    → 6) log VEH-MOVE (solo debug)
```

### 2.3 Docking y salida

```
jugador cerca de un muelle (M28)
  → vehicle_dock:
    → 1) magnetismo suave: ajustar posición/rotación al muelle
    → 2) si el ángulo es inválido → desactivar y permitir reintento
    → 3) al atracar: log VEH-DOCK; al salir (interacción M70):
    → 4) detener sonidos/animaciones, restaurar cámara del jugador
    → 5) log VEH-EXIT
```

## 3. Tablas de Métricas (técnico)

### 3.1 Presets de vehículos

| Vehículo | Medio | Velocidad máx | Giro | Altitud máx | Baúl (M14) | Mejoras | Combustible |
|---|---|---|---|---|---|---|---|
| Barco | agua (M51) | 12 m/s (crucero 6) | suave | — | 12 slots | velocidad, giro, faroles, baúl 20 | NO |
| Dirigible | aire | 15 m/s | medio | 60 m | 8 slots | velocidad, altitud 90, faroles | NO |
| Submarino | subagua | 8 m/s | medio | −40 m | 10 slots | velocidad, luces (M49), baúl 16 | NO |
| Locomotora | riel (M68) | 20 m/s | fijo | — | 16 slots | velocidad, vagón | NO |

### 3.2 Streaming (regla dura M10/M61)

| Caso | Comportamiento |
|---|---|
| Vehículo en movimiento | chunk_target = vehículo (carga alrededor del vehículo primero) |
| Dirigible a > 30 m de altura | LOD de chunks: terreno a menor resolución; no romper generación |
| Barco en aguas lejanas | Cargar islas cercanas (M27) antes que el terreno lejano |
| Submarino sumergido | Terreno bajo el agua con LOD; sin cargar el cielo innecesariamente |

### 3.3 Rendimiento (contra M61/M43/M49/M52)

- Presupuesto por vehículo: ≤ 30 draw calls (pooling M62).
- Luces de faroles: del pool de M49 (máx 2 por vehículo).
- VFX: solo por eventos (M52): estela del barco, vapor del dirigible.
- Audio: LOD (M43) — atenuar > 40 m, silenciar > 80 m.

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M28 | Viajes entre islas, dock de muelles |
| M68 | Transporte y navegación asistida (locomotora si aplica) |
| M51 | Superficie del agua para flotación; buceo del submarino |
| M10/M61 | chunk_target y LOD de chunks por altitud |
| M57 | Controles de teclado/gamepad y cámara |
| M70 | Interacción de entrada/salida |
| M14 | Baúl integrado (almacenamiento) |
| M59 | Persistencia de mejoras y personalización |
| M46/M87 | Pintura, banderas, nombre, localización |
| M43 | Sonidos con LOD |
| M48 | Animaciones de timón/olas/hélices/pasajeros |
| M49 | Faroles en pool y visibilidad nocturna del submarino |
| M52 | VFX por eventos (estela, vapor) |
| M50 | Colisiones con vegetación |
| M45 | Materiales de pintura |
| M108/M118 | Importación y validación en CI |