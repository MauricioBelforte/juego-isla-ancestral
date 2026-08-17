**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 70: Interacciones

## 1. Arquitectura General

```
                    +----------------------------------------------+
                    |                  INPUT (M57)                   |
                    |   InputMap: accion "interact" (E / A / B)      |
                    +---------------------+-------------------------+
                                          | solo este modulo la escucha
                                          v
+-------------------+     +------------------------------+     +-----------------------+
|  M11 Jugador      |---->|   InteractionManager         |---->|  PromptHUD (Canvas)   |
|  (pos, frente,    |     |   (autoload / nodo unico)    |     |  - indicador world    |
|   estado FSM)     |     |                              |     |  - linea contexto     |
+-------------------+     |  - registro de interactuables|     |  - estado atenuado    |
                          |  - evaluacion por frame      |     +-----------------------+
+-------------------+     |  - seleccion con prioridad   |
|  M08 Mundo Voxel  |---->|  - linea de vision (voxel)   |     +-----------------------+
|  (VoxelTool)      |     |  - despacho por contrato     |---->|  Categorias/Consumidor|
+-------------------+     |  - estados y bloqueo         |     |  (M19/M21/M33/M14/    |
                          |  - persistencia GameState    |     |   M65/M18/M35/M36/    |
+-------------------+     +------------------------------+     |   M22/M24/M26)        |
|  M13 Herramienta  |---->    |                             +-----------------------+
|  (mano, nivel)    |         v
+-------------------+     +------------------------------+
                          |  Contrato IInteractable       |
                          |  (interfaz GDScript)          |
                          +------------------------------+
```

### 1.1 Nodos y clases previstos

| Nodo / clase | Tipo | Responsabilidad |
|---|---|---|
| `InteractionManager` | Autoload (`Interaction`) | Autoridad única: registro, evaluación, selección, despacho, estados, persistencia |
| `Interactable` | Script base (Node3D) | Implementa `IInteractable`; helpers de registro automático en `_ready` y `_exit_tree` |
| `IInteractable` | Interfaz GDScript (class_name) | Contrato mínimo entre el gestor y cualquier consumidor |
| `PromptHUD` | Control (CanvasLayer propio) | Render del indicador world-space + línea de contexto; lee del gestor (nunca de consumidores) |
| `CategoriaInteraccion` | Resource | Datos por categoría: ícono, sonido, prioridad, label, requiere línea de visión |
| `CatalogoCategorias` | Resource `.tres` | Tabla de categorías registradas (registro abierto para consumidores) |
| `InteractionState` | Enum (en `InteractionManager`) | Estado global del gestor: INACTIVO, SELECCIONANDO, INTERACTUANDO, DORMIDO |

### 1.2 Contrato `IInteractable` (interfaz GDScript)

```gdscript
class_name IInteractable

enum EstadoInteractuable { DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO }

func obtener_estado() -> EstadoInteractuable
func obtener_categoria() -> StringName          # clave en CatalogoCategorias
func obtener_posicion_interaccion() -> Vector3  # punto ancla del prompt
func obtener_radio() -> float                   # radio de deteccion propio
func obtener_nombre_prompt() -> String          # localizable, ej "Hablar con {nombre}"
func obtener_razon_no_disponible() -> String    # opcional, localizable, ""=sin razon
func requisitos_cumplidos(jugador) -> bool
func interactuar(datos: Dictionary) -> void     # el consumidor hace su logica
func cancelar_interaccion() -> void             # cierre suave si el jugador se aleja
func obtener_duracion_esperada() -> float       # 0 = instantanea, >0 = hold/activa
```

Regla de oro: el gestor NUNCA castea a clases de consumidores; solo llama estos métodos. Errores → degradación NO_DISPONIBLE + log (M103).

## 2. Flujos principales

### 2.1 Flujo de detección y selección (por frame, cuando no está DORMIDO ni INTERACTUANDO)

