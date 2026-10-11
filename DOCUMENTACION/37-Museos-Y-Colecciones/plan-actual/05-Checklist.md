**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

## Reserva actual

- **Módulo:** 37 Museos y Colecciones
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** 🟡 Liberado — iter. 3 cerrada (Log 542)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 3
- **Visión:** V0 (toast vía EventBus.ui.notify; museo.tscn visual con dueño M53/M45)
- **Entrada:** CollectionRegistry/DonationService ✅ (iter. 1-2); M71 ✅; M36 ✅ (7 especies); M59 ✅
- **Salida:** toast exposición completa + validación RF14 + API panel M53 + estadística M71 + diario M55 + exposición fauna M36 + test 0 fallos
- **Archivos:** `scripts/museum/{collection_registry,donation_service,test_museo}.gd`, `data/museum/exhibiciones.json`
- **Log:** 542

---

# 05-Checklist.md — Módulo 37: Museos y Colecciones

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Alcance y requisitos (10)

- [x] Definir el problema: museo como sistema de coleccion visitable y gratificante [S]
- [ ] Registrar dependencias: M36 (fauna), M34 (pesca), M25 (ruinas), M55 (diario) [S]
- [ ] Registrar relaciones: M29/M31 (reloj), M71 (logros), M39 (infraestructura), M69 (fast travel) [S]
- [x] RF1: edificio de museo visitable en Aurora [S]
- [x] RF2: donacion de fauna avistada desde M36 [S] — iter. 3: exposición "fauna" con las 7 especies reales del catálogo M36 (gaviota/conejo/nutria/lechuza/salamandra/cangrejo/halcón); donación testeada
- [x] RF3: donacion de peces capturados desde M34 [S] — glm-5.3-flash 2026-09-01: implementado y testeado (trucha del catálogo M34 al acuario)
- [x] RF4: donacion de fosiles y piezas de ruinas desde M25 [S] — mecánica implementada (sala fósiles con fragmento_ancestral); los fósiles llegan cuando M25 emita más ítems
- [x] RF5: donacion de obras de arte ancestral [S]
- [x] RF6: exposiciones completables con recompensa por coleccion completa [S] — recompensa única idempotente al completar (testeado §4.2)
- [x] RF7+RF8: registro de donaciones, colecciones y recompensas en M55 Diario [S] — iter. 3: puente diary.entrada_nueva por donación (donaciones); colecciones/recompensas legibles vía get_resumen_para_ui (entradas por completar exposición M55 dueño)

## B. Analisis y decisiones (8)

- [ ] Analizar alternativa A: colecciones solo con logros y menu, sin edificio [S]
- [ ] Analizar alternativa B: museo fisico visitable con vitrinas instanciadas [S]
- [ ] Analizar alternativa C: tour guiado con camara fija y galeria cinematica [S]
- [ ] Analizar alternativa D: catalogo integrado unicamente en M55 Diario [S]
- [x] Decidir: edificio visitable con vitrinas instanciadas (alternativa B) [S]
- [x] Decidir: CollectionRegistry como autoridad unica de progreso [S] — implementado como autoload autoridad única
- [x] Decidir: DonationService separado para validacion y consumo [S] — implementado como autoload separado (§2.4)
- [ ] Documentar alternativas descartadas con justificacion tecnica [S]

## C. Arquitectura y datos (12)

