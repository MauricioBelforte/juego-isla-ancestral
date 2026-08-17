**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 35: Minería

## 1. Análisis del Dominio

La minería en juegos cozy (Animal Crossing, Story of Seasons, Zelda cozy) no busca desafío físico ni riesgo, sino una **actividad satisfactoria que produzca recursos siempre disponibles**. En un mundo voxel (M08) la minería natural es la edición de bloques: el problema es decidir qué se puede editar, durante cuánto tiempo y con qué recompensa, sin romper el paisaje ni permitir farmeo infinito instantáneo.

## 2. Alternativas y Decisiones

### D1. Vetas regenerables vs vetas fijas (permanentes)

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A. Vetas fijas (se agotan para siempre) | Simple de implementar, mundo "realista" | Contradice el cozy: el jugador castiga el paisaje y se queda sin recursos; requiere rebalanceo constante |
| B. Regeneración por tiempo real | Siempre hay recursos al volver | Diseño de sesiones cortas; castiga al que no juega seguido |
| C. Regeneración por tiempo de juego (días M29/M30) | Ritmo controlado por sesión; el jugador decide cuándo regresar | Requiere persistencia de temporizadores |

**Decisión: C.** Las vetas reaparecen tras N días de juego (2-3 días según rareza). Es compatible con el reloj M30, con pausas (congela timers) y con el determinismo PRNG de M29. El jugador nunca queda sin recursos si explora otras zonas, y no se siente presionado a jugar todos los días.

### D2. Golpe por golpe (Minecraft) vs golpe único animado vs golpes limitados

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A. Golpe por golpe infinito con dureza real | Sensación de trabajo | Aburrido y repetitivo en cozy; fricción innecesaria |
| B. Un solo golpe con animación | Rápido y directo | Sin sensación de progreso ni incentivo de picos mejores |
| C. Golpes limitados (2-4 según dureza del mineral) | Ritmo táctil, corto y satisfactorio; el pico mejora agiliza | Requiere dureza por mineral |

**Decisión: C.** Cada bloque de veta requiere 2 a 4 golpes según la dureza definida en OreDefinition. El pico superior (M13) puede extraer en menos golpes (eficiencia RF6). La cadencia se logra con cooldown de 0.6 s, swing animado y partículas, sin llegar a la repetición tediosa.

### D3. Edición directa del voxel (M08) vs vetas como prefabs separados

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A. Bloques dentro del voxel de M08 | Coherente con el mundo editable; colisiones y mesh unificados | Acoplado a la API de edición de M08 |
| B. Nodos prefab flotantes sobre el terreno | Independiente del voxel | Rompe la estética voxel; colisiones duplicadas; el jugador no puede ver la veta "de verdad" |

**Decisión: A.** Las vetas son bloques especiales del voxel (capa de mineral). OreVein es un nodo liviano de **estado** (posición, mineral, golpes restantes, temporizador) que no duplica geometría: la geometría vive en el chunk de M08 y el remeshing se hace diferido y localizado.

### D4. Drop probabilístico vs drop fijo por veta

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A. Drop fijo (siempre el mismo mineral, cantidad fija) | Predecible y simple | Sin momento de sorpresa; farmeo calculable |
| B. Drop probabilístico con rareza y doble drop | Sorpresa gratificante; el pico mejora la probabilidad (RF6) | Requiere balance |

**Decisión: B.** Tabla de drops con cantidad mínima/máxima y chance de doble drop escalada por el poder del pico. La rareza del mineral sube con la profundidad; el mineral ancestral (M26) tiene drops bajos pero muy valiosos.

### D5. Minería infinita vs límites diarios

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A. Sin límites | Cero fricción | Farmeo intensivo; la economía (M36) se satura; el juego se vuelve repetitivo |
| B. Límite duro diario | Protege la economía | Frustrante; contradice el cozy |
| C. Límite suave por zona con respawn lento | Desalienta sin prohibir; obliga a explorar otras zonas | Más lógica de estado |

**Decisión: C.** Cada zona de minería tiene un tope suave de extracciones por día de juego; al superarlo las vetas de esa zona todavía golpean pero dan fábula ("No queda nada brillante aquí hoy"), fomentando la exploración (RF10). El respawn lento (D1) completa el ciclo.

### Resumen de alternativas descartadas

1. **Vetas fijas permanentes (D1-A):** descartada por contraer el espíritu cozy y matar la disponibilidad de recursos.
2. **Golpe único sin dureza (D2-B):** descartada por eliminar el incentivo de progresión de herramientas M13.
3. **Prefabs flotantes sobre el voxel (D3-B):** descartada por romper coherencia visual, física y de edición del mundo.
4. **Drop fijo sin probabilidad (D4-A):** descartada por eliminar la sorpresa y la escalabilidad con picos superiores.

## 3. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Remeshing costoso al editar el voxel | Remeshing diferido y solo del chunk afectado (cola en MiningManager) |
| Respawn en zona ocupada (construcción M17, otro bloque) | Validación de ocupación antes de reaparecer; reintento en siguiente tick |
| Jugador parado sobre la veta al regenerar | Desplazamiento suave de 0.5 bloques al espacio libre más cercano |
| Explotación de guardado/carga para resetear temporizadores | Persistencia del estado por veta con tiempo restante acumulado |
| Inconsistencia con el catálogo de M15 | Minería consume OreDefinition que referencian los recursos de M15 (cobre, hierro, oro_ancestral, cristal_estacional) |

## 4. Conclusiones

El sistema se apoya en cuatro piezas: definiciones (OreDefinition), estado de veta (OreVein), herramienta (MiningTool en el pico de M13) y orquestador (MiningManager, autoload). La regeneración por tiempo de juego con validación de ocupación resuelve el requisito de "sin agotamiento permanente" manteniendo la economía sana. Todo queda desacoplado de la UI.