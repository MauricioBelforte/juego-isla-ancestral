**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 33: Agricultura

## 1. Dominio del problema

La agricultura cozy exige resolver tres tensiones clásicas del género:

1. **Ritual vs presión:** regar cada día es un ritual que da satisfacción, pero castigar el olvido (planta muerta) contradice la filosofía del proyecto (M152: sin castigos irreversibles).
2. **Simulación vs simplicidad:** el jugador debe entender por qué un cultivo no crece sin leer manuales ni memorizar tablas.
3. **Mundo voxel vs vegetación:** el mundo es voxel por bloques (M08, Voxel Tools), pero los cultivos se ven mejor como mallas instanciadas encima del bloque; hay que decidir dónde vive cada representación.

## 2. Alternativas analizadas

### A1. Riego: manual obligatorio vs manual con lluvia automática vs automático total

| Opción | Ventajas | Desventajas |
|---|---|---|
| A1a. Riego manual obligatorio | Ritual clásico, valor del tiempo | Presión, castigo al olvido, molesto |
| A1b. Manual + lluvia del clima (M32) | El clima ayuda sin quitar el ritual; sin agua = pausa (no muerte) | Requiere integración M32 (ya delegable) |
| A1c. Riego automático infinito (aspersores gratis) | Cero fricción | Pierde el ritual; contenido vacío |

**Decisión: A1b.** El agua se modela como un nivel por cultivo (0..2). Regar llena el nivel; la lluvia lo llena también. Si el nivel llega a 0 al final del día, el cultivo **no muere**: pausa su crecimiento con un cartel amable ("Echó de menos el agua"). Esto conserva el ritual y cumple M152.

### A2. Cultivos que se marchitan y mueren vs cultivos que nunca mueren

| Opción | Ventajas | Desventajas |
|---|---|---|
| A2a. Marchitamiento con muerte | Realismo, stakes | Castigo irreversible, anti-cozy, usuarios pierden partidas |
| A2b. Marchitamiento reversible (seca, revive al regar) | Tensión suave + recuperación | Riesgo de confusión visual entre "seco" y "podrido" |
| A2c. Solo pausa de crecimiento | Máxima calma, regla de oro | Menos profundidad de gestión |

**Decisión: A2c** como base (pausa, nunca muere), **con matiz A2b opcional** vía fertilizante mal aplicado: el único "marchitamiento" posible es temporal, reversible regando, y solo aparece si el jugador lo provoca experimentalmente (etiquetado claramente). Documentado en M152 como desviación benigna.

### A3. Estaciones: cultivos que mueren en invierno vs cultivos que se pausan

| Opción | Ventajas | Desventajas |
|---|---|---|
| A3a. Muerte estacional | Realismo agrícola | Castigo, frustración |
| A3b. Estado DORMANTE (pausa) | Cozy, aprendible, coherente con A2c | Menos realista |

**Decisión: A3b.** Cada CropDefinition declara `star` y `end` de estaciones (del calendario M29). Fuera de su ventana, el cultivo entra en DORMANTE: no crece, no muere, visual de reposo (hojas cerradas, tono apagado). Al volver la estación apta, reanuda donde quedó. Unívoco y tranquilo.

### A4. Representación: bloque voxel vs entidad instanciada encima

| Opción | Ventajas | Desventajas |
|---|---|---|
| A4a. Todo como bloques del catalogo (Voxel Tools) | Integrado con el mundo, diffs por chunk | Modelos de plantas pobres, costo de mesh por chunk, difícil animar |
| A4b. Tierra = bloque del catalogo; planta = instancia 3D (VoxelInstanceModifier/MultiMesh) | Planta animable, barata (instancing), desacople visual | Dos sistemas a sincronizar (bloque + instancia) |

**Decisión: A4b.** La tierra arada es un **bloque** del catálogo M08 (`TIERRA_ARADA`, con variante húmeda) porque afecta colisiones, terreno y diffs de chunk. El cultivo (planta) es una **instancia** registrada por coordenada voxel; el FarmService mantiene el diccionario posición→CropTile y el visual se concreta en un MultiMesh agrupado por etapa y especie.

