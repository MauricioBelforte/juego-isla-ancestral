**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 62: Memoria

## 1. Archivos involucrados (previstos) — Pendiente de implementación

| Archivo | Tipo | Rol |
|---|---|---|
| `res://rendimiento/memoria/memory_monitor.gd` | Autoload | Muestreo global, semáforos, drift, getters públicos |
| `res://rendimiento/memoria/memory_budget_registry.gd` | Servicio | Presupuestos por sistema, verificación periódica |
| `res://rendimiento/memoria/global_pool.gd` | Servicio | Pools por familia (obtener/devolver/precalentar/límites) |
| `res://rendimiento/memoria/pool_factory.gd` | Util | Construcción de pools tipados por familia |
| `res://rendimiento/memoria/unload_policy.gd` | Servicio | LRU/distancia/edad, escalonamiento, handshake M63 |
| `res://rendimiento/memoria/chunk_memory.gd` | Nodo | Integración M08: buffers, meshes, colliders, pool `mesh_chunk` |
| `res://rendimiento/memoria/audio_memory.gd` | Nodo | Integración M41-M44: bancos, streaming, tope de voces |
| `res://rendimiento/memoria/texture_memory.gd` | Nodo | Atlas/mips, evicción, detector de texturas sin mips |
| `res://rendimiento/memoria/scene_memory.gd` | Nodo | Tránsito de escenas: drenado de pools, tween/timer cleanup |
| `res://rendimiento/memoria/memory_debug_panel.gd` | UI | Panel del Debug Menu (M110): gráficas y controles |
| `res://rendimiento/memoria/data/budgets.tres` | Data | Topes por sistema y preset (Baja/Media/Alta) |
| `res://rendimiento/memoria/data/pool_config.tres` | Data | Límites y precalentamiento por familia |

> Todos los archivos están **pendientes de implementación** (dueño: AGENTE DELEGADO cuando existan M08 voxel funcional y los presupuestos definitivos de M61).

## 2. API pública prevista (GDScript)

```
## MemoryMonitor (autoload — el único dueño del estado global de memoria)
func memoria_actual_mb() -> float
func memoria_pico_mb() -> float
func objetos_vivos() -> int            # Performance.PERFORMANCE_OBJECT_COUNT
func nodos_huerfanos() -> int          # Performance.PERFORMANCE_ORPHAN_NODE_COUNT
func consumo_de(sistema: StringName) -> int   # MB reportados por el sistema
func presupuesto_de(sistema: StringName) -> int
func semaforo() -> int                 # 0 ok · 1 warning · 2 critico · 3 emergencia
func drift_porciento() -> float
func drift_check() -> bool             # true si drift <= 5% (RN3)
signal semaforo_cambiado(nivel: int)
signal presupuesto_superado(sistema: StringName, consumo_mb: int)
signal recurso_descargar(recurso: Resource, peso: int)
signal recurso_descargado(sistema: StringName, mb_liberados: int)

## BudgetRegistry
func registrar_sistema(nombre: StringName, tope_mb: int)
func reportar_consumo(nombre: StringName, mb: int)
func verificar() -> Array[StringName]  # sistemas sobre su tope

## GlobalPool
func obtener(familia: StringName) -> Node
func devolver(objeto: Node) -> void
func precalentar(familia: StringName, cantidad: int) -> void
func limite(familia: StringName) -> int
func tamanio(familia: StringName) -> int
func liberar_todo() -> void            # drenado en cambio de escena

## UnloadPolicy
func marcar_candidato(recurso: Resource, peso: int, distancia: float = INF) -> void
func ejecutar_descarga(hasta_mb: int, max_por_frame: int) -> int   # MB liberados
```

## 3. Suscripciones e integración

- **M08 (voxel):** `chunk_memory.gd` escucha `chunk_saliendo` (M63) y `juego_editado` (diffs); libera buffers/colliders y reutiliza meshes del pool.
- **M41-M44 (audio):** `audio_memory.gd` gestiona banco por bioma (M42), streaming de pistas largas (M41/M44) y tope de 24 voces (M43).
- **M61 (rendimiento):** el 62 **solo consume** frame budgets y presupuestos del 61; prohibido modificar su carpeta.
- **M63 (streaming):** handshake: el 63 emite `recurso_cargado`; el 62 emite `recurso_descargar` y respeta colas activas.
- **M07 (EventBus):** dominio propio del 62 para semáforos y presupuestos.
- **M90:** preset gráfico activo selecciona el bloque de `budgets.tres`.
- **M103/M110:** reportes al logging y panel de diagnóstico.

## 4. Reglas de implementación

1. Cero `load()`/`preload()` explícitos en gameplay: toda carga pasa por M63 (RN6).
2. Cero allocs deliberados en `_process`/`_physics_process`: arrays tipados y `Packed*Array` (RF8).
3. Todo `connect()` conocio se desconecta en `_exit_tree`; timers y tweens se cancelan (RN3).
4. `queue_free()` diferido 1 frame para liberaciones masivas (RN2).
5. Sin `duplicate()` de recursos compartidos: la caché de recursos tiene un solo dueño (D6).

