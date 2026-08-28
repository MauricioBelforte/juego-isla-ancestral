**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Implementación operativa (entregable M133)

---

# Flujo Multiagente — Resumen Operativo — Módulo 133

> Versión operativa y autocontenida del protocolo de la sección 21 de `AGENTS.md` para el trabajo diario (RF2, RF3, RF4, RF16). Si este archivo y `AGENTS.md` §21 difieren, **manda `AGENTS.md`** y se corrige este resumen por ADR.

---

## 1. Ciclo de un módulo

```
1. ESCANEAR   Leer CHECKLIST-GLOBAL.md + ESTADO-PARALELO.md + guía 08 antes de tocar nada.
2. RECLAMAR   Estado → 🔵 En curso · Agente actual → tu nombre · Última actividad → timestamp.
              Reserva en los 4 registros: CHECKLIST-GLOBAL, ESTADO-PARALELO,
              DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md, 05-Checklist.md del módulo.
3. TRABAJAR   Documentación primero (§13) → implementación → testings (§14).
              Auto-corrección con MCP si es Godot (§12.1). No pisar archivos ajenos.
4. MARCAR     05-Checklist.md: [x] solo con DoD completa; [?] con explicación si no se resolvió.
5. QA CRUZADO Un modelo DISTINTO revisa contra la DoD antes de dar por definitivo un ✅ (§21.8).
6. CERRAR     Log numerado en Logs/ (§6), firmas en documentos modificados,
              liberar bloqueo (🔵/🔴 → 🟢/🟡/✅), sincronizar los 4 registros.
```

Nunca dejar un `🔵`/`🔴` huérfano al terminar la sesión (regla 21.4.5).

---

## 2. Estados y transiciones

| Estado | Significado | Transición |
|--------|-------------|------------|
| ⬜ Sin iniciar | Aún no tocado | → 🟢 cuando el backlog lo libera |
| 🟢 Disponible | Reclamable | → 🔵 al reservar |
| 🔵 En curso | Bloqueado por un agente, avanzando | → 🟡/✅/🟢 al liberar; → 🔴 si hay riesgo |
| 🔴 En curso con riesgo | Atascado | → 🟡/✅/🟢; otro agente puede reclamar tras 24 h |
| 🟡 Con dudas | Liberado con `[?]` pendientes | → 🔵 cuando otro lo retoma (ciclo 21.5) |
| ✅ Completado | DoD completa + QA cruzado | → 🟡 si el QA cruzado encuentra fallos |

**Regla de colgados (21.4.7):** un 🔵/🔴 sin actividad >24 h (columna `Última actividad`) puede ser reclamado por otro agente, que actualiza agente, estado y timestamp. La detección es manual + `scripts/verificar_checklist.py`.

---

## 3. Reserva en los 4 registros (plantilla)

```text
RESERVA: M{ID} - {Nombre del módulo}
AGENTE: {modelo / plataforma}
FASE: {según DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md}
ENTRADA: {puerta o dependencia cumplida}
SALIDA: {resultado verificable esperado}
ARCHIVOS: [lista]
VALIDACION: {herramienta: MCP Godot / scripts / pruebas}
FECHA: YYYY-MM-DD HH:MM:SS
```

Donde se anota: (1) fila del módulo en `CHECKLIST-GLOBAL.md`; (2) entrada en `ESTADO-PARALELO.md`; (3) tabla `Reserva actual` o §17 de la guía 08; (4) bloque `Reserva actual` al inicio del `05-Checklist.md` del módulo.

---

## 4. DoD (definición de listo, §21.6)

Un `[x]` exige TODOS: ① implementado y verificado (§12) · ② `plan-actual/` refleja el código real · ③ testings superados (§14) · ④ log en `Logs/` · ⑤ firma del agente.
Un módulo `✅` exige además: cero `[?]` y QA cruzado aprobado por un modelo distinto.

---

## 5. QA cruzado (§21.8, resumen)

