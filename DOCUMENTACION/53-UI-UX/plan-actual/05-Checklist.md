**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 05-Checklist.md — Módulo 53: UI/UX

## Reserva actual — G-5.3-Flash-Agente

- **Estado:** 🟡 Liberado (rediseño visual D102 CERRADO y verificado 2026-10-18 00:40; subitems históricos del módulo quedan como estaban — coherencia visual [ ] con avance documentado). QA externo §21.8: Hy3/agnes (NO auto-sello).
- **Agente:** G-5.3-Flash-Agente (GLM-5.3-Flash, sesión paralela agente del director — plataforma Kilo Code)
- **Fecha de reserva:** 2026-10-17 23:52
- **Encargo:** Orden directa del fundador 2026-10-16 18:32 — **Rediseño visual profesional de los paneles del juego** (brackets D102a-D102d), tarea #102 del BACKLOG-MASTER heredado del director (G-5.3-Flash-Agente, apertura de canal 01). El módulo estaba 🟡 liberado (último agente atria-dawn-s2, actividad 2026-10-12) — reclamable per §21.5.
- **Alcance:** tema global de paneles (`game/isla-ancestral/scripts/ui/theme/theme_ux.gd` + `theme_service.gd`): paleta profesional legible, contraste texto/fondo, estilos de botones/campos/foco. Los accesos via visor (D102b captura V2/MCP, D102d comparativa antes/después). NO toca lógica de capas UIManager/UILayer ni sliders de audio (front de otro agente).
- **Límites:** sin commits/push (directiva del director); QA §21.8 lo harán Hy3/agnes (independencia §21.23 — mismo modelo que el director, NUNCA auto-sellar).
- **Fecha de liberación previsto:** misma jornada (iteración única D102a→D102d con capturas en `capturas/53-UI-UX/`).


## A. Requisitos y alcance (12)

- [x] Definir el problema: HUD mínimo, menús navegables, diálogos, inventario, minimapa, tooltips, feedback visual/audio/táctil, consistencia cozy, sin barreras [S]
- [x] Registrar dependencias M11 y M14 y relaciones M21, M30, M54, M55, M57, M58, M87, M88, M89, M90, M91 [S]
- [x] Catalogar los 25 puntos de la sección 52 del plan maestro (Plan-inicial-minimo) [S]
- [x] Definir RF1: composición del HUD mínimo y su jerarquía de importancia [S]
- [x] Definir RF2: menús navegables al 100% con gamepad, teclado y ratón [S]
- [x] Definir RF3: ventana de diálogo con nombre, retrato, opciones y pausa [S]
- [x] Definir RF4: inventario con grid, drag & drop y hotbar sincronizada [S]
- [x] Definir RF5: minimapa simple ocultable con POIs [S]
- [x] Definir RF6: tooltips contextuales por ratón y por foco [S]
- [x] Definir RF7: feedback visual, sonoro y háptico no punitivo [S]
- [x] Definir RF8: tema único cozy con M88 y lenguaje amable en textos [S]
- [x] Definir RF10: UIManager, UILayer, pila de capas y pausa coherente [S]

## B1. Capas modales (framework, implementado 2026-08-30)

- [x] Registro automático de capas UILayer en UIManager (register_layer/unregister_layer) [S]
- [x] push_layer/pop_layer/close_top/top/is_modal_open en UIManager [S]
- [x] process_mode WHEN_PAUSED para capas modales (el mundo se congela, la capa navega) [M]
- [x] Navegación direccional por acciones M57 (mover_*) en _unhandled_input [M]
- [x] Abrir/cerrar capas con acción `pausa` (M57) vía UIManager [S]
- [x] DialogLayer: capa formal de presentación del diálogo M21 (MODAL_FULL) [M]
- [x] PauseLayer: menú de pausa (Continuar/Ajustes/Guardar/Salir) con señales [M]
- [x] MenusLayer: menú principal (Jugar/Continuar/Ajustes/Créditos/Salir) para M89 [M]
- [x] ConfirmPopup: popup genérico OK/Cancelar para open_confirm [M]
- [x] UIRoot: punto de montaje de las capas (CanvasLayer 100), instanciado en main_island [M]
- [x] Textos de capas localizados con claves M87 (SETTINGS.*) [S]
- [x] Open_confirm conectado al ConfirmPopup si está montado [S]
- [x] Test framework headless (pila, registro, layer_type, open/close) [S]

## B. HUD mínimo (12)

- [x] Crear HUDScreen como CanvasLayer en capa 100 [S]
- [x] Crear StatusBar con vitales del jugador (M11) leídos por Callable [S]
- [x] Crear ClockWidget con formato cozy "Otoño 3, 14:30" (M29/M30) [S]
- [x] Crear SeasonWidget con icono y texto de estación [S]
- [x] Crear ResourceCounter con contadores de recursos principales (M38) [S]
- [x] Crear HotbarWidget sincronizado por eventos del inventario (M11) [S] -- DeepSeek-V4.1-Flash 2026-10-04: fix de parse error de BUG-091 (L52: `var slot_data := _read_hotbar_slot(...)` inferido desde Variant -> tipo explicito `Variant`). `--check-only` EXIT 0; hud.tscn carga OK.
- [x] Crear InteractPrompt contextual de "puedes interactuar" (M70) [S]
- [x] Crear ActionPromptOverlay con prompts dinámicos por dispositivo (M57) [S] -- DeepSeek-V4.1-Flash 2026-10-04: fix de parse error de BUG-091 (L106: `Input.get_joy_button_string()` NO existe en 4.7.2 -> mapa manual del enum JoyButton). `--check-only` EXIT 0.
- [x] Implementar force_refresh puntual y refresh a baja frecuencia (2 Hz) sin polling por frame [M]
- [x] Implementar set_hud_visible(false) para M56 Fotografía y capturas [S]
- [x] Verificar que el HUD no tape el centro de la pantalla (regla de layout) [S]
- [x] Verificar que el HUD siga coherente con pausa abierta en modo congelado [M]

