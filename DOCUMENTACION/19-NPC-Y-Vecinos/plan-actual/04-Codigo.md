**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

# 04-Codigo.md — Módulo 19: NPC y Vecinos

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/villagers/villager_manager.gd` | Autoload (`VillagerManager`) | Autoridad de la población: activos, plazas, mudanzas, interacción, persistencia |
| `res://src/villagers/villager.gd` | Escena + script (`Villager`) | Instancia runtime de un vecino activo |
| `res://src/villagers/villager_mood.gd` | Componente (`VillagerMood`) | Estado emocional (base persistida + deltas calculados) |
| `res://src/villagers/villager_dialogue_hook.gd` | Componente (`VillagerDialogueHook`) | Contrato hacia M21 (líneas, respuestas, cierre) |
| `res://src/villagers/villager_profile.gd` | `Resource` (`VillagerProfile`) | Hoja de datos del vecino |
| `res://src/villagers/villager_catalog.gd` | `Resource` / singleton de datos | Registro de candidatos (mayor al límite activo) |
| `res://src/villagers/parcela_marker.gd` | Componente de escena | Marcador de parcela/hogar en terreno vóxel (Voxel Tools) |
| `res://data/villagers/*.tres` | Data | Perfiles de los ~14 candidatos (10 activos + 4 rotación) |
| `res://data/villagers/catalog.tres` | Data | Catálogo de candidatos |

### Estructura de escenas prevista

```
res://scenes/villagers/
├── villager.tscn            # base: Node3D + mesh vóxel + Villager + VillagerMood + VillagerDialogueHook
├── villager_palette.tscn    # variante de silueta por especie (referenciada por silueta)
├── casa_vecino.tscn         # casa base prefab + ParcelaMarker
└── indicador_interaccion.tscn  # burbuja "F" sobre cabeza (UI world-space)
```

## 2. Funciones Clave (firmas GDScript)

```gdscript
# villager_manager.gd — autoload VillagerManager
func _ready() -> void                          # carga catálogo, suscribe a input F y a M29
func obtener_activos() -> Array[Villager]      # vecinos presentes en la isla
func obtener_vecino(id: String) -> Villager    # null si no existe
func plaza_libre() -> bool                     # activos.size() < POBLACION_MAX (10)
func proponer_mudanza(candidato_id: String) -> void   # visita a la isla
func aprobar_mudanza(candidato_id: String) -> void    # permiso del jugador (RF2)
func cancelar_mudanza(candidato_id: String) -> void   # limpio en cualquier fase
func anunciar_partida(vecino_id: String) -> void      # aviso 1 día antes
func aceptar_partida(vecino_id: String) -> void
func rechazar_partida(vecino_id: String) -> void      # enfriamiento 30 días
func entregar_regalo(vecino_id: String, objeto_id: String) -> void  # RF5
func detectar_objetivo(pos_jugador: Vector3) -> Villager  # rango 2.5 m + raycast vóxel
func _unhandled_input(evento: InputEvent) -> void     # tecla F → interactuar (RF4)
func guardar() -> Dictionary                    # VillagerSaveData
func cargar(datos: Dictionary) -> void          # valida IDs contra catálogo

# villager_profile.gd — VillagerProfile (Resource)
func evaluar_objeto(objeto_id: String) -> float # gustos +1.0 / disgustos -0.5 / neutro 0.0
func proxima_franja(hora: float) -> String      # clave de rutina activa

# villager_mood.gd — VillagerMood
func aplicar_delta(delta: float, causa: String) -> void   # clamp(-1.0, 1.0)
func factor_dialogo() -> float                  # tono de líneas para M21
func estado_emocional() -> String

# villager_dialogue_hook.gd — VillagerDialogueHook
func solicitar_dialogo() -> void                # emite linea_solicitada
func notificar_cierre() -> void                 # emite conversacion_terminada
func linea_reaccion_regalo(objeto_id: String) -> void  # RF5 respuesta textual

# villager.gd — Villager
func interactuar(jugador: Node3D) -> void
func recibir_regalo(objeto_id: String) -> void
func set_ocupado(ocupado: bool) -> void         # bloquea interacción (dormido/evento)
```

## 3. Suscripciones e Integración

