# 01 - M169: Doc + Code + Verify (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:50
**Nicho:** Documentacion + Verificacion + Codigo
**Tareas:** 12

## Contexto

M169 Crucero tiene 147[ ] de los cuales 144 son modelado (Blender). Pero hay 21 tareas de doc/code/verify que NO necesitan Blender y que podrias hacer.

## A - Verificacion (6 tareas)

- [ ] T01-01: D-03 Verificar que LOD baja conserve silueta (72m eslora) - revisar GLB en disco
- [ ] T01-02: D-04 Verificar que LOD media conserve chimeneas y botes - revisar GLB
- [ ] T01-03: E-07 Verificar que jugador no pueda caer al agua desde cubierta 1 - revisar colisiones en .tscn
- [ ] T01-04: E-08 Verificar que jugador no atraviese paredes de interiores - revisar CollisionShape3D
- [ ] T01-05: K-03 Verificar que nunca haya 2 cubiertas en memoria - revisar CruceroManager
- [ ] T01-06: P-09 Verificar que ningun otro modulo cambio de comportamiento - diff contra HEAD

## B - Code (4 tareas)

- [ ] T01-07: P-01 tests/unit/test_crucero_manager.gd con 4 estados
- [ ] T01-08: P-02 tests/integration/test_crucero_viaje.gd (embarque → zarpe → llegada)
- [ ] T01-09: J-02 Implementar CruceroManager como autoload (si no esta)
- [ ] T01-10: Q-13 Conectar 5 actividades al EventManager de M74

## C - Doc (2 tareas)

- [ ] T01-11: Actualizar 03-Diseno de M169 con los 56 drifts fixeados en b57
- [ ] T01-12: Anotar 18 iconos de logros rotos (logros.json → assets/ui/logros/*.png) en 04-Codigo

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Verificacion) | 6 |
| B (Code) | 4 |
| C (Doc) | 2 |
| **Total** | **12** |

**Nota:** B-02/B-03 siguen pendientes de Blender + fundador. Estas 12 tareas son trabajo complementario que podrias hacer sin Blender.
