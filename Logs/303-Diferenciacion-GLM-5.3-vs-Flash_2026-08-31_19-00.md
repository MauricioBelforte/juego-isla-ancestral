**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# Log 303: Diferenciación GLM-5.3 vs GLM-5.3-Flash

**Fecha:** 2026-08-31
**Hora:** 19:00

## Resumen
Se diferenciaron GLM-5.3 (flagship) de GLM-5.3-Flash (multimodal económico) en la guía comparativa y CHECKLIST-GLOBAL. Cada modelo tiene módulos asignados según su caso de uso.

## Cambios Realizados

### Guía 10 — Diferenciación de modelos
- **Sección C:** GLM-5.3 separado como "Flagship Texto" — 743B params, solo texto, $1.40/$4.40 por 1M tokens
- **Sección C2:** GLM-5.3-Flash agregado como "Multimodal Económico" — 320B/18B activos, multimodal nativo (texto+imagen+video), $0.07-$0.15/$0.25-$0.50 por 1M tokens, MIT license
- **Matriz comparativa real:** GLM-5.3 y GLM-5.3-Flash separados con specs distintas
- **Capacidades por tipo de trabajo:** GLM-5.3 para verificación crítica, GLM-5.3 Flash para scripts/documentación/batch/QA visual
- **Flujo de delegación:** GLM-5.3 Flash agregado como paso 4 (scripts diarios, documentación, batch)
- **Reglas de asignación:** GLM-5.3 para core (complejidad 4-5), GLM-5.3 Flash para sistemas (complejidad 1-3)

### CHECKLIST-GLOBAL — Asignación de módulos
- **GLM-5.3 (9 módulos):** M13 Herramientas, M14 Inventario, M15 Recursos, M16 Crafting, M21 Diálogos, M22 Historia Principal, M24 Templos, M29 Tiempo, M59 Guardado — todos core/con densidad de lógica
- **GLM-5.3 Flash (44 módulos):** documentación, sistemas auxiliares, batch, scripts — donde el costo y la velocidad importan más

## Diferencias Clave Documentadas

| | GLM-5.3 | GLM-5.3 Flash |
|---|---|---|
| Params | 743B (texto puro) | 320B/18B activos (MoE) |
| Multimodal | ❌ Solo texto | ✅ Texto+imagen+video |
| Precio input | $1.40/1M | $0.07-$0.15/1M |
| Precio output | $4.40/1M | $0.25-$0.50/1M |
| Pesos | No publicados | ✅ MIT HuggingFace |
| Uso | Verificación crítica, arquitectura | Scripts, doc, batch, QA visual |

## Archivos Modificados
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — secciones C/C2, matriz, capacidades, flujo delegación
- `CHECKLIST-GLOBAL.md` — 53 módulos reasignados (9 GLM-5.3, 44 GLM-5.3 Flash)
