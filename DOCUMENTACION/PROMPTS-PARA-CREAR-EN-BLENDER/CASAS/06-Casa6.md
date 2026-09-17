Seguimos con **sillas utilizables**, manteniendo los muebles dentro de los GLB y añadiendo únicamente la lógica de juego.

Vamos a separar tres posiciones:

```text
SILLA
├── Aproximación   ← El personaje llega caminando
├── Pose sentada   ← Alineación del personaje y su animación
└── Salida         ← Lugar libre donde vuelve a ponerse de pie
```

**No vamos a confundir “llegar junto a la silla” con “estar sentado”.** La reserva, el cambio de postura y la salida serán pasos independientes.

> Esta implementación está pensada para **Godot 4.x** y un personaje `CharacterBody3D`. No he ejecutado el código aquí. Los desplazamientos y la pose necesitan ajustarse con tu modelo y sus animaciones.

---

# 1. Qué resuelve esta etapa

- Reservar una silla para un personaje.
- Exigir que esté cerca de su posición de aproximación.
- Suspender temporalmente su controlador habitual.
- Alinear su raíz con una pose configurada.
- Solicitar una animación de sentado.
- Comprobar que la salida tiene suelo y espacio para su collider.
- Restaurar movimiento y colisiones al levantarse.
- Mantener la silla reservada mientras está ocupada.

**No incluye todavía:**

- Animaciones nuevas.
- IK de pies o manos.
- Navegación automática hasta la silla.
- Transiciones de sentado con detección continua de obstáculos.
- Compatibilidad automática con cualquier controlador.

La alineación será un **desplazamiento corto y guionado**, no una ruta de navegación. Por eso solo se permite iniciarla desde el punto de aproximación.

---

# 2. Organización de archivos

Añadimos:

```text
res://casas/scripts/
├── actor_asiento.gd
└── silla_casa.gd
```

El personaje tendrá:

```text
PLAYER
├── CollisionShape3D
├── Modelo
│   └── AnimationPlayer
├── InteractorMuebles
└── ActorAsiento
```

Los puntos de silla seguirán siendo creados por `InteriorCasa`, leyendo el JSON.

---

# 3. Adaptador del personaje

Guardá:

```text
res://casas/scripts/actor_asiento.gd
```

Este componente no depende de `CozyNPC`. Se conecta con un `CharacterBody3D` y suspende los callbacks del nodo que controla su movimiento.

