# Log 302: M31 Ciclo Día/Noche — Núcleo runtime (iteración 1)

**Fecha:** 2026-08-31
**Hora:** 06:30
**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Tarea:** Reserva M31 (excepción F5 autorizada por usuario) → núcleo de ciclo día/noche

## Resumen
Se implementa el núcleo del ciclo día/noche de Aurora consumiendo M29 (GameTime/TimeCalendar). 5 franjas (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA), rotación de fuentes sol/luna en arcos opuestos, anti-oscuridad (piso 0.15), señal `EventBus.time.fase_cambio` en cambio de franja, tests headless 12/0 OK. Reserva M31 sigue activa para iteraciones futuras (assets, faroles, M45/M49/M52).

## Cambios realizados

- `game/isla-ancestral/scripts/world/day_night_cycle.gd` (nuevo, 138 líneas): orquesta el ciclo. Sin `class_name` (no es autoload). Constantes `FASE_ALBA/DIA/ATARDECER/NOCHE/PROFUNDA` + `PHASE_NAMES`. `_ready()` cachea `/root/GameTime` y `/root/EventBus` con `get_node_or_null` (patrón del repo). `_fase_de_hora(hora)` → enum de fase. `_aplicar_iluminacion(hora, tween)` calcula targets por hora (sol/luna/ambiente + color) y los interpola con `Tween` (1.0 s). `_rotar_fuentes(hora)` posiciona sol y luna en arcos opuestos (radio 50, altura 20) usando `look_at` con guarda anti-colineal (§9.9 07-GUIA-GODOT). API pública: `get_fase()`, `es_de_dia()`.
- `game/isla-ancestral/scripts/core/event_bus.gd`: nuevo dominio `var time := TimeEvents.new()` con la clase `TimeEvents` y la señal `fase_cambio(fase: int)`.
- `game/isla-ancestral/scenes/main_island.tscn` (vía godot-mcp `add_node`): nodo `DayNightCycle` (Node3D + script) y nodo `DirLightLuna` (DirectionalLight3D, `light_color` azul, `light_energy=0`, `shadow_enabled=false`, transform inicial). Escena guardada OK (Pack=0).
- `game/isla-ancestral/scripts/world/test_ciclo_dia_noche.gd` (nuevo, 107 líneas): `extends SceneTree`. 12 checks: fases correctas a 08/05/07/19/20/23/10/01 h, sin doble señal misma hora, `get_fase()`/`es_de_dia()` correctos, guardas de escena para checks visuales (que requieren `main_island.tscn`).

## Decisiones

- **Consumo de M29 vía `get_node_or_null("/root/GameTime")`**: el acceso directo al global `GameTime` falla en parse-time dentro de `--script` headless ("Identifier not found"). El repo ya usa este patrón en `time_calendar.gd` y `time/test_consumidores_tiempo.gd`.
- **Sin `class_name`**: evité `class_name DayNightCycle` porque el test usa `const DAY_NIGHT_CYCLE := preload(...)` y el conflicto de identificador rompía la instanciación (`Nonexistent function 'new' in base 'GDScript'`). El script se carga por `res://` path.
- **Rotación de fuentes simple (radio 50, altura 20, 24 puntos por hora)**: V1 funcional. Las curvas 24-puntos y `data/light/*.tres` del diseño quedan para una iteración posterior de datos.
- **Tween 1.0 s** en cada `hora_cambio` para evitar saltos. No se ejecuta por frame.
- **Señal solo en cambio de franja** (cumple el contrato del §2 del diseño): `EventBus.time.fase_cambio` se emite únicamente cuando `_fase_de_hora(hora) != _fase_actual`.

## Verificación

- `godot --headless --path game/isla-ancestral --script res://scripts/world/test_ciclo_dia_noche.gd` → `=== Resumen: 12 checks, 0 fallos ===` / `CICLO DIA/NOCHE OK`.
- Sin SCRIPT ERROR al compilar/arrancar. Los `RID allocations leaked at exit` del log son preexisting (físicas/Jolt/renderer), no del módulo.
- Booting de `main_island.tscn` (vía `godot_add_node` y `save_scene`) carga los nodos `DayNightCycle` y `DirLightLuna` sin errores; las warnings `[DayNightCycle] DirectionalLight no encontrado` solo aparecen en el test standalone (sin escena), como se esperaba.

## Hallazgos / errores documentados

- **Error de parse de GameTime directo**: documentado en este log. La lección (a agregar a 07-GUIA-GODOT §9) es: **nunca referenciar autoloads directamente por nombre global en scripts que se cargan vía `--script` o en grafos de dependencia temprana**; usar siempre `get_node_or_null("/root/Nombre")`. Costo: 1 iteración de reescritura.
- **Conflicto `class_name` vs `const preload()` en tests**: cuando un script tiene `class_name X` y un test hace `const X := preload(path)`, el `preload` puede no exponer `.new()` por la sombra del identificador. Workaround: o no usar `class_name`, o en el test hacer `var inst = (load(path) as GDScript).new()`.

## Archivos modificados/creados
- `game/isla-ancestral/scripts/world/day_night_cycle.gd` (nuevo)
- `game/isla-ancestral/scripts/world/test_ciclo_dia_noche.gd` (nuevo)
- `game/isla-ancestral/scripts/core/event_bus.gd` (dominio `time` + clase `TimeEvents`)
- `game/isla-ancestral/scenes/main_island.tscn` (nodos `DayNightCycle`, `DirLightLuna`)
- `Logs/ULTIMO_NUMERO.txt` → 302
- `CHECKLIST-GLOBAL.md` (nota M31 actualizada)
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/04-Codigo.md` (Notas del Agente)
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md` (bloque iteración 1)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva sección 17)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada M31)

## Pendientes honestos (siguientes iteraciones)
- Curvas 24-puntos en `data/light/*.tres` (energía, color cielo, mods estación, umbrales).
- Prefab de farol con omni 3200K y autoswitch (M17/M18).
- Sincronización de eventos nocturnos con M52 partículas (lluvia de estrellas) y M15 (flora brillante con bonus x2).
- QA visual M114 (checklist nocturno por zona) — pendiente M114 implementado.
- Integración con M49 iluminación global cuando M49 exista.
- Arte/mesh de luna y estrellas (M45/M46).
- Pulido de transición sol/luna (curvas de 90 s amanecer/atardecer del diseño).
- Opción M58 "Noche clara" (piso 0.35) cuando M58 exista.
- Documentar lección `GameTime` global vs `get_node_or_null` en 07-GUIA-GODOT §9.
