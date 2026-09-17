# Log 803 — WorkBuddy (hy3) — M33-3D-TIERRA (arada + regada)

- **Fecha:** 2026-09-08 22:25 ART
- **Módulo:** 33-Agricultura (objetos 3D)
- **Assets:** `tierra_arada` (parche 1×1 con surcos, seco) + `tierra_regada`
  (mismo parche, oscuro y con charcos). Un solo script con MODO por env var.
- **Variantes:** ALTA · MEDIA · BAJA (× 2 assets = 6 blends, 36 capturas, 6 GLBs).
- **Pipeline:** cabeza (`blender -b --factory-startup --python …`) → contacto
  visual → `exportar_godot.py EXPORT_FORZAR=1` → `Godot --headless --import`
  → verificación por conteo (E-65 + E-72).
- **Sockets:** MCP Blender 9876 caído todo el turno (E-45); todo headless.

## Por qué este asset es un caso especial de altura (el dato del día)

La spec del módulo (`02-Analisis.md` decisión A4b) dice que la tierra arada
es un **BLOQUE del catálogo M08**, no una instancia decorativa. Y el
generador de variantes **re-asienta a `Z_APOYO = 0.045`** todas las piezas
del asset — eso destruye cualquier parte que estuviera por debajo. Las
tres restricciones combinadas:

1. **No puede tener caras verticales coplanarias con sus vecinos** (z-fight
   visible en una franja de 1.00 × 0.13 m entre parcelas contiguas).
2. **No puede estar enterrada** (el re-asentado la levantaría 15 cm).
3. **No puede tocar la arena coplanariamente** (z-fight con el terreno
   en una franja de 1.00 m).

**Solución:** el contorno BAJA hasta z=0.045 en los 4 bordes, es decir
**5 mm bajo el top de la arena (0.05)**. Por construcción:

- Dos parcelas en Y se juntan en una línea a z=0.045 (5 mm bajo la arena).
  El espacio entre ellas se ve como un surco en V natural.
- La extrusión en X es 0.98 (1 cm de luz por lado) — las tapas de
  extrusión (verticales) NUNCA son coplanarias con las del vecino.
- Ninguna cara toca la arena coplanariamente: el perímetro está BAJO
  la arena, el resto del bloque está SOBRE la arena.

**Por qué esto no es lo mismo que los demás objetos:** todos los demás
assets se asientan a 0.045 con su apoyo hacia ABAJO. Este se "asienta"
con su apoyo hacia ARRIBA (los 4 bordes quedan a 0.045, el resto del
prisma va hacia arriba). Por eso la huella es 0.98×1.00 con **4 verts
tocando** (las 4 esquinas de la base), no 8+ como un objeto apoyado
sobre un plano.

## Decisiones de diseño (con la razón)

| # | Decisión | Por qué |
|---|----------|---------|
| 1 | Un solo script con `MODO = os.environ.get('MODO', 'arada')` | Misma geometría base, distinto set de "extras" (piedras vs charcos) y materiales. Evita duplicar 200 líneas. |
| 2 | Contorno de 22 puntos (4 crestas + 5 valles con jitter) | 22 es múltiplo de 2 y "lindo de triangulizar". 4 crestas en 1 m = pitch 0.20, escala de surco real. Jitter ±0.9 cm (cresta) / ±0.6 cm (valle) con hash sin() determinista — sin random, reproducible, y la mano se ve. |
| 3 | Reclasificar caras por `normal + zmax` DESPUÉS de construir el prisma | Permite reusar `prisma_contorno_en` (que solo sabe poner UN material) y obtener 4 zonas (cresta/valle/falda/labio) con 84 tris — imposible de modelar a mano y verificable solo con el conteo. |
| 4 | **EXACTAMENTE 4 materiales** (techo BAJA) | E-96 desde origen. Cero poda. |
| 5 | 1 solo SM_ por asset (prisma + 10 piedras en el mismo bmesh) | E-70. El prismo solo son 84 tris — separar piedras en otro objeto gastaría un SM_ completo para 12 tris cada una. |
| 6 | Regada NO lleva piedras (en su lugar, 12 charcos) | Con 4 mats no entran piedra + agua; en tierra mojada las piedras se ven menos que el agua. Cada versión tiene su propio "detalle premium". |
| 7 | Charcos: 12 mm visibles (NO 4 mm) | A 4 mm sobre un parche de 1 m el ojo no los lee. A 12 mm sí — y se ve "agua" en el surco. Hundidos 8 mm así nunca flotan. |
| 8 | Color de agua (0.16, 0.18, 0.22) — azulado-frío | (0.11, 0.09, 0.07) — marrón muy oscuro — se confundía con el valle mojado. El azul-grisáceo lee como "agua" desde el primer azimut. |
| 9 | Cámara orbital auto-fit | El capturador toma `altura = centro.z` cuando no se le pasa — la cámara queda a 11 cm del objeto con vista 55° sobre la horizontal, suficiente para leer surcos. |
| 10 | **Reutilizar `caja_en` de `hoja_util.py` (E-97)** | El refactor del compostera movió `caja_en + CARAS_CAJA` al módulo canónico. Re-run de compostera dio bit-for-bit idéntico (824 tris, mismos volúmenes) — refactor sin riesgo. |

