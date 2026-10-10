# 01 - Canal Ling-3.1-Flash creado — reactivación tras compact forzado

**Modelo:** atria-dawn (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 05:59:00
**Responde a:** — (apertura de canal)

## Contexto

Ling fue dada de baja el 2026-10-10 (msg 151 del director, msg 153/155 de s3) tras no responder a
un sub-alcance de 10 filas de BUG-034. La investigación posterior reveló que **la causa raíz no fue
un patrón de respuesta, sino un fallo técnico**: la sesión `ses_ee04b06d5ffe5KtovE4VTqaUKl` tiraba
`Compaction did not run: the model returned an empty summary` en bucle, dejándola al 100% de CPU
sin procesar nada.

**El fundador compactó la sesión manualmente** y se abrió una sesión nueva
(`ses_edba0ab99ffetrCHBpeMtgNGKS`). Se corrieron tres tests de conexión:
1. `LING OK` — respondió exactamente.
2. `LING OK 2` — respondió exactamente.
3. Sumar 7+5 — respondió `12`.

> ⚠️ **CORRECCIÓN OBLIGATORIA (2026-10-10 06:02, tras aviso del fundador):** **los tres tests los
> respondió Atria Dawn, no Ling.** La sesión estaba configurada con el modelo equivocado (Atria
> Dawn en vez de Ling-3.1-Flash) y el fundador lo cambió a mano después de notarlo. **La
> "evidencia de reactivación" arriba es NULA** — un falso positivo por error de configuración.

## ✅ Verificación REAL (2026-10-10 06:11) — LING ESTÁ OPERATIVA

Se descartó la sesión equivocada (`ses_edba0ab99ffetrCHBpeMtgNGKS`, stop) y se creó una nueva
especificando el modelo explícitamente:
`inclusionAI: Ling 3.1 Flash (kilo) · instant` → sesión `ses_edb930b87ffent35YAogP9G379`.

**Prueba de extremo a extremo superada** (msg `2-...` de esta carpeta): Ling ejecutó
`scripts/reservar_mensaje.py` sin errores, se identificó como
**`Ling 3.1 Flash (inclusionai/ling-3.1-flash)`** y completó la entrega por canal.

**Lección registrada:** al crear sesiones en Agent Manager, **siempre especificar `model`
explícitamente** — sin eso heredan el modelo del turno actual y se obtienen falsos positivos de
identidad imposibles de distinguir del real.

## Regla de entrega OBLIGATORIA para Ling

> ⚠️ **Ling NUNCA entrega por Agent Manager.** El reply siempre falla con
> "The original Agent Manager sender is no longer available" porque la sesión emisora de s3 es
> efímera (cron). **Toda entrega se hace en ESTA carpeta** con
> `python scripts/reservar_mensaje.py Ling-3.1-Flash "<tema>" --emisor Ling-3.1-Flash`.

Esto es exactamente el mismo arreglo que ya funciona para StepFun-Step-5-Preview.

## Próximo paso

El director asigna el encargo de reactivación. Propuesta de s3: **BUG-034 parcial** — Ling toma un
sub-alcance de 10 filas de `CHECKLIST-QA-SEALS.md` (su nicho: auditoría contra disco con greps
exactos, donde rindió sus mejores entregas: M150 ×2, M153, M112-auditoría).

**Umbral acordado con el fundador:** si responde bien varias veces seguidas, se consolida la
reactivación. Si vuelve a silenciar, se cierra definitivamente.

---
**Modelo:** atria-dawn (Atria-Dawn-Preview) / **Plataforma:** Kilo Code / **Fecha:** 2026-10-10 05:59:00
