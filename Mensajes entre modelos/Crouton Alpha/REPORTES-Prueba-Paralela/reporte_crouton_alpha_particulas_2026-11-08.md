# Reporte: Sistemas de Partículas/VFX — Isla Ancestral

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` (GDScript)
**Tipo:** auditoría estática (código + catálogo); no verificado en runtime Godot/GPU.

## 1. Inventario de archivos

### 1.1 Módulo principal `scripts/particles/` (12 scripts)

| Archivo | Líneas | Propósito |
|---|---|---|
| `scripts/particles/vfx_factory.gd` | 114 | `VfxFactory`: `parametros()` puro, `crear()` / `nuevo_emisor()` / `redisparar()` GPUParticles3D |
| `scripts/particles/vfx_pool.gd` | 278 | `VfxPool`: pool de emisores one-shot reutilizables |
| `scripts/particles/vfx_director.gd` | 156 | `VfxDirector`: conecta eventos → catálogo → pool |
| `scripts/particles/vfx_trigger.gd` | 144 | `VfxTrigger`: traducción bus namespaced → VFX (1002) |
| `scripts/particles/vfx_schema.gd` | 169 | `VfxSchema`: validación de catálogo |
| `scripts/particles/vfx_loops.gd` | 135 | `VfxLoops`: loops ambientales con culling/LOD |
| `scripts/particles/test_vfx_catalog_headless.gd` | ~50 | tests headless |
| `scripts/particles/test_vfx_factory_headless.gd` | ~50 | tests headless |
| `scripts/particles/test_vfx_director_headless.gd` | ~50 | tests headless |
| `scripts/particles/test_vfx_m52_iter6.gd` | ~300 | tests M52 iter. 6 (schema, trigger, loops) |
| `scripts/particles/test_vfx_pool_m52.gd` | ~324 | tests de pool |
| `scripts/particles/preview_particles.gd` | 103 | demo visual polen (preview) |
| `scripts/particles/preview_vfx_m52.gd` | 86 | preview de calibración M52 (6 eventos) |

### 1.2 Sistema secundario (terreno)
| Archivo | Líneas | Propósito |
|---|---|---|
| `scripts/terrenos/terrain_particles.gd` | 185 | `TerrainParticles` (M156): moléculas por tipo de terreno, CPUParticles3D |

### 1.3 Catálogo
| Archivo | Contenido |
|---|---|
| `game/isla-ancestral/data/vfx/vfx_catalog.json` | 31 VFX (version 2), 12 loops, 21 con `bus`, 10 con `dueno_evento`, 0 sin触发者 |

## 2. ¿Cómo se gestionan los sistemas de partículas?

### 2.1 Flujo canónico (VFX del catálogo)
1. `VfxFactory.parametros(vfx)` (`vfx_factory.gd:30-37`) normaliza un VFX: `color`, `cantidad` (default 20), `emision` (default 0.5), `tipo`, `id`.
2. `VfxFactory.nuevo_emisor(vfx)` (`vfx_factory.gd:52-61`) crea `GPUParticles3D` nuevo **sin añadir al árbol**: `one_shot=true`, `explosiveness=1.0`, `lifetime=maxf(0.2, emision)`, `draw_pass_1=_quad()` (QuadMesh 0.08), `process_material=_material(vfx)`.
3. `VfxPool.prestar(vfx, pos, container)` (`vfx_pool.gd:118-152`) reutiliza un emisor libre del mismo `id`, o crea uno si hay cupo; si no, recicla el activo más antiguo. Configura posición, `restart()`, semilla determinista `semilla_de(id, orden)` (FNV-1a 32, líneas 67-73) y lo deja `emitting=true`.
4. `VfxDirector.disparar(evento_id, pos)` (`vfx_director.gd:87-99`) busca el VFX por `evento` y delega al pool; guarda la vida útil en `_vida[nodo] = emision` (mín. 0.2 s).
5. `VfxDirector.actualizar(delta)` (`vfx_director.gd:103-111`) — **no es `_process` propio** — decrementa la vida restante de cada emisor y lo libera al pool cuando expira.

**Presupuestos del pool** (`vfx_pool.gd:37-38`):
- `MAX_EMISORES_DEF = 32` emisores vivos (activos + libres).
- `MAX_PARTICULAS_DEF = 1200` partículas activas (suma de `cantidad` de los activos).

**Política de desborde** (`_hacer_hueco`, `vfx_pool.gd:249-260`): recicla activos más antiguos primero (`_reciclar_mas_antiguo`, líneas 266-278) hasta que quepa la nueva emisión. Si ni un solo VFX cabe, `prestar()` devuelve `null` y emite `emision_descartada` con motivo (`MOTIVO_SIN_ID` / `MOTIVO_PARTICULAS` / `MOTIVO_EMISORES`, líneas 41-43). El director lo loguea como `VFX-SKIP` en `GameLogger` (`vfx_director.gd:119-123`).

**Determinismo** (T-093): las semillas FNV-1a son estables entre corridas/plataformas; `_validar_semillas` detecta secuencias vacías o repetidos consecutivos (líneas 77-85).

**Loops ambientales** (`vfx_loops.gd`): lógica pura, sin nodos. `VfxLoops.registrar()` (líneas 36-50) registra un emisor por zona (no uno por chunk), `activos(camara)` (líneas 73-81) culla por distancia al centro de zona, `factor_lod(vfx, d)` (líneas 85-89) baja al 25% a distancia, y `fase_en_t(vfx, t, periodo)` (líneas 108-111) usa fase fija del catálogo (sin `randf()`).

**Terreno** (`terrain_particles.gd`, CPUParticles3D): se autoconecta a `TerrainDetector.terrain_changed` (líneas 57-58), precarga 7 escenas `.tscn` vía `RUTA_PARTICULA` (líneas 62-70), emite en `_physics_process` sólo si la velocidad horizontal del jugador > `velocidad_minima=1.5` (líneas 78-93), con pool propio `max_emisores=6`, ráfaga de `duracion_rafaga=0.8` s (líneas 138-144).

**Validación** (`vfx_schema.gd:63-151`): valida versión (esperada 2), 6 conjuntos cerrados (`CATEGORIAS`, `EMISORES`, `MATERIALES`, `TIPOS`), rangos `CANTIDAD_MIN=5`, `CANTIDAD_MAX=300`, `EMISION_MIN=0.1`, `EMISION_MAX=3.0`, `presupuesto >= cantidad`, `luz_por_particula=false`, `parpadeo_hz <= 10`, loops con `radio>0` y `fase` en `[0,1)`, `bus` frente a `dueno_evento`, naming `vfx_<snake_case>`, color `#RRGGBB`.

