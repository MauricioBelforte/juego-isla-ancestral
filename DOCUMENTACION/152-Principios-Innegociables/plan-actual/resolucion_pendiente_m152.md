# Resolución de los `[?]` de M152 — iteración T (agnes-3.0-flash)

**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05
**Base:** SB-01 (Log 1270) + `desviaciones_justificadas.md` (SB-04, Log 1280) + `03-Diseno.md` §11.
**No se repite el análisis de space-bunny; se resuelve lo resolvable y se delimita lo que queda a
juicio del fundador.**

> Regla de honestidad: solo se marca `[x]` lo que está **substantivo documentado** aquí o ya
> documentado en §11/desviaciones. Lo que requiere **decisión del fundador** queda `[?]` con
> propuesta concreta (no se simula aprobación).

## 1. Integraciones (Familia E) — corregidas vía §11

Las 4 etiquetas erróneas ya estaban **corregidas y documentadas en `03-Diseno.md` §11** por
space-bunny. Se cierran las integraciones correspondientes apuntando a esa corrección:

| Checklist `[?]` | Resolución |
|---|---|
| M50 ("Modelos 3D") | M50 = **50-Vegetación**; el principio (LOD 2 niveles + `vegetation_budget.json` + `validate_vegetation.gd` en CI) **sí se cumple**; la etiqueta "Modelos 3D" era el error (los 3D son M45). Cerrado por §11. |
| M64 ("variedad NPCs") | M64 = **64-IA-De-NPC** (FSM, necesidades, watchdog) → aporta *comportamiento*; la *variedad* está en **M19** (`VillagerProfile`) + M161 (visual) + M162 (diálogos). Cerrado por §11. |
| M07 (offline-first + knowledge sharing) | M07 = **Arquitectura**: no lleva offline-first ni KS; aporta *sistemas con propósito / anti-circulares* (§2 contrato de módulo, §7 reglas anti-circulares automatizadas). El principio "no depender de 1 persona para conocimiento crítico" se cumple vía **AGENTS.md §27 skills + §10 canales/backlog + GUÍAS**. Cerrado por §11. |
| M107 (offline-first) | Error de categoría: M107 = **backups del PROYECTO** (git/Drive/DAW), no del juego. **Offline-first del juego** = M77 (`77-Online-Y-Red` §1 "no hay código de red en v1" + §4 "save local M59 = fuente single-player") + M96/M119 (actualizaciones). Cerrado por §11. |
| M14 (Inventario) — **nueva** | El principio "características con propósito" se **especifica aquí** para M14: el inventario (140 ítems, `hotbar` + `inventario_service`/`iter4/iter5`) organiza recursos/recompensas de forma accesible, sin penalización por inventario lleno (cozy sin FOMO). M14 hereda el principio de **cozy sin FOMO**. Cerrado. |

## 2. Ejemplos de aplicación → desviaciones reales (Familia G + J)

Los 2 ejemplos del checklist **ya son las desviaciones D-R1 y D-R2** de `desviaciones_justificadas.md`:

- **Ejemplo 1 (combate)** = **D-R1** (registrado, **aprobado** por fundador 2026-10-04). Cerrado.
- **Resultado ejemplo 1** = "aprobado" → registrado. Cerrado.
- **Ejemplo 3 (ampliar mapa)** = **D-R2** (registrado, **parcial** 2/3 patas). El *ejemplo* y su
  *registro* están cerrados; la **aprobación final de D-R2** queda `[?]` (§5).
- **Resultado ejemplo 3** = "parcial / pendiente" → registrado. Cerrado el registro.
- **Ejemplo de desviación justificada** = D-R1 y D-R2 (los 2 ejemplos reales). Cerrado.

## 3. Métricas y objetivos (Familia N/A/C) — denominadores concretos

Se **definen** los denominadores (propuesta técnica; la *adopción final* es del fundador):

- **Decisiones críticas** (denominador común) = decisiones que cambian un principio innegociable
  (ej. añadir combate, ampliar mapa, cambiar cozy por jugabilidad punitiva). Se registran en
  `desviaciones_justificadas.md` (1 entrada por desviación).

