#!/usr/bin/env python3
"""
Script de Verificación de Consistencia del Protocolo Multiagente.

Recorre DOCUMENTACION/{NN}-*/plan-actual/05-Checklist.md y valida:
1. Que el Progreso declarado en CHECKLIST-GLOBAL.md coincida con el conteo real de [x].
2. Que no existan módulos 🔵/🔴 colgados (sin actividad por más de 24h).
3. Que no haya [x] en módulos cuyo estado global es 🟡/⬜ (inconsistencias).
4. Que los [x] cumplan la Definición de Completado (DoD) de la sección 21.6.

Uso:
    python scripts/verificar_checklist.py [--checklist PATH] [--horas-limite H]
    python scripts/verificar_checklist.py --estructura
    python scripts/verificar_checklist.py --totales
    python scripts/verificar_checklist.py --todos

Códigos de salida (BUG-075 — no compartir el 1 y el 3):
    0  sin alertas: todo consistente.
    1  miré y encontré alertas (inconsistencias reales del protocolo).
    3  DETECTOR CIEGO: no pude leer mi fuente de verdad (archivo ausente, vacío,
       sin tabla, o sin nada que analizar). No es «0 problemas», es «no miré».
"""

import argparse
import datetime
import re
import sys
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
DOCUMENTACION = RAIZ / "DOCUMENTACION"
CHECKLIST_GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"
HORAS_LIMITE_DEFAULT = 24

ESTADOS_EN_CURSO = {"🔵", "🔴"}

# SB-05 (space-bunny-alpha, 2026-10-04). Ver el canal
# `Mensajes entre modelos/space-bunny-alpha/06-...-sb02-aceptado-sb05-verificador.md`.
#
# Estas verificaciones son "opt-in" (flags --estructura / --totales / --todos) y
# NO alteran el comportamiento por defecto. Motivo: hoy el script devuelve exit
# 0 sobre el repo y CI puede depender de eso. Anadir 58 alertas de filas mal
# formadas sin avisar cambiaria el exit code de golpe y pondria el pipeline en
# rojo. Con opt-in, el default es identico al previo (0 cambios) y las
# verificaciones nuevas se piden explicitamente.
SB05_NOTA = (
    "SB-05: verificacion 2 (estructura de filas) y 4 (Totales) + fix del "
    "comparador de estado (E3). Opt-in para no cambiar el exit code por defecto."
)


# ---------------------------------------------------------------------------
# Excepciones
# ---------------------------------------------------------------------------
class DetectorCiegoError(RuntimeError):
    """BUG-075: fallo de INFRAESTRUCTURA, no de contenido.

    El orquestador no pudo leer su fuente de verdad (archivo ausente, vacío, sin
    tabla, o sin nada que analizar). Eso **no** es «0 problemas»: es «no miré», y
    un resultado vacío es indistinguible de «no hay datos» (familia trampas
    91/100).

    Hereda de ``RuntimeError`` para no romper a los llamadores existentes, y
    ``main()`` lo mapea al **código 3**. Ese código tiene que ser DISTINTO del 1:
    el 1 ya significa «miré y encontré alertas» (hoy, 92 preexistentes), así que
    compartirlo dejaría al llamador sin forma de separar «el orquestador está
    ciego» de «hay inconsistencias». Misma convención que
    ``auditar_arquitectura_m62.py`` y ``empaquetar_deposito_usco.py``.
    """


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------
def contar_checklist(archivo: Path):
    """Cuenta [x], [ ] y [?] en un archivo de checklist.

    Solo cuenta ítems de lista (líneas que empiezan con ``- [x]``, ``- [ ]``
    o ``- [?]``, ignorando sangría). Esto excluye la línea de leyenda de
    marcadores (``> Marcadores: ...``) y resúmenes (``**Total:** ...``)
    que antes inflaban el conteo. Debe coincidir con la función homónima
    de ``generar_checklist_global.py``.
    """
    contenido = archivo.read_text(encoding="utf-8")
    x = len(re.findall(r"(?m)^\s*- \[x\]", contenido))
    pendientes = len(re.findall(r"(?m)^\s*- \[ \]", contenido))
    dudas = len(re.findall(r"(?m)^\s*- \[\?\]", contenido))
    return x, pendientes, dudas


