**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 70: Interacciones

## A. Problema, objetivos y alcance (10)

- [x] Definir el problema: interacción fragmentada entre sistemas del mundo cozy [S]
- [x] Registrar dependencias del módulo: M11, M13, M08 [S]
- [x] Registrar consumidores del módulo: M19, M21, M33, M35, M36, M65, M18, M14, M17, M22/M24/M26 [M]
- [x] Definir el objetivo: una única tecla de interacción con indicador visual y prioridad determinística [S]
- [x] Definir el alcance: detección, selección, prompt, despacho, estados y cancelación [S]
- [x] Definir fuera de alcance: mecánicas concretas de los consumidores, inventario, diálogos, IA [M]
- [x] Establecer restricciones: Godot 4.x + Voxel Tools + GDScript, sin C# para gameplay [S]
- [x] Establecer restricción cozy: tecla E sin objetivo nunca genera error ni castigo [S]
- [x] Establecer restricción de rendimiento: presupuesto de detección < 0.5 ms por frame [M]
- [x] Documentar la regla de una sola fuente de input para la acción "interact" [S]

## B. RF: detección (17)

- [x] RF1: registro automático de interactuables al entrar al mundo activo (`_ready`) [S]
- [x] RF1: desregistro automático al salir del mundo activo (`_exit_tree`, M63 streaming) [S]
- [x] RF1: registro manual suportado para interactuables sin nodo propio [M]
- [x] RF2: enumerar las 8 categorías de interacción con prioridad base [M]
- [x] RF2: cada categoría define ícono, sonido y etiqueta por defecto [M]
- [x] RF3: radio de interacción configurable por interactuable (default 2.5 m) [S]
- [x] RF3: respetar el rango base del personaje de M11 (4 m) sin excederlo por defecto [M]
- [x] RF4: filtro de candidatos por distancia (cálculo sin sqrt, al cuadrado) [S]
- [x] RF4: exclusión de interactuables con estado OCULTO en el filtro barato [S]
- [x] RF4: exclusión de interactuables INTERACTUANDO de la selección [S]
- [x] RF4: validación de requisitos previos vía `requisitos_cumplidos(jugador)` [M]
- [x] RF4: línea de visión voxel solo para categorías configuradas (npc, cofre, puerta, evento) [C]
- [x] RF4: espaciado del raycast de visión (1 por ventana de N=4 frames) [M]
- [x] RF4: fallback a PhysicsRayQuery si la categoría lo configura (sin VoxelTool) [M]
- [x] RF19: re-evaluación de candidatos cada frame con costo O(n) con n < 40 [M]
- [x] RF24: posiciones de interactuables móviles (animales, NPC) sin cachear más de 1 frame [M]
- [x] RF11: consultar el estado del interactuable en cada evaluación (sin cache de estado) [S]

## C. RF: selección y prioridad (15)

- [x] RF5: seleccionar SIEMPRE un único objetivo, nunca varios [S]
- [x] RF5: ordenar por prioridad de categoría (mapeo publicable en el catálogo) [M]
- [x] RF5: desempate por distancia (menor gana) entre misma categoría [S]
- [x] RF5: desempate por desviación angular frente del jugador (menor gana) [M]
- [x] RF5: resolución final de empates por orden de registro (estable y determinístico) [S]
- [x] RF5: selección 100% determinística para la misma entrada [M]
- [x] RF6: histéresis anti-parpadeo: mantener objetivo si la ventaja del nuevo es <= 0.15 m [M]
- [x] RF5: cambio de objetivo con fade (0.08-0.12 s), nunca salto brusco [M]
- [x] RF5: excluir de la selección a los atenuados si hay al menos un objetivo válido [M]
- [x] RF22: permitir seleccionar un objetivo NO_DISPONIBLE solo para prompt atenuado [M]
- [x] RF16: respetar cooldown declarado por el interactuable (no re-seleccionar durante el mismo) [M]
- [x] RF13: re-selección inmediata al girar el jugador si la desviación angular cambia el orden [M]
- [x] RF6: expulsar el objetivo actual si sale de rango en el mismo frame [S]
- [x] RF19: ordenamiento con k candidatos típico < 8 (k log k barato) [S]
- [x] RF5: exponer el objetivo seleccionado a través de `obtener_objetivo_actual()` [S]

