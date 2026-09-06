**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Módulo:** 53-UI-UX
**Estado:** 🟡 Con dudas (72/158 completados)
**Prioridad:** #1
**Fortaleza:** Arquitectura de sistemas complejos, integración multi-sistema

# M53 — UI-UX: Checklist MiMo V2.5

## Reserva actual
- **Estado:** 🔵 Reservado
- **Fecha:** 2026-09-02
- **Log:** pendiente

## Pendientes (92 items)

### Requerimientos (8)
- [ ] T-053-001: Definir el problema: HUD mínimo, menús navegables, diálogos, inventario, minimapa, tooltips, feedback visual/audio/táctil, consistencia cozy, sin barreras [S]
- [ ] T-053-002: Registrar dependencias M11 y M14 y relaciones M21, M30, M54, M55, M57, M58, M87, M88, M89, M90, M91 [S]
- [ ] T-053-003: Catalogar los 25 puntos de la sección 52 del plan maestro [S]
- [ ] T-053-004: Definir RF1: composición del HUD mínimo y su jerarquía de importancia [S]
- [ ] T-053-005: Definir RF2: menús navegables al 100% con gamepad, teclado y ratón [S]
- [ ] T-053-006: Definir RF3: ventana de diálogo con nombre, retrato, opciones y pausa [S]
- [ ] T-053-007: Definir RF4: inventario con grid, drag & drop y hotbar sincronizada [S]
- [ ] T-053-008: Definir RF5: minimapa simple ocultable con POIs [S]
- [ ] T-053-009: Definir RF6: tooltips contextuales por ratón y por foco [S]
- [ ] T-053-010: Definir RF7: feedback visual, sonoro y háptico no punitivo [S]
- [ ] T-053-011: Definir RF8: tema único cozy con M88 y lenguaje amable en textos [S]

### Navegación y gamepad (6)
- [ ] T-053-012: Verificar que el HUD siga coherente con pausa abierta en modo congelado [M]
- [ ] T-053-013: Configurar focus_neighbor y focus_next/focus_prev en todas las pantallas del editor [M]
- [ ] T-053-014: Soporte completo de navegación con ratón (hover, click, scroll) [S]
- [ ] T-053-015: Definir política mixta: el hover del ratón no roba el foco del gamepad [M]
- [ ] T-053-016: Atajos rápidos (inventario I, pausa Esc/P, mapa M) definidos en M57 [S]
- [ ] T-053-017: Foco siempre visible con anillo de foco dorado (M58: visible sin ratón) [S]
- [ ] T-053-018: Probar navegación completa de cada pantalla 30 minutos por método de input [C]

### Diálogos (5)
- [ ] T-053-019: Suscribirse a dialog_requested y dialog_finished del EventBus (M21) [S]
- [ ] T-053-020: Velocidad de texto ajustable en runtime (M58) [S]
- [ ] T-053-021: Pausa de texto a pedido según M58 [S]
- [ ] T-053-022: Subtítulos de diálogo si M58 los activa [M]
- [ ] T-053-023: Pausar GameClock durante el diálogo y restaurarlo al cerrar [M]
- [ ] T-053-024: Verificar que el diálogo cierra solo con dialog_finished y restaura el foco [M]

### Inventario (3)
- [ ] T-053-025: Mover objetos con gamepad (agarrar/soltar con confirm y dirección) [M]
- [ ] T-053-026: Categorías y orden (nombre/peso/reciente) navegables [M]
- [ ] T-053-027: Confirmación antes de descartar objetos permanentemente [S]

### Minimapa (8)
- [ ] T-053-028: Crear MinimapWidget con textura caché generada por M54 [M]
- [ ] T-053-029: Ícono del jugador centrado con rotación fija (menos cinetosis, M58) [S]
- [ ] T-053-030: Mostrar POIs relevantes (pueblo, templos, accesos a islas) [S]
- [ ] T-053-031: Ocultable con una acción y desde configuración [S]
- [ ] T-053-032: Sin re-render por frame: solo al cambiar chunk, POI o ratio [M]
- [ ] T-053-033: Diferenciación por forma y color para daltonismo (M58) [S]
- [ ] T-053-034: Test de rendimiento del minimapa con el mundo voxel cargado [M]
- [ ] T-053-035: Integración con el mapa completo M54 (acceso desde el minimapa) [M]