```
INACTIVO/SELECCIONANDO
  |
  v
[1] Obtener lista de interactuables registrados (Array de IInteractable)
  |
  v
[2] Filtro barato: distancia al jugador <= max(radio_propio, radio_base 2.5 m)
    y estado != OCULTO  -> candidatos_1
  |
  v
[3] Filtro de estado y requisitos (candidatos_1 -> candidatos_2):
    - estado == DISPONIBLE y requisitos_cumplidos(jugador) -> VÁLIDO
    - estado == NO_DISPONIBLE -> válido atenuado (solo para prompt gris)
    - estado == INTERACTUANDO (otro) -> excluido
  |
  v
[4] Si hay VÁLIDOS: linea de vision voxel al mejor candidato provisional
    (solo categorias que lo requieren; espaciado: 1 raycast cada N frames)
    -> descarta los que quedan tapados por geometria voxel
  |
  v
[5] Ordenar por (prioridad_categoria desc, distancia asc, angulo asc)
  |
  v
[6] Histéresis: si el objetivo actual sigue en candidatos con ventaja <= 0.15 m,
    mantener el actual (anti-parpadeo); si no, cambiar objetivo con fade
  |
  v
[7] Estado -> SELECCIONANDO con objetivo fijado; PromptHUD recibe objetivo
```

### 2.2 Flujo de acción (presionar E)

```
SELECCIONANDO con objetivo válido + player presiona "interact"
  |
  v
[1] Estado global -> INTERACTUANDO (bloqueo de nuevas selecciones)
  |
  v
[2] PromptHUD: micro-animacion pulse + ocultar linea de contexto (opcional)
  |
  v
[3] Suena el chirrido de categoria (M11/M44) + particulas del consumidor (senal previa)
  |
  v
[4] datos := { jugador, herramienta_en_mano (M13), item_seleccionado (M14) }
    interactuable.interactuar(datos)   # el consumidor ejecuta su logica
  |
  v
[5] Si duracion_esperada > 0: el gestor queda INTERACTUANDO hasta que el
    consumidor emita `interaccion_terminada(ok)` (o el timeout de M66)
  |
  v
[6] feedback: exito (sonido campana suave) / fallo (tono bajo, NO castigo)
  |
  v
[7] Estado -> SELECCIONANDO; re-evaluacion en el siguiente frame
```

### 2.3 Flujo de cancelación

- **Por distancia:** el jugador sale del rango → señal `objetivo_perdido()`, prompt fade out; si había interacción en curso, `cancelar_interaccion()` al consumidor (cierre suave) y log M103 si el consumidor no responde.
- **Por UI/pausa:** apertura de menú/diálogo/inventario (señal de M53/M57) → estado DORMIDO, prompt oculto, sin procesar input; al cerrar → re-evaluación normal.
- **Por cambio de objetivo:** el fade de entrada/salida dura 0.08–0.12 s; nunca saltos bruscos (regla cozy).
- **Por desregistro:** el interactuable sale del mundo activo (M63) → se retira de la lista en el mismo frame; si era el objetivo, se re-evalúa.

### 2.4 Flujo de persistencia

- On change: eventos de estado relevantes (cofre abierto, puerta, cosecha recogida, animal acariciado) → `GameState.M70.<tipo>.<id> = estado` (escritura diferida 0.5 s para amortizar I/O).
- On load: al cargar zona (M63), cada interactuable consulta `GameState.M70` en `_ready` y se auto-configura (cofre ya abierto → OCULTO/NO_DISPONIBLE "Abierto").

## 3. Estructura de datos

### 3.1 Estructura interna del InteractionManager

```gdscript
var _registro: Array[IInteractable]          # interactuables activos
var _objetivo_actual: IInteractable          # nulo si no hay
var _estado: int                             # InteractionState
var _catalogo: CatalogoCategorias            # Resource cargado
var _histesis_dist: float = 0.15             # umbral anti-parpadeo (m)
var _frames_vision: int = 0                  # contador de espaciado del raycast
var _jugador: Node3D                         # inyectado desde M11
var _voxel_tool: Node                        # inyectado desde M08 (opcional)
```

### 3.2 Datos de evaluación (por interactuable, cache 1 frame)

```gdscript
var _cache: Dictionary = {
  dist: float, angulo: float, valido: bool, atenuado: bool, visto: bool
}
```

### 3.3 Categorías (Resource `categorias_interaccion.tres`)

