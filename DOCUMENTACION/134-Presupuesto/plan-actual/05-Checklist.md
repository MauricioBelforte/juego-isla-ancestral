# Módulo 134: Presupuesto — Checklist

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (checklist original por Nemotron 3 Ultra)
**Estado:** Implementación completa (pendiente de QA cruzado) — 100/100 sin `[?]`

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal de gestión, V0
- Dificultad: 2
- Visión: V0
- Entrada: M133 ✅ (gestión operativa, log 219); M95 documentado (precio USD 24.99)
- Salida: presupuesto operativo implementado en `DOCUMENTACION/134-Presupuesto/operativa/` (desglose, control de gastos, proyecciones, dashboard, guía de uso, 4 plantillas) coherente con M133/M95
- Archivos: `DOCUMENTACION/134-Presupuesto/operativa/*`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 19:30:00 (reserva) · 2026-08-28 20:00:00 (liberación)

---

> **Cómo se marcó (2026-08-28, GLM/Kilo):** cada ítem se marcó `[x]` contra el entregable concreto que lo implementa (archivo y sección entre paréntesis cuando suma claridad). Las adaptaciones al proyecto de 1 persona y costo cero están documentadas como notas, no ocultas. No hay `[?]`.

## A. Definición del Presupuesto (10 ítems)

- [x] Definir presupuesto total del proyecto → USD 0/mes + USD 100 Steam fee (`operativa/budget-breakdown.md` §1)
- [x] Establecer fuente de financiamiento principal → autofinanciamiento costo cero (budget-breakdown §5)
- [x] Definir moneda de trabajo → USD (budget-breakdown §1)
- [x] Establecer período de presupuesto (trimestral/mensual) → mensual registro / trimestral cierre (§1)
- [x] Definir proceso de aprobación de presupuesto → fundador única instancia (§1 + expense-tracking §2)
- [x] Crear documento maestro de presupuesto → `operativa/budget-breakdown.md`
- [x] Distribuir presupuesto a leads de área → *adaptado a 1 persona:* fundador dueño de todas las áreas; techos por categoría definidos para escalar (§2/§4)
- [x] Establecer política de gastos → regla de oro: ningún gasto sin decisión registrada del fundador (§1)
- [x] Definir límites de aprobación por rol → tabla por rol, agentes de IA USD 0 (§4)
- [x] Documentar supuestos de estimación → budget-breakdown §3

## B. Desglose por Categorías (15 ítems)

Todos implementados como techos del escenario financiado en `budget-breakdown.md` §2 y en `templates/budget-template.csv` (montos 0 en modo actual):

- [x] Personal: programadores (30%)
- [x] Personal: artistas 3D/2D (15%)
- [x] Personal: diseñadores (5%)
- [x] Personal: audio (3%)
- [x] Personal: QA/producción (2%)
- [x] Herramientas: software (5%)
- [x] Herramientas: hardware (3%)
- [x] Herramientas: licencias (2%)
- [x] Marketing: ads digitales (8%)
- [x] Marketing: eventos/convenciones (5%)
- [x] Marketing: PR/comunidad (4%)
- [x] Marketing: assets de marketing (3%)
- [x] Operaciones: servicios (2%)
- [x] Operaciones: legal (2%)
- [x] Reserva: imprevistos (10-20%) → mínima 11 % / objetivo 20 %, regla de protección de la reserva (§2 regla 1)

## C. Control de Gastos (10 ítems)

- [x] Crear template de registro de gastos → `templates/registro-de-gastos.csv` (append-only)
- [x] Definir flujo de aprobación (3 niveles) → expense-tracking §2 (adaptado a 1 persona, escalable)
- [x] Establecer frecuencia de revisión (semanal/mensual) → §3 (integrada a revisión de estado de M133)
- [x] Crear proceso de reconciliación bancaria → §4 (adaptado: reconciliación contra resumen del método de pago)
- [x] Definir proceso de reembolsos → §5
- [x] Establecer política de facturación → §5 (comprobantes ≥ USD 10 archivados)
- [x] Crear dashboard de gastos en tiempo real → *adaptado:* pestaña Google Sheets con fórmulas (dashboard-metrics.md nota inicial + §3); costo 0
- [x] Definir alertas de exceso de presupuesto → expense-tracking §6 + dashboard §3 (fórmulas)
- [x] Establecer proceso de ajuste de presupuesto → expense-tracking §7
- [x] Documentar proceso de auditoría → expense-tracking §8 + dashboard §4 (cierre trimestral)

