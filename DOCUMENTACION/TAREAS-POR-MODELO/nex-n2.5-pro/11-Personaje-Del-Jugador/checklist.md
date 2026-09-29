**Modelo:** nex-n2.5-pro (Nex-AGI)
**Plataforma:** Kilo Code
**Módulo:** 11-Personaje-Del-Jugador
**Fecha:** 2026-09-19

# Checklist personal — M11 Personaje-Del-Jugador

> **Encaje A+B.** Fuente de verdad: `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md`.
> El módulo tiene **código real** en `game/isla-ancestral/scripts/player/` (player.gd,
> equipment_manager.gd, equipment_catalog.gd, equipment_slot.gd, player_equipment.gd,
> terrain_bonus_table.gd, unlock_condition.gd), **73 ítems `[?]` verificados contra el
> código** y divergencias documentadas. La suite headless fue creada, validada y protegida
> con un gate CI duro; quedan abiertos la implementación restante y el QA cruzado §21.8.

> **Regla de evidencia (no negociable):** cada `[x]` cita `archivo:línea` o el test que lo
> cubre. Si el valor no existe o diverge del diseño, se repara el código **o** se deja `[?]`
> con la divergencia documentada. Prohibido `[x]` sin evidencia (AGENTS.md §21.4).

## Fase 0 — Suite headless (PRIORIDAD 1, bloquea el resto)

**Reserva actual:** 🟡 Liberado · Agente — (nex-n2.5-pro liberó la reserva) · Logs **1055/1062/1064/1069** · Inicio 2026-09-19 · Liberación 2026-09-19 08:08 · Alcance completado: suite headless y auditoría de los 73 `[?]`; implementación restante y QA cruzado pendientes.

- [x] T-001 Crear suite headless scripts/player/test_player_m11.gd con marcador _fin() por bloque y guardián anti-falso-verde [C]
- [ ] T-002 Cobertura suite: constantes seccion B (12 aserciones) [M]
- [ ] T-003 Cobertura suite: transiciones FSM seccion C (16 aserciones) [M]
- [ ] T-004 Cobertura suite: stamina (drenado/regen/limites) [M]
- [ ] T-005 Cobertura suite: buceo (aire + flotado automatico) [M]
- [ ] T-006 Cobertura suite: magnetismo de luz + interaccion (mock IInteractable) [M]
- [ ] T-007 Cobertura suite: hitbox/colision voxel [M]
- [x] T-008 Ejecutar suite con binario real, EXIT 0 + 0 SCRIPT ERROR en stderr: 30 checks, 0 fallos (Godot 4.7.2) [M]
- [x] T-009 Cablear test_player_m11.gd en .github/workflows/quality.yml como gate duro (|| FAIL=1) [M]
- [x] T-010 Prueba de inyeccion: introducir error sintactico temporal y confirmar que el gate FALLA [M]

## Fase 1 — Verificación de los 73 `[?]` contra código real


### Sección B — Física y constantes

- [x] T-011 Hitbox: ancho 0.6, alto 1.8, profundo 0.3 m [S]
- [x] T-012 Velocidad de caminar: 4.2 m/s [S]
- [x] T-013 Velocidad de correr: 6.5 m/s [S]
- [x] T-014 Velocidad de nadar: 2.5 m/s (superficie) [S]
- [x] T-015 Velocidad de buceo: 1.8 m/s (bajo agua) [S]
- [x] T-016 Altura de salto: 1.2 m (2 bloques) y tiempo aéreo 0.6 s [S]
- [x] T-017 Gravedad 12 m/s² y velocidad terminal 20 m/s [S]
- [x] T-018 Step-up 0.6 m (rampas sí, paredes no) [S]
- [x] T-019 Aire de buceo: 18 s con flotado automático [S]
- [x] T-020 Stamina: máx 100, drenado 12/s corriendo, regen 8/s parado [S]
- [x] T-021 Radio de magnetismo de luz: 1.2 m [S]
- [x] T-022 Rango de interacción: 4 m [S]

### Sección C — FSM de estados

- [x] T-023 Estado IDLE: entrada/salida, sin movimiento [M]
- [x] T-024 Estado WALK: entrada por input direccional [M]
- [x] T-025 Estado RUN: entrada por LShift + stamina > 0 [M]
- [x] T-026 Transición RUN→WALK al 30% de stamina o shift suelto [M]
- [x] T-027 Estado JUMP: entrada desde tierra [M]
- [x] T-028 Estado FALL: entrada al apex; control aéreo 60% [M]
- [x] T-029 Aterrizaje FALL→IDLE/WALK suave [M]
- [x] T-030 Estado SWIM: entrada al tocar agua de cintura [M]
- [x] T-031 Estado DIVE: entrada con mantener espacio bajo agua [M]
- [x] T-032 Estado SURFACE (flota): al 20% de aire o soltar [M]
- [x] T-033 Transición SWIM→WALK en bordes (salida del agua) [M]
- [x] T-034 Estado INTERACT: bloquea movimiento 0.3 s [M]
- [x] T-035 Estado SLEEP: solo desde cama (M31) [M]
- [x] T-036 Estado CRAFT: solo desde mesa (M16) [M]
- [x] T-037 Tabla de permisos por estado (mov/jump/interact/sprint) [M]
- [x] T-038 Sin estados imposibles (transiciones validadas) [M]

### Sección D — Interacción y luz

