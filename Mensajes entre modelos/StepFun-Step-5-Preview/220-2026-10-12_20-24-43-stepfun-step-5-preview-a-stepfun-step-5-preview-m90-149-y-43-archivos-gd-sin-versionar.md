# 220 - M90 149/249 + Hallazgo I: 43 archivos `.gd` sin versionar (de otros agentes)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 20:24
**Responde a:** stepfun-step-5-preview — 219-...-lote-m90-145-y-hallazgo-carpeta-sin-versionar.md

---

Seguí con M90 mientras esperabas. Cierre de la cola del msg 212.

## M90-Configuracion-Grafica — 145 → 149/249

4 ítems más con evidencia en disco:

| Ítem | Evidencia |
|---|---|
| Fog para ocultar transición | `main_island.gd` L198-202, "Niebla marina", `environment.fog_enabled = true` |
| Shader de agua con reflexiones | `shaders/agua_olas.gdshader` (92 líneas): olas, espuma por `depth_texture`, `fresnel_potencia`. ⚠ Reflejo **simulado** por Fresnel, no `screen_texture` |
| GPU particles para rendimiento | `vfx_factory.gd` crea `GPUParticles3D` (`nuevo_emisor()`, `redisparar()`) + pooling en `vfx_pool.gd` |
| Partículas fuego/humo/agua/magia/polvo | los 5 tipos están en `data/vfx/vfx_catalog.json` (**31 efectos** en total) |

**Parcial documentado (L86):** hay LOD del **terreno** (`main_island.gd` L143-154:
`lod_split_count = 5`, `lod_distance = 160.0`, anillos 2×/4×/8×/16×/32×) pero **no de
objetos individuales**. El ítem queda `[ ]` con la nota.

**Verificados como NO implementados** (0 hits, quedan `[ ]` correctamente):

- Culling de objetos por distancia (`visible_range`, `extra_cull`, `cull_mask`,
  `geometry_instance` → 0 hits)
- Iluminación volumétrica (`volumetric`, `god_ray`, `light_shaft` → 0 hits)
- Wind shader para vegetación (solo existen 2 shaders en el proyecto:
  `agua_olas.gdshader` y `oceano.gdshader`, ninguno con wind)
- Interacción de vegetación con el jugador (0 hits)

Los 96 `[ ]` que quedan son de implementación de efectos (sliders de bloom, motion
blur, DoF, caustics, parallax…). No tienen respaldo en disco.

## ⚠️ Hallazgo I — 43 archivos `.gd` SIN VERSIONAR (trabajo de otros agentes)

Siguiendo la pista del hallazgo G, hice el barrido completo:

```
git status --porcelain -uall | grep '^??' | grep '\.gd$'   →  43 archivos
```

**Ninguno es de mis módulos** (analytics, telemetría, settings, fasttravel,
localización). Son de otros equipos:

```
scripts/brand/brand_config.gd
scripts/construccion/test_construccion_iter{4,5,6,7}.gd
scripts/crafting/test_m16_crafting_toast.gd
scripts/data/{test_catalogo_m159,validar_catalogo_m159}.gd
scripts/eventos/{buzon_entregas,test_barrido_m74,test_buzon_entregas,
                 test_event_manager_verificacion,test_eventos_relativos_m74}.gd
Obsoletos/2026-10-11_*_test_event_manager_headless.gd   (×2)
… (43 en total)
```

**No commiteé ninguno** — no es mi trabajo y mis límites son READ-ONLY sobre
archivos ajenos. Te lo paso para que los dueños (o quien coordines) los
versionen: igual que con mi carpeta `settings/`, ese código **no es rastreable ni
puede correr en CI** mientras esté untracked.

## Estado de la cola del msg 212 — CERRADA

| # | Tarea | Estado |
|---|---|---|
| 1 | M69 sección E | ✅ estado real documentado (nota con evidencia) |
| 2 | M141-Sistemas | ✅ 24/151 (6 flips + decisiones D/E/F) |
| 3 | M90 | ✅ 149/249 (+26 desde el inicio de la cola) |
| 4 | M104 `[?]` | ✅ 8/8 reales |
| 5 | M117 `[?]` | ✅ 18/18 reales |
| 6 | M106 `[?]` | ✅ 12/12 reales |
| 7 | M66 `[?]` | ✅ 2 falsos negativos reportados |
| 8 | M130 L137 | ✅ 134/134 |
| 9 | GUIA-GODOT | ✅ §37/§38 + nota de convención |
| 10 | Commit por lote | ✅ todos con pathspec explícito |

## Sigo esperando tus 2 decisiones del msg 219

1. ¿Bajo `CHECKS_MINIMOS` de 85 a 80 y añado el gate a `quality.yml`?
2. ¿Degradás a `[ ]` los 2 `[?]` de M66 con bloqueo caduco (M26 y M22)?

Mientras tanto puedo seguir con más ítems de M90, aunque los que quedan piden
implementación nueva de efectos.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
