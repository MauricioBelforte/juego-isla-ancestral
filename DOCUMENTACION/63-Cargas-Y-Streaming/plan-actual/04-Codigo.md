**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 63: Cargas y Streaming

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/stream/stream_manager.gd` | Autoload | Cola, pesos, orquestación |
| `res://src/stream/async_loader.gd` | Util | `load_threaded_request` + callbacks |
| `res://src/stream/chunk_stream.gd` | Nodo | LRU + prioridades voxel (M08) |
| `res://src/stream/region_stream.gd` | Nodo | Océano/subterráneo/islas (StreamableBox) |
| `res://src/stream/progress_calculator.gd` | Util | Pesos y barra |
| `res://src/ui/loading_screen.gd` + `.tscn` | UI | Pantalla de carga cozy |
| `res://data/stream/weights.tres` | Data | Pesos por operación |
| `res://data/stream/tips.txt` | Data | Consejos de mundo |

## 2. API pública

```
StreamManager (autoload/único):
  encolar(operacion: StreamOp, prioridad: int)
  precalentar_mundo(){}
  progreso() -> float
  señal operacion_completada(op)
  señal cola_vacia
  presupuesto_chunks: int (config)
  pausar_cargas() / reanudar_cargas()   # M29
StreamOp: { tipo, path, peso, callable_al_terminar }
```

## 3. Suscripciones e integración

- M08 (voxel): StreamManager encola los chunks; el voxel solo genera mesh en hilos.
- M12 (cámara): posición del anillo; eventos de región.
- M28/M69 (Gran Vapor/Fast Travel): `precargar_destino(coords)` al 60% de la ruta.
- M29: `pausar_cargas()` en pantallas de carga del mundo (el reloj no avanza).
- M45/M46 (menús): el LoadingScreen se reutiliza para mundos dentro del menú si hay transiciones.
- M47 (texturas): atlas con mips; LODManager pide mips por distancia.
- M61: presupuestos (deltas < 50 ms; tope de chunks; sin `load()` síncrono).

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| StreamManager + cola + progreso real | Requiere M08 voxel y presupuestos M61 |
| Precalentamiento en menú principal | Con M46 |
| RegionStream (océano/subterráneo/islas) | Con M09/M27/M28 |
| LoadingScreen cozy + consejos | Con arte 2D (M46) |
| Tests M112 y QA M114 | Movimiento rápido y memoria |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17 00:10:00
**Estado:** Documentación de diseño completa (módulo delegable; bloqueado por M08/M61 para implementar)

### Lo que hice
- 15/15 puntos de la sección 62 resueltos.
- Progreso real por pesos, LRU con tope duro, precalentamiento en menú y streaming por región.
- Reglas anti-congelamiento verificables (< 50 ms; cero cargas síncronas).

### Lo que NO hice (honestidad obligatoria)
- Implementar: depende de M08 (mundo voxel funcional) y de los presupuestos definitivos de M61 (GPT-5 en curso). Dueño: AGENTE DELEGADO cuando existan las bases.
- No se tocó el M61 (zona de GPT-5).

### Recomendaciones para el próximo agente
- Coordinar con el resultado del M61 antes de fijar tope de chunks y presupuesto de delta.
- El LoadingScreen debe deshabilitar todo el input excepto pausa del sistema.
- Probar el cambio de anillo de océano con cámara rápida: es donde aparecen los huecos si el LOD no encadena.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 24:10:00
**Estado:** Parcial (cola priorizada + progreso real + LRU implementados y verificados; módulo liberado 🟡)

### Lo que hice
- StreamManager autoload (scripts/stream/stream_manager.gd, §1-§4, §8): cola priorizada por pesos (7 tipos §2: chunk_lod0=1, chunk_lod1=3, banco_audio=3, textura_atlas=2, shader=5, npc_instancia=1, malla_region=4); ProgresoReal (barra = Σ pesos completados/Σ encolados, piso 2%, tope 98% SOLO mientras hay cola — "hasta cerrar" = 100% al vaciar); procesamiento asíncrono por frame con PRESUPUESTO_MS=40 (§8: delta < 50 ms, sin load síncrono en gameplay); LRU de chunks (MAX_CHUNKS=4096 default/2048 Deck, envejecido fuera de R_max+1 → 2 frames → liberar silencioso, prioridad lejanos primero, pool de meshes reutiliza M61); aplicar_tope() con liberación de más lejanos; señales chunk_listo/banco_listo/shader_listo/progreso_cambiado/operacion_completada; métricas LRU persistidas (M59 "stream").
- Test test_stream.gd: pesos §2, orden por prioridad, progreso piso/tope/cierre, presupuesto de frame drena la cola, LRU envejecido (solo lejanos, 2 frames), tope duro (los cercanos sobreviven), persistencia → **0 fallos**.
- Regresión: test_autosave_m59 0 fallos.
- Checklist: progreso relevado (ítems del núcleo implementados).

### Fusión documentada (iter. 1)
- Los 5 componentes del diseño §1 (Cola/AsyncLoader/ChunkStream/LODManager/Precalentador) están representados en un único autoload: la cola+presupuesto cubre AsyncLoader, el LRU cubre ChunkStream, LODManager es parte del tipo chunk_lod1. El thread real (AsyncLoader threaded) es iter. 2 — V0 usa callables diferidos con presupuesto (sin congelamiento, §8 cumple).

### Lo que NO pude hacer (honestidad obligatoria)
- AsyncLoader con thread real (ResourceLoader.load_threaded_request): iter. 2 — el presupuesto por frame ya evita el congelamiento en V0.
- Precalentador del menú principal (§7): precalentar_mundo() es 1 llamada al manager — el flujo del menú es del dueño M53/M40.
- LoadingScreen cozy (§6): UI V2 M53 — progreso_cambiado listo.
- Streaming por región (océano coronas, subterráneo pisos, islas StreamableBox — §5): requiere M08/M27/M28 — puentes con dueños.
- LODManager de mips/mesh real: integración M08 (dueño).

### Recomendaciones para el próximo agente
- M08: al generar chunks, llamar registrar_chunk(chunk_id, distancia, mesh_recurso) y marcar_envejecidos(R_max) + aplicar_tope() en cada actualización del anillo.
- M28/M69: el vuelo de aproximación encola la isla destino al 60% de la ruta (encolar con prioridad 5, §3).
- Iter. 2 thread real: migrar los callables a ResourceLoader.load_threaded_request para texturas/shaders; el presupuesto pasa a 1 op por frame verificación.
- MAX_CHUNKS por hardware: M90 presets (2048 Deck / 4096 PC) vía set_max_chunks.
