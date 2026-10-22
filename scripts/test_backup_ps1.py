#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: Propietaria
#
# M107-Backups / item 33 de la COLA ACTIVA de DeepSeek-V4.1-Flash
# "9 pendientes" -> medido: 167 [x] / 0 [ ] / 9 [?] = 176, y 4 de esos [?]
# son "no verificable headless: no hay disco externo".
#
# DeepSeek-V4.1-Flash (WorkBuddy) - 2026-10-22
#
# Suite de los 4 scripts PowerShell de `scripts/backup/` (M107).
#
#   python scripts/test_backup_ps1.py
#
# POR QUE EXISTE
# --------------
# `backup_local.ps1` (222 lineas), `verify_backups.ps1` (103), `restore_backup.ps1`
# (143) y `register_task.ps1` son el unico entregable de codigo del modulo que NO
# tenia ninguna prueba: `grep -rn "\.ps1" scripts/test_*.py` = 0 referencias, y
# `quality.yml` solo ejecuta suites .gd y .py. La verificacion de disco externo
# (backup_local.ps1 L111-119) SI esta implementada; lo que faltaba era un banco
# que la ejercite con un destino FICTICIO, sin depender del hardware.
#
# QUE CONGELA (y que NO)
# ----------------------
# NO congela rutas absolutas de esta maquina (D:\Backups...): todo corre sobre
# fixtures en un temporal. Congela el CONTRATO de los scripts:
#   - exit codes (0 exito / 1 error de backup / 1 corrupto / 2 error de verify)
#   - el checksum registrado es el sha256 REAL del .tar.gz (recalculado en Python)
#   - las exclusiones de compresion se aplican de verdad (no viajan en el tar)
#   - la retencion poda archivo + .sha256 + entrada de checksums.txt
#   - la unidad de destino ausente aborta ANTES de escribir nada (item L91)
#   - restore verifica el checksum ANTES de extraer y no restaura un backup corrupto
#   - el round-trip backup -> restore devuelve el contenido byte-exacto
#
# AGENTS.md 28: UTF-8 sin BOM, LF.

import hashlib
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import unicodedata
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DIR_SCRIPTS = RAIZ / "scripts" / "backup"
BACKUP_LOCAL = DIR_SCRIPTS / "backup_local.ps1"
VERIFY = DIR_SCRIPTS / "verify_backups.ps1"
RESTORE = DIR_SCRIPTS / "restore_backup.ps1"

PASS = 0
FAIL = 0

# Piso MEDIDO en verde (no estimado). Se re-mide al crecer la suite.
# 2026-10-22: 49 checks medidos (49/0/EXIT 0 x3 corridas).
CHECKS_MINIMOS = 49

BLOQUES_ESPERADOS = ["A", "B", "C", "D", "E", "F", "G", "H"]
_bloques_corridos = set()

SENTINEL = "SENTINEL-M107-2026-10-22\n"


# ── utilidades ────────────────────────────────────────────────────────────────

def _check(cond, nombre, detalle=""):
    global PASS, FAIL
    if cond:
        PASS += 1
        print("  [OK]    " + nombre)
    else:
        FAIL += 1
        extra = ""
        if detalle not in ("", None):
            extra = "  ->  " + str(detalle)
        print("  [FALLO] " + nombre + extra)


def _bloque(nombre, titulo):
    _bloques_corridos.add(nombre)
    print("\n== Bloque %s: %s ==" % (nombre, titulo))


def _decodificar(b):
    """PS 5.1 mezcla codepages: decodificar LINEA por linea, no el buffer entero.

    Con el buffer entero, una sola linea no-UTF8 arrastraba TODO a cp850 y un
    "i" acentuada quedaba como "a" + guion blando (medido 2026-10-22).
    """
    if not b:
        return ""
    trozos = []
    for linea in b.splitlines(keepends=True):
        for enc in ("utf-8", "cp850", "cp1252", "latin-1"):
            try:
                trozos.append(linea.decode(enc))
                break
            except UnicodeDecodeError:
                continue
        else:
            trozos.append(linea.decode("utf-8", "replace"))
    return "".join(trozos)


