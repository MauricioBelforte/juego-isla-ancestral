**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 17: Construcción

## 1. Arquitectura

```
                    BuildManager.gd (autoload, única autoridad de sesión)
   ┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
   ▼                  ▼                  ▼                  ▼                  ▼
BuildPreview      BuildValidator     BuildGhost        BuildHistory      CatalogDB
(raycast, celda,  (reglas + zonas +  (visual fantasma, (pila undo/redo,  (piezas .tres,
 estado UI)        costos M14)        pooling)          deltas)           recetas)
   │                  │                  │                  │                  │
   └──────────┬───────┴─────────┬────────┴──────────────────┴──────────────────┘
              ▼                 ▼
        VoxelWorld (M08)   Inventario (M14)
        writes + dirty      descuentos y
        flags por chunk     devoluciones
              │
              ▼
        Señales: obra_activa(npc), pieza_colocada, navmesh_delta (M64)
```

Separación de responsabilidades: `BuildManager` no conoce UI (emite señales; la capa UI/M18 consume). `BuildValidator` es la única autoridad "puede colocar". `BuildGhost` es puramente visual. `PlacementRule` son datos declarativos por pieza.

## 2. Diagrama de flujo del modo construcción

```
Abrir modo (herramienta/tecla) 
   → BuildManager.entrar_modo()
       → se suspende input de movimiento del jugador
       → se instancia BuildGhost (pooled) + HUD (capa UI)
       → señal obra_activa(true) → M64 (NPC curiosos, evitan zona)
Seleccionar pieza (catálogo) → pieza_actual = receta.tres + fantasma.recargar()
Apunticar célula: raycast → BuildPreview.calcular_celda() (snap 1m, planta)
   → BuildValidator.validar(pieza, celda, rotacion)
       → [ocupada? | soporte? | regla pieza? | zona? | recursos M14? | NPC?]
       → resultado {ok, motivos[]}
   → BuildGhost.set_color(ok) + HUD muestra motivo de error
Rotar/elevar (teclas) → revalidar con nuevo estado
Confirmar (click) 
   → BuildManager.confirmar_colocacion()
       → Inventario.descontar(costo)      (M14)
       → VoxelWorld.escribir_pieza(celdas, bloque, chunk meta)
       → BuildHistory.push(delta)          (para undo)
       → señal pieza_colocada(pieza)
Salir (tecla) → BuildGhost devuelto al pool → señal obra_activa(false)
Demoler: seleccionar pieza colocada → confirmar → delta de demolición
   → devolución parcial (Inventario.devolver) → undo disponible
```

## 3. Clases principales

| Clase | Tipo | Responsabilidad |
|---|---|---|
| `BuildManager` | Autoload | Sesión de construcción, entrada/salida, orquesta validación-colocación, emite señales, pila de acción actual |
| `BuildPreview` | Componente | Raycast, conversión cursor → celda voxel (snap 1 m, planta), límites de mundo |
| `BuildValidator` | Util/estático | Aplica zonas + reglas + ocupación + soporte + costos; única fuente "puede colocar" |
| `BuildGhost` | Nodo visual | Malla fantasma semi-transparente (verde/rojo), pooling al entrar/salir, sigue al cursor con suavizado |
| `PlacementRule` | Resource `.tres` | Regla declarativa por pieza: tipo, tamaño (celdas), soporte requerido, restricción de superficie, devolución, costo |
| `BuildHistory` | Componente | Pila de deltas (colocar/demoler/mover) con undo/redo exacto, incluye recursos |
| `ZoneRegistry` | Autoload M08/M17 | Regiones AABB en celdas voxel con permiso (edificable/protegida/narrativa/agua) |
| `BuildCatalogDB` | Autoload data | Catálogo de piezas (recetas .tres) filtrado por modo construcción/decoración y desbloqueos (M70/M93) |

## 4. Contrato de API (GDScript)

```
BuildManager (autoload):
  func entrar_modo(modo: ModoConstruccion) -> void
  func salir_modo() -> void
  func esta_en_modo() -> bool
  func seleccionar_pieza(receta: PlacementRule) -> void
  func confirmar_colocacion() -> Result  # -> {ok, motivos, delta}
  func demolir_pieza(celda: Vector3i) -> Result
  func mover_pieza(origen: Vector3i, destino: Vector3i) -> Result
  func copiar_pieza(celda: Vector3i) -> void
  func almacenar_pieza(celda: Vector3i) -> Result
  func undo() -> void
  func redo() -> void
  signal obra_activa(activa: bool)
  signal pieza_colocada(receta: PlacementRule, celda: Vector3i)
  signal zona_rechazada(celda: Vector3i, motivo: String)

BuildValidator (clase estática):
  func validar(receta: PlacementRule, celda: Vector3i, rotacion: int) -> Dictionary
  func celda_ocupada(celda: Vector3i) -> bool
  func tiene_soporte(receta: PlacementRule, celda: Vector3i) -> bool
  func dentro_de_zona(celda: Vector3i, permiso: TipoPermiso) -> bool
  func hay_npc_en(celda: Vector3i) -> bool
  func puede_pagar(receta: PlacementRule) -> bool   # consulta M14

BuildPreview:
  func celda_bajo_cursor() -> Vector3i
  func elevar(plantas: int) -> void
  func rotar(direccion: int) -> void    # 0..3 (90°)
  func celda_valida_en_mundo(celda: Vector3i) -> bool

BuildGhost:
  func recargar(receta: PlacementRule) -> void
  func set_color(valido: bool) -> void
  func posicionar(celda: Vector3i) -> void
  func volver_al_pool() -> void

PlacementRule (Resource):
  @export var id: StringName
  @export var nombre: String
  @export var tamano: Vector2i          # celdas ocupadas (1x1, 1x2, 3x1...)
  @export var altura: float = 1.0
  @export var requiere_soporte: bool = true
  @export var superficie_ok: Array[VoxelType] = [TERRENO, PISO, TECHO]
  @export var sobre_agua: bool = false  # puentes exclusivamente
  @export var requiere_pared: bool = false  # puertas/ventanas
  @export var deconstruible: bool = true
  @export var devolucion: float = 0.5
  @export var costo: Dictionary         # {item_id: cantidad} → M14
  @export var mesh: PackedScene
  @export var es_mueble: bool = false   # modo decoración
```

