# Log 850 — QA cruzado M36 Fauna (§21.8)

**Modelo:** Hy3 (Tencent Hunyuan) / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 05:53
**Rol:** QA cruzado independiente (AGENTS.md §21.8) — verificador ≠ autor
**Contexto:** módulo que Hy3 tiene asignado como `Agente actual` (CHECKLIST-GLOBAL fila 36) y que
faltaba en la lista documentada de QA cruzado. Detectado por el usuario ("falta alguno que te hayas
asignado").

---

## 1. Alcance

M36 Fauna estaba con `Agente actual = hy3` pero sin sello §21.8. La fila ya registraba:
- **Verificado + fix (Log 410) — deepseek-v4-flash-vision-exp:** test 0 fallos + auditoría data-driven
  del catálogo (FaunaSchema: biomas/rareza/enums reales/manada/escala/radios/colores) → 7 especies OK
  (exit 0); 3 datos corregidos (conejo radio curiosidad; nutria/lechuza 2ª variante de color).
- **Jabalí etapas (Log 596 — hy3):** `jabali_npc.gd` + 2 instancias en `main_island.tscn` (joven/adulto),
  runtime verificado 0 errores.

Pendiente (no bloquea §21.8): criaturas in-game (M64 IA).

## 2. Verificación headless (re-grounding Hy3)

- Test: `scripts/fauna/test_fauna.gd` (`extends SceneTree`, autoloads `fauna` + `fauna_registry`).
- Comando: `"<godot_console>" --headless --path game/isla-ancestral --script res://scripts/fauna/test_fauna.gd`
- Resultado: `=== TEST M36 FAUNA: 0 fallo(s) ===` → **EXIT 0**.
- Cobertura del test (según cabecera): catálogo (carga+validación+biomas+ventana horaria), especie
  (validación+colores+rareza), registry (avistamientos+dedupe+persistencia), behavior (FSM 8 estados+
  transiciones+pausa+factor de miedo), manager (especie_aleatoria_para+porcentaje_descubierto+
  candidatos_manada).
- Warnings de shutdown (`ObjectDB leaked` / `resources still in use`) = ruido de cierre, no fallos
  (igual patrón que M119/M162).

## 3. Conclusión

🔵 **M36 cumple §21.8**: verificación cruzada original por deepseek-v4-flash-vision-exp (Log 410, modelo
distinto al autor) + re-verificación headless independiente de Hy3/WorkBuddy (Log 850, 0 fallos). Módulo
documentado en la lista de QA cruzado.

---

**Firmado:** Hy3 (Tencent Hunyuan) / WorkBuddy — 2026-09-12 05:53
