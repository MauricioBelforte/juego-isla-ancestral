# Reglas Globales para la IA — Proyecto Unity (Isla Ancestral)

## 1. Idioma
- Todas las comunicaciones deben realizarse **estrictamente en español**.

## 2. Verificación inicial en proyectos
Antes de ejecutar cualquier tarea en un repositorio o proyecto:
1. Verificar siempre si existe un archivo `AGENTS.md` en la **raíz del proyecto**.
2. Si existe, leerlo completo y **priorizar sus instrucciones** sobre cualquier regla global.

## 3. Estructura de Documentación del Proyecto

La documentación vive dentro de `DOCUMENTACION/`. La raíz del proyecto solo contiene `AGENTS.md`, `README.md`, `CHECKLIST-GLOBAL.md`, y configuraciones generales.

### CHECKLIST-GLOBAL.md — Orquestador Multiagente (raíz del proyecto)

La **`CHECKLIST-GLOBAL.md`** es el archivo coordinador central del protocolo multiagente. Contiene la **tabla resumen de todos los módulos** del proyecto (una fila por módulo) y es la única fuente de verdad sobre el estado global de cada uno. Ver sección 21 para la especificación completa.

### DOCUMENTACION/ — Raíz de la carpeta (documentación general vigente)

En la raíz de `DOCUMENTACION/` están los 5 documentos generales que reflejan el estado actual del sistema y deben ser consultados/modificados durante el desarrollo:

| Archivo | Contenido |
|---------|-----------|
| `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` | Especificaciones técnicas vigentes |
| `2-DOCUMENTO-DISENO-ACTUAL.md` | Diseño detallado vigente |
| `3-DOCUMENTO-TAREAS-ACTUAL.md` | Checklist de tareas con estado actual |
| `4-DOCUMENTO-EJECUCION-ACTUAL.md` | Código de ejecución vigente |
| `5-FUTURAS-MEJORAS.md` | Checklist de ideas y mejoras pendientes del usuario (directivas propias, no propuestas del agente) |

### DOCUMENTACION/00-PLAN-INICIAL/ — Solo el origen del proyecto

Esta carpeta contiene la documentación original del proyecto. **No refleja el estado actual del código.** Solo debe consultarse como referencia histórica. ⚠️ No debe modificarse.

### DOCUMENTACION/ — Documentación por Componentes

Cada componente agregado al sistema se documenta en una subcarpeta que usa **el ID del módulo** como prefijo: `{ID-Módulo}-{Nombre}` (ej: `102-Bug-Tracking`). El ID se toma de `CHECKLIST-GLOBAL.md` (fuente de verdad). Si un módulo es nuevo y no existe en la tabla, se usa el **siguiente ID libre en orden** y se agrega a la tabla. **Cada componente tiene DOS carpetas obligatorias:**

```
DOCUMENTACION/
├── README.md                          ← Explicación del sistema de carpetas
├── 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md
├── 2-DOCUMENTO-DISENO-ACTUAL.md
├── 3-DOCUMENTO-TAREAS-ACTUAL.md
├── 4-DOCUMENTO-EJECUCION-ACTUAL.md
├── 5-FUTURAS-MEJORAS.md               ← Ideas y mejoras pendientes del usuario
├── 00-PLAN-INICIAL/                   ← Solo origen del proyecto (no modificar)
├── {ID-Módulo}-Nombre-Componente/      ← Prefijo = ID del módulo según CHECKLIST-GLOBAL (ej: 102-Bug-Tracking)
│   ├── plan-inicial/                  ← Documentación original del componente (NO MODIFICAR)
│   │   ├── 01-Requerimientos.md
│   │   ├── 02-Analisis.md
│   │   ├── 03-Diseno.md
│   │   ├── 04-Codigo.md
│   │   ├── 05-Checklist.md
│   │   ├── 06-Plan-Testings.md
│   │   └── 07-Resultados-Testings.md
│   └── plan-actual/                   ← Documentación vigente del componente (ACTUALIZAR AQUÍ)
│       ├── 01-Requerimientos.md
│       ├── 02-Analisis.md
│       ├── 03-Diseno.md
│       ├── 04-Codigo.md
│       ├── 05-Checklist.md
│       ├── 06-Plan-Testings.md
│       └── 07-Resultados-Testings.md
├── 30-Reloj-En-Tiempo-Real/           ← Ejemplo real: prefijo 30 = ID del módulo
│   ├── plan-inicial/
│   └── plan-actual/
└── 102-Bug-Tracking/                  ← Ejemplo real: prefijo 102 = ID del módulo
    ├── plan-inicial/
    └── plan-actual/
```

### Archivos Obligatorios por Carpeta (plan-inicial y plan-actual)

Cada carpeta debe contener **como mínimo los 5 archivos principales**. Los 2 archivos de testing son **opcionales** y se incluyen cuando el módulo lo amerita (sistemas complejos, integraciones críticas, gameplay core).

**5 Archivos Principales (OBLIGATORIOS):**

| Archivo | Contenido |
|---------|-----------|
| `01-Requerimientos.md` | Problema, objetivos, alcance, restricciones |
| `02-Analisis.md` | Análisis del dominio, alternativas, decisiones |
| `03-Diseno.md` | Arquitectura, diagramas, flujos |
| `04-Codigo.md` | Archivos involucrados, funciones clave, logs relacionados |
| `05-Checklist.md` | Checklist de tareas completadas y pendientes del componente (**mínimo 100 ítems**, ver regla abajo) |

**2 Archivos de Testing (OPCIONALES según complejidad del módulo):**

| Archivo | Contenido |
|---------|-----------|
| `06-Plan-Testings.md` | Plan de testings profesional para identificar bugs y fallos antes de la primera prueba manual |
| `07-Resultados-Testings.md` | Resultados detallados de la ejecución de tests con referencias al código y soluciones propuestas |

### Regla del Checklist Mínimo de 100 Ítems

El archivo `05-Checklist.md` de cada módulo debe contener **no menos de 100 ítems** a cumplir. Esta regla aplica tanto para `plan-inicial/` como para `plan-actual/`.

**¿De dónde sacar las ideas para los ítems?**

1. **Fuentes primarias obligatorias:** Los archivos de referencia del proyecto:
   - `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` — Checklist maestro de 600+ puntos de control
   - `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` — Plan de producción con desglose técnico por disciplina
2. **Pensamiento propio del agente:** El agente tiene libertad y responsabilidad de **pensar, imaginar y proponer** ítems adicionales que contribuyan al buen funcionamiento del juego, siempre que estén alineados con la visión del proyecto.
3. **Granularidad:** Los ítems deben ser lo suficientemente específicos para ser verificables (no genéricos como "hacer el sistema", sino "implementar detección de colisión del jugador con objetos interactuables").
4. **Cobertura:** Los 100+ ítems deben cubrir: implementación, integración con otros sistemas, edge cases, optimización, documentación y polish.

> **Nota:** Al crear la documentación de un módulo nuevo, la solicitud se refiere **como mínimo** a los 5 archivos principales del `plan-inicial/`. Los 2 archivos de testing se agregan si el módulo lo amerita.


### Reglas de Actualización por Componente

