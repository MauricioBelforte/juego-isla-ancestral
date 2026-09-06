# Log 640: M162 Diálogos — iter. contenido 4 (cobertura nocturna completa 23/23)

**Fecha:** 2026-09-04
**Hora:** 05:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. contenido 4 de M162: 18 HISTORIA nocturnas para AUR/CEN/COR/riz_006-008 — la cobertura nocturna alcanza **23/23 NPCs** (los riz_001-005 ya tenían del Log 639). Registry 328 → 346 entries, todas validadas.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/dialogues/contextual/{aur,cen,cor}_00X_cap0_historia_noche.json` *(15 nuevos)* | HISTORIA nocturnas (es_noche=true, prio 2) |
| `data/dialogues/contextual/{riz_006,007,008}_cap0_historia_noche.json` *(3 nuevos)* | Ídem para los RIZ restantes |
| `data/dialogues/contextual/registry.json` | +18 entries → 346 total |
| `scripts/gen_m162_noche_all.py` *(nuevo)* | Generador idempotente reutilizable (plantilla por isla+nombre) |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` | Nota iter. 4 (80/120) |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M162 cobertura nocturna completa (84/120) |

## Tests (headless Godot 4.7.2)
- `test_contextual_dialogue_m162.gd`: **346/346 grafos OK, 0 fallos**
- Regresión: test_dialogos M21 **0 fallos**

## Archivos Modificados/Creados
- 18 grafos *(nuevos)* + registry + `scripts/gen_m162_noche_all.py` *(nuevo)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 640)*
- `Logs/reservas/640-...txt` *(creada y borrada)*

## Cobertura de contenido M162 tras 4 iteraciones
- **Amistad: 23/23** (60 grafos, umbral 60/90)
- **Nocturnas: 23/23** (23 grafos, es_noche=true)
- Pendientes: estación en HISTORIA, caps 1-7 con variantes, i18n M87, textos por personalidad
