**Modelo:** GLM
**Plataforma:** Kilo
**Última revisión:** 2026-08-28 (revisión inicial en papel, por implementación) | **Próxima revisión:** 2026-11-28 (primera revisión trimestral formal, pendiente de confirmación del fundador)

# Registro de Riesgos — isla-ancestral

> **Registro vivo** (fuente: `plan-actual/02-Analisis.md` §2 y procedimiento de `03-Diseno.md`). Regla de IDs: el ID primario es **R-XX consecutivo** (heredado del análisis inicial); cada entrada conserva además su **código de categoría** (TEC/ALC/EQU/BUR/FIN/MER) como alias. El nivel es P×I manual (sin herramientas; decisión D2 de `02-Analisis.md`).

## Escalas (resumen; detalle completo en `02-Analisis.md` §3)

- **Probabilidad 1-5:** 1 muy improbable (<10 %) · 2 improbable (10-30 %) · 3 posible (30-60 %) · 4 probable (60-85 %, síntomas visibles) · 5 muy probable (>85 %).
- **Impacto 1-5:** 1 insignificante · 2 menor (días) · 3 moderado (semanas/recorte parcial) · 4 mayor (riesgo de hito o lanzamiento) · 5 catastrófico (abandono o salud del fundador).
- **Zonas:** Verde 1-4 (aceptar) · Amarillo 5-9 (vigilancia trimestral) · Naranja 10-16 (mitigación activa) · Rojo 17-25 (contingencia obligatoria + seguimiento mensual).

## Resumen

| Zona | Cantidad | Riesgos | Acción |
|---|---|---|---|
| Roja (17-25) | 0 | — | — |
| Naranja (10-16) | 7 | R-01, R-02, R-03, R-06, R-08, R-10, R-11 | Mitigación activa |
| Amarilla (5-9) | 8 | R-04, R-05, R-07, R-09, R-12, R-13, R-15, R-16 | Vigilancia trimestral |
| Verde (1-4) | 1 | R-14 | Aceptación |
| Cerrados | 0 | — | — |

## Matriz probabilidad × impacto

| P \ I | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| 5 | · | · | · | · | · |
| 4 | · | · | R-02, R-06 | R-01 | · |
| 3 | · | · | R-04, R-07, R-13, R-16 | R-03, R-08, R-11 | R-10 |
| 2 | · | · | R-12, R-15 | R-05, R-09 | · |
| 1 | · | · | · | R-14 | · |

---

## Entradas

### [R-01] — Dependencia crítica de los agentes de IA (código de categoría: TEC-01)

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-17, Fundador/Deepseek (documentación inicial) |
| Descripción | El flujo diario depende de agentes de IA; si fallan, la velocidad de producción colapsa |
| Probabilidad | 4 |
| Impacto | 4 |
| Nivel | 16 — Naranja (mitigación activa) |
| Estado | Monitoreado |
| Dueño | Fundador + protocolo multiagente (AGENTS.md §21) |
| Mitigación | IA como asistente y no autor final; QA cruzado de otro modelo (§21.8); multiplicidad de plataformas/modelos |
| Contingencia | Plan B manual: priorizar hitos críticos sin IA (activar solo si el proveedor cae) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28 (revisión en papel): evidencia real confirma P=4 (8+ agentes activos en CHECKLIST-GLOBAL/ESTADO-PARALELO); se mantiene nivel |

### [R-02] — Calidad variable del código GDScript generado por IA (TEC-02)

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Bugs y deuda técnica del código generado por IA llegan a producción |
| Probabilidad | 4 |
| Impacto | 3 |
| Nivel | 12 — Naranja |
| Estado | Mitigándose |
| Dueño | M111 (Código de Calidad, 🔵 en curso) + M112 (Testing) |
| Mitigación | M111 como filtro (lint, pre-commit, CI); M112 testing automático; QA cruzado multi-modelo; registro de errores en 07-GUIA-GODOT §8 |
| Contingencia | Congelar integración de código nuevo hasta pasar el gate de calidad |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: M111 reservado/en curso por ox-alpha (log 219); mitigación avanzando |

