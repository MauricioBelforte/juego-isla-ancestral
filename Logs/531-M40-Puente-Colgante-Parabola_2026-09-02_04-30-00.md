# Log 531 — M40 Puente de cuerda colgante (parábola) + duplicado M25 detectado

**Fecha:** 2026-09-02 04:30 (hora del sistema; el reloj inyectado puede estar desfasado)
**Agente:** MiniMax-M3 · WorkBuddy AI · Windows
**Módulo:** 40 — Infraestructura
**Asset:** `puente_cuerda_colgante`
**Tarea:** #55
**Estado:** ✅ CERRADO (3 GLB + 3 `.import` + 3 `.scn` verificados por archivos, E-65)

---

## 1. Qué se hizo

Asset nuevo (no estaba en el backlog de 114): un **puente colgante de cuerda** para
M40 Infraestructura, distinto del `puente_cuerda` de M25 y del `puente_troncos` de M40.

Archivo generado:
`tools/mcp/blender-mcp/40-Infraestructura/scripts/crear_puente_cuerda_colgante_lowpoly.py`

---

## 2. La curva: parábola, NO catenaria

Error conceptual evitado. El nombre "colgante" sugiere catenaria (`cosh`), que es la
forma de una **cuerda pesada por su propio peso**. Pero un puente con tablero tiene la
carga (los tablones) **uniformemente distribuida en x**, no en longitud de arco. En ese
caso la curva de equilibrio es una **parábola**:

```python
def z_cable(x):
    return Z_CENTRO + (x / HALF_SPAN) ** 2 * (Z_POSTE_TOP - Z_CENTRO)
```

Con `HALF_SPAN = 2.20`, `Z_CENTRO = 0.95` (vientre), `Z_POSTE_TOP = 1.90` (apoyo).

La curva se discretiza en **N segmentos rectos**, cada uno un cilindro corto orientado
con `to_track_quat` (E-58, nunca trig manual):

```python
def segmento_cable(nombre, p0, p1, radio, material):
    direccion = p1 - p0
    largo = direccion.length
    centro = (p0 + p1) / 2.0
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=6, radius=radio, depth=largo, location=centro)
    o = bpy.context.object
    o.name = nombre
    o.rotation_euler = direccion.to_track_quat('Z', 'Y').to_euler()
    o.data.materials.append(material)
    return o
```

`to_track_quat('Z','Y')` alinea el eje local +Z del cilindro (que es su largo) con la
dirección del segmento. Sin esto, cada tramo quedaría vertical.

---

## 3. Geometría final (v2)

| # | Pieza | Cantidad | Notas |
|---|-------|----------|-------|
| 1-2 | Basa de piedra | 2 | caja 0.45×0.45×0.12, en x = ±HALF_SPAN |
| 3-4 | Poste | 2 | caja 0.18×0.18×1.78, de Z_BASE a Z_POSTE_TOP |
| 5-10 | **Cable principal** | **6** | 3 tramos por lado (y = ±SEMI_ANCHO) |
| 11-13 | Tablón de tablero | 3 | caja 0.30 × 1.00 × 0.06 en z = Z_TABLERO |
| 14-15 | Barandilla | 2 | cuerda vertical del cable al tablero |

**Total: 15 `SM_` / 15 objetos.**

Constantes: `HALF_SPAN=2.20`, `Z_BASE=0.12`, `Z_POSTE_TOP=1.90`, `Z_CENTRO=0.95`,
`SEMI_ANCHO=0.50`, `Z_TABLERO=0.32`, `RADIO_CABLE=0.035`, `RADIO_BARAND=0.025`.

Resultado del asentado: `ASENTADO: z_min 0.0000 -> 0.0450`,
`HUELLA: toca=8 footprint=4.85 x 0.45`.

---

## 4. Bug v1 → v2: presupuesto ALTA excedido

**Síntoma:** la primera versión generaba 6 segmentos de cable **por lado** (12 total) →
**21 objetos**. El presupuesto M166 §3.3 para ALTA es **≤16 obj**. Fallaba.

