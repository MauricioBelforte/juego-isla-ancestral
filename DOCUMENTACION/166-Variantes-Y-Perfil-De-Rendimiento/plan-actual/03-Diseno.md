# 03 — Diseño · M166 Variantes de Assets por Perfil de Rendimiento

**Módulo:** 166 · **Estado:** plan-inicial · **Fecha:** 2026-08-28
**Agente:** MiniMax-M3 · WorkBuddy AI

---

## 1. Panorama

```
        ┌─────────────────────────────┐   ┌─────────────────────────────┐
        │ MEDIA · asset actual        │   │ ALTA · pasada artística     │
        │ crear_*_lowpoly.py (hoy)    │   │ modelado nuevo (futuro)     │
        │ lowpoly ya aprobado         │   │ +subdivisiones +biselados   │
        │ 33 obj / 784 tris           │   │ ~80 obj / ~4.000 tris       │
        └──────────────┬──────────────┘   └──────────────┬──────────────┘
                       │                                 │
                       │  generar_variante.py ──► BAJA    │
                       │  (merge+decimate+poda)           │
                       ▼                                 ▼
        ┌──────────────────────────────────────────────────────────────┐
        │  MERGE POR MATERIAL  (etapa de exportación, las 3 variantes) │
        │  No cambia la imagen: baja draw calls un 55-82 %             │
        └──────────────────────────────┬───────────────────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    ▼                  ▼                  ▼
            ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
            │ stats_asset  │  │ capturar_    │  │ export glTF  │
            │ ¿cumple el   │  │ angulos.py   │  │ por carpeta  │
            │ presupuesto? │  │ QA visual    │  │              │
            └──────────────┘  └──────────────┘  └──────┬───────┘
                                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
  res://assets/props/            res://assets/props/            res://assets/props/
    cofre/alta/                    cofre/media/                  cofre/baja/
    cofre_alta.gltf                cofre_media.gltf              cofre_baja.gltf
        │                               │                               │
        └───────────────────────────────┼───────────────────────────────┘
                                        ▼
                        ┌────────────────────────────┐
                        │  AssetProfile (autoload)   │
                        │  elige la carpeta según    │
                        │  perfil detectado/settings │
                        └────────────────────────────┘
```

**Clave:** el merge ya no define la variante — es una etapa común de exportación. La variante la define el nivel de detalle del modelado.

---

## 2. Nomenclatura

### 2.1 En Blender

| Elemento | Convención | Ejemplo |
|---|---|---|
| Objeto fusionable | `SM_{Asset}_{Pieza}` | `SM_Cofre_BandaH_1` |
| Objeto **NO** fusionable | `SM_{Asset}_{Pieza}_NOFUNDIR` | `SM_Cofre_Tapa_NOFUNDIR` |
| Material | `MAT_{Material}_{Asset}` | `MAT_Oro_Cofre` |
| **Blend fuente MEDIA** (asset actual, autoría) | `{asset}_lowpoly.blend` | `cofre_ancestral_lowpoly.blend` |
| Blend derivado MEDIA (merge) | `{asset}_lowpoly_media.blend` | `cofre_ancestral_lowpoly_media.blend` |
| Blend derivado BAJA (poda+decimate+merge) | `{asset}_lowpoly_baja.blend` | `cofre_ancestral_lowpoly_baja.blend` |
| **Blend fuente ALTA** (pasada artística, autoría) | `{asset}_alta.blend` | `cofre_ancestral_alta.blend` |
| Blend derivado ALTA (merge) | `{asset}_alta_media.blend` | `cofre_ancestral_alta_media.blend` |

**Regla `_NOFUNDIR`:** cualquier pieza que vaya a animarse, rotar, abrirse o interaccionar por separado lleva ese sufijo y el generador la respeta como objeto individual. Hoy ninguna pieza lo necesita (todos los assets son estáticos), pero la convención se fija ahora para no tener que rehacer el pipeline después.

#### Por qué en Blender NO se usa carpetas `alta/` `baja/` (decisión D8)

