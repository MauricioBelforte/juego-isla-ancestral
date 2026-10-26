**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 137: Prototipo

## 1. Arquitectura del Prototipo

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Escena principal: prototipo_isla.tscn                           â”‚
â”‚  â”œâ”€â”€ Player (CharacterBody3D + cÃ¡mara third-person M11/M12)     â”‚
â”‚  â”œâ”€â”€ VoxelWorld (VoxelTools M08: terreno 64Â³-96Â³, seed fija)    â”‚
â”‚  â”œâ”€â”€ RecursoNode (1 recurso clave: madera, M15)                 â”‚
â”‚  â”œâ”€â”€ NPC_Prueba (StaticBody simple + diÃ¡logo, M19/M21)          â”‚
â”‚  â”œâ”€â”€ Casa (para pruebas, M18)                                   â”‚
â”‚  â”œâ”€â”€ Ruina (bloque collectible + pista, M25)                    â”‚
â”‚  â”œâ”€â”€ Puzzle (puerta que abre con herramienta, M24)              â”‚
â”‚  â”œâ”€â”€ Sky/Sun (ciclo dÃ­a-noche bÃ¡sico, M31)                      â”‚
â”‚  â””â”€â”€ Clima (lluvia simple de partÃ­culas, M32/M52)               â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Autoloads                                                        â”‚
â”‚  game_state.gd      (M59 â€” GameState con slot Ãºnico)            â”‚
â”‚  world_seed.gd      (M10 â€” seed fija 20260819)                  â”‚
â”‚  save_manager.gd    (M59/M60 â€” save delta de chunks)            â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ docs/prototipo/                                                 â”‚
â”‚  â”œâ”€â”€ PLAYTEST.md           (plan + resultados M114)             â”‚
â”‚  â”œâ”€â”€ FILOSOFIA-CHECK.md    (checks M152/M153)                   â”‚
â”‚  â”œâ”€â”€ GONOGO.md             (decisiÃ³n final con criterios)       â”‚
â”‚  â””â”€â”€ RETROSPECTIVA.md      (lecciones â†’ M138)                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 2. Componentes del Prototipo

### 2.1 Jugador (M11/M12)
- `CharacterBody3D` con movimiento en 8 direcciones + salto (decisiÃ³n: sin sprint en el prototipo; la velocidad fija simplifica el feeling test).
- Colisiones voxel: `move_and_slide()` con shapes por bloque.
- CÃ¡mara: SpringArm3D + mouse orbit, sin clip contra el terreno (distancias mÃ­nima/mÃ¡xima 2-8 m).
- Input: teclado/mouse provisional (M57 real llega despuÃ©s).

### 2.2 Voxel (M08/M09/M10)
- `VoxelTerrain` con generador de isla: 1 isla elevada rodeada de agua (sin ocÃ©ano navegable, M51 no aplica).
- ExtracciÃ³n: raycast desde la mira, `voxel_tool.do_point()` con lÃ­mite de radio 3 (no minar de lejos).
- ColocaciÃ³n: do_point en cara apuntada; el bloque colocable = 1 recurso de madera.
- Seed fija (20260819) para que el save delta sea vÃ¡lido.

### 2.3 Inventario y Recurso (M14/M15)
- 1 slot: {"recursos": N, "herramienta": bool}.
- La madera se obtiene de Ã¡rboles de bloque (leÃ±a) o del suelo.
- ConfecciÃ³n mÃ­nima: 2 maderas + nada mÃ¡s = herramienta (M16 esbozado).

### 2.4 NPC y DiÃ¡logo (M19/M21)
- NPC de prueba ("GuÃ­a") con 3 frases: bienvenida, pista del puzzle, agradecimiento del regalo.
- InteracciÃ³n: tecla E al mirarlo; caja de diÃ¡logo flotante simple (placeholder UI).

### 2.5 Puzzle y Ruina (M24/M25)
- Puzzle: puerta de ruina que se abre si tenÃ©s la herramienta (mÃ­nimo viable).
- Ruina: 5-8 bloques decorativos + 1 reliquia decorativa (placeholder).
- Recompensa del puzzle: mensaje de "Â¡El viento te lo agradece!" (placeholder noble M148).

### 2.6 Casa y Ambiente (M18/M31/M32)
- Casa: caja con puerta que abre y "dormir para pasar el dÃ­a" (recarga): valida el ciclo de dÃ­a/noche.
- Ciclo dÃ­a/noche: sky procedural simple (M31), ronda en 6 min reales.
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
- Script `playtest_runner.gd` (herramienta editor): cÃ¡mara demogrÃ¡fica (grabar 15 min), log de eventos (extracciÃ³n, diÃ¡logo, puzzle).
- FPS log cada 5 s (M61) con `Engine.get_frames_per_second()`.
- Encuesta post-sesiÃ³n (5 preguntas, ver RF14).

## 3. Flujo Principal (bucle de juego del prototipo)

```
Spawn en la playa (isla 64Â³)
 â†’ Caminar por el mundo (movimiento + cÃ¡mara)
 â†’ Extraer madera (voxel_tool) â†’ se siente el voxel
 â†’ 2 maderas â†’ herramienta (crafting esbozo)
 â†’ Hablar con la GuÃ­a (diÃ¡logo: pista del puzzle)
 â†’ Entrar a la ruina â†’ resolver puzzle con herramienta
 â†’ Recompensa: mensaje + regalo a la GuÃ­a + "dormir" en la casa (dÃ­a siguiente)
 â†’ Guardar â†’ sesiÃ³n 15 min â†’ encuesta + observaciÃ³n
```

## 4. Criterios de MediciÃ³n (GO/NO-GO)

| Criterio | MÃ©trica | GO si |
|---|---|---|
| DiversiÃ³n (RF14) | Encuesta media (M114) | â‰¥ 7/10 |
| IntenciÃ³n de seguir | % "sÃ­" a "Â¿volverÃ­as a jugar?" | â‰¥ 80% |
| Rendimiento (RF16) | FPS medio en config media | â‰¥ 60 |
| Philosophy (RF15) | Checklist M152/M153 | Sin fallos crÃ­ticos |
| Bucle completo (RF1-RF12) | % de testers que completan el bucle | â‰¥ 90% |
| Save (M59) | Test guardarâ†’salirâ†’cargar | 0 pÃ©rdidas |
| MÃ©tricas 1-6 | Tabla consolidada en GONOGO.md | 6/6 o 5/6 con plan de mitigaciÃ³n |

## 5. Cierre del Hito

1. Limpieza de logs, tag `prototipo-v1`, push.
2. Retrospectiva (lecciones â†’ M138 Vertical Slice).
3. GONOGO.md firmado por el equipo con fecha.
4. Si NO-GO: se documenta el motivo (tÃ©cnico/filosofÃ­a/diversiÃ³n) y se decide: ajustar prototipo (7 dÃ­as) o replanificar alcance (M136/M135).
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
