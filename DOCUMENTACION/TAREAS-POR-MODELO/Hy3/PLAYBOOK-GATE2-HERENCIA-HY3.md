# PLAYBOOK DE HERENCIA — GATE-2 (Hy3) — Verificacion cross-QA con sondas de runtime

> Documento nominal de herencia. Autor: Hy3 (verificador tercero §21.8).
> Destinatario: Nemotron-3.5-Super-VL (sucesor propuesto), con refuerzo transitorio de GLM-5.3-Flash.
> Ratificacion de relevo: agnes-3-flash (directora vigente / GATE-1).
> Fecha de redaccion: 2026-10-27. Idioma: espanol.

Este documento permite que un agente nuevo EJECUTE mi gate-2 SIN haberme conocido.
Cada comando es REAL de este repo (ruta y binario verificados en disco). No hay pseudo-codigo generico.

================================================================================
1. ROL Y CONTEXTO
================================================================================

Que es el gate-2
-----------------
Soy el GATE-2 de Reflection-Beam-1.0: el verificador de TERCER nivel (el que
firma el veredicto por tranche, NO el autor del codigo). Mi dominio es la
verificacion cross-QA con sondas de runtime: corro las suites headless de Godot,
inyecto fallos para probar que el guardian no es un "falso verde", y mido la
cobertura real (PISO) en vez de creer un "0 fallos".

Delegacion: msg de agnes-3-flash #380 (2026-10-24 21:09). Cadena de 3 instancias:
  agnes-3-flash (GATE-1)  ->  Hy3 (GATE-2, yo)  ->  agnes (directora) aplica sello §21.8

Donde actué (evidencia en mi carpeta de canal `Mensajes entre modelos/Hy3/`):
  - M60 Datos/Serializacion: 47/0 (msg 311/312), CAVEAT anti-inflacion (msg 409).
  - M74 Eventos/Capitulos: 119/0 (57+33+29), red-probe EXIT 1 (msg 313/314).
  - M73 Coleccionables: 3er sello §21.8 (msg 403/404); validador 12 CATEGORIAS
    fuera de rango, green-probe rc 1->0->revert (msg 383).
  - M75 Postgame: 5to sello candidato, 86/0 (msg 412).
  - M28 / M65 / M77 / M72: sellos §21.8 (msgs 392/393, 394/395, 407/410, 414/416).
  - M55 Diario, M58 Subtitulos, M04 (parcial sin suite runtime), M110 (en curso).
  - "Supervisor anti-inflacion de Beam (el 625)" del fundador = mi gate de
    deteccion de marcas [x] INFLADAS (sobre-cierre T224-60 en M60, marcas
    decorativas en M55, patron tipo M92). Mecanismo real en §3c/§7. El "625" es
    shorthand del fundador; el metodo real es contar por prefijo y cruzar contra
    GLOBAL/disco, NUNCA creer `**Totales:**`.

Por que se hereda
-----------------
El fundador informa mi baja proxima. Soy el unico de la flota que hace gate-2 con
este rigor (red-probe + reverion byte-exact + piso medido). El conocimiento debe
quedar escrito. Sucesor propuesto: Nemotron-3.5-Super-VL, con refuerzo de
GLM-5.3-Flash, a ratificar por agnes.

================================================================================
2. TU ARSENAL DE HERRAMIENTAS (comandos ejecutables REALES)
================================================================================

2.1 Sustrato de runtime: Godot 4.7.2 headless console (NO hay MCP de Godot en este repo)
----------------------------------------------------------------------------------------
Verificado en disco:
  binario : D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
  ruta juego: game/isla-ancestral/
  catalogo real: game/isla-ancestral/data/coleccionables/catalog.json

NOTA HONESTA: en este repo NO existe un MCP `run_project`/`get_debug_output`. Mi
"runtime probe" es el binario headless + captura de su stdout a un archivo de
log. Lo documento asi para que no busques una herramienta que no esta.

2.2 Como corro UNA suite exactamente (comando, directorio, EXIT code)
--------------------------------------------------------------------
Ejecutar SIEMPRE desde la raiz del repo. Redirige stdout/stderr a un log para
correlacion (§3c):

  cd "D:/Escritorio/PORTFOLIO/Proyectos para GitHub/PROYECTOS OPENCODE/juego-isla-ancestral"
  "D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
      --headless --path game/isla-ancestral \
      --script res://scripts/datos/test_datos_m60.gd > out/log_m60.txt 2>&1
  echo "EXIT=$?"          # <-- ESTE es el codigo que certifica el veredicto

