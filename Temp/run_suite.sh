#!/bin/bash
# run_suite.sh <MOD> <res_path> [<res_path> ...]
# Ejecuta cada test .gd headless y reporta EXIT / Checks / FAIL / SCRIPT_ERROR
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
MOD="$1"; shift
echo "########## MODULE $MOD ##########"
tot_chk=0; tot_fail=0; tot_serr=0; any_fail=0
for res in "$@"; do
  log="Temp/$(echo "$res" | tr '/:' '__').log"
  "$GODOT" --headless --path game/isla-ancestral --script "$res" > "$log" 2>&1
  ec=$?
  chks=$(grep -E "Checks:" "$log" | tail -1 | sed 's/.*Checks: //')
  fcnt=$(grep -cE "\[FAIL\]" "$log")
  scnt=$(grep -cE "SCRIPT ERROR" "$log")
  resumen=$(grep -E "RESUMEN|TODOS LOS CHECKS|FALLO" "$log" | tail -2 | tr '\n' '|')
  [ "$ec" -ne 0 ] && any_fail=1
  echo "[$res] EXIT=$ec | Checks=$chks | FAIL_lines=$fcnt | SCRIPT_ERROR=$scnt | $resumen"
  # aggregate numbers if present
  if [ -n "$chks" ]; then tot_chk=$((tot_chk + ${chks%% *})); fi
  tot_fail=$((tot_fail + fcnt)); tot_serr=$((tot_serr + scnt))
done
echo "MODULE $MOD SUMMARY: checks~$tot_chk fail_lines=$tot_fail script_errors=$tot_serr any_nonzero_exit=$any_fail"
