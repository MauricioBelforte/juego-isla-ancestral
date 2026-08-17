**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 18: Casas

## 1. Arquitectura general

| Clase | Responsabilidad | Escena |
|---|---|---|
| `HouseManager` | Singleton de servicio: registro de casas, parcelas, orquestación de visitas, persistencia | `res://scenes/houses/house_manager.tscn` |
| `House` | Nodo exterior en el mundo: puerta interactiva, estado de obra, etapa actual, reubicación | `res://scenes/houses/house.tscn` |
| `HouseInterior` | Escena instanciada del interior: habitaciones, cámara, decoración, almacenamiento | `res://scenes/houses/house_interior.tscn` |
| `HouseUpgrade` | Lógica de mejoras por etapas (Lee `HouseUpgradeData`) | Script de datos + componente en `House` |
| `HouseStorage` | Contenedores domésticos: slots, transferencia con M14 | `res://scenes/houses/house_storage.tscn` |
| `HouseDecor` | Colocación de muebles en grid interior, rotación, recolocación y preview | Script en `HouseInterior` |

Capas: los scripts de UI (`HouseUIPanel`, aparte) llaman solo a los objetos públicos de estas clases; ninguna clase anterior conoce nodos de UI (regla 9 de AGENTS.md).

```
WorldManager (M07)          GameState (M58)
      |                           |
      v                           v
 HouseManager <---------> HouseRegistry (por partida)
      |
      +-- House (exterior, mundo voxel M17)
      |       +-- HouseUpgrade (etapa actual, progreso de obra)
      |       +-- Puerta (Area3D interactiva, portal)
      |
      +-- HouseInterior (instanciada bajo demanda)
              +-- Habitaciones (nodes por sala) 
              +-- HouseDecor (grid fino, muebles)
              +-- HouseStorage (contenedores M14)
              |       +-- InventoryView (contrato M14, sin acoplar)
              +-- Cámara interior (M12)
```

## 2. Flujos en texto

### Flujo 2.1: Construcción inicial de la casa (M17)
1. Jugador activa el modo construcción (M17) sobre una parcela asignada.
2. `HouseManager.validar_parcela(parcela)` comprueba terreno despejado y parcelas disponibles.
3. M17 descuenta materiales de M14 via `M17.construir_parcela(parcela, materiales)`.
4. Al completar la obra (progreso por M29), `HouseManager.crear_casa(parcela)` instancia `House` sobre la huella.
5. La casa nace en etapa 1 (choza base) y queda registrada y guardada.

### Flujo 2.2: Entrar y salir del interior
1. Jugador interactúa con la puerta de `House` (Area3D + prompt de interacción).
2. `House.abrir_interior()` verifica estado de casa: si está en obra, muestra cartel "Obra en curso" (M21) y no permite entrar.
3. Se deshabilita input de juego, se instancia/activa `HouseInterior` (carga asíncrona) y se reproduce fundido.
4. Al entrar: la cámara pasa al interior (M12), GameClock pausa el exterior interiormente (iluminación propia).
5. Al salir (puerta interior): fundido inverso, se libera la escena interior, el jugador reaparece frente a la puerta exterior.

### Flujo 2.3: Ampliación por etapas (HouseUpgrade)
1. Jugador abre el panel de mejoras (UI aparte) que lista la próxima etapa.
2. `HouseUpgrade.verificar_requisitos(etapa)` valida: materiales M14, dinero, requisitos de misión M21, día/hora M29.
3. Confirmado, se descuentan materiales y `House.obra = true` (duración N días de juego según M29).
4. El exterior visual cambia a "en obra" (andamiaje); el interior queda bloqueado.
5. `HouseUpgrade.tick_diario()` avanza el progreso; al terminar, aplica la nueva etapa: agrega habitaciones y desbloquea slots de decoración/almacenamiento.

### Flujo 2.4: Decoración y mudanza de muebles (HouseDecor)
1. En modo decoración (panel UI), `HouseDecor.activar()` muestra preview fantasma del ítem del hotbar (M14).
2. `HouseDecor.validar_celda(celda, mueble)` comprueba: dentro de la habitación, sin solapamiento, superficie apta.
3. El jugador coloca/rota el mueble; al confirmar se descuenta del inventario M14 (o se toma del propio contenedor).
4. Para mover un mueble ya colocado: `HouseDecor.levantar(instancia)` — si el mueble es contenedor con objetos, `HouseStorage.extraer_contenido()` devuelve los ítems al inventario (con aviso previo).
5. Se guarda el estado del grid.

### Flujo 2.5: Almacenamiento doméstico (HouseStorage + M14)
1. Jugador abre un mueble-contenedor (cofre, estantería).
2. `HouseStorage.abrir()` crea la vista de transferencia usando el contrato de M14 (sin acoplar UI).
3. Transferencia rápida (un click), por lotes, separación de stacks y confirmación para objetos importantes (reglas M14).
4. Cualquier cambio emite `storage_changed` y se marca el GameState para guardado.

