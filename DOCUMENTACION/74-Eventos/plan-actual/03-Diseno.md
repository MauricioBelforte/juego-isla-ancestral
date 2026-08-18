**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 74: Eventos

## 1. Arquitectura general

```
┌─────────────────────────────────────────────────────────────┐
│  M29 Tiempo/Calendario          M30 Reloj        M32 Clima   │
│  GameClock · EventBus.time      (hora interna)  (condiciones)│
└───────────┬──────────────────────────────┬──────────────────┘
            │ señales: dia_cambio,         │ señales: clima_cambio
            │ estacion_cambio, año_cambio  │
            ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 EventManager (autoload)                     │
│  · Catálogo: Dictionary[evento_id → EventDefinition]        │
│  · Agenda anual: Array[EventDefinition ordenado]            │
│  · Estado: EventState por año (persistido en GameState.M74) │
│  · Evaluador de CondicionEvento                             │
│  · Token anti-duplicado                                     │
└──┬──────────────────┬──────────────────────┬────────────────┘
   │ EventBus.eventos │                      │ API pública
   ▼                  ▼                      ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐
│ M53 UI       │  │ M19 NPCs     │  │ Recompensas          │
│ banners,     │  │ rutinas de   │  │ entrega → M14/M20/   │
│ agenda,      │  │ festival     │  │ M38/M71 + registro   │
│ ventana      │  │ (por datos)  │  │ token anual          │
└──────────────┘  └──────────────┘  └──────────────────────┘
```

## 2. Componentes

### 2.1 `EventDefinition` (recurso `Resource` — datos `.tres`)

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | String | Identificador único (ej: `fiesta_primavera`) |
| `tipo` | Enum | FESTIVAL, FERIA, COMPETENCIA, RITUAL, CLIMATICO, SORPRESA |
| `nombre_clave` | StringName | Clave de localización (M57) |
| `descripcion_clave` | StringName | Texto largo localizable |
| `dia` / `mes` | int | Fecha fija del calendario Aurora (0 si es relativo) |
| `estacion` | Enum | Estación requerida (NULO = cualquiera) |
| `hora_inicio` / `hora_fin` | int | Franja horaria (minutos desde 0:00, interna M30) |
| `dias_aviso` | int | Anticipación del aviso (default 3) |
| `prioridad` | int | Solapamiento: mayor gana |
| `condiciones` | Array[CondicionEvento] | Puertas de disparo y de participación |
| `recompensas` | Array[RecompensaDef] | Declarativas (objeto, moneda, amistad, progreso) |
| `escena_recinto` | PackedScene | Escena del recinto/evento (carga bajo demanda, M63) |
| `ocupacion_npc` | Array[OcupacionNPC] | Qué NPCs están en el recinto y desde cuándo (M19) |
| `dialogos_id` | StringName | Id del set de diálogos de festival (M21) |
| `variante_cubierta` | PackedScene | Variante segura si llueve/nieva (M32) |
| `recompensa_compensatoria` | RecompensaDef | Fallback si la escena no carga |
| `flags` | Dictionary | Extensible (ambiental, música M41, etc.) |

### 2.2 `CondicionEvento` (recurso `Resource` reutilizable)

Tipo (`tipo_condicion`): HORA_EN_FRANJA · ESTACION · CLIMA_OK · AMISTAD_MIN · HISTORIA_PROGRESO · INVENTARIO_TIENE · SEMANA_DIA. Campos: `valor` (int/String), `bandera` (bool), `mensaje_fallo_clave` (localizable). Método: `evaluar(ctx: ContextoEvaluacion) -> bool` con razón de fallo para feedback amable.

### 2.3 `RecompensaDef` (recurso `Resource`)

Campos: `tipo` (OBJETO/COLECCIÓN/MONEDA/AMISTAD/PROGRESO/FERIA), `cantidad`, `id_item`, `id_npc`, `moneda` (M38 `MonedaFeria`), `clave_recuerdo` (para M37). Validación duplicada: definición + estado.

### 2.4 `EventManager` (autoload `eventos`)

**Estado público:**
- `catalogo: Dictionary[String, EventDefinition]`
- `agenda_anio: Array[EventDefinition]` (ordenada por fecha+prioridad)
- `estado_anual: Dictionary[int, Dictionary[String, EventState]]` (persistido)
- `evento_actual: EventDefinition` / `evento_actual_id: StringName`

**Señales (EventBus.eventos):**
- `evento_proximo(evento: EventDefinition, dias: int)`
- `evento_iniciado(evento: EventDefinition)`
- `evento_terminado(evento: EventDefinition)`
- `evento_cancelado(evento: EventDefinition, razon: StringName)`
- `evento_recompensa_entregada(evento: EventDefinition, recompensa: RecompensaDef)`
- `agenda_actualizada(agenda: Array)`

