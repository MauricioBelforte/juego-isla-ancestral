# Hy4 — Acta de cierre PARCIAL T-02: Carreta Ancestral (M157 / T04)

**Fecha:** 2026-11-06 02:36:14 -0300
**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Origen:** `07-Backlog-Tanda-Blender.md`, T-02 (directora agnes-3-flash #04 / #05; acuse #22)
**Reporte al canal:** mensaje **23** (acuse de #22) · **Log:** 2332
**Estado:** **PARCIAL**. `07` L18 y L19 ejecutados; **L20 bloqueado sin GO**. Las 3 marcas siguen `[ ]`.

> Precedente: D-01 (`12-…`), T-01a (`13-…`), T-01b (`14-…`), T-01c (`15-…`)
> y T-01d (`16-…`) se documentaron en actas propias sin tocar el `07`.
> **T-01 quedó 4/4 ejecutado.** Esta es la primera acta de la tanda que cierra
> **en forma parcial**: se documenta explícitamente lo que NO se hizo y por qué.

## 1. Alcance: tres fuentes en conflicto, resuelto por medición

| fuente | dice | medición |
|---|---|---|
| `07` L17-L21 | 1 asset M157 + GLB/`.glb.import` + integración en escena; referencia `DOCUMENTACION/157-Transporte/` | la ruta **no existe**; la real es `DOCUMENTACION/157-Medios-De-Transporte/`, con 5 archivos en `plan-actual/` |
| directora #04 | «Assets 3D de transporte ausentes en disco (**los 5 de la designación P1**)» | el informe P1 de Nemotron (`164-…-p1-m157.md`) habla de **5 artefactos M85** `model_legal`/`credit`/`build_script` + HUD/JourneyPanel, **no** de 5 assets 3D |
| M157 `01-Requerimientos.md` RF-04 / `03-Diseno.md` | 5 tipos: T01 Barco, T02 Tren, T03 Avión, T04 Carreta, T05 A pie | `game/isla-ancestral/data/vehiculos/vehicles.json` (M67) ya tiene 4 ids: `barco`, `dirigible`, `submarino`, `locomotora`. **El único tipo sin asset 3D es la Carreta T04** |

`05-Checklist.md` L26 fija la **condición de arranque**:

> «requiere **GO del fundador** + visión M154 (assets 3D) + owner de gameplay. Sin GO, la implementación no debe empezar (§15: no se toca código de otros dueños)».

Y C-15 («Escenas 3D representativas de cada transporte») tiene dueño de
gameplay. `04-Codigo.md` además advierte que los 23 scripts de M157 van en
`scripts/transporte_medios/`, **no** en `scripts/transporte/` (M68, 16 archivos
reales).

**Decisión adoptada:** T-02 se ejecuta **solo como asset Blender**, que es el
nicho de Hy4 según #04 («TODO lo referido a Blender») y #05. Se entrega **1
asset — Carreta T04 — con 3 LOD**. No se tocó runtime, escenas, `terrain
locator`, `TransportManager`, `scripts/transporte_medios/` ni ningún script de
M157. Queda pendiente y **bloqueada** la integración del `07` L20.

## 2. Búsqueda Poly Haven (medida antes de generar)

Catálogo completo por API: **521 modelos**, **0** carretas utilizables, **18**
falsos positivos por keyword. Trampa nueva de substring: `ox` dentro de
`*_box`, que se suma a las ya medidas en la tanda (`rail` → `trail`,
`cart` → muebles industriales de 18 902–29 418 polis). Se usa la alternativa
**custom lowpoly** que habilita el `07`.

## 3. Artefactos entregados

| variante | GLB | bytes | sha256 (12) |
|---|---|---:|---|
| ALTA | `game/isla-ancestral/assets/3d/alta/157-Medios-De-Transporte_carreta_ancestral.glb` | 44 448 | `2deda8c23193` |
| MEDIA | `game/isla-ancestral/assets/3d/media/157-Medios-De-Transporte_carreta_ancestral.glb` | 40 364 | `82088d05bb4f` |
| BAJA | `game/isla-ancestral/assets/3d/baja/157-Medios-De-Transporte_carreta_ancestral.glb` | 30 940 | `cf0e58efdb37` |

- Generador: `tools/mcp/blender-mcp/157-Medios-De-Transporte/scripts/crear_carreta_ancestral_lowpoly.py` (21 059 B).
- 3 `.blend` ALTA/MEDIA/BAJA, 18 PNG orbitales y 3 hojas de contacto (locales, ignorados).
- 3 `.glb.import` generados por `godot472.exe --headless --path game/isla-ancestral --import`, con uid `uid://d4ds7i0rcabrj`, `uid://co7saur4h3b4f`, `uid://b7ixy5e8w73ru`. **Locales y sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`, y `git ls-files` devuelve **0** `.glb.import` en todo el repo (convención medida, no supuesta).
- `exportar_godot.py`: se agregó `'157-Medios-De-Transporte'` al final de `MODULOS` (E-63). Sin esa entrada un módulo nuevo exporta **0 GLB en silencio**. Diff medido: 1 entrada + 3 líneas de comentario, ningún otro cambio.

## 4. Evidencia POSITIVA (re-medida en esta vuelta)

`chk_asset.py` sobre los 3 `.blend`, **cada uno contra su propio perfil M166**.
Que en ALTA se imprima `NO MEDIA` / `NO BAJA` es esperado: un ALTA de 11
objetos no puede cumplir el techo de 8/6 objetos de los otros perfiles.

| perfil | objetos | tris reales | mats | z_min | veredicto |
|---|---:|---:|---:|---:|---|
| ALTA | 11/16 | 792/6000 | 4/12 | 0.0450 | **OK** |
| MEDIA | 4/8 | 704/1500 | 4/8 | 0.0450 | **OK** |
| BAJA | 4/6 | 491/700 | 4/4 | 0.0450 | **OK** |

Materiales usados por caras: `MAT_Carreta_Madera`, `MAT_Carreta_Lona`,
`MAT_Carreta_Verde`, `MAT_Carreta_Hierro` (4 en los 3 LOD).

Cotas `.blend` y GLB: `X [-1.110..1.110]` = **2.220 m**, `Y(blend)
[-1.900..2.300]` = **4.200 m**, `Z [0.045..2.430]` = **2.385 m**.

GLB verificados por **decodificación de vértices reales del BIN** (magic `glTF`
v2, chunks JSON+BIN, jerarquía de nodos, matrices **column-major**
`M[c*4+r]` con traslación en `M[12..14]`, `byteStride` real):

| var | nodos/mallas | vértices | y_min | y_max | ancho X | largo Z | mats |
|---|---:|---:|---:|---:|---:|---:|---:|
| ALTA | 11/11 | 1328 | 0.0450 | 2.4300 | 2.220 | 4.200 | 4/4 |
| MEDIA | 4/4 | 1328 | 0.0450 | 2.4300 | 2.220 | 4.200 | 4/4 |
| BAJA | 4/4 | 991 | 0.0450 | 2.4300 | 2.220 | 4.200 | 4/4 |

En los 3: **0** nodos `Base_Arena`/`SOL`/`CAM_`, **todos** los nodos `SM_`.
Piezas ALTA: `Bastidor`, `Tablones`, `Lona`, `Aros`, `Ruedas`, `Eje`, `Cubos`,
`Limones`, `Carga`, `Farol`, `Herrajes`. MEDIA/BAJA: 4 grupos por material
(`SM_Carreta_M_*`), identidad de color conservada.

Export real **3/0/0**. Dry-run global re-ejecutado en esta vuelta: **6
planeados / 430 saltados / 0 errores**. Los 3 GLB de la carreta entran en
`saltados` por `up-to-date` (mtime GLB `02:25:18` ≥ mtime `.blend` `02:23:24`,
medido en los 3) → prueba positiva de que el export quedó completo. Los
**12 GLB de T-01 (a/b/c/d) quedaron byte-idénticos a HEAD**: re-medido por
hash de blob git, **12/12**, 0 distintos.

Capturas: 6 azimuts por variante (**18 PNG**) y 3 hojas de contacto con
sha256 distintos (`b7fc595d…`, `3b54175f…`, `d0f3da7e…`). Revisión visual
**de autoría** con ampliación de az000 / az060 / az120: plataforma, lona y
aros, 2 ruedas octogonales, limones, carga y farol colgado bajo la lona;
**postes de suspensión visibles uniendo eje y viga**; sin piezas desprendidas.

## 5. Decisiones de autoría

1. **4 materiales exactos** → `--max-mats 4` de BAJA es un **no-op** y el merge produce 4 objetos. Reutiliza la corrección de T-01c/d. No se tocó `generar_variante.py`.
2. **Apoyo por 2 RUEDAS**, no patines. Octógonos con arista inferior plana, `Z_RUEDA = 0.045 + cos(π/8)·0.62`. `z_min = 0.0450` sobre vértices reales en los 3 `.blend` y los 3 GLB.
3. **Normales explícitas hacia afuera** en la lona: winding `(a,d,c,b)`, `normal_ref='explicito'`, guard de producto punto radial sobre 32 caras; sin `recalc_face_normals()` sobre tiras abiertas.
4. **Guardias de unión positivas**: holgura de aros por estación (`RADIOS_ARO`), suspensión eje→viga, penetración del eje en las ruedas, cubos, apoyo de la carga, farol colgado, limones y cotas `4.20 × 2.22 × 2.385`.
5. **4.20 m de largo** (`Y_POPA=-1.90`, `Y_PROA=2.30`), plataforma de 3.00 m, lona de 5 estaciones con radios `0.94/1.00/1.00/1.00/0.94 × 0.88`.

## 6. Defectos reales encontrados y corregidos

**6.1 Defecto de autoría — caja flotante.** El primer intento ponía un
«montante de eje» en `Z_RUEDA-0.24`, es decir **debajo** del eje y sin tocar la
plataforma: la caja flotaba sobre las ruedas. Corregido con 2 postes
verticales que van del eje (`z≈0.618`) a las vigas longitudinales (`z≈0.95`),
más un guard que exige **≥8 vértices a la altura del eje** y vértices por
encima de `0.90`. Es la misma familia de la trampa de «pieza no portante»:
`z_min ≥ Z_APOYO` no prueba que una pieza esté unida a la que la sostiene.

La cronología de mtimes es **monótona** y prueba que capturas y GLB son
posteriores al fix (no muestran la versión defectuosa):

```text
02:23:15  generador (última edición)
02:23:24  .blend ALTA / 02:23:25 MEDIA y BAJA
02:23:48  capturas PNG
02:24:15  hojas de contacto
02:25:18  3 GLB
02:26:20  3 .glb.import (Godot headless)
```

**6.2 Defecto de MEDICIÓN propio — matriz identidad mal construida.** El
decodificador inline usado para verificar los GLB tenía `ident()` con **20
floats** (una columna de corrimiento), no la identidad de 16. Publicó ejes
**permutados** — `y[-2.30..1.90]`, `x=2.385`, `z=0.0` — **sin lanzar ningún
error ni excepción**: un falso verde de medición. Corregida la identidad
column-major, las 3 variantes coincidieron exactamente con `chk_asset.py`
(`y_min=0.0450`, `x=2.220`, `z=4.200`). Trampa nueva candidata: *«una matriz
identidad mal construida produce cotas falsas sin crash; la comprobación no es
que el script termine, sino que el resultado coincida con una medición
independiente»*. Propuesto su registro en `TRAMPAS-MEDICION.md` con GO de la
directora; **el catálogo no se tocó**.

**6.3 Falso verde de Blender evitado.** Blender 4.2 devuelve `RC=0` incluso
cuando el script Python levanta `AssertionError`; se exigieron marcadores de
stdout, existencia positiva de los 3 GLB y `py_compile` previo del generador.

## 7. Formatos y límites

Mensaje 23 y esta acta: **UTF-8 sin BOM + LF**. Log 2332: **ASCII puro +
CRLF**, 9 841 B, 0 bytes > 127, 164 CRLF, 0 LF sueltos, sin BOM. Generador:
21 059 B, LF, sin BOM, sin `U+FFFD`, `py_compile` RC=0. Gate §28
`verificar_bom.py`: **RC=0**, con 6 avisos de `U+FEFF` embebido ajenos y no
bloqueantes.

Límites: revisión visual **de autoría**, no QA §21.8, no sello, no aprobación
visual final, no auto-QA. Sin push, sin `--amend`, sin `git add -A`. Sin tocar
`07`, `CHECKLIST-GLOBAL.md`, `quality.yml`, `project.godot`,
`generar_variante.py`, `plantilla_asset.py` ni `dump_glb.py`. `.blend`,
`.blend1`, PNG/JPG y `__pycache__` quedan locales por `.gitignore`
L84/L104/L228.

## 8. Lo que NO se hizo (bloqueado)

- `07` L20: **integración en escena**, `terrain locator`, `z_min=0.045` en runtime. Requiere GO del fundador + visión M154 + owner de gameplay (`05-Checklist.md` L26) y toca código de otros dueños (§15).
- Los otros 4 tipos de M157 y los 5 artefactos P1 de M85: **sin definición de alcance** (#04 dice «los 5», `07` dice 1). No se inventaron tareas.
- Flips de marcas en `07`: **ninguno aplicado**; el backlog lo escribió la directora.
- `dump_glb.py` sigue con el defecto de convención de matrices detectado en el acta 16. Fix de 2 líneas propuesto, sin GO.

## 9. Propuestas y deuda detectada

- Flip **solo** de `07` L18/L19 con cita a mensaje 23 + log 2332; **L20 queda `[ ]`**.
- Pedir definición de alcance y prioridad del siguiente `[ ]`: **T-03 HUD** o **T-04 B-15-02** (#05: «si no sabés qué hacer → reportalo, no lo inventes»).
- **Hueco nuevo medido (nicho Blender)**: el dry-run global planea **6 exportaciones** de `25-Ruinas-Templos/columna_rota_alta|baja` × alta/media/baja; hay **6 `.blend` en disco y 0 GLB** en `game/isla-ancestral/assets/3d/`. La autoría M25 ya estaba cerrada, pero el export a Godot no. Pido GO para exportarlos.
- Reiterar peticiones del mensaje 22: flips T-01a/b/c/d, T-01a-bis, fix de `dump_glb.py`, `07` L33 obsoleto (P-01 ya en `d806c45`).
- **Colisión de numeración 22** en el canal HY4 (reporte Hy4 + acuse de la directora). Mensaje nuevo = `max(real)+1 = 23`. Pool del canal roto: cabeza 5, máximo real 22 → reportado, no tocado.
- Pool de logs: 2332 → 2333 tras la reserva. Relojes desincronizados: #22 dice 04:30, local 02:36:14.
- `07` L21 cita `DOCUMENTACION/157-Transporte/` (inexistente) y `template_asset.py` (el helper real es `plantilla_asset.py`). No se corrige: backlog ajeno.
- **Aviso de discrepancia nº 40**: directora vigente `agnes-3-flash`; el prompt de la automatización dice `GLM-5.3-Flash`.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-06 02:36:14 -0300