**Causa:** dimensión de la pieza mal estimada al escribir el script. No conté los `SM_`
antes de generar.

**Fix:** bajar a 3 tramos por lado (6 total) → **15 objetos**. Visualmente sigue leyendo
como curva porque la flecha de la parábola es suave (0.95 m de vientre en 4.40 m de luz).

**Lección:** contar los `SM_` **antes** de ejecutar. Con N tramos por lado la cuenta es
`2 basas + 2 postes + 2*N cables + 3 tablones + 2 barandillas = 9 + 2N`, así que
`N ≤ 3` para cumplir ALTA.

---

## 5. Validación visual (E-13 / E-37)

6 capturas orbitales por variante, hoja de contacto revisada por visión:

- **ALTA** (15 obj) — los 6 cables describen la curva continua, los 3 tablones se apoyan
  bajo el vientre, las barandillas llegan al tablero sin hueco.
- **MEDIA** — 4 obj / 244 tris / 4 mats.
- **BAJA** — 4 obj / 168 tris / 4 mats.

Las tres aprobadas (visión ✓ 2026-09-02 04:24). Nada flota en los 6 azimuts.

---

## 6. Descubrimiento importante: la línea del backlog era DUPLICADA

El ítem que perseguía era `- [ ] Puente de cuerda colgante (25/28 viajes)`, en la
sección **M25**. Al cerrarlo descubrí que **ya estaba cubierto**:

- Línea 240: `- [x] Puentes de cuerda (M25)` = `crear_puente_cuerda_lowpoly.py`,
  aprobado **2026-08-29 21:12** (log 246), con 3 GLB y 3 `.import` ya en Godot:
  `25-Ruinas-Templos_puente_cuerda.glb` (alta/media/baja).
- Descripción de ese asset: 4 postes de piedra + 13 tablones en catenaria + 2 cuerdas
  maestras + 2 pasamanos + 10 colgantes. Es decir, **el mismo concepto**.

**Consecuencia:** el asset nuevo de M40 **no cierra ningún pendiente real**; es un asset
adicional. La contabilidad honesta queda así:

| Concepto | Antes | Después |
|---|---|---|
| Total ítems | 114 | **114** (117 − 4 duplicados + 1 añadido) |
| Completados | 78 | **79** (+1: el puente M40 nuevo) |
| Pendientes | 36 | **35** (cierra el duplicado de M25) |
| GLB / `.import` / `.scn` | 234 / 234 / — | **237 / 237 / 237** |

El duplicado de M25 **no** suma a "completados" porque su gemelo ya estaba contado.

**Lección:** antes de crear un asset a partir de una línea sin marcar, hacer
`grep -i <nombre> CHECKLIST-OBJETOS-BLENDER.md` y comparar con las líneas ya marcadas
`[x]` del resto del documento. Los duplicados en este checklist viven en **secciones
distintas** (M25 vs M40), así que revisar solo la propia sección no basta. Es el cuarto
duplicado encontrado (`Puentes de troncos M40`, `Hongo luminoso`, `Flor de isla`, y este).

---

## 7. Pipeline ejecutado

```bash
# 1) Generar fuente (socket — requiere Blender GUI; E-56)
#    crear_puente_cuerda_colgante_lowpoly.py  →  15 SM_, z_min 0.0450

# 2) Capturas orbitales headless (E-55: capturar_angulos_headless.py)
#    6 azimuts × 3 variantes

# 3) Variantes MEDIA / BAJA (socket; E-56)
#    generar_variante.py  →  MEDIA 4/244/4 · BAJA 4/168/4
#    E-62 OK: delta +0.000 (no re-asentó; UMBRAL_REASENTADO = 0.25)

# 4) Export glTF headless (E-45, E-49, E-63)
cd "<repo>" && EXPORT_FORZAR=1 EXPORT_MODULOS="40-Infraestructura" \
  "D:/Archivos de programa/Blender Foundation/Blender 4.2/blender.exe" \
  --background --factory-startup \
  --python "tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py"
# RESUMEN_EXPORT {"exportados": 21, "saltados": 0, "errores": 0}
#   alta  ok 27KB 15objs · media ok 15KB 4objs · baja ok 13KB 4objs

# 5) Import Godot (E-64: seguro con el editor abierto, ruido benigno)
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" \
  --headless --path "game/isla-ancestral" --import
# 16 s, DONE

# 6) Verificación por archivos (E-65)
#    237 GLB / 237 *.glb.import / 237 *.scn
#    3 .scn del puente, mtime 04:24 > mtime GLB 04:23
```

