**Modelo:** ox-alpha
**Plataforma:** Cline

# 05-Checklist.md — Módulo 154: Visión del Agente

> **Actualizado:** 2026-08-24 — Verificación operativa de la Vía V5 (Blender + blender-mcp) y creación de la **guía maestra de conexión**: `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (archivo 06 global, en la raíz de DOCUMENTACION/; referencia obligatoria para cualquier agente — ver AGENTS.md sección 25).

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **operativo**: combina documentación (hecha) con implementación de herramientas MCP (pendiente).

## A. Requisitos y alcance (10)

- [ ] Definir el problema: agentes sin visión limitan iteración de diseño visual [S]
- [ ] Registrar directiva del usuario: 4 vías como alternativas, V4 fundamental [S]
- [ ] Catalogar los 7 requisitos funcionales (RF1-RF7) [S]
- [ ] Definir 6 requisitos no funcionales (NFR1-NFR6) [S]
- [ ] Establecer criterios de aceptación del módulo [S]
- [ ] Delimitar alcance: incluir 4 vías, excluir modelos custom/APIs pagas/streaming [S]
- [ ] Identificar integraciones con M45/M48/M53/M61/M103/M110/M112/M118 [S]
- [ ] Validar RF1 en la práctica: pegar imagen de prueba y analizarla [S]
- [ ] Confirmar con el usuario la matriz de decisión por escenario [S]
- [ ] Revisar alcance tras primera instalación real de godot-mcp [M]

## B. Análisis y decisiones (12)

- [ ] Analizar los 4 puntos de integración posibles de captura [S]
- [ ] Evaluar capacidades reales del stack Cline+Windows+Godot [S]
- [ ] Documentar pros/contras de cada una de las 4 vías [S]
- [ ] Descartar A1 (modelo de visión propio) con justificación de costo [S]
- [ ] Descartar A2 (API de visión paga crítica) por NFR2/NFR6 [S]
- [ ] Descartar A3 (streaming >5 FPS) por complejidad innecesaria [S]
- [ ] Decisión D1: V4 como estándar fundamental permanente [S]
- [ ] Decisión D2: vías complementarias con degradación elegante [S]
- [ ] Decisión D3: V2 como primer fallback universal [S]
- [ ] Decisión D4: V3 asociada a M118 para regresión visual [S]
- [ ] Decisión D5: V1 como validación artística final del usuario [S]
- [ ] Registrar riesgos con probabilidad/impacto/mitigación [S]

## C. Diseño y arquitectura (14)

- [ ] Diagrama de arquitectura general de las 4 vías [S]
- [ ] Diseñar flujo V1 (chat) sin componentes nuevos [S]
- [ ] Diseñar API de screenshot_mcp.py (V2): capture_screen/capture_window/save_capture [S]
- [ ] Diseñar configuración JSON para cline_mcp_settings.json (V2) [S]
- [ ] Diseñar pipeline V3: export headless → http.server → Playwright [S]
- [ ] Diseñar arquitectura de conexión V4: Cline ↔ server ↔ plugin Godot [S]
- [ ] Definir contrato de tools esperadas de godot-mcp (6 tools) [S]
- [ ] Escribir guía de instalación de V4 en Windows (6 pasos) [S]
- [ ] Crear matriz de decisión "qué vía usar según escenario" (6 escenarios) [S]
- [ ] Definir protocolo de iteración visual de 6 pasos [S]
- [ ] Acotar resolución de capturas a ≤1280x720 (preservar contexto) [S]
- [ ] Limitar iteraciones autónomas a 5 antes de escalar al usuario [S]
- [ ] Diseñar convención de nombres para Logs/screenshots/ [S]
- [ ] Revisar diseño tras primera sesión real de uso [M]

## D. Implementación V2 — MCP de captura de pantalla (16)

- [ ] Instalar dependencias Python: pillow, pygetwindow, mcp [S]
- [ ] Crear carpeta scripts/mcp/ [S]
- [ ] Implementar esqueleto FastMCP("screenshot") con transporte stdio [S]
- [ ] Implementar tool capture_screen() con ImageGrab.grab() [S]
- [ ] Implementar thumbnail 1280x720 antes de codificar base64 [S]
- [ ] Implementar tool capture_window(title) con pygetwindow [S]
- [ ] Manejar error de ventana no encontrada con mensaje claro [S]
- [ ] Implementar tool save_capture(path) para historial en disco [S]
- [ ] Probar capture_screen() manualmente desde CLI [S]
- [ ] Probar capture_window("Godot Engine") con editor abierto [S]
- [ ] Verificar que la imagen devuelta es legible por el agente (visión) [M]
- [ ] Registrar servidor "screenshot" en cline_mcp_settings.json [S]
- [ ] Configurar alwaysAllow para tools de solo lectura [S]
- [ ] Verificar reinicio de Cline detecta el servidor [S]
- [ ] Medir latencia de captura (objetivo ≤5s, NFR1) [S]
- [ ] Documentar versión de dependencias instaladas [S]

## E. Implementación V4 — godot-mcp comunitario ⭐ (20)

- [x] Confirmar versión exacta de Godot del proyecto (4.7.2 — M04) [S]
- [x] Investigar proyectos comunitarios: godot-mcp elegido (Coding-Solo, 5.3k ⭐) [M]
- [x] Evaluar soporte Godot 4.x del candidato (compatible) [M]
- [x] Priorizar candidatos que expongan capture_viewport y get_errors [S]
- [x] Seleccionar implementación y registrar decisión con fecha (2026-08-24) [S]
- [x] Clonar/fork del proyecto elegido (tools/mcp/godot-mcp/) [S]
- [x] Instalar dependencias del servidor (npm install OK) [S]
- [x] Configurar GODOT_PATH en env de cline_mcp_settings.json [M]
- [x] Registrar servidor "godot" en cline_mcp_settings.json [S]
- [x] Test get_godot_version desde el agente (4.7.2.stable, 2026-08-24) [M]
- [x] Test get_project_info sobre game/isla-ancestral (2 escenas, 4 scripts, 16 assets) [S]
- [x] Documentar versión y commit exacto de godot-mcp instalado [S]
- [x] Declarar V4 operativo y actualizar regla de uso obligatoria (guía maestra) [S]

## F. Implementación V3 — Export web + Playwright (14)

- [ ] Definir preset de export Web en el proyecto Godot [M]
- [ ] Ejecutar export headless: godot --headless --export-release Web [M]
- [ ] Verificar builds/web/index.html generado [S]
- [ ] Servir localmente con python -m http.server 8080 [S]
- [ ] Navegar con skill webapp-testing a localhost:8080 [S]
- [ ] Esperar carga WASM correctamente (networkidle + timeout) [M]
- [ ] Capturar primer screenshot del juego en navegador [S]
- [ ] Verificar similitud visual razonable vs build desktop [M]
- [ ] Probar interacción: click/tecla mueve al personaje [M]
- [ ] Crear carpeta Logs/screenshots/ con .gitkeep [S]
- [ ] Guardar captura con convención YYYY-MM-DD_HH-MM-SS_via_descripcion.png [S]
- [ ] Documentar diferencias conocidas WebGL vs desktop [S]
- [ ] Preparar script reutilizable del pipeline completo [M]
- [ ] Conectar pipeline con job de CI (M118) para regresión visual [C]

## G. Escena de preview de personaje (8)

- [ ] Crear preview_personaje.tscn en el proyecto Godot [M]
- [ ] Fondo neutro uniforme (gris medio) para comparaciones [S]
- [ ] Luz de 3 puntos key/fill/rim estandarizada [M]
- [ ] Cámara fija con encuadre documentado [S]
- [ ] Slot para modelo voxel intercambiable [M]
- [ ] Botón/tecla de captura directa a Logs/screenshots/ [M]
- [ ] Integrar escena con Debug Menu (M110) si aplica [S]
- [ ] Documentar uso de la escena en este módulo [S]

## H. Protocolo y gobernanza (12)

- [ ] Regla obligatoria: verificar V4 al inicio de toda sesión visual [S]
- [ ] Fallback automático a V2 si V4 no responde [S]
- [ ] Informar al usuario cuando se active un fallback [S]
- [ ] Máximo 5 iteraciones autónomas antes de escalar (V1) [S]
- [ ] El agente describe lo observado ANTES de proponer cambios [S]
- [ ] Cambios de ajuste mínimos y medibles (no vagos) [S]
- [ ] Capacitar al usuario en el flujo V1 (pegar capturas) [S]
- [ ] Redactar quick-start de 1 página para nuevos agentes [M]
- [ ] Agregar referencia a este módulo desde AGENTS.md si el usuario lo aprueba [S]
- [ ] Revisión periódica semestral de las vías (nuevas herramientas MCP) [S]
- [ ] Actualizar ESTADO-PARALELO.md con disponibilidad de visión [S]
- [ ] Registrar en CHECKLIST-GLOBAL.md el estado operativo de V4 [S]

## I. QA y verificación (14)

- [ ] Test V1: imagen de prueba analizada con elementos correctos identificados [S]
- [ ] Test V2: capture_window devuelve PNG legible del viewport [S]
- [ ] Test V2: manejo correcto cuando la ventana no existe [S]
- [ ] Test V3: carga web <30s [S]
- [ ] Test V3: screenshot muestra escena inicial esperada [S]
- [ ] Test V3: interacción básica funciona [M]
- [ ] Test V4: run_scene lanza escena real [M]
- [ ] Test V4: get_errors refleja error inducido [M]
- [ ] Test V4: capture_viewport devuelve render correcto [M]
- [ ] Test fallback: flujo de personaje funciona vía V2 con V4 deshabilitada [M]
- [ ] Test de contexto: 5 iteraciones no disparan el presupuesto de tokens [M]
- [ ] Test de privacidad: ninguna captura sale del equipo local (NFR6) [S]
- [ ] Test de reproducibilidad: otro agente sigue la guía e instala V4 [C]
- [ ] Documentar resultados de tests en 07-Resultados-Testings.md futuro [S]

## K. Vía V5 — Blender + blender-mcp ⭐ (22)

- [ ] Evaluar blender-mcp como vía de visión para assets 3D (madurez comunitaria confirmada) [S]
- [ ] Decisión D6 registrada: V5 agregada como vía de diseño de assets [S]
- [ ] RF8/RF9 definidos (modelar/renderizar/ver/exportar; pipeline glTF→Godot) [S]
- [ ] Guía de instalación Windows documentada (6 pasos) [S]
- [ ] Contrato de tools documentado (get_scene_info, get_object_info, get_viewport_screenshot, execute_blender_code) [S]
- [ ] 12 capacidades del agente con ojos detalladas en 03-Diseno.md [S]
- [ ] Snippet generador de personaje voxel diseñado [S]
- [ ] Snippet export glTF→Godot diseñado [S]
- [ ] Script de seguridad estándar (respaldo .blend + shading Material Preview) diseñado [S]
- [ ] Protocolo de iteración V5 específico definido (6 pasos) [S]
- [ ] Riesgos V5 registrados con mitigación (script colgante, shading incorrecto) [S]
- [ ] Instalar Blender 4.x LTS en el sistema (4.2.3 LTS instalada) [M]
- [ ] Instalar addon blender-mcp en Blender y habilitarlo (Install from Disk, flecha ˅ en Preferences 4.2+) [S]
- [ ] Verificar conexión socket 9876 (panel BlenderMCP → Connect to MCP server) [S]
- [ ] Registrar servidor "blender" en cline_mcp_settings.json [S]
- [ ] Test get_scene_info: devuelve estructura real de escena (success, 3 objetos, 2 materiales — 2026-08-24) [S]
- [ ] Crear guía maestra de conexión de visión: `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (archivo 06 global, referenciada desde AGENTS.md sección 25) [S]
- [ ] Test get_viewport_screenshot: imagen legible con colores reales (verificada 2026-08-24 — requiere parámetro `filepath`; esfera naranja vista y validada por el agente) [M]
- [ ] Crear scripts/blender/setup_estudio.py (luz 3 puntos + cámara + fondo) [M]
- [ ] Crear scripts/blender/personaje_voxel.py (generador paramétrico) [M]
- [ ] Iterar primer NPC completo end-to-end con screenshots hasta aprobación del usuario [C]
- [ ] Exportar personaje aprobado a .glb e importarlo en Godot [M]
- [ ] Documentar versiones exactas instaladas (Blender, blender-mcp, commit) [S]

