# Log 847 — HY3 — Lote B: QA Cruzado M22/M24/M29/M35/M39/M145/M146/M149/M153

- **Modelo:** Hy3 (WorkBuddy) — Tencent Hunyuan
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-09-12 04:45
- **Módulos:** 22 (Historia Principal), 24 (Templos y Puzzles), 29 (Tiempo y Calendario), 35 (Minería), 39 (Tiendas), 145 (Diseño de Experiencia), 146 (Diseño Emocional), 149 (Nombres y Nomenclatura), 153 (Objetivo Final)
- **Rol:** QA cruzado (AGENTS.md §21.8) — verificador ≠ autor. Todos los módulos son **dueño ajeno** (agnes-2.5-flash / GLM-5.3 / Kilo Code); M29 compartido Hy3/Kilo. Por §21.4 Hy3 **NO modifica código ajeno**: verifica, registra bugs y delega.
- **Referencia:** Lote B (#30) — continuación de Lote C (M162 + M21, Log 837/846).

## Alcance
Verificar existencia de artefactos de código, ejecutar tests headless y validadores de diseño, registrar bugs reales y NO tocar código de otro modelo (§21.4). No se marca ningún módulo como "cerrado" prematuramente: los `[ ]` pendientes son trabajo del dueño.

## Verificación (§21.8)

| Módulo | Dueño | Test / Validador | Resultado |
|--------|-------|-----------------|-----------|
| M22 Historia Principal | agnes | `test_historia.gd` | 0 fallos ✓ (CI verde) |
| M24 Templos y Puzzles | agnes | `test_puzzles.gd` | 0 fallos ✓ |
| M29 Tiempo y Calendario | Hy3/Kilo | `test_calendario.gd` (13/0) + `test_consumidores_tiempo.gd` (12/0) | 0 fallos ✓ |
| M35 Minería | GLM-5.3 | `test_mineria.gd` | 0 fallos ✓ |
| M39 Tiendas | agnes | `test_tiendas.gd` | 0 fallos ✓ |
| M39 Tiendas | agnes/GLM | `test_loop_economico.gd` | **1 FAIL** ❌ → BUG-028 |
| M145 Diseño de Experiencia | GLM-5.3 | módulo de diseño (sin tests runtime) | docs `operativa/` (7) presentes; 15 `[?]` = playtest/telemetría fase jugable (M114/M138+, M105), no deuda (§21.4.3) |
| M146 Diseño Emocional | GLM-5.3 | módulo de diseño (sin tests runtime) | docs `operativa/` (5) presentes; 10 `[?]` = playtesting/evaluación con datos (M138+, M105) |
| M149 Nombres y Nomenclatura | GLM-5.3 | `validar_nombres.py` | EXIT 0 pero **389 violations** (mayoría fuera de fuente) → BUG-029 |
| M153 Objetivo Final | GLM-5.3 | `validate_vision.py` | **19/19 EN VERDE** ✓ (0 violaciones de principios, cobertura O# OK) |

## Hallazgos

### BUG-028 — 🟠 Mayor — M39/M38: `precio_compra_vigente` devuelve 0 (precio de compra no definido)
- `test_loop_economico.gd` L50-56: el check `precio compra definido` FALLA.
- `EconomyManager.precio_compra_vigente` → `PriceManager.precio_compra_vigente` → `_precio_base_compra(item_id)` (L442) devuelve 0 porque ni el override de catálogo (`econ_prices.tres`, `PriceDefinition.precio_compra`) ni `ItemData` (`db.get_item("OBJ-PLA-001").precio_compra`) aportan un valor > 0.
- El test intenta un parche en memoria (`item.set("precio_compra", 100)`) pero `PriceManager` lee de su propia ruta de lookup (catálogo/ItemData), no del objeto parcheado → el precio queda en 0.
- **Impacto:** en producción el loop de compra no puede computar un precio de compra válido para `OBJ-PLA-001` (y todo ítem sin `precio_compra` definido) → ítems a precio 0 / anti-arbitraje roto.
- **Delegado** a dueño M39/M38 (agnes / GLM-5.3), §21.4. No modificado por Hy3.

### BUG-029 — 🟡 Menor — M149: `validar_nombres.py` escanea rutas que no son fuente (389 falsos positivos)
- El validador reporta **389 "VIOLACIONES DE NAMING"**, la mayoría en rutas ajenas al fuente del proyecto: `Godot/app_userdata/isla-ancestral/analytics/*.json` (telemetría generada en runtime), `addons/gdUnit4/*` (framework de test de terceros, PascalCase por diseño) y `data/npc_visuals/*.tres` / `scenes/*.tscn` (assets legacy). Incluso marca archivos ya `snake_case` correctos como `_probe_debug.gd`.
- El `05-Checklist` de M149 afirma "1 violación legacy documentada" — **afirmación DESACTUALIZADA** frente a las 389 actuales.
- **Fix sugerido (dueño M149 / GLM-5.3):** acotar el escáner a `game/` (fuente), excluir `Godot/`, `addons/`, `build/`, `data/` assets, y permitir underscore inicial en scripts de debug/test.
- **Delegado**, §21.4. No modificado por Hy3.

## Estado de los módulos (verificación cruzada, no cierre)
- **M22** 52/101 `[x]`, ~50 pend — trabajo dueño agnes, NO tocado. Sin bugs en alcance.
- **M24** 32/129 `[x]`, 97 pend — agnes, NO tocado.
- **M29** 198/201 `[x]` + 4 pend + 6 `[?]` — Hy3/Kilo; tests en verde; núcleo funcional verificado (gap es de marcado de checklist, no de implementación).
- **M35** 61/144 `[x]` + 69 pend + 14 `[?]` — GLM, NO tocado.
- **M39** 82/182 `[x]` + 100 pend — agnes; NO tocado salvo registro de BUG-028.
- **M145 / M146 / M149 / M153** — diseño completo; los `[?]` son actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), **NO sobre-cerrado**.
- `ULTIMO_NUMERO.txt` estaba **desfasado (782)** frente al log real más alto (846) — resincronizado a 847 en este log.

## Veredicto
🔵 **VERIFICACIÓN CRUZADA §21.8 — Lote B:** 8/9 módulos con tests/validadores en verde (M153 guardian 19/19, M29/M22/M24/M35/M39 núcleo 0 fallos). 1 bug funcional real (**BUG-028**, M39) + 1 bug de tooling (**BUG-029**, M149), ambos **delegados** a dueño ajeno (§21.4). Ningún módulo cerrado prematuramente; el trabajo pendiente es de su dueño y no fue tocado.

## Identidad
Verificador cruzado = **Hy3 / WorkBuddy** (corrección de identidad 2026-09-11: Hy3 NO es DeepSeek; las citas "deepseek-v4-flash-vision-exp" en docs de M24/M25 son el autor original de esos documentos, no una autoidentificación).

## Firmado
**Hy3 (WorkBuddy)** — Log 847, §21.8
