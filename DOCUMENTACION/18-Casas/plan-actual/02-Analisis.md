**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 18: Casas

## 1. Problema de diseño

La casa combina un componente externo en el mundo voxel (visible desde la isla, construible con M17) y un componente interno (habitaciones, muebles, almacenamiento). La pregunta central es cómo conviven ambos mundos: si el interior vive dentro del mundo abierto o en un espacio separado, y cómo se mantiene la coherencia (decoración, guardado, visitas, rendimiento).

## 2. Alternativas analizadas

### Alternativa A: Interior instanciado por portal (escena separada por casa)

Cada casa del mundo es un "portal": al cruzar la puerta se carga una escena interior dedicada (una por casa), fuera del mundo voxel. Es el enfoque de Animal Crossing y de la mayoría de cozy games.

- **Pros:** rendimiento predecible (interior aislado, cero coste en el mundo exterior); decoración libre sin voxel constraints; cámara interior dedicada; streaming sencillo; menor complejidad de colisiones.
- **Contras:** el interior no es "real" en el mundo (no se ve desde afuera); transición con pantalla de carga (mitigable con fundido); coordinación de visitas NPC requiere teletransportar lógica; latencia en la entrada/salida.

### Alternativa B: Interior persistido en el mundo (casa completa construida en voxel)

La casa se construye entera con bloques voxel (M17) y el interior es un espacio real dentro del mundo: techo removible o sección transversal para ver dentro, jugador y muebles son voxels.

- **Pros:** máxima coherencia con el mundo; se ve desde afuera; sin transiciones; los NPC navegan naturalmente hacia dentro.
- **Contras:** costo de renderizado y meshing del interior siempre activo; cámara dentro de espacios pequeños (clipping); decoración limitada a grid voxel grueso; escalado de muebles difícil; rendimiento pobre en mundo modificado masivamente (riesgo M61).

### Alternativa C: Híbrido con miniatura exterior + isla interior compartida

Modelo exterior en el mundo + un único "espacio interior de la casa" aparte, con salas por habitación. Mezcla de A y B.

- **Pros:** mejor que A en coherencia visual de vecinos (no tan bueno como B); mejor que B en rendimiento.
- **Contras:** complejidad de coordinación alta (qué interior es cual, jugadores/vecinos en ambos lados); estado duplicado (exterior vs interior); más superficie de bugs; sin ganancia clara frente a A.

## 3. Decisión y justificación

**Se elige la Alternativa A: interior instanciado por portal (escena separada por casa).**

Justificación:

1. **Rendimiento (M61):** el mundo voxel abierto ya tiene presupuesto apretado (chunks, cargas y streaming). Un interior instanciado elimina de raíz el costo de meshing, colisiones y render de interiores.
2. **Calidad cozy:** el juego prioriza la sensación hogareña: cámara interior controlada, luz cálida por habitación, sin clipping, y decoración con libertad (grid fino de 1/4 de bloque interior frente al grid voxel grueso). Es el estándar del género (Animal Crossing) y donde mejor se logra polish.
3. **Simpleza de guardado:** el estado de una casa se serializa como datos (etapa, habitaciones, muebles con posición/rotación, slots de almacenamiento) sin depender del estado de chunks del mundo.
4. **Vecinos (M19):** las visitas se modelan como un evento controlado por la casa (quién entra, cuándo sale), sin navegación compleja interior-exterior.
5. **Mitigación de la transición:** el costo es un fundido de 0.5 s con carga asíncrona de la escena interior; la casa exterior es un nodo ligero siempre presente.

Alternativa B queda descartada por costo de renderizado, pero se reserva como patrón opcional para "cabañas de exploración" pequeñas en futuras mejoras (M5). Alternativa C se descarta por duplicación de estado sin beneficio claro.

## 4. Decisiones derivadas

| Tema | Decisión | Justificación |
|---|---|---|
| Interior | Escena instanciada por casa (portal en la puerta) | Aisla rendimiento y permite cámara/decoración de calidad |
| Carga | Asíncrona con fundido y deshabilitar input durante transición | Evita congelamiento (regla 8 de AGENTS.md) |
| Grid interior | Celdas de 0.25 bloques (grid fino) sobre plano de sala | Decoración precisa sin el costo voxel completo |
| Etapas | Mejoras discretas definidas por recursos `HouseUpgradeData` | Progresión clara y balanceable |
| Guardado | Datos por IDs de mueble y habitación; versión de esquema | Save compacto (M58) |
| Almacenamiento | Slots por mueble + panel integrado con M14 | Sin sistema de contenedores paralelo |
| Visitas | Evento `EntrarVisita`/`SalirVisita` manejado por House (M19) | Coordinación centralizada con horario M29 |
| Reubicación | Mover la casa exterior conservando todo el interior | El jugador no pierde decoración |

