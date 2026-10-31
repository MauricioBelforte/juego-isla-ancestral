# ANEXO A — FORMULA-C: 37 flips contrarios, línea a línea (ola Beam 13-14oct)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 22:12 local (2026-10-31 01:12Z)
**Vuelta:** 24 del cron (override 205 del fundador) — nicho auditoría/doc/i18n
**Estado:** REPORT-ONLY. 0 flips aplicados. Las 37 líneas siguen `[x]` en sus módulos (propiedad de sus dueños; degradación = decisión director/fundador, ver §6).

---

## 1. Definición y método

**FORMULA-C** = línea `- [x]` de un `plan-actual/05-Checklist.md` que contiene la fórmula legítima de flip ("FORMULA (Beam T#) … Flipado tras verificacion de artefacto en disco") **Y evidencia contraria EN LA MISMA LÍNEA** (AUDIT step-5-kilocode 2026-10-13/14 o anotación BUG-070 lote 8). Es la contradicción nacida documentada: el flip y su refutación viajan juntos.

- **Extracción (repo-wide, 2026-10-30):** `rg "Flipado tras verificacion de artefacto en disco.*(sin implementar|no implementado|0 hits|inexistente|no tiene|no existe|no verificable|ausente|sin evidencia|sin artefacto|no construido|sin construir)" -g "**/05-Checklist.md"` → **37 líneas, 4 módulos**.
- **Clasificación de bucket:** con el **código real del detector v7** (`scripts/detectar_autocontradiccion.py` importado; misma pasada 1 orden exclusivo FP→R4→A1→A3→A2→C2→SOS + pasada 2 promoción vecinal ±4). Resultado: **A2=27 · C2-promovido-por-vecinos=4 · sin-bucket=6**. Las 37 son `FORMULA_OK=True` (viven dentro de los 80 legítimos de forma — FORMULA_OK es contador paralelo, no exclusión de bucket).
- **Contexto de ola:** Beam T# 343-480 (13-14oct, produce-first step-5-kilocode) — **DISTINTA** de la ola FLIP26 26oct (R4=239). Los mismos 4 módulos lideran AMBAS olas (R4 26oct: 27=30, 156=27, 31=14, 34=10).
- **Conteos v7 canónicos del detector (re-corrida 2026-10-31 00:5xZ, determinista):** 168 checklists · 23.029 [x] · FORMULA 80 · GRIS 209 · A1=32 · R4=239 · A3=31 · A2=219 · C2=561 · SOS=313 · FP=4.

## 2. Tabla maestra (37 líneas)

### 34-Pesca — 6 líneas (AUDIT 2026-10-13 step-5-kilocode)

| L | Ítem (corto) | Esc | Beam | Evidencia contraria (token de la línea) | Existe previo (parcial) | Dueño(s) | Bucket v7 | Subfamilia |
|---|---|---|---|---|---|---|---|---|
| 47 | P23: desafíos objetivos opcionales (catálogo completo, pez más grande) | M | 439 | los desafíos opcionales 'catalogo completo' y 'pez mas grande' **no existen** (logros.json: 17 logros, solo 2 de pesca) | achievement_service.gd L141-144 consume captura_exitosa→_on_captura_pesca (producción, verificado; test_logros.gd L88-106) | M72 (logros) | A2 | (b) |
| 111 | Evento de festival (M29) con bono temporal de capturas | M | 346 | fishing_manager.gd **0 hits** de festival/evento; M34 no consume evento_activado para bonos | time_calendar.gd: signal evento_activado L13 + _on_evento_activado L101; proximos_eventos L138-147 ("festival" repetible) | M29 (eventos) + M34 (cableado) | A2 | (b) |
| 134 | Notificación de nueva especie al catálogo | S | 346 | **0 hits** de NotificationService/notificar_nueva_especie | registrar_captura() existe; dato veces==1 detectable | M53 (consumo/vista) | A2 | (b) |
| 179 | Modo accesibilidad "captura automática" (M57) | M | 473 | el toggle de captura automática es de M57 y **no existe** | la FSM admite notificar_pulsacion_boton() programática (fishing_session.gd L63) | M57 | A2 | (b) |
| 184 | Peces ancestrales con presentación suave (burbujas doradas, sin combate) | M | 473 | presentación suave (burbujas doradas) = data M93 + VFX M52, **inexistentes** | 'sin combate' SÍ garantizado por diseño (sesión sin castigos; captura_fallida no punitivo L227) | M93 (data) + M52 (VFX) | A2 | (b) |
| 199 | Registro de capturas para telemetría de balance (sin afectar determinismo) | M | 473 | telemetria_m104.gd (M105) es consumido por pausa_contemplativa/house_manager/transport_route_events — **NO por pesca**: el registro para balance **no existe** | achievement_service.gd L141-144 consume captura_exitosa para stats (producción) — pero para logros, no para balance | M105 (telemetría) | A2 | (b) |

