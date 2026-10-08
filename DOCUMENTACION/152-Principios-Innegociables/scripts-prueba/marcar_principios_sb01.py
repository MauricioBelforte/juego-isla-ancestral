#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
#
# SB-01 — space-bunny-alpha — 2026-10-04
#
# Aplica los veredictos de verificacion de los 87 `[ ]` de M152 sobre
# `plan-actual/05-Checklist.md` de forma IN-PLACE (una marca por linea, sin
# reordenar, sin anadir ni quitar lineas del cuerpo) y luego agrega un
# apendice de evidencia al final del archivo.
#
# *** DE UN SOLO USO — CORRERLO DOS VECES ABORTA, A PROPOSITO ***
# Despues de aplicarlo, los 87 items quedan `[x]` o `[?]`, nunca `[ ]`. Si se
# vuelve a correr, los 87 veredictos dan 0 coincidencias y el script ABORTA sin
# escribir. Eso es correcto: un script que "se aplica dos veces" y duplica el
# apendice o re-marca el checklist es un peligro en un repo con 20+ agentes.
# Para RE-VERIFICAR el estado despues de aplicarlo, usar el conteo directo:
#   python -c "import io;t=io.open(r'...05-Checklist.md',encoding='utf-8').read();\
#     print(t.count('- [x] '), t.count('- [?] '), t.count('- [ ] '))"   # 173 29 0
#
# El emparejamiento es (SEECCION, TEXTO): dentro de una misma seccion hay
# items con texto identico en secciones distintas (p.ej. "Disenar campo de
# aprobacion" aparece en "Proceso de revision" y en "Documentacion de
# proceso_revision.md"). Sin la seccion el script ABORTA, que es
# exactamente lo que se quiere: nunca marcar por coincidencia.
#
# Uso:
#   python marcar_principios_sb01.py --check    # dry-run: solo informa
#   python marcar_principios_sb01.py --aplicar  # escribe (UTF-8 sin BOM)
#
# Diseno (AGENTS.md 28): SIEMPRE UTF-8 sin BOM; conserva los finales de linea
# tal como estan (newline="" en lectura y escritura).

import argparse
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHECKLIST = os.path.normpath(
    os.path.join(HERE, "..", "plan-actual", "05-Checklist.md")
)
APENDICE = os.path.normpath(os.path.join(HERE, "apendice_sb01.md"))

# ---------------------------------------------------------------------------
# (seccion, texto exacto de la linea `[ ]`, 'x' | '?')
# ---------------------------------------------------------------------------

