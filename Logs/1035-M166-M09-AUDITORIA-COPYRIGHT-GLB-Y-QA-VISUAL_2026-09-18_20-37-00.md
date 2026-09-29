# Log 1035: M166/M09 — Auditoría de copyright de .glb + QA visual V2-asistencia de capturas orbitales

**Fecha:** 2026-09-18
**Hora:** 20:37
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Verificación empírica del claim M127 (Log 1022) de "434 .glb sin copyright" + QA visual
asistido (V2) de capturas orbitales acumuladas M16/M19/M33/M51 para alimentar la decisión de
M154. Resultado: **el claim se confirma y se explica** (434 = 418 activos + 16 respaldos
Obsoletos; CERO de los 694 .glb versionados del repo tiene atribución por-archivo), y se
detectaron **7 artefactos visuales** (1 flotación real: `antorcha_pared`, 2 interpenetraciones
M19, 1 silueta rota M16, 1 escalón M33, 2 issues M51 — el shore-fade confirma issue conocido).

## PARTE A — Auditoría de copyright de .glb

### Método (todo empírico, .glb por .glb)

Herramientas nuevas (reutilizables, `scripts/`):
- `scripts/auditar_copyright_glb.py` — parsea el chunk JSON de cada .glb (extras
  `asset.copyright`/`asset.license` + `extras` anidados con copyright/author/license/
  source/credit/attribution/polypizza_*), detecta sidecars de licencia en el mismo
  directorio (LICENSE*/COPYRIGHT*/CREDITS*/NOTICE*/atribucion*), cruza con los catálogos
  `data/legal/*.json` (solo hay entradas por CATEGORÍA: `creditos.json` declara
  "assets_terceros: Font Awesome CC BY 4.0, Kenney.nl CC0, OpenGameArt" — ningún
  mapeo por-archivo), con `tools/legal/asset_metadata_scope.json` y con git (commit que
  añade cada .glb + su mensaje). Salida: `tools/legal/auditoria_copyright_glb.json`
  (694 registros).
- `scripts/auditar_flotacion_glb.py` — mide z_min/z_max reales de cada .glb (parses
  accessors POSITION + TRS de nodos) contra Z_APOYO=0.045±0.020 (M166/E-12). Salida:
  `tools/legal/flotacion_glb.json`.

### Coneteos exactos

| Bucket | glb | CON | SIN | AMBIGUO |
|---|---|---|---|---|
| `game/isla-ancestral/assets/**` (el claim M127) | **434** | 0 | **434** | 0 |
| `game/Obsoletos/**` | 10 | 0 | 10 | 0 |
| `tools/mcp/blender-mcp/**` | 250 | 0 | 250 | 0 |
| **Total versionado (git ls-files)** | **694** | **0** | **694** | **0** |

Detalle del claim 434 (desglose exacto, verificado con `git ls-files` + walk):
- `assets/3d/alta` 160 + `assets/3d/baja` 128 + `assets/3d/media` 130 = **418 activos**
  (coincide con el techo `max: 418` del baseline SIN_ATRIBUCION en
  `tools/legal/asset_metadata_scope.json`, que excluye `Obsoletos`).
- +16 respaldos en `assets/3d/media/Obsoletos/` (1 en `media/Obsoletos/` + 15 en
  `media/Obsoletos/respaldo_original_2026-09-04_06-06-43/`) = **434**.
- **Explica el "creció de 418 a 434" del Log 1022: NO son 16 assets nuevos activos — son
  los 16 archivos de respaldo Obsoletos de 2026-09-04.** El conteo activo sigue siendo 418.

### Evidencia por clase (verificación ítem por ítem)

- **Sidecars de licencia:** 0 de los 694 directorios contiene LICENSE/COPYRIGHT/CREDITS/
  NOTICE/atribución junto a los .glb.
- **Extras GLB:** 0 de los 694 .glb tiene `asset.copyright`, `asset.license` ni `extras`
  de autor/licencia (ni `polypizza_attribution`/`polypizza_licence` → ningún asset del
  repo pasó por el downloader de Poly Pizza del blender-mcp; idem Sketchfab/Hyper3D:
  sin señales).
- **Catálogo M166/M09:** `data/legal/modelos_3d.json` (3 entradas por categoría:
  voxel_characters=propio, terrain_textures=CC0, ui_icons=MIT) y `creditos.json`
  (assets_terceros: Font Awesome CC BY 4.0 / Kenney.nl CC0 / OpenGameArt) — cobertura
  **por categoría, no por archivo**: ningún .glb específico está mapeado a una licencia.
