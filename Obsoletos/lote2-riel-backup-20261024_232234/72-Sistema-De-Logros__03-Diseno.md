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