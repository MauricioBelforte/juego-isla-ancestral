Seguimos con los perfiles de rutina: los horarios, casas y preferencias dejan de estar escritos en código y pasan a ser recursos editables.

La pieza clave es esta separación:

text

PerfilRutina (Resource)   → QUÉ hacer y CUÁNDO
AgendaNPC (por NPC)       → CUÁNDO empezar cada visita
RutinaCasa (por NPC)      → CÓMO ejecutar una visita
CrucePuerta / AccionMueble→ CÓMO moverse sin romper nada
La lógica de circulación no se duplica: la agenda solo configura y dispara RutinaCasa.

Como siempre: no he ejecutado esto en Godot. Está escrito contra los componentes anteriores y requiere las pruebas del final.

1. Qué hace falta: un reloj
Las rutinas dependen de la hora del día. Si tu proyecto ya tiene un sistema de tiempo, podés adaptarlo; mientras tanto añadimos uno mínimo.

Guardá:

text

res://casas/scripts/reloj_juego.gd
gdscript

class_name RelojJuego
extends Node

signal minuto_cambiado(minutos_del_dia: int)
signal dia_cambiado(dia: int)

@export_range(0.0, 23.99, 0.01)
var hora_inicial: float = 8.0

# 1.0 = un minuto de juego por segundo real (día de 24 minutos).
@export var minutos_juego_por_segundo: float = 1.0

@export var activo: bool = true

var minutos_del_dia: float = 0.0
var dia: int = 0

var _ultimo_minuto_emitido: int = -1


func _ready() -> void:
	minutos_del_dia = hora_inicial * 60.0


func _process(delta: float) -> void:
	if not activo:
		return

	minutos_del_dia += delta * minutos_juego_por_segundo

	while minutos_del_dia >= 1440.0:
		minutos_del_dia -= 1440.0
		dia += 1
		dia_cambiado.emit(dia)

	var minuto := int(minutos_del_dia)

	if minuto != _ultimo_minuto_emitido:
		_ultimo_minuto_emitido = minuto
		minuto_cambiado.emit(minuto)


func hora_actual() -> float:
	return minutos_del_dia / 60.0


func tiempo_absoluto() -> float:
	return dia * 1440.0 + minutos_del_dia


func establecer_hora(hora: float) -> void:
	# Para pruebas. No emite minutos intermedios.
	minutos_del_dia = wrapf(hora, 0.0, 24.0) * 60.0
	_ultimo_minuto_emitido = -1


func hora_texto() -> String:
	var h := int(minutos_del_dia / 60.0)
	var m := int(minutos_del_dia) % 60
	return "%02d:%02d" % [h, m]
Colocá una sola instancia en la escena de prueba. Todos los NPCs comparten el mismo reloj.

2. Los recursos de rutina
bloque_rutina.gd
text

res://casas/scripts/bloque_rutina.gd
gdscript

class_name BloqueRutina
extends Resource

# Solo existe una actividad real por ahora.
# CAMA, COCINA y demás llegarán cuando esos muebles
# tengan uso implementado, no antes.
enum Actividad { SENTARSE }

@export var nombre: String = "Actividad"

@export_range(0.0, 24.0, 0.25)
var hora_inicio: float = 8.0

@export_range(0.0, 24.0, 0.25)
var hora_fin: float = 10.0

# Debe coincidir con el identificador de una CasaTransitable.
@export var id_casa: StringName = &"CASA_01"

@export var actividad: Actividad = Actividad.SENTARSE

# Segundos reales de uso del mueble.
@export var duracion_uso: float = 12.0

# Si dos bloques se solapan, gana el de mayor prioridad.
@export var prioridad: int = 0

# Vacío = cualquier silla disponible.
# Acepta tipo ("SILLA") o prefijo de identificador.
@export var tipos_aceptables: Array[StringName] = []


func esta_activo(hora: float) -> bool:
	if hora_fin > hora_inicio:
		return hora >= hora_inicio and hora < hora_fin

	if hora_fin < hora_inicio:
		# Bloque que cruza medianoche, p.ej. 22 → 2.
		return hora >= hora_inicio or hora < hora_fin

	# inicio == fin se considera bloque vacío.
	return false
perfil_rutina.gd
text

