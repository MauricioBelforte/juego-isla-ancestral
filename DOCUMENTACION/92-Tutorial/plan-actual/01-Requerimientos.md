**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 92: Tutorial

## ID del Módulo
- **Código:** M92 (plan maestro: guía de inicio del juego — tutorial integrado no intrusivo)
- **Carpeta:** `DOCUMENTACION/92-Tutorial/`
- **Dependencias:** M53 (UI-UX), M70 (Interacciones); consumen M57 (Interfaz De Control), M58 (Accesibilidad), M66 (Anti-Softlock)
- **Contenidos didácticos referenciados:** M11 (Personaje Del Jugador — moverse), M13 (Herramientas), M33 (Agricultura), M34 (Pesca), M35 (Minería), M16 (Crafting), M19/M21 (NPC y Vecinos / Diálogos)
- **Relacionados:** M44 (ASMR y Feedback), M43 (Efectos De Sonido), M02 (Visión Y Concepto), M22 (Historia Principal)
- **Delegable desde:** documentación completa; implementación junto con el primer playable con Voxel Tools (hito M1), cuando existan los sistemas que enseña (M70, M13, M33-M35, M16)

## 1. Problema

Los juegos cozy tipo Stardew Valley tienen sistemas simples pero numerosos (moverse, interactuar, herramientas, cultivo, pesca, minería, crafting, relaciones con vecinos). Sin guía, un jugador nuevo llega a la isla Aurora y no sabe qué puede hacer, con qué tecla, ni en qué orden; y un tutorial tradicional tipo pared de texto rompe la fantasía cozy de "explorar a mi ritmo". El módulo 92 resuelve esto con un tutorial integrado, no intrusivo y opcional: aprendizaje por inmersión mediante pistas contextuales breves en el mundo, secuencias guiadas suaves durante el prólogo de la isla, y un sistema de consejos desactivables que NUNCA bloquea ni castiga al jugador.

## 2. Objetivo

Que el jugador aprenda las mecánicas esenciales de la isla Aurora (moverse, interactuar, usar herramientas, cultivar, pescar, minar, craftear y conocer a los primeros vecinos) por inmersión, en menos de 15-20 minutos de juego, sin pantallas de texto interminables, con la posibilidad de saltear, repetir o desactivar cada pista, y con revalidación automática para jugadores que ya conocen la mecánica (nuevas partidas, segunda vez jugando o re-juego tras guardado antiguo).

## 3. Alcance

### 3.1 Dentro del alcance
- Guiones de tutorial por capítulos: prólogo de llegada, moverse, interactuar (M70), herramientas (M13), cultivo (M33), pesca (M34), minería (M35), crafting (M16) y primeros vecinos (M19/M21).
- Triggers contextuales: eventos del mundo o del jugador que disparan la lección correspondiente (primer paso, primera interacción "E", primera cosecha, etc.).
- Pistas contextuales world-space: burbujas breves con texto corto, flecha opcional hacia el objetivo y tecla a presionar (icono adaptado a teclado/gamepad según M57).
- Secuencias guiadas del prólogo: pasos cortos y encadenados con marcador de objetivo y retroalimentación de éxito (chirrido cozy, confeti ligero opcional).
- Sistema de consejos: tips de profundización opcionales, registrables como leídos, que aparecen solo en contextos de espera (carga, caminata larga) y son desactivables.
- Skip: saltear el capítulo actual, todo el tutorial restante, o desactivar las pistas desde opciones (M53/M57).
- Re-play: reiniciar el tutorial (o capítulos sueltos) desde el menú de opciones del juego.
- Persistencia: estado de capítulos completados, pistas desactivadas y consejos vistos en `GameState.M92`.
- Revalidación inteligente: si el jugador ya ejecutó la mecánica de forma espontánea (ej: ya pescó antes del capítulo), el capítulo se marca completo sin mostrar pasos redundantes.
- Feedback de avance: el HUD indica brevemente "mejora recibida: consejo de la abuela" o similar al completar una lección (alineado con M44).
- Watchdog anti-softlock: si un trigger de tutorial se pierde (jugador eliminó el objeto de la lección, huésped del mundo no cargado), la lección se re-programa o se descarta con log en M103.

### 3.2 Fuera del alcance
- El contenido propiamente de diálogos de los NPC tutores (M21) y sus misiones (M22/M23).
- Las mecánicas que se enseñan (movimiento M11, interacción M70, herramientas M13, cultivo M33, pesca M34, minería M35, crafting M16, amistad M20): el 92 solo las "enseña", no las implementa.
- La gestión de opciones gráficas/audio (M90/M91); el interruptor de tutorial vive en opciones de juego (M53).
- La IA de NPC (M64) y diálogos de historia (M22).
- La localización final de textos (M53 posee el flujo de traducción; el 92 entrega claves `tr()`).
- El tutorial en un sentido clásico de "misión": no crea misiones en el diario ni en M22; es guía contextual desacoplada.

