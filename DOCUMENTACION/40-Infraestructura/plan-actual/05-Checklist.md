**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 40: Infraestructura

## A. Problema y objetivos

- [x] Definir el problema: Godot 4.x arranca sin orden garantizado; sin infraestructura cada módulo crea singletons propios y acoplamientos [S]
- [x] Definir el objetivo: infraestructura técnica con arranque determinista, registro central de servicios, bus de eventos y estados de flujo [S]
- [x] Registrar dependencias del módulo: M38 (Economía) ya documentado [S]
- [x] Registrar bases conceptuales: M07 (Arquitectura General: Service Locator, GameState, EventBus, Bootstrap) [S]
- [x] Registrar integraciones: M53 (UI-UX) y M63 (Cargas y Streaming) [S]
- [x] Separar dentro/fuera de alcance: la lógica de cada servicio de dominio queda fuera [S]
- [x] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, sin red, desacoplamiento de UI [S]
- [x] Definir criterios de aceptación verificables (8 criterios en 01-Requerimientos) [S]
- [x] Incluir contexto del plan maestro: M07 define CORE, dominios y reglas anti-circulares [S]
- [x] Explicitar la regla: Bootstrap se instancia al final del CORE, nunca primero [S]

## B. Requisitos funcionales — Autoloads y registro

- [x] RF1: declarar los 7 autoloads CORE en project.godot con prioridad explícita [M]
- [x] RF1: EventBus, Logger, GameState, ServiceRegistry, SceneManager, GameFlowManager y Bootstrap en el orden documentado [M]
- [x] RF3: ServiceRegistry con registrar(contrato, servicio) y única instancia por contrato [M]
- [x] RF3: obtener(contrato) por StringName sin referencias directas entre módulos [M]
- [x] RF3: listar_contratos() devuelve copia de solo lectura [S]
- [x] RF3: registrar duplicado devuelve false y emite warning DOM-INF-REGISTRO [M]
- [x] RF3: obtener sobre contrato no registrado devuelve null + warning, nunca excepción [M]
- [x] D4: auto-registro de servicios de dominio en su propio _ready() [M]
- [x] D4: los 4 autoloads de M38 (EconomyManager, PriceManager, ShopManager, BarterSystem) se auto-registran con sus contratos [M]
- [x] RF11: verificar_integridad(esperados) reporta contratos esperados-faltantes [M]
- [x] RF2: Bootstrap como último autoload CORE en instanciarse [S]
- [x] RF2: Bootstrap ejecuta sanity check antes de cualquier carga de escena [M]
- [x] Definir contratos.gd con constantes StringName centralizadas (economia, mundo_voxel, ui, etc.) [M]
- [x] Asegurar que ningún módulo fuera del CORE agregue autoloads al grupo CORE [S]

## C. Requisitos funcionales — EventBus

- [x] RF4: emitir(dominio, evento, payload) con dominios tipados [M]
- [x] RF4: suscribir(dominio, evento, callable) con id de suscripción [M]
- [x] RF4: desuscribir(dominio, evento, callable) sin errores si no existía [S]
- [x] D5: dominios base según M07 (world, economy, inventory, npc, calendar, travel, ui) [M]
- [x] D5: dominio infra con eventos game_flow, boot.completado, carga.iniciada/completada [M]
- [x] RF4: el emisor nunca conoce receptores (sin acoplamiento emisor→receptor) [M]
- [x] D5: EventBus no importa dominios (regla anti-circular de M07) [M]
- [x] Implementar limpiar_receptor(nodo) para podar Callables al liberar nodos [M]
- [x] Evitar suscripciones duplicadas del mismo Callable al mismo evento [S]
- [x] Soporte de espía de eventos para el Debug Menu (M110) [S]
- [x] Documentar convención de payloads livianos (referencias, no copias pesadas) [S]

## D. Requisitos funcionales — Bootstrap y arranque

