# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

PROMOS = {
 "Definir contratos de interfaces entre capas": (
  "- [x] Definir contratos de interfaces entre capas: `IInteractable`, `ITienda`, `ITemplo`, `IViajable` [M] — "
  "COMPLETADO 2026-10-14 (step-5-kilocode): `IInteractable` preexistia (M70) y se crearon las 3 que faltaban "
  "(`scripts/interfaces/i_tienda.gd`, `i_templo.gd`, `i_viajable.gd`) con el patron de default neutro de "
  "`IInteractable` v2. Consumidores previstos identificados: ShopManager/shop.gd (M39), travel_service.gd (M28), "
  "templos (M26, sin script aun). Ver seccion 7.1 de 04-Codigo.md."),
 "Definir `SesionMaster` como unico orquestador": (
  "- [ ] Definir `SesionMaster` como \u00fanico orquestador de arranque (bootstrapping) [M] \u2014 PARCIAL 2026-10-13 "
  "(step-5-kilocode): `scripts/core/sesion_master.gd` CREADO con la maquina de estados "
  "(INACTIVA/INICIALIZANDO/ACTIVA/CERRANDO/CERRADA), inicializacion por capas (Infra \u2192 World Services \u2192 "
  "Managers \u2192 UI), cierre en orden inverso y registro via `ServiceRegistry`. Falta la ACTIVACION: el juego "
  "arranca hoy con `main_island.tscn` + ~20 autoloads y no hay master activo; activarlo como autoload "
  "requiere validacion en runtime. Ver seccion 7.2 de 04-Codigo.md."),
 "Documentar el flujo de sesion": (
  "- [x] Documentar el flujo de sesi\u00f3n: men\u00fa \u2192 continuar/nuevo \u2192 carga de zona [M] \u2014 COMPLETADO 2026-10-13 "
  "(step-5-kilocode): documentado en la seccion 7.3 de 04-Codigo.md \u2014 menu principal \u2192 continuar/nuevo \u2192 "
  "`SesionMaster.inicializar(nueva_partida)` \u2192 carga de zona (`ZonaManager`, M63) \u2192 mundo activo \u2192 tick \u2192 "
  "cierre en orden inverso, con la UI deshabilitada durante la carga (regla M53)."),
 "Documentar el modo \"degradacion\" si un servicio falla": (
  "- [x] Documentar el modo \"degradaci\u00f3n\" si un servicio falla al arrancar (M66) [S] \u2014 COMPLETADO 2026-10-13 "
  "(step-5-kilocode): seccion 7.4 de 04-Codigo.md \u2014 la sesion NO aborta: se registra el fallo (GameLogger + "
  "telemetria M105), el servicio queda degradado con default neutro del contrato, si el fallo es de guardado "
  "se ofrece recuperar copia o partida nueva (patron de `integridad_save`/M66 y `SoftlockGuard`), y la sesion "
  "continua degradada con los fallos documentados para el GONOGO de M140."),
}

def norm(s):
    return (s.replace("\u00e1", "a").replace("\u00e9", "e").replace("\u00ed", "i")
             .replace("\u00f3", "o").replace("\u00fa", "u").replace("\u00f1", "n")
             .replace("\u00c1", "A").replace("\u00c9", "E").replace("\u00cd", "I")
             .replace("\u00d3", "O").replace("\u00da", "U").replace("\u00d1", "N")
             .replace("\u00fc", "u").replace("\u00dc", "U").replace("\u00bf", "?")
             .replace("\u2192", "->").replace("\u2014", "-").replace("\u201c", '"')
             .replace("\u201d", '"').replace("\u2019", "'"))

n_promo, n_nota = 0, 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[[ x]\]", l):
        continue
    ln = norm(l)
    for clave, nuevo in PROMOS.items():
        if norm(clave) in ln:
            if nuevo.startswith("- [x]"):
                if l.startswith("- [ ]"):
                    lines[i] = nuevo
                    n_promo += 1
            else:
                if l.startswith("- [ ]"):
                    lines[i] = nuevo
                    n_nota += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("promovidos a [x]:", n_promo, "| anotados (parcial):", n_nota)

# Totales: 10+3=13 [x], 130-3=127 [ ], 2 [?]
t = "\n".join(lines)
t = t.replace("Completados: 10 \u00b7 Pendientes: 130 \u00b7 No resueltos: 2",
              "Completados: 13 \u00b7 Pendientes: 127 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos ahora: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