### Flujo 2.6: Visita de vecino (M19 + M29 + M21)
1. El plan diario del vecino (M19, agenda M29) incluye "Visitar casa del jugador" según afinidad y decoración.
2. `HouseManager.solicitar_visita(vecino, dia, hora)` valida disponibilidad (casa accesible, no en obra).
3. Al entrar con el jugador o por horario, el vecino se instancia dentro de `HouseInterior` (punto de entrada).
4. El vecino reacciona a la decoración (mira muebles, comenta por M21) y puede sentarse en muebles aptos.
5. Puntos de amistad (M19) según ítems valiosos de la casa; la visita termina y el vecino sale por la puerta.

## 3. Contratos API GDScript (públicos)

```gdscript
# HouseManager (autoload "house_manager")
func validar_parcela(parcela: Vector3i, size_voxel: Vector3i) -> bool
func crear_casa(parcela_id: String, datos: HouseData) -> House
func obtener_casa_jugador() -> House
func registrar_casa(casa: House) -> void
func solicitar_visita(vecino_id: String, dia_juego: int, hora: int) -> bool
func salvar(estado: Dictionary) -> void
func cargar(estado: Dictionary) -> void
signal casa_creada(casa: House)
signal casa_reubicada(casa: House)

# House (exterior)
func abrir_interior() -> void
func esta_en_obra() -> bool
func etapa_actual() -> int
func reubicar(nueva_parcela: Vector3i, coste: Dictionary) -> bool
func obtener_entrada() -> Vector3
signal puerta_interactuada()

# HouseInterior (interior)
func entrar(jugador: Node3D) -> void
func salir() -> void
func obtener_habitaciones() -> Array[HouseRoom]
func agregar_habitaciones(ids: Array[String]) -> void
signal interior_listo
signal interior_cerrado

# HouseUpgrade
func etapa_actual() -> int
func proxima_etapa() -> HouseUpgradeData
func verificar_requisitos(etapa_id: String, inv: Inventory) -> Dictionary
func iniciar_obra(etapa_id: String) -> bool
func tick_diario() -> void
func aplicar_etapa(etapa: HouseUpgradeData) -> void
signal obra_iniciada(etapa_id: String)
signal obra_completada(etapa_id: String)

# HouseStorage
func abrir(mueble: Node3D) -> void
func cerrar() -> void
func transferir_a_inventario(mueble_id: String, idx: int, cantidad: int) -> int
func transferir_desde_inventario(mueble_id: String, item_id: String, cantidad: int) -> int
func extraer_contenido(mueble_id: String) -> Array
signal storage_changed(mueble_id: String)

# HouseDecor
func activar() -> void
func desactivar() -> void
func validar_celda(celda: Vector3i, mueble: FurnitureData) -> Dictionary
func colocar(celda: Vector3i, mueble_id: String, rotacion: int) -> bool
func levantar(celda: Vector3i) -> void
func rotar(celda: Vector3i, pasos: int) -> void
func recolectar_estado() -> Dictionary
func restaurar_estado(datos: Dictionary) -> void
signal decoracion_cambiada
```

## 4. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M17 Construcción | La casa exterior nace de `construir_parcela()`; obras de mejora reusan el patrón de obra de M17 (andamiaje, progreso) |
| M14 Inventario | Descuentos de materiales via `Inventory.quitar_item()`; transferencia de almacenamiento con el mismo contrato de stacks/UI |
| M19 NPC | `solicitar_visita()` coordina entrada/salida; puntos de amistad por valor de decoración |
| M21 Diálogos | Carteles de obra, reacciones a decoración y avisos de visita se emiten como eventos de diálogo |
| M29 Tiempo | `tick_diario()` para obras; agenda de visitas por hora; PRNG por partida para preferencias y variaciones |
| M58 Guardado | `House` y `HouseInterior` serializan via `salvar()/cargar()` con IDs y versión de esquema |
| M12 Cámara | Cámara interior dedicada con límites por habitación al entrar/salir |
| M61 Rendimiento | Contrato de presupuesto: interior instanciado, grid sin allocs, transición asíncrona |

## 5. Persistencia (esquema de datos)

```
partida -> casas: [
  { parcel_id, etapa, en_obra, progreso_obra, posicion_voxel, rotacion,
    interior: {
      habitaciones: [ids],
      muebles: [ { id, celda, rotacion, extra: {slot_id: {item, cantidad}} } ],
      storage: [ { mueble_id, slots: [{item_id, cantidad}] } ]
    }
  }
]
```
Versión del esquema incluida; migración en el cargador (M58).