def normalizar(nombre: str):
    """Normaliza nombres de columnas para comparación (función de módulo)."""
    nombre = nombre.lower()
    nombre = (
        nombre.replace("ú", "u")
        .replace("é", "e")
        .replace("í", "i")
        .replace("ó", "o")
        .replace("á", "a")
        .replace("ñ", "n")
    )
    return re.sub(r"[^a-z0-9]", "", nombre)


def leer_tabla_global(archivo: Path):
    """Parsea la tabla resumen de CHECKLIST-GLOBAL.md.

    Devuelve un dict {id_modulo: {columna: valor}} con los datos de la tabla.

    Fail-fast anti detector ciego (BUG-075): si el archivo está vacío, no
    existe, o no contiene la tabla, esto es un FALLO de infraestructura, no un
    "0 problemas". Un parser que no itera devuelve «0 inconsistencias», lo cual
    es indistinguible de «no hay datos» y deja al orquestador operando sobre un
    estado inexistente sin saberlo (familia trampa 91). Aquí levantamos una
    excepción explícita para que `main()` termine con exit 1.
    """
    if not archivo.exists():
        raise DetectorCiegoError(
            f"BUG-075: {archivo.name} no existe — la fuente de verdad global "
            "desapareció. Revisar escrituras de agentes paralelos."
        )

    contenido = archivo.read_text(encoding="utf-8")
    if not contenido.strip():
        raise DetectorCiegoError(
            f"BUG-075: {archivo.name} está VACÍO ({archivo.stat().st_size} bytes). "
            "La fuente de verdad global se truncó — restaurar desde HEAD antes "
            "de continuar (git checkout HEAD -- CHECKLIST-GLOBAL.md)."
        )

    lineas = contenido.splitlines()

    # Buscar la línea de encabezado de la tabla (contiene | ID |)
    inicio_tabla = None
    for i, linea in enumerate(lineas):
        if "| ID |" in linea:
            inicio_tabla = i
            break

    if inicio_tabla is None:
        raise DetectorCiegoError(
            f"BUG-075: {archivo.name} existe ({len(contenido)} chars) pero no "
            "contiene la tabla '| ID |' — truncamiento parcial o formato roto."
        )

    # Parsear encabezados para mapear nombres de columna
    encabezados_raw = [c.strip().lower() for c in lineas[inicio_tabla].strip().strip("|").split("|")]
    encabezados = [normalizar(h) for h in encabezados_raw]

    # Las filas de datos son las líneas siguientes que comienzan con |
    filas = {}
    for linea in lineas[inicio_tabla + 2 :]:
        if not linea.strip().startswith("|"):
            continue
        celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
        if len(celdas) < 4:
            continue
        # El ID siempre está en la primera columna
        id_modulo = celdas[0].strip()
        if not id_modulo.isdigit():
            continue

        fila = {}
        for idx, nombre_col in enumerate(encabezados):
            if idx < len(celdas):
                fila[nombre_col] = celdas[idx].strip()
        filas[id_modulo] = fila

    return filas


def detectar_colgados(filas: dict, horas_limite: int):
    """Detecta módulos 🔵/🔴 sin actividad reciente (colgados)."""
    ahora = datetime.datetime.now()
    limite = ahora - datetime.timedelta(hours=horas_limite)
    colgados = []

    for id_modulo, datos in filas.items():
        estado = datos.get("estado", "")
        # El estado puede ser "🔵 En curso" o "🔴 En curso con riesgo";
        # verificar si COMIENZA con el emoji, no igualdad exacta.
        if not any(estado.startswith(e) for e in ESTADOS_EN_CURSO):
            continue

        # La "última actividad" está en la columna normalizada "ultimaactividad"
        ultima_act = datos.get("ultimaactividad", "")
        if not ultima_act or ultima_act == "—":
            colgados.append((id_modulo, datos.get("modulo", "?"), "sin timestamp"))
            continue

        try:
            fecha = datetime.datetime.strptime(ultima_act, "%Y-%m-%d %H:%M")
        except ValueError:
            try:
                fecha = datetime.datetime.strptime(ultima_act, "%Y-%m-%d")
            except ValueError:
                colgados.append((id_modulo, datos.get("modulo", "?"), f"timestamp ilegible: {ultima_act}"))
                continue

        if fecha < limite:
            colgados.append(
                (id_modulo, datos.get("modulo", "?"), f"sin actividad desde {ultima_act}")
            )

    return colgados


