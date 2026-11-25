# 02 - M169 Doc + Verificacion + Codigo (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 08:15
**Nicho:** Documentacion + Verificacion + Codigo
**Tareas:** 12 (10 cerradas 2026-11-25, 2 con duda honesta)

## Contexto

b01 CERRADA (12/12). M169 sigue con 147[ ] pero 144 son Blender. Estas 12 no necesitan Blender.

## A - Verificacion M169 (6)

- [x] T02-01: Verificar que CruceroManager autoload este en project.godot y funcione — `CruceroManager="*res://scripts/crucero/crucero_manager.gd"` tras TransportManager; boot emite `[CRU] catalogos cargados: 3 clases, 7 camarotes`.
- [x] T02-02: Verificar que los 5 interiores tengan CollisionShape3D (no atraviesen paredes) — 4 escenas `interior_cubierta_1..4.tscn` con `StaticBody3D` (piso + 2 paredes), 4/4 cargan OK. La bodega es un 5º espacio sin `.tscn` propio (modelado Blender pendiente).
- [?] T02-03: Verificar que el bote salvavidas tenga colision correcta — el exterior es un GLB sin `.tscn` de colisión (no existe `crucero.tscn`); la colisión del casco/botes es iter 2 (03-Diseno §7/§11 D-07). Requiere Blender + revisión del fundador (B-02/B-03).
- [?] T02-04: Verificar que las 24 ventanas de camarote no se solapen (AABB) — requiere parseo geométrico del GLB en Blender; este harness no tiene visión ni Blender conectado. Honesto: no verificable hoy.
- [x] T02-05: Verificar que el HUD de tienda (M-06) muestre precios correctos — `shop_ui.gd` L199/L222 usa `EconomyManager.precio_compra_vigente/precio_venta_vigente` y muestra `"%s — %d AO (x%d)"`; precios en vivo, no hardcodeados.
- [x] T02-06: Verificar que no haya 2 cubiertas en memoria simultaneamente (K-03) — `crucero_manager.gd` `cargar_cubierta()` descarga la anterior (`descargar_cubierta()` + `queue_free`) antes de cargar la nueva.

## B - Codigo M169 (4)

- [x] T02-07: P-01: tests/unit/test_crucero_manager.gd (4 estados) — 13 OK / 0 FAIL.
- [x] T02-08: P-02: tests/integration/test_crucero_viaje.gd (embarque → zarpe → llegada) — 19 OK / 0 FAIL.
- [x] T02-09: Q-13: Conectar 5 actividades al EventManager de M74 — fix node path `/root/EventManager` → `/root/eventos` en `crucero_eventos.gd` (antes no-op); `finalizar_evento` hace no-op seguro para ids no-festival.
- [x] T02-10: L-04: Dialogo ambiental simple al interactuar (1 linea por NPC) — `data/crucero/ambiental.json` (6 NPCs) + `scripts/crucero/crucero_ambiental.gd` + `tests/unit/test_crucero_ambiental.gd` (5 OK / 0 FAIL).

## C - Doc M169 (2)

- [x] T02-11: Actualizar 03-Diseno de M169 con los drifts fixeados + 18 iconos logros — `03-Diseno.md` §11 (10 drifts verificables reconciliados; no existe registro "b57/56" en el repo) + `04-Codigo.md` §9 (18 iconos rotos).
- [x] T02-12: Verificar que 04-Codigo de M169 mencione CruceroManager + autoload + tests — `04-Codigo.md` §1.1 (autoload), §1.5 (tests), §8.5 (verificación), §9 (iconos).

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Verif) | 6 (4 cerradas, 2 con duda) |
| B (Code) | 4 |
| C (Doc) | 2 |
| **Total** | **12 (10 cerradas, 2 [?])** |

**Cerrado:** 2026-11-25 por ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code.
T02-03 y T02-04 quedan `[?]` honestos: requieren Blender/visión (B-02/B-03 en STANDBY).

**Nota:** B-02/B-03 siguen en STANDBY (Blender + fundador). Estas 12 son complemento.