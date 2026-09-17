Seguimos con **varios NPCs usando la misma puerta**, con una cola compartida y puntos de espera separados.

La diferencia respecto a la etapa anterior es importante: **cada NPC deja de competir directamente por la puerta**. Un gestor de la casa decide quién puede cruzar.

```text
NPC solicita paso
→ recibe un lugar de espera
→ llega a ese lugar
→ espera su turno
→ abre y cruza
→ despeja el vano
→ se habilita el siguiente
```

Usaremos una **cola FIFO global para ambas direcciones**: entra primero quien pidió primero, tanto si quiere entrar como salir.

> No he ejecutado estos scripts en Godot. Esta entrega coordina turnos; no constituye un sistema completo de tráfico ni garantiza que dos personajes no se bloqueen en otros puntos de la casa.

---

# 1. Organización de la puerta

Añadí a la casa:

```text
CASA_BASE
├── PUERTA_PRINCIPAL
├── ESPERA_EXTERIOR
├── ESPERA_INTERIOR
├── COLA_EXT_01
├── COLA_EXT_02
├── COLA_INT_01
├── COLA_INT_02
└── GESTOR_PASO
```

Los cuatro nodos `COLA_*` son `Marker3D`.

### Función de cada marcador

| Marcador | Función |
|---|---|
| `COLA_EXT_*` | Esperar para entrar |
| `COLA_INT_*` | Esperar para salir |
| `ESPERA_INTERIOR` | Terminar el cruce de entrada |
| `ESPERA_EXTERIOR` | Terminar el cruce de salida |

Los puntos que antes usábamos como espera ahora siguen siendo **destinos de salida del cruce**.

### Distribución recomendada

Vista conceptual desde arriba:

```text
              INTERIOR

 COLA_INT_02       pasillo       COLA_INT_01

             ESPERA_INTERIOR

                PUERTA

             ESPERA_EXTERIOR

 COLA_EXT_01       pasillo       COLA_EXT_02

              EXTERIOR
```

**No pongas las colas sobre el eje de paso.** El NPC que ya cruzó debe poder salir del vano sin atravesar a quienes esperan.

Además:

- Cada marcador debe estar sobre navegación.
- La cápsula completa del personaje debe quedar fuera del barrido.
- Separá los puntos entre sí según el diámetro real de los NPCs.
- No coloques puntos interiores dentro de muebles.

En la choza puede no haber espacio para dos esperas interiores. **En ese caso configurá una sola**, en lugar de forzar una cola que no cabe.

---

# 2. Gestor compartido de turnos

Guardá:

```text
res://casas/scripts/gestor_paso_puerta.gd
```

Este gestor:

- Asigna un marcador libre del lado correspondiente.
- Mantiene el orden de solicitudes.
- Otorga un solo turno.
- Conserva la reserva hasta que el barrido esté despejado.
- No cierra automáticamente la puerta entre NPCs.

