#!/usr/bin/env python3
"""
Suite de Tests Automatizados para los scripts del Protocolo Multiagente.

Valida las funciones críticas de:
- scripts/generar_checklist_global.py
- scripts/verificar_checklist.py

Uso:
    python scripts/test_scripts.py

Salida:
    ✅ PASS / ❌ FAIL por cada test. Exit code 0 si todos pasan, 1 si alguno falla.
"""

import io
import sys
import tempfile
from pathlib import Path

# Forzar salida UTF-8 en Windows (PowerShell/cmd no soportan emojis por defecto)
if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

# ---------------------------------------------------------------------------
# Configuración
# ---------------------------------------------------------------------------
RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import generar_checklist_global as gen
import verificar_checklist as ver

# ---------------------------------------------------------------------------
# Utilidades de test
# ---------------------------------------------------------------------------
_PASS = 0
_FAIL = 0


def test(nombre, funcion):
    """Ejecuta un test y reporta PASS/FAIL."""
    global _PASS, _FAIL
    try:
        funcion()
        _PASS += 1
        print(f"  ✅ PASS: {nombre}")
    except AssertionError as e:
        _FAIL += 1
        print(f"  ❌ FAIL: {nombre} — {e}")
    except Exception as e:
        _FAIL += 1
        print(f"  ❌ FAIL: {nombre} — Excepción inesperada: {e}")


def crear_checklist_temporal():
    """Crea un 05-Checklist.md temporal con contenido de prueba."""
    tmp = tempfile.TemporaryDirectory()
    ruta = Path(tmp.name) / "05-Checklist.md"
    ruta.write_text(
        "# Checklist de Prueba\n\n"
        "- [x] Tarea completada [S]\n"
        "- [ ] Tarea pendiente [M]\n"
        "- [?] Tarea con dudas [C]\n"
        "- [x] Otra completada [M]\n",
        encoding="utf-8",
    )
    return tmp, ruta


# ---------------------------------------------------------------------------
# TESTS: generar_checklist_global.py
# ---------------------------------------------------------------------------
def test_contar_checklist():
    tmp, ruta = crear_checklist_temporal()
    try:
        x, pend, dudas = gen.contar_checklist(ruta)
        assert x == 2, f"Esperaba 2 [x], obtuvo {x}"
        assert pend == 1, f"Esperaba 1 [ ], obtuvo {pend}"
        assert dudas == 1, f"Esperaba 1 [?], obtuvo {dudas}"
    finally:
        tmp.cleanup()


def test_normalizar_nombre_no_pierde_letras():
    """REGRESIÓN: antes el regex eliminaba las mayúsculas (bug crítico)."""
    resultado = gen.normalizar_nombre("Módulo")
    assert resultado == "modulo", f"Esperaba 'modulo', obtuvo '{resultado}'"

    resultado = gen.normalizar_nombre("Estado")
    assert resultado == "estado", f"Esperaba 'estado', obtuvo '{resultado}'"

    resultado = gen.normalizar_nombre("Última actividad")
    assert resultado == "ultimaactividad", f"Esperaba 'ultimaactividad', obtuvo '{resultado}'"

    resultado = gen.normalizar_nombre("Progreso")
    assert resultado == "progreso", f"Esperaba 'progreso', obtuvo '{resultado}'"

    resultado = gen.normalizar_nombre("Agente actual")
    assert resultado == "agenteactual", f"Esperaba 'agenteactual', obtuvo '{resultado}'"

    resultado = gen.normalizar_nombre("Dependencias")
    assert resultado == "dependencias", f"Esperaba 'dependencias', obtuvo '{resultado}'"


def test_inferir_estado():
    assert gen.inferir_estado(0, 0, 0) == "⬜ Sin iniciar"
    assert gen.inferir_estado(0, 5, 0) == "🟢 Disponible"
    assert gen.inferir_estado(2, 3, 0) == "🔵 En curso"
    assert gen.inferir_estado(2, 3, 0, "🔴 En curso con riesgo") == "🔴 En curso con riesgo"
    assert gen.inferir_estado(2, 0, 0) == "✅ Completado"
    assert gen.inferir_estado(1, 0, 2) == "🟡 Con dudas"


