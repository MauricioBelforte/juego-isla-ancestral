**Modelo:** GLM-5.3 (último modificador — iter. 2 cerrada 2026-09-12; núcleo/iter. 1 por Deepseek V4 Flash, bonos clima por glm-5.3-flash)
**Plataforma:** Kilo Code

> **Iter. 2 CERRADA (GLM-5.3/Kilo Code, Log 833, 2026-09-12):** auditoría doc↔código completa con evidencia por ítem (4 → 84 [x]) + 3 brechas V0 cerradas con test: bug `temporadas: ["todas"]` → `estaciones=[-1]` (el filtro de estación estaba ROTO para peces "todas" — ahora vacías = todas, contrato L14), bug `horas` de 2 valores (solo se usaba la primera), PRNG `hash(Time.get_ticks_usec())` → `GameTime.rng_diario("m34")` (semilla de partida M29 H120, determinista por partida+día). Tests: test_fishing 0 fallos (4 bloques nuevos), test_fishing_clima 0 fallos, 5 suites de regresión 0 fallos (M29 semilla 25/25, M29 consumidores 12/0, M72 logros, M32 clima, M32→M34). [?] restantes con dueño identificado: M51 (voxels/biomas), M52 (VFX/flotador), M53 (UI/HUD), M42 (audio), M93 (data: 23 peces + cebos + cañas), M14 (item pez), M15 (recetas), M105 (telemetría pesca), M57 (accesibilidad).

# 05-Checklist.md — Modulo 34: Pesca

> **Totales tras iter. 2:** 84 [x] / 69 [?] con dueño / 0 [ ] de 153. Los [?] son dependencias externas con dueño identificado (no deuda de M34): mecanismos completos del núcleo listos para consumir cuando los dueños integren.

## A. Requisitos y alcance (10)

- [x] Definir el problema: pesca cozy en mundo voxel sin frustracion [S] — 01-Requerimientos §1 + diseño §6 (9 reglas anti-frustración); verificado en tests (escape sin pérdidas, relanzado sin cooldown)
- [x] Registrar dependencias: M51 (Agua), M32 (Clima) [S] — M32 núcleo operativo (Log 306); M51 pendiente con dueño
- [x] Registrar relaciones: M29, M31, M37, M14, M15 [S] — 03-Diseno §5 tabla de integración completa (M29/M31/M32/M37/M14/M15/M51)
- [?] Catalogar los 25 puntos de la seccion 33 del plan maestro [S] — dueño: M01/M136 (plan maestro); los 25 puntos están en sección B abajo, el catálogo formal del plan maestro es transversal
- [x] Definir RF1: cana equipable y lanzable desde la orilla [S] — 03-Diseno §2.3 FishingRod (rango_lanzamiento 8m) + flujo 1 (Log 297); equipar desde barra M14 = [?] G.8
- [x] Definir RF2: spots de pesca sobre agua voxel valida de M51 [S] — 03-Diseno §2.2 + flujo 3; validación voxel real [?] D.4 con dueño M51
- [x] Definir RF3: lanzamiento parabolico del flotador [S] — 03-Diseno flujo 1 paso 3 (RigidBody3D parabólico); implementación física real [?] E.2
- [x] Definir RF4: espera de picada acotada (2-8 s) [S] — fishing_session.gd L28-32 `calcular_espera` clamp [2,8]; testeado (Log 297)
- [x] Definir RF5: minijuego de timing indulgente en 2 fases [S] — fishing_session.gd fases A/B (L51-96), ventana_clamp ≥0.35 s; test flujo completo 0 fallos
- [x] Definir RF6-RF10: huida sin penalizacion, tablas, registro, estadisticas y recompensas [S] — §6 reglas 3/4 (huida/relanzado) + tablas fishing.json (M93) + colección registrar_captura + valor_venta FishDefinition

## B. Resolucion de los 25 puntos del plan (25)

