# 252 - Cierre de pendientes: presupuesto + pipeline Godot
**Fecha:** (sin fecha)
**Hora:** 00:15

**Fecha**: 2026-08-30 00:15
**Modulo**: M166 (produccion 3D)
**Alcance**: cuatro frentes cerrados en una sola sesion
- Los 4 assets de M70 que el segmento anterior dejo creados sin loguear
- Las 23 variantes que excedian presupuesto (auditar_presupuesto.py reportaba 23 de 113)
- El pipeline Blender -> Godot (D8) que venia pendiente desde log 205
- Capturas de QA (E-13) y sincronizacion de variantes con su fuente

---

## 1. M70: los 4 assets que faltaba documentar

El segmento anterior (cierre de palanca v3, log 248) creo los 4 assets
restantes del modulo 70 y los puso en el checklist, pero no reservo log.
Acumulado aca para mantener la trazabilidad:

| Asset | ALTA | MEDIA | BAJA | mats | z_min |
|---|---|---|---|---|---|
| boton_piso          | 136 | 136 | 94  | 3 | 0.045 |
| puerta_corrediza    | 84  | 84  | 58  | 3 | 0.045 |
| cofre_pequeno       | 72  | 72  | 50  | 3 | 0.045 |
| valvula_manivela    | 236 | 236 | 164 | 3 | 0.045 |

Los 4 son single-mesh (1 objeto), 3 materiales, asentados a z=0.045, dentro
de presupuesto sin necesidad de decimate. Capturas a las 23-15-00 (6
azimuths por variante) + 12 hojas de contacto. Diseno de cada uno:

- **boton_piso** (M70-1): piedra octogonal + placa de metal embutida + 4
  pernos de bronce (cono_revolucion helper, 8 lados).
- **puerta_corrediza** (M70-2): riel + 2 pilares + dintel + hoja 1.62 m
  **deslizada a +X** dejando hueco libre de 0.72 m para que se lea
  CORREDIZA y no como un muro ciego.
- **cofre_pequeno** (M70-3): cuerpo 0.62x0.40x0.30 + tapa BARRIL (media_cana
  helper) + 2 bandas de hierro + cierre de bronce en y=+0.23.
- **valvula_manivela** (M70-4): brida + cuerpo + cuello + cubo + VOLANTE
  DE BARCO (toro horizontal R=0.21 tubo 0.022 + 5 radios), reutiliza
  `toro()` del puente de troncos (log 247).

Helpers nuevos introducidos: `cono_revolucion(z0, z1, r0, r1, lados, mat)`
y `media_cana(x0, x1, cy, cz, radio, lados, mat)`. Pendiente documentar
en guia.

---

## 2. Saneo de presupuesto: 23 -> 0

Estado inicial (auditar_presupuesto.py):

```
TOTAL: 113 variantes, 23 exceden el presupuesto
  16 tris+ (12 _alta_media + 4 _lowpoly_media/_baja)
   5 mats+ (todas _lowpoly_baja)
   2 ambos (cofre_ancestral_baja, hongo_luminoso_baja)
```

### 2.1 Causa raiz encontrada

`generar_alta.py` aplicaba BEVEL(2 seg) + SUBDIV a todos los heroes y
MEDIA el TRIS (no CARAS como pretendia). Misma familia de bug que E-33
ya documentado en variantes. Resultado:

| Heroe | tris reales (medidos) | veredicto del script viejo |
|---|---|---|
| totem_isla (ALTA) | **21014** | PASA 4500 tris (sub-estimaba 2x) |
| cofre_ancestral (ALTA) | **11510** | PASA 5510 tris |
| monolito_glifos, muelle, concha, ... | 2200-4700 | OK |

Solo **2 ALTA se pasaban de los 6000 tris** de su propio presupuesto
(totem y cofre). El resto de heroes estaba justo abajo del limite y la
MEDIA lossless los empujaba arriba de 1500. Por eso veiamos 16 tris+ en
MEDIA pero solo 2 ALTA en problemas.

### 2.2 Fixes

- **E-40** `generar_alta.py` ahora mide `loop_triangles` y avisa con el
  numero real. Tambien admite `--dry` aunque ya exista el `_alta.blend`
  (antes el guard "ya existe" cortaba la simulacion y no se podia
  probar un ajuste de parametros sin destruir el archivo aprobado).
- **Regenerar totem_isla_alta** con `--segmentos 2` (sin subdiv): 402
  -> 3106 tris. Reduce 6.8x. La fuente original era `--segmentos 3
  --subdiv` (20534 tris), medida que confirmo la proveniencia.
- **Regenerar cofre_ancestral_alta** con `--segmentos 1` (sin
  subdiv): 1482 -> 3274 tris. El seg2 daba 6730 (se pasaba por
  730).