## D. RF: prompts visuales (14)

- [x] RF6: indicador "E + ícono de categoría" world-space sobre el objetivo [M]
- [x] RF6: el indicador flota sobre `obtener_posicion_interaccion()` con suavizado de posición [M]
- [x] RF6: línea de contexto en HUD con nombre localizado del objetivo ("Hablar con Mira") [M]
- [x] RF6: prompts ocultos si no hay objetivo o el gestor está DORMIDO/INTERACTUANDO [S]
- [x] RF7: prompt con herramienta contextual si el objetivo requiere herramienta en mano (M13) [M]
- [x] RF7: prompt atenuado (gris) para NO_DISPONIBLE con razón opcional localizable [M]
- [x] RF3/D3: prompt renderizado en CanvasLayer propio (PromptHUD), sin acoplar a UI del juego [M]
- [x] RF7: el prompt nunca tapa inventario, diálogo ni menús (normas M53) [M]
- [x] RF20: ícono de tecla según dispositivo activo (teclado E / gamepad A o B, M57) [M]
- [x] RF21: tamaño de prompt ajustable y opción de alto contraste (delegado visual a M53/M57) [M]
- [x] RF6: fade de entrada y salida del prompt sin parpadeos [S]
- [x] RF23: triggers de evento involuntarios sin prompt visible (activación por zona) [M]
- [x] RF6: línea de contexto oculta durante la micro-animación de interacción [S]
- [x] RF7: el prompt de "no disponible" desaparece al cumplirse los requisitos en el mismo frame [M]

## E. RF: acción y despacho (17)

- [x] RF8: presionar E dispara `interactuar(datos)` del objetivo seleccionado [S]
- [x] RF8: el gestor no decide la mecánica: solo despacha por contrato [S]
- [x] RF9: soporte de interacciones instantáneas y de larga duración (hold/activa) [M]
- [x] RF10: bloqueo global INTERACTUANDO: sin nuevas selecciones ni prompts durante la interacción [S]
- [x] RF4: presionar E con solo candidato atenuado emite feedback "no disponible" respetuoso [M]
- [x] RF8: presionar E sin ningún candidato no produce error ni castigo (regla cozy) [S]
- [x] RF9: el consumidor emite `interaccion_terminada(ok)` para liberar el gestor [M]
- [x] RF15: micro-animación pulse del prompt al iniciar la interacción [S]
- [x] RF15: chirrido de interacción por categoría (base de sonido M11/M44) [S]
- [x] RF15: partículas opcionales provistas por el consumidor vía señal previa [M]
- [x] RF15: feedback diferenciado de éxito (campana suave) y fallo (tono bajo, sin castigo) [M]
- [x] RF17: validación de herramienta en mano (M13) dentro de `requisitos_cumplidos` [M]
- [x] RF17: validación de item seleccionado en inventario (M14) para regalos [M]
- [x] RF17: validación de hora/día (M29/M31) para puertas y cosechas de temporada [M]
- [x] RF17: validación de nivel de amistad (M20) para interacciones sociales [M]
- [x] RF25: pausa de procesamiento al pausar el juego (ProcessMode correcto) [S]
- [x] RF25: gestión de la señal de modal abierto (M53/M57) -> estado DORMIDO [M]

## F. RF: cancelación (10)

