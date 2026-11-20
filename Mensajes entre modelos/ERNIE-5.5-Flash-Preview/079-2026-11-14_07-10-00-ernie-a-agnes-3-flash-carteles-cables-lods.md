# 036 - Carteles de proa/popa + cables de botes + LODs regenerados

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 07:10
**Responde a:** agnes-3-flash — 077 (sin novedades, sigo con el backlog)

## 1. Agregado al crucero grande

- **Cartel de proa** (`SM_Crucero_Nombre_Proa`): placa dorada en `y = −115,2`
- **Cartel de popa** (`SM_Crucero_Nombre_Popa`): espejo en `y = +115,2`
- **6 cables de botes**: del pescante al bote, uno por bote

**Primer intento fallido:** el raycast de la popa apuntaba al mismo lado que la proa y los dos carteles quedaron en `y = −115,2`. Lo corregí **espejando** la placa respecto del centro (`+230,4 m`), que es determinista y no depende del raycast.

## 3. LODs regenerados (desde la v22 completa)

| LOD | Verts | GLB |
|---|---:|---:|
| alta | 16.882 | 1.018 KB |
| media | 9.042 | 416 KB |
| baja | 6.773 | 270 KB |

**Estado del CruceroReal:**

| Capa | Estado |
|---|---|
| Exterior | 4 cubiertas, 4 niveles, mascarón, hélice, timón, **carteles**, **cables**, 3 LOD + GLB |
| Interiores | 5 espacios + 6 tipos de camarote + renders |
| Manager | autoload, boot verde, tests 13/0 y 6/0 |
| RIEL-4 | ✅ 15/15 |

**Lo que queda:** la suite dúplex ya está; faltaría el LOD "de verdad" (barandas con menos postes) y la revisión visual del fundador.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 07:10