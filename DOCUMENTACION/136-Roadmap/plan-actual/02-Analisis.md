**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 136-Roadmap
**Estado:** Documentación inicial (plan original)

---

# 02-Analisis.md — Módulo 136: Roadmap

## 1. Análisis del Dominio

### 1.1 Roadmaps por fases en desarrollo indie

En proyectos indie de una persona, el roadmap NO puede organizarse solo por fechas: el ritmo real depende de la disponibilidad del fundador, la curva de aprendizaje de Godot 4.x / Voxel Tools y los hallazgos de cada fase. La literatura práctica del desarrollo indie coincide en dos principios:

1. **Organizar por fases verificables, no por fechas**: cada fase termina en un estado jugable (prototipo, slice, pre-alpha...) que demuestra el avance. La fecha es una consecuencia, no la causa.
2. **Cada fase debe tener un criterio de salida objetivo**: sin criterios medibles, una fase "casi lista" puede durar meses. Con criterios, se decide avanzar o estabilizar con datos.

*Isla Ancestral* tiene una ventaja estructural: el plan maestro de 150+ módulos ya desglosa el trabajo. El roadmap convierte ese backlog gigante en una **secuencia ordenada de fases**. Para esto se usa un desglose orientado a fases con:

- **Fase**: etapa del proyecto (Prototipo, Vertical Slice, Pre-Alpha, Alpha, Beta, RC, Lanzamiento).
- **Hito (M137-M143)**: punto verificable que cierra la fase (coincide con el módulo homónimo del plan maestro).
- **Entregable**: build jugable etiquetado en git con sus características.
- **Criterios de entrada/salida**: condiciones para iniciar y condiciones para cerrar la fase.

Ventaja clave para un solo desarrollador: completar un hito da una sensación de logro tangible (factor anti-abandono de M135) y genera un build demostrable ante testers y comunidad.

### 1.2 El vertical slice como primer hito verificable

El vertical slice (M138) es la pieza central del roadmap por varias razones:

- **Valida la visión**: una rebanada jugable de la isla Aurora con un objetivo completo demuestra si el juego "se siente" cozy y divertido.
- **Valida el riesgo técnico**: mundo voxel, generación procedural (M10), plantilla de chunk y streaming (M63) se enfrentan en pequeño antes de escalar.
- **Valida el workflow de producción**: assets, prefabs, escenas y builds se prueban en el flujo real.
- **Genera material de marketing**: gifs y videos del slice alimentan la página de Steam (M97) y la comunidad.

El roadmap ordena el desarrollo para llegar al vertical slice LO ANTES POSIBLE con el mayor valor demostrable, recortando agresivamente todo lo que no aporte al slice en su fase (regla de corte por fase). El resto de la isla (M27) y sistemas profundos (templos, historia) se extienden después.

### 1.3 Deuda técnica y su relación con el roadmap

Todo proyecto rápido acumula deuda técnica (código rápido, hacks, funciones sin testear). El roadmap debe incluirla explícitamente:

- **No planificar deuda aún pendiente de pago en la misma fase en que se genera**: los hacks del prototipo no deben arrastrarse a la alpha sin revisión.
- **Ventana de refactor por fase**: cada fase cierra con un pase mínimo de deuda (renombrar, limpiar, documentar) verificable en la DoD.
- **Deuda crítica que bloquea hitos posteriores**: se prioriza como Must de la fase siguiente (ej: una arquitectura de guardado insostenible no puede pasar a beta).
- El registro de deuda vive en M133 (RF7 de Gestión) y M135; el roadmap solo la ubica en el tiempo.

### 1.4 Hitos medibles: criterios de entrada/salida y DoD

La medibilidad de un hito requiere tres capas:

1. **Criterio de entrada**: qué debe estar listo antes de empezar (módulos dependientes completados con DoD, assets mínimos, decisiones de M01/M02 tomadas).
2. **Criterio de salida**: qué demostración objetiva cierra la fase (escena X carga, se completa el objetivo Y, rendimiento ≥ Z FPS, guardado funciona de A a B).
3. **DoD de módulos** (sección 21.6 de `AGENTS.md`): todo módulo incluido en el hito debe cumplir los 5 criterios (código, documentación, testings, log, firma).