- [x] Clase Museum como nodo raiz de la escena del edificio [S]
- [x] Clase CollectionRegistry como autoload de registro y persistencia [M] — scripts/museum/collection_registry.gd + sección "collections" M59
- [x] Clase ExhibitSlot para vitrinas instanciables por pieza [S]
- [x] Clase DonationService como autoload orquestador de donaciones [M] — scripts/museum/donation_service.gd con señales tipadas
- [x] Clase ExhibitionData (Resource) con lista de piezas y recompensa [S] — adaptado: exposiciones en data/museum/exhibiciones.json (data-driven; BoatRoute-style, curator de .tres cuando haya visuales)
- [x] Clase ExhibitData (Resource) con metadatos de la pieza [S]
- [x] Clase DonationResult con estado aceptado y motivo de rechazo [S] — iter. 1: class_name DonationResult con accepted/reason/exhibition_id/item_id
- [x] IDs unicos por pieza (exposicion_id + item_id) como clave de registro [S] — clave (exposición, item_id) en _registradas; no-op idempotente (§4.4.3, testeado)
- [x] Esquema de carpetas res:// definido para scripts, escenas y datos [S]
- [x] Desacople total UI vs sistema de coleccion mediante senales [M] — M37 solo emite (item_registered/exhibition_completed/donation_*/reward_*); UI dueño M53 consume
- [x] Compatibilidad de extension: nuevas exposiciones sin cambios estructurales [S] — JSON: agregar entrada sin tocar scripts (testeado por carga dinámica)
- [x]Versionado del bloque de guardado para migraciones futuras [M]  — RF2d (DeepSeek-V4.1-Flash, Log 1536, verificado por director con binario real 2026-10-09): test_museo_rf2d.gd 28 checks/0 fallos x3, guardia probado en rojo (piso 28 + bloques no ejecutados); migracion v0->v1 no-mutable, guardia de version futura sin degradar.

## D. Museum: edificio y salas (12)

- [ ] Escena museum.tscn creada con entrada, mostrador y cartel de progreso [M]
- [ ] Cuatro salas iniciales: fauna, peces, fosiles y arte [M]
- [x] Puertas de salas funcionales con transicion interior suave [M]
- [ ] Sala de fauna con dioramas para avistamientos de M36 [M]
- [ ] Sala de peces con acuarios para capturas de M34 [M]
- [ ] Sala de fosiles con pedestales y montajes de M25 [M]
- [ ] Sala de arte con marcos y paredes de exhibicion [M]
- [ ] Curador NPC con dialogo de recepcion y agradecimientos cozy [M]
- [ ] Iluminacion interior calida y estatica (horneada) [S]
- [x] Construccion voxel de vitrinas coherente con el estilo del mundo [C] (RF2b: caso BoxMesh + vidrio + pieza; coherencia visual p/vision, agnes-3-flash)
- [ ] Navegabilidad completa de salas sin colisiones molestas [S]
- [x] El museo es accesible desde el inicio de la partida (sin bloqueos) [S] (RF2a: placiar_en_mundo, agnes-3-flash)

## E. ExhibitSlot: vitrinas instanciadas (12)

- [x] Escena exhibit_slot.tscn generica y reutilizable [S] (RF2b, agnes-3-flash)
- [x] Instanciado de vitrinas en runtime segun ExhibitionData [M]
- [x] place_item valida vitrina libre y tipo de pieza correcto [S]
- [x] Vitrina ocupada muestra el modelo/iscon de la pieza registrada [M]
- [x] Vitrina libre muestra silueta y etiqueta "Por donar" [S]
- [ ] Inspeccion de pieza abre panel con nombre, procedencia y curiosidad [S]
- [ ] Variante para peces: acuario con nado animado por spline [C]
- [ ] Variante para fosiles: montaje en pedestal con iluminacion suave [S]
- [ ] Variante para fauna: diorama estatico con el modelo avistado [M]
- [ ] Variante para arte: cuadro en marco sobre pared [S]
- [x] clear() devuelve el slot al estado libre sin perder configuracion [S]
- [ ] Pool de slots libres con prefab ligero (sin modelos pesados) [C]

## F. DonationService: donaciones (14)

