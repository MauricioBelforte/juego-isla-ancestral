# 08 - Guia Maestra de Orden de Implementacion

**Modelo:** GitHub Copilot
**Plataforma:** VS Code
**Fecha:** 2026-08-26
**Estado:** Referencia principal vigente para reservar y delegar trabajo de implementacion

> Esta guia define el orden real de construccion del proyecto. El numero del modulo identifica el dominio, pero **no define el orden de implementacion**.
>
> **Fuente de orden:** este archivo.
> **Fuente de estado, propietario y progreso:** `CHECKLIST-GLOBAL.md`.
> **Fuente de coordinacion entre agentes:** `Mensajes entre modelos/ESTADO-PARALELO.md`.

> **Regla de sincronizacion:** al reservar un modulo, el agente debe marcar la reserva en esta guia 08, en el `05-Checklist.md` del modulo, en `CHECKLIST-GLOBAL.md` y en `ESTADO-PARALELO.md`. Los cuatro registros deben coincidir.

## Reserva actual

| Módulo | Estado | Agente | Fase | Visión | Entrada | Salida | Archivos afectados |
|---|---|---|---|---|---|---|---|
| M04 Game Engine | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | F1 | V1 | Validar la base del proyecto Godot 4.7.2 y confirmar runtime sin bloqueos | Proyecto arrancable y sin errores de motor antes de seguir con M05/M07 | `game/isla-ancestral/project.godot`, `game/isla-ancestral/scenes/main_island.tscn`, correción de Transform3D y strings |
| M05 Lenguaje y Programacion | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | F1 | V0 | Convenciones GDScript aplicadas | Tipado estatico, naming correcto, anti-patrones documentados | `07-GUIA-GODOT.md`, scripts varios |
| M08 Mundo Voxel | ✅ Completado | MiMo V2.5 (OpenCode) | F2 | V2 | Voxel Tools configurado | Terreno OK, colisión OK, WASD OK, cámara OK, edición E/Q OK | `scripts/world/flat_ground_generator.gd`, `scripts/player/player.gd`, `scripts/main_island.gd` |
| M11 Personaje del Jugador | ✅ Completado | MiMo V2.5 (OpenCode) | F3 | V2 | CharacterBody3D funcional | WASD + gravedad + colision suelo + pivot camara + interaccion E/Q + movimiento relativo a camara | `scripts/player/player.gd` |
| M12 Camara | ✅ Completado | MiMo V2.5 (OpenCode) | F3 | V2 | Camera3D + rotacion + zoom + colision + GameSettings | Rotacion mouse, zoom scroll, colision terreno, sensibilidad configurable | `scripts/follow_camera.gd` |
| M53 UI/UX | 🔵 En curso | MiMo V2.5 (OpenCode) | F6 | V2 | Infraestructura core UI creada | UIManager, UILayer, MenuNavigator, HUDScreen, TooltipService, NotificationService, ThemeUx | `scripts/ui/core/`, `scripts/ui/hud/`, `scripts/ui/services/`, `scripts/ui/theme/` |

---

## 1. Regla principal

Ningun agente debe reservar un modulo solo porque aparezca como `🟢 Disponible`. Antes debe comprobar que:

- [ ] El modulo aparece en una fase habilitada de esta guia.
- [ ] Todas sus dependencias tecnicas estan `✅` o tienen un contrato aprobado para el hito actual.
- [ ] No existe otro agente trabajando en el modulo o en sus archivos.
- [ ] El agente puede cumplir la complejidad, el presupuesto de rendimiento y los requisitos de vision del modulo.
- [ ] El agente leyo el `plan-actual/` completo del modulo.
- [ ] El agente registro la reserva en `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md`.
- [ ] El agente marco el punto de entrada y la salida esperada en esta guia.

Un modulo puede investigarse antes de estar habilitado, pero debe marcarse como **investigacion previa**, no como implementacion reservada.

---

## 2. Principio de construccion

El proyecto se implementa de abajo hacia arriba:

