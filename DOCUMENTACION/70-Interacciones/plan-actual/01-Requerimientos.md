**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 70: Interacciones

## ID del Módulo
- **Código:** M70 (plan maestro: sistema de interacciones del jugador con el mundo)
- **Carpeta:** `DOCUMENTACION/70-Interacciones/`
- **Dependencias:** M11 (Personaje Del Jugador), M13 (Herramientas), M08 (Mundo Voxel / Voxel Tools)
- **Consumidores:** M19 (NPC y Vecinos), M21 (Diálogos), M33 (Agricultura), M35 (Minería), M36 (Fauna), M65 (Animales IA), M18 (Casas), M14 (Inventario), M17 (Construcción), M22/M24/M26 (Eventos y Puzzles), M66 (Anti-Softlock)
- **Relacionados:** M53 (UI-UX), M57 (Interfaz De Control), M44 (ASMR y Feedback), M43 (Efectos De Sonido), M63 (Cargas Y Streaming), M29/M30/M31 (Tiempo)
- **Delegable desde:** documentación completa; implementación junto con el primer playable con Voxel Tools (hito M1)

## 1. Problema

En un mundo voxel cozy con decenas de elementos con los que el jugador puede interactuar (objetos recogibles, puertas, cofres, cosechas, animales, vecinos, eventos), la interacción fragmentada por sistema produce inconsistencias: distintos modos de detección, prompts visuales dispares, prioridades arbitrarias y feedback incoherente. Sin un sistema unificado, el jugador no sabe qué puede tocar, con qué tecla, ni qué pasará al presionarla; y cada módulo consumidor reinventa la rueda. El módulo 70 centraliza la detección, selección, indicación, despacho y feedback de TODA interacción del jugador con el mundo, con personalidad cozy: clara, amable, predecible y sin frustración.

## 2. Objetivo

Unificar cómo el jugador interactúa con el mundo de la isla Aurora mediante una única tecla de interacción (E) por proximidad, con indicador visual explícito sobre el objetivo seleccionado, prioridad determinística entre interactuables cercanos, estados claros (interactuando / no disponible) y despacho a los sistemas consumidores (diálogos, cosechas, cofres, animales, eventos) por contrato, sin acoplar el gestor a ningún sistema concreto.

## 3. Alcance

### 3.1 Dentro del alcance
- Registro y detección de interactuables por proximidad, con radio configurable por interactuable.
- Selección de UN objetivo con reglas de prioridad determinísticas (categoría, distancia, ángulo).
- Línea de visión con Voxel Tools (bloqueo por geometría voxel cuando corresponda).
- Prompt visual: indicador "E" sobre el objetivo (world-space) + línea de contexto en HUD con nombre del objeto (localizable).
- Acción única (E) con despacho por interfaz; soporte gamepad y remapeo (InputMap de Godot 4.x).
- Estados de interacción: disponible, interactuando (bloqueo), no disponible (con razón), oculto.
- Cancelación por salir de rango, cambiar de objetivo o nuevo input.
- Feedback mínimo unificado: chirrido de interacción, animación del indicador, partículas opcionales por categoría.
- Bloqueo mutuo con UI abierta (menús, diálogos, inventario) y pausa.
- Persistencia ligera del estado de interactuables (GameState.M70).

### 3.2 Fuera del alcance
- La mecánica concreta de cada interacción (cosechar, hablar, abrir cofre) la definen los módulos consumidores (M33, M19/M21, M14, M65, M18, M35, M36).
- La gestión de inventario (M14), crafting (M16), construcción (M17) y herramientas (M13).
- Los contenidos de diálogo (M21) y misiones (M22/M23).
- La IA de NPC (M64) y de animales (M65).
- La lógica de luces y esporas de luz del personaje (M11/M14).
- El sistema de control global de Godot (M57) solo se consume, no se reemplaza.

## 4. Restricciones

- Motor: Godot 4.x + Voxel Tools (GDExtension), lenguaje GDScript. Prohibido C# para gameplay.
- El gestor de interacciones NO puede conocer clases concretas de otros módulos: solo contrato (interfaz `IInteractable`).
- Rendimiento: la detección no puede costar más de ~0.5 ms por frame en escenarios densos (isla poblada con decenas de interactuables visibles); prohibido iterar la lista completa con raycast por objeto en el mismo frame.
- Reparto de responsabilidades: el módulo 70 es UI-aware pero no UI-owner; los prompts visuales se dibujan en su CanvasLayer propio y se rigen por las normas de M53/M57.
- Una sola fuente de verdad de input: la acción "interact" del InputMap; el 70 escucha y los consumidores NO escuchan la tecla E por su cuenta.
- Cozy como regla roja: presionar E sin objetivo no genera error ni castigo; el prompt nunca parpadea ni titila; si el jugador se aleja en plena interacción, el cierre es suave.
- Estandarización de tecla: el usuario juega con E; los módulos 11 y 19 referencian F en documentación histórica; al implementar se unifica en el InputMap con E (y el remapeo de M57 lo permite).
- Compatibilidad total con el mundo voxel: el terreno es voxel; la línea de visión usa el voxel world (VoxelTool) o equivalente, no solo colliders de física.

