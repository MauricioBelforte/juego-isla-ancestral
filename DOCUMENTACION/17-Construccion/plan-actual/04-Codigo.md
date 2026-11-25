**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

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

## LO QUE QUEDA ABIERTO (y por que) — Log 2109, 2026-07-22

Con los checks **nombrados** de las 7 suites de M17 (496 checks, auditables uno a uno) se cerraron 2 items mas
(P7 copia, P11 demolicion). Los que siguen abiertos NO se cierran porque **falta una parte concreta**, no
porque no se haya buscado:

| Item | Parte que falta | Por que no se cierra |
|---|---|---|
| P6 elevacion | "altura maxima por zona" | hay planta (set_planta/planta_actual, la clave "planta" del codec, "refleja la elevacion: y = celda.y + altura/2") pero **no hay check de altura maxima por zona** |
| P16 restricciones | "alturas" | hay topes por zona ("3/3 piezas -> LIMITE_DE_ZONA") y parcelas ajenas ("parcela NPC -> PROTEGIDA", "dentro de la parcela NPC: NO edificable") pero **el validador no tiene regla de alturas** (`ConstruccionValidator.ORDEN` son 8 reglas y ninguna es de altura) |
| P10 almacenamiento | "sin perdidas" | el contrato real es devolucion 50% ("devolucion 50% redondea hacia abajo (madera 5->2, piedra 3->1)") con re-cobro en undo ("undo re-cobro la devolucion: 8-2=6"): el item dice "sin perdidas" y eso **no** es lo que hace el codigo |
| P21 ventanas | "transparentes a la luz (M48)" | solo hay "toda puerta/ventana exige pared contigua": la transparencia a la luz es de M48 (no M17) |
| P22 escaleras | todo | 0 checks con "escalera": la escalera no tiene suite |
| P23 puentes | "losa 1-4 celdas" | hay "puente sobre AGUA con sobre_agua -> ok" / "puente sobre tierra firme -> FUERA_DE_ZONA" / "todo puente: sobre_agua + superficie 'agua' + 0 soportes" / "familia 'puente' tiene 5 recetas" pero **no se pudo verificar el rango de tamanos 1-4**: el catalogo no esta en `data/construccion/piezas/` (la ruta que citan los tests no existe en disco) |
| P27 muebles | "interaccion M18" | hay "modo DECORACION ve 21 muebles" / "todo lo del modo decoracion es es_mueble" / "refleja las 2 celdas de la cama" pero la interaccion con M18 no tiene check |
| P15 colisiones | "colision estatica real" | el validator es **logico**, no fisico: no hay colisiones reales |
| A. Requisitos (12) | redaccion | son items de documentacion del modulo (problema, dependencias, RF1..RF14): son del dueno del modulo, no se autocierran |
| C. Modo construccion | UI + mundo | requieren HUD y viewport: fuera del riel headless |

## 7. Tanda P3-3 — Reglas declarativas por pieza contra el catálogo real (Log 2220, 2026-10-27 21:40)

**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

### 7.1 Qué se añadió

Suite NUEVA en el runner central: **`res://tests/test_m17_reglas_pieza.gd`** → **40 checks, 0 fallos,
EXIT 0** (Godot 4.7.2 headless). Cableada en `.github/workflows/quality.yml` (job `test-suite`, lane
M17) junto a las 3 suites de `scripts/construccion/` que ya corrían en CI.

El motivo: el validador de M17 es **declarativo** (lee `PlacementRule`), y las suites que ya existían
probaban las REGLAS con recetas sintéticas. Esta suite prueba las reglas contra el **catálogo real**
(`res://data/construccion/piezas/`, 46 recetas `.tres` cargadas por `BuildCatalogDB`), que es donde
vive el dato que el jugador realmente toca.

### 7.2 Checks por item cerrado (texto literal de los checks)

| Item | Checks | Evidencia |
|---|---|---|
| **G137** Puerta exige pared contigua | 7 | "receta puerta 'puerta_madera' tiene requiere_pared == true" · "receta puerta 'puerta_piedra' tiene requiere_pared == true" · "puerta 'puerta_madera' SIN pared contigua -> REQUIERE_PARED" · "puerta 'puerta_madera' CON pared contigua -> sin REQUIERE_PARED" (idem `puerta_piedra`) |
| **G138** Ventana exige pared contigua de al menos 1 celda | 7 | "receta ventana 'ventana_marco' tiene requiere_pared == true" · "receta ventana 'ventana_arco' tiene requiere_pared == true" · "ventana 'ventana_marco' SIN pared contigua -> REQUIERE_PARED" · "ventana 'ventana_marco' CON pared contigua -> sin REQUIERE_PARED" (idem `ventana_arco`; con **una sola** celda contigua `pared`) |
| **G141** Camino solo sobre césped/arena | 13 | "camino 'camino_cesped' superficie_ok == ['terreno'] (sin piso/techo/pared/agua/aire)" (idem `camino_arena`, `camino_piedra`) · "camino 'camino_cesped' sobre 'roca' (fuera de superficie_ok) -> SIN_SOPORTE" · "camino 'camino_cesped' sobre 'terreno' (en superficie_ok) -> ok" |
| **G145** Ruina M25 / parcela NPC no colocables ni demolidas | 8 | "preset PARCELA_NPC == PROTEGIDA" · "preset RUINA == PROTEGIDA" · "zona PROTEGIDA -> ZONA_PROTEGIDA para cualquier receta" · "colocar receta deconstruible=false -> ok (manager permite colocar)" · "demoler receta deconstruible=false -> NO_DECONSTRUIBLE" · "demoler pieza NORMAL (deconstruible=true) -> ok" |
| **F121** La validación se re-ejecuta con cada rotación | 5 | "preview rotacion 0 -> cache=false (primera evaluacion)" · "preview misma celda/rot/receta -> cache=true (cache hit)" · "preview rotacion 1 (cambia huella) -> cache=false (recalculo real)" · "la rotacion 1 cambia las celdas afectadas (2x1 -> huella en Z)" · "el contador de recalculos del preview sube con el cambio de rotacion" |
| Catalogo (control) | 3 | "catalogo carga recursiva res://data/construccion/piezas (46 recetas)" · "catalogo valido (sin problemas de schema): ok == true" · "12 familias canonicas PRESENTES (RF12 bloque J)" |

### 7.3 Mecanismos verificados (con ruta y línea)

- `PlacementRule.requiere_pared` (`scripts/construccion/placement_rule.gd` L49) — flag declarativo en
  los `.tres` de `data/construccion/piezas/` (2 puertas + 2 ventanas = `true`).
- Regla 4 del validador (`scripts/construccion/construccion_validator.gd` L89-92) →
  `tiene_pared_contigua()` (L209-215) sobre los 4 vecinos horizontales (`VECINOS_H`, L45-48).
- Regla 3 del validador (soporte) → `contar_soportes()` (L146-154) contra la whitelist
  `PlacementRule.superficie_ok` (L43): el camino solo acepta `terreno`; la roca no está en la lista
  → 0 soportes < `soportes_minimos` = 1 → `SIN_SOPORTE`.
- Regla 1 del validador (zona) → `ZonasPermisos.PARCELA_NPC` / `.RUINA` = `Permiso.PROTEGIDA`
  (`scripts/construccion/zonas_permisos.gd` L28-30) → `ZONA_PROTEGIDA` antes que cualquier otra regla.
