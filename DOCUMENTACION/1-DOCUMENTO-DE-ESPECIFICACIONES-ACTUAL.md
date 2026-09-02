# 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md

**Modelo:** glm-5.3-flash (último modificador; esqueleto por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Vigente — el detalle técnico por módulo vive en su plan-actual; acá el índice de especificaciones aplicadas.

## Propósito

Especificaciones técnicas vigentes del sistema: motor, arquitectura, rendimiento, entrada/salida, datos.

## Secciones

| Sección | Estado | Módulo dueño |
|---|---|---|
| Motor y pipeline (Unity vs Godot) | ✅ **Godot 4.x + Voxel Tools (GDExtension) + GDScript — CONFIRMADO 2026-08-16** (investigación y decisión final en `04-Game-Engine/plan-actual/`, Log 17) | 04 Game Engine |
| Arquitectura de software | ✅ Service Locator + capas unidireccionales + EventBus tipado — ver `07-Arquitectura-General/` | 07 Arquitectura |
| Mundo voxel (chunks, culling, LOD) | ✅ Implementado (M08/M09 — semilla 42, biomas, VoxelViewer sigue al jugador) | 08 Mundo Voxel |
| Rendimiento y frame budget | 🟡 Presupuestos definidos (M61 núcleo; límites por chunk en balance meta.json); medición real V2 | 61 Rendimiento |
| Guardado y serialización | ✅ Implementado (M59: cola atómica + backup rotativo + dirty tracking + auto-save + providers por duck-typing — Log 307) | 59 Guardado |
| Input (teclado/mando) | 🟡 Teclado/mouse aplicado (M11/M13); mando pendiente | 57 Interfaz de Control |
| Cargas y streaming | 🟡 Bootstrap + GameFlowManager aplicados (M40); streaming de islas M63 pendiente | 63 Cargas y Streaming |
| Clima y tiempo | ✅ Implementado (M29 calendario Aurora 336 días, M30 reloj HUD, M31 día/noche 5 franjas, M32 clima determinista con señales) | 29/30/31/32 |
| Viajes y mundo abierto | 🟡 TravelService núcleo (rutas JSON, clima retraso-sin-bloqueo, persistencia mitad de ruta — Log 319); escénico V2 | 28 Viajes |
| Colecciones y museo | 🟡 CollectionRegistry + DonationService núcleo (donaciones validadas, recompensas únicas — Log 321); escénico V2 | 37 Museos |
| Onboarding | 🟡 TutorialManager con triggers de acción/mundo/watchdog (Log 320); presentación V2 | 92 Tutorial |
| Localización | 🟡 es/en vía .po + tr_key/tr_ctx + persistencia de locale (sección "general" M60 — Log 322) | 87 Localización |

## Reglas de actualización

- Actualizar aquí ante cambios significativos (AGENTS §3, sección 3).
- Firmar con modelo/plataforma cada modificación.
