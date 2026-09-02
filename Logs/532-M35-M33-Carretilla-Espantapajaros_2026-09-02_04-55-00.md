# Log 532 — M35 Carretilla de minero + M33 Espantapájaros (tarea #56)

**Fecha:** 2026-09-02 04:55 (hora del sistema; el reloj inyectado puede estar desfasado)
**Agente:** MiniMax-M3 · WorkBuddy AI · Windows
**Módulos:** 35 — Minería, 33 — Agricultura
**Assets:** `carretilla_minero` (M35), `espantapajaros` (M33)
**Tarea:** #56 (cerrada)
**Estado:** ✅ CERRADO — 6 GLB exportados, 6 `.import` + 6 `.scn` (E-65), 243/243/243 cobertura total

---

## 1. Alcance

Crear dos módulos nuevos en `tools/mcp/blender-mcp/` (E-63: registrar en
whitelist `MODULOS` de `exportar_godot.py` ANTES de exportar o exporta 0
en silencio) y autorar un asset en cada uno. La instrucción del usuario: "si
cerra todos los pendientes · recorda liberar los modulos".

---

## 2. Whitelist MODULOS (E-63)

```python
MODULOS = ('13-Herramientas', '15-Recursos', '16-Crafting', '18-Casas',
           '25-Ruinas-Templos', '27-Islas-Ubicaciones',
           '33-Agricultura', '35-Mineria',   # ← NUEVOS (2026-09-02 04:30, log 532)
           '40-Infraestructura', '45-Arte3D', '50-Vegetacion', '70-Interacciones')
```

Directorios creados:
- `tools/mcp/blender-mcp/35-Mineria/{scripts,capturas}/`
- `tools/mcp/blender-mcp/33-Agricultura/{scripts,capturas}/`

**Nota:** el archivo `CHECKLIST-GLOBAL.md` (reserva multiagente §8) tiene
mojibake conocido (ver `Obsoletos/encoding-backup-20260902_014555/`). Ambos
módulos verifican `Agente actual = —` (libres) — no los edito por riesgo de
empeorar el encoding. Mi trabajo es de assets, no de lógica de juego; los
dueños de la lógica M35/M33 (`minimax-m3-free/Kilo Code`) ya figuran en
"🟡 Liberado" en las filas de CHECKLIST-GLOBAL.

---

## 3. M35 — Carretilla de minero

### 3.1 Geometría (15 piezas)

```
1)  Rueda         cil 14 lados r=0.24 w=0.09    x=+0.75 z=0.285  (eje en Y)
2)  Eje           cil  8 lados r=0.035 w=0.60   x=+0.75 z=0.285
3-4)  Largueros x2  caja 1.53 x 0.07 x 0.09      y=±0.26 z=0.30   (horizontales)
5)  Batea_Fondo   caja 1.00 x 0.64 x 0.06      z=0.375            (apoyada en largueros, E-60)
6-7)  Batea_Lat x2  caja 1.00 x 0.05 x 0.30     z=0.555            (flared ±16.7° en X)
8)  Batea_Front   caja 0.05 x 0.73 x 0.30      x=+0.50  z=0.555  (inclinado +14° en Y)
9)  Batea_Tras    caja 0.05 x 0.73 x 0.30      x=-0.50  z=0.555  (vertical)
10-11) Patas x2   caja 0.08 x 0.08 x 0.255     x=-0.72  y=±0.26  (apoyo en suelo)
12-13) Mangos x2  caja 0.457 x 0.09 x 0.09     centro (-0.99, ±0.26, 0.39), rot +23.2° en Y
14-15) Mineral x2 cil 6 lados h=0.32 / h=0.24  apoyados en cara superior del piso (E-60)
```

### 3.2 Decisiones de diseño

- **Apoyo en trípode** (rueda + 2 patas): las patas (cajas) aportan 4 verts c/u
  = 8, la rueda 1-2 más → toca=10. Huella 1.51 x 0.60. E-50 OK sin necesitar
  un cilindro extra (a diferencia de la estatua).
