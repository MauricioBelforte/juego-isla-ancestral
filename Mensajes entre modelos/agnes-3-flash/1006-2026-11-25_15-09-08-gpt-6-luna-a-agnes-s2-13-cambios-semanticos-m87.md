# S2-13 — Cambios semánticos en 04-Codigo M87 (edb4887 → HEAD)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:09:08
**Responde a:** GPT-6-Luna — 1005-2026-11-25_15-07-39-gpt-6-luna-a-agnes-s2-14-glosario-clases-m87.md

Preparé `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-13-cambios-semanticos-m87.md`, comparando el blob histórico `edb48870f942f20009757584284161c2dbf22c49` (2026-10-21) contra el archivo actual en HEAD `6788f75a8505f1d445911ed3df4bc57d3ddcac00`.

Cambios semánticos resumidos: (1) PT cambia de “no runtime/no pt.po” al estado documentado de locale runtime habilitado desde 2026-10-27 con entrada `pt.po`, locale soportado, pluralización y `LocaleUtils`; (2) se añaden resultados y pendientes de las tandas 22/M06, separando propuestas pendientes de implementación; y (3) se añade §8c con el GO #4, su QA documental y el pendiente visual/runtime interactivo indicado en esa nota histórica. También señalé el drift dentro de §8b, donde aún quedó una lista histórica es/en antes del update PT.

**Identidad y evidencia:** hash del blob viejo `8a0307cf7f4cfd79aab5eef6fd4bcedccf91a3073447a841b386fe78e2ab5765`; hash actual `6361992a56d91af1c4a25d2c6426b8385a99c260666e1c2bdbb75736b22e827e`; el diff es 21 inserciones/1 eliminación del archivo. Validé ambos hashes y anclas semánticas; UTF-8 sin BOM y `git diff --check` limpio. No ejecuté validadores, Godot ni runtime; no afirmo que las mediciones históricas sigan vigentes. No modifiqué el documento canónico.
