# Log 568 — workbuddy · M19 · Composición NPC v5 + sombrero de paja (2026-09-03)

## Pedido del usuario
> "este me gusta bastante mas pero me gustaba el sombrero del anterior lo podes
> recuperar? o diseñaste 2 npcs?"

Respuesta corta: **es un solo NPC**. El sombrero es un asset aparte
(`19-NPCs_sombrero_paja.glb`) que en Godot se instancia como hijo de la cabeza.
Las capturas de `npc_base` lo muestran sin sombrero por diseño (el sombrero es
montable, no forma parte del cuerpo).

## Trabajo
1. Se creó `tools/mcp/blender-mcp/19-NPCs/scripts/componer_npc_sombrero.py`
   para componer NPC + sombrero en una escena de verificación (NO fuente de
   export: el nombre del .blend NO termina en `_alta/_lowpoly/...`, así que
   `exportar_godot.py` lo ignora — E-63).
2. Bug del path original: `RAIZ = abspath(join(dir(__file__), '..', '..', '..',
   '..'))` desde `.../19-NPCs/scripts/` resolvía a `.../juego-isla-ancestral/
   tools` (un nivel corto), y luego `DIR_MOD = join(RAIZ, 'tools', ...)`
   duplicaba el segmento. Manifestación:
   `Cannot read file "...\tools\tools\mcp\blender-mcp\19-NPCs\npc_base..."`.
3. Fix (E-82): reemplazar la pareja `RAIZ`+`DIR_MOD` por construcción directa
   desde `DIR_SCRIPTS = dirname(abspath(__file__))`:
   ```python
   DIR_MOD = abspath(join(DIR_SCRIPTS, '..'))          # scripts -> 19-NPCs
   DIR_REUTIL = abspath(join(DIR_SCRIPTS, '..', '..', 'scripts-reutilizables'))
   RAIZ = abspath(join(DIR_MOD, '..', '..', '..'))     # 19-NPCs -> repo root
   ```
4. Run OK:
   - NPC cargado con 17 objetos.
   - 6 piezas del sombrero traídas por append.
   - **Guard de encaje** sobre el NPC v5 real:
     - copa z_min = 1.535, cima pelo = 1.612 → **PELO CONTENIDO** (7.7 cm de
       overlap; la copa engulle la coronilla).
     - ala frontal z_min = 1.513, ojos z = 1.445 → **CARA LIBRE** (6.8 cm de
       clearance sobre los ojos).
     - verts de la copa dentro del cráneo (+2cm) = 0 → "FLOTA" (pero el sombrero
       va sobre el pelo, no sobre el cráneo — el test es engañoso para hats).
     - diámetro del ala = 0.601 × 0.509 m (60 cm — ala ancha de granjero, en
       escala con NPC de 1.6 m).
   - Escena guardada en
     `19-NPCs/capturas/npc_con_sombrero_VERIF.blend` con 23 objetos / 20 SM_.
5. 6 capturas orbitales (az000/060/120/180/240/300) generadas con
   `capturar_angulos_headless.py`, prefijo `SM_NPC`.
6. Hoja de contacto `_hoja_npc_con_sombrero_v5.jpg` (33 KB) generada con
   `contact_sheet.py` y **leída con éxito** (el filtro multimodal sí aceptó
   esta vez).

## Verificación visual
La hoja muestra: sombrero de paja con cinta roja y lazo rosa lateral, copa
calzada sobre el pelo (no flota, no tapa la cara), ala ancha horizontal,
cuerpo v5 con torso de pecho profundo + hombros cap elipsoidales + cintura
marcada por cinturón de cuero, shorts A-line, piernas, sandalias. Sin aire
entre pies y arena. Sin acción.