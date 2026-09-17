# Me decidi por continuar con la Opcion 1

Continuamos con la **estabilización de las animaciones en Godot**. Antes de crear caminar o sentarse, conviene corregir varios puntos del paso anterior para no propagarlos a los 35 personajes.

## 1. Correcciones importantes del rig anterior

El rig que entregué es un **prototipo rígido**, no un humanoide deformable terminado:

- `ARM_R` está vinculado a `UPPER_ARM.R`. Por tanto, **el antebrazo y la mano no deforman ese mesh**. Las herramientas siguen al brazo completo, no al hueso de la mano.
- La cabeza está vinculada a un hueso cuyo origen no coincide exactamente con el pivote de cuello solicitado. Eso puede producir una rotación poco natural.
- **IDLE no quedó configurado explícitamente como bucle**.
- La exportación de las acciones depende del modo de animación del exportador glTF. Los nombres y la cantidad de clips **deben comprobarse en el archivo importado**.
- El uso directo de `Action.fcurves` pertenece al flujo de acciones heredado y puede requerir adaptación en versiones recientes de Blender. Para probar ese script sin modificarlo, utiliza **Blender 4.2 LTS**.
- Un personaje emparentado a huesos **no debe darse por importado como mesh con skinning**. Godot puede representar ese parentesco mediante nodos de unión a huesos; hay que inspeccionar la escena importada.

**No recomiendo extender todavía ese rig a los 35.** Primero estabilizamos Luna y comprobamos que los clips exportados realmente funcionan.

---

# 2. Sustituir el controlador de animaciones

Este controlador reemplaza `npc_animado.gd` de la respuesta anterior.

Reutiliza `NPCVisualLOD`, pero mejora lo siguiente:

- Busca el `AnimationPlayer` por tipo, no por nombre.
- Imprime los nombres reales de los clips importados.
- Crea copias locales de IDLE y SALUDO para configurar sus bucles sin modificar los recursos importados.
- Evita múltiples saludos simultáneos.
- Interrumpe el saludo al abandonar ALTA.
- Retoma IDLE cuando vuelve a ALTA.
- No usa un `await` que pueda quedar esperando una animación interrumpida.
- Permite desactivar el saludo en personajes con herramientas voluminosas.

## Archivo: `res://npc/scripts/npc_animado.gd`

