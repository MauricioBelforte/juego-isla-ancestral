# -*- coding: utf-8 -*-
"""Generador TASCHE T078+ para Beam (encargo directo del fundador, 24oct 21:13).
GLM-5.3-Flash / Kilo Code. Escaneo fresco de 05-Checklists con exclusiones,
clasificacion cubo A/B, chunks de 20 items, un modulo por archivo.
Uso:  python -X utf8 generar_tasche_glm.py --dry-run   (solo informe)
      python -X utf8 generar_tasche_glm.py --write [desde_t] [hasta_t]
"""
import os, re, sys, json, itertools

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
DOC = os.path.join(RAIZ, "DOCUMENTACION")
GLOBAL_MD = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")
TAREAS_DIR = os.path.join(RAIZ, "DOCUMENTACION", "TAREAS-POR-MODELO", "Reflection-Beam-1.0", "tareas")

MOD_SATURADOS_HOY = {1, 55, 73, 75, 110}   # Beam ya tiene 327 items en cola de estos
EX_D5 = {59, 20, 16, 17, 138}              # exclusion-set D-5 ya vigente (editor-locked / conflicto)
EX_FLAGS = re.compile(r"FLAG\s*FUNDADOR|FLAG\s*TECNICO", re.I)
ESTADOS_BLOQ = ("🔵", "🔴")
CUBO_B = re.compile(r"\b(arte|art|sprite|sprites|textura|texturas|modelado|modelo 3d|mesh|blender|"
                    r"animaci|assets? visuales?|iconografia|icono graphic|vfx|particulas? visual|"
                    r"editor de godot|editor godot| captura|screenshot|mockup|wireframe|ui art|"
                    r"voz|audio|musica|sfx|sonidos?)\w*\s", re.I)

RX_FILA = re.compile(r"^\|\s*(\d{1,3})\s*\|\s*([^|]+?)\s*\|\s*\S")
RX_ITEM = re.compile(r"^-\s*\[( |x|X|\?)\]\s*(.+)$", re.S)
RX_ESTADO = re.compile(r"(🔵|🔴|🟡|🟢|✅|⬜)", re.I)

def detectar_estado(celdas):
    """Detección robusta: el layout del GLOBAL varía por fila (estado puede caer
    en celda 2 o 3; a veces la 2 es la cifra de progreso)."""
    for c in celdas[2:6]:
        m = RX_ESTADO.search(c)
        if m:
            return m.group(1)
    return "?"

def esta_bloqueado(celdas):
    """🔵/🔴/'en curso'/'QA por' en cualquier celda temprana = bloqueado."""
    return any(t in c for c in celdas[2:7] for t in ("🔵", "🔴", " en curso", "QA por"))

def parsear_global():
    mods = {}
    with open(GLOBAL_MD, encoding="utf-8") as f:
        for line in f:
            m = RX_FILA.match(line.rstrip())
            if not m:
                continue
            mid = int(m.group(1))
            celdas = [c.strip() for c in line.split("|")[1:-1]]
            if len(celdas) < 4:
                continue
            estado = detectar_estado(celdas)
            bloqueado = esta_bloqueado(celdas)
            nombre = celdas[1].strip()
            mods[mid] = {"nombre": nombre, "estado": ("🔒 bloqueado" if bloqueado else estado)}
    return mods

def lstrip_item(texto):
    t = texto.strip()
    # quitar marcador de esfuerzo final [S]/[M]/[C] lo conservamos (info util)
    t = t.replace("|", "\\|")
    # compactar espacios multiples para la tabla
    t = re.sub(r"\s+", " ", t)
    return t

def cubo_de(texto):
    if CUBO_B.search(texto[:140]):
        return "B-EDITOR/ARTE (listar honesto)"
    return "A-DOC/FORMULA"

RX_DUENO = re.compile(r"\bdue\u00f1o:|\bdue\u00f1a:|dueno:|depende de|fila \d+ global|"
                      r"espera (GO|cifra|DECISI|decision)|DECISI\u00d3N DEL (FUNDADOR|DIRECTOR)|"
                      r"sin implementar \(fila|bloqueado por", re.I)
RX_DEF = re.compile(r"^\s*(Definir|Documentar|Validar|Formalizar|Especificar|Auditar|Verificar)", re.I)

