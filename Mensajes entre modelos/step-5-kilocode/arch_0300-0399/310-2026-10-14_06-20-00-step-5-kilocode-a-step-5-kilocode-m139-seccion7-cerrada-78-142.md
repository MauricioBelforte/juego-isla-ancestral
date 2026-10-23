# 310 — M139 sección 7 CERRADA (Templo de Brisa): 65 → 78/142

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 06:20
**Responde a:** step-5-kilocode — 309-2026-10-14_06-00-00-step-5-kilocode-a-step-5-kilocode-m139-seccion6-cerrada-65-142.md

Sección 7 completa (13 ítems, el lote más grande hasta ahora). Commit `a5c95c9`.

## Conteo

| | Sección 6 | Ahora |
|---|---|---|
| `[x]` | 65 | **78** |
| `[ ]` | 75 | **62** |

**Superé la mitad del módulo: 78/142.**

## 4 ítems con respaldo real en disco

- **Lore canónico**: `scripts/eventos/data/capitulos/historia_c4_templo_brisa.tres` — capítulo 4,
  gatillo `templo_brisa_abierto`, 7 sellos requeridos, prioridad 300. El templo ya tiene su
  capítulo de historia como dato real.
- **Anti-softlock**: `scripts/core/invariants/puzzle_invariant.gd` — invariante M66 que valida
  resolubilidad en 30 s y reinicia el slot; más `softlock_guard.gd` y `softlock_rules.gd`.
- **Motor de puzzles**: `scripts/templos/` con `puzzle_def.gd` (MAX_EMISORES 16), `puzzle_agua.gd`,
  `puzzle_bloques.gd`, `puzzle_dificultad.gd`.
- **Mi propia interfaz `i_templo.gd`** (creada esta madrugada para el contrato entre capas) resulta
  ser el contrato que consumiría el templo.

## Definición nueva (§2.7.1)

- **Acceso**: colina N con 2 puzzles ambientales en la subida (3 tallos de semilla + 2 antorchas por
  dirección de viento), ninguno bloquea el paso.
- **Sala 1 "Las Velas"**: 3 velas en orden N→E→S según la ráfaga; el error se perdona solo.
- **Sala 2 "El Carillón"**: 5 campanas con la melodía que susurra el lore.
- **Herramienta del Viento** (M13): recompensa al cerrar las 2 salas, ráfaga con cooldown de 3 s —
  la primera herramienta "climática" del juego.
- **Anti-spoiler** de los otros 5 templos garantizado por diseño (runas genéricas).
- **Hint no intrusivo** recién tras 20 s a <2 m, desactivable en accesibilidad.
- **3 rutas de solución** por sala (orden / observación / ayuda) que convergen.
- **Recompensa extra**: página de lore oculta tras el carillón (M73), visible solo con la
  Herramienta ya obtenida.
- **Efecto global**: con la herramienta, el viento mueve semillas y abre atajos de polen en la
  pradera — primer cambio del mundo por una herramienta.

## próXIMO

Sección 8 (Primer viaje — Gran Vapor, M28/M67/M68). Conteo vigente: **78/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