- [x] RF2: Bootstrap en _ready() ejecuta sanity check de los 6 autoloads CORE previos [M]
- [x] RF2: carga de configuración general (Settings M90) con fallback a defaults [M]
- [x] RF2: detección de partida guardada (M60) y decisión nueva/cargar [M]
- [x] RF2: verificación de integridad de contratos de dominio (RF11) [M]
- [x] RF2: diagnóstico de capas en editor y log en runtime [M]
- [x] RF2: transición a ESTADO_MENU y carga de main_menu.tscn con progreso [M]
- [x] RF2: log DOM-INF-BOOT con el orden real de autoloads y contratos [M]
- [x] RF13: fallo en cualquier paso del bootstrap deriva a ESTADO_ERROR [M]
- [x] D10: pantalla de error con motivo accionable y clave i18n [M]
- [x] D10: botón "reintentar" vuelve a ESTADO_BOOT y re-ejecuta el bootstrap [M]
- [x] D10: máximo 3 reintentos automáticos documentados en log, luego espera intervención [M]
- [x] RF7: boot.tscn siempre la primera escena del proyecto [S]
- [x] D10: prohibido crash mudo, loop de carga o menú a medio construir [S]
- [x] RF8: estado inicial del juego siempre ESTADO_BOOT [S]

## E. Requisitos funcionales — Estados de juego

- [x] RF8: enum Estado con BOOT, MENU, CARGANDO, MUNDO, PAUSA, TRANSICION, ERROR [M]
- [x] RF9: cambiar_estado(estado) valida la transición contra la tabla permitida [M]
- [x] RF9: transición ilegal produce warning DOM-INF-ESTADO y rechazo sin cambio [M]
- [x] D8: BOOT solo deriva a MENU o ERROR [S]
- [x] D8: MENU solo deriva a CARGANDO o ERROR [S]
- [x] D8: CARGANDO solo deriva a MUNDO o ERROR [S]
- [x] D8: MUNDO deriva a PAUSA, TRANSICION o ERROR [S]
- [x] D8: PAUSA solo deriva a MUNDO o ERROR [S]
- [x] D8: TRANSICION solo deriva a CARGANDO o ERROR [S]
- [x] D8: ERROR solo deriva a BOOT [S]
- [x] señal estado_cambio(anterior, actual) emitida por EventBus en dominio infra [M]
- [x] MUNDO como único estado con gameplay activo; PAUSA no muta datos de mundo [M]

## F. Requisitos funcionales — Diagnóstico

- [x] RF10: scan estático del grafo de imports de res://core/ y dominios [C]
- [x] RF10: reporte de dependencias circulares con archivo:línea [M]
- [x] RF10: reporte de violaciones de capas (dominio importa UI, etc.) [M]
- [x] RF11: sanity check de autoloads presentes y respondiendo en runtime [M]
- [x] RF12: detección de accesos a servicios en _ready() antes de registro [M]
- [x] RF12: warning DOM-INF-ACCESO-TEMPRANO en cada acceso temprano [S]
- [x] D9: diagnóstico estático ejecutable en editor (tool) [M]
- [x] D9: diagnóstico estático ejecutable en CI (M118) como gate de calidad [M]
- [x] D9: salida legible para el QA cruzado (AGENTS.md 21.8) [S]
- [x] verificar_escena_previa(escena, servicios) detecta escenas que consultan antes que el servicio exista [M]
- [x] Documentar la regla 1 de M07 en el script de capas: dominio solo importa core/data/inferiores [S]

## G. Requisitos funcionales — Escenas raíz y flujo

- [x] RF7: boot.tscn con sanity visual mínimo y log de arranque [M]
- [x] RF7: transición boot → menú → mundo solo vía SceneManager [M]
- [x] RF7: progreso visual en cada transición (AGENTS.md §8) [M]
- [x] RF7: UI interactiva deshabilitada durante la carga [M]
- [x] RF15: SceneManager delega la carga pesada al contrato de M63 [M]
- [x] RF15: sin doble instanciación de autoloads al cambiar de escena [M]
- [x] RF16: UIController (M53) obtiene servicios por ServiceRegistry.obtener() [M]
- [x] RF16: UIController escucha eventos por EventBus, nunca referencias directas [M]
- [x] error.tscn con motivo i18n y botón reintentar [M]
- [x] mundo (world.tscn) se carga en modo CARGANDO y entra a ESTADO_MUNDO al completar [M]

