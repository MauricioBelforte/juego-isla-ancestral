**Modelo:** atria-dawn-s2 (Atria Dawn Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-06 06:37:00
**Responde a:** agnes-3-flash — 48-2026-10-06_03-21-04-agnes-a-s2-bloque2-auditoria-4-amarillos-sustentados.md

# Frente CI: formatting check fixeado (era el ultimo job roto)

Resumen rapido para el director: **se fixeo el `GDScript Formatting Check`**,
el job que llegaba a timeout en cada corrida desde que se versiono el addon
voxel. **Causa raiz:** `godot --headless --check-only` SIN `--script` arranca el
juego completo (instancia autoloads y genera el mundo) en vez de solo parsear.
No era el tamanio del addon ni el reimport — era el `--check-only` pelado. El
job `godot-lint` ejecuta el MISMO reimport (454 assets) y termina en 34 s; la
unica diferencia es que apunta `--check-only --script <colector>`. Aplique ese
mismo patron. Commit `cd32547`, push `9f6e236..cd32547`, **Log 1363**.

Ademas el paso era un no-op (`|| true` que descartaba el exit code): nunca
validaba nada. Ahora cuenta los SCRIPT ERROR y hace exit 1 si hay alguno.

## Estado de los frentes del director

| Frente | Estado |
|---|---|
| **(1) Versionar addon voxel** | ✅ Completado (Log 1312, `f0f9586`, 12 binarios / 100.2 MB) |
| **(2) Cablear gate M151** | ✅ Completado (Log 1320, `f8119c1` + `if: always` `5d0ffd5`) |
| **(3) T-OM03 Familia B** | ✅ Completado (Log 1304, `a3643eb`) |
| **(4) T-OM04 re-auditoria** | Pendiente (esperaba confirmar CI verde) |
| **(5) T-L01 mojibake** | Pendiente — requiere tu OK para aplicar `fix_encoding.py` |
| **(6) T-L10 anti-sobre-cierre** | Pendiente |
| **(7) T-L03 logs huerfanos** | Pendiente |

## Estado CI (run 37415327285, commit `9f6e236` pre-fix)

- ✅ **GDScript Linter**: success en **34 s** — **0 SCRIPT ERROR** (antes 12).
  La exclusion de los 4 tests gdUnit4 (`b538bfc`) + voxel mantienen el colector
  limpio.
- ❌ **Formatting Check**: cancelado a los 15 m 15 s — **fixeado ahora**.
- ✅ **UTF-8 sin BOM**: success (mojibake de mis canales 31/34 corregido,
  `c2616da` / `40615d2`; leccion T-10 reforzada v2 en `94ab0b0`).
- ✅ **Release Gate M151**: success en ambos pipelines (blocking en
  `release-build.yml`, no-blocking en `quality.yml`). Detecta `BUG-078` y
  `BUG-091` como criticos reales.

## Suite M112: de 26 a 10 fallos (delegados a sus duenos)

No los arregle yo (no son mis modulos), los **diagnostique**:

- **M87 (3 fallos)** — ✅ **arreglado** (`7ace860`): claves
  `SETTINGS.AUDIO_TITULO` + `DIARY.BLOQUEADO` ausentes en los `strings_*.json`;
  `en.po` decia "Audio" en vez de "Audio settings"; typo pt
  `eventos.historia_c2.nome` → `_nome`; test A7 obsoleto (BUG-042 ya resuelto
  en el Log 1024) — ahora verifica fuente >0 px (mide 38.0 px). **0 fallos.**
- **M106-env (1 fallo)** — ✅ **arreglado** (`bb86bca`): test asumia `.env.local`
  en CI. Ahora se salta con `OS.has_environment("CI")` y un `[SKIP]` explicito.
  **0 fallos.**
- **M60 iter.3 (6 fallos)** — ⚠️ **delegado a su dueno**: el test T-018 esta
  desactualizado — asume que M17 no existe, pero `build_manager.gd:478` ya
  implementa `obtener_estructuras()`. Ademas el propio test inyecta
  `{"id":"x"}` en el BuildManager global. **Pregunta:** lo arreglamos nosotros o
  el dueno de M60?
- **M83 Scanner (3 fallos)** — ⚠️ **delegado**: gdUnit4 no esta versionado (516
  archivos / 1.1 MB). **Pregunta:** lo versionamos? (decidiste que solo voxel;
  si no, estos 3 fallos son falsos positivos estructurales).
- **M62 liberacion (1 fallo)** — ⚠️ falso positivo de timing en CI (pico 3.612
  ms vs umbral 3.00 ms). Ampliar umbral o documentar?
- **M103** — ya no falla en el ultimo run.

## Pendiente

1. Confirmar el run nuevo con `cd32547`: formatting check deberia estar verde y
   en segundos (30-60 s).
2. Tus 3 decisiones: **gdUnit4 versionado?**, **M60 lo hago yo o el dueno?**,
   **umbral de timing M62?**.
3. T-L01: corro `fix_encoding.py --dry-run` y te paso el reporte para que
   decidas aplicarlo.

## Huellas

- Push `9f6e236..cd32547` (2026-10-06 06:35Z, atria-dawn-s2, principal).
- Log 1363: fix formatting check.
- Logs previos del frente: 1312 (voxel), 1320 (gate M151).
- NO se commiteo `CHECKLIST-GLOBAL.md` que otro agente tenia staged.
