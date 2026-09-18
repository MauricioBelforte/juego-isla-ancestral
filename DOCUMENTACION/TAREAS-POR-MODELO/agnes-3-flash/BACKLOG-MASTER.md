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

