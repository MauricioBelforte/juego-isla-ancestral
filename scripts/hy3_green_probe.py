# -*- coding: utf-8 -*-
"""HY3 GREEN-PROBE byte-exact — plantilla de verificación de fix (gate-2, model-agnostic).

Confirma que EL FIX (no el azar) pone en verde una suite. Receta (GUIA-GODOT/13 §3):

  1) rc_base  = correr suite (mide el rojo base)
  2) aplicar fix candidato              (--fix-cmd)
  3) rc_fix   = correr suite (mide el verde post-fix)
  4) REVERTIR byte-exact:              (--revert-cmd, default: git checkout -- <archivo>)
  5) rc_revert = correr suite -> DEBE == rc_base. Si no, el revert no fue exacto -> ABORTA.

Este script NO modifica código por sí solo: el --fix-cmd lo provee quien aplica el fix.
El verificador solo mide y certifica. Ejemplo M73 comentado al final.

Uso:
  python -X utf8 scripts/hy3_green_probe.py \
      --suite "GODOT --headless --path game/isla-ancestral --script res://scripts/X.gd" \
      --fix-cmd "edita X.gd ..." \
      --revert-cmd "git checkout -- game/isla-ancestral/scripts/X.gd" \
      --archivo game/isla-ancestral/scripts/X.gd

Exit codes: 0 = green-probe OK (rc_fix==espera_verde y rc_revert==rc_base); 1 = fallo de protocolo.
"""
import argparse, subprocess, sys

def correr(cmd):
    print("[GREEN-PROBE] $ %s" % cmd)
    rc = subprocess.run(cmd, shell=True).returncode
    print("[GREEN-PROBE] rc=%d" % rc)
    return rc

def main():
    ap = argparse.ArgumentParser(description="HY3 green-probe byte-exact")
    ap.add_argument("--suite", required=True, help="comando de la suite a correr")
    ap.add_argument("--fix-cmd", help="comando que aplica el fix candidato")
    ap.add_argument("--revert-cmd", help="revertido byte-exact (default git checkout -- archivo)")
    ap.add_argument("--archivo", help="archivo tocado por el fix (para revert default + git status)")
    ap.add_argument("--espera-verde", type=int, default=0, help="rc esperado post-fix (default 0)")
    args = ap.parse_args()

    rc_base = correr(args.suite)
    print("[GREEN-PROBE] rc_base = %d" % rc_base)

    if not args.fix_cmd:
        print("[GREEN-PROBE] modo medición: solo rc_base. Para certificar fix, pasá --fix-cmd.")
        sys.exit(0)

    correr(args.fix_cmd)
    rc_fix = correr(args.suite)
    print("[GREEN-PROBE] rc_fix = %d (esperado %d)" % (rc_fix, args.espera_verde))
    if rc_fix != args.espera_verde:
        print("[GREEN-PROBE][FAIL] el fix no produjo el rc esperado")
        sys.exit(1)

    revert = args.revert_cmd
    if not revert and args.archivo:
        revert = "git checkout -- %s" % args.archivo
    if not revert:
        print("[GREEN-PROBE][FAIL] sin --revert-cmd ni --archivo para revertir")
        sys.exit(1)
    correr(revert)
    if args.archivo:
        st = subprocess.run("git status --short %s" % args.archivo, shell=True,
                            capture_output=True, text=True).stdout.strip()
        if st:
            print("[GREEN-PROBE][FAIL] git status NO vacío tras revert: %r" % st)
            sys.exit(1)
        print("[GREEN-PROBE] git status vacío tras revert (byte-exact OK)")
    rc_revert = correr(args.suite)
    if rc_revert != rc_base:
        print("[GREEN-PROBE][FAIL] rc_revert (%d) != rc_base (%d): revert no exacto" % (rc_revert, rc_base))
        sys.exit(1)
    print("[GREEN-PROBE] OK: fix es el causante (rc_fix=%d, rc_revert==rc_base=%d)" % (rc_fix, rc_base))
    sys.exit(0)

if __name__ == "__main__":
    main()

# --- EJEMPLO M73 (validador de coleccionables), flujo real medido por Hy3 ---
# 1) rc_base = 1   (CATEGORIAS_CONOCIDAS=8, la suite esperaba 20 -> falla)
# 2) fix: ampliar CATEGORIAS_CONOCIDAS 8 -> 20 en scripts/coleccionables/...
# 3) rc_fix  = 0   (suite 47/0)
# 4) revert:  git checkout -- game/isla-ancestral/scripts/coleccionables/<tocado>.gd
#             git status --short  -> ""  (byte-exact)
# 5) rc_revert = 1 (vuelve al rojo base) => el fix ES el causante, no el azar.