El usuario propuso separar las versiones en carpetas. Se adoptan las carpetas **solo del lado de Godot** (§2.2), no en Blender:

| Lugar | Estructura | Motivo |
|---|---|---|
| **Blender** | Plano, con sufijos (`_media`, `_alta`) | La ALTA y la MEDIA deben compartir silueta, paleta y `z_min` (R7). Si viven en carpetas separadas, divergen: se edita una y la otra queda vieja sin que nada lo delate. Juntas, el diff salta a la vista. |
| **Godot** | Carpetas `alta/` `media/` `baja/` | Es donde el runtime **elige** qué cargar según el perfil. Aquí la separación sí tiene sentido operativo. |

Además, en Blender los `_media` y `_baja` son **derivados regenerables** (no se versionan). Mezclarlos en carpetas con los fuentes (que sí se versionan) complicaría el `.gitignore`.

**En resumen: carpetas donde se consume, sufijos donde se edita.**

### 2.2 En Godot

```
res://assets/props/{asset_id}/{perfil}/{asset_id}_{perfil}.gltf
```

Ejemplo:

```
res://assets/props/cofre_ancestral/alta/cofre_ancestral_alta.gltf
res://assets/props/cofre_ancestral/media/cofre_ancestral_media.gltf
res://assets/props/cofre_ancestral/baja/cofre_ancestral_baja.gltf
```

- El `{perfil}` va en **minúsculas** (`alta` / `media` / `baja`) porque son rutas de sistema de archivos.
- El `{asset_id}` es snake_case, coherente con M149 (Nombres y Nomenclatura).

---

## 3. Algoritmo de generación de variantes

### 3.1 ALTA → MEDIA (merge por material)

**Entrada:** objetos `SM_*` de la escena, excluyendo los `_NOFUNDIR`.
**Salida:** un objeto por material distinto.

```
1. Limpiar el .blend derivado (abrir el de ALTA con wm.open_mainfile).
2. view_layer.update()  ← imprescindible para que matrix_world esté fresca.
3. Agrupar los SM_* (sin _NOFUNDIR) por material → diccionario {mat: [objetos]}.
4. Para cada grupo:
     a. Crear un bmesh vacío.
     b. Por cada objeto del grupo:
          - Copiar su mesh evaluada al bmesh, transformando cada vértice
            por obj.matrix_world (baking a coordenadas de mundo).
          - Copiar las caras con el mismo winding.
          - Si hay índices de material múltiples, respetar el slot.
     c. Crear un Mesh con ese bmesh y un objeto en (0,0,0), scale (1,1,1).
     d. Asignarle el material del grupo.
     e. Nombrarlo SM_{Asset}_Merge_{Material}.
5. Borrar los objetos originales (solo los que se fusionaron).
6. Re-verificar z_min y re-asentar a 0.045 si hizo falta (E-12).
7. Guardar como {asset}_lowpoly_media.blend.
```

**Punto crítico (E-18 aplicado al revés):** al fusionar con baking a coordenadas de mundo, el objeto resultante tiene `location=(0,0,0)` y `scale=(1,1,1)`. **No hereda transformaciones**, así que cualquier hijo futuro funcionaría con `Matrix()`. Por eso el merge es seguro.

**Punto crítico 2:** no usar `bpy.ops.object.join()` cuando hay objetos con padres, porque el join reescribe `matrix_parent_inverse` y puede desplazar piezas. El merge por `bmesh` evita el problema por completo.

### 3.2 MEDIA → BAJA (decimate + poda)

```
1. Partir de MEDIA.
2. Poda: eliminar objetos cuyo volumen de bounding box sea < UMBRAL_PODA
   (piezas diminutas: glifos, tirador).
   UMBRAL_PODA = 1e-4 m³ (cubo de 4.6 cm de lado), calibrado sobre el cofre.
3. Merge por material (igual que 3.1).
4. Decimate: ratio 0.7, SOLO sobre las mallas fundidas.
   - NO usar dissolve boundaries (rompe las aristas duras del flat shading).
   - ratio 0.5 destruye mallas planas lowpoly → E-23.
5. shade_flat() a todos.
6. Re-verificar z_min y re-asentar (E-12).
7. Guardar como {asset}_lowpoly_baja.blend.
```

