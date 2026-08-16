**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 13: Herramientas

## 1. Carácter del Componente

Módulo que **especifica el sistema de herramientas** (catálogo, durabilidad, contratos, mejora) a implementar en el prototipo del hito M1. No crea scripts todavía. Sin 06/07 aún (los tests de herramientas entran en M1: extracción, contratos, reparación).

## 2. Archivos involucrados (implementación prevista)

```
scripts/tools/tool.gd                 → Resource base (Tool)
scripts/tools/tool_item.gd            → instancia con durabilidad (M14 integra)
scripts/tools/tool_registry.gd        → catálogo estático (ServiceLocator M07)
scripts/tools/tool_actions.gd         → dispatch de acciones por herramienta
scripts/tools/tool_feedback.gd        → sonidos/partículas
data/tools/tool_catalog.tres          → tabla completa (9 × 4 niveles)
```

## 3. Contratos de integración

- **Entrada:** `ToolAction(input.pos, tool_id)` desde M11 (InteractionService + F/click).
- **Salida:** `ToolResult(ok, drop[], diff, feedback)` → M14 (inventario) y M08 (WorldPartition).
- **Consume:** catálogo de bloques M08, durabilidad por instancia M14, recursos M46.
- **Publica:** `tool_used(tool_id, pos)`, `tool_repair_request(id)` → EventBus (HUD e informes M71).
- **Persistencia:** `GameState.M13.tools: { id → {durability, level}}`.

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Ajuste fino de tiempos reales por bloque | Prototipo M1 (playtest) |
| Mini-juego de pesca (caña) | M35 (mecánica) |
| Martillo completo (rotación/pegado) | M17 (construcción) |
| Lupa: datos de inspección por objetivo | M26/M44 (contenido) |
| Sonidos/partículas finales | M65 (assets) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 05:30:00
**Estado:** Completado (especificación; implementación en M1/M17/M35)

### Lo que hice
- Resolví los 27 puntos de la sección 12 del plan maestro.
- Catálogo de 9 herramientas × 4 niveles con tabla de durabilidad y tiempos.
- Contrato de extracción/colocación con M08 (try_extract/try_place) verificado.
- Reglas cozy: reparación gratis con recursos, herramientas nunca desaparecen, martillo/lupa infinitos.
- Persistencia en GameState.M13 y progresión atada a M46 (cobre→hierro→oro→cristal).

### Lo que NO pude hacer (honestidad obligatoria)
- Balancear tiempos reales → playtest M1.
- Mini-juego de pesca → M35.
- Mecánica de construcción del martillo → M17.
- Contenido de la lupa → M26/M44.
- Assets finales → M65.

### Recomendaciones para el próximo agente
- Respetar el contrato try_extract/try_place (una sola escritura de diffs, M08).
- Nunca implementar rotura total de herramientas: es regla cozy roja del proyecto.
- La caña y la lupa son "herramientas de conocimiento": no gastan durabilidad (M35/M26).