def cubo_qmark(texto):
    """Clasificacion especial para [?] degradados: fórmula/spec vs dueño ajeno."""
    if RX_DUENO.search(texto[:180]):
        return "C-SKIP (dueno/dependencia externa)"
    if CUBO_B.search(texto[:140]):
        return "B-EDITOR/ARTE (listar honesto)"
    if RX_DEF.match(texto):
        return "A-DEF/FORMULA (re-verificar y definir)"
    return "A-DOC/FORMULA"

def extraer_pendientes(ruta_05, qmarks=False):
    items = []
    marcas = ("- [ ]", "- [?]") if qmarks else ("- [ ]",)
    with open(ruta_05, encoding="utf-8") as f:
        for n, line in enumerate(f, 1):
            t = line.lstrip()
            if not any(t.startswith(m) for m in marcas):
                continue
            cuerpo = RX_ITEM.match(t)
            if not cuerpo:
                continue
            texto = cuerpo.group(2)
            if EX_FLAGS.search(texto):
                continue
            es_q = t.startswith("- [?]")
            cubo = cubo_qmark(texto) if es_q else cubo_de(texto)
            if es_q and cubo.startswith("A-"):
                texto = "[?] DEGRADADO — " + texto
            items.append({"L": n, "texto": lstrip_item(texto), "cubo": cubo})
    return items

def carpeta_modulo(mid, nombre):
    # buscar carpeta DOCUMENTACION/{mid}-{...}
    pref = "%03d-" % mid if mid < 100 else "%d-" % mid
    if not os.path.isdir(DOC):
        return None
    for d in sorted(os.listdir(DOC)):
        if d.startswith(pref) and os.path.isdir(os.path.join(DOC, d)):
            return os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
    # fallback: cualquier carpeta que empiece por el numero crudo
    pref2 = str(mid) + "-"
    for d in sorted(os.listdir(DOC)):
        if d.startswith(pref2) and os.path.isdir(os.path.join(DOC, d)):
            return os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
    return None

def pendientes_en_cola_root():
    """(mid, L#) ya apilados y aun sin hacer en archivos T### del root (no duplicar)."""
    vivos = set()
    try:
        lista = os.listdir(TAREAS_DIR)
    except FileNotFoundError:
        return vivos
    rx = re.compile(r"^\|\s*\d+\s*\|\s*(\d+)\s*\|\s*L(\d+)\s*\|.*\|\s*\[\s\]\s*\|\s*$")
    for f in lista:
        if not (f.startswith("T") and f.endswith(".md")):
            continue
        ruta = os.path.join(TAREAS_DIR, f)
        try:
            with open(ruta, encoding="utf-8") as fh:
                for line in fh:
                    m = rx.match(line.rstrip())
                    if m:
                        vivos.add((int(m.group(1)), int(m.group(2))))
        except OSError:
            continue
    return vivos

