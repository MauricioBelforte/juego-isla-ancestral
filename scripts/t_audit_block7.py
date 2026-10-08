# -*- coding: utf-8 -*-
import glob
NOTES = {
    "60": ("test_datos_m60_iter5.gd 40/0", "scripts/datos/ + scripts/construccion/build_manager.gd en disco (iter. 5 es posterior a BUG-091, verificado). 4 [?] = integración externa (M62 UI, M63 <2s, M15/16/33 .tres, Profiler) — legítimos"),
    "39": ("test_tiendas_iter_glm.gd 39/0", "scripts/shops/ + catalogos. El 1 [ ] aislado = 'Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame' (necesita hardware/profiling, no es [x] inflado). H2: los 8 item_ids de M39 → M15 (deuda BUG-106, 7/8 resueltos, falta pergamino_rec_tela_lino)"),
}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 7)\n"
            "Los [x] auditados contra disco y sustentados; 0 degradaciones. Evidencia: %s = %s.\n" % (test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
