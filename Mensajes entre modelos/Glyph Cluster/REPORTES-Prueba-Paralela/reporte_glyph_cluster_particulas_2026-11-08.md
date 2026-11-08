# Reporte de análisis: partículas, VFX y efectos visuales

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 04:15 (UTC, según entorno)  
**Alcance analizado:** `game/isla-ancestral/scripts/particles/` (`.gd`) + datos/performance relacionados (`data/vfx/vfx_catalog.json`, `data/performance/budgets.json`)  
**Método:** revisión estática de código, búsqueda de referencias de integración (`VfxDirector`/`VfxTrigger`/`VfxPool`), lectura de tests headless existentes y verificación de presupuesto de partículas.

## 1) ¿Cómo se gestionan los sistemas de partículas?

El sistema M52 está diseñado como pipeline por capas:

| Capa | Archivo / líneas clave | Responsabilidad |
|---|---|---|
| Catálogo/validación | `vfx_schema.gd:1-169` | Valida `data/vfx/vfx_catalog.json` (versión, rangos, categorías/emisores/materiales/tipos cerrados, cobertura del plan, reglas RF3/RF4/RF6/RF7/RF11/RF14/RF16). |
| Carga + construcción de emisores | `vfx_factory.gd:20-97` | `cargar_catalogo()` lee el JSON (`:20-27`). `nuevo_emisor()` crea `GPUParticles3D` one-shot configurado (`:52-61`). `redisparar()` reutiliza el emisor con semilla determinista aplicada **después** de `restart()` (`:69-77`) para evitar pérdida de seed. Usa `draw_pass_1` (Godot 4.3+) y no la propiedad obsoleta `mesh` (`:48-59`). |
| Pooling/reuso | `vfx_pool.gd:1-278` | Pool por `id` con límites `max_emisores`/`max_particulas` (def. 32/1200, `:37-61`), precalentamiento (`:91-112`), préstamo/liberación (`:118-171`), reciclado del activo más antiguo (`:265-278`), métricas (`:174-212`), señal `emision_descartada` para telemetría/log (`:29-31`, `:235-240`). Semillas deterministas FNV-1a por `(evento, índice)` (`:67-73`). |
| Orquestación por evento | `vfx_director.gd:34-156` | Carga catálogo, indexa por `evento` (`:60-68`), expone `disparar(evento_id, pos)` (`:87-99`), llama `pool.prestar()` con contenedor (`:93`), lleva vida temporal en `_vida` y libera expirados en `actualizar(delta)` (`:102-111`). `finalizar()` hace `queue_free()` de nodos vivos y vacía pool (`:151-156`). |
| Traducción bus→VFX | `vfx_trigger.gd:1-144` | Deriva mapa namespaced `bus -> ids` desde catálogo (`:32-48`), resuelve señales reales del `EventBus` y reporta faltantes (`:77-99`), evalúa condiciones (`:104-122`) y cobertura (`:127-137`). Diseñado como punto único RF6/T-163. |
| Loops ambientales (lógica) | `vfx_loops.gd:1-135` | Lógica pura para registrar 1 emisor por zona, culling por radio, LOD 100%/25%, fase fija determinista y resumen de telemetría (`:36-135`). No crea nodos ni renderiza por sí mismo. |
| Tests/pruebas | `test_vfx_pool_m52.gd`, `test_vfx_m52_iter6.gd`, `test_vfx_director_headless.gd`, `test_vfx_catalog_headless.gd`, `test_vfx_factory_headless.gd` | Cobertura de runtime de factory, pool/prestamo/liberación/límites/determinismo, director, skips VFX-SKIP, schema, loops y trigger. `test_vfx_pool_m52.gd:30-48` usa marcador anti-falso-verde por bloques. |
| Preview/manual | `preview_vfx_m52.gd:1-79` | Escena aislada que instancia director, precalienta y dispara 6 eventos representativos; útil para verificación visual V4, no es wiring de gameplay. |

**Datos operativos observados (resumen del catálogo):** `data/vfx/vfx_catalog.json` tiene versión 2, 31 entradas, 12 loops, 21 con bus, `max_cantidad=150`, `sum_cantidad=1688`, `max_presupuesto=220`. Los presupuestos de performance declaran `limites.particulas_simultaneas_max=500` y, en `particulas`, `max_emisores_pool=32`, `max_particulas_pool=1200`, `precalentamiento_emisores=8` (`data/performance/budgets.json`).

## 2) ¿Hay fugas de partículas no detenidas?

**Riesgos/fugas potenciales identificados (estáticos):**

