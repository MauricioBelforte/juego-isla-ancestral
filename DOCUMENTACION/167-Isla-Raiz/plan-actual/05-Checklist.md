**Modelo:** Hy3
**Plataforma:** Kilo

# 05-Checklist.md — Módulo 167: Isla Raíz — Isla Raíz — Registro del Terreno y Posicionamiento

> Estados: [x] cumplido · [ ] pendiente · [?] no resuelto. Marcadores: [S] simple, [M] medio, [C] complejo.

## A. Configuración del terreno (fuente de verdad)

- [x] Documentar que el centro de la isla es (island_radius, island_radius) [S]
- [x] Documentar que el radio 256 produce una isla visible y completa [S]
- [x] Explicar que con radio 2048 se ve "pasto infinito" [S]
- [x] Documentar el valor exacto de `world_seed` (42) [S]
- [x] Documentar el valor exacto de `island_radius` (256) [S]
- [x] Documentar el valor exacto de `max_height` (40) [S]
- [x] Documentar el spawn del jugador (256, 16, 256) [S]
- [x] Documentar el VoxelViewer inicial (256, 30, 256) [S]
- [x] Documentar que el spawn debe estar en el centro [M]
- [x] Documentar el perfil en capas del get_height [M]
- [x] Documentar que la ladera llega EXACTAMENTE a la planicie (sin muros) [M]
- [x] Documentar la paleta Maldivas (colores de la library) [M]
- [x] Documentar el bloque SHALLOW_WATER (turquesa, id 30) [M]
- [x] Documentar el azul océano claro del agua profunda [S]
- [x] Documentar el verde #55711E del pasto [S]

## B. Cámara (follow_camera.gd)

- [x] Documentar que la cámara sigue al jugador [S]
- [x] Documentar el fix del target (reintento en _physics_process) [M]
- [x] Documentar el fallback por nombre "Player" [S]
- [x] Documentar el rango de pitch (-10 a 60) [S]
- [x] Documentar el rango de zoom (4 a 20) [S]
- [x] Documentar la rotación con mouse capturado [S]
- [x] Documentar la colisión con el terreno [M]
- [x] Explicar el bug "no me veo" (target null en _ready) [M]
- [x] Documentar la solución al bug "no me veo" [M]

## C. Spawn del jugador

- [x] Documentar que el spawn debe calcularse con get_height [M]
- [x] Documentar la función _ajustar_spawn_superficie [M]
- [x] Documentar que no se debe usar Y fija [M]
- [x] Documentar el error de spawn en el mar (radio desalineado) [M]
- [x] Documentar la corrección del spawn hardcodeado (256,256) [M]
- [x] Explicar por qué el jugador nacía en el borde (radio 2048 vs spawn 256) [C]
- [x] Documentar la solución: spawn en el centro real del radio actual [M]

## D. Posicionamiento de objetos

- [x] Documentar el método robusto (get_height + 1) [M]
- [x] Documentar que el snap del NPC crea su propio generador [M]
- [x] Documentar que el radio del snap debe coincidir con el mundo [M]
- [x] Documentar el uso de call_deferred para posicionar [M]
- [x] Documentar el mapa de ubicaciones (jugador, Catalina, ruina) [M]
- [x] Documentar que Catalina está en (268, 268) [S]
- [x] Documentar que la ruina está en (660, 660) [S]
- [x] Excluir posicionamiento de M160/M161 (diseño) [S]

## E. Recovery / Troubleshooting

- [x] Documentar el caso: spawn en el mar → revisar radio vs spawn [M]
- [x] Documentar el caso: pasto infinito → radio muy grande (2048) [M]
- [x] Documentar el caso: NPC flotante → radio del snap desalineado [M]
- [x] Documentar el caso: cámara no sigue → revisar target [M]
- [x] Documentar la regla de verificar valores con grep (no asumir) [M]
- [x] Documentar que los .replace() no fallan si no encuentran el string [M]

## F. Verificación técnica

- [x] El proyecto compila sin errores tras el cambio de radio 256 [S]
- [x] El juego corre (FPS 60) con la isla radio 256 [S]
- [x] El jugador aparece sobre la montaña, no en el mar [S]
- [x] El plato de arena es visible [S]
- [x] El agua turquesa es visible al horizonte [S]
- [x] La cámara sigue al jugador correctamente [S]
- [x] El NPC Catalina está sobre el terreno (snap) [S]
- [x] El diálogo con F funciona [S]

