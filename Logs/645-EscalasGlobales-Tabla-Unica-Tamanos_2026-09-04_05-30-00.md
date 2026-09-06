# Log 645: M45/M50/M36/M19 — EscalasGlobales autoload (tabla única de tamaños)

**Fecha:** 2026-09-04
**Hora:** 05:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Implementación del patrón "Estandarizar tamaños de objetos" de 5-FUTURAS-MEJORAS: autoload **EscalasGlobales** con tabla data-driven de **43 tipos** que cubre **vegetación (15), fauna (9), NPCs (8), props/tótems (11)**. Cualquier módulo consulta `EscalasGlobales.escala_de(tipo)` para obtener el multiplicador correcto.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/escalas/escalas.json` *(nuevo)* | Tabla data-driven: 43 tipos con escalas referenciadas al personaje (1.8m) y voxel (1m). Categorías: vegetacion, fauna, npcs, props_totems |
| `scripts/core/escalas_globales.gd` *(nuevo)* | Autoload EscalasGlobales: carga JSON, escala_de(tipo) con match exacto + substring (para prefijos "50-Vegetacion_"), recargar() para iteración visual |
| `project.godot` | Autoload EscalasGlobales registrado |
| `scripts/vegetacion/vegetation_spawner.gd` | _escala_de() delega a EscalasGlobales (reemplaza tabla rota con parse error); plant_seeded() huérfano eliminado |

## Escalas de referencia (5-FUTURAS-MEJORAS)

| Objeto | Altura objetivo |
|---|---|
| Personaje (voxel) | 1.8m |
| Palmera/árbol | 4-6m |
| Arbusto | ~1m |
| Helecho gigante | 3-4m |
| Hierba alta | 0.4m |
| Flor | 0.2m |
| Tortuga | 0.8m |
| Cangrejo | 0.25m |
| Jabalí adulto | 1.1m |
| Tótem ancestral | 3.5m |
| Choza | 3m |

## Tests
- Boot: `[Escalas] Tabla cargada: 43 tipos` sin errores
- test_distribucion.gd: 109→134 instancias del plan (25 en cercanias_spawn)
- Escala de spawner: los GLB usan `EscalasGlobales.escala_de(tipo)` en vez de tabla hardcoded con parse error

## Archivos Modificados/Creados
- `game/isla-ancestral/data/escalas/escalas.json` *(nuevo)*
- `game/isla-ancestral/scripts/core/escalas_globales.gd` *(nuevo)*
- `game/isla-ancestral/scripts/vegetacion/vegetation_spawner.gd` *(reparado + delegación)*
- `game/isla-ancestral/project.godot` *(autoload)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 645)*
- `Logs/reservas/645-...txt` *(creada y borrada)*

## Lección para 07-GUIA §8
- **_escala_de() con tabla inline causó parse error por indentación**: el archivo creció orgánicamente con funciones anidadas y la tabla quedó en posición sintácticamente inválida. Mejor patrón: tabla en JSON data-driven + autoload que la consume. Un solo punto de curaduría (el JSON), cero riesgo de parse error.
- La tabla está en `escalas.json` y puede editarse en vivo sin reiniciar (llamar `recargar()` desde DebugMenu).
