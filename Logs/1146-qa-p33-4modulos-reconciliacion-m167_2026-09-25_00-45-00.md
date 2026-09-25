# Log 1146 — P-33: Lote ampliado (4 módulos §21.8) + reconciliación M167

**Verificador:** hy3 (Tencent Hunyuan) / WorkBuddy · **Regla:** AGENTS.md §21.8 (verificador ≠ autor) · **Fecha:** 2026-09-25
**Alcance:** Parte A — QA §21.8 de 4 módulos (M65, M94, M114, M119). Parte B — propuesta de reconciliación M167 (SOLO PROPUESTA; sin diffs, sin commits a código ni docs de M167).

---

## Parte A — QA §21.8 de 4 módulos

Método: conteo por ítems (`^\s*-\s+\[[ x?]\]`, nunca substring); re-grounding de artefactos contra `04-Codigo.md`; suites headless con binario Godot 4.7.2 real. Verificador ≠ autor en M94/M114/M119. **M65: hy3 es el AUTOR** (coordinador) → mi QA es complementaria; el sello §21.8 vinculante corresponde a agnes (P-31).

### M65 — Animales-IA  → 🟡 VERIFICACIÓN SUPLEMENTARIA (sin sello §21.8 propio)
- **Suite** `scripts/animales_ia/test_m65.gd` (Godot 4.7.2 headless, re-corrida hoy): `GODOT_EXIT=0`, **0 `SCRIPT ERROR`**, summary `=== TEST M65 ANIMALES-IA: 0 fallo(s) ===`. GREEN.
- **Checklist** `05-Checklist.md`: **88 `[x]` / 1 `[ ]` / 0 `[?]` = 89 ítems**. El único `[ ]` es L98 `[M08] Movimiento real con NavigationServer3D` — dependencia externa con dueño (M08), KnownIssue honesto, NO sobre-cierre. (El brief decía "89/89"; la realidad es 88/1 por esa dependencia externa legítima.)
- **Re-grounding corrección:** el brief advertía que `pack_logic.gd`/`school_logic.gd` "viven en `scripts/fauna/`". Verificado por glob: **ambos están en `scripts/animales_ia/`** (`m65_animal_ai.gd`, `pack_logic.gd`, `school_logic.gd`, `test_m65.gd` todos presentes). La advertencia del brief venía del propio `04-Codigo.md` de M65 (L10-11), que tiene la **ruta obsoleta** (`scripts/fauna/`). Drift de ruta en el doc de M65, no carpeta separada.
- **Veredicto:** evidencia limpia, pero como hy3 es autor de M65 no emito sello §21.8. Sello vinculante = agnes (P-31). Si agnes coincide → ella sella; si diverge → el coordinador audita.

### M94 — Retención-Sin-FOMO  → 🟢 SELLO LIMPIO §21.8
- **Verificador ≠ autor:** autor DeepSeek-V4-Flash (GLOBAL fila 94). ✔
- **Re-grounding:** `04-Codigo.md` lista `scripts/motivacion/` → glob confirma **7 .gd + 2 test presentes** (`motivacion_manager.gd`, `objetivo_data.gd`, `objetivo_activo.gd`, `recompensa_acumulada.gd`, `motor_variantes.gd`, `antifomo_auditor.gd`, `test_motivacion_m94.gd`, `test_antifomo_headless.gd`). 0 archivos faltantes.
- **Checklist:** **138 `[x]` / 0 `[ ]` / 0 `[?]`**. (El brief decía "135"; 138 es el conteo real por ítems — el 135 era un total previo desactualizado. Cumple §24: 0 `[ ]` reales.)
- **Sello:** en SEALS (fila 94) + GLOBAL (fila 94, Nota P-33). T-101 OK.

### M114 — Playtest  → 🟢 SELLO LIMPIO §21.8
- **Verificador ≠ autor:** autor Step 3.7 Flash / Deepseek V4 Flash (GLOBAL fila 114). ✔
- **Re-grounding (consistencia doc↔código):** `04-Codigo.md` §2 describe las plantillas como "pendiente de implementación / no existen". Glob de `docs/playtest/*.md` → **las 4 existen** (`PLAYTEST-GUIA.md`, `PLAYTEST-ENCUESTA.md`, `PLAYTEST-INFORME.md`, `README.md`, versionadas desde Log 481). Doc↔código consistente (los archivos están; el texto "pendiente" es obsoleto, no bloquea).
- **Checklist:** **186 `[x]` / 0 `[ ]` / 0 `[?]`**. Cumple §24.
- **Sello:** en SEALS (fila 114) + GLOBAL (fila 114, Nota P-33). T-101 OK.

