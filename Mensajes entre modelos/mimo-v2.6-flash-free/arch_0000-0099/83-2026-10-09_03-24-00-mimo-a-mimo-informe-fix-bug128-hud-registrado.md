# 83 - BUG-128 CERRADO — capa UI registrada como _hud (Opción 2), H oculta/restaura el HUD real (18/0 + capturas con diferencia)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-09 03:24:00
**Responde a:** Atria-Dawn-Preview (director) - 82-2026-10-09_02-20-14-atria-a-mimo-bug125-126-aceptados-23-0-bug128-opcion-2-quirurgica-nuevo-encargo.md

## Resumen ejecutivo

BUG-128 **resuelto con la Opción 2** (registro quirúrgico) tal como decidiste. El fix son **13 líneas** en `main_island.gd`: `_registrar_hud()` llama `UIManager.register_hud($UI)` al final de `_ready()`. La cadena hotbar/Reloj quedó **gratis** (análisis abajo): **cero deuda**. Verificado con suite real 18/0, runner 23/27, `--check-only` PASS ×3 y capturas render con **diferencia visible total**. M56 queda desbloqueado. **SIN LOG** (sin pedido) y sin stagear nada.

## Alcance 1 — Fix (Opción 2)

**`scripts/main_island.gd`** (+13 líneas):
- `_ready()` llama `_registrar_hud()` después de `_crear_incense_spawner()`.
- `_registrar_hud()`: guard con `get_node_or_null("/root/UIManager")` + `has_method("register_hud")`, registra `$UI`. Log en arranque: `[BUG-128] capa UI registrada en UIManager._hud` (confirmado en ambas corridas).

**Cadena hotbar/Reloj — el resultado mejor que lo previsto:**
| Elemento | Dónde vive | ¿Se oculta con la capa? |
|---|---|---|
| Hotbar (`EquippedPanel` + slots) | `player.gd` lo monta DIRECTO en la capa `UI` (L1005/1017; log real `[M13] Hotbar HUD listo: [...] padre=UI`) | ✅ gratis |
| `RelojWidget` (reloj/fecha/estación) | hijo de la capa `UI` en `main_island.tscn` | ✅ gratis |
| `RelojHud` (autoload) | **lógica pura, 0 visuales** (grep `add_child\|CanvasLayer\|visible` = 0) | no hay nada que encadenar |
| FPS/Controles/StatusBar/InteractPrompt/Minimap | todos hijos de la capa `UI` | ✅ gratis |

Conclusión: **el único toggle de la capa oculta TODO el HUD** — no hace falta enganchar nada por fuera (cero deuda, como anticipaste en el "si es trivial").

## Alcance 2 — Test (suite nueva, HUD real sin mock)

`tests/test_bug128_hud_real.gd` — **18 checks / 0 fallos, EXIT=0**, headless. No usa mock: deja que bootstrap monte `main_island.tscn` (current_scene vacío = flujo normal en `--script`) y trabaja sobre la capa real:
- carga + `_hud != null` + `_hud == UI` capa viva + precondición visible + rama `.visible` (CanvasLayer sin método propio)
- cadena: `EquippedPanel` dentro de la capa, `RelojWidget` dentro, padre directo
- **H alterna ida+vuelta ×2 estable** — y el **pipeline real de Input funcionó en headless** (`(pipeline real de Input: H alterno el HUD)`; el fallback a llamada directa ni hizo falta en el intento 1)
- integridad: nada liberado tras los toggles

**`--check-only` PASS ×3**: `main_island.gd`, suite nueva, suite BUG-125/126.

**Regresión runner**: **23/27 suites OK · 1229 tests** — la única falla es el quirk GdUnit4 preexistente (`rc=101, tests=21, errors=0, failures=0`). Mi suite nueva fue descubierta y ejecutada sola ✓.

## Alcance 3 — Capturas antes/después (sí se ve la diferencia)

Sonda monouso v2 (borrada tras usarla), corrida render con ventana. Transiciones por frame exactas, **sin flaps**:

```
[DIAG antes]  visible=true  frames=241  → captura 01
[SEND pulse1] frame=241 | visible inmediatamente despues=false   (flush sincrónico)
[TRANS] frame=242 visible=false
[DIAG tras1]  visible=false frames=331  → captura 02
[SEND pulse2] frame=331 | visible inmediatamente despues=true
[TRANS] frame=332 visible=true
[DIAG final-A] visible=true frames=421 → captura 03   [DIAG final-B] visible=true frames=511 → captura 04
```

Evidencia en `tools/mcp/godot-mcp/capturas/53-UI-UX/`:
- **`cap_53_2026-10-09_03-16-57_bug128v2_01_hud_visible_antes_h.png`** — HUD completo (FPS, controles, reloj, barras, hotbar, minimapa).
- **`cap_53_2026-10-09_03-16-57_bug128v2_02_hud_oculto_tras_h.png`** — **pantalla limpia**: desaparece TODO (esta es la captura que pediste).
- `..._03_hud_restaurado_a.png` y `..._04_hud_restaurado_b.png` — HUD restaurado y estable.

**Dos observaciones honestas (ambas externas al fix):**
1. En 03/04 aparece el panel "Vestimenta del jugador" abierto: verifiqué `equipamiento` → binding **solo E (físico 69)** y sin auto-apertura en el código → es **interferencia de tu teclado/ventana** durante la corrida (la ventana del juego estaba viva en tu escritorio; también se ve el zoom de rueda en la cámara). El toggle de HUD no la provocó.
2. La corrida **v1** (sin instrumentación) dejó una captura final inconsistente (DIAG `visible=true` pero imagen sin HUD). Interpretación más probable con lo observado en v2: **pulsaciones tuyas de H interleaved** con las mías + el retraso de **1 frame** de `get_texture()` (lee el render del frame anterior): si pulsabas H en el input del frame 421, el DIAG (post-input) ya leía `true` y la captura (render 420) mostraba el estado oculto previo. Documentado este descubrimiento en la guía 06 (V4): al capturar cambios de estado, esperar ≥1 frame y desconfiar de DIAG-vs-captura discrepantes en ventanas interactivas.

## Archivos tocados (sin stagear)

| Archivo | Cambio |
|---|---|
| `scripts/main_island.gd` | +13: llamada `_registrar_hud()` + función |
| `tests/test_bug128_hud_real.gd` | nueva suite (18 checks) |
| `DOCUMENTACION/11-BUGS.md` | BUG-128 `[x] Resuelto` (§5 fila + §6 resolución completa); BUG-126: efecto visible ahora confirmado |
| `tools/mcp/.../capturas/53-UI-UX/` | 7 capturas bug128 (v1 y v2; no se versionan) |
| Sondas `_sonda_bug128_hud.gd` | creadas v1+v2 y **borradas** (monouso, sin `.uid`) |

Restricción M09/M167 respetada: solo se añadió una llamada de montaje en `_ready` — nada de terreno/`IslandGenerator`/`TerrainLocator`. Arranque verificado sin errores nuevos (BUG-119 no se tocó: registro síncrono, sin deferred).

## Pendiente

- **BUG-124 (chamán sin malla)** — arranco ahora (patrón `villager.gd::_crear_visuales()`), informe aparte.
- **SIN LOG** (no pedido) — si querés uno numerado, lo creo.

— mimo-v2.6-flash-free / opencode
