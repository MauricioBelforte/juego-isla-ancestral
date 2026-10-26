**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” Modulo 34: Pesca

# 1. Arquitectura (por capas)

```
Vista (UI)              FishingMinigameUI.gd  /  FishingHud.gd   (puro: solo escucha senales)
                            |
Servicio (autoload)     FishingManager.gd  (orquesta sesiones, tablas, PRNG M29)
                            |
Gameplay                FishingSession.gd (maquina de estados del minijuego)
                        FishingRod.gd (Resource: stats de la cana)
                        FishingSpot.gd (Node3D: agua voxel valida M51, autorregistrado)
                            |
Datos (Resources)       FishDefinition.gd (.tres)   CeboDefinition.gd (.tres)
                        FishCollectionData.gd (progreso coleccion)
                            |
Integracion             M51 Agua (voxels)  M29/M31/M32 (tiempo/clima)  M14 (inventario)  M37 (museo)
```

Reglas de capas (AGENTS seccion 9): la UI nunca toca voxels ni M14; el manager expone API publica; los Resources son datos puros.

# 2. Clases y Responsabilidades

# 2.1 FishingManager (autoload `Fishing`)
- Registro de spots vivos (`FishingSpot` por chunk M51).
- Resolucion de especie: filtra `FishDefinition` por bioma, estacion M29, franja M31, clima M32 y cebo; elige por PRNG ponderado M29.
- Crea/destruye `FishingSession` y emite senales de estado hacia la UI.
- Persiste `FishCollectionData` (coleccion, estadisticas, mejor tamano).

# 2.2 FishingSpot (Node3D, por chunk de agua M51)
- Se registra/desregistra con el chunk (streaming M51).
- Valida si sigue siendo "agua pescable" bajo demanda (no cada frame): voxel AGUA + AIRE encima + orilla accesible a pie.
- Marca visual opcional (ondulaciones/burbujas) y punto de impacto del anzuelo.

# 2.3 FishingRod (Resource) â€” datos de la cana equipada
- Rango de lanzamiento (m), ventana de exito (s), multiplicador de espera (x), multiplicador de rareza (x).
- Variantes: cana vieja, cana de madera ancestral, cana de deidad.

# 2.4 FishDefinition (Resource `.tres`)
- id, nombre (localizable), bioma(s), estaciones (M29), franjas (M31), climas (M32), peso PRNG (rareza), tamano min/max (m), valor venta (M37), recetas que consume (M15), pieza museo (M37), seÃ±uelos preferidos.

# 2.5 FishingSession â€” maquina de estados del minijuego
Estados: `IDLE -> LANZANDO -> ESPERA_PICADA -> PICADA -> MINIJUEGO -> CAPTURA | ESCAPE -> IDLE`
- Timers pausables con GameClock (M29); PRNG propio derivado del M29 para determinismo.
- 2 fases indulgentes: fase A (reaccion: pulsar al hundirse el flotador; ventana segun cana) y fase B (mantener 3 pulsaciones con ventana amplia).

# 2.6 FishCollectionData (Resource de partida)
- Por especie: capturado (bool), veces, mejor tamano; totales de capturas; piezas entregadas a M37.

# 2.7 UI (FishingMinigameUI, FishingHud)
- Indicador de espera (flotador, sonido de picada), boton de captura, feedback de exito/escape, zoom de captura, entrada al registro. Solo escucha senales; sin logica de gameplay.

# 3. Flujos en Texto

# Flujo 1 â€” Captura completa
1. Jugador equipa cana (M14/barra) y pulsa "pescar" mirando al agua.
2. FishingManager busca el spot mas cercano en el rayo del jugador (rango de la cana) y valida voxels M51.
3. Se lanza el flotador (RigidBody3D parabolico); estado LANZANDO.
4. Flotador toca el voxel agua y queda flotando; estado ESPERA_PICADA con timer de espera (cana x cebo, 2-8 s).
5. Al activarse la picada: sonido + flotador se hunde; estado PICADA; la UI muestra ventana de reaccion (fase A).
6. Si el jugador pulsa dentro de la ventana, entra MINIJUEGO (fase B: 3 pulsaciones con ventana por cana).
7. Exito: estado CAPTURA; FishingManager resuelve especie (tablas + PRNG M29), tamano (rango min/max x PRNG) y envia item pez a M14.
8. Se notifica a FishCollectionData (registro/estadisticas) y, si aplica, se marca pieza disponible para M37.
9. UI muestra resultado cozy; el jugador puede relanzar con 1 clic.

