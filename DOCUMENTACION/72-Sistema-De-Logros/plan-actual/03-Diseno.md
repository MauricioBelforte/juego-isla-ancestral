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

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 1 | Umbrales de desbloqueo por nivel de amistad | 30/70/120/150/260 | De friendship.json (coherente con M20). Logros por nivel: 3-5 por nivel. |
| 2 | Curva de growth por stat | 1.0 + 0.15 * nivel | Lineal, coherente con M16 RF-MR4. Max nivel 10 -> 2.5x. |
| 3 | Recompensas de oro por logro (suma total) | ~750 AO one-time | Mision principal 200 + sello 500 + secundaria 50 = 750. vs economia diaria 80 AO = 9.4 dias. Razonable. |
| 4 | Tabla de XP por logro (suma vs curva) | 2790 XP (ILUSTRATIVO: 93 logros x 30 XP) — PENDIENTE DE CATALOGO FINAL | Curva de nivel: 100 niveles x 100 XP = 10000 XP. Ratio 27.9% SOLO si el catalogo final es 93 logros. AUDITORIA 2026-10-23: CAT-1 define catalogo base de 20-30 logros; la cifra 93 no tiene fuente en el doc (inconsistencia interna). Con 20-30 logros: 600-900 XP (6-9% de la curva). |
| 5 | KPI: % logros completados por jugador cozy | 60-70% | Orden de magnitud razonable para un jugador cozy (no completionist). |


## Presupuestos numericos — catalogo cozy y specs (Reflection-Beam-1.0, 2026-10-23)

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
- Valores de diseño FIJOS (30/70/120/150/260): los incrementos reales (30/40/50/30/110) NO siguen un factor geometrico; la formula `umbral_nivel = base + (umbral_anterior*0.5)` era falsa (Hy3 343: no produce la serie; corregido por director — serie queda FIJA tal como esta, sin formula derivable; si el diseño futuro la necesita, se define nueva regla y se cita aquí).
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
- **PAQ-3 (H23)**: "max 100 cosechas" del catalogo cozy = **ACUMULADO** (no por sesion). El catalogo de logros de M72 cuenta cosechas acumuladas a lo largo de toda la partida, no por sesion. Coherente con M93 (economia) y M34 (pesca). Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".