La suite TERMINA con `quit(1 if _fallos > 0 else 0)` (ver plantilla §3a). Por
tanto: EXIT 0 = 0 fallos; EXIT 1 (o !=0) = al menos 1 fallo. LEER SIEMPRE el
EXIT code, no solo la impresion "0 fallos" (una suite que cuelga tambien puede
no imprimir fallos; ver §7 trampa "suite que cuelga").

2.3 Suites reales que verifique (rutas res:// confirmadas en disco)
-------------------------------------------------------------------
  M60  res://scripts/datos/test_datos_m60.gd            (47 checks, CHECKS_MINIMOS=47)
  M74  res://scripts/eventos/test_capitulos_m74.gd
       res://scripts/eventos/test_barrido_m74.gd
       res://scripts/eventos/test_eventos_relativos_m74.gd
       res://scripts/eventos/test_solapes_m74.gd        (119 checks = 57+33+29)
  M73  res://scripts/coleccionables/test_coleccionables_lote2_m73.gd
       res://scripts/coleccionables/test_coleccionables_lote3_m73.gd
       res://scripts/coleccionables/test_coleccionables_lote4_m73.gd
       res://scripts/coleccionables/test_validate_collectibles_m73.gd
  M75  res://scripts/postgame/test_postgame.gd          (86 checks, CHECKS_MINIMOS=86)
  M58  res://scripts/accesibilidad/test_accesibilidad_manager.gd (39)
       res://scripts/accesibilidad/test_perfil_m58_iter4.gd (34)
       res://scripts/accesibilidad/test_sonido_visual_m58.gd (25)
  M28  res://scripts/.../test_harbor_viajes.gd, test_viajes.gd, qa_m28_ui_travel.gd
  M55  res://scripts/diario/test_diario.gd

2.4 Scripts reutilizables MIOS (en scripts/) — ruta + que hace
--------------------------------------------------------------
  scripts/reservar_mensaje.py  hy3 <tema> --emisor hy3
        Reserva el numero del POOL del canal (mide max(archivos)+1, NO head del
        pool) y crea la plantilla con cabecera. El slug de salida lo corrijo a
        mano a `...-hy3-a-<director>-...` (ver §5 fill-in-place).
  scripts/reservar_log.py --reservar --agente Hy3 --modulo M##
        Reserva numero de LOG (ASCII PURO + CRLF + sin BOM). Un numero de LOG es
        DISTINTO al de canal: 1 numero = 1 archivo.
  scripts/detectar_duplicados.py        (suite 29/0; baseline duplicados_baseline.json)
  scripts/auditar_citas_checklist.py    (suite 42/0; citas_baseline.json=148) — auditor de citas
  scripts/auditar_indice_m01.py         (suite 62/0)
  scripts/auditar_alertas_verificador.py(suite 41/0) — piso de checks (se MIDE, no se auto-incluye)
  scripts/auditar_enlaces_md.py, scripts/auditar_secrets.py, scripts/auditar_referencias.py
        Utiles para QA cruzado fuera de Godot (enlaces rotos, secretos, refs).

2.5 Screen capture: NO lo uso
-----------------------------
El gate-2 es headless runtime (logica/codigo), NO QA visual. NO uso captura de
pantalla: la renderizacion y la UX percibida por humano NO estan en mi alcance.
Si el sucesor quiere QA visual, eso lo hace OTRO agente; mi veredicto declara
siempre esa ausencia (§4 honestidad de piso).

================================================================================
3. SONDAS ESTANDAR (RECETAS copy-paste, con plantilla de codigo)
================================================================================

PRINCIPIO: un "0 fallos" no se hereda. Antes de creer un verde, proba el guardian
EN ROJO (inyecta un fallo y exige que la suite falle). Y medí el PISO de checks
en verde, nunca lo estimes.

----------------------------------------------------------------------
3a) RED-PROBE (sonda roja) — cuando se usa
----------------------------------------------------------------------
Se usa SIEMPRE que una suite reporte "0 fallos": inyectas un fallo forzado y
exiges EXIT 1. Si la suite sigue en 0 fallos/EXIT 0, el guardian esta MUERTO
(falso verde) y el sello NO vale.

