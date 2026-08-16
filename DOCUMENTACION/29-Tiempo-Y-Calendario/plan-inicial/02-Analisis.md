**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 29: Tiempo y Calendario

## 1. Análisis de los puntos del plan maestro (sección 28)

| # | Punto | Resolución |
|---|---|---|
| 1 | Duración del día | ✅ 24 min (cozy: tiempo suficiente para completar la rutina sin apuro) |
| 2 | Duración de la noche | ✅ 8 min (amanecer 06:00, atardecer 20:00 → 14 h de día) |
| 3 | Amanecer | ✅ 06:00 (azul→naranja, 90 s de gradiente sky, M31) |
| 4 | Atardecer | ✅ 20:00 (naranja→violeta, 90 s) |
| 5 | Hora del juego | ✅ HH:MM dentro del ciclo 24 h de Aurora (reloj UI, M30) |
| 6 | Fecha | ✅ Día/Mes/Año del mundo |
| 7 | Semana | ✅ 7 días: Lun-Mar-Mie-Jue-Vie-Sáb-Dom (nombres locales cable, M149) |
| 8 | Mes | ✅ 4 semanas = 28 días: 12 meses al año |
| 9 | Estaciones | ✅ Primavera, Verano, Otoño, Invierno (3 meses c/u) |
| 10 | Años | ✅ Año contado desde la fundación de Aurora (año 1 = refugio) |
| 11 | Eventos periódicos | ✅ Festivales por estación + visitas mensuales + rutinas diarias |
| 12 | Cumpleaños | ✅ 1 por vecino (M19 lo puebla); se celebra con regalo y gorra (M74) |
| 13 | Festivales | ✅ 4 por año (1 por estación) + 1 anual grande (Festival de las Luces) |
| 14 | Visitas | ✅ 1 visitante/semana (con M27/M28: llegada en barco/Gran Vapor) |
| 15 | Cambios diarios | ✅ Tiendas reabren, cultivos avanzan, NPC se levantan (hooks M19/M33) |
| 16 | Cambios semanales | ✅ Visitante nuevo, pesca/fauna renovación de stock (M36) |
| 17 | Cambios mensuales | ✅ Evento de la Gran Vapor (M28), mercado especial (M39) |
| 18 | Cambios estacionales | ✅ Nieve (M08 nieve estacional), cultivos de estación (M33), fauna (M36) |
| 19 | Evitar frustración temporal | ✅ Regla: contenido por tiempo NUNCA excluyente — si se pierde, repite el ciclo |
| 20 | Repetir eventos importantes | ✅ Festivales anuales re-entrantes; sin evento único perdible |
| 21 | Calendario visible | ✅ UI Calendario: mes actual + días con iconos de evento (M74 consume) |
| 22 | Reloj | ✅ UI Reloj: hora actual + icono de estación (M30) |
| 23 | Transición temporal | ✅ Pasar de día sin pausa; dormir en cama avanza a la mañana (M31⁺) |
| 24 | Comportamiento NPC por hora | ✅ Rutina diaria: hora_inicio/hora_fin por vecino (M19/M64 consumen) |

## 2. Modelo de datos (datos de diseño, no código aún)

```
data/time/time_config.tres
├── DURACION_DIA = 1440 s | DURACION_NOCHE = 480 s
├── AMANECER = 06:00 | ATARDECER = 20:00
├── MESES: [Primavera(marzo-abril-mayo)... 12 nombres (M149)]
├── FESTIVALES: [id, estacion, dia, descripcion, contenido(M74)]
├── CUMLEAÑOS: mapeado por vecino (M19)
└── RUTINAS_NPC: [vecino, hora_inicio, hora_fin, ubicacion]
```

## 3. Decisiones de diseño

- **Tiempo comprimido 1:40** (1 s real = 1 min de juego): 1 h de sesión ≈ 2,5 días de Aurora → el jugador avanza sin sensación de aburrimiento, y el ciclo es cortito para ver estaciones.
- **Pausa de acción:** el reloj corre siempre en sesión; se pausa en: diálogos, crafting, menú de pausa, escenas de carga, cutscenes. La pausa NUNCA descuenta tiempo para el jugador.
- **Offline:** cuando estás offline NO corre el tiempo de juego (a diferencia de cozy con día real, M30 decide). Evita castigo y exploits por manipular el reloj del sistema.
- **Año 1 = fundación del refugio:** lore coherente con la historia de Aurora (M22).
- **Sin lunares ocultos:** las estaciones se anuncian (icono + texto al cambiar); nunca sorpresas que arruinen cultivos (aviso 1 día antes del cambio).

## 4. Tickets de consumo (para delegar)

| Consumidor | Qué le da el módulo |
|---|---|
| M30 (Reloj UI) | `get_hora()`, `get_fecha()` formateadas |
| M31 (Día/Noche) | `fase_del_dia()` → amanecer/día/atardecer/noche |
| M32 (Clima) | `get_estacion()` para patrones de clima |
| M33 (Agricultura) | `get_estacion()`, avisos de cambio estacional |
| M36 (Fauna) | ciclo día/noche + estación → comportamiento |
| M19/M64 (NPC) | rutinas por hora |
| M74 (Eventos) | `proximos_eventos(fecha)`, disparador de festival |
| M71 (Progresión) | hitos por hora/estación |