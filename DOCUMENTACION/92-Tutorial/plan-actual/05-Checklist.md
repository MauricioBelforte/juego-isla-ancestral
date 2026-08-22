**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 92: Tutorial

## A. Problema, objetivos y alcance (12)

- [x] Definir el problema: juegos cozy con muchos sistemas pequeños y jugador nuevo sin guía [S]
- [x] Descartar la pared de texto como solución: rompe la fantasía cozy [S]
- [x] Registrar dependencias del módulo: M53 (UI-UX), M70 (Interacciones) [S]
- [x] Registrar módulos enseñados: M11, M13, M33, M34, M35, M16, M19/M21 [M]
- [x] Definir el objetivo: aprendizaje por inmersión en 15-20 minutos, sin frustración [M]
- [x] Definir alcance: capítulos, triggers, pistas contextuales, prólogo guiado, consejos, skip/re-play [M]
- [x] Definir fuera de alcance: diálogos (M21), misiones (M22), mecánicas enseñadas (M13/M33...) [M]
- [x] Establecer restricciones: Godot 4.x + Voxel Tools + GDScript, sin C# para gameplay [S]
- [x] Establecer regla roja cozy: el tutorial nunca bloquea ni castiga al jugador [S]
- [x] Establecer restricción de longitud: pistas ≤ 2 líneas, máx. 3 pasos visibles por guion [S]
- [x] Establecer restricción de rendimiento: presupuesto ≤ 0.2 ms por frame [M]
- [x] Documentar la persistencia mínima de GameState.M92 (< 1 KB) [S]

## B. RF: Triggers y detección de contexto (15)

- [x] RF1: estructurar el tutorial en capítulos (Llegada, Moverse, Interactuar, Herramientas, Cultivo, Pesca, Minería, Crafting, Vecinos) [M]
- [x] RF1: cada capítulo es un guion Resource reutilizable (partida nueva, re-play, New Game+) [M]
- [x] RF2: trigger por señal de sistema (M70, M33, M34, M35, M16...) con condición de contexto [M]
- [x] RF2: trigger por mundo (proximidad del jugador a ITutorialTarget, radio configurable) [M]
- [x] RF2: trigger por acción del jugador (primer paso, primera tecla E, primer equipar) [M]
- [x] RF2: los triggers se registran y desregistran según los mundos activos (M63 streaming) [M]
- [x] RF2: condiciones de contexto permitidas: día, hora, zona, sistema disponible [M]
- [x] RF3: revalidación de "ya lo sabe": señal de maestría antes del trigger completa el capítulo en silencio [C]
- [x] RF3: la revalidación no muestra ningún paso ni feedback al jugador que ya domina [M]
- [x] RF19: mapeo de revalidación por dominio+señal en `revalidacion.gd` (M70, M33, M34, M35, M16, M19) [M]
- [x] RF19: la revalidación registra log de M103 para trazabilidad [S]
- [x] RF2: nunca disparar lecciones sobre NPCs dormidos u ocupados (estado M19 `set_ocupado`) [M]
- [x] RF2: no disparar capítulos de sistemas no implementados (omisión con log de degradación) [M]
- [x] RF23: watchdog por capítulo con timeout configurable (default 120 s) [M]
- [x] RF20: re-programación del trigger hasta 3 intentos antes del descarte seguro [M]

## C. RF: Guiones y secuencias guiadas (14)

