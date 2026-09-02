# Log 518: M71 Progresión — iter. 3 RF12 Títulos + RF10 Gating

**Fecha:** 2026-09-02
**Hora:** 06:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 3 de M71 Progresión: implementación de RF12 (títulos sociales cosméticos) y RF10 (gating suave hacia M66). Núcleo iter. 2 (minimax-m3-free) respetado e incrementado.

## Cambios Realizados

### Archivos modificados
| Archivo | Cambio |
|---|---|
| `scripts/progresion/progression_manager.gd` | +RF12: señal progreso_titulo_obtenido, dict _titulos, otorgar_titulo_directo(), titulos_obtenidos(), tiene_titulo(), titulo_count(), persistencia v2 (SECCION_VERSION=2), premio "titulo" en recompensas de hitos. +RF10: validar_imposibles(), reportar_condicion_imposible(), _es_posible_alcanzable(). Fix indentación elif. |
| `scripts/progresion/test_progresion.gd` | Actualizado check de versión: `== 1` → `>= 1` para compatibilidad v2. |
| `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` | RF10 [x], RF12 [x], encabezado actualizado, bloque reserva añadido. |
| `CHECKLIST-GLOBAL.md` | M71: 🟢 Disponible → 🔵 En curso → 🟡 Liberado (iter. 3). |
| `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` | Fila M71 añadida en registro de reservas. |
| `Logs/ULTIMO_NUMERO.txt` | 517 → 518. |

### Tests ejecutados
- `test_progresion.gd`: **0 fallos**, exit 0
- `test_viajes.gd` (M28 regresión): **0 fallos**, exit 0
- `test_harbor_viajes.gd` (M28 regresión): **0 fallos**, exit 0
- Boot runtime: sin errores nuevos; `[M71] ProgressionManager ready, 15 hitos cargados`

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` *(modificado)*
- `game/isla-ancestral/scripts/progresion/test_progresion.gd` *(modificado)*
- `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md` *(modificado)*
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` *(modificado)*
- `Logs/ULTIMO_NUMERO.txt` *(modificado: 517→518)*
- `Logs/reservas/518-glm-5.3-flash-M71-Progresion.txt` *(creado y borrado)*

## Notas técnicas
- RF12: el tipo de recompensa `"titulo"` en hitos.json ahora activa `_otorgar_titulo()` en vez de ser ignorada. El hito `hito_amistades_5` ya tenía `"tipo": "titulo", "valor": "Amigo del Pueblo"` en el JSON — ahora funciona.
- RF10: `validar_imposibles()` se llama en `_ready()`; escanea los 15 hitos del catálogo y reporta a M66 (SoftlockGuard) si encuentra condiciones imposibles. Duck-typing: si M66 no existe, solo hace log.
- `_es_posible_alcanzable()`: revisa recursivamente tipos de condición (stat_min, compuesta AND/OR, hito_previo, etc.) y verifica dependencias (M22, M37, M13/M18) via get_node_or_null.
- SECCION_VERSION bumped to 2: saves antiguos carecen de clave "titulos" pero `restore_save_data` maneja el fallback con `.get("titulos", {})`.
- Fix: indentación incorrecta en `validar_imposibles()` (elif mal sangrado) corregida.