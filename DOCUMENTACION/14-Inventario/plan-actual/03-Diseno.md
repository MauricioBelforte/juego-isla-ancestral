**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo Code

# 03-Diseno.md — Módulo 14: Inventario

## 1. Arquitectura

```
                    InventoryService.gd (autoload; única autoridad de ítems)
   �??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�??�?
   ▼            ▼               ▼              ▼               ▼               ▼
 Inventory   Inventory       StorageChests  ItemCatalog   InventorySave   Señales de
 (bolsillo)  (casa 60-120)  (cofres M17 /  (id → Item-     (serialización   integración
 + mochila)                  almacén 240)    Data.tres)     M59 + valid.)   M13/M15/M16/
   │            │               │              │               │           M19/M39/M37
   └────────────┴───────┬───────┴──────────────┴───────────────┘           │
                       ▼                                                    ▼
              InventoryUI.gd (capa presentación M53 — solo refleja estado)
   �??�??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�?��??�??�??�??�??�??�??�??�??�??�??�??�??�??�?
   ▼              ▼              ▼              ▼              ▼
 Grid de slots  Pestañas y     Tooltip /      Hotbar 6       Diálogos de
 (escena slot)  filtros/sort   panel detalle   slots          confirmación
   │              │              │              │              │
   └──────────────┴───────┬──────┴──────────────┴──────────────┘
                          ▼
              Catalog/EventBus: señales cambiadas(lugar, slot)
                          ▼
              Logs DOM-14 (errores, descartes protegidos) — M103
```

Regla de capas: la UI nunca muta contenedores directamente; emite intenciones (señales/botones) y el servicio valida y responde.

## 2. Diagrama de flujo: recolección (M13/M15)

```
Jugador usa herramienta (M13) sobre recurso (M15)
   → el mundo produce ItemData + cantidad (1-3 según recurso, PRNG M29)
   → InventoryService.add_item(id, cantidad, BOLSILLO)
        ├─ pasa si hay stack con espacio → se apila (never se pierde)
        ├─ si el stack se llena → nuevo slot libre
        ├─ si no hay stack ni slot libre → signal inventory_full
        └─ inventory_full → el ítem queda en el mundo (pickup flotante, M23/M56)
   → UI muestra notificación amable + contador si es espóra de luz
```

## 3. Diagrama de flujo: abrir inventario y transferir

```
Tecla B / Botón de mochila (M56 controles)
   → InventoryService.pausa_suave(UI only, mundo congelado M29 opcional)
   → InventoryUI.open(bolsillo, contenedor_seleccionado)
   → el jugador selecciona ítem:
        ├─ Mover: enter/click → transferencia rápida del stack completo
        ├─ Ctrl+click → transferencia múltiple (spinner de cantidad)
        ├─ Shift+click → separar stack a la mitad (2 clicks)
        ├─ R / clic derecho → acciones contextuales (usar, equipar, favorito,
        │                    vender M39, donar M37, descartar M14)
        └─ Tecla de soltar → descarte (con confirmación si es protegido)
   → InventoryService valida y ejecuta
   → señales → UI refresca solo los slots cambiados (no toda la grilla)
```

## 4. Contratos de API (nivel servicio)

```
InventoryService (autoload — único punto de acceso):
  add_item(item_id: String, amount: int, container: ContainerType) -> int  # sobrante no aceptado
  remove_item(item_id: String, amount: int, container: ContainerType) -> bool
  count_item(item_id: String, include_house: bool) -> int
  has_free_space(container: ContainerType) -> bool
  used_slots(container: ContainerType) -> int / total_slots(container) -> int
  move_all(from: ContainerType, to: ContainerType) -> int                   # ítems movidos
  move_amount(from: ContainerType, slot: int, to: ContainerType, amount: int) -> bool
  split_stack(container: ContainerType, slot: int, amount: int) -> bool
  sort(container: ContainerType, mode: SortMode)
  toggle_favorite(container: ContainerType, slot: int)
  discard(container: ContainerType, slot: int, confirmado: bool) -> Result
  open_storage(chest_id: String) -> void / close_storage() -> void
  señales: item_added / item_removed / slot_changed(container, slot) /
           inventory_full(container, item_id) / container_size_changed /
           storage_opened(chest_id) / storage_closed
```

Contratos de integración con otros módulos:

```
M13 (herramientas):  usar_herramienta() → señal herramienta_usada → el mundo entrega ítems
M15 (recursos):      recurso.cosechar() → InventoryService.add_item(...)
M16 (crafting):      InventoryService.count_item(id, include_house=true) para materiales;
                     receta.craftear() → remove_item(materiales) → add_item(resultado)
M19/M20 (regalos):   regalar(item_id) → remove_item + señal regalo_entregado;
                     NPC entrega → add_item a BOLSILLO o a BandejaCorreo si está lleno
M37 (colecciones):   donar(item_id) → remove_item + registro en colección (índice POI global)
M39 (tiendas):       vender(slot, cantidad) → remove_item + crédito; comprar → add_item
M59 (guardado):      to_dict() / from_dict() por contenedor, versión y validación
M55 (diario):        contador de espóras de luz vía count_item("espora_luz", global)
```

## 5. Tabla de contenedores

| Contenedor | Slots | Stack referencial | Cómo se obtiene |
|---|---|---|---|
| Bolsillo | 24 | 99 (recursos) | Inicial |
| Mochila | +16 (total 40) | — | Compra/regalo amistad (M20) |
| Almacenamiento doméstico | 60 → 120 | — | Casa inicial (M18) + expansiones |
| Cofres colocables | 16 / 28 / 40 | — | Construcción (M17) |
| Almacén del pueblo | 240 | — | Desbloqueo temprano por misión |
| Bandeja de correo | 24 | ítems 1 | Recepción de paquetes NPC (M19) |

## 6. Diseño de slots y estados

| Estado | Visual | Comportamiento |
|---|---|---|
| Vacío | Slot oscuro | Acepta soltar ítems |
| Ocupado | Icono + contador | Acciones contextuales |
| Favorito | Pin superior | Fijo ante sort; nunca se sobreescribe |
| Bloqueado | Candado | Tooltip explica desbloqueo |
| Protegido | Borde dorado | Requiere confirmación para descartar |

## 7. Presupuesto y rendimiento (M61)

| Métrica | Tope |
|---|---|
| Apertura del inventario | ≤ 5 ms |
| Mover/ordenar 100 ítems | ≤ 8 ms |
| Instancias de nodo por ítem | 0 (datos) |
| Iconos | Atlas 256 por categoría (1 draw call) |
| Refresh de UI | Solo slots cambiados (signal por slot) |
| Guardado de todos los contenedores | ≤ 10 ms en diferido (M59) |

## 8. QA

- Test M112: matriz de operaciones (add, apilar, overflow, mover, intercambiar, separar, ordenar, descartar) sin pérdida de ítems.
- Test M112: inventario lleno en cada integración (recolección, regalo, compra, craft) → ítem nunca desaparece.
- Recorrido M114: 3 días de juego recolectando y gestionando; sin frustraciones ni pérdidas; hotbar y favoritos persisten entre sesiones.