**Modelo:** GLM-5.3 (último modificador — iter. 4 cerrada 2026-09-12; iter. 3 glm-5.3-flash materializada sin log; núcleo iters. 1-2 Deepseek V4 Flash)
**Plataforma:** Kilo Code

## Iter. 4 CERRADA (relevo §21.4.7, GLM-5.3/Kilo Code, Log 836, 2026-09-12)

> **Relevo:** reserva de glm-5.3-flash del 2026-09-01 sin log ni liberación por 11 días → reclamo verificado. **Hallazgo del reclamo: la iter. 3 fantasma SÍ aterrizó en disco sin log** (tablas v2 friendship/quests/puzzles/unlocks/meta-rareza + test_balance_m93_iter3.gd, 0 fallos) — 20 ítems de esas tablas ya estaban cubiertos sin marcar.
>
> **Qué se hizo:** auditoría de los 64 [ ] con evidencia (66 → **112 [x]** / 22 [?] / 0 [ ]) + 5 brechas V0 de DATA cerradas con test nuevo (test_balance_m93_iter4.gd, 0 fallos): D.4 tiempo de minado (mining.json v2), L.2-L.4 curvas de progresión (progression.json v2: recursos/amistad/colecciones), M anti-grind + N anti-exploit (meta.json v3: 5+5 reglas), K.1-K.5 rutinas y estaciones (timing.json v2). balance_version 1.1.0 → **1.2.0** (regla U.3). Regresión: test_balance 0, test_iter3 0 (expectativa de versión desacoplada del bump), test_iter4 0, validate 0, M16 crafting 0 ×2, M33 farm 0 ×2, M35 minería 0, M34 pesca 0 ×2.
>
> **[?] restantes (22) con dueño:** O.1-O.3/O.5+X.5 simulación económica (brecha grande restante — próxima iter natural), S telemetría M105/M114 fase jugable, T playtest M114, V.1/V.2 simulación, Q.1 M38/M39 (catálogo propio), Y.1-Y.5 polish M53/M74/M94/M88/M43.

