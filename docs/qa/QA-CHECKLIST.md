# QA-CHECKLIST.md — Checklist Maestro de QA por Área (Módulo 101)

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-02

## Área 1 — Mundo voxel (M08/M09/M10)
- [ ] La generación del mundo no produce errores en consola
- [ ] El terreno se carga alrededor del jugador sin huecos visibles
- [ ] La semilla produce el mismo mundo en cada regeneración (M10)
- [ ] Los chunks se descargan al alejarse (memoria estable, M62)
- [ ] Edge: semilla inválida (negativa) se maneja sin crash

## Área 3 — Jugador (M11/M12)
- [ ] Movimiento fluido sin atascos en terreno normal
- [ ] La cámara sigue al jugador sin clips visibles
- [ ] Al caer al agua el jugador no se queda atascado
- [ ] La vida/energía se muestra correctamente
- [ ] Edge: posición inválida en save se recupera al spawn

## Área 5 — Herramientas (M13/M158)
- [ ] El pico extrae roca correctamente
- [ ] El hacha corta árboles sin quedar atascada
- [ ] La pala prepara la tierra para plantar
- [ ] Las herramientas no se pierden al agotar durabilidad
- [ ] Edge: usar herramienta con id inválido no crashea

## Área 6 — Inventario (M14)
- [ ] Con inventario vacío, al recolectar un objeto se abre el slot 0 con el item correcto
- [ ] Con 30 slots llenos, al recolectar se muestra el aviso de inventario lleno y el item NO se pierde
- [ ] Al hacer click derecho en un stack de item_madera x5 se separa correctamente (si aplica)
- [ ] Al soltar items en el suelo, aparecen como recolectables y se vuelven a tomar
- [ ] Al vender un item en la tienda, el dinero aumenta y el item desaparece del stack
- [ ] Edge: se intenta usar un item con id inválido (id="") y no crashea (log M103 sin error)
- [ ] Edge: se cargan datos de guardado con inventario corrupto y el juego recupera/ignora con log

## Área 7 — Agricultura (M33)
- [ ] Plantar un cultivo con la pala funciona en tierra preparada
- [ ] El cultivo crece con el tiempo de juego (no con tiempo real)
- [ ] Cosechar el cultivo maduro entrega los items esperados
- [ ] El cultivo no muere por falta de riego (cozy, M94)
- [ ] Edge: sembrar en terreno no preparado da feedback claro

## Área 8 — Pesca (M34)
- [ ] Lanzar el anzuelo funciona desde la orilla
- [ ] La captura se realiza con el minijuego correcto
- [ ] Los peces capturados entran al inventario
- [ ] Edge: pescar sin caña no crashea (feedback claro)

## Área 9 — Minería (M35)
- [ ] Extraer mineral de una veta da los items correctos
- [ ] La veta se agota tras N extracciones
- [ ] Edge: minar en altura límite no rompe el mundo

## Área 10 — Guardado (M59/M60)
- [ ] Guardar manualmente escribe el save sin errores
- [ ] Cargar el save restaura posición, inventario y tiempo
- [ ] El auto-save se dispara en los momentos esperados
- [ ] Un save corrupto se detecta y no crashea (checksum M60)
- [ ] Edge: guardar con disco lleno devuelve error sin crash

## Área 11 — Economía (M38/M39)
- [ ] Comprar un item descuenta el precio correcto
- [ ] Vender un item aumenta el dinero correctamente
- [ ] El stock de la tienda se actualiza al comprar
- [ ] Edge: comprar sin dinero suficiente se bloquea con feedback

## Área 12 — Música (M41)
- [ ] La música cambia de tema al cambiar de zona/hora
- [ ] El volumen de música respeta la configuración (M91)
- [ ] Edge: el silencio tras sello no crashea (M150)

## Área 13 — Sonido ambiente (M42)
- [ ] El ambiente del bioma se escucha correctamente
- [ ] La capa de clima se activa al llover
- [ ] Edge: bioma sin banco no produce error

## Área 14 — Efectos (M43/M44)
- [ ] Los SFX de superficie se reproducen al golpear
- [ ] El feedback de acciones (cocinar, plantar) tiene capas
- [ ] Edge: pool de voces lleno descarta sin error

## Área 15 — UI/UX (M53)
- [ ] El inventario se abre/cierra con la tecla correcta
- [ ] La barra de herramientas muestra los items seleccionados
- [ ] El HUD muestra vida, energía y hora correctamente
- [ ] Los menús responden al gamepad (si aplica)
- [ ] Edge: UI con texto truncado se detecta visualmente

## Área 16 — Mapa (M54)
- [ ] El mapa muestra la posición del jugador
- [ ] Los iconos de lugares aparecen al descubrirlos
- [ ] El mapa se puede abrir/cerrar sin bugs

## Área 17 — Diario (M55)
- [ ] El diario registra los objetivos completados
- [ ] Las entradas del diario se guardan/cargan correctamente

## Área 18 — Control (M57)
- [ ] Los controles responden sin retraso
- [ ] La configuración de teclas se guarda (M58)
- [ ] Edge: tecla reasignada se respeta en el juego

## Área 19 — Guardado/Config (M58)
- [ ] La accesibilidad (tamaño texto, subtítulos) se aplica
- [ ] La configuración gráfica se guarda entre sesiones
- [ ] Edge: config corrupta usa defaults sin crash

## Área 20 — Rendimiento (M61/M62/M63)
- [ ] El juego mantiene FPS estables en el mundo base
- [ ] La memoria no crece indefinidamente en sesión larga
- [ ] La carga de escenas no congela la UI (progreso visual)

## Área 21 — Interacciones (M70)
- [ ] Interactuar con un NPC dispara el diálogo correcto
- [ ] Interactuar con un objeto recolectable lo recoge
- [ ] Edge: interactuar con objeto no interactuable no hace nada raro

## Área 22 — Progresión (M71)
- [ ] La experiencia/desbloqueos se acumulan correctamente
- [ ] El nivel del jugador sube al cumplir requisitos

## Área 23 — Amistad (M20)
- [ ] Regalar a un NPC aumenta su amistad
- [ ] El nivel de amistad se muestra correctamente

## Área 24 — Clima (M32)
- [ ] El clima cambia según el calendario
- [ ] La lluvia afecta al mundo visualmente
- [ ] Edge: transición de clima no crashea

## Área 25 — Calendario (M29/M30/M31)
- [ ] El día/noche transcurre a la velocidad correcta
- [ ] El calendario avanza con los días de juego
- [ ] Edge: avanzar muchos días no degrada rendimiento

## Área 26 — Fauna (M36/M65)
- [ ] Los animales aparecen en sus biomas
- [ ] Los animales huyen al acercarse (si aplica)
- [ ] Edge: animal atrapado en geometría se libera

## Área 27 — IA de NPC (M64/M19)
- [ ] Los NPC se mueven por su rutina diaria
- [ ] Los NPC reaccionan al jugador (saludo, diálogo)
- [ ] Edge: NPC en ruta obstruida no se pierde

## Cómo usar este checklist
1. Cada sesión de QA elige áreas según el hito (M137 prototipo → áreas 1,3,5,6,10,15,20).
2. Marcar [x] solo si se verificó realmente. Dejar [ ] con nota si no aplica.
3. Los ítems fallidos se convierten en issues M102 con severidad.
4. El QA-SESSION.md documenta los resultados completos de la sesión.