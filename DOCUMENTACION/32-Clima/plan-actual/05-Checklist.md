**Modelo:** glm-5.3-flash (último modificador; relevamiento iter. 1)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 32: Clima

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (tras M29/M31).

> **Reserva actual (LIBERADA 🟡)**
> **Agente:** glm-5.3-flash · **Plataforma:** Kilo Code · **Fecha:** 2026-08-31 23:50 · **Estado:** 🟡 Liberado (iter. 1 núcleo determinista verificado, Log 306)
> **Entrada:** M29 ✅ + M31 núcleo runtime cerrado · **Salida:** WeatherService autoload determinista + clima_config data-driven + EventBus.weather + persistencia M59 + test headless 0 fallos
> **Archivos afectados:** `scripts/clima/`, `data/clima/`, `scripts/core/event_bus.gd`, `project.godot`, `scripts/dialogos/world_state_service.gd` (integración M21)

## A. Requisitos del módulo (12)

- [x] Definir el problema: clima atmosférico cozy sin bloqueos ni castigos [S]
- [x] Registrar dependencias: M29, M31; consumidores M19, M33, M34, M36, M41-M44, M49-M51, M63 [S]
- [x] Catalogar los 25 puntos del plan maestro (sección 31) [S]
- [x] RF1: 9 tipos de clima con catálogo [S]
- [x] RF2: frecuencia estacional determinista [S]
- [x] RF3: duración corta y agradable (2-6 h de juego) [S]
- [x] RF4: transiciones crossfade 60-90 s [S]
- [x] RF5: partículas GPU compartidas y pausables [S]
- [x] RF6: sonidos y música por clima [S]
- [x] RF7: atenuación de iluminación por clima [S]
- [x] RF8: efectos sobre vegetación, agua y nieve visual [S]
- [x] RF9/10/11/12: comportamiento mundo, eventos, anti-molestia y accesibilidad [S]

## B. Resolución de los 25 puntos del plan (25)

- [x] P1: soleado — base, 100% sol, más frecuente en verano [S]
- [x] P2: lluvia — 70% sol, partículas finas, riega parcelas [S]
- [x] P3: tormenta — 35% sol, truenos lejanos, sin rayos al jugador [S]
- [x] P4: niebla — visual 120 m, matinal (otoño) y densa (invierno) [S]
- [x] P5: nieve — solo invierno, 110% sol por reflejo, cubierta M08 [S]
- [x] P6: viento — estético (hojas/polen), sin impacto en físicas [S]
- [x] P7: tormenta tropical — verano, 2-4/año, isla segura siempre [S]
- [x] P8: clima especial — aurora, arcoíris, despejado para estrellas [S]
- [x] P9: frecuencia — PRNG(seed, día_del_año) por estación [S]
- [x] P10: duración — por tipo en data (knobs) [S]
- [x] P11: transición — intensidad tween 60-90 s, doble buffer [S]
- [x] P12: partículas — 1 sistema GPU compartido, densidades por calidad [S]
- [x] P13: sonidos — buses de lluvia/viento/truenos lejanos/nieve (M42) [S]
- [x] P14: música — variante "lluvia" cozy, sin tensión [S]
- [x] P15: iluminación — tabla de atenuación + tintes (lluvia azul-gris, aurora verde) [S]
- [x] P16: vegetación — sway por intensidad (M50), gotas en hojas [S]
- [x] P17: agua — ondas por clima (M51), sin cambio de navegación [S]
- [x] P18: NPC — refugio en tormenta, paraguas cosmético (M19) [S]
- [x] P19: fauna — anfibios con lluvia, aves anidadas en tormenta (M36) [S]
- [x] P20: agricultura — riego gratis con lluvia, invernadero, sin daño (M33) [S]
- [x] P21: pesca — bonos opcionales (lluvia +15%, tropical +25%), nunca prohibida (M34) [S]
- [x] P22: navegación — minimapa siempre, faroles en niebla (M31), viajes sin cancelar [S]
- [x] P23: eventos especiales — aurora día fijo, arcoíris post-lluvia, estrellas con despejado [S]
- [x] P24: evitar clima molesto — regla de oro: nunca bloquea/destruye/castiga [S]
- [x] P25: accesibilidad — reducir clima, sin truenos, niebla reducida, banner texto (M58) [S]

