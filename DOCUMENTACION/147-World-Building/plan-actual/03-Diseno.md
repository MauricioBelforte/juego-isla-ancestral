**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 147: World Building

## 1. Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│ world_bible/  (editorial, Markdown)                         │
│  ├── 00-indice.md                                           │
│  ├── 01-linea-de-tiempo.md                                  │
│  ├── 02-aurora.md                  (RF2)                    │
│  ├── 03-islas.md                  (RF3, M27)                │
│  ├── 04-arquitectos-del-alba.md   (RF4)                     │
│  ├── 05-primeros-jardineros.md    (RF5)                     │
│  ├── 06-la-resonancia.md          (RF6)                     │
│  ├── 07-elisia.md                 (RF7, capas)              │
│  ├── 08-personajes/               (RF8-RF13, un MD por NPC) │
│  ├── 09-religiones.md             (RF14)                    │
│  ├── 10-costumbres.md             (RF15)                    │
│  ├── 11-arquitectura.md           (RF16)                    │
│  ├── 12-simbolos.md               (RF17)                    │
│  ├── 13-lenguaje-antiguo.md       (RF18)                    │
│  ├── 14-calendario-antiguo.md     (RF19)                    │
│  ├── 15-tecnologia.md             (RF20)                    │
│  ├── 16-economia-antigua.md       (RF21)                    │
│  ├── 17-mapas-antiguos.md         (RF22)                    │
│  ├── 18-catastrofes.md            (RF23)                    │
│  ├── 19-migraciones.md            (RF24)                    │
│  ├── 20-leyendas.md               (RF25)                    │
│  └── CHANGELOG.md                                          │
├─────────────────────────────────────────────────────────────┤
│ world_data.json  (técnico, generado desde los MD)           │
└─────────────────────────────────────────────────────────────┘

Scripts:
  sync_world_data.gd     ← MD (marcas DATA:) → world_data.json
  validate_world.gd      ← valida ids, fechas, referencias, capas
  world.gd (autoload)    ← acceso en runtime (solo lectura)
