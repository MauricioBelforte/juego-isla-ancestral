**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-CHECKLIST.md — Checklist Maestro de QA por Área (Módulo 101)

> **Reglas de uso (leer antes de ejecutar cualquier sesión):**
> 1. Cada ítem es **verificable**: se responde `[x]` (pasa), `[ ]` (falla) o `[?]` (no verificable en esta build, con razón).
> 2. Formato de IDs: `NN.MM` — NN = número de área (tabla abajo), MM = ítem dentro del área (ej: `06.03` = área 6, ítem 3).
> 3. Todo ítem verificable **también por logs** (M103) se marca con `🔍`; los ítems `🔍` pueden ejecutarlos agentes solo con logs.
> 4. Los ítems que requieren el debug menu (M110) se marcan `🎮` (teletransporte, dar objetos, fijar tiempo/clima).
> 5. El checklist se actualiza tras cada hito: se agregan ítems nuevos por módulos nuevos y se revisan los existentes contra el `plan-actual` de cada módulo.

## Áreas del checklist

| # | Área | Módulos fuente |
|---|------|----------------|
| 01 | Mundo voxel y terreno | M08, M09, M10 |
| 02 | Generación del mundo | M10, M63 |
| 03 | Jugador y movimiento | M11 |
| 04 | Cámara | M12 |
| 05 | Herramientas | M13 |
| 06 | Inventario | M14 |
| 07 | Recursos | M15 |
| 08 | Crafting | M16 |
| 09 | Construcción y casas | M17, M18 |
| 10 | NPC y vecinos | M19, M20 |
| 11 | Diálogos | M21, M22, M23 |
| 12 | Templos y puzzles | M24, M25, M26 |
| 13 | Islas y viajes | M27, M28, M69 |
| 14 | Tiempo y calendario | M29, M30, M31 |
| 15 | Clima | M32 |
| 16 | Actividades (agri/pesca/minería) | M33, M34, M35 |
| 17 | Fauna y museos | M36, M37 |
| 18 | Economía y tiendas | M38, M39, M70 |
| 19 | Audio | M41-M44 |
| 20 | UI/UX | M53, M57, M88, M89 |
| 21 | Accesibilidad | M58 |
| 22 | Memoria y streaming | M61, M62, M63 |
| 23 | IA (NPC y animales) | M64, M65 |
| 24 | Anti-softlock y guardado | M66, M59 |
| 25 | Tutorial y progresión | M92, M71 |
| 26 | Configuración gráfica y audio | M90, M91 |
| 27 | Debug menu (herramienta) | M110 |

---

## Área 01 — Mundo voxel y terreno (M08, M09, M10)

- [ ] 01.01 🔍 La build arranca sin errores ni warnings en consola hasta el menú/primer frame (M103 vacío de errores).
- [ ] 01.02 🎮 Regenerando el mundo con la misma semilla (42) se obtiene el mismo terreno y biomas (comparar capturas o coordenadas de un punto destacado).
- [ ] 01.03 Con semilla 0, el mundo genera sin excepciones y con todos los biomas presentes (playa/césped/bosque/montaña/nieve).
- [ ] 01.04 Cruzar la frontera de un chunk no produce caídas, agujeros ni costuras visibles.
- [ ] 01.05 Al caminar por el mundo 5 min, los chunks cargan sin pops y desalojados correctamente (monitor de memoria M61).
- [ ] 01.06 Extraer un bloque en la superficie y en profundidad (Y<64) produce el bloque/drop correcto según la herramienta (M15).
- [ ] 01.07 🎮 El teletransporte a coordenadas exactas deja al jugador sobre el terreno (sin flotar ni hundirse; `get_height` consistente).
- [ ] 01.08 Edge: en el borde norte de la isla (coordenadas extremas) el jugador puede caer fuera del terreno y el juego lo recupera sin crash (respawn).
- [ ] 01.09 Edge: bloquear y desbloquear 100 bloques consecutivos no aumenta la memoria de forma sostenida (sin leaks, ver M61/M103).

## Área 02 — Generación del mundo (M10, M63)

