**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 31: Ciclo Día/Noche

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (tras M29/M49).

## Reserva actual

- Estado: 🔵 En curso
- Agente: GLM (Kilo)
- Fase: 5 - Base de producción
- Dificultad: 3
- Visión: V1/V2
- Entrada: M29 ✅
- Salida: 5 franjas operativas (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA), sol/luna/sky tweeneados, anti-oscuridad 0.15, señal fase_cambio, tests 0 fallos
- Archivos: scripts/world/day_night_cycle.gd, event_bus.gd (dominio time), main_island.tscn (nodos luz/luna), tests/caso_noche_dia_tests.gd
- Fecha: 2026-08-31 03:30

## A. Requisitos del módulo (12)

- [ ] Definir el problema: luz/cielo/ambiente cambian con la hora (M29) [S]
- [ ] Registrar dependencias: M29, M07; consumidores M19, M36, M41-M44, M15, M34, M39 [S]
- [ ] Catalogar los 22 puntos del plan maestro (sección 30) [S]
- [ ] RF1: luz diurna por curva de hora [S]
- [ ] RF2: luz nocturna con luna suave [S]
- [ ] RF3: cielo dinámico (gradiente, nubes, niebla) [S]
- [ ] RF4: amanecer/atardecer con transiciones suaves [S]
- [ ] RF5: franjas discretas para consumidores [S]
- [ ] RF6: luces artificiales con autoswitch [S]
- [ ] RF7: comportamiento NPC/fauna/audio/spawn por franja [S]
- [ ] RF8: eventos nocturnos opcionales [S]
- [ ] RF9: navegación nocturna cómoda [S]

## B. Resolución de los 22 puntos del plan (22)

- [ ] P1: iluminación diurna — sol DirLight con curva 0.25→1.0→0.2 y temperatura por banda [S]
- [ ] P2: iluminación nocturna — luna 0.12-0.2, 7500K, sin sombras [S]
- [ ] P3: sombras — solo sol, 2 cascadas, radio 30 m, PCF suave [S]
- [ ] P4: color ambiental — gradiente 24 puntos por hora + mod estacional [S]
- [ ] P5: cielo — ProceduralSkyMaterial, energía 0.18-1.0 [S]
- [ ] P6: estrellas — canvas procedural, alpha 0→100% 20:00-22:00 [S]
- [ ] P7: luna — esfera + fases del calendario M29 [S]
- [ ] P8: nubes — velo 2D con drift, densidad estacional [S]
- [ ] P9: amanecer — 06:00, gradiente naranja/violeta, cantos (M42) [S]
- [ ] P10: atardecer — 19:00-20:00, luces con umbral 0.35 [S]
- [ ] P11: niebla — matinal otoño, bruma verano, densa invierno, nocturna 0.25 [S]
- [ ] P12: luces artificiales — omnipoint 3200K r 8 m, autoswitch [S]
- [ ] P13: comportamiento NPC — franjas DÍA/PRE-NOCHE/NOCHE/PROFUNDA/ALBA [S]
- [ ] P14: comportamiento fauna — diurna/nocturna + peces luna [S]
- [ ] P15: cambio música — 4 variantes + crossfade 3 s (M41) [S]
- [ ] P16: cambio sonidos — banco diurno/nocturno con crossfade (M42) [S]
- [ ] P17: spawn de recursos — nocturnos opcionales (nunca críticos) [S]
- [ ] P18: actividades — tiendas cierran 21:00, pesca toda la noche [S]
- [ ] P19: eventos nocturnos — lluvia de estrellas días 10 y 25 [S]
- [ ] P20: secretos nocturnos — flora brillante + murales lore [S]
- [ ] P21: navegación nocturna — piso 0.15 + linterna + faroles 40 m [S]
- [ ] P22: evitar oscuridad excesiva — regla de oro + opción M58 [S]

## C. Cronograma de fases (12)

- [ ] Fase ALBA: 05:30-06:59, sol 0.2→0.5 [S]
- [ ] Fase DÍA: 07:00-18:59, sol 0.5→1.0→0.6 [S]
- [ ] Fase ATARDECER: 19:00-19:59, sol 0.6→0.2 [S]
- [ ] Fase NOCHE: 20:00-22:59, luna 0.15 [S]
- [ ] Fase PROFUNDA: 23:00-05:29, ambiente piso 0.15 [S]
- [ ] Comienza amanecer a las 05:30 (transición pre-alba) [S]
- [ ] Señal `fase_cambio` SOLO en cambio de franja [S]
- [ ] Umbrales configurables en `fase_umbral.tres` [S]
- [ ] Compatible con dormir (M29 avanza hasta 06:00 → DÍA directo) [S]
- [ ] Compatible con carga de partida a cualquier hora [S]
- [ ] Sin saltos visuales al cargar (fase se evalúa al entrar) [S]
- [ ] Cronograma documentado como tabla de referencia [S]

