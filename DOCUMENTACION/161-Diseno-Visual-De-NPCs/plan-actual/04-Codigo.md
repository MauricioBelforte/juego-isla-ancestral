**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md â€” MÃ³dulo 161: DiseÃ±o Visual de NPCs

## 1. Estructura de Datos Propuesta

### 1.1 Resource: NPCVisualData.gd

```gdscript
## Datos visuales de un NPC.
class_name NPCVisualData
extends Resource

## ID del NPC (coincide con M19)
@export var npc_id: String

## Nombre del NPC
@export var nombre: String

## Isla donde vive
@export var isla: IslandType

## Rasgos fÃ­sicos
@export var piel: PielType
@export var cabello: CabelloType
@export var ojos: OjosType
@export var complexion: ComplexionType

## Ropa
@export var sombrero: RopaData
@export var torso: RopaData
@export var piernas: RopaData
@export var pies: RopaData

## Accesorios
@export var accesorios: Array[AccesorioData]

## Herramienta en mano (ID de M159 o vacÃ­o)
@export var herramienta_derecha: String
@export var herramienta_izquierda: String

## Variantes estacionales
@export var variantes_estacionales: Dictionary  # EstacionType -> NPCVisualData

## Retrato 2D (path a textura)
@export var retrato_path: String
```

### 1.2 Resource: RopaData.gd

```gdscript
## Datos de una prenda de ropa.
class_name RopaData
extends Resource

## Nombre de la prenda
@export var nombre: String

## Estilo de la prenda
@export var estilo: String

## Color principal (HEX)
@export var color_principal: String

## Color secundario (HEX, opcional)
@export var color_secundario: String

## Material
@export var material: String

## Notas para artistas
@export var notas: String
```

### 1.3 Resource: AccesorioData.gd

```gdscript
## Datos de un accesorio.
class_name AccesorioData
extends Resource

## Nombre del accesorio
@export var nombre: String

## UbicaciÃ³n (cuello, manos, cinturÃ³n, cabeza)
@export var ubicacion: String

## Color (HEX)
@export var color: String

## Notas
@export var notas: String
```

### 1.4 Enums

```gdscript
## Tono de piel.
enum PielType {
    CLARO,    ## SK-01 #F5D6C4
    MEDIO,    ## SK-02 #D4A882
    BRonceado, ## SK-03 #C49A6C
    MORENO,   ## SK-04 #8B6914
    OSCURO    ## SK-05 #5C4033
}

## Tipo de cabello.
enum CabelloType {
    RUBIO,        ## HR-01 #F5DEB3
    CASTANO_CLARO, ## HR-02 #C4A882
    CASTANO,      ## HR-03 #8B6914
    PELO_ROJO,    ## HR-04 #B22222
    NEGRO,        ## HR-05 #2C2C2C
    CANOSO,       ## HR-06 #9E9E9E
    BLANCO,       ## HR-07 #F5F5DC
    PELO_ROJO_CLARO ## HR-08 #CD853F
}

## Color de ojos.
enum OjosType {
    MARRON,  ## EY-01 #5C4033
    VERDE,   ## EY-02 #228B22
    AZUL,    ## EY-03 #5F9EA0
    AMBAR,   ## EY-04 #FFBF00
    GRIS     ## EY-05 #808080
}

## ComplexiÃ³n fÃ­sica.
enum ComplexionType {
    MEDIA,
    MUSCULOSA,
    DELGADA,
    REDONDA,
    ALTA,
    PEQUENA  ## para niÃ±os
}

## Estaciones del aÃ±o.
enum EstacionType {
    PRIMAVERA,
    VERANO,
    OTONIO,
    INVIERNO
}
```

### 1.5 Autoload: NPCVisualDatabase.gd

```gdscript
## Autoload que gestiona el diseÃ±o visual de todos los NPCs.
extends Node

## Diccionario de diseÃ±os visuales: npc_id -> NPCVisualData
var visuals: Dictionary = {}

func _ready() -> void:
    _load_all_visuals()

## Carga todos los diseÃ±os visuales desde archivos .tres
func _load_all_visuals() -> void:
    var dir = DirAccess.open("res://data/npc_visuals/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var visual = load("res://data/npc_visuals/" + file_name) as NPCVisualData
                if visual:
                    visuals[visual.npc_id] = visual
            file_name = dir.get_next()

## Obtiene el diseÃ±o visual de un NPC
func get_visual(npc_id: String) -> NPCVisualData:
    return visuals.get(npc_id)

## Obtiene todos los NPCs de una isla
func get_visuals_by_island(isla: IslandType) -> Array[NPCVisualData]:
    var result: Array[NPCVisualData] = []
    for v in visuals.values():
        if v.isla == isla:
            result.append(v)
    return result

## Obtiene la variante estacional de un NPC
func get_seasonal_variant(npc_id: String, estacion: EstacionType) -> NPCVisualData:
    var visual = get_visual(npc_id)
    if visual and visual.variantes_estacionales.has(estacion):
        return visual.variantes_estacionales[estacion]
    return visual
```