## G. Integración con otros módulos

- [x] Registrar que el módulo 167 es la plantilla para nuevas islas [M]
- [x] Documentar la relación con M08/M09/M10 (mundo voxel) [S]
- [x] Documentar la relación con M12 (cámara) [S]
- [x] Documentar la relación con M19 (NPC) [S]
- [x] Documentar la relación con M160 (ubicaciones) [S]

## H. Proceso de creación (futuras islas)

- [x] Definir el ID del módulo de cada isla futura [S] — M168 template
- [x] Documentar el terreno fijo de cada isla (radio, perfil, paleta) [M] — M168 template
- [x] Mapear las posiciones de objetos de cada isla [M] — M168 template
- [x] Documentar el recovery de cada isla [M] — M168 template
- [x] Establecer esta plantilla como base [M]
- [ ] Crear un script de validación del terreno (opcional) [C]

## I. Lecciones aprendidas (refuerzo)

- [x] El problema dominante fue asumir valores en vez de verificar [M]
- [x] La isla ideal es chica (256), no el perfil [M]
- [x] El centro es (radio, radio), no (0,0) [M]
- [x] La cámara reintenta el target [M]
- [x] `get_height` es la única forma de posicionar sobre el terreno [M]

## Total de ítems: 100+


## J. Documentación del estado actual (2026-08-29)

- [x] Documentar que la Isla Raíz usa radio 256 y spawn en (256,256) [S]
- [x] Documentar que Catalina (NPC) se posiciona con snap a get_height [M]
- [x] Documentar el botón T (teleport dev junto a Catalina) [S]
- [x] Documentar la tecla C (descender al suelo) [S]
- [x] Documentar la tecla ESPACIO (saltar, flota en dev) [S]
- [x] Documentar la velocidad dev 25 (y cómo volver a 5) [S]
- [x] Documentar que la velocidad dev se fuerza en _ready (el tscn pisa el @export) [M]
- [x] Documentar el bloque SHALLOW_WATER (id 30) en BlockType [M]
- [x] Documentar el efecto de los colores Maldivas en la library [S]
- [x] Documentar el orden de capas: montana -> plato -> agua clara -> agua profunda [M]

## K. Mantenimiento del mundo

- [ ] Revalidar el terreno tras cada cambio de radio [M]
- [ ] Revalidar el snap de los NPC tras cada cambio [M]
- [ ] Revalidar la camara tras cada cambio de player [M]
- [ ] Documentar cambios del perfil en 03-Diseno [M]
- [ ] Actualizar el mapa de posiciones al agregar objetos [M]
- [ ] Registrar en el log cuando el terreno cambie [M]
- [ ] Verificar que la paleta no se rompa al agregar bloques [M]
- [ ] Usar el generador del mundo (no clones) para posicionar [M]
- [ ] Mantener la semilla fija (42) para terreno determinista [S]

## L. Verificación visual (con vision M154)

- [ ] Capturar el terreno tras cada cambio para revisar [M]
- [ ] Verificar que la montana no tenga muros verticales [M]
- [ ] Verificar que el plato de arena este plano [S]
- [ ] Verificar que el agua clara sea pisable [M]
- [ ] Verificar que el agua profunda sea azul [S]
- [ ] Verificar que el jugador no aparezca en el mar [S]
- [ ] Verificar que Catalina no flote [S]
- [ ] Verificar que la camara siga al jugador [S]
- [ ] Verificar el dialogo con F [S]

## M. Gestion de la plantilla

- [x] Definir el formato del modulo terreno (README + 5 archivos) [M]
- [x] Establecer 03-Diseno como fuente de verdad del terreno [M]
- [x] Establecer el mapa de posiciones como referencia [M]
- [x] Establecer el procedimiento de recovery [M]
- [x] Documentar como crear una isla nueva con la plantilla [M]
- [ ] Crear el primer modulo de isla futura (cuando aplique) [M]
- [ ] Validar que el modulo 167 sea usable por otro agente [M]
