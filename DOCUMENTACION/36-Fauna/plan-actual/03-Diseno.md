**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 36: Fauna

## 1. Arquitectura General

```
                     FaunaRegistry.gd (autoload - unica autoridad de datos)
                       catalogo + avistamientos + diario + persistencia
   +-------------------+---------------------+-----------------+-------------+
   |                   |                     |                 |             |
   v                   v                     v                 v             v
FaunaCatalog.gd   FaunaSpawner.gd      FaunaBehavior.gd   (senales)    (senales)
(carga especies   (poblacion, biomas   (FSM por animal,   M56 Foto     M37 Museos
 .tres)           M09, filtros)        delega en M65)     foto tomada  descub.)
   |                   |                     |              |              |
   v                   v                     v              v              v
FaunaSpecies.gd    Voxel Tools (M08) +   M65 Animales IA   registro de   ficha de
(Resource puro,    consulta M09 bioma   (deambular, huida, foto por      especie
sin logica)        por voxel/chunk      alimentarse,       especie       completada
   |                                       descansar)
   v
Datos: res://data/fauna/especies/*.tres (27 especies, expansible sin codigo)
```

Reglas de capas:

- FaunaSpecies es un Resource puro (datos, cero logica).
- FaunaCatalog carga y valida los recursos (IDs unicos, biomas validos).
- FaunaSpawner decide donde/cuando/cuantos (consulta M09, M29, M31, M32) y gestiona el presupuesto.
- FaunaBehavior es un Node por animal: FSM ligera que delega movimiento y deambular a M65; reporta avistamientos al Registry.
- FaunaRegistry (autoload) es la unica fuente de verdad de descubrimientos; emite senales a M56 y M37.
- Sin acoplamiento con UI: la UI del diario consume senales de Registry.

## 2. Componentes

### 2.1 FaunaSpecies (Resource)

| Campo | Tipo | Detalle |
|---|---|---|
| `id` | StringName | Identificador unico en kebab-case (ej: `lombriz_luminosa`) |
| `nombre` | String | Nombre visible para el diario |
| `nombre_cientifico` | String | Ficha de museo (M37) |
| `bioma_ids` | Array[StringName] | Biomas M09 donde habita |
| `rareza` | enum | COMUN, POCO_COMUN, RARA, MUY_RARA |
| `comportamiento` | enum | HUIDA_INSTINTIVA, HUIDA_SUAVE, CURIOSA, PASIVA, PASIVA_AEREA, PASIVA_MARINA |
| `clase` | enum | TERRESTRE, ACUATICA, AEREA, ANFIBIA |
| `hora_inicio/hora_fin` | int | Ventana horaria 0-24 (M31) |
| `estaciones` | Array[int] | Estaciones activas (M29) |
| `clima_especial` | ClimaRequerido (Resource) | null o requisito: lluvia, niebla, nieve, luna llena |
| `escala_min/escala_max` | float | Variacion de tamano (cria/adulto) |
| `velocidad_deambular` | float | Base entregada a M65 |
| `radio_alarma` | float | Distancia de huida en metros |
| `radio_curiosidad` | float | Distancia de acercamiento en metros |
| `velocidad_huida` | float | Multiplo de velocidad base |
| `gregaria` | bool | Permite manadas de 2-5 |
| `variantes_color` | PackedStringArray | 2-3 variantes visuales |
| `sonido_avistamiento` | AudioStream | Glifo de descubrimiento |
| `sonidos_ambiente` | Array[AudioStream] | Sonidos contextuales (M65) |
| `modelo_voxel` | PackedScene | Prefab voxel del animal (M08) |
| `pista_diario` | String | Pista mostrada antes del primer avistamiento |

### 2.2 FaunaRegistry (autoload)

- Carga el catalogo via FaunaCatalog al iniciar; expone `get_especie(id)` y `get_especies_por_bioma(bioma)`.
- Estado por especie: `NO_AVISTADA`, `AVISTADA`, `FOTOGRAFIADA`.
- Historial de encuentros: `{especie_id, fecha_diaria, hora, clima, bioma, fotografiada}` con una entrada por encuentro valido (dedupe por instancia).
- Senales: `especie_avistada(especie_id, contexto)`, `especie_fotografiada(especie_id, foto_id)`, `diario_cambio`.
- Persistencia: JSON versionado en `user://fauna/registro.json` + backup automatico.
- API: `registrar_avistamiento(especie_id, contexto)`, `registrar_foto(especie_id, foto_id)`, `estado_especie(id)`, `porcentaje_descubierto()` (para M37).

### 2.3 FaunaBehavior (Node por animal)