```text
Contrato de producto
  -> Motor y arquitectura
  -> Mundo minimo
  -> Jugador y camara
  -> Interaccion y herramientas
  -> Prototipo jugable
  -> Sistemas de soporte
  -> Contenido
  -> Pulido visual y produccion
  -> QA, rendimiento y lanzamiento
```

La primera meta no es completar muchos modulos. La primera meta es obtener un **M1 jugable, visible y medible**.

---

## 3. Mapa de fases y puertas

| Fase | Objetivo | Modulos principales | Puerta de salida |
|---|---|---|---|
| 0 | Reglas y contratos | M01, M02, M03, M06, M152, M153, M154 | Alcance, vision y proceso congelados |
| 1 | Fundacion ejecutable | M04, M05, M07 | Proyecto Godot arranca con arquitectura base |
| 2 | Mundo minimo | M08, M09, M10 | Isla pequena determinista, editable y visible |
| 3 | Primer control jugable | M11, M12, M13 | Jugador se mueve, mira y usa una herramienta |
| 4 | Prototipo minimo divertido | M14, M15, M19, M21, M24, M25, M59, M137 | Bucle jugable completo y decision GO/NO-GO |
| 5 | Base de produccion | M16, M17, M18, M20, M22, M29, M31, M32, M38, M40, M61, M63 | Sistemas conectados con contratos y presupuestos |
| 6 | Vertical slice | M26, M41-M52, M53, M57, M58, M70, M89, M114, M138 | Una experiencia pequena pulida de principio a fin |
| 7 | Produccion de contenido | M23, M27, M28, M30, M33-M37, M39, M54-M56, M64-M75 | Contenido escalable sobre sistemas estables |
| 8 | Arte y calidad final | M45-M50, M87-M91, M101-M113, M115, M122, M130-M136 | Assets, accesibilidad, QA y rendimiento aprobados |
| 9 | Release | M76-M86, M95-M100, M116-M121, M123-M129, M139-M153 | Build certificada y lanzamiento preparado |

Los rangos son orientativos; la puerta y las dependencias mandan. Un modulo de una fase posterior puede investigarse, pero no debe introducir runtime que dependa de una puerta aun cerrada.

### 3.1 Escala de dificultad y vision

| Dificultad | Significado | Perfil recomendado |
|---|---|---|
| 1 | Documentacion, datos simples o ajuste aislado | Agente rapido o de investigacion |
| 2 | Sistema pequeno con pocas dependencias | Agente generalista |
| 3 | Sistema integrado con pruebas y persistencia | Agente con experiencia en Godot |
| 4 | Sistema transversal, visual o con varias integraciones | Agente robusto con validacion MCP |
| 5 | Riesgo tecnico alto, rendimiento o integracion critica | Agente senior, pruebas y QA cruzado |

| Vision | Significado | Regla de reserva |
|---|---|---|
| V0 | No necesita observar pixeles | Puede asignarse a un agente sin vision |
| V1 | Vision recomendable para QA o pulido | Preferir agente con vision; puede avanzar sin ella |
| V2 | Vision necesaria para validar el resultado | Solo reservar con MCP/capturas operativas |

La dificultad describe el riesgo del modulo, no la cantidad de archivos. La marca de vision describe si el resultado puede darse por terminado sin observar el juego, el editor o el asset.

### 3.2 Matriz de la ruta critica