| Clave | Prioridad | Ícono | Sonido | Línea visión | Label default |
|---|---|---|---|---|---|
| `npc` | 100 | burbuja hablar | chirrido suave | sí | "Hablar con {nombre}" |
| `evento` | 95 | rombo | campana | sí | "Activar" |
| `cofre` | 90 | cofre | madera | sí | "Abrir {nombre}" |
| `puerta` | 80 | puerta | madera/metal | sí | "Abrir {nombre}" |
| `cosecha` | 70 | hoja | hoja | no | "Recoger {nombre}" |
| `animal` | 60 | huella | animal | no | "Acariciar {nombre}" |
| `objeto` | 50 | mano | campana suave | no | "Recoger {nombre}" |
| `decorativo` | 10 | estrella | ligero | no | "Mirar {nombre}" |

## 4. Señales del módulo (eventos de salida)

```gdscript
signal objetivo_seleccionado(objetivo: IInteractable, atenuado: bool)
signal objetivo_perdido()
signal interaccion_iniciada(objetivo: IInteractable, categoria: StringName)
signal interaccion_terminada(objetivo: IInteractable, ok: bool)
signal interaccion_cancelada(objetivo: IInteractable, motivo: String)
signal estado_cambiado(estado: int)
```

Consumidores y HUD se suscriben; nadie más lee la tecla E.

## 5. Integración con sistemas críticos

- **M11 (Personaje):** el gestor lee posición/frente/estado FSM del jugador (inyectado); si el jugador está ocupado (tirando, durmiendo, cutscene) el gestor pasa a DORMIDO automáticamente.
- **M13 (Herramientas):** el prompt de herramienta contextual se resuelve consultando la herramienta en mano (ícono y acción secundaria); el requirement "necesita herramienta X" se valida por `requisitos_cumplidos`.
- **M08 (Voxel):** `VoxelTool` para el raycast de línea de visión (voxel que ocupa la posición → tapa la vista salvo categoría `objeto` bajo el mismo voxel del jugador).
- **M19 (NPC):** el vecino implementa `IInteractable`; al E → despacha al `VillagerDialogueHook` (ya definido en M19); `set_ocupado(true)` → NO_DISPONIBLE "Duerme"/"Ocupado"; el indicador world-space de M19 migra al PromptHUD del 70.
- **M57 (Control):** respeta el InputMap; el prompt muestra el ícono de la acción según dispositivo (teclado E / gamepad A o B).
- **M53 (UI):** el PromptHUD usa un CanvasLayer propio (layer intermedio) y se oculta si hay modal superior (inventario, diálogo).
- **M63 (Streaming):** `registrar()` al entrar en zona activa, `desregistrar()` al salir (mismo frame que el nodo se libera).
- **M66 (Anti-Softlock):** watchdog del estado INTERACTUANDO (timeout configurable, default 60 s) y checks de cooldown eternos.
- **M103 (Logging):** errores de contrato, degradaciones y cancelaciones por timeout se loguean con contexto.

## 6. Rendimiento previsto

| Operación | Costo | Mitigación |
|---|---|---|
| Filtro de distancia por frame | O(n), n < 40 | Barrera temprana por distancia al cuadrado (sin sqrt) |
| Raycast voxel de visión | 1 por ventana de N frames | Espaciado N=4; acotado a categorías que lo requieren |
| Ordenamiento de candidatos | O(k log k), k pequeño | k típico < 8 |
| Prompt (física del indicador) | 1 Label/TextureRect pequeño | Sin sombras costosas; pool del indicador |
| Persistencia diferida | Cada 0.5 s como máximo | Escritura por lote en `GameState` |

Presupuesto total objetivo: < 0.5 ms/frame en escena densa (40 interactuables), medible con el perfilador (M152/111).

## 7. Estados de prueba recomendados (para el implementador)

1. Escenario "mercado": 5+ interactuables a distintas distancias y categorías → selección correcta y estable.
2. Escenario "esquina": objetivo tras una casa voxel de una categoría con línea de visión → descartado.
3. Escenario "cosecha": 30 plantas maduras en fila → prompt en la más cercana sin parpadeo al caminar.
4. Escenario "puerta bloqueante": interacción en curso + tecla E repetida → bloqueada hasta terminar.
5. Escenario "vecino ocupado": NPC dormido → prompt atenuado con razón, no despacha.
6. Escenario "streaming": entrar/salir de zona con M63 → registro/desregistro sin objetivo perdido erróneo.