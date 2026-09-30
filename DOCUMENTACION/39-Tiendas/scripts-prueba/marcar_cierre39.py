# -*- coding: utf-8 -*-
"""M39 — reconciliacion de marcas del cierre (Log 1120, glm-5.3-flash / Cline).

Marca `[x]` 35 items del 05-Checklist.md que ya estaban MATERIALMENTE hechos
pero seguian `[ ]` (marcas stale): documentacion 01/02 ya escrita, diagramas
2.1-2.4 y contrato de señales en 03-Diseno, UI real en shop_ui.gd (367 lineas,
conecta las 5 señales), i18n en mensajes, y pruebas ya definidas/verdes en
test_tiendas + test_tiendas_iter_glm. NO toca items sin evidencia.

Idempotente: solo actua sobre `- [ ] <texto exacto>`.
Backup previo en Obsoletos/ con timestamp.
"""
from __future__ import annotations

import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CHECKLIST = RAIZ / "plan-actual" / "05-Checklist.md"
OBSOLETOS = RAIZ / "Obsoletos"

# (texto exacto del item tras "- [ ] ", nota de evidencia)
ITEMS = [
    # J. Analisis del dominio — documentado en 02-Analisis.md (§2 alternativas / §3 decisiones / §4 riesgos)
    ("Analizar tiendas como atributos de NPCs (identidad, amistad M20, interacción) [M]",
     "cierre: D1 + alt. «tiendas sin dueño» descartada — 02 §2-3"),
    ("Analizar catálogos por NPC: venta + recompra selectiva [M]",
     "cierre: D3 + alt. «catálogo único por tipo» descartada — 02 §2-3"),
    ("Analizar horarios y descansos como consulta pura al calendario [M]",
     "cierre: D4 + alt. «descansos fijos globales» descartada — 02 §2-3"),
    ("Analizar precios dinámicos vs fijos: delegados a M38 con variabilidad diaria [M]",
     "cierre: D7 + alt. «precios por tienda» descartada — 02 §2-3"),
    ("Analizar compra/venta con validaciones en cascada y atomicidad [M]",
     "cierre: D8 + riesgo «transacción a medias» — 02 §3-4"),
    ("Analizar eventos y ferias como etapa temporal reversible [M]",
     "cierre: D10 + riesgo «feria que pisa stock» — 02 §3-4"),
    ("Evaluar catálogo único por tipo y descartarlo: los puestos serían clones [S]",
     "cierre: alternativa descartada — 02 §2"),
    ("Evaluar precios propios por tienda y descartarlos: divergencia con M38 [S]",
     "cierre: alternativa descartada — 02 §2"),
    # I. RNF — UI real y i18n verificados en codigo
    ("RNF6: desacoplamiento absoluto de la UI, comunicación por señales [M]",
     "cierre: señales SM L29-38; shop_ui.gd 367 líneas conecta L36-40"),
    ("RNF7: claves i18n para tiendas, catálogos y mensajes [S]",
     "cierre: nombre_clave_i18n + _motivo_texto con _t() — shop_ui L313-326"),
    # K. Diseno — 03-Diseno.md ya tiene los 4 diagramas + contrato + balance
    ("Diagrama de flujo de compra completo (2.1) documentado [S]", "cierre: 03-Diseno §2.1"),
    ("Diagrama de flujo de venta completo (2.2) documentado [S]", "cierre: 03-Diseno §2.2"),
    ("Diagrama de reabastecimiento diario (2.3) documentado [S]", "cierre: 03-Diseno §2.3"),
    ("Diagrama de aparición de mercader viajero (2.4) documentado [S]", "cierre: 03-Diseno §2.4"),
    ("Contrato de señales tabulado con emisores y consumidores [M]",
     "cierre: 03-Diseno §5 — tabla emisor/consumidores"),
    ("Tabla de balance por tipo de tienda documentada [M]", "cierre: 03-Diseno §8 — tabla por tipo"),
    # L. Integracion M14
    ("Operaciones de ítems en diccionarios {item_id: cantidad} compatibles con M14 [S]",
     "cierre: SM L245 agregar_items({item_id: cantidad})"),
    # M. M19/M20
    ("La amistad (M20) afecta descuentos vía M38, no en este módulo [S]",
     "cierre: SM L236 pasa npc_duenio_id a M38; el descuento lo aplica M38"),
    # N. M29/M30
    ("Sin estados de apertura manuales que puedan desincronizar (D4) [M]",
     "cierre: shop.abierta_ahora = esta_abierta() SM L153; sin flags manuales"),
]

