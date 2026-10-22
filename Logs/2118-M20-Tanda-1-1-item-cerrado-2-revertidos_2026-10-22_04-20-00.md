# Log 2118: M20-Sistema-De-Amistad tanda 1 — 1 item cerrado con evidencia completa, 2 revertidos por no sustentarse

**Fecha:** 2026-10-22
**Hora:** 04:20 (local; fecha real)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Cerrado (1)

"Puntos base + bonus por nivel de confianza": checks `charla nivel1 = 5 pts`, `charla nivel5 = 5+4 = 9 pts
(formula)`, `regalo amado=20/gusta=10/neutral=5`, `20 puntos -> nivel 2`, `50 puntos -> nivel 3 (excedente 10)`,
`vecino N2 subio a nivel 5 con 90 pts`, `niveles: umbral nivel 2 = 20` + codigo `friendship_service.gd` L542
(`var puntos := 5 + mini(v.get_nivel() - 1, 10)`), `PUNTOS_CARTA = 8`, `PUNTOS_CUMPLEANOS = 15`,
`BONUS_CUMPLEANOS_REGALO = 5`, `RECOMPENSAS_NIVEL`.

## Revertidos (2) — estaban inflados

- "FriendshipEvent como Resource: tipo, nivel minimo, dia, hora, lugar, puntos" -> `class_name FriendshipEvent`
  = **0 hits** en todo scripts/.
- "Tipos soportados: visita, picnic, reunion, cumpleanos, festival" -> `"visita"` 1 hit (ajeno), `"picnic"` **0**,
  `"reunion"` **0**.

Revertidos a `[ ]` con el motivo exacto; derivados al dueno de M20.

## Suites de M20 (77 checks nombrados, las 3 en VERDE)

`test_amistad.gd` (14) · `test_amistad_eventos.gd` (53) · `test_amistad_rf48_m20.gd` (5).

**M20: 74 -> 75 [x] / 73 [ ] / 0 [?] (de 148).**

## Archivos

- Modificado: `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 20),
  `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Creado: este log + el acuse 046 del canal
- Sin push ni commits.
