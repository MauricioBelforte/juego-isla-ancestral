# 03 — Diseño — M25: Ruinas

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18

## Kit modular (≤ 40 piezas base)

### Definición de pieza

Cada pieza del kit es un `Resource` (GDScript `RefCounted`) con:
- `nombre: String` — identificador único (ej: `suelo_losa`)
- `pivot: Vector3` — esquina inferior izquierda del voxel 0 (nunca centro)
- `snaps: Dictionary` — `{ "norte": Vector3i, "sur": Vector3i, "este": Vector3i, "oeste": Vector3i, "arriba": Vector3i, "abajo": Vector3i }` — offsets de conexión por cara
- `bbox: AABB` — bounding box para cálculo de traslapes
- `grupo: String` — categoría (suelo, muro, apertura, etc.)
- `lod0_mesh: Mesh` — geometría LOD 0 (alta resolución)
- `lod1_mesh: Mesh` — geometría LOD 1 (media)
- `lod2_mesh: Mesh` — geometría LOD 2 (baja, billboard opcional)

### Catálogo de 40 piezas

| # | Grupo | Pieza | Snaps | Notas |
|---|-------|-------|-------|-------|
| 1 | Suelo | `suelo_losa` | 4 caras + arriba/abajo | 1x1 voxel, base universal |
| 2 | Suelo | `suelo_losa_rota` | 2 caras + arriba | Borde irregular, sin snap oeste |
| 3 | Suelo | `suelo_losa_intermedia` | 4 caras | 1x0.5 voxel, transición de altura |
| 4 | Suelo | `suelo_umbral` | 2 caras (este/oeste) | Puerta, 0.5 voxel alto |
| 5 | Suelo | `suelo_escalon` | 4 caras + arriba | 1x1x0.5, ascenso gradual |
| 6 | Muro | `muro_recto` | 2 caras (lados) | 1x2 voxel, pared estándar |
| 7 | Muro | `muro_esquina` | 3 caras | 2x2 voxel, ángulo 90° |
| 8 | Muro | `muro_roto` | 1 cara | Altura variable, borde dentado |
| 9 | Muro | `muro_vano` | 2 caras + vano | Recto con hueco de puerta 1x2 |
| 10 | Muro | `muro_alto` | 2 caras | 1x3 voxel, pared alta de templo |
| 11 | Muro | `muro_ventana` | 2 caras + vano | Recto con hueco de ventana 1x1 |
| 12 | Apertura | `arco` | 2 caras | Arco semicircular, 2x2 voxel |
| 13 | Apertura | `puerta_madera` | 2 caras | Marco + puerta (abrible) |
| 14 | Apertura | `ventana` | 2 caras | Marco simple, sin puerta |
| 15 | Apertura | `pasaje_subterraneo` | 4 caras + arriba | Túnel 2x2, conecta cámaras |
| 16 | Soporte | `columna` | arriba/abajo | 1x1x3, soporte vertical |
| 17 | Soporte | `pilar_roto` | arriba | 1x1x1.5, base de columna rota |
| 18 | Soporte | `contrafuerte` | 2 caras | 2x1x2, refuerzo angular |
| 19 | Techo | `techo_dos_aguas` | 4 caras | A dos vertientes, 2x1 voxel |
| 20 | Techo | `techo_plano` | 4 caras + arriba | 2x2 voxel, azotea |
| 21 | Techo | `cresteria` | 2 caras | Borde decorativo de techo |
| 22 | Escalera | `escalera_recta` | 2 caras | 3 peldaños, sube 1 voxel |
| 23 | Escalera | `escalera_L` | 3 caras | Giros 90°, 4 peldaños |
| 24 | Escalera | `rampa` | 2 caras | Inclinación suave, accesible |
| 25 | Decoración | `balaustrada` | 2 caras | Baranda 1x0.5 voxel |
| 26 | Decoración | `cornisa` | 2 caras | Borde superior de muro |
| 27 | Decoración | `estela` | 1 cara | Losa vertical con glifos |
| 28 | Decoración | `altar` | 4 caras | Mesa 1x1x1, bloque central |
| 29 | Decoración | `banco` | 2 caras | Asiento 1x0.5 voxel |
| 30 | Decoración | `estatua_rota` | 1 cara | Base + torso sin cabeza |
| 31 | Decoración | `fuste_columna` | arriba/abajo | Fragmento horizontal de columna |
| 32 | Canal | `canal_agua` | 2 caras | Surco 1x0.5, fluye en 1 dir |
| 33 | Canal | `canal_agua_cruz` | 4 caras | Intersección de canales |
| 34 | Canal | `compuerta_seca` | 2 caras | Compuerta cerrada (activable) |
| 35 | Especial | `puerta_sellada` | 2 caras | Bloque de piedra (se rompe con puzzle) |
| 36 | Especial | `placa_presion` | 1 cara | Triggers puzzle (Area3D) |
| 37 | Especial | `pedestal_llave` | 4 caras | Soporte de llave-runa |
| 38 | Especial | `espejo_luz` | 2 caras | Reflector para puzzles de luz (M24) |
| 39 | Especial | `forja_rota` | 4 caras | Horno + yunque (talleres) |
| 30 | Especial | `vitrina` | 4 caras | Expositor de objetos (museo M36) |