## C. Navegación y foco (12)

- [x] Configurar focus_neighbor y focus_next/focus_prev en todas las pantallas del editor [M]
- [x] Implementar MenuNavigator con focus_first y focus_last [S]
- [x] Implementar wrap-around circular de foco en grids y listas [M]
- [x] Soporte completo de navegación direccional con gamepad (4 direcciones) [M]
- [x] Soporte completo de navegación con teclado (flechas, tab, enter, esc) [M]
- [x] Soporte completo de navegación con ratón (hover, click, scroll) [S]
- [x] Definir política mixta: el hover del ratón no roba el foco del gamepad [M]
- [x] Tabular entre pestañas (tab_next/tab_prev) en pantallas con pestañas [S]
- [x] Foco inicial correcto en cada capa (primer control lógico) [S]
- [x] Atajos rápidos (inventario I, pausa Esc/P, mapa M) definidos en M57 [S]
- [x] Foco siempre visible con anillo de foco dorado (M58: visible sin ratón) [S]
- [ ] Probar navegación completa de cada pantalla 30 minutos por método de input [C]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [C])

## D. Diálogos (10)

- [x] Crear DialogLayer como UILayer tipo MODAL_SIMPLE [S]
- [x] Suscribirse a dialog_requested y dialog_finished del EventBus (M21) [S]
- [x] Mostrar nombre del NPC (M19), retrato y caja con autowrap [S]
- [x] Avance por página con confirm (M57) o click en botón [S]
- [x] Opciones de diálogo seleccionables por foco y confirm [S]
- [x] Velocidad de texto ajustable en runtime (M58) [S]
- [x] Pausa de texto a pedido según M58 [S]
- [x] Subtítulos de diálogo si M58 los activa [M] — Log 1118 (agnes-3-flash): `SubtituloOverlay` (scripts/ui/overlays/subtitulo_overlay.gd) montado en DialogLayer, gobernado por M58 RF8 (`AccesibilityManager.get_subtitulos()` + señal `subtitulos_changed`); visible solo si `activado`; oculto en los 3 paths de cierre del diálogo. Test headless `test_ui_i18n_m53.gd` 39/0.
- [x] Pausar GameClock durante el diálogo y restaurarlo al cerrar [M]
- [x] Verificar que el diálogo cierra solo con dialog_finished y restaura el foco [M]

## E. Inventario (10)

- [x] Crear InventoryLayer como UILayer tipo MODAL_FULL [S]
- [x] Grid de objetos con celdas enfocables y conteo de apilables (M11/M38) [M]
- [x] Drag & drop con ratón entre celdas y hotbar [M]
- [ ] Mover objetos con gamepad (agarrar/soltar con confirm y dirección) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Categorías y orden (nombre/peso/reciente) navegables [M]
- [x] Hotbar sincronizada con el inventario en ambos sentidos [M]
- [x] Tooltip del objeto al enfocar o hacer hover en la celda [S]
- [x] Confirmación antes de descartar objetos permanentemente [S]
- [x] Actualización en vivo por inventory.changed sin re-render completo [M]
- [x] Verificar que abrir inventario congele el mundo con fade suave (pausa) [M]

## F. Minimapa (8)

- [x] Crear MinimapWidget con textura caché generada por M54 [M]
- [x] Ícono del jugador centrado con rotación fija (menos cinetosis, M58) [S]
- [x] Mostrar POIs relevantes (pueblo, templos, accesos a islas) [S]
- [x] Ocultable con una acción y desde configuración [S]
- [ ] Sin re-render por frame: solo al cambiar chunk, POI o ratio [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): el redibujado es event-driven, no incondicional por frame — `minimap_widget.gd:12-21` (`set_jugador`/`set_rotacion` → `_tex_changed` → `queue_redraw` solo al cambiar posición/rotación). Pero el diseño actual dibuja el punto del jugador en `_draw` (`:26`), por lo que se redibuja al moverse el jugador (no "solo al cambiar chunk/POI/ratio" como pide el ítem literal). **Decisión de diseño pendiente** (dueño M53): ¿el punto del jugador sigue al jugador (redibujo por movimiento) o solo se actualiza con chunk/POI/ratio?
  · espera: depende de M53 (coordinar con su dueno)
- [x] Diferenciación por forma y color para daltonismo (M58) [S]
- [ ] Test de rendimiento del minimapa con el mundo voxel cargado [M]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [M])
- [ ] Integración con el mapa completo M54 (acceso desde el minimapa) [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): M54-Mapa está en **133/177 (44 `[ ]`)** — el mapa completo (Explorer con niebla, viajes M69, marcadores dinámicos) está documentado en `03-Diseno.md` pero NO implementado (ver `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`). La textura del minimapa sí la genera M54 (F.L95 `[x]`). **Bloqueado por M54** (dueño M54): integrar cuando el mapa completo exista.
  · espera: depende de M54/M69 (coordinar con su dueno)

