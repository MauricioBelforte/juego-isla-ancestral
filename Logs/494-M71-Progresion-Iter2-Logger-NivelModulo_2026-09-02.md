# Log 414: M71 Progresión iter 2 — GameLogger + nivel_modulo + catálogo expandido

**Fecha:** 2026-09-02
**Hora:** 00:20
**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

## Resumen
M71 iter 2: integración con GameLogger (M103) reemplazando print(), nuevo tipo condicional nivel_modulo (nivel de herramienta M13 / casa M18 vía duck-typing), catálogo expandido de 9 a 15 hitos, tests actualizados. **13 OK / 0 fallos** en test headless. Regresiones M36/M65/M73: 0 fallos cada una.

## Cambios Realizados

### scripts/progresion/progression_manager.gd
- Integración con GameLogger (M103): helper _log_info/_log_dom_hito/_log_dom_unlock que usa logger.info(msg, 3) si disponible, fallback a print() si no.
- Nuevo tipo condicional `nivel_modulo`: evalúa nivel de herramienta (M13 ToolController.obtener_nivel_herramienta) o casa (M18 CasaManager.obtener_nivel_casa) vía duck-typing. Retorna false sin crash si el módulo no existe.
- Limpieza de señal doble `_sello_obtenido` (había un `and false if false else` residual del desarrollo).
- Logs DOM-PROG-HITO y DOM-PROG-UNLOCK ahora pasan por GameLogger.

### data/progresion/hitos.json
- Expandido de 9 a 15 hitos: añadidos hito_dias_7, hito_dias_30, hito_items_50, hito_misiones_5, hito_viajeros_10, hito_sello_ceniza_sala2.
- Todos con recompensas info/cosmético válidas.

### scripts/progresion/test_progresion.gd
- Actualizado para 15 hitos (antes esperaba 9).
- Nuevo test `_test_nivel_modulo_fallback`: verifica que nivel_modulo retorna false sin crash cuando ToolController/CasaManager no existen (3 checks).
- Todos los tests existentes pasaron sin cambios.

### Validación
- **M71 test:** 13 OK / 0 fallos
- **M36 regresión:** 59 OK / 0 fallos
- **M65 regresión:** 9 OK / 0 fallos
- **M73 regresión:** 44 OK / 0 fallos
- Boot runtime: 0 errores, ServiceRegistry completo, bootstrap OK

## Notas técnicas
- GameLogger category 3 = GAMEPLAY (confirmado desde logger.gd enum Category).
- Duck-typing para nivel_modulo: no se requiere que M13/M18 emitan señales; simplemente lee el nivel actual cuando se evalúa la condición. Esto es consistente con el enfoque "solo lectura" del diseño M71.
- El fix de `_sello_obtenido` eliminó código muerto (and false if false else) que dejaba la función en estado ambiguo.

## Pendientes M71
- Señales nivel_herramienta_cambio (M13) / nivel_casa_cambio (M18): el tipo nivel_modulo ya funciona por lectura directa, pero las señales permitirían dirty-flagging proactivo. Pendiente de dueños M13/M18.
- Reputación con amistad real de M20: reputacion(amistad_normalizada) espera normalización desde M20. Pendiente.
- Logros (M72) y títulos: tipos Achievement/Title del diseño quedan para iteración con M72.
- Catálogo completo 22 categorías × ~500 items (el plan original). Iter 2 mantiene 15 hitos de referencia.
