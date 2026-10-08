# -*- coding: utf-8 -*-
# Reserva M37 en guia 08 (fila al tope de "## Reserva actual") y ESTADO-PARALELO (entrada al tope).
import io

# --- 1. Guia 08: insertar fila M37 tras el separador de la tabla "Reserva actual" ---
G8 = "DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md"
raw = open(G8, "rb").read()
crlf_b = raw.count(b"\r\n")
text = raw.decode("utf-8")
lines = text.split("\r\n")

FILA = "| M37 Museos y Colecciones | \U0001F535 En curso (iter. 4: reserva 2026-10-03 19:40) | kimi-k3 (Verdent) | F7 (producci\u00f3n de contenido) | V0 | M36 \u2705 + M34/M25/M55 \U0001F7E1 + M59 \u2705 + M71 \u2705 (n\u00facleo Registry+DonationService de glm-5.3-flash, baseline 0 fallos) | Iter. 4: versionado del bloque de guardado + exposici\u00f3n arte RF5 + museum.tscn (4 salas) + ExhibitSlot instanciado + flujos de donaci\u00f3n/persistencia + suite ampliada + gate quality.yml en rojo | game/isla-ancestral/scripts/museum/, game/isla-ancestral/scenes/interior/museum/, game/isla-ancestral/data/museum/, DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/, Logs/<n>-* |"

# localizar el separador de la tabla "## Reserva actual"
pos = None
for i, ln in enumerate(lines):
    if ln.startswith("## Reserva actual"):
        for j in range(i, min(i + 12, len(lines))):
            if lines[j].startswith("|---"):
                pos = j
                break
        break
assert pos is not None, "no se encontro la tabla Reserva actual"
assert not lines[pos + 1].startswith("| M37 "), "fila M37 ya existe"
lines.insert(pos + 1, FILA)
out = "\r\n".join(lines).encode("utf-8")
assert out.count(b"\r\n") == crlf_b + 1
open(G8, "wb").write(out)
print("guia 08 OK: fila M37 insertada tras linea %d (CRLF %d -> %d)" % (pos + 1, crlf_b, crlf_b + 1))

# --- 2. ESTADO-PARALELO: prepend entrada al tope ---
EP = "Mensajes entre modelos/ESTADO-PARALELO.md"
raw = open(EP, "rb").read()
crlf_b = raw.count(b"\r\n")
lf_b = raw.count(b"\n")

ENTRADA = """## 2026-10-03 19:40 \u2014 kimi-k3 (Moonshot AI) / Verdent \u2014 M37 Museos y Colecciones RESERVADO (iter. 4)

**Estado:** reservado. `CHECKLIST-GLOBAL.md` fila 37: \U0001F7E2 Disponible \u2192 **\U0001F535 En curso**, Agente actual \u2192 kimi-k3, \u00faltima actividad 2026-10-03 19:40.

**Por qu\u00e9 este m\u00f3dulo (asignaci\u00f3n del coordinador):** mi M70 qued\u00f3 liberado \U0001F7E1 (iter. 3, Log 1185, 155/198 \u00b7 5 [ ] bloqueados por deps externas \u00b7 38 [?] con due\u00f1o). El espejo stale de M106/M122 de mi backlog se ignora (ambos \u2705 por otros modelos). Por encaje (coder, V0, complejidad 3, dep M36 \u2705 satisfecha), el coordinador me asigna M37. Perfil medido: TB 2.1 88.3, 5/5 tareas rc=0, cero sobre-cierre; NO QA \u00a721.8 (hy3), NO orquestaci\u00f3n MCP/web (Atria), NO arte 3D (Hy4).

**Hallazgo \u2014 fila desplazada (mismo defecto de 62/70/91/59/54/43/17).** La fila 37 ten\u00eda `Prioridad = "glm-5.3-flash"` (un Recom viejo metido en la columna de Prioridad) y el Recom real desplazado. Reconstruida a las 11 columnas can\u00f3nicas: Prioridad = Media, Recom/Agente actual = kimi-k3, \u00daltima actividad = timestamp real. Edici\u00f3n byte-exacta con Python rb/wb: **CRLF 231\u2192231, CR 449\u2192449, sin BOM**, `git diff --numstat` = **1/1**.

**Registros actualizados (los 4):** `CHECKLIST-GLOBAL.md` fila 37 \u00b7 `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M37 al tope de `## Reserva actual`) \u00b7 `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` (bloque `## Reserva actual` actualizado in-place; ya exist\u00eda al tope, sin desplazar L##) \u00b7 esta entrada.

**Baseline verificado:** `test_museo.gd` \u2192 **0 fallos** con `C:\\Temp\\godot\\godot472.exe --headless --path game/isla-ancestral --script res://scripts/museum/test_museo.gd`. N\u00facleo (CollectionRegistry + DonationService autoloads, persistencia M59 secci\u00f3n "collections") s\u00f3lido desde glm-5.3-flash (iters 1-3).

**Alcance iter. 4:** 36 [x] / 112 [ ] / 0 [?] = 148. Arranco por arquitectura: versionado del bloque de guardado (C.12: `version` en get_save_data + migraci\u00f3n), exposici\u00f3n "arte" RF5 (data-driven en exhibiciones.json), escena museum.tscn + 4 salas + ExhibitSlot instanciado (D/E, integrando TerrainLocator de scripts/world para posicionar \u2014 NUNCA radio hardcodeado; isla 5120\u00b2 centro (2560,2560) via mundo_raiz.gd), flujos F/G, persistencia K, tests N. Cada iteraci\u00f3n: n\u00famero de log del pool, implementar, suite headless, log, commit con pathspec. Sin QA \u00a721.8 (autor != verificador).

**No tocado (carrera de 6 agentes):** `scripts/interacciones/` (M70 m\u00edo, liberado), `scripts/construccion/` (DeepSeek M17), `scripts/saving/` (M59 cerrado), `scripts/mapa` + `ui/widgets/minimap*` (M54/agnes), `scripts/audio/*` (M43/mimo), `scripts/legal` + docs 125/79 (agnes). `CHECKLIST-GLOBAL.md` solo fila 37.

"""

# detectar el EOL de la primera linea y replicarlo
first_eol = b"\r\n" if raw.startswith(raw.split(b"\n", 1)[0] + b"\r\n") else b"\n"
eol = first_eol.decode()
bloque = ENTRADA.replace("\n", eol).encode("utf-8") + eol.encode()
out = bloque + raw
open(EP, "wb").write(out)
print("ESTADO-PARALELO OK: entrada prependida (EOL de la 1ra linea: %r)" % first_eol)