```gdscript
class_name NPCAnimado
extends NPCVisualLOD

signal greeting_started
signal greeting_finished
signal greeting_cancelled

@export_category("Clips importados")
# Copia aquí los nombres exactos que imprime el AnimationPlayer.
@export var source_idle: StringName = &""
@export var source_greeting: StringName = &""

@export_category("Reproducción")
@export_range(0.0, 1.0, 0.01) var crossfade_seconds: float = 0.20
@export_range(0.1, 3.0, 0.05) var playback_speed: float = 1.0

@export_category("Seguridad del saludo")
# Déjalo desactivado hasta revisar la trayectoria del brazo.
@export var greeting_enabled: bool = false
@export_range(0.0, 30.0, 0.5) var greeting_cooldown: float = 4.0

# Protección frente a un clip que no termina como se esperaba.
@export_range(1.0, 30.0, 0.5) var greeting_timeout: float = 8.0

@export_category("Diagnóstico")
@export var print_imported_clips: bool = true

const RUNTIME_LIBRARY: StringName = &"COZY_RUNTIME"
const IDLE_CLIP: StringName = &"COZY_RUNTIME/IDLE"
const GREETING_CLIP: StringName = &"COZY_RUNTIME/SALUDO"

var _animation_player: AnimationPlayer
var _greeting_timer: Timer

var _animation_ready: bool = false
var _has_greeting: bool = false
var _greeting_active: bool = false

var _next_greeting_time: float = 0.0


func _ready() -> void:
	# Conectamos antes de que la clase base seleccione el primer LOD.
	lod_changed.connect(_on_visual_lod_changed)

	super._ready()

	if _visuals.size() != 3:
		return

	_animation_player = _find_animation_player(_visuals[Level.HIGH])

	if _animation_player == null:
		push_error(
			"%s: el visual ALTA no contiene AnimationPlayer." % name
		)
		return

	if print_imported_clips:
		print(
			"%s — clips importados: %s"
			% [name, _animation_player.get_animation_list()]
		)

	if not _prepare_local_animations():
		return

	_animation_player.animation_finished.connect(
		_on_animation_finished
	)

	_greeting_timer = Timer.new()
	_greeting_timer.name = "GREETING_WATCHDOG"
	_greeting_timer.one_shot = true
	add_child(_greeting_timer)
	_greeting_timer.timeout.connect(_on_greeting_timeout)

	_animation_ready = true

	if get_current_lod() == Level.HIGH:
		_play_idle()
	else:
		_animation_player.stop()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var result := _find_animation_player(child)

		if result != null:
			return result

	return null


func _prepare_local_animations() -> bool:
	if source_idle == &"":
		push_error(
			"%s: configura source_idle con el nombre real del clip."
			% name
		)
		return false

	if not _animation_player.has_animation(source_idle):
		push_error(
			"%s: no existe el clip IDLE '%s'."
			% [name, source_idle]
		)
		return false

	# El nombre se reserva para esta instancia.
	if _animation_player.has_animation_library(RUNTIME_LIBRARY):
		push_error(
			"%s: ya existe una biblioteca llamada %s."
			% [name, RUNTIME_LIBRARY]
		)
		return false

	var library := AnimationLibrary.new()

	var idle_original := _animation_player.get_animation(source_idle)
	var idle_copy := idle_original.duplicate(true) as Animation

	if idle_copy.length <= 0.0:
		push_error("%s: el clip IDLE tiene duración cero." % name)
		return false

	# Configuramos el bucle sobre una copia, no sobre el GLB importado.
	idle_copy.loop_mode = Animation.LOOP_LINEAR
	library.add_animation(&"IDLE", idle_copy)

	_has_greeting = false

	if source_greeting != &"":
		if _animation_player.has_animation(source_greeting):
			var greeting_original := _animation_player.get_animation(
				source_greeting
			)
			var greeting_copy := greeting_original.duplicate(true) as Animation

			if greeting_copy.length > 0.0:
				greeting_copy.loop_mode = Animation.LOOP_NONE
				library.add_animation(&"SALUDO", greeting_copy)
				_has_greeting = true
			else:
				push_warning(
					"%s: SALUDO tiene duración cero; se desactiva."
					% name
				)
		else:
			push_warning(
				"%s: no existe el clip SALUDO '%s'."
				% [name, source_greeting]
			)

	var error := _animation_player.add_animation_library(
		RUNTIME_LIBRARY,
		library
	)

	if error != OK:
		push_error(
			"%s: no se pudo crear la biblioteca local de animaciones."
			% name
		)
		return false

	return true


func _play_idle() -> void:
	if not _animation_ready:
		return

	if get_current_lod() != Level.HIGH:
		return

	_animation_player.play(
		IDLE_CLIP,
		crossfade_seconds,
		playback_speed
	)


func saludar() -> bool:
	if not _animation_ready:
		return false

	if not greeting_enabled or not _has_greeting:
		return false

	if get_current_lod() != Level.HIGH:
		return false

	if _greeting_active:
		return false

	var now := Time.get_ticks_msec() / 1000.0

	if now < _next_greeting_time:
		return false

	_greeting_active = true
	_next_greeting_time = now + greeting_cooldown

	_animation_player.play(
		GREETING_CLIP,
		crossfade_seconds,
		playback_speed
	)

	_greeting_timer.start(greeting_timeout)
	greeting_started.emit()

	return true


func cancelar_saludo() -> void:
	if not _greeting_active:
		return

	_greeting_active = false
	_greeting_timer.stop()

	if _animation_ready:
		_animation_player.stop()

	greeting_cancelled.emit()

	if get_current_lod() == Level.HIGH:
		_play_idle()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != GREETING_CLIP:
		return

	if not _greeting_active:
		return

	_greeting_active = false
	_greeting_timer.stop()

	greeting_finished.emit()
	_play_idle()


func _on_greeting_timeout() -> void:
	if not _greeting_active:
		return

	push_warning(
		"%s: el saludo superó el tiempo de seguridad; se cancela."
		% name
	)

	cancelar_saludo()


func _on_visual_lod_changed(
	_previous_lod: int,
	current_lod: int
) -> void:
	# La primera señal puede llegar durante super._ready().
	if not _animation_ready:
		return

	if current_lod == Level.HIGH:
		_play_idle()
		return

	if _greeting_active:
		cancelar_saludo()
	else:
		_animation_player.stop()
```

