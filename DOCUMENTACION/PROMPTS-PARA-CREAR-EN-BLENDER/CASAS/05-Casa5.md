Seguimos con **puertas abatibles**, primero. Las dejamos como un componente reutilizable para las cinco casas, sin modificar los GLB ni depender del controlador `CozyNPC`, cuyo código completo no aparece en este contexto.

Después conectaremos las sillas al mismo sistema de interacción y reservas. Conviene separar las pruebas: **una puerta que bloquea el acceso puede parecer un fallo de navegación o de la silla**.

> **Alcance de esta entrega:** hoja provisional, colisión móvil, apertura/cierre e interacción del jugador. No incluye todavía apertura automática por NPCs ni actualización de navegación. No he ejecutado estos scripts en Godot: requieren la prueba de integración indicada al final.

## Antes de continuar: dos precauciones

- El script de Blender de la choza está recortado en el contexto. **No se puede ejecutar tal como aparece aquí**, y el generador por lotes depende de partes que faltan. Lo siguiente supone que ya tenés los GLB generados.
- La rampa anterior termina su pendiente dentro de la casa. Eso puede dejar un pequeño encuentro contra el frente del cimiento. **Probá primero el paso sin puerta**: si ya se traba allí, la puerta no resolverá ese problema.

---

# 1. Cómo incorporamos la puerta

Añadimos un hijo a cada instancia de `CASA_BASE`:

```text
CASA_BASE
├── Interior
├── Navegacion
└── PUERTA_PRINCIPAL          ← PuertaCasa
```

Los nodos visuales y físicos de la hoja se crean al iniciar:

```text
PUERTA_PRINCIPAL
├── HOJA                     ← AnimatableBody3D, origen en la bisagra
│   ├── VISUAL
│   └── CollisionShape3D
└── ZONA_BARRIDO              ← Area3D de precaución
    └── CollisionShape3D
```

Usamos **`AnimatableBody3D`**, no el trimesh estático de la casa.

La hoja inicial es un tablón liso de prueba. **No lo consideramos el acabado artístico final**: posteriormente se puede sustituir su visual por una puerta modelada, conservando bisagra, colisión y lógica.

---

# 2. Script `puerta_casa.gd`

Guardá:

```text
res://casas/scripts/puerta_casa.gd
```