- **git:** todos los commits que añaden .glb son del pipeline propio (usuario git
  "Belforte": "Pipeline Blender->Godot: 153 GLB exportados", "trackear 101 GLB untracked",
  etc.). Ningún commit menciona Poly/PolyPizza/Sketchfab/Hyper3D.

### Origen y atribución propuesta (paso 4 de la asignación)

- Origen de los 694 SIN: **propio (pipeline Blender MCP V5)** — los 694 llevan
  `asset.generator = "Khronos glTF Blender I/O v4.2.83"` (Blender 4.2) y el commit de
  adición es del pipeline del proyecto. Cero señales de Poly Haven / Poly Pizza /
  Sketchfab / Hyper3D en el repo.
- **Atribución propuesta para los 434 activos + 10 Obsoletos + 250 tools:**
  `Isla Ancestral Team — © 2026 — Licencia Propietaria` (titular según
  `data/legal/copyright.json` → `assets_visuales` y `NOTICE.md`).
- **Fix del pipeline (dueño M166/M09, fuera de mi alcance — no toqué mallas/GLB):**
  1. El exportador glTF de Blender acepta `asset.copyright` y `asset.license`: agregarlos
     a la exportación del pipeline (`bpy.ops.export_scene.gltf(copyright=..., license=...)`
     o el equivalente del flujo actual) y re-exportar los 434 activos con
     `copyright="Isla Ancestral Team © 2026"` + `license="Propietaria (ver NOTICE.md)"`.
  2. Mantener el techo de deuda `asset_metadata_scope.json` (418 activos) y subirla solo
     cuando entren activos nuevos; los 16 Obsoletos deberían salir del scan (ya están
     excluidos vía `Obsoletos` en `excluir` → el +16 no debería exceder el techo).
  3. Cada importación futura de asset de terceros (Poly Pizza/Sketchfab/Hyper3D) debe
     guardar sidecar de licencia en el mismo directorio del .glb (hoy no existe ninguno).

### Hallazgo de pipeline (PARTE B vincula)

Ninguno de los 694 .glb está asentado en Z_APOYO=0.045: la librería `assets/3d` usa
**referencia de origen centrada** (z_min negativo: azada -0.13, bowl -0.10, gema -0.15,
tierra -0.50, espantapajaros -0.40, palmera -2.35 [tronco embebido intencional],
volcan ±4.0 [pieza de isla]). Única excepción positiva: `antorcha_pared` z_min +0.295/
+0.34 (→ flotación, ver V-3). El criterio numérico M166 (0.045±0.02) aplica a los
**.blend** de trabajo (`auditar_flotantes.py`), no a los .glb exportados: los .glb salen
con la cota del estado del .blend al exportar, y el runtime los posiciona con
`get_height+1` (guias 07/167). Documentado para que no se "arregle" el z de los .glb
manualmente.

## PARTE B — QA visual V2-asistencia (capturas orbitales acumuladas)

> Alcance: `tools/mcp/blender-mcp/{16-Crafting,19-NPCs,33-Agricultura,25-Ruinas-Templos}/capturas/`
> (orbitales az000-az300 por variante, E-13) + `tools/mcp/godot-mcp/capturas/51/` (17
> capturas in-game M51). Muestreo: 18 orbitales + 4 antorcha + 4 in-game. **No apruebo
> estéticamente (M154 = usuario); solo reporto artefactos.**

