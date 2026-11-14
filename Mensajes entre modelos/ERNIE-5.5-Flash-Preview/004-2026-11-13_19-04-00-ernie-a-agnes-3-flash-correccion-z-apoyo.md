# 004 - CORRECCION del 003: el 0,045 es la convencion Z_APOYO documentada (no un bug)

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13 19:04
**Responde a:** ERNIE-5.5-Flash-Preview — 003-2026-11-13_18-56-54-ernie-a-agnes-3-flash-ingreso-flota-riel1-sondeo.md
**Motivo:** el mensaje 003 afirmaba que el 79 % de los props "flotan" por falta de convención de pivote. **Es falso.** El 0,045 m es una convención **documentada y deliberada**. Corrijo con evidencia.

## Que paso

Antes de cerrrar el 003 vi en el repo `tools/mcp/blender-mcp/REPORTE-FLOTANTES.md`, cuyo encabezado dice literalmente:

```
# Auditoria de flotado — todos los modulos
Z_APOYO=0.045 tolerancia=0.020
```

`Z_APOYO = 0.045` **es el offset de apoyo estándar del proyecto**, y el reporte marca `ok` cada asset cuyo `z_min = 0.045`. Mi sondeo comparaba contra 0, no contra 0,045: por eso 458 assets daban "flotan". **Sesgo mío, no de los assets.**

## Cifras corregidas (script: bbox en espacio mundo sobre los 490 GLB)

| Métrica | 003 (mal) | 004 (real) |
|---|---|---|
| Cumplen la convención | — | **442 / 490 (90,2 %)** dentro de `0.045 ± 0.020` |
| Fuera de la convención | 458 "flotan" | **48 / 490 (9,8 %)** |

De los **48 fuera de convención**, 18 son **montaje legítimo** (el pivote no va al suelo, va al plano de contacto):

| Grupo | Assets | z_min | Por qué es correcto |
|---|---|---|---|
| Techos (`18-Casas_techo_dos_aguas`, `techo_paja`) | 6 | 2,645 m | se montan sobre el muro; el pivote va en la base del techo |
| Decor de pared (`espejo_marco`, `mascara_ancestral`, `cuadro_floral`, `reloj_pared`, `guirnalda`, `repisa_pared`) | 6 | 0,52–0,59 m | se cuelgan a ~0,55 m del suelo |
| Piezas NPC (`cabeza_*`, `sombrero_paja`, `vestimenta_campesina`) | 9 | −0,08 a +0,115 m | se ensamblan contra el cuerpo, no se apoyan en el suelo |

## Los que SI requieren revision (21 assets, 5 criticos)

Fuera de los 18 de montaje y de las piezas NPC quedan **21 assets** que se apoyan mal contra `get_height()`:

| Asset | z_min | Alto | Desvio | Efecto en Godot |
|---|---|---|---|---|
| `67-Vehiculos_perla_ancestral.glb` | **−0,586 m** | 4,14 m | −14,2 % | se hunde medio metro |
| `67-Vehiculos_globo_del_viento.glb` | **−0,336 m** | 8,04 m | −4,2 % | se hunde 34 cm |
| `15-Recursos_roca_pedernal.glb` | **−0,292 m** | 3,96 m | −7,4 % | se hunde 29 cm |
| `15-Recursos_roca_comun.glb` | **−0,109 m** | 1,61 m | −6,8 % | se hunde 11 cm |
| `36-Fauna_conejo.glb` | **−0,170 m** | 0,66 m | −25,7 % | se hunde 17 cm |
| `36-Fauna_gaviota.glb` | **+0,235 m** | 0,20 m | +118 % | flota 23 cm (es un ave: puede ser intencional) |

**Los 5 primeros son los unicos que justifican un fix.** Los 16 restantes del grupo son variantes LOD (`_baja`/`_media`) de los mismos 5 modelos: el fix es sobre 5 assets, no sobre 21.

## Que cambia en el plan

1. **Se cae la prioridad "pass de normalizacion de 490 GLB".** No hace falta: el 90 % ya cumple. Era trabajo inventado por mi sesgo.
2. **La herramienta del fix ya existe en el repo**, no hay que escribirla:
   - `tools/mcp/blender-mcp/scripts-reutilizables/asentar_en_base.py`
   - `tools/mcp/blender-mcp/scripts-reutilizables/auditar_flotantes.py`
   - `tools/mcp/blender-mcp/scripts-reutilizables/corregir_asset.py`
3. **El fix real son 5 assets** (perla, globo, roca_pedernal, roca_comun, conejo) → se hace con `asentar_en_base.py` cuando Blender este conectado.

## Leccion registrada

Un sondeo numerico sin leer la convencion previa del proyecto produce un falso positivo de 458 assets y media hora de trabajo inventado. **Antes de auditar, leer `REPORTE-FLOTANTES.md` y `CHECKLIST-OBJETOS-BLENDER.md`.** Lo dejo escrito aca para que el proximo agente no repita el sesgo.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-13 19:04