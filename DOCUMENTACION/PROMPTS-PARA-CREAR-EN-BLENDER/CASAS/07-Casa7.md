Seguimos con la **coordinación completa de acciones del personaje**:

```text
LIBRE
  ↓
CAMINANDO AL MUEBLE
  ↓
SENTÁNDOSE
  ↓
SENTADO
  ↓
LEVANTÁNDOSE
  ↓
LIBRE
```

La idea es que **jugador y NPC usen el mismo circuito**, sin que la navegación, el controlador habitual y el asiento intenten mover al personaje simultáneamente.

**Esta entrega trabaja con las sillas ya configuradas.** No añade animaciones ni corrige automáticamente sus posiciones.

> No he ejecutado estos scripts en Godot. Son una integración sobre los archivos anteriores y necesitan las pruebas del final. Tampoco voy a suponer métodos adicionales de `CozyNPC`: usaremos un componente independiente.

---

# 1. Quién controla el movimiento

Vamos a establecer una única responsabilidad por etapa:

| Etapa | Responsable |
|---|---|
| Libre | Controlador habitual del personaje |
| Caminando a la silla | `AccionMueble` |
| Alineándose y sentado | `ActorAsiento` |
| Salida | `ActorAsiento` |
| Después de levantarse | Controlador habitual |

La reserva se mantiene desde que se acepta la acción hasta que el personaje se levanta.

Si la aproximación falla:

```text
Cancelar ruta
→ liberar silla
→ restaurar controlador
```

Si la salida está bloqueada:

```text
Mantener postura sentada
→ mantener reserva
→ permitir otro intento
```

---

# 2. Estructura del personaje

Añadí:

```text
PLAYER o NPC
├── CollisionShape3D
├── Modelo
├── ActorAsiento
├── AgenteMuebles           ← NavigationAgent3D
└── AccionMueble            ← nuevo script
```

`AgenteMuebles` será exclusivo de estas acciones.

**No reutilices por ahora el agente de deambulación del NPC.** Así evitamos sobrescribir su destino anterior.

Configuración inicial orientativa:

```text
Path Desired Distance:   0.12
Target Desired Distance: 0.18
Avoidance Enabled:       false
```

El radio y la altura del agente deben corresponder al personaje. Recordá que esos valores **no sustituyen el radio y la altura usados al hornear el NavigationMesh**.

---

# 3. Coordinador `accion_mueble.gd`

Guardá:

```text
res://casas/scripts/accion_mueble.gd
```

