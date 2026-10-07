- [x] **M44-ASMR-Y-Feedback — cierre T-M4** CERRADO 2026-10-06 22:05: 76/0/37 → **108/5/0 = 113** (32 [x] con cita; 5 [?] dueño: AGENTE DELEGADO ×4 + M114); §8 nuevo en 03-Diseno; suite test_feedback_m44 9/0 exit 0 + sonda roja exit 1; Log 1396; mensaje 46; candidato ✅ pendiente QA §21.8
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
- [x] Log reservado y creado: **1221** — **M43 LIBERADO a 🟡 Con dudas (59/41/0)**: ciclo de 9 lotes (A auditoría 22 [x] + B1→B6 + C1 auditoría 13 [x]); suite 15 → **127/0 EXIT=0**; 8 commits + cierre; los 4 registros de §26 actualizados.
- [x] Log creado: **1260** — **M91 iter. 11: BUG-092 resuelto** (set_mute auto-guarda, mutes+opciones serializados, API `set_opcion()` con claves español, suite 103→136 + sonda rojo, BUG-092 cerrado en 11-BUGS §7; liberada 🟡 02:28)
- [x] **M91 iter. 10 CERRADA (Log 1250, aprobada por el director)** — reservada 2026-10-03 23:29 (reasignación del director, canal `04-2026-10-04_00-45-00-respuesta-ciclo.md`): diseño de controles **L198-L211** + **L147** + **L288**, revisión de **L110-L116/L240-L243** con la API de M43. QC fila 91 → 🔵 en **working tree** (commit CG pendiente por carrera con agnes-3-flash, fila 06 sin commitear). QA §21.8 de M91 **ya VERIFICADO por Hy3 (Log 1225)**.
- [x] **M91 iter. 11 CERRADA (BUG-092)** — 2026-10-04 02:28, Log 1260: fix en `audio_config_service.gd` + API `set_opcion()/get_opcion()/opcion_cambiada` (claves `rango_dinamico`/`compresion`/`dispositivo_salida`), suite 103→136 (piso medido + sonda rojo EXIT 1), regresiones 82/0 + 127/0, BUG-092 cerrado en `11-BUGS.md` §7. QA §21.8 pendiente (autor ≠ verificador).

## Módulo LIBERADO 🟡 — 43-Efectos-De-Sonido (Log 1221)

> **Asignado 2026-10-03 00:14 por el coordinador atria-Dawn-Preview** (encaje de
> dominio — **no** por columna `Recom`: tras liberar M91 no me quedaba ninguna
> fila propia). **Fase 6 (vertical slice) · Visión V0 · Dificultad 3 ·
> 0 dependencias reales** (la `Dependencias` de la fila era espuria: traía un
> `Recom`; corregida a `—`). Al cerrarlo quedan desbloqueados **M41, M42 y M44**.
> M150 se descartó (sus 4 pendientes son `[?]` con deps externas M22/M148/M41-M43).

**Fuente de verdad:** `DOCUMENTACION/43-Efectos-De-Sonido/plan-actual/05-Checklist.md`
(**59 [x] / 41 [ ] / 0 [?] = 100 ítems** — **LIBERADO 🟡 el 2026-10-03 01:36**). Es la fuente de verdad; esto es solo resumen.

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

**Lote B2 — catálogo y superficies de §3 (2026-10-03 00:55, hecho):** creado
`game/isla-ancestral/data/audio/sfx_catalog.json` con las **12 filas exactas de
`03-Diseno §3`** (6 paso + 5 romper + 1 colocar) + API `catalogo()` /
`catalogo_variaciones(efecto, material)` en `sfx_manager.gd`. `sfx_surfaces.json`
ampliado de 6 a **9 superficies**: nuevas hierba (5), nieve (4), arena (4) y
piedra corregida de 4 a **5**; se conservan agua/metal/cristal (4). Suite
+`_test_catalogo()` y expectativas por superficie: **35 → 59 checks, 0 fallos,
EXIT=0**. Cierra **8 del mapa §3 (E) + G103** (checklist 48 → 57 `[x]`).
**Hallazgo de honestidad:** `Pasos hierba: 5` estaba `[x]` en la auditoría del
Lote A **sin evidencia** (el archivo no tenía hierba) y no lo detecté — quedó
cubierto recién en B2 con datos reales y con la nota pública en el checklist.
`Colocar: misma familia` queda `[ ]`: el catálogo declara 4 variaciones pero
no enlaza colocar ↔ superficie (el requisito no está modelado).

