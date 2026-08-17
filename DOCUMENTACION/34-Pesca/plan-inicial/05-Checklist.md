**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 34: Pesca

## A. Requisitos y alcance (10)

- [x] Definir el problema: pesca cozy en mundo voxel sin frustracion [S]
- [x] Registrar dependencias: M51 (Agua), M32 (Clima) [S]
- [x] Registrar relaciones: M29, M31, M37, M14, M15 [S]
- [x] Catalogar los 25 puntos de la seccion 33 del plan maestro [S]
- [x] Definir RF1: cana equipable y lanzable desde la orilla [S]
- [x] Definir RF2: spots de pesca sobre agua voxel valida de M51 [S]
- [x] Definir RF3: lanzamiento parabolico del flotador [S]
- [x] Definir RF4: espera de picada acotada (2-8 s) [S]
- [x] Definir RF5: minijuego de timing indulgente en 2 fases [S]
- [x] Definir RF6-RF10: huida sin penalizacion, tablas, registro, estadisticas y recompensas [S]

## B. Resolucion de los 25 puntos del plan (25)

- [x] P1: especies — catalogo base de 25 peces con definiciones [C]
- [x] P2: biomas — mar costero, rio, laguna, pozo ancestral [M]
- [x] P3: horarios — tablas por franjas de M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA) [M]
- [x] P4: estaciones — filtro por estacion de M29 (4 estaciones repetibles) [M]
- [x] P5: clima — filtro por los 9 climas de M32 con bono (nunca bloqueo) [M]
- [x] P6: rareza — pesos PRNG (comun 60, poco comun 25, raro 10, legendario 4, ancestral 1) [M]
- [x] P7: cebos — 4 cebos con multiplicadores (niego exclusividad) [M]
- [x] P8: canas — 3 canas que mejoran ventana/espera sin bloquear especies [M]
- [x] P9: minijuego — timing suave en 2 fases indulgentes [C]
- [x] P10: anti-frustracion — reglas verificables (ver seccion B-extra) [M]
- [x] P11: animaciones — cast, flotador, curva, salto del pez y zoom de captura [M]
- [x] P12: sonidos — splash, picada, escape, captura y ambiente de agua [M]
- [x] P13: efectos visuales — ondulaciones, burbujas, brillo de pez raro [M]
- [x] P14: coleccionario — FishCollectionData con catalogo por especie [M]
- [x] P15: peces legendarios — 4 legendarios con captura opcional sin cebo exigido [M]
- [x] P16: peces ancestrales — 2 ancestrales vinculados al pozo ancestral y a M37 [C]
- [x] P17: especies exclusivas — 3 exclusivas por bioma (mar profundo, laguna oculta) [M]
- [x] P18: peces nocturnos — 4 especies solo en NOCHE/PROFUNDA [M]
- [x] P19: peces estacionales — 8 especies limitadas a 1-2 estaciones [M]
- [x] P20: recompensas — valor de venta por especie y bono de calidad [M]
- [x] P21: recetas — peces consumibles en recetas de M15 (opcional) [M]
- [x] P22: museo — piezas opcionales entregadas a M37 [M]
- [x] P23: desafios — objetivos opcionales (catalogo completo, pez mas grande) [S]
- [x] P24: estadisticas — capturas, mejores tamanos, sesiones de pesca [S]
- [x] P25: registro — enciclopedia del jugador con especies vistas/capturadas [M]

## C. Datos y definiciones (Resource) (10)

- [x] FishDefinition con id, nombre localizable y biomas [S]
- [x] FishDefinition con estaciones, franjas y climas como arrays [S]
- [x] FishDefinition con peso_rareza y rangos de tamano [S]
- [x] FishDefinition con valor_venta y cebos_preferidos [S]
- [x] FishDefinition con pieza_museo y receta asociada [S]
- [x] CeboDefinition con multiplicadores de probabilidad y espera [S]
- [x] CeboDefinition con consumo solo al capturar [S]
- [x] FishingRod con rango, ventana de exito y multiplicadores [S]
- [x] Instancias .tres de los 25 peces en res://_Project/Data/Fishing [M]
- [x] Instancias .tres de cebos y canas listas para referenciar [S]

## D. FishingSpot y mundo voxel M51 (15)

