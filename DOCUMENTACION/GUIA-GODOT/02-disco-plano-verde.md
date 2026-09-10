# DISCO PLANO SÓLIDO CON SURFACETOOL (el "plato verde")

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-09
> **Validado en:** Isla Ancestral — disco r 1600m a y=4.3 sobre el agua, GPU integrada AMD
> **Logs:** 790-796 · **Referencia cruzada:** 07-GUIA-GODOT §13.10

---

## El objetivo

Un disco plano sólido sobre el agua que cubra la isla vista desde lejos
(fondo verde en el horizonte). Debe verse desde la posición del jugador
(a nivel del suelo, mirando horizontal) y desde arriba.

## LOS 3 ERRORES QUE COMETIMOS (no repetir)

### Error 1 — Anillo con agujero (Log 784)

Dibujar solo el anillo exterior deja el centro sin cubrir → se ve "arandela".

```
❌ Anillo:     ◯   (agujero en el centro)
✅ Disco:      ⬤   (relleno)
```

### Error 2 — Plano horizontal sin paredes (Log 789)

Un plano a y=4.05 visto de canto desde lejos es una **LÍNEA de subpíxeles** →
invisible. Un plano horizontal SIEMPRE necesita relieve vertical para verse de
cualquier ángulo, o el jugador nunca lo verá desde el suelo.

### Error 3 — Abanico con vértices duplicados en el centro (Log 790)

Dibujar DOS triángulos por segmento donde p00 y p01 son el MISMO punto (r=0):

```gdscript
# ❌ MAL: 2 triángulos por segmento
var p00 := Vector3(centro.x + cos(a0) * 0.0, y, ...)  # ¡p00 == p01!
var p01 := Vector3(centro.x + cos(a1) * 0.0, y, ...)  # ¡el mismo punto!
_tri(st, p00, color, p01, color, p11, color)  # (centro, centro, borde) = área CERO
_tri(st, p00, color, p11, color, p10, color)  # winding INVERTIDO
```

Resultado por triángulo:
- Triángulo 1 (p00, p01, p11): p00==p01 → **área CERO** → la GPU lo descarta.
- Triángulo 2 (p00, p11, p01): winding INVERTIDO → normal hacia abajo →
  `cull_back` lo cullea desde arriba.

**NETO: cero superficie visible.** Solo quedaban las paredes (que tienen
doble cara) = la **"cinta de pulsera"** que reportó el usuario.

---

## LA RECETA CORRECTA (validada visualmente por el usuario)

### Código completo

```gdscript
func _crear_disco_solido() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r_max := 1600.0
	var segs := 64
	var centro := Vector2(2560.0, 2560.0)  # centro del mundo
	var y_disco := 4.3                     # encima del agua (4.05), bajo la orilla (5.0)
	for i in range(segs):
		var a0 := TAU * float(i) / float(segs)
		var a1 := TAU * float(i + 1) / float(segs)
		# UNA sola copia del centro y DOS bordes — UN triángulo por segmento
		var c := Vector3(centro.x, y_disco, centro.y)
		var b0 := Vector3(centro.x + cos(a0) * r_max, y_disco, centro.y + sin(a0) * r_max)
		var b1 := Vector3(centro.x + cos(a1) * r_max, y_disco, centro.y + sin(a1) * r_max)
		# ORDEN ANTIHORARIO visto desde arriba → normal hacia ARRIBA
		_tri(st, c, color, b0, color, b1, color)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLOR_VERDE
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # seguro extra: doble cara
	mi.material_override = mat
	add_child(mi)
```

### Las 5 reglas de la receta

1. **UN triángulo por segmento** del abanico: (centro, borde_a0, borde_a1).
2. **NUNCA duplicar el centro** del abanico (p00==p01 = triángulo degenerado
   que la GPU descarta).
3. Orden **ANTIHORARIO visto desde arriba** (Y-up) → normal hacia arriba.
   Si se ve desde abajo, invertir el orden de b0/b1.
4. Material con `CULL_DISABLED` como seguro extra (barato: 1 disco).
5. **Verificar SIEMPRE con captura desde la posición del jugador** (no desde
   arriba — la vista cenital engaña).

---

## Cómo saber si el winding está correcto (sin jugar)

**Producto cruzado**: (b0 - c) × (b1 - c) — si el resultado apunta **+Y**, el
orden es correcto (normal hacia arriba).

**O más simple**: probalo — si ves el aro pero no el plato, invertí b0/b1.

**Diagrama mental** (vista desde arriba, Y hacia vos):

```
        a1 (borde)
       /
      /
     c (centro) ——→ a0 (borde)

Triángulo (c, a0, a1): girando de c→a0→a1 en sentido ANTIHORARIO
= normal hacia vos (arriba) = VISIBLE desde arriba.
```

---

## Optimizaciones validadas (GPU integrada)

### Material OPACO — NUNCA TRANSPARENCY_ALPHA en meshes de km

El sorting de transparencias masivo **tilda la GPU integrada**. El disco es
opaco y SIEMPRE visible (1 draw call). Si necesitás fade:

```gdscript
# ❌ MAL: transparencia en un mesh gigante
mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  # tilda
mat.albedo_color.a = alpha  # animado = sorting constante

# ✅ BIEN: fade BINARIO por tile (visible/oculto)
mi.visible = distancia_al_player > umbral
```

### Si el disco debe seguir al jugador

Para que el disco siempre esté bajo los pies del jugador (horizonte verde
permanente), mover el NODO cada 0.25s (no cada frame):

```gdscript
# En el _process del impostor, cada 0.25s:
var h_local := 4.3
if _island_gen != null:
	h_local = maxf(4.3, float(_island_gen.get_height(int(pp.x), int(pp.z))) - 0.7)
_disco_mi.global_position = Vector3(pp.x, h_local - 0.3, pp.z)
```

### Dividir en tiles SI hay fade por tile

Si necesitás ocultar partes del disco cerca del jugador, dividí en tiles
(128-256m) y alterná `mi.visible` por tile — nunca transparencia por mesh
gigante.

---

## Errores técnicos relacionados (07-GUIA-GODOT §8)

| Error | Ver |
|---|---|
| TRANSPARENCY_ALPHA tilda GPU integrada | §13.7 TILDE 3 |
| Plano horizontal de canto invisible | §13.10 Error 2 |
| get_height NO thread-safe (sin Thread) | §13.8 paso 1 |
| Los escalones voxel vs interpolación | §13.10 Error 3 contexto |
