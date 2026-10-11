# Log 1607: Gate .gitignore anidados — 0 conflictos anidados; drift real = raíz (3144 rastreados-ignorados)

**Fecha:** 2026-10-10
**Hora:** 17:44
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Auditoría de `.gitignore` anidados autorizada por el director (msg 107). Resultado: **los
`.gitignore` anidados NO compiten de forma dañina con el raíz** — el caso reportado
("godot-mcp excluido afectó a capturas/") es un **diagnóstico erróneo**: el raíz excluye el
directorio entero `tools/mcp/godot-mcp/` (L99), git **nunca consulta** su `.gitignore`
anidado, y las capturas están doblemente excluidas (L94 `**/capturas/` + L99) apuntando la
misma dirección. El drift REAL está en el **`.gitignore` raíz**: **3144 archivos rastreados
que las reglas del raíz marcan como ignorados** (dominados por `.claude/` = 2754, que
contradice la §27 "skills versionadas"). Sin fixes (reportar, no arreglar).

## Inventario de .gitignore

| Archivo | Rastreado | Estado para el git del repo |
|---|---|---|
| `.gitignore` (raíz, 251 líneas) | sí | **Activo** — el que manda |
| `game/isla-ancestral/.gitignore` (50 líneas) | sí | Activo, redundante-inofensivo (plantilla Godot estándar) |
| `tools/mcp/godot-mcp/.gitignore` (28 líneas) | **no** | **INERTE** — raíz L99 ignora el directorio entero; git nunca lo lee |
| `.kilo/.gitignore` + copias en worktrees | no | Inertes (raíz L85 ignora `.kilo/`; worktrees = clones separados normales) |
| `.pytest_cache/.gitignore`, `tools/mcp/.venv/.gitignore` | no | Auto-generados por sus herramientas, contenidos en sí mismos |
| `.claude/skills/.../godot.gitignore` | sí (como archivo de skill) | Plantilla de referencia de una skill, NO un .gitignore activo |

## Veredicto del caso reportado (godot-mcp / capturas)

`git check-ignore -v` demuestra que **la raíz L99 es la única regla que decide** para todo
bajo `tools/mcp/godot-mcp/`:

```
.gitignore:99:tools/mcp/godot-mcp/   tools/mcp/godot-mcp/capturas/cap_1.png
.gitignore:99:tools/mcp/godot-mcp/   tools/mcp/godot-mcp/.gitignore   (el anidado está él mismo ignorado)
.gitignore:99:tools/mcp/godot-mcp/   tools/mcp/godot-mcp/node_modules/x.js
```

- `tools/mcp/godot-mcp/`: **0 archivos rastreados** (git ls-files). El directorio completo
  está fuera del repo por diseño (L97-100 "repos embebidos").
- El `.gitignore` anidado de godot-mcp (node_modules, build, .env*, etc.) es **inerte** en
  este repo: solo tendría sentido si la carpeta se usa standalone (es un clone embebido).
- Las capturas bajo godot-mcp: excluidas por L99 (directorio) + independientemente por L94
  (`**/capturas/`) — **misma dirección, cero competencia**. El anidado no menciona capturas
  en absoluto. **El reporte era un falso positivo.**

## Veredicto de game/isla-ancestral/.gitignore

- ~10 patrones redundantes con el raíz (`.godot/`, `*.import`, `*.translation`, `.vscode/`,
  `.idea/`, `.DS_Store`, `Thumbs.db`) — plantilla Godot estándar, **inofensiva** (útil si se
  abre el subdir standalone).
- Aporta reglas únicas coherentes: `.mono/`, `data_*/`, `/android/`, `/builds/`, `/export/`,
  `.gdskills/`, `addons/*/bin/` + `!addons/zylann.voxel/bin/` (excepción voxel, coherente con
  raíz L20-26), `/Godot/`.
- Verificado: `game/isla-ancestral/scripts/build/x.gd` **NO** está ignorado (el fix ancla del
  Log 1276 `/build/` sigue vigente; el anidado usa `/builds/` plural anclado — sin colisión).

