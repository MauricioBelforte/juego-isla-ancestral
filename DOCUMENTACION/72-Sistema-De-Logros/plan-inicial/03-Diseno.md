**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 72: Sistema de Logros

## 1. Arquitectura general

El módulo sigue la arquitectura por capas del proyecto (M07): **motor de dominio desacoplado** (no conoce UI ni plataforma) + **adaptadores opcionales** (UI toast, panel, Steam). El `AchievementManager` es un **autoload** (`logros`), registrado en `project.godot`, que orquesta todo el flujo.

```
┌────────────────────────────────────────────────────────────────────┐
│  Emisores de eventos (ya existentes)                                │
│  M71 Progresión · M37 Colecciones · M34 Pesca · M20 Amistad          │
│  M22 Historia · M33 Agricultura · M38 Economía · M13 Herramientas    │
└──────────────────────────┬─────────────────────────────────────────┘
                           │ señales de progreso (EventBus M07)
                           ▼
┌────────────────────────────────────────────────────────────────────┐
│  AchievementManager (autoload "logros")                             │
│  ┌──────────────┐ ┌───────────────┐ ┌───────────────────┐           │
│  │Catálogo      │ │Motor de       │ │GuardadoLogros     │           │
│  │(definiciones)│ │condiciones    │ │(persistencia      │           │
│  │.tres         │ │(dirty flags)  │ │write-through M60) │           │
│  └──────────────┘ └───────────────┘ └───────────────────┘           │
│  Señales: logro_desbloqueado(id, def) · logro_progreso(id, x, y)    │
└──────┬───────────────────────────────┬─────────────────────────────┘
       │ logro_desbloqueado            │ API consulta / catálogo
       ▼                               ▼
┌──────────────────┐        ┌───────────────────┐   ┌────────────────┐
│ Notificador UI   │        │ Panel de logros   │   │ steam_sync     │
│ (toast encolado, │        │ (M53 UI/UX:       │   │ (M97 opcional, │
│ 3 visibles, N    │        │ obtenidos, en     │   │ desacoplado:   │
│ resumibles)      │        │ progreso "X de Y",│   │ Set/Get/Store  │
│                  │        │ ocultos)          │   │ Stats)         │
└──────────────────┘        └───────────────────┘   └────────────────┘
```

### 1.1 Componentes

| Componente | Tipo | Responsabilidad |
|---|---|---|
| `AchievementManager` | Autoload `logros` | Orquestador: catálogo, registro de definiciones, evaluación, desbloqueo, persistencia, señales, API de consulta |
| `AchievementDefinition` | Resource (`.tres`) | Datos de un logro: id, textos i18n, ícono, categoría, condición, oculto, `logro_steam_id`, progreso parcial |
| `CondicionBase` | RefCounted (abstracta) | Contrato de condición: `evaluar_progreso(ctx) -> float` (0..1) y `cumplida() -> bool` |
| `CondicionContador` | CondicionBase | `stat_contador >= n` sobre estadísticas de M71 |
| `CondicionColeccion` | CondicionBase | `coleccion_completa(id)` y `coleccion_porcentaje(id) >= p` de M37 |
| `CondicionPesca` | CondicionBase | `pescar_especie(id)` y `pescar_todas_las_especies()` de M34 |
| `CondicionAmistad` | CondicionBase | `amistad_maxima(npc)` y `amistad_total >= n` de M20 |
| `CondicionHito71` | CondicionBase | `hito_71(id)` alcanzado en M71 |
| `CondicionHistoria` | CondicionBase | `sello_historia(id)` de M22 |
| `CondicionCompuesta` | CondicionBase | AND / OR / NOT de subcondiciones |
| `GuardadoLogros` | RefCounted | Serializa/deserializa el estado `{id: {desbloqueado, fecha, progreso, extra}}` con M60 |
| `LogroToastUI` | CanvasLayer + Node | Notificación toast encolada, no bloqueante, desactivable (M58) |
| `PanelLogrosUI` | CanvasLayer + Node | Vista de logros: obtenidos, en progreso, ocultos (M53) |
| `SteamSync` | Node (M97, opcional) | Adaptador Steamworks: `SetAchievement`, `GetAchievement`, `StoreStats`, reconciliación en carga |

## 2. Diseño de datos

### 2.1 `AchievementDefinition` (Resource)

