**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 06-Plan-Testings.md — Módulo 55: Diario del Jugador

## 1. Alcance

Plan de tests automáticos del diario (servicio + UI). Ejecución **siempre headless** con Godot 4.7.2:

```powershell
& "C:\Temp\godot\godot472.exe" --headless --path game/isla-ancestral --script res://scripts/<ruta_test> 2>&1 |
  Out-File "$env:TEMP\opencode\<nombre>.log" -Encoding utf8   # exit=$LASTEXITCODE
```

**Criterio de éxito global:** `exit=0` y línea `=== TEST ...: 0 fallo(s) ===` en la salida,
sin SCRIPT ERROR propios del módulo (los preexistentes de otros módulos se listan aparte).

## 2. Suites

| # | Suite | Ruta | Cubre | Éxito esperado |
|---|---|---|---|---|
| S1 | `test_diario.gd` | `scripts/diario/` | Servicio: catálogo, registro manual idempotente + promoción, 6 puentes de eventos reales, anti-spoiler §3.2, progreso sobre descubierto, favoritos, búsqueda, persistencia con huérfanas | 0 fallos, exit 0 |
| S2 | `test_diario_ui.gd` | `scripts/ui/` | Capa DiaryLayer: estructura de nodos, apertura/cierre/pila, detalle 2 clics, favorito round-trip ★, 5 filtros, búsqueda con/sin acentos y EN, categoría vacía, 13/14 catálogo, scroll, persistencia round-trip, clamp [0,100], atajos `diario`/`favorito`, locale EN + nombres propios, sin VFX/tweens, wrap/tooltip, sin claves crudas | ≥55 checks, 0 fallos, exit 0 |
| S3 | `test_ui_i18n_m53.gd` | `scripts/ui/` | Regresión i18n (claves del framework) — regresión por mis cambios en `.po` | 0 fallos, exit 0 |
| S4 | `test_ui_framework.gd` | `scripts/ui/` | Regresión del framework de capas — regresión por mis cambios en `ui_manager.gd` | 0 fallos, exit 0 |
| S5 | `test_settings_audio_roundtrip.gd` | `scripts/ui/` | Regresión de capa SettingsAudio (round-trip) — regresión por el fix de `close_top()` | 51/0, exit 0 |

## 3. Escenarios de S2 (test_diario_ui.gd)

1. **Precondiciones:** DiaryService y UIManager cargados; acción `diario` y `favorito` existen en InputMap; snapshot/restore del estado del servicio (`get_save_data`/`restore_save_data`) para no contaminar otros tests.
2. **Estructura:** capa `MODAL_FULL`, 14 pestañas, nodos canónicos presentes, sin claves i18n crudas (`_sin_claves_crudas` recursivo).
3. **Estado inicial:** categoría vacía muestra mensaje amistoso, barra 0, % global 0.
4. **Registro y refresco:** `registrar()` → 1 fila, oculta el vacío, barra/% ≥99, sin claves crudas.
5. **Detalle (2 clics):** selección de fila → título/estado/día correctos; `SinSelección` oculto.
6. **Favorito:** round-trip marcar/desmarcar con ★ aparece/desaparece en la fila (undo visual) y estado del botón coherente.
7. **Filtros:** 5 opciones, textos ES correctos, conteos por filtro correctos.
8. **Búsqueda:** con resultados, sin resultados (mensaje exacto), sin acentos encuentra con acentos, locale EN.
9. **Multi-categoría:** registrar en `lugares` y cambiar de pestaña; 13/14 categorías con ≥1 entrada (fotografías vacía).
10. **Scroll:** offset preservado tras refresco.
11. **Persistencia:** round-trip `get_save_data` → `restore_save_data` conserva estados/favoritos y purga no-registradas.
12. **Clamp:** barra y % global siempre ∈ [0,100].
13. **Pila/cierre:** Esc/`close_top()` cierra la capa visible, no toca capas ocultas (SettingsAudioLayer intacta), reabrir re-registra (idempotente).
14. **Atajos:** `InputEventAction` de `diario` alterna apertura; `favorito` alterna solo con la capa visible.
15. **Locale EN:** `Close`, `Characters`, nombres propios intactos.
16. **Hábitos:** source scan sin `create_tween`/`GPUParticles`/`CPUParticles`; wrap + tooltip presentes.

## 4. Sondas rojo/verde (obligatorio)

Antes de dar por verde una suite nueva, **sabotear a propósito** una comprobación (p. ej. romper la ★ de la fila), ejecutar y verificar que **falla** (exit≠0, nombra el check); revertir y verificar verde. Evidencia: logs de la corrida rojo y verde en `$env:TEMP\opencode\`.

## 5. Regresiones obligatorias tras tocar `ui_manager.gd` o `locales/*.po`

S3, S4 y S5 siempre en verde además de S1/S2. Si alguna cae → no se commitea.

## 6. Fuera de alcance de este plan (pendientes honestos)

- Rendimiento con 500+ entradas (virtualización, checklist W) — requiere lote dedicado.
- ~~Persistencia entre sesiones reales~~ → **cubierto 2026-10-05**: `test_diario_persist.gd` (2 procesos, SaveManager M59 real).
- ~~`validate_diary.gd` (checklist Y)~~ → **cubierto 2026-10-05**: `scripts/diario/validate_diary.gd` (6 áreas + sonda roja EXIT 1).
- Contenido fotográfico y puente FOTO_TOMADA (L53/L212) — depende de M56.
- Tercer idioma / plurales (checklist V).
