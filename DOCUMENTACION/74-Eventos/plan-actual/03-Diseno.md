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

## Specs Eventos (Beam 728)

### RF4.6: activar el recinto del evento (interaccion M70)
- Spec: RF4.6: activar el recinto del evento (interaccion M70). El campo escena_recinto existe y se serializa (event_definition.gd L61/L188) pero no hay instanciacion ni activacion del recinto por interaccion de M70. Coherente with M74 (eventos) and M70 (progresion).

### RF4.7: activar musica y ambiente festivo por señales (M41/M42/M43)
- Spec: RF4.7: activar musica y ambiente festivo por señales (M41/M42/M43). Existen senales de ciclo (evento_iniciado/terminado, event_manager.gd L22-31) pero no hay senial ni consumo de musica/ambiente festivo (M41/M42/M43). Coherente with M74 (eventos) and M41/M42/M43 (audio).

### RF5.15: lanzar el minijuego/partida del festival por contrato de escena
- Spec: RF5.15: lanzar el minijuego/partida del festival por contrato de escena. 0 hits de minijuego/partida de festival en scripts/eventos/. Coherente with M74 (eventos) and M06 (puzzles).

### RF6.7: entregar progreso via M71
- Spec: RF6.7: entregar progreso via M71. 0 hits de entrega de progreso a M71 (logros) en scripts/eventos/. Coherente with M74 (eventos) and M71 (progresion).

### RF6.13: informar en UI "Ya recibiste la recompensa de este año"
- Spec: RF6.13: informar en UI "Ya recibiste la recompensa de este año". Existe buzon_entregas.gd (recompensa fuera de inventario) y la senal evento_recompensa_entregada (event_manager.gd L26) pero no hay mensaje de UI 'ya recibiste la recompensa de este ano'. Coherente with M74 (eventos) and M53 (UI).


## Specs Eventos (Beam 729)

### RF8.2: intercambiar recinto por variante_cubierta ante clima severo
- Spec: RF8.2: intercambiar recinto por variante_cubierta ante clima severo. _on_clima_cambio ante tormenta (event_manager.gd L176-186) es un STUB: imprime y hace pass ('la UI consumiria esta senal'); no hay intercambio real de escena. Coherente with M74 (eventos) and M31 (clima).

### RF8.3: trasladar el evento un dia si no existe variante y el clima es severo
- Spec: RF8.3: trasladar el evento un dia si no existe variante y el clima es severo. 0 hits de reprogramacion de evento por clima severo sin variante (la senal evento_reprogramado existe, L29, pero sin esa logica). Coherente with M74 (eventos) and M31 (clima).

### RF8.4: no interrumpir el evento abruptamente si la tormenta aparece a mitad
- Spec: RF8.4: no interrumpir el evento abruptamente si la tormenta aparece a mitad. 0 hits de logica de no-interrupcion de evento ante tormenta a mitad. Coherente with M74 (eventos) and M31 (clima).

### RF8.5: esperar al cierre del dia para finalizar un evento interrumpido
- Spec: RF8.5: esperar al cierre del dia para finalizar un evento interrumpido. 0 hits de espera al cierre del dia para finalizar evento interrumpido. Coherente with M74 (eventos) and M29 (tiempo).

### RF8.6: ejecutar dialogos de variante para recintos techados (M21)
- Spec: RF8.6: ejecutar dialogos de variante para recintos techados (M21). Los dialogos con variante existentes son estacionales/contextuales (M162, test_contextual_dialogue_m162.gd), no dialogos de variante cubierta para recintos techados de M21. Coherente with M74 (eventos) and M21 (historia).


## Specs Eventos (Beam 730)

### RF9.4: re-programar la sorpresa descartada a otro dia
- Spec: RF9.4: re-programar la sorpresa descartada a otro dia. _sorpresa_semanal_count existe (event_manager.gd L41) pero no hay logica de reprogramar la sorpresa descartada a otro dia. Coherente with M74 (eventos) and M29 (tiempo).

