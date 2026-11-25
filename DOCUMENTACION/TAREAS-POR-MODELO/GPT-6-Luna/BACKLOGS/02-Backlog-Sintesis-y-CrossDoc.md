# 02 — Síntesis y análisis entre documentos (20 tareas)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Regla:** producir síntesis con punteros a las fuentes; no editar la documentación canónica ni presentar borradores como decisiones del proyecto.

1. [ ] S2-01 — Resumir un plan-actual asignado en objetivo, alcance, estado, dependencias y pendientes; citar secciones/líneas.
2. [ ] S2-02 — Comparar `01-Requerimientos.md` con `03-Diseno.md` de un mismo módulo y listar requisitos no mapeados.
3. [ ] S2-03 — Comparar diseño y ejecución (`03-Diseno.md` vs `04-Codigo.md`) y señalar contradicciones expresas.
4. [ ] S2-04 — Comparar `04-Codigo.md` con inventario de archivos y marcar referencias ausentes/existentes.
5. [ ] S2-05 — Sintetizar el estado de pruebas de un módulo desde plan y resultados de testing, sin elevar pruebas propuestas a ejecutadas.
6. [ ] S2-06 — Crear una matriz claim→fuente para afirmaciones de una sección de diseño escogida.
7. [ ] S2-07 — Identificar decisiones pendientes del usuario en documentos de un módulo y separar de tareas que el agente sí puede ejecutar.
8. [ ] S2-08 — Sintetizar un hilo de mensajes asignado en cronología, decisión, evidencia y estado; preservar enlaces a cada mensaje.
9. [ ] S2-09 — Comparar un mensaje de cierre con el código actual y clasificar cada afirmación como corroborada, stale o no verificable.
10. [ ] S2-10 — Extraer las lecciones aplicables a un bug conocido desde `11-BUGS.md` y guías temáticas, con referencias.
11. [?] S2-11 — Construir mapa de contradicciones de un flujo concreto entre `AGENTS.md`, guía temática y plan-actual; citar todas las fuentes. **Bloqueo:** el artefacto inicial solo cruzó `AGENTS.md` y `BACKLOG-MASTER`, sin guía temática ni `plan-actual`; no se marca completo. Evidencia parcial: `evidencias/S2-11-S2-15-sintesis-crossdoc.json`. Para resolver: seleccionar con el director un módulo no reservado y su guía temática aplicable.
12. [ ] S2-12 — Sintetizar las tareas pendientes de un módulo sin modificar marcas; incluir dueños explícitos y dependencias.
13. [ ] S2-13 — Comparar la versión actual y una versión histórica seleccionada para identificar cambios semánticos, no de formato.
14. [ ] S2-14 — Extraer un glosario de nombres de clase/sistema desde documentos y enlazar cada término con su archivo fuente.
15. [x] S2-15 — Crear un resumen ejecutivo de una guía larga limitado a 500 palabras con secciones exactas citadas. Evidencia: `evidencias/S2-11-S2-15-sintesis-crossdoc.json` (120 palabras; referencias a secciones/líneas de la guía 08 verificadas).
16. [ ] S2-16 — Comparar dos módulos que documentan la misma interfaz/contrato e identificar diferencias de vocabulario o firma.
17. [ ] S2-17 — Clasificar referencias de un documento por fuente oficial, fuente interna, hipótesis o dato histórico.
18. [ ] S2-18 — Preparar borrador de handoff para un módulo con qué está probado, qué falta, riesgo y próximo paso sugerido.
19. [ ] S2-19 — Comprobar que un resumen existente no omite condiciones, excepciones o propietarios nombrados en su fuente.
20. [ ] S2-20 — Evaluar consistencia de citas y fidelidad de un resumen contra una muestra elegida por el director; registrar omisiones y falsos claims.

## Regla de salida

El resultado puede ser informe temporal en el canal o documento borrador solo si el director lo solicita. No crear copias nuevas permanentes de documentación canónica por iniciativa propia.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
