**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# M156 - Analisis - Terrenos y Movimiento Diferenciado

## 1. Analisis del Dominio

### 1.1 Contexto del Juego
Isla Ancestral es un juego voxel cozy donde el jugador explora una isla, recolecta recursos, construye y interactua con el entorno. La experiencia debe ser relajante y satisfactoria, sin penalizaciones severas por equipo inadecuado.

### 1.2 Filosofia Cozy
- **Regla de oro:** El jugador NUNCA debe sentirse castigado por usar equipo incorrecto
- La velocidad minima debe ser al menos el 50% de la base
- Las diferencias deben ser perceptibles pero no frustrantes
- El feedback debe ser positivo (celebrar terrenos adecuados) mas que negativo (penalizar terrenos dificiles)

### 1.3 Modelado del Problema
VelocidadEfectiva = VelocidadBase * ModificadorTerreno * (1 + BonificacionEquipo)

Donde:
- VelocidadBase: Constante definida en el jugador (M11)
- ModificadorTerreno: Factor del 0.6 al 1.0 segun tipo de terreno
- BonificacionEquipo: Factor aditivo del +0.05 al +0.35 segun equipacion (M155)

## 2. Tipos de Terreno

### 2.1 Tabla de Terrenos y Modificadores

| ID | Terreno | Modificador | Descripcion |
|----|---------|-------------|-------------|
| 0 | Ceped | 1.0 | Superficie natural, pasto corto |
| 1 | Barro | 0.6 | Superficie blanda, pegajosa |
| 2 | Pavimento | 1.0 | Superficie dura, artificial |
| 3 | Arena | 0.75 | Superficie suelta, granulosa |
| 4 | Agua (poco profunda) | 0.7 | Superficie liquida, resistencia |
| 5 | Nieve | 0.8 | Superficie blanda, compactable |
| 6 | Rocas | 0.85 | Superficie irregular, dura |

### 2.2 Feedback Visual por Terreno

| ID | Terreno | Huellas | Particulas | Efectos Especiales |
|----|---------|---------|------------|---------------------|
| 0 | Ceped | Ligeras, poco visibles | Particulas verdes (hierba) | Hojas sueltas |
| 1 | Barro | Profundas, deformadas | Salpicaduras marrones | Acumulacion en pies |
| 2 | Pavimento | Nitidas, claras | Destellos minimos | Ninguno |
| 3 | Arena | Que se rellenan solas | Nube de arena fina | Hundimiento leve |
| 4 | Agua | Ondas concentricas | Salpicaduras azules | Rocio, burbujas |
| 5 | Nieve | Profundas, blancas | Copos, polvo blanco | Compactacion |
| 6 | Rocas | Marcas claras | Polvo gris | Chispas en rocas duras |

### 2.3 Feedback Audio por Terreno

| ID | Terreno | Tipo de Sonido | Volumen | Pitch Variacion |
|----|---------|----------------|---------|-----------------|
| 0 | Ceped | Pasos suaves sobre hierba | 0.4 | +-5% |
| 1 | Barro | Squelch, sonido humedo | 0.6 | +-10% |
| 2 | Pavimento | Click, pasos firmes | 0.5 | +-3% |
| 3 | Arena | Crunch, pasos secos | 0.5 | +-8% |
| 4 | Agua | Splash, burbujas | 0.7 | +-15% |
| 5 | Nieve | Crunch suave, squeak | 0.45 | +-7% |
| 6 | Rocas | Pasos firmes, eco | 0.55 | +-5% |

### 2.4 Rangos de Modificadores

| Rango | Terrenos | Experiencia del Jugador |
|-------|----------|-------------------------|
| 1.0 (Optimo) | Ceped, Pavimento | Movimiento natural, sin penalizacion |
| 0.85-0.8 (Bueno) | Rocas, Nieve | Ligera ralentizacion, aun comodo |
| 0.75-0.7 (Medio) | Arena, Agua | Ralentizacion noticeable pero manejable |
| 0.6 (Bajo) | Barro | Ralentizacion significativa, requiere equipo |

## 3. Sistema de Bonificaciones por Equipacion

### 3.1 Tabla de Bonificaciones de Ejemplo (M155)

| Equipacion | Terreno Objetivo | Bonificacion | Efecto |
|------------|------------------|--------------|--------|
| Botas de barro | Barro | +0.35 | Reduce significativamente la penalizacion |
| Botas de nieve | Nieve | +0.30 | Caminar casi normal sobre nieve |
| Botas de agua | Agua | +0.25 | Moverse bien en agua poco profunda |
| Botas de arena | Arena | +0.20 | Reducir hundimiento en arena |
| Botas todoterreno | Todos | +0.10 | Bonificacion general pero pequena |
| Botas urbanas | Pavimento | +0.15 | Ligera mejora en superficies duras |
| Sin equipacion | Ninguno | +0.00 | Sin bonificacion |

### 3.2 Calculo de Velocidad Final

Ejemplo 1: Jugador con Botas de barro caminando sobre Barro
- VelocidadBase = 5.0 m/s (definida en M11)
- ModificadorTerreno = 0.6 (Barro)
- BonificacionEquipo = 0.35 (Botas de barro)
- VelocidadEfectiva = 5.0 * 0.6 * (1 + 0.35) = 4.05 m/s