### M119 — Actualizaciones  → 🟡 SIN SELLO (drift doc↔código)
- **Verificador ≠ autor:** autor Nemotron 3 Ultra / Step 3.7 Flash (GLOBAL fila 119). ✔ (la revisión es válida; el fallo es del módulo, no del verificador)
- **Checklist:** **118 `[x]` / 0 `[ ]` / 0 `[?]`** — el cierre de ítems es REAL.
- **DRIFT encontrado:** `04-Codigo.md` lista 4 `.gd` (`update_manager.gd`, `update_checker.gd`, `save_migrator.gd`, `game_version.gd`) + `test_updates_m119.gd`. Glob multi-ruta confirma que **solo `update_manager.gd` + `test_updates_m119.gd` existen**; `update_checker.gd`, `save_migrator.gd`, `game_version.gd` **NO EXISTEN** en ningún lado. El código de `update_manager.gd` referencia `UpdateChecker`/`UpdateDownloader`/`SaveMigrator`/`GameVersion` (`.new()`) que no están materializados.
- **Veredicto:** exactamente el drift que cazaste en M167, pero en un módulo donde nadie había mirado. Sin sello limpio hasta reconciliar (opciones: crear los 3 archivos, o sanear el `04-Codigo.md` para reflejar la estructura consolidada en `update_manager.gd`). **No toco el código ni el doc de M119** (fuera de mi alcance P-33); lo dejo documentado para que el autor decida.
- **Registro:** SEALS (Notas QA, fila 119) + GLOBAL (fila 119 → estado `🟡 QA-drift-doc`, Nota P-33). T-101 (sin sello).

---

## Parte B — M167: propuesta de reconciliación del radio de la isla

> Entregable solicitado: (1) qué dice el código real del spawn y el tamaño del mundo; (2) cuál de 256 / 2560 es la verdad intencional, con evidencia; (3) propuesta en 3 opciones — qué fuente cede y costo de cada una. **No se tocó código ni docs de M167.**

### B1 — Qué dice el código REAL (bytes del archivo, no del plan)

`game/isla-ancestral/scripts/main_island.gd` — **17.135 bytes**. Líneas clave:
- **L142-144 (comentario, YA CONTRADICTORIO):** `# Generador de isla con biomas (M09/M10) — PERFIL ORIGINAL (M167 config fija: max_height 40, sin boost — restaurado Log 791 tras el rechazo del terreno escalado)`.
- **L147:** `generator.island_radius = 2560`  ← valor vivo.
- L148-149: `max_height = 40`, `max_height_boost = 1.0`.
- **L162:** `voxel_viewer_node.set_deferred("global_position", Vector3(2560, 30, 2560))` (visor centrado en 2560).
- **L184:** `player.set_deferred("global_position", Vector3(256, 16, 256))`  ← **spawn en el centro VIEJO (256,256)**.
- **L205:** `oceano.position = Vector3(256, 1.2, 256)`  ← **océano en el centro VIEJO (256,256)**.
- **L296:** `var altura_spawn: int = locator.get_height(spawn_x, spawn_z)`  ← lookup **parametrizado** (usa `spawn_x/spawn_z`, no literal 256) — esto es el rework M09/M16.

`game/isla-ancestral/scripts/terreno/validador_isla_raiz.gd` — **7.732 bytes**, 28 checks. Gate que cita `04-Codigo.md`:
- **L60-61:** `_check(main.find("generator.island_radius = 256") != -1, ...)` → exige literal `256`.
- **L64-65:** exige `Vector3(256, 16, 256)` (coincide con L184, pasa).
- **L68-69:** `_check(main.find("locator.get_height(256, 256)") != -1, ...)` → exige literal `get_height(256,256)`; el código vivo usa `get_height(spawn_x, spawn_z)` → **FALLA**.
- L109-110: perfil dinámico usa constante `RADIO_EXPECTADO` para el centro `(256,256)` y montaña ≥12.

**Conclusión de B1:** el generador vive en **2560** (mundo 5120²), pero el **spawn del jugador (L184), el océano (L205) y el gate del validador (L60-69) siguen hardcodeados en 256**. El código está a medio migrar.

### B2 — ¿256 o 2560 es la verdad intencional? (con evidencia git)

`git log -L 147,147:game/isla-ancestral/scripts/main_island.gd` (historia del valor):
`4234bca` (init) → `16364c0` (640) → `3fb12f6` (**256**, "Isla plato de arena: circular, grande (radio 256)") → `cb4bef8` (2048) → `245a597` (**256**, "Restaurado el terreno ideal... isla radio 256") → **`c107419` (256 → 2560)**.

**El commit que puso 2560 es `c107419`** (Mauricio Belforte, 2026-09-07). Su *mensaje* dice: *"Se corrigieron ultimos 2 logs duplicados (722, 751) y 6 referencias cruzadas rotas"* — pero su **diff real es el rework "Isla 10×" de M09/M167**:
- Restaura `island_radius = 256` → **`2560`** (mundo 5120²).
- Crea el autoload `scripts/world/mundo_raiz.gd` como **única fuente de verdad del layout**: `CENTRO (2560,2560)`, `SPAWN_JUGADOR (3860,3860)` (llanura de césped), `SPAWN_CONTENIDO`.
- Migra consumidores (fauna, skyline, recursos) al centro real.
- El diff cita la *"Petición del usuario: la isla debería ser 10 veces más grande..."* y el Log 751/753 del cierre M09/M167.