def test_leer_tabla_existente():
    """Crea una tabla temporal y verifica el parseo de todas las columnas."""
    with tempfile.TemporaryDirectory() as tmp:
        tabla = Path(tmp) / "CHECKLIST-GLOBAL.md"
        tabla.write_text(
            "# CHECKLIST-GLOBAL\n\n"
            "| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |\n"
            "|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|\n"
            "| 01 | Modulo-Test | 🔵 En curso | 5/10 | Alta | 4 | — | CLAUDE | 2026-08-15 04:00 | ✅ Verificado por DEEPSEEK |\n",
            encoding="utf-8",
        )

        encabezados, filas = gen.leer_tabla_existente(tabla)

        assert "modulo" in encabezados, f"Falta 'modulo' en encabezados: {encabezados}"
        assert "estado" in encabezados, f"Falta 'estado' en encabezados: {encabezados}"
        assert "progreso" in encabezados, f"Falta 'progreso' en encabezados: {encabezados}"
        assert "prioridad" in encabezados, f"Falta 'prioridad' en encabezados: {encabezados}"
        assert "complejidad" in encabezados, f"Falta 'complejidad' en encabezados: {encabezados}"
        assert "agenteactual" in encabezados, f"Falta 'agenteactual' en encabezados: {encabezados}"
        assert "ultimaactividad" in encabezados, f"Falta 'ultimaactividad' en encabezados: {encabezados}"
        assert "notas" in encabezados, f"Falta 'notas' en encabezados: {encabezados}"

        fila = filas.get("01")
        assert fila is not None, "No se encontró la fila 01"
        assert fila["modulo"] == "Modulo-Test", f"Módulo incorrecto: {fila['modulo']}"
        assert fila["estado"] == "🔵 En curso", f"Estado incorrecto: {fila['estado']}"
        assert fila["progreso"] == "5/10", f"Progreso incorrecto: {fila['progreso']}"
        assert fila["prioridad"] == "Alta", f"Prioridad incorrecta: {fila['prioridad']}"
        assert fila["complejidad"] == "4", f"Complejidad incorrecta: {fila['complejidad']}"
        assert fila["agenteactual"] == "CLAUDE", f"Agente incorrecto: {fila['agenteactual']}"
        assert fila["ultimaactividad"] == "2026-08-15 04:00", f"Última actividad incorrecta: {fila['ultimaactividad']}"
        assert fila["notas"] == "✅ Verificado por DEEPSEEK", f"Notas incorrectas: {fila['notas']}"


