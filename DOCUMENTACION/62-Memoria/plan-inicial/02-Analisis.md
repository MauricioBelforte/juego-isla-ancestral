**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 62: Memoria

## 1. Análisis del Dominio

### 1.1 Reference counting y GC en Godot/GDScript
- Godot 4 usa **conteo de referencias** para `RefCounted`/`Resource` y `free()` manual para `Node`. GDScript **no tiene GC por barrido**: la memoria se libera cuando el refcount llega a 0. Eso significa que una liberación masiva (descargar 100 chunks a la vez) concentra todo el trabajo de dealloc en un solo frame → pico de frame.
- Los **ciclos de referencias** (A→B→A) nunca llegan a refcount 0: son leaks invisibles difíciles de detectar.
- En **hot paths** (código por frame), crear temporales sin tipar (arrays, dicts) genera presión de refcount y hitching irregular en gama baja.

### 1.2 Leaks por señales
- Godot 4 desconecta automáticamente las conexiones cuando el **destino** muere, pero si el **emisor queda vivo** y el callable captura objetos (lambdas con `self`, nodos externos), esos objetos quedan retenidos.
- `Timer`/`Tween` repetitivos activos mantienen callables vivos mientras el nodo no los cancele en `_exit_tree`.
- El patrón típico de leak en este tipo de proyecto: conectar señal `tick` de un servicio global a una lambda de un nodo local que nunca se desconecta.

### 1.3 Texturas
- Una textura 4K sin mipmaps y sin compresión VRAM consume RAM del sistema de forma innecesaria; los atlas con mips reducen memoria y el estado de bind.
- `ResourceCache` mantiene vivas las texturas mientras exista cualquier referencia; `duplicate()` crea copias que duplican VRAM/RAM sin necesidad.

### 1.4 Chunks voxel (M08)
- Cada chunk vivo = buffers voxel (VoxelBuffer) + mesh + collider. La isla Aurora con anillo de carga amplio implica cientos de chunks; sin pooling + LRU la RAM explota o el juego stuttea al liberar de golpe.
- Las ediciones del jugador (diffs de M08) no deben retener historial infinito en RAM.

### 1.5 Audio (M41-M44)
- `preload()` de `.ogg` largos en RAM es caro: las pistas deben reproducirse por streaming.
- Las voces del pool (M43, 24 voces) si no se detienen y devuelven se acumulan sin tope.
- Los bancos por bioma (M42) deben descargarse al cambiar de región, con un frame de margen para no cortar transiciones.

### 1.6 ResourceCache y recursos duplicados
- `load()` cachea recursos; cargar el mismo recurso dos veces por caminos distintos (o con `duplicate()`) duplica memoria.
- La cola de streaming (M63) y la precarga de pools deben tener **un solo dueño** del ciclo de vida de cada recurso.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Muestreo periódico del monitor vs hooks por asignación | **Muestreo periódico + contadores propios** | Los hooks de asignación no existen de forma limpia en GDScript; el muestreo con contadores por sistema es suficiente para semáforos y drift |
| Pool global único vs pools por módulo | **Pool global con familias tipadas** | Evita que cada módulo reinvente pooling; las familias dan control de límites y contabilidad central |
| Enforcement duro (descarga forzosa) vs solo warning | **Suave al 90% + duro al 95%** | El duro siempre descarga (regla desesperada verificable); el suave degrada con prioridad para no invadir la jugabilidad cozy |
| LRU por edad vs LRU por distancia | **Distancia pesa más, edad desempata** | En un mundo voxel el costo de recargar un chunk lejano es alto y visible; la edad evita trashing en regiones estables |
| Descarga síncrona inmediata vs diferida 1 frame | **Diferida 1 frame y escalonada** | Evita el pico de frame de la liberación masiva (RN2); el 63 nunca ve "agujeros" porque la descarga se anuncia por evento antes de ejecutarse |
| Medir con `Performance` de Godot vs contadores propios por sistema | **Ambos: `Performance` para el motor, contadores propios para el juego** | `Performance` da memoria estática/orphans pero no atribuye consumo por sistema del juego |
| `preload()` síncrono vs `load_threaded_request` (M63) | **Solo M63 threaded** | Cualquier `load()` síncrono en gameplay viola RN6; el 62 consume la cola del 63 |
| Descargar recursos vía `ResourceLoader.unload` vs soltar referencias | **Soltar referencias + unload explícito en casos globales** | En GDScript lo determinante es que no queden referencias; unload explícito como refuerzo para precargados globales |

## 3. Decisiones Clave

1. **D1 — MemoryMonitor como autoload único:** dueño del estado global de memoria; el resto de módulos lo consulta con getters puros y nunca tocan memoria ajena.
2. **D2 — Presupuestos como datos:** `budgets.tres` con topes por sistema y por preset (Baja 1.5 GB / Media 2.0 GB / Alta 2.5 GB); suma cerrada con reserva del sistema 300 MB.
3. **D3 — Semáforos con acción:** warning 80% (registrar), crítico 90% (degradación suave), emergencia 95% (descarga duro sin excepción). Cada cambio notifica por EventBus (M07) y log (M103).
4. **D4 — Pool global por familias:** `GlobalPool` con `obtener/devolver/precalentar`, límite por familia y `queue_free()` como fallback honesto si el pool está lleno.
5. **D5 — Anti-leak estructural:** desconexión de señales y cancelación de timers/tweens obligatorias en `_exit_tree`; prohibido lambda que capture nodos externos sin limpieza.
6. **D6 — Un solo dueño por recurso:** el ciclo de vida de cada recurso lo decide M63 (carga) o el 62 (descarga), nunca ambos: handshake por eventos (`recurso_cargado`/`recurso_descargar`).
7. **D7 — Liberación escalonada:** las descargas masivas se reparten en frames (máx N recursos/descargas por frame según preset) para cumplir RN2.
8. **D8 — Texturas con mips y atlas:** sin texturas individuales por objeto; evicción de atlas por orden de uso cuando el presupuesto texturas se supera.
9. **D9 — Audio streaming:** pistas de música/ambiente largas se reproducen por streaming; en RAM solo se retienen streams pequeños (SFX del pool M43).
10. **D10 — Degradación graceful entrada a salida:** orden de degradación fijo: LOD de chunks lejanos → pools secundarios → evicción de atlas → bancos de audio de biomas viajeros (nunca desactivar audio esencial de gameplay ni UI).

## 4. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Pico de frame por liberación masiva de chunks | D7 (escalonamiento) + RN2 verificable en tests |
| Ciclos de referencias entre servicios | D1 + autorrevisión de `connect()`; conteo `PERFORMANCE_OBJECT_COUNT` en tests de drift |
| Textura 4K suelta eleva RAM en gama baja | D8 + detector de texturas sin mips que fuerza degradación automática (edge case K1) |
| Audio acumulado por bug de voces | Tope duro del pool M43 + log; la voz extra se corta (nunca se crea más) |
| Descarga que rompe el streaming activo | D6 handshake con M63; el 62 no descarga nada en cola de carga |
| Presupuesto superado en preset Baja durante tormenta (clima + audio + partículas) | D10 degradación ordenada y registro en log; el juego nunca crashea por memoria |
| Medidas muertas (monitor que avisa pero no actúa) | Enforcement duro al 95% sin excepción + tests de semáforo forzado |