- Guard de demolición (`scripts/construccion/build_manager.gd` L493-496): receta con
  `deconstruible == false` → `Motivo.NO_DECONSTRUIBLE`; el control con `deconstruible == true` демuele
  normal.
- Cache del preview (`scripts/construccion/build_preview.gd` L46): la cache se invalida cuando cambia
  `(celda, rotacion, receta_id)`; `evaluar()` toma la rotación viva del manager (L39-40).

### 7.4 Deuda que queda (honesta, no tapada)

- **G145 — data:** el catálogo M17 tiene **0 recetas con `deconstruible == false`** (check explícito
  "catálogo M17 declara 0 receta(s) con deconstruible == false"). El GUARD del sistema está
  implementado y verificado con una receta sintética, pero las piezas de ruina (M25) y de evento
  (M73) todavía no existen como recetas: cuando M25/M73 las entreguen, el sistema las cubrirá sin
  tocar M17. Deuda de **data**, no de código.
- **G139 escalera** (exige apoyo en piso o pared y no bloquea la circulación): la parte de "no
  bloquea la circulación" no tieneImplementation en el validador lógico — sigue `[ ]`.
- **M Raycast 1/frame + cache de celda** (M221): la cache de celda existe en `BuildPreview`, pero el
  raycast vive en la capa de input/UI, fuera del riel headless — sigue `[ ]`.

### 7.5 Regresión

Las 3 suites de M17 que ya corrían en CI (`scripts/construccion/test_construccion.gd`,
`test_construccion_iter2.gd`, `test_construccion_iter3.gd`) NO se tocaron en esta tanda (no se
modificó ningún `.gd` de `scripts/construccion/`). La suite nueva es aditiva.

## 8. Tanda persistencia + rejilla (2026-11-06 22:40) — 4 ítems cerrados

**Modelo:** DeepSeek-V4.1-Flash (OpenCode)
**Plataforma:** OpenCode

### 8.1 Qué se añadió

Suite NUEVA `res://tests/test_m17_persistencia_rejilla.gd` → **23 checks, 0 fallos, EXIT 0**
(Godot 4.7.2 headless). No se tocó ningún `.gd` de `scripts/construccion/`: la suite es aditiva y
`tests/run_tests.gd` la descubre sola (recorre `res://tests/` de forma recursiva), por lo que NO
hizo falta tocar `quality.yml`.

La suite recorre el ciclo real del save: coloca `piso_tablones` en (2,0,3), `pared_madera` rotada
90° encima en (2,1,3) y `escalera_doble` 2x1 en (4,0,-1) con `planta=1`; toma
`obtener_estructuras()`; lo pasa por `JSON.stringify`/`JSON.parse_string` (el save M59 es JSON: los
enteros vuelven como float); `limpiar_estructuras()`; `restaurar_estructuras()`; y exige identidad
de campos, reconstrucción de la ocupación (incluida la segunda celda de la huella 2x1), misma
posición mundial por celda y doble restauración idempotente.

### 8.2 Ítems cerrados

| Ítem | Evidencia (texto literal de los checks / ruta) |
|---|---|
| **D97** Altura de planta 1 m por bloque | `ConstruccionMundo.OFFSET_MEDIO_VOXEL = 0.5` + `mundo_desde_celda(celda) = Vector3(celda) + 0.5` (`construccion_mundo.gd` L113-117). `test_m17_construccion_validacion.gd` L244-260: "OFFSET_MEDIO_VOXEL == 0.5", "el origen de la rejilla coincide con el origen global del mundo voxel" (0.5, 0.5, 0.5) y round-trip en 4 casos. |
| **D102** Rejilla coherente tras guardar/cargar | Suite nueva: "misma celda -> misma posicion mundial antes y despues" y "round-trip celda -> mundo -> celda es exacto (incluye negativos)". |
| **F127** Mover no re-cobra | `mover_pieza()` (L555-597) no llama a `_f_descontar` ni a `_f_devolver` y registra `"costo": {}` (L590); `test_construccion.gd` L386-391: "mover NO re-cobra recursos". |
| **P256** Integración colocar→guardar→cargar→restaurar | Suite nueva (23 checks); complementa `scripts/saving/test_carga_idempotente_m59.gd` (mismo par `obtener_estructuras`/`restaurar_estructuras`). |