- **Input F:** `VillagerManager._unhandled_input` usa el InputMap de Godot (acción `interactuar`); sin acoplo de UI (AGENTS.md §9).
- **M29:** suscripción a `hora_actual` y `dia_actual` (variaciones de rutina, aviso de partida, PRNG de partida para sentencias de mudanza).
- **M31/M32:** deltas de mood por clima (`lluvia`, `calor`) con señal `clima_cambio`.
- **M21:** `VillagerDialogueHook.linea_solicitada` es consumida por el director de diálogo; M21 responde con `respuestas_disponibles`.
- **M20:** señales `regalo_recibido` y `conversacion_terminada` alimentan puntos de amistad; M20 devuelve `nivel_amistad` para líneas especiales del hook.
- **M25:** líneas con clave `ruina_*` activadas por nivel de amistad (amistad alta revela pista); evento `ruina_descubierta` suma delta de mood.
- **M64:** `VillagerManager.obtener_activos()` es la fuente de agentes de la burbuja; `VillagerProfile.rutina_diaria` alimenta la agenda; el vecino informa `objetivo_actual()` para animación.
- **Voxel Tools:** `ParcelaMarker` coloca el hogar en terreno vóxel; el raycast de detección (F) consulta el `VoxelWorld` para no interactuar a través de paredes.

## 4. Logs Relacionados

- **Logs del protocolo (repositorio):** `Logs/` con la nomenclatura `NN-descripcion_AAAA-MM-DD_HH-MM-SS.md` (sección 6 de AGENTS.md) — generado por el agente para cada cambio de este módulo.
- **Logs de runtime del juego (fuera de Assets; en Godot, `user://logs/`):** prefijo `[VILLAGER]` en `print()`/`push_warning()` para: mudanzas (propuesta/aceptación/partida), regalos evaluados, fallbacks de parcela, detecciones fallidas, validación de guardado.
- **Rotación:** el sistema de rotación de logs (sección 18) mueve archivos a `rotated/` al superar el umbral (ej. 500 KB).
- **Nube de logs:** `push_error` reservado para fallos críticos (catálogo sin perfil, ID huérfano al cargar, parcela no navegable).

## 5. Pendientes de Implementación (dueño: agente implementador)

| Pendiente | Nota |
|---|---|
| Autoload VillagerManager + catálogo de perfiles | Requiere bootstrap Godot 4.4.1 + Voxel Tools |
| Escena villager.tscn por especie | Primera pasada con 4 siluetas (oso, mapache, zorro, rana) |
| Flujo de mudanza completo | Máquina de fases + persistencia |
| Hook de diálogo + contratos M21/M20 | Prototipo con 2 perfiles antes de poblar los 14 |
| Grilla de pruebas de interacción F | Raycast vóxel y rango 2.5 m |
| Integración con M64 (agenda/burbuja) | Tras tener la IA lista (módulo delegable M64) |

## Notas del Agente

**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode
**Fecha:** 2026-08-29 03:00:00
**Estado:** Primer NPC visible e interactuable (snap al terreno + interacción F)

### Lo que hice
- 5 scripts creados en `scripts/npc/`: villager_profile.gd, villager_mood.gd, villager_dialogue_hook.gd, villager.gd, villager_manager.gd
- Primer perfil: `data/villagers/catalina_oso.tres` (oso, cocinera, dulce)
- NPC CatalinaOso spawna en `main_island.tscn` con visual placeholder (cápsula + esfera + Label3D + indicador [F])
- VillagerManager autoload registrado con interacción F (rango 3.0m), gestión de población (max 10)
- Corrección player.gd: 22 referencias a autoloads (Inventario×16, ItemDatabase×6) cambiadas a get_node_or_null() dinámico
- Snap al terreno con IslandGenerator.get_height() directo (VoxelTool.raycast no funciona al inicio — chunks no cargados)
- Offset +1.0 para pies sobre bloque (confirmado por usuario)
- NPC movido de (5,8,5) a (30,10,64) — dentro de la isla (centro 64,64, radio 64)
- Documentados errores §9.44 (VoxelTool raycast sin chunks) y §9.45 (offset NPC +1.0) en 07-GUIA-GODOT.md

### Lo que NO pude hacer (honestidad obligatoria)
- class_name no funciona en este proyecto (razón desconocida) — se usa preload() + duck-typing
- Persistencia de estado de NPCs en guardado (pendiente M59)
- Q&A cruzado del módulo (pendiente)

### Recomendaciones para el próximo agente
- TODO NPC debe usar `get_height()` del IslandGenerator para snap, NUNCA VoxelTool.raycast al inicio
- El island_radius del snap DEL NPC debe coincidir con el del mundo (64 en Isla Raíz)
- Los autoloads no están disponibles en compilación MCP — usar get_node_or_null("/root/Nombre")
- El NPC es CharacterBody3D pero NO llama move_and_slide() — no tiene gravedad propia

## Notas del Agente (plan-inicial)

**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-08-16 21:30:00
**Estado:** Documentación de diseño completa (plan-inicial)

