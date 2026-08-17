**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 19: NPC y Vecinos

## 1. Arquitectura

### 1.1 Capas

```
┌─────────────────────────────────────────────────────────────┐
│ CAPA UI (M21 Diálogos + UI propia del módulo de interfaz)   │
│  - Caja de diálogo, indicador de interacción, notificaciones │
└───────────────────────────────┬─────────────────────────────┘
                                │ señales
┌───────────────────────────────▼─────────────────────────────┐
│ CAPA DE ORQUESTACIÓN (este módulo, M19)                     │
│  VillagerManager (autoload)  ── autoridad de la población   │
│   ├── Villager (escena por vecino activo)                   │
│   ├── VillagerMood (componente por vecino)                  │
│   └── VillagerDialogueHook (componente por vecino)          │
└───────────────┬──────────────────────────────┬──────────────┘
                │ datos (.tres)                 │ eventos
┌───────────────▼──────────────┐   ┌────────────▼─────────────────┐
│ CAPA DE DATOS                │   │ CAPA DE CONSUMIDORES          │
│  VillagerProfile (.tres)     │   │  M64 IA (perfil+agenda)       │
│  VillagerCatalog (registro)  │   │  M20 Amistad (eventos)        │
│  VillagerSaveData            │   │  M25 Ruinas (temas)           │
└───────────────┬──────────────┘   └────────────┬─────────────────┘
                │                                │
        res://data/villagers/           res://src/dialogs/ (M21)
```

### 1.2 Clases GDScript

| Clase | Tipo | Rol |
|---|---|---|
| `VillagerProfile` | `Resource` (.tres) | Hoja de datos: identidad, gustos, rutina, personalidad, hogar |
| `VillagerCatalog` | `Resource` / singleton de datos | Registro de todos los candidatos (mayor al límite activo) |
| `VillagerManager` | `Node` (autoload) | Autoridad de población: activos, plazas, mudanzas, persistencia |
| `Villager` | `Node3D` (con `CharacterBody3D` opcional) | Instancia runtime de un vecino activo: estado, señales, audio, animación |
| `VillagerMood` | `Node` (componente) | Estado emocional: ánimo base persistido + deltas calculados |
| `VillagerDialogueHook` | `Node` (componente) | Contrato hacia M21: líneas actuales, respuestas, eventos de conversación |
| `VillagerMudanza` | Clase de estado (o datos en manager) | Máquina de fases de mudanza (propuesta, aviso, confirmación, mudanza, llegada) |

## 2. Diagramas de Flujo (texto)

### 2.1 Ciclo de vida de un vecino

```
Candidato (catálogo)
   │  plaza libre en isla (10 max)
   ▼
Propuesta de mudanza (el candidato aparece en puerto/plaza "visitante")
   │  jugador pulsa F y elige "Invitar a la isla"
   ▼  ┌── No ──► Visitante se marcha (reaparece el próximo ciclo)
Permiso concedido ──► Confirmación de parcela libre → Parcela asignada
   ▼
Llegada (dia siguiente, 08:00): se construye su casa base y se activa
   ▼
Vida cotidiana (rutinas M64 + interacción M19)
   │  (deseo de partir, azar poco frecuente)
   ▼
Aviso de partida (1 día antes, burbuja de diálogo visible)
   │  ┌── Jugador rechaza ──► Permanece (enfriamiento de nuevo aviso)
   ▼  jugador acepta / no responde
Partida (empaqueta maletas, dice adiós, libera parcela)
   ▼
Hogar vacío → disponible para próximo candidato
```

### 2.2 Interacción con tecla F

```
Input F (cada frame)
   ▼
VillagerManager.detectar_objetivo():
   - vecino más cercano en rango 2.5 m del jugador
   - sin pared/chunk entre jugador y vecino (raycast vóxel)
   - vecino no bloqueado por evento (dormido se excluye, o se ignora)
   ▼
Hay objetivo ──► Villager.obtener_hook().solicitar_dialogo()
                    │  M21 abre el diálogo contextual
                    ▼  (jugador en conversación → el vecino "mira" al jugador)
Fin de diálogo ──► VillagerDialogueHook.notificar_cierre() → M20 registra charla
```

### 2.3 Regalo y reacción

```
Jugador entrega objeto (desde inventario + tecla F sobre el vecino)
   ▼
VillagerManager.entregar_regalo(vecino, objeto_id)
   ▼
VillagerProfile.evaluar(objeto_id):
   - en gustos  → me gusta +1.0
   - en disgustos → no me gusta -0.5
   - neutro      → 0.0
   ▼
VillagerMood.aplicar_delta(valor, "regalo") flood de emoción (alegre/sorprendido/molesto)
   ▼
VillagerDialogueHook.linea_reaccion(objeto_id)  →  M21 muestra la línea
VillagerManager.emitir_senal("regalo_recibido", vecino, objeto_id)  →  M20 amistad
```

### 2.4 Mood (estado emocional)

```
ánimo_efectivo = ánimo_base (persistido)
               + delta_clima (M31/M32: lluvia -0.2 si sin refugio)
               + delta_estacion (M29: primavera +0.1)
               + delta_hora (noche +0.1 / tarde -0.1)
               + delta_eventos (festival M73 +0.3, ruina descubierta M25 +0.2)
clamp(-1.0 .. 1.0)
   ▼
Traduce a expresión visual (animación de cara/emojis vóxel) y tono de líneas (M21)
```

## 3. Contratos de API

### 3.1 VillagerProfile (Resource)