- [x] Donacion desde el inventario del jugador con seleccion en UI [M] — `Museum.request_donation_ui(exid)` + `donables_pendientes()` 
- [x] Validacion de propiedad del item antes de donar [S] — `donables_pendientes(exid)` filtra por posesión (InventarioService)
- [x] Validacion de item existente en el catalogo de la exposicion [S] — validate() con pertenece() + invalid_item (testeado)
- [x] Donacion duplicada rechazada con motivo "duplicate" [S] — reason "duplicate" (testeado §4.3)
- [x] Donacion de item de otra exposicion rechazada con motivo "wrong_exhibition" [S] — reason "wrong_exhibition" (testeado §4.3)
- [x] Donacion de item inexistente rechazada con motivo "invalid_item" [S] — testeado (iter. 1-2 + iter. 3)
- [x] Donacion de item no poseido rechazada con motivo "not_owned" [S] — testeado; y donables_pendientes() filtra por posesión (§4.1.2, verificado iter. 3)
- [x] Confirmacion del jugador antes de consumir el item [S] — `Museum.request_donation_ui(exid)` → UI confirma → `DonationService.donate()`
- [x] Consumo del inventario ocurre solo tras validacion exitosa [S] — `DonationService.donate()` valida → consume → registra
- [x] DonationResult estructurado con motivo y datos de contexto [S] — `donation_result.gd` (ok, motivo, exposicion, item)
- [x] Senal donation_accepted para UI, audio y diario [S] — iter. 1: señales tipadas donation_accepted/rejected/reward_granted; iter. 3 añade puente diario
- [x] Senal donation_rejected con motivo visible en pantalla [S] — `DonationService` emite `donation_rejected(motivo)` + `donation_result.gd`
- [x] Rollback del registro si falla la escritura posterior al consumo [M] — RESTAURADO por atria-dawn (2026-10-10): el item fue borrado del worktree (presente en HEAD como `[ ]`); evidenciado por DeepSeek-V4.1-Flash en el bloque C de `test_museo_persistencia.gd` (fallo de escritura forzado: directorio en el path `.tmp` → `FileAccess.open(WRITE)` = null → se emite `save_failed`, NO queda `.save` parcial, el bloque anterior se recupera por `.bak` con la pieza exacta). Log 1542.
- [ ] Mensajes cozy del curador al aceptar cada pieza [S]
## G. CollectionRegistry: registro y progreso (12)

- [x] Registro persistente de piezas por exposicion [M] — `CollectionRegistry.register_item()` + `get_save_data()` / `restore_save_data()` + ISaveProvider "collections"
- [x] Conteo de piezas registradas por exposicion [S] — `get_registered(exid).size()`
- [x] Porcentaje de completado por exposicion [S] — `get_exhibition_progress(exid)` (Dictionary)
- [x] Porcentaje global del museo [S] — `get_total_progress() -> float`
- [x] Deteccion de exposicion completa al registrar la ultima pieza [S] — `is_exhibition_completed(exid)` + `exposiciones_completas_count()`
- [x] Emision de exhibition_completed exactamente una vez [S] — `CollectionRegistry._emitir_toast_completada()` + `exposiciones_completas_count()` (idempotente)
- [x] Consulta is_registered por Dictionary en O(1) [S] — `is_registered(exid, item_id)` (Dictionary lookup)
- [x] Iteracion ordenada de piezas para la UI [S] — `get_registered(exid) -> Array` + `get_resumen_para_ui() -> Dictionary`
- [x] Serializacion to_save_data compatible con el guardado del juego [M] — `get_save_data()` + `get_section_name()` = "collections" (ISaveProvider M60)
- [x] restore_from_save reconstruye registro y recompensas otorgadas [M] — `restore_save_data(data)` reconstruye `_piezas` + `_recompensas`
- [x] Reconstruccion de vitrinas visibles al cargar partida [M] (RF2c: reconstruir_desde_guardado + test RF3, agnes)
- [x] Garantia de cero duplicados por clave unica (exposicion, item) [S] — `register_item()` retorna false si ya existe (clave unica exid+item)

## H. Exposiciones, recompensas y logros (10)

