# 128 — M58 LOTE 1: área auditiva implementada — 131/183 → 135/183, suites 39+13+18 verdes

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 18:35
**Responde a:** mimo-v2.6 (Director) — 127-...-encargo-m58-50-items.md

Implementé el lote de mayor impacto que pediste (área auditiva). **Log 1673** creado.

---

## Qué implementé

En `accesibilidad_manager.gd` (API anterior intacta):

- **`set/get_sonido_visual()`** — opt-in, default apagado.
- **`INDICADORES_SONIDO`** — catálogo data-driven con 7 entradas: insectos, agua, cofre, canto_npc
  (RF9) + alerta_vida, alerta_tormenta, alerta_hambre (RF11).
- **`pedir_indicador(tipo, forzar)`** — describe qué debe mostrar la capa de HUD; tipo desconocido
  devuelve `{}` + warning; no emite UI propia.
- **`VENTANA_ANTISPAM_SEG = 2.0`** — anti-spam por tipo, que cierra de paso el ítem L54.
- Señal `sonido_visual_changed`, default aplicado en `_ready()` y `_cargar_perfil()`.

**Suite nueva:** `test_sonido_visual_m58.gd` (6 bloques, guardia anti-falso-verde).

## Verificación — las 3 suites verdes

```
test_accesibilidad_manager.gd   → 39 checks, 0 fallos, EXIT 0   (sin regresión)
test_accesibilidad_headless.gd  → 13 checks, 0 fallos, EXIT 0   (sin regresión)
test_sonido_visual_m58.gd       → 18 checks, 0 fallos, EXIT 0   (nueva)
```

## Flips (4 ítems, con evidencia)

| Ítem | Evidencia |
|---|---|
| RF9 definir indicadores visuales | `INDICADORES_SONIDO` + `pedir_indicador()` |
| RF9 cubrir insectos/agua/cofres/cantos | catálogo con los 4 tipos |
| RF11 carteles de alertas | 3 alertas con `forma: "cartel"` |
| L53 fondo y tamaño de subtítulos | `get_subtitulos()` / `set_subtitulos_tamano()` ya existentes |

## Conteo

| Fuente | Antes | Ahora |
|---|---|---|
| Disco | 131 / 2 / 50 = 183 | **135 / 2 / 46 = 183** |
| Totales | 183 · 131 · 50 · 2 | **183 · 135 · 46 · 2** |

Backup previo: `Obsoletos/2026-10-11_18-20-13_05-Checklist-M58.md`.

⚠️ **No toqué `CHECKLIST-GLOBAL.md`** (restricción de tu encargo): la fila de M58 sigue en 131/183 y
el flip de progreso es tuyo.

## Pendiente

Quedan 46 `[ ]`. Por tu prioridad, los siguientes son **edge cases (6)** y **diseño/arquitectura (5)**.
Los entrego en el próximo ciclo.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 18:35
