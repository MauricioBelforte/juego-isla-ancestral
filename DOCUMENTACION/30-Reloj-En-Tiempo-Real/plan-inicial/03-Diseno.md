**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 30: Reloj en Tiempo Real

## 1. Arquitectura

```
┌─────────────────────────────┐
│  game/clock/GameClock (M29) │ ← única fuente de tiempo
└──────────┬──────────────────┘
           │ lee
┌──────────▼──────────────────┐
│ UI/HUD/WReloj (M30.1)       │ → muestra hora + fecha + estación
└──────────┬──────────────────┘
           │ pruebas
┌──────────▼──────────────────┐
│ tests M112: caso_reloj.tscn │
└─────────────────────────────┘
```

**Principio:** M30 es DISPLAY + POLÍTICA, no crea tiempo. Cero lecturas de `Time.get_unix_time_from_system()` en gameplay.

## 2. Widget de reloj (UI)

| Elemento | Detalle |
|---|---|
| Hora | `HH:MM` (12h/24h configurable en Ajustes M46) |
| Fecha | `Viernes, 12 de Primavera, Año 1` |
| Estación | Ícono (hoja/sol/hoja seca/copo) + color de fondo suave |
| Ubicación | Superior derecha del HUD, desplegable al pasar el cursor |
| Tick | Suscribe a `EventBus.time.hora_cambio` (no polling) |
| Font | M57 (jeroglíficos locales) — localizable |

## 3. Política anti-exploit (documentada en código y aquí)

1. **Regla de oro:** ningún sistema consume `Time.get_*()` del SO para gameplay.
2. **Excepción única:** título cosmético "16 de agosto" en el menú principal (opcional, ocultable).
3. **Persistencia:** el estado de tiempo vive únicamente en `GameState.M29` (jugador lo guarda/carga).
4. **Escritura:** la hora interna solo cambia por `GameClock.pausa()/resume()/avanzar_hasta()`; no hay setters públicos.
5. **Auditoría:** test de M112 verifica que ningún autoload llame a tiempo real (búsqueda estática de `Time.` en código de gameplay).

## 4. Pruebas de fechas límite (design para M112)

| Caso | Escenario | Resultado esperado |
|---|---|---|
| Tick normal | 1 minuto de juego cada segundo real | HH:MM avanza 1 |
| Fin de día | 23:59 → 00:00 | Cambia día, señal `dia_cambio` |
| Fin de mes | Día 28 → día 1 del mes siguiente | Sin error, señal `mes_cambio` (nueva en M29) |
| Fin de año | Día 336 → 1 de Primavera Año 2 | Año incrementa, sin overflow |
| Cambio de estación | Último día de Verano → Otoño | Señal `estacion_cambio` + aviso UI |
| Cumpleaños | Fecha exacta de un vecino | `evento_activado(Cumpleaños)` |
| Persistencia | Guardar 14:32 → cargar | 14:32 exacto |
| Retroceder OS | `Set-SystemTime` 1 día atrás | Sin efecto en el juego |
| Adelantar OS | `Set-SystemTime` 1 mes adelante | Sin efecto en el juego |
| Ausencia | 7 días reales sin jugar | Estado congelado al volver |

## 5. Configuración

- `data/ui/w_reloj.tres`: formato 12h/24h, posición, color de estación.
- `project.godot` (autoload): `GameClock` y `UI_HUD` registrados (M07: ínstancia única).