## 4. Restricciones

- Motor: Godot 4.x + Voxel Tools (GDExtension), lenguaje GDScript. Prohibido C# para gameplay.
- Regla roja cozy: el tutorial NUNCA bloquea al jugador (ni movimientos ni acciones); si el jugador hace otra cosa mientras se muestra una pista, la pista desaparece sin castigo y el capítulo queda pendiente.
- Sin paredes de texto: cada pista ≤ 2 líneas cortas; guiones con máximo 3 pasos visibles a la vez.
- Desacople: los guiones del 92 no conocen las clases concretas de UI (M53) ni de los sistemas enseñados (M13, M33, M70...); solo contratos y señales.
- Una sola fuente de verdad de config: las opciones de tutorial (activado/skip/consejos) viven en la config de juego (M53/M57) y el 92 solo las lee.
- Persistencia liviana: solo enum de capítulos + flags; prohibido guardar posiciones o timestamps adicionales.
- Rendimiento: el sistema de pistas no puede costar más de ~0.2 ms por frame dentro de su presupuesto; las pistas activas son como máximo 2 simultáneas.
- Re-jugabilidad: el estado del tutorial es POR GUARDADO; un nuevo juego comienza el tutorial limpio, y se detecta "jugador que ya sabe" por revalidación, no por config global.
- Compatibilidad con gamepad y remapeo (M57): los iconos de tecla se leen del InputMap, nunca se hardcodean.
- Accesibilidad (M58): las pistas deben poder alargarse en tiempo (jugadores con lectura lenta), agrandarse y contrastarse; el 92 provee los datos, M58/M53 la presentación final.

## 5. Requisitos Funcionales (RF)

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tutorial por capítulos | El tutorial se estructura en capítulos: Llegada, Moverse, Interactuar (M70), Herramientas (M13), Cultivo (M33), Pesca (M34), Minería (M35), Crafting (M16), Primeros Vecinos (M19/21). Cada capítulo es un guion reutilizable. |
| RF2 | Triggers contextuales | Cada capítulo posee uno o más triggers definidos por eventos: señal de sistema (M70, M33...), condición de mundo (proximidad, hora, día) o acción del jugador (primer paso, primera tecla E). |
| RF3 | Detección de "ya lo sabe" | Si el jugador ejecuta la mecánica de un capítulo antes de su trigger (ej: pesca antes del capítulo de pesca), el capítulo se completa en silencio y se salta la guía de ese ítem. |
| RF4 | Pistas contextuales | Pautas world-space: burbuja anclada al elemento de la lección con texto ≤ 2 líneas, ícono de tecla dinámico (InputMap) y flecha opcional al objetivo. Desaparecen al cumplir la acción o al alejarse. |
| RF5 | Secuencia guiada de prólogo | Los primeros pasos (llegada a la playa, primer vistazo a la cabaña) se encadenan en secuencia guiada corta con marcador de objetivo en HUD y sin diálogo pesado. |
| RF6 | Sistema de consejos | Tips opcionales de profundización (ej: "regar de mañana hace crecer más rápido") aparecen una sola vez en contextos permitidos; se registran como vistos y se desactivan por opción. |
| RF7 | Skip global y por capítulo | El jugador puede saltear el capítulo actual y/o desactivar el tutorial restante; la opción se persiste por guardado. |
| RF8 | Re-play desde menú | Desde opciones del juego (M53) se puede reiniciar el tutorial completo o capítulos sueltos; el estado previo se conserva hasta confirmar. |
| RF9 | Pistas desactivables | El interruptor "Pistas contextuales" (on/off) apaga todas las burbujas world-space sin afectar las secuencias guiadas del prólogo ni los consejos (que tienen su propio interruptor). |
| RF10 | No interrumpir acciones | El tutorial jamás interrumpe una interacción en curso de M70, un diálogo de M21, una animación o una cutscene; espera la señal de fin o se cancela. |
| RF11 | Enseñanza Moverse | Capítulo guiado: usar WASD/joystick para el primer tramo (5-10 s), con pista de elegir una dirección y celebrar la llegada al punto. |
| RF12 | Enseñanza Interactuar (M70) | Al llegar al primer interactuable "emoji de bienvenida" (tipo tótem), la pista explica la tecla E (ícono del InputMap), la burbuja del 70 y el prompt del HUD. |
| RF13 | Enseñanza Herramientas (M13) | Al equipar la primera herramienta (hacha o azada de madera), pista corta: cómo equipar, qué hace, y gestión de energía. |
| RF14 | Enseñanza Cultivo (M33) | En el primer campo: azada → semilla → regar → esperar → cosechar con E; cada paso con su pista contextual, sin diálogo. |
| RF15 | Enseñanza Pesca (M34) | En el primer muelle: equipar caña, lanzar, mini-juego (timing de barra), recoger pez; pistas por fase; opcional relajar con consejo. |
| RF16 | Enseñanza Minería (M35) | En la primera veta: pico, animación de romper, recoger mineral; pista de energía y de sondear con el pico. |
| RF17 | Enseñanza Crafting (M16) | Al abrir el primer banco de trabajo: mostrar la receta del ítem requerido por la historia, fabricar, verificar en inventario (M14). |
| RF18 | Enseñanza NPCs (M19/21) | En la plaza: saludar con E al primer vecino, elegir opción de diálogo, recibir el primer regalo; pista suave de que se puede volver a hablar por día. |
| RF19 | Revalidación por acción espontánea | El gestor de revalidación marca un capítulo "hecho" si detecta la señal equivalente a su meta (ej: señal de M34 "pez_capturado") y lo registra sin mostrar pasos. |
| RF20 | Reprogramación de triggers | Si un trigger no puede dispararse (objeto de la lección indisponible, mundo streamed out por M63), la lección se re-programa hasta 3 intentos o se descarta con log (M103). |
| RF21 | Localización | TODOS los textos (pistas, guiones, consejos, botones) se escriben como claves localizadas `tr()`; sin texto hardcodeado en el 92. |
| RF22 | Iconografía dinámica de tecla | Los íconos de teclas se resuelven en runtime desde el InputMap activo y el dispositivo (teclado/gamepad) según M57; si la tecla es remapeada, la pista muestra la nueva. |
| RF23 | Watchdog anti-softlock | Si el tutorial queda a la espera de una acción que el jugador no puede realizar (objeto destruido, NPC dormido en M19), el watchdog de M66 libera el capítulo tras timeout configurable (default 120 s). |
| RF24 | Celebrar el avance | Al completar cada capítulo: feedback unificado breve (sonido de éxito de M44 + mensaje de capítulo completado en HUD, 2 s, sin modal obligatorio). |
| RF25 | Variabilidad de reemplazo de pantalla | Si el jugador abre un menú/diálogo mientras hay pista activa, la pista se oculta y reaparece (sin parpadeo) al cerrar, solo si el contexto sigue vigente. |

