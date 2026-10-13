class_name Contratos
extends RefCounted

## M40 (Infraestructura) — Contratos centralizados del ServiceRegistry.
##
## Antes de este archivo, los 47 contratos estaban como strings literales
## dispersos: 35 en el `register()` de cada servicio y 12 en el diccionario
## `_autoregistrar_dominios()` de `bootstrap.gd`. Un typo en cualquiera de esos
## strings era indetectable en tiempo de compilación.
##
## Uso:
##   ServiceRegistry.register(Contratos.ANALYTICS, self)
##   var svc = ServiceRegistry.get_service(Contratos.ECONOMY_MANAGER)
##
## Regla: todo contrato nuevo se agrega AQUÍ primero. No se aceptan strings
## literales en `register()` / `get_service()` fuera de este archivo.

# ── CORE (los 4 autoloads de infraestructura) ─────────────────────────
const SERVICE_REGISTRY := &"service_registry"
const EVENT_BUS := &"event_bus"
const LOGGER := &"logger"

# ── Dominios de juego (registrados por bootstrap.gd) ──────────────────
const ECONOMY_MANAGER := &"economy_manager"
const SHOP_MANAGER := &"shop_manager"
const EVENT_MANAGER := &"event_manager"
const INVENTARIO := &"inventario"
const BALANCE := &"balance"
const TIME_CALENDAR := &"time_calendar"
const FARM := &"farm"
const FISHING := &"fishing"
const DIALOGUE_MANAGER := &"dialogue_manager"
const CRAFTING := &"crafting"
const GAME_FLOW := &"game_flow"
const SCENE_MANAGER := &"scene_manager"

# ── Servicios que se auto-registran ───────────────────────────────────
const ANALYTICS := &"analytics"
const TELEMETRY := &"telemetry"
const AMBIENT := &"ambient"
const MUSIC := &"music"
const SFX := &"sfx"
const FEEDBACK := &"feedback"
const NARRATIVE_SOUND := &"narrative_sound"
const BACKUP := &"backup"
const BUILD := &"build"
const CICD := &"cicd"
const COMMUNITY := &"community"
const CRASH := &"crash"
const DATOS := &"datos"
const DEBUG_MENU := &"debug_menu"
const DEVTOOLS := &"devtools"
const DLC := &"dlc"
const FONTS := &"fonts"
const HARDWARE := &"hardware"
const HOUSE_MANAGER := &"house_manager"
const INSTALADOR := &"instalador"
const LOCALIZACION := &"localizacion"
const MAPA := &"mapa"
const MEMORIA := &"memoria"
const MERCH := &"merch"
const MODDING := &"modding"
const MOTIVACION := &"motivacion"
const PLATAFORMAS := &"plataformas"
const SECURITY := &"security"
const SUPPORT := &"support"
const UGC := &"ugc"
const UPDATES := &"updates"
const WORLD := &"world"


## Lista completa de contratos conocidos, para validación de integridad.
## Orden: CORE, dominios de juego, servicios auto-registrados.
const TODOS: Array[StringName] = [
	SERVICE_REGISTRY, EVENT_BUS, LOGGER,
	ECONOMY_MANAGER, SHOP_MANAGER, EVENT_MANAGER, INVENTARIO, BALANCE,
	TIME_CALENDAR, FARM, FISHING, DIALOGUE_MANAGER, CRAFTING, GAME_FLOW,
	SCENE_MANAGER,
	ANALYTICS, TELEMETRY, AMBIENT, MUSIC, SFX, FEEDBACK, NARRATIVE_SOUND,
	BACKUP, BUILD, CICD, COMMUNITY, CRASH, DATOS, DEBUG_MENU, DEVTOOLS, DLC,
	FONTS, HARDWARE, HOUSE_MANAGER, INSTALADOR, LOCALIZACION, MAPA, MEMORIA,
	MERCH, MODDING, MOTIVACION, PLATAFORMAS, SECURITY, SUPPORT, UGC, UPDATES,
	WORLD,
]


## ¿El string dado corresponde a un contrato conocido?
## Protege contra typos: `get_service("analytic")` devuelve false aquí.
static func es_contrato_valido(contrato: String) -> bool:
	for c in TODOS:
		if String(c) == contrato:
			return true
	return false
