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

## Notas del Agente — iter. 3 (implementación real)

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-04
**Log:** 1244

Las rutas REALES de la implementación viven en `res://scripts/construccion/` (no
`res://src/`, que era la propuesta de diseño). Archivos agregados en iter. 3:

| Archivo | Tipo | Rol |
|---|---|---|
| `res://scripts/construccion/build_hud.gd` | Modelo puro | `BuildHudModel`: filas de costo y motivos de rechazo traducidos para el HUD (la capa UI es M18) |
| `res://scripts/construccion/zonas_permisos.gd` | Política pura | `ZonasPermisos`: presets de permiso M18/M25 (casa del jugador, parcelas NPC, ruinas) y traducción a motivo |

Cambios en archivos existentes:
- `placement_rule.gd`: nuevo campo `@export var mesh_path: String` (round-trip en `desde_dict`/`a_dict`).
- `build_ghost.gd`: `resolver_malla()`/`malla_desde_ruta()`/`cargar_malla()` (MESH REAL de la receta, con caja de respaldo), `seguir()`/`seguir_celda()`/`destino_de()` (FOLLOW con lerp, sin sobrepasar) y `actualizar_visibilidad()`/`debe_ocultarse()` (AUTO-OCULTADO fuera de zona).
- `data/construccion/piezas/*.tres`: 30 recetas declaran `mesh_path` hacia `assets/3d/alta/`.
- Suite `res://scripts/construccion/test_construccion_iter3.gd` (138 checks, 9 bloques `_fin`).

## Notas del Agente — iter. 4: edge cases de la sección L

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Log:** 1684

Pedido del director (msg 140). Tres edge cases del núcleo, todos con suite propia:

| Requisito | Implementación | Archivo |
|---|---|---|
| L187 rechazo temporal por NPC | `MOTIVOS_TEMPORALES` + `es_temporal()`; `resultado_fallo()` expone `"temporal"`; `BuildHudModel.linea_estado()` añade "(temporal: probá de nuevo)" | `construccion_tipos.gd`, `build_hud.gd` |
| L194 límite del mundo | `set_limite_mundo(AABB)` / `_limite_mundo`; `ConstruccionValidator.fuera_del_mundo(celdas, ctx)` + motivo `FUERA_DEL_MUNDO`; ORDEN gana "mundo" | `build_manager.gd`, `construccion_validator.gd` |
| L196 doble confirmación | cooldown de 250 ms por celda en `confirmar_colocacion()`, motivo `DOBLE_CONFIRMACION`, evaluado DESPUÉS de validar y reseteado en `limpiar_estructuras()` | `build_manager.gd` |

Suite nueva: `res://scripts/construccion/test_construccion_iter4.gd` (45 checks, 4 bloques).
Las 4 suites de M17: **413 checks, 0 fallos**.

**Regresión encontrada y corregida:** el estado del cooldown sobrevivía a
`limpiar_estructuras()`, así que la primera pieza tras un reset podía quedar
bloqueada por un click viejo (rompía 20 checks de `test_construccion.gd`). Ahora se
reinicia junto con el estado de sesión.


## Notas del Agente — iter. 5: edge cases restantes (sección L)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Log:** 1687

| Requisito | Implementación | Archivo |
|---|---|---|
| L197 demolición ordenada | `piezas_apoyadas_en(ancla)` + motivo `SOSTIENE_OTRA_PIEZA` (permanente); rechaza nombrar la pieza de arriba para que el jugador demuela de arriba hacia abajo | `build_manager.gd`, `construccion_tipos.gd` |
| L192 fantasma al pool | `conectar_fantasma()` / `fantasma()`; `salir_modo()` llama `devolve_al_pool()` | `build_manager.gd` |
| L193 guardado a mitad de colocación | el fantasma es estado de UI: `obtener_estructuras()` / save solo ven `_estructuras`; verificado por round-trip | `build_manager.gd`, suite iter5 bloque 3 |

Suite nueva: `res://scripts/construccion/test_construccion_iter5.gd` (39 checks, 4 bloques).
Las 5 suites de M17: **452 checks, 0 fallos**.

**Bug latente corregido:** `BuildGhost.ocultar()` no limpiaba `_receta_id`, así que un
fantasma devuelto al pool seguía reportando la receta anterior (la UI podía mostrar
datos obsoletos al reutilizarlo). Ahora el fantasma ocioso queda sin pieza.

