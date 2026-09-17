Seguimos con **perfiles de rutina configurables**.

El objetivo es separar la **lógica de movimiento** (que ya funciona en `RutinaCasa`) de la **intención del personaje** (qué hace, cuánto tarda, qué prefiere).

En lugar de hardcodear tiempos y comportamientos en el script, usaremos recursos de datos (`Resource`) que se asignan en el Inspector. Esto permite crear variantes como "Vecino Desayunador", "Lector Nocturno" o "Visitante Rápido" sin tocar código.

> Esta entrega añade gestión de estados basada en datos, selección ponderada de muebles y ciclos de vida repetibles. No he ejecutado el código en Godot; requiere las pruebas finales indicadas.

---

# 1. El recurso `PerfilVisita`

Creamos un tipo de dato nuevo para definir el comportamiento.

Guardá:

```text
res://casas/datos/perfil_visita.gd
```

```gdscript
class_name PerfilVisita
extends Resource

@export_group("Identificación")
@export var nombre: String = "Nuevo Perfil"
@export_multiline var descripcion: String = ""

@export_group("Tiempos")
# Tiempo base sentado + variación aleatoria.
@export var tiempo_sentado_base: float = 5.0
@export var tiempo_sentado_variacion: float = 3.0

# Pausa fuera de la casa entre visitas repetidas.
@export var pausa_exterior_base: float = 10.0
@export var pausa_exterior_variacion: float = 5.0

@export_group("Preferencias de Mueble")
# Tipos de mueble que le interesan (ej: SILLA, CAMA, SOFA).
# Si está vacío, acepta cualquier mueble interactuable definido en el JSON.
@export var tipos_preferidos: Array[StringName] = []

# Peso relativo para elegir entre varios disponibles.
# Ej: [SILLA: 2.0, SOFA: 1.0] -> elige silla el doble de veces si hay espacio.
@export var pesos_por_tipo: Dictionary = {}

@export_group("Comportamiento")
# Si es falso, al fallar la salida del asiento se detiene la rutina permanentemente.
@export var reintentar_salida_asiento: bool = true
@export var intentos_maximos_salida: int = 3

# Si es verdadero, al no encontrar mueble libre sale inmediatamente.
# Si es falso, espera un rato antes de salir.
@export var salir_si_no_hay_mueble: bool = true
@export var tiempo_espera_mueble_ocupado: float = 5.0

@export_group("Avanzado")
# Probabilidad de decidir no entrar si la cola es muy larga (0 a 1).
@export var probabilidad_rechazo_cola_larga: float = 0.0
@export var umbral_cola_larga: int = 2

func obtener_tiempo_sentado(rng: RandomNumberGenerator) -> float:
	return tiempo_sentado_base + rng.randf() * tiempo_sentado_variacion

func obtener_pausa_exterior(rng: RandomNumberGenerator) -> float:
	return pausa_exterior_base + rng.randf() * pausa_exterior_variacion

func calcular_puntuacion(tipo_mueble: StringName) -> float:
	if tipos_preferidos.size() > 0 and not tipos_preferidos.has(tipo_mueble):
		return 0.0

	if pesos_por_tipo.has(tipo_mueble):
		return float(pesos_por_tipo[tipo_mueble])

	# Si no hay peso específico pero está en la lista preferida (o la lista está vacía):
	return 1.0
```

### Cómo usarlo en el Editor

1. En el panel de FileSystem, click derecho → **New Resource** → `PerfilVisita`.
2. Guárdalo como `perfil_vecino_desayuno.tres`.
3. Configura:
   - `Tiempo sentado base`: 15.0
   - `Tipos preferidos`: `["SILLA"]`
   - `Pesos`: `{"SILLA": 2.0, "SOFA": 0.5}`

Ahora puedes crear múltiples archivos `.tres` para diferentes personalidades.

---

# 2. Actualizar `RutinaCasa` para usar el perfil

Modificamos `rutina_casa.gd` para leer estos datos en lugar de usar variables fijas.

### A. Añadir exportaciones

Al principio de la clase, reemplaza las variables de tiempo por:

```gdscript
@export_category("Perfil")
@export var perfil: PerfilVisita

# RNG interno para este NPC, seedeado opcionalmente para reproducibilidad.
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
```

En `_ready()`, inicializa el RNG:

```gdscript
func _ready() -> void:
    # ... validaciones anteriores ...
    
    if perfil == null:
        push_warning("%s: Sin perfil asignado. Usando valores por defecto." % name)
        perfil = PerfilVisita.new() # O crea uno por defecto si prefieres
    
    _rng.seed = hash(name) + randi() # Seed único por instancia
    
    # ... conexiones de señales ...
```

### B. Reemplazar constantes por llamadas al perfil