```gdscript
class_name GestorPasoPuerta
extends Node

@export var puerta: PuertaCasa

@export_category("Lugares de espera")
@export var lugares_exteriores: Array[Marker3D] = []
@export var lugares_interiores: Array[Marker3D] = []

@export_category("Liberación")
# Aproximación conservadora, no una prueba física de cápsulas.
@export var distancia_liberar_lugar: float = 0.85

# Espera adicional después de que el barrido queda libre.
@export var demora_entre_turnos: float = 0.20

var _cola: Array[Dictionary] = []
var _activo: Dictionary = {}

# Un marcador sigue retenido si su antiguo usuario permanece allí.
var _lugares_retenidos: Dictionary = {}

var _despejando: bool = false
var _tiempo_despejado: float = 0.0


func solicitar(actor: CharacterBody3D, entrar: bool) -> Dictionary:
	if not is_instance_valid(actor) or not is_instance_valid(puerta):
		return {}

	if _tiene_solicitud(actor):
		return {}

	_limpiar_lugares_retenidos()

	var lugares: Array[Marker3D] = (
		lugares_exteriores if entrar else lugares_interiores
	)

	var elegido: Marker3D

	for lugar in lugares:
		if not is_instance_valid(lugar):
			continue

		if not _lugares_retenidos.has(lugar):
			elegido = lugar
			break

	if elegido == null:
		# No improvisamos una espera sobre el pasillo.
		return {}

	var solicitud: Dictionary = {
		"actor": actor,
		"entrar": entrar,
		"lugar": elegido,
		"listo": false,
	}

	_cola.append(solicitud)
	_lugares_retenidos[elegido] = actor

	return {
		"lugar": elegido,
		"posicion": elegido.global_position,
	}


func marcar_listo(actor: CharacterBody3D) -> void:
	for i in range(_cola.size()):
		if _cola[i]["actor"] == actor:
			_cola[i]["listo"] = true
			return


func tiene_turno(actor: CharacterBody3D) -> bool:
	return (
		not _despejando
		and not _activo.is_empty()
		and _activo["actor"] == actor
	)


func terminar(actor: CharacterBody3D) -> void:
	if _activo.is_empty():
		return

	if _activo["actor"] != actor:
		return

	# Todavía no liberamos la puerta.
	# El personaje u otro cuerpo pueden seguir dentro del barrido.
	_despejando = true
	_tiempo_despejado = 0.0


func cancelar(actor: CharacterBody3D) -> void:
	for i in range(_cola.size() - 1, -1, -1):
		if _cola[i]["actor"] == actor:
			_cola.remove_at(i)

	if not _activo.is_empty() and _activo["actor"] == actor:
		_despejando = true
		_tiempo_despejado = 0.0

	# El lugar no se libera inmediatamente si el personaje
	# sigue parado encima.
	_limpiar_lugares_retenidos()


func _physics_process(delta: float) -> void:
	_limpiar_solicitudes_invalidas()
	_limpiar_lugares_retenidos()

	if not is_instance_valid(puerta):
		return

	if _despejando:
		_procesar_despeje(delta)
		return

	if not _activo.is_empty():
		return

	if _cola.is_empty():
		return

	# FIFO estricto: el primero conserva prioridad aunque
	# otro NPC haya llegado antes a su marcador.
	var primera: Dictionary = _cola[0]

	if not primera["listo"]:
		return

	# No conceder otro turno si alguien está en el giro
	# o si la hoja todavía se está moviendo.
	if puerta.esta_moviendose() or puerta.hay_actor_en_barrido():
		return

	var actor := primera["actor"] as CharacterBody3D

	if not puerta.reservar_paso(actor):
		return

	_activo = _cola.pop_front()


func _procesar_despeje(delta: float) -> void:
	if puerta.esta_moviendose() or puerta.hay_actor_en_barrido():
		_tiempo_despejado = 0.0
		return

	_tiempo_despejado += delta

	if _tiempo_despejado < demora_entre_turnos:
		return

	if not _activo.is_empty():
		var anterior: Variant = _activo.get("actor")

		if is_instance_valid(anterior):
			puerta.liberar_paso(anterior)

	_activo = {}
	_despejando = false
	_tiempo_despejado = 0.0


func _tiene_solicitud(actor: CharacterBody3D) -> bool:
	if not _activo.is_empty() and _activo["actor"] == actor:
		return true

	for solicitud in _cola:
		if solicitud["actor"] == actor:
			return true

	return false


func _actor_tiene_solicitud(actor: Variant) -> bool:
	if not is_instance_valid(actor):
		return false

	return _tiene_solicitud(actor)


func _limpiar_solicitudes_invalidas() -> void:
	for i in range(_cola.size() - 1, -1, -1):
		if not is_instance_valid(_cola[i]["actor"]):
			_cola.remove_at(i)

	if (
		not _activo.is_empty()
		and not is_instance_valid(_activo["actor"])
	):
		_despejando = true


func _limpiar_lugares_retenidos() -> void:
	for lugar in _lugares_retenidos.keys():
		var actor: Variant = _lugares_retenidos[lugar]

		if not is_instance_valid(lugar) or not is_instance_valid(actor):
			_lugares_retenidos.erase(lugar)
			continue

		if _actor_tiene_solicitud(actor):
			continue

		var separacion: Vector3 = (
			actor.global_position - lugar.global_position
		)
		separacion.y = 0.0

		if separacion.length() > distancia_liberar_lugar:
			_lugares_retenidos.erase(lugar)
```

## Por qué se retiene un lugar después de cancelar

Si un NPC cancela mientras espera, podría quedarse parado en su marcador.

Liberarlo inmediatamente permitiría asignar ese mismo sitio a otro NPC. Por eso se conserva hasta que el antiguo usuario se aleja.

**Esta comprobación solo sigue al usuario registrado.** No detecta automáticamente a un jugador u otro personaje ajeno a la cola que se pare en ese lugar.

---

# 3. Configurar `GESTOR_PASO`

Asignale el script anterior y completá:

```text
Puerta:
    PUERTA_PRINCIPAL

Lugares exteriores:
    COLA_EXT_01
    COLA_EXT_02

Lugares interiores:
    COLA_INT_01
    COLA_INT_02
```

Debe existir **un solo gestor por puerta**.

Todos los NPCs que utilicen esa puerta deben referenciar el mismo gestor.

---

# 4. Adaptar `CrucePuerta`

No vamos a duplicar todo el script. Aplicá estos cambios al archivo anterior.

## A. Añadir referencia y seguimiento

Añadí:

