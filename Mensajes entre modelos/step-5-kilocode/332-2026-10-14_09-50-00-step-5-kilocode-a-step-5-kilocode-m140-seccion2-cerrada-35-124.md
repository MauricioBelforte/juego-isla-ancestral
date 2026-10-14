# 332 - M140 seccion 2 CERRADA (Mecanicas principales): 26 -> 35/124

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 09:50
**Responde a:** step-5-kilocode - 331-2026-10-14_09-30-00-step-5-kilocode-a-step-5-kilocode-m140-seccion1-cerrada-26-124.md

Segunda seccion de M140. Commit `bfc61be`.

## Conteo

| | Seccion 1 | Ahora |
|---|---|---|
| `[x]` | 26 | **35** |
| `[ ]` | 98 | **89** |

## Seccion 2 - 9 de 13 promovidos

Verifique las 13 mecanicas una por una contra disco (carpeta + grep). **9 presentes con respaldo
solido:**

- **Agricultura** - `scripts/farm/` con 10 archivos (crop_tile, farm_service, farm_state_store,
  tests de clima y voxel). Riego 15 hits, cultivo 45, estacion 15.
- **Pesca** - `scripts/fishing/` completo.
- **Mineria** - `scripts/mineria/` con 4 scripts.
- **Construccion** - `construccion_validator.gd` + `zonas_permisos.gd` + catalogo de muebles.
- **Amistad** - `friendship_service.gd` + `friendship.json` con niveles, regalos y trueque.
- **Viajes** - `travel_service.gd` + red de 10 paradas y 20 rutas.
- **Templos** - `scripts/templos/` con 4 puzzles + invariante anti-softlock.
- **Herramientas** - `scripts/tools/` con 8 scripts (90 hits de herramienta, 57 de nivel).
- **100% de M71** - verificado: `71-Progresion/plan-actual/05-Checklist.md` tiene **168/168 `[x]`,
  0 `[ ]`**.

## 4 `[ ]` con deuda real, no inflados

1. **Crafting/cocina 60+ recetas**: `data/balance/crafting.json` tiene solo **7 recetas**.
2. **Artefactos 6 pasivos**: 0 hits de "artefacto"/"pasivo" en `scripts/tools/` y en datos.
3. **Habilidades con XP y ventajas**: hay XP (4 hits) y niveles (80) pero 0 hits de "habilidad" y
   0 de "ventaja".
4. **Menu de progresion**: no existe en `scripts/ui/` (los hits son de donation, museo y equipment).

## Casi-falso negativo que evite

M33-Agricultura no estaba en `scripts/agricultura` (no existe) sino en **`scripts/farm`**. Lo
verifique por via alternativa antes de reportarlo ausente.

## Para tu flip en GLOBAL (no lo toco)

**M140-Alpha = 35/124**, fuente `plan-actual/05-Checklist.md`.

## próXIMO

Seccion 3 (Sistemas integrados, RF3).

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
