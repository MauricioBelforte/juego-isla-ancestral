# Log 406: M73 Coleccionables iter 1 — autoload `coleccionables` + integración con M36

**Fecha:** 2026-09-01
**Hora:** 23:00
**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

## Resumen

Se implementó la iteración 1 de M73 Coleccionables como 1 autoload (`coleccionables`) sobre 3 archivos + tests. API idempotente con dedupe por id_global, progreso por categoría, persistencia M59 compacta, registro por fuente (minería/fauna/playa/ruinas/templo). Integración automática con M36 fauna_registry: cuando M36 emite `especie_avistada`, M73 registra el item correspondiente en la categoría "animales". **44 OK / 0 fallos** en test headless. M36 y M65 re-corridas sin regresiones.

## Cambios Realizados

### Archivos creados (3 + 1 test)

- `game/isla-ancestral/scripts/coleccionables/coleccionable_item.gd` — `ColeccionableItem` (Resource). 9 campos exportados: categoria, id_local, display_name, rareza, fuente, recompensa_item, recompensa_cantidad, puntos. `id_global()` compone `categoria_id_local`. `es_valido()` valida campos mínimos.
- `game/isla-ancestral/scripts/coleccionables/coleccionables_catalog.gd` — `ColeccionablesCatalog` (RefCounted). Carga `data/coleccionables/catalog.json` (futuro) con fallback in-code de 15 items en 4 categorías. API: `obtener`, `obtener_por_categoria`, `cantidad_total`, `cantidad_por_categoria`, `todas_las_categorias`.
- `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd` — autoload `coleccionables`. API:
  - `registrar(id_global)` — idempotente, emite `item_collected`
  - `registrar_por_local(categoria, id_local)` — vía catálogo
  - `registrar_por_fuente(fuente, id_local)` — infiere categoría
  - `es_collected`, `collected_count`, `total_count`, `porcentaje_categoria`, `porcentaje_total`
  - `obtener_collected_ids`, `obtener_categorias`
  - Persistencia M59 (get_section_name/get_save_data/restore_save_data)
  - Conexión automática a `fauna_registry.especie_avistada` con mapa hard-coded
  - Emite `categoria_completed` cuando se completa una categoría
- `game/isla-ancestral/scripts/coleccionables/test_coleccionables.gd` — 44 asserts OK / 0 fallos.

### Archivos modificados

- `game/isla-ancestral/project.godot` — autoload `coleccionables` registrado.

### Archivos de docs firmados (5)

- `DOCUMENTACION/73-Coleccionables/plan-actual/01-05` — firma de minimax-m3-free/Kilo Code + nota del agente en 05.

### Registros de orquestación

- `CHECKLIST-GLOBAL.md` — M73: 🔵 → 🟡 Liberado (iter 1, capa V0 + integración M36), 40/130.
- `Mensajes entre modelos/ESTADO-PARALELO.md` — reserva Liberada.
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — fila M73: Liberado.

## Validación

- **Compilación**: 0 errores tras 1 iteración de auto-corrección (`var X = Y if cond else Z` → `var X: Resource = null; if cond: X = Y`).
- **Test headless M73**: `godot --headless res://scripts/coleccionables/test_coleccionables.gd` → **44 OK / 0 fallos**.
  - Catalog: 15 items, 4 categorías, validación de ids.
  - Item: id_global, display_name, rareza, fuente, recompensa.
  - Registro idempotente: segundo `registrar` con mismo id no emite señal.
  - Registro por local + por fuente (mineria/fauna/playa/fuente_inexistente).
  - Progreso: collected_count, total_count, porcentaje_categoria (0.4 con 2/5 minerales), porcentaje_total (0.2).
  - Categoría completa: 4/4 animales = 100%, señal `categoria_completed` emite.
  - Señales: `item_collected` emitido 3 veces tras 3 registros, 0 tras re-registro.
  - Persistencia M59: 3 items, restore, version 0 ignorada.
  - **Integración M36**: emitir `especie_avistada(&"conejo_pradera", ...)` registra `animales_001`. Emitir `especie_avistada(&"salamandra_ancestral", ...)` registra `animales_004`.
- **Re-corridas**: M36 test_fauna 59/59 OK, M65 test_m65 23/23 OK. Cero regresiones.
- **Smoke test del proyecto**: bloqueado por errores pre-existentes en M14/M59/M64 (no introducidos por M73).

## Decisiones clave