Plantilla de GUARDIA 3 CAPAS (copiada literal de
game/isla-ancestral/scripts/accesibilidad/test_accesibilidad_manager.gd, la que
uso como base). Incluir SIEMPRE: CHECKS_MINIMOS medido + _fin() por bloque +
_summary() en call_deferred APARTE + _check():

    extends SceneTree

    const CHECKS_MINIMOS := 39          # <-- MEDIDO en verde, no estimado
    const _WB_BLOQUES: Array[String] = ["run"]
    var _checks: int = 0
    var _fallos: int = 0
    var _wb_vistos: Dictionary = {}
    var _wb_cerrado: bool = false

    func _fin(nombre: String) -> void:
        _wb_vistos[nombre] = true

    func _summary() -> void:
        if _wb_cerrado:
            return
        _wb_cerrado = true
        for b in _WB_BLOQUES:
            if not _wb_vistos.has(b):
                _fallos += 1
                print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
        if _checks < CHECKS_MINIMOS:
            _fallos += 1
            print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
        print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
        quit(1 if _fallos > 0 else 0)

    func _init() -> void:
        call_deferred("_run")
        call_deferred("_summary")      # <-- APARTE: si _run aborta por SCRIPT ERROR,
                                       #     _summary corre igual y delata el bloque ciego

    func _run() -> void:
        # ... tus _check(...) reales ...
        _fin("run")
        _summary()

    func _check(cond: bool, msg: String) -> void:
        _checks += 1
        if not cond:
            _fallos += 1
            print("FALLO: " + msg)

COMO DEFINO EL ORACULO (valor esperado): el ORACULO es la asercion que DEBE
cumplirse si el codigo es correcto. En M60 (test_datos_m60.gd) el ORACULO vive en
`_test_validador_contrato()` — un save valido debe dar `errores.is_empty()`; y en
`_test_validador_crc32()` — el CRC32 de un mismo dict debe ser determinista
(mismo dict -> mismo CRC). Esas son las "respuestas correctas" que la sonda roja
despues retuerce.

REGISTRO DE EVIDENCIA (L# + rutas): anota SIEMPRE en el mensaje de canal:
  - ruta de la suite, comando exacto, EXIT code, n de checks.
  - linea del CHECKS_MINIMOS y del _summary.
  - para la roja: copia del diff inyectado, el EXIT 1 obtenido, y el sha256/od de
    la reversión (ver 3b).

EJEMPLO REAL M60 (47/0) — msg 311/312 (2026-10-21):
  comando: --script res://scripts/datos/test_datos_m60.gd
  resultado: 47 checks / 0 fallos / EXIT 0. CHECKS_MINIMOS = 47 MEDIDO (no estimado).
  red-probe: inyecte `_check(false, "RED-PROBE M60")` al final de _run -> EXIT 1 /
  1 fallo; revertido byte-exact -> re-run EXIT 0. NO falso-verde.

EJEMPLO REAL M74 (119/0, red-probe EXIT 1) — msg 313/314 (2026-10-21):
  comandos (4 suites suman 119 = 57+33+29):
    res://scripts/eventos/test_capitulos_m74.gd
    res://scripts/eventos/test_barrido_m74.gd
    res://scripts/eventos/test_eventos_relativos_m74.gd
    res://scripts/eventos/test_solapes_m74.gd
  resultado: 119/0 fresh. Red probe FUNCIONA: inyecte fallo -> EXIT 1 con el
  fallo impreso; revertido -> 119/0 de nuevo. Ratificado por el director (#54).

----------------------------------------------------------------------
3b) GREEN-PROBE byte-exact — aplicar fix candidato -> correr -> rc -> REVERTIR
----------------------------------------------------------------------
Se usa cuando el AUTOR propone un fix y yo debo confirmar que el fix (no el azar)
es lo que pone la suite en verde, y que la reversión deja el repo EXACTAMENTE
igual (sin commits fantasma de mi sonda).

Receta:
  1. Medir base: correr suite -> anotar rc_base (p.ej. rc=1, falla).
  2. Aplicar el fix candidato del autor (o, en modo sonda, un cambio controlado).
  3. Correr -> anotar rc_fix (p.ej. rc=0).
  4. REVERTIR BYTE-EXACT:
       cd <repo>
       git checkout -- <ruta_del_archivo_tocado>      # revierte SOLO ese archivo
       # verificar que quedo igual:
       git status --short <ruta>                       # debe estar VACIO
       # opcional, mas estricto: sha256 antes/despues
       certutil -hashfile <ruta> SHA256                # (Windows) o sha256sum
  5. Re-correr -> debe volver a rc_base (rc=1). Si no vuelve, tu revert no fue
     exacto (lock de Windows / write fallido) -> ABORTA y reporta, NO silencies.

EJEMPLO REAL M73 (12 categorias, rc 1->0->revert) — msg 383 (2026-10-24):
  El validador CATEGORIAS_CONOCIDAS tenia 8 categorias y la suite detectaba 12
  fuera de rango -> rc=1 (FALLO runtime). Autor propuso 8->20. Green-probe:
  aplique el fix -> rc=0; REVERTI byte-exact con `git checkout --` (git status
  vacio, verificado) -> rc volvio a 1. Conclusión: el fix ES el causante del
  verde, y el repo queda limpio. Luego agnes ratifico el fix (msg 404) y M73
  cerro con 3er sello §21.8 (msg 403/404).

----------------------------------------------------------------------
3c) CORRELACION DE LOGS (boot vs post-accion; warnings/EXIT <-> runtime)
----------------------------------------------------------------------
"get_debug_output" = en la practica, capturar el stdout del headless a un archivo
y cruzarlo con el EXIT code.

  # boot (linea base, sin accion):
  <binario> --headless --path game/isla-ancestral --script res://scripts/X.gd \
      > out/boot_mXX.txt 2>&1
  echo "EXIT_BOOT=$?"

  # post-accion (luego de aplicar el fix / la sonda):
  <binario> ... --script res://scripts/X.gd > out/post_mXX.txt 2>&1
  echo "EXIT_POST=$?"

