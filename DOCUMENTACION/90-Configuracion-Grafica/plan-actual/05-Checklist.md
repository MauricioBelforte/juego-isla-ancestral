**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 90: Configuración Gráfica

## Checklist de implementación del módulo

### [S] Especificación de configuración gráfica
- [x] Resolución
- [x] Pantalla completa
- [x] Ventana
- [x] Borderless
- [x] VSync
- [x] FPS
- [x] Calidad de sombras
- [x] Calidad de texturas
- [x] Distancia de dibujado
- [x] Calidad de efectos
- [x] Calidad de vegetación
- [x] Calidad de agua
- [x] Calidad de partículas
- [x] Anti-aliasing
- [x] Anisotropic filtering
- [x] Post-processing
- [x] Bloom
- [x] Motion blur
- [x] Depth of field
- [x] FSR/DLSS/XeSS si corresponde
- [x] Escala de resolución
- [x] Presets gráficos
- [x] Detección automática

### [S] Resoluciones
- [x] Definir 720p (1280x720)
- [x] Definir 1080p (1920x1080)
- [x] Definir 1440p (2560x1440)
- [x] Definir 4K (3840x2160)
- [x] Definir nativa (resolución del monitor)
- [x] Definir aspect ratio 16:9
- [x] Definir soporte para 16:10
- [x] Definir soporte para 21:9

### [S] Modos de pantalla
- [x] Definir pantalla completa (fullscreen)
- [x] Definir ventana (windowed)
- [x] Definir borderless (borderless windowed)
- [x] Definir toggle de pantalla completa (F11 o botón)
- [x] Definir modo ventana para multitasking
- [x] Definir borderless para pantalla completa sin bloquear otros monitores

### [S] VSync
- [x] Definir VSync 0 (off)
- [x] Definir VSync 1 (on)
- [x] Definir VSync 2 (adaptive)
- [x] Definir recomendación por preset (bajo: 0, medio: 1, alto: 2, ultra: 2)

### [S] Cap de FPS
- [x] Definir 30 FPS (hardware muy bajo)
- [x] Definir 60 FPS (hardware medio, recomendado)
- [x] Definir 120 FPS (hardware alto)
- [x] Definir ilimitado (hardware ultra)
- [x] Definir recomendación por preset (bajo: 30, medio: 60, alto: 120, ultra: ilimitado)

### [S] Calidad de sombras
- [x] Definir baja (cascada simple, 1 shadow map, 512x512)
- [x] Definir media (cascada suave, 2 shadow maps, 1024x1024)
- [x] Definir alta (PCSS, 4 shadow maps, 2048x2048)
- [x] Definir ultra (cascada soft shadows, 4 shadow maps, 4096x4096)
- [x] Definir implementación (DirectionalLight, OmnidirectionalLight, SpotLight)
- [x] Definir soft shadows para calidad alta/ultra

### [S] Calidad de texturas
- [x] Definir baja (0.5x, mipmap 0)
- [x] Definir media (1x, mipmap 1)
- [x] Definir alta (2x, mipmap 2)
- [x] Definir ultra (4x, mipmap 3)
- [x] Definir filtering (trilinear)
- [x] Definir anisotropic filtering por calidad (2x, 4x, 8x, 16x)
- [x] Definir mipmaps habilitados

### [S] Distancia de dibujado
- [x] Definir cercana (50 unidades, 100m)
- [x] Definir media (100 unidades, 200m)
- [x] Definir lejana (200 unidades, 400m)
- [x] Definir culling de objetos fuera de distancia
- [x] Definir LODs para objetos lejanos (M50)
- [x] Definir fog para ocultar transición

### [S] Calidad de efectos
- [x] Definir baja (partículas básicas, sin post-processing)
- [x] Definir media (partículas estándar, post-processing básico)
- [x] Definir alta (partículas avanzadas, post-processing completo)
- [x] Definir ultra (partículas máximas, post-processing cinemático)
- [x] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad)

### [S] Calidad de vegetación
- [x] Definir baja (sin animación, LOD 0 solo)
- [x] Definir media (animación básica, LOD 0-1)
- [x] Definir alta (animación completa, LOD 0-2)
- [x] Definir ultra (animación + wind procedural + interacción, LOD 0-3)
- [x] Definir animación por wind shader
- [x] Definir interacción con jugador

### [S] Calidad de agua
- [x] Definir baja (sin reflexiones, textura simple)
- [x] Definir media (reflexiones básicas, textura normal)
- [x] Definir alta (reflexiones completas, textura normal + parallax)
- [x] Definir ultra (reflexiones + caustics, textura normal + parallax + caustics)
- [x] Definir shader de agua con reflexiones
- [x] Definir normal map para olas
- [x] Definir parallax para profundidad
- [x] Definir caustics para ultra

### [S] Calidad de partículas
- [x] Definir baja (100 partículas máximas por sistema)
- [x] Definir media (500 partículas máximas por sistema)
- [x] Definir alta (1000 partículas máximas por sistema)
- [x] Definir ultra (2000 partículas máximas por sistema)
- [x] Definir GPU particles para rendimiento
- [x] Definir colisión de partículas con world
- [x] Definir partículas para fuego, humo, agua, magia, polvo