### Feedback (9)
- [ ] T-053-036: Confirmar tonalidad de interacciones positivas (SFX en bus UI de M91) [S]
- [ ] T-053-037: Hover de botones con cambio suave de color y sonido leve [S]
- [ ] T-053-038: Click y confirm con sonido de confirmación corto [S]
- [ ] T-053-039: Acción inválida con sonido suave no alarmante y texto amable [S]
- [ ] T-053-040: Feedback visual de colocación, cosecha y compra (Tween 120 ms) [M]
- [ ] T-053-041: Vibración háptica leve opcional en gamepad (M57, ajustable en M58) [M]
- [ ] T-053-042: Ajuste global del feedback (volumen UI en M91, háptica en M58) [S]
- [ ] T-053-043: Ningún flash ni parpadeo por defecto (modo sin flashes de M58) [S]
- [ ] T-053-044: Test de no redundancia: nunca sonido + visual + toast para la misma acción [M]

### Tipografía y accesibilidad (12)
- [ ] T-053-045: Usar Nunito para cuerpo y Fredoka One para títulos (M88) [S]
- [ ] T-053-046: Verificar legibilidad AA en todas las combinaciones de color [M]
- [ ] T-053-047: Verificar coherencia visual entre todas las capas (un solo lenguaje) [M]
- [ ] T-053-048: Revisar textos con locales largos (alemán) sin cortes (M87) [M]
- [ ] T-053-049: Integrar text_scale independiente del escala de UI [M]
- [ ] T-053-050: Integrar high_contrast con contraste AA y bordes reforzados [M]
- [ ] T-053-051: Integrar modo daltonismo con formas y texturas además del color [M]
- [ ] T-053-052: Integrar reduce_motion desactivando tweens y transiciones [M]
- [ ] T-053-053: Integrar tamaño, opacidad y fondo de subtítulos [M]
- [ ] T-053-054: Integrar indicadores visuales de sonido (toast visual de eventos auditivos) [M]
- [ ] T-053-055: Navegación completa por foco sin ratón (con gamepad y teclado) [S]
- [ ] T-053-056: Velocidad de texto y pausa de diálogo según M58 [S]
- [ ] T-053-057: Test con combinaciones extremas: escala 1.5 + alto contraste + sin movimiento [C]

### Integración con otros módulos (12)
- [x] T-053-058: UIManager suscrito al Action Layer de M57 (acciones transversales) [M]
- [x] T-053-059: Prompts dinámicos por dispositivo (keyboard, xbox, playstation, generic) [M]
- [x] T-053-060: Remapeo de M57 re-lee las etiquetas de prompts automáticamente [M]
- [x] T-053-061: M58 settings_changed re-aplica el tema sin reiniciar [M]
- [x] T-053-062: M87 cambio de idioma recarga fuentes y textos en vivo [M]
- [x] T-053-063: M90 resolution_changed re-aplica ThemeUx y guardas de layout [M]
- [x] T-053-064: M91: todos los SFX de interfaz en el bus UI dedicado [S]
- [x] T-053-065: M89: menú principal, continuar, cargar, ajustes y créditos registrados [M]
- [x] T-053-066: M89: pausa con deep-linking entre capas (inventario, diario, mapa, ajustes) [M]
- [x] T-053-067: M54 minimapa, M55 diario y M56 ocultar HUD consumen el framework UI [M]
- [x] T-053-068: M63 progreso visual de carga en LoadingLayer [M]
- [x] T-053-069: M30/M29 widgets de reloj y estación respetan la pausa [S]

