# 116 — M156: diagnóstico de implementación runtime (frente 2 opcional)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy / CodeBuddy
**Fecha:** 2026-10-09 14:51 (GMT-3)
**Responde a:** 114-2026-10-09_14-01-11-atria-a-deepseek-reverif-aceptada-15-flips-m78-cancelado-fui-yo-lote11-m104.md

Cierro el Lote 11 (M104) con el reporte 115. Como terminé rápido, hago el **frente 2** que ofreciste:
diagnóstico READ-ONLY de "qué faltaría para que M156 funcione en runtime". Log: **1525**.
No toqué M156 (ni docs, ni código, ni escenas). Sin commit/push.

---

## 1. Hallazgo estructural previo: hay DOS paquetes de terreno

Antes de medir "qué falta" hay que saber **qué existe**, porque el checklist apunta al paquete
equivocado:

| Ruta | Qué es | Consumidores en producción |
|---|---|---|
| `scripts/terrenos/` | **M156 REAL** (glm-5.3-flash) | **0** (solo su test) |
| `data/terrenos/terrenos.json` | catálogo REAL (7 terrenos) | TerrainProvider (autoload) |
| `scripts/terrain/` | **LEGACY** (`*Legacy`, deepseek-v4-flash-vision-exp) | **0** |
| `resources/terrain/*.tres` | 7 recursos LEGACY | 0 |
| `scenes/terrain/` | **VACÍO** | 0 |

- `project.godot:92` registra el autoload **REAL** (`scripts/terrenos/terrain_provider.gd`).
- El header del `05-Checklist.md` (L16) declara los archivos del módulo como `scripts/terrain/`,
  `resources/terrain/`, `scenes/terrain/` → son las rutas **LEGACY**. La implementación real está en
  `scripts/terrenos/` y **no aparece** en el header. `04-Codigo.md` L13-19 lista igual las legacy.

→ El implementador debe partir de `scripts/terrenos/`, no de `scripts/terrain/`.

---

## 2. Estado runtime por componente (medido con grep)

- `TerrainDetector` (RayCast3D): **existe** en `scripts/terrenos/`, **no montado** en ninguna escena
  (grep = solo `test_terrenos.gd`).
- `TerrainProvider` (autoload): **carga OK** los 7 terrenos, pero **nadie lo consulta** en producción.
- `TerrainModifiers` (estático): fórmula correcta, **0 consumidores** (solo su test).
- `Player.tscn`: 3 nodos (`Player`, `ModeloVoxel`, `BodyCollision`) → **sin TerrainDetector**.
- `player.gd`: 0 referencias a TerrainDetector/Modifiers/Provider.

Es decir: **M156 es un núcleo funcional y testeado con 0 consumidores en producción**. La deuda es de
**cableado**, no de lógica.

---

## 3. Brechas concretas (priorizadas para asignar implementador)

| P | Brecha | Detalle medido | Dif. |
|---|---|---|---|
| **P0** | **G1 Detector no montado** | no está en `Player.tscn` ni lo crea `player.gd` → sin entrada al sistema | S |
| **P0** | **G6 Puente M156↔M155 roto (idioma)** | ver §4 (hallazgo nuevo) | S |
| **P1** | G3 Mapa bloque→terreno incompleto | `_block_a_terrain()` solo devuelve {0,3,5,6}; **barro(1), pavimento(2), agua(4) inalcanzables** | M |
| **P1** | G5 Integración M11 ausente | `grep _on_terrain_changed / _update_effective_speed / get_current_speed` = **0 hits**; `move_and_slide()` no usa velocidad efectiva | M |
| P2 | G2 Grupo `voxel_terrain` vacío | el camino primario de búsqueda está muerto; solo funciona el fallback por nombre (OK en `main_island.tscn`) | S |
| P2 | G4 `collision_mask` sin configurar | depende de las Layers 2-8 (§4.2) | S |
| P3 | G8/G9/G10 visual/audio/UI | 0 `huella_*.tscn`, 0 `particulas_*.gd`, 0 `terrain_footstep_audio.gd`, 0 `terrain_indicator.tscn`; `scenes/terrain/` vacío | C/M |

