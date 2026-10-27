# 13 — Sondas de runtime del GATE-2 (verificacion cross-QA)

> **Modelo:** Hy3 (verificador tercero §21.8) — transferido por herencia al sucesor
> **Plataforma:** WorkBuddy / Hunyuan
> **Fecha:** 2026-10-27
> **Origen:** recetas referenciales del `PLAYBOOK-GATE2-HERENCIA-HY3.md`
>   (`DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md`).

Este archivo es la version canonica de las sondas de runtime que usa el GATE-2 de
Reflection-Beam-1.0 (el verificador de TERCER nivel). No es teoria: cada receta fue
ejecutada contra el repositorio real de Isla Ancestral (Godot 4.7.2 headless).

## Principio rector (el pulmon del gate-2)

> Un "0 fallos" no se hereda. Antes de creer un verde: (1) proba el guardian EN ROJO
> (inyecta un fallo y exige EXIT 1), y (2) MEDI el PISO de checks en verde, nunca lo
> estimes. Un test que nunca corre sus aserciones publica "0 fallos" y es un falso verde.

## 1. Sustrato de runtime (lo que HAY, no lo que deberia haber)

Verificado en disco — NO existe un MCP `run_project`/`get_debug_output` en este repo.
El runtime es el binario headless + captura de stdout a un log:

  binario : D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
  ruta    : game/isla-ancestral/
  catalogo: game/isla-ancestral/data/coleccionables/catalog.json

Comando canonico de UNA suite (leer SIEMPRE el EXIT code):

  cd "<repo>"
  "<binario>" --headless --path game/isla-ancestral \
      --script res://scripts/datos/test_datos_m60.gd > out/m60.txt 2>&1
  echo "EXIT=$?"          # 0 = 0 fallos; !=0 = al menos 1 fallo

## 2. RED-PROBE (sonda roja) — receta copy-paste

Usar SIEMPRE que una suite reporte "0 fallos". Inyecta un fallo forzado y exige EXIT 1.

Plantilla de GUARDIA 3 CAPAS (copia literal de
`game/isla-ancestral/scripts/accesibilidad/test_accesibilidad_manager.gd`):

    extends SceneTree
    const CHECKS_MINIMOS := 39            # MEDIDO en verde, no estimado
    const _WB_BLOQUES: Array[String] = ["run"]
    var _checks: int = 0
    var _fallos: int = 0
    var _wb_vistos: Dictionary = {}
    var _wb_cerrado: bool = false
    func _fin(nombre: String) -> void: _wb_vistos[nombre] = true
    func _summary() -> void:
        if _wb_cerrado: return
        _wb_cerrado = true
        for b in _WB_BLOQUES:
            if not _wb_vistos.has(b):
                _fallos += 1
                print("[FAIL] bloque %s NO se ejecuto" % b)
        if _checks < CHECKS_MINIMOS:
            _fallos += 1
            print("[FAIL] solo %d checks (min %d)" % [_checks, CHECKS_MINIMOS])
        print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
        quit(1 if _fallos > 0 else 0)
    func _init() -> void:
        call_deferred("_run")
        call_deferred("_summary")     # APARTE: si _run aborta (SCRIPT ERROR), _summary corre
    func _run() -> void:
        # ... _check(...) reales ...
        _fin("run"); _summary()
    func _check(cond: bool, msg: String) -> void:
        _checks += 1
        if not cond: _fallos += 1; print("FALLO: " + msg)

ORACULO = la asercion que DEBE cumplirse si el codigo es correcto. Ej. M60:
`_test_validador_contrato()` exige `errores.is_empty()` en un save valido;
`_test_validador_crc32()` exige CRC32 deterministico (mismo dict -> mismo CRC).

Ejemplo real medido — M60: 47/0, CHECKS_MINIMOS=47 MEDIDO. Red-probe inyectada
(`_check(false,...)`) -> EXIT 1 / 1 fallo; revertida byte-exact -> 47/0 de nuevo.
M74: 119/0 (57+33+29); red-probe EXIT 1, revertida -> 119/0.

## 3. GREEN-PROBE byte-exact — receta

Cuando el AUTOR propone un fix y debe confirmarse que EL FIX (no el azar) pone en verde:

  1. rc_base = correr suite (p.ej. rc=1, falla).
  2. aplicar fix candidato.
  3. rc_fix = correr -> (p.ej. rc=0).
  4. REVERTIR byte-exact:  git checkout -- <archivo_tocado>
                             git status --short <archivo>   # debe estar VACIO
                             certutil -hashfile <archivo> SHA256   # opcional, estricto
  5. re-correr -> debe volver a rc_base. Si no, el revert no fue exacto -> ABORTA.

Ejemplo real — M73: validador CATEGORIAS_CONOCIDAS 8->20; rc 1->0; revertido con
`git checkout --` (git status vacio) -> rc volvio a 1. El fix ES el causante.

