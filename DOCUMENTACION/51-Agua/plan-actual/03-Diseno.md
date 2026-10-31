**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 51: Agua

## 1. Arquitectura

```
Assets/_Project/Water/
â”œâ”€â”€ types/                        (config por tipo de agua)
│   ├── agua_oceano.tres · agua_rio.tres · agua_lago.tres
│   ├── agua_cascada.tres · agua_subterranea.tres
│   ├── agua_hielo.tres · agua_termal.tres
├── ocean/                        (render del océano)
â”‚   â”œâ”€â”€ ocean_mesh.gd             (mesh por chunk, LOD, culling)
â”‚   â””â”€â”€ olas.gd                   (fase fija + semilla por cuerpo)
├── river/                        (ríos y corrientes)
â”‚   â”œâ”€â”€ river_spline.gd           (spline de M10 â†’ flujo)
â”‚   â””â”€â”€ current.gd                (mueve objetos M70 y barcos M28/M67)
â”œâ”€â”€ state/                        (estados del agua)
│   ├── water_state.gd            (nivel por cuerpo: inundación/drenaje/evaporación)
â”‚   â”œâ”€â”€ hielo.gd                  (congelamiento estacional M29/M32 + anti-softlock M66)
│   └── cascada.gd                (VF de caída + partículas M52 + sonido M42)
├── physics/                      (colisiones y flotación)
│   └── water_surface.gd          (plano físico por chunk: flotación M11/M70)
â””â”€â”€ budget/                       (water_budget.json)

Assets/_Project/Editor/
â””â”€â”€ validate_water.gd             (validador: nivel de mar, presupuesto, determinismo)
```

El océano es un mesh por chunk (M10) que comparte el shader de agua (M47 `agua.gdshader`) con parámetros del tipo. Los ríos vienen de splines de M10 y las corrientes afectan a M70 (objetos) y M28/M67 (barcos). El estado del agua (nivel, hielo, cascadas) lo consume M31/M32 (clima/estación) y los puzzles de M24 (compuertas). El `WaterSurface` da la física de flotación a M11 (natación) y M70 (objetos).

## 2. Diagramas de Flujo (texto)

### 2.1 Generación de un chunk de océano

```
chunk costero cargado (M10)
  â†’ ocean_mesh.gd:
    â†’ 1) nivel de mar global (semilla M09) â†’ Y del plano
    → 2) mesh de agua del chunk (cuadricula con segmentos según LOD:
         lejos plano sin olas, cerca con detalle)
    â†’ 3) shader (M47): olas con fase = hash(cuerpo, semilla_chunk),
         espuma donde altura de ola supera altura de costa
    → 4) physics: WaterSurface (plano estático por chunk)
    â†’ 5) registrar en water_budget.json (verts, overdraw estimado)
```

### 2.2 Congelamiento estacional (invierno)

```
ESTACION_CAMBIADA(invierno) (M29) + clima bajo cero (M32)
  â†’ hielo.gd:
    â†’ 1) cuerpos congelables (lago/rio/zona termal NO) entran
         en transición (fade 10 s) a superficie congelada
    → 2) hielo caminable: collider sólido + crujido de sonido (M42)
    → 3) límites anti-softlock: el hielo NUNCA cubre salidas de
         puzzles ni zonas de progresión (M66); se derrite con
         antorcha (M13) o al subir la temperatura (M32)
    â†’ 4) log WATER-HIELO
```

### 2.3 Puzzle de compuerta (inundación/drenaje M24)

```
jugador activa palanca de compuerta (M24)
  â†’ water_state.gd:
    â†’ 1) nivel objetivo del cuerpo = config del puzzle
    â†’ 2) llenar/vaciar con easing (determinista, 5-10 s)
    → 3) olas/espuma actualizan según nivel; corrientes cambian
    â†’ 4) fauna (M36/M65) y barcos (M28) reaccionan al nivel
    â†’ 5) log WATER-PUZZLE
```

## 3. Tablas de Métricas (técnico)

### 3.1 Tipos de agua (parámetros de shader M47)

| Tipo | Color | Opacidad | Olas | Espuma | Flujo |
|---|---|---|---|---|---|
| Océano | azul bioma | 0.85 | alta | costa | n/a |
| Río | verde-azul | 0.90 | baja | orillas | direccional (spline) |
| Lago | azul profundo | 0.90 | media | orillas | n/a |
| Cascada | blanca | 0.80 | n/a | base | caída |
| Subterránea | azul oscuro | 0.95 | 0 | n/a | estática |
| Hielo | celeste | 0.70 | 0 | n/a | sólido |
| Termal | turquesa | 0.85 | baja | n/a | estática |

