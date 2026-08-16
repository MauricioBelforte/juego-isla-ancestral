#!/usr/bin/env python3
"""
Generador Automático de CHECKLIST-GLOBAL.md.

Recorre DOCUMENTACION/{NN}-*/plan-actual/05-Checklist.md y regenera
la tabla resumen de la CHECKLIST-GLOBAL.md automáticamente.

PROTECCIONES INCLUIDAS:
- Crea un backup automático en scripts/backups/ antes de sobrescribir.
- Preserva Todas las columnas manuales (Prioridad, Complejidad, Dependencias,
  Agente actual, Última actividad, Notas) si el módulo ya existía.
- Solo actualiza Estado (según reglas de inferencia) y Progreso (conteo real).
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
    "agenteactual",
    "ultimaactividad",
    "notas",
}


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------
def contar_checklist(archivo: Path):
    """Cuenta [x], [ ] y [?] en un archivo de checklist."""
    contenido = archivo.read_text(encoding="utf-8")
    x = len(re.findall(r"\[x\]", contenido))
    pendientes = len(re.findall(r"\[ \]", contenido))
    dudas = len(re.findall(r"\[\?\]", contenido))
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


def leer_tabla_existente(archivo: Path):
    """Lee la tabla existente de CHECKLIST-GLOBAL.md.

    Devuelve (encabezados_normalizados, filas) donde filas es un dict
    {id_modulo: {columna_normalizada: valor}}.
    """
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

    filas = {}
    for linea in lineas[inicio + 2 :]:
        if not linea.strip().startswith("|"):
            continue
        celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
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

    # Leer tabla existente (si existe) para preservar columnas manuales
    _, filas_existente = leer_tabla_existente(salida)

    filas_output = []
    total_x = 0
    total_items = 0
    cambios = []

    for cl in checklists:
        modulo_dir = cl.parent.parent
        nombre_modulo = modulo_dir.name
        id_modulo = nombre_modulo.split("-")[0] if "-" in nombre_modulo else nombre_modulo

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

        # Preservar columnas manuales (prioridad, complejidad, dependencias,
        # agente actual, última actividad, notas)
        prioridad = previo.get("prioridad", "—")
        complejidad = previo.get("complejidad", "—")
        dependencias = previo.get("dependencias", "—")
        agente = previo.get("agenteactual", "—")
        ultima_act = previo.get("ultimaactividad", "—")
        notas = previo.get("notas", "—")

        filas_output.append(
            f"| {id_modulo} | {nombre_modulo} | {estado} | {progreso} | "
            f"{prioridad} | {complejidad} | {dependencias} | {agente} | {ultima_act} | {notas} |"
        )

        # Registrar cambios de estado/progreso para el resumen
        if previo.get("estado") != estado:
            cambios.append(f"  • Módulo {id_modulo} ({nombre_modulo}): estado '{previo.get('estado', '—')}' → '{estado}'")
        if previo.get("progreso") != progreso:
            cambios.append(f"  • Módulo {id_modulo} ({nombre_modulo}): progreso '{previo.get('progreso', '—')}' → '{progreso}'")

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

    contenido = f"""# CHECKLIST-GLOBAL.md — Orquestador Multiagente

> **Modelo:** [Nombre del modelo]
> **Plataforma:** [Nombre de la plataforma]
> **Última generación automática:** {ahora}

Este archivo es la **única fuente de verdad** sobre el estado global del proyecto. Contiene la **tabla resumen** con UNA fila por módulo. Los subitems detallados viven en `DOCUMENTACION/{{NN}}-Modulo/plan-actual/05-Checklist.md` de cada módulo.

> ⚠️ **Generado por script.** Las columnas `Estado` y `Progreso` se recalculan automáticamente según los `05-Checklist.md`. Las columnas manuales (`Prioridad`, `Complejidad`, `Dependencias`, `Agente actual`, `Última actividad`, `Notas`) se **preservan** de la versión anterior si el módulo ya existía.

## Tabla Resumen de Módulos

| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |
|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|
{chr(10).join(filas_output)}

## Simbología de Estados

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

    salida.write_text(contenido, encoding="utf-8")
    print(f"✅ CHECKLIST-GLOBAL.md generado en {salida}")
    print(f"   Módulos: {len(filas_output)} | Subitems completados: {total_x}/{total_items} ({porcentaje}%)")

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