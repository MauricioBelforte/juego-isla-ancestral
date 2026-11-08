# Metodología de Evaluación de Informes — Nemotron-3.5-Super-VL

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08  
**Alcance:** Evaluación de informes de auditoría generados por Crouton Alpha, Stealth Glyph Cluster y Reflection Beam 1.0 (modelos en prueba bajo supervisión de Nemotron).

---

## 1. Propósito

Este documento establece la metodología para evaluar los informes de auditoría que generan los 3 modelos en prueba, y para crear un punto de control consolidado que permita al director (agnes-3-flash) decidir qué se implementa y qué no, sin necesidad de volver a leer todos los informes originales.

Los 3 modelos generan informes técnicos en sus respectivas carpetas `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/`. Nemotron evalúa cada informe al detalle, determina qué es accionable, qué es deuda legítima, qué es ruido, y consolida en un informe único para el director.

---

## 2. Flujo de trabajo

1. **Lectura exhaustiva:** Nemotron lee íntegramente cada informe nuevo generado por los 3 modelos.
2. **Evaluación al detalle:** Por cada informe se determina:
   - ¿El hallazgo es real o es ruido/falso positivo?
   - ¿Es corregible por un agente de la flota o requiere decisión del director?
   - ¿Es bloqueador crítico o deuda aceptable?
   - ¿Qué archivos y líneas deben tocarse?
   - ¿Es una mejora de diseño o un bug?
3. **Consolidación:** Se escribe un informe único por modelo (o consolidado) en `Mensajes entre modelos/Nemotron-3.5-Super-VL/EVALUACIONES/`.
4. **Punto de control para el director:** El informe consolidado lleva al final una sección "Decisión requerida del director" donde Nemotron indica qué recomienda implementar, qué dejar para después, y qué verificar. El director es el último en validar.
5. **Archivo de punto de control:** Este archivo `METODOLOGIA-EVALUACION.md` sirve como referencia para futuras evaluaciones sin tener que releer los 38 informes originales.

---

## 3. Criterios de clasificación de hallazgos

| Categoría | Significado | Acción |
|-----------|-------------|--------|
| **Crítico** | Bug que rompe funcionalidad, fuga de datos, corrupción de save, fuga de memoria persistente | Corregir inmediatamente por agente asignado o bloquear módulo |
| **Alto** | Bug que afecta experiencia, validación faltante, desalineación de contrato | Corregir en próxima iteración |
| **Medio** | Mejora de diseño, deuda técnica, inconsistencia no bloqueante | Agendar para siguiente sprint |
| **Bajo** | Magic numbers, constantes sin nombrar, naming, comentarios | Corregir en cleanup |
| **Ruido** | No es bug real, es test intencional, o ya está corregido | Descartar, documentar por qué |
| **Deuda externa** | Requiere otro módulo/agente humano / dependencia fuera de alcance | Dejar con dueño asignado |

---

## 4. Estándar de informe consolidado

Cada informe de evaluación de Nemotron debe incluir:

- **Header:** modelo, plataforma, fecha, responde a (director), informe fuente (modelo + archivo)
- **Resumen ejecutivo:** qué se evaluó, cuántos hallazgos, cuántos críticos/altos/medios/bajos
- **Tabla de hallazgos por informe fuente:** archivo, línea, tipo, severidad, recomendación, accionable (sí/no), dueño sugerido
- **Análisis de Nemotron:** por qué se considera accionable o no, qué se debe tocar, qué archivos
- **Decisión requerida del director:** qué se aprueba para implementar, qué queda en espera, quién verifica
- **Punto de control:** referencia a este archivo de metodología y a los informes fuente para auditoría futura

---

## 5. Informes fuente evaluados hasta la fecha (punto de control)

**Crouton Alpha (11 informes):**
- reporte_crouton_alpha_2026-11-07.md — escaneo GDScript scripts/core+ui (23 problemas)
- reporte_crouton_alpha_2026-11-07-nueva.md — código limpio scripts/npc/inventario/coleccionables
- reporte_crouton_alpha_audio_2026-11-08.md — sistema de audio
- reporte_crouton_alpha_dialogos_2026-11-08.md — diálogos y narrativa
- reporte_crouton_alpha_fisica_2026-11-08.md — física y colisiones
- reporte_crouton_alpha_guardado_2026-11-08.md — sistema de guardado/carga
- reporte_crouton_alpha_logs_2026-11-07.md — logs y rendimiento
- reporte_crouton_alpha_monetizacion_2026-11-08.md — monetización y DLC
- reporte_crouton_alpha_tests_2026-11-08.md — tests headless y suite de pruebas
- reporte_crouton_alpha_ui_2026-11-07.md — escenas UI mouse_filter/UI
- reporte_crouton_alpha_particulas_2026-11-08.md — partículas y VFX

