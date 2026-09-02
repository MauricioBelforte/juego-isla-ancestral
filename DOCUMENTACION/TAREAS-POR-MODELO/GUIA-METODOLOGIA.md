**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

# GUÍA DE METODOLOGÍA — TAREAS POR MODELO

> **Propósito:** la CHECKLIST-GLOBAL.md es el tablero de RESUMEN (1 fila por módulo, ~18.000 subítems que no caben en él). Esta carpeta aloja las **checklists personales de tareas granulares de cada modelo**, alimentadas directamente de los `05-Checklist.md` de cada módulo.

## Estructura

```
DOCUMENTACION/TAREAS-POR-MODELO/
├── GUIA-METODOLOGIA.md            ← este archivo
├── <MODELO>/                      ← una carpeta por modelo (nombre exacto de la identidad)
│   ├── BACKLOG-MASTER.md          ← índice de tareas del modelo (resumen por módulo + conteos)
│   └── <ID-Modulo>-<Nombre>/      ← una subcarpeta por MÓDULO asignado
│       └── checklist.md           ← tareas granulares pendientes de ESE módulo
```

## Reglas

1. **Cada modelo con su carpeta** (nombre de identidad: ej. `deepseek-v4-flash-vision-exp`). No se tocan carpetas de otros modelos.
2. **1 tarea = 1 ítem verificable.** Las tareas se extraen de los `[ ]` y `[?]` del `05-Checklist.md` del módulo (fuente de verdad) y se copian a `checklist.md` del modelo con un ID propio `T-XXX` (secuencial por módulo).
3. **Marcado:**
   - `[ ] T-### …` → pendiente
   - `[x] T-### …` → completado (con evidencia: log + test + nota)
   - `[?] T-### …` → no resuelto (con razón y dueño)
   - `[→] T-### …` → movida a otro modelo (con nota de quién)
4. **Fuente:** al terminar T-###, actualizar TAMBIÉN el `05-Checklist.md` del módulo (el ítem marcado) y la fila de CHECKLIST-GLOBAL (progreso). Los tres lugares deben estar sincronizados.
5. **Priorización:** el BACKLOG-MASTER.md ordena por (a) módulo con núcleo existente (verificación rápida), (b) dependencia resuelta, (c) prioridad del módulo (Alta/Media/Baja).
6. **Ciclo:** el modelo toma la siguiente tarea de su master en orden → reserva log → implementa/verifica → test headless 0 fallos → documenta (05-Checklist + CHECKLIST-GLOBAL) → libera → sigue. Sin preguntar: la decisión más conservadora + nota `[?]`.
7. **Escala: mínimo 100 tareas.** Todo modelo que se une a la metodología DEBE asignarse en su backlog **no menos de 100 tareas** (las tareas se toman de los módulos con su Recom en CHECKLIST-GLOBAL; los pendientes de cada módulo van de decenas a cientos de subítems). Las checklists personales reemplazan el trabajo "por ítem" que la tabla global no puede representar. **No hay límite superior**: 2000+ tareas es válido (las subcarpetas por módulo lo soportan). Aquí tienes ejemplos reales: `deepseek-v4-flash-vision-exp` arrancó con 3.474 tareas en 30 módulos.

## Cómo usa otro modelo esta metodología (pasos)

1. Crear su carpeta `<MODELO>/` con la identidad real (modelo + plataforma).
2. Ejecutar/adaptar el extractor (patrón: `scripts-reutilizables/generar_tareas_modelo.py` o el script equivalente) sobre los módulos donde la columna **Recom** de CHECKLIST-GLOBAL lo nombre.
3. Generar `BACKLOG-MASTER.md` + subcarpetas `checklist.md` por módulo. **Verificar que el total de tareas asignadas sea ≥ 100**; si es menor, ampliar a más módulos con su Recom (o a los disponibles del proyecto).
4. Trabajar en bucle con el protocolo estándar (AGENTS.md §6/§21).

**Creadores:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 (primero en usar la metodología, con 37 módulos asignados).