### 8.3 Línea base del lote (Godot 4.7.2 headless)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/test_m17_construccion_validacion.gd` | 44 | 0 | 0 |
| `tests/test_m17_reglas_pieza.gd` | 40 | 0 | 0 |
| `tests/test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 | 0 |
| `tests/test_m17_persistencia_rejilla.gd` (NUEVA) | 23 | 0 | 0 |

### 8.4 Los 36 abiertos, clasificados por dueño (no son deuda de código de M17)

- **M18 / capa UI y escena (12):** C78 (entrada por herramienta/tecla), C80 (HUD con categorías y
  costo), C81 (suspender movimiento), C82 (mundo activo), C83 (selección por categorías), C84
  (desbloqueos visibles), C85 (tutorial), C86 (indicador de celda en el mundo), F124 (fantasma
  elevado: la matemática está verificada — `y = celda.y + altura/2`, `test_construccion_iter3.gd`
  L298-303 — falta el juicio visual), F129 (ventana de confirmación + preview de devolución), O250
  (admirar desde la cámara), P261 (QA Play Mode entrar/salir).
- **M14 inventario (2):** I128 (espacio libre al almacenar), I166 (almacenar convierte la pieza en
  ítem sin perder receta).
- **M18 contenido funcional (2):** F130 `[?]` (demolición libera contenido), K191 (ampliaciones de
  la casa).
- **M64 IA/navmesh (3):** G144 (no bloquear la única salida), O249 (NPC miran la obra), P257
  (navmesh con puertas y obras).
- **M08 terreno cargado (1):** D100 (la rejilla solo sobre terreno cargado — el adaptador devuelve
  "aire" sin terreno, pero falta la prueba con chunks reales en runtime).
- **M25 (1):** K192 (ruinas `deconstruible=false`) — deuda de DATA: 0 recetas de ruina en el
  catálogo; el guard está implementado y probado con receta sintética.
- **M73 (1):** K194 (recetas de festival `devolucion=0`) — 0 recetas de festival en el catálogo.
- **M31 (1):** K196 (faroles al ciclo día/noche).
- **M92 (1):** I169 (tabla de costos de referencia de M92 en las recetas).
- **M93 (2):** H157 (señal a M93), K199 (proyectos de meta larga cuentan piezas). ⚠️ Discrepancia:
  en `CHECKLIST-GLOBAL.md` M93 = **Balance**, no "proyectos"; la numeración de K199 es de un plan
  viejo. Se reporta, no se adivina.
- **M51/M43 VFX/audio (3):** O244 (polvo), O245 (sonido por material), O246 (ambiente de obra).
- **Polish UX (2):** O247 (aura verde), O248 (aviso amable + vibración).
- **Optimización (1):** M223 (materiales compartidos entre instancias).
- **Input/render (1):** M221 (raycast 1/frame: la cache de celda existe en `BuildPreview`, el
  raycast vive en la capa de input/UI — el throttle actual de 1/4 frames es de M70
  `interaction_manager.gd`, no de M17).
- **Playtest/QA manual (2):** P259 (playtest M113 teclado+mando), P260 (recorrido M114 en M18).
- **Regla de escalera (1):** G139 (apoyo sí — `soportes_minimos=1` + `superficie_ok`; "no bloquea
  la circulación" no tiene implementación en el validador lógico).

Total: 12 + 2 + 2 + 3 + 1 + 1 + 1 + 1 + 1 + 2 + 3 + 2 + 1 + 1 + 2 + 1 = 36.

## 9. Tanda circulación + apoyo alternativo (2026-11-08) — 2 ítems cerrados

**Modelo:** DeepSeek-V4.1-Flash (OpenCode)
**Plataforma:** OpenCode

### 9.1 Qué se añadió

1. **`scripts/construccion/circulacion.gd` (NUEVO, modelo puro).** `class_name Circulacion`,
   sin dependencias de escena ni de `Node`. API:
   - `analizar(zona: Dictionary, nuevas: Array, salidas: Array) -> Dictionary` — devuelve
     `{bloquea, motivo, salidas_aisladas, salidas_tapadas, libres_antes, libres_despues,
     componentes_antes, componentes_despues}`.
   - `bloquea(...) -> bool` — atajo booleano.
   - BFS **4-direccional en x/z** (las plantas se evalúan por separado: una escalera no conecta
     plantas para este chequeo). `MAX_VISITAS = 200000` como cota dura anti-cuelgue.

   Detecta tres casos: (a) pieza que **tapa** una salida, (b) dos o más salidas que **dejan de
   estar conectadas** entre sí, (c) **salida única que queda aislada**. Si una salida ya estaba
   aislada **antes** de la pieza, no se le atribuye a la pieza nueva (evita falsos positivos).

2. **Paso 9 del validador (`construccion_validator.gd`).** `ORDEN` pasa de 8 a **9 reglas**:
   `["zona","ocupacion","soporte","regla","npc","mundo","limite","recursos","circulacion"]`.
   El paso **solo corre si el dueño de la zona provee `ctx["circulacion"]`** (un `Dictionary` con
   `zona` y `salidas`); sin datos devuelve `sin_datos` y **no bloquea** (política fail-open, para no
   romper llamadas existentes que no conocen la zona).

3. **Motivo nuevo `BLOQUEA_SALIDA`** en `ConstruccionTipos` (texto al jugador: «taparia la unica
   salida de la zona»), tratado como **permanente** (no reintentable: mover la pieza no arregla el
   problema si la pieza está en el paso).

4. **`PlacementRule.apoyo_alternativo: Array[StringName]`** (export nuevo + round-trip en
   `a_dict()`/`desde_dict()`). `ConstruccionValidator.tiene_apoyo_alternativo(receta, celda,
   rotacion, ctx)` acepta el paso de soporte si la celda vecina declarada como alternativa existe
   físicamente en el mundo (p. ej. `&"pared"`).

5. **Data:** `escalera_recta.tres` y `escalera_doble.tres` declaran
   `apoyo_alternativo = Array[StringName]([&"pared"])`, que es exactamente lo que pide L143
   («apoyo en piso **o** pared»).

### 9.2 Ítems cerrados

| Ítem | Evidencia (texto literal de los checks / ruta) |
|---|---|
| **L148** Las piezas no pueden bloquear la única salida de la zona | `circulacion.gd` (BFS) + paso 9 del validador. Suite `tests/test_m17_circulacion.gd` A1-A16 (modelo): "A1 zona vacia -> sin_datos y NO bloquea", "A3 pieza en el medio de un pasillo de 2 salidas -> BLOQUEA — aisla 2 salida(s)", "A8 pieza justo sobre una salida -> BLOQUEA — tapa 1 salida(s)", "A11 unica salida, pieza contigua -> la deja AISLADA y bloquea", "A13 salida ya aislada ANTES por otra pieza -> no se culpa a la nueva". Integración B1-B7 sobre el validador, incluida huella 2x1. |
| **L143** Escalera exige apoyo en piso o pared y no bloquea la circulación | `PlacementRule.apoyo_alternativo` + `tiene_apoyo_alternativo()` + data de las dos escaleras. Suite nueva C1-C12: "C? piso normal acepta", "pared contigua sin piso acepta", "sin piso ni pared -> SIN_SOPORTE", "huella 2x1 con apoyo junto a la segunda celda acepta" y "regresión: receta sin `apoyo_alternativo` NO acepta pared". |

### 9.3 Línea base del lote (Godot 4.7.2 headless)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/test_m17_circulacion.gd` (NUEVA) | 36 | 0 | 0 |
| `tests/test_m17_construccion_validacion.gd` | 44 | 0 | 0 |
| `tests/test_m17_reglas_pieza.gd` | 40 | 0 | 0 |
| `tests/test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 | 0 |
| `tests/test_m17_persistencia_rejilla.gd` | 23 | 0 | 0 |

### 9.4 Corrección de la clasificación de §8.4 y deuda honesta

- **`G139` y `G144` no existen como líneas del `05-Checklist.md` de M17.** Son IDs legacy citados
  en §8.4; las líneas reales son **L143** (escalera con apoyo en piso o pared) y **L148** (no
  bloquear la única salida). Ambas quedaron cerradas en esta tanda, así que **los dos bullets
  «Regla de escalera (1)» y «M64 IA/navmesh (3): G144…» de §8.4 están vencidos**: de los 36
  abiertos quedan **34** (33 `[ ]` + 1 `[?]`).
- **Deuda real que queda (no tapada):** el paso 9 está implementado y probado **a nivel de
  validador**, pero `BuildManager` todavía **no arma `ctx["circulacion"]`** al validar. El cableado
  necesita que el dueño de la zona (M18 escena / M64 navmesh) exponga zona y salidas; mientras no
  lo haga, el paso 9 devuelve `sin_datos` y no bloquea. Es deuda de **integración**, no del modelo
  de circulación (que está cubierto por 16 checks de modelo puro).
- **Límite del modelo:** la circulación es **por planta**. Una escalera no se considera conexión
  vertical para el BFS: si la zona tiene salidas en plantas distintas, el chequeo las evalúa como
  componentes separados. Se documenta para que el cableado de M18/M64 no asuma lo contrario.

### 9.5 Regresión

- `tests/test_m17_construccion_validacion.gd` se actualizó de 8 a 9 reglas esperadas en `ORDEN`
  (aserción de contrato, no de comportamiento).
- `tests/test_m17_suites_integracion.gd`: el watchdog usaba `w.start()` en `_initialize()`, cuando
  el `Window` raíz todavía no está en el árbol, y Godot emitía
  `ERROR: Unable to start the timer because it's not inside the scene tree`. Se cambió a
  `w.autostart = true` + `add_child()`; el error desapareció y la suite sigue en 17/0 (501 checks).
- Ningún `.gd` de las 7 suites históricas (`test_construccion.gd` … `iter7`) se modificó.

## 10. Tanda almacenamiento de piezas (2026-11-25 09:5x) — 2 ítems cerrados

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 10.1 Qué se añadió

**Código (antes NO existía ninguna función de almacenamiento):**

1. `scripts/construccion/build_manager.gd` → **`almacenar_pieza(celda: Vector3i) -> Dictionary`** (NUEVA).
   La pieza sale del mundo y entra al inventario (M14) como un item con el **mismo id de receta**
   (`String(e["tipo"])`), por eso la pieza conserva su receta y sigue siendo colocable desde el
   catálogo. **No** devuelve recursos (guardar no es demoler: lo que se guarda es la pieza).
   Orden de guards: `NO_HAY_PIEZA` → `RECETA_INVALIDA` → `NO_DECONSTRUIBLE` → `SOSTIENE_OTRA_PIEZA`
   → `SIN_INVENTARIO` → `SIN_ESPACIO`.
   **Atomicidad:** el item se agrega ANTES de tocar el mundo; si el inventario no lo acepta, la
   pieza sigue intacta (nunca hay entrega parcial).