### 31-Ciclo-Dia-Noche — 20 líneas (AUDIT 2026-10-14 step-5-kilocode)

| L | Ítem (corto) | Esc | Beam | Evidencia contraria (token de la línea) | Existe previo (parcial) | Dueño(s) | Bucket v7 | Subfamilia |
|---|---|---|---|---|---|---|---|---|
| 46 | P8: nubes — velo 2D con drift, densidad estacional | C | 415 | **sin implementar** (0 hits de nubes/velo/drift en scripts/islas ni world) | — | M45 (K.2 escénico) | C2-promovido* | (a) |
| 49 | P11: niebla — matinal otoño, bruma verano, densa invierno, nocturna 0.25 | M | 415 | el nodo FogVolume **no existe** en escenas .tscn (0 hits) | fog_curve.tres data por hora EXISTE (fase_umbral.json §niebla; Log curvas iter 2) | M31/M45 | A2 | (b) |
| 55 | P17: spawn de recursos — nocturnos opcionales (nunca críticos) | M | 423 | recurso nocturno **inexistente**; M15 sin ventana horaria | M15 tiene temporada_respawn (iter 5, estación) | M15 (contenido) + M31 (hook horario futuro) | A2 | (b) |
| 57 | P19: eventos nocturnos — lluvia de estrellas días 10 y 25 | M | 423 | evento calendario M74 + partículas M52 **sin implementar**; la cadena completa no está implementada | datos de estrellas existen en JSON | M74 + M52 | sin-bucket* | (b) |
| 58 | P20: secretos nocturnos — flora brillante + murales lore | M | 423 | **0 hits** de flora brillante ni murales lore | — | M15/M25/M148 (G) | A2 | (a) |
| 83 | Nubes velo 2D con drift lento | S | 423 | **sin implementar** (0 hits en scripts/islas ni world) | — | M45 (K.2) | C2-promovido* | (a) |
| 84 | Niebla (FogVolume ligero) | S | 473 | el nodo FogVolume **no existe** en ninguna escena .tscn (0 hits) | data fog_curve.tres existe (fase_umbral.json §niebla) | M31/M45 | C2-promovido* | (b) |
| 85 | Prefab de farol con omni 3200K | S | 473 | **0 hits** de prefab de farol con luz omni 3200K en escenas (los 30 hits de 'farol' son puzzles de cadenas, test_historias.gd) | — | M18/M45 (K.2) | C2-promovido* | (a) |
| 118 | M15 Recursos: flor lumínica + cristales estelares nocturnos | M | 415 | flor lumínica y cristales estelares **inexistentes**; M15 solo tiene temporada_respawn (iter 5) | respuesta estacional de M15 existe | M15 (contenido); M93 (data) | A2 | (b) |
| 133 | Lluvia de estrellas: días 10 y 25, 22:00-23:30 | M | 476 | evento de calendario (días 10/25) y partículas = M74/M52 **sin implementar** | fase_umbral.json §estrellas documenta la ventana 20:00-22:00 | M74/M52 | sin-bucket* | (b) |
| 134 | Partículas de estrellas fugaces (M52) | C | 476 | M52 **sin implementar** (0 hits de partículas de estrellas en scripts) | — | M52 | A2 | (a) |
| 135 | Lince de luna: día 15, Claro del Bosque | C | 415 | **0 hits** de lince en data/fauna/catalog.json (7 especies listadas) | — | M36/M93 (fauna especial) | A2 | (a) |
| 141 | Diario M55 registra "deseo" de estrellas | S | 476 | M55 **sin implementar** (0 hits de diario en scripts) | — | M55 | A2 | (a) |
| 142 | TTS/texto accesible en eventos (M58) | M | 476 | M58 **sin implementar** para TTS | — | M58 | sin-bucket* | (a) |
| 150 | Faroles cada 40 m en poblado | C | 476 | prefab farol **inexistente**; M18-BIS 🔵 WorkBuddy construyendo casas — coordinar al liberar | — | M18/M45 | A2 | (a) |
| 153 | Minimapa operable de noche | S | 476 | **CONTRADICCIÓN INTERNA**: nota Beam dice "M12 minimapa sin implementar" vs AUDIT "M12 minimapa SI existe en disco (mapa_manager.gd) pero sin modo nocturno" | mapa_manager.gd SÍ existe (sin modo nocturno) | M12 | sin-bucket* | (b)+(c) |
| 223 | Prefab de farol con omni 3200K r 8 m y autoswitch por umbral 0.35 | M | 477 | **0 hits** de prefab de farol con luz omni 3200K en escenas (30 hits 'farol' = puzzles de cadenas) | — | M18/M45 (K.2) | A2 | (a) |
| 224 | Faroles cada 40 m en poblado (M18) | C | 477 | prefab farol **inexistente**; M18-BIS WorkBuddy construyendo casas — coordinar al liberar | — | M18/M45 | A2 | (a) |
| 225 | Sincronización lluvia de estrellas con M52 (días 10/25 22:00-23:30) | M | 477 | la sincronización con M52 (días 10/25) es de M74/M52 **sin implementar** | fase_umbral.json §estrellas tiene la ventana | M74/M52 | sin-bucket* | (b) |
| 226 | Flora brillante con bonus x2 (M15) | M | 477 | el bonus x2 es de M15/M93 **sin implementar** | hook es_de_dia() EXISTE (game_clock.gd L120, time_calendar.gd L155, day_night_cycle.gd L207) | M15/M93 | sin-bucket* | (b) |

