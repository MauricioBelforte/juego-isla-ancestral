# Log 551: Cangrejo de Playa M36 — Asset + NPC Completo

**Fecha:** 2026-09-02
**Hora:** 21:55
**Modelo:** GLM 5.3 (z-ai)
**Plataforma:** Kilo Code

## Resumen

Segundo animal del pipeline Blender→Godot→movimiento (07 §11): cangrejo de
playa aprobado por el usuario **a la primera** (sin iteraciones de diseño,
a diferencia de la tortuga) y llevado al juego con `cangrejo_npc.gd` — camina
DE LADO como los cangrejos reales, 8 patitas remando en secuencia, pinzas
alternadas y ojos curiosos en pausa.

## Cambios Realizados

- **Asset v3** (`crear_cangrejo_playa_lowpoly.py`): caparazón elipse naranja
  con frente caído + 2 pinzas levantadas (loft 1-malla con V de mandíbulas
  integrada) + 8 patitas loftadas con punta PLANA + 2 ojos en pedúnculos
  (tallo+casquete 1 pieza). 13 SM_ / 656 tris / 4 mats · z_min 0.0450 ·
  huella 16 verts 0.53×1.12.
- **Lecciones v1→v3 (checker rechazó 2 veces, bien):** v1 patitas de cono
  con punta de 1 vert → E-50 huella 0.04×0.04 → loft con anillo final
  plano (4+ verts por pata). v2 19 SM_ → E-70 excedido → mandíbulas
  fundidas al loft de la pinza + ojo fundido al pedúnculo → 13. Contar
  E-70 con lista explícita ANTES de escribir, no de memoria.
- **Variantes:** MEDIA 4 obj/656 tris (merge lossless), BAJA 4 obj/456.
- **GLB:** 3 exportados (47/39/30 KB) — OJO: el primer export salió
  incompleto (solo alta); re-ejecutar `exportar_godot.py` y verificar los
  3 por archivos antes de importar. 3 `.import` + 3 `.scn` (E-65).
- **NPC** (`cangrejo_npc.gd`, patrón tortuga §11): camina DE LADO (yaw =
  atan2(dir) − 90°), 8 patitas con fase por índice (oleada), pinzas en
  contrafase, ojos en pedúnculos inclinándose en pausa, bobbing sutil.
  Nodo en `main_island.tscn` (245, 262), radio de paseo 6–20 m.

## Verificación (V4)

- Boot limpio, ambos animales vivos:
  `[Tortuga] nodos animables: 5/5` + `[Cangrejo] en la playa (spawn 245, 262) — 8 patas, 2 pinzas, 2 ojos`
- 60+ s corriendo sin errores propios (los "atascado" y warnings son
  preexistentes de otros módulos).
- Captura: `tools/mcp/godot-mcp/capturas/36-Fauna/cap_36_cangrejo_npc_2026-09-02_21-50.png`

## Archivos Modificados/Creados

- `tools/mcp/blender-mcp/36-Fauna/scripts/crear_cangrejo_playa_lowpoly.py` (nuevo)
- `tools/mcp/blender-mcp/36-Fauna/cangrejo_playa_lowpoly{,_media,_baja}.blend` (nuevos)
- `tools/mcp/blender-mcp/36-Fauna/capturas/` (6 capturas + hoja v1)
- `game/isla-ancestral/scripts/fauna/cangrejo_npc.gd` (nuevo)
- `game/isla-ancestral/scenes/main_island.tscn` (+CangrejoNPC)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/36-Fauna_cangrejo_playa.glb` + `.import`
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (ítem [x])

## Pendiente / Próximo agente

- Validación visual final del usuario (V1) en el juego corriendo.
- Próximos animales del backlog M36: gaviota, pez tropical, lagarto, jabalí,
  cabra, gallina, mariposa. El patrón §11 está probado con 2 casos.