```gdscript
class_name PuertaCasa
extends Node3D

signal apertura_completada(puerta: PuertaCasa)
signal cierre_completado(puerta: PuertaCasa)
signal movimiento_interrumpido(puerta: PuertaCasa)
signal solicitud_rechazada(motivo: String)

enum Estado {
	CERRADA,
	ABRIENDO,
	ABIERTA,
	CERRANDO,
	DETENIDA,
}

@export_category("Vano")
@export var ancho_vano: float = 1.0
@export var alto_vano: float = 2.10

# Separación respecto al marco y al piso.
@export var holgura: float = 0.025
@export var espesor_hoja: float = 0.035

@export_category("Movimiento")
# Con bisagra a la izquierda y frente hacia -Z,
# -90 grados abre hacia el interior, +Z.
@export_range(-120.0, 120.0, 1.0)
var angulo_abierta: float = -90.0

@export_range(10.0, 180.0, 1.0)
var velocidad_grados: float = 65.0

@export var iniciar_abierta: bool = false

@export_category("Física")
@export_flags_3d_physics var capa_entorno: int = 1

# Incluir las capas de jugador y NPCs.
@export_flags_3d_physics var mascara_actores: int = 3

# Detector conservador alrededor de la bisagra.
@export var margen_barrido: float = 0.20

@export_category("Interacción")
@export var distancia_interaccion: float = 2.6

@export_category("Visual provisional")
@export var color_madera: Color = Color("#8C6941")

var estado: Estado = Estado.CERRADA

var _hoja: AnimatableBody3D
var _zona: Area3D

var _ancho: float
var _alto: float

var _angulo_actual: float = 0.0
var _objetivo_abierto: bool = false
var _lista: bool = false


func _ready() -> void:
	if (
		ancho_vano <= holgura * 2.0
		or alto_vano <= holgura * 2.0
		or espesor_hoja <= 0.0
		or velocidad_grados <= 0.0
		or absf(angulo_abierta) < 1.0
	):
		push_error("%s: parámetros de puerta inválidos." % name)
		set_physics_process(false)
		return

	_ancho = ancho_vano - holgura * 2.0
	_alto = alto_vano - holgura * 2.0

	_crear_hoja()
	_crear_detector()

	_objetivo_abierto = iniciar_abierta
	_angulo_actual = (
		deg_to_rad(angulo_abierta)
		if iniciar_abierta
		else 0.0
	)

	_hoja.rotation.y = _angulo_actual
	estado = Estado.ABIERTA if iniciar_abierta else Estado.CERRADA

	add_to_group("PUERTAS_INTERACTUABLES")
	_habilitar_despues_de_sincronizar()


func _habilitar_despues_de_sincronizar() -> void:
	# El Area3D necesita sincronizar sus solapamientos.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_lista = true


func _crear_hoja() -> void:
	_hoja = AnimatableBody3D.new()
	_hoja.name = "HOJA"
	_hoja.collision_layer = capa_entorno
	_hoja.collision_mask = mascara_actores
	_hoja.sync_to_physics = true
	add_child(_hoja)

	# El origen del cuerpo es la bisagra inferior.
	var centro := Vector3(_ancho * 0.5, _alto * 0.5, 0.0)
	var medidas := Vector3(_ancho, _alto, espesor_hoja)

	var mesh := BoxMesh.new()
	mesh.size = medidas

	var mat := StandardMaterial3D.new()
	mat.resource_name = "MAT_PUERTA_PROVISIONAL"
	mat.albedo_color = color_madera
	mat.roughness = 0.88
	mesh.material = mat

	var visual := MeshInstance3D.new()
	visual.name = "VISUAL"
	visual.mesh = mesh
	visual.position = centro
	_hoja.add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = medidas

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	collision.position = centro
	_hoja.add_child(collision)


func _crear_detector() -> void:
	_zona = Area3D.new()
	_zona.name = "ZONA_BARRIDO"
	_zona.collision_layer = 0
	_zona.collision_mask = mascara_actores
	_zona.monitoring = true
	_zona.monitorable = false
	add_child(_zona)

	# Cubre todo el círculo alrededor de la bisagra.
	# Es más restrictivo que el sector barrido real.
	var shape := CylinderShape3D.new()
	shape.radius = _ancho + margen_barrido
	shape.height = _alto + 0.10

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	collision.position.y = _alto * 0.5
	_zona.add_child(collision)


func hay_actor_en_barrido() -> bool:
	if not is_instance_valid(_zona):
		return true

	for body in _zona.get_overlapping_bodies():
		# Ignoramos paredes, suelo y la propia hoja.
		# Los actores de esta guía utilizan CharacterBody3D.
		if body is CharacterBody3D:
			return true

	return false


func esta_moviendose() -> bool:
	return estado == Estado.ABRIENDO or estado == Estado.CERRANDO


func solicitar_alternar() -> bool:
	return solicitar_apertura(not _objetivo_abierto)


func solicitar_apertura(abrir: bool) -> bool:
	if not _lista:
		return false

	if esta_moviendose():
		return false

	if abrir and estado == Estado.ABIERTA:
		return true

	if not abrir and estado == Estado.CERRADA:
		return true

	if hay_actor_en_barrido():
		solicitud_rechazada.emit(
			"Alejá un poco al personaje del giro de la puerta."
		)
		return false

	_objetivo_abierto = abrir
	estado = Estado.ABRIENDO if abrir else Estado.CERRANDO
	return true


func _physics_process(delta: float) -> void:
	if not _lista or not esta_moviendose():
		return

	# Si alguien entra en la zona, detenemos la hoja.
	if hay_actor_en_barrido():
		estado = Estado.DETENIDA
		movimiento_interrumpido.emit(self)
		return

	var destino := (
		deg_to_rad(angulo_abierta)
		if _objetivo_abierto
		else 0.0
	)

	_angulo_actual = move_toward(
		_angulo_actual,
		destino,
		deg_to_rad(velocidad_grados) * delta
	)

	_hoja.rotation.y = _angulo_actual

	if absf(_angulo_actual - destino) < 0.0001:
		if _objetivo_abierto:
			estado = Estado.ABIERTA
			apertura_completada.emit(self)
		else:
			estado = Estado.CERRADA
			cierre_completado.emit(self)


func obtener_objetivo_visual() -> Vector3:
	if not is_instance_valid(_hoja):
		return global_position

	# Aproximadamente donde colocaríamos el tirador.
	return _hoja.to_global(
		Vector3(_ancho * 0.80, _alto * 0.48, 0.0)
	)


func es_collider_de_hoja(collider: Object) -> bool:
	return collider == _hoja


func texto_accion() -> String:
	if esta_moviendose():
		return "Puerta en movimiento"

	if estado == Estado.DETENIDA:
		return "Devolver puerta"

	return "Cerrar puerta" if _objetivo_abierto else "Abrir puerta"
```

