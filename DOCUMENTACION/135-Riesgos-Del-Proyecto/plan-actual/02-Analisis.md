**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 135: Riesgos del Proyecto

## 1. Análisis del dominio

"isla-ancestral" es un juego cozy de mundo voxel (isla Aurora) desarrollado con Godot 4.x y Voxel Tools en GDScript, por un fundador único asistido por agentes de IA. Este dominio combina tres fuentes de riesgo estructurales:

1. **Complejidad técnica del mundo voxel:** generación procedural, chunking, streaming y tiempos de carga (M08, M09, M10, M63) concentran la mayor parte del riesgo técnico.
2. **Dependencia de la IA en el flujo de producción:** el fundador no delega solo código en los agentes, también diseño, documentación y QA. La calidad, disponibilidad y consistencia de la IA son riesgos de producción directos.
3. **Escala humana del equipo:** un único fundador concentra conocimiento, ejecución y toma de decisiones. Burn-out, enfermedad o pérdida de motivación son riesgos de severidad máxima porque no hay reemplazo natural.

A esto se suman riesgos clásicos de un proyecto indie: assets de terceros y licencias (M78), alcance (scope creep), financiamiento y resultado comercial en un nicho (cozy voxel).

## 2. Matriz de riesgos del proyecto (identificación inicial)

| ID | Categoría | Descripción del riesgo | Prob. (1-5) | Impacto (1-5) | Nivel (P×I) | Mitigación principal |
|---|---|---|---|---|---|---|
| R-01 | Técnicos | Dependencia crítica de los agentes de IA en el desarrollo diario | 4 | 4 | 16 (alto) | IA como asistente, el fundador revisa y entiende todo lo que se integra; regla 21.4 de AGENTS.md |
| R-02 | Técnicos | Calidad variable del código GDScript generado por IA (bugs, deuda) | 4 | 3 | 12 (alto) | M111 (Código de Calidad) + M112 (Testing) + revisiones por múltiples modelos (QA cruzado) |
| R-03 | Técnicos | Tamaño del mundo voxel ingobernable (rendimiento, almacenamiento) | 3 | 4 | 12 (alto) | Limitación de alcance por hito (M137, M138), LOD y chunking (M08/M63) |
| R-04 | Técnicos | Tiempos de carga y streaming lentos rompen la experiencia cozy | 3 | 3 | 9 (medio) | Streaming por chunks (M63), cargas asíncronas, barras de progreso (regla 8) |
| R-05 | Técnicos | Madurez limitada de Voxel Tools para Godot 4.x | 2 | 4 | 8 (medio) | Featureset mínimo verificado en Prototipo (M137); fallback a meshes manuales |
| R-06 | Alcance | Scope creep: agregar mecánicas nuevas continuamente | 4 | 3 | 12 (alto) | MoSCoW por hito (M136), visión documento (M02), no tocar flujos estables (regla 16) |
| R-07 | Alcance | Hitos del prototipo deslizantes por estimaciones optimistas | 3 | 3 | 9 (medio) | Estimaciones conservadoras en M133, margen de holgura del 20 % |
| R-08 | Equipo | Unicidad de conocimiento: solo el fundador sabe detalles clave | 3 | 4 | 12 (alto) | Documentación continua (AGENTS.md, DOCUMENTACION/), backups (M107) |
| R-09 | Equipo | Dependencia de un proveedor/herramienta único (ej: streams de la IA) | 2 | 4 | 8 (medio) | Multiplicidad de plataformas/modelos de IA, protocolo multiagente |
| R-10 | Burn-out | Agotamiento del fundador por jornadas largas y presión | 3 | 5 | 15 (alto) | Jornadas acotadas, pausas, quedan registrar prioridades de salud en revisión trimestral |
| R-11 | Financiamiento | Agotamiento de reservas antes de completar el lanzamiento | 3 | 4 | 12 (alto) | Presupuesto mensual (M134), fondo de reserva, hitos con retorno parcial |
| R-12 | Financiamiento | Costos imprevistos (assets, herramientas, hardware) | 2 | 3 | 6 (medio) | Fondo de contingencia del 10 %, revisión mensual en M134 |
| R-13 | Mercado | Resultado comercial flojo del nicho cozy en la plataforma elegida | 3 | 3 | 9 (medio) | Demo temprana, wishlists, comunidad desde M137 |
| R-14 | Mercado | Platform/engine deprecation o incompatibilidad futura | 1 | 4 | 4 (bajo) | Godot 4.x LTS, exportabilidad multi-plataforma en M04 |
| R-15 | Alcance | Assets de terceros con licencias no verificadas | 2 | 3 | 6 (medio) | Auditoría de licencias (M78), registro de créditos (M131) |

## 3. Evaluación probabilidad × impacto

### Escala de probabilidad (1-5)

