**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 02-Analisis.md — Módulo 70: Interacciones

## 1. Análisis del Dominio

### 1.1 Categorías de interactuables en la isla Aurora

| Categoría | Ejemplos en el mundo | Consumidor | Comportamiento típico |
|---|---|---|---|
| Objeto recogible | Flores, bayas, conchas, recursos sueltos | M14/M46 | Recoger al E; desaparece o vuelve tras respawn |
| NPC / Vecino | Vecinos con rutinas, visitantes | M19/M20/M21 | Hablar al E (hook de diálogo), regalar con item seleccionado |
| Cosecha | Plantas maduras, cultivos | M33 | Recoger al E; requiere planta madura |
| Puerta | Casas (M18), cofres de casas, salidas | M18 | Abrir/cerrar toggle al E; bloqueada si está cerrada con llave |
| Cofre | Cofres de recompensa, tesoros | M14 | Abrir al E una vez (cofre abierto persiste) |
| Animal | Gallinas, vacas, mascotas | M65 | Acariciar/alimentar al E; estado de ánimo |
| Evento / Trigger | Zonas de cutscene, santuarios, puzzles | M22/M24/M26 | Activar al E (o por zona); muchas veces sin prompt |
| Decorativo | Bancos, faroles, altar | M53/M44 | Flavor: algunas veces solo animación/feedback al E |

Cada categoría aporta: prioridad base, ícono de prompt, sonido de interacción, prompt label por defecto y si requiere línea de visión.

### 1.2 Detección por raycast vs cercanía

El mundo es voxel (Voxel Tools). El jugador es un personaje y el mundo una isla 3D cozy (cámara y física de M11/M12). Dos familias de detección:

- **Cercanía pura (Overlap/área):** cada interactuable tiene una Shape2D/3D y se detectan overlaps contra el cuerpo del jugador. Simple, pero el costo sube con la cantidad y no da orden de prioridad ni maneja bien la geometría voxel.
- **Registro + distancia (manager):** cada interactuable se registra en el InteractionManager; cada frame el jugador consulta la lista y filtra por distancia, categoría y estado. Determinístico, O(n) barato, permite orden y prioridad con coste mínimo.
- **Raycast central:** un raycast desde la cámara/jugador hacia delante (estilo aventura) contradice el input por proximidad cozy que define el proyecto: el jugador mira el mundo, no "apunta" a objetos.

**Decisión D1:** Registro + distancia en el InteractionManager, con raycast de línea de visión solo como filtro de validación (obstáculos voxel entre jugador y objetivo) y SOLO para las categorías que lo configuran (NPC, cofre, puerta), espaciado por frames.

### 1.3 Prioridad de selección

Con varios interactuables en rango hay que elegir UNO. Criterios ordenados lexicográficamente:

1. **Prioridad de categoría** (tabla del sistema): NPC charlar > evento/trigger > cofre > puerta > cosecha > animal > objeto recogible > decorativo. Racional: lo narrativo y lo irrepetible primero; lo repetible después.
2. **Distancia** al jugador (menor gana). Al ser voxel, la distancia es euclidiana sobre la posición del jugador y el centro del interactuable.
3. **Desviación angular** entre el frente del jugador y el vector hacia el objetivo (menor gana). Resuelve empates y evita saltos raros al girar.

**Decisión D2:** orden determinístico por (prioridad_categoría desc, distancia asc, ángulo asc). Sin aleatoriedad: los empates perfectos se resuelven por ID de registro (orden de entrada), que es estable.

### 1.4 Prompts visuales

Referencias del proyecto: M11 define "Prompt contextual (F) sobre IInteractable" y M19 define "burbuja F sobre la cabeza" world-space para vecinos. El módulo 70 unifica:

- **Indicador world-space:** ícono de tecla (E) + ícono de categoría, flotando sobre el interactuable (altura configurable), con suavizado de posición y fade de entrada/salida.
- **Línea de contexto en HUD:** nombre localizado del objetivo ("Hablar con Mira", "Abrir cofre de roble"), en el HUD bajo el jugador (normas M53), aparece solo con objetivo.
- **Estado atenuado:** si NO_DISPONIBLE, el indicador se muestra en gris con la tecla y opcionalmente la razón ("Necesitas hacha", "Duerme").