### RF10.3: conectar tutorial de primer festival (M92)
- Spec: RF10.3: conectar tutorial de primer festival (M92). 0 hits de tutorial/primer festival (M92) en scripts/eventos/. Coherente with M74 (eventos) and M92 (tutorial).

### RF12.1: cancelar con aviso amable si la escena del recinto falla (M63)
- Spec: RF12.1: cancelar con aviso amable si la escena del recinto falla (M63). La recompensa compensatoria al cancelar esta implementada y testeada (event_manager.gd L272-283, test_event_manager_verificacion.gd L294) pero falta el disparador: nadie llama _finalizar_evento(cancelado=true) por fallo de escena de M63 (0 llamadores en produccion). Coherente with M74 (eventos) and M63 (streaming).

### RF12.2: jamas crashear ante recinto faltante o corrupto
- Spec: RF12.2: jamas crashear ante recinto faltante o corrupto. Evidencia parcial — recinto FALTANTE no crashea (test_barrido_m74.gd L139 'evento sin escena_recinto no crashea' + load() con null-safe en L84); recinto CORRUPTO no tiene prueba ni manejo. Coherente with M74 (eventos) and M66 (anti-softlock).

### RN4: carga de recintos bajo demanda (M63)
- Spec: RN4: carga de recintos bajo demanda (M63). 0 hits de carga de recintos bajo demanda/streaming (M63) en scripts/eventos/. Coherente with M74 (eventos) and M63 (streaming).


## Specs Eventos (Beam 731)

### RN7: avisos accesibles con texto y icono (M58)
- Spec: RN7: avisos accesibles con texto y icono (M58). 0 hits de avisos accesibles con texto e icono (M58) en scripts/eventos/. Coherente with M74 (eventos) and M58 (accesibilidad).

### RN8: opcion de pausar avisos de eventos
- Spec: RN8: opcion de pausar avisos de eventos. 0 hits de opcion de pausar avisos de eventos. Coherente with M74 (eventos) and M53 (UI).

### RN9: alto contraste en banners
- Spec: RN9: alto contraste en banners. 0 hits de alto contraste en banners de evento. Coherente with M74 (eventos) and M58 (accesibilidad).

### RN10: nombres y descripciones siempre localizables (M57)
- Spec: RN10: nombres y descripciones siempre localizables (M57). Los nombres/descripciones existen como CLAVES de localizacion (nombre_clave/descripcion_clave, event_definition.gd L178-179) pero 0 usos de tr() en scripts/eventos/ (los hits de 'tr(' eran falsos positivos de str(); no hay consumo de M57 verificado). Coherente with M74 (eventos) and M86 (localizacion).

### RN11: cero texto hardcodeado en GDScript
- Spec: RN11: cero texto hardcodeado en GDScript. Hay texto hardcodeado en espanol en prints de debug (event_manager.gd L168 'Buzon: %d entregas purgadas...' y similares); no se verifico texto de UI. Coherente with M74 (eventos) and M102 (logging).


## Specs Eventos (Beam 732)

### RN12: determinismo con misma semilla de partida
- Spec: RN12: determinismo con misma semilla de partida. 0 hits de semilla/seed en scripts/eventos/; no hay logica de determinismo por semilla de partida. Coherente with M74 (eventos) and M08 (terreno).

### RN14: banners no-modales que no bloquean el juego
- Spec: RN14: banners no-modales que no bloquean el juego. 0 hits de banners/modales en scripts/eventos/ (la UI de avisos no esta implementada en el modulo). Coherente with M74 (eventos) and M53 (UI).

### I10: consumir M20 amistad.modificar para recompensas de amistad
- Spec: I10: consumir M20 amistad.modificar para recompensas de amistad. El consumidor existe pero esta ROTO: recompensa_def.gd L95-97 llama fs.sumar_puntos() y friendship_service.gd NO expone sumar_puntos ni modificar (API real: get_puntos, registrar_evento, aplicar_puntos vive en VecinoAmistad) -> en runtime cae al push_warning y la recompensa de amistad no se entrega. Coherente with M74 (eventos) and M20 (amistad).

