# Log 825: M60-Datos-Y-Serializacion iter 2 — Guardado asincrónico real (RF10) + cola anti-doble-guardado

**Fecha:** 2026-09-11
**Hora:** 20:01
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M60-Datos-Y-Serializacion
**Reserva:** `Logs/reservas/825-DeepSeek-V4.1-Flash-M60.txt`
**Entrada:** M59 🟡 (núcleo OK, rutas `user://saves` compatibles)
**Visión:** V0 (módulo sin necesidad de recursos visuales)

## Resumen

Iteración 2 de M60. La iter. 1 (deepseek-v4-flash, Kilo Code, 2026-09-01) dejó el núcleo data-driven completo y **66/66 checks**, pero declaró explícitamente que **RF10 (guardado fuera del hilo principal) NO estaba implementado**: la escritura era síncrona. Esta iteración cierra esa brecha con un `Thread` real, la cola de profundidad 1 para el edge case de doble guardado concurrente, y un test headless que prueba el hilo. **Resultado: 94 checks / 0 fallos** (28 nuevos), estable en 3 corridas. Se cierran **5 ítems** del checklist del módulo.

**Relevo:** el módulo estaba `🔵 En curso` con reserva de `deepseek-v4-flash`, modelo **descatalogado el 2026-09-10**; su reserva llevaba **10 días huérfana** (> 24 h) → reclamado por §21.4.7, con justificación escrita en la fila 60 de CHECKLIST-GLOBAL.

## Cambios Realizados

**Código — `game/isla-ancestral/scripts/datos/data_store.gd` (+ ~130 líneas, la API sincrónica NO cambió de contrato):**

1. **`guardar_partida_async(slot, datos) -> Dictionary`** — arranca un `Thread` que hace SOLO IO (serializar → checksum → `WriterAtomico.escribir_atomicamente` → meta → voxel). Devuelve `{ok, aceptado, encolado, reemplazo, error}` de inmediato; el hilo principal nunca toca disco.
2. **Poll barato en `_process`** — solo `is_alive()`. Al terminar, `_finalizar_hilo_guardado()` une el hilo (`wait_to_finish()`), guarda `_ultimo_resultado_async`, emite `guardado_slot` (misma señal que la vía sincrónica → M59/M53 no necesitan dos caminos de UI) y arranca la cola.
3. **Cola de profundidad 1 ("la última gana")** — si ya hay un guardado en curso, la segunda petición se **encola** (`_cola_guardado`), y una tercera **reemplaza** a la encolada (`reemplazo=true`). Nunca se escriben dos veces el mismo archivo en paralelo.
4. **Thread-safety sin locks** — el `Dictionary` se copia con `duplicate(true)` en el hilo llamador: el consumidor sigue mutando su copia sin corromper la escritura en curso. Los helpers (`Serializer`/`Validador`/`WriterAtomico`/`GestorSlot`) son `class_name ... extends RefCounted` (estáticos, sin árbol de escena) → seguros desde un hilo. `DataStore` es el único autoload y **no se accede a él desde el hilo**.
5. **Cierre ordenado — `_exit_tree()`** — une el hilo si quedó vivo. Sin esto, el `Thread` aparecía como `ObjectDB leaked`.
6. **Fallback seguro** — si `Thread.start()` devuelve `err != OK`, cae al camino sincrónico (`guardar_partida`). Nunca se pierde un guardado por falta de hilo.
7. **Señales nuevas** — `guardado_async_iniciado(slot)` y `guardado_async_encolado(slot, reemplazo)`.
8. **API de consulta** — `guardado_en_curso() -> bool`, `slot_en_curso() -> int`, `ultimo_resultado_async() -> Dictionary`.
9. **Refactor interno** — `_escribir_save()` se desdobló en `_escribir_save_con_payload(slot, datos) -> {ok, payload_str}` para calcular el checksum **sin releer el archivo**; `_escribir_save()` conserva el contrato `bool` original (cero regresión).

**Test — `game/isla-ancestral/scripts/datos/test_datos_m60.gd` (+ ~150 líneas):**

10. **`_test_datastore_async()`** — 28 checks nuevos que verifican:
    - la llamada **no bloquea** (< 50 ms) y el hilo queda en curso (`guardado_en_curso()`, `slot_en_curso()==2`);
    - el 2.º guardado se **encola** (`encolado=true, reemplazo=false`) y el 3.º **reemplaza** al encolado (`reemplazo=true`);
    - la **secuencia de señales** exacta `iniciado(2) → fin(2) → iniciado(2) → fin(2)` (traza por señales, no por poll → sin flakiness);
    - el resultado final viene del **hilo** (`hilo=true`, no del fallback sincrónico) y trae checksum;
    - el disco queda con el contenido de la **última** petición (`Async-C`) y **no** con la descartada (`Async-B`); el slot descartado (3) **no** se escribió;
    - slot fuera de rango → rechazo limpio **sin** arrancar hilo.
    - El test cede frames con `await process_frame` (no bloquea el bucle principal), con guarda de timeout (900 frames).