**plan-inicial/**:
- **NO MODIFICAR NUNCA**. Contiene la documentación original del componente tal como fue concebido inicialmente.
- Sirve como referencia histórica para entender el diseño original y compararlo con el estado actual.

**plan-actual/**:
- **ACTUALIZAR AQUÍ** cuando se realicen cambios en el componente.
- Refleja el estado actual del código y la implementación.
- Si se modifica un componente existente, actualizar los archivos en `plan-actual/`.
- Los cambios deben documentarse en `Logs/` con el formato estándar.

### Reglas de Actualización General
- Al realizar cambios significativos en el código, actualizar los 4 archivos `*-ACTUAL.md` en la raíz de `DOCUMENTACION/`.
- No modificar los archivos dentro de `DOCUMENTACION/00-PLAN-INICIAL/` (raíz).
- Si se requiere crear una nueva funcionalidad, agregarla al `3-DOCUMENTO-TAREAS-ACTUAL.md`.
- **Cuando se agregue un componente nuevo**, ver la sección 11.

### DOCUMENTACION/5-FUTURAS-MEJORAS.md — Anotador de Ideas del Usuario

Este archivo es un **anotador de ideas del usuario**. Su función es:

- **Solo directivas del usuario:** Contiene únicamente ideas, mejoras y directivas que el usuario le comunica al agente. **NO** deben agregarse propuestas generadas por el agente.
- **Checklist por prioridad:** Las ideas se organizan en tres niveles de prioridad: Alta 🔴, Media 🟡 y Baja 🟢.
- **Registro de fecha:** Cada entrada registra la fecha en que fue creada.
- **Actualización:** Cuando el usuario indique una nueva idea o mejora, el agente debe plasmarla en este archivo bajo la prioridad correspondiente.
- **Marcado de completado:** Cuando una idea se implemente, se marca `[ ]` → `[x]`.
- **No es un plan de tareas:** No reemplaza al `3-DOCUMENTO-TAREAS-ACTUAL.md`; es un registro de intenciones y mejoras futuras que el usuario quiere tener presentes.

### Firma de Documentación (Modelo y Plataforma)

Toda documentación generada o modificada por un agente debe incluir al inicio una **firma** indicando el modelo y la plataforma que la realizó. Esto permite identificar quién trabajó en cada archivo y mantener trazabilidad.

**Formato de firma:**
```
**Modelo:** [Nombre del modelo]
**Plataforma:** [Nombre de la plataforma]
```

**Ejemplos:**
- `**Modelo:** Claude` / `**Plataforma:** Antigravity`
- `**Modelo:** Deepseek V4 Flash` / `**Plataforma:** Openrouter`
- `**Modelo:** Deepseek V4 Flash` / `**Plataforma:** Cline`

**Reglas de aplicación:**

1. **Planes iniciales (`plan-inicial/`):** Deben firmar el agente que los creó. Esta firma es permanente y no se modifica.
2. **Planes actuales (`plan-actual/`):** Deben firmar el **último agente que los modificó**. Si un agente actualiza un plan actual, debe reemplazar la firma anterior por la suya.
3. **Logs (`Logs/`):** Deben firmar el agente que generó el log.
4. **Documentos generales (`*-ACTUAL.md`):** Deben firmar el último agente que los modificó.
5. **Mensajes entre modelos:** Ya tienen su propio formato de firma definido en la sección 10.

## 4. Estándar de Commits y Protocolo de Push (Git)

### 4.1 Estilo de Commits
- **Idioma:** Español.
- **Tiempo verbal:** Pasado descriptivo (pasivo o impersonal). Ejemplo: "Se agregó el módulo de autenticación".

### 4.2 Protocolo de Push (Commits Completos y Detallados)

Cuando el usuario solicite explícitamente *"hace un push o subilo a github o similar"*, el Agente debe seguir el siguiente flujo de trabajo obligatorio:

1. **Verificar el último commit en el remoto:** Revisar el último commit subido (por ejemplo, mediante `git log origin/main -1` o la rama correspondiente).
2. **Revisar el historial de cambios locales, los logs:** Comparar el estado actual del repositorio local contra la última versión subida (por ejemplo, mediante `git diff --stat origin/main`).
3. **Analizar los cambios en detalle:** Examinar archivo por archivo los cambios realizados (por ejemplo, mediante `git diff origin/main`) para comprender el alcance completo de las modificaciones.
4. **Redactar un commit completo y estructurado:**
   - **Idioma:** Español, con tiempo verbal en pasado descriptivo (pasivo o impersonal).
   - **Título:** Un título descriptivo que resuma el cambio principal.
   - **Cuerpo (opcional):** Si hay múltiples cambios, incluir una lista con viñetas detallando cada modificación encontrada.
5. **Ejecutar el commit y push:** Una vez redactado el mensaje, agregar los archivos, realizar el commit y ejecutar el push, informando al usuario del resultado.

**Ejemplos de formato de commit:**
  ```
  Se actualizó la documentación de la Práctica 4

  - Se agregó la guía de estudio teórica de UART
  - Se corrigió el diagrama temporal del Ejercicio 1
  - Se eliminaron archivos binarios obsoletos del directorio
  ```

**Nota:** Durante el push, es posible que se muestren advertencias sobre la conversión de saltos de línea (LF a CRLF). Esto es normal en entornos Windows y no afecta la integridad de los archivos.

## 5. Respaldos ante Cambios Grandes
Antes de realizar modificaciones grandes (como refactorizar el proceso principal):
1. **Creación de Carpeta:** Verificar la existencia de `Obsoletos/` en la ubicación del archivo.
2. **Respaldo:** Guardar una copia con nomenclatura: `AAAA-MM-DD_HH-MM-SS_nombre_archivo.extension`.

## 6. Registro de Cambios (Logs)
Cada vez que finalices una tarea, genera un informe de cambios:

### 6.1 Protocolo de Numeración (OBLIGATORIO — previene duplicados)

> ⚠️ **Este protocolo debe seguirse EXACTAMENTE para evitar logs duplicados.**

1. **Leer `Logs/ULTIMO_NUMERO.txt`** → obtener el número actual (N).
2. **Calcular siguiente número:** N + 1.
3. **VERIFICAR que no exista** un archivo con ese número:
   ```
   Logs/{N+1}-*.md
   ```
   Si existe → incrementar hasta encontrar un número libre.
4. **ESCRIBIR el nuevo número** en `ULTIMO_NUMERO.txt` (solo el número, sin texto adicional).
5. **Crear el archivo de log** con el nombre: `NN-DESCRIPCION_BREVE_AAAA-MM-DD_HH-MM-SS.md`.
6. **Actualizar el header** del archivo con `# Log NN: Descripcion`.

### 6.2 Formato del Archivo

```
# Log NN: Descripcion breve

**Fecha:** YYYY-MM-DD
**Modelo:** [Nombre del modelo]
**Plataforma:** [Nombre de la plataforma]

## Resumen
[Que se hizo]

## Cambios Realizados
[Detalle]

## Archivos Modificados/Creados
[Lista]
```

### 6.3 Reglas de Seguridad

- **NUNCA** editar el número directamente sin verificar que no exista un archivo con ese número.
- **SIEMPRE** verificar la existencia del archivo antes de crearlo.
- Si dos agentes leen `ULTIMO_NUMERO.txt` al mismo tiempo, el segundo debe verificar y encontrar el número tomado → incrementar.
- **El número en ULTIMO_NUMERO.txt es el ÚLTIMO número usado**, no el próximo. Al leerlo, sumar 1.

## 7. Seguimiento de Progreso (Checklist)
Cada vez que completes una tarea:
1. Leer `DOCUMENTACION/3-DOCUMENTO-TAREAS-ACTUAL.md` (o el equivalente local).
2. Marcar como completado cambiando `[ ]` por `[x]`.

> **Para tareas masivas (múltiples módulos):** el seguimiento de estado global se realiza mediante **`CHECKLIST-GLOBAL.md`** (sección 21), que resume el progreso de todos los módulos. Los subitems detallados viven en el `05-Checklist.md` de cada módulo.

## 8. Progreso Visual Detallado (UX Obligatorio)
Toda tarea de larga duración (carga de assets, generación procedural, operaciones de red, build de escenas) **DEBE** mostrar progreso visual al jugador/usuario en la interfaz.
- **Pantallas de carga y barras de progreso:** Por ejemplo, mientras se cargan escenas, se generan terrenos o se descargan assets.
- **Mensajes de estado:** Textos descriptivos ("Cargando escena...", "Generando terreno...", "Sincronizando datos...").
- **Prevención de clicks rápidos:** Deshabilitar botones de acción y UI interactiva hasta que la carga/proceso subyacente esté 100% completo.

## 9. Modularidad y Desacoplamiento
- **Separación de Responsabilidades:** La lógica de gameplay, IA, sistemas de combate, generación procedural y operaciones de I/O debe estar separada de la capa de UI (Canvas/UI Toolkit).
- **Arquitectura por capas:** Los MonoBehaviours de UI solo deben llamar a funciones expuestas por managers/servicios (ScriptableObject-based, singletons o service locators). Usar patrones como MVC, MVP o ECS según la complejidad del sistema.
- **No acoplar** lógica de gameplay, persistencia o networking directamente en los scripts de UI.
- **Componentes reutilizables:** Preferir la composición de componentes sobre la herencia profunda. Usar interfaces (`IInteractable`, `IDamageable`, etc.) para definir contratos entre sistemas.

## 10. Protocolo de Comunicación entre Modelos de Lenguaje (Chat por Temas)

Cuando una tarea se bloquee o requiera colaboración entre modelos, usar estructura tipo chat con carpetas por tema.

### Estructura
```
Mensajes entre modelos/
├── ESTADO-PARALELO.md                     ← Coordinación (quién trabaja en qué)
├── tema-problema/                         ← Carpeta por TEMA a resolver
│   ├── 2026-07-04_05-59-00_1-DEEPSEEK-planteo.md
│   ├── 2026-07-04_18-00-00_2-GEMINI-analisis.md
│   ├── 2026-07-04_20-30-00_3-DEEPSEEK-prueba-solucion.md
│   └── documentacion-solucion/           ← Docs adicionales si la solución es extensa
│       └── diagrama-propuesta.md
```

### Reglas
1. **Carpeta por tema:** Cada problema/feature tiene su propia carpeta dentro de `Mensajes entre modelos/`.
2. **Mensajes tipo chat:** Archivos con formato:
   - `YYYY-MM-DD_HH-MM-SS_N-MODELO-descripcion-breve.md`
   - `N` = número secuencial del mensaje en ese hilo
   - `MODELO` = quien escribe (DeepSeek, Gemini, Claude, etc.)
3. **Fecha y hora:** Usar timestamp real en el nombre del archivo.
4. **Firma en el contenido:** Incluir al inicio del archivo:
   ```markdown
   **Modelo:** DeepSeek
   **Fecha:** 2026-07-04 18:00:00
   **Responde a:** `2026-07-04_05-59-00_1-DEEPSEEK-planteo.md`
   ```
5. **Documentación adjunta:** Si una solución requiere documentos extensos, crear una subcarpeta dentro del tema (ej: `documentacion-solucion/`).
6. **No eliminar mensajes anteriores:** El hilo completo debe conservarse para trazabilidad.
7. **ESTADO-PARALELO.md:** Mantener actualizado para saber qué modelo trabaja en cada tema.
8. **Carpetas enumeradas:** Las carpetas dentro de `Mensajes entre modelos/` usan prefijo numérico (`NN-`) para orden cronológico. Ejemplo: `01-Investigacion-FBNeo-GGPO/`, `02-Diseno-Arquitectura/`.
9. **Subcarpetas por agente (opcional):** Si múltiples agentes trabajan dentro del mismo tema, cada uno crea su propia subcarpeta dentro del tema para no pisar archivos. Ejemplo: `01-Investigacion-FBNeo-GGPO/1-DEEPSEEK-planteo/`, `01-Investigacion-FBNeo-GGPO/2-CLAUDE-respuesta/`. Si no hay riesgo de colisión (un solo archivo por agente), se puede prescindir de subcarpetas y usar el formato estándar de mensajes.


## 11. Documentación de Nuevos Componentes (DOCUMENTACION)
Al crear un nuevo componente o sistema del juego:
1. **Tomar el ID del módulo de `CHECKLIST-GLOBAL.md`** (fuente de verdad). Si el módulo es nuevo y no existe en la tabla, registrar el siguiente ID libre en orden y agregar la fila.
2. Crear carpeta `DOCUMENTACION/{ID-Módulo}-Nombre/`. ⚠️ **El prefijo SIEMPRE es el ID del módulo** (ej: `102-Bug-Tracking`, `29-Tiempo-Y-Calendario` **no** `30-Bug-Tracking` → el 30 es otro módulo). Queda prohibido usar numeración cronológica o por orden de creación.
3. Crear la carpeta `plan-inicial/` dentro del componente.
4. Crear los **5 archivos principales obligatorios** en `plan-inicial/`: `01-Requerimientos.md`, `02-Analisis.md`, `03-Diseno.md`, `04-Codigo.md`, `05-Checklist.md`.
   - **`05-Checklist.md` debe contener mínimo 100 ítems** (ver sección 3, "Regla del Checklist Mínimo").
   - Los 2 archivos de testing (`06-Plan-Testings.md`, `07-Resultados-Testings.md`) se agregan **solo si el módulo lo amerita** (sistemas complejos, gameplay core, integraciones críticas).
5. Consultar obligatoriamente `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` y `Plan-de-produccion.md` como fuente de ítems y contexto para los archivos del componente.
6. Crear la carpeta `plan-actual/` dentro del componente (vacía inicialmente).
7. Crear los archivos correspondientes en `plan-actual/` (pueden ser copia de plan-inicial al inicio).
8. Actualizar `DOCUMENTACION/README.md`.

## 12. Verificación y Diagnóstico Post-Tarea
Antes de dar una tarea por terminada:
1. **Verificar compilación:** Asegurarse de que el proyecto Unity compile sin errores (0 errors en la Console de Unity). Warnings deben documentarse si no se pueden resolver inmediatamente.
2. **Sin Errores en Consola:** Verificar que no haya excepciones en runtime (`NullReferenceException`, `MissingReferenceException`, etc.) al entrar en Play Mode.
3. **Flujo Completo:** Si modificaste sistemas críticos (gameplay, IA, generación de mundo, persistencia, networking), verificar localmente en Play Mode que funcionen correctamente antes de dar la tarea por terminada.
4. **Verificar en escenas relevantes:** Si el cambio afecta múltiples escenas, probar en cada una.

## 13. Flujo de Trabajo: Documentación Primero (Documentation-First)

Este es el **flujo de trabajo obligatorio**:

### Para tareas NUEVAS (nuevo componente):
1. **Antes de escribir código:** Crear la carpeta del componente en `DOCUMENTACION/` y sus 5 archivos.
2. Implementar la funcionalidad.
3. Verificar que todo funcione (ejecutar el proyecto).
4. Revisar los 5 archivos iniciales contra el código real y actualizar si hay diferencias.
5. Generar log en `Logs/`.

### Para tareas sobre MÓDULOS EXISTENTES (mejoras, bugfixes):
1. **Antes de escribir código:** Leer los archivos del componente en `DOCUMENTACION/` (o si no existe, usar el plan general).
2. Implementar la modificación.
3. Verificar que funcione.
4. Actualizar los archivos del módulo/documentación para reflejar el cambio.
5. Actualizar los `*-ACTUAL.md` de la raíz si el cambio es significativo (arquitectura, flujos principales).
6. Generar log en `Logs/`.

## 14. Plan de Testings Profesional para Nuevos Módulos

Antes de integrar un nuevo módulo al proyecto y realizar la primera prueba manual del usuario, se debe crear y ejecutar un plan de testings profesional para identificar bugs y fallos.

### Requisitos del Plan de Testings

1. **Tipos de pruebas a incluir:**
   - Pruebas unitarias de cada función/componente (Unity Test Framework — Edit Mode Tests)
   - Pruebas de integración entre sistemas (Unity Test Framework — Play Mode Tests)
   - Pruebas de casos límite (edge cases: valores nulos, listas vacías, condiciones de borde)
   - Pruebas de manejo de errores (excepciones, fallbacks, estados inválidos)
   - Pruebas de rendimiento si aplica (Profiler, frame budget, memory leaks, draw calls)

2. **Documentación del plan:**
   - Crear archivo `06-Plan-Testings.md` en la carpeta `plan-actual/` del componente
   - Listar todos los escenarios a probar
   - Definir criterios de éxito para cada prueba

3. **Ejecución obligatoria:**
   - Ejecutar todas las pruebas antes de notificar al usuario
   - Documentar resultados (pasaron/fallaron)
   - Corregir fallos encontrados antes de la primera prueba manual

4. **Actualización de checklist:**
   - Agregar items de testing en `05-Checklist.md`
   - Marcar como completado solo cuando todas las pruebas pasen

### Flujo de Testings

1. **Diseñar el plan:** Antes de implementar, definir qué se va a probar
2. **Implementar pruebas:** Crear tests automatizados cuando sea posible
3. **Ejecutar pruebas:** Correr el suite de tests completo
4. **Corregir fallos:** Solucionar bugs encontrados antes de la entrega
5. **Documentar resultados:** Registrar en `06-Plan-Testings.md` qué pruebas pasaron
6. **Notificar al usuario:** Solo cuando el plan de testings esté completado exitosamente

## 15. Modularización de Flujos Complejos

Cuando se desarrolle una funcionalidad nueva que comparta lógica con sistemas existentes que ya funcionan:

1. **Identificar el flujo nuevo vs existente:** Si el nuevo sistema tiene requisitos diferentes o puede necesitar cambios que afecten a sistemas que ya funcionan, se debe crear un script/manager/componente separado.
2. **No tocar lo que funciona:** Si un sistema ya funciona correctamente (ej: sistema de combate, movimiento del jugador, IA de NPCs), no modificarlo para agregar funcionalidad nueva. En su lugar:
   - Agregar **nuevos scripts/managers** para el nuevo flujo.
   - El nuevo script puede REUTILIZAR funciones auxiliares compartidas (utility classes, ScriptableObjects, interfaces) pero debe tener su propia lógica de orquestación.
   - Esto permite que el nuevo sistema pueda hacer cambios agresivos sin riesgo de romper los sistemas existentes.
3. **Documentar la decisión:** En los archivos del componente (`03-Diseno.md` o `04-Codigo.md`), explicar por qué se optó por un sistema separado y qué comparte con los sistemas existentes.

## 16. Flujos Bloqueados (Estables) — NO MODIFICAR

Estos flujos han sido verificados y no deben modificarse. Cualquier cambio debe hacerse en un flujo paralelo nuevo.

> **Nota:** Esta sección debe personalizarse por proyecto. Listar aquí los flujos/características que han sido verificados y deben permanecer estables.

| Flujo | Descripción | Componente | Arquitectura |
|-------|-------------|------------|-------------|
| [ ] | | | |

## 17. Trabajo en Paralelo entre Agentes

Cuando múltiples agentes trabajen simultáneamente en **tareas masivas**, el flujo principal es el **protocolo multiagente de `CHECKLIST-GLOBAL.md`** (sección 21). El sistema de chat por temas (sección 10) se usa para **comunicación puntual** entre agentes:

1. **Archivo de coordinación obligatorio**: `Mensajes entre modelos/ESTADO-PARALELO.md` + `CHECKLIST-GLOBAL.md` (sección 21).
2. **Leerlos siempre** antes de empezar cualquier tarea (antes de tocar código o archivos).
3. **Actualizarlos** al reclamar, iniciar, bloquear o completar una tarea.
4. **No modificar archivos** que otro agente tenga `🔵`/`🔴` (en curso) o `reclamado`/`en progreso`.
5. Cada entrada debe incluir: nombre de tarea, agente, archivos involucrados, estado, timestamp.
6. Los agentes se identifican con su nombre/modelo (ej: `Claude`, `GPT-4`, `Gemini`, `DeepSeek`).
7. **Usar carpetas por tema** para comunicación puntual (sección 10.1). Si dos agentes ocupan temas o módulos distintos → pueden trabajar en paralelo sin issues.
8. **UN módulo por agente a la vez** (regla de bloqueo de la sección 21.4).

## 18. Sistema de Rotación de Logs

El proyecto implementa un sistema automático de rotación de logs para evitar que los archivos crezcan indefinidamente.

### Estructura de Logs

```
Logs/
├── rotated/                          ← Logs rotados (históricos)
│   ├── 01-componente-2026-06-30.log
│   ├── 02-servicio-2026-10-03.log
│   └── 03-aplicacion-2026-10-03.log
├── aplicacion.log                    ← Log actual (siempre < tamaño máximo)
├── output.txt
└── ULTIMO_NUMERO.txt
```

### Implementación en Código (Unity/C#)

> **Nota:** En Unity, el logging en tiempo de ejecución usa `Debug.Log`, `Debug.LogWarning` y `Debug.LogError`. Para logging persistente en archivos, usar un sistema custom o una librería como `Unity.Logging`.

**Configuración:**
- `MAX_LOG_SIZE` - Umbral de rotación (ej: 500KB)
- `LOG_DIR` - Directorio de logs (fuera de `Assets/` para no disparar reimport)
- `LOG_ROTATED_DIR` - Directorio de logs rotados

**Función de rotación:**
- Verificar el tamaño del log actual después de cada write
- Si el tamaño >= umbral, renombrar el archivo a `logs/rotated/nombre-YYYY-MM-DD.log`
- Crear automáticamente un nuevo log vacío
- Registrar la rotación con mensaje `[LOG ROTATION]`

**Comportamiento:**
- Las carpetas de logs se crean automáticamente si no existen
- La rotación es transparente para el usuario
- Los logs rotados conservan la fecha en el nombre para trazabilidad
- En Unity, los logs de consola de runtime se capturan automáticamente en `Application.persistentDataPath` si se configura un custom logger

### Reglas para Nuevos Logs

Si necesitas agregar logging en el código:
1. **Usar el sistema de logging de Unity** (`Debug.Log()`, `Debug.LogWarning()`, `Debug.LogError()`) para mensajes de desarrollo
2. **Para logging persistente a archivo** (ej: analytics, crash reports), usar un sistema centralizado que escriba fuera de `Assets/`
3. **No crear archivos de log adicionales** dentro de `Assets/` — Unity los importa y genera .meta innecesarios
4. **Si necesitas un log separado** (ej: para un sistema específico como IA o networking):
   - Implementar rotación similar en el script del sistema
   - Usar el mismo formato de nomenclatura: `NN-nombre-YYYY-MM-DD.log`
   - Guardar en `logs/rotated/` cuando se rote

### Formato de Nomenclatura para Logs Rotados

**Formato:** `NN-nombre_log-YYYY-MM-DD.log`

**Ejemplos:**
- `01-gameplay-2026-06-30.log`
- `02-networking-2026-10-03.log`
- `03-ia-sistema-2026-10-03.log`

**NN** = Número secuencial (se incrementa automáticamente al mover logs existentes)

## 19. Archivo de Hilos de Chat Resueltos (RESUELTOS)

Cuando un problema analizado en `Mensajes entre modelos/` se considere **sustancialmente resuelto** (aunque pueda tener retoques pendientes):

1. **Crear carpeta `Mensajes entre modelos/RESUELTOS/`** si no existe.
2. **Mover la carpeta del tema** de `Mensajes entre modelos/` a `Mensajes entre modelos/RESUELTOS/`.
3. **Agregar prefijo numérico** al nombre de la carpeta para orden cronológico:
   ```
   Mensajes entre modelos/tema-problema/
   → Mensajes entre modelos/RESUELTOS/1-tema-problema/
   ```
4. **Mantener el historial intacto:** No se eliminan ni modifican los archivos del hilo.
5. **Se puede retomar después:** Si en el futuro se quiere mejorar o ajustar algo, se puede:
   - Volver a mover la carpeta de `RESUELTOS/` a `Mensajes entre modelos/`
   - Agregar nuevos archivos al hilo existente
   - O crear un hilo nuevo referenciando al anterior
6. **Actualizar `ESTADO-PARALELO.md`:** La tarea se mueve al historial de completadas con la fecha de archivo.

## 21. Protocolo Multiagente Orquestado (CHECKLIST-GLOBAL)

Este es el **protocolo central para tareas masivas** (ej: proyectos con decenas o cientos de módulos). Reemplaza el enfoque de "hacer todo en un solo hilo" por un **orquestador de trabajo en paralelo** donde múltiples modelos reclaman, trabajan y liberan módulos de forma ordenada y sincera.

### 21.1 Archivo Coordinador: CHECKLIST-GLOBAL.md

Ubicado en la **raíz del proyecto**. Es la **única fuente de verdad** sobre el estado global del proyecto. Su estructura es una **tabla resumen** con UNA fila por módulo (no contiene los subitems, esos viven en el `05-Checklist.md` de cada módulo):

| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |
|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|
| 01 | Autenticación | 🟢 Disponible | 0/100 | Alta | 3 | — | — | 2026-08-15 04:00 | — |
| 02 | Base de datos | 🔵 En curso | 45/100 | Alta | 5 | 01 | CLAUDE | 2026-08-15 04:10 | Avanzando normal |
| 03 | API REST | 🟡 Con dudas | 30/100 | Media | 4 | 01, 02 | — | 2026-08-15 03:00 | Ver plan-actual |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| 100 | Despliegue | ⬜ Sin iniciar | 0/50 | Baja | 2 | 03 | — | — | — |

**Alcance:**
- La tabla global solo resumen: **1 fila = 1 módulo**.
- Los **subitems** (hasta cientos por módulo) viven en `DOCUMENTACION/{NN}-Modulo/plan-actual/05-Checklist.md`.
- El progreso en la tabla global es la **cantidad de subitems completados** calculada del `05-Checklist.md` del módulo.
- **Prioridad:** Alta 🔴 / Media 🟡 / Baja 🟢.
- **Complejidad:** escala 1 (simple) a 5 (muy complejo). Ayuda al agente a elegir: modelos robustos toman complejidad 4-5, modelos rápidos toman 1-2.
- **Última actividad:** timestamp de la última modificación del módulo. Permite detectar `🔵`/`🔴` colgados (sin actividad por más de 24h → otro agente puede reclamarlo).
- **Definición de Completado (DoD):** un módulo se marca `✅` solo si TODOS sus subitems cumplen la Definición de Completado de la sección 21.6.

### 21.2 Simbología de Estados

| Estado | Significado |
|--------|-------------|
| `⬜` | Sin iniciar |
| `🟢` | Disponible (puede ser reclamado) |
| `🔵` | **En curso** (bloqueado por un agente, avanzando normal) |
| `🔴` | **En curso con riesgo** (bloqueado por un agente, posiblemente atascado; si no hay actividad en 24h otro agente puede reclamarlo) |
| `🟡` | **Con dudas** (bloqueado liberado con `?` pendientes, retomable) |
| `✅` | Completado (todos los subitems resueltos) |

En el `05-Checklist.md` de cada módulo:

| Símbolo | Significado |
|---------|-------------|
| `[ ]` | Pendiente |
| `[x]` | Completado |
| `[?]` | **No resuelto** (el agente fue honesto y no lo hizo "por hacer") |

**Estimación de esfuerzo por subitem** (opcional pero recomendada): cada ítem del `05-Checklist.md` puede llevar un marcador de esfuerzo al final de la línea:

| Marcador | Esfuerzo estimado |
|----------|-------------------|
| `[S]` | Simple (minutos) |
| `[M]` | Medio (horas) |
| `[C]` | Complejo (días) |

Ejemplo: `- [ ] Implementar handler de autenticación [C]` · `- [x] Crear esquema de base de datos [M]`

Esta estimación permite calcular el esfuerzo total por módulo y ayuda al agente a elegir módulos acordes a su capacidad de trabajo.

### 21.3 Flujo de Trabajo del Agente (Ciclo Completo)

1. **Leer `CHECKLIST-GLOBAL.md` y `Mensajes entre modelos/ESTADO-PARALELO.md`** antes de tocar nada.
2. **Escanear la tabla global** y autoevaluarse con **honestidad total**:
   - ¿Puedo hacer este módulo con calidad?
   - ¿Tengo las capacidades necesarias (visión, cálculo, dominio específico)?
   - Considerar la **complejidad** del módulo: ¿está acorde a mi capacidad? (modelos robustos → complejidad 4-5, modelos rápidos → 1-2)
   - Si NO soy el adecuado o no sé resolverlo → **NO tomarlo**. Buscar otro módulo o un `🟡` con dudas que sí pueda resolver.
3. **Si lo toma:**
   - `Estado` → `🔵 En curso` (usar `🔴 En curso con riesgo` si desde el inicio anticipa dificultades).
   - `Agente actual` → su nombre/modelo.
   - `Última actividad` → timestamp actual.
4. **Ir a `DOCUMENTACION/{NN}-Modulo/plan-actual/`** y leer TODO (especialmente las `## Notas del Agente` del anterior si el estado era `🟡`).
5. **Trabajar** el módulo: documentación primero, código, testings (secciones 13 y 14).
6. **Actualizar `05-Checklist.md` del módulo:**
   - `[ ]` → `[x]` en lo completado (solo si cumple la **Definición de Completado** de la sección 21.6).
   - Lo que no pudo resolver → `[?]` con una breve explicación al lado.
7. **Actualizar la tabla global:**
   - `Progreso` = n/total de subitems completados.
   - `Última actividad` → timestamp actual.
   - Si completó TODO → `Estado` = `✅`, `Agente actual` = `—`, y **firmar en `Notas`**: `✅ Completado por [MODELO]`.
   - Si dejó `[?]` pendientes → `Estado` = `🟡`, `Agente actual` = `—`.
8. **Escribir `## Notas del Agente`** al final del `04-Codigo.md` (o del archivo que corresponda) del plan-actual:
   ```markdown
   ## Notas del Agente

   **Modelo:** [Nombre]
   **Plataforma:** [Plataforma]
   **Fecha:** YYYY-MM-DD HH:MM:SS
   **Estado:** Completado | Parcial (con dudas)

   ### Lo que hice
   - ...

   ### Lo que NO pude hacer (honestidad obligatoria)
   - [item] → intenté X, Y, Z y no funcionó porque ...

   ### Intentos fallidos / decisiones
   - ...

   ### Recomendaciones para el próximo agente
   - [Qué probar a continuación, por dónde seguir, advertencias, ideas]
   ```
9. **Generar log** en `Logs/` (sección 6) y firmar los documentos que modificó.
10. **Si no pudo realizar NADA** del módulo: marcar en la tabla `Estado` → `🟢` (disponible de nuevo), no dejar `🔵`/`🔴` colgado. Dejar el `[?]` donde corresponda.
11. **Si el módulo quedó `✅`**, NO liberarlo como definitivo de inmediato: primero debe pasar por el **QA cruzado** de la sección 21.8.

### 21.4 Reglas de Bloqueo, Honestidad y Optimización

1. **UN módulo por agente** a la vez. Terminar o liberar antes de tomar otro.
2. **Nunca trabajar sobre un módulo `🔵` o `🔴`** (en curso por otro). Respetar el bloqueo.
3. **Ser honesto siempre:** un `[?]` es mejor que un `[x]` falso. No hacer "por hacer".
4. **Sincero al autoevaluarse:** si el módulo necesita visión y el modelo no tiene, NO tomarlo. Considerar la **complejidad** (1-5): no tomar un módulo de complejidad 5 si el modelo es rápido.
5. **Liberar el bloqueo** antes de terminar la sesión: `🔵`/`🔴` → `🟢`, `🟡` o `✅` siempre. Nunca dejar un `🔵`/`🔴` huérfano.
6. **No pisar archivos** que otro agente tenga `🔵`/`🔴` o reclamados en ESTADO-PARALELO.md.
7. **Detectar bloqueos colgados:** si un módulo lleva `🔵`/`🔴` sin actividad por más de 24h, otro agente puede reclamarlo (actualizando `Agente actual`, `Estado` y `Última actividad`).
8. **Prioridad absoluta: OPTIMIZACIÓN.** Este proyecto prioriza la calidad técnica sobre la velocidad de entrega. Las reglas son:
   - **No hacer por hacer.** Cada línea de código, cada mesh, cada textura, cada sistema debe estar bien hecho. No se aceptan polígonos mal optimizados, scripts sin considerar rendimiento, ni sistemas que "funcionan pero mal".
   - **Si no sabés optimizar, no lo hagas.** Si un agente no tiene el conocimiento para implementar un sistema con la calidad de optimización requerida (ej: LOD, culling, pooling, batching, compresión de texturas, frame budget), debe **dejar el módulo disponible** (`🟢`) para otro agente que sí pueda hacerlo bien.
   - **Buscar otra tarea.** Un agente que no puede optimizar un módulo correctamente debe elegir otro módulo acorde a sus capacidades en vez de entregar trabajo de baja calidad.
   - **Documentar limitaciones.** Si un agente intenta optimizar y encuentra que no puede alcanzar el estándar requerido, debe documentarlo honestamente en `[?]` con las razones técnicas y qué se intentó.

### 21.5 Ciclo de Continuidad (Retomar un Módulo con Dudas)

Cuando un agente ve un `🟡` (Con dudas) en la tabla global:

1. Bloquear el módulo (`🔵`) y registrarse como agente actual.
2. Ir al `plan-actual/` del módulo.
3. Leer **obligatoriamente** las `## Notas del Agente` para entender QUÉ se hizo y QUÉ falta (prestar especial atención a las **Recomendaciones para el próximo agente**).
4. Intentar resolver los `[?]`.
5. Si los resuelve todos → `✅`. Si no → dejar nuevos `[?]` con explicaciones actualizadas (nunca borrar las notas del agente anterior, agregar al historial).
6. Actualizar la tabla global y cerrar su ciclo.

### 21.6 Definición de Completado (DoD) y Finalización del Proyecto

**Definición de Completado (DoD):** un subitem solo se marca `[x]` cuando cumple TODOS estos criterios:

1. **Código implementado** y funcional (verificado según sección 12).
2. **Documentación actualizada**: `plan-actual/` refleja el estado real del código.
3. **Testings superados** (sección 14): ejecutados los tests correspondientes sin fallos.
4. **Log generado** en `Logs/` (sección 6).
5. **Firma del agente** en los documentos que modificó.

Un módulo solo se marca `✅` cuando **todos** sus subitems están `[x]` cumpliendo la DoD (ningún `[?]`). Además, debe haber pasado el **QA cruzado** de la sección 21.8. El proyecto se considera completo cuando **los 100 módulos** (o el total definido) estén `✅`.

### 21.7 Interacción con el Sistema de Mensajes (Sección 10)

- El protocolo de `CHECKLIST-GLOBAL.md` es el **flujo principal** para trabajo masivo.
- `Mensajes entre modelos/` se mantiene para **comunicación puntual** entre agentes (consultas, advertencias, dudas técnicas urgentes) que no requieren esperar a la revisión de documentos.
- Al actualizar `ESTADO-PARALELO.md`, reflejar también el estado del módulo en la `CHECKLIST-GLOBAL.md` (y viceversa) para mantener consistencia.

### 21.8 QA Cruzado (Verificación entre Modelos)

Cuando un módulo queda `✅ Completado por [MODELO]`, **NO se considera definitivo** hasta que un **segundo agente de otro modelo** realice la verificación:

1. **Reclamo de QA:** el verificador toma el módulo `✅` y lo marca `🔵 En QA` en la columna `Notas` (ej: `🔵 QA por [MODELO-VERIFICADOR]`).
2. **Revisión:** el verificador revisa:
   - Que la `05-Checklist.md` tenga TODOS los subitems `[x]` y ninguno `[?]`.
   - Que el código exista y cumpla la **DoD** (sección 21.6).
   - Que la documentación `plan-actual/` coincida con el código real.
   - Que existan los logs y las firmas.
   - Que el `07-Resultados-Testings.md` muestre los tests pasados.
3. **Resultado:**
   - **Si está OK** → el módulo permanece `✅`. En `Notas`: `✅ Verificado por [MODELO-VERIFICADOR] YYYY-MM-DD`.
   - **Si encuentra fallos** → el módulo vuelve a `🟡 Con dudas`, se documentan los hallazgos en las `## Notas del Agente` (agregando al historial, sin borrar) y queda para que el siguiente agente lo corrija.
4. **Regla de independencia:** el verificador debe ser un **modelo distinto** al que completó el módulo. Idealmente de otra plataforma (ej: si lo hizo Claude, que verifique DeepSeek o Gemini). Esto aprovecha que distintos modelos detectan errores distintos.

### 21.9 Herramientas de Automatización (Opcional)

Para proyectos muy grandes se recomienda crear scripts que automaticen el protocolo. Estos scripts son **herramientas de apoyo que ejecuta el agente manualmente** cuando lo necesita (no se ejecutan solos). Son opcionales: el protocolo funciona igual sin ellos, pero ayudan a ahorrar trabajo y evitar errores.

**¿Cuándo debe ejecutarlos el agente?**

1. **`scripts/generar_checklist_global.py`** — Generar/regenerar la tabla resumen:
   - **Al crear el proyecto o agregar un módulo nuevo** (después de crear los `05-Checklist.md`).
   - **Al finalizar un turno de trabajo** para reflejar el progreso real en `CHECKLIST-GLOBAL.md`.
   - Lee cada `DOCUMENTACION/{NN}-*/plan-actual/05-Checklist.md`, cuenta `[x]`/`[ ]`/`[?]` y reconstruye la tabla.
   - **Protecciones incluidas (NO pisa documentación):**
     - ✅ Crea **backup automático** en `scripts/backups/` antes de sobrescribir.
     - ✅ **Preserva columnas manuales** (Prioridad, Complejidad, Dependencias, Agente actual, Última actividad, Notas) si el módulo ya existía.
     - ✅ Solo recalcula `Estado` y `Progreso` (los verifica contra los `05-Checklist.md` reales).
     - ✅ No pisa la firma `✅ Verificado por` en Notas.
     - ✅ Respeto `🔵`/`🔴` en curso del estado previo.
   - **Modo simulación:** `python scripts/generar_checklist_global.py --dry-run` muestra qué cambios se aplicarían **sin escribir nada**.
   - Ejecución normal: `python scripts/generar_checklist_global.py`

2. **`scripts/verificar_checklist.py`** — Verificación de consistencia:
   - **Antes de empezar** a trabajar: confirmar que el estado global está sano.
   - **Al terminar un turno**: validar que las actualizaciones no rompieron la consistencia.
   - Detecta:
     - Que el `Progreso` declarado en `CHECKLIST-GLOBAL.md` coincida con el conteo real de `[x]` en el `05-Checklist.md`.
     - Módulos `🔵`/`🔴` sin actividad por más de 24h (colgados).
     - `[x]` en módulos cuyo estado global es `🟡`/`⬜` (inconsistencias).
     - `[?]` en módulos marcados `✅` (no deberían tener dudas).
     - Que exista la carpeta `Logs/` si hay `[x]` (requisito DoD de la sección 21.6).
   - Ejecución: `python scripts/verificar_checklist.py`
   - Parámetros: `--checklist RUTA` (otra ruta de la tabla) y `--horas-limite H` (umbral de colgado, default 24).

3. **`scripts/test_scripts.py`** — Suite de tests automatizados (obligatorio antes de tocar producción):
   - **Ejecutar SIEMPRE antes de usar los scripts en un proyecto real** (o al modificar cualquier script).
   - Valida las funciones críticas: conteo de checklists, normalización de columnas, inferencia de estados, preservación de columnas manuales, detección de colgados.
   - Detecta bugs de regresión (como el de normalización que perdía letras de columnas).
   - Ejecución: `python scripts/test_scripts.py`
   - Si algún test falla → **NO ejecutar los scripts en producción** hasta corregir.

> **Regla:** ejecutar `test_scripts.py` después de modificar cualquier script o antes de usarlos en un proyecto grande. Los scripts no reemplazan la honestidad del agente: un `[x]` materialmente incorrecto seguirá dependiendo de que el agente lo haya implementado bien.

## 22. Empaquetado y Distribución (Unity Build Pipeline)

Para generar el artefacto distribuible del proyecto:

### Plataformas objetivo
- **PC (Windows/Mac/Linux):** Build standalone desde `File > Build Settings` o vía script con `BuildPipeline.BuildPlayer()`.
- **Consolas (Switch/PS/Xbox):** Requiere SDK oficiales y licencias de plataforma. Build desde módulos de Unity específicos.
- **Mobile (iOS/Android):** Solo si se decide portar. Build desde los módulos correspondientes.

### Proceso de Build

```csharp
// Script de build automatizado (Assets/Editor/BuildScript.cs)
BuildPipeline.BuildPlayer(scenes, outputPath, BuildTarget.StandaloneWindows64, BuildOptions.None);
```

**Qué hace:**
1. Compilación de todos los scripts C# del proyecto
2. Empaquetado de assets (texturas, modelos, audio, prefabs, ScriptableObjects)
3. Generación del ejecutable y carpeta de datos (`.exe` + `_Data/` en Windows)
4. Aplicación de Addressables/AssetBundles si están configurados

**Output:** Carpeta `Builds/[Plataforma]/` en la raíz del proyecto (fuera de `Assets/`).

**Notas:**
- Verificar que las escenas estén agregadas en `Build Settings` antes de compilar.
- Los builds de desarrollo (`Development Build`) incluyen profiling y logs de consola.
- Los builds de release deben deshabilitar `Debug.Log` en producción (usar `#if UNITY_EDITOR` o Conditional attributes).
- Respetar la configuración de `Player Settings` (resolución, calidad, splash screen, etc.).
- Los assets de gran tamaño (terrenos, texturas 4K) deben usar compresión adecuada para la plataforma objetivo.

