**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 50: Vegetación

## 1. Análisis del Dominio

El dominio de vegetación de Aurora se descompone en ocho subsistemas:

### 1.1 Catálogo de especies (contenido)
- **Dominio:** el plan maestro define 26+ tipos (hierba, flores, arbustos, árboles de 3 tamaños, palmeras, bambú, tropical, acuático, submarino, musgo, enredaderas, hongos, luminosas). Cada especie tiene malla (M45), materiales (M47) y parámetros: biomas, densidad, altura, pendiente máx, fase de viento.
- **Clave:** árboles grandes y ancestrales TALABLES se representan como bloques voxel (M08) con malla encima para el follaje; hierba/flores/arbustos son decorativas instanciadas.

### 1.2 Densidad por bioma (datos)
- **Dominio:** M09 define 13 biomas; aquí se parametriza density (instancias por chunk), distribución (clusters por PRNG M10), altura mín/máx y pendiente máx por especie.
- **Clave:** la distribución usa PRNG de chunk (M10) → determinismo total; ningún Randomize en runtime.

### 1.3 Instancing y rendimiento (core técnico)
- **Dominio:** Godot MultiMesh instancia mallas con 1 draw call por mesh. Estrategia: MultiMeshInstance3D por especie y por chunk, con instancias cacheadas. Con culling por distancia (M61) y LOD de 2 niveles (malla alta/baja).
- **Presupuesto:** instancias visibles máximas por escena (con preset M90), memoria VRAM de buffers (M62), draw calls por chunk (objetivo M61).

### 1.4 Viento (animación procedural)
- **Dominio:** vertex shader con desplazamiento senoidal por hoja; fase determinista = hash(instancia, semilla_chunk). Amplitude modulada por bioma (jungla baja, pampa alta) y clima (M32: viento fuerte → amplitud ×1.5).
- **Clave:** shader en GPU (costo constante por píxel, no por instancia); compatible con malla baja LOD (menos verts → más barato).

### 1.5 Interacción con jugador
- **Dominio:** tala (M08/M13) corta bloques de árbol → el follaje superior "cae" (tween de corta duración, determinista); hierba pisada transitoria (M11 interacciones); flores cosechables (M14/M15/M33) desaparecen del chunk y reaparecen por regla de regeneración (tiempo de mundo M29, límites por chunk).
- **Clave:** la interacción NO cambia el determinismo base del chunk (los cambios se guardan como deltas de M10).

### 1.6 Estaciones (tiempo de mundo)
- **Dominio:** M29 (calendario Aurora) define 4 estaciones; cada especie tiene variantes de color por estación con transición suave (matcap/soporte o shader de tint). Floración solo en primavera; hojas amarillas en otoño; nieve opcional en invierno.
- **Clave:** los cambios de estación se aplican con fade (no snaps) y la vegetación talada no reaparece por estación (solo por juego).

### 1.7 Terreno, agua y clima
- **Dominio:** pendiente (ácapes de vegetación), altura (línea de árboles), playa desnuda; plantas acuáticas/submarinas con rangos de profundidad relativos a M51; clima (M32) modula viento y puede cubrir de nieve.
- **Clave:** la vegetación se coloca al generar el chunk (M10) después del terreno (sin vegetación en agua ni en acantilados).

### 1.8 Validación técnica
- **Dominio:** `validate_vegetation.gd` en editor/CI (M118): recorre chunks de muestra, verifica densidad real vs tabla, presencia de LOD, presupuesto draw calls/memoria, y naming.
- **Clave:** también verifica que ninguna instancia esté dentro de agua/cueva (ruido de arte).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| MeshInstance por planta (escena por instancia) | **Descartado** | Draw calls explotando; MultiMesh obligatorio |
| Vegetación procedural en runtime con RNG | **Descartado** | Rompe determinismo M10; se genera al chunk (cache) |
| Árboles como mallas 3D no voxel | **Descartado parcial** | Árboles TALABLES = voxel (M08); decorativos pueden ser malla |
| Física por instancia (viento con bones) | **Descartado** | Coste CPU; vertex shader GPU |
| Un solo MultiMesh gigante mundial | **Descartado** | Culling complejo; por chunk es más simple |
| Viento con RNG por frame | **Descartado** | Determinismo; fase hash |

## 3. Decisiones del Módulo

1. **MultiMesh por especie × chunk** con culling + LOD 2 niveles.
2. **Densidad/distribución determinista** con PRNG de chunk (M10), clamps por pendiente/altura/profundidad.
3. **Viento GPU** con fase hash por instancia; amplitud por bioma/clima (M32).
4. **Tala voxel** para árboles talables (M08) + decorativas no destructibles (hierba transitoria).
5. **Estaciones** con variantes de color y transición suave (M29).
6. **Regeneración de interacción** guardada como delta (M10), nunca en el chunk base.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Draw calls por chunk desbordados | Alta | Alto | Presupuesto por chunk + LOD + culling; monitor M61 |
| Vegetación en agua/acantilados (arte sucio) | Media | Alto | Placement sobre terreno post-procesado + validador |
| Viento costoso en mallas altas | Media | Alto | LOD reduce verts; shader ligero |
| Reaparecer árboles talados por transición de estación | Media | Alto | Reglas de regeneración por eventos de juego |
| Densidad desigual entre chunks por mal hashing | Media | Medio | PRNG de chunk con seeds derivadas (M10) |
| Determinismo roto por eventos | Media | Alto | Deltas versionados (M10/M60) |