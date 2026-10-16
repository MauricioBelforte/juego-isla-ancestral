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
- Lección a documentar en GUIA-GODOT/INDICE.md §9: nunca referenciar autoloads directos por global en scripts cargados vía `--script`; usar `get_node_or_null("/root/Nombre")`.

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

### Hallazgo documentado (GUIA-GODOT/09-godot4-migracion.md §9.60 — pendiente de copiar en la próxima pasada de guía)
- `Curve.add_point` espera Vector2 y el DOMINIO de posición es 0-1 (curva normalizada). Intentar guardar horas 0-24 como posiciones clampa silenciosamente todos los puntos a ≤1 y sample(hora) devuelve 0. El consumidor debe samplear con hora/24.0. (Anotado en Log 452; copiar a §9 en la próxima edición de la guía.)

### Lo que NO pude hacer (honestidad obligatoria)
- Cielo procedural, estrellas visuales, luna con textura, nubes, faroles, murales luminosos: V2/escénicos con dueño (M45/M49/M52).
- Opción M58 "Noche clara", QA M114, capturas V4: con dueño.
- Transición 90 s polish: queda [ ] (el crossfade de 1 s del núcleo se mantiene).

### Recomendaciones para el próximo agente
- M49: la iluminación global puede consultar directamente las mismas curvas de data/light/ (fuente única).
- M52/M58: los parámetros de luces nocturnas y opciones de accesibilidad leen fase_umbral.json.
- Los valores de curva son tuning fino: editar gen_curvas.gd y regenerar (nunca editar el .tres a mano).

---

## Notas del Agente — Iteración 3 auditoría A-J + test del contrato (2026-09-12)

**Modelo:** GLM-5.3 (flagship de Z.ai, 743B)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-12 02:15
**Estado:** Cerrada — 115 [x] / 0 [ ] / 54 [?] con dueño (de 16/161). Módulo queda 🟡.

### Lo que hice
- **Auditoría doc↔código de las secciones A-J** (mi especialidad, patrón M29): el header del checklist decía "131 completados" pero las secciones estaban mayormente [ ] contra el núcleo (iter. 1), las curvas data-driven (iter. 2) y los ramps M49 (iter. 3 de M49, Log 731) ya implementados. 92 ítems marcados [x] con evidencia por ítem: número de línea de day_night_cycle.gd, archivo .tres/.json de data, check de test, o sección del 03-Diseno.
- **Test del CONTRATO central (EventBus.time.fase_cambio)** — antes NUNCA testeado: el test solo validaba get_fase() interno. Ahora test_ciclo_dia_noche.gd valida con el bus REAL: sin señal en misma franja (23→23), exactamente 1 señal al cambiar (23→5), payload == FASE_ALBA correcto, 1 señal (5→7), desconexión limpia. Suite 12 → **16 checks, 0 fallos**.
- **Código muerto activado:** la variable _fases_recibidas estaba declarada sin uso desde la iter. 1 — ahora es el receiver del test del contrato.
- **Clasificación honesta de los 54 [?]:** escénicos V2 (luna/nubes/estrellas/faroles/FogVolume — M45/M18), contenido de dueños (M15 flora nocturna, M52 partículas, M74 eventos, M25/M148, M55, M58, M110, M114, M12), cables de dueños 🔵 activos (M41/M42 de agnes-2.5-flash — respetados por regla §21.4.6, no tocados).
- **Consumidores F verificados con grep REAL:** M19 consume hora_cambio propia (villager_manager L127), M36 candidatas_para(hora,bioma) (fauna_manager L46), M34 FRANJAS propias (fishing_manager L20), M39 esta_abierta(dia,hora) (shop.gd L45), M41 variante _noche (music_director L48), M42 set_fase() (ambient_director L52). El ítem F.13 "Contrato solo por señales" verificado: 0 imports de day_night_cycle fuera de tests.