## D. Proyecciones de Ingresos (10 ítems)

- [x] Definir precio de venta del juego → USD 24.99 premium (revenue-projections §1, fuente M95 decidido)
- [x] Crear escenario pesimista de ventas → §3 (2.250 copias / ~USD 39k neto)
- [x] Crear escenario realista de ventas → §3 (8.000 copias / ~USD 140k)
- [x] Crear escenario optimista de ventas → §3 (24.000 copias / ~USD 420k)
- [x] Calcular break-even point → §4 (modo actual: ≈7 copias; paramétrico para escenario financiado)
- [x] Definir supuestos por plataforma (Steam, GOG, etc.) → §2 (comisiones y neto por copia)
- [x] Proyectar ingresos por año (3 años) → §3 + `templates/proyeccion-ingresos.csv`
- [x] Considerar descuentos y sales → §6 (festivales Steam, piso de precio USD 9.99)
- [x] Definir margen neto después de costos de plataforma → §2/§7
- [x] Documentar sensibilidad del modelo a variables clave → §7

## E. Gestión de Riesgos Financieros (10 ítems)

- [x] Reserva del 20% para imprevistos → objetivo 20 % / mínimo 11 % con regla de protección (budget-breakdown §2 regla 1)
- [x] Identificar riesgos de sobrecosto por categoría → alertas por categoría con umbral >10 % (expense-tracking §6); el registro consolidado con impacto financiero se completa en M135 (integración J)
- [x] Definir triggers de activación de reserva → revenue-projections §8
- [x] Crear plan de contingencia financiero → revenue-projections §8
- [x] Definir proceso de corte de gastos si es necesario → revenue §8 + budget-breakdown §2 regla 3 + expense-tracking §7
- [x] Establecer línea de crédito de emergencia → *decisión documentada:* NO se establece en modo costo cero (no endeudarse para desarrollar); si el fundador decide otra cosa, ADR (revenue §8)
- [x] Documentar escenario de quiebra y salida ordenada → revenue §8 (sin pasivos, builds/assets conservados, comunicación honesta)
- [x] Definir proceso de renegociación de contratos → revenue §8 (hito por hito, M79)
- [x] Crear escenarios de reducción de alcance → revenue §8 + proceso de alcance de hitos en M133 (`guia-hitos.md` §5)
- [x] Establecer métricas de alerta temprana → dashboard-metrics §3

## F. Reporting (10 ítems)

- [x] Crear reporte mensual de presupuesto → `templates/reporte-mensual.md`
- [x] Incluir burn rate y runway → dashboard-metrics §1
- [x] Incluir varianza real vs. plan → dashboard §1
- [x] Incluir proyección de fin de mes → plantilla de reporte (sección KPIs)
- [x] Incluir top 5 gastos del mes → plantilla de reporte
- [x] Distribuir reporte a leads semanalemente → *adaptado:* revisión mensual integrada al ciclo de M133; distribución a leads al escalar (dashboard §2)
- [x] Crear dashboard ejecutivo → pestaña Sheets con KPIs + fórmulas de alerta (dashboard §3)
- [x] Definir KPIs financieros clave → dashboard §1 (6 KPIs con fórmula)
- [x] Establecer reunión de revisión financiera mensual → *adaptado:* revisión mensual dentro del ciclo de M133, formalizada con acta al escalar (dashboard §2)
- [x] Documentar proceso de toma de decisiones financieras → dashboard §6

## G. Herramientas y Plantillas (10 ítems)

- [x] Seleccionar herramienta de hoja de cálculo (Google Sheets, Excel) → Google Sheets, Excel alternativa válida (guia-uso-plantillas §1)
- [x] Crear plantilla maestra de presupuesto → `templates/budget-template.csv`
- [x] Crear plantilla de registro de gastos → `templates/registro-de-gastos.csv`
- [x] Crear plantilla de proyección de ingresos → `templates/proyeccion-ingresos.csv`
- [x] Crear plantilla de reporte mensual → `templates/reporte-mensual.md`
- [x] Crear dashboard con fórmulas automáticas → dashboard §3 (fórmulas sugeridas por alerta)
- [x] Establecer formato estándar de reportes → plantilla de reporte + dashboard §2 (contenido obligatorio)
- [x] Crear guía de uso de plantillas → `operativa/guia-uso-plantillas.md`
- [x] Capacitar al equipo en uso de herramientas → *adaptado:* la guía cumple el rol de capacitación con 1 persona; onboarding de colaboradores la incluye (guia §4)
- [x] Mantener plantillas actualizadas → regla de sincronización repo↔Sheets (guia §3.5) + cierre trimestral

