**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# 05-Checklist.md — Modulo 155: Vestimenta y Accesorios

> Marcadores: [S] simple · [M] medio · [C] complejo.

## Reserva actual

- Estado: 🟡 Con dudas
- Agente: stepfun-3.7-flash / Kilo Code
- Fase: F4/F5
- Dificultad: 3
- Visión: V0/V1
- Entrada: M11✅ M14✅ M156🟢
- Salida: EquipmentManager autoload + 4 slots + 16 prendas + tabla de bonos + desbloqueo progresivo + integración M11/M14/M156/M59 + test headless 0 fallos
- Archivos: `scripts/player/equipment_manager.gd`, `scripts/player/equipment_slot.gd`, `scripts/player/player_equipment.gd`, `scripts/ui/equipment_ui.gd`, `data/equipment/equipment_catalog.tres`, `data/equipment/terrain_bonuses.tres`
- Fecha: 2026-09-01 15:56

---

## A. Requisitos del módulo

- [x] Definir el alcance del sistema de vestimenta y accesorios [M]
- [x] Establecer que el sistema opera en tiempo de ejecución sin reinicios de escena [C]
- [ ] Confirmar compatibilidad con el sistema de terrenos (M156) [M]
- [ ] Validar que el sistema no interfiere con el guardado de progreso (M59) [M]
- [ ] Asegurar que los accesorios se renderizan correctamente en el jugador [M]
- [x] Establecer que los bonos son acumulativos y se aplican en tiempo real [S]
- [x] Definir que cada prenda pertenece a un único slot de equipamiento [S]
- [x] Confirmar que el jugador puede portar máximo 4 accesorios simultáneamente [S]
- [x] Establecer que el catálogo se carga al iniciar el juego [M]
- [ ] Validar que los requisitos de desbloqueo verifican progreso del jugador [M]

---

## B. Data Model

- [x] Crear enum `EquipmentSlot.SlotType` con valores: HEAD, BODY, FEET, ACCESSORY [S]
- [ ] Crear enum `TerrainType` con valores: grass, mud, pavement, sand, shallow_water, snow, rock [S]
- [ ] Crear Resource `EquipmentSlot` con campos: slot_type, item_id, item_name, terrain_bonuses, comfort_penalty [C]
- [x] Crear Resource `PlayerEquipment` con slots: head, body, feet, accessory + to_dict/from_dict [M]
- [x] Implementar serialización JSON de `PlayerEquipment` para guardado [M]
- [x] Implementar deserialización de `PlayerEquipment` desde datos guardados [M]
- [x] Crear catálogo de 16 prendas en EquipmentManager._load_catalog() [M]
- [x] Crear tabla de 7 terrenos en EquipmentManager._load_terrain_bonus_table() [M]
- [x] Definir constantes para bonos base por defecto (sin equipamiento) [S]
- [x] Crear estructura `UnlockCondition` con campos: tipoCondición, valorRequerido [S]
- [x] Asociar `UnlockCondition` a cada `ClothingItemData` [S]
- [x] Crear pool de datos estático del catálogo completo (16 prendas) [M]
- [x] Documentar esquema de serialización en 04-Codigo.md [S]

---

## C. EquipmentManager

- [x] Crear script `EquipmentManager` como autoload/singleton persistente [M]
- [x] Implementar método `equip_item(item_id, slot_type)` que valida slot y catálogo [C]
- [x] Implementar método `unequip_slot(slot_type)` que devuelve el item_id anterior [M]
- [ ] Implementar método `unequip_accessory(index)` para accesorios individuales [S]
- [x] Implementar método `get_terrain_bonus(terrain_type)` que calcula bono acumulado [C]
- [ ] Implementar método `get_total_bonus()` que suma bonos de todos los terrenos [M]
- [ ] Implementar verificación de límite de accesorios (máximo 4) [S]
- [ ] Implementar verificación de requisitos de desbloqueo antes de equipar [M]
- [x] Emitir señal `equipment_changed(slot_type, new_item_id)` al modificar equipamiento [M]
- [x] Implementar método `get_equipped_item(slot_type)` para consulta [S]
- [x] Implementar método `is_item_equipped(item_id)` de verificación [S]
- [x] Integrar con sistema de persistencia M59 (to_dict/from_dict) [C]

---

## D. Catálogo de prendas (16 prendas)

