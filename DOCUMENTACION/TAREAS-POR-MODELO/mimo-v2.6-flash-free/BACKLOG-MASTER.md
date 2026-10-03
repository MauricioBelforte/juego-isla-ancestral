# BACKLOG-MASTER — mimo-v2.6-flash-free (opencode)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Tareas

- [x] Log reservado y creado: **1161** — P-43b QA cruzado M106 + M122
- [x] Log reservado y creado: **1164** — P-50 cierre hallazgos (KnownIssue H-1, cabeceras H-2, sello SEALS)
- [x] Log reservado y creado: **1172** — Consolidación bucket P-48 (34 archivos, 5 commits: 454d0ae, dac4740, a757f51, 3a568ea, afcdf4f)
- [x] Log reservado y creado: **1175** — P-48 ronda 2: 6 archivos restantes del dominio mimo (8db4abd, c6b3426) + fix de regresión M150 que introduje en 3a568ea
- [x] Log creado: **1178** - BUG-081: 4 errores de inferencia en scripts/legal (M131 + M84)
- [x] Log creado: **1184** — Sello M131-Creditos a ✅ (pantalla de creditos implementada, 9 KnownIssue de audio, QA P-56 de agnes-3-flash)
- [x] Log creado: **1191** — M91 lote 1: efectos de bus (DynamicRangeManager, CompressionManager, OutputDeviceManager) + 82 checks en verde + trampas T-107/T-108
- [x] Log creado: **1194** — M91 lote 2: API de porcentaje 0-100 para sliders M53 (6 funciones) + piso CHECKS_MINIMOS=66 + checklist 118→141
- [x] Log creado: **1198** — M91 lote 3: subtítulos (autoload SubtitleManager + test 80 checks + T-109 + doc) + checklist 141→157
- [x] Log creado: **1199** — M91 lote 4: aplicacion/control por bus (11 items, test 103 checks, tabla de enrutamiento) + checklist 157→168
- [x] Log creado: **1201** — M91 lote 5: 06-Plan-Testings.md + 07-Resultados (265 checks en verde) + checklist 168→173
- [x] Log creado: **1203** — M91 lote 6: contraste Especificación RF1-RF15 (10 rollup) + L102 + L216/L277/L285 → checklist 173→187
- [x] Log creado: **1204** — M91 lote 7: Audio 3D (03-Diseno §5 20→119 lineas con API sondeada en 4.7.2; hallazgo SIN HRTF en el motor -> L88 `[?]`; 5 items `[x]`; fix del `[x]` falso L227 AudioEffectEQ) + checklist 187→192/46/1

## Módulo ACTIVO — 91-Configuracion-De-Audio

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).** Lock 🔵 a tu nombre.
> Tu dominio exacto: UI + audio + i18n (creditos_layer, farewell, i18n,
> performance de M131). Complejidad 1 — ideal para vos.

**Fuente de verdad:** `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md`
(192 [x] / 46 [ ] / 1 [?], 239 ítems totales — avance al cierre del lote 7
2026-10-02 2026-10-02). Lee ese archivo ANTES de empezar; las tareas de abajo son un
resumen, no la fuente.

**Código real:**
- `game/isla-ancestral/scripts/audio/audio_config_service.gd` (autoload)
- Suite headless: `res://scripts/audio/test_audio_config.gd`
  **Línea base medida por atria-dawn 2026-10-02: 0 fallos, EXIT 0.**
  (Nota: el output de la suite se mezcla con los logs de arranque del
  juego — buscá "=== TEST M91 AUDIO" en la salida.)

**Tareas de código concretas (las más valiosas):**
1. Sliders de volumen (maestro/música/efectos/ambiente/voces/UI) con
   conversión 0-100% → dB (`linear2db`) y valores por defecto.
2. Buses de audio (Music/Buses/SFX) conmute y separación de canales.
3. Dispositivo de salida seleccionable + rangos dinámicos.
4. Persistencia de la configuración (M59).
5. Integración con M91 ↔ M41/M42/M43 (motores de audio ya existen y pasan
   tests — a diferencia de M131, acá HAY infraestructura).

**Método:** lotes → suite con binario real
(`C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script
res://scripts/audio/test_audio_config.gd --quit-after 8000`) → marca [x]
solo con la suite en verde. Si creas tests nuevos, mantén un piso de
checks (CHECKS_MINIMOS) como en M105.

**Trampas:** 114 (pathspec SIEMPRE — kimi trabaja M70 en
scripts/interacciones/, DeepSeek en M62 scripts/memory/ y rendimento),
M-06 (byte-exact si tocas CHECKLIST-GLOBAL: 231 CRLF / 0 LF / 219 CR),
119 (✅ inflado), 118 (impresión visual ≠ diagnóstico).

**Pool:** lee `Logs/NUMEROS_DISPONIBLES.txt` en disco VIVO (cabeza actual
1205 tras reservar el 1204, pero verificá — se mueve). Reserva con §6.1.a.

**Pendiente de M91 (tras lote 7):** queda **1 `[?]` + 46 `[ ]`**, todos
bloqueos reales: **L88 HRTF** (no existe en Godot 4.7.2 — elegir entre
GDExtension / DSP propio / aceptar pan+atenuación), 12 de M53 (menú),
10 de assets de audio (0 `.wav`/`.ogg`/`.mp3` en el proyecto), 9 de
hardware del usuario, 3 de AudioTestManager (no creado), 3 de pruebas de
calidad, 3 rollups, 5 de M58/M87. **Nada técnico propio salvo H-1:**
`tools/ci/run_tests.py --module` no descubre `test_audio_config.gd`
(es substring de la ruta). Cuando entre la primera fuente 3D, implementar
`03-Diseno` §5.7 (bus propio + LPF + raycast desde el oído).
**Al terminar o liberar:** Estado 🔵 → ✅/🟡, Agente → —, actualiza
Última actividad en la fila 91. Nunca dejes 🔵 huérfano (§21.4.5).
