# Log 562: M162 Diálogos Contextuales — iter. contenido (variantes de amistad)

**Fecha:** 2026-09-02
**Hora:** 23:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Primera iteración de contenido de M162 tras el desbloqueo del BUG-012 (Log 560): 15 grafos de variantes de amistad para los 5 NPCs de Isla Raíz. Registry 263 → 278 entries, todas validadas. Test ampliado con 5 checks de selección de amistad — 0 fallos.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/dialogues/contextual/{riz_00X}_cap0_saludo_{amistad60,amistad90}.json` *(10 nuevos)* | SALUDO con condición `amistad_riz_00X >= 60/90`, textos cozy con voz por personalidad |
| `data/dialogues/contextual/{riz_00X}_cap0_historia_amistad60.json` *(5 nuevos)* | HISTORIA de confianza con `amistad_riz_00X >= 60` (prioridad 2) |
| `data/dialogues/contextual/registry.json` | +15 entries (SALUDO prio 4/5 sobre estacionales; HISTORIA prio 2) → 278 total |
| `scripts/dialogos/test_contextual_dialogue_m162.gd` | +_test_seleccion_amistad_iter3 (5 checks: amistad 60→prio 4, 90→prio 5, HISTORIA→prio 2, baja→base prio 1) |
| `scripts/gen_m162_amistad.py` *(nuevo, scripts de generación)* | Generador idempotente de variantes de amistad (patrón del gen original) |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` | Notas del Agente iter. contenido |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M162 iter. contenido registrado |

## Tests (headless Godot 4.7.2)
- `test_contextual_dialogue_m162.gd`: **278/278 grafos OK, 0 fallos** (incluye amistad 60→prio 4, 90→prio 5, HISTORIA→prio 2, amistad baja→base prio 1)
- Regresión: test_dialogos M21 **0 fallos**

## Decisiones de contenido
1. **Amistad manda sobre estación** (prio 4 > 3): la relación del vecino define el saludo, no el clima.
2. **Umbrales 60/90** alineados con la escala M20 (0-100): 60 = amigo, 90 = cómplice.
3. **Textos con voz por personalidad** (cocinera/pescador/bosque/huerto/taller) — canónicos en el registry, sin hardcode.
4. Generador **idempotente** (omite grafos existentes) — re-ejecutable al agregar NPCs.

## Archivos Modificados/Creados
- 15 grafos .json *(nuevos)* + registry.json *(modificado)*
- `scripts/dialogos/test_contextual_dialogue_m162.gd` *(modificado)*
- `scripts/gen_m162_amistad.py` *(nuevo)*
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 562)*
- `Logs/reservas/561/562-...txt` *(creadas y borradas — 561 tomada por otro agente, v2 asignó 562)*

## Pendientes con dueño (próximas iteraciones)
- Variantes de amistad para NPCs de AUR/COR/CEN/MAR (los 5 RIZ cubiertos)
- Variantes de HORA para HISTORIA/MISION (14 existen solo en SALUDO)
- Contenido de capítulos 1-7 con variantes (hoy solo SALUDO base)
- i18n de text_key (M87) — hoy español base
