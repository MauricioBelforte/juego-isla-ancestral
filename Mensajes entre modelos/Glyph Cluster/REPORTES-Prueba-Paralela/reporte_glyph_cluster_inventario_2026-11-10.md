# Reporte de análisis — Sistema de inventario (Godot / Isla Ancestral)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10  
**Alcance solicitado:** `game/isla-ancestral/scripts/inventario/`, `game/isla-ancestral/scripts/data/item_data.gd`, `game/isla-ancestral/scripts/data/item_database.gd`, `game/isla-ancestral/data/items/` y tests relacionados.

---

## 1. Archivos analizados

| Archivo | Líneas | Rol principal |
|---|---:|---|
| `game/isla-ancestral/scripts/inventario/container_type.gd` | 43 | Enum de tipos de contenedor y tamaños por defecto (`TAMANOS`: bolsillo 24, mochila 16, casa 60, cofre 16, almacén 240, correo 24). Cadena de fallback lógica (`BOLSILLO -> CASA`). |
| `game/isla-ancestral/scripts/inventario/inventory_slot.gd` | 57 | Modelo de slot: `item_id`, `cantidad`, `favorito`, `bloqueado`, `instancia` (estado de ítems no apilables). Serialización/deserialización del slot. |
| `game/isla-ancestral/scripts/inventario/inventario_contenedor.gd` | 163 | Contenedor genérico de slots. Alta en dos pasadas, baja, conteo, búsqueda de espacio libre, serialización/deserialización con validaciones y clamp de stack, `validate_quantities()`. |
| `game/isla-ancestral/scripts/inventario/inventario_service.gd` | 444 | Servicio/autoload (`Inventario`) autoridad única de ítems. Crea 6 contenedores, expone API rica, señales, operaciones de movimiento/split/sort, adaptadores para shop/crafting/regalos/herramientas/descarte/donación, persistencia M59 y validación robusta de restore. |
| `game/isla-ancestral/scripts/inventario/hotbar_state.gd` | 117 | Estado de hotbar (6 slots, slot activo, contador de esporas) y persistencia M59. |
| `game/isla-ancestral/scripts/inventario/inventario_iter4.gd` | 336 | Helpers de iteración 4: sugerencias de inventario lleno, faltantes de receta, fallback de recolección, autosave diferido, validaciones de catálogo/invariantes, wrappers M39/M59/M87. |
| `game/isla-ancestral/scripts/inventario/inventario_iter5.gd` | 344 | Wrappers de iteración 5 (cofres/mundo en memoria, accesibilidad/tutoriales/atajos) con persistencia propia; sin modificar el núcleo. |
| `game/isla-ancestral/scripts/data/item_data.gd` | 95 | `Resource` de definición de ítem: categorías, rareza, interacciones, `apilable`, `stack_max`, precios, flags; helpers `se_puede_apilar()` y `es_valido()`. |
| `game/isla-ancestral/scripts/data/item_database.gd` | 140 | Autoload catálogo: carga `.tres` de `res://data/items/`, indexa por id/categoría/rareza/fuente/interactivo/colocable y expone queries. |
| `game/isla-ancestral/scripts/inventario/test_inventario.gd` | 262 | Tests de hotbar, helpers iter4 e invariantes básicos del servicio (68 checks mínimos declarados). |
| `game/isla-ancestral/scripts/inventario/test_inventario_iter5.gd` | 120 (parcial inspeccionado) | Tests de cofres/accesibilidad/persistencia iter5 (70 checks mínimos declarados). |
| `game/isla-ancestral/scripts/inventario/test_inventario_restore_robusto.gd` | 106 | Tests de robustez de `restore_save_data` (BUG-108): claves inválidas/fuera de rango y clamp de stack al cargar. |
| `game/isla-ancestral/data/items/*.tres` | (catálogo) | Definiciones concretas de ítems (ej. `crystal.tres`, `ancient_crystal.tres`, etc.) consumidas por `ItemDatabase`. |

> **Nota de alcance:** la búsqueda en `game/isla-ancestral/scripts/` no mostró otros `.gd` fuera de `scripts/inventario/`, `scripts/data/` y tests del propio módulo cuyo nombre coincidiera con inventario/items/slots. Se incluyeron también los archivos de datos y tests directamente relacionados.

---

## 2. (1) ¿Cómo se gestionan los items y slots?