### Edge cases y pila de capas (12)
- [ ] T-053-070: Inventario abierto + evento de diálogo: la capa se encola y espera [M]
- [ ] T-053-071: Diálogo abierto + request de inventario: modal simple no compite, se encola [M]
- [ ] T-053-072: Cierre rápido de capas (doble pulsación) no rompe la pila [M]
- [ ] T-053-073: Foco perdido por control eliminado: focus_first de respaldo + log DOM-UI [M]
- [ ] T-053-074: Alt-tab y pérdida de foco de ventana: al volver, focus_first de la capa visible [M]
- [ ] T-053-075: Cambio de resolución M90 con capas abiertas: sin cortes ni controles fuera de pantalla [C]
- [ ] T-053-076: Ratios 16:9 y 16:10 verificados en todas las pantallas [M]
- [ ] T-053-077: Escala de UI extrema (1.5) sin solapamientos entre widgets [M]
- [ ] T-053-078: Listas largas (500 items) con scroll por foco sin glitches [M]
- [ ] T-053-079: Notificaciones encadenadas (10 seguidas) sin desbordes de cola [S]
- [ ] T-053-080: Abrir configuración desde pausa y volver sin perder el foco de pausa [M]
- [ ] T-053-081: Pausa durante transición de escena (M63) sin capas colgadas [C]

### Rendimiento (8)
- [ ] T-053-082: Canvas merge por capa para minimizar draw calls [M]
- [ ] T-053-083: Labels con caché de texto en refresh de widgets [M]
- [ ] T-053-084: Minimapa con textura caché sin regeneración por frame [M]
- [ ] T-053-085: Tooltips con pool sin allocaciones en el flujo caliente [M]
- [ ] T-053-086: Capas modales en pausa no repintan el HUD por frame [M]
- [ ] T-053-087: Presupuesto UI menor o igual a 8% del frame medido con Profiler (M61) [C]
- [ ] T-053-088: Verificación de draw calls en escena poblada (pueblo + HUD completo) [M]
- [ ] T-053-089: Font subsetting por idioma (M88) para evitar desperdicio de memoria [M]

### Testings y validación (3)
- [ ] T-053-090: Plan de testings sugerido: navegación por 3 métodos, edge cases y rendimiento [M]
- [ ] T-053-091: Acoplamiento verificado: gameplay, mundo y AI no importan res://ui [M]
- [ ] T-053-092: Verificar que el M154 (Visión del Agente) está implementado y operativo [S]

## Completados esta sesión

| Fecha | Tarea | Detalle |
|-------|-------|---------|
| 2026-09-04 | Logs cleanup (3 rondas) | 14 duplicados renumerados, ULTIMO_NUMERO=693, 671 logs 0 duplicados |
| 2026-09-04 | T-053-060 | Remapeo M57 re-lee etiquetas de prompts automáticamente |
| 2026-09-04 | T-053-063 | M90 resolution_changed re-aplica ThemeUx y guardas de layout |
| 2026-09-04 | T-053-065 | M89 menú principal registrado con señales a GameFlowManager |
| 2026-09-04 | T-053-066 | M89 pausa con deep-linking entre capas |
| 2026-09-04 | T-053-067 | M54 minimapa, M55 diario y M56 ocultar HUD integrados al framework UI |
| 2026-09-04 | T-053-068 | M63 progreso visual de carga en LoadingLayer |

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02
**Estado:** Inicio de backlog

### Lo que voy a hacer
- Priorizar items de integración (M57, M58, M87-M91) que desbloquean otros módulos
- Enfocarme en edge cases de pila de capas (capa más frágil del sistema)
- Rendimiento UI al final (requiere escena poblada para medir)

### Lo que NO puedo hacer todavía
- Items de gamepad físico (T-053-012 a T-053-018) — requieren hardware
- Items de M54 minimapa — depende de que M54 esté implementado
- Items de M63 loading — requiere escena de transición

### Recomendaciones para el próximo agente
- Empezar por T-053-058 a T-053-069 (integración módulos) — son los que más desbloquean
- Los items de accesibilidad (T-053-049 a T-053-057) se pueden hacer en paralelo
- Guardar evidencia de screenshots de cada capa UI para comparar antes/después
