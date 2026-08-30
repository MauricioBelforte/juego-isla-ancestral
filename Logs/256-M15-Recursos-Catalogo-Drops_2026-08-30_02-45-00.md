# Log 256: M15 Recursos — ResourceManager + ResourceDefinition + catálogo 6 tipos + drops

**Fecha:** 2026-08-30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 1 del M15 (Recursos, V1). Se implementó el núcleo data-driven: ResourceManager
autoload con catálogo de 6 tipos de recurso (madera, piedra, fibra, comida, mineral, raro),
ResourceDefinition y ResourceDropEntry como clases serializables, generación de drops con
probabilidad y garantía anti-frustración, validación de herramienta (RF4), e integración
con el Inventario M14 (agregar_items). Test headless 0 fallos.

## Cambios Realizados

### Código (Godot)
- `scripts/resources/resource_definition.gd` — **NUEVO** class_name ResourceDefinition:
  Categoria enum, def_id, display_name, herramienta_requerida, golpes, drops, temporada_respawn,
  región, valor_venta, fuentes_alternativas. Métodos: drops_para_herramienta(), es_accesible_con().
- `scripts/resources/resource_drop_entry.gd` — **NUEVO** class_name ResourceDropEntry:
  item_id, cantidad_min/max, probabilidad, requiere_herramienta_mejorada, cantidad(rng).
- `scripts/resources/resource_manager.gd` — **NUEVO** autoload "ResourceManager": catálogo
  con 6 definiciones por defecto, generar_drops() con validación de herramienta + garantía
  anti-frustración, entregar_drops() para M14, persistencia M59 (placeholder).
- `scripts/resources/test_recursos.gd` — **NUEVO** test: catálogo 6 tipos, drops generados,
  acceso por herramienta, RNG consistente. 0 fallos.
- `project.godot` — autoload ResourceManager registrado.

### Documentación
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` — marcados ítems del catálogo y drops.
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` — notas de implementación.
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`,
  `Mensajes entre modelos/ESTADO-PARALELO.md` — registros actualizados.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/resources/resource_definition.gd` | Creado |
| `scripts/resources/resource_drop_entry.gd` | Creado |
| `scripts/resources/resource_manager.gd` | Creado |
| `scripts/resources/test_recursos.gd` | Creado |
| `project.godot` | Modificado (autoload + fix duplicado) |
| `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` | Modificado |
| `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` | Modificado |
| `CHECKLIST-GLOBAL.md` | Modificado |
| `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` | Modificado |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (255 → 256) |
| `Logs/256-M15-Recursos-Catalogo-Drops_2026-08-30_02-45-00.md` | Creado (este log) |

## Validación
- `test_recursos.gd` headless: 0 fallos (6 tipos, drops, validación herramienta).

## Pendientes honestos
- ResourceNode (nodo 3D con estados intacto/dañado/agotado): requiere visión (V1/V2).
- ResourceSpawner con burbuja 48 m y conexión a M08 (regiones voxel).
- ResourceDrops físicos (RigidBody3D con pooling): requiere visión.
- Señal `golpe_aplicado` de M13 (no existe aún; drops se generan desde el manager).
- Respawn estacional/eventos (M29/M73).
- Persistencia completa de nodos agotados.