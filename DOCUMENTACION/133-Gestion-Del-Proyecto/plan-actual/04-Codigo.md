**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Documentación inicial (plan original)

---

# 04-Codigo.md — Módulo 133: Gestión del Proyecto

## 1. Carácter del Componente

Módulo **administrativo / de proceso**: define cómo se organiza el desarrollo (metodología, roles, ceremonias, hitos, flujo multiagente, DoD, herramientas, anti-abandono). No genera código de juego; genera **plantillas, guías y documentación operativa** en Markdown, más la operación de los scripts ya existentes de la sección 21.9 de `AGENTS.md`.

**06-Plan-Testings.md:** NO aplica como suite de pruebas automatizadas de código; las verificaciones del módulo son procedimentales (conteo de checklist, hashes, consistencia de la tabla global) y se cubren en `05-Checklist.md`.

---

## 2. Archivos Previstos (implementación del módulo)

> ⚠️ **Todos estos archivos están "Pendiente de implementación"**: son la implementación operativa que un agente posterior (o el fundador) debe crear siguiendo este diseño. Este documento solo los especifica.

```
DOCUMENTACION/133-Gestion-Del-Proyecto/
├── plan-actual/                       ← Espejo del plan inicial (este módulo)
│   ├── 01-Requerimientos.md
│   ├── 02-Analisis.md
│   ├── 03-Diseno.md
│   ├── 04-Codigo.md
│   ├── 05-Checklist.md
│   ├── adrs/                          ← PENDIENTE DE IMPLEMENTACIÓN (registro de decisiones)
│   │   ├── 0001-README-adrs.md        ← Cómo escribir un ADR en este proyecto
│   │   └── ... (ADRs numerados al producirse decisiones)
│   ├── actas/                         ← PENDIENTE DE IMPLEMENTACIÓN (actas de ceremonias)
│   │   └── 0001-acta-planificacion-hito-M1.md
│   └── reportes/                      ← PENDIENTE DE IMPLEMENTACIÓN (reportes mensuales)
│       └── 2026-08-reporte-avance.md
├── README.md                          ← PENDIENTE DE IMPLEMENTACIÓN (guía de arranque de la gestión)
├── guia-hitos.md                      ← PENDIENTE DE IMPLEMENTACIÓN (plantilla + guía de hitos)
├── guia-sprints.md                    ← PENDIENTE DE IMPLEMENTACIÓN (guía de iteraciones/bloques de trabajo)
└── flujo-multiagente.md              ← PENDIENTE DE IMPLEMENTACIÓN (resumen operativo del protocolo 21)
```

Fuera de la carpeta (ya existentes, se OPERAN, no se reimplementan):

```
CHECKLIST-GLOBAL.md                    ← Fuente de verdad del estado global (raíz)
Mensajes entre modelos/ESTADO-PARALELO.md ← Coordinación de agentes
scripts/generar_checklist_global.py    ← Regenera la tabla global desde los checklists
scripts/verificar_checklist.py         ← Verifica consistencia de la tabla global
scripts/test_scripts.py                ← Suite de tests de los scripts
```

---

## 3. Especificación de Plantillas

### 3.1 Plantilla de hito (`guia-hitos.md` — PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# Hito {N}: {Nombre}
**Fecha inicio:** ... · **Fecha objetivo:** ... · **Estado:** ⬜/🔵/🟡/✅

## Objetivo
{Una frase: qué se demuestra jugablemente al cerrar este hito}

## Alcance
- Módulos incluidos: {IDs y nombres}
- Fuera del alcance de este hito: {para evitar scope creep}

## Dependencias
- {Módulos que deben estar listos antes}

## Tareas (vinculadas al tablero)
1. {Tarea} → agente {X}
2. {Tarea} → agente {Y}

## Criterios de salida (cada uno verificable)
- [ ] {Criterio 1}
- [ ] {Criterio 2}
- [ ] Prueba de juego del fundador hecha
- [ ] Retrospectiva registrada en actas/