### 3.2 Presupuesto de render (contra M61)

- Verts de océano por chunk: ≤ 2.000 (LOD lejano 100).
- ReflectionProbe por escena: â‰¤ 2 (solo lagos/vitrinas).
- Refracción: solo pools de puzzles M24 (≤ 2 por escena).
- Overdraw de transparencia: â‰¤ 1.5Ã— pantalla en escena pivote.
- Nivel de mar: valor global; tolerancia de consistencia ± 0.01 m entre chunks.

### 3.3 Física de flotación

- Superficie de agua: plano físico (colisión) por chunk.
- Jugador (M11): flota con inmersión visual 0.8 m, sprint en agua ×1.2 stamina (M11).
- Objetos sueltos (M70): flotan si densidad < 1 (deltas de M10).
- Barcos (M28/M67): 90% del casco sobre superficie, deriva por corriente (0.3 m/s máx cozy).
- Hielo: caminable con límites de tiempo (M31) y zonas de salida (M66).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M08/M10 | Bloques de agua, nivel de mar, splines de río, deltas |
| M09 | Nivel del mar global, biomas costeros |
| M47 | Shader de agua (agua.gdshader) |
| M11 | Natación: flotación, sprint, chapoteo |
| M13/M15/M33 | Balde, botella, riego (agua como ítem M14) |
| M24 | Puzzles: compuertas, canales, refracción de pools |
| M28/M67 | Barcos: flotabilidad, deriva, olas |
| M36/M65 | Fauna acuática |
| M29/M32 | Congelamiento, inundación, evaporación estacional/climática |
| M31 | Hielo con límites de tiempo |
| M42/M44 | Sonidos de agua y feedback |
| M52 | Salpicaduras, rocío, gotas |
| M61/M62 | Presupuesto de render y memoria |
| M66 | Anti-softlock del hielo |
| M70 | Objetos flotantes |
| M108/M118 | Importación y validación en CI |
## Specs Agua (Beam 507)

### Reflejo de escena real (SSR/planos reflejo)
- Spec: reflejo de escena real (SSR/planos reflejo) — necesita presupuesto de rendering, próxima iteración. Coherente con M51 (agua) y M45/M47/M49 (shaders/iluminación).

## Specs Agua (Beam 688)

### Definir olas GPU con fase fija por cuerpo
- Spec: definir olas GPU con fase fija por cuerpo. Coherente with M51 (agua) and M47 (shaders).

### Definir espuma costera (altura de ola vs costa)
- Spec: definir espuma costera (altura de ola vs costa). Coherente with M51 (agua) and M47 (shaders).

### Definir transparencia con depth_prepass
- Spec: definir transparencia con depth_prepass. Coherente with M51 (agua) and M47 (shaders).

### Definir ReflectionProbe <= 2 por escena
- Spec: definir ReflectionProbe <= 2 por escena. Coherente with M51 (agua) and M49 (iluminacion).

### Definir partículas en base (M52)
- Spec: definir particulas en base (M52). Coherente with M51 (agua) and M52 (particulas).


## Specs Agua (Beam 689)

### Definir olas por bioma/franja (M42)
- Spec: definir olas por bioma/franja (M42). Coherente with M51 (agua) and M42 (sonido ambiental).

### Definir cascada en loop
- Spec: definir cascada en loop. Coherente with M51 (agua) and M42 (sonido ambiental).

### Definir salpicaduras de pies
- Spec: definir salpicaduras de pies. Coherente with M51 (agua) and M52 (particulas).

### Definir rocio de cascada
- Spec: definir rocio de cascada. Coherente with M51 (agua) and M52 (particulas).

### Definir gotas al salir del agua
- Spec: definir gotas al salir del agua. Coherente with M51 (agua) and M52 (particulas).


## Specs Agua (Beam 690)

### Nivel de mar consistente entre chunks
- Spec: nivel de mar consistente entre chunks. Coherente with M51 (agua) and M08 (terreno).

### Ocean con olas/espuma dentro del presupuesto
- Spec: ocean con olas/espuma dentro del presupuesto. Coherente with M51 (agua) and M61 (rendimiento).

### Hielo solo estacional y sin softlock
- Spec: hielo solo estacional y sin softlock. Coherente with M51 (agua) and M32 (clima).


## Specs Agua (Beam 691)

### Interaccion de olas con la fauna (barcos/estaciones)
- Spec: interaccion de olas con la fauna (barcos/estaciones). Coherente with M51 (agua) and M36 (fauna).
