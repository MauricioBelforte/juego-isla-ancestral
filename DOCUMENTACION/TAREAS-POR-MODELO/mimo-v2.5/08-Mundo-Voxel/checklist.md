**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Módulo:** 08-Mundo-Voxel
**Estado:** ✅ Completado (105/105)
**Prioridad:** — (bugs pendientes)

# M08 — Mundo Voxel: Checklist MiMo V2.5 (Bugs)

## Reserva actual
- **Estado:** 🔵 Reservado (bugs)
- **Fecha:** 2026-09-02
- **Log:** pendiente

## Bugs asignados

### BUG-019: Chunks de terreno no visibles desde lejos
- [ ] T-08-BUG-019-001: Investigar por qué chunks de terreno no se ven desde lejos pero sí objetos/vegetación [C]
- [ ] T-08-BUG-019-002: Revisar configuración de LOD en island_generator.gd [M]
- [ ] T-08-BUG-019-003: Verificar distancia de renderizado de VoxelViewer [M]
- [ ] T-08-BUG-019-004: Comparar con configuración de M167-Isla-Raíz [M]
- [ ] T-08-BUG-019-005: Documentar causa raíz y solución [S]
- [ ] T-08-BUG-019-006: Capturar evidencia antes/después [S]

### BUG-020: Palmeras posicionadas sobre el agua
- [ ] T-08-BUG-020-001: Investigar por qué palmeras se posicionan sobre agua [C]
- [ ] T-08-BUG-020-002: Revisar lógica de posicionamiento de vegetación en island_generator.gd [M]
- [ ] T-08-BUG-020-003: Verificar que vegetación solo aparezca en tierra firme [M]
- [ ] T-08-BUG-020-004: Documentar causa raíz y solución [S]
- [ ] T-08-BUG-020-005: Capturar evidencia antes/después [S]

## Completados esta sesión
_(ninguno aún)_

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02
**Estado:** Inicio de backlog

### Lo que voy a hacer
- Investigar BUG-019 y BUG-020 — ambos relacionados con generación procedural
- Revisar island_generator.gd y configuración de VoxelViewer
- Comparar con M167-Isla-Raíz (referencia)

### Lo que NO puedo hacer todavía
- Fixes de rendering requieren testing visual con V4
- Cambios en vegetación pueden afectar rendimiento

### Recomendaciones para el próximo agente
- BUG-019 probablemente es configuración de LOD o distancia de renderizado
- BUG-020 probablemente es lógica de raycast para posicionamiento
- Siempre comparar con M167-Isla-Raíz como referencia
