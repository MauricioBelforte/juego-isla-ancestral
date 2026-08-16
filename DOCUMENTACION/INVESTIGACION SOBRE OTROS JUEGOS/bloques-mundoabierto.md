
# Documento Maestro de Diseño de Juego (GDD): El Universo y la Arquitectura de un Voxel Survival Builder

Este documento constituye una guía exhaustiva, técnica y conceptual sobre las mecánicas, los sistemas de generación, el crafteo y la física detrás del género **Voxel Survival Builder**. Está estructurado para servir como contexto permanente de referencia para modelos de Inteligencia Artificial, agentes de programación y diseñadores de juegos.

---

## 1. Núcleo Técnico y Filosofía de Diseño

Este proyecto pertenece al género **Sandbox de Voxel y Supervivencia**, basando su éxito en tres pilares conceptuales:

*   **Mundo Totalmente Destruible y Modificable (Voxel Engine):** Todo el entorno (tierra, piedra, flora, agua) está compuesto por cubos tridimensionales (*voxeles*) que el jugador puede picar, recolectar y colocar libremente en una grilla fija de $1 \times 1 \times 1$ metros.
*   **Generación Procedimental Infinita:** El terreno se genera dinámicamente mediante algoritmos matemáticos (como el *Noise de Perlin* o *Simplex*) creando biomas variados (bosques, montañas, cavernas, desiertos) con semillas únicas (*seeds*).
*   **Emergencia y Libres Decisiones (*Emergent Gameplay*):** No hay una historia fija ni un único camino. El jugador decide si quiere ser un constructor pacífico, un minero explorador, un agricultor o un cazador de jefes finales.

---

## 2. El Bucle de Juego de Tres Niveles (Core Game Loop)

El flujo de interacción se sostiene en un ciclo de progresión tecnológica y exploración:

┌────────────────────────────────────────────────────────┐
│                   BUCLE MICRO (Minutos)                │
│ Picar bloque ➔ Recoger material ➔ Craftear herramienta  │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                   BUCLE MESO (Sesión/Días)             │
│ Explorar cueva ➔ Extraer minerales ➔ Construir base   │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                  BUCLE MACRO (Semanas/Semanas)         │
│ Desbloquear era/tier ➔ Vencer Jefe ➔ Viajar a dimensión│
└───────────────────────────┴────────────────────────────┘


---

## 3. Desglose Detallado de Sistemas y Mecánicas

### A. Progresión Tecnológica y Tiers de Materiales
El progreso del jugador está directamente ligado al material del que están compuestas sus herramientas:

1.  **Tier Madera / Estructura Básica:** Permite picar piedra suave y recolectar recursos superficiales.
2.  **Tier Piedra / Arcilla:** Permite minar vetas de hierro y metales comunes en capas intermedias.
3.  **Tier Hierro / Acero:** Permite extraer gemas de alta dureza, minerales raros y resistir ataques enemigos.
4.  **Tier Cristal ASTRAL / Adamantio (Material Leyenda):** Encontrado en las profundidades máximas o dimensiones alternas; permite minar los bloques más duros del juego y crear equipo definitivo.

### B. Sistema de Crafteo y Mesa de Ensamblaje
*   **Grid de Creación (3x3):** El jugador combina materiales en una matriz espacial. La posición de los objetos en la grilla define el resultado (ej: 2 palos verticales + 3 bloques de hierro horizontales arriba = *Pico de Hierro*).
*   **Módulos Especializados:**
    *   *Mesa de Trabajo:* Desbloquea la grilla compleja de 3x3.
    *   *Horno de Fundición:* Transforma minerales crudos en lingotes mediante el consumo de combustible (carbón, madera).
    *   *Yunque de Encantamiento:* Combina gemas para otorgar propiedades mágicas al equipo (mayor velocidad, luz propia, durabilidad).

### C. Física de Bloques y Red de Energía
*   **Física de Gravedad Selección:** La mayoría de los bloques flotan si se destruye el de abajo (permitiendo arquitectura libre), pero ciertos materiales estructurales como la *Arena* y la *Grava* sí responden a la gravedad y caen si no tienen soporte inferior.
*   **Red de Impulso Luminoso (Circuitería Básica):**
    *   Un mineral especial (*Polvo de Lumen*) actúa como conductor de señal lógica en el mundo.
    *   Permite crear componentes lógicos (puertas AND, OR, temporizadores) para automatizar puertas, trampas, elevadores y granjas de recursos.

### D. Ecosistema, Ciclo Noche/Día y Criaturas (Mobs)
*   **El Riesgo de la Oscuridad:** El mundo opera en un ciclo continuo de luz y sombra (ej. 20 minutos reales = 1 día completo).
*   **Generación de Amenazas por Nivel de Luz:** Cuando el nivel de luz estructural baja de un umbral específico ($< 7$ lumens), el motor genera criaturas hostiles de forma procedural:
    *   *Los Silenciosos (Hostiles explosivos):* Criaturas sigilosas que se acercan al jugador y detonaron destruyendo la infraestructura de bloques cercana.
    *   *Acechadores de las Sombras:* Criaturas altas que se teletransportan y se enfurecen si el jugador las mira directamente.
    *   *Esqueletos Arqueros / Autómatas:* Enemigos a distancia que atacan con proyectiles.

### E. Dimensiones y Progreso de Fin de Juego (*Endgame*)
El mundo overworld está conectado a otros reinos mediante **Portales de Bloques**:
*   **Reino Infernal / Abismo de Fuego:** Accesible construyendo un marco de piedra volcánica endurecida. Contiene recursos únicos para fundición avanzada y criaturas voladoras de fuego.
*   **Dimensión del Vació / El Éter:** El dominio del jefe final. Un archipiélago de islas flotantes en el espacio donde reside el **Dragón Abisal**, cuya derrota otorga la victoria del ciclo y herramientas de vuelo.

---

## 4. Matriz de Directivas para la Generación de Contenido por IA

Cualquier modelo de IA que utilice este marco para programar o diseñar sistemas debe seguir rigurosamente estas reglas:

1.  **Lógica Voxel Absoluta:** Todas las estructuras, coordenadas y físicas de colisión deben estar alineadas a valores enteros de la grilla espacial (Coordenadas $X, Y, Z$).
2.  **Modularidad de Crafteo:** Los objetos creados deben poder desglosarse en sus partes o reciclarse con alguna pérdida de eficiencia.
3.  **Prioridad al Rendimiento (Optimization First):** La generación de chunks de bloques ($16 \times 16 \times 256$ voxeles) debe realizarse de forma asíncrona usando subprocesos (*multithreading*) para evitar congelamientos de pantalla.
4.  **Sensación de Descubrimiento:** Cada nivel subterráneo profundizado debe presentar un cambio de paleta visual, mayor peligro y minerales de mayor rareza.