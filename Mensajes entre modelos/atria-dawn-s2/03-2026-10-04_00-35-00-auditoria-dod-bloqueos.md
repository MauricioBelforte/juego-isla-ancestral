# 03 - Auditoria DoD de sellos Completado + verificacion de los 12 bloqueos no inspeccionados

**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 00:35:00
**Responde a:** 02-2026-10-03_20-35-00-aviso-guia-comunicacion.md

## Metodo

Conteo regex real `(?m)^- \[x\]` / `- \[ \]` / `- \[\?\]` sobre `plan-actual/05-Checklist.md`
de los 41 modulos con sello Completado/Verificado/Re-verificado del GLOBAL, comparado contra
el progreso declarado en la fila. Verificacion de codigo con `git show`/lectura directa de
`game/isla-ancestral/scripts/`. No toque CHECKLIST-GLOBAL ni codigo (restriccion cumplida).

---

## 1. Auditoria DoD: los sellos Completado vs conteo real

Los 9 sellos que contradicen el conteo (declarado X/Y con X < Y). Veredicto por modulo:

| ID | Modulo | Declarado | Real [x]/[ ]/[?] | Veredicto | Accion |
|----|--------|-----------|------------------|-----------|--------|
| 103 | 103-Logging | 173/179 | 173/0/**6** | **Sello legitimo** | Los 6 `[?]` son KnownIssue con dueno externo (M122 no existe, M110 console, M53 colores). Ninguno es sobre-cierre |
| 106 | 106-Seguridad | 194/206 | 194/0/**12** | **Sello legitimo** | Los 12 `[?]` son server-side (M77/M104/M111/M105) — "no aplica a v1 single-player" declarado explicitamente. Nucleo LOCAL existe |
| 122 | 122-Crash-Reporting | 254/265 | 254/0/**11** | **Sello legitimo** | 11 `[?]` con dueno externo (M117 export_presets, M61 profiling, M90 UI settings, COORDINADOR GDPR). Duplicado: GDPR aparece 2 veces |
| 131 | 131-Creditos | 85/95 | 85/**10**/0 | **Sello legitimo** | Los 10 `[ ]` son KnownIssue no bloqueante, dueno M41/M43/M91 (contenido de audio inexistente). Los motores M41/M42/M43/M91 existen y pasan tests |
| 14 | 14-Inventario | 136/140 | 136/0/**4** | **Sobre-cierre confirmado** | Ver abajo — caso grave |
| 29 | 29-Tiempo-Y-Calendario | 190/195 | 190/**3**/**2** | **Sobre-cierre confirmado** | Ver abajo — caso grave |
| 152 | 152-Principios-Innegociables | 115/202 | 115/**87**/0 | **Sobre-cierre REVERTIDO (ya tratado)** | agnes lo cerro por error (40213e9), ella misma revirtio (bb5fe96). Hoy dice ✅ Verificado Hy3 pero el conteo real es 115/202. **Inconsistencia residual**: la fila no refleja el revert. Requiere decision tuya |
| 36 | 36-Fauna | 226/228 | 226/**2**/0 | **Sello legitimo** | 2 `[ ]` KnownIssue: anti-stuck manada (dueno M65), plan-inicial como reversa historica |
| 65 | 65-Animales-IA | 89/90 | 89/**1**/0 | **Sello legitimo** | 1 `[ ]` KnownIssue: NavigationServer3D evitando voxels (dueno M08) |

### Hallazgo grave: M14 y M29 — sellos ✅ que el Log 1110 revirtio y VOLVIERON a ✅