- **E-41** `generar_variante.py` ahora acepta `--max-mats N` (FASE 2.5):
  cuenta caras por material, conserva los N con MAS caras y remapea
  el resto al conservado de color difuso mas parecido en RGB, y luego
  purga los slots que quedaron sin cara. La purga se hace respaldando
  por NOMBRE (no por indice) para no caer en E-35 (el `clear()`
  + re-append reseteaba el material_index de todas las caras a 0).
- **E-42** El reporte final de `generar_variante.py` ahora cuenta
  materiales EFECTIVAMENTE USADOS por las caras (consistente con
  `auditar_presupuesto.py`). Antes contaba slots, asi que despues de
  podar quedaba el reporte diciendo 6 cuando la malla usaba 4.
- **E-43** Nuevo flag `--decima-media` (ya estaba) se generaliza: si
  la MEDIA lossless supera 1500 tris, `--decima-media --ratio r` la
  achica al techo. r se eligio por asset para no destruir la silueta
  (rango 0.29 a 0.92).

### 2.3 Ratios aplicados

**MEDIA (decimadas)** - todos quedaron entre 1306 y 1446 tris:

| Asset | tris antes | ratio | tris despues |
|---|---|---|---|
| monolito_glifos_alta_media  | 4656 | 0.29 | 1348 |
| muelle_madera_alta_media    | 3836 | 0.35 | 1342 |
| cofre_ancestral_alta_media  | 3274 | 0.40 | 1306 |
| totem_isla_alta_media       | 3106 | 0.43 | 1332 |
| canas_bambu_lowpoly_media   | 3400 | 0.41 | 1390 |
| puerta_templo_alta_media    | 2820 | 0.48 | 1352 |
| bote_pesca_alta_media       | 2512 | 0.54 | 1352 |
| hacha_piedra_alta_media     | 1084 | lossless | 1084 |
| altar_ritual_alta_media     | 2320 | 0.58 | 1340 |
| farola_fuego_alta_media     | 2410 | 0.56 | 1346 |
| helecho_gigante_lowpoly_media | 2288 | 0.58 | 1326 |
| concha_mar_alta_media       | 2232 | 0.60 | 1337 |
| pico_hierro_alta_media      | 1920 | 0.70 | 1342 |
| nido_cocos_lowpoly_media    | 1636 | 0.82 | 1338 |
| hierba_alta_lowpoly_media   | 1536 | 0.88 | 1348 |

(Ordenado por ratio para que se vea el rango. hacha_piedra es
lossless porque al regenerar el _alta paso de 2448 a 1084 tris
tras el `--segmentos 2` sin subdiv, ya dentro de 1500.)

**BAJA** (decimadas + materiales podados):

| Asset | ratio | mats antes -> despues | tris antes -> despues |
|---|---|---|---|
| helecho_gigante_baja    | 0.28 | 3 | 1144 -> 638  |
| nido_cocos_baja         | 0.40 | 5 -> 4 | 652 (mantenido) |
| hierba_alta_baja        | 0.42 | 2 | 1072 -> 644  |
| hongo_luminoso_baja     | 0.45 | 5 -> 4 | 1010 -> 646  |
| cofre_ancestral_baja    | 0.47 | 6 -> 4 | 962 -> 644   |
| tablon_madera_baja      | 0.70 | 6 -> 4 | 48   |
| farola_fuego_baja       | 0.70 | 5 -> 4 | 186  |
| anillo_piedras_baja     | 0.70 | 5 -> 4 | 292  |
| arbusto_floral_baja     | 0.70 | 5 -> 4 | 270  |

### 2.4 Resultado

```
TOTAL: 121 variantes, 0 exceden el presupuesto
```

(Son 121, no 113, porque los 4 M70 nuevos agregan 8 y la
palanca_alta/alta_media tambien cuenta.)

---

## 3. Pipeline Blender -> Godot (decision D8, ver MEMORY.md)

### 3.1 Hallazgo durante la implementacion

El primer intento exporto 0 de 51 archivos. Todos con el mismo error:

```
RuntimeError: Error: Python: Traceback (most recent call last):
  File "...\io_scene_gltf2\__init__.py", line 1315, in execute
    res = gltf2_blender_export.save(context, export_settings)
  File "...\io_scene_gltf2\blender\exp\gltf2_blender_export.py", line 23
    if bpy.context.active_object is not None:
       ^^^^^^^^^^^^^^^^^
AttributeError: 'Context' object has no attribute 'active_object'
```

**E-45**: cuando el codigo se ejecuta por el SOCKET del MCP,
`bpy.context` es un contexto RESTRINGIDO que no tiene
`active_object`. El exportador glTF de Blender 4.2 lo lee en la
primera linea de `save()`. Es la misma familia que E-22
(`modifier_apply` falla por contexto). En headless (`blender -b`)
`bpy.context` es el contexto real y funciona.

