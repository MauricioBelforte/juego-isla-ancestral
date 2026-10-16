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
