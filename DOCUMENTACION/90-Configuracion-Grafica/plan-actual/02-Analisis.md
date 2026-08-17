**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 90: Configuración Gráfica

## 1. Análisis de los puntos del plan maestro (sección 89)

| # | Punto | Resolución |
|---|---|---|
| 1 | Resolución | ✅ Resoluciones: 720p (1280x720), 1080p (1920x1080), 1440p (2560x1440), 4K (3840x2160), nativa (resolución del monitor) |
| 2 | Pantalla completa | ✅ Toggle de pantalla completa (F11 o botón en settings) |
| 3 | Ventana | ✅ Modo ventana (ventana con bordes del sistema) |
| 4 | Borderless | ✅ Toggle de borderless (ventana sin bordes, pantalla completa pero sin bloquear otros monitores) |
| 5 | VSync | ✅ VSync options: 0 (off), 1 (on), 2 (adaptive) |
| 6 | FPS | ✅ Cap de FPS: 30, 60, 120, ilimitado (0) |
| 7 | Calidad de sombras | ✅ Calidad de sombras: baja (cascada simple), media (cascada suave), alta (PCSS), ultra (cascada con soft shadows) |
| 8 | Calidad de texturas | ✅ Calidad de texturas: baja (0.5x), media (1x), alta (2x), ultra (4x) |
| 9 | Distancia de dibujado | ✅ Distancia de dibujado: cercana (50), media (100), lejana (200) |
| 10 | Calidad de efectos | ✅ Calidad de efectos: baja (simple), media (normal), alta (avanzado), ultra (cinematográfico) |
| 11 | Calidad de vegetación | ✅ Calidad de vegetación: baja (sin animación), media (animación básica), alta (animación completa), ultra (animación + wind) |
| 12 | Calidad de agua | ✅ Calidad de agua: baja (sin reflexiones), media (reflexiones básicas), alta (reflexiones completas), ultra (reflexiones + caustics) |
| 13 | Calidad de partículas | ✅ Calidad de partículas: baja (reducido), media (normal), alta (aumentado), ultra (máximo) |
| 14 | Anti-aliasing | ✅ Anti-aliasing: off, FXAA (rápido), MSAA 2x (calidad), MSAA 4x (alta calidad), TAA (temporal) |
| 15 | Anisotropic filtering | ✅ Anisotropic filtering: off, 2x, 4x, 8x, 16x |
| 16 | Post-processing | ✅ Toggle de post-processing (bloom, motion blur, depth of field, color grading) |
| 17 | Bloom | ✅ Toggle de bloom e intensidad (slider 0-1) |
| 18 | Motion blur | ✅ Toggle de motion blur e intensidad (slider 0-1) |
| 19 | Depth of field | ✅ Toggle de depth of field e intensidad (slider 0-1) |
| 20 | FSR/DLSS/XeSS | ✅ Upscaling: FSR 1.0 (AMD), FSR 2.0 (AMD), DLSS (NVIDIA), XeSS (Intel) si GPU soporta |
| 21 | Escala de resolución | ✅ Escala de resolución: 50%, 75%, 100%, 125%, 150% |
| 22 | Presets gráficos | ✅ Presets: bajo (720p, calidad baja), medio (1080p, calidad media), alto (1440p, calidad alta), ultra (4K, calidad ultra), personalizado |
| 23 | Detección automática | ✅ Detección automática de hardware (GPU, RAM, CPU) y recomendación de preset |

## 2. Resoluciones

**Resoluciones soportadas:**
- 720p (1280x720) - hardware bajo
- 1080p (1920x1080) - hardware medio (recomendado)
- 1440p (2560x1440) - hardware alto
- 4K (3840x2160) - hardware ultra
- Nativa - resolución del monitor

**Aspect ratio:**
- 16:9 (predeterminado)
- 16:10 (soportado si monitor soporta)
- 21:9 (soportado si monitor soporta)

## 3. Modos de pantalla

**Modos:**
- Pantalla completa (fullscreen)
- Ventana (windowed)
- Borderless (borderless windowed)

**Implementación:**
- Toggle de pantalla completa (F11 o botón en settings)
- Modo ventana para multitasking
- Borderless para pantalla completa sin bloquear otros monitores

## 4. VSync

**VSync options:**
- 0 (off): sin sincronización vertical, máximo FPS pero posible tearing
- 1 (on): sincronización vertical, 60 FPS máximo, sin tearing
- 2 (adaptive): sincronización adaptativa, máximo FPS sin tearing cuando sea posible

**Recomendación:**
- Bajo preset: VSync 0 (off) para máximo FPS
- Medio preset: VSync 1 (on) para estabilidad
- Alto preset: VSync 2 (adaptive) para balance
- Ultra preset: VSync 2 (adaptive) para calidad

## 5. Cap de FPS

**Cap de FPS:**
- 30 FPS - hardware muy bajo
- 60 FPS - hardware medio (recomendado)
- 120 FPS - hardware alto
- Ilimitado (0) - hardware ultra

