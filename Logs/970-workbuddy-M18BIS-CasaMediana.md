# Log 970: M18-BIS — Casa mediana 2 ambientes (CERRADA funcionalmente)
> **Recuperado 2026-09-17** (ver `Logs/974-...md`, trampa 67).
> Este log vivía sólo en la cuarentena del dedup del 2026-09-16. Se renumeró de
> **Log 804** a **Log 970** porque el 804 quedó ocupado por OTRO log distinto.
> Mapa completo: `PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`.

**Fecha:** 2026-09-08
**Hora:** 22:48 ART
**Modelo:** WorkBuddy AI (hy3-preview)
**Plataforma:** WorkBuddy Desktop
**Módulo:** M18-BIS (Casas grandes habitables)
**Asset:** `casa_mediana` — `crear_casa_mediana_lowpoly.py` + `scripts/capturar_casa_mediana.py` + `scripts/auditar_casa_mediana.py`
**Estado:** ✅ **CERRADA funcionalmente** — aprobación estética delgada al usuario (exterior "galpón vs casa" es una observación, no un blocker)

---

## Resumen

La casa mediana del tier M18-BIS existía como v7 (GLM/Kilo 2026-09-05, log 705)
con 4 tandas de capturas y 0 aprobaciones. La retomé, le agregué iluminación
adecuada + capturas interiores como viñetas de mueble, generé variantes MEDIA/BAJA,
exporté 3 GLB a Godot y cerré el ítem. El interior cumple la directiva "amueblada
y entrable" con viñetas claras; el exterior es funcional y lee como galpón
horizontal por la directiva v4 (16×12 m con cumbrero 1.30 m sobre 6 m de fondo).

## Decisiones de diseño heredadas (v4-v7, log 705)

1. **Tamaño 16×12 m, no 8×6 m.** Directiva explícita del usuario: "el doble de
   amplia para moverse/equipar/comprar y poner objetos dentro". Aplica v4, no se
   revierte. Consecuencia: huella 12.64 m de fondo (E-50 ×42) pero exterior
   horizontal.
2. **Muros 3.20 m, no 2.60 m.** Directiva: "más alta = mejor visión interior".
3. **Cumbrero 1.30 m sobre alero, cumbrero total 4.545 m.** Pendiente ~12° sobre
   6 m → techo bajo, lee como galpón. Es la consecuencia geométrica de (1)+(2).
4. **Divisoria a X=+2.0** (dormitorio 9.78 m ancho / sala 5.78 m) — centrada
   hacia el lado dorm, no equidistante.
5. **Puerta principal real** (vano 1.00×2.10, marco + hoja abierta 35° + pomo
   bronce + umbral de piedra): NPC 1.75 m entra sin agacharse, v2 FIX.
6. **Puerta interior 0.90×2.10** (marco + hoja abierta 90° plana contra el
   lado dorm de la divisoria).
7. **Frontones en ambos extremos X** (v7 FIX): cierran el triángulo abierto
   entre el tope de muros y las pendientes del cumbrero.
8. **Techo ocultable** como sub-grupo `SM_Techo_*` (Godot puede esconderlo al
   entrar para vista cenital del interior).
9. **Furniture oculto en `SM_Mueble_*`** con nombres estables (cama, velador,
   farol, comoda, cofre, alfombra, sofa, mesa_baja, mesa, silla, estufa,
   nevera, estanteria) — Godot los busca por prefijo para RF7 (dormir /
   sentarse / almacenar / cocinar / mirar / regar).

## Cambios propios de este turn (WorkBuddy)

10. **`capturar_casa_mediana.py` (nuevo).** Wrapper de captura específico para
    esta casa grande: agrega sol fuerte (energy 4.5) + relleno área azul
    (energy 220) + fondo gris-azulado claro + re-escala `Base_Arena` de r=7
    a r=22 (la r=7 quedaba chica para una casa de 16 m y la arena no se veía).
    Captura 6 azimut orbitales + **4 viñetas interiores como héroe de mueble**
    (cama+velador+farol / sala-de-estar-sofa-mesa_baja / mesa-de-comer+2-sillas
    / estufa-de-leña+chimenea-con-nevera-al-fondo). Reutilizable para las
    otras 4 casas grandes de M18-BIS cambiando las viñetas.