res://casas/scripts/perfil_rutina.gd
gdscript

class_name PerfilRutina
extends Resource

@export var nombre_perfil: String = "Perfil"
@export var bloques: Array[BloqueRutina] = []


func bloque_activo(hora: float) -> BloqueRutina:
	var mejor: BloqueRutina

	for bloque in bloques:
		if bloque == null or not bloque.esta_activo(hora):
			continue

		if (
			mejor == null
			or bloque.prioridad > mejor.prioridad
			or (
				bloque.prioridad == mejor.prioridad
				and bloque.hora_inicio < mejor.hora_inicio
			)
		):
			mejor = bloque

	return mejor
Los perfiles son recursos compartibles: varios vecinos pueden usar el mismo, o cada uno puede tener el suyo.

3. Cambios en RutinaCasa
Ahora el destino llega por parámetros. Aplicá estos ajustes al script de la entrega anterior.

A. Interior y navegación pasan a ser asignables
Reemplazá _preparar_referencias() por esta versión, que exige solo las referencias personales y deja el destino para después:

gdscript

func _preparar_referencias() -> bool:
	if not is_instance_valid(cruce) or not is_instance_valid(cruce.accion):
		return false

	_accion = cruce.accion
	_asiento = _accion.asiento
	_actor = _accion.actor

	if not is_instance_valid(_asiento) or not is_instance_valid(_actor):
		return false

	_control = (
		_asiento.controlador
		if _asiento.controlador != null
		else _actor
	)

	return (
		is_instance_valid(_control)
		and _control != self
		and _control != cruce
		and _control != _accion
		and _control != _asiento
	)
Añadí las variables de visita:

gdscript

var duracion_sentado_visita: float = -1.0
var tipos_aceptables: Array[StringName] = []
Y el método que usa la agenda:

gdscript

func asignar_destino(
	p_interior: InteriorCasa,
	p_navegacion: NavegacionCasa,
	duracion: float = -1.0,
	tipos: Array[StringName] = []
) -> bool:
	if (
		not is_instance_valid(p_interior)
		or not is_instance_valid(p_navegacion)
	):
		return false

	interior = p_interior
	navegacion = p_navegacion
	duracion_sentado_visita = duracion
	tipos_aceptables = tipos.duplicate()
	return true
B. iniciar() exige destino
Al comienzo de iniciar(), después de la comprobación de _conectada:

gdscript

if (
	not is_instance_valid(interior)
	or not is_instance_valid(navegacion)
):
	push_warning("RutinaCasa: falta asignar destino.")
	return false
Cuando la agenda maneja la rutina:

text

Iniciar automáticamente = false
Repetir visita = false
La agenda decide cuándo empieza cada visita; la repetición interna queda para pruebas manuales.

C. Duración por visita
En _al_sentarse(), reemplazá el cálculo de espera por:

gdscript

var duracion := (
	duracion_sentado_visita
	if duracion_sentado_visita > 0.0
	else segundos_sentado
)

estado = Estado.SENTADO
_espera = maxf(0.1, duracion)
D. Filtro de preferencia de sillas
En _buscar_y_solicitar_silla(), dentro del bucle y después de las comprobaciones de configuración, agregá:

gdscript

if not _tipo_aceptado(silla):
	continue
Y añadí:

gdscript

func _tipo_aceptado(silla: SillaCasa) -> bool:
	if tipos_aceptables.is_empty():
		return true

	var id := String(silla.identificador)

	for tipo in tipos_aceptables:
		if silla.tipo == tipo:
			return true

		if id.begins_with(String(tipo)):
			return true

	return false
Así un bloque puede pedir, por ejemplo, ["SILLA"] genérico o un prefijo concreto como ["SILLA_COMEDOR"].

4. Registrar las casas
En casa_transitable.gd, dentro de _ready(), agregá:

gdscript

add_to_group("CASAS")
Y verificá que cada instancia tenga su identificador correcto:

text

CASA_01, CASA_02, CASA_03, CASA_04, CASA_05
Los bloques de rutina se refieren a las casas por ese identificador, no por ruta de nodo. Así el mismo perfil sirve aunque reorganices la escena.

5. La agenda del NPC
Guardá:

text

res://casas/scripts/agenda_npc.gd
gdscript

