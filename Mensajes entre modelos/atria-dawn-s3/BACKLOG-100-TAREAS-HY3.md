# BACKLOG 100 TAREAS PARA HY3 — Investigación para mañana

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 15:42:00
**Origen:** orden del fundador (15:37): *"planea de antemano 100 tareas para cada modelo ... ling y
kimi no"* (relegados). Hy3 vuelve mañana (fuera desde las 04:24).

## Perfil de HY3 (§21.21)

**Patrón D honesto — no promueve sin evidencia**. Autor del barrido BUG-070 (lotes 1-8) que detectó
inflación en 6 de 7 módulos auditados. Su nicho: **QA cruzado §21.8 con muestreo anti-inflación
§21.8.2.b** y auditoría de deuda `[?]`. Los **sellos los pone el director**; Hy3 audita y propone.

## ⚠️ HALLAZGO CRÍTICO DE ESTA SESIÓN (15:38)

**76 módulos figuran ✅ en CHECKLIST-GLOBAL y solo 1 tiene sello §21.8** (M126, y fue DENEGADO).
Hay ~75 módulos ✅ **sin verificación cruzada** — el backlog de QA de Hy3 es el más grande de la
flota. Además, **drift real detectado** (GLOBAL dice ✅ pero el disco tiene deuda):

| Módulo | GLOBAL dice | Disco real (escaneo 15:38) | Acción |
|--------|------------|---------------------------|--------|
| M45-Arte-3D | ✅ 2026-10-13 04:05 | 19 `[ ]` + 2 `[?]` | ✅ **FLIPEADO por el director 16:52** — drift real |
| M105-Telemetria | ✅ 2026-10-13 04:05 | 33 `[?]` | ❌ **FALSO POSITIVO mío** — ya era 🟡, deuda justificada (s2 Log 1502) |
| M117-Build-System | ✅ 2026-09-17 | 18 `[?]` | ❌ **FALSO POSITIVO mío** — ya era 🟡, deuda justificada (hy3 Log 947) |

⚠️ **CORRECCIÓN 17:04 (director msg 258):** M105 y M117 NO eran drift inflacionario. Ya figuraban
🟡 en GLOBAL con `[?]` auditados y con dueño nombrado. **M45 sí era drift real y ya se flipó.**
Lección anotada: antes de reportar "✅ con deuda real", verificar el estado ACTUAL de la columna en
GLOBAL. Un `[?]` con dueño es deuda legítima, no fraude (BUG-070 es `[x]` sin respaldo).

## LAS 100 TAREAS

### Prioridad 1: drift ✅→🟡 (tareas 1-5)

1. ~~M45-Arte-3D — auditar 19 `[ ]` + 2 `[?]`, proponer ✅→🟡 con cita (drift)~~ — **CERRADO:
   el director lo flipeó a las 16:52 (mi diagnóstico fue exacto).** Hy3 no necesita auditarlo.
2. ~~M105-Telemetria — auditar 33 `[?]`, proponer ✅→🟡~~ — **FALSO POSITIVO: ya era 🟡 con deuda
   justificada (s2 Log 1502).** Anulado.
3. ~~M117-Build-System — auditar 18 `[?]`, proponer ✅→🟡~~ — **FALSO POSITIVO: ya era 🟡 con deuda
   justificada (hy3 Log 947).** Anulado.
4. **M126-Marketing-Legal** — re-verificar el archivo `marketing_legal_review.md` que degradó el
   sello (L90 afirmaba existencia; `legal/` y `docs/legal/` no existen) — crear o confirmar
   ausencia. ⚠️ El director indicó que esta QA va a **s2** (independencia §21.8: M126 es tuyo).
5. **M167-Isla-Raiz** — QA §21.8 fresca pendiente (P-39 cerrado por mí, 113/114, 1 `[ ]`
   shore-fade KnownIssue M49/M51). Verificar 0 hardcodes de centro viejo con grep. (El director
   indicó que también va a s2.)

### Prioridad 2: QA cruzado §21.8 módulos ✅ sin sello (tareas 6-75)

Muestreo §21.8.2.b: 5 `[x]` por módulo elegidos por verbos de creación, verificación contra disco
(`glob`/`grep`/`Test-Path`). 0-1 fallas → sello válido; 2+ → DENEGAR y volver a 🟡.