- [ ] 02.01 La generación del mundo tarda dentro del presupuesto (sin congelar la UI más del límite definido; barra de progreso M53 si aplica).
- [ ] 02.02 🎮 Con la misma semilla, dos partidas nuevas generan mundos idénticos (verificar 1 punto destacado + bioma).
- [ ] 02.03 El streaming de zonas lejanas no corta el mundo visible en tiempo real (ver 3 biomas desde la montaña central).
- [ ] 02.04 Edge: entrar a una zona de streaming carga los chunks sin excepciones repetidas en el log.
- [ ] 02.05 La isla es coherente con la configuración de radio/paleta del módulo dueño (167-Isla-Raiz para la Isla Raíz).

## Área 03 — Jugador y movimiento (M11)

- [ ] 03.01 WASD se mueve relativo a la cámara; salto, agacharse y correr funcionan (si aplican) sin atascos en terreno accidentado.
- [ ] 03.02 La hitbox del jugador (0.6×1.8) no atraviesa paredes ni techos voxel (colisión en 8 direcciones).
- [ ] 03.03 La gravedad funciona: al caer de una montaña el jugador aterriza sin atravesar el terreno.
- [ ] 03.04 El jugador no puede salir del mundo por horizontes (límite invisible/contención).
- [ ] 03.05 🎮 Cambiar el modo de vista/rotación (ESC) mantiene la posición del jugador.
- [ ] 03.06 Edge: agacharse bajo un techo de 1 bloque y pararse no teclipea al techo (validación de colisión superior).
- [ ] 03.07 Edge: movimiento sostenido 30 s contra una pared no causa desincronización de colisión ni jitter.

## Área 04 — Cámara (M12)

- [ ] 04.01 Rotación con el mouse: la cámara orbital sigue al jugador sin clipear el terreno.
- [ ] 04.02 Zoom (scroll): funcional y con límites; el spring-arm se acorta en paredes sin mostrar el interior voxel.
- [ ] 04.03 Los 5 modos de cámara (si implementados) alternan sin pérdida de foco ni lags.
- [ ] 04.04 Edge: en espacios cerrados (cueva/casa), la cámara no muestra el exterior del voxel.
- [ ] 04.05 Edge: rotación rápida 360° sin artefactos de jitter en el overhead.

## Área 05 — Herramientas (M13, M35, M158)

- [ ] 05.01 Las 9 herramientas x 4 niveles extraen/colocan el bloque esperado según el tipo (tool→recurso correcto).
- [ ] 05.02 La durabilidad es cozy: ninguna herramienta se rompe; el HUD (M57) refleja el desgaste y cambia colores.
- [ ] 05.03 Cooldown por velocidad de uso: click múltiple rápido no extrae más rápido de lo previsto.
- [ ] 05.04 El área 3×3 y la extracción progresiva multi-golpe funcionan como defiende el diseño del módulo 13.
- [ ] 05.05 🎮 El bloque objetivo inválido (no minable con esa herramienta) no se extrae y el feedback visual lo indica.
- [ ] 05.06 Edge: extraer un bloque justo debajo del jugador no lo hace caer al vacío sin control.
- [ ] 05.07 Edge: con la herramienta en el último golpe, el HUD parpadea y la extracción sigue funcionando.

## Área 06 — Inventario (M14)

- [ ] 06.01 Con inventario vacío, al recolectar un objeto se abre el slot 0 con el item correcto (id y cantidad).
- [ ] 06.02 Con 30 slots llenos, al recolectar se muestra el aviso de inventario lleno y el item NO se pierde (queda en el suelo o se cancela con feedback).
- [ ] 06.03 El stacking respeta el máximo por stack definido; no excede el límite del item.
- [ ] 06.04 Arrastrar y soltar un slot sobre otro intercambia/agrupa correctamente (2 clics, sin clicks fantasma).
- [ ] 06.05 La hotbar refleja el inventario en tiempo real (bidireccional) y se actualiza al recolectar/consumir.
- [ ] 06.06 Al abrir el inventario con el mundo running, el mundo queda congelado y se descongela al cerrar (sin acumulación de tiempo).
- [ ] 06.07 Edge: se intenta usar un item con id inválido (`""`) y no crashea; el log M103 registra la advertencia.
- [ ] 06.08 Edge: cargar un guardado con inventario corrupto recupera/ignora con log sin crash (M59/M60).
- [ ] 06.09 Edge: abrir/cerrar el inventario 50 veces seguidas no crea nodos huérfanos ni degrades de FPS (M61).

