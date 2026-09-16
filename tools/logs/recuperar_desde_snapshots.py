#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""recuperar_desde_snapshots.py - recupera archivos borrados del arbol de trabajo
usando el ledger de snapshots del host Kilo / OpenCode.

POR QUE EXISTE
--------------
El host Kilo (y OpenCode) versiona el repo en la sombra en cada paso del agente:

    ~/.local/share/kilo/snapshot/<hash-repo>/<hash-gitdir>/
    ~/.local/share/opencode/snapshot/<hash-repo>/<hash-gitdir>/

Dentro de ese gitdir hay refs con esta forma:

    refs/kilo/snapshots/<epoch-ms>/<sha>

TRAMPA: cada ref apunta directamente a un objeto **tree**, NO a un commit.
Por eso `git log`, `git rev-list --all` y `git log --all` devuelven 0 y parece que
el ledger esta vacio o roto. El contenido SI esta ahi:

    git --git-dir=<gitdir> show "<tree-sha>:<ruta>"

Como cada tree es el arbol de trabajo COMPLETO en ese instante, tambien incluye los
archivos **untracked** - justo los que `git checkout` no puede devolver.

USO
---
    # 1. localizar los gitdirs del ledger que existen en esta maquina
    python tools/logs/recuperar_desde_snapshots.py --find

    # 2. listar lo que falta en disco (dry-run, no escribe nada)
    python tools/logs/recuperar_desde_snapshots.py --path Logs --list

    # 3. restaurar todo lo que falte
    python tools/logs/recuperar_desde_snapshots.py --path Logs --restore-to Logs

    # 4. solo ciertos prefijos, a una carpeta de cuarentena
    python tools/logs/recuperar_desde_snapshots.py --path Logs --restore-to .rec \
        --prefix 901-,902-,933-

    # 5. apuntar a un gitdir concreto (si --find devuelve varios)
    python tools/logs/recuperar_desde_snapshots.py --gitdir <ruta> --path Logs --list

GARANTIAS
---------
  - Nunca sobrescribe: solo escribe rutas que NO existen en disco.
  - Escribe con CRLF (convencion del arbol de trabajo; el blob del snapshot es LF).
  - Salta archivos binarios (NUL en los primeros 8 KB).
  - Sin --restore-to es siempre dry-run.
