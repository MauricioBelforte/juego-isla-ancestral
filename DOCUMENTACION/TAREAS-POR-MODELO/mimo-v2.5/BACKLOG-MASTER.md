**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# BACKLOG MASTER — MiMo V2.5

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` + bugs asignados + fortalezas del modelo (§12.5 de `10-GUIA-COMPARATIVA-MODELOS.md`).

**Módulos asignados:** 14  |  **Tareas pendientes totales:** ~850

> Última actualización: 2026-09-17 (mimo-v2.5, OpenCode)

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Rol

> **MiMo V2.5** no es solo un agente ejecutor — es el **acompañante y director técnico** del usuario. Mi trabajo incluye:
> - **Ejecutar** tareas de código, documentación, bugs, terreno, UI, etc.
> - **Acompañar** al usuario en cada sesión, mantener contexto, recordar cosas pendientes.
> - **Dirigir** la consistencia del proyecto: logs, referencias, documentación, protocolo multiagente.
> - **Parchar** errores de otros modelos (duplicados de logs, refs rotas, código mal escrito).
> - **Proponer** mejoras, detectar problemas, alertar sobre riesgos.
> - **Mantener** el proyecto sano: `CHECKLIST-GLOBAL.md`, `11-BUGS.md`, `GUIA-GODOT/INDICE.md`, `Logs/NUMEROS_DISPONIBLES.txt`.

## Fortalezas del modelo (por qué estos módulos)

| Fortaleza | Módulos relacionados |
|-----------|---------------------|
| Arquitectura de sistemas complejos | M08, M10, M53 |
| Integración entre sistemas | M160, M156 |
| Core gameplay (movimiento, cámara, jugador) | M11, M12 |
| Análisis de bugs y debugging | M08 (BUG-019), M10 (BUG-020) |
| Eficiencia token en tareas agentic largas | Todos |

## Orden de trabajo

| # | ID | Módulo | Estado global | Progreso | Prioridad | Pendientes | Subcarpeta |
|---|----|--------|---------------|----------|-----------|------------|------------|
| 1 | 53 | 53-UI-UX | 🟡 Con dudas | 130/158 | Alta | 28 | `53-UI-UX/checklist.md` — 82%, items restantes dependen de M57/M58/M63/M90 |
| 2 | 160 | 160-Ubicaciones | 🟡 Con dudas | 148/155 | Alta | 7 | `160-Ubicaciones/` — verificado: 5 [?] bloqueados M25/M28, 2 [ ] pendientes |
| 3 | 156 | 156-Terrenos-Y-Movimiento | 🟡 Con dudas | 246/307 | Media | 61 | `156-Terrenos/` — 59 [ ] pendientes (integracion M11/M155, assets audio/visual, escenas, polish), 2 [?] |
| 4 | 154 | 154-Vision-Del-Agente | ✅ | 155/155 | Media | 0 | `154-Vision/checklist.md` — ✅ completado |
| 5 | 78 | 78-Legal-Propiedad-Intelectual | ✅ | 159/159 | Alta | 0 | `78-Legal-PI/` — ✅ completado |
| 6 | 84 | 84-Musica-Y-Audio-Legal | 🔵 En curso | 77/100 | Alta | 23 | `84-Musica-Y-Audio-Legal/` — pendiente: edge cases, build logging |
| 7 | 131 | 131-Creditos | 🟡 Con dudas | 83/94 | Media | 11 | `131-Creditos/` — limpieza completada, 9 [?] bloqueados audio M41/M42/M43 |
| 8 | 150 | 150-Diseno-Sonoro-Narrativo | 🟡 Con dudas | 146/150 | Media | 4 | `150-Diseno-Sonoro/` — 17 items cerrados por spec, 4 [?] pendientes (M22, M148, M41/M42/M43) |
| 9 | 166 | 166-Variantes-Rendimiento | ✅ | 112/112 | Alta | 0 | `166-variantes/` — ✅ completado |
| 10 | 168 | 168-Plantilla-De-Isla | ✅ Completado | 104/104 | — | 0 | `168-Plantilla/` |
| 11 | 08 | 08-Mundo-Voxel | ✅ Completado | 108/108 | — | 0 | `08-Mundo-Voxel/` |
| 12 | 10 | 10-Generacion-Del-Mundo | ✅ Completado | 92/92 | — | 0 | `10-Generacion/` |
| 13 | 11 | 11-Personaje-Del-Jugador | ✅ Completado | 53/53 | — | 0 | `11-Personaje/` |
| 14 | 12 | 12-Camara | ✅ Completado | 104/104 | — | 0 | `12-Camara/` |

## Notas

- M78, M166, M168, M08, M10, M11, M12 están **completados** — incluidos para bugs/regresiones.
- M53 (UI) en 82%: items restantes dependen de M57/M58/M63/M90.
- M154 (Visión) casi completo: solo 2 items pendientes.
- M160, M156: módulos core de world-building (vacíos/poco avanzados).
- M84, M131, M150: módulos de contenido/audio en progreso.
- **Rol director/companion:** verifico consistencia, logs, referencias, propongo mejoras.

## Tareas adicionales completadas

| Fecha | Tarea | Detalle |
|-------|-------|---------|
| 2026-09-03 | Limpieza Logs/ (135 archivos) | Eliminé 42 duplicados, renombré 67 archivos, eliminé 26 residuales. stepfun corrompió nombres con prefijos `dup*` y sin `.md`. Documentado en §13 de10-GUIA-COMPARATIVA-MODELOS.md. |
| 2026-09-04 | Corrección logs duplicados (3 rondas) | AGNES creaba logs con números repetidos. Ronda 1: 9 archivos → 610-618. Ronda 2: 3 AGNES → 619-621. Ronda 3: 16 AGNES → 622-637. Referencias docs corregidas (M75 608→617, M162 609→618). §10.17 de GUIA-GODOT/08-terreno-voxel.md creado (cómo modificar terreno correctamente). `ULTIMO_NUMERO.txt` = 637, 622 logs, 0 duplicados. |
| 2026-09-04 | Fix agua orilla (island_generator.gd) | Corregido dirección de expansión del agua: de 0.94-0.98 → 0.94-1.03 (×3 hacia el mar, no hacia la arena). Sync en get_height, get_block_at, validador_isla_raiz.gd. |

## Tarea recurrente diaria (siempre al inicio de sesión)

> **REGLA PERSONAL (MiMo V2.5):** Al inicio de CADA sesión, ANTES de cualquier otra tarea, DEBO automáticamente (sin que el usuario lo pida):
> 1. Leer `Logs/NUMEROS_DISPONIBLES.txt` → verificar que hay números disponibles.
> 2. Si se agotaron → agregar más números al final (1501, 1502, ...).
> 3. Buscar referencias rotas en docs (`grep "Log XXX"` en DOCUMENTACION/, CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md, 11-BUGS.md).
> 4. Corregir las referencias para que apunten al archivo correcto.
> 5. Anotar en este backlog lo que hice.
> 
> **Cualquier modelo puede causar duplicados** — yo soy el parche que mantiene la consistencia. Esto NO es opcional — es parte de mi protocolo de arranque.

## Regla de guardado de assets Blender

> **REGLA (MiMo V2.5):** Cuando el usuario me pida guardar un modelo de Blender, **SIEMPRE** guardo primero el `.blend` en `tools/mcp/blender-mcp/{ID-Fauna}/` (o la carpeta del módulo que corresponda). **NO exporto GLB directamente** a `game/...` sin aprobación explícita del usuario.
>
> **Flujo:**
> 1. Ejecutar script en Blender → verificar resultado (screenshot + stats).
> 2. Guardar `.blend` en `tools/mcp/blender-mcp/{ID-Modulo}/` con nombre descriptivo.
> 3. Presentar resultado al usuario para aprobación.
> 4. Solo si el usuario aprueba → exportar GLB a `game/isla-ancestral/assets/3d/`.
>
> **Razón:** El usuario quiere revisar los modelos antes de integrarlos al juego. Las pruebas van primero en la carpeta del módulo.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).

## ⚠️ NOTA IMPORTANTE — Si se eliminaron las charlas de OpenCode (2026-09-04)

> **SI ESTÁS LEYENDO ESTO ES PORQUE SE ELIMINARON LAS CHATS O SE REINSTALÓ OPENCODE.**
>
> **¿Quién soy?** MiMo V2.5, el acompañante y director técnico del usuario.
>
> **¿Qué hago?**
> - Ejecuto tareas de código, documentación, bugs, terreno, UI
> - Acompaño al usuario en cada sesión, mantengo contexto
> - Dirijo la consistencia del proyecto: logs, referencias, documentación
> - Parcheo errores de otros modelos (duplicados de logs, refs rotas)
> - Mantengo el proyecto sano
>
> **¿Qué hacer ahora?**
> 1. Leer `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` para configurar MCP
> 2. Leer `DOCUMENTACION/GUIA-GODOT/INDICE.md` para errores comunes
> 3. Leer `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` para saber qué modelos funcionan
> 4. Ejecutar verificación de logs duplicados (tarea recurrente)
> 5. Revisar `CHECKLIST-GLOBAL.md` para saber el estado del proyecto
>
> **Estado del proyecto al momento de la última sesión:**
> - 167 módulos, ~12,341/23,459 ítems (52.6%)
> - Sistema de numeración v3: `Logs/NUMEROS_DISPONIBLES.txt` (fuente de verdad)
> - M53 UI-UX: 130/158 (82%), M166 completado, M78 completado
>
> **Archivos clave:**
> - `opencode.json` — Configuración MCP (ver `DOCUMENTACION/GUIA-CONFIGURACION-OPENCODE.md`)
> - `CHECKLIST-GLOBAL.md` — Estado global de módulos
> - `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.5/BACKLOG-MASTER.md` — Este archivo
>
> **GUÍA DE REINSTALACIÓN:** `DOCUMENTACION/GUIA-CONFIGURACION-OPENCODE.md`

---

## ACTUALIZACION 2026-09-20 — nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente — **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

### 31-Ciclo-Dia-Noche (49 pendientes)

- [?] P6: estrellas — canvas procedural, alpha 0→100% 20:00-22:00 [C] → parámetros en fase_umbral.json §estrellas (alpha_inicio 20, fin 22, max 1.0)...
- [?] P7: luna — esfera + fases del calendario M29 [C] → luz OK; esfera con textura de fases = M45 (K.2)
- [?] P8: nubes — velo 2D con drift, densidad estacional [C] → sin implementar; escénico V2 (K.2)
- [?] P11: niebla — matinal otoño, bruma verano, densa invierno, nocturna 0.25 [M] → `fog_curve.tres` data por hora EXISTE (Log curvas iter. 2); Fog...
- [?] P17: spawn de recursos — nocturnos opcionales (nunca críticos) [M] → M15 tiene temporada_respawn (iter. 5 estación) pero NO ventana horaria; r...
- [?] P19: eventos nocturnos — lluvia de estrellas días 10 y 25 [M] → data estrellas en JSON; evento calendario de M74 + partículas M52 sin implemen...
- [?] P20: secretos nocturnos — flora brillante + murales lore [M] → no implementado; dueños M15/M25/M148 (G)
- [?] Luna esférica con textura de fases [S] → luz sin mesh — M45 (K.2)
- [?] Nubes velo 2D con drift lento [S] → sin implementar (K.2)
- [?] Niebla (FogVolume ligero) [S] → data fog_curve.tres; FogVolume nodo no existe en escena (K.2)
- [?] Prefab de farol con omni 3200K [S] → sin implementar; dueño M18/M45 (K.2)
- [?] Canvas de estrellas [S] → sin implementar (K.2)
- [?] Compatible con M12 minimapa (sin luz) [S] → M12 minimapa sin implementar (fila 12 global); la regla "sin luz" documentada en diseño §4
- [?] `season_mod.tres`: 4 mods estacionales [S] → NO existe; curva única anual (K.2 visual fino)
- [?] Validación de rangos de curvas en dev mode (M110) [M] → M110 dev tools sin implementar; test_curvas_luz valida rangos en CI (parcial, dueño M110)
- [?] M15 Recursos: flor lumínica + cristales estelares nocturnos [M] → M15 solo tiene respawn estacional (iter. 5); contenido nocturno inexistente ...
- [?] M17 Construcción: faroles sin red eléctrica en v1 [S] → M17 sin faroles; puzzle farol_cargado existe en M23 data — dueño M17/M18
- [?] M13 Linterna: sugerencia automática opcional [S] → M13 sin linterna (grep 0); dueño M13 contenido + M92 sugerencia
- [?] M37 Museo: horario definido [M] → scripts/museos inexistente; M37 28/148 fila global — dueño M37
- [?] M32 Clima: lluvia de estrellas nunca con tormenta [S] → WeatherService enum sin "lluvia de estrellas" (es evento M74 + partículas M52); coordi...
- [?] Lluvia de estrellas: días 10 y 25, 22:00-23:30 [M] → fase_umbral.json §estrellas documenta la ventana; evento del calendario + partículas = M7...
- [?] Partículas de estrellas fugaces (M52) [C] → M52 sin implementar
- [?] Lince de luna: día 15, Claro del Bosque [C] → fauna especial de M36/M93 data
- [?] Interacción "observar" del lince (sin caza) [M] → ídem
- [?] Flora brillante: Senda de las Luciérnagas [C] → M15 contenido + M45 assets
- [?] Bono x2 de noche en flora (único bonus horario) [M] → hook futuro: consumers pueden leer es_de_dia(); implementación M15/M93
- [?] Murales luminosos en ruinas (M25, lore M148) [C] → dueños M25/M148
- [?] Diario M55 registra "deseo" de estrellas [S] → M55 sin implementar
- [?] TTS/texto accesible en eventos (M58) [M] → M58 sin implementar
- [?] Linterna del jugador rango 12 m [M] → no existe (M13/M45) — dueño externo
- [?] Opción M58 "Noche clara" (piso 0.35) [M] → M58 sin implementar; el piso es constante en curva — el hook sería parametrizar sky_curve (K.2 con ...
- [?] Faroles cada 40 m en poblado [C] → M18-BIS 🔵 WorkBuddy está construyendo casas — coordinar al liberar; prefab farol inexistente
- [?] Minimapa operable de noche [S] → M12 minimapa sin implementar
- [?] QA M114: checklist visual nocturno por zona [M] → M114 sin implementar; soy solo-texto — QA visual del usuario o agente con visión
- [?] 1 draw call de nubes [S] → sin nubes (D); la regla queda para el dueño escénico
- [?] Test: umbral farol antes/después [M] → sin autoswitch runtime (RF6 [?]) — test se escribirá con la feature (dueño M18/M45)
- [?] Transición amanecer/atardecer de 90 s con curvas de interpolación (polish)
- [?] `Sky` procedural con gradiente por hora y estrellas alpha 0→100% 20:00-22:00
- [?] Luna esférica con textura de fases (M45)
- [?] Nubes velo 2D con drift lento y densidad estacional
- [?] Niebla por estación/hora (FogVolume ligero ≤120 m)
- [?] Prefab de farol con omni 3200K r 8 m y autoswitch por umbral 0.35
- [?] Faroles cada 40 m en poblado (M18)
- [?] Sincronización lluvia de estrellas con M52 (días 10/25 22:00-23:30) [M] — **precisión QA V2 agnes-3-flash (Log 1052, 2026-09-19): el catálogo ...
- [?] Flora brillante con bonus x2 (M15)
- [?] Murales luminosos en ruinas (M25/M148)
- [?] Opción M58 "Noche clara" (piso 0.35) — M58 sin implementar
- [?] Integración con M49 iluminación global — M49 sin implementar
- [?] QA visual M114 (checklist nocturno por zona) — M114 sin implementar




**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar — corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 1:**

### M-04 — Barredura no intencional de trabajo ajeno en commits (tu cobertura)
Mi commit 11ac4d9 barrio **5 gates de M64** dentro de un fix de CI, y no me di cuenta
hasta que te lo pregunte. **Tu cobertura:** cuando un commit o cambio mio toque archivos
de tu modulo (o que te afecten), **verificalo vos** aunque yo diga que esta bien.
Ya lo hiciste una vez (P-09: 4/4 PASS, 60 checks, 0 fallos) — ese es el estandar.

**Como operar:** si ves en git log un commit mio que toca `quality.yml`, tus gates, o
archivos de tus modulos, correrlos y reportar. **No asumas que yo lo verifique.**
