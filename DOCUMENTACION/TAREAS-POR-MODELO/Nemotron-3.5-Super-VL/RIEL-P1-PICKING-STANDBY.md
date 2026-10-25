# RIEL-P1 — PICKING DOCUMENTAL (STANDBY hasta coordinación con la directora; 10 items genéricos)

**Armado por:** GLM-5.3-Flash (orden fundador 25oct) | **Fecha:** 2026-10-25

**ESTADO: STANDBY.** La cola actual de picking (T057 → T265) está asignada a **Reflection-Beam-1.0** (en ejecución). Este riel se ACTIVA solo cuando la directora:
(a) reparta módulos nuevos a Nemotron con doble-check anti-duplicado (contra la cola root de Beam y los backlogs consumidos BACKLOG-10/12/13/14), o
(b) confirma que el fuel de reposición por investigación (RIEL-I1) ya está validado y convertido a tareas TASCHE.

**Hallazgo de contexto (para no duplicar):** el fuel estructurado de los 05 (`- [ ]` y `- [?]`) está agotado para NUEVOS apilados; Beam tiene ~2.300 items en cola (T057-T265). Tomar ítems de módulos ya apilados = duplicación — prohibido.

| # | Tarea genérica (se concreta cuando la directora asigne módulo) |
|---|---|
| P1-001 | Picking de los [ ] vivos del módulo asignado: L# + texto exacto + cubo (A-DOC/FORMULA, B-EDITOR/ARTE, C-SKIP por dueño/dependencia) |
| P1-002 | Ídem con filtro de exclusión (no apilar: FLAG FUNDADOR/TECNICO, módulos 🔵/🔴, items en cola de otro agente) |
| P1-003 | Documentar fórmula/spec en 03 (sección única, grep previo anti-duplicado M31) y flip en 05 con cita — solo cubos A |
| P1-004 | Re-verificación de ítems [?]: si la definición existe → flipa [?]→[x] con cita; si el dueño es ajeno → deja [?] y anota skip (honesto) |
| P1-005 | Reporte por tanda: `modulo | escritas | flips | skips | preguntas` + 5 muestras de ancla (formato Beam, probado) |
| P1-006 | Skip listado honesto de cubos B/C (listar para que la directora derive) |
| P1-007 | Anti-duplicado previo: buscar (módulo, L#) en la cola `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/tareas/` antes de apilar cualquier ítem |
| P1-008 | Confirmar con la directora el formato TASCHE vigente antes del primer apilado (20 tareas por archivo, un módulo por archivo; referencia: tareas/T078 en adelante de Beam) |
| P1-009 | Si el módulo asignado ya tiene tandas de Beam en curso: NUNCA tocar los mismos L#; coordinar por canal antes |
| P1-010 | Cierre de tanda: UN mensaje de reporte + [x] en el archivo de tareas correspondiente (regla de Beam ya validada) |

**Lecciones de Beam aplicables (de N.2 de la guía comparativa):** conteo con lstrip sobre el prefijo (jamás de memoria), flip con línea textual (no parafrasis), releer scope antes de tocar funciones ajenas.
