# Log 1750 - M27 Islas del Mundo - barrido y adjudicacion de los 71 pendientes

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-10-12 05:21:15
**Modulo:** M27-Islas-Del-Mundo (carpeta del GLOBAL: 27-Terreno -- drift de nombre)
**Tarea:** directiva del director mimo msg 190 + 191 (D1) + 192 -- adjudicar los [?] del
modulo. Seccion L y secciones F/J excluidas por el director (ya trabajadas por Step 5).
**Reserva de log:** 1750 (protocolo v3; head del pool medido JUSTO antes: 1750).

---

## 1. Medicion del estado real (por PREFIJO de linea, no por substring)

Archivo: `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md`

```
prefijo de linea : x=121  ?=71  vacio=0   total=192
substring        : x=121  ?=71  vacio=0   (coincide: no hay marcas de ejemplo en notas)
```

Coincide 1:1 con el director (msg 192: 121/192) y con la fila 203 del GLOBAL.

Higiene del archivo medido por BYTES: 33132 B, bom=False, CRLF=0, LF=333,
CR=0, NUL=0, FFFD=0. **No se toco el archivo** (trae ediciones sin commitear de
stepfun-step-5-preview, mtime 2026-10-12 04:52).

### Conteo por seccion (x / ? / vacio)

```
A  Requisitos y alcance            9 / 1 / 0  = 10
B  IslandDefinition              20 / 0 / 0  = 20
C  IslandRegistry                14 / 1 / 0  = 15
D  Anclas y generacion (M10)      6 / 6 / 0  = 12
E  IslandLoading (M63)            9 /10 / 0  = 19
F  IslandProps                    6 / 4 / 0  = 10   <- EXCLUIDA por el director
G  Integracion M28 (viajes)       0 /12 / 0  = 12
H  Integracion M51 (agua)         0 /10 / 0  = 10
I  Integracion M09/M32            0 / 6 / 0  =  6
J  Persistencia y mapa            6 / 0 / 0  =  6   <- EXCLUIDA por el director
K  Edge cases                    14 / 0 / 0  = 14
L  Optimizacion (M61/M62)         8 / 4 / 0  = 12   <- EXCLUIDA por el director
M  Documentacion y logs           6 / 0 / 0  =  6
N  Polish y UX cozy               0 / 8 / 0  =  8
O  Testing (M112/M114)            6 / 4 / 0  = 10
   Dependencia M154               1 / 0 / 0  =  1
   Iter. 1 (historial)            3 / 1 / 0  =  4
   Iter. 2 (historial)            2 / 0 / 0  =  2
   Iter. 3 (historial)           11 / 4 / 0  = 15
   Iter. 4 (historial)            0 / 0 / 0  =  0
```

A adjudicar (no excluidas): 1+1+6+10+12+10+6+8+4+1+4 = **63**.
Excluidas por el director: F 4 + L 4 = 8. Total 71. Cuadra.

## 2. Evidencia de suites (medida, no heredada)

Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral
--script res://scripts/islas/<suite>.gd`

```
test_islas_headless.gd   ->   5 checks / 0 fallos / EXIT 0
test_islas_m27.gd        -> 171 checks / 0 fallos / EXIT 0
test_islas_m27_iter2.gd  -> 238 checks / 0 fallos / EXIT 0
TOTAL                    -> 414 checks / 0 fallos  (0 SCRIPT ERROR en el filtro)
```

Reproduce el claim de stepfun (Log 1710/1736/1746). Las suites siguen verdes.

## 3. Estado MEDIDO de cada modulo dueno citado

Fuente: fila del `CHECKLIST-GLOBAL.md` + presencia real de codigo en disco.

```
M09  09-Terreno-Y-Geografia      100/105  Con dudas   codigo presente
M10  10-Generacion-Del-Mundo      90/106  Con dudas   SIN capa de anclas (ver 4.1)
M15  15-Recursos                  99/222  Con dudas
M19  19-NPC-Y-Vecinos             48/131  Con dudas
M21  21-Dialogos                  40/143  Con dudas
M23  23-Historias-Secundarias     24/104  Con dudas
M24  24-Templos-Y-Puzzles        126/128  Con dudas
M25  25-Ruinas                   122/122  Con dudas (deuda de estado)
M26  26-Templo-Subterraneo        62/129  Liberado parcial
M28  28-Viajes                    50/130  Con dudas   codigo SI (scripts/viajes, 8 .gd)
M29  29-Tiempo-Y-Calendario      189/195  Con dudas
M31  31-Ciclo-Dia-Noche          120/169  Con dudas
M32  32-Clima                    121/121  COMPLETADO
M36  36-Fauna                    226/228  Completado
M41  41-Musica                    58/110  Con dudas
M42  42-Sonido-Ambiental          62/100  Con dudas
M50  50-Vegetacion                29/142  EN CURSO
M51  51-Agua                      35/166  EN CURSO   casi sin codigo (ver 4.2)
M54  54-Mapa                     133/177  Liberado    codigo SI (scripts/mapa, 9 .gd)
M61  61-Rendimiento               37/144  Liberado (QA no sellable)
M62  62-Memoria                  113/150  Liberado
M63  63-Cargas-Y-Streaming        67/101  Liberado    codigo SI (scripts/stream)
M64  64-IA-De-NPC                102/119  Liberado
M73  73-Coleccionables            26/135  Liberado    (NO es una 'feria': ver 4.4)
M105 105-Telemetria              122/162  Con dudas
M112 112-Testing-Automatico      205/225  Con dudas
M114 114-Playtest                185/186  Con dudas
M160 160-Diseno-De-Ubicaciones   145/155  Con dudas
```

