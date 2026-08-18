**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 92: Tutorial

## 1. Carácter del Componente

Módulo que **especifica el sistema de tutorial integrado no intrusivo** de la isla Aurora (guiones por capítulos, triggers contextuales, pistas world-space, secuencia guiada del prólogo, sistema de consejos opcionales, skip/re-play y revalidación de "jugador que ya sabe"). Especificación completa: la implementación queda delegada al agente que la reclame, durante el prototipo del hito M1 (primer playable con Voxel Tools). Aún no se crean scripts: todos los archivos listados a continuación están **pendientes de implementación**.

## 2. Archivos involucrados (implementación prevista — Pendiente de implementación)

```
res://tutorial/tutorial_manager.gd            -> Autoload (Tutorial), autoridad unica del modulo
res://tutorial/tutorial_state.gd              -> Resource de estado persistente (GameState.M92, RN6)
res://tutorial/capitulo_guion.gd              -> Resource de guion por capitulo (pasos + meta)
res://tutorial/data/capitulos_llegada.tres    -> Guiones: Llegada + Moverse (prologo)
res://tutorial/data/capitulos_interactuar.tres-> Guiones: Interactuar (M70) + Herramientas (M13)
res://tutorial/data/capitulos_actividades.tres-> Guiones: Cultivo (M33), Pesca (M34), Mineria (M35)
res://tutorial/data/capitulos_social.tres     -> Guiones: Crafting (M16) + Primeros Vecinos (M19/21)
res://tutorial/trigger.gd                     -> Clase base de trigger
res://tutorial/trigger_senal.gd               -> Trigger por senal de sistema (M70, M33, M34, M35, M16...)
res://tutorial/trigger_mundo.gd               -> Trigger por proximidad a ITutorialTarget (mundo voxel)
res://tutorial/trigger_accion.gd              -> Trigger por primera accion del jugador (mover, E...)
res://tutorial/i_tutorial_target.gd           -> Interfaz opcional para nodos que marcan lecciones
res://tutorial/pista_contextual.gd            -> Logica de burbuja world-space (pooled)
res://tutorial/pista_pool.gd                  -> Pool de burbujas (max 2 vivas, RN4)
res://tutorial/consejo.gd                     -> Resource de consejo opcional (sistema de tips)
res://tutorial/sistema_consejos.gd            -> Gestor de consejos (1 sola vez, cooldown, contextos)
res://tutorial/revalidacion.gd                -> Mapeo senal-maestria -> capitulo (RF3/RF19)
res://tutorial/watchdog.gd                    -> Timeout + reprogramacion + descarte (RF23/M66)
res://tutorial/ui/burbuja_pista.tscn          -> Escena de prueba de la burbuja (depuracion; UI final = M53)
res://tutorial/test/mock_sistemas.gd          -> Mocks de M33/M34/M35/M70/M13/M16 para tests
res://tutorial/test/test_capitulos.gd         -> Suite de tests (Edit Mode y Play Mode)
```

## 3. Contratos de integración

### 3.1 Entrada (lo que el módulo 92 consume)

- `M70 Interacciones`: señales `interaccion_iniciada`, `interaccion_terminada`, `interaccion_cancelada`; prompt actual para no duplicar iconos.
- `M11/M57 Movimiento e Input`: InputMap (acciones move/interact/tool), dispositivo activo para iconos.
- `M33 Agricultura`: señales de cultivo (plantado, regado, cosechado).
- `M34 Pesca`: señales de fases (lanzar, captura, recoger).
- `M35 Minería`: señal `veta_rota` y estado de energía del jugador.
- `M16 Crafting`: señal `item_crafteado`.
- `M19/M21 NPC y Diálogo`: señales `dialogo_iniciado`/`dialogo_terminado`, estado `set_ocupado` (no disparar lecciones sobre vecinos dormidos).
- `M53 UI-UX`: normas de presentación, localización, señal de apertura de modal (DORMIDO).
- `M58 Accesibilidad`: preferencias de duración/contraste/tamaño.
- `M66 Anti-Softlock`: watchdog global (timeouts).
- `M103 Logging`: logs estructurados.

### 3.2 Salida (lo que el módulo 92 ofrece)

