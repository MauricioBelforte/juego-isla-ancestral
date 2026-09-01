# Log 309 — M21: Gate CI/editor de validación + salto rápido skip_all (2026-08-31)

**Modelo:** Hy3
**Plataforma:** Kilo
**Módulo:** 21-Dialogos
**Iteración:** 7 (continúa iter 6; aprobada por el usuario: "si hace esos 2")

## Tareas realizadas

### 1) Gate CI/editor de validación de diálogos
- **Nuevo `scripts/dialogos/validate_all_dialogues.gd`** (`extends SceneTree`): recorre
  `res://data/dialogues/*.json` y valida cada uno con `DialogGraphValidator.validar_archivo`.
  Imprime `[CI-DGT] <archivo>: OK` o la lista de problemas y sale `quit(1)` si hay problemas
  (para fallar CI). `CLAVES_MUNDO` const opcional (vacío ⇒ no chequea claves de mundo, evita
  falsos positivos; se documenta cómo poblarlo con las claves de `world_state_service.gd`).
  Es `extends SceneTree` (no `EditorScript`) para que el MISMO script corra en `--script`
  headless (CI) y desde la terminal del editor.
- **`start_dialogue` (dialogue_manager.gd) ahora también corre el validador en runtime**, tras
  `grafo.validate()`: `_obtener_validador_script().validar(grafo)` (claves_mundo vacío ⇒ solo
  huérfanos + operadores) y aborta con errores `[VAL-DGV]`. El validador se carga con `load()`
  en runtime (cacheado en `_validador_script`), sin anotación de tipo ⇒ respeta §9.50.
- **Nuevo `test_validacion_ci_m21.gd`**: espejo headless del gate (valida la carpeta, afirma 0
  problemas).

### 2) Salto rápido skip_all
- **Nuevo `func skip_all()` en `dialogue_manager.gd`**: fast-forward por nodos LINEA/EVENTO
  aplicando efectos, hasta detenerse en OPCIONES (el jugador elige) o FIN (termina). Guarda
  9999 + `stop_dialogue()` de salvaguarda ante ciclos sin FIN.
- **`dialogue_ui.gd` `_input`**: `KEY_ESCAPE` → `dm.skip_all()` (+ `set_input_as_handled`).
  ENTER/SPACE siguen avanzando una línea.
- **Nuevo `test_skip_m21.gd`** (4 sub-tests): skip hasta FIN termina; skip se detiene en
  OPCIONES; efecto de LINEA aplicado durante el salto; `choose_option(0)` tras skip funciona.

## Tests (headless, Godot 4.7.2)
7 suites M21 en verde (0 fallos):
- test_dialogos
- test_condiciones_mundo
- test_reaccion_m21_dialogo
- test_eventos_dialogo_m21
- test_validacion_grafo_m21
- test_validacion_ci_m21 (nuevo)
- test_skip_m21 (nuevo)
Más gate end-to-end `validate_all_dialogues.gd`: Resumen 3 archivos, 0 problemas.

## Archivos
- MOD: `scripts/dialogos/dialogue_manager.gd` (start_dialogue + skip_all + _obtener_validador_script)
- MOD: `scripts/dialogos/ui/dialogue_ui.gd` (KEY_ESCAPE → skip_all)
- NEW: `scripts/dialogos/validate_all_dialogues.gd`
- NEW: `scripts/dialogos/test_validacion_ci_m21.gd`
- NEW: `scripts/dialogos/test_skip_m21.gd`
- DOC: `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md` (Iteración 7)
- DOC: `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` (+2 [x])
- DOC: `CHECKLIST-GLOBAL.md` (M21 69/139 → 71/139, Iteración 7)

## Notas
- `catalina_hola.json` validado limpio (todos los nodos alcanzables desde `saludo`, sin
  condiciones) ⇒ cablear el validador en runtime no rompe diálogos existentes.
- `skip_all` NO salta decisiones: se queda en la primera bifurcación para que el jugador elija.
- Contador ULTIMO_NUMERO.txt en 303 al escribir este log (otros agentes lo pisan); se fija en
  309 para coincidir con la numeración usada en CHECKLIST-GLOBAL / 04-Codigo / 05-Checklist.
