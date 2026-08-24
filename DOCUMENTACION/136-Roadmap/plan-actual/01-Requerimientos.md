**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 136-Roadmap
**Estado:** Documentación inicial (plan original)

---

# 01-Requerimientos.md — Módulo 136: Roadmap

## 1. Problema

El proyecto *Isla Ancestral* (mundo voxel cozy ambientado en la isla Aurora, desarrollado en Godot 4.x con Voxel Tools y GDScript) cuenta con un plan maestro de más de 150 módulos documentados, gestionados mediante el protocolo multiagente de `AGENTS.md` (sección 21) con `CHECKLIST-GLOBAL.md` como fuente de verdad. Ese plan maestro define QUÉ construir, pero no organiza el trabajo en el TIEMPO: no existe una hoja de ruta que diga en qué orden construir los módulos, en qué fases, con qué hitos verificables y con qué criterios de avance se llega a la v1.0.

El problema central es de **ordenamiento temporal del desarrollo**: cómo convertir los 150+ módulos en una secuencia de fases (Prototipo, Vertical Slice, Pre-Alpha, Alpha, Beta, RC, Lanzamiento) con hitos M137-M143 medibles, priorizados por valor para el jugador y por riesgo técnico, y que permita decidir cortes de alcance, fechas y releases sin caer en el abandono (riesgo documentado por M135) ni en el alcance descontrolado.

### Contexto del problema

- Equipo mínimo: 1 fundador + agentes de IA como fuerza de trabajo auxiliar; presupuesto cero (solo `Steam Direct Fee` de USD 100 previsto en M134).
- Los módulos M133 (Gestión del Proyecto) y M135 (Riesgos del Proyecto) ya están documentados. M136 depende de ambos y alimenta a los módulos de hitos M137-M143.
- El roadmap debe respetar el orden natural del desarrollo: el vertical slice (M138) depende del prototipo (M137); pre-alpha (M139), alpha (M140), beta (M141), RC (M142) y lanzamiento (M143) dependen del slice y de los hitos previos.
- Los hitos de este módulo (M137-M143) coinciden en ID con los módulos del mismo nombre del plan maestro: Prototipo (M137), Vertical Slice (M138), Pre-Alpha (M139), Alpha (M140), Beta (M141), RC (M142) y Lanzamiento (M143).
- Los criterios de salida de cada hito deben ser verificables y cumplir la DoD de la sección 21.6 de `AGENTS.md` (código implementado, documentación actualizada, testings superados, log generado, firma).
- La fecha real de cada hito depende del ritmo del fundador: el roadmap define criterios y orden; las fechas son estimaciones a confirmar y recalibrar.

---

## 2. Objetivos

### 2.1 Objetivo General

Definir una **hoja de ruta del desarrollo** de *Isla Ancestral* que organice los 150+ módulos del plan maestro en 7 hitos con fases claras (Prototipo, Vertical Slice, Pre-Alpha, Alpha, Beta, RC, Lanzamiento), cada uno con criterios de entrada y salida verificables, dependencias explícitas, prioridades y calendario estimado, de modo que el proyecto avance de forma jugable, motivante y sostenible hasta la v1.0.

### 2.2 Objetivos Específicos

| # | Objetivo | Criterio de éxito |
|---|----------|-------------------|
| 1 | Roadmap maestro definido | Los 7 hitos M137-M143 con fases, criterios de entrada/salida y calendario estimado documentados |
| 2 | Hitos medibles | Cada hito tiene criterios de salida verificables que cumplen la DoD (sección 21.6 de `AGENTS.md`) |
| 3 | Priorización real | Cada módulo del plan maestro está asignado a una fase con prioridad MoSCoW |
| 4 | Dependencias explícitas | Dependencias entre hitos y módulos documentadas y coherentes con `CHECKLIST-GLOBAL.md` |
| 5 | Corte de alcance gestionado | Proceso definido para mover módulos de un hito a otro sin romper la coherencia |
| 6 | Releases planificados | Política de builds y lanzamiento definida (EA vs full release) |
| 7 | Contextualizado a Godot 4.x | El roadmap respeta el stack real (GDScript, Voxel Tools, git) y el ritmo indie solo-dev |
| 8 | Coherente con gestión y riesgos | El roadmap integra el ciclo de M133 y las mitigaciones de M135 (especialmente anti-abandono) |

---

## 3. Alcance

### 3.1 Dentro del alcance (ESTE COMPONENTE)