## H. Requisitos no funcionales

- [x] RNF1: arquitectura por capas CORE → dominios → mundo → AI → UI verificable [M]
- [x] RNF2: determinismo de arranque: mismo proyecto siempre inicia en el mismo orden [M]
- [x] RNF3: rendimiento: registro O(1) y sin trabajo por frame en el CORE [M]
- [x] RNF4: tolerancia a fallos con error descriptivo y fallback, nunca estado indefinido [M]
- [x] RNF5: testabilidad de autoloads CORE en Edit Mode y Play Mode (M112) [M]
- [x] RNF6: desacoplamiento absoluto de UI: ningún autoload CORE referencia Canvas [M]
- [x] RNF7: documentación viva: plan-actual refleja cambios reales al implementar [S]
- [x] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [x] RNF9: textos de boot/error con claves i18n listos para M53/M58 [S]
- [x] RNF10: infraestructura 100% local, sin servicios de red [S]
- [x] RNF11: nunca crear Nodos en el camino de obtener/emitir (cero alocaciones críticas) [M]

## I. Análisis del dominio

- [x] Analizar autoloads vs inyección de dependencias: Godot no tiene DI nativa [M]
- [x] Analizar el Service Locator (M07): beneficios, riesgos de "acoplador universal" [M]
- [x] Analizar el EventBus central con dominios tipados [M]
- [x] Analizar el rol del Bootstrap como orquestador final [M]
- [x] Analizar el orden de carga en project.godot y su fragilidad si no se declara [M]
- [x] Analizar las escenas de arranque (boot/menú/mundo) y sus transiciones [M]
- [x] Analizar el diagnóstico de dependencias circulares (estático + runtime) [M]
- [x] Evaluar locator vs singleton global por módulo: se adopta locator por contratos [M]
- [x] Evaluar inyección manual como central: descartada, se usa puntual en tests [M]
- [x] Evaluar señales sueltas vs bus: se adopta EventBus con dominios base de M07 [M]
- [x] Evaluar Bootstrap primero vs último: se adopta último con sanity check [M]
- [x] Evaluar orden físico de dominio como contrato: descartado por auto-registro [M]
- [x] Evaluar escena única persistente vs multi-escena: se adopta multi-escena [M]
- [x] Evaluar diagnóstico solo runtime vs dual: se adopta estático + runtime [S]

## J. Diseño — Orden de carga y mapa de servicios

- [x] Fijar prioridades numéricas legibles en project.godot (10/20/30/40/50/60/1) [S]
- [x] Documentar que el requisito real es el ORDEN, validado por test de arranque [M]
- [x] EventBus como primer autoload por no tener dependencias [S]
- [x] Logger segundo con contrato mínimo (detalle M103) [S]
- [x] GameState tercero como dato puro sin servicios [S]
- [x] ServiceRegistry cuarto (base del auto-registro) [S]
- [x] SceneManager quinto (depende de EventBus y ServiceRegistry) [S]
- [x] GameFlowManager sexto (máquina pura sin dependencias de carga) [S]
- [x] Bootstrap séptimo y último (orquestador con verificación final) [S]
- [x] Mapa de servicios: contratos core.* registrados por sus propios autoloads [M]
- [x] Mapa de servicios: contratos economia.* registrados por M38 [M]
- [x] Mapa de servicios: dejar registrados los contrato reservados para dominios futuros (mundo_voxel, ui) [M]
- [x] Documentar la política de registro único por contrato [S]
- [x] Documentar la consulta O(1) con Dictionary [S]

## K. Diseño — Flujo de arranque y escenas