**Recomendación:**
- Bajo preset: 30 FPS
- Medio preset: 60 FPS
- Alto preset: 120 FPS
- Ultra preset: ilimitado

## 6. Calidad de sombras

**Calidad de sombras:**
- Baja: cascada simple, 1 shadow map, resolución 512x512
- Media: cascada suave, 2 shadow maps, resolución 1024x1024
- Alta: PCSS (Percentage-Closer Soft Shadows), 4 shadow maps, resolución 2048x2048
- Ultra: cascada con soft shadows, 4 shadow maps, resolución 4096x4096

**Implementación:**
- DirectionalLight shadows
- OmnidirectionalLight shadows (point lights)
- SpotLight shadows
- Soft shadows para calidad alta/ultra

## 7. Calidad de texturas

**Calidad de texturas:**
- Baja: texturas a 0.5x resolución (mipmap 0)
- Media: texturas a 1x resolución (mipmap 1)
- Alta: texturas a 2x resolución (mipmap 2)
- Ultra: texturas a 4x resolución (mipmap 3)

**Implementación:**
- Filtering: trilinear filtering
- Anisotropic filtering: 2x (baja), 4x (media), 8x (alta), 16x (ultra)
- Mipmaps: habilitados para evitar shimmering

## 8. Distancia de dibujado

**Distancia de dibujado (render distance):**
- Cercana: 50 unidades (100m)
- Media: 100 unidades (200m)
- Lejana: 200 unidades (400m)

**Implementación:**
- Culling de objetos fuera de distancia de dibujado
- LODs para objetos lejanos (M50)
- Fog para ocultar transición

## 9. Calidad de efectos

**Calidad de efectos:**
- Baja: efectos simples (partículas básicas, sin post-processing)
- Media: efectos normales (partículas estándar, post-processing básico)
- Alta: efectos avanzados (partículas avanzadas, post-processing completo)
- Ultra: efectos cinematográficos (partículas máximas, post-processing cinemático)

**Efectos:**
- Partículas (fuego, humo, agua, magia)
- Post-processing (bloom, motion blur, depth of field, color grading)
- Iluminación volumétrica (baja/ media: off, alta: on, ultra: alta calidad)

## 10. Calidad de vegetación

**Calidad de vegetación:**
- Baja: sin animación de vegetación, LOD 0 solo
- Media: animación básica (wind), LOD 0-1
- Alta: animación completa (wind + interacción), LOD 0-2
- Ultra: animación completa + wind procedural + interacción, LOD 0-3

**Implementación:**
- Vegetación procedural (árboles, arbustos, hierba)
- Animación por wind shader
- Interacción con jugador (cuando camina cerca)
- LODs para rendimiento

## 11. Calidad de agua

**Calidad de agua:**
- Baja: sin reflexiones, textura simple
- Media: reflexiones básicas (environment map), textura normal
- Alta: reflexiones completas (real-time reflections), textura normal + parallax
- Ultra: reflexiones completas + caustics (refracción de luz a través del agua), textura normal + parallax + caustics

**Implementación:**
- Shader de agua con reflexiones
- Normal map para olas
- Parallax para profundidad
- Caustics para ultra (luz refractada)

## 12. Calidad de partículas

**Calidad de partículas:**
- Baja: 100 partículas máximas por sistema
- Media: 500 partículas máximas por sistema
- Alta: 1000 partículas máximas por sistema
- Ultra: 2000 partículas máximas por sistema

**Implementación:**
- GPU particles para rendimiento
- Colisión de partículas con world
- Partículas para fuego, humo, agua, magia, polvo

## 13. Anti-aliasing

**Anti-aliasing:**
- Off: sin anti-aliasing (más rápido, más jagged edges)
- FXAA: Fast Approximate Anti-Aliasing (rápido, calidad baja)
- MSAA 2x: Multi-Sample Anti-Aliasing 2x (calidad media)
- MSAA 4x: Multi-Sample Anti-Aliasing 4x (calidad alta)
- TAA: Temporal Anti-Aliasing (calidad alta, más lento)

**Recomendación:**
- Bajo preset: off o FXAA
- Medio preset: FXAA
- Alto preset: MSAA 2x
- Ultra preset: TAA

## 14. Anisotropic filtering

**Anisotropic filtering:**
- Off: sin anisotropic filtering (texturas borrosas en ángulos oblicuos)
- 2x: calidad baja
- 4x: calidad media
- 8x: calidad alta
- 16x: calidad ultra

**Recomendación:**
- Bajo preset: off o 2x
- Medio preset: 4x
- Alto preset: 8x
- Ultra preset: 16x

## 15. Post-processing

**Post-processing:**
- Toggle de post-processing (activa/desactiva todos los efectos de post-processing)
- Efectos: bloom, motion blur, depth of field, color grading, tonemapping

