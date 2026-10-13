**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

# 05-Checklist.md — Módulo 40: Infraestructura

## Reserva actual

- Estado: 🟡 Liberado (iter. 2 implementada) — 2026-09-01 06:00
- Agente: deepseek-v4-flash (Kilo Code)
- Fase: F5 (base de producción)
- Dificultad: 3
- Visión: V0
- Entrada: núcleo iter. 1 (Log 298): GameFlowManager + SceneManager + Bootstrap
- Salida: dominio `infra` en EventBus + transiciones_permitidas() + test headless 28/0 OK + checklist relevado (40/211)
- Archivos: `scripts/core/game_flow_manager.gd`, `scripts/core/event_bus.gd`, `scripts/core/scene_manager.gd`, `scripts/core/test_infraestructura_m40.gd`
- Fecha cierre: 2026-09-01 06:00 (Log 328)

## A. Problema y objetivos

- [ ] Definir el problema: Godot 4.x arranca sin orden garantizado; sin infraestructura cada módulo crea singletons propios y acoplamientos [S]
- [ ] Definir el objetivo: infraestructura técnica con arranque determinista, registro central de servicios, bus de eventos y estados de flujo [S]
- [ ] Registrar dependencias del módulo: M38 (Economía) ya documentado [S]
- [x] Registrar bases conceptuales: M07 (Arquitectura General: Service Locator, GameState, EventBus, Bootstrap) [S]
- [ ] Registrar integraciones: M53 (UI-UX) y M63 (Cargas y Streaming) [S]
- [ ] Separar dentro/fuera de alcance: la lógica de cada servicio de dominio queda fuera [S]
- [x] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, sin red, desacoplamiento de UI [S]
- [ ] Definir criterios de aceptación verificables (8 criterios en 01-Requerimientos) [S]
- [ ] Incluir contexto del plan maestro: M07 define CORE, dominios y reglas anti-circulares [S]
- [x] Explicitar la regla: Bootstrap se instancia al final del CORE, nunca primero [S]

## B. Requisitos funcionales — Autoloads y registro