# Flujo 2 â€” Huida indulgente (sin frustracion)
1. En fase A: no se pulso a tiempo. En fase B: se fallo una pulsacion.
2. Estado ESCAPE: el pez huye; el flotador vuelve; la UI muestra "el pez se fue".
3. Sin perdidas: no se consume cebo (solo se consume al capturar), ni dinero ni items; relanzado inmediato con 1 clic.

# Flujo 3 â€” Validacion de spot (M51)
1. Al intentar lanzar, FishingManager consulta el voxel en el punto de impacto: tipo AGUA y voxel superior AIRE.
2. Busca orilla accesible (BFS limitado sobre chunks segun navmesh de orilla/arena).
3. Si falla cualquiera: no se lanza, UI sutil "aqui no se puede pescar" (sin bloqueo molesto).

# Flujo 4 â€” Resolucion de especie
1. Candidatas = FishDefinition que coinciden con bioma del spot + estacion M29 + franja M31 + clima M32 actuales.
2. Ajuste: cebo equipado aplica multiplicadores (probabilidad + espera).
3. Seleccion por PRNG ponderado (peso rareza x bono clima x bono cebo); tamano por PRNG uniforme en [min, max].

# Flujo 5 â€” Carga/descarga de chunks (streaming M51)
1. Al cargar chunk con agua: FishingSpot se crea y registra en FishingManager.
2. Si hay sesion activa en un spot descargado: se cancela como ESCAPE (sin castigo, el pez "no tuvo ganas").
3. Al descargar: el spot deja de recibir lanzamientos; se limpia de registros (pooling).

# 4. Contratos API (GDScript, Godot 4.x)

```gdscript
# FishingManager.gd (autoload Fishing)
class_name FishingManager
extends Node

signal picada_iniciada(sesion: FishingSession)
signal captura_exitosa(pez: FishDefinition, tamano: float)
signal captura_fallida(motivo: String)
signal sesion_terminada(sesion: FishingSession)

func registrar_spot(spot: FishingSpot) -> void
func desregistrar_spot(spot: FishingSpot) -> void
func spot_apunta_desde(origen: Vector3, direccion: Vector3, rango: float) -> FishingSpot
func iniciar_sesion(spot: FishingSpot, cana: FishingRod) -> FishingSession
func resolver_especie(spot: FishingSpot, cebo: CeboDefinition) -> FishDefinition
func registrar_captura(pez: FishDefinition, tamano: float) -> void
func entrega_museo(pez: FishDefinition) -> bool   # consumido por M37
func get_collection_data() -> FishCollectionData

# FishingSpot.gd
class_name FishingSpot
extends Node3D

signal spot_invalido(spot: FishingSpot)

func es_agua_pescable() -> bool                    # valida voxels M51 bajo demanda
func get_bioma() -> int
func get_punto_impacto() -> Vector3
func activar_marcador_visual() -> void
func desactivar_marcador_visual() -> void

# FishingSession.gd
class_name FishingSession
extends Node

signal estado_cambiado(estado: int)
signal ventana_activa(inicio_ventana: float, duracion: float)

func iniciar_espera() -> void
func notificar_pulsacion_boton() -> void           # llamada por la UI (indirecta)
func cancelar(motivo: String) -> void
func get_estado() -> int                            # ver constante de estado

# FishDefinition.gd (Resource) â€” datos puros
class_name FishDefinition
extends Resource

@export var id: String
@export var nombre_es: String
@export var biomas: Array[int]                     # IDs de bioma M51
@export var estaciones: Array[int]                 # IDs de estacion M29
@export var franjas: Array[int]                    # franjas M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA)
@export var climas: Array[int]                     # IDs de clima M32 (vacio = todos)
@export var peso_rareza: float                     # peso PRNG (raro 1.0 .. comun 60.0)
@export var tamano_min: float
@export var tamano_max: float
@export var valor_venta: int
@export var cebos_preferidos: Array[String]        # multiplicador si el cebo coincide
@export var pieza_museo: String                    # id de pieza opcional para M37 ("" = ninguna)
@export var id_receta: String                      # receta M15 que consume este pez ("" = ninguna)

# CeboDefinition.gd (Resource)
class_name CeboDefinition
extends Resource

@export var id: String
@export var multiplicador_probabilidad: float
@export var multiplicador_espera: float            # < 1.0 reduce la espera
@export var consumo_por_captura: int = 1           # solo se consume al capturar

# FishingRod.gd (Resource)
class_name FishingRod
extends Resource

@export var id: String
@export var rango_lanzamiento: float = 8.0
@export var ventana_exito: float = 0.5             # s (fase A y B)
@export var multiplicador_espera: float = 1.0
@export var multiplicador_rareza: float = 1.0
```