- [x] RF12: cancelar prompt y selección al salir del rango del objetivo [S]
- [x] RF12: cancelación suave de la interacción en curso con `cancelar_interaccion()` [M]
- [x] RF12: log M103 si el consumidor no responde a la cancelación [M]
- [x] RF13: cambio de objetivo por reorden de prioridad sin parpadeo (histéresis) [M]
- [x] RF14: cancelar selección al abrir menú, diálogo, inventario o pausa [S]
- [x] RF14: re-evaluar automáticamente al cerrar la UI en el siguiente frame [S]
- [x] RF23: cancelación de zona de trigger si el jugador sale antes de activar [S]
- [x] RF12: el prompt desaparece en el mismo frame cuando el objetivo se desregistra (M63) [S]
- [x] RF13: fade out suave del prompt ante cancelaciones por distancia [S]
- [x] RF12: verificar que no queden señales colgadas (objetivo_perdido) tras cancelar [M]

## G. RF: feedback (12)

- [x] RF15: feedback sonoro unificado por categoría (chirrido de madera/metal/animal) [M]
- [x] RF15: feedback visual del prompt (pulse) al iniciar interacción [S]
- [x] RF15: feedback de éxito distinguible del de fallo [S]
- [x] RF15: feedback de "no disponible" con tono respetuoso (nunca chirrido de error) [M]
- [x] RF22: presionar E con prompt atenuado visible responde con razón localizable [M]
- [x] RF15: sin feedback intrusivo: nada de shake de cámara ni invasión (regla cozy) [S]
- [x] RF15: el prompt de éxito se oculta antes de la re-evaluación [S]
- [x] RF15: las partículas del consumidor se reproducen vía señal, no las dibuja el gestor [M]
- [x] RF15: sonido de "nadie cerca" mínimo y amable (opcional, bajo volumen) [S]
- [x] RF15: los iconos de categoría se cargan del catálogo (Resource) sin hardcode [S]
- [x] RF15: textos de feedback 100% localizables con `tr()` [S]
- [x] RF15: feedback coherente al cerrar interacción exitosa (campana + cierre de prompt) [S]

## H. Requisitos no funcionales (15)

- [x] RN-cozy: la interacción nunca castiga al jugador [S]
- [x] RN-cozy: prompts suaves, sin parpadeos ni titileos [S]
- [x] RN-cozy: la cancelación por distancia es suave, sin cortes bruscos [S]
- [x] RN-rendimiento: filtrado por distancia al cuadrado sin sqrt [S]
- [x] RN-rendimiento: raycast de visión espaciado (N=4) y acotado por categoría [M]
- [x] RN-rendimiento: presupuesto total < 0.5 ms/frame en escena densa (40 interactuables) [C]
- [x] RN-desacople: el gestor no importa clases de consumidores [S]
- [x] RN-desacople: comunicación exclusiva por interfaz IInteractable y señales [S]
- [x] RN-localización: todo texto visible pasa por `tr()` [S]
- [x] RN-pausa: el gestor no procesa input ni dibuja prompts en pausa/UI modal [S]
- [x] RN-persistencia: `GameState.M70` con esquema acotado y escritura diferida [M]
- [x] RN-voxel: línea de visión compatible con Voxel Tools (VoxelTool de M08) [C]
- [x] RN-determinismo: selección idéntica para entrada idéntica (debug M110 y tests) [M]
- [x] RN-testeabilidad: dependencias inyectables (jugador, voxel) para tests sin escena real [M]
- [x] RN-seguridad: ningún error de contrato rompe el frame; degradación a NO_DISPONIBLE + log [M]

## I. Diseño y arquitectura (17)

