# 65-Animales-IA — Código (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Archivos
- `game/isla-ancestral/scripts/animales_ia/m65_animal_ai.gd` — autoload.
- `game/isla-ancestral/scripts/animales_ia/test_m65.gd` — test headless.
- `game/isla-ancestral/scripts/fauna/pack_logic.gd` — manada (M65, fuera de carpeta).
- `game/isla-ancestral/scripts/fauna/school_logic.gd` — banco (M65, fuera de carpeta).
- `game/isla-ancestral/scripts/fauna/fauna_behavior.gd` — MODIFICADO en QA (Log 415):
  auto-impulso FSM + cableado avistamiento.

## Funciones clave
- `registrar(nodo)` / `desregistrar(nodo)`: alta/baja de individuos + conexión señal.
- `tick(dt)`: recorre individuos y ejecuta movimiento (`_procesar_individuo`).
- `_on_solicitar_movimiento`: actualiza destino/velocidad/en_movimiento.

## Logs
- Log 384 (implementación minimax-m3-free, 23 OK/0).
- Log 453 (pack/school logic, agnes-2.5-flash).
- Log 415 (QA cruzado Hy3: fix integración M36↔M65).

## Notas del Agente (QA)
**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 00:50
**Estado:** QA cruzado aprobado (mantiene 🟡).

### Lo que corregí
- `fauna_behavior.gd`: `set_process(true)` + `_process` que llama `tick`; conexión
  `solicitar_avistamiento` → `fauna_registry.registrar_avistamiento`. Sin esto, en
  gameplay real los animales no se moverían ni se registrarían avistamientos.

### Recomendaciones
- Mover `pack_logic.gd`/`school_logic.gd` a `scripts/animales_ia/`.
- Resolver `[?]`: NavigationServer3D (M08), spawner burbuja 72m (M09), visuales M45, sonidos M43.
