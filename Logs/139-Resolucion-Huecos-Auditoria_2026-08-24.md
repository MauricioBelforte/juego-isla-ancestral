# Log 139: Resolución de Huecos de Auditoría — 11 de 12 completados

**Fecha:** 2026-08-24
**Hora:** 21:25
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Se resolvieron 11 de 12 huecos de auditoría identificados en `5-FUTURAS-MEJORAS.md`. Solo quedó pendiente la resolución de cantidad de NPCs (M19 vs M161/M162).

## Cambios Realizados

### 🔴 Alta (3 items completados)

1. **M15 — Catálogo de recursos:** Se agregaron 69 definiciones de recursos en `04-Codigo.md` (12 madera + 14 piedra/mineral + 10 fibra/planta + 12 comida + 8 especial + 8 pescados + 5 tesoros). Cada recurso tiene def_id, display_name, rareza, herramienta requerida, golpes, drops, valor de venta, temporada y región.

2. **M45 — Tabla de polígonos:** Se completaron las 14 categorías de assets 3D con techos de tris (LOD0/LOD1/LOD2), distancias de LOD y reglas generales. Archivo: `01-Requerimientos.md`.

3. **M13 — Tablas de durabilidad:** Se definieron tablas de durabilidad para las 9 herramientas × 4 tiers (150-700 golpes), velocities, áreas de extracción, costos de reparación y contrato `try_extract`/`try_place` con M08. Archivo: `01-Requerimientos.md`.

### 🟡 Media (6 items completados)

4. **M20 — Amistad:** Se unificaron niveles a 0-5 (antes 0-10), se eliminó decaimiento (cozy absoluto), se diseñó sistema de cartas completo (5 tipos, plantillas, respuestas por nivel, persistencia). Archivo: `01-Requerimientos.md`.

5. **M38 — Anti-inflación:** Se diseñaron 5 mecanismos: límite diario por ítem, amortiguación por volumen, separación de mercados por isla, bono por comercio inter-islas y reserva de mercado (anti-monopolio). Archivo: `01-Requerimientos.md`.

6. **M39 — Reputación de tienda:** Se diseñaron 6 niveles de reputación (0-5), NPCs especiales desbloqueados, objetos exclusivos y costos de mejora (200-5000 monedas + requisitos de amistad). Archivo: `01-Requerimientos.md`.

7. **M59/M60 — Formato de guardado:** Se definió esquema JSON completo con 12 bloques (world, player, inventory, buildings, npcs, friendship, economy, time, missions, collections, events, config), benchmarks (< 300ms guardado, < 1s carga) y 8 edge cases. Archivo: `01-Requerimientos.md`.

8. **M53 — UI/UX:** Se priorizaron 10 pantallas MVP + 15 post-MVP con dependencias, y se especificaron assets base (fuentes, paleta, espaciados, animaciones). Archivo: `01-Requerimientos.md`.

9. **M64 — IA de NPC:** Se crearon 4 archivos faltantes (02-Analisis, 03-Diseno, 04-Codigo, 05-Checklist con 100+ items). Incluye FSM jerárquica, rutinas, necesidades, navegación, social y reacciones ambientales.

### 🟢 Baja (2 items completados)

10. **M11 — Referencia Godot:** Corregido "New Input System de Godot" a "Input System de Godot" en `04-Codigo.md` y `05-Checklist.md`.

11. **M45 — ART_STYLE_3D.md:** Se creó la guía de estilo artístico 3D completa (estilo, paleta por bioma, métricas, topología, nombres, checklist de revisión).

## Pendiente

- **Resolver cantidad de NPCs:** M19 dice 8-12, M161/M162 documentan 23. Necesita decisión del usuario.

## Archivos Modificados/Creados

### Modificados
- `DOCUMENTACION/5-FUTURAS-MEJORAS.md` — 11 items marcados [x]
- `DOCUMENTACION/13-Herramientas/plan-actual/01-Requerimientos.md` — tablas de durabilidad + contrato M08
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` — catálogo de 69 recursos
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/01-Requerimientos.md` — niveles, decaimiento, cartas
- `DOCUMENTACION/38-Economia/plan-actual/01-Requerimientos.md` — anti-inflación
- `DOCUMENTACION/39-Tiendas/plan-actual/01-Requerimientos.md` — reputación de tienda
- `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md` — tabla de polígonos completa
- `DOCUMENTACION/53-UI-UX/plan-actual/01-Requerimientos.md` — MVP + assets
- `DOCUMENTACION/59-Guardado/plan-actual/01-Requerimientos.md` — esquema JSON + benchmarks
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/04-Codigo.md` — corrección Godot
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md` — corrección Godot

### Creados
- `DOCUMENTACION/45-Arte-3D/plan-actual/ART_STYLE_3D.md` — guía de estilo
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/02-Analisis.md` — análisis del dominio
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/03-Diseno.md` — diseño FSM + rutinas
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/04-Codigo.md` — scripts y firmas GDScript
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/05-Checklist.md` — 100+ items