**Traducción de eventos** (`vfx_trigger.gd`): `VfxTrigger.construir(catalogo)` (líneas 33-48) deriva `bus → [ids]` desde el catálogo; `conectar(raiz, callable)` (líneas 77-99) resuelve namespaces reales (`world.*`, `quest.*`, `weather.*`, etc.) y **reporta** `faltantes`. `disparar(bus, contexto, catalogo)` (líneas 104-112) filtra por `condicion = "clave:valor"`.

## 3. ¿Hay fugas de partículas no detenidas?

Auditoría por mecanismo (no por conteo de emisores visibles en captura):

### 3.1 Defectos confirmados
**F-1. `VfxDirector` no tiene `_process`; si el host no llama `actualizar()` nunca libera** (`vfx_director.gd:103-111`). Es el **principal riesgo de fuga funcional**: `preview_vfx_m52.gd:47-49` sí lo llama desde `_process`, pero si un nodo de producción olvida el tick, los emisores quedan en `emitting` para siempre; el pool se satura de emisores "activos fantasma" y los disparos empiezan a descartar (`MOTIVO_EMISORES` / `MOTIVO_PARTICULAS`). No es fuga de memoria dura (el nodo sigue vivo en el pool), pero es fuga de presupuesto.
**F-2. Sin limpieza automática al salir del árbol.** `VfxDirector.finalizar()` (`vfx_director.gd:151-156`) es manual: `queue_free()` de cada nodo del pool y `vaciar()`. No hay `_exit_tree()`, `_notification(NOTIFICATION_EXIT_TREE)` ni `tree_exiting` en `VfxPool`. Si la escena se cambia sin llamar `finalizar()`, los nodos del pool quedan huérfanos o se destruyen con el contenedor, dejando claves inválidas en `_activos` del `RefCounted` (que vive fuera del árbol). El pool es `RefCounted`, no `Node` (`vfx_pool.gd:26-27`), así que no recibe señales de ciclo de vida.
**F-3. `VfxFactory.crear(container, vfx, pos)` (`vfx_factory.gd:39-44`): vía legacy sin pool.** Crea un `GPUParticles3D` nuevo por llamada, lo añade al árbol y lo deja `emitting=true`; **nunca lo libera ni lo registra**. Cualquier caller que use `crear()` en vez de `VfxPool.prestar()` genera un emisor nuevo en cada disparo, con vida no contabilizada. Es el camino que el comentario de `vfx_director.gd:8-12` declara obsoleto tras iter. 5; sigue siendo público y ningún schema/test garantiza que nadie lo llame.
**F-4. `VfxFactory.redisparar()` no libera el `ParticleProcessMaterial` anterior** (`vfx_factory.gd:73`). Cada disparo crea un `ParticleProcessMaterial.new()` sin `free()`/`queue_free()` del material previo que el emisor reutiliza. En Godot 4 los `Resource` son `RefCounted` y el anterior se libera por referencia (p. ej. `gp.process_material` en `_material` es un recurso nuevo; el viejo queda sin referencias y su contador llega a 0), así que **no es fuga dura en el runtime**, pero sí una churn de recursos por disparo (alloc + unref) evitable con 2-3 materiales compartidos por tipo.
**F-5. `PreviewParticles` (`preview_particles.gd:12-103`) crea 420 partículas permanentes sin cleanup.** El `_ready()` pone `CPUParticles3D.amount=200` + `GPUParticles3D.amount=220` = 420, los deja `emitting=true` para toda la vida de la escena, con `visibility_aabb` gigante de 40 m (líneas 33, 85) y sin `_exit_tree()`. Para una escena de preview es correcto; si esa escena se instanciara en ciudad o se dejara `emitting` tras uso, sería una fuga de emisor permanente. No es el flujo productivo.
**F-6. `TerrainParticles` no se hace `queue_free()` en `_exit_tree`.** `_liberar()` (líneas 147-152) pone `emitting=false, visible=false` y apila el nodo; los emisores quedan con `amount` en el último valor, pero el sistema los reutiliza con nueva cantidad (línea 109). Correcto dentro de la vida del jugador; si el jugador se libera antes que el sistema, quedan nodos hijos sin dueño (heredan el árbol del jugador, que sí los libera). Riesgo bajo.

