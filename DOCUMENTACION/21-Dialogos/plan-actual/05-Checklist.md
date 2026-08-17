**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 21: Diálogos

## A. Requisitos del módulo (12)

- [x] Definir el problema: NPC con conversaciones vivas y ramificadas sin texto en código [S]
- [x] Registrar dependencias: M19 (amistad); relaciones M22, M23, M87, M29/M31, M64, M73, M17 [S]
- [x] RF1: motor de diálogo nodo a nodo [S]
- [x] RF2: opciones ramificadas con condiciones y efectos [S]
- [x] RF3: tipografía progresiva con velocidad configurable [S]
- [x] RF4: salto rápido de línea y salto completo con confirmación doble [S]
- [x] RF5: variables de estado del mundo como condición de ramas [S]
- [x] RF6: textos dinámicos con placeholders resueltos en runtime [S]
- [x] RF7: diálogos contextuales por estación, hora, clima y progreso [S]
- [x] RF8: avance automático opcional con temporizador [S]
- [x] RF9: señales de eventos de conversación (inicio, fin, nodo, opción) [S]
- [x] RF10-RF12: traducción con claves, base de diálogos con IDs únicos y triggers [S]

## B. Implementación del motor nodo a nodo (14)

- [x] Implementar DialogueNode con id, tipo, speaker, texto y placeholders [S]
- [x] Implementar tipos de nodo: LINEA, OPCIONES, EVENTO, FIN [S]
- [x] Implementar transición lineal via next_id [S]
- [x] Implementar salto directo via goto_id [S]
- [x] Implementar nodo FIN con cierre limpio de conversación [S]
- [x] Implementar nodo EVENTO sin texto visible con efectos [S]
- [x] Implementar DialogueManager como autoload registrado en project.godot [S]
- [x] Implementar start_dialogue con cache de grafos [S]
- [x] Implementar stop_dialogue con limpieza de estado [S]
- [x] Implementar advance() que respeta tipeo activo [S]
- [x] Implementar reentrada segura: dos diálogos nunca activos a la vez [S]
- [x] Implementar contexto por sesion (quien habla, desde donde se abrio) [S]
- [x] Implementar resolucion de texto con claves y placeholders [S]
- [x] Implementar speaker por clave (NPC, deidad, narrador) con nombre y retrato [S]

## C. Grafo JSON y validación (14)

- [x] Definir esquema JSON de grafo con dialogue_id y start_node_id [S]
- [x] Implementar DialogueGraph.load_from_json con parsing tolerante [S]
- [x] Reportar JSON malformado con archivo, linea y columna [S]
- [x] Detectar IDs duplicados dentro de un grafo [S]
- [x] Detectar next_id apuntando a nodo inexistente [S]
- [x] Detectar goto_id apuntando a nodo inexistente [S]
- [x] Detectar nodo sin start_node_id alcanzable (nodo huerfano) [S]
- [x] Detectar grafo sin nodo de inicio [S]
- [x] Detectar ciclos sin salida (loop de LINEA sin FIN) [M]
- [x] Validar condiciones con sintaxis incorrecta [S]
- [x] Validar referencias a variables inexistentes del WorldStateService [S]
- [x] Emitir log [VAL-DGT] con conteo de errores y advertencias [S]
- [x] Fallback amigable al usar un grafo invalido (mensaje por defecto) [S]
- [x] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M]

## D. UI y tipografía progresiva (16)

- [x] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S]
- [x] Crear caja de dialogo con nombre y retrato del hablante [S]
- [x] Implementar tipografia progresiva letra a letra [S]
- [x] Configurar velocidad de tipeo por caracteres por minuto [S]
- [x] Acelerar el tipeo mientras se mantiene presionada la confirmacion [S]
- [x] Completar la linea al instante con el primer confirm durante el tipeo [S]
- [x] Avanzar de nodo con el confirm una vez completada la linea [S]
- [x] Implementar salto completo del dialogo con doble confirmacion sostenida [S]
- [x] Mostrar indicador de linea completada (flecha pulsante) [S]
- [x] Mostrar indicador de espera mientras se escribe (tres puntos) [S]
- [x] Implementar avance automatico opcional con temporizador y pausa en opciones [S]
- [x] Implementar salto de pagina automatico para lineas largas [M]
- [x] Mostrar contador de paginas cuando hay multiples saltos [M]
- [x] Aplicar color de texto por tipo de hablante (NPC, deidad, narrador) [S]
- [x] Usar las fuentes del modulo M87 en textos y retratos [S]
- [x] Ocultar y resetear la UI al terminar la conversacion [S]

## E. Opciones y ramificación (10)

- [x] Implementar DialogueOption con text_key, next_id, conditions y effects [S]
- [x] Mostrar la lista de opciones filtrada por condiciones del mundo [S]
- [x] Ocultar opciones bloqueadas cuando hide_blocked es true [S]
- [x] Mostrar opciones bloqueadas con texto alternativo y visual gris [S]
- [x] Navegar opciones con teclado (arriba/abajo + confirmar) [S]
- [x] Navegar opciones con gamepad (dpad + boton A) [S]
- [x] Seleccionar opciones con mouse (hover y click) [S]
- [x] Aplicar los effects de la opcion elegida una sola vez [S]
- [x] Soportar ramas de mas de un nivel de profundidad [S]
- [x] Perder la rama elegida en el historial de sesion para retornos [M]