- Definición de fases y hitos M137-M143 con criterios de entrada y salida.
- Asignación tentativa de los módulos del plan maestro a cada hito/fase.
- Priorización de módulos por fase (MoSCoW: Must / Should / Could / Won't).
- Documentación de dependencias entre hitos y módulos.
- Calendario estimado por fase e hito (rangos, no fechas rígidas).
- Política de builds y releases (prototipo, slice, pre-alpha, alpha, beta, RC, lanzamiento).
- Proceso de replanificación ante retraso de hito, corte de alcance y dependencia fallida.
- Plantilla `ROADMAP.md` y checklist por hito (archivos previstos, pendientes de implementación).
- Integración con M133 (Gestión), M135 (Riesgos) y M137-M143 (módulos de hitos).

### 3.2 Fuera del alcance (otros módulos)

- Metodología de gestión general (ceremonias, DoD, flujo multiagente) → M133 (Gestión del Proyecto).
- Registro y análisis de riesgos → M135 (Riesgos del Proyecto).
- Contenido concreto del prototipo → M137 (Prototipo).
- Contenido concreto del vertical slice → M138 (Vertical Slice).
- Contenido de pre-alpha, alpha, beta, RC y lanzamiento → M139, M140, M141, M142 y M143 respectivamente.
- Presupuesto y costos → M134 (Presupuesto).
- Implementación de código de juego (el roadmap ordena, no desarrolla).

---

## 4. Requerimientos Funcionales (RF)

| ID | Requerimiento | Prioridad | Criterio de aceptación |
|----|---------------|-----------|------------------------|
| RF1 | Definir el roadmap maestro con las fases y los 7 hitos M137-M143 | Alta | Cada hito tiene nombre, objetivo jugable, alcance y posición en la secuencia |
| RF2 | Definir criterios de entrada para cada hito | Alta | Todo hito documenta las condiciones (módulos/dependencias) previas a comenzar |
| RF3 | Definir criterios de salida verificables para cada hito | Alta | Cada criterio es comprobable y cumple la DoD de la sección 21.6 |
| RF4 | Asignar módulos del plan maestro a cada hito | Alta | Todo módulo del plan maestro tiene fase/hito de referencia |
| RF5 | Priorizar por fase con MoSCoW | Alta | Todo módulo/función tiene clasificación Must/Should/Could/Won't por fase |
| RF6 | Documentar dependencias entre hitos | Alta | La secuencia M137 → M138 → M139 → M140 → M141 → M142 → M143 es explícita |
| RF7 | Estimar el calendario por fase | Media | Rangos de duración estimados por fase, marcados como estimaciones del fundador |
| RF8 | Definir la política de builds y releases | Alta | Cada hito publica un build identificable (etiqueta git) y jugable |
| RF9 | Definir la estrategia EA vs full release | Media | Decisión documentada con criterios y momento del roadmap |
| RF10 | Gestionar la replanificación por retraso de hito | Alta | Proceso documentado para deslizar fechas sin mentir el estado global |
| RF11 | Definir el corte de alcance (scope cut) por hito | Alta | Proceso para mover módulos de un hito a otro con impacto documentado |
| RF12 | Gestionar dependencia fallida entre módulos | Media | Procedimiento de desbloqueo (alternativas, hito posterior, renegociación) |
| RF13 | Mantener coherencia con `CHECKLIST-GLOBAL.md` | Alta | El estado de hits/hitos se refleja en la tabla global sin contradicciones |
| RF14 | Registrar cambios del roadmap | Alta | Todo ajuste de hitos, fechas o alcance queda en el log del módulo |
| RF15 | Publicar la hoja de ruta accesible al fundador | Media | `ROADMAP.md` en la carpeta del módulo, legible en pocos minutos |
| RF16 | Permitir la revisión periódica del roadmap | Media | El roadmap se revisa con el ciclo de M133 y se recalibra con datos reales |

---

## 5. Requisitos No Funcionales (RN)

| ID | Requisito | Detalle |
|----|-----------|---------|
| RN1 | Idioma | Todo el roadmap y su documentación en español |
| RN2 | Formato | Markdown con la estructura estándar del proyecto (`AGENTS.md`) |
| RN3 | Presupuesto cero | El roadmap no requiere herramientas con costo recurrente |
| RN4 | Sostenible para 1 persona | La administración del roadmap demanda ≤ 10% del tiempo de desarrollo |
| RN5 | Legible por agentes IA | Los hitos y criterios son interpretables por modelos múltiples (secciones 10, 17 y 21 de `AGENTS.md`) |
| RN6 | Trazabilidad | Todo cambio de roadmap tiene autor, fecha y motivo |
| RN7 | Resiliencia a ausencias | Un agente nuevo puede retomar el roadmap solo con la documentación |
| RN8 | Fechas orientadas a criterios | Las fechas son estimaciones; los criterios de salida son la verdad del avance |
| RN9 | Git-friendly | `ROADMAP.md` y los checklist por hito viven versionados en el repositorio |
| RN10 | Verificable | Los estados de los hitos son comprobables contra los checklists reales |
| RN11 | Respaldado | El roadmap entra en el esquema de backups del proyecto (M107) |
| RN12 | Alineado con la filosofía cozy | El plan evita el burnout y respeta los Principios Innegociables (M152) |
| RN13 | Escalable de 1 a pocas personas | El roadmap soporta incorporar colaboradores o un publisher sin rediseño |
| RN14 | Accesible sin conexión | `ROADMAP.md` se puede leer offline como contingencia |

---

## 6. Restricciones

- **Tecnología del proyecto:** Godot 4.x, GDScript, Voxel Tools; el roadmap es agnóstico al código pero respeta su orden de implementación.
- **Equipo:** 1 persona (fundador) + agentes de IA; sin contrataciones previstas en el inicio.
- **Presupuesto:** cero; el único desembolso previsto es `Steam Direct Fee` (M134).
- **Ritmo:** desarrollo en tiempo parcial o completo según disponibilidad del fundador; las duraciones del calendario son rangos amplios.
- **Filosofía del juego:** atmosfera cozy; el roadmap no planifica crunch ni metas imposibles (coherente con M152 y con el riesgo BUR-01 de M135).
- **Documentación:** los documentos del roadmap se ubican en `DOCUMENTACION/136-Roadmap/` y siguen las reglas de firmas, logs y planes de `AGENTS.md`.
- **Coherencia con la tabla global:** la fila 136 de `CHECKLIST-GLOBAL.md` (Alta, complejidad 2, dependencias 133 y 135) es la fuente de verdad del estado del módulo.

---

## 7. Criterios de Aceptación del Módulo

- [x] El roadmap maestro está documentado en los 5 archivos del módulo.
- [x] Los 7 hitos M137-M143 tienen criterios de entrada y salida definidos y verificables.
- [x] La asignación de módulos por fase y la priorización MoSCoW están especificadas.
- [x] Las dependencias entre hitos y módulos están documentadas.
- [x] El calendario estimado por fase existe con rango de duración.
- [x] La política de builds y la estrategia EA vs release están decididas.
- [x] La integración con M133, M135 y M137-M143 está documentada.
- [x] El checklist del módulo tiene ≥ 120 ítems, todos verificables.

---

## 8. Fuentes del Requerimiento

| Fuente | Archivo / Sección |
|--------|-------------------|
| Reglas globales del proyecto | `AGENTS.md` (secciones 3, 4, 6, 10, 16, 17, 21) |
| Fuente de verdad de módulos | `CHECKLIST-GLOBAL.md` (raíz) |
| Gestión del proyecto | `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/` |
| Riesgos del proyecto | `DOCUMENTACION/135-Riesgos-Del-Proyecto/plan-actual/` |
| Plan maestro | `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` |
| Plan de producción | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` |
| Principios innegociables | `DOCUMENTACION/152-Principios-Innegociables/plan-actual/` |
| Objetivo final del proyecto | `DOCUMENTACION/153-Objetivo-Final-Del-Proyecto/plan-actual/` |

---

## 9. Riesgos Iniciales Identificados

| Riesgo | Nivel | Mitigación inicial |
|--------|-------|--------------------|
| Hitos deslizantes (fechas incumplidas) | Alto | Criterios de salida como verdad; fechas como estimación; deslizamiento documentado (RF10) |
| Alcance descontrolado por fase | Alto | MoSCoW por hito; proceso de corte de alcance (RF11); renegociación con M133 |
| Dependencia fallida entre módulos | Medio | Procedimiento de desbloqueo (RF12); alternativas en M135 |
| Roadmap obsoleto (no se actualiza) | Medio | Revisión periódica con el ciclo de M133 (RF16); log obligatorio (RF14) |
| Abandono por falta de progreso visible | Alto | Hitos cortos y jugables; vertical slice (M138) como foco motivador |
| Estimación irreal del ritmo del fundador | Alto | Calendario en rangos; recalibración con datos reales del prototipo M137 |
| Conflicto entre roadmap e implementación real | Medio | Coherencia con `CHECKLIST-GLOBAL.md` verificable (RF13, RN10) |

---

## 10. Dependencias del Módulo

| Dependencia | Tipo | Uso |
|-------------|------|-----|
| M133 (Gestión del Proyecto) | Blanda (referencia) | Ciclo de gestión, DoD, ceremonias y flujo multiagente |
| M135 (Riesgos del Proyecto) | Blanda (referencia) | Riesgos que amenazan hitos y sus mitigaciones |
| M137-M143 (hitos) | Blanda (salida) | Reciben marco de fases, criterios y dependencias desde este módulo |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M133** — Gestión del Proyecto | Roadmap de gestión |
| **M135** — Riesgos del Proyecto | Base para riesgos del proyecto |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M133** — Gestión del Proyecto | Depende de este módulo |
| **M135** — Riesgos del Proyecto | Depende de este módulo |

