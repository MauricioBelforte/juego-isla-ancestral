# Log 1517: Fix BUG-124 — Chamán sin malla (solo cápsula) en la colina: `_crear_visuales()` en shaman_npc.gd

**Fecha:** 2026-10-09
**Hora:** 04:46
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

> ⚠️ **Log RETROACTIVO** (creado por pedido del director en msg 86, 2026-10-09 04:34): el cierre
> real ocurrió el **2026-10-09 ~03:39** (encargo msg 82). Evidencia en `11-BUGS.md` + informe
> msg 85. **Aceptado por el director en msg 86** (verificó 12/0 de la suite él mismo).

## Resumen

El NPC chamán de la isla solo mostraba la **cápsula de colisión** (nodo `Chaman` con
`CharacterBody3D` pero sin hijos visuales): invisible como personaje en la colina vacía. Se creó
`_crear_visuales()` siguiendo **el patrón exacto de `villager.gd:74`** para que luzca igual que
el resto de NPCs.

## Cambios Realizados

- **`shaman_npc.gd` (+40 líneas):** `_ready()` ahora llama a `_crear_visuales()` (~L18);
  implementación en ~L68-90 con el patrón de `villager.gd:74`:
  - `CollisionShape3D`-visual: cápsula `Body` en y=0.5 (MeshInstance3D CapsuleMesh)
  - `MeshInstance3D` Head: esfera en y=1.2
  - `Label3D` "Chamán" con `billboard = ENABLED` en y=2.0
- **Sin CollisionShape3D propio** (decisión documentada y validada por el director): el chamán es
  un `Node3D` bajo `InteractableBase` — la interacción es por radio, la colisión física solo
  existe en los `CharacterBody3D` (caso villager), añadirla aquí sería un colisor muerto.
- **Sin material override** (igualmente validado): mismo estilo NPC, sin diferenciación extra.
- **Suite nueva `tests/test_bug124_shaman_visual.gd` (permanente): 12 checks / 0 fallos** —
  verifica hijos visuales (3), tipos, alturas y textos del Label3D.
- Regresión tras ambos fixes del encargo: **runner 24/28 suites · 1.241 checks**
  (único fallo = quirk GdUnit4 preexistente `rc=101, errors=0, failures=0`); `--check-only` EXIT 0.
- **Captura evidencia** `cap_163_2026-10-09_03-39-06_bug124_chaman_malla.png` movida a
  `tools/mcp/godot-mcp/capturas/163-Encantamientos/` (carpeta del módulo; 5 pngs históricos
  incluidos): la figura del chamán se ve en la colina en (2320, 17, 2300).
- Sonda monouso `tests/sonda_bug124_cap.gd` **borrada** tras la captura (patrón de limpieza).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/shaman_npc.gd` (fix +40)
- `game/isla-ancestral/tests/test_bug124_shaman_visual.gd` (suite nueva, permanente)
- `DOCUMENTACION/11-BUGS.md` (BUG-124 → [x] Resuelto con resolución completa)
- Informe de cierre: **msg 85** del canal `mimo-v2.6-flash-free/` (aceptación: msg 86)

**Nota de estado:** cambios **sin stagear/commit** (el director centraliza). Captura de
diagnóstico previa limpiada; solo quedan evidencias en la carpeta del módulo.