### 2.1 Modelo de slot (`inventory_slot.gd`)
- Cada slot es un `RefCounted` con estado mínimo: `item_id`, `cantidad`, `favorito`, `bloqueado` e `instancia` (`inventory_slot.gd:12-18`).
- Semántica de vacío: `esta_libre()` devuelve `true` si no hay id o la cantidad es `<= 0` (`inventory_slot.gd:20-21`).
- Operaciones básicas: `puede_apilar()`, `ocupar()`, `vaciar()` y `serializar()/deserializar()`; la serialización omite slots libres y solo guarda flags/metadatos presentes (`inventory_slot.gd:23-57`).
- `instancia` permite portar estado propio de ítems no apilables (ej. durabilidad de herramientas), duplicándose en profundidad al ocupar/deserializar (`inventory_slot.gd:27-29,55-56`).

### 2.2 Contenedor genérico (`inventario_contenedor.gd`)
- Inicializa un array de `InventorySlot` según tipo/tamaño (`inventario_contenedor.gd:20-24`). Tamaños provienen de `ContainerType.TAMANOS` (`container_type.gd:21-28`).
- **Inserción en dos pasadas** (`add_item`, `inventario_contenedor.gd:47-79`):
  1. Completa stacks parciales del mismo `item_id` si `stack_max > 1` y no hay `instancia`, respetando capacidad restante y omitiendo slots favoritos (`:54-65`).
  2. Usa slots vacíos no bloqueados, creando stacks hasta `stack_max` (`:67-77`).
  - Devuelve **sobrante** no aceptado (nunca “pierde” por retorno) (`:79`).
- **Eliminación** (`remove_item`, `inventario_contenedor.gd:82-97`): valida disponibilidad total con `count_item`, luego descuenta desde el final hacia el inicio para conservar los primeros slots; vacía slots que llegan a 0 y emite `slot_changed`.
- **Consultas/utilidades**: `slots_usados()`, `tiene_slot_libre()`, `count_item()` (`:29-35,99-110`).
- **Resolución de stack máximo**: `_stack_max_de()` consulta `ItemDatabase` por `/root/ItemDatabase`; si el ítem no es apilable fuerza 1, si es apilable usa `item.stack_max` (mín. 1), y si no hay DB/ítem usa fallback `99` (`inventario_contenedor.gd:37-43`).
- **Serialización**: guarda solo slots ocupados con su índice (`inventario_contenedor.gd:112-120`).
- **Deserialización robusta**: limpia todos los slots, ignora ítems desconocidos en catálogo y cantidades inválidas, y acota al `stack_max` (BUG-108) (`inventario_contenedor.gd:122-145`).

### 2.3 Servicio central (`inventario_service.gd`)
- Autoload “autoridad única” (sin `class_name`), crea contenedores para bolsillo, mochila, casa, cofre, almacén y correo y conecta `slot_changed` por contenedor (`inventario_service.gd:27-33`).
- **Señales** para UI/sistemas: `item_added`, `item_removed`, `slot_changed`, `inventario_actualizado` (batched), `inventario_lleno`, `item_usado` (`:15-23`).
- **API de alto nivel**:
  - `add_item()` (default bolsillo) suma aceptado, emite señales y reporta sobrante/inventario lleno (`:47-57`).
  - `remove_item()` todo-o-nada por contenedor (`:60-67`).
  - Conteo/espacio: `count_item()` (bolsillo+mochila, opcional casa), `has_free_space()`, `used_slots()`, `total_slots()` (`:69-83`).
  - Movimiento entre slots/contenedores: `move_item()`, `swap_items()`, `split_stack()`, `sort_container()` con modos por id/nombre/categoría/rareza (`:94-219`).
  - Adaptadores externos (M39/shop): `agregar_items()` y `remover_items()` con intención todo-o-nada (`:225-254`).
  - Crafting: `consume_for_crafting()` verifica primero y luego consume (`:260-280`).
  - Regalos/entregas: `give_gift()` con fallback bolsillo→casa→correo (`:285-292`).
  - Herramientas: `equip_tool()`, `use_toolDurability()` (`:298-337`).
  - Descarte protegido y donación: `discard_item()` (doble confirmación, protege `mission_`), `donate_item()` (`:343-370`).
- **Persistencia M59**: `get_section_name/get_save_data/restore_save_data` serializa todos los contenedores; `restore_save_data` valida claves de sección y tipo de dato, ignorando entradas inválidas (BUG-108), y emite actualización (`:391-430`).

