**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-17 (documentación original por Deepseek V4 Flash)

# 04-Codigo.md — Módulo 135: Riesgos del Proyecto

## 1. Carácter del Componente

Módulo **administrativo de gestión**: no genera código del juego (Godot 4.x / GDScript), sino un registro de riesgos en Markdown mantenido a lo largo del ciclo de vida del proyecto. El "código" de este módulo son las plantillas y el registro vivo que cualquier agente de IA o el fundador puede editar.

**06-Plan-Testings.md:** NO aplica como suite automatizada (documento de gestión); la verificación se realiza con chequeos de formato y simulaciones de revisión (sección 12 del checklist).

## 2. Archivos previstos → Estado real de implementación

```
DOCUMENTACION/135-Riesgos-Del-Proyecto/plan-actual/
├── 01-Requerimientos.md                 ← CREADO (2026-08-17)
├── 02-Analisis.md                       ← CREADO (2026-08-17)
├── 03-Diseno.md                         ← CREADO (2026-08-17)
├── 04-Codigo.md                         ← CREADO (2026-08-17; actualizado 2026-08-28)
├── 05-Checklist.md                      ← CREADO (2026-08-17; marcado 2026-08-28)
├── RISK-REGISTER.md                     ← ✅ IMPLEMENTADO 2026-08-28 (16 entradas: R-01..R-15 + R-16 por hallazgo real)
└── GUIA-REVISION-TRIMESTRAL.md          ← ✅ IMPLEMENTADO 2026-08-28 (10 pasos + checklist de sesión)
```

## 3. Plantilla prevista: RISK-REGISTER.md

```markdown
**Modelo:** [último agente que lo editó]
**Plataforma:** [plataforma]
**Última revisión:** YYYY-MM-DD (trimestral) | **Próxima revisión:** YYYY-MM-DD

# Registro de Riesgos — isla-ancestral

## Resumen

| Zona | Cantidad | Acción |
|---|---|---|
| Roja (17-25) | N | Contingencia + seguimiento mensual |
| Naranja (10-16) | N | Mitigación activa |
| Amarilla (5-9) | N | Vigilancia trimestral |
| Verde (1-4) | N | Aceptación |
| Cerrados | N | — |

## Matriz probabilidad × impacto

| P \ I | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| 5 | · | · | · | · | · |
| 4 | · | TEC-02 | · | · | · |
| 3 | · | · | TEC-04 | BUR-01 | · |
| 2 | · | · | · | · | · |
| 1 | · | · | · | · | · |

(Cada celda lista los IDs de riesgo ubicados allí.)

## Entradas

### [ID] — [Título corto]
(tabla según plantilla de la sección 4 de 03-Diseno.md)
```

## 4. Ejemplos de entradas (contenido inicial previsto)

### TEC-01 — Dependencia crítica de los agentes de IA

| Campo | Valor |
|---|---|
| Categoría | TEC |
| Identificado | 2026-08-17, Fundador |
| Descripción | El flujo diario depende de agentes de IA; si fallan, la velocidad de producción colapsa |
| Probabilidad | 4 |
| Impacto | 4 |
| Nivel | 16 — Naranja (mitigación activa) |
| Estado | Monitoreado |
| Dueño | Fundador + protocolo multiagente (AGENTS.md sección 21) |
| Mitigación | IA como asistente y no autor final; QA cruzado de otro modelo; multiplicidad de plataformas |
| Contingencia | Plan B manual: priorizar hitos críticos sin IA (activa solo si el proveedor cae) |
| Próxima revisión | [fecha] |
| Historial | 2026-08-17: identificado en la documentación inicial del módulo 135 |

### BUR-01 — Burn-out del fundador

| Campo | Valor |
|---|---|
| Categoría | BUR |
| Identificado | 2026-08-17, Fundador |
| Descripción | Jornadas largas y presión sostenida pueden llevar al agotamiento del fundador único |
| Probabilidad | 3 |
| Impacto | 5 |
| Nivel | 15 — Naranja |
| Estado | Monitoreado |
| Dueño | Fundador (decisión exclusiva de prioridades) |
| Mitigación | Jornadas acotadas, pausas, prioridades de salud registradas en la revisión trimestral |
| Contingencia | Parar el proyecto temporalmente y preservar el estado (backups M107) |
| Próxima revisión | [fecha] |
| Historial | 2026-08-17: registrado; las prioridades de mitigación las define el fundador |

