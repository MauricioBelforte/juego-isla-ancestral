# Log 370: M19 NPC iter. mudanzas + línea de visión — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 00:50
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración del M19 NPC y Vecinos (F4, dificultad 4, V0/V1) sobre la base de snap+interacción F (auditoría 2026-08-30): población lógica de mudanzas completa, catálogo data-driven de vecinos y raycast de línea de visión para la interacción F. Módulo liberado 🟡 32/131.

## Cambios Realizados

### villager_manager.gd (aditivo)
- Mudanzas (diseño §2.1/§3.2): proponer_mudanza (visitante, sin duplicados), aprobar_mudanza (llegada agendada día siguiente), cancelar_mudanza (fases propuesta/aprobada), llegada a las 08:00 vía GameTime.hora_cambio con asignación de parcela (_asignar_hogar índice libre) y señales vecino_llego + EventBus.npc.npc_moved_in (contrato M07; M20/M21 consumen).
- Partidas: anunciar_partida (aviso 1 día antes, bloqueado por enfriamiento), aceptar_partida (programa día siguiente), rechazar_partida (enfriamiento 30 días ENFRIAMIENTO_PARTIDA), puede_avisar_partida() (consulta para M64/M21).
- Señales nuevas: mudanza_propuesta/mudanza_aprobada/mudanza_cancelada/vecino_llego/aviso_partida/vecino_partio.
- Catálogo data-driven: _cargar_catalogo() lee data/villagers/*.tres; catalogo_count().
- Línea de visión (checklist ítem 86): hay_linea_de_vision() muestreo DDA 0.5 m vía VoxelTool.get_voxel (patrón M13), integrada en _intentar_interaccion() y detectar_objetivo() — no se interactúa a través de paredes. _obtener_terrain() con fallback general para el bootstrap.
- Persistencia ISaveProvider M59 sección "npc" (diseño §5): visitantes/llegadas/partidas/avisos/enfriamientos/hogares; IDs huérfanos purgados con log.

### data/villagers/ (+4 perfiles)
- finneas_zorro (pescador/costa), mateo_mapache (granjero/pradera), luna_zorra (artesana/colina), bruno_sapo (carpintero/bosque) — con rutinas_diaria listas para la agenda de M64, cumpleaños (M20), gustos/disgustos y líneas de diálogo. Total 5 con catalina_oso.

### test_mudanzas.gd (nuevo)
- Catálogo, ciclo completo de mudanza (propuesta→aprobación→llegada con señales y EventBus), cancelación en ambas fases, partida con enfriamiento (vencimiento simulado), línea de visión (aire libre / bajo tierra / línea corta), persistencia round-trip → **0 fallos**.

### Registro
- Regresiones: test_amistad M20 14 checks/0 fallos, test_autosave M59 0 fallos.
- Checklist: 9 ítems [x]. Progreso 23→32/131.

## Hallazgos ajenos (no tocados)

- scripts/interacciones/interaction_manager.gd falla el parse en headless (vars dx/dz/p sin tipo inferible): módulo en curso de otro agente (M70). Reportado en la fila global para su dueño.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/npc/villager_manager.gd` (aditivo)
- `game/isla-ancestral/data/villagers/{finneas_zorro,mateo_mapache,luna_zorra,bruno_sapo}.tres` (nuevos)
- `game/isla-ancestral/scripts/npc/test_mudanzas.gd` (nuevo)
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/04-Codigo.md` (Notas del Agente iter.)
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md` (32/131 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_mudanzas.gd: 0 fallos · test_amistad.gd (M20): 14/0 · test_autosave_m59.gd: 0 fallos (Godot 4.5 headless).
