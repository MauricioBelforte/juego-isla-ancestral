# Log 1743: M72 - seccion D notificacion de logros (68 -> 77)

**Fecha:** 2026-10-12
**Hora:** 07:35
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 189, a eleccion entre M27 seccion L y M72 seccion D): elegi
**M72 seccion D** porque M27 seccion L ya estaba cerrada del ciclo anterior.
**M72: 68 -> 77 `[x]` / 185 (+9).**

## Verificado

`achievement_service.gd` -> `_emitir_toast()` (L258-278) y
`scripts/ui/services/notification_service.gd` (M53):

| Item | Evidencia |
|---|---|
| Toast no bloqueante con icono/nombre/descripcion | emite `bus.ui.notify({tipo, id, titulo, texto})`; icono via `_get_type_icon()` |
| Respetar M58 | retorna temprano si `_toasts_disabled`; `_conectar_accesibilidad()` lee el perfil |
| No robar input ni pausar | señal no bloqueante de EventBus |
| Sin duplicados | `desbloquear()` idempotente |
| Revelacion de ocultos | nombre real siempre; descripcion enmascarada |
| Cola de toasts | `push()` + `_dequeue_oldest()` + `set_queue_limit(n)` |
| Fade suave | `fade_duration` configurable |
| Tiempo visible | `toast_lifetime = 4.0` (> 3.5 s pedido) |
| Cola durante cinematica | FIFO |

## Suites

```
test_puente_notify.gd        TEST PUENTE NOTIFY: 0 fallo(s)
test_logros.gd               20 tests, 0 fallos
test_logros_rf1_e.gd          6 tests, 0 fallos
test_logros_m72_statids.gd    1 test,  0 fallos
```

## Quedó `[ ]` a propósito

- **Resumen "N nuevos logros"** al superar 5 en cola: no hay lógica de agrupación en
  `NotificationService`; habría que implementarla en M53 (dueño de la cola).
- **Click en el toast para abrir el panel**: `panel_solicitado()` ya se emite desde M72
  (RF7), pero el click es del widget de M53.
- **Log de desborde de cola**: M72 emite 1:1, no hay desborde que registrar desde acá.

## Archivos Modificados

- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` (9 flips)
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/04-Codigo.md` (Notas del Agente)
