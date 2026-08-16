**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 02: Documentación del Proyecto

## 1. Estado actual de los 25 puntos del plan maestro (sección 2)

| # | Documento/ítem | Estado | Dueño / Fuente |
|---|---|---|---|
| 1 | GDD principal | ✅ Existe | `00-PLAN-INICIAL/IDEA-BASE-DEL-JUEGO.md` (immutable) |
| 2 | Documento de narrativa | ✅ Existe | `00-PLAN-INICIAL/HISTORIA-DEL-JUEGO.md` (1281 líneas) |
| 3 | Documento de mundo | 🟡 Parcial | Datos en GDD§3 + biblia; consolidación → módulo Mundo Voxel/Terreno |
| 4 | Documento de personajes | 🟡 Parcial | Arquetipos en biblia; consolidación → módulo NPC y Vecinos |
| 5 | Documento de misiones | 🟡 Parcial | Viaje del jugador en GDD§4; detalle → módulo Misiones/Historia |
| 6 | Documento de sistemas | 🟡 Parcial | GDD§3 desglosa sistemas; diseño detallado → módulos dueños |
| 7 | Documento técnico | ⬜ Pendiente | Módulo Arquitectura General + Game Engine (decisiones técnicas) |
| 8 | Documento de arte | ⬜ Pendiente | Módulo Estilo de Arte Visual / Arte 3D |
| 9 | Documento de audio | ⬜ Pendiente | Módulo Música / Audio |
| 10 | Documento de UI/UX | ⬜ Pendiente | Módulo UI/UX |
| 11 | Documento de economía | 🟡 Parcial | GDD§3B (doble moneda); detalle → módulo Economía |
| 12 | Documento de progresión | 🟡 Parcial | Sellos y boletos en GDD; detalle → módulo Progresión |
| 13 | Documento de monetización | ⬜ Pendiente | Opciones en Plan-de-produccion §14; decisión diferida a publicidad |
| 14 | Documento legal | ⬜ Pendiente | Módulo Legal-PI (incluye verificación del nombre del juego) |
| 15 | Documento de QA | ⬜ Pendiente | Protocolo AGENTS§14 + módulo QA/Testing |
| 16 | Documento de publicación | ⬜ Pendiente | Módulo de Publicación |
| 17 | Convenciones de nombres | ✅ Definir-ahora | AGENTS.md + `03-Diseno.md §3` (este componente) |
| 18 | Estructura de carpetas | ✅ Existe | AGENTS.md §3 + `03-Diseno.md §4` |
| 19 | Estándar de documentación | ✅ Existe | AGENTS.md (5 archivos, firmas, logs) |
| 20 | Control de versiones de documentos | ✅ Existe | Git (este repo) + flujo `03-Diseno.md §6` |
| 21 | Sistema de tareas | ✅ Existe | CHECKLIST-GLOBAL + 05-Checklist por módulo |
| 22 | Prioridades | ✅ Existe | Columna Prioridad del CHECKLIST-GLOBAL (🔴/🟡/🟢) |
| 23 | Milestones | ⬜ A definir | `03-Diseno.md §8` (este componente) |
| 24 | Roadmap | 🟡 Parcial | Plan-de-produccion §1 (post-v1.0); formalizado en §8 |
| 25 | Backlog inicial | ✅ Existe | Plan-inicial-minimo.md = 152 módulos |

## 2. Análisis: ¿este módulo crea o cataloga?

- **Crear aquí (son infraestructura):** convenciones, estándar, versionado, sistema de tareas, prioridades, milestones, roadmap, backlog, y los 5 `*-ACTUAL.md` generales.
- **Solo catalogar aquí:** los documentos de contenido (GDD, narrativa, mundo…) — su creación/detalle pertenece al módulo dueño. Esto evita duplicación y respeta la modularidad del protocolo (AGENTS.md §15: no tocar lo que funciona).

## 3. Análisis de convenciones existentes (heredadas de AGENTS.md)

| Convención | Regla | Estado |
|---|---|---|
| Componentes | `DOCUMENTACION/{NN}-Nombre/` con `plan-inicial/` y `plan-actual/` | Vigente |
| Archivos | 01-Requerimientos · 02-Analisis · 03-Diseno · 04-Codigo · 05-Checklist (≥100 ítems); 06/07 opcionales | Vigente |
| Logs | `Logs/{NN}-descripcion_YYYY-MM-DD_HH-MM-SS.md` + `ULTIMO_NUMERO.txt` | Vigente |
| Firmas | `**Modelo:** X` / `**Plataforma:** Y` al inicio de cada doc | Vigente |
| Estados checklist | `[ ]` / `[x]` / `[?]` + esfuerzo `[S]/[M]/[C]` | Vigente |
| Global | CHECKLIST-GLOBAL.md, una fila por módulo | Vigente |
| Obsoletos | Backup `Obsoletos/AAAA-MM-DD_HH-MM-SS_nombre.ext` | Vigente |

**Conclusión:** no hace falta diseñar nada nuevo; el módulo **consolida** lo que AGENTS.md ya fija y lo vuelve verificable en checklist.

## 4. Análisis de milestones

Referencias disponibles: Plan-de-produccion (fases producción MVP §1, EA vs lanzamiento directo §14, presupuesto). El método ágil liviano (sin fechas rígidas) es el adecuado para equipo 1 persona. Propuesta en `03-Diseno.md §8`:
1. Prototipo jugable voxel (M04/M08) → validar 60 FPS y frame emisor→receptor.
2. Vertical Slice: 1 día completo en Aurora (bucle diario + 1 templo).
3. Alfa interna: Aurora completa + 1 isla + 2 sellos.
4. Beta cerrada: contenido v1.0 completo + QA/playtests.
5. v1.0 lanzamiento.
6. Roadmap post: Cenizas → Cielo → Elysia → 4 finales.

## 5. Decisiones de diseño documental

1. **Los 5 `*-ACTUAL.md` generales** se crean en este módulo como esqueletos con secciones y estado; el contenido se completa por los módulos dueños (especificaciones técnicas → Arquitectura/Engine; diseño → módulos de gameplay; tareas → cada módulo; ejecución → cada implementación; mejoras → directivas del usuario).
2. **Backlog inicial = los 152 módulos**: no se redefine; se formaliza.
3. **Roadmap post-lanzamiento** sigue la propia ficción (Gran Vapor): Cenizas, Cielo, Elysia, 4 finales (Plan-de-produccion §1).
4. **Versión de documentos:** git + convención de "plan-actual como espejo vigente"; sin ramas por documento (proyecto 1 persona).
5. **Verificación legal del nombre** ("Isla Ancestral") queda formalmente asignada al módulo Legal-PI (M78), no perdida en pendientes sueltos.