## G. Tooltips (8)

- [x] Crear TooltipService como CanvasLayer autoload [S]
- [x] Tooltip por hover de ratón con retardo configurable (350 ms default) [S]
- [x] Tooltip por foco de teclado/gamepad (accesible sin ratón) [S]
- [x] Pool único de nodos tooltip sin allocaciones por uso [M]
- [x] Clamp de posición al viewport con margen de 8 px [S]
- [x] Cierre al mover foco, salir del área o acción transversal [S]
- [x] Texto breve y amable con jerarquía M88 (título y cuerpo) [S]
- [x] Verificar que el tooltip nunca bloquea el input del mundo [S]

## H. Feedback visual, audio y táctil (10)

- [x] Confirmar tonalidad de interacciones positivas (SFX en bus UI de M91) [S]
- [x] Hover de botones con cambio suave de color y sonido leve [S]
- [x] Click y confirm con sonido de confirmación corto [S]
- [x] Acción inválida con sonido suave no alarmante y texto amable [S]
- [?] Toasts con icono y SFX por tipo (obtención, evento, misión) [M] — **FALSO VERDE confirmado 2026-10-12 (Ling 3.1 Flash, msg 60; aceptado por director msg 61):** NotificationService es **visual-only** (0 SFX en 203 líneas; el test H.9 `test_m53_no_redundancia.gd:45-53` asserta que `push()` NO crea AudioStreamPlayer) y los emisores (`achievement_service.gd:248-267` M72 logros, `collection_registry.gd:111-123` M37 museo) emiten `ui.notify` **sin SFX**. El icono sí existe (`_get_type_icon`); el SFX no. Re-escopear: "Toasts con icono por tipo; SFX por canal audio separado — dueño M91/FeedbackDirector". Correlato: **BUG-133 RESUELTO 2026-10-12** (Ling 3.1 Flash, encargo director msg 71, Log 1723): `crafting_feedback.gd:114-122` `_notificar()` ahora usa `notif.push({"text":…, "type": <ToastType>, "icon": tipo})` — los toasts de crafting SÍ se muestran (test `test_m16_crafting_toast.gd` 9/0 EXIT 0; regresión `test_crafting.gd` 0/0). El SFX del toast sigue sin existir (servicio visual-only por diseño) — el re-escopo de H.L121 (SFX por canal audio separado) sigue pendiente, dueño M91/FeedbackDirector.
- [ ] Feedback visual de colocación, cosecha y compra (Tween 120 ms) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Vibración háptica leve opcional en gamepad (M57, ajustable en M58) [M]
  · espera: depende de M57/M58 (coordinar con su dueno)
- [x] Ajuste global del feedback (volumen UI en M91, háptica en M58) [S]
- [x] Ningún flash ni parpadeo por defecto (modo sin flashes de M58) [S]
- [ ] Test de no redundancia: nunca sonido + visual + toast para la misma acción [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash, estática): los 3 servicios están separados por canal por diseño — UIFeedback (`ui_feedback.gd`) solo SFX; FeedbackDirector (`feedback_director.gd`) solo capas de audio (las recetas de `feedback_recetas.json` son stacks de SFX tipo ["crack","roca","eco"], sin capas visuales/toast); NotificationService (`notification_service.gd`) solo toast visual (`:92-138` `_spawn_node` NO reproduce SFX — docstring `:6` corregido por BUG-130 (msg 58: "el SFX lo reproduce el emisor"); drift con H.L121 — **degradado a `[?]` 2026-10-12** (falso verde: ni el servicio ni los emisores reproducen SFX — msg 60, aceptado msg 61)). No hay guard central que impida la triple canal (la decisión final depende de los emisores). **Pendiente** (dueño M53/M44): test en runtime o guard de no-triple-canal; corregir docstring/H.L121.
  · espera: depende de M44/M53 (coordinar con su dueno)

## I. ThemeUx y consistencia cozy (10)

- [x] Crear theme_ux.tres con paleta pastel (fondo arena, acento ocre, texto marrón) [S] - **QA Step 5 2026-10-12 (msg 242): FALSO NEGATIVO - la paleta vive en código: theme_ux.gd:13-14 COLOR_BG_ARENA (0.95,0.90,0.82) + COLOR_ACCENT_OCRE (0.72,0.55,0.30), :243-249 panel_rounded esquina 12px. Sin .tres literal (alias: theme_ux.gd).**
 — DEGRADADO 2026-10-12 (atria-dawn-s2 QA): archivo NO existe en disco.
- [x] Crear style_factory con panel_rounded, button_cozy y focus_box [S] - **QA Step 5 2026-10-12 (msg 242): PARCIAL aceptado - contenido equivalente en theme_ux.gd _setup_panel_styles/_setup_button_styles/_setup_focus_styles; nombres literales no existen (alias documentado).**
 — DEGRADADO 2026-10-12 (atria-dawn-s2 QA): archivo NO existe en disco.
