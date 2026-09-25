# Log 1116: Over-marks Familia A — 5 módulos revertidos ✅→🟡 (código no implementado)

**Fecha:** 2026-09-20
**Hora:** 01:13
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code (sesión 2)

## Resumen

Directriz del usuario (2026-09-20): *"mira si marcaron que hicieron la tarea pero el
código no está implementado, se descarta. Ahora si el plan fue malo y las checklist no
corresponden, bueno tenemos que re-evaluar el plan actual y la checklist"*.

Aplicada al hallazgo del escaneo anterior: **17 de los 33 ✅** tenían `[x]` sobre ítems
que dicen literalmente "NO implementado / KnownIssue no bloqueante" (145 ítems). Tras
verificar **evidencia de código real** (no el texto del ítem), se clasificaron en dos
familias y se actuó sobre la **Familia A**.

## Clasificación

| Familia | Criterio | Acción | # ítems |
|---------|----------|--------|---------|
| **A** | Marcaron `[x]` pero el código **no está implementado** | **Se descarta la marca** (`[x]`→`[ ]`) | 8 |
| **B** | El plan fue malo / la checklist no corresponde (item de diseño, doc o dependencia externa legítima) | **Re-evaluar plan-actual + checklist** (tarea pendiente, no de auditoría) | 120 |

La distinción se hizo verificando la existencia real del código citado en `game/`
(6008 archivos indexados), no confiando en el texto del ítem.

## Familia A — los 8 ítems revertidos

| Módulo | Ítem | Código ausente |
|--------|------|----------------|
| **M93 Balance** | Definir `simulate_economy.gd` con escenarios | `simulate_economy.gd` no existe |
| **M93 Balance** | Simulación de 60/180/365 días | ídem (depende de simulate_economy.gd) |
| **M93 Balance** | Simulación corra en CI (M118) | ídem (job deferred hasta que exista) |
| **M85 Modelos-3D-Legal** | Inventario de librerías de stock | no existe el inventario |
| **M36 Fauna** | Anti-stuck de manada/banco coordinado | `behavior.gd` no existe (renombre a `fauna_behavior.gd`, otra funcionalidad) |
| **M36 Fauna** | Crear `plan-inicial/` como reversa histórica | no existe |
| **M65 Animales-IA** | Movimiento real con NavigationServer3D evitando voxels | `animal_behavior.gd` no existe (solo movimiento 2D básico) |
| **M167 Isla-Raiz** | Ajuste olas en arena: shore-fade cubre demasiada arena | `water_config.tres` no existe |

## M93 — el caso más grave

M93 Balance figuraba ✅ con **134/134** y su propio `plan-actual/04-Codigo.md:256`
admite: *"**O.1-O.3 + X.5 (simulación económica): la brecha grande restante del módulo.
`simulate_economy.gd` NO existe (a pesar de figurar en §1 del 04-Codigo)**"*. Es el único
módulo donde el plan **documenta su propia brecha principal y aun así el ✅ estaba dado**.

## Cambios aplicados

Por cada uno de los 5 módulos (M93, M85, M36, M65, M167):

1. **`05-Checklist.md`**: los ítems Familia A pasaron de `[x]` → `[ ]`, **conservando
   intacta toda la nota KnownIssue original** (no se borró evidencia). Línea
   `**Totales:**` recalculada.
2. **`CHECKLIST-GLOBAL.md`**: celda `Estado` ✅ → **🟡 Con dudas (revertido)**;
   `Progreso` actualizado; nota de reversión firmada anteponiéndose al historial.

| Módulo | Antes | Después |
|--------|-------|---------|
| M93 Balance | ✅ 134/134 | 🟡 131/134 |
| M85 Modelos-3D-Legal | ✅ 100/100 | 🟡 99/100 |
| M36 Fauna | ✅ 228/228 | 🟡 226/228 |
| M65 Animales-IA | ✅ 89/89 | 🟡 88/89 |
| M167 Isla-Raiz | ✅ 114/114 | 🟡 113/114 |

**Total ✅ en el global: 33 → 28.**

## Familia B — pendiente (NO se tocó)

Los **120 ítems Familia B** no se modificaron. Son ítems de diseño/documentación/
dependencias externas legítimas cuyo problema es **de plan**, no de marca:

- El ítem pide "validación con jugadores reales" / "revisión legal" / "playtest" —
  tareas de proceso que requieren el juego andando o externos.
- El ítem cita un archivo que **sí existe** bajo otro nombre (renombre Unity→Godot:
  `behavior.gd`→`fauna_behavior.gd`, `balance.gd`→`balance_service.gd`,
  `isla_generador.gd`→`island_generator.gd`) — el `04-Codigo.md` quedó stale.
- El plan mezcla ítems de spec con ítems de implementación.

**Acción correcta (Familia B): re-evaluar el `plan-actual/` y la `05-Checklist.md` de
cada módulo** para que la checklist corresponda con el plan. Es trabajo de planificación
por módulo, no de auditoría — queda como tarea para los próximos agentes (ver "Próximos
pasos").

## Verificación

- Conteos reales vs línea Totales: **coinciden en los 5 módulos** (script directo).
- Encoding: **0 mojibake** en los 5 checklists editados. El global tiene 245 marcas
  pre-existentes (no introducidas por mí; la nota nueva está limpia).
- Los `[x]` Familia B **no se tocaron** — aplicarles el mismo tratamiento habría sido
  equivocar familia (la directriz los manda a re-evaluación de plan, no a descarte).

## Archivos Modificados/Creados

- `CHECKLIST-GLOBAL.md` (filas 36, 65, 85, 93, 167: Estado + Progreso + Notas)
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md` (3 marcas + Totales)
- `DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/05-Checklist.md` (1 marca + Totales)
- `DOCUMENTACION/36-Fauna/plan-actual/05-Checklist.md` (2 marcas + Totales)
- `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md` (1 marca + Totales)
- `DOCUMENTACION/167-Isla-Raiz/plan-actual/05-Checklist.md` (1 marca + Totales)
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/scripts-prueba/clasificar_overmarks.py`
- `.../scripts-prueba/clasificar_overmarks_familias.py`
- `.../scripts-prueba/revertir_familia_a.py`
- `.../overmarks_2026-09-20.txt`, `.../overmarks_clasificacion_2026-09-20.txt`
- `Logs/1116-overmarks-familia-a-reversion_2026-09-20_01-13-40.md`

## Próximos pasos

1. **Familia B (120 ítems en 16 módulos):** re-evaluar `plan-actual/04-Codigo.md` +
   `05-Checklist.md` por módulo. Los `04-Codigo.md` stale (paths Unity, renombres)
   deben actualizarse a los nombres reales en `game/`.
2. **Registrar el BUG-067** en `DOCUMENTACION/11-BUGS.md`: patrón sistémico de
   over-marks "KnownIssue no bloqueante" usado por 9 agentes como atajo para cerrar
   ítems no implementados. Convención legítima para deferrals, pero **no cuenta como
   completado para la DoD §21.6**.
3. **Re-auditar el global** tras los cambios: `python scripts/verificar_checklist.py`.
4. **QA cruzado §21.8** (PRIORIDAD 2 del backlog), ahora con 28 ✅ en lugar de 33.