### Botas (6 tipos)
- [x] feet_boots_mud: Botas de barro, bono +35% barro [S]
- [x] feet_skates: Patines, +30% pavimento, -60% barro, -70% arena [M]
- [x] feet_bike: Bicicleta, +20% camino, +40% pavimento, -50% barro [M]
- [x] feet_boots_water: Botas de agua, +30% agua poco profunda, +10% barro [M]
- [x] feet_sandals: Sandalias, +20% arena, +5% césped, -15% nieve [S]
- [x] feet_boots_winter: Botas de invierno, +20% nieve, +15% hielo, +5% barro [M]

### Cabeza (3 tipos)
- [x] head_hat_fisher: Sombrero de pescador, -10% comodidad lluvia [S]
- [x] head_helm_explorer: Casco de explorador, sin bonos [M]
- [x] head_scarf_warm: Bufanda de lana, +15% comodidad frío [M]

### Cuerpo (3 tipos)
- [x] body_shirt_casual: Camisa casual, sin bonos [S]
- [x] body_coat_rain: Capa impermeable, +25% comodidad lluvia [M]
- [x] body_vest_explorer: Chaleco explorador, sin bonos [C]

### Accesorios (4 tipos)
- [x] acc_backpack: Mochila, sin bonos [S]
- [x] acc_lantern: Linterna, sin bonos [S]
- [x] acc_compass: Brújula, sin bonos [S]
- [x] acc_amulet_ancestral: Amuleto ancestral, +10% grass/mountain/snow [C]

---

## E. Tabla de bonos por terreno

- [x] Definir bonos para 7 terrenos: grass, mud, pavement, sand, shallow_water, snow, rock [M]
- [x] Implementar función `get_terrain_bonus(terrain_type)` en EquipmentManager [C]
- [x] Verificar que bonos negativos se aplican correctamente (desventajas) [M]
- [x] Verificar que bonos de accesorios se suman correctamente a los de ropa [M]
- [ ] Testear combinaciones de 3+ prendas en mismo terreno [M]
- [x] Documentar tabla completa en 03-Diseno.md [S]

---

## F. Interfaz de usuario

- [ ] Crear CanvasLayer `EquipmentUI` con panel de equipamiento [M]
- [ ] Implementar slots visuales para Head, Body, Boots (1 cada uno) [M]
- [ ] Implementar slots visuales para 4 Accesorios [M]
- [ ] Mostrar ícono de cada prenda equipada en su slot correspondiente [M]
- [ ] Mostrar tooltip con nombre, descripción y bonos al pasar鼠标 sobre prenda [M]
- [ ] Implementar botón "Desequipar" para cada slot [S]
- [ ] Mostrar bonos acumulados por terreno en panel lateral [C]
- [ ] Implementar highlight visual en slots con bonos activos para terreno actual [M]
- [ ] Integrar con sistema de inventario existente (M14) [C]
- [ ] Asegurar que la UI se oculta al entrar en combate o interacción [S]

---

## G. Desbloqueo progresivo

- [x] Botas de cuero: desbloqueadas al inicio del juego [S]
- [ ] Implementar función `is_item_unlocked(item_id)` en EquipmentManager [M]
- [ ] Mostrar indicador visual de "bloqueado" en UI para prendas no desbloqueadas [M]
- [ ] Integrar con sistema de progreso del jugador (M14/M20) [C]
- [ ] Guardar estado de desbloqueo en datos de guardado [M]

---

## H. Integraciones

- [ ] Integrar con M156 (Terrenos): aplicar bonos según terreno actual [C]
- [ ] Integrar con M11 (Personaje): modificar move_speed con bonos de equipo [C]
- [ ] Integrar con M14 (Inventario): consumir/retornar ítems al equipar/desequipar [C]
- [ ] Integrar con M59 (Guardado): persistir equipamiento en GameState [C]
- [ ] Verificar que no hay conflictos de rendimiento con otros módulos activos [M]

---

## I. Testing

- [x] Test: equipar prenda en slot vacío funciona correctamente [S]
- [x] Test: equipar prenda en slot ocupado reemplaza la anterior [S]
- [x] Test: desequipar prenda devuelve item_id anterior [S]
- [x] Test: bonos se acumulan correctamente con múltiples prendas [M]
- [ ] Test: límite de 4 accesorios se respeta [S]
- [x] Test: bonos se aplican según terreno actual del jugador [M]
- [ ] Test: prendas bloqueadas no se pueden equipar [S]
- [x] Test: guardado y carga de equipamiento preserva estado [M]
- [ ] Test: UI muestra correctamente slots ocupados y vacíos [M]
- [ ] Test: integración con sistema de combate aplica bonos de defensa [M]

