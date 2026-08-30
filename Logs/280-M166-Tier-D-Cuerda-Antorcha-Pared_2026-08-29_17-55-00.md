# $1280 — M166 Tier D: cuerda enrollada + antorcha de pared (2026-08-29 17:55)

## Resumen ejecutivo

Continuación de la directiva del usuario "egui por donde consideres, ya sea mejora
o crea nuevos objetos" (typo del usuario, probablemente "seguí"). Sigo con Tier D
del `CHECKLIST-OBJETOS-BLENDER.md`. En este turn:

- **Cuerda enrollada (M16)** — completado: source + MEDIA + BAJA, todos con E-13
  aprobado (6 capturas orbitales cada uno). z_min = 0.045.
- **Antorcha de pared (M25)** — completado: source + MEDIA + BAJA, E-13 aprobado
  (6×3 capturas). z_min = 0.045.
- **Cartel indicador (M40)** — ya estaba hecho del turn anterior, queda
  referenciado en el checklist.

Lección nueva **E-27** (descubierta y corregida en `cuerda_enrollada`):
sobreescribir `child.matrix_parent_inverse = parent.matrix_world.inverted()`
después de parenteo **anula la herencia**: la posición local del hijo se
convierte en posición world directa. Esto rompió la alineación del cono-punta
respecto del cabo. Fix correcto: NO tocar `matrix_parent_inverse`, dejar que
Blender lo compute automáticamente al asignar `parent`.

## §1 Cuerda enrollada (M16-Crafting)

**Archivo:** `16-Crafting/scripts/crear_cuerda_enrollada_lowpoly.py`

**Composición:** 2 toroides acostados en el suelo (rollos de soga) + cilindro
horizontal que sale del rollo como cabo + cono como punta deshilachada. Total
4 SM_ source → 2 mallas mergeadas (por material) en MEDIA/BAJA.

**Variantes generadas:**
- MEDIA: 2 obj / 401 tris / 2 mats (z_min 0.045, dentro del budget 1500)
- BAJA: 2 obj / 357 tris / 2 mats (z_min 0.045, dentro del budget 700)

**Bugs encontrados y corregidos durante el turn:**

1. **Diseño inicial mal:** dos toroides apilados verticalmente parecían un
   sándwich tipo UFO, no un rollo de soga. El cabo cilíndrico vertical
   parecía un poste, no un cabo. **Fix:** quitar la rotación 90° del
   segundo rollo para que quede al mismo nivel, y acostar el cabo
   cilindro con `rotation=(90°X, 0, 35°Z)` para que salga horizontal.

2. **E-27 (CRÍTICO):** primera versión con el cono-punta parentado al cabo
   calculaba mal la posición: el cono aparecía en el origen (0, 0, 0.193)
   en vez de en la punta del cabo. Causa: sobreescribí
   `punta.matrix_parent_inverse = cabo.matrix_world.inverted()` y luego
   asigné `punta.location = (0, 0, 0.193)`. Con esa combinación, la
   posición local del hijo se convierte en posición world directa
   (porque `child.matrix_world = parent.matrix_world @
   parent.matrix_world.inverted() @ child.matrix_local = child.matrix_local`).
   **Fix:** eliminar la línea que sobreescribe `matrix_parent_inverse`.
   Blender, al asignar `child.parent = parent`, ya calcula automáticamente
   la inversa correcta para preservar la world position. Después solo
   `punta.location = (0, 0, 0.34/2 + 0.045/2)` para colocar el cono
   en el extremo +Z local del cabo (sumando la mitad de su profundidad
   para que la base toque el final del cabo).

## §2 Antorcha de pared (M25-Ruinas-Templos)

**Archivo:** `25-Ruinas-Templos/scripts/crear_antorcha_pared_lowpoly.py`

**Composición:** placa trasera vertical apoyada en el suelo (0.16 × 0.32 ×
0.020) + brazo horizontal de hierro que sale hacia adelante (L=0.18, R=0.020)
+ copa cilíndrica al final del brazo + mango de madera vertical dentro de la
copa + tela carbonizada envolviendo el tercio superior del mango + brasa
emisiva en la punta + 4 remaches en las esquinas de la placa (todos en una
sola malla bmesh). Total 7 SM_ source → 4 mallas mergeadas en MEDIA/BAJA.

**Set de captura:** se incluye un panel de pared vertical
(`Set_Pared`, 1.4×0.05×1.40) detrás de la antorcha para dar contexto
visual en las capturas, pero NO se exporta (prefijo `Set_` lo marca como
solo-set). La placa se modeló apoyada en el suelo, no suspendida de la
pared — así el asset exportable es autosuficiente.