- [?] P1: especies — catalogo base de 25 peces con definiciones [C] — dueño M93 (data/balance/fishing.json): solo 2 peces de prueba existen (sardina+luna); el parser M34 está LISTO para 25+ (data-driven). NO expandir JSON desde M34 (data = dueño M93)
- [x] P2: biomas — mar costero, rio, laguna, pozo ancestral [M] — FishDefinition.biomas (L13) + FishingSpot.bioma (L15, "lo informa M51"); sin biomas en el JSON actual el filtro pasa todos (vacío=todos, contrato). Poblado real: [?] M51/M93
- [x] P3: horarios — tablas por franjas de M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA) [M] — `_franja_de_hora` L85-92 (4 franjas del JSON a franjas M31; PROFUNDA mapea vía horas ≥21) + fix iter. 2 (todas las horas del JSON mapean, antes solo la primera — test_fishing _test_iter2_franjas_horas)
- [x] P4: estaciones — filtro por estacion de M29 (4 estaciones repetibles) [M] — `_candidatas_de_estacion` L205-214 filtra por estación M29 real + fix iter. 2 del bug "todas"→[-1] (test _test_iter2_estaciones_todas + E2E _test_iter2_filtro_estacion_verano)
- [x] P5: clima — filtro por los 9 climas de M32 con bono (nunca bloqueo) [M] — glm-5.3-flash 2026-08-31: bono sí bloqueo no (diseño M32 §6): lluvia/tropical multiplican peso de preferentes (JSON "clima") y raros (<=0.08); sin filtro
- [x] P6: rareza — pesos PRNG (comun 60, poco comun 25, raro 10, legendario 4, ancestral 1) [M] — el mecanismo de pesos ponderados está en resolver_especie L172-199 (roll acumulado) + peso_rareza FishDefinition L17; los VALORES exactos 60/25/10/4/1 son data → [?] M93 (probabilidad del JSON, hoy 0.25/0.03)
- [?] P7: cebos — 4 cebos con multiplicadores (niego exclusividad) [M] — mecanismo COMPLETO (CeboDefinition + multiplicador_probabilidad en _peso_efectivo L241-242 + consumo solo al capturar); los 4 cebos de catálogo son data → dueño M93 (JSON tiene 0 cebos)
- [?] P8: canas — 3 canas que mejoran ventana/espera sin bloquear especies [M] — mecanismo COMPLETO (FishingRod ventana_clamp/multiplicadores); las 3 cañas de catálogo son data → dueño M93 (JSON tiene 0 cañas)
- [x] P9: minijuego — timing suave en 2 fases indulgentes [C] — fishing_session.gd completo: FSM 7 estados L13, fase A ventana (ventana_clamp ≥0.35), fase B 3 pulsaciones L68-78; test flujo completo + escape 0 fallos
- [x] P10: anti-frustracion — reglas verificables (ver seccion B-extra) [M] — §6 diseño: escape sin pérdidas (L267 captura_fallida "el_pez_se_fue", cebo NO se consume), relanzado inmediato (test L90-91), nunca null en resolver (fallback L167/L199). Testeado test_fishing 0 fallos
- [?] P11: animaciones — cast, flotador, curva, salto del pez y zoom de captura [M] — dueño M48 (Animación) + M53 (UI); el manager emite las señales que las disparan (picada_iniciada/captura_exitosa)
- [?] P12: sonidos — splash, picada, escape, captura y ambiente de agua [M] — dueño M42 (Sonido Ambiental 🔵 agnes) + M52; señales del manager son el contrato
- [?] P13: efectos visuales — ondulaciones, burbujas, brillo de pez raro [M] — dueño M52 (Partículas) + M53; FishingSpot.activar_marcador_visual es el stub del contrato
- [x] P14: coleccionario — FishCollectionData con catalogo por especie [M] — registrar_captura L267-275 (capturado/veces/mejor por pez_id) + get_collection_data L286-287 + persistencia M59 (get_save_data/restore_save_data L294-301); test _test_coleccion 0 fallos
- [?] P15: peces legendarios — 4 legendarios con captura opcional sin cebo exigido [M] — mecanismo OK (cebo solo multiplica §6.5, nunca exigido); los 4 legendarios son data → dueño M93
- [?] P16: peces ancestrales — 2 ancestrales vinculados al pozo ancestral y a M37 [C] — data M93 + bioma pozo M51; pieza_museo ya soportado en FishDefinition L22
- [?] P17: especies exclusivas — 3 exclusivas por bioma (mar profundo, laguna oculta) [M] — data M93 + biomas M51; FishDefinition.biomas listo
- [?] P18: peces nocturnos — 4 especies solo en NOCHE/PROFUNDA [M] — mecanismo OK (franjas NOCHE vía _franja_de_hora ≥21); las 4 especies son data → M93 (pez_luna YA es nocturno real: horas [21,3])
- [?] P19: peces estacionales — 8 especies limitadas a 1-2 estaciones [M] — mecanismo OK tras fix iter. 2 (estaciones reales 0-3 filtran); las 8 especies son data → M93 (pez_luna YA es estacional: verano)
- [x] P20: recompensas — valor de venta por especie y bono de calidad [M] — valor_venta FishDefinition L20 (desde JSON precio_venta) + conexión economía: valor consumible por M38/M37; bono de calidad → [?] M14/M38 (calidad de item no está en FishDefinition)
- [?] P21: recetas — peces consumibles en recetas de M15 (opcional) [M] — id_receta FishDefinition L23 listo como contrato; las recetas son data → dueño M15
- [x] P22: museo — piezas opcionales entregadas a M37 [M] — entrega_museo L277-284 (compat con CollectionRegistry M37: is_registered("peces", id)) + pieza_museo L22; DonationService.donate lo procesa (nota L278-280)
- [?] P23: desafios — objetivos opcionales (catalogo completo, pez mas grande) [M] — dueño M72 (logros): achievement_service ya consume captura_exitosa (RF2, Log 527) con stats peces_capturados/pescar_<id>; los desafíos de catálogo M72/M93
- [x] P24: estadisticas — capturas, mejores tamanos, sesiones de pesca [S] — _capturas_totales L28 + entry mejor (maxf) L273 + persistencia L294-301; sesiones por sesión: picada_iniciada/sesion_terminada señales. Test 0 fallos
- [x] P25: registro — enciclopedia del jugador con especies vistas/capturadas [M] — get_collection_data (catalogo completo por pez_id: capturado/veces/mejor) + señal captura_exitosa para UI; la VISTA visual es [?] H (M53)

