# Log 11 — Creación del Componente 08: Mundo Voxel

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Hora:** 02:50

## Descripción breve

Se documentó el **Módulo 08 — Mundo Voxel** en `DOCUMENTACION/08-Mundo-Voxel/` (riesgo técnico #1 del proyecto, complejidad 5). Se fijaron: voxel 1×1×1 m, chunk 16³, mundo Aurora 2048×2048 (−64 a +192), catálogo de ~30 bloques con propiedades, reglas de colocación/validación (protección de ruinas), mesh (face culling/greedy/LOD Transvoxel), agua con nivel, nieve estacional y persistencia por diffs.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 8 requisitos + criterios |
| `plan-inicial/02-Analisis.md` | 39 puntos del plan maestro resueltos; decisión Voxel Tools; riesgos |
| `plan-inicial/03-Diseno.md` | Constantes, catálogo de bloques, modelo BlockType, reglas de validación, mesh/luz/rendimiento, streaming/persistencia |
| `plan-inicial/04-Codigo.md` | Arquitectura de implementación, contratos, pendientes con dueño, Notas del Agente |
| `plan-inicial/05-Checklist.md` | **104 ítems**, 104 completados |
| `plan-actual/*` | Espejo vigente |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M08 → 🟢 Disponible, 104/104.
- `DOCUMENTACION/README.md`: componente 08 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 11.

## Decisiones

- Base del mundo: **Voxel Tools (Zylann)** (meshing, AO, LOD, streaming, colisiones ya optimizados en C++); encima: catálogo propio + validación + diffs.
- Persistencia por **diffs por chunk** + generación determinista por seed (nunca guardar el mundo entero).
- Agua con nivel de superficie (sin simulación pesada); congelación como cambio de tipo por Varas de Flujo (M24).
- Bloques puzzle con estado en entidad vinculada (nunca en el voxel).
- La validación física (greedy por tipo, radio óptimo) queda como entregable del hito M1 con medición real.