## C. Determinismo y datos (12)

- [x] Fórmula: PRNG(semilla_partida, dia_del_ano) — implementada como cadena cacheada `clima_de_dia(dia_absoluto)` (día monótono de M30) [S]
- [x] Mismo seed + día ⇒ mismo clima (sin re-roll con recargas) — probado en test [S]
- [x] Semilla multiprimaria estable para dev (7919) [S]
- [x] Intensidad transitoria única en GameState.M32 — **nota:** GameState no existe en el proyecto; el estado vive SOLO en el autoload `Weather` (único dueño, equivalente funcional) [S]
- [x] Recomptue al cargar partida y validación contra guardado — `restore_save_data` gana el recomputado (warning si difieren) [S]
- [x] Nunca dos días de clima profundo seguidos — fallback SOLEADO, probado en 1008 días [S]
- [x] Clima de mañana calculable para aviso — `clima_de_manana()` determinista [S]
- [x] Probabilidades en `clima_config.tres` por estación — ruta real `data/clima/clima_config.tres` [S]
- [x] Duraciones mín/máx por tipo en data [S]
- [x] Tabla de atenuación de sol en data [S]
- [x] Volúmenes de audio por clima en data [S]
- [x] Sin valores duros en scripts (todo .tres) [S]

## D. Transiciones y partículas (10)

- [x] Cambio de clima a medianoche del juego [S]
- [x] Tween lineal de intensidad 60-90 s — rampa por minutos de juego conectada a `GameTime.minuto_cambio` (sin `_process` propio) [S]
- [ ] Densidad = intensidad × densidad_clima — API expuesta (`get_intensidad`); partículas con dueño M52 (V2) [S]
- [ ] Dos buffers para entrada/salida de partículas — dueño M52 [S]
- [ ] Audio crossfade en la misma ventana — volumen interpolado expuesto (`get_volumen_audio`); buses con dueño M42 [S]
- [ ] 1 sistema GPU compartido (lluvia/nieve/hojas) — dueño M52 [S]
- [ ] Densidad por calidad gráfica (M90) [S]
- [ ] Partículas pausan con GameClock (M29) — la transición ya se congela con el reloj; partículas con dueño M52 [S]
- [ ] Sin overhead de partículas con sol — dueño M52/M61 [S]
- [ ] Presupuesto ≤ 1 ms GPU pico (M61) [S]

## E. Consumidores (12)

- [ ] M19 NPC: refugio en tormenta + paraguas [S]
- [ ] M33 Agri: riego automático, invernadero, sin daño [S]
- [ ] M34 Pesca: bonos opcionales [S]
- [ ] M36 Fauna: spawns condicionados [S]
- [ ] M50 Vegetación: sway por intensidad [S]
- [ ] M51 Agua: ondas por clima [S]
- [ ] M41 Música: variante lluvia, sin tensión [S]
- [ ] M42 Audio: buses climáticos [S]
- [ ] M30 UI: banner + aviso 1 día antes — `clima_de_manana()` listo [S]
- [ ] M28/M69 Viajes: clima jamás cancela [S]
- [ ] M08 Voxel: cubierta de nieve visual [S]
- [x] Consumidores escuchan señales (desacople) — `EventBus.weather.clima_cambio`/`intensidad_cambio` publicadas; M21 ya consume vía `WorldState.get_value("clima")` [S]

## F. Eventos especiales (10)

- [ ] Aurora boreal: día fijo de invierno, 21:00-04:00 — requiere M29 festivals [S]
- [ ] Aurora requiere despejado (reemplaza clima esas horas) [S]
- [ ] Lluvia de estrellas (M31) requiere despejado [S]
- [ ] Tormenta en día de estrellas ⇒ pospone al primer despejado [S]
- [ ] Posposición avisada por M29 con 1 día [S]
- [ ] Arcoíris: 30 min post-lluvia con sol ≥ 0.9 [S]
- [ ] Arcoíris cosmético (sin mecánica) [S]
- [ ] Validación mutua documentada en 03-Diseno §7 [S]
- [ ] Eventos nunca otorgan objeto obligatorio [S]
- [ ] Eventos registrables en diario M55 [S]