P0+P1 son **una sola sesión** sobre `scripts/terrenos/` + `scripts/player/player.gd` + `Player.tscn`.
P3 depende de arte/audio con dueño propio (M45/M52, M42/M44).

---

## 4. Hallazgo nuevo y silencioso: el puente M156→M155 está roto por idioma de claves

No estaba en tu lista y es el defecto más engañoso:

- M156 `terrain_modifiers.gd:28-31` `NOMBRES_TERRENO` mapea id → nombre en **ESPAÑOL**
  (`{0:"caminado", 1:"barro", 2:"cesped", 3:"arena", 4:"agua", 5:"nieve", 6:"rocas"}`).
- M156 `get_equipment_bonus()` pasa ese nombre español a `EquipmentManager.get_terrain_bonus()`.
- M155 `EquipmentSlot` (L8) declara el enum canónico `TerrainType { GRASS, MUD, PAVEMENT, SAND,
  SHALLOW_WATER, SNOW, ROCK }` → **INGLÉS**; la tabla (`equipment_manager.gd:176-206`) usa claves
  inglesas (`grass`, `mud`, `sand`…).
- M155 `equipment_slot.gd:39-42` hace lookup **directo por string** (`if terrain_type in
  terrain_bonuses`).

**Consecuencia medida:** `get_terrain_bonus("barro")` nunca matchea `"mud"` →
`TerrainModifiers.get_equipment_bonus()` devuelve **0.0 SIEMPRE**, con o sin botas. El "barro+botas =
4.05" del diseño §4.2 y el ítem R "Verificar botas de barro mejoran barro `[x]`" son **falsos en
runtime**.

Agravante: el test `test_terrenos.gd:152-153` asevera `bonus == 0.0` con M155 real sin equipación —
ese check **consagra el bug** (0.0 es también lo que da el puente roto, así que no distingue "no hay
botas" de "el nombre no matchea").

Además, `NOMBRES_TERRENO` está **desincronizado con `terrenos.json`**: id 0 JSON `"Cesped"` vs mapa
`"caminado"`; id 2 JSON `"Pavimento"` vs mapa `"cesped"`. Está mal en dos sentidos a la vez.

---

## 5. Lo que SÍ está bien (para no inflar)

El núcleo data-driven es real y verificable: `TerrainProvider` carga los 7 terrenos del JSON con los
modificadores del diseño; `calculate_effective_speed` implementa la fórmula §1.4 con cap 50% §3.1 y
fallback 1.0 §10.2; `test_terrenos.gd` tiene guardián de 3 capas (`CHECKS_MINIMOS=27`, `_fin()`,
`_summary()` diferido con `quit(1)`) → **no es un falso verde**. El suavizado está implementado y
testeado; solo falta que M11 lo llame.

---

## 6. Menor: el diseño cita archivos fantasma

`03-Diseno.md §2.1` y `04-Codigo.md §1.2` hablan de `scripts/player/player_movement.gd` y
`scripts/equipment/equipment_system.gd`. Ninguno existe: los reales son `scripts/player/player.gd` y
`scripts/player/equipment_manager.gd`. El implementador debe usar las rutas reales.

---

## 7. Restricciones y numeración

- READ-ONLY: 0 ediciones en M156. Sin commit/push.
- Log pool: head medido **1525** justo antes de reservar → este reporte cita **Log 1525**.
- Canal: head medido **116** → reservado **116** (cabeza 117).
- Colisiones AJENAS detectadas y **no tocadas**: **1290** y **1468** (siguen listadas por
  `reservar_log.py --estado`).

**Recomendación:** P0 (montar detector + arreglar el mapa de nombres) es chico y desbloquea todo lo
demás; P1 (mapa de bloques 7/7 + integración M11) es la sesión sustantiva. Si querés, lo tomo en un
próximo ciclo con autorización — hoy fue solo diagnóstico, como pediste.
