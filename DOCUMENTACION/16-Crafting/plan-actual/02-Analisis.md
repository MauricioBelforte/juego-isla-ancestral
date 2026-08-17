**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 16: Crafting

## 1. Análisis del Dominio

### 1.1 El crafting en juegos cozy
Los juegos cozy (Animal Crossing, Stardew Valley, Zelda cozy) usan el crafting como **motor de progresión emocional**: cada objeto fabricado es un recuerdo o una mejora de vida, no un número. Las palancas de calidad del género son:

- **Ritmo sin presión:** no hay reloj hostil ni colas de espera punitivas; la fabricación es un momento placentero.
- **Descubrimiento:** la alegría de "¡aprendí algo nuevo!" (recetas secretas, combinaciones inesperadas) es un pilar de rejugabilidad.
- **Contexto físico:** el crafting sucede en lugares (estación) y no en un menú global; esto ancla el mundo y da identidad (mesa, fogata, telar).
- **Consumo honesto:** el jugador sabe exactamente qué consume y qué recibe; sorprenderle gastando de más rompe la confianza cozy.

### 1.2 Dimensiones a decidir
1. **Origen del conocimiento:** recetas aprendidas (dadas/compars) vs descubiertas (experimentación).
2. **Tiempo de fabricación:** instantáneo vs con duración.
3. **Costo de experimentación:** se consume material en intentos fallidos vs solo en éxito.
4. **Catalogación de recetas:** el jugador conoce el catálogo completo o solo lo descubierto.
5. **Redundancia:** cómo evitar recetas que no aportan.

## 2. Alternativas Consideradas

### Alternativa A — Recetas aprendidas (solo compra/regalo)
El jugador obtiene recetas únicamente de tiendas, NPCs y cofres. No puede experimentar.

| A favor | En contra |
|---|---|
| Simple de implementar y balancear | Pierde la alegría del descubrimiento (pilar cozy) |
| Sin riesgo de combinaciones absurdas | El jugador "siente" que le faltan recetas que no compró |
| Fácil de monetizar/estructurar en M38 | Poco rejugable; depende 100 % de la economía M37 |

### Alternativa B — Recetas descubiertas por experimentación (solo)
Cualquier combinación de materiales válida produce una receta; el jugador prueba libremente.

| A favor | En contra |
|---|---|
| Máximo descubrimiento y sorpresa | Riesgo de frustración por combinaciones sin acierto |
| Sin dependencia de economía | Curva de aprendizaje desordenada; recetas importantes pueden no descubrirse |

### Alternativa C — Descubrimiento por experimentación + compra a NPCs (HÍBRIDA) — DECISIÓN
El jugador descubre recetas probando combinaciones de materiales en la estación correcta (con pistas sutiles), y además compra pergaminos de recetas a NPCs (M20/M38) para recetas específicas (secretas, ancestrales, avanzadas).

| A favor | En contra |
|---|---|
| Cubre ambos pilares: descubrimiento y economía | Requiere una tabla de combinaciones bien diseñada |
| Las recetas importantes tienen doble vía (nunca bloquean) | Algo más de datos que mantener (balance) |
| Las recetas secretas requieren experimentación fina → misterio | Cantidad de material de testing mayor |
| Da propósito a M38 (recetas como mercancía) | — |

**Decisión:** Alternativa C. Justificación: cumple el pilar cozy del descubrimiento sin bloquear a quien no quiera experimentar; la compra es la red de seguridad que mantiene la progresión principal siempre disponible.

### Alternativa D — Crafting con tiempo de espera (barra/cola)
Fabricar ocupa tiempo real (segundos/minutos), típico de juegos de gestión de colonias.

| A favor | En contra |
|---|---|
| Sensación de "proceso" real | Rompe el ritmo cozy si es largo |
| Fuel para economía (esperar = pagar) | Frustrante en un juego sin presiones |

### Alternativa E — Crafting instantáneo — DECISIÓN
Al confirmar, el resultado se entrega en el mismo frame con animación breve no bloqueante (SFX/VFX + pequeño rebote del ítem).

| A favor | En contra |
|---|---|
| Cero frustración, ritmo placentero | Menos "peso" de proceso (mitigado con animación y SFX) |
| Coherente con "sin combate, sin presión" | — |

**Decisión:** Alternativa E, reforzada con feedback audiovisual rico. Justificación: requisito explícito del usuario (sin tiempos de espera frustrantes — cozy) y del plan maestro ("crear creación individual / múltiple" sin mencionar tiempos).

### Alternativa F — Gasto de materiales en intentos fallidos
Cada experimento consume los materiales introducidos aunque la receta no exista.

