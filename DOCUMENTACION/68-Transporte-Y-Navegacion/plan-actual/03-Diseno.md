**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 68: Transporte y NavegaciÃ³n

## 1. Arquitectura

```
Assets/_Project/Transport/
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ transport_stop.gd          (parada: id, POI M54, tipo, horario M29)
â”‚   â”œâ”€â”€ transport_route.gd         (ruta: origen, destino, duraciÃ³n, coste M38, restricciones)
â”‚   â””â”€â”€ transport_network.tres     (grafo de paradas y rutas â€” Ãºnica fuente de verdad)
â”œâ”€â”€ service/
â”‚   â”œâ”€â”€ transport_manager.gd       (autoload: grafo, boletos, desbloqueos, horarios)
â”‚   â”œâ”€â”€ trip_service.gd            (ejecuta el viaje: fade M61, destino, orientaciÃ³n)
â”‚   â”œâ”€â”€ navigation_signs.gd        (carteles y marcadores en el mundo, M46)
â”‚   â””â”€â”€ transport_map_layer.gd     (capa de rutas en el mapa M54)
â”œâ”€â”€ ui/
â”‚   â”œâ”€â”€ transport_panel.gd         (panel de transporte en M53: rutas, costes, horarios)
â”‚   â””â”€â”€ trip_transition.gd         (transiciÃ³n cozy con mensaje M44 y progreso M08)
â””â”€â”€ validators/
    â””â”€â”€ validate_transport.gd      (grafo, seÃ±alizaciÃ³n vs mapa, costes, transiciones)
```

`TransportManager` (autoload) administra el grafo (`transport_network.tres`): paradas desbloqueadas (M71), horarios (M29), clima (M32) y costes (M38 con descuentos M20). Al elegir una ruta, `trip_service` ejecuta la transiciÃ³n (fade con mensaje, orientaciÃ³n al destino, M61) y registra el viaje (M29/M74). `navigation_signs` coloca los carteles leyendo la MISMA red; `transport_map_layer` dibuja la capa en el mapa (M54). El fast travel (M69) consulta las mismas estaciones.

## 2. Diagramas de Flujo (texto)

### 2.1 Elegir y viajar por una ruta

```
jugador en parada â†’ panel de transporte (M53) o cartel (M70)
  â†’ TransportManager.list_routes(stop):
    â†’ 1) filtrar rutas desbloqueadas y vÃ¡lidas (horario M29, clima M32)
    â†’ 2) calcular coste con descuentos (M20) y duraciÃ³n
    â†’ 3) mostrar rutas en el panel (mapa M54 de referencia)
  â†’ confirmar (con dinero, M38)
    â†’ 4) trip_service.start(route):
      â†’ fade cozy con mensaje "Viajando a X..." (M44, M08 barra si tarda)
      â†’ cargar destino (M61) ANTES de mover al jugador
      â†’ reapariciÃ³n orientada al destino (nunca perder al jugador)
      â†’ log TRIP-START/TRIP-END
```

### 2.2 SeÃ±alizaciÃ³n y mapa (una sola fuente)

```
al abrir el mapa (M54) o al construir una parada (M71)
  â†’ transport_map_layer.refresh(): dibujar rutas y marcadores desde el grafo
  â†’ navigation_signs.refresh(): actualizar carteles (M46) con la MISMA red
  â†’ validate_transport.check_signs_vs_map(): nunca discrepancia
```

### 2.3 Viaje narrativo (M22/M23)

```
evento de historia M22 activa una ruta narrativa
  â†’ trip_service.start(route, narrative=true):
    â†’ sin coste, sin horario (ruta especial)
    â†’ diÃ¡logos a bordo (M21) durante el trayecto
    â†’ al llegar: avanzar hitos de M22/M23
    â†’ log TRIP-NARRATIVE
```

## 3. Tablas de MÃ©tricas (tÃ©cnico)

### 3.1 Red de transporte tÃ­pica

| Parada | Tipo | Conexiones | Coste (M38) | Horario (M29) |
|---|---|---|---|---|
| Puerto de Aurora (isla principal) | barco | 6 rutas | 20-80 | 06:00-22:00 |
| Puerto de la Isla del Este | barco | 3 rutas | 30-60 | 07:00-21:00 |
| Plataforma del Norte (dirigible) | dirigible | 2 rutas | 50-90 | 08:00-19:00 |
| EstaciÃ³n Central (tren, si M67) | tren | 4 rutas | 15-40 | 06:30-21:30 |
| Puerto del Festival (M74) | barco/temp | 1 ruta | 10 | solo festival |

