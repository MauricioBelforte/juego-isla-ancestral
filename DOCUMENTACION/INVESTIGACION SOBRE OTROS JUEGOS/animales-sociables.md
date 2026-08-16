
# Documento Maestro de Diseño de Juego (GDD): El Universo y la Arquitectura de un Cozy Social Simulator

Este documento constituye una guía exhaustiva, técnica y conceptual sobre las mecánicas, los bucles de interacción, la economía y la psicología detrás del género **Cozy Social Simulator**. Está estructurado para servir como contexto permanente de referencia para modelos de Inteligencia Artificial, agentes de programación y diseñadores de juegos.

---

## 1. Núcleo Psicológico y Filosofía de Diseño

Este proyecto pertenece al género **Cozy Social Simulation** y basa su éxito en el cumplimiento de necesidades psicológicas clave:

*   **Pacing asíncrono y en Tiempo Real (24/7):** El juego está sincronizado con el reloj del sistema (365 días, ciclo día/noche real). No existen aceleradores de tiempo nativos (salvo alterar el reloj de la consola/PC).
*   **Ausencia de Presión y Fricción (*Zero Stress*):** No hay mecánicas de hambre, muerte, daño permanente ni penalizaciones financieras por impago de deudas.
*   **Concepto del *Imagination Gap* y *Trigger of Play*:** Diseñado para sesiones diarias breves (20 a 45 minutos) que generan hábito mediante eventos cambiantes cada día.
*   **Autoexpresión y Pertenencia:** El mundo es un lienzo totalmente moldeable donde el jugador construye su "refugio ideal".

---

## 2. El Bucle de Juego de Tres Niveles (Core Game Loop)

El flujo de interacción se estructura en tres escalas de tiempo interconectadas:

┌────────────────────────────────────────────────────────┐
│                   BUCLE MICRO (Minutos)                │
│ Recolectar (pesca, bichos) ➔ Inventario ➔ Vender      │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                   BUCLE MESO (Diario)                  │
│ Revisar tiendas ➔ Hablar con vecinos ➔ Pagar hipoteca │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                  BUCLE MACRO (Semanas/Meses)            │
│ Cambios de estación ➔ Eventos ➔ Completar el Galería   │
└───────────────────────────┴────────────────────────────┘


---

## 3. Desglose Detallado de Sistemas y Mecánicas

### A. Economía Doble (Dual Currency System)
1.  **Gemas de Ámbar / Ambers (Moneda Principal):**
    *   **Mecanismo de Entrada:** Venta de recursos (peces, insectos, frutas, madera, fósiles, artesanías) en el almacén central.
    *   **Mecanismo de Salida:** Pago de hipotecas a **Finneas (el Administrador)**, compra de muebles/ropa, obras públicas (puentes, rampas) y remodelación del terreno.
    *   **Mercado Cambiario (Especulación):** Compra de **Lirio-Bulbos** los domingos por la mañana para venderlos entre lunes y sábado a precios fluctuantes (mecanismo inspirado en la bolsa de valores).
2.  **Pases de Expedición / Puntos de Éxito (Moneda Secundaria):**
    *   Recompensan acciones cotidianas del jugador (ej: "Pesca 3 peces", "Tala 5 árboles").
    *   Evitan que el jugador se quede "sin nada que hacer" cuando no tiene dinero.
    *   Se canjean por recetas exclusivas, billetes de viaje a zonas inexploradas (*Tickets de Expedición*) y mejoras de inventario.

### B. Sistema de Herramientas, Durabilidad y Recursos
*   **Tier de Herramientas:** Frágiles (se rompen tras N usos), Estándar, de Cristal (máxima durabilidad).
*   **Herramientas Clave:**
    *   *Pala de Mano:* Excavación de fósiles, golpeo de rocas para extraer minerales, trasplante de árboles y flores.
    *   *Caña de Pescar:* Activación mediante minijuego de reacción/sonido cuando el pez sumerge el flotador.
    *   *Red de Caza:* Para captura de bichos y sacudir árboles (pueden caer avispas o muebles).
    *   *Hacha de Tala:* Tala ligera (para madera) y tala pesada (para derribar árboles).
    *   *Garfio y Escala:* Herramientas de movilidad para cruzar ríos y subir acantilados antes de construir infraestructura.

