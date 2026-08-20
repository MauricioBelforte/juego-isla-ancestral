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