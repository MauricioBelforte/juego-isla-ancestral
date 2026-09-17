Seguimos con **NPCs que abren una puerta, cruzan y después van a la silla**.

Vamos a hacerlo con un paso explícito, no intentando que el NPC “descubra” la puerta al chocar:

```text
Ir al punto de espera
→ reservar el uso de la puerta
→ solicitar apertura
→ esperar a que termine
→ cruzar hasta un punto despejado
→ liberar la puerta
→ solicitar la acción de silla
```

**La reserva de la puerta será independiente de la reserva de la silla.** En esta primera versión, la silla se solicita después de cruzar; podría estar ocupada para entonces.

> Seguimos sobre los scripts anteriores, en Godot 4.x. No he ejecutado esta integración aquí. La puerta, los puntos de espera y la navegación necesitan las pruebas indicadas al final.

---

# 1. Qué cambia en la navegación

No vamos a hornear nuevamente el `NavigationMesh` cada vez que gira una puerta.

Mantenemos:

- Navegación continua por el vano.
- Colisión física de la hoja.
- Apertura controlada antes de ordenar el cruce.

Esto funciona para **recorridos que utilicen este componente**. Un NPC que siga una ruta normal sin pasar por él todavía podría quedarse contra una puerta cerrada.

Tampoco añadimos todavía un sistema que elija automáticamente qué puertas necesita cruzar para llegar a cualquier habitación.

---

# 2. Dos puntos junto a la puerta

Añadí a la casa dos `Marker3D`:

```text
CASA_BASE
├── PUERTA_PRINCIPAL
├── ESPERA_EXTERIOR
└── ESPERA_INTERIOR
```

Deben quedar:

- Sobre suelo navegable.
- Cerca del eje central del vano.
- **Fuera de la zona circular de barrido de la puerta.**
- Con espacio para que el personaje se detenga de pie.

Para entrar:

```text
ESPERA_EXTERIOR → puerta abierta → ESPERA_INTERIOR
```

Para salir:

```text
ESPERA_INTERIOR → puerta abierta → ESPERA_EXTERIOR
```

### Importante sobre las distancias

No basta con que el centro del personaje esté fuera del detector. **Su cápsula completa debe quedar fuera.**

Con una puerta de aproximadamente un metro, empezá colocando los puntos a unos **1,6–1,8 m del plano de la hoja** y ajustá con las colisiones visibles.

El punto exterior puede quedar sobre la rampa o sobre el terreno, según su longitud. Su coordenada vertical debe corresponder a esa superficie, no necesariamente al piso interior.

---

# 3. Añadir reserva a `PuertaCasa`

En `puerta_casa.gd`, añadí:

```gdscript
var _usuario_paso: Node3D
```

Y estos métodos:

```gdscript
func reservar_paso(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if (
		is_instance_valid(_usuario_paso)
		and _usuario_paso != actor
	):
		return false

	_usuario_paso = actor
	return true


func liberar_paso(actor: Node3D) -> void:
	if _usuario_paso == actor:
		_usuario_paso = null


func paso_reservado_por_otro(actor: Node3D) -> bool:
	return (
		is_instance_valid(_usuario_paso)
		and _usuario_paso != actor
	)
```

Después cambiá la firma de:

```gdscript
func solicitar_apertura(abrir: bool) -> bool:
```

por:

```gdscript
func solicitar_apertura(
	abrir: bool,
	solicitante: Node3D = null
) -> bool:
```

Y al comienzo de esa función agregá:

```gdscript
if paso_reservado_por_otro(solicitante):
	solicitud_rechazada.emit(
		"La puerta está reservada para un cruce."
	)
	return false
```

**El resto de la función se conserva.**

Las llamadas anteriores siguen funcionando:

```gdscript
solicitar_apertura(true)
```

Pero durante un cruce reservado, solo se acepta la solicitud del actor propietario:

```gdscript
solicitar_apertura(true, npc)
```

La interacción manual del jugador queda temporalmente bloqueada mientras el NPC utiliza la puerta.

**Esta reserva no detiene físicamente a otros personajes ni crea una cola ordenada.** Solo coordina las solicitudes de apertura y cierre.

---

# 4. Bloqueo externo de `AccionMueble`

Mientras el NPC cruza la puerta, no debemos permitir que otro sistema le ordene ir a una silla.