### [R-03] — Tamaño del mundo voxel ingobernable (TEC-03)

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Rendimiento y almacenamiento se vuelven ingobernables al escalar el mundo |
| Probabilidad | 3 |
| Impacto | 4 |
| Nivel | 12 — Naranja |
| Estado | Monitoreado |
| Dueño | M08 (Mundo Voxel) + M61 (Rendimiento) + M136 |
| Mitigación | Alcance acotado por hito (M137/M138), LOD y chunking (M08/M63), presupuestos de M61 |
| Contingencia | Congelar tamaño del mundo al máximo medido estable |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: M08/M09/M10 completados con isla única acotada (semilla 42); el riesgo reaparece al escalar a 4 islas (M27/M160); se mantiene P=3 |

### [R-04] — Tiempos de carga y streaming lentos (TEC-04)

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | El streaming de chunks (M63) puede producir cargas largas que rompen la experiencia cozy |
| Probabilidad | 3 |
| Impacto | 3 |
| Nivel | 9 — Amarillo (vigilancia) |
| Estado | Evaluado |
| Dueño | M63 (Cargas y Streaming) |
| Mitigación | Streaming asíncrono, precarga, indicadores de progreso (regla 8 de AGENTS.md) |
| Contingencia | — (zona amarilla) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado; validar con el prototipo M137 |

### [R-05] — Madurez limitada de Voxel Tools para Godot 4.x (TEC-05)

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Limitaciones o bugs del addon bloquean features planificadas |
| Probabilidad | 2 |
| Impacto | 4 |
| Nivel | 8 — Amarillo |
| Estado | Monitoreado |
| Dueño | M08/M165 (Voxel Tools Guía) + M137 (validación) |
| Mitigación | Featureset mínimo verificado en el prototipo (M137); guía de errores conocidos (M165); fallback a meshes manuales |
| Contingencia | Sustituir el feature afectado por alternativa de meshes/bloques propios |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: núcleo validado en desktop (M08/M09/M10 ✅, guía M165 con errores conocidos); la limitación web se registra aparte como R-16 |

### [R-06] — Scope creep (ALC-01)

