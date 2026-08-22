# Módulo 115: Hardware — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:27:00

## A. Requisitos de Hardware (10 ítems)

- [x] Documentar requisitos mínimos de CPU (cores, frecuencia)
- [x] Documentar requisitos mínimos de RAM
- [x] Documentar requisitos mínimos de GPU (VRAM, modelo)
- [x] Documentar requisitos recomendados de CPU
- [x] Documentar requisitos recomendados de RAM
- [x] Documentar requisitos recomendados de GPU
- [x] Definir OS soportados (Windows 10/11, Linux, macOS)
- [x] Definir DirectX/OpenGL requerido
- [x] Documentar espacio en disco requerido
- [x] Crear tabla comparativa de requisitos por plataforma

## B. Detección de Hardware (15 ítems)

- [x] Crear Resource HardwareProfile con campos: cpu_cores, cpu_name, cpu_freq_ghz, gpu_name, gpu_vram_mb, ram_mb, os_name, os_version, quality_preset, detected_at
- [x] Implementar HardwareDetector.detect() que retorna perfil completo
- [x] Detectar CPU: cores, nombre, frecuencia estimada
- [x] Detectar GPU: nombre, VRAM usando RenderingServer
- [x] Detectar RAM total usando OS.get_memory_info()
- [x] Detectar OS: nombre y versión
- [x] Detectar dispositivos de entrada conectados
- [x] Implementar get_input_devices() para listar gamepads
- [x] Guardar perfil detectado en user://hardware_profile.tres
- [x] Cargar perfil guardado al inicio
- [x] Detectar si el hardware cambió entre sesiones
- [x] Fallback a perfil conservador si detección falla
- [x] Logging de hardware detectado
- [x] Implementar _estimate_cpu_freq() basado en cores
- [x] Soporte para múltiples GPUs (laptops hybrid)

## C. Selección de Preset (10 ítems)

- [x] Definir enum QualityPreset: VERY_LOW, LOW, MEDIUM, HIGH, ULTRA
- [x] Implementar QualityPresetSelector.select_preset()
- [x] Sistema de scoring: VRAM (0-40), RAM (0-30), CPU (0-30)
- [x] Very Low: VRAM <1GB o RAM <4GB
- [x] Low: VRAM 1-2GB, RAM 4-6GB
- [x] Medium: VRAM 2-4GB, RAM 6-8GB
- [x] High: VRAM 4-6GB, RAM 8-16GB
- [x] Ultra: VRAM >6GB, RAM >16GB
- [x] Guardar preset seleccionado en user://quality_settings.tres
- [x] Permitir override manual del jugador

## D. Aplicación de Calidad (15 ítems)

- [x] Crear Resource QualitySettings con campos: preset, render_scale, shadow_quality, ssao, ssr, lod_bias, max_fps, vsync, texture_quality, antialiasing, volumetric_fog, grass_distance
- [x] Implementar QualityApplier.apply_preset()
- [x] Very Low: render_scale 0.5, shadows off, 30 FPS target
- [x] Low: render_scale 0.7, shadows low, 30 FPS target
- [x] Medium: render_scale 0.85, shadows medium, 60 FPS target
- [x] High: render_scale 1.0, shadows high, 60 FPS target
- [x] Ultra: render_scale 1.0, shadows ultra, 120 FPS target
- [x] Aplicar render scale al viewport
- [x] Aplicar configuración de sombras
- [x] Aplicar SSAO on/off
- [x] Aplicar SSR on/off
- [x] Aplicar V-Sync
- [x] Aplicar max FPS
- [x] Aplicar texture quality
- [x] Aplicar antialiasing (None/FXAA/MSAA2/MSAA4)

## E. Gestión Principal (10 ítems)

- [x] Crear HardwareManager como autoload principal
- [x] Inicializar detección en _ready()
- [x] Cargar perfil guardado si existe
- [x] Seleccionar preset automáticamente
- [x] Aplicar preset al motor
- [x] Guardar perfil después de cambio
- [x] Implementar set_preset() para cambio manual
- [x] Implementar get_current_preset()
- [x] Emitir señal cuando el preset cambia
- [x] Soporte para cambio de preset en runtime (con reinicio)

## F. Dispositivos de Entrada (10 ítems)

- [x] Detectar teclado y mouse (siempre disponibles)
- [x] Detectar Xbox Controller (XInput)
- [x] Detectar PlayStation Controller (DualShock/DualSense)
- [x] Detectar Switch Pro Controller
- [x] Mapear botones genéricamente (A/B/X/Y)
- [x] Mostrar prompts correctos por dispositivo detectado
- [x] Guardar mapeo personalizado del jugador
- [x] Soporte para remapeo de botones
- [x] Detección de hot-plug (conectar/desconectar gamepad)
- [x] Fallback a teclado si no hay gamepad

## G. Testing (10 ítems)

- [x] Test de detección con perfil de hardware mock
- [x] Test de selección de preset para cada categoría
- [x] Test de aplicación de Very Low settings
- [x] Test de aplicación de Ultra settings
- [x] Test de guardado y carga de perfil
- [x] Test de cambio de preset en runtime
- [x] Test de detección de gamepad
- [x] Test de mapeo de botones
- [x] Test de hot-plug de gamepad
- [x] Test de fallback cuando detección falla

## H. Integración con Build Pipeline (10 ítems)

- [x] HardwareManager como autoload en project.godot
- [x] Perfiles de calidad incluidos en build
- [x] Detección funciona en todos los OS soportados
- [x] Logging de hardware en build log
- [x] Integración con M90 (Configuración Gráfica)
- [x] Integración con M61 (Rendimiento)
- [x] Integración con M57 (Interfaz de Control)
- [x] Integración con M72 (Validación de Builds)
- [x] Soporte para Steam Deck (optimización específica)
- [x] Documentar hardware no soportado

## I. Documentación (10 ítems)

- [x] Documentar cada función pública con XML docs
- [x] Crear guía de uso para el jugador
- [x] Documentar cómo funciona la detección automática
- [x] Documentar cómo cambiar calidad manualmente
- [x] Tabla de requisitos de hardware para la página de Steam
- [x] FAQ de problemas de hardware comunes
- [x] Documentar soporte de gamepads
- [x] Registro de cambios del módulo
- [x] Proceso de testing en hardware diverso
- [x] Contacto de soporte técnico para issues de hardware