## 4. Hallazgos (medidos, no inferidos)

### 4.1 La capa de anclas de M10 NO esta implementada

`grep -rn ancla scripts/world/*.gd scripts/terrenos/*.gd` -> **0 coincidencias**.
`grep -rln 'INTENTOS|re-roll|reroll'` en esos dominios -> solo `terreno_horizonte.gd`
(y no es un re-roll de anclas). M27 **recibe** anclas (`island_registry.anclar()`) pero
nadie las genera todavia. Los 4 items D77/D78/D79/D80 atribuidos a M10 estan
**bloqueados por dependencia real**, no por falta de trabajo de M27.

### 4.2 M51 (agua) casi sin codigo

Busqueda de `agua|water|oceano|ocean` bajo `scripts/`: solo `scripts/world/agua_animada.gd`
(animacion) + `scripts/templos/puzzle_agua.gd` (M24). **No hay nivel de mar global, ni
profundidades, ni corrientes.** Los 10 items del bloque H son DEP-BLOQUEADO.

### 4.3 M28 (viajes) tiene codigo pero NO consulta a M27

`grep -rn 'posicion_ancla|IslandRegistry|island_registry' scripts/viajes/ scripts/transporte/`
-> **0 coincidencias**. Existen `travel_service.gd`, `boat_route.gd`, `travel_ui.gd`,
`harbor.gd`, `embark_trigger.gd`, pero el contrato G125 (trazar ruta con
`posicion_ancla(destino)`) **no esta cableado**. DEP-REAL/PARCIAL: el dueno existe, el
contrato no. Es trabajo de M28, no de M27.

### 4.4 Cita dudosa: 'M73/feria' en N223

El item N223 dice `accesible luego por otras vias (M73/feria)`. Medido: la fila 287 del
GLOBAL es `73-Coleccionables` (26/135), **no una feria/mercado**. Busqueda de
`feria|fair|market` en `scripts/`: solo `marketing`. La cita al 'M73/feria' no resuelve.

### 4.5 Drift de nombre del modulo en el GLOBAL

Fila 203: `| 27 | 27-Terreno |`. La carpeta real es `DOCUMENTACION/27-Islas-Del-Mundo`
y el `05-Checklist.md` se titula `Modulo 27: Islas del Mundo`. El nombre de la fila
**no coincide** con el modulo. Lo aplica el director (no edito el GLOBAL).

### 4.6 `data/islas/islas.json` legacy sigue en disco

Conviven `data/islas/islas.json` (773 B, config de 4 islas, 2026-09-02) y
`data/islas/definiciones/*.tres` (13 islas + `aurora.tres`) + `archipielago.tres`.
El item de la iter. 3 'Migrar el mapa de islas.json (4) al catalogo de 13 -> M54'
sigue **pendiente** (el legacy no se retiro).

### 4.7 Item de historial que no es tarea

Iter. 1 (L252) `[?] Coordenadas/disposicion de world (via M160) y generacion de islas
por viaje (M27/M28) - iter 2 (dueno: deepseek-v4-flash-vision-exp)` es una nota de
historial de una iteracion vieja, con un **modelo ya retirado** como dueno. No es una
tarea viva: candidato a retirar del conteo (decision del director).

## 5. Adjudicacion de los 63 items (no excluidos)

Leyenda: RES-M27 = el item esta satisfecho por API/codigo de M27 medido (candidato a
flip); DEP-REAL = dueno externo con codigo (el item es contrato entre modulos, no se
cierra desde M27); DEP-BLOQ = dueno externo SIN el codigo que el item exige (bloqueo
real); DISENO = no implementado por decision de alcance; CITA = cita no resuelve.