## 5. Alternativas descartadas (resumen)

1. **Interior persistido en voxel (B):** costo de renderizado y streaming inaceptable en mundo abierto; decoración voxel gruesa.
2. **Híbrido miniatura + interior compartido (C):** duplicación de estado y superficie de bugs alta; sin ganancia sobre A.
3. **Almacenamiento global de red propio:** se usa el mueble-contenedor con slots (integración M14) en lugar de una "nube doméstica" que desvirtúa el cozy.
4. **Ampliación libre por bloque (estilo M17 puro):** para la casa se usan etapas definidas; la libertad total queda para el modo construcción exterior.

## 6. Riesgos y mitigaciones

- **Transición molesta:** mitigada con fundido corto y carga asíncrona (reusa patrones de M63).
- **Visita de vecino durante reubicación:** la casa cancela visitas pendientes y avisa con diálogo (M21) antes de mover.
- **Mudanza de muebles con objetos dentro:** al levantar un mueble, su contenido se intercepta (va al inventario) o se muestra aviso antes de confirmar.
- **Obra en curso:** el interior queda inaccesible hasta el día siguiente (progreso por M29), con cartel indicador.

## 7. Análisis de densidad espacial (2026-11-12, ERNIE-5.5-Flash-Preview)

> **Actualización:** §7.1–7.5 describen v1 (16×12 / 22×16); la versión vigente es §7.6 (20×15 / 28×20, 0 solapes).

### 7.1 Problema

La primera versión de las casas grandes (10×8 m y 14×10 m) concentraba ~600–845 objetos en plantas de 80–140 m². El usuario reportó que "se siente apretado para un juego". La causa no era la cantidad de objetos en sí, sino la **densidad**: 1,5–2,5 objetos/m² y pasillos de menos de 1 m entre muebles.

### 7.2 Alternativas analizadas

| Alternativa | Pros | Contras |
|---|---|---|
| A. Reducir objetos | Baja la densidad de inmediato | Pierde la sofisticación pedida |
| B. Agrandar las casas (elegida) | Mantiene objetos y da aire; permite habitaciones reales | Más tris y draw calls; exige LODs |
| C. Escalar muebles a 0,8× | Rápido | Techos/muebles desproporcionados; se nota "casa de muñecas" |

### 7.3 Decisión

Agrandar las casas a **16×12 m (Casona del Gremio)** y **22×16 m (Mansión del Museo)**, con habitaciones de 5×4 a 8×11 m, techos de 3,4/3,8 m y circulación ≥1,2 m. Se mantiene la cantidad de objetos, pero la densidad baja a ≈1,2–1,6 objetos/m².

### 7.4 Métricas medidas

| Casa | m² por planta | Plantas | Objetos | Densidad |
|---|---:|---:|---:|---:|
| Casona del Gremio | 192 | 2 | 608 | 1,58/m² |
| Mansión del Museo | 352 | 2 | 845 | 1,20/m² |

### 7.5 Consecuencias

- El kit de muebles actual (M18) sigue siendo válido; solo cambia la **distribución**.
- Las casas grandes se modelan como **exterior + interior separados** para no superar el presupuesto de 6.000 tris por volumen.
- El techo y la fachada frontal se modelan como objetos aparte para la vista de muñeca.

### 7.6 Actualización v2 (2026-11-12)

El usuario reportó que las casas seguían apretadas y con objetos superpuestos. Se midió el solape real con AABB en Blender y se rediseñó:

- **Casona 20×15 m** (300 m²/planta) y **Mansión 28×20 m** (560 m²/planta).
- **568 / 826 piezas**; densidad **1,89 / 1,48 piezas/m²** (frente a 3,17 / 2,40 en v1).
- **0 solapes mueble-estructura** y **0 mueble-mueble** (excluyendo uniones intended: chimenea-techo, base/respaldo, tapa/cuerpo de piano, anillos de la esfera armilar).
- Techos de **3,6 m** (Casona) y **4,0 m** (Mansión); habitaciones de 6,5×5 a 9,5×14 m.
- La corrección se aplicó sobre los 7/13 solapes reales que quedaban tras el primer rediseño (armarios, vitrinas, chimeneas, armadura y araña).