**Implementación:**
- Bloom: glow para fuentes de luz brillantes
- Motion blur: blur cuando la cámara se mueve rápido
- Depth of field: blur para objetos fuera de foco
- Color grading: corrección de color para estilo visual
- Tonemapping: HDR to LDR tonemapping

## 16. Bloom

**Bloom:**
- Toggle de bloom
- Intensidad (slider 0-1)
- Threshold (slider 0-1)
- Radius (slider 0-1)

**Implementación:**
- Bloom shader para glow
- Threshold para que solo fuentes de luz brillantes tengan glow
- Radius para tamaño de glow

## 17. Motion blur

**Motion blur:**
- Toggle de motion blur
- Intensidad (slider 0-1)
- Sample count (slider 4-16)

**Implementación:**
- Motion blur basado en velocidad de cámara
- Más blur cuando la cámara se mueve más rápido
- Puede causar mareo, desactivar por defecto

## 18. Depth of field

**Depth of field:**
- Toggle de depth of field
- Intensidad (slider 0-1)
- Distance (slider 0-100)
- Aperture (slider 0-1)

**Implementación:**
- Depth of field basado en distancia de la cámara
- Blur para objetos fuera de foco
- Aperture controla cuánto blur

## 19. FSR/DLSS/XeSS

**Upscaling:**
- FSR 1.0 (AMD FidelityFX Super Resolution 1.0): upscaling AMD
- FSR 2.0 (AMD FidelityFX Super Resolution 2.0): upscaling AMD mejorado
- DLSS (NVIDIA Deep Learning Super Sampling): upscaling NVIDIA
- XeSS (Intel Xe Super Sampling): upscaling Intel

**Recomendación:**
- Detectar GPU y habilitar upscaling correspondiente
- Bajo preset: FSR 1.0 quality
- Medio preset: FSR 2.0 quality
- Alto preset: DLSS quality (si NVIDIA)
- Ultra preset: DLSS ultra quality (si NVIDIA)

## 20. Escala de resolución

**Escala de resolución:**
- 50%: render a resolución mitad, escalar a resolución completa (más rápido, menos calidad)
- 75%: render a resolución 3/4, escalar a resolución completa (balance)
- 100%: render a resolución completa (calidad máxima)
- 125%: render a resolución 1.25x, escalar a resolución completa (oversampling, más calidad pero más lento)
- 150%: render a resolución 1.5x, escalar a resolución completa (oversampling máximo, más calidad pero mucho más lento)

**Recomendación:**
- Bajo preset: 50%
- Medio preset: 75%
- Alto preset: 100%
- Ultra preset: 100% (o 125% si hardware lo permite)

## 21. Presets gráficos

**Presets:**
- Bajo: 720p, calidad baja, VSync 0, 30 FPS, escala 50%
- Medio: 1080p, calidad media, VSync 1, 60 FPS, escala 75%
- Alto: 1440p, calidad alta, VSync 2, 120 FPS, escala 100%
- Ultra: 4K, calidad ultra, VSync 2, ilimitado FPS, escala 100%
- Personalizado: configuración del usuario

**Implementación:**
- Botones de preset en settings
- Aplicar preset automáticamente al seleccionar
- Guardar preset personalizado en settings (M90)

## 22. Detección automática

**Detección de hardware:**
- GPU: detectar modelo y VRAM
- RAM: detectar memoria RAM
- CPU: detectar modelo y núcleos

**Recomendación de preset:**
- GPU baja + RAM baja + CPU baja → preset bajo
- GPU media + RAM media + CPU media → preset medio
- GPU alta + RAM alta + CPU alta → preset alto
- GPU ultra + RAM ultra + CPU ultra → preset ultra

**Implementación:**
- Usar RenderingServer.get_video_adapter_name() para GPU
- Usar OS.get_static_memory_usage() para RAM
- Usar OS.get_processor_name() para CPU
- Recomendar preset según hardware detectado

## 23. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaño de fuente (slider 0.5x a 2x) - integración con M88
- Alto contraste (toggle) - integración con M88
- Reducción de motion blur (opción para reducir mareo)
- Reducción de bloom (opción para reducir distracción visual)

**Implementación:**
- Ajustes de accesibilidad en menú de configuración gráfica
- Ajustes guardados en settings (M90)
- Ajustes aplicados en tiempo real

## 24. Integración con M61 (Rendimiento)

**Rendimiento:**
- FPS counter (opcional, en debug)
- Profiling de GPU (opcional, en debug)
- Monitoreo de uso de GPU y RAM (opcional, en debug)

**Implementación:**
- FPS counter visible en debug (M110)
- Profiling visible en debug (M110)
- Monitoreo de uso de GPU y RAM visible en debug (M110)

## 25. Integración con M88 (Fuentes Tipográficas)

**Fuentes:**
- Tamaño de fuente (slider 0.5x a 2x)
- Alto contraste (toggle)

**Implementación:**
- Ajustes de fuentes en menú de configuración gráfica
- Ajustes guardados en settings (M90)
- Ajustes aplicados en tiempo real