**Métodos de consumo (API):**
- `get_eventos_del_dia(fecha: FechaAurora) -> Array[EventDefinition]`
- `get_eventos_proximos(dias: int) -> Array[EventDefinition]`
- `get_estado_evento(evento_id: StringName, anio: int) -> EventState`
- `puede_participar(evento_id: StringName) -> Dictionary` (bool + razón)
- `iniciar_participacion(evento_id: StringName, contexto: Dictionary) -> bool`
- `entregar_recompensa(evento_id: StringName) -> Array[RecompensaDef]`
- `finalizar_evento(evento_id: StringName, resultado: Dictionary)`
- `normalizar_agenda() -> void`
- `registrar_sorpresa(evento_id: StringName) -> bool` (azart + límites)
- `get_recuerdos() -> Array[Recuerdo]` (galería M37)

### 2.5 `EventState` (clase de estado, serializable)

`estado: Enum` (PENDIENTE · EN_CURSO · PARTICIPADO · NO_PARTICIPADO · CANCELADO) · `recompensas_recibidas: PackedStringArray` · `mejor_puesto: int` · `anio_participacion: int` · `sorpresa_ya_usada: bool` · `anio` · `evento_id`.

### 2.6 Calendario de eventos (agenda anual)

- Al `año_cambio` (M29) o con `normalizar_agenda()`: se construye la agenda del año desde `catalogo` (fechas fijas) + eventos relativos (ej: "segundo sábado de Otoño") + sorpresas con slots libres.
- Chequeo diario en `dia_cambio` (coste O(n) con n ≈ 40 eventos): se marcan `evento_proximo` para los `dias_aviso` restantes, `evento_iniciado` al entrar en franja, `evento_terminado` al salir.
- La agenda se muestra en M53 (panel) y el badge del reloj M30 se enciende con `evento_proximo`/`evento_iniciado`.

### 2.7 Flujo de festival (ej: Fiesta de la Primavera)

```
día -3:  dia_cambio → evento_proximo (banner "¡En 3 días!") [UI lee señal]
día 0:   dia_cambio → evento_iniciado
         1) banner de inicio + música festiva (M41) + ambient (M42)
         2) EventBus.day.ocupacion_evento → M19 reposiciona NPCs
         3) puerta del recinto activa (interacción M70)
día 0 (franja): jugador entra → puede_participar() → iniciar_participacion()
         → minijuego/diálogos (M21) → finalizar_evento(resultado)
         → entregar_recompensa() [token anual] → señales recompensa_entregada
hora_fin: evento_terminado → NPCs vuelven a rutinas (M19) → estado PENDIENTE → próximo año
```

### 2.8 UI de festival (M53 — carpeta `res://ui/festival/`)

- `w_agenda.gd/.tscn` — panel de agenda (año completo, marcador "hoy", avisos próximos).
- `w_banner_evento.gd/.tscn` — banner no-modal de aviso/inicio/fin (animación de entrada, botón "ver agenda").
- `w_ventana_festival.gd/.tscn` — ventana del evento: nombre, descripción, condiciones pendientes, recompensas, estado de este año ("Ya recibiste la recompensa").
- `w_reloj_badge` — dot del reloj M30 (módulo 30 ya escucha `evento_proximo`).
- Regla M09: la UI **nunca** decide gameplay; solo llama API de `EventManager` y pinta señales.

### 2.9 Persistencia (M60)

`GameState.M74 = { version: int, anios: { str(anio): { evento_id: EventState_serializado } }, recuerdos: Array[Recuerdo] }`. Carga: se reconstruye `agenda_anio` de datos + estado, se resuelven solapamientos y eventos en curso (si la franja sigue abierta, el recinto queda accesible sin re-mostrar banners).

## 3. Flujos principales

### 3.1 Programación (RF2)
`dia_cambio` → `EventManager._on_dia_cambio()` → verifica eventos del día → publica `agenda_actualizada` → UI agenda.

### 3.2 Disparo (RF3/RF4)
`_on_dia_cambio()` evalua `dias_aviso` → `evento_proximo`; al llegar el día y la hora → `evento_iniciado`. Canciones/ambient ingresan por señal (M41/M42) sin acoplar.

### 3.3 Participación (RF5)
`puede_participar()` evalúa `CondicionEvento[]`+`EventState`; si ok → `iniciar_participacion()` fija `EN_CURSO`; el minijuego (identificado por `tipo`) es lanzado por el recinto. Dato: el motor de eventos no implementa minijuegos, define contrato (señal `partida_pedida`/`partida_finalizada`).

### 3.4 Recompensas (RF6)
`entregar_recompensa()` → valida token del año → entrega vía M14 (inventario con fallback a buzón), M20 (amistad), M38 (moneda feria), M71 (progreso) → registra en `EventState` → señal.