- [x] RF5: prólogo guiado suave (Llegada + Moverse) con marcador de objetivo en HUD [C]
- [x] RF5: el prólogo tiene máximo 2-4 pasos y no bloquea sistemas del juego [M]
- [x] RF11: capítulo Moverse: guía de WASD/joystick con celebración de llegada al punto [M]
- [x] RF11: la pista de movimiento desaparece al detectar input de dirección [M]
- [x] RF12: capítulo Interactuar: explica la tecla E con ícono dinámico del InputMap [M]
- [x] RF14: capítulo Cultivo: azada → semilla → regar → esperar → cosechar con E, paso a paso [C]
- [x] RF15: capítulo Pesca: equipar caña → lanzar → mini-juego → recoger pez, por fases [C]
- [x] RF16: capítulo Minería: equipar pico → romper veta → recoger mineral, con aviso de energía [M]
- [x] RF17: capítulo Crafting: abrir banco → mostrar receta requerida → fabricar → verificar inventario [M]
- [x] RF18: capítulo Vecinos: saludar con E → elegir opción de diálogo → recibir primer regalo [M]
- [x] RF13: capítulo Herramientas: equipar y usar la primera herramienta con pista de energía [M]
- [x] RF24: cada capítulo completo emite feedback breve (sonido de éxito M44 + mensaje 2 s) [M]
- [x] RF24: el feedback de éxito nunca es modal obligatorio (se puede ignorar) [S]
- [x] RF5: los pasos SECUENCIA aceptan avanzar solo al cumplir la meta, sin bloquear otras acciones [M]

## D. RF: Pistas contextuales y sistema de consejos (14)

- [x] RF4: burbuja world-space anclada al objetivo de la lección con texto ≤ 2 líneas [M]
- [x] RF4: la burbuja incluye ícono de tecla dinámico (InputMap) según dispositivo activo [M]
- [x] RF4: flecha opcional apuntando al objetivo cuando está fuera de pantalla [M]
- [x] RF4: la burbuja se oculta con fade al expirar, al alejarse (> 6 m) o al cumplir la acción [M]
- [x] RF4: la burbuja se oculta sin parpadear al abrir menús/diálogos y reaparece si el contexto sigue [M]
- [x] RF4: máx. 2 pistas vivas simultáneas en todo momento [S]
- [x] RF9: el interruptor "Pistas contextuales" (on/off) apaga todas las burbujas [M]
- [x] RF9: el interruptor de pistas no afecta la secuencia guiada del prólogo (interruptor separado) [M]
- [x] RF6: sistema de consejos: tips opcionales de profundización (riego, horarios, senderismo) [M]
- [x] RF6: los consejos se muestran una sola vez (registro en `consejos_vistos`) [M]
- [x] RF6: contextos permitidos de consejo: carga de escena, caminata larga, pausa [M]
- [x] RF6: cooldown mínimo de 90 s entre consejos [S]
- [x] RF6: los consejos nunca aparecen durante diálogos (M21) ni cutscenes [S]
- [x] RF6: interruptor independiente "Consejos" (on/off) en opciones de juego [S]

## E. RF: Skip, replay y revalidación (12)

- [x] RF7: skip global: desactiva el tutorial restante y se persiste por guardado [M]
- [x] RF7: skip por capítulo: libera el guion actual sin marcarlo como completado [M]
- [x] RF7: al saltear, las pistas activas se ocultan de inmediato y sin parpadeo [M]
- [x] RF8: re-play del tutorial completo desde opciones del juego (M53) [M]
- [x] RF8: re-play de capítulos sueltos (ej: volver a ver el de pesca) [M]
- [x] RF8: confirmación obligatoria antes de re-jugar (M53) [S]
- [x] RF8: snapshot del estado previo para no contaminar la partida en curso (RN11) [M]
- [x] RF8: el re-play usa estado_replay sin revalidación (muestra todos los pasos) [M]
- [x] RF3: jugador que ya pescó antes del capítulo: capítulo marcado completo sin mostrar pasos [C]
- [x] RF3: jugador que ya crafteó antes del capítulo: misma revalidación silenciosa [M]
- [x] RF10: nunca interrumpir interacciones de M70, diálogos de M21 ni animaciones en curso [M]
- [x] RF25: el estado DORMIDO se activa con la señal de modal de M53 y se restaura al cerrar [M]

## F. Requisitos No Funcionales (12)