| Orden | Modulo | Dificultad | Vision | Trabajo principal | Puede ir en paralelo |
|---:|---|:---:|:---:|---|---|
| 1 | M04 Game Engine | 5 | V1 | Proyecto, renderer, input, build | No |
| 2 | M05 Lenguaje y Programacion | 3 | V0 | Convenciones y utilidades | Con M04, sin pisar archivos |
| 3 | M07 Arquitectura General | 5 | V0 | Servicios, eventos, contratos | Despues del contrato de M04 |
| 4 | M08 Mundo Voxel | 5 | V2 | Chunks, Voxel Tools, edicion | No; bloquea M09/M10 |
| 5 | M10 Generacion del Mundo | 5 | V1 | Seed y generacion determinista | Con M09 solo en investigacion |
| 6 | M09 Terreno y Geografia | 4 | V2 | Aurora, alturas, costa y POI | Con M10 despues del contrato |
| 7 | M11 Personaje del Jugador | 4 | V2 | Movimiento, colision, pivot | Despues de M07; requiere M08 para prueba |
| 8 | M12 Camara | 2 | V2 | Seguimiento, zoom y encuadre | Despues de M11 |
| 9 | M13 Herramientas | 4 | V2 | Raycast, extraccion y colocacion | Despues de M08 y M11 |
| 10 | M14 Inventario | 3 | V1 | Slots y estado minimo | Con M15, sin depender de UI final |
| 11 | M15 Recursos | 3 | V1 | Recoleccion y drops | Con M14 |
| 12 | M59 Guardado | 5 | V0 | Serializacion, slots y migraciones | Con M14/M15, sin UI final |
| 13 | M19 NPC y Vecinos | 4 | V2 | NPC de prueba y presencia visual | Despues de M11 |
| 14 | M21 Dialogos | 4 | V1 | Conversacion y datos | Despues de M19 |
| 15 | M24 Templos y Puzzles | 5 | V2 | Puzzle observable y verificable | Despues de M13 |
| 16 | M25 Ruinas | 3 | V2 | Estructura pequena y legibilidad | Despues de M24 |
| 17 | M137 Prototipo | 5 | V2 | Integracion y GO/NO-GO | No; es la puerta F4 |
| 18 | M61 Rendimiento | 5 | V0 | Presupuesto, profiling y gates | Desde M08; cierre despues de M137 |
| 19 | M138 Vertical Slice | 5 | V2 | Recorrido visual completo | No; requiere F4 |

### 3.3 Matriz de lineas paralelas

Estas lineas pueden ejecutarse en paralelo **solo cuando la fase habilitante este abierta**. Un agente con vision debe preferir una fila V2; un agente sin vision debe preferir una fila V0.

| Linea | Modulos | Dificultad | Vision | Condicion para reservar |
|---|---|:---:|:---:|---|
| Datos y tiempo | M16, M29, M30, M32, M38, M40 | 2-4 | V0/V1 | F1 y contratos de M07 |
| Construccion | M17, M18 | 4/3 | V2 | M08 + M14 + M16 |
| Relaciones y narrativa | M20, M22, M23 | 3-4 | V1 | M19 + M21 |
| Viajes e islas | M27, M28 | 4/3 | V2 | M10 + M22 + M63 |
| Actividades | M33-M37 | 2-3 | V1 | M08/M14/M29 segun sistema |
| Economia y tiendas | M39, M93, M95 | 3-4 | V1 | M15 + M16 + M20 + M38 |
| Arte 3D y materiales | M45-M50 | 3-5 | V2 | M04 + escala de M08 + M61 |
| Agua y VFX | M51, M52 | 4/3 | V2 | M08 + M45 + presupuesto M61 |
| UI y accesibilidad | M53, M57, M58, M87-M91 | 2-4 | V2 | M11/M14 y F4 para polish |
| IA y fauna | M64, M65 | 4/3 | V1/V2 | M19 + M61 |
| QA y operacion | M101-M113, M115, M122 | 1-5 | V0/V1 | Prototipo ejecutable |

### 3.4 Regla de no interferencia visual

- [ ] Si un agente reserva un modulo V2, otro agente puede reservar simultaneamente un modulo V0 habilitado.
- [ ] Dos agentes no deben reservar a la vez dos modulos V2 que necesiten la misma escena, captura o sesion de Godot.
- [ ] Un agente V0 no debe modificar escenas, materiales, layout, camara, iluminacion ni assets que otro agente V2 este revisando.
- [ ] Un modulo V1 puede ser trabajado sin vision, pero queda con QA visual pendiente y no puede declararse definitivamente `✅` si su checklist exige captura.
- [ ] La vision es un recurso de validacion compartido: reservarla en `ESTADO-PARALELO.md` cuando dos tareas dependan de la misma ventana o Blender.

