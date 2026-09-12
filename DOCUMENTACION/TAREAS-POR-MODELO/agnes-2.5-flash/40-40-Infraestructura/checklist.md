# Tareas módulo 40 40-Infraestructura

**Estado:** 🔵 En curso

**Items pendientes:** 116

[ ] T-40-001: Definir el problema: Godot 4.x arranca sin orden garantizado; sin infraestructura cada módulo crea singletons propios y acoplamientos
[ ] T-40-002: Definir el objetivo: infraestructura técnica con arranque determinista, registro central de servicios, bus de eventos y estados de flujo
[ ] T-40-003: Registrar dependencias del módulo: M38 (Economía) ya documentado
[ ] T-40-004: Registrar integraciones: M53 (UI-UX) y M63 (Cargas y Streaming)
[ ] T-40-005: Separar dentro/fuera de alcance: la lógica de cada servicio de dominio queda fuera
[ ] T-40-006: Definir criterios de aceptación verificables (8 criterios en 01-Requerimientos)
[ ] T-40-007: Incluir contexto del plan maestro: M07 define CORE, dominios y reglas anti-circulares
[ ] T-40-008: RF3: obtener(contrato) por StringName sin referencias directas entre módulos
[ ] T-40-009: RF3: listar_contratos() devuelve copia de solo lectura
[ ] T-40-010: RF3: registrar duplicado devuelve false y emite warning DOM-INF-REGISTRO
[ ] T-40-011: RF3: obtener sobre contrato no registrado devuelve null + warning, nunca excepción
[ ] T-40-012: D4: auto-registro de servicios de dominio en su propio _ready()
[ ] T-40-013: Definir contratos.gd con constantes StringName centralizadas (economia, mundo_voxel, ui, etc.)
[ ] T-40-014: Soporte de espía de eventos para el Debug Menu (M110)
[ ] T-40-015: RF2: detección de partida guardada (M60) y decisión nueva/cargar
[ ] T-40-016: RF2: verificación de integridad de contratos de dominio (RF11)
[ ] T-40-017: RF2: diagnóstico de capas en editor y log en runtime
[ ] T-40-018: RF2: transición a ESTADO_MENU y carga de main_menu.tscn con progreso
[ ] T-40-019: D10: pantalla de error con motivo accionable y clave i18n
[ ] T-40-020: D10: máximo 3 reintentos automáticos documentados en log, luego espera intervención
[ ] T-40-021: RF7: boot.tscn siempre la primera escena del proyecto
[ ] T-40-022: D10: prohibido crash mudo, loop de carga o menú a medio construir
[ ] T-40-023: RF8: estado inicial del juego siempre ESTADO_BOOT
[ ] T-40-024: D8: BOOT deriva a MENU/CARGANDO/MUNDO/ERROR (mi GFM agrega CARGANDO y MUNDO para prototipo sin menú)
[ ] T-40-025: D8: CARGANDO deriva a MUNDO/MENU/ERROR (también permite volver a MENU)
[ ] T-40-026: D8: TRANSICION solo deriva a CARGANDO o ERROR
[ ] T-40-027: RF10: scan estático del grafo de imports de res://core/ y dominios
[ ] T-40-028: RF10: reporte de dependencias circulares con archivo:línea
[ ] T-40-029: RF10: reporte de violaciones de capas (dominio importa UI, etc.)
[ ] T-40-030: RF12: detección de accesos a servicios en _ready() antes de registro
[ ] T-40-031: RF12: warning DOM-INF-ACCESO-TEMPRANO en cada acceso temprano
[ ] T-40-032: D9: diagnóstico estático ejecutable en editor (tool)
[ ] T-40-033: D9: diagnóstico estático ejecutable en CI (M118) como gate de calidad
[ ] T-40-034: D9: salida legible para el QA cruzado (AGENTS.md 21.8)
[ ] T-40-035: verificar_escena_previa(escena, servicios) detecta escenas que consultan antes que el servicio exista
[ ] T-40-036: RF7: boot.tscn con sanity visual mínimo y log de arranque
[ ] T-40-037: RF7: progreso visual en cada transición (AGENTS.md §8)
[ ] T-40-038: RF7: UI interactiva deshabilitada durante la carga
[ ] T-40-039: RF16: UIController escucha eventos por EventBus, nunca referencias directas
[ ] T-40-040: error.tscn con motivo i18n y botón reintentar
[ ] T-40-041: mundo (world.tscn) se carga en modo CARGANDO y entra a ESTADO_MUNDO al completar
[ ] T-40-042: RNF1: arquitectura por capas CORE → dominios → mundo → AI → UI verificable
[ ] T-40-043: RNF2: determinismo de arranque: mismo proyecto siempre inicia en el mismo orden
[ ] T-40-044: RNF3: rendimiento: registro O(1) y sin trabajo por frame en el CORE
[ ] T-40-045: RNF9: textos de boot/error con claves i18n listos para M53/M58
[ ] T-40-046: RNF10: infraestructura 100% local, sin servicios de red
[ ] T-40-047: RNF11: nunca crear Nodos en el camino de obtener/emitir (cero alocaciones críticas)
[ ] T-40-048: Analizar el EventBus central con dominios tipados
[ ] T-40-049: Analizar el orden de carga en project.godot y su fragilidad si no se declara
[ ] T-40-050: Analizar las escenas de arranque (boot/menú/mundo) y sus transiciones
[ ] T-40-051: Analizar el diagnóstico de dependencias circulares (estático + runtime)
[ ] T-40-052: Evaluar locator vs singleton global por módulo: se adopta locator por contratos
[ ] T-40-053: Evaluar inyección manual como central: descartada, se usa puntual en tests
[ ] T-40-054: Evaluar señales sueltas vs bus: se adopta EventBus con dominios base de M07
[ ] T-40-055: Evaluar orden físico de dominio como contrato: descartado por auto-registro
[ ] T-40-056: Evaluar escena única persistente vs multi-escena: se adopta multi-escena
[ ] T-40-057: Evaluar diagnóstico solo runtime vs dual: se adopta estático + runtime
[ ] T-40-058: Fijar prioridades numéricas legibles en project.godot (10/20/30/40/50/60/1)
[ ] T-40-059: Documentar que el requisito real es el ORDEN, validado por test de arranque
[ ] T-40-060: Logger segundo con contrato mínimo (detalle M103)
[ ] T-40-061: GameState tercero como dato puro sin servicios
[ ] T-40-062: Mapa de servicios: contratos economia.* registrados por M38
[ ] T-40-063: Mapa de servicios: dejar registrados los contrato reservados para dominios futuros (mundo_voxel, ui)
[ ] T-40-064: Documentar la política de registro único por contrato
[ ] T-40-065: Documentar la consulta O(1) con Dictionary
[ ] T-40-066: Diagramar nueva partida: CARGANDO → GameState.inicializar_nueva(seed) → world
[ ] T-40-067: Diagramar continuar: CARGANDO → GameState.cargar() (M60) → world
[ ] T-40-068: Diagramar el error de arranque con fallback y reintento
[ ] T-40-069: Definir que carga_completada dispara el cambio a ESTADO_MUNDO
[ ] T-40-070: Definir el enlace del HUD (M53) tras boot.completado
[ ] T-40-071: Definir que la UI del menú no se enlaza hasta verificar_integridad exitosa
[ ] T-40-072: Definir el modo de carga por escena (TRANSICION/CARGANDO/ERROR)
[ ] T-40-073: Documentar el uso de M63 para el progreso de carga pesada
[ ] T-40-074: Definir que el streaming de chunks (M63) opera dentro de ESTADO_MUNDO
[ ] T-40-075: Definir señal infra.carga.iniciada/completada para la UI de progreso
[ ] T-40-076: Definir que la escena boot no muestra interacción, solo estado de arranque
[ ] T-40-077: M07: materializar EventBus con los dominios base de M07 (§5)
[ ] T-40-078: M07: GameState con partición por dominios (meta, world, player, economy, calendar, discovery, story)
[ ] T-40-079: M07: respetar la regla "EventBus no importa dominios"
[ ] T-40-080: M07: respetar la regla "GameState no importa servicios"
[ ] T-40-081: M07: delegar el detalle profundo de GameState a M59/M60
[ ] T-40-082: M38: los eventos economy.* fluyen por EventBus sin interceptación de la infraestructura
[ ] T-40-083: M38: la UI no accede a nodos directos de economía, solo por contrato
[ ] T-40-084: M53: UIController usa _ready aplazado (primer frame) para obtener servicios (RF12)
[ ] T-40-085: M53: toda comunicación gameplay → UI viaja por EventBus
[ ] T-40-086: M53: el HUD se monta dentro de world.tscn
[ ] T-40-087: M63: transiciones boot → menú → mundo con progreso y UI bloqueada
[ ] T-40-088: M63: los chunks se siguen cargando con M63 dentro de ESTADO_MUNDO
[ ] T-40-089: M63: sin doble carga ni duplicación de escenas en transiciones
[ ] T-40-090: Contrato esperado sin registrar (M38 ausente): verificar_integridad lo reporta antes del menú
[ ] T-40-091: Servicio consultado en _ready() antes de registrarse: warning DOM-INF-ACCESO-TEMPRANO
[ ] T-40-092: Registrar dos servicios con el mismo contrato: segundo registro rechazado con warning
[ ] T-40-093: obtener() sobre contrato inexistente: null + warning, la UI muestra estado vacío sin crash
[ ] T-40-094: Reintento de arranque fallido repetido: máximo 3 intentos y mensaje de intervención
[ ] T-40-095: Cambio de estado ilegal (MUNDO → BOOT directo): rechazo con warning
[ ] T-40-096: Carga de mundo interrumpida por error: vuelve a ESTADO_ERROR sin estado fantasma
[ ] T-40-097: Transición de escena con UI bloqueada y jugador escribe: entrada descartada, sin doble disparo
[ ] T-40-098: Juego iniciado sin partida guardada: flujo nueva partida por defecto sin excepción
[ ] T-40-099: Dos cambios de estado simultáneos en un frame: solo el último válido se aplica, con warning si ambos
[ ] T-40-100: obtener() como lectura de Dictionary sin instanciación
[ ] T-40-101: emitir() como reenvío directo del Callable, sin nodos temporales
[ ] T-40-102: mapas de contratos y dominios acotados: decenas de entradas, carga única al arranque
[ ] T-40-103: payloads de eventos livianos por convención (referencias, no copias)
[ ] T-40-104: el CORE permanece inactivo durante el gameplay salvo eventos que lo tocan
[ ] T-40-105: verificar_integridad se ejecuta una vez por arranque, nunca por frame
[ ] T-40-106: preload de constantes de contratos (contratos.gd) sin I/O en runtime
[ ] T-40-107: Crear 01-Requerimientos.md con problema, objetivo, alcance, RF1-RF16 y RN
[ ] T-40-108: Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos
[ ] T-40-109: Crear 03-Diseno.md con arquitectura, orden de carga, mapa de servicios, flujos y estados
[ ] T-40-110: Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones
[ ] T-40-111: Crear 05-Checklist.md con más de 125 ítems todos completados
[ ] T-40-112: Firmar todos los archivos con modelo y plataforma
[ ] T-40-113: Copiar plan-inicial a plan-actual byte a byte (verificación por hash)
[ ] T-40-114: Definir test de integridad: 4 contratos de M38 registrados antes del menú
[ ] T-40-115: Definir test de diagnóstico estático sobre un árbol de prueba con ciclo artificial
[ ] T-40-116: Definir test de escena prematura: warning DOM-INF-ACCESO-TEMPRANO y fallback