# 5. Integracion con Otros Modulos

| Modulo | Integracion |
|---|---|
| M51 (Agua) | Spots = voxels de agua validados (tipo AGUA + aire encima + orilla); registro por chunk/streaming; biomas de agua (mar, rio, laguna, pozo ancestral) |
| M29 (Tiempo y Calendario) | Estaciones y PRNG de partida para determinismo; pausa de timers con GameClock; eventos (festival con bono de capturas) |
| M31 (Ciclo Dia/Noche) | Franjas ALBA/DIA/ATARDECER/NOCHE/PROFUNDA como filtro de tablas; peces nocturnos |
| M32 (Clima) | 9 climas: bono de probabilidad (p.ej. lluvia favorable); nunca bloquea especies; transiciones suaves |
| M37 (Museos y Colecciones) | Piezas opcionales por pez; entrega de pez unico (duplicados no aceptados, pero vendibles sin frustracion); catalogo alimentado por FishCollectionData |
| M14 (Inventario) | Pez como item (stack, calidad); consumo para recetas M15; equipar cana y cebos |
| M15 (Crafting) | Recetas de coccion consumen peces del inventario (complemento: no obligatorio) |

# 6. Reglas Anti-Frustracion (Cozy, verificables)

1. Espera de picada en [2, 8] s segun cana y cebo.
2. Ventana de exito minima 0.35 s (cana vieja) y 0.70 s (cana de deidad).
3. Fallo = huida: sin perdida de items, dinero ni cebo (el cebo se consume solo al capturar).
4. Relanzado con 1 clic, sin cooldown de penalizacion.
5. Ninguna especie exige cebo especifico obligatorio (el cebo solo multiplica).
6. Ninguna especie es fuente exclusiva de progreso obligatorio (coleccion opcional M37).
7. Modo accesibilidad "captura automatica" salta las 2 fases (M57).
8. Pausa (GameClock M29) congela timers del minijuego; nunca se pierde por pausa.
9. Sin FOMO: las especies estacionales vuelven cada ano del calendario (M29, anos repetibles).

# Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-8 (H4)**: pesca con margen >70% es **intencional** (M93/M34). El margen alto de pesca es una decision de diseÃ±o, no un bug. Cita canonica: "GO FUNDADOR 23oct 20:25: Â«sÃ­, me gustan las recomendacionesÂ» (via director 315)".
- **PAQ-8 (H5)**: las probabilidades de fishing son **pesos relativos**, no probabilidades (suman >1 a proposito). No normalizar a 1.0. Cita canonica: "GO FUNDADOR 23oct 20:25: Â«sÃ­, me gustan las recomendacionesÂ» (via director 315)".

# Presupuestos de pesca (Beam 346, produce-first)
### Evento de festival con bono temporal de capturas
- Spec: en festival (M29), las capturas de peces otorgan bono x2 (duplica el peso del pez para el ranking).
- Duracion: durante el festival (1 dia de juego).
- Coherente con M29 (calendario) y M72 (logros).

### Feedback de escape cozy ("el pez se fue") sin culpa
- Spec: al escapar el pez, mostrar mensaje "el pez se fue" (no punitivo). Sin penalizacion, sin pÃ©rdida de cebo.
- Coherente con M53 (UI) y M42 (sonido).

### Zoom de captura con nombre y tamaÃ±o del pez
- Spec: al capturar, mostrar zoom con nombre del pez y tamaÃ±o (cm). Formato: "Sardina â€” 12 cm".
- Coherente con M53 (UI) y M55 (diario).

