**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 01: Visión y Concepto

## 1. Análisis de los 26 puntos de la sección 1 del plan maestro

Estado por punto, con fuente de resolución y dueño del pendiente:

| # | Punto del plan | Estado | Fuente / Resolución |
|---|---|---|---|
| 1 | Nombre definitivo | ✅ | **"Isla Ancestral"** — `HISTORIA-DEL-JUEGO.md`, repo y estructura de carpetas |
| 2 | Título provisional | ✅ | *"Proyecto Isla Ancestral"* — `IDEA-BASE-DEL-JUEGO.md` §1 |
| 3 | Disponibilidad del nombre | ⏳ Pendiente | Verificar en Steam Direct, buscadores y registro de marca (M02/legal) |
| 4 | Género principal | ✅ | **Cozy Voxel / Life Simulation** — GDD §1 |
| 5 | Géneros secundarios | ✅ | **Puzzle Adventure + Exploración** — GDD §1, Biblia §Género |
| 6 | Público objetivo | ✅ | Jugadores cozy 16-35, perfil definido en §2 (este archivo) |
| 7 | Edad recomendada | ✅ | **E+10 (ESRB) / PEGI 7** — ausencia total de violencia; misterio no gráfico |
| 8 | Plataformas objetivo | ✅ | **PC (Steam) primera; Steam Deck verificado; consolas a evaluar post-v1.0** |
| 9 | Perspectiva de cámara | ✅ | 3ª persona cenital inclinada, control libre (GDD §1) |
| 10 | Estilo visual | ✅ | **"Cozy Voxel"**: terreno de bloques + props/personajes redondeados pastel (GDD §3A, §4) |
| 11 | Tono general | ✅ | Misterioso, cálido, contemplativo, aventurero, esperanzador (Biblia §Género) |
| 12 | Duración estimada | ✅ | v1.0: 30-50 h principales; comunidad completa 70+ h; contenido post vía roadmap |
| 13 | Filosofía del juego | ✅ | Cero combate/muerte/penalización; herramientas sin daño (GDD §1, §5 directiva 2) |
| 14 | Características diferenciadoras | ✅ | §3 (este archivo) |
| 15 | Propuesta de valor | ✅ | §4 (este archivo) |
| 16 | Elevator pitch | ✅ | `03-Diseno.md` §2 |
| 17 | Descripción de una frase | ✅ | `03-Diseno.md` §3 |
| 18 | Descripción de una página | ✅ | `03-Diseno.md` §4 |
| 19 | Pilares de diseño | ✅ | `03-Diseno.md` §5 (4 pilares) |
| 20 | Pilares narrativos | ✅ | `03-Diseno.md` §6 (3 pilares) |
| 21 | Pilares visuales | ✅ | `03-Diseno.md` §7 |
| 22 | Pilares sonoros | ✅ | `03-Diseno.md` §8 |
| 23 | Principios de accesibilidad | ✅ | `03-Diseno.md` §9 |
| 24 | Principios de rendimiento | ✅ | `03-Diseno.md` §10 + GDD §5 |
| 25 | Alcance del proyecto | ✅ | v1.0 definida: `Plan-de-produccion.md` §1 (punto 78-86) |
| 26 | Fuera de alcance inicial | ✅ | §11 (este archivo) + roadmap |

## 2. Análisis del público objetivo

**Perfil primario (comprador):** 16-35 años, jugadores de simulación y confort ("cozy gamer"), valoran relajación, ritmo propio y mundos acogedores. Referencias: Stardew Valley, Animal Crossing, Dinkum, A Short Hike; Monster Hunter Stories inspira la "aventura por capítulos" (investigación `INVESTIGACION SOBRE OTROS JUEGOS/`).

**Perfil secundario:** jugadores de aventura/puzzle que buscan progresión de misterio sin combate (Zelda-like sin lucha); jugadores de Minecraft/Voxel que buscan construcción con significado narrativo.

**Región inicial:** Steam global con texto en español/inglés (español como idioma de autor, inglés para mercado primario).

**Evitar:** mecánicas de castigo, FOMO, contenidos competitivos o de tiempo límite real.

## 3. Decisión de nombre

- **Candidato:** "Isla Ancestral" — describe el hook narrativo (una isla con civilización dormida debajo), funciona en español y mantiene el misterio sin spoilear la Resonancia.
- Alternativa descartada: "Aurora" (nombre de la isla del GDD; se conserva como nombre del lugar, no del juego).
- Riesgo: colisión con marcas/juegos existentes → **verificación pendiente** (Steam, web, registro) en M02.
- El repositorio y la biblia ya usan "Isla Ancestral" → adoptado por unanimidad.

## 4. Características diferenciadoras (vs. referentes)

| Diferenciador | Detalle | Contra qué compite |
|---|---|---|
| Terreno voxel con memoria | Excavar no es cosmético: **el terreno guarda el pasado** (ruinas, canales, cámaras) y modificar el mundo revela historia | Minecraft (sin narrativa de pasado), Dinkum (grid + props) |
| Cero violencia total | Herramientas con "Eficacia de Recolección / Alcance de Acertijo", nunca daño. Los templos son puzles de lógica y observación 100% | Zelda/BOTW (necesita combate), la mayoría de sandbox |
| Templo = mecánica única | Cada sello/templo agrega herramienta y regla de puzle nueva (varas de flujo, espejos, gancho) | Stardew (sin dungeons temáticos), Portia (mazmorras simples) |
| Expansión por ficción | Las islas mensuales del Gran Vapor son EA/roadmap **dentro de la narrativa**, no cortes de contenido | Casi ningún comparable |
| Economía doble sin castigo | Gemas de Ámbar + Pases de Mérito por tareas diarias positivas; sin deuda punitiva | Animal Crossing (deuda), Stardew (energía limitada) |

## 5. Análisis de alternativas consideradas

- **Combate presente (descartado):** fue la primera tentación por convención del género aventura; contradice la filosofía y el público cozy → rechazado en GDD.
- **Multijugador en v1.0 (descartado):** costo altísimo vs. historia single-player ya diseñada; queda como posible roadmap.
- **Nombre alternativo (descartado):** "Resonancia" como título (spoilea la mecánica); "Aurora" (colisión con otros títulos) → se eligió "Isla Ancestral".
- **Cámara fija (descartado):** el voxel requiere rotación/zoom libre para construcción; cámara cenital inclinada con control libre (GDD).

## 6. Preguntas abiertas (decidir en módulos posteriores)

- Precio y modelo post-lanzamiento (gratuito vs DLC) → decidir cerca del lanzamiento (`Plan-de-produccion.md` §14).
- Nombre del estudio/propietario de la cuenta pública de Steam.
- Idioma primario de Steam (español vs inglés) → pendiente de validación de mercado.
- Venta anticipada (EA) sí/no → depende del roadmap y presupuesto.