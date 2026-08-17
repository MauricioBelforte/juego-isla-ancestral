**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 58: Accesibilidad

## 1. Arquitectura

El módulo sigue la regla de desacoplamiento del proyecto: **ninguna lógica vive en la UI**. Cuatro piezas componen el sistema:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SettingsManager (autoload)                    │
│  - Carga/guarda/valida AccessibilityProfile (JSON user://)            │
│  - Emite señales: profile_loaded, profile_changed, profile_reset      │
│  - Expone helpers: get_setting(), is_reduced_motion(), etc.           │
└───────────┬─────────────────────────────────────────┬────────────────┘
            │ consulta                              │ aplica
            ▼                                        ▼
┌─────────────────────────┐            ┌─────────────────────────────────┐
│  AccessibilityProfile   │            │  AccessibilityApplier           │
│  (Resource, serializable)│           │  - Aplica perfil en vivo       │
│  - campos por área      │            │  - Escala UI (M53), texto (M88) │
│  - presets predefinidos │            │  - Filtro de color (shader)     │
└─────────────────────────┘            │  - Factor de movimiento (M12)   │
                                       │  - SubtitleProfile (M91)        │
        ▲                              └──────────────┬──────────────────┘
        │ lee/escribe                                 │ señala
┌───────┴───────────────┐                ┌─────────────▼──────────────────┐
│ AccessibilityMenuUI   │                │  Sistemas consumidores:        │
│ (vista en M53, sin    │                │  Input (M57), Fuentes (M88),   │
│  lógica de gameplay)  │                │  Gráficos (M90), Audio (M91),  │
└───────────────────────┘                │  Controles de juego (M34/M35…) │
                                         └────────────────────────────────┘
```

### 1.1 SettingsManager (autoload, nodo global)

| Responsabilidad | Detalle |
|---|---|
| Persistencia | Lee `user://accesibilidad/profile.json` al arranque; escritura atómica (temp + rename) y backup `profile.backup.json`. |
| Validación | Coerce tipos; si el JSON está corrupto o desactualizado → defaults + aviso (una vez por sesión). |
| Señales | `profile_loaded(profile)`, `profile_changed(profile)`, `profile_reset()`. |
| API pública | `get_profile()`, `get_setting(key)`, `set_setting(key, value)`, `save()`, `reset()`, `apply()`. |
| Acceso pre-título | Instanciado como primer autoload para que el filtro de color/contraste ya exista cuando se muestra el logo. |

### 1.2 AccessibilityProfile (Resource)

| Campo | Rango / valores | Área |
|---|---|---|
| `color_filter` | `none / protanopia / deuteranopia / tritanopia` | Visual |
| `color_filter_intensity` | 0.0–1.0 | Visual |
| `high_contrast` | bool + `contrast` 1.0–2.0, `brightness` 0.8–1.2, `saturation` 0.0–1.5 | Visual |
| `ui_scale` | 0.8–2.0 (paso 0.1) | Visual |
| `text_scale` | `normal / large / extra_large` (delega en M88) | Visual |
| `interactable_outlines` | bool | Visual |
| `ui_background_opacity` | 0.0–1.0 | Visual |
| `subtitles_enabled` | bool (default true) | Auditiva |
| `subtitle_size` / `subtitle_background_opacity` | 0.8–2.0 / 0.0–1.0 | Auditiva |
| `subtitle_speed` | 0.5–2.0 | Auditiva |
| `audio_indicators` | bool (rizos visuales) | Auditiva |
| `visual_alert_cards` | bool | Auditiva |
| `action_mode` | `hold / toggle` por acción | Motora |
| `aim_assist` | 0.0–1.0 | Motora |
| `vibration_enabled` | bool | Motora |
| `input_preset` | `default / single_hand / low_mobility` | Motora |
| `difficulty` | `serene / standard / custom` | Cognitiva |
| `serene_combat` | bool (sin combate estresante) | Cognitiva |
| `extended_timers` | bool / factor | Cognitiva |
| `motion_reduction` | 0.0–1.0 (factor anti-mareo) | Cognitiva |
| `guidance_level` | `minimal / standard / reinforced` (marcadores de objetivo) | Cognitiva |
| `dialogue_pace` | `player_controlled / slow / standard` | Cognitiva |
| `reading_options` | `spacing` 0.8–1.5, `line_height` 0.9–1.6 | Lectoescritura |
| `global_large_text` | bool | Lectoescritura |
| `autosave_interval` | 1–30 min (default 5) | Sistema |
| `accessibility_shortcut` | `f10 / custom / off` | Sistema |

Presets predefinidos (static): `DEFAULT`, `PREVENT_MOTION_SICKNESS`, `HIGH_CONTRAST`, `SERENE_MODE`, `SINGLE_HAND`.

### 1.3 AccessibilityApplier (servicio)

- Aplica el perfil a los nodos objetivo: escala de layout (nodo raíz de UI, M53), escala de texto (theme de M88), opacidad de fondos, outlines de interactuables.
- Activa/desactiva el **ColorFilter** (CanvasLayer con shader passthrough o fallback `modulate` según preset gráfico de M90).
- Informa a **InputManager (M57)** de cambios de remapeo descargados (presets `single_hand`, `low_mobility`) y de vibración.
- Informa a **SubtitleManager (M91)** del perfil de subtítulos.
- Informa a **M12 (cámara)** del factor `motion_reduction` para shake/parallax/transiciones.
- Informa a sistemas de juego (M34 pesca, M35 minería, combate) del nivel `aim_assist` y de los flags de dificultad; estos sistemas solo LEEN valores, nunca escriben.

### 1.4 AccessibilityMenuUI (vista)

- Vive dentro del árbol de UI de M53 (menú Opciones → pestaña "Accesibilidad"), sin lógica de gameplay.
- Organizado por áreas (Visual/Auditiva/Motora/Cognitiva/Lectura) con descripciones de una línea.
- Incluye preview en vivo: escena de prueba (texto, símbolos de estado, botones) que reacciona a los controles, escena de color para ver filtros de daltonismo sobre una muestra del mundo voxel.
- Botones: "Restablecer a valores por defecto", "Restablecer sección", "Aplicar" (aplicación continua, el botón solo confirma/cierra).
- Atajo global F10 (configurable) + acceso desde el menú de pausa y desde el título.

## 2. Flujos

### 2.1 Arranque (boot)

```
Godot boot → SettingsManager._ready() (primer autoload)
  → user://accesibilidad/profile.json existe?
      ├─ Sí   → validar y coerce → profile_loaded
      └─ No   → defaults → guardar primera versión
  → AccessibilityApplier.apply(profile)   (filtro de color ya activo)
  → Cargar escena Título → los menús usan el perfil aplicado
```

### 2.2 Cambio de opción (vivo)

```
Jugador mueve slider en AccessibilityMenuUI
  → MenuUI.set_setting(clave, valor)  (solo reenvío, sin lógica)
  → SettingsManager.set_setting → profile_changed(profile)
  → AccessibilityApplier.apply_profile(profile)   (deltas por área)
  → Preview actualiza en el mismo frame
  → Autosave del perfil: debounce 2 s (no escribir por cada tick de slider)
```

### 2.3 Persistencia (atómica)

```
SettingsManager.save()
  1. Escribir user://accesibilidad/profile.json.tmp
  2. fsync/cerrar → renombrar .tmp → profile.json
  3. Copiar backup: profile.json → profile.backup.json
  4. Si falla el paso 2/3 → conservar backup como última versión válida.
```

### 2.4 Carga con corrupción o versión antigua

```
JSON ilegible / campos faltantes
  → marcar defectos, cargar defaults para esos campos
  → cargar profile.backup.json si existe para intentar recuperar el resto
  → notify_once("Se restablecieron algunas opciones de accesibilidad")
  → guardar perfil saneado
```

## 3. Persistencia de preferencias

| Aspecto | Decisión |
|---|---|
| Ubicación | `user://accesibilidad/profile.json` + `profile.backup.json` |
| Formato | JSON con versión (`"version": 1`) — abre a migraciones futuras |
| Momento de escritura | Debounce 2 s tras cambios + al cerrar/guardar partida + al cambiar a menú de título |
| Escritura | Atómica con archivo temporal y renombre (misma convención que M57) |
| Validación | Coerce de tipos, rangos recortados, claves desconocidas ignoradas |
| Reset | `reset()` restaura preset por defecto y guarda de inmediato |
| Multi-partida | El perfil es global al jugador (no por partida) para que el título sea accesible antes de cargar |

## 4. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M53 (UI-UX) | Menú "Accesibilidad" dentro de Opciones; la UI consume SettingsManager; escalado aplicado al nodo raíz; navegación por foco. |
| M57 (Interfaz de Control) | Remapeo completo y perfiles de control expuestos; M58 añade presets (`single_hand`, `low_mobility`), vibración OFF y acción retención/alternancia por acción. |
| M88 (Fuentes) | `text_scale` y `reading_options` consumen el theme tipográfico; "Texto grande" escala vía theme override sin reimportar. |
| M90 (Configuración Gráfica) | Fallback de filtro de color según preset (shader en media/alta, modulate en baja); el modo de reducción de movimiento desactiva motion blur propio de M90. |
| M91 (Configuración de Audio) | SubtitleManager recibe el perfil de subtítulos de M58 (tamaño/fondo/velocidad/activo); volúmenes por bus referenciados; indicadores visuales de eventos de audio. |
| M12 (Cámara) | Factor `motion_reduction` aplicado a shake, parallax y transiciones de cámara. |
| Sistemas de juego (M34/M35/combate) | `aim_assist`, `serene_combat`, `extended_timers` leídos como configuración; cero cambios en su core. |
| Persistencia de partida | El `autosave_interval` se comunica al sistema de guardado (M-persistencia) para autosaves frecuentes sin pausa. |
| M87 (Internacionalización) | Los textos del menú usan keys de traducción; el TTS futuro se dispara sobre el texto localizado. |

## 5. Diagrama de estados del perfil

```
[DEFAULT] → (editado) → [EDITADO] → save() → [PERSISTIDO] → (corrupción) → [RECUPERADO]
   ↑            │                                   │                      │
   └── reset() ─┘                                   └→ backup → recovery ───┘
```

## 6. Verificabilidad del diseño

- El 05-Checklist.md cubre la implementación de estas piezas ítem por ítem (≥ 125 ítems).
- Todas las rutas y firmas de archivos previstos están en 04-Codigo.md marcadas "Pendiente de implementación".
- Criterio de aceptación: aplicar cualquier opción en vivo y persistirla entre reinicios con cero errores en consola.