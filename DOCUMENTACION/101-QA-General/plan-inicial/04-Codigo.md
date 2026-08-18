**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 101: QA General

## 1. Carácter del Componente

Módulo de **proceso y herramientas de QA manual**: checklists por área, plantillas de sesión, guías de regresión/smoke/release y puente con playtesting. El motor es Godot 4.x, el lenguaje es GDScript. El módulo NO introduce código runtime del juego: sus entregables son plantillas y guías Markdown que los agentes/tester completan durante las sesiones, más el uso read-only del debug menu de M110 como acelerador. Todo lo listado a continuación está **previsto** y marcado como **Pendiente de implementación** — este documento es la especificación para el agente implementador.

**06-Plan-Testings.md / 07-Resultados-Testings.md:** NO se incluyen para este módulo en su entrega inicial (módulo de proceso, sin código runtime); el checklist del módulo SÍ incluye una sección de testings con la validación de las plantillas en una sesión ficticia.

## 2. Archivos previstos (Pendiente de implementación)

```
DOCUMENTACION/101-QA-General/plan-actual/
├── QA-CHECKLIST.md                → Checklist maestro de QA por área (27 áreas, ítems verificables). PENDIENTE DE IMPLEMENTACIÓN
├── QA-SESSION.md                  → Plantilla de sesión de QA obligatoria (cabecera, resultados, bugs, conclusión, métricas). PENDIENTE DE IMPLEMENTACIÓN
├── QA-SMOKE.md                    → Guía de smoke test por build (< 15 min, 7 pasos: arranque, menú, mundo nuevo, movimiento/interacción, recolectar, guardar/cargar, debug menu). PENDIENTE DE IMPLEMENTACIÓN
├── QA-REGRESION.md                → Guía de regresión por dependencias (cuándo, qué áreas, cómo convertir a M112). PENDIENTE DE IMPLEMENTACIÓN
├── QA-RELEASE-CRITERIA.md         → DoD de QA por build/hito (7 puntos, severidades bloqueantes). PENDIENTE DE IMPLEMENTACIÓN
├── QA-PLAYTEST-BRIDGE.md          → Coordinación con M114 (reglas EA.1/EA.2, flujo de hallazgos). PENDIENTE DE IMPLEMENTACIÓN
├── guia-para-agentes.md           → Guía de verificación post-tarea para el protocolo multiagente (sección 12/21 AGENTS.md). PENDIENTE DE IMPLEMENTACIÓN
└── sesiones/
    └── M137-PROTOTIPO/            → Resultados de sesiones reales (una carpeta por hito; se crean al ejecutar QA). PENDIENTE DE IMPLEMENTACIÓN
```

**Plantilla de issue de bug:** NO se crea aquí (pertenece a M102, ya documentada por Devin). El flujo solo la referencia.

## 3. Ejemplos de entrada (plantillas base)

> Contenido base que implementará el agente en los archivos del punto 2. Los ejemplos siguientes son la especificación mínima.

### 3.1 Fragmento del checklist maestro por área (QA-CHECKLIST.md)

```markdown
# QA-CHECKLIST.md — Checklist Maestro de QA por Área (Módulo 101)

**Modelo:** [agente que actualiza]
**Plataforma:** [plataforma]
**Última actualización:** YYYY-MM-DD

## Área 6 — Inventario (M14)
- [ ] Con inventario vacío, al recolectar un objeto se abre el slot 0 con el item correcto
- [ ] Con 30 slots llenos, al recolectar se muestra el aviso de inventario lleno y el item NO se pierde
- [ ] Al hacer click derecho en un stack de item_madera x5 se separa correctamente (si aplica)
- [ ] Al soltar items en el suelo, aparecen como recolectables y se vuelven a tomar
- [ ] Al vender un item en la tienda, el dinero aumenta y el item desaparece del stack
- [ ] Edge: se intenta usar un item con id inválido (id="" ) y no crashea (log M103 sin error)
- [ ] Edge: se cargan datos de guardado con inventario corrupto y el juego recupera/ignora con log
```

### 3.2 Plantilla de sesión (QA-SESSION.md)