## J. Documentación y cierre (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado con Notas del Agente [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] plan-actual/ espejo idéntico verificado [S]
- [ ] Log generado en Logs/ con numeración secuencial [S]
- [ ] Fila 154 agregada a CHECKLIST-GLOBAL.md [S]
- [ ] Entrada agregada a DOCUMENTACION/README.md [S]
- [ ] Commit + push realizados [S]

## L. Integración GitHub Copilot / VS Code

- [x] Investigar la configuración MCP oficial de VS Code para Copilot (`.vscode/mcp.json`) [M]
- [x] Registrar el servidor `screen` con rutas `${workspaceFolder}` [S]
- [x] Registrar el servidor `godot` con `GODOT_PATH` del proyecto [S]
- [x] Validar sintaxis JSON de `.vscode/mcp.json` [S]
- [x] Validar existencia de los ejecutables locales registrados [S]
- [x] Validar sintaxis JavaScript del build de Godot MCP [S]
- [x] Documentar diferencia entre `servers`, `mcpServers` y `mcp` [S]
- [x] Confirmar tools desde `MCP: List Servers` en la interfaz de VS Code [S]
- [x] Confirmar captura visual desde `screen.capture_screen` en Copilot [M]
- [ ] Verificar conexión V5 Blender desde Copilot con socket 9876 activo [M]

**Totales:** 153 ítems · Completados: 73 · Pendientes: 80 · No resueltos: 0
**Nota:** la documentación del módulo está completa (incluida la Vía V5 Blender agregada el 2026-08-22); los ítems pendientes son de **implementación operativa** (instalación de MCPs, tests reales), que requieren el proyecto Godot base (M04), Blender instalado, o decisiones del usuario sobre qué herramienta comunitaria adoptar. **V5 quedó operativa y verificada el 2026-08-24** (Blender 4.2.3 LTS + addon + test get_scene_info exitoso), y se creó la guía maestra de conexión `06-GUIA-DE-CONEXION-VISION.md`. **V4 (godot-mcp) quedó operativa y verificada el 2026-08-24** (Coding-Solo/godot-mcp clonado y compilado, registrado en cline_mcp_settings.json con GODOT_PATH, tests get_godot_version 4.7.2 y get_project_info exitosos).
