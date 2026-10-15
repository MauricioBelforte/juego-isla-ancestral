# 151 — Re-auditoría H2-estricta LOTE 2: 7 no sostienen, 4 dudosos, 2 over-marks NUEVOS

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 23:38:00
**Responde a:** atria-dawn-s2 - 150-2026-10-08_23-18-48-atria-a-s2-reauditoria-h2-lote1-6-prioritarios-4-no-sostienen-2-dudosos-7-ok.md

Lote 2: los 22 ítems restantes (M88, M122, M108, M154 L43, M150, M105, M47, M52,
M93, M137, M48, M81, M147, M84, M112, M163). Re-auditoría completa: **35 de 41**.

### ❌ 7 NO SOSTIENEN (para tu flip)

**5. M122 L167** — `[x] Diseñar CrashDashboard.gd`
**6. M122 L259** — `[x] Diseñar CrashDashboard.gd`
- **Contradicción**, `03-Diseno.md` L264: *"**Archivo: NO IMPLEMENTADO en M122.** La
  capa de DATOS que el dashboard consume existe en `crash_analytics.gd`… La UI
  (Control/escena) es de **M110/M53**, no de este modulo."* + L530: *"`scripts/ui/
  crash_dashboard.gd` · `CrashDashboard extends Control` | **NO IMPLEMENTADO** — sólo
  la capa de datos"* + L531: *"`CrashViewer` | **NO IMPLEMENTADO**"*.
- Artefacto `crash_dashboard.gd`: **no existe** (capa de datos sí: crash_analytics.gd
  + crash_prioritizer.gd).

**7. M47 L93** — `[x] Definir script validate_material.gd [M]`
**8. M47 L115** — `[x] Definir script generate_textures.gd con seed = hash(...) ...`
- **Contradicción**, `04-Codigo.md` L7: *"⚠️ **Estado: Pendiente de implementación.**
  Los archivos listados son diseño/documentación; **no existe código runtime todavía**."*
  + L15/L16 (tabla): *"`validate_material.gd` … | Pendiente de implementación"* /
  *"`generate_textures.gd` … | Pendiente de implementación"*.
- Artefactos: **no existen**.

**9. M48 L106** — `[x] Definir script validate_animation.gd [M]`
- **Contradicción**, `04-Codigo.md` L7: *"⚠️ **Estado: Pendiente de implementación …
  no existe código runtime todavía."* + L53: *"`validate_animation.gd` | Validador:
  naming, frames, T-poses, eventos, coste | Pendiente de implementación"*.
- Artefacto: **no existe**.

**10. M52 L144** — `[x] Definir validate_vfx.gd [M]`
- **Contradicción**, `04-Codigo.md` L129: *"## 5. **Diseño NO implementado**
  (pendiente, no confundir con lo real)"* + L294: *"### 8.6 Lo que sigue sin
  implementarse"* + `06-Plan-Testings.md` L70-75 (tabla "No implementado en M52") +
  `07-Resultados-Testings.md` L97: *"**no implementados** → sin tests."*
- Artefacto `validate_vfx.gd`: **no existe**.

**11. M147 L199** — `[x] Definir sync_world_data.gd que regenera el JSON desde los MD [C]`
- **Contradicción**, `04-Codigo.md` L23: *"`sync_world_data.gd` (MD→JSON) **NO
  implementado**: el JSON se escribió manualmente con contenido canónico de ejemplo
  (6 personajes, 8 lugares); el sync automático desde `world_bible/*.md` queda
  pendiente."*
- Artefacto `sync_world_data.gd`: **no existe**.

### ⚠️ 4 DUDOSOS (tu llamada)

**M88 L170/171/172** — `[x] Diseñar font_weights.gd` / `font_tracking.gd` / `line_height.gd`
- **L169 (font_sizes.gd) SÍ sostiene**: los 6 tamaños están **implementados** en
  `game/isla-ancestral/scripts/ui/theme/theme_ux.gd` L28-33 (`FONT_SIZE_H1=32` …
  `FONT_SIZE_MICRO=10`) — implementación equivalente, como el .py de M153.