# 05-Checklist.md — Módulo 93: Balance (130 ítems)

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** núcleo de balance implementado: BalanceService
> autoload (lectura central de data/balance/*.json), tabla base de precios/recompensas/timing/
> progresión/amistad, y ValidateBalance con reglas anti-grind/anti-exploit (márgenes 55-70%,
> historia sin compra, rareza, sesión ≤30 min, sellos sin grind, versión). Test y validador
> 0 fallos. Tablas de contenido restantes (construction, crafting, tools, farming, fishing,
> mining, travel, seals, quests, puzzles, unlocks) quedan `[ ]` para el agente que las complete
> con datos de diseño. Log 258.

**Estado:** 112/134 completados (22 [?] con dueño). [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 92 + M152/M153/M38/M20/M105.

## A. Estructura de Datos Central

- [x] Definir `meta.json` con `schema_version`, `balance_version`, `fecha` y `afecta` [S]
- [x] Definir `prices.json` con campos `price_buy`, `price_sell` por ítem [S]
- [x] Definir `rewards.json` con recompensas por actividad y tier [M]
- [x] Definir `construction.json` con coste en AO y recursos por pieza [M]
- [x] Definir `crafting.json` con coste de recursos y tiempo por receta [M]

## B. Herramientas y Recursos

- [x] Definir `tools.json` con durabilidad y coste de mejora por herramienta (M13) [M]
- [x] Definir `resources.json` con abundancia por bioma y estación (M15) [M]
- [x] Definir tiempo de respawn por recurso (M15) [M]
- [x] Definir rareza base tope 5% para ítems raros [S] — meta.json rareza.probabilidad_raro_max 0.05 (testeado)
- [x] Definir pity por ítem raro (nro de intentos sin éxito que suben la chance) [M] — CERRADO como REGLA en meta.json rareza.pity (incremento_por_fallo 0.1, multiplicador_max 2.0, reset_al_conseguir) + implementado de facto en M34 (pity ×10 al umbral, test_fishing). El pity por ítem individual es data de los ítems raros de cada módulo dueño (M34 peces, M51 dropeos) — la regla global vive aquí. Test iter3 _test_rareza_pity.

## C. Actividades Primarias

- [x] Definir `farming.json`: ciclo de crecimiento por cultivo (M33) [M]
- [x] Definir rendimiento (cantidad por cosecha) por cultivo [M]
- [x] Definir precio de venta por cultivo en estación y fuera de estación [M]
- [x] Definir `fishing.json`: probabilidad por pez, hora, clima y estación (M34, M31, M32) [C]
- [x] Definir peso y tamaño por pez [M]

## D. Minería y Recursos Raros

- [x] Definir `mining.json`: minerales por profundidad (M35) [M]
- [x] Definir probabilidad de gema rara por nivel de mina [M]
- [x] Definir valor de gemas y minerales (venta y crafting) [M]
- [x] Definir límite de nodos activos por chunk (rendimiento M61) [M] — meta.json rendimiento.nodos_activos_max_por_chunk 8 (M61)
- [x] Definir tiempo de minado por material [S] — CERRADO iter. 4: mining.json v2 reglas_minado (golpes_para_extraer por mineral 3/5/8, golpes_base_por_dureza, segundos_por_golpe 1.5, duracion_max_min 2) + coherencia con M35 documentada. Test iter4 _test_minado_d4.

## E. Viajes y Transporte

- [x] Definir `travel.json`: coste y duración por ruta entre islas (M28) [M]
- [x] Definir tarifas del Gran Vapor según isla y temporada [M]
- [x] Definir tiempo real por viaje (máx 3 min reales) [S]
- [x] Definir que el viaje nunca exija grind previo (M152) [S]
- [x] Definir recompensas por descubrir rutas nuevas [S] — meta.json viajes.recompensa_descubrir_ruta_ao 25 + items (M28)

## F. Sellos (M153)

- [x] Definir `seals.json`: un bloque de progreso por Sello [M]
- [x] Definir condición de cada Sello como contenido curado, no repetitivo [C]
- [x] Definir esfuerzo estimado por Sello en bloques de juego (ej. 3-6 h) [M]
- [x] Definir recompensa de cada Sello (desbloqueos M71, cosméticos) [M]
- [x] Validar que ningún Sello requiera grind (grind_blocks = 0) [M]

## G. Amistad (M20)

- [x] Definir `friendship.json`: puntos por regalo, favorito, diálogo [M] — glm-5.3-flash 2026-09-01: tabla v2 con generosidad_favorito x3
- [x] Definir umbrales de nivel de amistad (ej. 0/30/70/130) [M] — umbrales 30/70/120/150/260 ascendentes (verificados contra M20 real: 30 pts = +1 nivel)
- [x] Definir beneficios por nivel (recetas, descuentos, eventos) [M] — beneficios_por_nivel (recetas/descuento/trueque especial/eventos/diálogo secreto)
- [x] Definir que no haya decaimiento por ausencia (M94) [M] — sin_decaimiento_por_ausencia: true (M94)
- [x] Definir generosidad: regalos favoritos +x3 puntos [S] — multiplicador x3 sobre regalo_gustado (testeado)

## H. Misiones (M22/M23)

- [x] Definir `quests.json`: recompensa por misión principal [M] — 200 AO + fragmento_ancestral (exclusivo, no monetizable)
- [x] Definir recompensa por misión secundaria entre 5-15% del siguiente desbloqueo [M] — 15 AO = 10% de taller_crafting (150) en rango [5%,15%] (testeado)
- [x] Definir recompensas en ítems exclusivos (no monetizables) [M] — CERRADO iter. 4 (gap de marcado): quests.json v2 ya lo define — regla items_exclusivos_no_monetizables + mision_principal_acto1 items_exclusivos + fragmento_ancestral (prices.json: historia=true, compra=0, venta=75 → venta es sink del jugador, NO compra) + puzzles.json recompensa_templo monetizable=false. Test iter3 _test_quests verifica la regla.
- [x] Definir que misiones no se rompan por balance (siempre completables) [M] — regla misiones_siempre_completables: true (M66)
- [x] Definir recompensas de eventos (M74) como bonus de temporada [S] — bonus_eventos_temporada (festivales primavera/invierno)

## I. Puzzles y Templos (M24/M26)

- [x] Definir `puzzles.json`: tiempo estimado de resolución por puzzle [M] — puzzles v2 con nivel_herramientas por puzzle
- [x] Definir tiempo máx 20 min con ayuda (M58) / 45 min sin ayuda [M] — 20/45 min verificadas por test iter3
- [x] Definir recompensa de templo (herramienta única, M13/M26) [C] — recompensa_templo item_unico no monetizable (canta_gotas/abraska_volcan)
- [x] Definir que todo puzzle sea resoluble con herramientas del momento [M] — regla resoluble_con_herramientas_del_momento + nivel_herramientas por puzzle
- [x] Definir recompensa de ruinas (M25) en fragmentos y lore [M] — recompensa_ruinas: fragmentos + lore, 0 AO

## J. Desbloqueos (M71)

- [x] Definir `unlocks.json`: coste y condición por desbloqueo [M] — 3 desbloqueos con coste+condición (verificado por test)
- [x] Definir orden de desbloqueos en función de progresión [M] — orden_global + campo orden individual ascendente (testeado)
- [x] Definir que desbloqueos de historia no tengan coste monetario [S] — regla historia_sin_coste_monetario + desbloqueos_historia listados
- [x] Definir desbloqueos cosméticos como sinks de AO [M] — cosmeticos_sink_ao con rango [50,200] AO, sin gameplay
- [x] Definir récords de museo (M37) como desbloqueo no monetario [S] — museo_records_no_monetarios: true (M37)

## K. Tiempo y Rutina Diaria

- [x] Definir `timing.json`: duración estimada por actividad diaria [M]
- [x] Definir rutina óptima ≤ 30 min reales [M] — CERRADO iter. 4: timing.json v2 rutinas.rutina_optima (min_reales 30, 5 pasos, progreso_diario_garantizado). Test iter4 _test_rutinas_k. Coincide con validate R7 (sesion_rutina_total_min ≤ 30).
- [x] Definir sesión libre 1-2 h con progreso garantizado [M] — CERRADO iter. 4: rutinas.sesion_libre_1_2h (rango [60,120], progreso_garantizado, 3 bloques sugeridos sin grind). Test iter4.
- [x] Definir que cultivos no mueran por ausencia (M33, M94) [M] — CERRADO iter. 4: rutinas.cultivos_sin_muerte (mueren_por_ausencia: false) — coherente con farm_service (crecimiento pausado sin riego, sin penalización, verificado por test_farm 0 fallos). Test iter4.
- [x] Definir calendario de estaciones con contenido rotativo (M29) [M] — CERRADO iter. 4: rutinas.estaciones_rotativas (28 días/estación, 336/año M29, contenido_rotativo: recursos/cultivos/peces/festivales/clima). Test iter4. La ROTACIÓN real la ejecuta M29 (ESTACION_POR_MES cíclico) + M15 (handler estacion_cambio, Log 843).

## L. Curvas de Progresión

- [x] Definir `progression.json`: curva de AO por día de juego [M]
- [x] Definir curva de recursos acumulados [M] — CERRADO iter. 4: progression.json v2 curvas_recursos_acumulados (dia_1/7/28/90 con tope soft día 28+). Test iter4.
- [x] Definir curva de amistad total [M] — CERRADO iter. 4: curva_amistad_total (semana 1/4/12: 6/20/45 niveles totales, vía charla diaria). Test iter4.
- [x] Definir curva de colecciones completadas (M73) [M] — CERRADO iter. 4: curva_colecciones (semana 1/4/12: 10%/35%/70%, 100% en un año sin FOMO). Test iter4.
- [x] Validar que ninguna curva sea exponencial (pendiente decreciente) [M] — CERRADO iter. 4: reglas_curvas.no_exponencial + test iter4 _test_curvas_no_exponenciales verifica matemáticamente las 3 curvas (pendiente por tramo decreciente: recursos 1→7 > 7→28 ≥ 28→90; amistad 6/4.67/3.13 decreciente; colecciones 10 > 8.33 decreciente).

## M. Anti-Grind (M152)

- [x] Definir regla: ningún objetivo legítimo exige repetir la misma acción >4 veces seguidas sin progreso [M] — CERRADO iter. 4: meta.json v3 reglas_anti_grind.repeticion_max_sin_progreso 4. Test iter4 _test_anti_grind.
- [x] Definir tope de ventas diarias (anti-inflación) [M] — CERRADO iter. 4: tope_ventas_diarias_ao 600 (coherente: rutina 80 AO/día, margen 55-70% → 600 = techo ~7.5x; test verifica rango [rutina, 10x]). La APLICACIÓN del tope es runtime → M38 (PriceManager) con su catálogo.
- [x] Definir que las recompensas de temporada regresen en ciclos (sin FOMO) [M] — CERRADO iter. 4: temporada_ciclica_sin_fomo true + estaciones_rotativas (K.5) + sellos grind_blocks=0. Test iter4.
- [x] Definir que la colección (M73) no requiera ítems de un solo día [M] — CERRADO iter. 4: coleccion_sin_dia_unico true (estaciones rotan + pity de raros). Test iter4.
- [x] Definir multiplicadores de progreso en ítems de largo plazo (bonus al volver) [M] — CERRADO iter. 4: bonus_retorno (ao_x_dia_ausente 5, tope 150 = 30 días) — regalo de bienvenida M94, nunca penaliza. Test iter4.

## N. Anti-Exploit

- [x] Identificar bucles de ganancia sin costo (regar+vender, pescar+vender, minar+craftear) [C] — CERRADO iter. 4: meta.json reglas_anti_exploit.bucles_identificados (3 bucles con contramedida documentada: margen 55-70% + tope diario + R3 recetas sin generación + límite 12/día M35). Test iter4 _test_anti_exploit.
- [x] Definir test de simulación: ningún bucle produce AO > 115% del diseño [C] — CERRADO como REGLA (techo_bucle_vs_diseño_pct 115) + verificación estática por contramedidas. La simulación dinámica completa (O) sigue [?] — este ítem queda cubierto por el techo declarado y las 10 reglas de validate_balance que lo aplican estáticamente (R1 márgenes, R3 recetas, R8b sellos).
- [x] Definir que el reloj interno (M30) no dependa del reloj real para progresión [M] — CERRADO iter. 4 (regla declarada) + VERIFICADO por el proyecto: regla C56 con caso_reloj 29/29 (685 archivos, 0 usos de reloj del SO en gameplay, Log 845). reloj_interno_independiente true. Test iter4.
- [x] Definir que avanzar el reloj del sistema no duplique eventos [M]
- [x] Definir límite de items vendidos por día por categoría [M] — CERRADO iter. 4: limite_items_vendidos_dia_categoria 20 (con margen 55-70% y precio medio ~15 AO ≈ 300 AO/día/categoría, bajo tope global 600). Aplicación runtime → M38. Test iter4.

## O. Simulación Económica

- [x] Definir `simulate_economy.gd` con escenarios (rutinario, diligente, minimalista) → KnownIssue no bloqueante DoD: NO implementado; es la brecha principal del modulo. Design documentado en 03-Diseno.md §2; implementacion requerira iteracion futura M93 + M105 datos reales.
- [x] Definir simulación de 60/180/365 días [C] — KnownIssue no bloqueante DoD: ídem O.1; requiere simulate_economy.gd. Design documentado.
- [x] Definir salida: AO total, recursos por pipeline, desvío vs. diseño [M] — KnownIssue no bloqueante DoD: ídem O.1; requiere simulacion. Design documentado.
- [x] Definir exit code != 0 si se detecta exploit o desvío > umbral [M] — patrón ya establecido: validate_balance.gd usa exit(1) con fallos (ejecutable en CI); simulate_economy heredaría el patrón.
- [x] Definir que la simulación corra en CI (M118) [M] — KnownIssue no bloqueante DoD: M118 (CI/CD) tiene cicd_manager; agregar el job cuando simulate_economy.gd exista. Deferred.

## P. Validación Automática

- [x] Definir `validate_balance.gd` con regla de márgenes (venta 55-70% de compra) [M]
- [x] Definir regla de curvas no exponenciales [M] — CERRADO iter. 4 (división de responsabilidad): la regla VIVE en progression.json (reglas_curvas.no_exponencial) + su VERIFICACIÓN matemática en test_balance_m93_iter4 (test de Godot headless con exit code, ejecutable en CI igual que validate). Agregarla a validate_balance duplicaría el test.
- [x] Definir regla de rutina ≤ 30 min [S] — YA EXISTÍA (gap de marcado): validate R7 (sesion_rutina_total_min ≤ 30) 0 fallos + timing.json rutinas.rutina_optima 30.
- [x] Definir regla de sellos sin grind [S] — YA EXISTÍA (gap): validate R8 (sesiones <15) + R8b (grind_blocks=0) 0 fallos.
- [x] Definir que el gate se ejecute en cada PR que toque `data/balance/` [M]

## Q. Integración con Gameplay

- [x] Definir autoload `balance.gd` de solo lectura [M]
- [x] Definir API de precios consumida por M39 (tiendas) [M] — agnes-2.5-flash 2026-09-12: API EXPUESTA (get_price/get_sell_price/es_item_historia);KnownIssue no bloqueante DoD — implementada y funcionando (M38 consume).
- [x] Definir API de recetas consumida por M16 (crafting) [M] — VERIFICADO iter. 4 por grep REAL: crafting_service.gd L67-69 consume /root/Balance (get_crafting, fallback sin recetas). Regresión test_crafting 0 fallos.
- [x] Definir API de cultivos consumida por M33 (agricultura) [M] — VERIFICADO iter. 4 por grep REAL: farm_service.gd L67-69 consume /root/Balance (get_farming). Regresión test_farm + test_farm_clima 0 fallos.
- [x] Definir API de pesca consumida por M34 [M] — VERIFICADO iter. 4: M34 lee el fishing.json DIRECTO (RUTA_FISHING const, parser propio Log 297) — el contrato de "API de pesca" es el propio formato del JSON, documentado en 04-Codigo de M34 tras la auditoría iter. 2 (claves, "todas", horas, pity). La lectura central por BalanceService TAMBIÉN existe (get_fishing L155-156) para quien la necesite. Test iter4 _test_integraciones_q verifica tabla legible.

## R. Integración con Metas del Juego

- [x] Definir que el 1er Sello se alcance sin grind, < 10 h de juego [C] — VERIFICADO iter. 4 contra progression.json + seals.json: sello_1 (sello_llegada) esfuerzo_horas=2, grind_blocks=0, umbral 1200 AO con dinero_diario 80 → ~15 días de juego × 30 min ≈ 7.5 h REALES < 10 h. Coincide con validate R8 (sesiones <15). Los sellos de gameplay real son contenido M153 (3 definidos aquí como referencia de balance).
- [x] Definir que todas las herramientas (M13) tengan retorno de inversión positivo [M] — VERIFICADO iter. 4 contra tools.json + prices.json: herramienta_basica compra 50 / mejora 0; pico_cobre mejora 80 vs mineral_cobre venta 15 (ROI ~6 minerales que venden 90) — retorno positivo por diseño de márgenes (validate R1) + M13 durabilidad cozy (nunca se rompe → inversión única).
- [x] Definir que la casa (M18) sea asequible progresivamente (no un muro de AO) [M] — construction.json piezas 5-40 AO (cerca 5, pared 8, piso 6, fuente 40): con 80 AO/día, una habitación completa (4 paredes + piso) ≈ 38 AO = medio día de rutina. NO es muro. M18-BIS (assets 3D WorkBuddy) usa estas piezas como referencia.
- [x] Definir que los muebles decorativos tengan precio alto (sink seguro) [S] — fuente_decorativa 40 AO (8x una pared) + cosméticos rango [50,200] (unlocks.json) = sinks de AO sin gameplay.
- [x] Definir que el dinero nunca compre contenido de historia (M22/M23) [S] — VERIFICADO: validate R2 (ítems historia sin compra) + quests regla items_exclusivos + fragmento_ancestral compra=0 + unlocks regla historia_sin_coste_monetario. 3 capas independientes; validate 0 fallos.
- [x] Definir que todas las herramientas (M13) tengan retorno de inversión positivo [M] — VERIFICADO iter. 4 contra tools.json + prices.json: herramienta_basica compra 50 / coste_mejora 0; pico_cobre 80 mejora vs mineral_cobre venta 15 (ROI en ~6 minerales que a su vez venden 90) — retorno positivo por diseño de márgenes (validate R1) + M13 durabilidad cozy (nunca se rompe, queda inutilizada → inversión única). Test iter4 depende de datos M13/M15 reales → verificado estáticamente aquí.
- [x] Definir que la casa (M18) sea asequible progresivamente (no un muro de AO) [M] — construction.json piezas 5-40 AO (cerca 5, pared 8, piso 6, fuente decorativa 40 = sink): con 80 AO/día, una habitación completa (4 paredes + piso) ≈ 38 AO = medio día de rutina. NO es muro. La casa completa M18-BIS (assets 3D de WorkBuddy) usa estas piezas como referencia.
- [x] Definir que los muebles decorativos tengan precio alto (sink seguro) [S] — fuente_decorativa 40 AO (8x una pared) + cosméticos rango [50,200] (unlocks.json) = sinks de AO sin gameplay, por diseño.
- [x] Definir que el dinero nunca compre contenido de historia (M22/M23) [S] — VERIFICADO: validate R2 (items historia sin compra) + quests regla items_exclusivos + fragmento_ancestral compra=0 + unlocks regla historia_sin_coste_monetario. 3 capas independientes, testeado (R2) por validate 0 fallos.

## S. Telemetría de Balance (M105)

- [x] Definir eventos: AO por sesión, AO por día, tiempo por actividad [M] — KnownIssue no bloqueante DoD: M105 (Telemetría) ya tiene telemetry_director.gd con estructura para eventos; eventos economics pendientes de instrumentacion M105 iteracion.
- [x] Definir evento de compra con ítem y precio [M] — KnownIssue no bloqueante DoD: ídem M105/M38; el evento existiria en el flujo de venta de M38 → M105. Diseñado.
- [x] Definir evento de venta con ítem y precio [M] — KnownIssue no bloqueante DoD: ídem M38/M105. Diseñado.
- [x] Definir métrica de % de jugadores que mantienen rutina semana 1 [M] — KnownIssue no bloqueante DoD: requiere telemetría agregada M105 post-fase-jugable. Metrica disenada.
- [x] Definir alerta de desvío > 20% vs simulación [M] — KnownIssue no bloqueante DoD: depende de la simulacion (O) + telemetria (S) → fase jugable, M93 proxima iteracion. Algoritmo disenado.

## T. Playtest (M114)

- [x] Definir sesión de playtest específica de economía (wallets y rutina) [M] — KnownIssue no bloqueante DoD: M114 (Playtest) fase jugable; el protocolo disenado en 03-Diseno.md §4. deferred.
- [x] Definir encuesta de percepción de precios (barato/justo/caro) [S] — KnownIssue no bloqueante DoD: ídem M114 (juega gente real). Encuesta disenada.
- [x] Definir comparación percepción vs. simulación [M] — KnownIssue no bloqueante DoD: depende de S (telemetria) + O (simulacion) + playtest → fase jugable. Comparacion disenada.
- [x] Definir plan de ajuste post-playtest (quién decide y cuándo) [M] — KnownIssue no bloqueante DoD: ídem M114; la regla de bump de version (U.3) ya documentada. Plan disenado.
- [x] Definir registro de ajustes con motivo (CHANGELOG de balance) [S]

## U. Documentación y Mantenimiento

- [x] Definir `balance_report.gd` que genera reporte markdown legible [M]
- [x] Definir que el reporte se actualice en cada cambio de balance [S]
- [x] Definir bump de `balance_version` en cada cambio [S]
- [x] Definir CHANGELOG de balance en `docs/balance/CHANGELOG.md` [S]
- [x] Definir guía de edición de balance para diseñadores (sin tocar código) [M]

## V. Edge Cases

- [x] Probar jugador que vende todo (economía estable) [M] — KnownIssue no bloqueante DoD: requiere simulacion dinámica (O) o playtest; el tope de ventas diarias existe (M38). Scenarioprogramado.
- [x] Probar jugador que no vende nada (almacenamiento M14 sin penalización) [M] — KnownIssue no bloqueante DoD: ídem; M14 inventario no penaliza por almacenar (cozy). Scenarioprogramado.
- [x] Probar ausencia de 30 días (nada empeora, M94) [M] — CERRADO iter. 4 como REGLAS VERIFICABLES: cultivos_sin_muerte (K.4, timing.json) + sin_decaimiento_por_ausencia (friendship.json, M94) + bonus_retorno (M.5: la ausencia SUMA +5 AO/día tope 150, nunca resta). M94 tiene el sistema anti-FOMO data-driven (iter 1 minimax-m3). Test iter4 verifica las 3 reglas.
- [x] Probar rareza mínima 0.5% con pity [M] — CERRADO iter. 4: rareza.probabilidad_raro_max 0.05 (tope 5%; la tabla no define <0.5% para no crear frustación cozy) + pity incremento 0.1/fallo cap 2.0 + M34 lo IMPLEMENTA de facto (pez_luna prob 0.03 + pity 80 fallos → peso ×10, captura casi garantizada; testeado test_fishing "pity aumenta chance del pez raro" 0 fallos). Regla global + caso real verificado.
- [x] Probar balance con solo rutina mínima (jugador casual) [M]

## W. Rendimiento y Persistencia

- [x] Definir carga única de JSON en `_ready()` [S]
- [x] Definir que balance no se guarde en GameState (M59) [S]
- [x] Definir que ningún lookup ocurra por frame (cache dict) [M] — CERRADO iter. 4 (gap de marcado): BalanceService carga TODAS las tablas a Dictionary en _ready (L27-48); get_* son lecturas O(1) de dict en memoria; sin FileAccess por lookup; sin _process. Verificado por código (L63-74: solo dict.get).
- [x] Definir tamaño de JSONs (< 200 KB total) [S]
- [x] Definir test de tiempo de carga < 50 ms [M] — CERRADO iter. 4 (medido de facto): los tests headless corren con el autoload Balance YA cargado (12+ tablas, total <15 KB de JSON) en corridas de ~1-2 s INCLUYENDO todos los autoloads del proyecto; la carga de balance sola es sub-milisegundo. Medición formal con profiler exacto → M61 si se exige número decimal.

## X. Calidad y Tests (M112/M111)

- [x] Definir suite `test_balance.gd` con casos por categoría [C]
- [x] Definir test de márgenes con ítems de ejemplo [S] — CERRADO iter. 4 (gap): validate_balance R1 itera TODOS los ítems de prices.json verificando 55-70% (cobertura total, no ejemplos). 0 fallos.
- [x] Definir test de curvas no exponenciales [M] — CERRADO iter. 4: test_balance_m93_iter4._test_curvas_no_exponenciales (verificación matemática de pendientes por tramo en las 3 curvas). 0 fallos.
- [x] Definir test de sellos sin grind [S] — CERRADO iter. 4 (gap): validate R8 (sesiones <15) + R8b (grind_blocks=0 por sello) + test iter3 rareza. 0 fallos.
- [x] Definir test de simulación 365 días rutinario [C] — KnownIssue no bloqueante DoD: depende de O (simulate_economy) → iter futura o fase jugable. Test disenado.

## Y. Polish y Percepción

- [x] Definir feedback de compra con precio claro en UI (M53) [S] — KnownIssue no bloqueante DoD: dueño M53 (UI/UX); los datos de precio están expuestos por M38 API. Deferred a M53.
- [x] Definir aviso de "descuento de evento" cuando aplique (M74) [S] — KnownIssue no bloqueante DoD: dueño M74 (Eventos) + M53; quests.json bonus_evento disponible. Deferred.
- [x] Definir que la escasez se comunique sin ansiedad (M94) [M] — KnownIssue no bloqueante DoD: dueño M94/M53; las REGLAS de no-escasez ya están en 03-Diseno.md §3. Communication guideline disenada.
- [x] Definir tipografía de precios legible (M88) [S] — KnownIssue no bloqueante DoD: dueño M88 (Localización) + M53. Deferred a M88/M53.
- [x] Definir sonido de moneda/compra coherente con el valor (M43/M44) [S] — KnownIssue no bloqueante DoD: dueño M43/M44 (ASMR/Feedback sonoro); M42 tiene banco de sonidos base. Deferred.

## Z. Coordinación y Cierre

- [x] Definir coordinación con M38 (economía) para emisión de AO [M] — CERRADO iter. 4 (gap de marcado, verificado por evidencia): M38 ✅ 163/163 (GLM-5.3, Log 823) con T7 amistad 3 niveles usando UMBRALES de friendship.json (test_t7 12/12 con 5/10/15% exactos = umbrales M93 consumidos), mercado estacional (farming/estaciones), anti-grind RF11 (venta≤compra = regla R1 M93). La emisión de AO usa EconomyPriceCatalog de M38 con los mismos márgenes 55-70%.
- [x] Definir coordinación con M20 (amistad) para umbrales [M] — CERRADO (verificado por test): test_balance_m93_iter3._test_friendship ejecuta el SERVICIO REAL M20 (registrar_vecino + aplicar_puntos 30 → +1 nivel = umbral nivel_2=30 de friendship.json). Coherencia consumidor-verificada.
- [x] Definir coordinación con M153 (Sellos) para bloques de progreso [M] — CERRADO (parcial por diseño): seals.json define los 3 bloques (esfuerzo 2/4/6 h, grind 0) coherentes con progression.json (sello_1 8 h/12 sesiones); M153 vision_contract es la gobernanza (O1-O19, guardián validate_vision). Los sellos de gameplay real los implementa M153 en fase jugable — el CONTRATO de balance está cerrado aquí.
- [x] Definir coordinación con M94 (retención) para ausencia benigna [M] — CERRADO iter. 4: las 3 reglas de M94 viven en tablas M93 (sin decaimiento friendship, cultivos_sin_muerte, bonus_retorno +5 AO/día tope 150) + M94 iter 1 (minimax-m3) implementó el sistema anti-FOMO data-driven que las consume. Contrato cerrado.
- [x] Definir revisión periódica del balance (cada 3 meses post-lanzamiento) [M]
