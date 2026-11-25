# 02 - M169 Doc + Verificacion + Codigo (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 08:15
**Nicho:** Documentacion + Verificacion + Codigo
**Tareas:** 12

## Contexto

b01 CERRADA (12/12). M169 sigue con 147[ ] pero 144 son Blender. Estas 12 no necesitan Blender.

## A - Verificacion M169 (6)

- [ ] T02-01: Verificar que CruceroManager autoload este en project.godot y funcione
- [ ] T02-02: Verificar que los 5 interiores tengan CollisionShape3D (no atraviesen paredes)
- [ ] T02-03: Verificar que el bote salvavidas tenga colision correcta
- [ ] T02-04: Verificar que las 24 ventanas de camarote no se solapen (AABB)
- [ ] T02-05: Verificar que el HUD de tienda (M-06) muestre precios correctos
- [ ] T02-06: Verificar que no haya 2 cubiertas en memoria simultaneamente (K-03)

## B - Codigo M169 (4)

- [ ] T02-07: P-01: tests/unit/test_crucero_manager.gd (4 estados: inactivo/embarque/zarpe/llegada)
- [ ] T02-08: P-02: tests/integration/test_crucero_viaje.gd (embarque → zarpe → llegada)
- [ ] T02-09: Q-13: Conectar 5 actividades al EventManager de M74
- [ ] T02-10: L-04: Dialogo ambiental simple al interactuar (1 linea por NPC)

## C - Doc M169 (2)

- [ ] T02-11: Actualizar 03-Diseno de M169 con los 56 drifts fixeados + 18 iconos logros
- [ ] T02-12: Verificar que 04-Codigo de M169 mencione CruceroManager + autoload + tests

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Verif) | 6 |
| B (Code) | 4 |
| C (Doc) | 2 |
| **Total** | **12** |

**Nota:** B-02/B-03 siguen en STANDBY (Blender + fundador). Estas 12 son complemento.