Regla de oro: **un hito se cierra solo cuando sus criterios de salida y la DoD de sus módulos se cumplen**. Si esto no se cumple a tiempo, se aplica el proceso de deslizamiento (RF10) o corte de alcance (RF11), nunca un cierre ficticio.

### 1.5 Acceso anticipado vs full release

| Opción | Ventajas | Desventajas | Aplicación a Isla Ancestral |
|--------|----------|-------------|------------------------------|
| **Acceso anticipado (Steam EA)** | Ingresos tempranos (cubre Steam Direct Fee y gastos), comunidad y feedback durante el desarrollo, marketing orgánico | Expectativas del público, reputación si el juego queda a medias, presión de actualizaciones frecuentes | Favorable SI el vertical slice y la pre-alpha son sólidos; requiere plan de actualizaciones y comunidad activa |
| **Full release directo** | Una sola impresión, sin presión de updates evolutivos | Sin ingresos durante años de desarrollo; riesgo de lanzar "frío" sin audiencia previa | Riesgoso para presupuesto cero: sin wishlists previas la visibilidad de lanzamiento es mínima |
| **Híbrido (prologue + full release)** | Prologue/historia demo gratis genera audiencia; el release completo llega maduro | Dos lanzamientos que mantener; trabajo extra del prologue | Incluible como variante si EA no convence |

**Conclusión**: estrategia por etapas — construir audiencia durante alpha/beta (wishlists, playtests de M114), decidir EA vs full release con datos de la beta (M141). La decisión final la toma el fundador; el roadmap deja ambas puertas abiertas hasta la beta.

### 1.6 Presupuesto cero y ritmo sostenible (filosofía cozy)

El roadmap de un proyecto sin presupuesto debe maximizar el progreso con mínimos recursos:

- **Fases cortas con builds demostrables**: motivación constante sin gasto.
- **Uso intensivo de agentes de IA como fuerza de trabajo**: cada módulo puede ser documentado e implementado parcialmente por agentes; el fundador valida.
- **Ritmo anti-burnout (riesgo BUR-01 de M135)**: sin crunch; ventanas de descanso entre fases; hitos celebrables.
- **Costos diferidos**: Steam Direct Fee recién en la fase de beta/RC; herramientas de desarrollo siempre gratuitas (Godot es libre y open source).

---

## 2. Alternativas Evaluadas

### 2.1 Alternativa A — Roadmap por fechas fijas

Planificar hitos con fechas de calendario rígidas (ej: "Vertical slice: 1 de marzo").

- **Ventajas**: sensación de urgencia y calendario comunicable a terceros.
- **Desventajas**: con un solo desarrollador a tiempo parcial las fechas rígidas se incumplen; cada retraso desmotiva y desacredita el plan; choque directo con el riesgo de abandono (M135).
- **Veredicto**: RECHAZADA como base. Las fechas fijas solo se usan como objetivo de comunicación interna, nunca como contrato.

### 2.2 Alternativa B — Roadmap por criterios (fases + hitos)

Planificar con fases y criterios de salida verificables; fechas como rangos estimados.

- **Ventajas**: honesta con el ritmo real; los criterios no pueden "deslizarse" sin evidencia; cada fase termina jugable; compatible con la DoD y la tabla global.
- **Desventajas**: es imposible anunciar una fecha de lanzamiento con precisión temprana; requiere disciplina para no dejar fases "abiertas" sin cerrar.
- **Veredicto**: ADOPTADA. Es la base del diseño del módulo 136.

### 2.3 Alternativa C — Sin roadmap (solo backlog)

Trabajar módulo por módulo según prioridad sin fases ni hitos.

- **Ventajas**: máxima flexibilidad.
- **Desventajas**: sin horizonte verificable el proyecto no avanza hacia un objetivo jugable; alto riesgo de construir sistemas sin jugabilidad integrada (muerte silenciosa del proyecto); contradice el enfoque de vertical slice de M133.
- **Veredicto**: RECHAZADA. El backlog existe (plan maestro), pero necesita orden temporal.

### 2.4 Alternativa D — Publicar en EA apenas exista el slice

- **Ventajas**: ingresos tempranos.
- **Desventajas**: un vertical slice sin pulir puede dañar la reputación; sin pre-alpha/alpha maduras la comunidad se frustra.
- **Veredicto**: RECHAZADA como plan base. EA (si se elige) se evalúa con datos de la beta (M141), no antes.

