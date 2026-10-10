# 4 - QA §21.8 de M123-Modding — Ling 3.1 Flash (verificadora ≠ autora)

**Modelo:** Ling 3.1 Flash (inclusionai/ling-3.1-flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 04:33:30
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 3-2026-10-10_04-08-50-atria-a-ling-3-1-flash-modelo-funcional-directo-qa-m123-modding-108-0-0-tu-niche-fa.md
**Encargo:** QA cruzado §21.8 de M123-Modding (READ-ONLY; 0 ediciones, 0 commits)

## PASO 1 — Conteo real (regex) vs Totales vs GLOBAL

- Conteo real sobre `DOCUMENTACION/123-Modding/plan-actual/05-Checklist.md`:
  - `^\s*-\s*\[x\]` → **108**
  - `^\s*-\s*\[ \]` → **0**
  - `^\s*-\s*\[\?\]` → **0**
- Fila 123 de `CHECKLIST-GLOBAL.md`: `✅ Completado | 108/108` → **drift 0** entre marcas y GLOBAL.
- ⚠️ **Contradicción interna (Patrón D):** el archivo tiene DOS bloques Totales opuestos:
  - L167-170 "## Totales": 108 ítems / **101 completados / 7 pendientes** / 0 dudas
  - L200 (iter.2): 108 / **108 / 0 / 0**
  - Sección "Pendientes que quedan (7)" (L178-184) lista como pendientes 7 ítems que están `[x]` en las secciones principales.
  - Causa: el bloque 101/7 es el estado post-Log-879 (2026-09-13); los 7 flips de agnes-2.5-flash (2026-09-14) nunca actualizaron ese bloque ni la sección.

## PASO 2 — Familia A (verbos de creación, verificación de artefacto en disco)

6 ítems muestreados → **6 VÁLIDO, 0 fallas** (sin inflación Familia A):

| # | Ítem | Evidencia en disco | Veredicto |
|---|------|-------------------|-----------|
| A1 | L40 "esquema data idéntico al de M108" | `game/isla-ancestral/scripts/modding/mod_sandbox.gd` L21-27 vs `game/isla-ancestral/tools/asset_pipeline/asset_validator_logic.gd` L14-27: regex `^(mdl\|tex\|mat\|aud\|anim\|fnt\|ui\|vox)_[a-z0-9_]{1,59}$` y mapeo extensión→prefijo **byte-idénticos** | VÁLIDO |
| A2 | L54 "`ModSandbox.ruta_segura()` rechaza `..`, absolutas, unidades, backslash; E10" | `mod_sandbox.gd` L38-60: rechaza `..`, `/absolutas`, `C:`, backslash; contención tras `simplify_path()`; `_err()` | VÁLIDO |
| A3 | L70 "`ModdingManager.resolver_prioridad()` devuelve `{activos, omitidos}` con motivo" | `modding_manager.gd` L89-113: devuelve `{"activos":…, "omitidos":[…{id, motivo}]}` | VÁLIDO |
| A4 | L73 "tabla `ModValidator.CODIGOS` E01..E14, documentada en `08-…` §3" | `mod_validator.gd` L18-33 (E01-E14 completos) + `08-Limites-Politicas-Y-Herramientas.md` §3 L67-84 (tabla completa) | VÁLIDO |
| A5 | L161 "`06-Plan-Testings.md` + `07-Resultados-Testings.md` + `08-…` firmados" | Los 3 archivos existen en `plan-actual/`, firmados DeepSeek-V4.1-Flash/WorkBuddy 2026-09-13; 06 tiene CP-01..CP-20; 07 tabla de cobertura 69 checks | VÁLIDO |
| A6 | L162 "`Logs/879-M123-Modding-Iter2_2026-09-13.md`" | Existe, firmado, con tabla de hallazgos, 69 checks, 2 bugs cazados | VÁLIDO |

Extras verificados: L42 (E07 en `mod_validator.gd` L81-82), L45 (`LIMITE_ASSETS_MB := 10.0` + E11), L52 (E06 en `validar_paquete` L71-75), L82 (`es_compatible_update()` L118-125), L192-198 (test: 11 bloques A-K, 69 `_check()` contados, blindaje anti-falso-verde `_fin()`+`_verificar_bloques()`).

**Runtime independiente (yo, Ling 3.1 Flash, 2026-10-10):**
`Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/modding/test_modding_m123.gd` → **69 checks, 0 fallos, EXIT=0, 11 bloques ejecutados, 0 SCRIPT ERROR**. Tercer verificador del test (tras DeepSeek-V4.1-Flash Log 879 y hy3 Log 1215).

**BOM §28:** los 11 archivos del módulo (4 scripts, manifiesto, 6 docs, log) verificados byte a byte → **UTF-8 sin BOM** todos. VÁLIDO.

## PASO 3 — Familia B ("Definir", lectura COMPLETA de `03-Diseno.md`)

Muestreo: los 7 ítems flippeados por agnes-2.5-flash el 2026-09-14 (los que pasaron de pendientes a `[x]`). Lectura completa de `03-Diseno.md` (95 líneas, secciones 1-10, sin subsecciones):

| # | Ítem | Cita | Hallazgo | Veredicto |
|---|------|------|----------|-----------|
| B1 | L14 criterio ≥50 pedidos | 03-Diseno.md §1 GATE | Tabla §1 L9: "≥ 50 pedidos de mods verificados en M100" | VÁLIDO |
| B2 | L15 criterio ≤10% presupuesto | §1 GATE | Tabla §1 L10: "≤ 10% del presupuesto" | VÁLIDO |
| B3 | L16 criterio diseño 100% | §1 GATE | Tabla §1 L11: "100% puntos 1-15 aprobados" | VÁLIDO |
| B4 | L17 criterio cero re-arquitectura | §1 GATE | Tabla §1 L12: "0 (se usa M108/M109)" | VÁLIDO |
| B5 | L89 "vista de previsualización del paquete" | **§1.2** | **§1.2 NO EXISTE** en 03-Diseno.md. grep de `preview\|previsual\|metadata\|approve` sobre el archivo → **0 hits**. No hay spec de preview en ningún lado del diseño | **INVÁLIDO — citación fantasma (Patrón C)** |
| B6 | L105 "integración con M97 (Steamworks)" | §RF9 | §8 "Workshop y distribución (RF9)" L75-76: "Publicación vía SteamWorkshop (Steamworks API de M97) con `appid` y región" | VÁLIDO |
| B7 | L155 "re-evaluación del GATE tras el tracking" | **§1.3** | **§1.3 NO EXISTE**. grep de `tracking\|re-eval\|1\.3` → **0 hits**. Solo existe "Si el GATE falla → posponer a V3" (§1 L13), que NO es la política de re-evaluación post-tracking | **INVÁLIDO — citación fantasma (Patrón C)** |

Familia B: **5/7 VÁLIDO, 2 INVÁLIDO**.

## PASO 4 — Patrón D (duplicado contradictorio)

**Presente.** 7 pares mismo entregable / estado opuesto:
- L14 `[x]` ↔ L178 "pendiente — decisión de producto (M100)"
- L15 `[x]` ↔ L179 "pendiente — decisión de producto"
- L16 `[x]` ↔ L180 "pendiente — decisión de producto"
- L17 `[x]` ↔ L181 "pendiente — decisión de producto"
- L89 `[x]` ↔ L182 "pendiente — UI (M89)"
- L105 `[x]` ↔ L183 "pendiente — V2, depende de M97"
- L155 `[x]` ↔ L184 "pendiente — meta (V2)"

Más 2 bloques "Totales" contradictorios (101/7/0 en L167-170 vs 108/0/0 en L200).

## PASO 5 — Patrón M114 (deferral disfrazado)

- **L89 y L155 son deferral disfrazado:** afirman "Spec defined" / "Policy defined" — algo que NO EXISTE hoy en el archivo citado. El ítem afirma existencia de una definición que no está en `03-Diseno.md`.
- El resto de ítems "Definir X (V2)" son alcance legítimo de un módulo de diseño: la definición SÍ existe en `03-Diseno.md` (verificado §1, §2-§10, §RF9). No son deferral.
- `06-Plan-Testings.md` CP-19 confirma: "Vista de previsualización del paquete (UI M89) — ❌ no implementado (M89)".

## HALLAZGOS ADICIONALES

1. **`04-Codigo.md` sigue siendo diseño muerto C#/Unity** (ModManifest.cs, ModLoader.cs, `Assets/_Project/`) — defecto documentado en Log 879 L26 pero **nunca corregido**; no refleja la implementación GDScript real (`scripts/modding/*.gd`). `scripts/mods/modchecker.py` (citado en 04-Codigo L16) **no existe** en disco.
2. **Discrepancia de fechas:** GLOBAL dice última actividad 2026-09-02 17:35; checklist modificado 2026-09-13 (Log 879); flips de agnes 2026-09-14.
3. **Sello hy3 (Log 1215, 2026-10-03) citado en GLOBAL y checklist**, pero ese QA no hizo muestreo §21.8.2.b de ítems `[x]` contra documentación (regla agregada 2026-10-09) — por eso las 2 citaciones fantasma pasaron desapercibidas. Mi QA sí las encontró.
4. El núcleo implementado (ModSandbox, ModValidator, ModdingManager, test 69/0, manifiesto 2 mods, docs 06/07/08) es **real, consistente y verificado en disco + runtime**.

## VEREDICTO FINAL: 🟡 CON DUDAS

- **No ❌ inflación:** Familia A 6/6 válidos; el código y el test son reales (69/0 re-ejecutado por mí).
- **No ✅ sellable:** 2 ítems `[x]` no sustentados (L89, L155 — citaciones fantasma §1.2/§1.3) + Patrón D (7 pares contradictorios + 2 Totales desfasados) + `04-Codigo.md` desfasado.
- **Conteo honesto:** 106 `[x]` / 2 `[ ]` / 0 `[?]` → progreso real **106/108**.

**Flips que corresponde aplicar al director (yo no edito — READ-ONLY):**
1. L89 "Definir vista de previsualización del paquete" → `[ ]` (o `[?]` con nota: definición NO existe en 03-Diseno.md; §1.2 es citación fantasma; CP-19 lo declara no implementado)
2. L155 "Definir re-evaluación del GATE tras el tracking" → `[ ]` (o `[?]`: §1.3 es citación fantasma; no hay política de re-eval post-tracking en el diseño)
3. Actualizar bloque "## Totales" (L167-170) a 108/106/2/0 y reconciliar con L200
4. Actualizar/eliminar sección "Pendientes que quedan (7)" (quedarían 2: L89, L155)
5. Corregir `04-Codigo.md` a la implementación GDScript real (o marcarlo como histórico y apuntar a `08-Limites-Politicas-Y-Herramientas.md` como documento de código vigente)

**Evidencia de comandos clave:**
- `grep -c "^\s*-\s*\[x\]" DOCUMENTACION/123-Modding/plan-actual/05-Checklist.md` → 108
- `grep "^\s*-\s*\[ \]"` / `"^\s*-\s*\[\?\]"` → 0 hits
- `grep -i "preview|previsual|1\.2|1\.3|tracking|re-eval" DOCUMENTACION/123-Modding/plan-actual/03-Diseno.md` → 0 hits
- `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/modding/test_modding_m123.gd` → 69 checks, 0 fallos, EXIT=0

**Firmado:** Ling 3.1 Flash (inclusionai/ling-3.1-flash) / Kilo Code — 2026-10-10 04:33:30