**Decisión D3:** doble prompt (indicador world-space + línea HUD) con datos provistos por el módulo 70 y render de un componente propio (PromptHUD en CanvasLayer separado) para no acoplar la UI del juego.

### 1.5 Estados de interacción

Cada interactuable y el gestor tienen estados:

- **Interactuable:** DISPONIBLE / INTERACTUANDO (consumidor en curso) / NO_DISPONIBLE (con razón) / OCULTO (no visible al sistema, p. ej. respawneando, fuera de streaming).
- **Gestor:** INACTIVO (sin candidatos) / SELECCIONANDO (candidatos evaluados cada frame) / INTERACTUANDO (bloqueo global mientras el consumidor trabaja) / DORMIDO (pausa o UI modal).

**Decisión D4:** el bloqueo global durante INTERACTUANDO evita múltiples interacciones simultáneas (regla cozy: una cosa a la vez) y da consistencia.

### 1.6 Análisis de riesgo (anti-cozy y frustración)

| Riesgo | Severidad | Mitigación |
|---|---|---|
| Prompt parpadeante al alternar dos objetivos equidistantes | Alta | Suavizado/fade del prompt + desviación angular como desempate + histéresis (mantener objetivo si se reordena por ≤ un umbral 0.15 m) |
| Tecla E muerta ("no pasó nada") | Media | Siempre hay feedback sonoro/visual distinto si se presiona con prompt o sin él |
| Interacción interrumpida por alejarse | Media | Cancelación suave: señal `interaccion_cancelada` al consumidor y cierre del prompt sin cortes bruscos |
| Bloqueo eterno (interfaz atascada) | Media | Timeout de cooldown del consumidor + watchdog de estado INTERACTUANDO (M66 lo audita) |
| Cosecha madura invisible entre muchas plantas | Baja | El prompt resalta con borde/glow cuando hay varios candidatos de la misma categoría |
| NPC "no disponible" sin motivo | Media | Estado NO_DISPONIBLE siempre con razón localizable opcional |
| Dos sistemas escuchan E a la vez | Alta | Regla de una sola fuente: solo el módulo 70 escucha "interact"; los consumidores reciben señales |

## 2. Alternativas Consideradas

| # | Alternativa | Pros | Contras | Decisión |
|---|---|---|---|---|
| D1a | Overlap por Shape (Area3D per interactuable) | No requiere manager central | Costo con muchos objetos; sin orden de prioridad natural; roza física | Descartada |
| D1b | Raycast desde cámara (apuntar) | Precisión | Rompe la interacción por cercanía cozy; frustrante en vista lejana isométrica | Descartada |
| D1c | Registro + distancia + raycast de visión opcional | Determinismo, costo bajo, encaja con voxel | Manager obligatorio (habrá uno: M07) | **Elegida (D1)** |
| D2a | Prioridad solo por distancia | Simple | El jugador "pelea" con el vecino en cofre: impredecible | Descartada |
| D2b | Prioridad dinámica por contexto (herramienta en mano) | Inteligente | Cambios de objetivo al cambiar de herramienta; confuso en cozy | Descartada parcial: el prompt SÍ muestra herramienta contextual (RF7), pero la selección solo usa categoría/distancia/ángulo |
| D3a | Sólo indicador world-space | Inmersivo | Nombre de objetivo poco legible | Descartada |
| D3b | Sólo línea HUD | Simple | Confuso si varios objetos cerca | Descartada |
| D3c | Indicador + línea HUD | Claro, legible, cozy | Dos renders a coordinar | **Elegida (D3)** |
| D4a | Interacciones simultáneas (multi-interactuable) | Velocidad | Caos cozy; feedback confuso | Descartada |
| D4b | Un solo bloqueo global | Sencillo, predecible | Interacciones largas bloquean todo | **Elegida (D4)** con timeout auditado por M66 |
| D5a | Registrar categorías por módulo (hardcode) | Simple al inicio | Rompe el desacople | Descartada |
| D5b | Proveedores de categoría registrados por Resource `.tres` | Desacoplado, configurable, localizable | Más piezas | **Elegida**: catálogo `categorias_interaccion.tres` + registro por Signal/Enum |