```gdscript
class_name ActorAsiento
extends Node

signal sentado
signal levantado

enum Estado {
	LIBRE,
	ENTRANDO,
	SENTADO,
	SALIENDO,
}

@export_category("Personaje")
@export var actor: CharacterBody3D
@export var collider: CollisionShape3D

# Nodo cuyo script procesa movimiento y entradas.
# Si queda vacío, se utiliza el CharacterBody3D.
@export var controlador: Node

@export_category("Animación opcional")
@export var animaciones: AnimationPlayer
@export var animacion_sentado: StringName = &"sentado"
@export var animacion_de_pie: StringName = &"idle"

@export_category("Transición")
@export var duracion_alineacion: float = 0.25

@export_category("Salida")
@export var accion_levantarse: StringName = &"levantarse"

# Debe incluir entorno, muebles y otros personajes sólidos.
@export_flags_3d_physics var mascara_salida: int = 3

# Esta versión supone que el origen del actor está en sus pies.
@export var elevacion_salida: float = 0.035
@export var pendiente_maxima_salida: float = 40.0

var estado: Estado = Estado.LIBRE
var silla_actual: SillaCasa

var _control: Node
var _callbacks: Dictionary = {}

var _capa_anterior: int
var _mascara_anterior: int

var _base_anterior: Basis
var _collider_relativo: Transform3D

var _transicion: Tween


func _ready() -> void:
	if not _configuracion_valida():
		push_error(
			"%s: asigná actor y su CollisionShape3D principal."
			% name
		)
		return

	_control = controlador if controlador != null else actor


func _configuracion_valida() -> bool:
	return (
		is_instance_valid(actor)
		and is_instance_valid(collider)
		and collider.shape != null
		and collider.get_parent() == actor
	)


func esta_libre() -> bool:
	return estado == Estado.LIBRE


func comenzar_asiento(silla: SillaCasa) -> bool:
	if not _configuracion_valida():
		return false

	if not esta_libre() or not is_instance_valid(silla):
		return false

	if collider.disabled:
		push_warning("No se puede sentar con el collider desactivado.")
		return false

	if not is_instance_valid(_control):
		return false

	silla_actual = silla
	estado = Estado.ENTRANDO

	_base_anterior = actor.global_basis
	_collider_relativo = (
		actor.global_transform.affine_inverse()
		* collider.global_transform
	)

	_capa_anterior = actor.collision_layer
	_mascara_anterior = actor.collision_mask

	_suspender_controlador()

	actor.velocity = Vector3.ZERO

	# La cápsula de pie no representa una postura sentada.
	# La retiramos temporalmente de las interacciones físicas.
	actor.collision_layer = 0
	actor.collision_mask = 0

	_reproducir(animacion_sentado)

	var destino := silla.obtener_pose_sentada()

	var rotacion_destino := destino.basis.get_euler()
	rotacion_destino.y = (
		actor.global_rotation.y
		+ wrapf(
			rotacion_destino.y - actor.global_rotation.y,
			-PI,
			PI
		)
	)

	_transicion = create_tween()
	_transicion.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_transicion.set_parallel(true)

	_transicion.tween_property(
		actor,
		"global_position",
		destino.origin,
		maxf(0.01, duracion_alineacion)
	)

	_transicion.tween_property(
		actor,
		"global_rotation",
		rotacion_destino,
		maxf(0.01, duracion_alineacion)
	)

	_transicion.finished.connect(_terminar_entrada)
	return true


func _terminar_entrada() -> void:
	if estado != Estado.ENTRANDO:
		return

	estado = Estado.SENTADO
	sentado.emit()


func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.SENTADO:
		return

	if event.is_echo():
		return

	if event.is_action_pressed(accion_levantarse):
		solicitar_levantarse()
		get_viewport().set_input_as_handled()


func solicitar_levantarse() -> bool:
	if estado != Estado.SENTADO:
		return false

	if not is_instance_valid(silla_actual):
		push_warning("La silla ya no existe; falta una salida de emergencia.")
		return false

	var resultado := _comprobar_salida(
		silla_actual.obtener_posicion_salida()
	)

	if not resultado.get("valida", false):
		print(
			"No se puede levantar: ",
			resultado.get("motivo", "salida bloqueada")
		)
		return false

	estado = Estado.SALIENDO

	var posicion: Vector3 = resultado["posicion"]

	# Salida discreta a una posición comprobada.
	# No interpolamos una cápsula de pie a través del asiento.
	actor.global_transform = Transform3D(
		_base_anterior,
		posicion
	)
	actor.velocity = Vector3.ZERO

	actor.collision_layer = _capa_anterior
	actor.collision_mask = _mascara_anterior

	_reproducir(animacion_de_pie)

	var silla := silla_actual
	silla_actual = null

	silla.finalizar_uso(actor)
	_restaurar_controlador()

	estado = Estado.LIBRE
	levantado.emit()
	return true


func _comprobar_salida(posicion_prevista: Vector3) -> Dictionary:
	var espacio := actor.get_world_3d().direct_space_state

	# Buscar suelo cerca del punto configurado.
	var rayo := PhysicsRayQueryParameters3D.create(
		posicion_prevista + Vector3.UP * 0.30,
		posicion_prevista - Vector3.UP * 0.25
	)
	rayo.collision_mask = mascara_salida
	rayo.collide_with_areas = false
	rayo.exclude = [actor.get_rid()]

	var suelo := espacio.intersect_ray(rayo)

	if suelo.is_empty():
		return {
			"valida": false,
			"motivo": "no hay suelo cerca del punto de salida",
		}

	var normal: Vector3 = suelo["normal"]
	var limite := cos(deg_to_rad(pendiente_maxima_salida))

	if normal.dot(Vector3.UP) < limite:
		return {
			"valida": false,
			"motivo": "el suelo de salida es demasiado inclinado",
		}

	var posicion: Vector3 = suelo["position"]
	posicion += Vector3.UP * elevacion_salida

	# Probar el collider real de pie con su orientación original.
	var transform_actor := Transform3D(
		_base_anterior,
		posicion
	)

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collider.shape
	query.transform = transform_actor * _collider_relativo
	query.collision_mask = mascara_salida
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [actor.get_rid()]
	query.margin = 0.005

	var contactos := espacio.intersect_shape(query, 16)

	if not contactos.is_empty():
		return {
			"valida": false,
			"motivo": "no cabe el personaje de pie",
		}

	return {
		"valida": true,
		"posicion": posicion,
	}


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


func _restaurar_controlador() -> void:
	if not is_instance_valid(_control):
		return

	_control.set_process(_callbacks.get("process", false))
	_control.set_physics_process(_callbacks.get("physics", false))
	_control.set_process_input(_callbacks.get("input", false))
	_control.set_process_unhandled_input(
		_callbacks.get("unhandled", false)
	)
	_control.set_process_unhandled_key_input(
		_callbacks.get("key", false)
	)


func _reproducir(nombre_animacion: StringName) -> void:
	if not is_instance_valid(animaciones):
		return

	if animaciones.has_animation(nombre_animacion):
		animaciones.play(nombre_animacion)
	else:
		push_warning(
			"Falta animación de asiento: %s" % nombre_animacion
		)
```