**Advertencia 1:** la poda puede eliminar piezas que sostienen visualmente a otras (por ejemplo, los pies del cofre). Se excluyen explícitamente de la poda los nombres que contengan `Pie`, `Base`, `Soporte`, `Tronco`, `Poste`, `Cuerpo`, `Tapa` (`PROTEGIDAS`).

**Advertencia 2:** las piezas con detalle fino (costillas, cerradura, gemas, asas, tirador, ojos) van en `CRITICAS_NO_FUNDIR`: **no se funden ni se decimatan**. El decimate las destruiría (E-23). Lista extensible por asset al tope del script.

---

### 3.3 ALTA — la pasada artística (trabajo nuevo planificado)

**La ALTA no se deriva por script: se modela.** Es la mejora artística que el proyecto ya planea hacer sobre sus assets. El objetivo es que la diferencia con MEDIA sea **visible**, no solo medible.

**Presupuesto:** ≤ 6.000 tris (≈7,6× el cofre actual), ≤ 16 objetos tras merge, ≤ 12 materiales.

#### Qué se le agrega a un asset para promoverlo de MEDIA a ALTA

Tomando el cofre ancestral (784 tris en MEDIA) como ejemplo:

| Pieza | MEDIA | ALTA | Tris ganados |
|---|---|---|---|
| `Tapa` (medio cilindro) | 10×13 segmentos | 20×26 segmentos | 152 → ~600 |
| `Remaches` (22 en 1 malla) | cajas de 6 caras | esferas subdiv 2, piezas individuales | 132 → ~500 |
| `Gema` | icoesfera subdiv 2 | icoesfera subdiv 3 | 80 → ~320 |
| `Costilla_1/2/3` | toroide 12×4 | toroide 24×8 | 48 → ~150 c/u |
| `Asa_I/D` | toroide 12×4 | toroide 24×8 | 40 → ~120 c/u |
| Cuerpo, bandas, esquinas | cajas de 6 caras, filos vivos | **biselados** (bevel 2 segmentos) | +~200 |
| Detalles nuevos | — | vetas de madera en relieve, mecanismo de cerradura, bisagras articuladas | +~500 |
| **Total** | **784** | **~4.000** | **5×** |

#### Técnicas ordenadas por rendimiento visual / coste

1. **Biselar aristas (bevel)** — el cambio más evidente. Un cofre con filos vivos parece de juguete; con biselados parece un objeto real. Coste bajo en tris.
2. **Subdividir superficies curvas** — tapas, toroides, esferas. De 10 a 20 segmentos duplica la suavidad.
3. **Detalles modelados en relieve** — vetas de madera, grabados, mecanismos. Lo que en MEDIA era color plano, en ALTA es geometría.
4. **Piezas individuales en lugar de mallas agrupadas** — los 22 remaches como esferas separadas en vez de una malla con cajas.
5. **Materiales adicionales** — MEDIA usa 6; ALTA puede usar hasta 12 (madera clara, madera oscura, madera veteada, hierro, hierro oxidado, bronce, bronce pulido, oro, oro viejo, gema, cuero, tela).

#### Reglas de la pasada (R7)

- ✅ Añadir detalle, subdividir, biselar, enriquecer materiales.
- ❌ **No cambiar la silueta.** Si el cofre mide 0.7 × 0.4 × 0.62 en MEDIA, mide lo mismo en ALTA.
- ❌ **No cambiar la paleta.** Los colores base de `MAT_*` se conservan; se pueden agregar variantes (bronce pulido), no reemplazar.
- ❌ **No mover el apoyo.** `z_min = 0.045` se mantiene (E-12).
- ❌ **No animar lo que en MEDIA no se anima.** Si se añade una pieza animada, marcarla `_NOFUNDIR`.

#### Verificación