### 3.2 Conclusión de fugas
- **No hay "fuga de handle de partícula" en el sentido de `amount` que crece sin cota dentro del ciclo correcto** (el pool reciclando evita eso).
- **Sí hay fuga de ciclo de vida** (F-1, F-2, F-3) si el host no llama `actualizar()`/`finalizar()`. La causa raíz es el pool siendo `RefCounted` sin `_process()` gestionado: toda la limpieza depende de que el llamador sea disciplinado.

## 4. ¿Hay problemas de rendimiento con demasiadas partículas activas?

### 4.1 Presupuesto global
- `MAX_PARTICULAS = 1200` suma de `cantidad` activos (`vfx_pool.gd:199-203`).
- Catálogo: 31 VFX, suma de `cantidad` = **1 688**, max 150 (`vfx_polen`), min 12 (`vfx_regalo_amistad`), media ~54. Las 12 loops suman 895 si todas estuvieran activas en la cámara a la vez.
- Unión: los loops **no** pasan por el pool en este código (`VfxLoops` decide **cantidad**, no instancia nodos). Por tanto, el presupuesto de 1 200 **no incluye loops ambientales** activos en paralelo: si un productor instancia emisores de loops sin preguntar a `VfxLoops.resumen()`/`cantidad_efectiva()`, puede tener loops (hasta 895) + burbujas limitadas por el pool (1 200) = ~2 095 partículas simultáneas en CPU/GPU. En un PC GPU modesta es asumible; en móvil es un riesgo.
- `preview_particles.gd` dispara 420 permanentes además del presupuesto (fijo, no suma como pool).