### Reglas de snapping

- Cada snap es un `Vector3i` relativo al pivote de la pieza.
- Dos piezas se conectan si un snap de pieza A coincide con un snap de pieza B (misma posición en world space).
- **Validación en Editor**: el script `validar_kit.gd` verifica:
  - No hay traslapes (AABB intersection test)
  - No hay huecos > 1 voxel entre piezas adyacentes
  - Todos los snaps están a 1 voxel de distancia máxima
  - El pivote está en esquina inferior izquierda
- **Error ⇒ no build**: si la validación falla, el editor muestra error y no permite exportar.

### Paletas visuales (3 épocas)

| Época | Color predominante | Desgaste | Notas |
|-------|-------------------|----------|-------|
| Temprana | Arena clara + piedra gris | Mínimo | Construcciones nuevas, bordes lisos |
| Media | Piedra oscura + musgo | Moderado | Grietas, vegetación incipiente |
| Tardía | Piedra negra + raíces | Severo | Derrumbes, huecos, flora completa |

Las paletas se aplican como `StandardMaterial3D` override (M47), sin modificar geometría.

## Tipos de ruina (ensamblajes)

| Tipo | Piezas | Puzzles (M24) | Notas |
|---|---|---|---|
| Chozas/ermitas | 3-5 | 1 banda Exploración | entrada de bioma |
| Caseríos/atalayas | 8-15 | 1-2 banda Ritual | refugios, vistas |
| Templos/fortines | 25-60 | 2-3 + 1 multilateral | exigidos por lore |
| Ciudades antiguas | 3-5 bloques | 1 central | perimetral jugable |
| Observatorios | 12-20 | 1 alineación solar (M31) | domo y anillos |
| Estaciones | 6-12 | 0-1 | amarre de vehículos (M66) |
| Faros | 8-16 | 1 luz (M24) | haz visible |
| Puentes antiguos | 6-10 | 0 | arco y colgante |
| Jardines | 10-18 | 1 agua (M24) | canales y terrazas |
| Edificios abandonados | 12-24 | 0-1 | 2 plantas, balcón roto |
| Bibliotecas | 10-16 | 1 símbolos | cofre de lore |
| Talleres | 8-14 | 1 herramientas | clues de inventario |
| Cámaras secretas | 2-6 (adicionales) | 0-1 | 2+ caminos siempre |

### Especificación por tipo

**Chozas/ermitas (3-5 piezas):**
- Estructura: 1 suelo + 3 muros (oeste, sur, este) + 1 techo plano
- Puerta: vano en muro oeste (sin puerta física)
- Interior: 1 altar o estela
- Puzzle: placa de presión → puerta sellada (framework M24)
- Ejemplo: `generador_ruina.gd` (chozavil existente)

**Caseríos/atalayas (8-15 piezas):**
- Estructura: 4-6 suelos + 4-8 muros + 1-2 techos + escalera
- Variantes: 2 plantas (atalaya) o planta única amplia (caserío)
- Interior: 1-2 altares + 1 estela con glifos
- Puzzles: banda Ritual (2-3 emisores → 1 receptor)

**Templos/fortines (25-60 piezas):**
- Plano en cruz: nave central + crucero + ábside
- Vestíbulo (entrada) + sancta (sala principal)
- 2-3 puzzles + 1 multilateral (requiere 2+ activadores simultáneos)
- Interior: altar mayor + vitrinas + murales en paredes

**Ciudades antiguas (3-5 bloques urbanos):**
- Cada bloque: 8-12 piezas (muros perimetrales + edificios internos)
- Calles perimetrales jugables (2 voxel de ancho mínimo)
- Plaza central con acueducto (canales de agua)
- 1 puzzle central en la plaza