### Configuración

1. Asigna el GLB animado a `high_scene`.
2. Asigna MEDIA y BAJA estáticas de la **misma versión geométrica**.
3. Ejecuta una vez la escena.
4. Copia los nombres que aparecen en:

```text
NPC_VISUAL — clips importados: [...]
```

5. Pégalos en:
   - `source_idle`
   - `source_greeting`
6. Activa `greeting_enabled` únicamente después de revisar la animación.

**No asumas nombres como `ARM|IDLE`**: dependen de cómo se hayan exportado y nombrado las acciones.

---

# 3. Botón de prueba sin lógica de proximidad

Antes de conectar áreas, diálogos o comportamiento, prueba el saludo con una acción de entrada.

En **Project Settings → Input Map**, crea:

```text
npc_saludar_prueba
```

Asígnale, por ejemplo, la tecla **G**.

Guarda este script en el nodo raíz de tu escena de prueba:

```gdscript
extends Node3D

@export var npc: NPCAnimado


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("npc_saludar_prueba"):
		if npc == null:
			return

		var accepted := npc.saludar()

		if not accepted:
			print(
				"Saludo rechazado: revisa LOD, configuración, "
				+ "cooldown o reproducción actual."
			)

		get_viewport().set_input_as_handled()
```

---

# 4. Pruebas que debemos superar

| Prueba | Resultado esperado |
|---|---|
| Permanecer 10 segundos en ALTA | IDLE continúa en bucle |
| Pulsar G varias veces | No se acumulan saludos ni esperas |
| Terminar SALUDO | Vuelve a IDLE |
| Alejarse durante SALUDO | Cancela la reproducción y muestra el LOD lejano |
| Volver a ALTA | Retoma IDLE |
| No configurar SALUDO | IDLE sigue funcionando |
| Configurar mal IDLE | Mensaje claro de error |
| Compartir un mismo GLB entre dos NPCs | Cambiar el bucle local no modifica el recurso importado |

### Dos problemas que este controlador no corrige

**1. Salto de pose al cambiar de LOD.**  
MEDIA y BAJA están estáticas. Pasar de un brazo levantado a una pose neutra puede notarse. La histéresis evita cambios repetidos, pero no elimina ese salto.

**2. Intersecciones de herramientas.**  
El saludo genérico puede hacer que una caña, una lanza o un báculo atraviesen la cabeza o el sombrero. Para esos personajes, deja el saludo desactivado y utiliza después un gesto específico —por ejemplo, una inclinación de cabeza—.

---

## Siguiente hito: rig deformable de un solo NPC

Una vez que Luna supere estas pruebas, el siguiente trabajo de modelado es **reemplazar el prototipo rígido por un rig con pesos**:

- Brazo distribuido entre hombro, codo y muñeca.
- Pierna distribuida entre cadera, rodilla y tobillo.
- Cabeza rotando desde el cuello correcto.
- Herramientas vinculadas de manera explícita a la mano.
- Falda y delantal con tratamiento propio.
- MEDIA compatible con el mismo esqueleto.

**No conviene generar caminar todavía sobre los brazos y piernas rígidos del paso anterior:** produciría movimiento de piezas completas, no una marcha humana convincente. Este controlador deja preparada la reproducción, pero la calidad del movimiento depende de corregir primero ese rig.