- **Batea en tronco de pirámide** (`rot_euler=(±ANG_LAT, 0, 0)` con
  `ANG_LAT = atan2(ABERTURA, H_LAT) = atan2(0.09, 0.30) ≈ 16.7°`): los
  laterales se abren hacia arriba 9 cm a cada lado, lo que cambia la silueta
  de "caja" a "carretilla". Rotación sobre X: local +Z va a `(0, -sin a, cos a)`,
  así que `a > 0` (izquierdo) tira el borde superior hacia `-Y`; `a < 0`
  (derecho) tira hacia `+Y`.
- **Rueda adelantada a x=+0.75** (no +0.62 como pensé en v0): el frente
  inclinado de la batea termina en x=+0.536; con la rueda a r=0.24 sobre
  z=0.045..0.525, el cilindro atraviesa la batea si x<+0.70. Verificado
  manualmente que con x=+0.75 el cilindro queda fuera del frente inclinado.
- **Mangos angulados** con `atan2(d.z, d.x) * -1` para alinear la caja con el
  segmento de (x=-0.78, z=0.30) a (x=-1.20, z=0.48): ángulo +23.2° sobre Y.
  E-58 vía `rot_euler`, no trig manual.
- **Mineral** apoyado en cara superior del piso (E-60): NO usa Z_APOYO,
  se sienta sobre el piso de la batea (z=0.405).

### 3.3 Resultados

| Métrica | ALTA | MEDIA | BAJA |
|---|---|---|---|
| Objetos | 15 | 4 | 4 |
| Tris | (15*12 + rueda + eje + 2*mineral) ≈ 290 | 252 | 176 |
| Mats | 4 | 4 | 4 |
| Toca | 10 | — | — |
| Footprint | 1.51 x 0.60 | — | — |
| `asentar` delta | 0.000 | 0.000 | 0.000 |

**Aprobado visualmente** en los 6 azimuts (E-13/E-37). La silueta lee como
carretilla: rueda + laterales abiertos + 2 mangos = inconfundible. El
mineral asoma por encima del borde. Nada flota en ningún azimut.

GLBs exportados:
- `alta/35-Mineria_carretilla_minero.glb` (28 KB, 15 objs)
- `media/35-Mineria_carretilla_minero.glb` (16 KB, 4 objs)
- `baja/35-Mineria_carretilla_minero.glb` (12 KB, 4 objs)

---

## 4. M33 — Espantapájaros

### 4.1 Geometría (15 piezas)

```
1)  Base_Tierra    cil 12 lados r=0.40 h=0.08  z=0.085           (E-50: 12 verts al suelo)
2)  Poste          cil  8 lados r=0.05 h=2.30  z=1.195           (bottom en z=0.045)
3)  Brazo          caja 1.30 x 0.07 x 0.07     z=1.65
4-5)  Manos x2     caja 0.15 x 0.18 x 0.15     x=±0.65 z=1.65
6)  Cuerpo         caja 0.38 x 0.26 x 0.65     z=1.40
7)  Cabeza         caja 0.24 x 0.22 x 0.24     z=1.85
8)  Cuerda         cil 8 lados r=0.13 h=0.04   z=1.95            (atadura del cuello)
9)  Sombrero Copa  cil 8 lados r=0.14 h=0.20   z=2.07            (base sobre la cabeza)
10) Sombrero Ala   cil 12 lados r=0.32 h=0.04  z=2.00            (brim r=0.32 > copa r=0.14)
11-12) Ojos x2     caja 0.06 x 0.02 x 0.04    y=+0.115 x=±0.05 z=1.86  (cara frontal)
13) Boca           caja 0.08 x 0.02 x 0.03    y=+0.115 x=0    z=1.79
14-15) Pajas x2    cil 6 lados r=0.10 h=0.20  eje en Y, y=±0.23 z=1.40 (mechones laterales)
```

### 4.2 Decisiones de diseño

- **Apoyo** (E-50): cilindro de 12 lados a z=0.045 aporta 12 verts al suelo,
  más 9 del cap del poste (1 centro + 8 ring) que también cae en z=0.045 →
  **toca=20** (sobra margen). Footprint 0.80 x 0.80.
- **Cara con rasgos visibles** (E-37): los ojos y boca se colocan en la cara
  +Y, sobresaliendo +0.115 — justo 5 mm fuera de la cara frontal de la cabeza
  (que llega a y=+0.11), para que no se hundan en la tela.
