**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 35: Minería

## ID del Módulo
- **Código:** M35 (plan maestro: sección 34 — Minería)
- **Carpeta:** `DOCUMENTACION/35-Mineria/`
- **Dependencias:** M08 (mundo voxel), M13 (herramientas — pico), M15 (recursos con drops), M26 (Templo Subterráneo). Relaciones: M29 (calendario/PRNG), M30 (reloj en tiempo real), M16 (crafting), M36 (economía), M36 (fauna/colecciones por afinidad cultural), M73 (festivales)
- **Delegable desde:** hoy (diseño completo; implementación tras M08, M13 y M15 funcionales)

## 1. Problema

Minería cozy en un mundo voxel: vetas de minerales incrustadas en el terreno de M08, extraíbles con el pico de M13, que producen recursos (M15) sin tensión ni castigo. Las vetas no se agotan de forma permanente: reaparecen con un respawn lento para que el jugador siempre tenga acceso a recursos pero el mundo nunca se vacíe ni se sature de farmeo.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Vetas | Vetas de 1-3 bloques de mineral distribuidas por el voxel según profundidad, bioma y zona de minería |
| RF2 | Minerales | Catálogo OreDefinition: cobre, hierro, oro, cristal, mineral ancestral y materiales raros, alineado con el catálogo de M15 |
| RF3 | Profundidad | Bandas de profundidad: superficie (vetas pobres), subterráneo medio (vetas ricas), capa ancestral (M26, minerales raros) |
| RF4 | Cuevas | Cuevas y cavernas con vetas en paredes y techos, iluminadas por el brillo propio del mineral |
| RF5 | Herramienta | Pico de M13 con golpes por veta según dureza; la durabilidad solo se descuenta al extraer (ningún castigo por errar) |
| RF6 | Eficiencia | Picos superiores (M13) reducen golpes necesarios y aumentan la probabilidad de drop doble |
| RF7 | Drops | La extracción genera recursos al inventario (M15) con partículas, sonido y texto flotante |
| RF8 | Regeneración | Vetas agotadas reaparecen tras un tiempo de juego prolongado (respawn lento), validando que la zona esté libre |
| RF9 | Riesgos cozy | Sin daño al jugador; riesgos no violentos: deslumbramiento momentáneo, caídas suaves y derrumbes controlados que solo entierran la veta |
| RF10 | Ritmo | Anti-repetitividad: golpes con cadencia, animación de swing y recompensas escalonadas; límite suave de extracción diaria por zona |
| RF11 | Secretos | Recursos secretos (mineral ancestral) en nodos especiales de la capa de M26 |
| RF12 | Colecciones | Cada mineral se registra en la colección del jugador y es donable (museo/colecciones) |

## 3. Requisitos No Funcionales

- **Cozy:** cero violencia, cero fallas que dañen al jugador; derrumbes solo visuales y breves.
- **Determinismo:** distribución de vetas por PRNG de partida (M29); el estado de cada veta (agotada/regenerando) se persiste en guardado.
- **Rendimiento:** edición voxel por bloques con remeshing diferido del chunk afectado; partículas pooled; sin allocs en el hot path del golpe.
- **Pausa:** el reloj M30 congela los temporizadores de regeneración sin desincronizar los tiempos.
- **Desacople:** MiningManager se comunica con M08, M13, M15 y M26 por APIs/contratos; cero acoplamiento con UI.

## 4. Criterios de Aceptación

1. Los 24 puntos de la sección 34 resueltos y cubiertos en los archivos del módulo.
2. Vetas, minerales, bandas de profundidad, cuevas y regeneración diseñados e integrables con M08.
3. El pico M13 extrae con eficiencia, durabilidad y drops M15 coherentes con su catálogo.
4. Edge cases cubiertos: veta a medias, respawn con zona ocupada, jugador parado sobre la veta.
5. Módulo delegable para implementación.