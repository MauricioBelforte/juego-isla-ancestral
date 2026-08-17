**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 53: UI/UX

## 1. Análisis del dominio

La UI de un cozy game con mundo voxel en Godot 4.x debe resolver tres tensiones:

1. **Input dual**: teclado/mouse y gamepad conviven en tiempo real (Steam Deck incluido). El mismo botón (ej: "A"/Espacio) significa "confirmar" en una pantalla y "actuar sobre el mundo" en el HUD. Separar correctamente ambos contextos es la decisión central.
2. **Capas superpuestas**: HUD siempre visible + pantallas modales (inventario, diálogo, pausa) + popups (notificación, confirmación, tooltip). Cada capa debe declarar qué input consume y qué estado de pausa requiere.
3. **Acoplamiento con gameplay**: por regla de M07, la UI es "SPI hacia servicios": escucha eventos, no expone sus nodos a la gameplay. El diseño debe garantizar eso sin convertirse en un centro de mensajería monolítico.

## 2. Alternativas consideradas

### Alternativa A — Control del mundo (input centralizado fuera de la UI)

Un único node captura todos los eventos de input (`_unhandled_input`) y los reenvía manualmente a la pantalla activa; la UI no usa el sistema de foco de Godot, sino una tabla propia "ventana activa -> acción -> callback".

- **Pros:** control absoluto de prioridad; un solo lugar para decidir "a quién va este botón".
- **Contras:**
  - Duplica infraestructura que Godot 4 ya provee (focus, `gui_input`, `focus_neighbor`, `joypad_navigation`), aumentando superficie de bugs.
  - Rompe el foco nativo que usan los gadgets (sliders, option buttons, scroll) y dificulta la accesibilidad gratuita (navegación por tabulador, lectores).
  - El input que la UI no consume debe "devolverse al mundo" a mano: fácil fuente de fugas (botón tragado sin efecto).
  - Acopla a M57: cada acción (`ui_confirm`, `inventory_toggle`) se procesaría dos veces o se reasignaría manualmente.

### Alternativa B — Control directo de UI (foco nativo de Godot 4) + Action Layer de M57

Cada pantalla es una escena de `Control` con el foco correctamente cableado (`focus_neighbor`, `focus_next/focus_prev`); Godot enruta el input por `gui_input` al control enfocado. Las acciones **transversales** (abrir/cerrar inventario, pausar, confirmar, cancelar, tabular entre pestañas) se definen **una sola vez** en el sistema de acciones de M57 y la UI las escucha en modo "consumo" (`Input.action_press`) a nivel de UIManager, nunca tocando los eventos crudos del mundo.

- **Pros:**
  - 100% de los gadgets de Godot funcionan (sliders, listas, scroll, drag & drop) con foco, teclado y gamepad sin código custom.
  - La separación de contextos es declarativa: las capas modales usan `process_mode` para dejar de consumir el input del mundo cuando están abiertas; sin reenvíos manuales.
  - Accesibilidad más barata: el foco nativo es el que M58 necesita (navegación completa por teclado/gamepad).
  - M57 es la única fuente de verdad de "qué significa cada botón" (prompts dinámicos incluidos); la UI no define acciones.
- **Contras:** hay que cablear el foco con cuidado (wrap-around, foco inicial en la primera pestaña); mitigado por un `MenuNavigator` reutilizable (M53) y tests de navegación.

### Alternativa C — Híbrido (foco nativo + router de capas propio)

Como B, pero además un "router de capas" central que intercepta `close`, `tab_cycle` y `confirm` para orquestar la pila. En la práctica C se degrada a B con un `UIManager` bien diseñado; mantener un router extra hoy agrega código sin necesidad real decidida aún (reseva: si M76 multijugador/desconexiones exige acciones remotas, el router puede emerger como capa de presentación).

## 3. Decisión

**Se adopta la Alternativa B**: Control directo de UI en Godot (foco nativo) + Action Layer del sistema de acciones de M57 para las acciones transversales de la UI.

Justificación:

1. **Foco nativo = accesibilidad gratis**: navegación por tabulador, gamepad y lectores funcionan sobre controles reales; M58 se integra por parámetros (`ui_scale`, `high_contrast`, `reduce_motion`) y no por parche.
2. **Menos código, menos bugs**: no se reimplementa el enrutado de input; el 80% de la navegación es declarativa (editores de escena + `MenuNavigator`).
3. **M57 como única fuente de input**: las acciones `inventory_toggle`, `pause`, `confirm`, `cancel`, `tab_next` viven en el Action Layer; el HUD escucha las acciones del jugador (`move`, `interact`) solo cuando no hay capa modal abierta; sin doble procesamiento.
4. **Cero acoplamiento con gameplay**: la UI escucha eventos del EventBus (`ui.*`); la gameplay jamás llama a un nodo de UI; el UIManager es autoload de presentación, no de dominio.
5. **Rendimiento**: canvas merge y `low_processor_mode` se controlan por capa y por pausa; el minimapa es un widget liviano con caché de textura.

Decisión registrada en `03-Diseno.md` sección de integración; la Alternativa A queda descartada (motivo: duplicación del sistema de input de Godot y riesgos de fuga) y la C queda como reserva documentada para M76 (multijugador).

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Foco perdido al abrir/cerrar capas (edge case crítico) | `UIManager` guarda y restaura el foco; `MenuNavigator.focus_first()` idempotente; test de cierre/reapertura |
| Capa modal invisible que bloquea el input | Registro en pila con `process_mode` explícito; assert en debug que verifica pila y visibilidad (DOM-UI) |
| Diálogo + inventario simultáneos (edge case) | Política de pila: una sola capa de gameplay-modal a la vez; la segunda se encola y se abre al cerrar la primera |
| Cambio de resolución M90 rompe el layout | Modo de escalado `canvas_items` con base 1920x1080; re-dispatch del evento de redimension al ThemeUx; guardas de anchor |
| DoS por tooltips | Cola única de tooltip; un solo nodo reutilizado; retardo configurable; se cierra al cambiar foco |
| Draw calls en pausa | Capas modales en `process_mode` pausado no repintan el HUD por frame; merge de canvas por capa |
| Textos largos cortados (M87 locales) | Labels con `autowrap`, `clip_text` verificado en QA; prueba con locales largos (alemán) antes de lanzar |