### 27-Islas-Del-Mundo — 8 líneas (AUDIT 2026-10-13 step-5-kilocode)

| L | Ítem (corto) | Esc | Beam | Evidencia contraria (token de la línea) | Existe previo (parcial) | Dueño(s) | Bucket v7 | Subfamilia |
|---|---|---|---|---|---|---|---|---|
| 77 | Log WARN con detalle de cada ancla re-rollada | S | 343 | **0 hits** de re-roll/reroll/re_roll en scripts/islas ni world; **no existe** log WARN de ancla re-rollada | — | M10 | A2 | (a) |
| 92 | Emitir isla_cargando(id, progreso, etapa) en cada etapa | S | 343 | **0 hits** de signal isla_cargando | existe signal island_loaded(island) en event_bus.gd L120 — pero sin progreso ni etapa | M10 | A2 | (b) |
| 93 | Emitir isla_cargada(id) al 100% | S | 343 | **0 hits** de signal isla_cargada | island_loaded(island) sin id de etapa ni 100% | M10 | A2 | (b) |
| 94 | Emitir isla_descargada(id) al liberar | S | 343 | **0 hits** de signal isla_descargada; **no existe** señal de liberación | — | M10 | A2 | (a) |
| 98 | isla_actual() -> StringName rastreada por el servicio | S | 343 | los 9 hits de isla_actual son parámetros de funciones de island_travel_guard.gd; **no existe** isla_actual()->StringName rastreada por un servicio | hits parciales (como parámetros) | M10 | A2 | (b) |
| 136 | Si la isla destino ya está cacheada, la travesía se salta la carga (inmediato) | M | 469 | **no existe** cacheado(id) (ver item 13) ni lógica de saltear carga; la travesía siempre evalúa carga | — | M10 | A2 | (a) |
| 202 | Telemetría de carga (M105): tiempos por isla, memoria, errores | C | 470 | **0 hits** de telemetría de carga por isla (tiempos/memoria/errores) ligada a M105 | — | M105 | A2 | (a) |
| 221 | El mapa muestra nombre de la isla al pasar el cursor (M54) | S | 470 | **0 hits** de tooltip/nombre en mapa dentro de islas/; el mapa es de M54 | — | M54 | A2 | (a) |

