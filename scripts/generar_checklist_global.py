#!/usr/bin/env python3
"""
Generador Automático de CHECKLIST-GLOBAL.md.

Recorre DOCUMENTACION/{NN}-*/plan-actual/05-Checklist.md y regenera
la tabla resumen de la CHECKLIST-GLOBAL.md automáticamente.

PROTECCIONES INCLUIDAS:
- Crea un backup automático en scripts/backups/ antes de sobrescribir.
- **Preserva TODO el contenido fuera de la tabla** (aviso de codificación UTF-8,
  "Flujo para modelos nuevos", simbología, resumen del proyecto). Antes el script
  reescribía el archivo desde una plantilla fija y borraba esas secciones
  (BUG-039: pérdida medida de 38,9 KB en la corrida del 2026-09-15 01:11).
- **Preserva el esquema de columnas del archivo existente** (encabezado + separador
  tal cual). Antes forzaba una tabla de 10 columnas y eliminaba la columna `Recom`.
- Preserva Todas las columnas manuales (Prioridad, Complejidad, Dependencias,
  Recom, Agente actual, Última actividad, Notas) si el módulo ya existía.
- Solo actualiza Estado (según reglas de inferencia) y Progreso (conteo real).
- **Conserva la anotación manual del Estado** cuando el emoji calculado coincide
  (p. ej. `🟡 Liberado (Log 831)` no se degrada a `🟡 Con dudas`): esa anotación es
  la traza de qué agente y qué log liberaron el módulo.
- No pisa la firma "✅ Verificado por" en Notas.

Uso:
    python scripts/generar_checklist_global.py [--output PATH] [--dry-run]
"""

import argparse
import datetime
import re
import shutil
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
BACKUP_DIR = RAIZ / "scripts" / "backups"

# Columnas que SIEMPRE se recalculan (nunca se preservan)
COLUMNAS_AUTO = {"estado", "progreso"}

# Columnas que se preservan de la versión anterior si el módulo ya existía
COLUMNAS_MANUALES = {
    "prioridad",
    "complejidad",
    "dependencias",
    "recom",
    "agenteactual",
    "ultimaactividad",
    "notas",
}

# Encabezado/separador por defecto (solo si el archivo destino no existe todavía)
ENCABEZADO_DEFECTO = (
    "| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | "
    "Recom | Agente actual | Última actividad | Notas |"
)
SEPARADOR_DEFECTO = (
    "|----|--------|--------|----------|-----------|-------------|--------------|"
    "-------|---------------|------------------|-------|"
)
PREFIJO_DEFECTO = """# CHECKLIST-GLOBAL.md — Orquestador Multiagente

> **Modelo:** [Nombre del modelo]
> **Plataforma:** [Nombre de la plataforma]
> **Última generación automática:** —

Este archivo es la **única fuente de verdad** sobre el estado global del proyecto. Contiene la **tabla resumen** con UNA fila por módulo. Los subitems detallados viven en `DOCUMENTACION/{NN}-Modulo/plan-actual/05-Checklist.md` de cada módulo.

## Tabla Resumen de Módulos
""".split("\n")


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------
def contar_checklist(archivo: Path):
    """Cuenta [x], [ ] y [?] en un archivo de checklist.

    Solo cuenta ítems de lista (líneas que empiezan con ``- [x]``, ``- [ ]``
    o ``- [?]``, ignorando sangría). Esto excluye la línea de leyenda de
    marcadores (``> Marcadores: ...``) y resúmenes (``**Total:** ...``)
    que antes inflaban el conteo.
    """
    contenido = archivo.read_text(encoding="utf-8")
    x = len(re.findall(r"(?m)^\s*- \[x\]", contenido))
    pendientes = len(re.findall(r"(?m)^\s*- \[ \]", contenido))
    dudas = len(re.findall(r"(?m)^\s*- \[\?\]", contenido))
    return x, pendientes, dudas


