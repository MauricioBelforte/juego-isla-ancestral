**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 15: Recursos

## 1. Análisis del Dominio

### 1.1 El dominio "recurso" en juegos cozy

En un cozy game de mundo voxel, el jugador pasa la mayor parte del tiempo recolectando materiales para construir y crear. El dominio se compone de tres entidades fundamentales:

1. **El recurso definido** (el material: madera de roble, piedra, fibra de algodón...). Es un dato, no un objeto del mundo.
2. **El nodo de recurso** (el objeto del mundo: un árbol, una roca, un arbusto, un yacimiento de cobre). Es una instancia 3D anclada al mundo voxel que el jugador golpea.
3. **El drop** (lo que el nodo entrega al ser recolectado). Es el puente entre el mundo y el inventario M14.

La referencia de mercado más cercana es Animal Crossing: los recursos aparecen (roca diaria, árboles que crecen, frutos que vuelven) y el jugador nunca se queda sin ellos, solo tiene que esperar o viajar. Zelda cozy (BotW) aporta la idea de que la herramienta correcta marca el ritmo (hacha-pico), pero sin el desgaste frustrante.

### 1.2 Cómo encaja en Isla Ancestral

- El mundo es voxel (M08 + Voxel Tools GDExtension). Los árboles, rocas y arbustos pueden vivir como nodos separados del voxel (mesh instanciado) o como modificadores del voxel. Se elige lo primero (ver 3.1) por simplicidad y rendimiento.
- Las herramientas (M13) golpean el mundo; el recurso necesita escuchar esos golpes sin acoplarse a la herramienta (interfaz `IInteractable`/señal).
- El inventario (M14) recibe los ítems; el recurso solo emite "drop generado".
- El crafting (M16) consume los materiales; el recurso debe entregar cantidades balanceadas para que las recetas tengan costo razonable.
- El calendario y las estaciones (M29/M32) disparan el respawn; el recurso debe suscribirse sin conocer el calendario.
- Los eventos (M73) pueden reponer recursos en zonas festivas (lluvia de estrellas de madera, festival de la cosecha).

## 2. Alternativas Evaluadas

### 2.1 Regeneración vs respawn por evento

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| A1: Respawn por estación/evento (elegida) | Predecible para el jugador; ligado a la fantasía de la isla; coherente con calendario M29/M32; crea anticipación cozy ("en primavera vuelven los frutos") | El jugador debe esperar; requiere estado persistente por nodo |
| A2: Regeneración continua (timer fijo por nodo) | Siempre hay algo que recolectar | Genera rutinas de "farmear el mismo punto"; estado por nodo con timers; menos narrativo; más fricción con guardado |
| A3: Respawn solo al dormir/cargar escena | Simple, sin timers | Rompe inmersión; se siente artificial; incentiva dormir como truco |

**Decisión:** A1. Cada nodo agotado tiene `fecha_reaparicion` (estación o evento concreto) calculada con PRNG M29. Los recursos básicos (madera, piedra, fibras) reaparecen rápido (cambio de estación o un día tras evento); los raros, una vez por estación. Esto cumple la regla cozy de "sin agotamiento irreparable" y da ritmo natural.

### 2.2 Recursos infinitos vs finitos

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| B1: Finitos con respawn (elegida) | El mundo se siente vivo y limitado; los drops valen; el respawn garantiza disponibilidad | Requiere el sistema de respawn bien calibrado |
| B2: Infinitos (nunca se agotan) | Cero frustración, cero estado | El mundo se siente vacío de significado; satura inventario; rompe el flujo de crafting (todo gratis) |
| B3: Finitos sin respawn | Raro/valioso | Rompe la regla cozy; la isla se vacía; riesgo de bloqueo irreparable |

**Decisión:** B1 con generosidad cozy: el respawn básico es de 1 estación como máximo para materiales comunes y hay fuentes alternativas garantizadas (vendedor, regalos de deidades M73, recursos de pesca/minería). El sistema registra "fuentes alternativas" por recurso para que el QA verifique que nunca hay bloqueo total.

### 2.3 Nodos adheridos al voxel vs nodos independientes

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| C1: Nodos independientes anclados a voxel (elegida) | Fácil de animar/golpear/estado; pooling sencillo; no modifica el chunk voxel (evita re-mesheado) | Debe mantenerse sincronizado con el terreno (no flotar ni enterrarse) |
| C2: Recursos como voxeles especiales del chunk | Total integración visual | Remeshear chunks al recolectar es costoso; estado mezclado con el mundo; difícil animación |

**Decisión:** C1. El nodo se posiciona sobre el voxel raíz de su ocupación (se consulta altura exacta a M08 al instanciarse y al reaparecer). Al recolectarse, el mesh del nodo desaparece y queda el voxel de base (tocón/roca baja) según definición.

### 2.4 Drops físicos vs automáticos a inventario

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| D1: Drops físicos recogibles (elegida) | Satisfacción visual cozy; el jugador elige qué levantar; feedback claro | Más entidades activas; hay que gestionar el suelo saturado |
| D2: Directo a inventario | Cero gestión | Pierde tacto; el jugador no "ve" lo que ganó |

**Decisión:** D1 con reglas de saturación (ver 2.5): los drops caen con física suave, son imantados por el jugador al acercarse y se auto-recogen. Si el inventario está lleno o el suelo se satura, se redirigen al buzón/caja de la casa (M17) o se convierten en "bolsa de recursos" que se recoge completa.

