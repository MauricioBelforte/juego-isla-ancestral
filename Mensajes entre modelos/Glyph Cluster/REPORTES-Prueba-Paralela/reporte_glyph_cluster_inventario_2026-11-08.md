# Reporte de análisis — Sistema de inventario (`game/isla-ancestral/scripts/`)

**Modelo:** Glyph Cluster  
**Plataforma:** Vercel AI Gateway (Kilo Code)  
**Fecha:** 2026-11-08  
**Alcance revisado:** scripts de inventario/items/slots y UI relacionada en `game/isla-ancestral/scripts/` + tests unitarios relevantes.

## Archivos analizados (principales)

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/inventario/inventory_slot.gd` | Modelo de slot: `item_id`, cantidad, flags, instancia, serialización. |
| `game/isla-ancestral/scripts/inventario/container_type.gd` | Tipos/tamaños de contenedor y cadena de fallback. |
| `game/isla-ancestral/scripts/inventario/inventario_contenedor.gd` | Contenedor genérico: add/remove en pasadas, conteo, serialización/restauración, validación de cantidades. |
| `game/isla-ancestral/scripts/inventario/inventario_service.gd` | Autoload/servicio central: contenedores, señales, adaptadores M39, crafting, split/swap/move/sort, save/restore, helpers. |
| `game/isla-ancestral/scripts/inventario/inventario_iter4.gd` | Helpers de autosave/fallback/sugerencias; capa auxiliar (autoload). |
| `game/isla-ancestral/scripts/inventario/inventario_iter5.gd` | Cofres/accesibilidad/tutoriales persistidos (autoload). |
| `game/isla-ancestral/scripts/data/item_data.gd` | Definición `ItemData` (`apilable`, `stack_max`, categoría, rareza, etc.). |
| `game/isla-ancestral/scripts/data/item_database.gd` | Autoload catálogo: carga `.tres`, índices y consultas. |
| `game/isla-ancestral/scripts/utils/components/inventory_component.gd` | Componente ligero genérico para entidades (diccionario `item_id -> cantidad`). |
| `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd` | UI M53: pestañas, búsqueda, sort, swap por dos clicks, favorito, descarte. |
| `game/isla-ancestral/tests/unit/inventario/test_inventory_slot.gd` | Tests de `InventorySlot` (ocupación, vaciado, apilado básico, serialización). |

> Nota: existen otros scripts relacionados (`hotbar_state.gd`, `inventario_helper.gd`, iter3, tests de integración/stress) no leídos en detalle en esta pasada; los hallazgos se basan en el núcleo efectivo del inventario.

## 1) ¿Cómo se gestionan los items y slots?

**Modelo de slot (`inventory_slot.gd:10-57`):**
- Cada slot es un `RefCounted` con `item_id` (`:12`), `cantidad` (`:13`), flags `favorito/bloqueado` (`:14-15`) e `instancia: Dictionary` (`:18`) para estado propio de items no apilables (ej. durabilidad de herramienta).
- `esta_libre()` considera vacío si `item_id == ""` o `cantidad <= 0` (`:20-21`).
- `puede_apilar(cantidad_extra, stack_max)` solo valida que el slot no esté vacío y que la suma no exceda el tope (`:23-24`); **no compara identidad de item** (la identidad la garantiza el contenedor).
- Serializa solo slots ocupados y omite flags false/instancia vacía (`:36-46`); deserializa con defaults defensivos (`:48-57`).

**Contenedor (`inventario_contenedor.gd:11-163`):**
- `ContenedorInventario` mantiene `Array[InventorySlot]` de tamaño fijo según `ContainerType` (`:17-24`).
- `add_item` usa **dos pasadas** (`:47-79`): (1) completa stacks parciales del mismo item si `stack_max > 1` e `instancia` vacía, saltando favoritos (`:54-65`); (2) ocupa slots vacíos no bloqueados (`:68-77`). Devuelve **sobrante** (nunca descarta items en silencio).
- `remove_item` valida disponibilidad total antes (`:82-84`) y remueve desde el final para conservar primeros slots (`:86-96`).
- `serializar()` guarda solo ocupados con índice `slot` (`:113-120`); `deserializar()` limpia y repuebla, validando existencia en `ItemDatabase`, cantidad `> 0` y acotando a `stack_max` (BUG-108, `:122-145`).
- `_stack_max_de()` consulta `ItemDatabase` y usa `stack_max` si el item es apilable, si no fuerza `1`; fallback `99` si no hay DB (`:37-43`).

**Servicio central (`inventario_service.gd:1-444`):**
- `InventarioService` (autoload, sin `class_name`) es la **única autoridad** (`:6-8`). Crea contenedores bolsillo/mochila/casa/cofre/almacén/correo y conecta `slot_changed` (`:27-34`).
- API principal: `add_item/remove_item/count_item/has_free_space/used_slots/total_slots` (`:45-88`) con fallback bolsillo→casa al agregar (`:47-57` solo en llamada directa por contenedor; el fallback en cadena completa se ve en `agregar_items/give_gift`).
- Operaciones: `move_item` (slot completo con auto-apilado), `swap_items` (swap profundo campo a campo, permite cruces entre contenedores), `split_stack`, `sort_container` por 4 modos (`:90-219`).
- Adaptadores M39: `agregar_items` (fallback bolsillo→casa y reversión parcial si sobra, `:225-237`) y `remover_items` todo-o-nada sobre bolsillo/mochila/casa (`:239-254`).
- Integraciones: `consume_for_crafting` (`:260-280`), `give_gift` con fallback a correo (`:285-292`), herramientas/durabilidad (`:297-337`), descarte protegido con doble confirmación y bloqueo de `mission_` (`:343-362`), donación, misión, validación global.
- Persistencia M59: `get_section_name/get_save_data/restore_save_data` (`:391-430`), con protección ante claves de sección inválidas (`_seccion_a_contenedor`, BUG-108, `:404-414`).

**UI (`ui/layers/inventory_layer.gd:13-463`):**
- La capa M53 lee/escribe a través de `/root/Inventario` (M14) y escucha señales de cambio (`:49-56`). Renderiza slots del bolsillo, filtros (categoría/búsqueda) y sort delegando al servicio (`:283-288`).
- Interacción por dos clicks: seleccionar origen, segundo click intercambia (`swap_slots` o fallback manual) o togglea favorito; click en vacío con origen mueve a vacío vía fallback local (`:293-349`).
- Descarte usa `UIManager.open_confirm` y luego llama `remove_item(0, indice)` (`:376-402`) — **ver observación de stacking/split abajo**.

## 2) ¿Hay validación de capacidad máxima?

**Sí, en varios niveles, pero con matices:**

- **Capacidad por contenedor (número de slots):** tamaños definidos en `container_type.gd:21-28` (Bolsillo 24, Mochila 16, Casa 60, Cofre 16, Almacén 240, Correo 24). El contenedor se inicializa con `n` slots fijos (`inventario_contenedor.gd:20-24`); `add_item` no crea slots nuevos y devuelve sobrante si no hay hueco (`:68-79`).
- **Tope por stack (`stack_max`):** `inventario_contenedor.gd:37-43` obtiene el límite desde `ItemDatabase/ItemData`; items no apilables fuerzan `stack_max=1`. `add_item` respeta `mini(stack_max, restante)` al ocupar nuevos slots (`:74`) y el espacio libre al apilar (`:60-64`).
- **Validación al restaurar save:** `deserializar()` ignora items desconocidos (`:129-134`), cantidades inválidas (`:135-137`) y **acota cantidades > `stack_max`** al tope (BUG-108, `:138-144`). `validate_quantities()` corrige negativos/overflow en memoria (`:147-163`); `InventarioService.validate_all_containers()` la expone globalmente (`:381-387`).
- **Validación de claves de sección en restore:** `_seccion_a_contenedor` rechaza claves no enteras para evitar clobber del bolsillo (`inventario_service.gd:404-428`).
- **Límites no cubiertos explícitamente:** no hay verificación de `cantidad` extremadamente grande en `add_item`/`agregar_items` más allá del stack/slots (el sobrante se calcula correctamente, pero no se valida overflow de `int` ni se normaliza entrada negativa más allá de `cantidad <= 0` en contenedor). `InventoryComponent` (ligero, `utils/components/inventory_component.gd:12-23`) **no tiene capacidad máxima ni `stack_max`** — es intencional como building-block, pero no debe confundirse con el sistema M14.

## 3) ¿Hay problemas de stacking o split de items?

### Comportamientos correctos observados
- **Stacking en dos pasadas** con protección de favoritos y separación de items con `instancia` no vacía (`inventario_contenedor.gd:54-77`). Esto evita fusionar herramientas con estado propio.
- **Items no apilables** quedan con stack efectivo 1 porque `_stack_max_de` devuelve `1` si `apilable` es false (`:37-43`, `item_data.gd:72-73,88-90`).
- **`split_stack`** existe en el servicio (`inventario_service.gd:145-162`): separa `amount` a otro contenedor, impide separar todo el stack (`amount <= s.cantidad - 1`) y actualiza cantidad origen solo si el destino aceptó sin sobrante.

### Problemas / riesgos detectados

1. **`split_stack` no valida `stack_max` del item destino ni la semántica de no apilables/instancia (riesgo de stack inválido o pérdida parcial).**  
   - `inventario_service.gd:153` permite `amount` desde `1` hasta `s.cantidad - 1` sin consultar `ItemDatabase.stack_max`. Para un item con `stack_max` menor (o reglas especiales), el servicio puede intentar crear/llenar stacks que el contenedor luego limita internamente; pero el contrato de split no comunica el tope al llamador.  
   - `:156` pasa `s.instancia` al destino solo si `s.cantidad - amount <= 1` (`s.instancia if s.cantidad - amount <= 1 else {}`), lo cual es una heurística frágil: puede duplicar estado de instancia en escenarios no previstos o perderlo cuando no corresponde. Además, para items con instancia (herramientas), separar cantidad de un stack de “herramientas apiladas” conceptualmente es ambiguo; el sistema mezcla cantidad e instancia en el mismo slot (`inventory_slot.gd:16-18`).  
   - **Impacto:** posible inconsistencia lógica al separar stacks de items con instancia o con límites de stack no contemplados; UX confusa si el split “acepta” pero el destino no recibe lo esperado en casos borde.

2. **UI de descarte usa una firma incompatible con el servicio (stacking/cantidad afectada incorrectamente).**  
   - `inventory_layer.gd:397-402` ejecuta `inv.remove_item(0, indice)` al confirmar descarte. Sin embargo, `InventarioService.remove_item` espera `(item_id: String, amount: int, container: int = -1)` (`inventario_service.gd:60-67`), y la eliminación real la hace `ContenedorInventario.remove_item(item_id, cantidad)` (`inventario_contenedor.gd:82-97`) por **item_id y cantidad total**, no por índice de slot.  
   - Pasar `indice` como `amount` (y usar el contenedor por defecto) provoca comportamiento erróneo: puede intentar remover `indice` unidades de un item incorrecto/no existente o no remover el slot seleccionado. Además el servicio tiene `discard_item(container, slot_idx, confirmado)` (`inventario_service.gd:343-362`) que sí respeta índice, doble confirmación lógica y protección de ítems de misión (`mission_`).  
   - **Impacto:** bug funcional en descarte desde UI M53 (puede no borrar lo seleccionado, borrar cantidad equivocada o fallar silenciosamente). También se omite la protección de misión y la señal de pickup prevista en `discard_item`.

3. **`swap_items` permite intercambiar slots entre contenedores sin validar reglas de contenedor/bloqueo.**  
   - `inventario_service.gd:111-141` copia campos crudos entre slots cualesquiera (incluyendo `bloqueado/favorito/instancia`) sin comprobar si el destino acepta el tipo, si hay restricciones de contenedor o si el slot destino está bloqueado. `add_item` sí evita ocupar slots bloqueados (`inventario_contenedor.gd:73`), pero el swap directo los sobreescribe.  
   - **Impacto:** puede mover/poner items en slots bloqueados o romper invariantes esperadas por UI/reglas de contenedor.

4. **Doble fuente de verdad / componentes paralelos.**  
   - Existe `InventoryComponent` ligero (`utils/components/inventory_component.gd`) con `Dictionary` simple sin slots, sin `stack_max`, sin capacidad ni validación; y además múltiples iteraciones/autoloads (`inventario_iter4`, `inventario_iter5`, helper/hotbar).  
   - **Impacto:** riesgo de divergencia si entidades usan el componente ligero esperando reglas de M14, o si la UI/lógica consulta sistemas distintos.

## 4) Dos mejoras sugeridas

### Mejora 1 — Corregir el descarte de UI para usar `discard_item` por slot y unificar reglas
- **Cambio:** en `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:397-402`, reemplazar `inv.remove_item(0, indice)` por `inv.discard_item(0, indice, true)` (contenedor bolsillo, índice real, confirmación ya realizada por `ConfirmPopup`). Manejar el `bool` de retorno para refrescar/mostrar error si el ítem es de misión o el índice es inválido.
- **Beneficio:** elimina el bug de firma/índice, respeta protección `mission_` (`inventario_service.gd:352-354`), emite señales coherentes (`item_removed`/pickup, `:360-361`) y centraliza la política de descarte en el servicio.
- **Validación sugerida:** test de integración UI/servicio: seleccionar slot con 5 unidades y descartar → solo ese slot se vacía; ítem `mission_*` → descarte rechazado.

### Mejora 2 — Endurecer `split_stack` y `swap_items` con invariantes de stack/instancia/bloqueo
- **Cambio:** en `game/isla-ancestral/scripts/inventario/inventario_service.gd`:
  - `split_stack` (`:145-162`): consultar `ItemDatabase`/`_contenedor(...)._stack_max_de` para acotar `amount` al `stack_max` aceptable; rechazar split si el slot origen tiene `instancia` no vacía (o definir política explícita: separar solo items apilables sin instancia); calcular aceptación real y ajustar origen por lo efectivamente movido, no asumir `sobrante == 0` como único caso válido si se permite split parcial controlado.
  - `swap_items` (`:111-141`): rechazar si `a.bloqueado` o `b.bloqueado` (salvo regla explícita de admin/UI), o al menos impedir colocar en destino bloqueado; opcionalmente validar compatibilidad de contenedor si existen restricciones futuras.
- **Beneficio:** evita corrupción lógica de stacks/herramientas con durabilidad, respeta bloqueos ya modelados en el slot/contenedor y hace el comportamiento predecible para UI y save/load.
- **Validación sugerida:** ampliar `tests/unit/inventario/test_inventory_slot.gd` o agregar tests de contenedor/servicio para: split de item apilable respeta `stack_max`; split rechazado con `instancia`; swap no sobreescribe slot bloqueado.

## Conclusión final

El núcleo de inventario M14 (`InventorySlot` + `ContenedorInventario` + `InventarioService`) tiene una base sólida: modelo de slot claro, **dos pasadas de apilado** con sobrante explícito, tamaños de contenedor definidos, validaciones importantes en deserialización (item desconocido, cantidad inválida, acotado a `stack_max`, claves de sección seguras) y una API de servicio que centraliza señales e integraciones.

Sin embargo, hay **riesgos concretos**: (1) el descarte de la UI M53 llama a `remove_item` con una firma/semántica incompatible con el servicio, lo que puede romper el borrado por slot y omitir reglas de misión/pickup; (2) `split_stack` no endurece invariantes de `stack_max`/instancia y usa una heurística frágil para copiar estado; (3) `swap_items` puede sobreescribir slots bloqueados; (4) coexisten componentes ligeros/autoloads iterativos que requieren disciplina para no duplicar autoridad. Priorizar la corrección del descarte UI y el endurecimiento de split/swap mejorará consistencia, seguridad de datos y mantenibilidad del inventario.