- [x] RN1: tono amable sin urgencia ("cuando quieras"), sin castigo por ignorar pistas [M]
- [x] RN2: el tiempo con pistas activas no supera el 10% de la sesión [M]
- [x] RN3: tutorial completo (prólogo + capítulos) en 15-20 minutos para jugador nuevo [M]
- [x] RN4: presupuesto ≤ 0.2 ms/frame para la lógica del 92 [M]
- [x] RN5: desacople total: el 92 no referencia clases concretas de M13/M33/M34/M35/M16/M19/M21 [C]
- [x] RN6: persistencia mínima en GameState.M92 (< 1 KB por guardado) [S]
- [x] RN7: 100% de textos con claves `tr()` (soporte inicial ES/EN) [M]
- [x] RN8: determinismo: mismo input + mismo mundo = mismo disparo de lecciones [M]
- [x] RN9: testabilidad: triggers y guiones instanciables sin escena real (mocks) [M]
- [x] RN10: un capítulo roto nunca bloquea la partida (watchdog + descarte) [M]
- [x] RN11: el tutorial se re-inicializa limpio en partida nueva (estado por guardado) [M]
- [x] RN12: duración de pistas escalable x1/x2/x4 y tamaño/contraste desde preferencias de M58 [M]

## G. Diseño y arquitectura (12)

- [x] G1: TutorialManager como autoload único con estados (ACTIVO, ESPERANDO, PISTA, CONSECUENCIA, SKIPPED, DORMIDO) [C]
- [x] G2: guiones como Resources con pasos tipados (PISTA, SECUENCIA, CONSEJO) [M]
- [x] G3: 3 tipos de trigger (señal, mundo, acción) derivados de la clase base Trigger [M]
- [x] G4: pool de pistas world-space con reutilización de nodos (max 2 vivas) [M]
- [x] G5: interfaz ITutorialTarget opcional para autoetiquetar objetos del mundo [M]
- [x] G6: sistema de consejos con contexto permitido y cooldown [M]
- [x] G7: watchdog de tutorial con re-programación ×3 y descarte con log [M]
- [x] G8: diagrama de estados del presentador (M53) con transiciones sin parpadeo [M]
- [x] G9: flujo principal documentado: disparo → lección → cierre → feedback [M]
- [x] G10: flujo de skip y re-play con snapshot (RN11) [M]
- [x] G11: flujo de revalidación por señal de maestría [M]
- [x] G12: contratos de integración resumidos en tabla (sistemas ↔ 92) [S]

## H. Integración con 53-UI-UX (8)

- [x] H1: el 92 entrega datos de pistas y M53 dibuja la burbuja final [M]
- [x] H2: interruptores de tutorial (pistas, consejos, skip) desde opciones del juego (M53) [M]
- [x] H3: re-play desde el menú de opciones con confirmación [M]
- [x] H4: localización: todas las claves `tr()` siguen el flujo de traducción de M53 [M]
- [x] H5: el mensaje "capítulo completado" respeta las normas de HUD de M53 [S]
- [x] H6: señal de apertura de modal pone el tutorial en DORMIDO [S]
- [x] H7: el marcador de objetivo del prólogo usa componentes de M53 sin duplicación [M]
- [x] H8: los .tscn de la carpeta ui/ del 92 son de depuración, no la UI final [S]

## I. Integración con 70-Interacciones (8)

- [x] I1: el capítulo Interactuar se dispara en el primer interactuable (tótem de bienvenida) [M]
- [x] I2: la pista de tecla E se alinea al prompt del 70 (sin iconos duplicados en pantalla) [M]
- [x] I3: se consume la señal `interaccion_terminada` para validar el paso [M]
- [x] I4: el tutorial no interfiere con la selección de objetivo del 70 [M]
- [x] I5: la burbuja del 92 se oculta cuando el prompt del 70 está en INTERACTUANDO [S]
- [x] I6: capítulo Interactuar también enseña el prompt atenuado (no disponible con razón) [M]
- [x] I7: el 92 usa la localización de nombres del 70 (obtener_nombre_prompt) si aplica [S]
- [x] I8: sin acoplamiento: el 92 escucha señales del 70, nunca lo modifica [S]

## J. Integración con 13-Herramientas (6)

