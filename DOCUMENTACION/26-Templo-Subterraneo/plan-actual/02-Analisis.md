# 02 — Análisis — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 25 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Diseñar entrada | Pórtico bajo las raíces de la Isla de los Sacrificios (brisa sale del respiradero); 2 puertas: principal (sellada) y servicio |
| Diseñar vestíbulo | Sala de 3 vías: al templo (derecha), a la Guarda de la Brisa (izquierda), a la plaza de desembarque (retro) |
| Diseñar primera sala | "Sala de los Vientos": 3 puzzles de viento (banda Exploración, M24 familia ambiental) |
| Diseñar tutorial | Panel de la Guía del Templo (iconografía M24) + 1 puzzle guiado paso a paso |
| Diseñar habitaciones intermedias | 6 salas: 2 de luz, 1 de agua, 1 de presión, 1 de sonido, 1 de secuencia (bandas Ritual-Antiguo) |
| Diseñar caminos alternativos | Pasillo del Artesano: abre vía lateral tras resolver 2 salas secretas (siempre 2+ caminos, M66) |
| Diseñar salas secretas | 4: bajo placa, tras puerta falsa, tras mural giratorio, bajo el acuífero (2+ caminos) |
| Diseñar sala central | Rotonda de la Columna: mecanismo principal (7 anillos de viento), círculo de observación |
| Diseñar mecanismo principal | 7 anillos de la Columna: cada anillo se activa con un sello de cristal traído de las salas secretas; 3 progresos de puzzle (M24 multilateral) |
| Diseñar puzzle final | "Sello de la Brisa": 3 fases — alinear espejo maestro (luz), tocar 3 gongs en orden (sonido), timón de agua (nivel) |
| Diseñar cámara del Sello | Sancta: pedestal del Sello; cutscene contextual mínima (M33 hooks); se restaura el sello y se abre la salida |
| Diseñar salida | Túnel del amanecer: sube a la isla (atajo al puerto), abre si sello restaurado |
| Diseñar checkpoints | 5 puntos: porte, vestíbulo, primera sala, sala central, cámara del Sello (patrón M66/M3X, guardado atómico) |
| Diseñar iluminación | Faros de cristal por sala; luz volumétrica suave (brisa); contraste mínimo 4.5:1 en iconografía (M58) |
| Diseñar sonido ambiental | Brisa en corredores (M42), goteo de agua (M43), 3 ambiences por banda (M41) |
| Diseñar partículas | Polvo de luz en la rotonda (M52), viento visible en corredores; sin partículas sin función |
| Diseñar materiales | 1 paleta de materiales del templo (piedra de brisa, cristal, bronce) — 3 materiales base + variantes (M47) |
| Diseñar texturas | 12 texturas clave con nivel de detalle por LOD (M47/M63) |
| Diseñar iconografía | 8 glifos del Sello (4 comunes, 4 de cámara); glosario en la Guía del Templo (M24) |
| Diseñar arquitectura coherente | Voxel-compatible: corredores 4x4x4 m, techos 3x3 bloques, puertas 2x3; transiciones en 45° |
| Crear navegación | NavigationServer3D: foam de navegación por piso con vínculos verticales (rampas 20°, huecos) |
| Crear telemetría de puzzles | Cada puzzle emite: intentos, pistas usadas, tiempo; exportable a M24 para balance |
| Testear softlocks | Suite (M66) por zona: objetos/llaves perdidos, NPC atascados, puzzles irresolubles |
| Testear exploits | Acceleración por salto en rampas (teórico), duplicación de sellos, entrada por salida sellada — prueba por vite |
| Testear orientación | Recorrido de checkpoints con el panel opcional del mapa; prueba de deriva (jugador perdido > 2 min) |
| Testear accesibilidad | Contrastes, tamaño de iconografía (M58), fov, sin presión temporal en puzzles |

## Alternativas descartadas

1. **Templo 100% lineal:** descartado — la retención cae; el diseño es lineal-ramificado (núcleo + ramas cuadradas).
2. **Retrocableado extenso (laberinto):** descartado — costoso y rompe orientación (regla anti-laberinto del cozy).
3. **Voznarrada obligatoria en cada puzzle:** descartado — el tutorial es guiado pero breve; el resto se autodocumenta (M24).
4. **Salas secretas sin cofre de salida:** descartado — el Detector de M66 exige 2+ caminos para zonas con recompensa.

## Decisiones

- **Metría voxel fija** (corredor 4×4×4 m, puerta 2×3 bloques) para que M08 lo genere sin retrabajo.
- **5 checkpoints con guardado atómico** (patrón del proyecto).
- **7 anillos + 3 fases** del puzzle final como multilateral que reutiliza las familias de M24.
- La Cámara del Sello exige **restauración del sello y apertura de salida** como único gating (sin llaves duplicables).
- La telemetría de puzzles alimenta M24 (balance) con export listo (JSON).