# BACKLOG-MASTER — GPT-6-Luna (índice rector)

**Modelo:** GPT-6-Luna (`gpt-6-luna`)
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Estado:** Plan inicial de 160 tareas candidatas pendientes; ninguna tarea de este plan se declara ejecutada.
**Nicho prioritario propuesto:** trabajos de alto volumen y contexto extenso con salida estructurada verificable: extracción/clasificación de documentos, síntesis cross-doc con citas, normalización de datos y validación JSON. Son fortalezas potenciales declaradas en la ficha oficial; aún no hay evidencia empírica del proyecto ni comparación homogénea que permita afirmar superioridad frente a la flota. La sesión debe buscar activamente ese nicho, medirlo y reportar resultados comparables al director.

## 1. Propósito y alcance

Este archivo es la **guía rectora** para todos los sub-backlogs listados abajo. Define cómo leerlos, seleccionar trabajo, verificarlo y reportarlo. Los sub-backlogs dividen el trabajo por especialidad; no son ocho autorizaciones independientes para cambiar el proyecto.

El conjunto prioriza tareas **acotadas, repetibles y auditables**, especialmente las de síntesis de grandes lotes, extracción estructurada y análisis cross-doc donde el contexto amplio y structured outputs pueden ser útiles. Si aparece una oportunidad de alto valor alineada con esas fortalezas, proponerla o tomarla si está pendiente, autorizada, sin dueño/reserva en curso y dentro de la fase habilitada. No asumir superioridad: verificarla con mismo corpus, prompt, herramientas, rúbrica/gold set y métrica que los demás modelos; si no puede controlarse la comparación, informar solo el resultado propio y los límites. Hay ítems de consulta, reporte, diseño de pruebas y evaluación; que una tarea aparezca aquí no significa que se haya ejecutado, que el modelo esté asignado a un módulo ni que el director haya aprobado una modificación.

## 2. Ciclo obligatorio antes de trabajar

1. Leer `AGENTS.md` completo (contexto general y reglas del proyecto).
2. Revisar siempre `Mensajes entre modelos/GPT-6-Luna/`: primero el último mensaje y después cualquier instrucción pendiente. Si hay un mensaje de director, atenderlo antes de seleccionar una tarea. No inferir instrucciones desde el nombre del archivo; si es una plantilla, respetar T-19 y esperar cinco minutos antes de releer.
3. Leer este `BACKLOG-MASTER.md` y el sub-backlog de la tarea candidata.
4. Contrastar que la tarea siga pendiente y no duplique una salida existente. Para trabajo ligado a un módulo, consultar `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` y `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`; respetar fase, reservas y dependencias.
5. Por defecto, trabajar en lectura y preparación. No editar archivos canónicos, código, backlog de otro modelo, checklist de módulo o tabla GLOBAL, ni reservar un módulo, sin instrucción/encargo y coordinación requeridos.
6. Ejecutar solo comprobaciones acotadas y autorizadas; auditar efectos de un script antes de ejecutarlo. Separar claramente análisis estático, prueba diseñada, prueba ejecutada y prueba pasada.
7. Mantener evidencia reproducible: ruta, sección/línea, comando/método, salida relevante, alcance y límites. No elevar hipótesis, fuentes históricas ni propuestas a hechos actuales.
8. Al cerrar **cada sub-backlog**, comprobar otra vez el canal y reportar al director en `Mensajes entre modelos/GPT-6-Luna/`. El detalle va en un mensaje propio de ese canal; el chat solo recibe un aviso breve. La numeración debe seguir el protocolo oficial y helper del proyecto; nunca numerar manualmente ni editar mensaje de otra persona. El pool de este canal está en `Mensajes entre modelos/GPT-6-Luna/NUMEROS_DISPONIBLES.txt`; la apertura formal `01` corresponde al director según el README del canal. Si helper/pool no está disponible o hay una denegación de ejecución, registrar el bloqueo y no improvisar ni eludirla.

## 3. Estados y regla anti-duplicación

- `[ ]` = candidata aún no ejecutada. Es el estado inicial de las 160 tareas.
- `[x]` = solo después de ejecutar y verificar el resultado definido; el informe debe enlazar evidencia. No usar para planificación, lectura superficial ni salida copiada de otro modelo.
- `[?]` = no resuelta, no verificable o bloqueada, con causa y qué la desbloquearía.
- Si el resultado ya existe en HEAD o en una entrega previa, **no repetirlo para sumar una marca**: registrar duplicidad/obsolescencia en el reporte del sub-backlog y conservar la tarea pendiente hasta que el director decida si la reemplaza.
- No heredar resultados, pruebas ni calibraciones de `GPT-Luna` (GPT-5.6 Luna). Mantener identidades separadas.

