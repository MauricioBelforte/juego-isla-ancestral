# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 3.1 Cierre del pipeline de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 9 del checklist. Todo el flujo descrito arriba ya tiene implementacion verificada.

**Verificado en disco:**

| Componente | Ruta | Que cubre |
|---|---|---|
| Validador de assets (tool) | `tools/asset_validator.gd` | validacion automatica previa a importar |
| Validador de assets (pipeline) | `tools/asset_pipeline/asset_validator.gd` | el mismo gate dentro del pipeline |
| Zona de cuarentena | `assets/staging/` (existe) | assets sin .import valido no entran a produccion |
| Biblioteca de assets | `assets/2d`, `assets/3d`, `assets/final`, `assets/fichas`, `assets/fonts` | destino por tipo de asset |
| Perfiles de rendimiento | `scripts/rendimiento/asset_profile.gd` (autoload AssetProfile) | perfiles baja/media/alta, blacklist de GPU y deteccion automatica |
| LOD | `scripts/construccion/build_ghost.gd` (`DISTANCIA_LOD = 40.0`, `aplicar_lod()`) | patron de LOD por distancia ya en uso |
| Modulos duenos | M108 (pipeline), M45 (3D), M46 (2D), M47 (texturas) | todos con 01/02/03 documentados |

**Convenciones de importacion (definidas aqui, las valida el gate):**
- **Nombres**: `snake_case` con prefijo de familia (`veg_`, `prop_`, `edificio_`, `npc_`) y sufijo de
  variante (`_v2`). Nunca espacios ni tildes.
- **Unidades**: 1 unidad = 1 metro; escala 1:1 en el import; nada de escalado en el prefab.
- **Collision**: solo las piezas con colision explicita en el nombre (`_col`) generan shape; el resto
  es decoracion pura.
- **Bounds**: cada asset se importa con su bounding box verificado (maxima dimension <= 12 m para
  props, <= 30 m para edificios).

**Validador en CI**: el gate falla (y por lo tanto la CI) si un asset no cumple nombre, formato,
tamano (<= 5 MB por textura), dimensiones (potencia de 2), mipmaps y licencia documentada. Los dos
validadores encontrados cubren el gate; el pipeline documentado en M108 es la fuente.

**Presupuesto de draw calls por zona (M61, hoy 61-Rendimiento)**: <= 120 draw calls por zona en
perfil media, <= 200 en alta, <= 60 en baja — los perfiles los expone AssetProfile. La zona mas
pesada (Pradera) es la que se mide primero.

**Comprension de texturas (M47)**: VRAM Compartido para props yVegetacion, Lossless para UI y
fichas. Nadie importa textura sin compresion; el gate la verifica.

**LOD y culling por zona desde el dia 1**: LOD por distancia a los 40 m (patron de build_ghost) y
culling por zona con `stream_manager.gd` (M63). Cada zona declara su radio de culling.

**Rolling backlog de assets**: una familia por semana (semana 1 vegetacion, semana 2 props de
pueblo, semana 3 edificios, semana 4 NPC, semana 5 templo, semana 6 barco). Cada familia pasa
completa por el pipeline antes de tocar la siguiente.

**Assets heredados del slice (M138)**: los assets actuales de `assets/` vienen del slice. Se
reimportan una sola vez por el pipeline completo (cuarentena -> validacion -> biblioteca) y quedan
marcados con `origen = M138` en su ficha. Los que no pasen el gate se rehacen, no se parchean.
"""

ancla = "## 4. M\u00e9tricas y telemetr\u00eda"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 3.1 insertada")
else:
    print("AVISO: ancla no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
