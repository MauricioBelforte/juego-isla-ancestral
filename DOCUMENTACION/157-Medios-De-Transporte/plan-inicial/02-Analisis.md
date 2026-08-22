**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 02-Analisis.md — Modulo 157: Medios de Transporte

## Analisis por Tipo de Transporte

### Barco (Ship)

**Naturaleza del viaje:** Recorrido costero o inter-islas. Velocidad media. Vistas panorámicas del océano y costa.

**Mecánicas únicas:**
- Navegación por corrientes (el jugador puede influir en la ruta).
- Sistema de clima marítimo (tormentas, niebla, calma chicha).
- Pesca durante el viaje (recurso adicional).
- Avistamiento de fauna marítima (ballenas, tortugas, aves).
- Riesgo de naufragio si se ignora mantenimiento.

**Eventos exclusivos:**
- Tormenta eléctrica (reducir velas, proteger carga).
- Naufragio a la vista (decidir rescatar o ignorar).
- Isla misteriosa (desviarse para explorar).
- Ballena varada (eventos de rescate o recolección).
- Piratas (combate o negociación).
- Contrabando (riesgo legal vs recompensa).
- Tormenta de arena marítima (reducción de visibilidad).
- NPC pescador (comercio, información, misiones secundarias).

**Fortalezas:** Mayor capacidad de carga, acceso a islas remotas, eventos narrativos ricos.
**Debilidades:** Lento, susceptible a clima, requiere puerto de origen y destino.

---

### Tren (Train)

**Naturaleza del viaje:** Recorrido terrestre por vías férreas. Velocidad alta. Paisajes de interior de isla.

**Mecánicas únicas:**
- Movimiento por carril (no hay desviación de ruta).
- Sistema de estaciones (paradas obligatorias o opcionales).
- Compartimento social (interacción con pasajeros NPCs).
- Velocidad constante (eventos basados en posición, no decisión del jugador).
- Sistema de seguridad del tren (robos, sabotajes).

**Eventos exclusivos:**
- Asalto de bandidos en curva (defender el tren).
- Pasajero misterioso (diálogo, puzzle, misterio).
- Túnel oscuro (eventos de horror/suspense).
- Estación abandonada (exploración rápida).
- Daño en vías (reparación de emergencia).
- Comerciante ambulante (comprar/vender durante viaje).
- NPC fugitivo (decidir ayudar o reportar).
- Accidente ferroviario (consecuencias narrativas).

**Fortalezas:** Rápido, seguro (relativamente), social.
**Debilidades:** Ruta fija, requiere infraestructura, costoso.

---

### Avión (Small Plane)

**Naturaleza del viaje:** Vuelo corto sobre la isla. Velocidad muy alta. Vistas aéreas.

**Mecánicas únicas:**
- Vista aérea del mundo (descubrir ubicaciones desde arriba).
- Sistema de combustible (gestión de recurso limitado).
- Navegación manual (el jugador puede desviarse de la ruta).
- Turbulencias (eventos de estrés físico).
- Aterrizaje técnico (mini-game de aterrizaje).

**Eventos exclusivos:**
- Falla de motor (reparación de emergencia en vuelo).
- Avistamiento de ruinas aéreas (descubrimiento).
- Nube tóxica (desviar ruta o atravesar con riesgo).
- Aterrizaje forzado en zona desconocida (eventos de supervivencia).
- Señal de radio misteriosa (investigar origen).
- Tormenta eléctrica (navegar entre nubes).
- Carga sospechosa (contrabando detectado).
- Panorama narrativo (vista del mundo que revela lore).

**Fortalezas:** El más rápido, acceso a áreas inalcanzables, perspectiva única.
**Debilidades:** Combustible limitado, costoso, riesgo de accidente, ruido.

---

### Carreta (Cart)

**Naturaleza del viaje:** Recorrido terrestre lido por animales. Velocidad baja. Contacto cercano con el entorno.

**Mecánicas únicas:**
- Velocidad muy lenta (maximiza oportunidades de evento).
- Contacto con fauna terrestre (observar, evitar, cazar).
- Compañía animal (el animal de tiro tiene personalidad y necesidades).
- Ruta por caminos secundarios (atajos, peligros, secretos).
- Carga limitada pero flexible.

**Eventos exclusivos:**
- Bandidos en el camino (combate o negociación).
- Caravana de comerciantes (comercio, información).
- Mercado ambulante (comprar objetos raros).
- Animal de tiro enfermado (cuidar o buscar reemplazo).
- Fauna salvaje (encuentro cercano, observación).
- Campamento nómada (hospitalidad, misiones).
- Camino bloqueado (buscar desvío).
- Ruinas junto al camino (exploración rápida).

**Fortalezas:** Económico, contacto cercano con el mundo, eventos frecuentes.
**Debilidades:** El más lento, capacidad limitada, vulnerable a bandidos.

---

### A Pie (Walking)

**Naturaleza del viaje:** Recorrido libre a velocidad mínima. Exploración máxima.

