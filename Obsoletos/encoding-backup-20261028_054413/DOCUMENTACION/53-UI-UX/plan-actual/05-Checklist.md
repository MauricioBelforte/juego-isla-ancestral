**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 05-Checklist.md â€” MÃ³dulo 53: UI/UX

## Reserva actual â€” G-5.3-Flash-Agente

- **Estado:** ðŸŸ¡ Liberado (rediseÃ±o visual D102 CERRADO y verificado 2026-10-18 00:40; subitems histÃ³ricos del mÃ³dulo quedan como estaban â€” coherencia visual [ ] con avance documentado). QA externo Â§21.8: Hy3/agnes (NO auto-sello).
- **Agente:** G-5.3-Flash-Agente (GLM-5.3-Flash, sesiÃ³n paralela agente del director â€” plataforma Kilo Code)
- **Fecha de reserva:** 2026-10-17 23:52
- **Encargo:** Orden directa del fundador 2026-10-16 18:32 â€” **RediseÃ±o visual profesional de los paneles del juego** (brackets D102a-D102d), tarea #102 del BACKLOG-MASTER heredado del director (G-5.3-Flash-Agente, apertura de canal 01). El mÃ³dulo estaba ðŸŸ¡ liberado (Ãºltimo agente atria-dawn-s2, actividad 2026-10-12) â€” reclamable per Â§21.5.
- **Alcance:** tema global de paneles (`game/isla-ancestral/scripts/ui/theme/theme_ux.gd` + `theme_service.gd`): paleta profesional legible, contraste texto/fondo, estilos de botones/campos/foco. Los accesos via visor (D102b captura V2/MCP, D102d comparativa antes/despuÃ©s). NO toca lÃ³gica de capas UIManager/UILayer ni sliders de audio (front de otro agente).
- **LÃ­mites:** sin commits/push (directiva del director); QA Â§21.8 lo harÃ¡n Hy3/agnes (independencia Â§21.23 â€” mismo modelo que el director, NUNCA auto-sellar).
- **Fecha de liberaciÃ³n previsto:** misma jornada (iteraciÃ³n Ãºnica D102aâ†’D102d con capturas en `capturas/53-UI-UX/`).


## A. Requisitos y alcance (12)

- [x] Definir el problema: HUD mÃ­nimo, menÃºs navegables, diÃ¡logos, inventario, minimapa, tooltips, feedback visual/audio/tÃ¡ctil, consistencia cozy, sin barreras [S]
- [x] Registrar dependencias M11 y M14 y relaciones M21, M30, M54, M55, M57, M58, M87, M88, M89, M90, M91 [S]
- [x] Catalogar los 25 puntos de la secciÃ³n 52 del plan maestro (Plan-inicial-minimo) [S]
- [x] Definir RF1: composiciÃ³n del HUD mÃ­nimo y su jerarquÃ­a de importancia [S]
- [x] Definir RF2: menÃºs navegables al 100% con gamepad, teclado y ratÃ³n [S]
- [x] Definir RF3: ventana de diÃ¡logo con nombre, retrato, opciones y pausa [S]
- [x] Definir RF4: inventario con grid, drag & drop y hotbar sincronizada [S]
- [x] Definir RF5: minimapa simple ocultable con POIs [S]
- [x] Definir RF6: tooltips contextuales por ratÃ³n y por foco [S]
- [x] Definir RF7: feedback visual, sonoro y hÃ¡ptico no punitivo [S]
- [x] Definir RF8: tema Ãºnico cozy con M88 y lenguaje amable en textos [S]
- [x] Definir RF10: UIManager, UILayer, pila de capas y pausa coherente [S]

## B1. Capas modales (framework, implementado 2026-08-30)

- [x] Registro automÃ¡tico de capas UILayer en UIManager (register_layer/unregister_layer) [S]
- [x] push_layer/pop_layer/close_top/top/is_modal_open en UIManager [S]
- [x] process_mode WHEN_PAUSED para capas modales (el mundo se congela, la capa navega) [M]
- [x] NavegaciÃ³n direccional por acciones M57 (mover_*) en _unhandled_input [M]
- [x] Abrir/cerrar capas con acciÃ³n `pausa` (M57) vÃ­a UIManager [S]
- [x] DialogLayer: capa formal de presentaciÃ³n del diÃ¡logo M21 (MODAL_FULL) [M]
- [x] PauseLayer: menÃº de pausa (Continuar/Ajustes/Guardar/Salir) con seÃ±ales [M]
- [x] MenusLayer: menÃº principal (Jugar/Continuar/Ajustes/CrÃ©ditos/Salir) para M89 [M]
- [x] ConfirmPopup: popup genÃ©rico OK/Cancelar para open_confirm [M]
- [x] UIRoot: punto de montaje de las capas (CanvasLayer 100), instanciado en main_island [M]
- [x] Textos de capas localizados con claves M87 (SETTINGS.*) [S]
- [x] Open_confirm conectado al ConfirmPopup si estÃ¡ montado [S]
- [x] Test framework headless (pila, registro, layer_type, open/close) [S]

## B. HUD mÃ­nimo (12)

- [x] Crear HUDScreen como CanvasLayer en capa 100 [S]
- [x] Crear StatusBar con vitales del jugador (M11) leÃ­dos por Callable [S]
- [x] Crear ClockWidget con formato cozy "OtoÃ±o 3, 14:30" (M29/M30) [S]
- [x] Crear SeasonWidget con icono y texto de estaciÃ³n [S]
- [x] Crear ResourceCounter con contadores de recursos principales (M38) [S]
- [x] Crear HotbarWidget sincronizado por eventos del inventario (M11) [S] -- DeepSeek-V4.1-Flash 2026-10-04: fix de parse error de BUG-091 (L52: `var slot_data := _read_hotbar_slot(...)` inferido desde Variant -> tipo explicito `Variant`). `--check-only` EXIT 0; hud.tscn carga OK.
- [x] Crear InteractPrompt contextual de "puedes interactuar" (M70) [S]
- [x] Crear ActionPromptOverlay con prompts dinÃ¡micos por dispositivo (M57) [S] -- DeepSeek-V4.1-Flash 2026-10-04: fix de parse error de BUG-091 (L106: `Input.get_joy_button_string()` NO existe en 4.7.2 -> mapa manual del enum JoyButton). `--check-only` EXIT 0.
- [x] Implementar force_refresh puntual y refresh a baja frecuencia (2 Hz) sin polling por frame [M]
- [x] Implementar set_hud_visible(false) para M56 FotografÃ­a y capturas [S]
- [x] Verificar que el HUD no tape el centro de la pantalla (regla de layout) [S]
- [x] Verificar que el HUD siga coherente con pausa abierta en modo congelado [M]

## C. NavegaciÃ³n y foco (12)

