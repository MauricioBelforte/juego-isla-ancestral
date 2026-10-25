**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 51: Agua

## 1. Arquitectura

```
Assets/_Project/Water/
â”œâ”€â”€ types/                        (config por tipo de agua)
â”‚   â”œâ”€â”€ agua_oceano.tres Â· agua_rio.tres Â· agua_lago.tres
â”‚   â”œâ”€â”€ agua_cascada.tres Â· agua_subterranea.tres
â”‚   â”œâ”€â”€ agua_hielo.tres Â· agua_termal.tres
â”œâ”€â”€ ocean/                        (render del ocÃ©ano)
â”‚   â”œâ”€â”€ ocean_mesh.gd             (mesh por chunk, LOD, culling)
â”‚   â””â”€â”€ olas.gd                   (fase fija + semilla por cuerpo)
â”œâ”€â”€ river/                        (rÃ­os y corrientes)
â”‚   â”œâ”€â”€ river_spline.gd           (spline de M10 â†’ flujo)
â”‚   â””â”€â”€ current.gd                (mueve objetos M70 y barcos M28/M67)
â”œâ”€â”€ state/                        (estados del agua)
â”‚   â”œâ”€â”€ water_state.gd            (nivel por cuerpo: inundaciÃ³n/drenaje/evaporaciÃ³n)
â”‚   â”œâ”€â”€ hielo.gd                  (congelamiento estacional M29/M32 + anti-softlock M66)
â”‚   â””â”€â”€ cascada.gd                (VF de caÃ­da + partÃ­culas M52 + sonido M42)
â”œâ”€â”€ physics/                      (colisiones y flotaciÃ³n)
â”‚   â””â”€â”€ water_surface.gd          (plano fÃ­sico por chunk: flotaciÃ³n M11/M70)
â””â”€â”€ budget/                       (water_budget.json)

Assets/_Project/Editor/
â””â”€â”€ validate_water.gd             (validador: nivel de mar, presupuesto, determinismo)
```

El ocÃ©ano es un mesh por chunk (M10) que comparte el shader de agua (M47 `agua.gdshader`) con parÃ¡metros del tipo. Los rÃ­os vienen de splines de M10 y las corrientes afectan a M70 (objetos) y M28/M67 (barcos). El estado del agua (nivel, hielo, cascadas) lo consume M31/M32 (clima/estaciÃ³n) y los puzzles de M24 (compuertas). El `WaterSurface` da la fÃ­sica de flotaciÃ³n a M11 (nataciÃ³n) y M70 (objetos).

## 2. Diagramas de Flujo (texto)

### 2.1 GeneraciÃ³n de un chunk de ocÃ©ano

```
chunk costero cargado (M10)
  â†’ ocean_mesh.gd:
    â†’ 1) nivel de mar global (semilla M09) â†’ Y del plano
    â†’ 2) mesh de agua del chunk (cuadricula con segmentos segÃºn LOD:
         lejos plano sin olas, cerca con detalle)
    â†’ 3) shader (M47): olas con fase = hash(cuerpo, semilla_chunk),
         espuma donde altura de ola supera altura de costa
    â†’ 4) physics: WaterSurface (plano estÃ¡tico por chunk)
    â†’ 5) registrar en water_budget.json (verts, overdraw estimado)
```

### 2.2 Congelamiento estacional (invierno)

```
ESTACION_CAMBIADA(invierno) (M29) + clima bajo cero (M32)
  â†’ hielo.gd:
    â†’ 1) cuerpos congelables (lago/rio/zona termal NO) entran
         en transiciÃ³n (fade 10 s) a superficie congelada
    â†’ 2) hielo caminable: collider sÃ³lido + crujido de sonido (M42)
    â†’ 3) lÃ­mites anti-softlock: el hielo NUNCA cubre salidas de
         puzzles ni zonas de progresiÃ³n (M66); se derrite con
         antorcha (M13) o al subir la temperatura (M32)
    â†’ 4) log WATER-HIELO
```