### 156-Terrenos-Y-Movimiento — 3 líneas (anotaciones BUG-070 lote 8; sin AUDIT step-5)

| L | Ítem (corto) | Esc | Beam | Evidencia contraria (token de la línea) | Existe previo (parcial) | Dueño(s) | Bucket v7 | Subfamilia |
|---|---|---|---|---|---|---|---|---|
| 247 | Implementar fade al cambiar terreno | M | 479 | BUG-070 lote 8: feedback audio inexistente — play_footstep = **0 hits** en scripts/ | FORMULA cita 03 "Spec feedback de terreno" §Fade (ver nota §4) | M156 (propio) | A2 | (a) |
| 270 | Agregar ProgressBar para velocidad efectiva | S | 346 | BUG-070 lote 8: indicador UI inexistente — TerrainIndicator/terrain_indicator = **0 hits** en scripts/ y scenes/ | TerrainModifiers static cap 50% testeado §4.2; cap clampf 0-0.5 testeado | M156 (propio) | A2 | (a) |
| 354 | Agregar TerrainFootstepAudio al jugador | M | 480 | BUG-070 lote 8 Patron D: el entregable padre **no existe** (terrain_footstep_audio.gd L214 [?]; terrain_indicator.tscn L258 [ ]); grep **0 hits** | — | M156 (propio) | A2 | (a) |

\* **C2-promovido / sin-bucket = límites del detector v7** (ver §5), NO resolución real: la línea misma sigue trayendo evidencia contraria.

## 3. Subfamilias

- **(a) Entregable totalmente inexistente (19):** 156 L247/L270/L354 · 31 L46/L58/L83/L85/L134/L135/L141/L142/L150/L223/L224 · 27 L77/L94/L136/L202/L221.
- **(b) Parcial — infraestructura/data/hook/contrato SÍ existe, entregable específico NO (18):** 34 ×6 (padre achievement_service/eventos/dato detectable/FSM/diseño sin-castigo/stats) · 31 L49/L55/L57/L84/L118/L133/L153/L225/L226 (fog_curve, temporada_respawn, data JSON, ventana fase_umbral, hook es_de_dia) · 27 L92/L93/L98 (island_loaded, hits como parámetros).
- **(c) Contradicción interna nota↔AUDIT en la misma línea (1):** 31 L153 — nota Beam "M12 minimapa sin implementar" vs AUDIT "mapa_manager.gd SÍ existe pero sin modo nocturno". Artefactos distintos (ya flaggeado en informe padre §6; QA atria M12 verificó minimap_view.gd inexistente).

## 4. Casos emblemáticos

