# Log 737 — workbuddy — M16 Crafting (assets 3D): 4 herramientas + nuevo helper E-91

**Fecha:** 2026-09-04 → 2026-09-05 (cierre admin)
**Agente:** workbuddy (Hy3 preview)
**Módulo:** 16-Crafting (solo autoría 3D; la lógica M16 sigue en step-3.7-flash)
**Reserva:** `Logs/reservas/679-workbuddy-M16-3D.txt` (liberada al cerrar este log)

## Contexto
Continuación del batch M16 abierto en log 678 (M19 batch + reservas varias).
Antes de este log, M16 tenía 7 pendientes: 4 herramientas en mano
(hacha_hierro, martillo, azada, machete) y 3 misc representables
(gema_tallada, frasco_agua, bowl_barro). Este log cierra las 4 herramientas
con un nuevo error documentado (E-91) y un helper reutilizable.

## Entregables

### Nuevos archivos

1. **`tools/mcp/blender-mcp/scripts-reutilizables/herramienta_util.py`** —
   Helper reusable para construir herramientas alargadas (hacha, martillo,
   azada, machete, pico, azuela, guadaña, pala, serpeta, horca):
   - `cerrar_prisma(bm, anillos)` — caras laterales + tapas fan.
   - `punto(eje, t, rx, ry, ang)` — mapea una estación a 3D por eje ('X'/'Y'/'Z').
   - `prisma(nombre, estaciones, eje, material, lados, fase, escena)` — prisma
     de sección variable. `estaciones` = lista de `(t, rx, ry)`. `lados=4`
     romboidal (hojas), `6/8` redondeado (mangos).
   - `perfil(estaciones, t)` — interpolación lineal de `(rx, ry)` en `t`.
   - `recubrimiento(nombre, estaciones, eje, ts, espesor, material, lados, fase, escena)` —
     prisma que envuelve a otro muestreando su perfil real + espesor constante.
   - `asentar_herramienta(escena, min_toca=8, min_fp=0.02, frac_largo=0.45,
     z_apoyo=0.045, tol=0.005)` — el guard E-91 (sustituto de E-50 para
     herramientas alargadas).
   - `cerrar_herramienta(escena, modulo, asset, loc_cam, mira_cam, ...)` —
     wrapper que hace asentar + iluminar + cámara + shade_flat + auditar + guardar.

2. **`tools/mcp/blender-mcp/16-Crafting/scripts/crear_hacha_hierro_lowpoly.py`**
3. **`tools/mcp/blender-mcp/16-Crafting/scripts/crear_martillo_lowpoly.py`**
4. **`tools/mcp/blender-mcp/16-Crafting/scripts/crear_azada_lowpoly.py`**
5. **`tools/mcp/blender-mcp/16-Crafting/scripts/crear_machete_lowpoly.py`**

### 4 herramientas (ALTA / MEDIA / BAJA)

| Asset | ALTA | MEDIA | BAJA | z_min | huella |
|-------|------|-------|------|-------|--------|
| hacha_hierro | 6/388/4 | 4/388/4 | 4/268/4 | 0.045 | 0.68×0.04 (L 0.78) |
| martillo | 8/464/4 | 4/464/4 | 4/312/4 | 0.045 | 0.67×0.03 (L 0.78) |
| azada | 7/348/3 | 3/348/3 | 3/224/3 | 0.045 | 1.35×0.13 (L 1.38) |
| machete | 5/292/3 | 3/292/3 | 2/84/2 | 0.045 | 0.71×0.06 (L 0.73) |

Formato: `objetos_SM / tris_reales / materiales_usados`. Todas en presupuesto
M166 §3.3 (ALTA ≤16 obj / ≤6000 tris / ≤12 mats; MEDIA ≤8 / ≤1500 / ≤8;
BAJA ≤6 / ≤700 / ≤4).

### Diferenciadores por herramienta

- **Hacha de hierro** (vs piedra): cabeza de hierro forjado más gruesa
  (`lados=6, fase=0`, 5 estaciones), collar soldado (en lugar del remache de
  cuero de la piedra), astil con grip de cuero cosido.
- **Martillo** claw hammer: cabeza con boca (+Y, bit de acero) y u partida
  (−Y, dos prismas offset en X con rotación Z), collar, astil cilíndrico con
  grip, pomo.
- **Azada** (1 m de astil): hoja trapezoidal 6 lados, costilla central,
  cuello, collar, grip, pomo.
- **Machete**: hoja romboidal (`lados=4, fase=π/4`, `F_PLANO4=0.707`), guarda
  de bronce, **2 remaches de bronce unidos en 1 SM_** (E-70), empuñadura de
  madera, pomo.

## Exportación a Godot

- `EXPORT_DRY=1 EXPORT_MODULOS=16-Crafting` → 12/12 planned.
- `EXPORT_FORZAR=1 EXPORT_MODULOS=16-Crafting` → 24/24 OK (incluye los 12
  preexistentes — re-exportados por `EXPORT_FORZAR`).
- `godot --headless --import --path game/isla-ancestral` → **8 GLB × 3
  variantes = 24 archivos en `assets/3d/{alta,media,baja}/16-Crafting_*.glb`,
  con sus 24 `.glb.import`** (verificado por CONTEO, E-65 + E-72).

## Verificaciones