ITEMS += [
    # P. UI
    ("UI consume señales compra/venta/inventario_tienda_cambio [M]",
     "cierre: shop_ui L36-40 conecta las 5 señales"),
    ("Feedback de rechazo con motivo legible y no duro [S]",
     "cierre: _on_tx_rechazada + _motivo_texto i18n — shop_ui L309-326"),
    ("Jugador con 0 monedas: puede vender para obtener ingresos (básicos siempre recomprados) [M]",
     "cierre: test_tiendas _test_rechazos L86-89 — vende con 0 AO"),
    # R. Optimizacion
    ("esta_abierta como cálculo aritmético puro sin alocaciones [S]",
     "cierre: shop.gd L46-60 consulta pura sin alocación"),
    ("Transacciones sin instanciación de nodos (diccionarios + llamadas M38/M14) [M]",
     "cierre: shop_manager 0 .instantiate(); flujo por diccionarios"),
    # S. Documentacion entregada
    ("Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF18 [M]",
     "cierre: 309 líneas, problema/objetivo/alcance/RF1-RF18, firmado"),
    ("Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M]",
     "cierre: 139 líneas, dominio/alternativas/decisiones/riesgos, firmado"),
    ("Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]",
     "cierre: 04-Codigo §Notas del Agente"),
    ("Crear 05-Checklist.md con los 181 ítems completados y marcadores de esfuerzo [M]",
     "cierre: 181 ítems con marcadores [S]/[M]/[C]"),
    ("Firmar todos los archivos con modelo y plataforma [S]",
     "cierre: firma Modelo+Plataforma en los 5 archivos"),
    ("Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]",
     "cierre: 02/03 idénticos por hash; 01/04/05 divergen por cambios firmados"),
    # T. Testings
    ("Definir prueba de venta normal: recompra, monedas y acumulación en tienda [M]",
     "cierre: test_tiendas _test_venta_basica + G257 acumular_stock"),
    ("Definir prueba de horarios: bordes de hora, descansos y ítem cerrado [M]",
     "cierre: test_tiendas_iter_glm _test_horarios_real"),
    ("Definir prueba de rotación estacional: semillas fuera de temporada ausentes [M]",
     "cierre: G68/G75 — canales estación/eventos"),
    ("Definir prueba de edge cases: cero fondos, inventario lleno, cantidad inválida [M]",
     "cierre: T86 cero fondos · G186 inv. lleno · CANTIDAD_INVALIDA"),
    ("Definir prueba de integración con M38: precios idénticos en tienda y mercado [M]",
     "cierre: G225 precio cobrado == recargado de M38"),
]


def main() -> int:
    seco = "--dry-run" in sys.argv
    texto = CHECKLIST.read_text(encoding="utf-8")

    marcados = 0
    faltantes: list[str] = []
    for item, nota in ITEMS:
        viejo = "- [ ] " + item
        nuevo = "- [x] " + item + f" *(cierre glm-5.3-flash — Log 1120: {nota})*"
        if viejo in texto:
            texto = texto.replace(viejo, nuevo, 1)
            marcados += 1
        else:
            faltantes.append(item)

    print(f"ITEMS: {len(ITEMS)} | marcados: {marcados} | faltantes: {len(faltantes)}")
    for f in faltantes:
        print(f"  FALTA: - [ ] {f}")
    if seco:
        print("DRY-RUN: sin cambios (quitar --dry-run para aplicar)")
        return 0 if not faltantes else 2
    OBSOLETOS.mkdir(exist_ok=True)
    sello = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    shutil.copy2(CHECKLIST, OBSOLETOS / f"{sello}_05-Checklist.md")
    CHECKLIST.write_text(texto, encoding="utf-8")
    print("APLICADO: checklist actualizado + backup en Obsoletos/")
    return 0 if not faltantes else 2


if __name__ == "__main__":
    raise SystemExit(main())