En `accion_mueble.gd`, añadí:

```gdscript
var bloqueado_externamente: bool = false
```

Reemplazá `esta_libre()` por:

```gdscript
func esta_libre() -> bool:
	return (
		not bloqueado_externamente
		and estado == Estado.LIBRE
		and asiento.esta_libre()
	)
```

El componente de cruce activará este bloqueo y lo retirará al terminar.

Los interactores que ya consultan `accion_mueble.esta_libre()` también respetarán ese estado.

---

# 5. Componente `cruce_puerta.gd`

Añadí al personaje:

```text
NPC
├── ActorAsiento
├── AgenteMuebles
├── AccionMueble
└── CrucePuerta
```

Para mantener la prueba sencilla, `CrucePuerta` reutiliza el agente de `AccionMueble`, **pero nunca al mismo tiempo**.

Guardá:

```text
res://casas/scripts/cruce_puerta.gd
```

```gdscript
class_name CrucePuerta
extends Node

signal cruce_completado
signal cruce_cancelado(motivo: String)
signal destino_no_iniciado(motivo: String)

enum Estado {
	LIBRE,
	YENDO_A_ESPERA,
	ESPERANDO_APERTURA,
	CRUZANDO,
}

@export_category("Referencias")
@export var accion: AccionMueble
@export var puerta: PuertaCasa
@export var espera_exterior: Marker3D
@export var espera_interior: Marker3D

@export_category("Movimiento")
@export var velocidad: float = 1.8
@export var gravedad: float = 9.8
@export var distancia_llegada: float = 0.22
@export var tolerancia_navegacion: float = 0.25
@export var tiempo_maximo: float = 45.0

@export_category("Puerta")
# Por defecto la dejamos abierta.
# Si está activado, solo solicita cierre cuando el barrido está libre.
@export var intentar_cerrar_al_terminar: bool = false

var estado: Estado = Estado.LIBRE

var _actor: CharacterBody3D
var _agente: NavigationAgent3D
var _control: Node

var _callbacks: Dictionary = {}
var _suspendido: bool = false
var _tiene_reserva: bool = false

var _origen: Vector3
var _salida: Vector3
var _objetivo_ruta: Vector3

var _silla_destino: SillaCasa
var _queria_silla: bool = false

var _tiempo: float = 0.0
var _cancelacion_pendiente: bool = false


func solicitar_cruce(
	entrar: bool,
	silla_destino: SillaCasa = null
) -> bool:
	if estado != Estado.LIBRE:
		return false

	if not _preparar_referencias():
		return false

	if not accion.esta_libre():
		return false

	_origen = (
		espera_exterior.global_position
		if entrar
		else espera_interior.global_position
	)

	_salida = (
		espera_interior.global_position
		if entrar
		else espera_exterior.global_position
	)

	# Validar el primer tramo antes de suspender al personaje.
	if not _establecer_ruta(_origen):
		return false

	_silla_destino = silla_destino
	_queria_silla = silla_destino != null

	_tiempo = 0.0
	_cancelacion_pendiente = false
	_tiene_reserva = false

	accion.bloqueado_externamente = true
	_suspender_controlador()

	_actor.velocity = Vector3.ZERO
	estado = Estado.YENDO_A_ESPERA
	return true


func _preparar_referencias() -> bool:
	if (
		not is_instance_valid(accion)
		or not is_instance_valid(puerta)
		or not is_instance_valid(espera_exterior)
		or not is_instance_valid(espera_interior)
	):
		push_warning("CrucePuerta: faltan referencias.")
		return false

	_actor = accion.actor
	_agente = accion.agente

	if (
		not is_instance_valid(_actor)
		or not is_instance_valid(_agente)
		or not is_instance_valid(accion.asiento)
	):
		return false

	_control = (
		accion.asiento.controlador
		if accion.asiento.controlador != null
		else _actor
	)

	if (
		not is_instance_valid(_control)
		or _control == self
		or _control == accion
		or _control == accion.asiento
	):
		push_warning("CrucePuerta: controlador habitual inválido.")
		return false

	return true


func _establecer_ruta(objetivo: Vector3) -> bool:
	var mapa := _agente.get_navigation_map()

	if (
		not mapa.is_valid()
		or NavigationServer3D.map_get_iteration_id(mapa) == 0
	):
		push_warning("CrucePuerta: navegación no sincronizada.")
		return false

	var inicio := NavigationServer3D.map_get_closest_point(
		mapa,
		_actor.global_position
	)

	var destino := NavigationServer3D.map_get_closest_point(
		mapa,
		objetivo
	)

	if (
		inicio.distance_to(_actor.global_position)
		> tolerancia_navegacion
		or destino.distance_to(objetivo) > tolerancia_navegacion
	):
		push_warning("CrucePuerta: actor o marcador fuera de navegación.")
		return false

	var ruta := NavigationServer3D.map_get_path(
		mapa,
		inicio,
		destino,
		true,
		_agente.navigation_layers
	)

	if ruta.is_empty():
		return false

	if (
		ruta[ruta.size() - 1].distance_to(destino)
		> tolerancia_navegacion
	):
		return false

	_objetivo_ruta = destino
	_agente.target_position = destino
	return true


func _physics_process(delta: float) -> void:
	if estado == Estado.LIBRE:
		return

	if (
		not is_instance_valid(_actor)
		or not is_instance_valid(accion)
		or not is_instance_valid(puerta)
		or not is_instance_valid(_agente)
	):
		_cancelar("Se perdió una referencia durante el cruce.")
		return

	if _cancelacion_pendiente:
		_cancelar("Cruce cancelado.")
		return

	_tiempo += delta

	if _tiempo > tiempo_maximo:
		_cancelar("Se agotó el tiempo de espera o de cruce.")
		return

	match estado:
		Estado.YENDO_A_ESPERA:
			if _llego():
				_actor.velocity = Vector3.ZERO
				estado = Estado.ESPERANDO_APERTURA
			else:
				_caminar(delta)

		Estado.ESPERANDO_APERTURA:
			_mantener_en_suelo(delta)
			_esperar_apertura()

		Estado.CRUZANDO:
			if puerta.estado != PuertaCasa.Estado.ABIERTA:
				_cancelar("La puerta dejó de estar abierta durante el cruce.")
				return

			if _llego():
				_terminar_cruce()
			else:
				_caminar(delta)


func _llego() -> bool:
	return (
		_actor.global_position.distance_to(_objetivo_ruta)
		<= distancia_llegada
	)


func _esperar_apertura() -> void:
	if not _tiene_reserva:
		_tiene_reserva = puerta.reservar_paso(_actor)

		if not _tiene_reserva:
			return

	if puerta.estado == PuertaCasa.Estado.ABIERTA:
		if not _establecer_ruta(_salida):
			_cancelar("No existe una ruta al otro lado de la puerta.")
			return

		estado = Estado.CRUZANDO
		return

	if puerta.esta_moviendose():
		return

	# También permite reanudar una apertura interrumpida,
	# siempre que el barrido vuelva a estar libre.
	puerta.solicitar_apertura(true, _actor)


func _caminar(delta: float) -> void:
	var siguiente := _agente.get_next_path_position()

	if _agente.is_navigation_finished():
		_cancelar("La ruta terminó antes de alcanzar el marcador.")
		return

	var direccion := siguiente - _actor.global_position
	direccion.y = 0.0

	if direccion.length_squared() > 0.0001:
		direccion = direccion.normalized()
	else:
		direccion = Vector3.ZERO

	_actor.velocity.x = direccion.x * velocidad
	_actor.velocity.z = direccion.z * velocidad

	_aplicar_gravedad(delta)

	if direccion.length_squared() > 0.0001:
		var rotacion := _actor.global_rotation
		var giro := atan2(-direccion.x, -direccion.z)

		rotacion.y = lerp_angle(
			rotacion.y,
			giro,
			minf(1.0, delta * 10.0)
		)

		_actor.global_rotation = rotacion

	_actor.move_and_slide()


func _mantener_en_suelo(delta: float) -> void:
	_actor.velocity.x = 0.0
	_actor.velocity.z = 0.0

	_aplicar_gravedad(delta)
	_actor.move_and_slide()


func _aplicar_gravedad(delta: float) -> void:
	if _actor.is_on_floor():
		_actor.velocity.y = 0.0
	else:
		_actor.velocity.y -= gravedad * delta


func _terminar_cruce() -> void:
	_actor.velocity = Vector3.ZERO

	# Esto es una solicitud opcional, no una garantía de cierre.
	if (
		intentar_cerrar_al_terminar
		and not puerta.hay_actor_en_barrido()
	):
		puerta.solicitar_apertura(false, _actor)

	var silla := _silla_destino
	var queria_silla := _queria_silla

	_liberar_control()
	estado = Estado.LIBRE

	# El cambio de control se hace antes de emitir la señal pública.
	if queria_silla:
		if not is_instance_valid(silla):
			destino_no_iniciado.emit("La silla ya no existe.")
		elif not silla.intentar_usar(_actor):
			destino_no_iniciado.emit(
				"La silla está ocupada o no se pudo iniciar su acción."
			)

	cruce_completado.emit()


func cancelar() -> void:
	if estado != Estado.LIBRE:
		_cancelacion_pendiente = true


func _cancelar(motivo: String) -> void:
	if is_instance_valid(_actor):
		_actor.velocity = Vector3.ZERO

	if is_instance_valid(_agente) and is_instance_valid(_actor):
		_agente.target_position = _actor.global_position

	# No cerramos la puerta al cancelar: el personaje
	# podría encontrarse todavía dentro del vano.
	_liberar_control()
	estado = Estado.LIBRE

	cruce_cancelado.emit(motivo)


func _liberar_control() -> void:
	if (
		_tiene_reserva
		and is_instance_valid(puerta)
		and is_instance_valid(_actor)
	):
		puerta.liberar_paso(_actor)

	_tiene_reserva = false
	_silla_destino = null
	_queria_silla = false
	_cancelacion_pendiente = false

	_restaurar_controlador()

	if is_instance_valid(accion):
		accion.bloqueado_externamente = false


func _suspender_controlador() -> void:
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

	_suspendido = true


func _restaurar_controlador() -> void:
	if not _suspendido:
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

	_suspendido = false


func _exit_tree() -> void:
	# Limpieza si se retira únicamente este componente.
	if estado != Estado.LIBRE:
		_liberar_control()
```