**Observatorios (12-20 piezas):**
- Estructura circular: muros curvos (aproximados con esquinas)
- Domo con agujero cenital (para alineación solar M31)
- Anillos de piedra exteriores (alineación solar)
- 1 puzzle de luz: espejo → agujero cenital → receptor

**Estaciones (6-12 piezas):**
- Estructura linear: muros laterales + techo plano
- Amarre de vehículos (M66): puntos de anclaje en el suelo
- 0-1 puzzle (opcional, banda Exploración)

**Faros (8-16 piezas):**
- Torre vertical: escalera recta + platforma superior
- Haz physicalizable (luz M24): cono de luz visible desde lejos
- Linterna de memoria (narrativa M22): objeto interactuable
- 1 puzzle de luz: activar secuencia de espejos

**Puentes antiguos (6-10 piezas):**
- Variante arco: 4 pilares + 2 torres + arcos
- Variante colgante: 3 cables + 2 torres + tablero
- Sin puzzles (estructura pura)
- Conectan biomas separados (océano/ríos)

**Jardines (10-18 piezas):**
- Terrazas con canales de agua (canales M25 + compuertas)
- Vegetación: flora ancestral (assets M45)
- 1 puzzle de agua suave (M24): redirigir flujo

**Edificios abandonados (12-24 piezas):**
- 2 plantas con escalera interna
- Balcón roto (muro_roto en planta alta)
- Interiores solo donde son necesarios (no todos los cuartos)
- 0-1 puzzle

**Bibliotecas (10-16 piezas):**
- Estructura con estanterías (muros internos)
- Mural del mapa (objeto especial, integración con M58)
- Cofre de lore (M66): 1-2 objetos arqueológicos únicos
- 1 puzzle de símbolos (glifos M24)

**Talleres (8-14 piezas):**
- Hornos y yunques rotos (forja_rota + decoración)
- Clues de herramientas del inventario (M24): objetos que sugieren recetas
- 1 puzzle de herramientas

**Cámaras secretas (2-6 piezas, adicionales):**
- Siempre 2+ caminos de acceso (M66)
- Acceso principal: placa/estatua → puerta falsa
- Acceso secundario: pasaje subterráneo o ventana oculta
- Pista ambiental: viento (M32) o sonido
- 0-1 puzzle

## Sistemas de activación (8 reutilizables)

Cada activador es un `Node3D` con `class_name` propio, conectado al framework M24 (PuzzleRoom). Implementan el contrato de emisor/receptor de M24.

### 1. Palanca (cerrojo de puerta)
- **Script:** `activador_palanca.gd`
- **Geometry:** palanca en base de muro (1 pieza decorativa)
- **Interacción:** jugador interactúa (E) → palanca cambia de estado
- **Emisor:** `set_emisor(id, true/false)`
- **Animación:** rotación 90° con Tween
- **Restricción:** solo 1 palanca por PuzzleRoom, toggle on/off

### 2. Anillo giratorio (sello de cámara)
- **Script:** `activador_anillo.gd`
- **Geometry:** anillo de piedra en suelo (2 piezas: base + anillo)
- **Interacción:** jugador gira (E) → anillo rota 90°
- **Emisor:** `set_emisor(id, true)` cuando ángulo correcto
- **Animación:** rotación suave con Tween
- **Restricción:** 3-4 posiciones posibles, solo 1 correcta

### 3. Estrella giradora (puerta de templo)
- **Script:** `activador_estrella.gd`
- **Geometry:** estrella de 5 puntas en muro (1 pieza especial)
- **Interacción:** jugador gira (E) → estrella rota 72° por click
- **Emisor:** `set_emisor(id, true)` cuando puntas apuntan a símbolos
- **Animación:** rotación con easing
- **Restricción:** 5 posiciones, secuencia específica (glifos del suelo dan pista)

### 4. Llave-runa (inscripción que "bebe" glifo)
- **Script:** `activador_llave_runa.gd`
- **Geometry:** pedestal con ranura (1 pieza: pedestal_llave)
- **Interacción:** jugador lleva glifo en inventario → acerca al pedestal
- **Emisor:** `set_emisor(id, true)` al insertar glifo correcto
- **Animación:** glifo se funde en el pedestal (shader dissolve)
- **Restricción:** 1 glifo por pedestal, glifos son únicos (M24 catalog)

### 5. Timón de agua (compuertas)
- **Script:** `activador_timon_agua.gd`
- **Geometry:** compuerta seca + timón (2 piezas: compuerta_seca + decoración)
- **Interacción:** jugador gira timón (E) → compuerta se abre
- **Emisor:** `set_emisor(id, true)` → activa canal de agua (M24 puzzle de agua)
- **Animación:** compuerta se eleva con Tween, agua fluye
- **Restricción:** 1 timón por sistema de canales