**Lote B3 — categorías §2 y límites §5 (2026-10-03 01:15, hecho):**
`sfx_manager.gd` ahora tiene `CATEGORIAS` (ui/mundo/bloque/paso) con
`nivel_s2` (1 = alta … 4 = baja, la numeración del documento) **y**
`prioridad` interna invertida (10 … 1, porque el corte del pool gana con
el mayor), `MAX_MISMO_TIPO = 6`, `categoria_de(prioridad, categoria)`,
pool **preallocado** (`_voces.resize(24)`, cero `append`) y un solo
`RandomNumberGenerator` cacheado con semilla del reloj M29
(`GameTime.dia_absoluto/hora/minuto`) + `randi()`. Los límites se
evalúan ANTES del corte por prioridad. Suite +`_test_categorias()`:
**59 → 76 checks, 0 fallos, EXIT=0**. Cierra **6 de la sección D**
(checklist 57 → 63 `[x]`). Siguen `[ ]` en D: 3D/2D y distancias 15/20/30 m
(sin `AudioStreamPlayer`: bloqueado por 0 assets de audio, §7).

**Lote B4 — API pública de 04-Codigo §2 (2026-10-03 01:40, hecho):**
`sfx_manager.gd` gana la firma de §2 `reproducir(efecto, pos, prioridad,
categoria)` (el 2º argumento pasó a ser `pos`; `null` = 2D/UI y `Vector3`
se registra en la voz), `reproducir_localizado(tipo, material, pos)` (resuelve
variaciones: `paso` lee `surfaces`, `romper`/`colocar` generan por convención),
`configurar_volumen(bus, dB)` — **delegado en `AudioConfig`/M91**, sin tocar
`scripts/configuracion/` — y `pausar()/reanudar()` con purga de residuos
(F99: el `tiempo_ms` se desplaza por la pausa y la vencida se purga).
Suite +`_test_api()` (18 checks) y +2 de L115 (pool lleno no corta la UI):
**76 → 96 checks, 0 fallos, EXIT=0**. Cierra **5 items** (checklist 63 → 68
`[x]`, 37 → 32 `[ ]`): F98, G106, G107, G108, G115.
**F99 `Pausa con GameClock` queda `[ ]` con nota honesta:** la API existe y
está testeada, pero **nadie la enlaza con `GameTime.pausa()`** (M29).
**Incidencia de test (documentada):** la primera corrida dio 2 fallos porque
`_test_api()` heredaba el pool lleno de tests previos y el límite §5 de UI
(máx 2) descartaba legítimamente a `api_ui` — el código estaba bien; se hizo
el test determinista (pool vacío al entrar).

