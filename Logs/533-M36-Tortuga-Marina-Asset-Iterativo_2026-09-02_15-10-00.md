# Log 533: Tortuga Marina M36 — Asset 3D Completo Con Pipeline

**Fecha:** 2026-09-02
**Hora:** 15:10
**Modelo:** GLM 5.3 (z-ai)
**Plataforma:** Kilo Code

## Resumen

Se creó, iteró con feedback directo del usuario (V1) y cerró el asset 3D
**Tortuga Marina** (M36 Fauna, checklist línea 110) con el pipeline completo:
fuente ALTA + variantes MEDIA/BAJA + 3 GLB exportados + import Godot verificado.
Primer animal del módulo 36 y primer asset del proyecto aprobado en sesión
iterativa de 4 rondas con el usuario mirando el viewport en vivo.

## Cambios Realizados

- v1→v2: fix E-50 (esfera del domo colgaba bajo el plastrón) + E-19 (cola invertida).
- v3: rediseño total a pedido del usuario ("mejorarla al máximo"): aletas
  delanteras remo bmesh loftado (6 anillos), 9 escudos proyectados sobre la
  curvatura real de la elipsoide (1 malla bmesh), cabeza esférica + pico,
  cuello cónico, falda 16 lados + anillo marginal.
- v4 (mix pedido por el usuario): sin pico (cabeza redonda), traseras nuevas
  (remo compacto elíptico), cola cono.
- v5 (feedback final): cola de la v2 restaurada (la v3/v4 la tenía invertida
  por recaída del E-19), **E-74 descubierto y corregido** (espejo de aletas:
  negar ángulo Z, nunca π−áng — la izquierda cruzaba bajo el cuerpo y quedó
  oculta, el usuario veía "una sola pata"), cabeza agrandada r 0.105→0.12.
- Pipeline: `36-Fauna` agregado a `MODULOS` del exportador (E-63), variantes
  MEDIA (5 obj/1430 tris, merge lossless) y BAJA (4 obj/982 tris, ojos
  podados por umbral), 3 GLB (103/80/61 KB), import Godot verificado por
  archivos (E-65): 3 `.import` + 3 `.scn`.
- E-10 aplicado honestamente: GLM 5.3 no acepta imágenes, la aprobación
  visual fue 100% del usuario mirando su viewport (V1), con QA numérico
  del agente en cada iteración.

## Archivos Modificados/Creados

- `tools/mcp/blender-mcp/36-Fauna/scripts/crear_tortuga_marina_lowpoly.py` (nuevo, v5)
- `tools/mcp/blender-mcp/36-Fauna/tortuga_marina_lowpoly{,_media,_baja}.blend` (nuevos)
- `tools/mcp/blender-mcp/36-Fauna/capturas/` (24 capturas + 4 hojas de contacto v2..v5)
- `tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` (whitelist +36-Fauna)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/36-Fauna_tortuga_marina.glb` + `.import` (nuevos)
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (ítem marcado [x])
- `DOCUMENTACION/09-GUIA-BLENDER.md` (E-74)
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (re-verificación V4/V5 de este agente)

## QA

- z_min 0.0450 (nacida asentada), huella 19 verts 0.75×0.89 (E-50 ✓)
- 14 SM_ / 1430 tris reales / 5 mats (ALTA ≤16/≤6000/≤12 ✓)
- 6 azimuts E-13 por versión, hojas de contacto conservadas
- Import: 3 GLB / 3 `.import` / 3 `.scn` (E-64/E-65 ✓, editor abierto)

## Pendiente / Próximo agente

- Animación en Godot (ver respuesta al usuario en la sesión): el pipeline del
  proyecto es **animar en Godot, no en Blender** (los GLB van sin huesos ni
  actions). Para la tortuga: `AnimationPlayer` + rotación de nodos aleta por
  código (remar), o rig futuro si se quiere nado real.
- Especies restantes del backlog M36 3D: cangrejo, gaviota, pez tropical,
  lagarto, jabalí, cabra, gallina, mariposa (la tortuga sirve de patrón de
  organismo: bmesh loftado + proyección de superficies + E-74).
- E-74 debe respetarse en TODO asset con piezas pareadas.
