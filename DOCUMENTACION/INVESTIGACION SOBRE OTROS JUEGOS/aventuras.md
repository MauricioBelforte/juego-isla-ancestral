
# Documento Maestro de Diseño de Juego (GDD): El Universo y la Arquitectura de un Action-Adventure y Mazmorras (Dungeon-Crawler)

Este documento constituye una guía exhaustiva, técnica y conceptual sobre las mecánicas, la resolución de acertijos ambientales, el combate de acción en tiempo real y el diseño de mazmorras del género **Action-Adventure y Exploro-Mazmorras**. Está diseñado como marco permanente de referencia para Inteligencia Artificial y desarrolladores.

---

## 1. Núcleo Conceptual y Filosofía de Diseño

Este género se centra en el viaje de un héroe o explorador a través de un reino en ruinas, combinando la exploración libre con la superación de templos y mazmorras repleteras de acertijos mecánicos y combates tácticos:

*   **Diseño de Bloqueo por Ítems (*Item-Based Gating* / *Metroidvania Inverso*):** La progresión en el mapa no depende de niveles o puntos de experiencia, sino de descubrir reliquias y herramientas especiales (ej: el gancho, las bombas, el bumerán) que abren nuevas rutas en el mundo y resuelven acertijos en las mazmorras.
*   **Diseño de Mazmorras de "Cerradura y Llave" (*Lock and Key Design*):** Estructura de mapas complejos e interconectados con llaves pequeñas, llaves maestras, acertijos de botones, antorchas, espejos y jefes de área.
*   **Sensación de Misterio y Leyenda:** Narrativa ambiental expresada en ruinas, escrituras antiguas, diarios perdidos, mecánicas secretas que el jugador descubre por observación directa y secretos ocultos tras paredes resquebrajadas.

---

## 2. El Bucle de Juego de Tres Niveles (Core Game Loop)

El flujo de interacción conecta el mundo exterior (*Overworld*) con el interior de los templos ancestrales (*Dungeons*):

┌────────────────────────────────────────────────────────┐
│                   BUCLE MICRO (Minutos)                │
│ Esquivar/Atacar enemigo ➔ Resolver acertijo de sala    │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                   BUCLE MESO (Horas)                   │
│ Explorar Mazmorra ➔ Hallar Ítem Clave ➔ Vencer Jefe     │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                  BUCLE MACRO (Días)                    │
│ Reunir Reliquias ➔ Desbloquear Castillo/Templo Final   │
└───────────────────────────┴────────────────────────────┘


---

## 3. Desglose Detallado de Sistemas y Mecánicas

### A. Combate de Acción en Tiempo Real (*Real-Time Combat*)
*   **Control del Héroe:** Ataque básico con espada/daga, ataque cargado circular (360°), bloqueo con escudo y esquiva con rodamiento/paso lateral.
*   **Enfoque de Blanco (*Lock-On System*):** Centra la cámara y los movimientos alrededor de un enemigo específico para mantener una guardia táctica.
*   **Barra de Resistencia/Energía:** Limita la cantidad de rodamientos, ataques cargados o uso de habilidades de movilidad consecutivas.
*   **Contenedores de Vitalidad (Corazones/Gemas de Vida):** La salud se expande encontrando *Fragmentos de Corazón* o *Gemas de Vida* escondidas en cofres o como recompensa tras derrotar jefes.

### B. Herramientas de Aventura y Acertijos Ambientales
Las herramientas son funcionales tanto para la exploración de mazmorras como para el combate:

| Herramienta | Uso en Acertijos y Mapa | Uso en Combate |
| :--- | :--- | :--- |
| **Garra Retráctil / Gancho** | Engancharse a postes de madera para cruzar abismos. | Atraer enemigos pequeños o quitarles el escudo. |
| **Bombas de Pólvora** | Romper paredes con grietas o rocas que bloquean accesos. | Infligir gran daño de área a enemigos blindados. |
| **Bumerán Estelar** | Activar interruptores lejanos o traer objetos flotantes. | Paralizar momentáneamente a los enemigos. |
| **Cetro del Fuego/Hielo** | Encender antorchas apagadas o congelar fuentes de agua. | Infligir estados elementales de quemadura o congelamiento. |
| **Lente de la Verdad / Visor Áurico** | Revelar pasadizos invisibles, plataformas ocultas o falsas paredes. | Detectar debilidades o enemigos invisibles. |

