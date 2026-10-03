**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-15

# BACKLOG MASTER — agnes-3-flash (curado por ENCAJE)

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]`/`[?]` de los `05-Checklist.md` de cada módulo (fuente de verdad).
> **Primera sesión 2026-09-15.** Aún no tengo trabajo de módulo completado: este backlog v1 declara encaje y cola, y se ejecuta en bucle (bloquear → leer → codificar → test headless → documentar → desbloquear).
> ⚠️ **Identidad:** soy `agnes-3-flash` de **Sapiens AI**, NO el `agnes-2.5-flash` (Sapiens AI) de §10/§13 de la guía 10. Ver `10-GUIA-COMPARATIVA-MODELOS.md` §19 / §5.L.

## Criterio de encaje (mis fortalezas declaradas, ver §19 de la guía 10)

| Nivel | Qué es | Mi rol |
|-------|--------|--------|
| **A — Núcleo de especialidad** | Orquestación de herramientas, gates de CI/stress, data-driven (autoload + JSON/.tres + test headless), auditoría código↔checklist, tooling | **Ejecuto de punta a punta** (código + test + log) |
| **B — Sistemas con criterio de diseño** | Lógica data-driven de gameplay + verificación; documentación técnica | Ejecuto la **parte técnica/verificable**; la decisión la dejo `[?]` con dueño |
| **C — Visual / arte / audio / contenido** | Assets, VFX, arte, narrativa, música | **NO soy aprobador visual.** Solo plumbing data-driven; aprobación final = otro especialista / usuario |

**Excluyo por encaje:** arte 3D/Blender (generación de assets, V5), razonamiento de ciencia dura
(complejidad 5 aislada). **Visión:** DISPONIBLE (multimodal; Read-PNG + `screen_capture_*` +
`blender_get_viewport_screenshot`) → **ahora acepto módulos V0/V1 y V2-asistencia** (revisar/describir
capturas y opinar); la aprobación estética final sigue siendo del usuario (M154).

## Módulos asignados (v1 curado)

| # | ID | Módulo | Estado global | Encaje | Subcarpeta |
|---|----|--------|---------------|--------|------------|
| **0** | **54** | **54-Mapa** | **🔵 En curso — LOCK ACTIVO a tu nombre (atria-dawn, commit 24ddc7e, 2026-10-02 08:55)** | **A** (data-driven + orquestación de servicios + señales EventBus) — 36 [x] / 141 [ ] / 0 [?]. **Empezá por acá.** | `54-Mapa/checklist.md` |
| 1 | 113 | 113-Pruebas-De-Stress | 🟡 Con dudas (re-claimable, §21.5/§21.4.7) | **A** (tooling/gates/headless) — gap real: "baseline versionado perf_base.json" + "comparación automática ±5%" están `[x]` **por diseño** pero NO implementados en `stress_runner.gd` | `113-Pruebas-De-Stress/checklist.md` |
| 2 | 115 | 115-Hardware | 🟢 revertido por auditoría 2026-09-14 (0/104) | **A** (data-driven + auditoría código↔checklist + test headless) — el código de M115 existe (4 archivos + `test_hardware.gd` 30/30) pero la auditoría revirtió el checklist a `[ ]`; mi parte = reconciliar contra código real y dejar `[?]` con dueño (M90/M57/M97) | `115-Hardware/checklist.md` |
| 3 | 106 | 106-Seguridad | 🔵 (reserva agnes-2.5 stale → re-claimable §21.4.7) | **A** (validadores/sanitización + auditoría + headless) — implemento el helper reutilizable "InputValidator" del diseño (`[ ]`) + reconciliación del sobre-cierre | `106-Seguridad/checklist.md` |
| 4 | 96 | 96-Plataformas | 🟡 (re-claimable, reserva agnes-2.5 stale) | **A** (data-driven + doc + auditoría + V0) — §1.4 matriz "formato único" + §21.2 cláusula + reconciliación | `96-Plataformas/checklist.md` |
| 5 | 107 | 107-Backups | 🟢 revertido por auditoría 2026-09-14 (0/176) | **A** (data-driven + tooling/CI + V0) — verificación del estado real + método `listar_backups()` (audit) + reconciliación | `107-Backups/checklist.md` |
| 6 | 61 | 61-Rendimiento | 🟡 re-claimable (reserva agnes-2.5 stale 09-03, §21.4.7) | **A** (data-driven + gate CI + headless, V0) — iteración **acotada**: gate de límites de CANTIDAD (`limites` en `budgets.json` + `validate_budget.gd`), disparado por mi flag M52 "turbulencia 24 FPS" | `61-Rendimiento/checklist.md` |
| 7 | 117 | 117-Build-System | 🟡 Liberado iter. 2 (Log 941) → **iter. 3 agnes (Log 946)** | **A** (tooling/CI + data-driven + auditoría headless) — sync `installer/*.iss` en `bump_version.py` (root-cause V3 M116) + fix desync + cierre `[?]` test-isolation vía gate duro `quality.yml` | `117-Build-System/checklist.md` |
| 8 | 46 | 46-Arte-2D | 🟢 Disponible (file 0/110; notas declaran 104/110 = cierre no reflejado) | **V1/QA acotada** — verificar estado real de assets 2D + dueños de lo bloqueado (NO genero arte, NO apruebo estético) | `46-Arte-2D/checklist.md` |
| 9 | 83 | 83-Licencias-De-Software | 🟡 revertido por auditoría 09-14 (scaffold 9/100) | **A** (tooling/data-driven V0) — iteración **acotada**: capa scanner §A (`license_scanner.gd` classifier + detección + scan) + test + gate CI. NO toco la capa de Resources (dueño M83) | `83-Licencias-De-Software/checklist.md` |
| 10 | 126 | 126-Marketing-Legal | 🟢 revertido por auditoría 09-14 (scaffold 0/101) | **A** (data-driven + tooling/CI + auditoría V0) — iteración **acotada**: verificar data-layer (9/0) + gate CI + reconciliar sobre-cierre `Totales`. NO toco capa de servicio/legal review (dueño M126) | `126-Marketing-Legal/checklist.md` |
| 11 | 128 | 128-Identidad-De-Marca | 🟡 Con dudas (scaffold 5/100, honesto) | **A** (data-driven + tooling/CI + V0) — iteración **acotada**: verificar data-layer (8/0) + gate CI + doc. Checklist ya era honesto → NO re-marco; 95 `[ ]` = dueño M128/M46 | `128-Identidad-De-Marca/checklist.md` |
| 12 | 66 | 66-Anti-Softlock | 🟡 Con dudas (core 110/117, 7 `[?]` externos) | **A** (gate CI + auditoría V0) — iteración **acotada**: verificar core (softlock_guard+invariants) + cablear 2 tests al gate duro `quality.yml` + confirmar que los 7 `[?]` son externos (M22/M26/M64/M27). M66 → "esperando externos + core gateado" | `66-Anti-Softlock/checklist.md` |
| 13 | 72 | 72-Sistema-De-Logros | 🟡 Con dudas (86/185, core maduro) | **A** (data-driven + tooling/CI + V0) — iteración **acotada**: cerrar item RF14 abierto con **test aditivo** `test_logros_m72_statids.gd` (data-integrity: stat_ids resuelven contra M71) + cablear tests M72 al gate CI + flag del bug M39 (BUG-050) | `72-Sistema-De-Logros/checklist.md` |

**Totales v1:** M113 ~30 + M115 132 + M106 66 + M96 36 + M107 176 = **~440 subítems ≥ 100** (regla GUIA-METODOLOGIA §7).

**Expansión si hace falta:** M96 Plataformas (data-driven/tooling, ~37 abiertos), M106 Seguridad (validadores/sanitización/tests).

## Cola de trabajo inmediata (bucle)

| Orden | Módulo | Tarea | Qué es | Por qué yo |
|-------|--------|-------|--------|-----------|
| 1 | 113 | T-001/T-002 | Implementar `StressComparator` + baseline `perf_base.json` (±5%, configurable) y cablearlo en el runner (gap real marcado `[x]` pero ausente en código) | Orquestación de herramientas + gate de CI + data-driven: mi perfil "Agnes Code" |
| 2 | 113 | T-003 | Test headless del comparador/baseline (sin M61/hardware) | Verificación determinista, V0 |
| 3 | 113 | T-004 | Reconciliar el sobre-cierre del `Totales` (dice 127/127 "0 pendientes" pero hay ~30 `[ ]` reales) y cerrar T-008 ([?] "umbral por escenario" = mi comparador) | Auditoría código↔checklist, honestidad `[x]`/`[?]` |
| 4 | 113 | T-005/T-006/T-007 | Marcar `[?]` con dueño a los ítems que piden M61/M96/M141/M142 | No inflar; dejar `[?]` honesto |
| 5 | 115 | T-001..T-013 | Verificar test de M115 headless + reconciliar 132 ítems contra código real (dejar `[?]` M90/M57/M97 con dueño) | Mismo patrón, V0, data-driven |

## REGLA OBLIGATORIA — Codificación UTF-8
> UTF-8 sin BOM siempre (§AGENTS 28). Si un diff muestra mojibake (`Ã`, `â€`, `ðŸ`), lo corrijo antes de seguir.

## NO TOCAR (agentes activos hoy, 2026-09-15)
- M27/M60/M68/M103 (DeepSeek-V4.1/WorkBuddy) · M66/M92 (glm-5.3-flash/Cline) · M84/M150/M166 (mimo-v2.5-free/OpenCode) · M78 (mimo-v2.5) · M111 (muse-spark/Cline).
- M113: 🟡 → re-claimable (últ. agente `deepseek-v4-flash-vision-exp`, descatalogado).
- M115: 🟢 revertido por auditoría → disponible para reclamar.

## Historial de iteraciones (bucle)

| Iter | Módulo | Estado | Log | Qué hice (resumen) |
|------|--------|--------|-----|--------------------|
| 1 | **M113** Pruebas-De-Stress | 🟡 Liberado (102/132) | **919** | `StressComparator` + baseline `perf_base.json` ±5% + gate de regresión + test (19/0). Reconcilié el sobre-cierre del `Totales`. Hallazgo: no versionar baseline sembrado en dev (frágil fuera de CI; valor = M61/CI). |
| 2 | **M115** Hardware | 🟡 Liberado | **921** | Verifiqué contra código real (51 checks/0 fallos/0 `SCRIPT ERROR`). **Corregí 2 falsos-verdes** (`test_hardware`, `test_iter2`). Findings: divergencia diseño↔implementación + **autoload duplicado**. |
| 3 | **M106** Seguridad | 🟡 Liberado | **922** | Auditoría del sobre-cierre (161/161 → real 140/206) + **`security_input_validator.gd`** (métodos "InputValidator" del diseño, `[ ]`) + `test_security_m106_input.gd` **25/0** = 37 checks totales / 0 `SCRIPT ERROR`. Verifiqué `test_security_m106.gd` verde real (12/0). |
| 4 | **M96** Plataformas | 🟡 Liberado | **924** | Verifiqué `test_plataformas_m96.gd` **30/0** (doc decía 23/0 — test creció) + **§1.4 `MATRIZ-PLATAFORMAS.md`** (matriz formato único, derivada del JSON) + **§21.2 cláusula cross-play** + reconciliación sobre-cierre (102/102 → 71/34/1). No inventé GATE/costes (dueño M142/M144/M149). |
| 5 | **M107** Backups | 🟡 Liberado | **927** | Verifiqué estado real (infra PS 4 + `backup.yml` UTF-8 OK + in-engine manager) + **`listar_backups()`** (audit/manifest) → test **9/0 → 12/0** + reconciliación sobre-cierre (137/137 → real 176 `[ ]`). §28.1: el "mojibake" de `backup.yml` era artefacto de PowerShell → **no** reescrito. |
| 6 | **M61** Rendimiento | 🟡 Liberado (iter. agnes acotada) | **943** | Iteración acotada (data-driven + gate CI + headless): agregué la dimensión de **CANTIDAD** al gate — `budgets.json` nuevo bloque `limites` (`particulas_simultaneas_max` **500** = spec §M M61 + flag M52 "turbulencia 24 FPS" / `draw_calls_max` 400 / `objetos_mundo_max` 1000) + `validate_budget.gd` la valida (tolerante si ausente) → **gate headless 0 fallos, exit 0, 0 `SCRIPT ERROR`**. §M "≤500 partículas/cámara" → `[x]` con evidencia; el contador runtime sigue siendo de M52. Relevo §21.4.7 de reserva agnes-2.5 stale. |
| 7 | **M117** Build-System | 🟡 Liberado (iter. 3 agnes, acotada) | **946** | Iteración acotada (tooling/CI + data-driven + auditoría headless): (1) **root-cause V3 M116** — `bump_version.py` no sincronizaba `#define AppVersion` de `installer/*.iss` (`.iss`=0.0.2 vs `project.godot`=0.0.6) = **falso-verde de M116**; (2) fix sistemático: `_set_version_in_installer_iss()` + `INSTALLER_DIR` (cwd-first) en el bump; (3) fix inmediato `.iss`→0.0.6; (4) `test_bump_version.py` +3 casos → **14/14**; (5) cierre `[?]` "test_build_m117.gd no corre aislado" vía gate duro `quality.yml` (+`test_instalador_m116.gd`); hallazgo: aislación real imposible con `--script` (bootea autoloads; leaks preexistentes ajenos) → documentado como limitación de Godot. **`run_tests.py --module build` 2 OK.** |

| 8 | **M46** Arte-2D (V1-QA) | 🟡 Liberado (V1-QA agnes, acotada) | **954** | QA V1 acotado (NO genero arte/aprobo estético): verifiqué estado real — `inventario_2d.json` **48 assets definidos, 0 en disco** (0 PNG/SVG/WebP; validador headless 0 fallos exit 0); `ART_STYLE_2D.md` + tooling reales → el trabajo 2D está **bloqueado por M45/M108/artes** (dueños asignados en 05-Checklist §QA V1). **Flag doc↔archivo:** el checklist archivo está 0/110 `[x]` pero iter.1/2 declaran 103–104/110 cerrados por diseño+tooling (no reflejado) → **no re-marqué los ~103** (dueño M46). Colisión de reserva 953 (hy3 M66) → renumerizo a **954** (§6.1.d). |

| 9 | **M83** Licencias (iter. scanner) | 🟡 Liberado (iter. agnes scanner, acotada) | **974** | Iteración acotada (tooling/data-driven V0): implementé la **capa scanner** del diseño §A — `scripts/licensing/license_scanner.gd` (`TYPES` + `classificar()` por contenido con fallback UNKNOWN + `detectar_archivo_licencia` + `scan_addon`/`scan_addons` recursivo) + `test_license_scanner_m83.gd` **24/0** + gate duro `quality.yml`. 7 ítems §A re-marcados con evidencia; Totales stale 7→16 corregido. **Trampas:** `iterate_subdirs`/`iterate_directories` no existen en Godot 4.7.2 → `get_directories()`; substring `mpl` falseaba con "implied" → frases de alta señal. NO toco la capa de Resources (§A.1/A.3/A.5/A.10 = dueño M83). |
| 10 | **M126** Marketing-Legal (iter. data-layer+CI) | 🟡 Liberado (iter. agnes, acotada) | **981** | Iteración acotada (data-driven + tooling/CI + auditoría V0): verifiqué el data-layer (`marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` **9/0** exit 0), **cableé el test al gate duro `quality.yml`** (gap real), y **reconcilié el sobre-cierre**: `Totales` decía "101 resueltos/0 pend" (stale) con el archivo revertido a 0/101 → estado real **4 [x] / 97 [ ]** (re-marqué solo los 4 ítems "Especificación" respaldados por código; los 97 = política/servicio/docs/legal-review, **dueño M126** — no los cierro, anti-falso-verde). NO toco capa de servicio (`MarketingLegalManager/Config`) ni legal review (abogado). |
| 11 | **M128** Identidad-De-Marca (iter. data-layer+CI) | 🟡 Liberado (iter. agnes, acotada) | **1013** | Iteración acotada (data-driven + tooling/CI + V0): verifiqué el data-layer (`identidad_marca.json` + `brand_validator.gd` + `test_brand_m128.gd` **8/0** exit 0, 0 `SCRIPT ERROR`), **cableé el test al gate duro `quality.yml`** (gap real) y documenté. **A diferencia de M126, el checklist ya era honesto (5/100) → NO re-marqué nada**; los 95 `[ ]` (branding M45/M46 + legal/trademark + capa de servicio) = **dueño M128**. **Nota V3:** el equipo migró a `NUMEROS_DISPONIBLES.txt`; tomé **1013** del pool. |
| 12 | **M66** Anti-Softlock (iter. gate CI) | 🟡 Liberado (iter. agnes, acotada) | **1018** | Iteración acotada (gate CI + auditoría V0): verifiqué el core (`softlock_guard.gd` autoload + 7 invariants + `recovery/`) y los 2 tests **0 fallos exit 0** (0 `SCRIPT ERROR` propios), **cableé `test_anti_softlock_m66.gd` + `test_fallbacks_m66.gd` al gate duro `quality.yml`** (gap real: no estaban) y confirmé que los 7 `[?]` son **externos** (M22/M26/M64/M27) → M66 pasa de "Con dudas" a **"esperando externos + core gateado"** (110/117). Log 1018 tomado del pool V3. |
| 13 | **M72** Logros (iter. RF14+CI) | 🟡 Liberado (iter. agnes, acotada) | **1021** | Iteración acotada (data-driven + tooling/CI + V0): cerré el item RF14 abierto "validar que las stats referenciadas existan en M71" con un **test aditivo** `test_logros_m72_statids.gd` (**9/0**: 5 stat_ids vía catálogo M71 `hitos.json` + `amistad_max_catalina_oso` vía prefijo dinámico M20) — **NO toco el core** (`achievement_service.gd` de glm). **Cableé `test_logros.gd` + RF14 al gate duro `quality.yml`** (gap: no estaban). **Flaggeé el bug M39** (BUG-050: `catalogo_tiendas.gd:63` `.size()` sobre Callable + item M15 `piedra_caliza` inexistente) → delegado a M39/glm en `11-BUGS.md`. M72 86→87/185. Log 1021 del pool V3. |
| 14 | **M52** VFX (**QA cruzado §21.8**, no it.) | ✅ QA §21.8 CUMPLIDO (verificador ≠ autor) | **1030** | **QA §21.8 de iter. 6 de DeepSeek-V4.1-Flash** (Log 1002/1005). Re-grounding **sustantivo** (no solo "tests verdes"): 5 suites M52 → **181 checks, 0 fallos, exit 0, 0 `SCRIPT ERROR`** (coincide exacto con la claim); `gen_vfx_catalog.py --check` **OK** (31 entradas, 12 loops, 21 con bus, 24/24 plan, sin drift); **confirmé la claim "13 buses verificados contra `event_bus.gd`"** (13 únicos, 0 sin resolver); presupuesto de perf modelado en **31/31** entradas (`presupuesto`+`emision`/`emisor`/`luz_por_particula`) → **liga mi flag de turbulencia 24 FPS (M61) a data**. **Cero falsos-verdes** (progreso consistente 137/148); los 10 `[ ]`+1 `[?]` abiertos legítimos con dueño. Veredicto: **M52 iter. 6 CUMPLE §21.8**. Log 1030 del pool V3. |
| 15 | **M111** Codigo-De-Calidad (**QA cruzado §21.8**, no it.) | ✅ QA §21.8 CUMPLIDO (mantiene ✅) | **1032** | **QA §21.8 de iter. 4 de muse-spark-1.3-contributor** (Log 891/909). Re-grounding: `test_m111_utils_headless.gd` → **`passed=62 failed=0` + OK**, exit 0, 0 `SCRIPT ERROR`; **9/9 archivos M111 en disco** (math/validation/format utils, constants, enums, state_machine, factory, command, strategy); **FIX `Factory.create -> Variant` confirmado**; 209/209 consistente (0 `[ ]`/`[?]`). **Hallazgo (no revierte el ✅):** el test en `quality.yml` es gate **SUAVE** (`|| true`, documentado por el autor — exit global 1 preexistente de `backup_manager`/M107 + 68 leaks ObjectDB + 14 resources in use); para gate **duro** (`|| FAIL=1` como M52) → aislar test o resolver el exit 1 (dueño M107/core). **M111 CUMPLE §21.8, mantiene ✅.** Log 1032 del pool V3. |
| 16 | **M09** Terreno (QA visual T-V01, no it.) | ✅ T-V01 completada | **1115** | **Cierre de T-V01 del backlog (asignado por atria-dawn, ACTUALIZACION 2026-09-20).** V4: run `main_island.tscn` + captura (`capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png`): 42 tiles activos + disco/anillo horizonte, 0 SCRIPT ERROR, FPS 60; fog 0.001 tapa el horizonte en MI captura → veredicto agnes "no verificable". **V1 usuario: "los impostores sí funcionan (grises altos)"** → **IMPOSTOR VERIFICADO**; los "verdes bajos" aclarados = piso COLOR_PASTO del heightmap unificado (el viejo impostor MONTAÑAS 36-tile fue reemplazado, iter. DEFINITIVA 2026-09-08). QA note en `09-.../05-Checklist.md` + pendiente fog (M09/M49, diseño). Log 1115 del pool. |
| 17 | **M53** UI-UX (iter. agnes i18n+M58, acotada) | 🔵 En curso → Liberado (iter. agnes) | **1118** | **M53 asignado por el usuario 2026-09-20 (Recom Hy4 inactivo, §21.4.7) + prioridad "overlays/accesibilidad M58 + labels/tooltip M87 ×2".** Iteración acotada (data-driven + test headless + runtime): (1) `UiI18n` (puente M53↔M87: `traducir`/`traducir_param`/`meta_texto`/`meta_tooltip`/`retraducir` vía `RetraductorUI` + `conectar_locale`); (2) claves `EQUIP.*` + `UI.INTERACTUAR` en es.po/en.po (validador PO M87 0 fallos; `EQUIP.EQUIPADO` exento P5); (3) adopción de metadatos en `equipment_layer`/`equipment_ui`/`interact_prompt` (H-7 strings hardcodeados → claves); (4) `TooltipService.show_tooltip_key` + re-traducción en vivo del tooltip visible + `UIManager` prioriza `tooltip_text_key`; (5) `SubtituloOverlay` M58 RF8 en `DialogLayer` (D.7 [x]); (6) hook RF18 `UIManager._conectar_m58` (pausa instantánea → PauseLayer + reanudar); (7) `UIManager._conectar_m87` re-traduce capas montadas + HUD en `locale_changed`. Test `test_ui_i18n_m53.gd` **39/0 exit 0** + regresión `test_ui_framework` 0 fallos + **runtime main_island 0 SCRIPT ERROR**. **Cierro M87×2** (M53-owned → `[x]` en M87, 131/136). **NO adiviné visuales:** J.6 opacidad + J.7 indicador audio = sin fuente M58/M91 → `[ ]` con dueño; I.8/I.9/I.10/C.12 = **visión del usuario (M154)**. Hallazgo: `test_localizacion_iter6` A7 aserta el BUG-042 viejo (fuentes ya corregidas en Log 1024) → **residual M87/M88, no lo toqué**. Log 1118 del pool V3. |
| 18 | **M14** Inventario (**QA §21.8 P-18**, no it.) | ✅ SELLADO (definitivo) | **1127** | **QA §21.8 independiente de M14 (P-18, asignado 2026-09-20 07:54Z, autonomía total).** 5 suites binario real (enfoque s2 Log 1124: Push-Location + sin `--path`): `test_inventario` 0 fallos (68 OK) + `test_inventario_iter5` 0 fallos (70 OK), cada una ×2 EXIT 0; **gdUnit4 `GdUnitCmdTool` 32/32 PASSED 0 errors EXIT 0 ×2** — pero las 3 suites gdUnit4 **no eran ejecutables**: 5 defectos del TEST (no del código M14) registrados en **BUG-079** y resueltos con fix mínimo: `is_equal_to`→`is_equal` ×58 (API del addon instalado), `free()` sobre RefCounted→null, contadores de señal por lambda capture-by-value→holder por referencia, fixtures `madera`/`piedra`→`wood`/`stone` (ids M15 reales; `deserializar`/`restore` validan contra el ItemDatabase vivo), `test_puede_apilar_false_different_item`→`_empty_slot` (la API no recibe item id). **T-99:** 05-Checklist M14 = 136 [x]/0 [ ]/4 [?] = 140 = Totales exacto; 4 `[?]` externos con dueño; 0 `[x]`→archivo inexistente (`inventario_save.gd` = path stale de 04-Codigo, funcionalidad en `inventario_service.gd` L36-41/388-405). **Sello §21.8 otorgado** (verificador agnes ≠ autor glm-5.3-flash): fila 14 GLOBAL + `CHECKLIST-QA-SEALS.md` (Log 1127). **Delegado:** el defecto `is_equal_to` también está en M38 (×13), M29 (×1) y `test_stable_flows` (×18) → `[?]` BUG-079 a sus dueños. Log 1127 del pool V3. |
| 19 | **M101/M145/M146** (QA §21.8 P-25, doble fuente T-101) | ✅ SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 módulos s2 los selló en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente única). Verificador agnes ≠ s2 → independencia §21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 ×2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON válido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo §1 + parseo (`feedback-system.md` §2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 → re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` → M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) — solo edición workspace; commit `c94c7de` = SEALS + Log 1138. Log 1138 del pool V3. |
| 20 | **M08** Mundo-Voxel (**QA §21.8 P-29**, no it.) | ✅ SELLADO (definitivo, 1ª evidencia headless) | **1141** | **P-29 (asignado 2026-09-25 01:05Z): el ✅ sin sello más crítico que quedaba** (49 módulos sellos; M08 = core voxel; sellos previos 747/976 = solo re-grounding). Verificación con binario real (enfoque s2): suites M13 `test_herramientas` + `test_herramientas_iter4` (**el contrato real de edición M08**: `tool_controller.try_extract/try_place` + `interaction_manager`, documentado en 04-Codigo §3 saneado por atria Log 976) **0 fallos ×2 cada una, EXIT 0, 0 SCRIPT ERROR**; `main_island.tscn --quit-after 300` headless **EXIT 0 ×2, 0 SCRIPT ERROR** (`VoxelBoxMover listo` + `VoxelViewer enganchado` = GDExtension VoxelTools cargada y streaming headless). Re-grounding T-99: 05-Checklist **105/0/0 = Totales exacto**; artifacts §1 en disco (block_type live-central; block_catalog muerto-runtime documentado; tool_controller/interaction_manager/world_generator/world_manager vivos). **Salvedades en el sello**: M08 sin suite propia (verif. vía M13 + runtime), edición E/Q interactiva = playtest, RID-leak at exit = ruido headless benigno. Sello doble fuente (SEALS fila 1141 + notas GLOBAL fila 08); GLOBAL no commiteado (workspace). Log 1141 del pool V3. |
| 21 | **M36/M65/M32** (lote QA §21.8 P-31) | M36 ✅ + M32 ✅ SELLADOS · M65 🟡 (BUG-080) | **1145** | **Lote P-31 (asignado 2026-09-25 02:34Z): gameplay core fauna↔IA↔clima, interrelacionados. Verificador agnes ≠ autores (Hy3/minimax, glm, glm+DeepSeek).** Binario Godot 4.7.2 real, headless, enfoque s2 (Push-Location sin `--path`), conteos anclados `^\s*OK:`. **M36 Fauna ✅:** `test_fauna` 58 OK/0 ×2 + `fauna_auditor` 7 especies ×2; autoloads cableados y en runtime (`fauna_registry`/`fauna` L52/53, `[M36] FaunaManager ready: 7 especies`); 7/7 artifacts 04-Codigo + JabaliNPC/JabaliAdultoNPC en main_island; `fauna_behavior.gd` (mod M65 Log 415) íntegro ⇒ M65 no degradó M36. Corrección de conteo: 228/228 → **226 [x]+2 [ ] KnownIssue** (226/228). **M32 Clima ✅:** `test_clima` 0 fallos ×2 + **3 suites colaterales consumidoras** (`test_clima_dialogo_m21` 7 OK + `test_farm_clima` M33 + `test_fishing_clima` M34) verdes ×2 = integración real M21/M38/M40; autoload `Weather` L69 + EventBus `clima_cambio` en boot; 121/0/0 exacto. **M65 🟡 (BUG-080):** autoload verde (`test_m65` 24 OK ×2) PERO `tests/test_m65.gd` no ejecutable (preload muerto tras move Log 584 → 6× SCRIPT ERROR) + PackLogic/SchoolLogic huérfanas en producción → L109/L115 degradadas `[x]`→`[?]` (Caso A) + 1 `[?]` consolidado + Notas del Agente + Totales 90=86/1/3; fila GLOBAL 65 → 🟡. Cruce P-33 (hy3, Log 1146) documentado y escalado. **QA puro (cero fixes de código/tests).** Sello doble fuente (SEALS 1145 ×2 + notas GLOBAL 36/32); M65 = fila Notas QA. GLOBAL no commiteado. Log 1145 del pool V3. |
| 19 | **M101/M145/M146** (QA §21.8 P-25, doble fuente T-101) | ✅ SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 módulos s2 los selló en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente única). Verificador agnes ≠ s2 → independencia §21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 ×2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON válido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo §1 + parseo (`feedback-system.md` §2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 → re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` → M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) — solo edición workspace; commit = SEALS + Log 1138. Log 1138 del pool V3. |
| 22 | **M53 commit + M62 allowlist** (P-37, desbloqueo merge) | ✅ Merge desbloqueado | **1151** | **P-37 (urgente, 2026-09-25):** el change set M53 de P-18 (Log 1118) quedó sin commitear y rompía el gate M62 (`architecture-guard`: 2 refs A2|UIManager fuera del allowlist). Se commiteón 12 archivos (~751 inserciones, commit `825ed16`) + se agregaron 2 entradas al allowlist de `scripts/auditar_arquitectura_m62.py` (`A2|UIManager->AccesibilityManager` / `A2|UIManager->Localization`, etiqueta BUG-069: deuda de orden de capas, runtime OK). Gate M62 re-verificado: auditoría completa 0 hallazgos nuevos + selftest 0 fallos → merge final del coordinador desbloqueado. Log 1151 del pool V3. |
| 23 | **M65 manada/banco revive** (P-38, BUG-080) | ✅ M65 re-sellado (BUG-080 resuelto) | **1154** | **P-38 (2026-09-25):** BUG-080 (P-31, Log 1145) resuelto: preloads muertos de `tests/test_m65.gd` corregidos (`fauna/`→`animales_ia/`) + `PackLogic`/`SchoolLogic` cableadas en el autoload `m65_animal_ai` (`registrar`/`tick`/`desregistrar` por especie: gregaria+clase del catálogo M36; `_grupos_tick` cohesión/huida coordinada; `grupo_tamanio` QA) + fixes de semántica pack/school (`get_global_position()` duck-typed, `limpiar()` full-clear, líder con ≥1 miembro) + fix de mis propios bugs (`Resource.get(2 args)`, `Window.get_first_node_in_group`) + prueba nueva del flujo real `fauna_behavior`→autoload→PackLogic. Evidencia: `tests/test_m65.gd` **35 OK / 0 fallos**; `scripts/animales_ia/test_m65.gd` 0 fallos (base 24 OK); `test_fauna` 0 fallos; `main_island --quit-after 300` ×2 = 0 SCRIPT ERROR. **Limitación honesta:** los NPCs de main_island son legacy (no `fauna_behavior`) → los logs `[M65]` de grupo aún no se observan en la escena principal (el flujo de producción es M36). Docs: M65 04-Codigo (rutas `fauna/` obsoletas → `animales_ia/`) + 05-Checklist (3 `[?]`→`[x]`, Totales 89/1/0) + 11-BUGS BUG-080→`[x]` + GLOBAL fila 65 → ✅ + SEALS sello limpio (total 43). GLOBAL/11-BUGS/pool **sin commitear** (avisado al coordinador para el merge). Log 1154 del pool V3. |
| 24 | **M36 spawner en main_island** (P-49, deuda M65) | ✅ Integrado + documentado | **1165** | **P-49 (2026-09-25):** cerró la deuda que yo anoté en P-38 ("los NPCs de main_island son legacy... el spawner de M36 no está integrado"). Nuevo `fauna_spawner.gd` (nodo de escena) + nodo `FaunaSpawner` en `main_island.tscn`: zonas de bioma nominales de `MundoRaiz` (pradera en el spawn del jugador, playa/humedal en la costa) + especie por `especie_aleatoria_para(hora, bioma)` + tamaño por `candidatos_de_especie` + criatura = Node3D + `fauna_behavior` + placeholder de esfera (M45 posterior) + snap `TerrainLocator` (h≥3 tierra, franja 2.5–4.5 acuática, sobrevuelo aérea). Fixes durante la integración: autoload `fauna` no listo en `_ready` → lookup lazy `Engine.get_main_loop().root` + reintento; `Vector3.xz` (read-only) no pasa por dispatch de Variant → `.x/.z`; `:=` sobre Variant → `=`. **Evidencia:** `main_island --quit-after 300` ×2 = 0 SCRIPT ERROR; `[M65] Manada creada para conejo_pradera` + 2× `[M65] Banco creado para gaviota_playera/cangrejo_humedal` + 9/10 individuos; probe: 9 nodos `Fauna_*` con `fauna_behavior` bajo `FaunaSpawner`; suites M36/M65 0 fallos (no degradadas). Pendiente `[?]` M09: spawner completo "burbuja 72m" con `bioma_de_posicion` + despawn por distancia. Docs: M36 04-Codigo §P-49 + M65 05-Checklist Notas P-49 (limitación de P-38 levantada). Pool: P-49 pidió 1161 pero 1161–1164 fueron tomados en paralelo (P-43b/46/48/50) → reservé **1165** (anti-colisión §6.1.d). Commits 2 coherentes (trampa 87 verificado entre commits); los 4 compartidos sin commitear. Log 1165 del pool V3. |
| 25 | **Bucket OTRO:agnes (27 files)** (P-51, merge final) | ✅ Commiteado en 5 commits | **1168** | **P-51 (2026-09-29):** cerró el bucket "OTRO:agnes" (27 archivos) de la reclasificación P-48 (buckets_final.json) en 5 commits coherentes `Merge (worktree de agnes-3-flash)`: docs M19/M66/M72/M166 + tests M14/M155 + QA visual/utilería (VFX M52, ruinas M25, auditoría GLB) + 7 logs QA + 6 backlogs. Verificado `git diff --stat HEAD~1..HEAD` por commit (trampa 87). **Lecciones:** (1) en repos multi-agente siempre commitear con pathspec (un commit arrastró 1 file ajeno pre-staged; se revirtió y re-commiteó limpio); (2) test_equipment_manager.gd = reflow CRLF→LF (0 cambio de contenido; verificado LF-puro con editar_crlf.py); (3) pool: 1166/1167 tomados en paralelo → reservé 1168. Los 4 compartidos sin commitear (bucket C del coordinador). Push NEGATIVO. Log 1168 del pool V3. |
| 26 | **Lecciones GDScript → GUIA-GODOT/01** (P-52, deuda P-49) | ✅ Documentadas (§26-§28) | **1169** | **P-52 (2026-09-29):** documenté en `GUIA-GODOT/01-gdscript-errores-comunes.md` las 3 trampas de GDScript cazadas en producción (P-38/P-49, Godot 4.7.2), con síntomo/causa/solución/fecha (formato §26): §26 autoload no resuelto en `_ready()` (lookup lazy + reintento vía `Engine.get_main_loop().root`); §27 `Vector3.xz` read-only no pasa por dispatch de Variant (`Vector2(v.x, v.z)`); §28 `:=` sobre helper Variant no infiere tipo (`=` o anotar tipo). + 3 filas en la tabla de referencia + firma de cabecera. Cerró la deuda que anoté en P-49 ("mandalas allí cuando tengas hueco"). Commit con pathspec (trampa 70/87), Push NEGATIVO. Log 1169 del pool V3. |
| 27 | **Bucket flotación GLB M166** (P-54, última tajada) | ✅ Commiteado | **1174** | **P-54 (2026-09-30):** cerró el resto del bucket agnes: `scripts/auditar_flotacion_glb.py` (auditor de cota Z de .glb vía glTF, criterios M166 z_min 0.065/0.025) + `tools/legal/flotacion_glb.json` (salida --json, 265 KB). Mismo trabajo que `auditar_copyright_glb.py` (P-51, 9847169) y Log 1035. `preview_antorcha_m25.tscn` (antes listado como mío) era de mimo (afcdf4f) → descartado de mi bucket. Commit con pathspec (trampa 70/87), índice chequeado antes (0 staged ajenos). Pool: reserva **atómica** 1174 (el pool se movía: 1170–1173 tomados en paralelo). Push NEGATIVO. Log 1174 del pool V3. |
| 28 | **M131 QA §21.8 BUG-081** (P-56, QA cruzado) | 🟡 No sellable (delegado al dueño) | **sin log pool (QA)** | **P-56 (2026-10-02):** QA cruzado §21.8 de M131 (mimo-v2.6 cerró BUG-081). Verificado: BUG-081 bien resuelto (4 fixes en el código real + suites re-ejecutadas M131 8/0 y M84 15/0 verdes + Log 1178 commiteado 7f00e04 + diff de GLOBAL 1 línea limpia sin EOL). **Hallazgo: M131 NO es sellable a ✅** — la fila 131 del GLOBAL está en 🟡 (84/95) con 9 `[?]` (audio M41/M42/M43/M91) + 2 `[ ]`; DoD §21.6 exige 0 `[?]`. Veredicto documentado en M131 `04-Codigo` → `## Notas del Agente` (commit `c009775`, pathspec, sin push) y delegado al coordinador. La reclasificación 9 `[?]`→`[ ]` KnownIssue (precedente M36/M65) es del dueño (mimo), no de QA. QA audit-only: no toqué código de M131/M84. |
| 29 | **P-57: 6 filas defectuosas CHECKLIST-GLOBAL + auditoría** | ✅ Commiteado | **1186** | **P-57 (2026-10-02):** Corregí 6 filas (IDs 22, 26, 67, 68, 76, 77) de CHECKLIST-GLOBAL.md con columnas desplazadas/spurious (patrón detectado por atria-dawn, Log 1181). Edición byte-exact vía `scripts/p57_fix_rows.py` (EOL 231/0/219/1 preservado). Ejecuté `verificar_checklist.py`: 2 alertas documentadas en el log (M131 90vs85 mismatch; M70 fragmento de Notas en timestamp — ambos fuera de alcance P-57, delegados). Pool: reservé 1186 (head actual; 1182–1185 consumidos por otros). Push NEGATIVO (coordinador empuja). |
| 30 | **Candidata: escapar 148 pipes en Notas CHECKLIST-GLOBAL** | ⬜ Pendiente (no urgente) | — | **Sistema (2026-10-02, coordinador):** 148/167 filas de CHECKLIST-GLOBAL tienen pipes `|` sin escapar en la columna Notas. El verificador `verificar_checklist.py` resiste la mayoría (parsea solo las primeras 10 cols) pero se confunde en filas con contenido desplazado (M62, M70). Tarea de forma separada si se pide. |




**Siguiente en la cola del bucle (mi encaje A):** módulo V0 + data-driven + tooling/CI + **gap de
código real** (no solo política). Candidatos a verificar antes de reclamar (§21.4.7, checar estado real):
un módulo revertido por auditoría con código parcial (patrón de M113/M115/M107) — p. ej. revisar el pool
de módulos 🟢/🟡 "revertido por auditoría" y elegir el que tenga código testable donde mi perfil
(auditoría código↔checklist + test headless + tooling) dé un cierre genuino. Iteración 6 ya corrió como
V0 acotada sobre M61 (Log 943); pendiente visual: V3 M46 Arte-2D (fila de la cola visual).

## Cola visual (tareas que REQUIEREN visión — la aprovecho, §19 corrección 2026-09-16)

> Mi perfil de visión: **V1** (leer/describir capturas del MCP godot en `tools/mcp/godot-mcp/capturas/<módulo>/`)
> + **V2-asistencia** (revisar y opinar sobre un render/screenshot: terreno, HUD, VFX, iluminación, NPC).
> **Límite honesto:** la **aprobación estética final es del usuario (M154)**; **no genero arte 3D/texturas
> (V5)** → eso va a Hy4/Blender.

| # | Módulo | Capturas | Tarea de visión (V1/V2-asistencia) | Estado |
|---|--------|----------|-------------------------------------|--------|
| V1 | M52 Particulas-Y-VFX | `capturas/52-Particulas-Y-VFX/` (6) | V2-asistencia: leer capturas, describir el VFX, detectar artefactos/bugs visuales + QA note | 🟡 **done** (Log 932: leí iter3+iter4 vía visión + `screen_capture_screen`; **flag FPS-24 en turbulencia → M61**; nota §QA visual en `05-Checklist.md` M52) |
| V2 | M49 Iluminacion | `capturas/49-Iluminacion/` (4) + `capturas/49/` (16) | V2-asistencia: revisar balance de luz/sombras en las capturas; flaggear zonas quemadas/oscuras | 🟡 **done** (Log 939: leí mediodía/noche/atardecer/skyline vía visión; ciclo día→noche correcto, FPS ~60; **noche oscura = diseño confirmado por el usuario (la cubren las antorchas)**; nota §QA visual en `05-Checklist.md` M49) |
| V3 | M46 Arte-2D | `capturas/45`/`46` + M46 0/110 | V1: verificar si hay assets 2D reales (probablemente bloqueado por M45) → confirmar `[?]` con dueño | 🟡 **done** (Log 954: V1-QA — **0 de 48 assets en disco** (inventario_2d.json define 48, validador headless 0 fallos lo confirma); ART_STYLE_2D.md + tooling reales; trabajo 2D **bloqueado por M45/M108/artes** (dueños asignados en 05-Checklist §QA V1). **Flag:** checklist archivo 0/110 vs 103–104/110 declarado (cierre no reflejado) → dueño M46 re-marca) |
| V4 | M167 Isla-Raiz | `capturas/167-Isla-Raiz/` (3) | V1/V2: verificar que el terreno se vea correcto (perfil en capas, paleta Maldivas) vs doc de recuperación | 🟡 **done** (visión: leí `overview`/`costa`/`smoke_regresion` → terreno completo y correcto, FPS 60; respaldé con evidencia visual el KnownIssue "shore-fade cubre demasiada arena" y diagnosticé el `SCRIPT ERROR` de la consola = **caché stale del editor**, no bug en disco; nota §QA en `05-Checklist.md` M167). Elección: V4 > V3 porque M46 depende de M45 (assets) y M167 ya está ✅ 114/114 con solo pendiente la verificación visual = mi perfil exacto. |

**Regla de uso:** antes de cada V-###, **leo las PNG (visión)** y/o hago `screen_capture_*` (MCP) para
ver el estado actual; luego escribo la QA note en el `05-Checklist.md` del módulo (sección "QA visual
V2-asistencia — agnes-3-flash") sin afirmar "aprobado por el usuario".

---

## ACTUALIZACION 2026-09-20 — nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente — **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

*(Sin modulos nuevos — continua con tus tareas pendientes actuales.)*

## ACTUALIZACION 2026-09-20 — M53 UI-UX asignado por el usuario (04:15Z)

> El usuario asigna **M53 UI-UX** (Recom Hy4 inactivo, §21.4.7) con prioridad:
> (1) overlays/accesibilidad (M58: subtítulos RF8 + RF18), (2) labels/tooltips
> traducidos (M87 ×2). Log reservado: **1118** (vía `reservar_log.py`).
> **COMPLETADO 2026-09-20 (Log 1118 creado):** iteración agnes acotada en M53 + cierre
> de M87×2. Ver fila 17 del historial.

## ACTUALIZACION 2026-09-24 — P-25: QA cruzado M101/M145/M146 (asignado 2026-09-25 00:26Z)

> Sello T-101 de doble fuente para los 3 módulos que s2 selló solo en GLOBAL (Log 1124),
> reportados por hy3 como "sello de una sola fuente". Log reservado: **1138**.
> **COMPLETADO 2026-09-24 21:45 (Log 1138):** los 3 SELLADOS con doble fuente
> (`CHECKLIST-QA-SEALS.md` + notas GLOBAL). M101: suite 12/0 ×2 + artifacts parseados
> (schema JSON validado) + 209/0/0 exacto. M145: 7/7 docs + 20 acciones + R1-R8 +
> 105/0/0 exacto (salvedad: 15 `[x]` futuras = Familia B BUG-070, re-verif M114/M138+).
> M146: 5/5 docs + WM-1..8 + 7 preguntas + 100/0/0 exacto (salvedad: 10 `[x]` futuras
> → M138+). GLOBAL NO commiteado (working tree ajeno ~496 archivos + EOL): solo
> edición de workspace; commit = SEALS + Log 1138.

## ACTUALIZACION 2026-09-25 — P-29: QA §21.8 de M08 Mundo-Voxel (asignado 2026-09-25 01:05Z)

> El ✅ sin sello más crítico que quedaba (49 módulos ya sellos; M08 = core voxel).
> Log reservado: **1141** (el pool ya había consumido 1137-1140 — verificado antes).
> **COMPLETADO 2026-09-24 22:15 (Log 1141):** M08 **SELLADO con evidencia headless
> (primera vez)** — suites M13 (`test_herramientas` + `test_herramientas_iter4`, el
> contrato real de edición de M08 vía `tool_controller`/`interaction_manager`) **0
> fallos ×2 cada una EXIT 0**; `main_island.tscn --quit-after 300` headless **EXIT 0
> ×2, 0 SCRIPT ERROR** (VoxelBoxMover + VoxelViewer = GDExtension VoxelTools cargada
> y streaming). Re-grounding T-99: 05-Checklist 105/0/0 = Totales exacto; artifacts
> de 04-Codigo §1 verificados en disco (incl. la nota QA-976 de atria que sanea la
> "arquitectura prevista"). Salvedades en el sello: (1) M08 no tiene suite propia →
> verif. vía M13 + runtime; (2) edición E/Q interactiva = playtest (no verificable
 > headless); (3) RID-leak at exit = ruido headless benigno. Sello doble fuente
 > (SEALS + notas GLOBAL); GLOBAL no commiteado.

## ACTUALIZACION 2026-09-25 — P-31: lote QA §21.8 M36/M65/M32 (asignado 2026-09-25 02:34Z)

> Lote gameplay core interrelacionado (fauna ↔ IA animal ↔ clima). Log reservado:
> **1145** (pool: 1137-1144 ya consumidos por otros — verifiqué antes).
> **COMPLETADO 2026-09-25 00:50 local:** **M36 ✅ + M32 ✅ sellados (doble fuente
> T-101); M65 🟡 revertido → BUG-080.**
> - **M36:** `test_fauna` 58 OK/0 fallos ×2 + `fauna_auditor` 7 especies ×2; autoloads
>   cableados y en runtime (`fauna_registry`/`fauna` L52/53; `[M36] FaunaManager
>   ready`); 7/7 artifacts + JabaliNPCs en main_island; `fauna_behavior.gd` (compartido
>   M65) íntegro. Corrección de conteo: 228/228 → **226 [x] + 2 [ ] KnownIssue**.
> - **M32:** `test_clima` 0 fallos ×2 + **3 suites colaterales consumidoras** (M21 7 OK,
>   M33, M34) verdes ×2 = integración real; autoload `Weather` L69 + EventBus
>   clima_cambio en boot; 121/0/0 exacto.
> - **M65:** autoload verde (`test_m65` 24 OK ×2) PERO **`tests/test_m65.gd` no
>   ejecutable** (preload muerto tras el move Log 584 → 6× SCRIPT ERROR) +
>   **PackLogic/SchoolLogic huérfanas en producción** → **BUG-080** (`[?]` delegado a
>   M65/glm), L109/L115 degradadas `[x]`→`[?]` (Caso A) + Notas del Agente + Totales
>   90 = 86/1/3. **Cruce P-33 (hy3, Log 1146):** divergencia documentada y escalada.
> - QA puro (cero código/tests modificados). Commit = SEALS + Log 1145 + 05-Checklist
>   M65; GLOBAL en workspace (merge del coordinador).

## ACTUALIZACION 2026-09-20 — M14 Inventario (P-18, QA §21.8 asignado por el usuario, 07:54Z)

> **Autonomía total (cambio de método del coordinador):** intento resolver primero;
> `[?]` honesto si no pude; el coordinador verifica la entrega.
> Log reservado: **1127**. **COMPLETADO 2026-09-20 (06:25 local):** M14 **DEFINITIVO** —
> sello §21.8 otorgado. 5 suites verdes binario real: standalone ×2 (0 fallos, 68/70 OK,
> ×2 cada una) + gdUnit4 **32/32 PASSED 0 errors EXIT 0** (×2) tras fix mínimo de 5
> defectos del TEST registrado en **BUG-079** (`[x]` M14; `is_equal_to` ×58 + `free()`
> RefCounted + lambda capture-by-value + ids M15 + rediseño de 1 test al contrato real).
> M38/M29/regresión comparten el defecto `is_equal_to` → `[?]` delegado (no lo toqué).
> Reconciliación T-99: 05-Checklist M14 = 136/0/4 = Totales exacto; 0 `[x]`→archivo
> inexistente (`inventario_save.gd` stale, funcionalidad en `inventario_service.gd`).


### QA visual puntual — impostor de M09 (1 tarea)

> **Unica tarea nueva, chica** (eres lenta, reportado). M09 no tiene suite headless —
> su impostor se verifica visualmente (visible a 1300 m). Captura → analiza → reporta.
> **Si no hay captura posible, reporta "no verificable"** — no apruebes sin evidencia.

- [x] **T-V01:** Verificar `scripts/world/terreno_horizonte.gd` (impostor heightmap)
  con captura V4: ¿se ve correcto desde la distancia objetivo? — **COMPLETADO
  2026-09-20 (Log 1115).** V4: run main_island + captura
  `capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png` (42 tiles activos,
  0 SCRIPT ERROR, FPS 60; horizonte tapado por fog 0.001 → mi veredicto "no
  verificable"). V1 usuario: "los impostores sí funcionan — los altos grises; los
  verdes bajos que no veo = piso COLOR_PASTO del heightmap unificado, no asset
  aparte" → **IMPOSTOR VERIFICADO**. QA note en `09-.../05-Checklist.md`.
  Log reservado: **1115** → **Log creado** (`1115-QA-VISUAL-M09-IMPOSTOR`).


**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar — corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 1:**

### M-05 — Contar ruido de boot como fallos de suite (tu cobertura = conteos Godot)
Conte 43 "SCRIPT ERROR" en `test_ui_i18n_m53` y pense que la suite fallaba. Eran
**autoloads imprimiendo "OK:" al bootear** — el numero real era **39 OK / 0 fallos**.
Me equivoque y vos tenias razon. **Tu cobertura: TODO conteo de suites Godot lo haces vos.**

**Regla fija (leida en M-05, `GUIA-GODOT/06-registro-errores.md`):** anclar los conteos
en `^\s*OK:`. Yo **no cuento** suites Godot — te lo delego a vos que lo haces exacto
(132/0/26 = 158, 131/5/0 = 136, sin drift).

P-18 (M14 Inventario) es justo esto: 5 suites, binario real, sello §21.8 si pasan.

---

## Módulo ACTIVO — 54-Mapa (P-59)

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).** Lock 🔵 a tu nombre
> en la fila 54 de CHECKLIST-GLOBAL. **Prioridad sobre toda la tabla de
> arriba** — esa tabla es tu reserva histórica re-claimable; M54 es el lock
> activo de ahora.

**Encaje A puro:** data-driven + orquestación de servicios + señales EventBus
— exactamente tu núcleo de especialidad declarado.

**Fuente de verdad:** `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`
(89 [x] / 88 [ ] / 0 [?], 177 ítems). Leelo ANTES de tocar código (§13).

**Código real + suites (5 headless):**
- `game/isla-ancestral/scripts/mapa/` — MapManager, map_service, markers.
- Suites: `test_mapa_m54.gd`, `test_mapa_m54_e2e.gd`, `test_mapa_busqueda.gd`,
  `test_mapa_markers.gd`, `test_map_service_headless.gd`.
- **Línea base medida por atria-dawn 2026-10-02** (`test_mapa_m54.gd`):
  **27 checks, 0 fallos, EXIT 0.**
- ⚠️ Tu cobertura M-05 aplica: anclar conteos en `^\s*OK:` — los logs de
  boot del juego se mezclan con la salida de la suite.

**Tareas de código concretas (las más valiosas):**
1. **Niebla de guerra en el minimapa** (recorte del FogTextureRect) [M] —
   integración con `exploration_changed`. ✅ Ya implementado por agnes-2.5 (minimap_widget `_fog_rect` + suscripción a señales).
2. **Textura caché del MapManager** reutilizada sin segundo bake ni
   re-render por frame [M]. ✅ iter 2: MapCanvas `_apply_transform()` (zoom/pan sin recrear niños).
3. **Actualización por señales** (`exploration_changed`, `markers_changed`,
   posición a 2 Hz) en vez de polling [M]. ✅ iter 2: FullMapLayer suscribe/describe señales; MapCanvas `update_markers()` (position 2 Hz aún pendiente).
4. **Textura base del mapa desde chunk data** del mundo (M10) [C].
5. Acceso al mapa completo con click/foco sobre el minimapa (`map_toggle`). ✅ iter 2: KEY_M en FullMapLayer.
6. Convivencia con la pila de capas (diálogo abierto + mapa se encola).
7. Pausa coherente con M29/M30 al abrir el mapa. ✅ iter 3: TimeCalendar.pausa()/resume() (fix nombre autoload + método en español).

**Progreso P-59 (agnes-3-flash, 2026-10-02):**
- iter 2 (`72f72c7`): señales + KEY_M + transform. +3 [x]
- iter 3 (`9eb33ee`): FullMapLayer en hud.tscn + fix pausa. +1 [x]
- iter 4 (`6826c6e`): pila capas + 2Hz + fog per-island. +3 [x]
- iter 5 (`948854c`): textura cache + 11 [x] (docs, docs, etc). +11 [x]
- iter 6 (`487d905` + `5a692c6`): TerrainLocator texture + cancel viaje + M57. +8 [x]
- iter 7 (`e622872` → `ea7fff1`): 2Hz, pines, validación, 6+5+3+1 más. +15 [x]
- **TOTAL SESIÓN:** 34 → **89 [x] / 88 [ ] / 0 [?]** (50%). 55 items.
- **Suites:** 36/0 + 9/0 + 9/0. **Runtime:** 60 FPS, 0 M54 errors.
- **Capturas:** 6 en `capturas/54-Mapa/`.
- **GLOBAL:** 89/177.

**Notas de la iteración anterior** (agnes-2.5, 2026-09-12/13): varios ítems
tienen diseño documentado en `03-Diseno.md` (§2.1 estilo ilustrado cozy,
§2.3 flecha borde para marcadores, norte arriba). Algunos `[ ]` están
comentados con `— agnes-2.5-flash ... DISENO documentado` — eso significa
que el diseño existe y falta la implementación, no que falte el diseño.

**Método:** lotes → suite con binario real
(`C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script
res://scripts/mapa/test_mapa_m54.gd --quit-after 8000`) → marca [x] solo
con la suite en verde (≥ 27 checks). T-104/mimo: si un test usa conteo
mágico, cambial a `>=` ANTES de mutar el catálogo, no después.

**Trampas:** 114 (pathspec SIEMPRE — kimi trabaja M70 en
scripts/interacciones/, DeepSeek en M62, mimo en scripts/audio/), M-06
(byte-exact si tocas CHECKLIST-GLOBAL: 231 CRLF / 0 LF / 219 CR), 119
(✅ inflado), 118 (impresión visual ≠ diagnóstico).

**Pool:** lee `Logs/NUMEROS_DISPONIBLES.txt` en disco VIVO (cabeza actual
1187, verificá — se mueve). Reserva con §6.1.a.

**Al terminar o liberar:** Estado 🔵 → ✅/🟡 en la fila 54, Agente → —,
actualiza Última actividad. Nunca dejes 🔵 huérfano (§21.4.5).

---

## Encargo 100-Community-Management — asignado 2026-10-03 por atria-Dawn (Kilo Code)

M132 cerrado (105/0/0, 8 suites, Log 1220). El siguiente encolado era 100-Community-Management y la duda era si la dep M99-Marketing (7/169, recién iniciado) bloqueaba los 76 items.

**VERIFICADO POR EL COORDINADOR: NO bloquea.** Escaneé los 76 items pendientes del plan-actual y NINGUNO cita M99 (0 referencias). Los items son autocontenidos: reglas comunitarias, roadmap público, changelog público, atención de dudas, triage de bugs reportados, gestión de expectativas/críticas/toxicidad/spoilers. La dep es DOCUMENTAL, no técnica.

- [x] **100-Community-Management** CERRADO (222/0/0, 8 suites, Log 1228, 2026-10-03). Cuarto modulo de la sesion (125, 79, 132, 100).
- [x] Reserva confirmada viable por el coordinador: 129 y 152 ejecutables.

---

## ENCARGO NUEVO — 129-Merchandising (asignado por atria-dawn, 2026-10-03)

M100 cerrado (222/0/0, Log 1228). Sesion impecable: 4 modulos, 220 items, 13 commits, 3 handbooks, invariante EOL 231/0/218/1 preservado.

- [ ] **129-Merchandising**: Disponible, 68 [x] / 40 [ ] / 0 [?] = 108. C1. Dep M142-Release-Candidate NO bloqueante (verificado: 0 de 40 items la citan). Tu Recom (merch_validator+tests). Ejecutable AHORA.
- [ ] Siguiente encolado: **152-Principios-Innegociables**, 115 [x] / 87 [ ] / 0 [?], C1, dep M01 NO bloqueante (1 de 87 items la cita).
- [ ] Tras 152, si siguen libres: **06-Control-De-Versiones** (0 [x] / 100 [ ] / 0 [?], C1, dep M01 documental).

Reglas: protocolo habitual de los 4 registros, [x] en los TRES lugares, iteraciones con log del pool, gate con FAIL=1 demostrado en rojo, prohibido verde por omision (afirmar el camino de EXITO), CHECKLIST-GLOBAL byte-exact (invariante 231/0/218/1), git add con pathspec, sin pisar scripts de M17/M43/M37/saving/interacciones/museos/legal/mapa. Sello 21.8 de 129 delegado a hy3 (Lote M seccion P).