def main():
    dry = "--dry-run" in sys.argv
    qmarks = "--qmarks" in sys.argv
    desde = 78
    hasta = 500
    if "--write" in sys.argv:
        i = sys.argv.index("--write")
        if len(sys.argv) > i + 1:
            desde = int(sys.argv[i + 1])
        if len(sys.argv) > i + 2:
            hasta = int(sys.argv[i + 2])

    mods = parsear_global()
    excluidos = []
    banco = []  # (mid, nombre, items)
    for mid in sorted(mods):
        info = mods[mid]
        estado = info["estado"]
        razon = None
        if estado.startswith("🔒") or any(b in estado for b in ESTADOS_BLOQ):
            razon = "bloqueado %s" % estado
        elif estado.startswith("✅"):
            razon = "completado"
        elif mid in EX_D5:
            razon = "exclusion D-5"
        elif mid in MOD_SATURADOS_HOY and not qmarks:
            razon = "saturado hoy en cola (T061-T077)"
        if razon:
            excluidos.append((mid, info["nombre"], razon))
            continue
        ruta = carpeta_modulo(mid, info["nombre"])
        if not ruta or not os.path.isfile(ruta):
            excluidos.append((mid, info["nombre"], "sin 05 plan-actual"))
            continue
        items = extraer_pendientes(ruta, qmarks=qmarks)
        en_cola = pendientes_en_cola_root()
        items = [i for i in items if (mid, i["L"]) not in en_cola]
        if items:
            banco.append({"mid": mid, "nombre": info["nombre"], "ruta": ruta, "items": items})

    banco.sort(key=lambda b: (-len(b["items"]), b["mid"]))
    total_items = sum(len(b["items"]) for b in banco)
    total_cubo_b = sum(1 for b in banco for i in b["items"] if i["cubo"].startswith("B-"))
    print("MODULOS HABILITADOS CON PENDIENTES: %d  | ITEMS: %d  (cubo B: %d)" %
          (len(banco), total_items, total_cubo_b))
    print("ARCHIVOS x20 QUE ALCANZAN: ~%d  (T%03d -> T%03d)" % (total_items // 20 + 1, desde, desde + total_items // 20))
    print("--- TOP 30 ---")
    for b in banco[:30]:
        print("  M%02d %-40s items=%3d" % (b["mid"], b["nombre"][:40], len(b["items"])))
    print("--- EXCLUIDOS (%d) ---" % len(excluidos))
    for mid, nombre, razon in excluidos:
        print("  M%02d %-40s %s" % (mid, nombre[:40], razon))

    if dry:
        return

    # escribir archivos — UN MODULO POR ARCHIVO (convencion agnes), chunks de 20
    import datetime
    hoy = datetime.datetime.now().strftime("%Y-%m-%d")

    n = desde
    creados = []
    for b in banco:
        items = b["items"]
        i = 0
        while i < len(items) and n <= hasta:
            chunk = items[i:i + 20]
            i += 20
            fname = "T%03d-%d.md" % (n, b["mid"])
            path = os.path.join(TAREAS_DIR, fname)
            hay_q = any(i["texto"].startswith("[?] DEGRADADO") for i in chunk)
            lineas = []
            lineas.append("# TASCHE T%03d — %d tareas (%d para Beam)" % (n, len(chunk), b["mid"]))
            lineas.append("")
            lineas.append("**INSTRUCCIONES:** ejecuta las %d tareas EN ORDEN. Cubo A/DOC: formula o spec en el 03 del modulo (seccion unica, con cita) + flipa el item en el 05 con cita. Cubo B/C: salte y anotala como skip. Si el item ya esta [x] en el 05, solo marcalo Hecho y seguimos. Al terminar: UN mensaje `hecho=N skip=N fail=N` + [x] en ESTE archivo." % len(chunk))
            if hay_q:
                lineas.append("")
                lineas.append("**ITEMS [?] DEGRADADO:** fueron degradados por falta de artefacto/quorum. Re-verificá: si la definicion/spec/formula ya existe en el 03 (o en codigo) → flipa [?]→[x] con cita de seccion; si la podes definir vos (nicho matematico) → escribi la seccion en el 03 y flipa con cita; si el dueño es ajeno o depende de algo no implementado → dejalo [?] y anotala skip (honesto).")
            lineas.append("")
            lineas.append("| # | Modulo | L# | Tarea | Hecho |")
            lineas.append("|---|--------|----|-------|-------|")
            for k, item in enumerate(chunk, 1):
                lineas.append("| %d | %d | L%d | %s — CUBO: %s | [ ] |" % (k, b["mid"], item["L"], item["texto"], item["cubo"]))
            lineas.append("Al terminar: 1 mensaje al director (head del pool) + [x] en ESTE archivo.")
            lineas.append("")
            lineas.append("Fuente: %s (escaneo %s, fuente %s). Firma: APILADOR (GLM-5.3-Flash / Kilo Code) — %s, encargo directo del fundador." % (os.path.relpath(b["ruta"], RAIZ), hoy, "[?] degradados" if qmarks else "[ ] vivos", hoy))
            content = "\n".join(lineas) + "\n"
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.write(content)
            creados.append((fname, len(chunk)))
            n += 1
        if n > hasta:
            print("TECHO T%03d alcanzado — items restantes sin apilar: M%02d %d y demas" % (hasta, b["mid"], len(items) - i))
            break
    if creados:
        print("CREADOS %d archivos: %s .. %s   items apilados: %d" %
              (len(creados), creados[0][0], creados[-1][0], sum(c[1] for c in creados)))

if __name__ == "__main__":
    main()
