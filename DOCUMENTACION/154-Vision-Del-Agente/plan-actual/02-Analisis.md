**Modelo:** Cline
**Plataforma:** Nemotron 3.5 Lightning

# 02-Analisis.md — Módulo 154: Visión del Agente

## 1. Análisis del dominio

### 1.1 ¿Qué significa que un agente "tenga ojos"?

Un LLM con capacidad de visión (VLM) puede analizar imágenes si estas le llegan como entrada. El problema no es el modelo, sino el **pipeline de captura**: cómo la imagen del juego llega al contexto del agente. Existen 4 puntos de integración posibles:

| Punto | Mecanismo | Quién actúa |
|---|---|---|
| Chat directo | Imagen pegada/adjuntada por el usuario | Usuario |
| MCP tool | Servidor local devuelve imagen base64 al agente | Agente (autónomo) |
| Browser automation | Playwright captura página web renderizada | Agente (autónomo) |
| Control del editor | MCP específico de Godot ejecuta y captura | Agente (autónomo) |

### 1.2 Capacidades reales del stack actual (Cline + Windows + Godot 4.x)

- **Visión integrada:** Cline soporta imágenes en el chat; los modelos VLM las analizan. ✅ Disponible hoy.
- **MCP:** Cline soporta servidores MCP configurados en `cline_mcp_settings.json`. Las tools MCP pueden devolver imágenes (base64). ✅ Soportado.
- **Skill webapp-testing:** Playwright ya disponible para capturar apps web. Requiere export HTML5 del juego. ✅ Disponible.
- **godot-mcp comunitario:** existen proyectos open source (ej. `godot-mcp`, `mcp-godot`) que exponen el editor vía MCP: lanzar escenas, leer output de consola, capturar viewport. ⚠️ Requiere instalación y verificación de compatibilidad con Godot 4.x.

## 2. Las 4 alternativas evaluadas

### V1 — Capturas en el chat
- **Cómo funciona:** usuario renderiza en Godot → screenshot → arrastra al chat → agente analiza.
- **Pros:** cero setup, máxima fidelidad (el usuario elige exactamente qué mostrar), funciona con cualquier modelo VLM.
- **Contras:** interrupción manual en cada iteración; no escala para QA automatizado; depende de disponibilidad del usuario.
- **Veredicto:** viable como complemento; insuficiente como estándar.

### V2 — MCP custom de captura de pantalla
- **Cómo funciona:** servidor MCP Python con `PIL.ImageGrab` (o `pygetwindow` para ventana específica) → captura → devuelve PNG base64 → el agente lo analiza.
- **Pros:** autónomo, genérico (ve cualquier app, no solo Godot), ~50 líneas de código, sin dependencias del editor.
- **Contras:** captura lo que hay en pantalla (puede incluir ventanas ajenas); requiere que la ventana de Godot esté visible y enfocada; resolución limitada a la del monitor.
- **Veredicto:** excelente fallback universal; útil también para verificar UI fuera del juego.

### V3 — Export web + Playwright
- **Cómo funciona:** Godot exporta a HTML5/WebAssembly (`godot --headless --export-release Web`) → se sirve localmente (http.server) → skill webapp-testing abre la URL, espera carga, captura screenshots, incluso interactúa (clicks, teclas).
- **Pros:** totalmente automatizado e interactivo (el agente puede "jugar"); reproducible en CI (conecta con M118); no depende del escritorio.
- **Contras:** export web tiene diferencias de rendering vs desktop (WebGL); build web añade tiempo al ciclo; threading/audio limitados en WASM.
- **Veredicto:** ideal para QA automatizado y regresión visual; complementa, no reemplaza, la vista del editor.

### V5 — Blender + blender-mcp (agregada 2026-08-22)

