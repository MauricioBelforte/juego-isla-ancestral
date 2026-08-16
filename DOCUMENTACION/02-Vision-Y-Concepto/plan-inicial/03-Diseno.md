**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 01: Visión y Concepto

## 1. Identidad del Juego

| Atributo | Definición |
|---|---|
| Nombre definitivo | **Isla Ancestral** |
| Título provisional (producción) | Proyecto Isla Ancestral |
| Género principal | Cozy Voxel / Life Simulation |
| Géneros secundarios | Puzzle Adventure, Exploración, Sandbox |
| Edad recomendada | E+10 (ESRB) / PEGI 7 |
| Plataformas | PC (Steam) → Steam Deck → consolas (evaluar) |
| Cámara | 3ª persona, cenital inclinada, rotación/zoom libres |
| Estilo visual | "Cozy Voxel": terreno de bloques + props/personajes 3D redondeados, paleta pastel cálida, iluminación suave (URP) |
| Tono | Misterioso, cálido, contemplativo, aventurero, esperanzador |
| Duración v1.0 | 30-50 h principales (70+ h con comunidad completa) |
| Filosofía | Ausencia total de combate, muerte o penalizaciones violentas |

## 2. Elevator Pitch (15 segundos)

> "Isla Ancestral es un juego de vida y construcción voxel donde llegas a una isla aparentemente vacía para empezar de nuevo. Bajo tu pala duerme una civilización que aprendió a modificar el mundo… y cada bloque que mueves, cada templo que descubres, te acerca a algo que tal vez no debería haber sido despertado. Sin combate. Sin prisa. Solo tu hogar, tus vecinos y un secreto bajo la tierra."

## 3. Descripción de una Frase

> "Una aventura cozy de construcción voxel donde tu hogar crece mientras descubres la civilización que duerme debajo de tu isla."

## 4. Descripción de una Página

Isla Ancestral combina la vida comunitaria de un simulador cozy con la libertad de modificación de un mundo voxel y la progresión de misterio de una aventura de puzles.

Llegas a Aurora, una pequeña isla deteriorada, con una tienda de campaña y herramientas básicas. Con la pala, el pico y el hacha modelas el terreno: construyes casas, caminos, puentes y jardines. Los vecinos —animales y personajes con personalidades propias— se mudan a tu isla, reaccionan a tus construcciones y ganan confianza contigo con el tiempo.

Bajo la tierra descubres las ruinas de los Arquitectos del Alba, una civilización que dominó una energía natural llamada **La Resonancia**: una tecnología capaz de mover agua, alterar el terreno y conectar islas separadas por cientos de kilómetros. En templos subterráneos sin enemigos, resuelves acertijos de luz, agua y mecanismos para obtener Fragmentos de Sello y herramientas de aventura no letales: el Gancho Mecánico, la Lanza-Semillas y las Varas de Flujo.

Una vez al mes, el Gran Vapor atraca en tu puerto. Por un Boleto de Pasaje —que requiere haber resuelto el templo del mes anterior— puedes viajar a islas de biomas completamente distintos, con flora exótica, materiales únicos y nuevos vecinos que invitar a tu hogar.

No hay combate, no hay castigos ni plazos punitivos. El ritmo lo pone el jugador: construir es colaborar, y excavar es parte del misterio.

## 5. Pilares de Diseño

| # | Pilar | Descripción |
|---|---|---|
| P1 | **La construcción tiene memoria** | El terreno es narrativo: excavar no es cosmético. El mundo voxel guarda el pasado (ruinas, canales, cámaras) y modificarlo revela historia. Cada bloque cuenta |
| P2 | **Comunidad que reacciona** | Los vecinos viven *tu* mundo: reaccionan a tus puentes, jardines y plazas; tienen arcos de amistad y personalidades reconocibles. El pueblo es un espejo del jugador |
| P3 | **Misterio sin presión** | Templos sin enemigos, puzles de lógica y observación, progreso permanente. No hay relojes reales contra el jugador, ni castigos por fallar |
| P4 | **Calma satisfactoria** | Satisfacción sensorial (ASMR), animaciones suaves, bucles de 20-45 min por sesión. La facilidad de cada interacción está pulida antes de agregar complejidad |

