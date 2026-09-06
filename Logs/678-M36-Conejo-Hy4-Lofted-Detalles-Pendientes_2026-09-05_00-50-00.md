# Log 678: M36 — Conejo Hy4 lofted (3D correcto, detalles pendientes) + fauna backlog

**Fecha:** 2026-09-05
**Hora:** 00:50
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Conejo reconstruido con metodología Hy4 (bmesh lofting, anillos YZ variando X): el cuerpo y la cabeza ahora tienen **3D real** (no figura plana). Detalles (ojos/orejas) quedaron DENTRO de la cabeza por radio — pendiente ajuste fino.

## Lo que logró esta iteración
- ✅ Cuerpo 3D redondeado (grupa → espalda → pecho → cuello)
- ✅ Cabeza 3D esférica (nuca → cráneo → frente → cara)
- ✅ Vientre crema visible
- ✅ Patas cubos simples
- ✅ Piso de arena + iluminación plantilla
- ✅ Asentado manual con huella (sin guard estricto)
- ✅ 7 vistas orbitales renderizadas
- ✅ GLB exportado

## Pendiente (próximo agente con visión)
1. **Cabeza más chica** (0.075 radio → 0.055) — es más grande que el cuerpo
2. **Ojos afuera de la cabeza**: posicionarlos en la superficie (x ±0.075, y=-0.26, z=0.27) con esfera r=0.012 sobresaliendo
3. **Orejas visibles**: moverlas a la TOP de la cabeza (y=-0.22, z=0.38) con cubos más finos
4. **Exportar GLB final** + registrar en FaunaManager

## Lecciones documentadas en 09-GUIA-BLENDER
- **E-61**: lofting de anillos coplanares = figura plana. Usar el patrón de Hy4 (anillos YZ variando X)
- **E-58**: multiplicadores sin medir el GLB actual = alturas absurdas
- **Asentado manual**: el guard E-50 de plantilla es demasiado estricto para lofts con patas puntiformes — usar medición directa de zmin con assert manual

## Scripts
- `crear_conejo_lowpoly.py` (v13 — Hy4 methodology, detalles pendientes)
- `conejo_v5_regenerar.py` (recupera el conejo v5 aprobado si se necesita rollback)

## Respaldo
GLB anterior: `assets/3d/media/Obsoletos/conejo_v5_aprobado_2026-09-04_23-36-40.glb`