## 5. Reglas de validación (orden de aplicación en BuildValidator)

1. **Zona (ZoneRegistry):** la celda completa de la pieza debe estar en zona edificable; agua solo si `sobre_agua`; zonas protegidas (parcelas NPC, ruinas M25) → rechazo con motivo.
2. **Ocupación:** ninguna celda de la pieza (considerando rotación) ocupada por otra pieza del jugador ni por bloques no triturables de M08 (roca/violación del terreno solo vía herramienta M13).
3. **Soporte:** al menos una celda de la base apoya en superficie permitida (terreno/piso/techo); escaleras apoyan en pared contigua; techos exigen 2+ soportes.
4. **Regla específica (PlacementRule):** puerta/ventana requieren pared contigua; fuentes solo sobre piso; faroles sobre cualquier pieza.
5. **NPC y rutas (M64):** si la celda intercepta un NPC activo → rechazo temporal ("NPC en el lugar"); si bloquea la única ruta caminable de un vecino → aviso de "obra" y M64 recalcula ruta (las puertas siempre dejan hueco navegable).
6. **Recursos (M14):** verificación de `puede_pagar` durante la preview (fantasma rojo con motivo "recursos insuficientes"); descuento solo al confirmar.

## 6. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M08 Mundo Voxel | Escrituras `VoxelBuffer` por celdas de pieza; `VoxelViewer` marcado dirty por chunk; datos voxel de pieza en capa separada (no confundir con terreno generado); navmesh delta emitida |
| M14 Inventario | `Inventario.descontar(costo)` al confirmar; `devolver(item_id, cantidad)` al demoler/almacenar; agrupar stacks |
| M18 Casas | Las ampliaciones de la casa del jugador se modelan como proyectos de piezas (paredes, planta, techo); interiores usan el modo decoración |
| M25 Ruinas (solo visual) | Piezas `deconstruible = false`; se inspeccionan/copian visualmente; nunca se modifican (zona protegida) |
| M64 IA de NPC | `obra_activa(true)` → curiosidad y desvío; `navmesh_delta` → re-planificación; las obras nunca encierran a un NPC |
| M58 Guardado | Lista de piezas `{receta_id, celda, rotacion}` + costos descontados; restauración idempotente (limpiar celdas antes de reescribir) |
| M31/M32 Tiempo/clima | Luces de faroles siguen el ciclo M31; la lluvia (M32) no afecta las piezas (solo VFX); reacciones visuales cozy |
| M73 Festival de construcción | Recetas de evento con `devolucion = 0`; el festival premia proyectos (M93) |
| M92 Balance / M93 Progresión | Costos por receta balanceados en M92; desbloqueos de piezas viven en progresión M70/M93 (proyectos de construcción de meta larga) |
| M71 Logros | Logros de construcción (primera casa, N piezas, villa decorada) escuchan `pieza_colocada` |

## 7. Optimización (M61/M111)

- Dirty flags por chunk: al escribir una pieza se marcan solo los chunks tocados; la regeneración de mesh la orquesta M08; jamás full-regen.
- BuildGhost con pooling (una sola instancia reutilizada; ningún alloc en el tick de preview).
- Raycast de colocación limitado a 1 por frame con cache de celda (si el cursor no se mueve, no re-valida).
- Validación en O(n) por pieza (n = celdas de la pieza, máx. 8); ocupación consultada como mapa de celdas en memoria + lectura de datos voxel M08 solo en bordes.
- LOD del fantasma por distancia; piezas estáticas unen meshes no dinámicos (static batching de Godot).
- Límite suave de piezas por zona (configurable) con aviso, protege M112 (muchas construcciones).

## 8. QA

- Unit tests (GUT/vía C# si corresponde): BuildValidator con casos límite (aire, fuera de zona, NPC encima, recursos insuficientes, rotación que invade).
- Integración: colocar→guardar→cargar→restaurar idéntico; undo de demolir devuelve recursos exactos.
- Stress M112: 200+ piezas en una zona con profiler (frame time y memoria).
- Recorrido M114: construir una casa completa (M18) sin errores de consola, sin NPC atrapados.