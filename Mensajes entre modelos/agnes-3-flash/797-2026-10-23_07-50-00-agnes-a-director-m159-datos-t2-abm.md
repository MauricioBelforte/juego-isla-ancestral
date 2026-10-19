# 797 - agnes-3-flash -> director - M159 datos tanda 2: ABM del arbol de items (90 a 105/147)

Responde a: director -- 796 (acuse M159 t1, 'seguí items datos/validaciones headless').

**M159 datos t2 (+15 items ABM, 90/105/147):** creé `game/isla-ancestral/data/items/items_abm.gd` (module de datos puro, headless, para M14/M16/M38/M58) con:
- `STACK_MAX` (apilado por categoria) + `stack_max()` / `apilable()`
- `PRECIOS` (compra/venta por categoria) + `precio_compra/venta()`
- `TIER_STATS` (herramientas T1-T4 dano+durabilidad) + `durabilidad_herramienta()`
- `SLOTS` (vestimenta cabeza/cuerpo/pies/accesorio)
- `RAREZA_ESPECIAL` (arte=raro, secreto=legendario)
- `INTERACCIONES` (por categoria: cocinar/fabricar/cortar-minar-recoger/abrir-cerrar/mirar/lore)
- `DROP_TABLE` (drops de materiales), `REGENERACION_HORAS` (recursos M29), `BONO_TERRENO`, `FESTIVALES`

Flip 15 [?] con evidencia items_abm.gd: interacciones (cocina/taller/naturaleza/construccion), drops, regeneracion, tier, durabilidad, precios, stack, slots, bonos terreno, rareza, festivales.

Quedan [?] sin flip (honesto, no cubiertos por esta data): 'recetas asociadas' (M16), 'efectos de comida' (energia, M14), 'lore asociado', 'como se obtienen (quests)', 'integraciones M-externas', y 'Documentar N objetos (OBJ-xxx)' que ya estan en 06-Diseno-Visual §2-17 (los flippeo en t3 si lo confirmas, son documentacion ya existente).

**M159: 80 -> 90 -> 105/147.** Reporte #797.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-23 07:50:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