### 3.2 Reglas de viaje

| Regla | Valor |
|---|---|
| TransiciÃ³n cozy | < 4 s; barra de progreso (M08) solo si tarda |
| OrientaciÃ³n al llegar | CÃ¡mara mira al destino (never lose) |
| Viaje corto (muelle cercano) | Tiempo real (vehÃ­culo M67) |
| Viaje largo | Montaje con fade (sin esperas) |
| Coste con descuento | Amistad M20 nivel 5+ â†’ âˆ’20% |

### 3.3 Rendimiento (contra M61/M62/M46)

- Red: 8-12 paradas, 15-20 rutas (un `.tres`, sin nodos por escena).
- SeÃ±alizaciÃ³n: atlas de carteles (M46), batchable, â‰¤ 4 por escena.
- Capa de mapa (M54): lÃ­neas/iconos sin recargar; sin draw calls nuevos (M61).

## 4. Integraciones Clave

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M28 | Viajes entre islas, puertos |
| M67 | Docking de vehÃ­culos en paradas |
| M54 | Capa de transporte en el mapa |
| M53/M44 | Panel de transporte y notificaciones |
| M38 | Costes de rutas |
| M20 | Descuentos por amistad |
| M71 | Desbloqueo de paradas/rutas |
| M29/M32 | Horarios y clima |
| M74 | Viajes especiales de festival |
| M22/M23 | Viajes narrativos |
| M21 | DiÃ¡logos a bordo |
| M69 | CoordinaciÃ³n de estaciones (fast travel) |
| M46 | Carteles y marcadores (atlas) |
| M61/M08 | TransiciÃ³n con carga previa y progreso |
| M64 | NPC pasajeros en paradas |
| M108/M118 | ImportaciÃ³n y validaciÃ³n en CI |
## Specs Transporte y Navegación (Beam 518)

### Probar con profiler (M116)
- Spec: probar con profiler (M116). Coherente con M68 (transporte) y M116 (profiling).

## Specs Transporte y Navegacion (Beam 711)

### Puertas/gangways animados en paradas (M48)
- Spec: puertas/gangways animados en paradas (M48). Coherente with M68 (transporte) and M48 (animacion).

### Bandera del barco con viento (M50) en paradas
- Spec: bandera del barco con viento (M50) en paradas. Coherente with M68 (transporte) and M50 (vegetacion).

### NPC pasajeros en paradas (M64)
- Spec: NPC pasajeros en paradas (M64). Coherente with M68 (transporte) and M64 (IA).

### NPC abordando el vehiculo (M67)
- Spec: NPC abordando el vehiculo (M67). Coherente with M68 (transporte) and M67 (vehiculos).

### HUD del viaje legible con alto contraste
- Spec: HUD del viaje legible con alto contraste. Coherente with M68 (transporte) and M58 (accesibilidad).


## Specs Transporte y Navegacion (Beam 712)

### Reduce Motion: transiciones cortas sin zoom
- Spec: Reduce Motion: transiciones cortas sin zoom. Coherente with M68 (transporte) and M58 (accesibilidad).

### Subtitulos en mensajes de viaje
- Spec: subtitulos en mensajes de viaje. Coherente with M68 (transporte) and M53 (UI).

### Panel de transporte accesible con gamepad (M57)
- Spec: panel de transporte accesible con gamepad (M57). Coherente with M68 (transporte) and M57 (interfaz).

### Señalizacion batchable (M46, <= 4 carteles por escena)
- Spec: señalizacion batchable (M46, <= 4 carteles por escena). Coherente with M68 (transporte) and M61 (rendimiento).

### Capa de mapa sin draw calls nuevos
- Spec: capa de mapa sin draw calls nuevos. Coherente with M68 (transporte) and M61 (rendimiento).


## Specs Transporte y Navegacion (Beam 713)

### Transicion reutilizable (SceneTransition M61)
- Spec: transicion reutilizable (SceneTransition M61). Coherente with M68 (transporte) and M61 (rendimiento).

### Push del modulo y reporte al usuario
- Spec: push del modulo y reporte al usuario. Coherente with M68 (transporte) and AGENTS.md sec 4.
