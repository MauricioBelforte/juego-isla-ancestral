$ErrorActionPreference = 'Continue'
$gates = @(
  @{n='lint_check --no-syntax'; c='python tools/ci/lint_check.py --no-syntax'},
  @{n='validar_workflows --selftest'; c='python scripts/validar_workflows.py --selftest'},
  @{n='validar_workflows'; c='python scripts/validar_workflows.py'},
  @{n='verificar_checklist'; c='python scripts/verificar_checklist.py'},
  @{n='test_scripts'; c='python scripts/test_scripts.py'},
  @{n='auditar_arquitectura --selftest'; c='python scripts/auditar_arquitectura_m62.py --selftest'},
  @{n='cobertura de suites'; c='python tools/quality/auditar_cobertura_suites.py --check'}
)
foreach ($x in $gates) {
  $o = Invoke-Expression ($x.c + ' 2>&1')
  $code = $LASTEXITCODE
  'EXIT=' + $code + '  ' + $x.n + ' :: ' + (@($o | Select-Object -Last 1) -join '')
}