---

# 6. Qué garantiza este componente y qué no

### Sí coordina

- Que su actor espere a la apertura completa antes de cruzar.
- Que otro usuario del mismo sistema no cierre la puerta durante su reserva.
- Que `AccionMueble` no tome el control durante el cruce.
- Que se restaure el controlador al cancelar.
- Que no se intente cerrar automáticamente al fallar dentro del vano.

### No garantiza

- Una cola justa entre varios NPCs.
- Que otro personaje no se coloque delante de la puerta.
- Que el camino calculado pase necesariamente por ese vano si existen otras rutas.
- Que un NPC ajeno a este sistema no bloquee el barrido.
- Que una puerta cerrada aparezca como desconectada en el NavMesh.

Por eso esta versión se prueba primero con **una entrada y un NPC**.

---

# 7. Configuración del personaje

En `CrucePuerta`, asigná:

| Campo | Referencia |
|---|---|
| `accion` | Su `AccionMueble` |
| `puerta` | `CASA_BASE/PUERTA_PRINCIPAL` |
| `espera_exterior` | `CASA_BASE/ESPERA_EXTERIOR` |
| `espera_interior` | `CASA_BASE/ESPERA_INTERIOR` |
| `intentar_cerrar_al_terminar` | `false` inicialmente |

En la puerta:

