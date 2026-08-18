**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 54: Mapa

## 1. Análisis del dominio

El sistema de mapa en un cozy game con mundo voxel (Godot 4.x, GDScript) debe resolver cinco tensiones:

1. **Minimapa vs mapa completo**: el minimapa es un widget del HUD (M53) que debe ser legible de un vistazo, barato de renderizar y nunca competitivo con el mundo; el mapa completo es una pantalla modal de contemplación y planificación (viajes, pines, regiones). Comparten datos (regiones, marcadores, niebla) pero difieren en escala, rotación, detalle y costo. La decisión de rotación fija (norte arriba) minimiza cinetosis (M58) y simplifica el ícono del jugador.
2. **Generación desde mundo voxel**: el mundo es procedural (M10) y grande; NO se puede renderizar en vivo un SubViewport del mundo real dentro de la UI (costo altísimo en draw calls y memoria). La solución es un *bake*: una textura ilustrada generada una vez al (re)generar el mundo, donde cada celda voxel se mapea a un color por bioma/altura (estilo mapa ilustrado cozy, paleta M53) y las regiones de M09/M27 se dibujan como polígonos coloreados con nombres. Los marcadores, la niebla y los pines van en capas superpuestas a esa textura base.
3. **Niebla de guerra**: dos estados (no explorado / explorado) es la base; el estado "visitado" (ya estuve, volví) agrega valor en un juego de exploración. El costo dominante es el renderizado de la textura de niebla, no el dato: conviene guardar el estado por región/celda en el dominio (MapData) y materializar la niebla solo cuando cambia (textura cacheada por mosaicos sucios). Cero actualizaciones por frame.
4. **Marcadores**: el mundo voxel puede tener decenas de POIs (pueblo, tiendas M39, casas de NPCs M19, templos M24, ruinas M25, islas M27, destinos de fast travel M69). Los marcadores deben instanciarse con pool (sin crear/destruir nodos por frame), agruparse en clusters cuando la escala los junta, ocultarse detrás de la niebla y diferenciarse por forma + color (M58).
5. **Rendimiento en UI Godot**: cada `Control` con textura propia suma draw calls. La regla es: UNA textura base (mapa), UNA textura de niebla, capa de marcadores con un pool de sprites livianos, y actualizaciones por señal/evento (jamás por frame). Las etiquetas solo se refrescan en cambios de zoom/pan, no continuamente.

## 2. Alternativas consideradas

### Alternativa A — SubViewport del mundo en vivo dentro de la UI

Un `SubViewport` que re-renderiza la cámara del juego (o una cámara top-down dedicada) como textura del minimapa/mapa completo.

- **Pros:** cero lógica de bake; el mapa siempre refleja el mundo real al píxel; los marcadores podrían instanciarse en el mundo.
- **Contras:**
  - Costo de render por frame inaceptable para el presupuesto (M61): duplica la escena voxel en draw calls, vértices y memoria de textura.
  - El mundo voxel (M08/M10) tiene decenas de miles de meshes; un SubViewport extra los repite o exige culling adicional complejo.
  - Niebla de guerra y el mapa "ilustrado cozy" serían muy difíciles (la textura serían capturas crudas del engine, no una composición artística).
  - Rompe la estética cozy de mapa de papel/ilustración y complica el renderizado por regiones del minimapa.
  - Escala mal en low-end (Steam Deck).

### Alternativa B — Textura base baked + capas de datos (niebla, marcadores, pines)

El mapa es una textura generada UNA vez (bake al (re)generar el mundo o bajo demanda al abrir el mapa por primera vez, con progreso visual M63): se recorre el chunk data del mundo voxel (M10) y se pintan los biomas de M09/M27 como manchas de color pastel, con bordes de región y nombres. Sobre esa textura, capas independientes: niebla (ImageTexture de mosaicos sucios), marcadores (pool de sprites), pines del jugador.

- **Pros:**
  - 1 textura base + 1 textura de niebla + sprites livianos: 3 draw calls máximo con el mapa abierto.
  - Desacople total: los datos (MapData) se generan desde el dominio (M09/M10/M27); las vistas (M53) solo dibujan.
  - La niebla es un ImageTexture opaco con `modulate` — sin shaders costosos.
  - Estética controlada al 100% (paleta cozy, ilustración suave, M53/M88).
  - Generación en background con barra de progreso (regla 8 de AGENTS) y caché en disco (M60).
- **Contras:** hay que escribir el bake del mundo voxel a textura (una vez); la textura debe regenerarse si el mundo cambia (el mundo es procedural con semilla fija por save — M60 garantiza estabilidad).

### Alternativa C — Mapa vectorial dibujado (polígonos por región sin textura)

El mapa no es una textura sino polígonos `Polygon2D` por región, dibujados en runtime.

- **Pros:** cero memoria de textura; zoom infinito nítido.
- **Contras:** decenas de `Polygon2D` distintivas por región + bordes = draw calls que escalan con el número de regiones; el detalle del terreno (ríos, costas, caminos) exige muchísimos vértices y queda fuera del presupuesto; la apariencia no es "ilustración cozy" sino diagrama; complejidad alta sin beneficio frente a B.