## Condiciones de este adaptador

Para esta versión:

- El origen del `CharacterBody3D` debe estar en los pies.
- Su collider principal debe ser hijo directo del actor.
- Actor, collider y casas deben mantener escala `(1,1,1)`.
- El controlador habitual no debe seguir moviendo al personaje desde otro nodo, un temporizador o una animación con movimiento de raíz.
- No asignes `ActorAsiento` como su propio `controlador`.

**Desactivar callbacks de un nodo no desactiva automáticamente todos sus hijos.** Si tu movimiento está repartido entre varios componentes, habrá que conectar el bloqueo a tu máquina de estados.

La animación de sentado debe ser **sin desplazamiento de la raíz física**. Puede modificar el esqueleto, pero no competir con el `CharacterBody3D`.

---

# 4. Punto de silla especializado

Guardá:

```text
res://casas/scripts/silla_casa.gd
```

Extiende el `PuntoMueble` que ya tenés.

```gdscript
class_name SillaCasa
extends PuntoMueble

@export_category("Asiento")
@export var pose_definida: bool = false

# Respecto al centro del punto de mueble.
# Representa la raíz del personaje, no la superficie del asiento.
@export var desplazamiento_sentado: Vector3 = Vector3.ZERO

# Orientación del actor respecto a los ejes de la casa.
@export var giro_sentado_grados: float = 0.0

@export_category("Aproximación")
@export var tolerancia_aproximacion: float = 0.35

@export_category("Salida")
@export var salida_definida: bool = false
@export var desplazamiento_salida: Vector3 = Vector3.ZERO

var _en_uso: bool = false


func intentar_usar(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if _en_uso or not esta_disponible_para(actor):
		return false

	if (
		not posicion_uso_definida
		or not pose_definida
		or not salida_definida
	):
		push_warning(
			"%s: faltan aproximación, pose o salida."
			% identificador
		)
		return false

	var distancia := actor.global_position.distance_to(
		obtener_posicion_uso()
	)

	if distancia > tolerancia_aproximacion:
		print(
			"Acercate al punto de uso de la silla. Distancia: %.2f m."
			% distancia
		)
		return false

	var adaptador := _buscar_adaptador(actor)

	if adaptador == null:
		push_warning(
			"%s no tiene un ActorAsiento configurado."
			% actor.name
		)
		return false

	if not adaptador.esta_libre():
		return false

	if not reservar(actor):
		return false

	if not adaptador.comenzar_asiento(self):
		liberar(actor)
		return false

	_en_uso = true
	utilizado.emit(self, actor)
	return true


func obtener_pose_sentada() -> Transform3D:
	var local := Transform3D(
		Basis(Vector3.UP, deg_to_rad(giro_sentado_grados)),
		desplazamiento_sentado
	)
	return global_transform * local


func obtener_posicion_salida() -> Vector3:
	return to_global(desplazamiento_salida)


func finalizar_uso(actor: Node3D) -> void:
	if _ocupante != actor:
		return

	_en_uso = false
	liberar(actor)


func _buscar_adaptador(actor: Node3D) -> ActorAsiento:
	for child in actor.get_children():
		if child is ActorAsiento:
			var adaptador := child as ActorAsiento
			if adaptador.actor == actor:
				return adaptador

	return null


func _process(_delta: float) -> void:
	# Si desaparece el ocupante, la silla vuelve a estar disponible.
	if _en_uso and not is_instance_valid(_ocupante):
		_en_uso = false
		_ocupante = null
```

