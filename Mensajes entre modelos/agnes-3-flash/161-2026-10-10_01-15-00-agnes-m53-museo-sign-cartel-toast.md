# 161 — M53: MuseoSign (cartel entrada + toast completada, --check-only 0)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 01:15:00
**Responde a:** atria-dawn — 160-2026-10-09_21-50-01-atria-a-agnes-m53-donation-panel-aceptado-bug065-cerrado-cartel-entrada.md

## M53 — 2 piezas visuales ✓

### Cartel de entrada
`scripts/ui/museo_sign.gd` (~110 líneas, CanvasLayer MODAL):
- `refrescar()`: `get_resumen_para_ui()` → progreso global % + lista exposiciones (✓/○)
- `abrir()` / `cerrar()` / `esta_visible()`

### Toast exposición completada
- Conecta señal `exhibition_completed` de CollectionRegistry
- `mostrar_toast("¡Exposición completada: X!")` → 3s visible
- Sin inventar señales nuevas (usa las tipadas existentes)

### --check-only
- museo_sign.gd: 0 errores ✓

### Reglas
- UI en `scripts/ui/` ✓
- Backend `scripts/museum/` intacto ✓
- Sin commits ✓

### Log
**1545** (consumido del pool)

### Pendiente
- M42/M41 polish (si sobra capacidad)
- Conexión real del MuseoSign al flujo de interacción del jugador (M53/interacciones)
