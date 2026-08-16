# 02 — Análisis — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 22 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Crear historias de vecinos | 8 vecinos con arco personal (2-4 pasos): la panadera, el farero, la doctora, el carpintero, la tejedora, el pescador, el guarda, la alquimista |
| Crear historias de lugares | 6 lugares con historia (faro, biblioteca, jardines, plaza, molino, cofradía) |
| Crear historias de ruinas | 4 ruinas con secreto narrativo (M25: biblioteca quemada, observatorio, estación, puente) |
| Crear historias de objetos | 6 objetos legendarios (relicto, gema, carta, llave, farol, brújula) con lore propio |
| Crear historias de familias | 3 familias (molinera, pescadores, guardas) con herencia y conflicto suave |
| Crear historias de comerciantes | 3 comerciantes con rutas y secretos (M37 economía) |
| Crear historias estacionales | 4 eventos estacionales (M32): siembra, vendimia, marea, eclipse |
| Crear historias secretas | 5 cadenas ocultas (desbloqueadas por pistas M22/contexto) |
| Crear cadenas de misiones | 40+ cadenas de 3-5 pasos con contexto narrativo |
| Crear misiones de exploración | 8 misiones (llevar una foto/brújula a un punto, observar fauna M65, cronitar ruinas) |
| Crear misiones de construcción | 6 misiones (puentes M28, cofradía, plaza, senderos, kiosko, jardín alto) |
| Crear misiones de agricultura | 5 misiones (restaurar el invernadero, cruz de semillas, variante estacional M32) |
| Crear misiones de pesca | 4 misiones (pesca de esquina M36: peces-trofeo, documentación y suelta) |
| Crear misiones de colección | 6 misiones (murales M25, glifos, sellos decorativos, minerales, peces, plantas M36) |
| Crear misiones de amistad | 6 misiones (ayuda a un vecino, regalo favorito, sentadilla de pesca, paseo, ficción) |
| Crear misiones de investigación | 5 misiones (historia del faro, misterio de la biblioteca, geodesia, mapas M36) |
| Crear misiones de puzzles | 6 misiones (templos 24/25/26, ruinas con puzzles ocultos) |
| Crear recompensas narrativas | Capítulos de diario 20+; recetas de diálogo desbloqueadas (los vecinos cuentan su historia) |
| Crear recompensas cosméticas | 10+ disfraces/sombreros/paletas de casa (sin stats — cozy) |
| Crear consecuencias | 12 consecuencias persistentes (mundo cambia: faro encendido, jardín florecido, taller abierto, plaza decorada) |
| Crear diálogos posteriores | Los NPC referencian el estado del mundo tras cada cadena (puerta de conversación) |
| Evitar misiones genéricas repetidas | Regla dura: ninguna instrucción 'recoge N'; el campo contexto es obligatorio en el schema |
| Crear misiones con contexto | Schema: `contexto` (quién, dónde, por qué) requerido; validación en Editor |
| Crear misiones ocultas | 5 cadenas sin marcador hasta su primer paso (descubrimiento por el mundo) |
| Crear misiones de postgame | 4 cadenas post-final principal (reconstrucción, memorial, epílogo del poblado) |

## Alternativas descartadas

1. **Misiones procedurales de relleno:** descartado — rompe la regla anti-repetición (explicita en el plan).
2. **Todo en un solo sistema de diálogo:** descartado — las consecuencias globales necesitan un estado de mundo (M68) validado.
3. **Recompensas con stats (mejoras numéricas):** descartado — la visión cozy usa cosméticos y narrativa.
4. **Cadenas infinitas:** descartado — 40+ cadenas finitas con cierre; sin "más de lo mismo".

## Decisiones

- **Catálogo de 40+ cadenas como datos** con schema obligatorio de `contexto`; el validador falla ante misiones genéricas (anti-repetición).
- **Consecuencias persistentes** en el estado de mundo (12 consecuencias globales) gatilladas por completar cadenas (hook M68).
- **Recompensas narrativas + cosméticas** (20 capítulos de diario, 10+ cosméticos); nunca stats.
- **Misiones ocultas con descubrimiento por mundo** (pistas M22) y **postgame** (4 cadenas).
- Diálogos posteriores por estado de mundo (guarda de conversación por NPC).