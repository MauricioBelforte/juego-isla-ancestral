**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

# 05-Checklist.md — Módulo 21: Diálogos

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** El núcleo M21 está implementado (manager,
> grafo, UI, JSON de ejemplo). Se documentó y corrigió el bug "el diálogo solo funciona una vez":
> la UI mutaba el Array de opciones del grafo cacheado por referencia (fix en dialogue_ui.gd,
> ver 07-GUIA-GODOT §9.46 y Notas del Agente en 04-Codigo.md). Los ítems `[ ]` de este checklist
> aún no fueron relevados contra el código real por completo; los marcados `[x]` son los
> correspondientes a este bugfix y su verificación.

## A. Requisitos del módulo (12)

- [ ] Definir el problema: NPC con conversaciones vivas y ramificadas sin texto en código [S]
- [ ] Registrar dependencias: M19 (amistad); relaciones M22, M23, M87, M29/M31, M64, M73, M17 [S]
- [ ] RF1: motor de diálogo nodo a nodo [S]
- [ ] RF2: opciones ramificadas con condiciones y efectos [S]
- [ ] RF3: tipografía progresiva con velocidad configurable [S]
- [ ] RF4: salto rápido de línea y salto completo con confirmación doble [S]
- [ ] RF5: variables de estado del mundo como condición de ramas [S]
- [ ] RF6: textos dinámicos con placeholders resueltos en runtime [S]
- [ ] RF7: diálogos contextuales por estación, hora, clima y progreso [S]
- [ ] RF8: avance automático opcional con temporizador [S]
- [ ] RF9: señales de eventos de conversación (inicio, fin, nodo, opción) [S]
- [ ] RF10-RF12: traducción con claves, base de diálogos con IDs únicos y triggers [S]

## B. Implementación del motor nodo a nodo (14)

- [ ] Implementar DialogueNode con id, tipo, speaker, texto y placeholders [S]
- [ ] Implementar tipos de nodo: LINEA, OPCIONES, EVENTO, FIN [S]
- [ ] Implementar transición lineal via next_id [S]
- [ ] Implementar salto directo via goto_id [S]
- [ ] Implementar nodo FIN con cierre limpio de conversación [S]
- [ ] Implementar nodo EVENTO sin texto visible con efectos [S]
- [ ] Implementar DialogueManager como autoload registrado en project.godot [S]
- [ ] Implementar start_dialogue con cache de grafos [S]
- [ ] Implementar stop_dialogue con limpieza de estado [S]
- [ ] Implementar advance() que respeta tipeo activo [S]
- [ ] Implementar reentrada segura: dos diálogos nunca activos a la vez [S]
- [ ] Implementar contexto por sesion (quien habla, desde donde se abrio) [S]
- [ ] Implementar resolucion de texto con claves y placeholders [S]
- [ ] Implementar speaker por clave (NPC, deidad, narrador) con nombre y retrato [S]

## C. Grafo JSON y validación (14)

- [ ] Definir esquema JSON de grafo con dialogue_id y start_node_id [S]
- [ ] Implementar DialogueGraph.load_from_json con parsing tolerante [S]
- [ ] Reportar JSON malformado con archivo, linea y columna [S]
- [ ] Detectar IDs duplicados dentro de un grafo [S]
- [ ] Detectar next_id apuntando a nodo inexistente [S]
- [ ] Detectar goto_id apuntando a nodo inexistente [S]
- [ ] Detectar nodo sin start_node_id alcanzable (nodo huerfano) [S]
- [ ] Detectar grafo sin nodo de inicio [S]
- [ ] Detectar ciclos sin salida (loop de LINEA sin FIN) [M]
- [ ] Validar condiciones con sintaxis incorrecta [S]
- [ ] Validar referencias a variables inexistentes del WorldStateService [S]
- [ ] Emitir log [VAL-DGT] con conteo de errores y advertencias [S]
- [ ] Fallback amigable al usar un grafo invalido (mensaje por defecto) [S]
- [ ] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M]

