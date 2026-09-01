# Log 295: M20 Amistad — Gustos reales desde M19 + niveles en .tres

**Fecha:** 2026-08-30
**Hora:** 20:26
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy AI
**Tarea:** Continuación de N6 · M20 — "seguir con esos" (pendientes sin visual): (A) gustos
reales de VecinoData M19, (C) recursos de configuración .tres para niveles. Sin visión.

## Resumen
Dos huecos de valor del módulo M20 cerrados, ambos puramente lógicos/data (sin UI):
- **A) Gustos reales:** M20 ahora consume `gustos`/`disgustos` de `VillagerProfile` (M19)
  para evaluar regalos. Antes `_get_vecino_data()` devolvía `null` y TODOS los regalos
  salían NEUTRAL (el sistema ignoraba las preferencias de los NPCs).
- **C) Niveles en .tres:** los umbrales de nivel y recompensas por nivel se externalizaron
  a `amistad_config.tres` (data-driven), con fallback a los const si falta el archivo.

## Cambios realizados
- `scripts/friendship/friendship_service.gd`:
  - **Bug de diseño A:** `_get_vecino_data(vid)` ahora devuelve `{gustos, disgustos}` del
    `VillagerProfile` cacheado (o `{}` => NEUTRAL). Antes devolvía `null`.
  - Cacheo de perfiles M19: `_perfiles` (Dictionary vecino_id -> VillagerProfile), poblado en
    `set_cumpleanos_desde_perfil` (SIEMPRE, aunque el perfil no tenga cumpleaños). Alimenta
    la evaluación de regalos vía `GiftEvaluator.evaluar(vecino_data, item_meta, ya_regalado)`.
  - **C:** `const CONFIG_SCRIPT`, `var _config/_umbrales/_recompensas`; `_cargar_config()`
    carga `res://data/amistad/amistad_config.tres` en `_ready` (fallback a const UMBRALES /
    RECOMPENSAS_NIVEL). `_umbrales` se inyecta en cada `VecinoAmistad` (en `_vecino`,
    `registrar_vecino`, `restore_save_data`). Los 5 `aplicar_puntos(..., _recompensas)`.
- `scripts/friendship/vecino_amistad.gd`:
  - `var umbrales: Array = UMBRALES` (data-driven; reemplaza el const en `aplicar_puntos`,
    `get_progreso`, `deserializar`). El const `UMBRALES` queda como default/fallback.
- `scripts/friendship/amistad_config.gd` (nuevo, `class_name AmistadConfig`):
  `@export umbrales: Array[int]` (11 niveles 0..500), `@export recompensas_nivel: Dictionary`.
- `data/amistad/amistad_config.tres` (nuevo): umbrales + recompensas (mismo contenido que el const).
- `scripts/friendship/test_amistad_eventos.gd`:
  - `const EVAL := preload(gift_evaluator.gd)`.
  - `_test_gustos_reales_m19()` (5 checks): perfil cacheado, dict con gustos, FLOR_SILVESTRE
    => GUSTA, PESCADO (disgusto) => NEUTRAL, sin perfil => NEUTRAL.
  - `_test_niveles_config()` (4 checks): .tres cargado (size 11), umbral nivel 2 = 20,
    VecinoAmistad usa umbrales inyectados, 20 pts => nivel 2.

## Decisiones
- `regalos_amados` (clase AMADO) y `personalidad` aún NO existen en `VillagerProfile`; cuando
  M19 los agregue, `GiftEvaluator` los usa sin tocar M20 (ya lee `regalos_amados` por duck-typing).
- Cozy: un disgusto baja a NEUTRAL, NUNCA castiga (balanceo de diseño vigente).
- Pull unidireccional M20 <- M19 (M19 no se acopla a M20).

## Verificación
- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad.gd`
  → 14/14 OK (regresión base).
- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad_eventos.gd`
  → **44 checks, 0 fallos** (era 35/35; +9 checks de A+C). `AMISTAD EVENTOS OK`.
- Sin `SCRIPT ERROR` en el arranque headless del servicio.

## Archivos modificados
- `game/isla-ancestral/scripts/friendship/friendship_service.gd`
- `game/isla-ancestral/scripts/friendship/vecino_amistad.gd`
- `game/isla-ancestral/scripts/friendship/amistad_config.gd` (nuevo)
- `game/isla-ancestral/data/amistad/amistad_config.tres` (nuevo)
- `game/isla-ancestral/scripts/friendship/test_amistad_eventos.gd`

## Documentación
- `CHECKLIST-GLOBAL.md`: M20 41/148 → 43/148; pendientes reducidos a `reacción M21, DOM-AMISTAD`; Log 295.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`: ítem de gustos M19 `[x]`, ítem `.tres niveles` `[x]`.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/04-Codigo.md`: §6.7 (gustos reales) + §6.8 (niveles .tres); §6.6 conteo 44/44.

## Pendientes del módulo (fuera de alcance, sin visual)
- **B) Reacción M21:** M20 ya emite `EventBus.npc.friendship_level_up` / `gift_given`; falta
  que M21 (Diálogos) consuma el nivel de amistad para variar líneas. Requiere leer M21 antes
  de implementar (es responsabilidad cruzada de M21).
- **D) DOM-AMISTAD:** `Log DOM-AMISTAD centralizado con rotacion` (ítem [M] en checklist) — es
  un documento/esquema de datos de amistad; bajo valor suelto, se aclara con el usuario.
