#!/usr/bin/env python3
"""Tests de scripts/regenerar_estado_release.py (M118 / M151).

Patron del proyecto: unittest plano, sin dependencias externas, para correrse
desde la suite de protocolo en CI y en local.
"""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from textwrap import dedent

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parent
SCRIPT = RAIZ / "scripts" / "regenerar_estado_release.py"

BUGS_EJEMPLO = dedent(
    """\
    # 11 — BUGS: Registro Central

    ## 5. Tabla Resumen de Bugs

    | ID | Titulo | Modulo | Severidad | Estado | Reportado por | Fecha |
    |---|---|---|---|---|---|---|
    | BUG-001 | Bug critico abierto | M10 | 🔴 Critica | [ ] Abierto | agente | 2026-09-01 |
    | BUG-002 | Bug critico resuelto | M10 | 🔴 Critica | [x] Resuelto | agente | 2026-09-01 |
    | BUG-003 | Bug critico mencionando a BUG-999 en el titulo | M10 | 🔴 Critica | [ ] Abierto | agente | 2026-09-01 |
    | BUG-004 | Bug mayor abierto | M10 | 🟠 Mayor | [ ] Abierto | agente | 2026-09-01 |
    | BUG-005 | Critico parcial | M10 | 🔴 Crítica | [ ] Parcial — en curso | agente | 2026-09-01 |

    ## 6. Bugs Abiertos (pendientes)

    ### BUG-001 — Bug critico abierto
    """
)


def correr(args: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        capture_output=True,
        text=True,
        cwd=str(cwd),
    )


class TestRegenerarEstadoRelease(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.raiz = Path(self.tmp.name)
        (self.raiz / "DOCUMENTACION").mkdir()
        (self.raiz / "DOCUMENTACION" / "11-BUGS.md").write_text(
            BUGS_EJEMPLO, encoding="utf-8"
        )
        self.salida = self.raiz / "out" / "estado_release.json"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _gates(self) -> dict:
        return json.loads(self.salida.read_text(encoding="utf-8"))["gates"]

    def test_todos_los_gates_presentes(self) -> None:
        r = correr(
            ["--suite-ok", "1", "--smoke-ok", "1", "--ci-gates-ok", "1",
             "--backup-ok", "1", "--repo-root", str(self.raiz),
             "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        gates = self._gates()
        for g in ("suite_tests_verde", "smoke_aprobado", "zero_criticos_abiertos",
                  "crash_rate_cero", "ci_gates_verdes", "textos_localizados",
                  "backup_configurado"):
            self.assertIn(g, gates, "falta el gate %s" % g)

    def test_flags_se_reflejan_como_booleanos(self) -> None:
        correr(
            ["--suite-ok", "1", "--smoke-ok", "0", "--ci-gates-ok", "true",
             "--backup-ok", "no", "--repo-root", str(self.raiz),
             "--salida", str(self.salida)],
            RAIZ,
        )
        gates = self._gates()
        self.assertIs(gates["suite_tests_verde"], True)
        self.assertIs(gates["smoke_aprobado"], False)
        self.assertIs(gates["ci_gates_verdes"], True)
        self.assertIs(gates["backup_configurado"], False)
        # bool() real, no strings: el schema haria bool("false") = true.
        self.assertIsInstance(gates["suite_tests_verde"], bool)

    def test_cuenta_criticos_abiertos_de_la_tabla(self) -> None:
        # BUG-001, BUG-003 y BUG-005 abiertos; BUG-002 resuelto; BUG-004 es Mayor.
        r = correr(
            ["--repo-root", str(self.raiz), "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIs(self._gates()["zero_criticos_abiertos"], False)
        self.assertIn("criticos abiertos: BUG-001, BUG-003, BUG-005", r.stdout)

    def test_mencion_en_titulo_no_cuenta_como_registro(self) -> None:
        # BUG-003 menciona "BUG-999" en su titulo: no debe aparecer como abierto.
        r = correr(
            ["--repo-root", str(self.raiz), "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertNotIn("BUG-999", r.stdout)

    def test_sin_criticos_abiertos_da_true(self) -> None:
        (self.raiz / "DOCUMENTACION" / "11-BUGS.md").write_text(
            BUGS_EJEMPLO.replace("[ ] Abierto", "[x] Resuelto")
            .replace("[ ] Parcial — en curso", "[x] Resuelto"),
            encoding="utf-8",
        )
        r = correr(
            ["--repo-root", str(self.raiz), "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIs(self._gates()["zero_criticos_abiertos"], True)

    def test_pendientes_son_diccionarios_no_bloqueantes(self) -> None:
        correr(
            ["--repo-root", str(self.raiz), "--salida", str(self.salida)],
            RAIZ,
        )
        gates = self._gates()
        for g in ("crash_rate_cero", "textos_localizados"):
            self.assertIsInstance(gates[g], dict, "%s debe ser PENDIENTE (dict)" % g)
            self.assertEqual(gates[g]["estado"], "PENDIENTE")
            self.assertIn("duenio", gates[g])
            self.assertIn("fecha", gates[g])

    def test_fail_fast_si_no_hay_fuente(self) -> None:
        # Sin 11-BUGS.md y sin override -> DETECTOR CIEGO (exit 3).
        r = correr(
            ["--repo-root", str(self.raiz / "inexistente"),
             "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertEqual(r.returncode, 3, r.stdout + r.stderr)
        self.assertIn("DETECTOR CIEGO", r.stdout + r.stderr)

    def test_override_de_criticos_no_parsea(self) -> None:
        r = correr(
            ["--criticos-abiertos", "0", "--repo-root", str(self.raiz),
             "--salida", str(self.salida)],
            RAIZ,
        )
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIs(self._gates()["zero_criticos_abiertos"], True)
        self.assertIn("override --criticos-abiertos", r.stdout)

    def test_registro_lleva_commit_y_timestamp(self) -> None:
        correr(
            ["--repo-root", str(self.raiz), "--salida", str(self.salida)],
            RAIZ,
        )
        doc = json.loads(self.salida.read_text(encoding="utf-8"))
        self.assertIn("registro", doc)
        self.assertIn("regenerado por CI", doc["registro"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
