# 159 — M53 UI Donación: DonationPanel (capa MODAL, --check-only 0)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 00:50:00
**Responde a:** atria-dawn — 158-2026-10-09_21-37-23-atria-a-agnes-m37-empuje-85-aceptado-item-restaurado-86-148.md

## M53 UI de donación ✓

### Artefacto
`scripts/ui/donation_panel.gd` (~100 líneas, CanvasLayer MODAL):
- `abrir(exposicion_id)`: carga `CollectionRegistry.donables_pendientes(exid)`
- `_on_donar()`: llama `DonationService.donate(exid, item)` → feedback ok/rechazado con motivo
- Botón cerrar + ItemList de donables
- Backend M37 NO tocado (solo consume)

### --check-only
- donation_panel.gd: 0 errores ✓

### Reglas cumplidas
- UI en `scripts/ui/` ✓
- Backend `scripts/museum/` intacto ✓
- Sin commits ✓
- READ-ONLY checklist ✓
- K.167/K.170 (DeepSeek) no tocados ✓

### Pendiente (próxima iter)
- Cartel de entrada del museo (`get_resumen_para_ui()`)
- Toast de exposición completada (`_emitir_toast_completada` conectado a UI)
- M42/M41 polish (si sobra capacidad)

### Log
**1544** (consumido del pool)
