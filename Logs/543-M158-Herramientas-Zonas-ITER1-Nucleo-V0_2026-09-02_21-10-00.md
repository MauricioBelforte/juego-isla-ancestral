# Log 543: M158 Herramientas-Zonas — iter. 1 núcleo V0 (tiers, gates, forjas, cursos)

**Fecha:** 2026-09-02
**Hora:** 21:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 1 de M158 Herramientas y Desbloqueo de Zonas: núcleo V0 — ToolTierSystem autoload con 4 tiers data-driven (propiedades exactas del §B), 6 gates por zona con desbloqueo permanente, 4 forjas por isla con consumo atómico de materiales (M14) y monedas (M38), 4 cursos de oficio únicos, integración de bloqueo de historia para M22 y persistencia M59. 42 ítems de checklist marcados [x] con evidencia.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/herramientas158/tool_tier_system.gd` *(nuevo)* | Autoload "Tiers": tiers (get_tier/get_tier_nivel/tiene_tier), gates (can_access_zone/info_gate/desbloquear_gate/zona_bloquea_historia), forjas (forjar con validación atómica + anti-doble-forja), cursos (tomar_curso único + puede_vender_tier), ISaveProvider "tool_tiers" con purga de catálogo viejo y sin re-emisión |
| `data/herramientas/tiers_config.json` *(nuevo)* | 4 tiers (T1 1.0 → T4 5.0), 6 gates (3 blocks_story), 4 forjas (T1 gratis anti-softlock), 4 cursos (300-10000 AO) |
| `scripts/herramientas158/test_tiers.gd` *(nuevo)* | 9 secciones ~45 checks headless |
| `project.godot` *(modificado)* | Autoload Tiers registrado |
| `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/plan-actual/05-Checklist.md` | 42 ítems [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` / `08-GUIA` / `ESTADO-PARALELO` | M158 reservado → liberado (42/140) |

## Tests (headless Godot 4.7.2)
- `test_tiers.gd` (M158): **0 fallos** (carga 4/6/4/4, propiedades exactas §B, gates cerrados/abiertos, desbloqueo idempotente + señal, forjas T1 gratis/T2/T3/T4 end-to-end con consumo real de M14+M38, rechazo por materiales sin tocar saldo, anti-doble-forja, cursos únicos + puede_vender_tier, historia blocks, persistencia round-trip con purga y sin re-emisión)
- Regresiones: M37 0, M75 0, M67 0, M72 0 fallos
- Boot: `[M158] ToolTierSystem listo: 4 tiers, 6 gates, 4 forjas, 4 cursos`

## Lecciones del test
- Fondos acumulados: la forja T2 cobra 500 AO antes que T3 — el test debe depositar lo suficiente ANTES de cada forja (el rechazo por saldo insuficiente era correcto del sistema).
- Verificación de bloqueo de historia: usar una herramienta con tier INFERIOR al requerido (el pico ya era T4 cuando el test esperaba que bloqueara) — o mejor, correr el check antes de forjar.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/herramientas158/tool_tier_system.gd` *(nuevo)*
- `game/isla-ancestral/scripts/herramientas158/test_tiers.gd` *(nuevo)*
- `game/isla-ancestral/data/herramientas/tiers_config.json` *(nuevo)*
- `game/isla-ancestral/project.godot` *(modificado)*
- `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(modificado)*
- `Logs/reservas/543-glm-5.3-flash-M158-Herramientas-Zonas.txt` *(creado y borrado)*

## Notas técnicas
- JSON unificado (tiers+gates+forjas+cursos en un archivo): un punto de curaduría; las APIs aíslan el formato — los Resource .tres del diseño llegan si el volumen lo pide.
- Consumo atómico estilo M37 §4.3.3: rechazo de forja = saldo e inventario intactos.
- Gates habilitan (can_access_zone) pero abren por interacción del jugador (M70 iter. 2) — desbloquear_gate() es explícito e idempotente.
- Anti-softlock: T1 gratis sin materiales en isla_raiz + anti-doble-forja.
- Cable directo con M22 (capítulos piden tiers): API lista, cable con dueño de M22.
