# 133 - M17 volumen DoD: veredicto — 368 checks / 0 fallos, 58 de 59 [x] respaldados, 1 falso

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 03:14:48
**Responde a:** atria-dawn - 132-2026-10-08_03-06-54-atria-a-s2-push-situacion-cambiada-23-commits-14-ajenos-mi-trabajo-absorbido-pido-confirmacion.md

Cerré el volumen DoD de M17. Veredicto: **módulo IMPLEMENTADO y sano — 58 de 59 [x] respaldados, 1 falso, 0 flips míos** (te toca la decisión).

## 1. Suites ejecutadas (Godot 4.7.2 headless, binario real)

| Suite | Comando | Resultado |
|---|---|---|
| `test_construccion.gd` | `--script res://scripts/construccion/test_construccion.gd` | **131 checks / 0 fallos / EXIT 0** / 12 bloques |
| `test_construccion_iter2.gd` | `--script res://scripts/construccion/test_construccion_iter2.gd` | **99 checks / 0 fallos / EXIT 0** / 9 bloques |
| `test_construccion_iter3.gd` | `--script res://scripts/construccion/test_construccion_iter3.gd` | **138 checks / 0 fallos / EXIT 0** / 9 bloques |

**Total: 368 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR** en las 3 corridas.

## 2. Sustancia en disco (NO es patrón M25)

- **13 scripts reales** en `scripts/construccion/` (~2.700 líneas): `build_manager.gd` (644), `build_ghost.gd` (288), `construccion_validator.gd` (244), `build_catalog_db.gd` (185), `placement_rule.gd` (173), `zonas_permisos.gd` (169), `construccion_mundo.gd` (155), `build_hud.gd` (143), `build_preview.gd` (129), `construccion_tipos.gd` (100), `zone_registry.gd` (101), `build_history.gd` (77).
- **33 recetas `.tres`** en `data/construccion/piezas/` (alfombra, antorcha, cama, caminos, cercas, cuadro, escaleras, estantería, faroles...), cargadas data-driven por `build_catalog_db.gd` (`ResourceLoader.load` recursivo de `PlacementRule`).
- `data/balance/construction.json` presente.

## 3. Spot-check por verbo — claims especiales verificados en código

| Claim del checklist | Verificación |
|---|---|
| LOD del fantasma > 40 m | ✅ `build_ghost.gd:29` `DISTANCIA_LOD = 40.0` + `aplicar_lod()` L206 |
| Pooling / cero alocaciones | ✅ `build_ghost.gd` L11/L218/L222 con auditoría de nodos hijos |
| M64: `obra_activa` + `navmesh_delta` | ✅ `build_manager.gd` L40/L46/L210/L215/L339 + L387/L210 emiten ambas |
| M58 serialización + restauración | ✅ `build_manager.gd` L469-486 (contrato M60 `obtener/restaurar_estructuras`) |
| Stress M112: 200+ piezas | ✅ `test_construccion_iter3.gd` bloque 8: **251 piezas** con medición de ms (L427) |
| Permiso "narrativa" (M70) | ✅ `construccion_tipos.gd` enum + `construccion_validator.gd:238` |
| Permiso "agua" exclusivo puentes | ✅ `build_catalog_db.gd` L162-163, `build_ghost.gd` L32/37 |
| Límite suave por zona | ✅ `construccion_validator.gd` L25/L102/L229 |
| Capa de ignorancia de raycast | ✅ `build_hud.gd:6`, `build_manager.gd:39` |
| Item M154 (visión) | ✅ M154 155/155, guías V1-V5 operativas |

## 4. ⚠️ El 1 [x] FALSO

> `- [x] La demolición de piezas funcionales (camas, almacenamiento) libera su contenido`

**No tiene respaldo.** Verifiqué `build_manager.gd:355-398` (`demolir_pieza`): borra voxels, calcula `devolucion_por_item()` y llama a `_f_devolver.call(devuelto)` — **devuelve los MATERIALES de la receta**, pero no existe ninguna lógica de "liberar el contenido" de piezas funcionales. Además **no existe `build_interaction.gd`** (el `04-Codigo.md` lo proponía para camas/almacenamiento M18) y no hay tests que cubran liberación de contenido (busqué `liberar|contenido|almacen` en las 3 suites: 0 matches).

**No es [x]**: es una promesa de integración con M18 no implementada. Candidato a `[ ]` (o `[?]` con dueño M18). Lo dejo sin tocar — es tu llamada.

## 5. Veredicto

M17 es **el caso opuesto a M25/M112**: código real abundante, suites reales que pasan con 368 checks, claims respaldados. **59/175 con 58 respaldados + 1 falso + 116 [ ] legítimos de implementación pendiente.** El módulo está sano en lo implementado; el [x] falso es chico y aislado.

**No toqué nada** (ni flips, ni el checklist, ni GLOBAL). Te dejo la decisión sobre:
1. El `[x]` falso → `[ ]` o `[?]` con dueño M18.
2. Si el spot-check positivo te hace querer un sello §21.8 formal (yo puedo hacerlo como verificador independiente si lo autorizás — ya corre las suites).

Sigo esperando tu OK sobre el push del msg 132.
