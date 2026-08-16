**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 32: Clima

## 1. Resolución de los 25 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Clima soleado | Estado base (default). Sol 100%, cielo despejado, sin partículas; dura 2-4 h; más frecuente en verano (60%) |
| 2 | Lluvia | Finas y tranquilas. Sol a 70%, cielo gris suave, partículas GPU de lluvia (densidad media), sombras suaves; riega parcelas (M33) |
| 3 | Tormenta | Evento visible pero sutil: sol a 35%, truenos LEJANOS (volumen acotado), lluvia más densa 90 s antes/después; NUNCA cae rayo sobre el jugador; aviso 1 día antes |
| 4 | Niebla | Niebla baja densa (visual 120 m), sonidos amortiguados; dos franjas: matinal (otoño) y densa (invierno); nunca obstruye minimapa (M12) |
| 5 | Nieve | Solo invierno. Sol a 110% (reflejo), partículas de nieve livianas, suelo con cubierta visual (M08 nieve superficial), sin daño a cultivos (invernadero M33) |
| 6 | Viento | Racha visual: hojas/arena/polen (M50 sway), sin jugabilidad afectada; velocidad 2-3 niveles estéticos; nunca cambia físicas del jugador |
| 7 | Tormenta tropical | Solo verano, rarísima (2-4/año), acompañada de lluvia + viento; cielo dramático pero toda la isla sigue siendo segura (refugiarse es opcional) |
| 8 | Clima especial | Aurora boreal (invierno, 1-2 noches/año, visible en el Norte de la isla M09); arcoíris tras lluvia fuerte (30 min de juego); lluvia de estrellas requiere cielo despejado (M31) |
| 9 | Frecuencia | Tabla de probabilidades por estación (sección 3 del diseño). PRNG por (semilla_partida, día_del_año) → clima del día; transición de día a la medianoche del juego |
| 10 | Duración | 2-4 h de juego por tipo; tormenta máxima 3 h; niebla matinal 2 h; nieve 3-6 h; duración por tipo en data (knobs) |
| 11 | Transición | Crossfade 60-90 s de juego (intensidad 0→1); doble buffer entre partículas; sin cortes en señales de fase (M31) |
| 12 | Partículas | GPU Particles3D compartido (1 sistema): lluvia, nieve, hojas según tipo; densidad por calidad gráfica (M90); pausan con GameClock (M29) |
| 13 | Sonidos | Buses M42: lluvia suave (loop + variación), viento, truenos lejanos (cada 30-90 s durante tormenta), nieve casi silenciosa (crujido de pasos M44); volúmenes fijados |
| 14 | Música | M41: variante "lluvia" (misma base + capa suave de pads); tormenta NO cambia el tema a tensión (cozy); crossfade 3 s |
| 15 | Iluminación | Atenuación de sol por capa (tabla): soleado 1.0, nublado 0.85, lluvia 0.7, tormenta 0.35, niebla 0.6, nieve 1.1; color tintado (lluvia azul-gris, nieve frío, aurora verde) |
| 16 | Efectos vegetación | M50: sway fuerte con viento/tormenta; hojas con gotas (materiales M47); sin cambios de mecánica |
| 17 | Efectos agua | M51: ondas pequeñas lluvia, agitadas tormenta (amplitud 1.5x), calmas nieve; sin cambios de navegación acuática |
| 18 | Efectos NPC | M19: con lluvia suave siguen rutina (paraguas animación M48); con tormenta buscan refugio 30-60 min de juego y vuelven; NUNCA cancelan interacciones de historia (M22) |
| 19 | Efectos fauna | M36: aves se refugian (sin spawn), ranas/caracoles aparecen con lluvia (recolección M15), fauna nocturna a resguardo en tormenta |
| 20 | Efectos agricultura | M33: la lluvia RIEGA parcelas automáticamente (bonus cozy); nieve: cultivos en invernadero protegidos; tormenta NO daña cosechas (nunca se pierde trabajo — anti-frustración) |
| 21 | Efectos pesca | M34: lluvia +15% probabilidad de pez raro (recompensa opcional); tormenta: pesca posible con bono pequeño; nunca prohibida |
| 22 | Efectos navegación | Niebla reduce distancia visual (los faroles de M31 ayudan) pero minimapa (M12) siempre funciona; sin zonas bloqueadas por clima; el Gran Vapor (M28) sale igual (clima no cancela viajes) |
| 23 | Eventos especiales | Aurora (día fijo del calendario, M29) + lluvia de estrellas (M31) excluyen tormenta (validación mutua); arcoíris es decorativo |
| 24 | Evitar clima molesto | **Regla de oro:** el clima jamás bloquea, destruye ni castiga. Ningún objeto, misión, NPC o pez exige clima obligatorio (solo bonificaciones). Aviso de tormenta 1 día antes (UI M30) |
| 25 | Accesibilidad | M58: "Reducir clima" (densidad -50%), "Sin truenos" (fotosensibilidad), "Niebla reducida" (visual 80%); datos del clima también por texto (banner de aviso, sin frases crípticas) |

## 2. Decisiones clave

1. **Determinismo por (seed, día):** el clima del día se calcula igual al guardar/cargar; imposible re-rollear clima con recargas. Sin estado climático "global mutable" fuera de GameState.M32 (solo intensidad transitoria).
2. **Clima nunca castiga:** bono sí, bloqueo no. (Alineado con M152 Principios Innegociables de DEVIN: sin castigos irreversibles ni FOMO.)
3. **Tormenta segura:** truenos lejanos, sin rayos al jugador — atmósfera cozy, no survival.
4. **1 sistema de partículas compartido:** rendimiento (M61); las transiciones con doble buffer de densidades.
5. **Nieve estacional real pero protectora:** visual superficial en el voxel (M08) sin efectos de frío ni hambre forzada (M93 balance lo verifica).

## 3. Alternativas descartadas

- **Clima por simulación meteorológica continua (trayectorias):** complejidad innecesaria para cozy; el determinismo por día es más barato y testeable.
- **Tormenta con rayos al azar (elemento de riesgo):** descartada por pilar cozy y por QA de accesibilidad.
- **Clima que cancela viajes/fast travel (M69):** descartado (frustra), el aviso previo NO cancela nada.
- **Nieve que daña cultivos al aire libre:** descartado (anti-frustración; invernadero como opción, no como obligación).