1. El verificador marca en `Notas`: `🔵 QA por {modelo}`.
2. Revisa: checklist sin `[?]`, código vs DoD, `plan-actual/` vs realidad, logs y firmas, resultados de tests.
3. OK → permanece ✅ y se anota `✅ Verificado por {modelo} {fecha}`. Con fallos → vuelve a 🟡 y los hallazgos se agregan al historial de `## Notas del Agente` (sin borrar lo anterior).
4. El verificador nunca es el mismo modelo que implementó (idealmente tampoco la misma plataforma).

---

## 6. Deuda técnica (RF7) y desviaciones (RN14)

- **Deuda técnica** se registra donde vive el problema: `[?]` con explicación en el `05-Checklist.md`, nota en `## Notas del Agente`, y/o fila del módulo en la tabla global (columna Notas). El acumulado se revisa en la revisión de estado semanal y se prioriza en la planificación del hito siguiente. Los `[?]` de un módulo bloquean su ✅: pagar la deuda es la única salida.
- **Desviaciones justificadas** (reglas que no se pudieron cumplir): se documentan con motivo y fecha en el módulo afectado (o por ADR si afectan al proceso), coherente con el registro de desviaciones de M152. Una desviación sin registro cuenta como incumplimiento.

---

## 7. Edge cases (procedimientos)

| Situación | Procedimiento |
|---|---|
| **Un agente abandona un módulo sin terminar** | Si hay aviso (🔴) → esperar 24 h, luego reclamar (21.4.7), leer `## Notas del Agente` y los `[?]`. Si no hay aviso, el mismo umbral de 24 h aplica. Nunca borrar notas del agente anterior: se retoma con historial. |
| **Conflicto de reclamo del mismo módulo** | Gana el timestamp más antiguo en `CHECKLIST-GLOBAL.md`. El otro agente elige otro módulo. Disputas las resuelve el administrador del protocolo o el fundador. |
| **Módulo marcado ✅ sin cumplir DoD** | Cualquier agente lo detecta (o `verificar_checklist.py` con `[?]` en ✅) → se vuelve a 🟡 con hallazgos en las notas, se corrige y re-somete a QA cruzado. |
| **Conteo inflado en checklist/tabla** | Corregir el `05-Checklist.md` real; validar con `verificar_checklist.py`; regenerar con `generar_checklist_global.py --dry-run` y ejecutar solo si los cambios no pisan estados en curso ajenos (ver log 2026-08-28 del M133: la ejecución directa cambiaría estados de 38/39/59/66 → se prefiere edición manual de filas propias). |
| **Cambio de alcance a mitad de hito** | Procedimiento de `guia-hitos.md` §5 (evaluar → ADR o backlog M136 → actualizar plantilla del hito). |
| **Deuda técnica acumulada** | Si crece 2 bloques seguidos (métrica de `guia-sprints.md` §5) → dedicar un bloque o parte del hito siguiente a pagarla antes de sumar contenido nuevo. |
| **Ausencia prolongada del fundador** | La documentación es autoexplicativa (README de gestión §7). Los agentes continúan solo módulos con salida verificable sin decisiones humanas pendientes; lo que requiera decisión del fundador queda 🟡/anotado en `ESTADO-PARALELO.md` (RF9, RF13). |
| **Conflictos de merge / ramas divergentes** | Se respeta la política de M06 y `AGENTS.md` §4: ramas por módulo/hito, commits atómicos en español. Ante conflicto, coordinar en `Mensajes entre modelos/` con el agente dueño de los archivos; jamás forzar push. |
| **Replanificación por cambio de prioridades** | El fundador comunica la nueva prioridad; se recalcula el orden según la regla final de la guía 08 (primer módulo pendiente de la primera fase habilitada); los módulos 🔵 en curso se liberan con notas antes de reasignar. |
| **Sin internet / herramientas caídas** | Contingencia offline del README de gestión §8: Markdown local como verdad durable; sincronizar tablero/issues al volver. |

---

## 8. Comunicación entre agentes (puntual)

Para consultas, avisos y coordinación corta: carpetas por tema en `Mensajes entre modelos/` (formato y reglas en §10 de `AGENTS.md`). Para trabajo masivo, el canal principal es siempre el protocolo §21 (tabla global + ESTADO-PARALELO).

**Firma del último agente que modificó esta guía:**

**Modelo:** GLM
**Plataforma:** Kilo
