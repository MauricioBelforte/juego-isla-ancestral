# Log 294: M20 Amistad — Sincronización de cumpleaños desde M19 (VillagerProfile)

**Fecha:** 2026-08-30
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy AI
**Tarea:** Continuación de N6 · M20 — sincronizar cumpleaños desde M19 (sin visual, sin visión)

## Resumen
Los cumpleaños de NPCs ahora se sincronizan desde la fuente de verdad de M19
(`VillagerProfile`), en lugar de depender solo del seed `data/amistad/cumpleanos.json`.
M20 *consume* M19 (M19 no se acopla a M20).

## Cambios realizados
- `scripts/npc/villager_profile.gd`: nuevos `@export cumpleanos_mes:int`, `cumpleanos_dia:int`,
  `edad_base:int` (default 0 = sin fecha). `VillagerProfile` no tiene `class_name`
  (solo `extends Resource`); se detecta por duck-typing `has_method("evaluar_objeto")`.
- `data/villagers/catalina_oso.tres`: poblado Catalina (6/14, edad_base 29) como ejemplo real.
- `scripts/friendship/friendship_service.gd`:
  - `const VILLAGER_PROFILE_SCRIPT := preload(...villager_profile.gd)`.
  - `_cumpleanos_desde_perfil(perfil)` (duck-typing; devuelve {} si mes/dia = 0 → no pisa seed).
  - `set_cumpleanos_desde_perfil(perfil)` (fusiona/override por `id`).
  - `sincronizar_cumpleanos_desde_m19()` (itera `VillagerManager.obtener_activos()` y tira de
    `obtener_perfil()`; guardado con `is_inside_tree()`).
  - `_sincronizar_con_m19()` en `_ready()` conecta `VillagerManager.poblacion_cambio` →
    `_on_poblacion_m19` (villager que se muda hoy se sincroniza).
  - `_procesar_nuevo_dia()` llama `sincronizar_cumpleanos_desde_m19()` primero (frescura diaria).
  - Orden en `_ready()`: JSON seed → cartas → calendario → **M19** → save provider.
- `scripts/friendship/test_amistad_eventos.gd`: `_test_sincronizar_cumpleanos_m19()` (7 checks):
  carga perfil válido, override del seed JSON por id, omite perfil sin fecha (mes 0) y nodo ajeno.
  Total: **35/35 OK**.

## Decisiones
- Seed `cumpleanos.json` se mantiene como fallback para NPCs aún no definidos en M19
  (p.ej. los 10 de ejemplo). Cuando M19 agregue `.tres` para esos NPCs, sus perfiles
  sobreescriben el seed automáticamente (misma clave `id`).
- No se modificó M19 para que empuje a M20: la sincronización es unidireccional pull.

## Bug corregido durante la tarea
- `Object.get(prop, default)` NO existe en Godot 4 (1 solo argumento). Las lecturas de
  propiedades de `VillagerProfile` se hicieron por acceso directo (`perfil.cumpleanos_mes`),
  no por `.get(..., "")`.

## Verificación
- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad_eventos.gd`
  → `=== Resumen eventos: 35 checks, 0 fallos ===` / `AMISTAD EVENTOS OK`.
- Sin `SCRIPT ERROR` / errores de boot con el nuevo autoload en árbol (chequeado en el arranque del test).

## Archivos modificados
- `game/isla-ancestral/scripts/npc/villager_profile.gd`
- `game/isla-ancestral/data/villagers/catalina_oso.tres` (nuevo cumpleaños Catalina)
- `game/isla-ancestral/scripts/friendship/friendship_service.gd`
- `game/isla-ancestral/scripts/friendship/test_amistad_eventos.gd`

## Documentación
- `CHECKLIST-GLOBAL.md`: M20 40/147 → 41/148; nota de sync M19; Log 272.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/04-Codigo.md`: §6.2b sync M19.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`: ítem K (sync M19) `[x]`.