```gdscript
class_name AccionMueble
extends Node

signal estado_cambiado(estado: Estado)
signal accion_finalizada
signal accion_cancelada(motivo: String)

enum Estado {
	LIBRE,
	CAMINANDO,
	SENTANDO,
	SENTADO,
	LEVANTANDO,
}

@export_category("Referencias")
@export var actor: CharacterBody3D
@export var asiento: ActorAsiento
@export var agente: NavigationAgent3D

@export_category("Aproximación")
@export var velocidad: float = 2.0
@export var gravedad: float = 9.8
@export var tiempo_maximo: float = 30.0

# Se compara contra el punto de aproximación configurado.
@export var distancia_llegada: float = 0.22

# No corregimos puntos alejados de la navegación silenciosamente.
@export var tolerancia_proyeccion: float = 0.25

@export_category("Orientación")
# Asume que el frente lógico del CharacterBody3D es -Z.
@export var orientar_al_caminar: bool = true
@export var velocidad_giro: float = 10.0

@export_category("Entrada del jugador")
@export var permitir_cancelacion_por_tecla: bool = true
@export var accion_cancelar: StringName = &"cancelar_accion"

var estado: Estado = Estado.LIBRE

var _destino: SillaCasa
var _control: Node

var _callbacks: Dictionary = {}
var _control_suspendido: bool = false

var _tiempo: float = 0.0
var _cancelacion_pendiente: bool = false


func _ready() -> void:
	if not _configuracion_valida():
		push_error(
			"%s: revisá actor, asiento y agente."
			% name
		)
		set_physics_process(false)
		return

	_control = (
		asiento.controlador
		if asiento.controlador != null
		else actor
	)

	if _control == self or _control == asiento:
		push_error(
			"El controlador habitual no puede ser AccionMueble "
			+ "ni ActorAsiento."
		)
		set_physics_process(false)
		return

	asiento.sentado.connect(_al_quedar_sentado)
	asiento.levantado.connect(_al_quedar_libre)

	# Este componente mueve al actor directamente.
	# No utiliza la velocidad de avoidance.
	agente.avoidance_enabled = false


func _configuracion_valida() -> bool:
	return (
		is_instance_valid(actor)
		and is_instance_valid(asiento)
		and is_instance_valid(agente)
		and asiento.actor == actor
		and agente.get_parent() == actor
	)


func esta_libre() -> bool:
	return estado == Estado.LIBRE and asiento.esta_libre()


func solicitar(silla: SillaCasa) -> bool:
	if not _configuracion_valida():
		return false

	if not is_instance_valid(_control):
		return false

	if not esta_libre() or not is_instance_valid(silla):
		return false

	if (
		not silla.posicion_uso_definida
		or not silla.pose_definida
		or not silla.salida_definida
	):
		push_warning(
			"La silla no tiene aproximación, pose y salida completas."
		)
		return false

	if not silla.reservar(actor):
		return false

	_destino = silla
	_tiempo = 0.0
	_cancelacion_pendiente = false

	var punto := silla.obtener_posicion_uso()
	var tolerancia := _tolerancia_llegada()

	# Si ya está junto al punto, no necesita una ruta.
	if actor.global_position.distance_to(punto) > tolerancia:
		var resultado := _preparar_ruta(punto)

		if not resultado.get("valida", false):
			silla.liberar(actor)
			_destino = null

			accion_cancelada.emit(
				String(resultado.get("motivo", "Ruta inválida."))
			)
			return false

		agente.target_position = resultado["destino"]

	_suspender_controlador()
	actor.velocity = Vector3.ZERO

	_cambiar_estado(Estado.CAMINANDO)
	return true


func _preparar_ruta(objetivo: Vector3) -> Dictionary:
	var mapa := agente.get_navigation_map()

	if (
		not mapa.is_valid()
		or NavigationServer3D.map_get_iteration_id(mapa) == 0
	):
		return {
			"valida": false,
			"motivo": "La navegación todavía no está sincronizada.",
		}

	var cercano := NavigationServer3D.map_get_closest_point(
		mapa,
		objetivo
	)

	if cercano.distance_to(objetivo) > tolerancia_proyeccion:
		return {
			"valida": false,
			"motivo": "La aproximación está fuera de navegación.",
		}

	var inicio := NavigationServer3D.map_get_closest_point(
		mapa,
		actor.global_position
	)

	if inicio.distance_to(actor.global_position) > tolerancia_proyeccion:
		return {
			"valida": false,
			"motivo": "El personaje está fuera de navegación.",
		}

	var ruta := NavigationServer3D.map_get_path(
		mapa,
		inicio,
		cercano,
		true,
		agente.navigation_layers
	)

	if ruta.is_empty():
		return {
			"valida": false,
			"motivo": "No hay una ruta hacia la silla.",
		}

	if ruta[ruta.size() - 1].distance_to(cercano) > tolerancia_proyeccion:
		return {
			"valida": false,
			"motivo": "La ruta no alcanza la zona de la silla.",
		}

	return {
		"valida": true,
		"destino": cercano,
	}


func _physics_process(delta: float) -> void:
	if estado != Estado.CAMINANDO:
		return

	if _cancelacion_pendiente:
		_cancelar_aproximacion("Acción cancelada.")
		return

	if not is_instance_valid(_destino):
		_cancelar_aproximacion("La silla ya no existe.")
		return

	if not _destino.esta_disponible_para(actor):
		_cancelar_aproximacion("La reserva dejó de estar disponible.")
		return

	_tiempo += delta

	if _tiempo > tiempo_maximo:
		_cancelar_aproximacion(
			"Tiempo agotado al acercarse a la silla."
		)
		return

	var objetivo := _destino.obtener_posicion_uso()

	if (
		actor.global_position.distance_to(objetivo)
		<= _tolerancia_llegada()
	):
		_comenzar_asiento()
		return

	# Debe consultarse una vez por actualización física
	# mientras el agente está recorriendo una ruta.
	var siguiente := agente.get_next_path_position()

	if agente.is_navigation_finished():
		_cancelar_aproximacion(
			"La ruta terminó demasiado lejos de la aproximación."
		)
		return

	var direccion := siguiente - actor.global_position
	direccion.y = 0.0

	if direccion.length_squared() > 0.0001:
		direccion = direccion.normalized()
	else:
		direccion = Vector3.ZERO

	actor.velocity.x = direccion.x * velocidad
	actor.velocity.z = direccion.z * velocidad

	if actor.is_on_floor():
		actor.velocity.y = 0.0
	else:
		actor.velocity.y -= gravedad * delta

	if (
		orientar_al_caminar
		and direccion.length_squared() > 0.0001
	):
		var giro := atan2(-direccion.x, -direccion.z)

		var rotacion := actor.global_rotation
		rotacion.y = lerp_angle(
			rotacion.y,
			giro,
			minf(1.0, velocidad_giro * delta)
		)
		actor.global_rotation = rotacion

	actor.move_and_slide()


func _tolerancia_llegada() -> float:
	if not is_instance_valid(_destino):
		return distancia_llegada

	return minf(
		distancia_llegada,
		_destino.tolerancia_aproximacion
	)


func _comenzar_asiento() -> void:
	actor.velocity = Vector3.ZERO

	# Entregar el control a ActorAsiento.
	#
	# Restauramos los callbacks y, dentro de esta misma llamada,
	# ActorAsiento vuelve a suspenderlos y guarda su estado original.
	# No hay un frame de movimiento entre ambas operaciones.
	_restaurar_controlador()

	_cambiar_estado(Estado.SENTANDO)

	if not _destino.ejecutar_uso_inmediato(actor):
		_cancelar_aproximacion(
			"No se pudo iniciar la postura sentada."
		)


func _al_quedar_sentado() -> void:
	if estado == Estado.SENTANDO:
		_cambiar_estado(Estado.SENTADO)


func notificar_inicio_salida() -> void:
	if estado == Estado.SENTADO:
		_cambiar_estado(Estado.LEVANTANDO)


func _al_quedar_libre() -> void:
	if estado not in [
		Estado.SENTANDO,
		Estado.SENTADO,
		Estado.LEVANTANDO,
	]:
		return

	_destino = null
	_cambiar_estado(Estado.LIBRE)
	accion_finalizada.emit()


func cancelar() -> void:
	# Durante el asiento, cancelar NO libera la reserva
	# ni devuelve el movimiento de forma insegura.
	if estado == Estado.CAMINANDO:
		_cancelacion_pendiente = true


func _unhandled_input(event: InputEvent) -> void:
	if not permitir_cancelacion_por_tecla:
		return

	if event.is_echo():
		return

	if (
		estado == Estado.CAMINANDO
		and event.is_action_pressed(accion_cancelar)
	):
		cancelar()
		get_viewport().set_input_as_handled()


func _cancelar_aproximacion(motivo: String) -> void:
	actor.velocity = Vector3.ZERO
	agente.target_position = actor.global_position

	if is_instance_valid(_destino):
		_destino.liberar(actor)

	_destino = null
	_cancelacion_pendiente = false

	_restaurar_controlador()
	_cambiar_estado(Estado.LIBRE)

	accion_cancelada.emit(motivo)


func _suspender_controlador() -> void:
	if _control_suspendido:
		return

	_callbacks = {
		"process": _control.is_processing(),
		"physics": _control.is_physics_processing(),
		"input": _control.is_processing_input(),
		"unhandled": _control.is_processing_unhandled_input(),
		"key": _control.is_processing_unhandled_key_input(),
	}

	_control.set_process(false)
	_control.set_physics_process(false)
	_control.set_process_input(false)
	_control.set_process_unhandled_input(false)
	_control.set_process_unhandled_key_input(false)

	_control_suspendido = true


func _restaurar_controlador() -> void:
	if not _control_suspendido:
		return

	if is_instance_valid(_control):
		_control.set_process(_callbacks.get("process", false))
		_control.set_physics_process(_callbacks.get("physics", false))
		_control.set_process_input(_callbacks.get("input", false))
		_control.set_process_unhandled_input(
			_callbacks.get("unhandled", false)
		)
		_control.set_process_unhandled_key_input(
			_callbacks.get("key", false)
		)

	_control_suspendido = false


func _cambiar_estado(nuevo: Estado) -> void:
	estado = nuevo
	estado_cambiado.emit(estado)
```