"""

import argparse
import datetime
import pathlib
import re
import subprocess
import sys

HOME = pathlib.Path.home()
LEDGER_ROOTS = [
    HOME / ".local" / "share" / "kilo" / "snapshot",
    HOME / ".local" / "share" / "opencode" / "snapshot",
]
REF_RE = re.compile(r"^refs/(?:kilo|opencode)/snapshots/(\d+)/([0-9a-f]{40})$")


def git(gitdir, *args):
    p = subprocess.run(("git", "-c", "core.quotepath=false", "--git-dir", str(gitdir)) + args,
                       capture_output=True)
    return p.returncode, p.stdout, p.stderr


def fmt_epoch(ms):
    return datetime.datetime.fromtimestamp(ms / 1000, datetime.UTC).strftime("%Y-%m-%d %H:%M:%S")


def find_ledgers():
    """Devuelve [(gitdir, n_refs, n_trees, epoch_min, epoch_max), ...].

    n_refs  = cuantas refs hay (una por paso del agente)
    n_trees = cuantos tree-sha DISTINTOS (los refs comparten tree cuando el paso
              no toco el arbol de trabajo, asi que suele ser bastante menor)
    """
    found = []
    for root in LEDGER_ROOTS:
        if not root.is_dir():
            continue
        for gitdir in root.glob("*/*"):
            if not (gitdir / "HEAD").is_file():
                continue
            rc, out, _ = git(gitdir, "for-each-ref", "--format=%(refname)")
            if rc != 0:
                continue
            refs = 0
            epochs = set()
            trees = set()
            for line in out.decode("utf-8", "replace").split("\n"):
                m = REF_RE.match(line.strip())
                if m:
                    refs += 1
                    epochs.add(int(m.group(1)))
                    trees.add(m.group(2))
            if refs:
                found.append((gitdir, refs, len(trees), min(epochs), max(epochs)))
    return found


def load_trees(gitdir):
    """Todos los trees del ledger, de MAS NUEVO a MAS VIEJO, deduplicados.

    Ojo: el ref apunta a un tree, asi que 'sha' ES un tree-sha.
    """
    rc, out, err = git(gitdir, "for-each-ref", "--format=%(refname)")
    if rc != 0:
        sys.exit(f"ERROR leyendo refs: {err.decode('utf-8', 'replace')[:300]}")
    by_tree = {}
    total = 0
    for line in out.decode("utf-8", "replace").split("\n"):
        m = REF_RE.match(line.strip())
        if not m:
            continue
        total += 1
        epoch, sha = int(m.group(1)), m.group(2)
        if sha not in by_tree or epoch > by_tree[sha]:
            by_tree[sha] = epoch
    trees = sorted(((e, s) for s, e in by_tree.items()), reverse=True)
    return total, trees


def scan(gitdir, subpath, trees, verbose=True):
    """path -> (epoch, tree) del snapshot MAS NUEVO que contiene ese path."""
    newest = {}
    for i, (epoch, sha) in enumerate(trees):
        rc, out, _ = git(gitdir, "ls-tree", "-r", "--name-only", sha, "--", subpath)
        if rc != 0:
            continue
        for f in out.decode("utf-8", "replace").split("\n"):
            f = f.strip()
            if f and f not in newest:
                newest[f] = (epoch, sha)
        if verbose and (i + 1) % 200 == 0:
            print(f"    ... {i + 1}/{len(trees)} trees, {len(newest)} rutas", flush=True)
    return newest


def main():
    ap = argparse.ArgumentParser(description="Recupera archivos borrados desde el ledger de snapshots de Kilo/OpenCode.")
    ap.add_argument("--find", action="store_true", help="localizar los gitdirs del ledger y salir")
    ap.add_argument("--gitdir", help="gitdir del ledger (si hay varios)")
    ap.add_argument("--path", default="Logs", help="subruta a inspeccionar (default: Logs)")
    ap.add_argument("--list", action="store_true", help="listar lo que falta en disco (dry-run)")
    ap.add_argument("--restore-to", metavar="DIR",
                    help="escribir lo que falte bajo DIR (relativo al cwd). Sin esto = dry-run.")
    ap.add_argument("--prefix", help="solo rutas cuyo basename empiece por alguno de estos prefijos (coma)")
    ap.add_argument("--root", default=".", help="raiz del repo (default: cwd)")
    args = ap.parse_args()

    if args.find:
        ledgers = find_ledgers()
        if not ledgers:
            sys.exit("No se encontro ningun ledger de snapshots.")
        print(f"{'gitdir':<100} {'refs':>6} {'trees':>6}  rango")
        for gitdir, refs, trees, e0, e1 in ledgers:
            print(f"{str(gitdir):<100} {refs:>6} {trees:>6}  {fmt_epoch(e0)} .. {fmt_epoch(e1)}")
        return

    gitdir = pathlib.Path(args.gitdir) if args.gitdir else None
    if gitdir is None:
        ledgers = find_ledgers()
        if not ledgers:
            sys.exit("No se encontro ningun ledger de snapshots. Usa --gitdir.")
        # por defecto: el ledger mas RECIENTE (mayor epoch_max, indice 4)
        gitdir, refs, trees_n, e0, e1 = max(ledgers, key=lambda t: t[4])
        print(f"ledger: {gitdir}")
        print(f"        {refs} refs, {trees_n} trees, hasta {fmt_epoch(e1)} UTC\n")

    root = pathlib.Path(args.root).resolve()
    total, trees = load_trees(gitdir)
    print(f"=== ledger: {total} refs, {len(trees)} trees unicos ===", flush=True)
    print(f"    mas nuevo: {trees[0][1][:8]}  {fmt_epoch(trees[0][0])} UTC")
    print(f"    mas viejo: {trees[-1][1][:8]}  {fmt_epoch(trees[-1][0])} UTC", flush=True)

    newest = scan(gitdir, args.path, trees)
    print(f"=== rutas conocidas bajo {args.path}: {len(newest)} ===", flush=True)

    missing = {p: v for p, v in newest.items() if not (root / p).exists()}
    if args.prefix:
        prefixes = tuple(x.strip() for x in args.prefix.split(",") if x.strip())
        missing = {p: v for p, v in missing.items() if pathlib.PurePosixPath(p).name.startswith(prefixes)}

    print(f"=== FALTANTES EN DISCO: {len(missing)} ===")
    for p in sorted(missing):
        e, s = missing[p]
        print(f"    {p}\n        <- tree {s[:8]}  ({fmt_epoch(e)} UTC)")

    if not args.restore_to:
        print("\n(dry-run: nada escrito. usar --restore-to DIR para escribir)")
        return

    dest_root = pathlib.Path(args.restore_to)
    print(f"\n=== ESCRIBIENDO bajo {dest_root} ===")
    ok = fail = 0
    for p in sorted(missing):
        e, s = missing[p]
        rc, blob, err = git(gitdir, "show", f"{s}:{p}")
        if rc != 0 or not blob:
            print(f"    FALLO {p}: {err.decode('utf-8', 'replace').strip()[:140]}")
            fail += 1
            continue
        if b"\0" in blob[:8000]:
            print(f"    OMITIDO (binario) {p}")
            fail += 1
            continue
        # el blob del snapshot es LF; el arbol de trabajo usa CRLF
        out_bytes = blob.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
        dest = dest_root / p
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(out_bytes)
        print(f"    OK {p}   blob={len(blob)}B  escrito={dest.stat().st_size}B")
        ok += 1
    print(f"\n=== resultado: {ok} recuperados, {fail} fallidos ===")


if __name__ == "__main__":
    main()