La silla **conserva la reserva** hasta que `ActorAsiento` termina de levantar al personaje.

No usamos el comportamiento anterior de “llegar, emitir señal y liberar inmediatamente”.

---

# 5. Modificar el cargador de muebles

En `interior_casa.gd`, dentro de `_cargar_puntos()`, buscá:

```gdscript
var punto := PuntoMueble.new()
```

Reemplazalo por:

```gdscript
var tipo_entrada := String(
	entrada.get("tipo", "MUEBLE")
).to_upper()

var punto: PuntoMueble

if tipo_entrada == "SILLA":
	punto = SillaCasa.new()
else:
	punto = PuntoMueble.new()
```

Después, **antes de**:

```gdscript
add_child(punto)
```

añadí:

```gdscript
if punto is SillaCasa and ajuste is Dictionary:
	var silla := punto as SillaCasa
	var asiento: Variant = ajuste.get("asiento", {})

	if asiento is Dictionary:
		var pose: Variant = asiento.get("offset_raiz", null)
		var salida: Variant = asiento.get("offset_salida", null)

		if pose is Array and pose.size() == 3:
			silla.desplazamiento_sentado = _vector_desde_array(pose)
			silla.pose_definida = true

		if salida is Array and salida.size() == 3:
			silla.desplazamiento_salida = _vector_desde_array(salida)
			silla.salida_definida = true

		silla.giro_sentado_grados = float(
			asiento.get("giro_grados", 0.0)
		)

		silla.tolerancia_aproximacion = float(
			asiento.get("tolerancia_aproximacion", 0.35)
		)
```

Así:

- Camas y mesas siguen siendo `PuntoMueble`.
- Las entradas con tipo `SILLA` pasan a ser `SillaCasa`.
- Una silla sin configuración completa no permite sentarse.

---

# 6. Configuración inicial de la silla de la choza

En:

```text
res://casas/datos/casa_01_uso.json
```

Reemplazá solamente la entrada `"SILLA"` por:

```json
"SILLA": {
  "offset": [-0.65, 0.0, 0.0],
  "altura_objetivo": 0.65,
  "distancia_interaccion": 1.6,
  "asiento": {
    "offset_raiz": [0.0, 0.0, 0.0],
    "giro_grados": -90.0,
    "offset_salida": [-0.65, 0.0, 0.0],
    "tolerancia_aproximacion": 0.35
  }
}
```

### Cómo interpretar esos valores

**Aproximación:**

```json
"offset": [-0.65, 0.0, 0.0]
```

