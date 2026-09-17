# Log 761 — M33 Agricultura · Sub-pista 3D · Cultivos (4 etapas)

**Agente:** WorkBuddy (Hy4)
**Fecha:** 2026-09-07
**Módulo:** 33-Agricultura — **sub-pista 3D** (autoría de assets en Blender MCP)
**Reserva:** `Logs/reservas/761-workbuddy-M33-3D-Agricultura.txt`

> Aclaración de convivencia: el módulo 33 está reclamado por **agnes-2.5-flash**
> para trabajo de CÓDIGO. Esta reserva es la sub-pista **3D**, que es
> ortogonal: no toca `.gd`, ni datos, ni documentación de diseño del módulo.
> Es el mismo patrón ya usado en los logs 678 (M19), 679 y 730 (M16).

---

## 1. Contexto y motivo

Con M16 cerrado al 100 % (7/7, log 730) el backlog 3D quedó así:

| Módulo | Pendientes 3D | Agente de código |
|---|---|---|
| M33 Agricultura | 9 | agnes-2.5-flash |
| M18-BIS Casas grandes | 5 | glm-5.3-free |
| M25/24/26 Ruinas-Templos | 6 | agnes-2.5-flash |
| M36 Fauna | 5 | **reservado por otro modelo — NO TOCAR** |
| M34/35 Pesca-Minería | 4 | GLM-5.3 Flash |
| M40 Infraestructura | 1 | agnes-2.5-flash |

Elegí **M33** porque es el lote más grande, el más visible en gameplay (es la
cara del sistema de cultivo) y el que mejor ejercita las técnicas nuevas:
incluye la **regadera**, que es pieza hueca (E-92), y las **etapas de
crecimiento**, que exigen coherencia de silueta entre sí.

---

## 2. Hallazgo de diseño: el backlog 3D tenía UNA etapa menos que el diseño

`DOCUMENTACION/33-Agricultura/plan-actual/03-Diseno.md` §2.4.5 define el enum
`EtapaCultivo` con **CINCO** valores:

```
SEMILLA → Brote → CRECIENDO → MADURA → LISTA
           1        2          3        4      (0 = SEMILLA)
```

Pero el backlog 3D (`CHECKLIST-OBJETOS-BLENDER.md` §M33) listaba **tres**
assets: "Semillero brotando (etapa 1)", "Planta creciendo (etapa 2)" y
"Planta madura cosechable (etapa 3)".

Resolución:

- **SEMILLA (0)** no necesita mesh de planta: es la semilla recién puesta, así
  que la cubre el tile `Tierra arada`. → 4 assets, no 5.
- **Brote (1)** → `cultivo_brote`
- **CRECIENDO (2)** → `cultivo_creciendo`
- **MADURA (3)** = *"madurando, falta 1 día"* → `cultivo_madura`, fruto
  **verde y chico**. Este asset **faltaba en el backlog** y lo agregué.
- **LISTA (4)** = cosechable → `cultivo_lista`, fruto **rojo y lleno**. Es la
  que el backlog llamaba "madura cosechable (etapa 3)".

MADURA y LISTA comparten silueta a propósito: se distinguen por el color y el
tamaño del fruto, que es exactamente la diferencia semántica del enum
("te falta 1 día" vs "ya podés cosechar").

---

## 3. Entregables

| Asset | Etapa | SM_ | Tris | Mats | MEDIA | BAJA | z_min | toca | Huella |
|---|---|---|---|---|---|---|---|---|---|
| `cultivo_brote` | 1 Brote | 4 | 152 | 3 | 3/152/3 | 3/102/3 | 0.0450 | 13 | 0.28×0.28 |
| `cultivo_creciendo` | 2 CRECIENDO | 6 | 208 | 3 | 3/208/3 | 3/142/3 | 0.0450 | 13 | 0.28×0.28 |
| `cultivo_madura` | 3 MADURA | 10 | 360 | 4 | 4/360/4 | 3/180/3 | 0.0450 | 13 | 0.28×0.28 |
| `cultivo_lista` | 4 LISTA | 11 | 408 | 4 | 4/408/4 | 4/280/4 | 0.0450 | 13 | 0.28×0.28 |