## D. UI y tipografía progresiva (16)

- [ ] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S]
- [ ] Crear caja de dialogo con nombre y retrato del hablante [S]
- [ ] Implementar tipografia progresiva letra a letra [S]
- [ ] Configurar velocidad de tipeo por caracteres por minuto [S]
- [ ] Acelerar el tipeo mientras se mantiene presionada la confirmacion [S]
- [ ] Completar la linea al instante con el primer confirm durante el tipeo [S]
- [ ] Avanzar de nodo con el confirm una vez completada la linea [S]
- [ ] Implementar salto completo del dialogo con doble confirmacion sostenida [S]
- [ ] Mostrar indicador de linea completada (flecha pulsante) [S]
- [ ] Mostrar indicador de espera mientras se escribe (tres puntos) [S]
- [ ] Implementar avance automatico opcional con temporizador y pausa en opciones [S]
- [ ] Implementar salto de pagina automatico para lineas largas [M]
- [ ] Mostrar contador de paginas cuando hay multiples saltos [M]
- [ ] Aplicar color de texto por tipo de hablante (NPC, deidad, narrador) [S]
- [ ] Usar las fuentes del modulo M87 en textos y retratos [S]
- [ ] Ocultar y resetear la UI al terminar la conversacion [S]

## E. Opciones y ramificación (10)

- [ ] Implementar DialogueOption con text_key, next_id, conditions y effects [S]
- [ ] Mostrar la lista de opciones filtrada por condiciones del mundo [S]
- [ ] Ocultar opciones bloqueadas cuando hide_blocked es true [S]
- [ ] Mostrar opciones bloqueadas con texto alternativo y visual gris [S]
- [ ] Navegar opciones con teclado (arriba/abajo + confirmar) [S]
- [ ] Navegar opciones con gamepad (dpad + boton A) [S]
- [ ] Seleccionar opciones con mouse (hover y click) [S]
- [ ] Aplicar los effects de la opcion elegida una sola vez [S]
- [ ] Soportar ramas de mas de un nivel de profundidad [S]
- [ ] Perder la rama elegida en el historial de sesion para retornos [M]

## F. Variables de estado del mundo (12)

- [ ] Implementar WorldStateService con get_value y set_value [S]
- [ ] Implementar get_snapshot para evaluar condiciones en lote [S]
- [ ] Condiciones sobre estacion del ano (primavera, verano, otono, invierno) [S]
- [ ] Condiciones sobre hora del dia y franjas horarias [S]
- [ ] Condiciones sobre clima (lluvia, sol, tormenta) [S]
- [ ] Condiciones sobre progreso de la historia principal [S]
- [ ] Condiciones sobre amistad por NPC (M19) [S]
- [ ] Condiciones sobre etapa de misiones M22 y sellos M23 [S]
- [ ] Condiciones sobre eventos y festivales activos (M73) [S]
- [ ] Efectos que modifican amistad del NPC (M19) [S]
- [ ] Efectos que marcan banderas permanentes de conversaciones vistas [S]
- [ ] Persistir banderas de conversacion en el guardado de partida [M]

## G. Integración con módulos (12)

- [ ] DialogueTrigger integrable en NPCs del modulo M19 [S]
- [ ] NPC se detiene y mira al jugador durante la conversacion (M64) [S]
- [ ] La rutina del NPC (M64) se bloquea mientras habla y se reanuda despues [S]
- [ ] Dialogos de amistad por nivel en M19 (nuevas ramas al subir afinidad) [S]
- [ ] Efectos de opcion informan al sistema de misiones M22 [S]
- [ ] Dialogos de pistas y revelaciones conectados a M23 (templos) [S]
- [ ] Dialogos contextuales por clima/estacion/hora via M29/M31 [S]
- [ ] Dialogos especiales por festivales (M73) con ramas temporales [S]
- [ ] Reacciones a obras del jugador (M17) via banderas del mundo [S]
- [ ] Textos localizados con diccionarios por idioma (M87 compatible) [S]
- [ ] Pausa del reloj M29 pausa el tipeo sin perder estado [S]
- [ ] Guerra de inputs: el dialogo activo bloquea acciones del jugador [S]

