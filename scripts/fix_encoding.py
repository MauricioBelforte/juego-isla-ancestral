#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fix_encoding.py - Saneamiento de codificacion de archivos de texto.

Detecta y corrige dos formas de corruption por codificacion:
  1) Archivos guardados en cp1252/ANSI (single): no decodifican como UTF-8.
  2) Archivos doble-codificados (UTF-8 -> cp1252 -> UTF-8): decodifican como
     UTF-8 pero muestran mojibake ('a' => 'A~1', emojis rotos, etc.).

Uso:
  python fix_encoding.py --dry-run     # solo informa, no escribe
  python fix_encoding.py               # aplica correcciones (con backup)
  python fix_encoding.py --no-backup   # aplica sin respaldos
"""
import os
import re
import sys
import shutil
import datetime

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKUP_ROOT = os.path.join(ROOT, "Obsoletos",
                           "encoding-backup-" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))

TEXT_EXTS = {".md", ".txt", ".py", ".gd", ".cs", ".json", ".tscn", ".tres",
             ".cfg", ".csv", ".yml", ".yaml", ".ini", ".sh", ".bat", ".html",
             ".css", ".js", ".ts", ".gdns", ".gdn", ".import"}

# Carpetas excluidas del escaneo.
EXCLUDE_DIRS = {".git", "Library", "Temp", "obj", ".godot", "capturas",
                "node_modules", "Obsoletos", "Logs", ".import", "__pycache__",
                ".venv"}

# Exclusion SOLO en la raiz del repo. Antes esta lista se aplicaba por nombre
# de directorio en cualquier profundidad, y eso dejaba fuera
# game/isla-ancestral/scripts/ (el CODIGO DEL JUEGO) por llamarse igual que el
# scripts/ de la raiz. Resultado: los .gd con mojibake nunca se reparaban.
EXCLUDE_DIRS_ROOT = {"scripts"}  # scripts/ de la raiz: literales intencionales

# Archivos excluidos explicitamente (contienen ejemplos intencionales de mojibake).
EXCLUDE_FILES = {"AGENTS.md"}

def has_mojibake(s: str) -> bool:
    # Marcadores fiable de corruption cp1252->UTF-8 en texto espanol:
    #  - 'A~' (U+00C3) lidera TODOS los acentos corruptos (a -> A~A!) etc.
    #  - 'aEUR' (U+00E2 U+20AC) lidera signos/puntuacion (em dash, comillas, ...).
    #  - 'A' (U+00C2) suele venir de nbsp (U+00A0 -> A + nbsp) o A yen.
    #  - 'o' (U+00F0) lidera emojis corruptos.
    # NO se incluye 'Ñ' (U+00D1) porque es caracter legitimo del espanol.
    if "Ã" in s:
        return True
    if "â" in s:
        return True
    if "Â " in s or "Â\u00a0" in s:
        return True
    if "ð" in s:
        return True
    return False


# Detector ESTRICTO (Log 852). El de arriba es laxo y falla por los dos lados:
#   - FALSO NEGATIVO: solo reconoce 'Â' seguido de ESPACIO o nbsp, asi que
#     'Â§' (seccion) o 'Â°' (grado) se le escapaban y quedaban sin reparar.
#   - FALSO POSITIVO: salta con la sola presencia de 'â', y eso marcaba como
#     corruptos archivos de localizacion en portugues ('âmbito', 'você') que
#     estan perfectos.
# Este exige que el caracter sospechoso vaya SEGUIDO de su byte de
# continuacion, y por eso acierta en los dos casos.
_MOJI_RE = re.compile(
    "\u00c3[\u0080-\u00bf]"      # A-tilde + continuacion  (acentos)
    "|\u00c2[\u0080-\u00bf]"     # A-circunflejo + cont.   (§, °, ·, nbsp)
    "|\u00e2\u20ac"              # raya y comillas tipograficas
    "|\u00e2[\u0080-\u0093]"     # flechas y comillas bajas
    "|\u00f0"                    # emoji
)


def has_mojibake(s: str) -> bool:
    """Redefinicion estricta: anula la version laxa de arriba (ver Log 852)."""
    return bool(_MOJI_RE.search(s))


def _sloppy_bytes(r: str):
    """cp1252 tolerante: acepta los 5 bytes que cp1252 NO define.

    0x81, 0x8D, 0x8F, 0x90 y 0x9D no existen en cp1252 y Python los rechaza,
    pero en una cadena real de doble/triple codificacion SI aparecen (llegan
    como caracteres de control C1). Mapearlos a su mismo valor es lo que
    permite revertir el mojibake MULTIPLE.
    """
    out = bytearray()
    for ch in r:
        o = ord(ch)
        if o < 0x100:
            out.append(o)
            continue
        try:
            out.extend(ch.encode("cp1252"))
        except UnicodeEncodeError:
            return None
    return bytes(out)


def _fix_line(line: str):
    """Repara una sola linea preservando emojis (fuera de cp1252)."""
    out = []
    run = []

    def flush():
        if not run:
            return
        r = "".join(run)
        run.clear()
        # Solo intentamos reparar tramos que realmente contienen mojibake.
        if not has_mojibake(r):
            out.append(r)
            return
        for codec in ("cp1252", "latin-1"):
            try:
                out.append(r.encode(codec).decode("utf-8"))
                return
            except (UnicodeEncodeError, UnicodeDecodeError):
                continue
        # Tercer intento: cp1252 tolerante (ver _sloppy_bytes). Sin esto el
        # mojibake multiple (doble/triple codificacion) queda irrevertible.
        b = _sloppy_bytes(r)
        if b is not None:
            try:
                out.append(b.decode("utf-8"))
                return
            except UnicodeDecodeError:
                pass
        # Ultimo recurso: re-decificar con reemplazo para no dejar 'A~' sin tratar.
        # NUNCA usar errors="replace" aqui: ese fallback fue el que CREO los
        # U+FFFD irreversibles que el Log 507 declara irrecuperables. Un run
        # que no round-trippea es texto LEGITIMO (p. ej. portugues "você",
        # español "diseño", frances "â"): se deja intacto, no se adivina.
        out.append(r)

    for ch in line:
        # Pertenecen al tramo los chars < 0x100 (incluidos los de control C1
        # como U+009D, que son PARTE de una secuencia mojibake) y los que
        # cp1252 representa en un byte (p. ej. el euro). Antes se usaba solo
        # encode("cp1252"), que rechaza los C1 y PARTIA el token por la mitad:
        # por eso el mojibake triple quedaba irrevertible.
        if ord(ch) < 0x100:
            run.append(ch)
            continue
        try:
            ch.encode("cp1252")
            run.append(ch)
        except UnicodeEncodeError:
            flush()
            out.append(ch)
    flush()
    return "".join(out)


def try_fix_mojibake(s: str):
    """Reverte doble-codificacion cp1252/latin-1->UTF-8 preservando emojis.

    Se procesa linea por linea para evitar que caracteres fuera de cp1252
    (p.ej. 's' con caron) fusionen tramos de lineas distintas y rompan el
    round-trip. Dentro de cada linea se divide en runs de chars codificables a
    cp1252 (la parte corrupta) y el resto (emojis); solo los runs se someten a
    round-trip cp1252->UTF-8 (con fallback latin-1 para bytes indefinidos en
    cp1252). Los chars correctos que no forman UTF-8 valido al re-codificar se
    conservan.
    """
    lines = s.split("\n")
    fixed_lines = [_fix_line(ln) for ln in lines]
    return "\n".join(fixed_lines), "per-run"


def classify(raw: bytes):
    """Devuelve ('ok'|'cp1252'|'mojibake'|'mixed'|'binary', new_bytes_or_None, note)."""
    # ¿Binario?
    if b"\x00" in raw[:min(len(raw), 8192)] and len(raw) > 0:
        # muestreo simple
        sample = raw[:min(len(raw), 8192)]
        if sample.count(b"\x00") > max(1, len(sample) // 200):
            return "binary", None, "binario"
    # ¿UTF-8 valido?
    try:
        s = raw.decode("utf-8")
    except UnicodeDecodeError:
        # No es UTF-8 -> cp1252 single (o similar)
        try:
            s2 = raw.decode("cp1252")
        except UnicodeDecodeError:
            return "binary", None, "no decodificable"
        return "cp1252", s2.encode("utf-8"), "cp1252->utf8"
    # UTF-8 valido: ¿tiene BOM?
    if s and s[0] == "\ufeff":
        s = s[1:]
    # ¿Mojibake?
    if has_mojibake(s):
        fixed, method = try_fix_mojibake(s)
        if fixed is not None and fixed != s:
            # El mojibake puede estar aplicado VARIAS veces (doble, triple...).
            # Se itera mientras cada pasada siga limpiando algo.
            mejor, pases = fixed, 1
            while has_mojibake(mejor) and pases < 6:
                sig, _ = try_fix_mojibake(mejor)
                if sig is None or sig == mejor:
                    break
                mejor, pases = sig, pases + 1
            if not has_mojibake(mejor):
                return ("mojibake", mejor.encode("utf-8"),
                        "mojibake->%s(%dpass)" % (method, pases))
            # mejoro pero queda algo: aplicar una segunda pasada por si acaso
            fixed2, _ = try_fix_mojibake(fixed)
            if not has_mojibake(fixed2):
                return "mojibake", fixed2.encode("utf-8"), "mojibake->" + method + "(2pass)"
            return ("mojibake", mejor.encode("utf-8"),
                    "mojibake(parcial)->%s(%dpass)" % (method, pases))
        return "mojibake-fail", None, "mojibake irrevertible"
    return "ok", None, "utf-8 ok"


def iter_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        # podar directorios excluidos
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS
                       and not d.startswith(".git")]
        if os.path.abspath(dirpath) == os.path.abspath(ROOT):
            dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS_ROOT]
        for fn in filenames:
            ext = os.path.splitext(fn)[1].lower()
            if ext not in TEXT_EXTS:
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, ROOT)
            if rel.replace("\\", "/") in EXCLUDE_FILES:
                continue
            if os.path.basename(full) in EXCLUDE_FILES:
                continue
            yield full


def main():
    dry = "--dry-run" in sys.argv
    no_backup = "--no-backup" in sys.argv
    stats = {}
    changed = []
    print("=== fix_encoding ===")
    print("ROOT:", ROOT)
    print("DRY-RUN:", dry, "| NO-BACKUP:", no_backup)
    print("-" * 60)
    for full in iter_files():
        try:
            with open(full, "rb") as f:
                raw = f.read()
        except Exception as e:
            print("  [ERR lectura] %s -> %s" % (full, e))
            continue
        kind, new, note = classify(raw)
        stats[kind] = stats.get(kind, 0) + 1
        if kind in ("cp1252", "mojibake", "mojibake-fail") or (kind == "mojibake" and new):
            rel = os.path.relpath(full, ROOT)
            changed.append((rel, kind, note))
            if not dry:
                if new is None:
                    print("  [SKIP] %s -> classify devolvio None" % rel)
                    continue
                try:
                    antes = raw.decode("utf-8")
                except UnicodeDecodeError:
                    antes = ""
                # OJO: un U+FFFD puede venir DISFRAZADO como la secuencia de 3
                # chars que produce mojibakear U+FFFD. Esos no son dano nuevo:
                # son dano previo que la reparacion se limita a dejar a la
                # vista. Solo se aborta si aparecen U+FFFD que NO estaban ya
                # camuflados en el original.
                camuflados = antes.count("\u00ef\u00bf\u00bd")
                fffd_antes = antes.count("\ufffd")
                fffd_despues = new.decode("utf-8", "replace").count("\ufffd")
                if fffd_despues > fffd_antes + camuflados:
                    print("  [SKIP] %s -> ganaria %d U+FFFD, se aborta"
                          % (rel, fffd_despues - fffd_antes))
                    continue
                if not no_backup:
                    relp = os.path.relpath(full, ROOT)
                    bp = os.path.join(BACKUP_ROOT, relp)
                    os.makedirs(os.path.dirname(bp), exist_ok=True)
                    shutil.copy2(full, bp)
                with open(full, "wb") as f:
                    f.write(new)
    print("Resumen por categoria:")
    for k, v in sorted(stats.items()):
        print("  %-16s %d" % (k, v))
    print("-" * 60)
    print("Archivos a corregir (%d):" % len(changed))
    for rel, kind, note in changed:
        print("  [%s] %s  (%s)" % (kind, rel, note))
    if dry:
        print("\n(DRY-RUN: no se escribio ningun archivo)")


if __name__ == "__main__":
    main()