### TEC-04 — Tiempos de carga del mundo voxel

| Campo | Valor |
|---|---|
| Categoría | TEC |
| Identificado | 2026-08-17, Fundador |
| Descripción | El streaming de chunks (M63) puede producir cargas largas que rompen la experiencia cozy |
| Probabilidad | 3 |
| Impacto | 3 |
| Nivel | 9 — Amarillo (vigilancia) |
| Estado | Evaluado |
| Dueño | M63 (Cargas y Streaming) |
| Mitigación | Streaming asíncrono, precarga, indicadores de progreso (regla 8 de AGENTS.md) |
| Contingencia | — (zona amarilla) |
| Próxima revisión | [fecha] |
| Historial | 2026-08-17: identificado; validar con el prototipo M137 |

### ALC-01 — Scope creep

| Campo | Valor |
|---|---|
| Categoría | ALC |
| Identificado | 2026-08-17, Fundador |
| Descripción | Ideas nuevas a mitad de hito que amplían el alcance sin reevaluar el plan |
| Probabilidad | 4 |
| Impacto | 3 |
| Nivel | 12 — Naranja |
| Estado | Mitigándose |
| Dueño | M136 (Roadmap) + `5-FUTURAS-MEJORAS.md` |
| Mitigación | MoSCoW por hito; ideas "Could/Won't" derivadas a FUTURAS-MEJORAS; no tocar flujos estables (regla 16) |
| Contingencia | Congelar features del hito en curso y mover lo nuevo al siguiente |
| Próxima revisión | [fecha] |
| Historial | 2026-08-17: identificado en la documentación inicial |

## 5. Guía de revisión trimestral (procedimiento previsto)

1. Abrir `RISK-REGISTER.md` y la tabla de `CHECKLIST-GLOBAL.md`.
2. Recalcular P, I y nivel de cada entrada activa.
3. Verificar avance de mitigaciones; marcar vencidas.
4. Registrar riesgos nuevos (bugs M102, testings, QA cruzado, cambios de M136).
5. Cerrar riesgos superados con lección aprendida.
6. Aplicar escalamiento (nivel ≥ 17 o sin avance en zona naranja).
7. Actualizar la matriz 5×5 y el resumen de zonas.
8. Anotar fecha, firmar con el modelo participante y commitear (protocolo sección 4 de AGENTS.md).
9. Si se omite la revisión: registrar motivo y reprogramar en ≤ 30 días.
10. Reportar a M133/M136 cualquier riesgo que amenace hitos.

## 6. Contratos de integración

### Entrada (desde otros módulos)
- **M102 (Bug Tracking):** bugs repetidos o severos alimentan la reevaluación de riesgos TEC.
- **M137 (Prototipo):** resultados reales (rendimiento, cargas, bugs procedurales) recalibran probabilidades.
- **M134 (Presupuesto):** datos de gasto real vs. plan recalibran riesgos FIN.

### Salida (hacia otros módulos)
- **M133 (Gestión del Proyecto):** estado global de riesgos en cada ciclo.
- **M136 (Roadmap):** riesgos que amenazan hitos y sus mitigaciones.
- **M137 (Prototipo):** riesgos TEC que el prototipo debe validar primero.
- **Checklist global:** progreso del módulo (DoD sección 21.6 de AGENTS.md).

## 7. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear `RISK-REGISTER.md` con los 15 riesgos iniciales (R-01..R-15) | **IMPLEMENTACIÓN DELEGADA** (cualquier agente que reclame el módulo) |
| Crear `GUIA-REVISION-TRIMESTRAL.md` (opcional) | **IMPLEMENTACIÓN DELEGADA** |
| Realizar la primera revisión trimestral real | Fundador (con asistencia de un agente) |
| Definir prioridades reales de mitigación de BUR-01 | Fundador (no delegable) |
| Confirmar criterios de la escala P/I con M133 cuando exista | Próximo agente de M133 |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el módulo 135 completo (01 a 05) siguiendo el estándar del proyecto (firma, plan-inicial/plan-actual, 130 ítems de checklist).
- Identifiqué 15 riesgos iniciales del dominio (R-01 a R-15) en la matriz de 02-Analisis.md: técnicos (IA, Voxel Tools, mundo voxel, cargas), alcance, equipo, burn-out, financiamiento y mercado.
- Diseñé la matriz P×I 5×5 con 4 zonas (verde, amarilla, naranja, roja), plantilla de entrada, flujo de monitoreo y ciclo de revisión trimestral (< 1 hora).
- Definí el escalamiento (≥ 17 o mitigación sin avance) y el procedimiento de riesgo materializado.
- Especifiqué integración con M133 (referencia sin bloqueo), M134, M136 y M137, y dejé 4 entradas de ejemplo en la plantilla del registro.

