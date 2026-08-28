**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Implementación operativa (entregable M133)

---

# README de Gestión — Módulo 133

> **Guía de arranque (onboarding).** Este documento explica cómo operar la gestión de *Isla Ancestral*. Está escrito para que **cualquier agente o el fundador** pueda ponerse al día en minutos, incluso después de una pausa larga (RN7, RF13).

---

## 1. Qué es y qué no es la gestión de este proyecto

**Es:** un sistema liviano (meta ≤ 10 % del tiempo en administración, RN4) basado en **Kanban + hitos por vertical slice** (decisión D1 de `plan-actual/02-Analisis.md`), 100 % gratuito (RN3) y versionado en este repositorio (RN10).

**No es:** un proceso paralelo al protocolo existente. La gestión **adopta y operativiza** el protocolo multiagente de la sección 21 de `AGENTS.md` (RF1-RF4); no lo reemplaza.

---

## 2. Mapa de la gestión (dónde está cada cosa)

| Necesito… | Archivo |
|---|---|
| Ver el estado de TODOS los módulos (fuente de verdad) | `CHECKLIST-GLOBAL.md` (raíz del proyecto) |
| Saber qué agente está trabajando en qué | `Mensajes entre modelos/ESTADO-PARALELO.md` |
| Entender el ciclo de trabajo de un módulo (reglas, estados, QA) | `DOCUMENTACION/133-Gestion-Del-Proyecto/flujo-multiagente.md` |
| Crear o revisar un hito (M0-M5) | `DOCUMENTACION/133-Gestion-Del-Proyecto/guia-hitos.md` |
| Organizar un bloque de trabajo / iteración | `DOCUMENTACION/133-Gestion-Del-Proyecto/guia-sprints.md` |
| Registrar una decisión relevante | `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/adrs/` (ver su README interno) |
| Levantar acta de una ceremonia | `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/actas/` |
| Escribir el reporte mensual de avance | `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/reportes/` |
| Ver el diseño completo del sistema de gestión | `plan-actual/01-Requerimientos.md` a `04-Codigo.md` |

---

## 3. Cómo incorporarse (checklist de onboarding, ~10 minutos)

- [ ] Leer la sección 21 de `AGENTS.md` (protocolo multiagente) — al menos 21.2 (estados), 21.3 (flujo) y 21.6 (DoD).
- [ ] Leer `flujo-multiagente.md` de esta carpeta (resumen operativo con los edge cases).
- [ ] Leer `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` (estado actual y quién está trabajando qué).
- [ ] Si vas a trabajar un módulo: leer su `plan-actual/` completo, incluidas las `## Notas del Agente` si el estado era 🟡.
- [ ] Reservar en los 4 registros (ver §4) y recién entonces empezar a tocar archivos.
- [ ] Al terminar: marcar checklist con honestidad, liberar el bloqueo, generar log y firmar documentos.

---

## 4. Reglas de oro (resumen ejecutable)

1. **`CHECKLIST-GLOBAL.md` es la única fuente de verdad** del estado de los módulos. El tablero (GitHub Projects v2, decisión pendiente de confirmar por el fundador — ver ADR-0002) es solo un espejo operativo.
2. **Un módulo por agente a la vez.** Reservar = marcar 🔵 + tu nombre + timestamp en los 4 registros: esta guía no cambia; cambian `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, la fila correspondiente de `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (§Reserva actual / §17) y el bloque `Reserva actual` del `05-Checklist.md` del módulo.
3. **No pisar archivos** que otro agente tenga 🔵/🔴. Zonas propias documentadas en `ESTADO-PARALELO.md` §Reglas de no-pisado.
4. **Honestidad obligatoria:** un `[?]` documentado vale más que un `[x]` falso. Los estados se calculan desde los `05-Checklist.md` reales (los scripts lo verifican).
5. **DoD de 5 criterios** antes de marcar `[x]`: implementado + documentación al día + verificaciones sin fallos + log generado + firma. Un módulo `✅` requiere además QA cruzado de un modelo distinto (§21.8).
6. **Todo cambio relevante de proceso/alcance** se decide por ADR (`plan-actual/adrs/`).
7. **Idioma:** español. **Commits:** español, pasado descriptivo, push solo bajo pedido explícito del fundador (`AGENTS.md` §4).

---

## 5. Ceremonias mínimas

