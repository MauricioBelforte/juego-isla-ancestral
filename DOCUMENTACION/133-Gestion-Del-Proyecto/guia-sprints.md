**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Implementación operativa (entregable M133)

---

# Guía de Bloques de Trabajo (iteraciones) — Módulo 133

> El proyecto usa **Kanban liviano + hitos** (decisión D1/D3 de `plan-actual/02-Analisis.md`): no hay sprints de duración fija con ceremonias pesadas. En su lugar hay **bloques de trabajo semanales** que alimentan el hito activo (RF6). Duración recomendada: **1 semana**; si el fundador prefiere otra cadencia, se ajusta por ADR.

---

## 1. El bloque de trabajo (unidad de ritmo)

| Aspecto | Definición |
|---|---|
| Duración | 1 semana (ajustable por ADR) |
| Objetivo | Un subconjunto de tareas del hito activo, terminadas (no "empezadas") |
| Capacidad | Definida al inicio del bloque: cuántas tareas se comprometen según tiempo real disponible (anti-sobrecompromiso, RN4) |
| WIP máximo | **2 módulos/tareas en curso simultáneos** por persona; **1 módulo** por agente IA (regla 21.4.1) |
| Cierre | Revisión de estado semanal (15 min): ejecutar `verificar_checklist.py`, mover tarjetas, atender colgados y 🟡 |

---

## 2. Ciclo del bloque (lunes a viernes sugerido)

1. **Apertura (10 min):** elegir tareas del hito activo; declarar capacidad; anotar el objetivo del bloque en una línea (ej: "cerrar F3 con M13").
2. **Durante la semana:** ciclo de módulo del protocolo §21 (escanear → reclamar 🔵 → trabajar → marcar → liberar). Las tareas se mueven en el tablero al mismo ritmo que `CHECKLIST-GLOBAL.md` (espejo, no fuente de verdad).
3. **Cierre (15 min, revisión de estado):**
   - `python scripts/verificar_checklist.py` → 0 inconsistencias nuevas.
   - Módulos 🔵 propios avanzados esta semana: actualizar `Última actividad`.
   - Colgados >24 h ajenos: señalizados (no reclamados antes de las 24 h).
   - Si algo no se terminó: se replanifica explícitamente (no se arrastra en silencio).
4. **Fin de hito:** prueba de juego del fundador + retrospectiva (ver `guia-hitos.md` §6).

---

## 3. Reglas del bloque

1. **Terminar > empezar:** una tarea del bloque cuenta como hecha solo si cumple la DoD (5 criterios). Nada de "90 % terminado" semanal recurrente.
2. **Lo interrumpible queda anotado:** si el fundador cambia prioridades a mitad de bloque (RF8), la tarea pausada se registra con su estado real en el checklist del módulo antes de cambiar de contexto.
3. **Un objetivo por bloque:** si el objetivo del bloque no se cumple 2 bloques seguidos, es señal de sobre-alcance → recortar alcance o revisar dependencias (señal temprana del plan anti-abandono).
4. **Ceremonias mínimas:** apertura y cierre viven dentro del tiempo de desarrollo; prohibido agregar ceremonias sin ADR.
5. **Registro liviano:** el bloque no genera documentación propia; deja evidencia en los checklists, la tabla global y (si corresponde) el acta de la ceremonia que toque.

---

## 4. Relación con el tablero y los hitos

- Las tarjetas del tablero representan **módulos** (no tareas chicas); los campos `Prioridad`, `Complejidad`, `Dependencias`, `Agente actual` e `Hito` vienen de la fila de la tabla global.
- El bloque mueve tarjetas entre columnas `🟢 → 🔵 → 🟡/✅` a medida que los agentes reservan y liberan.
- El hito activo siempre tiene el bloque enfocado en sus tareas; los módulos fuera de hito (documentación V0, QA cruzado) pueden llenar capacidad ociosa, sin robar WIP al hito.

---

## 5. Métricas livianas del bloque (opcionales, ≤ 5 min por semana)

| Métrica | Cómo se mide | Señal de alerta |
|---|---|---|
| Módulos liberados en el bloque | Filas actualizadas a 🟡/✅ | 2 bloques seguidos con 0 liberaciones |
| Colgados acumulados | Salida de `verificar_checklist.py` | > 5 módulos 🔵 sin actividad >24 h |
| Deuda técnica nueva | `[?]` y notas nuevas en checklists | Crece 2 bloques seguidos sin plan de pago |
| Energía (subjetiva, fundador) | Pregunta de la retrospectiva | 2 semanas seguidas de "me la quitó" |

**Firma del último agente que modificó esta guía:**

**Modelo:** GLM
**Plataforma:** Kilo
