**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Modulo 34: Pesca

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
