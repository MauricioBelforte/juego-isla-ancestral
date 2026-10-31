**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 137: Prototipo

## 1. Arquitectura del Prototipo

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Escena principal: prototipo_isla.tscn                           â”‚
│  ├── Player (CharacterBody3D + cámara third-person M11/M12)     │
│  ├── VoxelWorld (VoxelTools M08: terreno 64³-96³, seed fija)    │
â”‚  â”œâ”€â”€ RecursoNode (1 recurso clave: madera, M15)                 â”‚
│  ├── NPC_Prueba (StaticBody simple + diálogo, M19/M21)          │
â”‚  â”œâ”€â”€ Casa (para pruebas, M18)                                   â”‚
â”‚  â”œâ”€â”€ Ruina (bloque collectible + pista, M25)                    â”‚
â”‚  â”œâ”€â”€ Puzzle (puerta que abre con herramienta, M24)              â”‚
│  ├── Sky/Sun (ciclo día-noche básico, M31)                      │
│  └── Clima (lluvia simple de partículas, M32/M52)               │
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Autoloads                                                        â”‚
│  game_state.gd      (M59 — GameState con slot único)            │
│  world_seed.gd      (M10 — seed fija 20260819)                  │
│  save_manager.gd    (M59/M60 — save delta de chunks)            │
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ docs/prototipo/                                                 â”‚
â”‚  â”œâ”€â”€ PLAYTEST.md           (plan + resultados M114)             â”‚
â”‚  â”œâ”€â”€ FILOSOFIA-CHECK.md    (checks M152/M153)                   â”‚
│  ├── GONOGO.md             (decisión final con criterios)       │
â”‚  â””â”€â”€ RETROSPECTIVA.md      (lecciones â†’ M138)                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 2. Componentes del Prototipo

### 2.1 Jugador (M11/M12)
- `CharacterBody3D` con movimiento en 8 direcciones + salto (decisión: sin sprint en el prototipo; la velocidad fija simplifica el feeling test).
- Colisiones voxel: `move_and_slide()` con shapes por bloque.
- Cámara: SpringArm3D + mouse orbit, sin clip contra el terreno (distancias mínima/máxima 2-8 m).
- Input: teclado/mouse provisional (M57 real llega después).

### 2.2 Voxel (M08/M09/M10)
- `VoxelTerrain` con generador de isla: 1 isla elevada rodeada de agua (sin océano navegable, M51 no aplica).
- Extracción: raycast desde la mira, `voxel_tool.do_point()` con límite de radio 3 (no minar de lejos).
- Colocación: do_point en cara apuntada; el bloque colocable = 1 recurso de madera.
- Seed fija (20260819) para que el save delta sea válido.

### 2.3 Inventario y Recurso (M14/M15)
- 1 slot: {"recursos": N, "herramienta": bool}.
- La madera se obtiene de árboles de bloque (leña) o del suelo.
- Confección mínima: 2 maderas + nada más = herramienta (M16 esbozado).

### 2.4 NPC y Diálogo (M19/M21)
- NPC de prueba ("Guía") con 3 frases: bienvenida, pista del puzzle, agradecimiento del regalo.
- Interacción: tecla E al mirarlo; caja de diálogo flotante simple (placeholder UI).

### 2.5 Puzzle y Ruina (M24/M25)
- Puzzle: puerta de ruina que se abre si tenés la herramienta (mínimo viable).
- Ruina: 5-8 bloques decorativos + 1 reliquia decorativa (placeholder).
- Recompensa del puzzle: mensaje de "¡El viento te lo agradece!" (placeholder noble M148).

### 2.6 Casa y Ambiente (M18/M31/M32)
- Casa: caja con puerta que abre y "dormir para pasar el día" (recarga): valida el ciclo de día/noche.
- Ciclo día/noche: sky procedural simple (M31), ronda en 6 min reales.
- Lluvia: particles 2D simple (M52 esbozo).

### 2.7 Guardado Delta (M59/M60)
```
save v1 = {
  "version": 1,
  "seed": 20260819,
  "player": {"pos": Vector3, "rot": float},
  "inventory": {"madera": int, "herramienta": bool},
  "modified_chunks": {"x,z": {"blocks": {...}}},
  "flags": {"puzzle_resuelto": bool}
}
```
- Load: regenera mundo con seed y re-aplica chunks modificados.