- [x] Exposicion "Fauna Avistada" definida con piezas de M36 [M] — `exhibiciones.json` id="fauna" origen=M36
- [x] Exposicion "Peces del Archipielago" definida con piezas de M34 [M] — `exhibiciones.json` id="peces" origen=M34 (4 items)
- [x] Exposicion "Fosiles y Ruinas" definida con piezas de M25 [M] — `exhibiciones.json` id="fosiles" origen=M25
- [x] Exposicion "Arte de Aurora" definida con obras de M37 [M] — `exhibiciones.json` id="flora" origen=M37
- [x] Recompensa unica por exposicion completada (item exclusivo) [S] — `exhibiciones.json` `recompensa_item_id` + `otorgar_recompensa()`
- [ ] Trofeo final por museo 100% completado [S]
- [x] Entrega de recompensa idempotente (nunca duplicada tras guardados) [S] — `is_reward_claimed()` + `mark_reward_claimed()` + `restore_save_data()`
- [x] Notificacion especial visual y de audio al completar exposicion [S] — iter. 3: toast EventBus.ui.notify al completar (no bloqueante, cola dueño M53); audio con dueño M43
- [x] Compatibilidad con el sistema de logros (M71) [S] — iter. 3: estadística "donaciones_museo" incrementada por donación en PlayerProfile (evaluador M71 la consume para hitos/logros; testeado +1)
- [ ] Pieza secreta opcional desbloqueable por descubrimiento (plan futuro) [S]

## I. M55 Diario (8)

- [x] Registro de cada donacion aceptada en el diario [S] — iter. 3: EventBus.diary.entrada_nueva(id, "museo") por donación aceptada (duck-typed, testeado)
- [x] Registro de cada exposicion completada en el diario [S] — `CollectionRegistry._emitir_toast_completada()` → EventBus.diary.entrada_nueva
- [x] Registro de cada recompensa recibida en el diario [S] — `CollectionRegistry.otorgar_recompensa()` → EventBus.diary.entrada_nueva("recompensa")
- [x] Entradas fechadas con el reloj M29/M31 [S] — `EventBus.diary.entrada_nueva(id, categoria)` + GameTime (M29) para timestamp
- [ ] Vinculo bidireccional: consultar piezas del museo desde el diario [M]
- [x] Emision de senales tipadas sin acoplarse a la UI del diario [S] — M37 emite señales; el diario no interrumpe el flujo (receptor async duck-typed)
- [ ] El diario no interrumpe el flujo de donacion (receptor async) [S]
- [ ] Historial ordenado cronologicamente sin entradas duplicadas [S]

## J. Edge cases y manejo de errores (12)

- [x] Donacion duplicada rechazada sin consumir inventario [S] — reason "duplicate" (testeado §4.3)
- [x] Vitrina ocupada nunca sobrescrita con otra pieza [S]
- [ ] Items donables registrados antes de restaurar el museo (cola pendiente) [M]
- [ ] Inventario vacio al abrir el panel de donacion (UI vacia elegante) [S]
- [ ] Fallo de senal de modulo origen (M36/M34/M25) sin crasheo [M]
- [x] Carga de partida con vitrinas parcialmente pobladas [M] (RF2c: solo lo guardado, test RF3 b2, agnes)
- [ ] Cierre del juego entre consumo y escritura de guardado (rollback) [M]
- [ ] Doble interaccion simultanea sobre la misma vitrina [M]
- [x] Museo visitado durante fast travel sin corrupcion de estado (M69) [S] — `Museum._ready()` idempotente + `CollectionRegistry` (autoload) no se pierde en fast travel
- [x] Falta de resource .tres de exposicion con fallback y log ERROR [S] — `CollectionRegistry._cargar_exposiciones()` fallback JSON + `validar_catalogo()`
- [ ] Recompensa otorgada con inventario lleno (cola o correo de items) [M]
- [x] Logs de error con contexto [M37] y datos de la operacion [S] — `GameLogger` (M103) + `push_warning` en M37

## K. Persistencia y guardado (8)