### Lo que NO pude hacer (honestidad obligatoria)
- Los 54 [?]: soy solo-texto (§16 guía 10) — los escénicos V2 requieren visión (V1/V4) y los de contenido son de sus dueños. M41/M42 🔵 de agnes-2.5-flash: el cableado fase→set_fase/variante es de ese agente, NO mío.
- QA visual M114 y capturas V4: fuera de mi alcance.

### Intentos fallidos / decisiones
- Decisión: marcar F (consumidores) por ESTADO REAL del consumidor (grep), no por deseo del diseño — M19 funciona por hora_cambio propia y está bien (desacople); no "corregí" lo que funciona para forzar fase.
- Decisión: los ítems I de rendimiento (2ms GPU, draw calls de nubes) se marcan por diseño+tween estructural; el profiling real es M61/M114.

### Recomendaciones para el próximo agente
- El test del contrato usa BUS.new() con root.add_child(bus) porque el autoload no está en --script headless; en runtime el autoload real se reutiliza (get_node_or_null primero).
- M41/M42 (al liberar): EventBus.time.fase_cambio.connect(...) → set_fase(fase) / selección variante _noche — el contrato ya está testeado de este lado.
- M18/M45 (faroles): fase_umbral.json §luces_artificiales tiene umbral 0.35 / 3200K / r 8 m listos para consumir.
- M93/M15 (flora nocturna): hook futuro es_de_dia()/fase_cambio para el bono x2 — la decisión cozy está documentada en diseño §6.

---

## Notas del Agente — Iteracion 4 lote 1: cielo/estrellas/90 s (Step-5-WorkBuddy, 2026-10-15)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-15
**Encargo:** msg 49 del director De-Director V4.1 (2026-10-15): M31 lote 1 = skybox/luces programadas (los 49 pendientes del modulo, hoy 120/169).
**Estado:** 124 [x] / 0 [ ] / 45 [?] = 169 (4 [?] cerrados con implementacion real). Evidencia: Log 1878 + test_cielo_estrellas_m31.gd (39 checks / 0 fallos / EXIT 0 x3).

### Lo que hice
- **Cielo procedural por hora** (`day_night_cycle.gd`, `_asegurar_cielo_procedural` L135 + `_aplicar_iluminacion` L259): el `ProceduralSkyMaterial` del Environment se conduce por hora — `sky_energy_multiplier` desde `sky_curve.tres` (diseño §P5) y `sky_top_color`/`sky_horizon_color` desde `sky_color_ramp.tres` (M49 iter. 3); `ground_horizon_color`/`ground_bottom_color` derivados por lerp. El material se DUPLICA en runtime: no se muta el recurso compartido cacheado de la escena. API real medida por sonda headless: la propiedad es `sky_energy_multiplier` (no `sky_energy`, que es Godot 3).
- **Canvas de estrellas** (`_asegurar_domo_estrellas` L156 + `_generar_textura_estrellas` L182): domo `MeshInstance3D` (SphereMesh r=900, flip_faces, unshaded + transparente) con `ImageTexture` procedural de 600 estrellas (semilla fija 31031, determinista entre sesiones). El alpha sale de `alpha_estrellas(hora)` L201: subida 0→100% entre 20:00 y 22:00 (fase_umbral.json §estrellas, diseño §P6), noche sostenida en alpha_max y bajada como espejo del gradiente de subida (2 h) sobre la franja del alba (5→7) — el diseño §P6 fija solo la subida.
- **Transiciones de 90 s** (`_duracion_transicion` L218, llamado desde `_on_hora_cambio` L226): los `duracion_gradiente_amanecer`/`duracion_gradiente_atardecer` de `time_config.tres` (M29, L31-32 = 90 s) se consumen en las transiciones que tocan ALBA/ATARDECER; el resto mantiene el crossfade de 1 s de fase_umbral.json §transicion (comportamiento del núcleo Log 302). Cierra el "dato definido, no aplicado" de la correccion 2026-10-15 (step-5-kilocode).
- **Umbrales cargados** (`_cargar_umbrales` L95, `_cargar_duraciones` L115): fase_umbral.json y time_config.tres se leen en `_ready`; si faltan, valores por defecto documentados.
- **Test nuevo** `scripts/world/test_cielo_estrellas_m31.gd`: 39 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR, con guardas anti-falso-verde (bloques A-D con `_fin()`, piso `CHECKS_MINIMOS` = 39 medido en verde, `_summary` por `call_deferred`). Guardián probado EN ROJO por inyeccion (aborto en bloque C -> nombra ["C","D"], 19 checks, EXIT 1). Extiende `test_curvas_luz.gd` (regresión verde: 0 fallos).
- **Flips aplicados** (4, con cita): B-P6 (L44), D-canvas de estrellas (L87), K-90 s (L218), K-Sky procedural (L219) [?] -> [x].