VEREDICTOS = [
    # --- FAMILIA A — Especificacion de principios innegociables (15) ---------
    ("### [S] Especificación de principios innegociables", "No convertir el juego en un survival de hambre si contradice la visión", "x"),
    ("### [S] Especificación de principios innegociables", "No castigar al jugador por jugar poco", "x"),
    ("### [S] Especificación de principios innegociables", "No obligar al jugador a optimizar constantemente", "x"),
    ("### [S] Especificación de principios innegociables", "No hacer que todos los NPC sean iguales", "x"),
    ("### [S] Especificación de principios innegociables", "No llenar el mundo únicamente con contenido procedural vacío", "x"),
    ("### [S] Especificación de principios innegociables", "No usar puzzles arbitrarios", "x"),
    ("### [S] Especificación de principios innegociables", "No esconder información esencial detrás de una sola acción fácilmente perdible", "x"),
    ("### [S] Especificación de principios innegociables", "No diseñar la economía alrededor del grind", "x"),
    ("### [S] Especificación de principios innegociables", "No sacrificar rendimiento por una pequeña mejora visual", "x"),
    ("### [S] Especificación de principios innegociables", "No ampliar el mapa solamente para hacerlo grande", "?"),
    ("### [S] Especificación de principios innegociables", "No confundir cantidad con profundidad", "x"),
    ("### [S] Especificación de principios innegociables", "No introducir monetización que destruya la experiencia", "x"),
    ("### [S] Especificación de principios innegociables", "No depender de servicios externos sin plan de contingencia", "?"),
    ("### [S] Especificación de principios innegociables", "No utilizar assets sin licencia clara", "x"),
    ("### [S] Especificación de principios innegociables", "No depender de una sola persona para conocimiento crítico del proyecto", "?"),

    # --- FAMILIA B — Filosofia cozy (1) --------------------------------------
    ("### [S] Filosofía cozy", "Definir filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles)", "x"),

    # --- FAMILIA C — Proceso de revision (6) ---------------------------------
    ("### [S] Proceso de revisión", "Diseñar formato de revisión de decisión", "x"),
    ("### [S] Proceso de revisión", "Diseñar campo de justificación para desviaciones", "x"),
    ("### [S] Proceso de revisión", "Diseñar campo de aprobación", "x"),
    ("### [S] Proceso de revisión", "Diseñar registro de desviaciones justificadas", "x"),
    ("### [S] Proceso de revisión", "Definir objetivo: 100% de decisiones críticas revisadas", "?"),
    ("### [S] Proceso de revisión", "Definir objetivo: < 5% de desviaciones justificadas por mes", "?"),

    # --- FAMILIA D — Documentacion de principios (4) -------------------------
    ("### [S] Documentación de principios", "Diseñar docs/licencias_assets.md", "x"),
    ("### [S] Documentación de principios", "Diseñar docs/knowledge_sharing.md", "x"),
    ("### [S] Documentación de principios", "Definir proceso de revisión", "x"),
    ("### [S] Documentación de principios", "Definir registro de desviaciones justificadas", "x"),

    # --- FAMILIA E — Integracion con otros modulos (15) ----------------------
    ("### [S] Integración con otros módulos", "Especificar integración con M01 (Fundamentos del Proyecto)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M02 (Visión y Concepto)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M07 (Arquitectura)", "?"),
    ("### [S] Integración con otros módulos", "Especificar integración con M10 (Generación del Mundo)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M13 (Herramientas)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M14 (Inventario)", "?"),
    ("### [S] Integración con otros módulos", "Especificar integración con M16 (Crafting)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M29 (Tiempo y Calendario)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M50 (Modelos 3D)", "?"),
    ("### [S] Integración con otros módulos", "Especificar integración con M59 (Guardado)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M61 (Rendimiento)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M64 (NPC)", "?"),
    ("### [S] Integración con otros módulos", "Especificar integración con M107 (Backups)", "?"),
    ("### [S] Integración con otros módulos", "Especificar integración con M111 (Código de Calidad)", "x"),
    ("### [S] Integración con otros módulos", "Especificar integración con M131 (Créditos)", "x"),

    # --- FAMILIA F — Revision periodica (4) ----------------------------------
    ("### [S] Revisión periódica", "Definir frecuencia de revisión (cada 3 meses)", "x"),
    ("### [S] Revisión periódica", "Definir responsable de revisión (equipo de diseño)", "?"),
    ("### [S] Revisión periódica", "Diseñar proceso de documentación de cambios", "?"),
    ("### [S] Revisión periódica", "Diseñar proceso de comunicación de cambios al equipo", "?"),

    # --- FAMILIA G — Ejemplos de aplicacion (5) ------------------------------
    ("### [S] Ejemplos de aplicación", "Diseñar ejemplo 1: decisión de agregar combate", "?"),
    ("### [S] Ejemplos de aplicación", "Diseñar ejemplo 3: decisión de ampliar mapa", "?"),
    ("### [S] Ejemplos de aplicación", "Documentar resultado de ejemplo 1 (aprobado)", "?"),
    ("### [S] Ejemplos de aplicación", "Documentar resultado de ejemplo 2 (aprobado con modificación)", "x"),
    ("### [S] Ejemplos de aplicación", "Documentar resultado de ejemplo 3 (aprobado con condición)", "?"),

    # --- FAMILIA H — Definicion de cozy (1) ----------------------------------
    ("### [S] Documentación de filosofia_cozy.md", "Diseñar definición de cozy", "x"),

    # --- FAMILIA I — Documentacion de proceso_revision.md (5) -----------------
    ("### [S] Documentación de proceso_revision.md", "Diseñar formato de revisión de decisión", "x"),
    ("### [S] Documentación de proceso_revision.md", "Diseñar campo de justificación", "x"),
    ("### [S] Documentación de proceso_revision.md", "Diseñar campo de aprobación", "x"),
    ("### [S] Documentación de proceso_revision.md", "Diseñar campo de fecha", "x"),
    ("### [S] Documentación de proceso_revision.md", "Diseñar campo de responsable", "x"),

    # --- FAMILIA J — desviaciones_justificadas.md (2) -------------------------
    ("### [S] Documentación de desviaciones_justificadas.md", "Diseñar tabla de desviaciones justificadas", "x"),
    ("### [S] Documentación de desviaciones_justificadas.md", "Diseñar ejemplo de desviación justificada", "?"),

    # --- FAMILIA K — Documentacion de licencias_assets.md (7) ----------------
    ("### [S] Documentación de licencias_assets.md", "Diseñar formato de registro de licencias", "x"),
    ("### [S] Documentación de licencias_assets.md", "Diseñar campos: asset, licencia, atribución, fuente", "x"),
    ("### [S] Documentación de licencias_assets.md", "Definir licencias comunes (MIT, CC0, CC BY, CC BY-SA, CC BY-NC, propietario)", "x"),
    ("### [S] Documentación de licencias_assets.md", "Diseñar proceso de verificación de licencias", "x"),
    ("### [S] Documentación de licencias_assets.md", "Diseñar proceso de registro de assets", "x"),
    ("### [S] Documentación de licencias_assets.md", "Diseñar proceso de inclusión de archivo de licencia", "?"),
    ("### [S] Documentación de licencias_assets.md", "Diseñar proceso de atribución en créditos", "x"),

    # --- FAMILIA L — Documentacion de knowledge_sharing.md (7) ---------------
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar prácticas de documentation", "x"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar prácticas de pair programming", "?"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar prácticas de knowledge sharing sessions", "?"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar herramientas de knowledge sharing", "x"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar proceso de documentación de arquitectura", "x"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar proceso de pair programming", "?"),
    ("### [S] Documentación de knowledge_sharing.md", "Diseñar proceso de knowledge sharing sessions", "?"),

    # --- FAMILIA M — Checklist de revision contra principios (8) --------------
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión respeta la filosofía cozy?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión no castiga al jugador por jugar poco?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión no obliga a optimizar constantemente?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión aporta calidad, no solo cantidad?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión no sacrifica rendimiento por bells and whistles?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión tiene propósito claro?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión no depende de servicios externos sin fallback?", "x"),
    ("### [S] Checklist de revisión contra principios", "Diseñar ítem: ¿Esta decisión no introduce dependencia crítica de una sola persona?", "x"),

    # --- FAMILIA N — Metricas de cumplimiento (3) ----------------------------
    ("### [S] Métricas de cumplimiento", "Definir métrica: número de desviaciones justificadas por mes", "?"),
    ("### [S] Métricas de cumplimiento", "Definir objetivo: 100% de decisiones críticas revisadas", "?"),
    ("### [S] Métricas de cumplimiento", "Definir objetivo: < 5% de desviaciones justificadas por mes", "?"),

    # --- FAMILIA O — Proceso de revision periodica (4) -----------------------
    ("### [S] Proceso de revisión periódica", "Definir frecuencia: cada 3 meses", "x"),
    ("### [S] Proceso de revisión periódica", "Definir responsable: equipo de diseño", "?"),
    ("### [S] Proceso de revisión periódica", "Diseñar paso 5: documentar cambios y justificaciones", "?"),
    ("### [S] Proceso de revisión periódica", "Diseñar paso 6: comunicar cambios al equipo", "?"),
]

