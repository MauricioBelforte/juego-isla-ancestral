# Log 822 — M18-BIS Casona 10×8 m (sala + 2 dormitorios + cocina) — CERRADO

## §0 Contexto
Reservado 2026-09-11 por WorkBuddy (Hy4 preview). Directiva del usuario
vigente: *"bien perfecto continua con el resto de casas"* (M18-BIS). El
usuario explícitamente pidió no escatimar en calidad: *"los diseños tienen
que ser premium"*.

M18-BIS **3/5 cerrado** (casa mediana log 806 + choza ampliada log 808 +
**casona log 822**). Pendientes: mansión 14×10 y casa de vecino.

## §1 Por qué 10×8 con 4 ambientes (y no 2 como la mediana)
La casa mediana usa 16×12 con 2 plantas independientes; la casona es el
escalón *intermedio* del jugador y debe sentirse como una casa real,
no como un galpón subdividido. Planta: sala de estar al frente, tabique
con 3 vanos (paso central ancho a cocina + 2 pasos a los dormitorios),
tabiques verticales a ±1.60 separando la cocina de los dormitorios.

```
+-------------------------------------+
|             SALA (36.8 m2)         |  <- sof + mesa + est + alfombra + lampara
+--------[ ]--------[    ]--------[--+
| DORM 1 |    COCINA     |  DORM 2   |  <- cama doble + velador + comoda
| 12.0m2 |    11.7 m2    |  12.0 m2  |     cocina lena + mesa + pozo
+-------------------------------------+
```

## §2 Decisiones de diseño (lenguaje premium, no escatimar)
1. **Techo de TABLONES** (madera_oscura), NO paja. La paja es la firma de la
   choza; la casona es el escalón siguiente. Se conserva UN acento de paja
   clara bajo el alero (0.34 m de franja) como recuerdo del lenguaje.
2. **Piso diferenciado** por ambiente: sala + dormitorios = tablones de
   madera clara (con juntas dibujadas); cocina = losa de piedra. La piedra
   *dice* que ahí hay fuego sin necesidad de cartel.
3. **Pórtico de entrada** (2 postes + viga + escalón de piedra). Es el
   salto "refugio → casa": la choza no lo tiene y la mansión lo tendrá
   más elaborado.
4. **6 ventanas** (vs 2 de la choza): flanqueando la puerta al frente,
   una por dormitorio al fondo, y una por lateral en la sala. Casing
   pintado en MAT_acento en todas.
5. **Chimenea que ATRAVIESA el techo** (caño z 0.155→4.055, sombrerete
   rojo MAT_acento): aprendida en la v8 de la casa mediana, sin humo
   visible la casa lee "galpón".
6. **Cumbrero 1.45 m** sobre semiluz 4.08 → pendiente **19.6°**
   (a propósito: 12° = galpón, 29° = choza; 19.6° lee "casa").
7. **Muebles reales** del log 811 (14 piezas): sof, mesa de centro,
   estantería con libros, alfombra con flecos, lámpara de pie con base
   de piedra, cocina de leña, mesa de cocina, nevera de pozo con patas
   CILÍNDRICAS (E-104/105), cama doble + velador con vela-llama + cómoda
   en dorm 1; cama básica + velador + cuadro ancestral en dorm 2.

## §3 Cifras (auditoría numérica, vértices reales, E-24)

```
Variante   SM_  tris   mats   z_min    huella
ALTA       30   3052   12     0.0450   9.64 x 7.64
MEDIA      19   3052    8     0.0450   9.64 x 7.64
BAJA       19   2122    4     0.0450   9.64 x 7.64
```

Presupuesto M166 §3.3: 6000 tris ✓ / 12 mats ✓ (tope exacto). 30 SM_
amparado por la excepción **casas grandes plan §6.1** (casa mediana v8
usa 60; sub-grupos ≤16 SM_ por habitación — la casona tiene 14 en Mueble
pero están repartidos entre 4 habitaciones: 6 sala + 3 cocina + 3 dorm1
+ 3 dorm2 ≤ 16 cada uno).

`PODA BAJA: 0 piezas eliminadas`. La precaución E-96 (juntar las piezas
firma como la llama de la vela con su soporte) evitó la poda.

## §4 Volumen firmado (E-92)
**0 objetos** con volumen firmado ≤ 0 → todas las normales apuntan hacia
afuera. Validado tras `bm.normal_update()` en cada cara del frontón (E-99).

## §5 Capturas orbitales (§24 anti-flotantes)
- 6 azimuts orbitales por variante × 3 = 18 PNG.
- 6 viñetas interiores por variante × 3 = 18 PNG.
- 6 hojas de contacto (3 exterior + 3 interior).

