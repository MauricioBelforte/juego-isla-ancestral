# -*- coding: utf-8 -*-
"""M39 — marcado de checklist iter. glm (Log 1017, glm-5.3-flash / Cline).

Marca `[x]` los ítems del 05-Checklist.md implementados y verificados con las
3 suites headless verdes de hoy (test_tiendas / test_loop_economico /
test_tiendas_iter_glm, todos EXIT=0). Idempotente: solo toca `- [ ]` exactos.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

CHECKLIST = Path(__file__).resolve().parent.parent / "plan-actual" / "05-Checklist.md"

# Prefijos exactos de ítem (después de "- [ ] ")
ITEMS = [
    # B. Catálogos — validaciones en registro (catalogo_tiendas L25/L26/L58-63)
    "Validar en editor que cada item_id del catálogo exista en M15 [M]",
    "Validar en editor que no haya ítems duplicados dentro del mismo catálogo [S]",
    # C. Tipos
    "Tienda general: mezcla flexible de comida, decoración y cotidianos [M]",
    "Mercader viajero: sin local fijo, catálogo rodante y recargos dentro de topes de M38 [M]",
    # A
    "Nombrar los cinco tipos de tienda: semillas, pescadería, ferretería, general y mercader viajero [M]",
    "Fijar la regla de oro: el módulo jamás define precios, solo consulta M38 [M]",
    # F. Horarios
    "RF5: definir dias_descanso como días cerrados explícitos por tienda [M]",
    "Emitir tienda_cerrada con próxima apertura para el cartel de la UI [M]",
    "Probar borde de hora exacta: apertura a las 09:00 incluida, cierre a las 17:00 excluido [M]",
    "Probar día de descanso: tienda cerrada todo el día aunque esté en horario [M]",
    "Mercader viajero: su \"horario\" es el calendario de aparición, no franja diaria [M]",
    # G. Stock y canalización
    "RF7: reabastecimiento diario por evento nuevo_dia_laborable de M29 [C]",
    "RF9: canalización en 5 etapas: base, estación, eventos, aforo, PRNG [C]",
    "Etapa base: materializar entradas del catálogo con rangos min/max [M]",
    "Etapa estación: descartar ítems fuera de temporada sin tocar básicos garantizados [M]",
    "Etapa eventos: agregar ítems solo_evento activos (ferias M73) [M]",
    "Etapa aforo: clamp min/max y peso_rareza (raros con menos ejemplares) [M]",
    "Etapa PRNG: variación determinista con semilla de partida (M29) [C]",
    # H. Precios (delegados a M38)
    "Precios jugador-vendedor distintos: compra (paga) vs venta (recibe) [M]",
    "Mercader viajero: recargos declarados pasados como parámetro a M38 [M]",
    "Nunca cachear precios entre operaciones: consulta fresca por operación [S]",
    "Jamás calcular precios dentro de tiendas (D7) [M]",
    "Total con clamp: cantidad válida > 0 y precio >= 1 garantizado por M38 [S]",
    # I. RNF
    "RNF9: transacciones atómicas: o ambas partes se mueven o ninguna [C]",
    # L. Integración M14
    "Compra entrega ítems vía Inventario.agregar_items [M]",
    "Venta remueve ítems vía Inventario.remover_items [M]",
    "Si remover_items falla, rechazar venta sin mover monedas [M]",
    # M
    "Tienda sin dueño válido = error de validación en editor [S]",
    # N. M29/M30
    "Consumir estacion_cambio para rotación estacional [M]",
    "Días de la semana 1-7 consistentes con el calendario de M29 [S]",
    "Recuperación de días perdidos al cargar partidas viejas [M]",
    # O. M38
    "precio_compra_vigente(item_id, npc_id) consumida en compras [M]",
    "precio_venta_vigente(item_id) consumida en ventas [M]",
    "Anti-grind y ventana de oferta resueltos internamente por M38 [S]",
    "Recargo de mercader viajero pasado como parámetro opcional a M38 [M]",
    # Q. Edge cases
    "Tienda cerrada: rechazo CERRADA sin efectos laterales [M]",
    "Día de descanso: cerrada aunque esté dentro de la franja horaria [M]",
    "Jugador sin fondos: rechazo SIN_FONDOS sin castigos ni mensajes duros [M]",
    "Cantidad inválida (0 o negativa): rechazo CANTIDAD_INVALIDA [S]",
    "Precio devuelto por M38 en 0 (no debería pasar): clamp defensivo >= 1 [S]",
    "Tienda sin dueño o catálogo nulo: error de validación en editor antes de runtime [M]",
    "Venta de un ítem no recomprado por la tienda: NO_RECOMPRA [S]",
    "Venta con menos ítems de los pedidos: SIN_ITEMS_JUGADOR sin tocar monedas [M]",
    "Mercader activo al guardar: al cargar sigue presente el mismo día [M]",
    # R. Optimización
    "Canalización solo en eventos de cambio de día/estación/evento, jamás por frame [M]",
    "Sin lecturas de disco en runtime: todo precargado [S]",
]


def main() -> int:
    texto = CHECKLIST.read_text(encoding="utf-8")
    marcados: list[str] = []
    faltantes: list[str] = []
    for item in ITEMS:
        viejo = "- [ ] " + item
        nuevo = "- [x] " + item + " *(iter. glm — Log 1017)*"
        if viejo in texto:
            texto = texto.replace(viejo, nuevo, 1)
            marcados.append(item[:70])
        else:
            faltantes.append(item)
    CHECKLIST.write_text(texto, encoding="utf-8")
    print(f"marcados: {len(marcados)}")
    for f in faltantes:
        print("NO ENCONTRADO:", f)
    total = texto.count("- [x]")
    abiertos = texto.count("- [ ]")
    print(f"totales 05-Checklist: {total} [x] / {abiertos} [ ]")
    return 0


if __name__ == "__main__":
    sys.exit(main())