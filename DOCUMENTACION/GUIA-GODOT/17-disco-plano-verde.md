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

---

## Errores nuevos del anillo arena (Log 817, glm-5.3-flash / Kilo Code)

### E-817a: Triángulos agregados DESPUÉS de `st.commit()` no entran al mesh

- **Síntoma:** el mesh se ve sin la pieza nueva (el anillo de arena nunca
  apareció en el terreno en NINGUNA iteración, ni corrigiendo el winding).
- **Causa:** en `_crear_disco_base()` el bucle del anillo estaba después de
  `var mi := MeshInstance3D.new(); mi.mesh = st.commit()`. Los vértices se
  agregaban al SurfaceTool cuando el ArrayMesh ya estaba construido → se
  descartaban silenciosamente y sin error.
- **Solución:** construir TODOS los triángulos (disco + paredes + anillo)
  ANTES de llamar `st.commit()`. Un solo commit al final.
- **Lección:** si una pieza de un SurfaceTool "no se ve", verificar el ORDEN:
  `begin()` → add_vertex... → `commit()`. Nada después del commit.

### E-817b: `albedo_color` sin `vertex_color_use_as_albedo` pinta todo igual

- **Síntoma:** el anillo de arena se veía VERDE (color del disco) en vez de
  arena, aun estando en el mesh con colores por vértice correctos.
- **Causa:** el material tenía `albedo_color = COLOR_DISCO_BASE` pero NO
  `vertex_color_use_as_albedo = true` → los colores por vértice se ignoran y
  toda la malla usa el albedo del material.
- **Solución:** `mat.albedo_color = Color.WHITE` + `mat.vertex_color_use_as_albedo = true`
  → el color vive SOLO en los vértices (blanco = no altera; disco queda verde
  y el anillo arena, sin oscurecer el disco).
- **Lección:** en un mesh multi-color con SurfaceTool, SIEMPRE activar
  `vertex_color_use_as_albedo` y dejar el albedo en blanco.

### Exageración del impostor sepulta las piezas planas (complemento Log 817)

Si el impostor aplica MONT_EXAG a TODAS las celdas, la playa (h 4-5) se dibuja
como prismas de 14-17 m que sepultan cualquier anillo plano a y≈4.3 y además
`_color_por_altura(top exagerado)` nunca elige arena. Aplicar la exageración
SOLO a celdas altas (h > 6) y dibujar la playa a su altura real.

### E-819: Anillo en radio FIJO no coincide con la costa real (glm-5.3-flash / Kilo Code)

- **Síntoma:** el anillo de arena se veía lejos del player y con agua de por
  medio — "tiene que estar bien cerca". Donde debía estar el anillo había agua.
- **Causa:** el anillo era una arandela de radio FIJO (1800-2300 del centro),
  pero la costa real NO es un círculo perfecto: en cada dirección la orilla
  está a un radio distinto → el anillo quedaba enterrado bajo la isla en
  algunos lados y flotando sobre el mar lejos de la orilla en otros.
- **Solución (anillo v3 "abrazacostas"):** por cada segmento angular (128
  segmentos = 2.8°), muestrear el radio de la costa real caminando desde el
  mar hacia adentro hasta el primer r con `get_height ≥ 4` (O(1) por llamada,
  ~4k llamadas totales, barato) y armar el quad del anillo pegado a ESE radio:
  borde interno = costa − 64m (solapa bajo los bloques), externo = costa + 600m.
  - Clamp anti z-fighting: `inner = maxf(costa − 64, disco_r + 2)` — el borde
    interno nunca es coplanar con el disco verde (en bahías con costa < 1800).
  - El anillo sigue en 16 sectores con ocultamiento <400m (E-818): cerca del
    player mandan los bloques reales; lejos, el anillo impostor.
- **Lección:** NUNCA asumir la costa circular. Toda pieza de horizonte que
  "abraza" la isla debe muestrear el radio real por dirección con get_height.
