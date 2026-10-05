**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 07-Resultados-Testings.md — Módulo 55: Diario del Jugador

Fecha de la corrida: **2026-10-04** (iter. 2, lote 1 de UI). Entorno: Godot 4.7.2 headless,
Windows. Logs completos en `$env:TEMP\opencode\` (no se versionan).

## 1. Resultados

| Suite | Comando (`--headless --path game/isla-ancestral --script …`) | Resultado | Log |
|---|---|---|---|
| S1 servicio | `res://scripts/diario/test_diario.gd` | **0 fallos, exit=0** | `m55_reg_diario.log` |
| S2 UI (nueva) | `res://scripts/ui/test_diario_ui.gd` | **89 checks, 0 fallos, exit=0** | `m55_verde_final.log` |
| S3 i18n regresión | `res://scripts/ui/test_ui_i18n_m53.gd` | **0 fallos, exit=0** | `m55_reg_i18n.log` |
| S4 framework regresión | `res://scripts/ui/test_ui_framework.gd` | **0 fallos, exit=0** | `m55_reg_framework.log` |
| S5 settings regresión | `res://scripts/ui/test_settings_audio_roundtrip.gd` | **51 checks, 0 fallos, exit=0** | `m55_reg_settings.log` |

**Total: 5/5 suites verdes.** Baselines previos a tocar código (misma sesión, antes de
escribir): `m55_base_diario.log` (S1 0 fallos) y `m55_base_i18n.log` (S3 0 fallos) — sin
regresión respecto del punto de partida.

## 2. Sonda rojo demostrada (guardián del test)

1. **Sabotaje:** en `diary_layer.gd`, `_texto_fila` dejó de anteponer `★ ` (`"XXX "` a cambio).
2. **Corrida rojo:** `m55_rojo.log` → `exit=1`, `FALLO: ★ al inicio de la fila tras marcar
   favorito (obtuvo: XXX Catalina Oso · Visto)`, `=== TEST M55 DIARIO UI: 89 checks, 1 fallo(s) ===`.
3. **Revert** del sabotaje → `m55_verde_final.log` → `exit=0`, **89/0**.

Conclusión: el test **detecta regresiones reales** (no es verde por omisión).

## 3. Bugs encontrados y corregidos durante los tests

| # | Bug | Causa | Fix | Detectado por |
|---|---|---|---|---|
| B1 | Desmarcar favorito no refrescaba la fila | `_on_favorito_pressed` usaba `if not alternar_favorito(...)` como guard, pero devuelve el **nuevo estado** (false al desmarcar) | guard con `esta_registrada()` + refresh incondicional | check ★ de S2 (corrida 1) |
| B2 | Textos estáticos no se re-traducían al abrir en locale EN | `on_layer_opened` no volvía a aplicar i18n | `_aplicar_textos_estaticos()` al abrir | check `Close` de S2 (corrida 1) |
| B3 | Atajos `diario`/`favorito` no encontraban la capa | el test la instanciaba como `DiaryTest`; `ui_manager` busca `"DiaryLayer"` | nombre correcto + liberación preventiva de capa homónima previa | acciones de S2 (corrida 1) |
| B4 (preexistente, NO mío) | `SCRIPT ERROR: Nonexistent 'bool' constructor` en `interaction_manager.gd:669` al hacer `pop_layer` | `interaction_manager` (zona BUG-096, kimi-k3) | **no tocado** — emisión de ruido que no aborta resultados; aparece también en las suites de M53 | consola de S2 |

Corrida 1 de S2: **89 checks, 4 fallos + 1 error preexistente** → fixes B1–B3 → corrida 2 verde.

## 4. Verificaciones de calidad de archivo

- `es.po`/`en.po`: UTF-8 sin BOM, 0 U+FFFD, EOL LF, +19 claves `DIARY.*` por idioma (verificado con script propio).
- `project.godot`: bloque `[input]` con CRLF preservado; acción `diario` insertada idempotente (script con guard).
- `05-Checklist.md`: UTF-8 sin BOM/FFFD, CRLF intacto (230 líneas), conteo de marcas 33 [x] / 1 [?] / 97 [ ] = 131.

## 5. Pendientes no cubiertos por esta corrida (honestidad)

- 13/14 categorías con entradas (`fotografías` = 0, falta M56) → checklist Y en `[?]`.
- Rendimiento/500+ entradas, virtualización, pooling (W), tercer idioma (V), `validate_diary.gd` (Y),
  persistencia entre sesiones reales (Z): **fuera de esta corrida**, sin probar.
- Estética "cozy": sin vía de visión (M154) usada en esta sesión; verificación solo estructural.
