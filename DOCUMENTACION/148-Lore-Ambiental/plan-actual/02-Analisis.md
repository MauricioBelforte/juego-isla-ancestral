**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 148: Lore Ambiental

## 1. Análisis del dominio
El lore ambiental se apoya en 2 pilares:

1. **Mundo narrativo** (qué cuentan las piezas): depende de la biblia (M147) y de la arquitectura de contenido (M50/M26/M13). Cada isla tiene su propia cultura constructiva y su historia de abandono.
2. **Canalización** (cómo llega al jugador): mecánicas existentes (diario M55, colecciones M73, pesca M34, minería M35, temples M24) que hoy NO tienen lore. Se agrega una capa de "piezas de lore" reutilizando triggers y UI existentes.

El diseño se divide en:
- **Lore estático** (ruinas, objetos, arquitectura, vegetación, daños, murales, estatuas): se observa/inspecciona in situ.
- **Lore canalizado** (mapas, canciones, rumores, peces, plantas, minerales, terreno): se obtiene mediante sistemas de juego.

## 2. Alternativas consideradas y decisiones

### D1: Arquitectura del contenido de lore
- **A1 (textos hardcodeados en prefabs)**: rápido pero no auditable ni canon-checkeable.
- **A2 (catálogo central `LoreCatalogo` SO/JSON con IDs + referencia en el prefab/trigger)**: única fuente, auditable contra M147, reutilizable por diario/colecciones.
- **Decisión:** **A2** — `LoreCatalogo` central con 4 campos: `id, canonRef, textoLore, tipoPieza, estadoPersistencia`.

### D2: Cómo se entrega la pieza al jugador
- **A1 (ventana modal al inspeccionar)**: interrumpe.
- **A2 (registro en el diario + notificación ligera)**: coherente con M55 y con la regla "sin infodump": el jugador lee cuando quiere.
- **Decisión:** **A2** — inspección → notificación "Nuevo lore en el diario" + entrada completa en el diario (sección Lore Ambiental con contador x/y por isla).

### D3: Cómo se modelan las pistas
- **A1 (pistas genéricas sin vínculo)**: no ayudan a resolver.
- **A2 (red de pistas dirigidas: mural→puzzle, estatua→sello/artefacto, mapa→coleccionable, canción→rumor)**: cada pieza pista apunta a un consumidor concreto y se valida en un "grafo de pistas" (checklist de trazabilidad).
- **Decisión:** **A2** — grafo de pistas trazable (señal→resultado), idealmente 3 pistas por mysterio crítico (resultado alcanzable sin todas).

### D4: Regla anti-infodump
- **A1 (prohibición absoluta de texto en diálogos)**: inviable (la historia necesita apoyarse en H2NPC).
- **A2 (regla proporcional 60/40 lore ambiental vs diálogo explicativo + auditoría de muestreo)**: sostenible y medible.
- **Decisión:** **A2** — 60% de la narrativa del trasfondo viaja en el mundo; los diálogos avanzan la trama pero no explican el mundo.

### D5: Terreno que revela secretos
- **A1 (contenido escondido estático fijo)**: se agota al encontrarlo una vez.
- **A2 (secretos ligados a estaciones/eventos que rotan)**: señal a largo plazo (M74): cada temporada destapa 2-3 ubicaciones.
- **Decisión:** **A2** — 3 ubicaciones por temporada destapan secretos (ruinas, mensajes, objetos) vinculados a M74/M50.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Contradicciones con la biblia | Media | Alta | Catálogo con referencia obligatoria `canonRef` + revisión en pipeline |
| Costo de contenido (texto por pieza) | Alta | Media | Plantillas por tipo de pieza (3-5 líneas), reutilización por isla |
| Frustración: pistas sin resolver | Media | Media | Grafo 3-pistas por misterio; el jugador no depende de una sola |
| Diario saturado | Media | Baja | Sección aparte con contador por isla y filtro de nuevo/no visto |
| Piezas invisibles (jugadores no exploran) | Media | Media | Rumores locativos de NPC (M21) apuntan a zonas de lore |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Catálogo** | `LoreCatalogo` SO/JSON + 72+ piezas (6 islas × 12) con canonRef; validación contra M147 |
| **F2 Inspección** | Trigger interactivo reutilizable + notificación + diario Lore (M55) |
| **F3 Pistas** | Grafo de pistas: 30 piezas pista vinculadas a puzzles/sellos/coleccionables/rumores |
| **F4 Colecciones** | Lore en peces (M34), plantas (M50), minerales (M35) dentro de sus fichas (M73) |
| **F5 Terreno** | 3+ ubicaciones por temporada con secretos (M74/M50) |
| **F6 Persistencia** | Save v3.x: estado de lore explorado + contadores; 30 ciclos de prueba |

## 5. Métricas de éxito
1. Catálogo 100% con canonRef válido (script de auditoría).
2. 6 islas × ≥ 12 piezas (mínimo 72 piezas) en la release.
3. 30 piezas pista trazables en el grafo (sin agujeros).
4. 100% de fichas de colección (peces/plantas/minerales) con lore.
5. Auditoría anti-infodump: 10 zonas muestreadas sin "muro de texto".
6. 3 ubicaciones por temporada destapando secretos.
7. 30 ciclos de carga/guardado sin pérdida de lore.

## 6. Notas para integración
- El LoreCatalogo se integra con M112 (tests: validación de canonRef, trazabilidad de pistas, persistencia).
- Los rumores de NPC (M21) son el puente "descubrimiento": evitan que el lore quede invisible.
- Compatibilidad: no modifica la arquitectura de M55 ni de M73 (solo agrega una sección de datos).