## 6. Requisitos No Funcionales (RN)

| # | Requisito | Detalle |
|---|---|---|
| RN1 | Cozy | Prohibido frustrar: ningún castigo por ignorar una pista; el tono es amable, corto y sin urgencia ("cuando quieras" en lugar de "debés"). |
| RN2 | No intrusivo | La suma de tiempo con pistas activas no supera el 10% de la sesión de juego; nunca hay más de 2 elementos de tutorial en pantalla. |
| RN3 | Duración controlada | El tutorial completo (capítulos principales + prólogo) debe completarse en 15-20 minutos para un jugador nuevo; medible en editores de test (M104 Analytics puede registrar hitos). |
| RN4 | Rendimiento | Presupuesto ≤ 0.2 ms/frame para la lógica del 92; las burbujas usan menos de 3 nodos UI cada una y se reciclan (pool). |
| RN5 | Desacople | El 92 no referencia clases concretas de M13/M33/M34/M35/M16/M19/M21/M53; solo señales, contratos y una interfaz `ITutorialTarget` opcional para objetos que marcan lecciones. |
| RN6 | Persistencia mínima | `GameState.M92` guarda: `{capitulos: {id: completado}, pistas_off: bool, consejos_off: bool, consejos_vistos: []}`; peso < 1 KB. |
| RN7 | Localizable | 100% de textos por `tr()`; soporte inicial ES/EN; sin concatenaciones rompibles. |
| RN8 | Determinismo | Para la misma secuencia de inputs y mundo, el mismo resultado de disparo de lecciones (tests de regresión). |
| RN9 | Testabilidad | Todo trigger y guion es instanciable sin escena real (mocks de M33/M34/M70), permitiendo Edit Mode y Play Mode tests en Unity-paridad con el resto del protocolo. |
| RN10 | Estabilidad | Un capítulo roto (sin target, señal nunca emitida) NUNCA bloquea la partida: watchdog + re-programación + descarte seguro. |
| RN11 | Rejugabilidad | El 92 se re-inicializa limpio en partida nueva; el re-play manual no contamina la partida en curso (snapshot del estado antes de re-jugar). |
| RN12 | Accesibilidad | Pistas con duración extendida configurable (x1, x2, x4), tamaño de fuente del HUD de tutorial seguible desde M58, y alto contraste opcional. |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M053** — UI/UX | Tutorial en UI |
| **M070** — Interacciones | Base para interacciones |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M053** — UI/UX | Depende de este módulo |
| **M070** — Interacciones | Depende de este módulo |

