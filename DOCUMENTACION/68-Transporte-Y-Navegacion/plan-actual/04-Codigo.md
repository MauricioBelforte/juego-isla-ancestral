**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 68: Transporte y Navegación

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `transport_stop.gd` | `Assets/_Project/Transport/data/` | Parada: id, POI (M54), tipo, horario (M29) |
| `transport_route.gd` | `Assets/_Project/Transport/data/` | Ruta: origen, destino, duración, coste (M38), restricciones |
| `transport_network.tres` | `Assets/_Project/Transport/data/` | Grafo de paradas y rutas (única fuente de verdad) |
| `transport_manager.gd` | `Assets/_Project/Transport/service/` | Autoload: grafo, boletos, desbloqueos (M71), horarios |
| `trip_service.gd` | `Assets/_Project/Transport/service/` | Ejecuta el viaje: fade (M61), destino, orientación |
| `navigation_signs.gd` | `Assets/_Project/Transport/service/` | Carteles y marcadores en el mundo (M46) |
| `transport_map_layer.gd` | `Assets/_Project/Transport/service/` | Capa de rutas en el mapa (M54) |
| `transport_panel.gd` | `Assets/_Project/Transport/ui/` | Panel de rutas/costes/horarios (M53) |
| `trip_transition.gd` | `Assets/_Project/Transport/ui/` | Transición cozy (M44, progreso M08) |
| `validate_transport.gd` | `Assets/_Project/Transport/validators/` | Grafo, señalización vs mapa, costes, transiciones |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `transport_manager.gd` (autoload)
```gdscript
func list_routes(stop: String) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    for r in _network.routes:
        if r.from_id != stop: continue
        if not _is_unlocked(r): continue  # M71
        if not _is_in_schedule(r): continue  # M29 + M32 clima
        var price := r.base_cost
        if Friendship.level(_rider()) >= 5: price = int(price * 0.8)  # M20
        out.append({"route": r, "price": price, "duration": r.duration})
    return out

func buy_ticket(route: TransportRoute, stop: String) -> bool:
    var price := _price(route)
    if not Economy.spend(price): return false  # M38
    TripService.start(route, stop)
    LOGS.transport("TRIP-START", {"route": route.id, "price": price})
    return true
```
**Logs:** `TRIP-START` (inicio de viaje), `TRIP-END` (llegada), `TRIP-NARRATIVE` (viaje de historia), `STOP-UNLOCKED` (parada desbloqueada M71).

### 2.2 `trip_service.gd` (transición sin perder al jugador)
```gdscript
func start(route: TransportRoute, from_stop: String) -> void:
    var dest: Vector3 = TransportManager.stop_pos(route.to_id)
    await TripTransition.play("transport.traveling_to", route.to_name)  # M44
    SceneLoader.preload_zone(route.to_id)  # M61: cargar ANTES de mover
    Global.player.global_position = dest + _spawn_offset()
    Global.player.look_towards(_exit_direction(route.to_id))  # orientación
    TripTransition.finish()
    TransportManager.sign_arrival(route.to_id)  # M29/M74 registro
    LOGS.transport("TRIP-END", {"to": route.to_id})
```

### 2.3 `navigation_signs.gd` (una sola fuente)
```gdscript
func refresh() -> void:
    for sign in _signs: sign.queue_free()  # reconstruir desde el grafo
    for stop in TransportNetwork.stops:
        if stop.has_sign && WorldState.is_visible(stop.poi):  # M54
            var s := _spawn_sign(stop)
            s.set_text(_sign_text(stop))  # direcciones + distancia (M46)
    # El validador compara carteles vs capa del mapa (M54): nunca discrepancia
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Transporte |
|---|---|---|
| `STOP_BUILT` | M71 (progresión) | Desbloquear parada + señalización |
| `FESTIVAL_STARTED` | M74 | Parada temporal del festival + viaje especial |
| `NARRATIVE_ROUTE` | M22/M23 | Viaje narrativo sin coste con diálogos (M21) |
| `TRIP_FINISHED` | trip_service | M29 registro de tiempo, M74 eventos en destino |
| `WEATHER_CHANGED` | M32 | Revalidar rutas activas (restricción) |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[TRP]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 68 completo (diseño técnico de Godot 4): grafo central de paradas y rutas (única fuente de verdad), capa de transporte en el mapa (M54), señalización física que lee la misma red, transición cozy reutilizable (M61) con orientación al destino, coordinación con M69 (estaciones compartidas sin duplicar costes), viajes especiales (M74) y narrativos (M22/M23) con diálogos a bordo (M21).

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Confirmar si la estación de tren existe: dependiente de M67 (locomotora condicional) y del ferrocarril del diseño; está modelada como parada opcional.
- `[?]` Confirmar los precios exactos de las rutas: los valores de la tabla 3.1 son estimaciones para el diseño; los números finales vienen de la economía de M38.

### Intentos fallidos / decisiones
- Decidí el grafo central de rutas en un `.tres` como única fuente de verdad (evita la discrepancia señalización-mapa).
- Decidí la coordinación M68/M69 por estaciones compartidas: M68 vende "boletos de ruta" y M69 vende "teletransporte" (más caro, sin animación).
- Decidí que los viajes largos usan montaje con fade (no tiempo real) y los cortos van en tiempo real con el vehículo (M67).

### Recomendaciones para el próximo agente
- Al implementar: probar la transición de viaje con el streaming activo (M61) — el destino debe cargarse ANTES de mover al jugador.
- Probar viajes de festival (M74) con paradas temporales y viajes narrativos (M22) con diálogos a bordo (M21).
- Coordinar los precios finales con M38 y los descuentos de M20 en la fase de implementación.