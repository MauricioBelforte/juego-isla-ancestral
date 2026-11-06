# RIEL-DOC-INTELLIGENCE-2.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06
**Estado:** Creado — pendiente de ejecución
**Nicho:** Document Intelligence — análisis de documentación para encontrar inconsistencias, drift y errores

## Propósito

Nemotron-3.5-Super-VL tiene **contexto de 1M tokens** y capacidad de **Document Intelligence** (tablas, gráficos, OCR). Este riel aprovecha esa capacidad para analizar documentación del proyecto, encontrar inconsistencias entre documentos, detectar drift (documentación que no coincide con el código), y verificar que los checklists reflejen la realidad del repositorio.

## Áreas de análisis

1. **Consistencia de checklists:** Verificar que los ítems marcados [x] en los `05-Checklist.md` correspondan realmente a archivos existentes y funcionales
2. **Drift de documentación:** Comparar `plan-inicial/` con `plan-actual/` para encontrar secciones desactualizadas
3. **Referencias rotas:** Buscar enlaces a archivos que ya no existen (como las referencias a `10-GUIA-COMPARATIVA-MODELOS.md` que se movieron a `GUIA-COMPARATIVA-MODELOS/`)
4. **Inconsistencias de módulos:** Comparar `CHECKLIST-GLOBAL.md` con los `05-Checklist.md` individuales para encontrar discrepancias en contadores
5. **Firmas faltantes:** Verificar que todos los documentos tengan firma de modelo y plataforma

## Itámes

- [ ] DOC-INT-01: Verificar que todos los ítems [x] en `05-Checklist.md` de módulos agotados tengan archivos existentes en disco
- [ ] DOC-INT-02: Comparar `plan-inicial/` vs `plan-actual/` de módulos clave para detectar drift
- [ ] DOC-INT-03: Buscar referencias rotas a `10-GUIA-COMPARATIVA-MODELOS.md` en todo el repositorio
- [ ] DOC-INT-04: Contrastar contadores de `CHECKLIST-GLOBAL.md` con conteos reales de `[x]` en checklists de módulos
- [ ] DOC-INT-05: Verificar que todos los documentos modificados tengan firma de modelo y plataforma
- [ ] DOC-INT-06: Analizar `GUIA-GODOT/06-registro-errores.md` para encontrar errores documentados sin solución
- [ ] DOC-INT-07: Verificar que los módulos marcados ✅ en `CHECKLIST-GLOBAL.md` tengan QA cruzado (§21.8) documentado
- [ ] DOC-INT-08: Revisar `AGENTS.md` para encontrar referencias a archivos movidos o eliminados

## Formato de reporte por ítem

Cada ítem debe producir:
1. Análisis del documento(s) relevante(s)
2. Hallazgos específicos con rutas de archivo y números de línea (L#)
3. Reporte en canal con: ítem, veredicto (OK/DRIFT/ERROR), evidencia (rutas), recomendación

## Reglas

- Usar contexto de 1M tokens: leer documentos completos, no solo secciones
- Citas textuales con L# para cada hallazgo
- No modificar archivos, solo reportar hallazgos
- UTF-8 sin BOM siempre

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06