## G. Regla de oro y accesibilidad (10)

- [x] Clima jamás bloquea objetos/misiones/NPC/peces — garantizado por construcción del núcleo (sin mecánicas de bloqueo) [S]
- [x] Solo bonificaciones, nunca requisitos [S]
- [x] Sin rayos ni daño al jugador [S]
- [x] Sin pérdida de cosechas por clima — M33 ya tiene pausas cozy; el clima no aplica daño [S]
- [x] Sin cancelación de historias (M22) — nada consulta el clima para bloquear [S]
- [ ] Aviso de tormenta 1 día antes (UI) — dato listo, UI con dueño M30/M53 [S]
- [ ] Opción "Reducir clima" (densidad -50%) — dueño M58 [S]
- [ ] Opción "Sin truenos" (fotosensibilidad) — dueño M58 [S]
- [ ] Opción "Niebla reducida" (visual 80%) — dueño M58 [S]
- [ ] Banner siempre con texto (nunca solo imagen) — dueño M30 [S]

## H. API y datos de runtime (8)

- [x] `get_clima() -> CLIMA` [S]
- [x] `get_intensidad() -> float` [S]
- [x] `es_precipitacion() -> bool` [S]
- [x] `clima_de_mañana() -> CLIMA` — implementado como `clima_de_manana()` (identificador sin ñ) [S]
- [x] `EventBus.weather.clima_cambio(CLIMA)` [S]
- [x] `EventBus.weather.intensidad_cambio(float)` [S]
- [x] Sin estado climático global mutable fuera de GameState.M32 — único dueño: autoload `Weather` (nota en C) [S]
- [ ] M31 consulta get_intensidad() sin duplicar estado — API lista (`get_atenuacion_sol()`); cableado con dueño M31/M49 [S]

## I. Pruebas (9)

- [x] Test: determinismo (mismo seed+día ⇒ mismo clima) [S]
- [x] Test: nunca 2 días de clima profundo seguidos — 1008 días simulados [S]
- [x] Test: transición sin corte de intensidad — monotonía verificada [S]
- [ ] Test: validación aurora/estrellas/posposición — requiere F [S]
- [x] Test: recarga de partida con clima correcto — "gana el recomputado" [S]
- [ ] Test: aviso de tormenta con 1 día de anticipación — requiere UI M30 [S]
- [ ] Test: pausa congela partículas — requiere partículas M52 [S]
- [x] Test: probabilidades dentro de rango por estación — suma 1.0 por estación [S]
- [x] Suite en `caso_clima_tests.gd` (M112) — **nota:** implementada como `scripts/clima/test_clima.gd` (patrón headless del proyecto, 0 fallos); suite GdUnit4 formal con dueño M112 [M]

## J. Delegación y cierre (12)

- [x] Módulo marcado delegable [S]
- [x] 4 alternativas descartadas documentadas — 02-Analisis §3 [S]
- [x] API estable para consumidores [S]
- [x] Implementación → AGENTE DELEGADO — iter. 1 por glm-5.3-flash (Kilo Code) [S]
- [x] Tasks dependientes anotadas (M45/M47/M50/M51 assets) — ver pendientes con dueño en 04-Codigo §0 [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) — re-firmado en iter. 1 [S]
- [x] 05-Checklist creado y firmado (este archivo) — relevado en iter. 1 [S]
- [x] Log de creación generado — Log 306 (iter. 1, glm-5.3-flash) [S]
- [x] Checked en README de DOCUMENTACION [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 121 ítems · Completados: 82 · Pendientes: 39 · No resueltos: 0.
**Nota iter. 1 (glm-5.3-flash, 2026-08-31):** A/B cerrados por documentación existente (Deepseek); C/H completos; D/E/F/G/I pendientes CON DUEÑO (M52/M42/M30/M31/M49/M58/M112/M29, mayoría V2). Núcleo determinista verificado: test headless 0 fallos + regresiones M29/M31/M21 OK + boot runtime OK (godot-mcp, Godot 4.7.2).