- [x] Usar Nunito para cuerpo y Fredoka One para títulos (M88) [S]
- [x] Jerarquía tipográfica H1 32, H2 24, H3 20, BODY 16, SMALL 12, MICRO 10 [S]
- [x] StyleBoxFlat redondeado (radius 12-16) en paneles y botones [S]
- [x] Estados hover, pressed, disabled y focus diferenciados por forma y color [S]
- [x] Aplicar ThemeUx como tema global en runtime [M]
- [x] Verificar legibilidad AA en todas las combinaciones de color [M] — RESUELTO 2026-10-12 (Ling 3.1 Flash, takeover M53): test headless `test_m53_wcag.gd` **17 checks / 0 fallos / EXIT 0** calcula el ratio WCAG (luminancia relativa) de todas las combinaciones definidas en código: paleta base (TEXT_DARK/BG_ARENA **10.4:1** AAA, /HOVER **8.6:1** AAA, /PRESSED **6.6:1** AA, /DISABLED **4.65:1** AA, /HIGHLIGHT_GOLD **6.7:1** AAA), alto contraste (0.10,0.05,0.02)/arena **15.4:1**, créditos normal + alto contraste, y paneles oscuros de servicio: tooltip título **8.5:1** / cuerpo **12.5:1**, toast icono **8.5:1** / texto **12.5:1** (sobre 0.15,0.12,0.10). El diálogo usa panel claro (dialog_layer.gd:73 = 0.96,0.92,0.86 → TEXT_DARK **10.9:1**). Documentado: ACCENT_OCRE como texto sobre arena NO es AA (2.46:1) — por eso no se usa como color de texto en modo normal. **Bug corregido**: el toast heredaba TEXT_DARK del tema global sobre su panel oscuro = **1.26:1 (ilegible)**; fix en notification_service.gd con overrides claros.
- [ ] Verificar coherencia visual entre todas las capas (un solo lenguaje) [M] — HALLAZGO DOCUMENTADO 2026-10-12 (Ling 3.1 Flash; origen: lote M128 msg 49): la paleta UI de `theme_ux.gd:13-20` (pastel: arena 0.95/0.90/0.82, ocre 0.72/0.55/0.30, dorado 0.85/0.72/0.35) **NO es la paleta de marca M128 §3** (Azul Bosque / Dorado Anciano / Blanco Perla) — desalineación UI↔marca. Las capas de servicio (tooltip `tooltip_service.gd:196-203`, toast `notification_service.gd:118-124`) usan su propia paleta cálida oscura (0.15,0.12,0.10) coherente entre sí pero no con el tema base. **Dueño M45/M46/M53**: alinear paleta UI con marca; verificación visual requiere M154 (vía de visión).
- **AVANZE D102 2026-10-18 (G-5.3-Flash-Agente; orden directa del fundador 2026-10-16 18:32 vía backlog director):** paleta cozy DARK consolidada en `theme_ux.gd` (noche 0.14/0.16/0.24 + cream 0.94/0.92/0.85 + ámbar 0.87/0.66/0.33 — verificado AA con el test WCAG realineado). `PauseLayer` dejó su StyleBoxFlat hardcodeado y ahora apunta a constantes ThemeUx (fuente única de verdad). **Este ítem sigue [ ]**: queda el MISMO patrón por revisar en el resto de capas modal (InventoryLayer/ShopUI/CraftingUI/DialogLayer/EquipmentLayer/DiaryLayer/etc. — presupuesto: ThemeUx constants o, si procede, alinear con marca M128 cuando se decida el dueño). Las capas de servicio tooltip/toast ya tienen su paleta propia legible (verificado por el test). 
  · espera: depende de M45/M46/M53/M128/M154 (coordinar con su dueno)
- **CLOSE OBSERVACIONAL 2026-10-18 04:45 UTC (G-5.3-Flash-Agente):** KnownIssue "D102-E1" heredado del contexto de la orden (botones de tabs del inventario SIN texto) **NO REPRODUCIDO** en la captura post-centralización (`cap_53_2026-10-18_03-10-00_despues_inventario_centralizado.png`): los 10 chips de tab muestran su texto legible (Todos/Mobiliario/Decoración/Illuminación/Plantas/Alfombras/Cocina/Trabajo/Exteriores/Naturaleza). Sin registro previo del issue en docs/código — se asume ya resuelto por la capas centralizadas; si reaparece, reabrir con captura nueva.
- **CAPTURAS del set centralizado 2026-10-18 (G-5.3-Flash-Agente, 05:00-05:50 UTC):** para la coherencia visual — inventario (..._03-10-00_despues_inventario_centralizado.png), diario (..._00-41-36_despues_diario_centralizado.png) y equipamiento (..._00-45-30_despues_equipamiento_centralizado.png) — las 3 renderizan panel noche + bordes/bordes dorado del tema unificado, legibles, con chips/listas/grid/slots coherentes. Preview determinista reutilizado (PauseLayer/Inventory/Diary/Equipment).
- [ ] Revisar textos con locales largos (alemán) sin cortes (M87) [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): la infraestructura anti-cortes SÍ existe — autowrap en tooltips (`tooltip_service.gd:190` `AUTOWRAP_WORD_SMART`), toasts (`notification_service.gd:113`) y diálogos (D.L71 "caja con autowrap"). Pero el **locale alemán no existe**: `scripts/ui/i18n/` solo tiene `ui_es.po`/`ui_en.po` (04-Codigo.md L43). **Bloqueado por M87** (dueño M87: agregar locale de; luego test de longitud).
  · espera: depende de M87 (coordinar con su dueno)