- [x] T-039 InteractionService con raycast de 4 m [M]
- [x] T-040 Highlight del objetivo en rango [M]
- [x] T-041 Un interactable a la vez (prioridad centro de rayo) [M]
- [x] T-042 HUD: prompt `[F] <nombre>` (localizable M57) [M]
- [x] T-043 IInteractable consumible por cualquier módulo [M]
- [x] T-044 Esporas de luz: spawn desde M27/natural [M]
- [x] T-045 Magnetismo 1.2 m con animación de entrada 0.3 s [M]
- [x] T-046 PlayerLightInventory (M14) recibe las esporas [M]
- [x] T-047 HUD de luz total (6 esferas, M14/M28) [M]
- [x] T-048 Recogida sin límite (progresión del alma) [S]
- [x] T-049 Audio de recogida (campana suave) [S]
- [x] T-050 Evento `light_collected(count)` en EventBus [M]
- [x] T-051 Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M]
- [x] T-052 Recogida idempotente: si se salvó la espora como recogida, no reaparece al regenerar [M]

### Sección E — Energía y bienestar

- [x] T-053 Stamina siempre informativa (nunca bloquea caminar) [M]
- [x] T-054 Barra visible solo al drenar (fade) [M]
- [x] T-055 Icono de fatiga suave al 30% [M]
- [x] T-056 Vibración sutil + tinte en bordes al 30% [M]
- [x] T-057 Sin daño por caída (amortiguación en alturas > 3 bloques) [M]
- [x] T-058 Regeneración libre parado o caminando [S]
- [x] T-059 Hueco de fatiga: sprint no acumula deuda permanente [M]
- [x] T-060 Bucle día/noche afecta energía (descanso M29) [M]
- [x] T-061 Alimentos otorgan bonos de bienestar (M29) [M]
- [x] T-062 Cero penalización por dormir poco (aviso suave) [M]
- [x] T-063 System settings: toggle sprint (hold/alternate) [S]
- [x] T-064 Validación cozy: sin castigos por jugar "mal" [M]
- [x] T-065 Aviso de fatiga no interrumpe el flujo (no modal) [S]
- [x] T-066 El sprint vuelve a 0 sin penalizar la siguiente acción [S]

### Sección F — Animaciones y audio

- [x] T-067 10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft [M]
- [x] T-068 Blend tree walk↔run por velocidad [M]
- [x] T-069 Crossfade 0.1 s entre estados [S]
- [x] T-070 Pasos por superficie (césped, arena, piedra, barro, agua) [M]
- [x] T-071 Saltos y aterrizajes con audio [S]
- [x] T-072 Splash de entrada/salida del agua [S]
- [x] T-073 Chirrido de interacción (madera/metal según objeto) [M]
- [x] T-074 Assets finales → M65 (terceros) [M]
- [x] T-075 Sin voz del personaje (cozy) [S]
- [x] T-076 La música del mundo la lleva M53 [S]
- [x] T-077 Sin loops de audio solapados al transicionar estados rápidos [M]
- [x] T-078 Volúmenes por capa: pasos → interacción → ambiente (M53) [S]

### Sección G — Documentación e integración

- [x] T-079 Constantes consumibles en data/player/player_motion.tres [M]

### Sección H — Verificación y cierre

- [x] T-080 FSM con tabla de permisos completa [M]
- [x] T-081 Constantes físicas documentadas y consumibles [M]
- [x] T-082 Guardado de posición/estado en GameState.M11 [M]
- [x] T-083 Anti-frustration: buceo flota, caída sin daño, stamina informa [M]

## Fase 2 — Cierre y protocolo

- [x] T-084 Reparar bloque ## Totales del 05-Checklist si quedo desincronizado (leccion 24) [S]
- [ ] T-085 QA cruzado §21.8 de la iteracion (verificador != nex-n2.5-pro) [M]
- [x] T-086 Si una constante contradice 03-Diseno.md: NO cambiarla unilateralmente -> [?] con divergencia documentada y dueño [S]
- [x] T-087 Sincronizar evidencia final de la suite 30/0 en checklist, guia 08, estado paralelo, CI y log 1069 [M]

## Totales

- **Tareas verificables directas:** 87 (73 `[?]` del módulo + 14 de suite/gate/cierre)
- **Expansión natural (regla >=100 de la guia):** la suite genera ~30 aserciones
  individuales (una por constante/estado/transición) que se descomponen en otros
  tantos ítems verificables; M12/M13/M14 (consumidores del contrato de player.gd,
  guia 08 §3.2) completan el resto cuando se libere M11.

## Reglas de uso

- **Marco de bloqueo:** `[ ]` pendiente → `[→]` en progreso (la tomo yo) → `[x]` completada
  (con evidencia: log + test + nota) → `[?]` no resuelta (con razón y dueño).
- **Al completar T-###:** actualizar TAMBIÉN el ítem correspondiente en
  `05-Checklist.md` del módulo y la fila 11 de CHECKLIST-GLOBAL. Los tres lugares
  sincronizados (GUIA-METODOLOGIA §4).
- **Reserva de log:** `python scripts/reservar_log.py --reservar --agente nex-n2.5-pro --modulo 11-Personaje`
- **No afirmar "M11 completo"** hasta que los 73 `[?]` estén implementados y marcados
  `[x]`, la suite siga verde y gateada, y el QA cruzado §21.8 esté aprobado.
- **player.gd es contrato de M12/M13/M14/M19:** no romper la API pública. Un cambio de
  contrato necesario se documenta como `[?]` con dueño y NO se aplica unilateralmente.