```markdown
**Sesión QA #01 — Hito M137 (Prototipo)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** commit abc1234 — 0.1.0-dev
**Tester:** Deepseek V4 Flash / OpenCode
**Semilla del mundo (M10):** 42
**Versión Godot:** 4.4.1
**Áreas cubiertas:** 1 (Mundo voxel), 3 (Jugador), 5 (Herramientas), 6 (Inventario)
**Smoke test (QA-SMOKE.md):** Aprobado

## Resultados por ítem
| ID | Área | Resultado | Bug (issue M102) | Notas |
|----|------|-----------|------------------|-------|
| 1.01 | Mundo | [x] | — | Generación sin errores en consola |
| 3.02 | Jugador | [x] | — | Movimiento fluido; sin atascos |
| 5.01 | Herramientas | [ ] | #12 (Alta) | Pico no extrae roca en altura Y>100 |

## Bugs encontrados
| Issue | Severidad | Categoría | Reproducible | Estado |
|-------|-----------|-----------|--------------|--------|
| #12 | Alta | Herramientas | Sí (2/2 intentos) | Abierto |

## Conclusión
- DoD de QA del hito: NO CUMPLE (1 bug alto abierto en área 5)
- Bloqueos para el siguiente hito: fix de #12 y re-sesión del área 5
- Métricas: 3 áreas cubiertas, 1 bug reportado, 1 regresión convertida a M112 (#13)
```

### 3.3 Guía de smoke test (QA-SMOKE.md) — pasos base

```
1. Arrancar la build → sin errores en consola al llegar al menú principal (M103 vacío de errores)
2. Menú principal: navegación y botones responden; se abre y cierra configuración
3. Partida nueva con semilla fija (M10) → el mundo genera sin excepciones en < N segundos
4. El jugador se mueve (wasd), salta, agacha y rota cámara sin clipping en terreno
5. Con la herramienta inicial: extraer 1 bloque y colocarlo → correcto (log sin warnings)
6. Guardar partida → cargarla → el estado (posición + inventario) es idéntico
7. Debug menu (M110) abre con F1/Backtick y el teletransporte funciona a 3 coordenadas
→ Si alguno falla: build rechazada, issue M102 de bloqueo, NO correr QA completo
```

### 3.4 Criterios de release (QA-RELEASE-CRITERIA.md) — puntos base

```
1. Smoke test aprobado sobre la build exacta
2. Checklists de áreas del hito 100% [x] (sin [?]; sección 21.2 AGENTS.md)
3. 0 bugs críticos abiertos; altos con dueño y fecha
4. Suite M112 en verde sobre la misma build
5. Sesión documentada (QA-SESSION.md) con firma
6. Flujos estables (sección 16 AGENTS.md) sin regresión
7. (M141/M142) Crash rate 0 (M122) + backlog documentado + release notes
```

### 3.5 Guía de regresión (QA-REGRESION.md) — reglas base

```
- Al modificar módulo X → correr el checklist del área X + checklists de los módulos
  dependientes (columna Dependencias del CHECKLIST-GLOBAL)
- Todo bug de regresión reproducible → issue M102 etiqueta "regresion" + orden de
  conversión a test automático en M112 (RF10 del módulo 101)
- Flujos estables verificados (sección 16 AGENTS.md) → siempre en la regresión de hito
- Los checks de regresión NUNCA se saltean por tiempo; se prioriza sobre features nuevas
```

## 4. Comandos de referencia (uso en sesiones)

```
# Build de QA (local, Godot 4.x + Voxel Tools)
godot --path . --export-release "Windows Desktop" builds/qa/IslaAncestral.exe

# Verificación headless de la suite automática (M112) antes de la sesión
godot --headless --path . --script res://tests/run_tests.gd -gexit

# Logger (M103) — dónde mirar salida de la sesión (fuera de Assets)
# (la ruta exacta se define en M103; el smoke test verifica que esté vacío de errores)

# Estando en el juego: debug menu (M110) con F1/Backtick; exportar diagnóstico
# para adjuntar en issues M102 (función RF20 del módulo 110)
```

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice

