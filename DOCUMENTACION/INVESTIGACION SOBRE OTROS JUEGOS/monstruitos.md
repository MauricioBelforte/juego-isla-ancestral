
# Documento Maestro de Diseño de Juego (GDD): El Universo y la Arquitectura de un Monster-Catching RPG (Era 16-Bit / GBA)

Este documento constituye una guía exhaustiva, técnica y conceptual sobre las mecánicas, los sistemas de combate por turnos, la recolección de criaturas, los tipos elementales y la exploración de regiones en el género **Monster-Catching RPG**. Está diseñado como marco permanente de referencia para Inteligencia Artificial y desarrolladores.

---

## 1. Núcleo Conceptual y Filosofía de Diseño

Este género combina la exploración de un mundo en perspectiva cenital (*Top-Down 2D*) con un sistema de combate táctico basado en turnos y un coleccionismo extensivo de criaturas:

*   **Bucle de Aventura y Crecimiento:** El jugador asume el rol de un joven explorador que viaja por una región descubriendo criaturas salvajes, entrenándolas y enfrentando a otros entrenadores para convertirse en el Campeón de la **Liga de Domadores**.
*   **Doble Región y Extensión de Juego:** Tras completar la liga principal, se desbloquea el acceso a una **segunda región completa** (mapa entero de un juego previo o continente vecino), duplicando la duración, los jefes de gimnasio y los secretos.
*   **Identidad de Criaturas (*Gotta Catch 'Em All*):** Decenas de especies únicas con estadísticas propias, tipos elementales, cadenas evolutivas y apariencias distintas.

---

## 2. El Bucle de Juego de Tres Niveles (Core Game Loop)

El flujo de interacción se sostiene en la exploración del mapa, el entrenamiento y la superación de desafíos:

┌────────────────────────────────────────────────────────┐
│                   BUCLE MICRO (Minutos)                │
│ Encontrar criatura salvaje ➔ Combatir/Capturar ➔ Exp  │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                   BUCLE MESO (Horas)                   │
│ Explorar ruta/cueva ➔ Subir nivel ➔ Vencer Gimnasio   │
└───────────────────────────┬────────────────────────────┘
│
▼
┌────────────────────────────────────────────────────────┐
│                  BUCLE MACRO (Semanas)                 │
│ Ganar los 8 Blasones ➔ Vencer Alto Consejo ➔ Región 2 │
└───────────────────────────┴────────────────────────────┘


---

## 3. Desglose Detallado de Sistemas y Mecánicas

### A. Sistema de Combate por Turnos ($1 \text{v} 1$ o $2 \text{v} 2$)
*   **Encuentros Aleatorios en Hierba Alta:** Al caminar por la vegetación o celdas de agua, se activa una transición de pantalla hacia la interfaz de combate.
*   **Matriz Elemental (Ventajas y Desventajas):**
    *   Cada criatura y movimiento posee 1 o 2 tipos (ej: *Fuego, Agua, Planta, Eléctrico, Místico, Sombra, Metal, Tierra, Aire*).
    *   Los ataques aplican multiplicadores de daño: **Superfictivo ($2\times$)**, **Neutro ($1\times$)**, **Resistido ($0.5\times$)** e **Inmune ($0\times$)**.
*   **Límite de Movimientos (4 Slots):** Cada criatura solo puede recordar hasta 4 ataques/habilidades simultáneas, obligando al jugador a tomar decisiones tácticas al subir de nivel.
*   **Puntos de Vigor / Usos (PV):** Cada habilidad tiene una cantidad limitada de usos antes de requerir descanso en un Centro de Curación.

### B. Captura, Cadenas Evolutivas y Crianza
1.  **Cápsulas de Contención / Esferas de Captura:**
    *   Reducir los Puntos de Vida (HP) de la criatura salvaje y aplicarle estados alterados (*Parálisis, Sueño, Congelación*) aumenta el porcentaje de éxito al lanzar una cápsula de captura.
    *   Existen cápsulas con multiplicadores especiales (ej: para criaturas acuáticas, para la noche, o cápsulas de éxito 100%).
2.  **Líneas de Evolución:**
    *   Las criaturas se transforman visual y estadísticamente al alcanzar determinado nivel, usar una *Gema Elemental* especial, o cumplir condiciones de amistad/intercambio.
3.  **Heredero y Crianza en Guardería:**
    *   Dejar dos criaturas compatibles en la guardería genera un **Huevo de Criatura**.
    *   El huevo eclosiona tras caminar una cantidad fija de pasos en el mapa.
    *   Permite heredar movimientos especiales, naturalezas y valores individuales de estadísticas (*Genética/IVs*).

### C. El Reloj Interno y Mecánicas de Día/Noche
*   **Ciclo de Tiempo Real (RTC - Real Time Clock):**
    *   El juego distingue entre *Mañana, Día, Tarde y Noche*.
    *   **Fauna Nocturna:** Ciertas criaturas solo aparecen en estado salvaje durante la noche.
    *   **Evoluciones Temporales:** Criaturas que solo evolucionan bajo la luz de la luna o del sol.
    *   **Días de la Semana:** Eventos fijos que ocurren solo ciertos días (ej: concurso de captura de insectos los martes/jueves, barco de pasajeros los viernes).

### D. Movimientos de Navegación y Vínculo con el Mapa (Técnicas de Entorno)
Ciertos ataques especiales sirven para interactuar con los obstáculos del mapa fuera del combate:

| Técnica | Uso en el Mapa |
| :--- | :--- |
| **Corte de Flora** | Destruye arbustos pequeños que bloquean caminos o secretos. |
| **Fuerza Impulsora** | Empuja rocas pesadas sobre botones o para despejar pasadizos. |
| **Navegación Acuática** | Permite montar sobre una criatura y cruzar ríos, lagos y océanos. |
| **Vuelo de Retorno** | Transporta instantáneamente al jugador a cualquier ciudad previamente visitada. |
| **Cascada Escalable** | Permite subir por saltos de agua verticales para acceder a mesetas altas. |

### E. Infraestructura e Interfaz de Progreso
*   **Enciclopedia de Criaturas (*Creature-Dex*):** Dispositivo portátil que registra automáticamente datos, hábitat, peso, altura y descripción biológica de cada criatura avistada o capturada.
*   **Red de Centros de Sanación y Almacén Digital:**
    *   *Santuario de Curación:* Restaura gratuitamente la salud y los puntos de vigor del equipo (máximo 6 criaturas en mano).
    *   *Terminal PC:* Permite almacenar electrónicamente hasta cientos de criaturas capturadas organizadas en cajas digitales.

---

## 4. Elementos Clave para Integrar en Nuestro Juego Híbrido (*Cozy Voxel*)

Para fusionar este universo con nuestro juego de **Bloques 3D + Vida Social**:

1.  **Capturar y Criar Fauna Voxel:**
    *   En lugar de solo pescar o cazar bichos, podés encontrar criaturas mágicas en el mundo de bloques, hacerte su amigo o capturarlas con ítems crafteados.
2.  **Criaturas que Trabajan en el Pueblo:**
    *   En lugar de solo combatir, las criaturas capturadas pueden **ayudarte en la aldea o finca**: criaturas de fuego que alimentan el horno, criaturas de agua que riegan tus cultivos automáticos, o criaturas terrestres que ayudan a picar bloques en la mina.
3.  **Compañeros de Viaje y Monturas:**
    *   Usar criaturas para desplazarte más rápido por el mundo de bloques (volar sobre islas flotantes o nadar por lagos profundos).
4.  **Crianza en tu Granja Voxel:**
    *   Construir un hábitat de bloques personalizado para que dos criaturas vivan juntas, pongan un huevo y nazca una cría con colores o patrones raros.

---

## 5. Matriz de Directivas para la Generación de Contenido por IA

Cualquier modelo de IA que utilice este marco debe seguir rigurosamente estas reglas:

1.  **Balance de Tipos:** Ningún tipo elemental debe ser invencible; siempre debe existir al menos un contragolpe táctico.
2.  **Progresión Modular:** Los obstáculos del mapa deben impedir el acceso a zonas avanzadas hasta que el jugador obtenga la medalla o habilidad correspondiente.
3.  **Personalidad de Criaturas:** Cada criatura debe contar con un diseño visual claro, una animación de entrada y un rol definido en combate o en la granja (tanque, veloz, atacante o asistente).