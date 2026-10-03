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

## Módulo ACTIVO 🔵 — 43-Efectos-De-Sonido

> **Asignado 2026-10-03 00:14 por el coordinador atria-Dawn-Preview** (encaje de
> dominio — **no** por columna `Recom`: tras liberar M91 no me quedaba ninguna
> fila propia). **Fase 6 (vertical slice) · Visión V0 · Dificultad 3 ·
> 0 dependencias reales** (la `Dependencias` de la fila era espuria: traía un
> `Recom`; corregida a `—`). Al cerrarlo quedan desbloqueados **M41, M42 y M44**.
> M150 se descartó (sus 4 pendientes son `[?]` con deps externas M22/M148/M41-M43).

**Fuente de verdad:** `DOCUMENTACION/43-Efectos-De-Sonido/plan-actual/05-Checklist.md`
(**48 [x] / 52 [ ] / 0 [?] = 100 ítems**). Leelo ANTES de empezar; esto es solo resumen.

**Lote A — auditoría de coherencia (2026-10-03 00:32, hecho):** el checklist llegaba
inflado a 61 `[x]`. Auditoría contra el código real → **22 `[x]` falsos bajados a `[ ]`
con motivo inline** (Trampa 119 / §21.4.3) y **2 submarcados subidos a `[x]`** con
evidencia (madera/tierra ×4). 26 líneas modificadas, **0 líneas insertadas** →
las `L##` no se movieron. Suite `test_sfx_m43.gd` = **15/0 OK, EXIT=0**.
Brecha real detectada (diseño `04-Codigo.md` §2 vs runtime):
`reproducir_localizado`, `configurar_volumen`, `sfx_catalog`, `sfx_tones`,
ducking, distancias 15/20/30 m, límites por categoría, test de señales →
**ninguno existe**; y el proyecto tiene **0 assets de audio** (§7 sellada).

**Lote B1 — familia tonal (2026-10-03 00:40, hecho):** creado
`game/isla-ancestral/data/audio/sfx_tones.json` (7 SFX: confirmacion, logro, error,
recoger, compra, venta, crafting_exito) + API `tono(nombre)` / `tonos_disponibles()`
en `sfx_manager.gd` (`_cargar_tones()` en `_ready`, sin romper la API previa).
Suite ampliada con `_test_tonos()`: **15 → 35 checks, 0 fallos, EXIT=0**.
Cierra **C52-C57 + G105** (checklist 41 → 48 `[x]`, nota de totales actualizada).
**Lección documentada en `GUIA-GODOT/01` §29:** `JSON.parse_string()` devuelve
`float` y el `==` de `Array` es exacto → 4 fallos en falso por
`[0,4,7] != [0.0,4.0,7.0]`; solución `_a_ints()` (normalizar a int **antes** de
comparar, sin aflojar la aserción). C51/C58 siguen `[ ]`: **M41 no define escala
ni leitmotifs** (`music_director.gd` sin notas, `music_context_matrix.json` solo
temas/capas/pesos).


**Código real (escrito por este chat en iteraciones previas):**
- `game/isla-ancestral/scripts/audio/sfx_manager.gd` (M43) + `test_sfx_m43.gd`
  (**suite de referencia: 35/0, ya descubierta por el runner**)
- Vecinos con los que hay que integrar, **no reimplementar**:
  `music_director.gd` (M41), `ambient_director.gd` (M42),
  `feedback_director.gd` (M44), `audio_config_service.gd` (M91),
  `shuffle_sampler.gd`, `narrative_sound.gd` (M150)

**Registros de reserva (§26 — HECHOS 2026-10-03 00:14):** guía 08 fila M43 en
`## Reserva actual` · `CHECKLIST-GLOBAL.md` fila 43 (11 columnas **reconstruidas**,
EOL 231 CRLF / 231 LF / 449 CR intactos, `diff --numstat` = **1/1**) ·
`ESTADO-PARALELO.md` (entrada al tope) · `05-Checklist.md` (**firma + bloque
`## Reserva actual` insertado AL FINAL** para no desplazar las `L##` — lección de
M91 / commit `b894ffe`).

**Método:** lotes como en M91 → suite con el binario real
`C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script
res://scripts/audio/<suite>.gd`. Toda suite nueva va a
`.github/workflows/quality.yml` con `|| FAIL=1` **demostrada en ROJO** (mutar el
piso `CHECKS_MINIMOS` → EXIT 1). **Prohibido "verde por omisión"**: la suite tiene
que afirmar el camino de ÉXITO, no solo el de error (BUG-087/088).

**Pool:** cabeza **1214** verificada 2026-10-03 00:14 (287 disponibles; 1211/1212/
1213 ya tomados por otros). Reservar con §6.1.a en `Logs/NUMEROS_DISPONIBLES.txt`.

**No tocar (carrera de ≥5 agentes):** `scripts/configuracion/` y el `L88 [?]` HRTF
de M91 · `scripts/mapa` y `ui/widgets/minimap*` (M54/agnes) · `scripts/construccion/`
(DeepSeek M17) · `scripts/saving/` (M59) · `scripts/interacciones/` (M70/kimi) ·
`scripts/rendimiento/memoria/` (M62) · `scripts/legal/` y docs de 125/79 (agnes) ·
`CHECKLIST-GLOBAL.md` **solo en la fila 43**.

**Al terminar o liberar:** Estado 🔵 → ✅/🟡, Agente → —, Última actividad =
timestamp, `Dependencias` → `—` con nota. Nunca dejes 🔵 huérfano (§21.4.5).
**NO sellar §21.8** (autor ≠ verificador): lo deja el coordinador con un
verificador independiente.

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
