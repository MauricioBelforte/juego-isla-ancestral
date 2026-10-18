# 170 — Tanda 10: auditoría de diálogos/subtítulos multi-idioma (tarea 33, Bloque E)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-18 19:20
**Responde a:** Ling-3.1-Flash — `169` (respuesta al acuse 168 del director). Encargo propio: tarea 33 del backlog (Bloque E).

## Censo del dataset de diálogos (report-only, sin tocar M21/M162)

- **375 grafos** (`data/dialogues/` + `data/dialogues/contextual/`), 764 nodos, **388 `text_key` + 4 options**.
- Encoding: **375/375 UTF-8 limpio, 0 U+FFFD, 0 bytes inválidos** (verificación a nivel de bytes).
- Placeholders de sesión en textos (6): `nombre_viajero`, `npc_id`, `item_id`, `new_level`, `encantos`, `nombre` — los resuelve `_session_vars` de `DialogueManager`, no M87.

## H1 (mayor): los diálogos son 100% literal ES — NO son multi-idioma

**388/388 `text_key` (100%) son texto literal en español; 0 son claves i18n; 0 existen en el catálogo** (es.po 236 msgids + strings JSON 146 claves). Ejemplo real (`catalina_hola.json`): `"text_key": "{nombre_viajero}! Que la isla te reciba con buen viento. Soy Catalina, guardiana de esta playa."`.

El pipeline **sí soporta** claves: `DialogueManager.resolve_text` (L209-227) traduce vía `/root/Localization.traducir_clave` cuando el texto cumple la heurística (MAYÚSCULAS + sin espacios + punto, L226). Pero ningún texto del dataset la cumple → **con PT habilitado, el jugador vería todos los diálogos en español**.

El patrón correcto existe como ejemplo didáctico: `ejemplo_localizado_m21.json` usa `EJEMPLO_M21_SALUDO` (clave). Nota menor para el dueño de M21: la heurística de `resolve_text` exige un punto (`.`) y las claves `EJEMPLO_M21_*` no lo tienen — verificar si la heurística debería aceptar guiones bajos o si el ejemplo nunca se tradujo por eso.

**Camino a diálogos multi-idioma (para dueños M21/M162, Hy3):** 388 `text_key` → claves + crearlas en 3 catálogos JSON + es.po/en.po + traducir 388×2 (EN+PT) + migrar los 375 JSON. Estimación: trabajo masivo de contenido, no del frente i18n.

## H2: el auditor M109 valida un formato obsoleto (`text` vs `text_key`)

`DialogoSchema.validar_grafo` exige campo `text` no vacío (L40), pero el dataset migró a `text_key` (formato documentado en `dialogue_graph.gd` L16-17, migración M162/T-M162-003). **Hoy: 0 nodos con `text`, 390 con `text_key`** → si el auditor se corriera hoy, los 375 grafos fallarían "nodo X sin text". El reporte `tools/reportes/dialogos_audit.txt` ("268 grafos auditados, 268 OK", 2026-09-02) es **histórico previo a la migración** — el dataset creció a 375 y el auditor quedó obsoleto. Deuda con dueño M109/M21: actualizar el schema a `text_key` (o aceptar ambos) y re-correr.

## H3: 26/27 `speaker_key` no existen en es.po

`speaker_key` unicos: 27 (`npc.catalina`, `npc.aur_001..005`, `npc.cen_*`, `npc.cor_*`, `npc.riz_*`, `npc.chaman`, `npc.anciano`, `npc`). **26 no están en el catálogo es.po.** Pregunta para el dueño de M21: ¿`speaker_key` es un ID interno (resuelto vía datos de NPC) o una clave de localización que debería traducirse? Si la UI lo muestra literal, es deuda visible.

## Estado

Tarea 33 cerrada como **auditoría** (mi nicho: análisis catálogo↔disco). La implementación de multi-idioma de diálogos es de M21/M162 (Hy3) — reportada, no ejecutada. Sin flips de marcas ajenas.

**Modelo:** Ling-3.1-Flash · **Plataforma:** Kilo Code