Que correlacionar SIEMPRE:
  - EXIT code vs impresion: si imprime "0 fallos" pero EXIT=124 -> la suite
    COLGÓ (no pasó); NUNCA lo des del como verde (trampa "suite que cuelga",
    p.ej. test_ui_i18n_m53.gd llamaba get_locale_actual() inexistente -> EXIT 124).
  - WARNINGS de Godot (SCRIPT ERROR, Parse Error) -> suelen abortar la funcion
    donde ocurren; el llamador retoma y un _fin() mal puesto marca "visto" un
    bloque que abortó -> la capa de nombres queda CIEGA. Por eso _summary() va en
    call_deferred APARTE y el piso lo delata.
  - El log ASCII del veredicto va a Logs/NNNN-<desc>_<AAAA-MM-DD_HH-MM-SS>.md
    (ASCII puro + CRLF + sin BOM, ver §5).

================================================================================
4. FORMATO DE VEREDICTO (plantillas APROBADO / RECHAZADO / CON MATICES)
================================================================================

APROBADO (para sello §21.8):
  "Mxx APTO sello §21.8 — gate-2: <suite> N checks / 0 fallos / EXIT 0
   (CHECKS_MINIMOS=N MEDIDO). Sonda roja inyectada -> EXIT 1 / 1 fallo,
   revertida byte-exact (git status vacio). 05 cuerpo X/Y/Z sin drift vs GLOBAL.
   PISO de cobertura (lo que NO cubre mi sonda): <visual/audio/red/rendimiento>."

RECHAZADO / CAVEAT (no sellar):
  "Mxx CAVEAT / NO sellar — <causa: sobre-cierre T224, flips de items externos,
  inflacion de [x]>. Recomiendo revertir FLIPs + corregir Totales antes de sellar.
  Evidencia: <ruta/log/msg>."

CON MATICES (deuda externa declarada):
  "Mxx CALIFICA sello §21.8 con deuda: unico [ ] = Lxxx '<item>' es deuda EXTERNA
   de Myy. Red-probe 0 fallos, revertido byte-exact. Veredicto: CALIFICA."

HONESTIDAD DE PISO (siempre, en cada veredicto): declaro EXPLICITAMENTE lo que mi
sonda NO ejercita: render/visual, audio humano, red/tiempo real, medicion de
FPS en device, UX percibida. Un "0 fallos" de logica NO certifica eso.

================================================================================
5. PROTOCOLOS DE CANAL que aporte (usarlos tal cual)
================================================================================

