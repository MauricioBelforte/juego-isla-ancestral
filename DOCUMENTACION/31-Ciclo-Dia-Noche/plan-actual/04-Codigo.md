**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 31: Ciclo Día/Noche

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://world/light/day_night_cycle.gd` | Node | Orquestador: escucha hora_cambio de M29, evalúa fase, tweena curvas |
| `res://world/light/sol.gd` | Componente | DirLight sol: rotación, energía, color por curvas |
| `res://world/light/luna.gd` | Componente | DirLight luna + arco opuesto + fases (textura de M29) |
| `res://world/light/cielo.gd` | Componente | Sky procedural + estrellas + nubes velo + niebla |
| `res://scene/farol.tscn` + `farol.gd` | Prefab | Autoswitch por umbral de luz; tinte cálido |
| `res://data/light/day_curve.tres` | Data | Curvas (sección 4 del diseño) |
| `res://data/light/sky_curve.tres` | Data | Curvas de cielo |
| `res://data/light/season_mod.tres` | Data | Modificadores de estación |
| `res://data/light/fase_umbral.tres` | Data | Umbrales de fase |
| `res://tests/caso_noche_dia_tests.gd` | Test | Suite M112: transiciones y fases |

## 2. API pública (contrato)

```
DayNightCycle (autoload/único, M07):
  get_fase() -> FASE                    # ALBA | DIA | ATARDECER | NOCHE | PROFUNDA
  get_intensidad_sol() -> float         # 0..1 (consulta para UI/partículas)
  es_de_dia() -> bool                   # DIA/ALBA = true
  EventBus.time.fase_cambio(FASE)       # señal en cambio de franja (no por minuto)
```

> La señal de fase ES la única dependencia de los consumidores (M19, M36, M41, M42, M15, M34, M39). El M23 no conoce detalle interno de curvas.

## 3. Algoritmo de transición

1. En `hora_cambio(minuto)`: `fase = tabla(franja(minuto))`.
2. Si `fase != _fase_actual` → emitir `fase_cambio(fase)`, actualizar `_fase_actual`.
3. Función `_tween_curvas(minuto)`: interpolación 24-punto (lerp entre vecinos) para sol/sky/ambiente/fog.
4. Nothing se procesa por frame: ciclo entero se dispara 1 vez por minuto de juego (M29 emite cada minuto).
5. Transición amanecer/atardecer resuelta por las curvas (los 90 s de diseño salen del espaciado de puntos).

## 4. Sombras y rendimiento (M61)

- Sol: shadow enabled, cascades 2, split 0.5, radio 30 m; atenuación suave.
- Luna: shadow DISABLED (regla de oro).
- Estrellas: canvas estático (alpha tweena) — sin partículas por estrella.
- Nubes: velo 2D (1 draw call), no volumétrico en v1.
- Niebla: FogVolume líghe (distancia ≤ 120 m).
- Presupuesto del módulo: ≤ 2 ms de GPU en peak, ≤ 1 ms típico (medir en M113).

## 5. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| Implementar `day_night_cycle.gd` + luces + cielo | Indispensable tras GameClock (M29); base de M49 |
| Curvas .tres (24 puntos c/u) | Plantilla numérica dada en 03-Diseno |
| Prefab de farol + autoswitch | Se instancia en poblado (M18/M17) y camino del puerto (M28) |
| Suite de tests M112 | Transiciones: cambio de fase límite (19:59→20:00), franjas, umbral farol (antes/después), persistencia de fase al recargar |
| QA visual M114 nocturno | Checklist de "no oscuridad excesiva" por zona |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 18:10:00
**Estado:** Documentación completa de diseño (módulo delegable)

### Lo que hice
- 22/22 puntos de la sección 30 resueltos con decisiones concretas.
- Cronograma de 5 franjas (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA) con umbrales fijos; consumidores atados SOLO a señales de fase.
- Regla anti-oscuridad con valores (piso 0.15 LDR + linterna + opción M58).
- Eventos/secretos nocturnos definidos (sin contenido obligatorio de noche).

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M29 (GameClock) y M07 en proyecto (hito M1). Dueño: AGENTE DELEGADO.
- No fijé textura final de luna/estrellas ni nombres de assets (M45/M46 los producen).

### Recomendaciones para el próximo agente
- Implementar con la API de fase (no leer el reloj): aísla de cambios de M29 y hace testeable.
- Las curvas .tres deben venir con valores que respeten el piso 0.15 (verificarlo en test).
- Coordinar con M49 (iluminación global) y M61 (presupuesto de sombras) antes de polish.

## Notas del Agente (iteración 1 — 2026-08-31)

**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Fecha:** 2026-08-31 06:30:00
**Estado:** Núcleo runtime implementado y validado. Módulo sigue en curso para iteraciones futuras.

### Lo que hice
- `game/isla-ancestral/scripts/world/day_night_cycle.gd` (nuevo): orquestador del ciclo. 5 franjas, rotación sol/luna en arcos opuestos, tween 1.0 s de energía/color sol-luna-ambiente, anti-oscuridad piso 0.15, API `get_fase()`/`es_de_dia()`. Conexión a `GameTime.hora_cambio` y emisión a `EventBus.time.fase_cambio` (nuevo dominio).
- `game/isla-ancestral/scripts/core/event_bus.gd`: nuevo dominio `time` con clase `TimeEvents` y señal `fase_cambio(fase: int)`.
- `game/isla-ancestral/scenes/main_island.tscn`: nodos `DayNightCycle` (Node3D + script) y `DirLightLuna` (DirectionalLight3D, sin sombras, color 7500K) añadidos vía godot-mcp.
- `game/isla-ancestral/scripts/world/test_ciclo_dia_noche.gd` (nuevo): suite headless 12/0 OK (fases correctas en 8 horas, sin doble señal, get_fase/es_de_dia).
- Reserva en los 4 registros (guía 08, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO).

