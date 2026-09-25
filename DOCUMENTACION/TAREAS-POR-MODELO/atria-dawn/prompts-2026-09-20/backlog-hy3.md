**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — hy3

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** QA cruzado + cierre de dudas (9/9 suites rc=0)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente hy3 --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 66-Anti-Softlock (8 pendientes)

- [?] **T-001 66:** Implementar disparo del detector al guardar [S] — SaveManager.save_completed (M59) → forzar_chequeo — **FLIP atria-dawn (Log 1029, 2026-09-18): el ...
- [?] **T-002 66:** Implementar validación con NavigationServer3D de 2 caminos [M] — (dueno externo M27/M64/M22/M26, Log 701/744)
- [?] **T-003 66:** Implementar watchdog anti-atasco reusado de M64 (2 s/6 s) [M] — (dueno externo M27/M64/M22/M26, Log 701/744)
- [?] **T-004 66:** Implementar sincronización con persistencia de misiones (M22) [M] — KnownIssue: integración real cuando M22 exponga la API (dueno externo, Log 701/...
- [?] **T-005 66:** Implementar pruebas de misiones imposibles (injerto) [M] — (dueno externo M27/M64/M22/M26, Log 701/744)
- [?] **T-006 66:** Implementar integración con M22 (Historia Principal) [M] — KnownIssue: cuando M22 exponga la API (dueno externo, Log 701/744)
- [?] **T-007 66:** Implementar integración con M26 (Templo Subterráneo) [M] — KnownIssue: cuando M26 exista (dueno externo, Log 701/744)
- [?] **T-008 66:** Implementar integración con M64 (watchdog NPC) [M] — KnownIssue: cuando M64 exponga el watchdog (dueno externo, Log 701/744)

## 25-Ruinas (15 pendientes)

- [ ] **T-009 25:** Diseñar atalayas con vista de bioma
- [ ] **T-010 25:** Definir validación de caminos con NavigationServer3D
- [ ] **T-011 25:** Integrar con M26 (templo subterráneo, sin rozar)
- [ ] **T-012 25:** Integrar con M28 (caminos)
- [ ] **T-013 25:** Integrar con M31 (alineación solar en observatorios)
- [ ] **T-014 25:** Integrar con M32 (viento/lluvia en pasajes y jardines)
- [ ] **T-015 25:** Integrar con M36 (museo: vitrinas para objetos)
- [ ] **T-016 25:** Integrar con M45/M47 (kit de referencia para assets)
- [ ] **T-017 25:** Diseñar 06-Plan-Testings.md: validación del kit (pivotes/snaps)
- [ ] **T-018 25:** Diseñar 06-Plan-Testings.md: armado de los 13 tipos
- [ ] **T-019 25:** Diseñar 06-Plan-Testings.md: progresión de descubrimiento
- [ ] **T-020 25:** Diseñar 06-Plan-Testings.md: pruebas de rendimiento (LOD)
- [ ] **T-021 25:** Definir criterio de éxito: suite completa pasa sin fallos
- [ ] **T-022 25:** Crear 07-Resultados-Testings.md para registrar la ejecución
- [ ] **T-023 25:** Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA

## 117-Build-System (18 pendientes)

- [?] **T-024 117:** Definir firmado incluido en staging [M] → T-012 externo (cert CA + runner; dueno M116/infra)
- [?] **T-025 117:** Definir regla de commits en PR (M118) [S] → T-018 decision M118 (dueno M118)
- [?] **T-026 117:** Definir suite completa en nightly [M] → T-020 sin schedule en workflows (dueno M118)
- [?] **T-027 117:** Definir gates de stress (M113) rápido en QA [M] → T-023 diseno; suite operativa dueno M113
- [?] **T-028 117:** Definir gates de stress completo pre-release [M] → T-024 diseno; suite operativa dueno M113
- [?] **T-029 117:** Definir packaging por plataforma (M96) [C] → T-025 solo preset Windows verificado (dueno M96)
- [?] **T-030 117:** Definir .app macOS + zip [M] → T-027 sin preset macOS (dueno M96)
- [?] **T-031 117:** Definir no data duplicada en artifact [S] → T-029 sin build real (dueno build real)
- [?] **T-032 117:** Definir tamaño objetivo del artifact por plataforma [M] → T-030 sin build real (CiCdManager size_bytes listo)
- [?] **T-033 117:** Definir acceso con permisos por rol (M118) [S] → T-037 decision GitHub envs (dueno M118)
- [?] **T-034 117:** Definir firmado Windows con signtool [M] → T-038 code_signing.bat presente pero enable=false + sin cert (dueno M116/infra)
- [?] **T-035 117:** Definir firmado macOS con notarytool + staple [M] → T-039 sin preset/runner (dueno M96/infra)
- [?] **T-036 117:** Definir smoke del artifact (no del runner) [C] → T-043 sin script smoke (dueno M118)
- [?] **T-037 117:** Definir paso: nueva partida con semilla fija [M] → T-044 (dueno M118)
- [?] **T-038 117:** Definir paso: guardado + carga (M59) [M] → T-045 (dueno M118)
- [?] **T-039 117:** Definir paso: salida limpia exit 0 [M] → T-046 (dueno M118)
- [?] **T-040 117:** Definir smoke en QA/staging/release [M] → T-048 (dueno M118)
- [?] **T-041 117:** Definir gestión de keystores/certificados centralizada [S] → T-050 sin store central (dueno M118/M96)

---

## PRIORIDAD EXTRA — QA cruzado §21.8 (10 módulos ✅ sin sello)

> **Esta es tu especialidad medida (9/9 suites rc=0).** Después de cerrar los módulos
> de arriba (o en paralelo si prefieres), verifica estos **10 módulos ✅ que no tienen
> sello §21.8**:

- [ ] **T-QA01:** M32 Clima — verificar (atria ya lo vio, Log 942; confirma sello)
- [ ] **T-QA02:** M84 Musica-Y-Audio-Legal — **arreglado por atria (BUG-062, Log 1085)**; test 15/0
- [ ] **T-QA03:** M94 Retencion-Sin-FOMO — **arreglado por atria (BUG-061, Log 1083)**; test 38/0
- [ ] **T-QA04:** M102 Bug-Tracking — verificar
- [ ] **T-QA05:** M112 Testing-Automatico — verificar
- [ ] **T-QA06:** M153 Objetivo-Final — verificar
- [ ] **T-QA07:** M154 Vision-Del-Agente — validate_vision.py 19/19 (Log 1065)
- [ ] **T-QA08:** M167 Isla-Raiz — validador 27/0 (Log 1065)
- [ ] **T-QA09:** M78 Legal-Propiedad-Intelectual — verificar
- [ ] **T-QA10:** M93 Balance — verificar

**Por cada uno:** (1) `05-Checklist.md` sin `[?]` (viola DoD §21.6), (2) código existe y
no es stub, (3) `plan-actual/` coincide con código, (4) logs y firmas del autor,
(5) suite headless re-corrida con binario 4.7.2 si existe.

**Veredicto por módulo:** `✅ Verificado por hy3 (WorkBuddy) 2026-09-20, Log NNNN` o
`🟡 Hallazgos` (documenta en `## Notas del Agente` de `plan-actual/04-Codigo.md`,
**sin borrar notas anteriores**).

---

## Meta

41 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