## H. Edge cases y robustez (14)

- [ ] NPC desaparece o se aleja durante el dialogo: cierre limpio sin errores [S]
- [ ] Iniciar dialogo dos veces en el mismo frame: segunda llamada ignorada [S]
- [ ] Grafo invalido en start_dialogue: feedback por log y fallback [S]
- [ ] Clave de texto ausente en el diccionario: se muestra la clave cruda [S]
- [ ] Placeholder faltante: se muestra el nombre de la variable entre llaves [S]
- [ ] Opcion unica con condiciones falsas: rama colapsa a next_id alternativo [S]
- [ ] Nodo OPCIONES sin opciones visibles: salta a next_id sin pantalla vacia [S]
- [ ] Dialogo interrumpido por teleport del jugador (M69): se cierra y se loguea [S]
- [ ] Guardado y carga de partida a mitad de conversacion: la conversacion se reinicia [M]
- [ ] Tipeo con caracteres unicode y emojis neutralizados en produccion [S]
- [ ] Lineas muy cortas y muy largas se ven correctamente [S]
- [ ] Multiples hablantes en un mismo grafo: retrato y nombre cambian por nodo [S]
- [ ] Recarga del grafo con datos rotos en caliente: el cache no se corrompe [S]
- [ ] La UI nunca emite errores si el manager no esta activo [S]
- [x] La UI no muta los datos del grafo cacheado: las opciones se copian con duplicate() y la limpieza reasigna en vez de clear() [S]
- [x] El diálogo se puede reiniciar N veces sin errores [VAL-DGT] (fix verificado headless) [S]

## I. Optimización (7)

- [ ] Cache de grafos cargados con descarte LRU por limite de memoria [M]
- [ ] Cero allocs apreciables por frame durante el tipeo (strings precalculadas) [S]
- [ ] Evaluacion de condiciones en lote con get_snapshot (una sola lectura) [S]
- [ ] UI oculta con visibility, sin procesos en idle cuando no hay dialogo [S]
- [ ] Fuentes del modulo M87 con atlas compartido, sin reimport por nodo [S]
- [ ] Load de JSON asincrono con carga diferida por zona del mapa [M]
- [ ] Presupuesto: dialogo activo agrega menos de 1 ms al frame presupuestado [S]

## J. Documentación (6)

- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis con alternativas descartadas justificadas y firmado [S]
- [ ] 03-Diseno con contratos de API y flujos creado y firmado [S]
- [ ] 04-Codigo con rutas, firmas y logs creado y firmado [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Plan-actual duplicado identico del plan-inicial [S]

## K. Polish (6)

- [ ] Transicion suave de apertura y cierre de la caja de dialogo [S]
- [ ] Animacion sutil del retrato al cambiar de hablante [S]
- [ ] Sonido de tipeo opcional atenuado por linea (integra audio del proyecto) [S]
- [ ] Destello suave en la linea seleccionada de opciones [S]
- [ ] Ritmo de tipeo calibrado para lectura cozy (sin prisa) [S]
- [ ] Dialogo de ejemplo localizado en espanol e ingles como muestra [M]

## L. Testing y QA (6)

- [ ] Test del pipeline end-to-end con dialogo_ejemplo.json en play mode [M]
- [ ] Test de salto rapido: tipeo, linea, nodo y salto completo [M]
- [ ] Test de ramas: cada condicion verdadera y falsa evaluada [M]
- [ ] Test de validacion: 5 grafos invalidos propositados detectados en editor [M]
- [ ] Test de integracion con un NPC del modulo M19 interactuable [M]
- [ ] Verificacion de 0 errores en consola durante una partida de prueba [S]
- [x] Test de reinicio del diálogo tras completarlo (test_dialogos.gd: _test_reinicio_dialogo — 0 fallos) [S]