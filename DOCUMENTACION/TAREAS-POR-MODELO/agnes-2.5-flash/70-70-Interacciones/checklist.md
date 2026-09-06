# Tareas módulo 70 70-Interacciones

**Estado:** ðŸ”µ En curso

**Items pendientes:** 121

[ ] T-70-001: Registrar dependencias del módulo: M11, M13, M08
[ ] T-70-002: Registrar consumidores del módulo: M19, M21, M33, M35, M36, M65, M18, M14, M17, M22/M24/M26
[ ] T-70-003: Definir el objetivo: una única tecla de interacción con indicador visual y prioridad determinística
[ ] T-70-004: Definir fuera de alcance: mecánicas concretas de los consumidores, inventario, diálogos, IA
[ ] T-70-005: Establecer restricción cozy: tecla E sin objetivo nunca genera error ni castigo
[ ] T-70-006: Establecer restricción de rendimiento: presupuesto de detección < 0.5 ms por frame
[ ] T-70-007: RF1: desregistro automático al salir del mundo activo (`_exit_tree`, M63 streaming)
[ ] T-70-008: RF2: enumerar las 8 categorías de interacción con prioridad base
[ ] T-70-009: RF2: cada categoría define ícono, sonido y etiqueta por defecto
[ ] T-70-010: RF3: respetar el rango base del personaje de M11 (4 m) sin excederlo por defecto
[ ] T-70-011: RF4: filtro de candidatos por distancia (cálculo sin sqrt, al cuadrado)
[ ] T-70-012: RF4: validación de requisitos previos vía `requisitos_cumplidos(jugador)`
[ ] T-70-013: RF4: espaciado del raycast de visión (1 por ventana de N=4 frames)
[ ] T-70-014: RF19: re-evaluación de candidatos cada frame con costo O(n) con n < 40
[ ] T-70-015: RF5: seleccionar SIEMPRE un único objetivo, nunca varios
[ ] T-70-016: RF5: ordenar por prioridad de categoría (mapeo publicable en el catálogo)
[ ] T-70-017: RF5: desempate por distancia (menor gana) entre misma categoría
[ ] T-70-018: RF5: desempate por desviación angular frente del jugador (menor gana)
[ ] T-70-019: RF5: resolución final de empates por orden de registro (estable y determinístico)
[ ] T-70-020: RF5: selección 100% determinística para la misma entrada
[ ] T-70-021: RF6: histéresis anti-parpadeo: mantener objetivo si la ventaja del nuevo es <= 0.15 m
[ ] T-70-022: RF5: cambio de objetivo con fade (0.08-0.12 s), nunca salto brusco
[ ] T-70-023: RF5: excluir de la selección a los atenuados si hay al menos un objetivo válido
[ ] T-70-024: RF13: re-selección inmediata al girar el jugador si la desviación angular cambia el orden
[ ] T-70-025: RF6: expulsar el objetivo actual si sale de rango en el mismo frame
[ ] T-70-026: RF19: ordenamiento con k candidatos típico < 8 (k log k barato)
[ ] T-70-027: RF5: exponer el objetivo seleccionado a través de `obtener_objetivo_actual()`
[ ] T-70-028: RF6: indicador "E + ícono de categoría" world-space sobre el objetivo
[ ] T-70-029: RF6: el indicador flota sobre `obtener_posicion_interaccion()` con suavizado de posición
[ ] T-70-030: RF6: línea de contexto en HUD con nombre localizado del objetivo ("Hablar con Mira")
[ ] T-70-031: RF20: ícono de tecla según dispositivo activo (teclado E / gamepad A o B, M57)
[ ] T-70-032: RF6: línea de contexto oculta durante la micro-animación de interacción
[ ] T-70-033: RF8: el gestor no decide la mecánica: solo despacha por contrato
[ ] T-70-034: RF9: soporte de interacciones instantáneas y de larga duración (hold/activa)
[ ] T-70-035: RF4: presionar E con solo candidato atenuado emite feedback "no disponible" respetuoso
[ ] T-70-036: RF8: presionar E sin ningún candidato no produce error ni castigo (regla cozy)
[ ] T-70-037: RF9: el consumidor emite `interaccion_terminada(ok)` para liberar el gestor
[ ] T-70-038: RF15: chirrido de interacción por categoría (base de sonido M11/M44)
[ ] T-70-039: RF15: partículas opcionales provistas por el consumidor vía señal previa
[ ] T-70-040: RF15: feedback diferenciado de éxito (campana suave) y fallo (tono bajo, sin castigo)
[ ] T-70-041: RF17: validación de herramienta en mano (M13) dentro de `requisitos_cumplidos`
[ ] T-70-042: RF17: validación de item seleccionado en inventario (M14) para regalos
[ ] T-70-043: RF17: validación de hora/día (M29/M31) para puertas y cosechas de temporada
[ ] T-70-044: RF17: validación de nivel de amistad (M20) para interacciones sociales
[ ] T-70-045: RF25: pausa de procesamiento al pausar el juego (ProcessMode correcto)
[ ] T-70-046: RF25: gestión de la señal de modal abierto (M53/M57) -> estado DORMIDO
[ ] T-70-047: RF12: cancelación suave de la interacción en curso con `cancelar_interaccion()`
[ ] T-70-048: RF12: log M103 si el consumidor no responde a la cancelación
[ ] T-70-049: RF13: cambio de objetivo por reorden de prioridad sin parpadeo (histéresis)
[ ] T-70-050: RF14: cancelar selección al abrir menú, diálogo, inventario o pausa
[ ] T-70-051: RF14: re-evaluar automáticamente al cerrar la UI en el siguiente frame
[ ] T-70-052: RF23: cancelación de zona de trigger si el jugador sale antes de activar
[ ] T-70-053: RF12: verificar que no queden señales colgadas (objetivo_perdido) tras cancelar
[ ] T-70-054: RF15: feedback sonoro unificado por categoría (chirrido de madera/metal/animal)
[ ] T-70-055: RF15: feedback de éxito distinguible del de fallo
[ ] T-70-056: RF15: feedback de "no disponible" con tono respetuoso (nunca chirrido de error)
[ ] T-70-057: RF15: sin feedback intrusivo: nada de shake de cámara ni invasión (regla cozy)
[ ] T-70-058: RF15: las partículas del consumidor se reproducen vía señal, no las dibuja el gestor
[ ] T-70-059: RF15: sonido de "nadie cerca" mínimo y amable (opcional, bajo volumen)
[ ] T-70-060: RF15: textos de feedback 100% localizables con `tr()`
[ ] T-70-061: RN-cozy: la interacción nunca castiga al jugador
[ ] T-70-062: RN-cozy: la cancelación por distancia es suave, sin cortes bruscos
[ ] T-70-063: RN-rendimiento: filtrado por distancia al cuadrado sin sqrt
[ ] T-70-064: RN-rendimiento: raycast de visión espaciado (N=4) y acotado por categoría
[ ] T-70-065: RN-localización: todo texto visible pasa por `tr()`
[ ] T-70-066: RN-persistencia: `GameState.M70` con esquema acotado y escritura diferida
[ ] T-70-067: RN-voxel: línea de visión compatible con Voxel Tools (VoxelTool de M08)
[ ] T-70-068: RN-determinismo: selección idéntica para entrada idéntica (debug M110 y tests)
[ ] T-70-069: RN-testeabilidad: dependencias inyectables (jugador, voxel) para tests sin escena real
[ ] T-70-070: RN-seguridad: ningún error de contrato rompe el frame; degradación a NO_DISPONIBLE + log
[ ] T-70-071: Diseñar Resource CategoriaInteraccion (ícono, sonido, prioridad, etiqueta, visión)
[ ] T-70-072: Diseñar catálogo `categorias_interaccion.tres` con las 8 categorías
[ ] T-70-073: Diseñar flujo de detección/secuencia de 7 pasos por frame
[ ] T-70-074: Diseñar flujo de cancelación por distancia/UI/cambio de objetivo/desregistro
[ ] T-70-075: Diseñar flujo de persistencia con escritura diferida (0.5 s)
[ ] T-70-076: Diseñar las 6 señales de salida del módulo
[ ] T-70-077: M11: leer posición, frente y estado FSM del jugador (inyección)
[ ] T-70-078: M11: pasar a DORMIDO si el jugador está ocupado (dormir, cutscene, minijuego)
[ ] T-70-079: M11: respetar el rango base de interacción de 4 m del personaje
[ ] T-70-080: M08: integrar VoxelTool para la línea de visión (bloqueo por voxel sólido)
[ ] T-70-081: M13: validar requisitos de herramienta dentro de `requisitos_cumplidos`
[ ] T-70-082: M19: `set_ocupado(true)` -> NO_DISPONIBLE con razón ("Duerme", "Ocupado")
[ ] T-70-083: M19: migrar la burbuja world-space de vecinos al indicador del 70 (sin duplicados)
[ ] T-70-084: M21: apertura de diálogo al E sin UI propia en el 70
[ ] T-70-085: M20: regalo al E con item seleccionado de M14 y validación de amistad
[ ] T-70-086: M33: recoger cosechas maduras al E
[ ] T-70-087: M14: abrir cofres con estado persistente (abierto) en GameState.M70
[ ] T-70-088: M18: abrir/cerrar puertas al E; bloqueo por llave con razón
[ ] T-70-089: M65: acariciar/alimentar animales al E con factor de ánimo
[ ] T-70-090: M35/M46: recoger recursos cosechables al E (objeto)
[ ] T-70-091: M22/M24/M26: activar triggers/cutscenes al E o por zona
[ ] T-70-092: M103: logging estructurado de errores de contrato, degradaciones y timeouts
[ ] T-70-093: Varios objetos juntos a la misma distancia: gana prioridad de categoría
[ ] T-70-094: Dos objetos idénticos superpuestos: se ordena por registro y nunca alterna
[ ] T-70-095: Jugador se aleja durante una interacción en curso: cancelación suave
[ ] T-70-096: Jugador gira 180 grados con dos objetos equidistantes: cambia por desviación angular
[ ] T-70-097: Pausa a mitad de interacción: DORMIDO, al reanudar continúa sin glitches
[ ] T-70-098: Cooldown de puerta y tecla E en auto-repeat: no se re-abre fuera de cooldown
[ ] T-70-099: Filtro de distancia con producto punto al cuadrado, sin sqrt en el paso rápido
[ ] T-70-100: Espaciado del raycast de línea de visión (N=4 frames)
[ ] T-70-101: Pool del indicador world-space (sin instancias/destrucciones por frame)
[ ] T-70-102: Evitar allocaciones de Arrays en el hot path (reuso de buffers)
[ ] T-70-103: Ordenamiento solo sobre candidatos pre-filtrados (k < 8)
[ ] T-70-104: Escritura de persistencia diferida y por lote (cada 0.5 s como máximo)
[ ] T-70-105: Verificación del presupuesto < 0.5 ms/frame con el profiler en escena densa
[ ] T-70-106: Documentar métricas de referencia para LOD de detección en zonas muy pobladas
[ ] T-70-107: Crear 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF y RN
[ ] T-70-108: Crear 02-Analisis.md con análisis del dominio, categorías, alternativas y decisiones D1-D7
[ ] T-70-109: Crear 03-Diseno.md con arquitectura, nodos, contrato, flujos y rendimiento
[ ] T-70-110: Crear 05-Checklist.md con 130+ ítems verificables
[ ] T-70-111: Documentar la integración con M11/M13/M19 y demás consumidores en 03-Diseno.md
[ ] T-70-112: Documentar la regla de unificación de tecla (E vs F histórica) como pendiente para M57
[ ] T-70-113: Definir escenario "esquina": objetivo tras pared voxel con categoría de visión
[ ] T-70-114: Definir escenario "cosecha": 30 plantas maduras en fila sin parpadeo
[ ] T-70-115: Definir escenario "puerta bloqueante": E repetida durante interacción en curso
[ ] T-70-116: Definir escenario "streaming": alta/baja de zona con M63 sin referencias colgadas
[ ] T-70-117: Plan de tests de determinismo: misma entrada -> misma selección (assert en Edit Mode)
[ ] T-70-118: Plan de tests de persistencia: cofre abierto, puerta y animal acariciado sobreviven sesión
[ ] T-70-119: Plan de pruebas de cancelación: distancia, UI, pausa y cambio de objetivo
[ ] T-70-120: Plan de pruebas de input: teclado E, gamepad A/B, remapeo y auto-repeat
[ ] T-70-121: Plan de pruebas de localización: nombres y razones traducibles sin cortes de layout
