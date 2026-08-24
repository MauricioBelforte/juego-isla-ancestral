**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 148: Lore Ambiental

## 1. Problema
El mundo de "Isla Ancestral" (6 islas, 6 templos, 6 Sellos) necesita contar su historia **con el entorno mismo y no solo con diálogos**, para que la exploración se sienta recompensada y el mundo tenga profundidad narrativa. Hoy no existe un sistema que distribuya lore ambiental (ruinas, objetos, arquitectura, vegetación, daños, pistas visuales) de forma coherente con la biblia (M147) y canalizable por los sistemas de recolección (diario M55, colecciones M73, pesca M34, minería M35, flora M50, templos M24/M26 y calendario M74).

## 2. Objetivo del módulo
Diseñar el sistema de **Lore Ambiental**: capas narrativas no-dialógicas distribuidas por el mundo, con pistas y secretos canalizados por las mecánicas de juego, coherentes con la biblia, y con métricas de cobertura para garantizar que el 100% del contenido narrativo ambiental esté desplegado en la release.

## 3. Alcance (derivado del plan maestro: sección 147 "LORE AMBIENTAL")
1. **Ruinas cuentan historias** — cada ruina con micro-narrativa visual/descripción. (M26/M13)
2. **Objetos cuentan historias** — objetos inspeccionables con historia. (M13/M66)
3. **Arquitectura cuenta historias** — estilo constructivo narra origen de cada isla. (M50/M06)
4. **Vegetación cuenta historias** — flora y bosques con narrativa de la isla. (M50/M36)
5. **Daños estructurales cuentan historias** — grietas/derrumbes narran eventos pasados. (M26/M50)
6. **Murales contienen pistas** — murales de templos con pistas de puzzles y lore. (M24)
7. **Estatuas contienen pistas** — estatuas con pistas de sellos/artefactos. (M13/M22)
8. **Mapas contienen pistas** — mapas antiguos con secretos de ubicaciones. (M28/M73)
9. **Canciones contienen pistas** — canciones (rutinas NPC, M20/M21) con mensajes cifrados.
10. **NPC cuentan rumores** — rumores de NPC enlazan lore ambiental con el jugador. (M21/M23)
11. **Peces revelan información** — peces raros/descritos (colección M34/M73) con trozos de mito.
12. **Plantas revelan secretos** — plantas de colección (M50/M73) con secretos de clima/curas.
13. **Minerales activan ruinas** — minerales (M35) que activan ruinas/altaríos (M24/M26).
14. **Cambios del terreno revelan información** — cambios (M50/eventos M74) destapan secretos.
15. **Evitar explicar absolutamente todo mediante diálogos** — regla de diseño: sin infodump; el lore está en el mundo.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Catálogo de piezas de lore ambiental (ruinas, objetos, arquitectura, vegetación, daños, murales, estatuas, mapas, canciones) con IDs y canon de M147 |
| RF2 | Mecánica de inspección: piezas interactuables abren descripción lore en el diario (M55) |
| RF3 | Pistas canalizadas: murales→puzzles (M24), estatuas→sellos/artefactos (M22/M13), mapas→coleccionables (M73), canciones→rumores (M21) |
| RF4 | Peces y plantas de colección con lore integrado a sus entradas (M34/M50/M73) |
| RF5 | Minerales con activación de ruinas/altaríos (interacción con M35 y M24) |
| RF6 | Terreno dinámico: cambios (temporada/eventos) revelan lore oculto (M50/M74) |
| RF7 | Regla anti-infodump: proporción lore ambiental vs diálogo ≥ 60/40; sin texto que explique todo |
| RF8 | Persistencia: estado de lore explorado en save v3.x (M59) y contador en diario |
| RF9 | Cobertura mínima: las 6 islas con ≥ 12 piezas de lore ambiental cada una en la release |
| RF10 | Coherencia total con la biblia (M147): 0 contradicciones detectables |

## 5. Criterios de aceptación (DoD del módulo)
1. Catálogo de lore con IDs únicos y vinculación canon (M147) 100% validado.
2. Inspección con descripción en diario funcional en prototipo.
3. Al menos 30 piezas de lore "pista" (murales/estatuas/mapas/canciones) trazables a sus consumidores.
4. Peces/plantas/minerales con lore en 100% de sus colecciones.
5. Terreno revelador verificable (ej: 3 ubicaciones con secretos destapados por temporada/evento).
6. Auditoría anti-infodump: muestreo de 10 zonas sin textos que expliquen todo.
7. Persistencia verificada: 30 ciclos de carga/guardado sin perder lore recolectado.
8. Documentación plan-actual actualizada y firmada.

## 6. Restricciones
- **Aplican:** M147 (biblia — canon obligatorio), M55 (diario), M73 (colecciones), M22/M23 (historia/misiones), M24/M26 (templos/puzzles), M13 (artefactos/herramientas), M34/M35/M50/M36 (pesca/minería/flora/fauna), M74 (eventos), M59/M60 (save), M152 (narrativa).
- No se crea texto que contradiga el canon; todo lore pasa revisión de la biblia.
- El sistema no debe agregar UI nueva fuera del diario/colecciones existentes.
- Rendimiento: las piezas de lore no agregan draw calls (solo triggers/descripciones).
- Compatibilidad con estados: una pieza ya explorada no se marca de nuevo (persistencia).

## 7. Dependencias
- M147 (Biblia ✅ — canon), M55 (Diario ✅), M73 (Colecciones ✅), M24/M26 (Templos ✅), M22 (Historia ✅), M13 (Artefactos ✅), M34/M35/M50/M36 (Pesca/Minerales/Flora/Fauna ✅), M74 (Eventos ✅), M59/M60 (Saves obsoletos a validar), M21/M23 (NPC/Misiones ✅).

## 8. Entregables del módulo
1. `LoreCatalogo` (ScriptableObject/JSON): todas las piezas con IDs y canon.
2. Mecánica de inspección con registro en diario.
3. Red de pistas (murales→puzzles, estatuas→sellos, mapas→coleccionables, canciones→rumores).
4. Data de lore por pez/planta/mineral integrada a colecciones.
5. Terreno con secretos por temporada (3+ ubicaciones) y pacto anti-infodump documentado.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M024** — Templos y Puzzles | Base para templos y puzzles |
| **M147** — World Building | Lore ambiental en world building |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M024** — Templos y Puzzles | Depende de este módulo |
| **M147** — World Building | Depende de este módulo |