2. **Adaptadores de inventario** en `conectar_inventario()` (duck-typing sobre M14):
   `_f_agregar_item(item_id, cantidad)`, `_f_tirar_item(item_id, cantidad)`,
   `_f_hay_espacio()` (usa `has_free_space(0)` — el BOLSILLO, `ContainerType.Id.BOLSILLO = 0`;
   si el inventario no lo expone, el intento real sigue siendo la autoridad).
3. **Señal nueva** `pieza_almacenada(receta_id: StringName, celda: Vector3i)` (+ `navmesh_delta`).
4. `scripts/construccion/build_history.gd` → `TIPO_ALMACENAR = "almacenar"` + rama en
   `_invertir()` de `BuildManager`: **undo** = recolocar la pieza y sacar el item del inventario;
   **redo** = volver a guardarla.
5. `scripts/construccion/construccion_tipos.gd` → motivos `SIN_ESPACIO` (temporal: se reintenta al
   liberar un slot) y `SIN_INVENTARIO` (permanente), con su texto de HUD. Se **añaden al final** del
   enum: no se renumera ningún motivo existente.

**Tests:** suite NUEVA `res://tests/test_m17_almacenamiento.gd` → **33 checks, 0 fallos, EXIT 0**
(Godot 4.7.2 headless). El runner central la descubre sola (recorre `res://tests/`), cableada
además en `quality.yml` (M118).

### 10.2 Ítems cerrados

| Ítem | Evidencia (texto literal de los checks) |
|---|---|
| **L132** Almacenar requiere inventario con espacio libre (M14) | "B4: inventario LLENO -> motivo SIN_ESPACIO" · "B5: inventario lleno -> la pieza SIGUE colocada (atomicidad: no hay entrega parcial)" · "B6: inventario lleno -> no se entrego el item" · "B7: SIN_ESPACIO es TEMPORAL (se reintenta al liberar un slot)" · "B1: SIN inventario -> motivo SIN_INVENTARIO" · "B2: SIN inventario la pieza SIGUE colocada" · "B3: SIN_INVENTARIO es PERMANENTE" |
| **L170** El almacenamiento convierte la pieza en ítem del inventario sin perder receta | "A4: el item guardado usa el MISMO id que la RECETA" · "A5: la receta sigue en el catalogo (no se perdio al guardar)" · "A8: el item almacenado se puede volver a colocar -> ok" · "A9: la pieza vuelve a estar en el mundo tras recolocarla" · "A6/A7: la pieza salio del mundo" · "D3: guardar NO devuelve recursos" · "D4–D9: undo/redo del almacenamiento (pieza ↔ item)" · "D1/D2: señales `pieza_almacenada` y `navmesh_delta`" |

### 10.3 Anti-falso-verde (ROJO-VERDE)

Con `almacenar_pieza()` stubbeada a un fallo la suite da **13 fallos / EXIT 1**; restaurada,
**33 checks / 0 fallos / EXIT 0**. La suite detecta la ausencia de la función.

### 10.4 Línea base del lote (Godot 4.7.2 headless)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/test_m17_almacenamiento.gd` (NUEVA) | 33 | 0 | 0 |
| `tests/test_m17_construccion_validacion.gd` | 44 | 0 | 0 |
| `tests/test_m17_reglas_pieza.gd` | 40 | 0 | 0 |
| `tests/test_m17_circulacion.gd` | 36 | 0 | 0 |
| `tests/test_m17_persistencia_rejilla.gd` | 23 | 0 | 0 |
| `tests/test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 | 0 |
| `tests/test_m17_categorias.gd` | 24 | **3 (PRE-EXISTENTE)** | 1 |

⚠️ **Deuda ajena a esta tanda (no tapada):** `test_m17_categorias.gd` está en ROJO por
`BuildHudModel.filas_categorias` inexistente (3 checks). Verificado como **fallo PRE-EXISTENTE**
con `git stash` sobre los 3 archivos tocados por esta tanda: los mismos 3 fallos sin mis cambios.
Corresponde al ítem de HUD (L81) — no es deuda de código de M17 resueluble headless.

### 10.5 Lo que sigue abierto (31 `[ ]` + 1 `[?]`)

Sin cambios respecto de §9.4 salvo el conteo: UI/arte/audio (L78-86, L127), inventario cruzado con
M14 para el resto de los muebles, navmesh M64 (L161), datos M25/M73 (L196/L198), M92 (L173), M93 (L200),
raycast 1/frame (L225), materiales compartidos (L227) y playtest/QA manual (L262-L266).

## 11. Tanda materiales compartidos (2026-11-25 10:2x) — 1 ítem cerrado (L227)

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 11.1 Medición previa (qué era real y qué no)

- Las piezas **colocadas** en M17 **no son mallas**: `ConstruccionMundo.escribir_voxel()` escribe
  **vóxeles** en el terreno (M08). No hay una instancia de malla por pieza colocada que pueda
  duplicar materiales → esa parte del ítem vive en **M08** (VoxelTerrain/VoxelTool) y se deja
  anotada, no se roba.
- Lo que **sí** existe en M17 son las **mallas de previa** (el fantasma). Antes de esta tanda,
  `BuildGhost` tenía cache **por instancia** (`_cache_malla`): cada fantasma instanciaba su
  propia copia de la escena `.glb` de la receta → N copias de la misma malla y de sus materiales
  (CPU + memoria + batching roto).

### 11.2 Qué se añadió

`scripts/construccion/build_ghost.gd`:
- `static var _cache_malla_compartida: Dictionary` — cache **ESTÁTICA** ruta→Mesh: la malla se
  resuelve **UNA vez** para todos los consumidores y todas las instancias reciben el **mismo**
  recurso (y por tanto el mismo material de superficie).
- `static var _cargas_malla: int` + `static func cargas_de_malla() -> int` — contador auditable
  (1 por ruta, no 1 por consumidor).
- `registrar_malla()` (precarga explícita) **sigue siendo por instancia**: son datos de test y no
  deben contaminar el cache compartido.
- Ruta inexistente → `null` sin fallar y **sin** consumir carga.

### 11.3 Ítem cerrado

| Ítem | Evidencia (texto literal de los checks) |
|---|---|
| **L227** Materiales de pieza compartidos entre instancias (static batching de Godot) | Suite NUEVA `res://tests/test_m17_materiales_compartidos.gd` (**13 checks, 0 fallos, EXIT 0**): "A2: la carga de la malla ocurre UNA sola vez (cache compartida, no 1 por consumidor)" · "A3: el 2do consumidor NO vuelve a cargar la malla (reutiliza la compartida)" · "A4: las dos instancias reciben el MISMO recurso de malla (mismo instance id)" · "A5: el material de superficie es el MISMO recurso en ambas instancias (no se duplica)" · "B1/B2: la precarga explícita tiene prioridad en SU instancia y NO contamina el cache compartido" · "C1/C2: ruta inexistente degrada a null sin fallar y sin gastar carga" · "D1: colocar una pieza NO crea instancias de malla en M17 (la pieza es un VOXEL de M08)" · "D2/D3" |