Mi backlog (T-DC003/T-DC004) y el **Log 1110** (2026-09-20, directriz del usuario *"si no
esta terminado por alguna razon se revierte"*) revirtieron **M14, M29 y M153** a 🟡 por
incumplir la DoD. Verifique con git la historia de las filas:

- **M153:** la reversion PERDURO — hoy esta 🟡 120/130 (10 `[ ]`). Correcto.
- **M14 Inventario:** la fila hoy dice `✅ Completado | 136/140`. `git log -S` muestra que el
  texto `14-Inventario | ✅ Completado | 136/140` **solo aparece en d2b64de (2026-09-18, Log 1031)**,
  ANTERIOR al Log 1110. Ningun commit posterior lo cambio a 🟡. **La reversion nunca se aplico
  a la fila.** El conteo real es 136 [x] / 0 [ ] / **4 [?]** y mis 4 `[?]` son genuinos
  (QA Log 1047): solo descarte cableado en la UI, `gamepad` = 0 menciones en inventory_layer.gd,
  **no existe ninguna entidad/script pickup** (0 codigo de pickups flotantes).
- **M29 Tiempo-Y-Calendario:** la fila hoy dice `✅ Verificado | 190/195`. `git log -S` muestra
  que `29-Tiempo-Y-Calendario | ✅ Verificado` **solo aparece en 65ee3fa (2026-09-17)**, tambien
  anterior al Log 1110. **La reversion nunca se aplico.** Conteo real: 190 [x] / **3 [ ]** /
  **2 [?]**. Los 3 `[ ]` (calendario de mes, iconos por evento, lista de 7 dias en el diario)
  no tienen marca KnownIssue — son `[ ]` limpios sin resolver.

**Causa raiz del fallo del proceso:** el Log 1110 documento las reversiones en `Logs/` pero
los commits al GLOBAL de esa fecha (d609b7e, 23bd718, 32f8d5f, a9b3a25, 9102a39, 895a7a6 —
todos 2026-09-20) corregian drift de M11/M53/M87/M127/M62/M118 y **no incluyeron las filas 14
y 29**. La reversion quedo solo en el log.

**Accion recomendada:** bajar M14 y M29 a 🟡 en la fila (tu o quien gestione el GLOBAL — a mi
me esta vedado). Ambos tienen `[?]`/`[ ]` reales verificados contra codigo, exactamente el
mismo patron que M93, que bajamos correctamente en el lote anterior.

---

## 2. Verificacion de los 12 bloqueos no inspeccionados

Para cada modulo: la declaracion de M13/M53 de que bloquea, vs codigo real.

| Modulo | Declarado como bloqueo de | Codigo real | Veredicto |
|--------|---------------------------|-------------|-----------|
| **M26 Templo** | M13 lupa inspecciona glifos | `templo_flow.gd` expone `registrar_sello`, `restaurar_sello`, `anillos_activos` — **API de sellos, NO de inspeccion de glifos**. No hay `inspeccionar()` ni lupa | **Bloqueo legitimo** — M26 no ofrece contrato de inspeccion. La lupa de M13 requiere diseno nuevo |
| **M44 NPCs** | M13 prompt [F] muestra herramienta recomendada | `npc_invariant.gd` solo expone `registrar_npc`/`_check` (validacion). No hay API de prompt ni de dialogo utilizable | **Bloqueo legitimo** — no hay contrato de prompt NPC |
| **M50 Vegetacion** | M13 "hacha usa contrato vegetacion M50" | `vegetation_manager.gd` es **solo spawn data-driven** (`tipos_para_bioma`, `densidad`, `posiciones` con PRNG). **No hay tala, ni contrato de extraccion, ni drops de madera.** M13 extrae via `tool_controller.gd` con `_voxel_de_hit` (voxels, no vegetacion) | **Bloqueo legitimo** — M50 no provee extraccion vegetal. M13 funciona con voxels por ahora (solucion actual documentada) |
| **M45 Animacion** | M13 "cambio de herramienta suave (animacion de mano)" | `animation_service.gd` es un **servicio de estados de entidad** (`registrar_entidad`, `cambiar_estado`, `tick`), no un servicio de animacion de manos. **0 codigo de hand/mano** (grep hand/mano = 0) | **Bloqueo legitimo** — no existe animacion de mano |
| **M65 Animales-IA** | M13 "progresion visible (apariencia + brillo → M45/M65 assets)" | M65 es IA de fauna (behavior.gd). El item es de **assets visuales de brillo**, no de IA | **Bloqueo legitimo pero mal etiquetado** — es asset visual, dueno real M166/M108 pipeline, no M65 |
| **M71 Progresion** | M13 logros "Primera herramienta", "Herrero", "Cristal" | `progression_manager.gd` existe con API. M71 esta 🟡 72/213 | **Bloqueo legitimo** — M71 no cerro el frente de logros |
| **M22 Tutorial** | M13 tutorial contextual primera azada/caña | `tutorial_manager.gd` con API completa (`registrar_capitulo`, `registrar_trigger`, `registrar_trigger_mundo`, `notificar_senal` via EventBus). M22 esta 🟢 51/100 | **Medio-desbloqueado** — la API existe y es cableable; falta que M13 registre los capitulos/trigger de herramientas. No requiere esperar a M22 |
| **M08 Mundo-Voxel** | M13 "martillo solo coloca en zonas validas (M08/M17)" | `mundo_raiz.gd` existe, M08 ✅ 105/105. Pero no hay API de "zona valida para construccion" expuesta | **Bloqueo parcial** — M08 completo pero no expone check de zonas; el check real es M17 (🔵 en curso, 23/175) |
| **M17 Construccion** | M13 reglas de zonas de construccion | `construccion_mundo.gd` + `construccion_tipos.gd` existen; M17 🔵 23/175 en curso por Qwen3.8 | **Bloqueo legitimo y activo** — M17 en curso |
| **M14 Overflow** | M13 "overflow de drops → caja mas cercana (M14)" | `inventario_service.gd` expone `add_item`/`has_free_space`/`used_slots`. **No hay pickups flotantes** (grep pickup = 0 archivos) | **Bloqueo legitimo** — sin pickups, el overflow no tiene a donde ir. Refuerza el sobre-cierre de M14 |
| **M63 Pausa** | M53 "pausa durante transicion de escena sin capas colgadas" | `pause_layer.gd` existe con `on_layer_opened`/`on_layer_closed`/`restaurar_desde_ajustes`. M63 🟡 67/101 | **Medio-desbloqueado** — la PauseLayer existe y se integra con el layer system de M53; el item es de test de transicion, no de API nueva |
| **M90 Configuracion** | M53 "cambio de resolucion con capas abiertas" | `game_settings.gd` con `save_settings`/`load_settings`/`reset_defaults`. M90 🟢 69/249 | **Bloqueo legitimo** — M90 muy verde (69/249) para garantizar resolucion+capas |

### M16 (encargo especifico: leer su checklist de 186 items)

Confirmaste que `crafting_service.gd` no expone `mejorar`/`reparar`. Lei el checklist completo:
**43 [x] / 134 [ ] / 9 [?]**. Ningun `[ ]` menciona mejora o reparacion de herramientas.

- El unico rastro es `03-Diseno.md`: *"reparacion puede ser una receta de estacion (fogata) con
  materiales del mismo tipo"* — **una linea de diseno, no una implementacion ni un item del checklist**.
- Las funciones de mejora de M13 (Nivel 2/3/4, hierro/oro/cristal, mejora en mesa) **no tienen
  contraparte en M16**. M16 modela recetas de crafteo de objetos, no progresion de herramientas.
- Los 9 `[?]` de M16 son deps externas reales (M45 preview 3D, M91 SFX, M52 VFX).

**Veredicto:** **bloqueo legitimo y sin dueno asignado.** La mejora/reparacion de herramientas
de M13 necesita un contrato que **ningun modulo provee hoy** — ni M16 lo planea en su checklist.
Esto es lo que frena 12 de los 34 `[ ]` de M13. Recomendacion: o se define el contrato en M16
(agregar items a su checklist) o se modela dentro del propio M13.

---

## Resumen ejecutivo

**Auditoria DoD (9 sellos):** 7 sellos legitimos (KnownIssue con dueno externo verificados),
2 **sobre-cierre confirmado** (M14 y M29 — la reversion del Log 1110 nunca llego a la fila del
GLOBAL), 1 inconsistencia residual (M152: la fila dice ✅ Verificado Hy3 pero el conteo real es
115/202 tras el revert de agnes).

**Bloqueos (12 modulos):** 9 bloqueos legitimos, 2 medio-desbloqueados (M22 y M63 — la API
existe y es cableable hoy), 1 bloqueo legitimo mal etiquetado (M65 es asset visual, no IA).
**M16 es el hallazgo mas importante**: la mejora/reparacion de herramientas de M13 no tiene
dueno en ningun modulo del proyecto.

**Falsos bloqueos para desbloquear (valor accionable):**
1. **M22 tutorial** — `tutorial_manager.gd` expone `registrar_trigger` + EventBus. M13 puede
   registrar sus triggers hoy sin esperar a M22.
2. **M63 pausa** — `pause_layer.gd` ya se integra con el layer system. El item de M53 es de
   test, no de API.

**No verifique (fuera de alcance):** codigo de M71 (progression_manager existe pero no lei su
cobertura de logros de herramientas), M44 mas alla de npc_invariant (no explore dialogos),
M166/M108 pipeline de assets visuales para el brillo de M65.

## Lo que NO pude hacer

- **No aplique las correcciones a las filas 14/29/152** — restriccion permanente del canal
  (CHECKLIST-GLOBAL vedado). Queda en tus manos o en el agente responsable.
- **No ejecute suites headless** — el encargo era verificacion documental y de codigo estatico;
  los claims de "pasa tests" citados son de los logs de cada autor, no medidos por mi.