### Lo que NO pude hacer (honestidad obligatoria)
- No creé `RISK-REGISTER.md` ni la guía de revisión (los archivos previstos quedan **Pendiente de implementación**).
- No asigné probabilidades/impactos definitivos: los valores de la matriz son estimaciones iniciales de documentación, y **las prioridades reales de los riesgos (especialmente BUR-01/burn-out) son decisión del fundador**.
- No pude verificar la madurez real de Voxel Tools en el proyecto (depende del prototipo M137).
- No realicé la revisión trimestral real (requiere fecha de calendario y participación del fundador).

### Recomendaciones para el próximo agente
- Al implementar, crear `RISK-REGISTER.md` a partir de la plantilla de 04-Codigo.md usando los 15 riesgos de 02-Analisis.md como contenido inicial.
- Verificar con el fundador los valores de P e I de cada riesgo; especialmente BUR-01 (salud) y FIN (financiamiento), que dependen de su situación real.
- Referenciar siempre M133 sin bloquearlo: si M133 ya existe, alinear el ancla de la revisión trimestral con su ciclo.
- Actualizar `CHECKLIST-GLOBAL.md` (fila 135, dependencia 133, Alta, complejidad 2) al completar la implementación, y generar log en `Logs/` según la sección 6 de AGENTS.md.
- No tocar `plan-inicial/` (inmutable); cualquier ajuste va en `plan-actual/` y en el registro vivo.

---

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 20:45:00
**Estado:** Completado (pendiente de QA cruzado)

### Lo que hice
- Implementé `RISK-REGISTER.md`: 16 entradas (R-01..R-15 del análisis inicial + **R-16 nuevo** por el hallazgo real de voxel-sin-soporte-web del 2026-08-25), matriz 5×5 poblada, resumen de zonas (0 roja, 7 naranja, 8 amarilla, 1 verde) y reglas operativas.
- Ejecuté una **revisión en papel** de los 15 riesgos contra evidencia real del proyecto (historiales actualizados por entrada: M08-M10 completados para R-03/R-05, M111 en curso para R-02, M134 implementado para R-11/R-12, multiplicidad de plataformas para R-09, etc.), documentada en el `Registro de revisiones`.
- Decisión documentada de IDs: ID primario R-XX consecutivo + código de categoría (TEC-01, BUR-01…) como alias, reconciliando el esquema de `02-Analisis.md` con los ejemplos de `04-Codigo.md`.
- Implementé `GUIA-REVISION-TRIMESTRAL.md` (10 pasos + checklist de sesión + regla de omisión/reprogramación), alineada al ciclo de M133.
- Marqué el checklist 134/134 sin `[?]` y verifiqué hashes plan-inicial/plan-actual (02-05 idénticos; 01 con la sección "Módulos Relacionados" añadida, convención del proyecto).
- Reservé y liberé el módulo en los 4 registros y generé el log 197.

### Lo que NO pude hacer (honestidad obligatoria)
- No realicé la **primera revisión trimestral formal**: requiere el fundador (fechas y prioridades de salud de R-10 son decisión no delegable). La revisión en papel del 2026-08-28 no la sustituye.
- Los valores P/I siguen siendo estimaciones iniciales: los recalqué contra evidencia disponible, pero la confirmación humana queda para la revisión formal.
- No materialicé contingencias reales (no hay riesgos materializados ni en zona roja): los flujos se probaron en papel.

### Recomendaciones para el próximo agente
- QA cruzado rápido: verificar 16 entradas, matriz poblada coherente con P×I, historiales append-only y checklist 134/134 sin `[?]`.
- Al cerrar M137 (Prototipo), ejecutar una revisión adelantada para recalibrar R-03/R-04/R-05 con datos reales de rendimiento.
- Cuando M135 y M135-ciclo convivan con más riesgos de implementación (bugs M102), agregar entradas nuevas con ID consecutivo (R-17+) sin renumerar.