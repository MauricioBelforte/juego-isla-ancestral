**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 49: Iluminación

## 1. Arquitectura

```
Assets/_Project/Lighting/
├── presets/                      (configuración por franja/bioma)
│   ├── franjas_alba.tres · franjas_dia.tres · franjas_atardecer.tres
│   ├── franjas_noche.tres · franjas_profunda.tres
│   └── niebla_por_bioma.tres     (13 biomas M09)
├── profiles/                     (perfiles de escena: interior, templo, cueva, ruinas)
│   ├── interior_casa.gd
│   ├── interior_templo.gd
│   └── subterraneo.gd
├── dynamic/                      (pool de luces)
│   ├── light_pool.gd
│   └── luz_farol.gd · luz_fuego.gd · luz_cristal.gd    (flicker determinista)
├── budget/                       (lighting_budget.json)
└── materials/                    (sky_material.tres, environment.tres)

Assets/_Project/Editor/
└── validate_lighting.gd          (validador de escenas)

Assets/_Project/Services/
└── lighting_service.gd           (autoload: franja + clima + bioma → luces globales)
```

El `LightingService` consume la franja de M31 (GameClock) y el clima de M32 y aplica la configuración a la direccional, ambiente, niebla y cielo con easing (siempre transición suave). Los perfiles de escena (interior/templo/cueva) se activan al entrar (viajes M28, portales M26) y desactivan las luces globales cuando procede. Las luces dinámicas (faroles/fuego/cristales) vienen del pool con flicker determinista.

## 2. Diagramas de Flujo (texto)

### 2.1 Transición de franja horaria

```
GameClock (M31) emite FRANJA_CAMBIADA(nueva_franja)
  → LightingService:
    → cargar preset_franja(nueva) (direccional: elevacion, azimuth, color, intensidad;
       ambiente: color, intensidad; niebla: densidad, color)
    → easing de valores actuales → nuevos (3 s; sin snaps)
    → luz lunar: misma direccional con curva fría en NOCHE/PROFUNDA
    → verificar piso anti-oscuridad (ambiente >= 0.15)
    → logging LIT-FRANJA
```

### 2.2 Entrada a una cueva (perfil subterráneo)

```
jugador cruza portal/entrada (M24/M26/M25)
  → perfil subterraneo.gd activa:
    → direccional apagada; ambiente cálido 0.15-0.25 (esporas M11/M47)
    → niebla de cueva (resultado M32/M09)
    → luces puntuales fijas (horneadas si estático, pool si dinámico)
  → salida: restaura presets por franja con easing
  → sin luces por instancia del jugador (la linterna es luz de pool opcional M90)
```

### 2.3 Validación de una escena (validate_lighting.gd)

```
al cargar escena en editor (o CI M118):
  → contar OmniLight/SpotLight con shadows habilitadas → <= 6
  → contar luces dinámicas totales → <= 20 (pool)
  → mínimo ambiente de la escena (revisión de Environment) → >= 0.15
  → niebla en rango esperado según bioma/franja del registro
  → luces con flicker: amplitud <= max por M58
  → registrar en lighting_budget.json (luces, sombras, memoria M62)
  → emitir errores/warnings accionables
```

## 3. Tablas de Métricas (técnico)

### 3.1 Presets por franja (valores de referencia)

| Franja | Elevación sol | Color luz | Intensidad | Ambiente mínimo | Niebla (pueblo) |
|---|---|---|---|---|---|
| ALBA | 8° | 255, 214, 170 | 0.75 | 0.30 | 0.020 |
| DÍA | 45° | 255, 244, 214 | 1.0 | 0.35 | 0.010 |
| ATARDECER | 12° | 255, 168, 108 | 0.70 | 0.28 | 0.025 |
| NOCHE | -25° | 96, 118, 156 | 0.25 | 0.18 | 0.040 |
| PROFUNDA | -55° | 60, 72, 110 | 0.12 | 0.15 | 0.055 |

> Los valores exactos se calibran en implementación (M1) con el validador; son referencia para el artista.

### 3.2 Límites de luces y sombras

- Luces dinámicas con sombra por escena: ≤ 6.
- Luces dinámicas totales por escena: ≤ 20 (pool; descarte por distancia 30 m).
- Cascades de sombra direccional: ≤ 4 (preset bajo: 2, medio: 3, alto: 4 — M90).
- Resolución de shadow atlas: 1024 (bajo/medio), 2048 (alto).
- Bias del voxel: shadow_bias 0.005-0.01, normal_bias 0.4 (calibrar; sin acne).
- Distancia máxima de sombras dinámicas: 45 m (bajo: 25 m — M90).
- Flicker: frecuencia ≤ 2 Hz, amplitud ≤ 15% intensidad (M58).

### 3.3 Perfiles de escena (ligth budgets por tipo)

| Perfil | Ambiente | Luces dinámicas | Sombras | Baked |
|---|---|---|---|---|
| Exterior pueblo | por franja | ≤ 12 (faroles pool) | direccional | NO |
| Exterior campo | por franja | ≤ 4 | direccional | NO |
| Interior casa | 0.30 cálido | ≤ 3 | puntuales ≤ 2 | SÍ (lightmap estático) |
| Templo / Ruinas | 0.25 | ≤ 6 | puntuales ≤ 3 | SÍ (grandes salas) |
| Cueva | 0.15-0.25 | ≤ 8 (esporas/faroles) | puntuales ≤ 4 | SÍ donde estático |
| Submarino | azulado 0.30 | ≤ 6 | luz direccional atenuada | NO |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M31 | Franjas horarias → presets de luz/niebla con easing |
| M32 | Clima (lluvia dim solar, niebla) |
| M09 | Sky procedural por bioma + niebla del bioma |
| M08/M10 | Meshes del mundo (sombras, baked) |
| M18/M24/M25/M26 | Perfiles de interior/templo/ruinas/cueva con lightmap |
| M47 | Materiales luminosos (emisión de cristales/glifos) |
| M11 | Esporas de luz en cuevas |
| M52 | Partículas de fuego + luz asociada |
| M61/M62 | Presupuestos de luces/sombras/memoria |
| M90 | Presets de calidad y opciones de luces/faroles |
| M58 | Flicker suave y desactivación por fotosensibilidad |
| M108/M118 | Importación y bake en CI |