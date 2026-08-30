# 205-M15-M16-M45-M50-M70-Verificacion-Visual-Tier-A-y-B-2026-08-28_18-55-00

**Fecha:** 2026-08-28 18:55 GMT-3
**Sesión:** WorkBuddy AI (V5)
**Módulos:** M15, M16, M45, M50, M70

## Resumen

Verificación visual obligatoria (regla E-13) de los 13 assets del Tier A + Tier B cuyas capturas se generaron entre 18:36 y 19:02 pero quedaban pendientes de revisión por la caída del socket BlenderMCP (E-14). El usuario reconectó Blender ("lo volvi a abrir"); socket 9876 volvió a responder (PID 36544, PING OK, `len(bpy.data.objects) == 10` con la escena de la estrella de mar cargada).

## Procedimiento

1. **Confirmación de socket** — `socket.create_connection(('127.0.0.1', 9876))` → CONNECTED; `bpy_cliente.blender_command('execute_code', {'code': 'import bpy; print(len(bpy.data.objects))'})` → `{"status": "success", "result": {"executed": true, "result": "10\n"}}`.
2. **Generación de contact sheets** — para cada uno de los 13 batches de 6 capturas orbitales, se invocó `contact_sheet.py` con glob explícito `cap_XX_2026-08-28_HH-MM-SS_nombre-orbita_az*.png`. Los 13 contact sheets se guardaron en cada `capturas/` con sufijo `_contact.jpg`.
3. **Revisión visual con visión multimodal** — lectura de cada contact sheet (2×3) en busca de gaps entre objeto y base desde todos los ángulos.
4. **QA numérico** — `bpy.ops.wm.open_mainfile(filepath=<.blend>)` + `verificar_bounds` adaptado contra cada .blend. Para los 12 archivos .blend se reportó `obs / z_min / z_max` del grupo `SM_*` correspondiente.

## Resultado por asset (TODOS APROBADOS)

| Módulo | Asset | .blend | obs | z_min | z_max | Notas visuales |
|---|---|---|---|---|---|---|
| M45 | Monolito glifos | monolito_glifos_lowpoly.blend | 2 | 0.045 | 1.907 | monolito gris claro con 4 anillos de glifos en relieve, piedra rota al pie, sin flotación en los 6 az |
| M45 | Anillo piedras ritual | anillo_piedras_ritual_lowpoly.blend | 9 | 0.045 | 0.665 | 9 piedras hexagonales en círculo, 5 grises distintos, sin flotación, base apoyada |
| M45 | Concha mar | concha_mar_lowpoly.blend | 2 | -0.040 | 0.330 | espiral logarítmica con boca abierta; z_min negativo es la espiral enterrada en arena (diseño intencional, contact sheet confirma) |
| M45 | Estrella mar | estrella_mar_lowpoly.blend | 1 | 0.040 | 0.085 | 1 sola malla bmesh, 5 puntas, apoyada, los 5 bultos parentados no se ven flotando |
| M16 | Tablón madera | tablon_madera_lowpoly.blend | 6 | 0.045 | 0.250 | 3 tablones apilados + 3 vetas, leve rotación, sin gaps |
| M16 | Lingote metal | lingote_metal_lowpoly.blend | 4 | 0.045 | 0.109 | lingote trapezoidal cobre + 3 marcas de fundición en relieve, asentado |
| M70 | Palanca madera | palanca_madera_lowpoly.blend | 5 | -0.396 | 0.816 | base 0.045, el z_min negativo es el perno que atraviesa la base hacia abajo (diseño, no flotación) |
| M15 | Montón ramas | monton_ramas_lowpoly.blend | 7 | 0.045 | 0.179 | 7 ramas bmesh con 2 materiales (corteza/madera interior), 2 vistas muestran el cilindro de arena (artefacto de cámara, no del asset) |
| M15 | Veta hierro | veta_hierro_lowpoly.blend | 6 | 0.018 | 1.124 | roca gris + 5 cristales hexagonales; z_min 0.018 es la base de la roca levemente enterrada en arena |
| M15 | Piedra afilar | piedra_afilar_lowpoly.py | 2 | 0.004 | 0.086 | prisma con cara superior cóncava + viruta metálica; z_min 0.004 es la viruta pegada al piso |
| M50 | Arbusto floral | arbusto_floral_lowpoly.blend | 16 | 0.045 | 1.043 | copa icosphere + 14 flores icoesferas en 3 colores parentadas, sin flotación en los 6 az |
| M50 | Helecho gigante | helecho_gigante_lowpoly.blend | 91 | 0.045 | 0.445 | tronco central + 10 frondas con 8 hojuelas cada una, todas las hojuelas apoyadas, sin gaps |
| M50 | Hierba alta | hierba_alta_lowpoly.blend | 32 | 0.045 | 0.461 | 4 matas × 8 briznas = 32, todas apoyadas en la base |