class_name AgendaNPC
extends Node

@export var rutina: RutinaCasa
@export var reloj: RelojJuego
@export var perfil: PerfilRutina

@export_category("Comportamiento")
@export var activa: bool = true

# Tras un fallo o rechazo, cuántos minutos de juego
# esperar antes de reintentar el mismo bloque.
@export var reintento_minutos: float = 20.0

# Evita iniciar visitas a casas inalcanzables por navegación.
@export var comprobar_acceso_previo: bool = true
@export var tolerancia_acceso: float = 1.5

var _visitando: bool = false
var _bloque_en_curso: BloqueRutina

# instance_id del bloque → tiempo absoluto del último intento.
var _intentos: Dictionary = {}

# instance_id del bloque → día en que se completó.
var _completados: Dictionary = {}


func _ready() -> void:
	if not _validar():
		push_error("AgendaNPC: faltan referencias.")
		return

	reloj.minuto_cambiado.connect(_on_minuto)
	rutina.visita_terminada.connect(_al_terminar_visita)
	rutina.rutina_detenida.connect(_al_detenerse)

	# Evaluación inicial por si empezamos dentro de un bloque.
	call_deferred("_evaluar")


func _validar() -> bool:
	return (
		is_instance_valid(rutina)
		and is_instance_valid(reloj)
		and is_instance_valid(rutina.cruce)
		and is_instance_valid(rutina.cruce.accion)
	)


func _on_minuto(_minuto: int) -> void:
	_evaluar()


func _evaluar() -> void:
	if not activa or _visitando:
		return

	if perfil == null:
		return

	if rutina.estado not in [
		RutinaCasa.Estado.INACTIVA,
		RutinaCasa.Estado.TERMINADA,
	]:
		return

	var bloque := perfil.bloque_activo(reloj.hora_actual())

	if bloque == null:
		return

	var clave := bloque.get_instance_id()

	# Una visita completada no se repite el mismo día.
	if _completados.get(clave, -1) == reloj.dia:
		return

	# Cooldown tras intentos fallidos.
	var ultimo: float = _intentos.get(clave, -INF)

	if reloj.tiempo_absoluto() - ultimo < reintento_minutos:
		return

	var destino := _resolver_casa(bloque.id_casa)

	if destino.is_empty():
		push_warning(
			"AgendaNPC: no se encontró la casa %s."
			% bloque.id_casa
		)
		_registrar_intento(clave)
		return

	if (
		comprobar_acceso_previo
		and not _acceso_preliminar(destino)
	):
		# Típico cuando el NPC está junto a otra casa
		# y las navegaciones no se conectan todavía.
		_registrar_intento(clave)
		return

	if not rutina.asignar_destino(
		destino["interior"],
		destino["navegacion"],
		bloque.duracion_uso,
		bloque.tipos_aceptables
	):
		_registrar_intento(clave)
		return

	_registrar_intento(clave)

	if rutina.iniciar():
		_visitando = true
		_bloque_en_curso = bloque
		print(
			"%s inicia «%s» (%s)."
			% [rutina._actor.name, bloque.nombre, reloj.hora_texto()]
		)


func _resolver_casa(id: StringName) -> Dictionary:
	for node in get_tree().get_nodes_in_group("CASAS"):
		var casa := node as CasaTransitable

		if casa == null or casa.identificador != id:
			continue

		var interior: InteriorCasa
		var nav: NavegacionCasa

		for hijo in casa.get_children():
			if hijo is InteriorCasa:
				interior = hijo
			elif hijo is NavegacionCasa:
				nav = hijo

		if interior != null and nav != null:
			return {
				"casa": casa,
				"interior": interior,
				"navegacion": nav,
			}

	return {}