## 6. Pilares Narrativos

| # | Pilar | Descripción |
|---|---|---|
| N1 | **La tecnología es conexión, no poder** | La Resonancia es una relación con el mundo, no una máquina de dominar. La historia enseña que modificar el entorno tiene consecuencias de cuidado, no de conquista |
| N2 | **Todos los mundos están conectados** | Bajo los océanos hay una red natural; cada isla nueva refuerza que Aurora no es el centro del universo, sino una hebra de una trama global |
| N3 | **No eres un héroe** | El jugador es un habitante; la historia avanza por curiosidad y cuidado, no por destino. Los finales emergen de cómo construyes y a quién ayudas |

## 7. Pilares Visuales

- **Paleta pastel cálida** con acentos por bioma (coral, nieve, ceniza) para legibilidad de contexto.
- **Terreno voxel + props orgánicos redondeados**: contraste deliberado que hace que cada objeto se sienta "artesanal".
- **Luz como lenguaje**: la luz guía puzles (espejos, receptores) y emociona el espacio (amaneceres, atardeceres).
- **UI diegética reducida**: la información del mundo (señales, glifos) vive en el mundo, no en overlays.
- **60 FPS** como requisito de estilo: la fluidez es parte del confort.

## 8. Pilares Sonoros

- **Música acústica/lo-fi en tiempo real**, que evoluciona con el ciclo del día y el área (puerto, templos, meseta).
- **Leitmotiv por Sello/bioma**: cada templo y cada isla tiene su motivo reconocible (Brisa, Marea, Raíz…).
- **SFX ASMR-satisfactorios**: excavar, plantar, regar y colocar bloques suenan "bien" y recompensan la acción por sí mismas.
- **Silencio intencional**: los templos usan espacio sonoro y eco para crear misterio sin tensión hostil.

## 9. Principios de Accesibilidad

1. Remapeo completo de controles (teclado + mando).
2. Subtítulos en diálogos y glifos traducidos.
3. Modalidad de alto contraste para puzles de luz/color (daltonismo: los puzles nunca dependen solo del color).
4. Texto ajustable (tamaño) y ritmo de diálogo pausable.
5. Sin requisitos de reflejos: los puzles se resuelven con calma.
6. Opciones de sensibilidad de cámara y vibración.
7. Sin FOMO: nada esencial se pierde por no jugar un día.

## 10. Principios de Rendimiento

1. **60 FPS objetivo** en PC media/Steam Deck; voxel con *face culling* (solo caras visibles) desde el día 1 (GDD §5 directiva 1).
2. Terreno por chunks con LOD y streaming (transvoxel si se elige Godot Voxel Tools).
3. Batching de objetos de decoración; pools para partículas.
4. Draw calls presupuestados por escena (frame budget definido en M04/rendimiento).
5. Assets comprimidos por plataforma (texturas, audio); iluminación horneada + luces dinámicas acotadas.

## 11. Alcance del Proyecto — v1.0

**Dentro de la v1.0** (fuente: `Plan-de-produccion.md` §1): Isla **Aurora completa** (hub) · **1-2 islas adicionales** vía Gran Vapor (Coral y/o Verde) · **2-3 Sellos obtenibles** (Brisa + Marea, con templos y herramientas) · **cierre narrativo satisfactorio parcial** (Aurora conectada a algo más grande) · comunidad/especialidades ambientales de Aurora · bucle diario/semanal/mensual completo.

**Fuera del alcance inicial (roadmap post-lanzamiento):** Isla de las Cenizas · Islas del Cielo · Elysia · los 4 finales · sistema oceánico completo con submarino · multijugador · modding.

## 12. Diagrama de Posicionamiento (texto)

```
                   Alta fantasía / acción
                          ▲
                          │
        Zelda BOTW ──────┤  (referencia de puzles, no de tono)
                          │
   ─── Oscuro/estrés ─────┼──── Cozy/calma ────►
                          │      ▲
                          │      │ Isla Ancestral (hook: misterio
                          │      │  bajo el voxel, cero violencia)
                          │      │ Stardew · Animal Crossing ·
                          │      │  Dinkum · A Short Hike
                          │      │
                          ▼
                    Simulación/Mundo social