### I12: consumir M71 progreso para recompensas de progresion
- Spec: I12: consumir M71 progreso para recompensas de progresion. El gancho existe pero esta DORMIDO: recompensa_def.gd L103-109 llama registrar_progreso_evento solo si M71 lo expone; el unico 'func registrar_progreso_evento' del repo esta en el test (test_event_manager_verificacion.gd L77); el propio comentario admite 'se deja el gancho; hasta entonces NO se marca entregada'. Coherente with M74 (eventos) and M71 (progresion).

### I13: consumir M37 registrar_recuerdo para la galeria
- Spec: I13: consumir M37 registrar_recuerdo para la galeria. Mismo patron: recompensa_def.gd L110+ llama museo.registrar_recuerdo() por duck-typing, pero el unico 'func registrar_recuerdo' esta en el test (L71); /root/Museo no expone el metodo en produccion. Coherente with M74 (eventos) and M37 (museo).


## Specs Eventos (Beam 733)

### I15: consumir M63 cargador bajo demanda para recintos
- Spec: I15: consumir M63 cargador bajo demanda para recintos. 0 hits de cargador bajo demanda de recintos (M63) en scripts/eventos/ (ver item 15). Coherente with M74 (eventos) and M63 (streaming).

### I16: consumir M53 convenciones de UI/HUD
- Spec: I16: consumir M53 convenciones de UI/HUD. El diseno separa UI por senales (event_manager.gd L16) pero no hay consumo de convenciones M53 en el modulo. Coherente with M74 (eventos) and M53 (UI).

### I17: consumir M57 localizacion en todas las claves de texto
- Spec: I17: consumir M57 localizacion en todas las claves de texto. 0 usos reales de tr() en scripts/eventos/ (las coincidencias de 'tr(' eran de str()); las claves nombre_clave/descripcion_clave existen pero sin consumo de M57 verificado. Coherente with M74 (eventos) and M86 (localizacion).

### I18: consumir M58 accesibilidad en banners y avisos
- Spec: I18: consumir M58 accesibilidad en banners y avisos. 0 hits de accesibilidad (M58) en banners/avisos del modulo. Coherente with M74 (eventos) and M58 (accesibilidad).

### I23: M94 anti-FOMO: recompensas importantes con ruta alternativa (M39/M37/M23)
- Spec: I23: M94 anti-FOMO: recompensas importantes con ruta alternativa (M39/M37/M23). El anti-FOMO anual esta implementado (event_manager.gd L9/L128, todos los eventos vuelven a PENDIENTE) y hay auditoria de catalogo (test_barrido_m74.gd L10) pero NO hay ruta alternativa de recompensas importantes via M39/M37/M23. Coherente with M74 (eventos) and M93 (retencion).


## Specs Eventos (Beam 734)

### I24: integracion con M92 tutorial en el primer festival
- Spec: I24: integracion con M92 tutorial en el primer festival. 0 hits de tutorial/primer festival (M92) en scripts/eventos/ (ver item 12). Coherente with M74 (eventos) and M92 (tutorial).

### I25: integracion con M104 analytics: registrar participacion sin PII
- Spec: I25: integracion con M104 analytics: registrar participacion sin PII. 0 hits de analytics/telemetria (M104) en scripts/eventos/. Coherente with M74 (eventos) and M104 (telemetria).

### J10: recompensa duplicada: aviso claro en la ventana del festival
- Spec: J10: recompensa duplicada: aviso claro en la ventana del festival. Hay proteccion anti-duplicado de recompensas (recompensas_recibidas en event_state.gd + deep-copy en buzon_entregas.gd L38/47/64) pero no hay aviso claro en UI para recompensa duplicada. Coherente with M74 (eventos) and M53 (UI).

