**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25

# 04-Codigo.md — Módulo 169: Crucero de Lujo

> **Estado: plan-inicial. No hay código escrito todavía.** Este archivo describe los archivos
> que se van a crear y las convenciones que deben respetar.

## 1. Archivos a crear

### 1.1 Script (GDScript)

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `scripts/crucero/crucero_manager.gd` | `Node` (autoload `CruceroManager`) | Estado del viaje, pasajes, camarote asignado, señales |
| `scripts/crucero/crucero_pasaje.gd` | `Resource` (`class_name PasajeCrucero`) | Datos de un pasaje (clase, precio, camarote) |
| `scripts/crucero/crucero_interior.gd` | `Node3D` | Control de una cubierta cargable (luces, puertas, spawn) |
| `scripts/crucero/crucero_puerto.gd` | `Area3D` | Detección de embarque/desembarque |

### 1.2 Escenas

| Archivo | Tipo | Nota |
|---|---|---|
| `scenes/crucero/crucero.tscn` | `Node3D` | Contenedor del exterior |
| `scenes/crucero/interior_cubierta_1.tscn` | `Node3D` | Cubierta de botes |
| `scenes/crucero/interior_cubierta_2.tscn` | `Node3D` | Camarotes |
| `scenes/crucero/interior_cubierta_3.tscn` | `Node3D` | Comedor + casino |
| `scenes/crucero/interior_cubierta_4.tscn` | `Node3D` | Puente + terraza |

### 1.3 Datos

| Archivo | Contenido |
|---|---|
| `data/crucero/pasajes.json` | Lista de clases de pasaje con precio y camarote asignable |
| `data/crucero/camarotes.json` | 6 tipos de camarote con medidas y precio |

### 1.4 Assets 3D

| Archivo | Vértices | Nota |
|---|---:|---|
| `assets/3d/alta/169-Crucero_exterior.glb` | ≤ 9.000 | |
| `assets/3d/media/169-Crucero_exterior.glb` | ≤ 3.500 | |
| `assets/3d/baja/169-Crucero_exterior.glb` | ≤ 1.500 | |

Fuente Blender: `tools/mcp/blender-mcp/169-Crucero/crucero_exterior_lowpoly.blend` (+ `_media`, `_baja`).

### 1.5 Tests

| Archivo | Cobertura |
|---|---|
| `tests/unit/test_crucero_manager.gd` | estados, venta de pasaje, cambio de cubierta |
| `tests/integration/test_crucero_viaje.gd` | embarque → zarpe → llegada |

## 2. Convenciones

### 2.1 Nomenclatura

- Escenas: `snake_case` con prefijo `interior_cubierta_N` / `crucero`.
- Assets: `SM_Crucero_<pieza>` (casco, cubierta_1, chimenea, bote, etc.).
- Materiales: `MAT_Crucero_<pieza>` (un material por pieza, sin texturas).
- Señales: `crucero_<evento>` (ver 03 §6).

### 2.2 Estructura del autoload

```gdscript
extends Node
## CruceroManager — estado del crucero y del pasaje del jugador.

signal embarque(cubierta: int)
signal desembarco(destino: String)
signal zarpe(origen: String, destino: String)
signal llegada(puerto: String)

enum Estado { ATRACADO, ABORDO, NAVEGANDO, EMERGENCIA }

var estado: Estado = Estado.ATRACADO
var cubierta_actual: int = 1
var camarote_asignado: String = ""
var pasaje_actual: PasajeCrucero

func vender_pasaje(clase: String) -> bool: ...
func embarcar() -> bool: ...
func cambiar_cubierta(destino: int) -> bool: ...
func desembarcar(destino: String) -> void: ...
```

### 2.3 Integración con M63 (streaming)

```gdscript
# al entrar a una cubierta
func _cargar_cubierta(n: int) -> void:
    var ruta := "res://scenes/crucero/interior_cubierta_%d.tscn" % n
    await CargasManager.cargar_sector(ruta)
    cubierta_actual = n
    emit_signal("embarque", n)
```

### 2.4 Integración con M67 (vehículo)

`vehicles.json` recibe una entrada nueva:

```json
{
  "id": "crucero",
  "tipo": "agua",
  "nombre": "Crucero Real",
  "velocidad_max": 0.0,
  "velocidad_crucero": 0.0,
  "giro": 0.0,
  "frenado": 0.0,
  "baul_slots": 0,
  "tiene_reversa": false,
  "condicional": "169"
}
```

**Nota:** `velocidad_max = 0` porque el crucero **no es manejable**: solo atrae y zarpa por ruta.
Si M67 rechaza velocidad 0, se usa un valor simbólico (1.0) y se bloquea el control en el script.