```text
Iniciar abierta = false
```

Su `mascara_actores` debe incluir la capa física del NPC.

**No cambies la máscara para evitar que el NPC bloquee la puerta.** Si queda dentro del barrido, corregí el marcador de espera.

---

# 8. Prueba: exterior → puerta → silla

Reemplazá la prueba anterior que enviaba directamente al NPC a la silla por esta.

Guardá:

```text
res://casas/scripts/prueba_npc_puerta_silla.gd
```

```gdscript
extends Node

@export var cruce: CrucePuerta
@export var interior: InteriorCasa
@export var navegacion: NavegacionCasa

@export var silla_id: StringName = &"SILLA"
@export var segundos_sentado: float = 5.0

var _iniciada: bool = false


func _ready() -> void:
	if (
		cruce == null
		or cruce.accion == null
		or cruce.accion.asiento == null
		or interior == null
		or navegacion == null
	):
		push_error("Faltan referencias en la prueba de puerta y silla.")
		return

	cruce.cruce_completado.connect(_al_cruzar)
	cruce.cruce_cancelado.connect(_al_cancelar)
	cruce.destino_no_iniciado.connect(_al_fallar_destino)

	cruce.accion.asiento.sentado.connect(_al_sentarse)
	cruce.accion.accion_finalizada.connect(_al_terminar)

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
		push_warning("No existe la silla configurada.")
		return

	if not cruce.solicitar_cruce(true, silla):
		push_warning("No se pudo iniciar el recorrido.")


func _al_cruzar() -> void:
	print("NPC al otro lado de la puerta.")


func _al_sentarse() -> void:
	print("NPC sentado.")

	await get_tree().create_timer(
		maxf(0.1, segundos_sentado)
	).timeout

	if not is_instance_valid(cruce):
		return

	if not is_instance_valid(cruce.accion):
		return

	if cruce.accion.estado == AccionMueble.Estado.SENTADO:
		cruce.accion.asiento.pedir_levantarse()


func _al_terminar() -> void:
	print("NPC levantado; acción de silla terminada.")


func _al_cancelar(motivo: String) -> void:
	print("Cruce cancelado: ", motivo)


func _al_fallar_destino(motivo: String) -> void:
	print("Se cruzó la puerta, pero no se inició la silla: ", motivo)
```