| # | Módulo | Artefacto | Evidencia (captura) | Severidad |
|---|---|---|---|---|
| V-1 | M16 | **Silueta rota / material**: la hoja de `hacha_piedra` en las variantes derivadas (media/baja desde ALTA) se ve como una **vela/plano semitransparente gris**, no como hoja sólida (la ALTA source sí la muestra sólida en az120). Sospecha: decimate o blend-mode invertido en la derivada (familia E-23) | `16-Crafting/capturas/hacha_piedra_alta_media_15-17-40_az000.png` + `hacha_piedra_baja_15-19-28_az000.png` vs `hacha_piedra_alta_00-15-00_az120.png` | Media |
| V-2 | M19 | **Interpenetración**: brazo-cuajado del `npc_base_v5` colado al torso sin separación en las vistas de perfil (no se distingue brazo del cuerpo) | `19-NPCs/capturas/npc_base_v5_az_az000.png` y `_az180.png` | Baja |
| V-3 | M25 | **Flotación real (única cota positiva del repo)**: `antorcha_pared` (3 variantes) z_min +0.295/+0.34 — pieza de pared (E-80) exportada a `assets/3d` como prop de suelo → **flota ~30 cm** si el runtime la pone sobre terreno. La captura la muestra montada en la pared del set (intencional en el set; el glb no incluye pared) | `25-Ruinas-Templos/capturas/antorcha_pared_baja_18-18-02_az120.png` + `flotacion_glb.json` | Alta |
| V-4 | M19 | **Piezas flotantes**: `npc_sentado_v3` tiene una pieza gris colando detrás de la cabeza/cuello y un anillo oscuro delgado flotando a la altura de la cintura (posible restos de silla/cinturón del set o interpenetración del pose sentado) | `19-NPCs/capturas/npc_sentado_v3_az000.png` | Media |
| V-5 | M33 | **Escalón/silueta rota**: torso del `espantapajaros` (2 cajas) con desplazamiento horizontal en la cintura — se nota un escalón en ambas caras (az000/az180); piernas colgadas asimétricas | `33-Agricultura/capturas/espantapajaros_src_20-12-15_az000.png` + `_az180.png` | Media |
| V-6 | M51 | **Shore-fade enmascarando arena (issue conocido M167 CONFIRMADO)**: la banda blanca cubre toda la costa (incl. `shorefade_azul` 18:22) — el known-issue "shore-fade enmascara demasiada arena" sigue visible en esta iteración | `godot-mcp/capturas/51/cap_51_2026-09-06_18-22-00_shorefade_azul.png` + `_17-42-50_olas_hasta_agua_clara.png` | Alta (conocido) |
| V-7 | M51 | **Orilla con borde duro**: la línea de ola es una banda blanca estática con borde cuadrado (no espuma suave); a distancia las palmeras de la banca se ven "flotando" sobre la banda blanca (base oculta) | `godot-mcp/capturas/51/cap_51_2026-09-06_16-23-25_agua_olas_v1.png` | Media |

### Revisiones sin artefacto (muestreadas, OK)

- M16: `azada_baja_v1` (azada apoyada en el disco, hoja en contacto, silueta limpia),
  `frasco_agua_v1` (agua semitransparente DENTRO del frasco, tapón encajado — no
  invertido), `gema_tallada_v1` (apoyada), `cuerda_enrollada_media` (apoyo plano),
  `bowl_barro_media` (sobre platillo de apoyo del set — el glb va centrado en origen
  z_min -0.10, "enterrado 10 cm" in-game; verificar look final en escena).
- M19: cabezas montadas OK, sombrero OK, `npc_sentado_v3` torso/beca OK (solo V-4).
- M33: `bananero_alta` (apoyado, hojas planas OK), `cultivo_madura_v1` **sin flotación**
  (la aparente separación del montículo es artefacto del set: glb z_min -0.14 = planta
  embebida intencional).
- M51: materiales de agua correctos (agua bajo arena, sin inversión); FPS 59-60.

### Decisiones pendientes del usuario (M154)

1. V-3 `antorcha_pared`: sacarla de `assets/3d` (librería de suelo), darle Empty de
   montaje (E-80) o dejarla si el runtime la monta en pared.
2. V-1 hacha_piedra media/baja: re-derivar con `generar_variante.py` (H12 de M166,
   dueño mimo-v2.5/Hy4) o ajustar el ratio de decimate (E-23).
3. V-6 shore-fade: el known-issue de M167 sigue abierto — decidir parámetro.

## Archivos Modificados/Creados

- **Creado:** `scripts/auditar_copyright_glb.py`, `scripts/auditar_flotacion_glb.py`
- **Creado:** `tools/legal/auditoria_copyright_glb.json` (694 registros con evidencia
  por-archivo), `tools/legal/flotacion_glb.json` (694 cotas z + buckets)
