# -*- coding: utf-8 -*-
"""Cierre v42 + escrituras v43 en docs (todo io.open UTF-8 sin BOM, LF):
- AUDITORIA: replace 'check_v42 (36 checks)' -> 38 checks + ADDENDUM v42 + §35
- BK 01: ADDENDUM v42 + ESTADO v43 (anchor unico) + header v14-v42 -> v14-v43"""
import io

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"

# ---------- AUDITORIA ----------
aud = io.open(AUD, encoding=u"utf-8").read()
old = u"check_v42 (36 checks)."
new = (u"check_v42 (38 checks: 34 PASS 1er run + 4 check-bugs fixeados "
       u"[6 case-sens, 18 regex Totales, 20 substring, 27 umbral Temp]; re-run 38 PASS/0 FAIL; "
       u"check 12 re-escrito como centinela determinista; check 21 tolerante a msg 355 propio).")
n = aud.count(old)
assert n == 1, u"anchor 36 checks aparece %d veces" % n
aud = aud.replace(old, new)

ADD = u"""

### Addendum v42 (cierre extendido 2026-11-07 01:30 local / 04:30Z)

- **Agrupador de canales confirmado legitimo**: las 931 deletions son 100% dentro de `Mensajes entre modelos` (desglose por directorio: 0 fuera); 0 D en game/ ni scripts/ de codigo; canal Ling 0 D/M; WT 33->1286 y siguiendo (agrupador activo: 1223->1420 entries). DS-OC/directora corrieron `scripts/agrupar_canales.py` (respaldos en scripts/Obsoletos/2026-11-06_22-1*). Reestructuracion por centenas (arch_0001-0100...), SOP AGENTS 4.1-b.
- **Detector 16a-17a hora (centinela)**: items [x] 22649->22654 (+5), C2-RESUELTO 551->552 (+1); invariantes iguales (A1=21 R4=187 A2=233 A3=4 SOS=289 FP=4, 168 checklists); detector 100% determinista (2 corridas diff=0). **Trampa propia descartada**: el "detalle_diff=220" inicial fue ARTIFACTO DE ENCODING de mis snapshots v42/v43 (guardados con mojibake â© en vez de â© limpio del runtime); NO era drift de flota. Diagnostico: Temp/kilo/diag_check12.py + diag_run1/2.txt.
- **+5 flips ATRIBUIDOS y VERIFICados (QA 21.8.2.b; centinela verifica, NO flipea)**: DS-V4.1-Flash-Opencode, Logs 2353 (M129) + 2354 (M17), mtimes checklists M17 22:36:32 / M129 22:26:19 local 6nov, 04-Codigo actualizados ambos, artefactos en disco:
  - M17-Construccion +4: D97 rejilla 1m, D102 coherencia guardar/cargar, F127 mover sin re-cobro, P256 integracion colocar->guardar->cargar->restaurar; suite NUEVA tests/test_m17_persistencia_rejilla.gd (23 checks 0 fallos); Totales re-medido 139/35/1 = marcas reales 139/35/1.
  - M129-Merchandising +1: L101 stock+numeracion tiradas limitadas RESUELTO v3 (revertido Familia A BUG-070 lote 7 -> resuelto con codigo real); merch_manager.gd (reservar_unidades/liberar_reserva/confirmar_venta/get_save_data), merch_validator.gd, test_merch_m129.gd 58/0, test_merch_boot_m129.gd B-17 11/0, merchandising.json v3 (artbook 500/vinilo 300/figura 200); Totales 108 = marcas 107/0/1.
  - Veredicto: flips LEGITIMOS (Logs + codigo + tests + conteos coherentes). Sin inflacion. C2+1 (551->552): dato agregado del detector, modulo no identificable por salida agregada (reportado, no atribuido).
- **Cron C 6a8ab2f: 6h+ sin preservar** v40+v41+v42 (slots 01:17/02:17/03:17/04:17Z pasados; patron v39 ~55min). ESCALADO al director — no bloqueante: riel PT canonico safe en HEAD 071a2f9; check 25 confirma §32/§33 solo en WT.
- **Flota silenciosa 7nov**: glob Mensajes entre modelos/**/*2026-11-07*.md = 0 archivos; ultimo latido DS-OC acuse 23:46 local 6nov. estado_director congelado 399 claves mtime 22:02 (agnes NO proceso mi 354; ling_345-351_acusado NO registrado — anti-loop honesto intacto). Posible dormancia de sesiones (patron 6nov 09:22Z).
- **ESTADO-PARALELO.md stale desde 17-oct** (5331 lineas; head = M159) — tablero de coordinacion sin actualizar 3 semanas; dato para directora.
- **Temp/kilo limpiado reversible**: 186->14 directos (176 movidos a Temp/kilo/_archivo_v25_v41/, listado en salida de limpiar_temp_v43.py); mis archivos, desechables, no versionados por Cron C.
"""
aud = aud.rstrip(u"\n") + u"\n" + ADD

