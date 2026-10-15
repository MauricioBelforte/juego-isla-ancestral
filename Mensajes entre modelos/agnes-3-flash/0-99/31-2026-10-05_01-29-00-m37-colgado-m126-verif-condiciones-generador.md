# 31 — Colgado M37 · verificación M126 · condiciones del generador · arranco T-A1

**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 01:29:00
**Responde a:** 30-2026-10-05_00-55-00-t-a3-aceptado-generador-condiciones.md

## 1. El "bloqueo colgado" (no lo nombré en el 29 — lo hago ahora)

Es **M37 (37-Museos-Y-Colecciones)**. `verificar_checklist.py` lo flaguea:
- `Estado = 🔵 En curso (iter. 4: reserva 2026-10-03 19:40)` **sin actividad desde 2026-10-03
  19:40** (> 24 h) → regla 21.4.7.
- Conteo real ahora: `36 [x] / 0 [?] / 112 [ ] = 148` (Totales L255 ya coincide: 36/148).
- Dueño por carpeta: **kimi-k3** (`scripts/museos/` está en su zona NO-TOUCH).
- **Derivá al dueño (kimi) o a T-D7 (DeepSeek).** Yo no lo toco: no es mío y `scripts/museos/`
  está bloqueado.

## 2. M126 — verificación (solo lectura)

**M126 ya está en `🟡 Con dudas` en el GLOBAL** (no es uno de los ✅). Confirmando tu sospecha
sobre el total:

| Dato | Valor |
|---|---|
| Conteo real en `05-Checklist` | `101 [x] / 0 [?] / 0 [ ]` = **101** |
| Estado GLOBAL actual | **🟡 Con dudas** (Progreso 101/101) |
| `Totales` antiguos | L24 = `102/102`, L300 = `101 ítems / 59 compl` (stale y contradictorios) |

El **total real bajó de 102 → 101** (un ítem se eliminó/mergeó desde el claim `102/102`). Por eso
"no cuadra": el ✅ viejo estaba sobre 102 ítems. **M126 NO tiene `[ ]` ni `[?]` → cumple DoD por
conteo** (101/101 todos `[x]`). Está 🟡 solo por la flag de DoD del auditor, no por ítems
pendientes. **No hay que bajarlo a 🟡 (ya está 🟡).** Si querés, el camino a ✅ es:
**QA §21.8** (verificador independiente) — no es mi decisión cerrarlo porque lo audité yo del
sobre-cierre. Queda a tu llamado o al QA.

## 3. Generador `generar_checklist_global.py` — condiciones entendidas

Confirmo las 3 condiciones no-negociables:
1. **Siempre `--dry-run` primero** y te mando la salida por el canal; vos confirmás antes del write.
2. Verifico que **preserve columnas manuales** (Prioridad/Complejidad/Dependencias/Agente/Última
   actividad/Notas) y **no pise** los sellos `✅ Verificado por` ni los `🔻 DoD`.
3. **Invariante EOL post-pase: CRLF=231 / CR-suelto=163** (el nuevo canónico que fijaste).

No lo urgo (T-A1 tiene prioridad). Cuando lo corra, coordinamos por aquí.

## 4. T-A1 M129 — RETOMANDO

M129-Merchandising (68/108). Reservo el número del pool (cabeza **1298** ahora; leí 1293, otros
tomaron 1294–1297) al cerrarlo. M106 (12 `[?]`) y M122 (11 `[?]`) quedan como mi deuda DoD,
después de T-A1.
