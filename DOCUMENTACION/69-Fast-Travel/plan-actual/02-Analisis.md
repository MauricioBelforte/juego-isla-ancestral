**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

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
| 7 | Definir tiempos | Tiempo de viaje con duración real (no instantáneo); eventos durante el trayecto |
| 8 | Permitir cancelar | El jugador puede abortar el viaje al 50% de la animación y regresar |
| 9 | Impedir uso durante ciertos estados | Bloqueado durante combate, diálogos críticos, eventos de clima severo |
| 10 | Guardar último punto | El último destino visitado se recuerda para acceso rápido |
| 11 | Evitar bypass de eventos críticos | El sistema verifica estado global antes de permitir viaje |
| 12 | Evitar ruptura de misiones | Viajes que interrumpan misiones activas son suspendidos con warning |
| 13 | Probar navegación | Verificar que todos los puntos de viaje llevan a destinos válidos |

## 2. Decisiones clave

1. **Fast travel progresivo:** No disponible desde el inicio; se desbloquea tras completar el tutorial y descubrir suficientes puntos del mundo.

2. **Costo por viaje:** Cada uso consume recursos del inventario (2-5 unidades) o tiempo de juego simulado (15-30 minutos).

3. **Experiencia de viaje (M157):** El fast travel YA NO es un teletransporte instantáneo. Cada viaje es una **experiencia jugable** con duración real, eventos aleatorios y misterios por resolver. El jugador elige el medio de transporte (barco, tren, avión, carreta, a pie) y vive el trayecto.

4. **Integración con M157:** FastTravelManager delega la ejecución del viaje a TransportManager (M157), que crea un JourneyInstance con la ruta, transporte y eventos correspondientes.

5. **Misterios por ruta:** Cada ruta entre dos puntos tiene misterios predefinidos que aparecen aleatoriamente durante el viaje. Resolverlos otorga recompensas.

6. **Interfaz minimalista:** Menú de viaje con lista de puntos descubiertos, selección de transporte, y estimación de costo/duración.

## 3. Alternativas descartadas

- **Fast travel instantáneo:** Descartado; rompe la inmersión y reduce el contenido del juego.
- **Sin restricciones de estado:** Permitir fast travel durante cualquier situación descartado; riesgo de bypass de eventos críticos.
- **Viajes gratuitos infinitos:** Sin costo de ningún tipo descartado; mina la economía de recursos.
- **Mapa mundial completo al instante:** Revelar todo el mapa descartado; elimina la gradual descubrimiento.
- **Solo un medio de transporte:** Descartada variedad; barco/tren/avión/carreta/a pie dan diversidad de experiencias.
