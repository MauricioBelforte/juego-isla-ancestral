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