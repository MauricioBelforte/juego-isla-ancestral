**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 147: World Building

## 1. Análisis del Dominio

### 1.1 Capas de la historia (modelo de "cebolla narrativa")

El mundo se estructura en capas concéntricas de conocimiento, de lo más público a lo más secreto:

```
CAPA 0 — Vida cotidiana (siempre visible): costumbres, festivales, economía actual, NPC.
CAPA 1 — Historia pública: leyendas, cuentos, historias de islas.
CAPA 2 — Historia documental: ruinas, murales, mapas antiguos (M25, M148).
CAPA 3 — Historia reconstruida: quien investiga (museo M37, diario M55) arma el canon.
CAPA 4 — Verdad central: Resonancia, Elysia, fin de los Arquitectos (M153, Sellos).
```

Cada capa es accesible por una cantidad creciente de trabajo de juego (M71) pero NUNCA bloqueada permanentemente. El jugador puede llegar a la capa 4 con el contenido curado (bloques de Sello), sin grind (M93, M152).

### 1.2 Historias que ya existen (del GDD/biblia del usuario)

- **Aurora:** la isla principal; conectada a algo más grande (creación, misterio).
- **Arquitectos del Alba:** constructores de los templos/tecnología antigua.
- **Primeros Jardineros:** civilización ligada a la naturaleza/agricultura; la voz del mundo.
- **La Resonancia:** fenómeno que conecta tierra/agua/cielo; vinculada a las herramientas únicas (M13/M26) y a los Sellos.
- **Elysia:** lugar/estado misterioso; meta del arco largo (post-final "Era del Alba").
- **Gran Vapor:** transporte mensual que conecta islas; mecanismo narrativo de expansión (M28, roadmap M136).
- **4 finales + Era del Alba:** rutas narrativas divergentes dedicadas al jugador (M22/23).

### 1.3 Diseño de civilizaciones (lecciones aplicables)

| Aspecto | Arquitectos del Alba | Primeros Jardineros |
|---|---|---|
| Rol | Construcción, templos, tecnología, Sellos | Naturaleza, cultivos, semillas, curación |
| Legado visible | Templos (M24/26), drones, relojes solares | Jardines salvajes, frutas, rituales de siembra |
| Legado oculto | Resonancia, sellos, Elysia | El "idioma" del viento/plantas (lore M148) |
| Relación | Elaboraron los Sellos | Protegieron la semilla del mundo |
| Caída | Catástrofe (la Gran Quietud) | Absorbidos por la caída; no murieron: se "dispersaron" |

Regla de diseño: **cada civilización deja 1 sistema jugable, 1 misterio y 1 símbolo** (evita lore muerto e inflación narrativa).

### 1.4 Riesgos del World Building mal gestionado

| Riesgo | Ejemplo | Mitigación |
|---|---|---|
| Contradicciones | Fecha de fundación distinta en 2 documentos | Validador de fechas/ids (`validate_world.gd`) + canon único |
| Lore muerto | 20 páginas que ningún módulo usa | Trazabilidad: cada bloque declara qué módulo lo consume (RF26) |
| Spoilers tempranos | Un mural en el tutorial revela Elysia | Capas de revelación controladas por progresión (M71/M153) |
| Exposición excesiva | Diálogos que explican todo (M148 lo prohíbe) | Regla de misterio: 30% máximo de explicación por diálogo |
| Deriva de canon | Cambios que rompen lo ya publicado | CHANGELOG + revisión por M152/M153 |
| Inconsistencia con IA generativa (M86) | Textos generados que contradicen | M86 consume los JSON de world_data como contexto forzado |

## 2. Alternativas Consideradas

### 2.1 Formato de la biblia: Markdown solo vs. Markdown + JSON
| Criterio | Solo Markdown | Markdown (copia editorial) + JSON (datos) |
|---|---|---|
| Legible por humanos | Excelente | Excelente |
| Consumible por scripts | No | Sí (diálogos M21, ruinas M25, i18n M87) |
| Validable | No | Sí (ids, fechas, referencias) |
| Mantiene canon | Difícil | El JSON es la fuente técnica; el MD la fuente editorial |
| **Decisión** | | **Dual**: la biblia editorial en `world_bible/*.md` Y los datos técnicos en `world_data.json` generado desde los MD (script de sync que falla si hay inconsistencias) |