**Lote B5 — ducking de diálogo F92/F95 (2026-10-03 02:05, hecho):**
`ducking_dialogo(activar)` baja el bus SFX **exactamente 6 dB** sobre la
base que declare M91 (se recalcula en cada cambio, así que un slider
movido durante el diálogo no deja volumen obsoleto) y es idempotente.
El enlace con M21 se hizo **suscribiéndose en `_ready()` a
`DialogueManager.dialogue_started/dialogue_ended` — sin modificar un solo
archivo de `scripts/dialogos/`** (§15: M43 solo escucha). Suite
+`_test_ducking()` (10 checks): **96 → 106 checks, 0 fallos, EXIT=0**.
Cierra **F92 + F95** (checklist 68 → 71 `[x]`) y **F96** (el error 0.4 s
ya estaba testeado desde B1 y se me pasó cerrar: `tones["error"]` =
[7,4,0] descendente, 0.4 s, tono suave).
**Dos hallazgos documentados en F93/F94:** (1) F93 «Música -6 dB en
logros (M41)» es de M41 y `music_director.gd` **no expone señal de
logro**, solo `tema_cambio` — delegado; (2) F94 «Correr +3 dB» cita
`02-Analisis` como «activado por M34» **pero M34 es *Pesca*
(CHECKLIST-GLOBAL fila 34), no movimiento**: la dependencia está mal
referenciada y no hay señal de «corriendo» en el código. No se creó API
huérfana (§21.4 «no hacer por hacer»).

**Lote B6 — 7 suscripciones de §3 (2026-10-03 02:35, hecho):**
`_conectar_autoloads()` enlaza M43 con el resto del juego **sin tocar un
solo archivo ajeno**: `Achievements.logro_desbloqueado` → `logro`,
`Crafting.crafting_completed` → `crafting_exito`,
`Crafting.crafting_failed` → `error`, `ShopManager.compra_exitosa` →
`compra`, `ShopManager.venta_exitosa` → `venta` y
`compra_rechazada`/`venta_rechazada` → `error`. Las **firmas se leyeron
del código fuente** (ej. `compra_rechazada` tiene 3 args, no 4) y
`Motivo` (enum con class_name ajeno) se recibe como `Variant` para no
acoplar M43 (GUIA-GODOT §9.50). Conexión defensiva `_conectar_si()`:
`has_signal` antes de `connect`, así un renombrado ajeno no rompe el
arranque. Los 5 autoloads van declarados **antes** que `SFXManager`
(líneas 24-85 vs 100 de `project.godot`), así que en `_ready()` ya
existen. Suite +`_test_senales()` (21 checks: 14 de conexión + 7 de que
cada handler emite su SFX): **106 → 127 checks, 0 fallos, EXIT=0**.
Cierra **G114** (checklist 71 → 72 `[x]`, 29 → 28 `[ ]`).
**Corrección de honestidad:** la nota de F93 decía «no hay señal de
logro» — es **falso**: `Achievements.logro_desbloqueado` existe y ya la
escucha M43. Lo que falta es que **M41** se suscriba para bajar la
música; se corrigió la nota en el checklist.

**Lote C1 — auditoría de honestidad final (2026-10-03 01:30, hecho):**
encontré **13 `[x]` sin evidencia** en las secciones A, B y D que la
auditoría del Lote A se había pasado. Prueba documentada en cada línea:
1. los 3 JSON de M43 (`sfx_tones`/`sfx_catalog`/`sfx_surfaces`) **no
   definen** `saltar`, `caer`, `equipar`, `herramienta`, `seleccion`,
   `abrir`, `cerrar` ni `plantar`;
2. `rg` sobre **todo** `scripts/audio/*.gd` **no arroja ninguna
   referencia** a esas palabras;
3. `abrir_contenedor`/`plantar`/`cosechar`/`pescar_captura` viven en
   `feedback_recetas.json`, que es de **M44** —`feedback_director.gd`
   imprime `[M44]`—, aunque viva en `scripts/audio/`.
Bajados a `[ ]` con motivo: RF2, RF4, RF5, RF6+RF7, P3, P4, P7, P9, P10,
P13, P22, «coherencia M41/M42» y «sin fatiga auditiva». **72 → 59 `[x]`.**