## 5. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| MemoryMonitor + semáforos + drift | Requiere poder medir contra presupuestos reales M61 |
| `budgets.tres` con preset M90 | Requiere el preset de M90 y los tope reales del prototipo |
| GlobalPool con familias | Requiere framewort de audio (M43) y voxel (M08) |
| ChunkMemory LRU + pool de meshes | Requiere voxel funcional M08 y streaming M63 |
| AudioMemory (bancos/streaming) | Requiere bancos de M41-M44 |
| Tests M112 y verificación de mediciones RN10 | Con hardware objetivo de gama media/baja |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté los 5 archivos del módulo 62 (Memoria) en `plan-inicial/` y `plan-actual/` (espejo idéntico, verificado por hash).
- Analicé el dominio: refcount/GC de Godot, leaks por señales y callables, texturas, chunks voxel (M08), audio (M41-M44) y ResourceCache.
- Diseñé la arquitectura: MemoryMonitor autoload, BudgetRegistry, GlobalPool, UnloadPolicy, drift detector y paneles de diagnóstico.
- Fijé presupuestos por sistema y preset (Baja 1.5 / Media 2.0 / Alta 2.5 GB) con reserva del sistema.
- Definió reglas anti-leak, anti-pico (liberación escalonada), handshake de carga/descarga con M63 y el edge case de textura gigante, chunk sin descargar, audio acumulado y escena cambiada.
- Checklist de 145 ítems 100% completados, con marcadores [S]/[M]/[C].

### Lo que NO pude hacer (honestidad obligatoria)
- **No implementé nada:** el módulo es documentación de diseño; la implementación exige el voxel de M08, los bancos de M41-M44 y los presupuestos definitivos de M61.
- **No medí memoria real:** los límites exactos (800 MB de voxel, 250 MB de audio, etc.) son estimaciones de diseño; requieren validación con el prototipo y hardware real.
- **No toqué `DOCUMENTACION/61-*`** (en curso por otro agente), ni ningún otro archivo fuera de `DOCUMENTACION/62-Memoria/`.

### Recomendaciones para el próximo agente
- Al implementar, leer primero los entregables finales de M61 para ajustar los topes duros y el presupuesto total.
- Verificar con mediciones reales los puntos de interés de RN10 (menú, spawn, horizonte, subterráneo, tormenta).
- El handshake con M63 es la pieza más delicada: probarlo con teletransporte extremo (10 saltos) antes de cerrar la integración.
- Validar en preset Baja con hardware de 4 GB de RAM: es el escenario donde la degradación graceful se ejercita.

---

## Notas del Agente — Iteración 2 enforcement (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 20:25:00
**Estado:** Parcial (enforcement suave/duro + alarma de pico implementados y verificados; módulo liberado 🟡)

### Lo que hice
- Enforcement (diseño §2/§3, RF9): MemoryMonitor._enforcement(actual_mb) — suave al 90% del presupuesto (descarga ordenada vía UnloadPolicy, MAX_POR_FRAME=3) y duro al 95% (sin excepción). Objetivo de descarga: bajar al 80%. Idempotente por nivel (gate _ultimo_enforcement; el nivel 2 siempre re-aplica). Log [M62] con nivel/actual/presupuesto/liberados.
- Alarma de pico (§RN3/RF1): _alarma_pico() — salto > 200 MB entre muestras consecutivas → push_warning con delta (registro para análisis; sin gameplay cost).
- registrar_candidato_descarga(): API para que los sistemas (voxel M08, clima M32, herramientas M13) marquen recursos descargables con peso y distancia.
- Integración en _muestrear(): enforcement + alarma por muestra (el muestreo ya era throttled por el núcleo).
- Test test_enforcement_m62.gd: BudgetRegistry (consumo/tope/verificar sobre tope), enforcement sin crash + UnloadPolicy respeta MAX_POR_FRAME, alarma de pico sin crash → **0 fallos**.
- Regresión: test_memoria_m62 (núcleo ox-alpha) 26 checks/0 fallos.
- Checklist: +2 ítems [x] (enforcement suave/duro, verificación periódica — el resto del bloque §2 son presets M90 con dueño). Progreso 14→16/150.

### Lo que NO pude hacer (honestidad obligatoria)
- Presets por calidad M90 (Baja 1.5 GB / Media 2.0 / Alta 2.5): con dueño M90 — los topes por sistema ya se registran en BudgetRegistry.
- Muestreo condicionado por movimiento de cámara (1 s vs 5 s): el núcleo muestrea por frame del monitor; la cámara vive en M11/M12.
- Contadores propios por sistema (voxel/audio/texturas reales): requiere instrumentación de cada sistema — con dueños.
- Panel del Debug Menu M110: el monitor expone memoria_actual/pico/semaforo/drift — el panel es de M110.

### Recomendaciones para el próximo agente
- M90: presets deben llamar budget.registrar_sistema() con los topes del §2 y setear los umbrales del semáforo.
- M08/M13/M32: al crear recursos descargables (chunks, efectos), llamar monitor.registrar_candidato_descarga() para que el enforcement pueda liberarlos.
- El enforcement usa memoria REAL del OS (OS.get_static_memory_usage) contra presupuesto declarado — no confundir con el consumo por sistema simulado de BudgetRegistry.