S35 = u"""
## 35. VUELTA 43 (2026-11-07 01:30 local / 04:30Z) — CIERRE v42 38/0 + CENTINELA: +5 flips atribuidos DS-OC (legítimos) + agrupador canales + Cron C 6h escalado

**Escrituras reales v43**: msg 355 (3.072B, pool canal 355->356, helper proximo_numero --consume; numeracion no manual) · Log 2355 (ritual assert cabeza>=2355, tomo 2355; pool Logs 2355->2356) · addendum v42 + §35 (este) · ESTADO v43 + header v14-v43 · check_v43.

**CIERRE v42 — check_v42 38 PASS / 0 FAIL**: 4 check-bugs propios fixeados en v42 (6 case-sens; 18 regex Totales `**Totales:** NN` — formato real tiene espacio tras `**`; 20 startswith->substring `/347-`; 27 umbral Temp/kilo 60 realista post-limpieza) + check 12 re-escrito como centinela determinista (2 corridas diff=0; items_x/C2 como dato, no asercion congelada) + check 21 tolerante (>=354; msg 355 propio legitimo en disco al re-runear). Re-run intermedio 37/1 (check 21 stale por diseño) -> re-run final 38/0.

**CENTINELA — HALLAZGO MATERIAL (16a-17a hora)**: detector items [x] 22649->**22654 (+5)** y C2-RESUELTO 551->**552 (+1)**; invariantes estables (A1=21, R4=187, A2=233, A3=4, SOS=289, FP=4, 168 checklists); 0 cambios en detalle de familias de defecto. Trampa propia descartada (ver addendum v42): snapshots v42/v43 con mojibake propio; detector 100% determinista (2 corridas diff=0).

**ATRIBUCION +5 flips (QA 21.8.2.b muestreado: sustento textual + fisico + conteos)**: DS-V4.1-Flash-Opencode, Logs 2353/2354, mtimes 22:26/22:36 local 6nov:
- M17-Construccion +4 [x]: D97 (OFFSET_MEDIO_VOXEL=0.5 en construccion_mundo.gd), D102, F127 (mover_pieza build_manager.gd L555-597), P256; suite NUEVA tests/test_m17_persistencia_rejilla.gd 23/0; marcas reales 139/35/1 = Totales declarado 139/35/1.
- M129-Merchandising +1 [x]: L101 stock/numeracion tiradas v3; merch_manager.gd + merch_validator.gd + test_merch_m129.gd 58/0 + test_merch_boot_m129.gd 11/0 + merchandising.json v3 3 tiradas; marcas reales 107/0/1 = Totales 108.
- Veredicto: flips LEGITIMOS, sin inflacion. Centinela Ling verifica y NO flipea (regla 21.8.2.b: muestreo 5 items con verbos de creacion — implementar/cerrar/verificar/definir/automatizar — todos con artefacto en disco).

**OTROS HALLAZGOS**:
- Agrupador canales legitimo y activo (0 D codigo; canal Ling intacto; WT ~1420).
- Cron C 6a8ab2f 6h+ sin preservar v40-v42 — ESCALADO.
- Flota silenciosa 7nov (0 msgs nuevos; ultimo latido DS-OC 23:46 local 6nov).
- ESTADO-PARALELO.md stale 17-oct (dato directora).
- Temp/kilo 186->14 directos (limpieza reversible, 176 a _archivo_v25_v41/).

**Riel i18n (re-verificado v43)**: locales es/en/pt 276 msgids, sha es 954107e1948a / en a601d4f63b76 / pt d2b567c48e88, WT==HEAD x3; localization_manager.gd 047eab5ff111 WT==HEAD; watchdog oficial LIMPIO rc=0 (cwd=RAIZ); 0 .mo; translation/ y ling_i18n_manager.gd siguen ausentes (untracked; pregunta limpieza oficial reiterada en msg 355).

**Pools**: canal Ling cabeza 356 (355 consumido por helper); Logs cabeza 2356 (2355 ritual). Huecos canal Ling: [63,156,157,232,233,234] (saneo fundador).

Firmado: Ling-3.1-Flash (Kilo Code) — 2026-11-07 01:30 local.
"""
aud = aud.rstrip(u"\n") + u"\n" + S35
with io.open(AUD, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(aud)
print(u"AUDITORIA: replace 36->38 + addendum v42 + §35. chars:", len(aud))
print(u"  §35 presente:", u"## 35." in aud, u"| addendum v42:", u"Addendum v42" in aud, u"| 38 checks:", u"38 checks" in aud)

# ---------- BK 01 ----------
bk = io.open(BK, encoding=u"utf-8").read()
nh = bk.count(u"v14-v42")
print(u"header v14-v42 ocurrencias:", nh)
if nh >= 1:
    bk = bk.replace(u"v14-v42", u"v14-v43")

anchor = u"Firmado: Ling-3.1-Flash (Kilo Code).\n\n**ESTADO 2026-10-27 01:01 local (04:01Z) — VUELTA 04:00Z:**"
na = bk.count(anchor)
assert na == 1, u"anchor addendum/ESTADO v43 no unico: %d" % na

BLOQUE = u"""Firmado: Ling-3.1-Flash (Kilo Code).

**ADDENDUM v42 (cierre extendido 01:30 local / 04:30Z):** check_v42 38 PASS/0 FAIL (fixes 6/18/20/27 + check 12 centinela determinista + check 21 tolerante msg 355 propio). Centinela: detector +5 [x] (22649->22654) + C2+1 (551->552), invariantes estables, 0 flips familias defecto — **atribuidos y verificados a DS-OC** (QA 21.8.2.b muestreado): M17 +4 (D97/D102/F127/P256, Log 2354, suite tests/test_m17_persistencia_rejilla.gd 23/0, marcas 139=Totales) + M129 +1 (L101 stock/tiradas v3, Log 2353, merch_manager/validator/tests 58/0/boot B-17 11/0, marcas 107=Totales 108). Flips LEGITIMOS sin inflacion. Agrupador canales legítimo y activo (931 D 100% en Mensajes entre modelos, 0 código, WT ~1420). Cron C 6a8ab2f 6h+ sin preservar v40-v42 — ESCALADO. Flota silenciosa 7nov (0 msgs nuevos). ESTADO-PARALELO stale 17oct. Temp/kilo 186->14 (limpieza reversible).

**ESTADO 2026-11-07 01:30 local (04:30Z) — VUELTA 43 CIERRE** (cron 04:07Z puntual; anti-loop: canal sin 356+, ling_345-351_acusado NO registrado, estado_director congelado 399 claves mtime 22:02 — agnes NO procesó mi 354; sin respuesta 352/353/354 → vuelta propia). CIERRE v42: check_v42 38 PASS/0 FAIL. CENTINELA MATERIAL: detector +5 [x] (22649→22654) + C2+1 (551→552) con 0 cambios en detalle de defectos; atribución verificada a DS-OC (M17+4/M129+1, Logs 2353/2354, sustento textual+físico+conteos coherentes; sin inflación). Trampa encoding propia descartada (snapshots mojibake; detector determinista 2 corridas diff=0). Otros hallazgos: agrupador canales legítimo activo (WT ~1420, 0 D código); **Cron C 6a8ab2f 6h+ sin preservar v40-v42 — ESCALADO** (riel PT safe en HEAD 071a2f9); flota silenciosa 7nov (0 msgs nuevos en canales); ESTADO-PARALELO stale 17oct. Riel i18n íntegro re-verificado (276 msgids x3, shas canónicos WT==HEAD, manager 047eab5ff111, watchdog LIMPIO). Pregunta reiterada: ¿eliminación translation/ + ling_i18n_manager.gd fue limpieza oficial? Escrituras reales v43: msg 355 (pool 355→356) · Log 2355 (ritual, pool Logs 2355→2356) · addendum v42 + §35 AUDITORIA · ESTADO v43 + header v14-v43 · check_v43. Pools: canal cabeza 356, Logs cabeza 2356. Bloqueos: I-08 runtime ms; bug_156=DS#491; gate-2 PT=Hy3; R4/gemelos/deuda313=fundador. Vuelta 44 ~05:07Z: ¿Cron C preservó v40-v43? ¿agnes acusa 345-354/responde 355? ¿flota despierta (Hy3 gate-2 M64/M17)? Firmado: Ling-3.1-Flash (Kilo Code).

**ESTADO 2026-10-27 01:01 local (04:01Z) — VUELTA 04:00Z:**"""

bk = bk.replace(anchor, BLOQUE)
with io.open(BK, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(bk)
print(u"BK01: addendum v42 + ESTADO v43 insertados; header v14-v43. chars:", len(bk))
print(u"  ESTADO v43 presente:", u"VUELTA 43 CIERRE" in bk, u"| addendum:", u"ADDENDUM v42" in bk, u"| header v14-v43:", u"v14-v43" in bk)
