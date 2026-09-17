# M96 — Matriz de Plataformas (formato único)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-16 (iter. agnes, Log 924)

> **Fuente de datos:** `game/isla-ancestral/data/plataformas/plataformas.json` (10 plataformas, verificado
> 2026-09-16 con `test_plataformas_m96.gd` 30/0). Esta tabla es el **formato único** de la matriz (RF1,
> ítem §1.4) — derivada del JSON; si el JSON cambia, **regenerar esta tabla** (M144 revisión trimestral).
> Símbolos: ✓ = sí · — = no.

## Tabla de la matriz

| Ord | Plataforma | Prioridad | Tipo | Tienda | Logros | Cloud | Cross-save | Deck | Coste devkit | Fee dist. |
|----:|------------|:---------:|:----:|:------:|:------:|:-----:|:----------:|:----:|:------------:|:---------:|
| 1 | Steam | P0 | pc | ✓ | ✓ | ✓ | ✓ | ✓ | $0 | 30% |
| 2 | Steam Deck | P0 | portátil | ✓ | ✓ | ✓ | ✓ | ✓ | $0 | 30% |
| 3 | Epic Games Store | P1 | pc | ✓ | ✓ | ✓ | — | — | $0 | 12% |
| 4 | GOG | P1 | pc | ✓ | — | ✓ | — | — | $0 | 0% |
| 5 | macOS | P1 | pc | — | — | — | — | — | $0 | 0% |
| 6 | Linux (Proton) | P1 | pc | — | — | — | — | — | $0 | 0% |
| 7 | PlayStation | P2 | consola | ✓ | ✓ | ✓ | — | — | $5000 | 30% |
| 8 | Xbox | P2 | consola | ✓ | ✓ | ✓ | — | — | $5000 | 30% |
| 9 | Nintendo Switch | P2 | consola | ✓ | — | ✓ | — | — | $5000 | 30% |
| 10 | Microsoft Store | P3 | pc | ✓ | ✓ | ✓ | — | — | $0 | 30% |

## Notas por plataforma (de `nota` en el JSON)
- **Steam (P0):** plataforma principal. SDK Steamworks + logros + cloud + overlay.
- **Steam Deck (P0):** "Steam Deck Verified" (800p + gamepad + textos legibles).
- **Epic (P1):** SDK EOS, logros, cloud. Fee 12% (mejor que Steam). Gate: presupuesto QA.
- **GOG (P1):** DRM-free, sin logros obligatorios, GOG Galaxy SDK.
- **macOS (P1):** Apple Silicon + Intel, build nativo. Gate: perf en M1/M2.
- **Linux (P1):** Proton test en CI (reporte mensual manual). No nativo.
- **PlayStation (P2):** PS SDK + certificación. Gate: presupuesto + certificación M142.
- **Xbox (P2):** XDK + certificación. Gate: presupuesto + certificación M142.
- **Nintendo Switch (P2):** NDA + eShop + políticas de contenido. Sin logros de plataforma. Gate: presupuesto + certificación M142.
- **Microsoft Store (P3):** UWP/Xbox Game Pass si corresponde. Gate: presupuesto + QA.

## Cláusula documentada: cross-play NO aplica (§21.2, RF P20)
> **Decisión:** no hay cross-play. **Porqué:** el juego es **single-player por diseño** y **no tiene
> servidores propios ni red entre jugadores** (no hay M77 de multijugador/online P2P). El único intercambio
> de datos es **save→cloud de cada plataforma** (cross-save Steam↔Steam Deck automático, vía `IPlatformBridge`),
> que es **portabilidad de datos, no juego compartido**. **Re-evaluación:** solo si un futuro DLC agrega
> **cooperación local** (revisión en M144). Documento de respaldo: `05-Checklist.md` §21.

## ¿Quién decide qué (owner de las `[ ]` restantes)
Las decisiones **de política/presupuesto** NO las tomo yo (no invento GATE de presupuesto/NDA):
- Consolas P2 (PS/Xbox/Switch) + MS Store P3 → **GATE presupuesto/NDA — dueño fundador/M142**.
- Costes devkits/testing/total → **M149 (presupuesto marketing)**.
- Prioridades/recursos/ventanas + revisión trimestral → **M144**.
- Requisitos de rendimiento probados → **M61**.
- Mapeo logros offline/catch-up → **M59**. Portabilidad save v3.x → **M60**. UI/remapeo gamepad → **M57/M58**.
