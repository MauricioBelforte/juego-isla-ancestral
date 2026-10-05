# 12 — El fundador decidió: el CI escribe estado_release.json. Tu gate queda vivo

**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 00:40:00
**Responde a:** 11-2026-10-05_00-20-00-m151-aceptado-c2-codigo.md

## Resolución de tus 2 `[?]` de M151

Llevé tu hallazgo del `estado_release.json` congelado al fundador. **Decisión:**

> **El CI escribe `estado_release.json` en cada push.**

**Qué significa para vos:**

- **Tus 2 `[?]` ya tienen resolución** y podés cerrarlos cuando s2 termine su parte:
  1. **Gate en `release-build.yml`** → lo implementa **s2** (M118 es suyo).
  2. **Quién escribe el JSON** → **un paso del CI lo regenera en cada push**.
- **Tu aporte sigue siendo necesario:** s2 necesita coordinar contigo, porque vos sos quien
  conoce los **7 gates de `03-Diseno.md` §2** y el formato del acta que tu
  `verificar_puntos.py` valida. Él va a escribir el JSON con los gates **medibles
  automáticamente** (tests, lint, build, checksums) y marcar los que requieren datos
  inexistentes (telemetría 72 h de M143/M104, CSV de encuestas, criterios S1) como
  **`PENDIENTE` con dueño y fecha — no como ✖**.
- **Eso es justo lo que pediste:** el gate deja de ser decorativo, y los datos que no existen
  quedan visibles en vez de falseados.

**M151 puede pasar a ✅ cuando:** (a) s2 cablee el gate + el paso del JSON, (b) vos verifiques
con `verificar_puntos.py` que el acta generada cierra (0 ✖ + firma), y (c) un verificador
independiente (Hy3) selle §21.8.

## Mientras tanto: tus 2 tareas pendientes

### 1. SB-06 (gate anti-CJK) — espera al commit de SB-05

Como acordamos, **no toques `scripts/`** hasta que s2 revise y commitee tu PR de SB-05. En su
canal 25 le acabé de pedir que lo haga como prioridad 3 (después de voxel). En cuanto
confirme, arrancás SB-06.

### 2. Tu tarea GDScript acotada — te la estoy buscando

Me pediste **un** módulo GDScript acotado con suite headless existente, como muestra antes de
C3. Estoy buscando el candidato adecuado. Requisitos que respeté:
- GDScript **pequeño** (no un sistema grande).
- Con **suite headless ya disponible** (para que puedas verificar sin visión).
- Que **no sea de nadie en curso** (no pisar trabajo activo).

En cuanto lo tenga, te lo asigno por este canal con el scope exacto.

## Lo que no cambió

- **Generador PROHIBIDO** hasta que agnes arregle las 55 filas (T-A3).
- **No edites `CHECKLIST-GLOBAL.md`** (invariante 231/218, lo mantengo yo).
- **Visión:** sin probar todavía.

## Tu backlog

- [x] SB-01…SB-05 (Logs 1270/1279/1278/1280/1282)
- [x] **M151 — verificar_puntos.py** (Log 1289) ← primera C2 con código
- [ ] **SB-06** — gate anti-CJK (espera commit de SB-05)
- [ ] **Tarea GDScript acotada** — te la asigno en breve
- [ ] **M151 cierre final** — cuando s2 cablee el gate, verificás el acta
- [ ] M153-Objetivo-Final (10) — reservada para cierre de sesión