## Área 07 — Recursos (M15)

- [ ] 07.01 Cada recurso se obtiene SOLO con la herramienta correcta (piedra→pico, madera→hacha, planta→manos/tijeras).
- [ ] 07.02 Las rarezas de recursos aparecen en las biomas/alturas que definen sus tablas (M93).
- [ ] 07.03 El respawn de recursos funciona según el diseñado (respawn con día + filtro estacional) sin duplicar nodos.
- [ ] 07.04 🎮 Fijar el tiempo/clima con M110 y verificar que el filtro estacional de respawn responde.
- [ ] 07.05 Edge: golpear un recurso sin la herramienta correcta da feedback y NO destruye el nodo.
- [ ] 07.06 Edge: extraer todos los recursos de una zona y verificar que el respawn respeta el día del calendario (M29).

## Área 08 — Crafting (M16)

- [ ] 08.01 Toda receta del catálogo, con los requisitos cumplidos, produce el item esperado con cantidades correctas.
- [ ] 08.02 Sin requisitos cumplidos, la receta se muestra bloqueada con razón clara (no es arbitraria).
- [ ] 08.03 El estacionalismo (RF5): recetas estacionales solo aparecen/producen en su estación (M29).
- [ ] 08.04 Los pergaminos/recetas desbloqueadas (M14) funcionan; craftear consume los insumos y no lo duplicados usa.
- [ ] 08.05 Edge: craftear con inventario lleno no pierde items; aviso y bloqueo del craft.
- [ ] 08.06 Edge: craftear con cantidades exactas en el borde (stack de 1) deja el slot vacío y no queda item fantasma.
- [ ] 08.07 Edge: la receta de un item id patrón (`coste_recursos`) valida contra los IDs reales del catálogo (M159); sin recetas fantasma.

## Área 09 — Construcción y casas (M17, M18)

- [ ] 09.01 Colocar un bloque en posición válida funciona y ocupa la celda voxel correcta (sin solaparse con el jugador).
- [ ] 09.02 Colocar posición inválida (dentro del NPC/agua prohibida/aire sin apoyo si aplica) se rechaza con feedback.
- [ ] 09.03 Desmontar una estructura devuelve el bloque al inventario y no deja restos invisibles.
- [ ] 09.04 Las casas utilizables (puerta, ventana, techo) se pueden cerrar/abrir y pasar de a pie sin clipeo.
- [ ] 09.05 Edge: construir al límite del render distance (frontera de chunk) no corrompe la zona cargada.
- [ ] 09.06 Edge: dejar la estructura abierta (sin techo completo) no rompe el conteo de exposición al clima M33.
- [ ] 09.07 🎮 Construir 100 bloques en cadena no degrada el FPS por encima del presupuesto (M61).

## Área 10 — NPC y vecinos (M19, M20)

- [ ] 10.01 Cada NPC con perfil tiene su rutina (trabajo/social/comer/vagancia) y se mueve según ella sin congelarse.
- [ ] 10.02 Los NPC se apegan al terreno (snap con get_height) y no flotan ni se hunden al caminar.
- [ ] 10.03 Regalar un item a un NPC: la amistad avanza, la reacción corresponde (M21) y el item se consume.
- [ ] 10.04 El sistema de mudanzas (propuesta→aprobación→llegada→partida) respeta el calendario y la persistencia (M59).
- [ ] 10.05 La línea de visión F (raycast) detecta correctamente obstrucciones (monte el NPC detrás de un muro y la interacción no se dispara).
- [ ] 10.06 Edge: regalar el mismo item repetido no supera el nivel esperado (regla de cooldown/amistad M20/M93).
- [ ] 10.07 Edge: cargar un guardado con NPCs en movimiento los reposiciona sin duplicados (purgado de huérfanos M59).
- [ ] 10.08 Edge: simular que un NPC parte con el sistema de tiempo y verificar que su estado persiste al recargar.

## Área 11 — Diálogos (M21, M22, M23)

