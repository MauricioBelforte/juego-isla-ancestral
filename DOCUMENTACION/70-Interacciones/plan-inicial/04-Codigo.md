**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 70: Interacciones

## 1. Carácter del Componente

Módulo que **especifica el sistema unificado de interacciones** del jugador con el mundo (detección por proximidad, selección por prioridad, prompts visuales, despacho por contrato, estados y cancelación). Especificación completa: la implementación queda delegada al agente que lo reclame, durante el prototipo del hito M1 (primer playable con Voxel Tools). Aún no se crean scripts: todos los archivos listados a continuación están **pendientes de implementación**.

## 2. Archivos involucrados (implementación prevista — Pendiente de implementación)

```
res://interacciones/interaction_manager.gd          -> Autoload (Interaction), autoridad unica del modulo
res://interacciones/interactable.gd                 -> Clase base Node3D que implementa IInteractable (helpers de registro)
res://interacciones/i_interactable.gd               -> Interfaz GDScript (class_name IInteractable + enum EstadoInteractuable)
res://interacciones/prompt_hud.gd                   -> Control del CanvasLayer: indicador world-space + linea de contexto
res://interacciones/categoria_interaccion.gd        -> Resource con datos por categoria (icono, sonido, prioridad, etiqueta)
res://interacciones/catalogo_categorias.gd          -> Resource contenedor `.tres` con la tabla de categorias
res://interacciones/data/categorias_interaccion.tres -> Configuracion de las 8 categorias del modulo
res://interacciones/indicador_interaccion.tscn      -> Escena del indicador "E + icono" world-space (poolable)
res://interacciones/prompt_contexto.tscn            -> Escena de la linea de contexto del HUD
res://interacciones/test/mock_interactables.gd      -> Mocks de cada categoria para tests (Edit y Play Mode)
```

## 3. Contratos de integración

### 3.1 Entrada (lo que el módulo 70 consume)

- `M11 Personaje Del Jugador`: posición, vector frente, estado FSM (ocupado/cutscene), rango base (4 m; radio de interacción default configurable, 2.5 m).
- `M08 Mundo Voxel`: `VoxelTool` para línea de visión (un voxel sólido entre jugador y objetivo tapa la vista según categoría).
- `M13 Herramientas`: herramienta en mano (para prompt contextual y requisitos `requisitos_cumplidos`).
- `M57 Interfaz De Control`: InputMap, acción `interact` (E teclado / A o B gamepad), normativa de remapeo y localización.
- `M53 UI-UX`: normas de CanvasLayer; señal de apertura de modal (menú, diálogo, inventario) que pone el gestor en DORMIDO.
- `M63 Cargas Y Streaming`: señales de alta/baja de zona para registrar/desregistrar interactuables.
- `M29/M31 Tiempo`: hora/día para requisitos temporales (puertas cerradas de noche, cosechas de temporada).
- `M103 Logging`: servicio de logs estructurados para contratos rotos, degradaciones y timeouts.

### 3.2 Salida (lo que el módulo 70 ofrece)

- Contrato `IInteractable` (interfaz) para cualquier consumidor.
- Señales: `objetivo_seleccionado`, `objetivo_perdido`, `interaccion_iniciada`, `interaccion_terminada`, `interaccion_cancelada`, `estado_cambiado`.
- Catálogo `categorias_interaccion.tres`, abierto al registro de nuevas categorías por consumidores.
- Persistencia: `GameState.M70` (estados relevantes: cofres abiertos, puertas, cosechas recogidas, animales acariciados).

### 3.3 Consumidores del despacho

| Consumidor | Categoría | Acción al presionar E |
|---|---|---|
| M19/M21 | `npc` | `VillagerDialogueHook.solicitar_dialogo()` (sin UI propia) |
| M19/M20 | `npc` (regalo) | flujo de regalo con item seleccionado (M14) |
| M33 | `cosecha` | recoger cultivo maduro (nivel de azada M13 si aplica) |
| M14 | `cofre` | abrir cofre; recompensa al inventario; estado persistente abierto |
| M18 | `puerta` | abrir/cerrar; bloqueada si requiere llave |
| M65 | `animal` | acariciar/alimentar; factor de ánimo |
| M35/M46 | `objeto` | recoger recurso/roca cosechable |
| M22/M24/M26 | `evento` | activar trigger/cutscene/santuario |
| M17 | `decorativo` | feedback de ambiente (animación ligera) |

## 4. Firma de funciones clave (GDScript, Godot 4.x)

### 4.1 `interaction_manager.gd`

```gdscript
class_name InteractionManager
extends Node

# Estado global
enum InteractionState { INACTIVO, SELECCIONANDO, INTERACTUANDO, DORMIDO }
enum EstadoInteractuable { DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO }

signal objetivo_seleccionado(objetivo: IInteractable, atenuado: bool)
signal objetivo_perdido()
signal interaccion_iniciada(objetivo: IInteractable, categoria: StringName)
signal interaccion_terminada(objetivo: IInteractable, ok: bool)
signal interaccion_cancelada(objetivo: IInteractable, motivo: String)
signal estado_cambiado(estado: int)

func registrar(interactuable: IInteractable) -> void
func desregistrar(interactuable: IInteractable) -> void
func configurar_jugador(jugador: Node3D) -> void
func configurar_voxel(voxel_tool) -> void
func evaluar_candidatos() -> void            # paso 1-4 del flujo de deteccion
func seleccionar_objetivo() -> IInteractable # paso 5-7 (orden + histeresis)
func presionar_interact() -> void            # entrada unica de input
func iniciar_interaccion(objetivo: IInteractable) -> void
func finalizar_interaccion(objetivo: IInteractable, ok: bool) -> void
func cancelar_interaccion(objetivo: IInteractable, motivo: String) -> void
func set_estado_dormido(dormido: bool) -> void
func obtener_objetivo_actual() -> IInteractable
func _procesar_persistencia_diferida() -> void
```

