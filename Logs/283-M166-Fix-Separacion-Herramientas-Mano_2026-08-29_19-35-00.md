# $1283 — M166 Fix de separación E-27 en las 3 herramientas de mano

**Fecha:** 2026-08-29 19:35 (GMT-3)
**Módulo:** 13-Herramientas
**Activos tocados:** `pico_piedra`, `pico_hierro`, `antorcha_mano`
**Tiempo total:** ~15 min entre diagnóstico, fix, regenerado y QA

---

## 1. Pedido del usuario

> "el pico de piedra esta mal hay que corregirlo lo gire y esta separado"

El usuario reportó que el pico de piedra se veía separado (head separada del mango). Antes de tocar nada, diagnostiqué el `.blend` real y resultó que las 3 herramientas de mano del módulo 13 tenían el mismo defecto, no solo el pico de piedra.

## 2. Diagnóstico (mediciones reales del `.blend`)

Escribí `diag_picos.py` y `diag_antorcha.py` para abrir cada `.blend` y leer la
posición/rotación world de cada SM_ con `(o.matrix_world @ Vector(c)).xyz`.
**Resultados:**

| Asset | Mango X | Hijos X | Separación | z_min global |
|---|---|---|---|---|
| `pico_piedra_lowpoly.blend` | centro -0.097 | centro 0.000 | **9.7 cm** | -0.4629 |
| `pico_hierro_lowpoly.blend` | centro -0.093 | centro 0.000 | **9.3 cm** | -0.4629 |
| `antorcha_mano_lowpoly.blend` | centro 0.108 (Z[0.262..0.862]) | centro 0.46 (Z[0.045..0.299]) | **35 cm en X** | 0.045 (parcial) |

La antorcha tenía un caso extra: la brasa emisiva (la parte que arde) terminó
ABAJO, tocando la arena, mientras que el mango de madera flotaba 21 cm sobre la
arena. Una antorcha con la brasa abajo no es una antorcha.

## 3. Causa raíz: E-27 con movimiento posterior del padre

Los 3 scripts `crear_{pico_piedra,pico_hierro,antorcha_mano}_lowpoly.py` usaban
el mismo `hijo()` roto:

```python
def hijo(objeto, padre):
    bpy.context.view_layer.update()
    objeto.parent = padre
    objeto.matrix_parent_inverse = padre.matrix_world.inverted()   # <-- E-27
    return objeto
```

Y después, en el paso de asentado (E-12), hacían:

```python
mango.location.z += (Z_APOYO - z_min)   # el padre se mueve
```

Pero como `matrix_parent_inverse` fue sobreescrito con la inversa de la
`matrix_world` del padre **al momento del parenting**, se anula la herencia:
`child.matrix_world = child.matrix_local`. Mover el mango NO arrastra a los
hijos. Resultado: el mango se levanta 9.7 cm (delta del asentado del pico de
piedra), las piezas se quedan donde estaban. Por eso `z_min` global del source
quedó en -0.4629: nadie se movió, solo se imprimió "asentado" (falso).

El comentario en el script original decía *"matrix_parent_inverse = Matrix()
SOLO vale si el padre tiene matrix_world identidad. Acá la pieza base está
rotada, así que hay que usar la inversa real"*. Es exactamente al revés: usar la
inversa real es lo que rompe la herencia. Blender YA calcula esa misma inversa
al asignar `.parent`.

## 4. Fix v2 aplicado a los 3 scripts

### 4.1) `hijo()` correcto
```python
def hijo(objeto, padre):
    bpy.context.view_layer.update()
    objeto.parent = padre        # Blender calcula matrix_parent_inverse solo
    return objeto
```

### 4.2) Pose vertical nativa con `matrix_world` identidad
El cilindro del mango nace a lo largo de Z; ya no lo roto. El padre (mango) tiene
rotación y traslación cero → `matrix_world = I` → el `child.location` en local
coincide con coords de mundo (legible). Esto también elimina la "rotación
post-hoc" del $1279 que dejó las piezas con la brasa abajo y al mango
desplazado.

Recomputé las posiciones de los hijos para la pose vertical:
- **pico_piedra / pico_hierro**: cabeza (X_CABEZA→Z_CABEZA=0.34), puntas (±Y
  en vez de a lo largo de X), ataduras coaxiales con el mango (sin rotación),
  pomo en el extremo -Z.
- **antorcha_mano**: cabeza arriba (brasa en el extremo +Z), tela y remate
  arriba del mango, cordeles coaxiales.

### 4.3) Assertion anti-regresión
Al final de cada script, una línea que falla fuerte si vuelve a aparecer E-27:
```python
assert abs(z_final - Z_APOYO) < 1e-4, (
    'E-27: el asentado no movió el conjunto (z_min %.4f -> %.4f). '
    'Revisá hijo(): no debe tocar matrix_parent_inverse.' % (z_min, z_final))
```

Las 3 corridas imprimieron "z_min -0.4668 -> 0.0450 (delta +0.5118)" y la
aserción pasó.

## 5. Variantes regeneradas (4 por asset)

| Asset | Source | MEDIA | BAJA | ALTA | ALTA_MEDIA | z_min |
|---|---|---|---|---|---|---|
| `pico_piedra` | 7 obj | 3/82/3 | 3/76/3 | 7/716/3 | 3/716/3 | 0.045 en todas |
| `pico_hierro` | 8 obj | 3/92/3 | 3/87/3 | 8/956/3 | 3/956/3 | 0.045 en todas |
| `antorcha_mano` | 6 obj | 4/88/4 | 4/73/4 | 6/556/4 | 4/556/4 | 0.045 en todas |