def test_generar_preserva_columnas_manuales():
    """REGRESIÓN CRÍTICA: verifica que el generador NO pise columnas manuales."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)

        # Crear DOCUMENTACION simulada
        doc = tmp_path / "DOCUMENTACION"
        checklist_dir = doc / "01-Modulo-Test" / "plan-actual"
        checklist_dir.mkdir(parents=True)
        (checklist_dir / "05-Checklist.md").write_text(
            "- [x] Tarea 1 [S]\n- [ ] Tarea 2 [M]\n",
            encoding="utf-8",
        )

        # Crear tabla existente con valores manuales
        tabla = tmp_path / "CHECKLIST-GLOBAL.md"
        tabla.write_text(
            "| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |\n"
            "|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|\n"
            "| 01 | Modulo-Test | 🔵 En curso | 1/2 | Alta | 3 | 02 | CLAUDE | 2026-08-15 04:30 | ✅ Verificado por DEEPSEEK |\n",
            encoding="utf-8",
        )

        # Guardar las rutas originales para restaurarlas después
        doc_original = gen.DOCUMENTACION
        salida_original = gen.CHECKLIST_GLOBAL
        backup_original = gen.BACKUP_DIR

        try:
            gen.DOCUMENTACION = doc
            gen.CHECKLIST_GLOBAL = tmp_path / "CHECKLIST-GLOBAL.md"
            gen.BACKUP_DIR = tmp_path / "test_backups"  # Evitar residuos en el proyecto

            # Ejecutar generación
            gen.generar_tabla(tabla)

            # Verificar que las columnas manuales se preservaron
            _, filas = gen.leer_tabla_existente(tabla)
            fila = filas["01"]
            assert fila["prioridad"] == "Alta", f"Prioridad no preservada: {fila['prioridad']}"
            assert fila["complejidad"] == "3", f"Complejidad no preservada: {fila['complejidad']}"
            assert fila["dependencias"] == "02", f"Dependencias no preservadas: {fila['dependencias']}"
            assert fila["agenteactual"] == "CLAUDE", f"Agente no preservado: {fila['agenteactual']}"
            assert fila["ultimaactividad"] == "2026-08-15 04:30", f"Última actividad no preservada: {fila['ultimaactividad']}"
            assert fila["notas"] == "✅ Verificado por DEEPSEEK", f"Notas no preservadas: {fila['notas']}"

            # Verificar que estado y progreso se recalculan
            assert fila["estado"] == "🔵 En curso", f"Estado incorrecto: {fila['estado']}"
            assert fila["progreso"] == "1/2", f"Progreso incorrecto: {fila['progreso']}"
        finally:
            gen.DOCUMENTACION = doc_original
            gen.CHECKLIST_GLOBAL = salida_original
            gen.BACKUP_DIR = backup_original


# ---------------------------------------------------------------------------
# TESTS: verificar_checklist.py
# ---------------------------------------------------------------------------
def test_ver_leer_tabla_global():
    with tempfile.TemporaryDirectory() as tmp:
        tabla = Path(tmp) / "CHECKLIST-GLOBAL.md"
        tabla.write_text(
            "| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |\n"
            "|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|\n"
            "| 03 | Modulo-3 | 🟡 Con dudas | 3/10 | Media | 2 | 01 | — | 2026-08-14 10:00 | — |\n",
            encoding="utf-8",
        )

        filas = ver.leer_tabla_global(tabla)
        fila = filas.get("03")
        assert fila is not None, "No se encontró la fila 03"
        assert fila["estado"] == "🟡 Con dudas", f"Estado incorrecto: {fila['estado']}"
        assert fila["progreso"] == "3/10", f"Progreso incorrecto: {fila['progreso']}"
        assert fila["ultimaactividad"] == "2026-08-14 10:00", f"Última actividad incorrecta: {fila['ultimaactividad']}"


def test_ver_fail_fast_detector_ciego():
    """REGRESIÓN BUG-075: un archivo vacío/inexistente/sin tabla NO puede
    devolver {} («0 problemas»).

    El 7º incidente de infra dejó al orquestador ciego sin que nadie lo supiera:
    un guardia `if checklist_global.exists() else {}` neutralizaba el fail-fast
    y NINGÚN test cubría los 3 caminos de fallo. Un `return {}` es
    indistinguible de «no hay datos» (familia trampa 91/100), así que los 3
    casos deben levantar RuntimeError en vez de devolver un valor.
    """
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)

        # (1) el archivo no existe
        try:
            ver.leer_tabla_global(tmp / "NO_EXISTE.md")
        except RuntimeError as e:
            assert "BUG-075" in str(e), f"RuntimeError sin marca BUG-075: {e}"
        else:
            raise AssertionError("archivo inexistente devolvio un valor en vez de fallar")

        # (2) 0 bytes — el caso EXACTO del incidente
        vacio = tmp / "VACIO.md"
        vacio.write_bytes(b"")
        try:
            ver.leer_tabla_global(vacio)
        except RuntimeError as e:
            assert "VAC" in str(e).upper(), f"RuntimeError sin diagnostico de vacio: {e}"
        else:
            raise AssertionError("archivo de 0 bytes devolvio un valor en vez de fallar")

        # (2b) solo espacios/saltos: `.strip()` vacio, mismo camino que (2)
        blanco = tmp / "BLANCO.md"
        blanco.write_text("\n\r\n   \n", encoding="utf-8")
        try:
            ver.leer_tabla_global(blanco)
        except RuntimeError:
            pass
        else:
            raise AssertionError("archivo con solo espacios devolvio un valor en vez de fallar")

        # (3) existe y tiene contenido, pero sin la tabla '| ID |'
        sin_tabla = tmp / "SIN_TABLA.md"
        sin_tabla.write_text("# Titulo\n\nSin tabla aca.\n", encoding="utf-8")
        try:
            ver.leer_tabla_global(sin_tabla)
        except RuntimeError as e:
            assert "ID" in str(e), f"RuntimeError sin mencion de la tabla: {e}"
        else:
            raise AssertionError("archivo sin tabla devolvio un valor en vez de fallar")

        # Control: con una tabla valida NO debe levantar
        sana = tmp / "SANA.md"
        sana.write_text(
            "| ID | Módulo | Estado | Progreso |\n"
            "|----|--------|--------|----------|\n"
            "| 03 | Modulo-3 | 🟡 Con dudas | 3/10 |\n",
            encoding="utf-8",
        )
        filas = ver.leer_tabla_global(sana)
        assert filas.get("03") is not None, "el caso sano dejo de parsear (falso positivo del fail-fast)"


def test_ver_exit_codes():
    """REGRESIÓN BUG-075: el detector ciego tiene que salir con 3, no con 1.

    Con el 1 compartido, un llamador (CI) no puede distinguir «no miré» de «miré
    y hay N alertas» — exactamente la ceguera que el fail-fast vino a curar, un
    nivel más arriba. Se corre el script como subproceso porque el contrato es
    el exit code del proceso, no el valor de retorno de una función.
    """
    import subprocess

    script = RAIZ / "scripts" / "verificar_checklist.py"
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        (tmp / "VACIO.md").write_bytes(b"")
        (tmp / "SIN_TABLA.md").write_text("# Titulo\n\nsin tabla\n", encoding="utf-8")

        for nombre, ruta in [
            ("inexistente", tmp / "NO_EXISTE.md"),
            ("0 bytes", tmp / "VACIO.md"),
            ("sin tabla", tmp / "SIN_TABLA.md"),
        ]:
            r = subprocess.run(
                [sys.executable, str(script), "--checklist", str(ruta)],
                capture_output=True,
            )
            assert r.returncode == 3, f"{nombre}: esperaba exit 3, obtuve {r.returncode}"

        # El 1 sigue reservado a «mire y encontre alertas». No se puede asertar el
        # conteo (cambia entre corridas segun lo que arreglan los demas agentes),
        # pero si que el archivo sano NUNCA caiga en el 3.
        r = subprocess.run([sys.executable, str(script)], capture_output=True)
        assert r.returncode in (0, 1), f"archivo real: esperaba 0 o 1, obtuve {r.returncode}"


def test_ver_normalizar():
    """REGRESIÓN: verifica que la normalización no pierda letras."""
    resultado = ver.normalizar("Prioridad")
    assert resultado == "prioridad", f"Esperaba 'prioridad', obtuvo '{resultado}'"

    resultado = ver.normalizar("Complejidad")
    assert resultado == "complejidad", f"Esperaba 'complejidad', obtuvo '{resultado}'"

    resultado = ver.normalizar("Notas")
    assert resultado == "notas", f"Esperaba 'notas', obtuvo '{resultado}'"


def test_ver_detectar_colgados():
    """Verifica que detecta módulos sin timestamp o con actividad vieja."""
    import datetime

    filas = {
        "01": {"estado": "🔵 En curso", "modulo": "Mod-1", "ultimaactividad": "2020-01-01 00:00"},
        "02": {"estado": "🔵 En curso", "modulo": "Mod-2", "ultimaactividad": "—"},
        "03": {"estado": "🟢 Disponible", "modulo": "Mod-3", "ultimaactividad": "2026-08-15 00:00"},
    }

    colgados = ver.detectar_colgados(filas, horas_limite=24)
    ids = {c[0] for c in colgados}
    assert "01" in ids, "Mod-1 debería estar colgado (actividad vieja)"
    assert "02" in ids, "Mod-2 debería estar colgado (sin timestamp)"
    assert "03" not in ids, "Mod-3 no debería estar colgado (disponible)"


# ---------------------------------------------------------------------------
# TESTS: verificar_checklist.py — verificaciones SB-05 (2026-10-04)
# ---------------------------------------------------------------------------
def test_ver_estado_emoji():
    """REGRESIÓN E3 (SB-02, Log 1279): el estado se compara por su EMOJI
    INICIAL, no por igualdad exacta ni por `in` sobre el texto.

    Dos bugs que este test congela:
      - `estado == "✅"` NO detecta "✅ Re-verificado (iter. 1)" → el modulo
        queda invisible para la DoD 21.6 (8 modulos escaparon en SB-02).
      - `contains("✅")` produce falsos positivos con "🟡 Con dudas (Log 1 ✅)".
    """
    assert ver.estado_emoji("✅ Completado (P-36)") == "✅"
    assert ver.estado_emoji("✅ Re-verificado (iter. 1)") == "✅"
    assert ver.estado_emoji("🟡 Con dudas (Log 1130 ✅)") == "🟡", "el ✅ interno no debe ganar"
    assert ver.estado_emoji("🔵 En curso") == "🔵"
    assert ver.estado_emoji("⬜ Sin iniciar") == "⬜"
    assert ver.estado_emoji("") == ""
    assert ver.estado_emoji(None) == ""
    # el caso que dispara la DoD 21.6 con [ ]
    assert ver.estado_emoji("✅ Completado") == "✅"


def test_ver_analizar_estructura_tabla():
    """SB-05 verificacion 2: detecta filas mal formadas y EXCLUYE la tabla de
    leyenda (E2), ademas de las filas que no terminan en pipe."""
    with tempfile.TemporaryDirectory() as tmp:
        t = Path(tmp) / "GLOBAL.md"
        # encabezado de 11 columnas (como el repo real)
        enc = (
            "| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | "
            "Dependencias | Recom | Agente actual | Última actividad | Notas |"
        )
        t.write_text(
            "\n".join([
                "# titulo",
                enc,
                "|----|----|----|----|----|----|----|----|----|----|----|",
                # (1) fila bien formada
                "| 01 | Uno | 🟡 Con dudas | 1/2 | Alta | 1 | — | 02 | — | 2026-10-01 | ok |",
                # (2) fila con pipe sin escapar en Notas -> sobran celdas
                "| 02 | Dos | 🟡 Con dudas | 1/2 | Alta | 1 | — | 03 | — | 2026-10-01 | a | b |",
                # (3) LEYENDA de la seccion 21.2: NO es un modulo (E2)
                "| Estado | Significado | 🟢 | Disponible | | | | | | | |",
                "| ID | x | | | | | | | | | |",
                # (4) fila que no termina en pipe -> debe detectarse
                "| 04 | Cuatro | 🟡 Con dudas | 1/2 | Alta | 1 | — | 05 | — | 2026-10-01",
            ]) + "\n",
            encoding="utf-8",
        )

        n_esp, problemas, sin_pipe = ver.analizar_estructura_tabla(t)
        assert n_esp == 11, f"esperaba 11 columnas, obtuve {n_esp}"
        ids = {p[1] for p in problemas}
        assert "02" in ids, "la fila con pipe sin escapar debe reportarse"
        assert "04" in ids, "la fila sin pipe final debe reportarse"
        assert "01" not in ids, "la fila bien formada no debe reportarse"
        # E2: la leyenda NO puede aparecer como modulo mal formado
        assert not any(not i.isdigit() for i in ids), "la leyenda se coló como modulo"
        # sin_pipe devuelve NUMEROS DE LINEA, no ids: se verifica el contenido
        assert len(sin_pipe) == 1, f"esperaba 1 fila sin pipe final, obtuve {sin_pipe}"
        lineas = t.read_text(encoding="utf-8").split("\n")
        assert "Cuatro" in lineas[sin_pipe[0] - 1], (
            "la linea registrada como sin pipe final no es la de la fila 04: %r"
            % lineas[sin_pipe[0] - 1])


def test_ver_analizar_estructura_deteccion_ciega():
    """La verificacion 2 hereda el fail-fast BUG-075: sin archivo o sin
    encabezado debe levantar, no devolver «0 filas mal formadas»."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        try:
            ver.analizar_estructura_tabla(tmp / "NO_EXISTE.md")
        except RuntimeError as e:
            assert "BUG-075" in str(e), f"sin marca BUG-075: {e}"
        else:
            raise AssertionError("archivo inexistente devolvio un valor")

        sin_enc = tmp / "SIN_ENC.md"
        sin_enc.write_text("# titulo\n\nsin tabla aqui\n", encoding="utf-8")
        try:
            ver.analizar_estructura_tabla(sin_enc)
        except RuntimeError as e:
            assert "ID" in str(e), f"sin mencion del encabezado: {e}"
        else:
            raise AssertionError("archivo sin encabezado devolvio un valor")