```
SEC  ITEM  DUENO        VEREDICTO  EVIDENCIA MEDIDA
A    L24   M28          DEP-REAL   travel_service.gd existe; 'regreso gratis' no
C    L64   M63          DEP-REAL   scripts/stream/stream_manager.gd existe
D    L74   M10/M25/M26  DEP-BLOQ   M10 sin capa de anclas (4.1)
D    L77   M10          DEP-BLOQ   idem 4.1
D    L78   M10          DEP-BLOQ   idem 4.1
D    L79   M10          DEP-BLOQ   idem 4.1
D    L80   M10          DEP-BLOQ   idem 4.1
D    L82   M19/M09      DEP-BLOQ   requiere anclas de M10 (cadena)
E    L90   (M63)        DISENO     IslandPref: hoy consts StringName en island_ops
E    L92   (M63)        DISENO     isla_cargando: no existe como signal (medido)
E    L93   (M63)        DISENO     isla_cargada: idem
E    L94   (M63)        DISENO     isla_descargada: idem
E    L96   (M63)        RES-M27    travel_guard L492-494: intocables=[principal,actual]
E    L97   (M63)        DISENO     'cacheado()' no existe; estado en ops/info()
E    L98   (M63)        DISENO     'isla_actual()' no existe como metodo
E    L99   (M63)        RES-M27    island_definition.gd L110 punto_llegada_mundo()
E   L100   (M63)        RES-M27    island_definition.gd L114 punto_partida_mundo()
E   L104   M28          DEP-REAL   pantalla de viaje: travel_ui.gd existe
G  L125-136 M28         DEP-REAL   contrato NO cableado (4.3): 12 items
H  L142-151 M51         DEP-BLOQ   casi sin codigo (4.2): 10 items
I   L157   M27/M09      RES-M27    island_definition: bioma_base + BIOMAS (13)
I   L158   M09          DEP-REAL   M09 100/105, codigo presente
I   L159   M09          DEP-REAL   idem
I   L160   M32          DEP-REAL   M32 COMPLETO pero no lee la isla (medido)
I   L161   M41          DEP-REAL   M41 58/110
I   L162   M36/M50      DEP-REAL   M36 226/228 ok; M50 29/142 EN CURSO
N  L220-227 M54/M28/M21 DEP-REAL   8 items; M73/feria = CITA (4.4)
O  L238   M28          DEP-REAL   viaje Aurora->Nieve: requiere M28
O  L239   M27/M63      RES-M27    K1/debe_precargar medido en iter2 (238/0)
O  L240   M10          DEP-BLOQ   regen 80/0: idem 4.1
O  L241   M61/M63      DEP-REAL   presupuesto: M61 37/144
IT1 L252  (retirado)    CITA       item de historial, dueno retirado (4.7)
IT3 L274  M63          DEP-REAL   IslandLoading: M63 67/101
IT3 L275  M10          DEP-BLOQ   anclas/re-roll: idem 4.1
IT3 L276  M50/M36/M15  DEP-REAL   ids reales: M50 29/142, M15 99/222
IT3 L277  M54          DEP-REAL   islas.json legacy sigue en disco (4.6)
```

Resumen (suma = 63, cuadra con el total a adjudicar):

```
RES-M27   =  5   E96, E99, E100, I157, O239
DEP-REAL  = 32   A24, C64, E104, G x12, I158-I162, N x7, O238, O241, IT3 x3
DEP-BLOQ  = 18   D x6, H x10, O240, IT3-L275
DISENO    =  6   E90, E92, E93, E94, E97, E98
CITA      =  2   N223 (M73/feria), IT1-L252 (dueno retirado)
TOTAL     = 63
```

## 6. Recomendacion (NO aplicada: los flips los aplica el director)

1. **5 candidatos a flip `[?]` -> `[x]`** con evidencia de API medida en M27:
   E96, E99, E100, I157, O239. Cada uno tiene el artefacto citado y medido.
2. **11 DEP-BLOQ**: dejar `[?]` y anotar el bloqueo real (M10 sin capa de anclas;
   M51 sin sistema de agua). Son los unicos que NO dependen de una decision de alcance.
3. **6 DISENO** (bloque E): el modulo decidio NO implementar `IslandLoading` (es de M63).
   Los items describen una API que se sustituyo por `IslandOps`. Candidatos a
   reescribir el item (no a flipar) o a marcar `[?]` con la nota de sustitucion.
4. **2 CITA**: N223 ('M73/feria' no resuelve) y el item de historial de la iter. 1.
5. **Fila 203 del GLOBAL**: el nombre `27-Terreno` deberia ser `27-Islas-Del-Mundo`.
6. El conteo NO cambia por este barrido: sigue **121 [x] / 71 [?] / 0 [ ] = 192**.
   Si el director aplica los 5 flips: **126 / 66 / 0 = 192**.

## 7. Limites de esta corrida

- **0 commits / 0 push** (los commits del repo estan a cargo de atria-dawn).
- **0 flips** aplicados. **0** ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`,
  `AGENTS.md` ni al `05-Checklist.md` del modulo.
- El `05-Checklist.md` y el `04-Codigo.md` de M27 traen **ediciones sin commitear de
  stepfun-step-5-preview** (mtime 2026-10-12 04:52/04:53): no se tocaron.
- Colisiones de pool AJENAS detectadas por `reservar_log.py --estado` (no tocadas):
  1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.
- De la cola de 12 tareas del msg 191 se ejecuto **D1 (M27)**. D2..D12 quedan para las
  corridas siguientes (cada una es implementacion de nucleo, no un barrido).

## 8. Siguiente

- Director: decidir los 5 flips, la reclasificacion de los 6 DISENO y el nombre de la
  fila 203. Reportar el bloqueo de M10/M51 a sus duenos.

**Fin del Log 1750.**