**Cierre — Log 1221 (2026-10-03 01:36, hecho):** M43 queda **🟡 Con dudas
59/41/0**. Los 4 registros de §26 actualizados: `05-Checklist.md` (totales
59/41/0, EOL **177 CR / 177 LF / 178 líneas intacto**), `CHECKLIST-GLOBAL`
fila 43 → 🟡 59/100 (invariante **449 CR / 231 LF / 231 CRLF** verificado
antes y después; edición solo dentro de la línea), `ESTADO-PARALELO.md`
(entrada de cierre al tope, resto byte-idéntico) y `04-Codigo.md`
(`## Notas del Agente` propia **sin borrar** la de Deepseek V4 Flash, con
nota histórica que desmiente su «25/25 puntos resueltos»).
Log `Logs/1221-cierre-de-M43_lotes-A-a-C1_2026-10-03_01-36-15.md`
(**pool releída en disco**: 1221 consumido; la cabeza pasó a 1240 con
otros agentes tomando 1222-1239).
**⚠️ NO se tocó `.github/workflows/quality.yml`**: tiene un diff **ajeno
sin commitear** (DeepSeek M17, Log 1211) → editar habría arrastrado
cambios ajenos (Trampa 114) o pisado trabajo en curso (§17.4). El gate
de M43 queda **pendiente documentado** en el informe del canal.
**⚠️ Commit cruzado detectado:** la fila 43 de `CHECKLIST-GLOBAL.md` fue
sweep-commiteada por otro agente en `446bd1c` (commit de kimi sobre
M17/M37) — mi cambio estaba en el working tree y viajó con el suyo.
Los archivos de C2 (05-Checklist, 04-Codigo, ESTADO-PARALELO, Log 1221)
siguieron sin commitear hasta el commit de cierre de este lote.


**Código real (escrito por este chat en iteraciones previas):**
- `game/isla-ancestral/scripts/audio/sfx_manager.gd` (M43) + `test_sfx_m43.gd`
  (**suite de referencia: 127/0, ya descubierta por el runner**)
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
timestamp. **HECHO 2026-10-03 01:36 (Log 1221):** fila 43 → `🟡 Con dudas`,
`59/100`, Agente `—`, ÚltAct `2026-10-03 01:36`. **Siguiente paso de este
módulo: QA cruzado §21.8 por OTRO modelo** (no por este chat) — la señal de
aviso al director ya quedó escrita en
`Mensajes entre modelos/mimo-v2.6-flash-free/` (archivo `03-...`).

**Al terminar o liberar:** Estado 🔵 → ✅/🟡, Agente → —, Última actividad =
timestamp, `Dependencias` → `—` con nota. Nunca dejes 🔵 huérfano (§21.4.5).
**NO sellar §21.8** (autor ≠ verificador): lo deja el coordinador con un
verificador independiente.

## Módulo 🟡 — 91-Configuracion-De-Audio (iter. 11 CERRADA: BUG-092 resuelto, Log 1260)

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).**
> **LIBERADO 2026-10-02 21:55 a 🟡 Con dudas — Log 1210.** Los 4 registros de §26
> quedaron actualizados (CHECKLIST-GLOBAL fila 91, 05-Checklist bloque Reserva
> **al final del archivo** para no desplazar las referencias `L##`, ESTADO-PARALELO,
> guía 08). ~~Quedaba pendiente el QA cruzado §21.8~~ → **VERIFICADO por
> Hy3/WorkBuddy (Log 1225, 2026-10-03)**: `test_audio_config.gd` 103/0 +
> `test_audio_effects_m91.gd` 82/0, guardián rojo reproducido (EXIT 1 inyectado);
> L88 HRTF `[?]` confirmado genuinamente técnico. No re-llevar este módulo a ✅
> sin resolver L88 `[?]` (HRTF).
>
> **REASIGNADO 2026-10-03 23:17 (iter. 10, canal 04):** el director me lo devolvió
> como prioridad tras cerrar M43; M41/M42/M44 quedan encolados (mismos bloqueos de
> 0 assets de audio). Estado → 🔵 en curso.

