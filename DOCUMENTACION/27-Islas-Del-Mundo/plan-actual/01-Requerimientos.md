**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 27: Islas del Mundo

## ID del Módulo
- **Código:** M27 (plan maestro: sección 26 — Islas del Mundo)
- **Carpeta:** `DOCUMENTACION/27-Islas-Del-Mundo/`
- **Dependencias:** M28 (Viajes), M29 (Tiempo y Calendario). Relaciones: M08 (Mundo Voxel), M09 (Terreno y Geografía), M10 (Generación del Mundo), M51 (Agua), M61 (Rendimiento), M63 (Cargas y Streaming), M54 (Mapa), M59 (Guardado)
- **Delegable desde:** implementación tras M08/M09/M10 base y presupuestos M61; requiere anclas de generación de M10 y streaming de M63

## 1. Problema

Aurora no es una sola isla: es un archipiélago. Los/as jugadores/as deben poder descubrir, visitar y volver a islas satélite con identidad propia (bioma, clima, flora, fauna, música, NPC y contenido exclusivo), conectadas por un océano voxel navegable con barco (M28). El módulo define qué islas existen, dónde anclan en el mundo (M10), cómo se cargan/descargan (M63), qué contenido exclusivo aportan y cómo garantiza que visitar cada isla sea una experiencia cozy y sin frustración (sin contenido perdible, viajes opcionales y sin bloqueos duros).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Archipiélago | Sistema de islas: 1 isla principal (Aurora) + 12 satélites definidas (Coral, Verde, Cenizas, Cielo, Nieve, Desierto, Volcánica, Submarina, Flotante, Misteriosa, Pequeña, Secreta) |
| RF2 | Definición por isla | Cada isla tiene identidad: bioma base y mezcla (M09), altura y forma de terreno, semilla de losa, posición ancla (M10), radio, playas |
| RF3 | Anclas de generación | Cada isla se posiciona mediante anclas de mundo del generador (M10): centro, radio, orientación; las anclas se validan contra colisiones entre islas |
| RF4 | Océano navegable | Entre islas existe océano voxel (M51) navegable con barco (M28); la distancia entre islas es navegable sin transición de carga por isla (streaming M63) |
| RF5 | Viaje por barco | El puerto de cada isla se integra con M28: embarque, travesía opcional, desembarque en isla destino con punto de llegada anclado |
| RF6 | Contenido exclusivo | Cada satélite aporta contenido exclusivo: flora/recursos únicos, fauna endémica, NPC residentes, arquitectura y música propias, puzzles y recompensas |
| RF7 | Punto de llegada | Cada isla define un puerto/desembarco con POI de llegada (muelle), plaza o faro como punto de spawn al visitarla |
| RF8 | Descubrimiento | Las islas se descubren progresivamente (visita previa o avistamiento narrativo); el mapa (M54) registra islas descubiertas y visitadas |
| RF9 | Determinismo | La posición, forma y distribución de las islas se deriva de la semilla de partida (PRNG M10): misma semilla, mismo archipiélago |
| RF10 | Streaming de islas | Una isla satélite se carga incrementalmente cuando se aproxima (M63) y se descarga (LRU) cuando se aleja; la isla principal siempre cargada |
| RF11 | Estado persistente | Progreso por isla (descubierta, visitada, sellos/cofre del sello de isla) se persiste en GameState (M59) |
| RF12 | Regreso seguro | Siempre hay forma camaraderil de volver a la isla principal: viaje de retorno gratuito y sin penalización |

## 3. Requisitos No Funcionales

- **Cozy:** viajar es opcional; ninguna recompensa crítica vive exclusivamente en una isla de difícil acceso; sin FOMO estacional por isla.
- **Rendimiento (M61):** a lo sumo 2 islas completas en memoria a la vez (actual + destino); las demás como metadatos sin voxel cargado.
- **Streaming (M63):** carga incremental con progreso real por pesos; descarga LRU con tope de memoria; cero congelamientos por encima del frame budget en viajes.
- **Determinismo:** anclas y formas de islas derivadas del PRNG de partida (M10); validación de archipiélago al generar.
- **Regeneración (M10 regen 80/0):** si se regenera el mundo, las anclas de islas se recalculan de forma consistente con la nueva semilla.
- **Pausa (M29):** el reloj se congela durante travesías largas si el jugador lo requiere; sin desincronizar calendario.

## 4. Criterios de Aceptación

1. Catálogo de 13 islas definidas con bioma, clima y contenido exclusivo.
2. Anclas de generación M10 consistentes: ninguna isla se superpone a otra ni al templo subterráneo (M26).
3. Viaje de ida y vuelta por barco (M28) funcionando con streaming (M63) sin caídas de frames.
4. Contenido exclusivo por isla verificado: al menos 1 recurso/flora/fauna/puzzle único por satélite.
5. Estado persistido (M59) de descubrimiento y visita tras reiniciar el juego.
6. Determinismo verificado: misma semilla → mismo archipiélago; regen 80/0 no rompe anclas.
7. Delegable para implementación.

## 5. Alcance

- **Incluye:** definición de islas, registro de archipiélago, anclas, carga/descarga, props, integración con viajes, agua, generación y streaming.
- **No incluye (otros módulos):** barco/transporte (M28, M67, M68), físicas de agua y olas (M51), generador de biomas (M09/M10), navmesh de islas (M09/M64), mapa UI (M54), puzzles de islas (M23/M24).
---

## 6. EXPANSIONES DEL MODULO 158 (2026-08-22)

### 6.1 Profesiones por Isla

Cada isla satelite tiene una profesion especializada que la identifica:

| Isla | Profesion | Profesional | Herramienta |
|------|-----------|-------------|-------------|
| Principal (Aurora) | Carpinteria | Carpintero | T1 (Madera) |
| Isla 2 (Coral) | Herreria | Herrero | T2 (Cobre) |
| Isla 3 (Verde) | Herreria Avanzada | Herrero Avanzado | T3 (Hierro) |
| Isla 4 (Cenizas) | Encantamiento | Encantador | T4 (Encantada) |

### 6.2 Precios Progresivos por Isla

Los precios de herramientas y cursos aumentan progresivamente entre islas. Esto motiva al jugador a explorar todas las islas y no quedarse en una sola.

### 6.3 Construccion en Otras Islas

El jugador puede construir casas en islas visitadas (usando M17). Esto le permite quedarse a trabajar en otra isla y tener una base de operaciones alli.

### 6.4 Identidad Visual por Isla

Cada isla tiene una identidad visual unica que refleja su profesion:
- Principal: madera, naturaleza, calidez
- Isla 2: metal, fragua, fuego
- Isla 3: vegetacion densa, misterio
- Isla 4: cristal, magia, ethereal
