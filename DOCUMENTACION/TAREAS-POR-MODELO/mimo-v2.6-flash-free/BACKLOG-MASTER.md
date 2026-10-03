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
- [x] Log creado: **1206** — M91 lote 8: H-1 RESUELTO (el runner SI descubre S1; era la etiqueta --module m91, no el descubrimiento; evidencia --module audio 8/8 OK y --module subtitle 1/1 OK; sin renombrar nada) + hallazgo: testing.yml usa GdUnit4 con || true y nunca falla
- [x] Log creado: **1208** — M91 lote 9: secciones de PRUEBAS completas (03-Diseno §11 y §19 reescritas de esqueleto a 11.1-11.7 y 19.1-19.5 con API sondeada) + correccion de API de Godot 3 en 3 documentos (get_device_list/set_device/get_device -> get_output_device_*) + 14 items `[x]` + notas anti-inflado en L18/L22/L23/L151 + checklist 192→206/32/1 (86%)
- [x] Log reservado y creado: **1210** — M91 LIBERADO a 🟡 Con dudas (206/239, 86%): los 4 registros de §26 actualizados (CHECKLIST-GLOBAL fila 91 byte-exacta, bloque Reserva actual + firmas en plan-actual, ESTADO-PARALELO, guía 08) + suites 9 OK/0 FAIL + QA §21.8 pendiente
- [x] Fix post-liberación (commit `b894ffe`, sin número de log nuevo): el bloque Reserva insertado tras el H1 desplazaba **+14** todas las líneas → se movió al **FINAL** del `05-Checklist.md` (15+/15−) y la línea 3 (blanca) pasó a ser línea de estado que remite al bloque; líneas 4..327 byte a byte iguales a `e986181` → **~200 referencias `L##` restauradas sin renumerar** en 05-Checklist, 03-Diseno, 04-Codigo, CHECKLIST-GLOBAL, ESTADO-PARALELO y Log 1210. Detalle en Log 1210 §"Corrección posterior".

## Módulo LIBERADO 🟡 — 91-Configuracion-De-Audio

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).**
> **LIBERADO 2026-10-02 21:55 a 🟡 Con dudas — Log 1210.** Los 4 registros de §26
> quedaron actualizados (CHECKLIST-GLOBAL fila 91, 05-Checklist bloque Reserva
> **al final del archivo** para no desplazar las referencias `L##`, ESTADO-PARALELO,
> guía 08). **Queda pendiente el QA cruzado §21.8** — lo toma un
> modelo DISTINTO a mimo-v2.6-flash-free. No re-llevar este módulo a ✅ sin resolver
> L88 `[?]` (HRTF).
>
> Dominio del chat: UI + audio + i18n (creditos_layer, farewell, i18n,
> performance de M131). Complejidad 1 — ideal para vos.

**Fuente de verdad:** `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md`
(206 [x] / 32 [ ] / 1 [?], 239 ítems totales — avance al cierre del lote 9
2026-10-02). Lee ese archivo ANTES de empezar; las tareas de abajo son un
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

**Pool:** lee `Logs/NUMEROS_DISPONIBLES.txt` en disco VIVO (cabeza **1211** tras
reservar el **1210** el 2026-10-02 22:04, pero verificá — se mueve). Reserva con
§6.1.a y el helper `python "$env:TEMP\reservar.py"`. Al commitear, la pool está
compartida: verificá `git status` y solo agregá el archivo si la única diferencia
son borrados de números.

**Pendiente de M91 (tras lote 9):** **checklist en 206/32/1 (86%)** y ya
**no queda trabajo de diseño propio**. Desglose real de los 32 `[ ]`:

- **3 rollups** (L18, L22, L23) — miden *ejecución/sección completa*, no
  diseño; tienen nota en el propio ítem para que no se inflen (Trampa 119).
- **13 de M53 (menú)** — L147 (dropdown de dispositivo) y L198–L211
  (sliders, toggles, dropdowns, botones de prueba).
- **10 de sonidos de interfaz** — L110–L114, L116 y L240–L243: bloqueados
  porque el proyecto tiene **cero** assets `.wav`/`.ogg`/`.mp3` (§7 sellada).
- **2 de M58** — L107 (accesibilidad) y L171 (alto contraste).
- **2 de M87** — L179 (subtítulos multi-idioma) y L181 (localización de
  nombres de dispositivo).
- **1 de M59** — L288 (trigger de guardado al cerrar settings).
- **1 HRTF** — L151, depende del único `[?]` del módulo: **L88** (Godot
  4.7.2 no expone HRTF; opciones escritas en `03-Diseno` §5.1.1).

Referencias útiles del lote 8 (siguen vigentes): H-1 cerrado — usar
`--module audio` (S1+S2, 8/8 OK) y `--module subtitle` (S3, 1/1 OK); **no**
renombrar `test_audio_config.gd` (rompería el `preload` de
`scripts/editor/_colector_sintaxis.gd:38`). CI real para M91 = migrar a
GdUnit4 en `tests/` (eso es módulo de CI).

**Al terminar o liberar:** Estado 🔵 → ✅/🟡, Agente → —, actualiza
Última actividad en la fila 91. Nunca dejes 🔵 huérfano (§21.4.5).
**HECHO 2026-10-02 21:55 (Log 1210):** fila 91 → `🟡 Con dudas`, `206/239`,
Agente `—`, ÚltAct `2026-10-02 21:55`. **Siguiente paso de este módulo:
QA cruzado §21.8 por OTRO modelo** (no por este chat).