> **ITER. 10 CERRADA 2026-10-04 00:03 → 🟡 (Log 1250).** Alcance reservado
> CORREGIDO: **L198-L211 + L147 son de M53** (dueño del menú; 03-Diseno §10
> + desglose lote 9) → no tocados (Trampa 119). Trabajo real ejecutado:
> (1) **03-Diseno §16-18 reescritos** con la arquitectura real (AudioConfig +
> DataStore → `user://config.cfg`; AudioSettings/Loader/Saver y
> `audio_settings.json` no existen — 0 refs en scripts/); (2) **L288 cerrado**
> (trigger de cierre diseñado en §18, API propuesta `set_opcion()`);
> (3) notas inline en L213/L275/L283/L290/L296 SIN insertar líneas (las
> referencias `L##` del archivo son números de línea); (4) **BUG-092** abierto
> (mutes + 3 settings sin persistencia en config.cfg); (5) suites re-meditidas
> **103/0 + 82/0** (EXIT 0); (6) progreso **207/239** (05-Checklist + CG fila 91
> + guía 08). Queda 🔵 sin trabajo propio: 31 `[ ]` con dueño externo/engine
> + L88 `[?]` HRTF. **No re-llevar a ✅ sin resolver L88.**

> **ITER. 11 CERRADA 2026-10-04 02:28 → 🟡 (Log 1260).** Encargo del director (canal 06): BUG-092 **resuelto** — `set_mute()` → `_guardar_config()` + `_mutes`/`_opciones` serializados como sub-diccionarios de `config["audio"]`; API `set_opcion(clave, valor) -> bool` con validación de clave/valor, aplicación al motor con confirmación de estado final y auto-guardado por setter (mismo camino que `set_volumen()`); claves en **español** (`rango_dinamico`/`compresion`/`dispositivo_salida` — los 3 managers siguen stateless, AudioConfig es el dueño único de la persistencia). Suite `test_audio_config.gd` 103 → **136/0 EXIT 0** (piso `CHECKS_MINIMOS=136`, sonda rojo EXIT 1 inyectada y removida) + regresiones 82/0 y 127/0. BUG-092 cerrado en `11-BUGS.md` §7. **NO se sella §21.8** (autor ≠ verificador) → M91 queda 🟡; L88 `[?]` HRTF sigue siendo el techo.

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


---

## Guia de comunicacion (Modo Canal) - 2026-10-03

**El detalle va a tu carpeta de mensajes; el chat solo avisa.**

Cuando termines (o abortes) un item, escribis el informe completo en `Mensajes entre modelos/mimo-v2.6-flash-free/` (archivo nuevo numerado, con firma y Responde a) y, por el chat, **una sola linea**:

> termine `[item]`, informe en mi carpeta

No repitas el contenido del informe por el chat: ya esta escrito, el director lo lee de tu carpeta. Si abortaste: `aborte [item]: [motivo de una linea]. informe en mi carpeta`. Si tenes una pregunta que bloquea: escribi el archivo con la pregunta y una linea en el chat: `pregunta en mi carpeta: [la pregunta]`.

Guia completa: `Mensajes entre modelos/GUIA-COMUNICACION.md` (lectura obligatoria).

## Módulo 🔵 ACTUAL — 53-UI-UX (sección Audio de settings, canal 10)