---

## 4. Fase 0 - Contratos y preparacion

**Proposito:** impedir que la implementacion contradiga la vision o que varios agentes creen contratos incompatibles.

- [x] Confirmar el alcance v1.0 y los pilares de diseno en M02.
- [x] Confirmar la estructura documental y el protocolo multiagente en M03.
- [x] Confirmar Git, ramas, logs y reglas de no pisado en M06.
- [x] Confirmar principios cozy, cero violencia y criterios de calidad en M152.
- [x] Confirmar el objetivo final verificable en M153.
- [x] Leer `06-GUIA-DE-CONEXION-VISION.md` antes de cualquier tarea visual.
- [x] Verificar al menos una via MCP operativa para tareas visuales.
- [x] Leer `07-GUIA-GODOT.md` antes de modificar GDScript.
- [x] Registrar toda reserva futura en `CHECKLIST-GLOBAL.md`.
- [x] Registrar toda reserva futura en `ESTADO-PARALELO.md`.

**Salida:** los agentes conocen el producto, las reglas y las herramientas. Esta fase no produce gameplay.

---

## 5. Fase 1 - Fundacion ejecutable

**Orden obligatorio:** `M04 -> M05 -> M07`.

### M04 - Game Engine

- [x] Fijar Godot `4.7.2` y documentar la version.
- [x] Crear o validar el proyecto Godot base.
- [x] Configurar renderer, resolucion y objetivo de 60 FPS.
- [x] Crear estructura de carpetas runtime.
- [ ] Configurar capas de fisica e Input Map inicial.
- [ ] Crear `Bootstrap` y `Main` vacios pero ejecutables.
- [x] Verificar build debug y salida de errores.

### M05 - Lenguaje y Programacion

- [x] Aplicar convenciones GDScript del proyecto.
- [x] Definir tipado, nombres y limites de complejidad.
- [x] Confirmar patrones permitidos y anti-patrones.
- [ ] Preparar utilidades basicas de validacion y logging.

### M07 - Arquitectura General

- [x] Implementar registro de servicios minimo.
- [x] Implementar contratos de `GameState` y `EventBus`.
- [ ] Definir orden de inicializacion de autoloads.
- [ ] Verificar dependencias unidireccionales.
- [ ] Ejecutar una escena vacia usando la arquitectura base.

**Puerta F1:** Godot arranca, los servicios se registran y no hay errores de arquitectura. Sin esta puerta no se reservan M08, M11, M29 ni M59 como implementacion runtime.

---

## 6. Fase 2 - Mundo minimo

**Orden recomendado:** `M08 -> M10 -> M09`.

### M08 - Mundo Voxel

- [x] Configurar Voxel Tools compatible con Godot fijado.
- [x] Crear terreno de prueba de un chunk `16^3`.
- [x] Implementar catalogo minimo: aire, tierra, piedra y madera.
- [x] Validar generacion, colision y remallado.
- [x] Probar extraccion y colocacion con coordenadas voxel.
- [x] Medir el costo de editar bloques.

### M10 - Generacion del Mundo

- [x] Integrar semilla fija de desarrollo.
- [x] Generar siempre el mismo chunk con la misma entrada.
- [x] Separar generacion de contenido y decoracion.
- [x] Evitar dependencias del orden de iteracion.

### M09 - Terreno y Geografia

- [x] Definir la forma minima de Aurora.
- [x] Aplicar alturas, costa y zona segura de inicio.
- [x] Reservar POI solo despues de validar el terreno base.
- [x] Capturar la isla con `screen.capture_window`.
- [x] Revisar escala, legibilidad y navegacion con vision.

**Puerta F2:** existe una isla pequena determinista, con colision y edicion, que se ve correctamente y mantiene el objetivo de rendimiento inicial.