```gdscript
@export var gestor: GestorPasoPuerta

var _solicitud_registrada: bool = false
```

Eliminá:

```gdscript
var _tiene_reserva: bool = false
```

La reserva física de la puerta ahora pertenece al gestor.

---

## B. Validar el gestor

En `_preparar_referencias()`, después de validar `puerta`, agregá:

```gdscript
if (
	not is_instance_valid(gestor)
	or gestor.puerta != puerta
):
	push_warning(
		"CrucePuerta: asigná el gestor correspondiente a esta puerta."
	)
	return false
```

---

## C. Solicitar un lugar antes de caminar

En `solicitar_cruce()`, reemplazá la asignación anterior de `_origen` por:

```gdscript
var solicitud := gestor.solicitar(_actor, entrar)

if solicitud.is_empty():
	push_warning(
		"No hay un lugar de espera disponible o ya existe una solicitud."
	)
	return false

_solicitud_registrada = true
_origen = solicitud["posicion"]
```

Conservá la asignación de `_salida`:

```gdscript
_salida = (
	espera_interior.global_position
	if entrar
	else espera_exterior.global_position
)
```

Reemplazá la comprobación del primer tramo por:

```gdscript
if not _establecer_ruta(_origen):
	gestor.cancelar(_actor)
	_solicitud_registrada = false
	return false
```

Y eliminá la línea:

```gdscript
_tiene_reserva = false
```

---

## D. Avisar al llegar al lugar de espera

En `_physics_process()`, dentro de `Estado.YENDO_A_ESPERA`, dejá el bloque así:

```gdscript
Estado.YENDO_A_ESPERA:
	if _llego():
		_actor.velocity = Vector3.ZERO
		gestor.marcar_listo(_actor)
		estado = Estado.ESPERANDO_APERTURA
	else:
		_caminar(delta)
```

También añadí el gestor a la comprobación de referencias:

```gdscript
or not is_instance_valid(gestor)
```

---

## E. Reemplazar `_esperar_apertura()`

Usá esta versión:

```gdscript
func _esperar_apertura() -> void:
	if not gestor.tiene_turno(_actor):
		return

	if puerta.estado == PuertaCasa.Estado.ABIERTA:
		if not _establecer_ruta(_salida):
			_cancelar("No existe una ruta al otro lado de la puerta.")
			return

		estado = Estado.CRUZANDO
		return

	if puerta.esta_moviendose():
		return

	puerta.solicitar_apertura(true, _actor)
```

Ahora el NPC solo solicita apertura cuando el gestor le concede el turno.

---

## F. Avisar al terminar el cruce

En `_terminar_cruce()`, eliminá el bloque que intentaba cerrar la puerta:

```gdscript
if (
	intentar_cerrar_al_terminar
	and not puerta.hay_actor_en_barrido()
):
	puerta.solicitar_apertura(false, _actor)
```

En su lugar:

```gdscript
gestor.terminar(_actor)
_solicitud_registrada = false
```

**Conservá el resto de la función**, incluida la solicitud posterior de silla.

Podés eliminar también el export:

```gdscript
@export var intentar_cerrar_al_terminar: bool = false
```

En esta etapa la puerta permanece abierta entre usuarios. Eso evita giros innecesarios y simplifica la circulación.

---

## G. Reemplazar la liberación directa de la puerta

Dentro de `_liberar_control()`, eliminá:

```gdscript
if (
	_tiene_reserva
	and is_instance_valid(puerta)
	and is_instance_valid(_actor)
):
	puerta.liberar_paso(_actor)

_tiene_reserva = false
```

Reemplazalo por:

```gdscript
if (
	_solicitud_registrada
	and is_instance_valid(gestor)
	and is_instance_valid(_actor)
):
	gestor.cancelar(_actor)

_solicitud_registrada = false
```

El resto se conserva: restaurar controlador, desbloquear `AccionMueble` y limpiar el destino.

---

# 5. Qué sucede al cancelar dentro del vano

Este caso requiere precaución.

Si un NPC cancela mientras cruza:

1. Recupera su controlador habitual.
2. El gestor marca el paso como pendiente de despeje.
3. **No concede otro turno hasta que el barrido quede libre.**
4. No cierra la puerta.

Esto evita enviar inmediatamente otro NPC contra el personaje detenido.

Pero no obliga al primero a apartarse. Si queda inmóvil dentro del vano, la cola puede permanecer detenida.

**Es un bloqueo conservador, no una recuperación automática.** Para desbloquearlo hay que mover al actor, reanudar su comportamiento o darle un destino seguro.

---

# 6. Qué pasa cuando se llenan los lugares

Si hay dos lugares exteriores y ya están asignados:

```gdscript
cruce.solicitar_cruce(true)
```

devuelve `false` para un tercer NPC.

No lo añadimos a una cola invisible sobre el mismo punto.