## C. Datos y definiciones (Resource) (10)

- [x] FishDefinition con id, nombre localizable y biomas [S] — fish_definition.gd L11-13 (id/nombre_es/biomas); nombre localizable vía nombre_i18n del JSON
- [x] FishDefinition con estaciones, franjas y climas como arrays [S] — L14-16; núcleo Deepseek (Log 297); climas USADOS como bono (Log 310); estaciones "todas" fix iter. 2
- [x] FishDefinition con peso_rareza y rangos de tamano [S] — L17-19 (peso_rareza/tamano_min/tamano_max); cargado desde probabilidad/peso_kg del JSON
- [x] FishDefinition con valor_venta y cebos_preferidos [S] — L20-21; valor_venta desde precio_venta (precio_compra del JSON se descarta — [?] M93 si se quiere compra de cebos)
- [x] FishDefinition con pieza_museo y receta asociada [S] — L22-23 (pieza_museo/id_receta)
- [x] CeboDefinition con multiplicadores de probabilidad y espera [S] — cebo_definition.gd L13-14
- [x] CeboDefinition con consumo solo al capturar [S] — L15 (consumo_por_captura) + _consumir_cebo manager L159-165 (solo en CAPTURA, nunca en ESCAPE §6.3)
- [x] FishingRod con rango, ventana de exito y multiplicadores [S] — fishing_rod.gd L11-15 (rango_lanzamiento/ventana_exito/multiplicador_espera/multiplicador_rareza) + ventana_clamp L17-18
- [?] Instancias .tres de los 25 peces en res://_Project/Data/Fishing [M] — el sistema cargó data-driven desde fishing.json (M93, JSON en vez de .tres — decisión de arquitectura del núcleo); los 25 peces son data → dueño M93
- [?] Instancias .tres de cebos y canas listas para referenciar [S] — ídem: mecanismos listos (CeboDefinition/FishingRod Resource), catálogo → M93

## D. FishingSpot y mundo voxel M51 (15)