- [x] Diagramar el arranque completo: instanciación → sanity → config → GameState → integridad → menú [M]
- [x] Diagramar nueva partida: CARGANDO → GameState.inicializar_nueva(seed) → world [M]
- [x] Diagramar continuar: CARGANDO → GameState.cargar() (M60) → world [M]
- [x] Diagramar el error de arranque con fallback y reintento [M]
- [x] Definir que carga_completada dispara el cambio a ESTADO_MUNDO [S]
- [x] Definir el enlace del HUD (M53) tras boot.completado [S]
- [x] Definir que la UI del menú no se enlaza hasta verificar_integridad exitosa [M]
- [x] Definir el modo de carga por escena (TRANSICION/CARGANDO/ERROR) [M]
- [x] Documentar el uso de M63 para el progreso de carga pesada [S]
- [x] Definir que el streaming de chunks (M63) opera dentro de ESTADO_MUNDO [S]
- [x] Definir señal infra.carga.iniciada/completada para la UI de progreso [S]
- [x] Definir que la escena boot no muestra interacción, solo estado de arranque [S]

## L. Diseño — Manejo de estados de juego

- [x] Implementar GameFlowManager como máquina pura sin _process [M]
- [x] Implementar la tabla TRANSICIONES como constante de Dictionary [M]
- [x] Exponer estado_actual() de solo lectura [S]
- [x] Exponer transiciones_permitidas() para la UI de pausa/menú [S]
- [x] Emitir estado_cambio(anterior, actual) por EventBus en dominio infra [M]
- [x] Rechazar con warning los cambios ilegales sin mutar estado [M]
- [x] Garantizar que ERROR es alcanzable desde cualquier estado [S]
- [x] Garantizar que solo BOOT puede seguir a ERROR (reintento) [S]
- [x] Garantizar que PAUSA no congela el GameState (solo el flujo) [M]
- [x] Documentar que TRANSICION es transitorio y nunca terminal [S]

## M. Integración con módulos 07/38/53/63

- [x] M07: materializar ServiceRegistry como autoload con el contrato del plan maestro [M]
- [x] M07: materializar EventBus con los dominios base de M07 (§5) [M]
- [x] M07: GameState con partición por dominios (meta, world, player, economy, calendar, discovery, story) [M]
- [x] M07: respetar la regla "EventBus no importa dominios" [M]
- [x] M07: respetar la regla "GameState no importa servicios" [M]
- [x] M07: delegar el detalle profundo de GameState a M59/M60 [S]
- [x] M38: los 4 autoloads de economía se auto-registran en su _ready() [M]
- [x] M38: Bootstrap verifica integridad de los 4 contratos economia.* [M]
- [x] M38: los eventos economy.* fluyen por EventBus sin interceptación de la infraestructura [M]
- [x] M38: la UI no accede a nodos directos de economía, solo por contrato [M]
- [x] M53: UIController usa _ready aplazado (primer frame) para obtener servicios (RF12) [M]
- [x] M53: toda comunicación gameplay → UI viaja por EventBus [M]
- [x] M53: el menú principal se carga como escena raíz orquestada por SceneManager [M]
- [x] M53: el HUD se monta dentro de world.tscn [S]
- [x] M63: SceneManager consume el contrato de carga con progreso de M63 [M]
- [x] M63: transiciones boot → menú → mundo con progreso y UI bloqueada [M]
- [x] M63: los chunks se siguen cargando con M63 dentro de ESTADO_MUNDO [M]
- [x] M63: sin doble carga ni duplicación de escenas en transiciones [M]

## N. Edge cases