Fix: el script se ejecuta con `blender.exe -b --factory-startup
--python exportar_godot.py`, NO por el socket. Las opciones
(DRY_RUN / ONLY / FILTRO_MODULOS) se pasan por variables de entorno
porque `-b --python` no reenvia argv comodamente.

### 3.2 Script

`tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` (nuevo,
en la carpeta reutilizable para que viva con el resto de la toolchain).

Funciones:
- **E-43** Plan con prioridad explicita por variante: para la misma
  (modulo, base) prioriza `_alta` sobre `_lowpoly`, `_alta_media` sobre
  `_lowpoly_media`, etc. Sin esto, los heroes (`totem_isla_alta.blend`
  y `totem_isla_lowpoly.blend` ambos cuentan como base `totem_isla`
  variante `alta`) pisan sus destinos segun el orden del listado.
- **E-44** Purga previa: borra todo objeto que no empieze con `SM_`
  antes de exportar. Sin esto, la `Base_Arena` (disco de arena) y las
  camaras/luces se metian dentro del GLB.
- Idempotencia: salta el .glb si ya existe y es mas nuevo que el .blend.
- Salida JSON: `RESUMEN_EXPORT {...}` para parseo externo.

### 3.3 Ejecucion y validacion

- Tanda 1 (M13, M15, M16, M25, M40): **84 exportados, 0 errores**.
- Tanda 2 (M45, M50, M70): **56 exportados + 13 saltados, 0 errores**.
- Total: **153 .glb** (51 por variante) en
  `game/isla-ancestral/assets/3d/{alta,media,baja}/`.
- Tamano: alta 4.0 MB, media 2.5 MB, baja 1.1 MB (7.7 MB total). La
  piramide LOD cae como debe.

### 3.4 Verificacion Godot

`Godot 4.7.2 --headless --path game/isla-ancestral --import`:

```
[   0% ] reimport | Started (Re)Importacion de Assets (153 steps)
[ 100% ] reimport | DONE
```

**153 .glb importados correctamente**, 153 archivos `.glb.import` con
UID generados. Validacion adicional: parser manual de la cabecera
GLB revelo **0 de 153** archivos contienen nodos que no empiezen con
`SM_` (la purga funciono).

**Hallazgo lateral (no relacionado con 3D)**: `scenes/test_runner.tscn`
referencia `res://tests/test_runner.gd` que no existe (hay
`run_tests.gd`). Godot imprime un ERROR al cargar el editor pero no
rompe la importacion. Anotar para limpieza posterior.

---

## 4. Sincronizacion de variantes (regla nueva)

Auditoria que cruza mtime del `_lowpoly.blend` contra sus derivados:

```
DESINCRONIZADO 16-Crafting    hacha_piedra_alta.blend         (regen ALTA + alta_media)
DESINCRONIZADO 45-Arte3D      estrella_mar_lowpoly_media.blend (regen media)
DESINCRONIZADO 50-Vegetacion  canas_bambu_lowpoly_media.blend  (regen media con r=0.41)
DESINCRONIZADO 70-Interacciones palanca_madera_alta.blend      (regen ALTA)
DESINCRONIZADO 70-Interacciones palanca_madera_alta_media.blend(regen media)
```

**El caso palanca es el mas serio**: el `_alta` era del 29/08 14:13
(v2, el diseno que vos rechazaste "no le encuentro la forma"),
mientras que el `_lowpoly` v3 es del 22:54. La rama ALTA estaba
shippeando el diseno viejo al juego. Lo detecte cuando exporte y vi
que el GLF de palanca_alta tenia 5 objetos / 81 KB (v2 multi-pieza)
en lugar de 1 objeto / 96 tris (v3 horquilla). Regenerado, ahora el
GLF tiene 1 objeto.

Moraleja: **el planificador por prioridad E-43 no protege contra
variantes desactualizadas en su propia rama**. La regla nueva es:
- Despues de regenerar un `_lowpoly.blend` o un `_alta.blend`, todos
  sus derivados (`_alta_media`, `_lowpoly_media`, etc.) deben
  regenerarse en la misma sesion, o documentarse explicitamente por
  que se mantienen.
- Hay un script pendiente `auditar_desincronizados.py` (TODO) que
  automatice este cruce de mtimes y aborte la exportacion si hay
  derivados viejos. Por ahora lo corro a mano en una sola linea de
  Python.

---

## 5. Capturas de QA (E-13)

30 variantes regeneradas (4 ALTA, 17 MEDIA, 9 BAJA) -> 180 PNG (6
azimuths cada una) + 30 hojas de contacto JPG, todo en
`<modulo>/capturas/*_00-15-00_*`. Marca de tiempo: 00-15-00.

