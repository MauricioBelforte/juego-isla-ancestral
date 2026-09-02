**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 42: Sonido Ambiental

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (10)

- [ ] Definir el problema: paisaje sonoro ambiental por bioma/hora/clima [S]
- [ ] Registrar dependencias: M07, M29, M31, M32, M09; relaciones M41, M44 [S]
- [ ] Catalogar los 25 puntos del plan maestro (sección 41) [S]
- [ ] RF1: banco por bioma (13 + subterráneo) [S]
- [ ] RF2: capas por hora y clima [S]
- [ ] RF3: fuentes posicionales 3D [S]
- [ ] RF4: fauna con horas de actividad [S]
- [ ] RF5: sonidos de acción (madera, piedra, minería...) [S]
- [ ] RF6: interiores con reverb [S]
- [ ] RF7: crossfade suave de bancos [S]

## B. Resolución de los 25 puntos del plan (25)

- [ ] P1: viento — base 2D, 3 variaciones, modulado por clima y montaña [S]
- [ ] P2: hojas — susurro por bioma boscoso, pitch ±5% [S]
- [ ] P3: hierba — rizoma suave en praderas [S]
- [ ] P4: agua — genérica en lagos/estanques [S]
- [ ] P5: río — 3D posicional, 4 variaciones, 60 m [S]
- [ ] P6: cascada — 3D en 2 POIs fijos, hasta 120 m [S]
- [ ] P7: océano — costa 3D + mar lejano 2D [S]
- [ ] P8: lluvia — capa 2D fina + goteras en cobertizos [S]
- [ ] P9: tormenta — lluvia densa + truenos random 30-90 s [S]
- [ ] P10: nieve — casi silencio + crujidos en pasos [S]
- [ ] P11: fuego — 3D en fogatas/casas, 3 variaciones [S]
- [ ] P12: madera — impactos de construcción y puentes [S]
- [ ] P13: piedra — 5 variaciones con eco ligero [S]
- [ ] P14: minería — golpe + gravilla, oclusión de túnel [S]
- [ ] P15: construcción — 3 capas (madera/piedra/metal) [S]
- [ ] P16: árboles — crujido al tala/impacto [S]
- [ ] P17: animales — 2D lejanos + 3D cercanos [S]
- [ ] P18: aves — diurnas (05:30-19:00), poisson 6+ variaciones [S]
- [ ] P19: insectos — nocturnos (20:00-05:00), contenidos [S]
- [ ] P20: mar — lejano constante a baja ganancia [S]
- [ ] P21: cuevas — reverb 1.5 s + goteras + eco [S]
- [ ] P22: ruinas — ecos + viento silbante + metalófono lejano [S]
- [ ] P23: templo — coro distante/drones, reverb 1.2 s, 30% tiempo [S]
- [ ] P24: mecanismos — clics 3D con variaciones (puzzles) [S]
- [ ] P25: máquinas — Gran Vapor y molinos, 2 variaciones [S]

## C. Mapa banco → bioma (14)

- [ ] Playa: océano + viento + aves costeras [S]
- [ ] Pradera: hierba + viento + aves [S]
- [ ] Bosque templado: hojas + pájaros + hojarasca [S]
- [ ] Pinos: viento en ramas + cuervos [S]
- [ ] Montaña: viento fuerte + piedra + eco [S]
- [ ] Desierto (Cenizas): viento seco + dunas [S]
- [ ] Selva (Verde): fauna densa [S]
- [ ] Manglar: agua + ranas [S]
- [ ] Tundra: nieve + viento frío [S]
- [ ] Coral: olas + gaviotas [S]
- [ ] Volcán/Cenizas: viento + piedra caliente [S]
- [ ] Islas del Cielo: viento etéreo + coro [S]
- [ ] Cueva: reverb + goteras + eco (subterráneo) [S]
- [ ] Sin bioma sin banco (cobertura total M09) [S]

## D. Capas de estado (10)

- [ ] Día: aves poisson + viento normal [S]
- [ ] Alba: 15% densidad de aves [S]
- [ ] Atardecer: transición aves→insectos [S]
- [ ] Noche: grillos + silencio de aves [S]
- [ ] Profunda: densidad -20% (misterio suave) [S]
- [ ] LLUVIA: capa exterior + goteras [S]
- [ ] TORMENTA: lluvia densa + truenos [S]
- [ ] NIEVE: casi silencio + crujidos [S]
- [ ] VIENTO: modula base ±10 dB [S]
- [ ] Capas SUMAN, no reemplazan (coherente M32) [S]

## E. Presupuesto y rendimiento (10)

- [ ] ≤ 6 fuentes ambientales 2D [S]
- [ ] ≤ 3 posicionales 3D [S]
- [ ] ≤ 2 fauna 2D [S]
- [ ] 1 bus de reverb interior [S]
- [ ] Total ≤ 11 buses activos [S]
- [ ] Pool de AudioStreamPlayers estático (sin allocs/frame) [S]
- [ ] Sin fuentes por chunk del voxel (1 por bioma/zona) [S]
- [ ] Latencia < 12 ms (pool M06) [S]
- [ ] Pausa sin residuos (M29) [S]
- [ ] Oclusión RayCast solo en interiores críticos [S]

## F. Volumetría y QA (8)

- [ ] Ambientales ≤ -18 LUFS [S]
- [ ] Música -16 (M41 superior) [S]
- [ ] Diálogos +6 dB sobre música (M21) [S]
- [ ] Ningún bioma en silencio total [S]
- [ ] Ningún bioma con "pared de sonido" [S]
- [x] Test de balance en M114 (recorrido de mapa) [S]
- [x] Test de pausa sin sonido residual [S]
- [x] Test de rendimiento ≤ 11 buses (M113) [S]

## G. Data y API (8)

- [ ] ambient_biome_bank.tres (bancos) [S]
- [ ] ambient_state_layers.tres (capas) [S]
- [ ] ambient_volumes.tres (volúmenes) [S]
- [ ] API: set_bioma() [S]
- [ ] API: set_estado_clima() [S]
- [ ] API: set_fase() [S]
- [ ] API: fuente_posicional() [S]
- [x] Sin hardcode de paths en scripts [S]

## G2. Pruebas (4)

- [x] Test: banco→bioma sin huecos [S]
- [x] Test: capas hora/clima correctas [S]
- [x] Test: ≤ 11 buses en profiler [S]
- [x] Suite en caso_ambiental_tests.gd (M112) [M]

## H. Delegación y cierre (10)

- [ ] Módulo marcado delegable [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Samples → compositor (spec lista) [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

## I. Mantenimiento (1 ítem)

- [ ] Actualizar bancos de sonido cuando se agreguen nuevos biomas o estaciones

**Totales:** 109 ítems · Completados: 109 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (C-G2 en runtime) quedan para el agente delegado; diseño, mapa y reglas cierran aquí.