**Error propio corregido durante la sesión:** el script de flips usaba el fragmento
`"Demolici"` y marcó el ítem equivocado (L114, "ventana de confirmación", que sigue
`[ ]`). Revertido y re-aplicado sobre el ítem correcto (L197). Sirve de recordatorio:
los anclajes de flip deben ser únicos y específicos, no prefijos.


## Notas del Agente — iter. 6: garantías de integración (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1703

Encargo del director (msg 154): integraciones de M17 con hooks listos. De los ítems
de la sección K y M, 4 se pudieron **verificar** (no implementar: ya estaban) con la
suite nueva `test_construccion_iter6.gd` (23 checks, 0 fallos):

| Item | Evidencia |
|---|---|
| K181 (M71) | `pieza_colocada(receta_id, celda)` y `pieza_demolida(receta_id, celda)` emiten con argumentos útiles; `navmesh_delta` trae las celdas tocadas al colocar y al demoler |
| K180 (M32) | Cero suscripciones a clima en `scripts/construccion/` (ni `clima_cambio`, ni `weather`, ni `tormenta`) y el manager no expone ninguna API de clima: la lluvia agrega VFX desde M32 y **no** puede tocar las piezas |
| M201 (dirty flags) | `escribir_voxel`/`borrar_voxel` escriben **por celdas puntuales**: colocar 2 piezas en celdas distintas escribe exactamente 2 celdas, ni una más |
| M202 (sin regeneración global) | Ninguna llamada a `regenerate(`/`rebuild(`/`remesh(`/`regenerar(` en el módulo; el terrain espía no recibió ninguna regeneración |

Falso positivo corregido en el propio test: mi primer chequeo de "regenerar" matcheaba
el **parámetro** `regenerar_id` de `ConstruccionTipos.resultado_ok()`. Se endureció
exigiendo la llamada con paréntesis.

### ⚠️ Colisión con otro agente (reportada al director)

`test_construccion_iter2.gd` y `test_construccion_iter3.gd` **no compilan** desde que
otro agente (M166, "capa B" de assets) agregó `AssetProfile.ruta(...)` en
`build_ghost.gd:96` sin definir la clase `AssetProfile` en el repo. Mis suites
(`iter1` e `iter6`) compilan y pasan. La rotura es del trabajo en vuelo de M166.

## Notas del Agente — F1 retractado + M17 reparado (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1712

### Encargo F1 (msg 159) retractado por el estratega (msg 160)

El estratega anuló el encargo F1: Hy3 lo había cerrado antes de quedarse sin tokens
(Log 1681), s2 lo verificó y el director selló **M166 112/112**. **Nada que revertir de mi
parte**: verifiqué que `asset_profile.gd` (tabla de hardware + `ruta()` + degradación) y el
campo `variantes_disponibles` de `placement_rule.gd` ya existían, así que no escribí
código de F1.

### Lo que SÍ quedó (todo en M17, mi módulo)

| Cambio | Por qué |
|---|---|
| `build_ghost.gd`: `AssetProfile.ruta(...)` por identificador → `get_node_or_null("/root/AssetProfile")` con fallback | El identificador de un autoload **no compila** bajo `--script` (lección E-27/E-28/E-29). Rompía `iter2`/`iter3` |
| `muelle_madera.tres`: `sobre_agua`, `superficie_ok=[agua]`, `soportes_minimos=0` | La receta nueva (tanda de héroes) tenía familia `puente` sin cumplir el invariante del catálogo |
| `test_construccion_iter2.gd`: esperados 36 → **46** recetas | El catálogo creció con 10 recetas de héroes |
| `test_construccion_iter3.gd`: acepta `mesh_path` en forma base (`x.glb`) | `alfombra.tres` usa la forma base que resuelve `AssetProfile.ruta()` |

### Estado de suites

Las 6 suites de M17 quedan en verde, corridas una por una:

```
test_construccion.gd        131 checks, 0 fallos
test_construccion_iter2.gd   99 checks, 0 fallos
test_construccion_iter3.gd  138 checks, 0 fallos
test_construccion_iter4.gd   45 checks, 0 fallos
test_construccion_iter5.gd   39 checks, 0 fallos
test_construccion_iter6.gd   22 checks, 0 fallos
                             ---
                             474 checks, 0 fallos
```

## Notas del Agente — iter. 7: utilidades de rejilla + copiar pieza (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1732

Encargo del director (msg 179): barrido de M17. **M17: 76 -> 80 `[x]` / 175 (+4).**