FSM con estados: `INACTIVO` (receta lejana), `DEAMBULAR`, `ALIMENTARSE`, `DESCANSAR`, `ALERTA`, `HUIDA`, `CURIOSA_ACERCARSE`, `OBSERVANDO_JUGADOR`.

- Parametros tomados de su FaunaSpecies al instanciar.
- M65 Animales IA provee: deambular por puntos, evitacion de obstaculos, alimentacion, descanso, sonidos y movimiento suave (interpolacion o animacion voxel).
- M36 define umbrales: radio de alarma, radio de curiosidad, tiempos de espera y recompensa de cercania (el animal "se deja mirar" si el jugador esta quieto mas de 1.5 s).
- Avistamiento: jugador a distancia menor o igual que el radio de observacion (segun personalidad) y especie en pantalla -> `FaunaRegistry.registrar_avistamiento()`.
- Huida no violenta: el animal se aleja en curva suave, sin dano, con sonido; si el jugador se detiene, el animal se detiene a distancia y reevalua.

### 2.4 FaunaSpawner (Node3D en el mundo)

- Burbuja centrada en el jugador (radio 72 m); consulta el bioma M09 en la posicion candidata.
- Pool de instancias por especie (pre-spawn y reutilizacion); instanciacion de la PackedScene voxel.
- Filtros: horario (M31), estacion (M29), clima (M32) y requisito especial (clima/luna).
- Presupuesto: maximo 40 activos en burbuja; maximo 6 por especie; manadas de 2-5 solo en especies gregarias; distancia minima entre individuos (anti-apilamiento).
- Despawn con fade a mas de 96 m; re-evaluacion al cambiar clima/estacion/hora (las especies condicionadas desaparecen con suavidad si la condicion se rompe).
- Determinismo: PRNG de partida M29 para decision de spawn, composicion de manadas, variantes y factor de miedo por individuo (+-10 %).
- Interiores: excluye volumenes de edificios y casas; las acuaticas exigen masa de agua (M09).

## 3. Flujos (texto)

### F1. Spawn de fauna

1. Tick del Spawner (1 s): calcula celdas candidatas dentro de la burbuja.
2. Para cada celda consulta `M09.bioma_en(pos)` y arma el pool de especies validas (bioma + hora M31 + estacion M29 + clima M32).
3. Con el PRNG M29 decide: si spawnear, que especie, cuantos individuos (manada si es gregaria) y variante de color.
4. Valida suelo caminable (no agua para terrestres, no interior de edificios, pendiente aceptable).
5. Instancia desde el pool, aplica pH de miedo individual y escala (cria/adulto).
6. Si se supera el presupuesto por especie o global, no se instancia (se reintenta en el proximo tick).

### F2. Avistamiento y registro

1. FaunaBehavior detecta al jugador dentro del radio de observacion con linea de vision despejada.
2. Comprueba que la especie esta en pantalla (viewport) mas de 0.5 s (evita destellos).
3. Emite `solicitar_avistamiento(especie_id, contexto)` hacia FaunaRegistry.
4. La Registry valida el dedupe (misma instancia no repite entrada) y registra encuentro + fecha + hora + clima + bioma.
5. Emite `especie_avistada` -> la UI del diario actualiza y suena el glifo de descubrimiento.
6. Si la especie era NO_AVISTADA, se desbloquea su ficha completa (antes: solo silueta y pista).

### F3. Huida y reevaluacion

1. Jugador corre o se lanza en diagonal hacia la especie dentro del radio de alarma.
2. Transicion a HUIDA: velocidad x `velocidad_huida`, direccion de fuga con separacion de obstaculos (M65).
3. Al alcanzar una distancia de seguridad, el animal reduce a deambular y reevalua con calma.
4. Si el jugador se detiene mas de 3 s, la especie curiosa puede volver en CURIOSA_ACERCARSE hasta el radio minimo.
5. Nunca hay contacto fisico danino; las colisiones del jugador son blandas (sin empuje agresivo).

### F4. Fotografia (M56) y museo (M37)

1. El jugador saca la camara (M56) y dispara; M56 computa el frustum y devuelve las entidades fotografiadas.
2. Si entre ellas hay una fauna, M56 emite `foto_con_fauna(foto_id, especie_id, contexto)`.
3. FaunaRegistry marca la especie FOTOGRAFIADA (nivel maximo) y guarda la foto_id en su ficha.
4. Emite `especie_fotografiada` -> M37 desbloquea la vitrina/placa de la especie (foto + ficha).
5. El porcentaje de descubrimiento de fauna alimenta el contador global del museo (M37).

### F5. Persistencia

1. Save de partida: FaunaRegistry serializa `registro.json` (version 1) en `user://fauna/`.
2. Backup rotativo (2 copias) antes de sobrescribir.
3. Al cargar: si la version es anterior, migracion incremental; especies desconocidas se agregan con estado NO_AVISTADA.