### 2.3 Puzzle de compuerta (inundaciÃ³n/drenaje M24)

```
jugador activa palanca de compuerta (M24)
  â†’ water_state.gd:
    â†’ 1) nivel objetivo del cuerpo = config del puzzle
    â†’ 2) llenar/vaciar con easing (determinista, 5-10 s)
    â†’ 3) olas/espuma actualizan segÃºn nivel; corrientes cambian
    â†’ 4) fauna (M36/M65) y barcos (M28) reaccionan al nivel
    â†’ 5) log WATER-PUZZLE
```

## 3. Tablas de MÃ©tricas (tÃ©cnico)

### 3.1 Tipos de agua (parÃ¡metros de shader M47)

| Tipo | Color | Opacidad | Olas | Espuma | Flujo |
|---|---|---|---|---|---|
| OcÃ©ano | azul bioma | 0.85 | alta | costa | n/a |
| RÃ­o | verde-azul | 0.90 | baja | orillas | direccional (spline) |
| Lago | azul profundo | 0.90 | media | orillas | n/a |
| Cascada | blanca | 0.80 | n/a | base | caÃ­da |
| SubterrÃ¡nea | azul oscuro | 0.95 | 0 | n/a | estÃ¡tica |
| Hielo | celeste | 0.70 | 0 | n/a | sÃ³lido |
| Termal | turquesa | 0.85 | baja | n/a | estÃ¡tica |

### 3.2 Presupuesto de render (contra M61)

- Verts de ocÃ©ano por chunk: â‰¤ 2.000 (LOD lejano 100).
- ReflectionProbe por escena: â‰¤ 2 (solo lagos/vitrinas).
- RefracciÃ³n: solo pools de puzzles M24 (â‰¤ 2 por escena).
- Overdraw de transparencia: â‰¤ 1.5Ã— pantalla en escena pivote.
- Nivel de mar: valor global; tolerancia de consistencia Â± 0.01 m entre chunks.

### 3.3 FÃ­sica de flotaciÃ³n

- Superficie de agua: plano fÃ­sico (colisiÃ³n) por chunk.
- Jugador (M11): flota con inmersiÃ³n visual 0.8 m, sprint en agua Ã—1.2 stamina (M11).
- Objetos sueltos (M70): flotan si densidad < 1 (deltas de M10).
- Barcos (M28/M67): 90% del casco sobre superficie, deriva por corriente (0.3 m/s mÃ¡x cozy).
- Hielo: caminable con lÃ­mites de tiempo (M31) y zonas de salida (M66).

## 4. Integraciones Clave

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M08/M10 | Bloques de agua, nivel de mar, splines de rÃ­o, deltas |
| M09 | Nivel del mar global, biomas costeros |
| M47 | Shader de agua (agua.gdshader) |
| M11 | NataciÃ³n: flotaciÃ³n, sprint, chapoteo |
| M13/M15/M33 | Balde, botella, riego (agua como Ã­tem M14) |
| M24 | Puzzles: compuertas, canales, refracciÃ³n de pools |
| M28/M67 | Barcos: flotabilidad, deriva, olas |
| M36/M65 | Fauna acuÃ¡tica |
| M29/M32 | Congelamiento, inundaciÃ³n, evaporaciÃ³n estacional/climÃ¡tica |
| M31 | Hielo con lÃ­mites de tiempo |
| M42/M44 | Sonidos de agua y feedback |
| M52 | Salpicaduras, rocÃ­o, gotas |
| M61/M62 | Presupuesto de render y memoria |
| M66 | Anti-softlock del hielo |
| M70 | Objetos flotantes |
| M108/M118 | ImportaciÃ³n y validaciÃ³n en CI |
## Specs Agua (Beam 507)

### Reflejo de escena real (SSR/planos reflejo)
- Spec: reflejo de escena real (SSR/planos reflejo) — necesita presupuesto de rendering, próxima iteración. Coherente con M51 (agua) y M45/M47/M49 (shaders/iluminación).