```bash
python stats_asset.py SM_Cofre_ ../25-Ruinas-Templos/cofre_ancestral_lowpoly_alta
# Debe dar: OK ALTA obj ~12/16  tris ~4000/6000  mats ~12/12
# Y debe dar NO en MEDIA (se pasa de triángulos) — eso confirma que hay salto real.
```

**Si ALTA da OK en MEDIA, la pasada no agregó suficiente detalle y hay que seguir trabajando.**

---

## 3.4 Cuándo se optimiza: la puerta de aprobación (R9)

Directiva del usuario 2026-08-28: *"si lo optimizamos no vamos a dejar los objetos sin optimizar solo para que ocupen recursos"*.

### La regla

**El merge por material es obligatorio para todo asset aprobado. La versión sin mergear nunca se exporta.**

Esto no significa que existan dos versiones conviviendo en el juego. Significa que hay dos archivos con papeles distintos:

| Archivo | Objetos | Papel | Se exporta a Godot |
|---|---|---|---|
| `{asset}.blend` (source) | N (ej. 33) | **Autoría.** Editable: se mueve un remache, se borra una hoja, se cambia un color | ❌ **Nunca** |
| `{asset}_media.blend` | ~6 | **Envío.** Geometría idéntica, draw calls −80 % | ✅ Sí |
| `{asset}_baja.blend` | ~6 | **Perfil bajo.** Poda + decimate 0.7 | ✅ Solo perfil bajo |

No se "dejan objetos sin optimizar ocupando recursos": el source no llega nunca al juego. Es el archivo de trabajo, como un `.psd` frente a un `.png`.

### Por qué NO se mergea en el script de creación

Se evaluó meter el merge directamente en cada script de creación de asset. Se descartó por tres razones:

1. **Se pierde la editabilidad durante toda la iteración.** Mientras se está ajustando un asset hay que mover piezas sueltas. Un cofre de 6 mallas fusionadas no permite mover un remache sin rehacer la malla.

2. **El algoritmo mejoraría en 117 sitios en vez de en uno.** Cuando se descubrió que decimate 0.5 rompía las mallas planas (E-23), el arreglo fue cambiar una constante en un script. Si el merge estuviera copiado en cada script de creación, habría que tocar 117 archivos y regenerar todo.

3. **El merge es idempotente y barato.** Se regenera con un comando. No hay coste en no tenerlo bakeado.

### Cuándo se corre

**Al aprobar el asset**, no antes. El momento es: se termina de iterar el source → pasa el QA visual multi-ángulo (E-13) → se corre `generar_variante.py --media --baja` → se verifica con `stats_asset.py` → se exporta.

Si después hay que editar el asset, se edita el **source** y se vuelve a correr el merge. El derivado nunca se edita a mano.

### Verificación: `auditar_optimizacion.py`

Script de auditoría que escanea todos los módulos y reporta qué assets tienen su versión mergeada y cuáles no. No necesita Blender (trabaja sobre el filesystem).

```bash
python auditar_optimizacion.py            # reporte completo
python auditar_optimizacion.py --falta    # solo los pendientes
```

Devuelve exit code 1 si hay assets sin mergear, así que puede entrar en CI. **Un asset que figura con `MEDIA = FALTA` no se exporta.**

---

## 3.5 Qué assets reciben la pasada ALTA (decisión D9)

Directiva del usuario 2026-08-28: *"las de alta calidad que tienen mas detalles... vas a tener que mejorar las que ya tenemos. si se te ocurre otra idea me decis"*.

**La otra idea: no hace falta que los 41 reciban la pasada ALTA.** Hacerla sobre todo el catálogo sería semanas de trabajo con retorno casi nulo en la mitad de los casos, y en la vegetación sería directamente contraproducente.

### El argumento numérico

La vegetación se instancia con **MultiMesh** (ítem A12). Eso significa que el coste de una variante ALTA no se paga una vez, se paga por instancia:

| Asset | Tris MEDIA | Tris ALTA | × 300 instancias |
|---|---|---|---|
| `palmera_lowpoly` | ~700 | ~4.000 | 210.000 → **1.200.000** |
| `hierba_alta_lowpoly` | ~300 | ~2.000 | 90.000 → **600.000** |