Busca donde se usan `segundos_sentado`, `pausa_entre_visitas`, etc., y cámbialos:

**En `_al_sentarse()`:**

```gdscript
func _al_sentarse() -> void:
	if estado != Estado.YENDO_A_SILLA:
		return

	estado = Estado.SENTADO
	_espera = perfil.obtener_tiempo_sentado(_rng)
```

**En `_al_cruzar()` (caso SALIENDO):**

```gdscript
Estado.SALIENDO:
    _silla_elegida = null

    if repetir_visita:
        estado = Estado.PAUSA
        _espera = perfil.obtener_pausa_exterior(_rng)
    else:
        estado = Estado.TERMINADA
        _devolver_controlador()

    visita_terminada.emit()
```

**En `_buscar_y_solicitar_silla()`:**

Aquí implementamos la lógica de preferencia y pesos.

Reemplaza el bucle de búsqueda por este algoritmo de ruleta ponderada:

```gdscript
func _buscar_y_solicitar_silla() -> void:
	if _intentos >= maxi(1, intentos_maximos):
		print("RutinaCasa: no se consiguió silla; se solicita salida.")
		_preparar_etapa(Estado.SALIENDO)
		return

	_intentos += 1
	_espera = maxf(0.2, perfil.tiempo_espera_mueble_ocupado)

	var candidatas: Array[SillaCasa] = []
	var puntuaciones: Array[float] = []
	var suma_puntos: float = 0.0

	for valor in interior.puntos.values():
		var silla := valor as SillaCasa

		if not is_instance_valid(silla):
			continue

		if (
			not silla.posicion_uso_definida
			or not silla.pose_definida
			or not silla.salida_definida
			or not silla.esta_disponible_para(_actor)
		):
			continue

		# Filtrar por exclusión temporal de fallos
		if _sillas_fallidas.has(silla.get_instance_id()):
			continue

		var puntos := perfil.calcular_puntuacion(silla.tipo)
		
		if puntos <= 0.0:
			continue

		candidatas.append(silla)
		puntuaciones.append(puntos)
		suma_puntos += puntos

	if candidatas.is_empty():
		if perfil.salir_si_no_hay_mueble:
			_preparar_etapa(Estado.SALIENDO)
		return

	# Selección ponderada
	var tiro := _rng.randf() * suma_puntos
	var acumulado: float = 0.0
	var elegida: SillaCasa = candidatas[0] # Fallback

	for i in range(candidatas.size()):
		acumulado += puntuaciones[i]
		if tiro <= acumulado:
			elegida = candidatas[i]
			break

	_silla_elegida = elegida
	estado = Estado.YENDO_A_SILLA

	var aceptada := elegida.intentar_usar(_actor)

	if not aceptada and estado == Estado.YENDO_A_SILLA:
		if _silla_elegida:
			_sillas_fallidas.append(_silla_elegida.get_instance_id())
		estado = Estado.BUSCANDO_SILLA
		_silla_elegida = null
```

**En `_intentar_levantarse()`:**

```gdscript
func _intentar_levantarse() -> void:
	if not perfil.reintentar_salida_asiento:
		_detener("Salida bloqueada y el perfil no permite reintentos.")
		return

	if _intentos >= perfil.intentos_maximos_salida:
		_detener(
			"La salida de la silla sigue bloqueada tras %d intentos." 
			% _intentos
		)
		return

	_intentos += 1
	_espera = maxf(0.2, intervalo_reintento)

	_asiento.pedir_levantarse()
```

---

# 3. Gestión de "Cola Larga" (Opcional)

Si queremos que un NPC decida no entrar si hay mucha gente esperando, modificamos `solicitar_cruce` en `RutinaCasa`.

Necesitamos acceder al gestor para ver el tamaño de la cola.

En `RutinaCasa`, añade una referencia al gestor (ya la tiene `cruce`, pero necesitamos acceso directo o pasarla):

```gdscript
@export var gestor_paso: GestorPasoPuerta # Asignar en inspector
```

En `_intentar_cruce(entrar)`:

```gdscript
func _intentar_cruce(entrar: bool) -> void:
	if _intentos >= maxi(1, intentos_maximos):
		_detener("No se pudo iniciar el cruce.")
		return

	# Verificar rechazo por cola larga solo al entrar
	if entrar and is_instance_valid(gestor_paso):
		var tamanio_cola = gestor_paso._cola.size() # Nota: _cola es privado, hazlo publico o añade un getter en GestorPasoPuerta
		
		# Añade este getter en GestorPasoPuerta.gd:
		# func get_tamanio_cola() -> int: return _cola.size()
		
		if gestor_paso.get_tamanio_cola() >= perfil.umbral_cola_larga:
			if _rng.randf() < perfil.probabilidad_rechazo_cola_larga:
				print("%s decide no entrar: cola demasiado larga." % name)
				_estado = Estado.TERMINADA # O PAUSA para intentar luego
				_devolver_controlador()
				visita_terminada.emit()
				return

	_intentos += 1
	_espera = maxf(0.2, intervalo_reintento)
	cruce.solicitar_cruce(entrar)
```

