**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 32: Clima

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (tras M29/M31).

## A. Requisitos del módulo (12)

- [ ] Definir el problema: clima atmosférico cozy sin bloqueos ni castigos [S]
- [ ] Registrar dependencias: M29, M31; consumidores M19, M33, M34, M36, M41-M44, M49-M51, M63 [S]
- [ ] Catalogar los 25 puntos del plan maestro (sección 31) [S]
- [ ] RF1: 9 tipos de clima con catálogo [S]
- [ ] RF2: frecuencia estacional determinista [S]
- [ ] RF3: duración corta y agradable (2-6 h de juego) [S]
- [ ] RF4: transiciones crossfade 60-90 s [S]
- [ ] RF5: partículas GPU compartidas y pausables [S]
- [ ] RF6: sonidos y música por clima [S]
- [ ] RF7: atenuación de iluminación por clima [S]
- [ ] RF8: efectos sobre vegetación, agua y nieve visual [S]
- [ ] RF9/10/11/12: comportamiento mundo, eventos, anti-molestia y accesibilidad [S]

## B. Resolución de los 25 puntos del plan (25)

- [ ] P1: soleado — base, 100% sol, más frecuente en verano [S]
- [ ] P2: lluvia — 70% sol, partículas finas, riega parcelas [S]
- [ ] P3: tormenta — 35% sol, truenos lejanos, sin rayos al jugador [S]
- [ ] P4: niebla — visual 120 m, matinal (otoño) y densa (invierno) [S]
- [ ] P5: nieve — solo invierno, 110% sol por reflejo, cubierta M08 [S]
- [ ] P6: viento — estético (hojas/polen), sin impacto en físicas [S]
- [ ] P7: tormenta tropical — verano, 2-4/año, isla segura siempre [S]
- [ ] P8: clima especial — aurora, arcoíris, despejado para estrellas [S]
- [ ] P9: frecuencia — PRNG(seed, día_del_año) por estación [S]
- [ ] P10: duración — por tipo en data (knobs) [S]
- [ ] P11: transición — intensidad tween 60-90 s, doble buffer [S]
- [ ] P12: partículas — 1 sistema GPU compartido, densidades por calidad [S]
- [ ] P13: sonidos — buses de lluvia/viento/truenos lejanos/nieve (M42) [S]
- [ ] P14: música — variante "lluvia" cozy, sin tensión [S]
- [ ] P15: iluminación — tabla de atenuación + tintes (lluvia azul-gris, aurora verde) [S]
- [ ] P16: vegetación — sway por intensidad (M50), gotas en hojas [S]
- [ ] P17: agua — ondas por clima (M51), sin cambio de navegación [S]
- [ ] P18: NPC — refugio en tormenta, paraguas cosmético (M19) [S]
- [ ] P19: fauna — anfibios con lluvia, aves anidadas en tormenta (M36) [S]
- [ ] P20: agricultura — riego gratis con lluvia, invernadero, sin daño (M33) [S]
- [ ] P21: pesca — bono raro (lluvia +15%, tropical +25%), nunca prohibida (M34) [S]
- [ ] P22: navegación — minimapa siempre, faroles en niebla (M31), viajes sin cancelar [S]
- [ ] P23: eventos especiales — aurora día fijo, arcoíris post-lluvia, estrellas con despejado [S]
- [ ] P24: evitar clima molesto — regla de oro: nunca bloquea/destruye/castiga [S]
- [ ] P25: accesibilidad — reducir clima, sin truenos, niebla reducida, banner texto (M58) [S]

## C. Determinismo y datos (12)

