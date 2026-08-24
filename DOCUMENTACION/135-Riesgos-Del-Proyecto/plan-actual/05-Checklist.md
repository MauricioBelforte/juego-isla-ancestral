**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 135: Riesgos del Proyecto

## A. Problema y objetivos (7)

- [ ] Definir el problema: ausencia de registro formal de riesgos en un proyecto indie con fundador único [S]
- [ ] Documentar el contexto del proyecto (Godot 4.x, Voxel Tools, GDScript, mundo voxel cozy isla Aurora) [S]
- [ ] Definir el objetivo: identificar, evaluar, mitigar y monitorear los riesgos del proyecto [S]
- [ ] Definir alcance: riesgos técnicos, de alcance, de equipo, de financiamiento, de mercado y de burn-out [S]
- [ ] Establecer restricciones: costo cero, mantenible por una persona, español, Markdown [S]
- [ ] Registrar dependencias: M133 referenciado sin bloqueo; consumidores M136 y M137 [S]
- [ ] Definir criterios de aceptación verificables para el módulo [S]

## B. RF — Identificación (15)

- [ ] RF1: identificar riesgos técnicos del motor Godot 4.x [S]
- [ ] RF1: identificar riesgos de Voxel Tools y del renderizado voxel [S]
- [ ] RF1: identificar riesgos de la generación procedural del mundo (M08/M10) [M]
- [ ] RF1: identificar riesgos de la dependencia de agentes de IA en el flujo de producción [M]
- [ ] RF1: identificar riesgos de assets de terceros y sus licencias [S]
- [ ] RF1: identificar riesgos de alcance (scope creep y tamaño de la isla Aurora) [S]
- [ ] RF1: identificar riesgos de equipo (fundador único y unicidad de conocimiento) [S]
- [ ] RF1: identificar riesgos de financiamiento y reservas [S]
- [ ] RF1: identificar riesgos de mercado y elección de plataforma [M]
- [ ] RF1: identificar riesgos de burn-out y salud del fundador [M]
- [ ] RF2: definir las 6 categorías de clasificación de riesgos [S]
- [ ] RF2: asignar categoría a cada riesgo identificado [S]
- [ ] RF3: diseñar plantilla de entrada de riesgo con campos obligatorios [S]
- [ ] RF3: asignar ID único consecutivo a cada riesgo (TEC-01, BUR-01, etc.) [S]
- [ ] RF3: registrar fecha de identificación y fuente de cada riesgo [S]

## C. RF — Evaluación (12)

- [ ] RF4: definir escala de probabilidad 1-5 con criterios porcentuales explícitos [S]
- [ ] RF5: definir escala de impacto 1-5 considerando tiempo, dinero, calidad y salud [M]
- [ ] RF6: calcular el nivel de riesgo como producto P×I [S]
- [ ] RF6: definir rangos de nivel: verde 1-4, amarillo 5-9, naranja 10-16, rojo 17-25 [S]
- [ ] RF6: documentar el cálculo del nivel en cada entrada del registro [S]
- [ ] RF7: construir la matriz de riesgo 5×5 con sus 4 zonas [M]
- [ ] RF7: ubicar cada riesgo identificado en la matriz según su P e I [S]
- [ ] RF5: evaluar el impacto de cada riesgo sobre los hitos de desarrollo [S]
- [ ] RF5: evaluar el impacto de cada riesgo sobre el presupuesto y el financiamiento [S]
- [ ] RF4: revisar la probabilidad con evidencia del proyecto y no solo intuición [M]
- [ ] RF6: recalcular el nivel de cada riesgo en la revisión trimestral [S]
- [ ] RF7: mantener la matriz actualizada tras cada cambio de P o I [S]

## D. RF — Mitigación (13)

- [ ] RF8: definir un plan de mitigación por cada riesgo de la matriz [M]
- [ ] RF8: priorizar las mitigaciones por nivel de riesgo (naranja y roja primero) [S]
- [ ] RF8: mitigar la dependencia de IA con IA como asistente y revisión humana final [M]
- [ ] RF8: mitigar el tamaño del mundo voxel con límites de alcance por hito (M137/M138) [M]
- [ ] RF8: mitigar los tiempos de carga con streaming por chunks y precarga (M63) [M]
- [ ] RF8: mitigar los assets de terceros con auditoría de licencias (M78) [S]
- [ ] RF8: mitigar el scope creep con MoSCoW por milestone y derivación a FUTURAS-MEJORAS [S]
- [ ] RF8: mitigar el burn-out con jornadas acotadas, pausas y registro de prioridades de salud [M]
- [ ] RF8: mitigar la unicidad de conocimiento con documentación continua y backups (M107) [S]
- [ ] RF8: mitigar el financiamiento con presupuesto mensual y fondo de contingencia (M134) [M]
- [ ] RF9: asignar responsable a cada acción de mitigación [S]
- [ ] RF9: fijar fecha límite a cada acción de mitigación [S]
- [ ] RF9: documentar el resultado esperado de cada mitigación [S]

