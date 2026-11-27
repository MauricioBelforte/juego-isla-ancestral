# LOG 2467 - M55 tanda datos: 6 flips (L57/L92/L97/L98/L99/L125), 92→98/131 + fix suite rota

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25
**Hora:** 15:11

## Resumen

Quinta tanda del día: M55-Diario-Del-Jugador (fila 🟡 libre, reserva §21.3). Implementé los puentes de datos del diario con señales REALES de otros módulos (todo read-only) y el modelo de extras persistente. Fix lateral de una suite rota desde el 2-nov.

## Cambios Realizados

### Modelo de extras por entrada (diary_service.gd)
- `_extras: Dictionary` (entrada_id → Dictionary), API `registrar_con_datos()` (merge idempotente) + `datos_de()`.
- `get_save_data()` → **schema_version 2** con clave `extras`; `restore_save_data()` tolerante (saves v1 sin extras cargan igual).
- `detalle_entrada()` expone `datos` (+ `inventario` en vivo para minerales, + `ingredientes`/`resultado` para recetas).

### Puentes read-only implementados
1. **L57 personajes:** `bus.npc.npc_moved_in` → snapshot de retrato (`NPCVisualDatabase.get_visual().resource_path`, M162); `bus.progresion.nivel_amistad_cambio` (dominio PROGRESION de M71/M20 — no bus.npc) → `nivel_relacion`; `bus.ui.dialog_requested` (UIEvents) → historial `dialogos` (tope 5, más nuevo primero, dedupe) + `ultimo_dialogo`.
2. **L92 minerales:** snapshot `cantidad_inventario` via `Inventario.count_item()` (mapeo mineral_mineral_cobre→mineral_cobre) + conteo en vivo en el detalle.
3. **L97/L98/L99 recetas (M16):** puentes a `Crafting.receta_aprendida` (desbloquea/registra) y `Crafting.crafting_completed` (registra + `marcar_completado()`); `_datos_receta()`/`_rec_id_de_entrada()` leen `Crafting.obtener_receta` (materiales + resultado_id/resultado_cantidad) con fail-closed; `diary_layer.gd::_pintar_descripcion_refs()` renderiza "Ingredientes: N × item" y "Resultado: N × item".
4. **L125:** API `validar_sellos_m25()` contra `data/balance/seals.json` (reporte catalogo_ok/desconocidos/sin_diario; hallazgo: diario registra sellos de TEMPLOS M24, M25 cataloga sellos de PROGRESO — familia distinta, ahora documentada).

### Fix lateral (honestidad): suite de recetas ROTA desde el 2-nov
`test_diario_recetas_m55.gd` (DeepSeek, WorkBuddy) exigía `_datos_receta`/`_rec_id_de_entrada` que NUNCA existieron en diary_service.gd (verificado contra HEAD y todo el historial git): **19 fallos preexistentes**. Implementé el contrato que la suite define (F1-F4 fail-closed, D1-D15 con el JSON crudo como segunda fuente, C3-C6 L97, E3-E5 L99) → ahora **47/0 EXIT 0**.

### Error mío corregido durante el desarrollo
- Primera versión de los puentes asumía `nivel_amistad_cambio` y `dialog_requested` en `bus.npc`: SCRIPT ERROR (no existen ahí; están en `bus.progresion` y `bus.ui`) + un `get(prop, default)` en Resource no parsea en Godot 4. Corregido; el test cubre ambos caminos.

### Regresión (8 suites del diario, todas EXIT 0)
`test_diario` 36/0 · `validate_diary` 392/0 · `test_diario_persist` (cadena 2 procesos, EXIT 0 — ajusté su aserción de schema 1→2 con comentario) · `test_diario_iconos` 56/0 · `test_diario_lore` 67/0 · `test_diario_idiomas` 51/0 · `test_diario_recetas` 47/0 · `test_diario_extras` (NUEVO) 24/0.

### Documentación
- 6 flips con cita en `05-Checklist.md` + Totales **98/131** (98 [x]/31 [ ]/2 [?]).
- Fila 55 del GLOBAL: 92/131 → **98/131** con nota. ESTADO-PARALELO + guía 08 (reserva/cierre).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/diario/diary_service.gd` (puentes + extras + validar_sellos_m25)
- `game/isla-ancestral/scripts/diario/test_diario_extras_m55.gd` (NUEVA QA, 24 checks)
- `game/isla-ancestral/scripts/ui/layers/diary_layer.gd` (render ingredientes/resultado)
- `game/isla-ancestral/scripts/diario/test_diario_persist.gd` (aserción schema v2)
- `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, guía 08
- Reporte **042** en mi carpeta

## Pendientes / Deuda (honestidad)
- M55: quedan 31 [ ] (la mayoría requieren puentes a módulos sin señales aún o UI compleja) y 2 [?] externos.
- Los historiales de diálogo se guardan como ids de nodos; la UI no los renderiza aún (solo en extras/datos).
- QA cruzado §21.8 de las 5 tandas del día pendiente de modelo distinto.

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code


> **Nota de colisión (GLM-5.3-Flash, 2026-11-25 15:35):** este log fue inicialmente numerado **2459**, número que YA HABÍA SIDO CONSUMIDO por minimax-m3.1-flash (log M17, ~40 min antes). Colisión de pool: el número no había sido borrado de `Logs/NUMEROS_DISPONIBLES.txt` al reservarse (posible falla del protocolo). Renumerado a **2467** por prioridad de timestamp (el log de minimax es anterior). Citas corregidas en los 4 registros y reportes.
