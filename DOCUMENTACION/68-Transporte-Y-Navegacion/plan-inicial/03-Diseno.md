**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 68: Transporte y Navegación

## 1. Arquitectura

```
Assets/_Project/Transport/
├── data/
│   ├── transport_stop.gd          (parada: id, POI M54, tipo, horario M29)
│   ├── transport_route.gd         (ruta: origen, destino, duración, coste M38, restricciones)
│   └── transport_network.tres     (grafo de paradas y rutas — única fuente de verdad)
├── service/
│   ├── transport_manager.gd       (autoload: grafo, boletos, desbloqueos, horarios)
│   ├── trip_service.gd            (ejecuta el viaje: fade M61, destino, orientación)
│   ├── navigation_signs.gd        (carteles y marcadores en el mundo, M46)
│   └── transport_map_layer.gd     (capa de rutas en el mapa M54)
├── ui/
│   ├── transport_panel.gd         (panel de transporte en M53: rutas, costes, horarios)
│   └── trip_transition.gd         (transición cozy con mensaje M44 y progreso M08)
└── validators/
    └── validate_transport.gd      (grafo, señalización vs mapa, costes, transiciones)
```

`TransportManager` (autoload) administra el grafo (`transport_network.tres`): paradas desbloqueadas (M71), horarios (M29), clima (M32) y costes (M38 con descuentos M20). Al elegir una ruta, `trip_service` ejecuta la transición (fade con mensaje, orientación al destino, M61) y registra el viaje (M29/M74). `navigation_signs` coloca los carteles leyendo la MISMA red; `transport_map_layer` dibuja la capa en el mapa (M54). El fast travel (M69) consulta las mismas estaciones.

## 2. Diagramas de Flujo (texto)

### 2.1 Elegir y viajar por una ruta

```
jugador en parada → panel de transporte (M53) o cartel (M70)
  → TransportManager.list_routes(stop):
    → 1) filtrar rutas desbloqueadas y válidas (horario M29, clima M32)
    → 2) calcular coste con descuentos (M20) y duración
    → 3) mostrar rutas en el panel (mapa M54 de referencia)
  → confirmar (con dinero, M38)
    → 4) trip_service.start(route):
      → fade cozy con mensaje "Viajando a X..." (M44, M08 barra si tarda)
      → cargar destino (M61) ANTES de mover al jugador
      → reaparición orientada al destino (nunca perder al jugador)
      → log TRIP-START/TRIP-END
```

### 2.2 Señalización y mapa (una sola fuente)

```
al abrir el mapa (M54) o al construir una parada (M71)
  → transport_map_layer.refresh(): dibujar rutas y marcadores desde el grafo
  → navigation_signs.refresh(): actualizar carteles (M46) con la MISMA red
  → validate_transport.check_signs_vs_map(): nunca discrepancia
```

### 2.3 Viaje narrativo (M22/M23)

```
evento de historia M22 activa una ruta narrativa
  → trip_service.start(route, narrative=true):
    → sin coste, sin horario (ruta especial)
    → diálogos a bordo (M21) durante el trayecto
    → al llegar: avanzar hitos de M22/M23
    → log TRIP-NARRATIVE
```

## 3. Tablas de Métricas (técnico)

### 3.1 Red de transporte típica

| Parada | Tipo | Conexiones | Coste (M38) | Horario (M29) |
|---|---|---|---|---|
| Puerto de Aurora (isla principal) | barco | 6 rutas | 20-80 | 06:00-22:00 |
| Puerto de la Isla del Este | barco | 3 rutas | 30-60 | 07:00-21:00 |
| Plataforma del Norte (dirigible) | dirigible | 2 rutas | 50-90 | 08:00-19:00 |
| Estación Central (tren, si M67) | tren | 4 rutas | 15-40 | 06:30-21:30 |
| Puerto del Festival (M74) | barco/temp | 1 ruta | 10 | solo festival |

### 3.2 Reglas de viaje

| Regla | Valor |
|---|---|
| Transición cozy | < 4 s; barra de progreso (M08) solo si tarda |
| Orientación al llegar | Cámara mira al destino (never lose) |
| Viaje corto (muelle cercano) | Tiempo real (vehículo M67) |
| Viaje largo | Montaje con fade (sin esperas) |
| Coste con descuento | Amistad M20 nivel 5+ → −20% |

### 3.3 Rendimiento (contra M61/M62/M46)

- Red: 8-12 paradas, 15-20 rutas (un `.tres`, sin nodos por escena).
- Señalización: atlas de carteles (M46), batchable, ≤ 4 por escena.
- Capa de mapa (M54): líneas/iconos sin recargar; sin draw calls nuevos (M61).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M28 | Viajes entre islas, puertos |
| M67 | Docking de vehículos en paradas |
| M54 | Capa de transporte en el mapa |
| M53/M44 | Panel de transporte y notificaciones |
| M38 | Costes de rutas |
| M20 | Descuentos por amistad |
| M71 | Desbloqueo de paradas/rutas |
| M29/M32 | Horarios y clima |
| M74 | Viajes especiales de festival |
| M22/M23 | Viajes narrativos |
| M21 | Diálogos a bordo |
| M69 | Coordinación de estaciones (fast travel) |
| M46 | Carteles y marcadores (atlas) |
| M61/M08 | Transición con carga previa y progreso |
| M64 | NPC pasajeros en paradas |
| M108/M118 | Importación y validación en CI |