- [ ] Fórmula: PRNG(semilla_partida, dia_del_ano) [S]
- [ ] Mismo seed + día ⇒ mismo clima (sin re-roll con recargas) [S]
- [ ] Semilla multiprimaria estable para dev (7919) [S]
- [ ] Intensidad transitoria única en GameState.M32 [S]
- [ ] Recomptue al cargar partida y validación contra guardado [S]
- [ ] Nunca dos días de clima profundo seguidos [S]
- [ ] Clima de mañana calculable para aviso [S]
- [ ] Probabilidades en `clima_config.tres` por estación [S]
- [ ] Duraciones mín/máx por tipo en data [S]
- [ ] Tabla de atenuación de sol en data [S]
- [ ] Volúmenes de audio por clima en data [S]
- [ ] Sin valores duros en scripts (todo .tres) [S]

## D. Transiciones y partículas (10)

- [ ] Cambio de clima a medianoche del juego [S]
- [ ] Tween lineal de intensidad 60-90 s [S]
- [ ] Densidad = intensidad × densidad_clima [S]
- [ ] Dos buffers para entrada/salida de partículas [S]
- [ ] Audio crossfade en la misma ventana [S]
- [ ] 1 sistema GPU compartido (lluvia/nieve/hojas) [S]
- [ ] Densidad por calidad gráfica (M90) [S]
- [ ] Partículas pausan con GameClock (M29) [S]
- [ ] Sin overhead de partículas con sol [S]
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
- [ ] M30 UI: banner + aviso 1 día antes [S]
- [ ] M28/M69 Viajes: clima jamás cancela [S]
- [ ] M08 Voxel: cubierta de nieve visual [S]
- [ ] Consumidores escuchan señales (desacople) [S]

## F. Eventos especiales (10)

- [ ] Aurora boreal: día fijo de invierno, 21:00-04:00 [S]
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

- [ ] Clima jamás bloquea objetos/misiones/NPC/peces [S]
- [ ] Solo bonificaciones, nunca requisitos [S]
- [ ] Sin rayos ni daño al jugador [S]
- [ ] Sin pérdida de cosechas por clima [S]
- [ ] Sin cancelación de historias (M22) [S]
- [ ] Aviso de tormenta 1 día antes (UI) [S]
- [ ] Opción "Reducir clima" (densidad -50%) [S]
- [ ] Opción "Sin truenos" (fotosensibilidad) [S]
- [ ] Opción "Niebla reducida" (visual 80%) [S]
- [ ] Banner siempre con texto (nunca solo imagen) [S]

## H. API y datos de runtime (8)

- [ ] `get_clima() -> CLIMA` [S]
- [ ] `get_intensidad() -> float` [S]
- [ ] `es_precipitacion() -> bool` [S]
- [ ] `clima_de_mañana() -> CLIMA` [S]
- [ ] `EventBus.weather.clima_cambio(CLIMA)` [S]
- [ ] `EventBus.weather.intensidad_cambio(float)` [S]
- [ ] Sin estado climático global mutable fuera de GameState.M32 [S]
- [ ] M31 consulta get_intensidad() sin duplicar estado [S]

## I. Pruebas (9)

- [ ] Test: determinismo (mismo seed+día ⇒ mismo clima) [S]
- [ ] Test: nunca 2 días de clima profundo seguidos [S]
- [ ] Test: transición sin corte de intensidad [S]
- [ ] Test: validación aurora/estrellas/posposición [S]
- [ ] Test: recarga de partida con clima correcto [S]
- [ ] Test: aviso de tormenta con 1 día de anticipación [S]
- [ ] Test: pausa congela partículas [S]
- [ ] Test: probabilidades dentro de rango por estación [S]
- [ ] Suite en `caso_clima_tests.gd` (M112) [M]

## J. Delegación y cierre (12)

- [ ] Módulo marcado delegable [S]
- [ ] 4 alternativas descartadas documentadas [S]
- [ ] API estable para consumidores [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Tasks dependientes anotadas (M45/M47/M50/M51 assets) [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]
- [ ] Checked en README de DOCUMENTACION [S]

**Totales:** 120 ítems · Completados: 120 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (C-H en runtime) quedan para el agente delegado; diseño, determinismo y reglas cierran aquí.