---

## 7. Fase 3 - Primer control jugable

**Orden obligatorio:** `M11 -> M12 -> M13`.

### M11 - Personaje del Jugador

- [x] Implementar `CharacterBody3D` y colision.
- [x] Implementar movimiento basico y gravedad.
- [x] Implementar pivot para la camara.
- [x] Implementar interaccion basica.
- [x] Verificar escala del personaje frente al voxel de 1 m.

### M12 - Camara

- [x] Implementar seguimiento en tercera persona.
- [x] Implementar rotacion y zoom.
- [x] Verificar limites, suavizado y colision de camara.
- [x] Capturar una vista de juego y revisar encuadre.

### M13 - Herramientas

- [ ] Conectar el nucleo existente al mundo voxel real.
- [ ] Validar raycast, alcance y tipo de bloque permitido.
- [ ] Verificar feedback visual sin iluminar objetivos invalidos.
- [ ] Mantener el contrato `try_extract` / `try_place`.
- [ ] Dejar durabilidad, HUD y sonido desacoplados para fases posteriores.

**Puerta F3:** el jugador puede moverse, mirar, apuntar y usar una herramienta sobre un bloque valido. Esta es la primera sesion donde la vision de Copilot aporta valor directo.

---

## 8. Fase 4 - Prototipo minimo divertido

**El modulo coordinador es M137, pero solo se implementa despues de sus dependencias.**

Orden de integracion:

1. `M14 Inventario` minimo.
2. `M15 Recursos` con un recurso recolectable.
3. `M19 NPC` con una entidad simple.
4. `M21 Dialogos` con una conversacion minima.
5. `M24 Templos y Puzzles` con un puzzle elemental.
6. `M25 Ruinas` con una ruina pequena.
7. `M59 Guardado` con un save/load del estado minimo.
8. `M137 Prototipo` como integrador y gate GO/NO-GO.

Checklist de la fase:

- [ ] Recoger un recurso y verlo en inventario.
- [ ] Guardar y cargar la posicion del jugador.
- [ ] Hablar con un NPC.
- [ ] Resolver una interaccion de puzzle.
- [ ] Explorar una zona pequena con objetivo comprensible.
- [ ] Capturar una sesion completa con MCP.
- [ ] Ejecutar playtest de M114.
- [ ] Medir si el bucle invita a repetir la accion.
- [ ] Validar que la experiencia respeta M152/M153.
- [ ] Registrar decision GO/NO-GO.

**Puerta F4:** el prototipo es jugable y evaluable. Si falla, se corrigen fundamentos; no se agregan islas, tiendas ni decenas de assets.

---

## 9. Fase 5 - Base de produccion

Solo se habilita despues de F4.

- [ ] M16 Crafting consume datos reales de M14/M15.
- [ ] M17 Construccion consume M08 y M14.
- [ ] M18 Casas usa las reglas de construccion.
- [ ] M20 Amistad consume eventos de M19.
- [ ] M22 Historia consume M21 y M28 solo mediante contratos.
- [x] M29 Tiempo y Calendario se implementa como servicio puro.
- [ ] M31 Dia/Noche consume M29 y alimenta M49.
- [ ] M32 Clima consume seed y dia, sin bloquear progreso.
- [ ] M38 Economia consume recursos, crafting y amistad.
- [ ] M40 Infraestructura registra los servicios reales.
- [ ] M61 Rendimiento define presupuestos antes de escalar contenido.
- [ ] M63 Streaming se implementa despues de medir M08/M10.

**Puerta F5:** los sistemas persistentes tienen contratos, eventos, pruebas y presupuestos; ningun agente agrega contenido sobre APIs inestables.

---

## 10. Fase 6 - Vertical slice visual

Esta es la fase donde la vision se usa de forma intensiva y repetible.