### 11.4 Anti-falso-verde

Quitando la cache compartida (cada consumidor vuelve a instanciar la escena) la suite da
**1 check en ROJO / EXIT 1** ("A3: el 2do consumidor NO vuelve a cargar la malla"); restaurada,
**13/0 / EXIT 0**.

### 11.5 Deuda que queda (honesta)

- El material **override** del fantasma (`_mat`, el tinte verde/rojo) es **por instancia a
  propósito**: cada fantasma cambia de color según su estado. Con 1-2 fantasmas visibles no
  afecta al batching; si el pool creciera, habría que compartir el material por estado.
- Los materiales del **terreno voxel** (las piezas ya colocadas) son de **M08** (VoxelTerrain /
  VoxelTool): quedan fuera de M17 y se anotan para su dueño.

## 12. Tanda HUD de categorias (2026-11-25 10:5x) — 2 ítems cerrados (L81, L84) y un ROJO pre-existente ARREGLADO

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 12.1 Punto de partida

La suite `tests/test_m17_categorias.gd` (escrita por DS-V4.1-Flash-Opencode el 2026-11-11 para el
ítem **L84**) exigía `BuildHudModel.filas_categorias(...)` y quedó **ROJA** (24 checks, 3 fallos):
la función **nunca se implementó**. Es decir: el rojo era el item, no un falso del test.

### 12.2 Qué se añadió

`scripts/construccion/build_hud.gd`:
- **`static func filas_categorias(mgr, modo: int = -1) -> Array`** — las 4 categorías canónicas en
  su orden de presentación (aunque una esté vacía: el HUD no salta filas). Cada fila:
  `{categoria, nombre, cantidad, cantidad_modo, texto}`.
  - `cantidad` = recetas del **catálogo** en esa categoría (las 4 filas suman las 46 reales).
  - `cantidad_modo` = piezas **disponibles en el modo pedido** (filtro real por `es_mueble`).
- **`static func texto_categorias(mgr, modo)`** — una línea con las 4 categorías y su disponibilidad.
- Tolerancia: sin manager, o con un objeto sin `piezas_de_categoria` → `[]` (nunca crashea el HUD).

**Tests:** suite NUEVA `res://tests/test_m17_hud_categorias.gd` → **22 checks, 0 fallos, EXIT 0**
(Godot 4.7.2 headless), con **watchdog de 120 s** (sin él, un error temprano abortaba el bloque
antes de `quit()` y el runner **se colgaba**: medido — el stub provocaba un cuelgue; con el
watchdog + guards, el rojo sale limpio con EXIT 1).

### 12.3 Ítems cerrados

| Ítem | Evidencia |
|---|---|
| **L81** HUD de modo con categorías del catálogo y costo de la pieza activa | `filas_categorias()` / `texto_categorias()` (nuevas) + `filas_costo()`/`texto_costo()`/`resumen()` (preexistentes). Checks: "A1: el HUD devuelve 4 filas" · "A3: el orden es el canonico" · "A4: las cantidades del CATALOGO suman las 46 recetas reales" · "A5: el nombre de cada fila es el texto legible de su categoria" · "A6: cada 'cantidad' coincide con el conteo REAL del manager" · "A7/A7b: mutar una fila no afecta la siguiente llamada" · "E1/E2/E3: resumen() con costo, motivos y linea (y tolerante a receta nula)" |
| **L84** Selección de pieza por categorías: estructura, mobiliario, iluminación, decoración | Suite de L84 `res://tests/test_m17_categorias.gd`: **24 checks, 0 fallos, EXIT 0** (era 3 fallos). Checks: "estructura = 26" · "mobiliario = 4" · "iluminacion = 3" · "decoracion = 13" · "suma de categorias = 46 (sin duplicados ni perdidas)" · "modo decoracion filtra por es_mueble tambien dentro de la categoria" |

### 12.4 ROJO-VERDE y el rojo pre-existente

- Con `filas_categorias()` stubbeada a `[]`: mi suite → **22 checks, 10 fallos, EXIT 1** (sin
  cuelgue) y la suite heredada de L84 → **24 checks, 2 fallos, EXIT 1**.
- Restaurada: **22/0** y **24/0**, ambas EXIT 0.
- **El rojo pre-existente que reporté en el Log 2446 queda ARREGLADO**: `test_m17_categorias.gd`
  pasó de 24 checks / 3 fallos a **24 checks / 0 fallos**. Ambas suites quedan cableadas en
  `quality.yml` (M118) para que no vuelva a colarse.

### 12.5 Mediciones reales del catálogo (para los próximos)

| Dato | Valor |
|---|---|
| Recetas del catálogo | **46** |
| Por categoría (todas) | estructura **26** · mobiliario **4** · iluminacion **3** · decoracion **13** |
| Por modo (filtro `es_mueble`) | CONSTRUCCION **25** · DECORACION **21** (conjuntos disjuntos) |

Nota de diseño: el filtro por modo (`es_mueble`) **cruza** las categorías (una antorcha es
`iluminacion` y es mueble: aparece en modo decoración). Por eso el HUD lleva los dos conteos
(`cantidad` = catálogo, `cantidad_modo` = disponible ahora) en lugar de uno solo.

## 13. Tanda P7 (2026-11-25 11:4x) — CONTENIDO de las piezas: el ÚNICO `[?]` de M17, cerrado

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 13.1 Punto de partida

El checklist tenía **un único ítem en `[?]`** (degradado por atria-dawn-s2 el 2026-10-08, msg 133):
*"La demolición de piezas funcionales (camas, almacenamiento) libera su contenido"*, con la nota de que
`demolir_pieza` solo devuelve los **materiales** de la receta, de que no existe lógica de liberar
contenido y de que **no existe `build_interaction.gd`** (que el propio `04-Codigo.md` §1 ya listaba
como "Punto de interacción en piezas funcionales (camas, almacenamiento M18)").

**Verificado en disco:** el archivo no existía y no había ninguna ruta de código que devolviera el
contenido de una pieza al demolerla — los items de un cofre **se perdían**.

### 13.2 Qué se añadió

**`scripts/construccion/build_interaction.gd`** (nuevo, **modelo puro**, sin nodos):
| Función | Qué hace |
|---|---|
| `items_de_contenido(bruto)` | Normaliza las **dos** formas de cofre del proyecto: canónica `{"contenido":[{item_id,cantidad}]}` y alternativa `{"items":{...}}`. CUALQUIER otra forma → `{}` (no inventa datos). |
| `contenido_de(estructura)` | Separa lo que guarda la pieza: `{items, muebles, puertas}` (vacío si no hay nada → nunca `null`). |
| `tiene_contenido(estructura)` | true si hay items, muebles o puertas. |
| `liberar_contenido(estructura)` | Lo que el jugador recupera. **NO muta** la pieza (para que el deshacer la devuelva íntegra). |
| `vaciar_contenido(estructura)` | Vacía el cofre de verdad (consumo real de la pieza). |
| `items_a_contenido(items)` | Inverso: `{item_id: cantidad}` → `{"contenido":[{item_id,cantidad}]}`. |
| `total_items` / `texto_contenido` / `es_funcional` | Métricas y texto para la UI ("vuelve: madera x4"). |

**`scripts/construccion/build_manager.gd`** (3 puntos):
1. `demolir_pieza()`: los items de la pieza **vuelven al inventario** (antes se perdían) y el
   resultado reporta `contenido_liberado` / `items_liberados`.