### Nuevo: utilidad compartida de conversión (D83/D86/D88)

`ConstruccionMundo` (estáticas, usables desde preview, fantasma y datos sin instancia):

```gdscript
const OFFSET_MEDIO_VOXEL: float = 0.5
static func mundo_desde_celda(celda: Vector3i) -> Vector3   # centro = celda + 0.5
static func celda_desde_mundo(pos: Vector3) -> Vector3i     # floor en los 3 ejes
static func esquina_desde_celda(celda: Vector3i) -> Vector3 # para AABB exactos
```

Convención documentada: la celda (x,y,z) ocupa el cubo [x,x+1)×[y,y+1)×[z,z+1), así que su
centro está en (x+0.5, y+0.5, z+0.5) — el offset de medio voxel aplicado una sola vez y en un
solo lugar (antes cada consumidor podía tener su propia fórmula).

### Nuevo: `copiar_pieza()` (F110/F112)

`BuildManager.copiar_pieza(origen, destino)`:

- **Conserva la rotación** de la pieza original (F110).
- **No desocupa el origen** (a diferencia de `mover_pieza`).
- Se **cobrara como colocación nueva** (F112: la copia gasta materiales).
- Rechaza con motivo claro: `NO_HAY_PIEZA` (origen vacío), `CELDA_OCUPADA` (destino tomado),
  `RECURSOS_INSUFICIENTES`, y si el destino no valida, el motivo real del validador.
- Registra `BuildHistory.TIPO_COPIAR` (nuevo) para que el undo/redo funcione.

### Suite

`scripts/construccion/test_construccion_iter7.gd` — **25 checks, 0 fallos** (2 bloques:
utilidades + copiar). Regresión verificada sin cambios en `test_construccion.gd`,
`test_construccion_iter2.gd` y `test_construccion_iter6.gd`.

### Nota de depuración (3 errores propios)

1. `ConstruccionMundo.new()` **vacío no reporta superficie**: sin terrain conectado toda celda
   queda "en el aire" y la colocación se rechaza con `SIN_SOPORTE`. Hizo falta un `MundoPlano`
   falso que sí reporte `superficie_voxel`.
2. El inventario falso arrancaba con 0 stones, así que ni la pieza original se podía colocar.
3. La expectativa de costo estaba mal por dos motivos: la copia se suma a la colocación original
   (20 - 4 - 4 = 12, no 16).

## Notas del Agente — auditoria de la seccion K (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1745

Continuacion del barrido de M17. Esta vuelta audite la **seccion K** (Integracion)
item por item contra el codigo. **M17: 80 -> 81 `[x]` / 175 (+1).**

### Lo que SI tiene respaldo

| Item | Evidencia |
|---|---|
| M14: descuento y devolucion | `conectar_inventario(inv)` + `_invertir()` con duck-typing; bloques 8-10 de `test_construccion.gd` prueban costo real, devolucion del 50 % al demoler y re-cobro al deshacer |

El item se cerro aclarando que el **almacenamiento** de piezas como items es de M14
(limite documentado), no de M17.

### Lo que NO existe (los 6 restantes quedan `[ ]`)

| Item | Estado real |
|---|---|
| M08: datos de pieza en capa voxel separada | `construccion_mundo.gd` escribe en `VoxelBuffer.CHANNEL_TYPE`, el **mismo canal** del terreno (no hay capa propia) |
| M18: ampliaciones usan proyectos de piezas | no hay contrato ni API de proyectos |
| M25: ruinas como solo visual | el campo `deconstruible` existe y se serializa, pero **ninguna de las 33 recetas** del catalogo lo usa |
| M73: recetas de festival con `devolucion = 0` | no hay recetas de festival |
| M31: faroles conectados al ciclo dia-noche | 0 referencias a `DayNightCycle`, `GameTime` o `franja` en `scripts/construccion/` |
| M93: proyectos de meta larga | no hay contador de piezas por meta |

### Consecuencia

La seccion K esta practicamente cerrada en lo que M17 puede hacer solo: los 6 items
restantes son trabajo de otros modulos (M08, M18, M25, M31, M73, M93).

### Suites

```
test_construccion.gd         131 checks, 0 fallos
test_construccion_iter2.gd    99 checks, 0 fallos
test_construccion_iter6.gd    22 checks, 0 fallos
test_construccion_iter7.gd    25 checks, 0 fallos
```
