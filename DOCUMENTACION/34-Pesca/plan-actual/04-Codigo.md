**Modelo:** GLM-5.3 (último modificador — iter. 2; bonos clima por glm-5.3-flash; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

# 04-Codigo.md — Modulo 34: Pesca

## 0. Rutas REALES del código (auditoría iter. 2 — corrige §1, que era aspiracional)

```
game/isla-ancestral/scripts/fishing/
├── fishing_manager.gd       # autoload "Fishing" (project.godot L68) — 306 líneas
├── fishing_session.gd       # FSM del minijuego — 104 líneas
├── fishing_spot.gd          # Node3D spot (stub M51) — 42 líneas
├── fish_definition.gd       # FishDefinition (Resource) — 24 líneas
├── cebo_definition.gd       # CeboDefinition (Resource) — 15 líneas
├── fishing_rod.gd           # FishingRod (Resource) — 18 líneas
├── test_fishing.gd          # suite núcleo + iter. 2 (7 bloques, 0 fallos)
└── test_fishing_clima.gd    # suite bonos clima (Log 310, 0 fallos)

game/isla-ancestral/data/balance/fishing.json   # tabla M93 (SOLO 2 peces: sardina + luna)
```

⚠️ Las rutas `res://_Project/...` de §1 son del DISEÑO original; el código real vive en `scripts/fishing/` con data en `data/balance/` (JSON en vez de .tres — decisión del núcleo, §1 queda como histórico). Los archivos `FishingMinigameUI.gd`/`FishingHud.gd`/`FishCollectionData.gd` NO existen: la colección es un Dictionary del manager (persistido por M59) y la UI es [?] M53.

## 0b. Firmas REALES (auditoría iter. 2 — corrige §2, que era aspiracional)

```gdscript
# fishing_manager.gd (autoload "Fishing") — señales reales:
signal picada_iniciada(sesion)
signal captura_exitosa(pez, tamano: float)
signal captura_fallida(motivo: String)
signal sesion_terminada(sesion)

func registrar_spot(spot) / desregistrar_spot(spot)
func spot_apunta_desde(_origen, _direccion, _rango)          # stub M51 (primer spot)
func iniciar_sesion(spot, cana: FishingRod, cebo: CeboDefinition = null) -> Node
func resolver_especie(_spot, cebo: CeboDefinition = null) -> FishDefinition
func _candidatas_de_estacion(estacion: int, hora: int = 12) -> Array   # NUEVO iter. 2 (testable)
func _peso_efectivo(pez: FishDefinition, cebo: CeboDefinition = null) -> float  # Log 310
func _clima_actual_m32() -> int / _clima_m32_a_m34(clima_m32: int) -> int
func registrar_captura(pez, tamano: float) / get_collection_data() -> Dictionary
func entrega_museo(_pez) -> bool                              # compat CollectionRegistry M37
func get_section_name() -> "fishing" / get_save_data / restore_save_data  # M59
```

`_filtrar_candidatas`/`_seleccionar_por_peso`/`_voxel_es_agua` de §2 NO existen (eran diseño); sus roles los cumplen `_candidatas_de_estacion` + el roll ponderado inline de `resolver_especie` + el stub `es_agua_pescable` del spot. `iniciar_espera`/`_entrar_minijuego`/`_resolver_captura` de la sesión son `lanzar(prng)`/`notificar_pulsacion_boton`/flujo del manager `_on_estado_sesion`.

## 1. Rutas de archivos (res://)

```
res://_Project/Scripts/Fishing/
├── FishingManager.gd            # Autoload "Fishing" (orquestador)
├── FishingSession.gd            # Maquina de estados del minijuego
├── FishingSpot.gd               # Nodo 3D por chunk de agua M51
├── FishingRod.gd                # Resource: stats de la cana
├── FishDefinition.gd            # Resource: tabla de especie
├── CeboDefinition.gd            # Resource: cebo
└── FishCollectionData.gd        # Resource de partida: coleccion y estadisticas

res://_Project/UI/Fishing/
├── FishingMinigameUI.gd         # UI del minijuego (solo senales)
└── FishingHud.gd                # Indicador de espera y resultado

res://_Project/Data/Fishing/     # Instancias .tres (definiciones)
├── Fish_SardinadeRio.tres
├── Fish_CalamarLunar.tres
├── Fish_PezAncestral.tres
├── ... (una por especie, ~25 base)
├── Cebo_Gusano.tres
├── Cebo_Pan.tres
├── Cebo_Insecto.tres
├── Cebo_Dorado.tres
├── Rod_Ancia.tres               # cana vieja
├── Rod_MaderaAncestral.tres
└── Rod_CanaDeidad.tres
```

Namespace GDScript: `IslaAncestral/Fishing` (prefijo de clases). Los `.tres` se referencian desde el proyecto (no se crean en runtime excepto el de partida).

## 2. Firmas clave (GDScript, Godot 4.x)

```gdscript
# --- FishingManager.gd (autoload "Fishing") ---
# Determina spot valido desde el rayo del jugador
func spot_apunta_desde(origen: Vector3, direccion: Vector3, rango: float) -> FishingSpot

# Inicia la sesion completa (lanza flotador y espera)
func iniciar_sesion(spot: FishingSpot, cana: FishingRod) -> FishingSession

# Tabla -> candidatas filtradas por bioma/estacion/franja/clima
func _filtrar_candidatas(spot: FishingSpot) -> Array[FishDefinition]

# Seleccion ponderada con PRNG de partida (M29)
func _seleccionar_por_peso(candidatas: Array[FishDefinition], cebo: CeboDefinition) -> FishDefinition

# Registro de captura en coleccion y estadisticas
func registrar_captura(pez: FishDefinition, tamano: float) -> void

# Entrega a M37: marca pieza del museo como disponible
func entrega_museo(pez: FishDefinition) -> bool

# --- FishingSpot.gd ---
# Validacion bajo demanda de voxels (tipo AGUA + aire encima + orilla)
func es_agua_pescable() -> bool

# Consulta al chunk voxel de M51 (VoxelTool::get_voxel para el tipo)
func _voxel_es_agua(pos: Vector3i, chunk: VoxelWorld) -> bool

# --- FishingSession.gd ---
# Estados de la FSM del minijuego
enum Estado { IDLE, LANZANDO, ESPERA_PICADA, PICADA, MINIJUEGO, CAPTURA, ESCAPE }

func iniciar_espera() -> void          # timer pausable con GameClock (M29)
func notificar_pulsacion_boton() -> void  # fase A y fase B
func _entrar_minijuego() -> void
func _resolver_captura() -> void       # tamano por PRNG en [min, max]
func cancelar(motivo: String) -> void  # p.ej. chunk descargado (sin castigo)

# --- FishCollectionData.gd (Resource de partida) ---
func marcar_captura(id_pez: String, tamano: float) -> void
func get_mejor_tamano(id_pez: String) -> float
func cantidad_total_capturas() -> int
func piezas_entregadas_por_captura(id_pez: String) -> bool

# --- FishingMinigameUI.gd ---
# Solo se conecta a senales del manager/sesion; nunca accede a voxels ni M14
func _on_picada_iniciada(sesion: FishingSession) -> void
func _on_ventana_activa(inicio_ventana: float, duracion: float) -> void
func _on_captura_exitosa(pez: FishDefinition, tamano: float) -> void
func _on_captura_fallida(motivo: String) -> void
```

## 3. Consideraciones de implementacion

- **Voxel Tools (GDExtension):** la validacion de agua usa la API voxel del mundo M51 (VoxelTool / get_voxel) con coordenadas del chunk; nunca PhysicsDirectSpaceState por colliders sueltos.
- **Timers:** en FishingSession usar `SceneTreeTimer` pausables o timers bajo el arbol que congela GameClock (M29); el reloj del minijuego y la espera deben congelarse al pausar.
- **PRNG:** un `RandomNumberGenerator` por partida sembrado desde M29 (seed de partida) para especies y tamanos deterministas; los tests usan semilla fija.
- **Pooling de spots:** los FishingSpot se crean con el chunk M51 y se desregistran al liberarlo; la sesion activa en un chunk liberado se cancela siempre como ESCAPE (regla 3 anti-frustracion).
- **UI desacoplada:** el HUD no muestra datos crudos de la sesion; solo consume senales (`picada_iniciada`, `ventana_activa`, `captura_exitosa`, `captura_fallida`).
- **Guardado:** FishCollectionData es un Resource serializable incluido en los datos de partida (formato M58); los `.tres` de definiciones no se modifican en runtime.

## 4. Logs

- **Formato de mensajes:** prefijo `[PESCA]` en todos los Debug: `[PESCA] sesion iniciada en spot (bioma=mar)`, `[PESCA] especie dividida: calamar-lunar (peso 4.0)`, `[PESCA] captura ok: sardina-de-rio 0.42 m -> M14`, `[PESCA] escape: chunk liberado (sin castigo)`.
- **Niveles:** `Debug.log` (flujo normal), `Debug.push_warning` (`push_warning`) para condiciones inesperadas (spot sin agua, tabla vacia), `push_error` solo en errores reales (nunca para fallos del jugador).
- **Persistencia (AGENTS seccion 18):** sin logs dentro de `Assets/`; si se requiere telemetria de pesca (especies capturadas por sesion), se escribe fuera del proyecto con rotacion `NN-pesca-YYYY-MM-DD.log` en `logs/rotated/`.
- **Debug builds:** los logs se compilan solo con `#if TOOLS` o canal de debug para no penalizar release.
- **Telemetria de balance:** cada captura registra (especie, tamano, estacion, franja, clima, cebo, cana) para ajustar pesos sin afectar determinismo (tabla en `07-Resultados-Testings.md` si se ejecuta plan de testings).

---

## Notas del Agente — Iteración bonos clima M32→M34 (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 23:40:00
**Estado:** Parcial (bonos de clima implementados y verificados; módulo liberado 🟡)

### Lo que hice
- Bono de clima en `resolver_especie` (checklist P5/"clima M32" del núcleo): el cálculo de peso se extrajo a `_peso_efectivo(pez, cebo)` (testeable, sin roll) y añade el factor clima consultando `/root/Weather.get_clima()` (M32).
- Reglas (diseño M32 §6 / "bono sí, bloqueo no"): LLUVIA → peso ×1.15 y TROPICAL → ×1.25 para peces que (a) declaran preferencia en el JSON `"clima"` (campo cargado por el núcleo pero SIN USAR hasta hoy) o (b) son raros (`peso_rareza <= UMBRAL_RARO = 0.08`). El clima NUNCA filtra especies (§6 "nunca prohibida") y el peso efectivo nunca es 0.
- Conversión `_clima_m32_a_m34()`: el enum de M32 (0-8) al formato numérico del JSON de Deepseek (0=despejado, 1=lluvia, 2=tormenta, 3=nieve) que usa `FishDefinition.climas`. Neutro (-1) si Weather no existe (headless/menú).
- Test `scripts/fishing/test_fishing_clima.gd`: conversión de enums, bono por preferencia (soleado base/lluvia ×1.15), bono por rareza (lluvia/tropical), preferente-de-lluvia NO raro bajo tropical queda en base (según diseño), "nunca prohibida" (catálogo completo con peso > 0 en 5 climas + resolver nunca null) → **0 fallos**.
- Regresiones: test_fishing.gd (núcleo Deepseek) **0 fallos**, test_clima.gd (M32) **0 fallos**.
- Checklist: 4 ítems marcados (dependencias M32, P5 clima, FishDefinition arrays, clima-actual-M32).

### Lo que NO pude hacer (honestidad obligatoria)
- "tropical" no está mapeado en `_clima_numero` de Deepseek (cae en 0=despejado): si el JSON llega a tener peces con "clima": ["tropical"], conviene agregar el caso → M34 valor 4 y su bono. No lo toqué (función del núcleo ajeno; hoy no hay datos que lo usen).
- Peces estacionales: todos los del JSON actual filtran por temporada, así que el test "nunca prohibida" valida pesos por clima (determinista), no aparición estadística (evita flakiness).
- Voxels M51, flotador físico + UI minijuego M53, museo M37, cebos M93: con dueño.

### Recomendaciones para el próximo agente
- M53 (flotador/UI): la intensidad de lluvia (M32 `get_intensidad()`) puede modular VFX de picada.
- Si se agregan peces "tropical" al JSON, extender `_clima_numero` y el bono en `_peso_efectivo` (caso clima 4).

---

## Notas del Agente — Iteración 2: auditoría doc↔código + 3 brechas V0 (GLM-5.3)

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-12 03:05
**Estado:** Parcial-liberado (auditoría completa + brechas cerradas; módulo queda 🟡 por los 69 [?] con dueño externo)

### Lo que hice
1. **Auditoría doc↔código completa (patrón M29/M31/M32):** 05-Checklist 4 → **84 [x]** / 69 [?] / 0 [ ] con evidencia por ítem (líneas de código, tests, secciones de diseño). El gap de marcado era total: FSM completa, persistencia M59, bonos, anti-frustración y colección existían desde Log 297/310 sin marcar.
2. **Fix bug crítico `temporadas: ["todas"]`:** en `_cargar_peces`, `_estacion_numero("todas")` devolvía -1 → `pez.estaciones = [-1]` NUNCA matcheaba una estación real 0-3 → TODOS los peces "todas" caían SIEMPRE al fallback "todas las especies" de `resolver_especie` (el filtro de estación estaba ROTO; cozy de accidente). Fix: si `temporadas` contiene "todas" → estaciones VACÍAS (= todas, contrato FishDefinition L14). Test: `_test_iter2_estaciones_todas` + E2E `_test_iter2_filtro_estacion_verano` (sardina candidata en las 4 estaciones POR REGLA; luna SOLO en verano — el filtro real ahora discrimina).
3. **Fix bug `horas` de 2 valores:** `horas: [4, 20]` solo usaba la PRIMERA (`franjas = [ALBA-de-la-4]`); la hora 20 se descartaba. Fix: cada hora mapea a su franja sin duplicados (`4→NOCHE, 20→ATARDECER` — ojo: 4 es NOCHE porque `_franja_de_hora` usa `<5 = NOCHE`, corregí mi propia confusión del archivo de contexto 04 que decía "ALBA"). Test: `_test_iter2_franjas_horas`.
4. **Fix PRNG semilla M29 H120:** `hash(Time.get_ticks_usec())` (entropía runtime, NO determinista por partida — violaba E.11/F.7 y §95 del diseño) → `GameTime.rng_diario("m34")` (semilla de partida + día + namespace, patrón canónico del Log 824). Fallback: semilla 0 estable si GameTime no existe. Test: `_test_iter2_prng_semilla_m29` (secuencia reproducible mismo día, namespace aislado de otros consumidores).
5. **Extracción `_candidatas_de_estacion(estacion, hora)`:** el filtro de `resolver_especie` extraído a función testeable (patrón `_peso_efectivo` del Log 310). El clima sigue NUNCA filtrando (§6 M32).
6. **04-Codigo saneado:** §0 rutas/firmas REALES (las de §1/§2 eran aspiracionales del diseño — `FishingMinigameUI.gd` etc. no existen).
7. **Saneamiento de infraestructura (§28):** 3 BOM UTF-8 eliminados de .gd preexistentes (achievement_service, player_profile, progression_manager — se colaron en la sesión de otro agente); CHECKLIST-GLOBAL.md saneado de mojibake masivo (810 runs doble-codificados por escritura cp1252 — script nuevo `scripts/saneamiento_utf8.py` reutilizable con --dry-run/--backup).

### Tests (QA numérico, Godot 4.7.2 headless)
- `test_fishing.gd` **0 fallos** (7 bloques: núcleo + 4 nuevos iter. 2)
- `test_fishing_clima.gd` **0 fallos** (regresión bonos)
- Regresión: `test_semilla_iter1` 25/25 (M29), `test_consumidores_tiempo` 12/0, `test_logros` 0 fallos (M72 consume captura_exitosa — intacto), `test_clima` 0 fallos (M32)

### Lo que NO pude hacer (honestidad obligatoria)
- **[?] con dueño** (69 ítems): M51 voxels/biomas/orilla (es_agua_pescable es stub true), M52 flotador RigidBody3D+VFX, M53 UI completa (7 ítems H + HUD), M42 sonidos, M93 data (solo 2 peces vs 25 del diseño + 0 cebos/cañas — NO expandí el JSON: data = dueño M93), M14 item pez al capturar (solo se REMUEVE cebo, no se AÑADE pez), M105 evento de telemetría de pesca, M57 accesibilidad, M15 recetas, M37 catálogo/recompensa.
- **VAL-DGV new_level** (10 push_error en test_logros): PREEXISTENTE de M22/M71 — `data/dialogues/reaccion_nivel.json` usa clave "new_level" que el validador de diálogo no reconoce como clave de mundo. NO es de M34, no lo toqué (regla de no pisar módulos ajenos). Registrar en 11-BUGS.md si lo toma otro agente.
- **Festival con bono de capturas (F.10):** M29 tiene proximos_eventos pero M34 no consume evento_activado; requiere decisión de diseño del bono + eventos reales en festivals.tres → [?] conjunto.

### Decisiones
- **NO expandí fishing.json** (23 peces faltantes, cebos, cañas): el data de balance es dueño M93 (tabla M93 según CHECKLIST-GLOBAL); el parser M34 está listo para 25+ peces data-driven.
- **Doble pulsación fase A (J.7):** la FSM ya lo maneja por estructura (match por estado); lo marqué [x] por análisis del código, no por test runtime de doble-click.
- **precio_compra del JSON se descarta** (FishDefinition no tiene campo compra): decisión del núcleo; si M93 quiere compra de cebos/cañas, el campo va en su tabla.

### Recomendaciones para el próximo agente
- **M93-Balance (relevo §21.4.7 listo):** con el contexto fresco de fishing.json (formato, 2 peces, claves), la iter. 3 de M93 debería completar el catálogo de pesca (25 peces + 4 cebos + 3 cañas) respetando: `temporadas` ("todas" o lista), `horas` (array de horas 0-23, todas mapean), `clima` (nombres), `probabilidad`, `pity`, `peso_kg` [min,max], `precio_venta`.
- **M51/M52/M53:** es_agua_pescable es el punto de integración voxel; las señales del manager (4) + sesión (3) son el contrato completo de UI; el stub `spot_apunta_desde` devuelve el primer spot (sin raycast real).
- **QA cruzado §21.8 (verificador: Hy3, NO auto-verificar):** puntos rápidos → test_fishing.gd 0 fallos (bloques iter2: `_test_iter2_estaciones_todas`/`_test_iter2_franjas_horas`/`_test_iter2_prng_semilla_m29`/`_test_iter2_filtro_estacion_verano`), test_fishing_clima 0 fallos, fishing_manager.gd L33-38 (rng_diario) + L72-82 (fix todas) + L63-68 (fix horas).
- **Si tocás M34 de nuevo:** _franja_de_hora NO devuelve ALBA para hora 4 (es NOCHE, `<5`); ATARDECER es 17-20; ALBA solo 5-6.
