# 04 — Código — M25: Ruinas

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18

## Archivos existentes (implementación actual)

| Archivo | Líneas | Descripción |
|---|---|---|
| `scripts/ruinas/generador_ruina.gd` | 122 | `class_name RuinaChozavil` — Construye una ruina chozavil procedural con voxels. Integrada en `main_island.gd` línea 14. |
| `scripts/ruinas/preview_ruina.gd` | 115 | Preview scene para validación visual. Crea VoxelTerrain propio + ruina + captura automática. |
| `scenes/ruina_preview.tscn` | — | Escena preview (VoxelTerrain + Camera3D + preview_ruina.gd) |

**Estado actual**: Solo existe 1 tipo de ruina (chozavil) construida procedural con voxels. No hay sistema modular, ni progresión, ni activadores.

## Archivos a crear (implementación futura)

| Archivo | Contenido | Prioridad |
|---|---|---|
| `scripts/ruinas/ruin_piece.gd` | `class_name RuinPiece` — Resource: pivot, snaps, bbox, grupo, LODs | Alta |
| `scripts/ruinas/ruin_catalog.gd` | `class_name RuinCatalog` — Catálogo de ≤40 piezas (Array de RuinPiece) | Alta |
| `scripts/ruinas/ruin_assembler.gd` | `class_name RuinAssembler` — Ensambla 13 tipos desde el kit | Alta |
| `scripts/ruinas/ruin_progresion.gd` | `class_name RuinaProgresion` — 4 estados + transiciones + eventos | Alta |
| `scripts/ruinas/validar_kit.gd` | Validación en Editor: pivots, snaps, traslapes | Alta |
| `scripts/ruinas/activadores/activador_palanca.gd` | Palanca (cerrojo de puerta) | Media |
| `scripts/ruinas/activadores/activador_anillo.gd` | Anillo giratorio (sello de cámara) | Media |
| `scripts/ruinas/activadores/activador_estrella.gd` | Estrella giradora (puerta de templo) | Media |
| `scripts/ruinas/activadores/activador_llave_runa.gd` | Llave-runa (inscripción que bebe glifo) | Media |
| `scripts/ruinas/activadores/activador_timon_agua.gd` | Timón de agua (compuertas) | Media |
| `scripts/ruinas/activadores/activador_martillo.gd` | Martillo de piedra (percutir pedestal) | Media |
| `scripts/ruinas/activadores/activador_vela_triple.gd` | Vela triple (encender 3 velas en orden) | Media |
| `scripts/ruinas/activadores/activador_puerta_falsa.gd` | Puerta falsa (rodar a cámara) | Media |
| `data/ruinas/piezas_kit.json` | Catálogo JSON de las 40 piezas | Alta |
| `data/ruinas/ruinas.json` | Datos de cada ruina (tipo, puzzles, conexiones) | Media |
| `data/ruinas/murales.json` | 12 murales (época, tema, ubicación) | Baja |
| `data/ruinas/glifos.json` | 30-60 glifos (símbolos, significado) | Baja |
| `data/ruinas/objetos_arqueologicos.json` | 25 objetos (época, riqueza, ubicación) | Baja |

## API clave (GDScript)

```gdscript
# ruin_piece.gd
class_name RuinPiece
extends Resource

@export var nombre: String
@export var pivot: Vector3
@export var snaps: Dictionary  # { "norte": Vector3i, "sur": Vector3i, ... }
@export var bbox: AABB
@export var grupo: String
@export var lod0_mesh: Mesh
@export var lod1_mesh: Mesh
@export var lod2_mesh: Mesh

# ruin_progresion.gd
class_name RuinaProgresion
extends Node

enum Estado { NO_DESCUBIERTA, DESCUBIERTA, EXPLORADA, COMPLETADA }

signal estado_cambiado(ruina_id: String, nuevo_estado: Estado)

func verificar_descubrimiento(distancia: float) -> void
func verificar_exploracion(puzzles_resueltos: int, puzzles_total: int) -> void
func verificar_completado(puzzles_resueltos: int, puzzles_total: int, relicto_guardado: bool) -> void

# ruin_assembler.gd
class_name RuinAssembler
extends Node

func ensamblar(tipo: String, posicion: Vector3, seed: int) -> Node3D
func validar_kit() -> Array[String]  # retorna errores (vacío = OK)
```

## Reglas de implementación (para quien concrete)

1. Kit ≤ 40 piezas; cada pieza con `RuinPiece` (pivote + snaps); la validación en Editor falla → no build.
2. Los datos de cada ruina viven en JSON (`data/ruinas/`); los scripts solo interpretan.
3. Progresión con eventos (diario, mapa M58, museo M36, guardado atómico); cero Update por ruina.
4. Activadores implementan el contrato del framework M24 (son Emisores/Reglas en datos).
5. No tocar M45/M47 (assets visuales) ni M26 (templo subterráneo).
6. Integración con M66 (objetos únicos al cofre) y M28 (caminos) vía nodos.
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 25 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18
**Estado:** Documentación expandida + arquitectura GDScript corregida

- Expandido 03-Diseno.md con: kit modular detallado (40 piezas), 8 activadores con scripts, progresión con código, murales/glifos/objetos, paletas visuales.
- Corregido 04-Codigo.md: eliminada arquitectura C# heredada (Unity), reemplazada por GDScript (Godot 4.x).
- Agregados archivos existentes (generador_ruina.gd, preview_ruina.gd) y archivos a crear.
- El módulo tiene documentación completa pero implementación mínima (1 ruina chozavil procedural).
- Al implementar, actualizar fila 25 del CHECKLIST-GLOBAL y crear el Log correspondiente.