- [ ] 11.01 Cada grafo de diálogo arranca en su nodo `start` y no termina en vacío (validador de grafo sin huérfanos).
- [ ] 11.02 Los árboles no tienen loops; las opciones con efectos (world/flag_*) aplican correctamente.
- [ ] 11.03 Las condiciones de mundo (estación, hora, amistad, banderas) filtran el diálogo correctamente (WorldState).
- [ ] 11.04 La historia principal (7 sellos) avanza con el gate correcto (requisitos capítulo/sellos/objeto) y persiste.
- [ ] 11.05 Los eventos de diálogo (regalo, cambio de botón/lanzamiento de amistad) aparecen una sola vez y auto-finalizan.
- [ ] 11.06 Edge: entrar y salir del diálogo con la tecla de cierre no deja el mundo bloqueado ni input atascado.
- [ ] 11.07 Edge: repetir un regalo duplicado ramifica en la reacción R_DUPLICADO sin romper el grafo.
- [ ] 11.08 🔍 Los nodos inválidos del grafo (referencia a id inexistente) se reportan una vez por sesión.

## Área 12 — Templos y puzzles (M24, M25, M26)

- [ ] 12.01 Función emisor→receptor: al activar el emisor, la puerta/receptor reacciona en el mismo frame y notifica (no requiere re-habilitar nada).
- [ ] 12.02 Los checkpoints del subtemplo (5 atómicos) guardan al pasar y restauran correctamente (M59).
- [ ] 12.03 Las ruinas progresan en sus 4 estados (no se registran los estados por artefactos de la cámara).
- [ ] 12.04 Edge: activar los emisores en orden arbitrario (sin validar arbitrariedad) no deja el puzzle sin solución.
- [ ] 12.05 Edge: morir/quedar atrapado en un templo (anti-softlock M66) recupera al jugador sin corromper estado.
- [ ] 12.06 🎮 Teletransportarse a mitad de un puzzle no deja switches con estado inconsistente tras recargar.

## Área 13 — Islas y viajes (M27, M28, M69)

- [ ] 13.01 Con el requisito de viaje cumplido (flag M22 + boleto M38), el viaje se inicia y mueve al jugador a la isla destino.
- [ ] 13.02 Sin requisitos (sin sello, sin boleto, noche prohibida, temporada incorrecta) se rechaza con feedback claro (sin excepciones).
- [ ] 13.03 Desembarcar posiciona al jugador sobre el terreno de la isla destino (no en el agua).
- [ ] 13.04 El viaje activo persiste a mitad de ruta (M59) y al cargar continúa sin duplicar al jugador.
- [ ] 13.05 Fast travel (M69): se desbloquea por anclas/sellos y funciona sin atravesar geometría (si está implementado).
- [ ] 13.06 Edge: cancelar un viaje con reembolso devuelve el boleto y NO deja al jugador en un lugar nulo.
- [ ] 13.07 Edge: el clima adverso retrasa pero nunca bloquea el viaje (regla cozy M32).

## Área 14 — Tiempo y calendario (M29, M30, M31)

- [ ] 14.01 El día dura ~24 min; el tick se mantiene sin drift al pausar/cerrar menús.
- [ ] 14.02 Las esto aparece calendario: 4 estaciones + fecha correcta; los eventos por fecha (festivales) aparecen el día correcto.
- [ ] 14.03 Las 5 franjas día/noche (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA) emiten la señal de cambio de fase y la luz responde.
- [ ] 14.04 Anti-oscuridad: en NOCHE PROFUNDA la pantalla nunca queda bajo el piso 0.15 (playable sin linterna, con opción M58).
- [ ] 14.05 Avanzar/atrasar la hora con el debug menu recalcula clima y luz sin saltos raros (M110).
- [ ] 14.06 Reloj en tiempo real (M30): el widget refleja la hora del mundo y del sistema correctamente, sin blur en el juego.
- [ ] 14.07 Edge: avanzar 30 días seguidos no corrompe el calendario (años bisiestos no aplican; fin de año correcto).
- [ ] 14.08 Edge: el juego funciona con el SO en cambio horario sin saltos del reloj relativo (M30/G113).

## Área 15 — Clima (M32)