## 23. Instalación del Protocolo en un Proyecto Nuevo

Este archivo (`AGENTS.md`) junto con `CHECKLIST-GLOBAL.md` y la carpeta `scripts/` forman un **kit portable** que puede copiarse a la raíz de cualquier proyecto para activar el protocolo multiagente.

### Pasos de instalación

1. **Copiar el kit a la raíz del proyecto nuevo:**
   ```
   [proyecto-nuevo]/
   ├── AGENTS.md
   ├── CHECKLIST-GLOBAL.md
   └── scripts/
       ├── generar_checklist_global.py
       ├── verificar_checklist.py
       └── test_scripts.py
   ```

2. **Verificar que los scripts funcionan en el nuevo entorno:**
   ```
   python scripts/test_scripts.py
   ```
   → Debe mostrar `8 PASS, 0 FAIL`. Si algo falla, NO continuar hasta corregir.

3. **Crear la estructura de documentación del proyecto:**
   ```
   mkdir DOCUMENTACION
   ```
   (Las carpetas por módulo se crean automáticamente al aplicar la sección 11.)

4. **Personalizar `CHECKLIST-GLOBAL.md`:**
   - Reemplazar las filas de ejemplo (`Ejemplo-Modulo-1`, etc.) por los módulos reales del proyecto.
   - Completar `Prioridad`, `Complejidad` y `Dependencias` de cada módulo.
   - Actualizar la sección "Resumen del Proyecto" con el total real de módulos.

