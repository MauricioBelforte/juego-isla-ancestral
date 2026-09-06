# Log 564: M162 Diálogos Contextuales — iter. contenido 2 (cobertura amistad completa)

**Fecha:** 2026-09-02
**Hora:** 23:59
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. contenido 2 de M162: cobertura de variantes de amistad **COMPLETA para los 23/23 NPCs** del registry (AUR 5 + CEN 5 + COR 5 + RIZ 8). 45 grafos nuevos; registry 278 → 323 entries, todas validadas.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/dialogues/contextual/{aur,cen,cor,riz}_00X_cap0_saludo_{amistad60,amistad90}.json` *(30 nuevos)* | SALUDO con `amistad_<slug> >= 60/90`, plantilla cozy con nombre del NPC |
| `data/dialogues/contextual/{aur,cen,cor,riz_006..008}_00X_cap0_historia_amistad60.json` *(15 nuevos)* | HISTORIA de confianza (prioridad 2) |
| `data/dialogues/contextual/registry.json` | +45 entries → 323 total |
| `scripts/gen_m162_amistad_all.py` *(nuevo)* | Generador idempotente reutilizable: cubre CUALQUIER NPC nuevo del registry con plantilla por nombre (solo los RIZ base llevan textos personalizados) |
| `scripts/dialogos/test_contextual_dialogue_m162.gd` | Check COR-001 actualizado: amistad alta → variante prio 2 (comportamiento nuevo esperado) |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` | Nota iter. 2 |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M162 cobertura completa registrada (78/120) |

## Tests (headless Godot 4.7.2)
- `test_contextual_dialogue_m162.gd`: **323/323 grafos OK, 0 fallos**
- Regresión: test_dialogos M21 **0 fallos**

## Archivos Modificados/Creados
- 60 grafos .json de variantes *(nuevos, total con Log 562)*
- `data/dialogues/contextual/registry.json` *(278 → 323)*
- `scripts/gen_m162_amistad_all.py` *(nuevo)*
- `scripts/dialogos/test_contextual_dialogue_m162.gd` *(modificado)*
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 564)*
- `Logs/reservas/561/564-...txt` *(creadas y borradas — 561 tomada por otro agente, v2 asignó 562; luego 564 reservada directa)*

## Pendientes con dueño
- Variantes de HORA para HISTORIA/MISION (solo SALUDO las tiene)
- Contenido de capítulos 1-7 con variantes
- i18n de text_key (M87)
- Textos personalizados por personalidad para AUR/CEN/COR (hoy plantilla genérica con nombre del NPC)
