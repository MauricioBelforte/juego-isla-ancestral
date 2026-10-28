# Log 2221: Tanda M87 conciliación POST-PT (JSON↔.po, 34 orphan, 115 .po-solo) — encargo agnes 302

**Fecha:** 2026-10-27
**Hora:** 22:30
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Tanda M87 report-only (encargo agnes 302, acuses 303/304, Regla CERO 304): conciliación post-PT de los catálogos i18n con criterio canónico de consumidor (gd-no-test + .tscn + data/dialogues, excluyendo Obsoletos/ y docstrings) + detección de consumo dinámico con evidencia archivo:linea. T1 paridad total; T2 34 orphan exactos; T3 115 .po-solo reclasificadas (108 vivas-runtime — el .po NO está inflado); T4 documentación con 4 ítems [x] nuevos en 05 M87 (135/140) sin flips de los 5 [?].

## Cambios Realizados
- T1: JSON×3 170/170/170 dif 0; .po×3 274/274/274 (270 simples + 4 plurales) dif 0; cruce idéntico 3 idiomas (159 comunes / 11 solo-JSON mortuas / 115 solo-.po); paridad cruzada 0/0.
- T2: 34 orphan (ui6/eventos14/SETTINGS9/msg3/npc2) con tabla clave→estado; corrección Obsoletos (ui.inventario/npc.hola/npc.adios = orphan reales); eventos.* consumidor solo tests → deuda M149.
- T3: 115 = 49 M68 literales (transport_localizer.gd:36-89 + interact_prompt.gd:94 + SIGN.GENERICO L297) + 10 STOP vía transport_network.tres + LM L309 + 30 M68 templates (LM L332-342/399-410) + 14 DIARY.CAT dinámicas (diary_layer.gd:412) + 4 CLOCK.ESTACIONES dinámicas (w_reloj.gd:198) + 2 test-only + 2 drift ítems (inventario_iter4.gd:283 convención inexistente) + 1 deuda M53 + 1 muerta real (VECINO_SALUDO) + 1 exenta (catalina). Cuadre 49+10+30+1+14+4+2+2+1+1+1=115.
- Hallazgos colaterales reportados: H1 M27.ISLA.* sin claves i18n (generar_islas.gd:115 vs 13 .tres); H2 ítems M159 sin integración i18n; H3 4 claves JSON docstring-only (verificar gate-2); H4 lección parser .po (bug msg 282 reintroducido en v1, corregido v2).
- T4: 05-Checklist M87 +4 ítems [x] nuevos (Totales 140, 135[x]/5[?]) sin tocar los 5 [?] con dueño; GLOBAL fila 87 → 135/140; msg 305 a agnes; backlog Ling ESTADO vuelta 5 + anexo.
- Numeración: colisión 304 (gemelo de agnes en disco sin consumir, race con consumo del helper) → informe = 305 (consumido del pool); el 304 del pool queda hueco sanado y anotado.

## Archivos Modificados/Creados
- DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md (Totales 136→140; +sección Conciliación POST-PT con ítems 137-140 [x])
- CHECKLIST-GLOBAL.md (fila 87: Progreso 135/140, última actividad 2026-10-27 22:30, +nota conciliación)
- Mensajes entre modelos/Ling-3.1-Flash/305-2026-10-27_22-30-00-de-ling-3-1-flash-a-agnes-3-flash-informe-tanda-m87-conciliacion-post-pt.md
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md (ESTADO vuelta 5 + anexo de mediciones)
- Logs/2221-tanda-m87-conciliacion-post-pt_2026-10-27_22-30-00.md (este archivo); Logs/NUMEROS_DISPONIBLES.txt (2221 consumido)
- Temp/kilo/ (no versionado): tanda_m87_informe.md, tanda_m87_conciliacion.py (v1 buggy), tanda_m87_v2.py, tanda_m87_v3.py, probe_dinamicas.py, probe_focal.py, probe_tres.py
- Hallazgo de conteo (§21.8.2.b): 05 M87 en disco tiene 140 marcas [x] / 0 [ ] / 0 [?]; 5 de esos [x] son formato híbrido del FLIP T219-87 de Reflection-Beam-1.0 (2026-10-26): marca [x] + texto "Sigue [?] deuda externa" con dueño (L71/L74/L112/L116/L117). Conteo semántico: 135 completados + 5 deuda-externa-con-dueño = 140. Drift declarativo preexistente (Totales histórico 131[x]/5[?] vs 136[x] reales post-flip) reportado a agnes/director en msg 305. Ningún flip propio: los 4 ítems nuevos (137-140) son trabajo medido esta vuelta con evidencia en disco. Observación encoding: blob HEAD del 05 en UTF-16LE+BOM (deuda histórica preexistente); working tree UTF-8 preservado por mi edición (git diff numstat 12/1 = solo mis líneas).
