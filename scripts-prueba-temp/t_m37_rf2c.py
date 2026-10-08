# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md"
c = open(p, encoding="utf-8").read()
marks = {
    "- [ ] Reconstruccion de vitrinas visibles al cargar partida [M]":
        "- [x] Reconstruccion de vitrinas visibles al cargar partida [M] (RF2c: reconstruir_desde_guardado + test RF3, agnes)",
    "- [ ] Carga de partida con vitrinas parcialmente pobladas [M]":
        "- [x] Carga de partida con vitrinas parcialmente pobladas [M] (RF2c: solo lo guardado, test RF3 b2, agnes)",
    "- [ ] Reconstruccion posicional de objetos en vitrinas al cargar [M]":
        "- [x] Reconstruccion posicional de objetos en vitrinas al cargar [M] (RF2c: place_item por pieza guardada, test RF3, agnes)",
    "- [ ] Test: guardar y cargar conserva piezas y vitrinas [M]":
        "- [x] Test: guardar y cargar conserva piezas y vitrinas [M] (RF2c: test_museo_rf3.gd 0/0 + idempotencia + casos limite, agnes)",
}
n = 0
for old, new in marks.items():
    if old in c:
        c = c.replace(old, new, 1); n += 1
    else:
        print("  NO encontre:", old[:45])
if "NOTA-AGNES RF2c" not in c:
    c += ("\n## NOTA-AGNES RF2c (persistencia + reconstruccion posicional, 2026-10-08, agnes-3-flash)\n"
          "- Museum.reconstruir_desde_guardado(): al cargar (tras restore_save_data del CollectionRegistry), "
          "re-puebla las vitrinas con las piezas guardadas (place_item valida slot libre + pertenece, NUNCA sobrescribe). "
          "Casos limite: expo huorfana (ignora), pieza sin vitrina (salta), poblacion parcial (solo lo guardado), idempotencia.\n"
          "- Persistencia: CollectionRegistry (ISaveProvider 'collections') ya tenia get_save_data/restore_save_data + "
          "register_provider; el Museo se sincroniza via refresh_from_registry (ahora delega a reconstruir_desde_guardado). "
          "No invente un save nuevo.\n"
          "- test_museo_rf3.gd 0/0 EXIT 0 (save->load->reconstruir + idempotencia + expo huorfana + pieza inexistente + parcial). "
          "RF1/RF2 siguen 0/0.\n"
          "- L111 (Registro persistente) queda cubierto por el ISaveProvider del registry; lo dejo para que el director lo confirme en su flip.\n")
open(p, "w", encoding="utf-8").write(c)
print("marcados [x]:", n, "/ 4")
print("mojibake:", bool(re.search(r"Ã|Â|â€", c)))
# consumir numeros
head = [l for l in open("Logs/NUMEROS_DISPONIBLES.txt", encoding="utf-8").read().splitlines() if l.strip()]
logn = head[0]
def consume(path, num):
    l = open(path, encoding="utf-8").read().splitlines()
    open(path, "w", encoding="utf-8").write("\n".join([x for x in l if x.strip() not in (num,)]) + "\n")
consume("Mensajes entre modelos/agnes-3-flash/NUMEROS_DISPONIBLES.txt", "115")
consume("Logs/NUMEROS_DISPONIBLES.txt", logn)
print("115 + log", logn)