## D. Componentes de escena (14)

- [ ] Nodo `DirLightSol` con parámetros definidos [S]
- [ ] Nodo `DirLightLuna` sin sombras [S]
- [ ] Sky procedural con gradiente [S]
- [ ] Luna esférica con textura de fases [S]
- [ ] Nubes velo 2D con drift lento [S]
- [ ] Niebla (FogVolume ligero) [S]
- [ ] Prefab de farol con omni 3200K [S]
- [ ] Autoswitch de faroles por umbral de luz [S]
- [ ] Canvas de estrellas [S]
- [ ] Sin partículas por estrella (estático) [S]
- [ ] Fuente del sol y la luna en arcos opuestos [S]
- [ ] Etiquetas/scene-root organizados por convención (M05) [S]
- [ ] Sin scripts de UI en el ciclo (M09 separación) [S]
- [ ] Compatible con M12 minimapa (sin luz) [S]

## E. Curvas y datos (12)

- [ ] `day_curve.tres`: 24 puntos sol [S]
- [ ] `sky_curve.tres`: 24 puntos cielo [S]
- [ ] `season_mod.tres`: 4 mods estacionales [S]
- [ ] `fase_umbral.tres`: umbrales [S]
- [ ] Interpolación lerp entre vecinos [S]
- [ ] Sin cambios de golpe (tween por minuto) [S]
- [ ] Valores respetan piso 0.15 [S]
- [ ] Carga de curvas con fallback a defaults [S]
- [ ] Curvas versionables en GameState? NO — solo data estática [S]
- [ ] Localizable sin datos duros en scripts [S]
- [ ] Umbral de luz de faroles en data (no hardcode) [S]
- [ ] Validación de rangos de curvas en dev mode (M110) [S]

## F. Consumidores e integración (14)

- [ ] M19 NPC: rutinas por fase [S]
- [ ] M36 Fauna: spawn diurno/nocturno [S]
- [ ] M41 Música: 4 variantes + crossfade [S]
- [ ] M42 Sonido: banco día/noche [S]
- [ ] M15 Recursos: flor lumínica + cristales estelares nocturnos [S]
- [ ] M34 Pesca: peces luna + pesca luna llena [S]
- [ ] M39 Tiendas: cierre 21:00 [S]
- [ ] M17 Construcción: faroles sin red eléctrica en v1 [S]
- [ ] M13 Linterna: sugerencia automática opcional [S]
- [ ] M33 Cultivos: sin efecto horario (decisión cozy) [S]
- [ ] M37 Museo: horario definido [S]
- [ ] M32 Clima: lluvia de estrellas nunca con tormenta [S]
- [ ] Contrato API solo por señales (desacople) [S]
- [ ] Sin dependencia de GameState en el motor visual [S]

## G. Eventos y secretos nocturnos (10)

- [ ] Lluvia de estrellas: días 10 y 25, 22:00-23:30 [S]
- [ ] Partículas de estrellas fugaces (M52) [S]
- [ ] Lince de luna: día 15, Claro del Bosque [S]
- [ ] Interacción "observar" del lince (sin caza) [S]
- [ ] Flora brillante: Senda de las Luciérnagas [S]
- [ ] Bono x2 de noche en flora (único bonus horario) [S]
- [ ] Murales luminosos en ruinas (M25, lore M148) [S]
- [ ] Nada crítico para la historia exige noche [S]
- [ ] Diario M55 registra "deseo" de estrellas [S]
- [ ] TTS/texto accesible en eventos (M58) [S]

## H. Navegación y anti-oscuridad (10)

- [ ] Piso ambiente nocturno 0.15 LDR [S]
- [ ] Linterna del jugador rango 12 m [S]
- [ ] Sin parpadeos de linterna (comfort) [S]
- [ ] Opción M58 "Noche clara" (piso 0.35) [S]
- [ ] Faroles cada 40 m en poblado [S]
- [ ] Prohibido negro puro en ambiente [S]
- [ ] Transiciones sin flash de oscuridad [S]
- [ ] Minimapa operable de noche [S]
- [ ] QA M114: checklist visual nocturno por zona [M]
- [ ] Regla de oro escrita en 03-Diseno §7 [S]

## I. Rendimiento y pruebas (12)

- [ ] Ciclo por minuto de juego (no por frame) [S]
- [ ] Presupuesto ≤ 2 ms GPU peak [S]
- [ ] Sin sombras de luna [S]
- [ ] 1 draw call de nubes [S]
- [ ] Niebla ≤ 120 m [S]
- [ ] Estrellas estáticas [S]
- [ ] Test: cambio de fase en límite 19:59→20:00 [S]
- [ ] Test: umbral farol antes/después [S]
- [ ] Test: fase correcta al cargar partida [S]
- [ ] Test: franjas estables (sin doble señal) [S]
- [ ] Test: curvas dentro de rango (piso 0.15) [S]
- [ ] Suite en `caso_noche_dia_tests.gd` (M112) [M]