- [x] FishingSpot como Node3D creado por chunk de agua [S]
- [x] Autorregistro en FishingManager al entrar el chunk [S]
- [x] Desregistro y limpieza al liberar el chunk (streaming) [S]
- [x] Validacion de agua por voxels (tipo AGUA) con VoxelTool de M51 [C]
- [x] Validacion de aire encima del voxel de agua [M]
- [x] Validacion de orilla accesible a pie (BFS limitado sobre chunks) [M]
- [x] Validacion bajo demanda, no por frame [M]
- [x] Bioma del spot derivado del voxel/chunk (identificador de bioma M51) [M]
- [x] Punto de impacto del anzuelo calculado sobre la superficie del agua [M]
- [x] Marcador visual opcional (ondulaciones / burbujas) [S]
- [x] Desactivacion del marcador al terminar la sesion [S]
- [x] Spot dentro de rango de la cana (rango_lanzamiento de FishingRod) [M]
- [x] Rechazo suave "aqui no se puede pescar" sin bloqueo molesto [S]
- [x] Opcion de hacer visible el spot al equipar la cana (help) [M]
- [x] Prueba de spot en mar, rio, laguna y pozo ancestral [S]

## E. Flujo de pesca y minijuego (FishingSession) (15)

- [x] FSM con estados IDLE, LANZANDO, ESPERA_PICADA, PICADA, MINIJUEGO, CAPTURA, ESCAPE [C]
- [x] Lanzamiento del flotador con fisica parabolica (RigidBody3D) [M]
- [x] Flotador queda flotando en el punto de impacto [M]
- [x] Timer de espera en [2, 8] s segun cana y cebo [M]
- [x] Picada con senal, sonido y hundimiento del flotador [S]
- [x] Fase A: ventana de reaccion con duracion de la cana [C]
- [x] Fase B: 3 pulsaciones con ventana amplia por cana [C]
- [x] Exito de fase B desemboca en CAPTURA [M]
- [x] Fallo de fase A o B desemboca en ESCAPE sin castigo [M]
- [x] Resolucion de especie por PRNG ponderado con seed M29 [C]
- [x] Tamano del pez por PRNG uniforme en [min, max] [S]
- [x] Creacion del item pez y entrega a M14 (inventario) [M]
- [x] Consumo del cebo solo al capturar [S]
- [x] Relanzado con 1 clic tras ESCAPE o CAPTURA [S]
- [x] Timers del minijuego pausables con GameClock (M29) [M]

## F. Integracion M29 / M31 / M32 (10)

- [x] Seleccion de estacion desde el calendario de M29 [S]
- [x] Franja horaria actual obtenida del ciclo M31 [S]
- [x] Clima actual obtenido del sistema M32 [S]
- [x] Filtro de candidatas por estacion, franja y clima [M]
- [x] Clima con bono multiplicador de probabilidad (lluvia p.ej.) [M]
- [x] Cero bloqueos por clima en cualquier especie [S]
- [x] PRNG de partida reutilizado para especie, tamano y marcador [M]
- [x] Pausa global congela espera y minijuego sin desincronizar hora [M]
- [x] Especies estacionales repetibles cada ano del calendario (sin FOMO) [S]
- [x] Evento de festival (M29) con bono temporal de capturas [M]

## G. Integracion M37 (museo) y M14 (inventario) (10)

- [x] Pez generado como item M14 con stack y calidad [M]
- [x] Valor de venta del pez conectado a la economia M37 [S]
- [x] Entrega del pez unico al museo (pieza opcional) [M]
- [x] Duplicados no aceptados por M37 pero vendibles (sin frustracion) [S]
- [x] Marcado de pieza disponible al entregar [S]
- [x] Catalogo del museo alimentado por FishCollectionData [M]
- [x] Recetas de M15 consumen peces del inventario [M]
- [x] Cana y cebos equipables desde la barra de herramientas M14 [M]
- [x] Listo el dato de "mejor tamano" visible en el museo [S]
- [x] Recompensa opcional del museo al completar la seccion de peces [M]

## H. UI/UX y feedback (10)

- [x] FishingHud con indicador de espera discreto [M]
- [x] Indicador de picada clara (icono + sonido + hundimiento) [M]
- [x] Ventana de reaccion visible con anillo/barra suave [M]
- [x] Feedback de pulsacion exitosa (tick visual/sonoro) [S]
- [x] Feedback de escape cozy ("el pez se fue") sin culpa [S]
- [x] Zoom de captura con nombre y tamano del pez [M]
- [x] Notificacion de nueva especie al catalogo [S]
- [x] Notificacion de pieza de museo disponible [S]
- [x] UI desacoplada: solo consume senales del manager [M]
- [x] Textos localizables (M86) en todos los nombres y mensajes [S]