2. Historial: la demolición guarda el `contenido` liberado → el **deshacer** restituye la pieza
   **íntegra** y saca los items del inventario (no se duplican ni se pierden); el **rehacer** los
   devuelve al inventario.
3. **API pública para M18** (la UI necesita leer/guardar, sin tocar estado privado):
   `contenido_de_pieza(clave)` y `asignar_contenido(clave, items)`.

> ⚠️ **Trampa de headless (documentada porque costó un rato):** un archivo **nuevo** con
> `class_name` no está en la cache global de clases hasta que el editor reescanea el proyecto. En
> headless eso rompía el arranque del autoload (`Identifier "BuildInteraction" not declared in the
> current scope`) y la suite **se colgaba** en vez de fallar. **Solución:** en el manager se carga
> con `const INTERACCION := preload("res://scripts/construccion/build_interaction.gd")` (no por
> `class_name`). El `class_name` se mantiene para cuando el editor registre la clase.

### 13.3 Verificación

- Suite NUEVA `res://tests/test_m17_contenido_piezas.gd` → **32 checks, 0 fallos, EXIT 0**.
- **ROJO-VERDE:** con `liberar_contenido()` stubbeado a items vacíos → **4 fallos (A9, A11, B7, B8) /
  EXIT 1**. Restaurado → 32/0.
- **Regresión M17 completa (12 suites, todas EXIT 0):** contenido 32/0 · hud_categorias 22/0 ·
  categorias 24/0 · almacenamiento 33/0 · materiales_compartidos 13/0 · validacion 44/0 ·
  reglas_pieza 40/0 · circulacion 36/0 · persistencia 23/0 · suites_integracion 17/0 (501 checks) ·
  qa_m17_modo 9/0 · iter3 138/0.

### 13.4 Regresion GLOBAL (runner central = gate de CI)

`res://tests/run_tests.gd` (suite completa del repo): **70/70 suites · 2982 tests · 0 fallos ·
EXIT 0**. Incluye las 4 suites de M17 entregadas por este agente. El runner reporta 771 s de tiempo
de suite (presupuesto 600 s): no es una regresion de este cambio (66 suites en paralelo sobre una
maquina compartida con el resto de la flota) — el veredicto es 0 fallos.

### 13.4 Lo que queda fuera de M17 (dueño explicito)

La **ventana de confirmación** con lo que devuelve la pieza al demolerla es **UI de M18** (L133).
Aquí queda el dato y la lógica; el diálogo, no.

## 14. Tanda P8 (2026-11-25 12:2x) — L102: la rejilla SOLO sobre terreno cargado

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 14.1 El item estaba realmente roto

`04-Codigo.md` decía de L102: *"el adaptador devuelve 'aire' sin terreno, pero falta la prueba con
chunks reales en runtime"*. Verificado: **no había ninguna comprobación de chunk**. El manager
colocaba la pieza, la registraba en `_estructuras` y la daba por buena **aunque el terreno no
tuviera data block en esa zona**: la pieza existía en la lógica de M17 pero no en el mundo (ni el
undo ni el redo cuadraban).

### 14.2 API nativa (medida, no supuesto)

Medida con `ClassDB.class_get_method_list("VoxelTerrain")` en Godot 4.7.2 + Voxel Tools:

```
voxel_to_data_block(voxel_pos: Vector3) -> Vector3i
has_data_block(block_position: Vector3i) -> bool
get_data_block_size() -> int
```

Ese es el contrato correcto ("¿hay data block en la zona?") — no un invento.

### 14.3 Qué se implementó

**`scripts/construccion/construccion_mundo.gd`**
| API | Qué hace |
|---|---|
| `chunk_cargada(celda) -> bool` | `voxel_to_data_block` + `has_data_block`. **Conservadora:** sin terreno (modo lógico) → true; sin esa API (VoxelTools distinto) → true. Solo bloquea cuando la API responde y dice que no hay data block. |
| `celdas_sin_chunk(celdas) -> Array` | Las celdas fuera de la rejilla. |
| `superficie_voxel(celda)` | Devuelve **"aire"** si el chunk no está cargado, aunque el voxelTool diga "sólido" (no se calcula sobre datos rancios). |
| `consultas` (+ `reiniciar_contadores()`) | Contador de consultas al terreno: permite **probar** que la rejilla se acota a la huella de la pieza. |

**`scripts/construccion/construccion_tipos.gd`**
- Motivo nuevo **`TERRENO_NO_CARGADO`** (al final del enum, como se hizo con `SIN_ESPACIO`/`SIN_INVENTARIO`).
- **Es TEMPORAL** (`MOTIVOS_TEMPORALES`): el chunk se carga solo (streaming de M08) y el reintento
  funciona sin cambiar de celda ni de pieza.
- Texto para el HUD: *"el terreno de esa zona todavía no está cargado"*.

**`scripts/construccion/build_manager.gd`** — guard en las **tres** rutas que escriben en el mundo:
`confirmar_colocacion()`, `copiar_pieza()` y `mover_pieza()`.
- Si alguna celda de la pieza cae en un chunk sin cargar → **no se coloca/copia/mueve**.
- **El guard va ANTES de validar**: si fuera después, el jugador vería "sin soporte" (permanente)
  en vez de "terreno no cargado" (temporal) — que es el motivo que puede resolverse solo.
- **No queda a medias:** no se registra la estructura, no se escribe ningún voxel, no se cobra el
  costo. Al mover, el origen **sigue en su sitio** (se comprueba antes de vaciarlo).

### 14.4 Verificación

- Suite NUEVA `res://tests/test_m17_terreno_cargado.gd` → **24 checks, 0 fallos, EXIT 0**.
  El terreno falso reproduce **exactamente** el contrato nativo medido (`voxel_to_data_block` +
  `has_data_block` + un `VoxelTool` con `channel/mode/value/get_voxel/do_point`), con dos zonas:
  chunk (0,0,0) **cargado** y chunk (8,0,0) **vacío** donde el voxelTool además dice "sólido"
  (justo el caso que hay que cazar).
- **ROJO-VERDE:** con `chunk_cargada()` stubbeada a `true` → **8 fallos (A2, A3, B1, B4, B5, F1, F2,
  F3) / EXIT 1**. Restaurada → 24/0.
- **Regresión (14 suites, todas EXIT 0):** terreno_cargado 24/0 · contenido_piezas 32/0 ·
  hud_categorias 22/0 · categorias 24/0 · almacenamiento 33/0 · materiales 13/0 · validacion 44/0 ·
  reglas_pieza 40/0 · circulacion 36/0 · persistencia 23/0 · suites_integracion 17/0 (501 checks) ·
  qa_m17_modo 9/0 · iter3 138/0 · **M59 carga idempotente 28/0**.

### 14.5 Alcance honesto (lo que NO se cierra aquí)

La **comprobación en runtime con los chunks reales de M08** no se puede ejercitar headless en este
build: está medido y documentado por M62 en `scripts/rendimiento/memoria/sesion_m62_voxel_500.gd`
(*"VoxelTerrain no usable headless para editar, updated_blocks=0"*). Lo que se cierra aquí es el
**lado de M17**: el contrato, el guard y la prueba con un terreno que reproduce la API nativa
medida. La prueba visual con el terreno de verdad es de M08.