- **12 `.blend`** (4 assets × ALTA/MEDIA/BAJA) en
  `tools/mcp/blender-mcp/33-Agricultura/`.
- **72 capturas orbitales** (4 × 3 × 6 azimuts) + **12 hojas de contacto**.
- **15 GLB** exportados (12 nuevos + 3 de `espantapajaros` re-exportados por
  `EXPORT_FORZAR=1`), con sidecar `.glb.import` verificado **12/12 por conteo**.

Todos dentro del presupuesto M166 §3.3 (ALTA ≤16/≤6000/≤12 · MEDIA
≤8/≤1500/≤8 · BAJA ≤6/≤700/≤4). El más pesado es `cultivo_lista` ALTA con
11/408/4, o sea al 7 % del techo de triángulos.

---

## 4. Decisiones de diseño

### 4.1 Un solo script parametrizado, no cuatro

`crear_cultivo_etapa_lowpoly.py` recibe la etapa por argumento
(`blender -b --python script.py -- 3`). Las 4 etapas comparten ~95 % del
código; tenerlas en un solo script garantiza que usen la misma paleta, el
mismo lenguaje de formas y las mismas fórmulas de reparto de hojas. Si fueran
4 scripts, divergirían en la primera edición.

### 4.2 El montículo de tierra no es decoración: es el apoyo

Una planta no puede apoyar sobre el tallo: un tallo de r=0.02 daría
`max(fp) ≈ 0.02` y el guard de E-91 (`max(fp) ≥ 0.45 · largo`) saltaría. Cada
planta nace de un **montículo** (cono truncado cerrado, r=0.14, h=0.045) que
aporta 12 vértices en el suelo y huella 0.28×0.28. Además de cumplir el guard,
es lo correcto: un cultivo se planta en un pequeño montículo de tierra suelta.

### 4.3 Reparto de hojas

- Inserción entre el 30 % y el 95 % de la altura del tallo. **Arranca en 0.30
  y no en 0.22**: la hoja más baja debe nacer por encima del borde superior
  del montículo (z=0.045) o su vértice pasa a ser el `z_min` de la escena y
  `asentar` levanta TODA la planta para apoyar esa punta, dejando el montículo
  flotando.
- Azimut por **ángulo áureo** (2.39996 rad): es el reparto de las plantas
  reales para que ninguna hoja tape a la de arriba; de paso evita el aspecto
  de hélice de un reparto simétrico.
- Inclinación 18° → 48° según la altura (abajo casi horizontales, arriba
  erguidas): es lo que produce la silueta de "mata" y no de "plancha".
- `roll` ±22°: giro de cada hoja sobre su nervio para que no parezcan cortadas
  por la misma matriz.

### 4.4 Frutos

Perfil de revolución cerrado en el eje (5 puntos), `lados=8`, 48 tris:
panza a la mitad y hombros redondeados, tipo baya. Se colocan a 4.8 cm del eje
del tallo para que el fruto (r=0.031) solape el tallo (r≈0.018) y se lea como
"colgando de la planta" y no como "esfera flotando al lado".

---

## 5. E-93 (NUEVA) — El volumen firmado sólo vale en caras PLANAS

**El bug.** La primera versión de la hoja tenía pandeo
(`z = L·(sin(incl)·t − droop·t²)`, `droop = 0.95`) y un pliegue en V para
levantar los bordes. Se construía como prisma: tapa + contratapa desplazadas
±h a lo largo de la **normal media** (Newell) + faldón. El volumen firmado
daba **negativo** → "normales hacia adentro".

**Diagnóstico.** Descompuse el sólido en *tapas* y *faldón* y lo comparé con un
cubo de control construido por el mismo algoritmo:

```
cubo de control  →  +4.0000   (el volumen exacto de un cubo 2×2×1)  ✔
hoja L=0.086     →  caps −6.6e-06  rim +1.2e-05  TOTAL +5.6e-06
hoja L=0.205     →  caps −7.5e-05  rim +6.8e-05  TOTAL −7.7e-06   ✘
hoja L=0.205 con grosor 0.030 → caps +6.0e-05                     ✔
```

Que el cubo dé +4.0 demuestra que el **algoritmo** está bien. Y que las tapas
no escalen linealmente con el espesor demuestra que el número que dan no
significa nada: **son caras alabeadas y el volumen se triangula en abanico**,
que sólo es una descomposición válida en caras planas y convexas.

Había además un problema geométrico real: con `droop = 0.95` la punta caía
4.3 cm por debajo del punto de inserción en una hoja de 8.6 cm — se clavaba en
el suelo — y la hoja se curvaba más de 90°, así que el prisma se
auto-intersectaba.

**El fix.** Hoja **plana**. Pandeo y planaridad son mutuamente excluyentes: una
hoja plana sólo puede curvarse DENTRO de su plano, y curvarse dentro del plano
es desviarse de costado, no caer. Se descartan pandeo y pliegue en V; la
variedad la dan `incl`, el ángulo áureo y `roll` (§4.3), que no rompen la
planaridad.

**La verificación.** Desviación de planitud del contorno respecto de su normal
media:

```python
n = newell(contorno); c = centroide(contorno)
desv = max(abs(dot(p - c, n)) for p in contorno)   # plano -> ~1e-17
```

En las 18 hojas de los 4 cultivos dio entre **3.8e-18 y 6.5e-17**, y los 18
volúmenes firmados salieron positivos (el peor, +1.66e-05).

**Lección transferible:** antes de culpar a la forma, construí un cubo con el
mismo algoritmo. Si el cubo da negativo, el bug es del algoritmo; si da +4.0 y
tu pieza da negativo, el problema es la forma.

Documentado en `DOCUMENTACION/09-GUIA-BLENDER.md` §3 (E-93) y §4.

---

## 6. E-94 (NUEVA) — `matrix_world` queda viejo sin `view_layer.update()`

El guard "el montículo debe ser la pieza más baja de la escena" (para que
`asentar` no levante la planta apoyándola en una punta de hoja) fallaba:

```
AssertionError: el montículo NO es lo más bajo (0.0000) —
lo es SM_Cultivo_Fruto_0 (-0.0170)
```

Un fruto colocado en z = 0.194 medido en −0.017 es imposible. La causa: los
frutos se colocan con `o.location = ...`, y `zmin_real()` hace
`(o.matrix_world @ v.co).z`, pero **`matrix_world` no se recalcula solo**. Como
el guard corría antes de `cerrar_herramienta()` (que sí llama a
`view_layer.update()`), los objetos recién movidos se medían como si estuvieran
en el origen.

Fix: `bpy.context.view_layer.update()` antes de medir. Regla general: **toda
medición en coordenadas de mundo necesita un `update()` previo si hubo
movimientos.** Documentado en la guía §3 (E-94) y §4.

---

## 7. Mejora de pipeline: variantes sin GUI

`generar_variante.py` es un cliente del socket MCP (E-56). Con Blender cerrado
(que era el caso: el socket 9876 estaba caído y sólo había procesos
`blender-mcp.exe`, no `blender.exe`) no hay forma de generar MEDIA/BAJA sin
abrir la GUI a mano.

Pero el merge por material y el decimate son operaciones 100 % de `bpy`. Creé
**`generar_variante_headless.py`**, que importa `generar_variante` y reemplaza
su única llamada de red (`blender_command`, línea 493) por un `exec` local del
mismo string de código. Es decir: se ejecuta **exactamente el mismo payload**
que ejecutaría el addon, sin red. No hay lógica duplicada que mantener.

```
blender -b --factory-startup --python generar_variante_headless.py -- \
    33-Agricultura cultivo_brote_lowpoly --media --baja
```

