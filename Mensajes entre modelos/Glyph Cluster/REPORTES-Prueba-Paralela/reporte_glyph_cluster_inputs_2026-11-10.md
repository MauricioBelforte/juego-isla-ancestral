# Reporte: Análisis de sistema de inputs en isla-ancestral

**Fecha:** 2026-11-10  
**Analista:** Glyph Cluster  
**Objetivo:** Analizar gestión de entradas (teclado/mouse/gamepad), validación, problemas, bindings y sugerencias de mejora

## 1. Archivos relacionados con inputs identificados

### Núcleo (game/isla-ancestral/)
- scripts/controls/control_input.gd (388 líneas) - Autoload \ControlInput\ (M57). Capa única de acciones. Gestiona dispositivos, remapeo, persistencia, vibración, deadzones, sugerencias de teclas libres.
- scripts/security/security_input_validator.gd (RefCounted) - Validador reutilizable para strings/int/float/email/enumeraciones con sanitización (elimina caracteres de control).
- scripts/player/player.gd - Usa \ControlInput\ vía \_accion_justa_m57()\ con fallback a \Input\ directo. Gestiona hotbar, herramientas, movimiento.
- scripts/tools/tool_controller.gd - Gestiona input de herramientas (E para golpear, Q para colocar) con \_physics_process\, respeta \input_habilitado\.
- scripts/farm/farm_tool_controller.gd - Control de herramientas agrícolas.
- scripts/vehiculos/vehicle_controller.gd - Control de vehículos.
- scripts/hardware/hardware_detector.gd - Detección de hardware/dispositivos.
- scripts/ui/layers/pause_layer.gd\, \scripts/debug/debug_menu.gd\, \scripts/dialogos/ui/dialogue_ui.gd\, etc. - Usan \Input\ directamente en distintos contextos.
- \project.godot\ ([input]) - Define acciones globales con bindings por defecto (WASD, E, B, 1-9, ESC).

### Tests relacionados
- \scripts/controls/test_control_input.gd\, \scripts/controls/test_migracion_m57.gd\
- \scripts/security/test_security_m106_input.gd\
- \scripts/debug/test_debug_menu_control_m110.gd\

## 2. ¿Cómo se gestionan las entradas de usuario?

### Arquitectura actual
1. **InputMap nativo de Godot** - Definido en \project.godot\ bajo \[input]\ con acciones como \mover_norte/sur/este/oeste\, \interactuar\, \inventario\, \pausa\, \hotbar_1..9\, \colocar\.
2. **Capa única (ControlInput autoload)** - \ControlInput\ (\scripts/controls/control_input.gd\) actúa como wrapper:
- Métodos convenientes: \ccion_presionada()\, \ccion_justa()\, \eje()\, \ector_movimiento()\, \ejes_camara()\.
- Detección automática de dispositivo activo (\_unhandled_input\) emite \dispositivo_cambiado\. Detecta teclado/ratón/gamepad por tipo de evento.
- Identifica marca de gamepad (xbox/playstation/generico) basándose en nombre.
- Sistema de remapeo en caliente con detección de conflictos (\emapear()\, \hay_conflicto()\).
- Sugerencias de teclas libres ante conflictos (\sugerir_tecla_libre()\).
- Persistencia atómica JSON en \user://settings/controls.cfg\ con backup.
- Deadzones configurables, sensibilidad/inversión, vibración.
- Etiquetado para UI según dispositivo activo (\etiqueta_accion()\).

3. **Uso en gameplay**
- \player.gd\ usa \_accion_justa_m57()\ que consulta \/root/ControlInput\ si existe, con fallback a \Input.is_action_just_pressed()\.
- \	ool_controller.gd\ usa \Input.is_key_pressed(KEY_E/Q)\ directamente en \_physics_process()\ (mientras \input_habilitado\), sin pasar por ControlInput.
- Muchos otros scripts usan \Input\ directamente (UI, menús, debug, etc.).

## 3. ¿Hay validación de inputs antes de usarlos?

**Parcial / limitada:**
- **ControlInput**: No valida \"input\" del usuario en sentido de sanitización; valida lógica (deadzone para ejes, detección de conflictos en remapeo). Aplica normalización de ejes.
- **SecurityInputValidator** (\scripts/security/security_input_validator.gd\): Sí ofrece validación/sanitización para datos de entrada (strings, ints, floats, emails, enumeraciones). Elimina caracteres de control con regex, trunca longitudes, valida rangos. Es un \RefCounted\ reutilizable (M106). Existe test \	est_security_m106_input.gd\.
- **Gameplay**: Mayormente confía en el InputMap de Godot y en las acciones definidas. No hay validación sistemática de \InputEvent\ antes de procesarlos fuera de ControlInput. Algunos scripts verifican estado (\input_habilitado\) antes de actuar.

**Observación:** La validación está más orientada a \"datos\" (SecurityInputValidator) que a \"eventos de input\" en tiempo real. Falta una política unificada para validar eventos en UI/diálogos/formularios.

## 4. ¿Hay problemas de inputs fantasma o duplicados?