def _plano(txt):
    """minusculas ASCII sin acentos: matchear mensajes sin depender de la codepage."""
    sin = unicodedata.normalize("NFKD", txt or "")
    sin = "".join(c for c in sin if not unicodedata.combining(c))
    return sin.lower()


def _path_limpio():
    """PATH de una sesion Windows normal (Task Scheduler / Explorer).

    El PATH heredado de un shell Git/MSYS trae un GNU tar delante; correr la
    suite con ESE PATH mediria otra cosa. El bloque H lo prueba aparte.
    """
    sr = os.environ.get("SystemRoot", r"C:\Windows")
    cand = [str(Path(sr) / "System32"), sr,
            str(Path(sr) / "System32" / "WindowsPowerShell" / "v1.0"),
            str(Path(sr) / "System32" / "Wbem")]
    return ";".join(p for p in cand if Path(p).is_dir())


def ps(script, *args, **kw):
    """Ejecuta un .ps1 con la politica de ejecucion de la maquina (sin Bypass)."""
    timeout = kw.pop("timeout", 300)
    env_path = kw.pop("env_path", None)
    cmd = ["powershell.exe", "-NoProfile", "-NonInteractive", "-File", str(script)]
    cmd += [str(a) for a in args]
    env = os.environ.copy()
    env["PATH"] = env_path if env_path is not None else _path_limpio()
    p = subprocess.run(cmd, cwd=str(RAIZ), capture_output=True, timeout=timeout, env=env)
    return p.returncode, _decodificar(p.stdout) + _decodificar(p.stderr)


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for trozo in iter(lambda: fh.read(65536), b""):
            h.update(trozo)
    return h.hexdigest().upper()


def _backups(dest, patron="backup_*.tar.gz"):
    return sorted(p for p in Path(dest).glob(patron) if p.is_file())


def _lineas_checksums(path):
    if not Path(path).exists():
        return []
    out = []
    for linea in Path(path).read_text(encoding="ascii", errors="replace").splitlines():
        linea = linea.strip()
        if not linea:
            continue
        partes = linea.split(None, 1)
        if len(partes) == 2:
            out.append((partes[0], partes[1].strip()))
    return out


def _crear_fixture(base):
    """Proyecto falso con la MISMA forma que espera backup_local.ps1."""
    proj = Path(base) / "juego-isla-ancestral"
    (proj / "game" / "isla-ancestral" / "data").mkdir(parents=True)
    (proj / "game" / "isla-ancestral" / ".godot").mkdir(parents=True)
    (proj / "build").mkdir(parents=True)
    (proj / "CHECKLIST-GLOBAL.md").write_text("# fixture M107\n", encoding="utf-8", newline="\n")
    (proj / "game" / "isla-ancestral" / "project.godot").write_text(
        'config_version=5\n\n[application]\n\nconfig/name="m107-fixture"\n',
        encoding="utf-8", newline="\n")
    (proj / "game" / "isla-ancestral" / "data" / "sentinel.txt").write_text(
        SENTINEL, encoding="utf-8", newline="\n")
    (proj / "game" / "isla-ancestral" / ".godot" / "cache.bin").write_bytes(b"X" * 1024)
    (proj / "build" / "junk.bin").write_bytes(b"J" * 1024)
    return proj


def _espacio_libre_gb(ruta):
    uso = shutil.disk_usage(str(ruta))
    return uso.free / (1024 ** 3)


# ── bloques ───────────────────────────────────────────────────────────────────