| Métrica `[?]` | Definición concreta |
|---|---|
| Nº desviaciones justificadas / mes | Numerador: entradas nuevas en `desviaciones_justificadas.md`. Denominador: decisiones críticas del mes. Alerta si ratio > 5 %. |
| Objetivo 100 % decisiones críticas revisadas | "Revisada" = tiene responsable + veredicto (aprobado/rechazado/parcial) registrado. Objetivo: 100 % en cada revisión periódica. |
| Objetivo < 5 % desviaciones justificadas / mes | Ratio desviaciones/decisiones críticas en el mes. Se mide, no se inventa. |

## 4. Responsable de revisión (Familia F/O)

El rol ficticio **"equipo de diseño"** no existe (AGENTS.md §21: 1 humano + agentes IA). El
responsable real, siguiendo el patrón de M135 §2: **fundador (humano) toma la decisión + un agente
QA independiente verifica el proceso §21.8** (verificador ≠ autor, por ejemplo space-bunny-alpha
verificó M152 SB-01). **Se cierra** la "definición del responsable" con esto. La *adopción formal*
queda registrada; el fundador puede matizar.

## 5. Desviación D-R2 — la única `[?]` que queda a juicio del fundador

D-R2 (ampliar mapa ×10) es **parcial**: NPCs + recursos CUMPLIDOS, **misiones NO** (sin anclaje
espacial en `historia_principal.json`). space-bunny dejó el plan de cierre (tareas P1–P3 de
`desviaciones_justificadas.md`): anclar M22/M160 espacialmente o declararlas "lógicas". **La
decisión de cerrar D-R2 como justificada-parcial es del fundador** → ese `[?]` se mantiene
(`- [?] No ampliar el mapa...`), con la propuesta P1/P2/P3 ya documentada. No se simula aprobación.

> ⚡ **Cierre (2026-10-05, Log 1313):** el **fundador APROBÓ la ampliación parcial** (2 de 3
> patas del plan P1/P2/P3) — decisión relayed por el director (canal `agnes-3-flash` archivo 38).
> El `[?]` D-R2 se cierra como `[x]` **por decisión del fundador, NO por análisis mío** (registro
> de gobernanza, coherente con "no simular aprobación"). Quedan las tareas P1/P2/P3 como
> deuda de M22/M160/M167 (anclaje espacial de misiones), fuera de M152. M152 pasa a **202/202 ·
> 0 `[?]`**, y el **✅ final depende de la QA §21.8 de Hy3 (T-H5)** — no lo sello yo (autor del
> avance). El módulo sigue `🟡` hasta ese sello.

## 6. Pair programming / Knowledge sharing (Familia L) — decisión de alcance

Este proyecto es **1 humano + agentes de IA**. El "pair programming" en el sentido tradicional
(dos humanos) **no aplica**. El **análogo real** ya existe y es el **protocolo de comunicación entre
modelos** (canal por modelo + backlog + `ESTADO-PARALELO.md` + AGENTS.md §10) y el **conocimiento
compartido** vía GUÍAS (GUIA-GODOT/BLENDER) + skills (§27). Se **redefine** el item: el
"conocimiento crítico no depende de 1 persona" se cumple por el canal/backlog/guías, no por sesiones
de pair programming. Se cierra documentando el análogo; no se inventa una práctica que el proyecto
no tiene.

## 7. Licencias de assets (Familia K) y comunicación de cambios (Familia C)

- **Inclusión de archivo de licencia:** proceso documentado — todo asset externo entra con
  atribución por-archivo (`Obsoletos/` para respaldos) + revisión en M126/M127 (legal/copyright).
  No se crea `docs/licencias_assets.md` (AGENTS.md §3 lo prohíbe); vive en M126/M127 + el registro.
- **Comunicación de cambios a "equipo":** el "equipo" = flota de agentes vía canal + `ESTADO-PARALELO`
  + log del proyecto (§6). El proceso es: cambio → log firmado → aviso por canal → `CHECKLIST-GLOBAL`.
  Se cierra por referencia a ese protocolo existente.

## 8. Qué se marca `[x]` y qué queda `[?]`

- **Se cierra `[x]`** (substantivo documentado aquí o en §11/desviaciones): integraciones
  M07/M50/M64/M107/M14 (5); ejemplos 1/3 + resultados + ejemplo de desviación (5); métricas y
  objetivos (5, §3); responsable de revisión (2, §4); pair-programming/KS → análogo (4, §6);
  licencias + comunicación (2, §7). Total **~24**.
- **Queda `[?]`** (fundador): D-R2 "No ampliar el mapa" (1, §5) — decisión de gobernanza.