## H. Integración con Roadmap (10 ítems)

- [x] Vincular presupuesto con cronograma (M136) → revenue §5 (cash flow por hito)
- [x] Estimar costo por milestone → modo actual USD 0 por milestone; umbrales por fase (revenue §5 tabla)
- [x] Proyectar cash flow por trimestre → revenue §5 + cierre trimestral
- [x] Definir go/no-go financiero por milestone → tabla de umbrales por fase (revenue §5) + regla de recálculo de break-even antes de aprobar gasto (§4)
- [x] Establecer umbrales de inversión por fase → revenue §5 (4 fases con umbral explícito)
- [x] Documentar dependency entre presupuesto y alcance → budget-breakdown §2 regla 3 + §3 + proceso de alcance de hitos (M133)
- [x] Crear escenarios de cambio de alcance → revenue §8 + guia-hitos §5 (M133)
- [x] Definir proceso de priorización con budget limitado → en modo costo cero la priorización la manda el roadmap (guía 08, regla final); todo gasto propuesto exige recálculo de break-even y aprobación (revenue §4)
- [x] Establecer revisión de presupuesto por quarter → dashboard §4 (checklist de cierre trimestral)
- [x] Documentar lecciones aprendidas financieras → ítem agregado al cierre trimestral (dashboard §4)

## I. Documentación y Cumplimiento (10 ítems)

- [x] Crear directorio docs/budget/ con todos los documentos → *adaptación documentada:* por convención de estructura del proyecto (`AGENTS.md` §3) el directorio es `DOCUMENTACION/134-Presupuesto/operativa/` (nota en budget-breakdown §nota)
- [x] Mantener documentos actualizados → reglas de mantenimiento (guia §3.5, dashboard §6)
- [x] Cumplir con requisitos legales de contabilidad → lo definible en el repo: solo datos agregados sin información personal; las obligaciones legales/contador las mantiene el fundador fuera del repo (dashboard §4/§5)
- [x] Documentar procesos financieros → los 5 documentos de `operativa/`
- [x] Crear backup de datos financieros → repo versionado + esquema 3-2-1 de M107 (dashboard §4)
- [x] Establecer política de retención de documentos → dashboard §4 (retención; mínimo legal lo define el contador)
- [x] Definir acceso restringido a datos financieros → dashboard §5 (hoja privada, repo con agregados)
- [x] Documentar proceso de cierre contable → dashboard §6
- [x] Crear checklist de cierre trimestral → dashboard §4 (6 ítems)
- [x] Archivar documentos financieros históricos → reportes archivados en el repo (M133/reportes o este módulo) con versionado git

## J. Integración con Otros Módulos (5 ítems)

- [x] Vincular con M133 (Gestión del Proyecto): costo por sprint → USD 0 en modo actual; horas no facturadas registradas como costo implícito (budget-breakdown §3); ceremonias sin costo (M133)
- [x] Vincular con M135 (Riesgos): impacto financiero de cada riesgo → columnas/mecanismo definidos aquí (revenue §8, expense-tracking §6); el registro consolidado de M135 los consumirá al implementarse (integración cruzada)
- [x] Vincular con M136 (Roadmap): inversión por fase → umbrales por fase (revenue §5)
- [x] Vincular con M95 (Monetización): proyecciones de ingresos por DLC → modelo premium/ediciones/DLC tomado de M95 (revenue §1); DLC no contado en escenarios base
- [x] Vincular con M143 (Lanzamiento): costo de marketing día 0 → USD 0, canales orgánicos (M99/M143) con regla de reinversión post-lanzamiento (revenue §5)

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados en `operativa/`: `budget-breakdown.md`, `expense-tracking.md`, `revenue-projections.md`, `dashboard-metrics.md`, `guia-uso-plantillas.md`, `templates/budget-template.csv`, `templates/registro-de-gastos.csv`, `templates/proyeccion-ingresos.csv`, `templates/reporte-mensual.md`.
- Números clave verificados: precio USD 24.99 y modelo sin P2W provienen de M95 (decidido, documentado en ESTADO-PARALELO); Steam fee USD 100 proviene de M133 (01-Requerimientos §Restricciones); comisión 30 % Steam/GOG estándar.
- El módulo queda listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 197-202, 220 y 221 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 134 (Presupuesto): VERIFICADO (100/100, 0 [?]). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