### Lo que hice
- 26/26 puntos de la sección 18 del plan maestro resueltos (ver 05-Checklist.md).
- Arquitectura de 5 clases GDScript (Villager, VillagerManager, VillagerProfile, VillagerMood, VillagerDialogueHook) con desacople total de UI.
- Flujos de mudanza (entrada con permiso / salida con aviso y rechazo), interacción F, regalo y mood especificados.
- Contratos de API estables para consumidores M64, M21, M20, M25.
- 05-Checklist.md con 130 ítems completados.

### Lo que NO hice (honestidad obligatoria)
- Implementar: no hay aún proyecto Godot en el repositorio; la implementación requiere el bootstrap del motor (4.4.1 + Voxel Tools GDExtension). Dueño: AGENTE DELEGADO.
- Datos finales de los 14 perfiles: se sugieren 4 siluetas de prototipo; el balanceo de gustos/rutinas queda para el agente implementador.
- Validación en Play Mode/Press: imposible sin jerarquía de escenas creada.

### Recomendaciones para el próximo agente
- Crear primero el bootstrap Godot y 1 perfil + 1 escena de prueba antes de poblar el catálogo.
- El raycast vóxel del objetivo F es crítico: probarlo en casa con pared de 1 vóxel.
- Mantener la API de las secciones 3-5 sin renombrar: M64 y M21 ya referencian estos contratos.
- Probar la cancelación de mudanza en las 3 fases (propuesta, aprobada, llegada) con tests manuales.

---

## Notas del Agente — Iteración mudanzas + línea de visión (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 00:40:00
**Estado:** Parcial (mudanzas/catálogo/línea de visión implementados y verificados; módulo liberado 🟡)

### Lo que hice
- Población lógica de mudanzas en VillagerManager (diseño §2.1/§3.2): proponer_mudanza (visitante), aprobar_mudanza (llegada agendada día siguiente), cancelar_mudanza (propuesta/aprobada), llegada 08:00 vía GameTime.hora_cambio con _asignar_hogar (índice de parcela libre) y señal vecino_llego + EventBus.npc.npc_moved_in (M20/M21 consumen), anunciar/aceptar/rechazar partida con enfriamiento de 30 días (ENFRIAMIENTO_PARTIDA) y puede_avisar_partida() para M64/M21.
- Catálogo data-driven: 4 perfiles .tres nuevos en data/villagers/ (finneas_zorro pescador/costa, mateo_mapache granjero/pradera, luna_zorra artesana/colina, bruno_sapo carpintero/bosque) siguiendo el formato de catalina_oso; total 5 perfiles (checklist "catálogo mayor que el límite" en progreso — 14 es la meta final).
- Línea de visión (checklist ítem 86): hay_linea_de_vision(desde, hasta) muestreo DDA 0.5 m vía VoxelTool.get_voxel (patrón de raycast de M13), integrada en _intentar_interaccion() y detectar_objetivo() — no se interactúa a través de paredes. Fallbacks de _obtener_terrain ampliados (bootstrap carga la escena manualmente).
- Persistencia ISaveProvider M59 sección "npc" (diseño §5): visitantes/llegadas/partidas/avisos/enfriamientos/hogares; IDs huérfanos eliminados con log al cargar.
- Test scripts/npc/test_mudanzas.gd: catálogo, ciclo completo de mudanza con señales, cancelación en ambas fases, partida con enfriamiento (vencimiento simulado), línea de visión (aire libre/bajo tierra/short-circuit), persistencia → **0 fallos**.
- Regresiones: test_amistad M20 14/0, test_autosave M59 0 fallos.
- Checklist: 9 ítems [x]. Progreso 23→32/131.

### Lo que NO pude hacer (honestidad obligatoria)
- Indicador/burbuja visual de mudanza y aviso (M53) y casas de mudanza visibles (M17/M18): señales listas.
- Rutinas/agenda jugable (M64) y comportamiento M64: rutinas en los perfiles listas para su agenda.
- 14 perfiles del catálogo: 5 hoy (9 restantes, contenido narrativo con dueño).
- Mudanza física del vecino al llegar (spawn/casa 3D): la lógica de población emite vecino_llego; el spawn real depende de M17/M18 (casas) y M64.

### Hallazgos ajenos (no tocados, tienen dueño)
- scripts/interacciones/interaction_manager.gd tiene errores de parse en headless (vars dx/dz/p sin tipo inferible): módulo en curso de otro agente (M70). No lo toqué.

### Recomendaciones para el próximo agente
- M64: consumir obtener_activos() + perfil.rutina_diaria + hogar_de() para la agenda; respetar puede_avisar_partida().
- M53: burbuja de mudanza escuchando mudanza_propuesta, indicador de partida con aviso_partida.
- M17/M18: al existir casas, conectar _asignar_hogar con la posición real de la parcela.
