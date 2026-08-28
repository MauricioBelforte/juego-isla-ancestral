**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 135-Riesgos-Del-Proyecto
**Estado:** Implementación operativa (entregable M135)

---

# Guía de Revisión Trimestral — Módulo 135

> Procedimiento paso a paso para la revisión periódica del registro de riesgos (decisiones D3/D4 de `02-Analisis.md`). Duración objetivo: **< 1 hora**. Anclada al ciclo de gestión de M133 (revisión de estado mensual; la trimestral puede coincidir con el cierre de un trimestre natural o de un hito).

## 1. Cuándo

- **Frecuencia:** trimestral (obligatoria; RN9). Fecha objetivo por defecto: `28/11/2026`, `28/02/2027`, `28/05/2027`, `28/08/2027`… (ajustable por el fundador).
- **Adelantada si:** se materializa un riesgo, aparece un riesgo ≥ 17 (zona roja), o un hito importante se cierra (M137/M138 recalibran riesgos TEC).
- **Si se omite:** registrar motivo en el registro de revisiones y reprogramar en ≤ 30 días (paso 9 del procedimiento).

## 2. Participantes

- **Fundador** (decide prioridades, especialmente R-10/salud y criterios de aceptación de nivel).
- **Un agente de IA como asistente** (prepara datos, redacta cambios, firma el documento).

## 3. Procedimiento (10 pasos)

1. **Abrir** `RISK-REGISTER.md` y `CHECKLIST-GLOBAL.md` (estado real de módulos).
2. **Recalcular** P, I y nivel de cada entrada activa contra evidencia real del trimestre (logs, checklists, hallazgos de `Mensajes entre modelos/`).
3. **Verificar avance** de mitigaciones en curso; marcar las vencidas o sin avance.
4. **Registrar riesgos nuevos** surgidos del trimestre (bugs M102 repetidos/severos, hallazgos de testing, cambios de M136/M152).
5. **Cerrar riesgos superados** con motivo y lección aprendida (el historial es append-only).
6. **Aplicar escalamiento:** nivel ≥ 17 o mitigación naranja sin avance → plan de contingencia escrito antes de cerrar la revisión.
7. **Actualizar** la matriz 5×5 y el resumen de zonas.
8. **Anotar fecha** en `Registro de revisiones`, firmar con modelo/plataforma y commitear (protocolo §4 de AGENTS.md, push solo si el fundador lo pide).
9. **Si se omite** la revisión: registrar motivo y reprogramar en ≤ 30 días.
10. **Reportar** a M133/M136 todo riesgo que amenace hitos (acta o reporte del mes).

## 4. Checklist de la sesión (copiar al acta)

- [ ] Todos los riesgos activos recalculados (P, I, nivel).
- [ ] Mitigaciones verificadas (avance/atraso).
- [ ] Riesgos nuevos del trimestre agregados con ID consecutivo.
- [ ] Riesgos cerrados con lección aprendida.
- [ ] Zona roja: 0 riesgos **o** con plan de contingencia escrito.
- [ ] Matriz y resumen actualizados.
- [ ] Registro de revisiones actualizado y documento firmado.
- [ ] Reporte a M133/M136 (si corresponde).

## 5. Después de la revisión

- El `05-Checklist.md` de este módulo no cambia por revisar (es el checklist de implementación); lo que evoluciona es `RISK-REGISTER.md`.
- Si la revisión cambia reglas del módulo (escala, umbrales, zonas): ADR en M133 + nota aquí.
- La primera revisión trimestral **formal** requiere la participación del fundador (pendiente; la revisión en papel del 2026-08-28 no la sustituye).

**Firma del último agente que modificó esta guía:**

**Modelo:** GLM
**Plataforma:** Kilo