### 2.2 Sincronización: manual vs. script
Se elige script (`sync_world_data.gd` / `.py`): extrae secciones marcadas `DATA:` de los MD y genera el JSON; el validador comprueba que ambos estén en sincronía (el MD y el JSON nunca divergen).

### 2.3 Nivel de detalle por NPC
Se define la regla del "1-5-25": 1 párrafo de canon para personajes de fondo, 5 para secundarios con misión, 25 para los principales (Finneas/Lía/Bruno/Nilo/Vera). Aurora (la isla) tiene documento completo (RF2).

### 2.4 Misterio: revelación por bloques (M153)
En lugar de infodumps, cada Sello desbloquea exactamente 1 documento de la capa siguiente (bisagras de la historia de Elysia). Se alinea con el contrato de visión O1-O19 (M153): ritmo de revelación accesible, sin metagaming forzado.

## 3. Decisiones Tomadas

1. **Biblia dual:** `world_bible/*.md` (editorial) + `world_data.json` (técnico) sincronizados por script.
2. **Canon único y trazable:** cada bloque declara `consumido_por: [M21, M25, ...]`.
3. **Capas de revelación** alineadas con Sellos (M153), sin spoilers por módulo.
4. **Regla 1-5-25** para detalle de personajes.
5. **Regla de civilización:** 1 sistema + 1 misterio + 1 símbolo por civilización.
6. **Regla de misterio:** ninguna pieza de contenido explica más del 30% del canon en una sola entrega (diálogo/mural/ruina).
7. **Fechas canónicas:** calendario antiguo (nombre propio) + equivalencia con el calendario actual del juego (M29).
8. **Sin lore contradictorio con el gameplay:** si una leyenda dice que el mar no retiene secretos, la pesca (M34) no debe encontrar nada "prohibido" sin justificación.
9. **ia/npc (M64):** los NPC conocen solo las capas que su historia exige; un aldeano no sabe de Elysia (evita exposición).
10. **Localización (M87):** los ids i18n del canon (nombres propios NO se traducen; descripciones sí).

## 4. Integración con Otros Módulos

| Módulo | Qué consume de World Building | Qué aporta |
|---|---|---|
| M21 Diálogos | `world_data.json` (personajes, lugares) | Texto final del canon |
| M25 Ruinas / M24 Templos | Símbolos, arquitectura, catástrofes | Espacios jugables del canon |
| M26 Templo Subterráneo | Historia de los Arquitectos | La herramienta única |
| M27 Islas | Historias de isla | Geolocalización del lore |
| M73 Coleccionables | Mapas antiguos, sellos, documentos | ítems de colección con texto canónico |
| M148 Lore Ambiental | Símbolos, leyendas, catástrofes | Texturas/murales coherentes |
| M150 Sonoro Narrativo | Símbolos, civilizaciones | Sonidos distintivos coherentes |
| M153 Objetivo Final | Capas de revelación, Elysia | Contrato O1-O19 |
| M86 IA Generativa | `world_data.json` como contexto | Textos generados sin contradicción |
| M152 Principios | Revisión de canon | Filtro de diseño final |

## 5. Edge Cases Identificados

1. **Jugador no lector:** el canon debe sobrevivir con 90% de lore ambiental (M148) y 10% de texto.
2. **Jugador min-max:** si ordena los Sellos de distinta forma, la historia no se contradice (capas independientes por Sello).
3. **Traducciones:** los nombres propios (Aurora, Elysia, Finneas) no se traducen; los textos sí (M87).
4. **Contenido IA (M86):** las variaciones procedurales solo pueden tocar capas 0-2; la capa 4 es siempre curada.
5. **Reescritura de canon post-exposición:** si el usuario cambia un nombre (M149), el validador detecta referencias rotas.