def bloque_a_backup_feliz(ctx):
    _bloque("A", "backup_local.ps1 — camino feliz (compresion, checksum, log)")
    proj, dest = ctx["proj"], ctx["dest"]
    rc, out = ps(BACKUP_LOCAL, "-SourcePath", proj, "-DestinationPath", dest)
    _check(rc == 0, "exit 0 en la primera corrida", "rc=%s salida=%s" % (rc, _plano(out)[-300:]))

    tars = _backups(dest)
    _check(len(tars) == 1, "crea exactamente 1 backup_*.tar.gz", "encontrados=%d" % len(tars))
    if not tars:
        return
    tar = tars[0]

    sidecar = Path(str(tar) + ".sha256")
    _check(sidecar.exists(), "escribe el sidecar .sha256 junto al backup")
    if sidecar.exists():
        texto = sidecar.read_text(encoding="ascii", errors="replace").strip()
        partes = texto.split()
        _check(len(partes) == 2 and len(partes[0]) == 64,
               "el sidecar tiene <64 hex> + nombre de archivo", texto[:90])

    checks = Path(dest) / "checksums.txt"
    entradas = _lineas_checksums(checks)
    _check(len(entradas) == 1, "checksums.txt tiene 1 entrada", "entradas=%d" % len(entradas))

    # el checksum registrado tiene que ser el sha256 REAL del archivo
    real = _sha256(tar)
    _check(bool(entradas) and entradas[0][0].upper() == real,
           "el hash de checksums.txt es el sha256 real del .tar.gz (recalculado en Python)",
           "registrado=%s real=%s" % (entradas[0][0] if entradas else "-", real))
    _check(bool(entradas) and entradas[0][1] == tar.name,
           "checksums.txt apunta al archivo recien creado",
           entradas[0][1] if entradas else "-")

    log = Path(dest) / "logs" / "backup.log"
    _check(log.exists() and "OK" in log.read_text(encoding="utf-8", errors="replace"),
           "registra la corrida en logs/backup.log con estado OK")
    _check("tar.exe resuelto" in out and "system32" in _plano(out),
           "declara que resolvio el bsdtar de System32 (no el tar del PATH)",
           _plano(out)[:160])

    with tarfile.open(str(tar), "r:gz") as tf:
        nombres = tf.getnames()
    _check(any(n.endswith("data/sentinel.txt") for n in nombres),
           "el tar contiene el archivo centinela del proyecto")
    _check(not any("/.godot/" in n for n in nombres),
           "excluye la cache de import game/isla-ancestral/.godot")
    _check(not any("/build/" in n or n.endswith("/build") for n in nombres),
           "excluye build/ (salidas regenerables)")


def bloque_b_retencion(ctx):
    _bloque("B", "backup_local.ps1 — retencion (archivo + .sha256 + checksums.txt)")
    proj, dest = ctx["proj"], ctx["dest"]
    rc2, _ = ps(BACKUP_LOCAL, "-SourcePath", proj, "-DestinationPath", dest)
    time.sleep(1.1)
    rc3, _ = ps(BACKUP_LOCAL, "-SourcePath", proj, "-DestinationPath", dest,
                "-RetentionCount", "2")
    _check(rc2 == 0 and rc3 == 0, "las corridas 2 y 3 salen con exit 0", "rc=%s,%s" % (rc2, rc3))

    tars = _backups(dest)
    _check(len(tars) == 2, "con -RetentionCount 2 quedan 2 backups (de 3)", "quedan=%d" % len(tars))

    entradas = _lineas_checksums(Path(dest) / "checksums.txt")
    _check(len(entradas) == 2, "checksums.txt se poda a 2 entradas", "entradas=%d" % len(entradas))

    nombres = {t.name for t in tars}
    _check(all(n in nombres for _, n in entradas),
           "no quedan entradas fantasma en checksums.txt (todas tienen archivo)",
           [n for _, n in entradas if n not in nombres])

    sidecars = sorted(Path(dest).glob("backup_*.tar.gz.sha256"))
    _check(len(sidecars) == 2, "los .sha256 huerfanos se podan con su backup",
           "sidecars=%d" % len(sidecars))


