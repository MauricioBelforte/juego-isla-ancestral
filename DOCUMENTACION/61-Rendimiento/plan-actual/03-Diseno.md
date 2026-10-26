**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 61: Rendimiento

## 1. Visión General

M61 define la **norma de rendimiento**: presupuestos, medición y técnicas obligatorias. Entregables ejecutables: `budget_profile.gd` (instrumentación), `bench_scene_a.tscn` (benchmark oficial) y `validate_budget.gd` (validador de tabla contra mediciones). Es una norma transversal: la implementación de cada técnica vive en el módulo dueño (M07 mesher, M50 instancing, M52 pooling...).

## 2. Arquitectura

```
┌─ NORMAS M61 ─────────────────────────────────────────┐
│  Presupuesto por categoría (16,5 ms @ 60 FPS)        │
│  Técnicas obligatorias por sistema                   │
│  Hardware objetivo (mín/recomendado)                 │
└───────┬──────────────────────────────┬───────────────┘
        │ declara coste                 │ mide
  ┌─────▼──────┐                ┌───────▼──────────┐
  │ Módulos    │                │ bench_scene_a    │
  │ (M07..M77) │                │ (60 s script)    │
  │ declaran   │                └───────┬──────────┘
  │ presupuesto│                        │
  └─────┬──────┘                   ┌────▼─────┐
        │                          │ Profiler │
  ┌─────▼──────────────────────────▼─────┐    ┌───┴───┐
  │ validate_budget.gd                   │    │ · CPU │
  │ compara tabla ↔ medición (toler.10%) │    │ · GPU │
  └───────────────┬──────────────────────┘    └───────┘
                  ▼
        Gate CI (M116): falla PR si excede
```

### 2.1 Instrumentación (budget_profile.gd)

| Función | Propósito |
|---|---|
| `begin_section(categoria)` | Marca inicio de categoría (etiqueta de Profiler Godot) |
| `end_section(categoria)` | Cierra y acumula tiempo/llamadas |
| `get_section_ms(categoria)` | Lectura para diagnose y CI |
| `reset_profile_run()` | Reinicia ventana de medición (bench scene) |

**Implementación Godot:** `get_ticks_usec()` diffs + etiquetas; en build de profiling se registran también draw calls y partes del render (`RenderingServer.get_frame_setup_time_cpu()`).

### 2.2 Bench scene (bench_scene_a.tscn)

| Propiedad | Valor |
|---|---|
| Terreno | 400 bloques de terreno voxel estándar (M08) |
| Vegetación | 60 instancias (árboles, hierba viento M50) |
| Pueblo | 10 NPC con IA (M19) + 1 casa (M17) |
| Agua | Plano de agua visible (M51) |
| Iluminación | Ciclo día (sol) y noche (faroles M49) |
| Duración | 60 s recorrido reproducido (script de cámara) |
| Salida | JSON con ms por categoría (16,7 ms diana @ 60 FPS) |

### 2.3 Técnicas obligatorias por sistema

| Sistema | Técnica | Módulo dueño |
|---|---|---|
| Mesher voxel | Greedy meshing + batching por chunk + LOD 3 niveles | M07/M08 |
| Terreno lejano | Impostor LOD (malla simpl. + textura) | M08/M47 |
| Vegetación | GPU instancing (multimesh) + viento en vertex shader | M50 |
| Agua | 1 plano + normales; reflejos solo superficie | M51 |
| Sombras | Dinámicas solo personajes/objetos clave; resto blended | M48/M49 |
| Partículas | Pool + límite 500/cámara | M52 |
| NPC/fauna | LOD de update + pooling de instancias | M19/M35/M64 |
| Cuevas/templos | Occlusion culling por celdas | M24/M25 |
| UI | Sin re-layouts por frame; texturas atlas | M53 |
| Gameplay | Cero allocations en bucles calientes | Global (norma) |

## 3. Estructura de Datos

### 3.1 Presupuesto oficial (`budgets.cfg`)

```
[total]
presupuesto_ms = 16.7        # diana 60 FPS
tolerancia_ci = 0.10

[categorias]
gameplay_ms = 2.5
mundo_voxel_ms = 4.0
ia_npc_ms = 2.0
particulas_ms = 1.0
culling_ms = 0.5
render_ms = 5.0
ui_ms = 1.5
```

### 3.2 `validate_budget.gd` — Validación

| Validación | Condición |
|---|---|
| Tabla completa | Todas las categorías declaradas (criterio RF28) |
| Bench measure | Suma de categorías ≤ presupuesto_total × (1+tolerancia) |
| Módulos | Cada módulo principal declara su coste en su checklist |
| Hardware | Configuración de escena = preset mínimo/recomendado |

## 4. Persistencia

- `budgets.cfg` es Resource embebido (constante, no serializado).
- El JSON de salida del bench se guarda en `logs/bench/` (rotación sección 18 del AGENTS) para comparar regresiones.

## 5. Integración con otros módulos

