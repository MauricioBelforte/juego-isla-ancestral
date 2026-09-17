# 05 — Checklist antes de dar por terminado un asset

**Modelo:** MiniMax-M3 (OpenCode)
**Plataforma:** OpenCode CLI
**Fecha:** 2026-09-10

**Propósito:** Extraído de OBSOLETOS/09-GUIA-BLENDER.md §4 "Checklist antes de dar por terminado un asset". Lista verificable de requisitos que todo asset Blender debe cumplir antes de considerarse terminado.

---

- [ ] Script idempotente (re-ejecutable sin duplicar)
- [ ] Mínima cantidad de mallas posible
- [ ] Materiales `MAT_*` con roughness acorde
- [ ] Escena de prueba con cámara + sol (sombra visible)
- [ ] `.blend` guardado en `trabajos/`
- [ ] Captura con timestamp en `capturas/{ID-Modulo}-Nombre/` (conservar la anterior)
- [ ] **Revisión visual de la captura** (si el modelo no acepta imágenes: QA numérico con `verificar_bounds.py` y dejar constancia de la revisión pendiente — E-10)
- [ ] QA numérico: `z_min` apoyado (ni flotando ni hundido), sin centros duplicados, materiales asignados
- [ ] **Detalles "pegados" a un cuerpo** (ojos, remaches, vetas, ...) parentados al cuerpo con `matrix_parent_inverse` identidad (E-11)
- [ ] **Apoyos medidos en caliente**, no calculados a partir del espesor nominal (E-09): el script autocorrige midiendo el bounding box y trasladando el objeto al objetivo
- [ ] **`grep -in` GLOBAL al checklist antes de empezar**: si el ítem ya existe marcado `[x]` en OTRA sección, es duplicado → cerrarlo como tal, no autorar otra vez (E-71, 4 casos ya)
- [ ] **Conteo de `SM_` hecho ANTES de ejecutar**: `≤16` ALTA. Ojo con los bucles anidados (lado × repetición), que crecen multiplicativo (E-70)
- [ ] **Curva correcta según dónde esté la carga**: cuerda suelta → `cosh`; tablero con carga uniforme → parábola (E-69)
- [ ] **Verificación de import por CONTEO de archivos**, no por mtime: `glb == .glb.import == .scn` (E-65 + E-72)
- [ ] **Path del script desde `dirname(__file__)`**: NO calcular `RAIZ` con
  varios `..` y después re-encadenar `tools/mcp/...` — eso duplica `tools` si
  los `..` no alcanzan. Construir `DIR_MOD = abspath(join(dirname(__file__),
  '..'))` directamente. `assert basename(DIR_MOD) == '<NN>'` mata el bug
  (E-82)