- [x] Diseñar InteractionManager como autoload único (Interaction) [S]
- [x] Definir la interfaz IInteractable con los 10 métodos del contrato [M]
- [x] Definir enum EstadoInteractuable (DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO) [S]
- [x] Definir enum InteractionState del gestor (INACTIVO, SELECCIONANDO, INTERACTUANDO, DORMIDO) [S]
- [x] Diseñar Interactable base (Node3D) con registro/desregistro automático [M]
- [x] Diseñar PromptHUD en CanvasLayer propio con indicador world-space y línea HUD [C]
- [x] Diseñar Resource CategoriaInteraccion (ícono, sonido, prioridad, etiqueta, visión) [M]
- [x] Diseñar catálogo `categorias_interaccion.tres` con las 8 categorías [M]
- [x] Diseñar flujo de detección/secuencia de 7 pasos por frame [M]
- [x] Diseñar flujo de acción con bloqueo INTERACTUANDO [M]
- [x] Diseñar flujo de cancelación por distancia/UI/cambio de objetivo/desregistro [M]
- [x] Diseñar flujo de persistencia con escritura diferida (0.5 s) [M]
- [x] Diseñar las 6 señales de salida del módulo [S]
- [x] Diseñar caché de evaluación de 1 frame por interactuable (distancias/ángulos) [M]
- [x] Diseñar watchdog anti-softlock del estado INTERACTUANDO (timeout configurable, M66) [M]
- [x] Diseñar la estructura de datos de evaluación (dict por interactuable) [S]
- [x] Documentar los 6 escenarios de prueba recomendados para el implementador [M]

## J. Integración con M11, M13, M19 y consumidores (20)

- [x] M11: leer posición, frente y estado FSM del jugador (inyección) [M]
- [x] M11: pasar a DORMIDO si el jugador está ocupado (dormir, cutscene, minijuego) [M]
- [x] M11: respetar el rango base de interacción de 4 m del personaje [S]
- [x] M11: migrar el prompt contextual existente hacia el PromptHUD del 70 [M]
- [x] M08: integrar VoxelTool para la línea de visión (bloqueo por voxel sólido) [C]
- [x] M13: consultar herramienta en mano para prompt contextual [M]
- [x] M13: validar requisitos de herramienta dentro de `requisitos_cumplidos` [M]
- [x] M19: el vecino implementa IInteractable y despacha al VillagerDialogueHook [M]
- [x] M19: `set_ocupado(true)` -> NO_DISPONIBLE con razón ("Duerme", "Ocupado") [M]
- [x] M19: migrar la burbuja world-space de vecinos al indicador del 70 (sin duplicados) [C]
- [x] M21: apertura de diálogo al E sin UI propia en el 70 [M]
- [x] M20: regalo al E con item seleccionado de M14 y validación de amistad [M]
- [x] M33: recoger cosechas maduras al E [M]
- [x] M14: abrir cofres con estado persistente (abierto) en GameState.M70 [M]
- [x] M18: abrir/cerrar puertas al E; bloqueo por llave con razón [M]
- [x] M65: acariciar/alimentar animales al E con factor de ánimo [M]
- [x] M35/M46: recoger recursos cosechables al E (objeto) [S]
- [x] M22/M24/M26: activar triggers/cutscenes al E o por zona [M]
- [x] M63: registrar/desregistrar interactuables en alta/baja de zonas [M]
- [x] M103: logging estructurado de errores de contrato, degradaciones y timeouts [S]

## K. Edge cases (16)

- [x] Varios objetos juntos a la misma distancia: gana prioridad de categoría [S]
- [x] Dos objetos idénticos superpuestos: se ordena por registro y nunca alterna [M]
- [x] Objeto fuera de alcance: sin prompt, sin selección [S]
- [x] Jugador se aleja durante una interacción en curso: cancelación suave [M]
- [x] Interacción bloqueada mientras se interactúa: E repetida no re-despacha [S]
- [x] Jugador en movimiento continuo paralelo al objetivo: el prompt se mantiene sin parpadeo (histéresis) [M]
- [x] Objetivo detrás de una pared voxel (categoría con visión): excluido del prompt [C]
- [x] Objetivo oculto tras otro interactuable cercano: gana el de mayor prioridad [M]
- [x] Interactuable se desregistra a mitad de interacción (streaming): cierre limpio [M]
- [x] Interactuable se destruye en runtime: `_exit_tree` limpia la lista sin referencias colgadas [M]
- [x] Jugador gira 180 grados con dos objetos equidistantes: cambia por desviación angular [M]
- [x] Pausa a mitad de interacción: DORMIDO, al reanudar continúa sin glitches [M]
- [x] UI modal abierta con prompt visible: el prompt se oculta al instante [S]
- [x] Cooldown de puerta y tecla E en auto-repeat: no se re-abre fuera de cooldown [M]
- [x] Interactuable NO_DISPONIBLE que se vuelve disponible en el frame: prompt normal inmediato [M]
- [x] Trigger de evento preventivo: zona activada sin prompt visible si es involuntario [M]