(triángulos: 82, 92, 88 en MEDIA — todos bien por debajo del techo de 1500.
BAJA: 76, 87, 73 — todos bien por debajo de 700.)

## 6. E-13 (6 capturas orbitales) + verificación visual

24 PNGs (4 variantes × 6 ángulos) por asset × 3 assets = 72 capturas nuevas.
Hojas de contacto en `13-Herramientas/capturas/`:

- `pico_piedra_v2_{src,altamedia,media,baja}_19-29-26_hoja.jpg` (4 × 6)
- `pico_hierro_v2_{src,altamedia,media,baja}_19-33-32_hoja.jpg` (4 × 6)
- `antorcha_mano_v2_{src,altamedia,media,baja}_19-36-12_hoja.jpg` (4 × 6)

**Resultado visual:** las 12 hojas muestran herramientas íntegras, sin
separación, con la cabeza montada en el mango y el extremo adecuado apoyado
en la arena. APROBADAS.

## 7. Bug colateral descubierto: E-30 en `contact_sheet.py`

Al construir las hojas de contacto:
```
$ python contact_sheet.py capturas/*_az*.png hoja.jpg
OK hoja.jpg con 1 capturas
```

¡Solo 1 imagen! La shell expandió el glob y llegaron N rutas a `sys.argv`,
pero el script solo tomaba `sys.argv[1]`. Resultado: hojas con la misma
imagen repetida 6 veces en grilla, que se ven "aprobadas" pero solo
muestran 1 ángulo → **E-13 invalidada en silencio**.

**Fix:** `pngs = sys.argv[1:-1]` cuando el modo es por rutas; imprimir
AVISO si `len(pngs) < 2`. El camino programático (`verificar_visual.py` →
`hoja(pngs, salida_jpg)`) SIEMPRE estuvo bien porque pasaba una lista de
Python. Documentado en `09-GUIA-BLENDER.md` como E-30.

Verificación post-fix: las 12 hojas dicen "con 6 capturas". OK.

## 8. Cambios al sistema

- **`tools/mcp/blender-mcp/13-Herramientas/scripts/crear_pico_piedra_lowpoly.py`** — reescrito como v2.
- **`tools/mcp/blender-mcp/13-Herramientas/scripts/crear_pico_hierro_lowpoly.py`** — reescrito como v2.
- **`tools/mcp/blender-mcp/13-Herramientas/scripts/crear_antorcha_mano_lowpoly.py`** — reescrito como v2.
- **`tools/mcp/blender-mcp/scripts-reutilizables/contact_sheet.py`** — fix E-30.
- **`tools/mcp/blender-mcp/13-Herramientas/pico_{piedra,hierro,antorcha_mano}_*.blend`** — 12 .blend regenerados.
- **`DOCUMENTACION/09-GUIA-BLENDER.md`** — E-27 fortalecido con el caso M13
  (movimiento del padre) y patrón seguro `hijo()`; nuevo E-30 sobre el bug de
  `contact_sheet.py`.
- **`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`** — entradas de los
  3 assets actualizadas con la nota v2.
- **`Logs/ULTIMO_NUMERO.txt`** 240 → **241**.
- **`.workbuddy-ai/memory/2026-08-29.md`** — entrada con el cierre (abajo).

## 9. Lección meta: el $1279 aplicó la rotación sin notar E-27

El $1279 ("Rotación de 3 hand tools + fix E-26 en capturas") decidió hacer
verticales los 3 hand tools aplicando una rotación -90° sobre Y a TODO el
conjunto. Esa rotación del grupo a nivel `.blend` enmascaró el E-27 del
parenting porque el source ya estaba "armado" en el script original (con la
cabeza perpendicular al mango, etc.); solo se necesitaba reorientar. Pero
cuando se reorienta el grupo, los hijos parentados correctamente habrían
seguido al mango, mientras que con E-27 los hijos se quedaron en su sitio
y aparecieron "al lado" del mango, con el offset justo de la magnitud del
asentado (-9.7 cm = delta del paso 7 en vertical, que se mapea a -X por la
rotación -90° en Y). En la foto de una sola vista, esa separación se
confundía con "ya está vertical, ok"; E-13 (multi-ángulo) no estaba
implementada cuando se hizo ese log, y los criterios de pose-audit no
detectaron offsets de 10 cm. Lección: **siempre E-13 al tocar un .blend**,
aunque la pose parezca bien en una vista.

## 10. Pendiente

- Auditar los otros scripts que usaban el patrón roto
  (`crear_cofre_ancestral`, `crear_monolito_glifos`, `crear_estrella_mar`,
  `crear_arbusto_floral`, `crear_helecho_gigante`, `crear_lingote_metal`,
  `crear_palanca_madera`). Si alguno mueve al padre después de emparentar,
  tiene el mismo bug silencioso. (No bloqueante: los assets resultantes
  están en producción y los usuarios no han reportado defectos; lo trato
  como barrido cuando vuelva a aparecer un caso visible.)
- Si vuelve a aparecer un `z_min` muy negativo en un .blend nuevo, sospechar
  E-27 antes que cualquier otra cosa.

## 11. Contadores

- 43/117 assets completados (sin cambios: los 3 ya estaban marcados).
- 0 PENDIENTES de captura para los 3 assets corregidos.
- 3 tasks de fix (28, 29, 30) completadas; 1 task de documentación (31) en
  preparación.
- 0 bugs nuevos detectados.