def test_ver_parsear_totales():
    """SB-05 verificacion 4: semántica de campos (E1) y regex agrupada (E4).

    E1: se compara cada CAMPO contra su real. El bug era comparar el primer
    numero (el total) contra los completados.
    E4: los patrones con alternacion van agrupados; sin agrupar, group(1) es
    None en la primera rama y el script revienta.
    """
    # caso que el parser viejo confundia
    d = ver.parsear_totales(
        "**Totales:** 164 ítems · Completados: 158 · Pendientes: 0 · No resueltos: 6.")
    assert d["total"] == 164, d
    assert d["x"] == 158, d
    assert d["e"] == 0, d
    assert d["?"] == 6, "%r — el campo '?' (no resueltos) no debe romperse por la alternacion" % (d,)

    # solo total
    assert ver.parsear_totales("**Totales:** 179 ítems") == {"total": 179}

    # sin numero de items -> None (no inventar)
    assert ver.parsear_totales("**Totales:** (sin datos)") is None

    # el caso de M103 que era FALSO POSITIVO en SB-02: el 158 es parcial
    d2 = ver.parsear_totales(
        "**Totales:** 158 ítems (diseño A–M) + 21 ítems (implementación N) "
        "= **179 ítems** · Estado: **173 [x] · 6 [?] · 0 [ ]**")
    assert d2["total"] == 158, "toma el primer bloque (el consumidor decide si es drift)"


