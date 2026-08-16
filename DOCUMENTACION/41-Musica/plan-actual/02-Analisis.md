**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 41: Música

## 1. Resolución de los 51 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Música de intro | Tema principal de Aurora (caleidoscopio sonoro cozy): 60 s, orquesta ligera, sin texto |
| 2 | Música de menú | Variación del tema principal, loop 45 s, volumen -8 dB bajo el logo |
| 3 | Música de creación de personaje | Bucle suave (uelle, marimba) 90 s; loop perfecto |
| 4 | Música de llegada | Transición de velero → isla: capa de "aventura costera" de 30-45 s; el leitmotif de Aurora entra al tocar tierra |
| 5 | Música de Aurora (pueblo) | Tema principal con variaciones; base de la matriz diurna |
| 6 | Música de día | Capa "día" sobre el tema de zona: woodwinds + campanas suaves |
| 7 | Música de noche | Capa "noche": celesta/piano lejano, 25% menos densidad; cozy, sin terror |
| 8 | Música de madrugada | Capa "alba": ambiente de cuerdas sostenidas |
| 9 | Música de amanecer | Capa de amanecer (M31 ALBA): arpa + vientos |
| 10 | Música de atardecer | Capa atardecer (M31 ATARDECER): calidez en cello |
| 11-14 | Música por estación | Primavera: flautas, tempo 100; Verano: percusión ligera + 100-110; Otoño: viola + 90; Invierno: glockenspiel + 85; cada estación recoloriza los temas de zona (misma armonía, diferente orquestación) |
| 15 | Música de lluvia | Capa "lluvia" (mezcla con M32): piano + pads suaves, sin percusión |
| 16 | Música de tormenta | Capa "tormenta": cuerdas con bajo suave; volumen ≤ tema base; NUNCA música de tensión |
| 17 | Música de nieve | Capa "nieve": campanas + cuerdas frías; delicado |
| 18-20 | Zonas (playa, bosque, montaña) | Playa: ukelele/caracola; Bosque: flautas + tarareo; Montaña: vientos + eco |
| 21 | Cueva | Subterráneo 1: cuerdas graves suaves, REVERB alto; NUNCA ominoso |
| 22 | Templo | Tema de templo (M24): cuerdas + coro femenino susurrado, misterio calmado |
| 23 | Ruinas | Tema de ruinas (M25): metalófono + viento; nostálgico |
| 24-27 | Islas | Coral: vibráfono + olas (marimba acuática); Verde: selva (percusión suave); Cenizas: cuerdas solas, melancólico; Cielo: arpa + coro etéreo |
| 28 | Océano | Tema de mar (viaje M28): acordeón suave + olas |
| 29 | Submarina | Burbujas + celesta, muy suave |
| 30 | Elysia | Tema celestial especial: coro + cuerdas; la "isla del final" (M22) |
| 31 | Tensión narrativa | Versión "preocupación suave": mismas armonías + menos percusión; duración máxima 45 s antes de resolver (anti-FOMO, nunca se estanca) |
| 32 | Descubrimiento | "Ascenso de maravillas": arpa + corno suave, 4 compases |
| 33 | Misterio | Misterio calmo: celesta + cuerdas muted; NUNCA disonante |
| 34 | Puzzle resuelto | Resolución: glissando + campanilla, 2 compases |
| 35 | Sello obtenido | Fanfarria SUAVE de Sello (M24): metales pequeños + campanillas, 5 s |
| 36 | Festival | Tema festivo (M29 eventos): percusión + vientos, 100 BPM, joy / sin EDM |
| 37 | Ceremonia | Tema ceremonial: coro + tambor suave (eventos M29) |
| 38 | Créditos | Re-elaboración del tema principal, 3-4 min |
| 39 | Leitmotifs | Aurora (2 compases: intervalo de 5ª ascendente), protagonista (3 notas), cada isla (color único), Gran Vapor (armónica lejana). Todos se citan en temas compuestos |
| 40 | Variaciones dinámicas | Cada tema con 2 (mín) variaciones que barajan; variación elegida por PRNG del jugador (M10 semilla) |
| 41 | Loop | Loop perfecto: secciones de 4/8/16 compases; cada loop termina en la tónica |
| 42 | Duración | Tema de zona 90-150 s por variación; loop sutil (el oído no detecta si es ~2 min y hay variaciones) |
| 43 | Volumen | Referencia: playa (Loudness True Peak -16 LUFS promedio); diálogos +6 dB sobre música; música ≤ -12 dB bajo UI |
| 44 | Transición | Crossfade 3 s entre temas; 1-2 s para stings (Sello, puzzle) |
| 45 | Crossfade | Implementación con AudioStreamPlayer doble (A/B) + tween de volumen |
| 46 | Capas musicales | 3 capas máx simultáneas: base (zona) + tiempo (día/noche/estación con recluido) + evento (lluvia/festival/sting); suma ≤ 8 voces |
| 47 | Música adaptativa | Intensidad sube con: noche (menos capas), festival (más), tormenta (1 capa extra) — NUNCA por peligro de muerte (no hay combate obligatorio) |
| 48 | Evitar repetición | Variaciones ×2 + shuffle PRNG + pausas de silencio 5-15 s entre loops con misma variación |
| 49 | Normalizar | Todos los temas pasan por loudness -16 LUFS; stings -18 |
| 50 | Masterización | Headroom 3 dB, sin compresión agresiva; masterización final en M84 (licencias) |
| 51 | Presupuesto | ≤ 80 temas + ≤ 20 stings (presupuesto M133 y royalties M84) |

## 2. Decisiones clave

1. **Paleta cozy por capas:** base = zona, capa 2 = día/noche/estación, capa 3 = eventos; permite 12×4×3 contextos sin componer 144 temas (presupuesto).
2. **Sin música de combate:** (no hay combate obligatorio); la "tensión narrativa" es siempre suave y limitada a 45 s.
3. **Todas las variaciones barajan con PRNG del jugador** (M10): cada sesión suena distinto.
4. **Volumetría profesional desde el diseño** (LUFS), para que M84 (licencias/royalties) no tenga sorpresas.

## 3. Alternativas descartadas

- **MIDI procedural generado por IA al vuelo:** calidad/latencia imprevisibles; riesgo legal (M86 IA generativa); descartado.
- **Música solo ambiental sin tema:** el proyecto quiere leitmotifs (visión M02); descartado.
- **Sistema adaptativo complejo tipo "pistas de riesgo" (combat music layers):** innecesario y anti-cozy; descartado.