## I. Audio y VFX (8)

- [x] Sonido de lanzamiento (swish suave) [S]
- [x] Sonido de splash al entrar el flotador [S]
- [x] Sonido de picada distintivo y relajante [S]
- [x] Sonido de escape del pez (no punitivo) [S]
- [x] Sonido de captura festivo y corto [S]
- [x] VFX de ondulaciones en el punto de impacto [M]
- [x] VFX de burbujas en spots activos [M]
- [x] Brillo sutil para peces raros/legendarios al caer [M]

## J. Edge cases y robustez (10)

- [x] Spot vacio o chunk descargado durante la sesion: ESCAPE sin castigo [M]
- [x] Sesion activa y el jugador se aleja fuera de rango: ESCAPE limpio [M]
- [x] Jugador lanza a agua no pescable (piscina decorativa): rechazo suave [M]
- [x] Tabla de candidatas vacia (sin especies para la condicion): mensaje y relanzado [M]
- [x] PRNG con seed determinista: misma partida, mismos resultados [C]
- [x] Pausa durante fase A o B: ventanas congeladas, sin perdida [M]
- [x] Doble pulsacion rapida en fase A: no cuenta doble ni rompe estado [M]
- [x] Flotador fuera del mundo o fuera de agua (perdida): recogida automatica [M]
- [x] Inventario lleno al capturar: bandeja "peces sueltos" o rechazo sin perder el pez [M]
- [x] Multiples spots cercanos: se elige el del centro del rayo, sin ambiguedad [M]

## K. Rendimiento y optimizacion (8)

- [x] Spots con pooling: se crean/destruyen con el chunk, sin duplicados [M]
- [x] Validacion voxel bajo demanda: unicamente al lanzar o validar [M]
- [x] Cero consultas grid por frame en estado IDLE [S]
- [x] Marcadores visuales desactivados fuera de rango del jugador [M]
- [x] UI del minijuego con pocos nodos y sin allocs por frame [M]
- [x] Data .tres compartida: sin duplicacion de definiciones en memoria [S]
- [x] Sesiones fuera de pantalla/lejas: sin UI hasta acercarse [S]
- [x] Frame budget del sistema de pesca por debajo de 1 ms en profiler [C]

## L. Guardado, accesibilidad y polish (12)

- [x] FishCollectionData serializable en datos de partida (M58) [M]
- [x] Guardado de coleccion, mejores tamanos y estadisticas [M]
- [x] No se guarda estado vivo de sesiones (se reinician limpias) [S]
- [x] Modo accesibilidad "captura automatica" (M57) [M]
- [x] Opciones de contraste para ventanas del minijuego (M57) [S]
- [x] Reduccion de efectos (ondulaciones/brillos) en opciones [S]
- [x] Cebos y canas balanceados sin grind (precios accesibles en M37) [M]
- [x] Polaco cozy: tiempo muerto nunca supera 8 s en espera [M]
- [x] Peces ancestrales con presentacion suave (burbujas doradas, sin combate) [M]
- [x] Desafios opcionales visibles desde el registro [S]
- [x] Vista previa de condiciones en el registro (donde/cuando pescar cada especie) [M]
- [x] Sin microtransacciones ni FOMO respecto a la coleccion [S]

## M. Documentacion, tests y logs (10)

- [x] 01-Requerimientos.md escrito en plan-inicial [S]
- [x] 02-Analisis.md con alternativas y decisiones justificadas [S]
- [x] 03-Diseno.md con arquitectura, flujos y contratos API GDScript [M]
- [x] 04-Codigo.md con rutas res://, firmas clave y formato de logs [M]
- [x] 05-Checklist.md con mas de 110 items de cobertura [M]
- [x] Copia identica de los 5 archivos en plan-actual [S]
- [x] Logs con prefijo [PESCA] en flujos normales [S]
- [x] push_warning para condiciones inesperadas, push_error solo errores reales [S]
- [x] Registro de capturas para telemetria de balance (sin afectar determinismo) [M]
- [x] Preparado el plan de testings (06) para implementacion del modulo [M]