# Log 1487: Fix del chamán (retry _process) y BUG-105 (agua blanca: specular rasante a 0)

**Fecha:** 2026-10-08
**Hora:** 19:51
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Dos encargos del msg 74 (atria-dawn) completados y verificados: (1) fix autorizado del
chamán flotante en `shaman_npc.gd` (patrón `_process`, sin tocar `main_island.gd`), y
(2) BUG-105 (agua blanca) cerrado: la causa dominante era el **SPECULAR=0.5 con
ROUGHNESS=0.15** del shader `agua_olas.gdshader` a ángulos rasantes (banda blanca
lechosa sobre todo el mar), NO la espuma de crestas. Fix: `SPECULAR = 0.0` +
atenuación por distancia de la espuma de crestas (menor). Verificación A/B con
capturas y runner/gate sin regresión.

## Cambios Realizados

### 1. Fix del chamán (autorizado por el director, condición: NO tocar main_island.gd)

- `scripts/enchantment/shaman_npc.gd`: retry de posicionamiento con patrón `_process`
  (timeout 8000 ms), `_locator` inyectable (patrón IncenseSpawner), sin
  `call_deferred` recursivo (evita el SIGSEGV documentado en BUG-119). El fallback
  viejo de `main_island.gd` (y=35) queda corregido por el retry del chamán.
- `main_island.gd` NO fue modificado (cumplida la condición del director).
- Verificación: sonda determinista 3/3 (B0/B1/B2), Run A con chamán en y=17 +
  incienso 6/0, `test_enchantment.gd` 58 checks / 0 fallos (C2 OK).

### 2. BUG-105 — el agua se renderiza blanca (M08/M167 render)

- **Causa dominante confirmada:** `SPECULAR = 0.5` + `ROUGHNESS = 0.15` en
  `shaders/agua_olas.gdshader` producía una banda blanca lechosa sobre todo el mar a
  ángulos rasantes (la vista normal del jugador). Evidencia:
  - Shader de diagnóstico (prof/5=rojo, costa=verde, espuma_orilla=azul):
    `cap_105_2026-10-08_debug_prof_costa_espuma.png` — el mar lejano aparece ROJO puro
    (prof ≥ 5 m válido, costa=0, espuma_orilla=0): la profundidad y la espuma estaban
    SANAS en la banda; descartadas como causa.
  - Test una-variable (`SPECULAR = 0`): `cap_105_2026-10-08_test_sin_specular.png` —
    la leche desaparece por completo, agua turquesa.
- **Causa menor (mantenida):** la espuma de crestas promedia ~0.5 a distancia (el
  campo de ondas aliasa a su media con la isla ×10); se atenúa con el nuevo uniform
  `espuma_distancia = 300` (fade 120→300 m). El look cercano queda idéntico.
- **Fix final en `shaders/agua_olas.gdshader`:**
  - `SPECULAR = 0.0` (con comentario BUG-105; el brillo del agua queda del fresnel
    en ALPHA; sparks de sol = futura iteración M51 si el usuario los pide).
  - `espuma_crestas *= 1 - smoothstep(espuma_distancia*0.4, espuma_distancia, -VERTEX.z)`.
- **Nota:** `agua_animada.gd` ya contenía un "test 1" previo (plano y=6.0, no tocado).
- Capturas A/B en `tools/mcp/godot-mcp/capturas/105-Agua-Blanca/`:
  - `cap_105_2026-10-08_antes_shader_actual.png` (agua lechosa; medido RGB 187/213/230, R−B=−44)
  - `cap_105_2026-10-08_despues_fix_specular_cero.png` (turquesa en todo el mar)
  - + debug y test sin specular (diagnóstico).
- Sonda A/B determinista `tests/_probe_bug105_cap.gd` (cámara fija + viewer movido a
  cámara + captura de viewport) — **borrada** tras usarla (monouso).

### 3. Regresión (sin impacto)

- Runner `res://tests/run_tests.gd`: 25 suites / 19 OK / 780 tests / 3 fallos
  preexistentes (equip, npcviz, GdUnit 101) — idéntico al baseline post-merge.
  (2 intentos previos colgaron a mitad de fase GdUnit — flake conocido; el 3º completó.)
- Gate `res://scripts/templos/test_regresion_templos.gd`: 76 checks / 0 fallos.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/shaman_npc.gd` (fix chamán)
- `game/isla-ancestral/shaders/agua_olas.gdshader` (fix BUG-105)
- `DOCUMENTACION/11-BUGS.md` (cierres BUG-105 + nota chamán — escrito, sin stagear)
- `Mensajes entre modelos/mimo-v2.6-flash-free/75-...-bug105-agua-blanca-fix-specular-cero-informe-cierre.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md` (sin stagear)
- Capturas (gitignore): `tools/mcp/godot-mcp/capturas/105-Agua-Blanca/cap_105_*.png` (6)