### C. Arquitectura de Mazmorras (*Dungeon Structure*)
Una mazmorra típica se compone de los siguientes elementos estructurales:
1.  **Entrada y Mapa/Brújula:** Hallar el plano de la mazmorra y un indicador de cofres clave.
2.  **Llaves Menores:** Ítems consumibles que abren puertas cerradas dentro de la misma mazmorra.
3.  **El Tesoro Central (Ítem de la Mazmorra):** La herramienta especial oculta en el corazón del templo que permite resolver la segunda mitad de los acertijos del lugar.
4.  **La Llave Maestra / Gran Sello:** Abre la puerta de la sala del Guardián/Jefe.
5.  **El Guardián (Jefe de Mazmorra):** Un combate dividido en fases donde la mecánica para infligir daño requiere usar hábilmente la nueva herramienta obtenida en la mazmorra.

### D. Misterios, Secretos y Lore Ambiental
*   **Canciones / Melodías Místicas:** Usar un instrumento musical (ej: ocarina, flauta, arpa) tocando secuencias de notas para alterar el clima, cambiar el tiempo de día/noche, teletransportarse o abrir puertas sagradas.
*   **Símbolos y Jeroglíficos:** Pistas visuales grabadas en paredes que indican el orden en que se deben presionar botones o encender antorchas.
*   **Interacciones Físicas con el Entorno:** Cortar hierba para encontrar recursos, empujar estatuas sobre placas de presión o usar espejos para reflejar haces de luz hacia receptores.

---

## 4. Elementos Clave para Integrar en Nuestro Juego Híbrido (*Cozy Voxel*)

Para fusionar este universo con nuestro juego de **Bloques 3D + Vida Social + Criaturas**:

1.  **Mazmorras y Tempos Ocultos en el Mundo Voxel:**
    *   Bajo la superficie de tu isla o pueblo de bloques existen ruinas antiguas procedimentales y templos llenos de trampas, bloques deslizantes y acertijos de luz/fuego.
2.  **Crafteo de Herramientas de Aventura con Materiales Voxel:**
    *   Picar minerales raros en el mundo de bloques para craftear el *Gancho de Cobre*, la *Barra de Lanzamiento* o las *Bombas de Minería*.
3.  **Criaturas Apoyando en Acertijos:**
    *   Tus criaturas o mascotas pueden ayudarte a resolver misterios en los templos (ej: una criatura eléctrica que enciende un generador o una criatura pesada que se para sobre un botón de presión).
4.  **Tesoros de Mazmorras para Decora tu Pueblo:**
    *   Las recompensas por superar templos y resolver misterios pueden ser **Recetas de Muebles Ancestrales**, **Reliquias para la Gran Galería (Museo)** o **Estructuras Únicas** que atraen a vecinos especiales al pueblo.

---

## 5. Matriz de Directivas para la Generación de Contenido por IA

Cualquier modelo de IA que utilice este marco debe seguir rigurosamente estas reglas:

1.  **Diseño Amigable e Intuitivo:** Cada acertijo debe enseñar su mecánica primero en un entorno seguro antes de combinarla con peligros o tiempo límite.
2.  **Recompensas Claramente Visibles:** Siempre mostrar el cofre o el objetivo bloqueado al entrar a una sala para que el jugador entienda qué debe resolver.
3.  **Coherencia Visual de Pistas:** Las paredes destruibles deben tener una textura distintiva y los objetos interactivos deben destacar sutilmente sobre el entorno.
4.  **Integración con el Mundo Abierto:** Las herramientas obtenidas en las mazmorras siempre deben abrir atajos o secretos en el mapa principal (*Overworld*).