### [S] Anti-aliasing
- [x] Definir off (sin anti-aliasing)
- [x] Definir FXAA (Fast Approximate Anti-Aliasing)
- [x] Definir MSAA 2x (Multi-Sample Anti-Aliasing 2x)
- [x] Definir MSAA 4x (Multi-Sample Anti-Aliasing 4x)
- [x] Definir TAA (Temporal Anti-Aliasing)
- [x] Definir recomendación por preset (bajo: off/FXAA, medio: FXAA, alto: MSAA 2x, ultra: TAA)

### [S] Anisotropic filtering
- [x] Definir off (sin anisotropic filtering)
- [x] Definir 2x (calidad baja)
- [x] Definir 4x (calidad media)
- [x] Definir 8x (calidad alta)
- [x] Definir 16x (calidad ultra)
- [x] Definir recomendación por preset (bajo: off/2x, medio: 4x, alto: 8x, ultra: 16x)

### [S] Post-processing
- [x] Definir toggle de post-processing
- [x] Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
- [x] Definir activación/desactivación de todos los efectos

### [S] Bloom
- [x] Definir toggle de bloom
- [x] Definir intensidad (slider 0-1)
- [x] Definir threshold (slider 0-1)
- [x] Definir radius (slider 0-1)
- [x] Definir bloom shader para glow
- [x] Definir threshold para fuentes de luz brillantes

### [S] Motion blur
- [x] Definir toggle de motion blur
- [x] Definir intensidad (slider 0-1)
- [x] Definir sample count (slider 4-16)
- [x] Definir motion blur basado en velocidad de cámara
- [x] Definir más blur cuando la cámara se mueve más rápido
- [x] Definir desactivado por defecto (causa mareo)

### [S] Depth of field
- [x] Definir toggle de depth of field
- [x] Definir intensidad (slider 0-1)
- [x] Definir distancia (slider 0-100)
- [x] Definir aperture (slider 0-1)
- [x] Definir depth of field basado en distancia de la cámara
- [x] Definir blur para objetos fuera de foco
- [x] Definir aperture controla cuánto blur

### [S] Upscaling
- [x] Definir FSR 1.0 (AMD)
- [x] Definir FSR 2.0 (AMD mejorado)
- [x] Definir DLSS (NVIDIA)
- [x] Definir XeSS (Intel)
- [x] Definir detección de GPU y habilitación correspondiente
- [x] Definir recomendación por preset (bajo: FSR 1.0, medio: FSR 2.0, alto: DLSS, ultra: DLSS ultra)

### [S] Escala de resolución
- [x] Definir 50% (render mitad, escalar a completa)
- [x] Definir 75% (render 3/4, escalar a completa)
- [x] Definir 100% (render completo)
- [x] Definir 125% (oversampling 1.25x)
- [x] Definir 150% (oversampling 1.5x)
- [x] Definir recomendación por preset (bajo: 50%, medio: 75%, alto: 100%, ultra: 100% o 125%)

### [S] Presets gráficos
- [x] Definir preset bajo (720p, calidad baja, VSync 0, 30 FPS, escala 50%)
- [x] Definir preset medio (1080p, calidad media, VSync 1, 60 FPS, escala 75%)
- [x] Definir preset alto (1440p, calidad alta, VSync 2, 120 FPS, escala 100%)
- [x] Definir preset ultra (4K, calidad ultra, VSync 2, ilimitado FPS, escala 100%)
- [x] Definir preset personalizado
- [x] Definir botones de preset en settings
- [x] Definir aplicación automática al seleccionar preset
- [x] Definir guardado de preset personalizado en settings

### [S] Detección automática
- [x] Definir detección de GPU (RenderingServer.get_video_adapter_name())
- [x] Definir detección de RAM (OS.get_static_memory_usage())
- [x] Definir detección de CPU (OS.get_processor_name())
- [x] Definir lógica de recomendación de preset según hardware
- [x] Definir GPU baja + RAM baja + CPU baja → preset bajo
- [x] Definir GPU media + RAM media + CPU media → preset medio
- [x] Definir GPU alta + RAM alta + CPU alta → preset alto
- [x] Definir GPU ultra + RAM ultra + CPU ultra → preset ultra

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [x] Diseñar alto contraste (toggle)
- [x] Diseñar reducción de motion blur (opción para reducir mareo)
- [x] Diseñar reducción de bloom (opción para reducir distracción visual)
- [x] Diseñar ajustes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [x] Diseñar aplicación en tiempo real

### [S] Integración con M61 (Rendimiento)
- [x] Diseñar FPS counter (opcional, en debug)
- [x] Diseñar profiling de GPU (opcional, en debug)
- [x] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug)
- [x] Diseñar FPS counter visible en debug (M110)
- [x] Diseñar profiling visible en debug (M110)
- [x] Diseñar monitoreo visible en debug (M110)

