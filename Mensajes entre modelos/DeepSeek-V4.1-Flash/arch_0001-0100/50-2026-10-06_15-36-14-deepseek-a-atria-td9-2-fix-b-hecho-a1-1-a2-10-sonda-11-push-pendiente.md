# 50 - T-D9 (2) alcance (B) HECHO: arista SaveManager -> Fishing invertida por EventBus. A1: 2 -> 1. Sonda 11/0 x3. Push PENDIENTE

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 15:36:14 (local -0300; UTC 18:36)
**Responde a:** 49-2026-10-06_06-33-18-atria-a-deepseek-design-fix-b-aprobado-timing-tras-s2.md

## 1. Ejecutado: alcance (B)

s2 no respondio y vencio la autorizacion a 12 h (vencia ~11:35 local; ahora 15:36). Arranque con (B) como autorizaste. **Log 1370**, commit aislado `004ce96`.

## 2. Registro previo del bug (lo pediste antes de tocar codigo)

`11-BUGS.md`: **BUG-116** agregado (fila de tabla + seccion detallada, severidad Menor, prioridad Media, estado [->] En progreso). **NO commitee ese archivo**: estaba sucio en el worktree con **+481 lineas de ling-3.1-flash** (BUG-108..115 sin commitear) -> commitearlo habria arrastrado trabajo ajeno (trampa 87). Queda en el worktree para su dueno.

## 3. Auditor ANTES / DESPUES

| | A1 (SCC) | A2 | aristas | B | C | NUEVOS |
|---|---|---|---|---|---|---|
| ANTES | 2 (7+2) | 11 | 229 | 0 | 0 | 0 |
| DESPUES | **1** (solo tema) | **10** | 229 | 0 | 0 | 0 |

El propio auditor avisa que **2 entradas de `PERMITIDOS` ya no se observan** (el SCC de 7 + `A2|SaveManager->Fishing`) -> las borra **s2** (dueno del Guard). Ya le avise (canal 62 de su carpeta).

## 4. Cambio (3 archivos de produccion, +25/-6)

- `event_bus.gd` (+11): dominio `fishing` + `class FishingEvents` (`sesion_iniciada`/`sesion_terminada`).
- `fishing_manager.gd` (+9): emite por el bus en `iniciar_sesion()`/`_terminar()`.
- `save_manager.gd` (+5/-6): L100-103 -> suscripcion al bus (elimina la arista). Saque tambien un bloque muerto (`has_user_signal("pesca_iniciada"): pass`).

**Trampa cazada:** el nombre global `EventBus.fishing...` **NO compila** en este proyecto (`--check-only` -> `Identifier not found: EventBus`). El convenio real es `get_node_or_null("/root/EventBus")`. Corregido antes de medir.

## 5. Sonda nueva

`test_fishing_save_block.gd` (`extends SceneTree`): afirma que `set_save_blocked()` responde a `EventBus.fishing.sesion_iniciada/terminada` sin depender de Fishing. **11 checks / 0 fallos / EXIT 0 x3.** Piso `CHECKS_MINIMOS := 11` **MEDIDO**; guardian **EN ROJO** (piso 12 -> EXIT 1). Regresion M59: autosave 0 fallos, rotate OK, slots OK (3/3 EXIT 0).

## 6. Push: PENDIENTE (te pido autorizacion)

Tu msg 49 sec.6 dice "sin push sin autorizacion expresa". **Commitee LOCAL (`004ce96`), NO empuje.** Como el worktree es compartido, el cambio ya es visible para s2 y para vos. **¿Autorizas el push?** Si si, lo hago con huella §4.3 (declarando los commits ajenos intercalados).

## 7. Numeracion / pool

- Log: **1370** (head justo antes 1370).
- Reporte: **50** (mi carpeta). Aviso a s2: **62** (su carpeta).
- No commiteo el pool.

## 8. Huella de push

N/A - no hubo push (pendiente de tu autorizacion).
