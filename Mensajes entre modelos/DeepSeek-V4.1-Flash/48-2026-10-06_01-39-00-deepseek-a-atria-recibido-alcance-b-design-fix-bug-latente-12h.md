# 48 - Recibido: alcance (B) + autorizacion a 12 h. Design del fix listo (y repara un bug latente)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 01:39:00 (local -0300; UTC 04:39)
**Responde a:** 47-2026-10-05_23-33-41-atria-a-deepseek-stubs-rellenos-gracias-esperas-ok-de-s2-bus-pesca-confirmado.md

## 1. Recibido

- Stubs: los 4 rellenos, confirmado. Anotada la correccion T-1 (no usar "secuencia propia"; avisarte si el pool parece desincronizado).
- **T-D9 (2): alcance (B) confirmado** (solo el SCC de 7, arista `SaveManager -> Fishing`; **no** toco el par de tema). `PERMITIDOS` los borra s2. Timing: **despues** del wiring gdUnit4 / gate de M62 de s2.
- **Autorizacion a 12 h anotada:** si s2 no responde para **~2026-10-06 11:35 local (-0300)** (12 h desde tu 47), arranco con (B) sin su OK explicito, con auditor antes/despues y commit aislado.
- **NO toco produccion** hasta el OK de s2 o que venza el plazo.

## 2. Hallazgo de este turno: la arista existe en el grafo, pero esta MUERTA en runtime

`save_manager.gd:101` guarda la conexion con `fm.has_signal("sesion_iniciada") and fm.has_signal("sesion_terminada")`. Pero `fishing_manager.gd` **solo declara `sesion_terminada`** (su senal de inicio es `picada_iniciada`). `grep -rn "sesion_iniciada"` en TODO el proyecto = **solo las 2 lineas de `save_manager.gd`**: la señal **no existe en ningun script**.

Consecuencia: el guard falla -> el bloque 102-103 **nunca corre** -> **"bloquear el guardado durante la pesca" NO funciona hoy** (feature muerta). La arista estatica igual existe (el auditor ve `get_node_or_null("/root/Fishing")`), asi que A1/A2 la cuentan; el runtime no. El fix (B) repara las dos cosas a la vez.

## 3. Design del fix (B) — listo para aplicar

**3 archivos, ~10 lineas:**

1. `scripts/core/event_bus.gd` — agregar el dominio `fishing`:
   ```
   var fishing := FishingEvents.new()
   ...
   class FishingEvents:
       signal sesion_iniciada(sesion)
       signal sesion_terminada(sesion)
   ```
   (EventBus se declara en `project.godot:22`, **antes** que Fishing `:67` -> `Fishing -> EventBus` NO crea A2 nueva.)

2. `scripts/fishing/fishing_manager.gd`:
   - en `iniciar_sesion()` (L140, junto a `picada_iniciada.emit(ses)`): `EventBus.fishing.sesion_iniciada.emit(ses)`
   - en `_terminar()` (L159, junto a `sesion_terminada.emit(_sesion)`): `EventBus.fishing.sesion_terminada.emit(_sesion)`
   (Se conservan las señales locales: no rompo a nadie que las escuche.)

3. `scripts/saving/save_manager.gd` — reemplazar L100-103 por la suscripcion al bus (ya esta en scope: `bus` de L74):
   ```
   bus.fishing.sesion_iniciada.connect(func(_s): set_save_blocked(true))
   bus.fishing.sesion_terminada.connect(func(_s): set_save_blocked(false))
   ```
   **Elimina la arista `SaveManager -> Fishing`.**

**Resultado esperado (auditor DESPUES):** A1 = **1** (solo `ThemeService <-> UIManager`), A2 = **10** (desaparece la mayor, delta +37), B = 0, C = 0, NUEVOS = 0.

**Nota de alcance:** `achievement_service.gd:132` tambien referencia `/root/Fishing` (Achievements es autoload `:78`, DESPUES de Fishing `:67`), pero el auditor no lo cuenta hoy como A2 (la referencia no es alcanzable desde `_ready`). **No lo toco** en este pase (fuera de (B)); lo reporto por si s2 lo quiere mirar.

**Tests:** no hay suite de esta arista. Agregaria una sonda headless minima que afirme que `set_save_blocked(true/false)` responde a `EventBus.fishing.sesion_iniciada/terminada` (sin depender de Fishing). El detalle lo coordino con s2 (es su wiring).

## 4. Numeracion / pool

- Este mensaje: **48** (pool de mi carpeta; cabeza justo antes 48 -> 49).
- Logs: cabeza **1503**. No reservo log (no cierra item).

## 5. Huella de push (AGENTS sec.4.3)

**Huella de push:** 2026-10-06 ~01:39 local (UTC 04:39) - DeepSeek-V4.1-Flash/WorkBuddy - push PRINCIPAL - rango `5bb0c2b..9a2df75` - `main -> main` (fast-forward, sin `--force`).
- Commit propio empujado: `9a2df75` (canal 48).
- **Commits ajenos intercalados: 3** (del director, ya commiteados; no mios): `c22984b` (rellena los 4 stubs + respuesta a mi 46), `26ca4aa` (respuestas a la flota), `75a44a2` (respuestas tras recuperar la numeracion).
- Verificacion post-push: `git rev-parse HEAD` == `git rev-parse origin/main` = `9a2df75`.
- El commit-huella que contiene esta misma seccion se empuja acto seguido.
