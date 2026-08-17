**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 58: Accesibilidad

## ID del Módulo

- **Código:** M58 (módulo transversal del proyecto)
- **Carpeta:** `DOCUMENTACION/58-Accesibilidad/`
- **Dependencias:** M53 (UI-UX), M57 (Interfaz de Control). Relaciones: M88 (Fuentes Tipográficas), M90 (Configuración Gráfica), M91 (Configuración de Audio), M87 (Internacionalización).
- **Delegable desde:** hoy (documentación completa; implementación sobre Godot 4.x + GDScript)

## 1. Problema

El juego "Isla Ancestral" (mundo voxel cozy en la isla Aurora, estilo Stardew Valley) debe poder ser jugado por **todo tipo de jugadores**, incluidos quienes tienen discapacidades visuales (incluido daltonismo), auditivas, motoras, cognitivas o dificultades de lectura. Sin opciones de accesibilidad, muchos jugadores quedarían excluidos de la experiencia o sufrirían mareos, fatiga o frustración. La accesibilidad no puede ser un agregado posterior: debe ser un **módulo transversal** que se integre con la UI (M53), los controles (M57), las fuentes (M88), el audio y los subtítulos (M91) y la configuración gráfica (M90).

## 2. Objetivo

Crear un sistema de accesibilidad completo, persistente y aplicable **en tiempo real** (sin reiniciar el juego) que cubra cinco áreas: visual/color, auditiva, motora, cognitiva y lectoescritura. El sistema debe estar disponible desde el arranque (antes de cargar partida), ser navegable por teclado y mando, y no degradar el rendimiento del juego.

## 3. Alcance

### Incluye

- Perfiles de daltonismo (protanopia, deuteranopia, tritanopia) con vista previa en vivo.
- Modo de alto contraste y redundancia de información (nunca solo por color).
- Escalado de interfaz y tamaño de texto global (delega renders en M53/M88).
- Subtítulos configurables e indicadores visuales de eventos de audio.
- Remapeo completo de controles (navega y consume M57), modos retención/alternancia y asistencia de puntería.
- Modo de reducción de movimiento (mareos) y modos de dificultad relajados (sin combate estresante).
- Opciones de lectura: tamaño, espaciado, fondo de subtítulos, velocidad.
- Autosave frecuente y atajo de accesibilidad global.
- Persistencia del perfil en JSON dentro de `user://`.

### Excluye

- Síntesis de voz / lector de texto a voz completo (queda como extensión futura; se deja el punto de integración).
- Traducción de contenidos (es responsabilidad de M87 Internacionalización).
- Soporte táctil nativo (misma decisión que M57: capa lista, sin implementación en PC/Steam Deck).

## 4. Restricciones

