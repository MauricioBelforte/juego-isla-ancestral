# Log 965 — workbuddy — M33 3D — REGADERA (pieza hueca con asas en arco)
> **Recuperado 2026-09-17** (ver `Logs/974-...md`, trampa 67).
> Este log vivía sólo en la cuarentena del dedup del 2026-09-16. Se renumeró de
> **Log 790** a **Log 965** porque el 790 quedó ocupado por OTRO log distinto.
> Mapa completo: `PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`.

- **Fecha:** 2026-09-07
- **Agente:** workbuddy (Hy3 / WorkBuddy)
- **Sub-pista:** 3D del Módulo 33 (Agricultura)
- **Item:** Regadera de chapa galvanizada (objeto colocado)
- **Estado:** 🟢 Cerrado · 1/1 · 7 SM_ · 928 tris · 5 mats ALTA

## 1. Contexto y backlog

El backlog 3D de M33 traía 9 ítems. Tras la hornada de cultivos (Log 761)
quedaban 5: `bananero`, `plantación de caña`, `compostera`, `regadera` y los
tiles `Tierra arada`/`Tierra regada`. La regadera es la más interesante
técnicamente: es una pieza hueca con pico oblicuo, roseta, collar, arco sobre
la boca con empuñadura de madera y asa trasera en D. Era además la **2ª
validación** de `revolucion()` (E-92) y necesitaba una solución para las
**asas en arco** que ni `loft()` ni `prisma()` pueden modelar (lo que se
convirtió en E-95).

## 2. Decisiones de diseño

| decisión | justificación |
|---|---|
| cuerpo con `revolucion()` | perfil cerrado (sube por la pared exterior, baja por la interior); `loft()` exigiría z creciente y daría un bloque macizo (E-77). |
| 14 lados · 15 puntos de perfil · 3 mats por tramo | `galvanizado` exterior (0,72 0,75 0,78) + `franja pintada` (verde 0,24 0,55 0,42) en vientre y labio + `interior` oscuro (0,26 0,29 0,32). Cero triángulos extra para los detalles de color. |
| pico RECTO en +Z y luego inclinado β=42° | cortar un tubo oblicuo con anillos horizontales exige elipses alargadas (feísimas en lowpoly); mejor construir recto y aplicar `transform_apply(rotation)`. |
| roseta de cobre con `revolucion()` abierta → cerrada | 5 puntos de perfil: arranca fina dentro del pico, se abre a r=0.048, cierra en un disco plano orientado a lo largo del pico (la cara del rociador). |
| **E-95 nuevo**: `tubo_arco()` para asas curvas | polilínea 3D + frame por tangente (`u = t × ref`, `v = t × u`); `ref` debe ser un eje que NO esté en el plano de la curva. |
| empuñadura de madera que envuelve el centro del arco | mismo centerline del arco, radios 0.019..0.024..0.019 — los extremos del arco siguen siendo de metal galvanizado. |
| collar de cobre envolviendo la base del pico | `tubo_arco()` con 2 puntos y radio cónico (0.044→0.038); se monta alrededor del spout, simulando la soldadura. |
| 7 SM_ / 928 tris / 5 mats | 5 materiales distintos: galvanizado, franja, interior, cobre, madera. Ninguno por encima del techo M166 (12 mats). |

## 3. Pieza por pieza

| objeto | tris | material | nota |
|---|---:|---|---|
| `SM_Regadera_Cuerpo` | 364 | 3 mats (galva/franja/interior) | revolución, 14 lados, 15 puntos de perfil; **V firmado = +3179 cm³** ✓ |
| `SM_Regadera_Pico` | 140 | galvanizado | loft con 5 anillos, lados=10, β=42°, `transform_apply(rotation)` |
| `SM_Regadera_Roseta` | 96 | cobre | revolución cerrada, lados=12, cara plana del rociador |
| `SM_Regadera_Collar` | ~24 | cobre | tubo_arco recto de 2 puntos, radio 0.044→0.038 |
| `SM_Regadera_AsaArco` | 144 | galvanizado | tubo_arco sobre semi-elipse `y=0.098·cos(πt)`, `z=0.208+0.136·sin(πt)`, 9 muestras |
| `SM_Regadera_Empunadura` | 96 | madera | tubo_arco sobre t∈[0.30, 0.70] del mismo centerline, radios 0.019..0.024 |
| `SM_Regadera_AsaTrasera` | 64 | galvanizado | tubo_arco en plano XZ (`ref=Y`), 6 puntos en D |
| **TOTAL** | **~928** | **5** | |

## 4. Decisiones de apoyo (E-91)

- huella Ø 0.236 (rodete del cuerpo)
- toca = 15 verts en z=0.0450 (anillo base de 14 + vértice apical)
- L = 0.468 (de x=-0.190 a x=+0.282, dominado por el pico)
- `frac_largo` requerido: 0.45 × 0.468 = 0.211
- `max(fp)` = 0.236 → **margen 12%** sobre el 45% del eje largo ✓

## 5. E-95 (nueva): `tubo_arco()`

**Problema:** un asa en arco sube y vuelve a bajar. `loft()` apila anillos
horizontales con z creciente (E-77) y se cae. `prisma()` avanza por un eje
fijo y da un tubo recto. Sin `tubo_arco()` no había forma de hacer la
mitad de los detalles de canastas, regaderas, palanganas o varillas de
paraguas que pide la dirección de arte.

**Solución:** polilínea 3D + frame de Frenet local. En cada estación:

```
t = normalize(p[i+1] - p[i-1])        # tangente
u = normalize(t × ref)                # 'ref' FUERA del plano de la curva
v = t × u                              # v ya unitario
```

