**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 75: Postgame

## 1. Visión General

El postgame es el **orquestador del contenido después de la historia**: define qué hay, cuándo se desbloquea, y cómo el jugador lo persigue (hoja de ruta del 100%). No implementa componentes nuevos — usa los de los módulos existentes (M22, M73, M37, M55, M72, M74, M16, M17, M25, M24, M19, M50, M36, M18). Entrega: `postgame_catalog.tres` (catálogo de expansiones) + `postgame_manager.gd` (desbloqueo y dirección) + `validate_postgame.gd` (integridad). Substitución indeterminada: `postgame_unlocked` viaja en el save (M59).

## 2. Arquitectura

```
M22 (Historia) ──"final alcanzado"──▶ PostgameManager (M75)
                                          │
                    ┌─────────────────────┼───────────────────────┐
                    ▼                     ▼                       ▼
              Hoja de ruta           Catálogo                Logros finales
            (diario M55)        (postgame_catalog.tres)      (M72, cat. Epílogo)
              │ 100%                    │ FASE 1/FASE 2            │
              ▼                         ▼                          ▼
        M73/M37 (colecciones)     M27/M51/M10/M16/M17     events: M74 (rotativos)
        M25/M24 (ruinas/puzzles)  (cada uno su módulo)
```

### 2.1 Servicios y responsabilidades (modularidad M09)

| Componente | Responsabilidad | Dependencias |
|---|---|---|
| `postgame_manager.gd` | Estado `postgame_unlocked`, hoja de ruta, dirección "¿qué sigue?" | M22 (final), M59 (save), M92 (tutorial) |
| `postgame_catalog.tres` | Catálogo declarativo de expansiones (FASE 1/FASE 2) | M27, M51, M10, M16, M17, M19, M18, M50, M36, M25, M24, M23, M73 |
| `validate_postgame.gd` | Integridad del catálogo y la hoja de ruta | Editor |

**No hay MonoBehaviour de UI en el core:** la hoja de ruta se renderiza en el diario (M55) y el museo (M37) llamando funciones expuestas del manager (regla M09).

### 2.2 Estados

```
LOCKED ──(M22: final alcanzado)──▶ UNLOCKED
UNLOCKED ──▶ RUTA_100 (hoja de ruta activa, diario M55)
UNLOCKED ──▶ EXPANSION_FASE2 (catálogo interno, diseñador)
```

- `LOCKED`: el postgame no existe antes del final (sin spoilers).
- `UNLOCKED`: epílogo + hoja de ruta + logros de la categoría Epílogo.
- FASE 2: nunca visible al jugador; solo catálogo interno.

### 2.3 Flujos principales

**Flujo A — Desbloqueo del postgame:** `M22.historia_terminada()` → PostgameManager.`unlock_postgame()` → guarda `postgame_unlocked=true` (M59) → M92 muestra "¿Qué sigue?" → M44 celebra → diario M55 activa la pestaña "Isla al 100%".

**Flujo B — Hoja de ruta del 100%:** cliente → `PostgameManager.get_roadmap()` → consulta a cada sistema (M73 catálogo, M37 museo, M25 ruinas, M24 puzzles, M16 recetas, M17 mejoras, M74 eventos) → devuelve % por categoría anti-spoiler → UI del diario (M55) muestra metas.

**Flujo C — Evento postgame:** calendario (M29) → M74 programa festival → PostgameManager marca `festival_unlocked` para itinerancia → recompensa única (M38/M20) → logro (M72).

**Flujo D — Expansión (FASE 2):** diseñador agrega entrada en `postgame_catalog.tres` (`fase: 2`) → `validate_postgame.gd` verifica módulo existente → la entrada queda interna hasta su lanzamiento (flag `hidden`).

## 3. Estructura de Datos

### 3.1 `postgame_catalog.tres` — Catálogo de expansiones (Resource)

```gdscript
[resource]
[expansions]
4 entries

[entry_0]
id = "expansion_isla_este"
nombre = "Isla del Este"
fase = 1
requisito = "historia_completa"
modulo = "M27"
hidden = false

[entry_1]
id = "expansion_isla_flotante"
nombre = "Isla Flotante"
fase = 2
requisito = "expansion_isla_este + dirigible"
modulo = "M10"
hidden = true

[entry_2]
id = "expansion_arrecife_profundo"
nombre = "Arrecife Profundo"
fase = 2
requisito = "submarino"
modulo = "M51"
hidden = true

[entry_3]
id = "sistema_jardin_acuatico"
nombre = "Jardín Acuático"
fase = 2
requisito = "herramienta_jardin_acuatico"
modulo = "M16"
hidden = true
```

### 3.2 Hoja de ruta del 100% (derivada, sin duplicación)

```
roadmap = {
  "colecciones_museo":   {source: M73/M37},
  "ruinas_restauradas":  {source: M25},
  "puzzles_resueltos":   {source: M24},
  "recetas_aprendidas":  {source: M16},
  "mejoras_casa":        {source: M17},
  "eventos_experimentados": {source: M74}
}
```

Cada fuente responde `total_conocido` y `completado` con la misma anti-spoiler (M55): **el jugador solo ve lo descubierto**.

### 3.3 `validate_postgame.gd` (test validable)

| Validación | Condición |
|---|---|
| Expansiones | `id` únicos, `fase` ∈ {1,2}, `modulo` existente en CHECKLIST |
| Logros Epílogo | Referencian hitos reales (M72) |
| Hoja de ruta | Cada fuente responde `total_conocido`/`completado` |
| Eventos postgame | Fechas del calendario (M29) sin colisión |

## 4. Persistencia (M59)

- `postgame_unlocked: bool` — slot `save_global.tres` v1.4 (viaja con el mundo).
- La hoja de ruta NO se guarda: se deriva de cada sistema (cero duplicación de estado).
- Catálogo: Resource embebido (constante), no serializado.

## 5. Integración con otros módulos

| Módulo | Rol en el postgame |
|---|---|
| M22 | Final de la historia → desbloqueo; epílogo |
| M92 | "¿Qué sigue?" tras los créditos |
| M73/M37 | El 100% de colecciones (museo completa la ruta) |
| M55 | Pestaña "Isla al 100%" (anti-spoiler) |
| M72 | Logros finales (categoría Epílogo) |
| M74 | Eventos rotativos postgame (calendario M29) |
| M27/M51/M10 | Expansiones de mundo (FASE 2) |
| M19/M18/M50/M36 | Vida nueva postgame (vecinos, muebles, plantas, animales) |
| M25/M24 | Ruina final y puzzles (100%) |
| M16/M17 | Herramienta/mejora postgame (fase 2) |
| M59/M60 | Persistencia y migración |
| M61 | Streaming/LOD de las expansiones de mundo |

## 6. Impacto en Rendimiento (M61)

- La hoja de ruta consulta sistemas existentes **bajo demanda** (al abrir la pestaña), no por frame.
- Catálogo estático: sin consultas por frame.
- Expansiones FASE 2 con streaming (M10/M51) respetan LOD y `chunk_target` (M61): cero carga síncrona.
- Durmientes cooperativos (M49) para habitantes y eventos postgame — sin NPCs siempre activos.