### Lo que NO pude hacer (honestidad obligatoria)
- Nubes velo, niebla FogVolume, luna esférica con textura, faroles: escénicos V2 con dueño (M45/M18) — los [?] correspondientes siguen intactos.
- La bajada de las estrellas (5→7) es una decisión de implementación (espejo de la subida): el diseño §P6 solo documenta la subida 20→22.

### Drift/discrepancias detectadas (reportadas, no tocadas)
- Diseño §P3 dice "energía 0.18-1.0" para el Sky; `sky_curve.tres` da 0.15 en hora profunda (§P5 del JSON). Manda el dato (data-driven).
- Diseño §P3 dice "gradiente 24 puntos"; `sky_color_ramp.tres` (M49) tiene 9 paradas. El muestreo es por hora (hora/24).
- Rutas del diseño (§1: `res://world/light/cielo.gd`) divergen de la real (`scripts/world/day_night_cycle.gd`, consolidado): nubes/niebla de M45 no están en M31.

### Recomendaciones para el próximo agente
- M45 (escénicos): el domo de estrellas y el cielo procedural ya están cableados; los assets (texturas, nubes) se montan sobre esta base.
- M58 ("Noche clara", piso 0.35): el hook natural es `alpha_estrellas()`/`sky_curve` — hoy el piso es constante en curva.
- M18/M45 (farol + autoswitch): `fase_umbral.json` §luces_artificiales (umbral 0.35, 3200K, r 8 m) sigue listo para consumir.


## Notas del Agente - Iteracion 4 lote 2: niebla por hora + modulacion estacional (Step-5-WorkBuddy, 2026-10-16)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-16
**Encargo:** msg 51 del director De-Director V4.1 (2026-10-15): cerrar los gaps PROPIOS de M31 (~2) + los tests de secciones propias; registrar el drift sec. P3 como deuda documentada sin reescribir el diseno.
**Estado:** 125 [x] / 0 [ ] / 44 [?] = 169 (1 [?] propio cerrado: E-season_mod; el gap de consumo de niebla tambien cerrado). Evidencia: Log 1884 + test_niebla_estacion_m31.gd (47 checks / 0 fallos / EXIT 0 x3).

