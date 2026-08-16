# 02 — Análisis — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 23 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Definir filosofía de puzzles | Coherentes con la isla, narrativos si es posible, jamás arbitrarios; el framework emisor→receptor es la garantía |
| Definir dificultad | 3 bandas (Exploración / Ritual / Antiguo) por zona; progresión por familia y por templo |
| Definir tutorialización | El primer puzzle de cada familia tiene una "guía del templo" mural (iconografía) + narrador suave (M31/M33) |
| Diseñar puzzles de luz | Emisores de luz apuntados a receptores (cristales); giro de prisma, lente, ocultación |
| Diseñar puzzles de espejos | Rotación de espejos para dirigir el rayo; convalidación de ángulos 45° (verificable por datos) |
| Diseñar puzzles de agua | Compuertas y niveles: emisor "abrir compuerta" → receptor "sube nivel", barcas flotantes (M66 vehículos) |
| Diseñar puzzles de hielo | Deslizamiento de bloques sobre hielo con patrones de colisión (simétría verificable) |
| Diseñar puzzles de presión | Placas con peso (estático: cajas; dinámico: jugador); umbrales de peso |
| Diseñar puzzles de bloques | Push/Pull con restricción de 1 bloque por eje; orientación del jugador (M57) |
| Diseñar puzzles de gravedad | Bombas/burbujas de gravedad que cambian la dirección del desplazamiento (zonas seleccionadas) |
| Diseñar puzzles de movimiento | Plataformas móviles, pulsos de aire, cintas — sincronizados por un reloj de datos (M29) |
| Diseñar puzzles de sonido | Emisor sonoro → receptor acústico si la línea de audición es clara (M43); nunca depende del oído del hardware |
| Diseñar puzzles de secuencia | Patrones de 3-5 símbolos visibles; la pista siempre muestra el patrón completo después de 2 intentos |
| Diseñar puzzles de símbolos | Emparejar glifos ancestrales (documentados en M25 inscripciones); glosario del templo disponible |
| Diseñar puzzles ambientales | Interacciones con el entorno vivo: viento (M32), lluvia, criaturas (M65 curiosidad abre puerta) |
| Diseñar puzzles con herramientas | Uso de herramientas del inventario (M64-herramientas, M57): pico, gancho, farol |
| Diseñar puzzles multilaterales | Multi-estado (2-3 salas a la vez) con mapa-emisor central (estado compartido por sala) |
| Crear pistas | 3 capas: pista visual ambiental → icono en el diario → pista total en el sistema de ayuda |
| Crear sistema de ayuda | Menú "Guía del Templo" (puzzle actual + historial resuelto); pista diferida 90 s; solución paso a paso tras 3 pistas |
| Evitar puzzles arbitrarios | Regla del framework: todo puzzle tiene solución única lógica; el test de arbitrariedad lo verifica automáticamente |
| Evitar soluciones ambiguas | Doble convalidación: estado objetivo único + detector de "casi solución" que indica proximidad |
| Probar puzzles con jugadores externos | Playtests externos por familia; métricas: tiempo, pistas usadas, abandonos |
| Medir tiempo de resolución | Instrumentación del framework (tiempo por puzzle, por pista usada) |
| Definir checkpoints | PuzzleState se guarda con el patrón de M66/M3X (atomico); checkpoint por sala |
| Definir reinicio de puzzle | Reinicio al estado inicial del slot (M66) si quedó irresoluble o tras 30 s de diagnóstico |
| Crear recompensas | Recompensas narrativas + materiales: reliquia, glifo, experiencia de lore; nunca repetibles ni explotables (M66 cofre) |

## Alternativas descartadas

1. **Puzzles por código duro en cada sala (sin framework):** descartado — 26 puntos y 15 familias lo hacen inmantenible; el framework emisor→receptor es la decisión central.
2. **Gráficos de dependencia complejos sin verificación automática:** descartado — invita a la ambigüedad; el tester de arbitrariedad es obligatorio.
3. **Ayuda por "magia" (completar automáticamente):** descartado — rompe la diversión cozy; la ayuda es incremental (pista → solución).
4. **Failstates con daño (trampas que dañan):** descartado — visión cozy: fallar un puzzle nunca castiga; solo reinicia el estado.

## Decisiones

- **Framework emisor→receptor** como formato de datos: `Emitter`, `Receptor`, `Regla` (estado global de sala expresado como vector booleano/entero).
- **Verificador de arbitrariedad:** en validación (Editor) y en tests se comprueba que el grafo tiene exactamente 1 solución alcanzable; si no, el puzzle no pasa la suite.
- **Estado global por sala** (no por puzzle suelto): el framework permite puzzles multilaterales compartiendo estado (mapa-emisor).
- **Dificultad por banda + subida por intento:** si el jugador falla 3 veces → pista progresiva automática (nunca penaliza).
- **Recompensas nunca duplicables** (integración M66 cofre) y siempre alineadas con el lore del templo.