```gdscript
class_name VillagerProfile
extends Resource

@export var id: String                     # único, ej: "catalina_oso"
@export var nombre: String
@export var especie: String                # oso, mapache, zorro, sapo, ...
@export var silueta: String                # ref. a escena/mesh vóxel
@export var personalidad: String           # animada, seria, dulce, tímida...
@export var edad_categoria: String         # niñez, juventud, adulto, anciano
@export var profesion: String              # granjero, pescador, cocinero...
@export var historia: String               # texto use-only (fichas)
@export var gustos: Array[String]          # ids de objetos
@export var disgustos: Array[String]
@export var hobbies: Array[String]
@export var rutina_diaria: Dictionary      # { "08:00": "trabajar", ... }
@export var hogar_deseado: String          # bioma/estilo de parcela
@export var linea_saludo: String
@export var linea_despedida: String
@export var linea_sueno: String

func evaluar_objeto(objeto_id: String) -> float
func proxima_franja(hora: float) -> String
```

### 3.2 VillagerManager (autoload)

```gdscript
extends Node

signal poblacion_cambio(lista_activa: Array)          # entrada/salida de vecinos
signal regalo_recibido(vecino: Villager, objeto_id: String)
signal mudanza_propuesta(candidato: VillagerProfile)
signal mudanza_aprobada(perfil: VillagerProfile, parcela_id: String)
signal mudanza_cancelada(perfil: VillagerProfile)
signal aviso_partida(vecino: Villager, permiso_rechazable: bool)

func obtener_activos() -> Array[Villager]
func obtener_vecino(id: String) -> Villager
func plaza_libre() -> bool
func proponer_mudanza(candidato_id: String) -> void
func aprobar_mudanza(candidato_id: String) -> void
func cancelar_mudanza(candidato_id: String) -> void
func anunciar_partida(vecino_id: String) -> void
func aceptar_partida(vecino_id: String) -> void
func rechazar_partida(vecino_id: String) -> void
func entregar_regalo(vecino_id: String, objeto_id: String) -> void
func detectar_objetivo(pos_jugador: Vector3) -> Villager
func guardar() -> Dictionary                   # persistencia (Godot: save_game)
func cargar(datos: Dictionary) -> void
```

### 3.3 Villager (instancia runtime)

```gdscript
class_name Villager
extends Node3D

signal dialogar_solicitado(hook: VillagerDialogueHook)
signal disponible_cambio(esta_disponible: bool)

@export var perfil: VillagerProfile
@onready var mood: VillagerMood
@onready var hook: VillagerDialogueHook

func interactuar(jugador: Node3D) -> void      # disparada por F
func recibir_regalo(objeto_id: String) -> void
func set_ocupado(ocupado: bool) -> void        # dormir/dialogando → no interactuable
func objetivo_actual() -> String
```

### 3.4 VillagerMood

```gdscript
class_name VillagerMood
extends Node

var animo_base: float = 0.0                    # persistido
var last_causa: String = ""
signal animo_cambio(valor: float, causa: String)

func aplicar_delta(delta: float, causa: String) -> void
func factor_dialogo() -> float                 # escala tono de líneas (M21)
func factor_regalo() -> float                  # amplifica reacciones
func estado_emocional() -> String              # "alegre"/"neutral"/"triste"
```

### 3.5 VillagerDialogueHook (contrato hacia M21)

```gdscript
class_name VillagerDialogueHook
extends Node

signal linea_solicitada(vecino: Villager, clave_linea: String)
signal respuestas_disponibles(vecino: Villager, respuestas: Array[String])
signal conversacion_terminada(vecino: Villager, resumen: Dictionary)

func solicitar_dialogo() -> void
func obtener_linea(clave: String) -> String    # M21 resuelve traducción
func notificar_cierre() -> void
```

## 4. Integración con Otros Módulos

| Módulo | Relación | Contrato |
|---|---|---|
| M64 IA de NPC | Consume a M19 | `VillagerManager.obtener_activos()` → lista de agentes; `VillagerProfile.rutina_diaria` → agenda; `Villager.objetivo_actual()` para sincronía de animación |
| M21 Diálogos | Consume hooks | `VillagerDialogueHook` emite `linea_solicitada` y `respuestas_disponibles`; M21 muestra y responde; `notificar_cierre` devuelve el control |
| M20 Amistad | Consume eventos | `regalo_recibido` y `conversacion_terminada` alimentan puntos de amistad; M20 devuelve nivel que M21 usa para líneas especiales |
| M25 Ruinas | Temática y eventos | vecinos comentan hallazgos de ruinas (líneas con clave `ruina_*`); alcanzar nivel de amistad alto revela pista de ruina (via hook) |
| M29 Tiempo/Calendario | Fuente de hora | `hora_actual()` y `dia_actual()` para variaciones de rutina y deltas de mood |
| M61 Rendimiento | Límites | número de NPCs activos informado a la burbuja de M64; `VillagerManager` no ejecuta IA fuera de burbuja |
| Voxel Tools (GDExtension) | Plataforma | los hogares/parcelas se posicionan en terreno vóxel; raycast de interacción usa el voxel world |

## 5. Persistencia

`VillagerSaveData` (Dictionary):

```
{
  "activos": [ { "perfil_id": "...", "parcela_id": "...", "animo_base": 0.3,
                 "memoria": { "regalos": ["manzana"], "charlas": 12,
                 "ultimo_regalo_dia": 3, "amistad_delta": 150 } } ],
  "visitantes": ["..."],          # candidatos en visita
  "partidas_pendientes": [ ... ]  # avisos activos
}
```

Reglas: los perfiles viven en `.tres` (no se guardan); solo se persiste el estado (presencia, parcela, emocional, memoria). Al cargar, se validan IDs contra el catálogo; los huérfanos se eliminan con log.