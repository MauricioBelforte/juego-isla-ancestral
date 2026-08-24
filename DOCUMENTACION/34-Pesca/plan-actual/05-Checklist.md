**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 34: Pesca

## A. Requisitos y alcance (10)

- [ ] Definir el problema: pesca cozy en mundo voxel sin frustracion [S]
- [ ] Registrar dependencias: M51 (Agua), M32 (Clima) [S]
- [ ] Registrar relaciones: M29, M31, M37, M14, M15 [S]
- [ ] Catalogar los 25 puntos de la seccion 33 del plan maestro [S]
- [ ] Definir RF1: cana equipable y lanzable desde la orilla [S]
- [ ] Definir RF2: spots de pesca sobre agua voxel valida de M51 [S]
- [ ] Definir RF3: lanzamiento parabolico del flotador [S]
- [ ] Definir RF4: espera de picada acotada (2-8 s) [S]
- [ ] Definir RF5: minijuego de timing indulgente en 2 fases [S]
- [ ] Definir RF6-RF10: huida sin penalizacion, tablas, registro, estadisticas y recompensas [S]

## B. Resolucion de los 25 puntos del plan (25)

- [ ] P1: especies — catalogo base de 25 peces con definiciones [C]
- [ ] P2: biomas — mar costero, rio, laguna, pozo ancestral [M]
- [ ] P3: horarios — tablas por franjas de M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA) [M]
- [ ] P4: estaciones — filtro por estacion de M29 (4 estaciones repetibles) [M]
- [ ] P5: clima — filtro por los 9 climas de M32 con bono (nunca bloqueo) [M]
- [ ] P6: rareza — pesos PRNG (comun 60, poco comun 25, raro 10, legendario 4, ancestral 1) [M]
- [ ] P7: cebos — 4 cebos con multiplicadores (niego exclusividad) [M]
- [ ] P8: canas — 3 canas que mejoran ventana/espera sin bloquear especies [M]
- [ ] P9: minijuego — timing suave en 2 fases indulgentes [C]
- [ ] P10: anti-frustracion — reglas verificables (ver seccion B-extra) [M]
- [ ] P11: animaciones — cast, flotador, curva, salto del pez y zoom de captura [M]
- [ ] P12: sonidos — splash, picada, escape, captura y ambiente de agua [M]
- [ ] P13: efectos visuales — ondulaciones, burbujas, brillo de pez raro [M]
- [ ] P14: coleccionario — FishCollectionData con catalogo por especie [M]
- [ ] P15: peces legendarios — 4 legendarios con captura opcional sin cebo exigido [M]
- [ ] P16: peces ancestrales — 2 ancestrales vinculados al pozo ancestral y a M37 [C]
- [ ] P17: especies exclusivas — 3 exclusivas por bioma (mar profundo, laguna oculta) [M]
- [ ] P18: peces nocturnos — 4 especies solo en NOCHE/PROFUNDA [M]
- [ ] P19: peces estacionales — 8 especies limitadas a 1-2 estaciones [M]
- [ ] P20: recompensas — valor de venta por especie y bono de calidad [M]
- [ ] P21: recetas — peces consumibles en recetas de M15 (opcional) [M]
- [ ] P22: museo — piezas opcionales entregadas a M37 [M]
- [ ] P23: desafios — objetivos opcionales (catalogo completo, pez mas grande) [S]
- [ ] P24: estadisticas — capturas, mejores tamanos, sesiones de pesca [S]
- [ ] P25: registro — enciclopedia del jugador con especies vistas/capturadas [M]

## C. Datos y definiciones (Resource) (10)

- [ ] FishDefinition con id, nombre localizable y biomas [S]
- [ ] FishDefinition con estaciones, franjas y climas como arrays [S]
- [ ] FishDefinition con peso_rareza y rangos de tamano [S]
- [ ] FishDefinition con valor_venta y cebos_preferidos [S]
- [ ] FishDefinition con pieza_museo y receta asociada [S]
- [ ] CeboDefinition con multiplicadores de probabilidad y espera [S]
- [ ] CeboDefinition con consumo solo al capturar [S]
- [ ] FishingRod con rango, ventana de exito y multiplicadores [S]
- [ ] Instancias .tres de los 25 peces en res://_Project/Data/Fishing [M]
- [ ] Instancias .tres de cebos y canas listas para referenciar [S]

## D. FishingSpot y mundo voxel M51 (15)

