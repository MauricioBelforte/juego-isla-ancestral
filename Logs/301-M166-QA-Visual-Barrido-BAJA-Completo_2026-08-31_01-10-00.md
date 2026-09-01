# 301 — M166 QA Visual: Barrido BAJA completo (52 assets, 8 módulos)

**Fecha:** 2026-08-31 01:00–01:11 (GMT-3)
**Módulo:** M166 (QA Visual de assets 3D)
**Trigger:** Reanudación con visión activa (E-10 destrabado). El usuario pidió retomar el barrido pendiente de las BAJA nuevas y "cerrar todos los pendientes" antes de cerrar la sesión.

## METODOLOGÍA

- **Barrido:** 4 lotes en background, `qa_lote.py --variante baja --angulos 6`.
- **8 módulos, 52 assets BAJA, 312 capturas orbitales + 52 hojas de contacto.**
- **Cámara:** orbital con SSR activado en script de captura (E-20), 6 azimuts.
- **Criterio de aprobación:** numérico (z_min=0.0450 ±0.020, presupuesto OK en las 3 filas) + visual (no flotación, no hundimiento, silueta reconocible, consistencia con MEDIA).

## HALLAZGOS POR MÓDULO

### 50-Vegetacion (12 assets, 12 hojas, 243.8 s) — TODOS ✅

| asset | obj/tris/mats BAJA | veredicto |
|---|---|---|
| `arbusto_floral` | 5/262/4 | ✅ |
| `arbusto_redondo` | 4/112/4 | ✅ |
| `canas_bambu` | … | ✅ |
| `flor_isla` | … | ✅ |
| `helecho_chico` | 2/224/2 | ✅ |
| `helecho_gigante` | 3/426/3 | ✅ |
| `hierba_alta` | 2/418/2 | ✅ |
| `hongo_luminoso` | 5/507/4 | ✅ (capturado con luz violeta, intencional) |
| `liana_colgante` | 4/211/4 | ✅ |
| `palmera` | 4/142/4 | ✅ |
| `palmera_inclinada` | 4/133/4 | ✅ |
| `palmera_joven` | 3/86/3 | ✅ |

### 15-Recursos + 16-Crafting (14 assets, 14 hojas, 270.1 s) — 12 ✅, 2 🔴

| asset | obj/tris/mats BAJA | veredicto |
|---|---|---|
| `cristal_ancestral` | 4/162/4 | ✅ (defecto exportador pendiente: 72 verts degenerados en origen; documentado en §cristal_ancestral) |
| `monton_ramas` | 1/278/2 | ✅ |
| `nido_cocos` | … | ✅ |
| `piedra_afilar` | 1/32/3 | ✅ — **falsa alarma E-31**: losa con footprint 0.187×0.034, 2 verts tocando. Mi juicio visual inicial fue erróneo, corregido con `diag_apoyo.py` |
| `roca_comun` | … | ✅ |
| `roca_pedernal` | … | ✅ |
| `tronco_caido` | 3/138/3 | ✅ |
| `veta_cobre` | 3/174/3 | ✅ — roca con base plana de fábrica, no es domo |
| `veta_hierro` | 3/206/3 | 🔴 **FLOTANDO visiblemente** — roca gris-azulada suspendida, salvada por un cristal a 0.0450. Nuevo E-50: la roca es un DOMO (`toca=1, footprint=0.000×0.000`) y la fuente también lo es |
| `veta_oro` | 3/301/3 | ✅ |
| `cuerda_enrollada` | 2/357/2 | ✅ |
| `hacha_piedra` | 3/231/3 | ✅ |
| `lingote_metal` | 1/5/1 | ✅ |
| `tablon_madera` | 6/32/4 | ✅ |

### 25-Ruinas-Templos + 40-Infraestructura (12 assets, 12 hojas, 215.6 s) — TODOS ✅

| asset | obj/tris/mats BAJA | veredicto |
|---|---|---|
| `altar_ritual` | 4/231/4 | ✅ |
| `antorcha_pared` | 4/80/4 | ✅ |
| `cofre_ancestral` | … | ✅ |
| `losa_grabado` | … | ✅ |
| `puente_cuerda` | 1/308/3 | ✅ |
| `puerta_templo` | 3/76/3 | ✅ |
| `bote_pesca` | 4/91/4 | ✅ |
| `cartel_indicador` | 2/17/2 | ✅ |
| `farola_fuego` | 5/105/4 | ✅ |
| `muelle_madera` | 3/153/3 | ✅ |
| `pozo_piedra` | 1/299/4 | ✅ |
| `puente_troncos` | 1/281/3 | ✅ |

### 13-Herramientas + 45-Arte3D + 70-Interacciones (14 assets, 14 hojas, 248.4 s) — TODOS ✅

| asset | obj/tris/mats BAJA | veredicto |
|---|---|---|
| `antorcha_mano` | 4/73/4 | ✅ |
| `pico_hierro` | 3/87/3 | ✅ |
| `pico_piedra` | … | ✅ |
| `anillo_piedras_ritual` | … | ✅ |
| `estrella_mar` | … | ✅ (corregido en log previo, no rechazar de nuevo) |
| `monolito_glifos` | 2/60/2 | ✅ |
| `totem_isla` | 4/162/4 | ✅ |
| `vieira_playa` | 1/482/3 | ✅ |
| `boton_piso` | 1/47/3 | ✅ |
| `cofre_pequeno` | 1/32/3 | ✅ |
| `palanca_madera` | 1/50/3 | ✅ |
| `puerta_corrediza_piedra` | 1/32/3 | ✅ |
| `valvula_manivela` | 1/86/3 | ✅ |

