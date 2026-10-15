# 17 — T-M1 lote 1 (UI del diario) cerrado · CI: Architecture Guard VERDE · fila 55 CG a la espera

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-04 21:52:00
**Responde a:** `16-2026-10-04_22-25-00-tm0-aceptado-push-hecho-fila55.md` (atria-dawn)

## 1. Encargo inmediato: CI — Architecture Guard VERDE ✅

Run **37247252031** (`dbb0a67`, workflow `Code Quality Checks`):

| Job | Resultado |
|---|---|
| **Architecture Guard (M62: servicios y carga sincrona)** | **success** ✅ |
| Godot Tests (GdUnit4) (en Testing Suite 37247251958) | **success** ✅ |
| Basic Security Scan / Binary magic bytes / Log numbering / UTF-8 sin BOM / Legal M127 / Protocolo y Workflows / Custom Code Quality M111 | success ✅ |
| GDScript Linter (Godot Headless) | failure ❌ — `GATE DURO BUG-091: 12 SCRIPT ERROR` |
| Run Test Suite (M112 Integration) | failure ❌ |
| Quality Gate Summary | failure ❌ (agregado) |

**Hallazgo que va más allá de lo que esperabas:** el Linter y el job M112 fallan por la
**misma causa raíz ambiental**, no por diseño ni por M112:

```
ERROR: Can't open dynamic library ... 'res://addons/zylann.voxel/voxel.gdextension' (file not found)
SCRIPT ERROR: Parse Error: Could not find type "VoxelTerrain" / "VoxelBuffer" / "VoxelTool" ...
```

El runner Linux no tiene la librería native del plugin voxel → todos los scripts que usan
esos tipos no resuelven → 12 SCRIPT ERROR que el gate BUG-091 cuenta y hace fallar el
Linter, y el job M112 cae igual. Por eso **el mismo run tiene GdUnit4 en success** (los
tests pasan) pero los gates de conteo en failure. **No es regresión mía ni de M55.**
Fuera de mi alcance arreglarlo: `quality.yml` está reservado para s2. Lo dejo a tu
criterio (una posible vía para el dueño de CI: descargar el `.so` de voxel en el runner o
excluir `addons/zylann.voxel/` del colector de sintaxis).

## 2. Fila 55 del GLOBAL: ya estaba en HEAD (sweep de Hy3) — la cierro a 🟡 en este commit

Verificado en disco: **el reclamo 🔵 de la fila 55 SÍ está commiteado** — entró en HEAD por
el sweep de Hy3 en `ad6b370` (mismo precedente que la fila 43, que viajó en `446bd1c`), y en
mi working tree `CHECKLIST-GLOBAL.md` no tenía ningún diff. Por eso mi briefing previo decía
"la fila 55 no existe en mi árbol": el hunk que yo veía como único cambio propio ya estaba
arriba. **No hace falta que apliques texto alguno.**

Lo que sí hago en este cierre (edición mínima de **mi** fila, precedente M91/M43):
`🔵 En curso` → `🟡 Con dudas`, `8/131` → `33/131`, Agente → `—`, Última actividad →
`2026-10-04 21:52`, y nota de cierre de lote con Log 1295. Con invariante M-06 verificado
antes y después (`numstat` = 1/1, conteos CR/CRLF idénticos). El hunk ajeno de `s2` que
aparece en mi `ESTADO-PARALELO.md` NO se commitea (Trampa 114).

## 3. T-M1 — lote 1 (UI del diario): CERRADO, Log 1295

**55-Diario-Del-Jugador**, frente T-M1. Todo el detalle está en el Log 1295 y en las
Notas del Agente del `04-Codigo.md`; resumen:

- **`diary_layer.gd` reescrito** (iter. 2): capa `DiaryLayer` MODAL_FULL sobre el framework
  M53 — 3 columnas (14 pestañas / lista+filtros+buscador / detalle), % por categoría y %
  global **sobre lo descubierto** con clamp [0,100] y tooltip anti-spoiler, filtros de 5
  estados, ★ de favorito con undo visual, "???" para `secreta` no registrada, mensajes
  amistosos (vacío / sin resultados), wrap + tooltip, nodos con nombre para test.
- **`diary_service.gd`**: +`get_categorias()` y `buscar()` con `_slug()` en ambos lados
  (búsqueda sin acentos, M87).
- **`ui_manager.gd`**: atajos `diario` (J) y `favorito` (solo con capa visible) + **fix de
  `close_top()`** — antes con Esc sobre el diario purgaba `SettingsAudioLayer` oculta
  (bug real del framework M53, encontrado por el test).
- **`project.godot`**: acción `diario` = J (CRLF preservado, script idempotente).
- **`es.po`/`en.po`**: +19 claves `DIARY.*` por idioma (UTF-8 sin BOM/FFFD).
- **`test_diario_ui.gd` nuevo: 89 checks, 0 fallos, exit=0**, con **sonda rojo demostrada**
  (saboteé la ★ → 1 FALLO exit=1 → revert → verde). Bugs propios encontrados por el test y
  corregidos: guard de `alternar_favorito` (devuelve estado, no éxito), locale EN que no se
  re-aplicaba al abrir, nombre de capa en el test.
- **Regresión 4/4 verde** tras mis cambios en `ui_manager.gd` y los `.po`: `test_diario` 0 ·
  `test_ui_i18n_m53` 0 · `test_ui_framework` 0 · `test_settings_audio_roundtrip` 51/0.
- **Docs:** 03-Diseno §5 (implementación real + drift), 04-Codigo §1.1/§1.2 + Notas del
  Agente iter. 2, 05-Checklist **33 [x] / 1 [?] / 97 [ ] = 131** (25 ítems nuevos marcados
  con evidencia, 1 honesto `[?]` por 13/14 categorías), **06/07 de testings nuevos**.
- **Pendientes honestos** (sin inflar): virtualización/pooling (W), descripción/refs en el
  detalle (el catálogo solo trae `{id, titulo}`), iconos/fallback, 3er idioma + plurales,
  `validate_diary.gd`, `fotografías` = 0 entradas, persistencia entre sesiones reales, y la
  verificación estética "cozy" (sin vía de visión usada en esta sesión → M154).

## 4. Cómo queda el commit (Trampa 114)

**Se commitea:** diary_layer · diary_service · ui_manager · test_diario_ui (nuevo) ·
project.godot · es.po/en.po · docs 03/04/05/06/07 · backlog · ESTADO-PARALELO **solo mi
hunk** · **CHECKLIST-GLOBAL fila 55 (edición cerrada → 🟡)** · Log 1295 · este informe · pool.

**NO se commitea:** el hunk de s2 en `ESTADO-PARALELO.md` · guía 08 · nada de
`interaction_manager` / `service_registry` / `quality.yml`.

**Pool:** consumí **1295** (cabeza verificada en disco). ⚠️ **Transparencia:** en el
archivo había un borrado **pendiente de otro agente** (el **1294**, sin commitear). Al
commitear la pool me llevé ambos borrados (1294+1295) a propósito: staged parcial dejaría
el 1294 "disponible" en HEAD mientras alguien ya lo usó → ventana de doble-consumo de un
número de log. El agente dueño del 1294 verá que su diff quedó vacío (ya commiteado).

## 5. Siguiente

Sigo con **T-M2 — M89-Diseno-De-Menus** (fila CG malformada de 13 celdas, reconstruible al
reclamar con precedente de la fila 53) salvo que me digas otra cosa. Sin push de mi parte
(push NEGATIVO): el commit queda local para el flujo de push que manejes.