**Variantes generadas:**
- MEDIA: 4 obj / 94 tris / 4 mats (z_min 0.045, dentro del budget 1500)
- BAJA: 4 obj / 81 tris / 4 mats (z_min 0.045, dentro del budget 700)

**Issue de cámara durante el turn:** la primera versión puso la cámara en
+X -Y (detrás de la pared), lo que daba un ángulo donde la placa se
veía edge-on. **Fix:** cámara a `(+0.65, +0.80, +0.50)` mirando a
`(+0.05, -0.10, +0.25)` — vista 3/4 frontal-derecha que muestra placa,
brazo, copa y antorcha completos.

## §3 Estado del Tier D

| Ítem | Módulo | SM_ src | MEDIA (obj/tris/mats) | BAJA (obj/tris/mats) | z_min | E-13 |
|---|---|---|---|---|---|---|
| cartel_indicador | M40 | 5 | 3/30/3 | 2/17/2 | 0.045 | OK 6/6 |
| cuerda_enrollada | M16 | 4 | 2/401/2 | 2/357/2 | 0.045 | OK 6/6 |
| antorcha_pared | M25 | 7 | 4/94/4 | 4/81/4 | 0.045 | OK 6/6 |

**Pendientes del Tier D:**
- Conchas y caracoles adicionales (M45)
- Puentes de cuerda (M25)
- Pozo de piedra (M40)
- Puentes de troncos (M40)

## §4 Lección E-27: parenting correcto en Blender (revisada y consolidada)

**Regla:** al asignar `child.parent = parent` en Blender, **dejar que
Blender calcule automáticamente `child.matrix_parent_inverse`**. NO
sobreescribirlo manualmente.

**Por qué:** Blender computa `matrix_parent_inverse` para preservar la
world position del hijo al momento del parenteo. Si después sobreescribís
con `parent.matrix_world.inverted()`:

- Si NO cambiás `child.location` después, la world position se preserva
  (porque `child.matrix_world = parent.matrix_world @
  parent.matrix_world.inverted() @ child.matrix_local = child.matrix_local`
  y como `child.matrix_local` no cambió desde la creación, la world
  position se mantiene).
- Si SÍ cambiás `child.location` después, la nueva location es WORLD
  DIRECTA, no relativa al padre. Esto es lo que rompió la cuerda.

**Patrón correcto y limpio:**

```python
# Crear el hijo en (0, 0, 0) o donde sea su world position inicial
bpy.ops.mesh.primitive_xxx_add(location=(0, 0, 0), ...)
hijo = bpy.context.object

# Parentar. Blender ajusta matrix_parent_inverse automáticamente.
hijo.parent = padre

# Mover en frame LOCAL del padre (ejes locales del padre, no world).
hijo.location = (offset_x_local, offset_y_local, offset_z_local)
```

**Patrón que funciona pero es confuso (NO recomendado):**

```python
# Crear hijo en su world position final
bpy.ops.mesh.primitive_xxx_add(location=(world_x, world_y, world_z), ...)
hijo = bpy.context.object

# Parentar SIN sobreescribir matrix_parent_inverse (Blender lo hace solo)
hijo.parent = padre

# NO tocar más la location — el hijo queda en su world position original
# y el padre puede moverse después arrastrándolo.
```

El primer patrón es más claro y reusable. Es el que uso en E-27.

## §5 Cambios al sistema

- `16-Crafting/scripts/crear_cuerda_enrollada_lowpoly.py`: 3 reescrituras
  hasta llegar al diseño correcto. Comentarios del bug del primer patrón
  de parenting dejados en el código como advertencia para futuras revisiones.
- `25-Ruinas-Templos/scripts/crear_antorcha_pared_lowpoly.py`: creado.
  Primera versión de cámara mal (atrás de la pared), corregido.
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`: 3 nuevos ítems
  marcados como completados con timestamp, contadores actualizados
  (43/117, 0 pendientes de captura).
- `Logs/ULTIMO_NUMERO.txt`: NO actualizado (este log usa 238 que ya está
  tomado por otro tema no-M166; el siguiente log M166 usará 239).
- `.workbuddy-ai/memory/2026-08-29.md`: append de este turn.
- `.workbuddy-ai/memory/MEMORY.md`: append de la lección E-27.

## §6 Pendientes para próximos turns

- Continuar Tier D: conchas/caracoles, puente de cuerda, pozo de piedra,
  puente de troncos.
- Evaluar si `antorcha_pared` debe tener ALTA (los 17 heroes ya están
  definidos y este no está en la lista — sigue siendo MEDIA/BAJA).
- Considerar el `Set_Pared` para otros assets mounted (carteles
  adicionales, etc.).
- Limpiar `C:/Users/Maury-New/AppData/Local/Temp/` de scripts temporales
  viejos (acumulación de la sesión).