### Notificacion de nueva especie al catalogo
- Spec: al capturar una especie nueva (entry.veces == 1), emitir notificacion "Nueva especie: [nombre]".
- Coherente con M72 (logros) y M53 (UI).

### Sonido de escape del pez (no punitivo)
- Spec: sonido de escape suave (no punitivo). Volumen -6 dB sobre ambiente.
- Coherente con M42 (sonido ambiental) y M43 (SFX).

# Presupuestos de desafios (Beam 439, produce-first)
### Desafios (objetivos opcionales: catalogo completo, pez mas grande)
- Spec: objetivos opcionales de pesca (catalogo completo = capturar las 25 especies; pez mas grande = capturar un pez con peso > umbral).
- CatÃ¡logo completo: capturar las 25 especies de fishing.json.
- Pez mÃ¡s grande: capturar un pez con peso > umbral (ej: pez_luna > 30 kg, pez_ancestral_raiz > 20 kg).
- Coherente con M72 (logros) y M93 (balance). achievement_service ya consume captura_exitosa.

# Presupuestos de brillo (Beam 448, produce-first)
### Brillo sutil para peces raros/legendarios al caer
- Spec: brillo sutil para peces raros/legendarios al caer (VFX). Dato de rareza disponible (peso_rareza/UMBRAL_RARO).
- Coherente con M52 (particulas/VFX) y M93 (balance). El brillo se activa cuando peso_rareza >= UMBRAL_RARO.
- UMBRAL_RARO: pez con probabilidad <= 0.1 (legendario) o <= 0.04 (ancestral) o <= 0.01 (ancestral especial).

### Animaciones de pesca (Beam 471)
- Spec: FishingManager emite picada_iniciada, captura_exitosa, captura_fallida, sesion_terminada (contrato). M48 (Animación) y M53 (UI) consumen estas señales para cast, flotador, curva, salto del pez y zoom de captura. M34 provee el contrato; la implementación de animación es de M48/M53. Coherente con M48 (animación) y M53 (UI).

### Sonidos de pesca (Beam 471)
- Spec: FishingManager emite las mismas señales (picada, captura, escape, captura_exitosa). M42 (Sonido Ambiental) y M52 consumen para splash, picada, escape, captura y ambiente de agua. M34 provee el contrato; la implementación de sonido es de M42/M52. Coherente con M42 (sonido) y M52 (VFX).
### Flotador en punto de impacto (Beam 472)
- Spec: el flotador (visual) permanece en get_punto_impacto() (global_position del spot) durante la sesión. M52/M53 consumen este contrato para instanciar el RigidBody3D con física parabólica. M34 expone get_punto_impacto() -> Vector3. Coherente con M52 (VFX) y M53 (UI).

### Recetas consumen peces del inventario (Beam 472)
- Spec: FishDefinition.id_receta (contrato L23) vincula un pez con una receta de M15. Al capturar, el inventario (M37) registra la pieza; M15 consulta id_receta para habilitar la receta. Coherente con M15 (recursos) y M37 (museo/inventario).
### Sonido de captura festivo (Beam 473)
- Spec: captura_exitosa(pez, tamano) dispara un sonido festivo y corto (M42). M34 emite la señal con payload completo; M42 consume. Coherente con M42 (sonido) y M53 (UI).

### VFX de burbujas en spots activos (Beam 473)
- Spec: FishingSpot expone activar_marcador_visual/desactivar (contrato). M52 consume para VFX de burbujas en spots activos. M34 provee el contrato; la implementación VFX es de M52. Coherente con M52 (partículas).

### Escape limpio al alejarse (Beam 473)
- Spec: si el jugador se aleja del spot fuera de rango durante la sesión, se emite captura_fallida("el_jugador_se_alejo") (motivo no punitivo). Requiere posición del jugador (M11) y rango real (M13). M34 emite; el cableado es de M13/M53. Coherente con M13 (herramientas) y M53 (UI).

### Flotador fuera del mundo (recogida automática) (Beam 473)
- Spec: si el flotador (físico) queda fuera del mundo o del agua, se recoge automáticamente y se emite captura_fallida("flotador_perdido"). Requiere flotador físico (M52/M53). M34 define el contrato de escape; la implementación es de M52/M53. Coherente con M52 (VFX) y M53 (UI).