## 4. Contratos API GDScript

```gdscript
# FaunaSpecies.gd (extends Resource) -- datos puros
signal: ninguno

# FaunaCatalog.gd (autoload o Node)
func cargar_catalogo(directorio: String = "res://data/fauna/especies") -> void
func get_especie(id: StringName) -> FaunaSpecies
func get_especies_por_bioma(bioma: StringName) -> Array[FaunaSpecies]
func get_all_especies() -> Array[FaunaSpecies]
func validar_catalogo() -> Dictionary  # errores: ids duplicados, biomas inexistentes

# FaunaRegistry.gd (autoload "Fauna") -- unica autoridad de descubrimientos
signal especie_avistada(especie_id: StringName, contexto: Dictionary)
signal especie_fotografiada(especie_id: StringName, foto_id: String)
signal diario_cambio

func registrar_avistamiento(especie_id: StringName, contexto: Dictionary) -> void
func registrar_foto(especie_id: StringName, foto_id: String) -> void
func estado_especie(especie_id: StringName) -> int  # NO_AVISTADA/AVISTADA/FOTOGRAFIADA
func porcentaje_descubierto() -> float              # 0.0 a 1.0 para M37
func encontrar_registrados() -> Array[Dictionary]   # historial para el diario

# FaunaSpawner.gd (Node3D)
signal poblacion_cambio(activos: int)

func configurar(radio_burbuja: float, presupuesto_max: int) -> void
func consultar_poblacion() -> int
func reevaluar_por_clima(cambio_clima: Dictionary) -> void
func reevaluar_por_hora(hora: int) -> void
func reevaluar_por_estacion(estacion: int) -> void

# FaunaBehavior.gd (Node en cada animal)
signal solicitar_avistamiento(especie_id: StringName, contexto: Dictionary)

func init_especie(especie: FaunaSpecies) -> void
func estado_actual() -> String
func aplicar_susto(velocidad_jugador: float) -> void

# Contrato con M56 Fotografia (suscripcion de Registry)
# M56 emite: foto_con_fauna(foto_id: String, especie_id: StringName, contexto: Dictionary)
```

## 5. Integraciones

| Módulo | Contrato | Direccion |
|---|---|---|
| M65 Animales IA | FaunaBehavior delega movimiento, deambular, alimentacion, descanso y sonidos; M36 setea personalidad, radios y velocidades por especie | M36 -> M65 (parametros) y M65 -> M36 (eventos) |
| M09 Biomas | `M09.bioma_en(posicion) -> StringName`; el Spawner filtra especies por bioma; acuaticas exigen masa de agua | M36 -> M09 (consulta) |
| M08 Mundo Voxel | Instanciacion de modelos voxel (PackedScene) sobre el terreno; validacion de superficie y pendiente | M36 -> M08 |
| M56 Fotografia | Registry escucha `foto_con_fauna`; M56 reporta especies en frustum al disparar | M56 -> FaunaRegistry |
| M37 Museos | `porcentaje_descubierto()` y fichas completas alimentan colecciones; M37 escucha `especie_fotografiada` | FaunaRegistry -> M37 |
| M29 Tiempo y Calendario | Estaciones y PRNG de partida para spawn y determinismo; pausa congela behavior sin desincronizar | M36 <- M29 |
| M31 Ciclo Día/Noche | Ventanas horarias de spawn; noche/luna llena para especies especiales | M36 <- M31 |
| M32 Clima | Estado de clima (lluvia/niebla/nieve/luna) para especies condicionadas; re-evaluacion inmediata | M36 <- M32 |
| M103 Logging | Logs de spawn/despawn, dedupe y errores de catalogo en el sistema central | M36 -> M103 |

## 6. Presupuesto de Rendimiento (M61)

| Metrica | Tope |
|---|---|
| Individuos activos en burbuja (72 m) | 40 |
| Individuos por especie simultaneos | 6 |
| Tick de FaunaBehavior | 0.2 s (solo burbuja) |
| Receta lejana (fuera de burbuja) | estado congelado, sin pathfinding |
| Despawn por distancia | 96 m con fade 0.5 s |
| LOD de animacion | simplificada a partir de 40 m |
| Consultas de bioma por tick | maximo 20 (cache por celda) |
| Allocs de spawn | 0 (pool por especie) |

## 7. QA

- Test M112: 24 h simuladas -> las especies respetan ventanas horarias y estacionales; la Lombriz Luminosa aparece solo tras lluvia; dedupe sin duplicados.
- Recorrido M114: 3 dias de juego recorriendo todos los biomas; presupuesto respetado (profiler M113); ninguna especie herida ni capturada; diario persistido y museo actualizado.