5. **Generar la tabla automáticamente (opcional):**
   - Si los módulos ya tienen `05-Checklist.md` creados, ejecutar:
     ```
     python scripts/generar_checklist_global.py --dry-run   # Simular primero
     python scripts/generar_checklist_global.py             # Escribir (con backup)
     ```

6. **Empezar a trabajar:**
   - Leer `CHECKLIST-GLOBAL.md` + `Mensajes entre modelos/ESTADO-PARALELO.md` (crear si no existe).
   - Escanear la tabla y elegir un módulo acorde a las capacidades propias (sección 21.3).
   - Bloquear, trabajar, documentar, firmar y liberar según el protocolo.

### Verificación de que el kit está sano

| Archivo | Requisito |
|---------|-----------|
| `AGENTS.md` | Contiene la sección 21 completa (21.1 a 21.9) y esta sección 23 |
| `CHECKLIST-GLOBAL.md` | Tabla con las 10 columnas (ID, Módulo, Estado, Progreso, Prioridad, Complejidad, Dependencias, Agente actual, Última actividad, Notas) |
| `scripts/test_scripts.py` | Ejecutable y muestra `8 PASS, 0 FAIL` |
| `scripts/backups/` | Carpeta creada (recibe los backups automáticos) |

> **Nota:** El kit es agnóstico al lenguaje/framework del proyecto. Los scripts de automatización (`scripts/`) son Python por portabilidad (no requieren Unity para ejecutarse). Los scripts de Unity Editor (`Assets/Editor/`) se escriben en C# y se ejecutan dentro del editor. Si se necesitan scripts de automatización adicionales dentro de Unity, deben ir en `Assets/Editor/` y no en la carpeta de runtime.

