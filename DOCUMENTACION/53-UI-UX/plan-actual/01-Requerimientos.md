**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 53: UI/UX

## ID del Módulo
- **Código:** M53 (plan maestro: sección 52 — UI/UX)
- **Carpeta:** `DOCUMENTACION/53-UI-UX/`
- **Dependencias:** M11 (Jugador), M14 (Mundo Voxel). Relaciones: M21 (Diálogos), M30 (Reloj en Tiempo Real), M54 (Mapa), M55 (Diario del Jugador), M57 (Interfaz de Control), M58 (Accesibilidad), M87 (Localización), M88 (Fuentes Tipográficas), M89 (Diseño de Menús), M90 (Configuración Gráfica), M91 (Configuración de Audio)
- **Delegable desde:** tras la arquitectura general (M07), el jugador (M11) y el sistema de acciones (M57); las pantallas hijas (M54, M55, M56) consumen esta base

## 1. Problema

El juego (cozy, isla ancestral, mundo voxel, sin combate obligatorio) necesita una interfaz coherente, amable y sin fricción que comunique el estado del mundo (HUD mínimo), permita navegar todos los menús con teclado/mouse y gamepad por igual, presente diálogos e inventario sin interrupciones agresivas, ofrezca un minimapa simple, tooltips contextuales y feedback táctil/visual/audio — todo con estética cozy y **sin barreras** (integrada de raíz con M58 Accesibilidad). La UI debe estar desacoplada de la lógica de gameplay (regla de capas de M07): la gameplay emite eventos y la UI se suscribe; la UI jamás es llamada por gameplay.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | HUD mínimo | Barra de estado (vitales/energía si aplica), reloj hora/día (M30), indicador de estación/clima, contador de recursos principales, hotbar/equipamiento actual, pistas de contexto (interactuar). Sin saturación: el HUD informa, no compite con el mundo |
| RF2 | Menús navegables | Todas las pantallas (inventario, pausa, diálogo, configuración, diario, mapa M54, tienda, crafting, construcción, personalización, relaciones, guardado/carga, tutoriales) navegables al 100% con gamepad, teclado y ratón; navegación por foco de Godot; sin zonas muertas |
| RF3 | Diálogos | Ventana de diálogo con nombre del NPC (M19), retrato, texto pausable y por página, opciones seleccionables con foco, velocidad de texto ajustable (M58), pausa de juego mientras se conversa; no bloquean otras UI de forma anómala |
| RF4 | Inventario | Cuadrícula de objetos con foco navegable, soltar/recoger con drag & drop (ratón) y mover con gamepad, tooltip del objeto, categorías y orden, hotbar sincronizada (M11) |
| RF5 | Minimapa simple | Widget discreto en esquina, icono del jugador centrado, puntos de interés (M54), rotación fija o según cámara según decisión; ocultable; sin costo de render relevante |
| RF6 | Tooltips | Tooltip contextual breve al poner el cursor sobre objetos/NPCs/edificios y sobre elementos de UI; retardo configurable; posicionamiento que nunca sale de pantalla; accesible por teclado (foco) |
| RF7 | Feedback táctil/visual/audio | Confirmación de acciones (colocar, cosechar, seleccionar, comprar, guardar): feedback visual (animación/color/partícula UI), sonoro (bus UI de M91) y háptico leve en input habilitado (M57 vibración); nunca punitivo |
| RF8 | Consistencia cozy | Un solo tema visual (M88: Nunito/Fredoka One, paleta pastel, StyleBoxFlat redondeado), misma jerarquía tipográfica, mismos patrones de botones/ventanas/popups en toda la UI; lenguaje amable en textos |
| RF9 | Sin barreras | Todo lo anterior coexiste con M58: escalado de UI, tamaño de texto, alto contraste, modo daltonismo (formas + colores), reducción de movimiento, subtítulos, notificaciones visuales de sonido, navegación completa por foco |
| RF10 | Sistema de capas | UIManager (autoload) + UILayer por pantalla + HUDScreen siempre visible; pila de capas modales con bloqueo de input correcto; transiciones suaves fade/deslizamiento; procesamiento en pausa coherente (process_mode) |

## 3. Requisitos No Funcionales

- **Desacoplamiento:** gameplay no conoce clases de UI (solo emite eventos por EventBus, dominio `ui`); la UI se suscribe. Verificado estáticamente.
- **Latencia de respuesta:** feedback visual/sonoro de interacción ≤ 100 ms tras el input; apertura de canciones ≤ 200 ms (sin carga bloqueante, precarga de temas).
- **Rendimiento (M61):** la UI no supera el 8% del frame budget; minimapa con poca geometría re-drawn; sin allocaciones por frame en hotpaths (tooltips reutilizados, labels pre-renderizados con caché de texto).
- **Resolución/escalado:** la UI funciona en todas las resoluciones soportadas por M90 (16:9 y 16:10) sin cortes; modo de escalado y referencia definidos.
- **Pausa coherente:** con GameClock (M29) en pausa, las pantallas modales siguen respondiendo; el HUD se congela; sin deadlocks de foco.
- **Sin movimiento forzado:** nada parpadea por defecto (M58 modo sin flashes); animaciones sutiles y reducibles.
- **Idioma:** strings y fuentes listos para M87 (Localización); tildes y caracteres especiales soportados (M88).
- **Cozy:** cero mensajes agresivos, cero errores rojos alarmantes; los errores se comunican con texto amable y opciones claras.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 52 del plan resueltos (HUD, menú principal, pausa, inventario, mapa, diario, misiones, colecciones, calendario, reloj, tienda, crafting, construcción, personalización, relaciones, configuración, guardado, carga, tutoriales, notificaciones, popups, tooltips, indicadores, accesibilidad, navegación con mando).
2. Toda pantalla navegable y operable al 100% con gamepad, teclado y ratón en una sesión de prueba de 30 minutos por método.
3. Pila de capas correcta: ningún input llega al mundo con una capa modal abierta; ninguna capa se queda invisible bloqueando.
4. Integración verificada con M57 (Action Layer y prompts dinámicos), M58 (parámetros de accesibilidad aplicados en runtime), M88 (tema centrado en fuentes definidas), M89 (registro de menús), M90 (re-aplicación del tema al cambiar resolución).
5. Presupuesto UI ≤ 8% frame bajo M61; sin draw calls duplicados entre capas (canvas merge donde corresponda).
6. Construcción de checklist del módulo (>= 110 ítems) y documentación completa para delegación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M011** — Personaje del Jugador | UI del jugador |
| **M014** — Inventario | Inventario en UI |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M054** — Mapa | Mapa |
| **M055** — Diario del Jugador | Diario |
| **M056** — Fotografía | Fotografía |
| **M058** — Accesibilidad | Accesibilidad |
| **M087** — Localización | Localización |
| **M088** — Fuentes Tipográficas | Fuentes tipográficas |
| **M089** — Diseño de Menús | Diseño de menús |
| **M090** — Configuración Gráfica | Configuración gráfica |
| **M091** — Configuración de Audio | Configuración de audio |
| **M092** — Tutorial | Tutorial |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M014** — Inventario | Depende de este módulo |
| **M054** — Mapa | Este módulo lo necesita |
| **M055** — Diario del Jugador | Este módulo lo necesita |
| **M056** — Fotografía | Este módulo lo necesita |
| **M058** — Accesibilidad | Este módulo lo necesita |
| **M087** — Localización | Este módulo lo necesita |
| **M088** — Fuentes Tipográficas | Este módulo lo necesita |

