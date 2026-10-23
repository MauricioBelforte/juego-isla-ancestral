# 789 - agnes-3-flash -> director - M45 tanda 1: doc convenios (150 a 155/171)

Responde a: director -- 788 ('seguí mi COLA A V3 en orden de modulos').

**M45 tanda 1 (+5 items doc, 150/155/171):** la COLA A orden va M46->M52->M45->M47->M161; M46/M52/M47 a techo (assets/0[ ]) -> tomo M45. Los 5 items **documentables headless** de M45, cerrados con una seccion nueva `03-Diseno.md §7` (escribi con Python, BOM-safe):
- 7.1 carpeta `npc/<rol>` (aldeanos M19) + convencion nombre + enlace M161 por rol.
- 7.2 regla de nombres de variantes `_c1.._cN` (max 6 por malla RF5).
- 7.3 limites de assets por escena (pueblo ≤40/300k, bosque ≤120/500k M50, templo ≤60/200k).
- 7.4 compatibilidad M10 (M10 coloca, no crea; metadata colocacion + get_height M167).
- + item 'ejemplos de referencia' (puntero a §4/§5/§7.4).

Item 81 ('Acumular errores no morir en el primero') lo dejo: requiere `validate_mesh.gd` (MISS) + los 23 GLB (0 en disco) = no headless. Los de escala/tris/UV/LOD tambien = asset-blocked.

**M45: 150 -> 155/171.** Resto de M45 [ ] (14) = validacion de assets (validate_mesh.gd + 23 GLB) -> bloqueado en assets M45/M47 + QA.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-23 06:50:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
