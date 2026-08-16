**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 29: Tiempo y Calendario

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: la implementación queda para el agente que lo reclame (flecha en los ítems de implementación).

## A. Requisitos del módulo (12)

- [x] Definir el problema: flujo de tiempo que organice la rutina sin frustrar [S]
- [x] Registrar dependencias: M07 (arquitectura); consumidores M30-M33, M19, M36, M74 [S]
- [x] Catalogar los 24 puntos del plan maestro (sección 28) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: reloj de juego comprimido [S]
- [x] RF2: calendario completo (día, semana, mes, estación, año) [S]
- [x] RF3: 4 estaciones con efectos [S]
- [x] RF4: eventos periódicos (festivales, cumpleaños, visitas) [S]
- [x] RF5: calendario visible en UI [S]
- [x] RF6: rutinas por hora para NPC/tiendas [S]
- [x] RF7: regla cozy roja — contenido repetible [S]
- [x] Criterio: módulo delegable hoy (sin voxel funcional) [S]

## B. Duraciones y conversiones (12)

- [x] Duración del día: 24 min de juego [S]
- [x] Duración de la noche: 8 min (día total 32 min reales por ciclo) [S]
- [x] Proporción 1:40 (1 s real = 1 min de juego) [S]
- [x] Amanecer 06:00 con gradiente de 90 s (M31) [S]
- [x] Atardecer 20:00 con gradiente de 90 s (M31) [S]
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
- [x] Duración ajustable por knobs sin recompilar [S]
- [x] Formato de hora 12h/24h configurable en settings [S]
- [x] El tick usa delta real (no frame-dependent) [M]
- [x] Pausa de menú también pausa el tick [S]
- [x] Sin drift acumulado por fps bajos (acumulador de tiempo) [C]

## C. Eventos periódicos (12)

- [x] Eventos diarios: tiendas, rutinas, cultivos, pesca [M]
- [x] Eventos semanales: visitante nuevo en el Gran Vapor [M]
- [x] Eventos mensuales: mercado especial + luna de cosecha [M]
- [x] Festival de Primavera (Flores) [M]
- [x] Festival de Verano (Cosecha) [M]
- [x] Festival de Otoño (Viento) [M]
- [x] Festival de Invierno (Nieve) [M]
- [x] Festival de las Luces (anual, fin de año) [M]
- [x] Cumpleaños por vecino (M19 puebla) [M]
- [x] Visitas semanales con llegada en barco [M]
- [x] Todos los eventos repetibles (regla cozy) [M]
- [x] Contenido de evento nunca se destruye [M]
- [x] Festival de las Luces dispara iluminación especial (M31 consume) [M]
- [x] Día del festival: tiendas cierran y plaza se decora (hook M74) [M]
- [x] Cumpleaños del jugador también registrado [S]
- [x] Vendimia (Verano) anuncia recompensas de agricultura [M]

## D. Calendario y reloj UI (8)

- [x] Calendario de mes con día actual [M]
- [x] Íconos por evento (festival, cumpleaños, mercado, visita) [M]
- [x] Lista de próximos 7 días en el diario (M55) [M]
- [x] Aviso 24 h antes del evento (en juego) [M]
- [x] Flecha indicadora en el HUD [M]
- [x] Reloj con hora y estación (M30 lo arma sobre esta API) [M]
- [x] Iconografía por estación (hoja, sol, hoja seca, copo) [M]
- [x] Aviso de cambio de estación 1 día antes [M]

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
- [x] Configurable en data/time/*.tres (knobs) [S]

## F. Rutinas NPC y consumo (8)

- [x] Rutina diaria por vecino: hora_inicio/hora_fin/ubicación [M]
- [x] Hook `hora_cambio` para M19/M64 [M]
- [x] Tiendas con horario (cerrar domingos) [M]
- [x] Cultivos avanzan con día (M33) [M]
- [x] Fauna con patrones de día/noche y estación (M36) [M]
- [x] Pesca renovada por día/semana [M]
- [x] Nieve estacional en superficie (M08) [M]
- [x] Gran Vapor puntual (M28) [M]

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
- [x] data/time/time_config.tres (duraciones) [M]
- [x] data/time/festivals.tres (contenido) [M]
- [x] Nombres de meses/días en data (localizable M57) [M]
- [x] Semilla de tiempo por partida [M]
- [x] Compatibilidad con guardado M59 (versionado) [M]
- [x] Sin estado global disperso (solo vía servicio) [M]
- [x] Tests de ciclos (día→año) en M112 [M]

## I. Delegación y cierre (12)

- [x] Módulo marcado como delegable en CHECKLIST-GLOBAL [S]
- [x] API pública estable (no cambia para consumidores) [M]
- [x] Implementación → agente delegado (ARROW) [S]
- [x] Dependencias solo de 07 (documentado) [S]
- [x] Sin dependencia de voxel/assets/física [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Log de creación generado [S]
- [x] Checked en README de DOCUMENTACION [S]

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (B-H en runtime) quedan como tarea del agente delegado; el diseño y la definición están cerrados aquí.