**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 27: Islas del Mundo

## 1. Problema de diseño

El plan inicial (sección 26) pide isla principal + satélites (Coral, Verde, Cenizas, Cielo, Nieve, Desierto, Volcánica, Submarina, Flotante, Misteriosa, Pequeña, Secreta) con rutas, distancias, clima, flora, fauna, recursos, NPC, arquitectura, música, puzzles, recompensas y relevancia narrativa. La pregunta central: **¿cómo representar el archipiélago en un mundo voxel (M08) con generación procedural (M10) y streaming (M63)?**

## 2. Alternativas evaluadas

### Alternativa A — Mundo continuo de un solo continente (una gran isla única)
- **Descripción:** un solo terreno continuo con "regiones" que hacen el papel de islas separadas por océano decorativo no navegable.
- **Ventajas:** sin streaming de islas, sin transiciones, sin coordenadas de islas.
- **Desventajas:** pierde la fantasía de viajar en barco (M28), la navegación oceánica (M51) y la identidad de satélites; el océano no podría ser navegable sin romper el "mundo continuo" colisionable con los bordes.
- **Veredicto:** descartada, contradice la sección 26 (rutas entre islas, navegación) y la 50 (agua de océano).

### Alternativa B — Islas completamente separadas con cargas instanciadas (fast travel obligatorio)
- **Descripción:** cada isla es una escena/reino aparte; entre islas solo hay viaje por pantalla (menú de M28), sin océano físico navegable.
- **Ventajas:** máxima optimización (una isla en memoria), transición trivial.
- **Desventajas:** pierde la experiencia de navegar el océano voxel (M51 "interacción con barcos"), el barco (M28) y la sensación de mundo abierto; la travesía real queda reducida a una pantalla de carga.
- **Veredicto:** descartada como primaria; se conserva como **fallback de bajo rendimiento** en M63 para hardware débil (opcional de streaming).

### Alternativa C — Archipiélago en océano voxel navegable con streaming por isla (ELEGIDA)
- **Descripción:** todas las islas viven en un mismo mundo voxel continuo de gran extensión; entre ellas hay océano voxel (M51) navegable a vela/barco (M28); el streaming (M63) mantiene cargada la isla actual y precarga/descarga vecinas por distancia con LRU.
- **Ventajas:**
  - Cumple sección 26 (rutas, distancias, navegación) y 50 (océano navegable, interacción con barcos).
  - Travesía real visible: el jugador ve el mar, oye las olas (M42) y sigue el viaje en barco (M28).
  - Contenido exclusivo por isla real: bioma (M09), clima (M32), flora (M50), fauna (M36), NPC (M19/M64).
  - Coherente con la generación procedimental de M10: las anclas de islas son puntos del generador.
- **Desventajas:** requiere streaming robusto (M63), presupuesto M61, y coordinación de anclas para no superponer islas.
- **Veredicto:** ELEGIDA. Es la única que cumple simultáneamente viajes por barco reales, océano navegable y mundo abierto con identidad por isla.

### Alternativa D — Mundos separados con salto de escena y misma semilla
- **Descripción:** cada isla es un mundo voxel separado (mismo mundo, diferentes coordenadas), con "portal" de barco que intercambia el mundo activo bajo renderizado.
- **Ventajas:** memoria muy acotada; simplicidad de coordenadas.
- **Desventajas:** dos veces el sistema de streaming (por mundo y por isla); colisión de navegación (M64) y de mapa (M54) más complejas; el océano de M51 queda partido.
- **Veredicto:** descartada; M63 ya define streaming dentro de un único mundo voxel.

## 3. Decisiones justificadas

| # | Decisión | Justificación |
|---|---|---|
| D1 | **Archipiélago en un único mundo voxel continuo** | Permite océano navegable real (M51) y viajes en barco (M28) dentro del mismo mundo; alineado con M08/M10 y M63 |
| D2 | **Isla principal Aurora siempre cargada; satélites con streaming** | Aurora es el hogar (pronóstico quieto); las satélites usan LRU de M63 para respetar presupuesto M61 |
| D3 | **Anclas de islas definidas por M10 (pipeline de 8 capas)** | La capa de anclas del generador posiciona islas de forma determinista (PRNG por contexto 2) y valida no-solapamiento |
| D4 | **Océano voxel navegable con agua de mar (M51)** | El agua es un bloque del catálogo (M08); la navegación del barco la gobierna M28/M67; M27 solo declara la región acuática entre islas |
| D5 | **Contenido exclusivo declarativo por isla** | Cada isla declara recursos/flora/fauna/puzzles/NPC; el spawn lo resuelven los generadores correspondientes (M50/M36/M19) contra un contrato de "bioma de isla" |
| D6 | **Distancia entre islas uniforme en anillo + islas extremas por ancla especial** | Anillo cercano (navegable < 2 min), anillo medio, islas lejanas (expedición M28) — evita frustración y da progresión suave |
| D7 | **Registro central `IslandRegistry` como service (patrón M07)** | Fuente única de verdad del catálogo; el resto consulta sin acoplarse |
| D8 | **Carga por servicio `IslandLoading` separado del generador** | M15 (modularidad) exige no tocar M10 para agregar streaming; IslandLoading orquesta M63 sin acoplar la generación |

## 4. Análisis de riesgo

| Riesgo | Mitigación |
|---|---|
| Islas superpuestas por anclas mal validadas | Validación en registro: distancia mínima entre centros > suma de radios + margen de playa |
| Congelamiento al cargar isla grande | Streaming incremental M63 con pesos y progreso real; precarga en pantalla de viaje (M28) |
| Contenido exclusivo inaccesible | Regla cozy: todo contenido exclusivo también obtenible (en menor cuantía) en Aurora o en ferias de M73 |
| Determinismo roto tras regen 80/0 | M10 recalcula anclas con la misma semilla derivada; test de regen incluido en checklist |
| Carga de isla vecina al navegar el borde | Fronteras de streaming definidas por radio de isla + margen de chunk (M63); precarga al entrar en zona de borde |

## 5. Conclusión

El archipiélago vive dentro de un único mundo voxel navegable, con Aurora como ancla central siempre cargada y satélites streaming-ables, posicionadas por las anclas de generación de M10 y navegadas a través del océano de M51 con el barco de M28. El módulo M27 paga principalmente metadatos (definiciones, registro, anclas) y orquestación de carga (IslandLoading) sobre infraestructura ya especificada por M08/M10/M51/M63.