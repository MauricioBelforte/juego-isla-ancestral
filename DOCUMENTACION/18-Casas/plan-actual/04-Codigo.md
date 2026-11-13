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
## 6. Implementación s2 (atria-dawn-s2, 2026-10-11, Log 1691)

Se implementaron 8 scripts nuevos en scripts/houses/ (lógica pura, sin tocar house_manager.gd):

| Script | class_name | Responsabilidad |
|---|---|---|
| house_data.gd | HouseData | Resource: huella voxel, etapa inicial, costo inicial; huella_valida(), costo_total() |
| house_upgrade_data.gd | HouseUpgradeData | Resource: etapa, costo, requisito_mision, requisito_amistad, dias_obra, habitaciones |
| house_storage.gd | HouseStorage | Contenedores: slots, transferencia bidireccional M14, extraer_contenido(), señal contenedor_lleno |
| house_decor.gd | HouseDecor | Grid fino 0.25 m: alidar_celda(), colocar(), otar() (90°), levantar(), persistencia |
| house_upgrade.gd | HouseUpgrade | Obra por etapas: erificar_requisitos(), iniciar_obra(), 	ick_diario() (M29), progreso_obra() |
| house.gd | House | Nodo exterior: brir_interior()/cerrar_interior(), obtener_entrada(), cartel_bloquea_mapa() |
| house_interior.gd | HouseInterior | Habitaciones por etapa (living→5), gregar_habitaciones(), desbloquear_etapa() |
| house_visit.gd | HouseVisit | Visitas M19/M21: agenda por franja, eaccion_decoracion(), puntos_amistad_por_valor() |

Test: scripts/houses/test_m18_sistemas_s2.gd — 79 checks, 0 fallos, EXIT 0 (sin regresión: 	est_m18_casas.gd 53/0).

**Notas:**
- HouseVisit lee house_manager por duck-typing (obtener_vecino, egistrar_entrada_vecino); no lo modifica (regla §15).
- En headless no hay InventarioService ni AmistadManager/MisionManager: las transferencias y requisitos degradan sin crash.
- HouseInterior._habitaciones_por_etapa(5) = 6 habitaciones (living + dormitorio + cocina + taller + sótano + ático).
- Pendiente (35 [ ]): cocina/taller funcionales con M16, jardín M33, visuales M154 (cimientos, exterior por etapa), integración M17/M21 real, tests de flujo completo.

---

## 8. Assets nuevos de casas grandes (2026-11-12, ERNIE-5.5-Flash-Preview)

> **v2:** las cifras de §8.1–8.5 son de la primera versión; la vigente es §8.6 (20×15 / 28×20, 0 solapes).

### 8.1 Archivos creados

| Archivo | Tipo | Contenido |
|---|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_grandes.py` | Script Blender | Genera Casona 16×12 y Mansión 22×16 con interiores, materiales, cámara y luces |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_2026-11-12.blend` | .blend | Escena `Casas_Grandes` con ambas casas + escena `Scene` con las casas pequeñas |
| `tools/mcp/blender-mcp/18-Casas/CAPTURAS/casas_grandes_exterior_2026-11-12.png` | Render | Vista general de ambas casas |
| `.../casona_exterior_2026-11-12.png` | Render | Casona del Gremio exterior |
| `.../casona_interior_2026-11-12.png` | Render | Casona con techo oculto (vista de muñeca) |
| `.../mansion_exterior_2026-11-12.png` | Render | Mansión del Museo exterior |
| `.../mansion_interior_2026-11-12.png` | Render | Mansión con techo oculto |

### 8.2 Funciones del script Blender

| Función | Responsabilidad |
|---|---|
| `box / cyl / cone / sph / roof` | Malla directa con `bmesh` (sin `bpy.ops` por objeto) |
| `wall_x / wall_y` | Muros con huecos de puerta y dintel |
| `stairs` | Escalera recta con baranda y balaustres |
| `slab_hole` | Losa de planta alta con hueco de escalera |
| `table / chair / bed / wardrobe / shelf` | Mobiliario base |
| `chandelier / plant / painting / display_case / armor` | Decoración y piezas de museo |
| `telescope / piano / harp / armillary / billiard / hammock` | Objetos originales |

### 8.3 Rutas propuestas en Godot

| Asset | Ruta | Notas |
|---|---|---|
| Casona exterior | `res://assets/3d/alta/18-Casas_casona_gremio.glb` | LOD0 ≤6.000 tris; variantes `_media/_baja` |
| Casona interior | `res://assets/3d/alta/18-Casas_casona_gremio_interior.glb` | Escena interior; muebles + shell |
| Mansión exterior | `res://assets/3d/alta/18-Casas_mansion_museo.glb` | Dividida en alas si supera 6.000 tris |
| Mansión interior | `res://assets/3d/alta/18-Casas_mansion_museo_interior.glb` | Escena interior |
| Objetos | `res://assets/3d/alta/18-Casas_<objeto>.glb` | Ej.: `18-Casas_biblioteca_caracol.glb` |
| Recetas M17 | `res://data/construccion/piezas/<objeto>.tres` | Solo para piezas construibles (pared, piso, techo, puerta, ventana) |

### 8.4 Integración en Godot (pendiente)