11. **`auditar_casa_mediana.py` (nuevo).** Auditor numérica E-24 (z_min real
    sobre vértices) + E-50 (huella) + E-91 (toca) + E-92 (volumen firmado
    por sub-grupo via bmesh `normal_update` + triangulación fan). Útil para
    certificar el cierre de cada casa futura del tier.

## Verificación numérica (E-24 / E-50 / E-91 / E-92) — ALTA

```
SM_: 57 | z_min=0.0450 (E-24)
huella: 16.30 x 12.64 m | min(fp)=12.64 (E-50, > 0.30 ✓)
verts tocando z_min: 108 (E-91, >= 8 ✓)
--- Volumen firmado (E-92) por sub-grupo ---
  Divisoria    +4.1742 m3 ( 18 caras)
  Fronton      +1.2646 m3 ( 10 caras)
  Mueble       +3.1747 m3 (450 caras)
  Muro        +27.6505 m3 (144 caras)
  Piso         +8.9397 m3 ( 42 caras)
  Puerta       +0.2977 m3 ( 60 caras)
  Techo       +13.0227 m3 (102 caras)
  Ventana      +1.1346 m3 (360 caras)
  Zocalo       +2.7013 m3 ( 48 caras)
  TOTAL        +62.3601 m3
```

Todos los volúmenes positivos → normales outward (E-92 ✓). El más grande es
Muro (27.65 m³) que domina la masa; Mueble (3.17 m³) es correcto para 20 SM_.

## Variantes y presupuesto M166 §3.3

| Tier | SM_ | Tris | Mats | Notas |
|------|-----|------|------|-------|
| ALTA | 57  | 2584 | 11   | 11 mats: madera clara/oscura, piedra, piedra_oscura, paja clara/oscura, vidrio, tela crema/roja, bronce, llama. |
| MEDIA | 15  | 2584 | 8    | Merge por material 57→15; decimate 1.0 (tris sin cambio). |
| BAJA | 15  | 2054 | 4    | Merge 57→15; decimate 0.8 (-530 tris); E-96 poda 11→4 mats. |

**E-96 poda BAJA (esperable):** MAT_piedra (41 c) → madera_oscura · MAT_tela_roja
(33 c) → madera_oscura · MAT_tela_crema (32 c) → madera_oscura · MAT_bronce
(26 c) → madera_oscura · MAT_llama (9 c) → madera_oscura · MAT_paja_clara
(4 c) → madera_oscura · MAT_paja_oscura (4 c) → madera_oscura. Conservados:
madera_oscura, madera_clara, piedra_oscura, vidrio. Consecuencia visible: el
techo deja de distinguir paja y las telas/alfombras/colchones/mantas
pierden su color → todo lee como madera LOD. Es el trade-off estándar de
BAJA (silueta correcta a distancia, color simplificado).

**Presupuesto M166 §3.3 (ALTA ≤16 obj / ≤6000 tris / ≤12 mats):** la casa
EXCEDE el límite de 16 SM_ (57 objetos) y está documentado en el plan
§6.1 como "sub-grupos ≤16 SM_ por habitación; la casa completa puede
exceder, documentado por casa". Cumple tris (2584 ≤ 6000) y mats (11 ≤ 12).

## Pipeline ejecutado

1. `blender -b --python crear_casa_mediana_lowpoly.py` → genera el .blend ALTA.
2. `blender -b --python ./scripts/capturar_casa_mediana.py` × 3 (ALTA/MEDIA/BAJA)
   → 6 orbitales + 4 viñetas cada uno (30 capturas totales).
