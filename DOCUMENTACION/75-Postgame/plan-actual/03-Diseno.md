**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 75: Postgame

## 1. VisiÃ³n General

El postgame es el **orquestador del contenido despuÃ©s de la historia**: define quÃ© hay, cuÃ¡ndo se desbloquea, y cÃ³mo el jugador lo persigue (hoja de ruta del 100%). No implementa componentes nuevos â€” usa los de los mÃ³dulos existentes (M22, M73, M37, M55, M72, M74, M16, M17, M25, M24, M19, M50, M36, M18). Entrega: `postgame_catalog.tres` (catÃ¡logo de expansiones) + `postgame_manager.gd` (desbloqueo y direcciÃ³n) + `validate_postgame.gd` (integridad). SubstituciÃ³n indeterminada: `postgame_unlocked` viaja en el save (M59).

## 2. Arquitectura

```
M22 (Historia) â”€â”€"final alcanzado"â”€â”€â–¶ PostgameManager (M75)
                                          â”‚
                    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                    â–¼                     â–¼                       â–¼
              Hoja de ruta           CatÃ¡logo                Logros finales
            (diario M55)        (postgame_catalog.tres)      (M72, cat. EpÃ­logo)
              â”‚ 100%                    â”‚ FASE 1/FASE 2            â”‚
              â–¼                         â–¼                          â–¼
        M73/M37 (colecciones)     M27/M51/M10/M16/M17     events: M74 (rotativos)
        M25/M24 (ruinas/puzzles)  (cada uno su mÃ³dulo)
```

### 2.1 Servicios y responsabilidades (modularidad M09)

| Componente | Responsabilidad | Dependencias |
|---|---|---|
| `postgame_manager.gd` | Estado `postgame_unlocked`, hoja de ruta, direcciÃ³n "Â¿quÃ© sigue?" | M22 (final), M59 (save), M92 (tutorial) |
| `postgame_catalog.tres` | CatÃ¡logo declarativo de expansiones (FASE 1/FASE 2) | M27, M51, M10, M16, M17, M19, M18, M50, M36, M25, M24, M23, M73 |
| `validate_postgame.gd` | Integridad del catÃ¡logo y la hoja de ruta | Editor |

**No hay MonoBehaviour de UI en el core:** la hoja de ruta se renderiza en el diario (M55) y el museo (M37) llamando funciones expuestas del manager (regla M09).

### 2.2 Estados

```
LOCKED â”€â”€(M22: final alcanzado)â”€â”€â–¶ UNLOCKED
UNLOCKED â”€â”€â–¶ RUTA_100 (hoja de ruta activa, diario M55)
UNLOCKED â”€â”€â–¶ EXPANSION_FASE2 (catÃ¡logo interno, diseÃ±ador)
```

- `LOCKED`: el postgame no existe antes del final (sin spoilers).
- `UNLOCKED`: epÃ­logo + hoja de ruta + logros de la categorÃ­a EpÃ­logo.
- FASE 2: nunca visible al jugador; solo catÃ¡logo interno.

### 2.3 Flujos principales

**Flujo A â€” Desbloqueo del postgame:** `M22.historia_terminada()` â†’ PostgameManager.`unlock_postgame()` â†’ guarda `postgame_unlocked=true` (M59) â†’ M92 muestra "Â¿QuÃ© sigue?" â†’ M44 celebra â†’ diario M55 activa la pestaÃ±a "Isla al 100%".

**Flujo B â€” Hoja de ruta del 100%:** cliente â†’ `PostgameManager.get_roadmap()` â†’ consulta a cada sistema (M73 catÃ¡logo, M37 museo, M25 ruinas, M24 puzzles, M16 recetas, M17 mejoras, M74 eventos) â†’ devuelve % por categorÃ­a anti-spoiler â†’ UI del diario (M55) muestra metas.

**Flujo C â€” Evento postgame:** calendario (M29) â†’ M74 programa festival â†’ PostgameManager marca `festival_unlocked` para itinerancia â†’ recompensa Ãºnica (M38/M20) â†’ logro (M72).

**Flujo D â€” ExpansiÃ³n (FASE 2):** diseÃ±ador agrega entrada en `postgame_catalog.tres` (`fase: 2`) â†’ `validate_postgame.gd` verifica mÃ³dulo existente â†’ la entrada queda interna hasta su lanzamiento (flag `hidden`).

