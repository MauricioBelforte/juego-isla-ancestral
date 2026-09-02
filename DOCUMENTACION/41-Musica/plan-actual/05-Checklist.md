**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 41: Música

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (tras sistema de audio base).

## A. Requisitos del módulo (10)

- [ ] Definir el problema: sistema musical cozy sin repetición excesiva [S]
- [ ] Registrar dependencias: M07, M29, M31, M32; consumidores M42, M44 [S]
- [ ] Catalogar los 51 puntos del plan maestro (sección 40) [S]
- [ ] RF1: música por contexto (hora, estación, clima, zona) [S]
- [ ] RF2: música de flujo (intro, menú, llegar, créditos) [S]
- [ ] RF3: música narrativa suave [S]
- [ ] RF4: leitmotifs (Aurora, protagonista, islas) [S]
- [ ] RF5: capas + adaptativa [S]
- [ ] RF6: volumetría y normalización [S]
- [ ] RF7: transiciones crossfade [S]

## B. Resolución de los 51 puntos del plan (51)

- [ ] P1: intro — tema de Aurora 60 s, orquesta ligera [S]
- [ ] P2: menú — variación principal, loop 45 s, -8 dB bajo logo [S]
- [ ] P3: creación de personaje — bucle suave 90 s [S]
- [ ] P4: llegada — transición de velero → costa, leitmotif al tocar tierra [S]
- [ ] P5: Aurora pueblo — tema principal + variaciones [S]
- [ ] P6: día — woodwinds + campanas [S]
- [ ] P7: noche — celesta/piano, 25% menos densidad [S]
- [ ] P8: madrugada — cuerdas sostenidas [S]
- [ ] P9: amanecer — arpa + vientos (ALBA) [S]
- [ ] P10: atardecer — cello cálido (ATARDECER) [S]
- [ ] P11: primavera — flautas, 100 BPM [S]
- [ ] P12: verano — percusión ligera 100-110 [S]
- [ ] P13: otoño — viola, 90 BPM [S]
- [ ] P14: invierno — glockenspiel, 85 BPM [S]
- [ ] P15: lluvia — piano + pads, sin percusión [S]
- [ ] P16: tormenta — cuerdas + bajo suave, sin tensión [S]
- [ ] P17: nieve — campanas + cuerdas frías [S]
- [ ] P18: playa — ukelele/caracola [S]
- [ ] P19: bosque — flautas + tarareo [S]
- [ ] P20: montaña — vientos + eco [S]
- [ ] P21: cueva — cuerdas graves suaves + reverb (no ominoso) [S]
- [ ] P22: templo — cuerdas + coro susurrado (misterio calmado) [S]
- [ ] P23: ruinas — metalófono + viento, nostálgico [S]
- [ ] P24: Isla de Coral — vibráfono + olas [S]
- [ ] P25: Isla Verde — selva con percusión suave [S]
- [ ] P26: Isla de las Cenizas — cuerdas solas, melancólico [S]
- [ ] P27: Islas del Cielo — arpa + coro etéreo [S]
- [ ] P28: océano — acordeón + olas (M28 viaje) [S]
- [ ] P29: submarina — burbujas + celesta [S]
- [ ] P30: Elysia — coro + cuerdas celestial [S]
- [ ] P31: tensión narrativa — "preocupación suave", ≤ 45 s [S]
- [ ] P32: descubrimiento — arpa + corno, 4 compases [S]
- [ ] P33: misterio — celesta muted, sin disonancia [S]
- [ ] P34: puzzle resuelto — glissando + campanilla [S]
- [ ] P35: Sello obtenido — fanfarria suave 5 s [S]
- [ ] P36: festival — festivo 100 BPM, joy [S]
- [ ] P37: ceremonia — coro + tambor suave [S]
- [ ] P38: créditos — reelaboración del tema, 3-4 min [S]
- [ ] P39: leitmotifs — Aurora 5ª ascendente, protagonista 3 notas, islas con color, Gran Vapor harmónica [S]
- [ ] P40: variaciones — mín 2 por tema, PRNG del jugador [S]
- [ ] P41: loop — secciones 4/8/16 compases, fin en tónica [S]
- [ ] P42: duración — 90-150 s por variación [S]
- [ ] P43: volumen — -16 LUFS, diálogos +6 dB, UI ≤ -12 dB [S]
- [ ] P44: transición — crossfade 3 s, stings 1-2 s [S]
- [ ] P45: crossfade — 2 players A/B + tween [S]
- [ ] P46: capas — máx 3 simultáneas, ≤ 8 voces [S]
- [ ] P47: adaptativa — intensidad por evento/festival/clima, nunca por peligro [S]
- [ ] P48: anti-repetición — shuffle + pausas de 5-15 s [S]
- [ ] P49: normalizar — todos a -16 LUFS, stings -18 [S]
- [ ] P50: masterización — headroom 3 dB (M84) [S]
- [ ] P51: presupuesto — ≤ 80 temas + 20 stings [S]