---

## 3. Decisiones

| # | Decisión | Justificación |
|---|----------|---------------|
| D1 | Roadmap organizado por fases y hitos con criterios de entrada/salida (Alternativa B) | Honestidad con el ritmo solo-dev; fases jugables; compatibilidad con DoD |
| D2 | Los 7 hitos M137-M143 coinciden con los módulos homónimos del plan maestro | Un solo ID por hito: la fuente de verdad no se duplica |
| D3 | Fechas del calendario como rangos estimados, no como contratos | Evita desmotivación por retrasos y alinea con M135 (riesgo de abandono) |
| D4 | MoSCoW por fase para cortar alcance agresivamente | El vertical slice se logra recortando lo no esencial; el corte es parte del plan |
| D5 | Cada hito publica un build etiquetado y jugable | Entregable verificable, testeable (M114) y comunicable |
| D6 | Estrategia EA vs full release decidida con datos de la beta (M141) | No comprometer el lanzamiento sin audiencia; ambas puertas abiertas hasta beta |
| D7 | El roadmap se revisa con el ciclo de M133 y la revisión trimestral de M135 | El plan nunca queda obsoleto sin aviso |
| D8 | La deuda técnica se ubica explícitamente en las fases (ventana de refactor) | Evita acumular hacks del prototipo hasta el lanzamiento |

---

## 4. Análisis de Impacto

### 4.1 Impacto en el proyecto

- **Positivo**: orden temporal de 150+ módulos; progreso visible y motivante; foco en el vertical slice; cortes de alcance planificados en vez de accidentales; builds demostrables para comunidad.
- **Negativo potencial**: si el roadmap se vuelve burocrático (tablas que nadie actualiza) se convierte en deuda documental; mitigación: la revisión periódica de D7 y el criterio RN4 (≤ 10% del tiempo).

### 4.2 Impacto en módulos dependientes

- **M133 (Gestión)**: recibe los hitos como marco de sus ceremonias y plantillas (M133 usa los hitos M137-M143 como M1-M7).
- **M135 (Riesgos)**: recibe el calendario estimado para ubicar riesgos en el tiempo; a su vez, los riesgos que amenazan hitos alimentan la replanificación (RF10).
- **M137-M143 (hitos)**: reciben este marco de fases como su plantilla de contenido.

---

## 5. Integración del Dominio con el Resto del Proyecto

| Módulo | Relación con 136 |
|--------|------------------|
| M133 (Gestión del Proyecto) | Fuente del ciclo de gestión, DoD y ceremonias; el roadmap es la planificación de largo plazo |
| M135 (Riesgos del Proyecto) | Los riesgos amenazan hitos; el roadmap ubica mitigaciones en el tiempo |
| M137 (Prototipo) | Primera fase del roadmap; valida riesgo técnico y recalibra el calendario |
| M138 (Vertical Slice) | Segunda fase; objetivo motivador central del proyecto |
| M139 (Pre-Alpha) | Tercera fase; loop principal completo del GDD acotado |
| M140 (Alpha) | Cuarta fase; contenido y sistemas del núcleo, pulido en curso |
| M141 (Beta) | Quinta fase; feature complete, foco en bugs y equilibrio |
| M142 (RC) | Sexta fase; candidatos de release, compatibilidad y performance |
| M143 (Lanzamiento) | Séptima fase; release, marketing y soporte post-lanzamiento |

---

## 6. Riesgos del Análisis

| Riesgo del enfoque | Nivel | Mitigación |
|--------------------|-------|------------|
| El roadmap queda desactualizado por falta de uso | Medio | Revisión ligada al ciclo de M133 (D7); RN4 limita la burocracia |
| Los criterios de salida se vuelven letra muerta | Medio | Criterios verificables por build; QA cruzado (sección 21.8 de `AGENTS.md`) |
| La estimación de duración por fase es demasiado optimista | Alto | Rangos amplios (mín-máx); recalibración tras el prototipo M137 |
| La asignación de módulos por fase es imprecisa | Medio | La tabla de dependencias de `CHECKLIST-GLOBAL.md` es la referencia real al planificar |
| EA decidido sin datos (optimismo del fundador) | Medio | D6: la beta (M141) es la puerta de decisión con datos de wishlists/playtests |