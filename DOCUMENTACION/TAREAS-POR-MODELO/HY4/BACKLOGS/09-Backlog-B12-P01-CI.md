# Hy4 — B12 / P-01: cableado de suites en `encoding-guard`

**Fuente:** agnes-3-flash #05 P-01 (**GO: hacerlo**) + #07 (acuse B11 y orden confirmado)
**Fecha:** 2026-11-05 22:15:19 -0300
**Log:** 2318 · **Canal:** mensaje 08
**Estado:** CERRADO (P-01). El resto de la tanda sigue en `07`.

## Cierre P-01

- [x] GO verificado: #05 P-01 autoriza `quality.yml`; el índice y `07` lo listan como "no tocar" → el GO puntual y posterior manda sobre la regla genérica. Conflict registrado en el Log 2318 §0.
- [x] `scripts/test_verificar_bom.py` cableado en `encoding-guard` como gate duro. Verde medido: `checks=26 fallos=0 minimo=26`, exit 0.
- [x] `scripts/auditar_scratch_game.py --self-test` cableado como gate duro. Verde medido: `13 checks / 0 fallos`, bloques S1..S6, exit 0.
- [x] Hermeticidad comprobada: ninguna de las dos depende de archivos no versionados del worktree (trampa 98).
- [x] `validar_workflows.py --selftest` 6/6 y `validar_workflows.py` 6/6 workflows válidos, exit 0.
- [x] Cableado probado **EN ROJO por inyección**: 16 checks / 0 fallos / piso 16 MEDIDO; 6 mutaciones (2 de ellas → CIEGO), sin mutar `quality.yml`.
- [x] Formato: UTF-8 sin BOM, LF, sin U+FFFD, sin sufijo tolerante, sin permiso de fallo, sin pipe que oculte el exit code.
- [x] Reporte en canal (08) + Log 2318. Cero flips ajenos, cero QA §21.8, cero sellos, cero push.

## Hallazgo nuevo (reportado, NO tocado)

- [ ] `encoding-guard` ya sale **rojo en CI** por el paso «Mojibake scan»: `9 SUCIO / 0 IRREVERSIBLE`, de los cuales **8 están en HEAD**. Incluye `CHECKLIST-GLOBAL.md` (protegido). Requiere dueño y decisión de la directora (`fix_encoding.py` o techo de deuda declarado, patrón M127).
- [ ] El comentario de `quality.yml` sigue afirmando «0 SUCIO / 0 IRREVERSIBLE» medido el 2026-09-24: deriva documental.

## Decisiones de #07 — acusadas, pendientes de ejecutar

- [ ] **D-01 (prioridad alta)**: re-hornear M50 con `reescalar_v5.py` + commit. Criterio de cierre: `auditar_escalas_vegetacion.py --check` de 2/10 → 10/10.
- [x] **D-02**: NO regenerar la estrella. Reportado al fundador vía directora; queda registrado que el generador no reproduce el GLB de disco.
- [ ] **D-03**: 13 flips `[ ]` → `[x]` con cita en `CHECKLIST-OBJETOS-BLENDER.md`. Autorizado; va en commit propio, no colgado de CI.
- [x] **D-04**: los 2 `[ ]` del pez se dejan como están. Confirmado.
- [ ] **T-01a** Barquita de Aurora (~5 m): reportar por separado con captura + escala + ruta del GLB, según #05.

## Notas de protocolo

- Log 2318 reservado con `reservar_log.py --reservar` (head 2318 → 2319). El pool no se commitea.
- Canal 08 por `max(archivos reales)+1`: apareció el 07 de la directora mientras corría la vuelta.
- Aviso de discrepancia nº 31: directora vigente `agnes-3-flash`, automatización dice `GLM-5.3-Flash`.
- Worktree compartido: commit con pathspec selectivo, sin `git add -A`, sin `--amend`, sin push.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-05 22:15:19 -0300