- [ ] 15.01 El clima sigue la semilla+día determinista: mismo día siembra misma secuencia de clima.
- [ ] 15.02 Regla cozy: nunca 2 climas profundos/serios seguidos (tormenta tras tormenta sin pausa).
- [ ] 15.03 El clima persiste correctamente al guardar/cargar (recomputed del día gana).
- [ ] 15.04 El clima afecta las actividades según diseño: la lluvia riega cultivos (M33), bono en pesca (M34), sin prohibiciones.
- [ ] 15.05 Edge: cambio de clima durante un diálogo/viaje no congela el mundo ni rompe el script de eventos.
- [ ] 15.06 🔍 EventBus.weather.emite clima_cambio una sola vez por cambio (sin dobles señales M32/M33).

## Área 16 — Actividades (M33, M34, M35)

- [ ] 16.01 Agricultura: labrar, plantar, regar (con lluvia automática), madurar y cosechar un cultivo completo sin excepciones.
- [ ] 16.02 Agricultura: el techado (M17/M18) protege de la lluvia (tile expuesto correcto).
- [ ] 16.03 Pesca: el minijuego/casting funciona; el pez capturado entra al inventario con el peso/tamaño según bono de clima.
- [ ] 16.04 Minería: extraer una veta con la herramienta correcta da el mineral; T3+ da doble drop (RF6).
- [ ] 16.05 Minería: el límite suave por zona (12/día) avisa y deja de dar en la misma zona (RF10).
- [ ] 16.06 🎮 Fijar día/clima para probar estacionalidad: cultivos estacionales maduran solo en su estación.
- [ ] 16.07 Edge: pescar con clima TROPICAL: los peces preferentes/raros tienen el peso multiplicado sin filtrar (nunca prohibido).
- [ ] 16.08 Edge: ciclo completo de agricultura en invierno no da cultivos de verano y muestra el estado correcto.

## Área 17 — Fauna y museos (M36, M37)

- [ ] 17.01 Los animales respetan su bioma y rutina (FSM); no se congelan en caminos de NPC.
- [ ] 17.02 La donación al museo de un item y su exhibición muestra el progreso por sala; la recompensa única se otorga una vez.
- [ ] 17.03 El museo purga donaciones inválidas (duplicado/no poseído/exposición incorrecta) sin consumir el item.
- [ ] 17.04 Edge: donar con inventario lleno no pierde el item (rollback cozy).
- [ ] 17.05 Edge: recargar con la exhibición ya completa no da doble recompensa.

## Área 18 — Economía y tiendas (M38, M39, M70)

- [ ] 18.01 Comprar un item: el dinero disminuye, el item va al inventario y la tienda actualiza su stock.
- [ ] 18.02 Vender un item: el dinero aumenta y el item desaparece del stack (sin duplicados).
- [ ] 18.03 El precio usa la tabla real (econ_prices.tres) — nunca precios 0 o tablas no cargadas — con recargo del mercader viajero correcto.
- [ ] 18.04 Edición de tiendas: 20-items sin recetas falsificadas (sin artículos con ids inexistentes).
- [ ] 18.05 Trueque (M38/Barter): la propuesta respeta amistad/temporada; la ejecución atómica no duplica ni pierde items.
- [ ] 18.06 Interactuar con cualquier objeto `IInteractable` (M70): la prioridad por distancia/registro es correcta (estado).
- [ ] 18.07 Edge: dinero en 0: la compra se bloquea con feedback (no crashea ni crea saldo negativo).
- [ ] 18.08 Edge: comprar el último stack de la tienda y revisar el precio/stock del recargo y descuento de amistad.

## Área 19 — Audio (M41-M44)

- [ ] 19.01 La música sigue la matriz de contexto (base+tiempo+evento); cambia al atravesar cada sistema.
- [ ] 19.02 Los efectos de sonido responden correctamente: feedback positivo/negativo/neutro con prioridad correcta (pool 24 voces).
- [ ] 19.03 El audio ambiental se apaga/atraviesa por realidad en interiores con oclusión correcta (si aplica).
- [ ] 19.04 Edge: 30 efectos en simultáneo (batería de pruebas) no generan buzz/clipping (blacklist anti-agresión M44).
- [ ] 19.05 Toca cortante: los niveles de los 7 buses responden a la configuración M91 y la música se detiene al silenciar.

