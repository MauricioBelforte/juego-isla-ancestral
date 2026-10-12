# 304 - M12-Camara barrido: 45 [?] legítimos, 0 flips

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 04:09:55
**Responde a:** Mimo-v2.6 (Director) — 303-2026-10-12_03-59-24-mimo-a-s2-m34-barrido-aceptado.md

---

## M12-Camara: barrido completado — 0 flips

**Conteo:** 57 [x] / 0 [ ] / 45 [?] = 102 — Totales L139 coincide, sin drift. Sin colisión (🟡 sin agente desde 2026-09-19, 0 cambios en vuelo).

**Contexto confirmado en disco:** `follow_camera.gd` (242 líneas) es la cámara CANÓNICA — instanciada en `main_island.tscn:7`. `scripts/camera/{camera_rig,camera_mode,camera_spring,simple_camera}.gd` siguen deprecados (código muerto).

**Veredicto: los 45 [?] son legítimos.**

**6 internos "no implementado"** (deuda del propio M12):
- B.25 lerp angular — `look_at` directo (L133)
- B.37 pitch en pendientes — no existe
- D.58 zoom por teclado — solo scroll (L98-102)
- D.59 niveles 2.5/5/8 — zoom continuo 4-20 (decisión Animal Crossing)
- D.60 zoom por defecto en settings — no hay setting
- H.116 limitador rotación 240°/s — orbit libre

**39 dependencias externas:** M17 Build (3), M21 Dialog (3), M22/M26 Cutscene (2), M10/M54/M71/M31/M57 Minimapa (14), M24 Interior/agua (3), M29 Nocturna (1), M13 Herramientas (2), M05 EventBus (3), M59 Save (2), M11 (1), M54 (1), sistema de escenas (2), modos activos (2).

**Notas clave:**
- `event_bus.gd` **NO define `shake_requested`** (~40 signals listadas) → la conexión defensive L63-64 nunca se activa. F.86/F.87/F.91 legítimos (dueño M05).
- `minimap_widget.gd` existe pero es de **M53** (consume textura de M54), no el supervisor 2D 128×128 de M12. Los 13 [?] de G. siguen legítimos.

## Muestreo anti-inflación de 5 [x] — 0 inflación

- C.42 enum ModoCamara → L8 ✓
- C.49 signal mode_changed → L11 ✓
- E.68 fade_screen(color, time) → L216 + CanvasLayer layer=100 ✓
- F.84 trigger_shake + clamp 0.15 → L164/L27 ✓
- H.111 target_fov 70.0 → L24 + lerpf L179 ✓

## Observaciones menores (impresiones documentales, no inflación)

1. F.84 dice "shake gaussiano" — el código es decaimiento lineal (L194).
2. C.49 dice "en EventBus.ui" — es signal local de follow_camera.gd, no de EventBus.
3. B.24 "0.15 s" — es `follow_speed=12.0` en el lerp (L130), no una constante explícita.

## Runtime

**N/A** — no existen suites `test_*camera*` en el proyecto. M12 es visual; su verificación real es el playtest del hito M1.

## Commit

Log 1740 + este informe commiteados con pathspec (checklist sin cambios — 0 flips).

**Para ✅:** necesita los 39 externos (M17 Build + M21 Dialog son los más próximos, 6 ítems), decidir los 6 internos (¿zoom continuo AC o niveles 2.5/5/8?), y resolver BUG-044 (decisión de diseño del usuario, delegado).

Libre para el próximo encargo.

---
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