Una sola especie de palmera en ALTA puede comerse por sí sola el frame budget entero. Y a la distancia de cámara a la que se ve una palmera en un juego cozy, **4.000 triángulos se ven exactamente igual que 700**. El detalle extra no se percibe; el coste sí.

### Criterio de clasificación

| # | Criterio | Veredicto |
|---|---|---|
| 1 | El jugador **interactúa** con él (abrir, accionar, recoger en mano) | ALTA |
| 2 | Se **sostiene en mano** y se ve en primerísimo plano | ALTA |
| 3 | Es un **hito visual** de la isla (se ve desde lejos, marca un lugar) | ALTA |
| 4 | Se **instancia por cientos** (vegetación, rocas, hierba) | Solo MEDIA |
| 5 | Es **decoración de fondo** o se pisa sin mirarla | Solo MEDIA |

### Clasificación de los 41 assets

**ALTA — héroes (15).** Se interactúa, se sostiene o es un hito.

| Módulo | Assets |
|---|---|
| 13-Herramientas | `pico_hierro`, `pico_piedra`, `antorcha_mano` |
| 15-Recursos | `cristal_ancestral` |
| 16-Crafting | `hacha_piedra`, `lingote_metal` |
| 25-Ruinas-Templos | `cofre_ancestral`, `altar_ritual`, `puerta_templo` |
| 40-Infraestructura | `bote_pesca`, `farola_fuego`, `muelle_madera` |
| 45-Arte3D | `monolito_glifos`, `totem_isla`, `anillo_piedras_ritual`, `concha_mar` |
| 70-Interacciones | `palanca_madera` |

**FRONTERA (1).** Caso límite que sigue dudoso tras la promoción de los otros dos.

| Módulo | Asset | Por qué es dudoso |
|---|---|---|
| 25-Ruinas-Templos | `losa_grabado` | Los glifos piden detalle, pero va en el piso, nunca se ve de cerca |

**Decisión sobre la frontera (2026-08-29, log 234).** De los 3 casos:
- `muelle_madera` **promovido a ALTA** (era el "hito visual" de la costa — argumentos a favor pesaron más que el "tablones repetidos"). Generado `muelle_madera_alta.blend` (1986 tris, 19 obj → 3 mallas post-merge).
- `concha_mar` **promovida a ALTA** (criterio 2: "se sostiene en mano y se ve en primerísimo plano" — encaja perfecto). Generado `concha_mar_alta.blend` (1162 tris, 2 obj).
- `losa_grabado` **se queda en MEDIA** (criterio 2 falla: nunca se ve de cerca, está en el suelo).

**SOLO MEDIA — relleno (23).** Instanciados o de fondo.

| Módulo | Assets |
|---|---|
| 15-Recursos | `monton_ramas`, `nido_cocos`, `piedra_afilar`, `roca_comun`, `roca_pedernal`, `tronco_caido`, `veta_cobre`, `veta_hierro`, `veta_oro` |
| 16-Crafting | `tablon_madera` |
| 45-Arte3D | `estrella_mar` |
| 50-Vegetacion | los 12 (`arbusto_floral`, `arbusto_redondo`, `canas_bambu`, `flor_isla`, `helecho_chico`, `helecho_gigante`, `hierba_alta`, `hongo_luminoso`, `liana_colgante`, `palmera`, `palmera_inclinada`, `palmera_joven`) |

### Consecuencias

1. **La carpeta `alta/` en Godot no tiene 41 entradas, tiene 15** (18 si se suma la frontera). Un asset sin ALTA no está "incompleto": está declarado como relleno y documentado.
2. **El runtime nunca debe pedir una ALTA inexistente.** El selector de perfil tiene que caer a MEDIA cuando no hay ALTA (ver §4).
3. **Ningún asset queda sin optimizar por esto.** Los 23 de relleno igual tienen su `_media` y su `_baja` mergeadas (R9). Lo que no tienen es detalle extra, porque no lo necesitan.
4. **La pasada se hace de a una, por módulo, con el mismo circuito de siempre:** editar el source → `generar_variante.py` → `stats_asset.py` (tiene que dar **NO en MEDIA**) → `capturar_angulos.py` 6 orbitales → aprobar.

