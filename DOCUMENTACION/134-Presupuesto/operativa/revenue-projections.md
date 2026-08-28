**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 134-Presupuesto
**Estado:** Implementación operativa (entregable M134)

---

# Proyecciones de Ingresos (`revenue-projections`) — Módulo 134

## 1. Modelo de venta (fuente: M95 Monetización)

| Parámetro | Valor | Fuente |
|---|---|---|
| Modelo | Premium, una compra, sin P2W/lootboxes | M95 (decidido) |
| Precio base | **USD 24.99** | M95 (decidido) |
| Ediciones | 3 (base / deluxe / bundle cosmético) sin fragmentar historia | M95 |
| DLC futuro | Expansión + cosmético post-lanzamiento | M95/M120 |

## 2. Supuestos por plataforma

| Plataforma | Comisión del store | Neto por copia (base, sin impuestos) |
|---|---|---|
| Steam | 30 % | ≈ USD 17.49 |
| GOG | 30 % | ≈ USD 17.49 |
| Steam Direct Fee | USD 100 (único costo fijo vigente) | — |

Supuestos conservadores: el volumen base se calcula al precio lleno; los descuentos (§6) reducen el neto promedio ~10-15 % y ya están descontados mentalmente de los escenarios (los números son aproximados por diseño, no promesas).

## 3. Escenarios de ventas (3 años)

| Escenario | Año 1 | Año 2 | Año 3 | Total copias | Ingreso neto acumulado aprox. |
|---|---|---|---|---|---|
| Pesimista | 1.500 | 500 | 250 | 2.250 | ≈ USD 39.000 |
| Realista | 5.000 | 2.000 | 1.000 | 8.000 | ≈ USD 140.000 |
| Optimista | 15.000 | 6.000 | 3.000 | 24.000 | ≈ USD 420.000 |

Base del cálculo: copias × USD 17.49 (Steam/GOG). No incluye ediciones deluxe, DLC ni impuestos personales del fundador (fuera del repo).

Supuestos de los escenarios:
- **Pesimista:** sin tracción de marketing, wishlist baja, reviews mixtas. El proyecto sigue sostenible por costo cero.
- **Realista:** campaña M99 estándar (devlogs, newsletter, wishlists 10k), reviews positivas.
- **Optimista:** fuerte tracción de comunidad/testers tempranos (M133 anti-abandono), featuring de plataforma.

## 4. Break-even (punto de equilibrio)

Fórmula: `copias_necesarias = costo_total / neto_por_copia`

| Modo | Costo total | Copias para break-even |
|---|---|---|
| **Modo actual (vigente)** | USD 100 (Steam fee) | **≈ 6 copias** (7 con margen) |
| Escenario financiado (paramétrico) | costo_total de `budget-template.csv` | costo_total / 17.49 |

Interpretación: en modo costo cero, el proyecto recupera su único desembolso con ~7 ventas. El break-even relevante para decisiones es el del escenario financiado: si algún gasto nuevo (ej:外包 de arte o audio) entra al presupuesto, se recalcula aquí **antes** de aprobarlo (regla de `expense-tracking.md` §2).

## 5. Proyección de cash flow (ligada a M136)

- Año 0 (hasta vertical slice/pre-alpha): entradas 0; salidas 0 (modo actual) o el cash flow negativo planificado del escenario financiado.
- Lanzamiento (M143): entrada principal del año 1 (primeros 2 meses ≈ 40-60 % de las ventas anuales en indie).
- Post-lanzamiento (M144): cola de ventas + DLC (M120). Los hitos de M136 marcan cuándo se evalúa cada inyección de presupuesto.

### Umbrales de inversión por fase (go/no-go financiero por milestone)

| Fase (M136/M133) | Umbral de inversión autorizado | Go/no-go financiero |
|---|---|---|
| Hasta M138 (vertical slice) | USD 0 (solo costo cero) | No se aprueba ningún gasto; si un hito lo exige, replantear alcance |
| Pre-RC / store page | Steam Direct Fee (USD 100, único gasto confirmado) | Aprobado por fundador; break-even ≈ 7 copias |
| RC → Lanzamiento (M143) | Marketing día 0: USD 0 (orgánico M99/M143); extras solo por decisión del fundador con break-even recalculado | Cada gasto propuesto recalcula break-even (§4) antes de aprobarse |
| Post-lanzamiento (M144/M120) | Reinversión desde ingresos netos, nunca por encima del 50 % del neto del mes | Revisión trimestral (`dashboard-metrics.md` §4) |

## 6. Descuentos y sales

- Participar en los festivales/seasonal sales de Steam (2-4 al año) con descuentos estándar (10 % / 20 % / 33 %); el precio nunca baja de USD 9.99 en promociones base (protege el valor y la confianza cozy).
- El bundle completo (juego + DLC) se descuenta combinando sus precios, no por debajo del piso.
- Cada sale se registra como evento del año en el reporte mensual para calibrar los escenarios.

## 7. Margen neto y sensibilidad

Variables a las que el modelo es más sensible (orden de impacto):
1. **Precio y comisión** (±USD 2 en precio ≈ ±11 % de ingresos).
2. **Volumen año 1** (duplicar wishlists → históricamente 5-10 % de conversión a lanzamiento).
3. **Proporción de ventas con descuento** (cada 10 % de copias vendidas a -50 % baja el neto promedio ~5 %).
4. **DLC/ediciones** (pueden añadir 10-25 % de ingreso según M95, no contados en los escenarios base).

Regla de decisión: cualquier cambio de precio o modelo pasa por M95 (dueño) y se refleja aquí recalculando break-even y escenarios.

## 8. Plan de contingencia financiero (resumen; detalle de riesgos en M135)

- **Si el proyecto necesita dinero y no lo tiene:** se recorta alcance (proceso de M136/M133), no se endeuda el fundador. **Decisión documentada: no se establece línea de crédito de emergencia en modo costo cero** (no endeudarse para desarrollar); si el fundador decide otra cosa, se registra por ADR.
- **Escenario de salida ordenada ("quiebra"):** sin empleados ni deuda, la salida es: publicar lo que exista como demo gratuita o no publicar; conservar builds, saves y assets (M107); comunicar el estado con honestidad a la comunidad (M99); liberar o conservar la propiedad intelectual según decida el fundador (M78). Sin pasivos pendientes más allá del Steam fee ya pagado.
- **Triggers de activación de reserva** (solo escenario financiado): gasto imprevisto > USD 100, oportunidad de contracto puntual de arte/audio, costo legal real (M79/M80).
- **Renegociación de contratos:** si existe un contrato activo y no hay fondos, se renegocia hito por hito (M79 §terminación) antes de usar reserva.
- **Métricas de alerta temprana:** en `dashboard-metrics.md`.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
