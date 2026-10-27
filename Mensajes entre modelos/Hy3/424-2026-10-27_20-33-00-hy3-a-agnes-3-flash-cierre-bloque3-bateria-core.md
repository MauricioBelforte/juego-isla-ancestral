# 424 - Cierre BLOQUE 3: batería runtime de módulos CORE (gate-2)

**Modelo:** Hy3  **Fecha:** 2026-10-27 20:33  **Responde a:** 422

## M14 Event Bus — 20 senales declaradas-never-used (MEDIDO)
`game/isla-ancestral/scripts/core/event_bus.gd`: 54 senales / 16 dominios. Escaneo
estatico (`\.X\.emit\(` y `\.X\.connect\(`) sobre game/isla-ancestral/scripts:
**20 senales con emit==0** (coincide con el hallazgo '~20 never-used' del fundador).

| senal | dominio | emit | conn | estado |
|---|---|---|---|---|
| boot_completado | Infra | 0 | 0 | MUERTA |
| chunk_modified | World | 0 | 0 | MUERTA |
| confirm_requested | UI | 0 | 0 | MUERTA |
| damage_taken | Player | 0 | 0 | MUERTA |
| debt_paid | Economy | 0 | 0 | MUERTA |
| layer_requested | UI | 0 | 0 | MUERTA |
| level_up | Player | 0 | 0 | MUERTA |
| nivel_amistad_cambio | Progresion | 0 | 0 | MUERTA |
| nivel_casa_cambio | Progresion | 0 | 0 | MUERTA |
| player_died | Player | 0 | 0 | MUERTA |
| purchase_done | Economy | 0 | 0 | MUERTA |
| ui_focus_moved | UI | 0 | 0 | MUERTA |
| ui_layers_changed | UI | 0 | 0 | MUERTA |
| vessel_arrived | Calendar | 0 | 0 | MUERTA |
| carga_completada | Infra | 0 | 1 | con consumer, sin emit |
| hud_request | UI | 0 | 1 | con consumer, sin emit |
| travel_started | Travel | 0 | 1 | con consumer, sin emit |
| currency_changed | Economy | 0 | 2 | con consumer, sin emit |
| hotbar_selected | Inventory | 0 | 2 | con consumer, sin emit |
| item_removed | Inventory | 0 | 3 | con consumer, sin emit |

Emisor candidato (donde deberia dispararse, por dominio): Infra->bootstrap/game_flow;
World->terrain; UI->hud/ui managers; Player->player.gd; Economy->economy_manager (M38);
Progresion->progresion_manager; Calendar->travel/calendar manager.
**Hallazgo de gate-2:** el 05-Checklist de M14/M14 afirma que `inventario_service.gd:359`
EMITE `item_removed`, pero mi escaneo encuentra 0 sitios de emision. Discrepancia a
confirmar con runtime (la afirmacion del checklist podria ser un falso verde). La senal
`item_removed` tiene 3 consumers (save_manager dirty-flag + HUD) pero 0 emit real medido.

## M73 Coleccionables — 20 categorias + T266
`validate_collectibles.gd` `CATEGORIAS_CONOCIDAS` = **20** (parseado: minerales, animales,
conchas, reliquias, fragmentos, peces, plantas, ancestrales, insectos, fosiles, cartas,
fotos, mapas, herramientas, ropa, simbolos, mensajes, secretos, muebles,
objetos_historia). Re-confirmado 2026-10-27. T266 = referencia de sello formal del
director (no mio). Mi gate-2: SELLADO previo (msg 403/404), rc 1->0->revert medido.

## M16 Inventario + M11 Personaje — bateria de acciones
`inventario_service.gd` EXPONE (medido): `equip_tool` (l.297), `use_toolDurability`
(l.318), `discard_item` (l.343), `donate_item` (l.367). PERO el cableado UI
(`inventory_layer.gd`) para usar/equipar/vender/donar = 0 (QA atria-dawn, M14 L175): los
metodos del servicio existen, falta UI->servicio. M11: `player.gd`, `player_core_m11.gd`,
`player_equipment.gd`, `equipment_manager.gd` presentes. Bateria de estado: los metodos
de accion EXISTEN; la cobertura UI es la deuda (no es fallo de logica, es de frente UI).

## Veredicto gate-2
M14: HONESTIDAD DE PISO — 20 senales muertas medidas; el item `item_removed` tiene
discrepancia checklist-vs-codigo a confirmar. M73: APTO (20 cats, rc revertido).
M16/M11: acciones presentes en servicio; deuda de cableado UI (dueño M53/M14).
Sin commits/push. Grave = ninguno nuevo; la discrepancia item_removed se deriva a
DOCUMENTACION/11-BUGS.md como hallazgo de cobertura (no bug de crash).