def inferir_estado(x: int, pendientes: int, dudas: int, estado_previo: str = ""):
    """Infiere el estado del módulo según el conteo de subitems.

    Respeta estados previos en curso (🔵/🔴) para no desmarcarlos.
    """
    total = x + pendientes + dudas
    if total == 0:
        return "⬜ Sin iniciar"
    if dudas > 0:
        return "🟡 Con dudas"
    if pendientes == 0:
        return "✅ Completado"

    # Si hay items [x] y pendientes, el módulo está en progreso
    if x > 0:
        # Mantener el estado en curso previo (🔵 o 🔴) si existía
        if "🔴" in estado_previo:
            return "🔴 En curso con riesgo"
        return "🔵 En curso"

    return "🟢 Disponible"


def normalizar_nombre(nombre: str):
    """Normaliza nombres de columnas para comparación."""
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


def leer_estructura_existente(archivo: Path):
    """Devuelve (prefijo, encabezado, separador, cuerpo, sufijo) del existente.

    ``prefijo`` = todo lo anterior a la tabla · ``sufijo`` = todo lo posterior.
    El generador NO debe tocar ese contenido (aviso ⛔ de codificación, "Flujo
    para modelos nuevos", simbología, resumen del proyecto).

    El fin de la tabla se detecta por el **siguiente encabezado markdown**
    (``#``), NO por la primera línea que no empiece con ``|``: hay filas cuyo
    campo Notas continuó en una línea huérfana y eso cortaba la tabla a mitad
    (BUG-039: el resto de la tabla se anexaba como "sufijo" → filas duplicadas).

    Devuelve ``(None, None, None, None, None)`` si no hay tabla reconocible.
    """
    if not archivo.exists():
        return None, None, None, None, None

    lineas = archivo.read_text(encoding="utf-8").splitlines()

    inicio = None
    for i, linea in enumerate(lineas):
        if linea.strip().startswith("| ID |"):
            inicio = i
            break

    if inicio is None or inicio + 1 >= len(lineas):
        return None, None, None, None, None

    fin = len(lineas)
    for j in range(inicio + 2, len(lineas)):
        if lineas[j].startswith("#"):
            fin = j
            break

    return (
        lineas[:inicio],
        lineas[inicio],
        lineas[inicio + 1],
        lineas[inicio + 2 : fin],
        lineas[fin:],
    )


def parsear_filas(cuerpo, encabezados_norm):
    """Convierte el cuerpo de la tabla en ``{id_modulo: {columna: valor}}``.

    - Usa ``maxsplit`` = nº de columnas - 1 para que una `|` dentro de las Notas
      no desplace las celdas (antes lo hacía y corrompía la fila).
    - Las líneas huérfanas (que no empiezan con ``|``) se reenganchan a las Notas
      de la fila anterior en lugar de perderse.
    """
    ncols = len(encabezados_norm)
    filas = {}
    ultimo_id = None

    for linea in cuerpo:
        s = linea.strip()
        if not s:
            continue

        if s.startswith("|"):
            celdas = [c.strip() for c in s.strip("|").split("|", ncols - 1)]
            if len(celdas) < 2 or not celdas[0].isdigit():
                continue
            datos = {}
            for idx, col in enumerate(encabezados_norm):
                if idx < len(celdas):
                    datos[col] = celdas[idx]
            filas[celdas[0]] = datos
            ultimo_id = celdas[0]
        elif ultimo_id is not None:
            filas[ultimo_id]["notas"] = (
                filas[ultimo_id].get("notas", "").rstrip() + " " + s
            ).strip()

    return filas


def leer_tabla_existente(archivo: Path):
    """Lee la tabla existente de CHECKLIST-GLOBAL.md.

    Devuelve (encabezados_normalizados, filas) donde filas es un dict
    {id_modulo: {columna_normalizada: valor}}.
    """
    prefijo, encabezado, _sep, cuerpo, _sufijo = leer_estructura_existente(archivo)
    if encabezado is None:
        return [], {}

    encabezados_raw = [c.strip() for c in encabezado.strip().strip("|").split("|")]
    encabezados_norm = [normalizar_nombre(h) for h in encabezados_raw]

    return encabezados_norm, parsear_filas(cuerpo, encabezados_norm)