### 2.4 Definición y catálogo de ítems (`item_data.gd`, `item_database.gd`)
- `ItemData` define metadatos relevantes para inventario: `apilable`, `stack_max`, categoría, rareza, precios, flags de interacción/uso, etc. (`item_data.gd:60-86,88-95`).
- `ItemDatabase` autoload carga `.tres` desde `res://data/items/`, registra sin duplicados y expone `get_item()` y consultas por índices; emite `catalogo_cargado` (`item_database.gd:21-31,52-97,101-140`).

### 2.5 Capas auxiliares
- `hotbar_state.gd`: mapea 6 posiciones a índices de bolsillo, selección/ciclo, contador de esporas y persistencia (`hotbar_state.gd:17-104`).
- `inventario_iter4.gd` / `inventario_iter5.gd`: lógica complementaria (sugerencias, fallback de recolección, wrappers de venta/compra/donación/tutorial/cofres en memoria) que delega en el servicio y otros managers por duck-typing (`inventario_iter4.gd`, `inventario_iter5.gd`).

---

## 3. (2) ¿Hay validación de capacidad máxima?

**Sí, en múltiples niveles (slots y stack), aunque con matices:**

- **Capacidad por contenedor (número de slots):** tamaños fijos/configurados por tipo (`container_type.gd:21-28`, aplicados en `inventario_contenedor.gd:20-24`). `tiene_slot_libre()` excluye slots bloqueados (`inventario_contenedor.gd:106-110`).
- **Capacidad por stack:** `_stack_max_de()` impone tope desde `ItemData.stack_max` (mín. 1) o 1 para no apilables; fallback 99 si falta catálogo (`inventario_contenedor.gd:37-43`). `add_item()` nunca supera `stack_max` por slot al insertar (`:54-77`).
- **Validación al cargar/restaurar:** `deserializar()` ignora ítems desconocidos, cantidades `<= 0` y acota cantidades al `stack_max` (`inventario_contenedor.gd:129-145`, cubierto por `test_inventario_restore_robusto.gd:88-102`). `restore_save_data()` rechaza claves no numéricas/fuera de rango y secciones que no sean `Array` (`inventario_service.gd:404-429`, tests `:57-86`).
- **Validación explícita en runtime:** `validate_quantities()` corrige negativos y excesos sobre `stack_max` (`inventario_contenedor.gd:147-162`), expuesto globalmente por `validate_all_containers()` (`inventario_service.gd:381-387`).
- **Reporte de desbordes:** `add_item()` del servicio emite `inventario_lleno` con el sobrante cuando no cabe (`inventario_service.gd:55-57`); helpers construyen sugerencias (`inventario_iter4.gd:54-73,175-179`).

**Matices/limitaciones observadas:**
- No se observa validación de capacidad por peso/volumen; el límite es puramente por slots y `stack_max`.
- `sort_container()` reconstruye slots desde ítems recolectados y los reinserta secuencialmente (`inventario_service.gd:209-217`); en condiciones normales no debería exceder la capacidad, pero no hay guardia explícita ante inconsistencias externas del array.

---

## 4. (3) ¿Hay problemas de stacking o split de items?

### Hallazgos

1. **El ordenamiento no compacta/mergea stacks fragmentados (comportamiento potencialmente no deseado).**  
   - Evidencia: `sort_container()` extrae ítems ocupados tal cual (`id`, `n`, `inst`, flags) y los vuelve a colocar secuencialmente en slots vacíos sin intentar fusionar stacks del mismo `item_id` (`inventario_service.gd:165-218`).  
   - Impacto: si un mismo ítem apilable quedó repartido en varios stacks parciales, el ordenamiento los reordena pero no los consolida, reduciendo eficiencia de espacio y pudiendo confundir al jugador.

2. **`swap_items()` intercambia slots sin lógica de apilado/merge.**  
   - Evidencia: intercambio directo de todos los campos entre `a` y `b` (`inventario_service.gd:111-141`).  
   - Impacto: soltar un stack sobre otro compatible no los fusiona (swap en vez de merge). Es una decisión de diseño común, pero si la UI espera “apilar al soltar”, el comportamiento actual no lo soporta.