### J11: festival con lluvia: variante cubierta sin cancelacion
- Spec: J11: festival con lluvia: variante cubierta sin cancelacion. _on_clima_cambio con tormenta es un stub (print + pass, event_manager.gd L176-186); no se aplica la variante cubierta ni se cancela, la escena no cambia. Coherente with M74 (eventos) and M31 (clima).

### J12: tormenta a mitad de evento: cierre normal sin interrupcion abrupta
- Spec: J12: tormenta a mitad de evento: cierre normal sin interrupcion abrupta. 0 hits de logica de cierre normal ante tormenta a mitad de evento (ver item 8). Coherente with M74 (eventos) and M31 (clima).


## Specs Eventos (Beam 735)

### J16: recinto roto/corrupto: evento_cancelado + compensacion sin crash
- Spec: J16: recinto roto/corrupto: evento_cancelado + compensacion sin crash. La compensacion al cancelar existe y esta testeada (event_manager.gd L272-283) pero el disparador 'recinto roto/corrupto' no existe y 'corrupto' no tiene prueba (solo 'faltante', item 14). Coherente with M74 (eventos) and M66 (anti-softlock).

### J18: carga concurrente doble: sin clonacion de recompensas
- Spec: J18: carga concurrente doble: sin clonacion de recompensas. El buzon deep-copia las recompensas (buzon_entregas.gd L38/47/64) pero no hay prueba ni guarda de carga concurrente doble de eventos. Coherente with M74 (eventos) and M59 (guardado).

### J20: cumpleanos de NPC (M29) y feria el mismo dia: feria se corre
- Spec: J20: cumpleanos de NPC (M29) y feria el mismo dia: feria se corre. Las prioridades de solape entre eventos de M74 existen (event_definition.gd L49-50, senal solape_resuelto L31) pero no hay regla cruzada cumpleanos-M29 vs feria. Coherente with M74 (eventos) and M29 (tiempo).

### K4: carga de recintos solo al iniciar el evento (bajo demanda)
- Spec: K4: carga de recintos solo al iniciar el evento (bajo demanda). 0 hits de carga/instanciacion de escena de recinto al iniciar evento (ver items 1 y 15). Coherente with M74 (eventos) and M63 (streaming).

### K5: liberar escenas de recinto al terminarse el evento
- Spec: K5: liberar escenas de recinto al terminarse el evento. 0 hits de liberacion (queue_free/free) de escenas de recinto en produccion; los unicos free() son de tests. Coherente with M74 (eventos) and M61 (rendimiento).


## Specs Eventos (Beam 736)

### K7: numeracion de diccionarios con StringName en lugar de String para ids
- Spec: K7: numeracion de diccionarios con StringName en lugar de String para ids. Hay conversiones defensivas a StringName (event_manager.gd L631/712/715) pero los diccionarios del modulo no estan tipados con clave StringName de forma uniforme. Coherente with M74 (eventos) and M04 (game engine).

### K10: persistencia diferida del historial anual (una escritura al fin de año)
- Spec: K10: persistencia diferida del historial anual (una escritura al fin de año). El manager escucha anio_cambio (comentario L15) pero no hay escritura diferida unica del historial al fin de ano (la purga es por dia, L165-170). Coherente with M74 (eventos) and M59 (guardado).

### K11: UI de agenda con instancias recicladas por fila
- Spec: K11: UI de agenda con instancias recicladas por fila. 0 hits de UI de agenda con reciclado de instancias en el modulo (los 'instancia' son de tests). Coherente with M74 (eventos) and M53 (UI).

### K12: banners con animacion unica de entrada, sin repintado continuo
- Spec: K12: banners con animacion unica de entrada, sin repintado continuo. 0 hits de animacion/tween en banners de evento. Coherente with M74 (eventos) and M48 (animacion).

