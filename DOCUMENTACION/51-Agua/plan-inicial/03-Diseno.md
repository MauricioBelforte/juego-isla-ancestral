**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 51: Agua

## 1. Arquitectura

```
Assets/_Project/Water/
├── types/                        (config por tipo de agua)
│   ├── agua_oceano.tres · agua_rio.tres · agua_lago.tres
│   ├── agua_cascada.tres · agua_subterranea.tres
│   ├── agua_hielo.tres · agua_termal.tres
├── ocean/                        (render del océano)
│   ├── ocean_mesh.gd             (mesh por chunk, LOD, culling)
│   └── olas.gd                   (fase fija + semilla por cuerpo)
├── river/                        (ríos y corrientes)
│   ├── river_spline.gd           (spline de M10 → flujo)
│   └── current.gd                (mueve objetos M70 y barcos M28/M67)
├── state/                        (estados del agua)
│   ├── water_state.gd            (nivel por cuerpo: inundación/drenaje/evaporación)
│   ├── hielo.gd                  (congelamiento estacional M29/M32 + anti-softlock M66)
│   └── cascada.gd                (VF de caída + partículas M52 + sonido M42)
├── physics/                      (colisiones y flotación)
│   └── water_surface.gd          (plano físico por chunk: flotación M11/M70)
└── budget/                       (water_budget.json)

Assets/_Project/Editor/
└── validate_water.gd             (validador: nivel de mar, presupuesto, determinismo)
```

El océano es un mesh por chunk (M10) que comparte el shader de agua (M47 `agua.gdshader`) con parámetros del tipo. Los ríos vienen de splines de M10 y las corrientes afectan a M70 (objetos) y M28/M67 (barcos). El estado del agua (nivel, hielo, cascadas) lo consume M31/M32 (clima/estación) y los puzzles de M24 (compuertas). El `WaterSurface` da la física de flotación a M11 (natación) y M70 (objetos).

## 2. Diagramas de Flujo (texto)

### 2.1 Generación de un chunk de océano

```
chunk costero cargado (M10)
  → ocean_mesh.gd:
    → 1) nivel de mar global (semilla M09) → Y del plano
    → 2) mesh de agua del chunk (cuadricula con segmentos según LOD:
         lejos plano sin olas, cerca con detalle)
    → 3) shader (M47): olas con fase = hash(cuerpo, semilla_chunk),
         espuma donde altura de ola supera altura de costa
    → 4) physics: WaterSurface (plano estático por chunk)
    → 5) registrar en water_budget.json (verts, overdraw estimado)
```

### 2.2 Congelamiento estacional (invierno)

```
ESTACION_CAMBIADA(invierno) (M29) + clima bajo cero (M32)
  → hielo.gd:
    → 1) cuerpos congelables (lago/rio/zona termal NO) entran
         en transición (fade 10 s) a superficie congelada
    → 2) hielo caminable: collider sólido + crujido de sonido (M42)
    → 3) límites anti-softlock: el hielo NUNCA cubre salidas de
         puzzles ni zonas de progresión (M66); se derrite con
         antorcha (M13) o al subir la temperatura (M32)
    → 4) log WATER-HIELO
```

### 2.3 Puzzle de compuerta (inundación/drenaje M24)

```
jugador activa palanca de compuerta (M24)
  → water_state.gd:
    → 1) nivel objetivo del cuerpo = config del puzzle
    → 2) llenar/vaciar con easing (determinista, 5-10 s)
    → 3) olas/espuma actualizan según nivel; corrientes cambian
    → 4) fauna (M36/M65) y barcos (M28) reaccionan al nivel
    → 5) log WATER-PUZZLE
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
- ReflectionProbe por escena: ≤ 2 (solo lagos/vitrinas).
- Refracción: solo pools de puzzles M24 (≤ 2 por escena).
- Overdraw de transparencia: ≤ 1.5× pantalla en escena pivote.
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