def bloque_c_mensual(ctx):
    _bloque("C", "backup_local.ps1 -Kind mensual")
    proj, dest = ctx["proj"], ctx["dest"]
    rc, out = ps(BACKUP_LOCAL, "-SourcePath", proj, "-DestinationPath", dest, "-Kind", "mensual")
    _check(rc == 0, "exit 0 con -Kind mensual", "rc=%s salida=%s" % (rc, _plano(out)[-300:]))

    mensual = Path(dest) / "mensual"
    snaps = _backups(mensual, "snapshot_*.tar.gz")
    _check(len(snaps) == 1, "crea 1 snapshot_*.tar.gz en <destino>/mensual", "encontrados=%d" % len(snaps))
    if snaps:
        import re as _re
        m = _re.match(r"^snapshot_(\d{4}-\d{2})\.tar\.gz$", snaps[0].name)
        _check(bool(m), "el snapshot lleva el mes en el nombre (AAAA-MM)", snaps[0].name)
        _check(len(_lineas_checksums(mensual / "checksums.txt")) == 1,
               "el checksums.txt mensual registra el snapshot")


def bloque_d_disco_externo(ctx):
    _bloque("D", "backup_local.ps1 — unidad de destino ausente (item L91) + sanity de origen")
    proj = ctx["proj"]
    dest_inexistente = Path(ctx["base"]) / "dest_inexistente"

    # Unidad inexistente: es exactamente el caso "disco externo desconectado".
    rc, out = ps(BACKUP_LOCAL, "-SourcePath", proj,
                 "-DestinationPath", "Q:\\Backups\\juego-isla-ancestral")
    plano = _plano(out)
    _check(rc == 1, "unidad inexistente (Q:) -> exit 1", "rc=%s" % rc)
    _check("no est" in plano and "disponible" in plano,
           "el error nombra la causa: la unidad no esta disponible", plano[-200:])
    _check("disco desconectado" in plano,
           "el mensaje identifica el escenario de disco desconectado", plano[-200:])

    # Sanity de origen: no es la raiz del proyecto -> aborta sin crear destino.
    vacio = Path(ctx["base"]) / "vacio"
    vacio.mkdir(exist_ok=True)
    rc2, out2 = ps(BACKUP_LOCAL, "-SourcePath", vacio, "-DestinationPath", dest_inexistente)
    _check(rc2 == 1, "un SourcePath que no es la raiz del proyecto -> exit 1", "rc=%s" % rc2)
    # Sin acentos en la asercion: la codepage OEM de PS 5.1 manglea la "i" de
    # "raiz" y el check no debe depender de eso (medido 2026-10-22).
    plano2 = _plano(out2)
    _check("no parece la ra" in plano2 and "del proyecto" in plano2
           and "faltan checklist-global.md" in plano2,
           "el error nombra el motivo (falta CHECKLIST-GLOBAL.md / project.godot)",
           plano2[-220:])
    _check(not _backups(dest_inexistente),
           "la corrida fallida no deja ningun backup en el destino")


def bloque_e_verify(ctx):
    _bloque("E", "verify_backups.ps1 — OK / CORRUPTO / FALTANTE / errores de uso")
    dest = Path(ctx["dest"])

    rc, out = ps(VERIFY, "-BackupDir", dest)
    plano = _plano(out)
    _check(rc == 0, "un destino intacto -> exit 0", "rc=%s" % rc)
    _check("0 corruptos" in plano and "0 faltantes" in plano,
           "el resumen reporta 0 corruptos / 0 faltantes", plano[-200:])
    _check((dest / "logs" / "verify.log").exists(), "deja constancia en logs/verify.log")

    # CORRUPTO: se altera un byte del backup ya registrado.
    tar = _backups(dest)[0]
    original = tar.read_bytes()
    tar.write_bytes(original[:-8] + b"CORRUPTO")
    rc2, out2 = ps(VERIFY, "-BackupDir", dest)
    _check(rc2 == 1, "un backup alterado -> exit 1", "rc=%s" % rc2)
    _check("[CORRUPTO" in out2, "nombra el archivo como [CORRUPTO]")
    tar.write_bytes(original)

    # FALTANTE: se borra un backup que sigue listado en checksums.txt.
    tar.unlink()
    rc3, out3 = ps(VERIFY, "-BackupDir", dest)
    _check(rc3 == 1, "un backup borrado pero listado -> exit 1", "rc=%s" % rc3)
    _check("[FALTANTE" in out3, "nombra el archivo como [FALTANTE]")
    tar.write_bytes(original)

    # Errores de uso: exit 2 (distinto de 1 = "hay defectos en los datos").
    rc4, _ = ps(VERIFY, "-BackupDir", Path(ctx["base"]) / "no_existe")
    _check(rc4 == 2, "un directorio inexistente -> exit 2 (error de ejecucion)", "rc=%s" % rc4)

    sin_checks = Path(ctx["base"]) / "dest_sin_checksums"
    sin_checks.mkdir(exist_ok=True)
    rc5, _ = ps(VERIFY, "-BackupDir", sin_checks)
    _check(rc5 == 2, "un destino sin checksums.txt -> exit 2", "rc=%s" % rc5)