- [x] Configurar focus_neighbor y focus_next/focus_prev en todas las pantallas del editor [M]
- [x] Implementar MenuNavigator con focus_first y focus_last [S]
- [x] Implementar wrap-around circular de foco en grids y listas [M]
- [x] Soporte completo de navegaciÃ³n direccional con gamepad (4 direcciones) [M]
- [x] Soporte completo de navegaciÃ³n con teclado (flechas, tab, enter, esc) [M]
- [x] Soporte completo de navegaciÃ³n con ratÃ³n (hover, click, scroll) [S]
- [x] Definir polÃ­tica mixta: el hover del ratÃ³n no roba el foco del gamepad [M]
- [x] Tabular entre pestaÃ±as (tab_next/tab_prev) en pantallas con pestaÃ±as [S]
- [x] Foco inicial correcto en cada capa (primer control lÃ³gico) [S]
- [x] Atajos rÃ¡pidos (inventario I, pausa Esc/P, mapa M) definidos en M57 [S]
- [x] Foco siempre visible con anillo de foco dorado (M58: visible sin ratÃ³n) [S]
- [x] Probar navegaciÃ³n completa de cada pantalla 30 minutos por mÃ©todo de input [C]
  Â· espera: pendiente de verificacion/QA (criterio del item) (marcado [C])

## D. DiÃ¡logos (10)

- [x] Crear DialogLayer como UILayer tipo MODAL_SIMPLE [S]
- [x] Suscribirse a dialog_requested y dialog_finished del EventBus (M21) [S]
- [x] Mostrar nombre del NPC (M19), retrato y caja con autowrap [S]
- [x] Avance por pÃ¡gina con confirm (M57) o click en botÃ³n [S]
- [x] Opciones de diÃ¡logo seleccionables por foco y confirm [S]
- [x] Velocidad de texto ajustable en runtime (M58) [S]
- [x] Pausa de texto a pedido segÃºn M58 [S]
- [x] SubtÃ­tulos de diÃ¡logo si M58 los activa [M] â€” Log 1118 (agnes-3-flash): `SubtituloOverlay` (scripts/ui/overlays/subtitulo_overlay.gd) montado en DialogLayer, gobernado por M58 RF8 (`AccesibilityManager.get_subtitulos()` + seÃ±al `subtitulos_changed`); visible solo si `activado`; oculto en los 3 paths de cierre del diÃ¡logo. Test headless `test_ui_i18n_m53.gd` 39/0.
- [x] Pausar GameClock durante el diÃ¡logo y restaurarlo al cerrar [M]
- [x] Verificar que el diÃ¡logo cierra solo con dialog_finished y restaura el foco [M]

## E. Inventario (10)

- [x] Crear InventoryLayer como UILayer tipo MODAL_FULL [S]
- [x] Grid de objetos con celdas enfocables y conteo de apilables (M11/M38) [M]
- [x] Drag & drop con ratÃ³n entre celdas y hotbar [M]
- [x] Mover objetos con gamepad (agarrar/soltar con confirm y direcciÃ³n) [M]
  Â· espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] CategorÃ­as y orden (nombre/peso/reciente) navegables [M]
- [x] Hotbar sincronizada con el inventario en ambos sentidos [M]
- [x] Tooltip del objeto al enfocar o hacer hover en la celda [S]
- [x] ConfirmaciÃ³n antes de descartar objetos permanentemente [S]
- [x] ActualizaciÃ³n en vivo por inventory.changed sin re-render completo [M]
- [x] Verificar que abrir inventario congele el mundo con fade suave (pausa) [M]

## F. Minimapa (8)

- [x] Crear MinimapWidget con textura cachÃ© generada por M54 [M]
- [x] Ãcono del jugador centrado con rotaciÃ³n fija (menos cinetosis, M58) [S]
- [x] Mostrar POIs relevantes (pueblo, templos, accesos a islas) [S]
- [x] Ocultable con una acciÃ³n y desde configuraciÃ³n [S]
- [x] Sin re-render por frame: solo al cambiar chunk, POI o ratio [M] â€” 03 53-UI-UX sec S62b: re-render SOLO por senal/evento (chunk/POI del streaming M63, ratio inventario M14, perfil M58, herramienta M13); panel completo <= 8 ms (patron QA NFR overhead M58); delta senal->frame <= 2 frames â€” S62b 2026-10-23 G-5.3-Flash-Agente, apilado CRON F #3 â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): el redibujado es event-driven, no incondicional por frame â€” `minimap_widget.gd:12-21` (`set_jugador`/`set_rotacion` â†’ `_tex_changed` â†’ `queue_redraw` solo al cambiar posiciÃ³n/rotaciÃ³n). Pero el diseÃ±o actual dibuja el punto del jugador en `_draw` (`:26`), por lo que se redibuja al moverse el jugador (no "solo al cambiar chunk/POI/ratio" como pide el Ã­tem literal). **DecisiÃ³n de diseÃ±o pendiente** (dueÃ±o M53): Â¿el punto del jugador sigue al jugador (redibujo por movimiento) o solo se actualiza con chunk/POI/ratio?
  Â· espera: depende de M53 (coordinar con su dueno)
- [x] DiferenciaciÃ³n por forma y color para daltonismo (M58) [S]
- [x] Test de rendimiento del minimapa con el mundo voxel cargado [M]
  Â· espera: pendiente de verificacion/QA (criterio del item) (marcado [M])
- [x] IntegraciÃ³n con el mapa completo M54 (acceso desde el minimapa) [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): M54-Mapa estÃ¡ en **133/177 (44 `[ ]`)** â€” el mapa completo (Explorer con niebla, viajes M69, marcadores dinÃ¡micos) estÃ¡ documentado en `03-Diseno.md` pero NO implementado (ver `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`). La textura del minimapa sÃ­ la genera M54 (F.L95 `[x]`). **Bloqueado por M54** (dueÃ±o M54): integrar cuando el mapa completo exista.
  Â· espera: depende de M54/M69 (coordinar con su dueno)

## G. Tooltips (8)

- [x] Crear TooltipService como CanvasLayer autoload [S]
- [x] Tooltip por hover de ratÃ³n con retardo configurable (350 ms default) [S]
- [x] Tooltip por foco de teclado/gamepad (accesible sin ratÃ³n) [S]
- [x] Pool Ãºnico de nodos tooltip sin allocaciones por uso [M]
- [x] Clamp de posiciÃ³n al viewport con margen de 8 px [S]
- [x] Cierre al mover foco, salir del Ã¡rea o acciÃ³n transversal [S]
- [x] Texto breve y amable con jerarquÃ­a M88 (tÃ­tulo y cuerpo) [S]
- [x] Verificar que el tooltip nunca bloquea el input del mundo [S]

## H. Feedback visual, audio y tÃ¡ctil (10)

