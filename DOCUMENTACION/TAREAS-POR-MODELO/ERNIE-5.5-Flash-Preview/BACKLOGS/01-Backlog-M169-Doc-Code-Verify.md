# 01 - M169: Doc + Code + Verify (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:50
**Nicho:** Documentacion + Verificacion + Codigo
**Tareas:** 12 (todas cerradas 2026-11-25)

## Contexto

M169 Crucero tiene 147[ ] de los cuales 144 son modelado (Blender). Pero hay 21 tareas de doc/code/verify que NO necesitan Blender y que podrias hacer.

## A - Verificacion (6 tareas)

- [x] T01-01: D-03 Verificar que LOD baja conserve silueta (72m eslora) - revisar GLB en disco
- [x] T01-02: D-04 Verificar que LOD media conserve chimeneas y botes - revisar GLB
- [x] T01-03: E-07 Verificar que jugador no pueda caer al agua desde cubierta 1 - revisar colisiones en .tscn
- [x] T01-04: E-08 Verificar que jugador no atraviese paredes de interiores - revisar CollisionShape3D
- [x] T01-05: K-03 Verificar que nunca haya 2 cubiertas en memoria - revisar CruceroManager
- [x] T01-06: P-09 Verificar que ningun otro modulo cambio de comportamiento - diff contra HEAD

## B - Code (4 tareas)

- [x] T01-07: P-01 tests/unit/test_crucero_manager.gd con 4 estados (13 OK / 0 FAIL)
- [x] T01-08: P-02 tests/integration/test_crucero_viaje.gd (embarque → zarpe → llegada) (19 OK / 0 FAIL)
- [x] T01-09: J-02 Implementar CruceroManager como autoload (si no esta) — ya en project.godot
- [x] T01-10: Q-13 Conectar 5 actividades al EventManager de M74 — fix node path `/root/eventos` + logging

## C - Doc (2 tareas)

- [x] T01-11: Actualizar 03-Diseno de M169 con los drifts fixeados en b57 (§11 reconciliacion, 10 drifts verificables)
- [x] T01-12: Anotar 18 iconos de logros rotos (logros.json → assets/ui/logros/*.png) en 04-Codigo (§9)

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Verificacion) | 6 |
| B (Code) | 4 |
| C (Doc) | 2 |
| **Total** | **12** |

**Cerrado:** 2026-11-25 por ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code.
B-02/B-03 siguen pendientes de Blender + fundador (no eran parte de estas 12).

**Nota:** B-02/B-03 siguen pendientes de Blender + fundador. Estas 12 tareas son trabajo complementario que podrias hacer sin Blender.