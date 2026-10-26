# BACKLOG-MASTER — Nemotron-3.5-Super-VL (checklist maestro de rieles; v2 con cronómetro)

**Mantenido por:** agnes-3-flash (directora) — v2 por GLM-5.3-Flash por orden del fundador 25oct ("backlog master que sirva de guia para mandarlo a trabajar solo en sus distintos archivos backlogs") + metodología: `DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md`.
**Motor:** `CRONOMETRO-NEMOTRON-3-5-SUPER-VL.md` (prompt fijo del cron, orden de rieles, hard stops).
**Ficha del modelo:** `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` → N.6 + N.6-bis.
**Estado del agente:** activo en Kilo (T1.1 visión APROBADA en vivo: 11/11 hits, 0 alucinaciones — veredicto canal 003). Autonomía total sobre sus rieles; el director interviene por excepción.

## CÓMO TRABAJA (ciclo del cronómetro — resumen)

Leer CRONÓMETRO → tomar el PRIMER riel no agotado (orden de capacidad, NO reordenar) → abrir su archivo de backlog → ejecutar el siguiente ítem `[ ]` → marcar `[x]` en ese archivo con fecha+evidencia → reporte en canal al cerrar tanda (REGLA CERO) → si el riel quedó 100%: marcar el check del riel acá y pasar al siguiente → AL FINAL responder mensajes de agnes si hay.

## CHECKLIST DE RIELES (marca [x] al AGOTAR cada backlog)

- [ ] **B-0 CALIBRACIÓN** — restan T1.2 (citas textuales) y T1.3 (fix pequeño con test). T1.1 visión: APROBADA (25oct, veredicto canal 003). Si agnes designa archivos, ejecutarlos primero de todo; NO bloquean los rieles de solo-lectura.
- [x] **B-1 G1 — QA VISUAL ACTIVO CON GODOT-MCP: 36 items** → `RIEL-G1-GODOT-MCP-VISION-ACTIVA.md` — abrir el juego (run_project), capturas ACTUALES (nomenclatura repo, nunca sobrescribir), analizar con visión, correlacionar get_debug_output, reportar defectos en canal. **Nicho máximo (nadie más lo hace).** Prioridad de arranque: G1-001, 002, 003, 006, 009. AGOTADO: 35 [x] + 1 [?] honesto (G1-002: Escape no abre menú de pausa; "Escape - Liberar mouse").
- [ ] **B-2 V1 — QA VISUAL DE CAPTURAS HISTÓRICAS: 88 items** → `RIEL-V1-VISION-CAPTURAS.md` — las 44 carpetas reales de `tools/mcp/godot-mcp/capturas/` (2 ítems por módulo: describir + defectos). Output: reporte en canal. Batch 5.
- [ ] **B-3 W1 — WEB RESEARCH/VERIFICACIÓN: 12 items** → `RIEL-W1-WEB-RESEARCH.md` — su segundo nicho publicado: verificar licencias/assets legales (M85/M86/M79), URLs activas de las guías, claims de M154/M97/M61 contra fuentes web, vigencia del free tier de su propia familia.
- [ ] **B-4 D1 — DOC INTELLIGENCE: 15 items** → `RIEL-D1-DOC-INTELLIGENCE.md` — drift de CHECKLIST-GLOBAL, censo FLAGS, .po, Logs, docs/, scripts/, mapas de ocupación. Solo-lectura con citas.
- [ ] **B-5 I1 — INVESTIGACIÓN + NUEVO FUEL: 20 items** → `RIEL-I1-INVESTIGACION.md` — 4 fuentes de reposición (Plan-inicial-minimo, 5-FUTURAS-MEJORAS, GUIA-GODOT, derivaciones ex-director). Output:_PROPUESTAS_ con L#+cubo para validación de la directora (él no apila directo).
- [ ] **B-6 P1 — PICKING DOCUMENTAL: 10 items** → `RIEL-P1-PICKING-STANDBY.md` — **STANDBY**: se activa solo con asignación de la directora + anti-duplicado (la cola T057-T265 es de Beam).

**TOTAL: 184 items** (T1: 3 — 1 hecha, 2 pendientes | G1 36 + V1 88 + W1 12 + D1 15 + I1 20 + P1 10 = **181 en rieles**).

## REGLAS FIJAS (detalle en canal 01 y cronómetro)

- Produce-first comprobable; en el riel visual el output es REPORTE en canal + capturas novas con nomenclatura repo (no edita 05s ni código).
- Citas textuales o nada (T1.1 demostrado). Mentar la evidencia en cada afirmación (ruta + L#).
- NO tocar módulos 🔵/🔴, colas de otros agentes, ni backlogs ajenos. Anti-duplicado (módulo, L#) contra la cola de Beam.
- Autonomía: consulta por EXCEPCIÓN (bloqueo/ambigüedad), mientras tanto sigue la tanda.
- Ítem no resuelto = `[?]` + razón honesta. Conteos por prefijo (lstrip), jamás de memoria.
- Sin push/commits. UTF-8 sin BOM. Español. Firma completa. REGLA CERO: reporte de tanda = trabajo que existe.

## PENDIENTES QUE NO SON SUYOS (no tocar)

- [ ] Cola de picking T057-T265 → Reflection-Beam-1.0 (en ejecución).
- [ ] BACKLOG-11 (562 ítems D-8) → asignado a DeepSeek (NO tomar sin orden).
- [ ] PT-runtime → decisión del fundador (Ling tiene plan listo).
- [ ] Las 4 consultas del fundador (frente de código, Bloque 0 M106-GCP, marca M01) → decisión del fundador (Jamás tocar GCP/credentials: el agente solo las analiza en D1-014 como texto).

## HISTORIAL

- 2026-10-25: canal + backlog v1 armados por GLM-5.3-Flash (log 2191); investigación en fichas N.6/N.6-bis (log 2188); T1.1 visión APROBADA en vivo (veredicto canal 003).
- 2026-10-25 (v2): metodología de agente autónomo publicada (`DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md`); cronómetro propio creado; rieles G1 (36, nicho máximo nuevo) y W1 (12, nuevo) agregados; orden fijado por capacidad medida. La directora agnes-3-flash ratificará y ajustará al volver.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25 20:20.
