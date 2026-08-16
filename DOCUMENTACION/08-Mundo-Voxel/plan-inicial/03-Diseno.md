**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 08: Mundo Voxel

## 1. Dimensiones y constantes del mundo

| Constante | Valor | Notas |
|---|---|---|
| Voxel | 1×1×1 m | GDD §3A |
| Chunk | 16×16×16 | Base del LOD y streaming |
| Mundo Aurora | 2048×2048 m | Altura -64…+192 |
| Islas viaje | 1024×1024 m | Cors/Verde (v1.0) |
| Altura de personaje | 1.8 m (2 bloques) | Cabecera 1 bloque de margen |
| Slab de medio bloque | SÍ (decoración/umbrales) | Prop especial |

## 2. Catálogo de bloques inicial (Aurora, ~30 tipos)

### Sólidos naturales
| Bloque | Propiedades |
|---|---|
| Tierra | Solida, recurso (pala) |
| Césped | Solida, decorativa al picar (deja tierra) |
| Piedra | Solida, recurso (pico) |
| Roca madre | Permanente, no extraíble (fondo del mundo) |
| Arena | Solida, recurso (pala), gravedad opcional |
| Arcilla | Solida, recurso (pala) |
| Madera (tronco) | Solida, recurso (hacha, no destruye árbol: queda tocón) |
| Madera estructural (tabla) | Solida, constructiva |

### Minerales (en piedra)
| Bloque | Propiedades |
|---|---|
| Cobre / Hierro (vetas) | Solida, recurso (pico), rareza media |
| Cristal de resonancia | Solida, recurso raro (pico), brilla |
| Gemas (ámbar crudo) | Solida, recurso raro (pico) |

### Transparentes / luces
| Bloque | Propiedades |
|---|---|
| Vidrio | Transparente |
| Cristal antiguo | Transparente, puzzle (espejo) |
| Lámpara de glifo | Transparente, emisiva (luz) |
| Hielo | Transparente (islas frías) |

### Líquido
| Bloque | Propiedades |
|---|---|
| Agua | Líquido con nivel; varas de flujo lo congelan/evaporan (M24) |

### Decorativos / interactivos
| Bloque | Propiedades |
|---|---|
| Placa de presión | Interactivo (receptor de peso) |
| Receptor de luz | Interactivo (receptor de haz) |
| Glifo emisor | Interactivo (emisor de haz), puzzle |
| Bloque deslizante | Puzzle (empujable), física en grilla |
| Vasija de flujo | Interactivo (modifica agua) |
| Flores/bayas (prop) | Decorativo no sólido (igual que M50 vegetación) |

### Constructivos (M17)
| Bloque | Propiedades |
|---|---|
| Pared (adobe), piso, teja | Solidos constructivos con texturas por bioma |

## 3. Modelo de datos del bloque (Resource)

```
BlockType (Resource .tres)
├── id (enum) · nombre · textura/skin por biome
├── flags: solido / transparente / liquido / gravedad / emisivo
├── tool: none/pala/pico/hacha (eficiencia base)
├── sound: hit/place/break (M43)
├── drop: item(s) (M15) · permanencia (barro permanente)
└── puzzle_props: tipo (si aplica) → framework M24
```

## 4. Reglas de colocación y validación

1. **Protección de ruinas/templos:** bloques marcados `permanente` no son extraíbles ni reemplazables (señal visual al intentar).
2. **Regla de soporte:** bloques constructivos requieren apoyo (debajo sólido o adyacente anclado); bloques de terreno colocables sobre cualquier sólido.
3. **Sin flotación:** decorativos solo sobre sólido (salvo mesas/estanterías que actúan de "superficie de apoyo").
4. **Validación de terreno:** la pala solo extrae bloques de terreno; no altera estructura de ruinas (misma regla de protección).
5. **Árboles:** el hacha quita bloques de tronco respetando "no destruir el árbol" → caída de ramas/leña; el árbol queda tocón (M50).
6. **Límites del mundo:** fuera del radio editable (borde) el mundo es roca madre automática.
7. **Puzzles:** los bloques puzzle extraíbles devuelven su estado a la entidad vinculada (no se pierde el puzzle).

## 5. Malla, luz y rendimiento

- **Face culling:** caras interiores nunca mesheadas (Voxel Tools).
- **Greedy meshing:** ON para bloques regulares del terreno (menos vértices); OFF por tipo si el puzzle necesita individualidad (decisión final en M1 con medición).
- **LOD:** Transvoxel para chunks lejanos; transición suave; el jugador nunca ve pop de bloques al editar área visible.
- **AO:** suave (estética pastel), configurable por bioma.
- **Iluminación:** día global + emisivos (lámparas, glifos, cristal); sin luz por voxel costosa (excepto zonas scripteadas).
- **Transparencia:** meshing aparte para cristal (segundo draw call por chunk como máximo).
- **Agua:** nivel de superficie por chunk (no simulación FEA); flujo simple hacia abajo/laterales; congelación por Varas de Flujo = cambio de tipo de bloque (evento world).
- **Gravedad:** flag por bloque (arena suelta); chequeada al editar vecinos (no simulación continua).

## 6. Streaming y persistencia

- **Carga:** radio 3-4 chunks alrededor del jugador (configurable); prioridad: frente de visión.
- **Descarga:** fuera de radio × 1.5 → flush de diffs a disco → liberar.
- **Diffs:** tabla `(isla, chunk, lista de ediciones)` en la partición `world` de GameState; compresión + guardado periódico (autosave por eventos, M07/M59).
- **Regeneración:** la generación base (M10) es determinista por seed; los diffs se re-aplican → mundo consistente entre sesiones sin guardar el mundo entero.
- **Islas:** cada isla es su propio stream (carpeta/archivo) — aprovecha escenas separadas (M28).

## 7. Interfaz hacia otros sistemas

| Sistema | Contrato |
|---|---|
| M13 Herramientas | API `try_extract(block_pos, tool)`, `try_place(block_pos, type)` → eventos world |
| M24 Puzzles | Entidades puzzle vinculadas a bloque; estado entidad ≠ estado voxel |
| M17 Construcción | Reglas de apoyo y materiales validados en VoxelWorld |
| M59 Guardado | Partición `world` con diffs versionados |
| M61 Rendimiento | Métricas: draw calls/chunk, ms de remesh, radio óptimo |
| M29 Calendar | Nieve estacional: efecto superficial según estación |