## Riesgos del hito
- {Riesgo} → mitigación
```

### 3.2 Plantilla de ADR (`adrs/` — PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# ADR-{N}: {Título de la decisión}
**Fecha:** {YYYY-MM-DD} · **Estado:** Aceptado / Propuesto / Rechazado

## Contexto
{Qué problema nos llevó a decidir}

## Decisión
{Qué se decidió, en una frase clara}

## Opciones descartadas
- {Opción A} → descartada por {motivo}
- {Opción B} → descartada por {motivo}

## Consecuencias
{Positivas y negativas conocidas}

**Firma:** {Modelo} / {Plataforma}
```

### 3.3 Plantilla de acta (`actas/` — PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# Acta {YYYY-MM-DD} — {Ceremonia}
**Presentes:** {quién} · **Duración:** {min}

## Temas
1. {Tema} → {acuerdo/decisión}

## Decisiones
- {Decisión con responsable y fecha límite}

## Pendientes
- {Ítem que queda abierto}

**Firma:** {Modelo} / {Plataforma}
```

---

## 4. Ejemplo de Tablero (GitHub Projects v2)

Vista Kanban (columnas = estados de la tabla global):

| ⬜ Sin iniciar | 🟢 Disponible | 🔵 En curso | 🟡 Con dudas | ✅ Completado |
|----------------|----------------|-------------|--------------|---------------|
| M135 Riesgos (Alta, dep: 133) | M136 Roadmap (Alta, dep: 133,135) | M138 Vertical Slice (Alta, dep: 137,26,19) | M111 Código de Calidad (Alta) | M01 Fundamentos (Alta) |
| M139 Pre-Alpha (Alta, dep: 138) | M137 Prototipo (Alta, dep: 08,11,14,59) | | | M03 Documentación (Alta) |

Campos por tarjeta: `Prioridad`, `Complejidad (1-5)`, `Dependencias`, `Agente actual`, `Hito (M0..M5)`, `Enlace al 05-Checklist.md`.

Regla de sincronización: cada vez que un agente cambia el estado de un módulo en `CHECKLIST-GLOBAL.md` (o en el `05-Checklist.md`), mueve la tarjeta del tablero. Los scripts de la sección 21.9 validan que el documento y el checklist estén consistentes; el tablero es un reflejo operativo, no la fuente de verdad.

---

## 5. Ejemplo de Reporte Mensual (`reportes/` — PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# Reporte de Avance — {Mes Año}
**Preparado por:** {Agente} · **Fecha:** {YYYY-MM-DD}

## Resumen ejecutivo
{Módulos completados este mes: N · En curso: M · Dudas abiertas: K}

## Detalle
- ✅ Completados: {IDs y nombres}
- 🔵 En curso: {IDs, agente y antigüedad}
- 🟡 Con dudas: {IDs y qué falta (leer "Notas del Agente")}
- ⚠️ Colgados (>24 h): {IDs, si hay}

## Riesgos activos
- {Riesgo} → estado → mitigación

## Próximo mes
- Módulos objetivo: {IDs}
- Hito en preparación: {Hito}
```

---

## 6. Uso de los Scripts de Verificación (operación, no reimplementación)

1. **Antes de tocar cualquier módulo**: `python scripts/test_scripts.py` (debe dar 8 PASS, 0 FAIL).
2. **Al terminar un turno**: `python scripts/verificar_checklist.py` → detecta progresos inflados, colgados, `[?]` en `✅`, inconsistencias.
3. **Al finalizar un turno de trabajo / tras crear módulos**: `python scripts/generar_checklist_global.py --dry-run` (simular) y luego ejecución normal si procede.

Los scripts **son herramientas de apoyo que se ejecutan manualmente**; no sustituyen la honestidad de los agentes.

---

## 7. Contratos de Integración

