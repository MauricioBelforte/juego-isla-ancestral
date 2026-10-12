# Especificaciones de Producción — Artbook Isla Ancestral

**Módulo:** M130
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Estado:** Definición completa — lista para fase de producción post-RC

---

## A. Fundamentos y Estructura Editorial

### Extensión objetivo total
220 páginas (rango 200-240), un tomo. Distribución:
- Prólogo + carta director: 8 pp
- 12 capítulos: 172 pp
- Créditos + índice + agradecimientos: 16 pp
- Portadillas + guardas: 24 pp

### 12 Capítulos temáticos
| # | Capítulo | Páginas | Piezas mín. |
|---|----------|---------|-------------|
| 1 | El Taller (Proceso, Descartes, Equipo) | 18 | 25 |
| 2 | Arte Conceptual Fundacional | 14 | 12 |
| 3 | Evolución del Mundo | 14 | 10 |
| 4 | Diseño de Aurora | 16 | 10 |
| 5 | Personajes y Vecinos | 18 | 10 |
| 6 | Fauna | 14 | 8 |
| 7 | Ruinas y Templos | 14 | 10 |
| 8 | Herramientas y Vehículos | 14 | 12 |
| 9 | Biomas e Islas | 14 | 12 |
| 10 | Interfaz y Símbolos | 14 | 10 |
| 11 | Storyboards | 14 | 4 (secuencias × 6 viñetas) |
| 12 | Crónica de la Isla (cierre) | 16 | 10 |

### Criterios de curaduría generales
- **Entra:** piezas que documentan una decisión de diseño no obvia, evolución visual, o enseñanza.
- **No entra:** capturas de pantalla sin contexto, assets sin decisión asociada, duplicados sin aprendizaje.
- **Regla 3D:** mínimo 3 piezas que muestren el "por qué" detrás de una decisión.

### Orden temático
Orden temático (no cronológico) con cronología interna por capítulo. Cada capítulo abre con una línea de contexto temporal ("Durante la alpha…").

### Página de título e introducción [?] → resuelto
Cada capítulo incluye:
- **Página de título:** nombre del capítulo + ilustración a sangre (72 pp).
- **Introducción:** ≤80 palabras (aprox. 5-6 líneas) contextualizando el capítulo.
- Plantilla en `game/isla-ancestral/data/legal/artbook/capitulos/capitulo_NN_intro.md`.

### Criterio de apertura de capítulo
Cada capítulo se abre con: (1) pieza ancla (la más evocadora), (2) intro ≤80 palabras, (3) primer body. Nunca una página en blanco.