- [x] **M53-settings sección Audio (reclamado 2026-10-04 04:04, CERRADO 2026-10-04 05:45, log 1273)** — Opción A aprobada: construir la sección Audio de Ajustes + wire-up `set_opcion()` + deprecar volúmenes de `game_settings.gd` (dueño M07 ✅ sin agente activo). Fila 53 CG reconstruida y 🔵.
- [x] Crear controles de la sección Audio: sliders maestro/música/sfx → `AudioConfig.set_volumen()` [M]
- [x] Toggles `rango_dinamico` / `compresion` / `dispositivo_salida` → `set_opcion()` con feedback cuando devuelva `false` [M]
- [x] Controles de mutes si encajan en la sección [S]
- [x] Routing de `ajustes_pedido` (deep-link de pausa hoy colgado: emite sin listener) [M]
- [x] Test headless round-trip UI → `config["audio"]` que FALLE si se rompe la integración [M]
- [x] Deprecar `master_volume`/`music_volume`/`sfx_volume` en `game_settings.gd` (sin lectores; doc en M07 plan-actual) [S]
- [x] Docs M53: `03-Diseno`/`04-Codigo`/`05-Checklist` (7 ítems nuevos `[ ]` ya agregados) [S]
- [x] Cierre: suites + log + registros + commit Trampa 114 + informe 11 [S]
- [x] Log reservado y creado: **1273** — M53 sección Audio (Opción A canal 10): SettingsAudioLayer + routing ajustes_pedido + i18n + deprecación game_settings + docs; suites 51/0, 0, 0, 136/0; fila 53 liberada 139/165
- [x] Log reservado y creado: **1396** — M44-ASMR cierre T-M4 (108/113, 32 [x] + 5 [?], §8 nuevo en 03, suite 9/0 + sonda roja)

---

## Módulos 🔵 ACTUALES — T-M2 89-Diseno-De-Menus (canal 18) + T-M1 lote 2 55-Diario (canal 18)