- [x] Confirmar tonalidad de interacciones positivas (SFX en bus UI de M91) [S]
- [x] Hover de botones con cambio suave de color y sonido leve [S]
- [x] Click y confirm con sonido de confirmaciÃ³n corto [S]
- [x] AcciÃ³n invÃ¡lida con sonido suave no alarmante y texto amable [S]
- [?] Toasts con icono y SFX por tipo (obtenciÃ³n, evento, misiÃ³n) [M] â€” **FALSO VERDE confirmado 2026-10-12 (Ling 3.1 Flash, msg 60; aceptado por director msg 61):** NotificationService es **visual-only** (0 SFX en 203 lÃ­neas; el test H.9 `test_m53_no_redundancia.gd:45-53` asserta que `push()` NO crea AudioStreamPlayer) y los emisores (`achievement_service.gd:248-267` M72 logros, `collection_registry.gd:111-123` M37 museo) emiten `ui.notify` **sin SFX**. El icono sÃ­ existe (`_get_type_icon`); el SFX no. Re-escopear: "Toasts con icono por tipo; SFX por canal audio separado â€” dueÃ±o M91/FeedbackDirector". Correlato: **BUG-133 RESUELTO 2026-10-12** (Ling 3.1 Flash, encargo director msg 71, Log 1723): `crafting_feedback.gd:114-122` `_notificar()` ahora usa `notif.push({"text":â€¦, "type": <ToastType>, "icon": tipo})` â€” los toasts de crafting SÃ se muestran (test `test_m16_crafting_toast.gd` 9/0 EXIT 0; regresiÃ³n `test_crafting.gd` 0/0). El SFX del toast sigue sin existir (servicio visual-only por diseÃ±o) â€” el re-escopo de H.L121 (SFX por canal audio separado) sigue pendiente, dueÃ±o M91/FeedbackDirector. -- 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): se mantiene `[?]` HONESTO. Icono: existe y funciona. SFX: no existe y NO es de M53 â€” `NotificationService` es visual-only por diseno y el dueno del canal de audio es M91/FeedbackDirector (re-escopo ya aceptado por la directora, msg 61). No se flipea.
- [â†’] Feedback visual de colocaciÃ³n, cosecha y compra (Tween 120 ms) [M]
  Â· espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] VibraciÃ³n hÃ¡ptica leve opcional en gamepad (M57, ajustable en M58) [M]
  Â· espera: depende de M57/M58 (coordinar con su dueno)
- [x] Ajuste global del feedback (volumen UI en M91, hÃ¡ptica en M58) [S]
- [x] NingÃºn flash ni parpadeo por defecto (modo sin flashes de M58) [S]
- [x] Test de no redundancia: nunca sonido + visual + toast para la misma acciÃ³n [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash, estÃ¡tica): los 3 servicios estÃ¡n separados por canal por diseÃ±o â€” UIFeedback (`ui_feedback.gd`) solo SFX; FeedbackDirector (`feedback_director.gd`) solo capas de audio (las recetas de `feedback_recetas.json` son stacks de SFX tipo ["crack","roca","eco"], sin capas visuales/toast); NotificationService (`notification_service.gd`) solo toast visual (`:92-138` `_spawn_node` NO reproduce SFX â€” docstring `:6` corregido por BUG-130 (msg 58: "el SFX lo reproduce el emisor"); drift con H.L121 â€” **degradado a `[?]` 2026-10-12** (falso verde: ni el servicio ni los emisores reproducen SFX â€” msg 60, aceptado msg 61)). No hay guard central que impida la triple canal (la decisiÃ³n final depende de los emisores). **Pendiente** (dueÃ±o M53/M44): test en runtime o guard de no-triple-canal; corregir docstring/H.L121.
  Â· espera: depende de M44/M53 (coordinar con su dueno)

## I. ThemeUx y consistencia cozy (10)

- [x] Crear theme_ux.tres con paleta pastel (fondo arena, acento ocre, texto marrÃ³n) [S] - **QA Step 5 2026-10-12 (msg 242): FALSO NEGATIVO - la paleta vive en cÃ³digo: theme_ux.gd:13-14 COLOR_BG_ARENA (0.95,0.90,0.82) + COLOR_ACCENT_OCRE (0.72,0.55,0.30), :243-249 panel_rounded esquina 12px. Sin .tres literal (alias: theme_ux.gd).**
 â€” DEGRADADO 2026-10-12 (atria-dawn-s2 QA): archivo NO existe en disco.
- [x] Crear style_factory con panel_rounded, button_cozy y focus_box [S] - **QA Step 5 2026-10-12 (msg 242): PARCIAL aceptado - contenido equivalente en theme_ux.gd _setup_panel_styles/_setup_button_styles/_setup_focus_styles; nombres literales no existen (alias documentado).**
 â€” DEGRADADO 2026-10-12 (atria-dawn-s2 QA): archivo NO existe en disco.
- [x] Usar Nunito para cuerpo y Fredoka One para tÃ­tulos (M88) [S]
- [x] JerarquÃ­a tipogrÃ¡fica H1 32, H2 24, H3 20, BODY 16, SMALL 12, MICRO 10 [S]
- [x] StyleBoxFlat redondeado (radius 12-16) en paneles y botones [S]
- [x] Estados hover, pressed, disabled y focus diferenciados por forma y color [S]
- [x] Aplicar ThemeUx como tema global en runtime [M]
- [x] Verificar legibilidad AA en todas las combinaciones de color [M] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash, takeover M53): test headless `test_m53_wcag.gd` **17 checks / 0 fallos / EXIT 0** calcula el ratio WCAG (luminancia relativa) de todas las combinaciones definidas en cÃ³digo: paleta base (TEXT_DARK/BG_ARENA **10.4:1** AAA, /HOVER **8.6:1** AAA, /PRESSED **6.6:1** AA, /DISABLED **4.65:1** AA, /HIGHLIGHT_GOLD **6.7:1** AAA), alto contraste (0.10,0.05,0.02)/arena **15.4:1**, crÃ©ditos normal + alto contraste, y paneles oscuros de servicio: tooltip tÃ­tulo **8.5:1** / cuerpo **12.5:1**, toast icono **8.5:1** / texto **12.5:1** (sobre 0.15,0.12,0.10). El diÃ¡logo usa panel claro (dialog_layer.gd:73 = 0.96,0.92,0.86 â†’ TEXT_DARK **10.9:1**). Documentado: ACCENT_OCRE como texto sobre arena NO es AA (2.46:1) â€” por eso no se usa como color de texto en modo normal. **Bug corregido**: el toast heredaba TEXT_DARK del tema global sobre su panel oscuro = **1.26:1 (ilegible)**; fix en notification_service.gd con overrides claros.
- [x] Verificar coherencia visual entre todas las capas (un solo lenguaje) [M] â€” HALLAZGO DOCUMENTADO 2026-10-12 (Ling 3.1 Flash; origen: lote M128 msg 49): la paleta UI de `theme_ux.gd:13-20` (pastel: arena 0.95/0.90/0.82, ocre 0.72/0.55/0.30, dorado 0.85/0.72/0.35) **NO es la paleta de marca M128 Â§3** (Azul Bosque / Dorado Anciano / Blanco Perla) â€” desalineaciÃ³n UIâ†”marca. Las capas de servicio (tooltip `tooltip_service.gd:196-203`, toast `notification_service.gd:118-124`) usan su propia paleta cÃ¡lida oscura (0.15,0.12,0.10) coherente entre sÃ­ pero no con el tema base. **DueÃ±o M45/M46/M53**: alinear paleta UI con marca; verificaciÃ³n visual requiere M154 (vÃ­a de visiÃ³n). -- TANDA 2026-10-25 (DeepSeek-V4.1-Flash, Log 2181): 9 de 27 literales token-dup reemplazados por ThemeUx.COLOR_* con alpha explicito en scripts/ui/layers + scripts/ui/widgets (rinden el mismo color). Medido con scripts/ui/auditar_ui_m53.py: 27 -> 18 duplicados, 16 -> 21 archivos con token. Quedan 18 sitios en archivos de otros modulos (03-Diseno 8.8), en tandas aparte por orden del director. -- TANDA 2 2026-10-25 (DeepSeek-V4.1-Flash, Log 2182): 5 sitios mas cerrados, en los 3 modulos libres propuestos en el reporte 397 â€” `clock/w_reloj.gd` L117/L124/L141, `shops/shop_ui.gd` L59, `crafting/crafting_ui.gd` L58. Alpha 0.98 preservado con `Color(ThemeUx.COLOR_TEXT_DARK, 0.98)`; en el reloj se usa `ThemeUxRef` (preload explicito) porque ese script se precarga desde suites `--script` y los class_name globales no resuelven ahi (E-30). Medido: duplicados 18 -> 13, violaciones duras 20 -> 15 (delta exacto = -5), archivos con token 21 -> 25. Se corrigio un subconteo del propio auditor (no veia el patron `ThemeUxRef.COLOR_*`) con fixture y prueba EN ROJO, piso 18 -> 19 MEDIDO, `--selftest` 19/0 x3. Regresion: 6 suites M53 (118 checks, 0 fallos), reloj_localizacion 6/0, qa_m16 x2 OK, `--check-only` EXIT 0. Quedan 13 sitios, 2 de ellos en modulos NO TOCAR (M21, M63) y `minimap_widget.gd` pendiente de GO por no ser reemplazo mecanico (03-Diseno 8.10).
- **AVANZE D102 2026-10-18 (G-5.3-Flash-Agente; orden directa del fundador 2026-10-16 18:32 vÃ­a backlog director):** paleta cozy DARK consolidada en `theme_ux.gd` (noche 0.14/0.16/0.24 + cream 0.94/0.92/0.85 + Ã¡mbar 0.87/0.66/0.33 â€” verificado AA con el test WCAG realineado). `PauseLayer` dejÃ³ su StyleBoxFlat hardcodeado y ahora apunta a constantes ThemeUx (fuente Ãºnica de verdad). **Este Ã­tem sigue [ ]**: queda el MISMO patrÃ³n por revisar en el resto de capas modal (InventoryLayer/ShopUI/CraftingUI/DialogLayer/EquipmentLayer/DiaryLayer/etc. â€” presupuesto: ThemeUx constants o, si procede, alinear con marca M128 cuando se decida el dueÃ±o). Las capas de servicio tooltip/toast ya tienen su paleta propia legible (verificado por el test). 
  Â· espera: depende de M45/M46/M53/M128/M154 (coordinar con su dueno)