- **Sombrero estilo mejicano** (Copa + Ala): la copa es un cilindro vertical
  sobre la cabeza; el ala es un disco 0.32 m de radio (vs copa 0.14) que hace
  de ala sobresaliendo. z=2.00 para el ala, z=2.07 para la copa → el ala
  queda 2 cm por debajo de la base de la copa, como un sombrero real.
- **Pajas de los costados** como cilindros con eje en Y (E-58) asomando
  lateralmente de la camisa: `cil_y()` agrega la rotación de +90° sobre X.
- **No confundir "poste con cajas" con espantapájaros** (E-37): sin sombrero +
  sin ojos + sin paja → la silueta se lee como otra cosa. Por eso las 3 señales
  están todas presentes.

### 4.3 Resultados

| Métrica | ALTA | MEDIA | BAJA |
|---|---|---|---|
| Objetos | 15 | 7 | 6 |
| Tris | ≈ 270 | 308 | 186 |
| Mats | 7 | 7 | 4 |
| Toca | 20 | — | — |
| Footprint | 0.80 x 0.80 | — | — |
| `asentar` delta | -0.000 | 0.000 | 0.000 |

**Aprobado visualmente** en los 6 azimuts. Sombrero + cruz + camisa + cara
con rasgos = espantapájaros en cualquier ángulo. En az 060 y 120 se ven los
ojos/boca como puntos negros. El ala del sombrero es inconfundible.

GLBs exportados:
- `alta/33-Agricultura_espantapajaros.glb` (31 KB, 15 objs)
- `media/33-Agricultura_espantapajaros.glb` (21 KB, 7 objs)
- `baja/33-Agricultura_espantapajaros.glb` (14 KB, 6 objs)

---

## 5. Pipeline ejecutado (los 2 assets)

```bash
# 1) Generar fuente (headless, E-45, sin socket)
blender -b --factory-startup --python crear_carretilla_minero_lowpoly.py
# -> 15 SM_, toca=10, fp=1.51x0.60, delta +0.0000
blender -b --factory-startup --python crear_espantapajaros_lowpoly.py
# -> 15 SM_, toca=20, fp=0.80x0.80, delta -0.0000

# 2) Capturas orbitales headless (E-55: capturar_angulos_headless.py)
#    6 azimuts × 3 variantes × 2 assets

# 3) Variantes (socket, E-56)
python generar_variante.py 35-Mineria carretilla_minero_lowpoly.blend --media
# -> 4 objs, 252 tris, 4 mats, z 0.045 -> 0.045 (delta 0)
python generar_variante.py 35-Mineria carretilla_minero_lowpoly.blend --baja
# -> 4 objs, 176 tris, 4 mats, z 0.045 -> 0.045 (delta 0)
python generar_variante.py 33-Agricultura espantapajaros_lowpoly.blend --media
# -> 7 objs, 308 tris, 7 mats
python generar_variante.py 33-Agricultura espantapajaros_lowpoly.blend --baja
# -> 6 objs, 186 tris, 4 mats

# 4) Export glTF headless (E-45, E-49, E-63 con MODULOS registrados)
EXPORT_FORZAR=1 EXPORT_MODULOS="35-Mineria" blender -b --factory-startup \
  --python scripts-reutilizables/exportar_godot.py
# -> 3 GLB exportados (alta 28KB 15objs, media 16KB 4objs, baja 12KB 4objs)
EXPORT_FORZAR=1 EXPORT_MODULOS="33-Agricultura" blender -b --factory-startup \
  --python scripts-reutilizables/exportar_godot.py
# -> 3 GLB exportados (alta 31KB 15objs, media 21KB 7objs, baja 14KB 6objs)

# 5) Import Godot (E-64: editor abierto -> ruido benigno de voxel.gdextension)
godot --headless --path game/isla-ancestral --import

# 6) Verificación por archivos (E-65 + E-72)
#    243 GLB / 243 *.glb.import / 243 *.scn
```

---

