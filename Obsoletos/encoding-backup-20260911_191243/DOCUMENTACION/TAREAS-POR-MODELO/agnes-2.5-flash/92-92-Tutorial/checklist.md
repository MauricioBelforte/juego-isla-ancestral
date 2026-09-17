# Tareas módulo 92 92-Tutorial

**Estado:** ðŸŸ¡ Con dudas

**Items pendientes:** 143

[ ] T-92-001: Descartar la pared de texto como solución: rompe la fantasía cozy
[ ] T-92-002: Registrar dependencias del módulo: M53 (UI-UX), M70 (Interacciones)
[ ] T-92-003: Registrar módulos enseñados: M11, M13, M33, M34, M35, M16, M19/M21
[ ] T-92-004: Definir el objetivo: aprendizaje por inmersión en 15-20 minutos, sin frustración
[ ] T-92-005: Definir alcance: capítulos, triggers, pistas contextuales, prólogo guiado, consejos, skip/re-play
[ ] T-92-006: Definir fuera de alcance: diálogos (M21), misiones (M22), mecánicas enseñadas (M13/M33...)
[ ] T-92-007: Establecer restricción de longitud: pistas ≤ 2 líneas, máx. 3 pasos visibles por guion
[ ] T-92-008: Establecer restricción de rendimiento: presupuesto ≤ 0.2 ms por frame
[ ] T-92-009: Documentar la persistencia mínima de GameState.M92 (< 1 KB)
[ ] T-92-010: RF2: trigger por acción del jugador (primer paso, primera tecla E, primer equipar)
[ ] T-92-011: RF2: los triggers se registran y desregistran según los mundos activos (M63 streaming)
[ ] T-92-012: RF19: la revalidación registra log de M103 para trazabilidad
[ ] T-92-013: RF2: nunca disparar lecciones sobre NPCs dormidos u ocupados (estado M19 `set_ocupado`)
[ ] T-92-014: RF20: re-programación del trigger hasta 3 intentos antes del descarte seguro
[ ] T-92-015: RF5: prólogo guiado suave (Llegada + Moverse) con marcador de objetivo en HUD
[ ] T-92-016: RF11: capítulo Moverse: guía de WASD/joystick con celebración de llegada al punto
[ ] T-92-017: RF11: la pista de movimiento desaparece al detectar input de dirección
[ ] T-92-018: RF12: capítulo Interactuar: explica la tecla E con ícono dinámico del InputMap
[ ] T-92-019: RF14: capítulo Cultivo: azada → semilla → regar → esperar → cosechar con E, paso a paso
[ ] T-92-020: RF15: capítulo Pesca: equipar caña → lanzar → mini-juego → recoger pez, por fases
[ ] T-92-021: RF16: capítulo Minería: equipar pico → romper veta → recoger mineral, con aviso de energía
[ ] T-92-022: RF17: capítulo Crafting: abrir banco → mostrar receta requerida → fabricar → verificar inventario
[ ] T-92-023: RF18: capítulo Vecinos: saludar con E → elegir opción de diálogo → recibir primer regalo
[ ] T-92-024: RF13: capítulo Herramientas: equipar y usar la primera herramienta con pista de energía
[ ] T-92-025: RF24: cada capítulo completo emite feedback breve (sonido de éxito M44 + mensaje 2 s)
[ ] T-92-026: RF24: el feedback de éxito nunca es modal obligatorio (se puede ignorar)
[ ] T-92-027: RF5: los pasos SECUENCIA aceptan avanzar solo al cumplir la meta, sin bloquear otras acciones
[ ] T-92-028: RF4: burbuja world-space anclada al objetivo de la lección con texto ≤ 2 líneas
[ ] T-92-029: RF4: la burbuja incluye ícono de tecla dinámico (InputMap) según dispositivo activo
[ ] T-92-030: RF4: flecha opcional apuntando al objetivo cuando está fuera de pantalla
[ ] T-92-031: RF4: la burbuja se oculta con fade al expirar, al alejarse (> 6 m) o al cumplir la acción
[ ] T-92-032: RF4: la burbuja se oculta sin parpadear al abrir menús/diálogos y reaparece si el contexto sigue
[ ] T-92-033: RF4: máx. 2 pistas vivas simultáneas en todo momento
[ ] T-92-034: RF9: el interruptor "Pistas contextuales" (on/off) apaga todas las burbujas
[ ] T-92-035: RF9: el interruptor de pistas no afecta la secuencia guiada del prólogo (interruptor separado)
[ ] T-92-036: RF6: los consejos se muestran una sola vez (registro en `consejos_vistos`)
[ ] T-92-037: RF6: contextos permitidos de consejo: carga de escena, caminata larga, pausa
[ ] T-92-038: RF6: cooldown mínimo de 90 s entre consejos
[ ] T-92-039: RF6: los consejos nunca aparecen durante diálogos (M21) ni cutscenes
[ ] T-92-040: RF6: interruptor independiente "Consejos" (on/off) en opciones de juego
[ ] T-92-041: RF7: skip por capítulo: libera el guion actual sin marcarlo como completado
[ ] T-92-042: RF7: al saltear, las pistas activas se ocultan de inmediato y sin parpadeo
[ ] T-92-043: RF8: re-play de capítulos sueltos (ej: volver a ver el de pesca)
[ ] T-92-044: RF8: confirmación obligatoria antes de re-jugar (M53)
[ ] T-92-045: RF8: snapshot del estado previo para no contaminar la partida en curso (RN11)
[ ] T-92-046: RF8: el re-play usa estado_replay sin revalidación (muestra todos los pasos)
[ ] T-92-047: RF3: jugador que ya pescó antes del capítulo: capítulo marcado completo sin mostrar pasos
[ ] T-92-048: RF3: jugador que ya crafteó antes del capítulo: misma revalidación silenciosa
[ ] T-92-049: RF10: nunca interrumpir interacciones de M70, diálogos de M21 ni animaciones en curso
[ ] T-92-050: RF25: el estado DORMIDO se activa con la señal de modal de M53 y se restaura al cerrar
[ ] T-92-051: RN1: tono amable sin urgencia ("cuando quieras"), sin castigo por ignorar pistas
[ ] T-92-052: RN2: el tiempo con pistas activas no supera el 10% de la sesión
[ ] T-92-053: RN4: presupuesto ≤ 0.2 ms/frame para la lógica del 92
[ ] T-92-054: RN6: persistencia mínima en GameState.M92 (< 1 KB por guardado)
[ ] T-92-055: RN7: 100% de textos con claves `tr()` (soporte inicial ES/EN)
[ ] T-92-056: RN8: determinismo: mismo input + mismo mundo = mismo disparo de lecciones
[ ] T-92-057: RN9: testabilidad: triggers y guiones instanciables sin escena real (mocks)
[ ] T-92-058: RN10: un capítulo roto nunca bloquea la partida (watchdog + descarte)
[ ] T-92-059: RN12: duración de pistas escalable x1/x2/x4 y tamaño/contraste desde preferencias de M58
[ ] T-92-060: G3: 3 tipos de trigger (señal, mundo, acción) derivados de la clase base Trigger [M]- [x] G4: pool de pistas world-space con reutilización de nodos (m
[ ] T-92-061: G8: diagrama de estados del presentador (M53) con transiciones sin parpadeo
[ ] T-92-062: H1: el 92 entrega datos de pistas y M53 dibuja la burbuja final
[ ] T-92-063: H3: re-play desde el menú de opciones con confirmación
[ ] T-92-064: H4: localización: todas las claves `tr()` siguen el flujo de traducción de M53
[ ] T-92-065: H5: el mensaje "capítulo completado" respeta las normas de HUD de M53
[ ] T-92-066: H7: el marcador de objetivo del prólogo usa componentes de M53 sin duplicación
[ ] T-92-067: H8: los .tscn de la carpeta ui/ del 92 son de depuración, no la UI final
[ ] T-92-068: I1: el capítulo Interactuar se dispara en el primer interactuable (tótem de bienvenida)
[ ] T-92-069: I2: la pista de tecla E se alinea al prompt del 70 (sin iconos duplicados en pantalla)
[ ] T-92-070: I3: se consume la señal `interaccion_terminada` para validar el paso
[ ] T-92-071: I5: la burbuja del 92 se oculta cuando el prompt del 70 está en INTERACTUANDO
[ ] T-92-072: I6: capítulo Interactuar también enseña el prompt atenuado (no disponible con razón)
[ ] T-92-073: I7: el 92 usa la localización de nombres del 70 (obtener_nombre_prompt) si aplica
[ ] T-92-074: I8: sin acoplamiento: el 92 escucha señales del 70, nunca lo modifica
[ ] T-92-075: J1: capítulo Herramientas: equipar la primera herramienta con pista contextual
[ ] T-92-076: J2: la pista explica brevemente la acción de la herramienta y la energía consumida
[ ] T-92-077: J3: se consume la señal de herramienta equipada para validar el paso
[ ] T-92-078: J5: el capítulo de herramientas reutiliza los íconos de teclas del InputMap de M57
[ ] T-92-079: J6: revalidación por maestría: si el jugador ya usó herramienta antes, se salta
[ ] T-92-080: K2: pasos: usar azada → plantar semilla → regar → esperar (consejo de tiempo real) → cosechar con E
[ ] T-92-081: K3: se consumen las señales de cultivo (plantado, regado, cosechado) para avanzar pasos
[ ] T-92-082: K4: la pista de "esperar a mañana" no obliga el envejecimiento de día (consejo contextual)
[ ] T-92-083: K5: si el jugador destruye la parcela, reprogramar o descartar vía watchdog (RF23)
[ ] T-92-084: K6: revalidación: jugador que ya cosechó antes del capítulo lo completa en silencio
[ ] T-92-085: L1: capítulo Pesca en el primer muelle con caña de madera
[ ] T-92-086: L2: pistas por fase: equipar caña, lanzar, mini-juego de retención, recoger pez
[ ] T-92-087: L3: después de un fallo en el mini-juego, la pista se re-muestra amable (sin castigo)
[ ] T-92-088: L4: se consume la señal `pez_capturado` para completar el paso final
[ ] T-92-089: L5: revalidación por maestría de pesca (jugador pescó antes)
[ ] T-92-090: L6: el consejo de "pescar de mañana tiene mejores peces" se registra como consejo visto
[ ] T-92-091: M1: capítulo Minería en la primera veta con pico de madera
[ ] T-92-092: M2: pistas: equipar pico, romper veta, recoger mineral, aviso de energía
[ ] T-92-093: M3: se consume la señal `veta_rota` para validar el paso
[ ] T-92-094: M4: si la veta es inalcanzable (pico insuficiente), el capítulo espera la veta correcta o se re-programa
[ ] T-92-095: M5: revalidación por maestría de minería
[ ] T-92-096: M6: el consejo de "sondear con el pico revela minerales" se registra como visto
[ ] T-92-097: N1: capítulo Crafting en el primer banco de trabajo
[ ] T-92-098: N2: la pista marca la receta requerida por la historia (ítem único)
[ ] T-92-099: N3: pasos: abrir banco → seleccionar receta → fabricar → verificar en inventario (M14)
[ ] T-92-100: N4: se consume la señal `item_crafteado` para completar el capítulo
[ ] T-92-101: N5: si el jugador no tiene los materiales, la pista indica dónde conseguirlos (sin misión)
[ ] T-92-102: N6: revalidación por maestría de crafting
[ ] T-92-103: O1: capítulo Vecinos en la plaza: saludar con E al primer vecino
[ ] T-92-104: O2: la pista explica la opción de diálogo (elegir línea con E)
[ ] T-92-105: O3: se consume `dialogo_iniciado`/`dialogo_terminado` para validar el paso
[ ] T-92-106: O4: respetar `set_ocupado` de M19 (no enseñar sobre un vecino dormido)
[ ] T-92-107: O5: la lección termina con la entrega del primer regalo (sin misión formal de M22)
[ ] T-92-108: O6: revalidación: jugador que ya habló con un vecino antes del capítulo
[ ] T-92-109: P1: jugador que ya completó el juego en otra partida: revalidación evita pasos redundantes
[ ] T-92-110: P2: jugador hace otra cosa durante una pista: la pista expira sin castigo y el capítulo queda pendiente
[ ] T-92-111: P4: reinicio del juego con guardado a mitad de capítulo: el capítulo se retoma desde el paso pendiente
[ ] T-92-112: P5: el objeto de la lección fue destruido (árbol talado, parcela removida): re-programar o descartar
[ ] T-92-113: P6: el nodo objetivo está fuera del mundo activo (M63): trigger se pausa hasta su alta
[ ] T-92-114: P7: se abre un modal justo con pista activa: DORMIDO y reaparición sin parpadeo al cerrar
[ ] T-92-115: P8: el jugador remapea la tecla E a otra tecla: la pista muestra el ícono nuevo desde InputMap
[ ] T-92-116: P9: cambio de dispositivo mid-pista (teclado→gamepad): el ícono de tecla se actualiza en vivo
[ ] T-92-117: P11: re-play mientras un capítulo está activo: conflicto resuelto con snapshot y cancelación suave
[ ] T-92-118: P12: jugador con lectura lenta (M58 x4): las pistas permanecen sin bloquear acciones
[ ] T-92-119: P13: dos pistas simultáneas en la misma zona: la de mayor prioridad se queda, la otra se pospone
[ ] T-92-120: P14: el jugador usa el fast-travel (M69) con una pista activa: la pista se descarta limpiamente
[ ] T-92-121: P15: el jugador cierra el juego en el instante del feedback de capítulo: el estado ya está persistido (orden write antes del feedback)
[ ] T-92-122: Q1: pool de burbujas con máx. 2 nodos UI vivos (reutilización, sin instanciado por pista)
[ ] T-92-123: Q2: la lógica de triggers se evalúa solo ante señales o entrada, nunca por polling innecesario
[ ] T-92-124: Q3: el trigger de mundo usa distancia al cuadrado (sin sqrt)
[ ] T-92-125: Q5: los guiones serializados en Resources (sin parseo en runtime)
[ ] T-92-126: Q6: el consejo de contexto "caminata larga" usa un contador de tiempo sin física extra
[ ] T-92-127: Q7: no hay alocaciones por frame en la ruta crítica (buffers reutilizados)
[ ] T-92-128: Q8: profiler: verificar ≤ 0.2 ms en la zona de la plaza con NPCs y cultivos
[ ] T-92-129: R1: 01-Requerimientos.md con RF1-RF25 y RN1-RN12
[ ] T-92-130: R3: 03-Diseno.md con arquitectura, flujos y estados
[ ] T-92-131: R5: 05-Checklist.md con ítems numerables y marcadores de esfuerzo
[ ] T-92-132: R6: plan-actual creado como espejo idéntico de plan-inicial
[ ] T-92-133: S2: test de triggers de señal con mocks de M70/M33/M34/M35
[ ] T-92-134: S3: test de trigger de mundo con distancias límites (radio exacto ±0.01 m)
[ ] T-92-135: S4: test de revalidación: señal de maestría previa completa el capítulo en silencio
[ ] T-92-136: S5: test de skip global y por capítulo (estado persistido correctamente)
[ ] T-92-137: S6: test de re-play con snapshot (la partida no se contamina)
[ ] T-92-138: S7: test del watchdog: meta imposible → re-programación ×3 → descarte sin bloqueo
[ ] T-92-139: S8: test de pistas: máx. 2 vivas, pool reutilizado, fade y expiración
[ ] T-92-140: S9: test de consejos: una sola vez, cooldown 90 s, contextos restringidos
[ ] T-92-141: S10: test de integración End-to-End: partida nueva → prólogo → capítulo cultivo completo con mocks
[ ] T-92-142: S11: test de rendimiento: medición < 0.2 ms en escenario denso (zona de plaza)
[ ] T-92-143: S12: test de regresión con InputMap remapeado (íconos dinámicos correctos)