## Verificación numérica

| Métrica | arada | regada | límite |
|---------|-------|--------|--------|
| SM_ | 1 | 1 | ≤16/8/6 |
| Tris ALTA | 204 | 228 | ≤6000 |
| Tris MEDIA | 204 | 228 | ≤1500 |
| Tris BAJA | 162 (×0.8) | 182 (×0.8) | ≤700 |
| Mats | 4 | 4 | ≤12/8/4 |
| z_min | 0.0450 | 0.0450 | 0.0450 |
| Toca | 4 | 4 | ≥4 (custom: prisma) |
| Huella | 0.98×1.00 | 0.98×1.00 | min≥0.30 |
| V firmado | +0.0772 m³ | +0.0777 m³ | >0 |

Conteo por material (AUDIT reportaba 3 en v1 — E-99):

| Material | arada | regada |
|----------|-------|--------|
| cresta | 12 (4 lomos + 8 laderas) | 12 |
| valle | 7 (5 fondos + 2 hombros) | 7 |
| falda | 5 (2 tapas + 1 base + 2 labios) | 5 |
| extra | 60 (10 piedras × 6 caras) | 72 (12 charcos × 6) |
| **total** | **84** | **96** |

Triángulos derivados: 84 (prisma) + 60×2 = **204** (arada) ·
84 + 72×2 = **228** (regada). Cuadran al triángulo.

## Verificación visual (E-13, 6 azimuts × 3 variantes × 2 assets)

**tierra_arada ALTA** (vista az 000): 4 lomos marrones claros con jitter
visible, piedritas grises dispersas (6 en crestas, 4 en valles), hombros
más oscuros entre el lomo y el borde, labio de 3 cm descendiendo al
suelo. El perímetro se ve entrando en la arena sin aire.
**tierra_arada ALTA** (vista az 180): la cara opuesta a la luz — lomos
a contraluz, se ve el relieve en silueta.
**tierra_regada ALTA** (vista az 000): MISMA silueta, pero los 4 valles
tienen charcos azul-acero que se leen como agua. Diferencia visible vs arada.
**tierra_regada BAJA** (vista az 000): idéntica, decimate 0.8 no toca
los quads de los charcos ni del prisma (solo colapsa 1-2 edges de cada
caja de 12 tris, que es lo único que el decimate puede colapsar).

## Pipeline (E-65 + E-72)

1. `MODO=arada blender -b --factory-startup --python crear_tierra_cultivo_lowpoly.py`
   → 1 SM_ / 204 tris / 4 mats, blend guardado.
2. `MODO=regada blender -b --factory-startup --python …` → 1/228/4.
3. `generar_variante_headless.py -- 33-Agricultura {tierra_arada,tierra_regada}_lowpoly
   --media --baja --ratio 0.8` → 2×MEDIA + 2×BAJA.
4. 6 capturas orbitales por variante → 36 PNGs.
5. `contact_sheet.py` × 6 → 6 hojas de contacto JPG.
6. **Iteración v1 → v2 (regada)**: la primera pasada tenía charcos de
   SEMI_Z=0.0055 (4 mm visibles) y color (0.11,0.09,0.07) — no se leían
   como agua. Corregido a SEMI_Z=0.010 y color (0.16,0.18,0.22) con
   spec=0.80. Re-capturado y re-exportado.
7. **Revisión visual de las 6 hojas** (E-10): aprobada en todos los
   azimuts; el perímetro se ve entrando a la arena sin aire visible
   desde ninguna altura.
8. `exportar_godot.py EXPORT_FORZAR=1` → 6 GLBs (13-15 KB c/u).
9. `Godot --headless --import` → 6 `.glb.import` (alta/media/baja × 2).
10. `ls .godot/imported/ | grep 33-Agricultura_tierra` → 6 `.scn` con md5
    distintos:
    - arada: `8e7e12f1…` (alta), `93a9dafd…` (media), `d2125348…` (baja)
    - regada: `7ecdfa34…` (alta), `8a9ded08…` (media), `ae2aa88d…` (baja)