APENDICE_MARKER = "## Verificación SB-01 (space-bunny-alpha, 2026-10-04)"

VIEJO_TOTALES = (
    "**Total de ítems:** 189\n"
    "**Ítems resoltos por documentación:** 189\n"
    "**Ítems pendientes de implementación:** 0 (implementación inmediata posible)\n"
    "**Totales:** 202 ítems · Completados: 115 · Pendientes: 87 · No resueltos: 0."
)

NUEVO_TOTALES = (
    "**Total de ítems del cuerpo:** 202 marcas (`[x]` / `[ ]` / `[?]`)\n"
    "**Nota de honestidad (SB-01, 2026-10-04):** el bloque anterior declaraba\n"
    "\"189 ítems · 189 resueltos por documentación · 0 pendientes\", cifra **falsa** que\n"
    "contradecía el conteo de marcas del propio archivo (115 `[x]` / 87 `[ ]`). Fue el primer\n"
    "hallazgo de la auditoría de atria-dawn-preview\n"
    "(`Mensajes entre modelos/atria-dawn-s2/06-...-m152-deuda-limpia-bug091-verificado.md` §1) y\n"
    "queda corregido aquí. **Conteo real tras SB-01: 173 `[x]` · 29 `[?]` = 202.**\n"
    "**Totales:** 202 ítems · Completados: 173 · No resueltos: 29 · Pendientes: 0 sin dueño."
)


def cargar(ruta):
    with io.open(ruta, "r", encoding="utf-8", newline="") as f:
        return f.read()


