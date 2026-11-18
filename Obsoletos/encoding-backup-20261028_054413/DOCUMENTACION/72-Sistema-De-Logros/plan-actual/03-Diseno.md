**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 72: Sistema de Logros

## 1. Arquitectura general

El mÃ³dulo sigue la arquitectura por capas del proyecto (M07): **motor de dominio desacoplado** (no conoce UI ni plataforma) + **adaptadores opcionales** (UI toast, panel, Steam). El `AchievementManager` es un **autoload** (`logros`), registrado en `project.godot`, que orquesta todo el flujo.

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Emisores de eventos (ya existentes)                                â”‚
â”‚  M71 ProgresiÃ³n Â· M37 Colecciones Â· M34 Pesca Â· M20 Amistad          â”‚
â”‚  M22 Historia Â· M33 Agricultura Â· M38 EconomÃ­a Â· M13 Herramientas    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â”‚ seÃ±ales de progreso (EventBus M07)
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  AchievementManager (autoload "logros")                             â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”           â”‚
â”‚  â”‚CatÃ¡logo      â”‚ â”‚Motor de       â”‚ â”‚GuardadoLogros     â”‚           â”‚
â”‚  â”‚(definiciones)â”‚ â”‚condiciones    â”‚ â”‚(persistencia      â”‚           â”‚
â”‚  â”‚.tres         â”‚ â”‚(dirty flags)  â”‚ â”‚write-through M60) â”‚           â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜           â”‚
â”‚  SeÃ±ales: logro_desbloqueado(id, def) Â· logro_progreso(id, x, y)    â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ logro_desbloqueado            â”‚ API consulta / catÃ¡logo
       â–¼                               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Notificador UI   â”‚        â”‚ Panel de logros   â”‚   â”‚ steam_sync     â”‚
â”‚ (toast encolado, â”‚        â”‚ (M53 UI/UX:       â”‚   â”‚ (M97 opcional, â”‚
â”‚ 3 visibles, N    â”‚        â”‚ obtenidos, en     â”‚   â”‚ desacoplado:   â”‚
â”‚ resumibles)      â”‚        â”‚ progreso "X de Y",â”‚   â”‚ Set/Get/Store  â”‚
â”‚                  â”‚        â”‚ ocultos)          â”‚   â”‚ Stats)         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1.1 Componentes

| Componente | Tipo | Responsabilidad |
|---|---|---|
| `AchievementManager` | Autoload `logros` | Orquestador: catÃ¡logo, registro de definiciones, evaluaciÃ³n, desbloqueo, persistencia, seÃ±ales, API de consulta |
| `AchievementDefinition` | Resource (`.tres`) | Datos de un logro: id, textos i18n, Ã­cono, categorÃ­a, condiciÃ³n, oculto, `logro_steam_id`, progreso parcial |
| `CondicionBase` | RefCounted (abstracta) | Contrato de condiciÃ³n: `evaluar_progreso(ctx) -> float` (0..1) y `cumplida() -> bool` |
| `CondicionContador` | CondicionBase | `stat_contador >= n` sobre estadÃ­sticas de M71 |
| `CondicionColeccion` | CondicionBase | `coleccion_completa(id)` y `coleccion_porcentaje(id) >= p` de M37 |
| `CondicionPesca` | CondicionBase | `pescar_especie(id)` y `pescar_todas_las_especies()` de M34 |
| `CondicionAmistad` | CondicionBase | `amistad_maxima(npc)` y `amistad_total >= n` de M20 |
| `CondicionHito71` | CondicionBase | `hito_71(id)` alcanzado en M71 |
| `CondicionHistoria` | CondicionBase | `sello_historia(id)` de M22 |
| `CondicionCompuesta` | CondicionBase | AND / OR / NOT de subcondiciones |
| `GuardadoLogros` | RefCounted | Serializa/deserializa el estado `{id: {desbloqueado, fecha, progreso, extra}}` con M60 |
| `LogroToastUI` | CanvasLayer + Node | NotificaciÃ³n toast encolada, no bloqueante, desactivable (M58) |
| `PanelLogrosUI` | CanvasLayer + Node | Vista de logros: obtenidos, en progreso, ocultos (M53) |
| `SteamSync` | Node (M97, opcional) | Adaptador Steamworks: `SetAchievement`, `GetAchievement`, `StoreStats`, reconciliaciÃ³n en carga |

## 2. DiseÃ±o de datos

### 2.1 `AchievementDefinition` (Resource)

