**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Modulo 34: Pesca

## 1. Arquitectura (por capas)

```
Vista (UI)              FishingMinigameUI.gd  /  FishingHud.gd   (puro: solo escucha senales)
                            |
Servicio (autoload)     FishingManager.gd  (orquesta sesiones, tablas, PRNG M29)
                            |
Gameplay                FishingSession.gd (maquina de estados del minijuego)
                        FishingRod.gd (Resource: stats de la cana)
                        FishingSpot.gd (Node3D: agua voxel valida M51, autorregistrado)
                            |
Datos (Resources)       FishDefinition.gd (.tres)   CeboDefinition.gd (.tres)
                        FishCollectionData.gd (progreso coleccion)
                            |
Integracion             M51 Agua (voxels)  M29/M31/M32 (tiempo/clima)  M14 (inventario)  M37 (museo)
```

Reglas de capas (AGENTS seccion 9): la UI nunca toca voxels ni M14; el manager expone API publica; los Resources son datos puros.

## 2. Clases y Responsabilidades

### 2.1 FishingManager (autoload `Fishing`)
- Registro de spots vivos (`FishingSpot` por chunk M51).
- Resolucion de especie: filtra `FishDefinition` por bioma, estacion M29, franja M31, clima M32 y cebo; elige por PRNG ponderado M29.
- Crea/destruye `FishingSession` y emite senales de estado hacia la UI.
- Persiste `FishCollectionData` (coleccion, estadisticas, mejor tamano).

### 2.2 FishingSpot (Node3D, por chunk de agua M51)
- Se registra/desregistra con el chunk (streaming M51).
- Valida si sigue siendo "agua pescable" bajo demanda (no cada frame): voxel AGUA + AIRE encima + orilla accesible a pie.
- Marca visual opcional (ondulaciones/burbujas) y punto de impacto del anzuelo.

### 2.3 FishingRod (Resource) — datos de la cana equipada
- Rango de lanzamiento (m), ventana de exito (s), multiplicador de espera (x), multiplicador de rareza (x).
- Variantes: cana vieja, cana de madera ancestral, cana de deidad.

### 2.4 FishDefinition (Resource `.tres`)
- id, nombre (localizable), bioma(s), estaciones (M29), franjas (M31), climas (M32), peso PRNG (rareza), tamano min/max (m), valor venta (M37), recetas que consume (M15), pieza museo (M37), señuelos preferidos.

### 2.5 FishingSession — maquina de estados del minijuego
Estados: `IDLE -> LANZANDO -> ESPERA_PICADA -> PICADA -> MINIJUEGO -> CAPTURA | ESCAPE -> IDLE`
- Timers pausables con GameClock (M29); PRNG propio derivado del M29 para determinismo.
- 2 fases indulgentes: fase A (reaccion: pulsar al hundirse el flotador; ventana segun cana) y fase B (mantener 3 pulsaciones con ventana amplia).

### 2.6 FishCollectionData (Resource de partida)
- Por especie: capturado (bool), veces, mejor tamano; totales de capturas; piezas entregadas a M37.

### 2.7 UI (FishingMinigameUI, FishingHud)
- Indicador de espera (flotador, sonido de picada), boton de captura, feedback de exito/escape, zoom de captura, entrada al registro. Solo escucha senales; sin logica de gameplay.

## 3. Flujos en Texto

### Flujo 1 — Captura completa
1. Jugador equipa cana (M14/barra) y pulsa "pescar" mirando al agua.
2. FishingManager busca el spot mas cercano en el rayo del jugador (rango de la cana) y valida voxels M51.
3. Se lanza el flotador (RigidBody3D parabolico); estado LANZANDO.
4. Flotador toca el voxel agua y queda flotando; estado ESPERA_PICADA con timer de espera (cana x cebo, 2-8 s).
5. Al activarse la picada: sonido + flotador se hunde; estado PICADA; la UI muestra ventana de reaccion (fase A).
6. Si el jugador pulsa dentro de la ventana, entra MINIJUEGO (fase B: 3 pulsaciones con ventana por cana).
7. Exito: estado CAPTURA; FishingManager resuelve especie (tablas + PRNG M29), tamano (rango min/max x PRNG) y envia item pez a M14.
8. Se notifica a FishCollectionData (registro/estadisticas) y, si aplica, se marca pieza disponible para M37.
9. UI muestra resultado cozy; el jugador puede relanzar con 1 clic.

### Flujo 2 — Huida indulgente (sin frustracion)
1. En fase A: no se pulso a tiempo. En fase B: se fallo una pulsacion.
2. Estado ESCAPE: el pez huye; el flotador vuelve; la UI muestra "el pez se fue".
3. Sin perdidas: no se consume cebo (solo se consume al capturar), ni dinero ni items; relanzado inmediato con 1 clic.

### Flujo 3 — Validacion de spot (M51)
1. Al intentar lanzar, FishingManager consulta el voxel en el punto de impacto: tipo AGUA y voxel superior AIRE.
2. Busca orilla accesible (BFS limitado sobre chunks segun navmesh de orilla/arena).
3. Si falla cualquiera: no se lanza, UI sutil "aqui no se puede pescar" (sin bloqueo molesto).

### Flujo 4 — Resolucion de especie
1. Candidatas = FishDefinition que coinciden con bioma del spot + estacion M29 + franja M31 + clima M32 actuales.
2. Ajuste: cebo equipado aplica multiplicadores (probabilidad + espera).
3. Seleccion por PRNG ponderado (peso rareza x bono clima x bono cebo); tamano por PRNG uniforme en [min, max].

