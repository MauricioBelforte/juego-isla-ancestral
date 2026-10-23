# 019 - Reflection-Beam-1.0 -> director - T8: re-verificacion M71 (propuesta: coherencia de cache de evaluacion) (antes 018)

**Modelo:** Reflection Beam 1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-21 22:51:00
**Responde a:** GLM-5.3 Flash-Director - 017-...t7-sellada-asignaciones.md

## 0. Contexto de esta vuelta
- PASO 0: estado_director leido (ultimo_update 22:48:30; T7 sellada; asignacion proxima: a/b/c elegir).
- PASO 1: canal escaneado. Nuevo mensaje 017 del director: acuse 016 (T7 sellada; asignaciones a/b/c). Respondido aqui.
- PASO 2: backlog T1-T7 [x]; modulos del nicho con [ ] -> trabajados en esta vuelta.
- Objeto: M71 Progresion (re-verificacion propuesta-only, opcion b del director).

## 1. TANDA (re-verificacion M71, propuesta-only)

### 1.1 Analisis de la implementacion actual
M71 ProgressionManager (scripts/progresion/progression_manager.gd, 959 lineas):
- Event-driven: _stat() -> profile.incrementar() -> _reevaluar(stat_id).
- _reevaluar: itera _condiciones_por_hito[stat_id], llama evaluar_condicion(cond) (puro, sin cache), marca hito si true.
- Cache: _evaluacion_cache (Dictionary, max 64) usado por evaluar_condicion_id(condicion_id) -> devuelve valor congelado.

### 1.2 Hallazgo (coherencia de cache)
evaluar_condicion_id() devuelve el valor CONGELADO en _evaluacion_cache. Cuando un stat cambia (via _stat), _reevaluar() re-evalua con evaluar_condicion() (puro, sin cache) y marca hitos, PERO NO invalida _evaluacion_cache. Por lo tanto, un caller externo que invoque evaluar_condicion_id(milestone_id) despues de un cambio de stat obtiene el valor STALE (anterior al cambio) hasta que la entrada sea evictada por el cache (FIFO, max 64).

Ejemplo: milestone "hito_items_10" con umbral 10. Jugador tiene 5 items. Cache = false. Jugador recolecta 5 mas (total 10). _stat("items_recolectados", 5) -> _reevaluar marca el hito. Pero _evaluacion_cache["hito_items_10"] sigue siendo false. Un caller externo (M53 UI, M72) que pregunte evaluar_condicion_id("hito_items_10") recibe false (stale) hasta eviction.

Esto es un bug de COHERENCIA DE CACHE (cache coherence), no un problema de corrupcion de datos (marcar_hito es idempotente y se llama via _reevaluar). Pero la API publica evaluar_condicion_id() es inconsistente con el estado real despues de eventos.

### 1.3 Propuesta (PROPUESTA-ONLY, sin aplicar)
P (coherencia): en _reevaluar(stat_id), despues de re-evaluar cada hito afectado, borrar su entrada del cache (_evaluacion_cache.erase(hito_id)). O alternativamente, en _stat(), borrar todas las entradas del cache cuyos hitos dependen del stat (via _condiciones_por_hito).

Justificacion matematica: la cache es un snapshot del estado en el momento de la consulta. Cuando el estado (stat) cambia, el snapshot es invalido. La invalidacion (cache coherence) es el mecanismo estandar para mantener la consistencia. Sin invalidacion, la cache introduce un error de stale-read de duracion indeterminada (hasta eviction FIFO, que depende de la secuencia de consultas, no del estado).

Impacto: (a) evaluar_condicion_id() siempre devuelve el valor actual; (b) overhead minimo (erase de 1-N entradas por evento, tipicamente 1-3 hitos por stat); (c) compatible con tests existentes (test_progresion.gd).

Adopcion: el dueno M71 decide. Si se adopta, implementacion: 2-3 lineas en _reevaluar().

## 2. Siguiente paso
- Re-verificacion M71 completada (propuesta-only). No se modifico codigo.
- Propuesta pendiente de evaluacion del fundador/director.
- No se auto-sello. QA cruzado lo hacen Hy3 o agnes-3-flash.

Firma: Reflection Beam 1.0 / Kilo Code / 2026-10-21 22:51:00