## 15. Tanda P9 (2026-11-25 13:0x) — ATOMICIDAD de la escritura + auditoria anti-inflacion del modulo

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 15.1 Un DEFECTO de la misma clase que L102

Al terminar L102 (seccion 14) hice un barrido de la clase de defecto que L102 representa
("operaciones que reportan exito sin hacer el trabajo"). Encontre otro, **peor**:

```gdscript
# ANTES (build_manager.gd, confirmar_colocacion)
var escritos: int = _mundo.escribir_voxel(celdas, r.bloque)   # puede ser 0
_alta_estructura(celda, r, _rotacion)                        # se registra igual
_historial.registrar({ ... })                                 # queda entrada de undo
return { "ok": true, ... }                                    # y dice "ok"
```

Si el mundo tiene terreno pero la escritura falla (`escribir_voxel` devuelve 0), la pieza
**quedaba REGISTRADA en la logica de M17 sin existir en el mundo**: el jugador no veia nada, el undo
no cuadraba y **el material ya descontado se perdia**. `copiar_pieza()` y `mover_pieza()` tenian el
mismo problema (el mover era el peor: vaciaba el origen y se perdia la pieza).

### 15.2 Correccion

**`scripts/construccion/construccion_tipos.gd`**
- Motivo nuevo **`NO_SE_PUDO_ESCRIBIR`** (final del enum) + **TEMPORAL** + texto de HUD
  ("no se pudo escribir en el mundo (intenta de nuevo)").

**`scripts/construccion/build_manager.gd`** — las tres rutas que escriben:
| Ruta | Antes | Ahora |
|---|---|---|
| `confirmar_colocacion()` | registraba la pieza y decía "ok" con 0 voxels | motivo `NO_SE_PUDO_ESCRIBIR`, **no registra**, **devuelve el costo** ya descontado, y no deja entrada en el historial |
| `copiar_pieza()` | idem | idem (costo de la copia devuelto) |
| `mover_pieza()` | **vaciaba el origen** y se perdia la pieza | **escribe el destino ANTES de vaciar el origen**: si la escritura falla, **el origen sigue en su sitio** |

**Modo LÓGICO (sin terreno):** no se bloquea nada. Ahi la pieza vive solo en la logica **por
diseno** (el mundo es nulo), asi que 0 voxels escritos es lo normal y la operacion es correcta.

### 15.3 Verificacion

- Suite NUEVA `res://tests/test_m17_atomicidad_escritura.gd` → **24 checks, 0 fallos, EXIT 0**.
  - El fallo de escritura se inyecta de forma **determinista** (receta con `bloque = 0`: la
    escritura devuelve 0 aunque el terreno responda), no con un terrain trampeado.
  - Checks: "A1: escribir en el mundo falla -> motivo NO_SE_PUDO_ESCRIBIR" · "A2: NO se reporta
    exito" · "A3: NO se registro la pieza (no queda a medias)" · "A4: el COSTO se devuelve" ·
    "A6: la colocacion fallida NO dejo entrada en el historial" · "B6: al no poder mover, la pieza
    ORIGEN sigue en su sitio" · "C1: en modo LOGICO se coloca igual que siempre" · "E2: en el camino
    sano el costo SI se consume (no es un reembolso fantasma)".
- **ROJO-VERDE:** con el guard desactivado (STUB) se reproduce el comportamiento viejo
  (`"colocada pieza_sin_bloque en (2, 1, 2) (1 celdas, 0 voxeles)"`) y la suite da **7 fallos /
  EXIT 1**. Restaurada → 24/0.
- **Regresion (15 suites, todas EXIT 0):** atomicidad 24/0 · terreno_cargado 24/0 ·
  contenido_piezas 32/0 · hud_categorias 22/0 · categorias 24/0 · almacenamiento 33/0 · materiales
  13/0 · validacion 44/0 · reglas_pieza 40/0 · circulacion 36/0 · persistencia 23/0 ·
  suites_integracion 17/0 (501 checks) · qa_m17_modo 9/0 · iter3 138/0 · **M59 28/0**.

### 15.4 Auditoria anti-inflacion del PROPIO modulo (regla 21.8.2)

El QA cruzado lo hace la directora, pero un modulo tampoco puede esperar a eso: se aplico el
**muestreo §21.8.2 al propio M17**.

- Se extrajeron los identificadores tecnicos de los **148 `[x]`** (funciones, clases, archivos,
  metodos citados en el texto literal de cada item).
- Se comprobo **cada uno contra disco** (`scripts/`, `tests/`, `data/`, `DOCUMENTACION/`).
- Resultado: **0 items sin artefacto** — ningun `[x]` de M17 esta inflado. Los 27 `[ ]` que
  quedan son de otros duenos (segun el mapa de propiedad de 04-Codigo.md) y **0 `[?]`** quedan.

### 15.5 Nota de trazabilidad

Se detecto un **choque de numeracion de logs**: existen `Logs/2450-m17-hud-...` (este agente) y
`Logs/2450-m56-...` (otro agente) con el MISMO numero. Es la carrera que el protocolo advierte
(§6.1.d: dos agentes leen la cabeza del pool a la vez). No lo toco — el pool es de la directora —
pero lo reporto para que lo sanee.

## 16. Tanda P9b (2026-11-25 13:4x) — la misma clase de defecto en DEMOLER y en el HISTORIAL

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 16.1 Lo que encontré al terminar la P9