### Límites de este movimiento

Este componente incluye una locomoción básica:

- Velocidad horizontal.
- Gravedad.
- Giro.
- `move_and_slide()`.

**No reproduce automáticamente la animación de caminar ni implementa todas las capacidades de tu controlador**, como escalones especiales, root motion o locomoción avanzada.

El personaje conserva sus colisiones mientras camina. Una puerta cerrada lo bloqueará físicamente, aunque la navegación considere que hay paso; el tiempo máximo cancelará la acción.

---

# 4. Cambiar el punto de silla

Ahora `SillaCasa.intentar_usar()` debe **solicitar la acción completa**, no sentar directamente.

En `silla_casa.gd`, cambiá el nombre de la función anterior:

```gdscript
func intentar_usar(actor: Node3D) -> bool:
```

por:

```gdscript
func ejecutar_uso_inmediato(actor: Node3D) -> bool:
```

**Conservá su contenido.** Esa función sigue comprobando aproximación, adaptador y reserva antes de iniciar la pose.

Después añadí esta nueva función:

```gdscript
func intentar_usar(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if _en_uso or not esta_disponible_para(actor):
		return false

	for child in actor.get_children():
		if child is AccionMueble:
			var accion := child as AccionMueble

			if accion.actor == actor:
				return accion.solicitar(self)

	push_warning(
		"%s necesita un componente AccionMueble."
		% actor.name
	)
	return false
```