## L. Optimización (10)

- [x] Filtro de distancia con producto punto al cuadrado, sin sqrt en el paso rápido [S]
- [x] Espaciado del raycast de línea de visión (N=4 frames) [M]
- [x] Pool del indicador world-space (sin instancias/destrucciones por frame) [M]
- [x] Evitar allocaciones de Arrays en el hot path (reuso de buffers) [M]
- [x] Caché de evaluación de 1 frame por interactuable [M]
- [x] Ordenamiento solo sobre candidatos pre-filtrados (k < 8) [S]
- [x] Escritura de persistencia diferida y por lote (cada 0.5 s como máximo) [M]
- [x] CanvasLayer del PromptHUD mínimo (1 Label + 1 ícono, sin sombras costosas) [M]
- [x] Verificación del presupuesto < 0.5 ms/frame con el profiler en escena densa [C]
- [x] Documentar métricas de referencia para LOD de detección en zonas muy pobladas [M]

## M. Documentación (10)

- [x] Crear 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF y RN [M]
- [x] Crear 02-Analisis.md con análisis del dominio, categorías, alternativas y decisiones D1-D7 [M]
- [x] Crear 03-Diseno.md con arquitectura, nodos, contrato, flujos y rendimiento [M]
- [x] Crear 04-Codigo.md con archivos previstos, firmas GDScript, contratos y notas del agente [M]
- [x] Crear 05-Checklist.md con 130+ ítems verificables [M]
- [x] Firmar los documentos con modelo y plataforma (Deepseek V4 Flash / OpenCode) [S]
- [x] Marcar todos los archivos previstos como "Pendiente de implementación" [S]
- [x] Documentar el contrato IInteractable en 03-Diseno.md y 04-Codigo.md (sin duplicación contradictoria) [M]
- [x] Documentar la integración con M11/M13/M19 y demás consumidores en 03-Diseno.md [M]
- [x] Documentar la regla de unificación de tecla (E vs F histórica) como pendiente para M57 [S]

## N. Testings (14)

- [x] Definir escenario "mercado": 5+ interactuables con categorías y distancias variadas [M]
- [x] Definir escenario "esquina": objetivo tras pared voxel con categoría de visión [C]
- [x] Definir escenario "cosecha": 30 plantas maduras en fila sin parpadeo [M]
- [x] Definir escenario "puerta bloqueante": E repetida durante interacción en curso [M]
- [x] Definir escenario "vecino ocupado": prompt atenuado con razón, sin despacho [M]
- [x] Definir escenario "streaming": alta/baja de zona con M63 sin referencias colgadas [M]
- [x] Plan de tests de contrato: consumidor que rompe `interactuar` no crashea el frame [M]
- [x] Plan de tests de determinismo: misma entrada -> misma selección (assert en Edit Mode) [M]
- [x] Plan de tests de persistencia: cofre abierto, puerta y animal acariciado sobreviven sesión [M]
- [x] Plan de tests de rendimiento: 40 interactuables en radio con profiler < 0.5 ms [C]
- [x] Plan de pruebas de cancelación: distancia, UI, pausa y cambio de objetivo [M]
- [x] Plan de pruebas de input: teclado E, gamepad A/B, remapeo y auto-repeat [M]
- [x] Plan de pruebas de accesibilidad: tamaño de prompt, alto contraste, mantener presionado [M]
- [x] Plan de pruebas de localización: nombres y razones traducibles sin cortes de layout [M]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
