# Log 127 — Revisión del plan inicial vs módulos implementados

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23 03:31:00

## Descripción breve de la modificación

Se realizó una auditoría comparativa entre `DOCUMENTACION/00-PLAN-INICIAL/` (Plan-inicial-minimo.md con sus 152 secciones, IDEA-BASE-DEL-JUEGO.md e HISTORIA-DEL-JUEGO.md) y los módulos existentes en `DOCUMENTACION/` + `CHECKLIST-GLOBAL.md`, para detectar conceptos definidos al comienzo que quedaron sin módulo o sin integración.

## Hallazgos

### 1. Falta el módulo 130 — ARTBOOK (plan maestro sección #129)
- El plan maestro tiene la sección `# 129. ARTBOOK` pero **no existe** ni la carpeta `DOCUMENTACION/130-Artbook/` ni una fila en `CHECKLIST-GLOBAL.md` (la tabla salta de ID 129 a ID 131).
- Nota: el índice del M01 (Fundamentos) lo lista como pendiente ("M129 Artbook" con numeración vieja), y `129-Merchandising` absorbió una subsección de artbook dentro de su checklist, pero el módulo dedicado con sus 5 archivos obligatorios nunca se creó.

### 2. Pases de Mérito (moneda secundaria) no integrados en M38 Economía
- La IDEA-BASE y el Plan-de-producción definen la **economía doble**: Gemas de Ámbar (principal) + Pases de Mérito (secundaria, por tareas diarias).
- M02 (Visión y Concepto) y M01 (Fundamentos) sí lo documentan.
- Búsqueda en `DOCUMENTACION/38-Economia/`: **0 resultados** para "mérito" / "moneda secundaria". El módulo de economía solo cubre Gemas de Ámbar; la segunda moneda quedó sin especificación en el módulo dueño.

### 3. Conceptos verificados como CUBIERTOS
- Buceo/submarino: M11 (aire de buceo), M67 (preset submarino), M75 (zonas submarinas postgame), M27 (isla submarina), M41 (música submarina). ✔
- Gran Vapor / boletos / viajes mensuales: M28, M69, M157. ✔
- Finneas / hipotecas / infraestructura: M40. ✔
- Sellos, templos, ruinas, Elysia: M22, M24, M25, M26, M147, M148. ✔
- Herramientas de aventura (Gancho, Lanza-Semillas, Varas de Flujo): M13. ✔
- Vecinos, amistad, diálogos: M19, M20, M21. ✔

### 4. Inconsistencias menores detectadas en CHECKLIST-GLOBAL.md
- "Resumen del Proyecto" dice "Total de módulos: 156", pero la tabla tiene 158 filas (IDs 01–159 sin el 130). Desactualizado.
- M81 (Legal — Menores) está `🔵 En curso` por NEMOTRON 3 ULTRA desde 2026-08-21 21:00 con progreso 0/110 → más de 24 h sin actividad; según regla 21.4.7 puede ser reclamado por otro agente.

## Código original / nuevo
No se modificó código ni documentación existente. Este log registra solo la auditoría.

## Recomendaciones
1. Crear `DOCUMENTACION/130-Artbook/` (plan-inicial + plan-actual, 5 archivos, checklist ≥100 ítems) y agregar la fila al CHECKLIST-GLOBAL.md.
2. Integrar los Pases de Mérito en M38 Economía (wallet doble, fuentes, sumideros, anti-exploit) y verificar coherencia con M71 Progresión y M74 Eventos (tareas diarias).
3. Actualizar el "Resumen del Proyecto" del CHECKLIST-GLOBAL.md.
4. Reclamar o liberar M81 según regla 21.4.7.