| Valor | Significado | Criterio |
|---|---|---|
| 1 | Muy improbable | < 10 % (solo en condiciones extremas) |
| 2 | Improbable | 10–30 % (se previene con esfuerzo) |
| 3 | Posible | 30–60 % (ocurrió en proyectos similares) |
| 4 | Probable | 60–85 % (ya se observan síntomas) |
| 5 | Muy probable | > 85 % (casi seguro de ocurrir) |

### Escala de impacto (1-5)

| Valor | Significado | Impacto en el proyecto |
|---|---|---|
| 1 | Insignificante | Molestia menor, sin efecto en hitos |
| 2 | Menor | Retraso de días, ajuste menor de alcance |
| 3 | Moderado | Retraso de semanas o recorte parcial de mecánicas |
| 4 | Mayor | Pone en riesgo un hito (M137, M138) o el lanzamiento |
| 5 | Catastrófico | Abandono del proyecto o daño duradero a la salud del fundador |

### Nivel de riesgo (P × I)

| Nivel | Rango | Zona | Acción |
|---|---|---|---|
| Bajo | 1–4 | Verde | Aceptar y vigilar |
| Medio | 5–9 | Amarillo | Mitigación ligera; revisar cada trimestre |
| Alto | 10–16 | Naranja | Mitigación activa con responsable y fecha |
| Crítico | 17–25 | Rojo | Plan de contingencia obligatorio + seguimiento mensual |

## 4. Cómo se mitiga cada familia de riesgo (estrategias)

### Técnicos (R-01 a R-05)
- **IA como asistente, nunca como autor final:** todo el código generado lo revisa el fundador o un segundo agente (QA cruzado, sección 21.8 de AGENTS.md).
- **Calidad de código:** aplicar M111 (Código de Calidad) y M112 (Testing) como filtro obligatorio antes de integrar código de IA.
- **Mundo voxel acotado:** el tamaño de la isla Aurora debe definirse por hito (M137 → M138 → M139) con límites duros de chunks y presupuesto de memoria.
- **Cargas lentas:** streaming por chunks (M63) + indicadores de progreso visual (regla 8 de AGENTS.md).
- **Riesgo de la herramienta:** un vertical slice temprano (M137/M138) valida Voxel Tools antes de apostar la producción completa.

### De alcance (R-06, R-07, R-15)
- MoSCoW (Must/Should/Could/Won't) aplicado en cada hito por M136.
- Contenido "Could/Won't" registrado en `5-FUTURAS-MEJORAS.md` para no perder ideas sin comprometer el alcance.
- Auditoría de assets de terceros siguiendo M78 (Legal/Propiedad Intelectual).

### De equipo y burn-out (R-08 a R-10)
- Documentación-first (sección 13 de AGENTS.md): el conocimiento vive en DOCUMENTACION/, no en la cabeza del fundador.
- Backups automáticos (M107) para que ningún estado del proyecto dependa de un único archivo.
- El riesgo R-10 (burn-out) se trata en la revisión trimestral con honestidad: jornada limitada, pausas y prioridades de salud registradas por el propio fundador. **La prioridad de las mitigaciones de salud es decisión exclusiva del fundador.**

### De financiamiento y mercado (R-11 a R-14)
- M134 (Presupuesto) alimenta el rendimiento real vs. plan; el registro de riesgos compara reservas vs. gasto proyectado.
- M136 (Roadmap) programa la demo y la wishlist como mitigación de mercado.
- Plataforma: Godot 4.x permite exportar a múltiples targets; no bloquearse en una sola plataforma hasta M143 (Lanzamiento).

## 5. Alternativas consideradas

| Alternativa | Pros | Contras | Decisión |
|---|---|---|---|
| Sin registro (memoria) | Cero esfuerzo | Los riesgos se olvidan; gestión reactiva | ❌ Descartado |
| Hoja de cálculo (Excel/Sheets) | Filtros, fórmulas P×I | No versionable en git, formato propietario | ❌ Descartado |
| SaaS de gestión de riesgos | Dashboards profesionales | Costo, sobrecarga para 1 persona | ❌ Descartado |
| **Registro Markdown en el repo** | Versionado, costo $0, editable por IA, integrado a DOCUMENTACION/ | Sin cálculo automático (el nivel P×I es manual) | ✅ ELEGIDO |

## 6. Decisiones clave

1. **Registro Markdown versionado:** `RISK-REGISTER.md` dentro del módulo 135, editable por humanos y agentes de IA.
2. **Escalas 1–5 y cálculo P×I:** simple, sin herramientas; la tabla de rangos evita ambigüedades.
3. **Revisión trimestral obligatoria:** alineada al ciclo de gestión de M133, con duración objetivo < 1 hora.
4. **Zona roja con contingencia:** todo riesgo ≥ 17 exige plan de contingencia escrito antes de cerrar la revisión.
5. **Referenciar sin bloquear:** M133, M134, M136 y M137 se integran por documentos compartidos (CHECKLIST-GLOBAL, Logs), nunca por acoplamiento de código.
6. **La salud del fundador (R-10) se registra y monitorea, pero la decisión sobre las prioridades de mitigación es siempre del fundador.**