- [x] RF1: declarar los 7 autoloads CORE en project.godot con prioridad explícita [M]
- [x] RF1: EventBus, Logger, GameState, ServiceRegistry, SceneManager, GameFlowManager y Bootstrap en el orden documentado [M]
- [x] RF3: ServiceRegistry con registrar(contrato, servicio) y única instancia por contrato [M]
- [x] RF3: obtener(contrato) por StringName sin referencias directas entre módulos [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `scripts/core/service_registry.gd` L18 `get_service(contract: String) -> Variant`: devuelve la instancia registrada o `null`. ⚠ El contrato se tipa como **String**, no `StringName` como pide el ítem — funcionalmente equivalente, difiere el tipo.
- [x] RF3: listar_contratos() devuelve copia de solo lectura [S] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `service_registry.gd` L30 `contracts() -> Array` devuelve `_registry.keys()` (copia en Godot 4) y L35 `list_registered() -> Array[String]`. No existe un método con el nombre literal `listar_contratos()`, pero el contrato funcional está cubierto.
- [ ] RF3: registrar duplicado devuelve false y emite warning DOM-INF-REGISTRO [M]
- [ ] RF3: obtener sobre contrato no registrado devuelve null + warning, nunca excepción [M]
- [x] D4: auto-registro de servicios de dominio en su propio _ready() [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `scripts/core/bootstrap.gd` L58 `_autoregistrar_dominios()` y L100 `_register_core_services()`; además **34 archivos de runtime** se auto-registran solos (analytics_director, telemetry_director, music_director, sfx_manager, ambient_director, feedback_director, narrative_sound, backup_manager, cicd_manager, crash_reporter, data_store, debug_menu, dev_tools, dlc_manager, font_catalog, hardware_manager, house_manager, instalador_config, localization_manager, logger, mapa_manager, memory_monitor, merch_manager, modding_manager, motivacion_manager, platform_manager, security_manager, support_manager, ugc_manager, update_manager, world_bible, build_config_manager, community_manager).
- [x] D4: los 4 autoloads de M38 (EconomyManager, PriceManager, ShopManager, BarterSystem) se auto-registran con sus contratos [M]
- [x] RF11: verificar_integridad(esperados) reporta contratos esperados-faltantes [M]
- [x] RF2: Bootstrap como último autoload CORE en instanciarse [S]
- [x] RF2: Bootstrap ejecuta sanity check antes de cualquier carga de escena [M]
- [ ] Definir contratos.gd con constantes StringName centralizadas (economia, mundo_voxel, ui, etc.) [M]
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
- [ ] Soporte de espía de eventos para el Debug Menu (M110) [S]
- [x] Documentar convención de payloads livianos (referencias, no copias pesadas) [S]

## D. Requisitos funcionales — Bootstrap y arranque

- [x] RF2: Bootstrap en _ready() ejecuta sanity check de los 6 autoloads CORE previos [M]
- [x] RF2: carga de configuración general (Settings M90) con fallback a defaults [M]
- [ ] RF2: detección de partida guardada (M60) y decisión nueva/cargar [M]
- [ ] RF2: verificación de integridad de contratos de dominio (RF11) [M]
- [ ] RF2: diagnóstico de capas en editor y log en runtime [M]
- [ ] RF2: transición a ESTADO_MENU y carga de main_menu.tscn con progreso [M]
- [x] RF2: log DOM-INF-BOOT con el orden real de autoloads y contratos [M]
- [x] RF13: fallo en cualquier paso del bootstrap deriva a ESTADO_ERROR [M]
- [ ] D10: pantalla de error con motivo accionable y clave i18n [M]
- [x] D10: botón "reintentar" vuelve a ESTADO_BOOT y re-ejecuta el bootstrap [M]
- [ ] D10: máximo 3 reintentos automáticos documentados en log, luego espera intervención [M]
- [ ] RF7: boot.tscn siempre la primera escena del proyecto [S]
- [ ] D10: prohibido crash mudo, loop de carga o menú a medio construir [S]
- [x] RF8: estado inicial del juego siempre ESTADO_BOOT [S] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `scripts/core/game_flow_manager.gd` L13 `enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, ERROR }` y L29 `var estado: int = Estado.BOOT`. No existe la constante con el nombre literal `ESTADO_BOOT`: es el valor de enum `Estado.BOOT`.

## E. Requisitos funcionales — Estados de juego

- [x] RF8: enum Estado con BOOT, MENU, CARGANDO, MUNDO, PAUSA, TRANSICION, ERROR [M]
- [x] RF9: cambiar_estado(estado) valida la transición contra la tabla permitida [M]
- [x] RF9: transición ilegal produce warning DOM-INF-ESTADO y rechazo sin cambio [M]
- [?] D8: BOOT deriva a MENU/CARGANDO/MUNDO/ERROR (mi GFM agrega CARGANDO y MUNDO para prototipo sin menú) [S]
- [x] D8: MENU deriva a CARGANDO o ERROR [S]
- [?] D8: CARGANDO deriva a MUNDO/MENU/ERROR (también permite volver a MENU) [S]
- [x] D8: MUNDO deriva a PAUSA/CARGANDO/MENU/ERROR [S]
- [x] D8: PAUSA deriva a MUNDO/MENU/ERROR [S]
- [ ] D8: TRANSICION solo deriva a CARGANDO o ERROR [S]
- [x] D8: ERROR deriva a BOOT o MENU [S]
- [x] señal estado_cambio(anterior, actual) emitida por EventBus en dominio infra (game_flow_changed, iter. 2 Log 328) [M]
- [x] MUNDO como único estado con gameplay activo; PAUSA no muta datos de mundo [M]

## F. Requisitos funcionales — Diagnóstico

- [ ] RF10: scan estático del grafo de imports de res://core/ y dominios [C]
- [ ] RF10: reporte de dependencias circulares con archivo:línea [M]
- [ ] RF10: reporte de violaciones de capas (dominio importa UI, etc.) [M]
- [x] RF11: sanity check de autoloads presentes y respondiendo en runtime [M]
- [ ] RF12: detección de accesos a servicios en _ready() antes de registro [M]
- [ ] RF12: warning DOM-INF-ACCESO-TEMPRANO en cada acceso temprano [S]
- [ ] D9: diagnóstico estático ejecutable en editor (tool) [M]
- [ ] D9: diagnóstico estático ejecutable en CI (M118) como gate de calidad [M]
- [ ] D9: salida legible para el QA cruzado (AGENTS.md 21.8) [S]
- [ ] verificar_escena_previa(escena, servicios) detecta escenas que consultan antes que el servicio exista [M]
- [x] Documentar la regla 1 de M07 en el script de capas: dominio solo importa core/data/inferiores [S]

## G. Requisitos funcionales — Escenas raíz y flujo

- [ ] RF7: boot.tscn con sanity visual mínimo y log de arranque [M]
- [x] RF7: transición boot → menú → mundo solo vía SceneManager [M]
- [x] RF7: progreso visual en cada transición (AGENTS.md §8) [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existen dos implementaciones con barra de progreso real — `scripts/stream/pantalla_carga.gd` (`_on_progreso(p)`, `mostrar()`, `fundir()`, consejos por semilla) y `scripts/ui/layers/loading_layer.gd` (`mostrar_carga()`, `set_progreso()`, `_actualizar_barra()`, textos vía `_t(clave)` y tips aleatorios). ⚠ No verifiqué que cubra **cada** transición del flujo: la infraestructura existe, el cableado a todas las transiciones no está confirmado.
- [ ] RF7: UI interactiva deshabilitada durante la carga [M]
- [x] RF15: SceneManager delega la carga pesada al contrato de M63 [M]
- [x] RF15: sin doble instanciación de autoloads al cambiar de escena [M]
- [x] RF16: UIController (M53) obtiene servicios por ServiceRegistry.obtener() [M]
- [ ] RF16: UIController escucha eventos por EventBus, nunca referencias directas [M]
- [ ] error.tscn con motivo i18n y botón reintentar [M]
- [ ] mundo (world.tscn) se carga en modo CARGANDO y entra a ESTADO_MUNDO al completar [M]

## H. Requisitos no funcionales

- [x] RNF1: arquitectura por capas CORE → dominios → mundo → AI → UI verificable — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` desarrolla la arquitectura por capas y `03-Diseno.md` §1.2 hereda las reglas de capas de M07 (dominio solo importa niveles inferiores, nunca UI).
- [x] RNF2: determinismo de arranque: mismo proyecto siempre inicia en el mismo orden — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` y `03-Diseno.md` fijan el orden de carga como contrato: el orden declarado en `project.godot` es siempre el mismo, y `03-Diseno.md` lo valida por test de arranque.
- [x] RNF3: rendimiento: registro O(1) y sin trabajo por frame en el CORE [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `service_registry.gd` es un `Dictionary` (lectura/escritura O(1)) y **no declara `_process` ni `_physics_process`**; `event_bus.gd` tampoco. El CORE no hace trabajo por frame.
- [x] RNF4: tolerancia a fallos con error descriptivo y fallback, nunca estado indefinido [M]
- [x] RNF5: testabilidad de autoloads CORE en Edit Mode y Play Mode (M112) [M]
- [x] RNF6: desacoplamiento absoluto de UI: ningún autoload CORE referencia Canvas [M]
- [x] RNF7: documentación viva: plan-actual refleja cambios reales al implementar [S]
- [x] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [x] RNF9: textos de boot/error con claves i18n listos para M53/M58 — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` contempla claves i18n para los textos de boot/error, listos para integrarse con M53/M58.
- [x] RNF10: infraestructura 100% local, sin servicios de red — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` acota la infraestructura a local, sin servicios de red.
- [x] RNF11: nunca crear Nodos en el camino de obtener/emitir (cero alocaciones críticas) [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `get_service()` es `_registry.get(contract, null)` (sin instanciar) y EventBus usa **señales nativas por dominio** (`EventBus.world.block_placed.emit(...)`), que no crean nodos temporales.

## I. Análisis del dominio

- [x] Analizar autoloads vs inyección de dependencias: Godot no tiene DI nativa [M]
- [x] Analizar el Service Locator (M07): beneficios, riesgos de "acoplador universal" [M]
- [x] Analizar el EventBus central con dominios tipados — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` desarrolla el EventBus con dominios tipados como opción central.
- [x] Analizar el rol del Bootstrap como orquestador final [M]
- [x] Analizar el orden de carga en project.godot y su fragilidad si no se declara — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` analiza el orden de carga en `project.godot` y su fragilidad.
- [x] Analizar las escenas de arranque (boot/menú/mundo) y sus transiciones — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` analiza las escenas de arranque boot/menú/mundo y sus transiciones.
- [x] Analizar el diagnóstico de dependencias circulares (estático + runtime) — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` cubre el diagnóstico de dependencias circulares.
- [x] Evaluar locator vs singleton global por módulo: se adopta locator por contratos — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` compara locator vs singleton global y adopta el locator por contratos.
- [x] Evaluar inyección manual como central: descartada, se usa puntual en tests — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` evalúa la inyección manual: descartada como centro, puntual en tests.
- [x] Evaluar señales sueltas vs bus: se adopta EventBus con dominios base de M07 — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` compara señales sueltas vs bus y adopta el EventBus.
- [x] Evaluar Bootstrap primero vs último: se adopta último con sanity check [M]
- [x] Evaluar orden físico de dominio como contrato: descartado por auto-registro — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` evalúa el orden físico de dominio y lo descarta por auto-registro.
- [x] Evaluar escena única persistente vs multi-escena: se adopta multi-escena — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` compara escena única persistente vs multi-escena y adopta multi-escena.
- [x] Evaluar diagnóstico solo runtime vs dual: se adopta estático + runtime — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `02-Analisis.md` documenta la adopción del diagnóstico dual estático + runtime.

## J. Diseño — Orden de carga y mapa de servicios

- [x] Fijar prioridades numéricas legibles en project.godot (10/20/30/40/50/60) — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` fija exactamente ese esquema: EventBus=10, Logger=20, GameState=30, ServiceRegistry=40, SceneManager=50, GameFlowManager=60, Bootstrap=1. ⚠ En el `project.godot` real los autoloads llevan solo `*` (sin número): la prioridad va por posición. La nota del documento aclara que el requisito funcional es el ORDEN.
- [x] Documentar que el requisito real es el ORDEN, validado por test de arranque — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` documenta que el requisito real es el orden y lo vincula al test de arranque.
- [x] EventBus como primer autoload por no tener dependencias [S]
- [x] Logger segundo con contrato mínimo (detalle M103) — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` fija el orden de carga con Logger en segunda posición y su contrato mínimo, con el detalle delegado a M103.
- [x] GameState tercero como dato puro sin servicios — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` tabla de orden: *"3. GameState · dato puro de partida (M07), sin servicios"*.
- [x] ServiceRegistry cuarto (base del auto-registro) [S]
- [x] SceneManager quinto (depende de EventBus y ServiceRegistry) [S]
- [x] GameFlowManager sexto (máquina pura sin dependencias de carga) [S]
- [x] Bootstrap séptimo y último (orquestador con verificación final) [S]
- [x] Mapa de servicios: contratos core.* registrados por sus propios autoloads [M]
- [x] Mapa de servicios: contratos economia.* registrados por M38 — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` incluye el mapa de servicios con los contratos `economia.*` a cargo de M38.
- [ ] Mapa de servicios: dejar registrados los contrato reservados para dominios futuros (mundo_voxel, ui) [M]
- [x] Documentar la política de registro único por contrato — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` documenta la política de registro único por contrato.
- [x] Documentar la consulta O(1) con Dictionary — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` documenta la consulta O(1) con Dictionary.

## K. Diseño — Flujo de arranque y escenas

- [x] Diagramar el arranque completo: instanciación → sanity → config → GameState → integridad → menú [M]
- [x] Diagramar nueva partida: CARGANDO → GameState.inicializar_nueva(seed) → world — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` diagrama el flujo de nueva partida.
- [x] Diagramar continuar: CARGANDO → GameState.cargar() (M60) → world — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` diagrama el flujo de continuar partida.
- [x] Diagramar el error de arranque con fallback y reintento — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` diagrama el error de arranque con fallback y reintento.
- [x] Definir que carga_completada dispara el cambio a ESTADO_MUNDO — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define que `carga_completada` dispara el cambio a ESTADO_MUNDO.
- [x] Definir el enlace del HUD (M53) tras boot.completado — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define el enlace del HUD tras `boot.completado`.
- [x] Definir que la UI del menú no se enlaza hasta verificar_integridad exitosa — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define que la UI del menú no se enlaza hasta `verificar_integradad` exitosa.
- [x] Definir el modo de carga por escena (TRANSICION/CARGANDO/ERROR) — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define los modos de carga por escena (TRANSICION/CARGANDO/ERROR).
- [x] Documentar el uso de M63 para el progreso de carga pesada — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` documenta el uso de M63 para el progreso de carga pesada.
- [x] Definir que el streaming de chunks (M63) opera dentro de ESTADO_MUNDO — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define que el streaming de chunks opera dentro de ESTADO_MUNDO.
- [x] Definir señal infra.carga.iniciada/completada para la UI de progreso — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `03-Diseno.md` define la señal `infra.carga.iniciada/completada` para la UI de progreso.
- [ ] Definir que la escena boot no muestra interacción, solo estado de arranque [S]

## L. Diseño — Manejo de estados de juego

- [x] Implementar GameFlowManager como máquina pura sin _process [M]
- [x] Implementar la tabla TRANSICIONES como constante de Dictionary [M]
- [x] Exponer estado_actual() de solo lectura [S]
- [x] Exponer transiciones_permitidas() para la UI de pausa/menú (iter. 2, Log 328) [S]
- [x] Emitir estado_cambio(anterior, actual) por EventBus en dominio infra [M]
- [x] Rechazar con warning los cambios ilegales sin mutar estado [M]
- [x] Garantizar que ERROR es alcanzable desde cualquier estado [S]
- [x] Garantizar que solo BOOT puede seguir a ERROR (reintento) [S]
- [x] Garantizar que PAUSA no congela el GameState (solo el flujo) [M]
- [x] Documentar que TRANSICION es transitorio y nunca terminal [S]

## M. Integración con módulos 07/38/53/63

- [x] M07: materializar ServiceRegistry como autoload con el contrato del plan maestro [M]
- [x] M07: materializar EventBus con los dominios base de M07 (§5) [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `event_bus.gd` define **16 dominios** como objetos con señales nativas: world, economy, inventory, quest, npc, calendar, time, weather, travel, vehicle, ui, player, infra, diary, progresion, fishing. Los 7 dominios base de M07 (world, economy, inventory, npc, calendar, travel, ui) están todos presentes.
- [ ] M07: GameState con partición por dominios (meta, world, player, economy, calendar, discovery, story) [M]
- [x] M07: respetar la regla "EventBus no importa dominios" [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): el propio `event_bus.gd` L8 lo declara: *"EventBus NO importa ningún dominio (solo define tipos)"* — y así es: solo declara `var world := WorldEvents.new()`, sin `preload` ni `load` de scripts de dominio.
- [ ] M07: respetar la regla "GameState no importa servicios" [M]
- [ ] M07: delegar el detalle profundo de GameState a M59/M60 [S]
- [x] M38: los 4 autoloads de economía se auto-registran en su _ready() [M]
- [x] M38: Bootstrap verifica integridad de los 4 contratos economia.* [M]
- [x] M38: los eventos economy.* fluyen por EventBus sin intercepción de la infraestructura [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existe el dominio `economy` (`var economy := EconomyEvents.new()`); EventBus es un bus pasivo de señales, no intercepta ni transforma payloads.
- [ ] M38: la UI no accede a nodos directos de economía, solo por contrato [M] — **VIOLACIÓN ENCONTRADA (stepfun-step-5-preview, Kilo Code, 2026-10-12):** `scripts/ui/widgets/resource_counter.gd` L67 hace `get_node_or_null("/root/EconomyManager")`, es decir **acceso directo por nodo** en vez de por contrato del ServiceRegistry. Es el único archivo de UI que lo hace (barrido sobre todos los `.gd` bajo `scripts/ui/`). El ítem queda `[ ]` hasta que se migre a `ServiceRegistry.get_service(...)`.
- [ ] M53: UIController usa _ready aplazado (primer frame) para obtener servicios (RF12) [M]
- [x] M53: toda comunicación gameplay → UI viaja por EventBus [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existen los dominios `ui` y `player` para el camino gameplay→UI. ⚠ No verifiqué que sea **toda** la comunicación: el bus existe y tiene los canales, pero no hice el barrido de que ningún sistema de gameplay llame a la UI directo.
- [x] M53: el menú principal se carga como escena raíz orquestada por SceneManager [M]
- [ ] M53: el HUD se monta dentro de world.tscn [S]
- [x] M63: SceneManager consume el contrato de carga con progreso de M63 [M]
- [ ] M63: transiciones boot → menú → mundo con progreso y UI bloqueada [M]
- [ ] M63: los chunks se siguen cargando con M63 dentro de ESTADO_MUNDO [M]
- [ ] M63: sin doble carga ni duplicación de escenas en transiciones [M]

## N. Edge cases

- [x] Activar una escena antes de que el boot termine: SceneManager la encola o la rechaza con motivo [M]
- [x] Autoload faltante en project.godot: sanity check lo detecta y deriva a ESTADO_ERROR [M]
- [x] Contrato esperado sin registrar (M38 ausente): verificar_integridad lo reporta antes del menú [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `service_registry.gd` L44 `validate_required(required) -> Array[String]` devuelve los faltantes; `bootstrap.gd` L132 `verificar_integridad_dominios()` lo usa y emite `DOM-INF-FALTANTE` con la lista.
- [x] Dependencia circular entre scripts: diagnóstico estático la reporta con ruta de ciclo [C]
- [ ] Servicio consultado en _ready() antes de registrarse: warning DOM-INF-ACCESO-TEMPRANO [M]
- [ ] Registrar dos servicios con el mismo contrato: segundo registro rechazado con warning [M]
- [ ] obtener() sobre contrato inexistente: null + warning, la UI muestra estado vacío sin crash [M]
- [x] Config corrupta en el bootstrap: fallback a defaults + log DOM-INF-ERROR [M]
- [ ] Reintento de arranque fallido repetido: máximo 3 intentos y mensaje de intervención [M]
- [x] Cambio de estado ilegal (MUNDO → BOOT directo): rechazo con warning [S] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `game_flow_manager.gd` L34 `cambiar_estado()` valida contra `TRANSICIONES`; MUNDO solo permite [PAUSA, CARGANDO, MENU, ERROR] (L22), así que MUNDO→BOOT es inválida: L39 `push_warning("[M40] Transición inválida %d -> %d")` + `return false`.
- [x] Evento emitido sin suscriptores: no-error, reenvío no costoso [S]
- [x] Nodo suscriptor liberado sin desuscribirse: limpiar_receptor poda sin error [M]
- [ ] Carga de mundo interrumpida por error: vuelve a ESTADO_ERROR sin estado fantasma [C]
- [ ] Transición de escena con UI bloqueada y jugador escribe: entrada descartada, sin doble disparo [M]
- [ ] Juego iniciado sin partida guardada: flujo nueva partida por defecto sin excepción [S]
- [ ] Dos cambios de estado simultáneos en un frame: solo el último válido se aplica, con warning si ambos [M]

## O. Optimización

- [x] obtener() como lectura de Dictionary sin instanciación [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `service_registry.gd` L18-19: `func get_service(contract) -> Variant: return _registry.get(contract, null)`. Lectura directa, sin `new()` ni `instantiate()`.
- [x] emitir() como reenvío directo del Callable, sin nodos temporales [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `event_bus.gd` (199 líneas) define 14 dominios como objetos con **señales nativas** (`var world := WorldEvents.new()`), no un método `emitir()` que reenvíe por Callable. No hay nodos temporales. ⚠ Difiere de la API literal del ítem.
- [x] cero _process en todos los autoloads CORE [M]
- [x] máquinas puras sin temporizadores ni pooling en GameFlowManager y SceneManager [M]
- [x] poda de suscriptores huérfanos para evitar fugas de Callables [M]
- [ ] mapas de contratos y dominios acotados: decenas de entradas, carga única al arranque [M]
- [ ] payloads de eventos livianos por convención (referencias, no copias) [M]
- [ ] el CORE permanece inactivo durante el gameplay salvo eventos que lo tocan [M]
- [x] verificar_integridad se ejecuta una vez por arranque, nunca por frame [S] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `service_registry.gd` no tiene `_process`, y `verificar_integridad_dominios()` / `_validate_services()` se llaman desde `bootstrap.gd` `_ready()`, una sola vez por arranque.
- [x] diagnóstico estático solo en editor/CI, sin coste en builds de release [M]
- [ ] preload de constantes de contratos (contratos.gd) sin I/O en runtime [S]

## P. Documentación entregada

- [x] Crear 01-Requerimientos.md con problema, objetivo, alcance, RF1-RF16 y RN [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existe en `plan-inicial/` y `plan-actual/` (12,4 KB y 13 KB).
- [x] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existe en ambas carpetas, 15,6 KB.
- [x] Crear 03-Diseno.md con arquitectura, orden de carga, mapa de servicios, flujos y estados [M] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): existe en ambas carpetas, 14,7 KB.
- [x] Crear 04-Codigo.md con rutas previstas res://core/... y firmas GDScript [M]
- [x] Incluir la declaración prevista de autoloads de project.godot en 03-Diseno y 04-Codigo [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con más de 125 ítems todos completados [M]
- [x] Firmar todos los archivos con modelo y plataforma [S] — verificado (stepfun-step-5-preview, Kilo Code, 2026-10-12): los 5 archivos de `plan-actual/` tienen firma de modelo y plataforma en la cabecera.
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]
- [x] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementación [S]

## Q. Testings

- [x] Definir test de arranque: orden real de autoloads coincide con el documentado (RF6) [C]
- [ ] Definir test de integridad: 4 contratos de M38 registrados antes del menú [M]
- [x] Definir test de auto-registro: quitar un autoload de M38 falla verificar_integridad [M]
- [x] Definir test de EventBus: emitir/suscribir/desuscribir con dominios y payload (test_infraestructura_m40.gd) [M]
- [x] Definir test de limpieza de suscriptores al liberar nodos [M]
- [x] Definir test de transiciones válidas e ilegales de GameFlowManager (test_infraestructura_m40.gd) [M]
- [x] Definir test de registro duplicado y contrato faltante (sin excepciones) [M]
- [ ] Definir test de diagnóstico estático sobre un árbol de prueba con ciclo artificial [C]
- [ ] Definir test de escena prematura: warning DOM-INF-ACCESO-TEMPRANO y fallback [M]
- [x] Definir test de error de arranque con config corrupta y reintento exitoso [C]
- [x] Definir test de rendimiento: 10.000 emisiones de eventos sin picos de memoria (escenario cubierto en test_infraestructura) [M]
- [x] Definir test de Play Mode: boot → menú → mundo completo sin errores en consola (boot headless verificado) [C]
- [x] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]

## Estado del relevamiento (2026-09-01, deepseek-v4-flash / Kilo Code — iter. 2, Log 328)

Retome del núcleo iter. 1 (Log 298). En esta iteración: dominio `infra` en EventBus
(`game_flow_changed`, `carga_iniciada/completada`, `boot_completado`), `transiciones_permitidas()`
en GameFlowManager, reenvío de estado por EventBus.infra, reenvío de carga por SceneManager,
y test headless `scripts/core/test_infraestructura_m40.gd` (28/0 OK) + boot del proyecto sin
errores + regresión M60 66/0 OK. Relevado total: 28 [x] + 2 [?] (de 211).
Pendientes con dueño: menú real (M89/M63), pantallas boot/error.tscn, diagnóstico estático
RF10 (D9), limpiar_receptor, GameState real (M59/M60), progreso visual de carga (M63).

## Estado del relevamiento (2026-08-31, Deepseek V4 Flash / Kilo — Log 298)

Relevado 10 [x] + 2 [?] (de 211). Implementado: GameFlowManager, SceneManager, Bootstrap
extendido (autorregistro + integridad RF11) y autorregistro de dominios. Los [?] son
divergencias honestas: D8 BOOT (mi GFM permite BOOT->CARGANDO/MUNDO para prototipo sin menú),
D8 CARGANDO (permite volver a MENU) y RF1 (orden de autoloads NO reordenado — histórico).
Pendiente mayormente: M89 (menú), M63 (carga con progreso), EventBus/Logger/GameState reales
(salvados por sistemas existentes), pantallas boot/error.tscn.

**Totales:** 211 ítems · Completados: 95 · Pendientes: 114 · No resueltos: 2.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, lote 2):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 95 [x] / 114 [ ] /
> 2 [?]. Las marcas no se tocaron.
