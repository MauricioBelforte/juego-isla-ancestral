# PROMPT — kimi-k3 (Kilo Code)
**Asignado por:** atria-dawn (coordinación, Log 1091/1092)
**Fecha:** 2026-09-20
**Tareas:** M106 Seguridad (continuar) + M122 Crash-Reporting (retomar stale)

---

## Contexto para ti

Eres el modelo con mejor rendimiento medido en este proyecto: **5/5 tareas con suite rc=0**,
~9 min/tarea, cero sobre-cierre. Tu especialidad confirmada es **seguridad** (CyberGym 86.5
→ 4/4 tareas de M106 + middleware rate limiting, 87 checks totales 0 fallos).

## Tarea 1 — M106 Seguridad: continúa (61 ítems `[ ]`)

`DOCUMENTACION/106-Seguridad/plan-actual/05-Checklist.md` está en **145/206** con **61 `[ ]`**.

Toma los siguientes 5 ítems en orden del backlog. Método probado (ya tuyo):
- Patrón RefCounted **sin `class_name`** (pitfall 9.41), preload
- Inyección por constructor para testeo headless
- Config data-driven (reutiliza el catálogo de políticas existente)
- Suite con guardián anti-falso-verde (marcador `_fin` por bloque)

**⚠️ La integración HTTP real (interceptar requests, responder 429) es de M77 — difiérela.**
El middleware T005 es componente de decisión headless; no lo cablees al servidor.

## Tarea 2 — M122 Crash-Reporting: retoma o libera

M122 está 🔵 a tu nombre pero **stale 15 días** (plan-actual sin tocar desde 2026-09-04).
Tienes **80 ítems `[ ]`** (185/265).

**Decisión obligatoria:** retomas o liberas. Si liberas, dímelo y lo reasigno.

Si retomas: **crash reporting es adyacente a M106** (captura + reporte de fallos = tu zona).
Empieza por los RF de captura de stack trace y volcado a archivo, con suite headless.

## ⚠️ Cambio en M103

**M103 Logging te fue reasignado a DeepSeek-V4.1-Flash** (2026-09-20). K3, tú no tocaste su
plan-actual desde el 2026-09-15 — te concentraste en M106. Liberado de tu lado.
**T-022 y T-109 de M103 son tuyos vía M122** (RF18 crash reporting integración y
bug_{timestamp}.log): DS los dejará `[?]` con dueño M122.

## Recordatorios del protocolo

- Reserva log: `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo <X>`
- Push a git: **NEGATIVO** (instrucción del usuario)
- Sync de los **3 registros** al cerrar: `05-Checklist.md` (marcas **y** línea `**Totales:**`),
  `CHECKLIST-GLOBAL.md`, tu backlog
- Codificación UTF-8 obligatoria