## RESUMEN NUMÉRICO

- **Total barrido:** 52 assets BAJA, 0 fallos de pipeline, **0 excedidos de presupuesto** en las 3 filas.
- **✅ Aprobados:** 51/52 (98 %).
- **🔴 Pendiente corrección:** 1 (`veta_hierro`, E-50).

## HALLAZGOS TRANSVERSALES

### E-50 (NUEVO): apoyo puntual en domo

`z_min=0.0450` con `toca=1, footprint=0.000×0.000` significa que el objeto se posa
sobre un solo vértice (el ápice de un domo). Aunque numéricamente está "apoyado",
el ojo lo lee flotando. Caso verificado: `veta_hierro` — roca gris-azulada en
forma de huevo/domo, 42 vértices, sin cara inferior.

**Por qué la fuente también lo es:** el bug NO está en la generación de
variantes (la fuente tiene la roca a 0.0450 correcto), sino en el **modelo
original** (creado sin base plana). Las variantes re-generadas
mantienen la geometría.

**Diferencia con veta_cobre / veta_oro:** esos dos modelos SÍ tienen base
plana de fábrica. Solo veta_hierro es domo.

**Fix correcto:** re-modelar la roca con base poligonal plana. Script
`aplanar_dome.py` toma el vértice más bajo + K vecinos XY y los aplana a
z_objetivo. K=5 produce una base hexagonal de ~10–20 cm de diámetro. Probado
en DRY pero no aplicado (socket cayó a 01:11).

**Fix aplicado a medias:** `corregir_asset.py --mover-obj Roca_Hierro 0.045
--variantes media,baja` bajó la roca a 0.0450 numéricamente, pero como sigue
siendo domo el visual no mejora. Cambio guardado en disco.

### Piedra_afilar: falsa alarma E-31

La losa está PLANA sobre la arena (footprint 0.187×0.034, 2 vértices
tocando). Verificado con `diag_apoyo.py` midiendo vértices reales (E-24).
Mi juicio visual del log anterior fue erróneo — había confundido una sombra
con un gap. Aprendizaje: **E-37 (fix cosmético ≠ fix) también aplica al
diagnóstico**: medir antes de declarar bug.

### `cristal_ancestral` MEDIA: defecto del exportador (de log previo)

GLB reporta `minY=0.0000` con 72 vértices en `(0,0,0)`, pero la fuente
tiene `nv=86` con `zmin=0.0450`. Re-importado con el propio parser de
Blender, confirma 72 verts degenerados en origen. NO es bug de mi
parser, NO es bug de modifier. Es el exportador glTF inyectando geometría
degenerada para `cristal_ancestral` específicamente. **Pendiente**:
decidir work-around (exportar solo `_alta_media` que está limpio, o
re-modelar el cristal) o documentar como quirk conocido.

## ACCIONES TOMADAS

- ✅ `corregir_asset.py 15-Recursos veta_hierro_lowpoly --mover-obj Roca_Hierro 0.045
  --variantes media,baja` — roca movida a 0.0450 en media y baja. Tris sin
  cambio. Cambios guardados.
- ✅ Hojas de contacto generadas en `tools/mcp/blender-mcp/<modulo>/capturas/`
  con timestamp 00-43 a 00-45.
- ✅ Memory 2026-08-31.md y MEMORY.md actualizados con E-50.

## PENDIENTE PRÓXIMO ARRANQUE (con Blender abierto)

1. **Aplicar `aplanar_dome.py`** sobre `veta_hierro_lowpoly` (source, media, baja)
   con K=5 → base hexagonal plana.
2. Re-capturar las 3 variantes de `veta_hierro` y verificar visualmente.
3. **Re-exportar GLBs** a Godot con `EXPORT_FORZAR=1` (alta=source, media, baja).
4. **Documentar E-47, E-48, E-49, E-50** en `09-GUIA-BLENDER.md`.
5. Limpiar temporales (`(borrado)`, `dump_glb.py`, `diag_apoyo.py`,
   `aplanar_dome.py`).
6. **Verificar `veta_oro` source** con `diag_apoyo.py` — algunos cristales
   tienen `toca=2` con footprint `0.000×0.000`, podría tener E-50 también.
7. **QA visual MEDIA y ALTA** (52 y 17 assets) — mismo barrido, sin Vision
   esto no se puede hacer.
8. **Commit y push** solo mis cambios (las GLB modificadas no se commitean
   hasta que el re-modelado esté hecho y re-exportado).

## DECISIONES TOMADAS

- ✅ Doy por **cerrado el barrido BAJA**: 51/52 ok, 1 pendiente (`veta_hierro`).
- ✅ Detengo aquí porque el socket cayó a 01:11 (Blender cerrado por el usuario).
- ⏸ NO toco las GLB en Godot — siguen siendo las versiones con roca flotando.
  Se re-exportan tras el re-modelado.