El personaje llega al lado de la silla que da hacia el pasillo.

**Pose:**

```json
"offset_raiz": [0.0, 0.0, 0.0]
```

Es únicamente un valor inicial. Sitúa la raíz del actor en el centro del punto de silla.

**No significa que la cadera quede correctamente apoyada.** Eso depende de cómo esté hecha la animación.

**Orientación:**

```json
"giro_grados": -90.0
```

Asume un actor cuyo frente lógico es `-Z`; lo orienta hacia `+X`, donde está la mesa de la choza.

**Salida:**

```json
"offset_salida": [-0.65, 0.0, 0.0]
```

Inicialmente coincide con la aproximación. Antes de levantarse se comprueba:

- Que exista suelo cerca.
- Que su pendiente sea aceptable.
- Que el collider de pie no toque obstáculos.

> Como la geometría original de la silla está recortada en el contexto, estos valores son **de ajuste inicial**, no una pose validada.

---

# 7. Añadir el adaptador al jugador

Creá un nodo `Node` llamado:

```text
ActorAsiento
```

Asignale `actor_asiento.gd`.

En el Inspector:

| Campo | Asignación |
|---|---|
| `actor` | Tu `CharacterBody3D` |
| `collider` | Su collider principal |
| `controlador` | Nodo que procesa el movimiento |
| `animaciones` | `AnimationPlayer`, si lo usás |
| `animacion_sentado` | Nombre real de tu animación |
| `animacion_de_pie` | Nombre real del idle |
| `mascara_salida` | Capas de entorno y personajes |

Añadí una acción:

```text
levantarse → tecla H
```

Usamos por ahora:

```text
F → usar mueble
G → usar puerta
H → levantarse
```

La entrada a la silla sigue pasando por `InteractorMuebles`.

---

# 8. Evitar usar otros muebles mientras está sentado

En `interactor_muebles.gd`, añadí:

```gdscript
@export var adaptador_asiento: ActorAsiento
```

Al comienzo de `_buscar_mueble()`:

```gdscript
if (
	is_instance_valid(adaptador_asiento)
	and not adaptador_asiento.esta_libre()
):
	return null
```

Asigná el nodo `ActorAsiento` desde el Inspector.

Podés aplicar el mismo bloqueo al interactor de puertas, al combate o a cualquier acción que no deba estar disponible durante el asiento.

**No bloqueamos todo el árbol del personaje**, porque eso también podría impedir procesar la tecla para levantarse.

---

# 9. Qué ocurre con las colisiones y el techo

Durante el asiento:

```text
Jugador:
    collision_layer = 0
    collision_mask = 0

Silla:
    conserva su colisión estática
```

Esto evita que la cápsula de pie choque contra el asiento o la mesa durante la pose.

Pero tiene consecuencias:

- Otros personajes no chocarán con el ocupante mediante ese collider.
- El detector interior de la casa puede dejar de detectar al jugador.
- Sistemas que identifiquen al actor exclusivamente mediante colisiones pueden perderlo temporalmente.

## Mantener el techo oculto

En `casa_transitable.gd`, añadí esta variable:

```gdscript
var _actores_interiores_fijados: Array[Node3D] = []
```

Y estos métodos:

```gdscript
func fijar_actor_interior(actor: Node3D) -> void:
	if not is_instance_valid(actor):
		return

	if not _actores_interiores_fijados.has(actor):
		_actores_interiores_fijados.append(actor)

	_actualizar_cubierta()


func soltar_actor_interior(actor: Node3D) -> void:
	_actores_interiores_fijados.erase(actor)
	_actualizar_cubierta()
```

Dentro de `_actualizar_cubierta()`, reemplazá el cálculo de `ocultar` por:

```gdscript
var hay_actor_fijado := false

for actor in _actores_interiores_fijados:
	if is_instance_valid(actor):
		hay_actor_fijado = true
		break

var ocultar := (
	ocultar_cubierta_al_entrar
	and (
		not _jugadores_dentro.is_empty()
		or hay_actor_fijado
	)
)
```