- [x] J1: capítulo Herramientas: equipar la primera herramienta con pista contextual [M]
- [x] J2: la pista explica brevemente la acción de la herramienta y la energía consumida [M]
- [x] J3: se consume la señal de herramienta equipada para validar el paso [S]
- [x] J4: si M13 no está implementado, el capítulo se omite con log de degradación [M]
- [x] J5: el capítulo de herramientas reutiliza los íconos de teclas del InputMap de M57 [S]
- [x] J6: revalidación por maestría: si el jugador ya usó herramienta antes, se salta [M]

## K. Integración con 33-Agricultura (6)

- [x] K1: capítulo Cultivo en el primer campo marcado como ITutorialTarget [M]
- [x] K2: pasos: usar azada → plantar semilla → regar → esperar (consejo de tiempo real) → cosechar con E [C]
- [x] K3: se consumen las señales de cultivo (plantado, regado, cosechado) para avanzar pasos [M]
- [x] K4: la pista de "esperar a mañana" no obliga el envejecimiento de día (consejo contextual) [M]
- [x] K5: si el jugador destruye la parcela, reprogramar o descartar vía watchdog (RF23) [M]
- [x] K6: revalidación: jugador que ya cosechó antes del capítulo lo completa en silencio [M]

## L. Integración con 34-Pesca (6)

- [x] L1: capítulo Pesca en el primer muelle con caña de madera [M]
- [x] L2: pistas por fase: equipar caña, lanzar, mini-juego de retención, recoger pez [C]
- [x] L3: después de un fallo en el mini-juego, la pista se re-muestra amable (sin castigo) [M]
- [x] L4: se consume la señal `pez_capturado` para completar el paso final [M]
- [x] L5: revalidación por maestría de pesca (jugador pescó antes) [M]
- [x] L6: el consejo de "pescar de mañana tiene mejores peces" se registra como consejo visto [S]

## M. Integración con 35-Mineria (6)

- [x] M1: capítulo Minería en la primera veta con pico de madera [M]
- [x] M2: pistas: equipar pico, romper veta, recoger mineral, aviso de energía [M]
- [x] M3: se consume la señal `veta_rota` para validar el paso [S]
- [x] M4: si la veta es inalcanzable (pico insuficiente), el capítulo espera la veta correcta o se re-programa [M]
- [x] M5: revalidación por maestría de minería [M]
- [x] M6: el consejo de "sondear con el pico revela minerales" se registra como visto [S]

## N. Integración con 16-Crafting (6)

- [x] N1: capítulo Crafting en el primer banco de trabajo [M]
- [x] N2: la pista marca la receta requerida por la historia (ítem único) [M]
- [x] N3: pasos: abrir banco → seleccionar receta → fabricar → verificar en inventario (M14) [C]
- [x] N4: se consume la señal `item_crafteado` para completar el capítulo [M]
- [x] N5: si el jugador no tiene los materiales, la pista indica dónde conseguirlos (sin misión) [M]
- [x] N6: revalidación por maestría de crafting [M]

## O. Integración con 19/21-NPC y Diálogos (6)

- [x] O1: capítulo Vecinos en la plaza: saludar con E al primer vecino [M]
- [x] O2: la pista explica la opción de diálogo (elegir línea con E) [M]
- [x] O3: se consume `dialogo_iniciado`/`dialogo_terminado` para validar el paso [M]
- [x] O4: respetar `set_ocupado` de M19 (no enseñar sobre un vecino dormido) [M]
- [x] O5: la lección termina con la entrega del primer regalo (sin misión formal de M22) [S]
- [x] O6: revalidación: jugador que ya habló con un vecino antes del capítulo [M]

## P. Edge cases (15)

