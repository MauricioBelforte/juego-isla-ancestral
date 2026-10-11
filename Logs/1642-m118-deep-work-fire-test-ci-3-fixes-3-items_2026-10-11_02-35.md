# Log 1642: M118 deep work — fire test de CI real, 3 fixes de causas raiz, 3 [ ] implementables cerrados

**Fecha:** 2026-10-11
**Hora:** 02:35
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Encargo H del director (mimo): profundizar M118 (CI/CD) sobre sus 4 `[ ]` abiertos. El push
`bf23406..6134034` (realizado horas antes) sirvió como **fire test real** de GitHub Actions:
disparo los 3 workflows del proyecto, lo que permitio diagnosticar 5 fallos con causa raiz
confirmada contra logs de CI reales (no hipotesis). Se aplicaron 3 fixes y se implementaron
los 3 items implementables de despliegue.

## Hallazgos contra CI real (runs 38112515046 / 38112515056 / 38112515059)

1. **Testing Suite failure — gdUnit4/bin/ no versionado (BUG-128).** `game/isla-ancestral/.gitignore:44`
   (`addons/*/bin/`) excluye el `bin/` de gdUnit4, que contiene **GDScript puro**
   (GdUnitCmdTool.gd 546 B, GdUnitCopyLog.gd 5104 B). `GdUnitCmdTool.gd` es el entry point del
   job "Godot Tests (GdUnit4)"; en checkout limpio da `File not found` → exit 1. Patron T-98.
2. **UTF-8 sin BOM failure — 6 archivos con BOM.** 2 en DOCUMENTACION/150-Diseno-Sonoro-Narrativo/
   (plan-actual y plan-inicial 01-Requerimientos.md), 4 en Mensajes entre modelos/ (atria-dawn #2/#5
   —mios—, s2 #189/#194).
3. **Linter + Formatting failure — patron T-108.** `Identifier not found: AnimationService` en
   `scripts/animacion/animacion_jugador_m48.gd:53` (script nuevo de mi commit da4ca3f). 345/980
   scripts referencian autoloads globales y solo este falla; los 114 autoloads existen en worktree y
   en HEAD (`git cat-file -e` sobre los 114, 0 faltantes); codificacion UTF-8 limpia. Causa:
   `--import` recompila solo scripts nuevos/modificados **antes** de registrar los autoloads como
   singletons → falso "Identifier not found". Los 345 scripts viejos pasan por cache.
4. **M112 Integration failure — bug en M68 (dueño ajeno).** Todas las suites reportan 0 fallos
   (M63 51/0, M63-iter6 42/0, M29 74/0, M29 51/0, M68 108/0) pero el proceso sale exit 1.
   `test_transporte_m68_iter3.gd` imprime el resumen y muere antes del `quit(0)` (L138-140).
   La logica de exit code esta bien; el proceso se cae entre el print y el quit. **Derivado.**
5. **CI roto cronicamente desde 2026-10-07** (ultimo success `d9534a0`, 68 failures desde entonces).

## Cambios Realizados

- **`game/isla-ancestral/.gitignore`**: anadida `!addons/gdUnit4/bin/` con comentario citando
  BUG-128. Verificado con `git check-ignore`: ya no se ignora.
- **`scripts/verificar_bom.py --fix`**: 6 BOM quitados; re-verificacion "Sin BOM" (0 archivos).
- **`.github/workflows/quality.yml`**: nuevo paso `Rebuild script cache with autoloads registered`
  (`godot --headless --editor --quit --path game/isla-ancestral`) entre `--import` y `--check-only`
  en los 2 jobs (godot-lint y format-check). YAML validado con `yaml.safe_load` (12 jobs OK).
- **`.github/workflows/release-build.yml`**: 2 jobs nuevos —
  - `deploy-itch` (P5 + I.99): trigger en tag `v*.*.*` + workflow_dispatch; instala butler desde
    broth.itch.ovh; `butler push` por plataforma (linux/windows/macos) con `--userversion`;
    canal `${ITCH_USER}/${ITCH_GAME}:${tag}-${os}`. Sin `BUTLER_API_KEY` se saltea con `::warning::`.
  - `notify-stakeholders` (J.109): `dawidd6/action-send-mail@v4` con body que linkea el GitHub
    Release y el run; `if: tag push`. Sin secretos SMTP se saltea con `::warning::`.
  - YAML validado: 7 jobs (test, release-gate, build, checksum, release-notes, deploy-itch,
    notify-stakeholders).
- **`DOCUMENTACION/118-CI-CD/plan-actual/04-Codigo.md`**: tabla de workflows actualizada con los
    2 jobs nuevos; ampliada la seccion "Pendientes reales"; anadidas Notas del Agente completas
    con el diagnostico, los fixes, lo que no se pudo hacer y recomendaciones.
- **`DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md`**: sin flips de marca (regla del
    director). Se referencio el log en la cabecera.

## Archivos Modificados/Creados

- `game/isla-ancestral/.gitignore` (fix BUG-093)
- `.github/workflows/quality.yml` (fix T-108 x2 jobs)
- `.github/workflows/release-build.yml` (deploy-itch + notify-stakeholders)
- `DOCUMENTACION/118-CI-CD/plan-actual/04-Codigo.md` (doc)
- `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md` ( referencia a este log)
- 6 archivos con BOM corregidos (DOCUMENTACION/150 x2, Mensajes entre modelos/atria-dawn x2, s2 x2)
- `Logs/1642-...` (este log)

## Verificacion

- `yaml.safe_load` OK en ambos workflows (12 jobs quality, 7 jobs release-build).
- `git check-ignore` confirma que `addons/gdUnit4/bin/GdUnitCmdTool.gd` ya no se ignora.
- `python scripts/verificar_bom.py` → "Sin BOM: ningun archivo empieza con EF BB BF".
- `git cat-file -e HEAD:` sobre los 114 autoloads → 0 faltantes (descarta la hipotesis de
  autoload apuntando a archivo inexistente).
- Conteo de scripts con autoloads: 345/980 referencian autoloads globales (evidencia de que
  los autoloads SI se resuelven en CI; el fallo es especifico del script nuevo).
- **Sin commits** (regla del encargo: "0 commits por ahora"). Todos los cambios quedan en el
  working tree para que el director planifique el commit.

## Limitaciones

- No se pudo ejecutar Godot 4.7.2 localmente (el sandbox bloquea `.exe` fuera del workspace).
- `deploy-itch` y `notify-stakeholders` no se probaron end-to-end: requieren secretos del repo
  que solo el fundador puede configurar.
- El bug del M68 iter.3 queda abierto, derivado al director (modulo ajeno).

## Notas

- Los 4 `[ ]` de M118 no se flipearon (regla: flips = director). El avance queda documentado
  en las Notas del Agente de 04-Codigo.md para que el director decida los flips.
- BUG-128 registrado en `DOCUMENTACION/11-BUGS.md`.