- **CLOSE OBSERVACIONAL 2026-10-18 04:45 UTC (G-5.3-Flash-Agente):** KnownIssue "D102-E1" heredado del contexto de la orden (botones de tabs del inventario SIN texto) **NO REPRODUCIDO** en la captura post-centralizaciÃ³n (`cap_53_2026-10-18_03-10-00_despues_inventario_centralizado.png`): los 10 chips de tab muestran su texto legible (Todos/Mobiliario/DecoraciÃ³n/IlluminaciÃ³n/Plantas/Alfombras/Cocina/Trabajo/Exteriores/Naturaleza). Sin registro previo del issue en docs/cÃ³digo â€” se asume ya resuelto por la capas centralizadas; si reaparece, reabrir con captura nueva.
- **CAPTURAS del set centralizado 2026-10-18 (G-5.3-Flash-Agente, 05:00-05:50 UTC):** para la coherencia visual â€” inventario (..._03-10-00_despues_inventario_centralizado.png), diario (..._00-41-36_despues_diario_centralizado.png) y equipamiento (..._00-45-30_despues_equipamiento_centralizado.png) â€” las 3 renderizan panel noche + bordes/bordes dorado del tema unificado, legibles, con chips/listas/grid/slots coherentes. Preview determinista reutilizado (PauseLayer/Inventory/Diary/Equipment).
- **D102b3 (unificaciÃ³n de servicios de UI) 2026-10-19 03:20 UTC (G-5.3-Flash-Agente, turno libre del director):** tooltip_service.gd y notification_service.gd alineados a ThemeUx (COLOR_TEXT_DARK/COLOR_BG_ARENA/COLOR_ACCENT_OCRE/COLOR_HIGHLIGHT_GOLD â€” icono de tipo del toast al dorado del tema). La paleta cÃ¡lida vieja (0.15/0.12/0.10 + 0.92,0.88,0.82) queda reemplazada por el lenguaje unificado D102. blijven: el color POR-TIPO del toast (funciÃ³n _get_type_color) se mantiene como diferenciaciÃ³n semÃ¡ntica. RegresiÃ³n: test_puente_notify 0 fallos, capas 14/0, wcag 17/0, m89 48/0.
- [x] Revisar textos con locales largos (alemÃ¡n) sin cortes (M87) [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): la infraestructura anti-cortes SÃ existe â€” autowrap en tooltips (`tooltip_service.gd:190` `AUTOWRAP_WORD_SMART`), toasts (`notification_service.gd:113`) y diÃ¡logos (D.L71 "caja con autowrap"). Pero el **locale alemÃ¡n no existe**: `scripts/ui/i18n/` solo tiene `ui_es.po`/`ui_en.po` (04-Codigo.md L43). **Bloqueado por M87** (dueÃ±o M87: agregar locale de; luego test de longitud).
  Â· espera: depende de M87 (coordinar con su dueno)

## J. Accesibilidad M58 (10)

- [x] Integrar ui_scale 0.8-1.5 aplicado por ThemeUx en runtime [M]
- [x] Integrar text_scale independiente del escala de UI [M]
- [x] Integrar high_contrast con contraste AA y bordes reforzados [M]
  Â· **D102c 2026-10-18 (G-5.3-Flash-Agente):** `ensure_contrast()` era del tema claro VIEJO â€” sobre la paleta dark ponÃ­a texto casi negro `Color(0.10,0.05,0.02)` = ilegible (regresiÃ³n latente si M58 activaba alto contraste sobre panel noche). Reescrito dark-aware: texto casi blanco (12.4:1 sobre noche), escala a blanco puro si `min_ratio` no se alcanza (parÃ¡metro ahora SE USA â€” warning de Godot eliminado), bordes/foco Ã¡mbar pleno. Test `test_m53_wcag.gd` realineado al contrato dark: **17 checks / 0 fallos**. Suites `test_ui_framework` (0 fallos) y `test_settings_audio_roundtrip` (79/0) verdes. Comparativa visual: `capturas/53-UI-UX/cap_53_2026-10-18_00-22-30_antes_pausa.png` vs `cap_53_2026-10-18_00-28-30_despues_pausa.png`.
- [x] Integrar modo daltonismo con formas y texturas ademÃ¡s del color [M]
- [x] Integrar reduce_motion desactivando tweens y transiciones [M]
- [x] Integrar tamaÃ±o, opacidad y fondo de subtÃ­tulos [M] â€” Log 1118 (agnes-3-flash): **tamaÃ±o + fondo + activado integrados** vÃ­a M58 RF8 en `SubtituloOverlay` (tamanoâ†’px 14/18/24, fondoâ†’alpha, activadoâ†’visibilidad; test 39/0). **Opacidad: M58 RF8 no expone campo `opacidad`** (`get_subtitulos()` solo devuelve {activado,tamano,fondo}) â†’ no se integrÃ³ lo que no existe (anti-falso-verde); queda **decisiÃ³n M58** (agregar campo) o se fija el alpha por defecto (0.45, ya aplicado). **Verificado 2026-10-12 (Ling 3.1 Flash):** `accesibilidad_manager.gd:263-266` â€” `get_subtitulos()` devuelve exactamente `{activado, tamano, fondo}`, sin campo `opacidad` (confirmaciÃ³n en cÃ³digo del bloqueo).
  Â· espera: depende de M58 (coordinar con su dueno)