6. QA M04-Game-Engine (hoy 04:45, WorkBuddy iter 4) — 10. QA M05-Lenguaje-Y-Programacion
11. QA M06-Control-De-Versiones — 12. QA M07-Arquitectura-General
13. QA M08-Mundo-Voxel — 14. QA M09-Terreno-Y-Geografia
15. QA M10-Generacion-Del-Mundo — 16. QA M62-Memoria
17. QA M101-QA-General — 18. QA M102-Bug-Tracking
19. QA M103-Logging — 20. QA M106-Seguridad
21. QA M110-Debug-Menu (hoy 07:30) — 22. QA M111-Codigo-De-Calidad
23. QA M113-Pruebas-De-Stress — 24. QA M116-Instalador
25. QA M118-CI-CD — 26. QA M119-Actualizaciones
27. QA M120-DLC-Y-Expansiones — 28. QA M121-Soporte-Post-Lanzamiento
29. QA M122-Crash-Reporting — 30. QA M123-Modding
31. QA M124-Contenido-Generado-Por-Usuarios — 32. QA M125-Terminos-De-Servicio
33. QA M128-Identidad-De-Marca — 34. QA M130-Artbook
35. QA M132-Produccion-De-Equipo — 36. QA M133-Gestion-Del-Proyecto
37. QA M134-Presupuesto — 38. QA M135-Riesgos-Del-Proyecto
39. QA M136-Roadmap — 40. QA M14-Inventario
41. QA M15-Recursos (hoy 07:30, agnes) — 42. QA M152-Principios-Innegociables
43. QA M165-Voxel-Tools-Guia — 44. QA M166-Variantes-Y-Perfil-De-Rendimiento
45. QA M167-Isla-Raiz (b2, shore-fade KnownIssue) — 46. QA M168-Plantilla-De-Isla
47. QA M24-Templos-Y-Puzzles — 48. QA M29-Tiempo-Y-Calendario (hoy 03:13)
49. QA M30-Reloj-En-Tiempo-Real — 50. QA M32-Clima
51. QA M34-Pesca (hoy 03:13) — 52. QA M36-Fauna
53. QA M38-Economia (hoy) — 54. QA M39-Tiendas (hoy 03:30)
55. QA M43-Efectos-De-Sonido — 56. QA M44-ASMR-Y-Feedback
57. QA M54-Mapa — 58. QA M56-Fotografia
59. QA M59-Guardado — 60. QA M60-Datos-Y-Serializacion
61. QA M63-Cargas-Y-Streaming — 62. QA M64-IA-De-NPC
63. QA M65-Animales-IA — 64. QA M70-Interacciones
65. QA M78-Legal-Propiedad-Intelectual — 66. QA M79-Legal-Contratos
67. QA M80-Legal-Privacidad — 68. QA M81-Legal-Menores
69. QA M82-Clasificacion-Por-Edades — 70. QA M84-Musica-Y-Audio-Legal (hoy)
71. QA M85-Modelos-3D-Legal — 72. QA M86-IA-Generativa
73. QA M88-Fuentes-Tipograficas — 74. QA M89-Diseno-De-Menus
75. QA M91-Configuracion-De-Audio, M93-Balance, M97-Steam, M98-Trailer, M99-Marketing (lote final 5)

### Prioridad 3: auditoría de deuda `[?]` [C-WB] (tareas 76-100)

Módulos en cola de WorkBuddy con deuda `[?]` — Hy3 audita si hay evidencia para promover (o
confirmar la deuda). **No pisar trabajo de WB**: auditar en solo lectura.

76. M159-Catalogo-De-Objetos (52 `[?]`) b1 — 13
77. M159-Catalogo b2 — 13
78. M159-Catalogo b3 — 13
79. M159-Catalogo b4 — 13
80. M63-Cargas-Y-Streaming (27 `[?]`) b1 — 9
81. M63-Cargas b2 — 9
82. M63-Cargas b3 — 9
83. M112-Testing-Automatico (12 `[?]`) — 12
84. M163-Sistema-De-Encantamientos (15 `[?]`) — 15
85. M35-Mineria (28 `[ ]` + 13 `[?]`) b1 — 7
86. M35-Mineria b2 — 7
87. M16-Crafting (36 `[ ]` + 13 `[?]`) b1 — 7
88. M16-Crafting b2 — 7
89. M26-Templo-Subterraneo (18 `[ ]` + 10 `[?]`) b1 — 7
90. M26-Templo b2 — 7
91. M61-Rendimiento (89 `[ ]` + 6 `[?]`) b1 — 5
92. M151-Control-Final (67 `[ ]` + 6 `[?]`) b1 — 5
93. M104-Analytics (8 `[?]`) — 8
94. M66-Anti-Softlock (5 `[?]`) — 5
95. M154-Vision-Del-Agente (3 `[?]`) — 3
96. M160-Diseno-De-Ubicaciones (7 `[?]`) — 7
97. M146-Diseno-Emocional (9 `[?]`) — 9
98. M03-Documentacion-Del-Proyecto (7 `[?]`) — 7
99. M02-Vision-Y-Concepto (1 `[?]` final) — 1
100. Barrido anti-inflación final: re-conteo regex global de TODOS los ✅ vs discos + reporte
     único con drift total del proyecto (entrega al director como insumo del sello)

## Reglas para Hy3

1. **NUNCA promover `[?]`→`[x]` sin evidencia en disco** (Patrón D — su código de honor).
2. **Independencia §21.8:** no auditar módulos que él mismo completó. Si encuentra uno propio en la
   lista (M126), delegar a s2 o avisar al director.
3. **Denunciar drift sin miedo:** los ✅ inflados dañan al proyecto más que los `[?]` sin resolver.
4. Reportar con evidencia: comando ejecutado + salida literal + antes/después.
5. Los **sellos los pone el director**; Hy3 propone con veredicto fundamentado.

## Entrega al director

10 mensajes de 10. Msg 1: drift urgente (tareas 1-5) + primeros QA. Msg 2-8: QA cruzado en lotes
de 10. Msg 9-10: auditoría de deuda + barrido final. **El drift de M45/M105/M117 es lo primero que
debe ver el director mañana** — el conteo global está inflado y toda la flota trabaja con datos
falsos.

**Firma:** atria-dawn-s3 (Atria-Dawn-Preview / Kilo Code) — 2026-10-13 15:42:00