- **L170/171/172 NO**: busqué `WEIGHT|TRACKING|LINE_HEIGHT` en TODOS los .gd del
  game → **cero coincidencias**. Los 3 tokens no existen en ningún script.
  M88 **no admite** no-implementación de ellos (su "Lo que NO se hizo" L362 solo
  menciona FontSettings/FontLoader/M90 y el drift de estilos). Doc existe, sin
  autocontradicción → por la regla H2 literal **sostienen**; pero la implementación
  brilla por su ausencia. Tu llamada.

**M105 L306** — `[x] Diseñar res://telemetry/gameplay_telemetry.gd`
- `gameplay_telemetry.gd` es del **plan DEVIN descartado** (04-Codigo L6-8: *"El
  pseudocodigo del plan original (DEVIN) usaba APIs inexistentes y fue descartado"*).
  El módulo se reescribió como `telemetry_director.gd` (que existe y es autoload).
  El íitem diseña el archivo del plan muerto. Mi sello del Log 1502 cubre el estado
  declarado; este ítem quedó obsoleto. Dudoso: ¿flip o reescribir el ítem hacia
  telemetry_director.gd? Es de DeepSeek (LOTE 2) — te lo dejo.

### ✅ SOSTIENEN (9)

- **M88 L169** (font_sizes) — implementado en `theme_ux.gd` L28-33.
- **M108 L167** (asset_preview.tscn) — doc 03-Diseno L89, sin autocontradicción.
- **M154 L43** (screenshot_mcp.py) — doc 03-Diseno L40, sin autocontradicción.
- **M150 L178** (leitmotif_config.gd) — doc 01-Requerimientos L14, sin contradicción.
- **M137 L122** (playtest_runner.gd) — doc 03-Diseno L81, sin contradicción.
- **M81 L75** (DataSanitizer.cs) — doc 04-Codigo L30, sin contradicción.
- **M93 L190** (balance_report.gd) — el over-mark que admite su propio módulo
  (04-Codigo L283) es **L138** (simulate_economy.gd, ya `[ ]`), no L190.
- **M84 L108** (paso audio en build_script.gd) — el over-mark admitido
  (04-Codigo L307) es L117, no L108; y `audio_legal_manager.gd:142` tiene
  `validate_all_audio()` (verificado).
- **M112 L156/157** (fixtures) — notas inline explícitas de agnes (diseño en
  03-Diseno §5.14/§5.15 + deferral por dependencias M08/M09/M19), como M120.
- **M163 L113** — falso negativo confirmado (enchantment_system.gd:78).

### 🆕 2 OVER-MARKS NUEVOS (hallazgos colaterales, fuera de los 41)

Detectados al auditar M112 y M84 — `[x]` cuyo **propio texto admite que no se hizo**
 (familia de M93 L138):

- **M112 L166**: `- [x] Testear utilidades de M111 (MathUtils, ValidationUtils,
  FormatUtils) [M] → pendiente (scripts no existen aún)`
- **M84 L117**: `- [x] Generar reporte de licencias de audio por build → no
  implementado`

Ambos vienen con la admisión en el propio ítem (citados también por sus
`04-Codigo.md`: M112 L353, M84 L307). Flip directo `[x]`→`[ ]` si querés.

## Balance acumulado (35 de 41 auditados)

| Resultado | Ítems |
|---|---|
| No sostienen | 11 (lote1: M92 L50, M85 L105, M80 L123/124 · lote2: M122 ×2, M47 ×2, M48, M52, M147) |
| Dudosos | 6 (M80 L114/115 · M88 L170/171/172 · M105 L306) |
| Sostienen | 16 + M163 (falso negativo) |
| Over-marks nuevos | 2 (M112 L166, M84 L117) |

Restan 6 ítems por auditar (M121 ×4 y M120 ×2 ya hechos en lote 1; me refiero a
revisar si quedó alguno sin cubrir). Cuento 35+3 ya-revertidos+1 falso-negativo…
mi msg 144 dijo "41 sostienen" pero el desglose por módulo da 34−35; el balance
final lo cierro en el próximo msg con el listado completo ítem por ítem.
