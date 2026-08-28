**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 134-Presupuesto
**Estado:** Implementación operativa (entregable M134)

---

# Desglose del Presupuesto (`budget-breakdown`) — Módulo 134

> **Nota de adaptación:** la especificación original ubicaba estos documentos en `docs/budget/`; por la convención de estructura del proyecto (`AGENTS.md` §3, la raíz no aloja carpetas de documentación), el directorio real es `DOCUMENTACION/134-Presupuesto/operativa/`.

## 1. Modo vigente (presupuesto real del proyecto)

| Concepto | Valor |
|---|---|
| Presupuesto total actual | **USD 0/mes** (desarrollo autofinanciado, costo cero) |
| Fuerza de trabajo | 1 fundador + agentes de IA (sin salarios) |
| Único desembolso previsto confirmado | **USD 100** — Steam Direct Fee (una vez, antes de publicar la página) |
| Herramientas | 100 % gratuitas: Godot 4.7.2, GDScript, git+GitHub, GitHub Projects (pendiente ADR-0002), Google Sheets, Blender |
| Moneda de trabajo | **USD** (los registros internos pueden anotar la moneda local del fundador en la columna Notas) |
| Período de presupuesto | Mensual (registro) · trimestral (revisión y cierre, item I) |
| Aprobación de presupuesto | **Fundador** (única instancia en modo actual) |

**Regla de política de gastos (modo vigente):** ningún gasto se realiza sin decisión explícita y registrada del fundador. Cualquier gasto nuevo se registra en `templates/registro-de-gastos.csv` (o su copia en Google Sheets) el mismo día y se menciona en el reporte mensual.

## 2. Escenario de referencia con financiamiento (techos por categoría)

Los porcentajes son **techos** de asignación sobre el subtotal de gastos si el proyecto llega a recibir financiamiento (patrocinio, fondos, editorial o ingresos). No son un compromiso de gasto.

| Categoría | Subcategoría | Techo |
|---|---|---|
| Personal | Programadores | 30 % |
| Personal | Artistas 3D/2D | 15 % |
| Personal | Diseñadores | 5 % |
| Personal | Audio | 3 % |
| Personal | QA / Producción | 2 % |
| Herramientas | Software | 5 % |
| Herramientas | Hardware | 3 % |
| Herramientas | Licencias | 2 % |
| Marketing | Ads digitales | 8 % |
| Marketing | Eventos/convenciones | 5 % |
| Marketing | PR/comunidad | 4 % |
| Marketing | Assets de marketing | 3 % |
| Operaciones | Servicios | 2 % |
| Operaciones | Legal | 2 % |
| **Subtotal gastos** | | **89 %** |
| **Reserva de imprevistos** | obligatoria | **11 % (mínimo) / 20 % (objetivo)** |

Reglas del escenario financiado:
1. La **reserva de imprevistos es obligatoria**: mínimo 11 % del total (para completar el 100 %) y objetivo 20 % (verificación de `revenue-projections.md` §break-even). Si el fondo disponible no alcanza para el 20 %, se recortan proporcionalmente los techos de Personal y Marketing, nunca la reserva.
2. Personal solo se contrata por hito definido (M136) con contrato firmado (M79); nunca de forma abierta.
3. Todo desvío >10 % de una categoría en un mes dispara el proceso de ajuste de `expense-tracking.md` §ajustes.

## 3. Supuestos de estimación

- El proyecto en modo actual **no consume dinero**: las horas del fundador y de agentes IA no se facturan; se registran como costo implícito (no monetario) en los reportes para no distorsionar el burn rate.
- Si se mide "costo equivalente" para tomar decisiones (¿vale la pena pagar X para ahorrar Y horas?), se hace por decisión explícita del fundador y se anota en el registro de gastos como `Nota analítica`, no como gasto.
- Las cifras del escenario financiado son paramétricas: la plantilla `templates/budget-template.csv` calcula totales al insertar montos; los montos de ejemplo del CSV son ilustrativos (marcados), no compromisos.
- Los impuestos y la moneda local del fundador quedan fuera de la contabilidad del repo (datos personales); los reportes trabajan solo con USD y categorías.
- Coherencia: herramientas gratuitas obligatorias (M133/RN3); monetización premium sin P2W (M95); costo de marketing día 0 orgánico (M99/M143) salvo decisión del fundador.

## 4. Límites de aprobación por rol (aplicables al escalar)

| Rol | Límite |
|---|---|
| Fundador | Sin límite (decide todo en modo actual) |
| Colaborador/lead (si existiera) | USD 0 — toda propuesta pasa por el fundador |
| Agente de IA | USD 0 — nunca autoriza ni realiza gastos |

## 5. Fuentes de financiamiento

| Fuente | Estado |
|---|---|
| Autofinanciamiento (costo cero) | **Vigente** |
| Ingresos del juego (premium M95) | Futuro (ver `revenue-projections.md`) |
| Editorial / patrocinio / fondos | Posible, decisión del fundador; no se planifica gasto contra dinero no recibido |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