- [ ] FishingSpot como Node3D creado por chunk de agua [S]
- [ ] Autorregistro en FishingManager al entrar el chunk [S]
- [ ] Desregistro y limpieza al liberar el chunk (streaming) [S]
- [ ] Validacion de agua por voxels (tipo AGUA) con VoxelTool de M51 [C]
- [ ] Validacion de aire encima del voxel de agua [M]
- [ ] Validacion de orilla accesible a pie (BFS limitado sobre chunks) [M]
- [ ] Validacion bajo demanda, no por frame [M]
- [ ] Bioma del spot derivado del voxel/chunk (identificador de bioma M51) [M]
- [ ] Punto de impacto del anzuelo calculado sobre la superficie del agua [M]
- [ ] Marcador visual opcional (ondulaciones / burbujas) [S]
- [ ] Desactivacion del marcador al terminar la sesion [S]
- [ ] Spot dentro de rango de la cana (rango_lanzamiento de FishingRod) [M]
- [ ] Rechazo suave "aqui no se puede pescar" sin bloqueo molesto [S]
- [ ] Opcion de hacer visible el spot al equipar la cana (help) [M]
- [ ] Prueba de spot en mar, rio, laguna y pozo ancestral [S]

## E. Flujo de pesca y minijuego (FishingSession) (15)

- [ ] FSM con estados IDLE, LANZANDO, ESPERA_PICADA, PICADA, MINIJUEGO, CAPTURA, ESCAPE [C]
- [ ] Lanzamiento del flotador con fisica parabolica (RigidBody3D) [M]
- [ ] Flotador queda flotando en el punto de impacto [M]
- [ ] Timer de espera en [2, 8] s segun cana y cebo [M]
- [ ] Picada con senal, sonido y hundimiento del flotador [S]
- [ ] Fase A: ventana de reaccion con duracion de la cana [C]
- [ ] Fase B: 3 pulsaciones con ventana amplia por cana [C]
- [ ] Exito de fase B desemboca en CAPTURA [M]
- [ ] Fallo de fase A o B desemboca en ESCAPE sin castigo [M]
- [ ] Resolucion de especie por PRNG ponderado con seed M29 [C]
- [ ] Tamano del pez por PRNG uniforme en [min, max] [S]
- [ ] Creacion del item pez y entrega a M14 (inventario) [M]
- [ ] Consumo del cebo solo al capturar [S]
- [ ] Relanzado con 1 clic tras ESCAPE o CAPTURA [S]
- [ ] Timers del minijuego pausables con GameClock (M29) [M]

## F. Integracion M29 / M31 / M32 (10)

- [ ] Seleccion de estacion desde el calendario de M29 [S]
- [ ] Franja horaria actual obtenida del ciclo M31 [S]
- [ ] Clima actual obtenido del sistema M32 [S]
- [ ] Filtro de candidatas por estacion, franja y clima [M]
- [ ] Clima con bono multiplicador de probabilidad (lluvia p.ej.) [M]
- [ ] Cero bloqueos por clima en cualquier especie [S]
- [ ] PRNG de partida reutilizado para especie, tamano y marcador [M]
- [ ] Pausa global congela espera y minijuego sin desincronizar hora [M]
- [ ] Especies estacionales repetibles cada ano del calendario (sin FOMO) [S]
- [ ] Evento de festival (M29) con bono temporal de capturas [M]

## G. Integracion M37 (museo) y M14 (inventario) (10)

- [ ] Pez generado como item M14 con stack y calidad [M]
- [ ] Valor de venta del pez conectado a la economia M37 [S]
- [ ] Entrega del pez unico al museo (pieza opcional) [M]
- [ ] Duplicados no aceptados por M37 pero vendibles (sin frustracion) [S]
- [ ] Marcado de pieza disponible al entregar [S]
- [ ] Catalogo del museo alimentado por FishCollectionData [M]
- [ ] Recetas de M15 consumen peces del inventario [M]
- [ ] Cana y cebos equipables desde la barra de herramientas M14 [M]
- [ ] Listo el dato de "mejor tamano" visible en el museo [S]
- [ ] Recompensa opcional del museo al completar la seccion de peces [M]

## H. UI/UX y feedback (10)

- [ ] FishingHud con indicador de espera discreto [M]
- [ ] Indicador de picada clara (icono + sonido + hundimiento) [M]
- [ ] Ventana de reaccion visible con anillo/barra suave [M]
- [ ] Feedback de pulsacion exitosa (tick visual/sonoro) [S]
- [ ] Feedback de escape cozy ("el pez se fue") sin culpa [S]
- [ ] Zoom de captura con nombre y tamano del pez [M]
- [ ] Notificacion de nueva especie al catalogo [S]
- [ ] Notificacion de pieza de museo disponible [S]
- [ ] UI desacoplada: solo consume senales del manager [M]
- [ ] Textos localizables (M86) en todos los nombres y mensajes [S]

