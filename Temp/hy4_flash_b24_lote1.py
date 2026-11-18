from pathlib import Path

REPO = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")
P = REPO / "DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/24-Backlog-Bug-RootCause-Remaining.md"

b = P.read_bytes()
assert not b.startswith(b"\xef\xbb\xbf")
eol = "\r\n" if b.count(b"\r\n") > 0 else "\n"
t = b.decode("utf-8")
assert t.count("- [ ] T24-") == 122

diag = {
 "T24-01": "BUG-032 CAUSA: aserciones `cantidad_cadenas()==11` frente a catalogo de 25 (false-red). HOY el test .gd NO existe (queda .uid huerfano y copia en `scripts/localizacion/Obsoletos/` por BUG-104). Cita de ruta STALE. CONFIDENCIA ALTA",
 "T24-02": "BUG-033 CAUSA: aserciones de igualdad `elementos==5`/`politicas==2` frente a catalogo 7/5. Resuelto: `test_copyright_m127.gd:15` documenta el drift y L102-104 usa `n_elem >= MIN_ELEMENTOS` (piso, no igualdad). CONFIDENCIA ALTA",
 "T24-03": "BUG-034 CAUSA: regeneracion concurrente de CHECKLIST-GLOBAL borra sellos. Mitigado: `CHECKLIST-QA-SEALS.md` existe (fila M114 en L62). Riesgo VIVO: re-medido hoy quedan 8 drifts >5 en GLOBAL. CONFIDENCIA ALTA",
 "T24-04": "BUG-035 CAUSA: `DirAccess.new()` (clase abstracta) caia el autoload BackupManager entero. Resuelto: `backup_manager.gd` 0 `DirAccess.new`, 3 `globalize_path`, `cantidad_backups()` en L353. CONFIDENCIA ALTA",
 "T24-05": "BUG-036 CAUSA: API Godot 4.7 elimino `PackedByteArray.hash()` y el constructor `String(int)`. Resuelto: `license_validator.gd:145` usa `str(hash(data))`. CONFIDENCIA ALTA",
 "T24-06": "BUG-037 CAUSA: `:=` sobre devoluciones Variant + APIs eliminadas (ZIPPacker.finish_file, DirAccess.open('user://')). Resuelto: `test_debug_menu_headless.gd` solo usa `:=` sobre constructores concretos (L36/L39), 0 `ZIPPacker`/`finish_file`. CONFIDENCIA ALTA",
 "T24-07": "BUG-038 CAUSA: BOM EF BB BF en checklists M54/M84. Verificado por bytes HOY: ambos sin BOM (0). CONFIDENCIA ALTA",
 "T24-08": "BUG-039 CAUSA: generador reescribia desde plantilla (10 columnas vs 11, fin de tabla malo, LF->CRLF). Resuelto: `generar_checklist_global.py:248` `leer_estructura_existente()` y L621 `newline=salto`. CONFIDENCIA ALTA",
 "T24-09": "BUG-040 CAUSA: desajuste de arity (senal 3 args, handler 2). Resuelto: `inventory_layer.gd:406` `_on_inv_changed(_item_id, _cantidad, _container)` con 3 parametros. CONFIDENCIA ALTA",
 "T24-10": "BUG-041 CAUSA: falso positivo - `categories_enabled` se puebla en `_load_config` (logger.gd:129-136) y `log_buffer` era codigo muerto. HOY el archivo se llama `scripts/logging/logger.gd` (cita STALE); L16 documenta la eliminacion de `log_buffer`. CONFIDENCIA ALTA",
}

lines = t.split(eol)
out = []
for line in lines:
    if line.startswith("- [ ] T24-"):
        tid = line.split(":", 1)[0].replace("- [ ] ", "")
        if tid in diag:
            line = line.replace("- [ ] ", "- [x] ", 1) + " — " + diag[tid]
    out.append(line)
res = eol.join(out)
assert res.count("- [x] T24-") == 10 and res.count("- [ ] T24-") == 112

res += eol + eol + "## Lote 1 cerrado (HY4 Flash, 2026-11-18)" + eol + eol
res += "- **10/10 diagnosticados** contra codigo vivo (no copiados del registro): 8 resueltos, 1 mitigado con riesgo vivo (BUG-034), 1 falso positivo confirmado (BUG-041)." + eol
res += "- **2 citas STALE detectadas:** BUG-032 (test .gd ausente, movido a Obsoletos por BUG-104) y BUG-041 (archivo renombrado a `scripts/logging/logger.gd`). Reportado al director." + eol
res += "- 10/10 CONFIDENCIA ALTA (evidencia file:line o bytes). Sin arreglos de codigo: nicho = diagnosticar sin arreglar." + eol
res += eol + "**Firma:** hy4-flash" + eol

P.write_bytes(res.encode("utf-8"))
b2 = P.read_bytes()
assert not b2.startswith(b"\xef\xbb\xbf") and (b2.count(b"\r\n") > 0) == (eol == "\r\n")
assert b2.decode("utf-8").count("- [x] T24-") == 10
print("OK backlog 24 lote 1: 10/10 | bytes", len(b), "->", len(b2), "| EOL", repr(eol))