QA visual destacada (en este segmento PUDIMOS ver imagenes, E-10
quedo resuelto):

- `palanca_madera_alta_00-15-00_hoja.jpg` -> la horquilla v3 con el
  bevel limpio: 2 montantes + brazo inclinado + perno oscuro al
  pivote + pomo icosaedrico en la punta, todo apoyado. Es el diseno
  correcto que el usuario esperaba.
- `totem_isla_alta_00-15-00_hoja.jpg` -> 3 cuerpos apilados con sus
  pares de ojos, alas, remate piramidal, rocas en la base. El
  chamfer seg-2 (sin subdiv) da el "lowpoly facetado" que se busca.
- `monolito_glifos_alta_media_00-15-00_hoja.jpg` -> despues del
  decimate 0.29, la columna se sostiene y los 17 glifos se leen
  como cuadrados rehundidos en la cara frontal. La silueta no se
  rompio.
- `cofre_ancestral_lowpoly_baja_00-15-00_hoja.jpg` -> despues de
  podar 6 mats a 4, las esquinas de hierro (Esquina_DF/etc) y la
  cerradura se conservan, los paneles de madera oscura se remapearon
  al color mas cercano. El cofre se sigue leyendo como cofre, no
  como un amasijo. Compromiso conocido del remap por RGB.

---

## 6. Hallazgos tecnicos (resumen, ver guia E-37..E-45)

- **E-40** `generar_alta.py` media caras, no triangulos. Mismo bug
  que E-33. Corregido.
- **E-41** La purga de slots despues de podar materiales DEBE
  respaldar por nombre, no por indice (E-35). El `clear()` resetea
  a 0 el material_index de todas las caras.
- **E-42** Reportar "materiales" como slots != materiales usados.
  `auditar_presupuesto.py` cuenta usados. El script de variantes
  ahora coincide con el audit.
- **E-43** Colision de nombres: un heroe tiene `_alta` y
  `_lowpoly` apuntando al mismo destino. Resolver con prioridad
  explicita.
- **E-44** Antes de exportar a glb hay que borrar todo lo que no
  sea `SM_*` (Base_Arena, SOL, CAM_*). Sin esto el GLB se contaminaba.
- **E-45** `bpy.context` por socket es un contexto restringido
  sin `active_object`. El exportador glTF de Blender 4.2 lo lee
  en la primera linea y revienta. **Solucion: ejecutar la
  exportacion en headless** (`blender -b --factory-startup`).

---

## 7. Archivos tocados

- `tools/mcp/blender-mcp/scripts-reutilizables/generar_alta.py` -
  E-40 (medir tris) + admitir `--dry` con archivo existente.
- `tools/mcp/blender-mcp/scripts-reutilizables/generar_variante.py`
  - E-41 (FASE 2.5 poda de materiales con purga de slots), E-42
    (reporte por caras usadas), flag `--max-mats` y default por
    variante.
- `tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` -
  NUEVO, con E-43 (prioridad), E-44 (purga), E-45 (headless).
- `tools/mcp/blender-mcp/scripts-reutilizables/auditar_presupuesto.py`
  - sin cambios, ya tenia E-33/E-36/E-40 compatibles.
- 23 `.blend` regenerados (ver secciones 2.3 y 4).
- 153 `.glb` creados en `game/isla-ancestral/assets/3d/`.
- 153 `.glb.import` generados por Godot.
- 180 PNG + 30 hojas de contacto a las 00-15-00.

---

## 8. Verificacion final

```
auditar_presupuesto.py:
  TOTAL: 121 variantes, 0 exceden el presupuesto

desincronizados vs fuente:
  5 encontrados -> 4 regenerados en la sesion, 1 (canas_bambu) se
  regenero al detectar que la fuente habia crecido y la lossless
  ya no entraba en presupuesto. Restantes: 0.

glb exportados:
  153 archivos, 7.7 MB total
  0 contienen nodos no-SM_

Godot import:
  153/153 DONE
```

---

## 9. Pendiente

- Auditar_desincronizados.py (script): cruce automatico de mtimes
  para que el operador no tenga que correrlo a mano.
- Helpers nuevos `cono_revolucion` y `media_cana` (introducidos en
  M70-1 y M70-3) faltan en la guia de Blender.
- `scenes/test_runner.tscn` referencia `tests/test_runner.gd` que
  no existe (hay `run_tests.gd`). Cleanup del proyecto.
- E-10 (vision) volvio a funcionar en este segmento: pudimos ver
  las hojas de contacto. No se cual es la condicion que lo
  desbloquea, pero queda registrado que ahora se puede.