### Lo que NO pude hacer (honestidad obligatoria)
- Curvas 24-puntos en `data/light/*.tres` (energía, color cielo, mods estacionales, umbrales). Implementé targets horarios inline en el script; las curvas como `.tres` son una iteración de datos.
- Prefab de farol con omni 3200K y autoswitch por umbral (M17/M18).
- Sincronización con M52 partículas (lluvia de estrellas) y M15 (flora brillante bonus x2).
- QA visual M114 (checklist nocturno por zona) — M114 está en 🟢 sin implementar.
- Integración con M49 iluminación global (M49 🟢 sin implementar).
- Malla de luna y canvas de estrellas (M45/M46 🟢 sin implementar).
- Pulido de transición 90 s amanecer/atardecer.
- Opción M58 "Noche clara" (M58 🟢 sin implementar).
- Lección a documentar en 07-GUIA-GODOT §9: nunca referenciar autoloads directos por global en scripts cargados vía `--script`; usar `get_node_or_null("/root/Nombre")`.

### Intentos fallidos / decisiones
- Referenciar `GameTime` directo → "Identifier not found" en parse. Resuelto con `get_node_or_null("/root/GameTime")`.
- `class_name DayNightCycle` + `const DAY_NIGHT_CYCLE := preload(...)` en el test → "Nonexistent function 'new' in base 'GDScript'". Resuelto quitando `class_name` del script (no es autoload; se carga por path `res://`).
- Rotación de fuentes: el `look_at` falla si el sol queda casi vertical (§9.9). Añadí guarda con `Vector3.FORWARD` cuando `dir.dot(UP) > 0.999`.

### Recomendaciones para el próximo agente
- Extraer las curvas horarios a `data/light/*.tres` (24 puntos sol, 24 cielo, 4 mods estacionales, umbrales de fase) y cargarlas en `_ready` con fallback a defaults inline.
- Implementar el prefab de farol y registrarlo como grupo `faroles` para que `_aplicar_iluminacion` haga `for f in faroles: f.light_energy = ...` (umbral 0.35).
- Cuando M49 exista, mover las constantes de energía/color a un servicio común para evitar duplicación.
- El test visual (captura del juego a 08:00, 13:00, 19:00, 23:00) se puede hacer con `cap_godot.py --modulo 31` y comparar antes/después para validar el cambio de luz. Requiere V4 operativa (Kilo nativo).

---

## Notas del Agente — Iteración 2 curvas data-driven (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 18:55:00
**Estado:** Parcial (curvas de luz data-driven implementadas y verificadas; módulo liberado 🟡 — cierra el [?] de datos, quedan [?] con dueño)

### Lo que hice
- Curvas de luz canónicas (data/light/): day_curve.tres (sol: 0 noche → 0.5 amanecer 6h → 1.0 día 7-17 → 0.2 atardecer 19 → 0), sky_curve.tres (cielo/ambiente: 0.15 anti-oscuridad profunda → 0.22 noche → 0.4 atardecer → 1.0 día), moon_curve.tres (luna: 0.12 profunda → 0.18 noche → 0), fog_curve.tres (niebla por hora: matinal 1.1-1.2, mediodía 0.5, atardecer 1.0-1.3). Generadas con el serializador de Godot (gen_curvas.gd) — formato .tres canónico garantizado.
- fase_umbral.json (data/light/): umbrales de las 5 franjas §P13, parámetros de luces artificiales (0.35/3200K/8 m §P10/P12), estrellas (20-22 h §P6) y transición — todo data-driven.
- day_night_cycle.gd (aditivo, §P1/P2/P5): _cargar_curvas() + sample(hora/24) — el núcleo usa curvas con fallback a los valores hardcodeados del Log 302 si los .tres faltan; amanecer/atardecer con color cálido/cálido-rojo por hora.
- Integración M71: reset_dia del PlayerProfile conectado a calendar.day_started M29 (RF7 de M71 — pendiente anotado allí, ahora cerrado).
- Test test_curvas_luz.gd: curvas cargables, valores del diseño (mediodía/noche/profundidad), rampa de amanecer, umbrales JSON, núcleo data-driven con estructura real (sun 1.0/0, cielo 1.0/0.15, luna 0/0.12), reset_dia → **0 fallos**.
- Regresión: test_ciclo_dia_noche (núcleo Log 302) 12 checks/0 fallos.

### Hallazgo documentado (07-GUIA-GODOT §9.60 — pendiente de copiar en la próxima pasada de guía)
- `Curve.add_point` espera Vector2 y el DOMINIO de posición es 0-1 (curva normalizada). Intentar guardar horas 0-24 como posiciones clampa silenciosamente todos los puntos a ≤1 y sample(hora) devuelve 0. El consumidor debe samplear con hora/24.0. (Anotado en Log 452; copiar a §9 en la próxima edición de la guía.)

### Lo que NO pude hacer (honestidad obligatoria)
- Cielo procedural, estrellas visuales, luna con textura, nubes, faroles, murales luminosos: V2/escénicos con dueño (M45/M49/M52).
- Opción M58 "Noche clara", QA M114, capturas V4: con dueño.
- Transición 90 s polish: queda [ ] (el crossfade de 1 s del núcleo se mantiene).

### Recomendaciones para el próximo agente
- M49: la iluminación global puede consultar directamente las mismas curvas de data/light/ (fuente única).
- M52/M58: los parámetros de luces nocturnas y opciones de accesibilidad leen fase_umbral.json.
- Los valores de curva son tuning fino: editar gen_curvas.gd y regenerar (nunca editar el .tres a mano).
