**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11

# GUÍA DE METODOLOGÍA — TAREAS POR MODELO

> **Propósito:** la CHECKLIST-GLOBAL.md es el tablero de RESUMEN (1 fila por módulo, ~18.000 subítems que no caben en él). Esta carpeta aloja las **checklists personales de tareas granulares de cada modelo**, alimentadas directamente de los `05-Checklist.md` de cada módulo.

> ⚠️ **IMPORTANTE:** Cada modelo DEBE trabajar desde su **backlog personal** (`BACKLOG-MASTER.md`). La CHECKLIST-GLOBAL es solo un tablero de resumen para el usuario — **NO** es la fuente de trabajo del agente. Ver `AGENTS.md` §29 para el flujo completo.

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver `AGENTS.md` seccion 28 para detalles.

### Flujo de trabajo obligatorio

1. **Leer tu backlog personal** → `TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md`
2. **Buscar tareas pendientes** en los `plan-actual/` de los módulos que te corresponden
3. **Elegir una tarea** de tu backlog que puedas hacer ahora
4. **Bloquearla** → marcar `[→]` en tu checklist personal
5. **Ejecutar** la tarea
6. **Completarla** → marcar `[x]` en los 3 lugares:
   - Tu checklist personal (`TAREAS-POR-MODELO/<MODELO>/...`)
   - El `05-Checklist.md` del módulo
   - La fila de CHECKLIST-GLOBAL (progreso)

**NO ir directo a la CHECKLIST-GLOBAL a buscar trabajo.** Tu backlog es tu fuente de verdad.

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

## Modelos registrados

| Modelo | Plataforma | Fecha registro | Módulos | Tareas |
|--------|------------|----------------|---------|--------|
| DeepSeek-V4.1-Flash | WorkBuddy | 2026-09-11 | 27 | 3.998 ítems · 2.192 pendientes (1.563 libres + 629 de otros agentes) — **BACKLOG v2 curado por encaje** |
| deepseek-v4-flash-vision-exp | Kilo Code | 2026-09-02 | 37 | 3.474 |
| MiMo V2.5 | OpenCode | 2026-09-02 | 8 | 312 |
| glm-5.3-flash | Kilo Code | 2026-09-02 | 22+ | ~330 |
| glm-5.3 | Kilo Code | 2026-09-10 | 20 | 1.245 |