def test_ver_detectar_totales_incoherentes():
    """SB-05 verificacion 4 de punta a punta sobre un 05-Checklist.md real."""
    with tempfile.TemporaryDirectory() as tmp:
        mod = Path(tmp) / "99-Modulo"
        (mod / "plan-actual").mkdir(parents=True)
        cl = mod / "plan-actual" / "05-Checklist.md"
        cl.write_text(
            "- [x] uno\n- [x] dos\n- [ ] tres\n- [?] cuatro\n"
            "\n**Totales:** 4 ítems · Completados: 99 · Pendientes: 0 · No resueltos: 0.\n",
            encoding="utf-8",
        )
        res = ver.detectar_totales_incoherentes([cl])
        assert len(res) == 1, f"esperaba 1 incoherencia, obtuve {len(res)}"
        nombre, num_linea, malas, detalle = res[0]
        assert nombre == "99-Modulo", nombre
        # el 'x' declarado (99) es distinto del real (2)
        assert any("x: declarado=99 real=2" in m for m in malas), malas
        assert "total=4" in detalle, detalle

        # control: si el bloque cuadra, NO debe reportarse
        cl.write_text(
            "- [x] uno\n- [x] dos\n- [ ] tres\n- [?] cuatro\n"
            "\n**Totales:** 4 ítems · Completados: 2 · Pendientes: 1 · No resueltos: 1.\n",
            encoding="utf-8",
        )
        assert ver.detectar_totales_incoherentes([cl]) == [], "falso positivo con bloque coherente"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("=" * 60)
    print("🧪 SUITE DE TESTS — SCRIPTS DEL PROTOCOLO MULTIAGENTE")
    print("=" * 60)
    print()

    print("generar_checklist_global.py:")
    test("contar_checklist cuenta [x]/[ ]/[?]", test_contar_checklist)
    test("normalizar_nombre no pierde letras (REGRESIÓN)", test_normalizar_nombre_no_pierde_letras)
    test("inferir_estado según conteo", test_inferir_estado)
    test("leer_tabla_existente parsea todas las columnas", test_leer_tabla_existente)
    test("generar preserva columnas manuales (REGRESIÓN CRÍTICA)", test_generar_preserva_columnas_manuales)

    print()
    print("verificar_checklist.py:")
    test("leer_tabla_global parsea correctamente", test_ver_leer_tabla_global)
    test(
        "fail-fast: vacio/inexistente/sin tabla NO devuelve {} (BUG-075)",
        test_ver_fail_fast_detector_ciego,
    )
    test("exit codes: detector ciego = 3, no 1 (BUG-075)", test_ver_exit_codes)
    test("normalizar no pierde letras (REGRESIÓN)", test_ver_normalizar)
    test("detectar_colgados identifica módulos inactivos", test_ver_detectar_colgados)
    test("estado_emoji usa el emoji inicial (REGRESIÓN E3)", test_ver_estado_emoji)
    test("estructura: filas mal formadas + excluye leyenda (E2)",
         test_ver_analizar_estructura_tabla)
    test("estructura: fail-fast BUG-075 heredado",
         test_ver_analizar_estructura_deteccion_ciega)
    test("parsear_totales por campo (E1) y regex agrupada (E4)",
         test_ver_parsear_totales)
    test("Totales incoherentes detectado + control sin falso positivo",
         test_ver_detectar_totales_incoherentes)

    print()
    print("=" * 60)
    print(f"RESULTADO: {_PASS} PASS, {_FAIL} FAIL")
    if _FAIL > 0:
        print("❌ HAY TESTS FALLANDO — NO EJECUTAR LOS SCRIPTS EN PRODUCCIÓN")
        return 1
    else:
        print("✅ TODOS LOS TESTS PASARON — Los scripts son seguros de ejecutar")
        return 0


if __name__ == "__main__":
    sys.exit(main())