## F. Variables de estado del mundo (12)

- [x] Implementar WorldStateService con get_value y set_value [S]
- [x] Implementar get_snapshot para evaluar condiciones en lote [S]
- [x] Condiciones sobre estacion del ano (primavera, verano, otono, invierno) [S]
- [x] Condiciones sobre hora del dia y franjas horarias [S]
- [x] Condiciones sobre clima (lluvia, sol, tormenta) [S]
- [x] Condiciones sobre progreso de la historia principal [S]
- [x] Condiciones sobre amistad por NPC (M19) [S]
- [x] Condiciones sobre etapa de misiones M22 y sellos M23 [S]
- [x] Condiciones sobre eventos y festivales activos (M73) [S]
- [x] Efectos que modifican amistad del NPC (M19) [S]
- [x] Efectos que marcan banderas permanentes de conversaciones vistas [S]
- [x] Persistir banderas de conversacion en el guardado de partida [M]

## G. Integración con módulos (12)

- [x] DialogueTrigger integrable en NPCs del modulo M19 [S]
- [x] NPC se detiene y mira al jugador durante la conversacion (M64) [S]
- [x] La rutina del NPC (M64) se bloquea mientras habla y se reanuda despues [S]
- [x] Dialogos de amistad por nivel en M19 (nuevas ramas al subir afinidad) [S]
- [x] Efectos de opcion informan al sistema de misiones M22 [S]
- [x] Dialogos de pistas y revelaciones conectados a M23 (templos) [S]
- [x] Dialogos contextuales por clima/estacion/hora via M29/M31 [S]
- [x] Dialogos especiales por festivales (M73) con ramas temporales [S]
- [x] Reacciones a obras del jugador (M17) via banderas del mundo [S]
- [x] Textos localizados con diccionarios por idioma (M87 compatible) [S]
- [x] Pausa del reloj M29 pausa el tipeo sin perder estado [S]
- [x] Guerra de inputs: el dialogo activo bloquea acciones del jugador [S]

## H. Edge cases y robustez (14)

- [x] NPC desaparece o se aleja durante el dialogo: cierre limpio sin errores [S]
- [x] Iniciar dialogo dos veces en el mismo frame: segunda llamada ignorada [S]
- [x] Grafo invalido en start_dialogue: feedback por log y fallback [S]
- [x] Clave de texto ausente en el diccionario: se muestra la clave cruda [S]
- [x] Placeholder faltante: se muestra el nombre de la variable entre llaves [S]
- [x] Opcion unica con condiciones falsas: rama colapsa a next_id alternativo [S]
- [x] Nodo OPCIONES sin opciones visibles: salta a next_id sin pantalla vacia [S]
- [x] Dialogo interrumpido por teleport del jugador (M69): se cierra y se loguea [S]
- [x] Guardado y carga de partida a mitad de conversacion: la conversacion se reinicia [M]
- [x] Tipeo con caracteres unicode y emojis neutralizados en produccion [S]
- [x] Lineas muy cortas y muy largas se ven correctamente [S]
- [x] Multiples hablantes en un mismo grafo: retrato y nombre cambian por nodo [S]
- [x] Recarga del grafo con datos rotos en caliente: el cache no se corrompe [S]
- [x] La UI nunca emite errores si el manager no esta activo [S]

## I. Optimización (7)

- [x] Cache de grafos cargados con descarte LRU por limite de memoria [M]
- [x] Cero allocs apreciables por frame durante el tipeo (strings precalculadas) [S]
- [x] Evaluacion de condiciones en lote con get_snapshot (una sola lectura) [S]
- [x] UI oculta con visibility, sin procesos en idle cuando no hay dialogo [S]
- [x] Fuentes del modulo M87 con atlas compartido, sin reimport por nodo [S]
- [x] Load de JSON asincrono con carga diferida por zona del mapa [M]
- [x] Presupuesto: dialogo activo agrega menos de 1 ms al frame presupuestado [S]

## J. Documentación (6)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis con alternativas descartadas justificadas y firmado [S]
- [x] 03-Diseno con contratos de API y flujos creado y firmado [S]
- [x] 04-Codigo con rutas, firmas y logs creado y firmado [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Plan-actual duplicado identico del plan-inicial [S]

## K. Polish (6)

- [x] Transicion suave de apertura y cierre de la caja de dialogo [S]
- [x] Animacion sutil del retrato al cambiar de hablante [S]
- [x] Sonido de tipeo opcional atenuado por linea (integra audio del proyecto) [S]
- [x] Destello suave en la linea seleccionada de opciones [S]
- [x] Ritmo de tipeo calibrado para lectura cozy (sin prisa) [S]
- [x] Dialogo de ejemplo localizado en espanol e ingles como muestra [M]

## L. Testing y QA (6)

- [x] Test del pipeline end-to-end con dialogo_ejemplo.json en play mode [M]
- [x] Test de salto rapido: tipeo, linea, nodo y salto completo [M]
- [x] Test de ramas: cada condicion verdadera y falsa evaluada [M]
- [x] Test de validacion: 5 grafos invalidos propositados detectados en editor [M]
- [x] Test de integracion con un NPC del modulo M19 interactuable [M]
- [x] Verificacion de 0 errores en consola durante una partida de prueba [S]