| Campo | Valor |
|---|---|
| Categoría | Alcance (ALC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Ideas nuevas a mitad de hito que amplían el alcance sin reevaluar el plan |
| Probabilidad | 4 |
| Impacto | 3 |
| Nivel | 12 — Naranja |
| Estado | Mitigándose |
| Dueño | M136 (Roadmap) + `DOCUMENTACION/5-FUTURAS-MEJORAS.md` |
| Mitigación | MoSCoW por hito; ideas "Could/Won't" derivadas a FUTURAS-MEJORAS; proceso de cambio de alcance (M133 `guia-hitos.md` §5); no tocar flujos estables (regla 16) |
| Contingencia | Congelar features del hito en curso y mover lo nuevo al siguiente |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: procedimiento operativo implementado en M133 (guia-hitos §5); el anotador de FUTURAS-MEJORAS sigue siendo el destino de ideas nuevas |

### [R-07] — Hitos deslizantes por estimaciones optimistas (ALC-02)

| Campo | Valor |
|---|---|
| Categoría | Alcance (ALC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Los hitos del prototipo se atrasan por estimaciones optimistas |
| Probabilidad | 3 |
| Impacto | 3 |
| Nivel | 9 — Amarillo |
| Estado | Monitoreado |
| Dueño | M136 + M133 (bloques de trabajo con capacidad real) |
| Mitigación | Estimaciones conservadoras, margen de holgura 20 %, métricas de bloque con 0 liberaciones 2 semanas seguidas (M133 `guia-sprints.md` §5) |
| Contingencia | Recortar alcance del hito (proceso M133 guia-hitos §5) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: sin fechas de hito formales aún (pendiente M136/fundador); el riesgo se materializará en la primera planificación si no hay holgura |

### [R-08] — Unicidad de conocimiento del fundador (EQU-01)

| Campo | Valor |
|---|---|
| Categoría | Equipo (EQU) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Solo el fundador conoce detalles clave del proyecto |
| Probabilidad | 3 |
| Impacto | 4 |
| Nivel | 12 — Naranja |
| Estado | Mitigándose |
| Dueño | Fundador + todos los agentes (regla de documentación) |
| Mitigación | Documentación continua (AGENTS.md §13, DOCUMENTACION/), README de onboarding de M133, backups M107 |
| Contingencia | Reconstrucción desde DOCUMENTACION/ + git (probada: agentes retoman módulos 🟡 sin el fundador) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: mitigación operativa (200+ módulos documentados; onboarding M133 implementado; continuidad probada en la práctica con retomas multiagente) |

### [R-09] — Dependencia de un proveedor/herramienta única (EQU-02)

| Campo | Valor |
|---|---|
| Categoría | Equipo (EQU) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Caída o cambio de condiciones de un único proveedor de IA o herramienta |
| Probabilidad | 2 |
| Impacto | 4 |
| Nivel | 8 — Amarillo |
| Estado | Monitoreado |
| Dueño | Fundador |
| Mitigación | Multiplicidad de plataformas/modelos (8+ en uso), herramientas todas gratuitas y estándar (Godot, git, Blender), workflow versionado en git |
| Contingencia | Redistribuir tareas a otro proveedor/plataforma; todo el estado vive en el repo, no en el proveedor |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: multiplicidad real verificada (Cline, OpenCode, VS Code, Kilo, Antigravity coexistiendo) |

### [R-10] — Burn-out del fundador (BUR-01)

| Campo | Valor |
|---|---|
| Categoría | Burn-out (BUR) |
| Identificado | 2026-08-17, Fundador |
| Descripción | Jornadas largas y presión sostenida pueden llevar al agotamiento del fundador único |
| Probabilidad | 3 |
| Impacto | 5 |
| Nivel | 15 — Naranja |
| Estado | Monitoreado |
| Dueño | Fundador (decisión exclusiva de prioridades; no delegable) |
| Mitigación | Jornadas acotadas, pausas, plan anti-abandono (M133 README §6), variable "energía" en retrospectivas; las prioridades de salud las registra el propio fundador en la revisión trimestral |
| Contingencia | Parar el proyecto temporalmente y preservar el estado (backups M107); la documentación permite retomar sin costo |
| Próxima revisión | 2026-11-28 (o antes, a solicitud del fundador) |
| Historial | 2026-08-17: registrado; prioridades de mitigación son decisión del fundador. 2026-08-28: sin cambios; se recuerda el regla anti-maratón del README de M133 |

### [R-11] — Agotamiento de reservas antes del lanzamiento (FIN-01)

| Campo | Valor |
|---|---|
| Categoría | Financiamiento (FIN) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | El dinero se agota antes de completar el desarrollo |
| Probabilidad | 3 |
| Impacto | 4 |
| Nivel | 12 — Naranja |
| Estado | Monitoreado |
| Dueño | Fundador + M134 (Presupuesto) |
| Mitigación | Modo costo cero vigente (M134: USD 0/mes, único gasto Steam fee USD 100); presupuesto mensual y fondo de reserva si llega financiamiento; hitos con retorno parcial |
| Contingencia | Recorte de alcance (M136/M133) antes que endeudarse; escenario de salida ordenada (M134 `revenue-projections.md` §8) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: M134 implementado — en modo costo cero no hay quema de reservas monetarias; el riesgo vigente es de costo de oportunidad/situación personal del fundador; recalibrar si se activa el escenario financiado |

### [R-12] — Costos imprevistos (FIN-02)

| Campo | Valor |
|---|---|
| Categoría | Financiamiento (FIN) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Gastos no planificados (assets, herramientas, hardware) |
| Probabilidad | 2 |
| Impacto | 3 |
| Nivel | 6 — Amarillo |
| Estado | Monitoreado |
| Dueño | M134 (Presupuesto) |
| Mitigación | Reserva de imprevistos (mín 11 % / objetivo 20 %), registro de gastos append-only, alertas (M134 `expense-tracking.md` §6), go/no-go financiero por milestone |
| Contingencia | Uso de reserva con registro + decisión del fundador (trigger en M134 `revenue-projections.md` §8) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: mecanismos implementados en M134 (operativa completa) |

### [R-13] — Resultado comercial flojo del nicho cozy (MER-01)

| Campo | Valor |
|---|---|
| Categoría | Mercado (MER) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Ventas por debajo del mínimo esperado en la plataforma elegida |
| Probabilidad | 3 |
| Impacto | 3 |
| Nivel | 9 — Amarillo |
| Estado | Monitoreado |
| Dueño | M99 (Marketing) + M97 (Store Page) + M136 |
| Mitigación | Demo temprana, wishlist campaign, comunidad desde M137; escenarios conservadores ya calculados (M134 `revenue-projections.md` §3) |
| Contingencia | En modo costo cero el proyecto sobrevive comercialmente flojo; recortar inversión prevista post-lanzamiento |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: M134 cuantificó el riesgo (break-even ≈7 copias en modo actual) |

### [R-14] — Deprecación de plataforma/engine (MER-02)

| Campo | Valor |
|---|---|
| Categoría | Mercado (MER) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Godot o la plataforma objetivo cambian de forma incompatible |
| Probabilidad | 1 |
| Impacto | 4 |
| Nivel | 4 — Verde (aceptación) |
| Estado | Monitoreado |
| Dueño | M04 (Game Engine) |
| Mitigación | Godot 4.7.2 fijado y documentado; exportabilidad multi-plataforma |
| Contingencia | — (zona verde; reevaluar si Godot anuncia breaking changes mayores) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: sin cambios |

### [R-15] — Assets de terceros con licencias no verificadas (ALC-03)

| Campo | Valor |
|---|---|
| Categoría | Alcance (ALC) |
| Identificado | 2026-08-17, Fundador/Deepseek |
| Descripción | Assets integrados sin auditoría de licencia generan riesgo legal |
| Probabilidad | 2 |
| Impacto | 3 |
| Nivel | 6 — Amarillo |
| Estado | Monitoreado |
| Dueño | M78 (Legal/PI) + M131 (Créditos) |
| Mitigación | Auditoría de licencias (M78), registro de créditos (M131), regla de skills auditadas antes de ejecutar scripts (AGENTS.md §27) |
| Contingencia | Retirar/reemplazar el asset no verificado antes de builds públicas |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-17: identificado. 2026-08-28: sin integraciones de assets de terceros aún; riesgo activará al entrar producción de assets (M45+) |

### [R-16] — Build web sin soporte del addon voxel (TEC-06) — riesgo nuevo detectado

| Campo | Valor |
|---|---|
| Categoría | Técnicos (TEC) |
| Identificado | 2026-08-25, ox-alpha (hallazgo verificado con Playwright; tema `Mensajes entre modelos/04-Voxel-Sin-Soporte-Web/`) |
| Descripción | El addon zylann.voxel no tiene binarios wasm32: en build web `main_isla.gd` falla al parsear y el gameplay (WASD) muere; desktop sin afectación |
| Probabilidad | 3 |
| Impacto | 3 |
| Nivel | 9 — Amarillo |
| Estado | Evaluado |
| Dueño | M04/M08 (voxel) + M96 (Plataformas; web no es plataforma objetivo v1) |
| Mitigación | v1 apunta a Steam+Deck (M96 oleada P0, web fuera de alcance); validar el build web solo después de que el addon ofrezca wasm32 o se defina alternativa |
| Contingencia | Si se decide distribución web: modo preview sin gameplay o implementación de terreno propio sin el addon (decisión de producto, fundador) |
| Próxima revisión | 2026-11-28 |
| Historial | 2026-08-25: hallazgo documentado por ox-alpha. 2026-08-28: incorporado al registro como R-16 (primer riesgo nuevo detectado tras la documentación inicial; demuestra el flujo de detección del módulo) |

---

## Registro de revisiones

| Fecha | Tipo | Participantes | Resultado |
|---|---|---|---|
| 2026-08-28 | Revisión inicial en papel (implementación del módulo) | GLM (Kilo) | 15 riesgos iniciales cargados con verificación de evidencia real + R-16 incorporado por hallazgo 2026-08-25. Cero en zona roja. Primera revisión trimestral formal pendiente del fundador |

## Reglas operativas (recordatorio)

1. El nivel y las zonas se recalculan en cada revisión trimestral (guía `GUIA-REVISION-TRIMESTRAL.md`).
2. Riesgo ≥ 17 → plan de contingencia escrito **antes de cerrar la revisión**.
3. Riesgo materializado → activar contingencia + registrar fecha, síntomas y consecuencias en el historial de la entrada.
4. El historial es append-only (nunca borrar entradas de historial previas).
5. Escalamiento a M133/M136: todo riesgo que amenace un hito se reporta en el acta/reporte correspondiente.

**Firma del último agente que modificó este registro:**

**Modelo:** GLM
**Plataforma:** Kilo