1. **31 L153 (minimapa nocturno):** único caso (c) — la línea se contradice a sí misma. El mapa SÍ existe (mapa_manager.gd); lo inexistente es el modo nocturno. Acción: corregir la nota Beam ("sin implementar" → "sin modo nocturno") y degradar solo ese alcance. Dueño M12.
2. **156 L247/L270/L354 (BUG-070 lote 8):** deuda viva PROPIA de M156 (play_footstep, TerrainIndicator, TerrainFootstepAudio = 0 hits en scripts/ y scenes/). Los padres ya están honestos en el checklist (L214 [?], L258 [ ]). Nota de precisión en L247: la evidencia contraria anotada es de audio (play_footstep) mientras el ítem dice "fade" visual — ambigüedad del spec "Spec feedback de terreno"; el fade visual no queda verificado por la línea.
3. **34 L47 (desafíos de pesca):** el padre SÍ está consumido en producción (achievement_service.gd L141-144 + test_logros.gd L88-106); lo inexistente son los desafíos opcionales 'catálogo completo' y 'pez más grande' (logros.json: 17 logros, 2 de pesca).
4. **27 L92/L93 (señales de carga):** island_loaded(island) SÍ existe (event_bus.gd L120) pero sin progreso/etapa/100% — la señal declarada en el ítem (isla_cargando/isla_cargada con id) no existe.

## 5. Límites del detector v7 expuestos por esta familia (candidatos v8)

1. **Promoción vecinal sobre línea contraria:** L46/L83/L84/L85 suben a C2 porque un vecino (±4) trae resolución fuerte — pero la evidencia contraria está en la PROPIA línea. La promoción debería excluir líneas con CONTRARIA propia (o requerir que el vecino resuelva EL MISMO entregable).
2. **'sin implementar' no está en CONTRARIOS_A2:** L57/L133/L142/L153/L225/L226 quedan sin bucket (invisibles para A2). Forma recomendada: agregar `r'sin implementar'` a CONTRARIOS_A2 (la guardia RESUELTO_LINEA ya existe).
3. **FORMULA_OK es contador paralelo:** las 37 se bucketean además (dual classification). Una línea puede ser FORMULA legítima de forma Y deuda viva de fondo — el contador de 80 no debe leerse como "80 limpias".

## 6. Acción sugerida (DECISIÓN DIRECTOR/FUNDADOR — Ling no flipea)

- **Degradación `[x]`→`[?]`** con deuda anotada y dueño, por dueño de módulo + QA cruzada §21.8 (agnes/Hy3); re-baseline de Totales en los 4 módulos (34: 153 ítems; 31/27/156: sus propios Totales).
- **Criterio aplicable:** msg 448 + re-baseline M11 + TANDA 6 de DeepSeek (commit `531f597`) apuntan a degradar masivamente; la convención Beam "[x]-con-spec" sigue sin decidir (afecta R4 239 + SOS 313 + FORMULA-C 37).
- **Para 156:** alinear con BUG-070 lote 8 (padres ya `[?]`/`[ ]` en L214/L258).
- **Para 31 L153:** corregir nota Beam (artefacto SÍ existe) y degradar solo el modo nocturno.
- **Cross-refs:** DeepSeek TANDA 7 (`grep_repowide_autocontradictorio`, PATRON A, estado_director.json) — esta tabla es el detalle línea a línea que su grep repo-wide solo cuenta; agnes gate-1 (kit anti-inflación del relevo 1-nov: mapa frágiles + SOP + muestreo_p100 + auditoría + detector).

## 7. Trazabilidad

- **Extracción:** rg del §1 sobre `DOCUMENTACION/**/plan-actual/05-Checklist.md` (2026-10-30 21:4x local).
- **Clasificación:** `Temp/kilo/clasif_formulac.py` (importa `scripts/detectar_autocontradiccion.py` v7; replica pasada 1 + pasada 2). Detector re-corrido con `--out Temp/kilo/v24_detector.txt` (conteos canónicos v7, deterministas).
- **Docs vinculadas:** informe padre `AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md` §8(iv) + §14 · estado_director.json (campos `grep_repowide_autocontradictorio`, `ling_mapa_fragiles`, `decisiones_fundador`).
- **Reporte:** msg 333 al canal Ling-3.1-Flash · **Log 2270** · BACKLOG-MASTER ESTADO v24.
- **Repo:** HEAD `5d6105a` · 0 flips aplicados · 0 push · riel PT intacto (pt.po sha1 95ee2ce0d1, K1-K4 vivos, git status riel vacío).

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-30 22:12 local (2026-10-31 01:12Z).
