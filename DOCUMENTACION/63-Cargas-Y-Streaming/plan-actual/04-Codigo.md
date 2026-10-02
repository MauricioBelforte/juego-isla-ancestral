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

---

## Notas del Agente — Iteración 5 (Log 1192, DeepSeek-V4.1-Flash/WorkBuddy)

**Fecha:** 2026-10-02
**Estado:** Parcial (lado 63 del handshake M62↔M63 + precalentamiento P9 + regiones P12-P14 + red de regresión endurecida)

### Lo que hice

**1. Handshake con M62 (§5.3) — LADO 63.** El 62 decide qué LIBERAR; el 63 decide qué CARGAR. El puente es `stream_manager.gd`:
- `avisar_carga_iniciada(recurso)` / `avisar_carga_terminada(recurso)`: registro `_en_carga` por `recurso.get_instance_id()` (contrato Resource-keyed, NO path-keyed) + aviso al autoload M62.
- `recursos_en_carga_63()`, `esta_en_carga_63()`, `avisos_m62()` (0 si M62 ausente).
- **DESACOPLADO** vía `_mem()` = `get_node_or_null("/root/MemoryMonitor")`: si M62 no existe (tests sueltos, orden de autoloads, build sin memoria) todo es no-op y el 63 sigue igual.
- Hooks reales: `_process()` avisa alrededor de la ENTREGA del recurso threaded (rama LOADED y rama FAILED); `liberar_envejecidos()` avisa ANTES de `unreference()`; `registrar_chunk()` OFRECE los chunks NUEVOS al 62 como candidatos de descarga (con su distancia).

**2. Anti doble carga (L158).** Registro `_rutas_en_carga` (ruta → nº de operaciones en vuelo): `encolar()` abre la ruta, `_process()` la cierra. `esta_cargando_ruta()`, `rutas_en_carga()`.

**3. Precalentamiento (§7 / P9).** `precalentar_mundo(opciones)`: shaders del mundo + banco del bioma inicial + atlas base + 3 anillos del spawn si `hay_partida`. IDEMPOTENTE (2.ª llamada sin `forzar` → 0). `operaciones_restantes()`, `precalentado()`, tope `OPERACIONES_CONTINUAR_MAX = 30` (§7.2).

**4. Streaming por región (§5 / P12-P14).** Matemática pura testeable headless: `corona_oceano()` (3 coronas), `piso_subterraneo()` (3 pisos LOD 0-2), `dentro_streamable_box()` (radio 10 m), `toca_precargar_destino()` (60% de la ruta M28), `piso_liberable()` (encadenado al subir, sin huecos). Instanciar la geometría es de M08/M09/M27/M28 (dueños externos).

**5. Suite nueva `test_stream_m63_iter5.gd`** (7 bloques A-G, **51 checks, 0 fallos, ×3**). Guardián de 3 capas probado EN ROJO con 5 sondas: (A) aserción falsa, (B) `return` que aborta `_run`, (C) piso+1, (D) bloques sin cerrar, (E) `_fin()` suprimido → las 5 dan **EXIT 1**; el control sin mutar da **EXIT 0**. El código de salida REAL se verificó con `echo $?`, no por el texto "FALLIDO".

**6. Red de regresión ENDURECIDA.** Las 5 suites previas imprimían `"0 fallo(s)"` SIN contador de checks: un aborto por SCRIPT ERROR (o un bloque nunca llamado) daba igual "0 fallo(s)" + EXIT 0 → falso verde (trampas 46/119). Ahora las 5 tienen guardián de 3 capas (bloque `_fin()`, piso `CHECKS_MINIMOS` MEDIDO, `_summary()` en su propio `call_deferred`), probado en rojo por inyección de un `return` temprano.

| Suite | Checks (verde) | Piso | Antes |
|---|---|---|---|
| `test_stream.gd` | 21 | 21 | "0 fallo(s)" sin contador |
| `test_stream_m63.gd` | 29 | 29 | MUERTA dando verde (3 SCRIPT ERROR) |
| `test_pausa_cargas.gd` | 9 | 9 | "0 fallo(s)" sin contador |
| `test_pantalla_carga.gd` | 7 | 7 | "0 fallo(s)" sin contador |
| `test_rf2_threaded.gd` | 7 | 7 | "0 fallo(s)" sin contador |
| `test_stream_m63_iter5.gd` | 51 | 51 | nueva |

**Total del módulo: 21+29+9+7+7+51 = 124 checks, 0 fallos, EXIT 0.** Las 6 suites quedan cableadas en `.github/workflows/quality.yml` con gate duro (`|| FAIL=1`).