# ===========================================================================
# SB-05 — Verificaciones nuevas (opt-in). NO tocan leer_tabla_global() ni
# detectar_colgados() para no romper los tests de regresion existentes.
# ===========================================================================

# E3 (fix mio, reportado en el Log 1279): el estado de una celda puede ser
# "✅ Re-verificado (iter. 1)" o "🟡 Con dudas (Log 1130 ✅)". Comparar con
# `== "✅"` (igualdad exacta) NO detecta el caso real, y `in` sobre el texto
# produce falsos positivos con el ✅ que aparece DENTRO de un estado 🟡.
# La regla correcta es: el emoji va SIEMPRE al principio, y se compara solo el
# primer token.
_EMOJI_RE = re.compile(r"^(\S+)")


def estado_emoji(estado: str) -> str:
    """Devuelve SOLO el emoji inicial de la celda de estado (fix E3).

    "✅ Completado (P-36)"  -> "✅"
    "🟡 Con dudas (Log 1 ✅)" -> "🟡"
    "" o None               -> ""
    """
    if not estado:
        return ""
    m = _EMOJI_RE.match(estado.strip())
    return m.group(1) if m else ""


# --- Verificacion 2: estructura de filas de la tabla resumen ----------------
# Motivo (SB-02, Log 1279): 58 de 167 filas tienen un numero de celdas distinto
# al del encabezado, y el parser las mapea POR POSICION. Con un pipe sin
# escapar dentro de la columna "Notas", las columnas "Agente actual" y "Ultima
# actividad" reciben basura en silencio: el parser no falla, devuelve datos
# equivocados. Sin este check, cualquier verificacion que dependa de esas
# columnas (incluido detectar_colgados) opera sobre basura.
#
# E2 (fix mio): se excluyen las filas de LEYENDA (seccion 21.2 Simbolos), que
# tienen un ID no numerico. Contarlas como modulos las hacia parecer mal
# formadas.
RE_ID_NUMERICO = re.compile(r"^\d{1,3}$")


def analizar_estructura_tabla(archivo: Path):
    """Verificacion 2: filas mal formadas de la tabla resumen.

    Devuelve (n_cols_esperadas, lista_de_problemas) donde cada problema es
    (num_linea, id_modulo, n_celdas, motivo).

    Convencion de split (importante, y es parte del hallazgo): se quitan el
    primer y el ultimo elemento SOLO si estan vacios. Asi las filas que NO
    terminan en "|" se detectan como faltantes en vez de perder contenido en
    silencio. La convencion ingenua split("|")[1:-1] daria un numero distinto
    (54 vs 58 en el repo el 2026-10-04) — y esa ambiguedad ES el problema.
    """
    if not archivo.exists():
        raise DetectorCiegoError(f"BUG-075: {archivo.name} no existe")

    lineas = archivo.read_text(encoding="utf-8").split("\n")

    # Encabezado: primera linea "| ID | ..."
    idx_enc = None
    for i, l in enumerate(lineas):
        if l.strip().startswith("|") and l.strip().split("|")[1].strip() == "ID":
            idx_enc = i
            break
    if idx_enc is None:
        raise DetectorCiegoError(
            f"BUG-075: {archivo.name} no contiene el encabezado '| ID |'"
        )

    celdas_enc = [c.strip() for c in lineas[idx_enc].strip().strip("|").split("|")]
    n_esperadas = len(celdas_enc)

    problemas = []
    sin_pipe_final = []
    for i, l in enumerate(lineas[idx_enc + 1:], idx_enc + 2):
        s = l.strip()
        if not s.startswith("|"):
            continue
        partes = s.split("|")
        if partes and partes[0].strip() == "":
            partes = partes[1:]
        if partes and partes[-1].strip() == "":
            partes = partes[:-1]
        celdas = [p.strip() for p in partes]
        if not celdas or not RE_ID_NUMERICO.match(celdas[0]):
            continue  # E2: leyenda o separador, no es un modulo
        if len(celdas) == n_esperadas:
            continue
        # indice de Recom / Agente / Actividad solo para el mensaje
        motivo = "faltan celdas" if len(celdas) < n_esperadas else "sobran celdas"
        if not s.endswith("|"):
            motivo += " + no termina en '|'"
            sin_pipe_final.append(i)
        problemas.append((i, celdas[0], len(celdas), motivo))

    return n_esperadas, problemas, sin_pipe_final


