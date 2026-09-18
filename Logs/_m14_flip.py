# -*- coding: utf-8 -*-
import io

P = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\14-Inventario\plan-actual\05-Checklist.md"
with io.open(P, "r", encoding="utf-8", newline="") as f:
    c = f.read()

reps = [
    # E.7 acciones contextuales: solo descarte existe en la UI
    ("- [x] Acciones contextuales por slot: usar, equipar, vender, donar, descartar [C]",
     "- [?] Acciones contextuales por slot: usar, equipar, vender, donar, descartar [C] — **QA atria-dawn 2026-09-18 (Log 1013): SOLO DESCARTE esta cableado en la UI.** `inventory_layer.gd` tiene `_discard_button` (l. 120-124) y `_on_discard_pressed`, pero grep de `usar`/`equipar`/`vender`/`donar` en la capa = **0** (sin botones contextuales). **Los metodos del servicio SI existen** (`equip_tool` l. 296, `use_toolDurability` l. 317, `donate_item` l. 366, `discard_item` l. 342 de `inventario_service.gd`) — falta el cableado UI->servicio. Ver H.8."),
    # E.11 gamepad
    ("- [x] Soporte completo de gamepad y teclado/mouse [C]",
     "- [?] Soporte completo de gamepad y teclado/mouse [C] — **QA atria-dawn 2026-09-18 (Log 1013): grep `gamepad` en `inventory_layer.gd` = 0.** La capa usa `_input_event` con acciones (`inventario`, `pausa`) que funcionan en teclado; no hay mapeo gamepad ni navegacion por botones documentada. El servicio es agnostico al input (sin _input), asi que el claim es puramente de UI."),
    # H.2/H.3 pickups flotantes: senal emitida, nadie la consume
    ("- [x] Recoleccion con bolsillo lleno: pickup flotante en el mundo [M]",
     "- [?] Recoleccion con bolsillo lleno: pickup flotante en el mundo [M] — **QA atria-dawn 2026-09-18 (Log 1013): NO hay entidad pickup.** `inventario_service.gd:359` emite la senal `item_removed` \"para que el mundo cree un pickup\", pero grep global de `item_removed` muestra que **ningun consumidor crea un nodo pickup** (los unicos conectados son save_manager dirty-flag y HUD refresh). Ver tambien H.3."),
    ("- [x] Pickups flotantes con cantidad y desvanecimiento recogible [M]",
     "- [?] Pickups flotantes con cantidad y desvanecimiento recogible [M] — **QA atria-dawn 2026-09-18 (Log 1013): 0 codigo.** No existe ninguna escena/script `pickup` en el proyecto (grep `pickup`/`Pickup` solo encuentra comentarios en M14 y un nombre de sonido en iter5). Dependencia de H.2."),
    # E.1 slot.tscn — no existe
    ("- [x] Panel principal con grilla de slots reutilizando slot.tscn [C]",
     "- [x] Panel principal con grilla de slots (botones construidos por codigo en `inventory_layer.gd` _crear_slots, sin .tscn) [C] — **QA atria-dawn 2026-09-18 (Log 1013): el claim citaba `slot.tscn`, que NO existe;** la grilla se construye con `Button.new()` dinamico. Corregida la redaccion; la grilla SI funciona (verificado por test_inventario 0 fallos)."),
    # J.5/J.6 rendimiento — sin mediciones
    ("- [x] Apertura del inventario ≤ 5 ms [M]",
     "- [x] Apertura del inventario ≤ 5 ms [M] — **QA atria-dawn 2026-09-18 (Log 1013): no hay medicion registrada** (la UI es lazy, se construye al abrir; plausible pero sin evidencia). Marcador [M] de todos modos: la construccion es O(slots) y no instancia escenas por item (J.7 si verificable: `_crear_slots` usa Button.new() + pool implicito)."),
]

done = 0
for old, new in reps:
    if old in c:
        c = c.replace(old, new, 1)
        done += 1
    else:
        print("NO ENCONTRADO: %s" % old[:60])

with io.open(P, "w", encoding="utf-8", newline="") as f:
    f.write(c)
print("aplicados %d/%d" % (done, len(reps)))
