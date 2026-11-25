# 04 — Auditoría documental y código estático (20 tareas)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Modo:** lectura y reporte; cualquier edición necesita encargo. Revalidar vigencia y lock antes de elegir cada tarea.

1. [ ] A4-01 — Comparar un `04-Codigo.md` con el árbol de archivos del módulo y clasificar cada ruta citada: existe, ausente, ambigua, histórica.
2. [ ] A4-02 — Comparar afirmaciones de un `03-Diseno.md` con funciones/clases citadas, verificando nombres y firmas exactas en disco.
3. [ ] A4-03 — Revisar un checklist asignado: conteo real `[x]/[ ]/[?]`, Totales y discrepancias; no corregir ni flipar marcas.
4. [ ] A4-04 — Validar una muestra de citas `archivo:L#` en un informe anterior contra contenido vigente y contexto semántico.
5. [ ] A4-05 — Auditar enlaces Markdown internos de un subárbol y distinguir ruta inexistente, anchor inválido y archivo obsoleto.
6. [ ] A4-06 — Extraer IDs de módulos mencionados en una guía y cruzarlos con títulos/IDs reales del GLOBAL, reportando alias históricos aparte.
7. [ ] A4-07 — Revisar si un plan llama “implementado” a un artefacto que en realidad aparece como propuesta, mock o plantilla.
8. [ ] A4-08 — Comprobar que pruebas citadas en cierres existan en `HEAD` y que sus aserciones cubran el comportamiento afirmado.
9. [ ] A4-09 — Contrastar funciones documentadas con declaraciones reales en un módulo sin lock de otro agente.
10. [ ] A4-10 — Buscar referencias a APIs Godot inexistentes o nombres de métodos sin definición en un alcance aprobado; registrar evidencia, no editar.
11. [x] A4-11 — Revisar encabezados, tabla de contenidos y estructura de un documento largo contra sus secciones reales. En `BACKLOG-MASTER.md`: extraje 7 secciones numeradas y 8 filas del índice de archivos; verifiqué existencia y conteos declarados (20 tareas por archivo). Hallazgo: esa tabla enumera sub-backlogs, no es una TOC de secciones del documento. Evidencia: `evidencias/A4-11-revision-indice-master.json`; 7 encabezados listados, 8 destinos válidos.
12. [ ] A4-12 — Detectar contradicciones de estado dentro del mismo documento: pendiente vs cerrado, “no aplica” vs artefacto listado, test propuesto vs ejecutado.
13. [ ] A4-13 — Comparar `01-Requerimientos.md` y `03-Diseno.md` de un módulo seleccionado y mapear requisitos sin diseño asociado.
14. [ ] A4-14 — Comparar `03-Diseno.md` con `04-Codigo.md` y clasificar diferencias como implementación, deferral, contradicción o alcance externo.
15. [ ] A4-15 — Auditar referencias cruzadas a capturas: verificar que cada ruta exista y que el nombre corresponda al módulo citado.
16. [x] A4-16 — Revisar una muestra de firmas del canal/backlog: modelo, plataforma y fecha coincidentes con la identidad del archivo. Verificación exacta de 8/8 sub-backlogs: `GPT-6-Luna`, `DeepAI Code`, `2026-11-25`. Evidencia: `evidencias/A4-11-A4-16-estructura-firmas.json`.
17. [ ] A4-17 — Comparar el texto de `3-DOCUMENTO-TAREAS-ACTUAL.md` con la tabla GLOBAL para detectar resúmenes stale; no editar fuente central.
18. [ ] A4-18 — Ejecutar lectura de un script de validación seleccionado y resumir inputs, outputs, exclusiones y posibles falsos positivos con líneas.
19. [ ] A4-19 — Revisar claims negativos (“no hay uso”, “no existe consumidor”) verificando scope, variantes de nombres y rutas excluidas.
20. [ ] A4-20 — Revisar un informe propio con checklist anti-alucinación: afirmación→evidencia, citas, límites, tareas no ejecutadas y decisión del dueño.

## Cierre verificable

El reporte incluye alcance consultado, conteos, rutas y citas. Las propuestas de corrección quedan separadas del estado actual. No usar la auditoría para adjudicar cierres, alterar el GLOBAL, cambiar marcas ni modificar archivos protegidos.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