### A5. Avance: tiempo continuo vs por días del calendario

| Opción | Ventajas | Desventajas |
|---|---|---|
| A5a. Crecimiento en tiempo real continuo | Sensación viva | Inconsistente con pausa/guardado; explotable |
| A5b. Avance por salto de día (M29) | Determinista, simple, coherente con GameClock | El jugador nota el salto (se usa para estado de mariposas) |
| A5c. Híbrido (días + bono por horas de riego) | Matiz fino | Complejidad innecesaria para el target |

**Decisión: A5b.** FarmService se suscribe a `calendar_day_advanced` de M29 y aplica `advance_day()`. Las horas intermedias solo afectan feedback visual (sin progreso acumulable). Regla anti-exploit: el conteo usa el índice de día del guardado, no el reloj real (M30 queda fuera).

### A6. Comida: sistema de hambre vs comida opcional

| Opción | Ventajas | Desventajas |
|---|---|---|
| A6a. Hambre con penalización | Tira de la agricultura "por necesidad" | Contra M152 y el encargo: comida opcional |
| A6b. Hambre informativa sin castigo (ya descontada en M152) | Contexto sin presión | No aporta al módulo |
| A6c. Comida 100% opcional (venta/recetas/regalos) | Cozy puro, libertad total | Toca balancear precios (M38) para que la agricultura sea atractiva sin obligación |

**Decisión: A6c.** No existe minusvalía por no comer. La cosecha alimenta la economía cozy (M38): venta, recetas M16, regalos a NPC (M19/M20), festivales (M29/M74). Un tutorial amable lo dice explícito desde la primera semilla.

### A7. Fertilizante y calidad: sistemas de 3 niveles vs binario

**Decisión:** 3 calidades (COMUN, BUENA, EXCELENTE) sin probabilidad oculta: la calidad depende de condiciones legibles por el jugador (riego constante + fertilizante si se desea + estación exacta). Los precios (M38) premiarán calidad sin que sea obligatorio optimizar. Cultivos ancestrales e híbridos se explican en RF10 como desbloqueables de progresión (M22), no como requisito.

### A8. Piso y almacenamiento del cultivo

**Decisión:** los cultivos no se "almacenan" como entidades: al cosechar se emiten ítems al inventario (M14), y las bolsas de semillas son el único ítem que produce semillas nuevas (reproducción a cuenta, por cultivo, con rendimiento declarado). Sin inventario infinito de plantas.

## 3. Decisiones finales (resumen)

| Decisión | Elección | Justificación |
|---|---|---|
| Riego | Manual + lluvia automática (M32); sin agua = pausa | Ritual conservado, castigo eliminado |
| Marchitamiento | No existe muerte; único estado reversible posible vía experimento | Regla de oro M152 |
| Estaciones | DORMANTE (pausa) fuera de ventana | Cozy y aprendible |
| Representación | Tierra = bloque M08; planta = instancia (MultiMesh) | Rendimiento + animación |
| Avance | Por salto de día (M29), determinista | Coherente con GameClock |
| Comida | Opcional (venta/recetas/regalos); sin hambre | Encargo explícito |
| Calidad | 3 niveles legibles, sin RNG oculto | Transparencia cozy |
| Almacenamiento | La cosecha entra a M14 al instante | Sin inventario de plantas |

## 4. Alternativas descartadas documentadas

1. **A1c (riego automático infinito):** elimina el ritual y el encanto de la lluvia; se descarta.
2. **A2a (muerte por sequía o invierno):** castigo irreversible; se descarta por M152 y el tono del juego.
3. **A4a (planta como bloque voxel):** cara en mesh/animación y pobre para el estilo cozy; se descarta.
4. **A5a (crecimiento en tiempo real):** rompe determinismo, pausa y guardado; se descarta.
5. **A6a (hambre castigadora):** contradice el encargo y M152; se descarta.