# Log 2432 - HY4 Flash - Backlog 41 RootCause Q restantes

Fecha: 2026-11-20
Agente: hy4-flash
Backlog: 41-Backlog-RootCause-Q-Remaining.md (344 tareas, 68 modulos)

== METODO ==
Para cada [?] de los 68 modulos: extraer el texto REAL del item en
plan-actual/05-Checklist.md (344/344 con texto), clasificar causa por keywords,
verificar en disco los archivos citados (indices de game/isla-ancestral).
Confianza alta = causa explicita en el checklist o verificada en disco;
media = deuda/alcance posterior sin verificacion directa.

== HALLAZGO DE CORRECCION ==
10 items decian 'no existe tal archivo' pero el archivo SI existe en disco
(island_generator.gd, audio_config_service.gd, validate_vehicles.gd...).
Se corrigio la causa a 'claim de ausencia inexacto: archivo existe, falta la
funcionalidad'. Sin esta verificacion se habrian consignado 10 falsedades.

== DISTRIBUCION DE CAUSAS ==
 141  deuda documentada en checklist (alcance posterior)
  52  decision de diseno pendiente (fuera de este modulo)
  45  sin verificacion automatizada disponible
  38  artefacto ausente en disco
  21  KnownIssue documentado, no bloqueante
  10  claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta
   7  deuda cross-modulo (dueno M104)
   7  deuda cross-modulo (dueno M90)
   6  deuda cross-modulo (dueno M53)
   5  requiere datos de gameplay reales (no disponibles en build)
   3  deuda cross-modulo (dueno M91)
   3  deuda cross-modulo (dueno M71)
   1  deuda cross-modulo (dueno M104,M91)
   1  deuda cross-modulo (dueno M102)
   1  deuda cross-modulo (dueno M57)
   1  deuda cross-modulo (dueno M63)
   1  deuda cross-modulo (dueno M61)
   1  deuda cross-modulo (dueno M38)

CONFIANZA: {'alta': 77, 'media': 267}