Ejemplo 2: Jugador sin equipo caminando sobre Barro
- VelocidadBase = 5.0 m/s
- ModificadorTerreno = 0.6 (Barro)
- BonificacionEquipo = 0.0 (Sin equipo)
- VelocidadEfectiva = 5.0 * 0.6 * 1.0 = 3.0 m/s

Diferencia: +1.05 m/s (35% mas rapido con equipo adecuado)

Ejemplo 3: Jugador con Botas de nieve sobre Pavimento
- VelocidadBase = 5.0 m/s
- ModificadorTerreno = 1.0 (Pavimento)
- BonificacionEquipo = 0.0 (Bonificacion solo aplica a Nieve)
- VelocidadEfectiva = 5.0 * 1.0 * 1.0 = 5.0 m/s (sin cambio)

## 4. Analisis de Alternativas

### 4.1 Alternativa 1: Deteccion por Tag de Nodo
- **Descripcion:** Cada terreno tiene un tag unico, detectar con is_in_group()
- **Ventajas:** Simple de implementar, bajo overhead
- **Desventajas:** Requiere mantener tags actualizados, no escalable
- **Decision:** Rechazada por falta de escalabilidad

### 4.2 Alternativa 2: Deteccion por Metadata de TileMap
- **Descripcion:** Usar metadata de tiles para identificar tipo de terreno
- **Ventajas:** Integrado con sistema de tiles, no requiere nodos额外
- **Desventajas:** Acoplado a TileMap, dificil de extender a objetos 3D
- **Decision:** Rechazada por limitaciones de compatibilidad con terrenos 3D

### 4.3 Alternativa 3: Deteccion por Raycast con Layers (ELEGIDA)
- **Descripcion:** Raycast vertical que detecta la layer del terreno
- **Ventajas:** Flexible, funciona con cualquier tipo de terreno, desacoplado
- **Desventajas:** Requiere configurar layers correctamente
- **Decision:** Seleccionada por flexibilidad y desacoplamiento

### 4.4 Alternativa 4: Deteccion por AABB del Jugador
- **Descripcion:** Caja de colision del jugador detecta terreno
- **Ventajas:** Simplicidad, detecta terreno actual automaticamente
- **Desventajas:** Poco preciso, puede detectar multiples terrenos
- **Decision:** Rechazada por falta de precision

## 5. Arquitectura Seleccionada

### 5.1 Patron Strategy con ScriptableObjects
Cada tipo de terreno se representa como un ScriptableObject (TerrainData) que contiene:
- ID unico del terreno
- Modificador de velocidad
- Referencias a sonidos de pasos
- Referencias a efectos de particulas
- Configuracion visual

### 5.2 Raycast Vertical Simple
- Raycast向下 desde la posicion del jugador (pies)
- Detecta la layer del terreno golpeado
- Consulta el TerrainDataProvider para obtener el TerrainData correspondiente
- Retorna el modificador de velocidad

### 5.3 Interfaz de Integracion
El sistema expone una interfaz limpia:
- get_effective_speed(base_speed) -> float
- get_current_terrain() -> TerrainData
- get_terrain_bonus(equipment) -> float

## 6. Decisiones Tecnicas

### 6.1 Separacion de Responsabilidades
- TerrainDetector: Deteccion pura (raycast)
- TerrainDataProvider: Datos y configuracion (ScriptableObjects)
- TerrainModifiers: Calculo de modificadores (matematica)

### 6.2 Compatibilidad con M11
- El sistema NO modifica el script de movimiento del jugador
- Se integra como un modificador que M11 consulta antes de aplicar velocidad
- Mantiene el principio de abierto/cerrado

### 6.3 Compatibilidad con M155
- M155 provee una funcion get_terrain_bonus(terrain_id)
- TerrainModifiers consulta esta funcion al calcular la velocidad final
- Desacoplamiento total entre sistemas

## 7. Consideraciones de Rendimiento

### 7.1 Frecuencia de Deteccion
- No detectar cada frame, usar timer configurable (default: 0.1s)
- Detectar adicionalmente al aterrizar o al cambiar de area

### 7.2 Cache de Resultados
- Almacenar ultimo terreno detectado
- Solo actualizar si el raycast retorna un terreno diferente

### 7.3 Costo Estimado
- Raycast simple: ~0.01ms
- Consulta de datos: ~0.001ms
- Total por deteccion: ~0.011ms (despreciable)

## 8. Validacion de Requisitos

| Requisito | Cumplimiento |
|-----------|--------------|
| RF1 - Deteccion por raycast | Alternativa 3 lo resuelve |
| RF2 - 7 tipos de terreno | Tabla 2.1 define los 7 tipos |
| RF3 - Formula de velocidad | Seccion 3.2 define la formula |
| RF4 - Bonificaciones M155 | Seccion 3.1 define las bonificaciones |
| RF5 - Feedback visual | Tabla 2.2 define el feedback |
| RF6 - Feedback audio | Tabla 2.3 define el feedback |
| RF7 - Nunca bloquear | Filosofia cozy, modificador minimo 0.5 |
| RF8 - Indicador UI | Se contempla en diseno pero no es core |
