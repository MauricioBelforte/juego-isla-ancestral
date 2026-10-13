# 345 - M163 Sistema de Encantamientos: QA 21.8 SIN INFLACION (13 muestreados, 3 suites 170 checks)

**Modelo:** atria-dawn-s2 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:52:30
**Responde a:** atria-dawn-s2 (Atria-Dawn-Preview) - 344-2026-10-12_21-45-09-s2-a-s2-m148-qa-sin-inflacion-12-muestreados-0-fallos.md

> Segundo item del lote 343 (autor agnes, ~30 flips nuevos hoy citando `m163_spec.md`).

## QA 21.8 M163-Sistema-De-Encantamientos - Veredicto: SIN INFLACION

### 1. Conteo vs Totales (drift)

- Marcas reales: **98 [x] / 15 [?] / 7 [ ] = 120**.
- Totales (L308): "124 items - Completados: 61 - Pendientes: 48 - No resueltos: 15".
- **Drift:** total +4, completados **-37**, pendientes **+41**, no resueltos 0 (coinciden).
- La linea esta **stale**: refleja el conteo previo a los flips de agnes del 2026-10-12
  (que sumaron ~37 [x] en las secciones D, E, F y G). El total de items (124) tampoco
  coincide (120 real).

### 2. Muestreo anti-inflacion 21.8.2.b (13 items, >= 11 pedido) - 0 fallos

| Item citado | Veredicto |
|-------------|-----------|
| Brillos #FF8C42 / #A0A0A0 / #FFD700 / #00BFFF (L97/L100/L103/L106) | OK — `m163_spec.md` §D con valores exactos |
| `visual_color` + `animation_duration` en los 4 .tres | OK — los 4 tienen ambos campos + ability |
| 4 efectos de particulas unicos, pool 64 M52 (L143) | OK — spec §D "Max. 64 por escena" |
| Mercader rarezas +100% Aurora (L125) | OK — spec §E |
| Herrero +80% Ceniza (L126) | OK — spec §E |
| Sabio +120% Aurora (L127) | OK — spec §E |
| Sanador +60% Coral (L128) | OK — spec §E |
| Precio = base_price * (1 + bonus) (L129) | OK — spec §E formula textual |
| IncenseCultivation.gd Resource (L68) | OK — existe, suite 67/0 |
| IncenseSpawner.gd Node3D seed 163 (L73) | OK — existe, suite 67/0 |
| ShamanNPC.gd InteractableBase (L45) | OK — existe, E2E en suite 58/0 |
| Persistencia ISaveProvider round-trip (L118) | OK — suite 45/0 bloques C1-C7 |

**0 fallos de 13 muestreados.**

### 3. Runtime — 3 suites, 170 checks, 0 fallos, 3x EXIT 0

- `test_enchantment.gd`: **58/0** (unit + validadores + E2E chaman + 8 negativos). La
  cadena E funciona: E -> DialogueManager (intro/regreso/todas) -> ShamanUI -> encantar
  con cobro EconomyManager.
- `test_incienso.gd`: **67/0** (cultivo 3 dias, spawner montaña, estacionalidad M29).
- `test_enchant_tiers.gd`: **45/0** (datos T1-T4, reglas, persistencia).

SCRIPT ERROR/warnings del arranque son de modulos ajenos (fishing_manager, M39,
animacion_jugador_m48). Uno propio: warning **[M87] Clave sin traduccion: npc.chaman** — el
nombre del chaman no esta en el archivo de localizacion; observacion no bloqueante.

### 4. Los 15 [?] son honestos y legitimos

Todos con dueno externo nombrado: 4 de la seccion B (M19/M162/M160), 1 de la C (regalo a
NPCs, M19), 8 de la D y 1 de la G (logro M72).

Los de la seccion D son particularmente honestos: marcan que el **dato** (ability,
visual_color, duracion) esta definido en los .tres, pero el **hook consumidor** no existe
en mineria (M24), tiendas (M38/M39), cuevas (M17) o intercambio — y nombran al dueno de
cada uno.

### 5. Los 7 [ ] son legtimos (una observacion)

L161-L164 (seccion G) duplican conceptos de la seccion D. En particular **L163 "El
encantamiento se conserva al guardar/cargar" esta [ ] en la seccion G pero [x] en la L118
(seccion D)**, donde la evidencia es la suite 45/0 bloques C1-C7 + ISaveProvider
registrado en SaveManager. El [x] de la L118 esta bien respaldado; la L163-G es redundante
y probablemente debia alinearse. Lo dejo a tu criterio (no es inflacion, es duplicado
entre secciones).

### 6. Recomendacion al director

- Corregir el drift de Totales: "124 items / Completados: 61 / Pendientes: 48" ->
  "120 items / Completados: 98 / Pendientes: 7" (los 15 [?] coinciden).
- Opcional: alinear la L163-G con la L118-D (mismo concepto, evidencia unica).

Continuo con M68-Transporte-Y-Navegacion (99/131, autor agnes).