- Motor **Godot 4.x**, lenguaje **GDScript** (prohibido C# y lógica fuera de Godot).
- **Nada de código en las capas de UI**: la lógica vive en managers/recursos desacoplados (regla de modularidad del proyecto).
- Cambios aplicados en vivo, sin reiniciar y sin reimportar assets.
- Persistencia atómica con backup (misma regla que M57).
- Los sistemas existentes (combate, IA, movimiento, M57, M53) **no se reescriben**: la accesibilidad se acopla por configuración y servicios.
- Tamaño de texto, contraste y filtros deben cumplir guías referenciales WCAG 2.2 AA cuando aplique (contraste ≥ 4.5:1 para texto normal, ≥ 3:1 para elementos grandes).
- Todo el contenido documental en español.

## 5. Requisitos Funcionales

### 5.1 Área visual / color

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Perfiles de daltonismo | Filtros protanopia, deuteranopia y tritanopia aplicables en vivo con vista previa (permutación de paleta y/o filtro matricial). |
| RF2 | Alto contraste | Modo que refuerza bordes, fondos y estados de UI para lectura con contraste ≥ 4.5:1. |
| RF3 | Escalado de interfaz | Escala global de UI 80 %–200 % en pasos de 10 % (aplicada por M53). |
| RF4 | Tamaño de texto | Escala de fuente global: Normal / Grande / Muy grande (delega render en M88). |
| RF5 | Redundancia de color | Ninguna información crítica (estado, rareza, alertas) se comunica únicamente con color: siempre hay icono o texto. |
| RF6 | Contornos de interactuables | Objetos interactuables con contorno/borde destacado opcional (afecta shaders de mundo, no solo UI). |
| RF7 | Fondo legible | Opacidad de fondos de UI y subtítulos configurable (transparente → sólido). |

### 5.2 Área auditiva

| # | Requisito | Detalle |
|---|---|---|
| RF8 | Subtítulos | Subtítulos en diálogos, eventos ambientales y alertas de combate; toggle, tamaño, fondo y velocidad configurables (se integra con M91). |
| RF9 | Indicadores visuales de audio | Avisos visuales (rizos/anillos, llamaradas) cuando suena un sonido no visualizable (insectos, agua, tesoros). |
| RF10 | Volúmenes por bus | Volúmenes independientes Maestro/Música/SFX/Ambiente/Voz/UI ya provistos por M91; accesibilidad solo los referencia y permite "Silenciar ambientes en eventos". |
| RF11 | Alertas visuales de estado | Eventos importantes (baja vida, aviso de tormenta) muestran cartel visual además de sonido. |
| RF12 | Sin dependencia auditiva crítica | Ningún puzzle o progreso exige oír un sonido específico sin alternativa visual. |

### 5.3 Área motora

| # | Requisito | Detalle |
|---|---|---|
| RF13 | Remapeo completo | Todas las acciones remapeables por teclado, ratón y mando, con perfiles (consume la capa de acciones de M57; nunca scancodes directos). |
| RF14 | Retención/alternancia | Acciones de mantener (correr, agachar, mirar alrededor) tienen opción "mantener" o "alternar". |
| RF15 | Asistencia de puntería | Slider 0–100 %: repele/suaviza la puntería hacia blancos (pesca, minería, combate) sin quitar control total. |
| RF16 | Vibración | Permite desactivar la vibración / feedback háptico por completo (integra entrada de M57). |
| RF17 | Dead zones y sensibilidad | Dead zones, sensibilidad por eje e inversión configurables (delegado a M57, expuestos aquí como accesos directos). |
| RF18 | Pausa accesible | El juego se pausa de inmediato con un único botón/tecla desde cualquier estado; sin diálogos intermedios. |

### 5.4 Área cognitiva

| # | Requisito | Detalle |
|---|---|---|
| RF19 | Modos de dificultad | Presets: "Sereno" (sin combate estresante, sin penalizaciones por muerte, timers extendidos), "Estándar" y "Personalizado". |
| RF20 | Sin timers hostiles | En modo Sereno los timers de eventos (pesca, misiones) se extienden o eliminan. |
| RF21 | Reducción de movimiento | Modo que reduce/mitiga sacudidas de cámara, parallax rápido, motion blur y transiciones bruscas (anti-mareo). |
| RF22 | Guías y tutoriales | Tutoriales opcionales, pistas de objetivos y marcador de dirección reinforzado (sin necesidad de recordar rutas). |
| RF23 | Diálogos a ritmo propio | Diálogos nunca con cuenta regresiva; avanzar a botón y reabrir con historia del último diálogo (integra M21). |

### 5.5 Área lectoescritura

| # | Requisito | Detalle |
|---|---|---|
| RF24 | Opciones de lectura | Tamaño, espaciado de líneas y estilo de fuente (Nunito/Fredoka One legibles, M88) ajustables desde el menú. |
| RF25 | Subtítulos para lectura | Subtítulos con fondo opaco, tamaño grande y velocidad de aparición configurable, activos por defecto. |
| RF26 | Texto crítico simple | Los textos críticos (instrucciones, alertas) usan vocabulario simple y frases cortas; sin depender de lectura veloz. |
| RF27 | Texto grande global | Opción "Texto grande" que escala todos los textos de UI, incluyendo diálogos y subtítulos. |
| RF28 | Punto de integración TTS | Interfaz/evento de lectura de texto expuesto para una futura extensión de síntesis de voz (no implementada). |

### 5.6 Sistema general

| # | Requisito | Detalle |
|---|---|---|
| RF29 | Autosave frecuente | Autosave cada 5 minutos de juego y en hitos (dormir, completar misión, entrar a templo) sin pantalla de carga y sin pausar. |
| RF30 | Atajo de accesibilidad | Acceso al menú de accesibilidad con un atajo global (por defecto F10 en teclado / combinación en mando) desde cualquier pantalla, incluida la de título. |
| RF31 | Acceso pre-partida | Opciones de accesibilidad disponibles en la pantalla de título ANTES de cargar partida (el perfil se aplica sin partida abierta). |
| RF32 | Reset y backups | Reset del perfil a valores por defecto y recuperación del último perfil válido ante corrupción del JSON. |
| RF33 | Vista previa en vivo | Todos los sliders/toggles muestran su efecto inmediatamente (previews con escena de prueba del menú). |

## 6. Requisitos No Funcionales

- **Rendimiento:** aplicar el perfil no debe superar ~1 ms de overhead por frame; filtros de color vía shader en canvas (o modulate como fallback en calidad baja); sin allocaciones en `_process`.
- **Compatibilidad:** Godot 4.x estable; funciona con presets gráficos Bajo/Medio/Alto (M90); Steam Deck y mandos genéricos (M57); sin dependencias de plugins no oficiales.
- **Persistencia:** JSON en `user://accesibilidad/profile.json`, escritura atómica (archivo temporal + renombrado) y backup `profile.backup.json`.
- **Usabilidad:** menú navegable por completo con teclado y mando (focus system de M53); cambios aplicados al instante sin reiniciar; textos de ayuda de una línea por opción.
- **Calidad:** cero errores en consola al entrar en Play Mode; cero advertencias de tipos GDScript; documentación actualizada y checklist completo antes de delegar.
- **Idioma:** UI y documentación en español.

## 7. Criterios de Aceptación

1. Las cinco áreas (visual, auditiva, motora, cognitiva, lectoescritura) tienen opciones visibles y funcionales en un mismo menú de accesibilidad.
2. Todas las opciones se aplican en vivo y persisten entre sesiones (JSON en `user://`).
3. El perfil de accesibilidad se puede cargar, resetear y recuperar ante corrupción.
4. Integración verificada con M53 (escalado UI), M57 (remapeo/dead zones/vibración), M88 (fuentes), M90 (post-processing/quality) y M91 (subtítulos/volúmenes).
5. Modo Sereno, reducción de movimiento y asistencia de puntería funcionan sobre los sistemas existentes sin modificarlos.
6. Autosave frecuente activo y verificado en sesiones largas (≥ 30 min jugados sin pérdida de progreso).
7. Checklist del módulo con 125+ ítems completados y módulo marcado delegable para implementación.