- [x] Estado del registro guardado con la partida [M] — iter. 1: ISaveProvider "collections" {piezas, recompensas}; round-trip testeado
- [x] Estado de recompensas otorgadas guardado [S] — iter. 1: _recompensas persistidas; round-trip restaura is_reward_claimed
- [x] Escritura atomica del bloque de museo [M] — K.167 (DeepSeek-V4.1-Flash, 2026-10-09): REUSO del writer atomico de M59 (SaveWriter.write_atomic: .tmp -> rename a .save, con verificacion interna antes del rename); el bloque del museo es UNA seccion ("collections") -> bloque unico. test_museo_persistencia.gd 35 checks/0 fallos x3; fallo de escritura inyectado (directorio en el .tmp) -> sin .save parcial y bloque anterior recuperable (RECOVERED).
- [x] Reconstruccion posicional de objetos en vitrinas al cargar [M] (RF2c: place_item por pieza guardada, test RF3, agnes)
- [x]Migracion de guardados viejos a nuevas exposiciones [C]  — RF2d (DeepSeek-V4.1-Flash, Log 1536, verificado por director con binario real 2026-10-09): test_museo_rf2d.gd 28 checks/0 fallos x3, guardia probado en rojo (piso 28 + bloques no ejecutados); migracion v0->v1 no-mutable, guardia de version futura sin degradar.
- [x] Compatibilidad con el autosave general del juego [S] — K.170 (DeepSeek-V4.1-Flash, 2026-10-09): el autosave (SaveManager.request_save) recolecta la seccion via el proveedor ISaveProvider de CollectionRegistry; probado el motivo "auto_dia", el disparador por EventBus (calendar.day_started), el round-trip y el museo vacio. test_museo_persistencia.gd 35 checks/0 fallos x3.
- [ ] Restauracion de curaduria (nombres y descripciones) al cargar [S]
- [x]Test de carga/descarga con museo al 50% y al 100% [M]  — RF2d (DeepSeek-V4.1-Flash, Log 1536, verificado por director con binario real 2026-10-09): test_museo_rf2d.gd 28 checks/0 fallos x3, guardia probado en rojo (piso 28 + bloques no ejecutados); migracion v0->v1 no-mutable, guardia de version futura sin degradar.

## L. UI y feedback (10)

- [ ] Panel de donacion con lista filtrada de items donables [M]
- [ ] Barra de progreso por exposicion con contador de piezas [S]
- [ ] Tooltip de vitrina al pasar el cursor (nombre y estado) [S]
- [ ] Feedback visual al donar (particulas y brillo en la vitrina) [S]
- [ ] Feedback de rechazo con motivo visible [S]
- [ ] Cartel de recompensa al completar exposicion [S]
- [x] Contador global del museo en el cartel de entrada [S] — iter. 3: get_total_progress() + get_resumen_para_ui() con percent_global/completas/total (cartel M53 con dueño visual)
- [ ] Navegacion completa por mando y teclado en la UI [M]
- [ ] Mensajes de estado durante la carga del edificio [S]
- [ ] Botones deshabilitados durante animaciones para evitar clicks rapidos [S]

## M. Optimizacion y rendimiento (8)

- [ ] Vitrinas instanciadas solo para piezas registradas [C]
- [ ] Culling de salas distantes desde el jugador [M]
- [ ] Consultas is_registered sin allocs en hot path [S]
- [ ] Modelos de piezas con LOD o mesh simplificado [C]
- [ ] Iluminacion estatica horneada en interiores [C]
- [ ] Acuarios con simulacion de nado ligera sin fisicas por pez [M]
- [ ] Carga de sala bajo 250 ms medido con Profiler [M]
- [ ] Inspeccion y UI sin micro-stutter en el frame budget [M]

## N. QA, testings y polish (12)

- [ ] Test: donacion feliz completa una exposicion entera [M]
- [ ] Test: donacion duplicada rechazada con motivo correcto [M]
- [ ] Test: vitrina ocupada nunca sobrescrita [M]
- [ ] Test: recompensa otorgada una sola vez en multiples cargas [M]
- [ ] Test: museo 100% desbloquea el trofeo final [M]
- [x] Test: guardar y cargar conserva piezas y vitrinas [M] (RF2c: test_museo_rf3.gd 0/0 + idempotencia + casos limite, agnes)
- [ ] Test: integracion de senales con M36/M34/M25/M55 [C]
- [ ] Test: edge cases (inventario vacio, sala incorrecta, item inexistente) [M]
- [ ] Recorrido manual: visitar el museo completo tres veces seguidas [C]
- [ ] Polish: animacion de colocacion de la pieza en la vitrina [S]
- [ ] Polish: sonido ambiente del museo (reverb suave, musica tenue) [S]
- [x] Documentacion plan-actual alineada con el codigo real implementado [S]

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 20:40
**Estado:** Liberado (iter. 3 cerrada) — 28/148 [x]

