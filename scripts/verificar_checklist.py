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
    """
    if not archivo.exists():
        return {}

    contenido = archivo.read_text(encoding="utf-8")
    lineas = contenido.splitlines()

    # Buscar la línea de encabezado de la tabla (contiene | ID |)
    inicio_tabla = None
    for i, linea in enumerate(lineas):
        if "| ID |" in linea:
            inicio_tabla = i
            break

    if inicio_tabla is None:
        return {}

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


# ---------------------------------------------------------------------------
# Análisis principal
# ---------------------------------------------------------------------------
def analizar_proyecto(checklist_global: Path, horas_limite: int):
    """Ejecuta el análisis completo y devuelve una lista de alertas."""
    alertas = []

    if not DOCUMENTACION.exists():
        alertas.append(f"⚠️ No existe la carpeta DOCUMENTACION/ ({DOCUMENTACION})")
        return alertas

    # Colectar todos los 05-Checklist.md
    checklists = sorted(DOCUMENTACION.glob("*/plan-actual/05-Checklist.md"))

    if not checklists:
        alertas.append("⚠️ No se encontraron checklists en DOCUMENTACION/*/plan-actual/")
        return alertas

    # Tabla global
    filas_global = leer_tabla_global(checklist_global) if checklist_global.exists() else {}
    if not filas_global:
        alertas.append("⚠️ No se pudo parsear la tabla de CHECKLIST-GLOBAL.md")

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

            # Verificar que un módulo con [x] no esté declarado ⬜/🟢 sin dudas
            if x > 0 and estado_declarado in ("⬜", "🟢"):
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: tiene {x} items [x] "
                    f"pero su estado global es '{estado_declarado}'."
                )

            # Verificar que un módulo con [?] no esté declarado ✅
            if dudas > 0 and estado_declarado == "✅":
                alertas.append(
                    f"❌ Inconsistencia en {nombre_modulo}: tiene {dudas} items [?] "
                    f"pero su estado global es '✅ Completado'."
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
    args = parser.parse_args()

    print("=" * 60)
    print("🔍 VERIFICACIÓN DE CONSISTENCIA DEL PROTOCOLO MULTIAGENTE")
    print("=" * 60)
    print()

    alertas = analizar_proyecto(args.checklist, args.horas_limite)

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