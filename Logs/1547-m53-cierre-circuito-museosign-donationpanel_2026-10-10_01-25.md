# Log 1547: M53 — Cierre circuito (MuseoSign → DonationPanel) + bundle entrega

**Fecha:** 2026-10-10
**Hora:** 01:25
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Cierre del circuito M53: MuseoSign ahora tiene botón "Donar pieza" que instancia y abre el DonationPanel. El flujo completo es: interacción → MuseoSign → Donar → DonationPanel → DonationService.donate() → feedback.

## Cambios en museo_sign.gd
- `+ _btn_donar` (Button "Donar pieza")
- `+ _on_donar()`: instancia DonationPanel (lazy) + `abrir(expo_actual)`
- `+ _obtener_expo_actual()`: extrae la primera exposición del resumen
- `+ tener_boton_donar()` / `obtener_donation_panel()` para tests

## --check-only
- museo_sign.gd: 0 errores ✓
- donation_panel.gd: 0 errores ✓

## Flujo completo verificado (headless)
1. MuseoSign `abrir()` → muestra resumen + progreso
2. Botón "Donar" → instancia DonationPanel + `abrir(expo)`
3. DonationPanel muestra `donables_pendientes(expo)`
4. `donate(expo, item)` → `DonationService` → feedback ok/rechazado
5. `exhibition_completed` → toast en MuseoSign

## Reglas
- UI en `scripts/ui/` ✓
- Backend `scripts/museum/` intacto ✓
- Sin commits ✓