**Desactivá `prueba_npc_silla.gd` y `prueba_npc_mueble.gd` en esta escena.** Solo debe existir un script de prueba dando órdenes al NPC.

---

# 9. Salir de la casa

El mismo componente permite salir:

```gdscript
cruce.solicitar_cruce(false)
```

Sin indicar una silla, la acción termina al llegar al marcador exterior.

Podés ejecutarlo después de que el NPC se levante, pero tené en cuenta algo: **el controlador habitual ya se habrá restaurado**. La nueva solicitud volverá a suspenderlo durante la salida.

Para una prueba simple, reemplazá `_al_terminar()` por:

```gdscript
func _al_terminar() -> void:
	print("NPC levantado. Solicitando salida.")

	if not cruce.solicitar_cruce(false):
		push_warning("No se pudo iniciar la salida de la casa.")
```

Así obtenés:

```text
Exterior
→ abrir
→ entrar
→ sentarse
→ levantarse
→ ir a espera interior
→ cruzar hacia fuera
```

---

# 10. Pruebas en orden

## A. Cruce sin silla

Llamá:

```gdscript
cruce.solicitar_cruce(true)
```

Comprobá que el NPC:

1. Llega al marcador exterior.
2. Se detiene fuera del barrido.
3. Abre la puerta.
4. Espera hasta la apertura completa.
5. Cruza.
6. Recupera su controlador.

Si no logra abrir, mirá primero la zona de barrido.

## B. Cruce con silla

Usá el script de prueba completo.

La puerta debe estar cerrada al comenzar y el NPC debe terminar sentado.

## C. Barrido ocupado

Colocá al jugador cerca de la hoja.

Resultado esperado:

- El NPC espera.
- La puerta rechaza el giro.
- Al retirar al jugador, vuelve a intentar abrir.
- Si pasa demasiado tiempo, cancela.

## D. Dos NPCs

Probá con cuidado:

- Ambos pueden acercarse a sus puntos.
- Solo uno reserva la puerta.
- El otro espera su turno de reserva.
- No hay garantía de orden.
- Si sus cápsulas se bloquean entre sí, puede agotarse el tiempo.

**Para circulación bidireccional estable todavía falta una cola con puntos de espera separados.**

## E. Cancelación

Durante el recorrido:

```gdscript
cruce.cancelar()
```

Debe:

- Detener el movimiento.
- Liberar la reserva.
- Desbloquear `AccionMueble`.
- Restaurar el controlador.
- No cerrar la hoja sobre el personaje.

---

## Resultado de esta etapa

Ya tenemos una secuencia explícita:

```text
Control habitual
→ aproximación a puerta
→ apertura reservada
→ cruce
→ aproximación a silla
→ asiento
→ salida del asiento
→ control habitual
```

La siguiente mejora importante es **la gestión de varios NPCs**: cola en la puerta, puntos de espera separados y cesión del paso. Esa pieza evitará que dos personajes que entran y salen a la vez conviertan el vano en un bloqueo permanente.