## 3. Estructura de Datos

### 3.1 `postgame_catalog.tres` â€” CatÃ¡logo de expansiones (Resource)

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
nombre = "JardÃ­n AcuÃ¡tico"
fase = 2
requisito = "herramienta_jardin_acuatico"
modulo = "M16"
hidden = true
```

### 3.2 Hoja de ruta del 100% (derivada, sin duplicaciÃ³n)

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

| ValidaciÃ³n | CondiciÃ³n |
|---|---|
| Expansiones | `id` Ãºnicos, `fase` âˆˆ {1,2}, `modulo` existente en CHECKLIST |
| Logros EpÃ­logo | Referencian hitos reales (M72) |
| Hoja de ruta | Cada fuente responde `total_conocido`/`completado` |
| Eventos postgame | Fechas del calendario (M29) sin colisiÃ³n |

## 4. Persistencia (M59)

- `postgame_unlocked: bool` â€” slot `save_global.tres` v1.4 (viaja con el mundo).
- La hoja de ruta NO se guarda: se deriva de cada sistema (cero duplicaciÃ³n de estado).
- CatÃ¡logo: Resource embebido (constante), no serializado.

## 5. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | Rol en el postgame |
|---|---|
| M22 | Final de la historia â†’ desbloqueo; epÃ­logo |
| M92 | "Â¿QuÃ© sigue?" tras los crÃ©ditos |
| M73/M37 | El 100% de colecciones (museo completa la ruta) |
| M55 | PestaÃ±a "Isla al 100%" (anti-spoiler) |
| M72 | Logros finales (categorÃ­a EpÃ­logo) |
| M74 | Eventos rotativos postgame (calendario M29) |
| M27/M51/M10 | Expansiones de mundo (FASE 2) |
| M19/M18/M50/M36 | Vida nueva postgame (vecinos, muebles, plantas, animales) |
| M25/M24 | Ruina final y puzzles (100%) |
| M16/M17 | Herramienta/mejora postgame (fase 2) |
| M59/M60 | Persistencia y migraciÃ³n |
| M61 | Streaming/LOD de las expansiones de mundo |

## 6. Impacto en Rendimiento (M61)

- La hoja de ruta consulta sistemas existentes **bajo demanda** (al abrir la pestaÃ±a), no por frame.
- CatÃ¡logo estÃ¡tico: sin consultas por frame.
- Expansiones FASE 2 con streaming (M10/M51) respetan LOD y `chunk_target` (M61): cero carga sÃ­ncrona.
- Durmientes cooperativos (M49) para habitantes y eventos postgame â€” sin NPCs siempre activos.
## Diseno en papel postgame (P-100 M75 batch)

### Tono cozy en el cierre (M21/M44)
- El cierre del juego mantiene el tono cozy: sin pantalla de Fin fria.
- Transicion suave al epilogo con musica tranquila y mensaje de agradecimiento.

### Puzzle opcional (M22)
- El puzzle de la ruina es opcional: nunca bloquea la historia principal.
- Se puede completar en cualquier momento post-historia.

### Herramientas sin durabilidad (cozy)
- Las herramientas del postgame no tienen combustible ni durabilidad.
- Coherente con el principio cozy: sin presion de recursos.
## Validacion y expansion (P-100 M75 batch 2)

### Validacion de muebles con ids univocos
- Cada mueble tiene id univoco para persistencia y referencias.
- Idempotencia: sin duplicacion de registro (M73).

### Plantas sin promesa de fase 2
- Las plantas del postgame no prometen contenido de fase 2 sin arquitectura.
- Coherente con M147 (canon).

### Ruina aporta al 100%
- La ruina contribuye a la hoja de ruta del 100% (M72).
- Puzzle opcional vinculado a logros.
## Metodos y validacion (P-100 M75 batch 3)

### Casa con expansion visible al vecindario (M19)
- La casa muestra expansiones al vecindario (visual feedback).

### Validar mejoras con M60 (migracion)
- Las mejoras de postgame se migran correctamente con M60.

### Historias sin exigencia multijugador
- El postgame no requiere multijugador.

### Conflictos resueltos sin romper eventos (M74/M29)
- Los conflictos de eventos se resuelven sin romper otros eventos.
## Specs Postgame (Beam 483)

### Epílogo de la historia
- Spec: epílogo tras los créditos que cierra la historia principal (M22). Coherente con M21 (historia) y M92 (¿qué sigue?).

### ¿Qué sigue? tras los créditos
- Spec: pantalla "¿Qué sigue?" (M92) que lista contenido postgame disponible. Coherente con M92 (postgame) y M75 (postgame).

### Catalogar isla del Este (FASE 1)
- Spec: diseño completo de la isla del Este (FASE 1, M27): biomas, flora/fauna, POI, música. Coherente con M26 (islas) y M27 (viajes).

### Catalogar isla flotante (FASE 2)
- Spec: diseño de la isla flotante (FASE 2, M10): biomas, flora/fauna, POI, música. Coherente con M26 (islas) y M10 (personaje).

### Verificar streaming/LOD de nuevas islas
- Spec: streaming/LOD (M61) para las nuevas islas (Este, flotante). Presupuesto de rendimiento. Coherente con M61 (rendimiento) y M63 (streaming).
### Vecinos postgame (M19)
- Spec: 1-2 vecinos nuevos postgame (M19) con personalidades propias, rutinas y diálogos. Coherente con M18 (NPC) y M19 (amistad).

### Rutinas de vecinos postgame
- Spec: rutinas propias de los vecinos nuevos (horarios, movimientos). Coherente con M18 (NPC) y M31 (ciclo).

### Diálogos postgame (M21)
- Spec: diálogos de vecinos postgame (M21) que reflejan el nuevo estado del mundo. Coherente con M20 (diálogos) y M22 (historia).

### Catálogo de muebles postgame (M18)
- Spec: catálogo de muebles postgame (M18) con recetas integradas (M16). Coherente con M16 (construcción) y M18 (NPC).

### Muebles únicos de eventos postgame
- Spec: muebles únicos desbloqueados por eventos postgame. Coherente con M18 (NPC) y M29 (tiempo).
### Recetas de muebles integradas (M16)
- Spec: recetas de muebles postgame integradas en M16 (crafting). Coherente con M16 (construcción) y M18 (NPC).

### Especies estacionales postgame (M50/M33)
- Spec: especies estacionales postgame (M50/M33) con aparición por clima/estación. Coherente con M33 (fauna) y M29 (tiempo).

### Plantas raras postgame
- Spec: plantas raras que solo aparecen después del final (postgame). Coherente con M15 (recursos) y M29 (tiempo).

### Validar temporadas con calendario (M29)
- Spec: validación de temporadas postgame con el calendario (M29). Coherente con M29 (tiempo) y M33 (fauna).

### Especies raras solo postgame (M36)
- Spec: especies raras que solo aparecen en postgame (M36). Coherente con M36 (fauna) y M29 (tiempo).
### Animales libres con ritmos propios (M35)
- Spec: animales libres con ritmos propios (M35) en postgame. Coherente con M35 (fauna) y M29 (tiempo).

### Avistamientos en diario (M55)
- Spec: avistamientos de fauna postgame registrados en el diario (M55). Coherente con M55 (diario) y M35 (fauna).

### Validar aparición por clima (M28)
- Spec: validación de aparición de fauna postgame por clima (M28). Coherente con M28 (clima) y M35 (fauna).

### Puzzle del Sello oculto (FASE 2, M24)
- Spec: puzzle del Sello oculto (FASE 2, M24) en postgame. Coherente con M24 (ruinas) y M23 (templos).
### Recompensa del puzzle sin spoilers
- Spec: recompensa del puzzle (M24) sin spoilers — el jugador descubre la recompensa al resolver. Coherente con M24 (ruinas) y M23 (templos).

### Puzzle rejugable sin repetir
- Spec: puzzle rejugable sin repetir (M24) — variaciones por seed/calendario. Coherente con M24 (ruinas) y M29 (tiempo).

### Validar solución única del puzzle
- Spec: validación de solución única del puzzle (M24) — no hay múltiples soluciones válidas. Coherente con M24 (ruinas) y M23 (templos).

### Categorías postgame en catálogo (M73)
- Spec: categorías postgame en el catálogo (M73) — documentos y coleccionables postgame. Coherente con M73 (catálogo) y M75 (postgame).

### Documentos finales de la historia (M73)
- Spec: documentos finales de la historia (M73) — coleccionables que cierran la narrativa. Coherente con M73 (catálogo) y M22 (historia).
## Specs Postgame (Beam 521)

### Isla flotante (FASE 2, M10)
- Spec: isla flotante (FASE 2, M10). Coherente con M75 (postgame) y M10 (personaje).

### LOD del terreno flotante (M61)
- Spec: LOD del terreno flotante (M61). Coherente con M75 (postgame) y M61 (rendimiento).

### Probar con profiler: hoja de ruta bajo demanda (M61/M116)
- Spec: probar con profiler: hoja de ruta bajo demanda (M61/M116). Coherente con M75 (postgame) y M116 (profiling).
## Specs Postgame (Beam 529)

### Colecciones postgame con totales reales
- Spec: colecciones postgame con totales reales. Coherente con M75 (postgame) y M73 (colección).

### Compleción de colección = donación al museo (M37)
- Spec: compleción de colección = donación al museo (M37). Coherente con M75 (postgame) y M37 (museo).

### Herramienta de jardín acuático (FASE 2, M16)
- Spec: herramienta de jardín acuático (FASE 2, M16). Coherente con M75 (postgame) y M16 (construcción).

### Mejora de herramienta postgame (M17)
- Spec: mejora de herramienta postgame (M17). Coherente con M75 (postgame) y M17 (casas).

### Herramienta con animación propia (M13)
- Spec: herramienta con animación propia (M13). Coherente con M75 (postgame) y M47 (animación).
## Specs Postgame (Beam 530)

### Validar receta de la herramienta postgame
- Spec: validar receta de la herramienta postgame. Coherente con M75 (postgame) y M16 (crafting).

### Mejora del ático postgame (M17)
- Spec: mejora del ático postgame (M17). Coherente con M75 (postgame) y M17 (casas).

### Mejora con material raro postgame
- Spec: mejora con material raro postgame. Coherente con M75 (postgame) y M14 (recursos).

### Cadenas secundarias postgame (M23)
- Spec: cadenas secundarias postgame (M23). Coherente con M75 (postgame) y M23 (templos).

### Historias que cierran arcos de vecinos (M19/M21)
- Spec: historias que cierran arcos de vecinos (M19/M21). Coherente con M75 (postgame) y M21 (historia).
## Specs Postgame (Beam 531)

### Diálogos postgame con doblaje (M93)
- Spec: diálogos postgame con doblaje si aplica (M93). Coherente con M75 (postgame) y M93 (retención).

### Festivales rotativos postgame (M74)
- Spec: festivales rotativos postgame (M74). Coherente con M75 (postgame) y M74 (eventos).

### Programación en calendario (M29)
- Spec: programación en calendario (M29). Coherente con M75 (postgame) y M29 (tiempo).

### Ciclo anual cozy sin fechas únicas
- Spec: ciclo anual cozy sin fechas únicas. Coherente con M75 (postgame) y M29 (tiempo).

### Recompensas únicas de festival (M38/M20)
- Spec: recompensas únicas de festival (M38/M20). Coherente con M75 (postgame) y M38 (eventos).
## Specs Postgame (Beam 532)

### Logros de eventos postgame (M72)
- Spec: logros de eventos postgame (M72). Coherente con M75 (postgame) y M72 (logros).

### Secretos desbloqueables solo postgame (M71)
- Spec: secretos desbloqueables solo postgame (M71). Coherente con M75 (postgame) y M71 (progresión).

### Secretos anti-spoiler en el diario (M55)
- Spec: secretos anti-spoiler en el diario (M55). Coherente con M75 (postgame) y M55 (diario).

### Secretos con pistas de exploración natural
- Spec: secretos con pistas de exploración natural. Coherente con M75 (postgame) y M27 (islas).
## Specs Postgame (Beam 533)

### Sin secuencias bloqueantes en secretos
- Spec: sin secuencias bloqueantes en secretos. Coherente con M75 (postgame) y M71 (progresión).

### Validar secretos con ids únicos
- Spec: validar secretos con ids únicos. Coherente con M75 (postgame) y M71 (progresión).

### Arrecife profundo (FASE 2, M51)
- Spec: arrecife profundo (FASE 2, M51). Coherente con M75 (postgame) y M51 (agua).

### Acceso con submarino (M67)
- Spec: acceso con submarino (M67). Coherente con M75 (postgame) y M67 (vehículos).

### Streaming del arrecife (M61/M10)
- Spec: streaming del arrecife (M61/M10). Coherente con M75 (postgame) y M61 (rendimiento).
## Specs Postgame (Beam 534)

### Fauna submarina propia (M36/M51)
- Spec: fauna/submarina propia (M36/M51). Coherente con M75 (postgame) y M36 (fauna).

### Sin buceo frustrante (oxígeno generoso, cozy)
- Spec: sin buceo frustrante (oxígeno generoso, cozy). Coherente con M75 (postgame) y M67 (vehículos).

### Isla flotante (FASE 2, M10)
- Spec: isla flotante (FASE 2, M10). Coherente con M75 (postgame) y M10 (personaje).

### Acceso con dirigible (M67)
- Spec: acceso con dirigible (M67). Coherente con M75 (postgame) y M67 (vehículos).

### Gravedad carismática sin romper mecánicas
- Spec: gravedad carismática sin romper mecánicas. Coherente con M75 (postgame) y M67 (vehículos).
## Specs Postgame (Beam 535)

### LOD del terreno flotante (M61)
- Spec: LOD del terreno flotante (M61). Coherente con M75 (postgame) y M61 (rendimiento).

### Sin caídas frustrantes (muerte suave, retorno)
- Spec: sin caídas frustrantes (muerte suave, retorno). Coherente con M75 (postgame) y M10 (personaje).

### Jardín acuático (FASE 2, M16)
- Spec: jardín acuático (FASE 2, M16). Coherente con M75 (postgame) y M16 (construcción).

### Criadero de peces (FASE 2, M34)
- Spec: criadero de peces (FASE 2, M34). Coherente con M75 (postgame) y M34 (pesca).

### Hoja de ruta "Isla al 100%" en el diario (M55)
- Spec: hoja de ruta "Isla al 100%" en el diario (M55). Coherente con M75 (postgame) y M55 (diario).
## Specs Postgame (Beam 536)

### % por categoría derivado (no almacenado)
- Spec: % por categoría derivado (no almacenado). Coherente con M75 (postgame) y M55 (diario).

### Anti-spoiler: solo se ve lo descubierto (M55)
- Spec: anti-spoiler: solo se ve lo descubierto (M55). Coherente con M75 (postgame) y M55 (diario).

### Museo (M37) aporta su % al total
- Spec: museo (M37) aporta su % al total. Coherente con M75 (postgame) y M37 (museo).

### Sin grindeo en el 100% (actividades naturales)
- Spec: sin grindeo en el 100% (actividades naturales). Coherente con M75 (postgame) y M29 (tiempo).
## Specs Postgame (Beam 537)

### Categoría "Epílogo" en M72
- Spec: categoría "Epílogo" en M72. Coherente con M75 (postgame) y M72 (logros).

### Logro: colección completa
- Spec: logro: colección completa. Coherente con M75 (postgame) y M73 (colección).

### Logro: primer festival postgame
- Spec: logro: primer festival postgame. Coherente con M75 (postgame) y M74 (eventos).

### Logro: 100% de la hoja de ruta
- Spec: logro: 100% de la hoja de ruta. Coherente con M75 (postgame) y M71 (progresión).

### Mundo 100% abierto tras el final
- Spec: mundo 100% abierto tras el final. Coherente con M75 (postgame) y M27 (islas).
## Specs Postgame (Beam 538)

### Sin bloqueos de progresión postgame (M71)
- Spec: sin bloqueos de progresión postgame (M71). Coherente con M75 (postgame) y M71 (progresión).

### Transporte accesible a todas las zonas (M68)
- Spec: transporte accesible a todas las zonas (M68). Coherente con M75 (postgame) y M68 (transporte).

### Exploración recompensada (M73/M71)
- Spec: exploración recompensada (M73/M71). Coherente con M75 (postgame) y M73 (colección).

### Cero contenido exclusivo de multijugador
- Spec: cero contenido exclusivo de multijugador. Coherente con M75 (postgame) y M76 (online).

### Hoja de ruta sin duplicación de estado
- Spec: hoja de ruta sin duplicación de estado. Coherente con M75 (postgame) y M55 (diario).
## Specs Postgame (Beam 539)

### Migración v1.4 del flag (M60)
- Spec: migración v1.4 del flag (M60). Coherente con M75 (postgame) y M60 (rendimiento).

### Catálogo como Resource embebido (no serializado)
- Spec: catálogo como Resource embebido (no serializado). Coherente con M75 (postgame) y M73 (colección).

### Sin grindeo en actividades del 100%
- Spec: sin grindeo en actividades del 100%. Coherente con M75 (postgame) y M29 (tiempo).

### Sin fechas únicas missable
- Spec: sin fechas únicas missable. Coherente con M75 (postgame) y M29 (tiempo).

### Sin logros imposibles (validados)
- Spec: sin logros imposibles (validados). Coherente with M75 (postgame) and M72 (logros).
## Specs Postgame (Beam 540)

### Epílogo cálido, no menú frío
- Spec: epílogo cálido, no menú frío. Coherente con M75 (postgame) y M22 (historia).

### La isla sigue viva tras los créditos
- Spec: la isla sigue viva tras los créditos. Coherente con M75 (postgame) y M27 (islas).

### "¿Qué sigue?" post-créditos (M92/M44)
- Spec: "¿Qué sigue?" post-créditos (M92/M44). Coherente con M75 (postgame) y M92 (balance).

### Pestaña "Isla al 100%" en el diario (M55)
- Spec: pestaña "Isla al 100%" en el diario (M55). Coherente with M75 (postgame) and M55 (diario).
## Specs Postgame (Beam 541)

### Notificación de meta cumplida (M44)
- Spec: notificación de meta cumplida (M44). Coherente con M75 (postgame) y M44 (UI).

### Confeti sutil en logros finales (M52)
- Spec: confeti sutil en logros finales (M52). Coherente con M75 (postgame) y M52 (partículas).

### Evento postgame durante viaje (M68)
- Spec: evento postgame durante viaje (M68). Coherente con M75 (postgame) y M68 (transporte).

### Expansión con módulo ausente en CHECKLIST
- Spec: expansión con módulo ausente en CHECKLIST. Coherente with M75 (postgame) and CHECKLIST-GLOBAL.

### Probar con profiler: hoja de ruta bajo demanda (M61/M116)
- Spec: probar con profiler: hoja de ruta bajo demanda (M61/M116). Coherente with M75 (postgame) and M116 (profiling).
## Specs Postgame (Beam 542)

### Integrar con M22 (epílogo)
- Spec: integrar con M22 (epílogo). Coherente con M75 (postgame) y M22 (historia).

### Integrar con M72 (categoría Epílogo)
- Spec: integrar con M72 (categoría Epílogo). Coherente con M75 (postgame) y M72 (logros).

### Integrar con M74/M29 (eventos)
- Spec: integrar con M74/M29 (eventos). Coherente con M75 (postgame) y M74 (eventos).

### Integrar con M73/M37/M55 (100%)
- Spec: integrar con M73/M37/M55 (100%). Coherente with M75 (postgame) and M73 (colección).

### Integrar con M92 (tutorial "¿qué sigue?")
- Spec: integrar con M92 (tutorial "¿qué sigue?"). Coherente with M75 (postgame) and M92 (tutorial).
## Specs Postgame (Beam 543)

### Agregar notas del agente al 04-Codigo.md
- Spec: agregar notas del agente al 04-Codigo.md (honestidad). Coherente con M75 (postgame) y AGENTS.md §21.3.

### Firmar los documentos del módulo
- Spec: firmar los documentos del módulo (modelo y plataforma). Coherente con M75 (postgame) y AGENTS.md §3.

### Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log
- Spec: actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log. Coherente with M75 (postgame) and AGENTS.md §21.

### Verificar con verificar_checklist.py (sin alertas nuevas)
- Spec: verificar con verificar_checklist.py (sin alertas nuevas). Coherente with M75 (postgame) and AGENTS.md §21.9.

### Confirmar 130 ítems exactos y plan-inicial == plan-actual
- Spec: confirmar 130 ítems exactos y plan-inicial == plan-actual. Coherente with M75 (postgame) and AGENTS.md §11.