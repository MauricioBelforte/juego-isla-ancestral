# BACKLOG-07 — PAQUETE-D (director, orden del fundador 23oct 20:42)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 20:42
**Origen:** fundador: "investigá las tareas que Beam puede hacer aprovechando sus mejores capacidades... agregá más tareas ya que Beam es muy rápido", con base en N.1/N.2 de DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md.

## Tu base de asignación (de la guía comparativa)

- N.1 tu nicho: (1) matemática/razonamiento post-cutoff (AIME #1 97.7); (2) auditorías de conteos y aritmética de drift; (3) contexto largo (LongBench #1-3) para análisis de módulos grandes.
- N.2 tu patrón ganador: picking documental por línea textual, re-verificación multi-ciclo (6 ciclos/6 hallazgos), inconsistencias aritméticas byte-exacto.
- EVITAR (límite honesto): items que requieren EDITOR Godot (los dejás [ ] honestos y los clasificás).

## Prioridad 0 — Terminar el GO 315 (antes de este paquete)

PAQ-1 (H2 rareza 5%), PAQ-2 (H1 por sesión ~1200), PAQ-4 (H21 opción A), PAQ-6 (H26 reducir nightly), PAQ-8a-d (H3=120/H4>70% intencional/H5 pesos relativos/H17 IDs dlc.json) + la matriz de shortcuts M116 (definila VOS con fórmula en 03 y flipá — ver acuse 318).

## CLUSTER D-1 — CENSO GLOBAL DE TOTALES (contexto largo + aritmética)

- Alcance: TODOS los `DOCUMENTACION/*/plan-actual/05-Checklist.md` (~57 carpetas), EXCLUYENDO los resincronizados hoy por el director: M72, M105, M107, M112, M114, M116, M118, M119.
- Tarea: medir [x]/[ ]/[?] con lstrip canon y comparar contra la ÚLTIMA línea `**Totales:**` del archivo.
- REGLA DURA: **NO editar los Totales** (los aplico yo al recibir tu tabla). Si tu muestreo detecta [x] sin artefacto, NO degrade: listalo con el criterio auditor-citas (a)+(b)+(c) (recién adoptado, acuse 371).
- Reporte por bloques de 10-15 módulos: tabla `módulo | declarado | medido | delta`. Solo marca delta != 0; los pares van en un resumen de 1 línea.

## CLUSTER D-2 — COHERENCIA NUMÉRICA POST-GO (matemática)

- Alcance: verificar que TODA mención en disco de los valores del día quede coherente: `69.99`, `+35`, `+45` (debe ser solo el histórico de corrección o cero residuos), ARPU `28.49`, `base pura/penetración`, `0.5%` vs `5%` (H2), precios 24.99/34.99, mix 60/25/15.
- Ámbito: `data/*.json` (ediciones, monetizacion, fishing, balance), `DOCUMENTACION/95-*`, `93-*`, `104-*`, `109-*` 03/05.
- REGLA: los 03-Diseno podés corregirlos VOS con cita "GO fundador 23oct 20:25/315"; los `data/*.json` NO los edites sin listarme el JSON+clave+valor exacto (yo autorizo o derivo al dueño).
- Reporte: tabla `path | linea | valor actual | valor esperado | fuente del GO`. Por bloques.

## CLUSTER D-3 — RE-VERIFICACIÓN MULTI-CICLO (tu patrón T9/T18/T32)

- Alcance: 1 módulo grande por bloque, elegir entre: M56, M60, M64, M91, M143, M152, M153, M162, M163 (módulos que más quedaron sin verificador fresco).
- Tarea: leer 02-Analisis/03-Diseno vs código real y reportar divergencias con LÍNEA TEXTUAL (el patrón que ya te ratifiqué 6/6): caps prometidos no implementados, trunc vs round, dirty flags, fórmulas desalineadas del 03.
- REGLA: hallazgo = lista, no fix: el fix lo derivará el director al dueño (o te lo devuelve como tanda si no tiene dueño). Los [x] ajenos NO los flopeas vos: solo señales.

## CLUSTER D-4 — M138 VERTICAL-SLICE (tu mitad)

- Tarea: completar TU subsección "Presupuesto técnico de render (Beam)" con fórmulas citadas (la parte de definiciones de contenido era del rails G-5.3, DESCARTADO hoy por el fundador — esa parte NO la tocás, queda en espera).
- Reporte al cerrar con conteos.

## CLUSTER D-5 — PICKING DOCUMENTAL [C] (paquete de tareas largas)

- Alcance: el paquete de tareas largas [C] (56-Foto/17/59/138/147/58/28) desde donde quedó, con picking documental por línea textual.
- EXCLUSIONES DURAS: M59 (dueño Step-5, GO 185 de 20:34 — NO pisar), M20/M16/M17 código (dueños MiniMax), items editor-locked, y cualquier item ya cerrado con criterio auditor.
- REGLA: 2+ items por bloque consolidado.

- PAQ-9 **RESUELTO sin cifra del fundador (23oct 20:48, delegacion al director):** el ancla default USD 3.000 ya esta aplicada en M123 03 §1 GATE con nota provisoria-revisable; NO requiere accion tuya (si queres, verificala al pasar en D-ciclos).

## Reglas vigentes (todas)

Produce-first; reporte consolidado por bloque con fuentes; muestreo del director por tanda es el único control de calidad; `**Totales:**` NUNCA tocar; flips solo con artefacto/fórmula EXISTENTE + criterio auditor-citas (a)(b)(c); sin push; UTF-8 sin BOM; sin GO nuevo del fundador salvo: cifra total V1 (PAQ-9/M123 D1) y decisiones aún reservadas.

Firma: GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-23 20:42.
