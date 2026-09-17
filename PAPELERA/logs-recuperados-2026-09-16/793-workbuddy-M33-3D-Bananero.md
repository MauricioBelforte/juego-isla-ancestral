# Log 793 — Hy4 preview / WorkBuddy — M33 3D Bananero

## 1. Contexto
Módulo **33-Agricultura**, sub-track 3D. Sigo el orden natural del backlog de M33 tras los cultivos (log 761) y la regadera (log 790). Próximo item: bananero.

## 2. Diseño

| Pieza | Decisión | Regla | Por qué |
|---|---|---|---|
| Pseudotallo | revolución CERRADA, base r=0.19 → corona r=0.088, H=1.70, 4 anillos de vaina via perfil zig-zag (subida +10mm → labio +0mm → bajada) | E-50 + E-77 + E-92 | Pseudotallo real: 3-5 m, diámetro 25-40 cm en la base. 0.38 m de diámetro pasa min(fp) > 0.30 con margen 27%. El zig-zag se aprovecha del winding (a[i],a[j],b[j],b[i]) de `revolucion`, que da caras hacia afuera para ambas transiciones del labio. |
| 7 hojas | PLANAS y ARQUEADAS: nervio d(t) = d0·cos(φ) + l0·sin(φ) con φ = barrido·t²; integración numérica; contorno con base redondeada y punta afilada | E-93 + E-91 | Las hojas reales se arquean: la nueva erguida, las viejas caen. Rotar d DENTRO del plano (eje n) mantiene la hoja PLANA. Planitud max|dot(p−c,n)| < 1e-17. |
| Distribución | ángulo áureo 2.39996323; attach en z = 0.65 + 0.85·t (escala 0.65→1.50) | E-91 | Primera pasada con z_att = 1.24+0.44·t concentraba todo en la corona y daba "ramillete". Bajé la zona. |
| Inclinación | 24° → 64°; barrido 72° → 43°; largo 1.10 → 1.00; ancho 0.28 → 0.24 | E-93 | Las viejas (más abajo) más caídas y arqueadas; las nuevas más erguidas y cortas. |
| Racimo | UN SOLO OBJETO: pedúnculo curvo (XZ, ref=Y) + 3 manos × 3 bananos curvos + flor macho (revolución violeta colgando). 2 materials dentro del objeto (material_index por cara). | E-70 + E-95 | Reuso `cerrar_prisma()` (la armadura de `tubo_arco` ya está en `herramienta_util.py`). Banano: arco en plano vertical, θ(t) de 52° a −16° vs vertical. |
| Hijo/chupon | revolución cerrada en z=0..0.34, r=0.075 → 0.045 → 0, lados=6 | E-50 + E-91 | Los bananeros crecen en matas: un chupon chico al pie es la marca de la especie. |
| E-50 vs E-91 | **asentar** (no `asentar_herramienta`) | E-91 | El bananero mide ~2.4 m y se abre ~2 m; frac_largo = 0.45 exigiría huella 0.9 m, imposible. E-91 lo dice claro: el criterio es el TAMAÑO, no la forma. Un bananero es un árbol: `asentar`. |

## 3. Presupuesto M166 §3.3 (triángulos reales)

| Pieza | tris |
|---|---|
| Pseudotallo (lados=12, 13 ring-ring + 2 apex fans) | 336 |
| Hojas (7 × 32 tris: 9-pt contorno, estaciones=4) | 224 |
| Racimo (pedúnculo lados=6: 60 + 9 bananos × 60 tris) | 600 |
| Flor (lados=6, 5 ring-ring + 2 fans) | 48 |
| Hijo (lados=6, 2 ring-ring + 2 fans) | 36 |
| **Total** | **1244** |

| Variante | obj / tris / mats | Presupuesto | Margen |
|---|---|---|---|
| ALTA | 11 / 1244 / 6 | ≤16 / ≤6000 / ≤12 | 69% / 79% / 50% |
| MEDIA | 5 / 1244 / 6 | ≤8 / ≤1500 / ≤8 | 38% / 17% / 25% |
| BAJA (ratio 0.5) | 5 / 622 / 4 | ≤6 / ≤700 / ≤4 | 17% / 11% / 0% |

El BAJA pidió `decimate --ratio 0.5` (el default 0.7 da 870 > 700). El racimo es el componente más denso (9 bananos × 60 tris + pedúnculo); incluso adelgazando el banano (M=6 → 4 segmentos del arco) y bajando lados (12 → 6) seguía en 1564 ALTA y 1090 BAJA. La iteración final es lo que está arriba.