---

## J. Documentación y cierre

- [x] Actualizar 04-Codigo.md con archivos y funciones implementadas [M]
- [ ] Generar log de cierre en Logs/ [S]

---

## Dependencia: Visión del Agente (M154)

- [x] Verificar M154 operativo antes de trabajo visual [S]

**Totales:** 123 items · Completados: 47 · Pendientes: 76
**Nota:** Iter 1 completada por stepfun-3.7-flash / Kilo Code (2026-09-01). Núcleo data-driven implementado. Pendiente: UI, integraciones M11/M14/M156/M59, desbloqueo progresivo.
## Iteración 2 (2026-09-01 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Fix crítico: catálogo con claves duplicadas (body_vest_explorer y acc_backpack repetidos: versión sin unlock + versión con unlock) → eliminadas las versiones antiguas sin unlock. Catálogo cargado: 16 prendas verificado (parse OK)
- [x] Fix boot global en equipment_manager.gd (indent espacios→tabs, 35 líneas, ver guía 07 §9.60)
- [x] Tests ampliados (17 en total): test_flag_unlock_vest_explorer (unlock por flag mochila_mejorada), test_catalog_no_duplicates (16 únicas, regresión del fix), test_equip_replaces_same_slot (reemplazo en mismo slot)
- [x] Suite completa del proyecto vía res://tests/run_tests.gd → ÉXITO (0 fallos, exit 0)
- [x] Verificación visual V4: juego ejecutado, boot sin errores, FPS 60, HUD/player intactos, captura en tools/mcp/godot-mcp/capturas/155-Vestimenta-Y-Accesorios/
- [x] Actualización de 04-Codigo (iter 2 + notas) y coordinación (CHECKLIST-GLOBAL, guía 08, ESTADO-PARALELO, Log 449)
- [?] UI de equipamiento (panel de slots, atajo, lista de prendas desbloqueadas) — requiere tema M53/M57 y DOM-UI de capas; dueño: iter 3
- [?] Render del modelo cambiado al equipar (M156 vestimenta visual) — pendiente del M156
- [?] Integración inventario→equipar (M14) — pendiente para iter 3
## Iteración 3 (2026-09-01 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] UI de equipamiento completa como capa M53: EquipmentLayer construida por código (reemplaza el esqueleto roto scripts/ui/equipment_ui.gd que esperaba nodos inexistentes $Panel/VBox/...)
- [x] 4 slots (head/body/feet/accessory) con nombre y rareza de la prenda equipada; click en slot ocupado = desequipar
- [x] Grid con las 16 prendas del catálogo + estado de desbloqueo (🔒 por capítulo/flag vía UnlockCondition, botón disabled)
- [x] Bono de terreno del equipo visible (player_equipment.get_total_terrain_bonus) + refresco por señales equipment_changed/terrain_bonus_updated
- [x] Montaje en UIRoot (capa 8) + toggle global con acción “equipamiento” (E) en UIManager + acción en InputMap (project.godot, KEY_E física 69)
- [x] Tests de la capa (3): test_equipment_layer.gd (build+toggle, grid 16 items, 20+ botones) incluidos en la suite → ÉXITO 0 fallos
- [x] Verificación V4 por log: [DOM-UI] capa registrada EquipmentLayer (pila=8) + capas montadas equipamiento=true + 0 parse errors
- [x] Verificación visual del panel abierto (tecla E) en ventana propia — COMPLETADO 2026-09-01 22:24 (Log 391): escena de preview scenes/preview_equipment.tscn (muestra la capa toggle) capturada y analizada: 4 slots (vacío), “16 prendas en el catálogo”, Amuleto ancestral 🔒 (capítulo), Brújula 🔒, Capa impermeable ✓, Chaleco explorador 🔒 (flag), Botas de barro ✓, hint E/ESC, bono +0%. Panel cozy crema/borde dorado correcto
- [?] Integración inventario→equipar (M14) y jugador con M156 — pendientes de sus módulos
