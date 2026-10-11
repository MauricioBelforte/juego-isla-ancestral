# Log 1629: M84 L117 — Reporte de licencias de audio por build (AudioLicenseReportTool)

**Fecha:** 2026-10-11
**Hora:** 03:40 (UTC)
**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code

## Resumen
Implementación del `[?]` L117 de M84-Musica-Y-Audio-Legal ("Generar reporte de licencias de audio por build"), por encargo del director mimo-v2.6 (msg 22, canal Ling-3.1-Flash). Tool de editor/build (NO runtime) que escanea los assets de audio del build, los cruza contra el inventario `data/legal/audio_licenses.json` y escribe `Builds/<plataforma>/LICENCIAS-AUDIO.md`. Todo asset del build aparece en el reporte; el que NO está en el inventario se marca **`SIN LICENCIA REGISTRADA`** (nunca se omite) y se loguea `push_warning` en consola.

## Cambios Realizados
- **`game/isla-ancestral/scripts/legal/audio_license_report_tool.gd`** (nuevo, `@tool class_name AudioLicenseReportTool`, API estática):
  - `escanear_assets_audio(raices)` — escaneo recursivo de `.ogg/.wav/.mp3/.opus/.flac/.mid/.it/.xm` (raíces inexistentes se ignoran sin error).
  - `cargar_inventario(ruta)` / `construir_indice(inventario)` — lectura **solo lectura** del JSON (no se modifica).
  - `buscar_track(archivo, indice)` — matching por stem del archivo == `id` del track (case-insensitive).
  - `formatear_tipo_licencia()` — taxonomía del encargo: CC0 / CC-BY / CC-BY-SA / CC-BY-NC (rechazada) / MIT / PROPIA / OTRO.
  - `generar_reporte(assets, indice, plataforma, ruta_inventario)` — markdown, **una sección por asset** con nombre de archivo, tipo de licencia, autor, fuente y URL de origen (fuente/URL derivadas de `autor`/`attribution` del inventario — el JSON no tiene campos propios, derivación documentada en el código).
  - `generar_reporte_build(plataforma, dir_salida, ruta_inventario, raices_audio)` — orquestador (hook de build): escanea → cruza → escribe `LICENCIAS-AUDIO.md` → `push_warning` por asset sin licencia → devuelve resumen.
- **`game/isla-ancestral/scripts/legal/audio_license_report_editor.gd`** (nuevo, `extends EditorScript`): entry point **invocable desde el editor** (File → Run) y desde el pipeline de build (M117). Default: `Builds/<OS.get_name()>/LICENCIAS-AUDIO.md`; raíces `res://assets/audio/`, `assets/music/`, `assets/sfx/`, `audio/`. Si hay assets sin licencia → `push_error` (build debe corregirse antes del release).
- **`game/isla-ancestral/scripts/legal/test_audio_license_report_m84.gd`** (nuevo, `extends SceneTree`): test headless con **simulación determinista documentada** (criterio de cierre del encargo): crea 4 fixtures temporales en `user://m84_report_test/` — 3 registrados en el inventario (`aurora_main.ogg` PROPIA, `ost_piano_01.ogg` CC-BY, `sfx_ambiente_01.wav` CC0) + **1 inyectado a propósito** (`sfx_no_registrado.wav`) para demostrar el caso `SIN LICENCIA REGISTRADA`. 13 checks. Limpieza de fixtures al final.

## Verificación (evidencia literal)
- Comando: `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script scripts/legal/test_audio_license_report_m84.gd` → **EXIT 0**.
- Salida: `=== Resumen M84 L117: 13 checks, 0 fallos ===` / `TEST M84 L117 OK — todos los checks pasaron`.
- WARNING verificado en consola (requisito del encargo): `WARNING: [M84] SIN LICENCIA REGISTRADA: 'sfx_no_registrado.wav' — asset de audio del build sin registro en res://data/legal/audio_licenses.json` (backtrace → `generar_reporte_build (audio_license_report_tool.gd:235)`).
- Reporte verificado en disco: contiene `## aurora_main.ogg` + `PROPIA (del estudio)`, `## ost_piano_01.ogg` + `CC-BY (atribución)`, `## sfx_ambiente_01.wav` + `CC0 (dominio público)`, `## sfx_no_registrado.wav` + `SIN LICENCIA REGISTRADA`, y resumen `4 assets — 3 con licencia registrada, 1 SIN LICENCIA REGISTRADA`.
- **Sin regresión:** `test_audio_licenses_m84.gd` re-corrido → **EXIT 0** (15 checks, 0 fallos).
- Log completo de la corrida: `C:\Temp\kilo\m84_l117_run.txt`.

## Antes / después de L117
- **Antes:** `- [?] Generar reporte de licencias de audio por build → no implementado` (revertido por auditoría H2-estricta BUG-070, s2 #152, 2026-10-08).
- **Después (propuesto):** `- [x] Generar reporte de licencias de audio por build → implementado en audio_license_report_tool.gd + audio_license_report_editor.gd; test 13/0 (Log 1629)`. **El flip lo aplica el director** (los flips son del director, encargo msg 22).

## Límites respetados
- READ-ONLY sobre otros módulos: solo archivos de M84 + 3 scripts nuevos en `scripts/legal/`.
- **0 commits** (working tree; commits los centraliza atria-dawn bajo pedido del fundador).
- Inventario `data/legal/audio_licenses.json` **solo leído, no modificado**.

## Archivos Modificados/Creados
- Creados: `game/isla-ancestral/scripts/legal/audio_license_report_tool.gd`, `audio_license_report_editor.gd`, `test_audio_license_report_m84.gd`
- Modificados (documentación M84): `DOCUMENTACION/84-Musica-Y-Audio-Legal/plan-actual/04-Codigo.md` (sección del tool), `05-Checklist.md` (nota del agente — **sin tocar marcas**)
- Este log: `Logs/1629-m84-l117-reporte-licencias-audio-build_2026-10-11_03-40-00.md`

## Pendiente del director
- Aplicar flip L117 `[?]` → `[x]` con la evidencia de este log + informe msg 23 (canal Ling-3.1-Flash).
- Actualizar totales GLOBAL (fila 84: 98/99 → 99/99) y CHECKLIST-QA-SEALS si corresponde.