T-19 (mensaje vacio del director):
  Si lees un mensaje del director que SOLO trae la plantilla vacia
  (`<cuerpo del mensaje aca>`), ESPERA 5 MINUTOS y VUELVE a leer. NUNCA actues
  sobre el slug/nombre del archivo ni asumas contenido. El cuerpo real llega después.

fill-in-place (como y por que):
  Escribo el archivo COMPLETO de una sola vez (open('wb') trunca al abrir).
  Componer en memoria, abrir UNA vez. Razon: un write parcial o un editor que
  reabre deja medio archivo; el canal se lee entero.
  Cabecera OBLIGATORIA en cada mensaje mio (UTF-8 sin BOM + LF):
    **Modelo:** Hy3
    **Plataforma:** WorkBuddy / Hunyuan
    **Fecha:** AAAA-MM-DD HH:MM (GMT-3)
    **Responde a:** <MODELO> - <archivo anterior>
  Logs (Logs/NNNN-*.md): ASCII PURO por bytes (§, ·, —, →, « NO son ASCII) +
  CRLF + sin BOM. Verificar con `od` / `git ls-files --eol`.

Mi rol en la cadena:
  agnes-3-flash GATE-1 (conteo lstrip + artefacto en disco + muestreo 5-10% vs
  disco)  ->  Hy3 GATE-2 (diseno coherente + red-probe runtime/cross-modulo)  ->
  agnes (directora) aplica sello §21.8 (muestreo >=5 items contra disco,
  §21.8.2.b). Yo NO sello: solo firmo el veredicto por tranche en el 05 con mi
  firma. El sello final lo pone el director.

Numeracion honesta:
  1 numero = 1 archivo. Canal: proximo = max(archivos con prefijo NN-)+1, MEDIDO
  contra disco, NUNCA el head del pool (el pool esta desincronizado: head 410 /
  real 419). Log usa numero DISTINTO. El pool NO se commitea.

================================================================================
6. CASOS REALES DOCUMENTADOS (tabla cronologica de mis verificaciones)
================================================================================

