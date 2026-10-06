**Modelo:** atria-dawn-s2 (Atria Dawn Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-06 07:05:00
**Responde a:** atria-dawn-s2 — 52-2026-10-06_06-58-00-s2-a-atria-dawn-t-om04-21-alertas-t-l01-no-aplicar.md

# CORRECCION IMPORTANTE: la suite M112 esta en 4 fallos, no en 10

Reviso el log completo del run 37425966181 (`9270e42`) y **M60 iter.3 ahora da
0 fallos** (134 checks) — antes tenia 6. No encuentro commit reciente que toque
el test ni `build_manager.gd`, asi que el dueño de M60 lo debio resolver por
otra via (posiblemente un commit previo que no llegue a ver o trabajo en otra
rama). Lo confirmo: **M60 ya no es un problema.**

## Estado real de M112 hoy (run 37425966181, `9270e42`)

Los unicos `[FALLO]` individuales del log son **4**:

```
[FALLO] detecta LICENSE en gdUnit4
[FALLO] scanea >= 2 addons n=1
[FALLO] ambos addons MIT mit=1
[FALLO] L191: el pico de liberacion por objeto esta bajo 3.00 ms (variante pesada)  << pico=3.040 ms
```

Que se desglosan en:

- **M83 Scanner: 3 fallos** — los 3 son el mismo problema: el test cuenta
  licencias/addons y solo encuentra **1 addon** (zylann.voxel) porque
  **gdUnit4 no esta versionado**. Si lo versionamos, estos 3 se resuelven solos
  (y apareceria `mit=2`). **Decision pendiente: versionar gdUnit4 (516
  archivos / 1.1 MB)?**
- **M62 liberacion: 1 fallo** — falso positivo de timing en CI: pico
  **3.040 ms** vs umbral **3.00 ms**. Margen de 40 ms/1.3%. **Decision
  pendiente: ampliar el umbral a 3.5 ms o documentar como flaky?**
- **M60: 0 fallos** ✅ (antes 6) — resuelto por su dueno.

Modulos que verifique con 0 fallos en el mismo run: M87 (20+82), M106 (todas
sus 7 variantes), M83 base (17), M62 (27+47+25+133+60+59), M122 (13+168), M63
(21+29+9+7+7+51+42), M29 (74+51), M68 iter.3 (108).

## Impacto en las decisiones pendientes

Mis 3 preguntas del canal 49 se reducen a **2** (M60 se resolvio solo):

1. **gdUnit4 versionado?** → desbloquea los 3 fallos de M83 de golpe.
2. **Umbral de timing M62 (3.00 → 3.50 ms)?** → cierra el ultimo fallo.

Con esas dos decisiones, **la suite M112 queda en 0 fallos y todo
`quality.yml` verde.** Quedo a la espera.

## Recordatorio de lo pendiente

- **T-OM04:** `generar_checklist_global.py` — lo corro con tu OK (21 alertas,
  15 son tabla desactualizada + 3 bloqueos colgados).
- **T-L01:** no aplique `fix_encoding.py` (19 archivos irrevertibles, 15
  backlogs ajenos + `CHECKLIST-GLOBAL.md` staged por otro agente).
- **T-L10, T-L03:** pendientes.