**7. `test_stream_m63.gd` REESCRITA.** Estaba MUERTA dando verde: apuntaba a una API que nunca existió en el manager entregado (`sm.weights`, `sm.cargadas_size()`, `sm.obtener_cache()`, `sm.presupuesto_chunks`, `sm.cola_vacia`, `encolar(tipo, ruta)` de 2 args, `precalentar_mundo(Array)`). Cada llamada lanzaba un SCRIPT ERROR que abortaba la función; el resumen imprimía "8 checks, 0 fallos" y salía con código 0. Reescrita contra la API REAL: cubre `ProgressCalculator` (pesos/progreso — cobertura que ninguna otra suite daba), la API de cola (incluido el rechazo de tipo desconocido), las SEÑALES (`operacion_completada`, `chunk_listo`, `banco_listo`, `shader_listo`, `progreso_cambiado`) y el progreso piso/tope/cierre.

### Hallazgo grave: el sello §21.8 de M63 está INVALIDADO

El `CHECKLIST-GLOBAL.md` (fila 63) y el `Log 895-HY3-LOTED.md` declaran M63 verificado §21.8 con **"0 fallos (EXIT 0)"** citando las 5 suites — incluida `test_stream_m63.gd`. Ese "0 fallos" era un **falso verde**: la suite emitía 3 SCRIPT ERROR y 3 de sus 4 funciones de test nunca corrían. Un sello que se apoyó en un "0 fallos" de una suite muerta queda **invalidado** → **hay que RE-VERIFICAR, no heredar**. La re-verificación §21.8 la hace un NO-autor (Hy3/verificador independiente), nunca el autor de la iteración. Reportado al coordinador.

### Lo que NO hice (honestidad obligatoria)
- **Integración real con M08/M09/M27/M28** (mallas de chunk reales, geometría de océano/subterráneo): fuera de alcance de una iteración headless. La DECISIÓN (qué corona/piso/caja) está implementada y testeada; instanciar geometría es de esos dueños → `[?]`.
- **M12** (anillo sigue a la cámara), **M47** (mips por LOD), **M53/M46** (arte cozy de la pantalla), **M90** (presets Deck), **M113/M114** (profiler/recorrido): dueños externos → `[?]`.
- **No toqué M61** (`scripts/rendimiento/` fuera de `memoria/`) ni `scripts/interacciones/` (kimi).

### Hallazgos ajenos (reportados, NO tocados)
- **Colisión de numeración 1188**: existen `Logs/1188-HY4-AUDITORIA-AUTORIA-BLENDER.md` y `Logs/1188-m62-iter5-verificada-deepseek-reasignado-m63_2026-10-02_17-47-26.md`.
- **Fuga de pool**: el número **1190** salió del pool sin log escrito (consumido, nunca usado). El pool entregó **1192**.
- **Contaminación de worktree ajena**: `scripts/mapa/mapa_manager.gd` (M54) tiene un PARSE ERROR en el worktree (líneas ~198-201, `center` sin tipo + inferencia Variant) y está modificado sin commitear. No es de M63; aparece como ruido en algunas corridas headless. NO tocado.

### Recomendaciones para el próximo agente
- Cablear `registrar_chunk()` desde M08 al poblar el anillo, para que el handshake con M62 tenga candidatos reales.
- El handshake de "vida larga" (avisar al consumidor) queda en manos del consumidor: `avisar_carga_iniciada()` al tomar el recurso y `avisar_carga_terminada()` al soltarlo (el 63 solo cubre la ventana de carga).
- Re-verificar §21.8 con un no-autor antes de volver a sellar M63.

---

## Notas del Agente — Iteración 6 (Log 1193, DeepSeek-V4.1-Flash/WorkBuddy)

**Fecha:** 2026-10-02
**Estado:** Parcial (cierra §6: consejos rotando L98 + fundido a escena L99; cierra la documentación de delegación L146-L150)

### Por qué esta iteración (los 13 `[ ]` que quedaban)

Tras la iter. 5, el checklist quedó en **61 `[x]` / 13 `[ ]` / 27 `[?]`**. Al revisar los 13 `[ ]` se separaron en dos grupos:

- **Con dueño externo** (L28/L34/L36/L38/L39/L40/L41): poblado real de NPC/audio/texturas/shaders y el arte cozy → M08/M15/M16/M42/M47/M53. Quedan `[ ]` con su nota.
- **Trabajo PROPIO de M63, sin dueño externo** (L98, L99, L146-L150): los tomé. La pantalla de carga es un entregable de este módulo (§6) y su comportamiento (consejos + transición) es suyo.

### Lo que hice

