**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 54: Mapa

## ID del Módulo
- **Código:** M54 (plan maestro: sección 54 — Mapa)
- **Carpeta:** `DOCUMENTACION/54-Mapa/`
- **Dependencias:** M53 (UI/UX), M09 (Terreno y Geografía — regiones/biomas), M27 (Islas del Mundo). Relaciones: M11 (Jugador), M19 (NPC y Vecinos), M24 (Templos y Puzzles), M25 (Ruinas), M28 (Viajes), M29 (Tiempo y Calendario), M30 (Reloj), M39 (Tiendas), M57 (Interfaz de Control/Input), M58 (Accesibilidad), M60 (Datos y Serialización), M63 (Cargas y Streaming), M69 (Fast Travel), M88 (Fuentes), M90 (Configuración Gráfica), M91 (Configuración de Audio UI), M92 (Tutorial)
- **Delegable desde:** M53 (framework UI), M09/M27 (datos de regiones y biomas), M11 (posición del jugador) y M69 (fast travel)

## 1. Problema

La isla Aurora es un mundo voxel grande y abierto (estilo cozy, sin combate obligatorio). Sin un sistema de mapa, el jugador se pierde al alejarse del pueblo, ignora regiones que ya exploró, no encuentra tiendas (M39), casas de NPCs (M19) ni puntos de interés (M24/M25), no sabe cómo viajar rápido (M69) y no tiene forma de dejar sus propias marcas de terreno. Un minimapa pobre o un mapa completo costoso romperían el presupuesto de rendimiento del proyecto y la estética amable.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Minimapa discreto | Widget del HUD (M53 MinimapWidget) en esquina sin tapar el centro; ícono del jugador centrado con rotación fija (menos cinetosis, M58); muestra regiones/biomas explorados, marcadores relevantes y niebla de guerra; ocultable con una acción y desde configuración; acceso directo al mapa completo |
| RF2 | Mapa completo | Pantalla modal (UILayer tipo MODAL_FULL de M53) con la textura de la isla Aurora generada a partir del mundo voxel (estilo mapa ilustrado cozy, sin saturar); regiones/biomas de M09/M27 coloreados con paleta pastel y nombres legibles (M88); marcador "estás aquí"; pausa coherente con M29/M30 |
| RF3 | Marcadores | Puntos de interés del mundo: pueblo, casa del jugador, tiendas individuales (M39), casas de NPCs (M19), templos y ruinas (M24/M25), accesos a otras islas (M27); iconos SVG por tipo (M46/M53); agrupación (cluster) cuando están muy cerca; tooltip con nombre (M53 TooltipService); visibles solo en zonas exploradas; leyenda y filtro por tipo; diferenciación por forma + color (daltonismo M58) |
| RF4 | Fast travel | Marcadores de viaje rápido de M69 visibles en el mapa; al confirmar uno se solicita el viaje a M69 (interfaz Callable, sin acoplar nodos); ruta al destino; destinos bloqueados hasta desbloquearlos explorando; confirmación amable y cancelación; costo/duración mostrados si M69 los define |
| RF5 | Niebla de guerra | Registro de exploración por región y por celda (no explorado / visto / visitado); revelado progresivo alrededor del jugador; aplicada sobre el mapa completo y el minimapa; transición suave de revelado (reducible por M58); persistente entre sesiones (M60) |
| RF6 | Pines del jugador | Marcas personales del jugador: crear pin en la posición actual o en la posición del cursor del mapa; nombre editable; eliminar con confirmación; límite máximo definido; persistencia (M60); visibles en minimapa y mapa completo; diferenciadas visualmente de los marcadores del mundo |
| RF7 | Zoom y navegación | Zoom con rueda de ratón, triggers de gamepad o botones (M57); pan arrastrando con ratón y con palanca de gamepad; límites de zoom y clamp del pan a los bordes; zoom anclado al cursor; acción de "volver al jugador"; escala de marcadores constante (no deforman) |
| RF8 | Atajos e integración | Abrir/cerrar con la acción `map_toggle` (tecla M, M57); cerrar con Esc/cancel; navegable al 100% con ratón, teclado y gamepad (foco nativo M53); pausa coherente con M29; SFX de apertura/cierre/viaje en el bus UI (M91); tutorial de primera apertura (M92); datos persistidos con M60 |

## 3. Requisitos No Funcionales

- **Rendimiento (M61):** el mapa (minimapa + completo) no supera el 5% del frame budget; draw calls del mapa ≤ 3 con la pantalla abierta; textura del mapa generada una vez y cacheada (sin re-render por frame); minimapa con una sola textura more algunos sprites; nada de re-draw por frame (updates por señal y bajo demanda).
- **Desacoplamiento:** la gameplay no conoce clases de Mapa; el mundo y M09/M27 solo emiten datos/eventos; MapManager es un servicio de datos (autoload) y las vistas (MinimapView/FullMapView) son de presentación; verificado estáticamente como en M07/M53.
- **Cozy:** cero mensajes agresivos; la niebla se disipa con suavidad; el mapa invita a explorar, nunca castiga; textos amables y con jerarquía M88.
- **Accesibilidad (M58):** formas + color en marcadores y estados de niebla; reduce_motion elimina animaciones de revelado; contraste AA; todo operable sin ratón.
- **Pausa coherente (M29):** el mapa completo congela el mundo como modal; el minimapa sigue vivo en el HUD; sin deadlocks de foco al abrir/cerrar (M53).
- **Escalado (M90):** funciona en 16:9 y 16:10 sin cortes; sin solapamientos al escalar la UI a 1.5.
- **Idioma (M87):** nombres de regiones y textos listos para localización; fuentes con tildes soportadas (M88).
- **Persistencia (M60):** exploración, pines y opciones de mapa sobreviven a reinicios.
- **Consistencia visual (M53):** usa ThemeUx, StyleBoxFlat, fuentes e iconos de M53/M88; no define un tema propio.

## 4. Criterios de Aceptación

1. RF1-RF8 implementados sobre el framework de M53 (capa modal, foco, tooltips, toasts) sin acoplar gameplay.
2. La textura del mapa completo refleja el mundo voxel real (regiones/biomas de M09/M27) con estética ilustrada cozy.
3. La niebla de guerra se revela correctamente explorando, persiste tras guardar/cargar (M60) y no penaliza al jugador.
4. El fast travel desde el mapa funciona end-to-end con M69 (destinos bloqueados → desbloqueo → viaje → cancelación).
5. Rendimiento medido con Profiler bajo el presupuesto (≤ 5% frame, ≤ 3 draw calls con mapa abierto) en escena poblada con el mundo voxel completo.
6. Mapa navegable al 100% con ratón, teclado y gamepad (30 minutos por método) incluyendo zoom, pan, filtros y pines.
7. Checklist del módulo con ≥ 120 ítems y documentación completa (5 archivos × 2 carpetas) para delegación de implementación.