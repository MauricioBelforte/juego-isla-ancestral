**Modelo:** **[COMPLETAR]**
**Plataforma:** **[COMPLETAR]**

# 05-Checklist.md — Módulo <ID>: <Nombre de la Isla> [MAQUETA]

> ⚠️ **TEMPLATE.** Copia a `<ID>-Isla-<Nombre>` y marca según tu isla. Debe tener NO MENOS de 100 ítems.
> Este listado base debe completarse con los ítems específicos de tu isla.

## A. Configuración del terreno
- [ ] Documentar el centro de la isla (island_radius, island_radius) [S]
- [ ] Documentar el island_radius elegido [S]
- [ ] Documentar el world_seed [S]
- [ ] Documentar el max_height [S]
- [ ] Documentar el spawn del jugador [S]
- [ ] Documentar el VoxelViewer inicial [S]
- [ ] Documentar el perfil en capas del terreno [M]
- [ ] Documentar que la ladera llega a la planicie sin muros [M]
- [ ] Documentar la paleta de colores de la isla [M]
- [ ] Documentar el bloque SHALLOW_WATER (agua clara pisable) [M]
- [ ] Documentar el azul océano del agua profunda [S]
- [ ] Documentar el color del pasto de la isla [S]

## B. Cámara
- [ ] Documentar que la cámara sigue al jugador [S]
- [ ] Documentar el fix del target (reintento en _physics_process) [M]
- [ ] Documentar el fallback por nombre "Player" [S]
- [ ] Documentar el rango de pitch y zoom [S]
- [ ] Documentar la colisión con el terreno [M]
- [ ] Explicar el bug "no me veo" y su solución [M]

## C. Spawn del jugador
- [ ] Documentar que el spawn se calcula con get_height [M]
- [ ] Documentar que no se usa Y fija [M]
- [ ] Documentar el error de spawn en el mar (radio desalineado) [M]
- [ ] Documentar la solución (spawn en el centro del radio actual) [M]

## D. Posicionamiento de objetos
- [ ] Documentar el método robusto (get_height + 1) [M]
- [ ] Documentar que el snap del NPC crea su propio generador [M]
- [ ] Documentar que el radio del snap debe coincidir con el mundo [M]
- [ ] Documentar el uso de call_deferred para posicionar [M]
- [ ] Documentar el mapa de ubicaciones de la isla [M]
- [ ] Documentar cada NPC/objeto y su coordenada [M]

## E. Recovery / Troubleshooting
- [ ] Documentar: spawn en el mar → revisar radio vs spawn [M]
- [ ] Documentar: pasto infinito → radio demasiado grande (2048) [M]
- [ ] Documentar: NPC flotante → radio del snap desalineado [M]
- [ ] Documentar: cámara no sigue → revisar target [M]
- [ ] Documentar la regla de verificar valores con grep [M]

## F. Verificación técnica
- [ ] El proyecto compila sin errores con el radio elegido [S]
- [ ] El juego corre (FPS 60) con la isla [S]
- [ ] El jugador aparece sobre el terreno, no en el mar [S]
- [ ] El plato de arena es visible [S]
- [ ] El agua turquesa es visible al horizonte [S]
- [ ] La cámara sigue al jugador correctamente [S]
- [ ] El NPC está sobre el terreno (snap) [S]

## G. Integración con otros módulos
- [ ] Registrar la relación con M08/M09/M10 (mundo voxel) [S]
- [ ] Registrar la relación con M12 (cámara) [S]
- [ ] Registrar la relación con M19 (NPC) [S]
- [ ] Registrar la relación con M160 (ubicaciones) [S]
- [ ] Registrar la relación con la directiva colores-por-isla (10.13) [M]

## H. Proceso de creación
- [ ] Copiar la plantilla (este módulo) al ID de la isla nueva [S]
- [ ] Renombrar todos los títulos al nombre de la isla [S]
- [ ] Registrar la fila en CHECKLIST-GLOBAL [S]
- [ ] Registrar en DOCUMENTACION/README.md [S]
- [ ] Actualizar plan-actual con la nota del agente [S]

## I. Lecciones heredadas del 167
- [ ] Recordar: el problema dominante fue asumir valores (verificar con grep) [M]
- [ ] Recordar: la isla ideal es chica (~256), no el perfil [M]
- [ ] Recordar: el centro es (radio, radio), no (0,0) [M]
- [ ] Recordar: la cámara reintenta el target [M]
- [ ] Recordar: get_height es la única forma de posicionar sobre el terreno [M]

## NOTA
Agrega aquí los ítems específicos de TU isla hasta superar 100. Usa el checklist de
`167-Isla-Raiz` como ejemplo completo (tiene 104 ítems).