def bloque_f_restore(ctx):
    _bloque("F", "restore_backup.ps1 — verificacion previa + round-trip byte-exacto")
    dest = Path(ctx["dest"])
    tar = _backups(dest)[0]
    restore_dir = Path(ctx["base"]) / "restaurado"

    rc, out = ps(RESTORE, "-BackupFile", tar, "-DestinationPath", restore_dir)
    plano = _plano(out)
    _check(rc == 0, "restore de un backup integro -> exit 0", "rc=%s" % rc)
    _check("checksum verificado" in plano, "verifica el checksum antes de extraer", plano[-250:])

    restaurado = restore_dir / "juego-isla-ancestral" / "game" / "isla-ancestral" / "data" / "sentinel.txt"
    contenido = restaurado.read_text(encoding="utf-8") if restaurado.exists() else None
    _check(contenido == SENTINEL, "el centinela restaurado es byte-exacto", repr(contenido))

    log = dest / "logs" / "restore.log"
    _check(log.exists() and "RESTAURADO" in log.read_text(encoding="utf-8", errors="replace"),
           "deja constancia en logs/restore.log")

    # Un backup corrupto NO se restaura (el checksum se verifica ANTES de extraer).
    original = tar.read_bytes()
    tar.write_bytes(original[:-8] + b"CORRUPTO")
    restore_malo = Path(ctx["base"]) / "restaurado_malo"
    rc2, out2 = ps(RESTORE, "-BackupFile", tar, "-DestinationPath", restore_malo)
    _check(rc2 == 1, "un backup corrupto -> exit 1 (aborta la restauracion)", "rc=%s" % rc2)
    _check("checksum no coincide" in _plano(out2),
           "el error dice que el checksum no coincide", _plano(out2)[-200:])
    _check(not (restore_malo / "juego-isla-ancestral").exists(),
           "no extrae nada cuando el checksum no coincide")
    tar.write_bytes(original)


def bloque_g_coherencia(ctx):
    _bloque("G", "coherencia entre los dos registros de checksums")
    dest = Path(ctx["dest"])
    entradas = dict((n, h.upper()) for h, n in _lineas_checksums(dest / "checksums.txt"))
    coherentes = 0
    for tar in _backups(dest):
        side = Path(str(tar) + ".sha256")
        if not side.exists():
            continue
        side_hash = side.read_text(encoding="ascii", errors="replace").split()[0].upper()
        if entradas.get(tar.name) == side_hash == _sha256(tar):
            coherentes += 1
    total = len(_backups(dest))
    _check(total > 0 and coherentes == total,
           "sidecar .sha256 == checksums.txt == sha256 real, en todos los backups",
           "coherentes=%d/%d" % (coherentes, total))