## E. RF — Monitoreo (12)

- [ ] RF10: revisar el registro de riesgos en cada revisión trimestral [S]
- [ ] RF10: verificar el avance de las mitigaciones en curso [S]
- [ ] RF10: detectar riesgos nuevos surgidos desde la última revisión [S]
- [ ] RF10: cerrar riesgos superados registrando el motivo y la lección [S]
- [ ] RF11: programar la revisión trimestral alineada al ciclo de gestión de M133 [S]
- [ ] RF11: registrar fecha y participantes de cada revisión realizada [S]
- [ ] RF12: definir disparadores de escalamiento (nivel ≥ 17 o sin avance de mitigación) [S]
- [ ] RF12: definir umbrales que activen el plan de contingencia [S]
- [ ] RF13: activar el plan de contingencia al materializarse un riesgo [M]
- [ ] RF13: registrar el riesgo materializado con fecha, síntomas y consecuencias [M]
- [ ] RF14: mantener historial de decisiones y cambios en cada entrada del registro [S]
- [ ] RF14: capturar lecciones aprendidas tras el cierre de cada riesgo [S]

## F. RN (9)

- [ ] RN1: registro en Markdown legible en cualquier editor y en GitHub [S]
- [ ] RN2: contenido íntegro en español [S]
- [ ] RN3: costo cero, sin herramientas SaaS de gestión de riesgos [S]
- [ ] RN4: mantenible por una sola persona en menos de una hora por revisión [S]
- [ ] RN5: versionado en git junto con el resto de la documentación [S]
- [ ] RN6: integrable con CHECKLIST-GLOBAL y con los documentos ACTUAL de DOCUMENTACION/ [S]
- [ ] RN7: funcionamiento standalone aunque M133 no exista todavía [S]
- [ ] RN8: módulo administrativo sin código de gameplay en Godot [S]
- [ ] RN9: revisión trimestral mínima obligatoria con reprogamación si se omite [S]

## G. Análisis (11)

- [ ] Analizar el dominio: desarrollo indie cozy con fundador único asistido por agentes de IA [S]
- [ ] Analizar los riesgos específicos del mundo voxel con Voxel Tools en Godot 4.x [M]
- [ ] Analizar los riesgos de tiempos de carga y streaming (M63) [M]
- [ ] Analizar el riesgo de dependencia crítica de la IA en el flujo diario [M]
- [ ] Analizar el riesgo de calidad variable del código generado por IA (M111/M112) [M]
- [ ] Analizar el riesgo de unicidad de conocimiento del fundador [S]
- [ ] Analizar el riesgo de burn-out en un desarrollo de larga duración [M]
- [ ] Analizar el riesgo de financiamiento y agotamiento de reservas [S]
- [ ] Analizar el riesgo de mercado del nicho cozy y la plataforma de venta [M]
- [ ] Considerar alternativas: sin registro, hoja de cálculo, SaaS y registro Markdown [S]
- [ ] Elegir y justificar el registro Markdown versionado como solución [S]

## H. Diseño (13)

- [ ] Diseñar la estructura del módulo 135 con plan-inicial y plan-actual [S]
- [ ] Definir las 6 categorías de riesgos con sus prefijos de ID [S]
- [ ] Diseñar la escala de probabilidad 1-5 con criterios porcentuales [S]
- [ ] Diseñar la escala de impacto 1-5 con las 4 dimensiones [S]
- [ ] Diseñar la matriz P×I 5×5 con 4 zonas de acción [M]
- [ ] Diseñar la plantilla de entrada de riesgo con campos obligatorios [S]
- [ ] Diseñar el plan de mitigación con acciones, responsable y fecha límite [S]
- [ ] Diseñar el flujo de monitoreo con los 6 estados del riesgo [M]
- [ ] Diseñar el ciclo de revisión trimestral paso a paso (7 pasos, < 1 hora) [M]
- [ ] Diseñar las reglas de escalamiento y los disparadores de contingencia [S]
- [ ] Definir los estados del riesgo (identificado a cerrado) [S]
- [ ] Diseñar las 4 entradas de ejemplo del registro (TEC-01, BUR-01, TEC-04, ALC-01) [M]
- [ ] Diseñar la guía de revisión trimestral con 10 pasos [S]

