**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 137: Prototipo

## 1. Análisis del Dominio

### 1.1 Por qué se prototipa antes del contenido

El Plan-de-produccion.md (sección 1) diagnostica: el GDD completo es "varios juegos combinados" (voxel estilo Minecraft + vida cozy estilo Stardew + templos estilo Zelda + oceánico estilo Subnautica). La estrategia recomendada es validar por partes. El prototipo valida la parte más riesgosa: **el voxel en Godot 4.x con un juego cozy** (combina dos géneros que rara vez se cruzan).

Pregunta central del hito: **"¿Moverte, modificar el mundo y socializar en una isla voxel es agradable en Godot?"**
Preguntas secundarias:
- ¿El sistema voxel (Voxel Tools) rinde ≥ 60 FPS con modificación en tiempo real?
- ¿La cámara en tercera persona evita nausea en un mundo voxel?
- ¿El bucle extraer→recolectar→conversar→resolver→guardar se siente cozy (sin grind, sin ansiedad)?

### 1.2 Riesgos técnicos a despejar en el prototipo

| Riesgo | Pregunta a responder | Cómo se mide |
|---|---|---|
| Rendimiento voxel | ¿Voxel Tools mantiene 60 FPS al modificar terreno? | FPS con Profiler (M61), escena 64³-96³ |
| Colisiones/vegas | ¿La física del jugador sobre voxel es estable? | Sesión de juego, bugs |
| Cámara | ¿Evita clips y mareos? | Playtest + encuesta |
| Guardado del mundo modificado | ¿Guardar cambios del voxel es rápido y confiable? | Test guardar/cargar |
| I/O del save | ¿`GameState` (M59) escala al guardar mundo voxel? | Tamaño del save y tiempo de carga |
| IB de las herramientas | ¿El flujo extraer/colocar se siente bien con input cómodo (M57)? | Playtest |

### 1.3 El prototipo como "mínimo divertido" vs. "mínimo vertical"

| Enfoque | Descripción | Riesgo |
|---|---|---|
| Mínimo vertical (Vertical Slice M138) | 1 zona pulida de principio a fin | Costoso; atrasa la validación del núcleo |
| **Mínimo divertido (PROTOTIPO, este módulo)** | Núcleo feo pero jugable que responde UNA pregunta | Riesgo de sesgo: si es feo, la diversión se subestima — se mitiga con encuesta enfocada en el bucle, no en el arte |

Decisión: prototipo = mínimo divertido; la pulcritud llega en M138 (Vertical Slice).

### 1.4 Qué prototipos previos referenciar

| Juego | Lección para el prototipo |
|---|---|
| Minecraft | El voxel atrae por CREAR, no por destruir: prototipar colocación como acción igual de agradable que extraer |
| A Short Hike | Mundo pequeño + libertad = diversión inmediata; el prototipo es un mapa chico a propósito |
| Stardew | El bucle social (regalar) suma sin costo técnico: prototipar UN regalo |
| Grow Home | La cámara/control sobre terreno irregular es el riesgo principal |

## 2. Alternativas Consideradas

### 2.1 Motor: Godot 4.x (decisión del proyecto, M04)
Se valida en el prototipo. Si Voxel Tools no rinde, la decisión de motor se reabre AQUÍ (antes de invertir en contenido) — el prototipo es la prueba de fuego.

### 2.2 Tamaño del mapa: 64³ vs. 96³ vs. islas múltiples
Se elige **isla única de ~64³-96³ alcanzable**: suficiente para esconder casa/ruina/NPC sin cargar el rendimiento. El ocean entre islas (M51) NO se prototipa.

### 2.3 Guardado del mundo voxel: entero vs. chunks modificados
Se elige **guardar solo chunks modificados** (delta): el save se mantiene pequeño y la carga rápida (M59/M60). El mundo base se regenera proceduralmente (M10) con seed fija.

### 2.4 Medición de diversión: encuesta vs. observación
Se usan AMBAS: encuesta corta (M114) + observación del playtester (dónde se detiene, qué repite). La repetición espontánea de una acción es el mejor indicador temprano de diversión.

### 2.5 Checks de filosofía: checklist manual vs. integrado
Checklist manual en el playtest (M152/M153) al inicio; se automatizará recién cuando existan los datos (M105). En el prototipo NO hay telemetría.

## 3. Decisiones Tomadas

1. **Prototipo "mínimo divertido"** (< 4 semanas), isla única 64³-96³, con todos los sistemas RF1-RF12 en versión fea pero funcional.
2. **Guardado delta de chunks** (M59/M60): solo chunks modificados, seed fija del mundo.
3. **UNA pregunta principal** (¿el núcleo divierte?) + 4 secundarias (rendimiento, cámara, guardado, input). Todo lo demás se corta.
4. **Playtest ≥ 3 personas** con encuesta (diversión ≥ 7/10 = GO preliminar) y observación.
5. **GO/NO-GO con criterios objetivos** documentados; sin "ya casi está" (criterios binarios).
6. **Corrupción del save = bloqueante** del GO (guardado confiable es promesa central, M59).
7. **Versionado:** tag `prototipo-v1` al cierre; log de decisiones en `docs/prototipo/`.
8. **No polish:** los placeholders (bloques de color, cube-NPC) son intencionales; se documenta en el reporte para que el playtester no penalice el arte.
9. **Presupuesto de riesgo:** si Voxel Tools falla el rendimiento, pasar a grid+props (7 días de contingencia) antes de reabrir la decisión de motor.
10. **Retrospectiva post-protipo:** sesión de lecciones que alimente M138 (Vertical Slice).

## 4. Integración con Otros Módulos

| Módulo | Qué usa del Prototipo | Qué aporta al Prototipo |
|---|---|---|
| M08/M09/M10 | Mundo voxel (núcleo) | Terreno, generación, extracción |
| M11/M12 | Jugador y cámara | Movimiento y cámara estable |
| M14/M59 | Inventario y guardado | Slot único + save delta |
| M21/M19 | Diálogo y NPC | NPC de prueba con un regalo |
| M24/M25 | Puzzle y ruina | 1 puzzle + 1 ruina |
| M18 | Casa | Habitación interactuable |
| M31/M32 | Día-noche y clima | Ciclo y clima simple |
| M114 | Playtest | Sesión y encuesta |
| M152/M153 | Filosofía y visión | Checks de validación |
| M61 | Rendimiento | Budget FPS y profiling |
| M136 | Roadmap | El prototipo es fase 1 del roadmap |

## 5. Edge Cases Identificados

1. **Playtester que no entiende el bucle** — el prototipo incluye una pista visual (flecha) opcional; no un tutorial (M92 llega después).
2. **Voxel con huecos sin colisión** — test de estabilidad: caminar por bordes y escaleras improvisadas.
3. **Save con chunks modificados y mundo regenerado** — seed fija obligatoria; si la seed cambia, el save se invalida (aviso).
4. **FPS < 60 en la zona densa** — medición con Profiler; el criterio de GO usa config media, no ultra.
5. **Jugador que rompe el puzzle sin herramienta** — el prototipo permite el bypass (registrar en reporte como dato de diseño).
6. **NPC colgado en el voxel** — IA de prueba por waypoints fijos (M64 no se prototipa).