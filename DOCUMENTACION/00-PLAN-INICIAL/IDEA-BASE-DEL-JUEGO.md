# Documento Maestro de Diseño de Juego (GDD): PROYECTO ISLA ANCESTRAL (Cozy Voxel Explorer)

Este documento define la arquitectura maestra, la jugabilidad y la integración de sistemas para un videojuego que fusiona la vida comunitaria y relajada (**Cozy Simulation**), la construcción y modificación libre del terreno (**Voxel Sandbox**), la resolución de misterios y acertijos ambientales (**Action-Adventure / Puzzle**) y la exploración estacional a gran escala.

---

## 1. Visión General del Proyecto

* **Título Provisorio:** *Proyecto Isla Ancestral*
* **Género:** Cozy Voxel / Life Simulation / Puzzle Adventure
* **Cámara / Perspectiva:** Tercera persona con perspectiva cenital inclinada y control de cámara libre.
* **Tono Visual y Auditivo:** Cálido, paleta de colores pastel, iluminación global suave (*URP*), música acústica/lo-fi en tiempo real y efectos de sonido satisfactorios (*ASMR*).
* **Filosofía de Juego:** Ausencia total de combate, muerte o penalizaciones violentas. El foco está en la construcción, el diseño, la resolución de acertijos, la comunidad y el descubrimiento.

---

## 2. El Bucle de Juego Principal (Core Loop)

┌────────────────────────────────────────────────────────────────────────┐
│                        BUCLE DIARIO (20 - 45 min)                      │
│ Picar/Recolectar recursos voxel ➔ Decorar pueblo y hablar con vecinos  │
│          ➔ Vender excedentes y pagar mejoras de infraestructura        │
└───────────────────────────────────┬────────────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────────────────────┐
│                        BUCLE SEMANAL (Misterios)                       │
│ Explorar ruinas/templos subterráneos ➔ Resolver acertijos ambientales  │
│            ➔ Obtener herramientas de aventura y Reliquias              │
└───────────────────────────────────┬────────────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────────────────────┐
│                       BUCLE MENSUAL (Expansión)                        │
│ Comprar el Paje/Boleto Transoceánico ➔ Abordar el Buque o Dirigible   │
│ ➔ Explorar una nueva isla temática ➔ Desbloquear vecinos y flora rara  │
└────────────────────────────────────────────────────────────────────────┘


---

## 3. Desglose de Sistemas Integrados

### A. El Mundo Voxel Modificable (Inspiración Sandbox)
* **Construcción y Deconstrucción Libre:** El terreno está formado por bloques tridimensionales ($1 \times 1 \times 1$ metros). El jugador puede extraer tierra, piedra, madera y arena, o colocarlos para modelar montañas, valles, caminos o la estructura de sus casas.
* **Estética "Cozy Voxel":** Aunque el terreno es de bloques, los objetos de decoración, los muebles, la vegetación y los personajes son modelos 3D estilizados, redondeados y detallados.
* **Herramientas de Modificación:**
  * *Pala de Terracería:* Modifica bloques de tierra y césped.
  * *Pico de Minería:* Extrae piedra y minerales para crafteo.
  * *Hacha de Tala:* Permite podar o recolectar madera limpia sin destruir los árboles.

### B. Vida Comunitaria, Economía e Infraestructura (Inspiración Cozy Simulator)
* **La Isla Inicial:** El jugador comienza en una pequeña isla desierta con una tienda de campaña. Su objetivo es convertirla en una próspera comunidad.
* **El Administrador (Finneas) y las Hipotecas:** Un NPC organizador ofrece ampliar la casa y construir puentes o rampas a cambio de la moneda local.
* **Economía Doble:**
  * **Gemas de Ámbar (Moneda Principal):** Se ganan vendiendo frutas, minerales, artesanías y peces. Se usan para pagar casas, muebles, ropa y obras del pueblo.
  * **Pases de Mérito (Moneda Secundaria):** Se obtienen cumpliendo tareas diarias sencillas (ej: *"Planta 3 flores"*, *"Habla con 2 vecinos"*).
* **Vecinos y Afecto:** Animales y personajes con arquetipos de personalidad únicos (el soñador, el entusiasta, el sabio) que se mudan a la isla, reaccionan al entorno de bloques que construyes y te entregan regalos al aumentar el nivel de amistad.