### 3.5 Repetibilidad (RF7)
Al fin de año: `normalizar_agenda()` regenera la agenda; los `EventState` del año anterior quedan en `anios[anio-1]`; el próximo año los eventos vuelven a estar `PENDIENTE` (token anual se resetea por año natural, no por jugador).

### 3.6 Clima (RF8)
`EventManager._on_clima_cambio(clima)` consulta M32: si el evento activo es de exterior y el clima es severo → si hay `variante_cubierta` se intercambia el recinto; si no hay variante, el evento se **traslada un día** (sin perderse) o usa `recompensa_compensatoria` solo si la variante falla.

### 3.7 Sorpresas (RF9)
`registrar_sorpresa()` → probabilidad diaria (data), límite semanal (3), colisión-check contra festivales → si ok, evento espontáneo con franja corta (ej: 20:00–23:00) y `sorpresa_ya_usada` por semana.

## 4. Diagramas

### 4.1 Diagrama de secuencia — disparo y participación

```
Jugador          EventManager          M29/EventBus      UI (M53)
   │                   │                     │                │
   │                   │◄──── dia_cambio ─────│                │
   │                   │── evento_proximo ───────────────────►│ banner
   │                   │── evento_iniciado ──────────────────►│ banner+hud
   │── interacción ───►│                     │                │
   │                   │── puede_participar()│                │
   │◄── bool+razón ────│                     │                │
   │── iniciar_participacion ▸───────► │                      │
   │                   │── minijuego (contrato M21/M34...)    │
   │── finalizar ─────►│── entregar_recompensa()              │
   │                   │── token ok → M14/M38/M20/M71 ───────►│
   │◄── recibe premio ─│── evento_recompensa_entregada ──────►│ toast
```

### 4.2 Diagrama de estados de un evento anual

```
        ┌─────────┐  dia_cambio (días_aviso)   ┌──────────┐
        │PENDIENTE│───────────────────────────►│AVISADO   │
        └────┬────┘                            └────┬─────┘
   año nuevo │                                      │ llega la fecha+franja
             ▼                                      ▼
        ┌─────────┐  participa    ┌──────────┐  fin franja   ┌──────────┐
        │PENDIENTE│──────────────►│EN_CURSO  │──────────────►│TERMINADO │
        └─────────┘               └────┬─────┘               └────┬─────┘
             ▲                         │ recompensa              │ persiste
             │                         ▼                          ▼
             │   repetido el          ┌──────────┐        historial anual (M74)
             └────────────────────────│PARTICIPADO│        + recuerdos (M37)
                                      └──────────┘
   NO_PARTICIPADO: franja pasó sin entrar → se registra y espera año siguiente.
   CANCELADO: fallback de carga falló → aviso amable + compensación.
```

## 5. Contrato de señales con otros módulos (solo consumo)

| Módulo | Señal/API consumida | Uso |
|---|---|---|
| M29 | `EventBus.time.dia_cambio`, `estacion_cambio`, `año_cambio` | Reprogramación y chequeo diario |
| M30 | `GameClock.get_minutos_dia()` | Franjas horarias (hora interna, nunca SO) |
| M32 | `EventBus.clima.clima_cambio(clima)` | Variante cubierta / traslado |
| M19/M64 | `EventBus.day.ocupacion_evento(def)` (emitida por M74) | Rutinas de festival por datos |
| M21 | `ContextoFestival` (estructura publicada por M74) | Diálogos con contexto |
| M37 | `registrar_recuerdo(recuerdo)` | Galería de recuerdos |
| M60 | `GameState.M74` | Persistencia versionada |

## 6. Estructura de archivos prevista (Godot)

```
res://eventos/
├── event_manager.gd            # Autoload (nombre: "eventos")
├── event_definition.gd         # Resource EventDefinition
├── condicion_evento.gd         # Resource CondicionEvento
├── recompensa_def.gd           # Resource RecompensaDef
├── event_state.gd              # Estado serializable por año
├── contexto_festival.gd        # Contexto para M21
├── data/
│   ├── festivales/*.tres       # Catálogo de festivales (4 estaciones)
│   ├── ferias/*.tres           # Ferias del pueblo
│   ├── competencias/*.tres     # Torneos (M34/M35/M33)
│   ├── rituales/*.tres         # Rituales ancestrales (M24/M25)
│   ├── climaticos/*.tres       # Aurora, niebla, lluvia de estrellas
│   └── sorpresas/*.tres        # Visitas, regalos, criaturas
res://ui/festival/
├── w_agenda.gd / w_agenda.tscn
├── w_banner_evento.gd / w_banner_evento.tscn
└── w_ventana_festival.gd / w_ventana_festival.tscn
res://tests/eventos/            # Suites de M112 (unit + play mode)
```