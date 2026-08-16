**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 04: Game Engine

## 1. Carácter del Componente

Módulo de **decisión técnica + configuración**. Hoy (fase documental) define el stack; el código del motor (escenas, scripts de bootstrap) se crea en el hito M1. Los archivos 06/07 (testing) se incorporarán cuando exista el proyecto base — por ahora no aplican y se omiten.

## 2. Arquitectura de referencia (Godot 4.x)

```
proyecto/                     ← raíz del juego (raíz de este repo, futura en Assets/)
├── project.godot             ← config del proyecto (renderer, input, layers)
├── scenes/                   ← Main.tscn, Player.tscn, CameraRig.tscn, UI.tscn
├── scripts/                  ← GDScript por sistema (nombres PascalCase)
├── resources/                ← datos (recipes, diálogos, herramientas) — análogo ScriptableObjects
├── data/                     ← generación procedural (seeds, biomas)
├── .godot/                   ← cache del editor (NO versionar)
└── export_presets.cfg        ← Windows/Linux/Web/SteamOS
```

## 3. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| Godot 4.x + GDScript | M05 (lenguaje), M07 (arquitectura) |
| Voxel Tools (Zylann) pinneado | M08 (mundo voxel), M61 (rendimiento) |
| Escenas separadas con carga diegética por isla | M28 (viajes), M63 (streaming) |
| 60 FPS + face culling obligatorio | M08, M61, M136 (optimización) |
| Input Map con remapeo | M57 (interfaz de control), M58 (accesibilidad) |

## 4. Versión fijada del motor (pendiente de resolución en M1)

| Campo | Valor |
|---|---|
| Motor | Godot 4.x (recomendado) |
| Versión exacta | ⏳ Fijar al crear el proyecto (usar última `4.x` estable y registrarla aquí) |
| Voxel Tools | ⏳ Fijar versión compatible con la versión de Godot |
| Renderer | Forward+ (Vulkan) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 01:10:00
**Estado:** Completado (decisión + diseño; instalación en M1)

### Lo que hice
- Adopté la recomendación del Plan-de-produccion §2: **Godot 4.x** (+ Voxel Tools), con análisis de los 30 puntos del plan maestro.
- Diseñé stack completo, configuración del proyecto base y criterio de validación del hito M1.
- Riesgos y mitigaciones documentados.

### Lo que NO pude hacer (honestidad obligatoria)
- Instalar Godot y crear el proyecto base → requiere ejecutar el motor (fuera del alcance documental; queda como pendiente `[ ]` del hito M1).
- Fijar la versión exacta de Godot y de Voxel Tools → depende de la instalación.
- Validar 60 FPS reales → depende del prototipo.

### Recomendaciones para el próximo agente
- M05/M07 deben diseñar contra Godot 4.x + GDScript, no contra Unity.
- M08 (Mundo Voxel): integrar Voxel Tools desde el inicio; no construir meshing propio salvo que se necesite control fino.
- El usuario debe **confirmar** Godot 4.x como decisión final (puede vetarla antes del M1).