### Salida (hacia otros módulos)
- **M01 (Fundamentos del Proyecto):** adopta metodología y DoD; hereda alcance v1.0 de 01.
- **M135 (Riesgos del Proyecto):** recibe la matriz de riesgos de gestión; este módulo alimenta el registro con el riesgo de abandono y el riesgo de proceso.
- **M136 (Roadmap):** recibe los hitos M0-M5 y las dependencias de módulos como insumo de planificación.
- **M137 (Prototipo):** recibe el marco de trabajo del hito M1 y su plantilla de hito.
- **M138 (Vertical Slice):** recibe el marco del hito M2, criterios de salida y proceso de prueba de juego.
- **M134 (Presupuesto):** recibe la política de herramientas gratuitas (costo cero de gestión).
- **M107 (Backups):** recibe el requisito de respaldar la gestión (repo + actas + ADRs).

### Entrada (desde otros módulos)
- **M01 (Fundamentos):** visión, alcance v1.0 y restricciones del proyecto.
- **M03 (Documentación del Proyecto):** convenciones de documentación y estructura de carpetas.
- **M06 (Control de Versiones):** política real de git sobre la que se apoya la gestión de repo.
- **M118 (CI-CD):** estado del pipeline para decidir automatizaciones.
- **M152 (Principios Innegociables):** marco filosófico que obliga al proceso anti-burnout.

### Configuración
- `DOCUMENTACION/133-Gestion-Del-Proyecto/README.md` (PENDIENTE DE IMPLEMENTACIÓN) documenta cómo operar la gestión.
- `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` se mantienen por todo agente que trabaje en el proyecto.

---

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 133 (5 archivos en `plan-inicial/`, espejo idéntico en `plan-actual/`).
- Definí la metodología (Kanban liviano + hitos por vertical slice), roles, ceremonias, DoD y flujo multiagente operativo sobre el protocolo existente de la sección 21 de `AGENTS.md`.
- Decidí GitHub Projects v2 como tablero gratuito con justificación y contingencia offline.
- Diseñé las plantillas de hito, ADR, acta y reporte mensual, y el uso operativo de los scripts de verificación existentes.
- Documenté la integración con M01, M134, M135, M136, M137, M138, M107, M152 y M118.
- Escribí el checklist del módulo con 127 ítems, todos completados (plan original) y con marcadores de esfuerzo [S]/[M]/[C].

### Lo que NO pude hacer (honestidad obligatoria)
- Las decisiones de proceso finales son del fundador: elegir la herramienta definitiva (GitHub Projects vs. alternativa), la duración de las iteraciones y el orden exacto de los hitos es una decisión humana confirmada, no una imposición del documento.
- No implementé los archivos operativos (README, guía-hitos, guía-sprints, flujo-multiagente, ADRs, actas, reportes): quedan especificados y "Pendiente de implementación".
- No actualicé `CHECKLIST-GLOBAL.md` ni generé log en `Logs/`: la tarea restringió los cambios a la carpeta del módulo 133.
- No ejecuté Play Mode ni tests de Godot (módulo administrativo, sin código de juego).

### Recomendaciones para el próximo agente
- Antes de implementar la operación real, ejecutar `scripts/test_scripts.py` (debe dar 8 PASS) y `scripts/verificar_checklist.py` para confirmar que el estado global está sano.
- Crear el `README.md` de gestión y la `guia-hitos.md` con la plantilla del hito M1 (Prototipo M137) como ejemplo práctico.
- Crear el primer ADR registrando la decisión de herramienta (GitHub Projects v2) confirmada por el fundador.
- Actualizar `CHECKLIST-GLOBAL.md` (fila 133 a `🟢`/`✅` según convención) y generar el log correspondiente cuando la tarea lo permita, respetando el protocolo de la sección 21.
- Al implementar la gestión real, verificar que los conteos de la tabla global no se inflen y que cada módulo `✅` pase el QA cruzado de un modelo distinto.