- Creé los 5 archivos de documentación del módulo 101-QA-General (plan-inicial) siguiendo el estándar del proyecto (firma, RF/RN, análisis, diseño, checklist de 125+ ítems completados) y copié plan-actual idéntico.
- Definí el problema, objetivo, alcance y restricciones del QA manual alineados con Godot 4.x + GDScript (sin mencionar Unity) y con el protocolo multiagente (secciones 12, 16 y 21 del AGENTS.md).
- Analicé el dominio de QA: tipos de QA (exploratorio, guiado, regresión, smoke, playtesting, automatizado), construcción de ítems verificables, sesiones por hito M137-M141 con madurez creciente, relación híbrida con M112 y DoD de QA por build/hito.
- Diseñé la estructura del módulo: checklist maestro por área (27 áreas mapeadas a los módulos del CHECKLIST-GLOBAL), plantilla de sesión única, criterios de release, flujos por cambio/build/hito y puente con M114 (playtesting) y M102 (bug tracking).
- Enlacé el reporte de bugs con M102 (plantilla oficial, severidades, evidencias con M103/M110/M122) sin redefinir lo que M102 ya documentó, y con la regla de conversión de regresiones a M112.
- Redacté ejemplos base de las plantillas (QA-CHECKLIST, QA-SESSION, QA-SMOKE, QA-REGRESION, QA-RELEASE-CRITERIA) y comandos de referencia de Godot.
- Completé el 05-Checklist.md del módulo con ítems `- [x]` (todos completados como documentación) cubriendo RF, RN, análisis, diseño, integraciones, edge cases, documentación y testings, sin líneas de leyenda ni totales.

### Lo que NO pude hacer (honestidad obligatoria)

- **La ejecución real de QA depende del prototipo:** no hay build jugable aún (módulos sin implementar), así que las plantillas no se probaron en una sesión real; su validación queda para cuando exista el primer prototipo (M137).
- No actualicé la fila del módulo 101 en CHECKLIST-GLOBAL.md (regla estricta de la tarea: prohibido tocar archivos fuera de `DOCUMENTACION/101-QA-General/`). El próximo agente debe reflejar el progreso de este módulo allí (0/125 → progreso real).
- No implementé los archivos de plantillas del punto 2 (QA-CHECKLIST.md, QA-SESSION.md, etc.): están marcados como Pendiente de implementación.
- No definí los criterios exactos de severidad/categorías de M102 (ya los definió Devin en ese módulo; aquí solo se referencian).
- No configuré integraciones técnicas con M110/M112/M122 más allá del contrato documental, porque la implementación de esos módulos aún no existe en código.

### Recomendaciones para el próximo agente

- Al implementar: crear primero `QA-CHECKLIST.md` con las 27 áreas del diseño (sección 2 de 03-Diseno.md) y después `QA-SMOKE.md` (es el filtro más barato y habilita todo lo demás).
- Probar las plantillas en una sesión ficticia sobre el editor de Godot 4.x (sin build exportada): arrancar el proyecto, abrir una escena de test y completar un QA-SESSION.md de ejemplo antes de la primera sesión real.
- Actualizar CHECKLIST-GLOBAL.md (fila 101) con el progreso real y el estado `🟢 Disponible`/`🔵 En curso` cuando se implementen los archivos de plantillas, siguiendo el flujo de la sección 21.3 del AGENTS.md.
- Al existir el prototipo M137: ejecutar el primer QA-SMOKE.md real y crear la carpeta `sesiones/M137-PROTOTIPO/` con el resultado firmado.
- Verificar que los ítems del QA-CHECKLIST.md usen el patrón "acción → resultado esperado" y el modo verificable por logs (M103) además de visual, para que los agentes sin visión no queden bloqueados.
- Coordinar con el dueño de M112: al primer bug de regresión reproducible, convertir el caso en test automático y etiquetar el issue M102 con `regresion`.
- Después de implementar, actualizar el 05-Checklist.md marcando los ítems reales y escribir el log en `Logs/` con la firma del modelo.