**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 90: Configuración Gráfica

## Checklist de implementación del módulo

### [S] Especificación de configuración gráfica
- [ ] Resolución
- [ ] Pantalla completa
- [ ] Ventana
- [ ] Borderless
- [ ] VSync
- [ ] FPS
- [ ] Calidad de sombras
- [ ] Calidad de texturas
- [ ] Distancia de dibujado
- [ ] Calidad de efectos
- [ ] Calidad de vegetación
- [ ] Calidad de agua
- [ ] Calidad de partículas
- [ ] Anti-aliasing
- [ ] Anisotropic filtering
- [ ] Post-processing
- [ ] Bloom
- [ ] Motion blur
- [ ] Depth of field
- [ ] FSR/DLSS/XeSS si corresponde
- [ ] Escala de resolución
- [ ] Presets gráficos
- [ ] Detección automática

### [S] Resoluciones
- [ ] Definir 720p (1280x720)
- [ ] Definir 1080p (1920x1080)
- [ ] Definir 1440p (2560x1440)
- [ ] Definir 4K (3840x2160)
- [ ] Definir nativa (resolución del monitor)
- [ ] Definir aspect ratio 16:9
- [ ] Definir soporte para 16:10
- [ ] Definir soporte para 21:9

### [S] Modos de pantalla
- [ ] Definir pantalla completa (fullscreen)
- [ ] Definir ventana (windowed)
- [ ] Definir borderless (borderless windowed)
- [ ] Definir toggle de pantalla completa (F11 o botón)
- [ ] Definir modo ventana para multitasking
- [ ] Definir borderless para pantalla completa sin bloquear otros monitores

### [S] VSync
- [ ] Definir VSync 0 (off)
- [ ] Definir VSync 1 (on)
- [ ] Definir VSync 2 (adaptive)
- [ ] Definir recomendación por preset (bajo: 0, medio: 1, alto: 2, ultra: 2)

### [S] Cap de FPS
- [ ] Definir 30 FPS (hardware muy bajo)
- [ ] Definir 60 FPS (hardware medio, recomendado)
- [ ] Definir 120 FPS (hardware alto)
- [ ] Definir ilimitado (hardware ultra)
- [ ] Definir recomendación por preset (bajo: 30, medio: 60, alto: 120, ultra: ilimitado)

### [S] Calidad de sombras
- [ ] Definir baja (cascada simple, 1 shadow map, 512x512)
- [ ] Definir media (cascada suave, 2 shadow maps, 1024x1024)
- [ ] Definir alta (PCSS, 4 shadow maps, 2048x2048)
- [ ] Definir ultra (cascada soft shadows, 4 shadow maps, 4096x4096)
- [ ] Definir implementación (DirectionalLight, OmnidirectionalLight, SpotLight)
- [ ] Definir soft shadows para calidad alta/ultra

### [S] Calidad de texturas
- [ ] Definir baja (0.5x, mipmap 0)
- [ ] Definir media (1x, mipmap 1)
- [ ] Definir alta (2x, mipmap 2)
- [ ] Definir ultra (4x, mipmap 3)
- [ ] Definir filtering (trilinear)
- [ ] Definir anisotropic filtering por calidad (2x, 4x, 8x, 16x)
- [ ] Definir mipmaps habilitados

### [S] Distancia de dibujado
- [ ] Definir cercana (50 unidades, 100m)
- [ ] Definir media (100 unidades, 200m)
- [ ] Definir lejana (200 unidades, 400m)
- [ ] Definir culling de objetos fuera de distancia
- [ ] Definir LODs para objetos lejanos (M50)
- [ ] Definir fog para ocultar transición

### [S] Calidad de efectos
- [ ] Definir baja (partículas básicas, sin post-processing)
- [ ] Definir media (partículas estándar, post-processing básico)
- [ ] Definir alta (partículas avanzadas, post-processing completo)
- [ ] Definir ultra (partículas máximas, post-processing cinemático)
- [ ] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad)