### C. Botánica, Jardinería y Ecosistemas
*   **Árboles Frutales:** Fruta nativa (precio base) vs. Fruta exótica (precio 5x superior). Las frutas se regeneran cada 3 días reales.
*   **Sistema de Hibridación de Flores:** Regar flores adyacentes de la misma especie permite cruzamientos genéticos para obtener colores raros (ej: orquídeas negras, azules, púrpuras).
*   **Rocas de Recursos:** Existen rocas fijas en el mapa que al ser golpeadas consecutivamente sueltan piedra, arcilla, hierro, pepitas de oro o gemas (1 roca de tesoro al día).

### D. Red Social y Arquetipos de Vecinos (NPCs)
La comunidad está formada por animales antropomórficos agrupados en **Arquetipos de Personalidad** fijos:
*   **Masculinos:** Atletismo (*Athlete*), Refortunado (*Cranky*), Erudito (*Scholar*), Soñador (*Dreamer*).
*   **Femeninos:** Empática (*Kind*), Elegante (*Glamour*), Entusiasta (*Energetic*), Tutelar (*Guardian*).

**Sistemas de Interacción Social:**
*   **Nivel de Amistad (0 a 255 pts):** Aumenta mediante conversación diaria, entrega de regalos envueltos y resolución de misiones (buscar objetos perdidos, entregar paquetes).
*   **Recompensas Sociales:** Al alcanzar la amistad máxima, el vecino entrega su **Retrato Enmarcado** (el objeto coleccionable social más valioso del juego).
*   **Dinámica de Población:** Un máximo de 10 vecinos simultáneos. Periódicamente, un vecino manifestará su deseo de mudarse, permitiendo la rotación de la población.

### E. La Gran Galería (Museo y Coleccionismo)
La Gran Galería actúa como el "Hub de Progreso" a largo plazo:
*   **4 Galerías:** Acuática (Agua Dulce y Mar), Entomología (Insectos/Bichos), Abisal (Buceo/Fauna marina) y Reliquias/Arte.
*   **Disponibilidad Estacional:** La fauna cambia dinámicamente mes a mes y según la hora del día (Hemisferio Norte vs. Hemisferio Sur).
*   **Cero Duplicados:** La primera captura/hallazgo se dona a la Galería. Las copias subsiguientes se venden para generar ingresos.

### F. Personalización, Construcción y Edición del Terreno
*   **Decoración Exterior e Interior:** Cientos de sets de muebles organizados en grillas (1x1, 2x1, 2x2).
*   **Diseños de Lienzo (Pixel Art):** Editor integrado de 32x32 píxeles para crear patrones aplicables a ropa, pisos, paredes, banderas y cuadros.
*   **Moldeo de Entorno (*Terrain Editor*):** Permite modificar el terreno en bloques 3D: elevar/destruir montañas, crear/rellenar ríos y colocar caminos de piedra, madera o tierra.

---

## 4. Estructura de Eventos y Visitantes Especiales

Para romper la rutina diaria, el juego utiliza **Visitantes Ambulantes** que aparecen aleatoriamente de lunes a viernes:

| Personaje | Función / Mecánica |
| :--- | :--- |
| **Melody (El Bardo)** | Músico que visita los sábados; da conciertos y regala discos de música. |
| **Nora (La Agrónoma)** | Vende Lirio-Bulbos los domingos por la mañana para el mercado especulativo. |
| **Sora (La Tejedora)** | Vende alfombras, tapices y pisos con textura animada. |
| **Otto y Tina (Los Artesanos)** | Personalización avanzada de muebles y paletas de colores. |
| **Capitán Barnaby** | Aparece desorientado en la costa. El jugador recupera los engranajes de su brújula a cambio de reliquias del mundo. |
| **Finn y Bix** | Compran peces e insectos a 1.5x de su valor y crean esculturas decorativas 3D. |

---

## 5. Matriz de Directivas para la Generación de Contenido por IA

Cualquier modelo de IA que utilice este marco debe seguir rigurosamente estas reglas de diseño:

1.  **Regla de Oro del Tono:** Mantener un lenguaje inocente, apacible, ligeramente absurdo y optimista.
2.  **Ciclos de Gratificación Retardada:** Las recompensas grandes (casas grandes, estatuas, puentes) deben tomar días de esfuerzo acumulado; nunca entregar todo de inmediato.
3.  **Diálogos con Personalidad:** Cada diálogo de vecino debe reflejar 100% su arquetipo (ej: el de Atletismo habla de entrenamientos, el Soñador habla de bocadillos y siestas).
4.  **Mecánicas Intuitivas de 1-Botón:** La interacción en el mundo debe ser realizable con una sola acción limpia (Presionar A para interactuar/usar herramienta).