**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 02-Analisis.md — Módulo 69: Fast Travel

## 1. Resolución de los 13 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Definir si existe | Fast travel disponible desde el inicio con restricciones progresivas |
| 2 | Definir puntos de viaje | Los puntos se desbloquean al descubrir ubicaciones; máximo 5 iniciales, expansión ilimitada |
| 3 | Definir requisitos | Requisito de "lugar descubierto" o costo en recursos/tiempo |
| 4 | Definir costes | Cada viaje consume recursos (madera, piedras) o tiempo de juego equivalente |
| 5 | Definir animación | Transición visual suave con efecto de "bruma" que desvanece al destino |
| 6 | Definir pantalla | Pantalla de carga minimalista con nombre del destino y icono de viaje |
| 7 | Definir tiempos | Tiempo de viaje instantáneo pero con "tiempo transcurrido" simulado (opcional) |
| 8 | Permitir cancelar | El jugador puede abortar el viaje al 50% de la animación y regresar |
| 9 | Impedir uso durante ciertos estados | Bloqueado durante combate, diálogos críticos, eventos de clima severo |
| 10 | Guardar último punto | El último destino visitado se recuerda para acceso rápido |
| 11 | Evitar bypass de eventos críticos | El sistema verifica estado global antes de permitir viaje |
| 12 | Evitar ruptura de misiones | Viajes que interrumpan misiones activas son suspendidos con warning |
| 13 | Probar navegación | Verificar que todos los puntos de viaje llevan a destinos válidos |

## 2. Decisiones clave

1. **Fast travel progresivo:** No disponible desde el inicio; se desbloquea tras completar el tutorial y descubrir suficientes puntos del mundo. Fomenta la exploración inicial.

2. **Costo por viaje:** Cada uso consume recursos del inventario (2-5 unidades) o tiempo de juego simulado (15-30 minutos), nunca es "gratis" para mantener la sensación de mundo persistente.

3. **Restricciones por estado:** El sistema verifica el estado actual del jugador (en combate, en diálogo, durante eventos climáticos especiales) y bloquea el fast travel automáticamente sin interrumpir la gameplay.

4. **Integración con M29/M31:** Los tiempos y disponibilidad del fast travel respetan el ciclo día/noche (no disponible durante noches de luna nueva) y eventos del calendario Aurora (fiestas, celebraciones).

5. **Interfaz minimalista:** Menú de viaje con lista de puntos descubiertos, búsqueda por nombre y atajo de teclado (Tecla M rápido).

## 3. Alternativas descartadas

- **Fast travel inmediato desde el inicio:** Permitir teletransportación desde el tutorial descartado; rompe la sensación de mundo conectado yReduce la valorización de los descubrimientos locales.
- **Sin restricciones de estado:** Permitir fast travel durante cualquier situación descartado; riesgo de bypass de eventos críticos y rupturas de misión.
- **Viajes gratuitos infinitos:** Sin costo de ningún tipo descartado; mina la economía de recursos y la progresión cozy de acumulación cuidadosa.
- **Mapa mundial completo al instante:** Revelar todo el mapa descartado; elimina la gradual descubrimiento que es central en el diseño cozy.