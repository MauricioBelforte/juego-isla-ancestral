**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 42: Sonido Ambiental

## 1. Resolución de los 25 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Viento | Estrato base 2D (loop suave, 3 variaciones) en todo exterior; velocidad se modula por clima viento (M32) y montaña (más fuerte) |
| 2 | Hojas | Susurro de hojas 2D, densidad por bioma boscoso (M50 sway); variación aleatoria de pitch ±5% |
| 3 | Hierba | Rizoma de hierba en praderas: loop muy suave, +paso crujiente (M44) |
| 4 | Agua | Agua genérica 2D junto al lago/estanques (M51), densidad por clima |
| 5 | Río | Fuente 3D posicional en ríos del mapa (M09): loop con 4 variaciones; atenúa al alejarse (distancia 60 m) |
| 6 | Cascada | Fuente 3D posicional en cascadas (2 fijas, POI M09): loop con spray fino; audible hasta 120 m |
| 7 | Océano | Fuente 3D en toda la línea de costa (2D layering + 3D cercano): olas suaves; zona de playa intensifica |
| 8 | Lluvia | Capa ambiental 2D (con M32 LLUVIA): lluvia fina exterior + goteras en cobertizos |
| 9 | Tormenta | Capa de tormenta (M32): lluvia densa + truenos lejanos 2D con randomizador 30-90 s; volumen limitado (cozy) |
| 10 | Nieve | Caída de nieve casi silente (M32 NIEVE): solo un zumbar muy suave; crujidos al caminar (M44) |
| 11 | Fuego | Fuente 3D posicional (fogata, M40 infraestructura): chisporroteo, loop 3 variaciones; también en interior de casas |
| 12 | Madera | Impactos de madera (construcción M17): golpes secos randomized; también pasos sobre puentes |
| 13 | Piedra | Impactos de piedra (M13 minería/construcción): 5 variaciones de golpe con eco ligero |
| 14 | Minería | Extracción de recursos (M35/minería): golpe + caída de gravilla; volumen cercano con oclusión de túnel |
| 15 | Construcción | Evento stagger: martillazos con ritmo (M17): 3 capas (madera, piedra, metal) |
| 16 | Árboles | Tala/impacto en recursos árbol (M13): crujido de madera al romper, con fallback de ramas |
| 17 | Animales | Fauna de fondo (M36): 2D spacies con horas; en pantalla cerca → 3D puntual |
| 18 | Aves | Trino diurno (05:30-19:00 M31): 6+ variaciones, poisson; anochecer silencio |
| 19 | Insectos | Grillos/chorrería nocturna (20:00-05:00): loop low + chirridos aleatorios; volumen contenidos |
| 20 | Mar | Mar lejano constante 2D (distancia): los mismos samples del océano a baja ganancia en biomas interiores |
| 21 | Cuevas | Reverb de cueva (AudioServer reverb 1.5 s), goteras aleatorias, eco de pasos |
| 22 | Ruinas | Ecos y viento silbante por aberturas (M25): loop + scena de metalófono lejano |
| 23 | Templo | Coro distante / drones de piedra (M24): reverb 1.2 s, solo 30% del tiempo (misterio, sin miedo) |
| 24 | Mecanismos | Engranajes y palancas (M24 puzzles): clics de mecanismo posicional (3D) con variaciones; feedback de puzzles |
| 25 | Máquinas | Máquinas del Gran Vapor (M28) y molinos (M40): bufido/ruido mecánico suave 3D, 2 variaciones |

## 2. Decisiones clave

1. **Bancos por bioma + capas de clima/hora:** un solo banco .tres por bioma; las capas de clima se suman (no reemplazan) → coherente con M32.
2. **Máximo 8+2 fuentes ambientales** por zona: control de rendimiento (M61) y de fatiga auditiva.
3. **Fauna con horas de actividad** (M31): aves de día, grillos de noche — refuerzan el ciclo sin más sistemas.
4. **Reverb dedicado por interior** (cueva/ruinas/templo): personalidad acústica, cero código extra de IA.
5. **Siempre ≤ -18 LUFS ambientales:** la música (M41) y diálogos (M21) suben por encima; sin "pared de sonido".

## 3. Alternativas descartadas

- **Ambientes procedurales con síntesis en vivo:** calidad variable sin librerías grandes; riesgo de rendimiento; descartado (se usan loops multi-variación).
- **Sonido por cada chunk del voxel (un emisor por chunk):** destructivo para el presupuesto (M61); se usa un emisor por bioma por zona.
- **Oclusión total con RayCast por fuente:** costoso en runtime; solo interiores críticos la usan (cueva/templo).