### 4.2 Hazañas de CPU en el bucle caliente
- `_hacer_hueco()` (`vfx_pool.gd:249-260`) es O(n²) en el peor caso: cada iteración de `while particulas_activas() + cantidad > max_particulas` llama a `particulas_activas()` O(n) (lines 199-203) y a `_reciclar_mas_antiguo()` O(n) (lines 266-273). Con n≈32 activos, el costo es ~32×64 ops por préstamo, despreciable en PC, pero es evitable manteniendo un contador `particulas_activas_actual`.
- `_reciclar_mas_antiguo()` recorre `_activos` en cada reciclado; cuando una sola emisión de `cantidad=150` (polen) fuerza varios reciclados seguidos, el bucle recorre la tabla varias veces.
- `VfxDirector.actualizar()` es O(n) por frame sobre ~mismo n.
- El catálogo `data/vfx/vfx_catalog.json` es ≤ 30 entradas; `cargar_catalogo()` es I/O síncrono en `_ready()` del director (está bien; una vez por escena).

### 4.3 Riesgo real de lag (no inventado)
- **No hay evidencia de que el presupuesto de 1 200 partículas cause lag en un hardware mínimo probado**, porque el shader de la `QuadMesh` es un `QuadMesh` 0.08 con textura radial gratuita (sin `mesh`, sin `draw_pass` pesado) y `ParticleProcessMaterial` homogéneo.
- **El riesgo está en la interacción**: una cascada de 32 préstamos simultáneos × reciclado secuencial puede causar **stutter de CPU** (en vez de pico de GPU) si ocurre en el mismo frame — el disco real es el `_hacer_hueco` en bucle, no el draw call.
- `TerrainParticles.max_emisores=6`, `INTENSIDAD_MAX=16`, `duracion_rafaga=0.8` es conservador; ningún riesgo.

## 5. Dos mejoras recomendadas

### Mejora A — Dar al `VfxPool` ciclo de vida propio
Convertir el pool en `Node` con `_process()` gestionado o suscribirlo a señales del contenedor. Detalle de implementación mínimo (sin paradigma nuevo):
1. Cambiar `class_name VfxPool extends RefCounted` → `Max`/`Node` o registrarse con `get_tree().node_added/exited_tree`/`tree_exited` y `finished` del `GPUParticles3D` (señal en Godot 4 `finished` tras años de `one_shot`? existe `GPUParticles3D.finished` desde 4.0). Al recibir la señal, liberar el emisor sin necesitar que `_vida` acabe.
2. Dejar autónomo a `VfxDirector._process()` (llamar a `actualizar(delta)` dentro de él) en vez de que el host lo haga a mano (`preview_vfx_m52.gd:47-49` ya lo hace manual; repetición propensa a olvido).
3. `_exit_tree()` en director + pool: `queue_free()` de cada `nodo()` del pool (ya existe en `finalizar()` lines 151-156; basta engancharlo).
**Efecto:** elimina F-1/F-2 (fuga de ciclo de vida) sin cambiar la API pública ni el kit de tests headless.