- Señales: `capitulo_iniciado`, `paso_mostrado`, `paso_completado`, `capitulo_completado`, `pista_solicitada(data)`, `pista_ocultada`, `consejo_mostrado`, `estado_cambiado`, `tutorial_disponible_cambios`.
- `ITutorialTarget` (interfaz opcional) para que objetos del mundo se autoetiqueten como objetivo de lección.
- Datos serializados de pistas/guiones para que M53 dibuje (el 92 no dibuja UI final).
- Persistencia `GameState.M92`.

## 4. Firma de funciones clave (GDScript, Godot 4.x)

### 4.1 `tutorial_manager.gd`

```gdscript
class_name TutorialManager
extends Node

enum Estado { ACTIVO, ESPERANDO, PISTA, CONSECUENCIA, SKIPPED, DORMIDO }

signal capitulo_iniciado(capitulo_id: StringName)
signal paso_mostrado(capitulo_id: StringName, paso_idx: int)
signal paso_completado(capitulo_id: StringName, paso_idx: int)
signal capitulo_completado(capitulo_id: StringName, silencioso: bool)
signal pista_solicitada(datos: Dictionary)     # M53 dibuja la burbuja
signal pista_ocultada(pista_id: StringName)
signal consejo_mostrado(consejo_id: StringName)
signal estado_cambiado(estado: int)

func configurar(estado_inicial: Dictionary) -> void
func registrar_guion(guion: CapituloGuion) -> void
func registrar_trigger(trigger: Trigger) -> void
func evaluar_trigger(trigger: Trigger, contexto: Dictionary) -> void
func desplegar_capitulo(capitulo_id: StringName) -> bool
func completar_capitulo(capitulo_id: StringName, silencioso: bool) -> void
func marcar_senial_maestria(dominio: StringName, senial: StringName) -> void  # RF3/RF19
func skip_global() -> void
func skip_capitulo() -> void
func replay_capitulo(capitulo_id: StringName) -> void   # RN11 (snapshot previo)
func set_dormido(dormido: bool) -> void
func pistas_activas() -> Array[StringName]
func serializar_estado() -> Dictionary
func restaurar_estado(datos: Dictionary) -> void
```

### 4.2 `capitulo_guion.gd` (Resource)

```gdscript
class_name CapituloGuion
extends Resource

enum TipoPaso { PISTA, SECUENCIA, CONSEJO }

@export var id: StringName
@export var titulo: StringName          # clave tr()
@export var pasos: Array[PasoGuion]
@export var meta_dominio: StringName    # dominio de la senal de maestria
@export var meta_senial: StringName     # senal de maestria (revalidacion)
@export var timeout_default: float = 120.0
@export var rejugable: bool = true

func obtener_paso(idx: int) -> PasoGuion
func esta_completado(estado: Dictionary) -> bool
```

### 4.3 `trigger_senal.gd` / `trigger_mundo.gd` / `trigger_accion.gd`

```gdscript
class_name TriggerSenal
extends Trigger

@export var dominio: StringName         # "m34_pesca", "m70_interaccion", ...
@export var senial: StringName
@export var capitulo: StringName
@export var condiciones: Array[Callable]  # contexto -> bool (dia, zona, hora)

func evaluar(dominio: StringName, senial: StringName, contexto: Dictionary) -> bool
```

```gdscript
class_name TriggerMundo
extends Trigger

@export var objetivo: NodePath          # ITutorialTarget
@export var radio: float = 4.0
@export var capitulo: StringName

func evaluar(jugador_pos: Vector3, mundo) -> bool
```

```gdscript
class_name TriggerAccion
extends Trigger

@export var accion: StringName          # "move", "interact", "tool_eq"
@export var capitulo: StringName

func evaluar(accion: StringName, contexto: Dictionary) -> bool
```

### 4.4 `pista_contextual.gd` / `pista_pool.gd`

```gdscript
class_name PistaContextual
extends Node3D

func mostrar(texto_clave: StringName, posicion_mundo: Vector3, accion_tecla: StringName, duracion_min: float) -> void
func ocultar_con_fade() -> void
func es_valida(jugador_pos: Vector3) -> bool   # distancia <= 6 m
```

```gdscript
class_name PistaPool
extends Node

func solicitar() -> PistaContextual
func liberar(pista: PistaContextual) -> void
func vivas() -> int
```

### 4.5 `sistema_consejos.gd`

