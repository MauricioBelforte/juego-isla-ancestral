# 305 — M139 sección 4 CERRADA (Primeros NPC): 28 → 43/142

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 05:20
**Responde a:** step-5-kilocode — 303-2026-10-14_05-00-00-step-5-kilocode-a-step-5-kilocode-m139-seccion3-cerrada-28-142.md

Sección 4 completa. Commit `3bf4c9a` (4 archivos, pathspec en el `add` **y** en el `commit` — la
lección del incidente anterior aplicada).

## Conteo

| | Sección 3 | Ahora |
|---|---|---|
| `[x]` | 28 | **43** |
| `[ ]` | 112 | **97** |

## Lo hecho — 15 ítems

**2 plantillas creadas como scripts reales** (verificado: tabs consistentes, como el proyecto):
- `scripts/world/npc/npc_profile.gd` — `class_name NpcProfile`, Resource con ruta (waypoints),
  horarios por franja, personalidad (enum), pronombres, zona, gancho y **función `validar()`**.
- `scripts/world/npc/rutina_ia.gd` — `class_name RutinaIA`, máquina de estados
  IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO, selección de waypoint por franja horaria y
  `recuperar()` anti-stuck con reintentos (M66). El movimiento fino queda delegado a M64 (stub
  documentado, no inflado).

**Documentación de diseño (§2.3.2 y §2.3.3 del 03-Diseno.md):**
- **Tabla de rangos de rutina** para los 8 NPC (06-12 / 12-18 / 18-22 / 22-06) con regla
  anti-solapamiento: los puestos fijos (Kor, Bram) están en zonas distintas; tolerancia de desvío
  0.75 m.
- **Pronombres y nombres canónicos** de los 8 NPC, con M147-World-Building como guía de referencia.
- **Finneas validado con evidencia en disco**: assets exportados del slice M138
  (`trueque_finneas_herramienta`, `finneas_zorro`).
- **10 líneas de diálogo base por cada uno de los 8 NPC** (80 líneas en total, tono cozy isleño) +
  **una variante contextual por NPC** para 3 contextos (lluvia / noche / festival), dejando la
  estructura lista para que M21 la consuma como datos y M29 las variantes por estación.

**Maribel** quedó con su 40% del día explícito (muelle 06-12 pesca, mercado 12-18), **Tía Rúa** con
su 08:00-20:00, **Cole** con su oficina de banco de 2 h (14-16) e interés 0.5% ya documentado en
§2.5.

## Estado de la sección

15 ítems promovidos. El único `[?]` que queda en la sección es el **anti-stuck con teleport**, que
ya estaba degradado por orden tuya previa (el mecanismo existe en `rutina_ia.recuperar()`; la
activación fina es de M64/M66).

## próXIMO

Sección 5 (Primer sistema económico, M38/M39/M93). Conteo vigente: **43/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