### Validación de puntos huérfanos
Cada punto del plan maestro (§ #129) mapea a ≥1 pieza del manifiesto. El validador `artbook_validator.gd` chequea `cobertura_plan_maestro` (campo del JSON).

---

## B. Manifiesto y Curaduría

### Campos obligatorios del manifiesto (`artbook_manifest.csv`)
`pieza_id, chapter, tipo, titulo, fuente, estado, nominador, fecha_nom, fecha_apro, nota_dev, palabra_max`

### Sesión mensual de curaduría
- Frecuencia: 1ª semana del mes, ≤60 min.
- Participantes: máximo 3 (1 art + 1 dev + 1 writer).
- Output: decisiones de estado (nominada → seleccionada/descartada).
- Registro: commit al manifiesto + log de sesión en `artbook/curaduria/log`.

### Cuota máxima de piezas por capítulo
Máx. 18 piezas por capítulo. Si un capítulo excede, se prioriza por impacto narrativo y se remueve la de menor decisión asociada.

### Política de piezas duplicadas/variantes
Si 2+ piezas del mismo asset compiten: se elige la que muestre MÁS decisión de diseño. La otra se archiva en `artbook/descartes/` con ficha de descarte.

---

## C. Fichas Estándar

### Plantilla de ficha de pieza (D3)
```
## {pieza_id} — {titulo}
**Capítulo:** {chapter}
**Tipo:** {concept/evolucion/storyboard/prototipo}
**Fuente:** {git ref / capture ref}
**Descripción:** {2-3 líneas}
**Decisión asociada:** {qué decisión muestra}
**Comentario dev (≤40 palabras):** "{comentario}"
**Firma:** {nombre} — {rol}
```

### Plantilla de comentario de desarrollador (D4)
Formato: 1-2 frases, tono cálido y honesto. Máx. 40 palabras. Debe explicar el "por qué" no el "qué".
Ejemplo: "Probamos voxel a 4/8/16 y elegimos 8: 4 perdía el relieve de las dunas, 16 se sentía pixel-art. 8 era el punto donde la isla respiraba."

### Límite de 40 palabras
El validador chequea `palabra_max` en el manifiesto. Si un comentario excede 40 palabras, el test falla.

### Regla de firma
Todo comentario lleva `{nombre} — {rol}` al pie. Rol ∈ {art, dev, writer, design, audio}.

### Tono cálido y honesto
- Se permite: "Este no nos salió bien, pero aprendimos que…"
- No se permite: "Esto era genial desde el principio."
- Ejemplos:
  1. "El faro era demasiado alto. Lo achicamos 3 veces hasta que el pueblo se sintió a escala."
  2. "El primer vapor era un barco de carga. Lo rediseñamos como un hotel flotante cuando Elysia llegó."
  3. "La primera versión de Finneas era un blob. Le pusimos orejas y todo cambió."

### 3 ejemplos de ficha, comentario, descarte
Véanse en `game/isla-ancestral/data/legal/artbook/ejemplos/`:
- `ejemplo_ficha_pieza.md`
- `ejemplo_comentario_dev.md`
- `ejemplo_ficha_descarte.md`

---

## D–M. Capítulos (especificaciones por capítulo)

### Capítulo 2 — mínimo 12 piezas + comparativa estilos descartados
Comparativa: 1 página con 3 paneles (realista/low-poly liso/cozy voxel final) + nota de 2 líneas por panel.

### Capítulo 3 — hitos de línea de tiempo
| Hito | Descripción | Piezas |
|------|-------------|--------|
| Prototipo | 2024-Q3: isla de prueba voxel | 3 |
| Vertical slice | 2025-Q1: primer puerto + 1 NPC | 4 |
| Pre-alpha | 2025-Q2: biomas + herramientas T1 | 4 |
| Alpha | 2025-Q4: 5 biomas + fauna + clima | 4 |
| Beta | 2026-Q1: 13 regiones + Sellos | 5 |
| RC | 2026-Q2: pulido + storyboards | 4 |

Comparativas "misma vista en cada hito": 6 vistas × 6 hitos = 36 paneles en 4 páginas.

Incluir capturas del prototipo original aunque sean feas (honestidad editorial).

### Capítulo 4 — comparativas deteriorado → restaurado + cortes transversales
2 panorámicas de la isla (deteriorada al inicio, restaurada al final) en página doble. 2 cortes transversales del terreno voxel mostrando la estructura interna (4-5 capas).

### Capítulo 5 — variantes de vestimenta (M155)
Tabla de 10 personajes × 3 variantes de vestimenta (estación: primavera/verano/lluvia). 30 miniaturas en 4 páginas.

Mínimo 10 personajes con hoja completa: 10 turnarounds × 4 vistas = 40 paneles en 6 pp.

### Capítulo 6 — fauna acuática y aérea
4 especies acuáticas (bancos, criatura luminosa, tortuga, arrastracielos) + 4 aéreas (gaviota, murciélago, búho, colibrí ancestral). 8 hojas completas.

### Capítulo 10 — wireframes tempranos + Sellos
6 wireframes de pantallas clave (menú, HUD, inventario, mapa, diálogo, config) en 2 pp. 6 símbolos de Sellos con significado + 2 pp.

### Capítulo 11 — mínimo 4 secuencias con 6+ viñetas
Faro, Gran Vapor, Corazón del Mundo, Elysia/Jardín Final. Cada una: 6-8 viñetas + banda de advertencia de spoilers.

---

## O. Especificaciones Técnicas

| Parámetro | Valor |
|-----------|-------|
| Tamaño de página | 240 × 300 mm horizontal |
| Resolución mínima print | 300 DPI |
| Perfil digital | sRGB IEC61966-2.1 |
| Perfil print | CMYK ISO 15930-2 (GRACoL para POD) |
| Sangrado | 3 mm por lado |
| Tipografía (títulos) | Fredoka One (Regular/Medium) |
| Tipografía (body) | Nunito (Regular/Medium/Semibold) |
| Peso PDF digital | ≤150 MB (web) |
| Peso PDF print | ≤500 MB (offset) |
| DPI efectivo mínimo | 150 DPI a tamaño final (300 ideal) |
| Densidad piezas/página | Máx. 6 paneles por página |
| Nomenclatura archivos | `M130_{capitulo}_{pieza}_{tipo}_{version}.png` (M149) |
| Snapshots mensuales | `artbook/snapshots/YYYY-MM/` + `changelog.md` |
| Tags Git | `artbook-pdf-v{major}.{minor}` para PDFs finales |
| Exportar PDF digital | RGB, 150 MB máx, embed fonts |
| Exportar PDF print | CMYK, bleed 3mm, 500 MB máx, POD M129 compatible |
| Prueba física | 1 copia impresa por M129 + verificación de color |

---

## P. Legal y Trazabilidad

### Registro de autoría
Cada pieza lleva `autor` en el manifiesto. Cross-check con M78 (créditos) y M132 (registros). El validador verifica que `autor` no sea "desconocido" en piezas `seleccionadas`.

---

## Q. Integración y Cierre

### Tirada limitada numerada
Coordina con M129: 500 copias numeradas + cert digital de autenticidad.

### Extractos sin spoilers para M99
Selección de 10 piezas (1 por capítulo × 10) + intro de cada capítulo = "teaser" para la store page.

### Criterio volumen 2 post-DLC
Se abre volumen 2 si: (a) DLC añade ≥30 piezas nuevas, (b) la producción del DLC genera documentación de proceso. Criterio decisorio: M120 evalúa en cierre de DLC.

### Verificación cobertura 100%
El validador `artbook_validator.gd` chequee `plan_maestro_cobertura` = 100% antes de cierre.

---

## Estructura de carpetas (D8)

```
game/isla-ancestral/data/legal/artbook/
├── capitulos/
│   ├── capitulo_01_intro.md
│   ├── capitulo_02_intro.md
│   └── ...
├── ejemplos/
│   ├── ejemplo_ficha_pieza.md
│   ├── ejemplo_comentario_dev.md
│   └── ejemplo_ficha_descarte.md
├── curaduria/
│   └── log/
├── descartes/
├── candidatos/
└── snapshots/
```
