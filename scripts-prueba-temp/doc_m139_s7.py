# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.7.1 Templo de Brisa — cierre de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 7 del checklist. Lo que ya existe en disco (verificado): el capitulo de historia
`scripts/eventos/data/capitulos/historia_c4_templo_brisa.tres` (gatillo `templo_brisa_abierto`,
7 sellos requeridos, capitulo 4) y la invariante anti-softlock
`scripts/core/invariants/puzzle_invariant.gd` (M66: resolubilidad en 30 s + reinicio del slot),
ademas de `softlock_guard.gd` / `softlock_rules.gd` y el catalogo de puzzles de
`scripts/templos/`.

**Acceso por la colina N:** 2 puzzles ambientales en la subida —
1) **semillas al viento**: soplar 3 tallos de semilla en orden de cercania (ensinanza la mecanica
de rafaga sin UI), 2) **antorchas de piedra**: encender 2 antorchas siguiendo la direccion del
viento. Ninguno bloquea la subida: se puede pasar y volver.

**Sala 1 "Las Velas":** 3 velas sobre una mesa de piedra. Hay que encenderlas en el orden que
marca la direccion de la rafaga del momento (N -> E -> S). Una vela mal encendida se apaga sola y
reintenta sin castigo.

**Feedback de las velas:** silbido de llama por vela (M42) y parpadeo de luz calida en proporcion
a la rafaga (M44). Los 3 componentes ya tienen modulos duenos.

**Sala 2 "El Carrillon":** 5 campanas de metal soplado. La melodia son 5 notas graves que se tocan
en el orden que susurra el lore de la sala (la misma que aparece en el capitulo 4). Error = la
campana suena muda y el puzzle continua.

**Feedback ASMR del carillon:** tonos puros con decay largo y sin percusiva (M44/M42); volumen
bajo para no saturar.

**Herramienta del Viento (M13):** recompensa al cerrar las 2 salas. Permite **llamar una rafaga**
(accion dedicada) con cooldown de 3 s. Es la primera herramienta "climatica" del juego y abre la
mecanica para templos futuros.

**Lore canonico (M147/M153):** el Templo de Brisa es el primero de 6; su sala central tiene runas
de viento y un mural del archipielago. **Anti-spoiler garantizado:** las runas son genericas
(direccion de viento), ningun texto nombra a los otros 5 templos, y el capitulo 4
(`historia_c4_templo_brisa.tres`) solo habla de este. Los 7 sellos requeridos por el capitulo son
los de completitud, no pistas.

**Hint no intrusivo (M58/M66):** solo aparece si el jugador permanece >20 s a <2 m del puzzle sin
interactuar, y como susurro de texto (no pop-up ni flecha). Desactivable en ajustes de
accesibilidad.

**3 rutas de solucion por sala:** para cada sala hay 3 caminos validos —
**orden** (seguir la mecanica tal cual), **observacion** (leer pirolo del lore/ambiente) y
**ayuda** (pista del hint tras 2 fallos). Las 3 llevan a la misma resolucion; no hay ruta "mas
rapida" que rompa balance.

**Anti-softlock (M66):** respaldado por `puzzle_invariant.gd` — si un slot de puzzle no es
resoluble en 30 s de diagnostico, se reinicia al estado inicial. Combinado con
`softlock_guard.gd` (autoload) y la regla de que ningun puzzle del templo es obligatorio para
salir.

**Recompensa extra (M73):** una **pagina de lore** coleccionable escondida en la sala 2 (detras del
carrillon, visible solo con la Herramienta del Viento ya obtenida). Cuenta para el set de M73.

**Viento en el exterior tras la herramienta:** con la Herramienta del Viento, las rafagas mueven
semillas y hojas en toda la isla, y abren **atajos de polen** (corrientes que aceleran el paso por
la pradera). Es el primer cambio global del mundo por una herramienta.
"""

ancla = "### 2.8 Audio global (M41-M44)"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.7.1 insertada")
else:
    print("AVISO: ancla no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
