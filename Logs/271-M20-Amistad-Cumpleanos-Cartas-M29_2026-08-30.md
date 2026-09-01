# Log 271: M20 Amistad — Cumpleaños de NPCs + cartas con M29

**Fecha:** 2026-08-30
**Hora:** 19:43
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy AI
**Tarea:** N6 · M20 Amistad · Cumpleaños de NPCs + cartas con M29 (Media 3/5, lógica de calendario y eventos, sin visual)

## Resumen
Implementada la lógica de cumpleaños de NPCs y el sistema de cartas con respuesta
diferida al día siguiente, integrados con el calendario de Aurora (M29). Sin UI/visual
(según alcance pedido). El servicio `FriendshipService` ya existía (ox-alpha); se extendió.

## Cambios realizados
- `scripts/friendship/friendship_service.gd`:
  - Cumpleaños: `es_cumpleanos_hoy`, `proximo_cumpleanos`, `regalar_en_cumpleanos` (usa
    límite propio `"cumpleanos"`, no consume `"regalo"`, +bonus 5), `celebrar_cumpleanos`
    (+15, una vez por año, sin penalización si se omite).
  - Cartas diferidas (M29): `enviar_carta` (1/día), `_madurar_cartas` (respuesta al día
    siguiente, +8 puntos, entrega `adjunto_retorno`), `_recibir_carta_npc`, `get_bandeja`,
    `get_cartas_pendientes`, `get_cartas_pendientes_total`.
  - Punto único de avance de día: `_procesar_nuevo_dia()` (cumpleaños + maduración de cartas),
    invocado desde `dia_cambio` de M29.
  - Señales: `cumpleanos_hoy(npc_id, edad)`; `EventBus.npc.cumpleanos` / `carta_recibida`.
  - Persistencia ISaveProvider M59: cartas, `anio_cumpleanos`, `cumpleanos_anunciados`,
    espejo de calendario. `_registrar_como_proveedor_guardado()` corregido (estaba invocado
    en `_ready()` pero NO definido → el autoload habría crasheado al cargar).
  - Helpers `_emitir_npc_*` guardados con `is_inside_tree()` (no emiten fuera del árbol;
    evita error de `get_node_or_null` con ruta absoluta fuera del árbol en tests).
- `scripts/friendship/vecino_amistad.gd`: agregado límite diario `"cumpleanos": 1` (separado
  de `"regalo"`); métodos `agregar_recuerdo` / `get_recuerdos`; serialización de `recuerdos`.
- `scripts/core/event_bus.gd`: señales `npc.cumpleanos(npc_id, edad)` y `npc.carta_recibida(npc_id, respuesta_id)`.
- `data/amistad/cumpleanos.json` (nuevo): 10 NPCs con `vecino_id, nombre, mes, dia, edad_base`
  (data-driven, placeholder hasta sincronizar desde M19/VecinoData).
- `data/amistad/cartas.json` (nuevo): plantillas `CARTA_GENERICA`, `CARTA_GRACIAS`
  (adjunto `FLOR_SILVESTRE`), `CUMPLEANOS` (adjunto `PASTEL`).
- `scripts/friendship/test_amistad_eventos.gd` (nuevo): test headless, instancia el servicio
  manualmente (el autoload no es alcanzable en `--script`); 28/28 OK.

## Decisiones de diseño
- Cozy / sin FOMO: cumpleaños no expiran (wrap al año siguiente), celebrar es repetible año a
  año, no hay castigo por ausencia.
- Límites diarios por `dia_absoluto()` (monótono) para no romperse en el paso de mes (28→1) ni de año.
- Regalo de cumpleaños NO consume el límite de regalo diario (tope propio de 1/día).
- Cartas: puntos al RECIBIR la respuesta (día siguiente), no al enviar.

## Bugs encontrados y corregidos
1. `_registrar_como_proveedor_guardado()` llamado en `_ready()` pero nunca definido → autoload
   `Friendship` crasheaba al cargar. Definido (duck-typing con `SaveManager.register_provider`).
2. Test: `root.get_node("Friendship")` no disponible en `--script` → instancia manual + carga
   de datos explícita (patrón de `test_amistad.gd`).
3. Test: lambdas de GDScript capturan escalares por valor → resultados de señal vía `Dictionary`
   (tipo referencia) para assertions fiables.

## Verificación
- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad_eventos.gd`
  → `=== Resumen eventos: 28 checks, 0 fallos ===` / `AMISTAD EVENTOS OK` (exit 0).
- El warning `resources still in use at exit` es ruido de cierre headless, no fallo de lógica.

## Archivos modificados
- `game/isla-ancestral/scripts/friendship/friendship_service.gd`
- `game/isla-ancestral/scripts/friendship/vecino_amistad.gd`
- `game/isla-ancestral/scripts/core/event_bus.gd`
- `game/isla-ancestral/data/amistad/cumpleanos.json` (nuevo)
- `game/isla-ancestral/data/amistad/cartas.json` (nuevo)
- `game/isla-ancestral/scripts/friendship/test_amistad_eventos.gd` (nuevo)

## Documentación actualizada
- `CHECKLIST-GLOBAL.md`: M20 → 40/147; pendientes actualizados (cumpleaños/cartas con M29 hechos); Log 271.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/04-Codigo.md`: §6 implementación real (M20+M29).
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`: 10 ítems marcados `[x]`
  (D.50, F.66-70, F.72, H.93, J.115, N.150).

## Pendientes (fuera de alcance de esta tarea)
- VecinoData M19 (gustos reales en vez de placeholder neutral), reacción M21, `.tres` niveles/eventos, DOM-AMISTAD (log centralizado).
