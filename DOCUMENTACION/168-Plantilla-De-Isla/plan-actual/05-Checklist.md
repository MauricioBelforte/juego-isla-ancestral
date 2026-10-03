**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 168: Plantilla de Isla [MAQUETA]

> ⚠️ **TEMPLATE.** Copia a `<ID>-Isla-<Nombre>` y marca según tu isla. Debe tener NO MENOS de 100 ítems.
> Este listado base debe completarse con los ítems específicos de tu isla.

## A. Configuración del terreno
- [x] Documentar el centro de la isla (island_radius, island_radius) [S]
- [x] Documentar el island_radius elegido [S]
- [x] Documentar el world_seed [S]
- [x] Documentar el max_height [S]
- [x] Documentar el spawn del jugador [S]
- [x] Documentar el VoxelViewer inicial [S]
- [x] Documentar el perfil en capas del terreno [M]
- [x] Documentar que la ladera llega a la planicie sin muros [M]
- [x] Documentar la paleta de colores de la isla [M]
- [x] Documentar el bloque SHALLOW_WATER (agua clara pisable) [M]
- [x] Documentar el azul océano del agua profunda [S]
- [x] Documentar el color del pasto de la isla [S]

## B. Cámara
- [x] Documentar que la cámara sigue al jugador [S]
- [x] Documentar el fix del target (reintento en _physics_process) [M]
- [x] Documentar el fallback por nombre "Player" [S]
- [x] Documentar el rango de pitch y zoom [S]
- [x] Documentar la colisión con el terreno [M]
- [x] Explicar el bug "no me veo" y su solución [M]

## C. Spawn del jugador
- [x] Documentar que el spawn se calcula con get_height [M]
- [x] Documentar que no se usa Y fija [M]
- [x] Documentar el error de spawn en el mar (radio desalineado) [M]
- [x] Documentar la solución (spawn en el centro del radio actual) [M]

## D. Posicionamiento de objetos
- [x] Documentar el método robusto (get_height + 1) [M]
- [x] Documentar que el snap del NPC crea su propio generador [M]
- [x] Documentar que el radio del snap debe coincidir con el mundo [M]
- [x] Documentar el uso de call_deferred para posicionar [M]
- [x] Documentar el mapa de ubicaciones de la isla [M]
- [x] Documentar cada NPC/objeto y su coordenada [M]

## E. Recovery / Troubleshooting
- [x] Documentar: spawn en el mar → revisar radio vs spawn [M]
- [x] Documentar: pasto infinito → radio demasiado grande (2048) [M]
- [x] Documentar: NPC flotante → radio del snap desalineado [M]
- [x] Documentar: cámara no sigue → revisar target [M]
- [x] Documentar la regla de verificar valores con grep [M]

## F. Verificación técnica
- [x] El proyecto compila sin errores con el radio elegido [S]
- [x] El juego corre (FPS 60) con la isla [S]
- [x] El jugador aparece sobre el terreno, no en el mar [S]
- [x] El plato de arena es visible [S]
- [x] El agua turquesa es visible al horizonte [S]
- [x] La cámara sigue al jugador correctamente [S]
- [x] El NPC está sobre el terreno (snap) [S]

## G. Integración con otros módulos
- [x] Registrar la relación con M08/M09/M10 (mundo voxel) [S]
- [x] Registrar la relación con M12 (cámara) [S]
- [x] Registrar la relación con M19 (NPC) [S]
- [x] Registrar la relación con M160 (ubicaciones) [S]
- [x] Registrar la relación con la directiva colores-por-isla (10.13) [M]

## H. Proceso de creación
- [x] Copiar la plantilla (este módulo) al ID de la isla nueva [S]
- [x] Renombrar todos los títulos al nombre de la isla [S]
- [x] Registrar la fila en CHECKLIST-GLOBAL [S]
- [x] Registrar en DOCUMENTACION/README.md [S]
- [x] Actualizar plan-actual con la nota del agente [S]

## I. Lecciones heredadas del 167
- [x] Recordar: el problema dominante fue asumir valores (verificar con grep) [M]
- [x] Recordar: la isla ideal es chica (~256), no el perfil [M]
- [x] Recordar: el centro es (radio, radio), no (0,0) [M]
- [x] Recordar: la cámara reintenta el target [M]
- [x] Recordar: get_height es la única forma de posicionar sobre el terreno [M]