| Módulo | Rol |
|---|---|
| M07/M08 | Mesher, batching, LOD, occlusion por chunks |
| M49/M50/M51/M52 | Iluminación, vegetación, agua, partículas (técnicas) |
| M19/M35/M64 | LOD de NPC/fauna |
| M53/M57 | UI ligera, controles (hardware objetivo) |
| M62 | Memoria (aquí solo análisis): allocations/GC cross |
| M63 | Cargas y streaming (tiempos de carga) |
| M91 | Presets gráficos que consumen esta norma |
| M114 | Hardware mínimo/recomendado (fuente) |
| M116 | Gate CI de rendimiento |
| M115 | Tiempos de carga frío/caliente |

## 6. Impacto en Rendimiento (del propio módulo)

- Instrumentación OFF en builds de producción (solo dev/profiling) — overhead cero en release.
- Bench scene corre solo en CI/dev — jamás en el juego del jugador.
- La norma NO impone monitoreo en runtime para el jugador (cero coste).

## Specs Rendimiento (Beam 709)

### Aplicar a vegetacion (M50)
- Spec: aplicar a vegetacion (M50). Coherente with M61 (rendimiento) and M50 (vegetacion).

### Aplicar a rocas y fragmentos (M08)
- Spec: aplicar a rocas y fragmentos (M08). Coherente with M61 (rendimiento) and M08 (terreno).

### Aplicar a particulas de larga vida
- Spec: aplicar a particulas de larga vida. Coherente with M61 (rendimiento) and M52 (particulas).

### Pooling de particulas (M52)
- Spec: pooling de particulas (M52). Coherente with M61 (rendimiento) and M52 (particulas).

### Pooling de fauna y peces (M35/M34)
- Spec: pooling de fauna y peces (M35/M34). Coherente with M61 (rendimiento) and M35/M34 (fauna/pesca).

### Pooling de efectos de herramientas
- Spec: pooling de efectos de herramientas. Coherente with M61 (rendimiento) and M13 (herramientas).

### Specs items degradados T190 (2026-10-26, Reflection-Beam-1.0)
- **L301 (instancing multimesh Voxel Tools):** no medible en headless; Multimesh se instancia y se mide con renderer.
- **L330 (cableado gate a GitHub Actions):** pertenece a M118 (CI-CD, 0/100, disponible); runner necesita GPU/Windows para bench; workflow actual usa Godot 4.3 (proyecto es 4.7.2) — actualizar es tarea de M118.
- **L104 (metodología capturas profiler):** capturas existen en disco pero no versionadas (git ls-files capturas/61 = 0).
- **L128 (alinear M114):** pendiente.
- **L137 (alinear M114 y presets M91):** pendiente.
- **L145 (documentar metodología Profiler):** pendiente.
- **L169 (VRAM < presupuesto GPU mínima):** umbral definido y verificado (memoria.vram_presupuesto_mb/vram_por_escena_mb, gate _validar_memoria()); VRAM real solo con renderer (headless no crea renderer).
- **L185 (pantalla de carga sin frames congelados):** no medible en headless; norma de carga (asincronía obligatoria, progreso real, bloqueo cero hilo principal) definida como umbrales data-driven en tanda 2.
- **L193 (generación stream continuo M63):** no medible en headless; streaming continuo se mide sobre frames reales con chunks entrando.
- **L201 (destrucción masiva sin picos):** no medible en headless; umbral remesh (<2ms por bloque) definido y verificado por gate (normas.remesh_bloque_ms_max).
- **L209 (pueblo completo 60 FPS):** no medible en headless; límite NPC visibles (≤20) definido en norma y verificado por gate (normas.npcs_activos_max).
- **L229 (noche con faroles M49 60 FPS):** exige renderer; presupuesto de sombras por preset derivado de M90 (sombras_cascadas 1/2/4/4) y verificado por suite.
- **L237 (ciclo día/noche sin drop):** no medible en headless (drop es frame time real).
- **L245 (mar visible sin overdraw):** umbral definido (gpu.overdraw_max = 1.5) y verificado por gate/suite contra validate_water.gd; medición real exige renderer (M51).
- **L253 (bosque denso 60 FPS):** no medible en headless; norma de instancing obligatoria (RF23) es umbral del dueño M50.
- **L261 (preset mínimo 30 FPS):** objetivo por preset declarado y verificado contra M90 (normas.objetivo_por_preset, 16 checks); FPS real exige renderer.
- **L269 (culling eficaz en bench):** bench (bench_recorder.gd + bench_scene_a.tscn) mide draw calls/objetos con renderer y vuelca JSON a user://logs/bench/; sin ventana no hay corrida; JSON anterior no versionado (deuda QA E-12a).
- **L277 (templo subterráneo M25 60 FPS):** occlusion culling por celdas se mide con GPU queries, inexistentes en headless.
- **L285 (ausencia de pop en cámara principal):** juicio visual de transición de LOD; exige capturas y visión (M154 V2). Umbral normas.lod_transicion_sin_pop_m = 2 definido.
- **L293 (draw calls dentro de presupuesto):** límite definido (gpu.draw_calls_escena_objetivo = 400 == limites.draw_calls_max) y verificado por gate/suite; medición real exige renderer (bench_recorder.gd).
