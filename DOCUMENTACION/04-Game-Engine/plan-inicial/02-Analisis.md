**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 04: Game Engine

## 1. Decisión adoptada

> **Motor: Godot 4.x** — recomendación explícita del `Plan-de-produccion.md §2` (línea 111): *"Godot 4.x es la opción más defendible por defecto"* para este proyecto (voxel como pilar, equipo chico, sin presupuesto asegurado). Adoptada como decisión de documentación; el usuario puede revertirla antes del hito M1.

## 2. Análisis de los 30 puntos del plan maestro (§3)

| # | Punto | Resolución |
|---|---|---|
| 1 | Elegir Unity | ❌ Descartado por defecto: costo por asiento > USD 200k ingresos, ecosistema sí maduro pero voxel sin soporte nativo |
| 2 | Evaluar Godot | ✅ **Elegido**: gratis (MIT), sin regalías, native Linux/SteamOS |
| 3 | Evaluar Unreal | ❌ Descartado: overkill para cozy sim, voxel manual, tasa del 5% |
| 4 | Comparar costes | ✅ Plan-producción §2: Godot gratis siempre vs Unity hasta USD 200k/año |
| 5 | Soporte multiplataforma | ✅ Godot: export Windows/Linux/macOS + Deck nativo sin Proton |
| 6 | Soporte voxel | ✅ **Voxel Tools (godot_voxel, Zylann)**: C++/GDExtension, terreno editable, colisiones, streaming, LOD Transvoxel — caso de uso exacto del juego |
| 7 | Herramientas de terreno | ✅ Voxel Tools + editor propio de chunks |
| 8 | Iluminación | ⚠️ Godot 4: SDFGI/SSIL suficientes para estética pastel suave |
| 9 | Animación | ⚠️ Mejor en Unity (Mecanim) pero Godot 4 cubre rigging básico para cozy |
| 10 | Audio | ✅ AudioServer + bus system; suficiente |
| 11 | UI | ✅ UGUI de Godot (Control nodes) suficiente para HUD/inventario |
| 12 | Networking | ⚠️ No necesita en v1.0 (multijugador fuera de alcance) — Godot tiene high-level multiplayer |
| 13 | Comunidad | ✅ Activa y motivada; más chica que Unity |
| 14 | Documentación | ✅ Docs estables desde 4.x |
| 15 | Plugins | ⚠️ Menor mercado que Asset Store; Voxel Tools cubre el crítico |
| 16 | Elegir versión | ✅ Godot 4.x LTS estable (fijar exacta al crear proyecto) |
| 17 | Fijar versión | ✅ Congelada en `04-Codigo.md` |
| 18 | Evitar actualizar arbitrariamente | ✅ Regla de producción |
| 19 | Crear proyecto base | ⏳ Hito M1 (prototipo) |
| 20 | Render pipeline | ✅ Forward+ (Vulkan); Mobile para builds livianas |
| 21+ | Calidad/resolución/framerate | ✅ 60 FPS objetivo, resolución ajustable, VSync opcional |
| 24 | Input system | ✅ Input Map de Godot (teclado + mando) |
| 25 | Físicas | ✅ Godot Physics; colisiones voxel vía Voxel Tools |
| 26-27 | Capas/Tags | ✅ Layer system de Godot |
| 28 | Escenas iniciales | ⏳ Al crear proyecto base (M1) |
| 29 | Build profiles | ⏳ Export presets (Windows/Linux/Web) en M1 |

## 3. Comparativa resumida (fuente: Plan-de-produccion §2)

| Criterio | Unity | Godot 4.x |
|---|---|---|
| Costo | Gratis < USD 200k; Pro ~USD 2.300/año | **Gratis siempre** |
| Voxel nativo | No — terceros | **Voxel Tools (C++)** |
| IA/MCP | Oficial en beta + Unity MCP (12.7k★) | Comunitarios sólidos (GDAI MCP) |
| Voxel a gran escala | Depende del asset | **Diseñado para eso** |
| Deck | Vía Proton | **Nativo SteamOS** |

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Comunidad Godot más chica para arte/animation | Contratar solo lo puntual; tutorials oficiales |
| Voxel Tools = dependencia comunitaria | Versión fijada + código fuente disponible (MIT) |
| Reaprendizaje si el usuario viene de Unity | Costo aceptado; desventaja documentada |
| Rendimiento transvoxel en islas grandes | Hito M1 valida antes de avanzar |

## 5. Alternativas consideradas y descartadas

- **Unity + asset voxel de pago:** costo anual + dependencia comercial; solo si hubiera presupuesto de contratación.
- **Unreal + Custom Voxel:** demasiado motor para el género; curva y tasa eliminatorias.
- **Motor propio voxel**: descartado (reinventar el mundo; plan-producción no lo contempla).