- [ ] Crear una zona pequena de Aurora con identidad visual.
- [ ] Crear un NPC con silueta, material y animacion legibles.
- [ ] Crear una ruina y un puzzle con lectura visual inmediata.
- [ ] Integrar iluminacion, particulas, audio y UI minima.
- [ ] Capturar antes y despues de cada ajuste visual.
- [ ] Revisar capturas con M154: capturar -> analizar -> ajustar.
- [ ] Limitar a cinco iteraciones autonomas por bloque visual.
- [ ] Ejecutar playtest real con M114.
- [ ] Corregir primero jerarquia, legibilidad, escala y rendimiento.
- [ ] Marcar M138 solo cuando la experiencia sea recorrible de inicio a fin.

**Puerta F6:** vertical slice aprobado tecnica y visualmente. A partir de aqui se puede delegar contenido en paralelo.

---

## 11. Fase 7 - Delegacion paralela de contenido

Cuando F6 esta abierta, los agentes pueden reservar modulos en paralelo, siempre que cada uno cumpla dependencias y no comparta archivos de runtime sin contrato.

- [ ] Reservar M23/M27/M28 para narrativa, islas y viajes.
- [ ] Reservar M33-M37 para actividades y vida del mundo.
- [ ] Reservar M39/M54-M56 para tiendas, mapa, diario y fotografia.
- [ ] Reservar M64/M65 para IA de NPC y animales.
- [ ] Reservar M66/M67-M75 para anti-softlock, transporte, coleccionables y postgame.
- [ ] Mantener una semilla y un entorno de prueba comunes.
- [ ] Exigir fixtures y escenas de prueba por cada sistema nuevo.
- [ ] Exigir captura visual cuando el modulo cambie pixels del juego.
- [ ] No permitir que un agente cambie contratos base sin actualizar el modulo dueño.

---

## 12. Fase 8 - Arte, accesibilidad y calidad

- [ ] M45 define el kit visual antes de producir grandes lotes.
- [ ] M47 fija materiales y atlas antes de decorar todas las islas.
- [ ] M48 fija el contrato de animacion antes de crear NPCs masivos.
- [ ] M49 fija presets de iluminacion y limites de luces.
- [ ] M50 produce vegetacion con LOD y pooling.
- [ ] M51 integra agua despues de estabilizar chunks y rendimiento.
- [ ] M52 integra VFX con presupuesto por escena.
- [ ] M53/M57/M58 validan UI, controles y accesibilidad junto a capturas.
- [ ] M87-M91 validan localizacion, tipografias, grafica y audio.
- [ ] M101-M113 ejecutan QA, bugs, logging, testing y stress.
- [ ] M115 valida hardware y perfiles reales.
- [ ] M122 valida crash reporting sin filtrar datos sensibles.

**Puerta F8:** el juego conserva legibilidad y rendimiento al agregar contenido, no solo belleza en una escena aislada.

---

## 13. Fase 9 - Release y operacion

- [ ] Congelar features segun M142.
- [ ] Validar licencias y modelos 3D con M83-M85.
- [ ] Validar legal, privacidad y clasificacion con M78-M82.
- [ ] Preparar builds y firmas con M116-M119.
- [ ] Preparar store, trailer y comunidad con M97-M100.
- [ ] Verificar actualizaciones, backups y compatibilidad de saves.
- [ ] Ejecutar smoke test de instalacion limpia.
- [ ] Ejecutar regresion visual y funcional.
- [ ] Obtener aprobacion de M151 antes de lanzamiento.
- [ ] Reservar M144 y M145 solo despues del release candidate.

---

## 14. Procedimiento de reserva para todos los agentes

Antes de reservar:

- [ ] Leer esta guia completa o la fase aplicable.
- [ ] Leer `CHECKLIST-GLOBAL.md`.
- [ ] Leer `ESTADO-PARALELO.md`.
- [ ] Revisar dependencias del modulo.
- [ ] Revisar si el modulo toca vision, Godot o archivos compartidos.
- [ ] Comprobar que el modulo esta habilitado por la puerta actual.
- [ ] Confirmar en el registro de reservas de la seccion 17 que el modulo no este `🔵` o `🔴`.

