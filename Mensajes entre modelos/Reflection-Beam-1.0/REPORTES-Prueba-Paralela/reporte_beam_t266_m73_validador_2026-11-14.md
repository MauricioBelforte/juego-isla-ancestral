# Reporte: T266 — M73 validador de coleccionables (12 categorías)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14

## Estado actual (sin cambios de código)

- `game/isla-ancestral/scripts/coleccionables/validate_collectibles.gd` ya lista **20** categorías en `CATEGORIAS_CONOCIDAS` (líneas 12-16), incluyendo las 12 nuevas (insectos, fosiles, cartas, fotos, mapas, herramientas, ropa, simbolos, mensajes, secretos, muebles, objetos_historia).
- `data/coleccionables/catalog.json` contiene **81 items en 19 categorías** (no hay "ancestrales" en el catálogo).
- Ejecución headless de `test_validate_collectibles_m73.gd` (Godot 4.5): **9 checks, 0 fallos** → rc=0. No hay fallo runtime.

## Hallazgos

| # | Severidad | Archivo:línea | Descripción | Accionable |
|---|-----------|---------------|-------------|------------|
| H1 | Ruido | scripts/coleccionables/validate_collectibles.gd:12-16 | CATEGORIAS_CONOCIDAS incluye "ancestrales" que no existe en catalog.json (20 vs 19). No bloquea. | Eliminar "ancestrales" para que la lista coincida exactamente con el catálogo. |
| H2 | Bajo | DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/tareas/T266-M73-validador-12-categorias.md:1 | La tarea T266 referencia `scripts/tools/validate_collectibles.gd` (ruta inexistente); el archivo real está en `scripts/coleccionables/`. | Actualizar la cita de la tarea. |
| H3 | Info | scripts/coleccionables/validate_collectibles.gd:37 | La validación de categoría desconocida se reporta como error (bloqueante), no advertencia; el comentario del código dice "advertencia, no bloqueo" pero el código agrega a `errores`. | Alinear comentario o cambiar a warning si se desea no bloquear. |

## Veredicto

T266 ya está resuelto en el estado actual del repositorio; no se requiere modificar `CATEGORIAS_CONOCIDAS`. La suite pasa con 0 fallos.

## 2 mejoras concretas

1. **Sincronizar la lista de categorías con el catálogo** (eliminar "ancestrales" si no se usa) para evitar falsos positivos si se agregan items de esa categoría en el futuro.
2. **Corregir la cita de ruta** en T266 (`scripts/tools/` → `scripts/coleccionables/`) para que el próximo agente no busque en la carpeta equivocada.