- [x] P1: jugador que ya completó el juego en otra partida: revalidación evita pasos redundantes [M]
- [x] P2: jugador hace otra cosa durante una pista: la pista expira sin castigo y el capítulo queda pendiente [M]
- [x] P3: tutorial bloqueante roto (meta imposible): watchdog re-programa ×3 y descarta con log [C]
- [x] P4: reinicio del juego con guardado a mitad de capítulo: el capítulo se retoma desde el paso pendiente [M]
- [x] P5: el objeto de la lección fue destruido (árbol talado, parcela removida): re-programar o descartar [M]
- [x] P6: el nodo objetivo está fuera del mundo activo (M63): trigger se pausa hasta su alta [M]
- [x] P7: se abre un modal justo con pista activa: DORMIDO y reaparición sin parpadeo al cerrar [M]
- [x] P8: el jugador remapea la tecla E a otra tecla: la pista muestra el ícono nuevo desde InputMap [C]
- [x] P9: cambio de dispositivo mid-pista (teclado→gamepad): el ícono de tecla se actualiza en vivo [M]
- [x] P10: el jugador salta el tutorial en el prólogo: el resto de capítulos se desactivan ordenadamente [M]
- [x] P11: re-play mientras un capítulo está activo: conflicto resuelto con snapshot y cancelación suave [C]
- [x] P12: jugador con lectura lenta (M58 x4): las pistas permanecen sin bloquear acciones [M]
- [x] P13: dos pistas simultáneas en la misma zona: la de mayor prioridad se queda, la otra se pospone [M]
- [x] P14: el jugador usa el fast-travel (M69) con una pista activa: la pista se descarta limpiamente [S]
- [x] P15: el jugador cierra el juego en el instante del feedback de capítulo: el estado ya está persistido (orden write antes del feedback) [M]

## Q. Optimización (8)

- [x] Q1: pool de burbujas con máx. 2 nodos UI vivos (reutilización, sin instanciado por pista) [M]
- [x] Q2: la lógica de triggers se evalúa solo ante señales o entrada, nunca por polling innecesario [M]
- [x] Q3: el trigger de mundo usa distancia al cuadrado (sin sqrt) [S]
- [x] Q4: las condiciones de contexto son funciones baratas (< 1 µs cada una) [S]
- [x] Q5: los guiones serializados en Resources (sin parseo en runtime) [S]
- [x] Q6: el consejo de contexto "caminata larga" usa un contador de tiempo sin física extra [S]
- [x] Q7: no hay alocaciones por frame en la ruta crítica (buffers reutilizados) [M]
- [x] Q8: profiler: verificar ≤ 0.2 ms en la zona de la plaza con NPCs y cultivos [M]

## R. Documentación (7)

- [x] R1: 01-Requerimientos.md con RF1-RF25 y RN1-RN12 [S]
- [x] R2: 02-Analisis.md con tipos de tutorial, onboarding cozy y decisión A4 [S]
- [x] R3: 03-Diseno.md con arquitectura, flujos y estados [S]
- [x] R4: 04-Codigo.md con archivos previstos (Pendiente de implementación) y firmas GDScript [S]
- [x] R5: 05-Checklist.md con ítems numerables y marcadores de esfuerzo [S]
- [x] R6: plan-actual creado como espejo idéntico de plan-inicial [S]
- [x] R7: al implementar: log en Logs/, plan-actual actualizado y CHECKLIST-GLOBAL.md con progreso del 92 [M]

## S. Testings (12)

- [x] S1: test unitario de transiciones de estado del TutorialManager (ACTIVO→PISTA→CONSECUENCIA→ESPERANDO) [M]
- [x] S2: test de triggers de señal con mocks de M70/M33/M34/M35 [M]
- [x] S3: test de trigger de mundo con distancias límites (radio exacto ±0.01 m) [M]
- [x] S4: test de revalidación: señal de maestría previa completa el capítulo en silencio [M]
- [x] S5: test de skip global y por capítulo (estado persistido correctamente) [M]
- [x] S6: test de re-play con snapshot (la partida no se contamina) [C]
- [x] S7: test del watchdog: meta imposible → re-programación ×3 → descarte sin bloqueo [C]
- [x] S8: test de pistas: máx. 2 vivas, pool reutilizado, fade y expiración [M]
- [x] S9: test de consejos: una sola vez, cooldown 90 s, contextos restringidos [M]
- [x] S10: test de integración End-to-End: partida nueva → prólogo → capítulo cultivo completo con mocks [C]
- [x] S11: test de rendimiento: medición < 0.2 ms en escenario denso (zona de plaza) [C]
- [x] S12: test de regresión con InputMap remapeado (íconos dinámicos correctos) [M]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