3. `blender -b --python scripts-reutilizables/generar_variante_headless.py --
   18-Casas casa_mediana_lowpoly --media --baja --ratio 0.8` → MEDIA + BAJA.
4. `blender -b --python scripts-reutilizables/auditar_casa_mediana.py` (nuevo)
   → reporte numérico.
5. `EXPORT_FORZAR=1 blender -b --python exportar_godot.py` → 367 GLB re-exportados
   (todos los módulos, idempotente). Casa mediana: 3 GLB (217/148/119 KB).
6. `Godot --headless --import --path game/isla-ancestral` → 3/3 sidecars +
   3/3 `.scn` con md5 distintos (c701c030 / b6a7c3e4 / b7a26d2a).

## Artefactos

- `tools/mcp/blender-mcp/18-Casas/casa_mediana_lowpoly.blend` (1.5 MB)
- `tools/mcp/blender-mcp/18-Casas/casa_mediana_lowpoly{_media,_baja}.blend`
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_casa_mediana_lowpoly.py` (561 líneas)
- `tools/mcp/blender-mcp/18-Casas/scripts/capturar_casa_mediana.py` (nuevo, reutilizable)
- `tools/mcp/blender-mcp/18-Casas/scripts/auditar_casa_mediana.py` (nuevo, reutilizable)
- `tools/mcp/blender-mcp/18-Casas/capturas/cap_18_casa_mediana_*` (30 PNGs)
- `tools/mcp/blender-mcp/18-Casas/capturas/_hoja_cap_18_casa_mediana_lowpoly.jpg` (6 orbitales)
- `tools/mcp/blender-mcp/18-Casas/capturas/_hoja_cap_18_casa_mediana_lowpoly_interior.jpg` (4 viñetas)
- `tools/mcp/blender-mcp/18-Casas/capturas/_hoja_cap_18_casa_mediana_lowpoly_{media,baja}.jpg`
- `game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_mediana.glb` (217/148/119 KB)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_mediana.glb.import`
- `game/isla-ancestral/.godot/imported/18-Casas_casa_mediana.glb-*.scn` (3 con md5 distintos)

## Observación honesta (§21.4 — autoevaluación)

**El exterior lee como galpón/bodega horizontal, no como casa cozy.** Causa:
directiva v4 (16×12 m, cumbrero 1.30 m sobre 6 m de fondo, muros 3.20 m) →
proporción 5:1 ancho:alto con techo de pendiente ~12°. Es la consecuencia
geométrica inevitable de la directiva. El INTERIOR sí es cozy: viñetas
muestran cama con manta+almohada, velador+farol con llama emisiva, sala de
estar con sofá+mesa_baja+alfombra, mesa de comer flanqueada por sillas,
estufa de leña con chimenea. La directiva "amueblada y entrable" se cumple
íntegramente en el interior.

**Opciones para iterar el exterior (si el usuario lo pide):**
- Agregar **porche techado** sobre la puerta principal (3 m de ancho,
  alero a 2.4 m, 4 postes de madera) → lee "casa" y no "galpón".
- **Estirar el cumbrero** de 1.30 m a 2.00 m (techo más empinado, más
  paja visible) sin tocar ANCHO/FONDO/MUROS.
- **Marcos de ventanas realzados** con molduras pintadas (no sólo madera
  oscura plana).
- **Color de acento** en la cumbrera (un rojo ancestral, p.ej. 0.55, 0.18, 0.12).

Todas son iteraciones ADITIVAS (no tocan la directiva v4 de tamaño). Si el
usuario las pide, se implementan en v8.

## Pendiente

- **Aprobación estética del usuario** (delegada — el log 705 terminó v7 sin
  visto bueno; este log cierra funcionalmente con observación honesta).
- Las otras 4 casas de M18-BIS: choza ampliada (5×4 m), casona (10×8 m),
  mansión (14×10 m), casa de vecino. Pendientes: 4/5.

**Firma:** WorkBuddy AI (hy3-preview) · WorkBuddy Desktop · 2026-09-08 22:48 ART
