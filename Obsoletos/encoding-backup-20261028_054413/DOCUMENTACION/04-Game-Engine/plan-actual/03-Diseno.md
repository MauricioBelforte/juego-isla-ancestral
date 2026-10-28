**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 04: Game Engine

## 1. Stack del Motor (decisiÃ³n adoptada)

| Elemento | ElecciÃ³n | Notas |
|---|---|---|
| Motor | **Godot 4.x** (versiÃ³n estable LTS a fijar en M1) | Gratis, MIT, sin regalÃ­as |
| Lenguaje script | **GDScript** (primario) + C# opcional vÃ­a .NET | GDScript es el ecosistema nativo de Godot |
| Terreno voxel | **Voxel Tools (Zylann)** â€” GDExtension C++ | Terreno editable, colisiones, streaming, LOD Transvoxel, meshing multihilo |
| Renderer | **Forward+ (Vulkan)** para PC/Deck | Mobile renderer para builds livianas |
| FÃ­sica | Godot Physics (o Jolt si el rendimiento lo pide) | Colisiones voxel vÃ­a raycast de Voxel Tools |
| Input | Input Map (teclado + mando, remapeo) | Requisito de accesibilidad M58 |
| UI | Control nodes (le da a UGUI) | Canvas/HUD del juego |
| Audio | AudioServer + buses | MÃºsica lo-fi + SFX ASMR |
| Export | Windows, Linux, macOS; **SteamOS nativo** | Presets en M1 |

## 2. Arquitectura de chunks (independiente del motor â€” Plan-prod Â§2)

- Chunk: 16Â³ o 32Â³ voxels (decidir en M08 Mundo Voxel).
- **Face culling + greedy meshing** obligatorios (GDD directiva 1).
- Remallado en hilos secundarios; nunca bloquear el hilo principal.
- **LOD Transvoxel** para chunks lejanos; transiciÃ³n suave al editar.
- Streaming por isla: **escenas separadas con carga diegÃ©tica** (el GRAN VAPOR navegando), opciÃ³n mÃ¡s simple y narrativamente coherente (Plan-prod Â§2.8).
- Persistencia por **diffs de chunk** (no guardar el mundo entero).

## 3. ConfiguraciÃ³n del proyecto base (entregable del hito M1)

1. Proyecto Godot creado con versiÃ³n fijada y `.gitignore` en `Assets/` equivalente (Godot: `/.godot/`).
2. Renderer Forward+; calidad en 3 niveles (Baja/Media/Alta) probados.
3. Input Map: mover, cÃ¡mara (rotar/zoom), atacar-herramienta, interactuar, inventario, hotbar 1-9.
4. Capas: voxel, jugador, NPC, props, UI, puzzle-receptor.
5. Escena raÃ­z: `Main.tscn` (world + player + camera rig) y `Bootstrap` (carga de config).
6. Presets de export: Windows (debug/release), Linux, Web (demo), luego SteamOS.
7. Config de autoguardado del editor y convenciones de carpetas del proyecto (`scenes/`, `scripts/`, `resources/`, `data/`).

## 4. Criterio de validaciÃ³n del motor (hito M1)

> Prototipo: chunk 16Â³ con face culling + editing + cÃ¡mara orbitando + raycast de bloque a **60 FPS sostenidos** en una PC media y Steam Deck. Si falla, revisar greedy meshing/threading antes de avanzar; si persiste, re-evaluar motor (con re-planificaciÃ³n).

## 5. GestiÃ³n de versiones del motor

- VersiÃ³n exacta fijada al crear el proyecto y registrada en `04-Codigo.md`.
- **Regla:** no actualizar Godot durante producciÃ³n salvo parche de seguridad crÃ­tico; documentar cualquier migraciÃ³n en Logs y changelog.
- Los assets/plugins se fijan por versiÃ³n (Voxel Tools pinned contra la versiÃ³n de Godot).
## Specs Rendimiento (Beam 493)

### Validar 60 FPS en PC media
- Spec: presupuesto de rendimiento para PC media — 60 FPS sostenidos, P99 <= 40 ms. Profiling con Unity/Godot Profiler. Coherente con M60 (rendimiento) y M61 (rendimiento).

### Validar 60 FPS en Steam Deck
- Spec: presupuesto de rendimiento para Steam Deck (o configuración equivalente) — 60 FPS sostenidos, P99 <= 40 ms. Coherente con M60 (rendimiento) y M61 (rendimiento).