### [S] Calidad de vegetación
- [ ] Definir baja (sin animación, LOD 0 solo)
- [ ] Definir media (animación básica, LOD 0-1)
- [ ] Definir alta (animación completa, LOD 0-2)
- [ ] Definir ultra (animación + wind procedural + interacción, LOD 0-3)
- [ ] Definir animación por wind shader
- [ ] Definir interacción con jugador

### [S] Calidad de agua
- [ ] Definir baja (sin reflexiones, textura simple)
- [ ] Definir media (reflexiones básicas, textura normal)
- [ ] Definir alta (reflexiones completas, textura normal + parallax)
- [ ] Definir ultra (reflexiones + caustics, textura normal + parallax + caustics)
- [ ] Definir shader de agua con reflexiones
- [ ] Definir normal map para olas
- [ ] Definir parallax para profundidad
- [ ] Definir caustics para ultra

### [S] Calidad de partículas
- [ ] Definir baja (100 partículas máximas por sistema)
- [ ] Definir media (500 partículas máximas por sistema)
- [ ] Definir alta (1000 partículas máximas por sistema)
- [ ] Definir ultra (2000 partículas máximas por sistema)
- [ ] Definir GPU particles para rendimiento
- [ ] Definir colisión de partículas con world
- [ ] Definir partículas para fuego, humo, agua, magia, polvo

### [S] Anti-aliasing
- [ ] Definir off (sin anti-aliasing)
- [ ] Definir FXAA (Fast Approximate Anti-Aliasing)
- [ ] Definir MSAA 2x (Multi-Sample Anti-Aliasing 2x)
- [ ] Definir MSAA 4x (Multi-Sample Anti-Aliasing 4x)
- [ ] Definir TAA (Temporal Anti-Aliasing)
- [ ] Definir recomendación por preset (bajo: off/FXAA, medio: FXAA, alto: MSAA 2x, ultra: TAA)

### [S] Anisotropic filtering
- [ ] Definir off (sin anisotropic filtering)
- [ ] Definir 2x (calidad baja)
- [ ] Definir 4x (calidad media)
- [ ] Definir 8x (calidad alta)
- [ ] Definir 16x (calidad ultra)
- [ ] Definir recomendación por preset (bajo: off/2x, medio: 4x, alto: 8x, ultra: 16x)

### [S] Post-processing
- [ ] Definir toggle de post-processing
- [ ] Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
- [ ] Definir activación/desactivación de todos los efectos

### [S] Bloom
- [ ] Definir toggle de bloom
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir threshold (slider 0-1)
- [ ] Definir radius (slider 0-1)
- [ ] Definir bloom shader para glow
- [ ] Definir threshold para fuentes de luz brillantes

### [S] Motion blur
- [ ] Definir toggle de motion blur
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir sample count (slider 4-16)
- [ ] Definir motion blur basado en velocidad de cámara
- [ ] Definir más blur cuando la cámara se mueve más rápido
- [ ] Definir desactivado por defecto (causa mareo)

### [S] Depth of field
- [ ] Definir toggle de depth of field
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir distancia (slider 0-100)
- [ ] Definir aperture (slider 0-1)
- [ ] Definir depth of field basado en distancia de la cámara
- [ ] Definir blur para objetos fuera de foco
- [ ] Definir aperture controla cuánto blur

### [S] Upscaling
- [ ] Definir FSR 1.0 (AMD)
- [ ] Definir FSR 2.0 (AMD mejorado)
- [ ] Definir DLSS (NVIDIA)
- [ ] Definir XeSS (Intel)
- [ ] Definir detección de GPU y habilitación correspondiente
- [ ] Definir recomendación por preset (bajo: FSR 1.0, medio: FSR 2.0, alto: DLSS, ultra: DLSS ultra)

