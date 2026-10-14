# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.6.1 Sistema de construccion de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 6 del checklist. El motor ya existe y esta testeado; lo que faltaba era el
catalogo y las reglas de fase.

**Lo que ya existe en disco (verificado, no inventado):**

| Componente | Archivo | Cubre |
|---|---|---|
| Validador de terreno | `scripts/construccion/construccion_validator.gd` | nucleo PURO (sin nodos ni VoxelTools): superficie/pared/agua, **limite de zona** (`Motivo.LIMITE_DE_ZONA`) |
| Permisos por zona | `scripts/construccion/zonas_permisos.gd` | parcela del jugador EDIFICABLE, ruina/templo PROTEGIDA (M25) |
| Preview translucido | `scripts/construccion/build_preview.gd` + `build_ghost.gd` | feedback visual de validez (M44) |
| Persistencia | `scripts/saving/buildings_save_provider.gd` (M59) + `test_m18_m60_integration.gd` (10 checks) | contrato ISaveProvider; **nota honesta:** el provider existe pero la fuente M17 todavia no esta implementada |
| Catalogo base | 6 muebles en `data/houses/*.tres` | cama, cofre, estanteria, lampara, mesa, silla |

**Catalogo de fase — 30 piezas (definidas aqui; 6 ya existen como .tres):**

| Categoria | Piezas |
|---|---|
| Vallas (6) | valla_madera, valla_jardin, valla_piedra, valla_bambu, puerta_jardin, arco_flores |
| Caminos (6) | camino_tierra, camino_adoquin, camino_grava, camino_madera, losa_jardin, borde_cesped |
| Mobiliario (10) | mesa_madera*, silla_madera*, cama_madera*, cofre_madera*, estanteria*, lampara_pared*, banco_plaza, sillon_exterior, mesita_noche, armario_roble |
| Deco (8) | maceta_flor, farol_jardin, molino_deco, comedero_pajaros, estatua_farol, cartel_madera, banderin_fiesta, alfombra_exterior |

(* las 6 que ya tienen .tres)

**3 estructuras de fase:** casa de campo (4 etapas: solar → estructura → techo → terminación),
invernadero pequeño (3 etapas) y gazebo (2 etapas). Las etapas las administra `house_manager.gd`
(ya tiene `avanzar_etapa`).

**Colocacion:** grid ligero de 1 m sin fisica — encaja con el validador de nucleo puro; la pieza se
coloca en la celda libre mas cercana al puntero y se rechaza con el motivo correspondiente.

**Costo por pieza (M93):** vallas 3-8 AO + 1 material · caminos 1-2 AO · mobiliario 15-120 AO +
1-3 materiales · deco 5-40 AO. Las recetas de crafteo viven en `crafting.json` (M16).

**Desbloqueo por amistad (M20):** respaldado por `data/economia/friendship.json` — nivel 2
desbloquea `recetas_basicas`, nivel 4 `recetas_avanzadas` + trueque especial. Obe (M23) anade el
gancho de mision que desbloquea las 3 estructuras.

**Clima (M32):** el **invernadero** es la unica estructura que interactua con el clima — la lluvia
duplica la velocidad de crecimiento de lo plantado adentro y el sol directo la reduce a la mitad.
El resto de las piezas es neutra al clima.

**Limite por zona (M61):** 40 piezas en la parcela del jugador, 25 en la plaza y 0 en ruinas y
templos. El validador ya rechaza con `LIMITE_DE_ZONA`; los numeros por zona quedan como balance de
M61.

**Categorias visuales (M46):** 4 materiales canonicos — madera, piedra, tela y planta. Toda pieza
usa uno de esos 4 con la paleta Maldivas del proyecto; nada de metal salvo el herrero.

**Interaccion con NPC (M19):** `banco_plaza` es sentable (accion SENTARSE ya existe en
`item_data.gd`); los NPC con rutina libre (Pax) pueden usar bancos como waypoint de descanso.
"""

ancla = "### 2.7 Guardado v3 (M59/M60)"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.6.1 insertada")
else:
    print("AVISO: ancla no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