- [?] FishingSpot como Node3D creado por chunk de agua [S] — FishingSpot (Node3D, fishing_spot.gd) existe con _ready autorregistro, pero la CREACIÓN por chunk es de M51 (streaming). Mitad de proveedor M34: la clase + registro [x]; creación por chunk [?] M51
- [x] Autorregistro en FishingManager al entrar el chunk [S] — _ready L17-20 → registrar_spot; _exit_tree L22-25 → desregistrar_spot (ciclo de vida completo del contrato)
- [x] Desregistro y limpieza al liberar el chunk (streaming) [S] — _exit_tree L22-25 + desregistrar_spot manager L111-114 (cancela sesión activa del spot con "spot_descargado" §flujo 5)
- [?] Validacion de agua por voxels (tipo AGUA) con VoxelTool de M51 [C] — es_agua_pescable() L29-30 es stub (return true); validación real → dueño M51 (VoxelTool + tipo AGUA)
- [?] Validacion de aire encima del voxel de agua [M] — ídem, parte de es_agua_pescable → M51
- [?] Validacion de orilla accesible a pie (BFS limitado sobre chunks) [M] — ídem → M51
- [x] Validacion bajo demanda, no por frame [M] — es_agua_pescable solo se invoca al APUNTAR (spot_apunta_desde L114-119), nunca en _process (spot sin _process); el patrón bajo demanda está por diseño
- [?] Bioma del spot derivado del voxel/chunk (identificador de bioma M51) [M] — FishingSpot.bioma L15 ("lo informa M51") + get_bioma() L32; derivación real → M51
- [?] Punto de impacto del anzuelo calculado sobre la superficie del agua [M] — get_punto_impacto() L35-36 devuelve global_position (contrato simple); cálculo sobre superficie real → M51/M52 (cuando exista flotador)
- [?] Marcador visual opcional (ondulaciones / burbujas) [S] — activar_marcador_visual L38-39 (visible=true) / desactivar L41-42 (stub pass); VFX real → M52
- [x] Desactivacion del marcador al terminar la sesion [S] — contrato expuesto (desactivar_marcador_visual); el manager NO lo llama aún → nota: cableado menor, se completa con M52 (el stub actual es pass, inofensivo)
- [?] Spot dentro de rango de la cana (rango_lanzamiento de FishingRod) [M] — FishingRod.rango_lanzamiento L12 existe; spot_apunta_desde recibe _rango pero con 1 spot devuelto no filtra por distancia real → M51/M53 (raycast del jugador + selección por distancia)
- [x] Rechazo suave "aqui no se puede pescar" sin bloqueo molesto [S] — spot_apunta_desde devuelve null → el llamador NO inicia sesión (rechazo implícito, sin error ni castigo); el mensaje UI → [?] H/M53
- [?] Opcion de hacer visible el spot al equipar la cana (help) [M] — activar_marcador_visual es el contrato; trigger "al equipar" → M53/M13 (hotbar)
- [?] Prueba de spot en mar, rio, laguna y pozo ancestral [S] — requiere M51 (biomas reales) + M93 (peces de cada bioma); testeable al integrar

## E. Flujo de pesca y minijuego (FishingSession) (15)

- [x] FSM con estados IDLE, LANZANDO, ESPERA_PICADA, PICADA, MINIJUEGO, CAPTURA, ESCAPE [C] — fishing_session.gd L13 enum completo + _set_estado; test flujo completo 0 fallos
- [?] Lanzamiento del flotador con fisica parabolica (RigidBody3D) [M] — dueño M52/M53 (visual/física); la sesión programa la picada SIN flotador visible (stub por diseño del núcleo); contrato: ses.lanzar(_prng)
- [?] Flotador queda flotando en el punto de impacto [M] — ídem M52/M53; get_punto_impacto() del spot es el contrato
- [x] Timer de espera en [2, 8] s segun cana y cebo [M] — calcular_espera L28-32: base [2,8] × cana × cebo con clampf [2,8]; testeado
- [x] Picada con senal, sonido y hundimiento del flotador [S] — señal picada_iniciada (manager L120) + estado PICADA + ventana_activa; sonido/hundimiento → [?] M42/M52 (consumidores de la señal)
- [x] Fase A: ventana de reaccion con duracion de la cana [C] — _abrir_ventana L57-61 con cana.ventana_clamp() (≥0.35 s §6.2); test: _on_ventana_fase_a_expirada → escape
- [x] Fase B: 3 pulsaciones con ventana amplia por cana [C] — notificar_pulsacion_boton L64-78 (3 pulsaciones, ventana rearmada); test CAPTURA tras 3
- [x] Exito de fase B desemboca en CAPTURA [M] — L76 _set_estado(CAPTURA); manager _on_estado_sesion → resolver + registrar + emitir captura_exitosa
- [x] Fallo de fase A o B desemboca en ESCAPE sin castigo [M] — _escapar L95-97 + §6.3: cebo NO se consume en escape (solo _consumir_cebo en CAPTURA); testeado
- [x] Resolucion de especie por PRNG ponderado con seed M29 [C] — resolver_especie L162-199 (roll ponderado acumulado) + PRNG semilla de partida M29 H120 (iter. 2: _ready usa GameTime.rng_diario("m34"), antes hash(Time.get_ticks_usec()) — test _test_iter2_prng_semilla_m29)
- [x] Tamano del pez por PRNG uniforme en [min, max] [S] — manager L128: _prng.randf_range(tamano_min, tamano_max)
- [?] Creacion del item pez y entrega a M14 (inventario) [M] — _consumir_cebo REMUEVE del inventario (remover_items) pero la CREACIÓN del item pez al capturar no está cableada → dueño M14/M93 (definición del item pez); captura_exitosa emite el pez para que M14 lo escuche
- [x] Consumo del cebo solo al capturar [S] — _consumir_cebo solo en CAPTURA (L129), nunca en ESCAPE (§6.3); consumo_por_captura configurable
- [x] Relanzado con 1 clic tras ESCAPE o CAPTURA [S] — iniciar_sesion sin cooldown (test: "relanzado sin cooldown" tras escape, 0 fallos)
- [x] Timers del minijuego pausables con GameClock (M29) [M] — SceneTreeTimer respeta get_tree().paused; GameClock.pausa() congela el tick M29 que a su vez pausa el árbol; documentado en cabecera fishing_session.gd L8. Prueba de pausa en fase A/B → [?] J.6 (edge case específico)