## Hallazgo REAL: drift rastreado-pero-ignorado del raíz (3144 archivos)

`git ls-files -c -i --exclude-standard` = 3144 archivos **rastreados** que una regla del
raíz marcaría como ignorados (siguen versionados porque ya están en el índice; el peligro es
que **archivos nuevos de esas familias quedan bloqueados en silencio** de `git add`).
Ojo: `git check-ignore` sin flag los reporta como NO ignorados (los omite por estar
rastreados); la evaluación real de reglas es con `--no-index`.

| Regla raíz | Línea | Rastreados-ignorados | Regla ganadora (check-ignore --no-index) | Diagnóstico |
|---|---|---|---|---|
| `.claude/` | L88 | **2754** (skills) | `.gitignore:88:.claude/` | **Contradice §27** ("skills se versionan en git"). Funciona porque ya están rastreadas; una skill NUEVA no se puede `git add` sin `-f`. |
| `*.blend` | L218 | 232 | `.gitignore:218:*.blend` | Drift legacy; la política LFS (L216) es intencional para archivos nuevos, pero los 232 legacy crean estado mixto. |
| `*.uid` | L13 | 144 | `.gitignore:13:*.uid` | Medio versionado: algunos `.uid` rastreados, los nuevos se ignoran. |
| Nombres sin ancla | L186-203 | 14 | L186 `_*.txt`, L191 `broken_log_refs.txt`, L192 `count_lists.ps1`, L193 `data.drift.json`, L203 `POSTLAUNCH_CHECKLIST.md` | Reglas pensadas para la **raíz** pero **sin barra inicial** → capturan las copias movidas a `PAPELERA/` (9), `scripts/` (2), `tools/` (2) y `DOCUMENTACION/M97/.../POSTLAUNCH_CHECKLIST.md` (1). |
| **Total** | | **3144** | | |

### Sub-hallazgo crítico: `.claude/` vs §27

AGENTS.md §27: "Skills: `.claude/skills/` (raíz del proyecto, **versionado en git**)".
Root L88: `.claude/` (ignora todo). 2754 archivos de skills están rastreados (force-added
histórico) pero cualquier skill nueva es **silenciosamente inaddable**. Es la contradicción
más grande del gate. Posibles fixes (NO aplicados, decisión del director):
- `!.claude/skills/` (re-incluir solo skills) + mantener `.claude/` para el resto, o
- quitar `.claude/` y listar explícitamente lo que sí se ignora (si algo hay que ignorar).

### Sub-hallazgo: nombres sin ancla

L186-203 ignoran por basename en cualquier profundidad. Las 14 copias movidas quedaron
rastreadas-pero-ignoradas. Fix (NO aplicado): anclar a raíz (`/broken_log_refs.txt`, etc.)
o negar con `!PAPELERA/...` si se quiere versionar la papelera.

## Recomendaciones (sin aplicar — para director / s2)

1. **`.claude/` (L88):** decidir `!.claude/skills/` vs quitar la regla — es la mayor
   contradicción política (2754 archivos).
2. **Nombres sin ancla (L186-203):** anclar a `/` los que eran de raíz; revisar si
   `PAPELERA/` debe versionarse (9 archivos rastreados) o no.
3. **godot-mcp (s2):** su `.gitignore` anidado es inerte; si s2 quiere versionar tooling
   bajo esa carpeta (p. ej. `cap_godot.py` de AGENTS.md §24), necesita un `!` en el raíz o
   reducir L99 a subcarpetas (node_modules etc.). Discusión con s2.
4. **`*.uid` / `*.blend`:** estado mixto conocido; documentar o aceptar como deuda.

## Archivos Modificados/Creados

- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1607)
- (solo lectura: git ls-files/check-ignore, lectura de 3 .gitignore)

## Siguiente

Informe msg 108 al director. Sin fixes, sin flips. Cola: M105 hooks (verificador de
integración de telemetría de s2) cuando el director lo asigne.
