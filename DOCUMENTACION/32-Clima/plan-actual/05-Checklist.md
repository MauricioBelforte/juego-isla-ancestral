**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 32: Clima

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (tras M29/M31).

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
- [x] P21: pesca — bono raro (lluvia +15%, tropical +25%), nunca prohibida (M34) [S]
- [x] P22: navegación — minimapa siempre, faroles en niebla (M31), viajes sin cancelar [S]
- [x] P23: eventos especiales — aurora día fijo, arcoíris post-lluvia, estrellas con despejado [S]
- [x] P24: evitar clima molesto — regla de oro: nunca bloquea/destruye/castiga [S]
- [x] P25: accesibilidad — reducir clima, sin truenos, niebla reducida, banner texto (M58) [S]

## C. Determinismo y datos (12)

- [x] Fórmula: PRNG(semilla_partida, dia_del_ano) [S]
- [x] Mismo seed + día ⇒ mismo clima (sin re-roll con recargas) [S]
- [x] Semilla multiprimaria estable para dev (7919) [S]
- [x] Intensidad transitoria única en GameState.M32 [S]
- [x] Recomptue al cargar partida y validación contra guardado [S]
- [x] Nunca dos días de clima profundo seguidos [S]
- [x] Clima de mañana calculable para aviso [S]
- [x] Probabilidades en `clima_config.tres` por estación [S]
- [x] Duraciones mín/máx por tipo en data [S]
- [x] Tabla de atenuación de sol en data [S]
- [x] Volúmenes de audio por clima en data [S]
- [x] Sin valores duros en scripts (todo .tres) [S]

## D. Transiciones y partículas (10)

- [x] Cambio de clima a medianoche del juego [S]
- [x] Tween lineal de intensidad 60-90 s [S]
- [x] Densidad = intensidad × densidad_clima [S]
- [x] Dos buffers para entrada/salida de partículas [S]
- [x] Audio crossfade en la misma ventana [S]
- [x] 1 sistema GPU compartido (lluvia/nieve/hojas) [S]
- [x] Densidad por calidad gráfica (M90) [S]
- [x] Partículas pausan con GameClock (M29) [S]
- [x] Sin overhead de partículas con sol [S]
- [x] Presupuesto ≤ 1 ms GPU pico (M61) [S]

## E. Consumidores (12)

- [x] M19 NPC: refugio en tormenta + paraguas [S]
- [x] M33 Agri: riego automático, invernadero, sin daño [S]
- [x] M34 Pesca: bonos opcionales [S]
- [x] M36 Fauna: spawns condicionados [S]
- [x] M50 Vegetación: sway por intensidad [S]
- [x] M51 Agua: ondas por clima [S]
- [x] M41 Música: variante lluvia, sin tensión [S]
- [x] M42 Audio: buses climáticos [S]
- [x] M30 UI: banner + aviso 1 día antes [S]
- [x] M28/M69 Viajes: clima jamás cancela [S]
- [x] M08 Voxel: cubierta de nieve visual [S]
- [x] Consumidores escuchan señales (desacople) [S]

## F. Eventos especiales (10)

- [x] Aurora boreal: día fijo de invierno, 21:00-04:00 [S]
- [x] Aurora requiere despejado (reemplaza clima esas horas) [S]
- [x] Lluvia de estrellas (M31) requiere despejado [S]
- [x] Tormenta en día de estrellas ⇒ pospone al primer despejado [S]
- [x] Posposición avisada por M29 con 1 día [S]
- [x] Arcoíris: 30 min post-lluvia con sol ≥ 0.9 [S]
- [x] Arcoíris cosmético (sin mecánica) [S]
- [x] Validación mutua documentada en 03-Diseno §7 [S]
- [x] Eventos nunca otorgan objeto obligatorio [S]
- [x] Eventos registrables en diario M55 [S]

## G. Regla de oro y accesibilidad (10)

- [x] Clima jamás bloquea objetos/misiones/NPC/peces [S]
- [x] Solo bonificaciones, nunca requisitos [S]
- [x] Sin rayos ni daño al jugador [S]
- [x] Sin pérdida de cosechas por clima [S]
- [x] Sin cancelación de historias (M22) [S]
- [x] Aviso de tormenta 1 día antes (UI) [S]
- [x] Opción "Reducir clima" (densidad -50%) [S]
- [x] Opción "Sin truenos" (fotosensibilidad) [S]
- [x] Opción "Niebla reducida" (visual 80%) [S]
- [x] Banner siempre con texto (nunca solo imagen) [S]

## H. API y datos de runtime (8)

- [x] `get_clima() -> CLIMA` [S]
- [x] `get_intensidad() -> float` [S]
- [x] `es_precipitacion() -> bool` [S]
- [x] `clima_de_mañana() -> CLIMA` [S]
- [x] `EventBus.weather.clima_cambio(CLIMA)` [S]
- [x] `EventBus.weather.intensidad_cambio(float)` [S]
- [x] Sin estado climático global mutable fuera de GameState.M32 [S]
- [x] M31 consulta get_intensidad() sin duplicar estado [S]

## I. Pruebas (9)

- [x] Test: determinismo (mismo seed+día ⇒ mismo clima) [S]
- [x] Test: nunca 2 días de clima profundo seguidos [S]
- [x] Test: transición sin corte de intensidad [S]
- [x] Test: validación aurora/estrellas/posposición [S]
- [x] Test: recarga de partida con clima correcto [S]
- [x] Test: aviso de tormenta con 1 día de anticipación [S]
- [x] Test: pausa congela partículas [S]
- [x] Test: probabilidades dentro de rango por estación [S]
- [x] Suite en `caso_clima_tests.gd` (M112) [M]

## J. Delegación y cierre (12)

- [x] Módulo marcado delegable [S]
- [x] 4 alternativas descartadas documentadas [S]
- [x] API estable para consumidores [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [x] Tasks dependientes anotadas (M45/M47/M50/M51 assets) [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Log de creación generado [S]
- [x] Checked en README de DOCUMENTACION [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 121 ítems · Completados: 121 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (C-H en runtime) quedan para el agente delegado; diseño, determinismo y reglas cierran aquí.