func _acceso_preliminar(destino: Dictionary) -> bool:
	var nav := destino["navegacion"] as NavegacionCasa
	var casa := destino["casa"] as CasaTransitable
	var mapa := nav.get_navigation_map()

	if (
		not mapa.is_valid()
		or NavigationServer3D.map_get_iteration_id(mapa) == 0
	):
		return false

	var actor := rutina.cruce.accion.actor

	if not is_instance_valid(actor):
		return false

	var origen := NavigationServer3D.map_get_closest_point(
		mapa, actor.global_position
	)

	if origen.distance_to(actor.global_position) > tolerancia_acceso:
		return false

	# Comprobación aproximada hacia el centro de la casa.
	# El punto exacto de cola lo valida después CrucePuerta.
	var centro := casa.to_global(Vector3(
		casa.largo_x * 0.5,
		casa.piso_terminado_y,
		-casa.ancho_y_blender * 0.5
	))

	var punto_casa := NavigationServer3D.map_get_closest_point(
		mapa, centro
	)

	if punto_casa.distance_to(centro) > tolerancia_acceso:
		return false

	var ruta := NavigationServer3D.map_get_path(
		mapa, origen, punto_casa, true
	)

	return not ruta.is_empty()


func _al_terminar_visita() -> void:
	_visitando = false

	if _bloque_en_curso != null:
		_completados[
			_bloque_en_curso.get_instance_id()
		] = reloj.dia

	_bloque_en_curso = null

	# Puede haber otro bloque activo a continuación.
	call_deferred("_evaluar")


func _al_detenerse(motivo: String) -> void:
	_visitando = false
	_bloque_en_curso = null
	activa = false

	push_warning(
		"AgendaNPC desactivada: " + motivo
		+ " Recuperá la rutina manualmente antes de reactivarla."
	)


func _registrar_intento(clave: int) -> void:
	_intentos[clave] = reloj.tiempo_absoluto()


func reactivar() -> bool:
	# Llamar solo después de devolver el control con éxito
	# mediante RutinaCasa.devolver_control_tras_revision().
	if rutina.estado != RutinaCasa.Estado.TERMINADA:
		return false

	activa = true
	call_deferred("_evaluar")
	return true
Decisiones deliberadas
Una visita completada no se repite el mismo día. Un bloque de 7:00–10:00 produce una visita, no una cadena infinita de idas y vueltas.

La agenda no interrumpe una visita en curso. Si el bloque termina mientras el NPC está sentado, completa la salida normal. Interrumpir a mitad de cruce de puerta o de asiento reabriría los casos peligrosos que ya marcamos; queda como trabajo posterior con cancelaciones seguras.

El precheck de acceso evita la peor falla. Sin navegación que conecte casas entre sí, un bloque que manda al NPC al otro lado del pueblo terminaría en DETENIDA. Con el precheck, el bloque se pospone y la agenda sigue viva.

6. Crear los perfiles
La forma más segura es desde el editor:

En el panel FileSystem, clic derecho → Create New → Resource.
Buscá PerfilRutina.
Guardalo como res://casas/perfiles/perfil_lector.tres.
En el Inspector, agregá elementos a Bloques → New BloqueRutina y completá los campos.
Un archivo de ejemplo resultante sería parecido a esto (si tu versión se queja del formato de arrays tipados, creálo desde el editor en su lugar):

ini

[gd_resource type="Resource" script_class="PerfilRutina" load_steps=4 format=3]

[ext_resource type="Script" path="res://casas/scripts/perfil_rutina.gd" id="1"]
[ext_resource type="Script" path="res://casas/scripts/bloque_rutina.gd" id="2"]

[sub_resource type="Resource" id="Bloque_manana"]
script = ExtResource("2")
nombre = "Lectura de mañana"
hora_inicio = 7.0
hora_fin = 10.0
id_casa = &"CASA_01"
actividad = 0
duracion_uso = 20.0
prioridad = 1
tipos_aceptables = Array[StringName]([&"SILLA"])

[sub_resource type="Resource" id="Bloque_tarde"]
script = ExtResource("2")
nombre = "Visita de tarde"
hora_inicio = 17.0
hora_fin = 19.0
id_casa = &"CASA_01"
actividad = 0
duracion_uso = 15.0
prioridad = 0
tipos_aceptables = Array[StringName]([])

[resource]
script = ExtResource("1")
nombre_perfil = "Vecino lector"
bloques = Array[BloqueRutina]([SubResource("Bloque_manana"), SubResource("Bloque_tarde")])
Perfiles de muestra para empezar
Vecino	Bloques
Lector	7–10 sentarse en CASA_01 · 17–19 otra visita
Madrugador	6–8 sentarse en CASA_01, prioridad alta
Visitante	15–17 CASA_01, prioridad baja
Nota importante: con la navegación actual, cada casa hornea su propia región aislada. Un bloque solo funcionará si el NPC ya está físicamente cerca de la casa destino — el precheck lo verifica y pospone el bloque si no hay ruta. Los perfiles de hoy modelan “quedarse por la zona”; los viajes entre casas son la siguiente etapa.

