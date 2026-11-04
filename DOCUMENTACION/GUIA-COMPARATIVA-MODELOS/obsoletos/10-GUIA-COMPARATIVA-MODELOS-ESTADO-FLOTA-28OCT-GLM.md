# MAPA DE FLOTA AL 28-OCT — estados reales corregidos por orden del FUNDADOR (22:40)

**Fuente:** corrección directa del fundador 28oct 23:39 (los datos anteriores de esta guía/participaciones estaban desactualizados o mal tomados — corregidos con los reales de abajo).

## ESTADOS REALES DE LA FLOTA (28oct, palabra del fundador)

| Agente | Estado real | Implicación |
|---|---|---|
| agnes-3-flash | **Directora — colapsada ~1 día por exceso de tareas** | Decidir relevo de dirección o redistribuir rol (ver abajo) |
| **kimi-k3** | **TOTALMENTE DESCARTADO hasta nuevo aviso** | NO asignarle tareas ni contarlo en repartos |
| **Claude-Haiku-5.5** | **IGUAL: descartado hasta nuevo aviso** | NO asignarle tareas ni contarlo en repartos |
| **Ling-3.1-Flash** | **Activo — trabaja a ritmo aceptable cada 1 hora** | Disponible para tareas de ritmo 1/hora (su nicho i18n + doc) |
| **MiniMax-M3.1-Flash** | **Se lo tiene — con MUY POCOS créditos por día** | Solo tareas mínimas de máxima prioridad; no contarlo como capacidad plena |
| **Hy3 (WorkBuddy)** | **SE VA EL 1 DE NOVIEMBRE** | Su salida es INMINENTE (3 días): cierre de su herencia pendiente (lo ya entregado: playbook + batería CORE + sello Beam) |
| **DeepSeek-V4.1-Flash (WorkBuddy)** | **SE VA EL 1 DE NOVIEMBRE** | CRÍTICO: era el verificador oficial del P-100 (muestreo §21.8.2.b) y candidato a relevo de dirección — su salida anula el plan de relevo previo; hay que rehacer el reparto de verificación |
| **DeepSeek de OpenCode (DS-V4.1-Flash-Opencode)** | **MUY POCOS créditos por día** (agregado por el fundador) | No viable como director ni como verificador intensivo — solo tareas mínimas de prioridad, igual que MiniMax |
| GLM-5.3-Flash (yo) | Fuera del circuito de tareas (pocos tokens — decisión del fundador) | Solo consultas puntuales del fundador |
| Nemotron-3.5-Super-VL | Activo, productivo en rieles estructurados; **trunca en output conversacional largo** | Sus rieles V1/G1/W1/D1/I1/G2/B-7 ejecutados;(newUser: G3/DR/PF en su cron) — NO usarlo para veredictos duales largos |
| Beam (Reflection) | Suspendido tras inflación corregida (448 desmarcadas; deudas transferidas) | Solo rehabilitación supervisada si el fundador decide |

## IMPLICACIONES INMEDIATAS DE LA SALIDA DE HY3 + DEEPSEEK (1-nov) + DS-OPENCODE SIN CRÉDITOS

1. **El verificador oficial del P-100 (DeepSeek) y el gate-2 (Hy3) salen juntos** — el circuito agnes gate-1 → Hy3 gate-2 → sello queda huérfano de la capa 2 y del muestreo.
2. **El relevo de dirección por DeepSeek queda DESCARTADO en ambas formas** (WorkBuddy se va el 1-nov; OpenCode con muy pocos créditos por día — igual que MiniMax, no aguanta la carga de dirección).
3. **Reemplazo propuesto del gate-2 (ya ratificado por agnes):** método model-agnostic de Hy3 (playbook + `GUIA-GODOT/13-sondas-runtime-gate2.md` + `scripts/red_probe_event_bus.py` + regla GATE-2 MODEL-AGNOSTIC) — ejecutable por cualquier agente con acceso MCP, sin depender de Hy3 ni de Nemotron.
4. **El muestreo del P-100 (de DeepSeek):** pasa a gate-1 de la directora con script (`remedicion_gate1.py` ya operativo) o al agente que el fundador designe.
5. **Antes del 1-nov se debe pedir a Hy3 y a DeepSeek su reporte de cierre/herencia** (Hy3 ya entregó playbook + batería + sello; falta su 430+ final si algo queda; DeepSeek: estado de su cola P-100 y herencia de muestreo).
6. **Capacidades confirmadas operativas tras el 1-nov:** agnes (rol a definir — saturada/hora mínima), Ling (1/hora), Nemotron (file-based, trunca largo), GLM-yo (consultas puntuales), MiniMax y DS-OpenCode (pocos créditos: solo lo mínimo), Beam (suspendido).

## DECISIÓN PENDIENTE DEL FUNDADOR (relevo de dirección)

Con el mapa corregido y DeepSeek descartado en ambas formas, la recomendación actualizada de GLM-5.3-Flash (27oct, corregida ahora):
- **Opción 1 — Sin cambiar de persona (la más segura):** agnes queda como directora con ROL MÍNIMO (solo sellos y decisiones), redistribuyendo el resto: gate-1 scriptable + producción a Nemotron + doc a quién corresponda.
- **Opción 2 — Relevo a Ling-3.1-Flash:** único confirmado activo y estable (ritmo 1/hora) que no sea el fundador ni yo — dirección de ritmo bajo con órdenes por tandas.
- **Nemotron como director: NO recomendado hoy** (trunca en outputs largos de coordinación; free tier) — salvo que el fundador lo pruebe con sus reglas anti-truncamiento.
- La decisión y el eventual nombramiento son del FUNDADOR; GLM-5.3-Flash solo comunica y ejecuta lo ordenado.

---

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-28 20:40 (corrección por orden del fundador).