== DETALLE POR TAREA (id | modulo | linea | conf | causa | texto) ==
T41-001 | M105 L145 | alta | requiere datos de gameplay reales (no disponibles en build) | - [?] Usar datos para mejorar diseno (requiere gameplay + volumen de datos real; fase posterior
T41-002 | M105 L189 | alta | deuda cross-modulo (dueno M53) | - [?] Definir encuesta post-puzzle  **M53** (UI de encuesta; M105 ya emite `solicitar_encuesta(
T41-003 | M105 L191 | alta | deuda cross-modulo (dueno M53) | - [?] Disenar pregunta: "Que tan dificil te parecio este puzzle?"  **M53** (texto de la UI de e
T41-004 | M105 L193 | alta | deuda cross-modulo (dueno M53) | - [?] Disenar encuesta opcional despues de completar puzzle  **M53** (UI opcional; requiere con
T41-005 | M105 L196 | alta | requiere datos de gameplay reales (no disponibles en build) | - [?] Definir analisis de datos para identificar puzzles con alta tasa de abandono  requiere da
T41-006 | M105 L197 | alta | requiere datos de gameplay reales (no disponibles en build) | - [?] Definir analisis de datos para identificar zonas ignoradas  requiere datos reales; M105 y
T41-007 | M105 L198 | alta | requiere datos de gameplay reales (no disponibles en build) | - [?] Definir analisis de datos para identificar eventos clave no alcanzados  requiere datos re
T41-008 | M105 L199 | alta | requiere datos de gameplay reales (no disponibles en build) | - [?] Definir analisis de datos para identificar tiempos anormales  requiere datos reales; M105
T41-009 | M105 L204 | alta | deuda cross-modulo (dueno M91) | - [?] Definir prompt en primer inicio del juego  **M91** (UI de primer arranque); M105 expone `
T41-010 | M105 L205 | alta | deuda cross-modulo (dueno M91) | - [?] Definir opcion de opt-out en settings  **M91** (menu de settings); M105 ya soporta opt-ou
T41-011 | M105 L209 | alta | deuda cross-modulo (dueno M104,M91) | - [?] Definir posibilidad de solicitar eliminacion de datos  **M104** (storage) + **M91** (UI);
T41-012 | M105 L210 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir politica de privacidad documentada  documentacion legal (transversal); M105 docum
T41-013 | M105 L215 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar AnalyticsService batching y envio  **M104** (AnalyticsDirector); M105 solo delega
T41-014 | M105 L216 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar AnalyticsService anonimizacion y GDPR compliance  **M104** (hash de sesion SHA256
T41-015 | M105 L217 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar AnalyticsService cache local y envio batch  **M104** (buffer + batch JSON offline
T41-016 | M105 L220 | alta | deuda cross-modulo (dueno M71) | - [?] Disenar integracion con M71 para observacion de eventos  **M71** (M105 expone la API pasi
T41-017 | M105 L221 | alta | deuda cross-modulo (dueno M71) | - [?] Disenar M71 notificar a M105 cuando ocurren eventos clave  **M71** (llamador); M105 ya ex
T41-018 | M105 L224 | alta | deuda cross-modulo (dueno M71) | - [?] Disenar M105 como observador pasivo de eventos de M71  **M71**; M105 es sumidero de solo-
T41-019 | M105 L233 | alta | deuda cross-modulo (dueno M102) | - [?] Disenar integracion con M102 para generacion de issues  **M102** (M105 expone los patrone
T41-020 | M105 L245 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar metodo generate_session_id()  iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegado a 
T41-021 | M105 L250 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar variable session_id  iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegada a M104 por 
T41-022 | M105 L293 | alta | deuda cross-modulo (dueno M53) | - [?] Disenar metodo show_difficulty_survey(puzzle_id)  **M53** (UI); M105 emite `solicitar_enc
T41-023 | M105 L295 | alta | deuda cross-modulo (dueno M53) | - [?] Disenar UI de encuesta post-puzzle  **M53**.
T41-024 | M105 L296 | alta | deuda cross-modulo (dueno M53) | - [?] Disenar encuesta opcional (no forzar)  **M53** (opcional por diseno).
T41-025 | M105 L299 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar archivo user://telemetry/gameplay_events.json  **M104** (4: buffer + batch JSON);
T41-026 | M105 L300 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar formato JSON de eventos  **M104** (contrato de `registrar_evento`).
T41-027 | M105 L301 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar metodo save_events_to_cache()  **M104** (cache offline).
T41-028 | M105 L302 | alta | deuda cross-modulo (dueno M104) | - [?] Disenar carga de eventos al inicio (opcional)  **M104**.
T41-029 | M115 L23 | alta | KnownIssue documentado, no bloqueante | - [?] Documentar requisitos recomendados de CPU  KnownIssue: M97 marketing. Spec en 03-Diseno 2
T41-030 | M115 L24 | alta | KnownIssue documentado, no bloqueante | - [?] Documentar requisitos recomendados de RAM  KnownIssue: M97. Spec en 03-Diseno 2.2.
T41-031 | M115 L25 | alta | KnownIssue documentado, no bloqueante | - [?] Documentar requisitos recomendados de GPU  KnownIssue: M97. Spec en 03-Diseno 2.3.
T41-032 | M115 L27 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir DirectX/OpenGL requerido  KnownIssue: M90/M04. Policy defined.
T41-033 | M115 L28 | alta | KnownIssue documentado, no bloqueante | - [?] Documentar espacio en disco requerido  KnownIssue: M98/M117 instalador. Estimacion ~2GB.
T41-034 | M115 L29 | alta | KnownIssue documentado, no bloqueante | - [?] Crear tabla comparativa de requisitos por plataforma  KnownIssue: M97 editorial.
T41-035 | M115 L66 | alta | deuda cross-modulo (dueno M90) | - [?] Aplicar SSAO on/off  **M90**
T41-036 | M115 L67 | alta | deuda cross-modulo (dueno M90) | - [?] Aplicar SSR on/off  **M90**
T41-037 | M115 L72 | media | deuda documentada en checklist (alcance posterior) | - [?] Crear Resource QualitySettings  **M90  fuera de alcance M115**
T41-038 | M115 L74 | alta | deuda cross-modulo (dueno M90) | - [?] Very Low: render_scale 0.5, shadows off, 30 FPS target  **M90**
T41-039 | M115 L75 | alta | deuda cross-modulo (dueno M90) | - [?] Low: render_scale 0.7, shadows low, 30 FPS target  **M90**
T41-040 | M115 L76 | alta | deuda cross-modulo (dueno M90) | - [?] Medium: render_scale 0.85, shadows medium, 60 FPS target  **M90**
T41-041 | M115 L77 | alta | deuda cross-modulo (dueno M90) | - [?] High: render_scale 1.0, shadows high, 60 FPS target  **M90**
T41-042 | M115 L78 | alta | deuda cross-modulo (dueno M90) | - [?] Ultra: render_scale 1.0, shadows ultra, 120 FPS target  **M90**
T41-043 | M115 L90 | alta | KnownIssue documentado, no bloqueante | - [?] Emitir senal cuando el preset cambia  KnownIssue: no emitida; pendiente si M90 la requier
T41-044 | M115 L115 | alta | deuda cross-modulo (dueno M57) | - [?] Test de mapeo de botones  **M57** *(test_control_input.gd existe)*
T41-045 | M115 L116 | media | sin verificacion automatizada disponible | - [?] Test de hot-plug de gamepad  requiere gamepad fisico; fuera de headless
T41-046 | M115 L122 | alta | KnownIssue documentado, no bloqueante | - [?] Perfiles de calidad incluidos en build  KnownIssue: M90. Deferred.
T41-047 | M115 L124 | alta | KnownIssue documentado, no bloqueante | - [?] Logging de hardware en build log  KnownIssue: M103 Logging. Deferred.
T41-048 | M115 L129 | alta | KnownIssue documentado, no bloqueante | - [?] Soporte para Steam Deck  KnownIssue: M95/M117. Deferred.
T41-049 | M115 L130 | alta | KnownIssue documentado, no bloqueante | - [?] Documentar hardware no soportado  KnownIssue: M97 editorial. Spec defined.
T41-050 | M115 L135 | alta | KnownIssue documentado, no bloqueante | - [?] Crear guia de uso para el jugador  KnownIssue: M88/M89 menu. Spec defined.
T41-051 | M115 L138 | alta | KnownIssue documentado, no bloqueante | - [?] Tabla de requisitos de hardware para Steam  KnownIssue: M97. Tabla base en 03-Diseno 2.6.
T41-052 | M115 L139 | alta | KnownIssue documentado, no bloqueante | - [?] FAQ de problemas de hardware comunes  KnownIssue: M97. FAQ en 03-Diseno 3.3.
T41-053 | M115 L142 | media | sin verificacion automatizada disponible | - [?] Proceso de testing en hardware diverso  KnownIssue: M113/M61 bench. Proceso en 03-Diseno 
T41-054 | M115 L153 | media | sin verificacion automatizada disponible | - [?] Verificar M154 antes de trabajo visual. En iter 1 no hay UI visual; M154 solo necesario s
T41-055 | M127 L29 | media | deuda documentada en checklist (alcance posterior) | - [?] Registrar narrativa  **dueno: usuario** (registro formal ante la Oficina de Copyright req
T41-056 | M127 L30 | media | deuda documentada en checklist (alcance posterior) | - [?] Registrar logos  **dueno: usuario** (registro formal)
T41-057 | M127 L119 | media | sin verificacion automatizada disponible | - [?] Integrar con M118 (CI/CD) para verificar automaticamente la presencia de cabeceras de cop
T41-058 | M127 L120 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M06 (Control de Versiones) para auditorias periodicas de historial de autori
T41-059 | M127 L121 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M41 (Musica) para archivar sesiones multipista (DAW), stems y partituras com
T41-060 | M127 L122 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M45 (Arte 3D) para archivar archivos maestros .blend con timestamps de creac
T41-061 | M127 L123 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M22 (Historia Principal) y M147 (World Building) para archivar borradores y 
T41-062 | M127 L124 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M131 (Creditos) para asegurar correspondencia 100% fiel entre autores reales
T41-063 | M127 L125 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M103 (Logging) para auditar cambios en declaraciones de derechos de autor y 
T41-064 | M127 L126 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M107 (Backups) para resguardo redundante (estrategia 3-2-1) de evidencias de
T41-065 | M127 L129 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar protocolo formal de respuesta y contra-notificacion ante reclamos falsos o malici
T41-066 | M127 L130 | media | deuda documentada en checklist (alcance posterior) | - [?] Establecer mecanismo de resolucion de disputas de coautoria con colaboradores externos o 
T41-067 | M127 L131 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir protocolo de evaluacion legal ante inclusion de librerias open source con licenci
T41-068 | M127 L132 | media | deuda documentada en checklist (alcance posterior) | - [?] Establecer plan de accion ante deteccion de clones, ripeos de assets o plagios en tiendas
T41-069 | M127 L133 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar procedimiento ante disputas de autoria de samples o librerias de sonido  **dueno:
T41-070 | M127 L134 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir gestion de propiedad intelectual sobre prototipos o conceptos desarrollados en ga
T41-071 | M127 L135 | media | deuda documentada en checklist (alcance posterior) | - [?] Establecer protocolo de depuracion urgente si se detectan assets provisionales de tercero
T41-072 | M127 L136 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar estrategia de proteccion de copyright en jurisdicciones internacionales no firman
T41-073 | M127 L141 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Optimizar costos de registro formal agrupando multiples obras relacionadas bajo registros
T41-074 | M127 L146 | media | deuda documentada en checklist (alcance posterior) | - [?] Mantener matriz de titularidad de derechos actualizada ante eventuales cesiones, acuerdos
T41-075 | M127 L158 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar presentacion estetica y tipografica del aviso de copyright en pantalla de titulo,
T41-076 | M127 L160 | media | deuda documentada en checklist (alcance posterior) | - [?] Estandarizar el diseno visual de los certificados y carpetas del archivo historico de pro
T41-077 | M127 L161 | media | deuda documentada en checklist (alcance posterior) | - [?] Crear pantalla accesible y navegable de licencias de software y librerias de terceros en 
T41-078 | M127 L164 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar sello distintivo de copyright oficial para manuales de juego, artbooks y piezas d
T41-079 | M124 L13 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir criterio: demanda comunitaria  25% (M100) [S]  dueno: producto + M100
T41-080 | M124 L16 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir criterio: diseno aprobado 100% [S]  dueno: diseno/producto
T41-081 | M124 L22 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir compartir fotos de la camara (M56) [M]  dueno: M56 + UI M89
T41-082 | M124 L33 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir compartir blueprints de diseno (M18) [M]  dueno: M18 + UI M89
T41-083 | M124 L45 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir ejemplos de materiales requeridos [S]  dueno: contenido (M16/M17)
T41-084 | M124 L47 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir regla: no puede exceder limites de terreno del jugador [M]  dueno: M17/M109
T41-085 | M124 L53 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir umbral de IA para NSFW/odio [M]  dueno: servicio de moderacion (post-V2)
T41-086 | M124 L54 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir cola humana con SLA 24 h [M]  dueno: proceso/ops
T41-087 | M124 L58 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir reportes de usuario entran a la misma cola (M100) [M]  dueno: M100
T41-088 | M124 L64 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir fotos en CDN [M]  dueno: infra/servicio
T41-089 | M124 L65 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir blueprints en bucket/objeto pequeno [M]  dueno: infra/servicio
T41-090 | M124 L79 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir proceso de stickers (repetir reportes abusivos) [S]  dueno: proceso/moderacion
T41-091 | M124 L87 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir almacenamiento segun region de M80 [M]  dueno: M80/infra
T41-092 | M124 L89 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir derecho al olvido operativo (GDPR) [M]  dueno: proceso/legal
T41-093 | M124 L104 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir politica apta para todas las edades [M]  dueno: legal/producto
T41-094 | M124 L107 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir suspension temporal del autor (3 strikes) [M]  dueno: proceso/moderacion
T41-095 | M124 L113 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir borrado efectivo  30 dias (GDPR) [M]  dueno: proceso/legal
T41-096 | M124 L123 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir resumen en lenguaje simple + texto legal [M]  dueno: legal (M125)
T41-097 | M124 L125 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir consentimiento de menores (minimo de edad) [M]  dueno: legal (M125)
T41-098 | M124 L126 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir revision legal anual del TOS (M126) [S]  dueno: legal (M126)
T41-099 | M124 L148 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir galeria publica con filtros por tag [M]  dueno: UI M89
T41-100 | M124 L149 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir tarjeta de item (foto/blueprint + alias + me gusta) [M]  dueno: UI M89
T41-101 | M124 L151 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir pagina de perfil con mis items y estados [M]  dueno: UI M89
T41-102 | M10 L18 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Requisito RF5: recetas de M09 aplicadas [S]  QA atria-dawn: FALSO. Las recetas de M09 no 
T41-103 | M10 L26 | media | deuda documentada en checklist (alcance posterior) | - [?] Configurar 4-6 octavas con amplitud 0-192 m (Aurora) [M]  DEGRADADO 2026-10-15 (step-5 41
T41-104 | M10 L38 | media | sin verificacion automatizada disponible | - [?] Test A de determinismo: 3 ordenes de regen  mismos bytes [C]  QA atria-dawn: no existia N
T41-105 | M10 L44 | media | sin verificacion automatizada disponible | - [?] Capa 2 Biomas: altura + humedad  mapa de biomas (umbrales M09) [M]  QA atria-dawn: parcia
T41-106 | M10 L45 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Capa 3 Formaciones: recetas M09 + marcadores  modificadores [M]  QA atria-dawn: FALSO. No
T41-107 | M10 L46 | media | deuda documentada en checklist (alcance posterior) | - [?] Capa 4 Roca y cuevas: Simplex 3D  densidad de piedra/aire [M]  QA atria-dawn: FALSO. El u
T41-108 | M10 L50 | media | deuda documentada en checklist (alcance posterior) | - [?] Capa 8 Estructuras: prefabs por marcador POI [M]  QA atria-dawn: FALSO. El generador no c
T41-109 | M10 L53 | media | deuda documentada en checklist (alcance posterior) | - [?] Diffs del jugador se aplican DESPUES de regenerar [M]  DEGRADADO 2026-10-15 (step-5 412, 
T41-110 | M10 L56 | media | deuda documentada en checklist (alcance posterior) | - [?] Implementacion como autoload WorldGenerator [S]  QA atria-dawn: FALSO. `world_generator.g
T41-111 | M10 L58 | media | artefacto ausente en disco | - [?] Knobs por capa en data/*.tres (sin recompilar) [M]  QA atria-dawn: FALSO. `data/generatio
T41-112 | M10 L90 | media | deuda documentada en checklist (alcance posterior) | - [?] Chunk fallido  reintento 2  fallback de basalto + log [M]  QA atria-dawn: FALSO. `_genera
T41-113 | M10 L91 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Midiendo: LOG_GENERATION con chunks/seg [S]  QA atria-dawn: FALSO. No existe tal logging 
T41-114 | M10 L95 | media | artefacto ausente en disco | - [?] Catalogo de prefabs de estructuras (faro, puerto, plaza, granja, templo, puentes, ruinas)
T41-115 | M10 L105 | media | deuda documentada en checklist (alcance posterior) | - [?] Cuevas:  3 entradas por isla, al menos 1 cerca del pueblo [M]  QA atria-dawn: FALSO, sin 
T41-116 | M10 L106 | media | deuda documentada en checklist (alcance posterior) | - [?] Galerias de 3-8 m de tamano [S]  QA atria-dawn: FALSO, sin codigo de galerias/cuevas. / F
T41-117 | M10 L107 | media | artefacto ausente en disco | - [?] Minerales por profundidad (hierro, carbon, cobre, oro, cristal) [M]  QA atria-dawn: parci
T41-118 | M10 L108 | media | deuda documentada en checklist (alcance posterior) | - [?] Prefabs reutilizables entre islas (biblia M09) [M]  QA atria-dawn: FALSO, no hay prefabs.
T41-119 | M10 L122 | media | deuda documentada en checklist (alcance posterior) | - [?] Sin contradicciones con M09 (recetas, POI, biomas) [M]  QA atria-dawn: FALSO. Hay contrad
T41-120 | M67 L46 | media | sin verificacion automatizada disponible | - [?] Vela desplegable (M48) y estela por evento (M52) [M] / DEGRADADO 2026-10-28 DS-V4.1-Flash
T41-121 | M67 L52 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] No romper el streaming a gran altura (chunk_target + LOD, M10/M61) [C]  Step-5 2026-10-21
T41-122 | M67 L53 | media | deuda documentada en checklist (alcance posterior) | - [?] No colisionar con vegetacion alta (paso por encima) [M]  Step-5 2026-10-21: sin sistema d
T41-123 | M67 L75 | media | sin verificacion automatizada disponible | - [?] Controles con WASD y gamepad (palanca/gatillos) [M] / DEGRADADO 2026-10-28 DS-V4.1-Flash-
T41-124 | M67 L99 | media | artefacto ausente en disco | - [?] Entrada solo si esta docked o en superficie [M]  Step-5 2026-10-21: enter() valida docked
T41-125 | M67 L102 | media | sin verificacion automatizada disponible | - [?] Testear entrada/salida con gamepad y durante eventos (M74) [M] / DEGRADADO 2026-10-28 DS-
T41-126 | M67 L110 | media | sin verificacion automatizada disponible | - [?] Testear docking en muelles angostos y con olas (M51) [C] / DEGRADADO 2026-10-28 DS-V4.1-F
T41-127 | M67 L124 | media | sin verificacion automatizada disponible | - [?] Mejoras de faroles (M49) y baul [M]  Step-5 2026-10-22 (tanda 4): baul SI implementado (b
T41-128 | M67 L139 | media | deuda documentada en checklist (alcance posterior) | - [?] LOD de audio: atenuar > 40 m, silenciar > 80 m [M] / FLIP 2026-10-26 (Reflection-Beam-1.0
T41-129 | M67 L182 | media | deuda documentada en checklist (alcance posterior) | - [?] Localizar mensajes de limites (profundidad, altitud) [S]  Step-5 2026-10-21: los avisos d
T41-130 | M67 L190 | media | deuda documentada en checklist (alcance posterior) | - [?] Controles completos con gamepad (sin mouse) [M] / DEGRADADO 2026-10-28 DS-V4.1-Flash-Open
T41-131 | M67 L196 | media | artefacto ausente en disco | - [?] Probar ciclo dirigible: despegar  volar  aterrizar [C]  Step-5 2026-10-21: el controller 
T41-132 | M67 L197 | media | deuda documentada en checklist (alcance posterior) | - [?] Probar ciclo submarino: sumergir  explorar  emerger [C]  Step-5 2026-10-21: igual que V3:
T41-133 | M67 L219 | media | sin verificacion automatizada disponible | - [?] Actualizar CHECKLIST-GLOBAL con el progreso real [S] / DEGRADADO 2026-10-28 DS-V4.1-Flash
T41-134 | M67 L226 | media | sin verificacion automatizada disponible | - [?] Verificar con verificar_checklist.py (sin alertas nuevas) [S] / DEGRADADO 2026-10-28 DS-V
T41-135 | M67 L229 | media | sin verificacion automatizada disponible | - [?] Revisar que plan-inicial == plan-actual (SHA-256) [S] / DEGRADADO 2026-10-28 DS-V4.1-Flas
T41-136 | M67 L230 | media | sin verificacion automatizada disponible | - [?] Confirmar 130 items exactos [S] / DEGRADADO 2026-10-28 DS-V4.1-Flash-Opencode (gate-1 21.
T41-137 | M16 L36 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir recetas regionales: materiales regionales M15 habilitan variantes [M] - **QA s2 2
T41-138 | M16 L48 | media | deuda documentada en checklist (alcance posterior) | - [?] Evitar cientos de recetas redundantes: validacion automatica de duplicados funcional [M] 
T41-139 | M16 L49 | media | deuda documentada en checklist (alcance posterior) | - [?] Balancear materiales: costes proporcionales a rareza M15 y nivel [C] - **QA s2 2026-10-12
T41-140 | M16 L54 | media | deuda documentada en checklist (alcance posterior) | - [?] Campos: id, nombre, descripcion, categoria, nivel [S] - **QA s2 2026-10-12 (Log 1789): co
T41-141 | M16 L168 | media | sin verificacion automatizada disponible | - [?] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]  **G-5.3-F
T41-142 | M16 L234 | media | deuda documentada en checklist (alcance posterior) | - [?] RF9: preview 3D real con modelo del resultado (M45 sin implementar) [C]
T41-143 | M16 L235 | media | deuda documentada en checklist (alcance posterior) | - [?] RF12: SFX master bus + libreria SFX (M91 sin nucleo) [M]
T41-144 | M16 L236 | media | deuda documentada en checklist (alcance posterior) | - [?] RF12: VFX avanzados (M52 sin nucleo) [C]
T41-145 | M16 L238 | media | deuda documentada en checklist (alcance posterior) | - [?] RF3: recetas secretas/ancestrales con feedback dorado adicional (parcial: particulas en d
T41-146 | M16 L265 | media | deuda documentada en checklist (alcance posterior) | - [?] RF9: preview 3D real con modelo del resultado (M45 sin implementar) [C]
T41-147 | M16 L266 | media | deuda documentada en checklist (alcance posterior) | - [?] RF12: SFX master bus + libreria SFX (M91 sin nucleo) [M]
T41-148 | M16 L267 | media | deuda documentada en checklist (alcance posterior) | - [?] RF12: VFX avanzados (M52 sin nucleo) [C]
T41-149 | M16 L268 | media | deuda documentada en checklist (alcance posterior) | - [?] RF14: mas pergaminos en tiendas (M38, solo `pergamino_rec_tela_lino` implementado) [M]
T41-150 | M16 L269 | media | deuda documentada en checklist (alcance posterior) | - [?] M14 `use_item`  emision desde UI de compra/tienda para consumir pergamino automaticamente
T41-151 | M16 L325 | alta | artefacto ausente en disco | - [?] RF-MR9: la estacion elegida se registra en `stations.json` con las recetas de -- Diseno: 
T41-152 | M16 L354 | media | sin verificacion automatizada disponible | - [?] RF-MR19: sonda en ROJO del umbral (mutacion de `CHECKS_MINIMOS` restaurada byte-exacto) [
T41-153 | M64 L69 | media | sin verificacion automatizada disponible | - [?] Verificar que las transiciones respetan la animacion actual  [?] host no permite ejecutar
T41-154 | M64 L114 | media | deuda documentada en checklist (alcance posterior) | - [?] Implementar navmesh del mundo (M08)  [?] dueno: M08 (navmesh voxel)
T41-155 | M64 L126 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M20 (amistad afecta socializacion)  [?] dueno: M20
T41-156 | M64 L127 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M21 (dialogos de socializacion)  [?] dueno: M21
T41-157 | M64 L137 | media | deuda documentada en checklist (alcance posterior) | - [?] Implementar reaccion a construcciones del jugador (M17)  [?] dueno: M17
T41-158 | M64 L139 | media | deuda documentada en checklist (alcance posterior) | - [?] Implementar reaccion a recursos agotados (comentario)  [?] dueno: M17
T41-159 | M64 L161 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M21 (dialogos segun estado)  [?] dueno: M21
T41-160 | M64 L163 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M65 (animales IA)  [?] dueno: M65
T41-161 | M64 L164 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M08 (navmesh del mundo voxel)  [?] dueno: M08
T41-162 | M64 L166 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar con M20 (amistad afecta socializacion)  [?] dueno: M20
T41-163 | M122 L95 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar asserts no eliminados (debug mode)  requiere export_presets de debug (dueno: M117
T41-164 | M122 L96 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar simbolos de debug para stack traces detallados  requiere export_presets con simbo
T41-165 | M122 L97 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar profiling habilitado (M61)  requiere build con profiling (dueno: M61)
T41-166 | M122 L135 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar checkbox en settings (M90)  requiere la UI de settings (dueno: M90)
T41-167 | M122 L138 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar cumplimiento GDPR  requiere revision legal (dueno: COORDINADOR)
T41-168 | M122 L159 | media | deuda documentada en checklist (alcance posterior) | - [?] Disenar minimo impacto en FPS  requiere medicion en build real (dueno: M61)
T41-169 | M122 L191 | media | sin verificacion automatizada disponible | - [?] Disenar tests manuales  requiere sesion de playtest (dueno: M114)
T41-170 | M122 L196 | media | sin verificacion automatizada disponible | - [?] Disenar test de opt-out  depende del opt-out (dueno: M90)
T41-171 | M131 L90 | media | sin verificacion automatizada disponible | - [?] SFX encendido/apagado de menu [S] - KnownIssue no bloqueante DoD: dueno M41/M43 (contenid
T41-172 | M131 L91 | media | sin verificacion automatizada disponible | - [?] SFX navegacion (flecha, enter, escape) [S] - KnownIssue no bloqueante DoD: dueno M41/M43 
T41-173 | M131 L92 | media | sin verificacion automatizada disponible | - [?] Musica lounge suave durante encabezado [S] - KnownIssue no bloqueante DoD: dueno M41/M43;
T41-174 | M131 L93 | media | sin verificacion automatizada disponible | - [?] Fade-out gradual al salir [S] - KnownIssue no bloqueante DoD: dueno M41; no hay pista que
T41-175 | M131 L94 | media | sin verificacion automatizada disponible | - [?] Logo de desarrolladora con sonido calido [S] - KnownIssue no bloqueante DoD: dueno M41; `
T41-176 | M131 L95 | media | sin verificacion automatizada disponible | - [?] Compatibilidad con familia tonal M43 [S] - KnownIssue no bloqueante DoD: dueno M43; no ha
T41-177 | M131 L96 | media | sin verificacion automatizada disponible | - [?] Sin musica fuerte si M91 lo desactiva [S] - KnownIssue no bloqueante DoD: dueno M91/M41; 
T41-178 | M131 L99 | media | sin verificacion automatizada disponible | - [?] SFX puntual solo si interactivo [S] - KnownIssue no bloqueante DoD: dueno M41; sin stream
T41-179 | M34 L15 | media | deuda documentada en checklist (alcance posterior) | - [?] Catalogar los 25 puntos de la seccion 33 del plan maestro [S]  dueno: M01/M136 (plan maes
T41-180 | M34 L71 | media | deuda documentada en checklist (alcance posterior) | - [?] Validacion de orilla accesible a pie (BFS limitado sobre chunks) [M]  idem  M51 / AUDIT 2
T41-181 | M34 L75 | media | deuda documentada en checklist (alcance posterior) | - [?] Marcador visual opcional (ondulaciones / burbujas) [S]  activar_marcador_visual L38-39 (v
T41-182 | M34 L129 | media | deuda documentada en checklist (alcance posterior) | - [?] Indicador de picada clara (icono + sonido + hundimiento) [M]  contrato: picada_iniciada +
T41-183 | M34 L141 | media | deuda documentada en checklist (alcance posterior) | - [?] Sonido de lanzamiento (swish suave) [S]  M42 (Sonido Ambiental  agnes) / M52; senales LAN
T41-184 | M34 L142 | media | deuda documentada en checklist (alcance posterior) | - [?] Sonido de splash al entrar el flotador [S]  idem M42/M52 (con flotador E.2) / AUDIT 2026-
T41-185 | M34 L143 | media | deuda documentada en checklist (alcance posterior) | - [?] Sonido de picada distintivo y relajante [S]  contrato picada_iniciada; samples  M42 (pend
T41-186 | M34 L146 | media | deuda documentada en checklist (alcance posterior) | - [?] VFX de ondulaciones en el punto de impacto [M]  M52 (Particulas y VFX); stub marcador D.1
T41-187 | M2 L14 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Verificar disponibilidad del nombre en Steam (colisiones de titulo) [S]  espera decision 
T41-188 | M2 L15 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Verificar ausencia de marca registrada conflictiva [M]  espera decision (flag doc-in: dec
T41-189 | M2 L16 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Verificar dominio/comunidad que use el nombre (colision de identidad) [S]  espera decisio
T41-190 | M2 L186 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Anotar la decision gratis-vs-DLC como pendiente de negocio (no tecnica) [S] -- espera dec
T41-191 | M2 L211 | media | deuda documentada en checklist (alcance posterior) | - [?] Copiar plan-inicial  plan-actual (espejo vigente) [S] - **INVALIDO POR DISENO (director 2
T41-192 | M2 L225 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Verificar que los modulos dependientes identificados en Requerimientos son correctos  esp
T41-193 | M2 L230 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Confirmar coherencia del alcance v1.0 con CHECKLIST-GLOBAL (153 modulos) [S]  espera deci
T41-194 | M137 L10 | alta | artefacto ausente en disco | - [?] Definir escena `prototipo_isla.tscn` como escena principal [M]  PENDIENTE REAL 2026-10-14
T41-195 | M137 L54 | alta | artefacto ausente en disco | - [?] Definir `inventario_proto.gd` con slot unico [S]  **[?] degradado 2026-10-23 (DeepSeek-V4
T41-196 | M137 L131 | media | artefacto ausente en disco | - [?] Definir plantilla `PLAYTEST.md` con resultados [M]  **[?] degradado 2026-10-23 (DeepSeek-
T41-197 | M137 L155 | media | artefacto ausente en disco | - [?] Definir reporte de rendimiento en `PLAYTEST.md` [M]  **[?] degradado 2026-10-23 (DeepSeek
T41-198 | M137 L178 | media | artefacto ausente en disco | - [?] Definir `GONOGO.md` firmado con fecha [S]  **[?] degradado 2026-10-23 (DeepSeek-V4.1-Flas
T41-199 | M137 L184 | media | artefacto ausente en disco | - [?] Definir doc `RETROSPECTIVA.md` con lecciones tecnicas [M]  **[?] degradado 2026-10-23 (De
T41-200 | M137 L210 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir comentarios XML de clase en cada script [S]  DEGRADADO 2026-10-14 (step-5-kilocod
T41-201 | M163 L59 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar chaman con M19 (NPCs y Vecinos) [M]  dueno: AGENTE DELEGADO M19 (requiere M19 co
T41-202 | M163 L60 | media | deuda documentada en checklist (alcance posterior) | - [?] Integrar chaman con M162 (Dialogos contextuales) [M]  dueno: AGENTE DELEGADO M162 (los 3 
T41-203 | M163 L61 | media | deuda documentada en checklist (alcance posterior) | - [?] El chaman aparece en mapa de ubicaciones (M160) [S]  dueno: AGENTE DELEGADO M160 (requier
T41-204 | M163 L62 | media | deuda documentada en checklist (alcance posterior) | - [?] El chaman tiene rutina diaria (M19) [M]  dueno: AGENTE DELEGADO M19 (diseno de rutina pen
T41-205 | M163 L80 | media | artefacto ausente en disco | - [?] Incienso se puede regalar a NPCs (M19) [S] - dueno: AGENTE DELEGADO M19 (no existe sistem
T41-206 | M163 L96 | media | artefacto ausente en disco | - [?] Cobre Ancestral: intercambio especial + bonus adicional [M]  ability `special_trade x1` d
T41-207 | M163 L120 | media | deuda documentada en checklist (alcance posterior) | - [?] Las mejoras y encantamientos son compatibles [S]  depende del item anterior  **dueno M13/
T41-208 | M88 L36 | alta | KnownIssue documentado, no bloqueante | - [?] Optimizar archivos de fuente  KnownIssue: Optimizar archivos de fuente (accion real, no d
T41-209 | M88 L78 | alta | KnownIssue documentado, no bloqueante | - [?] Disenar pruebas de legibilidad (720p, 1080p, 4K)  KnownIssue: pruebas de legibilidad 720p
T41-210 | M88 L79 | alta | KnownIssue documentado, no bloqueante | - [?] Disenar pruebas de legibilidad en diferentes dispositivos  KnownIssue: pruebas en diferen
T41-211 | M88 L221 | alta | KnownIssue documentado, no bloqueante | - [?] Disenar pruebas de legibilidad en 720p  KnownIssue: prueba legibilidad 720p  ejecucion vi
T41-212 | M88 L222 | alta | KnownIssue documentado, no bloqueante | - [?] Disenar pruebas de legibilidad en 1080p  KnownIssue: prueba legibilidad 1080p  ejecucion 
T41-213 | M88 L223 | alta | KnownIssue documentado, no bloqueante | - [?] Disenar pruebas de legibilidad en 4K  KnownIssue: prueba legibilidad 4K  ejecucion visual
T41-214 | M88 L259 | media | deuda documentada en checklist (alcance posterior) | - [?] Prueba en 1280x720 y 1366x768 (escalado de UI): pendiente (dueno: M58 accesibilidad / M53
T41-215 | M139 L63 | media | artefacto ausente en disco | - [?] Implementar anti-stuck con teleport a waypoint previo (M66) [M]  DEGRADADO a [?] por step
T41-216 | M139 L71 | alta | artefacto ausente en disco | - [?] Integrar precios desde `curvas.json` (M93: lineal clave/suave logaritmica metas) [M]  DEG
T41-217 | M139 L74 | media | artefacto ausente en disco | - [?] Documentar los 60+ items del mundo con precio base (M15) [C]  PENDIENTE REAL 2026-10-14 (
T41-218 | M139 L158 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Definir buses: Music, Ambient, SFX, ASMR, UI [M]  PENDIENTE REAL 2026-10-14 (step-5-kiloc
T41-219 | M139 L190 | media | sin verificacion automatizada disponible | - [?] Asegurar 0 errores en consola al entrar en Play Mode (regla seccion 12) [M]  PENDIENTE DE
T41-220 | M139 L192 | media | sin verificacion automatizada disponible | - [?] Asegurar flujo completo verificado en Play Mode antes de cerrar (seccion 12) [M]  PENDIEN
T41-221 | M21 L62 | media | deuda documentada en checklist (alcance posterior) | - [?] Reportar JSON malformado con archivo, linea y columna [S] (limite: Godot JSON.parse_strin
T41-222 | M21 L63 | media | artefacto ausente en disco | - [?] Detectar IDs duplicados dentro de un grafo [S] (no aplicable: DialogueGraph.load_from_jso
T41-223 | M21 L75 | media | deuda documentada en checklist (alcance posterior) | - [?] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M] / DEGRADADO 
T41-224 | M21 L79 | media | deuda documentada en checklist (alcance posterior) | - [?] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S] / DEGRADADO 2026-11-11 (D
T41-225 | M21 L166 | media | deuda documentada en checklist (alcance posterior) | - [?] Cache de grafos cargados con descarte LRU por limite de memoria [M] / DEGRADADO 2026-11-1
T41-226 | M21 L194 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Test del pipeline end-to-end con dialogo_ejemplo.json en play mode [M]  archivo inexisten
T41-227 | M33 L44 | media | deuda documentada en checklist (alcance posterior) | - [?] P21: recetas con cultivos  catalogo M16 (ensaladas, pan, tintes, ofrendas) [M]  FLIP 2026
T41-228 | M33 L120 | media | deuda documentada en checklist (alcance posterior) | - [?] Interaccion F sobre tierra arada abre selector de semillas (M70/M53) [M]  FLIP 2026-10-28
T41-229 | M33 L126 | media | deuda documentada en checklist (alcance posterior) | - [?] Cancelacion segura del selector sin consumir semillas [S]  FLIP 2026-10-28 (Nemotron, COL
T41-230 | M33 L166 | media | deuda documentada en checklist (alcance posterior) | - [?] Navegacion M64 evita celdas cultivadas cuando hay ruta alternativa [C]  FLIP 2026-10-28 (
T41-231 | M33 L169 | media | deuda documentada en checklist (alcance posterior) | - [?] Cosecha con inventario lleno: sobrante devuelto con notificacion [M]  FLIP 2026-10-28 (Ne
T41-232 | M33 L173 | media | deuda documentada en checklist (alcance posterior) | - [?] Borrado de parcela (M17) con cultivos activos: aviso previo y devolucion de semillas [M] 
T41-233 | M9 L103 | media | artefacto ausente en disco | - [?] Recetas consumibles por M10 (Generacion) via Resource/JSON [M]  QA atria-dawn: FALSO. No 
T41-234 | M9 L104 | media | deuda documentada en checklist (alcance posterior) | - [?] Eje de mezcla (altura+humedad) consumido por M50 (vegetacion) [M]  QA atria-dawn: M50 no 
T41-235 | M9 L105 | media | deuda documentada en checklist (alcance posterior) | - [?] Alturas de bioma consumidas por M61 (LOD/render) [M]  Veredicto hy3 (Log 1087, 2026-09-19
T41-236 | M9 L106 | media | artefacto ausente en disco | - [?] POI consumidos por M71 (descubrimiento) y M74 (eventos) [M]  QA atria-dawn: no hay `poi_*
T41-237 | M9 L107 | media | deuda documentada en checklist (alcance posterior) | - [?] Anti-softlock geografico consumido por M66 [M]  QA atria-dawn: las reglas viven solo como
T41-238 | M151 L255 | media | artefacto ausente en disco | - [?] `generar_acta.py`, `importar_telemetria.py`, `importar_encuestas.py`  los otros 3 modulos
T41-239 | M151 L326 | media | deuda documentada en checklist (alcance posterior) | - [?] **`ci_gates_verdes` no mide lo que nombra:** en `quality.yml` se pasa **hardcodeado `1`**
T41-240 | M151 L335 | alta | artefacto ausente en disco | - [?] **El acta de los 26 puntos no existe** (`acta-control-final.json`): nadie la genera con /
T41-241 | M151 L338 | media | artefacto ausente en disco | - [?] **`test-suite: failure` + `formatting-check: cancelled` en el ultimo CI** (run 3741532728
T41-242 | M151 L369 | media | deuda documentada en checklist (alcance posterior) | - [?] Integracion con M118 CI (gate automatico de release al push)  iter 2 (dueno: deepseek-v4-
T41-243 | M63 L76 | media | deuda documentada en checklist (alcance posterior) | - [?] Pool de meshes reutilizado (M61) [S]  **dueno externo (M61)**: el pool es de M61; el 63 s
T41-244 | M63 L94 | media | deuda documentada en checklist (alcance posterior) | - [?] Escena full-screen con arte del mundo [S]  **dueno externo (M53/arte 2D)**
T41-245 | M63 L95 | media | deuda documentada en checklist (alcance posterior) | - [?] Nubes/parallax en animacion suave [S]  **dueno externo (M53/arte 2D)**
T41-246 | M63 L118 | media | deuda documentada en checklist (alcance posterior) | - [?] Hilos de mesh solo en worker pool [S]  **dueno externo (M08/M61)**
T41-247 | M63 L141 | media | deuda documentada en checklist (alcance posterior) | - [?] Deck: 2048 chunks y texturas comprimidas [M]  **dueno externo (M90)**
T41-248 | M112 L98 | media | sin verificacion automatizada disponible | - [?] Alcanzar cobertura global  40% [C]  pendiente ejecucion real  ADJUDICADO Ling-3.1-Flash (
T41-249 | M112 L99 | media | deuda documentada en checklist (alcance posterior) | - [?] Alcanzar cobertura nucleo  60% [C]  pendiente ejecucion real  ADJUDICADO Ling-3.1-Flash (
T41-250 | M112 L255 | media | deuda documentada en checklist (alcance posterior) | - [?] Validar reporte de cobertura generado con umbrales [M]  pendiente (requiere instrumentaci
T41-251 | M112 L257 | media | sin verificacion automatizada disponible | - [?] Ejecutar suite en una maquina limpia (simulando CI) [C]  pendiente CI real  ADJUDICADO Li
T41-252 | M15 L40 | media | deuda documentada en checklist (alcance posterior) | - [?] resource_catalog.tres existe [M] - **QA s2 2026-10-12 (Log 1787): artefacto citado inexis
T41-253 | M15 L289 | media | deuda documentada en checklist (alcance posterior) | - [?] Meshes del arte (placeholders funcionales ahora) [C]
T41-254 | M15 L322 | media | deuda documentada en checklist (alcance posterior) | - [?] Meshes del arte (SIGUE de iter 3): dueno M45/M47 [C]
T41-255 | M15 L345 | media | deuda documentada en checklist (alcance posterior) | - [?] Meshes del arte (SIGUE de iter 3): dueno M45/M47 [C]
T41-256 | M18 L255 | media | deuda documentada en checklist (alcance posterior) | - [?] Escalera-torre de la Mansion: 0 solapes [S]  **QA AABB no reproducible** (ver nota Q)
T41-257 | M18 L257 | media | deuda documentada en checklist (alcance posterior) | - [?] Escalera-tabique de Agricultor/Mercader: 0 solapes [S]  **QA AABB no reproducible** (ver 
T41-258 | M18 L258 | media | deuda documentada en checklist (alcance posterior) | - [?] AABB 0 mueble-estructura en las cuatro casas [M]  **QA AABB no reproducible** (ver nota Q
T41-259 | M18 L259 | media | deuda documentada en checklist (alcance posterior) | - [?] AABB 0 mueble-mueble en las cuatro casas [M]  **QA AABB no reproducible** (ver nota Q)
T41-260 | M22 L74 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir el desarrollo del misterio por capitulo [M]  **agnes-3-flash (2026-10-13): `m22_s
T41-261 | M22 L75 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir la informacion oculta (5 caches) [M]  **agnes-3-flash (2026-10-13): `m22_spec.md`
T41-262 | M22 L76 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir la entrega de lore por contexto (mural/inscripcion/objeto) [M]  **agnes-3-flash (
T41-263 | M22 L77 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir el cierre del misterio en el final [S]  **agnes-3-flash (2026-10-13): `m22_spec.m
T41-264 | M60 L200 | alta | KnownIssue documentado, no bloqueante | - [?] M62: UI interactiva deshabilitada durante guardado/carga (anti clicks rapidos) [M] -- ite
T41-265 | M60 L202 | alta | deuda cross-modulo (dueno M63) | - [?] M63: carga de escena mundo < 2 s desde el menu (objetivo de build) [C] -- iter. 4: objeti
T41-266 | M60 L214 | alta | KnownIssue documentado, no bloqueante | - [?] M15/M16/M33: recetas y cultivos como Resources tipados (agregar .tres M16/M33) [M] -- agn
T41-267 | M60 L241 | media | sin verificacion automatizada disponible | - [?] Optimizacion: presupuestos RN verificados con el Profiler de Godot [M] -- iter. 4: el Pro
T41-268 | M82 L72 | media | artefacto ausente en disco | - [?] Definir proceso de QA interno antes de cada submission  KnownIssue no bloqueante DoD: che
T41-269 | M82 L82 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir proceso para cada plataforma que requiere submission propia  KnownIssue no bloque
T41-270 | M82 L86 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir proceso para versiones de consola vs. PC  KnownIssue no bloqueante DoD: diferenci
T41-271 | M82 L128 | alta | artefacto ausente en disco | - [?] Completar submissions a plataformas antes de M141 Beta  KnownIssue no bloqueante DoD: sub
T41-272 | M3 L67 | media | artefacto ausente en disco | - [?] Documentar carpetas futuras de Unity (Assets/, Builds/, Obsoletos/, Epics/) fuera de DOCU
T41-273 | M3 L68 | media | artefacto ausente en disco | - [?] Verificar que la estructura real coincide con la documentada [M] / REVERIFICADO 2026-10-1
T41-274 | M3 L69 | media | sin verificacion automatizada disponible | - [?] Documentar donde NO deben crearse archivos de log en runtime (fuera de Assets/) [S] / REV
T41-275 | M108 L319 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Presets de importacion por tipo (RF5): pendiente  requiere definir import settings por ti
T41-276 | M108 L320 | media | deuda documentada en checklist (alcance posterior) | - [?] Reglas de tamano/compresion VRAM auditables (RF6 completo): el validador audita tamano; m
T41-277 | M108 L321 | media | deuda documentada en checklist (alcance posterior) | - [?] Flujo `assets/staging/`  aprobacion (RF1): carpeta creada en caliente por la guia; el pro
T41-278 | M138 L122 | alta | artefacto ausente en disco | - [?] Definir reporte `REPORTE-FPS.md` generado por `bench_slice.gd` [C]  03-Diseno Cierre: too
T41-279 | M138 L138 | media | artefacto ausente en disco | - [?] Definir analisis de encuesta en `PLAYTEST.md` [M]  03-Diseno Protocolo: tabla por tester 
T41-280 | M138 L152 | media | artefacto ausente en disco | - [?] Definir `IDEAS-DESCARTADAS.md` para lo que no entra [S]  03-Diseno: 1 linea por idea (fec
T41-281 | M44 L100 | media | deuda documentada en checklist (alcance posterior) | - [?] M45: abrir contenedores con receta de caja  receta abrir_contenedor existe en datos; M45 
T41-282 | M44 L103 | media | deuda documentada en checklist (alcance posterior) | - [?] M31: capas de hora cambian microfoley  set_contexto() existe (feedback_director.gd L72) p
T41-283 | M44 L109 | media | deuda documentada en checklist (alcance posterior) | - [?] M29: pausa congela microfoley sin residuos  pausar()/reanudar() son stubs `pass` (feedbac
T41-284 | M62 L190 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Baseline menu principal: objetivo < 600 MB [S]  **[?] 2026-10-20 (Tanda 78, DS-Opencode):
T41-285 | M62 L193 | media | artefacto ausente en disco | - [?] Baseline subterraneo del templo (M26): objetivo < 2.000 MB [S]  **[?] 2026-10-20 (Tanda 8
T41-286 | M62 L194 | media | artefacto ausente en disco | - [?] Baseline tormenta maxima (M32) + banco de audio completo:  2.500 MB (Alta) [S]  **[?] 202
T41-287 | M68 L77 | media | artefacto ausente en disco | - [?] Descuentos visibles en el panel (M53)  iter. 1 DeepSeek-V4.1-Flash 2026-09-11: `list_rout
T41-288 | M68 L114 | media | deuda documentada en checklist (alcance posterior) | - [?] Marcadores de paradas en el mapa (M54)  iter. 1 DeepSeek-V4.1-Flash 2026-09-11: el datase
T41-289 | M68 L196 | media | deuda documentada en checklist (alcance posterior) | - [?] Viajar al destino destruido (ruina M25) o con el vehiculo en uso (M67)  iter. 1 DeepSeek-
T41-290 | M69 L47 | alta | deuda cross-modulo (dueno M91) | - [?] Volumen configurable por bus (M91) [S]  **[x][?] barrido atria (Log 1760):** claim de **M
T41-291 | M69 L208 | media | deuda documentada en checklist (alcance posterior) | - [?] UI del viaje (mapa M54 + atajo M57) y ejecucion del viaje (M28)  iter 2 (dueno: deepseek-
T41-292 | M69 L213 | media | deuda documentada en checklist (alcance posterior) | - [?] Anclas de COR/CEN/AUR cuando su acceso este implementado (iter 3, dueno: deepseek-v4-flas
T41-293 | M103 L186 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir busqueda de texto [S] -- [?]  no hay API de busqueda de texto en logger.gd; depen
T41-294 | M103 L189 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir scroll en consola in-game [S] -- [?]  sin consola in-game propia; depende de M110
T41-295 | M109 L218 | media | sin verificacion automatizada disponible | - [?] Verificacion visual del dock del editor: pendiente  requiere reinicio del editor de Godot
T41-296 | M109 L225 | media | deuda documentada en checklist (alcance posterior) | - [?] Panel del editor de dialogos en el dock (vista de grafo + edicion de texto de nodo)  iter
T41-297 | M12 L97 | media | deuda documentada en checklist (alcance posterior) | - [?] Fuente: texturas de biomas del generador (M10) [M] -- QA atria-dawn: sistema de minimapa 
T41-298 | M12 L117 | media | deuda documentada en checklist (alcance posterior) | - [?] 1 camara activa + minimapa con textura (sin camaras extras) [M]  requiere M54-Mapa (4/176
T41-299 | M140 L84 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir la meta de partida completa 60-100 h [M]  PENDIENTE REAL 2026-10-14 (step-5-kiloc
T41-300 | M140 L166 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir flujo completo verificado en Play Mode en las 4 islas [M]  PENDIENTE REAL 2026-10
T41-301 | M145 L108 | media | sin verificacion automatizada disponible | - [?] Verificar que sonidos tienen representacion visual  requiere audio integrado (M41-M44); 3
T41-302 | M145 L109 | media | sin verificacion automatizada disponible | - [?] Verificar que eventos visuales tienen audio  requiere VFX integrados (M52); 3 disenado. M
T41-303 | M154 L114 | media | deuda documentada en checklist (alcance posterior) | - [?] Boton/tecla de captura directa a Logs/screenshots/ [M] (s2 Log 1637: bug colision nombres
T41-304 | M154 L172 | media | sin verificacion automatizada disponible | - [?] Iterar primer NPC completo end-to-end con screenshots hasta aprobacion del usuario [C] (a
T41-305 | M161 L205 | media | deuda documentada en checklist (alcance posterior) | - [?] Modelos 3D/retratos M46 de los 23 disenos (dueno: M45/M46 + Hy4)  el dataset esta listo p
T41-306 | M161 L206 | media | deuda documentada en checklist (alcance posterior) | - [?] Variantes estacionales (RF6): la maquina `variantes_estacionales` esta vacia en los 23 (d
T41-307 | M162 L96 | media | sin verificacion automatizada disponible | - [?] 47. Verificar que las misiones del Carpintero sean completables / AUDIT 2026-10-14 (step-
T41-308 | M162 L168 | media | sin verificacion automatizada disponible | - [?] 101. Verificar que el Artista mencione ubicaciones de M160 / [PREMISA OBSOLETA 2026-11-01
T41-309 | M23 L21 | media | deuda documentada en checklist (alcance posterior) | - [?] Crear la historia de la doctora [M]  0 NPC medicos en data/villagers/ (14 villagers medid
T41-310 | M23 L35 | media | artefacto ausente en disco | - [?] Definir el tipo de paso "construir" para cadenas de construccion [M]  **Duenos M22/M17 (d
T41-311 | M31 L92 | media | sin verificacion automatizada disponible | - [?] Compatible con M12 minimapa (sin luz) [S]  M12 minimapa sin implementar (fila 12 global);
T41-312 | M31 L220 | media | deuda documentada en checklist (alcance posterior) | - [?] Luna esferica con textura de fases (M45) [C] / AUDIT 2026-10-14 (step-5-kilocode): luz Di
T41-313 | M45 L140 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir asset_catalog.json con: asset_id, categoria, bioma, estado, dueno, prioridad, dep
T41-314 | M45 L148 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir script validate_mesh.gd en Assets/_Project/Editor/ [M]
T41-315 | M50 L197 | media | deuda documentada en checklist (alcance posterior) | - [?] VegetationManager (spawn por bioma/estacion, pooling, densidad)  iter 2 (dueno: deepseek-
T41-316 | M50 L203 | media | deuda documentada en checklist (alcance posterior) | - [?] Instanciacion en el mundo (M08 poblar)  iter 3 (dueno: deepseek-v4-flash-vision-exp)
T41-317 | M52 L60 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir VfxManager (autoload) [M]  `VfxManager inexistente  impl real VfxDirector sin aut
T41-318 | M52 L242 | media | deuda documentada en checklist (alcance posterior) | - [?] Catalogo de VFX por evento (M44 feedback + M92 tutorial): iter 2  catalogo data-driven (d
T41-319 | M53 L137 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Toasts con icono y SFX por tipo (obtencion, evento, mision) [M]  **FALSO VERDE confirmado
T41-320 | M53 L224 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] Minimapa con textura cache sin regeneracion por frame [M] - **QA Step 5 2026-10-12 (msg 2
T41-321 | M55 L147 | media | deuda documentada en checklist (alcance posterior) | - [?] Abrir fotografia en pantalla completa sin lag (M61) [M]  **dueno M56/M61:** sin fotos que
T41-322 | M55 L212 | media | artefacto ausente en disco | - [?] Probar 14 categorias con al menos 1 entrada cada una [M] - 13/14: fotografias tiene 0 ent
T41-323 | M59 L157 | media | artefacto ausente en disco | - [?] Guardar opciones graficas (M90), audio (M91), accesibilidad (M58) e idioma (M87) [M]  **G
T41-324 | M59 L172 | alta | deuda cross-modulo (dueno M61) | - [?] Guardado en background thread (< 80 ms) [C]  *MEDIDO (iter. 1, Log 1197, rondas intercala
T41-325 | M72 L137 | media | sin verificacion automatizada disponible | - [?] RN5: nombres y descripciones usan claves i18n con espanol base [S] -- agnes-2026-09-06: M
T41-326 | M72 L162 | media | sin verificacion automatizada disponible | - [?] Disenar validacion de catalogo en editor con errores accionables (tool) [M] -- agnes-2.5-
T41-327 | M85 L105 | media | deuda documentada en checklist (alcance posterior) | - [?] Agregar paso de validacion de modelos en build_script.gd  REVERTIDO por re-auditoria H2-e
T41-328 | M85 L106 | alta | artefacto ausente en disco | - [?] Build falla si hay licencia de modelo invalida - BUG-070 lote 10 re-verif (atria-dawn, ev
T41-329 | M117 L139 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Definir smoke del artifact (no del runner) [C]  T-043 sin script smoke (dueno M118)
T41-330 | M129 L134 | media | deuda documentada en checklist (alcance posterior) | - [?] Crear pipeline de renderizado 3D de mockups realistas de merchandising para catalogo web 
T41-331 | M14 L183 | media | deuda documentada en checklist (alcance posterior) | - [?] Soporte completo de gamepad y teclado/mouse [C]  **QA atria-dawn 2026-09-18 (Log 1047): g
T41-332 | M147 L301 | media | deuda documentada en checklist (alcance posterior) | - [?] Aplicacion del canon en gameplay (M22 historia/sellos  dueno: Hy3/WorkBuddy)
T41-333 | M148 L224 | media | deuda documentada en checklist (alcance posterior) | - [?] Contenido narrativo por lugares nuevos (iter 2  dueno: deepseek-v4-flash-vision-exp)
T41-334 | M164 L42 | media | decision de diseno pendiente (fuera de este modulo) | - [?] Paquetes de gemas: 1 gema (1 USD), 10 gemas (8 USD), 20 gemas (15 USD) [S]  **iter 1: blo
T41-335 | M17 L134 | alta | claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta | - [?] La demolicion de piezas funcionales (camas, almacenamiento) libera su contenido [C]  **[x
T41-336 | M26 L202 | media | deuda documentada en checklist (alcance posterior) | - [?] Implementacion de salas/puzzles en el mundo (M24/M25 framework + gen de ruinas) y la cone
T41-337 | M35 L58 | media | deuda documentada en checklist (alcance posterior) | - [?] Sonidos de golpe y extraccion por material [S] *(placeholder; M43)*
T41-338 | M38 L41 | alta | deuda cross-modulo (dueno M38) | - [?] RF13: persistencia de saldo, reputacion, historial e inventarios de tienda [M]  PARCIAL: 
T41-339 | M48 L177 | alta | artefacto ausente en disco | - [?] Verificar coste por actor en animation_budget.json [M]  **[?] NO RESUELTO 2026-10-29 (Dee
T41-340 | M51 L233 | media | deuda documentada en checklist (alcance posterior) | - [?] Animacion de superficie de agua (ondas, transparencia, reflejos) y materiales  iter 2 (du
T41-341 | M56 L341 | media | deuda documentada en checklist (alcance posterior) | - [?] DoF selectivo (foco claro, RF6) y camara libre/zoom/filtros en vivo (RF1-RF4)  iteracion 
T41-342 | M58 L228 | media | deuda documentada en checklist (alcance posterior) | - [?] Aplicar la config a la UI (tamano/contraste en runtime con M53)  iter 2 (dueno: deepseek-
T41-343 | M61 L221 | media | sin verificacion automatizada disponible | - [?]Validar festival (M74) sin picos [C]  **no medible en headless** (Log 2068): VFX + frame t
T41-344 | M96 L210 | media | sin verificacion automatizada disponible | - [?] Verificacion con Steam real (M77 online + middleware)  cuando exista credenciales de Stea

== LIMITES ==
Sin cambios en checklists ni codigo. Sin flips. Sin commit/push.

