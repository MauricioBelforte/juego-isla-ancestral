**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 04: Game Engine

## 1. Stack del Motor (decisión adoptada)

| Elemento | Elección | Notas |
|---|---|---|
| Motor | **Godot 4.x** (versión estable LTS a fijar en M1) | Gratis, MIT, sin regalías |
| Lenguaje script | **GDScript** (primario) + C# opcional vía .NET | GDScript es el ecosistema nativo de Godot |
| Terreno voxel | **Voxel Tools (Zylann)** — GDExtension C++ | Terreno editable, colisiones, streaming, LOD Transvoxel, meshing multihilo |
| Renderer | **Forward+ (Vulkan)** para PC/Deck | Mobile renderer para builds livianas |
| Física | Godot Physics (o Jolt si el rendimiento lo pide) | Colisiones voxel vía raycast de Voxel Tools |
| Input | Input Map (teclado + mando, remapeo) | Requisito de accesibilidad M58 |
| UI | Control nodes (le da a UGUI) | Canvas/HUD del juego |
| Audio | AudioServer + buses | Música lo-fi + SFX ASMR |
| Export | Windows, Linux, macOS; **SteamOS nativo** | Presets en M1 |

## 2. Arquitectura de chunks (independiente del motor — Plan-prod §2)

- Chunk: 16³ o 32³ voxels (decidir en M08 Mundo Voxel).
- **Face culling + greedy meshing** obligatorios (GDD directiva 1).
- Remallado en hilos secundarios; nunca bloquear el hilo principal.
- **LOD Transvoxel** para chunks lejanos; transición suave al editar.
- Streaming por isla: **escenas separadas con carga diegética** (el GRAN VAPOR navegando), opción más simple y narrativamente coherente (Plan-prod §2.8).
- Persistencia por **diffs de chunk** (no guardar el mundo entero).

## 3. Configuración del proyecto base (entregable del hito M1)

1. Proyecto Godot creado con versión fijada y `.gitignore` en `Assets/` equivalente (Godot: `/.godot/`).
2. Renderer Forward+; calidad en 3 niveles (Baja/Media/Alta) probados.
3. Input Map: mover, cámara (rotar/zoom), atacar-herramienta, interactuar, inventario, hotbar 1-9.
4. Capas: voxel, jugador, NPC, props, UI, puzzle-receptor.
5. Escena raíz: `Main.tscn` (world + player + camera rig) y `Bootstrap` (carga de config).
6. Presets de export: Windows (debug/release), Linux, Web (demo), luego SteamOS.
7. Config de autoguardado del editor y convenciones de carpetas del proyecto (`scenes/`, `scripts/`, `resources/`, `data/`).

## 4. Criterio de validación del motor (hito M1)

> Prototipo: chunk 16³ con face culling + editing + cámara orbitando + raycast de bloque a **60 FPS sostenidos** en una PC media y Steam Deck. Si falla, revisar greedy meshing/threading antes de avanzar; si persiste, re-evaluar motor (con re-planificación).

## 5. Gestión de versiones del motor

- Versión exacta fijada al crear el proyecto y registrada en `04-Codigo.md`.
- **Regla:** no actualizar Godot durante producción salvo parche de seguridad crítico; documentar cualquier migración en Logs y changelog.
- Los assets/plugins se fijan por versión (Voxel Tools pinned contra la versión de Godot).