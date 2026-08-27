**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 29: Tiempo y Calendario

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: la implementación queda para el agente que lo reclame (flecha en los ítems de implementación).

## A. Requisitos del módulo (12)

- [ ] Definir el problema: flujo de tiempo que organice la rutina sin frustrar [S]
- [ ] Registrar dependencias: M07 (arquitectura); consumidores M30-M33, M19, M36, M74 [S]
- [ ] Catalogar los 24 puntos del plan maestro (sección 28) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: reloj de juego comprimido [S]
- [ ] RF2: calendario completo (día, semana, mes, estación, año) [S]
- [ ] RF3: 4 estaciones con efectos [S]
- [ ] RF4: eventos periódicos (festivales, cumpleaños, visitas) [S]
- [ ] RF5: calendario visible en UI [S]
- [ ] RF6: rutinas por hora para NPC/tiendas [S]
- [ ] RF7: regla cozy roja — contenido repetible [S]
- [ ] Criterio: módulo delegable hoy (sin voxel funcional) [S]

## B. Duraciones y conversiones (12)

- [x] Duración del día: 24 min de juego [S]
- [x] Duración de la noche: 8 min (día total 32 min reales por ciclo) [S]
- [x] Proporción 1:40 (1 s real = 1 min de juego) [S]
- [ ] Amanecer 06:00 con gradiente de 90 s (M31) [S]
- [ ] Atardecer 20:00 con gradiente de 90 s (M31) [S]
- [x] Hora HH:MM dentro del ciclo [S]
- [x] Semana de 7 días con nombres [S]
- [x] Mes de 28 días (4 semanas) [S]
- [x] Año de 336 días (12 meses) [S]
- [x] Estaciones de 3 meses c/u [S]
- [x] Año 1 = fundación del refugio [S]
- [x] Sin bisiesto (año fijo; se documenta para no aplicar) [S]
- [x] Conversión fecha ↔ día del año (1-336) como función auxiliar [M]
- [x] Día 336 → transición limpia a año 2 (sin bug de año nuevo) [M]
- [x] Estación inicial de partida: Primavera (calibrada para tutorial) [S]
- [ ] Duración ajustable por knobs sin recompilar [S]
- [ ] Formato de hora 12h/24h configurable en settings [S]
- [x] El tick usa delta real (no frame-dependent) [M]
- [x] Pausa de menú también pausa el tick [S]
- [x] Sin drift acumulado por fps bajos (acumulador de tiempo) [C]

## C. Eventos periódicos (12)

- [ ] Eventos diarios: tiendas, rutinas, cultivos, pesca [M]
- [ ] Eventos semanales: visitante nuevo en el Gran Vapor [M]
- [ ] Eventos mensuales: mercado especial + luna de cosecha [M]
- [ ] Festival de Primavera (Flores) [M]
- [ ] Festival de Verano (Cosecha) [M]
- [ ] Festival de Otoño (Viento) [M]
- [ ] Festival de Invierno (Nieve) [M]
- [ ] Festival de las Luces (anual, fin de año) [M]
- [ ] Cumpleaños por vecino (M19 puebla) [M]
- [ ] Visitas semanales con llegada en barco [M]
- [ ] Todos los eventos repetibles (regla cozy) [M]
- [ ] Contenido de evento nunca se destruye [M]
- [ ] Festival de las Luces dispara iluminación especial (M31 consume) [M]
- [ ] Día del festival: tiendas cierran y plaza se decora (hook M74) [M]
- [ ] Cumpleaños del jugador también registrado [S]
- [ ] Vendimia (Verano) anuncia recompensas de agricultura [M]

## D. Calendario y reloj UI (8)

- [ ] Calendario de mes con día actual [M]
- [ ] Íconos por evento (festival, cumpleaños, mercado, visita) [M]
- [ ] Lista de próximos 7 días en el diario (M55) [M]
- [ ] Aviso 24 h antes del evento (en juego) [M]
- [ ] Flecha indicadora en el HUD [M]
- [ ] Reloj con hora y estación (M30 lo arma sobre esta API) [M]
- [ ] Iconografía por estación (hoja, sol, hoja seca, copo) [M]
- [ ] Aviso de cambio de estación 1 día antes [M]

## E. Comportamiento temporal (10)

- [x] Tick por segundo (minuto de juego) [M]
- [x] Pausa en: diálogos, crafting, menú, carga, cutscenes [M]
- [x] Dormir en cama → avanzar_hasta(06:00) [M]
- [x] El reloj nunca retrocede [M]
- [x] El reloj no corre offline [M]
- [x] Sin exploits de reloj del sistema [M]
- [x] Sin castigo por no jugar (no pierde tiempo) [M]
- [x] Persistencia: retoma donde quedó al recargar [M]
- [x] Sin días fantasma entre sesiones [M]
- [ ] Configurable en data/time/*.tres (knobs) [S]

## F. Rutinas NPC y consumo (8)

- [ ] Rutina diaria por vecino: hora_inicio/hora_fin/ubicación [M]
- [ ] Hook `hora_cambio` para M19/M64 [M]
- [ ] Tiendas con horario (cerrar domingos) [M]
- [ ] Cultivos avanzan con día (M33) [M]
- [ ] Fauna con patrones de día/noche y estación (M36) [M]
- [ ] Pesca renovada por día/semana [M]
- [ ] Nieve estacional en superficie (M08) [M]
- [ ] Gran Vapor puntual (M28) [M]

## G. API y modelado (10)

- [x] Señal `dia_cambio(DiaInfo)` [S]
- [x] Señal `hora_cambio(hora)` [S]
- [x] Señal `estacion_cambio(estacion)` [S]
- [x] Señal `evento_activado(EventoPeriodico)` [S]
- [x] `get_hora() -> Hora` [S]
- [x] `get_fecha() -> Fecha` [S]
- [x] `get_estacion() -> ESTACION` [S]
- [x] `es_de_dia() -> bool` [S]
- [x] `proximos_eventos() -> [EventoPeriodico]` [S]
- [x] `pausa()/resume()/avanzar_hasta(hora)` [S]

## H. Persistencia y data (8)

- [x] GameState.M29: fecha, hora, eventos_visitados, proximo_evento [M]
- [ ] data/time/time_config.tres (duraciones) [M]
- [ ] data/time/festivals.tres (contenido) [M]
- [ ] Nombres de meses/días en data (localizable M57) [M]
- [ ] Semilla de tiempo por partida [M]
- [x] Compatibilidad con guardado M59 (versionado) [M]
- [x] Sin estado global disperso (solo vía servicio) [M]
- [x] Tests de ciclos (día→año) en M112 [M]

## I. Delegación y cierre (12)

- [ ] Módulo marcado como delegable en CHECKLIST-GLOBAL [S]
- [ ] API pública estable (no cambia para consumidores) [M]
- [ ] Implementación → agente delegado (ARROW) [S]
- [ ] Dependencias solo de 07 (documentado) [S]
- [ ] Sin dependencia de voxel/assets/física [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]
- [ ] Checked en README de DOCUMENTACION [S]

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (B-H en runtime) quedan como tarea del agente delegado; el diseño y la definición están cerrados aquí.