## 24. Stack Tecnológico del Proyecto

### Motor y Lenguaje
- **Motor:** Unity (versión LTS más reciente recomendada)
- **Lenguaje:** C# (.NET Standard 2.1 / .NET Framework según configuración de Unity)
- **IDE recomendado:** Visual Studio 2022 / Rider con integración Unity

### Arquitectura de Código
- **Patrones recomendados:** Composición sobre herencia, ScriptableObject Architecture, interfaces para contratos entre sistemas
- **Estructura de carpetas Unity:**
  ```
  Assets/
  ├── _Project/              ← Toda la lógica del juego
  │   ├── Scripts/
  │   │   ├── Core/          ← Managers, singletons, bootstrapping
  │   │   ├── Gameplay/      ← Mecánicas de juego, jugador, NPCs
  │   │   ├── AI/            ← Sistemas de IA, behavior trees, pathfinding
  │   │   ├── UI/            ← Scripts de interfaz de usuario
  │   │   ├── World/         ← Generación de mundo, biomas, terreno
  │   │   ├── Data/          ← ScriptableObjects, configuraciones
  │   │   ├── Audio/         ← Managers de audio, mixers
  │   │   ├── Networking/    ← Multijugador, sincronización (si aplica)
  │   │   └── Utils/         ← Utilidades, extensiones, helpers
  │   ├── Prefabs/
  │   ├── Materials/
  │   ├── Textures/
  │   ├── Models/
  │   ├── Animations/
  │   ├── Audio/
  │   ├── Scenes/
  │   ├── Shaders/
  │   └── ScriptableObjects/
  ├── Editor/                ← Scripts solo para el editor (build scripts, tools)
  ├── Plugins/               ← Paquetes de terceros
  └── StreamingAssets/       ← Datos que no se procesan por Unity
  ```