### 6. Martillo de piedra (percutir pedestal)
- **Script:** `activador_martillo.gd`
- **Geometry:** martillo de piedra en suelo + pedestal con marca (2 piezas)
- **Interacción:** jugador toma martillo → golpea pedestal (E)
- **Emisor:** `set_emisor(id, true)` al golpear
- **Animación:** flash de luz en el golpe, sonido de piedra
- **Restricción:** martillo es objeto de inventario temporal (se consume al usar)

### 7. Vela triple (encender 3 velas en orden)
- **Script:** `activador_vela_triple.gd`
- **Geometry:** 3 velas en positions fijas (3 piezas decorativas)
- **Interacción:** jugador enciende velas (E) en orden correcto
- **Emisor:** `set_emisor(id, true)` cuando las 3 están encendidas en orden
- **Animación:** llama de vela (particle system simple)
- **Restricción:** 1 solo orden correcto (pista: símbolos en el suelo numerados)

### 8. Puerta falsa (rodar a cámara secreta)
- **Script:** `activador_puerta_falsa.gd`
- **Geometry:** muro aparentemente normal (muro_recto modificado)
- **Interacción:** jugador empuja (E) → muro se desliza
- **Emisor:** `set_emisor(id, true)` → abre pasaje
- **Animación:** muro se desliza horizontalmente con Tween
- **Restricción:** 2+ accesos a la cámara (esta es solo 1)

### Integración con M24

Todos los activadores implementan:
```gdscript
# Contrato M24
signal emisor_cambiado(id: int, activo: bool)
func set_emisor(id: int, activo: bool) -> void
func get_emisor() -> bool
```

Los detalles de reglas (cuándo se resuelve el puzzle) viven en los datos de M24 (`PuzzleRoom`). Los activadores solo reportan estado.

## Progresión de descubrimiento (persistida)

### Estados

```
NoDescubierta → Descubierta → Explorada → Completada
```

### Transiciones

| De | A | Condición | Eventos emitidos |
|----|---|-----------|-----------------|
| NoDescubierta | Descubierta | Jugador a ≤15 m O ve POI en horizonte (M63) | `ruina_descubierta(ruina_id)` → diario, mapa M58 |
| Descubierta | Explorada | Entra al interior O resuelve 50% puzzles | `ruina_explorada(ruina_id)` → diario, mapa M58 |
| Explorada | Completada | Todos puzzles resueltos + relicto guardado (M66) | `ruina_completada(ruina_id)` → diario, mapa M58, museo M36 |

### Persistencia

- Cada ruina guarda su estado en el save (M59): `ruinas_estado: { "ruina_id_1": "completada", ... }`
- Guardado atómico en cada transición (no batch).
- El estado es inmutable una vez en `Completada` (no hay retroceso).

### Script

```gdscript
# ruina_progresion.gd
class_name RuinaProgresion
extends Node

enum Estado { NO_DESCUBIERTA, DESCUBIERTA, EXPLORADA, COMPLETADA }

signal estado_cambiado(ruina_id: String, nuevo_estado: Estado)

var _estado_actual: Estado = Estado.NO_DESCUBIERTA

func verificar_descubrimiento(distancia: float) -> void:
    if _estado_actual == Estado.NO_DESCUBIERTA and distancia <= 15.0:
        _cambiar_estado(Estado.DESCUBIERTA)

func verificar_exploracion(puzzles_resueltos: int, puzzles_total: int) -> void:
    if _estado_actual == Estado.DESCUBIERTA:
        if puzzles_resueltos >= puzzles_total * 0.5:
            _cambiar_estado(Estado.EXPLORADA)

func verificar_completado(puzzles_resueltos: int, puzzles_total: int, relicto_guardado: bool) -> void:
    if _estado_actual == Estado.EXPLORADA:
        if puzzles_resueltos >= puzzles_total and relicto_guardado:
            _cambiar_estado(Estado.COMPLETADA)

func _cambiar_estado(nuevo: Estado) -> void:
    _estado_actual = nuevo
    estado_cambiado.emit(_obtener_id(), nuevo)

func _obtener_id() -> String:
    return owner.name if owner else name
```

## Murales, inscripciones y objetos arqueológicos

### Murales (12 total)

