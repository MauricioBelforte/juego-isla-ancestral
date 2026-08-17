**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 19: NPC y Vecinos

## 1. Análisis del Dominio

El género cozy (Animal Crossing, Stardew Valley, My Time at Portia) sostiene su experiencia social en tres pilares:

1. **Población limitada y con identidad:** pocos vecinos, cada uno reconocible por especie, personalidad y casa. La memoria del jugador hacia ellos crea apego (el plan maestro lo exige: "El jugador debe recordar a los NPC").
2. **Vida cotidiana visible:** los vecinos se mueven con propósito aparente: trabajan, comen, pasean, duermen. Un vecino que nunca cambia de lugar rompe la ilusión de mundo vivo.
3. **Interacción significativa:** hablar (diálogo), regalar (afinidad), observar reacciones. Las reacciones a regalos y el tono de charla son el canal principal de feedback social.

En *Isla Ancestral* estos pilares se combinan con el mundo vóxel (Godot 4.4.1 + Voxel Tools GDExtension): los vecinos deben navegar terreno destructible y sus hogares son parcelas construidas/terrenos. El módulo 19 es la **capa de datos y comunidad**, mientras que la **capa de movimiento y decisiones de alto nivel** pertenece a M64 (IA de NPC), que ya está diseñada y consume este módulo.

El dominio identifica además un riesgo clásico: **población estática = aburrimiento**. Animal Crossing resuelve con rotación de vecinos. Este proyecto adopta la misma filosofía con matiz más amable: la salida de un vecino nunca es forzosa y la entrada siempre exige permiso del jugador (cozy ante todo).

## 2. Alternativas Consideradas

### A1. Vecinos fijos (siempre los mismos 10)
- **Ventajas:** mayor control narrativo; historias profundas con continuidad garantizada; menos complejidad de gestión.
- **Desventajas:** la isla envejece; el jugador pierde interés al conocer todo; rejugabilidad baja; choca con el plan maestro ("crear historias de vecinos", "nuevos vecinos", "NPC viajeros").
- **Decisión:** DESCATADA como modelo único. Se usa rotación (A2).

### A2. Vecinos rotativos con ciclo de entrada/salida (elegida)
- **Ventajas:** renovación de contenido, rejugabilidad, permite "NPC viajeros" (sección 18), sorpresa constante; el jugador conserva a sus favoritos rechazando salidas o priorizando entradas.
- **Desventajas:** gestión extra (plaza libre, avisos, persistencia), riesgo de que el jugador pierda a un vecino querido.
- **Mitigación:** la salida se anuncia con antelación (1 día) y se puede rechazar; la entrada siempre requiere aprobación explícita del jugador; ningún vecino se va por abandono del jugador.

### A3. Población máxima: 8 vs 10 vs 12
- **Justificación de 10 (rango 8-12):** 8 es el mínimo viable para sentir comunidad; 12 es el techo práctico de atención del jugador (memorizar e interactuar). 10 equilibra densidad de isla y frame budget de agentes (M64 permite hasta 60 a plena IA; la isla con 10 vecinos queda holgada). El rango 8-12 permite escalar según tamaño de la isla.

### A4. IA compartida vs IA por NPC
- **IA compartida (elegida):** un solo sistema de agente (M64) consume *perfiles de datos* de este módulo. Los NPCs no llevan lógica de comportamiento incrustada; llevan datos (rutina, gustos, personalidad).
- **Justificación:** evita duplicar código, permite presupuesto centralizado (burbuja 64 m, receta ligera), y mantiene el desacople de la sección 9 de AGENTS.md (gameplay separado de UI).

### A5. Datos de vecino en escena vs recursos `.tres` (Godot)
- **Elegida:** `VillagerProfile` como `Resource` (`.tres`) catalogado en carpeta de datos, inspirado en el patrón ScriptableObject de Unity que el proyecto venía usando.
- **Justificación:** los recursos son assets editables en el editor sin código, serializables, compartibles y sustituibles; permiten que diseñadores prototipen perfiles sin tocar GDScript.

### A6. Estado emocional calculado vs persistido
- **Elegida (mixto):** el "ánimo de base" se persiste (checkpoint), y los deltas por clima/estación/hora se calculan en runtime con las señales de M29/M31/M32.
- **Justificación:** lo persistido nunca se vuelve incoherente entre cargas (determinismo suave), y lo calculado reacciona al mundo sin guardar datos innecesarios.

## 3. Decisiones Tomadas

| # | Decisión | Alternativa rechazada | Justificación |
|---|---|---|---|
| D1 | Vecinos rotativos con ciclo entrada/salida | Vecinos fijos | Rejugabilidad y renovación; alineado con plan (viajeros, nuevos vecinos) |
| D2 | Población 10 (rango 8-12) | Población > 12 | Equilibrio comunidad / atención / rendimiento |
| D3 | Mudanza con permiso del jugador (entrada) + aviso y rechazo (salida) | Mudanza automática | Cozy: el jugador nunca pierde a un vecino sin consentimiento |
| D4 | Datos de vecino en `VillagerProfile` (.tres) | Datos incrustados en escena | Editable en editor, serializable, reutilizable |
| D5 | IA delegada a M64 (contrato de agentes) | IA por NPC | Presupuesto centralizado y desacople (AGENTS.md §9) |
| D6 | Mood mixto: base persistida + deltas calculados | Mood 100% calculado o 100% persistido | Coherencia entre cargas + reacción al mundo |
| D7 | Interacción central por tecla F con señales | Interacción por evento de colisión directa | Consistencia de input (New Input System / InputMap de Godot) y desacople |
| D8 | Hooks de diálogo (contrato) que consumen M21 | Diálogo implementado en este módulo | Evita duplicar UI de diálogo; M21 es el dueño |

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Vecino atascado en terreno vóxel (borde de chunk, parcela cerrada) | Media | Contrato de destino válido con M64; fallback IrACasa; teleport discreto tras 6 s (regla M64) |
| Mudanza cancelada a mitad de proceso | Media | Máquina de estados de mudanza con puntos de no retorno; cancelación limpia en cada fase |
| Jugador pierde vecino favorito | Media | Aviso previo, opción de rechazo, sin partidas forzosas |
| Población duplicada tras guardado corrupto | Baja | IDs únicos por perfil; validación al cargar (duplicados se descartan) |
| Vector de interacción confuso (pulsar F sin vecino cerca) | Baja | Indicador visible solo con objetivo válido; feedback de "nadie cerca" mínimo y respetuoso |
| Rendimiento del catálogo con muchos candidatos | Baja | Catálogo cargado bajo demanda (solo candidatos próximos) |

## 5. Consumidores y Proveedores

- **Provee a M64:** perfiles, rutinas, lista de vecinos activos, hogares (para agenda de POI).
- **Provee a M21:** hooks de diálogo (líneas, respuestas, eventos de conversación).
- **Provee a M20:** eventos de interacción (regalo, charla) y estado emocional para derivar amistad.
- **Consume de M25:** temas de conversación sobre ruinas; vecinos reaccionan a hallazgos del jugador.
- **Consume de M29:** hora del día, calendario, PRNG de partida para variaciones.
- **Consume de M61:** presupuesto de NPCs activos (límites de agentes en burbuja).