## 4. Ocho sub-backlogs (20 tareas cada uno)

| Orden | Archivo | Especialidad | Prefijo | Tareas |
|---|---|---|---|---:|
| 01 | `01-Backlog-Censos-y-Clasificacion.md` | Censos pequeños, extracción, inventarios y clasificación con fuentes | C1 | 20 |
| 02 | `02-Backlog-Sintesis-y-CrossDoc.md` | Síntesis documental, trazabilidad de claims y análisis entre fuentes | S2 | 20 |
| 03 | `03-Backlog-Estructuras-y-JSON.md` | Esquemas, consistencia de datos, catálogos y JSON | J3 | 20 |
| 04 | `04-Backlog-Auditoria-Documental-y-Codigo.md` | Auditoría documental/estática y contraste de claims con disco | A4 | 20 |
| 05 | `05-Backlog-Calibracion-y-Consistencia.md` | Medición empírica acotada de esta sesión, exactitud y límites | K5 | 20 |
| 06 | `06-Validacion-y-Pruebas.md` | Test existente, diseño de casos y reporte QA con evidencia | V6 | 20 |
| 07 | `07-Localizacion-y-Recuperacion.md` | Encontrar fuentes, procedimientos, dependencias y handoffs | R7 | 20 |
| 08 | `08-Informes-y-Coordinacion.md` | Informes, lectura del canal, handoffs y coordinación | C8 | 20 |

**Total:** 8 × 20 = **160 tareas**, todas pendientes al crear el plan. No se cuentan instrucciones de este índice como tareas ejecutadas.

## 5. Priorización por ajuste de capacidades

1. Priorizar primero `02` síntesis de documentos extensos y cross-doc, y `01` extracción/clasificación de alto volumen con esquema explícito: son las hipótesis de mejor ajuste a la ventana de contexto y eficiencia enfocada descritas por la ficha oficial.
2. En esas tareas, diseñar salidas estructuradas y trazables (tablas/JSON, claim→fuente, estados separados) y verificar contra las fuentes; el formato estructurado no sustituye la revisión de fidelidad.
3. Usar `03` para validar datos/JSON en esquemas reales y `04` para contrastar muchos claims documentales con archivos, preferiblemente por lotes reproducibles.
4. Usar `05` desde el inicio para medir exactitud, omisiones, citas, errores y límites propios. Si el director autoriza, comparar tareas equivalentes con otros modelos de la flota y reclamar un nicho superior solo si los resultados controlados lo sostienen.
5. Tomar `06` y `07` cuando haya un test/procedimiento existente y alcance autorizado; no traducir capacidades de coding anunciadas por el proveedor en autorización para tocar código o módulos.
6. Usar `08` como protocolo transversal de comunicación; el reporte de cierre es obligatorio al terminar cada archivo temático, no un permiso para tomar trabajo ajeno.
7. Antes de cada tarea y al terminar el backlog, releer el canal. El director puede cambiar prioridad, suspender tareas o solicitar un bloque específico.

## 6. Criterio mínimo de cierre por sub-backlog

Un reporte de cierre debe indicar:

- Archivo temático y rango de IDs atendidos; conteo de completadas, pendientes, duplicadas/obsoletas y `[?]`.
- Alcance inspeccionado y referencias exactas; comandos/tests ejecutados y salidas/códigos cuando aplique.
- Confirmación de que no se cambió un módulo bloqueado, fuente canónica o archivo de otro agente.
- Validación UTF-8 sin BOM y revisión de formato/diff en los archivos propios cuando hubo edición.
- Qué falta, qué quedó bloqueado y qué decisión/permiso sería necesaria.
- Mensaje formal al director en el canal propio, con formato y número autorizados por el protocolo. No declarar “reportado” si el mensaje no pudo crearse.

## 7. Límites permanentes

- No reservar ni modificar módulos, no asumir una línea `Recom`, no cambiar estados/checklists/firmas de terceros y no crear tareas en `5-FUTURAS-MEJORAS.md` (reservado a directivas del usuario).
- No crear archivos fuera de esta carpeta de tareas y del canal propio salvo que un encargo lo pida.
- No ejecutar scripts del proyecto sin conocer su efecto y cumplir reglas de seguridad/proyecto.
- No incluir claves, credenciales, tokens ni datos personales en JSON, muestras o reportes.
- No hacer commits, push, backups ni cambios de gran alcance sin solicitud expresa.
- Si una actividad requiere acceso, permiso, decisión de dueño o ejecución de herramienta no disponible: dejarla pendiente/`[?]` con causa; no sortear restricciones.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