3. **Manejo de `instancia` en stacking/split es conservador pero con casos límite.**  
   - Evidencia: la pasada 1 de apilado solo se ejecuta si `stack_max > 1 and instancia.is_empty()` (`inventario_contenedor.gd:54`); en la pasada 2, si `stack_max == 1` conserva `instancia`, si no la descarta al ocupar (`:75`). `split_stack()` permite separar solo si deja al menos 1 en origen (`amount = clampi(amount, 1, s.cantidad - 1)` y `if amount <= 0: return false`, `inventario_service.gd:153-155`) y pasa `s.instancia` al destino solo cuando el origen quedaría en 1 (`:156`).  
   - Impacto: ítems apilables portando `instancia` no se fusionarán con stacks parciales (por diseño defensivo) y, al crearse en slots nuevos como apilables, la instancia no se preserva en ese flujo. Además no se puede “partir en dos” extrayendo todo el stack vía `split_stack` (requiere usar mover/intercambiar), lo cual puede ser una limitación funcional según UX.

4. **Sin consolidación explícita al ordenar ni API de merge.**  
   - No se encontró una operación dedicada a “compactar” stacks (fusionar parciales del mismo ítem) en el servicio/contenedor.

---

## 5. (4) ¿Hay problemas de duplicación o pérdida de items?

### Hallazgos críticos/altos

1. **Posible duplicación en `move_item()` ante movimiento parcial.**  
   - Evidencia: `move_item()` llama `tc.add_item(...)` y obtiene `sobrante`; si `sobrante < s.cantidad` considera éxito, vacía el origen y retorna `true` (`inventario_service.gd:102-107`). Si `sobrante == s.cantidad` retorna `false` sin cambios (`:108`). **No contempla el caso intermedio** en que parte se aceptó en destino (`0 < sobrante < s.cantidad`): no descuenta lo movido del origen ni revierte lo agregado al destino, pero la función devuelve `false`.  
   - Impacto: en un traslado parcial (destino con espacio limitado), los ítems aceptados podrían quedar en destino y el stack original permanecer íntegro en origen → **duplicación** del monto aceptado.  
   - Ubicación: `game/isla-ancestral/scripts/inventario/inventario_service.gd:94-108`.

2. **`agregar_items()` (adaptador shop) no revierte correctamente el fallback a CASA.**  
   - Evidencia: por cada ítem intenta agregar a `BOLSILLO` y, si sobra, agrega el sobrante a `CASA` (`inventario_service.gd:225-230`). Si aún sobra, calcula `devolver = cantidad - sobrante` y elimina esa cantidad **solo de `BOLSILLO`** (`:233-235`) antes de retornar `false`.  
   - Impacto: si parte del ítem fue colocada en `CASA` durante el fallback, el rollback no la retira de `CASA` (y puede intentar quitar de bolsillo una cantidad que ya no está allí en la proporción esperada). Esto puede dejar ítems residuales en casa y/o fallar el rollback → **inconsistencia/posible duplicación lógica** respecto al contrato “todo-o-nada”.  
   - Ubicación: `game/isla-ancestral/scripts/inventario/inventario_service.gd:225-237`.

3. **`devolver_contenido_cofre()` (iter4) no consume/limpia el origen del cofre.**  
   - Evidencia: obtiene contenido desde `ChestManager.get_contenido(cofre_id)` y transfiere con `agregar_con_fallback()` acumulando sobrante, pero no elimina ni marca como extraído el contenido en el cofre ni en `ChestManager` (`inventario_iter4.gd:218-230`).  
   - Impacto: si la función se invoca más de una vez para el mismo estado del cofre (o si el llamador asume extracción), puede reinyectar los mismos ítems → **duplicación**. Depende del contrato externo, pero la función no es idempotente ni segura por sí misma.

### Riesgos de pérdida (mitigados en parte)

4. **Descarte elimina del inventario antes de materializar en mundo; pérdida depende del consumidor de la señal.**  
   - Evidencia: `discard_item()` exige confirmación, protege ítems de misión, vacía el slot y emite `item_removed` para que el mundo cree el pickup (`inventario_service.gd:343-362`).  
   - Impacto: si ningún sistema escucha/gestiona correctamente la creación del pickup, el ítem se pierde. Es consistente con un diseño event-driven, pero el riesgo existe en integración.