Al reservar:

- [ ] Cambiar el estado global a `🔵 En curso`.
- [ ] Escribir el agente y timestamp.
- [ ] Cambiar el estado del modulo a `🔵 En curso` en la seccion 17 de esta guia.
- [ ] Agregar el bloque `Reserva actual` al inicio del `05-Checklist.md` del modulo.
- [ ] Escribir en notas: `Fase X, entrada Y, salida Z`.
- [ ] Registrar la reserva en `ESTADO-PARALELO.md`.
- [ ] Declarar archivos que se van a modificar.
- [ ] Declarar la herramienta de validacion que se usara.

Al finalizar o liberar:

- [ ] Ejecutar tests y validacion visual si corresponde.
- [ ] Actualizar el `05-Checklist.md` del modulo.
- [ ] Actualizar la fila de `CHECKLIST-GLOBAL.md`.
- [ ] Actualizar el estado del modulo en la seccion 17 de esta guia.
- [ ] Cerrar o reemplazar el bloque `Reserva actual` del `05-Checklist.md`.
- [ ] Agregar notas honestas al `04-Codigo.md`.
- [ ] Crear log numerado.
- [ ] Liberar el estado `🔵`/`🔴` a `🟢`, `🟡` o `✅`.
- [ ] No marcar `✅` si queda algun `[?]`.
- [ ] Solicitar QA cruzado cuando corresponda.

Formato recomendado para una reserva:

```text
RESERVA: M08 - Mundo Voxel
AGENTE: [modelo / plataforma]
FASE: 2 - Mundo minimo
ENTRADA: F1 aprobada; M07 disponible
SALIDA: chunk 16^3 editable, determinista y medido
ARCHIVOS: [lista]
VALIDACION: Godot MCP + captura screen + test headless
FECHA: YYYY-MM-DD HH:MM:SS
```

---

## 15. Regla para agentes de investigacion

Un agente puede investigar cualquier modulo futuro si no modifica runtime ni pisa el trabajo de otro agente.

- [ ] Marcar la tarea como `INVESTIGACION PREVIA`.
- [ ] No cambiar el modulo a `🔵 En curso` salvo que vaya a implementar.
- [ ] Entregar decisiones, riesgos, APIs y dependencias.
- [ ] No inventar que una integracion esta hecha.
- [ ] Devolver el modulo a estado disponible al terminar.
- [ ] Agregar hallazgos al `plan-actual/02-Analisis.md` o al documento dueño.

Esto permite investigar M45, M64 o M97 con anticipacion sin desordenar el orden de codificacion.

---

## 16. Estado inicial recomendado - 2026-08-26

- [x] MCP de GitHub Copilot verificado con `screen` y `godot`.
- [x] M13 tiene nucleo y preview visual implementados.
- [x] Completar la puerta F1 de M04/M07 sobre el proyecto runtime actual.
- [ ] Integrar M08 con el mundo voxel real.
- [x] Integrar M11 y M12 con la escena jugable.
- [ ] Cerrar F3 con M13 conectado a bloques reales.
- [ ] Continuar hacia M14/M15/M59 y luego M137.
- [ ] Delegar contenido masivo solo despues de F4 o de una excepcion documentada.

**Regla final:** si hay duda sobre que modulo tomar, no se elige por numero ni por facilidad. Se elige el primer modulo pendiente de la primera fase cuya puerta y dependencias esten satisfechas.

---

## 17. Registro de reservas de la ruta critica

Esta tabla indica rapidamente que modulo esta disponible, bloqueado o reservado. `CHECKLIST-GLOBAL.md` continua siendo la fuente detallada de progreso; esta tabla es la vista de coordinacion del orden.