- **Cómo funciona:** Blender (gratis, open source) es 100% scriptable vía su API Python `bpy`, incluso en modo headless (`blender -b archivo.blend -P script.py`). El servidor MCP comunitario **`blender-mcp` (ahujasid)** —uno de los MCP creativos más maduros y usados— se conecta a Blender mediante un addon interno (socket en puerto 9876) y expone tools al agente: `get_scene_info`, `get_object_info`, `get_viewport_screenshot`, `execute_blender_code`.
- **Pros:** MCP maduro y activo; control TOTAL de Blender desde el agente (modelar, materiales, luces, cámara, render); renders de calidad de estudio independientes del motor; pipeline glTF nativo hacia Godot; soporta importar `.vox` de MagicaVoxel (estilo voxel del proyecto); permite generar variantes paramétricas de NPCs por código.
- **Contras:** `execute_blender_code` es poderoso pero puede colgar Blender si el script falla (requiere prácticas seguras); el screenshot del viewport depende del modo de shading (necesita Material Preview/Rendered para verse bien); el render F12 va a archivo (no lo devuelve el MCP directamente); requiere Blender abierto con el addon habilitado.
- **Veredicto:** la vía MÁS fácil y potente para que el agente tenga ojos sobre assets 3D. Complementa a Godot (Blender = taller de assets, Godot = casa final). No reemplaza a V4 para verificación dentro del juego.

### V4 — godot-mcp comunitario ⭐ FUNDAMENTAL
- **Cómo funciona:** servidor MCP (Node/Python según implementación) se conecta al editor Godot (vía plugin/gdscript bridge o headless CLI) y expone tools: `run_scene`, `get_errors`, `capture_viewport`, `read_console`, `inspect_node`.
- **Pros:** visión nativa del editor (viewport exacto, no pantalla completa); lee errores de consola directamente (integra con M103/M122); permite ejecutar escenas específicas (ej. escena de preview de personaje); es el más completo y el que el usuario designó como estándar permanente.
- **Contras:** dependencia de proyecto comunitario (madurez variable); requiere plugin en el proyecto o Godot headless; versión debe matchear Godot 4.x.
- **Veredicto:** **ESTÁNDAR OBLIGATORIO del proyecto**. Toda sesión de trabajo visual debe priorizar esta vía.

## 3. Alternativas descartadas

| Alternativa | Razón de descarte |
|---|---|
| **A1 — Entrenar modelo de visión propio sobre renders del juego** | Costo prohibitivo, dataset requerido enorme, mantenimiento continuo. No justificado para un juego indie cozy. |
| **A2 — API de visión externa de pago como dependencia crítica (ej. enviar cada frame a un servicio cloud)** | Viola NFR2 (sin pagos obligatorios) y NFR6 (privacidad: capturas salen del equipo). Podría usarse puntualmente pero nunca como pilar. |
| **A3 — Visión en tiempo real por streaming de video (>5 FPS)** | Innecesario para iteración de diseño (se trabaja con frames estáticos); complejidad técnica alta; consumo de contexto del agente disparado. |

## 4. Decisiones

| # | Decisión | Justificación |
|---|---|---|
| D1 | godot-mcp (V4) es el estándar fundamental y permanente | Directiva explícita del usuario; es la vía más completa (viewport + consola + ejecución de escenas) |
| D2 | Las 4 vías se documentan como complementarias | Degradación elegante (NFR5): si una falla, hay fallback inmediato |
| D3 | V2 (MCP custom de pantalla) se implementa como primer fallback | Genérica, simple (~50 líneas), útil incluso fuera de Godot |
| D4 | V3 (web+Playwright) queda asociada a M118 CI/CD para regresión visual | Aprovecha infraestructura existente del skill webapp-testing |
| D5 | V1 (chat) queda documentada como vía de validación artística final | El usuario conserva siempre la última palabra estética |
| D6 | Se agrega V5 (Blender + blender-mcp) como vía de diseño de assets con visión | Directiva del usuario (2026-08-22): blender-mcp es el MCP creativo más maduro; bpy permite modelar+renderizar+ver sin depender del motor; cumple NFR2 (gratis/open source) |

## 5. Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| godot-mcp incompatible con la versión de Godot elegida | Media | Alto | Verificar compatibilidad antes de adoptar; mantener V2/V3 como fallback |
| Proyecto comunitario abandonado | Media | Medio | Fork interno o migración a V2; el módulo documenta cómo reemplazarlo |
| Capturas consumen demasiado contexto del agente | Baja | Medio | Protocolo: 1 captura por iteración, resolución acotada (1280x720) |
| Export web difiere visualmente del build desktop | Alta | Bajo | Usar V3 solo para lógica/QA, no para validación estética final |
| Script bpy defectuoso cuelga Blender | Media | Medio | Scripts atómicos cortos; guardar .blend antes de execute_code; patrón try/except en scripts generados |
| Viewport screenshot sale en modo sólido (sin materiales) | Alta | Bajo | Protocolo: forzar shading Material Preview antes de capturar (script bpy incluido) |