### 2.5 Drops al suelo lleno

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| E1: Suelo con límite de objetos y conversión a bolsa (elegida) | Nunca se pierde un drop; rendimiento controlado | Necesita el objeto "bolsa" |
| E2: Desaparecen al límite | Simple | Pérdida injusta (anti-cozy) |
| E3: Límite alto sin gestión | Nunca se pierde | Rendimiento: cientos de instancias físicas |

**Decisión:** E1. Límite configurable de drops físicos por zona (default 40). Al superarlo, el drop nuevo se convierte en `RecursoBolsa` (un solo objeto físico con contador interno que entrega todo el contenido al recogerse). Al recoger una bolsa, se reparte a inventario M14 y el excedente se envía a la caja de almacenamiento.

### 2.6 Comida y hambre

| Alternativa | Ventajas | Desventajas |
|---|---|---|
| F1: Sin hambre castigadora; comida como buff opcional (elegida) | Cozy puro; la comida es recompensa, no necesidad; el jugador no muere por ignorarla | La comida pierde "urgencia" (se compensa con buffs y misiones M73) |
| F2: Hambre con penalización suave (energía baja) | Da propósito a la comida | Fricción constante; riesgo anti-cozy; más sistemas |
| F3: Hambre con muerte/daño | — | Prohibido por la visión cozy del proyecto |

**Decisión:** F1. La comida (frutas, bayas, pescado, recetas M16) otorga energía/beneficios temporales (velocidad de recolección, regeneración, suerte de drops raros). No existe muerte por hambre. Los recursos de comida son de respawn especialmente rápido (2-3 días de juego o tras eventos de lluvia).

## 3. Decisiones Técnicas Clave

### 3.1 Anclaje al mundo voxel (M08)
- Los nodos se registran con `world_pos` + `region_id` + `voxel_base` (coordenada voxel raíz).
- Al instanciar y al reaparecer, se consulta a M08 la altura de superficie en `region_id` para posicionar sin flotar.
- Si un jugador construye sobre un nodo agotado (M17), el respawn se reposiciona al voxel libre más cercano dentro de la región (radio de búsqueda 8 voxeles).

### 3.2 Estado por nodo y persistencia
- Cada nodo vive en el `ResourceSpawner` como entrada de diccionario: `{node_id, def_id, region_id, pos, estado, fecha_reaparicion}`.
- Solo los nodos agotados o dañados se serializan en el guardado; los intactos se regeneran por seed al cargar (determinismo M29). Esto mantiene el guardado chico.
- El inventario M14 guarda cantidades por `item_id` (recursos incluidos).

### 3.3 Presupuesto de spawns (optimización)
- `NODO_ACTIVO_RADIO`: 48 m alrededor del jugador (nodos instanciados y activos).
- `NODO_IMPOSTOR_RADIO`: 96 m (mesh estático simple sin física).
- Fuera de 96 m: solo entrada de datos (no instancia).
- Máximo de instancias activas simultáneas: 200; el excedente espera en cola (spawn budget).
- Drops físicos con pooling (max 60 activos) y auto-eliminación en 2 min si no se recogen (con conversión a bolsa si aplica).

### 3.4 Comunicación por señales
- M13 (Herramientas) emite `golpe_aplicado(position, herramienta_id, golpes_restantes_info)`.
- `ResourceNode` escucha dentro de su área; si la herramienta es válida: reduce durabilidad, dispara feedback, y al llegar a 0 produce drops.
- M14 (Inventario) expone `agregar_items(lista)`; los drops lo llaman al ser recogidos.
- M29/M32 (Calendario/Estaciones) emiten `estacion_cambio(nueva)`: el `ResourceSpawner` revisa fechas de reaparición.
- M73 (Eventos) emite `evento_iniciado(id_evento)`: el spawner aplica bonos/reposiciones.

## 4. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Nodos flotando/enterrados al regenerar terreno (M08) | Consulta de altura a M08 en cada instanciación y reposicionamiento |
| Explosión de objetos en el suelo | Límite por zona + conversión a bolsa + pooling |
| Guardado gigante por miles de nodos | Solo se guardan nodos no-intactos + seed PRNG |
| Jugador sin recursos por respawn lento | Respawn máximo 1 estación para comunes; fuentes alternativas registradas por recurso |
| Rendimiento de partículas al recolectar | Pooling de partículas y sonidos; una ráfaga por evento de recolección |
| Desincronía entre nodos visuales y voxel al construir (M17) | Revalidación de posición en cada carga de chunk y en respawn |

## 5. Fuentes de Ítems del Plan Maestro

Los puntos del plan maestro relacionados con recursos se resuelven así:

- "Diseñar sistema de recursos" (sección 4) → este módulo.
- "Crear generador de recursos" y "reglas de spawn/distribución" (sección 9) → este módulo junto a M08/M09 (distribución por bioma/región).
- "Evitar recursos inaccesibles" (sección 9) → validación de spawn: nunca en zonas sin camino alcanzable (regla: todo recurso visible debe ser alcanzable).
- "Diseñar materiales raros/ancestrales/estacionales/regionales" (secciones 15/16) → categorías del catálogo de recursos con temporada/región de aparición.
- "Balancear recursos" (sección 15) → tablas de cantidades en `ResourceDefinition` revisadas en QA (M114).
- "Medir primer recurso recolectado" (sección de UX) → test de onboarding: el jugador recolecta su primer recurso en los primeros 5 minutos.