Resultado idéntico al de la vía MCP (mismas cuentas de objetos/triángulos/
materiales). Documentado en la guía §4.

---

## 8. Verificaciones

| # | Control | Resultado |
|---|---|---|
| 1 | E-13 — 6 azimuts por variante | 72 PNG + 12 hojas de contacto ✔ |
| 2 | E-12/E-24 — apoyo sobre vértices reales | z_min 0.0450 en las 12, δ ≈ 0.000 ✔ |
| 3 | E-91 — `asentar_herramienta` | toca=13, huella 0.28×0.28 en las 12 ✔ |
| 4 | E-93 — planaridad + volumen firmado | 18/18 hojas > 0, desv ≤ 6.5e-17 ✔ |
| 5 | E-94 — montículo es lo más bajo | pasa en las 4 etapas ✔ |
| 6 | E-63 — `EXPORT_DRY=1` | 12 planeados, 0 errores ✔ |
| 7 | E-49 — `EXPORT_FORZAR=1` | 15 GLB exportados, 0 errores ✔ |
| 8 | E-65/E-72 — sidecar `.glb.import` → `.scn` | **12/12 por conteo** ✔ |
| 9 | E-70 — tope de 16 SM_ en ALTA | máximo 11 (`cultivo_lista`) ✔ |
| 10 | M166 §3.3 — presupuesto | 12/12 variantes dentro ✔ |

**QA visual:** leí 2 de las 4 hojas de contacto de ALTA (`cultivo_lista` y
`cultivo_creciendo`) y se ven correctas: planta reconocible, apoyada sobre el
montículo, lectura consistente desde los 6 azimuts, frutos legibles y
progresión de silueta clara entre etapas. Como siempre, dejo constancia de que
mi lectura de imágenes es intermitente (§15.3 de
`10-GUIA-COMPARATIVA-MODELOS.md`), así que la aprobación visual final conviene
que pase por GLM 5.3 Flash / Qwen 3.8 VL o por el usuario.

---

## 9. Archivos tocados

**Nuevos**
- `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_cultivo_etapa_lowpoly.py`
- `tools/mcp/blender-mcp/scripts-reutilizables/generar_variante_headless.py`
- 12 `.blend` en `tools/mcp/blender-mcp/33-Agricultura/`
- 72 PNG + 12 JPG en `tools/mcp/blender-mcp/33-Agricultura/capturas/`
- 12 GLB en `game/isla-ancestral/assets/3d/{alta,media,baja}/`

**Modificados**
- `DOCUMENTACION/09-GUIA-BLENDER.md` — E-93 y E-94 nuevas (§3) + 3 bullets (§4)
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` — 4 items M33 ✔ (3 del
  backlog + el de MADURA que faltaba); contadores 102→106 completados,
  46→42 pendientes
- `CHECKLIST-GLOBAL.md` — fila 33, alta de la sub-pista 3D

---

## 10. Deudas y siguientes pasos

1. **Seguir el backlog 3D de M33** (5): bananero, plantación de caña,
   compostera, regadera, y los tiles `Tierra arada` / `Tierra regada`.
   La **regadera** es la siguiente natural: es pieza hueca con pico y asa, y
   validaría `revolucion()` (E-92) por segunda vez.
2. **Los tiles de tierra arada/regada son un caso especial de E-12**: son
   parches de 1×1 m que deben quedar al ras del suelo, no a `Z_APOYO=0.045`.
   Hay que definir (y documentar) la altura correcta para no tener z-fighting
   con el terreno.
3. **Integración Godot:** el diseño prevé un `MultiMeshInstance3D` por especie
   y por etapa. Los 4 meshes ya están exportados; falta que M33 los consuma.
4. No toqué nada de código Godot (reserva de agnes-2.5-flash).

---

## 11. Liberación y firma

**Sub-pista 3D del módulo 33 liberada.** Se elimina
`Logs/reservas/761-workbuddy-M33-3D-Agricultura.txt`.

**Firmado:** WorkBuddy (Hy4) · 2026-09-07 · Log 761