### 4.2 `i_interactable.gd` (contrato)

```gdscript
class_name IInteractable

enum EstadoInteractuable { DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO }

func obtener_estado() -> IInteractable.EstadoInteractuable
func obtener_categoria() -> StringName
func obtener_posicion_interaccion() -> Vector3
func obtener_radio() -> float
func obtener_nombre_prompt() -> String          # localizable (tr())
func obtener_razon_no_disponible() -> String    # localizable; "" = sin razon
func requisitos_cumplidos(jugador) -> bool
func interactuar(datos: Dictionary) -> void
func cancelar_interaccion() -> void
func obtener_duracion_esperada() -> float       # 0 = instantanea
```

### 4.3 `prompt_hud.gd` (presentación)

```gdscript
class_name PromptHUD
extends CanvasLayer

func mostrar_objetivo(objetivo: IInteractable, atenuado: bool) -> void
func ocultar_prompt() -> void
func _fade_in(delta: float) -> void
func _fade_out(delta: float) -> void
func _actualizar_indicador(posicion_mundo: Vector3) -> void  # sigue al objetivo en pantalla
func set_icono_dispositivo(icono: Texture2D) -> void         # E / A / B segun M57
```

### 4.4 `interactable.gd` (base de consumidores)

```gdscript
class_name Interactable
extends Node3D
# Implementa IInteractable con defaults; los consumidores overridean:
# - interactuar(datos)
# - obtener_nombre_prompt() / requisitos_cumplidos(jugador)

func _ready() -> void:
    Interaction.registrar(self)

func _exit_tree() -> void:
    Interaction.desregistrar(self)
```

## 5. Referencias a documentación relacionada

- M08 `03-Diseno.md` — API de VoxelTool para el raycast de línea de visión.
- M11 `03-Diseno.md` sección 3 — prompt contextual y rango de interacción del personaje.
- M13 `04-Codigo.md` — contrato `ToolAction` y despachos de herramientas.
- M19 `04-Codigo.md` — `VillagerDialogueHook` y estado `set_ocupado` (integración de vecinos).
- M57 — InputMap, localización y remapeo de la acción `interact`.
- M103 — logging estructurado de degradaciones de contrato.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Definí el problema, objetivo, alcance y restricciones del sistema unificado de interacciones (módulo 70).
- Especifiqué 25 requisitos funcionales (detección, selección, prompts, acción, cancelación, feedback, requisitos, persistencia, gamepad, accesibilidad) y 12 no funcionales (cozy, rendimiento, desacople, localización, pausa, determinismo, testabilidad).
- Analicé el dominio: 8 categorías de interactuables con consumidores reales del proyecto (M19, M33, M14, M18, M65, M35, M22/M24/M26), detección por registro + distancia con línea de visión voxel opcional, prioridad determinística (categoría, distancia, ángulo) con histéresis anti-parpadeo, doble prompt (indicador world-space + línea HUD) y estados gestor/interactuable.
- Diseñé la arquitectura: InteractionManager autoload, contrato IInteractable (interfaz GDScript), Interactable base, PromptHUD en CanvasLayer propio, catálogo de categorías en Resource `.tres`, señales de salida, flujos (detección, acción, cancelación, persistencia) y presupuesto de rendimiento (< 0.5 ms/frame).
- Especifiqué los archivos previstos bajo `res://interacciones/` (Pendiente de implementación), firmas GDScript de las funciones clave y contratos de entrada/salida con M11, M08, M13, M57, M53, M63 y M103.
- Checklist de 130+ ítems completado, cubriendo RF, RN, diseño, integración con 11/13/19 (y demás consumidores), edge cases, optimización, documentación y testings.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé ningún script: la implementación está delegada (Pendiente de implementación), el código real debe validar las firmas aquí propuestas.
- No ejecuté tests (no hay implementación todavía); el plan de testings queda en el 06-Plan-Testings.md al implementar.
- No resolví la tecla final de interacción entre la "E" de esta especificación y la "F" histórica de M11/M19: se requiere decisión de unificación en M57 al implementar (esta especificación usa E).
- No definí los iconos finales ni los assets de sonido de cada categoría (delegado a M44/M53 y a los consumidores).

### Recomendaciones para el próximo agente
- Implementar respetando el desacople: el InteractionManager NO debe importar módulos consumidores; usar solo el contrato IInteractable y las señales.
- Verificar con el jugador de M11 (posición, frente, estados FSM) y con VoxelTool de M08 la integración antes de pulir prompts.
- Unificar la acción "interact" en el InputMap de M57 (E por defecto) y migrar las burbujas world-space de M19/M11 hacia PromptHUD del 70 para evitar prompts duplicados.
- Respetar el presupuesto de 0.5 ms/frame: espaciar el raycast de línea de visión (N=4 frames) y filtrar por distancia al cuadrado.
- Implementar primero los mocks de las 8 categorías para el escenario de pruebas "mercado" antes de integrar consumidores reales.
- No olvidar el watchdog anti-softlock (M66): el estado INTERACTUANDO debe tener timeout configurable.
- Al terminar, crear el log en Logs/, marcar el checklist del plan-actual y actualizar CHECKLIST-GLOBAL.md (módulo 70: Progreso y Estado).