## I. Integración con 133/136/137 (10)

- [ ] Referenciar M133 (Gestión del Proyecto) sin bloquear su desarrollo [S]
- [ ] Alinear la revisión trimestral con el ciclo de gestión de M133 [S]
- [ ] Reportar a M133 el estado global de riesgos en cada ciclo [S]
- [ ] Informar a M136 (Roadmap) sobre riesgos que amenazan hitos [S]
- [ ] Permitir que M136 ajuste prioridades si un riesgo crítico amenaza un hito [M]
- [ ] Alertar a M137 (Prototipo) sobre los riesgos técnicos que debe validar primero [M]
- [ ] Priorizar las mitigaciones que desbloqueen el Prototipo (M137) [M]
- [ ] Usar los resultados reales del prototipo para recalcular probabilidades [S]
- [ ] Intercambiar datos de financiamiento con M134 (Presupuesto) [S]
- [ ] Mantener consistencia con CHECKLIST-GLOBAL al actualizar el módulo [S]

## J. Edge cases (12)

- [ ] Registrar un riesgo no previsto que aparece sin identificación previa [M]
- [ ] Gestionar una mitigación fracasada: registrar y replanificar acciones [M]
- [ ] Manejar un riesgo materializado: activar contingencia y documentar el evento [M]
- [ ] Corregir probabilidades mal evaluadas por optimismo desmedido [S]
- [ ] Detectar impacto subestimado en salud del fundador (burn-out) [S]
- [ ] Cerrar un riesgo resuelto por factores externos (ej: actualización de Godot) [S]
- [ ] Atender múltiples riesgos simultáneos de alta severidad [M]
- [ ] Reconstruir el registro tras pérdida usando los backups (M107) [S]
- [ ] Reprogramar la revisión trimestral omitida por carga de trabajo [S]
- [ ] Escalar un riesgo crítico detectado a mitad de un hito (M137) [M]
- [ ] Reaccionar ante la indisponibilidad del proveedor de IA [M]
- [ ] Detectar y corregir un registro desactualizado frente a la realidad del proyecto [S]

## K. Documentación (8)

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y restricciones [S]
- [ ] Crear 01-Requerimientos.md con la tabla de requisitos funcionales RF1-RF14 [S]
- [ ] Crear 01-Requerimientos.md con los requisitos no funcionales y criterios de aceptación [S]
- [ ] Crear 02-Analisis.md con la matriz de 15 riesgos del dominio [S]
- [ ] Crear 03-Diseno.md con estructura del registro, matriz P×I y flujos [S]
- [ ] Crear 04-Codigo.md con plantilla RISK-REGISTER, ejemplos y notas del agente [S]
- [ ] Crear 05-Checklist.md con 130 ítems todos completados [S]
- [ ] Firmar los 5 archivos con modelo y plataforma (Deepseek V4 Flash / OpenCode) [S]

## L. Testings (12)

- [ ] Verificar que el registro cubre las 6 categorías de riesgos definidas [S]
- [ ] Verificar que toda entrada calcula P, I y nivel con los rangos correctos [S]
- [ ] Verificar que la matriz 5×5 contiene las 4 zonas de acción [S]
- [ ] Probar el cálculo P×I con valores extremos (1×1 mínimo y 5×5 máximo) [S]
- [ ] Probar el cálculo P×I con bordes de zona (4, 5, 9, 10, 16, 17) [S]
- [ ] Simular una revisión trimestral completa en papel con los 15 riesgos [M]
- [ ] Simular el escalamiento de un riesgo a zona roja (nivel ≥ 17) [S]
- [ ] Probar el caso de riesgo materializado con activación de contingencia [M]
- [ ] Probar el caso de mitigación fracasada con replanificación [M]
- [ ] Validar que la guía de revisión se puede seguir en menos de 1 hora [S]
- [ ] Verificar que las entradas de ejemplo usan el formato exacto de la plantilla [S]
- [ ] Confirmar la integridad de plan-inicial vs plan-actual (byte a byte) [S]