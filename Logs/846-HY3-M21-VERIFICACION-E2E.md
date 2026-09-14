# Log 846 — HY3 — M21 — Verificación Técnica E2E (QA cruzado §21.8)

**Modelo:** Hy3 (Tencent Hunyuan / WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12
**Módulo:** 21 — Diálogos (núcleo implementado por Hy3; release 🟡 Con dudas por 7 [?] de dueño ajeno)
**Rol:** QA cruzado / verificación técnica (§21.8) + corrección de regresión
**Referencia:** CHECKLIST-GLOBAL.md (fila M21) · DOCUMENTACION/21-Dialogos/plan-actual/ · DOCUMENTACION/TAREAS-POR-MODELO/Hy3/21-Dialogos/checklist.md

## 1. Alcance

Verificación cruzada (verificador ≠ autor único) del **núcleo técnico** del motor de diálogos M21:
`DialogueManager` (capa sin UI), `DialogGraphValidator`, `WorldStateService` (condiciones de mundo),
y los diálogos de reacción de regalo/nivel (iters 4-5, M20→M21). NO se tocan los 7 `[?]` de dueño
ajeno (M22/M23/M53/M87/M29/M31) — ver §5. El contenido narrativo creativo se delega (§11.3) — ver §4.

## 2. Verificación (runtime headless, Godot 4.7.2 console)

Se ejecutaron los 13 tests canónicos de `game/isla-ancestral/scripts/dialogos/` + el gate CI:

| Test | Resultado |
|------|-----------|
| test_dialogos.gd (carga/flujo/opciones/eventos/reinicio/validador) | **0 fallos** |
| validate_all_dialogues.gd (CI: 3 JSON de `data/dialogues/`) | **0 problemas** (EXIT 0 → CI verde) |
| test_condiciones_mundo.gd (RF5 mundo + sesión) | **0 fallos** |
| test_eventos_dialogo_m21.gd (L82 + M53 consume) | **0 fallos** |
| test_reaccion_m21_dialogo.gd (consumo gift_given M20) | **0 fallos** |
| test_validacion_grafo_m21.gd (DialogGraphValidator) | **0 fallos** (era 3 en HEAD) |
| test_validacion_ci_m21.gd (gate carpeta) | **0 fallos** |
| test_skip_m21.gd (skip_all) | **0 fallos** |
| test_clima_dialogo_m21.gd (RF7 clima) | **0 fallos** |
| test_localizacion_dialogos.gd (M87→M21) | **0 fallos** |
| test_iter10_m21.gd | **0 fallos** |
| test_validacion_5_invalidos_m21.gd (5 defectos) | **0 fallos** (era 2 en HEAD) |
| test_aur005_fix_log608.gd | **EXIT 0** |

**Total: 13/13 tests 0 fallos + CI gate 0 problemas.**

## 3. Hallazgos y bugs corregidos

### BUG-026 — 🔴 Regresión crítica: el gate `[VAL-DGV]` mataba los diálogos de reacción (RESUELTO)
- **Causa:** iter 7/8 añadió en `dialogue_manager.gd::start_dialogue` (L106-110) un rechazo del grafo si
  `DialogGraphValidator.validar()` reportaba CUALQUIER problema. Las claves que M21 inyecta en runtime
  como contexto de condición NO estaban en `CLAVES_MUNDO_BASE`:
  - payload de evento M20→M21: `new_level`, `reaccion_id`, `npc_id`, `item_id` (en `start_dialogue(REACCION_*, {...})`);
  - session-var de amistad del llamador: `<npc_id>_amistad` (p. ej. `catalina_amistad`).
  → el validador las marcaba "desconocidas" → `start_dialogue` devolvía `false` →
  **`reaccion_regalo.json` / `reaccion_nivel.json` (iters 4-5) NO arrancaban en producción** (reacciones mudas).
  También rompía CI (`validate_all` exit 1, 7 problemas) y `test_condiciones_mundo` (1 fallo).
- **Fix:** `dialog_graph_validator.gd`: `CLAVES_MUNDO_BASE` +`"npc_id","reaccion_id","item_id","new_level"`;
  `_clave_conocida()` reconoce ahora el sufijo `_amistad`; docstring alineado al contrato "vacío → base".

### BUG-027 — 🟠 Validador no detectaba `next_id`/`goto_id` inexistentes (RESUELTO)
- **Causa:** `_alcanzables()` solo encola aristas cuyo destino existe; una arista colgante pasaba CI y en
  runtime truncaba el diálogo sin error.
- **Fix:** bucle en `validar()` que reporta `next_id`/`goto_id` inexistentes. No afecta a los 3 grafos de
  producción (`validate_all` sigue 0 problemas).

Ambos registrados en `DOCUMENTACION/11-BUGS.md` (sección 7, Resueltos) con firma Hy3/WorkBuddy.

## 4. Contenido narrativo — DELEGADO (§11.3)

El contenido creativo de los diálogos de **M23 (Historias Secundarias), M148 (Narrativa), M150 (Diálogos
de evento)** está FUERA de la fortaleza de Hy3 (§11.3: no generación creativa libre). Se delega a un
modelo de creatividad especializado; requiere acción del orquestador para asignar. El motor (M21) ya
está listo para consumir ese contenido vía `DialogueGraph` + `start_dialogue(context)`.

## 5. Items abiertos fuera de dominio (§21.4 — NO tocados)

Los 7 `[?]` de la checklist de M21 son de dueño de OTRO modelo (M22/M23/M53/M87/M29/M31):
RF10-RF12 (traducción/IDs, M87), reporte JSON con línea/columna (limitación Godot), IDs duplicados
(no aplicable), filtrado de opciones por mundo (M53/UI), navegación de opciones con teclado (M53/UI),
diálogos contextuales por clima (M29/M31), test E2E play mode. Quedan como `[?]`; no se verifican ni
se cierran desde M21 (§21.4: no tocar módulos de otro modelo).

## 6. Veredicto

✅ **CIERRE TÉCNICO VERIFICADO (§21.8).** El núcleo de M21 (DialogueManager + validador + condiciones de
mundo + reacciones M20→M21) funciona en runtime (13/13 tests 0 fallos, CI verde) tras corregir la
regresión BUG-026 y el gap BUG-027. El módulo queda en 🟡 Con dudas exclusivamente por los 7 `[?]` de
dueño ajeno (§21.4), no por defectos del núcleo.

⚠️ **Nota de identidad:** la fila M21 de CHECKLIST-GLOBAL cita "Agente actual = agnes-2.5-flash" (reclamado).
El verificador cruzado de este log es **Hy3 / WorkBuddy** (corrección de identidad 2026-09-11 del usuario:
Hy3 NO es DeepSeek). No se sobre-escribe el reclamo de agnes; esta es QA cruzado independiente.

**Firmado:** Hy3 / WorkBuddy — Log 846, §21.8
