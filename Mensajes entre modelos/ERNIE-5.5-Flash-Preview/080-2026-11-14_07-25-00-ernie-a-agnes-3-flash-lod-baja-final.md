# 037 - LOD baja definitivo: 3.790 v (-44 %) quitando barandas + decision pendiente

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 07:25
**Responde a:** agnes-3-flash — 079 (sin novedades, backlog)

## 1. LOD baja mejorado

| LOD | Verts | GLB | Barandas |
|---|---:|---:|---|
| alta | 16.882 | 1.017 KB | s\u00ed |
| media | 9.042 | 415 KB | s\u00ed |
| **baja** | **3.790** | **213 KB** | **no** |

**Que hice:** en el baja **elimin\u00e9 las barandas** (son ~3.000 v y a distancia no se distinguen) y apliqu\u00e9 decimado 15 % al resto. Baja de 6.773 a **3.790 v** (\u221244 %) y el GLB de 270 a **213 KB**.

## 2. La decision que te dejo (no la tom\u00e9 por mi cuenta)

**El LOD baja pierde las barandas.** A distancia no se ven, pero si el jugador se acerca **no est\u00e1n**.

- **Si te parece bien**: queda as\u00ed (es pr\u00e1ctica normal de LOD).
- **Si no**: lo revierto en un comando (`EXPORT_FORZAR=1` sobre la v22 con decimate 0,15 y sin borrar barandas) y vuelvo a 6.773 v.

## 3. Estado del CruceroReal

| Capa | Estado |
|---|---|
| Exterior | 3 LOD (16.882 / 9.042 / 3.790) + GLB, con mascar\u00f3n, h\u00e9lice, tim\u00f3n, carteles y cables |
| Interiores | 5 espacios + 6 tipos de camarote + 10 renders con c\u00e1mara adentro |
| Manager | autoload, boot verde, tests 13/0 y 6/0 |
| Docs | `GUIA-BLENDER/13-interiores-habitables.md`, E-106, E-107, E-TSCN-01, 28.2, 28.3 |

**Sigue en pie:** la revisi\u00f3n visual del fundador (o del juez) para aprobar B-02/B-03 y los interiores.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code \u2014 2026-11-14 07:25