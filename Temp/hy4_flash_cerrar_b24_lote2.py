#!/usr/bin/env python3
"""Cierra el lote 2 del backlog 24 (T24-11..30) con evidencia medida."""
import re

P = "DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/24-Backlog-Bug-RootCause-Remaining.md"

D = {
11: "BUG-042 - diagnosticar causa — BUG-042 CAUSA: descargas 404 de GitHub guardadas como .ttf (magic 0a0a0a0a, ~304 KB de HTML). HOY RESUELTO: 4/4 .ttf de assets/fonts/ con magic 00010000 y tamanos 39724/132280/132312/276932 B; 0 paginas HTML. RESIDUO NUEVO: data/fonts/fonts.json mantiene 4 entradas con tiene_archivo=false (catalogo no refleja los archivos reales) -> reportar al dueno M46/M88. CONFIDENCIA ALTA",
12: "BUG-043 - diagnosticar causa — BUG-043 CAUSA: check de mountain (h>0.65*max_height) evaluado ANTES que snow (h>0.8*max_height) -> snow codigo muerto. HOY RESUELTO: island_generator.gd:218 `if height > max_height * 0.8: return \"snow\"` precedes L222 mountain; commentario L214-217 documenta el fix. CONFIDENCIA ALTA",
13: "BUG-044 - diagnosticar causa — BUG-044 CAUSA: dos sistemas de camara paralelos; el documentado (camera_rig.gd, 267 lineas) solo se instancia en main.tscn, no en la escena principal. ESTADO ACTUAL: project.godot:15 main_scene=main_island.tscn; main_island.tscn:7 carga follow_camera.gd; camera_rig.gd:1 lleva header DEPRECATED/CODIGO MUERTO y follow_camera.gd:5 documenta que shake/fade/FOV fueron portados. Mitigado por documentacion Y canonicalizacion; el codigo muerto SIGUE en disco. CONFIDENCIA ALTA",
14: "BUG-046 - diagnosticar causa — BUG-046 CAUSA: 12 .tres con categoria del id interno distinta del prefijo del archivo (M159). HOY RESUELTO: 272 items item_obj_*.tres medidos, 0 discordancias categoria(id) vs prefijo (regex ^id = \"OBJ-XXX-\"); los 12 ids viejos desaparecieron. CONFIDENCIA ALTA",
15: "BUG-047 - diagnosticar causa — BUG-047 CAUSA: early return 0 en _precio_venta_base cuando precio_compra<=0, mas falso fix v1 con .get() de 2 args sobre Resource. HOY RESUELTO: price_manager.gd:218-225 _catalog_venta() usa EconomyPriceCatalog.get_price_def(item_id) con null-check; L199-203 _precio_venta_base consume el precio_venta del catalogo. CONFIDENCIA ALTA",
16: "BUG-048 - diagnosticar causa — BUG-048 CAUSA: (a) `is Tween` sobre var inferida de get_children() en theme_ux.gd (Tween es RefCounted, no Node) y (b) _on_node_entered duplicada en dialog_layer.gd. HOY RESUELTO: theme_ux.gd:203-213 itera por indice con `var child: Variant` antes de `is Tween` (comentario L205-208 cita BUG-048); dialog_layer.gd tiene 1 sola `func _on_node_entered` (L280). CONFIDENCIA ALTA",
17: "BUG-049 - diagnosticar causa — BUG-049 CAUSA: guardian de logs con regex ^(\\d{3})- ciego a numeros de 1, 2 y 4+ digitos (98 logs invisibles). HOY RESUELTO: scripts/reservar_log.py:102-103 usa RE_LOG/RE_RES con ^(\\d+)-; comentario L98 documenta el motivo. CONFIDENCIA ALTA",
18: "BUG-050 - diagnosticar causa — BUG-050 CAUSA DOBLE YA DESLINDADA: el `.size()` sobre Callable NO estaba en catalogo_tiendas.gd sino en test_logros.gd:291 (ver BUG-055); la parte real (`piedra_caliza` inexistente en M15) hoy RESUELTA via tabla de mapeo en catalogo_tiendas.gd:15-22 (8 ids viejos -> ids reales M15); 0 apariciones de los ids viejos en codigo vivo (solo comentarios). CONFIDENCIA ALTA",
19: "BUG-051 - diagnosticar causa — BUG-051 CAUSA: `godot --headless --script` sin script + `|| true` -> job godot-lint no-op. HOY RESUELTO CON GATE DURO: quality.yml:45 genera _colector_sintaxis.gd; L77 corre --check-only con `| tee ... || true` (solo evita -e), L78 cuenta SCRIPT ERROR del log, L82 pone FAIL=1, L86 `exit $FAIL`. El `|| true` NO neutraliza el gate: el veredicto sale del conteo. CONFIDENCIA ALTA",
20: "BUG-052 - diagnosticar causa — ID DUPLICADO EN EL REGISTRO, DOS CAUSAS: (a) `.get()` de 2 args sobre Resource en 3 archivos de M64 — resuelto (ver entrada L3814); (b) deuda de copyright .glb: pipeline Blender exporta `asset.generator` pero NO `asset.copyright`; tools/legal/asset_metadata_scope.json:30-33 fija trinquete SIN_ATRIBUCION max 418. MEDIDO HOY: 490 .glb versionados bajo assets/3d (el registro cita 694/418, cifra stale); scripts/auditar_copyright_glb.py agoto timeout 120 s, estado actual NO re-medido en esta vuelta. CAUSA CONFIDENCIA ALTA / ESTADO CONFIDENCIA MEDIA. Dueños M166/M09, NO tocado",
21: "BUG-053 - diagnosticar causa — BUG-053 CAUSA: defectos de autoría de mallas en Blender, no de codigo (7 artefactos V-1..V-7). V-3 YA RESUELTO por regla E-80: ruinas/colocar_props_m25.gd:8-12 corrige z_min +0.295/+0.340 de antorcha_pared. V-1/V-2/V-4/V-5 SIGUEN PENDIENTES de correccion de mallas (Hy4 V5); los 4 nombres NO aparecen en el backlog visual 23 (grep=0) -> sin seguimiento local. V-6/V-7 son de M51/M167. CONFIDENCIA ALTA",
22: "BUG-054 - diagnosticar causa — BUG-054 CAUSA: M39 escrito con ids en espanol (madera_roble, piedra_caliza...) sin contraparte en M15/M159 (usa OBJ-* e ingleses); ademas el validador solo miraba catalogo_venta, no recompra. HOY RESUELTO: catalogo_tiendas.gd:15-22 mapea los 8 ids a OBJ-ITE-024, copper_ore, wood, stone, grass, OBJ-ART-002/003, OBJ-HER-001; 0 ids viejos en codigo vivo; catalogo_recompra asignado en L127/144/165. CONFIDENCIA ALTA",
23: "BUG-055 - diagnosticar causa — BUG-055 CAUSA: `_ach.desbloqueados` no existia (campo privado _desbloqueados); Godot resolvia el nombre a Callable y `.size()` fallaba en runtime, ensuciando todos los runs. HOY RESUELTO: test_logros.gd:10 documenta el falso verde, L223 usa get_desbloqueados(), L244 usa desbloqueados() que SI existe en achievement_service.gd:349 (y el alias L411). CONFIDENCIA ALTA",
24: "BUG-056 - diagnosticar causa — BUG-056 CAUSA: 7 scripts versionados con sintaxis Python/no-GD que ningun gate parseaba (antes del gate BUG-051). MEDIDO HOY: 3/3 archivos nominales limpios de las construcciones denunciadas — collectible_category.gd 0 docstrings `\"\"\"` y 0 comprensiones; audio_legal_manager.gd 0; test_credits_m131_v2.gd 0. Los 4 tests restantes NO re-ejecutados en esta vuelta (diagnostico, no QA). CONFIDENCIA ALTA en causa / MEDIA en verificacion total",
25: "BUG-057 - diagnosticar causa — BUG-057 CAUSA: restore_save_data() buscaba por duck-typing una fuente con obtener_estructuras()/restaurar_estructuras(); como M17 no existia, fuente() devolvia null y `return` descartaba la lista sin avisar. HOY MITIGADO: buildings_save_provider.gd:60-67 conserva el `if f == null: return`, pero project.godot:136 registra autoload Construccion -> build_manager.gd expone restaurar_estructuras (grep confirmado), asi que la fuente ya existe en boot. CONFIDENCIA ALTA",
26: "BUG-058 - diagnosticar causa — ID DUPLICADO, DOS CAUSAS: (a) validar_nombres.py (M149) reportaba 1128 violaciones, 95% ruido de Godot/app_userdata/addons — HOY RESUELTO: DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validar_nombres.py:38 EXCLUDE_DIRS=(\"Godot\",\"app_userdata\",\"addons\"), L44 excluye Obsoletos; (b) autoload M107 roto por ZIPWriter (Godot 3) — HOY RESUELTO: backup_manager.gd:120-127 usa ClassDB.class_exists(&\"ZIPPacker\"), ZIPPacker.new() y APPEND_ADDINZIP. CONFIDENCIA ALTA",
27: "BUG-059 - diagnosticar causa — BUG-059 CAUSA: notas KnownIssue citan secciones `03-Diseno.md §X.Y` inexistentes (sellos fabricados revertidos). PARCIAL: el header de 05-Checklist M126 L4-14 documenta el problema y el mapa de re-referencia, PERO median 11 items [x] que siguen citando §3.1-§3.9 en vivo (L68,69,76,77,85,87,94,97...) y 03-Diseno.md solo tiene §1/§2/§3 — trampa 129 (cita en rango mal atribuida). NEW sweep: M86 §12 y M108 §6 siguen con 0 headers. CONFIDENCIA ALTA. Dueños M126/M128/M71/M80/M86/M108/M127",
28: "BUG-060 - diagnosticar causa — BUG-060 CAUSA: _create_hotbar_hud() desreferenciaba get_tree().current_scene sin null-check (L972/978 originales) y crasheaba en instanciaciones previas al change_scene. HOY RESUELTO: player.gd:1014-1018 guarda `var current_scene := get_tree().current_scene` + `if current_scene == null: push_warning(...); return`; ademas L116 llama via call_deferred(). CONFIDENCIA ALTA",
29: "BUG-061 - diagnosticar causa — BUG-061 CAUSA: data/motivacion/objetivos.json tenia esquema 'v2' divergente (cadencia='diario_suave', target_min, recompensa string) frente al canon (.gd: plazo/cantidad_requerida/recompensa_id/recompensa_cantidad) -> 5 checks rojos sobre modulo marcado 135/135. HOY RESUELTO: 7/7 objetivos con campos canonicos, distribucion 3 diarios/2 semanales/2 mensuales, 0 campos 'cadencia'/'target_min'. CONFIDENCIA ALTA",
30: "BUG-062 - diagnosticar causa — BUG-062 CAUSA: `var tracks := data.get(...)` inferia Variant desde Dictionary.get() y Godot 4.7 (warnings=errores) rechazaba la suite M84, haciendo el 99/99 no re-validable. HOY RESUELTO: test_audio_licenses_m84.gd:75 y :94 usan `var tracks: Array = data.get(\"tracks\", [])` (medido en disco, 2/2). CONFIDENCIA ALTA",
}