### Por qué la zona de precaución es grande

Para esta primera prueba, preferimos que la puerta **se niegue a girar si un personaje está cerca**, antes que empujarlo contra el marco.

Eso implica:

1. Acercarte.
2. Apuntar a la puerta.
3. Retroceder un poco si estás dentro de su giro.
4. Abrir.
5. Esperar a que termine.
6. Cruzar.

**No es una detección continua de colisiones ni una garantía contra atrapamientos.** Los solapamientos se actualizan por pasos de física; además, esta versión detecta `CharacterBody3D`, no cajas móviles u otros objetos. Es una protección conservadora para las pruebas.

---

# 3. Colocación en cada casa

El origen de `PUERTA_PRINCIPAL` representa la **bisagra inferior**, no el centro de la puerta.

Para las casas 2–5 del generador:

```text
X = puerta_centro_x - puerta_ancho / 2 + holgura
Y = piso_terminado_y + holgura
Z = -ancho_y_blender + 0.06
```

El `+0.06` corresponde al centro de la pared frontal tal como quedó escrito en ese generador, incluso en la mansión.

Con `holgura = 0.025`:

| Casa | Posición del nodo `(X, Y, Z)` | Ancho vano | Alto vano |
|---|---|---:|---:|
| Choza | `(2.025, 0.270, -3.940)`* | 1,00 | 2,10 |
| Mediana | `(5.025, 0.320, -5.940)` | 1,00 | 2,10 |
| Casona | `(4.525, 0.370, -7.940)` | 1,00 | 2,10 |
| Mansión | `(6.425, 0.470, -9.940)` | 1,20 | 2,20 |
| Vecino | `(2.025, 0.220, -4.940)` | 1,00 | 2,10 |

\* **Choza:** posición inicial orientativa. Como falta el tramo que construye su pared, verificá visualmente dónde está el centro de su espesor y ajustá Z.

En todos los casos:

```text
Rotation = (0, 0, 0)
Scale = (1, 1, 1)
Ángulo abierta = -90°
```

Así, la puerta abre hacia dentro. **Comprobá que su giro no atraviese muebles o paredes interiores**: el detector anterior no valida obstáculos arquitectónicos.

---

# 4. Interacción del jugador

Durante esta etapa usamos una acción independiente:

```text
usar_puerta → tecla G
```

No cambiamos las acciones existentes de muebles o diálogo.

Creala en:

```text
Project → Project Settings → Input Map
```

Después guardá:

```text
res://casas/scripts/interactor_puertas.gd
```

```gdscript
extends Node

@export var actor: CharacterBody3D
@export var camara: Camera3D

@export var angulo_maximo: float = 25.0

# Debe incluir las capas de puertas y paredes.
@export_flags_3d_physics var mascara_obstaculos: int = 1

# Opcional: Label de tu interfaz.
@export var etiqueta: Label

var _seleccionada: PuertaCasa


func _physics_process(_delta: float) -> void:
	_seleccionada = _buscar_puerta()

	if is_instance_valid(etiqueta):
		etiqueta.text = (
			"[G] " + _seleccionada.texto_accion()
			if is_instance_valid(_seleccionada)
			else ""
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	if not event.is_action_pressed("usar_puerta"):
		return

	# Volvemos a comprobar distancia y línea de visión.
	var puerta := _buscar_puerta()

	if puerta == null:
		return

	if not puerta.solicitar_alternar():
		if puerta.hay_actor_en_barrido():
			print("Alejate un poco del giro de la puerta.")

	get_viewport().set_input_as_handled()


func _buscar_puerta() -> PuertaCasa:
	if not is_instance_valid(actor) or not is_instance_valid(camara):
		return null

	var frente := -camara.global_basis.z.normalized()
	var limite := cos(deg_to_rad(angulo_maximo))

	var mejor: PuertaCasa
	var puntuacion_mejor := -INF

	for node in get_tree().get_nodes_in_group("PUERTAS_INTERACTUABLES"):
		var puerta := node as PuertaCasa

		if puerta == null or puerta.esta_moviendose():
			continue

		var objetivo := puerta.obtener_objetivo_visual()
		var distancia := actor.global_position.distance_to(objetivo)

		if distancia > puerta.distancia_interaccion:
			continue

		var direccion := objetivo - camara.global_position

		if direccion.length_squared() < 0.001:
			continue

		var alineacion := frente.dot(direccion.normalized())

		if alineacion < limite:
			continue

		if not _visible(puerta, objetivo):
			continue

		var puntuacion := alineacion * 4.0 - distancia

		if puntuacion > puntuacion_mejor:
			mejor = puerta
			puntuacion_mejor = puntuacion

	return mejor


func _visible(puerta: PuertaCasa, objetivo: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		camara.global_position,
		objetivo
	)

	query.collision_mask = mascara_obstaculos
	query.collide_with_areas = false
	query.exclude = [actor.get_rid()]

	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return true

	return puerta.es_collider_de_hoja(hit.get("collider"))
```

