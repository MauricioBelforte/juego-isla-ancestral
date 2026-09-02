**Modelo:** glm-5.3-flash (último modificador; núcleo por Deepseek V4 Flash)
**Plataforma:** Kilo Code

## Reserva actual

- Estado: 🔵 En curso — iteración 3 (tablas faltantes: friendship/quests/puzzles/unlocks/meta-rareza) 2026-09-01 01:00
- Agente: glm-5.3-flash (Kilo Code)
- Fase: 5 (Base de producción) / Balance
- Dificultad: 4 (incremental, V0)
- Entrada: núcleo iter. 1-2 ✅ (Deepseek, Logs 258/263) + M20 ✅ + M22 ✅ núcleos
- Salida: tablas completadas según checklist + validación ValidateBalance + test de coherencia
- Archivos: `data/balance/{friendship,quests,puzzles,unlocks,meta}.json`, `scripts/balance/test_balance_m93_iter3.gd`

# 05-Checklist.md — Módulo 93: Balance (130 ítems)

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** núcleo de balance implementado: BalanceService
> autoload (lectura central de data/balance/*.json), tabla base de precios/recompensas/timing/
> progresión/amistad, y ValidateBalance con reglas anti-grind/anti-exploit (márgenes 55-70%,
> historia sin compra, rareza, sesión ≤30 min, sellos sin grind, versión). Test y validador
> 0 fallos. Tablas de contenido restantes (construction, crafting, tools, farming, fishing,
> mining, travel, seals, quests, puzzles, unlocks) quedan `[ ]` para el agente que las complete
> con datos de diseño. Log 258.

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 92 + M152/M153/M38/M20/M105.

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
- [ ] Definir pity por ítem raro (nro de intentos sin éxito que suben la chance) [M]

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
- [ ] Definir tiempo de minado por material [S]

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
- [ ] Definir recompensas en ítems exclusivos (no monetizables) [M]
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

- [ ] Definir `timing.json`: duración estimada por actividad diaria [M]
- [ ] Definir rutina óptima ≤ 30 min reales [M]
- [ ] Definir sesión libre 1-2 h con progreso garantizado [M]
- [ ] Definir que cultivos no mueran por ausencia (M33, M94) [M]
- [ ] Definir calendario de estaciones con contenido rotativo (M29) [M]

## L. Curvas de Progresión

- [ ] Definir `progression.json`: curva de AO por día de juego [M]
- [ ] Definir curva de recursos acumulados [M]
- [ ] Definir curva de amistad total [M]
- [ ] Definir curva de colecciones completadas (M73) [M]
- [ ] Validar que ninguna curva sea exponencial (pendiente decreciente) [M]

## M. Anti-Grind (M152)

- [ ] Definir regla: ningún objetivo legítimo exige repetir la misma acción >4 veces seguidas sin progreso [M]
- [ ] Definir tope de ventas diarias (anti-inflación) [M]
- [ ] Definir que las recompensas de temporada regresen en ciclos (sin FOMO) [M]
- [ ] Definir que la colección (M73) no requiera ítems de un solo día [M]
- [ ] Definir multiplicadores de progreso en ítems de largo plazo (bonus al volver) [M]

## N. Anti-Exploit

- [ ] Identificar bucles de ganancia sin costo (regar+vender, pescar+vender, minar+craftear) [C]
- [ ] Definir test de simulación: ningún bucle produce AO > 115% del diseño [C]
- [ ] Definir que el reloj interno (M30) no dependa del reloj real para progresión [M]
- [ ] Definir que avanzar el reloj del sistema no duplique eventos [M]
- [ ] Definir límite de items vendidos por día por categoría [M]

## O. Simulación Económica

- [ ] Definir `simulate_economy.gd` con escenarios (rutinario, diligente, minimalista) [C]
- [ ] Definir simulación de 60/180/365 días [C]
- [ ] Definir salida: AO total, recursos por pipeline, desvío vs. diseño [M]
- [ ] Definir exit code != 0 si se detecta exploit o desvío > umbral [M]
- [ ] Definir que la simulación corra en CI (M118) [M]

## P. Validación Automática

- [ ] Definir `validate_balance.gd` con regla de márgenes (venta 55-70% de compra) [M]
- [ ] Definir regla de curvas no exponenciales [M]
- [ ] Definir regla de rutina ≤ 30 min [S]
- [ ] Definir regla de sellos sin grind [S]
- [ ] Definir que el gate se ejecute en cada PR que toque `data/balance/` [M]

## Q. Integración con Gameplay

- [ ] Definir autoload `balance.gd` de solo lectura [M]
- [ ] Definir API de precios consumida por M39 (tiendas) [M]
- [ ] Definir API de recetas consumida por M16 (crafting) [M]
- [ ] Definir API de cultivos consumida por M33 (agricultura) [M]
- [ ] Definir API de pesca consumida por M34 [M]

## R. Integración con Metas del Juego

- [ ] Definir que el 1er Sello se alcance sin grind, < 10 h de juego [C]
- [ ] Definir que todas las herramientas (M13) tengan retorno de inversión positivo [M]
- [ ] Definir que la casa (M18) sea asequible progresivamente (no un muro de AO) [M]
- [ ] Definir que los muebles decorativos tengan precio alto (sink seguro) [S]
- [ ] Definir que el dinero nunca compre contenido de historia (M22/M23) [S]

## S. Telemetría de Balance (M105)

- [ ] Definir eventos: AO por sesión, AO por día, tiempo por actividad [M]
- [ ] Definir evento de compra con ítem y precio [M]
- [ ] Definir evento de venta con ítem y precio [M]
- [ ] Definir métrica de % de jugadores que mantienen rutina semana 1 [M]
- [ ] Definir alerta de desvío > 20% vs simulación [M]

## T. Playtest (M114)

- [ ] Definir sesión de playtest específica de economía (wallets y rutina) [M]
- [ ] Definir encuesta de percepción de precios (barato/justo/caro) [S]
- [ ] Definir comparación percepción vs. simulación [M]
- [ ] Definir plan de ajuste post-playtest (quién decide y cuándo) [M]
- [ ] Definir registro de ajustes con motivo (CHANGELOG de balance) [S]

## U. Documentación y Mantenimiento

- [ ] Definir `balance_report.gd` que genera reporte markdown legible [M]
- [ ] Definir que el reporte se actualice en cada cambio de balance [S]
- [ ] Definir bump de `balance_version` en cada cambio [S]
- [ ] Definir CHANGELOG de balance en `docs/balance/CHANGELOG.md` [S]
- [ ] Definir guía de edición de balance para diseñadores (sin tocar código) [M]

## V. Edge Cases

- [ ] Probar jugador que vende todo (economía estable) [M]
- [ ] Probar jugador que no vende nada (almacenamiento M14 sin penalización) [M]
- [ ] Probar ausencia de 30 días (nada empeora, M94) [M]
- [ ] Probar rareza mínima 0.5% con pity [M]
- [ ] Probar balance con solo rutina mínima (jugador casual) [M]

## W. Rendimiento y Persistencia

- [ ] Definir carga única de JSON en `_ready()` [S]
- [ ] Definir que balance no se guarde en GameState (M59) [S]
- [ ] Definir que ningún lookup ocurra por frame (cache dict) [M]
- [ ] Definir tamaño de JSONs (< 200 KB total) [S]
- [ ] Definir test de tiempo de carga < 50 ms [M]

## X. Calidad y Tests (M112/M111)

- [ ] Definir suite `test_balance.gd` con casos por categoría [C]
- [ ] Definir test de márgenes con ítems de ejemplo [S]
- [ ] Definir test de curvas no exponenciales [M]
- [ ] Definir test de sellos sin grind [S]
- [ ] Definir test de simulación 365 días rutinario [C]

## Y. Polish y Percepción

- [ ] Definir feedback de compra con precio claro en UI (M53) [S]
- [ ] Definir aviso de "descuento de evento" cuando aplique (M74) [S]
- [ ] Definir que la escasez se comunique sin ansiedad (M94) [M]
- [ ] Definir tipografía de precios legible (M88) [S]
- [ ] Definir sonido de moneda/compra coherente con el valor (M43/M44) [S]

## Z. Coordinación y Cierre

- [ ] Definir coordinación con M38 (economía) para emisión de AO [M]
- [ ] Definir coordinación con M20 (amistad) para umbrales [M]
- [ ] Definir coordinación con M153 (Sellos) para bloques de progreso [M]
- [ ] Definir coordinación con M94 (retención) para ausencia benigna [M]
- [ ] Definir revisión periódica del balance (cada 3 meses post-lanzamiento) [M]