## 5. Requisitos Funcionales (RF)

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Registro de interactuables | Todo ente interactuable se registra (automáticamente en `_ready` o manual) en el InteractionManager al entrar al mundo activo y se desregistra al salir (M63 streaming). |
| RF2 | Categorías de interacción | El contrato expone categorías: objeto recogible, NPC, cosecha, puerta, cofre, animal, evento/trigger, decorativo. Cada categoría define icono, sonido y prompt por defecto. |
| RF3 | Detección por proximidad | Radio de interacción por interactuable (default 2.5 m, configurable; el rango base del personaje es 4 m según M11). |
| RF4 | Filtrar candidatos | Solo candidatos válidos: en rango, con línea de visión (según config), no bloqueados, no ocultos, con requisitos cumplidos. |
| RF5 | Selección de objetivo | Siempre UN objetivo: se ordena por (prioridad de categoría, distancia, desviación angular del frente del jugador). Determinístico, sin empates aleatorios. |
| RF6 | Prompt visual | Indicador "E" sobre el objetivo (world-space, flotando) + línea de contexto en HUD con el nombre localizado; oculto si no hay objetivo o el jugador está en otra interacción. |
| RF7 | Prompt diferenciado | Si el objetivo es utilizable con herramienta y el jugador tiene la herramienta adecuada en mano (M13), el prompt muestra el ícono/tecla secundaria; si es "no disponible", el prompt aparece atenuado con razón opcional. |
| RF8 | Acción única E | Presionar E sobre un objetivo disponible dispara `interactuar(...)` del contrato; el gestor NO decide la mecánica. |
| RF9 | Despacho asíncrono | El consumidor puede declarar la interacción como larga (hold) o instantánea; el gestor lo respeta sin bloquear frames. |
| RF10 | Bloqueo durante interacción | Mientras una interacción está en curso, el gestor no selecciona otro objetivo ni muestra otros prompts (estado INTERACTUANDO). |
| RF11 | Estados por interactuable | Cada interactuable expone: DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE (con razón), OCULTO. El gestor consulta el estado en cada evaluación. |
| RF12 | Cancelación por distancia | Si el jugador se aleja del rango con el objetivo seleccionado, el prompt desaparece de inmediato (y la interacción en curso se cancela de forma suave si el consumidor lo permite). |
| RF13 | Cancelación por objetivo | Si otro interactuable supera la prioridad (p. ej. el jugador gira), el gestor cambia el objetivo sin parpadeos (fade si el prompt está visible). |
| RF14 | Cancelación por UI | Abrir menú/diálogo/inventario o pausar cancela la selección; al cerrar, se re-evalúa en el siguiente frame. |
| RF15 | Feedback unificado | Al ejecutar una interacción: sonido de chirrido por categoría (base M11), micro-animación del prompt (pulse), partículas opcionales del consumidor; feedback distinguible de éxito, fallo y "no disponible". |
| RF16 | Cooldown opcional | El contrato puede declarar un cooldown corto por interactuable (p. ej. puertas que se abren una vez por segundo); el gestor lo respeta y no re-selecciona durante el mismo. |
| RF17 | Requisitos previos | El contrato expone `requisitos_cumplidos(jugador)`: herramienta en mano (M13), item en inventario (M14), hora del día (M29/M31), estación, amistad (M20); si no cumple, el interactuable entra NO_DISPONIBLE. |
| RF18 | Persistencia de estado | El estado persistente de interactuables relevantes (cofres abiertos, puertas, cosechas recogidas, animales acariciados) se guarda en `GameState.M70`. |
| RF19 | Re-evaluación incremental | El gestor evalúa candidatos en cada frame, pero la búsqueda de línea de visión se espacia (cada N frames o con suavizado) para respetar el presupuesto. |
| RF20 | Soporte gamepad | Acción "interact" mapeada también a A/B en gamepad según normativa M57; el prompt muestra el ícono del dispositivo activo. |
| RF21 | Accesibilidad | Opciones de mantener presionado o pulso simple, tamaño de prompt ajustable y alto contraste (se delega la UI final a M53/M57; el gestor provee los datos). |
| RF22 | Ignorar mientras no-interactuable | Interactuables con estado OCULTO o NO_DISPONIBLE por sistema (p. ej. vecino durmiendo, M19 `set_ocupado`) se excluyen con feedback "no disponible" solo si el jugador presiona E con el prompt atenuado visible. |
| RF23 | Eventos y triggers | Los triggers de evento (M22/M24/M26) se modelan como interactuables especiales que solo se activan cuando el jugador presiona E dentro de su zona, sin prompt si son involuntarios. |
| RF24 | Interactuables en movimiento | Animales (M56) y NPC con IA (M64) se reconocen por su hitbox actualizada; el gestor no cachea posiciones por más de un frame para los móviles. |
| RF25 | Coherencia de input | El gestor se pausa con el juego (ProcessMode Always / pausable) y se inhabilita cuando hay UI modal (M53), siguiendo la normativa de una única fuente de input. |