### Herramientas de Unity Relevantes
- **Input System:** New Input System (paquete oficial)
- **Rendering:** URP o HDRP según las necesidades gráficas del proyecto
- **Física:** PhysX integrado de Unity
- **UI:** UI Toolkit o Canvas/UGUI según la complejidad
- **Audio:** AudioMixer + ScriptableObject-based audio system
- **Testing:** Unity Test Framework (NUnit) para Edit Mode y Play Mode tests
- **Profiling:** Unity Profiler, Frame Debugger, Memory Profiler
- **Version Control:** Git + `.gitignore` específico para Unity (ignorar `Library/`, `Temp/`, `obj/`, etc.)

### Convenciones de Código C#
- **Namespaces:** `IslaAncestral.[Sistema]` (ej: `IslaAncestral.Gameplay`, `IslaAncestral.AI`, `IslaAncestral.UI`)
- **Nomenclatura:** PascalCase para clases, métodos y propiedades públicas. camelCase para variables locales y campos privados con prefijo `_` (ej: `_playerHealth`)
- **Comentarios:** Documentar con `///` (XML docs) las clases y métodos públicos
- **Regiones:** Usar `#region` con moderación, solo para agrupar secciones grandes
- **Serialización:** Usar `[SerializeField]` en vez de campos `public` cuando sea posible