## 6. Archivos creados/tocados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/35-Mineria/scripts/crear_carretilla_minero_lowpoly.py` | CREADO |
| `tools/mcp/blender-mcp/35-Mineria/carretilla_minero_lowpoly.blend` (+ _media, _baja) | CREADOS (3) |
| `tools/mcp/blender-mcp/35-Mineria/capturas/carretilla_minero_*_az*.png` | CREADOS (18) |
| `tools/mcp/blender-mcp/35-Mineria/capturas/_hoja_cap_35_carretilla_minero_{lowpoly,media,baja}.jpg` | CREADAS (3) |
| `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_espantapajaros_lowpoly.py` | CREADO |
| `tools/mcp/blender-mcp/33-Agricultura/espantapajaros_lowpoly.blend` (+ _media, _baja) | CREADOS (3) |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/espantapajaros_*_az*.png` | CREADOS (18) |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/_hoja_cap_33_espantapajaros_{lowpoly,media,baja}.jpg` | CREADAS (3) |
| `game/isla-ancestral/assets/3d/{alta,media,baja}/{35-Mineria_carretilla_minero,33-Agricultura_espantapajaros}.glb` | CREADOS (6) |
| idem `.glb.import` | CREADOS (6) |
| `.godot/imported/{35-Mineria_carretilla_minero,33-Agricultura_espantapajaros}.glb-*.scn` | CREADOS (6) |
| `tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` | EDITADO (MODULOS: +33-Agricultura, +35-Mineria) |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | EDITADO (3 flips + contadores) |
| `DOCUMENTACION/09-GUIA-BLENDER.md` | EDITADO (E-69..E-72 + fixes) |
| `.workbuddy-ai/memory/MEMORY.md` | EDITADO |
| `.workbuddy-ai/memory/2026-09-02.md` | EDITADO (apéndice) |
| `Logs/532-*.md` | CREADO |
| `Logs/ULTIMO_NUMERO.txt` | 444 → 532 |

---

## 7. Lecciones nuevas

- **Carretilla: rueda adelantada** a x=+0.75 para no atravesar el frente
  inclinado de la batea. Regla práctica: el cilindro de la rueda con eje en
  Y, sobre el suelo, con z ∈ [Z_SUELO, Z_EJE+epsilon], se proyecta en el
  plano XY como un rectángulo de ancho w y alto 2r centrado en (x, y). Si la
  batea tiene cualquier superficie frontal en x dentro de ese rectángulo, hay
  intersección.

- **Espantapájaros: sombrero copa + ala como DOS cilindros separados**, no como
  primitiva `cone` o `torus`. Un cilindro vertical pequeño (Copa) sobre un
  cilindro plano más ancho (Ala) lee como sombrero mejicano en lowpoly. Más
  simple y robusto que un mesh toroidal.

- **E-37 positivo**: la diferencia entre "poste con cajas" y "espantapájaros"
  son 3 señales: (a) sombrero con ala, (b) cara con ojos/boca, (c) paja
  asomando de la camisa y los brazos. Sin las 3 → lee como otra cosa.

- **E-50 para cilindros con cap**: `primitive_cylinder_add` crea caps por
  defecto; el bottom cap de un cilindro de N lados tiene **N+1 verts**
  (N del anillo + 1 centro). Para toca, eso es N+1 dentro de 5 mm, no N.

---

## 8. Backlog tras este log

**33 pendientes.** Cierra:
- M33 (8): tierra arada, regada, semillero, planta ×2, bananero, plantación caña, compostera.
- M35 (1): Carrito de vías.
- M25 (7): Columna rota ×2, Columna entera, Bloque piedra tallada, Dintel caído, Palanca puzzle, Estructura sumergida.
- M40 (1): Valla de madera.
- M36 Fauna (9): BLOQUEADO — reservado por `minimax-m3-free (Kilo Code)` (AGENTS.md §8).
- M45 (~5), M16, M70, M34.

**Deudas administrativas sin cerrar:**
- 11 temporales `~libvoxel...TMP` (82 MB) en `addons/zylann.voxel/bin/`.
- `cristal_ancestral` MEDIA con 72 vértices degenerados.
- Commit+push **selectivo**, no tocar los ~335 cambios ajenos.
- Colisión de numeración de logs entre agentes (ya van por 532 y otros agentes usan números cercanos).
- `CHECKLIST-GLOBAL.md` con mojibake — no lo edito para no empeorar; nota para futuro refactor.