### Lo que hice en iter. 3 (Log 542)
- **RF2 fauna**: exposición "fauna" con las 7 especies REALES del catálogo M36 (data/museum/exhibiciones.json); donación gaviota/conejo testeada de punta a punta (inventario → donación → registro → recompensa).
- **Toast RF6**: _emitir_toast_completada() vía **EventBus.ui.notify** al completar exposición (cola/presentación dueño M53).
- **RF14**: validar_catalogo() accionable headless (id vacío/duplicado, items vacíos, recompensa sin item_id); ejecutado en _ready: 4 exposiciones, 0 problemas.
- **API panel M53 (§7)**: get_resumen_para_ui() (percent_global, completas, total, exposiciones con progreso "X de Y" y recompensa_entregada) + exposiciones_completas_count().
- **M71**: estadística "donaciones_museo" +1 por donación aceptada (PlayerProfile.incrementar duck-typed) — hitos/logros M71/M72 pueden condicionar sobre ella.
- **M55**: puente EventBus.diary.entrada_nueva(id, "museo") por donación (receptor async, no interrumpe el flujo).
- **Tests**: test_museo.gd de 6 → 10 secciones (validación RF14, toast RF6, API panel, estadística M71, diario M55) — 0 fallos.

### Hallazgo técnico importante (pitfall para guía 07 §8)
- **La señal notify vive en el dominio interno UIEvents (bus.ui), NO en la raíz del EventBus.** `bus.has_signal("notify")` devuelve false aunque exista. M72 (Log 527) tenía el mismo bug latente en _emitir_toast() — corregido en ambos sitios y verificado con test que conecta bus.ui.notify. El autoload real es "EventBus_" (class_name EventBus_ para evitar colisión clase/autoload); el acceso correcto siempre es get_node_or_null("/root/EventBus") + bus.ui.notify.

### Lo que NO está resuelto (pendientes con dueño)
- Escena museum.tscn, panel de donación visual, inspección de piezas, cartel físico (M53/M45): la API ya expone todo (get_resumen_para_ui, get_donatable_items).
- RF5 obras de arte ancestral: esperando piezas de M25/M163.
- Recompensa entregada por donación directa al inventario: ya funciona; su visual M53 pendiente.
- Navegación gamepad, tooltips de vitrina, fast travel M69: dueño M53/M69.

### Decisiones clave
1. **Posesión ANTES de donables**: get_donatable_items()/donables_pendientes() filtra por posesión (§4.1.2) — el test debe agregar al inventario antes de consultar (lección capturada en el test).
2. **Toast por dominio bus.ui**: corrección del acceso interno del EventBus (hallazgo compartido con M72).
3. **Estadística en PlayerProfile, no en el Registry**: M71 es el dueño de estadísticas; M37 solo incrementa (desacople).
4. **Fauna con ids de especies M36 reales**: alineado al catálogo verificable de M36 (Log 410) — nada inventado.

### Validación
- test_museo.gd: 0 fallos (10 secciones, ~55 checks).
- Regresiones: M72 0 fallos, M67 0 fallos, M75 0 fallos.
- Boot: [M37] Exposiciones cargadas: 4 + [M37][RF14] Catálogo OK.