## 25. Visión del Agente (M154) — Prerrequisito Fundamental para Trabajo Visual

> **Agregado:** 2026-08-22 · **Fuente:** directiva del usuario · **Módulo:** `DOCUMENTACION/154-Vision-Del-Agente/`

El **Módulo 154 (Visión del Agente)** es un **prerrequisito obligatorio** para cualquier tarea que involucre diseño o codificación visual del juego.

> 📖 **GUÍA MAESTRA DE CONEXIÓN (leer primero):** `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`
> Es el archivo de referencia de "los ojos" del proyecto: documenta TODAS las vías de visión, su estado operativo actualizado, y las instrucciones paso a paso para que cualquier agente de cualquier plataforma se conecte (instalación, conexión por sesión, ejemplos de código y checklist de verificación). **Todo agente que deba trabajar con visión debe leer ese archivo antes de empezar**, y debe actualizarlo al instalar o verificar una vía nueva.

### Regla de oro

> ⚠️ **Antes de comenzar a diseñar o codificar cualquier elemento visual** (personajes, escenas, UI, iluminación, efectos, assets 3D/2D), el agente DEBE verificar que el M154 esté **implementado y operativo**, con al menos una vía activa.

### Vías disponibles (detalle completo en el módulo)

| Vía | Mecanismo | Uso principal |
|---|---|---|
| V1 — Capturas en chat | Usuario pega screenshots; visión integrada | Validación estética final |
| V2 — MCP custom de pantalla | Python PIL/ImageGrab vía MCP | Fallback universal |
| V3 — Export web + Playwright | Godot HTML5 + skill webapp-testing | QA automatizado / regresión visual |
| V4 — godot-mcp ⭐ | MCP controla editor Godot | Verificación dentro del juego (**FUNDAMENTAL**) |
| V5 — Blender + blender-mcp ⭐ | bpy + viewport screenshot | Diseño/modelado de assets con visión |

### Obligaciones del agente

1. **Leer la guía maestra de conexión:** `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (estado de las vías + instrucciones de conexión de cada una).
2. Al reclamar un módulo visual, verificar en su `05-Checklist.md` el ítem de dependencia M154.
3. Si ninguna vía está operativa, solicitar al usuario la instalación correspondiente ANTES de proceder.
4. Durante el trabajo visual, seguir el protocolo de iteración del M154 (capturar → analizar → ajustar; máximo 5 iteraciones autónomas).
5. Los módulos visuales tienen en su checklist un ítem explícito de verificación M154 (agregado automáticamente el 2026-08-22).
6. Los nuevos módulos visuales que se creen a futuro deben incluir este ítem desde su creación.
7. Al instalar o verificar una vía nueva, **actualizar la guía maestra** (tabla de estado + sección de la vía + registro de verificación) y firmar el cambio.
