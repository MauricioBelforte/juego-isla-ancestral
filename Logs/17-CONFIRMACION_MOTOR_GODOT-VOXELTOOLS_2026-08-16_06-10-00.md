# Log 17 — Confirmación del Motor: Godot 4.x + Voxel Tools + GDScript

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Hora:** 06:10

## Descripción breve

Por encargo explícito del usuario ("como vos tenes actualmente el mejor contexto te encargo esa tarea"), se cerró la **decisión final del motor** con investigación web fresca (2026). Resultado: **Godot 4.x + Voxel Tools (edición GDExtension) + GDScript**. No hay argumento objetivo para cambiar de motor; se descarta el "volantazo".

## Evidencia de la investigación (2026)

- Voxel Tools (Zylann): 3.839★, 5.015 commits, MIT, builds CI activos 2026, docs activas, Discord activo. Ediciones: Module (build custom) y **GDExtension** (addon sobre Godot oficial ≥ 4.4.1) — elimina el mayor dolor histórico de instalación.
- Funcionalidades cubiertas: Transvoxel, streaming por chunks, meshing multihilo, física integrada, edición en runtime, instancias de decoración, canales 8/16-bit.
- **C# con Voxel Tools es engorroso** (requiere generar SDK local para Nuget) → confirma la decisión de GDScript del módulo 05.
- Terrain3D (4.171★) descartado: es heightmap, sin bloques/minería/edición volumétrica → incompatibles con el diseño del proyecto.
- Unity: plugins voxel de pago poco mantenidos, suscripción, sin ventaja. Unreal: Voxel Plugin de pago + 5% royalty + curva alta. Ambos sobre-dimensionados para un cozy single-player.
- Riesgo "muerte del plugin" mitigado: diseño M08 agnóstico del motor + referencia de case-study (greedy meshing + pooling + LOD en Godot 4.4 puro, ~4 semanas).

## Cambios realizados

- `04-Game-Engine/plan-actual/04-Codigo.md`: sección 4 actualizada con versión fijada y evidencia; Notas del Agente con confirmación.
- `04-Game-Engine/plan-actual/05-Checklist.md`: ítem de confirmación → `[x]`; totales 95/120 (25 pendientes de instalación → M1).
- `CHECKLIST-GLOBAL.md`: fila 04 con decisión confirmada.
- `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md`: sección Motor confirmada.
- **Sincronización plan-actual:** los espejos `plan-actual/` de los componentes 01-13 quedaron poblados (el Copy-Item previo con `-LiteralPath` + comodín no copiaba; corregido con `-Path`).

## Próximo paso

- Hito M1 (semilla de instalación): fijar versión exacta de Godot (≥4.4.1), instalar, proyecto base, correr demo oficial de Voxel Tools, gate 60 FPS. Disponible para delegar a otro agente.