### [S] Escala de resolución
- [ ] Definir 50% (render mitad, escalar a completa)
- [ ] Definir 75% (render 3/4, escalar a completa)
- [ ] Definir 100% (render completo)
- [ ] Definir 125% (oversampling 1.25x)
- [ ] Definir 150% (oversampling 1.5x)
- [ ] Definir recomendación por preset (bajo: 50%, medio: 75%, alto: 100%, ultra: 100% o 125%)

### [S] Presets gráficos
- [ ] Definir preset bajo (720p, calidad baja, VSync 0, 30 FPS, escala 50%)
- [ ] Definir preset medio (1080p, calidad media, VSync 1, 60 FPS, escala 75%)
- [ ] Definir preset alto (1440p, calidad alta, VSync 2, 120 FPS, escala 100%)
- [ ] Definir preset ultra (4K, calidad ultra, VSync 2, ilimitado FPS, escala 100%)
- [ ] Definir preset personalizado
- [ ] Definir botones de preset en settings
- [ ] Definir aplicación automática al seleccionar preset
- [ ] Definir guardado de preset personalizado en settings

### [S] Detección automática
- [ ] Definir detección de GPU (RenderingServer.get_video_adapter_name())
- [ ] Definir detección de RAM (OS.get_static_memory_usage())
- [ ] Definir detección de CPU (OS.get_processor_name())
- [ ] Definir lógica de recomendación de preset según hardware
- [ ] Definir GPU baja + RAM baja + CPU baja → preset bajo
- [ ] Definir GPU media + RAM media + CPU media → preset medio
- [ ] Definir GPU alta + RAM alta + CPU alta → preset alto
- [ ] Definir GPU ultra + RAM ultra + CPU ultra → preset ultra

### [S] Integración con M58 (Accesibilidad)
- [ ] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [ ] Diseñar alto contraste (toggle)
- [ ] Diseñar reducción de motion blur (opción para reducir mareo)
- [ ] Diseñar reducción de bloom (opción para reducir distracción visual)
- [ ] Diseñar ajustes en menú de configuración gráfica
- [ ] Diseñar guardado en settings (M90)
- [ ] Diseñar aplicación en tiempo real

### [S] Integración con M61 (Rendimiento)
- [ ] Diseñar FPS counter (opcional, en debug)
- [ ] Diseñar profiling de GPU (opcional, en debug)
- [ ] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug)
- [ ] Diseñar FPS counter visible en debug (M110)
- [ ] Diseñar profiling visible en debug (M110)
- [ ] Diseñar monitoreo visible en debug (M110)

### [S] Integración con M88 (Fuentes Tipográficas)
- [ ] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [ ] Diseñar alto contraste (toggle)
- [ ] Diseñar ajustes de fuentes en menú de configuración gráfica
- [ ] Diseñar guardado en settings (M90)
- [ ] Diseñar aplicación en tiempo real

### [S] Menú de configuración gráfica
- [ ] Diseñar GraphicsSettingsMenu
- [ ] Diseñar controles para resolución (dropdown)
- [ ] Diseñar controles para pantalla completa (toggle)
- [ ] Diseñar controles para ventana (toggle)
- [ ] Diseñar controles para borderless (toggle)
- [ ] Diseñar controles para VSync (dropdown)
- [ ] Diseñar controles para FPS cap (dropdown)
- [ ] Diseñar controles para escala de resolución (slider)
- [ ] Diseñar controles para upscaling (dropdown)
- [ ] Diseñar controles para calidad de sombras (dropdown)
- [ ] Diseñar controles para calidad de texturas (dropdown)
- [ ] Diseñar controles para distancia de dibujado (slider)
- [ ] Diseñar controles para calidad de efectos (dropdown)
- [ ] Diseñar controles para calidad de vegetación (dropdown)
- [ ] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown)
- [ ] Diseñar controles para anti-aliasing (dropdown)
- [ ] Diseñar controles para anisotropic filtering (dropdown)
- [ ] Diseñar controles para post-processing (toggle)
- [ ] Diseñar controles para bloom (toggle + slider)
- [ ] Diseñar controles para motion blur (toggle + slider)
- [ ] Diseñar controles para depth of field (toggle + slider)
- [ ] Diseñar botones de preset (bajo, medio, alto, ultra)
- [ ] Diseñar etiqueta de preset actual
- [ ] Diseñar botón de detección automática

