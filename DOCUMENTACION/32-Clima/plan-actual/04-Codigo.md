**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 32: Clima

> **Firma vigente (iter. 1):** glm-5.3-flash / Kilo Code — 2026-08-31. Documentación base: Deepseek V4 Flash / OpenCode (2026-08-16).

## 0. Implementación real (Iteración 1, glm-5.3-flash / Kilo Code, 2026-08-31)

### Archivos creados/modificados

| Archivo | Tipo | Rol real |
|---|---|---|
| `res://scripts/clima/weather_service.gd` | Node (autoload **Weather**) | Núcleo determinista: cadena `clima_de_dia(dia)` cacheada, regla cozy de profundos, transición de intensidad por minutos de juego, persistencia M59, API pública |
| `res://scripts/clima/weather_config.gd` | Resource (`class_name WeatherConfig`) | Config data-driven: semilla, ventana de transición, probabilidades por estación, atenuación de sol, duraciones, volúmenes audio, climas profundos |
| `res://data/clima/clima_config.tres` | Data | Valores reales (semilla 7919; 4 estaciones normalizadas a 1.0; atenuación SOLEADO 1.0 → TORMENTA 0.35, NIEVE 1.10; duraciones 2-6 h; climas profundos [TORMENTA, TROPICAL]) |
| `res://scripts/core/event_bus.gd` | Autoload M07 | **Aditivo:** dominio `weather` con señales `clima_cambio(clima)` e `intensidad_cambio(float)` |
| `res://project.godot` | Config | Autoload `Weather` registrado (tras `Fishing`) |
| `res://scripts/dialogos/world_state_service.gd` | Autoload M21 | **Integración:** placeholder `_get_clima()` ahora delega en `/root/Weather.get_nombre_clima()` (contrato `clima:String` respetado, fallback "") |
| `res://scripts/clima/test_clima.gd` | Test headless | 8 grupos de tests; **0 fallos** |

### Decisiones de implementación

1. **Determinismo por cadena recursiva:** `clima(d)` depende de `clima(d-1)` por la regla cozy; se cachea y se reconstruye desde el ancla más baja cacheada. Coste O(n) una vez, O(1) amortizado.
2. **Semilla:** `rng.seed = semilla_clima * 1000003 + dia` (int 64-bit, sin hash de string). Semilla de transición distinta (`+ dia * 31 + 7`) para muestrear los minutos [60, 90].
3. **Intensidad por minuto de juego:** conectada a `GameTime.minuto_cambio` (M30) — sin `_process` propio, se congela con la pausa del reloj. 1 s real = 1 min juego (60-90 pasos = 60-90 s).
4. **`clima_de_mañana()` sin ñ:** identificador GDScript sin ñ por seguridad de tooling (la guía/documentación lo escribe `clima_de_mañana`).
5. **Estado único:** el dueño del estado es el autoload `Weather` (equivalente funcional del "GameState.M32" del diseño; GameState no existe en el proyecto).
6. **Gana el recomputado:** `restore_save_data` recomputa `clima(dia)` y valida contra el guardado (warning si difieren) — nunca data corrupta.

### Verificación

- `test_clima.gd` headless (Godot 4.5 console): **0 fallo(s)** — determinismo (100 días + 500), regla cozy en 1008 días simulados, nieve solo en invierno, tabla estacional normalizada, rampa 0→1.0 en 60 minutos monótona, señales emitidas, API interpolaciones exactas, persistencia con clima corrupto.
- Regresiones: M29 "CALENDARIO OK", M31 "CICLO DIA/NOCHE OK", M21 "0 fallo(s)", Bootstrap "DOM-INF integridad OK: 9 dominios".
- Runtime real (godot-mcp, Godot 4.7.2): boot → MUNDO sin errores nuevos del módulo.

### Hallazgos ajenos (para sus dueños)

- **M15 (preexistente):** `resource_manager.gd:60 obtener_todas()` retorna `Array` genérico donde se declara `Array[ResourceDefinition]` — dispara SCRIPT ERROR en cada boot vía `resource_spawner.gd:31`. No lo toqué (M15 🟡 con dueño); es el "cableado M13→M15" pendiente.
- **Cache de clases:** los `class_name` nuevos requieren un escaneo del editor (`--headless --editor --quit`) para registrarse en `.godot/global_script_class_cache.cfg` antes de que otros scripts los referencien tipados.

### Pendientes con dueño (honestos)

- Partículas GPU compartidas (M52, V2) + presupuesto M61 + calidad M90.
- Buses de audio climáticos y crossfade (M42) — volumen interpolado ya expuesto.
- Atenuación de luz consultando `get_atenuacion_sol()` (M31/M49) — API lista, sin duplicar estado.
- Banner climático + aviso "mañana: tormenta" (M30/M53) — `clima_de_manana()` listo.
- Eventos especiales F: aurora/arcoíris/lluvia de estrellas (M29/M31).
- Accesibilidad M58 (reducir clima, sin truenos, niebla reducida) + opciones UI.
- Suite formal GdUnit4 (M112) — hoy: test headless estándar del proyecto.

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://world/weather/weather_service.gd` | Node (autoload M07) | Determinismo, selección diaria, intensidad, API pública |
| `res://world/weather/particulas_clima.gd` | Node3D | 1 sistema GPU compartido (lluvia/nieve/hojas) |
| `res://world/weather/particulas_clima.tscn` | Escena | Densidades por clima + calidad (M90) |
| `res://data/weather/clima_config.tres` | Data | Probabilidades, duraciones, atenuaciones, volúmenes |
| `res://data/weather/eventos_tabla.tres` | Data | Aurora/arcoíris/posposiciones |
| `res://ui/hud/banner_clima.gd` | UI | Banner + aviso de tormenta mañana (lee M29/M30) |
| `res://tests/caso_clima_tests.gd` | Test | Suite M112 (determinismo, transiciones, validaciones) |