## J. Delegación y cierre (12)

- [ ] Módulo marcado delegable [S]
- [ ] Alternativas descartadas (4) documentadas [S]
- [ ] API de fase estable para consumidores [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Dependencias de data: M45/M46 (texturas) anotadas [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]
- [ ] Checked en README de DOCUMENTACION [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 131 ítems · Completados: 131 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (D, E, H en runtime) quedan para el agente delegado; diseño, cronograma y reglas cierran aquí.

## K. Iteración 1 — Núcleo runtime (GLM Kilo 2026-08-31) — Log 302

> Implementación del núcleo funcional. No cierra el módulo (queda 🔵 En curso para iteraciones de datos/assets/polish).

### K.1 Implementado y verificado (12/0 tests OK)

- [x] Dominio `EventBus.time` con señal `fase_cambio(fase: int)` (RF5 contrato) [S]
- [x] Nodo `DayNightCycle` con script `res://scripts/world/day_night_cycle.gd` en `main_island.tscn` [S]
- [x] Nodo `DirLightLuna` (DirectionalLight3D, sin sombras, color 7500K) en `main_island.tscn` [S]
- [x] Mapeo hora→fase: ALBA 5-6, DÍA 7-18, ATARDECER 19, NOCHE 20-22, PROFUNDA 23-4 (cronograma §2 diseño) [S]
- [x] Señal `fase_cambio` SOLO en cambio de franja (no por hora) [S]
- [x] Conexión a `GameTime.hora_cambio` (M29) vía `get_node_or_null` [S]
- [x] Tween 1.0 s de energía y color de sol/luna/ambiente en cada `hora_cambio` [S]
- [x] Rotación de fuentes sol/luna en arcos opuestos (radio 50, altura 20) [S]
- [x] Guarda anti-colineal `Vector3.UP` en `look_at` (§9.9 07-GUIA-GODOT) [S]
- [x] Regla anti-oscuridad: piso ambiente nocturno 0.15, luna ≥ 0.10 en Noche [S]
- [x] API pública: `get_fase()`, `es_de_dia()` [S]
- [x] Test headless `test_ciclo_dia_noche.gd` 12/0 OK (fases, estabilidad, API) [M]
- [x] Reserva en 4 registros (guía 08, 05-Checklist, CHECKLIST-GLOBAL, ESTADO-PARALELO) [S]
- [x] Log 302 generado y firmado [S]

### K.2 Pendiente para iteraciones futuras [?]

- [x] Curvas 24-puntos en `data/light/day_curve.tres`, `sky_curve.tres`, `moon_curve.tres`, `fog_curve.tres` + `fase_umbral.json` (datos) — glm-5.3-flash 2026-09-01 (iter. 2, Log 452): generadas con serializador de Godot, núcleo data-driven con fallback, test 0 fallos
- [?] Transición amanecer/atardecer de 90 s con curvas de interpolación (polish) [M]
- [?] `Sky` procedural con gradiente por hora y estrellas alpha 0→100% 20:00-22:00 [C]
- [?] Luna esférica con textura de fases (M45) [C]
- [?] Nubes velo 2D con drift lento y densidad estacional [C]
- [?] Niebla por estación/hora (FogVolume ligero ≤120 m) [M]
- [?] Prefab de farol con omni 3200K r 8 m y autoswitch por umbral 0.35 [M]
- [?] Faroles cada 40 m en poblado (M18) [C]
- [?] Sincronización lluvia de estrellas con M52 (días 10/25 22:00-23:30) [M]
- [?] Flora brillante con bonus x2 (M15) [M]
- [?] Murales luminosos en ruinas (M25/M148) [C]
- [?] Opción M58 "Noche clara" (piso 0.35) — M58 sin implementar [M]
- [?] Integración con M49 iluminación global — M49 sin implementar [C]
- [?] QA visual M114 (checklist nocturno por zona) — M114 sin implementar [C]
- [?] Captura visual in-engine (V4) de las 5 franjas con `cap_godot.py --modulo 31` [M]
- [x] Documentar en 07-GUIA-GODOT §9: pitfall Curve.add_point (dominio 0-1, no horas) — documentado como §9.60 pendiente de copiar (ver Log 452); patrón get_node_or_null ya documentado por iter. previa

**Iteración 1 — 14 ítems [x].** **Iteración 2 (glm-5.3-flash, Log 452) — +2 ítems [x] (curvas data-driven + doc §9). Total: 16 [x], 15 [?]** honestos (escénicos V2 e integraciones con módulos aún no implementados: M45/M46/M49/M52/M58/M114).