# 01 — Censos y clasificación (20 tareas)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Regla:** solo lectura por defecto. Verificar primero HEAD y los informes existentes; no repetir censos recientes ni escanear datos sensibles.

1. [x] C1-01 — Medir cantidad y tipos de archivos de una carpeta documental elegida por el director; informar método y conteos. Alcance disponible del agente: carpeta propia BACKLOGS; 9 archivos Markdown de trabajo, excluidas evidencias para evitar autoconteo. Evidencia: `evidencias/C1-01-censo-backlogs.json`. No se inspeccionó carpeta ajena.
2. [x] C1-02 — Clasificar una lista de pendientes existente por tipo (implementación, documentación, prueba, decisión externa), con referencias fuente. Evidencia: `evidencias/C1-02-clasificacion-cola-01.json` (20 tareas clasificadas; etiquetas no excluyentes y método declarado).
3. [x] C1-03 — Extraer encabezados y jerarquía de un documento largo a JSON sin parafrasear títulos. Evidencia: `evidencias/C1-03-encabezados-guia-08.json` (35 encabezados, jerarquía y líneas validadas).
4. [x] C1-04 — Crear índice JSON de enlaces Markdown rotos en una ruta acotada, excluyendo obsoletos según alcance autorizado. Alcance propio: nueve archivos Markdown raíz de BACKLOGS; 0 enlaces Markdown detectados y 0 rotos. Evidencia: `evidencias/C1-04-enlaces-markdown-backlogs.json`; detector regex limitado, no parser CommonMark completo.
5. [ ] C1-05 — Clasificar los `[?]` de un módulo asignado por responsable mencionado y evidencia textual; sin cambiar marcas.
6. [x] C1-06 — Extraer las marcas y etiquetas literales de una sección acotada del backlog, conservar el orden y producir conteos por etiqueta sin evaluar si cada estado está justificado. Evidencia actualizada: `evidencias/C1-06-estados-cola-01.json` (20 IDs; 8 pendientes, 12 completas, 0 sin resolver; marcas extraídas sin juzgar su validez).
7. [ ] C1-07 — Inventariar archivos de pruebas de un módulo y clasificar unitarios/integración/regresión por nombre y contenido.
8. [x] C1-08 — Clasificar entradas de un registro de bugs por severidad declarada, módulo y estado; no inferir severidad no declarada. Evidencia: `evidencias/C1-08-tablas-resumen-bugs.json`; 113 filas literales en 2 tablas oficiales, sin deduplicar ni inferir. Las narrativas restantes quedan fuera del alcance.
9. [ ] C1-09 — Extraer referencias a archivos desde una sección de `04-Codigo.md` y marcarlas como existentes/ausentes en disco.
10. [ ] C1-10 — Construir un JSON de módulos con dependencias declaradas de un conjunto asignado y verificar que cada ID exista.
11. [ ] C1-11 — Censar claves de traducción declaradas en dos catálogos escogidos, reportando solo diferencias de conjunto.
12. [x] C1-12 — Clasificar tareas de backlog por modalidad de verificación requerida: estática, headless, runtime, visual o decisión humana. Evidencia: `evidencias/C1-12-modalidad-verificacion-160-tareas.json`; 160 IDs únicos, etiquetas no excluyentes, clasificador léxico con límites declarados.
13. [ ] C1-13 — Extraer nombres de señales declaradas de un script seleccionado y entregar JSON con archivo y línea.
14. [x] C1-14 — Procesar un lote documental aprobado y resumir sus metadatos en una tabla estructurada por ruta, tipo, fecha disponible y estado explícito; omitir campos ausentes sin inferirlos. Lote propio autorizado: 8 archivos listados en `BACKLOG-MASTER.md`, tipo Markdown, 160 tareas; metadatos explícitos, hash SHA-256 y marcas literales. Evidencia: `evidencias/C1-14-metadatos-subbacklogs.json`; ninguna otra carpeta incluida.
15. [x] C1-15 — Clasificar secciones de una guía en norma, historial, ejemplo o propuesta con evidencia de encabezado/contexto. Evidencia: `evidencias/C1-15-clasificacion-secciones-agents.json`; 134 encabezados de `AGENTS.md`, método heurístico y evidencias por sección.
16. [x] C1-16 — Verificar citas `archivo:L#` de un informe asignado; reportar válidas, rango inexistente o ruta ausente sin corregir la fuente. Alcance: informe cross-doc propio; 14 referencias verificadas contra disco y línea citada. Evidencia: `evidencias/C1-16-auditoria-citas.json`; se verificó rango/título, no se certifica todo el soporte semántico.
17. [ ] C1-17 — Preparar JSON de inventario de autoloads desde `project.godot` y comparar contra otra lista documental indicada.
18. [x] C1-18 — Agrupar duplicados exactos de nombres/IDs en un dataset acotado; incluir huellas o claves que permitan reproducir el conteo. Evidencia: `evidencias/C1-18-ids-duplicados.json`; 160 IDs, 160 únicos, 0 duplicados.
19. [x] C1-19 — Separar evidencia directa de inferencias en un informe técnico seleccionado, entregando tabla/JSON con justificación. Revisión de 8 afirmaciones cross-doc: clasifica requisitos documentados vs inferencia operativa, cita extractos literales y señala límites; no valida todo AGENTS.md. Evidencia: `evidencias/C1-19-separacion-hechos-inferencias.json`.
20. [ ] C1-20 — Medir tiempo/tamaño/errores de una tarea de clasificación pequeña con dos tamaños de lote; registrar calidad y truncamientos.

## Evidencia para cerrar una tarea

- Fuente exacta y alcance consultado.
- Script/consulta o método reproducible, cuando aplique.
- Conteos o salidas revisados contra el artefacto original.
- Estado `[x]` solo si el resultado se generó y validó; si ya existía, dejar nota de duplicación y no reclamar trabajo nuevo.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