| Orden | Modulo | Dificultad | Vision | Estado | Agente | Entrada | Salida | Ultima actividad |
|---:|---|:---:|:---:|---|---|---|---|---|
| 1 | M04 Game Engine | 5 | V1 | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | Fase 0 completa | Proyecto Godot ejecutable, Godot 4.7.2, sin errores de motor | 2026-08-26 |
| 2 | M05 Lenguaje y Programacion | 3 | V0 | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | Contrato de M04 | Convenciones GDScript aplicadas, tipado estatico | 2026-08-26 |
| 3 | M07 Arquitectura General | 5 | V0 | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | M04/M05 | EventBus(9 dominios) + ServiceRegistry + Bootstrap + test 6/6 PASS | 2026-08-26 |
| 4 | M08 Mundo Voxel | 5 | V2 | ✅ Completado | MiMo V2.5 (OpenCode) | F1 aprobada | VoxelBoxMover + terreno OK + edicion E/Q OK | 2026-08-26 |
| 5 | M10 Generacion del Mundo | 5 | V1 | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | M08 | world_generator.gd + IslandGenerator + semilla 42 + 21 bloques con colores | 2026-08-26 |
| 6 | M09 Terreno y Geografia | 4 | V2 | ✅ COMPLETADO | MiMo V2.5 (OpenCode) | M08/M10 | Isla Aurora: forma definida, playa visible, biomas (beach/grass/forest/mountain/snow), spawn en playa | 2026-08-26 |
| 7 | M11 Personaje del Jugador | 4 | V2 | ✅ Completado | MiMo V2.5 (OpenCode) | F2 | CharacterBody3D + WASD + gravedad + colision suelo + pivot camara + edicion E/Q + movimiento relativo a camara | 2026-08-26 |
| 8 | M12 Camara | 2 | V2 | ✅ Completado | MiMo V2.5 (OpenCode) | M11 | CameraFollowing: rotacion mouse + zoom scroll + colision terreno + GameSettings (sensibilidad + invert Y) | 2026-08-26 |
| 9 | M13 Herramientas | 4 | V2 | 🔵 En curso | MiMo V2.5 (OpenCode) | M08+M11 | Raycast + extracción + colocación voxel integrada | 2026-08-27 |
| 10 | M14 Inventario | 3 | V1 | 🔵 Reservado - nucleo de datos (excepcion doc.: M11 pendiente, sin dependencia de jugador; pickup post-M11) | ox-alpha (Cline) | F3 parcial / hallazgos H1-H8 (log 168) | Autoload Inventario + ISaveProvider | 2026-08-26 |
| 11 | M15 Recursos | 3 | V1 | 🟢 Bloqueado por M14 | — | M14 | Recurso recolectable | — |
| 12 | M59 Guardado | 5 | V0 | 🟢 Bloqueado por M07/M14 | — | Estado minimo | Save/load validado | — |
| 13 | M137 Prototipo | 5 | V2 | 🟢 Bloqueado por dependencias | — | F3 + M14/M15/M59 | GO/NO-GO | — |
| 14 | M61 Rendimiento | 5 | V0 | 🟢 Investigable desde M08 | — | M08 | Presupuesto medido | — |
| 15 | M138 Vertical Slice | 5 | V2 | 🟢 Bloqueado por M137 | — | F4 | Slice aprobado | — |

### Bloque `Reserva actual` obligatorio en cada checklist de módulo

Al reservar un módulo, el agente debe agregar este bloque al inicio de `DOCUMENTACION/{ID}-Modulo/plan-actual/05-Checklist.md` y cambiar su estado a `🔵 En curso`:

```markdown
## Reserva actual

- Estado: 🔵 En curso
- Agente: [modelo / plataforma]
- Fase: [Fase X]
- Dificultad: [1-5]
- Vision: [V0 / V1 / V2]
- Entrada: [puerta o dependencia cumplida]
- Salida: [resultado verificable]
- Archivos: [rutas previstas]
- Fecha: YYYY-MM-DD HH:MM:SS
```

Al liberar el módulo, el agente actualiza simultáneamente este bloque, la fila de esta sección, `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md`. Debe conservar el historial en las notas del agente y nunca marcar `✅` si quedan dudas `[?]`.
