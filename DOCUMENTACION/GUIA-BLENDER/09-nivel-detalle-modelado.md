**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

---

# 09 — Nivel Mínimo de Detalle en el Modelado

## 9. Nivel minimo de detalle en el modelado (2026-09-02 — glm-5.3/Kilo Code, directiva del usuario tras el caso jabali M36)

> El usuario fijo el ESTANDAR: "este es el nivel de detalle minimo que
> tenes que aportar a los disenos". Todo asset nuevo (fauna, NPCs, props
> organicos) debe llegar a este piso. Lo que sigue sale de iterar el
> jabali de v1 (tubo rigido) a v12b (aprobado) en 8 rondas de feedback.

### 9.1 La regla de oro: NADA de tapas planas ni tubos uniformes

El sintoma de "rigido" que el usuario rechaza viene de DOS habitos:

1. **Tapa en abanico plana** (el abanico de triangulos que cierra un loft):
   produce el "corte recto" (el culo del jabali v8: rechazado). Cualquier
   extremo visible del cuerpo debe cerrar con ANILLOS QUE SE CONTRAEN
   (r decreciente en 2-3 anillos hasta casi un punto) — nunca el anillo
   final tapado de golpe.
2. **Loft de anillos iguales espaciados uniformemente** (tubo): el cuerpo
   v1 del jabali era eso. La vida organica viene de VARIAR el anillo:
   radios distintos por anillo, centros desplazados (la linea del lomo
   que se HUNDE a media espalda y remonta en la cruz), secciones
   elipticas (mas anchas que altas, o al reves segun la masa).

### 9.2 Checklist del nivel de detalle (lo que marco la diferencia v1 -> v12b)

- [ ] Extremos cerrados con 2-3 anillos de contraccion (grupa redondeada,
      punta de hocico) — PROHIBIDO el abanico plano visible.
- [ ] Silueta ASIMETRICA en el eje del cuerpo: masa adelante vs atras
      (cruz alta + grupa estrecha del jabali; pecho caido de la paloma).
      Un cuerpo simetrico de adelante a atras lee como "salchicha".
- [ ] Linea dorsal variada: el lomo sube/baja entre anillos (el hump de
      la cruz), no es una recta.
- [ ] Miembros con PROPORCIONES DISTINTAS entre pares (delanteras cortas
      vs traseras largas del jabali) cuando la especie lo pide.
- [ ] Colas/cuerdas curvas: loft multi-punto con DIRECCION CAMBIANTE por
      tramo (base -> codo -> punta con tangentes distintas) y radio
      decreciente — jamas un cono recto unico.
- [ ] Detalles anclados con matrix_world del padre YA transformado (ver
      9.3) — posicion "a mano" = piezas flotando.
- [ ] Anillos: 6-10 lados para cuerpo (8 en jabali), 5-7 para miembros
      finos. Elipses (ry != rz) SIEMPRE que la pieza no sea un cilindro
      puro.

### 9.3 Anclar detalles al padre transformado (la leccion dura del jabali)

El jabali v5 puso la rotacion de la cabeza con el SIGNO INVERTIDO (rot Y
negativa creia inclinar abajo y LEVANTA el hocico — E-19) y todos los
detalles posicionados "a mano" segun donde DEBERIA estar la boca quedaron
flotando en el aire. El patron que lo arreglo (v6+):

```python
cabeza.rotation_euler = (...)  # definir pose PRIMERO
cabeza.location = (...)
bpy.context.view_layer.update()          # recien ahora es verdad
MW = cabeza.matrix_world

def punto_cabeza(lx, ly, lz):             # local -> mundo REAL
    return MW @ Vector((lx, ly, lz))
```

Y con assert anti-regresion del signo:
```python
_punta = punto_cabeza(PUNTA_X, 0, PUNTA_Z)
_craneo = punto_cabeza(CRANEO_X, 0, 0)
assert _punta.z < _craneo.z, "el hocico apunta ARRIBA: signo invertido"
```

REGLA: ningun detalle se posiciona con numeros a mano si su padre esta
rotado. Todo via matrix_world. Y todo signo de rotacion que "deberia"
dar una pose se VERIFICA con un assert sobre la geometria resultante.

### 9.4 Curvas tipo cuerda (colas, lianas, tendones): loft con tangentes

La cola del jabali v12b (aprobada) es el patron a copiar: NO dos conos
encadenados (ademas rompe E-70), NO un cono recto. Una linea central de
4-5 PUNTOS con direccion cambiante + anillos ortonormales por tramo:

```python
PTOS = [base, base + dir1*0.055, base + dir1*0.10,          # curva 1
        base + dir1*0.10 + dir2*0.06, ... ]                  # curva 2
RADIOS = [0.016, 0.014, 0.011, 0.008, 0.003]                 # se afina
# tangente central por anillo (promedio de tramos), n1 = tang x Y,
# n2 = tang x n1 -> anillo de 10 verts alrededor del punto.
```

Bonus: la malla unica queda como 1 pieza animable con 1 pivote (Godot la
menea entera).

### 9.5 Caso de referencia

`tools/mcp/blender-mcp/36-Fauna/scripts/crear_jabali_lowpoly.py` v12b
(log 555): tronco de 10 anillos con hump y grupa redonda por contraccion,
cabeza en cuna con perfil concavo, cola-cuerda curva de 5 puntos. Leer
sus comentarios v5->v12b antes de modelar el proximo animal — cada fix
esta documentado inline.

### 9.6 Directiva de guardado: .blend primero, GLB después (2026-09-05, MiMo V2.5)

> **Regla obligatoria:** cuando se guarda un asset de Blender, **SIEMPRE** se guarda
> primero el `.blend` en `tools/mcp/blender-mcp/{ID-Modulo}/` (ej: `36-Fauna/`).
> **NO se exporta GLB** a `game/isla-ancestral/assets/3d/` sin aprobación explícita
> del usuario.

**Flujo correcto:**

```
1. Ejecutar script en Blender → screenshot + stats (tris, objs, mats)
2. Guardar .blend en tools/mcp/blender-mcp/{ID-Modulo}/
3. Presentar resultado al usuario para aprobación
4. Solo si el usuario aprueba → exportar GLB a game/...
```

**Razón:** el usuario quiere revisar los modelos antes de integrarlos al juego.
Las pruebas y iteraciones van primero en la carpeta del módulo, no en la
carpeta de assets finales.

---