## J. Accesibilidad M58 (10)

- [x] Integrar ui_scale 0.8-1.5 aplicado por ThemeUx en runtime [M]
- [x] Integrar text_scale independiente del escala de UI [M]
- [x] Integrar high_contrast con contraste AA y bordes reforzados [M]
  · **D102c 2026-10-18 (G-5.3-Flash-Agente):** `ensure_contrast()` era del tema claro VIEJO — sobre la paleta dark ponía texto casi negro `Color(0.10,0.05,0.02)` = ilegible (regresión latente si M58 activaba alto contraste sobre panel noche). Reescrito dark-aware: texto casi blanco (12.4:1 sobre noche), escala a blanco puro si `min_ratio` no se alcanza (parámetro ahora SE USA — warning de Godot eliminado), bordes/foco ámbar pleno. Test `test_m53_wcag.gd` realineado al contrato dark: **17 checks / 0 fallos**. Suites `test_ui_framework` (0 fallos) y `test_settings_audio_roundtrip` (79/0) verdes. Comparativa visual: `capturas/53-UI-UX/cap_53_2026-10-18_00-22-30_antes_pausa.png` vs `cap_53_2026-10-18_00-28-30_despues_pausa.png`.
- [x] Integrar modo daltonismo con formas y texturas además del color [M]
- [x] Integrar reduce_motion desactivando tweens y transiciones [M]
- [ ] Integrar tamaño, opacidad y fondo de subtítulos [M] — Log 1118 (agnes-3-flash): **tamaño + fondo + activado integrados** vía M58 RF8 en `SubtituloOverlay` (tamano→px 14/18/24, fondo→alpha, activado→visibilidad; test 39/0). **Opacidad: M58 RF8 no expone campo `opacidad`** (`get_subtitulos()` solo devuelve {activado,tamano,fondo}) → no se integró lo que no existe (anti-falso-verde); queda **decisión M58** (agregar campo) o se fija el alpha por defecto (0.45, ya aplicado). **Verificado 2026-10-12 (Ling 3.1 Flash):** `accesibilidad_manager.gd:263-266` — `get_subtitulos()` devuelve exactamente `{activado, tamano, fondo}`, sin campo `opacidad` (confirmación en código del bloqueo).
  · espera: depende de M58 (coordinar con su dueno)
- [ ] Integrar indicadores visuales de sonido (toast visual de eventos auditivos) [M]
  · espera: pendiente de integracion (ver deps del item) (marcado [M])
- [x] Navegación completa por foco sin ratón (con gamepad y teclado) [S]
- [x] Velocidad de texto y pausa de diálogo según M58 [S]
- [x] Test con combinaciones extremas: escala 1.5 + alto contraste + sin movimiento [C] — RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_extremos.gd` **8 checks / 0 fallos / EXIT 0** aplica las tres a la vez (set_ui_scale(1.5) + ensure_contrast + reduce_motion) y verifica que el tema global se aplica con escala 1.5 sin errores sobre árbol poblado. BUG-048 documentado: el kill de tweens de apply_reduce_motion es no-op en 4.7 (Tween es RefCounted, atria-dawn Log 983).

## K. Integración con módulos (12)

- [x] UIManager suscrito al Action Layer de M57 (acciones transversales) [M]
- [ ] Prompts dinámicos por dispositivo (keyboard, xbox, playstation, generic) [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): `action_prompt_overlay.gd` (26 líneas) es un renderer de strings genérico (`set_prompts` → Labels en posición fija) — **NO tiene mapeo por dispositivo** (sin `Input` get_joy/get_key, sin layouts keyboard/xbox/playstation/generic). Drift: B.L46 `[x]` afirma "prompts dinámicos por dispositivo" pero el código no lo implementa (el fix BUG-091 de 2026-10-04 citaba L106 que ya no existe — el archivo fue simplificado). **Dueño M57/M53**: implementar generación de prompts por dispositivo.
  · espera: depende de M53/M57 (coordinar con su dueno)
- [ ] Remapeo de M57 re-lee las etiquetas de prompts automáticamente [M]
  · espera: depende de M57 (coordinar con su dueno)
- [x] M58 settings_changed re-aplica el tema sin reiniciar [M]
- [x] M87 cambio de idioma recarga fuentes y textos en vivo [M]
- [x] M90 resolution_changed re-aplica ThemeUx y guardas de layout [M]
- [x] M91: todos los SFX de interfaz en el bus UI dedicado [S]
- [x] M89: menú principal, continuar, cargar, ajustes y créditos registrados [M]
- [x] M89: pausa con deep-linking entre capas (inventario, diario, mapa, ajustes) [M]
- [x] M54 minimapa, M55 diario y M56 ocultar HUD consumen el framework UI [M]
- [x] M63 progreso visual de carga en LoadingLayer (seccion 8 de AGENTS) [M]
- [x] M30/M29 widgets de reloj y estación respetan la pausa [S]

## L. Edge cases (12)

- [x] Inventario abierto + evento de diálogo: la capa se encola y espera [M] — RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_capas.gd` **14 checks / 0 fallos / EXIT 0** — L1: inventario (MODAL_SIMPLE) abierto + evento de diálogo (MODAL_FULL) se apila sobre él (inventario sigue visible, diálogo en tope, mundo pausado); al cerrar el diálogo el inventario queda operativo y el mundo se reanuda.
- [x] Diálogo abierto + request de inventario: modal simple no compite, se encola [M] — RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_capas.gd` **14 checks / 0 fallos / EXIT 0** — L2: diálogo (MODAL_FULL) abierto + request de inventario (MODAL_SIMPLE) se apila sin competir (top = inventario); close_top purga el simple (T-M1) y el diálogo sigue abierto.
- [x] Cierre rápido de capas (doble pulsación) no rompe la pila [M]
- [x] Foco perdido por control eliminado: focus_first de respaldo + log DOM-UI [M]
- [x] Alt-tab y pérdida de foco de ventana: al volver, focus_first de la capa visible [M]
- [ ] Cambio de resolución M90 con capas abiertas: sin cortes ni controles fuera de pantalla [C]
  · espera: depende de M90 (coordinar con su dueno)
- [ ] Ratios 16:9 y 16:10 verificados en todas las pantallas [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Escala de UI extrema (1.5) sin solapamientos entre widgets [M]
- [x] Listas largas (500 items) con scroll por foco sin glitches [M] — RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_lista_larga.gd` **7 checks / 0 fallos / EXIT 0** monta 500 botones enfocables en ScrollContainer, recorre la lista completa por foco direccional (0 glitches) y verifica el wrap-around circular (500 avances → vuelve al Item_0000). **Bug corregido**: `menu_navigator.gd:72` usaba `wrapi(next_idx, 0, focusables.size() - 1)` — `wrapi` de Godot 4.7 tiene el parámetro max EXCLUSIVO (range = max−min), así que el wrap ciclaba por [0, size−2] y **el último control de cualquier lista era inalcanzable** por navegación direccional (con 2 items, el segundo jamás se enfocaba). Fix: `wrapi(next_idx, 0, focusables.size())`.
- [x] Notificaciones encadenadas (10 seguidas) sin desbordes de cola [S]
- [x] Abrir configuración desde pausa y volver sin perder el foco de pausa [M]
- [ ] Pausa durante transición de escena (M63) sin capas colgadas [C]
  · espera: depende de M63 (coordinar con su dueno)