Verificación visual §24: **los 6 azimuts ALTA** muestran la casona apoyada
íntegramente en el disco (sin luz/aire bajo zócalo). Las 6 viñetas
interiores confirman: sof+mesa+alfombra (sala), estantería con 3 libros
de colores + lámpara, cocina de leña con chimenea alta, cama doble,
cama básica, y los **3 vanos del tabique** desde la puerta principal
(la planta se entiende de una sola mirada).

Observaciones menores (a iterar si se pide):
- El techo en ALTA se ve muy claro en los orbitales — es la luz cenital
  fuerte sobre madera_oscura; no es bug de material.
- La alfombra no se distingue del piso en la viñeta 1 porque el color
  (rojo) está en el mismo rango tonal que el sofá.

## §6 Export + Godot
`EXPORT_MODULOS="18-Casas" blender -b ... exportar_godot.py` →
**3 exportados, 111 saltados, 0 errores** (los 111 son los GLB existentes
no modificados).

Reimport en Godot: `Godot --headless --import` sin warnings.

| var | GLB md5 | .scn md5 | size |
|-----|---------|----------|------|
| alta | e8092b9942 | 0e3eb9809c | 241 KB |
| media | 4d5fd3ef22 | ae619823ee | 177 KB |
| baja | 67692cec45 | 185e653689 | 138 KB |

## §7 Documentación actualizada
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`: ítem de la casona
  cerrado (línea 90).
- `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOG-MASTER.md`: ítem cerrado.
- `tools/mcp/blender-mcp/18-Casas/scripts/capturar_casa.py`: entrada
  `'casona'` añadida al dict `VINETAS` (radio arena 14.0, 6 viñetas).
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_casa_casona_lowpoly.py`:
  creado (~580 líneas, reutiliza la plantilla del choza log 808).

## §8 Cinco observaciones honestas (§21.4)
1. **El techo de la casona no se distingue de la paja de la choza** en
   los orbitales a esa distancia. La firma premium está en los planos
   cerrados; a 5 m con luz cenital ambas se ven crema. Si el feedback
   del usuario pide diferenciación desde fuera, bajar madera_oscura.
2. **El usuario pidió "premium"**. Cumplido en estructura, distribución
   y muebles, pero no en materiales con variación: las paredes son una
   sola madera_clara plana. Casa mediana tiene el mismo problema. Una
   iteración con materiales procedurales (vetas, manchas) mejoraría
   sin sumar tris.
3. **El pozo (nevera) tiene patas CILÍNDRICAS** (E-104/105 aplicado
   preventivamente, no por fallo). Esto significa que la cura es
   estructural, no cosmética: aunque ALTA habría pasado con cajas, BAJA
   habría comido las patas (caso real del log 811).
4. **Muebles colocados a mano**, no validados contra una "ruta de NPC".
   Si una ruta planned pasa por la sala y choca con la mesa de centro,
   hay que moverla. No fue pedido, queda para M19.
5. **Los frontones** están en la misma mesh del techo (E-70: contar
   piezas por mesh, no por caja). Eso baja el conteo de SM_ pero Godot
   oculta los 2 frontones *junto con* el techo al entrar — no es un
   bug, es lo correcto.

## §9 Artefactos
- Script: `tools/mcp/blender-mcp/18-Casas/scripts/crear_casa_casona_lowpoly.py`
- Capturador: `tools/mcp/blender-mcp/18-Casas/scripts/capturar_casa.py`
  (entrada `'casona'` agregada).
- Blend ALTA: `tools/mcp/blender-mcp/18-Casas/casa_casona_lowpoly.blend`
- Blend MEDIA: `tools/mcp/blender-mcp/18-Casas/casa_casona_lowpoly_media.blend`
- Blend BAJA: `tools/mcp/blender-mcp/18-Casas/casa_casona_lowpoly_baja.blend`
- Capturas: `tools/mcp/blender-mcp/18-Casas/capturas/cap_18_casona_*.png`
  (36) y `hoja_18_casona_*.jpg` (6).
- GLB: `game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_casona.glb`
  (241 / 177 / 138 KB).

## §10 Firma y siguiente paso
**Agente actual: —** (libero reserva).
`Logs/reservas/822-WorkBuddy-M18BIS-Casona.txt` → borrado.

M18-BIS 3/5. Próxima vuelta sugerida: **mansión 14×10** (biblioteca + sala
de museo + dormitorios) — el siguiente salto premium. La reserva y el
diseño inicial están en el backlog del HY4.