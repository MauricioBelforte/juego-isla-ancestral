**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 93: Balance (130 ítems)

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
- [x] Definir rareza base tope 5% para ítems raros [S]
- [x] Definir pity por ítem raro (nro de intentos sin éxito que suben la chance) [M]

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
- [x] Definir límite de nodos activos por chunk (rendimiento M61) [M]
- [x] Definir tiempo de minado por material [S]

## E. Viajes y Transporte

- [x] Definir `travel.json`: coste y duración por ruta entre islas (M28) [M]
- [x] Definir tarifas del Gran Vapor según isla y temporada [M]
- [x] Definir tiempo real por viaje (máx 3 min reales) [S]
- [x] Definir que el viaje nunca exija grind previo (M152) [S]
- [x] Definir recompensas por descubrir rutas nuevas [S]

## F. Sellos (M153)

- [x] Definir `seals.json`: un bloque de progreso por Sello [M]
- [x] Definir condición de cada Sello como contenido curado, no repetitivo [C]
- [x] Definir esfuerzo estimado por Sello en bloques de juego (ej. 3-6 h) [M]
- [x] Definir recompensa de cada Sello (desbloqueos M71, cosméticos) [M]
- [x] Validar que ningún Sello requiera grind (grind_blocks = 0) [M]

## G. Amistad (M20)

- [x] Definir `friendship.json`: puntos por regalo, favorito, diálogo [M]
- [x] Definir umbrales de nivel de amistad (ej. 0/30/70/130) [M]
- [x] Definir beneficios por nivel (recetas, descuentos, eventos) [M]
- [x] Definir que no haya decaimiento por ausencia (M94) [M]
- [x] Definir generosidad: regalos favoritos +x3 puntos [S]

## H. Misiones (M22/M23)

- [x] Definir `quests.json`: recompensa por misión principal [M]
- [x] Definir recompensa por misión secundaria entre 5-15% del siguiente desbloqueo [M]
- [x] Definir recompensas en ítems exclusivos (no monetizables) [M]
- [x] Definir que misiones no se rompan por balance (siempre completables) [M]
- [x] Definir recompensas de eventos (M74) como bonus de temporada [S]

## I. Puzzles y Templos (M24/M26)

- [x] Definir `puzzles.json`: tiempo estimado de resolución por puzzle [M]
- [x] Definir tiempo máx 20 min con ayuda (M58) / 45 min sin ayuda [M]
- [x] Definir recompensa de templo (herramienta única, M13/M26) [C]
- [x] Definir que todo puzzle sea resoluble con herramientas del momento [M]
- [x] Definir recompensa de ruinas (M25) en fragmentos y lore [M]

## J. Desbloqueos (M71)

- [x] Definir `unlocks.json`: coste y condición por desbloqueo [M]
- [x] Definir orden de desbloqueos en función de progresión [M]
- [x] Definir que desbloqueos de historia no tengan coste monetario [S]
- [x] Definir desbloqueos cosméticos como sinks de AO [M]
- [x] Definir récords de museo (M37) como desbloqueo no monetario [S]

## K. Tiempo y Rutina Diaria

- [x] Definir `timing.json`: duración estimada por actividad diaria [M]
- [x] Definir rutina óptima ≤ 30 min reales [M]
- [x] Definir sesión libre 1-2 h con progreso garantizado [M]
- [x] Definir que cultivos no mueran por ausencia (M33, M94) [M]
- [x] Definir calendario de estaciones con contenido rotativo (M29) [M]

## L. Curvas de Progresión

- [x] Definir `progression.json`: curva de AO por día de juego [M]
- [x] Definir curva de recursos acumulados [M]
- [x] Definir curva de amistad total [M]
- [x] Definir curva de colecciones completadas (M73) [M]
- [x] Validar que ninguna curva sea exponencial (pendiente decreciente) [M]

## M. Anti-Grind (M152)

- [x] Definir regla: ningún objetivo legítimo exige repetir la misma acción >4 veces seguidas sin progreso [M]
- [x] Definir tope de ventas diarias (anti-inflación) [M]
- [x] Definir que las recompensas de temporada regresen en ciclos (sin FOMO) [M]
- [x] Definir que la colección (M73) no requiera ítems de un solo día [M]
- [x] Definir multiplicadores de progreso en ítems de largo plazo (bonus al volver) [M]

## N. Anti-Exploit

- [x] Identificar bucles de ganancia sin costo (regar+vender, pescar+vender, minar+craftear) [C]
- [x] Definir test de simulación: ningún bucle produce AO > 115% del diseño [C]
- [x] Definir que el reloj interno (M30) no dependa del reloj real para progresión [M]
- [x] Definir que avanzar el reloj del sistema no duplique eventos [M]
- [x] Definir límite de items vendidos por día por categoría [M]

## O. Simulación Económica

