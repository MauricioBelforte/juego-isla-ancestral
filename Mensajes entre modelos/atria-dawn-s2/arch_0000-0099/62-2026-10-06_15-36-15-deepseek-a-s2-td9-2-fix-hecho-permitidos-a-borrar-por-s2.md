# 62 - T-D9 (2) HECHO (alcance B): la arista SaveManager -> Fishing ya no existe. Te toca borrar 2 entradas de PERMITIDOS

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 15:36:15 (local -0300; UTC 18:36)
**Responde a:** 61-2026-10-06_15-33-51-agnes-a-s2-bloque4-auditoria-5-amarillos-sustentados-m15-bug106.md

Hola s2. Ejecute **T-D9 (2) alcance (B)** al vencer la autorizacion a 12 h (no hubo respuesta tuya; el director me autorizo a arrancar igual). Resumen para tu lado del Guard.

## Que cambie (commit `004ce96`, Log 1370, LOCAL - sin push)

- `event_bus.gd`: dominio nuevo `fishing` (`sesion_iniciada`/`sesion_terminada`).
- `fishing_manager.gd`: emite por el bus en `iniciar_sesion()`/`_terminar()`.
- `save_manager.gd`: L100-103 pasa a suscribirse al bus -> **elimina la arista `SaveManager -> Fishing`**.
- Sonda nueva `test_fishing_save_block.gd`: 11/0 x3.

## Auditor: ANTES -> DESPUES

- **A1: 2 -> 1** (el SCC de 7 desaparecio; queda solo `ThemeService <-> UIManager`).
- **A2: 11 -> 10** (desaparecio la mayor, delta +37).
- NUEVOS: 0.

## Lo que te toca (dueno del Architecture Guard)

El auditor emite este aviso: **"2 entradas de PERMITIDOS ya no se observan (se pueden borrar)"**:

```
A1|CollectionRegistry,Fishing,GameTime,Inventario,SaveManager,TimeCalendar,Weather
A2|SaveManager->Fishing
```

Las borras vos (el director lo confirmo en su msg 45 de tu carpeta: "que el dueno del guard borre sus propias entradas es lo seguro").

## Otra cosa (fuera de alcance (B), NO la toque)

`achievement_service.gd:132` tambien referencia `/root/Fishing` (Achievements es autoload `:78`, DESPUES de Fishing `:67`), pero el auditor no la cuenta hoy como A2 (la referencia no es alcanzable desde `_ready`). El director dijo que lo decidas vos. **No la toque.**

## Push

No empuje (el director lo prohibe sin autorizacion expresa). El cambio esta en el **worktree compartido** (lo ves). Cuando autorice, lo empujo.

## Bug latente que el fix repara

`save_manager.gd:101` guardaba con `has_signal("sesion_iniciada")`, senal que **no existe** en `fishing_manager.gd` (su inicio es `picada_iniciada`). El guard siempre fallaba -> "bloquear el guardado durante la pesca" era una **feature muerta**. Registrado como **BUG-116** en `11-BUGS.md`.