### [S] Integración con M88 (Fuentes Tipográficas)
- [x] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [x] Diseñar alto contraste (toggle)
- [x] Diseñar ajustes de fuentes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [x] Diseñar aplicación en tiempo real

### [S] Menú de configuración gráfica
- [x] Diseñar GraphicsSettingsMenu
- [x] Diseñar controles para resolución (dropdown)
- [x] Diseñar controles para pantalla completa (toggle)
- [x] Diseñar controles para ventana (toggle)
- [x] Diseñar controles para borderless (toggle)
- [x] Diseñar controles para VSync (dropdown)
- [x] Diseñar controles para FPS cap (dropdown)
- [x] Diseñar controles para escala de resolución (slider)
- [x] Diseñar controles para upscaling (dropdown)
- [x] Diseñar controles para calidad de sombras (dropdown)
- [x] Diseñar controles para calidad de texturas (dropdown)
- [x] Diseñar controles para distancia de dibujado (slider)
- [x] Diseñar controles para calidad de efectos (dropdown)
- [x] Diseñar controles para calidad de vegetación (dropdown)
- [x] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown)
- [x] Diseñar controles para anti-aliasing (dropdown)
- [x] Diseñar controles para anisotropic filtering (dropdown)
- [x] Diseñar controles para post-processing (toggle)
- [x] Diseñar controles para bloom (toggle + slider)
- [x] Diseñar controles para motion blur (toggle + slider)
- [x] Diseñar controles para depth of field (toggle + slider)
- [x] Diseñar botones de preset (bajo, medio, alto, ultra)
- [x] Diseñar etiqueta de preset actual
- [x] Diseñar botón de detección automática

### [S] Configuración de settings
- [x] Diseñar GraphicsSettings (Resource)
- [x] Diseñar campos: resolution, fullscreen, borderless, vsync, fps_cap, resolution_scale, upscaling, shadows_quality, textures_quality, draw_distance, effects_quality, vegetation_quality, water_quality, particles_quality, anti_aliasing, anisotropic_filtering, post_processing, bloom, bloom_intensity, motion_blur, motion_blur_intensity, depth_of_field, depth_of_field_intensity, preset
- [x] Diseñar método apply_settings()

### [S] Presets gráficos
- [x] Diseñar GraphicsPresets
- [x] Diseñar diccionario PRESETS con 4 presets (bajo, medio, alto, ultra)
- [x] Diseñar método apply_preset()
- [x] Diseñar aplicación automática de preset al GraphicsSettings
- [x] Diseñar actualización de preset en GraphicsSettings.preset

### [S] Detección de hardware
- [x] Diseñar HardwareDetector
- [x] Diseñar método detect_hardware()
- [x] Diseñar método recommend_preset()
- [x] Diseñar lógica de recomendación según GPU, RAM, CPU

### [S] Aplicación de configuración
- [x] Diseñar GraphicsApplier
- [x] Diseñar método apply_resolution()
- [x] Diseñar método apply_vsync()
- [x] Diseñar método apply_fps_cap()
- [x] Diseñar método apply_shadows_quality()
- [x] Diseñar método apply_textures_quality()
- [x] Diseñar método apply_anti_aliasing()

### [S] Carga de configuración
- [x] Diseñar GraphicsSettingsLoader
- [x] Diseñar método load_settings()
- [x] Diseñar carga desde user://settings/graphics_settings.json
- [x] Diseñar parseo de JSON
- [x] Diseñar aplicación de configuración al inicio
- [x] Diseñar fallback a preset medio si no existe configuración

### [S] Guardado de configuración
- [x] Diseñar GraphicsSettingsSaver
- [x] Diseñar método save_settings()
- [x] Diseñar guardado en user://settings/graphics_settings.json
- [x] Diseñar serialización de settings a JSON
- [x] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] Diseñar formato de graphics_settings.json
- [x] Incluir todos los campos de GraphicsSettings
- [x] Incluir resolución como objeto {x, y}
- [x] Incluir preset como string

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración gráfica → Usuario selecciona preset o ajusta opciones → GraphicsSettings se actualiza → GraphicsApplier aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (presets en diferentes hardware, ajustes individuales, aplicación en tiempo real, guardado y carga, detección automática)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, detección de hardware)
- [x] Diseñar pruebas de legibilidad en 720p
- [x] Diseñar pruebas de legibilidad en 1080p
- [x] Diseñar pruebas de legibilidad en 4K
- [x] Diseñar pruebas de soporte de tildes
- [x] Diseñar pruebas de soporte de ñ
- [x] Diseñar pruebas de soporte de símbolos
- [x] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
- [x] Diseñar pruebas de ajustes de accesibilidad
- [x] Diseñar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA)
- [x] Diseñar tests de presets gráficos
- [x] Diseñar tests de ajustes individuales
- [x] Diseñar tests de aplicación en tiempo real
- [x] Diseñar tests de guardado y carga de configuración
- [x] Diseñar tests de detección automática de hardware

## Totales

**Total de ítems:** 248
**Ítems resueltos por documentación:** 248
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