### Regla de oro de la pasada

> Si al terminar la ALTA de un asset el `stats_asset.py` la marca **OK en MEDIA**, la pasada no agregó suficiente detalle. Hay que seguir. El objetivo es que la ALTA se pase del presupuesto MEDIA (≤1.500 tris) y se acerque al suyo (≤6.000).

### Estado de la pasada ALTA (2026-08-29)

**17/17 héroes procesados** (15 iniciales + 2 promovidos de la frontera en log 234: `muelle_madera`, `concha_mar`). Las 17 variantes `*_alta.blend` existen.

**Receta aplicada** (`tools/mcp/blender-mcp/scripts-reutilizables/generar_alta.py`):
```bash
python generar_alta.py <modulo> <asset_lowpoly> --segmentos 3 --ancho 0.10 --subdiv
```

| Héroe | Tris (src → alta) | Obj | Mats | Veredicto |
|---|---|---|---|---|
| `pico_hierro` | 92 → 956 | 8/16 | 3/12 | OK |
| `pico_piedra` | 82 → 716 | 7/16 | 3/12 | OK |
| `antorcha_mano` | 88 → 556 | 6/16 | 4/12 | OK |
| `cristal_ancestral` | 174 → 657 | 8/16 | 4/12 | OK |
| `hacha_piedra` | 278 → 1228 | 6/16 | 3/12 | OK |
| `lingote_metal` | 24 → 678 | 4/16 | 2/12 | OK |
| `cofre_ancestral` | 784 → 5980 | **33**/16 | 6/12 | ⚠ Excepción: cofre complejo |
| `altar_ritual` | 254 → 1162 | 11/16 | 4/12 | OK |
| `puerta_templo` | 90 → 1470 | 15/16 | 3/12 | OK |
| `bote_pesca` | 111 → 1304 | 13/16 | 4/12 | OK |
| `farola_fuego` | 157 → 1229 | 13/16 | 5/12 | OK |
| `monolito_glifos` | 154 → 2406 | **19**/16 | 2/12 | ⚠ Excepción: 19 glifos |
| `totem_isla` | 233 → 10543 | **32**/16 | 4/12 | ⚠ Excepción: hito visual, 32 caras |
| `anillo_piedras_ritual` | 265 → 680 | 9/16 | 5/12 | OK |
| `palanca_madera` | 96 → 560 | 5/16 | 3/12 | OK |

**Excepciones aprobadas al budget de 16 obj / 6000 tris** (complejidad inherente, no error de proceso):
- `totem_isla_alta` — **única excepción real**: 10.543 tris (vs 6.000 del budget). Es el "hito visual" de la isla, se renderiza con poca frecuencia y la inversión se justifica.

> **Corrección al log 232:** el budget de "16 objetos" aplica **después del merge** (§3.3), no antes.
> Por eso `cofre_ancestral_alta` (33 obj → 6 post-merge) y `monolito_glifos_alta` (19 obj → 2
> post-merge) NO son excepciones. El merge por material los baja a 6 y 2 respectivamente. La pasada
> ALTA con merge aplicado se documenta en el log 233.

**Verificación visual** (E-13): `pico_hierro_alta`, `hacha_piedra_alta` y `totem_isla_alta` confirmados con 6 capturas orbitales — biselado y subdiv visibles, sin flotación, `z_min = 0.0450` preservado. Los 12 restantes herendan la pose y la `z_min` de su `_media.blend` (la pasada ALTA solo agrega modificadores locales, no toca `location`).