| Ceremonia | Cuándo | Salida |
|---|---|---|
| Planificación de hito | Al inicio del hito | Acta en `plan-actual/actas/` + hito documentado con `guia-hitos.md` |
| Revisión de estado | Semanal (15 min) | Ejecutar `python scripts/verificar_checklist.py`; atender colgados y 🟡 |
| Retrospectiva de hito | Al cierre del hito | Acta breve; incluye la pregunta "¿este hito dio energía o la quitó?" |
| Prueba de juego (fundador) | Al cierre del hito | Feedback registrado como issues / notas de módulos |

---

## 6. Plan anti-abandono (diseño D8, resumen)

- **Hitos cortos que terminan jugables** (M1 prototipo, M2 vertical slice…) — el progreso siempre se puede jugar.
- **Progreso visible:** tabla global + tablero; completar módulos es señal real de avance.
- **Ritmo sostenible:** sesiones con metas pequeñas; prohibido el hábito de "maratón de 12 h" (coherente con M152).
- **Pausas planificadas:** esta documentación permite retomar sin costo (ver §7).
- **Señales de alerta** → activar plan de recuperación (recortar alcance inmediato, celebrar un logro, pedir feedback externo):
  - 2+ semanas sin commits.
  - Tablero/tabla sin movimiento.
  - Retrospectiva pospuesta 2 veces.
- **Testers tempranos:** compartir el vertical slice con amigos/comunidad (energía externa).

---

## 7. Cómo retomar el proyecto tras una pausa (continuidad)

1. `git pull` y leer este README completo.
2. Ejecutar `python scripts/test_scripts.py` (debe dar 8 PASS, 0 FAIL) y `python scripts/verificar_checklist.py`.
3. Leer en `CHECKLIST-GLOBAL.md` las filas 🔵/🔴 con `Última actividad` > 24 h: son reclamables (regla 21.4.7); las 🟡 tienen notas del agente anterior.
4. Elegir el **primer módulo pendiente de la primera fase habilitada** según `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (regla final: ni por número ni por facilidad).
5. Si la pausa fue larga, escribir un acta de "re-arranque" en `plan-actual/actas/` y un reporte de retoma en `plan-actual/reportes/`.

---

## 8. Contingencias (edge cases operativos)

- **Sin internet / GitHub caído:** trabajar solo con Markdown local; `CHECKLIST-GLOBAL.md` + checklists son la verdad durable y versionable. El tablero se sincroniza al volver.
- **Pérdida de datos de gestión:** el repo es copia primaria; restaurar desde backups (esquema 3-2-1 de M107). Verificar hashes de la tabla global con los scripts tras restaurar.
- **Conteo inflado / checklist con ítems de más:** corregir con `verificar_checklist.py` (detecta progreso declarado ≠ real) y regenerar con `generar_checklist_global.py --dry-run` antes de escribir.
- **Conflicto de reclamo (dos agentes, mismo módulo):** gana la reserva con timestamp más antiguo en `CHECKLIST-GLOBAL.md`; el otro elige otro módulo. Si hay disputa, resuelve el administrador del protocolo o el fundador.
- **Deuda técnica:** se registra como `[?]`/fila con nota o issue; se prioriza en la planificación del hito siguiente (ver `flujo-multiagente.md` §7).

---

## 9. Integración con otros módulos

- **M01** Fundamentos: hereda visión, alcance v1.0 y restricciones.
- **M03** Documentación: convenciones y ubicación de archivos.
- **M06** Control de versiones: política real de ramas/commits/push.
- **M107** Backups: la gestión (repo, actas, ADRs) entra en el esquema 3-2-1.
- **M118** CI-CD: automatización opcional de verificaciones; la gestión no depende de ella.
- **M132** Producción del Equipo: este módulo define roles de proceso; la organización de producción, horarios y estructura de equipo es de M132 (no duplicar).
- **M134/M135/M136** Presupuesto/Riesgos/Roadmap: reciben de aquí la política de herramientas gratuitas, la matriz de riesgos de gestión y los hitos M0-M5.
- **M137/M138** Prototipo/Vertical Slice: hitos M1 y M2, definidos con `guia-hitos.md`.
- **M152** Principios Innegociables: marco filosófico anti-burnout del proceso.

---

## 10. Mantenimiento de este README

Actualizaciones de proceso se registran como ADR y se reflejan aquí. Firma del último agente que lo modificó:

**Modelo:** GLM
**Plataforma:** Kilo
