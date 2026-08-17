**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

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

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
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