**Nota sobre el paso 5:** el import emitió errores de parseo de
`res://scripts/progresion/progression_manager.gd` y
`res://scripts/editor/plugin_herramientas.gd`. **No son míos** — pertenecen al working
tree de otro modelo (~335 cambios ajenos). No se tocaron.

**Nota sobre `25-Ruinas-Templos_puente_cuerda`:** su GLB se re-exportó el 04:13 (por el
`EXPORT_FORZAR=1` de M25) pero su `.import` sigue con mtime Aug 30. **No es un problema**:
Godot decide re-importar por hash de contenido, el GLB regenerado es byte-idéntico al de
Aug 30, así que el `.scn` existente sigue siendo válido. No confundir mtime con desfase.

---

## 8. Archivos tocados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/40-Infraestructura/scripts/crear_puente_cuerda_colgante_lowpoly.py` | CREADO (v2) |
| `tools/mcp/blender-mcp/40-Infraestructura/puente_cuerda_colgante_lowpoly.blend` (+ `_media`, `_baja`) | CREADO |
| `game/isla-ancestral/assets/3d/{alta,media,baja}/40-Infraestructura_puente_cuerda_colgante.glb` | CREADO (3) |
| idem `.glb.import` | CREADO (3) |
| `.godot/imported/40-Infraestructura_puente_cuerda_colgante.glb-*.scn` | CREADO (3) |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | EDITADO (línea dup M25, línea nueva M40, contadores) |
| `Logs/531-*.md` | CREADO |
| `Logs/ULTIMO_NUMERO.txt` | 529 → 531 |

---

## 9. Lecciones para la guía

1. **Parábola ≠ catenaria.** Tablero con carga uniforme en x → parábola
   `z = z_c + (x/L)² · (z_p − z_c)`. Cuerda suelta por su peso → `cosh`.
2. **Contar los `SM_` antes de generar.** Con N tramos por lado: `9 + 2N ≤ 16` → `N ≤ 3`.
3. **Cuarto duplicado del checklist.** Los duplicados viven en secciones distintas;
   el grep debe ser global, no por sección.
4. **mtime de `.import` viejo ≠ import desactualizado.** Godot usa hash de contenido.

---

## 10. Backlog tras este log

**35 pendientes.** Siguientes previstos:

- M25 (7): Columna rota ×2, Columna entera, Bloque piedra tallada, Dintel caído,
  Palanca puzzle, Estructura sumergida.
- M40 (1): Valla de madera (módulo recto + esquina).
- Carretilla de minero (M35) y Espantapájaros (M33) — requieren crear los directorios
  `35-Mineria/` y `33-Agricultura-Extra/` y registrarlos en la whitelist `MODULOS` de
  `exportar_godot.py` (**E-63**: módulo no listado exporta 0 EN SILENCIO).
- M45 (~5), M16, M70, M34.
- **M36 Fauna (9): BLOQUEADO** — reservado por `minimax-m3-free (Kilo Code)`
  (AGENTS.md §8). No tocar.

**Deudas administrativas sin cerrar:**
- 11 temporales `~libvoxel...TMP` (82 MB) en `addons/zylann.voxel/bin/`.
- `cristal_ancestral` MEDIA con 72 vértices degenerados en (0,0,0).
- Commit + push **selectivo** (no tocar los ~335 cambios ajenos).
- Colisión de numeración de logs entre agentes (otro agente usó 529 simultáneamente).