## 2. Archivos de Datos

### 2.1 Estructura de Carpetas

```
data/
â”œâ”€â”€ npc_visuals/
â”‚   â”œâ”€â”€ RIZ/
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-001-mayor.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-002-carpintero.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-003-vendedora.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-004-sabio.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-005-pescador.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-006-agricultora.tres
â”‚   â”‚   â”œâ”€â”€ NPC-RIZ-007-nina.tres
â”‚   â”‚   â””â”€â”€ NPC-RIZ-008-animador.tres
â”‚   â”œâ”€â”€ COR/
â”‚   â”‚   â”œâ”€â”€ NPC-COR-001-herrero.tres
â”‚   â”‚   â”œâ”€â”€ NPC-COR-002-pescadora.tres
â”‚   â”‚   â”œâ”€â”€ NPC-COR-003-viajero.tres
â”‚   â”‚   â”œâ”€â”€ NPC-COR-004-guardia.tres
â”‚   â”‚   â””â”€â”€ NPC-COR-005-nina.tres
â”‚   â”œâ”€â”€ CEN/
â”‚   â”‚   â”œâ”€â”€ NPC-CEN-001-herrero_adv.tres
â”‚   â”‚   â”œâ”€â”€ NPC-CEN-002-minero.tres
â”‚   â”‚   â”œâ”€â”€ NPC-CEN-003-cocinera.tres
â”‚   â”‚   â”œâ”€â”€ NPC-CEN-004-bibliotecario.tres
â”‚   â”‚   â””â”€â”€ NPC-CEN-005-guardia.tres
â”‚   â””â”€â”€ AUR/
â”‚       â”œâ”€â”€ NPC-AUR-001-encantador.tres
â”‚       â”œâ”€â”€ NPC-AUR-002-sanadora.tres
â”‚       â”œâ”€â”€ NPC-AUR-003-guardia.tres
â”‚       â”œâ”€â”€ NPC-AUR-004-artista.tres
â”‚       â””â”€â”€ NPC-AUR-005-viajero.tres
```

### 2.2 Ejemplo: NPC-RIZ-002-carpintero.tres

```gdscript
[gd_resource type="Resource" script_class="NPCVisualData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/data/NPCVisualData.gd" id="1"]

[resource]
script = ExtResource("1")
npc_id = "NPC-RIZ-002"
nombre = "Carpintero"
isla = 0  # RIZ
piel = 2  # BRonceado
cabello = 2  # CASTANO
ojos = 3  # AMBAR
complexion = 1  # MUSCULOSA

sombrero = {
    "nombre": "Fedora de paja",
    "estilo": "Ala ancha, cinta marrÃ³n",
    "color_principal": "#F5DEB3",
    "color_secundario": "#8B6914",
    "material": "Paja",
    "notas": "Cinta de cuero alrededor"
}

torso = {
    "nombre": "Camisa de trabajo",
    "estilo": "Manga corta, arremangada",
    "color_principal": "#C4A882",
    "material": "Lino grueso",
    "notas": "Manchas de aserrÃ­n"
}

piernas = {
    "nombre": "PantalÃ³n de trabajo",
    "estilo": "Largo, resistente",
    "color_principal": "#8B6914",
    "material": "Tela gruesa",
    "notas": "Manchas de aserrÃ­n"
}

pies = {
    "nombre": "Botas de carpintero",
    "estilo": "Altas, cuero grueso",
    "color_principal": "#5C4033",
    "material": "Cuero",
    "notas": "Sin cordones, suelas gruesas"
}

herramienta_derecha = "OBJ-HER-001"  # Hacha Madera T1
herramienta_izquierda = ""

accesorios = [
    {"nombre": "Delantal de cuero", "ubicacion": "torso", "color": "#A0522D", "notas": "Bolsillos para herramientas"},
    {"nombre": "Cinta mÃ©trica", "ubicacion": "cinturon", "color": "#FFD700", "notas": "En cinturÃ³n"},
    {"nombre": "LÃ¡piz", "ubicacion": "cabeza", "color": "#FFD700", "notas": "DetrÃ¡s de la oreja"}
]
```

## 3. IntegraciÃ³n con Otros MÃ³dulos

### 3.1 M19 (NPC y Vecinos)

```gdscript
# En NPCManager.gd
func get_npc_visual(npc_id: String) -> NPCVisualData:
    return NPCVisualDatabase.get_visual(npc_id)
```

### 3.2 M45 (Arte 3D)

