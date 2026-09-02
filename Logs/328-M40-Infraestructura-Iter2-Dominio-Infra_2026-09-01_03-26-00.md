# Log 328: M40 Infraestructura — Iter. 2 (dominio infra + transiciones_permitidas)

**Fecha:** 2026-09-01
**Hora:** 03:26
**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 2 del Módulo 40 (Infraestructura), retomando el núcleo de la iter. 1 (Log 298, mismo modelo). Se cerró el circuito de eventos de infraestructura: dominio `infra` en el EventBus, exposición de la API de consulta del flujo (`transiciones_permitidas()`) y reenvío de estado/carga por EventBus. Test headless 28/0 OK, boot del proyecto limpio y regresión M60 66/0 OK.

## Cambios Realizados

1. **`scripts/core/event_bus.gd`:** agregado dominio `infra` (clase `InfraEvents`) con las señales `game_flow_changed(anterior, nuevo)`, `carga_iniciada(ruta)`, `carga_completada(ruta)` y `boot_completado()` (D5 del 03-Diseno). Cambio aditivo: no se tocó ningún dominio existente.

2. **`scripts/core/game_flow_manager.gd`:** expuesto `transiciones_permitidas()` (copia, para UI de pausa/menú — ítem L del checklist); `cambiar_estado()` ahora reenvía el cambio por `EventBus.infra.game_flow_changed` vía `get_node_or_null` (sin class_name, pitfall §9.17/§9.51).

3. **`scripts/core/scene_manager.gd`:** reenvío de `carga_iniciada`/`carga_completada` por `EventBus.infra` en `cambiar_escena()` y `_do_cambio()`.

4. **`scripts/core/test_infraestructura_m40.gd` (NUEVO):** test headless del flujo — dominio infra presente, transiciones válidas e ilegales, `transiciones_permitidas()`, reenvío por EventBus.infra (2 eventos medidos con normalización de estado determinista), SceneManager anti doble-click y ruta inexistente.

5. **Documentación:** checklist de M40 relevado a 40 [x] + 2 [?] (de 211); `plan-actual/04-Codigo.md` con sección de implementación iter. 2 + notas del agente; README de DOCUMENTACION actualizado; registros de coordinación liberados.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/core/event_bus.gd` (dominio infra)
- `game/isla-ancestral/scripts/core/game_flow_manager.gd` (transiciones_permitidas + EventBus.infra)
- `game/isla-ancestral/scripts/core/scene_manager.gd` (señales infra)
- `game/isla-ancestral/scripts/core/test_infraestructura_m40.gd` (creado)
- `DOCUMENTACION/40-Infraestructura/plan-actual/05-Checklist.md` (40/211 + 2 [?])
- `DOCUMENTACION/40-Infraestructura/plan-actual/04-Codigo.md` (sección iter. 2)
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/README.md`
- `Logs/ULTIMO_NUMERO.txt` (328)

## Verificación

- Test M40: `Godot --headless --path game/isla-ancestral --script res://scripts/core/test_infraestructura_m40.gd` → **28 checks, 0 fallos**.
- Boot del proyecto headless: `[M40] Flujo: 0 -> 3`, `DOM-INF integridad OK: 9 dominios`, DataStore M60 sin errores.
- Regresión M60: **66/0 OK** (EventBus compartido, sin romper).

## Pendientes con dueño (siguiente iteración)

- Menú real (`main_menu.tscn` — M89/M53) y flujo BOOT→MENU→CARGANDO→MUNDO completo (M63).
- Escenas `boot.tscn` / `error.tscn` con motivo i18n y reintento (D10).
- Diagnóstico estático RF10 (`diagnostico.gd`, scan de ciclos/capas).
- `limpiar_receptor(nodo)` en EventBus (poda de suscriptores huérfanos).
- GameState real como dato puro (parcialmente cubierto por M59/M60).
- Progreso visual de carga en transiciones (M63).