## I. Audio y VFX (8)

- [ ] Sonido de lanzamiento (swish suave) [S]
- [ ] Sonido de splash al entrar el flotador [S]
- [ ] Sonido de picada distintivo y relajante [S]
- [ ] Sonido de escape del pez (no punitivo) [S]
- [ ] Sonido de captura festivo y corto [S]
- [ ] VFX de ondulaciones en el punto de impacto [M]
- [ ] VFX de burbujas en spots activos [M]
- [ ] Brillo sutil para peces raros/legendarios al caer [M]

## J. Edge cases y robustez (10)

- [ ] Spot vacio o chunk descargado durante la sesion: ESCAPE sin castigo [M]
- [ ] Sesion activa y el jugador se aleja fuera de rango: ESCAPE limpio [M]
- [ ] Jugador lanza a agua no pescable (piscina decorativa): rechazo suave [M]
- [ ] Tabla de candidatas vacia (sin especies para la condicion): mensaje y relanzado [M]
- [ ] PRNG con seed determinista: misma partida, mismos resultados [C]
- [ ] Pausa durante fase A o B: ventanas congeladas, sin perdida [M]
- [ ] Doble pulsacion rapida en fase A: no cuenta doble ni rompe estado [M]
- [ ] Flotador fuera del mundo o fuera de agua (perdida): recogida automatica [M]
- [ ] Inventario lleno al capturar: bandeja "peces sueltos" o rechazo sin perder el pez [M]
- [ ] Multiples spots cercanos: se elige el del centro del rayo, sin ambiguedad [M]

## K. Rendimiento y optimizacion (8)

- [ ] Spots con pooling: se crean/destruyen con el chunk, sin duplicados [M]
- [ ] Validacion voxel bajo demanda: unicamente al lanzar o validar [M]
- [ ] Cero consultas grid por frame en estado IDLE [S]
- [ ] Marcadores visuales desactivados fuera de rango del jugador [M]
- [ ] UI del minijuego con pocos nodos y sin allocs por frame [M]
- [ ] Data .tres compartida: sin duplicacion de definiciones en memoria [S]
- [ ] Sesiones fuera de pantalla/lejas: sin UI hasta acercarse [S]
- [ ] Frame budget del sistema de pesca por debajo de 1 ms en profiler [C]

## L. Guardado, accesibilidad y polish (12)

- [ ] FishCollectionData serializable en datos de partida (M58) [M]
- [ ] Guardado de coleccion, mejores tamanos y estadisticas [M]
- [ ] No se guarda estado vivo de sesiones (se reinician limpias) [S]
- [ ] Modo accesibilidad "captura automatica" (M57) [M]
- [ ] Opciones de contraste para ventanas del minijuego (M57) [S]
- [ ] Reduccion de efectos (ondulaciones/brillos) en opciones [S]
- [ ] Cebos y canas balanceados sin grind (precios accesibles en M37) [M]
- [ ] Polaco cozy: tiempo muerto nunca supera 8 s en espera [M]
- [ ] Peces ancestrales con presentacion suave (burbujas doradas, sin combate) [M]
- [ ] Desafios opcionales visibles desde el registro [S]
- [ ] Vista previa de condiciones en el registro (donde/cuando pescar cada especie) [M]
- [ ] Sin microtransacciones ni FOMO respecto a la coleccion [S]

## M. Documentacion, tests y logs (10)

- [ ] 01-Requerimientos.md escrito en plan-inicial [S]
- [ ] 02-Analisis.md con alternativas y decisiones justificadas [S]
- [ ] 03-Diseno.md con arquitectura, flujos y contratos API GDScript [M]
- [ ] 04-Codigo.md con rutas res://, firmas clave y formato de logs [M]
- [ ] 05-Checklist.md con mas de 110 items de cobertura [M]
- [ ] Copia identica de los 5 archivos en plan-actual [S]
- [ ] Logs con prefijo [PESCA] en flujos normales [S]
- [ ] push_warning para condiciones inesperadas, push_error solo errores reales [S]
- [ ] Registro de capturas para telemetria de balance (sin afectar determinismo) [M]
- [ ] Preparado el plan de testings (06) para implementacion del modulo [M]