```
@tool
class_name AchievementDefinition extends Resource

@export var achievement_id: StringName          # id Ãºnico del catÃ¡logo
@export var nombre_i18n: String                  # clave de traducciÃ³n (es)
@export var descripcion_i18n: String
@export var icono: Texture2D
@export var categoria: StringName                # agricultura, pesca, minerÃ­a,
                                                 # amistad, colecciones, progresion, economÃ­a, exploracion...
@export var oculto: bool = false                 # logro sorpresa (se revela al desbloquear)
@export var condicion: CondicionBase             # condiciÃ³n a evaluar
@export var logro_steam_id: String = ""          # id Steam (M97), vacÃ­o = solo local
@export var orden: int = 0                       # orden de presentaciÃ³n en el panel
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

- `progreso`: 0..1 calculado por la condiciÃ³n (para logros acumulativos, expone "X de Y" vÃ­a `get_progreso_humano`).
- Se guarda con el guardado global (M60) e inmediatamente despuÃ©s de cada desbloqueo (write-through, D6).

## 3. Flujos

### 3.1 Flujo de desbloqueo (evento â†’ logro desbloqueado)

1. Un sistema emisor (ej. M34 Pesca) emite su seÃ±al de progreso por el EventBus (M07) o directamente al manager.
2. `AchievementManager.notify_event(tipo_evento, valor, contexto)` consulta el Ã­ndice `evento â†’ logros dependientes` (dirty flags) y re-evalÃºa **solo** esos logros.
3. Para cada condiciÃ³n cumplida y no desbloqueada: se marca `_desbloqueados[id]` (flag atÃ³mico anti-doble-desbloqueo), se registra fecha, se persiste write-through.
4. Se emite `logro_desbloqueado(id, definicion)`.
5. El `NotificadorUI` encola el toast (o resumen si la cola excede N).
6. `SteamSync` (si estÃ¡ activo) llama `SetAchievement` + `StoreStats`.
7. Se registra en logs (M103) y analytics (M104).

### 3.2 Flujo de carga de partida (retroactividad + Steam)

1. M60 carga el guardado; `AchievementManager.cargar(estado)` restaura el dict de logros.
2. Se registran todas las definiciones del catÃ¡logo (`.tres` cargados por un `ResourceLoader` central o exportados en el autoload).
3. EvaluaciÃ³n retroactiva (D4): todo logro sin desbloquear cuya condiciÃ³n ya se cumple â†’ desbloqueo con fecha de carga y notificaciÃ³n encolada (resumida si son muchos).
4. Si `steam_sync` estÃ¡ disponible: `GetAchievement` para cada `logro_steam_id`; discrepancias se reconcilian (local â†’ Steam y Steam â†’ local, ganando el desbloqueado).

### 3.3 Flujo de consulta (panel)

1. `PanelLogrosUI` pide `AchievementManager.get_todos()`.
2. Por cada definiciÃ³n: `is_unlocked(id)`, `get_fecha(id)`, `get_progreso(id)` (y "X de Y" vÃ­a `get_progreso_humano(id)`) y `es_visible(id)` (ocultos no revelados â†’ "???").
3. El panel agrupa por categorÃ­a y orden, mostrando: obtenidos con fecha, en progreso con barra/contador, ocultos como misterio.
4. Hacer clic en un toast abre el panel en ese logro concreto.

### 3.4 Flujo de reset de partida

1. M60 borra la partida â†’ `AchievementManager.limpiar()` vacÃ­a el estado.
2. `steam_sync` (si aplica) no borra logros de Steam automÃ¡ticamente; en la prÃ³xima sesiÃ³n la reconciliaciÃ³n decide.

## 4. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | RelaciÃ³n | Detalle |
|---|---|---|
| M71 ProgresiÃ³n | Consume | EstadÃ­sticas del perfil de jugador (`stat_contador`), hitos (`hito_71`) y seÃ±ales de progreso como entrada de condiciones; el registro de logros base de M71 delega su presentaciÃ³n a este mÃ³dulo |
| M37 Colecciones | Consume | SeÃ±al de donaciÃ³n/completado para `coleccion_completa` y `coleccion_porcentaje`; los logros de colecciÃ³n usan ids de M37 |
| M20 Amistad | Consume | SeÃ±al de nivel de amistad para `amistad_maxima` y `amistad_total` |
| M34 Pesca | Consume | SeÃ±al de captura para `pescar_especie` y `pescar_todas_las_especies` |
| M22 Historia | Consume | SeÃ±ales de sello/capÃ­tulo para `sello_historia` |
| M53 UI/UX | Provee seÃ±ales | El Notificador y el Panel consumen las reglas de UI de M53; este mÃ³dulo no dibuja nada por sÃ­ mismo |
| M58 Accesibilidad | Consume | Notificaciones desactivables, sin robo de input, con tiempos generosos y contraste adecuado en el panel |
| M60/M59 Datos | Provee estado | `GuardadoLogros` serializa dentro del guardado global; write-through tras cada desbloqueo |
| M97 Steam | Opcional | `SteamSync` adapta el motor local a Steamworks; el motor no depende de M97 (D3, D4) |
| M103/M104 Logs/Analytics | Emite | Cada desbloqueo se registra con id, fecha y origen |
| M66 Anti-Softlock | Alineado | Retroactividad garantizada: ningÃºn logro queda imposible (D4) |
| M112 Testing | Consume | Tests unitarios del motor sin UI ni Steam; partidas sintÃ©ticas |

## 5. Contrato de seÃ±ales (API pÃºblica del autoload)

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

## 6. Detalles de implementaciÃ³n clave

- **Ãndice de dirty flags:** `Dictionary[StringName, Array[StringName]]` mapea `tipo_evento` â†’ ids de logros a re-evaluar; evita barridos completos (RN1).
- **Anti-doble-desbloqueo:** la marca en `_desbloqueados` ocurre **antes** de emitir seÃ±ales y de persistir; cualquier reentrada se ignora (RF4).
- **Retroactividad:** `re_evaluar_todo()` al cargar usa el perfil de M71 ya restaurado; condiciones compuestas se resuelven recursivamente con memoizaciÃ³n por logro.
- **NotificaciÃ³n encolada:** `LogroToastUI` mantiene una cola `Array[Dictionary]`, muestra mÃ¡x. 3 toasts simultÃ¡neos y resume "N nuevos logros" si la cola supera 5; delay regenerativo de 0.8 s entre toasts (D2).
- **ValidaciÃ³n en editor (`@tool`):** al guardar el catÃ¡logo se valida: ids Ãºnicos, Ã­conos no nulos, condiciÃ³n no nula, categorÃ­a conocida, referencia a estadÃ­stica existente en M71, mapeo Steam sin duplicados (RF14).
- **Determinismo:** nunca se usa `rand` en evaluaciÃ³n; la fecha se toma una sola vez por desbloqueo y se persiste.

## 7. Estructura de carpetas prevista

```
res://logros/
â”œâ”€â”€ achievement_manager.gd          # autoload "logros"
â”œâ”€â”€ achievement_definition.gd       # Resource (clase AchievementDefinition)
â”œâ”€â”€ condiciones/
â”‚   â”œâ”€â”€ condicion_base.gd
â”‚   â”œâ”€â”€ condicion_contador.gd
â”‚   â”œâ”€â”€ condicion_coleccion.gd
â”‚   â”œâ”€â”€ condicion_pesca.gd
â”‚   â”œâ”€â”€ condicion_amistad.gd
â”‚   â”œâ”€â”€ condicion_hito71.gd
â”‚   â”œâ”€â”€ condicion_historia.gd
â”‚   â””â”€â”€ condicion_compuesta.gd
â”œâ”€â”€ guardado_logros.gd
â”œâ”€â”€ ui/
â”‚   â”œâ”€â”€ logro_toast.gd / logro_toast.tscn
â”‚   â”œâ”€â”€ panel_logros.gd / panel_logros.tscn
â”‚   â””â”€â”€ panel_logros_item.gd / panel_logros_item.tscn
â”œâ”€â”€ steam/
â”‚   â””â”€â”€ steam_sync.gd               # opcional (M97), cargado solo si hay SDK
â”œâ”€â”€ datos/
â”‚   â”œâ”€â”€ logros_agricultura.tres ... # catÃ¡logo curado (contenido, no cÃ³digo)
â”‚   â””â”€â”€ validacion_logros.gd        # @tool script de validaciÃ³n (RF14)
â””â”€â”€ README.md                       # guÃ­a: cÃ³mo agregar un logro nuevo
```

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 1 | Umbrales de desbloqueo por nivel de amistad | 30/70/120/150/260 | De friendship.json (coherente con M20). Logros por nivel: 3-5 por nivel. |
| 2 | Curva de growth por stat | 1.0 + 0.15 * nivel | Lineal, coherente con M16 RF-MR4. Max nivel 10 -> 2.5x. |
| 3 | Recompensas de oro por logro (suma total) | ~750 AO one-time | Mision principal 200 + sello 500 + secundaria 50 = 750. vs economia diaria 80 AO = 9.4 dias. Razonable. |
| 4 | Tabla de XP por logro (suma vs curva) | 2790 XP (ILUSTRATIVO: 93 logros x 30 XP) â€” PENDIENTE DE CATALOGO FINAL | Curva de nivel: 100 niveles x 100 XP = 10000 XP. Ratio 27.9% SOLO si el catalogo final es 93 logros. AUDITORIA 2026-10-23: CAT-1 define catalogo base de 20-30 logros; la cifra 93 no tiene fuente en el doc (inconsistencia interna). Con 20-30 logros: 600-900 XP (6-9% de la curva). |
| 5 | KPI: % logros completados por jugador cozy | 60-70% | Orden de magnitud razonable para un jugador cozy (no completionist). |


## Presupuestos numericos â€” catalogo cozy y specs (Reflection-Beam-1.0, 2026-10-23)

### CAT-1: Catalogo base cozy de logros (20-30 logros)
Catalogo base de 20-30 logros cozy con umbrales NO abusivos:
- **Primeras veces (5):** primera pesca, primera foto, primer vecino, primera cosecha, primera casa.
- **Hitos (8):** dias jugados (7/30/90), cosechas totales (10/50/100), peces capturados (5/25/50), fotos tomadas (10/50).
- **Colecciones (7):** peces (5/10/15 especies), flora (3/6/9 tipos), medallas (3/6/9).
Umbrales coherentes con H2 de rareza (no grinds abusivos, max 100 repeticiones para el mas alto).

### CAT-2: Criterios anti-abusivos de logros
- Sin contrarreloj (no hay logros de "en menos de X segundos").
- Sin grinds > 100 repeticiones para el logro mas alto (cap en 100).
- Umbrales baseline por categoria: primeras veces (1), hitos (10/50/100), colecciones (3/6/9).
- Coherente con H2: rareza 0.5% vs 5% (si se alinea a 5%, los umbrales de coleccion son alcanzables).

### RF6: Spec de logs anti-perdida de avisos
- QUE se loggea cuando la cola se desborda: evento (id del logro), nivel (toast/panel), retencion (30 dias).
- Formato: {timestamp, logro_id, nivel, origen, progreso}. Retencion: 30 dias (coherente con M105 retencion 30 dias).
- Si la cola excede 3 toasts simultaneos, se encola y se muestra en secuencia (no se pierde).

### RF11: Spec de sincronizacion Steam
- QUE se sincroniza: logros desbloqueados (id + fecha), estadisticas (contadores), progreso (0..1).
- CUANDO: tras cada desbloqueo (write-through) y al cargar partida (reconciliacion local <-> Steam).
- QUE NO se borra nunca del Steam Cloud al borrar guardado local: logros desbloqueados (irreversibles en Steam).
- Coherente con K8/respawn de QA M28 (respawn no borra logros).

### RN2: Spec de write-through diferido
- Mecanica: cola diferida de escritura de progreso de logros. No bloquea el frame principal.
- Umbrales: flush cada 5s o cada 10 logros (lo que ocurra primero). Coherente con M58/M70 budgets (<0.5 ms/frame).
- Si el frame budget se excede, se difiere al siguiente frame (no se pierde, se encola).

### RF9: Spec de esquema de persistencia parcial
- Estructura: {id: {desbloqueado: bool, fecha: ISO8601, progreso: float, extra: Dictionary}}.
- Versionado: schema v1 (actual). Migracion futura: si se agrega campo, default = valor vacio.
- Coherente con M59/M60: GuardadoLogros serializa dentro del guardado global. Write-through tras cada desbloqueo.

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de sensibilidad de umbrales** [x] - formula de desvio por umbral y curva de canal (la +/- respecto de 93) (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de scaling de recompensas por tier** [x] - factor 1.5x INCREMENTAL por tier (50/75/100/125/150; annotation de correccion: la frase original decia 2x y era imprecisa, Hy3 343) chequeado contra economia de 93 (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de casos-limite: logros de coleccion al 99%** [x] - formula del jugador completista (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 1. Sensibilidad de umbrales de desbloqueo
- Valores de diseÃ±o FIJOS (30/70/120/150/260): los incrementos reales (30/40/50/30/110) NO siguen un factor geometrico; la formula `umbral_nivel = base + (umbral_anterior*0.5)` era falsa (Hy3 343: no produce la serie; corregido por director â€” serie queda FIJA tal como esta, sin formula derivable; si el diseÃ±o futuro la necesita, se define nueva regla y se cita aquÃ­).
- Valores: nivel_2 = 30, nivel_3 = 70 (30 + 30*0.5 = 45? No: 30 + 40 = 70, incremento 40). nivel_4 = 120 (70 + 50 = 120). nivel_5 = 150 (120 + 30 = 150). nivel_8 = 260 (150 + 110 = 260).
- Incrementos: 30, 40, 50, 30, 110. Pendiente decreciente hasta nivel_5, luego salto a nivel_8 (secreto). Coherente con H3 (umbrales 30/70/120/150/260).
- Unidad: puntos de amistad. Dependencia: M20 (amistad), M93 (economia).

### 2. Scaling de recompensas por tier
- Formula (corregida por director, Hy3 343): recompensa_tier = base_tier * (1 + 0.5 * (tier - 1)) con base_tier = 50 AO -> serie 50/75/100/125/150 (la version anterior con `tier` tenia off-by-one y daba 75 en tier1).
- Valores: tier 1 = 50, tier 2 = 75, tier 3 = 100, tier 4 = 125, tier 5 = 150.
- Coherente con economia diaria 80 AO: max recompensa por logro = 150 AO = 1.875 dias. No infla (<= 2 dias de ingreso).
- Unidad: AO. Dependencia: M93 (dinero_diario 80).

### 3. Casos-limite: logros de coleccion al 99%
- Formula: progreso_coleccion = items_obtenidos / items_totales * 100. Logro desbloqueado cuando progreso >= 99%.
- Umbral 99% (no 100%) para evitar bloqueo por items imposibles de obtener.
- Coherente con M73 (colecciones) y H2 (rareza 5% con pity).
- Unidad: porcentaje. Dependencia: M73, M93 (H2).

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-3 (H23)**: "max 100 cosechas" del catalogo cozy = **ACUMULADO** (no por sesion). El catalogo de logros de M72 cuenta cosechas acumuladas a lo largo de toda la partida, no por sesion. Coherente con M93 (economia) y M34 (pesca). Cita canonica: "GO FUNDADOR 23oct 20:25: Â«sÃ­, me gustan las recomendacionesÂ» (via director 315)".


## Specs Sistema de Logros (Beam 519)

### RN1: presupuesto de evaluación < 1 ms por evento con 200 logros
- Spec: RN1: presupuesto de evaluación < 1 ms por evento con 200 logros definidos. Coherente con M72 (logros) y M61 (rendimiento).

### RN3: módulo compila y funciona 100% sin SDK de Steam
- Spec: RN3: módulo compila y funciona 100% sin SDK de Steam. Coherente con M72 (logros) y M94 (negocio).

### SteamSync desacoplado que escuche logro_desbloqueado
- Spec: diseñar SteamSync desacoplado que escuche logro_desbloqueado sin modificar el manager. Coherente con M72 (logros) y M94 (negocio).

### Sincronizar local -> Steam con SetAchievement + StoreStats
- Spec: sincronizar local -> Steam con SetAchievement + StoreStats al desbloquear. Coherente con M72 (logros) y M94 (negocio).

### Sincronizar Steam -> local con GetAchievement al cargar partida
- Spec: sincronizar Steam -> local con GetAchievement al cargar partida. Coherente con M72 (logros) y M59 (guardado).

### Índice de dirty flags por tipo de evento
- Spec: índice de dirty flags por tipo de evento: re-evaluar solo logros afectados. Coherente con M72 (logros) y M61 (rendimiento).

### Maduras: verificar en Profiler que notify_event con 200 logros < 1 ms
- Spec: maduras: verificar en Profiler que notify_event con 200 logros < 1 ms. Coherente con M72 (logros) y M116 (profiling).

### Maduras: verificar 0.5 ms máx extra por frame en eventos de progreso
- Spec: maduras: verificar 0.5 ms máx extra por frame en eventos de progreso (sin GC spikes). Coherente con M72 (logros) y M116 (profiling).

### Test rendimiento: Profiler con 200 logros y evento de progreso < 1 ms
- Spec: test rendimiento: Profiler con 200 logros y evento de progreso < 1 ms. Coherente con M72 (logros) y M116 (profiling).


## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25, riel design-docs agnes msg 258 lote 2)

Metodo produce-first: grep + lectura directa de runtime/data, sin ejecutar Godot. Citas archivo:Línea. Los drifts encontrados se documentan con evidencia (no se pisan diseños previos; el historial Beam queda intacto).

### 4. Sensibilidad de umbrales (medida)
- Serie FIJA 30/70/120/150/260 verificada en disco: data/balance/friendship.json L3-9 = {"nivel_2": 30, "nivel_3": 70, "nivel_4": 120, "nivel_5": 150, "nivel_8": 260}, schema_version=2 (L2). Increments 30/40/50/30/110 — confirma Beam 312 ###1 (serie fija, sin derivacion geometrica; la formula base+anterior*0.5 era falsa, Hy3 343).
- Puntos por accion (friendship.json L10-16): regalo_gustado 10, regalo_neutral 5, charla 5, carta 8, evento_festival 20; generosidad_favorito x3 (L17-21); beneficios_por_nivel L22-29 (recetas/descuentos/eventos/dialogos — son beneficios de M20 amistad, NO recompensas de logros M72).
- Consumidor del JSON: scripts/balance/balance_service.gd L32 (_cargar_json("friendship.json")), expuesto via get_friendship_thresholds() L104-105; consumidores declarados L8-9 (M38/M20/M16/M17/M33-35/M22-23/M153/M71).
- DRIFT DE DOBLE FUENTE (niveles de amistad en runtime): scripts/friendship/amistad_config.gd L10 (fallback del Resource) y data/amistad/amistad_config.tres L7 tienen OTRA serie: [0, 20, 40, 70, 100, 140, 190, 250, 320, 400, 500] (11 niveles; nivel_2=20 vs 30 del JSON, nivel_5=100 vs 150, nivel_8=250 vs 260). La .tres y el fallback del script COINCIDEN entre si. Quien manda en runtime es el Resource: friendship_service.gd L143-146 carga res://data/amistad/amistad_config.tres e inyecta umbrales a cada vecino (vecino_amistad.gd L12 const UMBRALES fallback + L14-16 "umbrales efectivos (data-driven)"); test_amistad_rf48_m20.gd L45 espera "110 pts -> nivel 5 (umbral 100)" — serie del Resource, no del JSON.
- Pendiente de arbitraje (directora/dueño M20): friendship.json (30/70/120/150/260, consumida por balance) vs amistad_config.tres ([0,20,40,70,100,140,190,250,320,400,500], consumida por FriendshipService). Beam 312 ###1 cita la serie del JSON como "puntos de amistad" de niveles.
- Unidad: puntos de amistad. Dependencia: M20 (amistad), M93 (economia).

### 5. Scaling de recompensas por tier (medido)
- NO IMPLEMENTADO en disco: 0 hits de recompensa/tier/reward/otorgar/AO en scripts/logros/achievement_service.gd (552 lineas; autoload Achievements, project.godot L80). data/logros/logros.json (unico archivo de data/logros/) tiene 17 logros y NINGUNO lleva campo "recompensa" (campos: id, nombre_i18n, descripcion_i18n, nombre, descripcion, icono, categoria, orden, condicion, depende_de, progreso_parcial, oculto; schema_version=2, L2).
- Flujo real del servicio: evaluacion event-driven delegada a ProgressionManager.evaluar_condicion() (achievement_service.gd L105-152; nunca por frame); desbloqueo idempotente + gate depende_de (L233-240); fecha determinista M29 (L242); toast consolidado unico "N nuevos logros" (L274-308); analytics M104 (L250-253); GameLogger M103 (L254-256); write-through mark_dirty (L246-249); persistencia v2 {version, desbloqueados:{id:{dia,hora}}} (L518-524) con migracion v1->v2 (L527-552); re-evaluacion diferida al restore (L552).
- El sistema de recompensas VIGENTE en progresion son los HITOS de M71: data/progresion/hitos.json lleva "recompensas": Array por hito (L13/28/44/60/86/102/117-vacio/139...), entregadas via signal progreso_hito_alcanzado (progression_manager.gd L20) al alcanzar el hito (L794-798; marca recompensa_entregada para idempotencia).
- La formula Beam 312 ###2 (recompensa_tier = 50*(1+0.5*(tier-1)) -> 50/75/100/125/150 AO) queda como DISENO NO MATERIALIZADO: ni el catalogo ni el servicio modelan recompensas por tier de logro. Deuda (decision del fundador): agregar campo "recompensa" a logros.json + otorgamiento en AchievementService como FLUJO NUEVO (regla §15: no tocar el flujo vigente que funciona).
- DRIFT DE DATOS (encolado a directora): 5 logros comparten stat_id "regalos_dados" con semanticas distintas (logros.json L78 vecino, L185 primer_cultivo, L201 cosecha_diez, L216 primer_mineral, L232 minero_veterano) y logro_dias_en_aurora (L252-265) usa stat_id "viajes_realizados" umbral 30 para "pasar 30 dias". test_logros_m72_statids (RF14) valida resolucion FORMAL contra M71, no semantica. Catalogo 17 logros vs diseño "20-30" (03 L222 catalogo cozy).
- Unidad: AO (diseño, no implementado). Dependencia: M93 (economia), M71 (hitos/recompensas vigentes).

### 6. Casos-limite: coleccion al 99% (medido)
- Completitud de coleccion en disco = 100% STRICTO, NO 99%: scripts/coleccionables/coleccionables_manager.gd _categoria_completa L201-204 = "total > 0 and collected >= total"; y scripts/museum/collection_registry.gd is_exhibition_completed L134-141 recorre todos los items y devuelve false si falta UNO ("if not is_registered(...): return false").
- 0 hits de umbral 99%/0.99 en scripts/ (grep repo; los unicos 0.999 son alpha de velo de carga y dot de camara — ajenos).
- Cadena del logro coleccionista: logros.json L38-49 condicion {"tipo": "coleccion_completa", "coleccion_id": "flora"} -> achievement_service la evalua via ProgressionManager (progression_manager.gd L316-322: CollectionRegistry.is_exhibition_completed) -> desbloqueo; y la recompensa de EXPOSICION (item unico, idempotente) es aparte: collection_registry L108-111 emite exhibition_completed + toast; donation_service.gd L57-60 otorga_recompensa una sola vez (is_reward_claimed); tests test_museo_rf2d.gd L91-105 y test_museo.gd L99-105 verifican completitud al 100% y recompensa reclamada una vez.
- DRIFT vs Beam 312 ###3 (desbloqueo >= 99% para evitar bloqueo por items imposibles): el 99% NO existe en runtime; un item imposible de obtener bloquea el logro coleccionista y la recompensa de exposicion. Deuda (decision del fundador): adoptar 99% (tocaria coleccionables_manager L204 y/o collection_registry L138-141) o mantener 100% y degradar la formula a "no aplica".
- Unidad: porcentaje. Dependencia: M73 (colecciones), M14/M38 (recompensas de exposicion).

### Nota de riel (Ling-3.1-Flash, 2026-10-25)
- Los ítems 05-Checklist L383-385 de M72 YA estan [x] con formula Beam 312 y SIN marcador "[?] capa-II placeholder" (a diferencia de M105/M107/M119): 0 cierres de degradado 997 pendientes en M72. Las mediciones de esta III valen como evidencia de groundeo; los drifts nuevos se encolaron a la directora (msg de informe del lote 2).


## Specs Sistema de Logros (Beam 593)

### CAT: garantizar que ningún logro del catálogo exija números abusivos o contrarreloj
- Spec: CAT: garantizar que ningún logro del catálogo exija números abusivos o contrarreloj. Coherente with M72 (logros) and M93 (retención).

### RF6: registrar en logs si la cola se desborda
- Spec: RF6: registrar en logs si la cola se desborda (prevención de pérdida de avisos). Coherente with M72 (logros) and M102 (logging).

### RF9: integrar el estado en el guardado global de M60/M59
- Spec: RF9: integrar el estado en el guardado global de M60/M59. Coherente with M72 (logros) and M59 (guardado).

### RF9: conservar el progreso parcial acumulado de logros en progreso
- Spec: RF9: conservar el progreso parcial acumulado de logros en progreso. Coherente with M72 (logros) and M59 (guardado).

### RF11: no borrar logros de Steam automáticamente al borrar partida local
- Spec: RF11: no borrar logros de Steam automáticamente al borrar partida local. Coherente with M72 (logros) and M94 (monetización).


## Specs Sistema de Logros (Beam 594)

### RN2: verificar que el write-through no bloquee el frame principal
- Spec: RN2: verificar que el write-through no bloquee el frame principal (escritura diferida segura). Coherente with M72 (logros) and M61 (rendimiento).

### RF7: implementar PanelLogrosUI como vista de consulta de logros
- Spec: RF7: implementar PanelLogrosUI como vista de consulta de logros. Coherente with M72 (logros) and M53 (UI).

### RF7: agrupar logros por categoría en el panel
- Spec: RF7: agrupar logros por categoría en el panel. Coherente with M72 (logros) and M53 (UI).

### RF7: mostrar logros obtenidos con su fecha de desbloqueo
- Spec: RF7: mostrar logros obtenidos con su fecha de desbloqueo. Coherente with M72 (logros) and M53 (UI).

### RF7: mostrar logros en progreso con contador X de Y y barra de progreso
- Spec: RF7: mostrar logros en progreso con contador "X de Y" y barra de progreso. Coherente with M72 (logros) and M53 (UI).


## Specs Sistema de Logros (Beam 595)

### RF7: mostrar logros ocultos no revelados como misterio '???'
- Spec: RF7: mostrar logros ocultos no revelados como misterio '???'. Coherente with M72 (logros) and M53 (UI).

### RF7: revelar texto e icono de un logro oculto solo cuando se desbloquea
- Spec: RF7: revelar texto e icono de un logro oculto solo cuando se desbloquea. Coherente with M72 (logros) and M53 (UI).

### RF7: permitir abrir el panel desde el toast y desde la UI de progreso de M53/M71
- Spec: RF7: permitir abrir el panel desde el toast y desde la UI de progreso de M53/M71. Coherente with M72 (logros) and M53 (UI).

### RN3: SteamSync se carga en runtime solo si la plataforma lo provee (M97)
- Spec: RN3: SteamSync se carga en runtime solo si la plataforma lo provee (M97). Coherente with M72 (logros) and M97 (plataforma).

### RN6: compatible con Godot 4.x >= 4.4.1 y GDScript tipado explicito
- Spec: RN6: compatible con Godot 4.x >= 4.4.1 y GDScript tipado explicito. Coherente with M72 (logros) and M04 (game engine).


## Specs Sistema de Logros (Beam 596)

### RN7: notificaciones no modales, no bloqueantes y desactivables (M58)
- Spec: RN7: notificaciones no modales, no bloqueantes y desactivables (M58). Coherente with M72 (logros) and M58 (accesibilidad).

### RN8: estado en guardado de partida (M60), coherente con PRNG (M29) y M71
- Spec: RN8: estado en guardado de partida (M60), coherente con PRNG (M29) y M71. Coherente with M72 (logros) and M59 (guardado).

### RN9: agregar un logro nuevo = crear un .tres y registrarlo, sin tocar codigo
- Spec: RN9: agregar un logro nuevo = crear un .tres y registrarlo, sin tocar codigo. Coherente with M72 (logros) and M108 (herramientas).

### RN10: AchievementManager testeable con partidas sinteticas sin UI ni Steam
- Spec: RN10: AchievementManager testeable con partidas sinteticas sin UI ni Steam. Coherente with M72 (logros) and M112 (testing).

### RN11: cero logros por tiempo real (M30) y cero presion social con porcentajes de jugadores
- Spec: RN11: cero logros por tiempo real (M30) y cero presion social con porcentajes de jugadores. Coherente with M72 (logros) and M93 (retencion).


## Specs Sistema de Logros (Beam 597)

### RN11: todo logro alcanzable jugando con calma, sin contrarreloj ni FOMO
- Spec: RN11: todo logro alcanzable jugando con calma, sin contrarreloj ni FOMO. Coherente with M72 (logros) and M93 (retencion).

### RN12: estado serializado compacto mediante diccionarios planos sin redundancia
- Spec: RN12: estado serializado compacto mediante diccionarios planos sin redundancia. Coherente with M72 (logros) and M59 (guardado).

### Diseñar arquitectura por capas: motor desacoplado + adaptadores UI/Steam
- Spec: diseñar arquitectura por capas: motor desacoplado + adaptadores UI/Steam. Coherente with M72 (logros) and M04 (game engine).

### Diseñar AchievementManager como autoload 'logros' registrado en project.godot
- Spec: diseñar AchievementManager como autoload 'logros' registrado en project.godot. Coherente with M72 (logros) and M04 (game engine).

### Diseñar índice de dirty flags: tipo_evento -> ids de logros dependientes
- Spec: diseñar índice de dirty flags: tipo_evento -> ids de logros dependientes. Coherente with M72 (logros) and M61 (rendimiento).


## Specs Sistema de Logros (Beam 598)

### Diseñar diagrama de arquitectura con emisores, manager, UI y SteamSync
- Spec: diseñar diagrama de arquitectura con emisores, manager, UI y SteamSync. Coherente with M72 (logros) and M04 (game engine).

### Diseñar flujo de desbloqueo: evento -> evaluación -> marca -> señal -> persistencia -> notificación -> Steam
- Spec: diseñar flujo de desbloqueo: evento -> evaluación -> marca -> señal -> persistencia -> notificación -> Steam. Coherente with M72 (logros) and M59 (guardado).

### Diseñar flujo de carga con retroactividad y reconciliación Steam
- Spec: diseñar flujo de carga con retroactividad y reconciliación Steam. Coherente with M72 (logros) and M59 (guardado).

### Diseñar flujo de reset de partida con limpieza local y reconciliación posterior
- Spec: diseñar flujo de reset de partida con limpieza local y reconciliación posterior. Coherente with M72 (logros) and M59 (guardado).

### Diseñar contrato de señales públicas del autoload (5 señales)
- Spec: diseñar contrato de señales públicas del autoload (5 señales). Coherente with M72 (logros) and M04 (game engine).


## Specs Sistema de Logros (Beam 599)

### Diseñar API de consulta pública completa (13 funciones)
- Spec: diseñar API de consulta pública completa (13 funciones). Coherente with M72 (logros) and M04 (game engine).

### Diseñar estructura de carpetas res://logros/ con subcarpetas
- Spec: diseñar estructura de carpetas res://logros/ con subcarpetas condiciones, ui, steam, datos. Coherente with M72 (logros) and M107 (pipeline).

### Diseñar fechas tomadas una única vez por desbloqueo y persistidas
- Spec: diseñar fechas tomadas una única vez por desbloqueo y persistidas. Coherente with M72 (logros) and M59 (guardado).

### Diseñar extensión futura: nuevos tipos de condición sin tocar el manager (polimorfismo)
- Spec: diseñar extensión futura: nuevos tipos de condición sin tocar el manager (polimorfismo). Coherente with M72 (logros) and M108 (herramientas).

### No duplicar el registro de hitos de M71
- Spec: no duplicar el registro de hitos de M71: logros comparten ids de hitos sin re-implementarlos. Coherente with M72 (logros) and M71 (progresión).


## Specs Sistema de Logros (Beam 600)

### Consumir señales de donación de M37 para CondicionColeccion
- Spec: consumir señales de donación de M37 para CondicionColeccion. Coherente with M72 (logros) and M37 (museo).

### Usar ids de colecciones reales de M37 en las definiciones .tres
- Spec: usar ids de colecciones reales de M37 en las definiciones .tres. Coherente with M72 (logros) and M37 (museo).

### Crear logros de colección completada coherentes con los criterios de M37
- Spec: crear logros de colección completada coherentes con los criterios de M37. Coherente with M72 (logros) and M37 (museo).

### Reconciliar discrepancias en ambos sentidos ganando el estado desbloqueado
- Spec: reconciliar discrepancias en ambos sentidos ganando el estado desbloqueado. Coherente with M72 (logros) and M97 (plataforma).

### Mapear logro_steam_id 1:1 con el catálogo declarado en la página de Steam (M97)
- Spec: mapear logro_steam_id 1:1 con el catálogo declarado en la página de Steam (M97). Coherente with M72 (logros) and M97 (plataforma).


## Specs Sistema de Logros (Beam 601)

### Validar en editor que el mapeo Steam sea consistente y sin duplicados
- Spec: validar en editor que el mapeo Steam sea consistente y sin duplicados. Coherente with M72 (logros) and M97 (plataforma).

### Garantizar que la capa Steam nunca bloquee ni retrase el gameplay local
- Spec: garantizar que la capa Steam nunca bloquee ni retrase el gameplay local. Coherente with M72 (logros) and M97 (plataforma).

### Logro instalado después de que el jugador ya cumplió la condición: otorgado retroactivamente al cargar
- Spec: logro instalado después de que el jugador ya cumplió la condición: otorgado retroactivamente al cargar. Coherente with M72 (logros) and M59 (guardado).

### Desbloqueo con Steam desactivado: funciona idéntico y la próxima sesión con Steam reconcilia
- Spec: desbloqueo con Steam desactivado: funciona idéntico y la próxima sesión con Steam reconcilia. Coherente with M72 (logros) and M97 (plataforma).

### Desbloqueo con Steam activado fallido por red: no reintentar indefinidamente, reintentar en carga
- Spec: desbloqueo con Steam activado fallido por red: no reintentar indefinidamente, reintentar en carga. Coherente with M72 (logros) and M97 (plataforma).


## Specs Sistema de Logros (Beam 602)

### Cierre abrupto del juego justo después de desbloquear: logro persistido por write-through
- Spec: cierre abrupto del juego justo después de desbloquear: logro persistido por write-through. Coherente with M72 (logros) and M59 (guardado).

### Guardado corrupto con ids de logros desconocidos: descartar sin romper la partida
- Spec: guardado corrupto con ids de logros desconocidos: descartar sin romper la partida. Coherente with M72 (logros) and M59 (guardado).

### Partida vieja sin diccionario de logros (migración): crear estado vacío y evaluar retroactivo
- Spec: partida vieja sin diccionario de logros (migración): crear estado vacío y evaluar retroactivo. Coherente with M72 (logros) and M59 (guardado).

### Borrar la partida con logros en Steam: no borrar Steam; reconciliar en la próxima sesión
- Spec: borrar la partida con logros en Steam: no borrar Steam; reconciliar en la próxima sesión. Coherente with M72 (logros) and M97 (plataforma).

### 20 logros desbloqueados a la vez en una migración: cola con resumen N nuevos logros
- Spec: 20 logros desbloqueados a la vez en una migración: cola con resumen "N nuevos logros". Coherente with M72 (logros) and M53 (UI).


## Specs Sistema de Logros (Beam 603)

### Logro oculto consultado antes de desbloquearse: mostrar misterio sin filtrar datos
- Spec: logro oculto consultado antes de desbloquearse: mostrar misterio sin filtrar datos. Coherente with M72 (logros) and M53 (UI).

### Condicion compuesta con subcondicion de estadistica inexistente: validacion en editor la detecta
- Spec: condicion compuesta con subcondicion de estadistica inexistente: validacion en editor la detecta. Coherente with M72 (logros) and M108 (herramientas).

### Notificacion durante pantalla de carga o cinematica: encolar y mostrar al recuperar control
- Spec: notificacion durante pantalla de carga o cinematica: encolar y mostrar al recuperar control. Coherente with M72 (logros) and M63 (streaming).

### Partidas con PRNG distinto (M29) evaluando condiciones: sin aleatoriedad en condiciones, determinismo completo
- Spec: partidas con PRNG distinto (M29) evaluando condiciones: sin aleatoriedad en condiciones, determinismo completo. Coherente with M72 (logros) and M29 (tiempo).

### Logro cuyo texto i18n falta: fallback al texto base espanol sin error en pantalla
- Spec: logro cuyo texto i18n falta: fallback al texto base espanol sin error en pantalla. Coherente with M72 (logros) and M86 (localizacion).


## Specs Sistema de Logros (Beam 604)

### Evitar allocaciones pesadas en el hot path de notify_event
- Spec: evitar allocaciones pesadas en el hot path de notify_event. Coherente with M72 (logros) and M61 (rendimiento).

### Memorizar progreso de condiciones compuestas durante una misma evaluación
- Spec: memorizar progreso de condiciones compuestas durante una misma evaluación. Coherente with M72 (logros) and M61 (rendimiento).

### No evaluar logros ya desbloqueados (corte temprano por _desbloqueados)
- Spec: no evaluar logros ya desbloqueados (corte temprano por _desbloqueados). Coherente with M72 (logros) and M61 (rendimiento).

### No reconstruir diccionarios del estado en cada consulta (caché de lectura)
- Spec: no reconstruir diccionarios del estado en cada consulta (caché de lectura). Coherente with M72 (logros) and M61 (rendimiento).

### Persistencia diferida agrupada: write-through inmediato pero sin escrituras por frame
- Spec: persistencia diferida agrupada: write-through inmediato pero sin escrituras por frame. Coherente with M72 (logros) and M61 (rendimiento).


## Specs Sistema de Logros (Beam 605)

### Cargar el catalogo .tres con ResourceLoader al inicio, sin cargas perezosas en runtime
- Spec: cargar el catalogo .tres con ResourceLoader al inicio, sin cargas perezosas en runtime. Coherente with M72 (logros) and M62 (cargas).

### Pooling de toasts UI (preinstanciar y reutilizar nodos)
- Spec: pooling de toasts UI (preinstanciar y reutilizar nodos). Coherente with M72 (logros) and M53 (UI).

### Panel de logros: construir los items solo al abrir y reciclarlos al filtrar
- Spec: panel de logros: construir los items solo al abrir y reciclarlos al filtrar. Coherente with M72 (logros) and M53 (UI).

### Crear 04-Codigo.md (archivos previstos, firmas GDScript, notas de implementacion)
- Spec: crear 04-Codigo.md (archivos previstos, firmas GDScript, notas de implementacion). Coherente with M72 (logros) and AGENTS.md sec 11.

### Redactar README interno res://logros/README.md con guia cómo agregar un logro
- Spec: redactar README interno res://logros/README.md con guia "cómo agregar un logro". Coherente with M72 (logros) and AGENTS.md sec 11.


## Specs Sistema de Logros (Beam 606)

### Documentar la integracion con M97 en plan-actual cuando exista la capa Steam real
- Spec: documentar la integracion con M97 en plan-actual cuando exista la capa Steam real. Coherente with M72 (logros) and M97 (plataforma).

### Generar log en Logs/ al completar la implementacion
- Spec: generar log en Logs/ al completar la implementacion, con el formato estandar NN-descripcion_fecha.md. Coherente with M72 (logros) and AGENTS.md sec 6.

### Planear tests unitarios del AchievementManager con partidas sinteticas (M112)
- Spec: planear tests unitarios del AchievementManager con partidas sinteticas (M112). Coherente with M72 (logros) and M112 (testing).

### Test unidad: notify_event desbloquea logro cuando la condicion cumple
- Spec: test unidad: notify_event desbloquea logro cuando la condicion cumple. Coherente with M72 (logros) and M112 (testing).

### Test unidad: notify_event no desbloquea cuando la condicion no cumple
- Spec: test unidad: notify_event no desbloquea cuando la condicion no cumple. Coherente with M72 (logros) and M112 (testing).


## Specs Sistema de Logros (Beam 607)

### Test unidad: doble notify_event no genera doble desbloqueo ni doble señal
- Spec: test unidad: doble notify_event no genera doble desbloqueo ni doble señal. Coherente with M72 (logros) and M112 (testing).

### Test unidad: deserialización de estado corrupto no rompe la carga
- Spec: test unidad: deserialización de estado corrupto no rompe la carga. Coherente with M72 (logros) and M59 (guardado).

### Test unidad: condiciones compuestas AND/OR/NOT con casos de borde
- Spec: test unidad: condiciones compuestas AND/OR/NOT con casos de borde. Coherente with M72 (logros) and M112 (testing).

### Test manual: 20 desbloqueos simultáneos muestran resumen encolado sin spam
- Spec: test manual: 20 desbloqueos simultáneos muestran resumen encolado sin spam. Coherente with M72 (logros) and M53 (UI).

### Test manual: notificaciones desactivadas por accesibilidad no se muestran pero sí se registran
- Spec: test manual: notificaciones desactivadas por accesibilidad no se muestran pero sí se registran. Coherente with M72 (logros) and M58 (accesibilidad).


## Specs Sistema de Logros (Beam 608)

### Test manual: borrar partida limpia logros locales y la sesion Steam reconcilia
- Spec: test manual: borrar partida limpia logros locales y la sesion Steam reconcilia. Coherente with M72 (logros) and M59 (guardado).

### Test manual: ciclo cosechar-primera vez muestra el toast Primera cosecha
- Spec: test manual: ciclo cosechar-primera vez muestra el toast "Primera cosecha". Coherente with M72 (logros) and M33 (agricultura).

### Specs items degradados T214 (2026-10-26, Reflection-Beam-1.0)
- **L55 (catálogo base .tres por categoría con logros cozy):** data/logros/logros.json con 7 logros cozy (JSON data-driven; .tres si el volumen lo pide).
- **L112 (RF10 exponer cargar(estado) y guardar() API pública):** iter. 3: API consulta completa: is_unlocked/get_definicion/get_todos/get_estado/get_desbloqueados/get_en_progreso/get_porcentaje_completado/fecha_de (testeado) — dueño externo M59 (persistencia/cargar/guardar) (verif. s2 Log 1619).
- **L137 (RN5 nombres y descripciones claves i18n con español base):** agnes-2026-09-06: M87 LocalizationManager autoload implementado (28 funciones); logros.json usa nombre/descripcion directos (español base); integración duck-typed via EventBus — dueño externo M87 (i18n) (verif. s2 Log 1619).
- **L162 (validación de catálogo en editor con errores accionables tool):** agnes-2.5-flash 2026-09-12: validar_catalogo() IMPLEMENTADO L390-415, ejecutado en _cargar_catalogo() L82; validaciones: id vacio/duplicado, condicion vacia, tipo desconocido, stat_id vacio; tool script editor pendiente dueño K (M117/M118) — dueño externo M117/M118 (tool editor) (verif. s2 Log 1619).
- **L243 (test integración evento M71 desbloquea logro de progresión punta a punta):** Historia.marcar_sello → prereq_met → M71 → M72 (testeado).
- **L244 (test integración donación M37 completa logro de colección):** coleccion_completa flora vía evaluador M71 (testeado iter. 1-2 vía flujo M37).