def bloque_h_path_hostil(ctx):
    _bloque("H", "PATH hostil (GNU tar delante) — la resolucion explicita de bsdtar")
    proj = ctx["proj"]
    gnu = shutil.which("tar.exe") or ""
    hostil = str(Path(gnu).parent) if gnu else ""
    dest = Path(ctx["base"]) / "dest_hostil"
    dest.mkdir(parents=True, exist_ok=True)

    # Control de causa raiz: con la MISMA invocacion, el tar que gana en este
    # PATH falla si es GNU (interpreta "C:\..." como host:ruta remota).
    control = dest / "control.tar.gz"
    p = subprocess.run([gnu, "-czf", str(control), "-C", str(proj.parent), proj.name],
                       capture_output=True, timeout=120) if gnu else None
    es_gnu = bool(gnu) and "system32" not in gnu.lower()
    if es_gnu:
        _check(p.returncode != 0,
               "control: el GNU tar del PATH falla con la misma invocacion (causa raiz)",
               "rc=%s tar=%s" % (p.returncode, gnu))
    else:
        _check(p is not None and p.returncode == 0,
               "control: el tar del PATH comprime bien (no hay GNU tar que reproduzca la trampa)",
               gnu)

    env_path = (hostil + ";" if hostil else "") + _path_limpio()
    rc, out = ps(BACKUP_LOCAL, "-SourcePath", proj, "-DestinationPath", dest, env_path=env_path)
    _check(rc == 0, "con ese PATH el backup igual sale exit 0 (bsdtar resuelto)",
           "rc=%s salida=%s" % (rc, _plano(out)[-260:]))

    tars = _backups(dest)
    _check(len(tars) == 1, "y produce 1 backup valido", "encontrados=%d" % len(tars))
    if tars:
        try:
            with tarfile.open(str(tars[0]), "r:gz") as tf:
                ok = any(n.endswith("data/sentinel.txt") for n in tf.getnames())
        except Exception as exc:
            ok = False
        _check(ok, "el .tar.gz resultante se abre y contiene el centinela", "tar=%s" % tars[0].name)
    _check("system32" in _plano(out) and "portablegit" not in _plano(out),
           "no uso el tar de Git/PortableGit aunque estaba primero en el PATH",
           _plano(out)[:160])


# ── runner ────────────────────────────────────────────────────────────────────

def main():
    global FAIL
    print("Suite M107 — scripts PowerShell de scripts/backup/")
    print("Python %s | %s" % (sys.version.split()[0], RAIZ))

    faltantes = [p.name for p in (BACKUP_LOCAL, VERIFY, RESTORE) if not p.is_file()]
    if faltantes:
        print("[FALLO] faltan scripts en disco: %s" % ", ".join(faltantes))
        return 1

    base = Path(tempfile.mkdtemp(prefix="m107_ps1_"))
    ctx = {"base": base, "dest": base / "dest"}
    try:
        libre = _espacio_libre_gb(base)
        print("temporal: %s (%.1f GB libres)" % (base, libre))
        if libre < 6.0:
            print("[FALLO] menos de 6 GB libres: backup_local.ps1 exige 5 GB y abortaria")
            return 1
        ctx["proj"] = _crear_fixture(base)
        ctx["dest"].mkdir(parents=True, exist_ok=True)

        for nombre, fn in (("A", bloque_a_backup_feliz), ("B", bloque_b_retencion),
                           ("C", bloque_c_mensual), ("D", bloque_d_disco_externo),
                           ("E", bloque_e_verify), ("F", bloque_f_restore),
                           ("G", bloque_g_coherencia), ("H", bloque_h_path_hostil)):
            try:
                fn(ctx)
            except Exception as exc:  # un bloque que revienta NO puede pasar en verde
                _check(False, "bloque %s termino sin excepcion" % nombre,
                       "%s: %s" % (type(exc).__name__, exc))
    finally:
        if os.environ.get("M107_KEEP") != "1":
            shutil.rmtree(str(base), ignore_errors=True)

    for nombre in BLOQUES_ESPERADOS:
        if nombre not in _bloques_corridos:
            _check(False, "el bloque %s se ejecuto" % nombre)

    ejecutados = PASS + FAIL
    print("\n%s" % ("-" * 62))
    if CHECKS_MINIMOS and ejecutados < CHECKS_MINIMOS:
        FAIL += 1
        print("[FALLO] solo %d checks ejecutados (minimo %d)" % (ejecutados, CHECKS_MINIMOS))
    print("%d checks / %d fallos / EXIT %d" % (ejecutados, FAIL, 0 if FAIL == 0 else 1))
    return 0 if FAIL == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