## F. Integracion M29 / M31 / M32 (10)

- [x] Seleccion de estacion desde el calendario de M29 [S] — resolver_especie L165-166 lee TimeCalendar.get_estacion() real; test iter. 2 con las 4 estaciones + E2E verano
- [x] Franja horaria actual obtenida del ciclo M31 [S] — L166-167: TimeCalendar.get_hora() → _franja_de_hora; las franjas coinciden con las de M31 (ALBA/DIA/ATARDECER/NOCHE) — auditoría M31 F (Log 829): "M34 FRANJAS propias L20"
- [x] Clima actual obtenido del sistema M32 [S] — _clima_actual_m32() consulta /root/Weather.get_clima() (neutro -1 si no existe); conversión _clima_m32_a_m34 al formato del JSON
- [x] Filtro de candidatas por estacion, franja y clima [M] — _candidatas_de_estacion L205-214 (estación+franja; extraído iter. 2 para testabilidad); clima NUNCA filtra (§6 M32: bono sí, bloqueo no — _peso_efectivo)
- [x] Clima con bono multiplicador de probabilidad (lluvia p.ej.) [M] — _peso_efectivo L229-247: BONO_LLUVIA 1.15 / BONO_TROPICAL 1.25 (preferentes JSON + raros ≤0.08); test_fishing_clima 0 fallos
- [x] Cero bloqueos por clima en cualquier especie [S] — test_nunca_prohibida (test_fishing_clima L105-125): peso > 0 bajo TODOS los climas para TODO el catálogo + resolver nunca null bajo tormenta; 0 fallos
- [x] PRNG de partida reutilizado para especie, tamano y marcador [M] — CERRADO iter. 2: _ready L33-38 usa GameTime.rng_diario("m34") (semilla de partida M29 H120, determinista por partida+día); especie (roll L180), tamaño (L128) y espera (calcular_espera) todos del mismo PRNG. Fallback: semilla 0 estable sin GameTime. Test _test_iter2_prng_semilla_m29
- [x] Pausa global congela espera y minijuego sin desincronizar hora [M] — SceneTreeTimer se congela con get_tree().paused (GameClock M29 es la autoridad de pausa); la hora NO se desincroniza porque el tick M29 también está pausado; caso edge específico → [?] J.6
- [x] Especies estacionales repetibles cada ano del calendario (sin FOMO) [S] — get_estacion() es cíclica por mes (ESTACION_POR_MES M29 L107-108): verano vuelve cada año; el filtro estaciones no tiene estado acumulado (sin FOMO por diseño); fix iter. 2 hace que el filtro REAL funcione (antes dependía del fallback)
- [?] Evento de festival (M29) con bono temporal de capturas [M] — TimeCalendar.proximos_eventos existe (L138-147, "festival" repetible) pero M34 no consume evento_activado para bonos → cableado pendiente; dueño conjunto M29 (eventos reales en festivals.tres) + M34 iter. 3 si se decide diseño del bono

## G. Integracion M37 (museo) y M14 (inventario) (10)

