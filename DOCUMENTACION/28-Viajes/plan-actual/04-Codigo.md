**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 28: Viajes

## 1. Rutas de Código (res://)

```
res://_Project/gameplay/travel/
├── travel_service.gd          Autoload "TravelService" (orquesta el viaje)
├── travel_state.gd            Defines de estados y utilidades del viaje
├── boat.gd                    Gran Vapor (movimiento por curva, estados)
├── boat_route.gd              Resource de ruta (origen, destino, curva, coste)
├── harbor.gd                  Puerto de cada isla (docks, embarque)
├── harbor_dock.gd             Punto de atraque con lock/liberación
└── travel_events.gd           Eventos suaves del trayecto (NPC, coleccionables)

res://_Project/ui/travel/
└── travel_ui.gd               TravelUI (CanvasLayer) — capa UI pura

res://_Project/world/islands/  (M27 — no tocar)
└── ...                        Harbors instanciados por isla

res://_Project/data/routes/    (Resources BoatRoute, arranque)
├── ruta-aurora-coral.tres
├── ruta-aurora-verde.tres
├── ruta-aurora-cenizas.tres
└── ruta-secreta-cielos.tres
```

## 2. Firmas Clave (GDScript)

```gdscript
# travel_service.gd (autoload)
func request_travel(destination_island_id: String) -> Dictionary:
    # valida: desbloqueo M22/M70, horario M29, coste M38, clima M32, dock M27
func cancel_travel() -> Dictionary
func get_available_destinations() -> Array[BoatRoute]
func apply_weather_delay(weather: Dictionary) -> void:
    # M32: retraso = randf_range(5.0, 15.0) si adverso; NUNCA cancela el viaje
func serialize() -> Dictionary:
    # { "route_id": StringName, "progress": float, "state": int, "remaining": float }
func restore(saved: Dictionary) -> void
```

```gdscript
# boat.gd
func _physics_process(delta: float) -> void:
    # avanza t a lo largo de BoatRoute.curve cuando TravelState.SAILING
    # velocity_utilizado = curve.sample_baked(t + distancia) - global_position
func set_weather_factor(factor: float) -> void:
    # factor 0.0..1.0: escala balanceo (shake) y la velocidad de avance (retraso x1.25)
func start_sailing() -> void:
    # emite travel_started(BoatRoute); activa estela (M51) y silbato (M42)
func stop_at_dock(dock: HarborDock) -> void:
    # APRROACH: interpolación de posición/rotación hacia dock.global_position
```

```gdscript
# boat_route.gd
func sample_position(t: float) -> Vector3:
    return curve.sample_baked(t * curve.get_baked_length())
func compute_duration_with_weather(factor: float) -> float:
    return base_duration_seconds * (1.0 + 0.25 * factor)   # tope 90 s
```

```gdscript
# harbor.gd
func find_free_dock() -> HarborDock:
    # recorre docks; devuelve el primero con docked_boat == null
func lock_dock(dock: HarborDock) -> bool:
    return dock.lock(boat_ref) if dock.is_available() else false
func release_dock(dock: HarborDock) -> void:
    dock.release()
```

```gdscript
# travel_ui.gd
func _on_reservation_confirmed(route_id: StringName) -> void:
    emit_signal("confirm_reservation", route_id)   # sin lógica de gameplay
func set_interactive(enabled: bool) -> void:
    for button in _buttons: button.disabled = not enabled   # sección 8 AGENTS.md
```

## 3. Lógica Central (pseudocódigo de referencia)

```gdscript
# travel_service.gd
func request_travel(destination: String) -> Dictionary:
    if is_traveling(): return {"ok": false, "reason": "ya_hay_viaje"}
    var route := _find_route(destination)
    if route == null or not _is_unlocked(route): return {"ok": false, "reason": "bloqueado"}
    if not _economy.pay(route.cost_coins): return {"ok": false, "reason": "sin_dinero"}
    if _is_adverse_weather(): apply_weather_delay(_weather.get_state())
    _economy.consume_boat_ticket(route)                 # RF1: boleto
    _harbor_origen.lock_dock(dock_origen)
    _harbor_destino.lock_dock(dock_destino)             # reserva temprana (D4)
    _streaming.preload_island(route.destination_island_id)  # M63
    boat.set_route(route)
    state = TravelState.BOARDING
    return {"ok": true, "delay": _delay_seconds}
```

## 4. Estados del Viaje (travel_state.gd)

```
IDLE → BOARDING → WAITING_DEPARTURE → SAILING → ARRIVING → IDLE
       └────────────── CANCEL (devolución) ──────────────┘
```

Transiciones válidas exclusivamente a través de `request_travel()`, `cancel_travel()` y la señal `travel_arrived()`. El jugador no puede interrumpir `SAILING` (salvo guardar/restaurar M58).

## 5. Eventos del Trayecto (travel_events.gd)

- `travel_progress(progress)` → dispara eventos cuando `progress` cruza umbrales (0.3, 0.6, 0.8): NPC viajero saluda, coleccionable visible junto a la ruta, diálogo breve del capitán.
- Los eventos son opcionales y no bloquean la travesía (RF9).

## 6. Guardado y Restauración (M58)

```gdscript
func serialize() -> Dictionary:
    return {
        "route_id": _current_route.route_id,
        "state": state,
        "progress": _progress,
        "remaining_seconds": _remaining_seconds,
    }

func restore(saved: Dictionary) -> void:
    _current_route = _routes[saved["route_id"]]
    state = saved["state"]
    _progress = saved["progress"]
    _remaining_seconds = saved["remaining_seconds"]
    boat.teleport_to_curve_point(_progress)   # reaparece a mitad de ruta
```

## 7. Logs del Sistema

- **Consola de desarrollo (Debug):**
  - `TravelService`: `[VIAJE] reserva creada: aurora -> coral (30 s, 5 monedas)`
  - `[VIAJE] retraso por clima: tormenta, +8 s (nunca bloquea)`
  - `[VIAJE] llegada a coral: dock 1 atraque ok (0.5 s de espera)`
  - `[VIAJE] cancelado: devolución 50 % (3 monedas)`
- **Log persistente (sección 18 AGENTS.md):** solo eventos de guardado y errores graves:
  - `[ERROR][VIAJE] restore fallido: ruta desconocida "<id>" — se devuelve al muelle de origen`
- **Mensajes al jugador (UI, no log):** avisos de retraso, confirmaciones de coste, llegadas y devoluciones viven en `TravelUI`, nunca en la consola.

## 8. Buenas Prácticas

- `Class_name` y tipos estáticos en todas las firmas (Godot 4.x, `@export` en variables de escena).
- Sin `get_node()` en bucles calientes: cachear `_boat`, `_harbors` y `_routes` en `_ready()`.
- `TravelUI` no conoce economía ni clima: solo emite señales (sección 9 AGENTS.md).
- Recursos `BoatRoute` como `.tres` versionables en `res://_Project/data/routes/`.