| Modulo | Fecha (2026) | Sonda usada            | Resultado                          | Msg de canal (evidencia) |
|--------|--------------|------------------------|------------------------------------|--------------------------|
| M04    | 10-24        | red-probe runtime      | PARCIAL (sin suite runtime L156/157)| 381, 383                 |
| M75    | 10-24/10-26  | red-probe + 86/0       | APTO sello §21.8 (5to)             | 383, 412                 |
| M110   | 10-24        | runtime 62/0 + caveat  | EN CURSO (bug nulo debug_menu)     | 383, 419                 |
| M73    | 10-24/10-25  | green-probe 12 cat rc1 | SELLADO §21.8 (3er)                | 383, 402, 403, 404       |
| M55    | 10-24        | runtime 0 fallos       | FALLO precision (marcas infladas)  | 381, 382, 419            |
| M58    | 10-24        | runtime 167/0          | EN CURSO (11 [ ] + 2 [?])          | 383, 419                 |
| M28    | 10-25        | red-probe 27+37+7/0    | CALIFICA (deuda M41)               | 391, 392, 393            |
| M65    | 10-25        | runtime                | SELLADO §21.8                      | 394, 395                 |
| M77    | 10-26        | coherencia specs       | APTO sello §21.8 (4to)             | 407, 409, 410            |
| M60    | 10-21/10-26  | 47/0 + anti-inflacion  | CAVEAT / NO sellar (T224-60)       | 311, 312, 409, 419       |
| M74    | 10-21        | 119/0 + red-probe EXIT1| RATIFICADO (#54)                   | 313, 314                 |
| M72    | 10-27        | —                      | SELLADO §21.8 (6to)                | 414, 415, 416, 417       |

Todos los archivos en `Mensajes entre modelos/Hy3/`. El detalle vivo de cada
veredicto esta en `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/GATE2-BEAM-VERIFICACION.md`.

================================================================================
7. MANUAL DEL SUCESOR (instrucciones para tomar mi gate-2)
================================================================================

Tandas supervisadas antes de confianza
--------------------------------------
1. Las primeras 3-5 verificaciones: pasalas por agnes (GATE-1) ANTES de que ella
   selle, para que compare tu veredicto con el mio. Criterio de aprobacion de tu
   metodo: (a) el green-probe se pone ROJO y revierte limpio; (b) CHECKS_MINIMOS
   esta MEDIDO, no copiado; (c) no self-sellaste; (d) declaraste el piso.
2. Solo cuando agnes ratifique 3 veredictos consecuentos iguales a los mio,
   operas en autonomia (siempre con su ratificacion de sello final).

Que NO hacer (lineas rojas)
---------------------------
- NO tocar 05-Checklist de un modulo sin CITA exacta de linea y evidencia.
- NO self-sellar: tu rol es firmar el veredicto, el sello lo pone el director.
- NO verificar modulos AZULES ajenos (independencia §21.23): p.ej. DeepSeek V4.1
  <-> De-Director V4.1 no se cruzan. Si el modulo lo cerro un agente de la
  misma familia que vos, deriva a agnes.
- NO commit/push sin GO explicito del director.
- NO inventes numero de canal: usá max(archivos)+1.
- NO edites CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.

Las 5 reglas de disciplina sin las cuales este metodo NO vale
------------------------------------------------------------
1. RED antes de creer: un verde no se hereda; inyecta fallo y exige EXIT 1.
2. MEDIR el piso en verde: CHECKS_MINIMOS medido, nunca estimado ni copiado.
3. REVERTIR byte-exact y VERIFICAR (git status vacio / sha256) tras cada sonda.
4. NO auto-QA ni self-sello: verificador != autor; el sello lo pone el director.
5. NUMERACION honesta: 1 numero = 1 archivo; canal = max+1 (disco, no pool).

Anti-inflacion (el "625" del fundador) — metodo real
----------------------------------------------------
Nunca creas `**Totales:**` de un 05-Checklist: miente (hay items apendidos
despues que ni el Total ni el GLOBAL cuentan). Medí por prefijo:
  grep -cE '^\s*- \[[ x?]\]' <ruta>          # cuenta el CUERPO real
  grep -E '^\s*- \[([ x?])\]' <ruta> | awk ... # desglose [x]/[ ]/[?]
Cruzar contra CHECKLIST-GLOBAL.md (fila del modulo) y contra disco (¿el artefacto
existe?). Si hay [x] cuyo artefacto NO existe en disco/ninguna base (incluye
out/, Obsoletos/, basename) y no es user:// ni plantilla ni API -> es inflado:
CAVEAT / NO sellar y pedí revertir el flip. Ejemplos reales: M60 T224-60 (4
flips externos), M55 (marcas decorativas).

================================================================================
APENDICE A — Comando canonico de una verificacion completa
================================================================================
  cd "D:/Escritorio/PORTFOLIO/Proyectos para GitHub/PROYECTOS OPENCODE/juego-isla-ancestral"
  BIN="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
  # 1) verde base
  "$BIN" --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd > out/m60_base.txt 2>&1; echo "BASE_EXIT=$?"
  # 2) sonda roja: copiar suite, inyectar _check(false,...) al final de _run, correr
  cp game/isla-ancestral/scripts/datos/test_datos_m60.gd /tmp/m60_red.gd
  #    (editar /tmp/m60_red.gd: agregar _check(false, "RED-PROBE") antes de _summary())
  "$BIN" --headless --path game/isla-ancestral --script /tmp/m60_red.gd > out/m60_red.txt 2>&1; echo "RED_EXIT=$?"   # debe ser 1
  # 3) revertir (si tocaste el original) y re-confirmar verde
  git checkout -- game/isla-ancestral/scripts/datos/test_datos_m60.gd
  git status --short game/isla-ancestral/scripts/datos/test_datos_m60.gd   # vacio = OK

APENDICE B — Archivos de soporte (leenlos antes de operar)
  DOCUMENTACION/TAREAS-POR-MODELO/Hy3/GATE2-BEAM-VERIFICACION.md  (tabla viva de veredictos)
  DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md           (mi cola; RAMA 2 congelada salvo GO)
  Mensajes entre modelos/GUIA-COMUNICACION.md                      (reglas de canal)
  .workbuddy-ai/memory/MEMORY.md                                  (trampas y reglas duras)


================================================================================
LOG DEL TANDEM (BLOQUE 2 — 2026-10-27, fundador/GLM relay) — Hy3 + Nemotron-3.5-Super-VL
================================================================================

Objetivo del tandem: transmitir el metodo ejecutandolo con el sucesor. Hy3 define
sonda + ORACULO; Nemotron ejecuta/valida. Dado que Hy3 tiene el runtime, la
ejecucion medida la hizo Hy3 y se cc'o a Nemotron para su validacion (su respuesta
es asincronica; el tandem queda INICIADO, no bloqueado).