**Mecánicas únicas:**
- Libertad total de movimiento (cualquier dirección).
- Fatiga del jugador (necesita descanso, agua, comida).
- Exploración detallada del terreno (descubrir secretos escondidos).
- Interacción directa con el entorno (recoger objetos, observar fauna).
- Sistema de clima ambiental (lluvia, calor, viento).

**Eventos exclusivos:**
- Hallazgo de recurso raro (recolección).
- Encuentro con fauna peligrosa (combate o huida).
- Descubrimiento de atajo secreto (desbloqueo de ruta).
- NPC viajero (diálogo, comercio, misiones).
- Ruinas olvidadas (exploración profunda).
- Tormenta repentina (buscar refugio).
- Pista de misterio (investigar).
- Fatiga extrema (necesidad de descanso).

**Fortalezas:** Total libertad, máxima exploración, sin costo.
**Debilidades:** El más lento, agotador, vulnerable a todo.

---

## Mecánicas de Viaje Transversales

### Sistema de Eventos
- **Frecuencia:** Mínimo 1 evento cada 30 segundos de viaje real, máximo 1 cada 15 segundos.
- **Prioridad:** Eventos de misterio > eventos narrativos > eventos de recurso > eventos de combate.
- **Cooldown:** Un mismo evento no se repite en el mismo viaje.
- **Escalabilidad:** La cantidad de eventos escala con la distancia del viaje.

### Sistema de Misterios
- **Pistas:** Cada misterio tiene 3-5 pistas distribuidas en eventos aleatorios.
- **Progresión:** Las pistas se encuentran en orden (aunque pueden aparecer en cualquier evento).
- **Resolución:** Requiere todas las pistas + una decisión final del jugador.
- **Recompensa:** Recurso raro, desbloqueo de área, NPC aliado, o desbloqueo de transporte.

### Integración con Mundos
- **Biomas:** Los eventos varían según el bioma recorrido (bosque, desierto, costa, montaña).
- **Hora del día:** Algunos eventos solo ocurren de día, otros de noche.
- **Estación del año:** Eventos estacionales (tormentas en otoño, flores en primavera).
- **Progresión del mundo:** Eventos desbloqueados por eventos del mundo principal.

## Alternativas Analizadas

### Alternativa 1: Viaje Automático (Descartada)
- **Descripción:** El jugador selecciona destino y el viaje se resuelve instantáneamente.
- **Pro:** Simple, rápido.
- **Contra:** No cumple el requisito fundamental de que el viaje sea una experiencia jugable.
- **Veredicto:** Descartada por no alinearse con el diseño del juego.

### Alternativa 2: Mini-Game por Tipo (Descartada)
- **Descripción:** Cada tipo de transporte tiene un mini-game único (ej: tetris para el tren).
- **Pro:** Enganchante, diferenciado.
- **Contra:** Desconectado de la narrativa, no permite eventos aleatorios ni misterios.
- **Veredicto:** Descartada por fragmentar la experiencia.

### Alternativa 3: Sistema Híbrido de Eventos (Seleccionada)
- **Descripción:** El viaje es un recorrido en tiempo real con eventos aleatorios, misterios y decisiones.
- **Pro:** Cumple todos los requisitos, extensible, narrativamente rico.
- **Contra:** Complejo de implementar, requiere mucho contenido.
- **Veredicto:** Seleccionada por ser la única que cumple el requisito del usuario.

### Alternativa 4: Viaje con Companion (Descartada)
- **Descripción:** Un NPC acompaña al jugador y narra el viaje.
- **Pro:** Narrativamente rico.
- **Contra:** Limita la autonomía del jugador, requiere sistema de IA complejo.
- **Veredicto:** Descartada como mecánica principal, pero NPCs como eventos son válidos.

## Decisiones de Diseño

1. **Decisión 1:** El viaje será en tiempo real con pausa opcional (no en tiempo de juego加速ado).
   - **Razón:** Permite que el jugador disfrute del paisaje y tome decisiones sin prisa.

2. **Decisión 2:** Cada tipo de transporte tendrá su propio pool de eventos (no compartidos).
   - **Razón:** Diferencia las experiencias y recompensa probar todos los medios.

3. **Decisión 3:** Los misterios serán por viaje, no acumulativos.
   - **Razón:** Evita sobrecarga narrativa y permite mystery-of-the-week.

4. **Decisión 4:** El costo del viaje se deduce al iniciar, no al completar.
   - **Razón:** Evita exploits y simplifica la lógica de persistencia.

5. **Decisión 5:** Los eventos de combate usarán el sistema M19 existente.
   - **Razón:** Reutiliza código probado y mantiene consistencia.

6. **Decisión 6:** La interfaz de viaje será un Canvas overlay (no una escena separada).
   - **Razón:** Permite ver el mundo mientras se viaja, mantiene inmersión.

7. **Decisión 7:** El sistema de transporte se integrará con el sistema de misiones M24.
   - **Razón:** Permite misiones de escolta, transporte de carga, etc.