### Alternativa G — Gasto solo en éxito — DECISIÓN
La experimentación no consume material al fallar (el jugador recupera todo); solo consume cuando la receta se conoce y se fabrica.

**Decisión:** Alternativa G. Justificación: evita destrozar el inventario del jugador con pruebas fallidas (anticozy); el costo real del crafting es el del objeto fabricado, y el experimento es gratuito, fomentando la curiosidad.

## 3. Decisiones de Diseño

### D1. Física de estaciones
Las estaciones son objetos voxel interactuables (M11) con una `CraftingStation` que define: tipo (mesa de trabajo, fogata, telar), recetas habilitadas y punto de aparición del resultado. El jugador se acerca y presiona Interactuar; la UI se abre con el set filtrado.

### D2. Modelo de recetas (dato)
`CraftingRecipe` como `Resource` inmutable: id, categoría, nivel, estación requerida, materiales `[{item_id, cantidad}]`, resultado `{item_id, cantidad}`, origen de desbloqueo (experimentar | comprar | evento), precio base de pergamino, tags (secret|ancestral|estacional|regional), pista de descubrimiento (texto cozy).

### D3. Conocimiento del jugador
El conocimiento es un conjunto de IDs de recetas en persistencia. La UI muestra categorías con candado: las recetas no conocidas aparecen como siluetas/sombras "?" con la pista de obtención (“Los aldeanos comentan que con fuego y arcilla se hace algo especial…”). Esto mantiene el misterio sin frustrar.

### D4. Experimentación
En la estación, modo "Experimentar": el jugador arma una combinación arbitraria de hasta N materiales (3 por defecto). Si existe una receta oculta con esa combinación exacta → se descubre y se fabrica. Si no → respuesta suave ("Nada parece encajar..."), sin gastar materiales.

### D5. Fabricación
Flujo: abrir estación → listar recetas conocidas → seleccionar → validar materiales contra M14 → consumir → entregar al inventario. Si el inventario está lleno y hay almacenamiento doméstico accesible, intentar el almacenamiento; si no, aviso y no se consume.

### D6. Recetas por tipo
- **Secretas:** descubrimientos con combinaciones poco obvias; feedback especial (partículas doradas).
- **Ancestrales:** relacionadas con deidades, se obtienen por ofrendas o compra en tienda ancestral (M38) o por experimentación con materiales ancestrales (M15).
- **Estacionales (M29/M73):** solo fabricables/catalogables durante su estación o evento; el conocimiento persiste, la receta se "activa" en cada temporada.
- **Regionales:** los materiales regionales (M15) las habilitan; un objeto pide materiales de varias regiones para reforzar el viaje por la isla.

### D7. Anti-redundancia (plan maestro: "evitar cientos de recetas redundantes")
Criterio de inclusión de una receta: debe verificar al menos UNA de las siguientes — sirve para progresión (herramienta/upgrade M13), decoración única de un bioma, ingrediente de otra receta, ofrenda a deidad, o venta justificada; caso contrario se descarta. Se prohíbe duplicar función con variación estética de otro ítem accesible más barato.

### D8. Creación múltiple
Botón "Crear xN": calcula el máximo `floor(disponibles / coste)` considerando stacks M14, y fabrica en un solo ciclo con un único sonido de confirmación y VFX por unidad. Limite superior QoL (30) para evitar accidentes.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Tabla de combinaciones desbalanceada (recetas imposibles) | Media | Editor/validación: script que verifica que toda receta conocible tenga combinación alcanzable con materiales existentes (M15) |
| Jugador cae en bucle de experimentación infinita | Media | Pistas textuales de obtención; compra de pergaminos con el catálogo "faltante" sugerido |
| Inventario lleno rompe el flujo | Baja | Política fallback a almacenamiento doméstico + aviso previo en la UI |
| UI pesada con muchas recetas | Baja | Cache de listas por estación; scroll virtualizado; filtros por categoría y "fabricables ahora" |
| Recetas estacionales confunden (desaparecen del listado) | Media | Siempre visibles como "?” con temporada indicada; nunca se borra el conocimiento |
| Costo material inflado por M37 | Media | Rango de precios definido por nivel; revisitado en balance M37 |

## 5. Conclusiones

El sistema combina: estaciones físicas con identidad (mesa/fogata/telar), recetas basadas en datos editables, desbloqueo híbrido (experimentación + compra), fabricación instantánea con feedback rico, consumo honesto (solo en éxito) y una regla anti-redundancia que protege el catálogo. Esto cumple los 25 puntos del plan maestro y los requisitos cozy del usuario.