### Modo accesibilidad "captura automática" (Beam 473)
- Spec: la FSM admite notificar_pulsacion_boton programático. M57 (interfaz de control) puede activar un modo que simula pulsaciones automáticamente. M34 expone el hook; la UI/toggle es de M57. Coherente con M57 (accesibilidad).

### Reducción de efectos en opciones (Beam 473)
- Spec: las opciones (M57) pueden desactivar ondulaciones/brillos. M34 expone flags de efectos (efectos_visibles: bool) consultados por M52/M53. Coherente con M57 (opciones) y M52 (VFX).

### Peces ancestrales con presentación suave (Beam 473)
- Spec: peces ancestrales (M93) se presentan con burbujas doradas y sin combate (§6 sin castigos). M34 emite captura_exitosa con payload; M52 renderiza las burbujas doradas según rareza (peso_rareza/UMBRAL_RARO). Coherente con M93 (balance) y M52 (VFX).

### Specs items degradados T170 (2026-10-26, Reflection-Beam-1.0)
- **L131 (feedback pulsación):** pulsaciones_minijuego(restantes) se emite (L70/L74); tick visual/sonoro M53/M42.
- **L135 (notificación pieza museo):** dato de pieza disponible se calcula en M37/M53; M34 no notifica.
- **L137 (textos localizables):** nombre_i18n en JSON ("PESCA.PEZ_SARDINA") ya es clave localizable; consumo M86/M57 no verificado.
- **L154 (rechazo suave agua no pescable):** es_agua_pescable() stub (return true); rechazo suave inexistente — M51.
- **L157 (pausa durante fase A/B):** SceneTreeTimer pausable; edge case pausa en ventana sin prueba dedicada.
- **L161 (múltiples spots):** spot_apunta_desde devuelve primer spot; sin selección por centro de rayo — M51/M53.
- **L180 (opciones contraste ventanas):** M57/M53.
- **L181 (reducción efectos):** M57/M52 (efectos base tampoco existen).
- **L182 (cebos/canas balanceados):** 4 cebos + 3 cañas en fishing.json, 0 con precio_compra — balance M93/M38 pendiente.
- **L185 (desafíos opcionales registro):** get_collection_data() listo; vista M53.
- **L186 (vista previa condiciones):** FishDefinition tiene estaciones/franjas/climas; vista previa UI M53.
- **L196 (copia 1:1 plan-actual):** divergencia por diseño (AGENTS.md §3); no es tarea pendiente.

### Specs items degradados T169 (2026-10-26, Reflection-Beam-1.0)
- **L37 (P13):** efectos visuales (ondulaciones, burbujas, brillo de pez raro) — stub activar_marcador_visual (visible=true); VFX real M52.
- **L45 (P21):** recetas — peces consumibles en recetas M15 (opcional); id_receta en FishDefinition L23 listo como contrato.
- **L66 (FishingSpot):** clase + registro existe; creación por chunk es M51.
- **L69 (validación agua):** es_agua_pescable() stub (return true); validación real M51 (VoxelTool + tipo AGUA).
- **L70 (validación aire):** parte de es_agua_pescable — M51.
- **L73 (bioma spot):** FishingSpot.bioma int informado por M51; derivación M51.
- **L74 (punto impacto):** get_punto_impacto() devuelve global_position; cálculo sobre superficie real M51/M52.
- **L77 (spot en rango):** spot_apunta_desde ignora rango_lanzamiento (devuelve primer spot); filtro por distancia M51/M53.
- **L79 (spot visible al equipar):** trigger al equipar caña M53/M13; contrato activar_marcador_visual.
- **L80 (prueba spot):** pendiente M51 (biomas) + M93 (peces por bioma).
- **L85 (lanzamiento flotador):** sin RigidBody/parábola; sesión logica pura sin flotador visible (stub por diseño).
- **L119 (marcado pieza disponible):** estado "disponible" lo computa M37; M34 provee contrato entrega_museo().
- **L122 (cana/cebos hotbar):** datos existen (fishing_manager _cargar_canas_de); equipamiento desde hotbar M14/M13 no cableado.
- **L124 (recompensa museo):** recompensa por completar sección es diseño M37; M34 aporta catálogo.
- **L128 (FishingHud):** contrato ventana_activa(inicio, duracion) L16; HUD M53.
- **L130 (ventana reacción):** contrato ventana_activa L59; visual M53.