# --- Verificacion 4: bloques "**Totales:**" que contradicen el conteo real ---
# Motivo (SB-02, Log 1279): 14 bloques "Totales" dentro de 05-Checklist.md
# contradicen el conteo real de marcas, mientras CHECKLIST-GLOBAL.md esta bien.
# El patron H-D: el archivo se contradice a si mismo.
#
# E1 (fix mio): se comparan los CAMPOS declarados contra los reales, no "el
# primer numero contra los completados". Y E4: toda alternacion va agrupada.
_CAMPOS_TOTALES = (
    ("total", r"(?:\d+)\s*i?t?e?m?o?s?\b"),
    ("x", r"(?:completados)"),
    ("?", r"(?:no resueltos|sin resolver)"),
    ("e", r"(?:pendientes)"),
)
_RE_TOTALES_LINEA = re.compile(r"(?mi)^\s*\*{0,2}Totales\*{0,2}\s*:.*$")


def parsear_totales(linea: str):
    """Extrae {campo: valor} de una linea '**Totales:** ...'. None si no hay total.

    E4 (fix mio): los patrones con alternacion van agrupados con (?:...) para
    que el grupo de captura se aplique a TODAS las ramas. Sin agrupar, la
    alternacion reparte el patron entero y group(1) es None en la 1a rama.
    """
    bajo = linea.lower()
    out = {}
    for campo, patron in _CAMPOS_TOTALES:
        if campo == "total":
            m = re.search(r"(\d+)\s*i?t?e?m?o?s?\b", bajo)
        else:
            m = re.search(patron + r"[^0-9]{0,14}(\d+)", bajo)
        if m:
            out[campo] = int(m.group(1))
    return out if "total" in out else None


def detectar_totales_incoherentes(checklists):
    """Verificacion 4: 'Totales' declarados vs conteo real de marcas.

    Devuelve lista de (nombre_modulo, num_linea, campos_discrepantes, detalle).
    Un campo solo se reporta si el archivo LO declara y no coincide.
    """
    salida = []
    for cl in checklists:
        texto = cl.read_text(encoding="utf-8")
        x, pend, dudas = contar_checklist(cl)
        real = {"total": x + pend + dudas, "x": x, "?": dudas, "e": pend}
        for m in _RE_TOTALES_LINEA.finditer(texto):
            num_linea = texto[: m.start()].count("\n") + 1
            decl = parsear_totales(m.group(0))
            if decl is None:
                continue
            malas = [
                f"{campo}: declarado={v} real={real[campo]}"
                for campo, v in decl.items()
                if campo in real and v != real[campo]
            ]
            if malas:
                salida.append(
                    (
                        cl.parent.parent.name,
                        num_linea,
                        malas,
                        f"real: [x]={x} [?]={dudas} [ ]={pend} total={real['total']}",
                    )
                )
    return salida