- [x] Definir `simulate_economy.gd` con escenarios (rutinario, diligente, minimalista) [C]
- [x] Definir simulación de 60/180/365 días [C]
- [x] Definir salida: AO total, recursos por pipeline, desvío vs. diseño [M]
- [x] Definir exit code != 0 si se detecta exploit o desvío > umbral [M]
- [x] Definir que la simulación corra en CI (M118) [M]

## P. Validación Automática

- [x] Definir `validate_balance.gd` con regla de márgenes (venta 55-70% de compra) [M]
- [x] Definir regla de curvas no exponenciales [M]
- [x] Definir regla de rutina ≤ 30 min [S]
- [x] Definir regla de sellos sin grind [S]
- [x] Definir que el gate se ejecute en cada PR que toque `data/balance/` [M]

## Q. Integración con Gameplay

- [x] Definir autoload `balance.gd` de solo lectura [M]
- [x] Definir API de precios consumida por M39 (tiendas) [M]
- [x] Definir API de recetas consumida por M16 (crafting) [M]
- [x] Definir API de cultivos consumida por M33 (agricultura) [M]
- [x] Definir API de pesca consumida por M34 [M]

## R. Integración con Metas del Juego

- [x] Definir que el 1er Sello se alcance sin grind, < 10 h de juego [C]
- [x] Definir que todas las herramientas (M13) tengan retorno de inversión positivo [M]
- [x] Definir que la casa (M18) sea asequible progresivamente (no un muro de AO) [M]
- [x] Definir que los muebles decorativos tengan precio alto (sink seguro) [S]
- [x] Definir que el dinero nunca compre contenido de historia (M22/M23) [S]

## S. Telemetría de Balance (M105)

- [x] Definir eventos: AO por sesión, AO por día, tiempo por actividad [M]
- [x] Definir evento de compra con ítem y precio [M]
- [x] Definir evento de venta con ítem y precio [M]
- [x] Definir métrica de % de jugadores que mantienen rutina semana 1 [M]
- [x] Definir alerta de desvío > 20% vs simulación [M]

## T. Playtest (M114)

- [x] Definir sesión de playtest específica de economía (wallets y rutina) [M]
- [x] Definir encuesta de percepción de precios (barato/justo/caro) [S]
- [x] Definir comparación percepción vs. simulación [M]
- [x] Definir plan de ajuste post-playtest (quién decide y cuándo) [M]
- [x] Definir registro de ajustes con motivo (CHANGELOG de balance) [S]

## U. Documentación y Mantenimiento

- [x] Definir `balance_report.gd` que genera reporte markdown legible [M]
- [x] Definir que el reporte se actualice en cada cambio de balance [S]
- [x] Definir bump de `balance_version` en cada cambio [S]
- [x] Definir CHANGELOG de balance en `docs/balance/CHANGELOG.md` [S]
- [x] Definir guía de edición de balance para diseñadores (sin tocar código) [M]

## V. Edge Cases

- [x] Probar jugador que vende todo (economía estable) [M]
- [x] Probar jugador que no vende nada (almacenamiento M14 sin penalización) [M]
- [x] Probar ausencia de 30 días (nada empeora, M94) [M]
- [x] Probar rareza mínima 0.5% con pity [M]
- [x] Probar balance con solo rutina mínima (jugador casual) [M]

## W. Rendimiento y Persistencia

- [x] Definir carga única de JSON en `_ready()` [S]
- [x] Definir que balance no se guarde en GameState (M59) [S]
- [x] Definir que ningún lookup ocurra por frame (cache dict) [M]
- [x] Definir tamaño de JSONs (< 200 KB total) [S]
- [x] Definir test de tiempo de carga < 50 ms [M]

## X. Calidad y Tests (M112/M111)

- [x] Definir suite `test_balance.gd` con casos por categoría [C]
- [x] Definir test de márgenes con ítems de ejemplo [S]
- [x] Definir test de curvas no exponenciales [M]
- [x] Definir test de sellos sin grind [S]
- [x] Definir test de simulación 365 días rutinario [C]

## Y. Polish y Percepción

- [x] Definir feedback de compra con precio claro en UI (M53) [S]
- [x] Definir aviso de "descuento de evento" cuando aplique (M74) [S]
- [x] Definir que la escasez se comunique sin ansiedad (M94) [M]
- [x] Definir tipografía de precios legible (M88) [S]
- [x] Definir sonido de moneda/compra coherente con el valor (M43/M44) [S]

## Z. Coordinación y Cierre

- [x] Definir coordinación con M38 (economía) para emisión de AO [M]
- [x] Definir coordinación con M20 (amistad) para umbrales [M]
- [x] Definir coordinación con M153 (Sellos) para bloques de progreso [M]
- [x] Definir coordinación con M94 (retención) para ausencia benigna [M]
- [x] Definir revisión periódica del balance (cada 3 meses post-lanzamiento) [M]