## 6. Requisitos No Funcionales (RN)

- **Cozy (regla roja):** cero frustración. La interacción nunca rompe el ritmo: prompts suaves, sonidos amables (sin sustos), cero castigos por pulsar E a destiempo; el "no disponible" se comunica con respeto (prompt atenuado con razón opcional).
- **Rendimiento:** detección O(n) barata por frame con filtrado previo por distancia (n = interactuables en radio de transmisión, típicamente < 40); raycast de línea de visión espaciado y acotado a 1 objetivo candidato por frame o por lote; presupuesto total < 0.5 ms/frame en PC objetivo.
- **Desacople:** el interaction manager no importa módulos consumidores; comunica exclusivamente por interfaz `IInteractable` y señales; los consumidores registran proveedores de categoría para datos de presentación (ícono, sonido).
- **Localización:** todo texto mostrado por el módulo (nombres de objetos, razones de no-disponibilidad) pasa por `tr()` de Godot (normativa M57).
- **Accesibilidad:** remapeo completo de la acción "interact" (M57), modos de pulso simple o mantener, contraste alto opcional.
- **Pausa y UI:** al pausar (menú, diálogo, inventario, cutscene) el gestor entra en estado DORMIDO y no dibuja prompts ni procesa input.
- **Persistencia:** `GameState.M70` con esquema acotado (snapshot de estados relevantes), sin guardar interactuables transitorios.
- **Compatibilidad Voxel Tools:** el raycast de línea de visión y el filtrado por paredes usan el voxel world (M08); contenga fallback a PhysicsRayQuery si la categoría lo configura.
- **Determinismo:** la selección de objetivo es 100% determinística para la misma entrada (sirve para tests y debug M110).
- **Testeabilidad:** el gestor es un autoload con dependencias inyectables (jugador, vocabulario voxel) para poder testear en Edit Mode con escenario simulado.
- **Seguridad de contratos:** nunca throw; cualquier error de implementación de un consumidor se loguea (M103) y se degrada a "no disponible" sin romper el frame.
- **Documentación sincronizada:** cualquier cambio de contrato se refleja en este módulo y en un log (normativa del proyecto).

## 7. Criterios de Aceptación

1. El gestor selecciona y muestra prompt sobre UN objetivo en una escena con 5+ interactuables superpuestos, respetando prioridad de categoría y distancia.
2. Presionar E ejecuta la acción correcta del objetivo seleccionado (verificado con mocks de cada categoría).
3. Con dos interactuables a distinta distancia, se selecciona el de mayor prioridad; con igual categoría, el más cercano; con igual distancia, el de menor desviación angular.
4. El prompt desaparece al salir de rango, al abrir UI/pausa y al cambiar de objetivo; sin parpadeos.
5. Durante una interacción en curso, no se selecciona otro objetivo (bloqueo verificado).
6. El presupuesto de rendimiento (< 0.5 ms) se respeta en una escena densa (40 interactuables en radio de transmisión).
7. Los estados NO_DISPONIBLE / OCULTO se respetan (vecino durmiendo, cofre abierto, cosecha fuera de temporada).
8. Toda frase visible está localizable (`tr()`) y el prompt indica la tecla E con el ícono del dispositivo activo (teclado/gamepad).
9. `GameState.M70` guarda y restaura correctamente cofres, puertas y animales acariciados en una sesión nueva.
10. El módulo queda delegable para implementación con contrato `IInteractable` estable y pruebas de integración definidas.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M011** — Personaje del Jugador | Sistema de interacciones |
| **M013** — Herramientas | Interacciones con herramientas |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M092** — Tutorial | Usado por tutorial |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M013** — Herramientas | Depende de este módulo |
| **M092** — Tutorial | Este módulo lo necesita |

