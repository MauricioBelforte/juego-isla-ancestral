**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 141: Beta

## 1. Problema
Alpha (M140) entregó un juego completo jugable con GONOGO-BETA aprobado. Beta convierte ese juego en un **producto pulido, completo y certificable**: contenido 100% final, historia cerrada, las 6 islas, los 6 templos, los 6 Sellos (Acto 3 incluido), audio total, localización, accesibilidad, rendimiento objetivo, plataformas integradas y materiales de comercialización (store page, trailer, certificación).

## 2. Objetivo del módulo
Entregar la primera build **pública beta** jugable de punta a punta (100% del contenido previsto) con calidad de release funcional: cero bugs críticos conocidos, rendimiento sostenido en hardware objetivo, y todo lo necesario para el RELEASE CANDIDATE (M142).

## 3. Alcance (derivado del plan maestro: sección 140 "BETA")
1. **Contenido completo** — 6 islas, 6 templos, 100 coleccionables, todas las recetas, todos los ítems, todos los eventos.
2. **Historia completa** — 6 Sellos con Acto 3, epílogo en el faro, todas las cadenas de misiones.
3. **Puzzles completos** — puzzles de los 6 templos y del mundo, con dificultad balanceada y accesible.
4. **Islas completas** — las 6 islas de M50 en su versión final (visual, sonido, fauna, flora, NPC).
5. **Audio completo** — música M41, SFX M42, ambient M43, voz M44 en toda la partida.
6. **Localización completa** — M87: español, inglés + idiomas objetivo; subtítulos totales.
7. **Accesibilidad implementada** — M58 al 100%: remapeo, subtítulos, modos de color, reducción de efectos.
8. **Rendimiento objetivo** — M61/M62/M63 dentro de presupuesto en hardware mínimo y recomendado.
9. **Cero bugs críticos conocidos** — inventario P0/P1 = 0 al cierre de Beta.
10. **Integración de plataformas** — PC (Steam) y las definidas en M149; API de logros/guardado cloud.
11. **Store page final** — textos, capturas, tags, caja de puntuación (M149).
12. **Trailer final** — tráiler de lanzamiento con captura real (M149).
13. **Preparación para certificación** — checklist de plataforma, build estable, paquetes de contenido.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Contenido 100% final: todos los ítems, recetas, coleccionables (100/100), eventos y misiones presentes y jugables |
| RF2 | Historia completa: 6 Sellos obtienen y registran el Acto 3 y epílogo; sin texto placeholder |
| RF3 | Puzzles completos: los 6 templos con puzzles finales; dificultad descrita en M93 |
| RF4 | Islas finales: las 6 islas con arte, audio y gameplay finales (sin prototipos) |
| RF5 | Audio al 100% en runtime: música por zona/acto, SFX de interacción, ambient por bioma, voces de hitos |
| RF6 | Localización completa en los idiomas objetivo (M87): UI, subtítulos, textos, logros |
| RF7 | Accesibilidad 100% (M58): remapeo total, subtítulos, modos de color, reducción de efectos, tamaño de texto |
| RF8 | Rendimiento objetivo sostenido según presupuestos (M61-M63) en hardware mínimo y recomendado |
| RF9 | Cero bugs P0/P1 al cierre; P2 documentados con trabajo estimado |
| RF10 | Integración de plataformas funcional: build, sample, logros, cloud saves (según M149) |
| RF11 | Store page final ready (textos, capturas, tags, requisitos) |
| RF12 | Trailer final generado desde builds reales |
| RF13 | Certificación preparada: checklist de plataforma completo, candidato a RC (M142) |

## 5. Criterios de aceptación (DoD del módulo)
1. Partida completa Alpha→Beta de punta a punta en todas las métricas: 100% coleccionables, 100% misiones, 100% recetas.
2. Historia jugable completa incluyendo Acto 3 y epílogo, sin texto placeholder, sin ramas vacías.
3. Los 6 templos resolubles, con tutorial y accesibilidad verificados.
4. Hardware mínimo y recomendado dentro de presupuesto (M61-M63) medidos en build de Beta.
5. Bug tracker (M101): 0 abiertos P0/P1; P2 con estimación y plan.
6. Localización y accesibilidad verificadas por checklist (M87/M58) en todas las plataformas objetivo.
7. Store page y trailer entregados y aprobados por el equipo (M149).
8. Preparación de certificación completada (checklist M149) y candidato listo para M142.
9. Documentación plan-actual actualizada (141-Beta) y QA cruzado realizado.

## 6. Restricciones
- **Aplican:** M61 (presupuestos), M62 (memoria), M63 (streaming), M58 (accesibilidad), M87 (localización), M149 (plataforma/marketing), M101/M102 (bugs), M112 (tests), M135 (deuda ≤ nivel definido), M110 (audio), respuesta 60 días máx. a QA/plataformas.
- No se agregan features nuevas; solo correcciones, pulido y contenido final.
- El contenido de Beta 4 (M141-Beta) es 100% canon: nada de lo incluido puede desviarse de la biblia (M147).

## 7. Dependencias
- M140 (Alpha ✅): base funcional y GONOGO aprobado.
- M152 (Manual/UX), M87 (Localización), M58 (Accesibilidad), M149 (Plataformas/Marketing), M41-M44 (Audio), M50/M36 (Mundo/Flora), M24/M26 (Templos), M13 (Artefactos), M66 (Croft/anti-softlock), M71 (Progresión), M93 (Balance), M101/M102 (QA/Bug tracking), M112 (Tests), M59/M60 (Saves/Cloud), M147 (Biblia).
- M142 (RC): recibe el candidato de Beta.

## 8. Entregables del módulo
1. Build Beta pública (Steam y/o plataforma objetivo).
2. Acta de cierre Beta (checklist 100% del contenido, 0 P0/P1).
3. Inventario final de bugs conocidos (P2) para la ruta a RC.
4. Store page final + tráiler final (M149).
5. Candidato formal a Release Candidate.