```
@tool
class_name AchievementDefinition extends Resource

@export var achievement_id: StringName          # id único del catálogo
@export var nombre_i18n: String                  # clave de traducción (es)
@export var descripcion_i18n: String
@export var icono: Texture2D
@export var categoria: StringName                # agricultura, pesca, minería,
                                                 # amistad, colecciones, progresion, economía, exploracion...
@export var oculto: bool = false                 # logro sorpresa (se revela al desbloquear)
@export var condicion: CondicionBase             # condición a evaluar
@export var logro_steam_id: String = ""          # id Steam (M97), vacío = solo local
@export var orden: int = 0                       # orden de presentación en el panel
```

### 2.2 Estado persistido (GuardadoLogros)

```
{
    "logros": {
        "primera_cosecha": { "desbloqueado": true, "fecha": "2026-08-17T14:30:00", "progreso": 1.0 },
        "pescador_master":   { "desbloqueado": false, "fecha": "", "progreso": 0.74 }
    }
}
```

- `progreso`: 0..1 calculado por la condición (para logros acumulativos, expone "X de Y" vía `get_progreso_humano`).
- Se guarda con el guardado global (M60) e inmediatamente después de cada desbloqueo (write-through, D6).

## 3. Flujos

### 3.1 Flujo de desbloqueo (evento → logro desbloqueado)

1. Un sistema emisor (ej. M34 Pesca) emite su señal de progreso por el EventBus (M07) o directamente al manager.
2. `AchievementManager.notify_event(tipo_evento, valor, contexto)` consulta el índice `evento → logros dependientes` (dirty flags) y re-evalúa **solo** esos logros.
3. Para cada condición cumplida y no desbloqueada: se marca `_desbloqueados[id]` (flag atómico anti-doble-desbloqueo), se registra fecha, se persiste write-through.
4. Se emite `logro_desbloqueado(id, definicion)`.
5. El `NotificadorUI` encola el toast (o resumen si la cola excede N).
6. `SteamSync` (si está activo) llama `SetAchievement` + `StoreStats`.
7. Se registra en logs (M103) y analytics (M104).

### 3.2 Flujo de carga de partida (retroactividad + Steam)

1. M60 carga el guardado; `AchievementManager.cargar(estado)` restaura el dict de logros.
2. Se registran todas las definiciones del catálogo (`.tres` cargados por un `ResourceLoader` central o exportados en el autoload).
3. Evaluación retroactiva (D4): todo logro sin desbloquear cuya condición ya se cumple → desbloqueo con fecha de carga y notificación encolada (resumida si son muchos).
4. Si `steam_sync` está disponible: `GetAchievement` para cada `logro_steam_id`; discrepancias se reconcilian (local → Steam y Steam → local, ganando el desbloqueado).

### 3.3 Flujo de consulta (panel)

1. `PanelLogrosUI` pide `AchievementManager.get_todos()`.
2. Por cada definición: `is_unlocked(id)`, `get_fecha(id)`, `get_progreso(id)` (y "X de Y" vía `get_progreso_humano(id)`) y `es_visible(id)` (ocultos no revelados → "???").
3. El panel agrupa por categoría y orden, mostrando: obtenidos con fecha, en progreso con barra/contador, ocultos como misterio.
4. Hacer clic en un toast abre el panel en ese logro concreto.

### 3.4 Flujo de reset de partida

1. M60 borra la partida → `AchievementManager.limpiar()` vacía el estado.
2. `steam_sync` (si aplica) no borra logros de Steam automáticamente; en la próxima sesión la reconciliación decide.

## 4. Integración con otros módulos

| Módulo | Relación | Detalle |
|---|---|---|
| M71 Progresión | Consume | Estadísticas del perfil de jugador (`stat_contador`), hitos (`hito_71`) y señales de progreso como entrada de condiciones; el registro de logros base de M71 delega su presentación a este módulo |
| M37 Colecciones | Consume | Señal de donación/completado para `coleccion_completa` y `coleccion_porcentaje`; los logros de colección usan ids de M37 |
| M20 Amistad | Consume | Señal de nivel de amistad para `amistad_maxima` y `amistad_total` |
| M34 Pesca | Consume | Señal de captura para `pescar_especie` y `pescar_todas_las_especies` |
| M22 Historia | Consume | Señales de sello/capítulo para `sello_historia` |
| M53 UI/UX | Provee señales | El Notificador y el Panel consumen las reglas de UI de M53; este módulo no dibuja nada por sí mismo |
| M58 Accesibilidad | Consume | Notificaciones desactivables, sin robo de input, con tiempos generosos y contraste adecuado en el panel |
| M60/M59 Datos | Provee estado | `GuardadoLogros` serializa dentro del guardado global; write-through tras cada desbloqueo |
| M97 Steam | Opcional | `SteamSync` adapta el motor local a Steamworks; el motor no depende de M97 (D3, D4) |
| M103/M104 Logs/Analytics | Emite | Cada desbloqueo se registra con id, fecha y origen |
| M66 Anti-Softlock | Alineado | Retroactividad garantizada: ningún logro queda imposible (D4) |
| M112 Testing | Consume | Tests unitarios del motor sin UI ni Steam; partidas sintéticas |

