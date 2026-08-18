**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 51: Agua

## 1. Análisis del Dominio

El dominio del agua de Aurora se descompone en ocho subsistemas:

### 1.1 Tipos de agua (contenido)
- **Dominio:** 7 tipos: océano (nivel de mar global), río (flujo direccional), lago (estático con niveles), cascada (VF de caída), subterránea (cuevas M26), congelada (hielo estacional M29/M32), especial (termales/lagunas brillantes M47).
- **Clave:** cada tipo comparte el shader base (M47 `agua.gdshader`) con parámetros por tipo (color, olas, espuma, opacidad).

### 1.2 Nivel del mar y geografía
- **Dominio:** M09 define el nivel de mar (altura Y global) y la costa; M10 lo materializa por chunk. La consistencia entre chunks exige que el nivel de mar sea UN VALOR GLOBAL por semilla (no por chunk).
- **Clave:** los ríos se generan con splines en M10 (ancho, curva, pendiente) y aquí se les asigna flujo.

### 1.3 Render (coste y calidad)
- **Dominio:** el océano es el mayor gasto visual: mesh por chunk con olas en shader (GPU), espuma en la costa (altura de ola vs altura de costa), transparencia con depth_prepass (M47).
- **Reflejos:** ReflectionProbe es costoso (bake estático por escena); regla: ≤2 probes por escena, solo en lagos/vitrinas clave. Refracción: NO global (costo); solo pools pequeños de puzzles (M24).
- **Clave:** determinismo: fase fija (TIME) + semilla por cuerpo de agua; sin RNG.

### 1.4 Física y colisiones
- **Dominio:** el jugador (M11) flota con física suave (superficie como collider estático plano por chunk); los objetos sueltos (M70) flotan si densidad < agua (deltas de M10 guardan su posición flotante).
- **Clave:** el agua NO es un sólido voxel: es un plano de física en la superficie; los bloques de agua (M08) son para fuentes y puzzles.

### 1.5 Mecánicas de estado (inundación/drenaje/congelamiento/evaporación)
- **Dominio:** puzzles (M24) usan compuertas y canales (flujo direccional); la lluvia (M32) eleva lagos temporales (con tope, sin inundar zonas de juego); el invierno (M29/M32) congela lagos/rios con hielo caminable (límites de tiempo M31, sin softlock M66); el desierto evapora lagos efímeros.
- **Clave:** todas las transiciones son graduales (fade/easing) y deterministas por clima/estación.

### 1.6 Interacciones (herramientas, barcos, fauna, jugador)
- **Dominio:** balde/botella (M13/M15) llenan ítems de agua (M14); riego (M33); barcos (M28/M67) flotan con deriva por corriente; peces (M36/M65) nadan en el cuerpo de agua; el jugador nada (M11) con sprint costoso.
- **Clave:** el agua transportada nunca es infinita (cantidad por ítem M14) y no genera agua procedural ilimitada.

### 1.7 Sonido y partículas
- **Dominio:** olas (por bioma/franja M42), chapoteo (entrar/salir, balde), cascada (loop con intensidad), hielo (crujido al caminar); partículas (M52): salpicadura de pies, rocío de cascada, gotas al salir.
- **Clave:** los eventos se sincronizan con la animación (M48) y se rigen por M42/M44 (volumetría cozy).

### 1.8 Optimización y validación
- **Dominio:** mesh por chunk con LOD (lejanía: mesh plano sin olas), culling; la transparencia es el costo dominante (overdraw) → presupuesto por escena (M61).
- **Clave:** `validate_water.gd` comprueba nivel de mar consistente, presupuesto, y determinismo (fases).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Océano como bloque voxel masivo | **Descartado** | Coste y arte inconsistente; plano con shader |
| Refracción global | **Descartado** | Costo altísimo (M61); solo pools pequeños |
| ReflectionProbe por todo el océano | **Descartado** | Coste; solo ≤2 por escena |
| Física del agua por partículas (fluid) | **Descartado** | Complejidad innecesaria; cozy no requiere simulación |
| Ríos como bloques estáticos | **Descartado** | Flujo inexistente; se usan splines con corrientes |
| Hielo permanente en zonas frías | **Descartado** | Estacional (M29) + límites anti-softlock (M66) |

## 3. Decisiones del Módulo

1. **Nivel de mar global** por semilla (M09/M10), consistente entre chunks.
2. **Mesh por chunk** con olas GPU + espuma costera + transparencia con depth_prepass.
3. **Reflejos ≤2 probes por escena; refracción solo en pools de puzzles (M24).**
4. **Corrientes por spline de río** (M10) que mueven objetos (M70) y barcos (M28/M67).
5. **Estado del agua por clima/estación** (M29/M32): congelamiento, inundación, evaporación — siempre graduales y sin softlock (M66).
6. **Física de superficie plana** por chunk para flotación (M11/M70).
7. **Determinismo total:** fases fijas + semilla por cuerpo de agua.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Overdraw de transparencia en océano grande | Alta | Alto | Presupuesto por escena + LOD de mesh + depth_prepass |
| Nivel de mar inconsistente entre chunks | Media | Alto | Valor global + validación con semillas de prueba |
| Hielo que atrapa al jugador (softlock) | Media | Alto | Límites de tiempo + reglas M66 |
| Corrientes que desvían al jugador injustamente | Media | Medio | Fuerza de corriente suave, excepción cozy (M11/M70) |
| Reflejos caros mal calibrados | Media | Medio | ≤2 probes + prueba en hardware M90 |
| Ríos que cruzan terreno de forma visualmente rota | Media | Alto | Generación de splines en M10 + validador de pendiente |