- [ ] **Ninguna pieza larga, delgada y horizontal a la altura de cadera/torso** de figuras humanoides (E-73): un travesaño único lee como genital. Romper y angulizar si es estructural.
- [ ] **Ninguna pieza cilíndrica/caja corta sobresaliendo horizontalmente del pecho** de figuras humanoides (E-74): también lee como pico. Las "pajas" / "rellenos" deben asomar por las costuras naturales (dobladillo, cuello, sisa), nunca perpendiculares al pecho.
- [ ] **Asentado en la base** (E-12): `z_min` del elemento que toca el suelo ≤ 0.05 (verificable con `auditar_apoyos.py`); **auditar TODOS los obj** (E-36), no solo el primero
- [ ] **Guard de ropa con `partes=` por pieza** (E-89): camisa/cinturón/chaquetón NO contra brazos; perneras NO contra torso; mangas solo contra brazos+deltoides
- [ ] **Tapas de tubos cerrados marcadas OCULTO** (E-87): hombros de mangas, tobillos de perneras, cinturas de caderas. pasar el PUNTO EXACTO, no un "cerca del eje" genérico
- [ ] **Materiales tras `unir()`** (E-83): si hay deduplicación de slots, respaldar `material_index` por cara, `clear()`, re-asignar. Nunca `clear()` a secas (resetea a 0)
- [ ] **Torus horizontal** (E-85): `primitive_torus_add()` ya es horizontal (eje del agujero en +Z). NO rotar 90° para "horizontalizarlo"
- [ ] **Cobertura total del apoyo** (E-12): el elemento sobre el que se asienta el asset cubre TODA su planta (anillos/abanicos completos, no parciales)
- [ ] **Asentado en la base** (E-12): `z_min` del elemento que toca el suelo ≤ 0.05 (verificable con `auditar_apoyos.py`)
- [ ] **Verificación multi-ángulo** (E-13, directiva del usuario 2026-08-28): correr `capturar_angulos.py SM_<asset> ruta.png 4` y revisar TODAS las capturas. Si UNA sola muestra luz/aire entre el objeto y su base, corregir y volver a correr. **Una sola captura frontal no alcanza.**
- [ ] **Optimización obligatoria al aprobar** (M166, directiva del usuario 2026-08-28): una vez que el asset queda aprobado, correr `python generar_variante.py <modulo> <asset> --media --baja`. El merge por material es **lossless** (la geometría es idéntica, los draw calls bajan un 80 %+). **El `.blend` source con N objetos separados es el archivo de AUTORÍA: nunca se exporta a Godot. Solo se exporta el mergeado** (`_media.blend`).
- [ ] **Auditoría de presupuesto real** (E-33, E-36): correr `python scripts-reutilizables/auditar_presupuesto.py` y confirmar que el asset NO aparece en la lista de "excede el presupuesto". A diferencia de `auditar_optimizacion.py` (que solo verifica que existan los `_media`/`_baja`), este script abre cada `.blend`, cuenta triángulos REALES (`loop_triangles`), slots de material y materiales distintos usados, y avisa de cualquier exceso en `obj+`, `tris+` o `mats+`. Si excede, re-derivar con `--ratio <F>` (E-29) hasta que pase. Tras E-36, el conteo de materiales recorre TODOS los `objs` SM_ (no solo `objs[0]`).
- [ ] **Saneo de slots** (E-34, E-35): tras un `generar_variante.py --baja` con una versión de `generar_variante.py` previa al fix de E-35, correr `python scripts-reutilizables/saneo_bajas_e34.py`. NUNCA usar `Mesh.materials.clear()` como "limpieza": resetea a 0 el `material_index` de todas las caras (E-35). `saneo_bajas_e34.py` usa `pop()` que no lo hace.
- [ ] **Optimización por lote** (cuando hay varios assets pendientes): `python procesar_lote.py` procesa todos los módulos; `python procesar_lote.py 50-Vegetacion --media` restringe a un módulo y a una sola variante. Es **idempotente**: saltea los assets que ya tienen `_media`. Referencia: 41 assets en 168 s.
- [ ] **Módulo registrado en el export** (E-63): si el módulo es NUEVO, agregarlo a la tupla `MODULOS` de `exportar_godot.py`. Si no, el export devuelve `{"exportados": 0}` **sin ningún error**.
- [ ] **Cabeza en su sitio** (E-90): si el asset usa `construir_cabeza()` y es STANDALONE (no montado), aplicar `p.location.z += Z_REF_CABEZA` a TODAS las piezas devueltas y dejar el `assert z_min_cabeza > cuello - 0.05`. La clave del dict es `'Z_CRANEo'` con la **o minúscula**. Control final: el `delta` de `generar_variante.py` debe ser ≈ 0.000.
- [ ] **Herramientas alargadas usan `asentar_herramienta()`** (E-91): NUNCA delegar a `plantilla_asset.asentar()` para herramientas (hacha, martillo, azada, machete, pico, azuela, guadaña, pala, serpeta, horca). Tres condiciones: `toca ≥ 8`, `min(fp) ≥ 0.02`, **`max(fp) ≥ 0.45 × L`**. **CUIDADO (corregido 2026-09-06, log 730):** el criterio NO es "alargado vs ancho", es **tamaño**. E-50 exige `min(fp) > 0.30`, así que rechaza a **todo objeto cuyo diámetro sea menor a ~0.7 m**, sea alargado o ancho. Un bowl de 0.21 m y un frasco de 0.18 m son "anchos" pero chicos: van con `asentar_herramienta()`. E-50 original solo para props de ~1 m o más (muebles, rocas, lingotes grandes, tablones). **Geometría:** mangos con `hz` constante a lo largo (swell solo en `hy`); para `lados=6, fase=0` dividir el espesor por `F_PLANO = 0.8660` para que el grosor efectivo coincida con el pedido.
- [ ] **Piezas HUECAS van con `revolucion()`, no con `loft()`** (E-92): bowls, platos, cuencos, vasijas, ánforas, jarras, copas. `loft()` exige z crecientes (E-77) y no puede subir por fuera y bajar por dentro. `revolucion(perfil, materiales, lados, idx_mat)` asigna material por TRAMO (franjas pintadas / interior vidriado sin sumar triángulos). Si el perfil empieza y termina en el eje, **verificar con el volumen firmado**: `V = (1/6)·Σ(v0×v1)·v2` debe dar **> 0** (normales hacia afuera). Si da negativo, el perfil está recorrido al revés.
- [ ] **Hojas y superficies finas: PLANAS** (E-93). Si usás extrusión a lo largo de una normal media (`prisma_contorno` o similar), medí la desviación de planitud (~1e-16). Un volumen firmado negativo puede ser falla del TEST (abanico sobre cara alabeada), no de la malla: hacé el control con un cubo antes de tocar la forma.
- [ ] **`view_layer.update()` ANTES de medir** (E-94): si moviste objetos con `location`, `matrix_world` está viejo y `zmin_real()` devuelve cualquier cosa (midió −0.017 en un objeto que estaba en +0.194).
- [ ] **Variantes sin GUI:** si el socket 9876 está caído (Blender cerrado), usá `generar_variante_headless.py` — ejecuta el MISMO payload canónico de `generar_variante.py`, pero sin red. No hace falta abrir Blender con el addon.
- [ ] **Dry-run antes del export real** (E-63): `EXPORT_DRY=1 EXPORT_MODULOS=<mod> blender -b --factory-startup --python exportar_godot.py` y confirmar que el número sea `assets × 3 variantes`. Recién entonces correr con `EXPORT_FORZAR=1` (E-49) y terminar con el `--headless --import` de Godot.
- [ ] **Import verificado por ARCHIVOS, no por log** (E-64/E-65): por variante, `glb == import` (alta 66/66, media 66/66, baja 66/66) y el mtime del `.import` posterior al del `.glb`. El glob correcto es `*.import` (el sidecar es `<asset>.glb.import`, **no** `<asset>.import`). Los `ERROR:` de `voxel.gdextension` con el editor abierto son ruido benigno: **no** hay que cerrar el editor.
- [ ] **Variantes a la misma altura** (E-48 + E-62): el `z_min` de alta/media/baja tiene que coincidir. Si difiere, el objeto salta al cambiar de LOD o quedó enterrado. `chk_asset.py` lo reporta sin necesitar socket.
- [ ] **Aplicar transformadas ANTES de todo `join()`** (E-75): si el objeto activo tiene escala NO uniforme, cada pieza unida queda deformada en silencio por `active.matrix_world.inverted() @ obj.matrix_world`. Correr `bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)` sobre TODAS las piezas antes de `bpy.ops.object.join()`.
- [ ] **Limpieza de slots con `clear()`, no con `pop(update_data=)`** (E-76): en Blender 4.x `IDMaterials.pop()` ya no acepta `update_data` y tira `TypeError`. Para deduplicar materiales tras un join: leer `list(o.data.materials)`, deduplicar, `o.data.materials.clear()` y volver a hacer `append()`.
- [ ] **Torso humanoide NO se modela sólo con anillos** (E-81): un loft de elipses con `rx/ry > 1.5:1` da silueta LENS (extremos puntiagudos), no cap de hombro. Hay que **profundizar el pecho** (`ry ≥ 0.13` en los anillos del pecho), añadir **caps de deltoides como elipsoides separados** (ico sphere `subdiv=2`, radios `(0.084, 0.070, 0.052)`, **asimétricos en Z** para el hombro del lado que carga peso) **unidos al torso** después de `aplicar()`, y alargar el **trapecio a 8+ cm de pendiente** (no 5.5 cm).
- [ ] **Formato de anillo del loft: `(z, cx, cy, rx, ry)`, Z PRIMERO** (E-77): pasar `(x, y, z, ...)` deforma la malla sin tirar error. `plantilla_asset.loft()` ya tiene un assert que exige z no decreciente — si salta, es esto.
- [ ] **Suela plana cuando el apoyo es un loft elíptico** (E-78): el vértice más bajo de un anillo elíptico está en su CENTRO, así que el guard E-50 colapsa la huella a la línea media. Agregar una caja plana debajo que aporte 4 vértices de esquina. Regla de oro: **toda superficie que toca el piso necesita ≥4 vértices en sus esquinas, no 1 en el centro**.
- [ ] **Si el asset es MONTADO (sombrero, mochila, arma en mano)**: el `.blend` debe incluir un Empty llamado `_MONTADO` (E-80) y el script **no** debe llamar a `asentar()` (E-79). En su lugar, un **guard de encaje** propio: que no tape la cara, contenga el pelo, no flote, no sea una sombrilla, no atraviese orejas. La rotación se aplica a los VÉRTICES (con bmesh), no con `rotation_euler` del objeto.
- [ ] **Pivote del asset montado en el PUNTO DE MONTAJE** (E-79): el origen local del `.blend` es donde se cuelga del anfitrión (centro de la base de la copa para un sombrero, centro de la empuñadura para un arma, etc.). El GLB sale con el pivote listo para colgarse del hueso en Godot, sin más transformaciones.
- [ ] **Materiales con `use_backface_culling=False` para superficies visibles desde abajo** (E-79): un ala de sombrero es un loft sin tapas; sin doble lado, el ALA se vuelve invisible desde abajo. Costo: 0 tris, 0 mats extra. glTF `doubleSided: true` lo respeta.
- [ ] Hallazgos nuevos en §3 con fecha
- [ ] Log en `Logs/`