def _leer_tabla_legacy(archivo: Path):
    """(obsoleto) Parseo posicional original. Se conserva como referencia."""
    if not archivo.exists():
        return [], {}

    contenido = archivo.read_text(encoding="utf-8")
    lineas = contenido.splitlines()

    # Buscar el encabezado de la tabla (contiene | ID |)
    inicio = None
    for i, linea in enumerate(lineas):
        if "| ID |" in linea or "| id |" in linea.lower():
            inicio = i
            break

    if inicio is None:
        return [], {}

    encabezados_raw = [c.strip() for c in lineas[inicio].strip().strip("|").split("|")]
    encabezados_norm = [normalizar_nombre(h) for h in encabezados_raw]
    ncols = len(encabezados_norm)

    filas = {}
    for linea in lineas[inicio + 2 :]:
        if not linea.strip().startswith("|"):
            continue
        # maxsplit: la última columna (Notas) absorbe cualquier `|` interna
        celdas = [c.strip() for c in linea.strip().strip("|").split("|", ncols - 1)]
        if len(celdas) < 2:
            continue
        id_modulo = celdas[0].strip()
        if not id_modulo.isdigit():
            continue

        datos = {}
        for idx, col in enumerate(encabezados_norm):
            if idx < len(celdas):
                datos[col] = celdas[idx]
        filas[id_modulo] = datos

    return encabezados_norm, filas