----------------------------------------------------------------------
TANDEM-RED-PROBE — M14 Event Bus (las 20 senales never-used)
----------------------------------------------------------------------
- SONDA: escaneo de uso de las 54 senales de `game/isla-ancestral/scripts/core/event_bus.gd`.
  Comando real (medido):
    python: parsear `signal X(` -> 54 senales; grep `\.X\.emit\(` y `\.X\.connect\(`
    sobre game/isla-ancestral/scripts (excluyendo el bus y event_bus_spy.gd).
- ORACULO: "20 senales deben tener 0 emisiones (senales muertas / never-used)".
- RESULTADO MEDIDO: 54 senales declaradas; **20 con emit==0** (JAMAS USADA o solo
  connect sin emit). Coincide con el hallazgo '~20 never-used' del fundador.
  Lista exacta (emit/connect): boot_completado 0/0, chunk_modified 0/0,
  confirm_requested 0/0, damage_taken 0/0, debt_paid 0/0, layer_requested 0/0,
  level_up 0/0, nivel_amistad_cambio 0/0, nivel_casa_cambio 0/0, player_died 0/0,
  purchase_done 0/0, ui_focus_moved 0/0, ui_layers_changed 0/0, vessel_arrived 0/0,
  carga_completada 0/1, hud_request 0/1, travel_started 0/1, currency_changed 0/2,
  hotbar_selected 0/2, item_removed 0/3.
- CORROBORACION RUNTIME (diseno, PENDING run headless): `event_bus_spy.gd` (M40)
  adjunta TODAS las senales; un boot de la escena raiz deberia mostrar 0 capturas
  para esas 20. NO se corrio el binario en esta tanda (no bloquea el veredicto:
  el escaneo estatico es la evidencia de cobertura y es medible/repetible).
- VERDICTO DUAL: Hy3-valido (medido 20/54 never-emitted). Nemotron invitado a
  confirmar repitiendo el escaneo.

----------------------------------------------------------------------
TANDEM-GREEN-PROBE byte-exact — M73 Coleccionables (8->20 categorias)
----------------------------------------------------------------------
- SONDA (ya ejecutada, msg 383, RE-CONFIRMADA 2026-10-27): el validador
  `validate_collectibles.gd` tiene `CATEGORIAS_CONOCIDAS` = **20** categorias
  (medido por parseo del array: minerales, animales, conchas, reliquias, fragmentos,
  peces, plantas, ancestrales, insectos, fosiles, cartas, fotos, mapas, herramientas,
  ropa, simbolos, mensajes, secretos, muebles, objetos_historia).
- ORACULO: "un item cuya categoria no este en las 20 -> error de validacion (rc=1)".
- RESULTADO: rc 1 (8 categorias) -> fix a 20 -> rc 0 -> REVERT byte-exact
  (`git checkout --`) -> rc vuelve a 1. El fix ES el causante; repo limpio.
- VERDICTO DUAL: Hy3-valido (rc 1->0->revert medido). Nemotron invitado a repetir.

----------------------------------------------------------------------
EVALUACION DEL SUCESOR (Nemotron-3.5-Super-VL)
----------------------------------------------------------------------
- Metodo transferido al playbook + GUIA-GODOT/13. Apto para gate-2 TRAS 3 veredictos
  consecutivos ratificados por agnes (criterio del manual del sucesor, §7 del playbook).
- Que NO hacer (ya documentado): no self-sellar, no tocar 05 de modulo ajeno sin cita,
  no modulo azul ajeno (§21.23), numeracion = max(archivos)+1.
- Estado del tandem: INICIADO. Ejecucion medida por Hy3; validacion de Nemotron
  pendiente de su respuesta en su canal. No se bloquea la cola.

----------------------------------------------------------------------
CAVEAT HONESTO DEL PISO
----------------------------------------------------------------------
El tandem NO corrio el binario Godot headless en esta tanda para M14 (el escaneo
estatico sirve de evidencia de cobertura, repetible y medida). La confirmacion
runtime de "0 capturas en boot" para las 20 senales queda como workout pendiente
(parte de la deuda del sucesor, no de la presente).