## 4. Correlacion de logs (boot vs post-accion)

  <binario> --headless --path game/isla-ancestral --script res://X.gd > out/boot.txt 2>&1
  echo "EXIT_BOOT=$?"        # linea base, sin accion
  # luego de aplicar el fix / la sonda:
  <binario> ... --script res://X.gd > out/post.txt 2>&1; echo "EXIT_POST=$?"

Cruzar SIEMPRE: EXIT vs impresion (EXIT 124 = suite COLGO, no paso), y WARNINGS de
Godot (SCRIPT ERROR / Parse Error) que suelen abortar la funcion donde ocurren. Por
eso `_summary()` va en `call_deferred` APARTE y un piso lo delata.

## 5. Formato de veredicto (APROBADO / RECHAZADO / CON MATICES)

  APROBADO: "Mxx APTO §21.8 — gate-2: <suite> N/0, EXIT 0 (CHECKS_MINIMOS=N MEDIDO).
  Red-probe EXIT 1, revertida byte-exact. 05 cuerpo X/Y/Z sin drift vs GLOBAL."
  CAVEAT / NO sellar: "Mxx CAVEAT — <causa: inflacion de [x], flips externos>.
  Recomiendo revertir/revisar antes de sellar."
  HONESTIDAD DE PISO (siempre): declaro lo que mi sonda NO ejercita — render/visual,
  audio humano, red/tiempo real, FPS en device, UX percibida.

## 6. Anti-inflacion (el "625" del fundador) — metodo real

Nunca creas `**Totales:**` de un 05-Checklist: mienten (items apendidos despues que ni
el Total ni el GLOBAL cuentan). Medí por prefijo:

  grep -cE '^\s*- \[[ x?]\]' <ruta>                 # cuerpo real
  grep -E '^\s*- \[([ x?])\]' <ruta> | awk ...      # desglose [x]/[ ]/[?]

Cruzar contra `CHECKLIST-GLOBAL.md` (fila del modulo) y contra disco (¿el artefacto
existe?). Si hay [x] cuyo artefacto NO existe en disco/ninguna base (incluye out/,
Obsoletos/, basename) y no es user:// ni plantilla ni API -> es inflado: CAVEAT.

## 7. Las 5 reglas de disciplina (sin ellas el metodo no vale)

1. RED antes de creer: inyecta fallo y exige EXIT 1.
2. MEDIR el piso en verde: CHECKS_MINIMOS medido, nunca estimado.
3. REVERTIR byte-exact y VERIFICAR (git status vacio / sha256) tras cada sonda.
4. NO auto-QA ni self-sello: verificador != autor; el sello lo pone el director.
5. NUMERACION honesta: 1 numero = 1 archivo; canal = max(archivos en disco)+1.

## 8. Referencias cruzadas

- Playbook nominal completo: `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md`
- Verificaciones reales registradas en `Mensajes entre modelos/Hy3/` (msgs 311-314, 383-404, 412-421).
- Tabla viva de veredictos: `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/GATE2-BEAM-VERIFICACION.md`


## GATE-2 MODEL-AGNOSTIC — re-asignación permanente (directiva del fundador 27oct: el método sobrevive a los agentes)

El gate-2 (sondas de runtime) **no pertenece a ningún agente**: pertenece al repositorio. Reglas para que funcione con CUALQUIER agente que tome la tarea:

1. **Prerequisitos del agente-asignado (mínimos):** acceso de lectura al repo + MCP de Godot (run_project/get_debug_output) o poder correr el binario headless (4.7.2) + capacidad de citas textuales. Ningún requisito de modelo, plataforma o vendor.
2. **Onboarding express (30 min):** leer `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md` (método completo) + esta guía → ejecutar 2 sondas calibradas comparadas con un veredicto anterior (referencia: los casos de la tabla) → firma dual cuando exista transmisor; si no existe, doble verificación con re-medición scriptable.
3. **Independencia (§21.8):** el gate-2 NO puede verificar trabajo que el propio agente produjo. Cualquier modelo sirve EXCEPTO el productor.
4. **Sondas que NO requieren agente (scripts permanentes):** las sondeas mecánicas (conteo de emisiones de señales, validadores de suites) se corren con scripts del repo — ver `scripts/red_probe_event_bus.py` (red-probe M14 automatizada; salida: señales 0-emit vs oráculo). Cualquier cron o humano puede correrlas: el veredicto es máquina-verificable.
5. **Si el agente asignado muere:** el gate-2 se re-asigna a cualquier otro que cumpla los prerequisitos — el playbook + esta sección son la única dependencia.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-27, directiva del fundador ("en el futuro quizás tampoco esté Nemotron: el método debe funcionar para cualquier agente").