- **E-13** (barrido visual 6 azimuts): 24 hojas de contacto generadas (4
  assets × 3 variantes × 6 azimuts = 72 capturas), todas revisadas.
  **Ningún azimut muestra flotación.** Las BAJA mantienen silueta reconocible
  (la pérdida de guarda/remaches en el machete se compensa con la
  elongación de la hoja; el resto son simplemente más simples).
- **E-50/E-91** (asentado): `asentar_herramienta` validó las 4 con
  `toca≥8`, `min(fp)≥0.02`, `max(fp)≥0.45·L`. `delta` ≈ 0.000 en cada caso.
- **E-65/E-72** (import por conteo): 24/24 `.glb` con su `.glb.import`.

## E-91 — nuevo error documentado

**Síntoma:** el guard E-50 (`min(fp_x, fp_y) > 0.30`) rechaza herramientas
alargadas con `fp_y ≈ 0.04` aunque el objeto esté claramente apoyado y la
flotación sea 0.

**Causa:** la heurística E-50 fue calibrada para props centradas (cubos de
~1 m con `fp = 1.0 × 1.0`); no aplica a objetos alargados apoyados de
costado.

**Fix:** nuevo guard `asentar_herramienta` con tres condiciones:
1. `toca ≥ 8` (igual que E-50).
2. `min(fp) ≥ 0.02` (descarta apoyo en arista viva finísima).
3. `max(fp) ≥ 0.45 · L` — **la regla sustituta de E-50 para herramientas**:
   el contacto tiene que cubrir ≥45 % del eje largo.

**Insights de geometría asociados (descubiertos durante el fix):**
- `F_PLANO = sin(60°) = 0.8660`: para `lados=6, fase=0`, la mitad EFECTIVA
  del eje vertical NO es `ry`, sino `0.866·ry`. Hay que dividir el espesor
  pedido por `F_PLANO` en las estaciones para que el grosor físico coincida.
- `lados=6, fase=0`: cara inferior PLANA (dos vértices a 240° y 300°).
  `fase=π/6`: apoyo en arista (vértice único a 270°). Para piezas que
  descansan: `fase=0`.
- `lados=4`: vértices inferiores a la misma `y=0` (arista horizontal del
  rombo) → `fp_y = 0`. Útil para mangos romboidales (machete), destructivo
  para hojas que necesitan grosor real.
- **Mangos cónicos**: si `hz` varía, solo apoya en el punto más grueso →
  `toca=1..6` → E-50 falla. Mantener `hz` CONSTANTE, swell solo en `hy`.

**Aplica a:** hacha_hierro, martillo, azada, machete, pico, azuela,
guadaña, pala, serpeta, horca. **No aplica a:** props anchos (lingotes,
tablones, cestas, vasijas).

**Documentado en:** `DOCUMENTACION/09-GUIA-BLENDER.md` §3 (nueva entrada
E-91 con todas las reglas y el snippet de uso) y §4 (bullet del checklist).

## Archivo de soporte modificado

- `tools/mcp/blender-mcp/scripts-reutilizables/generar_variante.py`:
  arreglado el `argv` para que funcione en invocación CLI de Blender con
  `-b --factory-startup --python script.py -- <args>`. Blender en Windows
  mete TODO el argv (incluido el `-b` y el `--`) en `sys.argv` del script;
  el slice desde el primer `--` lo arregla. Sin este fix el script leía
  `modulo=-b, blend=--factory-startup` y construía paths basura
  (`tools/mcp/blender-mcp/-b/--factory-startup.blend`). El comportamiento
  por socket MCP no cambia (el argv sigue limpio).

## Deudas (no bloquean el cierre)

- Misc M16 pendientes: gema tallada, frasco de agua, bowl de barro
  (3 ítems).
- Visualmente, **6 de los 7 assets M19** del log 678 siguen con revisión
  visual pendiente (el modelo no aceptaba las imágenes en ese turno). Las
  hojas de contacto existen en `19-NPCs_Y_Vecinos/capturas/_hoja_*_v1.jpg`
  y la geometry pasó el QA numérico; falta revisión visual del usuario.
- 11 archivos `~libvoxel...TMP` (82 MB) en `addons/zylann.voxel/bin/`
  — basura de compilación previa, no tocan el gameplay.
- `cristal_ancestral` MEDIA con 72 vértices degenerados en el origen
  (E-32 menor).

## Archivos tocados (resumen)

Nuevos: 5 (helper + 4 generadores).
Modificados: `DOCUMENTACION/09-GUIA-BLENDER.md` (E-91 + bullet §4),
`.workbuddy-ai/memory/MEMORY.md` (E-91 + referencia E-01…E-91),
`tools/mcp/blender-mcp/scripts-reutilizables/generar_variante.py` (fix argv),
`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (4 ítems M16 cerrados +
contadores 95→99 / 53→49), `CHECKLIST-GLOBAL.md` (fila 16).

Generados: 12 .blend (4 × 3), 72 capturas PNG (4 × 3 × 6), 12 hojas JPG
(4 × 3), 12 GLB + 12 .import (los .import nuevos: 12; los 12 re-existentes
se re-generaron).

## Liberación

- `Logs/reservas/679-workbuddy-M16-3D.txt` → **borrado**.
- Fila 16 de `CHECKLIST-GLOBAL.md` → `Agente actual = —`.

Módulo 16 — **herramientas cerrado (4/4)**. Backlog: 3 misc (gema/frasco/bowl).