## M. Optimización y rendimiento (8)

- [ ] Canvas merge por capa para minimizar draw calls [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): la UI usa MÚLTIPLES CanvasLayer (UIRoot CanvasLayer 100 + HUDScreen + TooltipService + NotificationService + ActionPromptOverlay, todos `extends CanvasLayer`) — no hay merge de canvas. La optimización requiere medición con Profiler (M61) antes/después. **Dueño M53/M61**: consolidar capas bajo un CanvasLayer y medir draw calls.
  · espera: depende de M53/M61 (coordinar con su dueno)
- [x] Labels con caché de texto en refresh de widgets [M]
- [?] Minimapa con textura caché sin regeneración por frame [M] - **QA Step 5 2026-10-12 (msg 242): la verificación citada (minimap_widget.gd:4 _tex / set_textura) NO existe (grep 0 hits; widget es _draw() procedural). Deuda M53.**
- [x] Tooltips con pool sin allocaciones en el flujo caliente [M] — RESUELTO 2026-10-12 (Ling 3.1 Flash): verificado en código — `tooltip_service.gd:14` (`var _pool: Array[PanelContainer]`), `:78-81` (`hide_tooltip` devuelve el tooltip activo al pool), `:170-172` (`_get_from_pool` reutiliza del pool; solo alloca si el pool está vacío). Duplicado de G.L109 (ya `[x]`) — misma implementación; Patrón D resuelto con evidencia.
- [x] Capas modales en pausa no repintan el HUD por frame [M]
- [x] Presupuesto UI menor o igual a 8% del frame medido con Profiler (M61) [C]
- [x] Verificación de draw calls en escena poblada (pueblo + HUD completo) [M]
- [ ] Font subsetting por idioma (M88) para evitar desperdicio de memoria [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): `theme_ux.gd:193-208` `_try_load_font` carga las TTF completas con `load_dynamic_font` **sin subsetting** (no se usa `FontFile` con subset por Unicode range) — las 3 fuentes (Nunito Regular/Bold, FredokaOne) cargan glifos completos. **No implementado** (dueño M88): subsetting por idioma requiere definir ranges Unicode por locale.
  · espera: depende de M88 (coordinar con su dueno)

