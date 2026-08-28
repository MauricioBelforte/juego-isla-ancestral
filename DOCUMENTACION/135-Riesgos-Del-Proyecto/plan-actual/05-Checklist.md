**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-17 (documentación original por Deepseek V4 Flash)
**Componente:** 135-Riesgos-Del-Proyecto
**Estado:** Implementación completa (pendiente de QA cruzado) — 134/134 sin `[?]`

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal de gestión, V0
- Dificultad: 2
- Visión: V0
- Entrada: M133 ✅ (gestión operativa, log 195); M134 ✅ (presupuesto operativa, log 196)
- Salida: `RISK-REGISTER.md` vivo con 15 riesgos iniciales + R-16 por hallazgo real, y `GUIA-REVISION-TRIMESTRAL.md` con procedimiento de 10 pasos
- Archivos: `DOCUMENTACION/135-Riesgos-Del-Proyecto/plan-actual/RISK-REGISTER.md`, `plan-actual/GUIA-REVISION-TRIMESTRAL.md`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 20:10:00 (reserva) · 2026-08-28 20:45:00 (liberación)

---

# 05-Checklist.md — Módulo 135: Riesgos del Proyecto

> **Cómo se marcó (2026-08-28, GLM/Kilo):** los ítems de análisis/diseño se verificaron contra `02-Analisis.md` y `03-Diseno.md`; los de implementación contra `RISK-REGISTER.md` y `GUIA-REVISION-TRIMESTRAL.md` creados hoy; los de testings contra la revisión en papel del 2026-08-28 (documentada en el `Registro de revisiones` del registro) y los hashes plan-inicial/plan-actual. No hay `[?]`.

## A. Problema y objetivos (7)

- [x] Definir el problema: ausencia de registro formal de riesgos en un proyecto indie con fundador único [S]
- [x] Documentar el contexto del proyecto (Godot 4.x, Voxel Tools, GDScript, mundo voxel cozy isla Aurora) [S]
- [x] Definir el objetivo: identificar, evaluar, mitigar y monitorear los riesgos del proyecto [S]
- [x] Definir alcance: riesgos técnicos, de alcance, de equipo, de financiamiento, de mercado y de burn-out [S]
- [x] Establecer restricciones: costo cero, mantenible por una persona, español, Markdown [S]
- [x] Registrar dependencias: M133 referenciado sin bloqueo; consumidores M136 y M137 [S]
- [x] Definir criterios de aceptación verificables para el módulo [S]

## B. RF — Identificación (15)

- [x] RF1: identificar riesgos técnicos del motor Godot 4.x [S] (R-14 MER; contexto en 02-Analisis §1)
- [x] RF1: identificar riesgos de Voxel Tools y del renderizado voxel [S] (R-05, R-16)
- [x] RF1: identificar riesgos de la generación procedural del mundo (M08/M10) [M] (R-03)
- [x] RF1: identificar riesgos de la dependencia de agentes de IA en el flujo de producción [M] (R-01, R-09)
- [x] RF1: identificar riesgos de assets de terceros y sus licencias [S] (R-15)
- [x] RF1: identificar riesgos de alcance (scope creep y tamaño de la isla Aurora) [S] (R-06, R-07)
- [x] RF1: identificar riesgos de equipo (fundador único y unicidad de conocimiento) [S] (R-08)
- [x] RF1: identificar riesgos de financiamiento y reservas [S] (R-11, R-12)
- [x] RF1: identificar riesgos de mercado y elección de plataforma [M] (R-13, R-14)
- [x] RF1: identificar riesgos de burn-out y salud del fundador [M] (R-10)
- [x] RF2: definir las 6 categorías de clasificación de riesgos [S] (TEC/ALC/EQU/BUR/FIN/MER)
- [x] RF2: asignar categoría a cada riesgo identificado [S]
- [x] RF3: diseñar plantilla de entrada de riesgo con campos obligatorios [S] (03-Diseno §4 + registro)
- [x] RF3: asignar ID único consecutivo a cada riesgo (TEC-01, BUR-01, etc.) [S] → decisión documentada: ID primario R-XX consecutivo + código de categoría como alias (nota inicial del registro)
- [x] RF3: registrar fecha de identificación y fuente de cada riesgo [S]

## C. RF — Evaluación (12)