raw = open(P, "rb").read()
txt = raw.decode("utf-8")
lineas = txt.splitlines(keepends=True)
antes_vacias = sum(1 for l in lineas if l.startswith("- [ ] T24-"))
antes_hechas = sum(1 for l in lineas if l.startswith("- [x] T24-"))

cambios = 0
for i, l in enumerate(lineas):
    m = re.match(r"^- \[ \] T24-(\d+):", l)
    if not m:
        continue
    n = int(m.group(1))
    if n not in D:
        continue
    eol = "\r\n" if l.endswith("\r\n") else ("\n" if l.endswith("\n") else "")
    lineas[i] = "- [x] T24-%d: %s%s" % (n, D[n], eol)
    cambios += 1

assert cambios == 20, "se esperaban 20 cambios, hubo %d" % cambios

bloque = [
    "",
    "## Lote 2 cerrado (HY4 Flash, 2026-11-18)",
    "",
    "- **20/20 diagnosticados** contra codigo vivo y bytes en disco (T24-11..30, BUG-042..062).",
    "- **15 resueltos**, 2 mitigados con deuda viva (BUG-044 codigo muerto documentado, BUG-057 fuente recien cableada), 1 parcial (BUG-053 V-1/V-2/V-4/V-5 sin mallas corregidas ni seguimiento en backlog 23), 1 parcial con residuo medido (BUG-059: 11items [x] siguen citando §3.1-§3.9 inexistentes), 1 riesgo vivo (BUG-052-b: 490 .glb vs techo 418; auditor timeout 120 s), 1 con id duplicado resuelto en ambas entradas (BUG-058).",
    "- **2 IDs duplicados en el registro** (BUG-052 y BUG-058): cada uno tiene dos entradas con causas distintas; se diagnosticaron AMBAS.",
    "- **Cifras stale detectadas:** BUG-042 (304 KB HTML -> 4 fuentes reales), BUG-046 (12 items -> 0/272), BUG-052 (694/418 -> 490 under assets/3d), BUG-062 (lineas 75/94 confirmadas).",
    "- **Sin arreglos de codigo**: nicho = diagnosticar sin arreglar. Sin commits/push. Sin tocar 05-Checklist ajenos.",
    "",
    "**Firma:** hy4-flash",
]
# Normalizar el bloque al EOL del archivo (medido, no asumido)
eol = "\r\n" if txt.count("\r\n") > txt.count("\n") - txt.count("\r\n") else "\n"
lineas.extend([x + eol for x in bloque])
out = "".join(lineas).encode("utf-8")
open(P, "wb").write(out)

despues_vacias = sum(1 for l in out.decode("utf-8").splitlines() if l.startswith("- [ ] T24-"))
despues_hechas = sum(1 for l in out.decode("utf-8").splitlines() if l.startswith("- [x] T24-"))
print("cambios=%d  [ ] %d->%d  [x] %d->%d  EOL=%s" % (
    cambios, antes_vacias, despues_vacias, antes_hechas, despues_hechas, repr(eol)))
