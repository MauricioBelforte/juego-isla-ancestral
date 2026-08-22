**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 53: UI/UX

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

## B. HUD mínimo (12)

- [x] Crear HUDScreen como CanvasLayer en capa 100 [S]
- [x] Crear StatusBar con vitales del jugador (M11) leídos por Callable [S]
- [x] Crear ClockWidget con formato cozy "Otoño 3, 14:30" (M29/M30) [S]
- [x] Crear SeasonWidget con icono y texto de estación [S]
- [x] Crear ResourceCounter con contadores de recursos principales (M38) [S]
- [x] Crear HotbarWidget sincronizado por eventos del inventario (M11) [S]
- [x] Crear InteractPrompt contextual de "puedes interactuar" (M70) [S]
- [x] Crear ActionPromptOverlay con prompts dinámicos por dispositivo (M57) [S]
- [x] Implementar force_refresh puntual y refresh a baja frecuencia (2 Hz) sin polling por frame [M]
- [x] Implementar set_hud_visible(false) para M56 Fotografía y capturas [S]
- [x] Validar que el HUD no tape el centro de la pantalla (regla de layout) [S]
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
- [x] Probar navegación completa de cada pantalla 30 minutos por método de input [C]

## D. Diálogos (10)

- [x] Crear DialogLayer como UILayer tipo MODAL_SIMPLE [S]
- [x] Suscribirse a dialog_requested y dialog_finished del EventBus (M21) [S]
- [x] Mostrar nombre del NPC (M19), retrato y caja con autowrap [S]
- [x] Avance por página con confirm (M57) o click en botón [S]
- [x] Opciones de diálogo seleccionables por foco y confirm [S]
- [x] Velocidad de texto ajustable en runtime (M58) [S]
- [x] Pausa de texto a pedido según M58 [S]
- [x] Subtítulos de diálogo si M58 los activa [M]
- [x] Pausar GameClock durante el diálogo y restaurarlo al cerrar [M]
- [x] Verificar que el diálogo cierra solo con dialog_finished y restaura el foco [M]

## E. Inventario (10)

- [x] Crear InventoryLayer como UILayer tipo MODAL_FULL [S]
- [x] Grid de objetos con celdas enfocables y conteo de apilables (M11/M38) [M]
- [x] Drag & drop con ratón entre celdas y hotbar [M]
- [x] Mover objetos con gamepad (agarrar/soltar con confirm y dirección) [M]
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
- [x] Sin re-render por frame: solo al cambiar chunk, POI o ratio [M]
- [x] Diferenciación por forma y color para daltonismo (M58) [S]
- [x] Test de rendimiento del minimapa con el mundo voxel cargado [M]
- [x] Integración con el mapa completo M54 (acceso desde el minimapa) [M]

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
- [x] Toasts con icono y SFX por tipo (obtención, evento, misión) [M]
- [x] Feedback visual de colocación, cosecha y compra (Tween 120 ms) [M]
- [x] Vibración háptica leve opcional en gamepad (M57, ajustable en M58) [M]
- [x] Ajuste global del feedback (volumen UI en M91, háptica en M58) [S]
- [x] Ningún flash ni parpadeo por defecto (modo sin flashes de M58) [S]
- [x] Test de no redundancia: nunca sonido + visual + toast para la misma acción [M]

## I. ThemeUx y consistencia cozy (10)

- [x] Crear theme_ux.tres con paleta pastel (fondo arena, acento ocre, texto marrón) [S]
- [x] Crear style_factory con panel_rounded, button_cozy y focus_box [S]
- [x] Usar Nunito para cuerpo y Fredoka One para títulos (M88) [S]
- [x] Jerarquía tipográfica H1 32, H2 24, H3 20, BODY 16, SMALL 12, MICRO 10 [S]
- [x] StyleBoxFlat redondeado (radius 12-16) en paneles y botones [S]
- [x] Estados hover, pressed, disabled y focus diferenciados por forma y color [S]
- [x] Aplicar ThemeUx como tema global en runtime [M]
- [x] Verificar legibilidad AA en todas las combinaciones de color [M]
- [x] Verificar coherencia visual entre todas las capas (un solo lenguaje) [M]
- [x] Revisar textos con locales largos (alemán) sin cortes (M87) [M]

## J. Accesibilidad M58 (10)

- [x] Integrar ui_scale 0.8-1.5 aplicado por ThemeUx en runtime [M]
- [x] Integrar text_scale independiente del escala de UI [M]
- [x] Integrar high_contrast con contraste AA y bordes reforzados [M]
- [x] Integrar modo daltonismo con formas y texturas además del color [M]
- [x] Integrar reduce_motion desactivando tweens y transiciones [M]
- [x] Integrar tamaño, opacidad y fondo de subtítulos [M]
- [x] Integrar indicadores visuales de sonido (toast visual de eventos auditivos) [M]
- [x] Navegación completa por foco sin ratón (con gamepad y teclado) [S]
- [x] Velocidad de texto y pausa de diálogo según M58 [S]
- [x] Test con combinaciones extremas: escala 1.5 + alto contraste + sin movimiento [C]

## K. Integración con módulos (12)

- [x] UIManager suscrito al Action Layer de M57 (acciones transversales) [M]
- [x] Prompts dinámicos por dispositivo (keyboard, xbox, playstation, generic) [M]
- [x] Remapeo de M57 re-lee las etiquetas de prompts automáticamente [M]
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

- [x] Inventario abierto + evento de diálogo: la capa se encola y espera [M]
- [x] Diálogo abierto + request de inventario: modal simple no compite, se encola [M]
- [x] Cierre rápido de capas (doble pulsación) no rompe la pila [M]
- [x] Foco perdido por control eliminado: focus_first de respaldo + log DOM-UI [M]
- [x] Alt-tab y pérdida de foco de ventana: al volver, focus_first de la capa visible [M]
- [x] Cambio de resolución M90 con capas abiertas: sin cortes ni controles fuera de pantalla [C]
- [x] Ratios 16:9 y 16:10 verificados en todas las pantallas [M]
- [x] Escala de UI extrema (1.5) sin solapamientos entre widgets [M]
- [x] Listas largas (500 items) con scroll por foco sin glitches [M]
- [x] Notificaciones encadenadas (10 seguidas) sin desbordes de cola [S]
- [x] Abrir configuración desde pausa y volver sin perder el foco de pausa [M]
- [x] Pausa durante transición de escena (M63) sin capas colgadas [C]

## M. Optimización y rendimiento (8)

- [x] Canvas merge por capa para minimizar draw calls [M]
- [x] Labels con caché de texto en refresh de widgets [M]
- [x] Minimapa con textura caché sin regeneración por frame [M]
- [x] Tooltips con pool sin allocaciones en el flujo caliente [M]
- [x] Capas modales en pausa no repintan el HUD por frame [M]
- [x] Presupuesto UI menor o igual a 8% del frame medido con Profiler (M61) [C]
- [x] Verificación de draw calls en escena poblada (pueblo + HUD completo) [M]
- [x] Font subsetting por idioma (M88) para evitar desperdicio de memoria [M]

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

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