## 5. Contrato de señales (API pública del autoload)

```
signal logro_desbloqueado(achievement_id: StringName, definicion: AchievementDefinition)
signal logro_progreso(achievement_id: StringName, progreso: float)   # 0..1
signal logro_catalogo_actualizado()                                  # tras registrar definiciones o validar

# API de consulta
func is_unlocked(achievement_id: StringName) -> bool
func get_definicion(achievement_id: StringName) -> AchievementDefinition
func get_todos() -> Array[AchievementDefinition]
func get_estado(achievement_id: StringName) -> Dictionary        # {desbloqueado, fecha, progreso, extra}
func get_fecha(achievement_id: StringName) -> String
func get_progreso(achievement_id: StringName) -> float           # 0..1
func get_progreso_humano(achievement_id: StringName) -> String  # "37 de 50"
func es_visible(achievement_id: StringName) -> bool             # ocultos no revelados = false
func get_desbloqueados() -> Array[StringName]
func get_en_progreso() -> Array[StringName]
func get_porcentaje_completado() -> float

# API de registro y eventos
func registrar_catalogo(definiciones: Array[AchievementDefinition]) -> void
func notify_event(tipo_evento: StringName, valor: float = 1.0, contexto: Dictionary = {}) -> void
func re_evaluar_todo() -> void                                  # usado al cargar (retroactividad) y en editor

# API de persistencia
func cargar(estado_logros: Dictionary) -> void
func guardar() -> Dictionary
func limpiar() -> void

# API de Steam (delegada a SteamSync; el manager solo expone un registro de listener)
func registrar_sync_steam(sync: Node) -> void
func notificar_logro_steam(achievement_id: StringName) -> void  # llamado por SteamSync al reconciliar
```

## 6. Detalles de implementación clave

- **Índice de dirty flags:** `Dictionary[StringName, Array[StringName]]` mapea `tipo_evento` → ids de logros a re-evaluar; evita barridos completos (RN1).
- **Anti-doble-desbloqueo:** la marca en `_desbloqueados` ocurre **antes** de emitir señales y de persistir; cualquier reentrada se ignora (RF4).
- **Retroactividad:** `re_evaluar_todo()` al cargar usa el perfil de M71 ya restaurado; condiciones compuestas se resuelven recursivamente con memoización por logro.
- **Notificación encolada:** `LogroToastUI` mantiene una cola `Array[Dictionary]`, muestra máx. 3 toasts simultáneos y resume "N nuevos logros" si la cola supera 5; delay regenerativo de 0.8 s entre toasts (D2).
- **Validación en editor (`@tool`):** al guardar el catálogo se valida: ids únicos, íconos no nulos, condición no nula, categoría conocida, referencia a estadística existente en M71, mapeo Steam sin duplicados (RF14).
- **Determinismo:** nunca se usa `rand` en evaluación; la fecha se toma una sola vez por desbloqueo y se persiste.

## 7. Estructura de carpetas prevista

```
res://logros/
├── achievement_manager.gd          # autoload "logros"
├── achievement_definition.gd       # Resource (clase AchievementDefinition)
├── condiciones/
│   ├── condicion_base.gd
│   ├── condicion_contador.gd
│   ├── condicion_coleccion.gd
│   ├── condicion_pesca.gd
│   ├── condicion_amistad.gd
│   ├── condicion_hito71.gd
│   ├── condicion_historia.gd
│   └── condicion_compuesta.gd
├── guardado_logros.gd
├── ui/
│   ├── logro_toast.gd / logro_toast.tscn
│   ├── panel_logros.gd / panel_logros.tscn
│   └── panel_logros_item.gd / panel_logros_item.tscn
├── steam/
│   └── steam_sync.gd               # opcional (M97), cargado solo si hay SDK
├── datos/
│   ├── logros_agricultura.tres ... # catálogo curado (contenido, no código)
│   └── validacion_logros.gd        # @tool script de validación (RF14)
└── README.md                       # guía: cómo agregar un logro nuevo
```