```gdscript
# En ModelExporter.gd
func export_npc_model(npc_id: String) -> Dictionary:
    var visual = NPCVisualDatabase.get_visual(npc_id)
    return {
        "piel": visual.piel,
        "cabello": visual.cabello,
        "ojos": visual.ojos,
        "ropa": [visual.sombrero, visual.torso, visual.piernas, visual.pies],
        "accesorios": visual.accesorios,
        "herramienta": visual.herramienta_derecha
    }
```

### 3.3 M46 (Arte 2D)

```gdscript
# En PortraitGenerator.gd
func generate_portrait(npc_id: String) -> Texture2D:
    var visual = NPCVisualDatabase.get_visual(npc_id)
    # Generar retrato basado en visual
    # Usar colores de piel, cabello, ojos
    # Agregar sombrero y accesorios
    return portrait_texture
```

### 3.4 M155 (Vestimenta)

```gdscript
# En EquipManager.gd
func can_npc_wear_item(npc_id: String, item_id: String) -> bool:
    var visual = NPCVisualDatabase.get_visual(npc_id)
    var item = ItemDatabase.get_item(item_id)
    # Verificar si el NPC puede usar esta prenda
    return item.categoria == "ROPA"
```

### 3.5 M160 (Ubicaciones)

```gdscript
# En WorldLocations.gd
func get_npc_at_location(location_id: String) -> Array[String]:
    var location = WorldLocations.get_location(location_id)
    return location.npcs
```

## 4. Notas del Agente

**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 15:37
**Estado:** Iter 2 completada â€” catÃ¡logo 23 .tres + tests headless + docs

### Lo que hice
- CompletÃ© 22 archivos `.tres` faltantes (RIZ 7 + COR 5 + CEN 5 + AUR 5) sumados al ejemplo previo NPC-RIZ-002.
- OrganicÃ© la carpeta `data/npc_visuals/` en subcarpetas por isla (`RIZ/`, `COR/`, `CEN/`, `AUR/`).
- ExpandÃ­ `test_npc_visual_database.gd` con tests de carga, filtrado por isla, validaciÃ³n de campos obligatorios y validaciÃ³n de formato HEX.
- ActualicÃ© `05-Checklist.md`: marquÃ© [x] los Ã­tems de diseÃ±o/colores/.tres/herramientas/accesorios y testing.

### Lo que NO pude hacer (honestidad obligatoria)
- No creÃ© variantes estacionales como archivos `.tres` separados. El diseÃ±o de datos (`variantes_estacionales: Dictionary`) estÃ¡ listo, pero quedan como trabajo futuro los 92 archivos de variante (23 NPCs Ã— 4 estaciones).

### Intentos fallidos / decisiones
- IntentÃ© autocontener variantes en el `.tres` base, pero Godot requiere recursos externos para `Dictionary` de variantes. Se deja documentado en `04-Codigo.md` y log.

### Recomendaciones para el prÃ³ximo agente
- Crear variantes estacionales siguiendo la paleta Â§9.4 de `03-Diseno.md`.
- Integrar con M45 (modelos 3D) y M46 (retratos 2D) cuando esos mÃ³dulos avancen.
- Verificar que los IDs M159 de herramientas existan en `ItemDatabase` al integrar con M159.

```


## Notas de Integración M161 (agnes-3-flash, 2026-10-21, frente N650 #752)

**Estado de integración cross-módulo (verificado por grep en scripts/+data/, excluyendo M161 propio):**

| Módulo | Consumo de M161 | Estado |
|---|---|---|
| M159 (Catálogo) | **Wired** — 7/7 `herramienta_derecha` de los 23 NPCs resuelven a `data/items/` (art_005, her_001/004/006, tal_002) | verificado |
| M19 (Villagers) | **Scoping distinto** — M19 = 14 NPCs nombrados (`data/villagers/`), M161 = 23 diseños por rol. No hay 1:1; consumo de M161 por villager M19 **pendiente** | a decisión del director |
| M45 (Modelos 3D) / M46 (Retratos 2D) | **Pendiente (los 2 `[?]`)** — `modelo_3d=null` + `retrato_path=""` en los 23; owner M45/M46 + Hy4 | externo |
| M155 (Vestimenta) / M160 (Ubicaciones) / M27 / M29 / M39 | **No consumen aún** `NPCVisualData` — solo `_colector_sintaxis.gd` pre-carga el script (verificación de sintaxis, no consumo funcional) | integración docs |

**Conclusión:** los **datos + validación de M161 están listos y verificados** (test 356/0, validador 23/0). El **consumo cross-módulo (M19/M155/M160/M27/M29/M39) queda como deuda de integración** — M161 aporta el visual; que M19 et al. lo consuman es trabajo de esos módulos (no lo toco, §21.4). El `README-FORMATO-IDS.md` documenta cómo integrarlo.