5. **Recolección con fallback puede dejar sobrante “en el mundo” por contrato.**  
   - Evidencia: `agregar_con_fallback()` intenta bolsillo y luego casa, devolviendo el sobrante para que quede como pickup en mundo (`inventario_iter4.gd:175-179`); la sugerencia de casa llena también indica “quedan en el suelo” (`:69-71`).  
   - Impacto: no es pérdida si el llamador instancia el pickup; sí lo es si ignora el valor de retorno.

### Controles que reducen pérdida/duplicación
- `split_stack()` solo aplica el cambio si el destino aceptó todo el monto (`sobrante == 0`) (`inventario_service.gd:157-161`), evitando duplicación en splits parciales fallidos.
- Validaciones de carga (claves, tipos, ids de ítem, cantidades, clamp de stack) reducen corrupción silenciosa (`inventario_contenedor.gd:122-145`, `inventario_service.gd:404-429`, `test_inventario_restore_robusto.gd`).
- `consume_for_crafting()` y `remover_items()` validan disponibilidad antes de mutar (todo-o-nada) (`inventario_service.gd:239-280`).

---

## 6. (5) Dos mejoras sugeridas

### Mejora 1 — Corregir atomicidad de `move_item()` y de `agregar_items()` para evitar duplicaciones/inconsistencias
- **Problema a resolver:** `move_item()` no maneja correctamente el caso de traslado parcial (riesgo de duplicación) y `agregar_items()` revierte solo desde bolsillo aunque pudo haber insertado en casa (rollback incompleto).
- **Cambios propuestos:**
  - En `move_item()` (`inventario_service.gd:94-108`): calcular `movido = s.cantidad - sobrante`; si `movido <= 0` retornar `false`; si `movido < s.cantidad` descontar `movido` del slot origen y mantenerlo; si `movido == s.cantidad` vaciar origen. Emitir señales acorde a lo realmente movido.
  - En `agregar_items()` (`inventario_service.gd:225-237`): registrar por contenedor cuánto se agregó realmente (p. ej. snapshot/delta por contenedor o revertir primero de casa y luego de bolsillo por la cantidad correspondiente), o ejecutar una simulación/validación de capacidad previa y solo entonces mutar de forma transaccional.
- **Beneficio:** preserva invariantes de conservación de ítems, elimina duplicaciones en edge cases y hace confiables las integraciones con shop/traslados.

### Mejora 2 — Añadir compactación/merge de stacks y una operación de “stack” segura (merge-on-drop)
- **Problema a resolver:** stacks fragmentados persisten tras ordenar y no hay fusión al intercambiar/soltar; esto degrada capacidad útil y UX.
- **Cambios propuestos:**
  - Implementar `compact_container(container)` o integrar compactación opcional en `sort_container()` para fusionar stacks del mismo `item_id` (respetando `stack_max`, `favorito/bloqueado` según política definida).
  - Extender `swap_items()`/UI con una ruta de merge cuando origen y destino sean apilables, mismo id y sin conflicto de instancia (o definir política explícita), antes de caer en swap puro.
  - Añadir tests de regresión para: move parcial, agregar_items con fallback+rollback, merge de stacks fragmentados y split/merge con ítems con `instancia`.
- **Beneficio:** mejora uso de capacidad, reduce fragmentación y alinea el comportamiento con expectativas típicas de inventarios RPG/survival.

---

## 7. Conclusión final

El sistema de inventario presenta una arquitectura clara y razonablemente modular: `InventorySlot` como unidad de estado, `ContenedorInventario` con inserción en dos pasadas y controles de stack/capacidad, e `InventarioService` como autoridad central con señales, adaptadores de gameplay y persistencia robusta (incluyendo correcciones BUG-108 para claves inválidas y clamp de cantidades al cargar). Existen validaciones efectivas de capacidad por slots y por `stack_max`, y el flujo de split evita commits parciales inseguros.

Sin embargo, se identifican riesgos concretos de **integridad de ítems**: `move_item()` no maneja correctamente el caso de traslado parcial (potencial duplicación), `agregar_items()` realiza un rollback incompleto cuando interviene el fallback a casa, y `devolver_contenido_cofre()` no asegura idempotencia/limpieza del origen. A nivel de usabilidad/eficiencia, la ausencia de consolidación de stacks en sort/swap puede fragmentar el almacenamiento.

**Estado general:** base funcional sólida con controles importantes de validación/persistencia, pero requiere endurecer operaciones transaccionales (move/rollback) y añadir compactación/merge para garantizar conservación de ítems y mejor aprovechamiento de capacidad en todos los casos borde.
