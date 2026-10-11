# Log 1651: QA §21.8 M118 — 3 flips del director (P5/I.99/J.109) VÁLIDOS, 3 fixes CI verificados

**Fecha:** 2026-10-11
**Hora:** 07:20
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

QA cruzado §21.8 (READ-ONLY) de los 3 flips `[ ]`→`[x]` aplicados por el director mimo sobre el deep work de atria (Log 1642, fire test de CI real). **Resultado: 3/3 flips VÁLIDOS. Conteo 105 [x] / 1 [ ] / 0 [?] = 106 sin drift.** Se reportan 2 observaciones (no bloqueantes).

## Cambios Realizados

- Verificación READ-ONLY. **0 ediciones de código/documentación, 0 commits.**
- Informe al director en mi canal (msg 237).

## Verificación detalle

### Los 3 flips contra disco

| Flip | Ítem | Claim | Verificación |
|---|---|---|---|
| **P5** | L28 | job `deploy-itch` en `release-build.yml`, trigger `v*.*.*`, butler push por plataforma, degradación limpia sin `BUTLER_API_KEY` | ✅ Job en L211-280; trigger `push.tags: v*.*.*` L12 + `workflow_dispatch` L13; `butler push` por plataforma L269 con `--userversion`; skip con `::warning::` si falta la key L226-227 |
| **I.99** | L100 | mismo job `deploy-itch` vía `workflow_dispatch`, requiere `BUTLER_API_KEY` | ✅ `workflow_dispatch` confirmado L13-29; job y secreto confirmados |
| **J.109** | L109 | job `notify-stakeholders` con `dawidd6/action-send-mail@v4` | ✅ Job en L282-307; action en L298; degradación limpia sin secretos SMTP L290-291 |

### Los 3 fixes de CI (Log 1642) contra disco

| Fix | Verificación |
|---|---|
| **BUG-128** (gdUnit4/bin no versionado) | ✅ `game/isla-ancestral/.gitignore` L51 `!addons/gdUnit4/bin/`; `git check-ignore` sobre `addons/gdUnit4/bin/GdUnitCmdTool.gd` → **no ignorado** (exit 1) |
| **T-108** (falso "Identifier not found") | ✅ paso `Rebuild script cache with autoloads registered` (`godot --headless --editor --quit --path game/isla-ancestral`) presente en **los 2 jobs** de `quality.yml` (L58-59 godot-lint, L137-138 format-check) |
| **BOM UTF-8** (6 archivos) | ✅ `python scripts/verificar_bom.py` → "Sin BOM: ningun archivo empieza con EF BB BF" |

### Muestreo §21.8.2.b (8/8 artefactos contra disco)

Todos los artefactos citados por los flips y fixes existen y contienen lo afirmado: job deploy-itch, trigger v*.*.*, butler push, job notify-stakeholders, action-send-mail@v4, .gitignore gdUnit4/bin, quality.yml rebuild x2, verificar_bom limpio.

### Validez estructural

- `yaml.safe_load` OK en ambos workflows (release-build 7 jobs, quality 12 jobs).

### Conteo — sin drift

| | Real | Totales | Director (msg 235) |
|---|---|---|---|
| [x] | 105 | 105 ✅ | 105 ✅ |
| [ ] | 1 | 1 ✅ | 1 ✅ |
| [?] | 0 | 0 ✅ | 0 ✅ |
| **Total** | **106** | 106 ✅ | 106 ✅ |

El único `[ ]` (L199, "Validación en GitHub Actions real") es **deuda legítima**: requiere un push/tag real al remoto para disparar la pipeline.

## Observaciones (no bloqueantes)

1. **Texto obsoleto en los 3 ítems flipeados.** L28, L100 y L109 conservan la nota `**[QA s2 2026-10-09, Log 1539]** CASO A — ... se mantiene \`[ ]\` (no es \`[?]\`)`, que ahora **contradice** la marca `[x]` aplicada por el director. Mi QA anterior (Log 1539) evaluó los ítems antes del fire test del Log 1642; la evidencia nueva (jobs implementados y CI real disparado) fundamenta el flip. La marca es correcta; **el texto debería actualizarse** para reflejar el flip del director (eliminando o tachando "se mantiene `[ ]`"). No es inflación: los artefactos existen y hacen lo claimado.

2. **Commit ab3e544 arrastró trabajo ajeno staged.** Mi acuse 236 se commiteó junto con 8 archivos del deep work de la otra sesión atria (workflows, 04-Codigo.md, 05-Checklist.md, Log 1642, .gitignore) que estaban en el index. El contenido quedó íntegro en historial; el mensaje del commit dice solo "Se acuso el encargo K..." aunque incluye ese trabajo. Se informa al director para trazabilidad.

## Veredicto

**3/3 flips VÁLIDOS; M118 cierra en 105/106** (1 `[ ]` legítimo). El deep work de atria (Log 1642) es real y verificable: fire test de CI con 5 fallos diagnosticados contra logs reales, 3 fixes de causa raíz aplicados y confirmados en disco, y 2 jobs nuevos funcionales. La limitación de no poder probar `deploy-itch`/`notify-stakeholders` end-to-end (secretos del repo que solo el fundador puede configurar) está documentada honestamente como KnownIssue no bloqueante.

## Archivos Modificados/Creados

- `Mensajes entre modelos/atria-dawn-s2/237-*` — informe al director (msg 237)
- `Logs/1651-*` — este log
- `Logs/NUMEROS_DISPONIBLES.txt` — número 1651 consumido