Para conectarlo sin agregar dependencias al adaptador, añadí al script de tu escena de prueba:

```gdscript
@export var casa_prueba: CasaTransitable
@export var asiento_jugador: ActorAsiento


func _ready() -> void:
	asiento_jugador.sentado.connect(_al_sentarse)
	asiento_jugador.levantado.connect(_al_levantarse)


func _al_sentarse() -> void:
	casa_prueba.fijar_actor_interior(asiento_jugador.actor)


func _al_levantarse() -> void:
	# Dar tiempo al Area3D para volver a detectar el collider.
	await get_tree().physics_frame
	await get_tree().physics_frame
	casa_prueba.soltar_actor_interior(asiento_jugador.actor)
```

**Durante los 0,25 s de alineación puede haber un breve cambio de visibilidad**, porque la señal `sentado` se emite al terminar. Si querés eliminarlo, fijá al actor desde la señal `mueble_utilizado` de `InteriorCasa`, comprobando que el punto sea una `SillaCasa` y el actor sea el jugador.

Este enlace manual es para la prueba de una casa. Después lo centralizaremos para que cada asiento identifique su edificio.

---

# 10. Prueba de ajuste de la pose

Hacelo en este orden.

### A. Sin animación

Primero dejá `animaciones` vacío.

Comprobá:

- Desde lejos no permite sentarse.
- Cerca del punto de aproximación sí acepta.
- El actor se alinea con la silla.
- H lo devuelve a una salida libre.
- Movimiento y colisiones vuelven a funcionar.

**Ver al personaje rígido en esta prueba es normal.** Todavía estás comprobando la lógica.

### B. Con animación

Asigná tu animación real.

Ajustá `offset_raiz` hasta conseguir:

- Cadera sobre el asiento.
- Espalda alineada con el respaldo.
- Pies sin enterrarse.
- Rodillas sin atravesar la mesa.

No corrijas todo subiendo la raíz: a veces el problema está en la propia pose o en la altura de la silla.

### C. Salida bloqueada

Colocá un obstáculo con colisión en el punto de salida.

Resultado esperado:

```text
H → “No se puede levantar: no cabe el personaje de pie”
```

El personaje debe **seguir sentado y conservar la reserva**.

Retirá el obstáculo y probá nuevamente.

### D. Dos personajes

Si dos actores intentan usar la misma silla:

- El primero reserva.
- El segundo recibe rechazo.
- La silla vuelve a estar disponible cuando el primero se levanta.

---

# 11. NPCs: no uses todavía la prueba anterior sin modificarla

El script anterior `prueba_npc_mueble.gd` hacía esto después de llegar:

```text
Intentar usar
→ liberar reserva
→ restaurar deambulación
```

**Ese comportamiento ya no sirve para una silla real.** Liberaría la silla inmediatamente y podría reactivar al NPC mientras está sentado.

Para las sillas, la secuencia deberá ser:

```text
Reservar
→ caminar a aproximación
→ detener navegación
→ intentar_usar()
→ mantener comportamiento suspendido
→ solicitar_levantarse()
→ esperar señal levantado
→ recuperar comportamiento
```

El adaptador ya permite la parte de sentarse y levantarse, pero **la restauración de deambulación debe conectarse a tu controlador real**, no suponerse a partir del fragmento de `CozyNPC` que aparece en el contexto.

---

## Resultado de esta entrega

La silla deja de ser solamente un punto que imprime “Sentarse”:

- Tiene una aproximación obligatoria.
- Mantiene una reserva durante su uso.
- Coloca al personaje en una pose configurable.
- Puede reproducir una animación existente.
- Comprueba una salida antes de devolverle el control.

**El próximo ajuste útil es consolidar los estados del personaje —libre, caminando a un mueble, sentado y levantándose— para que jugador y NPC compartan las acciones sin competir con sus controladores.**