**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 52: Partículas y VFX

## 1. Arquitectura

```
Assets/_Project/VFX/
├── catalog/                        (catálogo central de efectos)
│   └── vfx_catalog.tres            (25+ efectos: tipo, material, emisor, presupuesto)
├── emitters/                       (escenas de emisores reutilizables)
│   ├── humo_chimenea.tscn · polvo_mina.tscn · hojas_viento.tscn
│   ├── pétalos_primavera.tscn · chispas_forja.tscn
│   ├── salpicadura_agua.tscn · lluvia.tscn · nieve.tscn
│   ├── fuego_hoguera.tscn · lava_ascuas.tscn
│   ├── runa_resonancia.tscn · sello_obtenido.tscn · puzzle_resuelto.tscn
│   ├── construccion_espuma.tscn · cosecha_estelas.tscn · pesca_burbujas.tscn
│   └── descubrimiento_glow.tscn · transicion_estacion.tscn
├── systems/                        (managers)
│   ├── vfx_manager.gd              (autoload: pool, catálogo, presupuesto)
│   ├── vfx_trigger.gd              (punto único: VFX + SFX + feedback)
│   └── vfx_atmospheric.gd          (lluvia/nieve/polvo por M32/M29)
├── ui/                             (VFX 2D para M53)
│   └── ui_vfx.gd                   (partículas 2D con Reduce Motion M58)
└── budget/                         (vfx_budget.json)

Assets/_Project/Editor/
└── validate_vfx.gd                 (validador: presupuesto, naming, determinismo)
```

El `VfxManager` (autoload) carga el catálogo, mantiene el pool de emisores (precalentados), respeta el presupuesto por escena y aplica `vfx_quality` (M58). Los triggers (minado M13, cosecha M33, runas M24, Sello M22...) llaman a `VfxTrigger.emitir(efecto, pos)` que dispara el emisor + sonido (M43) + feedback (M44) en el mismo frame. Los atmosféricos (M32/M29) los controla `vfx_atmospheric.gd` a nivel global (uno por bioma/clima, no por chunk).

## 2. Diagramas de Flujo (texto)

### 2.1 Emisión de un efecto one-shot

```
evento de juego (ej: resolver puzzle M24 → runas)
  → VfxTrigger.emitir("runas_resonancia", pos)
    → 1) vfx_manager: ¿presupuesto libre? (emisores activos < 12)
         no → log VFX-SKIP (sin romper el momento: se degrada a glow)
    → 2) tomar emisor del pool (precalentado)
    → 3) semilla = hash(seed_contexto M10, tipo, contador)
    → 4) reproducir one-shot (duración del efecto)
    → 5) al terminar → devolver al pool
    → 6) en paralelo: sonido (M43) y feedback (M44) desde el mismo trigger
    → 7) log VFX-PLAY
```

### 2.2 Loop ambiental (humo de chimenea)

```
casa cargada (M18) con chimenea encendida (M17)
  → registrar loop en vfx_manager (emisor activo)
  → cada frame: si distancia > 40 m → pausar; si < 30 m → reanudar (LOD)
  → fase de humo = TIME * velocidad + semilla del emisor (determinista)
  → la LUZ de la hoguera la emite M49 (pool), nunca la partícula
```

### 2.3 Clima y estaciones (atmosféricos)

```
CLIMA_CAMBIADO(lluvia) (M32) → vfx_atmospheric.activar("lluvia", bioma)
  → un solo emisor global de lluvia por zona activa (no por chunk)
  → ESTACION_CAMBIADA(primavera) (M29) → pétalos en zonas de floración
  → ESTACION_CAMBIADA(otoño) → hojas de los árboles (M50)
  → M58 reduce/off: se atenúa o desactiva visualmente (sin tocar gameplay)
```

## 3. Tablas de Métricas (técnico)

### 3.1 Catálogo de efectos (resumen de presupuesto)

| Efecto | Tipo | Partículas máx | Emisor | Notas |
|---|---|---|---|---|
| Humo chimenea | loop | 24 | GPUParticles3D | fase fija |
| Polvo de mina | one-shot | 60 | GPUParticles3D | semilla M10 |
| Hojas viento | loop | 40 | GPUParticles3D | viento M50 |
| Pétalos primavera | loop | 40 | GPUParticles3D | estación M29 |
| Chispas forja | one-shot | 80 | GPUParticles3D | M13/M38 |
| Salpicadura agua | one-shot | 40 | GPUParticles3D | M51/M11 |
| Lluvia | loop global | 1.000 | GPUParticles3D | M32 |
| Nieve | loop global | 800 | GPUParticles3D | M32/M29 |
| Fuego hoguera | loop | 120 | GPUParticles3D | luz = M49 |
| Lava ascuas | loop | 80 | GPUParticles3D | biomas volcánicos |
| Runa resonancia | one-shot | 100 | GPUParticles3D | M24 |
| Sello obtenido | one-shot | 200 | GPUParticles3D | M22, evento clave |
| Puzzle resuelto | one-shot | 120 | GPUParticles3D | M24 |
| Construcción | one-shot | 60 | GPUParticles3D | M17 |
| Cosecha | one-shot | 40 | GPUParticles3D | M33 |
| Pesca | one-shot | 50 | GPUParticles3D | M34 |
| Descubrimiento | one-shot | 80 | GPUParticles3D | M71 |
| Transición estacional | one-shot | 150 | GPUParticles3D | M29 |
| UI (recompensas) | one-shot 2D | 60 | GPUParticles2D | M53/M58 |

### 3.2 Presupuesto por escena (contra M61)

- Emisores activos por escena: ≤ 12 (preset medio), ≤ 8 en bajo (M90).
- Partículas vivas totales: ≤ 4.000 (medio), ≤ 2.000 (bajo).
- LOD de emisores: > 40 m → pausa; > 30 m → 25% de partículas.
- Precalentamiento del pool: 8 emisores en el arranque (M62).
- Overdraw de VFX: ≤ 0.3× pantalla en escena pivote.

### 3.3 Accesibilidad (M58)

| vfx_quality | Efecto |
|---|---|
| full | opacidad/velocidad normal |
| reduced | opacidad ×0.5, velocidad ×0.75, sin flashes > 8 Hz |
| off | desactiva loops y atmosféricos; one-shots mínimos (glow estático) |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M04 | GPUParticles3D/2D |
| M13/M17/M22/M24/M33/M34/M71 | Triggers de eventos de juego |
| M48 | Triggers en timelines de animación |
| M43/M44 | VFX + SFX + feedback en un solo trigger |
| M32/M29/M31 | Atmosféricos y estacionales |
| M51/M50 | Salpicaduras y hojas |
| M47/M49 | Materiales emisivos; luz de fuego (M49) |
| M53/M58 | VFX de UI con Reduce Motion |
| M61/M62 | Presupuesto y pool |
| M108/M118 | Importación y validación en CI |