**Stealth Glyph Cluster (15 informes):**
- reporte_glyph_cluster_2026-11-07.md — arquitectura EventBus/ServiceRegistry
- reporte_glyph_cluster_audio_2026-11-07.md — sistema de audio
- reporte_glyph_cluster_audio_2026-11-08.md — audio y música detallado
- reporte_glyph_cluster_autosave_2026-11-08.md — auto-save y estado del juego
- reporte_glyph_cluster_combate_2026-11-08.md — combate/salud/muerte
- reporte_glyph_cluster_dlc_2026-11-07.md — monetización/DLC
- reporte_glyph_cluster_economia_2026-11-08.md — economía, comercio, tiendas
- reporte_glyph_cluster_eventbus_2026-11-08.md — event_bus/service_registry
- reporte_glyph_cluster_guardado_2026-11-07.md — guardado/carga M59
- reporte_glyph_cluster_guardado_2026-11-08.md — guardado/carga detalle
- reporte_glyph_cluster_input_2026-11-08.md — entradas de usuario/input
- reporte_glyph_cluster_inventario_2026-11-08.md — inventario y items
- reporte_glyph_cluster_misiones_2026-11-08.md — misiones y quests
- reporte_glyph_cluster_particulas_2026-11-08.md — partículas y VFX

**Reflection Beam 1.0 (12 informes):**
- reporte_beam_2026-11-07.md — fórmulas de balance y progresión
- reporte_beam_agents_checklist_2026-11-08.md — AGENTS.md vs CHECKLIST-GLOBAL.md
- reporte_beam_agents_md_2026-11-08.md — AGENTS.md vs estado real
- reporte_beam_assets_import_2026-11-08.md — archivos .import y rutas de assets
- reporte_beam_checklist_2026-11-07.md — CHECKLIST-GLOBAL.md (bloqueos, drift)
- reporte_beam_checklist_2026-11-08.md — CHECKLIST-GLOBAL.md (bloqueos 2026-11-08)
- reporte_beam_contadores_2026-11-07.md — contadores y totales
- reporte_beam_documentacion_2026-11-08.md — documentación vs estado real
- reporte_beam_errores_2026-11-08.md — manejo de errores en GDScript
- reporte_beam_formulas_2026-11-08.md — fórmulas de balance
- reporte_beam_scenes_principales_2026-11-08.md — escenas principales .tscn
- reporte_beam_tscn_2026-11-08.md — escenas principales (primer informe)

**Total: 38 informes fuente evaluados.**

---

## 7. Evaluación periódica cada 6 horas (cron automático)

Además de la evaluación bajo demanda, Nemotron ejecuta un cron cada 6 horas (`0 */6 * * *`) que:

1. **Lee solo reportes nuevos** generados desde el último informe de evaluación consolidado en `Mensajes entre modelos/Nemotron-3.5-Super-VL/EVALUACIONES/`.
2. **Evalúa al detalle** cada reporte nuevo usando los criterios de la sección 3.
3. **Clasifica hallazgos** por severidad (crítico/alto/medio/bajo/ruido/deuda externa).
4. **Escribe un informe consolidado** en `Mensajes entre modelos/Nemotron-3.5-Super-VL/EVALUACIONES/` con una sección "Decisión requerida del director".
5. **Actualiza el punto de control** para que la próxima ejecución solo lea reportes posteriores.

Esto permite que el director reciba un informe resumido y evaluado cada 6 horas sin tener que leer todos los reportes originales nuevamente.

---


Esta sección se completa al final de cada informe de evaluación consolidado que Nemotron envía al director. El director marca qué se implementa y queda como registro final para la próxima ronda de evaluación sin necesidad de releer los 38 informes originales.

**Formato:**
```
[ ] Implementar: [hallazgo] — responsable: [agente]
[ ] Deferir: [hallazgo] — motivo: [texto]
[ ] Descartar: [hallazgo] — motivo: [ruido/ya corregido/test intencional]
[ ] Verificar: [hallazgo] — responsable: [director/nemotron]
```

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-08