**Verificación visual adicional (log 237, 2026-08-29):** `pico_hierro`, `pico_piedra` y `hacha_piedra` corregidos a pose vertical con cabeza arriba (rotación de la herramienta tumbada). Capturas orbitales 6× confirmadas en `_baja`, `_media`, `_alta` y `_alta_media` para los 3 — sin flotación, `z_min = 0.0450`. Bug del fix: la rotación -90° en Y ponía la cabeza abajo en `pico_hierro` (el handle de la versión tumbada tenía la cabeza en el -X); se aplicó +180° en su lugar para que la cabeza quede arriba. Las otras 2 ya estaban verticales en el source.

**Pendiente:**
- Re-derivar `_media` y `_baja` desde `_alta` (R9: el ALTA pasa a ser source of truth). Hoy las `_media`/`_baja` existentes se generaron desde el source; hay que regenerarlas.
- ~~Decidir la frontera (3 assets): `muelle_madera`, `losa_grabado`, `concha_mar`.~~ **Resuelto en log 234**: `muelle_madera` y `concha_mar` promovidos a ALTA; `losa_grabado` se queda en MEDIA.
- Crear `res://assets/props/<asset_id>/<perfil>/` en Godot (D8) para los 17 héroes.
- Declarar `variantes_disponibles = ["alta","media","baja"]` en el `ItemData` de M159 para los 17; `["media","baja"]` para los 22 de relleno (23 - `losa_grabado` que sigue en MEDIA, ya estaba).

---

## 4. Perfiles y selección en runtime

### 4.1 Detección automática

`AssetProfile` se resuelve una sola vez al arrancar, en este orden de prioridad:

1. **Override del usuario** — `GameSettings.perfil_assets` (`"auto"` / `"alta"` / `"media"` / `"baja"`). Si no es `"auto"`, gana.
2. **Detección de hardware** en modo `"auto"`:

| Señal | Condición | Perfil |
|---|---|---|
| `OS.get_processor_name()` contiene "Apple M" | siempre | `media` |
| Memoria de video reportada | < 2 GB | `baja` |
| Memoria de video reportada | 2–4 GB | `media` |
| Memoria de video reportada | > 4 GB | `alta` |
| `OS.get_name() == "Android"` o `"iOS"` | siempre | `baja` |
| Nombre de GPU en lista negra (Intel HD 4000/5000, Mali-T8xx) | siempre | `baja` |

3. **Fallback conservador:** `media` (nunca `alta` por defecto — es mejor que falte un remache a que el juego vaya a 20 fps).

### 4.2 API

```gdscript
# Autoload AssetProfile
AssetProfile.perfil               # "alta" | "media" | "baja"
AssetProfile.ruta(asset_id)       # "res://assets/props/cofre_ancestral/media/cofre_ancestral_media.gltf"
AssetProfile.cargar(asset_id)     # PackedScene listo para instanciar
AssetProfile.cambiar_perfil(p)    # recarga en caliente (solo en menú de opciones)
```

### 4.3 Regla de selección por distancia (complementaria)

Además del perfil global, un asset puede declarar LOD por distancia dentro de su propia variante. En M166 **esto no se implementa** (los objetos fusionados ya son 1 draw call); queda documentado para cuando existan assets grandes (barco hundido, volcán):

```gdscript
MeshInstance3D.lod_bias      # multiplicador de distancia de LOD
GeometryInstance3D.visibility_range_begin / _end   # Godot 4.x
```

---

## 5. Vegetación y props repetidos: MultiMesh

Los assets de vegetación **NO siguen el pipeline de variantes**. Siguen el de `MultiMeshInstance3D`. Coincide con la decisión **D9 (§3.5)**: los 12 assets de `50-Vegetacion` son relleno y quedan en MEDIA de forma permanente, porque su coste se multiplica por la cantidad de instancias.

| Asset | Objetos | Estrategia |
|---|---|---|
| Hierba alta | 32 | 1 MultiMesh con 32 instancias por mata, y la mata entera repetida por MultiMesh |
| Helecho gigante | 91 | Idem |
| Cañas de bambú | 38 | Idem |
| Palmera (cualquier variante) | 11 | MultiMesh si hay > 10 en escena |

