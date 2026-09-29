**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Módulo:** 66-Anti-Softlock (iteración agnes gate CI, Log 1018)
**Fecha:** 2026-09-18

# Checklist personal — M66 Anti-Softlock (iter. agnes, acotada)

> Encaje A: gate CI + auditoría headless (V0). **Alcance acotado:** verificar el core + cablear el
> gate CI + confirmar que los 7 `[?]` son externos. NO cierro los `[?]` (bloqueados por M22/M26/M64/M27).

## Iteración agnes (Log 1018)
- [x] Relevo del `🟡 Con dudas 110/117` (sin dueño) → M66 en curso
- [x] Verificar core real: `softlock_guard.gd` (autoload, tick 60 s, cascada de invariantes + cooldown
  toast) + `softlock_rules.gd` + `invariants/` (jugador/misión/npc/objeto_clave/vehículo/puzzle +
  `irecoverable`) + `recovery/` (cofre_recuperacion, checkpoint_manager)
- [x] Verificar tests headless: `test_anti_softlock_m66.gd` + `test_fallbacks_m66.gd` → **0 fallos,
  exit 0, 0 `SCRIPT ERROR` propios**
- [x] Gate CI: los 2 tests **no estaban** cableados → añadidos al gate duro `quality.yml`
- [x] Confirmar que los 7 `[?]` son **externos** (M22/M26/M64/M27) → NO los re-marqué
- [x] Documentar: 05-Checklist §"Iteración agnes" + 04-Codigo §"Iteración agnes" + CHECKLIST-GLOBAL
  fila 66 (🟡 Liberado) + ESTADO-PARALELO + Log 1018

## Pendiente (dueños externos / próximos)
- [ ] 7 `[?]`: NavigationServer3D 2-caminos (M27), watchdog NPC (M64), integración/persistencia de
  misiones (M22), Templo Subterráneo (M26) → **se abren cuando esos módulos expongan la API**
- [ ] QA cruzado §21.8 del Log 1018 (verificador ≠ agnes-3-flash)

## Reglas de uso
- No afirmar "M66 completo": mi iteración es acotada; el estado global sigue 🟡 110/117 (7 `[?]`
  externos). El core queda **protegido por el gate CI**.