## Área 20 — UI/UX (M53, M57, M88, M89)

- [ ] 20.01 Navegación de menús: teclado/mouse/gamepad caminan todos; no hay atajos atascados.
- [ ] 20.02 Los prompts en pantalla se mueven al dispositivo con mensaje (teclado→teclas, gamepad→iconos).
- [ ] 20.03 Ninguna en el contexto de la UI: no hay texto en blanco (fuente global aplicada), ni solapamiento de labels en resoluciones 1080p y 720p.
- [ ] 20.04 El tooltip aparece con retraso correcto y se oculta sin bloquear el input.
- [ ] 20.05 Los toasts/notificaciones aparecen y se desvanecen sin solaparse entre capas modales.
- [ ] 20.06 Edge: al cambiar la resolución en vivo, la UI no se descuadra y el ratón no se desalinea.
- [ ] 20.07 Edge: abrir un popup (inventario) encima de otro (mapa/hotbar) respeta la pila de capas (M53).

## Área 21 — Accesibilidad (M58)

- [ ] 21.01 Tamaño de texto al máximo no rompe ningún menú; al mínimo sigue legible (R1-R8 de M58).
- [ ] 21.02 El contraste 100: elementos interactivos perceptibles sin colores vibrantes.
- [ ] 21.03 Daltonismo: el modo correspondiente cambia paleta y ningún feedback depende solo de color (símbolos en paralelo).
- [ ] 21.04 Reducción de efectos: partículas y flashes se reducen y la visibilidad no depende de ellas.
- [ ] 21.05 FPS: el juego sigue siendo jugable con accesibilidad máxima (escaneo de sensibilidad sin fallos).

## Área 22 — Memoria y streaming (M61, M62, M63)

- [ ] 22.01 🔍 30 min de sesión sin acarreo de memoria (M103/M61: memoria estable post-sesion).
- [ ] 22.02 Con el profiling de M61 activado, el presupuesto de 16,7 ms no se excede en bloquología media (tolerancia 10%).
- [ ] 22.03 El de un mundo grande: streaming de ocean/closets no duplica el viento físico sino donde se camina.
- [ ] 22.04 Edge: entrar a una zona de streaming varias veces no acumula meshes ni recursos (LRU con tope).

## Área 23 — IA (M64, M65)

- [ ] 23.01 Los NPC con rutina diaria cumplen su plan (trabajo/social/comer/dormir) sin cruces de rutas.
- [ ] 23.02 Necesidades (hambre/energía/social) se actualizan y alteran el estado de forma coherente (sin spam de burbujas).
- [ ] 23.03 Anti-atascos: un NPC bloqueado por el jugador o la geometría se libera por sí mismo en un tiempo máximo.
- [ ] 23.04 Con NPCs en la burbuja de simulación fuera de pantalla, el estado persiste al entrar a la burbuja (sin congelar).
- [ ] 23.05 Edge: la función de regalo/trade aumenta `amistad` y la IA reacciona sin crashear (M20/M21).

## Área 24 — Anti-softlock y guardado (M66, M59)

- [ ] 24.01 Guardar→recurrir→cargar: el estado del mundo (posición, inventario, progreso, banderas) es idéntico.
- [ ] 24.02 El guardado usa el contrato `ISaveProvider` (M59) correctamente; no lanza excepciones con providers de nodos (M60).
- [ ] 24.03 Auto-save: al fin de día, al completar misión y al cerrar el juego, el guardado es consistente y no interrumpe el diálogo.
- [ ] 24.04 El cofre de recuperación (M66) puede ser usado por un jugador salido del mundo y permite salir del estado.
- [ ] 24.05 Edge: cargar un save viejo (versión anterior del formato) avisa/migra sin crashear (M60 Versionador).
- [ ] 24.06 Edge: interrumpir el guardado (matar el proceso a mitad) no corrompe el slot (Writer atómico .tmp/.bak).

## Área 25 — Tutorial y progresión (M92, M71)