1. **id_global compuesto** = `categoria + "_" + id_local` (ej: `minerales_001`). Evita colisiones entre categorías y mantiene el orden semántico. El método `id_global()` se llama una vez al validar y se cachea en el catalog.

2. **Doble API** de registro:
   - `registrar(id_global)` para sistemas que ya conocen el id completo.
   - `registrar_por_fuente(fuente, id_local)` para sistemas que solo saben dónde lo obtuvieron (M35 mineria, M33 cosecha, M34 pesca).
   - La conversión fuente→categoría está hard-coded en `_categoria_para_fuente()` (un match). Se puede mover a JSON si crece.

3. **Mapa hard-coded `especie_id → id_local`** en `_on_especie_avistada`: `conejo_pradera → animales_001`, `salamandra_ancestral → animales_004`, etc. Iter 2 debería leer `especie.id_local` directo de `FaunaSpecies` (requiere agregar ese campo a M36).

4. **Persistencia compacta**: solo guardo el set de ids collected (no el item completo). Al recargar, el manager consulta el catalog para reconstruir. Esto cumple con el requisito del plan (< 5KB).

5. **Recompensa solo se emite, no se entrega**: `categoria_completed` se emite con `(categoria, item, cantidad)`. M14 (Inventario) o M38 (Economía) deben consumirlo y entregar el item. Iter 1 no lo hace automáticamente para no romper el aislamiento del módulo.

## Lo que NO se hizo (honestidad)

- **UI del diario** (sección B del plan, 14 ítems): el manager expone `obtener_categorias()` y `obtener_collected_ids()`. La vista en sí es de M55 (Diario) o M53 (UI).
- **Entrega de recompensas al completar categoría**: el manager emite `categoria_completed`. M14/M38 deben consumirlo. Iter 1 no lo hace.
- **Conexión automática con M35 minería**: el manager expone `registrar_por_fuente("mineria", "001")` para que M35 lo llame manualmente. M35 no expone una señal pública estable todavía.
- **Catálogo completo 22 categorías × ~500 items** (el plan original). Iter 1 implementa la infraestructura + 4 categorías con 15 items. M93 (Contenido) o un agente de documentación puede poblar el JSON completo iter 2.
- **Iconos** (M46): el item tiene `display_name` pero no path de icono. M46 se encarga de generar los iconos.
- **Festival M74**: el plan menciona `PERFORMANCE_DONE` que el manager debe consumir. M74 está pendiente.
- **i18n** (M87): el item tiene `display_name` en español. Localización es de M87.

## Pitfalls documentados (memoria colectiva)

- **`var X = Y if cond else Z` infiere Variant**: GDScript 4.7 trata los warnings de tipo como errores en `--check-only` estricto. La forma correcta es `var X: Tipo = null; if cond: X = Y; else: X = Z`. Documentado en 07-GUIA-GODOT.
- **Lambda closures y variables locales**: `func(_id, _it): signal_count += 1` no incrementa `signal_count` del scope exterior (es local a la lambda). Usar `Array[bool]` o `Array[int]` como contenedor mutable: `var c = [0]; func(): c[0] += 1`.
- **Iterar dict.keys() con .erase()** sigue rompiendo el iterador en Godot 4. Usar `.keys().duplicate()`.
- **Plan escrito en C#/Unity en este proyecto Godot**: M73 también. Hay que traducir a GDScript consumiendo la API de los módulos ya implementados.
- **Autoload `coleccionables` y `fauna_registry` en test**: el orden importa. Si test_coleccionables accede a fauna_registry y este no existe, el test falla. Por eso se debe garantizar el orden de autoloads en project.godot.

## Próximo paso

- **QA cruzado (§21.8 AGENTS.md)** por Hy3 (WorkBuddy) — antes de `✅`.
- Mientras tanto:
  - **M55 (Diario)** puede consumir `obtener_collected_ids()` y `obtener_categorias()` para renderizar la vista.
  - **M14 (Inventario)** o **M38 (Economía)** pueden consumir `categoria_completed` para entregar recompensas.
  - **M37 (Museo)** puede recibir items via `registrar_por_fuente("ruinas", "001")`.
  - **M74 (Festival)** puede registrar performances via `registrar_por_fuente("festival", "001")`.

**Total: 3 archivos + 1 mod (project.godot) + 5 docs firmados + 44 tests OK + 40/130 ítems del checklist completados (resto [?] con dueño claro).**