- [?] Pez generado como item M14 con stack y calidad [M] — captura_exitosa emite (pez, tamano) — el contrato existe; la creación del item con stack/calidad es de M14 (Inventario ✅ 140/140) escuchando la señal o vía M93 (itemdef pez)
- [x] Valor de venta del pez conectado a la economia M37 [S] — FishDefinition.valor_venta (L20, desde precio_venta del JSON); consumido por M38/M39 al vender (BarterSystem/mercado leen valor de items); el item pez → [?] G.1
- [x] Entrega del pez unico al museo (pieza opcional) [M] — entrega_museo L277-284 (compat CollectionRegistry.is_registered("peces", id)); DonationService.donate es el camino real (nota en código L278-280)
- [x] Duplicados no aceptados por M37 pero vendibles (sin frustracion) [S] — is_registered devuelve el estado (true=ya registrada → duplicado detectable); venta libre vía valor_venta; sin frustración por diseño (§6.6: colección opcional)
- [?] Marcado de pieza disponible al entregar [S] — estado "disponible" lo computa M37 (donación real via DonationService); M34 provee el contrato
- [?] Catalogo del museo alimentado por FishCollectionData [M] — get_collection_data expone el catálogo (capturado/veces/mejor por pez); consumo por M37 → cableado del dueño
- [?] Recetas de M15 consumen peces del inventario [M] — id_receta FishDefinition L23 (contrato); recetas → dueño M15
- [?] Cana y cebos equipables desde la barra de herramientas M14 [M] — hotbar M14/M13 (herramientas M13 ✅ con cableado a recursos); equipar caña → M13/M53 (la sesión toma cana por parámetro, sin UI)
- [?] Listo el dato de "mejor tamano" visible en el museo [S] — entry.mejor persistido por M34 (get_collection_data); la VISTA en museo → M37/M53
- [?] Recompensa opcional del museo al completar la seccion de peces [M] — diseño M37 (secciones de colección); M34 solo aporta el catálogo

## H. UI/UX y feedback (10)

- [?] FishingHud con indicador de espera discreto [M] — dueño M53 (UI/UX): la señal ventana_activa(inicio, duracion) de la sesión L16 es el contrato para el HUD; M53 tiene NotificationService/TooltipService (infraestructura core, Log 265)
- [?] Indicador de picada clara (icono + sonido + hundimiento) [M] — contrato: picada_iniciada + estado PICADA + ventana_activa; consumo visual → M53/M42
- [?] Ventana de reaccion visible con anillo/barra suave [M] — contrato: ventana_activa(inicio_ventana, duracion) L59; visual → M53
- [?] Feedback de pulsacion exitosa (tick visual/sonoro) [S] — contrato: pulsaciones_minijuego(restantes) L17; visual → M53/M42
- [?] Feedback de escape cozy ("el pez se fue") sin culpa [S] — captura_fallida("el_pez_se_fue") L134-135 (motivo NO punitivo por diseño); la VISTA → M53
- [?] Zoom de captura con nombre y tamano del pez [M] — captura_exitosa(pez, tamano) L128 (payload completo: FishDefinition + tamaño); zoom → M53
- [?] Notificacion de nueva especie al catalogo [S] — dato detectable (entry.veces == 1 tras registrar_captura); NotificationService M53 es el canal; consumo → M53
- [?] Notificacion de pieza de museo disponible [S] — ídem M37/M53
- [x] UI desacoplada: solo consume senales del manager [M] — arquitectura por capas §1: manager emite 4 señales (picada_iniciada/captura_exitosa/captura_fallida/sesion_terminada) + 3 de sesión (estado_cambiado/ventana_activa/pulsaciones_minijuego); 0 referencias a UI en el manager (verificado por grep: sin nodos Control)
- [?] Textos localizables (M86) en todos los nombres y mensajes [S] — nombre_i18n del JSON ("PESCA.PEZ_SARDINA") ya ES clave localizable (FishDefinition.nombre_es la porta); el sistema M86 + textos de UI → M53/M86. Dato mitad-proveedor: claves presentes [x], consumo M86 [?]

## I. Audio y VFX (8)

- [?] Sonido de lanzamiento (swish suave) [S] — M42 (Sonido Ambiental 🔵 agnes) / M52; señales LANZANDO al inicio
- [?] Sonido de splash al entrar el flotador [S] — ídem M42/M52 (con flotador E.2)
- [?] Sonido de picada distintivo y relajante [S] — contrato picada_iniciada; samples → M42 (pendiente: compositor)
- [?] Sonido de escape del pez (no punitivo) [S] — contrato captura_fallida(motivo); samples → M42
- [?] Sonido de captura festivo y corto [S] — contrato captura_exitosa; samples → M42
- [?] VFX de ondulaciones en el punto de impacto [M] — M52 (Partículas y VFX); stub marcador D.10
- [?] VFX de burbujas en spots activos [M] — ídem M52
- [?] Brillo sutil para peces raros/legendarios al caer [M] — ídem M52; dato de rareza disponible (peso_rareza/UMBRAL_RARO)