**Riesgos detectados:**
- **Uso mixto de ControlInput vs Input directo**: \	ool_controller.gd\ usa \Input.is_key_pressed(KEY_E/Q)\ directamente, \player.gd\ usa ControlInput para acciones pero también hace polling directo en \_unhandled_input\ para teclas numéricas (hotbar) con \_event.keycode\. Esto puede crear comportamientos inconsistentes entre sistemas.
- **_unhandled_input vs _physics_process polling**: Algunos sistemas usan polling (\_physics_process\ con \is_key_pressed\) otros usan eventos (\_unhandled_input\). El comentario en \	ool_controller.gd\ dice \"M13: E/Q los procesa ToolController (polling en _physics_process, evita handlers duplicados §9.29)\" pero eso puede generar \"phantom inputs\" si no se controla bien el foco/UI.
- **input_habilitado**: \	ool_controller.gd\ tiene \input_habilitado\ (apagado cuando inventario abierto). \player.gd\ no muestra un flag global unificado; cada sistema controla su propio gating. Sin un gestor central de \"contexto/UI modal\", hay riesgo de inputs que se cuelan entre menús/juego.
- **Múltiples _unhandled_input**: \ControlInput\ tiene \_unhandled_input\, \player.gd\ también lo tiene. Godot propaga eventos; puede haber consumo parcial o doble procesamiento dependiendo del árbol.
- **Teclas hardcodeadas**: En \player.gd\ \_unhandled_input\ maneja \KEY_1..6\ directamente (hotbar). En \project.godot\ ya hay acciones \hotbar_1..9\ definidas - existe duplicidad conceptual.

**Conclusión sobre fantasma/duplicados:** No hay evidencia obvia de \"inputs fantasma\" sistemáticos, pero el uso mixto (ControlInput + Input directo + hardcodeo de teclas) crea potencial para duplicados/solapamientos. Falta una política estricta de \"única fuente de verdad\" para input.

## 5. ¿Hay bindings de teclado configurados correctamente?

**Estado:**
- **project.godot**: Bindings por defecto bien definidos para movimientos (WASD con \physical_keycode\), acciones principales (E, B, 1-9, ESC). Deadzone 0.2 para movimiento (correcto para acciones direccionales).
- **ControlInput**: Soporta remapeo completo con persistencia, detección de conflictos, sugerencias de teclas libres, restauración a defaults. Implementa serialización/deserialización correcta. Usa \physical_keycode\ para teclas (mejor para layouts).
- **Categorías**: \ACCIONES_CATALOGO\ incluye las acciones principales de gameplay.
- **Problemas menores:**
  - Algunos sistemas ignoran ControlInput y usan \Input.is_key_pressed(KEY_E)\ directamente (tool_controller, ciertos UI). Esto rompe la capa única en esos contextos.
  - \hotbar_1..6\ están en \project.godot\ y \player.gd\ también las maneja con hardcodeo en \_unhandled_input\ (posible doble manejo). \hotbar_7..9\ solo están en project.godot.
  - \colocar\ está definido en \project.godot\, pero \	ool_controller.gd\ usa \KEY_Q\ directamente para colocar.
  - Falta consistencia: algunas acciones usan ControlInput, otras usan keys directas.

## 6. Sugerencias de mejora (2)

### Mejora 1: Unificar todas las entradas bajo ControlInput (única fuente de verdad)
**Problema:** Uso mixto de \Input\ directo y \ControlInput\ crea inconsistencia, dificulta remapeo global y puede generar inputs duplicados/fantasma.

**Acciones propuestas:**
- Añadir a ControlInput métodos para acciones de herramientas: \golpear_presionado()\ / \colocar_justa()\ basados en acciones del InputMap (añadir \golpear\, \colocar\ a ACCIONES_CATALOGO si no están) o mapear las teclas via ControlInput.
- Migrar \	ool_controller.gd\ para usar \ControlInput\ (ej. \ControlInput.accion_presionada("golpear")\ / consultar vía InputMap pero centralizado). O bien extender ControlInput con polling unificado.
- Eliminar hardcodeo de \KEY_1..6\/\KEY_E\/\KEY_Q\ fuera de ControlInput; usar acciones.
- Implementar un \"InputContextManager\" (autoload) que gestione qué contexto (juego/UI/inventario/diálogo) tiene prioridad y cancele inputs no deseados.

**Beneficios:** Remapeo completo funcional, mejor soporte de gamepad, menos errores, comportamiento consistente.

### Mejora 2: Fortalecer validación y prevención de inputs fantasma/duplicados
**Problema:** Sin validación unificada de eventos, sin sistema central de gating por contexto/modal, riesgo de solapamiento entre múltiples \_unhandled_input\.

**Acciones propuestas:**
- Crear un autoload \InputManager\ que centralice \_unhandled_input\/polling, gestione stack de contextos (gameplay/UI/modal/dialogue/pause), y solo envíe eventos al contexto activo.
- Extender \SecurityInputValidator\ o crear \InputEventValidator\ para validar \InputEvent\ (filtrar eventos sospechosos/duplicados, verificar dispositivo, etc.) - especialmente útil para inputs no confiables.
- Añadir debounce/throttle para acciones críticas (golpe, colocar) en ControlInput para prevenir múltiples activaciones accidentales.
- Documentar política: \"solo ControlInput + InputManager acceden a Input; el resto consulta vía ellos\".

**Beneficios:** Prevención de inputs fantasma, mejor UX en menús, arquitectura más segura y mantenible.

## Conclusión final

El proyecto tiene una base sólida para gestión de inputs con **ControlInput (M57)** como capa única con remapeo, persistencia, detección de dispositivo y gamepad. Sin embargo, **la arquitectura está parcialmente implementada**: varios sistemas clave (\	ool_controller.gd\, manejo de hotbar en \player.gd\, ciertos UI) aún usan \Input\ directo o teclas hardcodeadas, rompiendo la \"única fuente de verdad\". La validación está mejor desarrollada para **datos** (\SecurityInputValidator\) que para **eventos de input** en tiempo real. No hay evidencia de inputs fantasma masivos, pero el uso mixto presenta riesgos de duplicados y dificulta el remapeo global. Las mejoras propuestas van en la dirección de **unificar todo bajo ControlInput/InputManager** y **fortalecer el gating por contexto** para eliminar esos riesgos.