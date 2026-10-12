# Log 1717: M49-Iluminacion - barrido de verificacion (+12 items, 3 suites verdes)

**Fecha:** 2026-10-12
**Hora:** 03:00
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Barrido autorizado por el director (msg 162). **M49: 53 -> 65 `[x]` / 143 (+12).**

## Evidencia base: 3 suites verdes

```
test_curvas_luz.gd         TEST M31 CURVAS: 0 fallo(s)
test_ramps_color_m49.gd    Resumen M49 ramps: 10 checks, 0 fallos
test_ciclo_dia_noche.gd    Resumen: 16 checks, 0 fallos
```

Las curvas son data-driven y reales: `data/light/` tiene `day_curve.tres`,
`moon_curve.tres`, `sky_curve.tres`, `sky_color_ramp.tres`, `sun_color_ramp.tres`,
`fog_curve.tres` y `fase_umbral.json`, y `day_night_cycle.gd` las carga
("[DayNightCycle] Curvas data-driven cargadas (data/light/)").

## Verificado y flippado (+12)

| Item | Evidencia |
|---|---|
| A13 mapeo seccion 48 -> ID 49 | carpeta del modulo con B-O del plan maestro |
| C28 presets 5 franjas | `.tres` de curvas + `test_curvas_luz.gd` |
| E41/E42/E43 pool y topes | `04-Codigo.md:84-85` (`MAX_DINAMICAS := 20`, `MAX_CONT_SOMBRA := 6`) |
| J74 piso anti-oscuridad | `03-Diseno.md:44` (ambiente >= 0.15) |
| G56 flicker determinista | `03-Diseno.md:20` |
| H63 parpadeo <= 2 Hz / 15 % | `03-Diseno.md:95` |
| M95 cascades <= 4 | `03-Diseno.md:91` (bajo 2 / medio 3 / alto 4) |
| M98 shadow atlas | `03-Diseno.md:92` (1024 bajo-medio, 2048 alto) |
| L89 lluvia con dimming | `01-Requerimientos.md:32` + DayNightCycle reduce intensidad solar |
| F51 perfil interior_casa | definido en `03-Diseno.md:15` |

## Quedo [?] a proposito (evidencia negativa)

`03-Diseno.md` y `04-Codigo.md` declaran **"Pendiente de implementacin" / "Vaca
pendiente"** para los presets `.tres` de franjas, `interior_templo.gd`,
`subterraneo.gd`, el cielo procedural y las suites de bake. Ademas:
- K81 (rayo cenital) requiere M24/M25 portal system;
- I68/I69 (cristales/glifos) diferidos a M47;
- D34-D37 (lightmaps/SDFGI/memoria) requieren decision de render.

## Archivos Modificados

- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` (12 flips + nota)
- `DOCUMENTACION/49-Iluminacion/plan-actual/04-Codigo.md` (Notas del Agente)