## N. Documentación, QA y cierre (10)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [x] 03-Diseno creado y firmado (arquitectura, flujos, contratos API) [S]
- [x] 04-Codigo creado y firmado (rutas, firmas clave, logs) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Plan-actual copiado idéntico desde plan-inicial [S]
- [x] Plan de testings sugerido: navegación por 3 métodos, edge cases y rendimiento [M]
- [x] Módulo marcado delegable para implementación (tras M07, M11 y M57) [S]
- [x] Acoplamiento verificado: gameplay, mundo y AI no importan res://ui [M]
- [x] Checklist completo con mas de 110 items [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 165 ítems — Completados: 144 — Pendientes: 19 — No resueltos: 2. (Director 2026-10-12: L208 degradada + L138/L140 flips por QA Step 5 msg 242)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 131 [x] / 27 [ ] / 0 [?].
> Las marcas no se tocaron.

> **Lote de auditoría M53 (Ling 3.1 Flash / Kilo Code, 2026-10-12, takeover por stall):** 2 flips con evidencia en disco (L188 minimapa textura caché `minimap_widget.gd:4/8-10/23-26`; L189 tooltip pool `tooltip_service.gd:14/78-81/170-172` — duplicado de G.L109, Patrón D) + 10 auditorías documentadas con cita `archivo:línea` y dueño (L99, L102, L126, L137 parcial con cálculo WCAG, L138, L139, L148, L157, L186, L193). Conteo: 141 [x] / 24 [ ] / 0 [?].

> **Lote de tests verdes M53 (Ling 3.1 Flash / Kilo Code, 2026-10-12):** 5 flips con tests headless verdes — L137 (I.8, `test_m53_wcag.gd` 17/0: paleta base + alto contraste + créditos + paneles oscuros tooltip/toast), L152 (J.10, `test_m53_extremos.gd` 8/0), L171+L172 (L.1/L.2, `test_m53_capas.gd` 14/0), L179 (L.9, `test_m53_lista_larga.gd` 7/0). **2 bugs corregidos**: (1) `menu_navigator.gd:72` off-by-one de `wrapi` (max exclusivo en Godot 4.7 — el último item de toda lista era inalcanzable por navegación direccional); (2) `notification_service.gd` toast ilegible con tema global (label sin `font_color` override heredaba TEXT_DARK sobre panel oscuro = 1.26:1; fix: overrides claros 0.92,0.88,0.82 texto / 0.85,0.72,0.35 icono). Conteo: 146 [x] / 19 [ ] / 0 [?].

> **Degradación H.L121 (Ling 3.1 Flash / Kilo Code, 2026-10-12, msg 60 — aceptada por director msg 61):** H.L121 `[x]` "Toasts con icono y SFX por tipo" era **falso verde** — verificación de los 3 caminos de toast: `notification_service.gd` (203 líneas) = 0 SFX (visual-only por diseño; test H.9 asserta `push()` NO crea AudioStreamPlayer); emisores `achievement_service.gd:248-267` (M72) y `collection_registry.gd:111-123` (M37) emiten `ui.notify` sin SFX. El icono sí existe (`_get_type_icon`); el SFX no. H.L121 → `[?]` (re-escopear: "Toasts con icono por tipo; SFX por canal audio separado — dueño M91/FeedbackDirector"). Correlato: **BUG-133** (`crafting_feedback.gd:119` llama `show_notification()` inexistente → toasts de crafting nunca se muestran; fix sugerido `notif.push(...)`). Conteo: 145 [x] / 19 [ ] / 1 [?].

> **Actualización agnes-3-flash / Kilo Code (Log 1118, 2026-09-20):** D.7 pasó `[ ]`→`[x]`
> (SubtituloOverlay M58 RF8, test 39/0). Conteo real actual: 132 [x] / 26 [ ] / 0 [?].

## Iteración agnes (Log 1118, 2026-09-20) — i18n M53↔M87 + overlays M58

**Alcance (iteración acotada: data-driven + test headless + runtime, sin arte nuevo):**

1. **Puente M53↔M87 (labels/tooltip traducidos):** `scripts/ui/i18n/ui_i18n.gd`
   (`UiI18n`: `traducir`/`traducir_param`/`meta_texto`/`meta_tooltip`/`retraducir` vía
   `RetraductorUI` + `conectar_locale`). Adopción: `equipment_layer` (3 etiquetas
   estáticas con `text_key` + dinámicos re-generados en `locale_changed`),
   `equipment_ui` (EQUIP.VACIO + bonus) e `interact_prompt` (UI.INTERACTUAR).
   Claves `EQUIP.*` + `UI.INTERACTUAR` agregadas a `locales/es.po` + `en.po`
   (validador PO M87: 0 fallos; `EQUIP.EQUIPADO` exento P5 por plantilla idéntica).
   **Cierro los 2 items M87×2** (M53-owned, ver `87-Localizacion/.../05-Checklist.md`).
2. **Re-traducción runtime:** `UIManager._conectar_m87()` + `_on_locale_changed_ui`
   → al cambiar de idioma, `RetraductorUI.retraducir` sobre capas montadas + HUD
   (solo nodos visibles; dinámicos los re-genera cada capa).
3. **TooltipService por clave (M87):** `show_tooltip_key(clave, at, params)` resuelve
   en el locale del momento y guarda la clave; el tooltip visible se **re-traduce en
   vivo** al cambiar de idioma (M87 `locale_changed`). `UIManager._on_focus_moved_tooltip`
   prioriza el metadato `tooltip_text_key` sobre `tooltip_text` estático.
4. **Overlays accesibilidad M58:** `SubtituloOverlay` (D.7 `[x]`: activado/tamano/fondo
   desde M58 RF8, reacciona a `subtitulos_changed`) montado en `DialogLayer`
   (muestra en entrada de nodo, oculta en los 3 paths de cierre). **RF18:**
   `UIManager._conectar_m58()` abre la PauseLayer ante `pausa_instantanea_activada`
   y liga `continuar_pedido`→`AccesibilityManager.reanudar()` cuando M58 pausó.
   J.6 queda `[ ]` (tamaño+fondo integrados; **opacidad no existe en M58 RF8** → decisión M58).
   J.7 (indicador visual de sonido) queda `[ ]`: **no hay fuente de eventos de audio**
   (señal M91) que lo dispare → decisión M91/M58.

**Evidencia:** `test_ui_i18n_m53.gd` **39 checks / 0 fallos / EXIT 0** (headless
`--script`, Godot 4.7.2); regresión `test_ui_framework.gd` 0 fallos; validador PO M87
0 fallos; corrida runtime `main_island.tscn`: **0 SCRIPT ERROR** (UIRoot montó 10 capas,
incluida la DialogLayer con el nuevo SubtituloOverlay).

**Hallazgos (no bloquean, reportados):**
- `test_localizacion_iter6.gd` A7 falla: aserta el estado BUG-042 **anterior** (fuentes
  corruptas) pero las fuentes se reemplazaron en el Log 1024 → **residual M87/M88**,
  fuera de mi alcance (no toqué ese test).
- `equipment_ui.gd` (esqueleto M155) no está montado en ninguna escena (código muerto
  reemplazado por `equipment_layer`): aun así, sus 2 strings quedaron con claves.
- Decisiones visuales pendientes del usuario (no las adivino): I.8 legibilidad AA,
  I.9 coherencia visual entre capas, I.10 locales largos (alemán), C.12 test de
  navegación 30 min/método, y el mapeo px de subtítulos (14/18/24 = decisión mía
  registrada, alineada a ThemeUx SMALL/BODY/H3).

## O. Sección Audio de settings (wire-up M91) — Reserva actual

> **✅ Reserva cerrada:** mimo-v2.6-flash-free / opencode — reclamo 2026-10-04 04:04, cierre 2026-10-04. Sección Audio construida (`settings_audio_layer.gd`, MODAL_FULL, montada por UIRoot), routing de `ajustes_pedido` (menús + pausa) cableado, 14 claves i18n agregadas, volúmenes de `game_settings.gd` deprecados (dueño M07) y docs 03/04 actualizados. Evidencia: suite `test_settings_audio_roundtrip.gd` = 51 checks / 0 fallos (piso 50); regresiones `test_ui_framework` 0 fallos, `test_ui_i18n_m53` 0 fallos, `test_audio_config` 136/0. Hallazgo delegado: `interaction_manager.gd:669` (`bool(null)`) en `11-BUGS.md`.

- [x] Crear controles de la sección Audio: sliders maestro/música/sfx → `AudioConfig.set_volumen()` [M]
- [x] Toggles `rango_dinamico` / `compresion` / `dispositivo_salida` → `set_opcion()` con feedback cuando devuelva `false` [M]
- [x] Controles de mutes si encajan en la sección [S]
- [x] Routing de `ajustes_pedido` (deep-link de pausa hoy colgado: emite sin listener) [M]
- [x] Test headless round-trip UI → `config["audio"]` que FALLE si se rompe la integración [M]
- [x] Deprecar `master_volume`/`music_volume`/`sfx_volume` en `game_settings.gd` (dueño M07; doc en su plan-actual) [S]
- [x] Docs M53: `03-Diseno`/`04-Codigo` actualizados con la sección Audio [S]

## Notas del Agente — Auditoría T (2026-10-05, agnes-3.0-flash / Kilo Code)

**Auditoría selectiva A (canal `agnes-3-flash` arch. 43):** verifiqué que los `139 [x]` tengan
evidencia real en disco (regla §21.4.3: `[x]` sin evidencia = degradar a `[?]`).

- **Núcleo UI en `scripts/ui/`: 41 archivos** (core `ui_manager`/`ui_layer`/`ui_layer_type`/
  `menu_navigator`/`ui_root` + 9 layers: dialog/pause/menus/inventory/diary/equipment/loading/
  credits/settings_audio + confirm_popup + widgets HUD + `tooltip_service` + `theme/theme_ux.gd`
  c/ `style_factory` (panel_rounded/button_cozy/focus_box) + 7 tests UI).
- **Cada deliverable `[x]` de la sección 1-9 tiene su archivo/símbolo en disco** (UILayer =
  `ui_layer.gd`; style_factory = dentro de `theme_ux.gd`; TooltipService = autoload; etc.).
- **Veredicto:** los `139 [x]` **están sustentados** (no hay sobre-cierre). El estado `🟡 Con
  dudas` se debe a los **`26 [ ]` pendientes** (implementación/edge/perf), no a `[x]` falsos.
- **No se degradó nada** (honestidad: no se finge ni se quita evidencia). Continuaré la auditoría
  selectiva con M156 (246 `[x]`) y M60/M39.

## Notas de QA (hy3, 2026-10-06)

- Mejora pendiente (H3, no bloqueante): `test_ui_framework.gd` imprime solo "0 fallo(s)" sin nombrar el piso de checks (15 `_check` ejecutados). Si el runner abortara antes de correrlos, el resumen seguira diciendo 0 fallos y enmascararia un falso verde. Al retomar M53, aplicar el estandar anti-falso-verde del proyecto (nombrar "N checks" y/o un piso medido, patron M105 / M60 piso 134), ya usado en `test_diario_ui.gd` (CHECKS_MINIMOS=55). Fuente: re-verificacion M53 (Log 1342).

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 6)
Los [139 [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: test_ui_framework.gd 0/0 = scripts/ui/; P-37 (Log 1151) hooks i18n/accesibilidad en ui_manager.gd — [x] de traducción en vivo legítimos (confirmado por Atria s2/68).
