# BACKLOG-MASTER — GLM-5.3-Flash — UNIFICADO (metodología V2, fundador 2026-10-17, corregido 04:56)

**Mantenido por:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code — actualizado con evidencia y según nicho (GUIA-COMPARATIVA `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` + estado real del proyecto).
**Unificación 2026-10-17 (directiva del fundador: un solo backlog, en TAREAS-POR-MODELO, NO en canales):** este archivo integra (A) la COLA ACTIVA de 100+ tareas curada por el director y (B) el estado/registro histórico del BACKLOG-MASTER anterior (preservado íntegro desde git). **ESTE es el único backlog válido de GLM-5.3-Flash.** Tu canal (`Mensajes entre modelos/GLM-5.3-Flash/`) queda SOLO para comunicación (mensajes + pool de numeración).

## TU CICLO COMO AGENTE (en este orden)

1. **PRIMERA INSTANCIA:** lee si el director te escribió un mensaje en tu canal (`Mensajes entre modelos/GLM-5.3-Flash/`). Si hay mensaje dirigido a ti, RESPÓNDELO primero (numeración de hilo: último + 1; borra SOLO ese número del pool `NUMEROS_DISPONIBLES.txt` de tu carpeta de canal — pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el próximo item `[ ]` de la COLA ACTIVA (sección A) según tu nicho. Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar, escribe un REPORTE en tu canal al director: qué cerraste (ids), evidencia (archivos/tests), y marca `[x]` honesto en ESTE archivo (solo verificable en disco — REGLA CERO: sin reporte, el trabajo no existe).
4. El director actualizará ESTE backlog, la fila de `CHECKLIST-GLOBAL.md` y te responderá.

**Reglas fijas:** reserva 🔵 §21.3 en los 4 registros antes de tocar módulos · UTF-8 §28 · independencia QA §21.8/§21.23 · no editar el backlog de otro modelo · marcas `[ ]/[→]/[x]/[?]` honestas.

---

# (A) COLA ACTIVA — 100+ TAREAS (tandas curadas por el director)

# BACKLOG 100+ TAREAS PARA GLM-5.3-FLASH (yo) — Investigación previa por GLM-5.3-Flash

**Modelo:** GLM-5.3-Flash · **Plataforma:** Kilo Code · **Fecha:** 2026-10-16 00:00
**Nicho propio** (GUIA-COMPARATIVA §5.C2 — 320B/18B MoE multimodal nativo texto+imagen+video, AutomationBench 48.8, Z.ai Code Bench 29.0, $0.07-0.15 input, key de mi historial M19/M22/M28/M31/M34/M35/M67/M95/M146/M158): **scripting diario, documentación, batch processing, análisis de imágenes/renders, QA visual económico, herramientas internas y marketing/branding técnico.**
**Rol simultáneo:** asistente del director (canal `Mensajes entre modelos/GLM-5.3-Flash/`, prioridad máxima) + editor de los 5 BACKLOG-100-TAREAS-*.md de esta carpeta.
**Autoridad:** CANDIDATOS — nada se arranca sin encargo o reclamo §21.3 (4 registros). Conteos estimados a validar contra `05-Checklist.md` al reclamar.

## Reglas del reparto

- Confirmar módulo libre en CHECKLIST-GLOBAL + ESTADO-PARALELO antes de tocar.
- Un módulo a la vez; cerrar marcando backlog + 05-Checklist + GLOBAL, log con número del pool global, y reporte en mi canal (REGLA CERO).

## LAS 100+ TAREAS

### Bloque A — Herramientas internas (mi módulo ancla M109)

1. M109-Herramientas-Internas (120/138): diagnóstico de los 18 restantes + plan — 8 [M]
2. M109 b1: resolver pendientes de scripts-* (nombres de prefijo cap_/lanzar_/ver_) — 8 [M]
3. M109 b2: unificar duplicados en scripts-reutilizables/ con tests — 10 [M]
4. M109 b3: cierre con test_scripts.py en verde — 8 [M]
5. Mejorar parser de CHECKLIST-GLOBAL (resiliencia a filas rotas del estilo actual — fila 04 desalineada detectada hoy) — 8 [M]
6. Runner de diagnóstico rápido de repo (status/diff/log/encoding en un comando) — 8 [M]
7. Asistente de saneo UTF-8 por lote con dry-run visible — 8 [C]
8. Verificador de mojibake solo-cambios-nuevos (git diff) — 6 [M]
9. Generador de captura con historial (cap_godot.py v2: auto-increment, nota obligatoria) — 6 [M]
10. Script de push-assistant (redacta título+cuerpo según §4.2) — 6 [M]
11. Dashboards de flota: contar mensajes por canal del día — 8 [M]
12. Resumen diario automático de logs (agrupar por modelo) — 8 [M]
13. Validador de firmas en documentación nueva (**Modelo:**/**Plataforma:**) — 6 [M]
14. Chequeo de pool de logs vs. logs reales (alerta de números huérfanos) — 6 [M]

### Bloque B — Mapa, fotografía, coleccionables (Recom GLM Flash)

15. M54-Mapa (133/177): 44 pendientes → lote 1 (estética + iconos marcadores) — 10 [C]
16. M54 b2: fog de descubrimiento con capturas — 10 [C]
17. M56-Fotografía (26/137): lote 1 (modo foto UI + composición) — 10 [C]
18. M56 b2: filtros/galería (análisis de imagen nativo) — 10 [C]
19. M56 b3: cierre con validación de export — 8 [C]
20. M73-Coleccionables (26/135): lote 1 (catálogo de coleccionables) — 10 [C]
21. M73 b2: localización en mundo (mapa de posiciones) — 10 [C]
22. M73 b3: cierre con persistencia M60 — 8 [C]

### Bloque C — UI/UX y tutoriales (multimodal económico + doc)

23. M53-UI-UX (144/165): 21 pendientes → lote con capturas antes/después — 8 [M]
24. M57-Interfaz-De-Control (91/119): 28 pendientes — 8 [M]
25. M89-Diseno-De-Menús (124/125): 1 pendiente — 3 [S]
26. M88-Fuentes (174/185): 11 pendientes — 8 [M]
27. M58-Accesibilidad (154/183): 29 pendientes documentales/técnicas — 10 [C]
28. M92-Tutorial (132/185): 53 pendientes → lote 1 (español) — 10 [C]
29. M92 b2: amarrar Tutorial con M23/M22 — 10 [C]
30. M55-Diario (37/131): lote 1 visual/documental — 10 [C]
31. M92×M87: tutorial localizado (i18n) — 8 [C]

### Bloque D — Marketing, marca, legal (mi nicho documental)

32. M95-Monetizacion (19/113): lote 1 (política de precios/pase) — 10 [C]
33. M95 b2: comparativa de modelos de monetización (doc) — 8 [M]
34. M126-Marketing-Legal (100/101): 1 pendiente — 3 [S]
35. M127-Copyright (76/100): 24 pendientes — lote de atribución por asset — 10 [C]
36. M128-Identidad-De-Marca (60/100): lote 1 (paleta/logo/tono) — 10 [C]
37. M128 b2: brandbook con capturas — 8 [C]
38. M129-Merchandising (101/108): 7 pendientes — 6 [M]
39. M131-Créditos (86/95): 9 pendientes — 6 [M]
40. M82-Clasificación (95/100): 5 pendientes — 4 [S]
41. M83-Licencias (98/100): 2 pendientes — 3 [S]
42. M85-Modelos-3D-Legal (95/0): revisar conteo anómalo y documentar — 4 [S]
43. M78/M79/M80/M81: cierres menú 1-2 pendientes cada uno — 8 [S]

### Bloque E — Localización y nombres (deuda real del proyecto)

44. M87-Localización (131/136): 5 pendientes — 6 [M]
45. i18n: absorber las 112 claves externas documentadas por Ling (M87.5) — 10 [C]
46. i18n b2: interpolación de variables y pluralización — 10 [C]
47. M149-Nombres (99/100): 1 pendiente — 3 [S]
48. M149×M159: nomenclatura normalizada de objetos — 8 [M]
49. M148-Lore (115/117): 2 pendientes — 3 [S]

### Bloque F — Documentación panorámica (mi firma)

50. Auditoría de plan-actual desactualizado en 20 módulos 🟡 (04-Codigo vs. código real) — 10 [C]
51. Chequeo de 05-Checklist con regla de 100 ítems (módulos nuevos: cumples?) — 8 [M]
52. Actualización de los 4 documentos *-ACTUAL.md (resumen semanal) — 8 [M]
53. Barrido de emojis corruptos en todo DOCUMENTACION/ (siguiendo §28 sin tocar los exclusivos) — 8 [M]
54. Reclasificación de C2/C3 de s3 (módulos amarillos de modelos inactivos → activos) — 10 [M]
55. Mantenimiento de los 5 BACKLOG-100-TAREAS-*.md de esta carpeta (semanal) — 8 [M]
56. Análisis de capacidad por modelo a partir de logs recientes (guía comparativa viva) — 8 [C]
57. Actualización de §10.3 (tabla de prioridades de respuesta del director si cambian créditos) — 4 [S]
58. Documentación de errores nuevos en GUIA-GODOT/06-registro-errores.md — 6 [M]
59. Documentación de descubrimientos MCP en 06-GUIA-DE-CONEXION-VISION.md — 6 [M]
60. Verificación semanal del kit §23 (AGENTS + GLOBAL + scripts 8/8 PASS) — 6 [M]

### Bloque G — Balance, retención, postgame (doc + técnico liviano)

61. M93-Balance (131/134): 3 pendientes — 4 [S]
62. M94-Retención-Sin-FOMO (87/138): lote documental (tablas de eficiencia) — 10 [C]
63. M75-Postgame (17/130): lote documental de contenido postgame — 10 [C]
64. M71-Progresión: apoyo documental de 45 pendientes — 8 [M]
65. M72-Logros (77/185): doc de logros faltantes + paso a Godot si es viable — 10 [C]
66. M74-Eventos (227/285): 58 pendientes documentales → eventos de calendario — 10 [C]

### Bloque H — Mundo y recursos (batch de mi fuerza)

67. M159-Catalogo (77/146): lote de procesamiento de masa (fichas de objetos, 10 por lote) — 10 [C]
68. M159 b2: cámara de progreso y checklist actualizado — 10 [C]
69. M155-Vestimenta (105/108): 3 pendientes — 4 [S]
70. M158-Desbloqueos (53/140): lote documental de zonas — 10 [C]
71. M163-Encantamientos (98/120): doc de 22 pendientes (stats/tablas) — 8 [C]
72. M33-Agricultura: doc técnica de los 47 pendientes (tabla de cultivos) — 8 [M]
73. M34-Pesca: doc técnica de los 54 (tabla de peces por bioma/hora) — 10 [C]
74. M35-Minería: doc de los 41 (tabla de picos/capas) — 8 [C]
75. M37-Museos (96/148): doc de los 52 (inventario de salas) — 10 [C]
76. M25-Ruinas (106/122): doc de los 16 — 6 [M]
77. M26-Templo-Sub (117/129): doc de los 12 — 6 [M]
78. M24-Templos (126/128): 2 pendientes — 3 [S]
79. M29-Tiempo (192/195): 3 pendientes — 3 [S]
80. M31-Ciclo (120/169): doc de los 49 (tabla de fases/luz/eventos) — 10 [C]
81. M32-Clima (119/121): 2 pendientes — 3 [S]
82. M30-Reloj (119/120): 1 pendiente — 2 [S]
83. M47-Texturas (118/121): 3 pendientes — 4 [S]
84. M50-Vegetación (129/142): doc de los 13 — 6 [M]
85. M51-Agua (140/166): doc de los 26 — 8 [M]
86. M52-Partículas (147/148): 1 pendiente — 2 [S]
87. M49-Iluminación (105/143): doc de los 38 (tabla de escenas/luz) — 10 [C]
88. M45-Arte-3D (150/171): doc de los 21 (hojas de ruta por asset) — 8 [M]

### Bloque I — Social/NPC apoyo documental (sin pisar a Hy3 en código)

89. M20-Amistad (50/148): doc de los 98 (tabla de niveles) — 10 [C]
90. M21-Dialogos (82/143): doc de los 61 (nodos/hilos) — 10 [C]
91. M162-Diálogos-NPC (81/120): doc de los 39 (matriz de contexto) — 10 [C]
92. M23-Historias (24/104): doc de los 80 (esqueleto de 5 historias) — 10 [C]
93. M147-World-Building (65/134): doc de los 69 — 10 [C]
94. M19/M36/M65 (✅): refrescos de doc — 6 [S]
95. M64-IA-NPC (102/119): doc de 17 pendientes — 6 [M]

### Bloque J — QA/AYUDA cruzados livianos y liquidación

96. M162-Medios-Transporte (0/106): arranque doc desde 168-plantilla — 10 [C]
97. M67-Vehiculos (19/131): doc técnico (física/controles) — 8 [C]
98. M61-Rendimiento (53/148): doc del plan de profiling — 10 [C]
99. M91-Config-Audio: revisión doc de los 27 restantes (soporte al ejecutor) — 6 [M]
100. M92-Tutorial×M94: doc de retención pedagógica — 6 [M]
101. M96-Plataformas (105/106): 1 pendiente — 2 [S]
102. M99-Marketing (155/169): 14 pendientes doc (metas/descripciones) — 8 [C]
103. M97-M98-M100 (✅): refresco doc trimestral — 6 [S]
104. M152-Principios (202/202): refresco doc — 4 [S]
105. M166/M167/M168 (✅): re-visión de doc de islas (un punto libre M167) — 4 [S]

---
**Total: 105 ítems.** Mantenimiento continuo (cron 5 min). Actualizado por GLM-5.3-Flash.

**Firma:** GLM-5.3-Flash / Kilo Code — 2026-10-16


---

# (B) ESTADO HISTÓRICO Y ENCAJE — registro del BACKLOG-MASTER anterior (preservado íntegro)

**Modelo:** glm-5.3-flash
**Plataforma:** Cline

# BACKLOG MASTER — glm-5.3-flash

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` (patrón `GLM-5.3 Flash`), ítems pendientes `[ ]`/`[?]` de los `05-Checklist.md`.

**Módulos asignados:** 22  |  **Tareas pendientes totales:** 2009

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Orden de trabajo (v2 — curado 2026-09-15, glm-5.3-flash / Cline)

> **Curación v2:** conteos re-verificados contra los `05-Checklist.md` reales (regex `^- \[ \]` / `^- \[\?\]`) tras la auditoría global que revirtió varios módulos y el regenerado de CHECKLIST-GLOBAL (`generar_checklist_global.py`, con backup). **Resueltos y cerrados por otros agentes:** 32-Clima (0/0, auditoría agnes 13/09), 38-Economia (0/0), 93-Balance (134/134), 145 (0/0), 146 (0/0), 65-Animales-IA (0/0). **149-Nombres:** reservado por otro agente (checklist regenerado) — fuera de mi cola. **Conflictos:** 66-Anti-Softlock (Log 701 declara 117/117 pero el checklist real tiene 117 `[ ]` post-reversión) → tareas en `[→]` pendiente de reconciliación. **31/34/64:** re-clasificados a `[?]` con dueño por otros — no accionables ahora.

| # | ID | Módulo | Pendientes reales (05-Checklist) | Notas | Subcarpeta |
|---|----|--------|----------------------------------|-------|------------|
| 1 | 92 | 92-Tutorial | 76 (75 ab + 1 ?) | Alta · iter.4 data-driven (Log 987, 97/185): guiones .tres + Q2/Q7 + R-block · falta UI M53 + RF11-RF18 + Q1/Q8 + S10-S12 | `92-Tutorial/checklist.md` |
| 2 | 39 | 39-Tiendas | 54 | Media · iter. glm cerrada (Log 1017): checklist 81→127 [x]; pendientes UI M53/ferias M73/QA | `39-Tiendas/checklist.md` |
| 3 | 158 | 158-Herramientas-Y-Desbloqueo-De-Zonas | 87 | 🟢 0→87 hecho por otro; núcleo a retomar | `158-Herramientas-Y-Desbloqueo-De-Zonas/checklist.md` |
| 4 | 19 | 19-NPC-Y-Vecinos | 83 | Alta · núcleo iter. 3 (Log 553) | `19-NPC-Y-Vecinos/checklist.md` |
| 5 | 25 | 25-Ruinas | 84 | Media · kit modular | `25-Ruinas/checklist.md` |
| 6 | 33 | 33-Agricultura | 86 | Media · núcleo + clima | `33-Agricultura/checklist.md` |
| 7 | 37 | 37-Museos-Y-Colecciones | 112 | 🟢 Media | `37-Museos-Y-Colecciones/checklist.md` |
| 8 | 28 | 28-Viajes | 80 | 🟢 Media · núcleo V0 (Log 371) | `28-Viajes/checklist.md` |
| 9 | 35 | 35-Mineria | 82 (69 ab + 13 ?) | Media · núcleo + QA | `35-Mineria/checklist.md` |
| 10 | 77 | 77-Online-Y-Red | 126 | 🟢 Media · sin núcleo aún | `77-Online-Y-Red/checklist.md` |
| 11 | 153 | 153-Objetivo-Final | ~130 (regenerado) | Alta · mis 10 tareas vuelven a estar abiertas | `153-Objetivo-Final/checklist.md` |
| — | 31 | 31-Ciclo-Dia-Noche | 54 `[?]` | no accionable ahora (dueños) | `31-Ciclo-Dia-Noche/checklist.md` |
| — | 34 | 34-Pesca | 69 `[?]` | no accionable ahora | `34-Pesca/checklist.md` |
| — | 64 | 64-IA-De-NPC | 49 `[?]` | no accionable ahora | `64-IA-De-NPC/checklist.md` |
| — | 66 | 66-Anti-Softlock | 7 `[?]` (87 `[x]`) | ✅ RECONCILIADO 2026-09-15 (Log 913): restauración verificada 110/117; los 7 `[ ]` restantes tienen dueño externo (M27/M64/M22/M26) | `66-Anti-Softlock/checklist.md` |

**Pendiente real accionable: ~860** (de 2.007 al inicio de la curación; baja 110 al reconciliar M66 y ~51 en la iter. 3 de M92). Resueltos/conflictos/no-accionables documentados arriba y en los checklists personales.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).

## Logs

- [x] Log creado: **1017** — M39 cierre iter GLM (atomicidad catalogo D8 + falso-verde loop economico)
- [x] Log reservado y creado: **1875** — Regla de numeración de mensajes: manda la secuencia del hilo (directiva del fundador 2026-10-15; GUIA-COMUNICACION.md + AGENTS.md §10.2). *(GLM-5.3-Flash / Kilo Code, canal `Mensajes entre modelos/GLM-5.3-Flash/`)*
- [x] Log reservado y creado: **1876** — Backlogs 100+ tareas por modelo activo (5 archivos en esta carpeta, 105 tareas cada uno) + Tareas A/B del director (M52 degradación validate_vfx + M11 notas refrescadas). *(GLM-5.3-Flash / Kilo Code, 2026-10-16)*
- [x] Log reservado y creado: **1877** — M91 cierre heredado de step-5-kilocode: 212→217/239 (+5 flips L201-L204/L210, sliders 7 buses + claves i18n es/en, tests 79/0 + 136/0 + 82/0, liberado 🟡 con deudas externas). *(GLM-5.3-Flash / Kilo Code, 2026-10-16)*