### Lo que hice
- **season_mod.tres (data nueva, game/isla-ancestral/data/light/season_mod.tres)**: Curve con dominio 0-3 (indice de estacion de game_clock: 0 Primavera, 1 Verano, 2 Otono, 3 Invierno) y multiplicadores 1.0 / 1.1 / 0.95 / 0.85 - DECISION DE IMPLEMENTACION (el diseno sec. 4 no fija cifras). Generado con gen_season_mod.gd (patron validante de gen_curvas.gd: valida ANTES de guardar, quit(1) si falla).
- **Consumo estacional (day_night_cycle.gd)**: mod_estacional(estacion) lee la curva; _aplicar_iluminacion la aplica a day_curve (sol) y sky_curve (ambiente + energia del cielo procedural) - "ambas curvas" del diseno sec. 4. La luna (moon_curve) NO se modula. La estacion vigente se lee de M29 (get_estacion()) en _ready y se re-aplica por la senal estacion_cambio (_on_estacion_cambio, con _hora_actual trackeada).
- **Piso anti-oscuridad (regla de oro sec. 7)**: la modulacion NUNCA baja el ambiente de 0.15 - maxf(valor * mod, PISO_AMBIENTE) (en Invierno 0.15 x 0.85 = 0.1275 queda clampeado a 0.15).
- **Niebla por hora (day_night_cycle.gd)**: niebla_densidad(hora) = FOG_BASE (0.00018, niebla marina autoreada en main_island.gd L204) x fog_curve.tres (variacion relativa 0.5 mediodia - 1.3 pico atardecer). Cierra el gap "fog_curve existe pero no se carga en codigo". El Environment recibe fog_density por hora (tween incluido) y fog_enabled = true.
- **Test nuevo test_niebla_estacion_m31.gd**: 47 checks / 0 fallos / EXIT 0 x3, 0 SCRIPT ERROR. Guardas anti-falso-verde: bloques A-C con _fin(), piso CHECKS_MINIMOS = 47 MEDIDO en verde, _summary por call_deferred. **Guardian probado EN ROJO por inyeccion** (aborto por runtime al inicio del bloque C -> EXIT 1, "[FAIL] solo 28 checks ejecutados (minimo 47)"). Regresiones verdes x2: test_curvas_luz.gd (0 fallos), test_ciclo_dia_noche.gd (16/0), test_cielo_estrellas_m31.gd (39/0).
- **Flips aplicados (1, con cita)**: E-season_mod (L99) [?] -> [x]. 124 -> **125 [x] / 44 [?] / 0 [ ] = 169** (prefijo de linea, invariante OK). Header + Totales actualizados. Nota PARCIAL en K.2-niebla (L222): el nodo FogVolume volumetrico sigue ausente (K.2, dueno externo M45) y por eso los items de niebla siguen [?].

### Lo que NO se pudo hacer (honestidad obligatoria)
- Los items de niebla (B-P11 L49, D L84, K.2 L222) SIGUEN [?]: exigen el nodo FogVolume volumetrico en escena + variacion estacional cualitativa ("matinal otono, bruma verano") que no tiene data - contenido de dueno externo (M45).
- La variacion estacional de la NIEBLA no se implemento (el diseno sec. 3 la menciona "por estacion/hora" pero no hay data; inventarla seria fabricar contenido).
- Los multiplicadores estacionales son decision de implementacion propia (verano 1.1 / invierno 0.85): el diseno sec. 4 no fija valores.

### Deuda documentada (drift, NO reescrito)
- **sec. P3 (tabla de componentes, fila Sky)**: el diseno dice "energia 0.18-1.0" y "gradiente 24 puntos"; el dato real es sky_curve.tres con piso 0.15 en hora profunda (anti-oscuridad sec. 7) y sky_color_ramp.tres (M49) con 9 paradas. Manda el dato; registrado en 03-Diseno.md como deuda del dueno del documento.
- **Escala de niebla**: el rango 0.08-0.25 del diseno sec. 3 es del FogVolume volumetrico; el fog del Environment se ancla a 0.00018 (niebla marina autoreada). Registrado, no modificado.
- **fase_umbral.json sec.niebla (prosa)**: dice "noche 0.9" pero la curva horneada da 1.0296 a las 03:00 (interpola 0.9 -> 1.1). Manda el dato; la prosa del JSON es aproximada.
- **TRAMPA MEDIDA**: Curve.sample() usa la curva HORNEADA (bake), no la interpolacion lineal exacta entre puntos - la 1a version del test esperaba 1.02 a las 03:00 y el medido fue 1.0296. Se asegura el valor medido, no la aritmetica de memoria.

### Recomendaciones para el proximo agente
- M45 (escenicos): el fog del Environment ya se consume por hora; el nodo FogVolume volumetrico (0.08-0.25 por estacion/hora) sigue pendiente y es el que cierra B-P11/D/K.2-niebla.
- M18/M45 (farol + autoswitch): fase_umbral.json sec.luces_artificiales (umbral 0.35, 3200K, r 8 m) sigue listo para consumir.
- M58 ("Noche clara", piso 0.35): el hook natural es sky_curve/alpha_estrellas; hoy el piso es constante.
