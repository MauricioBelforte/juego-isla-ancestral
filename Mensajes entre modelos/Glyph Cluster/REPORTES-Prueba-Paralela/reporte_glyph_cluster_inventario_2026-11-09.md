# Reporte: Sistema de Inventario, Ítems y Slots (Glyph Cluster)
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/inventario/*`, `scripts/utils/components/inventory_component.gd`, `scripts/data/item_data.gd`, `scripts/data/item_database.gd`, `tests/unit/inventario/*` (análisis estático; no se ejecutó el juego).

## Archivos analizados (principales)
| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/inventario/inventory_slot.gd` | Modelo de slot (líneas 1-57). |
| `game/isla-ancestral/scripts/inventario/inventario_contenedor.gd` | Contenedor genérico de slots, apilado y persistencia (1-163). |
| `game/isla-ancestral/scripts/inventario/inventario_service.gd` | Autoload/servicio: autoridad única, API rica, adaptadores M39/M59 (1-444). |
| `game/isla-ancestral/scripts/inventario/container_type.gd` | Tipos y tamaños de contenedor (1-43). |
| `game/isla-ancestral/scripts/inventario/inventario_iter4.gd` | Helpers iter. 4: fallback, autosave, validaciones, integración (1-336). |
| `game/isla-ancestral/scripts/inventario/inventario_iter5.gd` | Cofres/mundo, accesibilidad, tutoriales, persistencia (1-344). |
| `game/isla-ancestral/scripts/utils/components/inventory_component.gd` | Componente ligero por entidad (1-26). |
| `game/isla-ancestral/scripts/data/item_data.gd` | Resource `ItemData`: `apilable`, `stack_max`, validación (1-95). |
| `game/isla-ancestral/scripts/data/item_database.gd` | Autoload catálogo: carga `.tres`, `get_item()` (1-140). |
| `game/isla-ancestral/tests/unit/inventario/test_inventory_slot.gd` | Unit tests slot (1-91). |
| `game/isla-ancestral/tests/unit/inventario/test_contenedor_inventario.gd` | Tests headless contenedor (1-341). |

---

## (1) ¿Cómo se gestionan los ítems y los slots?

**Modelo de datos (slot):** `InventorySlot` (`inventory_slot.gd:9-57`) es un `RefCounted` con `item_id`, `cantidad`, flags `favorito`/`bloqueado` e `instancia: Dictionary` para estado propio de ítems no apilables (p. ej. durabilidad, según comentario L16-18). Expone `esta_libre()`, `puede_apilar(cantidad_extra, stack_max)`, `ocupar()`, `vaciar()`, `serializar()/deserializar()`.

**Contenedor:** `ContenedorInventario` (`inventario_contenedor.gd:11-163`) mantiene `Array[InventorySlot]` con tamaño por tipo (`ContainerType.TAMANOS`, `container_type.gd:21-28`: bolsillo 24, mochila 16, casa 60, cofre 16, almacén 240, correo 24). Operaciones clave:
- `add_item()` (L47-79): **dos pasadas** — (1) completa stacks parciales del mismo ítem si `stack_max > 1` e `instancia` vacía, saltando favoritos (L54-65); (2) usa slots vacíos no bloqueados (L68-77). Devuelve **sobrante** (nunca descarta silenciosamente en el contenedor).
- `remove_item()` (L82-97): verifica `count_item()` primero (todo-o-nada lógico), remueve desde el final hacia el inicio.
- `count_item()` (L99-104), `tiene_slot_libre()` (L106-110).
- Serialización de slots ocupados con índice (`serializar` L113-120, `deserializar` L122-145) y validaciones de carga (ítem desconocido, cantidad inválida, acotado a `stack_max` — BUG-108, L138-144).

**Servicio/autoridad:** `InventarioService` (`inventario_service.gd:8-444`, autoload “Inventario”, sin `class_name`) es la única autoridad (L6). Inicializa contenedores bolsillo/mochila/casa/cofre/almacén/correo y reenvía `slot_changed` por contenedor (L27-34). API: `add_item` con fallback implícito limitado al contenedor objetivo + señal `inventario_lleno` (L47-57), `remove_item`, `count_item(include_house)`, movimiento `move_item/swap_items/split_stack/sort_container` (L94-219), adaptadores M39 `agregar_items/remover_items` con fallback bolsillo→casa y reversión parcial (L225-254), `consume_for_crafting`, `give_gift` (bolsillo→casa→correo, L285-292), persistencia M59 `get_save_data/restore_save_data` con validación defensiva de claves/tipos (L391-430, BUG-108 L400-428).

**Resolución de stack máximo:** `_stack_max_de()` consulta `/root/ItemDatabase.get_item()` y usa `item.stack_max` si `apilable`, si no `1`; fallback `99` sin DB (contenedor L37-43, lógica equivalente en otras rutas). `ItemData` define `apilable`, `stack_max` y `se_puede_apilar()` (`item_data.gd:72-90`).

**Componente ligero alternativo:** `InventoryComponent` (`utils/components/inventory_component.gd:1-26`) es un inventario por entidad basado en `Dictionary` (sin slots, sin capacidad, sin stacking por `stack_max` de catálogo) — útil para NPCs/objetos, no sustituye M14.

---

## (2) ¿Hay validación de capacidad máxima?

**Sí, a nivel de contenedor/slots, con matices:**
- **Capacidad por número de slots:** fija al construir el contenedor (`contenedor L20-24`, tamaños en `container_type.gd`). `add_item` solo coloca en slots existentes; si no cabe, devuelve sobrante (L45-79). `tiene_slot_libre()` / `total_slots()` / `slots_usados()` existen.
- **Capacidad por stack:** acotada por `_stack_max_de()` en apilado y en slots nuevos (L50,60,74). Al deserializar se acota `cantidad > stack_max` al tope (BUG-108, contenedor L138-144). `validate_quantities()` corrige negativos y excesos (L147-163); el servicio expone `validate_all_containers()` (servicio L381-387).
- **Persistencia defensiva:** claves de sección inválidas/no enteras no clobberéan bolsillo (BUG-108, servicio L400-428); se ignoran ítems desconocidos/cantidades inválidas al cargar (contenedor L129-137).
- **Límites NO cubiertos globalmente:** no hay tope de “peso”/volumen, no hay límite transaccional centralizado entre todos los contenedores salvo la lógica de fallback explícita; `InventoryComponent` no valida capacidad alguna. `validate_quantities()` **no se invoca automáticamente** en todos los flujos de mutación (solo existe como API; `restore_save_data` ya acota por slot en deserialización, pero mutaciones runtime dependen de los callers).

---

## (3)/(4) Problemas de stacking o split de items

### Hallazgos

1. **`move_item` puede perder ítems al mover parcialmente (bug crítico de integridad).**  
   - Archivo/líneas: `inventario_service.gd:94-108`.  
   - `tc.add_item(...)` devuelve `sobrante`; si el destino acepta **parte** (`sobrante < s.cantidad`) el código **vacía el slot origen completo** (L103-104) sin devolver/reinsertar el sobrante. Resultado: los ítems no aceptados desaparecen.  
   - Impacto: cualquier movimiento entre contenedores cuando el destino tiene espacio parcial (stacks incompletos/slots limitados) puede destruir inventario.

2. **`split_stack` tiene semántica frágil con instancias y stacks (riesgo de corrupción lógica/UX).**  
   - Archivo/líneas: `inventario_service.gd:145-162`.  
   - L153: `clampi(amount, 1, s.cantidad - 1)` impide separar dejando el origen en 0 (razonable), pero también impide casos borde donde el caller espera comportamiento distinto.  
   - L156: pasa `s.instancia` al destino solo cuando `s.cantidad - amount <= 1` (`{}` en caso contrario). Para ítems **no apilables con estado** (instancia significativa) separar cantidades >1 es conceptualmente inválido; para apilables, compartir/copiar instancia es ambiguo. No valida explícitamente `stack_max==1`/no apilable antes de split.  
   - L156-161: asume que `tc.add_item` colocó exactamente `amount` en un destino coherente; si el destino apila en múltiples slots existentes, la operación “split a un stack nuevo” no está garantizada (depende del estado del destino). No hay manejo si `sobrante != 0` salvo devolver `false`, dejando al jugador sin feedback de cantidad parcial posible.

3. **`agregar_items` (M39) puede revertir mal en escenarios con fallback interno previo (riesgo atómico).**  
   - Archivo/líneas: `inventario_service.gd:225-237`.  
   - La reversión ante fallo final quita `devolver` desde **BOLSILLO** (L235). El ítem pudo haberse colocado en CASA por el fallback explícito (L229-230) en iteraciones previas del mismo ítem/lógica; la reversión no contempla CASA. Además, la atomicidad “todo-o-nada” se intenta, pero la estrategia de rollback es incompleta frente a distribución multi-contenedor.

4. **`puede_apilar()` no valida `cantidad_extra <= 0` ni sobre-llenado defensivo; responsabilidad en caller.**  
   - Archivo/líneas: `inventory_slot.gd:23-24`.  
   - No es bug por sí solo dado el uso actual, pero una API más defensiva evitaría estados inválidos si se reutiliza.

5. **Tests con supuestos acoplados al entorno.**  
   - `test_contenedor_inventario.gd:155-186,281-306` usa ids `"madera"/"piedra"` y otros `"wood"/"stone"`; el propio test documenta (L295-297) que la deserialización depende de `ItemDatabase` vivo. Esto no es bug del runtime, pero puede generar falsos positivos/negativos según autoloads del runner.

---

## (5) Sugerencias de mejora (2)

1. **Corregir `move_item` para preservar el sobrante (integridad de inventario).**  
   En `inventario_service.gd:94-108`, calcular `movido = s.cantidad - sobrante`; si `movido > 0`, decrementar `s.cantidad` en `movido` (y vaciar solo si llega a 0) en vez de vaciar siempre. Emitir `slot_changed` para origen y asegurar señales/actualización coherentes. Añadir test: mover stack a destino con espacio parcial y verificar que origen conserva el resto.

2. **Endurecer `split_stack` y operaciones de instancia/no apilables.**  
   En `inventario_service.gd:145-162`: rechazar split cuando el ítem sea no apilable o tenga `instancia` con estado que no deba duplicarse (consultar `ItemDatabase`/`stack_max==1`); definir política clara (no permitir split de herramientas con durabilidad, o crear instancia nueva explícita). Soportar resultado parcial solo si se diseña: `add_item` al destino y, si hay `sobrante < amount`, restaurar `sobrante` al origen y retornar éxito parcial/fracaso según contrato de UI. Cubrir con tests de split apilable, no apilable y destino casi lleno.

---

## Conclusión final
El sistema de inventario tiene una base sólida: separación slot/contenedor/servicio, apilado en dos pasadas, fallback anti-pérdida en varias rutas, y defensas relevantes en persistencia/carga (BUG-108, validación de ítems/cantidades). La **validación de capacidad** existe por slots y por `stack_max`, con utilidades de validación, aunque no toda corrección se aplica automáticamente en runtime.

Sin embargo, hay un **riesgo crítico**: `move_item` puede **eliminar ítems** cuando el destino acepta solo parte del stack (`inventario_service.gd:103-104`). También `split_stack` necesita reglas más estrictas para ítems con instancia/no apilables y mejor manejo de parciales. Se recomienda priorizar la corrección de `move_item` y agregar tests de regresión antes de exponer movimientos parciales en UI/juego.