### Mejora B — Incluir loops en el presupuesto e instrumentar la presión
1. `VfxLoops.resumen(camara)` (lines 122-135) ya devuelve `particulas_totales`; usarlo en `VfxDirector.stats()`/`VfxPool.stats()` para que el total logueado sea `pool + loops`, no sólo el pool.
2. `VfxPool._hacer_hueco()` mantener un contador incremental `_particulas_vivas` en vez de re-sumar (`vfx_pool.gd:199-203`) en cada iteración, y un contador de presión por categoría en `stats()`: `{one_shot, loops}`.
3. Si la suma `one_shot + loops > MAX_PARTICULAS` (1 200), bajar primero `factor_lod` de los loops lejanos a 0.25 (ya implementado en `vfx_loops.gd:85-89`), antes que descartar disparos de impacto. Reduce decisiones binarias (`prestar()` devuelve `null`) por pérdida gradual de fidelidad.
**Efecto:** el presupuesto deja de ser "1 200 one-shot + infinito loops" y pasa a controlar la carga real de la escena.

## 6. Conclusión final

El sistema VFX de M52 es **sólido en diseño**: factory + pool + trigger + schema + loops, con presupuestos explícitos (32 emisores / 1 200 partículas), reciclado determinista y validación de catálogo reproducible. El catálogo de 31 VFX (1 688 de cantidad total, 21 con bus) encaja con ese presupuesto sin desbordarlo en un solo disparo.

Los **únicos fugas reales** no son de memoria dura, sino de **ciclo de vida**: `VfxDirector` no tiene `_process` ni `_exit_tree()`, el pool es `RefCounted` sin señales de salida del árbol, y `VfxFactory.crear()` sigue público sin registrar emisores. Si el host es disciplinado (llama `actualizar()` cada frame y `finalizar()` al cerrar), todo se libera; si olvida uno de los dos, el pool se satura de emisores fantasma y `prestar()` empieza a descartar en silencio (con log `VFX-SKIP`). La corrección recomendada es pequeña y contenida (Mejora A): enganchar `_process()`/`_exit_tree()`/`finished` y convertir el pool a `Node` o dotarlo de callback de árbol.

El riesgo de rendimiento no está en el `MAX_PARTICULAS=1 200` en absoluto, sino en que **los loops no están dentro de ese presupuesto** (12 loops = 895 partículas potenciales fuera del pool). Con la Mejora B, el total queda controlado y la pérdida por presión es gradual (LOD 25% a distancia), no binaria.

Archivos de evidencia (frase exacta):
- `scripts/particles/vfx_factory.gd:39-44` (`crear()` sin registro)
- `scripts/particles/vfx_factory.gd:73` (material nuevo por disparo)
- `scripts/particles/vfx_pool.gd:37-38` (32 / 1 200), `:199-203` (recálculo O(n)), `:249-260` (hueco O(n²)), `:266-278` (reciclado O(n))
- `scripts/particles/vfx_director.gd:60-68` (`_ready()` con `has_signal("evento_generico")` inexistente → confirmación en lines 21-32), `:98` (`_vida`), `:103-111` (`actualizar` manual), `:151-156` (`finalizar` manual)
- `scripts/particles/vfx_trigger.gd:77-99` (`conectar` reporta faltantes), `:104-112` (disparo con condición)
- `scripts/particles/vfx_loops.gd:73-89` (`activos`, `factor_lod`), `:93-102` (`cantidad_efectiva`)
- `scripts/particles/preview_particles.gd:21,83` (200+220), `:33,85` (`visibility_aabb` 40 m)
- `scripts/terrenos/terrain_particles.gd:60-70` (precarga 7), `:78-93` (_physics_process), `:138-152` (`_gestionar_activos`, `_liberar`)
- `scripts/particles/vfx_schema.gd:53-57` (límites), `:63-151` (validación)
- `data/vfx/vfx_catalog.json` (31 VFX, 1688 suma; vfx_polen 150 en `cantidad`, vfx_lluvia 120, vfx_nieve 100)

Fin del reporte.
