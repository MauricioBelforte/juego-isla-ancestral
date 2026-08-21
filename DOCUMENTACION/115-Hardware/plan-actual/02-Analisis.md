# Módulo 115: Hardware — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:27:00

## 1. Análisis del Dominio

### Categorías de Hardware para Juegos

| Categoría | Ejemplo | Capacidad |
|-----------|---------|-----------|
| **Low-end** | Laptops integradas, PCs antiguas | Mínimo, jugable |
| **Mid-range** | PCs de gama media, consolas last-gen | Cómodo, buena calidad |
| **High-end** | PCs gamer, consolas actuales | Máximo, 60+ FPS |
| **Mobile** | Smartphones, tablets | Touch, optimizado |

### Requisitos de Hardware Típicos (Juegos Cozy Voxel)

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **OS** | Windows 10 64-bit | Windows 11 |
| **CPU** | Intel i3-4130 / AMD FX-6300 | Intel i5-8400 / AMD Ryzen 5 2600 |
| **RAM** | 4 GB | 8 GB |
| **GPU** | GTX 750 Ti / RX 460 | GTX 1060 / RX 580 |
| **VRAM** | 2 GB | 4 GB |
| **Storage** | 2 GB | 4 GB |
| **DirectX** | 11 | 12 |

### Detección de Hardware en Godot

```
[OS] ──► OS.get_name(), OS.get_version()
[CPU] ──► OS.get_processor_count(), OS.get_processor_name()
[GPU] ──► RenderingServer.get_rendering_info()
[RAM] ──► OS.get_memory_info()
[VRAM] ──► RenderingServer.get_rendering_info()
```

## 2. Decisiones de Diseño

### Decisión 1: Estrategia de Detección

**Opción A:** Detección al inicio del juego
- Pro: Configuración óptima desde el principio
- Contra: Puede causar delay al abrir

**Opción B:** Detección en background + apply on next launch
- Pro: Sin delay, configuración persistente
- Contra: Primera vez puede ir mal

**Decisión:** Opción B (background detection + save) con override manual del jugador.

### Decisión 2: Categorías de Calidad

**Opción A:** 3 categorías (Low, Medium, High)
- Pro: Simple
- Contra: Poco granular

**Opción B:** 5 categorías (Very Low, Low, Medium, High, Ultra)
- Pro: Granular
- Contra: Más complejo

**Decisión:** Opción B (5 categorías) + Auto-detect que elige la mejor categoría estable.

### Decisión 3: Ajuste Automático

**Opción A:** Ajustar todo de golpe
- Pro: Simple
- Contra: Puede causar bottleneck inesperado

**Opción B:** Ajuste progresivo (empezar bajo, subir si hay headroom)
- Pro: Seguro
- Contra: Más complejo

**Decisión:** Opción B con target de 60 FPS. Si el juego corre a >60 FPS estable, sube calidad. Si baja de 45 FPS, baja calidad.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Detección falla en hardware exótico | Media | Medio | Fallback a preset conservador |
| Ajuste automático causa stuttering | Media | Alto | Apply on restart, no in-game |
| Gamepad no detectado | Media | Bajo | Soporte genérico + mapping manual |
| VRAM insuficiente para texturas | Media | Alto | LOD agresivo + streaming |
| Mobile no soportado | Alta | Medio | Documentar como "no soportado" |

## 4. Mapa de Compatibilidad

### Plataformas Soportadas

| Plataforma | Estado | Notas |
|------------|--------|-------|
| Windows 10/11 | ✅ Principal | Primary target |
| Linux | ✅ Soportado | Proton/SteamOS compatibility |
| macOS | ⚠️ Limitado | Metal support, sin optimización nativa |
| Steam Deck | ✅ Soportado | Optimización específica |
| PlayStation | ❌ No soportado | v2+ |
| Xbox | ❌ No soportado | v2+ |
| Nintendo Switch | ❌ No soportado | v2+ |
| Mobile | ❌ No soportado | v2+ |

### Dispositivos de Entrada

| Dispositivo | Soporte | Notas |
|-------------|---------|-------|
| Teclado + Mouse | ✅ Principal | Primary PC input |
| Xbox Controller | ✅ Soportado | XInput nativo |
| PlayStation Controller | ✅ Soportado | DualShock/DualSense |
| Switch Pro Controller | ✅ Soportado | DirectInput |
| Touch Screen | ❌ No soportado | v2+ |
| VR | ❌ No soportado | Nunca |
