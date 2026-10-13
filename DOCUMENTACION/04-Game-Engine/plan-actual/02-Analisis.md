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

## 6. Verificación de costos y licencias — sección B del checklist (2026-10-12, step 5 workbuddy)

Auditoría de los 10 ítems de la sección B (`05-Checklist.md`, líneas 35-44) contra evidencia
en disco. Cada flip del checklist cita esta sección.

| # | Ítem | Evidencia (archivo + línea) |
|---|---|---|
| B1 | Costo Godot: gratis siempre, MIT, sin regalías | Este archivo L15 ("gratis (MIT), sin regalías") y L45 ("Gratis siempre"). Fuente primaria: godotengine.org/license (MIT, "free to use... for any purpose", verificado 2026-10-12) |
| B2 | Costo Unity: gratis < USD 200k, Pro ~USD 2.300/asiento/año | Este archivo L45: "Gratis < USD 200k; Pro ~USD 2.300/año" (tabla comparativa §3) |
| B3 | Episodio Runtime Fee 2023 y su cancelación | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` L100: "El 'Runtime Fee' de 2023 generó una fuga masiva a Godot/Unreal; Unity lo canceló por completo en septiembre de 2024 y volvió al modelo por asiento" |
| B4 | Caso Unreal: 5% tras USD 1M de ingresos | Este archivo L16 ("tasa del 5%"). Umbral verificado 2026-10-12 en fuente oficial unrealengine.com/release: "5% royalty on worldwide gross revenue over the first $1 million USD" |
| B5 | Modelo autofinanciado compatible con Godot | `01-Requerimientos.md` L23 (RF5 "Costo cero o bajo — autofinanciado sin presupuesto asegurado") y L30 (RNF "Sin regalías ni fee por instalación que pongan en riesgo el modelo autofinanciado"), cruzado con este archivo L15 |
| B6 | Costos de assets/plugins a futuro (presupuesto separado) | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` §15 "Presupuesto y financiamiento" (L420) y L271 (middleware FMOD/Wwise: licencias gratuitas bajo umbrales, confirmar umbral vigente) |
| B7 | Voxel Tools es MIT y gratuito | `game/isla-ancestral/addons/zylann.voxel/LICENSE.md` L1-3 ("MIT License — Copyright (c) 2016-2024 Marc Gilleron"); refuerzo: este archivo L56 |
| B8 | Licencias de exportación sin fees (Vulkan/drivers) | Motor MIT (B1: godotengine.org/license) => exportar no arrastra fee. Drivers de video Vulkan/OpenGL: bibliotecas del sistema operativo, sin licencia con costo. Evidencia de exportación real en el repo: `build/` (`.pck` + `.wasm` distribuibles) |
| B9 | Costo cero como factor decisivo del análisis | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` L111: "el costo cero pase lo que pase con tus ingresos... son dos ventajas que pesan mucho para un equipo con recursos limitados" |
| B10 | Costo de herramientas de apoyo registrado en módulo de arte | `DOCUMENTACION/46-Arte-2D/plan-actual/02-Analisis.md` L43 ("Herramientas: Inkscape (gratuita), Krita (pintura), Blender solo como soporte 3D→2D") |

Nota de método: los ítems B4 y B8 combinan cita interna (este archivo / addon) con verificación
de fuente externa oficial fechada (2026-10-12). Sin fuente externa no se escribió el dato.