```gdscript
class_name SistemaConsejos
extends Node

signal consejo_mostrado(consejo_id: StringName)

func registrar_consejo(consejo: Consejo) -> void
func contexto_permitido(contexto: StringName) -> bool   # "carga", "caminata", "pausa"
func evaluar(contexto: StringName) -> void              # cooldown >= 90 s
func marcar_visto(consejo_id: StringName) -> void
func activo() -> bool
```

### 4.6 `watchdog.gd`

```gdscript
class_name TutorialWatchdog
extends Node

func vigilar(capitulo_id: StringName, timeout: float) -> void
func liberar(capitulo_id: StringName) -> void
func _on_timeout(capitulo_id: StringName) -> void   # reprogramar x3 o descartar con log
```

## 5. Referencias a documentación relacionada

- M70 `plan-actual/04-Codigo.md` — señales de interacción y prompt HUD (evitar duplicación de iconos).
- M53 `03-Diseno.md` — capa de presentación y opciones del juego (interruptores de tutorial).
- M57 — InputMap y remapeo (iconos dinámicos de tecla).
- M58 — preferencias de accesibilidad (duración, contraste).
- M66 — watchdog anti-softlock global (timeouts).
- M103 — logs de degradación y revalidación.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Definí el problema, objetivo, alcance y restricciones del tutorial integrado no intrusivo (módulo 92), alineado con la visión cozy de la isla Aurora y con el aprendizaje por inmersión.
- Especifiqué 25 requisitos funcionales (capítulos, triggers, pistas contextuales, guiones, skip, re-play, consejos, revalidación, watchdog, localización, iconografía dinámica) y 12 no funcionales (cozy, no intrusión, duración, rendimiento, desacople, persistencia, accesibilidad, rejugabilidad).
- Analicé el dominio: 4 tipos de tutorial (contextual, secuencia guiada, sandbox libre, pared de texto), onboarding en referencias cozy (Stardew Valley, Cozy Grove, Animal Crossing), accesibilidad, y rejugabilidad con "jugador que ya sabe"; elegí el híbrido A4 (prólogo guiado suave + capítulos contextuales + consejos opcionales + skip/replay/revalidación).
- Diseñé la arquitectura: TutorialManager autoload, guiones como Resources, 3 tipos de trigger (señal, mundo, acción), pool de pistas world-space (≤ 2 vivas), sistema de consejos con cooldown, watchdog con re-programación, y flujos (disparo→lección→cierre, skip/re-play con snapshot, recuperación, revalidación).
- Especifiqué los archivos previstos bajo `res://tutorial/` (Pendiente de implementación), firmas GDScript de las funciones clave y contratos de entrada/salida con M70, M53, M13, M33, M34, M35, M16, M19/M21, M57, M58, M66 y M103.
- Checklist de 170+ ítems completado, cubriendo RF, RN, diseño, integración con 53/70/13/33/34/35/16/19/21, edge cases, optimización, documentación y testings.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé ningún script: la implementación está delegada (Pendiente de implementación), el código real debe validar las firmas aquí propuestas.
- No ejecuté tests (no hay implementación todavía); el plan de testings queda en el 06-Plan-Testings.md al implementar.
- No definí los textos finales de las pistas ni los iconos (dependen de la localización de M53 y de los assets de M44), solo las claves `tr()` y las reglas de longitud.
- No resolví qué NPC concreto oficia de "tutor" en el prólogo (depende de M19/M21 y de la historia de M22); el 92 es agnóstico al respecto.
- No definí la sincronización con M104 Analytics para medir la duración efectiva del tutorial (RN3); queda como recomendación.

### Recomendaciones para el próximo agente
- Implementar respetando el desacople: el TutorialManager NO debe importar M13/M33/M34/M35/M16/M19/M21; usar solo señales registradas por delegación (dominio+señal) o conexiones directas unidireccionales.
- Verificar primero con mocks (M70/M33/M34/M35) la suite de tests antes de integrar sistemas reales; el 92 debe arrancar como esqueleto sin dependencia dura de módulos aún no implementados.
- Coordinar con M53 para que la burbuja y los marcadores los dibuje la capa de presentación; los .tscn del 92 son solo de depuración.
- Validar la regla de "≤ 2 pistas vivas" con el presupuesto de 0.2 ms/frame (RN4) en la zona de la plaza con varios NPC y cultivos.
- Al terminar, crear el log en Logs/, marcar el checklist del plan-actual y actualizar CHECKLIST-GLOBAL.md (módulo 92: Progreso y Estado).