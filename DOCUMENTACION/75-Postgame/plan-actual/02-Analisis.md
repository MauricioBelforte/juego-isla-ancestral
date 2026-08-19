**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 75: Postgame

## 1. Análisis del Dominio

El postgame de un cozy de vida isleña (estilo Animal Crossing / Stardew) responde a una pregunta: **¿qué hago después de los créditos?** El plan maestro exige 20 contenidos (islas, vecinos, muebles, plantas, animales, ruinas, puzzles, colecciones, herramientas, mejoras, historias, eventos, secretos, zonas submarinas, islas flotantes, sistemas opcionales, 100%, logros finales, exploración libre). El riesgo #1: **postcarga fría** (créditos → pantalla "Fin" → aburrimiento). El riesgo #2: **promesa de contenido infinito** sin arquitectura (islas flotantes y zonas submarinas citadas pero sin mapeo a módulos reales).

Análisis de las 20 exigencias agrupadas por naturaleza:

| Grupo | Exigencias | Naturaleza |
|---|---|---|
| Contenido inmediato | 100% (M73/M37/M55), logros finales (M72), exploración libre | **Hoja de ruta + sistemas existentes** |
| Vida nueva | Vecinos (M19), muebles (M18), plantas (M50), animales (M36), historias (M23), eventos (M74), secretos (M71) | **Contenido de datos** sobre sistemas existentes |
| Mundo nuevo | Islas (M27), ruinas (M25), puzzles (M24), zonas submarinas (M51), islas flotantes (M10) | **Nuevos mapas/chunks** (cada uno su módulo) |
| Herramientas | Herramientas (M16), mejoras (M17), sistemas opcionales | **Nuevos sistemas** (fase 2) |

**Conclusión:** el módulo 75 NO desarrolla sistemas — es el **orquestador del contenido postgame**: catálogo de expansiones (FASE 1 vs FASE 2), hoja de ruta del 100% (sin spoilers, ver M55), hitos de logros finales (M72), eventos rotativos de postgame (M74) y validación.

## 2. Alternativas Consideradas

### 2.1 Hoja de ruta del 100%
- **A1. Pestaña dedicada en el diario (M55):** el diario ya conoce descubrimientos; agrega "Meta: 100%" con % por categoría anti-spoiler. **ELEGIDA:** una sola fuente de progreso, cero UI duplicada.
- **A2. Panel postgame propio (nuevo menú):** más espectacular pero duplica estados y esfuerzo. Rechazada (modularidad M09: no acoplar).

### 2.2 Catálogo de expansiones
- **A1. Catálogo declarativo `postgame_catalog.tres`:** lista cada expansión con `id`, `nombre`, `fase` (1/2), `requisito`, `módulo`. **ELEGIDA:** el contenido vive en datos; la arquitectura de cada expansión en su módulo (M27/M51/M10...).
- **A2. Enumeración en código:** imposible de auditar con FASE 1/FASE 2. Rechazada.

### 2.3 Contenido fase 2
- **A1. Catálogo con flag `fase: 2`:** visible para el diseñador, oculto al jugador hasta lanzamiento. **ELEGIDA:** sin promesas rotas (el jugador nunca ve "isla flotante (pronto)").
- **A2. Eliminar las menciones del código:** se pierde la hoja de ruta interna. Rechazada.

### 2.4 Logros finales
- **A1. Hitos postgame definidos en `achievements.tres` (M72) marcados `postgame: true`:** el sistema de logros no conoce "historia"; los hitos se agrupan en una categoría "Epílogo". **ELEGIDA:** el postgame NO modifica M72, solo lo configura.
- **A2. Sistema de logros con estado "postgame":** acopla historia a logros. Rechazada.

## 3. Decisiones Técnicas

1. **Orquestador de datos, no de código:** el M75 entrega `postgame_catalog.tres` + `validate_postgame.gd`; cada expansión se implementa en su módulo (M27, M51, M10, M16, M17...). Documentado en `03-Diseno.md` (regla M15: no tocar lo que funciona).
2. **El 100% es una hoja de ruta, no una barra:** el diario (M55) y el museo (M37) muestran % por categoría ya existente; el M75 agrega solo la meta global "Isla al 100%" con desglose anti-spoiler (ver M55: nunca revelar el total oculto).
3. **Anti-spoiler estricto (hereda M55):** el jugador nunca ve categorías sin descubrir; el % se calcula sobre lo descubierto; la hoja de ruta revela solo la próxima meta.
4. **Epílogo = historia, no menú:** tras el final (M22), M92 (tutorial) muestra "¿Qué sigue?" con las metas; M44 celebra. Los créditos se muestran con montaje cozy (montaje de la isla, M55 diario del jugador).
5. **FASE 1 vs FASE 2 explícito:** todo el contenido postgame se marca; nada de "próximamente" en la UI (promesa rota). La fase 2 (islas flotantes M10, submarinas M51, jardín acuático, criadero) solo en la hoja de ruta interna del diseñador.
6. **Eventos postgame rotativos (M74):** programados en el calendario (M29), con recompensas únicas (M38/M20) y sin fecha dura (ciclo anual cozy).
7. **Logros finales (M72):** categoría "Epílogo" con hitos (colección completa, ruina restaurada, primer festival postgame, 100%). Sin logros de grindeo (regla M75).
8. **Persistencia:** el flag `postgame_unlocked` (M59, versión 1.4) se guarda con el mundo; el progreso de la hoja de ruta se deriva de los sistemas existentes (cero duplicación).
9. **Nuevos vecinos (M19):** 1-2 vecinos postgame con rutinas propias (M19), mudanza por invitación (progresión M71). Contenido FASE 1.
10. **Puzzles finales (M24):** el Sello oculto (puzzle de ruinas, FASE 2) es opcional: nunca bloquea contenido principal (regla M22).

## 4. Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Postcarga fría (sin dirección) | Alta | Alto | Hoja de ruta "¿Qué sigue?" (M92) + epílogo M22 |
| Grindeo percibido en el 100% | Media | Alto | Actividades naturales (pesca/excavación), sin repetición |
| Promesa de fase 2 sin arquitectura | Media | Medio | Catálogo con `fase` + módulo real asignado |
| Spoilers del contenido restante | Media | Medio | Anti-spoiler de M55 heredado |
| Eventos con fecha dura (missable) | Baja | Medio | Ciclo anual cozy, sin fechas únicas |
| Logros postgame imposibles | Baja | Alto | `validate_postgame.gd` resuelve cada logro |

## 5. Conclusiones del Análisis

- El M75 es un **módulo de datos y orquestación**, no de gameplay nuevo: entrega catálogo + hoja de ruta + validación; cada expansión pertenece a su módulo.
- El 100% se persigue con **sistemas existentes** (M73, M37, M55, M25, M24, M74), evitando duplicar estados.
- La **fase 2** está catalogada pero invisible al jugador hasta su lanzamiento (sin promesas rotas).
- El epílogo mantiene el tono cozy: la historia termina, la isla continúa.