### 2.8 Playtest y Pruebas (M114/M61)
- Script `playtest_runner.gd` (herramienta editor): cámara demográfica (grabar 15 min), log de eventos (extracción, diálogo, puzzle).
- FPS log cada 5 s (M61) con `Engine.get_frames_per_second()`.
- Encuesta post-sesión (5 preguntas, ver RF14).

## 3. Flujo Principal (bucle de juego del prototipo)

```
Spawn en la playa (isla 64³)
 → Caminar por el mundo (movimiento + cámara)
 â†’ Extraer madera (voxel_tool) â†’ se siente el voxel
 â†’ 2 maderas â†’ herramienta (crafting esbozo)
 → Hablar con la Guía (diálogo: pista del puzzle)
 â†’ Entrar a la ruina â†’ resolver puzzle con herramienta
 → Recompensa: mensaje + regalo a la Guía + "dormir" en la casa (día siguiente)
 → Guardar → sesión 15 min → encuesta + observación
```

## 4. Criterios de Medición (GO/NO-GO)

| Criterio | Métrica | GO si |
|---|---|---|
| Diversión (RF14) | Encuesta media (M114) | ≥ 7/10 |
| Intención de seguir | % "sí" a "¿volverías a jugar?" | ≥ 80% |
| Rendimiento (RF16) | FPS medio en config media | â‰¥ 60 |
| Philosophy (RF15) | Checklist M152/M153 | Sin fallos críticos |
| Bucle completo (RF1-RF12) | % de testers que completan el bucle | â‰¥ 90% |
| Save (M59) | Test guardar→salir→cargar | 0 pérdidas |
| Métricas 1-6 | Tabla consolidada en GONOGO.md | 6/6 o 5/6 con plan de mitigación |

## 5. Cierre del Hito

1. Limpieza de logs, tag `prototipo-v1`, push.
2. Retrospectiva (lecciones â†’ M138 Vertical Slice).
3. GONOGO.md firmado por el equipo con fecha.
4. Si NO-GO: se documenta el motivo (técnico/filosofía/diversión) y se decide: ajustar prototipo (7 días) o replanificar alcance (M136/M135).
## Specs Prototipo Voxel (Beam 494)

### VoxelTerrain isla 64³-96³
- Spec: VoxelTerrain de isla de tamaño 64³-96³ voxels. Coherente con M08 (terreno) y M137 (prototipo).

### Test de bordes de chunk sin crash
- Spec: test de bordes de chunk sin crash. Coherente con M137 (prototipo) y M08 (terreno).

### Guardado delta solo de chunks modificados
- Spec: guardado delta solo de chunks modificados (persistencia incremental). Coherente con M07 (guardado) y M137 (prototipo).

### Test guardar→salir→cargar con 0 pérdidas
- Spec: test guardar→salir→cargar con 0 pérdidas. Coherente con M07 (guardado) y M137 (prototipo).

## Specs Prototipo (Beam 723)

### Specs items degradados T212 (2026-10-26, Reflection-Beam-1.0)
- **L126 (playtest_runner.gd que loguea eventos y FPS):** degradado 2026-10-16 (barrido agnes 610/643 + flip GLM-5.3 Flash-Director): archivo NO existe en disco (scripts/ + tools/ = 0 hits; scenes/prototipo/ inexistente — restante del futures). Degradado 2026-10-23 (DeepSeek-V4.1-Flash, P4/P5b dir 369): el artefacto citado playtest_runner.gd NO existe en disco ni en la historia de git (git log --all = 0 commits); el [x] no tenía evidencia en disco.
- **L147 (FILOSOFIA-CHECK.md firmada por tester/equipo):** degradado 2026-10-23 (DeepSeek-V4.1-Flash, P4/P5b dir 369): el artefacto citado FILOSOFIA-CHECK.md NO existe en disco ni en la historia de git (git log --all = 0 commits); el [x] no tenía evidencia en disco.

### Definir generador de isla: elevacion + playa + agua circundante
- Spec: definir generador de isla: elevacion + playa + agua circundante. Coherente with M137 (prototipo) and M08 (terreno).