- [x] **T-M0 — A2 M62 (CI rojo)** (canal 13, prioridad alta) — fix `A2|SubtitleManager->DataStore`: `DataStore` movido antes que `SubtitleManager` en `[autoload]` de `project.godot` (1 línea); rojo `exit=1` → verde `exit=0` + selftest `0 fallos`; Log **1285**; **CI CONFIRMADO 2026-10-04 21:5x** (encargo del director, canal archivo 16): **Architecture Guard (M62) = success** en run 37247252031 (`dbb0a67`); el Linter (12 SCRIPT ERROR) y `Run Test Suite (M112)` fallan por la MISMA causa ambiental — `voxel.gdextension` no carga en CI (tipos VoxelTerrain/Buffer/Tool sin resolver, gate BUG-091); `Godot Tests (GdUnit4)` = success
- [x] **T-M1 M55 Diario del Jugador — lote 1 (UI) CERRADO** (reclamado 2026-10-04 17:55, canal 12; retomado 19:51) — **Log 1295** + informe **17**: `diary_layer.gd` reescrito (capa MODAL_FULL 3 columnas, 14 pestañas, filtros, ★, % anti-spoiler clamp, i18n con `_aplicar_textos_estaticos`), `get_categorias()`+`buscar(_slug)` en el servicio, wiring `diario`/`favorito`+fix `close_top` en ui_manager, acción `diario` (J), 36 claves DIARY (es/en), **test_diario_ui 89/0 con sonda rojo**, regresión 4/4 (diario/i18n/framework/settings 51/0); docs 03§5/04§1.1+Notas/05 (33/1/97)+06+07; checklist M55 → 🟡 liberado. **CG fila 55**: el reclamo 🔵 ya estaba en HEAD (sweep de Hy3 en `ad6b370`); cierro mi fila a 🟡 33/131 con invariante M-06 en este commit
- [x] **T-M2 M89 Diseno-De-Menus CERRADO** (24→**30/125**) — **Log reservado: 1321** (la cabeza real era 1321, no 1296: 1296-1320 ya estaban consumidos); reclamo 2026-10-05 02:50 (fila reconstruida 13→11, M-06 OK); **auditoría contra disco** completa (plan-actual Unity vs repo Godot) + **suite `test_m89_menus.gd`** (48 checks, verde `exit=0` + sonda rojo 1 fallo `exit=1` + regresión M53 0 fallos / M55 89/0); flips **8 `[→]→[x]` + 2 `[x]→[?]`** (Navigator-21 y perfiles INFLADOS) → 30/93/2; docs 03§8, 04§6, 05 auditoría, 06, 07; CG fila 89 → 🟡; informe **20**
- [x] **T-M1 M55 — lote 2 (canal 18, 2026-10-05 01:40; ordenar después de T-M2):** 1) `validate_diary.gd` (integridad de entradas, suite headless); 2) descripciones/referencias en el detalle (el catálogo solo trae `{id, titulo}`); 3) persistencia de ★ y filtros entre sesiones reales; 4) investigar `fotografías` con 0 entradas (¿bug de datos o frente sin contenido?). Sin tocar `ui_manager.gd` salvo imprescindible (M53 = s2, avisar). — **CERRADO 2026-10-05**: validate_diary (verde + sonda roja), detalle desc/refs (8+3 con fuente), persistencia 2 procesos 0 fallos, diagnóstico fotos=M56 sin contenido; 37/131; **Log 1345 creado** (Logs/1345-T-M1-LOTE-2-M55-DIARIO-VALIDADOR-DETALLE-PERSISTENCIA_2026-10-05_21-16.md)
- [x] **M88 Fuentes-Tipograficas** ✅ 16/185 - ITERACIÓN 3 CERRADA 2026-10-06: sello re-corrado (11/0), test nuevo 43/0, sonda roja BSD exit 1, BUG-042 22/0, M87+M58 verificados; [?] M90 no implementado. Pendiente: QA §21.8 por modelo distinto + 166 [?] de diseóo restantes — Log creado: **1504**
- [x] **M88 Fuentes-Tipograficas — iter. de cierre hacia ✅** ✅ 174/185 CERRADO 2026-10-06 16:52 (mensaje 35): 158 [x] con sustento, 8 [?] con dueño (M154/disenador/M88), 3 suites exit 0 + sonda roja validada, 06-Plan-Testings creado; candidato a ✅ pendiente QA 21.8 · Log creado: **1376** — M88 cierre 166 [ ] -> 174/185/11. NO tocar theme M53, sin quality.yml, sin push
- [x] **M89 Diseno-De-Menus — cierre T-M3** ✅ 124/125 CERRADO 2026-10-06 19:36: 93 [x] con sustento (01/03/04 + §9 nuevo), 2 [?] inflados resueltos (04 §4), M154 [x]→[?]; suites 48/0 + 51/0 + sonda roja exit 1 · Log creado: **1392** — Logs/1392-M89-cierre-2026-10-06_19-45-00.md — M89 cierre 93 [ ] -> 124/125/1
- [x] **Hallazgos guía 01 (M88, aprobados en msg 38/42)** ✅ 2026-10-06 20:05: §32 trampa sonda de licencia (reemplazo global muta whitelist → falso verde) + §33 workaround `git checkout` unable-to-unlink vía `git show HEAD:` — Log creado: **1394** — Logs/1394-hallazgos-guia01-sonda-licencia-git-checkout_2026-10-06_20-05-00.md
- [x] **M151 Control-Final** ✅ 23/167 — iter 4 (alcance B) VERIFICADA 2026-10-06 - RECLAMADO 2026-10-06 (mensaje 29): alcance B - re-correr verificar_puntos.py + 11 tests de SB, medir 7 gates de verdad, NO gates nuevos. Restricciones SB: sin quality.yml (s2), sin interaction_manager, sin service_registry, sin M154, sin push
- [x] **M153 Objetivo-Final** ✅ 120/130 — CERRADO 2026-10-06 15:38 (mensaje 32): guardián en verde, anti-sobre-cierre OK, deuda real, **candidato a ✅** (pendiente QA §21.8 del director). Log reservado: **1372**

**Restricciones vigentes (canal 12):** no `quality.yml` · no M91 · no `interaction_manager` (BUG-096, kimi M70) · no `service_registry.gd` (BUG-097, agnes) · sin arquitectura visual/3D (§21.14)
- [x] Log creado: **1360** — M151 iter 4 verificacion alcance B (2026-10-06)