**Veredicto B2:** **2560 es la verdad INTENCIONAL** — no es un typo ni un accidente. Es el "Isla 10×" que el usuario pidió, committeado en `c107419`. El problema es que **la migración quedó a medio hacer**: spawn/ocean/validador/docs/AGENTS.md nunca se actualizaron al 2560; el comentario L142-144 quedó contradictorio. Por eso tu "regla de oro" (`AGENTS.md` L1109-1113: *"radio ~256 para isla visible"*, *"centro = (island_radius, island_radius)"*) y `GUIA-GODOT/08-terreno-voxel.md` §10.15 (*"Radio: 256 unidades"*) y el `04-Codigo.md` de M167 (*`island_radius = 256`*) **están desactualizados**. El error que temías es real, pero está en la **documentación/regla de oro, no en el código**.

### B3 — Propuesta de reconciliación en 3 opciones

| Opción | Qué fuente cede | Costo | Riesgo / nota |
|---|---|---|---|
| **A — Terminar la migración 5120² (el CÓDIGO manda)** | Docs/AGENTS.md/GUIA-08/M167 ceden al código (2560) | Medio: L147 ya está bien; arreglar **L184** → `MundoRaiz.SPAWN_JUGADOR (3860,3860)`, **L205** océano centro (2560,2560) + tamaño 6200² (Log 751), **validador L60-69** → parametrizar desde `MundoRaiz` (leer `island_radius`/`CENTRO`, no literal 256), y actualizar AGENTS.md/GUIA-08/M167 + comentario L142-144. | Máxima fidelidad al diseño pedido. Requiere grep de otros hardcodeos de 256 (otros agentes pudieron construir sobre 256). Toca tu AGENTS.md (infra compartida) → lo haces vos. |
| **B — Revertir a 256 (los DOCS mandan)** | El código cede a los docs: `L147` 2560→256, y `MundoRaiz` neutro/remove (o `CENTRO=(256,256)`) | Bajo en código (1 línea) + sanear MundoRaiz/comentarios. | **Desecha el "Isla 10×" que el usuario pidió explícitamente** (c107419 cita la petición). Solo si se cancela oficialmente la isla 10×. |
| **C — Freeze + documentar WIP (interino pragmático)** | El código se reconoce como verdad emergente; docs pasan a 2560 **con bandera WIP**; validador se hace paramétrico | Bajo: actualizar AGENTS.md/GUIA-08/M167 a *"radio 2560, mundo 5120², migración M09/M167 en curso; spawn/ocean/validador aún en centro legacy (256,256), pendiente vía MundoRaiz"* + arreglar validador L60-69 para que deje de fallar en falso. | No cambia el comportamiento del mundo (sigue físicamente inconsistente hasta terminar A), pero **desbloquea a otros agentes** de construir sobre el radio equivocado y frena el gate ciego. |

**Recomendación de hy3:** hacer **C ya** (barato, corrige la "regla de oro" y frena el gate falso), y luego decidir **A vs B** como un voto de diseño deliberado. La evidencia dice que **A es el destino previsto** (el usuario pidió 10× y `c107419` es el rework real), así que apuntaría a A; B solo si la isla 10× se cancela. En ningún caso dejar el estado actual (2560 en código + 256 en todo lo demás), porque eso es precisamente lo que puede hacer que otro agente construya una isla con el radio equivocado.

---

## Commits y estado del working tree

- **Commiteado (selectivo, trampa 87):** `CHECKLIST-QA-SEALS.md` (filas M94/M114 limpias + Notas M119/M65) + este `Logs/1146-...md`.
- **NO commiteado (queda en el worktree, para tu merge ~495 archivos):** `CHECKLIST-GLOBAL.md` (filas 94/114/119 editadas con las Notas P-33; M119 bajada a `🟡 QA-drift-doc`). **NUL (1) y CRLF (231) preservados** tras edición byte-a-byte.
- **NO tocado:** código ni docs de M167 (Parte B es propuesta); M93/M94 de DeepSeek sin commitear (fuera de alcance); `NUMEROS_DISPONIBLES.txt` (pool).
- **Pool:** primer libre reservado = **1146** (el coordinador dijo 1145, pero `--estado` reportó 1146 consumido). Siguiente libre = **1147**.
- **Advertencia EOL:** `CHECKLIST-GLOBAL.md` tiene líneas con terminador `\r` solo (no `\r\n`) mezcladas con CRLF; lo respeté tal cual. Si tu diff marca líneas completas, correr `scripts/editar_crlf.py` antes del merge.

## Resumen de veredictos P-33
| Módulo | Veredicto | Base |
|---|---|---|
| 65 Animales-IA | 🟡 suplementario (autor=hy3) | suite GREEN; 88/1; pack/school en `animales_ia/` (corrección: no `fauna/`). Sello = agnes (P-31) |
| 94 Retención | 🟢 sello limpio | 138/0/0; 7 .gd + 2 test presentes |
| 114 Playtest | 🟢 sello limpio | 186/0/0; 4 plantillas `docs/playtest/` presentes |
| 119 Actualizaciones | 🟡 sin sello | 118/0/0 pero 3 .gd documentados ausentes (drift) |
| 167 Isla-Raíz | — (solo propuesta) | 2560 intencional (c107419, "Isla 10×"); migración a medio hacer |