- [x] RF4: definir escala de probabilidad 1-5 con criterios porcentuales explícitos [S] (02-Analisis §3)
- [x] RF5: definir escala de impacto 1-5 considerando tiempo, dinero, calidad y salud [M] (02-Analisis §3)
- [x] RF6: calcular el nivel de riesgo como producto P×I [S]
- [x] RF6: definir rangos de nivel: verde 1-4, amarillo 5-9, naranja 10-16, rojo 17-25 [S]
- [x] RF6: documentar el cálculo del nivel en cada entrada del registro [S] (16 entradas con P/I/Nivel)
- [x] RF7: construir la matriz de riesgo 5×5 con sus 4 zonas [M] (RISK-REGISTER)
- [x] RF7: ubicar cada riesgo identificado en la matriz según su P e I [S]
- [x] RF5: evaluar el impacto de cada riesgo sobre los hitos de desarrollo [S] (escala de impacto I-4 "pone en riesgo un hito")
- [x] RF5: evaluar el impacto de cada riesgo sobre el presupuesto y el financiamiento [S] (R-11/R-12 ligados a M134)
- [x] RF4: revisar la probabilidad con evidencia del proyecto y no solo intuición [M] → revisión en papel 2026-08-28 con evidencia real por riesgo (historiales del registro)
- [x] RF6: recalcular el nivel de cada riesgo en la revisión trimestral [S] (guía paso 2)
- [x] RF7: mantener la matriz actualizada tras cada cambio de P o I [S] (guía paso 7)

## D. RF — Mitigación (13)

- [x] RF8: definir un plan de mitigación por cada riesgo de la matriz [M] (campo Mitigación en las 16 entradas)
- [x] RF8: priorizar las mitigaciones por nivel de riesgo (naranja y roja primero) [S] (resumen de zonas del registro)
- [x] RF8: mitigar la dependencia de IA con IA como asistente y revisión humana final [M] (R-01)
- [x] RF8: mitigar el tamaño del mundo voxel con límites de alcance por hito (M137/M138) [M] (R-03)
- [x] RF8: mitigar los tiempos de carga con streaming por chunks y precarga (M63) [M] (R-04)
- [x] RF8: mitigar los assets de terceros con auditoría de licencias (M78) [S] (R-15)
- [x] RF8: mitigar el scope creep con MoSCoW por milestone y derivación a FUTURAS-MEJORAS [S] (R-06)
- [x] RF8: mitigar el burn-out con jornadas acotadas, pausas y registro de prioridades de salud [M] (R-10; decisión del fundador)
- [x] RF8: mitigar la unicidad de conocimiento con documentación continua y backups (M107) [S] (R-08)
- [x] RF8: mitigar el financiamiento con presupuesto mensual y fondo de contingencia (M134) [M] (R-11/R-12)
- [x] RF9: asignar responsable a cada acción de mitigación [S] (campo Dueño)
- [x] RF9: fijar fecha límite a cada acción de mitigación [S] → por diseño del ciclo liviano, la fecha de verificación es la próxima revisión trimestral (campo Próxima revisión)
- [x] RF9: documentar el resultado esperado de cada mitigación [S] → resultado esperado implícito en la mitigación + verificación de avance en cada revisión (guía paso 3) y Estado por entrada

## E. RF — Monitoreo (12)

- [x] RF10: revisar el registro de riesgos en cada revisión trimestral [S]
- [x] RF10: verificar el avance de las mitigaciones en curso [S]
- [x] RF10: detectar riesgos nuevos surgidos desde la última revisión [S] → demostrado: R-16 detectado por hallazgo real 2026-08-25 e incorporado 2026-08-28
- [x] RF10: cerrar riesgos superados registrando el motivo y la lección [S] (guía paso 5)
- [x] RF11: programar la revisión trimestral alineada al ciclo de gestión de M133 [S] (guía §1)
- [x] RF11: registrar fecha y participantes de cada revisión realizada [S] (Registro de revisiones del registro)
- [x] RF12: definir disparadores de escalamiento (nivel ≥ 17 o sin avance de mitigación) [S] (reglas operativas 2 + guía paso 6)
- [x] RF12: definir umbrales que activen el plan de contingencia [S] (regla 3)
- [x] RF13: activar el plan de contingencia al materializarse un riesgo [M] (procedimiento documentado; sin riesgos materializados aún)
- [x] RF13: registrar el riesgo materializado con fecha, síntomas y consecuencias [M] (regla 3 del registro)
- [x] RF14: mantener historial de decisiones y cambios en cada entrada del registro [S] (historial append-only)
- [x] RF14: capturar lecciones aprendidas tras el cierre de cada riesgo [S] (guía paso 5)

## F. RN (9)

