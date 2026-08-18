**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 50: Vegetación

## 1. Arquitectura

```
Assets/_Project/Vegetation/
├── catalog/                      (catálogo de especies)
│   ├── especies.tres             (26+ especies: malla, slots M47, biomas, params)
│   └── densidades_bioma.tres     (tabla bioma → especie → densidad/altura/pendiente)
├── generation/                   (placement determinista)
│   └── vegetation_placer.gd      (coloca instancias por chunk con PRNG M10)
├── runtime/                      (instancing y viento)
│   ├── vegetation_manager.gd     (manager global de MultiMesh por chunk)
│   ├── viento_shader.gdshader    (vertex shader de viento GPU)
│   └── vegetation_lod.gd         (LOD 2 niveles + culling)
├── interaction/                  (jugador y regeneración)
│   ├── tala_falling.gd           (caída de follaje tras tala M08)
│   ├── hierba_pisada.gd          (hierba flectada transitoria)
│   ├── recoleccion_flores.gd     (flores cosechables M33)
│   └── regeneracion.gd           (deltas y tiempos de mundo M29)
├── seasons/                      (estaciones M29)
│   └── season_vegetation.gd      (variantes de color con fade)
└── budget/                       (vegetation_budget.json)

Assets/_Project/Editor/
└── validate_vegetation.gd        (validador de densidad/LOD/presupuesto)
```

El `VegetationManager` genera las instancias al cargar un chunk (M10): consulta `especies.tres` + `densidades_bioma.tres`, las coloca con el PRNG de chunk, crea MultiMesh por especie y aplica el shader de viento y el LOD. El jugador (M13/M33) tal/cosecha vía M08 (tala voxel) o recolección; los cambios se guardan como deltas (M10/M60). Las estaciones (M29) tintan las instancias con fade. El validador corre en editor y CI (M118).

## 2. Diagramas de Flujo (texto)

### 2.1 Generación de vegetación de un chunk

```
chunk cargado (M10, semilla_chunk derivada)
  → vegetation_placer.gd:
    → 1) datos del bioma (M09): lista de especies + densidades
    → 2) filtros espaciales: pendiente <= max, altura dentro de rango,
         no en agua (M51), no en cueva; clamps de playa
    → 3) para cada especie: contar N = density × área; posicionar con
         PRNG(chunk, especie) → (x, z) e y = altura terreno + delta
    → 4) crear MultiMesh por especie × chunk (1 draw call por especie)
    → 5) aplicar shader viento con fase = hash(instancia, semilla_chunk)
    → 6) registrar en vegetation_budget.json (instancias, memoria)
```

### 2.2 Tala de un árbol (interacción M08)

```
jugador extrae bloque de tronco (M13/M08)
  → follaje superior entra en estado "cayendo" (1-2 s, tween determinista)
  → bloque de madera al inventario (M14/M15)
  → delta registrado (M10): tronco ausente; follaje desaparecido
  → regeneración: NINGUNA por estación; solo evento de juego (plantío M33)
     con reglas de genética (semilla → nuevo árbol joven)
  → validador: vegetación no vuelve a aparecer en posiciones delta
```

### 2.3 Cambio de estación (M29)

```
calendario Aurora (M29) emite ESTACION_CAMBIADA(estación)
  → season_vegetation.gd:
    → 1) por especie: paleta de estación (color tint)
    → 2) tween global de 5 s sobre el material compartido
    → 3) plantas de floración (primavera) activan meshes de flores;
       otoño: hojas amarillas; invierno: nieve opcional (M32)
    → 4) log VEG-SEASON
```

## 3. Tablas de Métricas (técnico)

### 3.1 Presupuesto de instancias (contra M61)

| Categoría | Instancias por chunk (max) | Draw calls | LOD |
|---|---|---|---|
| Hierba | 200 | 1 (MultiMesh) | LOD1 ~50% verts |
| Flores | 40 | 1 | LOD1 |
| Arbustos | 20 | 1 | LOD1 |
| Árboles (joven/grande/ancestral) | 8/4/1 | 1 × tipo | LOD1 |
| Palmeras / bambú / tropicales | 6 | 1 × tipo | LOD1 |
| Acuáticas / submarinas | 30 | 1 × tipo | LOD1 |
| Musgo (decals/mesh bajo) | 50 | 1 | — (proyección) |
| Enredaderas | 15 | 1 | LOD1 |
| Hongos | 12 | 1 | LOD1 |
| Luminosas | 8 | 1 | LOD1 |

- Instancias visibles máx por escena: 8.000 (preset medio M90).
- Culling: frustum + distancia (LOD switch 24 m, cull 40 m).
- Memoria VRAM por instancia: ≤ 64 bytes (transform + tint).

### 3.2 Viento (parámetros de shader)

| Parámetro | Valor base | Modulación |
|---|---|---|
| Amplitud | 0.02 m | bioma (jungla 0.01, pampa 0.035); viento fuerte ×1.5 (M32) |
| Frecuencia | 0.6 Hz | por especie (hierba 1.0, árbol 0.4) |
| Fase | hash(instancia, semilla_chunk) | determinista |
| Bloqueo en nieve | amplitud → 0.2 | invierno (M29/M32) |

### 3.3 Estaciones (paleta por especie)

| Estación | Tint | Extra |
|---|---|---|
| Primavera fértil | verdes frescos | floración (meshes de flores) |
| Verano | verdes saturados | — |
| Otoño | amarillos/marrones | hojas desprendidas optativas (M52) |
| Invierno | desaturado | nieve opcional (M32/M90) |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M08/M10 | Tala voxel, deltas, PRNG de chunk para placement |
| M09 | Biomas: especies + densidades + clamps de terreno |
| M45/M47 | Mallas y materiales de especies |
| M61/M62 | Presupuestos de instancias, draw calls, VRAM |
| M48 | Viento procedural (vertex shader de este módulo, contratado en M48) |
| M29 | Estaciones y tiempo de mundo para crecimiento |
| M33 | Agricultura: suelo plantable, cultivos; recolección de flores |
| M32 | Viento fuerte/yuvia/nieve modulando shader |
| M51 | Plantas acuáticas/submarinas contra agua |
| M52 | VFX de hojas desprendidas optativo |
| M108/M118 | Importación y validación en CI |