Su lógica de rutina deberá:

- Esperar en otra zona.
- Reintentar después.
- Elegir otra actividad.

**No reintentes cada frame.** Para una prueba, usá un intervalo de dos o tres segundos; en producción conviene un planificador de rutinas.

---

# 7. Ajustar los tiempos de espera

El `tiempo_maximo` de `CrucePuerta` sigue contando:

```text
Caminar hasta la cola
+ esperar turno
+ abrir
+ cruzar
```

Para pruebas con cuatro personajes podés aumentarlo, por ejemplo:

```text
Tiempo máximo = 90 s
```

No significa que una espera de 90 segundos sea deseable. Sirve para distinguir:

- Un recorrido que funciona pero necesita esperar.
- Un bloqueo real que nunca se despeja.

Como la cola es FIFO estricta, **si el primero no llega a su marcador, los siguientes esperan hasta que cancele o venza su tiempo**.

---

# 8. Prueba con dos NPCs

Empezá sin sillas: primero validamos exclusivamente la puerta.

Configurá:

```text
NPC_A/CrucePuerta:
    Gestor = CASA_BASE/GESTOR_PASO

NPC_B/CrucePuerta:
    Gestor = CASA_BASE/GESTOR_PASO
```

Después de que la navegación esté preparada:

```gdscript
npc_a_cruce.solicitar_cruce(true)
npc_b_cruce.solicitar_cruce(true)
```

Resultado esperado:

1. Cada NPC recibe un lugar distinto.
2. El primero conserva prioridad.
3. Solo el primero abre y cruza.
4. El segundo permanece en su marcador.
5. Cuando el barrido queda libre, el segundo recibe turno.
6. Como la puerta sigue abierta, cruza sin volver a mover la hoja.

### Revisión importante

El segundo NPC no debe bloquear el camino del primero hacia el vano.

Si lo hace, mové su marcador. **Una cola lógica no corrige una mala distribución física.**

---

# 9. Prueba en sentidos opuestos

Colocá:

- `NPC_A` fuera.
- `NPC_B` dentro.

Solicitá:

```gdscript
npc_a_cruce.solicitar_cruce(true)
npc_b_cruce.solicitar_cruce(false)
```

El primero en solicitar conserva prioridad.

Comprobá que:

- El NPC interior espere a un lado.
- El que entra pueda llegar al destino interior sin chocarlo.
- El NPC que sale no empiece hasta que termine el despeje.

Si ambos destinos de salida caen sobre los lugares de cola, hay que reorganizar los marcadores.

---

# 10. Volver a conectar las sillas

Una vez que el cruce funcione:

```gdscript
npc_a_cruce.solicitar_cruce(true, silla_a)
npc_b_cruce.solicitar_cruce(true, silla_b)
```

Cada uno:

```text
Espera turno de puerta
→ cruza
→ solicita su silla
→ camina a la aproximación
→ se sienta
```

Si ambos reciben la misma silla:

- El primero que solicite la acción de silla puede reservarla.
- El otro terminará de cruzar, pero su acción de silla será rechazada.

**El orden en la puerta no reserva los muebles.** Seguimos evitando mantener una silla ocupada lógicamente mientras su futuro usuario espera mucho tiempo fuera.

---

# 11. Limitaciones que todavía importan

### Personajes ajenos al gestor

Un jugador puede bloquear el barrido o el pasillo. El gestor esperará, pero no le asignará prioridad ni lo apartará.

### Más de una ruta hacia el marcador

El agente calcula una ruta sobre el NavMesh. Si hay otra puerta o un recorrido alternativo, podría elegirlo. Este sistema no impone geométricamente que atraviese un vano concreto.

### Movimiento de espera

Los NPCs conservan su colisión, pero no añadimos avoidance. Sus recorridos hacia los marcadores pueden cruzarse.

### Descarga de la casa

No descargues la casa con solicitudes activas. Primero cancelá los componentes de cruce y sacá a los actores de la zona.

### Cierre automático

Queda desactivado deliberadamente. Lo añadiremos como acción del gestor cuando:

- No haya turno activo.
- No haya solicitudes pendientes.
- El barrido permanezca libre.
- Haya pasado un tiempo de inactividad.

---

## Resultado de esta etapa

La puerta ya tiene un punto de coordinación compartido:

```text
Solicitud
→ lugar de espera exclusivo
→ orden FIFO
→ turno único
→ apertura
→ cruce
→ despeje
→ siguiente turno
```

**El próximo paso útil es cerrar el ciclo de rutinas:** elegir un mueble disponible, ir a la casa, esperar la puerta, usarlo durante un tiempo y salir, con reintentos limitados cuando algo esté ocupado. Así los NPCs dejan de depender de scripts de prueba aislados.