# Hy4 — Convenciones: naming, materiales, presupuesto M166, z_min
**Fuente:** BACKLOG-MASTER.md Hy4 (sección dividida 4nov por fundador)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** Histórico/Cerrado


## Convenciones de HY4

### Naming de archivos
- **Scripts:** `crear_{objeto}_lowpoly.py` en `scripts-reutilizables/`
- **Blends:** `{objeto}_lowpoly.blend` (+ `_media.blend`, `_baja.blend`)
- **Capturas:** `{objeto}_az{angulo}.png` + `_hoja_{objeto}.jpg`
- **GLB:** Pendiente de exportar (los blends existen pero no se han exportado a Godot)

### Materiales
Usa la paleta estandar del proyecto:
- `MAT_MaderaClara` — (180, 140, 90)
- `MAT_MaderaOscura` — (90, 65, 40)
- `MAT_PajaClara` — (210, 180, 120)
- `MAT_Piedra` — (130, 125, 120)
- `MAT_TelaCrudo` — (200, 190, 170)
- `MAT_Cuero` — (120, 80, 45)
- `MAT_Cobre` — (180, 120, 60)

### Presupuesto M166 §3.3 (CORREGIDO 2026-09-10 — el dato anterior era erroneo)
- **ALTA:**  <=16 obj / <=6000 tris / <=12 mats
- **MEDIA:** <=8  obj / <=1500 tris / <=8  mats
- **BAJA:**  <=6  obj / <=700  tris / <=4  mats
- **Excepcion casas grandes (plan §6.1):** sub-grupos de <=16 SM_ por room; la casa
  completa puede exceder el nominal de MEDIA/BAJA (caso real: casa mediana v8 = 17 obj).
- Fuente: `scripts-reutilizables/generar_alta.py` + cabeceras de los generadores.

### z_min
- Todos los assets contactan el suelo en `z_min = 0.045`

---
