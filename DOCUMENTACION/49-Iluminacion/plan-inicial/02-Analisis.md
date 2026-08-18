**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 49: Iluminación

## 1. Análisis del Dominio

El dominio de iluminación de Aurora se descompone en ocho subsistemas:

### 1.1 Iluminación global (WorldEnvironment)
- **Dominio:** el mundo exterior se ilumina por cielo procedural por bioma (M09) + tonemapping. Godot 4 Forward+ permite ambient, sky y tonemapping en un WorldEnvironment global.
- **Decisión clave:** tonemapping ACES con exponente sutil (cozy, no cinematográfico dark); gamma de referencia ~2.2; **regla anti-oscuridad de M31:** el ambiente nunca baja de un piso legible (0.15) incluso en PROFUNDA.

### 1.2 Sol y luna (luces direccionales)
- **Dominio:** las 5 franjas de M31 (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA) definen: posición de la direccional, intensidad, color (temperatura) y niebla asociada.
- **Soporte:** la franja activa la emite M31 (GameClock) → LightingService aplica la configuración por easing (no snaps).
- **Clave:** NO hay doble direccional; luna es la misma direccional con curva de color fría en NOCHE/PROFUNDA.

### 1.3 GI y baked lighting
- **Dominio:** el mundo voxel es abundante en superficies oclusivas (cuevas, interiores). La GI en tiempo real es cara (M61).
- **Decisión:** lightmaps (baked) para estáticos: casas (M18), templos (M24/M26), ruinas (M25), cuevas de eventos y estructuras ancladas (M25/M10). SDFGI/VoxelGI: solo prueba documentada en escena clave si presupuesto lo permite (proyecto prioriza determinismo y previsibilidad → default OFF).
- **Clave:** el horneado se ejecuta solo en build de release/CI (M118) con semilla fija; los dinámicos (burbuja M64, jugador, NPC) reciben luz ambiente y luz de interior por luces puntuales.

### 1.4 Iluminación dinámica
- **Dominio:** luces puntuales/spot: interiores vivos, faroles, fuego, cristales. Godot permite muchas en teoría; el coste real es fill-rate de sombras y overdraw.
- **Regla dura (M61):** ≤ N dinámicas con sombra por escena (ver 3.2); las demás sin sombra o pool; desactivación por distancia.

### 1.5 Atmósfera: niebla y clima
- **Dominio:** niebla por bioma (jungla densa, costa baja, mar), intensidad por franja y por clima (lluvia M32). Fog Godot con modo exponencial; niebla volumétrica NO (demasiado cara).
- **Clave:** la niebla es cohesión de estilo (cozy) y ocultación de LOD pop-in (M61), no solo estética → densidades por bioma predefinidas.

### 1.6 Sombras
- **Dominio:** sombras direccionales con ≤4 cascades; distancia dinámica según preset M90; bias fino para evitar acne del voxel; resolución 1024 por cascade en medio (M90), 2048 en alto.
- **Estilo cozy:** sombras suaves (pcf con al menos 4 samples) y sin siluetas negras → sombra ambiental rellena (ambiente no 0).

### 1.7 Accesibilidad y opciones
- **Dominio:** M58 pide reducir movimiento/estroboscopio; flicker suave (no strobe), y M90 permite desactivar luces (ej: "faroles off" para fotosensibilidad).
- **Clave:** todas las luces con flicker respetan una amplitud máxima por accesibilidad.

### 1.8 Validación técnica
- **Dominio:** `validate_lighting.gd` recorre las escenas del registro: cuenta luces dinámicas con sombra, comprueba piso ambiental mínimo, presencia de Sky/ambient, registro de presupuesto, y log WARN/ERROR accionables.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| SDFGI habilitada global | **Descartado** | Coste de frame y memoria altos (M61/M62); el mundo voxel escénico no lo justifica por defecto |
| Lightmap para TODO (mundo abierto entero) | **Descartado** | Tiempo de horneado y memoria insostenibles; solo estructuras/interiores |
| Niebla volumétrica | **Descartado** | Muy cara; la niebla exponencial de Godot basta para estilo y ocultación |
| Luz por instancia (una linterna = una luz) | **Descartado** | Explosión de overdraw; pool + distancia |
| Un solo preset de calidad de sombras | **Descartado** | M90 pide 4 presets; aquí solo se definen valores por preset |
| Flicker con RNG | **Descartado** | Rompe determinismo (M10); fase fija + semilla |

## 3. Decisiones del Módulo

1. **LightingService** (autoload): aplica configuración de luz por franja/clima/bioma con easing; único dueño de luces globales.
2. **Baked lightmaps** para interiores/estructuras; default OFF SDFGI/Volumetric.
3. **Tope de luces dinámicas con sombra ≤ 6 por escena** (pool, sin sombra las demás).
4. **Niebla exponencial** por bioma/franja/clima; ni volumétrica ni por xmlns.
5. **Sombras:** 4 cascades máx, bias voxel fino, resolución por preset M90, sombra ambiental rellena.
6. **Flicker determinista** y amplitude accesible (M58).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Overdraw de luces dinámicas en pueblo con faroles | Alta | Alto | Pool + tope con sombra + distancia de desactivación |
| Acne/shadows en el voxel tras cambios de mallas | Media | Alto | Bias fino + reverificación visual en el validador |
| Horneado de lightmaps desactualizado tras ediciones | Media | Medio | Build CI con bake (M118) y versión de bake en registro |
| Franjas horarias con snaps visuales | Media | Medio | Easing entre franjas (GameClock M31) |
| Cuevas ilegibles por niebla | Media | Medio | Niebla diferenciada interior/exterior + piso 0.15 |
| Coste de sombras en hardware medio | Media | Alto | Distancia dinámica por preset + pruebas M90 |