```

## 2. Componentes

### 2.1 `world_bible/*.md`
Cada documento usa secciones con marcas de datos para la extracción automática. Formato de bloque:

```markdown
## DATA { id: "isla_coral", tipo: "isla", capa: 1, consumido_por: ["M27","M21"] }

La Isla Coral se formó cuando...
```

Reglas editoriales:
- Título canónico con id unívoco.
- `capa` 0-4 (modelo de cebolla).
- `consumido_por` lista de módulos.
- Fechas con formato del calendario antiguo + equivalencia (`fecha_gran_calma: "Año 0"`).

### 2.2 `world_data.json`
Estructura generada:

```json
{
  "schema_version": 1,
  "linea_tiempo": [
    { "evento": "despertar_de_la_resonancia", "anio_antiguo": -312, "anio_actual": null, "capa": 3, "consumido_por": ["M25","M24"] }
  ],
  "personajes": [
    { "id": "finneas", "rol": "guia", "capa_conocida": 1, "casa": "aurora", "consumido_por": ["M21","M19"] }
  ],
  "lugares": [
    { "id": "elisia", "capa": 4, "revelado_por": ["sello_del_alba"], "consumido_por": ["M153"] }
  ],
  "simbolos": [
    { "id": "simbolo_del_sello_brisa", "significado": "viento_primeros_jardineros", "consumido_por": ["M24","M148"] }
  ],
  "eventos": [],
  "leyendas": [
    { "id": "cuento_de_la_semilla", "verdad_parcial": true, "consumido_por": ["M148"] }
  ]
}
```

### 2.3 `validate_world.gd` (tool)
Reglas verificables:
1. Todo id referenciado existe (personajes, lugares, símbolos, eventos).
2. Ninguna fecha contradice la línea de tiempo (orden cronológico).
3. `capa` coherente: capa 4 solo consumida por M153/Sellos.
4. Nombres propios no duplicados (sin ambigüedad para M149).
5. `consumido_por` solo lista IDs de módulos existentes.
6. Los MD y el JSON están en sincronía (hash por documento).
7. Sin spoilers: los textos de capas ≥ 3 no aparecen en documentos de capa 0-2 (grep de frases marcadas).

### 2.4 `world.gd` (autoload)
- `get_personaje(id) -> Dictionary`
- `get_lugar(id) -> Dictionary`
- `get_simbolo(id) -> Dictionary`
- `get_capa_minima(consumido_por) -> int` — para el filtro de contenido
- Carga única del JSON en `_ready()`; caché en memoria; sin I/O por frame.

## 3. Línea de Tiempo Canónica (esqueleto)

| Época | Año antiguo | Evento | Capa |
|---|---|---|---|
| Despertar | -312 | La Resonancia despierta | 3 |
| Era de los Arquitectos | -300 a -80 | Construcción de templos y Sellos | 2 |
| Era de los Jardineros | -200 a -90 | Jardines sagrados, idioma del viento | 2 |
| La Gran Quietud | -80 | Catástrofe que detuvo a ambos | 3 |
| Dispersión | -79 a -40 | Migraciones, fundación de asentamientos | 2 |
| Asentamiento moderno | Año 0 | Souvenirs de Aurora, Festival de la Semilla | 0/1 |
| Era del Alba (post-final) | futuro | Reapertura de Elysia (M153) | 4 |

(Detalles completos en `world_bible/01-linea-de-tiempo.md`; los años exactos se afinan con M149/M29.)

## 4. Flujos

### 4.1 Flujo de consumo por un módulo (ej. M21 Diálogos)
```
NPC Finneas habla del Festival de la Semilla
→ M21 consulta world.gd.get_personaje("finneas") → capa_conocida = 1
→ M21 filtra frases del canon de capa ≤ 1
→ nunca expone capas superiores (regla de misterio)
```

### 4.2 Flujo de cambio de canon
```
Diseñador edita world_bible/XX-*.md (bloque DATA)
→ sync_world_data.gd regenera world_data.json
→ validate_world.gd valida consistencia
→ CHANGELOG.md registra el cambio + bump de canon_version
→ CI (M118) re-valida en cada PR
```

### 4.3 Flujo de revelación por Sellos (M153)
```
Jugador obtiene Sello Brisa
→ M153/autorización desbloquea documentos_capa[3] relacionados
→ M21/M25/M148 pueden mostrar contenido de esa capa
→ Elysia (capa 4) solo con Sello del Alba (post-final)
```

## 5. Integración con la Generación Procedural (M08/M10) y M86

- Los nombres de lugares generados proceduralmente deben salir del pool definido en `world_data.json` (coherencia con M149).
- M86 (IA generativa) recibe `world_data.json` como contexto obligatorio; sus salidas pasan por `validate_world.gd` antes de entrar al juego.
- La excepción "mar que no guarda secretos" (análisis) define qué NO puede generar el mundo.

## 6. Metadatos de Observabilidad

| Evento | Datos | Módulo |
|---|---|---|
| `WORLD_CANON_CARGADO` | canon_version | M104 |
| `WORLD_REFERENCIA_ROTA` | id roto | M103 (logging) |
| `WORLD_CAPA_EXPUESTA` | capa y origen | M104/M105 (debug) |
| `WORLD_VALIDATE_FALLIDO` | lista de errores | M118 (CI) |
## Reglas de formato y origen de Aurora (cola total M147 batch)

### Reglas de formato de datos ## DATA { }
- Formato estandar para datos de world-building en markdown.
- Seccion ## DATA { } con campos estructurados.

### Origen de Aurora y su nombre previo
- Aurora: nombre actual de la isla principal.
- Nombre previo: Isla del Alba (historico).

### Capa 0-1: lo que sabe el jugador nuevo
- Capa 0: solo el nombre y ubicacion.
- Capa 1: rumores basicos de los NPC.

### Historia de la Isla Verde
- Isla de cultivos y jardineros.
- Bioma: prado fértil con granjas.
## Historia de las islas y Arquitectos (cola total M147 batch 2)

### Historia de la Isla de las Cenizas (catastrofe)
- Isla de cenizas: catastrofe volcánica que destruyo la civilización.
- Legado: ruinas, cenizas, ecos de la tragedia.

### Origen de los Arquitectos
- Los Arquitectos: civilización avanzada que construyó templos y Sellos.
- Tecnología: mecanismos de piedra, canales de agua, sellos mágicos.

### Legado jugable de los Arquitectos
- Templos (M24/M26), drones, herramientas ancestrales.
- El jugador descubre su legado explorando.

### Origen de los Jardineros
- Los Jardineros: civilización pacífica de la Isla Verde.
- Se dispersaron, no murieron.
## Legado y conexiones (cola total M147 batch 4)

### Legado jugable: templos (M24/M26), drones, herramientas
- Templos como dungeons explorables.
- Drones de los Arquitectos (reliquias).
- Herramientas ancestrales como equipo.

### Idioma del viento (M148)
- Pistas ambientales: sonido del viento indica direccion.
- Sistema de pistas no verbales.

### Dispersion de los Jardineros
- No murieron: se dispersaron por el mundo.
- Pistas de su presencia en islas remotas.

### Conexion con el terreno voxel y sismos (M09/M12)
- Sismos como evento del terreno voxel.
- Afecta la generacion del terreno.
## Legado jugable y conexiones (cola total M147 batch 5)

### Legado jugable: semillas sagradas, festivales de siembra
- Semillas sagradas como coleccionables del postgame.
- Festivales de siembra como evento recurrente.

### Conexion con las herramientas unicas (M13/M26)
- Las herramientas unicas se vinculan con la historia de los Arquitectos.
- Desbloqueo progresivo.

### Conexion con los Sellos (M153)
- Los Sellos son artefactos de los Arquitectos.
- Vinculo con la narrativa del final.

### Idioma del viento (M148)
- Pistas ambientales: sonido del viento indica direccion.
- Sistema de pistas no verbales.
## Biografias y reglas de detalle (cola total M147 batch 6)

### Verdad de Elysia (capa 4) sin spoilers tempranos
- La verdad de Elysia se revela solo en capa 4 (post-final).
- Sin spoilers en las capas anteriores.

### Rol de Elysia en la Era del Alba (post-final)
- Elysia como guia en la Era del Alba.
- Rol narrativo post-final.

### Biografia de Finneas (guia, capa 1)
- Finneas: guia del jugador, capa 1.
- Personalidad: amable, servicial.

### Regla 1-5-25 de detalle por personaje
- Regla: 1 linea de resumen, 5 de detalle, 25 de backstory.
- Estandar para todas las biografias.
## Biografias y reglas (cola total M147 batch 7)

### Biografias de Bruno, Nilo, Vera (capa 2)
- Bruno: arco de redencion, capa 2.
- Nilo: arco de descubrimiento, capa 2.
- Vera: arco de reconciliacion, capa 2.

### Ninos NPC con capa 0 (nunca spoilers)
- Ninos NPC solo tienen capa 0: sin spoilers.
- Informacion basica y amigable.

### Estado actual de las religiones
- Restos de religiones antiguas.
- Festivales que persisten.

### Simbolos religiosos reutilizados en puzzles (M24)
- Simbolos de religiones antiguas en puzzles.
- Resolucion vinculada a la historia.
## Detalles culturales y arquitectonicos (cola total M147 batch 8)

### Ninguna religion siniestra (cozy, M152)
- Las religiones del mundo son acogedoras, no siniestras.
- Coherente con el tono cozy.

### Festivales anuales con origen historico (M74)
- Festivales anuales con origen historico documentado.
- Integracion con el sistema de eventos (M74).

### Costumbres de saludo/despedida (dialogos M21)
- Costumbres de saludo y despedida en dialogos.
- Varian por cultura/isla.

### Detalles arquitectonicos que narran (M148)
- Los detalles arquitectonicos cuentan la historia.
- Sin texto: solo visual.
## Estilo y simbolos (cola total M147 batch 9)

### Estilo de Elysia (distinto, capa 4)
- Estilo visual y narrativo distinto para Elysia.
- Capa 4: revelacion final.

### Un simbodo por Sello (M153)
- Cada Sello tiene un simbodo unico.
- Simbodos en reliquias y murales (M73/M148).

### Decodificacion de simbodos por progresion
- Los simbodos se decodifican por progresion, no de golpe.
- Vinculado a la exploracion.

### Glosario minimo del lenguaje antiguo
- Glosario de palabras del lenguaje antiguo.
- Frases cortas de uso en puzzles (M24).
## Reglas de traduccion y nombres (cola total M147 batch 10)

### Regla: el jugador nunca traduce el idioma completo
- El jugador nunca traduce el idioma completo.
- Solo fragmentos y pistas.

### Nombres derivados del lenguaje antiguo (para M149)
- Nombres de lugares/objetos derivados del lenguaje antiguo.
- Consistencia con el glosario.

### Numerales antiguos (relojes/reliquias)
- Numerales antiguos en relojes y reliquias.
- Sistema de numeracion propio.

### Secundarios con mision (M23) con 5 parrafos
- Secundarios con mision tienen 5 parrafos de dialogo.
- Profundidad narrativa.
## Tecnologias y drones (cola total M147 batch 11)

### Tecnologias de los Jardineros (organicas)
- Tecnologias organicas de los Jardineros.
- Agricultura avanzada, bioingenieria.

### Drones/maquinas residuales operativas (M26)
- Drones residuales aun operativos.
- Maquinas que siguen funcionando.

### Perdida de tecnologia (por que no se repara todo)
- La tecnologia se perdio por falta de conocimiento.
- No por falta de recursos.

### Limite: nada anacronico en manos del jugador
- El jugador no obtiene tecnologia anacronica.
- Coherente con el tono cozy.