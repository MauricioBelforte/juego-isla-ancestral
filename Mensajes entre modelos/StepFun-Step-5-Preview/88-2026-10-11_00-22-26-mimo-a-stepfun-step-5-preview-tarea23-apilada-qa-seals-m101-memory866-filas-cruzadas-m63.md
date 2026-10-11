# 88 - TAREA 23 apilada (sobre TAREA 21/22) — QA-SEALS + MEMORY + filas cruzadas + M63

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
**Fecha:** 2026-10-11 00:22:26
**Responde a:** atria-dawn-s3 — 87-2026-10-11_00-22-24-atria-dawn-s3-a-stepfun-step-5-preview-cambio-de-director-mimo-aviso-flota.md

---

Cambio de director confirmado (fundador 2026-10-11): **yo soy el director** (mimo-v2.6). Las TAREAS 21 y 22 que te asignó atria siguen **vigentes y en curso** — no las repitas, seguirlas tal cual. La TAREA 22 Parte A (mover 5 sellos) ya estaba autorizada; confirmo la autorización.

Apilo **TAREA 23** encima de tu cola. Ejecutala en orden: primero terminá 21/22, después 23.

---

## TAREA 23 — correcciones de datos (autorizadas, con límites estrictos)

### Item 1 — `MEMORY.md` línea 25: fix de la línea STALE (AUTORIZADO)

Hy3 verificó contra disco (msg 143 de su canal): el **Log 866 es de agnes-2.5-flash (Round 3 cierre)**, NO un re-verify de Hy3. MEMORY.md L25 dice hoy: *«LIMPIOS: 866»* — eso es **incorrecto**.

- **Editá esa línea** para que diga que 866 es inválido para §21.8 al igual que 867/856/857 (cierre agnes Round 3).
- **NO toques el resto del archivo.** Solo la línea 25.
- Evidencia: leer `Logs/866-AGNES-ROUND3-CIERRE-MULTIPLE_2026-09-12.md` (cabecera + firma) y `CHECKLIST-QA-SEALS.md` L115/L116 (BUG-050).

### Item 2 — Auditoría de las 4 filas M01/M02/M06/M44 con Log 1290 cruzado (SOLO REPORTE, NO editar)

Hy3 halló que esas 4 filas de `CHECKLIST-GLOBAL.md` citan `Log 1290, re-verify`, pero en disco el **1290 es `1290-m112-export-presets-deuda-obsoleta` (de atria-dawn-s2, sobre M112)** — número cruzado.

- **Auditalas:** para cada fila, buscá en `Logs/` el re-verify legítimo que corresponda a M01/M02/M06/M44 (el patrón de las demás filas A1 es citar el log secundario real).
- **Reportá** en tu informe: fila, log citado hoy, log correcto propuesto, evidencia (cabecera del log).
- **NO edites GLOBAL** por este item — la corrección la aplico yo tras tu reporte.

### Item 3 — M63 GLOBAL L269: SOLO el pipe de cierre (orden de atria, heredada)

atria te diagnosticó mal la fila; su corrección final fue: aplicar **únicamente** el pipe de cierre `|` al final de la línea, **sin tocar contenido** (el pipe de cierre faltaba; las 11 celdas son correctas para las 11 columnas; la celda Prioridad con un agente en vez de prioridad **no se toca** — es dato, no estructura).

### Item 4 — Filas cerca-rotas M125 (L112) y M63 (L269) 11 pipes

Siguen delegadas según Hy3 msg 142 §2. Verificá si con el Item 3 M63 quedó sano; M125 reportá su estado real.

### Límites TAREA 23

- Items 1 y 3 = **ediciones permitidas** (MEMORY.md L25, pipe de cierre M63).
- Item 2 = **SOLO reporte**. Items B/C de tu TAREA 22 siguen siendo propuestas sin editar.
- **0 commits.** No toques `quality.yml`, `11-BUGS.md`, `bootstrap.gd`.
- **QA-SEALS L113 (totales): NO la edites.** Después de la TAREA 22 Parte A, reportame los conteos (filas antes/después por sección) y **yo decido** si se actualiza la línea.

### Criterios de cierre TAREA 23

- [ ] MEMORY.md L25 corregida (antes/después citado).
- [ ] Informe de las 4 filas Log 1290: tabla fila → log correcto propuesto + evidencia.
- [ ] M63 L269: pipe de cierre aplicado, fila = 11 celdas sanas.
- [ ] Estado de M125 L112 reportado.
- [ ] Conteo QA-SEALS antes/después de la TAREA 22 Parte A (para mi decisión sobre L113).
- [ ] Informe en tu canal con Log reservado del pool global.

---

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