El recorrido queda así:

```text
Interactor del jugador o lógica del NPC
    ↓
SillaCasa.intentar_usar()
    ↓
AccionMueble.solicitar()
    ↓
Caminar a aproximación
    ↓
SillaCasa.ejecutar_uso_inmediato()
    ↓
ActorAsiento.comenzar_asiento()
```

**No llames `ejecutar_uso_inmediato()` desde el interactor.** Es el paso interno que usa el coordinador al llegar.

---

# 5. Levantarse desde el paso de física

Hay una mejora importante respecto al script anterior: las consultas físicas de salida deben ejecutarse desde el procesamiento físico, no directamente desde la entrada del teclado.

En `actor_asiento.gd`, añadí:

```gdscript
signal salida_iniciada

var _salida_pendiente: bool = false
```

Reemplazá `_unhandled_input()` por:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.SENTADO:
		return

	if event.is_echo():
		return

	if event.is_action_pressed(accion_levantarse):
		pedir_levantarse()
		get_viewport().set_input_as_handled()
```

Añadí:

```gdscript
func pedir_levantarse() -> void:
	if estado == Estado.SENTADO:
		_salida_pendiente = true


func _physics_process(_delta: float) -> void:
	if not _salida_pendiente:
		return

	_salida_pendiente = false

	if estado == Estado.SENTADO:
		solicitar_levantarse()