| # | Época | Tema | Ubicación típica | Desbloquea |
|---|-------|------|------------------|------------|
| M1 | Temprana | Fundación de la civilización | Templo mayor | Diario + M36 |
| M2 | Temprana | Descubrimiento del poder ancestral | Observatorio | Diario + M36 |
| M3 | Temprana | Primeros contactos entre islas | Estación costera | Diario + M36 |
| M4 | Media | Construcción de ciudades | Ciudad antigua | Diario + M36 |
| M5 | Media | Guerras y alianzas | Fortín | Diario + M36 |
| M6 | Media | Arte y cultura | Biblioteca | Diario + M36 |
| M7 | Media | Ciencia y astronomía | Observatorio | Diario + M36 |
| M8 | Tardía | Declive y abandono | Ruina grande | Diario + M36 |
| M9 | Tardía | Últimos días | Templo abandonado | Diario + M36 |
| M10 | Tardía | Legado y secretos | Cámara secreta | Diario + M36 |
| M11 | — | Mapa del mundo antiguo | Biblioteca (mural especial) | Mapa M58 |
| M12 | — | Linea temporal completa | Museo M36 | M36 (exhibición) |

- Cada mural es un `StaticBody3D` con textura (M47) y `Area3D` para detección.
- Al interactuar (E), se registra en el diario y se desbloquea la entrada en M36.

### Inscripciones / Glifos (30-60 total)

- **Familia de símbolos**: 8 símbolos base que se combinan en glifos compuestos.
- **Cada glifo** es un `Resource` con: `id: String`, `simbolos: Array[String]`, `significado: String`.
- **Catálogo**: se llena progresivamente al descubrir inscripciones en ruinas.
- **Uso en M24**: los glifos son las "llaves" de los puzzles de símbolos (bibliotecas, templos).
- **Glosario**: se muestra en el diario del jugador, agrupado por época.

### Objetos arqueológicos (25 total)

| # | Objeto | Época | Riqueza | Ubicación típica |
|---|--------|-------|---------|------------------|
| O1 | Máscara de ancestro | Temprana | Alta | Templo mayor |
| O2 | Vasija ancestral | Temprana | Media | Chozas |
| O3 | Obsidiana tallada | Temprana | Alta | Observatorio |
| O4 | Anillo de piedra | Media | Media | Ciudad antigua |
| O5 | Cráneo tallado | Media | Baja | Fortín |
| O6 | Placa de bronce | Media | Alta | Biblioteca |
| O7 | Espada rota | Media | Media | Fortín |
| O8 | Fíbula de oro | Tardía | Alta | Cámara secreta |
| O9 | Sello de cera | Tardía | Baja | Edificio abandonado |
| O10 | Moneda antigua | Tardía | Baja | Jardines |
| ... | ... | ... | ... | ... |
| O25 | Cristal ancestral | — | Legendaria | Cámara secreta final |

**3 estados por objeto:**
1. **Enterrado**: visible en el suelo (voxel especial), necesita herramienta para excavar
2. **Expuesto**: recogido por el jugador, en inventario
3. **Museo**: entregado a M36, en vitrina con placa descriptiva

**Copia única**: cada objeto existe 1 vez en el mundo. Si se entrega al museo, desaparece del inventario. Si se pierde, hay cofre de respaldo en M66.

## Conexiones entre ruinas

### Caminos (M28)
- Caminos de 2-4 tramos entre ruinas cercanas (2-4 ruinas por bioma).
- Los tramos son nodos del sistema de caminos M28 y se validan con NavigationServer3D.
- Cada tramo: 2-4 piezas del kit (suelos + muros laterales opcionales).

### Conexiones costeras
- Puentes antiguos conectan biomas separados (océano/ríos).
- Faros marcan la ruta costera (haz visible desde lejos).
- Estaciones son amarres de vehículos (M66).

### Conexiones subterráneas
- Pasajes subterráneos conectan ruinas cercanas (bajo tierra).
- Cámaras secretas pueden estar debajo de ruinas principales.
- Acceso por pasaje_subterraneo + escalera_recta.

## Presupuestos

- **Piezas estáticas**: LOD 0-2 vía M63 (culling por región); sin simulación.
- **Editor**: validación de kit (pivotes, snaps, traslapes) en consola; error ⇒ no build.
- **Runtime**: solo transiciones de estado y eventos; cero Update por ruina (estática).
- **Memoria**: cada ruina ≤ 50 piezas × 3 LODs = 150 meshes máximo. Con 10 ruinas visibles = 1500 meshes (dentro del budget de M61).
- **Draw calls**: batching por material (M47); cada ruina = 1-3 draw calls máximo.