La P9 arregló la **colocación**. Al seguir el barrido de la misma clase de defecto ("reporta
éxito sin hacer el trabajo"), aparecieron **más rutas con exactamente el mismo problema**:

| Ruta | Qué pasaba |
|---|---|
| `demolir_pieza()` | `_mundo.borrar_voxel()` devolvía 0 y la pieza **se daba de baja igual**, y los materiales **se devolvían**: el voxel quedaba **huérfano** en el mundo (visible, pero sin pieza: "no hay ninguna pieza en esa celda" → no se podía demoler). |
| `undo` de colocar | Idem: borrado fallido + `_baja_estructura()` + costo devuelto → huérfano. |
| `redo` de colocar | Escritura fallida + `_alta_estructura()` → pieza en la lógica **sin voxel**. |
| `undo` de demoler | Escritura fallida + `_alta_estructura()` → ídem, y además se re-descontaba el costo. |
| `redo` de demoler | Borrado fallido + `_baja_estructura()` + material devuelto → huérfano. |
| `undo`/`redo` de almacenar | Igual que colocar/demoler. |
| `undo`/`redo` de mover | `_baja_estructura()` del origen **antes** de escribir → si la escritura fallaba, **la pieza se perdía**. |

### 16.2 Corrección

- **Motivo nuevo `NO_SE_PUDO_BORRAR`** (TEMPORAL, con texto de HUD: *"no se pudo borrar la pieza del
  mundo (intenta de nuevo)"*), simétrico de `NO_SE_PUDO_ESCRIBIR`.
- Helper único en el manager:
  ```gdscript
  func _fallo_de_mundo(operados: int) -> bool:
      return _mundo.tiene_terreno() and operados <= 0
  ```
  (en **modo lógico** —sin terreno— nunca es un fallo: ahí el mundo es nulo por diseño).
- **Orden corregido en todas las rutas**: **primero la operación en el mundo, después el estado
  interno**. Si la operación falla, no se toca la estructura, el inventario ni el historial.
- **Al mover**: se escribe el destino **antes** de dar de baja el origen → si falla, la pieza
  **sigue donde estaba**.

### 16.3 Verificación

- Suite `res://tests/test_m17_atomicidad_escritura.gd` ampliada de 24 a **33 checks, 0 fallos,
  EXIT 0**. Checks nuevos: "F2: demoler con el borrado fallido -> motivo NO_SE_PUDO_BORRAR" · "F3:
  la pieza SIGUE en su sitio (no queda un voxel huerfano)" · "F4: NO se devuelven materiales si la
  demolicion no ocurrio" · "F5/F6: deshacer con el borrado fallido -> la pieza sigue en su sitio" ·
  "F8: deshacer una demolicion con la escritura fallida -> motivo NO_SE_PUDO_ESCRIBIR" · "F9: al no
  poder deshacer, la pieza NO se registro".
- **ROJO-VERDE:** con `_fallo_de_mundo()` stubbeada a `false` → **4 fallos / EXIT 1** (se ve el
  comportamiento viejo). Restaurada → 33/0.
- **Regresión: 15 suites en verde** (M17 ×14 + M59 28/0).

## 17. Tanda P9c (2026-11-25 14:2x) — la CACHE del fantasma: invalidacion y contador auditable

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 17.1 El defecto

`BuildPreview` cachea el resultado de la evaluacion por `(celda, rotacion, receta_id)`, y se
invalida con `limpiar()`. La invalidacion existia en **cuatro** rutas (`confirmar_colocacion`,
`demolir_pieza`, `mover_pieza`, `_invertir`) pero **faltaba en tres mutaciones del mundo**:

| Ruta sin invalidar | Consecuencia |
|---|---|
| `copiar_pieza()` | aparece una pieza nueva y la cache sigue valiendo |
| `limpiar_estructuras()` | se vacia el mundo y la cache sigue valiendo |
| `restaurar_estructuras()` (carga de save) | idem |

Efecto para el jugador: el fantasma podia pintar **VERDE** una celda que ya estaba ocupada (o ROJA
una celda valida), porque reutilizaba un resultado viejo. Es la misma familia de defecto que L102 y
la escritura no atomica: **el sistema mostraba un estado que ya no era verdad**.

### 17.2 Correccion

- `copiar_pieza()` y `limpiar_estructuras()` invalidan la cache (`_preview.limpiar()`).
  `restaurar_estructuras()` queda cubierta porque llama a `limpiar_estructuras()`.
  (`almacenar_pieza()` ya invalidaba.)
- **Contador auditable monótono nuevo**: `BuildPreview.recalculos_totales()` — el total de recálculos
  reales desde que se creó el evaluador, que **NO** se resetea al invalidar.
  El contador existente `recalculos()` **se mantiene igual** (es el contador de sesión y lo usan
  `test_construccion_iter2.gd` e `iter3.gd`: no se toca su semántica).

### 17.3 Verificación

- Suite NUEVA `res://tests/test_m17_cache_preview.gd` → **17 checks, 0 fallos, EXIT 0**.
  Checks: "A2: la segunda vista previa MISMA celda es un acierto de cache" · "A3: el acierto de
  cache NO recalcula" · "B3: COPIAR invalida la cache del fantasma (no se reutiliza el resultado
  viejo)" · "B5: la vista previa de la celda recien copiada dice INVALIDA (la pieza esta ahi)" ·
  "C1/C2: VACIAR el mundo invalida la cache y la celda ocupada vuelve a ser VALIDA" · "D1/D2:
  RESTAURAR estructuras (carga de save) invalida la cache".
- **ROJO-VERDE:** sin el `_preview.limpiar()` de `copiar_pieza()` → **1 fallo / EXIT 1** (el preview
  reutiliza el resultado viejo). Restaurada → 17/0.
- **Regresión: 16 suites en verde** (M17 ×15 + M59), incluidas `test_construccion_iter2.gd` (99/0) e
  `iter3.gd` (138/0), que dependen de la semántica de `recalculos()` (intacta).

## 18. Tanda P9d (2026-11-25 14:4x) — FANTASMA y HUD: ultimo tranche del barrido

**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

### 18.1 Tres defectos (todos de la familia "el sistema muestra un estado que no es verdad")

| # | Dónde | Qué pasaba |
|---|---|---|
| 1 | `BuildGhost.MOTIVOS_OCULTAN` | no incluía el motivo nuevo **`TERRENO_NO_CARGADO`** (L102): el fantasma pintaba una **caja roja flotando** sobre una zona cuyo chunk de terreno todavía no está cargado (no hay referencia espacial: es el mismo caso que "sin terreno", que sí lo oculta). |
| 2 | `BuildGhost.ocultar()` | **no reiniciaba la animación**: si el fantasma se ocultaba a media escala (0 < e < 1) y se reutilizaba del pool, la caja reaparecía a **escala parcial** y ya **no cuadraba con la huella** de la pieza nueva (el jugador veía una caja más pequeña que el sitio donde iba). |
| 3 | `BuildHudModel.es_temporal(res)` | leía solo la clave `"temporal"` del resultado. Un resultado **armado a mano** (sin esa clave) hacía que el HUD mostrara "RECHAZADO" **sin** el "proba de nuevo", aunque el motivo fuera temporal → el jugador|no reintentaba. |

### 18.2 Corrección

- `MOTIVOS_OCULTAN` += `TERRENO_NO_CARGADO` (integra L102 con la capa visual).
- `ocultar()` reinicia la animación: `_animando = false`, `_anim_timer = 0` y `_mesh.scale = Vector3.ONE`
  (el fantasma reutilizado del pool vuelve a cuadrar con la huella).
- `es_temporal(res)`: si el resultado no trae la clave, **consulta los motivos** con
  `ConstruccionTipos.es_temporal(motivo)`. Un temporal sigue siendo temporal.

### 18.3 Verificación

- Suite NUEVA `res://tests/test_m17_fantasma_estado.gd` → **24 checks, 0 fallos, EXIT 0**.
  Checks: "A1: debe_ocultarse = true con TERRENO_NO_CARGADO (no hay referencia espacial)" · "A2: con el
  terreno sin cargar el fantasma queda OCULTO" · "C1: al ocultar, la escala VUELVE a 1 (no queda a
  medias)" · "C2: el fantasma REUTILIZADO del pool aparece a escala 1 (cuadra con la huella)" ·
  "D1/D2: tras ocultar no queda receta ni celdas reportadas (L192)" · "E3: aplicar un resultado NO
  crea nodos nuevos (pooling)" · "F2: la linea del HUD pide reintentar en un rechazo temporal" ·
  "F3: un resultado sin la clave 'temporal' tambien se detecta como temporal (por el motivo)" ·
  "F5: la linea de un rechazo permanente NO pide reintentar".
- **ROJO-VERDE:** revirtiendo los 3 cambios → **4 fallos / EXIT 1**. Restaurados → 24/0.
- **Regresión: 17 suites en verde** (M17 ×16 + M59), incluidas `iter2` (99/0), `iter3` (138/0) e
  **`iter4` (45/0)** —后者 es la que prueba la línea de estado temporal del HUD.

### 18.4 Cierre del barrido

Con esta tanda queda **auditado con el criterio "el sistema muestra/reporta un estado que ya no es
verdad"** todo el núcleo de M17: `build_manager.gd`, `construccion_mundo.gd`, `construccion_tipos.gd`,
`build_preview.gd`, `build_ghost.gd` y `build_hud.gd`, más el historial (`build_history.gd`).