## 4. Verificación numérica (E-12, E-50, E-92, E-93, E-94)
```
ASENTADO: z_min 0.0000 -> 0.0450 (delta +0.0450)
HUELLA: toca=20  footprint=0.50 x 0.38
SM_: 11 — triangulos: 1244 — materiales: 6
VOLUMEN pseudotallo +0.1037 m3 (103696 cm3)
VOLUMENES hojas (todos > 0): +2.84e-03, ..., +1.96e-03
z_min = 0.0450 (Pseudotallo e Hijo), no las hojas
```

- E-50 min(fp) > 0.30: 0.38 ✓ (margen 27%).
- E-92 volumen firmado > 0: pseudotallo +0.1037 m³ ✓ (vs bowl +488 cm³). Para un cilindro de π·0.14²·1.70 = 0.105 m³ → nuestro 0.1037 es comparable, ligero desvío por los anillos salientes.
- E-93 planitud de hojas: assert `desp < 1e-9` por hoja ✓.
- E-94 view_layer.update() antes del assert ✓.

## 5. Iteración visual
Primera pasada con z_att = 1.24 + 0.44·t (todas las hojas entre z 1.24 y 1.68, últimos 26% del tallo). Las 6 capturas orbitales leían como "ramillete en la corona": un bouquet de hojas apretadas arriba de un pseudotallo pelado. La silueta NO se leía como banano.

Bajé la zona de attach a z = 0.65 + 0.85·t y la inclinación media de 28° a 24° para las más bajas, y el barrido de 78° a 72° (un poco menos agresivo para que la punta no toque la arena). Resultado: las hojas se escalonan a lo largo del 60% superior del tallo, las viejas caen visiblemente, las nuevas están erguidas. La silueta lee como banano real en los 6 azimuts.

**Lo que quedó bien** (verificado en la hoja de contacto):
- Hojas escalonadas con variedad de orientaciones (golden angle).
- Pseudotallo apoyado en la arena en los 6 azimuts (no flota).
- Racimo con la flor violeta colgando — da carácter.
- Anillos de vaina visibles (bandas sutiles, podrían tener más contraste).

**Lo que no es perfecto** (aceptable para un crop de M33):
- Anillos de vaina con poco contraste (MAT_vaina no se diferencia del tallo). Mejora cosmética menor pendiente.
- El hijo se ve apenas en algunos azimuts (está detrás del pseudotallo).
- El racimo se lee como un blob verde-amarillo más que como 9 bananos individuales a esta resolución.

## 6. Pipeline headless (E-45, E-56)
```
socket 127.0.0.1:9876 = DOWN → no se puede usar generar_variante.py
variantes:  generar_variante_headless.py --ratio 0.5 (solo BAJA decima)
capturas:   capturar_angulos_headless.py (6 azimuts x 3 variantes = 18 PNG)
contact:    contact_sheet.py con el venv PIL (3 jpg)
export:     exportar_godot.py EXPORT_FORZAR=1 (353 exports, 0 errors)
sidecar:    godot --headless --import → 3/3 .scn por conteo
```

Verificación por conteo (E-72): glb==.glb.import==.scn = 3/3/3 ✓.

## 7. Archivos producidos
- `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_bananero_lowpoly.py`
- `tools/mcp/blender-mcp/33-Agricultura/bananero_lowpoly{,_media,_baja}.blend`
- `tools/mcp/blender-mcp/33-Agricultura/capturas/bananero_{alta,media,baja}_az{000,060,120,180,240,300}.png` (x18)
- `tools/mcp/blender-mcp/33-Agricultura/capturas/_hoja_bananero_{alta,media,baja}.jpg` (x3)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/33-Agricultura_bananero.glb{,.import}` (x6)
- `game/isla-ancestral/.godot/imported/33-Agricultura_bananero.glb-*.scn{,.md5}` (x3, md5 distintos)

## 8. Documentación actualizada
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`: bananero [x]; contador 107 → 108.
- `CHECKLIST-GLOBAL.md` (raíz): fila 33 con bloque de cierre 793.

## 9. Deuda restante en M33 (3)
- Plantación de caña
- Compostera
- Tiles `Tierra arada` / `Tierra regada` (altura anti-z-fighting TBD — NO van a Z_APOYO=0.045 porque son tiles del piso)

## 10. Liberación de la reserva
`Logs/reservas/793-workbuddy-m33-3d-bananero.txt` borrado.

## 11. Firma
**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-07
**Estado:** M33 bananero CERRADO — 11 SM_ / 1244 tris / 6 mats ALTA, 3 GLB + 3 .import + 3 .scn (md5 distintos), hoja de contacto aprobada por QA numérico (z_min, V firmado, huella, planitud). Iteración visual: primera pasada = ramillete, segunda = silueta de banano. Iterar con capturas cuando no sale al primer intento es exactamente lo que pide §24.