# ---------------------------------------------------------------------------
# Análisis principal
# ---------------------------------------------------------------------------
def analizar_proyecto(checklist_global: Path, horas_limite: int,
                      con_estructura: bool = False, con_totales: bool = False):
    """Ejecuta el análisis completo y devuelve una lista de alertas.

    SB-05: `con_estructura` y `con_totales` activan las verificaciones nuevas.
    Por defecto False -> comportamiento identico al previo (exit code no cambia).
    """
    alertas = []

    if not DOCUMENTACION.exists():
        raise DetectorCiegoError(
            f"BUG-075: no existe la carpeta DOCUMENTACION/ ({DOCUMENTACION}) — "
            "no hay nada que analizar. Revisar el checkout antes de confiar en el resultado."
        )

    # Colectar todos los 05-Checklist.md
    checklists = sorted(DOCUMENTACION.glob("*/plan-actual/05-Checklist.md"))

    if not checklists:
        raise DetectorCiegoError(
            "BUG-075: no se encontraron checklists en DOCUMENTACION/*/plan-actual/ — "
            "el analisis correria sobre 0 modulos y reportaria «sin inconsistencias»."
        )

    # Tabla global
    # BUG-075: sin el fail-fast de leer_tabla_global(), un archivo vacío
    # producía «No se pudo parsear» como alerta suave y el conteo de módulos
    # caía a 0, reportando "sin inconsistencias" sobre un orquestador ciego.
    filas_global = leer_tabla_global(checklist_global)
    if not filas_global:
        alertas.append("⚠️ La tabla de CHECKLIST-GLOBAL.md está vacía (0 filas)")

    # 1. Verificar consistencia de progreso y estado
    for cl in checklists:
        modulo_dir = cl.parent.parent
        nombre_modulo = modulo_dir.name
        id_modulo = nombre_modulo.split("-")[0] if "-" in nombre_modulo else nombre_modulo

        x, pendientes, dudas = contar_checklist(cl)
        total = x + pendientes + dudas

        print(f"📋 {nombre_modulo}:")
        print(f"   - [x] completados: {x}")
        print(f"   - [ ] pendientes:  {pendientes}")
        print(f"   - [?] con dudas:   {dudas}")

        if id_modulo in filas_global:
            datos = filas_global[id_modulo]
            progreso_declarado = datos.get("progreso", "")
            estado_declarado = datos.get("estado", "")
            esperado = f"{x}/{total}" if total > 0 else "0/0"

            # Verificar progreso numérico
            if progreso_declarado != esperado:
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: "
                    f"CHECKLIST-GLOBAL dice '{progreso_declarado}' pero "
                    f"el 05-Checklist.md tiene '{esperado}'."
                )

            # E3 (SB-05): el estado se compara por su EMOJI INICIAL, no por
            # igualdad exacta. Antes: `estado_declarado == "✅"` no detectaba
            # "✅ Re-verificado (iter. 1)" (SB-02, Log 1279: 8 modulos con ✅ y
            # trabajo pendiente pasaban como "sin alertas").
            emoji_estado = estado_emoji(estado_declarado)

            # Verificar que un módulo con [x] no esté declarado ⬜/🟢 sin dudas
            if x > 0 and emoji_estado in ("⬜", "🟢"):
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: tiene {x} items [x] "
                    f"pero su estado global es '{estado_declarado}'."
                )

            # Verificar que un módulo con [?] no esté declarado ✅ (DoD 21.6)
            if dudas > 0 and emoji_estado == "✅":
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: tiene {dudas} items [?] "
                    f"pero su estado global es '{estado_declarado}'."
                )

            # E3 (SB-05): la misma trampa de comparacion, para el caso `[ ]`:
            # un modulo ✅ con items pendientes viola la DoD 21.6 igual que con
            # [?]. Antes no se checkeaba en absoluto.
            if pendientes > 0 and emoji_estado == "✅":
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: tiene {pendientes} items [ ] "
                    f"pendientes pero su estado global es '{estado_declarado}' "
                    f"(DoD 21.6: ✅ exige todo [x])."
                )

        # 2. Verificar DoD: si hay [x], deben existir Logs/ y firmas en plan-actual
        if x > 0:
            logs_dir = RAIZ / "Logs"
            if not logs_dir.exists():
                alertas.append(
                    f"❌ {nombre_modulo}: hay {x} items [x] pero no existe la carpeta Logs/ "
                    f"(requisito DoD sección 21.6)."
                )

    # 3. Detectar bloques colgados (🔵/🔴 sin actividad)
    colgados = detectar_colgados(filas_global, horas_limite)
    for id_modulo, nombre, motivo in colgados:
        alertas.append(
            f"⚠️ Módulo {id_modulo} ({nombre}) está en curso pero {motivo}. "
            f"Posible bloqueo colgado (regla 21.4.7)."
        )

    # --- SB-05: verificaciones nuevas (opt-in) ------------------------------
    # 4. Estructura de filas de la tabla resumen
    if con_estructura:
        n_esp, problemas, sin_pipe = analizar_estructura_tabla(checklist_global)
        faltan = [p for p in problemas if "faltan" in p[3]]
        sobran = [p for p in problemas if "sobran" in p[3]]
        print()
        print(f"🔧 SB-05 · Estructura de la tabla: {n_esp} columnas en el encabezado")
        print(f"   filas mal formadas: {len(problemas)} (faltan={len(faltan)} sobran={len(sobran)})")
        print(f"   de las cuales no terminan en '|': {len(sin_pipe)} -> lineas {sin_pipe}")
        print("   NOTA: una fila mal formada hace que el parser mapee por posicion y")
        print("         las columnas 'Agente actual'/'Ultima actividad' reciban basura.")
        for num_linea, mid, n, motivo in problemas:
            alertas.append(
                f"⚠️ Fila {mid} (L{num_linea}) mal formada: {n} celdas de {n_esp} ({motivo}) "
                f"— el parser mapea por posicion."
            )

    # 5. Bloques "Totales" que contradicen el conteo real
    if con_totales:
        incoherentes = detectar_totales_incoherentes(checklists)
        print()
        print(f"🔧 SB-05 · Bloques 'Totales' que contradicen el conteo real: {len(incoherentes)}")
        print("   (CHECKLIST-GLOBAL.md puede estar bien: el que miente es el checklist)")
        for nombre, num_linea, malas, detalle in incoherentes:
            alertas.append(
                f"⚠️ {nombre} L{num_linea}: bloque 'Totales' incoherente — "
                f"{'; '.join(malas)} ({detalle})"
            )

    return alertas


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Verifica la consistencia del protocolo multiagente."
    )
    parser.add_argument(
        "--checklist",
        type=Path,
        default=CHECKLIST_GLOBAL,
        help="Ruta al CHECKLIST-GLOBAL.md (default: raíz del proyecto).",
    )
    parser.add_argument(
        "--horas-limite",
        type=int,
        default=HORAS_LIMITE_DEFAULT,
        help="Horas sin actividad para considerar un 🔵/🔴 como colgado (default: 24).",
    )
    parser.add_argument(
        "--estructura",
        action="store_true",
        help="SB-05: verifica filas mal formadas de la tabla resumen "
        "(celdas de mas/menos, filas sin pipe final).",
    )
    parser.add_argument(
        "--totales",
        action="store_true",
        help="SB-05: verifica que los bloques '**Totales:**' de cada "
        "05-Checklist.md cuadren con su conteo real de marcas.",
    )
    parser.add_argument(
        "--todos",
        action="store_true",
        help="SB-05: activa --estructura y --totales.",
    )
    args = parser.parse_args()

    con_estructura = args.estructura or args.todos
    con_totales = args.totales or args.todos

    print("=" * 60)
    print("🔍 VERIFICACIÓN DE CONSISTENCIA DEL PROTOCOLO MULTIAGENTE")
    print("=" * 60)
    if con_estructura or con_totales:
        print("SB-05 activo: --estructura=%s --totales=%s" % (con_estructura, con_totales))
    print()

    try:
        alertas = analizar_proyecto(
            args.checklist, args.horas_limite, con_estructura, con_totales
        )
    except DetectorCiegoError as e:
        # BUG-075: exit 3 = DETECTOR CIEGO. Deliberadamente distinto del 1, que
        # significa «mire y encontre alertas». Con el mismo codigo, un llamador
        # (CI) no puede separar «el orquestador esta ciego» de «hay 92
        # inconsistencias preexistentes», y el fail-fast queda inutil.
        print()
        print("=" * 60)
        print("🛑 DETECTOR CIEGO — fallo de infraestructura (exit 3):")
        print(f"   {e}")
        print()
        print("Esto NO es «sin inconsistencias»: es «no mire». El orquestador no")
        print("pudo leer su fuente de verdad, asi que no hay nada que reportar.")
        print("Restaurar el archivo (git checkout HEAD -- CHECKLIST-GLOBAL.md) y reintentar.")
        return 3

    print()
    print("=" * 60)
    if alertas:
        print(f"⚠️  SE ENCONTRARON {len(alertas)} ALERTAS:")
        for alerta in alertas:
            print(f"   {alerta}")
        print()
        print("Recomendación: corregir las inconsistencias antes de continuar.")
        return 1
    else:
        print("✅ SIN ALERTAS: todo consistente.")
        return 0


if __name__ == "__main__":
    sys.exit(main())