### Alternativa D — Integración del fast travel directa (acoplada)

El Mapa llama a métodos/nodos de M69 directamente (import de clases).

- **Pros:** simple de escribir.
- **Contras:** rompe la regla de capas de M07 y M53 (UI no acopla gameplay); M69 queda dependiente de la UI; testear aislado se vuelve imposible.
- **Decisión:** M69 expone una interfaz por `Callable`/EventBus (dominio `map`) y el Mapa nunca importa nodos de M69.

## 3. Decisión

**Se adopta la Alternativa B**: textura base baked desde el mundo voxel + capas de datos (niebla, marcadores, pines) + integración por interfaz con M69 (descartando A, C y D).

Justificación:

1. **Presupuesto garantizado**: 1 textura base + 1 niebla + sprites con pool = ≤ 3 draw calls y ≤ 5% de frame con el mapa abierto; el minimapa reusa la misma textura base (sin segundo bake).
2. **Desacople por construcción**: `MapManager` (autoload de datos de mapa/exploración/pines) no conoce ninguna clase de UI; `MinimapView` y `FullMapView` son vistas de M53 que consumen datos por eventos/Callable.
3. **Cozy nativo**: el bake permite una paleta pastel ilustrada (M53) con nombres en M88; la niebla es suave y el revelado progresivo recompensa explorar (M58 reduce_motion respetado).
4. **Persistencia barata (M60)**: exploración = bits por celda/región en MapData; pines = lista de `PinData`; ambos serializables sin tocar el mundo.
5. **Mundo estable**: semilla fija por save (M60) garantiza que el bake no cambie a mitad de partida; se regenera solo cuando se regenera el mundo (M10/M63) con progreso visual (AGENTS 8).
6. **Escala**: bajo costo en low-end; Steam Deck incluido.

Decisión registrada en `03-Diseno.md`; A y C quedan descartadas (costo de render y draw calls), D queda descartada por acoplamiento (M07/M53).

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Bake de textura bloqueante en mundo grande (isla Aurora) | Generación por secciones en background (M63) con barra de progreso (AGENTS 8); caché de la textura en disco (M60); abortable con estado consistente |
| Textura de mapa enorme en memoria (isla completa) | Resolución acotada por presupuesto de memoria (ej: max 2048 px de lado para el mapa completo, minimapa reusa la misma); compresión M108; nunca duplicada |
| Niebla de guerra con render por frame | Estado en MapData por región/celda; textura de niebla solo se materializa en mosaicos sucios; update por señal `exploration_changed` |
| Marcadores agrupados ilegibles | Cluster dinámico por escala (pool de clusters); tooltip del cluster lista los nombres; límite de sprites por cluster |
| Región sin explorar: spoilers (POIs ocultos) | Marcadores de una región solo se instancian cuando la región está explorada; la niebla tapa la región completa |
| Mapa abierto mientras el mundo genera (M10/M63) | `MapData` marca "regiones pendientes"; el mapa muestra fondo amable "El mapa aún se está dibujando..." (AGENTS 8) y refresca por señal |
| Jugador en otra isla (M27) | El mapa completo muestra la isla actual con pestaña/selector de islas ya exploradas (M27); el minimapa siempre la isla actual |
| Viaje rápido con un diálogo abierto (M21) | Pila de capas de M53: el request de viaje se encola; la confirmación del viaje espera cerrar el diálogo |
| Coordenadas de pines inválidas (mundo regenerado) | Al cargar (M60) se validan contra los límites del mundo; pines fuera de rango se marcan como "no disponibles" sin borrar el dato |
| Fuga de memoria al abrir/cerrar el mapa 100 veces | Texturas cacheadas en MapManager (jamás recreadas por apertura); pool de marcadores; test de stress (100 aperturas) |
| Foco perdido al cerrar el mapa | M53 restaura el foco (focus_backup de UIManager); test de cierre/reapertura |

## 5. Notas de motor (Godot 4.x específico)

- La textura del mapa se genera con `Image` + `ImageTexture` (sin `SubViewport`); el render es CPU-only en el bake, una sola vez.
- La niebla se dibuja como una `ImageTexture` del tamaño exacto del mapa con `blend_mode` opaco y `modulate`; hipotéticamente un `CanvasItemMaterial` con shader simple si se quiere patrón suave — reservado para polish (M58 reduce_motion lo simplifica a opacidad pura).
- Zoom/pan en el mapa completo con `scale` y `position` del contenedor; los marcadores usan `top_level` para mantener tamaño constante al zoom.
- Nombres de región con `Label` en M88 (Nunito/Fredoka One) de M53; sin `dynamic_font` re-hinting por frame (caché del Theme).
- Atajos y acciones vienen de M57 (`map_toggle`, `map_zoom_in/out`, `map_pan_*`, `map_close`); jamás se lee `Input.is_key_pressed` fuera de M57.