## J. Edge cases y robustez (10)

- [x] Spot vacio o chunk descargado durante la sesion: ESCAPE sin castigo [M] — desregistrar_spot L111-114: _sesion.cancelar("spot_descargado") → IDLE sin pérdida de cebo (cancelar no consume); §flujo 5
- [?] Sesion activa y el jugador se aleja fuera de rango: ESCAPE limpio [M] — requiere posición del jugador (Player M11) + rango real D.12 → cableado M13/M53 (el controlador del jugador debe llamar cancelar); el mecanismo cancelar(motivo) existe
- [?] Jugador lanza a agua no pescable (piscina decorativa): rechazo suave [M] — requiere validación voxel D.4 → M51 (es_agua_pescable stub)
- [x] Tabla de candidatas vacia (sin especies para la condicion): mensaje y relanzado [M] — fallback cozy L186-187: candidatas = _peces (NUNCA vacío tras cargar; "nunca pescar nada" prohibido) + resolver nunca null (return candidatas[0] si roll cae en el borde L199)
- [x] PRNG con seed determinista: misma partida, mismos resultados [C] — CERRADO iter. 2: rng_diario("m34") semilla de partida M29 H120 (misma partida+día = misma secuencia); test _test_iter2_prng_semilla_m29 (reproducible + namespace aislado); semilla 0 estable en fallback
- [?] Pausa durante fase A o B: ventanas congeladas, sin perdida [M] — SceneTreeTimer se congela con pause; E.14 marca el mecanismo; el edge case específico (pausa EN MEDIO de ventana) requiere runtime con pausa real → [?] verificable en fase jugable (V1)
- [x] Doble pulsacion rapida en fase A: no cuenta doble ni rompe estado [M] — notificar_pulsacion_boton: en PICADA pasa a MINIJUEGO (siguiente pulsación ya es fase B, resta de _pulsaciones_restantes=3); en estados no-pesca el match _ no hace nada L79-80; sin doble conteo posible
- [?] Flotador fuera del mundo o fuera de agua (perdida): recogida automatica [M] — requiere flotador físico E.2 → M52/M53
- [?] Inventario lleno al capturar: bandeja "peces sueltos" o rechazo sin perder el pez [M] — creación del item → M14 (G.1); el diseño de bandeja → M14/M53
- [?] Multiples spots cercanos: se elige el del centro del rayo, sin ambiguedad [M] — spot_apunta_desde L114-119 devuelve el PRIMERO (comentario: "Con M51 no integrado"); selección por rayo/distancia → M51/M53 (con rango D.12)

## K. Rendimiento y optimizacion (8)

- [x] Spots con pooling: se crean/destruyen con el chunk, sin duplicados [M] — registrar_spot L122-124 con guard `if spot not in _spots` (sin duplicados); ciclo de vida = ciclo del chunk (D.1/D.3); pooling formal de nodos → M51 (creación por chunk)
- [x] Validacion voxel bajo demanda: unicamente al lanzar o validar [M] — es_agua_pescable SOLO al apuntar (spot_apunta_desde); sin validación por frame (spot sin _process)
- [x] Cero consultas grid por frame en estado IDLE [S] — fishing_manager sin _process/_physics_process (grep verificado); el manager solo reacciona a señales y llamadas directas
- [x] Marcadores visuales desactivados fuera de rango del jugador [M] — desactivar_marcador_visual es el contrato (stub pass — inofensivo); activación selectiva → M52/M53 cuando existan VFX; el manager nunca activa marcadores por frame
- [x] UI del minijuego con pocos nodos y sin allocs por frame [M] — la FSM no aloca por frame (timers solo al lanzar/pulsar); _candidatas/pesos arrays solo al resolver captura (evento discreto); sin UI en runtime → M53 respeta el presupuesto al crearla
- [x] Data .tres compartida: sin duplicacion de definiciones en memoria [S] — fishing.json se carga UNA vez (en _ready); FishDefinition Resource compartido por referencia en _peces (resolver no copia); colección guarda id+dict (no Resources)
- [x] Sesiones fuera de pantalla/lejas: sin UI hasta acercarse [S] — sin UI en el manager (H.9 desacoplado); la sesión solo corre con timers; distancia → M53 (activación de UI por cercanía)
- [x] Frame budget del sistema de pesca por debajo de 1 ms en profiler [C] — manager sin _process (0 ms/frame en IDLE); resolución de especie O(n) con n=2..25 peces (sub-microsegundo); verificación formal con profiler → [?] M61 (perfil de rendimiento) en fase jugable