```

Dentro de `solicitar_levantarse()`, buscá:

```gdscript
estado = Estado.SALIENDO
```

Y debajo añadí:

```gdscript
salida_iniciada.emit()
```

Finalmente, en `_ready()` de `AccionMueble`, junto a las otras conexiones:

```gdscript
asiento.salida_iniciada.connect(notificar_inicio_salida)
```

**A partir de ahora, jugador y NPC deben llamar a `pedir_levantarse()`.** `solicitar_levantarse()` queda como operación interna ejecutada desde física.

La salida sigue siendo discreta, como en la entrega anterior: no hemos añadido una animación de levantarse ni una interpolación entre silla y salida.

---

# 6. Configurar jugador y NPC

En cada nodo `AccionMueble` asigná:

| Campo | Referencia |
|---|---|
| `actor` | Su `CharacterBody3D` |
| `asiento` | Su `ActorAsiento` |
| `agente` | Su `AgenteMuebles` |

En `ActorAsiento`, mantené:

```text
Controlador = nodo que procesa el movimiento habitual
```

Para el jugador:

```text
Permitir cancelación por tecla = true
```

Para los NPCs:

```text
Permitir cancelación por tecla = false
```

Creá la acción:

```text
cancelar_accion → Escape
```

Si Escape ya abre el menú de pausa, usá otra tecla durante la prueba o centralizá la prioridad de entradas. No conviene que la misma pulsación cancele la acción y abra dos interfaces.

---

# 7. Bloquear nuevas interacciones durante la aproximación

Antes solo comprobábamos si el actor estaba sentado. Ahora también debemos bloquear mientras camina a una silla.

En `interactor_muebles.gd`, añadí:

```gdscript
@export var accion_mueble: AccionMueble
```

Al comienzo de `_buscar_mueble()`:

```gdscript
if (
	is_instance_valid(accion_mueble)
	and not accion_mueble.esta_libre()
):
	return null
```

Podés conservar la comprobación anterior de `ActorAsiento`, aunque pasa a ser redundante si siempre usás el coordinador.

Aplicá el mismo criterio al interactor de puertas:

```gdscript
@export var accion_mueble: AccionMueble
```

Y al comienzo de `_buscar_puerta()`:

```gdscript
if (
	is_instance_valid(accion_mueble)
	and not accion_mueble.esta_libre()
):
	return null
```

Esto evita solicitar otras acciones mientras la locomoción está bajo control del sistema de muebles.

---

# 8. Prueba automática de un NPC

Este script **reemplaza la prueba anterior de llegada a un mueble** para el caso de las sillas.

No modifica `wander_enabled` ni `CozyNPC.State`: el coordinador suspende y restaura los callbacks del controlador que hayas asignado.

Guardá:

```text
res://casas/scripts/prueba_npc_silla.gd
```

```gdscript
extends Node

@export var accion: AccionMueble
@export var interior: InteriorCasa
@export var navegacion: NavegacionCasa

@export var silla_id: StringName = &"SILLA"
@export var segundos_sentado: float = 5.0

var _iniciada: bool = false


func _ready() -> void:
	if accion == null or interior == null or navegacion == null:
		push_error("Faltan referencias en prueba_npc_silla.")
		return

	accion.asiento.sentado.connect(_al_sentarse)
	accion.accion_finalizada.connect(_al_terminar)
	accion.accion_cancelada.connect(_al_cancelar)

	if navegacion.preparada:
		call_deferred("_iniciar")
	else:
		navegacion.navegacion_preparada.connect(_iniciar)


func _iniciar() -> void:
	if _iniciada:
		return

	_iniciada = true

	var silla := interior.obtener_punto(silla_id) as SillaCasa

	if silla == null:
		push_warning("El destino no es una SillaCasa válida.")
		return

	if not silla.intentar_usar(accion.actor):
		push_warning("El NPC no pudo iniciar la acción de silla.")


func _al_sentarse() -> void:
	print("NPC sentado. Esperando antes de pedir salida.")

	await get_tree().create_timer(
		maxf(0.1, segundos_sentado)
	).timeout

	if not is_instance_valid(accion):
		return

	if accion.estado == AccionMueble.Estado.SENTADO:
		accion.asiento.pedir_levantarse()


func _al_terminar() -> void:
	print("NPC levantado; controlador habitual restaurado.")


func _al_cancelar(motivo: String) -> void:
	print("Acción del NPC cancelada: ", motivo)
