**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 18: Casas

## 1. Rutas de assets (res://)

```
res://scripts/houses/house_manager.gd          # HouseManager (autoload "house_manager")
res://scripts/houses/house.gd                   # House (nodo exterior, puerta)
res://scripts/houses/house_interior.gd          # HouseInterior (escena interior)
res://scripts/houses/house_upgrade.gd           # HouseUpgrade (etapas y obras)
res://scripts/houses/house_storage.gd           # HouseStorage (contenedores)
res://scripts/houses/house_decor.gd             # HouseDecor (grid de muebles)
res://scripts/houses/house_data.gd              # HouseData, HouseUpgradeData, FurnitureData (Resources)
res://scripts/houses/house_registry.gd          # Registro por partida (rehidratación al cargar)
res://scenes/houses/house.tscn                  # Modelo exterior (huella, puerta, andamiaje)
res://scenes/houses/house_interior.tscn         # Interior base: living + habitación 1
res://scenes/houses/house_storage.tscn          # Cofre/estantería reutilizable
res://scenes/houses/rooms/                      # Habitaciones prefabricadas (cocina, taller, dormitorio...)
res://data/houses/upgrades/                     # HouseUpgradeData .tres por etapa (1..5)
res://data/houses/furniture/                    # FurnitureData .tres por mueble (cama, mesa, silla, lampara...)
res://data/houses/paint/                        # Presets de estilos de decoracion
res://ui/houses/house_uipanel.gd                # Panel de mejoras (UI aparte, sin acoplar)
res://ui/houses/house_decor_panel.gd            # Panel de modo decoración (UI aparte)
```

## 2. Firmas clave a implementar

```gdscript
# house_manager.gd
class_name HouseManager
extends Node

const VERSION_ESQUEMA := 1
var _casas: Dictionary = {}          # parcel_id -> House
var _parcelas_ocupadas: Dictionary = {}

func validar_parcela(parcela: Vector3i) -> bool
func crear_casa(parcela_id: String, datos: HouseData) -> House
func obtener_casa_jugador() -> House
func registrar_casa(casa: House) -> void
func solicitar_visita(vecino_id: String, dia_juego: int, hora: int) -> bool
func salvar(estado: Dictionary) -> void
func cargar(estado: Dictionary) -> void
signal casa_creada(casa: House)
signal casa_reubicada(casa: House)

# house.gd
class_name House
extends Node3D

@export var etapa: int = 1
@export var en_obra: bool = false
@export var progreso_obra: int = 0
@export var parcela_id: String = ""

func abrir_interior() -> void
func esta_en_obra() -> bool
func etapa_actual() -> int
func reubicar(nueva_parcela: Vector3i, coste: Dictionary) -> bool
func obtener_entrada() -> Vector3
signal puerta_interactuada()

# house_interior.gd
class_name HouseInterior
extends Node3D

var habitaciones: Array[Node3D] = []

func entrar(jugador: Node3D) -> void
func salir() -> void
func obtener_habitaciones() -> Array[Node3D]
func agregar_habitaciones(ids: Array[String]) -> void
signal interior_listo
signal interior_cerrado

# house_upgrade.gd
class_name HouseUpgrade
extends Node

@export var etapas: Array[HouseUpgradeData] = []

func etapa_actual() -> int
func proxima_etapa() -> HouseUpgradeData
func verificar_requisitos(etapa_id: String, inv: Inventory) -> Dictionary
func iniciar_obra(etapa_id: String) -> bool
func tick_diario() -> void
func aplicar_etapa(etapa: HouseUpgradeData) -> void
signal obra_iniciada(etapa_id: String)
signal obra_completada(etapa_id: String)

# house_storage.gd
class_name HouseStorage
extends Node

var _contenedores: Dictionary = {}   # mueble_id -> { slots: Array }

func abrir(mueble: Node3D) -> void
func cerrar() -> void
func transferir_a_inventario(mueble_id: String, idx: int, cantidad: int) -> int
func transferir_desde_inventario(mueble_id: String, item_id: String, cantidad: int) -> int
func extraer_contenido(mueble_id: String) -> Array
signal storage_changed(mueble_id: String)

# house_decor.gd
class_name HouseDecor
extends Node3D

const CELDA_TAMANO := Vector3(0.25, 0.25, 0.25)

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

## 3. Datos (Resources)

```gdscript
# house_data.gd
class_name HouseData
extends Resource
@export var display_name: String
@export var huella_voxel: Vector2i = Vector2i(4, 4)
@export var etapa_inicial: int = 1
@export var costo_inicial: Dictionary = { "madera": 20, "piedra": 10 }

class_name HouseUpgradeData
extends Resource
@export var etapa: int
@export var display_name: String
@export var costo: Dictionary                  # item_id -> cantidad (M14)
@export var requisito_mision: String = ""
@export var dias_obra: int = 1
@export var habitaciones: Array[String] = []
@export var slots_decor_extra: int = 0
@export var slots_storage_extra: int = 0

class_name FurnitureData
extends Resource
@export var id: String
@export var display_name: String
@export var tamano_celdas: Vector3i = Vector3i.ONE
@export var tipo: String                       # "silla", "cama", "mesa", "lampara", "contenedor", "pared", "planta", "decorativo"
@export var interactivo: bool = false
@export var es_contenedor: bool = false
@export var slots_contenedor: int = 0
@export var valor_amistad: int = 1            # aporte a visitas M19
@export var estilo: String = "ancestral"
```

## 4. Logs relacionados

Prefijo de log del módulo: `[HOUSE]`. Ejemplos de entradas (sistema de Logs de la sección 6 de AGENTS.md):

```
[HOUSE] casa creada parcel=0x12 etapa=1
[HOUSE] obra iniciada parcel=0x12 etapa=2 dias=2
[HOUSE] obra completada parcel=0x12 etapa=2 habitacion=cocina
[HOUSE] visita inicio vecino=Maika dia=23 hora=18 por=decoracion_valor=14
[HOUSE] visita fin vecino=Maika amistad=+2 total=57
[HOUSE] mudanza mueble cofre_roble celda=(2,0,1) contenido_devolvido=3 items
[HOUSE] reubicacion parcel=0x12 -> parcel=0x15 coste_aplicado=true
[HOUSE] error: intento de entrar con obra en curso parcel=0x12
```

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Diseño inicial completo (no implementado)

- Este documento es la plantilla objetivo para la implementación; las rutas y firmas se ajustarán al agente delegado según la estructura real del proyecto Godot.
- Los prefijos de log `[HOUSE]` deberán ir por el sistema central de logging (M103) al implementar.
- La integración con Voxel Tools (GDExtension) aplica solo al exterior (huella y parcela); el interior es escena de malla estándar de Godot.