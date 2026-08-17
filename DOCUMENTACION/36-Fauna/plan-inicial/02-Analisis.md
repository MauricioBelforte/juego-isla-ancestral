**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 36: Fauna

## 1. Problema de Diseño

En un cozy game sin combate obligatorio, la fauna debe ofrecer **interés y coleccionismo sin explotación**. La pregunta central: ¿cómo se relaciona el jugador con los animales? La respuesta define el loop de juego, la integración con museo/fotografía y todo el sistema de comportamiento.

## 2. Alternativas Evaluadas

### A1. Captura y recolección (estilo Animal Crossing)
Redes, cañas y jaulas para "atrapar" criaturas guardándolas en la mochila y entregándolas al museo.

- **Ventajas:** loop probado, recompensa táctil, colección física.
- **Desventajas:** contradice por completo el tono del juego (deidades ancestrales, respeto a la naturaleza, cero daño); las especies "atrapadas" chocan con la fantasía de observación; demandan animaciones de captura, estados de inventario y colisiones de red; el usuario pidió explícitamente fauna no cazable.

### A2. Solo avistamiento con diario (sin fotografía)
El jugador se acerca, el registro del diario ocurre automáticamente al tener cerca a la especie.

- **Ventajas:** cero fricción, menos esfuerzo técnico.
- **Desventajas:** pierde el componente activo y la recompensa de "logro"; la cámara (M56) existe en el juego y quedaría infrautilizada; el avistamiento automático quita la satisfacción de la espera y la paciencia (núcleo cozy).

### A3. Crianza y amistad (alimentar, mascotas, crías)
Alimentar a los animales, ganar su confianza, criar camadas y mascotas personales.

- **Ventajas:** máxima cercanía emocional, potencial de vínculo fuerte.
- **Desventajas:** gran esfuerzo (estados de confianza, reproducción M-animales, vínculo persistente); puede derivar en "farmeo" de crías (exploit); duplica sistemas de M65 (reproducción ya contemplada ahí); no resuelve el coleccionismo global que el museo M37 necesita.

### A4. Avistamiento + fotografía + registro en diario (ELEGIDA)
Los animales se observan y se fotografían (M56). Cada especie se registra en el diario al ser avistada (con dedupe) y se marca FOTOGRAFIADA al capturarla en foto; las fotos alimentan el museo (M37).

- **Ventajas:** coherente con el tono (observación respetuosa); la cámara ya existe (M56); premia la paciencia y el acercamiento lento; colección del museo sin "capturar" nada; perfecta sinergia: huida suave -> quietud -> foto; rejugabilidad por especies raras condicionadas a clima/estación/hora.
- **Desventajas:** requiere que M56 reporte qué especie capturó (contrato de integración claro); riesgo de frustración si es muy difícil — mitigado con rarezas escalonadas y pistas en el diario.

## 3. Comparación de Criterios

| Criterio | A1 Captura | A2 Solo diario | A3 Crianza | A4 Avistamiento + Foto |
|---|---|---|---|---|
| Coherencia cozy (cero daño) | Mala | Buena | Buena | **Excelente** |
| Coherencia con deidades/ancestros | Mala | Buena | Regular | **Excelente** |
| Esfuerzo técnico | Alto | Bajo | Muy alto | **Medio** |
| Rejugabilidad (especies raras) | Media | Baja | Media | **Alta** |
| Sinergia con M56 Fotografía | Sin uso | Sin uso | Parcial | **Total** |
| Oportunidades de museo M37 | Física | Ficha | Vínculo | **Ficha + foto** |
| Riesgo de exploits | Alto (farmeo) | Nulo | Alto (crías) | Nulo |

## 4. Decisión Final y Justificación

**Se implementa A4: avistamiento + fotografía + registro en diario.**

1. **Respeto ecológico total:** el jugador nunca daña; la huida suave es la única "defensa" animal y el acercamiento lento la única "llave".
2. **La cámara ya es un sistema separado (M56):** conectar avistamiento-foto es un contrato de señal, no un sistema nuevo.
3. **El museo (M37) pide colección:** fotografías y fichas de especies completan salas sin vitrinas con animales vivos.
4. **La rareza se diseña por condiciones (clima/estación/hora),** no por droprate de caza: la Lombriz Luminosa "solo tras lluvia" es un misterio por descubrir, no un drop.
5. **Determinismo y presupuesto** se mantienen simples: no hay inventario de criaturas ni estados por individuo — solo recuento de avistamientos por especie.

## 5. Decisiones de Diseño Secundarias

| Decisión | Justificación |
|---|---|
| Comportamiento por 4 personalidades (HUIDA INSTINTIVA / HUIDA SUAVE / CURIOSO / PASIVO) | Diferenciación legible por el jugador; cada especie ajusta distancias y velocidades |
| Especies raras condicionadas al clima (M32) | Misterio estacional; recompensa a quien explora con lluvia/noche/luna llena |
| Dedupe por instancia (+ fecha) | Evita spam del mismo individuo; única entrada por especie por encuentro |
| Fotografía como máximo nivel de registro | Orden: NO_AVISTADA -> AVISTADA -> FOTOGRAFIADA |
| Manadas pequeñas (2-5) solo en especies gregarias | Evita "murallas" de fauna; coste de IA contenido |
| Spawn determinista por PRNG M29 | Reproducibilidad y coherencia entre guardados |
| Filtros del spawner consultados a M09 (bioma) y M31/M32 (hora/clima) | El contenido de la especie es puro dato; la lógica de filtrado vive en el spawner |
| Presupuesto: 40 activos en burbuja, despawn 96 m | Frame budget estable; burbuja igual que M64/M65 |

## 6. Alternativas Descartadas (resumen)

- **A1 Captura estilo Animal Crossing:** descartada por tono (cero daño) y por el principio del usuario de fauna no cazable. Se menciona como referencia para M37 (vitrinas se llenan con fotografías, no con animales).
- **A2 Solo avistamiento automático:** descartada por perder recompensa activa y sinergia con M56.
- **A3 Crianza/amistad completa:** descartada por esfuerzo y riesgo de exploit; la confianza queda como reto futuro (ver 5-FUTURAS-MEJORAS si el usuario lo pide), no forma parte de M36.
- **Simulación completa de todos los animales del mapa:** inviable por presupuesto; se usa burbuja + receta ligera (ligada a M65).