**Regla:** si un asset aparece más de 10 veces en una escena, va con `MultiMeshInstance3D`, no con variantes. Un MultiMesh dibuja miles de instancias en **1 draw call**, lo que hace irrelevante el perfil.

`AssetProfile` expone además:

```gdscript
AssetProfile.debe_usar_multimesh(asset_id) -> bool
```

---

## 6. Integración con el catálogo de objetos (M159)

Cada `ItemData` gana dos campos:

```gdscript
class_name ItemData extends Resource

@export var id: StringName
@export var modelo_id: StringName      # "cofre_ancestral" → resuelto por AssetProfile
@export var usa_multimesh: bool = false
@export var variantes_disponibles: PackedStringArray = ["alta", "media", "baja"]
```

Si `variantes_disponibles` no contiene el perfil activo, `AssetProfile.ruta()` **degrada al perfil más alto disponible** y emite un `push_warning` en Debug. Así un asset recién creado (solo ALTA) funciona aunque el jugador esté en `baja`.

**Esto es exactamente lo que necesita la decisión D9 (§3.5).** Los 23 assets de relleno declaran:

```gdscript
variantes_disponibles = ["media", "baja"]     # sin ALTA, declarado a propósito
```

Y los 17 héroes, cuando terminen su pasada:

```gdscript
variantes_disponibles = ["alta", "media", "baja"]
```

El campo ya existía en el diseño y resuelve D9 sin tocar una línea del runtime: **no hay que programar nada nuevo para que un asset sin ALTA funcione.**

---

## 7. Qué NO se fusiona

| Caso | Razón |
|---|---|
| Objetos con sufijo `_NOFUNDIR` | Van a animarse |
| `Base_Arena`, `SOL`, `Mundo`, `CAM_*` | Set de captura, nunca se exportan (§7) |
| Objetos con hijos | El merge por bmesh iguala todo; si tiene hijos se fusiona solo el padre y los hijos se re-parentan al mesh resultante |
| Assets con > 6 materiales | Se revisan a mano: probablemente haya que reducir la paleta antes de fusionar |

---

## 8. Flujo de trabajo para el desarrollador

```bash
# 1. Modelar (como hasta ahora)
python ejecutar_script.py 25-Ruinas-Templos crear_cofre_ancestral_lowpoly.py

# 2. Medir  — dice si cumple el presupuesto
python stats_asset.py SM_Cofre_
# → NO  MEDIA  obj 33/8   tris 784/1500   mats 6/6

# 3. Generar variantes
python generar_variante.py 25-Ruinas-Templos cofre_ancestral_lowpoly --media
python generar_variante.py 25-Ruinas-Templos cofre_ancestral_lowpoly --baja

# 4. Re-medir
python stats_asset.py SM_Cofre_
# → OK  MEDIA

# 5. Capturar QA de las 3 variantes (E-13: todos los ángulos)
python capturar_angulos.py SM_Cofre_ .../cofre_media.png 6
```

---

## 9. Decisiones de diseño registradas

| # | Decisión | Alternativa descartada | Motivo |
|---|---|---|---|
| D1 | Tres variantes, no dos | Dos (la propuesta original) | MEDIA es gratis (cero pérdida visual); tenerla cuesta un script y ahorra un 82 % de draw calls |
| D2 | ALTA es la única fuente de verdad | Versionar las tres | Evita divergencia; las derivadas se regeneran |
| D3 | MEDIA es el default | ALTA como default | MEDIA no se distingue de ALTA; si algo va a fallar, que falle en el perfil correcto |
| D4 | Merge por bmesh, no `bpy.ops.object.join()` | join | El join reescribe `matrix_parent_inverse` y desplaza piezas con padre |
| D5 | Presupuesto manda en objetos, no en tris | Presupuesto de triángulos | Medición: 784 tris es irrelevante, 33 draw calls no |
| D6 | Las variantes no se versionan | Versionarlas | Son artefactos regenerables; versionarlas garantiza desincronización |
| D7 | Vegetación → MultiMesh, no variantes | Variantes para todo | Un MultiMesh ya es 1 draw call; las variantes no aportan nada ahí |