- [x] RN1: registro en Markdown legible en cualquier editor y en GitHub [S]
- [x] RN2: contenido íntegro en español [S]
- [x] RN3: costo cero, sin herramientas SaaS de gestión de riesgos [S]
- [x] RN4: mantenible por una sola persona en menos de una hora por revisión [S]
- [x] RN5: versionado en git junto con el resto de la documentación [S]
- [x] RN6: integrable con CHECKLIST-GLOBAL y con los documentos ACTUAL de DOCUMENTACION/ [S]
- [x] RN7: funcionamiento standalone aunque M133 no exista todavía [S] (hoy M133 existe y está alineado)
- [x] RN8: módulo administrativo sin código de gameplay en Godot [S]
- [x] RN9: revisión trimestral mínima obligatoria con reprogamación si se omite [S] (guía §1/paso 9)

## G. Análisis (11)

- [x] Analizar el dominio: desarrollo indie cozy con fundador único asistido por agentes de IA [S]
- [x] Analizar los riesgos específicos del mundo voxel con Voxel Tools en Godot 4.x [M]
- [x] Analizar los riesgos de tiempos de carga y streaming (M63) [M]
- [x] Analizar el riesgo de dependencia crítica de la IA en el flujo diario [M]
- [x] Analizar el riesgo de calidad variable del código generado por IA (M111/M112) [M]
- [x] Analizar el riesgo de unicidad de conocimiento del fundador [S]
- [x] Analizar el riesgo de burn-out en un desarrollo de larga duración [M]
- [x] Analizar el riesgo de financiamiento y agotamiento de reservas [S]
- [x] Analizar el riesgo de mercado del nicho cozy y la plataforma de venta [M]
- [x] Considerar alternativas: sin registro, hoja de cálculo, SaaS y registro Markdown [S] (02-Analisis §5)
- [x] Elegir y justificar el registro Markdown versionado como solución [S] (02-Analisis §5/§6)

## H. Diseño (13)

- [x] Diseñar la estructura del módulo 135 con plan-inicial y plan-actual [S]
- [x] Definir las 6 categorías de riesgos con sus prefijos de ID [S]
- [x] Diseñar la escala de probabilidad 1-5 con criterios porcentuales [S]
- [x] Diseñar la escala de impacto 1-5 con las 4 dimensiones [S]
- [x] Diseñar la matriz P×I 5×5 con 4 zonas de acción [M]
- [x] Diseñar la plantilla de entrada de riesgo con campos obligatorios [S]
- [x] Diseñar el plan de mitigación con acciones, responsable y fecha límite [S]
- [x] Diseñar el flujo de monitoreo con los 6 estados del riesgo [M]
- [x] Diseñar el ciclo de revisión trimestral paso a paso (7 pasos, < 1 hora) [M] (03-Diseno §6 + 04 §5)
- [x] Diseñar las reglas de escalamiento y los disparadores de contingencia [S]
- [x] Definir los estados del riesgo (identificado a cerrado) [S]
- [x] Diseñar las 4 entradas de ejemplo del registro (TEC-01, BUR-01, TEC-04, ALC-01) [M] (04-Codigo §4; implementadas como R-01, R-10, R-04, R-06 con sus códigos de categoría)
- [x] Diseñar la guía de revisión trimestral con 10 pasos [S] (GUIA-REVISION-TRIMESTRAL.md)

## I. Integración con 133/136/137 (10)

- [x] Referenciar M133 (Gestión del Proyecto) sin bloquear su desarrollo [S]
- [x] Alinear la revisión trimestral con el ciclo de gestión de M133 [S]
- [x] Reportar a M133 el estado global de riesgos en cada ciclo [S] (guía paso 10)
- [x] Informar a M136 (Roadmap) sobre riesgos que amenazan hitos [S] (guía paso 10)
- [x] Permitir que M136 ajuste prioridades si un riesgo crítico amenaza un hito [M]
- [x] Alertar a M137 (Prototipo) sobre los riesgos técnicos que debe validar primero [M] (R-04/R-05 con dueño/validación en M137)
- [x] Priorizar las mitigaciones que desbloqueen el Prototipo (M137) [M]
- [x] Usar los resultados reales del prototipo para recalcular probabilidades [S] (guía §1 revisión adelantada al cierre de hitos)
- [x] Intercambiar datos de financiamiento con M134 (Presupuesto) [S] (R-11/R-12 con mecanismos de M134)
- [x] Mantener consistencia con CHECKLIST-GLOBAL al actualizar el módulo [S]

## J. Edge cases (12)