Un truco válido desde ya: un bloque que apunta a la casa del propio NPC funciona como “estar en casa”, porque la visita lo lleva a sentarse en su propia silla.

7. Montaje de la escena
text

MUNDO
├── RelojJuego                    ← una sola instancia
├── CASA_BASE (CASA_01)
│   ├── PUERTA_PRINCIPAL
│   ├── ESPERA_* y COLA_*
│   ├── GESTOR_PASO
│   ├── Interior
│   └── Navegacion
├── NPC_LECTOR
│   ├── ActorAsiento
│   ├── AgenteMuebles
│   ├── AccionMueble
│   ├── CrucePuerta
│   ├── RutinaCasa
│   └── AgendaNPC
└── NPC_MADRUGADOR (misma estructura)
En cada RutinaCasa:

text

Iniciar automáticamente = false
Repetir visita = false
Interior = (vacío; lo asigna la agenda)
Navegacion = (vacío; lo asigna la agenda)
En cada AgendaNPC:

text

Rutina → su RutinaCasa
Reloj → RelojJuego del mundo
Perfil → su recurso .tres
Eliminá de la escena cualquier prueba_*.gd anterior que ordene a los mismos NPCs.

Para pruebas rápidas, acelerá el reloj:

text

Minutos juego por segundo = 30
Hora inicial = 6.95
Así el bloque de las 7:00 empieza a los pocos segundos.

8. Pruebas
A. Un NPC, un bloque
Hora inicial 6.95, bloque 7:00–10:00.
Al llegar el minuto 7:00, el NPC pide entrada, cruza, se sienta 20 s, sale.
Al terminar la visita, el bloque queda completado: no vuelve a entrar aunque siga dentro del horario.
B. Dos NPCs, mismo bloque y misma casa
Ambos reciben el bloque a la vez.
El gestor de puerta los ordena.
El primero toma la silla; el segundo espera, reintenta y, si no hay otra silla, se va sin sentarse. Su bloque queda en cooldown, no en bucle infinito.
C. Bloque inalcanzable
Asigná un bloque a CASA_02 mientras el NPC está junto a CASA_01.
Resultado esperado: aviso silencioso en consola, cooldown de 20 minutos de juego, la agenda sigue evaluando otros bloques. No debe quedar DETENIDA.
D. Medianoche
Probá un bloque 22:00–2:00. Debe activarse a las 23:00 y también a la 1:00 del día siguiente (con el día ya incrementado, los completados se reinician solos porque se guardan por número de día).
E. Prioridades
Dos bloques solapados: gana el de mayor prioridad; al completarse, el de menor prioridad no se ejecuta si ya terminó su ventana.
9. Limitaciones honestas de esta versión
Sin viajes entre casas: falta una navegación exterior que conecte las regiones (o un sistema de “ir a” entre puntos del pueblo). Hasta entonces, los bloques solo alcanzan casas cercanas.
Sin interrupciones: un NPC sentado 20 segundos no reacciona a un nuevo bloque de mayor prioridad hasta terminar.
Sin hambre, energía ni diálogos: las rutinas son puramente espaciales y horarias.
Las actividades distintas de SENTARSE son nombres en un enum, no implementaciones. No los uses esperando comportamiento.
La hora es local del juego de pruebas. Cuando tengas ciclo día/noche visual, conectá el mismo reloj para que rutinas y cielo coincidan.
Resultado
El comportamiento diario ahora se edita como datos:

text

Perfil (.tres)
  → AgendaNPC lo evalúa cada minuto de juego
  → RutinaCasa ejecuta la visita
  → Puerta, cola, silla y salida funcionan igual que antes
El próximo paso natural es la navegación del pueblo: un NavigationMesh exterior que conecte puertas, caminos y casas, para que los bloques de rutina puedan mandar a un vecino de verdad “a visitar a otro” en lugar de quedarse en su zona.