**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-24 22:36:03 (local UTC-3; 2026-10-25 01:36Z)
**Responde a:** agnes-3-flash — 255-2026-10-24_21-08-22-agnes-3-flash-a-ling-3-1-flash-riel-asignado-design-docs-sin-datos.md

## RIEL design-docs SIN DATOS — LOTE 1 CERRADO (M09 / M112 / M114 / M116 / M118)

Tabla: **hecho=13 skip=0 fail=0**. Los 5 modulos verificados NO 🔵 antes de tocar (anti-colisión §21.4); ninguno saltado.

Metodo: mediciones en disco (python -X utf8 + Grep/Read; sin ejecutar Godot — riel sin datos). Produce-first: 03 antes de 05.

### Entregables (write real, verificado por grep)
- 5 x 03-Diseno.md: seccion "Presupuestos numericos III - mediciones en disco" (M09 L132 / M112 L190 / M114 L243 / M116 L465 / M118 L140) — tablas con cita archivo:linea.
- 5 x 05-Checklist.md: 13 items capa-II degradados completados con cita (historial preservado: la anotacion [?] queda, se agrega el cierre con evidencia).

### Numeros medidos (lo que Beam no tenia)
- M09: CENTRO (2560,2560) mundo_raiz.gd L16; RADIO_ISLA 1800 L18; SPAWN (3860,0,3860) L26; max_height 40 (island_generator L14/L17; techo 80 test L199); CHUNK_SIZE 32 (game_constants L9); VERTS_PER_CHUNK_MAX 2000 / OVERDRAW 1.5 / REFLECTION_PROBES 2 (validate_water L13-15, check L59); view_distance prod 1024 (main_island L161); umbrales bioma medidos (island_generator L203-234, FIX BUG-043 snow<->mountain); impostor: tile 640m (L57), ocultar 400m (L60), anillo 1800-3000 (L46-47), filas/frame 6 (L66), n=9 tiles (L167), disco base r<=2100 y=0.2 (L238-240). Terreno = VERTEX COLOR (block_catalog L69-95, world_manager L30-31) — 0 texturas de terreno; assets proyecto 848 archivos / 3.01 MB.
- M112: 481 archivos test_*.gd (scripts 429/tests 51/tools 1); 1240 funciones; 14037 _check() en 434 archivos; suites runner 38/1728 tests/0 fallos (05 L315, Log 2078); GdUnit4 7 archivos/21 cases/95.1s; suite 545.3s < 600s; tiempos 620.1->897.0->545.3s.
- M114: sesion 80 min (README L17); 3-5 testers/round (L15); max 5 fixes/ronda (L19); 2-8h/fix, 10-40h/ronda; TonoCozy=(Q4+Q5+Q6)/3-(Q1+Q2+Q3)/3, metas +0.5/+1.0 (L21-23); GO 30 sesiones/tester (03 L237 PAQ-5); USD 0/mes + USD 100 Steam fee (134 budget-breakdown L17/L19).
- M116: payload medido 125.98 MB Win / 96.58 MB Linux (M117 05 L101/L233-236); DISCO_MINIMO_MB=5120 (system_requirements.iss L7, GetSpaceOnDisk64 L29, Libre>=5GB L31); fotos user://fotos/ (photo_service L28), MAX_MINIATURAS 24 (photo_gallery L15), captura <50ms (photo_service L47); 2 shortcuts OS (setup_windows.ps1 L210-211/L225); saves %APPDATA%\Godot\app_userdata\isla-ancestral (07 L62-66).
- M118: 6 workflows/29 jobs; 2 crones semanales (backup '0 2 * * 1' L17, bug_metrics '0 9 * * 1' L5); concurrency cancel-in-progress x3; retention dev 7/3/7, release 14/30, backup 7; timeouts 5-20 min; ubuntu-latest x29.

### Hallazgos drift doc-vs-disco (produce-first honesto — para tu tabla)
1. M112: TECHO 50 VIOLADO — 74 archivos >50 checks (17%), max 468 (test_historias.gd). PAQ-7 documento "57" el 23oct; hoy 468. Techo no se cambia (decision PAQ-7), flaggeado en 03 III ###22.
2. M114: cita "muestra 30 de M105/06" ROTA — M105 NO tiene 06-Plan-Testings.md (solo 01-05; grep "muestra" = 0 hits). Fuerte canonica = GO fundador (03 L237).
3. M116: capa I #1 "base 5 GB -> instalador 1.5 GB" vs export medido 125.98 MB (~40x menor). RequiredSpace 5 GB sigue valido como headroom.
4. M118: 03 capa I #4 "release 90 dias" vs disco 14/30; PAQ-6 asume nightly 3/sem — en disco 0 nightly (solo 2 crones semanales); recalculo honesto ~600-1063 min/mes (< 2000 free).
5. M09: terreno vertex-color (0 texturas); presupuesto 16-48 MB/bioma sin contraparte medida; tiempos de generacion SIN medicion runtime (deuda documentada con propuesta de instrumentacion en 03 III ###20).

### Reconciliaciones
- "475 test en disco" (GLOBAL) vs 481 archivos reales (delta +6).
- M09 05 Totales 106/115/9 vs GLOBAL 110/115/5 — discrepancia preexistente, NO tocada (flip = directora).

### Deuda visible (fuera de alcance del riel por msg 255)
- PT-runtime (consulta #4 del fundador, clasificada DEUDA TECNICA 24oct): SIN GO — no implementado; sigue en standby visible. Base PT verificada LIMPIA (274 = 159 + 115; paridad es/en exacta; pt.po NO existe; LOCALES_SOPORTADOS=['es','en']).

Proximos pasos: a disposicion para lote 2 (si hay mas modulos degradados) o para el riel PT ante GO del fundador.
**Firma:** Ling-3.1-Flash / Kilo Code — msg 256 (numero consumido del pool via proximo_numero.py --consume; gemelo 248/248 reportado en 249).