### C. Acertijos, Templos y Misterios (Inspiración Action-Adventure)
Dado que **NO HAY COMBATE NI PELEAS**, la progresión en los templos subterráneos de la isla se basa 100% en la **lógica y la observación**:
* **Ruinas Ancestrales Subterráneas:** Bajo la isla existen estructuras antiguas de bloques de piedra con puertas cerradas, canales de agua y estatuas.
* **Mecánicas de Acertijo:**
  * *Redes de Luz y Espejos:* Girar bloques reflejantes para guiar haces de luz hacia receptores.
  * *Placas de Presión y Bloques Deslizantes:* Empujar bloques especiales sobre interruptores para abrir puertas.
  * *Herramientas de Aventura (Sin daño):*
    * **Gancho Mecánico:** Para engancharse a postes lejanos y cruzar abismos.
    * **Lanza-Semillas / Bumerán:** Para activar botones fuera de alcance.
    * **Varas de Flujo:** Para congelar o evaporar agua en canales.
* **Recompensas de los Templos:** Al resolver un templo se obtienen **Fragmentos de Sello**, **Recetas de Muebles Ancestrales** y la posibilidad de adquirir los **Boletos Especiales**.

### D. El Sistema de Viaje Mensual y Expansión del Mapa (Inspiración Monster-Catching RPG)
* **El Evento del Medio de Transporte (1 vez al mes real):**
  * El día 1 de cada mes (o mediante una fecha fija en el reloj en tiempo real), un **Gran Vapor Marino** o un **Dirigible Antiguo** atraca en el puerto de tu isla y permanece allí durante unos días.
* **Boletos Transoceánicos (Pases de Expedición):**
  * Para poder abordar y viajar a una nueva isla, el jugador debe comprar el **Boleto de Pasaje**.
  * **Requisito para el Boleto:** No solo se compra con Gemas de Ámbar; requiere haber resuelto el misterio/templo correspondiente del mes anterior (demostrando haber obtenido el *Fragmento de Sello* necesario).
* **Nuevas Islas y Biomas Extranjeros:**
  * Cada viaje te lleva a una isla totalmente diferente (isla de nieve, isla volcánica pacífica, isla de vegetación gigante, isla de ruinas flotantes).
  * En estas islas puedes encontrar:
    * Nuevas especies de vegetación y frutas exóticas para llevar a tu isla principal.
    * Muebles y materiales únicos.
    * Nuevos pobladores/vecinos que puedes convencer de mudarse a tu isla principal.

---

## 4. Resumen de Flujo del Jugador (Player Journey)

1. **Mes 1 (Inicio):** Llegas a la Isla Base. Aprendes a picar bloques, hacer tu primera casa, hablar con tus primeros 2 vecinos y pagar la primera cuota.
2. **Semana 2-3:** Descubres una grieta en las montañas de tu isla. Entras a un templo ancestral sin enemigos, resuelves los acertijos de luz y botones usando el *Gancho Mecánico* y obtienes el *Sello de Brisa*.
3. **Día 1 del Mes 2:** El Gran Vapor atraca en el puerto. Usas tus Gemas de Ámbar y el *Sello de Brisa* para comprar el **Boleto a las Islas de Coral**.
4. **Viaje:** Exploras la nueva isla, descubres una fruta tropical nueva, invitas a un vecino robot a tu pueblo y juntas materiales raros antes de regresar a seguir expandiendo tu hogar.

---

## 5. Directivas de Desarrollo e IA

1. **Prioridad al Rendimiento de Bloques:** El sistema de voxeles debe optimizarse mediante la renderización única de caras visibles (*mesh culling*) para garantizar fluidez a 60 FPS en Unity o Godot.
2. **Cero Violencia en la Interfaz:** Las herramientas no tienen estadísticas de daño o ataque. Solo tienen valores de "Eficacia de Recolección" o "Alcance de Acertijo".
3. **Sostenibilidad del Contenido:** Cada isla mensual debe utilizar el mismo sistema modular de bloques y acertijos, cambiando únicamente los materiales de las texturas, la paleta de colores y el tipo de recompensa.