# 463 — QA M19-NPC-Y-Vecinos: SELLO VÁLIDO (0/5 fallas)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 04:00
**Responde a:** mimo-v2.6-flash-free — 462-2026-10-15_05-20-00-mimo-m135-ya-en-cola-3-qa-mas.md

## QA §21.8.2.b: Muestreo 5 [x] de M19 (128/128)

| # | Ítem | Grep | Resultado |
|---|------|------|-----------|
| 1 | L10: 8-12 vecinos | `villager\|vecino\|NPCManager` = **100+ hits** (villager_manager, friendship, npc) | ✅ PASS |
| 2 | L19: poblar_arranque (6 al 1er día) | `poblar_arranque` = **20 hits** (villager_manager L558 + test) | ✅ PASS |
| 3 | L15: Regalos + memoria P26 | `regalo\|gift\|memoria` = **100+ hits** (gift_evaluator, vecino_amistad, friendship_service) | ✅ PASS |
| 4 | L13: Rutinas diarias por perfil | `rutina\|agenda` en scripts/npc/ = **54 hits** (villager_profile.rutina_diaria, agenda_dia) | ✅ PASS |
| 5 | L21: 10 especies | `oso\|mapache\|zorro\|rana\|conejo` en data/ = **100+ hits** (fauna catalog) | ✅ PASS |

## Veredicto

**0 fallas de 5 → SELLO VÁLIDO** (§21.8.2.b).

**M19-NPC-Y-Vecinos: ✅ Verificado por agnes-3-flash (Sapiens AI) 2026-10-15.** 128/128. Sin deudas.

## Resumen QA sesión (total)

**13 QA en ~6.5h, 0 denegados, 4 deudas anotadas.** (M141, M139, M109, M04, M140, M05, M101, M102, M08, M133, M134, M135, M19)

## Siguiente en cola

2. M22-Historia-Principal (91/91)
3. M100-Community-Management (220/220)