## 2. Contrato de datos

```
CLIMA = { SOLEADO, NUBLADO, LLUVIA, TORMENTA, NIEBLA, NIEVE, VIENTO, TROPICAL, ESPECIAL }

clima_config.tres:
  por_clima = {
    LLUVIA:   { prob_estacion: {P:0.18, V:0.08, O:0.12, I:0.05}, dur_min: 120, dur_max: 240,
                sol: 0.70, particulas: "lluvia_fina", audio_bus: "lluvia" },
    TORMENTA: { prob_estacion: {P:0.06, V:0.10, O:0.04, I:0.02}, dur_max: 180, sol: 0.35,
                particulas: "lluvia_densa", audio_bus: "tormenta" },
    ...
  }
```

## 3. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| `weather_service.gd` (determinismo + API) | Indispensable tras GameClock (M29) y la franjas (M31) |
| `particulas_clima` (1 sistema compartido) | Con M61 (presupuesto 1 ms) y M90 (calidad) |
| Integración con M31 (atenuación de luz) | Solo lee `get_intensidad()` — sin estado duplicado |
| Integración con M42 (buses) y M41 (variante lluvia) | Crossfade 60-90 s |
| Banner climático (M30 HUD) | Aviso: "Mañana: tormenta" |
| Suite de tests M112 | Determinismo (mismo seed+día ⇒ mismo clima), validación aurora/estrellas, nunca 2 tormentas seguidas, transiciones sin corte de intensidad |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 20:10:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 25/25 puntos de la sección 31 resueltos (tabla en 02-Analisis).
- Catálogo de 9 climas con probabilidades estacionales, duraciones, atenuación de sol y partículas.
- Determinismo (seed, día) documentado con fórmula — sin exploits de recarga.
- Regla de oro: clima jamás bloquea/destruye/castiga (bono sí, bloqueo no); alineado con M152 de DEVIN.
- Validaciones mutuas: lluvia de estrellas (M31) ↔ tormenta; aurora con despejado.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M29/M31 existentes (hito M1). Dueño: AGENTE DELEGADO.
- No fijé assets de partículas ni nombres finales de materiales (M45/M47 los producen).

### Recomendaciones para el próximo agente
- Implementar WeatherService como autoload puro sin leer el calendario (todo por API M29).
- El determinismo por (seed, día) debe estar probado antes que cualquier efecto visual (es la base anti-exploit).
- Los consumidores (NPC/fauna/agri/pesca) deben escuchar señales, nunca consultar internals.

---

## Notas del Agente — Iteración 1 (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 23:50:00
**Estado:** Parcial (núcleo implementado y verificado; módulo liberado 🟡)

### Lo que hice
- Núcleo determinista completo: cadena cacheada `clima_de_dia(dia)` con regla cozy (profundos nunca seguidos), tabla estacional data-driven en `clima_config.tres`, transición de intensidad por minutos de juego, persistencia ISaveProvider M59 con validación "gana el recomputado".
- Dominio `EventBus.weather` (aditivo) + autoload `Weather` registrado + integración M21 (`WorldState._get_clima` delega en Weather).
- Test headless `test_clima.gd` 0 fallos + regresiones M29/M31/M21 OK + boot runtime verificado con godot-mcp (Godot 4.7.2) sin errores nuevos.
- Relevé el checklist: 84/121 [x] reales (A/B por docs existentes de Deepseek; C/H completos; D/G/I/J parciales). Checklist fila global actualizada a 84/121.

### Lo que NO pude hacer (honestidad obligatoria)
- Partículas visuales, audio real, banner UI, atenuación de luz aplicada y eventos especiales: requieren V2 (capturas) y/o dueños M52/M42/M30/M31/M49/M58. Quedan como [ ] con dueño, no como `[?]` (no hay bloqueo técnico, solo dependencia de fase).
- Suite GdUnit4 formal del M112: el test vive como test headless estándar del proyecto (patrón test_farm/test_clima).

### Intentos fallidos / decisiones
- `class_name WeatherConfig` no resolvió en headless hasta regenerar la caché de clases con un escaneo del editor — documentado como hallazgo en §0.
- Las lambdas de GDScript capturan por valor: el test contaba emisiones con un contenedor Array mutable (no con una variable local).

### Recomendaciones para el próximo agente
- Partículas (M52): consumir `get_intensidad()` + densidades de `clima_config.tres`; presupuesto ≤1 ms (M61); pausa ya garantizada por diseño (transición por señales de minuto).
- Banner (M30/M53): usar `clima_de_manana()` para el aviso de 1 día y `get_nombre_clima()` para el texto (nunca solo ícono — accesibilidad M58).
- Eventos especiales (F): aurora/estrellas requieren leer el calendario de festivales (M29 `festivals.tres`) y el cielo despejado (`get_clima() == SOLEADO` o NUBLADO según regla).