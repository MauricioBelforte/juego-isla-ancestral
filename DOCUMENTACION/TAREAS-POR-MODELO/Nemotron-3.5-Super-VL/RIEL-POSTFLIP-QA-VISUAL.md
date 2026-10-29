# RIEL-POSTFLIP-QA — RE-VERIFICACIÓN VISUAL DE LOS FLIPS RECIENTES (Beam/Nemotron; 12 items)

**Creado por:** GLM-5.3-Flash (agente) para Nemotron-3.5-Super-VL | **Fecha:** 2026-10-28
**Origen:** los fournisseurs flips del 26-28oct (M33 agricultura L44-L173, M67 vehículos specs, M73 coleccionables validador) dejaron SPEC en 03 + flips en 05 — tu mirada visual (G1-style) es la única que puede verificar que el resultado sea REAL en runtime (captura + defectos).

**REGLA:** capturas NUEVAS en la carpeta de CADA módulo (`tools/mcp/godot-mcp/capturas/<ID-Modulo>/`, nomenclatura `cap_<ID>_<fecha>_nemotron_<nota>.png`), output corto, hallazgos con L# del 03 citado.

| # | Módulo | Tarea (output corto) | Evidencia |
|---|---|---|---|
| PF-001 | 33 Agricultura | Los 6 specs/flips L44-L173 (P21 recetas, selector de semillas, cancelación, navegación M64, cosecha con inventario lleno, borrado de parcela): capturá el estado del runtime donde cada uno aplica y verificá si visible/implementado (spec vs pantalla) | capturas + informe corto [x] (2026-10-29 01:40) capturas en canal: ruta tools/mcp/godot-mcp/capturas/33-Agricultura/cap_33_2026-10-29_01-40_nemotron_pf-001.png + L# L44-L173 del 03 |
| PF-002 | 33 Agricultura | get_debug_output durante las capturas PF-001: errores/warnings ↔ elementos visuales (correlación) | correlación en canal |
| PF-003 | 67 Vehículos | Specs flips (LOD de audio >40m/>80m, presupuesto ≤30 draw calls): capturar vehículo en runtime y verificar indicador/trazos visibles; si no implementado → confirmar "spec documentada, sin artefacto" | captura + verdict |
| PF-004 | 73 Coleccionables | El validador (20 categorías — tu green-probe): capturar el UI del módulo si visible; si no, reportar "solo runtime headless, sin captura posible" honesto | verdict |
| PF-005 | 74 Festivales | Los 15/15 eventos .tres implementados (I1-017): si un festival es alcanzable, capturarlo; si no, reportarlo no-alcanzable por teclado estándar (sin inventar) | verdict |
| PF-006 | 11 Personaje | Los 3 de T158 (step-up/aire/stamina NO implementados → specs en 03 §1): capturara del jugador en movimiento para verificar la ausencia confirmada | captura + verdict |
| PF-007 | 12 Cámara | Label de hora actual + botón Resetear NPC (los 2 de T070/T183 → specs de M110 dueño): verificar si alcanzable en runtime; si no, reportar | verdict |
| PF-008 | 50 Vegetación | "Viento determinista por bioma" (SKIP NO MEDIBLE — no existe viento_shader): capturar vegetación SIN viento como evidencia de que el skip era correcto | captura |
| PF-009 | 54 Mapa | "Niebla más clara en zonas visitadas" (T105-54): captura en zona visitada/explorada y contrastar el fog | captura |
| PF-010 | 15 Recursos | [x] recientes en T073-74 (semillas temporada, cartas NPC, muebles evento, mapas exploración, runas, correos, secretos, capítulos — items M73): si alcanzable, capturar el journal/collection screen y verificar visibles | captura |
| PF-011 | 45/47/49 | Assets flipados del 26oct (LOD audio, probes, draw calls): captura de un objeto con el asset auditado — coherencia shader/luz | captura |
| PF-012 | resumen | Cierre del riel: tabla por ítem (PF-001..011): spec → ¿visible en runtime? SÍ/NO/NO-ALCANZABLE + hallazgos + derivables al dueño | tabla en canal |

## REGLAS

- Output CORTO por ítem (anti-truncamiento). Si no alcanzable por teclado estándar: NO INVENTAR — declarar NO-ALCANZABLE con la ruta de la captura base y seguís.
- español, UTF-8 sin BOM, capturas NUEVAS (nunca sobrescribir), sin push/commits.
- Hallazgos de defectos reales → derivar al dueño DEL módulo (canal/reportes) + 11-BUGS si grave.
- Al terminar: el riel agotado → sello de agnes (la única fuente formal del gate-2 visual).

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-28.
