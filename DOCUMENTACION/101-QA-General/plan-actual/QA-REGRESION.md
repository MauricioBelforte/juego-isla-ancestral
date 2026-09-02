**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-REGRESION.md — Guía de Regresión (Módulo 101)

> **Propósito:** el mayor riesgo del proyecto (140+ módulos con dependencias cruzadas) es la **regresión silenciosa**: un cambio en M14 rompe M15/M16/M17/M38 sin que nadie lo note. Estas reglas garantizan que cada cambio se verifica contra lo que puede haber tocado.

## 1. Cuándo correr qué

| Frecuencia | Alcance | Quién | Tiempo objetivo |
|---|---|---|---|
| **Post-cambio** (cada tarea de agente) | Área del módulo modificado + checklists de los **dependientes** (columna "Dependencias" de CHECKLIST-GLOBAL) | Agente que modificó | 30-60 min |
| **Post-build** (cada build de QA) | Smoke (QA-SMOKE.md) + áreas del cambio desde la última build | QA interno | 15 min + 30 min |
| **Post-hito** (M137-M141) | **TODAS** las áreas del QA-CHECKLIST (+ flujos estables §16 AGENTS.md) | QA + agente | 1-2 sesiones |
| **QA cruzado** (§21.8 AGENTS.md) | DoD del módulo verificado por otro modelo | Modelo verificador | Según módulo |

## 2. Reglas de dependencias

1. Al modificar el módulo X de la columna Dependencias de `CHECKLIST-GLOBAL.md`, se modifican módulos que **dependen** de X.
2. Correr el checklist del área X **más** el área de cada módulo dependiente (tabla de áreas en QA-CHECKLIST.md).
3. Los **flujos estables** (§16 AGENTS.md) se re-corren en cada regresión de hito: nunca se editan sin QA posterior.

## 3. Reglas de conversión a M112 (RF10)

1. Todo bug de regresión **reproducible** → issue M102 con etiqueta `regresion`.
2. En ese mismo issue se agrega la orden de **convertir a test automático** (dueño M112): "este caso debe pasar a `res://tests/...`".
3. Si el bug no es reproducible → marcador `NO REPRODUCIDO` en el issue + reintento en la siguiente sesión (QA-CHECKLIST EB.01).
4. La suite M112 debe correr **antes de cada sesión de hito** (gate del punto 4 del DoD).

## 4. Presupuesto y prioridad

1. La regresión **nunca se saltea por tiempo**; se prioriza sobre features nuevas (una feature nueva sin regresión no se integra).
2. Un bug de regresión solo duplica el tiempo de sesión si es reproducible y bloqueante.
3. La tasa de regresión (bugs de regresión / total de bugs) se reporta por hito a M133 (RF11).

## 5. Registro

- Cada regresión corre con la plantilla QA-SESSION.md (rebrote: "regresión post-cambio de MXX").
- Los ítems re-corridos se listan en la columna "Resultado" con nota `[regresión]`.

## 6. Guía rápida para agentes

```
¿Modifiqué Módulo X?
  → 1. Verificación post-tarea (§12 AGENTS.md): compila, sin excepciones, prueba funcional
  → 2. Log M103 vacío de errores de mi cambio
  → 3. Checklist del área X en QA-CHECKLIST.md (solo los ítems que tocan mi cambio)
  → 4. Checklist de cada módulo que DEPENDE de X (CHECKLIST-GLOBAL col. Dependencias)
  → 5. ¿Bug? → issue M102 (etiqueta regresion + orden de conversión M112 si reproducible)
  → 6. Registro en sesión QA-SESSION.md + log de la tarea en Logs/ + CHECKLIST-GLOBAL
```