1. **Integración real incompleta / director “mudo” por señal inexistente (alto impacto funcional, documentado en código).**  
   - `vfx_director.gd:21-32` documenta que iter. 5 intentaba conectar `EventBus.evento_generico`, señal inexistente; el `has_signal()` evita error pero deja el director sin disparos por eventos reales.  
   - `vfx_director.gd:64-67` mantiene esa conexión condicional: si el EventBus no expone `evento_generico`, no se engancha.  
   - Búsqueda de uso fuera de `scripts/particles/`, previews/tests/editor/colector encontró solo referencias en `data/performance/budgets.json` (texto de norma) y no wiring en escenas `.tscn` del juego. **Conclusión:** hoy el riesgo principal no es fuga activa en runtime de gameplay, sino **sistema no integrado**; cuando se integre sin usar `VfxTrigger`/`finalizar()`, pueden aparecer fugas.

2. **Nodos fuera del árbol no se liberan solos si se usa `VfxPool`/`nuevo_emisor()` sin contenedor y sin `finalizar()`.**  
   - `vfx_pool.gd:118-152` permite `container == null`; el nodo se dispara pero puede quedar sin padre (`:147-150` solo reparenta si hay contenedor).  
   - `vfx_pool.gd:214-229` mantiene referencias en `_activos/_libres` y `nodos()`/`vaciar()` no hacen `queue_free()`; el owner debe liberar nodos.  
   - `vfx_director.gd:151-156` sí hace el teardown correcto (`queue_free()` + `vaciar()`), pero solo si quien lo integra llama `finalizar()` al cerrar/cambiar escena.

3. **Contabilidad `_vida` en director depende de `actualizar(delta)`.**  
   - `vfx_director.gd:97-111` registra vida y libera al expirar solo cuando se invoca `actualizar()`. Si un integrador dispara efectos y no llama `actualizar()` periódicamente, los emisores pueden seguir marcados activos en el pool hasta reciclado por presión o hasta `finalizar()`. No es fuga de memoria en nodos si el pool los retiene/reusa, pero sí **retención prolongada de capacidad del pool** y posible comportamiento inesperado.

4. **`vfx_loops.gd` no gestiona ciclo de vida de nodos.**  
   - `vfx_loops.gd` decide qué zonas/cantidades son activas (`:73-135`) pero no crea, detiene ni libera emisores. Si un consumidor crea emisores por zona activa y no los apaga al salir de radio/desregistrar, puede dejar partículas activas. El módulo en sí es puro; el riesgo está en el código que lo consuma (actualmente no detectado en `.tscn`/scripts no-particles).

**Evidencia de mitigación ya presente:** `VfxFactory.crear/nuevo_emisor/redisparar` configuran `one_shot=true` (`vfx_factory.gd:56`), `VfxPool` recicla/libera (`:154-171`, `:265-278`), `VfxDirector.actualizar/finalizar` gestionan expiración/limpieza (`vfx_director.gd:102-156`), y `test_vfx_pool_m52.gd` cubre runtime, reuso, liberación y limpieza (`:64-97`, `:124-168`, `:223-267`, `:306-325`).

## 3) ¿Hay problemas de rendimiento con demasiadas partículas activas?

**Controles existentes (positivos):**
- Límites duros en pool: `MAX_EMISORES_DEF=32`, `MAX_PARTICULAS_DEF=1200` (`vfx_pool.gd:37-38`), con descarte/reciclado cuando no hay hueco (`:123-142`, `:247-260`).
- Política de reciclado determinista del más antiguo (`vfx_pool.gd:265-278`) y señal/motivos de descarte para observabilidad (`:29-31`, `:235-240`, `:195-212`).
- Presupuesto global en `data/performance/budgets.json`: `limites.particulas_simultaneas_max=500`; norma `particulas.max_emisores_pool=32`, `max_particulas_pool=1200`, `pooling_emisores=true`, `gpu_particles_larga_vida=true`, `max_emisores_por_evento=1`.
- `VfxLoops` aplica culling por radio y LOD 25% a distancia (`vfx_loops.gd:23-31`, `:73-102`), y RF9 apunta a 1 emisor global por zona (`:8-10`, `:34-51`).

**Riesgos de rendimiento detectados:**

1. **Desalineación entre presupuesto por cámara y presupuesto interno del pool (medio).**  
   - El budget de performance exige `particulas_simultaneas_max=500` por cámara (`budgets.json`, `limites`), pero `VfxPool` permite por defecto `max_particulas=1200` (`vfx_pool.gd:38`, `:59-61`).  
   - Si el director/pool se instancia con defaults, puede exceder el tope por cámara bajo ráfagas, aunque respete su límite interno. `VfxDirector._init` crea `POOL.new()` sin parámetros (`vfx_director.gd:53-58`).

