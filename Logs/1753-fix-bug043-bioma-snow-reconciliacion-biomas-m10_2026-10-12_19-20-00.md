# Log 1753: Fix BUG-043 (bioma snow inalcanzable) + reconciliacion diseño↔runtime de biomas M10

**Fecha:** 2026-10-12
**Hora:** 19:20
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo-v2.6-flash-free, mensaje #32 del canal atria-dawn): reconciliación diseño↔runtime de biomas del M10 y resolución del BUG-043 (bioma "snow" inalcanzable). Se aplicó el fix (reordenar los checks de `_get_biome`), se incorporó el bioma `wetland` (eje de humedad que faltaba según M09 §3 regla 1) y se documentó el mapeo completo de los 13 biomas del diseño contra los 6 que produce el generador de la Isla Raíz.

## Cambios Realizados

### 1. Fix BUG-043 — `island_generator.gd::_get_biome`

**Causa (confirmada en disco):** el check de `mountain` (h > 0.65×max_height = 26) se evaluaba ANTES que el de `snow` (h > 0.8×max_height = 32). Toda celda con altura de cumbre nevada pasaba el umbral de montaña primero y devolvía "mountain". Muestreo del Log 945: mountain=80, snow=0 sobre 2000 posiciones, con altura máx real 38 > 32.

**Fix:** `snow` (0.8) ahora se evalúa antes que `mountain` (0.65). El perfil de alturas del usuario (max_height 40, Log 791) quedó intacto — solo se reordenaron dos bloques `if`.

### 2. Bioma `wetland` incorporado (mismo archivo)

M09 03-Diseno §3 regla 1 pide mezcla por **dos ejes** (altura + humedad); el generador usaba la humedad (`_biome_noise`) solo para separar bosque de pradera. Ahora también alimenta `wetland`: humedad > 0.45 y altura ≤ 8 → superficie y subsuelo **MUD** (id 29, ya existente en BlockType y en la library inline de main_island.gd). No se crearon bloques nuevos. Reglas de agua (beach h≤3) y altitud (snow/mountain) quedan por encima, así que el humedal ocupa la banda 4-8 en zonas húmedas.

### 3. `get_block_at` — superficie y subsuelo de wetland

Superficie: `wetland` → `BlockType.MUD`. Subsuelo (y > height-3): `wetland` → `BlockType.MUD`.

### 4. Reconciliación diseño↔runtime (13 biomas de M09 §2)

El catálogo de M09 cubre TODAS las islas del juego; `island_generator.gd` genera solo la Isla Raíz (Aurora). Mapeo documentado en 04-Codigo.md §7:

- **6 producibles por heightmap+ruido en la Raíz, los 6 ahora presentes:** costa→beach, pradera→grassland, bosque→forest, humedal→wetland (nuevo), montaña→mountain, cumbre→snow (fixeado).
- **3 de otras islas (no aplican):** desierto (isla Viaje), tropical (Coral/Verde sur), volcánico pacífico (roadmap Cenizas).
- **2 de colocación narrativa (no por ruido, M09 §3.5):** ruinas (M22/M26), resonancia (M26 Templo de la Brisa).
- **2 requieren features de terreno que el generador actual no tiene:** valle (heightmap puro, sin depresiones), nevado (fusionado con cumbre; con max_height=40 no hay rango de nieve a baja altura).

**Conclusión:** la brecha "5 vs 13" no era principalmente un defecto; el faltante real en la Raíz era el humedal, ahora incorporado.

### 5. Tests — `test_generacion_m10_atria.gd`

- `_test_bioma_novible_alcanzable`: antes fallaba por diseño (snow=0); ahora debe pasar tras el fix. Comentario actualizado.
- Nuevo `_test_bioma_humedal`: muestrea 2000 posiciones y verifica cobertura > 0 de los 6 biomas del pipeline (beach, grassland, forest, mountain, snow, wetland).
- Header firmado y fechado.

**NO ejecutados:** Godot no es ejecutable en este sandbox. Quedan pendientes de CI/headless.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/world/island_generator.gd` — `_get_biome` (reorden snow/mountain + wetland), `get_block_at` (MUD en superficie y subsuelo de wetland)
- `game/isla-ancestral/scripts/world/test_generacion_m10_atria.gd` — header, `_test_bioma_novible_alcanzable` (comentario post-fix), nuevo `_test_bioma_humedal`
- `DOCUMENTACION/10-Generacion-Del-Mundo/plan-actual/04-Codigo.md` — nueva sección §7 (reconciliación + fix BUG-043 + wetland); firma actualizada
- `DOCUMENTACION/10-Generacion-Del-Mundo/plan-actual/05-Checklist.md` — ítem Capa 2 Biomas actualizado (6 biomas, fix BUG-043); sección de hallazgos con BUG-043 resuelto; recomendación 2 tachada como HECHA; firma actualizada

## Lo que NO se hizo (honestidad obligatoria)

- **Tests sin ejecutar** (sin Godot en el sandbox). Pendiente de CI/headless: `Godot --headless --path game/isla-ancestral --script res://scripts/world/test_generacion_m10_atria.gd` → esperar 0 fallos.
- **Sin validación visual** (V4 godot-mcp / V5 blender): no se vio la cumbre nevada ni las manchas de humedal en runtime.
- Los 7 hallazgos previos del QA (Log 945) quedan fuera de alcance: capas 3/4/8, carbón/oro inexistentes, `BlockCatalog` muerto, `_has_ore` allocando FastNoiseLite por bloque, knobs en data/.
- No se tocaron CHECKLIST-GLOBAL ni se aplicaron flips de marca (reglas del director). No se committeó.

## Notas para el director

- BUG-043 queda resuelto en código; el sello/marca corresponde al director. El ítem 43 del 05-Checklist sigue `[?]` porque los tests no corrieron — la degradación a `[x]` requiere CI headless.
- Claim del encargo corregido: los archivos `island_design_catalog.gd`, `island_definition.gd` y `generar_islas.gd` citados en el mensaje #32 NO existen; los reales son `island_generator.gd` y `terreno_horizonte.gd` bajo `game/isla-ancestral/scripts/world/`. La carpeta de M09 es `09-Terreno-Y-Geografia` (no "09-Terreno-Geografia").