1. Exportar cada casa con `exportar_godot.py` (módulo `18-Casas`) y verificar `glb == .import == .scn`.
2. Importar con `meshes/generate_lods=true` y `visibility_range` 30/60/120 m.
3. Crear `scenes/houses/house_casona_gremio.tscn` y `house_mansion_museo.tscn` con `House` + `Area3D` de puerta + colisión.
4. Colocar con `TerrainLocator.posicionar_sobre_terreno()`; validar huella y pendiente.
5. Registrar en `HouseManager.registrar_casa()`; añadir `HouseInterior` con habitaciones por etapa.
6. Añadir los objetos nuevos al catálogo M159 y a `HouseDecor` (celdas, `requiere_pared`, `requiere_superficie`).
7. QA: `godot_get_debug_output` sin errores, capturas orbitales y prueba de entrar/salir.

### 8.5 Presupuesto y materiales

| Métrica | Casona | Mansión |
|---|---:|---:|
| Piezas Blender | 608 | 845 |
| Tris ALTA | 12.608 | 19.866 |
| Materiales | 16 | 15 |
| LOD objetivo exterior | ≤6.000 | ≤6.000 por ala |
| Materiales objetivo en Godot | ≤8 | ≤8 |

> Los materiales exceden el objetivo de 8; se unifican con `generar_variante.py --media --baja` o con el atlas M47 (1024², 32 px/tile). El color por vértice se conserva como fuente de autoría.

### 8.6 v2 — casas 20×15 y 28×20, 0 solapes (2026-11-12)

| Archivo | Contenido |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_grandes_v2.py` | Script v2 con generador y **validador de AABB** |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_v2_2026-11-12.blend` | Escena `Casas_Grandes_v2` + `Scene` (casas pequeñas) |
| `CAPTURAS/casas_grandes_v2_exterior_2026-11-12.png` | Vista general |
| `CAPTURAS/casona_v2_exterior/interior_2026-11-12.png` | Casona v2 |
| `CAPTURAS/mansion_v2_exterior/interior_2026-11-12.png` | Mansión v2 |

| Métrica | Casona v2 | Mansión v2 |
|---|---:|---:|
| Dimensiones | 20×15 m | 28×20 m |
| Piezas | 568 | 826 |
| Tris ALTA | 11.896 | 19.874 |
| Materiales | 16 | 15 |
| BBox | 21,1×16,0×10,3 m | 30,2×22,8×12,9 m |
| Solapes mueble-estructura | **0** | **0** |
| Solapes mueble-mueble | **0** | **0** |
| Objetos sobre el hueco de escalera | **0** | **0** |

**Validación:** AABB mundial por malla, tolerancia 0,10 m; se excluyen uniones intended (chimenea-techo, base/respaldo de sofá, tapa/cuerpo de piano, anillos de esfera armilar). El script imprime el resultado al construir.

**Pendiente de Godot:** exportar GLB exterior/interior, LODs ≤6.000 tris, `TerrainLocator`, escenas `house_casona_gremio_v2.tscn` / `house_mansion_museo_v2.tscn`, y registro de los 21 objetos en M18/M159.

### 8.7 Casas extra y detalle exterior/interior (2026-11-12)

| Archivo | Contenido |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_extra.py` | Genera Agricultor (18×13) y Mercader (16×12) |
| `tools/mcp/blender-mcp/18-Casas/add_exterior_detail.py` | Ventanas, chimeneas, vigas de esquina, zócalos, aleros, sendero, cerca, pozo, farol |
| `tools/mcp/blender-mcp/18-Casas/add_interior_detail.py` | Zócalos interiores, vigas de techo, marcos de puertas, cuadros, vajilla |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_extra_2026-11-12.blend` | Escena `Casas_Extra` + `Casas_Grandes_v2` + `Scene` |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_v2_guardadas_2026-11-12.blend` | Respaldo v2 con detalle |
| `CAPTURAS/casas_grandes_v2_exterior_2026-11-12.png` | Exterior v2 con ventanas/chimeneas |
| `CAPTURAS/casona_v2_interior_2026-11-12.png` | Interior Casona |
| `CAPTURAS/mansion_v2_interior_2026-11-12.png` | Interior Mansión |
| `CAPTURAS/casas_extra_exterior_2026-11-12.png` | Exterior Agricultor/Mercader |
| `CAPTURAS/agricultor_interior_2026-11-12.png` | Interior Agricultor |
| `CAPTURAS/mercader_interior_2026-11-12.png` | Interior Mercader |

| Métrica | Casona | Mansión | Agricultor | Mercader |
|---|---:|---:|---:|---:|
| Piezas | 807 | 1.091 | 546 | 592 |
| Tris | 18.708 | 27.502 | 12.330 | 12.708 |
| Materiales | 18 | 17 | 17 | 18 |
| Ventanas | 240 | 280 | 160 | 120 |
| Solapes AABB | 0 | 0 | 0 | 0 |
| Sobre el hueco | 0 | 0 | 0 | 0 |

> **Nota:** los objetos de ventana (640 en total) y el detalle (zócalos, vigas, marcos, cuadros, vajilla) se excluyen del conteo de muebles del validador por ser piezas **ancladas** al muro, piso o techo. El QA de muebles sigue dando 0.