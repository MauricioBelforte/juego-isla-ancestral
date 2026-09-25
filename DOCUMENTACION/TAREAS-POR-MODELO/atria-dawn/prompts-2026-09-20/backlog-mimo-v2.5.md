**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — mimo-v2.5

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** Reconciliacion + VFX visual (vision + godot-mcp operativos)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente mimo-v2.5 --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 31-Ciclo-Dia-Noche (49 pendientes)

- [?] **T-001 31:** P6: estrellas — canvas procedural, alpha 0→100% 20:00-22:00 [C] → parámetros en fase_umbral.json §estrellas (alpha_inicio 20, fin 22, max 1.0); can...
- [?] **T-002 31:** P7: luna — esfera + fases del calendario M29 [C] → luz OK; esfera con textura de fases = M45 (K.2)
- [?] **T-003 31:** P8: nubes — velo 2D con drift, densidad estacional [C] → sin implementar; escénico V2 (K.2)
- [?] **T-004 31:** P11: niebla — matinal otoño, bruma verano, densa invierno, nocturna 0.25 [M] → `fog_curve.tres` data por hora EXISTE (Log curvas iter. 2); FogVolum...
- [?] **T-005 31:** P17: spawn de recursos — nocturnos opcionales (nunca críticos) [M] → M15 tiene temporada_respawn (iter. 5 estación) pero NO ventana horaria; recurs...
- [?] **T-006 31:** P19: eventos nocturnos — lluvia de estrellas días 10 y 25 [M] → data estrellas en JSON; evento calendario de M74 + partículas M52 sin implementar (...
- [?] **T-007 31:** P20: secretos nocturnos — flora brillante + murales lore [M] → no implementado; dueños M15/M25/M148 (G)
- [?] **T-008 31:** Luna esférica con textura de fases [S] → luz sin mesh — M45 (K.2)
- [?] **T-009 31:** Nubes velo 2D con drift lento [S] → sin implementar (K.2)
- [?] **T-010 31:** Niebla (FogVolume ligero) [S] → data fog_curve.tres; FogVolume nodo no existe en escena (K.2)
- [?] **T-011 31:** Prefab de farol con omni 3200K [S] → sin implementar; dueño M18/M45 (K.2)
- [?] **T-012 31:** Canvas de estrellas [S] → sin implementar (K.2)
- [?] **T-013 31:** Compatible con M12 minimapa (sin luz) [S] → M12 minimapa sin implementar (fila 12 global); la regla "sin luz" documentada en diseño §4
- [?] **T-014 31:** `season_mod.tres`: 4 mods estacionales [S] → NO existe; curva única anual (K.2 visual fino)
- [?] **T-015 31:** Validación de rangos de curvas en dev mode (M110) [M] → M110 dev tools sin implementar; test_curvas_luz valida rangos en CI (parcial, dueño M110)
- [?] **T-016 31:** M15 Recursos: flor lumínica + cristales estelares nocturnos [M] → M15 solo tiene respawn estacional (iter. 5); contenido nocturno inexistente — due...
- [?] **T-017 31:** M17 Construcción: faroles sin red eléctrica en v1 [S] → M17 sin faroles; puzzle farol_cargado existe en M23 data — dueño M17/M18
- [?] **T-018 31:** M13 Linterna: sugerencia automática opcional [S] → M13 sin linterna (grep 0); dueño M13 contenido + M92 sugerencia
- [?] **T-019 31:** M37 Museo: horario definido [M] → scripts/museos inexistente; M37 28/148 fila global — dueño M37
- [?] **T-020 31:** M32 Clima: lluvia de estrellas nunca con tormenta [S] → WeatherService enum sin "lluvia de estrellas" (es evento M74 + partículas M52); coordinació...
- [?] **T-021 31:** Lluvia de estrellas: días 10 y 25, 22:00-23:30 [M] → fase_umbral.json §estrellas documenta la ventana; evento del calendario + partículas = M74/M52
- [?] **T-022 31:** Partículas de estrellas fugaces (M52) [C] → M52 sin implementar
- [?] **T-023 31:** Lince de luna: día 15, Claro del Bosque [C] → fauna especial de M36/M93 data
- [?] **T-024 31:** Interacción "observar" del lince (sin caza) [M] → ídem
- [?] **T-025 31:** Flora brillante: Senda de las Luciérnagas [C] → M15 contenido + M45 assets
- [?] **T-026 31:** Bono x2 de noche en flora (único bonus horario) [M] → hook futuro: consumers pueden leer es_de_dia(); implementación M15/M93
- [?] **T-027 31:** Murales luminosos en ruinas (M25, lore M148) [C] → dueños M25/M148
- [?] **T-028 31:** Diario M55 registra "deseo" de estrellas [S] → M55 sin implementar
- [?] **T-029 31:** TTS/texto accesible en eventos (M58) [M] → M58 sin implementar
- [?] **T-030 31:** Linterna del jugador rango 12 m [M] → no existe (M13/M45) — dueño externo
- [?] **T-031 31:** Opción M58 "Noche clara" (piso 0.35) [M] → M58 sin implementar; el piso es constante en curva — el hook sería parametrizar sky_curve (K.2 con dueño...
- [?] **T-032 31:** Faroles cada 40 m en poblado [C] → M18-BIS 🔵 WorkBuddy está construyendo casas — coordinar al liberar; prefab farol inexistente
- [?] **T-033 31:** Minimapa operable de noche [S] → M12 minimapa sin implementar
- [?] **T-034 31:** QA M114: checklist visual nocturno por zona [M] → M114 sin implementar; soy solo-texto — QA visual del usuario o agente con visión
- [?] **T-035 31:** 1 draw call de nubes [S] → sin nubes (D); la regla queda para el dueño escénico
- [?] **T-036 31:** Test: umbral farol antes/después [M] → sin autoswitch runtime (RF6 [?]) — test se escribirá con la feature (dueño M18/M45)
- [?] **T-037 31:** Transición amanecer/atardecer de 90 s con curvas de interpolación (polish)
- [?] **T-038 31:** `Sky` procedural con gradiente por hora y estrellas alpha 0→100% 20:00-22:00
- [?] **T-039 31:** Luna esférica con textura de fases (M45)
- [?] **T-040 31:** Nubes velo 2D con drift lento y densidad estacional
- [?] **T-041 31:** Niebla por estación/hora (FogVolume ligero ≤120 m)
- [?] **T-042 31:** Prefab de farol con omni 3200K r 8 m y autoswitch por umbral 0.35
- [?] **T-043 31:** Faroles cada 40 m en poblado (M18)
- [?] **T-044 31:** Sincronización lluvia de estrellas con M52 (días 10/25 22:00-23:30) [M] — **precisión QA V2 agnes-3-flash (Log 1052, 2026-09-19): el catálogo M52 (...
- [?] **T-045 31:** Flora brillante con bonus x2 (M15)
- [?] **T-046 31:** Murales luminosos en ruinas (M25/M148)
- [?] **T-047 31:** Opción M58 "Noche clara" (piso 0.35) — M58 sin implementar
- [?] **T-048 31:** Integración con M49 iluminación global — M49 sin implementar
- [?] **T-049 31:** QA visual M114 (checklist nocturno por zona) — M114 sin implementar

## 52-Particulas-Y-VFX (11 pendientes)

- [ ] **T-050 52:** Definir presupuesto por preset (M90)
- [ ] **T-051 52:** Definir triggers en timelines (M48)
- [ ] **T-052 52:** Definir burbujas + ascuas de lava
- [ ] **T-053 52:** Definir chapoteo de balde (M13)
- [ ] **T-054 52:** Definir estelas de luz (M47)
- [ ] **T-055 52:** Definir partículas 2D en menús/recompensas (M53)
- [ ] **T-056 52:** Definir Reduce Motion (M58)
- [ ] **T-057 52:** Cozy: amplitudes suaves, sin humo denso negro
- [ ] **T-058 52:** Riesgo de efectos fuera de estilo → guía de amplitudes + review
- [ ] **T-059 52:** Escena pivote sin exceder límites y sin caída de fps
- [?] **T-060 52:** Catálogo de VFX por evento (M44 feedback + M92 tutorial): iter 2 — catálogo data-driven (dueño: deepseek-v4-flash-vision-exp)

---

## Meta

60 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