Añadilo como hijo del jugador:

```text
PLAYER
├── Camera3D
├── InteractorMuebles
└── InteractorPuertas
```

Asigná `actor`, `camara` y, si querés mostrar el texto, una `Label` propia.

---

# 5. La navegación necesita una decisión explícita

**Una puerta con colisión móvil no actualiza automáticamente el `NavigationMesh`.**

Además, el recolector de geometría que ya tenés solo procesa cuerpos `StaticBody3D`. Por tanto:

- Las paredes y el suelo entran en el bake.
- Esta hoja `AnimatableBody3D` **queda fuera del bake**.
- La navegación seguirá considerando transitable el vano.
- Con la puerta cerrada, un NPC podría calcular una ruta que atraviese el vano y quedarse detenido físicamente contra la hoja.

No vamos a presentar eso como navegación resuelta.

### Configuración para esta etapa

Para probar al jugador:

```text
Iniciar abierta = false
```

Para repetir las pruebas de NPC → mueble:

```text
Iniciar abierta = true
```

Y mantené la puerta abierta durante el recorrido.

### Integración posterior de NPCs

El comportamiento deberá ser:

```text
Llegar a un punto de espera fuera del giro
→ solicitar apertura
→ esperar apertura_completada
→ cruzar
→ abandonar la zona de barrido
→ permitir cierre
```

Las señales ya están preparadas para ese circuito.

**Añadir únicamente un `NavigationObstacle3D` no basta:** la evitación local no reemplaza el control del paso ni modifica por sí sola la conectividad de la ruta.

---

# 6. Prueba recomendada

Primero, **una sola puerta en la choza**.

### A. Entrada sin hoja

Desactivá temporalmente el nodo de puerta o retiralo de la escena de prueba.

Comprobá:

- La rampa no engancha al personaje contra el cimiento.
- El vano permite entrar.
- No hay una colisión invisible sobre el hueco.

### B. Hoja cerrada

Activá la puerta:

- Debe quedar dentro del marco.
- No debe atravesar el piso.
- Debe bloquear físicamente el acceso.
- No debe aparecer una segunda colisión generada desde la casa: esta hoja es un componente aparte.

### C. Apertura

Desde fuera del giro:

1. Apuntá a la hoja.
2. Pulsá G.
3. Esperá a que termine.
4. Cruzá.

Si no abre y aparece el aviso, retrocedé un poco. El detector también considera al personaje que solicita la apertura.

### D. Cierre y bloqueo

- Alejate del barrido desde dentro.
- Cerrá.
- Probá entrar en la zona mientras gira: debe detenerse.
- Salí de la zona y pulsá G: desde el estado detenido intentará regresar hacia el extremo contrario al movimiento interrumpido.

### E. Otras casas

Repetí verificando especialmente:

- **Mediana:** giro dentro del dormitorio.
- **Casona:** no invadir el paso del vestíbulo.
- **Mansión:** mayor radio de giro por su hoja de 1,20 m.
- **Vecino:** compatibilidad con el toldo, la rampa y el acceso del patio.

---

## Qué queda añadido

- Una puerta exterior independiente por casa.
- Bisagra y dimensiones configurables.
- Colisión móvil separada del modelo estático.
- Interacción con distancia y línea de visión.
- Apertura, cierre y detención conservadora ante personajes.
- Señales para conectar después los NPCs.

**La siguiente pieza es la silla:** separaremos la posición de aproximación, la pose sentada y la posición de salida. Antes de desplazar al personaje al asiento, habrá que validar la salida y coordinar su controlador y animaciones; no conviene resolverlo teletransportándolo al centro del mueble.