### K13: monitorear allocate de strings en bucles de agenda
- Spec: K13: monitorear allocate de strings en bucles de agenda. 0 hits de monitoreo de allocate de strings en bucles de agenda. Coherente with M74 (eventos) and M61 (rendimiento).


## Specs Eventos (Beam 737)

### K14: test de frame budget en Profiler de Godot
- Spec: K14: test de frame budget en Profiler de Godot. 0 hits de test de frame budget con Profiler para el modulo. Coherente with M74 (eventos) and M61 (rendimiento).

### K15: medicion de memoria del catalogo cargado
- Spec: K15: medicion de memoria del catalogo cargado. 0 hits de medicion de memoria del catalogo cargado. Coherente with M74 (eventos) and M62 (memoria).

### M9: planear suite test_clima: variante cubierta y traslado
- Spec: M9: planear suite test_clima: variante cubierta y traslado. No existe suite test_clima planificada para variante cubierta y traslado (los tests existentes cubren otro frente). Coherente with M74 (eventos) and M112 (testing).

### M14: planear caso de carga concurrente sin clonacion
- Spec: M14: planear caso de carga concurrente sin clonacion. No existe caso de carga concurrente sin clonacion planificado (ver item 37). Coherente with M74 (eventos) and M63 (streaming).

### M20: medir frame budget con Profiler en escena de festival
- Spec: M20: medir frame budget con Profiler en escena de festival. 0 hits de medicion de frame budget con Profiler en escena de festival. Coherente with M74 (eventos) and M61 (rendimiento).


## Specs Eventos (Beam 738)

### M21: verificar 0 errores en consola al entrar en Play Mode
- Spec: M21: verificar 0 errores en consola al entrar en Play Mode. Verificacion manual en Play Mode; no verificable por disco. Pendiente de ejecucion. Coherente with M74 (eventos) and M112 (testing).

### M22: verificar ausencia de NullReference/MissingReference en runtime
- Spec: M22: verificar ausencia de NullReference/MissingReference en runtime. Verificacion de runtime (NullReference/MissingReference); no verificable por disco. Pendiente. Coherente with M74 (eventos) and M112 (testing).

### M23: probar el flujo completo de un festival de extremo a extremo
- Spec: M23: probar el flujo completo de un festival de extremo a extremo. Prueba de flujo completo extremo a extremo; manual. Pendiente. Coherente with M74 (eventos) and M112 (testing).

### M24: probar en la escena de la plaza y en la del recinto
- Spec: M24: probar en la escena de la plaza y en la del recinto. Prueba en escena de plaza y de recinto; manual. Pendiente. Coherente with M74 (eventos) and M112 (testing).

### M25: probar con clima severo forzado desde el debug (M32/M110)
- Spec: M25: probar con clima severo forzado desde el debug (M32/M110). Prueba con clima severo forzado desde debug (M32/M110); manual. Pendiente. Coherente with M74 (eventos) and M32/M110.


## Specs Eventos (Beam 739)

### M26: probar recompensas con inventario lleno y vacio
- Spec: M26: probar recompensas con inventario lleno y vacio. Prueba de recompensas con inventario lleno/vacio; manual. Pendiente. Coherente with M74 (eventos) and M14 (recursos).

### M27: probar ausencia de FOMO: perder un festival y vivirlo el año siguiente
- Spec: M27: probar ausencia de FOMO: perder un festival y vivirlo el año siguiente. Prueba anti-FOMO (perder un festival y vivirlo al ano siguiente); manual. Pendiente. Coherente with M74 (eventos) and M93 (retencion).

### Simulacion de inicio/fin por dia: colgada por regresiones ajenas en el arbol
- Spec: simulacion de inicio/fin por dia: colgada por regresiones ajenas en el arbol (event_bus.gd parse error + vehicle_manager.gd autoload roto — avisos en ESTADO-PARALELO, dueños ajenos) — se revalida con el arbol sano. Coherente with M74 (eventos) and M04 (game engine).