**1. Consejos de mundo rotando (§6, L98).** Nuevo `scripts/stream/consejos_carga.gd` (`class_name ConsejosCarga`, lógica PURA, métodos `static`):
- `parsear(texto)`: una frase por línea, `#` = comentario, blancos ignorados, espacios recortados, ORDEN preservado.
- `cargar(ruta)`: lee `tips.txt` con `FileAccess`; **degradación silenciosa** (archivo ausente/vacío → lista vacía, la pantalla sigue igual).
- `indice_inicial(semilla, n)`: índice determinista por **semilla de partida (M29)**. **NO es `semilla % n`** (eso daría el mismo consejo a partidas creadas seguidas); mezcla la semilla y se verifica que 20 semillas contiguas dan ≥5 índices distintos.
- `consejo(tips, semilla, tick)`: rota desde el índice inicial con `posmod` (da la vuelta).
- Base de datos `data/stream/tips.txt` (junto a `weights.json`): **lista semilla** de 10 consejos; ampliarla es trabajo de **contenido** (Nivel C), no de lógica.

**2. Fundido (fade) hacia la escena (§6, L99).** Nuevo `scripts/stream/fundido_carga.gd` (`class_name FundidoCarga`, máquina de estados PURA): `iniciar(duracion)` → `avanzar(delta)` → `alpha()` (1.0 → 0.0) / `progreso()` / `terminado()`. Idempotente (re-iniciar reinicia el reloj), `delta` negativo no retrocede, `duracion <= 0` nace TERMINADO, y `acotar_duracion()` respeta el tope **`DURACION_MAX = 2 s`** de §6 ("transición corta").

**3. Integración en `pantalla_carga.gd`.** Label `Consejos` nuevo (los nodos `Fondo`/`Barra`/`Texto` se conservan: `test_pantalla_carga.gd` sigue 7/0). `configurar_seed()` (siembra desde el autoload `GameTime` = M29 si no se fija), `consejo_actual()`, `fundir(duracion)`, `fundiendo()`, `alpha_actual()`. El `_process` (habilitado solo con la pantalla visible, `set_process`) rota el consejo cada `INTERVALO_ROTACION` y avanza el fundido; al completarlo llama a `ocultar()`.

**4. Suite nueva `test_stream_m63_iter6.gd`** (6 bloques A-F, **42 checks, 0 fallos, EXIT 0, ×3**). Guardián de 3 capas con piso **42 MEDIDO** y probado EN ROJO con 5 sondas: (A) aserción falsa, (B) `return` que aborta `_run`, (C) piso+1, (D) bloque sin cerrar, (E) `_fin()` no-op → **5/5 EXIT 1**; control sin mutar **EXIT 0**.

**5. Regresión completa del módulo.** Las 7 suites, ×1 (la nueva ×3):

| Suite | Checks | Piso |
|---|---|---|
| `test_stream.gd` | 21 | 21 |
| `test_stream_m63.gd` | 29 | 29 |
| `test_stream_m63_iter5.gd` | 51 | 51 |
| `test_stream_m63_iter6.gd` | 42 | 42 |
| `test_pausa_cargas.gd` | 9 | 9 |
| `test_pantalla_carga.gd` | 7 | 7 |
| `test_rf2_threaded.gd` | 7 | 7 |

**Total del módulo: 21+29+51+42+9+7+7 = 166 checks, 0 fallos, EXIT 0.** La suite nueva queda cableada en `quality.yml` con gate duro (`|| FAIL=1`).

**6. Documentación de cierre (L146-L150).** Cierro los 4 ítems de la sección §L que son documentación pura: módulo marcado delegable, 3 alternativas descartadas, API estable y bloqueo por M08/M61 documentados (ver `05-Checklist.md` y `02-Analisis.md`).

### Nota de infraestructura (trampa 114, otra vez)

El **índice git compartido volvió a fallar**: tras `git add` de mis 6 rutas, otro agente (M54) commiteó y el índice quedó **vacío** — `git commit -- <rutas>` falló con *"did not match any file(s) known to git"*. Solución aplicada: **encadenar `git add -- <rutas> && git commit -- <rutas>` en UNA sola invocación** (ventana de carrera mínima). Commit resultante `b8229ef`, con EXACTAMENTE mis 6 archivos (`git show --stat`). El worktree nunca se perdió.

### Lo que NO hice (honestidad obligatoria)
- **El contenido de `tips.txt`** es una lista semilla; redactar los consejos definitivos y su tono es de contenido (Nivel C).
- **El arte cozy** de la pantalla (nubes/parallax/escena full-screen) sigue siendo de M53 → `[?]`.
- **No toqué M61** ni `scripts/interacciones/` (kimi). **No sellé §21.8** (autor ≠ verificador).