```

Si la salida está bloqueada al cumplirse los cinco segundos, el NPC permanece sentado.

Esta prueba **no reintenta indefinidamente**. Para volver a intentarlo, llamá otra vez:

```gdscript
accion.asiento.pedir_levantarse()
```

En un sistema de rutinas real añadiremos un tiempo de espera y una política de reintentos.

---

# 9. Corregir la fijación del techo

En la entrega anterior se fijaba el techo oculto al terminar de sentarse. Eso podía producir un pequeño parpadeo durante la alineación.

Ahora usá `mueble_utilizado`, que la silla emite cuando `ActorAsiento` ya aceptó la entrada.

En el script de la escena de prueba:

```gdscript
@export var casa_prueba: CasaTransitable
@export var interior_prueba: InteriorCasa
@export var asiento_jugador: ActorAsiento


func _ready() -> void:
	interior_prueba.mueble_utilizado.connect(_al_usar_mueble)
	asiento_jugador.levantado.connect(_al_levantarse)


func _al_usar_mueble(
	punto: PuntoMueble,
	actor: Node3D
) -> void:
	if punto is SillaCasa and actor == asiento_jugador.actor:
		casa_prueba.fijar_actor_interior(actor)


func _al_levantarse() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

	if (
		is_instance_valid(casa_prueba)
		and is_instance_valid(asiento_jugador)
	):
		casa_prueba.soltar_actor_interior(asiento_jugador.actor)
```

**Reemplazá la conexión anterior**, no mantengas dos scripts distintos controlando esta misma fijación.

---

# 10. Pruebas que deben pasar

Hacelas primero con la silla de la choza y la puerta abierta.

| Prueba | Resultado esperado |
|---|---|
| F cerca de la silla | El jugador camina a la aproximación y se sienta |
| F estando ya en aproximación | Se sienta sin iniciar una ruta innecesaria |
| Escape durante el recorrido | Se detiene, libera la silla y recupera control |
| H sentado | Comprueba salida y se levanta |
| Salida ocupada | Sigue sentado y mantiene reserva |
| Dos actores, misma silla | Solo uno obtiene la reserva |
| Aproximación fuera del NavMesh | Rechazo con motivo |
| Puerta cerrada en el recorrido | Colisión física; finalmente cancela por tiempo |
| Final del uso | El controlador habitual recupera sus callbacks |

Durante la prueba de un NPC, desactivá el viejo `prueba_npc_mueble.gd`. **Dos scripts ordenando acciones al mismo personaje invalidan la prueba.**

---

## Límites que todavía conservamos

### Controladores repartidos en varios nodos

Suspender los callbacks de un nodo no detiene:

- Temporizadores de otros nodos.
- Corutinas ya iniciadas.
- Otros componentes que cambien `velocity`.
- Animaciones que desplacen la raíz.
- Una máquina de estados ejecutada desde otro lugar.

Si tu controlador usa esos mecanismos, deberá consultar un bloqueo de acción o implementar una entrada explícita a “control externo”.

### Evitación entre NPCs

Esta versión no utiliza avoidance. Dos personajes pueden bloquearse mutuamente en un paso estrecho; la reserva solo protege **la silla**, no el pasillo.

### Eliminación de una silla ocupada

No elimines una silla ni descargues su casa mientras un actor está sentado. Todavía falta una política de salida de emergencia o de descarga coordinada.

### Puertas

La navegación sigue sin abrirlas. Durante las pruebas de interiores, mantenelas abiertas. El coordinador detecta que no llega por tiempo, pero no identifica por sí mismo que el obstáculo es una puerta.

---

## Resultado

Ahora tenemos una acción completa y compartida:

```text
Solicitar silla
→ reservar
→ comprobar ruta
→ caminar
→ entregar control al asiento
→ sentarse
→ comprobar salida
→ levantarse
→ liberar reserva
→ devolver control habitual
```

**El siguiente paso natural es conectar las puertas a este recorrido:** un NPC debe esperar fuera del giro, pedir apertura, cruzar y recién después continuar hacia el mueble. Así dejamos de depender de que todas las entradas estén abiertas durante la prueba.