- **Modificado:** `DOCUMENTACION/11-BUGS.md` (ampliación del hallazgo M127 con V-3 y
  registro de deuda), `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/{05-Checklist,04-Codigo}.md`
  y `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/{05-Checklist,04-Codigo}.md`
  (notas del agente + reserva), `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`,
  `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, backlog `agnes-3-flash`
- **No se tocó:** mallas/GLB (V5 = Hy4), `scripts/player/`, `scripts/ia_npc/`, M30/M49/M71,
  los 4 scripts de M166 ni H12.

## Nota de honestidad

- El origen "propio" de los 694 es inferencia (generator Blender + commits del pipeline +
  ausencia de señales de terceros); si algún asset se importó desde Blend externo sin
  metadata, el exportador lo perdería. No se encontró señal contraria.
- Los 16 .glb de `media/Obsoletos/` son respaldos marcados Obsoletos: se cuentan en el
  434 del claim, pero para el pipeline de fix solo importan los 418 activos.

## Anexo — Lista completa de los 434 .glb de assets/ SIN copyright (verificables en tools/legal/auditoria_copyright_glb.json)

game/isla-ancestral/assets/3d/alta/13-Herramientas_antorcha_mano.glb
game/isla-ancestral/assets/3d/alta/13-Herramientas_pico_hierro.glb
game/isla-ancestral/assets/3d/alta/13-Herramientas_pico_piedra.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_cristal_ancestral.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_monton_ramas.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_nido_cocos.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_piedra_afilar.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_roca_comun.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_roca_pedernal.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_tronco_caido.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_veta_cobre.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_veta_hierro.glb
game/isla-ancestral/assets/3d/alta/15-Recursos_veta_oro.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_azada.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_bowl_barro.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_cuerda_enrollada.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_frasco_agua.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_gema_tallada.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_hacha_hierro.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_hacha_piedra.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_lingote_metal.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_machete.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_martillo.glb
game/isla-ancestral/assets/3d/alta/16-Crafting_tablon_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_alfombra.glb
game/isla-ancestral/assets/3d/alta/18-Casas_cama_basica.glb
game/isla-ancestral/assets/3d/alta/18-Casas_cama_doble.glb
game/isla-ancestral/assets/3d/alta/18-Casas_casa_casona.glb
game/isla-ancestral/assets/3d/alta/18-Casas_casa_choza_ampliada.glb
game/isla-ancestral/assets/3d/alta/18-Casas_casa_completa_ejemplo.glb
game/isla-ancestral/assets/3d/alta/18-Casas_casa_mediana.glb
game/isla-ancestral/assets/3d/alta/18-Casas_comoda.glb
game/isla-ancestral/assets/3d/alta/18-Casas_cuadro_ancestral.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_alfombra_floral.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_alfombra_tejida.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_banco_exterior.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_baul_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_cofre_perlas.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_concha_decor.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_cuadro_floral.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_espejo_marco.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_estatuilla_ave.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_farol_coral.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_farol_mesa.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_fuente_chica.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_guirnalda.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_idol_piedra.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_jarron_agua.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_jarron_flores.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_lampara_pie.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_lampara_techo.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_maceta_flor.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_maceta_helecho.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_maceta_palmera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_mascara_ancestral.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_mecedora.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_olla_barro.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_plato_frutas.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_reloj_pared.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_repisa_pared.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_totem_chico.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_vasija_ritual.glb
game/isla-ancestral/assets/3d/alta/18-Casas_decor_vela_plato.glb
game/isla-ancestral/assets/3d/alta/18-Casas_escalera_mano.glb
game/isla-ancestral/assets/3d/alta/18-Casas_estanteria.glb
game/isla-ancestral/assets/3d/alta/18-Casas_estufa_lena.glb
game/isla-ancestral/assets/3d/alta/18-Casas_lampara_pie.glb
game/isla-ancestral/assets/3d/alta/18-Casas_maceta_interior.glb
game/isla-ancestral/assets/3d/alta/18-Casas_mesa_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_nevera_rustica.glb
game/isla-ancestral/assets/3d/alta/18-Casas_pared_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_pared_puerta.glb
game/isla-ancestral/assets/3d/alta/18-Casas_pared_ventana.glb
game/isla-ancestral/assets/3d/alta/18-Casas_piso_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_puerta_articulada.glb
game/isla-ancestral/assets/3d/alta/18-Casas_silla_madera.glb
game/isla-ancestral/assets/3d/alta/18-Casas_sillon.glb
game/isla-ancestral/assets/3d/alta/18-Casas_techo_dos_aguas.glb
game/isla-ancestral/assets/3d/alta/18-Casas_techo_paja.glb
game/isla-ancestral/assets/3d/alta/18-Casas_velador.glb
game/isla-ancestral/assets/3d/alta/18-Casas_ventana_marco.glb
game/isla-ancestral/assets/3d/alta/18-Casas_zocalo_piedra.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_cabeza_alargada.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_cabeza_cuadrada.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_cabeza_redonda.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_npc_base.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_npc_sentado.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_sombrero_paja.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_vestimenta_anciano.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_vestimenta_campesina.glb
game/isla-ancestral/assets/3d/alta/19-NPCs_vestimenta_pescador.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_altar_ritual.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_antorcha_pared.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_arco_entrada_templo.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_cofre_ancestral.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_estatua_ancestral_erosionada.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_losa_grabado.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_puente_cuerda.glb
game/isla-ancestral/assets/3d/alta/25-Ruinas-Templos_puerta_templo.glb
game/isla-ancestral/assets/3d/alta/27-Islas-Ubicaciones_campamento_abandonado.glb
game/isla-ancestral/assets/3d/alta/27-Islas-Ubicaciones_cascada.glb
game/isla-ancestral/assets/3d/alta/27-Islas-Ubicaciones_cementerio_barcos.glb
game/isla-ancestral/assets/3d/alta/27-Islas-Ubicaciones_faro_viejo.glb
game/isla-ancestral/assets/3d/alta/27-Islas-Ubicaciones_volcan.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_bananero.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_canaveral.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_compostera.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_cultivo_brote.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_cultivo_creciendo.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_cultivo_lista.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_cultivo_madura.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_espantapajaros.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_regadera.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_tierra_arada.glb
game/isla-ancestral/assets/3d/alta/33-Agricultura_tierra_regada.glb
game/isla-ancestral/assets/3d/alta/35-Mineria_carretilla_minero.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_cangrejo_playa.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_conejo.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_gaviota.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_jabali.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_nutria_ribera_v2.glb
game/isla-ancestral/assets/3d/alta/36-Fauna_tortuga_marina.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_bote_pesca.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_cartel_indicador.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_farola_fuego.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_muelle_madera.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_pozo_piedra.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_puente_cuerda_colgante.glb
game/isla-ancestral/assets/3d/alta/40-Infraestructura_puente_troncos.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_ancla_naufragio.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_anillo_piedras_ritual.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_barco_hundido.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_caveira_criatura.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_concha_mar.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_coral_abanico.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_estrella_mar.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_jarrones_urnas.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_monolito_glifos.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_totem_isla.glb
game/isla-ancestral/assets/3d/alta/45-Arte3D_vieira_playa.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_arbol_frutal.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_arbusto_floral.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_arbusto_redondo.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_canas_bambu.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_flor_isla.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_helecho_chico.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_helecho_gigante.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_hierba_alta.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_hongo_luminoso.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_liana_colgante.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_musgo_roca.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_palmera.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_palmera_inclinada.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_palmera_joven.glb
game/isla-ancestral/assets/3d/alta/50-Vegetacion_raices_expuestas.glb
game/isla-ancestral/assets/3d/alta/70-Interacciones_boton_piso.glb
game/isla-ancestral/assets/3d/alta/70-Interacciones_cofre_pequeno.glb
game/isla-ancestral/assets/3d/alta/70-Interacciones_palanca_madera.glb
game/isla-ancestral/assets/3d/alta/70-Interacciones_puerta_corrediza_piedra.glb
game/isla-ancestral/assets/3d/alta/70-Interacciones_valvula_manivela.glb
game/isla-ancestral/assets/3d/baja/13-Herramientas_antorcha_mano.glb
game/isla-ancestral/assets/3d/baja/13-Herramientas_pico_hierro.glb
game/isla-ancestral/assets/3d/baja/13-Herramientas_pico_piedra.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_cristal_ancestral.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_monton_ramas.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_nido_cocos.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_piedra_afilar.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_roca_comun.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_roca_pedernal.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_tronco_caido.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_veta_cobre.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_veta_hierro.glb
game/isla-ancestral/assets/3d/baja/15-Recursos_veta_oro.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_azada.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_bowl_barro.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_cuerda_enrollada.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_frasco_agua.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_gema_tallada.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_hacha_hierro.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_hacha_piedra.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_lingote_metal.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_machete.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_martillo.glb
game/isla-ancestral/assets/3d/baja/16-Crafting_tablon_madera.glb
game/isla-ancestral/assets/3d/baja/18-Casas_alfombra.glb
game/isla-ancestral/assets/3d/baja/18-Casas_cama_basica.glb
game/isla-ancestral/assets/3d/baja/18-Casas_cama_doble.glb
game/isla-ancestral/assets/3d/baja/18-Casas_casa_casona.glb
game/isla-ancestral/assets/3d/baja/18-Casas_casa_choza_ampliada.glb
game/isla-ancestral/assets/3d/baja/18-Casas_casa_completa_ejemplo.glb
game/isla-ancestral/assets/3d/baja/18-Casas_casa_mediana.glb
game/isla-ancestral/assets/3d/baja/18-Casas_comoda.glb
game/isla-ancestral/assets/3d/baja/18-Casas_cuadro_ancestral.glb
game/isla-ancestral/assets/3d/baja/18-Casas_escalera_mano.glb
game/isla-ancestral/assets/3d/baja/18-Casas_estanteria.glb
game/isla-ancestral/assets/3d/baja/18-Casas_estufa_lena.glb
game/isla-ancestral/assets/3d/baja/18-Casas_lampara_pie.glb
game/isla-ancestral/assets/3d/baja/18-Casas_maceta_interior.glb
game/isla-ancestral/assets/3d/baja/18-Casas_mesa_madera.glb
game/isla-ancestral/assets/3d/baja/18-Casas_nevera_rustica.glb
game/isla-ancestral/assets/3d/baja/18-Casas_pared_madera.glb
game/isla-ancestral/assets/3d/baja/18-Casas_pared_puerta.glb
game/isla-ancestral/assets/3d/baja/18-Casas_pared_ventana.glb
game/isla-ancestral/assets/3d/baja/18-Casas_piso_madera.glb
game/isla-ancestral/assets/3d/baja/18-Casas_puerta_articulada.glb
game/isla-ancestral/assets/3d/baja/18-Casas_silla_madera.glb
game/isla-ancestral/assets/3d/baja/18-Casas_sillon.glb
game/isla-ancestral/assets/3d/baja/18-Casas_techo_dos_aguas.glb
game/isla-ancestral/assets/3d/baja/18-Casas_techo_paja.glb
game/isla-ancestral/assets/3d/baja/18-Casas_velador.glb
game/isla-ancestral/assets/3d/baja/18-Casas_ventana_marco.glb
game/isla-ancestral/assets/3d/baja/18-Casas_zocalo_piedra.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_cabeza_alargada.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_cabeza_cuadrada.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_cabeza_redonda.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_npc_base.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_npc_sentado.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_sombrero_paja.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_vestimenta_anciano.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_vestimenta_campesina.glb
game/isla-ancestral/assets/3d/baja/19-NPCs_vestimenta_pescador.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_altar_ritual.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_antorcha_pared.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_arco_entrada_templo.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_cofre_ancestral.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_estatua_ancestral_erosionada.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_losa_grabado.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_puente_cuerda.glb
game/isla-ancestral/assets/3d/baja/25-Ruinas-Templos_puerta_templo.glb
game/isla-ancestral/assets/3d/baja/27-Islas-Ubicaciones_campamento_abandonado.glb
game/isla-ancestral/assets/3d/baja/27-Islas-Ubicaciones_cascada.glb
game/isla-ancestral/assets/3d/baja/27-Islas-Ubicaciones_cementerio_barcos.glb
game/isla-ancestral/assets/3d/baja/27-Islas-Ubicaciones_faro_viejo.glb
game/isla-ancestral/assets/3d/baja/27-Islas-Ubicaciones_volcan.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_bananero.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_canaveral.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_compostera.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_cultivo_brote.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_cultivo_creciendo.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_cultivo_lista.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_cultivo_madura.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_espantapajaros.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_regadera.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_tierra_arada.glb
game/isla-ancestral/assets/3d/baja/33-Agricultura_tierra_regada.glb
game/isla-ancestral/assets/3d/baja/35-Mineria_carretilla_minero.glb
game/isla-ancestral/assets/3d/baja/36-Fauna_cangrejo_playa.glb
game/isla-ancestral/assets/3d/baja/36-Fauna_gaviota.glb
game/isla-ancestral/assets/3d/baja/36-Fauna_jabali.glb
game/isla-ancestral/assets/3d/baja/36-Fauna_tortuga_marina.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_bote_pesca.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_cartel_indicador.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_farola_fuego.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_muelle_madera.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_pozo_piedra.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_puente_cuerda_colgante.glb
game/isla-ancestral/assets/3d/baja/40-Infraestructura_puente_troncos.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_ancla_naufragio.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_anillo_piedras_ritual.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_barco_hundido.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_caveira_criatura.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_concha_mar.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_coral_abanico.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_estrella_mar.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_jarrones_urnas.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_monolito_glifos.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_totem_isla.glb
game/isla-ancestral/assets/3d/baja/45-Arte3D_vieira_playa.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_arbol_frutal.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_arbusto_floral.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_arbusto_redondo.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_canas_bambu.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_flor_isla.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_helecho_chico.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_helecho_gigante.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_hierba_alta.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_hongo_luminoso.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_liana_colgante.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_musgo_roca.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_palmera.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_palmera_inclinada.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_palmera_joven.glb
game/isla-ancestral/assets/3d/baja/50-Vegetacion_raices_expuestas.glb
game/isla-ancestral/assets/3d/baja/70-Interacciones_boton_piso.glb
game/isla-ancestral/assets/3d/baja/70-Interacciones_cofre_pequeno.glb
game/isla-ancestral/assets/3d/baja/70-Interacciones_palanca_madera.glb
game/isla-ancestral/assets/3d/baja/70-Interacciones_puerta_corrediza_piedra.glb
game/isla-ancestral/assets/3d/baja/70-Interacciones_valvula_manivela.glb
game/isla-ancestral/assets/3d/media/13-Herramientas_antorcha_mano.glb
game/isla-ancestral/assets/3d/media/13-Herramientas_pico_hierro.glb
game/isla-ancestral/assets/3d/media/13-Herramientas_pico_piedra.glb
game/isla-ancestral/assets/3d/media/15-Recursos_cristal_ancestral.glb
game/isla-ancestral/assets/3d/media/15-Recursos_monton_ramas.glb
game/isla-ancestral/assets/3d/media/15-Recursos_nido_cocos.glb
game/isla-ancestral/assets/3d/media/15-Recursos_piedra_afilar.glb
game/isla-ancestral/assets/3d/media/15-Recursos_roca_comun.glb
game/isla-ancestral/assets/3d/media/15-Recursos_roca_pedernal.glb
game/isla-ancestral/assets/3d/media/15-Recursos_tronco_caido.glb
game/isla-ancestral/assets/3d/media/15-Recursos_veta_cobre.glb
game/isla-ancestral/assets/3d/media/15-Recursos_veta_hierro.glb
game/isla-ancestral/assets/3d/media/15-Recursos_veta_oro.glb
game/isla-ancestral/assets/3d/media/16-Crafting_azada.glb
game/isla-ancestral/assets/3d/media/16-Crafting_bowl_barro.glb
game/isla-ancestral/assets/3d/media/16-Crafting_cuerda_enrollada.glb
game/isla-ancestral/assets/3d/media/16-Crafting_frasco_agua.glb
game/isla-ancestral/assets/3d/media/16-Crafting_gema_tallada.glb
game/isla-ancestral/assets/3d/media/16-Crafting_hacha_hierro.glb
game/isla-ancestral/assets/3d/media/16-Crafting_hacha_piedra.glb
game/isla-ancestral/assets/3d/media/16-Crafting_lingote_metal.glb
game/isla-ancestral/assets/3d/media/16-Crafting_machete.glb
game/isla-ancestral/assets/3d/media/16-Crafting_martillo.glb
game/isla-ancestral/assets/3d/media/16-Crafting_tablon_madera.glb
game/isla-ancestral/assets/3d/media/18-Casas_alfombra.glb
game/isla-ancestral/assets/3d/media/18-Casas_cama_basica.glb
game/isla-ancestral/assets/3d/media/18-Casas_cama_doble.glb
game/isla-ancestral/assets/3d/media/18-Casas_casa_casona.glb
game/isla-ancestral/assets/3d/media/18-Casas_casa_choza_ampliada.glb
game/isla-ancestral/assets/3d/media/18-Casas_casa_completa_ejemplo.glb
game/isla-ancestral/assets/3d/media/18-Casas_casa_mediana.glb
game/isla-ancestral/assets/3d/media/18-Casas_comoda.glb
game/isla-ancestral/assets/3d/media/18-Casas_cuadro_ancestral.glb
game/isla-ancestral/assets/3d/media/18-Casas_escalera_mano.glb
game/isla-ancestral/assets/3d/media/18-Casas_estanteria.glb
game/isla-ancestral/assets/3d/media/18-Casas_estufa_lena.glb
game/isla-ancestral/assets/3d/media/18-Casas_lampara_pie.glb
game/isla-ancestral/assets/3d/media/18-Casas_maceta_interior.glb
game/isla-ancestral/assets/3d/media/18-Casas_mesa_madera.glb
game/isla-ancestral/assets/3d/media/18-Casas_nevera_rustica.glb
game/isla-ancestral/assets/3d/media/18-Casas_pared_madera.glb
game/isla-ancestral/assets/3d/media/18-Casas_pared_puerta.glb
game/isla-ancestral/assets/3d/media/18-Casas_pared_ventana.glb
game/isla-ancestral/assets/3d/media/18-Casas_piso_madera.glb
game/isla-ancestral/assets/3d/media/18-Casas_puerta_articulada.glb
game/isla-ancestral/assets/3d/media/18-Casas_silla_madera.glb
game/isla-ancestral/assets/3d/media/18-Casas_sillon.glb
game/isla-ancestral/assets/3d/media/18-Casas_techo_dos_aguas.glb
game/isla-ancestral/assets/3d/media/18-Casas_techo_paja.glb
game/isla-ancestral/assets/3d/media/18-Casas_velador.glb
game/isla-ancestral/assets/3d/media/18-Casas_ventana_marco.glb
game/isla-ancestral/assets/3d/media/18-Casas_zocalo_piedra.glb
game/isla-ancestral/assets/3d/media/19-NPCs_cabeza_alargada.glb
game/isla-ancestral/assets/3d/media/19-NPCs_cabeza_cuadrada.glb
game/isla-ancestral/assets/3d/media/19-NPCs_cabeza_redonda.glb
game/isla-ancestral/assets/3d/media/19-NPCs_npc_base.glb
game/isla-ancestral/assets/3d/media/19-NPCs_npc_sentado.glb
game/isla-ancestral/assets/3d/media/19-NPCs_sombrero_paja.glb
game/isla-ancestral/assets/3d/media/19-NPCs_vestimenta_anciano.glb
game/isla-ancestral/assets/3d/media/19-NPCs_vestimenta_campesina.glb
game/isla-ancestral/assets/3d/media/19-NPCs_vestimenta_pescador.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_altar_ritual.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_antorcha_pared.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_arco_entrada_templo.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_cofre_ancestral.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_estatua_ancestral_erosionada.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_losa_grabado.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_puente_cuerda.glb
game/isla-ancestral/assets/3d/media/25-Ruinas-Templos_puerta_templo.glb
game/isla-ancestral/assets/3d/media/27-Islas-Ubicaciones_campamento_abandonado.glb
game/isla-ancestral/assets/3d/media/27-Islas-Ubicaciones_cascada.glb
game/isla-ancestral/assets/3d/media/27-Islas-Ubicaciones_cementerio_barcos.glb
game/isla-ancestral/assets/3d/media/27-Islas-Ubicaciones_faro_viejo.glb
game/isla-ancestral/assets/3d/media/27-Islas-Ubicaciones_volcan.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_bananero.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_canaveral.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_compostera.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_cultivo_brote.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_cultivo_creciendo.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_cultivo_lista.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_cultivo_madura.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_espantapajaros.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_regadera.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_tierra_arada.glb
game/isla-ancestral/assets/3d/media/33-Agricultura_tierra_regada.glb
game/isla-ancestral/assets/3d/media/35-Mineria_carretilla_minero.glb
game/isla-ancestral/assets/3d/media/36-Fauna_cangrejo_playa.glb
game/isla-ancestral/assets/3d/media/36-Fauna_conejo.glb
game/isla-ancestral/assets/3d/media/36-Fauna_gaviota.glb
game/isla-ancestral/assets/3d/media/36-Fauna_jabali.glb
game/isla-ancestral/assets/3d/media/36-Fauna_tortuga_marina.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_bote_pesca.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_cartel_indicador.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_farola_fuego.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_muelle_madera.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_pozo_piedra.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_puente_cuerda_colgante.glb
game/isla-ancestral/assets/3d/media/40-Infraestructura_puente_troncos.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_ancla_naufragio.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_anillo_piedras_ritual.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_barco_hundido.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_caveira_criatura.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_concha_mar.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_coral_abanico.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_estrella_mar.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_jarrones_urnas.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_monolito_glifos.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_totem_isla.glb
game/isla-ancestral/assets/3d/media/45-Arte3D_vieira_playa.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_arbol_frutal.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_arbusto_floral.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_arbusto_redondo.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_canas_bambu.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_flor_isla.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_helecho_chico.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_helecho_gigante.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_hierba_alta.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_hongo_luminoso.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_liana_colgante.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_musgo_roca.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_palmera.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_palmera_inclinada.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_palmera_joven.glb
game/isla-ancestral/assets/3d/media/50-Vegetacion_raices_expuestas.glb
game/isla-ancestral/assets/3d/media/70-Interacciones_boton_piso.glb
game/isla-ancestral/assets/3d/media/70-Interacciones_cofre_pequeno.glb
game/isla-ancestral/assets/3d/media/70-Interacciones_palanca_madera.glb
game/isla-ancestral/assets/3d/media/70-Interacciones_puerta_corrediza_piedra.glb
game/isla-ancestral/assets/3d/media/70-Interacciones_valvula_manivela.glb
game/isla-ancestral/assets/3d/media/Obsoletos/conejo_v5_aprobado_2026-09-04_23-36-40.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_arbol_frutal.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_arbusto_floral.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_arbusto_redondo.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_canas_bambu.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_flor_isla.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_helecho_chico.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_helecho_gigante.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_hierba_alta.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_hongo_luminoso.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_liana_colgante.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_musgo_roca.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_palmera.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_palmera_inclinada.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_palmera_joven.glb
game/isla-ancestral/assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/50-Vegetacion_raices_expuestas.glb