## 3. Decisiones Clave

1. **D1** — Detección por registro + distancia en InteractionManager; línea de visión voxel opcional por categoría y espaciada.
2. **D2** — Selección determinística: (prioridad categoría desc, distancia asc, ángulo asc) + histéresis anti-parpadeo.
3. **D3** — Doble prompt: indicador world-space "E + ícono categoría" y línea HUD con nombre localizado; estados atenuados con razón.
4. **D4** — Estado global INTERACTUANDO con bloqueo de nuevas selecciones; cancelación suave por distancia/UI; watchdog anti-softlock (M66).
5. **D5** — Desacople total por contrato `IInteractable` (interfaz), señales y catálogo de categorías en Resource; el módulo 70 no importa consumidores.
6. **D6** — Input unificado: solo el 70 escucha la acción "interact" (E en teclado, A/B en gamepad según M57); los consumidores reciben despachos.
7. **D7** — Persistencia acotada en `GameState.M70` (solo estados relevantes: cofres, puertas, cosechas recogidas, animales acariciados).

## 4. Impacto en otmódulos (contratos que ofrecemos/consumimos)

**Ofrecemos (señales/contrato):**
- `IInteractable` (interfaz GDScript): `obtener_estado()`, `obtener_categoria()`, `obtener_posicion_interaccion()`, `interactuar(datos)`, `cancelar_interaccion()`, `requisitos_cumplidos(jugador)`.
- Señal `objetivo_seleccionado(interactable)` y `objetivo_perdido()`.
- Señal `interaccion_iniciada(interactable)` / `interaccion_terminada(interactable, ok)`.
- Catálogo de categorías (Resource) para iconos, sonidos y labels por defecto.

**Consumimos:**
- M11: posición/cabeza del jugador, estado FSM (si está ocupado, sin interactuar), rango base 4 m.
- M08: voxel world para línea de visión (VoxelTool / raycast voxel).
- M13: herramienta en mano para prompt contextual y checklist de requisitos (Rf7/RF17).
- M57: InputMap (acción "interact"), normativa de remapeo y localización.
- M53: normas de HUD y CanvasLayer (prompt no tapa inventario ni diálogos).
- M63: alta/baja de interactuables al cargar/descargar zonas.
- M29/M31: hora del día para requisitos temporales.
- M103: logging estructurado de errores de contrato.

**Reciben de nosotros:** M19 (despacho hablar/regalar), M21 (abrir diálogo), M33 (cosechar), M14 (abrir cofre), M65 (acariciar/alimentar), M18 (abrir puerta), M35/M46 (recoger recursos), M22/M24/M26 (activar triggers).

## 5. Supuestos y Riesgos

- Supuesto: un solo jugador (single-player cozy); sin interacciones en multijugador.
- Supuesto: el radio de interacción se mide contra el centro del jugador (collider de M11).
- Riesgo: rendimiento del raycast voxel por frame → mitigado con espaciado y acotado a categorías que lo necesitan.
- Riesgo: fragmentación con módulos que ya definieron su prompt (M19 burbuja, M11 prompt) → el 70 provee el componente compartido y los módulos existentes migran su indicador al PromptHUD del 70 (con glog de migración).
- Riesgo: la tecla E vs F histórica → unificar con InputMap y documentar en M57; el remapeo permite al usuario elegir.
- Riesgo: consumidores que rompan el contrato durante runtime → degradación segura a NO_DISPONIBLE + log M103, sin excepción al jugador.
- Supuesto: mundo voxel con interactuables posicionados en células de red; la distancia euclidiana es suficiente (no pathfinding para interactuar).