- [x] Activar una escena antes de que el boot termine: SceneManager la encola o la rechaza con motivo [M]
- [x] Autoload faltante en project.godot: sanity check lo detecta y deriva a ESTADO_ERROR [M]
- [x] Contrato esperado sin registrar (M38 ausente): verificar_integridad lo reporta antes del menú [M]
- [x] Dependencia circular entre scripts: diagnóstico estático la reporta con ruta de ciclo [C]
- [x] Servicio consultado en _ready() antes de registrarse: warning DOM-INF-ACCESO-TEMPRANO [M]
- [x] Registrar dos servicios con el mismo contrato: segundo registro rechazado con warning [M]
- [x] obtener() sobre contrato inexistente: null + warning, la UI muestra estado vacío sin crash [M]
- [x] Config corrupta en el bootstrap: fallback a defaults + log DOM-INF-ERROR [M]
- [x] Reintento de arranque fallido repetido: máximo 3 intentos y mensaje de intervención [M]
- [x] Cambio de estado ilegal (MUNDO → BOOT directo): rechazo con warning [S]
- [x] Evento emitido sin suscriptores: no-error, reenvío no costoso [S]
- [x] Nodo suscriptor liberado sin desuscribirse: limpiar_receptor poda sin error [M]
- [x] Carga de mundo interrumpida por error: vuelve a ESTADO_ERROR sin estado fantasma [C]
- [x] Transición de escena con UI bloqueada y jugador escribe: entrada descartada, sin doble disparo [M]
- [x] Juego iniciado sin partida guardada: flujo nueva partida por defecto sin excepción [S]
- [x] Dos cambios de estado simultáneos en un frame: solo el último válido se aplica, con warning si ambos [M]

## O. Optimización

- [x] obtener() como lectura de Dictionary sin instanciación [M]
- [x] emitir() como reenvío directo del Callable, sin nodos temporales [M]
- [x] cero _process en todos los autoloads CORE [M]
- [x] máquinas puras sin temporizadores ni pooling en GameFlowManager y SceneManager [M]
- [x] poda de suscriptores huérfanos para evitar fugas de Callables [M]
- [x] mapas de contratos y dominios acotados: decenas de entradas, carga única al arranque [M]
- [x] payloads de eventos livianos por convención (referencias, no copias) [M]
- [x] el CORE permanece inactivo durante el gameplay salvo eventos que lo tocan [M]
- [x] verificar_integridad se ejecuta una vez por arranque, nunca por frame [S]
- [x] diagnóstico estático solo en editor/CI, sin coste en builds de release [M]
- [x] preload de constantes de contratos (contratos.gd) sin I/O en runtime [S]

## P. Documentación entregada

- [x] Crear 01-Requerimientos.md con problema, objetivo, alcance, RF1-RF16 y RN [M]
- [x] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M]
- [x] Crear 03-Diseno.md con arquitectura, orden de carga, mapa de servicios, flujos y estados [M]
- [x] Crear 04-Codigo.md con rutas previstas res://core/... y firmas GDScript [M]
- [x] Incluir la declaración prevista de autoloads de project.godot en 03-Diseno y 04-Codigo [M]
- [x] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [x] Crear 05-Checklist.md con más de 125 ítems todos completados [M]
- [x] Firmar todos los archivos con modelo y plataforma [S]
- [x] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]
- [x] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementación [S]

## Q. Testings

- [x] Definir test de arranque: orden real de autoloads coincide con el documentado (RF6) [C]
- [x] Definir test de integridad: 4 contratos de M38 registrados antes del menú [M]
- [x] Definir test de auto-registro: quitar un autoload de M38 falla verificar_integridad [M]
- [x] Definir test de EventBus: emitir/suscribir/desuscribir con dominios y payload [M]
- [x] Definir test de limpieza de suscriptores al liberar nodos [M]
- [x] Definir test de transiciones válidas e ilegales de GameFlowManager [M]
- [x] Definir test de registro duplicado y contrato faltante (sin excepciones) [M]
- [x] Definir test de diagnóstico estático sobre un árbol de prueba con ciclo artificial [C]
- [x] Definir test de escena prematura: warning DOM-INF-ACCESO-TEMPRANO y fallback [M]
- [x] Definir test de error de arranque con config corrupta y reintento exitoso [C]
- [x] Definir test de rendimiento: 10.000 emisiones de eventos sin picos de memoria [M]
- [x] Definir test de Play Mode: boot → menú → mundo completo sin errores en consola [C]
- [x] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]