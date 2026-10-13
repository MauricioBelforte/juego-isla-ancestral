# M110 — Debug Menu: Especificación

**Módulo:** M110
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12

---

## Secciones del menú
1. **Estado del juego:** FPS, draw calls, memoria, entidades activas.
2. **Tiempo:** velocidad (0/1/2/4/8x), hora del día, estación.
3. **Jugador:** HP, inventario, posición, teleport.
4. **Mundo:** seed, chunk, bioma, clima.
5. **Económico:** dinero, gemas, recetas desbloqueadas.
6. **Narrativa:** hitos, misiones, sellos.
7. **Rendimiento:** frame time, GC, memory leak monitor.
8. **Save/Load:** slots, corrupt check, rollback.

## Activación
- **Hotkey:** `F8` + `F9` (solo dev builds).
- **Oculto en release:** `#ifdef DEV_BUILD`.

## Restricciones
- **Sin afectar gameplay:** solo consulta + cambios limitados.
- **Sin write de archivos:** solo lectura.
- **Sin red:** solo local.