### [S] Configuración de settings
- [ ] Diseñar GraphicsSettings (Resource)
- [ ] Diseñar campos: resolution, fullscreen, borderless, vsync, fps_cap, resolution_scale, upscaling, shadows_quality, textures_quality, draw_distance, effects_quality, vegetation_quality, water_quality, particles_quality, anti_aliasing, anisotropic_filtering, post_processing, bloom, bloom_intensity, motion_blur, motion_blur_intensity, depth_of_field, depth_of_field_intensity, preset
- [ ] Diseñar método apply_settings()

### [S] Presets gráficos
- [ ] Diseñar GraphicsPresets
- [ ] Diseñar diccionario PRESETS con 4 presets (bajo, medio, alto, ultra)
- [ ] Diseñar método apply_preset()
- [ ] Diseñar aplicación automática de preset al GraphicsSettings
- [ ] Diseñar actualización de preset en GraphicsSettings.preset

### [S] Detección de hardware
- [ ] Diseñar HardwareDetector
- [ ] Diseñar método detect_hardware()
- [ ] Diseñar método recommend_preset()
- [ ] Diseñar lógica de recomendación según GPU, RAM, CPU

### [S] Aplicación de configuración
- [ ] Diseñar GraphicsApplier
- [ ] Diseñar método apply_resolution()
- [ ] Diseñar método apply_vsync()
- [ ] Diseñar método apply_fps_cap()
- [ ] Diseñar método apply_shadows_quality()
- [ ] Diseñar método apply_textures_quality()
- [ ] Diseñar método apply_anti_aliasing()

### [S] Carga de configuración
- [ ] Diseñar GraphicsSettingsLoader
- [ ] Diseñar método load_settings()
- [ ] Diseñar carga desde user://settings/graphics_settings.json
- [ ] Diseñar parseo de JSON
- [ ] Diseñar aplicación de configuración al inicio
- [ ] Diseñar fallback a preset medio si no existe configuración

### [S] Guardado de configuración
- [ ] Diseñar GraphicsSettingsSaver
- [ ] Diseñar método save_settings()
- [ ] Diseñar guardado en user://settings/graphics_settings.json
- [ ] Diseñar serialización de settings a JSON
- [ ] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [ ] Diseñar formato de graphics_settings.json
- [ ] Incluir todos los campos de GraphicsSettings
- [ ] Incluir resolución como objeto {x, y}
- [ ] Incluir preset como string

### [S] Diagrama de flujo
- [ ] Diseñar diagrama de flujo de configuración
- [ ] Diseñar flujo: Usuario abre settings → Menú de configuración gráfica → Usuario selecciona preset o ajusta opciones → GraphicsSettings se actualiza → GraphicsApplier aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [ ] Diseñar pruebas manuales (presets en diferentes hardware, ajustes individuales, aplicación en tiempo real, guardado y carga, detección automática)
- [ ] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, detección de hardware)
- [ ] Diseñar pruebas de legibilidad en 720p
- [ ] Diseñar pruebas de legibilidad en 1080p
- [ ] Diseñar pruebas de legibilidad en 4K
- [ ] Diseñar pruebas de soporte de tildes
- [ ] Diseñar pruebas de soporte de ñ
- [ ] Diseñar pruebas de soporte de símbolos
- [ ] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
- [ ] Diseñar pruebas de ajustes de accesibilidad
- [ ] Diseñar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de presets gráficos
- [ ] Diseñar tests de ajustes individuales
- [ ] Diseñar tests de aplicación en tiempo real
- [ ] Diseñar tests de guardado y carga de configuración
- [ ] Diseñar tests de detección automática de hardware

## Totales

**Total de ítems:** 248
**Ítems resueltos por documentación:** 248
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