2. **`VfxDirector` no usa el presupuesto de catálogo ni coordina múltiples disparos simultáneos por cámara globalmente.**  
   - El catálogo valida `presupuesto >= cantidad` (`vfx_schema.gd:116-118`), pero el director solo consulta `cantidad`/parámetros de factory al disparar (`vfx_director.gd:87-98`, `vfx_factory.gd:29-37`). No hay un “budget manager” central que agregue todos los pools/directores/loops activos frente al límite global de 500.

3. **Cada emisor crea material y quad nuevos (bajo/medio, mitigado parcialmente por pool).**  
   - `vfx_factory.gd:52-61` crea `ParticleProcessMaterial` y `QuadMesh` por `nuevo_emisor()`. El pool evita recrear en cada disparo si reutiliza (`vfx_pool.gd:129-146`), pero precalentamiento masivo o pools por id podrían multiplicar materiales/meshes. El `QuadMesh` es trivial (0.08x0.08) pero no está compartido.

4. **`actualizar(delta)` itera sobre claves del diccionario `_vida` y puede borrar durante iteración lógica por claves; coste crece con activos, aunque el tope de emisores es pequeño (32).**  
   - `vfx_director.gd:103-111` usa `for nodo in _vida.keys()` y `erase` al expirar; con 32 emisores es despreciable, pero es un patrón a vigilar si se suben límites.

5. **Loops registrados sin consumidor integrado conocido.**  
   - `vfx_loops.gd` provee culling/LOD determinista, pero no se detectó wiring en escenas/scripts de gameplay fuera del módulo. Esto no degrada rendimiento hoy; sí implica que la optimización RF9/RF14 está implementada en lógica pero no necesariamente aplicada en runtime real.

## 4) Sugerencias de mejora (2)

1. **Integrar el disparo real por `VfxTrigger` y cerrar el ciclo de vida en escenas de gameplay.**  
   - Reemplazar la conexión rota a `evento_generico` en `vfx_director.gd:64-67` por un flujo basado en `VfxTrigger.construir/catalogo` + `conectar(/root/EventBus, callback)` (`vfx_trigger.gd:32-99`), o delegar el mapeo al trigger y mantener al director solo como ejecutor/pool.  
   - Asegurar en la escena que usa VFX: `set_container(...)`, llamada periódica a `actualizar(delta)`, precalentamiento según budget, y `finalizar()` en `_exit_tree`/cambio de escena. Esto elimina el modo “mudo” documentado y evita retenciones/fugas por nodos no liberados.

2. **Alinear límites del pool con budgets y centralizar presupuesto por cámara.**  
   - Instanciar `VfxDirector/VfxPool` con valores derivados de `data/performance/budgets.json`/config de calidad (p. ej. `max_particulas <= limites.particulas_simultaneas_max` o un reparto explícito por cámara/capa), en vez de depender de defaults 1200 (`vfx_pool.gd:38`, `vfx_director.gd:53-54`).  
   - Añadir un chequeo agregado opcional (partículas activas del pool + loops activos + otros pools) antes de `prestar()` o en el director, para respetar el tope global de 500 por cámara. Complementariamente, compartir `QuadMesh`/material base cuando el efecto lo permita, manteniendo variaciones por instancia solo donde sean necesarias.

## Conclusión final

El subsistema de partículas/VFX en `game/isla-ancestral/scripts/particles/` tiene una base técnica sólida para Godot 4.3+: usa `GPUParticles3D` con `draw_pass_1`, pool de emisores con préstamo/liberación, semillas deterministas, límites de emisores/partículas, descarte con señal/motivos y lógica de loops con culling/LOD. Los tests headless revisados cubren buena parte de estas garantías, incluyendo casos que antes producían falsos verdes.

No se observó un wiring activo en escenas `.tscn` de gameplay, y el propio `vfx_director.gd` documenta un bloqueo de integración real: depende de `EventBus.evento_generico`, inexistente, por lo que no dispararía VFX desde eventos reales del juego. El riesgo de fuga no está tanto en el core del pool/factory, sino en integraciones futuras que omitan `actualizar(delta)`, usen `container == null` sin teardown, o no llamen `finalizar()`. En rendimiento, el control local existe, pero hay una desalineación potencial entre el límite interno del pool (1200 partículas por defecto) y el presupuesto global por cámara (500), además de la falta de coordinación agregada entre fuentes de emisión.

**Estado:** base reusable y testeada a nivel módulo; **pendiente** integrar el trigger/event bus real y ajustar presupuestos globales por cámara para considerar el sistema cerrado en runtime de juego.