### Flujo 5 — Carga/descarga de chunks (streaming M51)
1. Al cargar chunk con agua: FishingSpot se crea y registra en FishingManager.
2. Si hay sesion activa en un spot descargado: se cancela como ESCAPE (sin castigo, el pez "no tuvo ganas").
3. Al descargar: el spot deja de recibir lanzamientos; se limpia de registros (pooling).

## 4. Contratos API (GDScript, Godot 4.x)

```gdscript
# FishingManager.gd (autoload Fishing)
class_name FishingManager
extends Node

signal picada_iniciada(sesion: FishingSession)
signal captura_exitosa(pez: FishDefinition, tamano: float)
signal captura_fallida(motivo: String)
signal sesion_terminada(sesion: FishingSession)

func registrar_spot(spot: FishingSpot) -> void
func desregistrar_spot(spot: FishingSpot) -> void
func spot_apunta_desde(origen: Vector3, direccion: Vector3, rango: float) -> FishingSpot
func iniciar_sesion(spot: FishingSpot, cana: FishingRod) -> FishingSession
func resolver_especie(spot: FishingSpot, cebo: CeboDefinition) -> FishDefinition
func registrar_captura(pez: FishDefinition, tamano: float) -> void
func entrega_museo(pez: FishDefinition) -> bool   # consumido por M37
func get_collection_data() -> FishCollectionData

# FishingSpot.gd
class_name FishingSpot
extends Node3D

signal spot_invalido(spot: FishingSpot)

func es_agua_pescable() -> bool                    # valida voxels M51 bajo demanda
func get_bioma() -> int
func get_punto_impacto() -> Vector3
func activar_marcador_visual() -> void
func desactivar_marcador_visual() -> void

# FishingSession.gd
class_name FishingSession
extends Node

signal estado_cambiado(estado: int)
signal ventana_activa(inicio_ventana: float, duracion: float)

func iniciar_espera() -> void
func notificar_pulsacion_boton() -> void           # llamada por la UI (indirecta)
func cancelar(motivo: String) -> void
func get_estado() -> int                            # ver constante de estado

# FishDefinition.gd (Resource) — datos puros
class_name FishDefinition
extends Resource

@export var id: String
@export var nombre_es: String
@export var biomas: Array[int]                     # IDs de bioma M51
@export var estaciones: Array[int]                 # IDs de estacion M29
@export var franjas: Array[int]                    # franjas M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA)
@export var climas: Array[int]                     # IDs de clima M32 (vacio = todos)
@export var peso_rareza: float                     # peso PRNG (raro 1.0 .. comun 60.0)
@export var tamano_min: float
@export var tamano_max: float
@export var valor_venta: int
@export var cebos_preferidos: Array[String]        # multiplicador si el cebo coincide
@export var pieza_museo: String                    # id de pieza opcional para M37 ("" = ninguna)
@export var id_receta: String                      # receta M15 que consume este pez ("" = ninguna)

# CeboDefinition.gd (Resource)
class_name CeboDefinition
extends Resource

@export var id: String
@export var multiplicador_probabilidad: float
@export var multiplicador_espera: float            # < 1.0 reduce la espera
@export var consumo_por_captura: int = 1           # solo se consume al capturar

# FishingRod.gd (Resource)
class_name FishingRod
extends Resource

@export var id: String
@export var rango_lanzamiento: float = 8.0
@export var ventana_exito: float = 0.5             # s (fase A y B)
@export var multiplicador_espera: float = 1.0
@export var multiplicador_rareza: float = 1.0
```

## 5. Integracion con Otros Modulos

| Modulo | Integracion |
|---|---|
| M51 (Agua) | Spots = voxels de agua validados (tipo AGUA + aire encima + orilla); registro por chunk/streaming; biomas de agua (mar, rio, laguna, pozo ancestral) |
| M29 (Tiempo y Calendario) | Estaciones y PRNG de partida para determinismo; pausa de timers con GameClock; eventos (festival con bono de capturas) |
| M31 (Ciclo Dia/Noche) | Franjas ALBA/DIA/ATARDECER/NOCHE/PROFUNDA como filtro de tablas; peces nocturnos |
| M32 (Clima) | 9 climas: bono de probabilidad (p.ej. lluvia favorable); nunca bloquea especies; transiciones suaves |
| M37 (Museos y Colecciones) | Piezas opcionales por pez; entrega de pez unico (duplicados no aceptados, pero vendibles sin frustracion); catalogo alimentado por FishCollectionData |
| M14 (Inventario) | Pez como item (stack, calidad); consumo para recetas M15; equipar cana y cebos |
| M15 (Crafting) | Recetas de coccion consumen peces del inventario (complemento: no obligatorio) |

## 6. Reglas Anti-Frustracion (Cozy, verificables)

1. Espera de picada en [2, 8] s segun cana y cebo.
2. Ventana de exito minima 0.35 s (cana vieja) y 0.70 s (cana de deidad).
3. Fallo = huida: sin perdida de items, dinero ni cebo (el cebo se consume solo al capturar).
4. Relanzado con 1 clic, sin cooldown de penalizacion.
5. Ninguna especie exige cebo especifico obligatorio (el cebo solo multiplica).
6. Ninguna especie es fuente exclusiva de progreso obligatorio (coleccion opcional M37).
7. Modo accesibilidad "captura automatica" salta las 2 fases (M57).
8. Pausa (GameClock M29) congela timers del minijuego; nunca se pierde por pausa.
9. Sin FOMO: las especies estacionales vuelven cada ano del calendario (M29, anos repetibles).