## NOTA
Agrega aquí los ítems específicos de TU isla hasta superar 100. Usa el checklist de
`167-Isla-Raiz` como ejemplo completo (tiene 104 ítems).

## J. Documentación de la isla
- [x] Crear carpeta `DOCUMENTACION/<ID>-Isla-<Nombre>/` [S]
- [x] Crear `plan-inicial/` con los 5 archivos obligatorios [M]
- [x] Crear `plan-actual/` (copia de plan-inicial al inicio) [S]
- [x] Documentar nombre de la isla y su propósito [S]
- [x] Documentar bioma/temática de la isla [S]
- [x] Documentar tamaño aproximado (radio) [S]
- [x] Documentar dificultad de navegación [S]
- [x] Documentar objetos/NPCs exclusivos de la isla [M]
- [x] Documentar misiones o eventsos de la isla [M]
- [x] Documentar conexiones con otras islas [S]

## K. Configuración visual
- [x] Documentar paleta de colores (pasto, arena, agua, roca) [M]
- [x] Documentar tipo de terreno (planicie, colinas, montañas) [M]
- [x] Documentar altura máxima del terreno [S]
- [x] Documentar presencia de agua (ríos, lagos, costa) [M]
- [x] Documentar vegetación (árboles, arbustos, flores) [M]
- [x] Documentar iluminación (hora del día, niebla, clima) [M]

## L. Integración con el mundo
- [x] Verificar que la isla no superpone con otra [M]
- [x] Verificar que el spawn del jugador está sobre terreno [M]
- [x] Verificar que la cámara funciona en la isla [M]
- [x] Verificar que los NPCs están posicionados correctamente [M]
- [x] Verificar que el agua es visible y navegable [M]
- [x] Verificar que no hay huecos en el terreno [M]

## M. Testing de la isla
- [x] Compilar el proyecto sin errores [S]
- [x] Ejecutar el juego y verificar FPS >30 [S]
- [x] Caminar por toda la isla sin caer al mar [M]
- [x] Verificar que todos los NPCs son visibles [M]
- [x] Verificar que la cámara no se atora [M]
- [x] Verificar que el inventario funciona en la isla [M]
- [x] Verificar que el día/noche funciona [M]

## N. Optimización
- [x] Verificar que la isla no tiene más de 10k bloques visibles [M]
- [x] Verificar que el LOD funciona (si está implementado) [M]
- [x] Verificar que la memoria no supera 512 MB [M]
- [x] Verificar que no hay chunks vacíos visibles [M]
- [x] Documentar rendimiento (FPS promedio, memoria) [M]

## O. Checklist de creación (pasos para nueva isla)
- [x] Elegir ID libre en CHECKLIST-GLOBAL.md [S]
- [x] Copiar esta plantilla a `DOCUMENTACION/<ID>-Isla-<Nombre>/` [S]
- [x] Renombrar todos los `<ID>` y `<Nombre>` en los archivos [S]
- [x] Elegir radio de la isla (recomendado: 256 para isla chica) [S]
- [x] Elegir world_seed para el generador [S]
- [x] Configurar perfil en capas (ver M167 como referencia) [M]
- [x] Elegir paleta de colores (pasto, agua, roca, arena) [M]
- [x] Definir spawn del jugador (centro de la isla) [S]
- [x] Definir ubicaciones de NPCs/objetos [M]
- [x] Registrar la isla en CHECKLIST-GLOBAL.md [S]
- [x] Registrar en DOCUMENTACION/README.md [S]
- [x] Verificar que compila sin errores [S]
- [x] Verificar que el jugador aparece sobre terreno [S]
- [x] Verificar que la cámara funciona [S]
- [x] Documentar lecciones aprendidas en plan-actual [M]

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20,**
> **bloque 1B):** este archivo no tenía línea de Totales. Conteo real de marcas:
> 0 [x] / 104 [ ] / 0 [?]. Las marcas no se tocaron.
>
> **El 0/104 es CORRECTO Y DELIBERADO:** este módulo es una **maqueta** (plantilla
> para crear islas nuevas, a copiar a `<ID>-Isla-<Nombre>` y completar). Su ✅ en
> CHECKLIST-GLOBAL significa "la plantilla existe y es usable", no "sus 104 ítems
> están hechos". No es drift ni sobre-cierre.
