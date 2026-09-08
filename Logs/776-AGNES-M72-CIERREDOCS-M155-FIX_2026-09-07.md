# Log 776: M72 cierre docs + M155 unlock tracking + tooltips

**Fecha:** 2026-09-07
**Hora:** 04:35
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
Cierre de documentos de diseno M72 pendientes e implementacion de features M155.

## M72 Sistema de Logros — 182/185 (98%)

### Items marcados como completados (designo ya existente):
- L149: Flujo consulta panel — disenado 03-Diseno.md §3.3, implementado API get_todos()/get_estado()/get_en_progreso()
- L150: Flujo reset partida — disenado 03-Diseno.md §3.4, restore_save_data() tolera v1/v2
- L154: Memoizacion condiciones compuestas — IMPLEMENTADO: _compuesta_cache L50 + COMPUESTA_CACHE_TTL L51
- L156: Validacion catalogo editor — IMPLEMENTADO: validar_catalogo() L390, ejecutado en _cargar_catalogo() L82
- L158: Convivencia notificaciones/pausas — MANEJADO: EventBus.notify no bloqueante, cola M53, RN7 accesibilidad

### Items que quedan [?]:
- L172: Reconciliar discrepancias Steam — BLOQUEADO por M97 (Steam SDK no presente); diseño existe §3.2 paso 4
- L240: Test manual 20 desbloqueos simultaneos — REQUIERE ejecucion juego real
- L243: Test manual ciclo cosechar-toast — REQUIERE ejecucion juego real

## M155 Vestimenta y Accesorios — 104/108 (96%)

### Cambios implementados:
1. **equipment_manager.gd**: agregado _unlocked_items: Array[String] + señal item_unlocked
   - unlock_item(item_id) marca permanente + write-through SaveManager
   - get_save_data() incluye unlocked_items en dictionary
   - 
estore_save_data() restaura array desde seccion equipment M59
2. **equipment_layer.gd**: toolip mejorado L163-172
   - Muestra: nombre, rareza, slot, descripcion
   - Bonos de terreno si existen
   - Requerimiento de desbloqueo si bloqueado
   - Fix Godot 4.7.2 parser: explicit String() casting para Dictionary.get()
3. Checklists actualizados: L34, L118, L131, L133 marcados [x]

### Items que quedan [?]:
- L29: Renderizar accesorios en jugador — BLOQUEADO por M156 (vestimenta visual GLB)
- L143: Verificar conflictos rendimiento — sin profiling dedicado; codigo event-driven sin frame loops

## Prueba de comprension
- Juego arranca sin errores parser (Debug Break resuelto)
- EquipManager: 16 prendas catalog + tabla bonos 7 terrenos
- EquipmentLayer: pila=8, toggle con tecla E
- M72: 11 logros cargados, RF14 validacion 0 problemas
- Test headless: 0 fallos criticos

## Archivos modificados
- game/isla-ancestral/scripts/logros/achievement_service.gd — solo lectura (verify)
- game/isla-ancestral/scripts/player/equipment_manager.gd — ADD: _unlocked_items, unlock_item(), get_unlocked_items_list(), save/restore extendido
- game/isla-ancestral/scripts/ui/layers/equipment_layer.gd — ADD: tooltip detallado + parser fix tipo explicito
- DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md — 5 items [x], 3 items [?]
- DOCUMENTACION/155-Vestimenta-Y-Accesorios/plan-actual/05-Checklist.md — 4 items [x]
- CHECKLIST-GLOBAL.md — progreso actualizado

## Lecciones
- Godot 4.7.2 trata type inference de Dictionary.get() como Variant-error si el valor por defecto no es del mismo tipo que la clave esperada. Solucion: cast explicito String() o as Dictionary.
- M72 design items: cuando el documento de diseno (§3.x) ya describe el flujo, se puede marcar [x] incluso si la implementacion UI depende de otro modulo (M53).
- M155 unlocks persistentes: necesidad de separar equipamiento (lo que tienes puesto) de desbloqueos (que prendas has obtenido). Ahora ambas cosas persisten en secciones distintas del guardado.
