# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-19
#
# M39 (39-Tiendas) — Reconciliación de cierre (iter. glm, Log 1017):
# convierte a [x] los ítems del 05-Checklist.md cuya evidencia material ya
# existe (documentación 01/02/03, código de shops/ y suites verdes 39/0).
#
# Seguro por diseño:
#   - Lista blanca explícita de líneas (nada de heurística).
#   - Backup previo en Obsoletos/ con timestamp.
#   - Idempotente: si la línea ya está [x] no hace nada.
#   - `--dry-run` muestra los cambios sin escribir.
#
# Uso:
#   python DOCUMENTACION/39-Tiendas/scripts-prueba/reconciliar_ck39.py --dry-run
#   python DOCUMENTACION/39-Tiendas/scripts-prueba/reconciliar_ck39.py

import io
import os
import shutil
import sys
import time

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
CK = os.path.join(RAIZ, "DOCUMENTACION", "39-Tiendas", "plan-actual", "05-Checklist.md")

# Línea -> nota de evidencia (ver Anexo del Log 1017).
FLIPS = {
    21: "iter. glm — Log 1017: 01 §A (problema)",
    23: "iter. glm — 02 §6 + 03 §4 (dependencias)",
    24: "iter. glm — 02 §6 (relaciones M19/M20/M53/M73)",
    25: "iter. glm — 01 §Alcance (dentro/fuera)",
    27: "iter. glm — 01 §7 (8 criterios)",
    28: "iter. glm — 01 §1 (contexto del plan maestro)",
    107: "D4: esta_abierta() puro, sin flag manual",
    144: "iter. glm — shop_ui: 4 señales, 0 lógica de precio",
    145: "iter. glm — shop_ui: 11 claves tr()",
    153: "iter. glm — 02 §1/§3 (tiendas = atributos de NPC)",
    154: "iter. glm — 02 §3/§5 (catálogos por NPC)",
    155: "iter. glm — 02 §1/§3 (consulta pura al calendario)",
    157: "iter. glm — 02 §2/§4 (precios delegados a M38)",
    158: "iter. glm — 02 §3 D8 + fix atomicidad",
    160: "iter. glm — 02 §3 D10 (eventos reversibles)",
    162: "iter. glm — 02 §2 (descartado: clones)",
    163: "iter. glm — 02 §2 (descartado: divergencia M38)",
    174: "iter. glm — 03 §2 (flujo 2.1)",
    175: "iter. glm — 03 §2 (flujo 2.2)",
    176: "iter. glm — 03 §2 (flujo 2.3)",
    177: "iter. glm — 03 §2 (flujo 2.4)",
    178: "iter. glm — 03 §5 (contrato de señales)",
    180: "iter. glm — 03 §8 (tabla de balance)",
    189: "iter. glm — agregar_items({item_id: cantidad}) en shop_manager",
    195: "iter. glm — npc_id del dueño pasado a M38",
    206: "iter. glm — 153: derivado de esta_abierta()",
    222: "iter. glm — shop_ui conecta compra/venta/inventario_tienda_cambio",
    224: "iter. glm — shop_ui: motivo en rechazos (6 usos)",
    234: "test_venta_sin_fondos: 6 checks OK (suite 39/0)",
    250: "shop.gd: aritmética pura sin alocaciones",
    252: "shop_manager: solo RefCounted/diccionarios (sin nodos)",
    262: "iter. glm — 01 con problema/objetivo/alcance/RF1-RF18",
    263: "iter. glm — 02 con dominio/alternativas/decisiones/riesgos",
    266: "iter. glm — Notas del Agente en 04",
    267: "iter. glm — 05 con 181 ítems y marcadores de esfuerzo",
    268: "iter. glm — 5 archivos firmados (modelo + plataforma)",
    269: "verificación por hash: 02/03 idénticos; 01/04/05 evolucionados",
    275: "suites verdes: recompra + monedas + acumular_stock (39/0, 16/0)",
    277: "test_horarios_real: bordes 17:00 excluida y día de descanso",
    280: "test recuperación/mercader: presencia + persistencia",
    282: "canal 2: semilla fuera de temporada AUSENTE",
    283: "edge cases: cantidad inválida, INVENTARIO_LLENO, SIN_FONDOS",
    284: "test_loop_economico: precios M38 idénticos (16 checks)",
}


def main() -> int:
    dry = "--dry-run" in sys.argv[1:]
    lineas = io.open(CK, encoding="utf-8").read().splitlines()
    cambios = []
    for n in sorted(FLIPS):
        idx = n - 1
        if idx < 0 or idx >= len(lineas):
            cambios.append(("FUERA_DE_RANGO", n, ""))
            continue
        actual = lineas[idx]
        if "- [x]" in actual or "- [X]" in actual:
            cambios.append(("YA_X", n, actual.strip()[:70]))
            continue
        if "- [ ]" not in actual:
            cambios.append(("SIN_CHECKBOX", n, actual.strip()[:70]))
            continue
        nueva = actual.replace("- [ ]", "- [x]", 1)
        if not nueva.rstrip().endswith("*"):
            nueva = nueva.rstrip() + " *(%s)*" % FLIPS[n]
        lineas[idx] = nueva
        cambios.append(("FLIP", n, actual.strip()[:60] + "  ->  " + FLIPS[n]))

    flips = [c for c in cambios if c[0] == "FLIP"]
    for tipo, n, txt in cambios:
        print("[%s] L%d: %s" % (tipo, n, txt))
    print("--- resumen: %d a convertir, %d ya [x], %d incidencias" % (
        len(flips), len([c for c in cambios if c[0] == "YA_X"]),
        len([c for c in cambios if c[0] not in ("FLIP", "YA_X")])))

    if dry:
        print("(dry-run: no se escribió nada)")
        return 0
    if not flips:
        print("(nada que escribir)")
        return 0

    obs = os.path.join(RAIZ, "Obsoletos")
    if not os.path.isdir(obs):
        os.makedirs(obs)
    marca = time.strftime("%Y-%m-%d_%H-%M-%S")
    shutil.copy2(CK, os.path.join(obs, "%s_05-Checklist-39-Tiendas.md" % marca))
    io.open(CK, "w", encoding="utf-8", newline="\n").write("\n".join(lineas) + "\n")
    print("OK: %d ítems convertidos. Backup en Obsoletos/%s_05-Checklist-39-Tiendas.md" % (len(flips), marca))
    return 0


if __name__ == "__main__":
    sys.exit(main())
