# Log 169: M14 Inventario — iteración 1 (núcleo de datos + ISaveProvider)

**Fecha:** 2026-08-26
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Implementada la **iteración 1 del M14 (Inventario)**: núcleo de datos puro, autoload `Inventario` y el primer proveedor real (`ISaveProvider`) del sistema de guardado M59. Reservas hechas en los 4 registros (guía 08, checklist del módulo, CHECKLIST-GLOBAL, ESTADO-PARALELO). Excepción documentada en guía 08: M11 pendiente → esta iteración no depende del jugador.

## Archivos creados (`game/isla-ancestral/scripts/inventario/`)
| Archivo | Contenido |
|---|---|
| `container_type.gd` | 6 contenedores con tamaños del diseño (bolsillo 24, mochila +16, casa 60, cofre 16, almacén 240, correo 24) + cadena de fallback anti-pérdida |
| `inventory_slot.gd` | item_id + cantidad + favorito/bloqueado + `instancia: Dictionary` (herramientas M13 con durabilidad por instancia) + serialización solo ids/cantidades/instancia |
| `inventario_contenedor.gd` | Add en DOS pasadas (stacks parciales → slots vacíos), sobrante como int, remove desde el final, count, serialización |
| `inventario_service.gd` | Núcleo del autoload **Inventario**: API rica del diseño + adaptadores `agregar_items()/remover_items()` para M39 (con fallback bolsillo→casa y revert atómico) + ISaveProvider (`get_section_name()="inventory"`) |

Modificados: `project.godot` (autoload), `save_manager.gd` y `save_snapshot.gd` (register_provider sin tipo estricto para aceptar proveedores Node por duck-typing), `05-Checklist.md` (ítems [x] + Notas del Agente).

## Bugs detectados y corregidos durante la validación
1. Sección `"inventory"` duplicada en SaveSchema al agregarla (ya existía en default_payload) → `Key already used`. Revertido.
2. `register_provider(provider: ISaveProvider)` tipado rechazaba al servicio (Node) → `Invalid type... not a subclass`. Destipado el parámetro en SaveManager y SaveSnapshot.
3. Inferencia rota tras destipar: `var section := provider.get_section_name()` → tipo explícito `: String`.

## Verificación final
- Boot headless completo: **SIN ERRORES DE SCRIPTS**
- Regresión M59 (`validate_save.gd`): **13/13 OK, exit 0**

## Pendientes honestos ([?])
- Prueba end-to-end de compra/venta M39↔M14: falta M38 EconomyManager (siguiente módulo recomendado).
- Sort/favoritos/discard/open_storage: contratos definidos, implementación pendiente.
- UI (M53), cofres colocables (M17), correo (M19), tests M112.