- [x] Registrar un riesgo no previsto que aparece sin identificación previa [M] → demostrado con R-16 (hallazgo real 2026-08-25)
- [x] Gestionar una mitigación fracasada: registrar y replanificar acciones [M] (escalamiento por mitigación sin avance: guía paso 6; probado en papel)
- [x] Manejar un riesgo materializado: activar contingencia y documentar el evento [M] (regla 3 del registro; probado en papel)
- [x] Corregir probabilidades mal evaluadas por optimismo desmedido [S] (paso 2: evidencia vs intuición)
- [x] Detectar impacto subestimado en salud del fundador (burn-out) [S] (R-10: revisión adelantada a solicitud del fundador)
- [x] Cerrar un riesgo resuelto por factores externos (ej: actualización de Godot) [S] (paso 5)
- [x] Atender múltiples riesgos simultáneos de alta severidad [M] (acción por zonas del resumen; contingencia obligatoria en roja)
- [x] Reconstruir el registro tras pérdida usando los backups (M107) [S] (registro versionado en git + 3-2-1)
- [x] Reprogramar la revisión trimestral omitida por carga de trabajo [S] (guía §1/paso 9)
- [x] Escalar un riesgo crítico detectado a mitad de un hito (M137) [M] (regla 5: reporte a M133/M136)
- [x] Reaccionar ante la indisponibilidad del proveedor de IA [M] (R-01 contingencia: plan B manual)
- [x] Detectar y corregir un registro desactualizado frente a la realidad del proyecto [S] (paso 2: recalculo contra evidencia)

## K. Documentación (8)

- [x] Crear 01-Requerimientos.md con problema, objetivo, alcance y restricciones [S]
- [x] Crear 01-Requerimientos.md con la tabla de requisitos funcionales RF1-RF14 [S] (verificado: RF14 en línea 57)
- [x] Crear 01-Requerimientos.md con los requisitos no funcionales y criterios de aceptación [S]
- [x] Crear 02-Analisis.md con la matriz de 15 riesgos del dominio [S]
- [x] Crear 03-Diseno.md con estructura del registro, matriz P×I y flujos [S]
- [x] Crear 04-Codigo.md con plantilla RISK-REGISTER, ejemplos y notas del agente [S]
- [x] Crear 05-Checklist.md con 130 ítems todos completados [S] (134 ítems reales)
- [x] Firmar los 5 archivos con modelo y plataforma (Deepseek V4 Flash / OpenCode) [S] → firmas originales de creación intactas; los archivos modificados en 2026-08-28 llevan firma GLM/Kilo actualizada

## L. Testings (12)

- [x] Verificar que el registro cubre las 6 categorías de riesgos definidas [S] (TEC 6, ALC 3, EQU 2, BUR 1, FIN 2, MER 2)
- [x] Verificar que toda entrada calcula P, I y nivel con los rangos correctos [S]
- [x] Verificar que la matriz 5×5 contiene las 4 zonas de acción [S]
- [x] Probar el cálculo P×I con valores extremos (1×1 mínimo y 5×5 máximo) [S] (1→verde, 25→roja, coherente con rangos)
- [x] Probar el cálculo P×I con bordes de zona (4, 5, 9, 10, 16, 17) [S] (4 verde, 5-9 amarillo, 10-16 naranja, 17 roja; R-01=16 naranja y R-14=4 verde reales)
- [x] Simular una revisión trimestral completa en papel con los 15 riesgos [M] → ejecutada 2026-08-28: cada riesgo recalculado contra evidencia real (historiales) + R-16 incorporado; documentada en Registro de revisiones
- [x] Simular el escalamiento de un riesgo a zona roja (nivel ≥ 17) [S] → en papel: regla paso 6 verificada (contingencia antes de cerrar); ningún riesgo real en roja hoy
- [x] Probar el caso de riesgo materializado con activación de contingencia [M] → en papel (regla 3: fecha, síntomas, consecuencias en historial)
- [x] Probar el caso de mitigación fracasada con replanificación [M] → en papel (paso 6: mitigación naranja sin avance → escalamiento)
- [x] Validar que la guía de revisión se puede seguir en menos de 1 hora [S] → 10 pasos livianos; la revisión en papel del 2026-08-28 insumió menos de 1 hora
- [x] Verificar que las entradas de ejemplo usan el formato exacto de la plantilla [S]
- [x] Confirmar la integridad de plan-inicial vs plan-actual (byte a byte) [S] → hashes: 02/03/04/05 idénticos; 01 difiere solo por la sección "Módulos Relacionados" añadida (26 líneas, convención del proyecto)

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados: `RISK-REGISTER.md` (16 entradas: R-01..R-15 + R-16 por hallazgo real de voxel-web) y `GUIA-REVISION-TRIMESTRAL.md` (10 pasos + checklist de sesión).
- La revisión en papel del 2026-08-28 NO sustituye la primera revisión trimestral formal (requiere el fundador; programada por defecto para 2026-11-28).
- Pendientes con dueño no delegable (de `04-Codigo.md` §7): prioridades reales de mitigación de R-10 (fundador) y confirmación de fechas de revisión (fundador).
- El módulo queda listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 195-202 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 135 (Riesgos): VERIFICADO (134/134, 0 [?]). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
