**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 17: Construcción

Nota: rutas propuestas (prefijo `res://src/` acorde al stack Godot 4.x + GDScript del proyecto). El nombre exacto de las rutas lo confirma el agente de implementación al consolidar M08.

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/construccion/build_manager.gd` | Autoload | Sesión de construcción: entrada/salida de modo, orquestación, señales, pila de acción |
| `res://src/construccion/build_preview.gd` | Componente | Raycast del cursor, conversión a celda voxel (rejilla 1 m, planta), rotación y elevación |
| `res://src/construccion/build_validator.gd` | Clase estática | Única autoridad "puede colocar": zonas, ocupación, soporte, reglas de pieza, costos |
| `res://src/construccion/build_ghost.gd` | Nodo visual | Fantasma semi-transparente (verde/rojo) con pooling, sigue al cursor |
| `res://src/construccion/build_history.gd` | Componente | Pila undo/redo con deltas exactos (celdas + recursos) |
| `res://src/construccion/zone_registry.gd` | Autoload data | Regiones AABB de zonas (edificable/protegida/narrativa/agua) consultada por el validador |
| `res://src/construccion/build_catalog_db.gd` | Autoload data | Catálogo de piezas por modo (construcción/decoración) y desbloqueos |
| `res://src/construccion/placement_rule.gd` | Resource | Datos declarativos por pieza (tamaño, regla, costo, devolución, mesh) |
| `res://data/construccion/piezas/*.tres` | Data | Recetas del catálogo (paredes, pisos, techos, puertas, ventanas, escaleras, puentes, caminos, cercas, faroles, muebles, decoración) |
| `res://src/construccion/build_interaction.gd` | Componente | Punto de interacción en piezas funcionales (camas, almacenamiento M18) |
| `res://src/construccion/modo_construccion.gd` | Enum/Util | Tipos de modo: CONSTRUCCION, DECORACION |

## 2. Funciones clave (firmas GDScript)

```
## BuildManager (autoload)
func entrar_modo(modo: ModoConstruccion) -> void
func salir_modo() -> void
func esta_en_modo() -> bool
func seleccionar_pieza(receta: PlacementRule) -> void
func confirmar_colocacion() -> Dictionary
func demolir_pieza(celda: Vector3i) -> Dictionary
func mover_pieza(origen: Vector3i, destino: Vector3i) -> Dictionary
func copiar_pieza(celda: Vector3i) -> void
func almacenar_pieza(celda: Vector3i) -> Dictionary
func undo() -> void
func redo() -> void
func pieza_en_celda(celda: Vector3i) -> Dictionary    # {receta, rotacion} o vacío

## BuildPreview
func celda_bajo_cursor() -> Vector3i
func set_planta(planta: int) -> void
func rotar_paso() -> void
func rotacion_actual() -> int

## BuildValidator (estáticas)
static func validar(receta: PlacementRule, celda: Vector3i, rotacion: int) -> Dictionary
static func celda_ocupada(celda: Vector3i) -> bool
static func tiene_soporte(receta: PlacementRule, celda: Vector3i) -> bool
static func dentro_de_zona(celda: Vector3i, permiso: StringName) -> bool
static func hay_npc_en_celda(celda: Vector3i) -> bool
static func puede_pagar(receta: PlacementRule) -> bool

## BuildGhost
func recargar(receta: PlacementRule) -> void
func actualizar_estado(resultado: Dictionary) -> void
func posicionar(celda: Vector3i, rotacion: int) -> void
func al_pool() -> void

## BuildHistory
func registrar(delta: Dictionary) -> void      # {tipo, receta, celdas[], rotacion, costo}
func undo_ultimo() -> Dictionary
func redo_siguiente() -> Dictionary
func limpiar() -> void

## ZoneRegistry (data via M08)
func zona_de(celda: Vector3i) -> StringName
func permitido(permiso: StringName, celda: Vector3i) -> bool
func registrar_zona(aabb: AABB, permiso: StringName) -> void
```

## 3. Suscripciones e integración

- M08: `VoxelWorld.escribir_celdas(celdas, bloque)` con marca dirty de chunk; lee datos de ocupación del mapa de piezas en memoria (rápido) + consulta voxel en bordes.
- M14: `Inventario.consultar(costo)` antes y `Inventario.descontar(costo)` al confirmar; `Inventario.devolver(item_id, cantidad)` en demolición/almacenamiento.
- M64: `obra_activa(activa)` y `navmesh_delta(celdas)` para re-planificación de NPC; el validador consulta ocupación de NPCs activos.
- M58: `ConstruccionData` serializa `Array[Dictionary] {receta_id, celda, rotacion}`; restauración idempotente (limpia celdas de pieza previas antes de reescribir).
- M31: luces de pieza (faroles) conectadas al ciclo día/noche (`dia_cambio`, `noche_cambio`).
- M73: `recargas_festival()` agrega recetas de evento temporales al catálogo.
- UI: la capa UI (Canvas) escucha señales de `BuildManager`; no se acopla ninguna lógica de colocación en los scripts de UI.

## 4. Logs relacionados

- `Logs/` del proyecto conforme a la sección 6 de AGENTS.md (numeración secuencial NN-...) para cada implementación de este módulo.
- Logs de runtime (debug): `[BUILD]` para confirmar/demoler/mover/undo con receta + celda + delta de recursos.
- Diagnósticos de rechazo (válidos para QA): `[BUILD][VALIDACION] motivo` al bloquear una colocación (zona, soporte, ocupado, NPC, recursos).
- Referencias cruzadas: módulo M111 (calidad de código), M113 (profiler para presupuesto de preview <= 1 ms), M112 (stress con muchas construcciones).

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Documentación de diseño completa (plan-inicial). Implementación pendiente (requiere M08 y M14 estables).

### Lo que hice
- Documentación completa del módulo 17: requerimientos (RF1-RF14), análisis de alternativas y decisiones (rejilla 1 m + piezas modulares, validación declarativa, undo por deltas, dirty flags), diseño (BuildManager, BuildPreview, BuildValidator, BuildGhost, PlacementRule, BuildHistory, ZoneRegistry), código propuesto y checklist de 174 ítems.
- Resolví los 28 puntos de la sección 16 del plan maestro (CONSTRUCCIÓN) sobre rejilla voxel alineada a M08.

### Lo que NO hice (honestidad obligatoria)
- Implementación: pendiente hasta que M08 (escritura voxel + dirty flags) y M14 (inventario) estén disponibles y estables.
- Las rutas `res://src/construccion/` son propuestas de diseño; deben confirmarse al consolidar la estructura del proyecto Godot (M07 arquitectura).
- El balance de costos de piezas queda delegado a M92.

### Recomendaciones para el próximo agente
- Implementar primero BuildValidator (es la pieza crítica): sin él nada se coloca con seguridad.
- Prototipar con 3 piezas (pared, piso, techo) antes de crear las 12 familias; validar la rejilla 1 m contra el mesh de M08 en una escena de prueba.
- Conectar la señal `obra_activa` con M64 al inicio para detectar bloqueos de rutas temprano.
- Especificar los datos voxel de pieza en capa separada del terreno generado para que M08 pueda restaurar el terreno al demoler.