## Decisiones

1. **`Thread` en vez de `WorkerThreadPool`.** La iter. 1 recomendaba `WorkerThreadPool`, pero el guardado es una operación **única, larga y de orden estricto** que necesita un resultado tipado (`wait_to_finish()` devuelve el `Dictionary`); con `WorkerThreadPool` habría que agregar sincronización manual. Migrar es directo si M62 lo pide: `_tarea_guardado` ya es una función pura de IO.
2. **Cola de profundidad 1, no cola ilimitada ni bloqueo.** Un doble guardado concurrente casi siempre es el mismo estado actualizado (autosave + guardado manual) → encolar N escrituras es desperdicio y bloquea la UI; quedarse con la última es correcto y acota memoria.
3. **Una sola señal de fin (`guardado_slot`) para ambas vías.** Evita que M59/M53 tengan dos caminos de UI distintos.
4. **La API sincrónica queda intacta.** `guardar_partida` sigue existiendo con el mismo contrato (fallback + compatibilidad con lo ya cableado).

## Archivos Modificados/Creados

**Código GDScript:**
- `game/isla-ancestral/scripts/datos/data_store.gd` (iter. 2: guardado asincrónico + cola + helpers de hilo)
- `game/isla-ancestral/scripts/datos/test_datos_m60.gd` (iter. 2: `_test_datastore_async` + helpers)

**Documentación:**
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md` (5 ítems cerrados, reserva actualizada)
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/04-Codigo.md` (API async + Notas del Agente iter. 2)
- `CHECKLIST-GLOBAL.md` (fila 60: 🟡 Liberado, 182/196, agente `—`, notas)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (registro §17 + reserva actual)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada M60 iter. 2)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/60-Datos-Y-Serializacion/checklist.md` (backlog personal)

## Ítems cerrados (5)

- `[x] RF10: serialización de guardado fuera del hilo principal [C]`
- `[x] M62: IO del guardado en hilo secundario (Thread/WorkerThreadPool) [C]`
- `[x] Edge case: doble guardado concurrente -> bloqueo de escritura o cola [M]`
- `[x] Optimización: IO en hilo secundario, UI nunca bloqueada [M]`
- `[x] Testings: test de hilo: guardado asincrónico sin bloquear el frame [C]`

## Verificación (QA numérico — Godot 4.7.2 headless)

Binario: `/d/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`

```
--headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd
```

- **Test M60 completo: 94 checks / 0 fallos** (baseline previo: 66 checks / 0 fallos → +28 nuevos). Exit 0.
- **Estabilidad:** 3 corridas consecutivas → 94/0 las 3. Sin flakiness (la traza por señales evita las carreras del poll).
- **Sin errores de parseo.** Sin patrones nuevos de reloj-SO.
- **§28 — UTF-8 sin BOM:** se detectó que `data_store.gd` y `08-GUIA-ORDEN-DE-IMPLEMENTACION.md` tenían BOM en el working tree pese a que HEAD está limpio (el repo tiene 522 archivos con BOM — condición endémica, no introducida aquí). Se **sanearon los 3 bytes** de ambos y se re-corrió el test: **94/0**. `test_datos_m60.gd`, `05-Checklist.md` y `04-Codigo.md` quedan sin BOM.
- **Fugas:** verificado con `--verbose` → **cero `Leaked instance: Thread`**. El hilo se une en `_finish` y en `_exit_tree()`.
- **Observación honesta (no es un fallo de M60):** el test ahora corre varios frames (`await process_frame`) y eso deja que el mundo (terreno voxel con meshing en hilos propios, NPCs, UI) se construya más antes del `quit()`. El warning `ObjectDB instances were leaked at exit` sube de **58** (copia del test sin la llamada async) a **385** (con frames). A/B verificado con una copia temporal: **no hay fuga introducida por M60**; es un artefacto preexistente de cierre del proyecto que escala con los frames corridos. Se deja registrado para quien audite fugas.

## Pendientes que quedan en M60 (NO bloqueantes, NO cerrados aquí)

- `[C]` Compresión ZIP_DEFLATE de `mundo_voxel.bin` (+ `Optimización: compresión bajo demanda`).
- `[S]` Carga perezosa de catálogos.
- `[M]` M62: progreso visible durante guardado + UI interactiva deshabilitada → **son de UI (M53/M59)**; el DataStore ya expone las señales.
- `[M]` Presupuestos RN verificados con el Profiler (requiere build con GUI).
- `[C]` Contrato de "edits" de M08 (pendiente confirmación del agente de M08, heredado de iter. 1).
- `[S]` Rotación/limpieza de `.bak` (coordinación con M107, heredado de iter. 1).
- `[M]` RF3: serialización de construcciones/casas (M17/M18) y fauna/vecinos (M36/M19).
- `[M]` M15/M16/M33: recetas y cultivos como Resources tipados.
