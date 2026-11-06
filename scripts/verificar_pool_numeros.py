# -*- coding: utf-8 -*-
r"""v2 de verificar_pool_numeros.py — inventario tolerante a long-path.

Cambios respecto de la v1 (dos, ambos de exactitud, ninguno de criterio):
  1. INVENTARIO: os.walk + stat con prefijo \\?\ en vez de Path.rglob/is_file.
     En Windows sin long-path habilitado, rglob NO ve los mensajes con ruta > 260
     chars (los "fantasmas NTFS"): los cuenta como huecos y ademas no detecta un
     numero usado que siga en el pool.
  2. DETECTOR: acepta hora HH-MM ademas de HH-MM-SS (misma regex que
     renumerar_canal.py v2 y saneo de pools), para no ignorar mensajes validos.

Todo lo demas es identico: mismos fails, mismos umbrales, mismo exit code.
"""
import io, os, re, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MM = ROOT / "Mensajes entre modelos"
LOGS = ROOT / "Logs"
CANALES = ["atria-dawn-s2", "DeepSeek-V4.1-Flash", "Hy3", "agnes-3-flash",
           "kimi-k3", "mimo-v2.6-flash-free", "space-bunny-alpha"]

NUM = re.compile(r"^(\d+)-")
MENSAJE_RE = re.compile(r"^\d+-\d{4}-\d{2}-\d{2}_\d{2}-\d{2}(?:-\d{2})?-")
FECHA_PRIMERO = re.compile(r"^\d{4}-\d{2}-\d{2}_")

fails = []


def lp(p):
    """Ruta absoluta con prefijo long-path en Windows."""
    p = os.path.abspath(str(p))
    if os.name != "nt" or p.startswith("\\\\?\\"):
        return p
    return "\\\\?\\" + p


def leer_sano(path):
    """Devuelve (set de numeros, ok). Marca fallo si hay BOM o CR."""
    if not path.is_file():
        fails.append(f"pool inexistente: {path.relative_to(ROOT)}")
        return set(), False
    raw = path.read_bytes()
    if raw[:3] == b"\xef\xbb\xbf":
        fails.append(f"BOM en {path.relative_to(ROOT)}")
    if b"\r" in raw:
        fails.append(f"CRLF/CR en {path.relative_to(ROOT)} (debe ser LF puro)")
    out = set()
    for ln in raw.decode("utf-8", errors="replace").replace("\r\n", "\n").split("\n"):
        ln = ln.strip()
        if ln.isdigit():
            out.add(int(ln))
    return out, True


def inventario(d):
    """Recorre todas las subcarpetas; devuelve (numeros usados, ilegibles, total)."""
    usados, ilegibles, total = set(), [], 0
    for raiz, _dirs, files in os.walk(d):
        for f in files:
            if not MENSAJE_RE.match(f):
                continue
            ruta = os.path.join(raiz, f)
            try:
                os.stat(lp(ruta))
            except OSError as ex:
                ilegibles.append(f"{os.path.relpath(ruta, d)} ({ex.__class__.__name__})")
                continue
            m = NUM.match(f)
            if m:
                usados.add(int(m.group(1)))
                total += 1
    return usados, ilegibles, total


# --- pool global (logs) ---
pool_logs, _ = leer_sano(LOGS / "NUMEROS_DISPONIBLES.txt")
logs_usados = set()
for p in LOGS.glob("*.md"):
    m = NUM.match(p.name)
    if m:
        logs_usados.add(int(m.group(1)))
fuga = pool_logs & logs_usados
if fuga:
    fails.append(f"log(s) ya creado(s) pero su numero sigue en el pool global: {sorted(fuga)}")
# correlatividad: el pool global debe arrancar justo despues del ultimo log existente
# (los huecos antiguos no se reutilizan, T-16)
if logs_usados and pool_logs:
    mx = max(logs_usados)
    if min(pool_logs) != mx + 1:
        fails.append(f"pool global no es correlativo: arranca en {min(pool_logs)} "
                     f"pero el ultimo log es {mx} (deberia arrancar en {mx + 1})")
    # si hay un hueco entre el max log y el tope, todos los intermedios deben estar libres
print(f"pool global (logs): {len(pool_logs)} libres, "
      f"rango {min(pool_logs)}..{max(pool_logs) if pool_logs else '-'} | "
      f"{len(logs_usados)} logs en disco, ultimo {max(logs_usados) if logs_usados else '-'}")

# --- pools por canal ---
# FIX 2026-10-13 (step-5-kilocode, orden del director mimo msg 277): la lista
# hardcodeada CANALES dejaba fuera 11 de 18 canales. Ahora se descubre de disco.
_resueltos = ("RESUELTOS",)
_canales_disco = sorted(
    d.name for d in MM.iterdir()
    if d.is_dir() and d.name not in _resueltos
    and not re.match(r"^\d+-", d.name)
)
_faltan_hardcode = [c for c in _canales_disco if c not in CANALES]
if _faltan_hardcode:
    print(f"(aviso: {len(_faltan_hardcode)} canal/es en disco no estaban en la lista "
          f"hardcodeada y ahora se auditan: {', '.join(_faltan_hardcode)})")
print()
for c in _canales_disco:
    d = MM / c
    pool, ok = leer_sano(d / "NUMEROS_DISPONIBLES.txt")
    usados, ilegibles, total = inventario(d)
    if ilegibles:
        fails.append(f"{c}: {len(ilegibles)} mensaje(s) ilegibles incluso con long-path: "
                     f"{ilegibles[:5]}")
    fuga = pool & usados
    if fuga:
        fails.append(f"{c}: mensaje(s) ya creado(s) pero su numero sigue en el pool del canal: {sorted(fuga)}")
    # huecos dentro de la secuencia usada (informativo, no fallo)
    if usados:
        faltan = [n for n in range(1, max(usados) + 1) if n not in usados]
    else:
        faltan = []
    print(f"{c}: {len(pool)} libres | {len(usados)} mensajes, max {max(usados) if usados else 0}"
          + (f" | huecos: {faltan}" if faltan else " | sin huecos"))

# --- sanity: no queden archivos con numeracion 13xx (era del pool global revertido) ---
huerfanos = []
for d in MM.iterdir():
    if not d.is_dir() or d.name in ("RESUELTOS",):
        continue
    for p in d.iterdir():
        if p.is_file() and re.match(r"^13\d\d-", p.name) and MENSAJE_RE.match(p.name):
            huerfanos.append(f"{d.name}/{p.name}")
if huerfanos:
    fails.append(f"mensajes con numeracion global 13xx sin renumerar: {huerfanos}")

print()
if fails:
    print("!! FALLOS:")
    for f in fails:
        print("  -", f)
    sys.exit(1)
print("OK: todos los pools sanos (LF, sin BOM), sin numeros usados disponibles")
