#!/usr/bin/env python3
"""
Detector de mensajes pendientes de respuesta en `Mensajes entre modelos/`.

No depende de memoria ni de numeros recordados: deriva TODO del disco.

Regla (protocolo §10.2): un canal necesita respuesta del director si el ULTIMO
mensaje emitido por el dueño del canal (dirigido al director) NO tiene despues
ningun mensaje del director respondiendole.

El emisor se toma del campo `**Modelo:**` del contenido del archivo (fuente
autoritativa), con fallback al nombre del archivo si el header falta.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "Mensajes entre modelos"

# Director: cualquier modelo cuyo nombre arranque con estos prefijos cuenta
# como lado-director (el director escribe en canales ajenos).
DIRECTOR_PREFIXES = ("atria",)

# Delegados del director: arrancan con "atria" PERO son agentes (s2, s3...).
# Si no se excluyen, el detector los clasificaria como director-side y sus
# mensajes NUNCA se detectarian como pendientes. MANTENER ACTUALIZADA.
DELEGADOS = {"atria-dawn-s2", "atria-dawn-s3"}

# Canales excluidos: no son canales de agente (soporte / archivo).
EXCLUDE_DIRS = {"RESUELTOS"}

# Formato canal §10.2: NN-AAAA-MM-DD_HH-MM-SS-...
CANAL_FMT = re.compile(r"^\d+-\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-")
HEADER_MODELO = re.compile(r"\*\*Modelo:\*\*\s*(.+)", re.IGNORECASE)
NUM_PREFIX = re.compile(r"^(\d+)-")


def normalizar(s: str) -> str:
    """Minusculas, sin espacios, sin tildes -> para comparar nombres."""
    out = []
    for ch in s.strip().lower():
        if ch.isspace():
            continue
        tabla = {"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "ñ": "n"}
        out.append(tabla.get(ch, ch))
    return "".join(out)


def es_director(nombre_modelo: str) -> bool:
    # Exclusion por CONTENIDO (no por prefijo): un delegado puede firmar con el
    # motor base + sufijo (ej. "Atria-Dawn-Preview (atria-dawn-s2)"), y
    # startswith("atria") lo clasificaria como director-side. Mismo criterio
    # que _es_variant_director().
    n = normalizar(nombre_modelo)
    if any(normalizar(d) in n for d in DELEGADOS):
        return False
    return any(n.startswith(p) for p in DIRECTOR_PREFIXES)


def _es_variant_director(nombre_modelo: str) -> bool:
    """True si el header es una variante del director base (no de un delegado).

    Ejemplos: "atria-dawn", "Atria-Dawn-Preview", "Atria-Dawn-Preview (sesión s3)".
    Se usa en canales de delegados, donde sesiones del mismo motor se comunican
    con el director y el header puede traer sufijos de sesion.
    """
    n = normalizar(nombre_modelo)
    # Un delegado nunca es el director, aunque su header mencione el motor base
    # (ej. "Atria-Dawn-Preview (atria-dawn-s2)" o "...(sesion s3)").
    for d in DELEGADOS:
        if normalizar(d) in n:
            return False
    return ("atria-dawn-preview" in n) or (n == "atria-dawn")


def emisor_desde_header(path: Path) -> str | None:
    """Lee el campo **Modelo:** del archivo (primeros 1500 bytes)."""
    try:
        with path.open("r", encoding="utf-8") as f:
            for _ in range(12):
                linea = f.readline()
                if not linea:
                    break
                m = HEADER_MODELO.search(linea)
                if m:
                    return m.group(1).strip()
    except (UnicodeDecodeError, OSError):
        return None
    return None


def es_plantilla_vacia(path: Path) -> bool:
    """Plantilla del helper reservar_mensaje.py que nunca se completo."""
    try:
        with path.open("r", encoding="utf-8") as f:
            contenido = f.read(2000)
    except (UnicodeDecodeError, OSError):
        return False
    return "<completar titulo aca>" in contenido or \
           "<cuerpo del mensaje aca>" in contenido


def listar_mensajes(canal: Path) -> list[tuple[int, Path]]:
    out = []
    for p in canal.iterdir():
        if not p.is_file() or p.suffix.lower() != ".md":
            continue
        m = NUM_PREFIX.match(p.name)
        if not m:
            continue
        if es_plantilla_vacia(p):
            continue
        out.append((int(m.group(1)), p))
    out.sort(key=lambda t: t[0])
    return out


def es_canal_de_agente(canal: Path) -> bool:
    """Carpeta de canal §10.2 (mensajes con formato NN-AAAA-MM-DD_HH-MM-SS-...).

    Las carpetas de TEMA §10.1 usan otra nomenclatura (AAAA-MM-DD_N-MODELO-...)
    y no son canales de respuesta obligada -> se ignoran como soporte.
    """
    archs = [p for p in canal.iterdir() if p.is_file() and p.suffix.lower() == ".md"]
    if not archs:
        return False
    # Canal si >=80% de los archivos matchean el formato canal.
    ok = sum(1 for p in archs if CANAL_FMT.match(p.name))
    return ok >= max(1, int(len(archs) * 0.8))


def diagnosticar(canal: Path) -> dict:
    """Devuelve estado de un canal."""
    msgs = listar_mensajes(canal)
    dueño = normalizar(canal.name)
    if not msgs:
        return {"canal": canal.name, "total": 0, "estado": "vacio",
                "detalle": "sin mensajes", "ultimo": "-"}

    # Clasificar cada mensaje: lado-director (respuesta) o lado-modelo.
    # Se considera "lado-director" si el header **Modelo:** es del director.
    # Fallback: si no hay header, se usa el nombre del archivo (arranca con el
    # dueño -> lado-modelo; si arranca con 'atria' -> director).
    #
    # EXCEPCION (canal de un DELEGADO, ej. atria-dawn-s3): el delegado es el
    # mismo motor que el director (firma "Atria-Dawn-Preview (sesión s3)"), asi
    # que el header NO distingue lado. Ahi el emisor se deduce del nombre del
    # archivo: "atria-a-<delegado>-..." -> lado-director; "<delegado>-a-..." ->
    # lado-modelo (el dueño hablando).
    clasif = []
    dueño_es_delegado = dueño in {normalizar(d) for d in DELEGADOS}
    for num, path in msgs:
        hdr = emisor_desde_header(path)
        es_dir = None
        if dueño_es_delegado:
            # Canales de delegados (s2/s3): sesiones Atria-Dawn-Preview que se
            # comunican con el director. Convenciones mixtas:
            #  - s2 firma "atria-dawn-s2" y sus mensajes se nombran "atria-a-s2".
            #  - s3 firma "Atria-Dawn-Preview (sesion s3)" y se nombra
            #    "atria-dawn-s3-a-atria-dawn-s3".
            # Regla: si el header coincide con el dueño -> lado-modelo.
            # Si el header es una variante del director base -> se usa el nombre
            # del archivo (parte antes del primer "-a-") como emisor.
            if hdr is not None and normalizar(hdr) == dueño:
                es_dir = False
            elif hdr is not None and not _es_variant_director(hdr):
                es_dir = es_director(hdr)
            if es_dir is None:
                resto = CANAL_FMT.sub("", path.name, count=1)
                emisor_arch = resto.split("-a-")[0] if "-a-" in resto else resto
                es_dir = normalizar(emisor_arch) != dueño
        else:
            if hdr is not None:
                es_dir = es_director(hdr)
            else:
                cuerpo = path.name.split("-", 2)[-1] if "-" in path.name else ""
                es_dir = not normalizar(cuerpo).startswith(dueño)
        clasif.append((num, path, es_dir))

    # Ultimo mensaje del lado-modelo (el dueño pidiendo/hablando al director).
    ult_modelo = None
    for num, path, es_dir in reversed(clasif):
        if not es_dir:
            ult_modelo = (num, path)
            break

    if ult_modelo is None:
        return {
            "canal": canal.name,
            "total": len(msgs),
            "estado": "ok",
            "detalle": "sin mensajes del modelo",
            "ultimo": clasif[-1][0],
        }

    # ¿Existe respuesta del director posterior a ese mensaje?
    num_um, _ = ult_modelo
    respondido = any(es_dir and n > num_um for n, _, es_dir in clasif)
    if respondido:
        return {
            "canal": canal.name,
            "total": len(msgs),
            "estado": "ok",
            "detalle": f"respondido (ultimo modelo #{num_um})",
            "ultimo": clasif[-1][0],
        }

    # Sin respuesta: si el ultimo mensaje es del director PERO es anterior al
    # ultimo del modelo, igual queda pendiente (orden raro / fuera de orden).
    return {
        "canal": canal.name,
        "total": len(msgs),
        "estado": "PENDIENTE",
        "detalle": f"sin respuesta al #{num_um}",
        "pendiente_num": num_um,
        "pendiente_path": str(ult_modelo[1]),
        "ultimo": clasif[-1][0],
    }


def main() -> int:
    if not BASE.is_dir():
        print(f"ERROR: no existe {BASE}")
        return 1

    canales = sorted(
        (p for p in BASE.iterdir() if p.is_dir() and p.name not in EXCLUDE_DIRS),
        key=lambda p: p.name.lower(),
    )
    pendientes = []
    temas = []
    print(f"=== Verificacion de canales (derivada de disco) ===")
    print(f"Base: {BASE}\n")
    for c in canales:
        if not es_canal_de_agente(c):
            temas.append(c.name)
            continue
        d = diagnosticar(c)
        total = d["total"]
        ultimo = d.get("ultimo", "-")
        if d["estado"] == "PENDIENTE":
            pendientes.append(d)
            print(f"  [!!] {d['canal']:<24} total={total:>3} ultimo=#{ultimo} "
                  f"-> {d['detalle']}  {d['pendiente_path']}")
        else:
            print(f"  [ok] {d['canal']:<24} total={total:>3} ultimo=#{ultimo} "
                  f"-> {d['detalle']}")

    print(f"\n=== Resumen ===")
    print(f"Canales de agente: {len(canales) - len(temas)} | "
          f"Temas (ignorados): {len(temas)} | "
          f"Pendientes de respuesta: {len(pendientes)}")
    for p in pendientes:
        print(f"  PENDIENTE: {p['canal']} #{p['pendiente_num']}")
    if temas:
        print(f"  Temas ignorados: {', '.join(sorted(temas))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