# ---------------------------------------------------------------------------
# Generación de la tabla
# ---------------------------------------------------------------------------
def generar_tabla(salida: Path, dry_run: bool = False):
    """Genera la tabla resumen y la escribe en el archivo de salida."""
    if not DOCUMENTACION.exists():
        print(f"❌ No existe la carpeta DOCUMENTACION/ ({DOCUMENTACION})")
        return 1

    checklists = sorted(DOCUMENTACION.glob("*/plan-actual/05-Checklist.md"))

    if not checklists:
        print("⚠️ No se encontraron checklists en DOCUMENTACION/*/plan-actual/")
        return 1

    # Leer la estructura existente: prefijo/sufijo (intocables) + esquema de columnas
    prefijo, encabezado, separador, cuerpo, sufijo = leer_estructura_existente(salida)
    if encabezado is None:
        prefijo = list(PREFIJO_DEFECTO)
        encabezado = ENCABEZADO_DEFECTO
        separador = SEPARADOR_DEFECTO
        cuerpo = []
        sufijo = []
    columnas = [normalizar_nombre(c) for c in encabezado.strip().strip("|").split("|")]

    # Leer tabla existente (si existe) para preservar columnas manuales
    filas_existente = parsear_filas(cuerpo, columnas)

    filas_output = []
    total_x = 0
    total_items = 0
    cambios = []
    ids_generados = set()

    for cl in checklists:
        modulo_dir = cl.parent.parent
        nombre_modulo = modulo_dir.name
        id_modulo = nombre_modulo.split("-")[0] if "-" in nombre_modulo else nombre_modulo
        ids_generados.add(id_modulo)

        x, pendientes, dudas = contar_checklist(cl)
        total_items_modulo = x + pendientes + dudas
        total_x += x
        total_items += total_items_modulo

        # Datos previos del módulo (si existía en la tabla)
        previo = filas_existente.get(id_modulo, {})
        estado_previo = previo.get("estado", "")

        # Calcular estado y progreso
        estado = inferir_estado(x, pendientes, dudas, estado_previo)
        progreso = f"{x}/{total_items_modulo}" if total_items_modulo > 0 else "0/0"

        # Conservar la anotación manual del Estado si el emoji coincide
        # (p. ej. "🟡 Liberado (Log 831)" no se degrada a "🟡 Con dudas").
        prev_txt = (estado_previo or "").strip()
        if prev_txt and prev_txt[:1] == estado[:1] and prev_txt != estado:
            estado = prev_txt

        # Reconstruir la fila con el esquema de columnas del archivo existente:
        # se recalculan id/módulo/estado/progreso, el resto se preserva.
        fila = {}
        for col in columnas:
            fila[col] = previo.get(col, "—")
        fila["id"] = id_modulo
        fila["modulo"] = nombre_modulo
        fila["estado"] = estado
        fila["progreso"] = progreso

        filas_output.append(
            "| " + " | ".join(fila.get(col, "—") for col in columnas) + " |"
        )

        # Registrar cambios de estado/progreso para el resumen
        if previo.get("estado") != estado:
            cambios.append(f"  • Módulo {id_modulo} ({nombre_modulo}): estado '{previo.get('estado', '—')}' → '{estado}'")
        if previo.get("progreso") != progreso:
            cambios.append(f"  • Módulo {id_modulo} ({nombre_modulo}): progreso '{previo.get('progreso', '—')}' → '{progreso}'")

    # Filas que estaban en la tabla pero NO tienen `05-Checklist.md` detectable:
    # se conservan tal cual (nunca borrar información por un glob que no matchea).
    huerfanas = [mid for mid in filas_existente if mid not in ids_generados]
    for mid in sorted(huerfanas, key=lambda s: int(s) if s.isdigit() else 10**9):
        datos = filas_existente[mid]
        filas_output.append(
            "| " + " | ".join(datos.get(col, "—") for col in columnas) + " |"
        )
    if huerfanas:
        print(f"ℹ️  Filas conservadas sin checklist detectable: {len(huerfanas)} ({', '.join(huerfanas[:10])}…)")

    # Contar estados
    conteo_estados = {"⬜": 0, "🟢": 0, "🔵": 0, "🔴": 0, "🟡": 0, "✅": 0}
    for fila in filas_output:
        for estado_key in conteo_estados:
            if estado_key in fila:
                conteo_estados[estado_key] += 1
                break

    # Timestamp actual
    ahora = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    porcentaje = round(total_x * 100 / total_items, 1) if total_items > 0 else 0

    contenido = f"""## Simbología de Estados

| Estado | Significado |
|--------|-------------|
| `⬜` | Sin iniciar |
| `🟢` | Disponible (puede ser reclamado) |
| `🔵` | **En curso** (bloqueado por un agente, avanzando normal) |
| `🔴` | **En curso con riesgo** (posiblemente atascado; si no hay actividad en 24h otro agente puede reclamarlo) |
| `🟡` | **Con dudas** (bloqueado liberado con `?` pendientes, retomable) |
| `✅` | Completado (todos los subitems resueltos, debe pasar QA cruzado) |

## Resumen del Proyecto

- **Total de módulos:** {len(filas_output)}
- **Completados (`✅`):** {conteo_estados["✅"]}
- **En curso (`🔵`):** {conteo_estados["🔵"]}
- **En riesgo (`🔴`):** {conteo_estados["🔴"]}
- **Con dudas (`🟡`):** {conteo_estados["🟡"]}
- **Disponibles (`🟢`):** {conteo_estados["🟢"]}
- **Sin iniciar (`⬜`):** {conteo_estados["⬜"]}
- **Progreso total de subitems:** {total_x}/{total_items} ({porcentaje}%)
"""

    # --- Actualizar el prefijo (sin borrarlo) -------------------------------
    for i, linea in enumerate(prefijo):
        if "Última generación automática" in linea:
            # reemplazar solo el datetime, conservando anotaciones tipo
            # "(recontado a mano 2026-08-31 23:53)"
            prefijo[i] = re.sub(
                r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}(?::\d{2})?", ahora, linea, count=1
            )
            break
    else:
        # No había línea de timestamp: insertarla tras el bloque de título
        prefijo = list(prefijo)
        prefijo.insert(1, f"> **Última generación automática:** {ahora}")

    # --- Actualizar el resumen del sufijo (si existe) -----------------------
    def _rep_resumen(texto: str) -> str:
        pares = [
            (r"(?m)^(- \*\*Total de módulos:\*\*) .*$", rf"\1 {len(filas_output)}"),
            (r"(?m)^(- \*\*Completados \(`✅`\):\*\*) .*$", rf"\1 {conteo_estados['✅']}"),
            (r"(?m)^(- \*\*En curso \(`🔵`\):\*\*) .*$", rf"\1 {conteo_estados['🔵']}"),
            (r"(?m)^(- \*\*En riesgo \(`🔴`\):\*\*) .*$", rf"\1 {conteo_estados['🔴']}"),
            (r"(?m)^(- \*\*Con dudas \(`🟡`\):\*\*) .*$", rf"\1 {conteo_estados['🟡']}"),
            (r"(?m)^(- \*\*Disponibles \(`🟢`\):\*\*) .*$", rf"\1 {conteo_estados['🟢']}"),
            (r"(?m)^(- \*\*Sin iniciar \(`⬜`\):\*\*) .*$", rf"\1 {conteo_estados['⬜']}"),
            (
                r"(?m)^(- \*\*Progreso total de subitems:\*\*) .*$",
                rf"\1 {total_x}/{total_items} ({porcentaje}%)",
            ),
        ]
        for patron, repl in pares:
            texto = re.sub(patron, repl, texto)
        return texto

    if sufijo:
        # Quedarse solo con el bloque "Resumen del Proyecto" si ya existía, para
        # no duplicar la simbología; el resto del sufijo se conserva tal cual.
        tiene_resumen = any("Resumen del Proyecto" in ln for ln in sufijo)
        tiene_simbologia = any("Simbología de Estados" in ln for ln in sufijo)
        if tiene_resumen and tiene_simbologia:
            contenido = _rep_resumen("\n".join(sufijo)).lstrip("\n")
        else:
            contenido = "\n".join(sufijo).strip("\n") + "\n\n" + contenido

    tabla = "\n".join([encabezado, separador] + filas_output)

    partes = ["\n".join(prefijo).rstrip("\n"), "", tabla, "", contenido.strip("\n")]
    contenido = "\n".join(partes).rstrip("\n") + "\n"

    if dry_run:
        print("🔍 MODO DRY-RUN: no se escribió nada. Cambios que se aplicarían:")
        if cambios:
            for c in cambios:
                print(c)
        else:
            print("  (Sin cambios de estado/progreso)")
        return 0

    # ========== BACKUP AUTOMÁTICO ANTES DE SOBRESCRIBIR ==========
    if salida.exists():
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = BACKUP_DIR / f"CHECKLIST-GLOBAL_{timestamp}.md"
        shutil.copy2(salida, backup_path)
        print(f"💾 Backup creado: {backup_path}")

    # Conservar el estilo de fin de línea del archivo existente (no imponer uno).
    # Path.write_text con newline=None traduce "\n" a os.linesep (CRLF en Windows)
    # y eso convertía en silencio un archivo LF en CRLF.
    salto = "\n"
    if salida.exists():
        crudo = salida.read_bytes()
        if crudo.count(b"\r\n") > (crudo.count(b"\n") - crudo.count(b"\r\n")):
            salto = "\r\n"

    salida.write_text(contenido, encoding="utf-8", newline=salto)
    print(f"✅ CHECKLIST-GLOBAL.md generado en {salida}")
    print(f"   Módulos: {len(filas_output)} | Columnas: {len(columnas)} | Salto de línea: {salto!r}")
    print(f"   Subitems completados: {total_x}/{total_items} ({porcentaje}%)")

    if cambios:
        print("\n📋 Cambios aplicados:")
        for c in cambios:
            print(c)

    return 0


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Regenera la tabla resumen de CHECKLIST-GLOBAL.md."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=CHECKLIST_GLOBAL,
        help="Ruta de salida (default: raíz del proyecto).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Solo muestra qué cambios se aplicarían, sin escribir nada.",
    )
    args = parser.parse_args()

    return generar_tabla(args.output, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())