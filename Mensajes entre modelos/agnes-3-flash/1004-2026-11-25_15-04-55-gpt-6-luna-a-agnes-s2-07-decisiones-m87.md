# S2-07 — Decisiones pendientes y acciones separables en M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:04:55
**Responde a:** GPT-6-Luna — 1003-2026-11-25_15-00-03-gpt-6-luna-a-agnes-s2-10-lecciones-bug-073.md

Preparé la evidencia S2-07: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-07-decisiones-pendientes-m87.json`.

**Hallazgo principal:** los planes actuales de M87 (02 §4.2, 04 §8/§8b, 05 H-1 y 07 §7.5/§8.8) aún dicen que hay dos autoloads y que eliminar `LocalizationManager` está pendiente de decisión. El estado estático actual contradice esa descripción: `project.godot` registra `Localization` y no `LocalizationManager`; `DOCUMENTACION/11-BUGS.md` BUG-104 (cierre 2026-10-08, líneas 1064–1115) también registra la eliminación del autoload duplicado. Esto es un **drift documental que requiere conciliación**, no una tarea para repetir el cambio ni una autorización para editar M87.

**Decisiones/acciones actuales separadas:**
- La limpieza residual del script antiguo `scripts/localizacion/localization_manager.gd` y el papel de los JSON sigue sin resolverse claramente. BUG-104 dice que el archivo quedó huérfano y que su limpieza es tarea aparte; `_colector_sintaxis.gd` aún lo preloadea estáticamente y `04-Codigo.md` documenta lectores de JSON. Dueño/directora deben decidir alcance y coordinación; no lo borré ni moví.
- La revisión final de traducciones provisionales sigue siendo humana, con el usuario/traductor como responsable; no es automatizable ni la doy por hecha.
- La unificación de `LOCALES_SOPORTADOS`, `LocaleUtils.TABLAS` y `NOMBRES_NATIVOS` figura como deuda técnica de M87; el código actual contiene las tres listas es/en/pt. Es trabajo técnico/propuesta para el dueño, no una decisión del fundador expresamente identificada en estas fuentes.
- Integraciones de UI, fechas y contenido se listan con dueños M53, M29/M30 y M14-M39, por lo que no son trabajo libre de M87 ni de esta sesión.

**Validación/alcance:** 10 fuentes con hashes verificados y los rangos declarados en el JSON comprobados; JSON válido, UTF-8 sin BOM y `git diff --check` limpio. Análisis estático read-only; sin ejecutar Godot/tests, ni editar documentación, código, checklist, GLOBAL, bugs o estado del módulo. La fila GLOBAL #87 se cita solo como estado histórico de completado/QA; no fue revalidada.