*(Nota: Recuerda añadir `func get_tamanio_cola() -> int: return _cola.size()` en `GestorPasoPuerta`).*

---

# 4. Escena de Prueba Integrada

Organiza tu escena de prueba así:

```text
MUNDO_PRUEBA
├── SUELO
├── CASA_BASE
│   ├── Interior (InteriorCasa)
│   ├── Navegacion (NavegacionCasa)
│   ├── PUERTA_PRINCIPAL
│   ├── GESTOR_PASO (GestorPasoPuerta)
│   ├── ESPERA_EXTERIOR / INTERIOR
│   └── COLAS...
├── NPC_LECTOR
│   ├── CharacterBody3D
│   │   ├── ActorAsiento
│   │   ├── AgenteMuebles
│   │   ├── AccionMueble
│   │   ├── CrucePuerta (con Gestor asignado)
│   │   └── RutinaCasa
│   └── Mesh/Skeleton
└── NPC_DESAYUNADOR (igual estructura)
```

### Configuración de Recursos

1. Crea `perfil_lector.tres`:
   - Tiempo sentado: 20s + 10s var.
   - Preferidos: `["SILLA"]`.
   - Pesos: `{"SILLA": 5.0, "SOFA": 1.0}`.

2. Crea `perfil_desayunador.tres`:
   - Tiempo sentado: 8s + 2s var.
   - Preferidos: `["SILLA", "MESA"]` (si defines mesas interactivas).
   - Salir si no hay mueble: `true`.

3. Asigna estos recursos a `RutinaCasa.perfil` de cada NPC.

4. En `RutinaCasa`:
   - `Iniciar automáticamente`: true.
   - `Repetir visita`: true.
   - `Gestor Paso`: Referencia al nodo `GESTOR_PASO`.

---

# 5. Depuración Visual

Para saber qué está pensando cada NPC, añade un Label 3D o imprime en consola con colores.

En `RutinaCasa`, dentro de `_physics_process`, puedes actualizar un texto flotante:

```gdscript
@export var label_debug: Label3D

func _process(delta):
    if label_debug:
        var texto_estado = Estado.keys()[estado]
        var info_extra = ""
        
        if estado == Estado.SENTADO:
            info_extra = " (%.1fs)" % _espera
        elif estado == Estado.BUSCANDO_SILLA:
            info_extra = " Intento %d/%d" % [_intentos, intentos_maximos]
            
        label_debug.text = "%s\n%s%s" % [perfil.nombre, texto_estado, info_extra]
```

---

# 6. Flujo Completo Resultante

Con esto, el sistema evoluciona de "mover piezas" a "simular habitantes":

1. **Inicio**: El NPC despierta con su perfil cargado.
2. **Decisión**: Quiere visitar la casa.
3. **Aproximación**: Llega a la puerta.
4. **Evaluación**: Ve 2 personas en la cola. Su perfil dice "probabilidad rechazo 0.8". Tira dados y decide irse o esperar.
5. **Entrada**: Consigue turno, cruza.
6. **Selección**: Dentro hay una Silla y un Sofá.
   - El Lector calcula: Silla (5 pts), Sofá (1 pt). Elige Silla con 83% probabilidad.
   - El Desayunador calcula: Silla (1 pt), Sofá (1 pt). Elige al azar.
7. **Uso**: Se sienta el tiempo definido en su perfil (con variación aleatoria).
8. **Salida**: Se levanta. Si hay alguien bloqueando, reintenta según su paciencia configurada.
9. **Ciclo**: Sale, espera fuera el tiempo de su perfil, y repite.

---

# 7. Siguientes Pasos Sugeridos

Ahora que tienes NPCs con personalidades y rutinas completas:

1. **Inventario e Interacción Real**: Que "Usar Mesa" abra un menú de crafteo o "Usar Cama" avance el reloj del juego.
2. **Horarios**: Un sistema global de "Hora del Día" que active/desactive perfiles (ej: de noche nadie va a la casa, o van a dormir).
3. **Diálogo**: Que al cruzarse en la puerta o estar sentados cerca, intercambien frases basadas en sus perfiles.
4. **Necesidades**: Que el perfil cambie dinámicamente (ej: si tiene "Hambre" alta, busca la Cocina en vez de la Silla).

Esta arquitectura de **Componentes + Perfiles de Datos** te permite escalar a docenas de NPCs distintos sin escribir nuevos scripts para cada uno. Solo creas nuevos archivos `.tres`.