def guardar(ruta, texto):
    with io.open(ruta, "w", encoding="utf-8", newline="") as f:
        f.write(texto)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--aplicar", action="store_true")
    args = ap.parse_args()
    if args.check == args.aplicar:
        ap.error("usar --check o --aplicar")

    lineas = cargar(CHECKLIST).split("\n")

    # indice de la cabecera de seccion de cada linea
    seccion_de = {}
    actual = None
    for i, l in enumerate(lineas):
        if l.startswith("### "):
            actual = l.rstrip()
        seccion_de[i] = actual

    plan = {}
    problemas = []
    for seccion, texto_item, marca in VEREDICTOS:
        prefijo = "- [ ] " + texto_item
        cands = [
            i for i, l in enumerate(lineas)
            if seccion_de[i] == seccion and l.startswith(prefijo)
        ]
        if len(cands) != 1:
            problemas.append(
                u"[%s] %r -> %d coincidencias" % (seccion, texto_item, len(cands))
            )
            continue
        if cands[0] in plan:
            problemas.append(u"linea %d ya asignada (%r)" % (cands[0], texto_item))
            continue
        plan[cands[0]] = (marca, seccion, texto_item)

    if problemas:
        print("ABORTA: %d item(s) no localizados de forma univoca:" % len(problemas))
        for p in problemas:
            print("  - %s" % p)
        return 1

    n_x = sum(1 for v in plan.values() if v[0] == "x")
    n_q = sum(1 for v in plan.values() if v[0] == "?")
    print("SB-01: %d veredictos localizados 1:1  ->  [x]=%d  [?]=%d  (total %d)"
          % (len(plan), n_x, n_q, n_x + n_q))
    if len(plan) != 87:
        print("ABORTA: se esperaban 87 veredictos, hay %d" % len(plan))
        return 1

    nuevas = list(lineas)
    for idx, (marca, _s, _t) in plan.items():
        assert nuevas[idx].startswith("- [ ] "), nuevas[idx]
        nuevas[idx] = "- [" + marca + "] " + nuevas[idx][6:]

    joined = "\n".join(nuevas)

    # recuento final sobre el texto resultante (verificacion independiente)
    tot_x = joined.count("- [x] ")
    tot_q = joined.count("- [?] ")
    tot_e = joined.count("- [ ] ")
    print("  recuento en el archivo resultante: [x]=%d [?]=%d [ ]=%d  (suma %d)"
          % (tot_x, tot_q, tot_e, tot_x + tot_q + tot_e))
    if tot_x + tot_q + tot_e != 202:
        print("ABORTA: el cuerpo deberia tener 202 marcas, tiene %d"
              % (tot_x + tot_q + tot_e))
        return 1
    if tot_e != 0:
        print("ABORTA: quedan %d lineas `[ ]` sin veredicto" % tot_e)
        return 1

    crlf = "\r\n" in joined
    nl = "\r\n" if crlf else "\n"

    # Reemplazo del bloque Totales POR LINEAS (robusto a finales de linea).
    lineas2 = joined.split(nl)
    ini = fin = None
    for i, l in enumerate(lineas2):
        s = l.strip()
        if s.startswith("**Total de ítems:**") and ini is None:
            ini = i
        if s.startswith("**Totales:** 202 ítems") and ini is not None:
            fin = i
            break
    if ini is not None and fin is not None and fin >= ini:
        nuevo_bloque = [b + "\r" if crlf else b
                        for b in NUEVO_TOTALES.split("\n")]
        lineas2[ini:fin + 1] = nuevo_bloque
        joined = nl.join(lineas2)
        print("  bloque Totales: CORREGIDO lineas %d-%d (claim falso '189/0 pendientes')"
              % (ini, fin))
    else:
        print("  AVISO: bloque Totales no encontrado (ini=%s fin=%s); se deja intacto"
              % (ini, fin))

    if APENDICE_MARKER in joined:
        print("  apendice: ya presente, no se duplica")
    else:
        with io.open(APENDICE, "r", encoding="utf-8") as f:
            apendice = f.read().replace("\r\n", "\n").replace("\n", nl)
        joined = joined.rstrip() + nl + nl + "---" + nl + nl + apendice.rstrip() + nl
        print("  apendice: agregado (%d lineas)" % len(apendice.split(nl)))

    if args.check:
        print("DRY-RUN: no se escribio nada.")
        return 0

    guardar(CHECKLIST, joined)
    with io.open(CHECKLIST, "rb") as f:
        if f.read(3) == b"\xef\xbb\xbf":
            print("ERROR: se escribio BOM (AGENTS.md 28).")
            return 2
    print("ESCRITO: %s  (UTF-8 sin BOM verificado)" % CHECKLIST)
    return 0


if __name__ == "__main__":
    sys.exit(main())