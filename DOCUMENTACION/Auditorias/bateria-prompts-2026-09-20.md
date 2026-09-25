**Modelo:** Atria-Dawn-Preview (Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-20
**Hora:** 21:05

# BATERÍA DE PROMPTS — Jornada 2026-09-20

> Análisis de estado del proyecto + batería de prompts listos para entregar a cada
> modelo, emparejados con sus **fortalezas medidas** (ver
> `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md`).

---

## 1. Estado global del proyecto (2026-09-20 21:01)

**167 módulos en CHECKLIST-GLOBAL:**

| Estado | Cantidad |
|---|---|
| ✅ Completado | 37 (26 con sello §21.8, **10 sin sello**) |
| 🟢 Disponible | 60 |
| 🔵 En curso | 9 |
| 🟡 Con dudas / Liberado | ~55 |

** 🔵 En curso (NO tocar — 9 módulos):**
M103 Logging, M106 Seguridad, M122 Crash-Reporting, M131 Créditos, M150 Diseño Sonoro,
M160 Ubicaciones del Mundo, M166 Variantes Rendimiento, M19 NPC-Y-Vecinos, M39 Tiendas

**Cierres rápidos disponibles (🟡 con mayor progreso):**

| % | Módulo | Progreso | Prioridad | Complejidad |
|---|---|---|---|---|
| 97% | M149 Nombres-Y-Nomenclatura | 97/100 | Media | 2 |
| 96% | M60 Datos-Y-Serializacion | 189/196 | Alta | 3 |
| 96% | M38 Economia | 158/164 | Alta | 4 |
| 95% | M87 Localizacion | 129/136 | Media | 3 |
| 93% | M09 Terreno-Y-Geografia | 98/105 | Alta | 4 |
| 93% | M66 Anti-Softlock | 109/117 | Alta | 3 |
| 93% | M52 Particulas-Y-VFX | 137/148 | Media | 3 |
| 89% | M30 Reloj-En-Tiempo-Real | 107/120 | Media | 2 |
| 88% | M25 Ruinas | 107/122 | Media | 3 |
| 85% | M10 Generacion-Del-Mundo | 90/106 | Alta | 5 |
| 85% | M64 IA-De-NPC | 100/117 | Alta | 5 |

**🟢 Alta prioridad sin iniciar/casi sin tocar:**
M59 Guardado (55/130, c5), M62 Memoria (59/150, c3), M70 Interacciones (77/198, c3),
M53 UI-UX (131/158, c4), M152 Principios (115/202, c1), M97 Steam Store (129/195, c3),
M22 Historia Principal (51/100, c4), M163 Encantamientos (23/124, c3),
M17 Construcción (11/175, c5), M24 Templos-Y-Puzzles (31/128, c5)

---

## 2. Modelos disponibles y fortalezas medidas

| Modelo | Fortaleza medida | Estado |
|---|---|---|
| **kimi-k3** | Seguridad, data-driven, **5/5 suites rc=0**, ~9 min/tarea, contexto 1M | M106 activo (145/206, 61 `[ ]`) |
| **deepseek-v4.1-flash** | **M103 es suyo** (iter. 1: 131 checks/0 fallos, 7 fixes), visión 2/2 | **🆕 disponible — M103 reasignado** |
| **mimo-v2.5** | Visión + godot-mcp, complejidad 5, honesto | M31 con **54 `[?]`** sin cerrar |
| **hy3** | **QA cruzado §21.8 top** (9/9 suites), fixes, contenido legal/marketing | Libre |
| **agnes-3-flash** | Visión nativa, honestidad excepcional, lenta | ⏸️ **En pausa** (2026-09-20, el usuario la espera) |
| ~~nex-n2.5-pro~~ | ~~Tareas atómicas con verificación obligatoria~~ | ⛔ **FUERA DE FLUJO definitivo (2026-09-20, directiva del usuario): el contexto es muy grande, no avanzó nada. Sin locks. Tareas reasignadas — ver Log 1101.** |
| **atria-dawn** (yo) | Coordinación, verificación binario real, auditoría | Coordinación + barrido histórico |

**Hallazgos del chequeo de hoy:**
- **M122 Crash-Reporting**: stale **15 días** (plan-actual sin tocar desde 09-04). K3 lo
  tiene 🔵 pero solo avanzó M106. **Reasignar formalmente.**
- **M31**: 115 `[x]` / 54 `[?]` / 0 `[ ]` — el trabajo de MiMo generó dudas, no cierre.
  Necesita reconciliación de esos `[?]` (mismo patrón que M12, que MiMo ya ejecutó bien).
- **10 módulos ✅ sin sello §21.8** — cola de QA para hy3.

---

## 3. Batería de prompts por modelo

### 3.1 kimi-k3 — continuar M106 + tomar M122

**Encaje:** CyberGym 86.5 confirmado 5/5 en seguridad. M122 (Crash-Reporting) es
adyacente a seguridad y está stale 15 días.

**Prompt A (continuar M106):**
> Continúa tu backlog de M106 Seguridad. Te quedan **61 ítems `[ ]`** en
> `DOCUMENTACION/106-Seguridad/plan-actual/05-Checklist.md`. Toma los siguientes 5
> ítems en orden, impleméntalos con test headless (patrón RefCounted sin class_name que
> ya usaste), verifica con el binario Godot 4.7.2 real y documenta log. Recuerda: la
> integración HTTP real es de M77 — difiérela.

**Prompt B (M122, reasignación):**
> M122 Crash-Reporting está 🔵 a tu nombre pero stale 15 días (sin cambios desde
> 2026-09-04). Tienes **80 ítems `[ ]`**. Confirma si lo retomas o lo liberas. Si lo
> retomas: es adyacente a M106 (crash = seguridad), tu zona medida. Empieza por los
> RF de captura y reporte, con suite headless.

### 3.2 mimo-v2.5 — cerrar los 54 `[?]` de M31

**Encaje:** MiMo ya demostró el patrón de reconciliación en M12 (FASE 3 + drift
corregido). Los 54 `[?]` de M31 son el mismo trabajo.

**Prompt:**
> M31 Ciclo-Día-Noche quedó con **115 `[x]` / 54 `[?]`**. Tu trabajo generó dudas, no
> cierre. Haz la reconciliación (mismo método que M12 FASE 3): para cada `[?]`,
> decide con evidencia de código: (a) marcar `[x]` citando archivo+línea, o (b)
> dejarlo `[?]` con dueño y explicación. Tienes godot-mcp + visión operativos —
> úsalos para los ítems visuales (ciclo de color del cielo, transiciones de
> iluminación). **No marques `[x]` sin respaldo.** Meta: bajar los 54 `[?]` a <15.

### 3.3 hy3 — M149 + QA §21.8 de los 10 ✅ sin sello

**Encaje:** hy3 cerró M126 (4→59) y M128 (5→53) con eficacia total. M149 (97/100) es
exactamente el mismo patrón. Además es el QA cruzado top (9/9).

**Prompt A (M149):**
> M149 Nombres-Y-Nomenclatura está al **97% (97/100)** con 3 `[?]`. Es el mismo patrón
> que M126/M128 que cerraste. Termina los 3 `[?]` con evidencia (el módulo ya tiene
> `validar_nombres.py` funcional) y cierra el módulo → ✅.

**Prompt B (QA §21.8 — 10 ✅ sin sello):**
> Hay **10 módulos ✅ sin sello de QA §21.8**:
> M102 Bug-Tracking, M112 Testing-Automatico, M153 Objetivo-Final, M154 Vision-Del-Agente,
> M167 Isla-Raiz, M32 Clima, M78 Legal-PI, M84 Musica-Audio-Legal, M93 Balance,
> M94 Retencion-Sin-FOMO.
> Verifica: checklist sin `[?]`, código existe y cumple DoD, plan-actual coincide con
> código, logs y firmas. **Ojo:** M84 y M94 fueron arreglados por mí (BUG-061/062,
> Logs 1083/1085) — sus tests ya pasan 15/0 y 38/0; verifica que el ✅ esté ahora
> respaldado. M32 fue verificado por mí (Log 942). Reporta hallazgos sin marcar.

### 3.4 agnes-3-flash — una tarea visual pequeña y puntual

**Encaje:** Visión nativa + honestidad, pero lenta. **Solo tareas pequeñas** (un asset
o una captura a la vez).

**Prompt:**
> Tarea visual única, pequeña: verifica el impostor del terreno de M09
> (`game/isla-ancestral/scripts/world/terreno_horizonte.gd`) con una captura V4.
> M09 no tiene suite headless (su impostor se verifica visualmente, visible a 1300 m).
> Captura → analiza → reporta: ¿se ve el impostor correcto desde la distancia
> objetivo? **Si no hay captura posible, reporta "no verificable"** — no apruebes
> sin evidencia. Una captura, un veredicto.

### 3.5 ~~nex-n2.5-pro~~ — ⛔ FUERA DE FLUJO DEFINITIVO (2026-09-20)

> **Directiva del usuario (2026-09-20):** *"practicamente no puede aportar nada porque
> el contexto es muy grande"* — no avanzó nada en su asignación. **Sección cancelada;
> no usar este prompt.** Las 7 tareas de M87 vuelven a DeepSeek-V4.1-Flash (Recom del
> módulo + autor de la iter. 6); los 7 ítems son `[?]` con dueño externo (M53 ×4,
> usuario, M14-M39, M29/M30), no trabajo libre. Ver Log 1101.

**Encaje:** ~~M87 Localización está al 95% (129/136) — 7 ítems sueltos, atómicos.~~

**Prompt:**
> M87 Localización: **7 ítems `[ ]` sueltos** para llegar al 100%. Son tareas
> atómicas (completar strings faltantes, verificar tablas de idioma). Hazlos uno por
> uno. **Regla obligatoria:** cada entrega se re-corre con el binario Godot 4.7.2 real
> antes de marcar `[x]` — tu claim "0 SCRIPT ERROR" fue falso una vez. Scope acotado:
> solo M87, nada más.

### 3.6 deepseek-v4.1-flash — cerrar M103 Logging (¡su módulo!)

**Encaje (2026-09-20, Log 1091):** DeepSeek-V4.1-Flash (WorkBuddy, visión 2/2 verificada)
**es el autor de la iter. 1 de M103** (Log 918, 2026-09-15): 131 checks/0 fallos ×3,
7 fixes reales (JSON inválido, export no-op, rotación, escapes), dejó 167 `[x]` / 12 `[?]`.
El módulo estuvo 🔵 a nombre de kimi-k3 pero K3 nunca lo tocó (stale desde 2026-09-15).
**Reasignado a DeepSeek por el usuario + Atria.** Los `[?]` son decisiones de diseño —
su especialidad — y el scope (10 ítems) encaja en su límite de tokens.

**Prompt:**
> Vuelves a **M103 Logging**, tu módulo: hiciste la iter. 1 (Log 918, 131 checks/0
> fallos, 7 fixes). Quedó en **167 `[x]` / 12 `[?]` / 0 `[ ]`**. Cierra los `[?]`.
>
> **Tus 10 ítems** (de
> `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/103-Logging/checklist.md`):
> T-093 (buffer de escritura), T-094 (flush periódico), T-130 (búsqueda de texto),
> T-133 (scroll en consola), T-134 (coloreado por nivel), T-135 (timestamp relativo),
> T-142 (frame budget < 0.5%), T-153 (criterios de aceptación), **T-165 (implementar
> buffer + flush — el único [M], el resto son "Definir" [S])**, T-178 (regresión 6 tests
> economía/tiendas/tiempo con 0 fallos).
>
> **⚠️ NO toques T-022 ni T-109** (RF18 crash reporting integración y
> bug_{timestamp}.log) — son de **M122 Crash-Reporting (kimi-k3)**. Déjalos `[?]` con
> dueño M122 y documenta la dependencia.
>
> **Método (el tuyo, probado):** para cada "Definir X", documenta la decisión de diseño
> en `plan-actual/03-Diseno.md` con criterios medibles, y márcalo `[x]` solo si la
> decisión queda respaldada por código existente o por una decisión explícita. T-165 es
> implementación real: suite `test_logging_m103_iter2.gd` con guardián anti-falso-verde.
> T-178: re-corre las 6 suites con el binario Godot 4.7.2 real.
>
> **Meta:** M103 167→177+ `[x]`, con T-022/T-109 explícitamente diferidos a M122.

### 3.7 atria-dawn (yo) — coordinación + barrido histórico

- Verificar cada entrega que llegue (binario real, anti-falso-verde, sync de 3 registros)
- **Barrido histórico** (sección 7 del doc empírico): DeepSeek V4 Flash escribió
  **114 de 168 plan-iniciales (68%)**; **Nemotron 3 Ultra + 3.5 Lightning = 17 módulos
  sin documentar**; devin 21; glm-5.3/5.3-flash fundadores
- Actualizar el doc empírico con cada verificación

---

## 4. Regla de oro de la jornada

> **Cada entrega se verifica con binario real antes de marcar `[x]`.** El drift de
> conteo es endémico (M09, M11, M12, M126/M128/M115 lo demostraron). Cada cierre
> requiere sync de los **3 registros**: `05-Checklist.md` (marcas **y** línea
> `**Totales:**`), `CHECKLIST-GLOBAL.md` (fila) y el backlog del modelo.

---

**Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-20 21:05
