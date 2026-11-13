# Reporte: Casas, construcciones y edificios (M17 Construcción / M18 Casas)

**Modelo:** ERNIE-5.5-Flash-Preview (baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-12
**Alcance:** análisis estático de `game/isla-ancestral/scripts/` (y su data asociada) sobre casas, construcciones y edificios. No se ejecutó el motor: todo lo que sigue es lectura de código.

---

## 0. Método y archivos efectivamente leídos

Se localizaron **3 subsistemas distintos** que tocan "casas". Es importante no confundirlos:

| Subsistema | Carpeta | Qué modela |
|---|---|---|
| **M17 Construcción** | `scripts/construccion/` | Colocación de **piezas voxel** 1×1 (paredes, pisos, techos, muebles) con validación declarativa |
| **M18 Casas** | `scripts/houses/` | **Casa como entidad**: etapas de mejora, interior, muebles, almacenamiento, visitas de vecinos |
| **M117 Build System** | `scripts/build/` | Build/instalador del ejecutable (nada que ver con casas; solo comparte el `class_name BuildValidator`) |

Archivos leídos íntegramente (con nº de líneas):

| Archivo | Líneas | Rol |
|---|---|---|
| `scripts/houses/house_data.gd` | 26 | Recurso de huella/costo de la casa |
| `scripts/houses/house.gd` | 89 | Nodo exterior de la casa (etapa, obra, puerta) |
| `scripts/houses/house_manager.gd` | 338 | Autoload central (etapas, costos, muebles, guardado) |
| `scripts/houses/house_upgrade.gd` | 118 | Obra por etapas con días de juego |
| `scripts/houses/house_upgrade_data.gd` | 35 | Recurso de etapa de mejora |
| `scripts/houses/house_interior.gd` | 70 | Habitaciones desbloqueables por etapa |
| `scripts/houses/house_decor.gd` | 200 | Grid de decoración a 0,25 m |
| `scripts/houses/house_storage.gd` | 129 | Contenedores (cofre/estantería) |
| `scripts/houses/house_visit.gd` | 174 | Visitas de vecinos + gustos decorativos |
| `scripts/houses/furniture_data.gd` | 21 | Recurso de mueble |
| `scripts/houses/casas_panel.gd` | 127 | UI modal de casas |
| `scripts/construccion/construccion_tipos.gd` | 186 | Enums, motivos, resultados |
| `scripts/construccion/placement_rule.gd` | 199 | **Regla declarativa por pieza (dimensiones)** |
| `scripts/construccion/build_catalog_db.gd` | 185 | Catálogo data-driven de recetas |
| `scripts/construccion/construccion_validator.gd` | 319 | **Única autoridad "puede colocar"** |
| `scripts/construccion/build_ghost.gd` | 345 | Fantasma visual (tamaño real de malla) |
| `scripts/construccion/build_manager.gd` | 838 | Orquestador: colocar/demoler/copiar/mover/estructuras |
| `scripts/construccion/construccion_mundo.gd` | 177 | Adaptador al mundo voxel real |
| `scripts/houses/test_m18_casas.gd` | 166 | Suite headless M18 |

Data asociada: **46 recetas** `.tres` en `data/construccion/piezas/`, **59 fichas** de asset en `assets/fichas/18-Casas_*.md`, y **6 modelos GLB de casa completa** en `assets/3d/{alta,media,baja}/18-Casas_casa_*.glb`.

---

## 1. ¿Qué tipos de casas existen?

Hay que separar **tres planos** que en el código están solo parcialmente conectados.

### 1.1 Casas como etapas de progresión (M18, el único plano "jugable")

`house_manager.gd:11-18` define la escalera de 5 etapas:

```gdscript
const MAX_ETAPAS := 5
const ETAPAS := { 1: "choza", 2: "ampliacion", 3: "cocina", 4: "taller", 5: "sotano_atico" }
```

Y `house_manager.gd:245-251` desbloquea habitaciones por etapa (coincide con `house_interior.gd:46-59`):

| Etapa | Nombre | Habitaciones | Costo (`house_manager.gd:106-112`) | Slots muebles (`:171`) |
|---|---|---|---|---|
| 1 | Choza | living | 10 wood + 5 grass | 2 |
| 2 | Ampliación | + dormitorio | 20 wood + 10 stone | 4 |
| 3 | Cocina | + cocina | 30 wood + 15 stone + 5 copper_ore | 6 |
| 4 | Taller | + taller | 40 wood + 20 stone + 10 iron_ore | 8 |
| 5 | Sótano/Ático | + sótano + ático | 50 wood + 25 stone + 5 crystal | 12 |

**Es una casa única que crece**, no un catálogo de casas distintas. `house_data.gd:8` declara un único `@export var display_name = "Choza"` y `house_manager.registrar_casa()` (`:32-42`) no recibe tipo: todas las casas del mundo son iguales y solo difieren en etapa.

### 1.2 Casas como modelos 3D (data sin usar)

Existen **6 mallas de casa completa** en `assets/3d/{alta,media,baja}/` con sus fichas:

| GLB | Ficha | Estado |
|---|---|---|
| `18-Casas_casa_choza_ampliada.glb` | sí | `PENDIENTE-REVIEW` |
| `18-Casas_casa_mediana.glb` | sí | `PENDIENTE-REVIEW` |
| `18-Casas_casa_casona.glb` | sí | `PENDIENTE-REVIEW` |
| `18-Casas_casa_mansion.glb` | sí | `PENDIENTE-REVIEW` |
| `18-Casas_casa_vecino.glb` | sí | `PENDIENTE-REVIEW` |
| `18-Casas_casa_completa_ejemplo.glb` | sí | `PENDIENTE-REVIEW` |

**Hallazgo (importante):** una búsqueda de estos nombres en `scripts/**.gd` devuelve **0 usos**. Los `mesh_path` de las recetas apuntan a piezas sueltas (`18-Casas_pared_madera.glb`, `18-Casas_techo_paja.glb`, etc.), nunca a `casa_*`. `house.gd:21-23` dice:

```gdscript
## Devuelve la etapa visual actual (cambia el modelo exterior).
func etapa_actual() -> int:
	return etapa
```

El comentario promete un cambio de modelo exterior por etapa, pero la función **solo devuelve un entero**: no hay `MeshInstance3D`, ni carga de GLB, ni swap de escena en ningún archivo de `scripts/houses/`. **Los 6 modelos de casa completa están creados, catalogados y muertos.**

### 1.3 Casas como piezas voxel (M17, el único plano construible por el jugador)

`build_catalog_db.gd:18-21` declara 12 familias y el catálogo tiene **46 recetas** (verificado con `Get-ChildItem data/construccion/piezas/*.tres` → 46). Cobertura por familia:

| Familia | Recetas presentes |
|---|---|
| pared | `pared_madera`, `pared_piedra`, `pared_esquina`, `pared_pilar` |
| piso | `piso_tablones`, `piso_piedra`, `piso_terraza` |
| techo | `techo_paja`, `techo_losa` |
| puerta | `puerta_madera`, `puerta_piedra` |
| ventana | `ventana_marco`, `ventana_arco` |
| escalera | `escalera_recta`, `escalera_doble` |
| puente | `puente_1..4` |
| camino | `camino_arena`, `camino_cesped`, `camino_piedra` |
| cerca | `cerca_madera`, `cerca_piedra`, `cerca_bambu` |
| iluminacion | `farol_piso`, `farol_colgante`, `antorcha_ancestral` |
| mueble | `mesa`, `silla`, `cama`, `estanteria`, `cofre_ancestral`, `comoda`… |
| decoracion | `alfombra`, `cuadro`, `totem`, `fuente`, `maceta`… |

**Conclusión del punto 1:** el jugador construye **piezas**, no casas. Existe una casa abstracta de 5 etapas sin geometría propia, y 6 casas completas con geometría pero sin integración. **No hay un solo "tipo de casa" seleccionable** (ni cabaña, ni casona, ni casa de vecino) en el código.

---

## 2. ¿Hay validación de dimensiones y proporciones?

### 2.1 Lo que SÍ existe

**(a) Dimensiones declarativas por pieza.** `placement_rule.gd:32-35`:

```gdscript
@export var tamano: Vector2i = Vector2i.ONE   # huella (x, z)
@export var altura: float = 1.0                # alto en metros
```

`placement_rule.gd:101-110` (`celdas()`) deriva la huella ocupada y **intercambia ancho/fondo en rotaciones impares**, con ancla en la esquina de menor x/z. Esto está bien resuelto y testeado (`test_construccion.gd:135`).

**(b) Validación de huella mínima.** `house_data.gd:13-15`:

```gdscript
func huella_valida() -> bool:
	return huella_voxel.x > 0 and huella_voxel.y > 0
```

Y `build_catalog_db.gd:156-157` dentro de `validar()`:

```gdscript
if r.tamano.x < 1 or r.tamano.y < 1:
	problemas.append("%s: tamano invalido %s" % [String(id), str(r.tamano)])
```

**(c) Validación geométrica de colocación** (no de proporción, pero sí de encaje): `construccion_validator.gd` valida soporte (`:167-175 contar_soportes`), apoyo alternativo (`:180-192`), pared contigua (`:247-253`), fuera del mundo (`:219-227`) y **no permite demoler una pieza que sostiene otra** (`build_manager.gd:503-518 piezas_apoyadas_en` + `:533-541`).

**(d) Validación de muebles.** `house_decor.gd:84-89` rechaza dimensiones no positivas:

```gdscript
var ancho: float = float(mueble.get("ancho", 1.0))
var profundo: float = float(mueble.get("profundo", 1.0))
if ancho <= 0.0 or profundo <= 0.0:
	out["razon"] = "dimensiones inválidas"
```

### 2.2 Lo que FALTA (huecos reales de validación)

**F1 — No hay validación de proporciones.** En ningún archivo se compara `tamano` contra `altura`, ni se exige una relación mínima (p. ej. que una pared de 2 m de alto tenga al menos 1×1 de base, o que un techo cubra toda la huella). El validador solo comprueba `>= 1`. Un `tamano = Vector2i(9, 9)` con `altura = 0.1` pasaría `build_catalog_db.validar()` sin objeción.

**F2 — Nadie verifica que la malla coincida con `tamano`/`altura`.** `build_ghost.gd:179-197` calcula la caja de respaldo desde `tamano`/`altura`, pero si la receta declara `mesh_path`, **usa la malla tal cual** (`_mesh.mesh = malla`) sin escalarla ni comparar su AABB con la huella declarada. Consecuencia: una receta puede decir `tamano = 1×1, altura = 1.0` y mostrar un GLB de 4 m de ancho; el fantasma se ve bien, la validación dice 1×1, y el voxel ocupa 1 celda. **La discrepancia visual/jurídica no se detecta nunca.**

**F3 — 36 de 46 recetas no declaran `tamano`** (medido: `Select-String "^tamano"` sobre los 46 `.tres`). Viven del default `Vector2i.ONE`. Esto hace que `pared_madera`, `pared_esquina`, `pared_pilar`, `pared_piedra`, `ventana_marco` y `ventana_arco` sean **indistinguibles en huella** (1×1): una esquina ocupa lo mismo que una pared recta, y una ventana lo mismo que un pilar.

**F4 — 21 de 46 recetas no declaran `altura`** (medido). `pared_madera`, `pared_piedra`, `ventana_marco`, `piso_terraza`, `escalera_recta`, `pared_esquina` usan el default `1.0`, mientras `puerta_madera` declara `altura = 2.0`. Resultado: **una puerta de 2 m de alto se apoya en una pared de 1 m de alto** (relación de altura incoherente, sin validación que la rechace).

**F5 — No hay validación de altura libre interior.** `interior_camera.gd:13` fija `ALTURA_CAMARA := 1.6` m, pero nada comprueba que el techo quede por encima (2,0 m mínimos). Con `altura` por defecto de 1,0 m el jugador cabría de pie dentro de una pared.

**F6 — Dos grids incompatibles sin conversión compartida.** `build_manager`/`construccion_mundo.gd:113-121` trabajan en celdas de **1,0 m** (`OFFSET_MEDIO_VOXEL = 0.5`), mientras `house_decor.gd:11-12` usa `CELDA_TAMANO := 0.25` con `CELDAS_POR_METRO := 4`. No existe una función puente entre ambos: colocar un mueble de 1×1 m del grid fino ocupa 4×4 celdas del grid grueso, y nadie lo traduce.

**F7 — Borde de habitación hardcodeado.** `house_decor.gd:197-200`:

```gdscript
const BORDE := 31  # 8 m / 0.25 m = 32 celdas
return celda.x <= 0 or celda.x >= BORDE or celda.z <= 0 or celda.z >= BORDE
```

La restricción "solo contra la pared" asume **siempre** una habitación de 8×8 m. Una casa de 4×4 o de 12×6 tiene los bordes mal calculados.

**F8 — Dos convenciones distintas para la puerta de la casa.** `house.gd:34-35` usa `global_position + Vector3.FORWARD * 2.0` (FORWARD = −Z), y `house_manager.gd:196-201` usa `pos + Vector3(0, 0, 3.0)` (+Z). **Misma entidad, dos posiciones de puerta opuestas**, sin constante compartida.

---

## 3. ¿Hay problemas de ensamblaje de piezas?

Sí, y son el punto más débil del subsistema. Listados por severidad.

### 3.1 Variante sin geometría propia (visual)

`data/construccion/piezas/pared_esquina.tres`:

```
id = &"pared_esquina"
variante = "esquina"
mesh_path = "res://assets/3d/alta/18-Casas_pared_madera.glb"
tamano = (default 1x1)
```

`pared_pilar.tres` hace exactamente lo mismo (misma malla, `variante = "pilar"`, `bloque = 3` = piedra). **La esquina y el pilar se dibujan con la malla de la pared recta.** Al ensamblar cuatro paredes en cuadrado, las esquinas se solapan visualmente (dos mallas de pared en la misma celda) y no existe una pieza que cierre el encuentro en L. Es un ensamblaje **visualmente roto por diseño de datos**, no por bug de código.

### 3.2 Falta el zócalo / cimiento

Existe el asset `18-Casas_zocalo_piedra.glb` (alta/media/baja) con ficha `18-Casas_zocalo_piedra.md`, **pero no hay receta `.tres` de zócalo**. Como el piso (`piso_tablones`) se apoya sobre terreno con `altura = 0.5` y las paredes sobre el piso, la casa **nace a nivel del terreno sin base de piedra**: en terreno irregular (la isla usa `get_height()` con perfil en capas, ver `167-Isla-Raiz`) el piso queda a distintas alturas y las paredes dejan huecos bajo el zócalo. No hay validación de "casa nivelada".

### 3.3 Techo: 2 recetas para 4 pendientes, sin cumbrera

`techo_paja.tres` y `techo_losa.tres` declaran `tamano = Vector2i(2, 2)`, `altura = 0.5`, `soportes_minimos = 2`, `superficie_ofrecida = &"techo"`. Problemas:

- `techo_losa.tres` usa `mesh_path = 18-Casas_techo_dos_aguas.glb` (un techo **a dos aguas**) pero la pieza se declara como **losa plana 2×2 de 0,5 m**. La malla y la semántica no coinciden.
- No hay **cumbrera**, ni **alero**, ni **tapa de hastial**: al cerrar un rectángulo de 4×6 con piezas de 2×2, el encuentro de dos aguas queda abierto (no hay pieza que resuelva la arista).
- `superficie_ok` incluye `&"techo"`: se pueden apilar techos sobre techos sin límite, y `soportes_minimos = 2` permite que una losa de 2×2 se apoye con solo dos celdas tocando pared — el otro lado queda volando.

### 3.4 Huecos de pared no modelados

`puerta_madera.tres` declara `requiere_pared = true` (igual `ventana_marco`), pero **no existe receta de "pared con hueco"**. El validador exige pared contigua (`construccion_validator.gd:98-100` + `:247-253`), de modo que la puerta se coloca *al lado* de una pared, no *dentro* de un vano. El asset `18-Casas_pared_puerta.glb` y `18-Casas_pared_ventana.glb` existen y **no tienen receta**. Resultado: no se puede cerrar una casa dejando una puerta practicable; el vano hay que simularlo dejando la celda vacía, lo que a su vez rompe la continuidad de `superficie_ofrecida = &"pared"` (el techo de la celda contigua pierde soporte).

### 3.5 La escalera no comunica plantas

`escalera_recta.tres`:

```
familia = &"escalera"
altura = 1.0        (default: no declarado)
bloque = 8
apoyo_alternativo = [&"pared"]
```

Una escalera de 1 m de altura no salva la distancia entre una planta baja y un primer piso (que la losa declara en 0,5 m de espesor + altura de pared). `house_interior.gd:58` desbloquea "atico" en etapa 5 y `house_manager.gd:245-251` "sotano", pero **no hay ninguna pieza de escalera que conecte dos niveles de voxels de la casa construida**: el sótano/ático son habitaciones lógicas, no espacios accesibles.

### 3.6 La "casa" no es una entidad: son N estructuras sueltas

`build_manager.confirmar_colocacion()` (`:393-446`) registra **cada pieza** como una estructura independiente en `_estructuras` y `_ocupacion` (`:728 _alta_estructura`, `:767 _baja_estructura`). No existe el concepto "conjunto de piezas = una casa". Consecuencias:

- No hay puerta que abra al interior de lo construido: `house.gd:38-47 abrir_interior()` instancia un `HouseInterior` lógico independiente de la geometría.
- No hay conteo de "piezas de esta casa" para costos, límites ni guardado.
- Demoler es por pieza (`:521`), con el único cuidado de no tirar la que sostiene otra (`:533-541`).

### 3.7 Perfiles de malla hardcodeados a "alta"

`placement_rule.gd:74` + `build_ghost.gd:101-110`: si `mesh_path` empieza con `res://`, se usa **tal cual**; solo las rutas "base" pasan por `AssetProfile.ruta()`. Las 46 recetas declaran rutas `res://assets/3d/alta/...` → **las variantes `media` y `baja` nunca se usan** en el fantasma. El sistema de degradación M166 queda fuera de la ruta real de render del construir.

### 3.8 Bug conocido en la integración (registrado, no resuelto)

`11-BUGS.md` BUG-135 (línea 7823) documenta que `house_manager.gd:231-238` llama a `WorldLocations.buscar_cerca()`, **método que no existe** → el guard `has_method` es siempre falso y `casa_en_ubicacion_conocida()` **devuelve `true` siempre**. Además `test_m18_casas.gd:117` consagra el comportamiento degradado. Es la misma familia que BUG-116 (arista viva en el grafo, muerta en runtime).

Y BUG-145 (línea 542): `test_m18_m17_conflicto.gd` cuelga en headless (60 s sin salida), lo que sugiere que **la integración M17↔M18 nunca se verificó en runtime**.

---

## 4. ¿Qué tipos de casas faltan?

### 4.1 Casas (tipos) ausentes del catálogo

Existiendo `casa_vecino.glb` sin usar, no hay **ninguna** casa de NPC diferenciada (el vecino habita la misma choza genérica). Faltan:

1. **Casa de vecino/NPC con rol** — el GLB existe; falta la entidad y la asignación (M19 solo asigna un `vecino_id` a una casa del jugador, `house_manager.gd:154-160`).
2. **Cabaña de pescador sobre pilotes** — hay `muelle_madera`, `puente_1..4` y `bote_pesca`, pero ninguna pieza de **pilote/zanco** ni receta de plataforma elevada sobre agua.
3. **Casa en el árbol** — no hay plataforma, ni tronco habitable, ni escalera que suba.
4. **Casa de piedra / casona de dos plantas** — los GLB `casa_casona` y `casa_mansion` existen; falta la escalera funcional (3.5) y la losa de entrepiso.
5. **Casa comunal / granero / taller-almacén** — etapa 4 "taller" existe como etiqueta, sin geometría ni puerta ancha.
6. **Casa abandonada / habitable en ruina** — hay `generador_ruina.gd` en M25, pero sin integración con M18 (no se puede reparar una ruina y habitarla).
7. **Casa de invitados / segunda vivienda** — `house_manager` permite registrar varias casas (`:32-42`) pero `obtener_casa_jugador()` (`:46-57`) resuelve siempre la primera; no hay selección de casa activa.

### 4.2 Piezas estructurales ausentes (impiden ensamblar cualquier casa)

| Pieza faltante | Por qué es necesaria |
|---|---|
| **Zócalo / cimiento** | El asset existe; sin receta la casa no asienta en terreno irregular |
| **Pared con vano de puerta** | Sin vano no se puede cerrar una casa con puerta practicable |
| **Pared con vano de ventana** | Ídem para `ventana_marco` / `ventana_arco` |
| **Dintel / viga** | Falta el remate superior del vano |
| **Pilar de esquina real** | La "esquina" actual usa malla de pared recta (3.1) |
| **Entrepiso / losa de planta** | Sin él no hay segundo piso |
| **Escalera de 2+ m** | La actual es de 1 m (3.5) |
| **Cumbrera / caballete** | No hay cierre de dos aguas (3.3) |
| **Alero / goterón** | Sin él el agua entra bajo el techo |
| **Baranda / balcón** | No hay protección de desnivel |
| **Porche / galería** | No hay transición exterior-interior |
| **Chimenea / estufa** | El asset `estufa_lena` existe sin receta |
| **Puerta de doble hoja / portón** | Para granero/almacén |

---

## 5. Dos diseños concretos de casas

Ambos están pensados para implementarse con el sistema actual (piezas de 1 m + recetas .tres), declarando explícitamente las piezas nuevas necesarias y su validación. Se respeta la convención de placement_rule.gd (ancla en la esquina de menor x/z, tamano en celdas, altura en metros, superficie_ofrecida para el encadenado).

### 5.1 Diseño A — Cabaña del Pescador (etapa 1-2, 4x5 m, sobre pilotes)

Concepto: vivienda mínima de madera sobre la línea de playa, con piso elevado 0,6 m sobre pilotes de piedra y un pequeño muelle propio. Es el primer hogar del jugador y sirve de tutorial de ensamblaje.

Huella y volumetría

| Elemento | Celdas | Altura | Notas |
|---|---|---|---|
| Zócalo (pilotes) | 4 pilotes de 1x1 en las 4 esquinas | 0,6 m | Pieza nueva: zocalo_pilote |
| Piso | 4x5 = 20 losas de 1x1 | 0,15 m | piso_tablones (existente) |
| Paredes perimetrales | 14 celdas de perímetro | 2,0 m | pared_madera + 4 esquinas reales |
| Vano de puerta | 1x2 en el frente | 2,0 m | pared_puerta_vano (nueva) + puerta_madera (hoja) |
| Vano de ventana | 1x1 en el lateral izquierdo | 1,0 m | pared_ventana_vano (nueva) + ventana_marco (hoja) |
| Techo | 3 losas de 2x2 (= 12 celdas) | 0,5 m | techo_paja (existente) |
| Muelle | 2x4 sobre agua | 0,3 m | muelle_madera (existente) |

Piezas nuevas requeridas (4):

1. zocalo_pilote — familia cimiento (familia nueva a registrar en BuildCatalogDB.FAMILIAS), tamano 1x1, altura 0.6, soportes_minimos 1, superficie_ok [terreno, arena], superficie_ofrecida cimiento, bloque 3 (piedra), mesh_path res://assets/3d/alta/18-Casas_zocalo_piedra.glb. Es la receta que hoy falta aunque el asset exista (ver 3.2).
2. pared_puerta_vano — familia pared, tamano 1x2, altura 2.0, requiere_pared false (es la pared que ofrece el vano), superficie_ofrecida pared, mesh_path res://assets/3d/alta/18-Casas_pared_puerta.glb (asset existente sin receta).
3. pared_ventana_vano — familia pared, tamano 1x1, altura 1.0, requiere_pared false, superficie_ofrecida pared, mesh_path res://assets/3d/alta/18-Casas_pared_ventana.glb (asset existente sin receta).
4. puerta_madera (hoja) — ya existe; se apoya en el vano en vez de en pared contigua (requiere_pared true -> falso con apoyo_alternativo [vano]).

Validación específica a añadir (cubre los huecos de 2.2):

- Soporte de zócalo: en construccion_validator.contar_soportes (L167-175), una pieza con familia cimiento exige que la celda de abajo sea terreno o arena; si es agua, rechazar (hoy el agua solo se permite a puentes).
- Altura mínima de pared: en build_catalog_db.validar (L148-174), exigir altura >= 2.0 en toda receta con familia pared y con familia puerta (hoy el default 1,0 lo incumple: F4).
- Cierre perimetral: nuevo validador de conjunto que cuenta las celdas de perímetro con superficie_ofrecida == pared y exige que sea igual al perímetro teórico de la huella antes de permitir colocar techo (hoy no existe: 3.3 y 3.4).

Integración M17-M18: al colocar la última losa de techo, BuildManager emite la señal pieza_colocada; un listener nuevo (house_manager o un conector dedicado) agrupa las piezas de la zona y llama a registrar_casa(pos) con etapa 1; al mejorar a etapa 2 (house_manager.avanzar_etapa) se desbloquea el dormitorio en house_interior.

Por qué es viable: reutiliza 6 recetas existentes; solo exige 4 recetas nuevas (2 de ellas con asset ya presente) y una validación de cierre perimetral que además corrige los huecos F1/F4 y 3.2/3.4.

### 5.2 Diseño B — Casa-Taller de dos plantas con porche (etapa 3-5, 6x7 m)

Concepto: la casa del artesano. Planta baja abierta al taller (piezas grandes, portón doble), planta alta con dormitorio y balcón, y porche de acceso. Es la casa visible en el tramo medio del juego y la que justifica las etapas 3-5 (cocina, taller, sótano/ático) que hoy solo desbloquean habitaciones lógicas sin geometría.

Huella y volumetría

| Nivel | Elemento | Celdas | Altura acumulada |
|---|---|---|---|
| 0 | Zócalo corrido de piedra | perímetro 6x7 | 0 → 0,4 m |
| 0 | Piso de planta baja | 42 losas | 0,4 m |
| 0 | Paredes portantes | 22 celdas de perímetro | 0,4 → 2,6 m |
| 0 | Portón doble (2x2) + 2 ventanas | 3 celdas | — |
| 1 | Entrepiso (losa 6x7 con hueco de escalera 1x3) | 39 losas | 2,6 → 2,8 m |
| 1 | Escalera recta de 2,2 m + descansillo | 4 celdas | 0,4 → 2,6 m |
| 1 | Paredes de planta alta | 22 celdas | 2,8 → 4,8 m |
| 1 | Vano de balcón (1x2) + ventana | 2 celdas | — |
| 2 | Techo a dos aguas (cumbrera + 2 faldones) | 4 losas 2x2 + 1 cumbrera | 4,8 → 6,3 m |
| 0 | Porche: 6 losas + 4 pilares + baranda | 10 celdas | 0,4 → 2,4 m |

Piezas nuevas requeridas (7):

1. zocalo_corrido — familia cimiento, tamano 1x1, altura 0.4, superficie_ofrecida cimiento. Variante de zocalo_pilote para base continua.
2. pared_puerta_vano — la misma del Diseño A (reutilizada).
3. losa_entrepiso — familia piso, tamano 2x2, altura 0.2, soportes_minimos 2, superficie_ok [pared], superficie_ofrecida piso. Es la pieza que hoy no existe y sin la cual no hay segundo piso.
4. escalera_larga — familia escalera, tamano 1x3, altura 2.2, apoyo_alternativo [pared], superficie_ofrecida aire. Reemplaza a escalera_recta (1 m) en 3.5.
5. cumbrera — familia techo, tamano 1x1, altura 0.4, soportes_minimos 2, superficie_ok [techo, pared], superficie_ofrecida techo. Cierra la arista del techo a dos aguas (3.3).
6. alero — familia techo, tamano 1x1, altura 0.15, soportes_minimos 1, superficie_ofrecida techo. Vuela 0,5 m sobre la pared.
7. baranda — familia cerca, tamano 1x1, altura 0.5, superficie_ofrecida aire. Protege balcón y porche.

Validación específica a añadir:

- Nivelación por niveles: nueva función en construccion_validator que exige que todas las celdas de una misma planta compartan el mismo y de zócalo; hoy no existe nada que impida colocar la planta alta a media altura.
- Alineación vertical de muros portantes: exigir que cada celda de pared de planta N tenga pared o losa debajo (hoy solo se valida el soporte de la fila inferior, L167-175).
- Continuidad de escalera: exigir que una escalera_larga tenga al menos una celda de llegada con superficie piso a 2,6 m; hoy la escalera se apoya en cualquier pared y no lleva a ningún lado.
- Cierre de cumbrera: exigir que una cumbrera tenga faldón a ambos lados (dos celdas contiguas con superficie_ofrecida techo); hoy se apila techo sobre techo sin límite (3.3).

Integración M17-M18: el entrepiso habilita la habitación atico de etapa 5 (house_interior L46-59) como espacio real; la escalera larga la conecta con la planta baja. El taller de etapa 4 se materializa como el vano de portón doble de la planta baja.

Por qué es viable: la losa de entrepiso resuelve el hueco de atico (etapa 5) y la escalera larga resuelve el 3.5; el porche da la transición exterior-interior que hoy no existe.

---

---

## 6. Recomendaciones priorizadas

| # | Acción | Archivos | Esfuerzo |
|---|---|---|---|
| 1 | **Conectar los 6 GLB de casa completa** al menos como decoración de `casa_vecino` en el mundo (hoy están muertos) | `scripts/houses/house.gd:21-23`, `scripts/world/` | M |
| 2 | **Receta de zócalo** + validación de nivelación | `data/construccion/piezas/zocalo_piedra.tres` (nuevo), `construccion_validator.gd` | S |
| 3 | **Recetas de pared con vano** (puerta/ventana) usando `pared_puerta.glb` / `pared_ventana.glb` | `data/construccion/piezas/pared_puerta.tres`, `pared_ventana.tres` (nuevos) | S |
| 4 | **Geometría propia para esquina y pilar** (o declarar `tamano`/`altura` distintos) | `data/construccion/piezas/pared_esquina.tres`, `pared_pilar.tres` | S |
| 5 | **Validación de proporción** `tamano` vs `altura` y AABB de malla vs huella declarada | `build_catalog_db.gd:148-174`, `build_ghost.gd:186-197` | M |
| 6 | **Declarar `tamano` y `altura` explícitos en las 46 recetas** (hoy 36 y 21 los omiten) | `data/construccion/piezas/*.tres` | M |
| 7 | **Unificar la posición de puerta** (−Z a 2 m vs +Z a 3 m) | `house.gd:34-35`, `house_manager.gd:196-201` | S |
| 8 | **Completar el catálogo de techo** (cumbrera, alero, hastial) | `data/construccion/piezas/techo_*.tres` | M |
| 9 | **Arreglar BUG-135** (`buscar_cerca` inexistente) y revisar la aserción del test | `house_manager.gd:231-238`, `test_m18_casas.gd:117` | S |
| 10 | **Puente de grids** 1,0 m ↔ 0,25 m para muebles | `house_decor.gd:11-12`, `construccion_mundo.gd:113` | M |

---

## 7. Conclusión final

**El proyecto tiene un sistema de construcción voxel sólido y bien validado en lo que respecta a reglas de colocación (soporte, ocupación, permisos, mundo, recursos, circulación, orden de demolición), pero el ensamblaje de casas está incompleto en tres frentes:**

1. **No existe el tipo de casa.** M18 modela una sola casa abstracta que crece en 5 etapas etiquetadas (choza → ampliación → cocina → taller → sótano/ático), sin geometría propia: `house.gd:21-23` promete "cambia el modelo exterior" y solo devuelve un entero. Los **6 modelos de casa completa** (`casa_choza_ampliada`, `casa_mediana`, `casa_casona`, `casa_mansion`, `casa_vecino`, `casa_completa_ejemplo`) existen en `assets/3d/` con sus fichas, pero **ningún script los referencia**: son assets huérfanos. El jugador construye **piezas de 1 m**, no casas.

2. **Falta toda la validación de proporciones.** Lo que hay es validación de *huella mínima* (`> 0`) y de *encaje* (soporte, pared contigua, no demoler lo que sostiene). No hay relación `tamano`/`altura`, no se compara la malla GLB contra la huella declarada, y **36 de 46 recetas omiten `tamano`** (viven del default 1×1) mientras **21 omiten `altura`** (default 1,0 m). Una puerta de 2 m se apoya en paredes de 1 m y nadie lo objeta; el fantasma puede mostrar un GLB de 4 m en una celda de 1 m.

3. **El ensamblaje no cierra.** La "esquina" y el "pilar" se dibujan con la malla de la pared recta; no hay zócalo (el asset existe sin receta), no hay vano de puerta/ventana (los assets `pared_puerta.glb`/`pared_ventana.glb` existen sin receta), el techo a dos aguas se declara como losa plana de 2×2 sin cumbrera ni alero, la escalera mide 1 m y no comunica plantas, y la casa no es una entidad sino N estructuras independientes. A esto se suman dos convenciones de puerta incompatibles (−Z×2 m vs +Z×3 m) y un BUG-135 registrado que deja muerta la integración M18→M160.

**En una frase:** el andamiaje de datos y validación de M17 es de buena calidad, pero **la casa como objeto construible no está ensamblada**: faltan las piezas de unión (zócalo, vanos, cumbrera, entrepiso, escalera larga), falta la validación de proporción malla/huella, y falta decidir si la casa es geometría (M17) o entidad (M18) — hoy no es ninguna de las dos por completo.

---

*Reporte generado por ERNIE-5.5-Flash-Preview (baidu) sobre Kilo Code — 2026-11-12. Análisis estático; no se ejecutó el motor ni se corrieron las suites headless.*
