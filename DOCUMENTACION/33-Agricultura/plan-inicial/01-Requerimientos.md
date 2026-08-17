**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 33: Agricultura

## ID del Módulo
- **Código:** M33 (plan maestro: sección 32 — Agricultura)
- **Carpeta:** `DOCUMENTACION/33-Agricultura/`
- **Dependencias:** M17 (Construcción — parcelas y terrenos cultivables), M29 (Tiempo y Calendario — ciclos por día y estaciones). Relaciones: M08 (Mundo Voxel — tierra arada como bloque y cultivos como instancias), M14 (Inventario — semillas y cosechas), M15 (Recursos — semillas, frutas y fibras), M16 (Crafting — recetas con cultivos), M13 (Herramientas — pala y regadera), M31 (Ciclo Día/Noche), M32 (Clima — lluvia que riega), M64 (IA de NPC — pisoteo y navegación), M61 (Rendimiento — presupuesto de instancias)
- **Delegable desde:** hoy (diseño completo; implementación tras mundo voxel M08, GameClock M29 e inventario M14)

## 1. Problema

El jugador necesita una actividad calmada, opcional y con recompensa clara dentro de la isla: cultivar parcelas de tierra arada, plantar semillas, regar y cosechar siguiendo los ciclos diarios del calendario de Aurora. El sistema debe sentirse cozy — sin hambre castigadora, sin marchitamiento cruel, sin cultivos que mueren si el jugador se ausenta — y a la vez profundo (estaciones, calidades, cultivos especiales, árboles frutales, flores e híbridos ancestrales). La comida es opcional: cosechar sirve para vender, cocinar, regalar y completar misiones, nunca como requisito de supervivencia.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tierra cultivable y arada | La pala (M13) convierte tierra (bloque del catálogo M08) en tierra arada persistente; la tierra arada no se puede pisar como bloque (colisión correcta) |
| RF2 | Parcelas | Sistema M17 otorga hasta N parcelas activas por el jugador; la parcela define el límite de cultivos simultáneos permitidos por tamaño |
| RF3 | Semillas | Ítem del inventario (M14/M15); al plantar en tierra arada se consume y se crea un cultivo en el voxel seleccionado |
| RF4 | Etapas de crecimiento | Cada cultivo pasa por una secuencia de etapas (semilla, brote, crecimiento, madura, lista) definida en su CropDefinition |
| RF5 | Ciclos por día | Cada salto de día del GameClock (M29) evalúa todos los cultivos activos y avanza (o pausa) su etapa según días totales y condiciones |
| RF6 | Riego | La regadera (M13) o la lluvia (M32) llenan un nivel de agua por cultivo; sin agua el crecimiento se pausa pero el cultivo no muere (regla cozy) |
| RF7 | Estaciones | El calendario M29 expone la estación actual; cada cultivo declara las estaciones donde crece; en estaciones no aptas el cultivo entra en estado DORMANTE (se detiene, nunca muere) |
| RF8 | Cosecha | Al estar listo, el jugador cosecha y obtiene los ítems de rendimiento definidos (frutas, verduras, flores, fibras, semillas reproducibles); deja la tierra arada lista para replantar |
| RF9 | Sin hambre castigadora | No existe requisito de alimentarse para sobrevivir; la comida es un recurso opcional para venta, recetas M16, regalos y misiones |
| RF10 | Cultivos especiales | Árboles frutales, flores decorativas, plantas ancestrales (con requisitos de desbloqueo narrativo), híbridos (cruce de flores) y agricultura decorativa |
| RF11 | Fertilizante | Opcional y benigno: acorta el tiempo de crecimiento o mejora la calidad del rendimiento sin penalidades de mal uso |
| RF12 | Persistencia | El estado de cada cultivo (etapa, agua, días acumulados, posición voxel) se guarda con el GameState y se restaura al cargar |

## 3. Requisitos No Funcionales

- **Cozy absoluto:** cero pérdidas irreversibles por descuido; cero presión temporal; los NPC nunca destruyen cultivos (el pisoteo es solo un coqueto feedback de agitación).
- **Rendimiento (M61):** máx 400 cultivos activos simultáneos en la isla con visual por instancias (MultiMesh / VoxelInstanceModifier): evaluación diaria ≤ 2 ms; sin procesamiento por frame (excepto feedback visual).
- **Legibilidad:** el estado de cada cultivo se comunica con visual y tooltip; nunca se obliga al jugador a adivinar por qué no crece.
- **Determinismo (M29):** el avance se calcula por días (índice de día + estación), no por tiempo real; reanudar un guardado nunca retrocede ni se salta etapas injustamente.
- **Modularidad (M07):** FarmService expone API pura sin acoplamiento a UI; los visuales viven en capa separada.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 32 del plan maestro resueltos y documentados en el plan-actual.
2. Ciclo completo verificable: arar → plantar → regar → crecer por días → cosechar → obtener ítems (con y sin agua, en las 4 estaciones).
3. Reglas cozy verificadas: sin muerte por sequía, sin muerte por invierno, sin hambre castigadora, sin destrucción por NPC.
4. Presupuesto visual y de evaluación diaria definido y acotado (M61).
5. Contrato API estable y delegable para implementación.