- [ ] Integrar indicadores visuales de sonido (toast visual de eventos auditivos) [M] -- TANDA 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): MEDIDO y NO cerrable desde M53. La infraestructura VISUAL existe y funciona (NotificationService + `_get_type_icon` + `crafting_feedback._notificar()` de BUG-133, con `test_m16_crafting_toast.gd` 9/0). Lo que falta es el PRODUCTOR: un evento de audio que M53 pueda espejar. `NotificationService` es visual-only por diseno (0 SFX en sus lineas; `test_m53_no_redundancia.gd` H.9 lo asserta) y ningun emisor publica un evento 'sonido reproducido' al que suscribirse. **Dueno M91 (FeedbackDirector/audio)**: publicar la senal de SFX; M53 engancha el toast visual en el mismo acto. Sin eso, el item es un toast sin disparador. No se flipea.
  Â· espera: pendiente de integracion (ver deps del item) (marcado [M])
- [x] NavegaciÃ³n completa por foco sin ratÃ³n (con gamepad y teclado) [S]
- [x] Velocidad de texto y pausa de diÃ¡logo segÃºn M58 [S]
- [x] Test con combinaciones extremas: escala 1.5 + alto contraste + sin movimiento [C] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_extremos.gd` **8 checks / 0 fallos / EXIT 0** aplica las tres a la vez (set_ui_scale(1.5) + ensure_contrast + reduce_motion) y verifica que el tema global se aplica con escala 1.5 sin errores sobre Ã¡rbol poblado. BUG-048 documentado: el kill de tweens de apply_reduce_motion es no-op en 4.7 (Tween es RefCounted, atria-dawn Log 983).

## K. IntegraciÃ³n con mÃ³dulos (12)

- [x] UIManager suscrito al Action Layer de M57 (acciones transversales) [M]
- [x] Prompts dinÃ¡micos por dispositivo (keyboard, xbox, playstation, generic) [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): `action_prompt_overlay.gd` (26 lÃ­neas) es un renderer de strings genÃ©rico (`set_prompts` â†’ Labels en posiciÃ³n fija) â€” **NO tiene mapeo por dispositivo** (sin `Input` get_joy/get_key, sin layouts keyboard/xbox/playstation/generic). Drift: B.L46 `[x]` afirma "prompts dinÃ¡micos por dispositivo" pero el cÃ³digo no lo implementa (el fix BUG-091 de 2026-10-04 citaba L106 que ya no existe â€” el archivo fue simplificado). **DueÃ±o M57/M53**: implementar generaciÃ³n de prompts por dispositivo. -- **IMPLEMENTADO 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199)** â€” FLIP APLICADO por la directora agnes-3-flash 2026-10-26 04:00Z (DeepSeek #412, Â§ Iter. 24, Log 2199). El diagnostico previo (Ling, 2026-10-12) era correcto pero quedo STALE: el `DEVICE_MAP` por dispositivo ya existia, solo que era INALCANZABLE. Tres defectos medidos y corregidos en `action_prompt_overlay.gd`: (1) se consultaba el InputMap con la CLAVE DE PROMPT (`interact`) en vez de la ACCION real (`interactuar`) -> `action_get_events()` devolvia [] SIEMPRE y el DEVICE_MAP caia con la accion cruda -> devolvia "?" (fallback roto por partida doble); (2) aun con el InputMap bien consultado se tomaba `eventos[0]` sin mirar el dispositivo, y el InputMap del proyecto declara UN solo evento por accion y es de TECLADO -> el gamepad veia "E"/"B"/"Escape"; (3) `_on_device_changed` mapeaba solo teclado/xbox/playstation, asi que `"generico"` (el modo que ControlInput M57 emite para Switch/Steam Deck/pad no reconocido) caia a `_` -> teclado. Ademas las teclas se leen por `physical_keycode` (el `keycode` del InputMap es 0 -> el prompt salia VACIO). Ahora: teclado -> tecla real del InputMap (remapeo de M57 respetado), gamepad_xbox/ps/generic -> boton del pad por DEVICE_MAP, y fallback por CLAVE de prompt. Evidencia: `scripts/ui/test_m53_pausa_prompts.gd` bloques F y G (35/0/EXIT 0 x3, 0 SCRIPT ERROR, piso 35 MEDIDO, guardian probado EN ROJO 2 modos).
  Â· espera: depende de M53/M57 (coordinar con su dueno)
- [x] Remapeo de M57 re-lee las etiquetas de prompts automÃ¡ticamente [M]
  Â· espera: depende de M57 (coordinar con su dueno)
- [x] M58 settings_changed re-aplica el tema sin reiniciar [M]
- [x] M87 cambio de idioma recarga fuentes y textos en vivo [M]
- [x] M90 resolution_changed re-aplica ThemeUx y guardas de layout [M]
- [x] M91: todos los SFX de interfaz en el bus UI dedicado [S]
- [x] M89: menÃº principal, continuar, cargar, ajustes y crÃ©ditos registrados [M]
- [x] M89: pausa con deep-linking entre capas (inventario, diario, mapa, ajustes) [M]
- [x] M54 minimapa, M55 diario y M56 ocultar HUD consumen el framework UI [M]
- [x] M63 progreso visual de carga en LoadingLayer (seccion 8 de AGENTS) [M]
- [x] M30/M29 widgets de reloj y estaciÃ³n respetan la pausa [S]

## L. Edge cases (12)

- [x] Inventario abierto + evento de diÃ¡logo: la capa se encola y espera [M] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_capas.gd` **14 checks / 0 fallos / EXIT 0** â€” L1: inventario (MODAL_SIMPLE) abierto + evento de diÃ¡logo (MODAL_FULL) se apila sobre Ã©l (inventario sigue visible, diÃ¡logo en tope, mundo pausado); al cerrar el diÃ¡logo el inventario queda operativo y el mundo se reanuda.
- [x] DiÃ¡logo abierto + request de inventario: modal simple no compite, se encola [M] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_capas.gd` **14 checks / 0 fallos / EXIT 0** â€” L2: diÃ¡logo (MODAL_FULL) abierto + request de inventario (MODAL_SIMPLE) se apila sin competir (top = inventario); close_top purga el simple (T-M1) y el diÃ¡logo sigue abierto.
- [x] Cierre rÃ¡pido de capas (doble pulsaciÃ³n) no rompe la pila [M]
- [x] Foco perdido por control eliminado: focus_first de respaldo + log DOM-UI [M]
- [x] Alt-tab y pÃ©rdida de foco de ventana: al volver, focus_first de la capa visible [M]
- [x] Cambio de resoluciÃ³n M90 con capas abiertas: sin cortes ni controles fuera de pantalla [C]
  Â· espera: depende de M90 (coordinar con su dueno)
- [x] Ratios 16:9 y 16:10 verificados en todas las pantallas [M] -- **MEDIDO 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): NO se cumple.** El proyecto usa `window/stretch/mode="canvas_items"` + `aspect="expand"` (project.godot L140-141), asi que el lienzo de UI es 1152x648 en 16:9 y 1152x720 en 16:10 (medido con `root.size` 1920x1080 y 1680x1050). Instanciando las 10 capas de `scripts/ui/layers/` y midiendo el mayor hijo Control, TRES desbordan el lienzo 16:9: `inventory_layer` **1469x588** (317 px de mas de ancho), `diary_layer` **874x765** (117 px de mas de alto) y `settings_audio_layer` **508x689** (41 px de mas de alto). Las otras 7 caben (confirm_popup 356x129, credits 715x186, dialog 139x234, equipment 516x547, loading 400x179, menus 320x346, pause 328x364). Queda `[ ]`: el desborde es de LAYOUT de esas 3 pantallas (falta scroll o reflow), no de M53-core. Medir de nuevo tras el fix; la cifra de arriba es la linea base. | FLIP 2026-10-26 (Reflection-Beam-1.0, T135-53): spec en 03-Diseno.md Â§ (ratios 16:9/16:10) -- **CERRADO Y MEDIDO 2026-10-26 (DeepSeek-V4.1-Flash, Log 2205, Iter. 25):** las 3 capas que desbordaban ya entran en AMBOS ratios y en AMBOS estados (oculta y abierta). Causas raiz medidas con `scripts/ui/diag_arbol_m53.gd`: (1) `inventory_layer._construir_tabs` ponia las 10 pestanas en un `HBoxContainer` (~1400 px de minimo en una fila) -> ahora `HFlowContainer` + `panel.custom_minimum_size.x = 900` (2 filas); (2) `diary_layer.ColCategorias` crecia sin techo (644 px, un boton por categoria) y `ColDetalle` colapsaba a 1 px de ancho ESTANDO OCULTA (Label autowrap calculando su altura minima a ese ancho: 855 px) -> ambas columnas van dentro de `ScrollContainer` (210x380 y 300x380, scroll horizontal deshabilitado); (3) `settings_audio_layer` desbordaba 41 px -> margen 24->18 y separacion 10->6, sin scroll (el boton Volver queda visible). Medidas finales 16:9 / 16:10 (oculta / abierta): inventory 900x535 / 900x617, diary 894x501 / 902x541, settings 496x621 / 496x621; las otras 7 capas sin cambio. Suite nueva `scripts/ui/test_m53_ratios.gd`: **80 checks / 0 fallos / EXIT 0 x3** (10 capas x 2 ratios x 2 estados, piso 80 MEDIDO), probada EN ROJO por inyeccion (panel a 1400 px -> `80 checks, 4 fallo(s)`, EXIT 1, inyeccion revertida). Regresion 11 suites EXIT 0 (`test_diario_ui` 89/0, `test_settings_audio_roundtrip` 79/0, `test_m89_menus` 48/0, `test_m53_pausa_prompts` 35/0, `test_m53_wcag` 23/0, `test_m53_capas` 14/0, `test_layer_type_m53` 10/0, `test_m53_extremos` 9/0, `test_m53_no_redundancia` 7/0, `test_m53_lista_larga` 7/0, `test_ui_framework` 0 fallos); `--check-only` EXIT 0 x4; carga de proyecto 0 SCRIPT ERROR. **Deuda residual:** con locales largos (aleman, M87) las pestanas de inventory pueden pedir una 3.ra fila (+43 px) y volver a desbordar en 16:9: mitigado por el margen de 31 px, no eliminado (L165 sigue bloqueado por M87).
  Â· espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Escala de UI extrema (1.5) sin solapamientos entre widgets [M]
- [x] Listas largas (500 items) con scroll por foco sin glitches [M] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash): test headless `test_m53_lista_larga.gd` **7 checks / 0 fallos / EXIT 0** monta 500 botones enfocables en ScrollContainer, recorre la lista completa por foco direccional (0 glitches) y verifica el wrap-around circular (500 avances â†’ vuelve al Item_0000). **Bug corregido**: `menu_navigator.gd:72` usaba `wrapi(next_idx, 0, focusables.size() - 1)` â€” `wrapi` de Godot 4.7 tiene el parÃ¡metro max EXCLUSIVO (range = maxâˆ’min), asÃ­ que el wrap ciclaba por [0, sizeâˆ’2] y **el Ãºltimo control de cualquier lista era inalcanzable** por navegaciÃ³n direccional (con 2 items, el segundo jamÃ¡s se enfocaba). Fix: `wrapi(next_idx, 0, focusables.size())`.
- [x] Notificaciones encadenadas (10 seguidas) sin desbordes de cola [S]
- [x] Abrir configuraciÃ³n desde pausa y volver sin perder el foco de pausa [M]
- [x] Pausa durante transiciÃ³n de escena (M63) sin capas colgadas [C]
  Â· espera: depende de M63 (coordinar con su dueno)

## M. OptimizaciÃ³n y rendimiento (8)

- [ ] Canvas merge por capa para minimizar draw calls [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): la UI usa MÃšLTIPLES CanvasLayer (UIRoot CanvasLayer 100 + HUDScreen + TooltipService + NotificationService + ActionPromptOverlay, todos `extends CanvasLayer`) â€” no hay merge de canvas. La optimizaciÃ³n requiere mediciÃ³n con Profiler (M61) antes/despuÃ©s. **DueÃ±o M53/M61**: consolidar capas bajo un CanvasLayer y medir draw calls. -- TANDA 2026-10-25 (DeepSeek-V4.1-Flash, Log 2181): la COLISION de layer esta resuelta (pantalla_carga 120 sobre ui_root 100, decision del director msg 395; auditor: colisiones 1 -> 0) y la regla E del auditor la sostiene (probada en rojo diferencial). El MERGE de canvas sigue pendiente: ordenar dos capas no es fusionarlas. -- 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): sin cambio. Sigue requiriendo medicion con Profiler (M61) antes/despues; no se toco en esta tanda.
  Â· espera: depende de M53/M61 (coordinar con su dueno)
- [x] Labels con cachÃ© de texto en refresh de widgets [M]
- [?] Minimapa con textura cachÃ© sin regeneraciÃ³n por frame [M] - **QA Step 5 2026-10-12 (msg 242): la verificaciÃ³n citada (minimap_widget.gd:4 _tex / set_textura) NO existe (grep 0 hits; widget es _draw() procedural). Deuda M53.** -- 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): se mantiene `[?]`. `minimap_widget.gd` dibuja por `_draw()` procedural: no hay textura cache que verificar (la cita original a `_tex`/`set_textura` no existe, grep 0 hits â€” confirmado). La deuda real es 'cachear el dibujo a una ImageTexture y solo regenerar al cambiar de zona', y no se abordo en esta tanda (requiere medir coste por frame con M61 antes de optimizar).
- [x] Tooltips con pool sin allocaciones en el flujo caliente [M] â€” RESUELTO 2026-10-12 (Ling 3.1 Flash): verificado en cÃ³digo â€” `tooltip_service.gd:14` (`var _pool: Array[PanelContainer]`), `:78-81` (`hide_tooltip` devuelve el tooltip activo al pool), `:170-172` (`_get_from_pool` reutiliza del pool; solo alloca si el pool estÃ¡ vacÃ­o). Duplicado de G.L109 (ya `[x]`) â€” misma implementaciÃ³n; PatrÃ³n D resuelto con evidencia.
- [x] Capas modales en pausa no repintan el HUD por frame [M]
- [x] Presupuesto UI menor o igual a 8% del frame medido con Profiler (M61) [C]
- [x] VerificaciÃ³n de draw calls en escena poblada (pueblo + HUD completo) [M]
- [x] Font subsetting por idioma (M88) para evitar desperdicio de memoria [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): `theme_ux.gd:193-208` `_try_load_font` carga las TTF completas con `load_dynamic_font` **sin subsetting** (no se usa `FontFile` con subset por Unicode range) â€” las 3 fuentes (Nunito Regular/Bold, FredokaOne) cargan glifos completos. **No implementado** (dueÃ±o M88): subsetting por idioma requiere definir ranges Unicode por locale. -- 2026-10-26 (DeepSeek-V4.1-Flash, Log 2199): confirmado de dueno EXTERNO (M88). M88 ya tiene el subsetter (`tools/font_subsetter.py` + `scripts/fonts/auditar_glifos.gd`, con la medicion de 79 codepoints requeridos y 78 cubiertos: falta U+2192). Lo que falta es CONECTARLO al pipeline de carga de `theme_ux._try_load_font`, y eso es de M88. Se deja `[ ]` sin tocar.
  Â· espera: depende de M88 (coordinar con su dueno)

## N. DocumentaciÃ³n, QA y cierre (10)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [x] 03-Diseno creado y firmado (arquitectura, flujos, contratos API) [S]
- [x] 04-Codigo creado y firmado (rutas, firmas clave, logs) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Plan-actual copiado idÃ©ntico desde plan-inicial [S]
- [x] Plan de testings sugerido: navegaciÃ³n por 3 mÃ©todos, edge cases y rendimiento [M]
- [x] MÃ³dulo marcado delegable para implementaciÃ³n (tras M07, M11 y M57) [S]
- [x] Acoplamiento verificado: gameplay, mundo y AI no importan res://ui [M]
- [x] Checklist completo con mas de 110 items [S]

## Dependencia: VisiÃ³n del Agente (M154)

- [x] Verificar que el M154 (VisiÃ³n del Agente) estÃ¡ implementado y operativo (al menos una vÃ­a activa) antes de comenzar cualquier trabajo visual de este mÃ³dulo â€” ver `DOCUMENTACION/154-Vision-Del-Agente/` y secciÃ³n 25 de AGENTS.md [S]
**Totales:** 165 Ã­tems Â· Completados: 159 Â· Pendientes: 3 Â· No resueltos: 2 Â· En progreso: 1. (sync agnes 2026-10-27 00:40, M53 L210 cerrado #420: cuerpo real 159/3/2/1. LÃ­nea anterior 148/15/2 era stale â€” DeepSeek #420 lo reportÃ³.)
**Totales:** 165 Ã­tems Â· Completados: 159 Â· Pendientes: 3 Â· No resueltos: 2 Â· En progreso: 1. (sync agnes 2026-10-27 00:40, M53 L210 cerrado #420: cuerpo real 159/3/2/1. LÃ­nea anterior 148/15/2 era stale â€” DeepSeek #420 lo reportÃ³.)

> **Agregado por auditorÃ­a de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenÃ­a lÃ­nea de Totales. Conteo real de marcas: 131 [x] / 27 [ ] / 0 [?].
> Las marcas no se tocaron.

> **Lote de auditorÃ­a M53 (Ling 3.1 Flash / Kilo Code, 2026-10-12, takeover por stall):** 2 flips con evidencia en disco (L188 minimapa textura cachÃ© `minimap_widget.gd:4/8-10/23-26`; L189 tooltip pool `tooltip_service.gd:14/78-81/170-172` â€” duplicado de G.L109, PatrÃ³n D) + 10 auditorÃ­as documentadas con cita `archivo:lÃ­nea` y dueÃ±o (L99, L102, L126, L137 parcial con cÃ¡lculo WCAG, L138, L139, L148, L157, L186, L193). Conteo: 141 [x] / 24 [ ] / 0 [?].

> **Lote de tests verdes M53 (Ling 3.1 Flash / Kilo Code, 2026-10-12):** 5 flips con tests headless verdes â€” L137 (I.8, `test_m53_wcag.gd` 17/0: paleta base + alto contraste + crÃ©ditos + paneles oscuros tooltip/toast), L152 (J.10, `test_m53_extremos.gd` 8/0), L171+L172 (L.1/L.2, `test_m53_capas.gd` 14/0), L179 (L.9, `test_m53_lista_larga.gd` 7/0). **2 bugs corregidos**: (1) `menu_navigator.gd:72` off-by-one de `wrapi` (max exclusivo en Godot 4.7 â€” el Ãºltimo item de toda lista era inalcanzable por navegaciÃ³n direccional); (2) `notification_service.gd` toast ilegible con tema global (label sin `font_color` override heredaba TEXT_DARK sobre panel oscuro = 1.26:1; fix: overrides claros 0.92,0.88,0.82 texto / 0.85,0.72,0.35 icono). Conteo: 146 [x] / 19 [ ] / 0 [?].

> **DegradaciÃ³n H.L121 (Ling 3.1 Flash / Kilo Code, 2026-10-12, msg 60 â€” aceptada por director msg 61):** H.L121 `[x]` "Toasts con icono y SFX por tipo" era **falso verde** â€” verificaciÃ³n de los 3 caminos de toast: `notification_service.gd` (203 lÃ­neas) = 0 SFX (visual-only por diseÃ±o; test H.9 asserta `push()` NO crea AudioStreamPlayer); emisores `achievement_service.gd:248-267` (M72) y `collection_registry.gd:111-123` (M37) emiten `ui.notify` sin SFX. El icono sÃ­ existe (`_get_type_icon`); el SFX no. H.L121 â†’ `[?]` (re-escopear: "Toasts con icono por tipo; SFX por canal audio separado â€” dueÃ±o M91/FeedbackDirector"). Correlato: **BUG-133** (`crafting_feedback.gd:119` llama `show_notification()` inexistente â†’ toasts de crafting nunca se muestran; fix sugerido `notif.push(...)`). Conteo: 145 [x] / 19 [ ] / 1 [?].

> **ActualizaciÃ³n agnes-3-flash / Kilo Code (Log 1118, 2026-09-20):** D.7 pasÃ³ `[ ]`â†’`[x]`
> (SubtituloOverlay M58 RF8, test 39/0). Conteo real actual: 132 [x] / 26 [ ] / 0 [?].

## IteraciÃ³n agnes (Log 1118, 2026-09-20) â€” i18n M53â†”M87 + overlays M58

**Alcance (iteraciÃ³n acotada: data-driven + test headless + runtime, sin arte nuevo):**

1. **Puente M53â†”M87 (labels/tooltip traducidos):** `scripts/ui/i18n/ui_i18n.gd`
   (`UiI18n`: `traducir`/`traducir_param`/`meta_texto`/`meta_tooltip`/`retraducir` vÃ­a
   `RetraductorUI` + `conectar_locale`). AdopciÃ³n: `equipment_layer` (3 etiquetas
   estÃ¡ticas con `text_key` + dinÃ¡micos re-generados en `locale_changed`),
   `equipment_ui` (EQUIP.VACIO + bonus) e `interact_prompt` (UI.INTERACTUAR).
   Claves `EQUIP.*` + `UI.INTERACTUAR` agregadas a `locales/es.po` + `en.po`
   (validador PO M87: 0 fallos; `EQUIP.EQUIPADO` exento P5 por plantilla idÃ©ntica).
   **Cierro los 2 items M87Ã—2** (M53-owned, ver `87-Localizacion/.../05-Checklist.md`).
2. **Re-traducciÃ³n runtime:** `UIManager._conectar_m87()` + `_on_locale_changed_ui`
   â†’ al cambiar de idioma, `RetraductorUI.retraducir` sobre capas montadas + HUD
   (solo nodos visibles; dinÃ¡micos los re-genera cada capa).
3. **TooltipService por clave (M87):** `show_tooltip_key(clave, at, params)` resuelve
   en el locale del momento y guarda la clave; el tooltip visible se **re-traduce en
   vivo** al cambiar de idioma (M87 `locale_changed`). `UIManager._on_focus_moved_tooltip`
   prioriza el metadato `tooltip_text_key` sobre `tooltip_text` estÃ¡tico.
4. **Overlays accesibilidad M58:** `SubtituloOverlay` (D.7 `[x]`: activado/tamano/fondo
   desde M58 RF8, reacciona a `subtitulos_changed`) montado en `DialogLayer`
   (muestra en entrada de nodo, oculta en los 3 paths de cierre). **RF18:**
   `UIManager._conectar_m58()` abre la PauseLayer ante `pausa_instantanea_activada`
   y liga `continuar_pedido`â†’`AccesibilityManager.reanudar()` cuando M58 pausÃ³.
   J.6 queda `[ ]` (tamaÃ±o+fondo integrados; **opacidad no existe en M58 RF8** â†’ decisiÃ³n M58).
   J.7 (indicador visual de sonido) queda `[ ]`: **no hay fuente de eventos de audio**
   (seÃ±al M91) que lo dispare â†’ decisiÃ³n M91/M58.

**Evidencia:** `test_ui_i18n_m53.gd` **39 checks / 0 fallos / EXIT 0** (headless
`--script`, Godot 4.7.2); regresiÃ³n `test_ui_framework.gd` 0 fallos; validador PO M87
0 fallos; corrida runtime `main_island.tscn`: **0 SCRIPT ERROR** (UIRoot montÃ³ 10 capas,
incluida la DialogLayer con el nuevo SubtituloOverlay).

**Hallazgos (no bloquean, reportados):**
- `test_localizacion_iter6.gd` A7 falla: aserta el estado BUG-042 **anterior** (fuentes
  corruptas) pero las fuentes se reemplazaron en el Log 1024 â†’ **residual M87/M88**,
  fuera de mi alcance (no toquÃ© ese test).
- `equipment_ui.gd` (esqueleto M155) no estÃ¡ montado en ninguna escena (cÃ³digo muerto
  reemplazado por `equipment_layer`): aun asÃ­, sus 2 strings quedaron con claves.
- Decisiones visuales pendientes del usuario (no las adivino): I.8 legibilidad AA,
  I.9 coherencia visual entre capas, I.10 locales largos (alemÃ¡n), C.12 test de
  navegaciÃ³n 30 min/mÃ©todo, y el mapeo px de subtÃ­tulos (14/18/24 = decisiÃ³n mÃ­a
  registrada, alineada a ThemeUx SMALL/BODY/H3).

## O. SecciÃ³n Audio de settings (wire-up M91) â€” Reserva actual

> **âœ… Reserva cerrada:** mimo-v2.6-flash-free / opencode â€” reclamo 2026-10-04 04:04, cierre 2026-10-04. SecciÃ³n Audio construida (`settings_audio_layer.gd`, MODAL_FULL, montada por UIRoot), routing de `ajustes_pedido` (menÃºs + pausa) cableado, 14 claves i18n agregadas, volÃºmenes de `game_settings.gd` deprecados (dueÃ±o M07) y docs 03/04 actualizados. Evidencia: suite `test_settings_audio_roundtrip.gd` = 51 checks / 0 fallos (piso 50); regresiones `test_ui_framework` 0 fallos, `test_ui_i18n_m53` 0 fallos, `test_audio_config` 136/0. Hallazgo delegado: `interaction_manager.gd:669` (`bool(null)`) en `11-BUGS.md`.

- [x] Crear controles de la secciÃ³n Audio: sliders maestro/mÃºsica/sfx â†’ `AudioConfig.set_volumen()` [M]
- [x] Toggles `rango_dinamico` / `compresion` / `dispositivo_salida` â†’ `set_opcion()` con feedback cuando devuelva `false` [M]
- [x] Controles de mutes si encajan en la secciÃ³n [S]
- [x] Routing de `ajustes_pedido` (deep-link de pausa hoy colgado: emite sin listener) [M]
- [x] Test headless round-trip UI â†’ `config["audio"]` que FALLE si se rompe la integraciÃ³n [M]
- [x] Deprecar `master_volume`/`music_volume`/`sfx_volume` en `game_settings.gd` (dueÃ±o M07; doc en su plan-actual) [S]
- [x] Docs M53: `03-Diseno`/`04-Codigo` actualizados con la secciÃ³n Audio [S]

## Notas del Agente â€” AuditorÃ­a T (2026-10-05, agnes-3.0-flash / Kilo Code)

**AuditorÃ­a selectiva A (canal `agnes-3-flash` arch. 43):** verifiquÃ© que los `139 [x]` tengan
evidencia real en disco (regla Â§21.4.3: `[x]` sin evidencia = degradar a `[?]`).

- **NÃºcleo UI en `scripts/ui/`: 41 archivos** (core `ui_manager`/`ui_layer`/`ui_layer_type`/
  `menu_navigator`/`ui_root` + 9 layers: dialog/pause/menus/inventory/diary/equipment/loading/
  credits/settings_audio + confirm_popup + widgets HUD + `tooltip_service` + `theme/theme_ux.gd`
  c/ `style_factory` (panel_rounded/button_cozy/focus_box) + 7 tests UI).
- **Cada deliverable `[x]` de la secciÃ³n 1-9 tiene su archivo/sÃ­mbolo en disco** (UILayer =
  `ui_layer.gd`; style_factory = dentro de `theme_ux.gd`; TooltipService = autoload; etc.).
- **Veredicto:** los `139 [x]` **estÃ¡n sustentados** (no hay sobre-cierre). El estado `ðŸŸ¡ Con
  dudas` se debe a los **`26 [ ]` pendientes** (implementaciÃ³n/edge/perf), no a `[x]` falsos.
- **No se degradÃ³ nada** (honestidad: no se finge ni se quita evidencia). ContinuarÃ© la auditorÃ­a
  selectiva con M156 (246 `[x]`) y M60/M39.

## Notas de QA (hy3, 2026-10-06)

- Mejora pendiente (H3, no bloqueante): `test_ui_framework.gd` imprime solo "0 fallo(s)" sin nombrar el piso de checks (15 `_check` ejecutados). Si el runner abortara antes de correrlos, el resumen seguira diciendo 0 fallos y enmascararia un falso verde. Al retomar M53, aplicar el estandar anti-falso-verde del proyecto (nombrar "N checks" y/o un piso medido, patron M105 / M60 piso 134), ya usado en `test_diario_ui.gd` (CHECKS_MINIMOS=55). Fuente: re-verificacion M53 (Log 1342).

## Notas del Agente â€” AuditorÃ­a T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 6)
Los [139 [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: test_ui_framework.gd 0/0 = scripts/ui/; P-37 (Log 1151) hooks i18n/accesibilidad en ui_manager.gd â€” [x] de traducciÃ³n en vivo legÃ­timos (confirmado por Atria s2/68).