- [ ] 25.01 El tutorial aparece en el momento correcto (primer item/bloque/regalo) y no se duplica.
- [ ] 25.02 Los capítulos no disparan si la señal viene de un sistema no implementado (degradación limpia de M92).
- [ ] 25.03 El watchdog anti-softlock (120 s) no molesta ni se repite si el jugador está trabajando.
- [ ] 25.04 [ ] La progresión almacenada (logros M71/M72, desbloqueos) persiste correctamente en el guardado.

## Área 26 — Configuración gráfica y audio (M90, M91)

- [ ] 26.01 Los 4 presets gráficos (bajo/medio/alto/ultra) modifican la calidad real y no crashean al aplicar en vivo.
- [ ] 26.02 La detección de hardware recomienda un preset coherente con las especificaciones (M115).
- [ ] 26.03 Los 7 buses de audio responden a los sliders (master/música/SFX/ambiente/voice/UI/cinematics).
- [ ] 26.04 La configuración se persiste al cerrar y se restaura al abrir (M60 GestorConfig).
- [ ] 26.05 Edge: aplicar cambios de gráfica dentro de una partida en curso mantiene el mundo estable (sin recarga forzada).

## Área 27 — Debug menu (M110) — herramienta de QA

- [x] 27.01 🎮 Lab: el menú abre con el atajo definido (F12 — el atajo real; el diseño decía F1/backtick, corregido) y la tecla no queda atascada. Verificado 2026-09-01 por evidencia de log [DBG] Debug menu abierto (apertura en runtime); la captura visual es inviable con la ventana ocluida (D3D12 suspende la presentación, ver guia-para-agentes §hallazgos V4).
- [ ] 27.02 🎮 El teletransporte a 3 coordenadas (una en cada bioma) posiciona correctamente al jugador.
- [ ] 27.03 🎮 Dar objetos al inventario funciona (se usan `GrantItem` a un stack/empty; no duplica ni sobrecarga).
- [ ] 27.04 🎮 Fijar hora (día/franja) y clima (7 normas aplicables) recalcula el estado global.
- [ ] 27.05 El diagnóstico exportado (RF20) genera un archivo legible para adjuntar a un issue M102.
- [ ] 27.06 🔍 El menú está **deshabilitado** en builds de release (ver verificación de build M118/preset release).

---

## Estados de borde transversales (verificar en cada hito que los aplique)

- [ ] EB.01 Bug no reproducible: se reporta `NO REPRODUCIDO` con condiciones + semilla y se reintenta en la siguiente sesión.
- [ ] EB.02 Bug solo en plataforma X: se registra SO/GPU y se prueba en las 3 de escritorio (Windows/macOS/Linux) si está disponible.
- [ ] EB.03 Save con datos viejos: cargar con guardado de versión anterior funciona (M60), migrando o advirtiendo.
- [ ] EB.04 Save corrupto: el juego se recupera sin crash y loguea la advertencia (M103) — nunca pantalla negra.
- [ ] EB.05 Semillas 0, 42 y aleatoria: los 3 mundos generan igual de bien (sin mutaciones de balance).
- [ ] EB.06 Inventario lleno en todos los sistemas receptores (recolección, crafting, regalos, compra): feedback + no pérdida.
- [ ] EB.07 Moneda en 0 en todas las acciones económicas: bloqueo con feedback, saldo nunca negativo.
- [ ] EB.08 Noche profunda: el juego es jugable (anti-oscuridad + linterna + opción M58).
- [ ] EB.09 Frontera de chunk en todas las direcciones: sin costuras ni caídas.
- [ ] EB.10 Carga de chunk faltante (streaming): regeneración sin excepciones (M63).
- [ ] EB.11 IA en estado inválido: el NPC se re-sincroniza sin quedar congelado (M64 watchdog).
- [ ] EB.12 Reset a fábrica de configuración: el juego arranca con valores por defecto sin errores.

## Actualización del checklist

- Tras cada hito (M137-M141), revisar este checklist: agregar ítems de módulos nuevos, eliminar los obsoletos (pueden [x] sin volver a probar) y registrar la fecha de revisión aquí arriba.
- Los ítems marcados `[?]` deben ir acompañados de la razón (no verificable en esta build) y el dueño.
