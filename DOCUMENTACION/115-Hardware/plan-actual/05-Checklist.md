# Módulo 115: Hardware — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:27:00

## A. Requisitos de Hardware (10 ítems)

- [ ] Documentar requisitos mínimos de CPU (cores, frecuencia)
- [ ] Documentar requisitos mínimos de RAM
- [ ] Documentar requisitos mínimos de GPU (VRAM, modelo)
- [ ] Documentar requisitos recomendados de CPU
- [ ] Documentar requisitos recomendados de RAM
- [ ] Documentar requisitos recomendados de GPU
- [ ] Definir OS soportados (Windows 10/11, Linux, macOS)
- [ ] Definir DirectX/OpenGL requerido
- [ ] Documentar espacio en disco requerido
- [ ] Crear tabla comparativa de requisitos por plataforma

## B. Detección de Hardware (15 ítems)

- [ ] Crear Resource HardwareProfile con campos: cpu_cores, cpu_name, cpu_freq_ghz, gpu_name, gpu_vram_mb, ram_mb, os_name, os_version, quality_preset, detected_at
- [ ] Implementar HardwareDetector.detect() que retorna perfil completo
- [ ] Detectar CPU: cores, nombre, frecuencia estimada
- [ ] Detectar GPU: nombre, VRAM usando RenderingServer
- [ ] Detectar RAM total usando OS.get_memory_info()
- [ ] Detectar OS: nombre y versión
- [ ] Detectar dispositivos de entrada conectados
- [ ] Implementar get_input_devices() para listar gamepads
- [ ] Guardar perfil detectado en user://hardware_profile.tres
- [ ] Cargar perfil guardado al inicio
- [ ] Detectar si el hardware cambió entre sesiones
- [ ] Fallback a perfil conservador si detección falla
- [ ] Logging de hardware detectado
- [ ] Implementar _estimate_cpu_freq() basado en cores
- [ ] Soporte para múltiples GPUs (laptops hybrid)

## C. Selección de Preset (10 ítems)

- [ ] Definir enum QualityPreset: VERY_LOW, LOW, MEDIUM, HIGH, ULTRA
- [ ] Implementar QualityPresetSelector.select_preset()
- [ ] Sistema de scoring: VRAM (0-40), RAM (0-30), CPU (0-30)
- [ ] Very Low: VRAM <1GB o RAM <4GB
- [ ] Low: VRAM 1-2GB, RAM 4-6GB
- [ ] Medium: VRAM 2-4GB, RAM 6-8GB
- [ ] High: VRAM 4-6GB, RAM 8-16GB
- [ ] Ultra: VRAM >6GB, RAM >16GB
- [ ] Guardar preset seleccionado en user://quality_settings.tres
- [ ] Permitir override manual del jugador

## D. Aplicación de Calidad (15 ítems)

- [ ] Crear Resource QualitySettings con campos: preset, render_scale, shadow_quality, ssao, ssr, lod_bias, max_fps, vsync, texture_quality, antialiasing, volumetric_fog, grass_distance
- [ ] Implementar QualityApplier.apply_preset()
- [ ] Very Low: render_scale 0.5, shadows off, 30 FPS target
- [ ] Low: render_scale 0.7, shadows low, 30 FPS target
- [ ] Medium: render_scale 0.85, shadows medium, 60 FPS target
- [ ] High: render_scale 1.0, shadows high, 60 FPS target
- [ ] Ultra: render_scale 1.0, shadows ultra, 120 FPS target
- [ ] Aplicar render scale al viewport
- [ ] Aplicar configuración de sombras
- [ ] Aplicar SSAO on/off
- [ ] Aplicar SSR on/off
- [ ] Aplicar V-Sync
- [ ] Aplicar max FPS
- [ ] Aplicar texture quality
- [ ] Aplicar antialiasing (None/FXAA/MSAA2/MSAA4)

## E. Gestión Principal (10 ítems)

- [ ] Crear HardwareManager como autoload principal
- [ ] Inicializar detección en _ready()
- [ ] Cargar perfil guardado si existe
- [ ] Seleccionar preset automáticamente
- [ ] Aplicar preset al motor
- [ ] Guardar perfil después de cambio
- [ ] Implementar set_preset() para cambio manual
- [ ] Implementar get_current_preset()
- [ ] Emitir señal cuando el preset cambia
- [ ] Soporte para cambio de preset en runtime (con reinicio)

## F. Dispositivos de Entrada (10 ítems)

- [ ] Detectar teclado y mouse (siempre disponibles)
- [ ] Detectar Xbox Controller (XInput)
- [ ] Detectar PlayStation Controller (DualShock/DualSense)
- [ ] Detectar Switch Pro Controller
- [ ] Mapear botones genéricamente (A/B/X/Y)
- [ ] Mostrar prompts correctos por dispositivo detectado
- [ ] Guardar mapeo personalizado del jugador
- [ ] Soporte para remapeo de botones
- [ ] Detección de hot-plug (conectar/desconectar gamepad)
- [ ] Fallback a teclado si no hay gamepad

## G. Testing (10 ítems)

- [ ] Test de detección con perfil de hardware mock
- [ ] Test de selección de preset para cada categoría
- [ ] Test de aplicación de Very Low settings
- [ ] Test de aplicación de Ultra settings
- [ ] Test de guardado y carga de perfil
- [ ] Test de cambio de preset en runtime
- [ ] Test de detección de gamepad
- [ ] Test de mapeo de botones
- [ ] Test de hot-plug de gamepad
- [ ] Test de fallback cuando detección falla

## H. Integración con Build Pipeline (10 ítems)

- [ ] HardwareManager como autoload en project.godot
- [ ] Perfiles de calidad incluidos en build
- [ ] Detección funciona en todos los OS soportados
- [ ] Logging de hardware en build log
- [ ] Integración con M90 (Configuración Gráfica)
- [ ] Integración con M61 (Rendimiento)
- [ ] Integración con M57 (Interfaz de Control)
- [ ] Integración con M72 (Validación de Builds)
- [ ] Soporte para Steam Deck (optimización específica)
- [ ] Documentar hardware no soportado

## I. Documentación (10 ítems)

- [ ] Documentar cada función pública con XML docs
- [ ] Crear guía de uso para el jugador
- [ ] Documentar cómo funciona la detección automática
- [ ] Documentar cómo cambiar calidad manualmente
- [ ] Tabla de requisitos de hardware para la página de Steam
- [ ] FAQ de problemas de hardware comunes
- [ ] Documentar soporte de gamepads
- [ ] Registro de cambios del módulo
- [ ] Proceso de testing en hardware diverso
- [ ] Contacto de soporte técnico para issues de hardware