11. **Conteo 6/6** (E-65 + E-72): GLB `.import` `.scn` → 6 + 6 + 6.

## Artefactos

| Archivo | Notas |
|---------|-------|
| `tools/mcp/blender-mcp/33-Agricultura/{tierra_arada,tierra_regada}_lowpoly.blend` | ALTA |
| `…_{tierra_arada,tierra_regada}_lowpoly{_media,_baja}.blend` | variantes |
| `scripts/crear_tierra_cultivo_lowpoly.py` | generador con MODO |
| `capturas/tierra_{arada,regada}{,_media,_baja}_az{000…300}.png` | 36 capturas |
| `capturas/hoja_tierra_{arada,regada}{,_media,_baja}.jpg` | 6 hojas |
| `game/.../assets/3d/{alta,media,baja}/33-Agricultura_tierra_{arada,regada}.glb` | 6 GLBs |
| `…/3d/{alta,media,baja}/33-Agricultura_tierra_{arada,regada}.glb.import` | 6 sidecars |
| `.godot/imported/33-Agricultura_tierra_{arada,regada}.glb-{md5}.scn` | 6 .scn |

## Documentación actualizada

- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` líneas 48-49:
  ambos `- [ ]` → `- [x]` con la entrada larga (los dos en uno); línea de
  contadores 110 → 112, "M33 — quinta hornada (9/9)".
- `DOCUMENTACION/09-GUIA-BLENDER.md` §3: nueva entrada **E-99**
  (BMFace.normal vale 0 hasta `bm.normal_update()`; sin esto, el
  material del "no z-alto" queda huérfano en cualquier clasificador por
  normal).
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`: sin cambios (QA
  visual OK, no hay nueva lección de modelo).
- `MEMORY.md` (workspace): E-99 añadido; M33 8/9 → 9/9, pendientes 0.
- `daily log 2026-09-08.md`: append con la lección.
- `Logs/reservas/803-WorkBuddy-M33-3D-TIERRA.txt` (reserva) — **se borra
  al final de este log**.

## Deuda restante (M33 3D)

**CERO.** M33 3D cerrado: 4 cultivos + regadera + bananero + cañaveral +
compostera + 2 tiles = **9 ítems, 9 cerrados**.

Backlog global intacto: M18-BIS 5 · M25/24/26 6 · M36 5 (reservado por
otro modelo, no toco) · M34/35 4 · M40 1.

## Lecciones / E- nuevos

- **E-99 (nuevo, este log):** `BMFace.normal` en bmesh vale `(0,0,0)`
  para caras recién creadas con `bm.faces.new()`. Sin
  `bm.normal_update()` después de construir y antes de clasificar,
  TODA cara que no supere el umbral por z cae en el `else` y el
  material de la zona "no alta" queda huérfano (la auditoría reporta
  3 mats en vez de 4 — el valle en este caso). Mismo espíritu que
  E-94 (`view_layer.update()` antes de medir): la geometría existe,
  pero sus atributos derivados no se computan hasta que se piden
  explícitamente. Aplica a cualquier clasificador por normal
  (suelo/agua/niebla, cresta/falda, manto por normal.z > 0.3, etc.).
- **Caso especial de altura (este log):** si un asset es un BLOQUE del
  catálogo M08 y el generador de variantes re-asienta a 0.045, el
  bloque debe tener su **perímetro a 0.045** y todo el resto por
  ENCIMA. Cero caras coplanarias con vecinos, cero z-fight con el
  terreno, y el surco en V entre parcelas sale gratis por la geometría.
  Aplicable a cualquier futuro "tile" del juego (piso, pasto, arena,
  nieve — todos los que son bloques que se replican adyacentes).
- **Refactor E-97 verificado:** mover `caja_en` de compostera a
  `hoja_util.py` no alteró bit-for-bit la compostera (824 tris, mismos
  volúmenes). El módulo canónico ahora tiene `caja_en + CARAS_CAJA`
  reusables para todos los scripts de assets.

## Aprobación

**Tiles M33 cerrados.** Ambos assets cumplen M166 §3.3 en las 3
variantes, apoyan sin flotar (E-12), no tienen caras coplanarias
(requisito M08-A4b), encajan con E-50 y E-70, y se ven correctos en
los 6 azimuts a ALTA y BAJA (E-13). Iteración de charcos v1 → v2
documentada (E-10, revisión visual atrapó el problema antes de
exportar).

- **Firma:** WorkBuddy AI (hy3-preview) — 2026-09-08 22:25 ART