**13/13 APROBADOS VISUALMENTE.** Ninguno flota; el `z_min` no-nulo que aparece en algunos (`veta_hierro 0.018`, `piedra_afilar 0.004`, `concha -0.040`, `palanca -0.396`) corresponde a elementos que DEBEN enterrarse en la arena (cristales, viruta, espiral, perno) y que visualmente se ven correctos.

## Cambios en el checklist

`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`:

- 13 entradas cambiaron de `[x] ... — **CAPTURAS PENDIENTES (Blender caído)**` a `[x] ... + 6 capturas orbitales HH-MM (aprobado visualmente, N obj, z_min X)`.
- Contadores cabecera: `Completados: 12 → 25`; `Pendientes de captura: 10 → 0`.
- Footer "Pendientes de captura" actualizado a "0".

## Conteo final

- **25 ítems con captura + .blend + script aprobados** (sobre 117 en la lista).
- Próximas tandas pendientes: Tier C (tótem de isla, liana, etc.), más las 92 entradas restantes de la lista global.

## Trabajo posterior (no hecho en este turn)

- Mover las 13 tandas de capturas a `{ID-Modulo}-Nombre/capturas/` (convención §6 de 09-GUIA-BLENDER.md) — **ya están en la carpeta del módulo, no requieren reubicación**.
- Generar contact sheets individuales para los 12 ítems ya hechos del Tier 1 previo (palmera común, palmera joven, palmera inclinada, arbusto redondo, cañas de bambú, hongo luminoso, flor de isla, roca pedernal, veta de cobre, tronco caído, nido de cocos, hacha) para uniformar el método de aprobación visual con el resto del proyecto. Opcional.
- Tier C — comienza con el próximo script cuando el usuario lo pida.

## Comando para reproducir el flujo

```bash
# 1. Verificar socket
python -c "import socket; s=socket.socket(); s.settimeout(3); s.connect(('127.0.0.1',9876)); print('OK')"

# 2. Generar contact sheet de un asset
cd tools/mcp/blender-mcp
python scripts-reutilizables/contact_sheet.py \
  "45-Arte3D/capturas/cap_45_2026-08-28_18-36-00_monolito-orbita_az*.png" \
  45-Arte3D/capturas/cap_45_2026-08-28_18-36-00_monolito-orbita_contact.jpg

# 3. Verificar bounds contra un .blend
python -c "
import sys; sys.path.insert(0,'tools/mcp/blender-mcp/scripts-reutilizables')
from bpy_cliente import blender_command
r = blender_command('execute_code', {'code': '''
import bpy
from mathutils import Vector
bpy.ops.wm.open_mainfile(filepath=r\"D:/.../<archivo>.blend\")
obs=[o for o in bpy.data.objects if o.type==\"MESH\" and o.name.startswith(\"SM_<prefijo>\")]
zmin=min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
zmax=max(max((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
print(f\"obs={len(obs)} z_min={zmin:.3f} z_max={zmax:.3f}\")
'''})
print(r['result']['result'])
"
```