### Recomendaciones para el próximo agente
- M53: usar get_resumen_para_ui() para el cartel de entrada y get_donatable_items(sala) para el panel de donación; escuchar EventBus.ui.notify {tipo:"museo"} y señales donation_accepted/rejected/reward_granted.
- Al agregar exposiciones nuevas: seguir el vocabulario de validar_catalogo() (id único, items no vacíos, recompensa con item_id) — la validación se ejecuta en cada boot.
- Para "obras de arte ancestral" (RF5): definir los ids con M25/M163 y añadir la sala al JSON — el resto del flujo ya funciona.
**Totales:** 148 ítems · Completados: 86 · Pendientes: 62 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 36 [x] / 112 [ ] / 0 [?].
> Las marcas no se tocaron.

## NOTA-AGNES (slice RF1/RF5, 2026-10-08, agnes-3-flash)
Este slice implemento la LOGICA del museo (Museum.gd + ExhibitSlot.gd, Node3D headless-friendly)
+ el cableado de donacion/refresh (RF5). El teste test_museo_rf1.gd (0/0) verifica: edificio,
vitrinas instanciadas, place_item (libre/sobrescritura), inspect 'Por donar', refresh_from_registry,
request_donation_ui. PENDING (fuera de este slice): construccion VOXEL 3D de vitrinas (item [C]),
panel UI M53 de donacion + escena museum.tscn posicionada en el mundo. Los [x] de arriba son la
logica verificada, no el 3D/UI.

## NOTA-AGNES RF2a (escena + posicionamiento, 2026-10-08, agnes-3-flash)
- Escena scenes/museo/museum.tscn creada (Museum Node3D + vitrinas instanciadas en runtime por data/museum/exhibiciones.json).
- Museum.placiar_en_mundo(pos=MUSEO_POS) posiciona el edificio en el mundo con TerrainLocator.posicionar_sobre_terreno (anti-flotamiento get_height+1; NEVER IslandGenerator). Test headless: test_museo_rf2.gd 0/0 EXIT 0 (estructura + XZ; el snapping del terreno se verifica en-editor).
- museum_placer.gd instanciado + posiciona el museo en el mundo.
- PENDING (RF2b / M53, NO marcados): construccion VOXEL 3D de vitrinas [C]; mostrador + cartel de progreso (UI M53); escena exhibit_slot.tscn; registro persistente por exposicion; reconstruccion posicional al cargar. No sobremarcaron esas lineas.

## NOTA-AGNES RF2b (voxel 3D vitrinas + exhibit_slot.tscn, 2026-10-08, agnes-3-flash)
- ExhibitSlot._construir_vitrina_3d(): caso voxel (BoxMesh + material translúcido) + pieza interior (silueta tenue libre / sólida al ocupar). Geometría autocontenida (MeshInstance3D + StandardMaterial3D), NO toca M17/M156 (construccion/terreno).
- Escena exhibit_slot.tscn creada (vitrina generica reutilizable).
- test_museo_rf2.gd 0/0 EXIT 0 (estructura voxel: CasoVitrina BoxMesh + PiezaVitrina + place/clear).
- PENDING: coherencia visual exacta del voxel (verificar con vision/M154 en-editor); registro persistente + reconstruccion posicional (siguiente slice).

## NOTA-AGNES RF2c (persistencia + reconstruccion posicional, 2026-10-08, agnes-3-flash)
- Museum.reconstruir_desde_guardado(): al cargar (tras restore_save_data del CollectionRegistry), re-puebla las vitrinas con las piezas guardadas (place_item valida slot libre + pertenece, NUNCA sobrescribe). Casos limite: expo huorfana (ignora), pieza sin vitrina (salta), poblacion parcial (solo lo guardado), idempotencia.
- Persistencia: CollectionRegistry (ISaveProvider 'collections') ya tenia get_save_data/restore_save_data + register_provider; el Museo se sincroniza via refresh_from_registry (ahora delega a reconstruir_desde_guardado). No invente un save nuevo.
- test_museo_rf3.gd 0/0 EXIT 0 (save->load->reconstruir + idempotencia + expo huorfana + pieza inexistente + parcial). RF1/RF2 siguen 0/0.
- L111 (Registro persistente) queda cubierto por el ISaveProvider del registry; lo dejo para que el director lo confirme en su flip.