### 2.5 Colisiones

Ver 03 §7. Resumen operativo:

```gdscript
# el casco no usa la malla: usa un convex simplificado
$Casco/Colision.shape = ConvexPolygonShape3D.new()
$Casco/Colision.shape.points = _simplificar_casco()  # 12-16 puntos
```

## 3. Dependencias

| Módulo | Tipo | Por qué |
|---|---|---|
| **68-Transporte** ⭐ | **Código** (`TransportManager`, `buy_ticket`, `temporada`) | Rutas entre islas, pasajes y ventana estacional |
| **74-Eventos** ⭐ | **Código** (`EventManager`, contrato de minijuego) | Los 5 juegos a bordo |
| **34-Pesca** | **Código** (solo como plantilla de FSM) | Estructura de los minijuegos |
| **21-Diálogos** | **Código** | Retos conversacionales y espectáculo |
| **28-Viajes** | **Código** (`Boat`, `BoatDeck`) | Flujo de embarque |
| **63-Cargas** | **Código** (`CargasManager`) | Streaming de cubiertas |
| **29-Tiempo** | **Código** (`GameClock`) | Ventana estacional |
| **38-Economía** | **Código** | Monedas (pasajes y apuestas) |
| **67-Vehículos** | **Datos** (`vehicles.json`) | Registro de atraque |
| **59-GameState** | **Código** | Persistencia |
| **51-Agua** | **Escena** | Flotación |

## 3b. Scripts de la capa de aventura (a crear)

| Archivo | Responsabilidad |
|---|---|
| `scripts/crucero/juegos/crucero_casino.gd` | Ruleta + 2 mesas de cartas; apuesta con M38; límite diario |
| `scripts/crucero/juegos/crucero_torneo.gd` | Recorrido contra reloj por cubiertas 1-2 |
| `scripts/crucero/juegos/crucero_vigia.gd` | Catalejo: detectar objetos en el mar (FSM tipo M34) |
| `scripts/crucero/juegos/crucero_camarote_misterioso.gd` | Pista + cofre en un camarote |
| `data/crucero/juegos_a_bordo.json` | Definición data-driven de las 5 actividades (id, cubierta, premio, límite diario) |

## 4. Logs relacionados (previstos)

| Log | Tema |
|---|---|
| `NNNN-169-exterior-alta.md` | Modelado del exterior (iter 1) |
| `NNNN-169-interiores.md` | Interiores de las 4 cubiertas |
| `NNNN-169-integracion-m28.md` | Embarque/viaje/desembarco |

**Reserva de número:** al cerrar cada tanda, tomar el primer número de `Logs/NUMEROS_DISPONIBLES.txt`
(protocolo §6.1) y borrarlo de la lista.

## 5. Comandos de verificación

```bash
# auditoría de z_min y escala del exterior
python -X utf8 tools/mcp/blender-mcp/scripts-reutilizables/auditar_glb_490.py

# exportar el exterior (headless; el addon MCP no sirve, ver GUIA-BLENDER E-106)
EXPORT_FORZAR=1 EXPORT_MODULOS="169-Crucero" blender -b --factory-startup --python tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py

# tests
godot --headless --path game/isla-ancestral --script tests/run_tests.gd
```

## 6. Notas del agente

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25
**Estado:** Plan inicial (sin código).

### Lo que hice
- Creé el módulo 169 con los 5 archivos de `plan-inicial/`.
- Verifiqué en disco que el crucero **no existía** (16 archivos con "crucero" = velocidad de crucero;
  M28 solo tiene `BoatDeck` de una cubierta; `vehicles.json` sin crucero; IDs hasta 168).
- Definí medidas cerradas y presupuesto de vértices calibrado contra la flota real (109-130 v/m).

### Lo que NO hice
- No escribí código ni modelé nada: el encargo fue **crear el módulo** (documentación).

### Recomendaciones para el próximo agente
1. Empezar por el **exterior LOD alta** (iter 1): es el entregable que el fundador quiere ver.
2. Antes de modelar, leer `GUIA-BLENDER/09-nivel-detalle-modelado.md` (sin tapas planas) y
   `GUIA-BLENDER/07-set-captura-vs-asset.md` (no incluir `Base_Arena` en el asset).
3. El pivote va en la **línea de flotación** (`z = 0`), no en la quilla: un crucero se posa en el agua.
4. Verificar con `auditar_glb_490.py` que el `z_min` quede en `0,045 ± 0,020`.
5. El exportador **no corre desde el addon MCP** (E-106): usar `blender -b`.