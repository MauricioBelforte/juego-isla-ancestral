# Especificación de Integración de Audio — M131-Créditos (9 ítems pendientes)

**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Contexto:** cierre M131 (encargo del director, msg 50). E.L58 (`catalogo_creditos.tres`) quedó RESUELTO con artefacto real. Los 9 ítems de audio (I.L90-97, I.L99) permanecen `[ ]` con dueño: el bloqueo verificado es la **ausencia de contenido de audio en el repo** (0 archivos .ogg/.wav/.opus/.mp3 — rglob sobre el proyecto). Este documento es la especificación de cableado punto por punto, para que el dueño de cada ítem (o el equipo de audio) implemente sin re-investigación.

## Estado verificado de los motores (2026-10-11)

- **M41 MusicDirector** (`scripts/audio/music_director.gd`): 24 temas cargados; `sting()` es **stub** (L76-78: "stub: el compositor provee los assets").
- **M42 AmbientDirector**: 13 biomas.
- **M43 SFXManager** (`scripts/audio/sfx_manager.gd`): 9 superficies, 7 tonos, catálogo OK; `data/audio/sfx_surfaces.json` solo define materiales de terreno.
- **M91 AudioConfigService** (`scripts/audio/audio_config_service.gd`): `esta_muteado(bus)` existe (L177).
- **Matriz de contextos musicales** (`data/audio/music_context_matrix.json`): ya define `"flow_creditos"` (L19).
- **UIFeedback** (`scripts/ui/services/ui_feedback.gd`): 4 `AudioStreamPlayer` (vars L17-20), creados en `_crear_players()` (L64-68) vía `_create_player(nombre)` (L70-75): `AudioStreamPlayer.new()`, `bus = "UI"`, **sin `stream` asignado**. `_play()` (L77-82) reproduce.
- **0 archivos de audio en el repo** (rglob `*.ogg/*.wav/*.opus/*.mp3` → 0 resultados).

## Tabla de los 9 ítems

| Ítem | Título | Dueño | Asset requerido | Punto de cableado | Criterio de aceptación |
|---|---|---|---|---|---|
| I.L90 | SFX encendido/apagado de menú | M41/M43 (contenido) | `toggle_on.ogg`, `toggle_off.ogg` | `ui_feedback.gd:70-75` `_create_player` — asignar `player.stream` al player correspondiente (o player dedicado nuevo) | Al mutar/desmutar se oye el SFX; respeta `esta_muteado("UI")` (M91, L177) |
| I.L91 | SFX navegación (flecha, enter, escape) | M41/M43 | `hover.ogg`, `click.ogg`, `escape.ogg` | `ui_feedback.gd:64-68` `_crear_players` — `_hover_player`, `_click_player`, `_invalid_player` ya existen; asignar streams | Navegación de menú reproduce SFX por foco / aceptación / cancelación |
| I.L92 | Música lounge suave durante encabezado | M41/M43 | pista lounge (.ogg) | `music_director.gd` — tocar tema `flow_creditos` (ya en `music_context_matrix.json:19`) al entrar a la pantalla de créditos | Suena lounge suave al abrir créditos; se detiene al salir |
| I.L93 | Fade-out gradual al salir | M41 | (usa pista de I.L92) | `music_director.gd` — fade-out al `salir_creditos` (signal de `credits_manager.gd`) | Atenuación progresiva (no corte seco) al salir |
| I.L94 | Logo de desarrolladora con sonido cálido | M41 | sting cálido (.ogg) | `music_director.gd:76-78` — implementar `sting()` (hoy stub) | Al mostrar el logo se oye el sting cálido |
| I.L95 | Compatibilidad con familia tonal M43 | M43 | (verificación sobre pistas de I.L92/I.L94) | Revisión de diseño musical: comparar tonalidad/timbre de las pistas contra la familia tonal definida por M43 | Las pistas de créditos pertenecen a la familia tonal del juego |
| I.L96 | Sin música fuerte si M91 lo desactiva | M91/M41 | (usa pista de I.L92) | `music_director.gd` — consultar `AudioConfigService.esta_muteado("Music")` (`audio_config_service.gd:177`) antes de reproducir | Con Music mutado no suena nada en créditos |
| I.L97 | Balance con M41/M42/M43 según estado | M41/M42/M43 | (usa pistas de I.L92/I.L94) | Mezcla: niveles Music vs Ambient vs SFX coherentes con el estado del juego (fin de partida → créditos) | El balance percibido es coherente con el contexto de salida |
| I.L99 | SFX puntual solo si interactivo | M41 | (usa streams de I.L90/I.L91) | `ui_feedback.gd:77-82` `_play()` — disparar solo cuando el elemento es interactivo (no en pantallas de solo lectura) | SFX solo en elementos interactivos |

## Orden de implementación sugerido

1. **Contenido:** el equipo de audio entrega los 6 assets (.ogg) en la carpeta de assets del proyecto (respetando la convención de rutas de assets del repo).
2. **I.L90 + I.L91** (UIFeedback: asignar streams a los 4 players existentes — L64-75).
3. **I.L92** (MusicDirector: `flow_creditos` ya definido en la matriz).
4. **I.L93** (fade-out) e **I.L94** (sting) sobre la pista de I.L92.
5. **I.L96** (gate M91) e **I.L99** (gate de interactividad).
6. **I.L95 + I.L97** (verificación de diseño musical y balance).

## Nota de honestidad

Ninguno de los 9 ítems se marca `[x]` hasta que exista el artefacto de audio y el cableado en disco (regla anti-inflación §21.8.2.b: el artefacto citado debe existir). Este documento es la especificación, no la implementación.
