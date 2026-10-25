**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 58: Accesibilidad

## 1. Arquitectura

El mÃ³dulo sigue la regla de desacoplamiento del proyecto: **ninguna lÃ³gica vive en la UI**. Cuatro piezas componen el sistema:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                        SettingsManager (autoload)                    â”‚
â”‚  - Carga/guarda/valida AccessibilityProfile (JSON user://)            â”‚
â”‚  - Emite seÃ±ales: profile_loaded, profile_changed, profile_reset      â”‚
â”‚  - Expone helpers: get_setting(), is_reduced_motion(), etc.           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
            â”‚ consulta                              â”‚ aplica
            â–¼                                        â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”            â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  AccessibilityProfile   â”‚            â”‚  AccessibilityApplier           â”‚
â”‚  (Resource, serializable)â”‚           â”‚  - Aplica perfil en vivo       â”‚
â”‚  - campos por Ã¡rea      â”‚            â”‚  - Escala UI (M53), texto (M88) â”‚
â”‚  - presets predefinidos â”‚            â”‚  - Filtro de color (shader)     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜            â”‚  - Factor de movimiento (M12)   â”‚
                                       â”‚  - SubtitleProfile (M91)        â”‚
        â–²                              â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
        â”‚ lee/escribe                                 â”‚ seÃ±ala
â”Œâ”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ AccessibilityMenuUI   â”‚                â”‚  Sistemas consumidores:        â”‚
â”‚ (vista en M53, sin    â”‚                â”‚  Input (M57), Fuentes (M88),   â”‚
â”‚  lÃ³gica de gameplay)  â”‚                â”‚  GrÃ¡ficos (M90), Audio (M91),  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                â”‚  Controles de juego (M34/M35â€¦) â”‚
                                         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1.1 SettingsManager (autoload, nodo global)

| Responsabilidad | Detalle |
|---|---|
| Persistencia | Lee `user://accesibilidad/profile.json` al arranque; escritura atÃ³mica (temp + rename) y backup `profile.backup.json`. |
| ValidaciÃ³n | Coerce tipos; si el JSON estÃ¡ corrupto o desactualizado â†’ defaults + aviso (una vez por sesiÃ³n). |
| SeÃ±ales | `profile_loaded(profile)`, `profile_changed(profile)`, `profile_reset()`. |
| API pÃºblica | `get_profile()`, `get_setting(key)`, `set_setting(key, value)`, `save()`, `reset()`, `apply()`. |
| Acceso pre-tÃ­tulo | Instanciado como primer autoload para que el filtro de color/contraste ya exista cuando se muestra el logo. |

### 1.2 AccessibilityProfile (Resource)

| Campo | Rango / valores | Ãrea |
|---|---|---|
| `color_filter` | `none / protanopia / deuteranopia / tritanopia` | Visual |
| `color_filter_intensity` | 0.0â€“1.0 | Visual |
| `high_contrast` | bool + `contrast` 1.0â€“2.0, `brightness` 0.8â€“1.2, `saturation` 0.0â€“1.5 | Visual |
| `ui_scale` | 0.8â€“2.0 (paso 0.1) | Visual |
| `text_scale` | `normal / large / extra_large` (delega en M88) | Visual |
| `interactable_outlines` | bool | Visual |
| `ui_background_opacity` | 0.0â€“1.0 | Visual |
| `subtitles_enabled` | bool (default true) | Auditiva |
| `subtitle_size` / `subtitle_background_opacity` | 0.8â€“2.0 / 0.0â€“1.0 | Auditiva |
| `subtitle_speed` | 0.5â€“2.0 | Auditiva |
| `audio_indicators` | bool (rizos visuales) | Auditiva |
| `visual_alert_cards` | bool | Auditiva |
| `action_mode` | `hold / toggle` por acciÃ³n | Motora |
| `aim_assist` | 0.0â€“1.0 | Motora |
| `vibration_enabled` | bool | Motora |
| `input_preset` | `default / single_hand / low_mobility` | Motora |
| `difficulty` | `serene / standard / custom` | Cognitiva |
| `serene_combat` | bool (sin combate estresante) | Cognitiva |
| `extended_timers` | bool / factor | Cognitiva |
| `motion_reduction` | 0.0â€“1.0 (factor anti-mareo) | Cognitiva |
| `guidance_level` | `minimal / standard / reinforced` (marcadores de objetivo) | Cognitiva |
| `dialogue_pace` | `player_controlled / slow / standard` | Cognitiva |
| `reading_options` | `spacing` 0.8â€“1.5, `line_height` 0.9â€“1.6 | Lectoescritura |
| `global_large_text` | bool | Lectoescritura |
| `autosave_interval` | 1â€“30 min (default 5) | Sistema |
| `accessibility_shortcut` | `f10 / custom / off` | Sistema |

Presets predefinidos (static): `DEFAULT`, `PREVENT_MOTION_SICKNESS`, `HIGH_CONTRAST`, `SERENE_MODE`, `SINGLE_HAND`.

### 1.3 AccessibilityApplier (servicio)

- Aplica el perfil a los nodos objetivo: escala de layout (nodo raÃ­z de UI, M53), escala de texto (theme de M88), opacidad de fondos, outlines de interactuables.
- Activa/desactiva el **ColorFilter** (CanvasLayer con shader passthrough o fallback `modulate` segÃºn preset grÃ¡fico de M90).
- Informa a **InputManager (M57)** de cambios de remapeo descargados (presets `single_hand`, `low_mobility`) y de vibraciÃ³n.
- Informa a **SubtitleManager (M91)** del perfil de subtÃ­tulos.
- Informa a **M12 (cÃ¡mara)** del factor `motion_reduction` para shake/parallax/transiciones.
- Informa a sistemas de juego (M34 pesca, M35 minerÃ­a, combate) del nivel `aim_assist` y de los flags de dificultad; estos sistemas solo LEEN valores, nunca escriben.

### 1.4 AccessibilityMenuUI (vista)

- Vive dentro del Ã¡rbol de UI de M53 (menÃº Opciones â†’ pestaÃ±a "Accesibilidad"), sin lÃ³gica de gameplay.
- Organizado por Ã¡reas (Visual/Auditiva/Motora/Cognitiva/Lectura) con descripciones de una lÃ­nea.
- Incluye preview en vivo: escena de prueba (texto, sÃ­mbolos de estado, botones) que reacciona a los controles, escena de color para ver filtros de daltonismo sobre una muestra del mundo voxel.
- Botones: "Restablecer a valores por defecto", "Restablecer secciÃ³n", "Aplicar" (aplicaciÃ³n continua, el botÃ³n solo confirma/cierra).
- Atajo global F10 (configurable) + acceso desde el menÃº de pausa y desde el tÃ­tulo.

## 2. Flujos

### 2.1 Arranque (boot)

```
Godot boot â†’ SettingsManager._ready() (primer autoload)
  â†’ user://accesibilidad/profile.json existe?
      â”œâ”€ SÃ­   â†’ validar y coerce â†’ profile_loaded
      â””â”€ No   â†’ defaults â†’ guardar primera versiÃ³n
  â†’ AccessibilityApplier.apply(profile)   (filtro de color ya activo)
  â†’ Cargar escena TÃ­tulo â†’ los menÃºs usan el perfil aplicado
```

### 2.2 Cambio de opciÃ³n (vivo)

```
Jugador mueve slider en AccessibilityMenuUI
  â†’ MenuUI.set_setting(clave, valor)  (solo reenvÃ­o, sin lÃ³gica)
  â†’ SettingsManager.set_setting â†’ profile_changed(profile)
  â†’ AccessibilityApplier.apply_profile(profile)   (deltas por Ã¡rea)
  â†’ Preview actualiza en el mismo frame
  â†’ Autosave del perfil: debounce 2 s (no escribir por cada tick de slider)
```

### 2.3 Persistencia (atÃ³mica)

```
SettingsManager.save()
  1. Escribir user://accesibilidad/profile.json.tmp
  2. fsync/cerrar â†’ renombrar .tmp â†’ profile.json
  3. Copiar backup: profile.json â†’ profile.backup.json
  4. Si falla el paso 2/3 â†’ conservar backup como Ãºltima versiÃ³n vÃ¡lida.
```

### 2.4 Carga con corrupciÃ³n o versiÃ³n antigua

```
JSON ilegible / campos faltantes
  â†’ marcar defectos, cargar defaults para esos campos
  â†’ cargar profile.backup.json si existe para intentar recuperar el resto
  â†’ notify_once("Se restablecieron algunas opciones de accesibilidad")
  â†’ guardar perfil saneado
```

## 3. Persistencia de preferencias

| Aspecto | DecisiÃ³n |
|---|---|
| UbicaciÃ³n | `user://accesibilidad/profile.json` + `profile.backup.json` |
| Formato | JSON con versiÃ³n (`"version": 1`) â€” abre a migraciones futuras |
| Momento de escritura | Debounce 2 s tras cambios + al cerrar/guardar partida + al cambiar a menÃº de tÃ­tulo |
| Escritura | AtÃ³mica con archivo temporal y renombre (misma convenciÃ³n que M57) |
| ValidaciÃ³n | Coerce de tipos, rangos recortados, claves desconocidas ignoradas |
| Reset | `reset()` restaura preset por defecto y guarda de inmediato |
| Multi-partida | El perfil es global al jugador (no por partida) para que el tÃ­tulo sea accesible antes de cargar |

## 4. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M53 (UI-UX) | MenÃº "Accesibilidad" dentro de Opciones; la UI consume SettingsManager; escalado aplicado al nodo raÃ­z; navegaciÃ³n por foco. |
| M57 (Interfaz de Control) | Remapeo completo y perfiles de control expuestos; M58 aÃ±ade presets (`single_hand`, `low_mobility`), vibraciÃ³n OFF y acciÃ³n retenciÃ³n/alternancia por acciÃ³n. |
| M88 (Fuentes) | `text_scale` y `reading_options` consumen el theme tipogrÃ¡fico; "Texto grande" escala vÃ­a theme override sin reimportar. |
| M90 (ConfiguraciÃ³n GrÃ¡fica) | Fallback de filtro de color segÃºn preset (shader en media/alta, modulate en baja); el modo de reducciÃ³n de movimiento desactiva motion blur propio de M90. |
| M91 (ConfiguraciÃ³n de Audio) | SubtitleManager recibe el perfil de subtÃ­tulos de M58 (tamaÃ±o/fondo/velocidad/activo); volÃºmenes por bus referenciados; indicadores visuales de eventos de audio. |
| M12 (CÃ¡mara) | Factor `motion_reduction` aplicado a shake, parallax y transiciones de cÃ¡mara. |
| Sistemas de juego (M34/M35/combate) | `aim_assist`, `serene_combat`, `extended_timers` leÃ­dos como configuraciÃ³n; cero cambios en su core. |
| Persistencia de partida | El `autosave_interval` se comunica al sistema de guardado (M-persistencia) para autosaves frecuentes sin pausa. |
| M87 (InternacionalizaciÃ³n) | Los textos del menÃº usan keys de traducciÃ³n; el TTS futuro se dispara sobre el texto localizado. |

## 5. Diagrama de estados del perfil

```
[DEFAULT] â†’ (editado) â†’ [EDITADO] â†’ save() â†’ [PERSISTIDO] â†’ (corrupciÃ³n) â†’ [RECUPERADO]
   â†‘            â”‚                                   â”‚                      â”‚
   â””â”€â”€ reset() â”€â”˜                                   â””â†’ backup â†’ recovery â”€â”€â”€â”˜
```

## 6. Verificabilidad del diseÃ±o

- El 05-Checklist.md cubre la implementaciÃ³n de estas piezas Ã­tem por Ã­tem (â‰¥ 125 Ã­tems).
- Todas las rutas y firmas de archivos previstos estÃ¡n en 04-Codigo.md marcadas "Pendiente de implementaciÃ³n".
- Criterio de aceptaciÃ³n: aplicar cualquier opciÃ³n en vivo y persistirla entre reinicios con cero errores en consola.
## Specs Accesibilidad (Beam 512)

### Texto grande no desborda diálogos ni inventario (M53)
- Spec: RF27: verificar que el texto grande no desborde diálogos ni inventario (M53). Coherente con M58 (accesibilidad) y M53 (UI).

### Texto grande con inventario lleno (36 slots) sin cortes
- Spec: texto grande con inventario lleno (36 slots) → sin elementos cortados. Coherente con M58 (accesibilidad) y M53 (UI).

### Escaneo de interactuables para contornos solo en radio cercano
- Spec: escaneo de interactuables para contornos solo en radio cercano al jugador. Coherente con M58 (accesibilidad) y M61 (rendimiento).

### M58 no suma draw calls perceptibles (M61)
- Spec: verificar que M58 no sume draw calls perceptibles en escenas pobladas (M61). Coherente con M58 (accesibilidad) y M61 (rendimiento).

## Specs Accesibilidad (Beam 714)

### Verificar legibilidad de la UI de M53 con escala 200% sin cortes
- Spec: verificar legibilidad de la UI de M53 con escala 200% sin cortes. Coherente with M58 (accesibilidad) and M53 (UI).

### RF17: exponer dead zones, sensibilidad por eje e inversion como accesos directos (M57)
- Spec: RF17: exponer dead zones, sensibilidad por eje e inversion como accesos directos (M57). Coherente with M58 (accesibilidad) and M57 (interfaz).

### Definir que el remapeo respete los conflictos detectados por M57
- Spec: definir que el remapeo respete los conflictos detectados por M57. Coherente with M58 (accesibilidad) and M57 (interfaz).

### Integrar con M53: previews dentro del menu sin escenas externas
- Spec: integrar con M53: previews dentro del menu sin escenas externas. Coherente with M58 (accesibilidad) and M53 (UI).

### Integrar con M57: dead zones/sensibilidad expuestos como accesos directos en el menu
- Spec: integrar con M57: dead zones/sensibilidad expuestos como accesos directos en el menu. Coherente with M58 (accesibilidad) and M57 (interfaz).


## Specs Accesibilidad (Beam 715)

### Mando desconectado a mitad de sesion -> perfil intacto, prompts actualizados por M57
- Spec: mando desconectado a mitad de sesion -> perfil intacto, prompts actualizados por M57. Coherente with M58 (accesibilidad) and M57 (interfaz).

### Apertura del menu de accesibilidad durante combate -> pausa correcta sin perdida de estado
- Spec: apertura del menu de accesibilidad durante combate -> pausa correcta sin perdida de estado. Coherente with M58 (accesibilidad) and M53 (UI).

### Focus del teclado perdido al abrir atajo global -> restaurado al volver al menu
- Spec: focus del teclado perdido al abrir atajo global -> restaurado al volver al menu. Coherente with M58 (accesibilidad) and M53 (UI).

### Aplicar el perfil solo con deltas por area, no reconstruir toda la UI
- Spec: aplicar el perfil solo con deltas por area, no reconstruir toda la UI. Coherente with M58 (accesibilidad) and M53 (UI).

### Carteles de alerta con tiempo de vida y fade-out sin tween acumulados
- Spec: carteles de alerta con tiempo de vida y fade-out sin tween acumulados. Coherente with M58 (accesibilidad) and M53 (UI).
