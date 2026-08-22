**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 34: Pesca

## ID del Módulo
- **Código:** M34 (plan maestro: sección 33 — PESCA)
- **Carpeta:** `DOCUMENTACION/34-Pesca/`
- **Dependencias:** M51 (Agua), M32 (Clima) según CHECKLIST-GLOBAL. Relaciones: M29 (Tiempo y Calendario), M31 (Ciclo Día/Noche), M37 (Museos y Colecciones), M14 (Inventario)
- **Stack:** Godot 4.x (>= 4.4.1) + Voxel Tools (GDExtension) + GDScript
- **Delegable desde:** hoy (diseño completo; implementación tras M51 y tras M29/M31/M32)

## 1. Problema

Implementar una pesca cozy en un mundo voxel (Isla Ancestral): el jugador equipa una caña, lanza a cualquier superficie de agua válida del terreno (M51, agua voxel con cielo encima), espera una picada regida por tablas de especies (bioma, estación M29, hora M31, clima M32, cebo) y captura el pez con un minijuego de timing indulgente y sin frustración. Las capturas alimentan el inventario (M14), recetas, estadísticas y piezas opcionales de colección para el museo (M37). El fallo nunca debe castigar al jugador: el pez se va y se puede relanzar al instante. Nada de colección es obligatorio ni bloqueante.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Caña equipable | Herramienta M14/barra del jugador; se lanza con botón apuntando al agua; stats: rango, ventana de éxito, espera maxima |
| RF2 | Spots de pesca | Puntos de agua voxel válidos (M51): voxel de tipo AGUA con aire encima y orilla accesible; visibles con marcador sutil (ondulacion/burbujas) |
| RF3 | Lanzamiento del flotador | Trayectoria parabolica del anzuelo (RigidBody3D en Godot) hasta el agua; el flotador queda flotando |
| RF4 | Espera de picada | Tiempos de espera por especie y cebo; nunca tediosa (max 8 s sin cebo, ver NFR) |
| RF5 | Minijuego de timing | 2 fases indulgentes: reaccion a la picada (pantalla vibra) y ventana de pulsacion amplia; fallo = huida sin penalizacion |
| RF6 | Huida indulgente | Si el jugador falla, el pez huye y el anzuelo vuelve; relanzado con 1 clic, sin perdidas de inventario ni dinero |
| RF7 | Tablas de especies | Especie elegida por: bioma de agua (mar, rio, laguna, pozo ancestral), estacion M29, franja horaria M31, clima M32, rareza, cebo usado |
| RF8 | Los 25 puntos del plan | Especies, biomas, horarios, estaciones, clima, rareza, cebos, canas, minijuego, anti-frustracion, animaciones, sonidos, VFX, coleccionario, peces legendarios, peces ancestrales, exclusivos, nocturnos, estacionales, recompensas, recetas, museo, desafios, estadisticas y registro |
| RF9 | Registro y estadisticas | Enciclopedia del jugador: especies vistas/capturadas, mejor tamano, cantidad total, sesiones |
| RF10 | Recompensas | Pez como item M14 (venta y recetas), veces capturado, piezas opcionales para M37, desafios de pesca |

## 3. Requisitos No Funcionales

- **Cozy, cero frustracion:** sin especies que se escapen por skill injusta; ventana de exito minima amplia; sin castigo por fallo; sin esperas tediosas; la lluvia (M32) da bono, nunca bloquea; ninguna especie es fuente unica de progreso obligatorio.
- **Rendimiento (M61):** spots con pooling/registro por chunk; sin queries de voxel en cada frame (solo al lanzar y al validar); UI del minijuego apenas costosa.
- **Determinismo suave:** seleccion de especie por PRNG de partida (M29) para coherencia entre guardados y tests.
- **Pausa con GameClock (M29):** el reloj del minijuego y la espera se congelan al pausar el juego; sin desincronizacion con hora del mundo.
- **Integracion voxel:** validacion de "agua pescable" contra los voxels de M51 (tipo + aire encima + conectividad), nunca contra colliders fisicos.
- **Serializable:** coleccion, estadisticas y mejor tamano guardados en datos de partida (compatible M58).
- **Accesibilidad (M57):** modo "captura automatica" que salta el minijuego; opciones de contraste y reduccion de efectos.
- **Idioma y textos:** toda la UI y nombres de peces localizables (M86).

## 4. Criterios de Aceptacion

1. Los 25 puntos de la seccion 33 del plan maestro quedan resueltos en el diseno.
2. Minijuego indulgente definido con reglas anti-frustracion verificables (ventanas, tiempos, penalizaciones nulas).
3. Integracion definida con M51 (agua voxel), M29/M31/M32 (tablas por estacion/hora/clima), M37 (piezas opcionales, sin requisito obligatorio) y M14 (pez como item, inventario y recetas).
4. Contratos API en GDScript listos para que la implementacion sea delegable sin ambiguedades.
5. Checklist de diseno con mas de 110 items de cobertura (implementacion, integracion, edge cases, optimizacion, documentacion y polish).
---

## 4. EXPANSIONES COZY (2026-08-22)

### 4.1 Pesca Idle (automática)

Inspirado en Tsuki's Odyssey, el jugador puede pescar automáticamente sin interacción constante.

#### Modos de Pesca

| Modo | Control | Recompensa | Calidad |
|------|---------|------------|---------|
| Activo | Minijuego completo | Máxima | 100% |
| Semi-pasivo | Lanza caña, espera automática | Media | 70% |
| Idle | Pescador automático (nivel 3+) | Baja | 40% |

#### Pesca Idle - Reglas

- Solo se desbloquea con hacha/pico nivel 3+ (herramientas avanzadas)
- El personaje va al punto de pesca más cercano automáticamente
- Pesca 1 pez cada 5 minutos de juego (no tiempo real)
- La calidad del pez es baja (pero utilizable en recetas)
- El jugador puede interrumpir en cualquier momento
- No necesita cebo para pesca idle
- No pesca peces raros o legendarios (solo comunes y poco comunes)

#### Integración con Modo Pasivo (M11)

- Si el modo pasivo está activo, el jugador pesca idle automáticamente
- El pez va al inventario directamente
- Si el inventario está lleno, deja de pescar
- Si es de noche, busca un punto seguro para pescar
- Si llueve, busca refugio y vuelve a pescar después

### 4.2 Pesca Social

- Otros NPCs pueden acompañar al jugador a pescar
- Si un NPC pescador está cerca, pesca junto al jugador
- Los peces que pesca el NPC se los puede pedir (trueque o compra)
- Si el jugador le regala un pez a un NPC pescador, sube amistad +3
- Los NPCs pescadores dan consejos que mejoran la calidad del pez (+10%)

### 4.3 Enciclopedia de Pesca (M37)

- Cada pez capturado se registra en la enciclopedia
- La enciclopedia muestra: nombre, bioma, estación, hora, rareza, mejor tamaño
- Completar categorías da recompensas (muebles de pesca,.decoraciones)
- La enciclopedia se puede consultar en cualquier momento
- No es obligatoria (cozy = sin presión de completar)