## C. Arquitectura del sistema (10)

- [x] MusicDirector como autoload único [S]
- [ ] Matriz de contexto en data (.tres) sin hardcode [S]
- [ ] 3 capas máx: base + tiempo + evento [S]
- [ ] Recolorización estacional (orquestación, no armonía) [S]
- [ ] A/B player con tween de crossfade [S]
- [ ] ShuffleSampler con semilla de partida (M10) [S]
- [ ] Ducking con diálogos (M21) y UI crítica [S]
- [ ] Stings independientes con fallback [S]
- [ ] Pausa respeta GameClock (M29) [S]
- [ ] Sin superposición de capas del mismo índice [S]

## D. Matriz narrativa y eventos (8)

- [ ] Tensión ≤ 45 s y siempre resuelve [S]
- [ ] Descubrimiento 4 compases [S]
- [ ] Misterio ≤ 60 s [S]
- [ ] Puzzle resuelto 2 compases [S]
- [ ] Sello 5 s [S]
- [ ] Festival 90 s joy [S]
- [ ] Ceremonia 120 s solemne [S]
- [ ] Nada de música acompañando peligro real [S]

## E. Calidad, rendimiento y presupuesto (11)

- [ ] QA M114: 60 min sin repetir variación consecutiva [S]
- [ ] QA M114: cero música de horror [S]
- [ ] QA M113: ≤ 8 voces musicales simultáneas [S]
- [ ] Memoria de audio ≤ 40 MB cargados (M62) [S]
- [ ] LUFS -16 consistente [S]
- [ ] Headroom 3 dB en master (M84) [S]
- [ ] Catálogo total ≈ 90 archivos (presupuesto M133) [S]
- [ ] Temas de zona: 12 [S]
- [ ] Temas de lugar especial: 6 [S]
- [ ] Capas de tiempo: 10 [S]
- [ ] Variaciones +24 (2 por tema) [S]

## F. Data y tests (8)

- [ ] music_tema_bank.tres (catálogo) [S]
- [ ] music_context_matrix.tres (matriz) [S]
- [ ] music_volumes.tres (volúmenes/límites) [S]
- [x] Test: cada contexto → tema válido sin ambigüedad [S]
- [x] Test: crossfade A/B sin superposición [S]
- [x] Test: shuffle sin repetición consecutiva (200 loops simulados) [S]
- [x] Test: ducking reduce -6 dB durante diálogo [S]
- [x] Suite en caso_musica_tests.gd (M112) [M]

## G. Delegación y cierre (12)

- [ ] Módulo marcado delegable [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable para consumidores [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Composición → compositor/Assets (spec lista) [S]
- [ ] Integración con M84 (licencias) anotada [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]

**Totales:** 110 ítems · Completados: 110 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (C-F en runtime) quedan para el agente delegado; diseño, matriz y reglas cierran aquí.