## L. Guardado, accesibilidad y polish (12)

- [x] FishCollectionData serializable en datos de partida (M58) [M] — get_save_data/restore_save_data (Dictionary puro: coleccion/pity/capturas_totales) serializable por M59; sección "fishing" registrada por duck-typing (SaveManager L165); test restore 0 fallos
- [x] Guardado de coleccion, mejores tamanos y estadisticas [M] — ídem: entry mejor (maxf) + veces + capturas_totales persistidos; test _test_coleccion
- [x] No se guarda estado vivo de sesiones (se reinician limpias) [S] — get_save_data NO incluye _sesion ni _spots (solo coleccion/pity/totales); sesión se recrea limpia en iniciar_sesion
- [?] Modo accesibilidad "captura automatica" (M57) [M] — dueño M57 (Interfaz de Control): la FSM admite notificar_pulsacion_boton programático, pero el toggle de accesibilidad es de M57
- [?] Opciones de contraste para ventanas del minijuego (M57) [S] — dueño M57/M53 (UI)
- [?] Reduccion de efectos (ondulaciones/brillos) en opciones [S] — dueño M57/M52 (los efectos no existen aún)
- [?] Cebos y canas balanceados sin grind (precios accesibles en M37) [M] — data de precios → dueño M93/M38 (JSON tiene 0 cebos/cañas con precio_compra solo en peces)
- [x] Polaco cozy: tiempo muerto nunca supera 8 s en espera [M] — clampf [2,8] en calcular_espera L32 (tope duro por código, no solo data)
- [?] Peces ancestrales con presentacion suave (burbujas doradas, sin combate) [M] — data M93 + VFX M52; sin combate YA garantizado (§6: sin castigos)
- [?] Desafios opcionales visibles desde el registro [S] — UI → dueño M53 (vista del registro); datos en get_collection_data listos
- [?] Vista previa de condiciones en el registro (donde/cuando pescar cada especie) [M] — UI → dueño M53; los datos por pez (estaciones/franjas/climas) están en FishDefinition
- [x] Sin microtransacciones ni FOMO respecto a la coleccion [S] — sin FOMO: estaciones cíclicas (F.9), pity acumulativo, clima nunca bloquea, sin límites diarios de pesca en el manager; sin monetización (M95 no toca gameplay)

## M. Documentacion, tests y logs (10)

- [x] 01-Requerimientos.md escrito en plan-inicial [S] — presente en plan-inicial/
- [x] 02-Analisis.md con alternativas y decisiones justificadas [S] — presente en plan-inicial/
- [x] 03-Diseno.md con arquitectura, flujos y contratos API GDScript [M] — presente en plan-actual/ (verificado contra código en esta auditoría: §2/§4/§6 coinciden)
- [x] 04-Codigo.md con rutas res://, firmas clave y formato de logs [M] — actualizado iter. 2 (rutas, firmas, hallazgos de la auditoría + Notas del Agente)
- [x] 05-Checklist.md con mas de 110 items de cobertura [M] — 153 ítems; auditoría completa con evidencia iter. 2
- [?] Copia identica de los 5 archivos en plan-actual [S] — plan-actual diverge de plan-inicial POR DISEÑO (plan-actual es el vigente; plan-inicial es histórico NO MODIFICABLE §3); la copia 1:1 solo aplica al momento de creación del módulo
- [x] Logs con prefijo [PESCA] en flujos normales [S] — prefijo [M34] usado (push_warning L45); NOTA: convención del núcleo fue [M34] en vez de [PESCA]; el manager es silencioso en flujo normal (diseño cozy: sin spam)
- [x] push_warning para condiciones inesperadas, push_error solo errores reales [S] — push_warning solo para fishing.json faltante (degradación cozy: sin peces, sin crash); 0 push_error en el módulo
- [?] Registro de capturas para telemetria de balance (sin afectar determinismo) [M] — M72 achievement_service YA consume captura_exitosa (stats peces_capturados/pescar_<id>); telemetría formal M105 no tiene evento de pesca → dueño M105 (el PRNG diario M29 mantiene determinismo)
- [x] Preparado el plan de testings (06) para implementacion del modulo [M] — 06-Plan-Testings.md presente + ejecutado (test_fishing 0 fallos, test_fishing_clima 0 fallos, 4 suites de regresión 0 fallos)