`u × v = t` (porque `t × ref` y `t × (t × ref)` son ortonormales), con lo
que la mano es la misma que usa `prisma()`. `cerrar_prisma(bm, anillos)`
deja las normales hacia afuera sin tocar nada.

**Cuidado de la degeneración:** si la tangente llega a ser paralela a
`ref`, el frame degenera y el tubo sale torcido. Para cada asa, pasar un
`ref` que NO esté en su plano (arco en plano YZ → `ref = X`; asa trasera
en plano XZ → `ref = Y`). El script detecta la degeneración y la
desempantana con un fallback a `(0, 0, 1)`, pero es mejor pasarlo bien
de entrada.

## 6. Verificación de orientación (E-92)

Perfil del cuerpo arranca y termina en el eje (r=0), así que la superficie
es cerrada: encierra el volumen de chapa. El VOLUMEN FIRMADO
`V = (1/6)·Σ(v0×v1)·v2` debe dar **> 0** si las normales apuntan hacia
afuera. Resultado: **+0.003179 m³ (3179 cm³)** → una regadera de 3 L
aprox, que es la capacidad de una regadera clásica. ✓

(Para comparación: el bowl del Log 730 dio +488 cm³.)

## 7. Pipeline headless (sin socket MCP, E-56)

El socket 127.0.0.1:9876 estaba caído en este turno (proceso `blender-mcp.exe`
sin `blender.exe` acompañante). `generar_variante.py` exige el socket, así
que usé `generar_variante_headless.py` (creado en el Log 761) que reemplaza
la única llamada de red por un `exec` local del mismo payload canónico.
Sin tocar `generar_variante.py`.

## 8. Variantes y presupuesto M166 §3.3

| variante | SM_ | tris | mats | techo M166 | ¿pasa? |
|---|---:|---:|---:|---|---|
| ALTA | 7 | 928 | 5 | ≤16 / ≤6000 / ≤12 | ✓ |
| MEDIA | 4 | 928 | 5 | ≤8 / ≤1500 / ≤8 | ✓ |
| BAJA | 4 | 648 | 4 | ≤6 / ≤700 / ≤4 | ✓ (648/700 = 92.6% del techo) |

La variante BAJA está al **92.6%** del techo de tris (648/700) — es justo.
El decimate 0.7 ya no da más sin empezar a comerse la franja pintada y la
empuñadura. Si hace falta una BAJA-MAS todavía más agresiva se puede
bajar a 0.5, pero por ahora cumple.

## 9. Verificación visual (§24 + E-37 + E-13)

- 18 capturas orbitales (6 azimuts × 3 variantes)
- 3 hojas de contacto (`_hoja_regadera_lowpoly{,_media,_baja}.jpg`)
- En las **6 vistas** de la ALTA, el contacto entre el rodete y la arena es
  CONTINUO (no se ve aire entre el objeto y el suelo en ningún azimut)
- La **cavidad oscura** se ve desde arriba (confirmando que la revolución
  hueca está bien hecha y las paredes interiores se orientan hacia adentro)
- La **franja pintada** se lee claramente en el vientre y en el canto del labio
- La **empuñadura de madera** contrasta con el metal galvanizado
- La **roseta de cobre** apunta a lo largo del pico (la cara del rociador
  queda perpendicular al suelo, no perpendicular a la cámara)
- El **asa trasera en D** es visible en las vistas traseras y le da al
  objeto esa lectura de "regadera de verdad" en lugar de "olla con pico"

## 10. GLB / sidecar / .scn

- DRY (`EXPORT_DRY=1 EXPORT_MODULOS=33-Agricultura`): 3 planificados, 0 errores
- Real (`EXPORT_FORZAR=1 EXPORT_MODULOS=33-Agricultura`): 18 exportados
  (3 nuevos + 15 de cultivos/espantapájaros re-exportados), 0 errores
- `godot --headless --import`: 6 GLB alta, 6 sidecars alta, 18 `.scn`
  resueltos en `.godot/imported/`
- Específico de la regadera: 3 GLB + 3 `.import` + 3 `.scn` (E-65 + E-72,
  conteo 3/3 ✓)

## 11. Deuda abierta (siguiente vuelta)

- **Bananero (cultivo):** tronco + racimo, probablemente con `revolucion()`
  para el tronco y bunches para los bananos. Pieza no hueca.
- **Plantación de caña:** tile de 1×1 con varias cañas (variación del
  bambú que ya está en M11-Herramientas, reutilizable).
- **Compostera:** caja con tapa y compost adentro, probablemente
  `caja()` + `loft()`.
- **Tierra arada / Tierra regada:** tiles 1×1 que NO van a
  `Z_APOYO=0.045` (van rasantes con la arena para evitar z-fighting).
  Pendiente definir la altura exacta (¿+0.001? ¿+0.002?).
- Memoria y guías al día: agregar E-95 al `MEMORY.md` y a
  `DOCUMENTACION/09-GUIA-BLENDER.md` §3.

## 12. Liberación

**Sub-pista 3D del módulo 33** ahora en 5/9 ítems cerrados (4 cultivos +
regadera). Quedan 4 (bananero, caña, compostera, 2 tiles).

Se elimina `Logs/reservas/790-workbuddy-M33-3D-Regadera.txt`. `Logs/ULTIMO_NUMERO.txt` se
sincroniza al máximo real de los archivos en `Logs/` (al cierre de este log, 790).

Firmado: workbuddy (Hy3 / WorkBuddy AI) — 2026-09-07.
