**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 101: QA General

## 1. Arquitectura General del QA

```
DOCUMENTACION/101-QA-General/
├── plan-inicial/                      ← Documentación original del componente (NO MODIFICAR)
│   ├── 01-Requerimientos.md
│   ├── 02-Analisis.md
│   ├── 03-Diseno.md
│   ├── 04-Codigo.md
│   └── 05-Checklist.md
└── plan-actual/                       ← Documentación vigente del componente (ACTUALIZAR AQUÍ)
    ├── 01-Requerimientos.md
    ├── 02-Analisis.md
    ├── 03-Diseno.md
    ├── 04-Codigo.md
    ├── 05-Checklist.md
    ├── QA-CHECKLIST.md                ← CHECKLIST MAESTRO DE QA POR ÁREA (Pendiente de implementación)
    ├── QA-SESSION.md                  ← PLANTILLA DE SESIÓN DE QA (Pendiente de implementación)
    ├── QA-SMOKE.md                    ← GUÍA DE SMOKE TEST POR BUILD (Pendiente de implementación)
    ├── QA-REGRESION.md                ← GUÍA DE REGRESIÓN POR DEPENDENCIAS (Pendiente de implementación)
    ├── QA-RELEASE-CRITERIA.md         ← CRITERIOS DE RELEASE / DoD DE QA (Pendiente de implementación)
    ├── QA-PLAYTEST-BRIDGE.md          ← COORDINACIÓN CON M114 (Pendiente de implementación)
    ├── sesiones/                      ← Resultados de sesiones reales (se crean al ejecutar QA)
    │   └── M137-PROTOTIPO/            ← Ej: una sesión por hito (Pendiente de implementación)
    └── guia-para-agentes.md           ← Guía de verificación post-tarea (sección 12 AGENTS.md)
```

**Principio rector:** el módulo 101 NO genera código runtime del juego. Sus entregables son **plantillas y guías Markdown** que cualquier agente o tester humano completa durante las sesiones. La única herramienta de código que usa es el debug menu de M110 (teletransporte, objetos, tiempo/clima) que acelera los ítems de QA. La fuente de verdad de bugs es M102 (GitHub Issues), nunca archivos del módulo.

## 2. Estructura del Checklist Maestro por Área (QA-CHECKLIST.md)

El checklist maestro se organiza por **área funcional del juego** (25+ áreas), cada una con sección propia de ítems verificables `- [ ] / - [x]` y un bloque de "estados de borde" específico. Áreas previstas (referenciando su módulo del CHECKLIST-GLOBAL):

| # | Área de QA | Módulos fuente | Ejemplos de ítems |
|---|---|---|---|
| 1 | Mundo voxel y terreno | M08, M09, M10 | Chunks se generan sin errores; fronteras de chunk sin costuras; semilla dev reproducible |
| 2 | Generación del mundo | M10, M63 | Regeneración con misma semilla da mismo mundo; streaming carga sin pops |
| 3 | Jugador y movimiento | M11 | FSM de estados sin transiciones rotas; hitbox 0.6x1.8 coherente; stamina informativa |
| 4 | Cámara | M12 | 5 modos sin clipeos; spring-arm con colisión; anti-mareo opcional |
| 5 | Herramientas | M13 | 9 herramientas x 4 niveles: extracción/colocación correctas; durabilidad cozy (nunca se rompen) |
| 6 | Inventario | M14 | 30 slots, stacking, quitar/agregar, límites, ids inválidos |
| 7 | Recursos | M15 | Obtención por herramienta correcta; rarezas y usos coherentes |
| 8 | Crafting | M16 | Recetas con requisitos; resultados con cantidades correctas; sin recetas arbitrarias |
| 9 | Construcción | M17, M18 | Validación de posición; casas habilitables; desmontaje correcto |
| 10 | NPC y vecinos | M19, M20 | Rutinas por perfil; amistad avanza; regalos correctos |
| 11 | Diálogos | M21, M22, M23 | Árboles sin loops; consecuencias persistentes; historia/side quests |
| 12 | Templos y puzzles | M24, M25, M26 | Emisor→receptor; 15 familias; validador de arbitrariedad; checkpoints del subtemplo |
| 13 | Islas y viajes | M27, M28, M69 | Restricciones de viaje; fast travel; desbloqueos por sello |
| 14 | Tiempo y calendario | M29, M30, M31 | Día de 24min; eventos por fecha; franjas ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA; anti-oscuridad |
| 15 | Clima | M32 | 9 climas deterministas; regla anti-molestia (bono sí, bloqueo no) |
| 16 | Actividades (agri/pesca/minería) | M33, M34, M35 | Ciclos completos; clima afecta cosechas; bancos de peces; vetas |
| 17 | Fauna y museos | M36, M37 | IA animal; migraciones; donación y colección |
| 18 | Economía | M38, M70 | Precios; compra/venta; interacciones correctas |
| 19 | Audio | M41-M44 | Música por contexto; ASMR; blacklist anti-agresión; feedback sincronizado |
| 20 | UI/UX | M53, M57, M88, M89 | Navegación de menús; prompts por dispositivo; fuentes; sin solapamientos |
| 21 | Accesibilidad | M58 | Tamaño de texto, contraste, daltonismo, tiempo de respuesta |
| 22 | Memoria y streaming | M61, M62, M63 | Sin acarreo; presupuesto de frame; pesos LRU; precalentamiento |
| 23 | IA (NPC y animales) | M64, M65 | FSM; burbuja de simulación; anti-atascos; rutinas |
| 24 | Anti-softlock | M66, M59 | Detector de invariantes; cofre de recuperación; guardado/carga |
| 25 | Tutorial y progresión | M92, M71 | Nace bien; logros; desbloques progresivos |
| 26 | Configuración | M90, M91 | Presets gráficos; audio 7 buses; persistencia de settings |
| 27 | Debug menu (herramienta) | M110 | Funciones RF1-RF20 operativas; off en release |

Cada ítem sigue el patrón: **acción concreta → resultado esperado verificable**. Ejemplo: "Con el pico nivel 1, al golpear un bloque de piedra en (x,z) se obtiene 1 roca y el bloque se destruye; se registra en el log M103 sin warnings".

## 3. Plantilla de Sesión (QA-SESSION.md)

Cabecera obligatoria de cada sesión:

```
**Sesión QA #NN — Hito M1XX**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** commit hash + versión (ej: 1.2.3-dev+abc1234)
**Tester:** Agente (Modelo/Plataforma) | Humano (nombre)
**Semilla del mundo (M10):**
**Versión Godot:** 4.x.y
**Áreas cubiertas:** [lista]
**Smoke test (QA-SMOKE.md):** Aprobado / Rechazado (si rechazado, la sesión termina aquí)

## Resultados por ítem
| ID ítem | Área | Resultado | Bug (issue M102) | Notas |
|---|---|---|---|---|

## Bugs encontrados
| Issue M102 | Severidad | Categoría | Reproducible | Estado |

## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE
- Lista de bloqueos para el siguiente hito
- Firma del tester
```

## 4. Reporte de Bugs (enlace M102)

Flujo de reporte (RF5):

1. El tester detecta un hallazgo → abre issue en GitHub con la **plantilla oficial de M102** (no se crean plantillas paralelas).
2. El issue incluye: título descriptivo, pasos de reproducción numerados, resultado esperado, resultado obtenido, build/commit, entorno (SO, GPU, versión Godot, semilla del mundo), evidencias (screenshot, video, extracto del log M103, diagnóstico exportado del debug menu M110, crash ID de M122 si aplica).
3. Severidad y categoría: valores definidos por M102 (crítica/alta/media/baja; categorías por sistema).
4. Si es bug de regresión → el issue lleva etiqueta `regresion` y se dispara la orden de convertir el caso a test automático M112 (RF10).
5. El dueño del módulo afectado (según CHECKLIST-GLOBAL) toma el issue; QA solo reporta y re-verifica el fix.

**Veredictos de severidad y release:**

| Severidad | Definición (M102) | Efecto en el hito |
|---|---|---|
| Crítica | Bloquea jugabilidad o corrompe datos | Frena el hito; fix obligatorio antes de avanzar |
| Alta | Funcionalidad rota con workaround molesto | Debe tener dueño y fix planificado en el mismo hito |
| Media | Impacto parcial / pulido negado | Backlog del hito siguiente |
| Baja | Cosmético / sugerencia | Backlog libre (puede ir a 5-FUTURAS-MEJORAS) |

## 5. Criterios de Release / DoD de QA (QA-RELEASE-CRITERIA.md)

Una build cumple el **DoD de QA** (RF7) si y solo si:

1. Smoke test aprobado (RF6) sobre esa build exacta.
2. Checklists de todas las áreas incluidas en el hito al 100% `[x]` (sin `[?]` — sección 21.2 AGENTS.md).
3. 0 bugs críticos abiertos; altos abiertos con dueño y fecha en el hito.
4. Suite de M112 en verde corriendo sobre la misma build (CI de M118 o local headless).
5. Sesión documentada en `sesiones/` con plantilla `QA-SESSION.md` y firma.
6. Verificación de no-regresión en flujos estables (sección 16 AGENTS.md) documentada.
7. Para M141 (Beta) y M142 (RC) además: crash rate cero en M122, backlog de bugs documentado, y release notes preliminares.

Sin el DoD de QA, la build NO avanza de hito (regla del protocolo multiagente, sección 21.6).

## 6. Flujos de Trabajo

### 6.1 Flujo por cambio (post-tarea de un agente)

```
Agente termina tarea en módulo X
  → Verificación post-tarea (sección 12 AGENTS.md): compila, sin excepciones, flujo manual
  → QA guiado: checklist del área X (QA-CHECKLIST.md) → correr ítems del área
  → Regresión ligera: módulos dependientes de X (columna Dependencias del CHECKLIST-GLOBAL)
  → Si bug → issue M102 (si regresión reproducible → etiqueta regresion + conversión M112)
  → Log en Logs/ + actualización del checklist del módulo afectado
```

### 6.2 Flujo por build

```
Build generada (M118 CI o manual)
  → QA-SMOKE.md (< 15 min) → ¿Aprobado?
      ├── NO → build rechazada; issues M102 de bloqueo; se informa al dueño; NO hay QA completo
      └── SÍ → QA completo por áreas del hito (QA-CHECKLIST.md)
                → Sesión QA-SESSION.md documentada + firma
                → Bugs → issues M102
                → ¿DoD de QA cumplido? → build pasa de hito (firma del QA en CHECKLIST-GLOBAL)
```

### 6.3 Flujo por hito (M137-M141)

```
Hito N-1 completo → git tag hito_N-1
  → QA: regresión completa de TODAS las áreas (no solo las del hito)
  → Sesiones exploratorias (QA manual libre, 1-2h) buscando no-cubiertos
  → Playtesting M114 (si el hito lo define): hallazgos → issues M102 → priorización
  → DoD de QA del hito → ¿cumple?
      ├── NO → iterar fixes; re-sesión de las áreas fallidas
      └── SÍ → marca del hito N; siguiente hito
```

### 6.4 Flujo de coordinación con M114 (Playtesting)

| Aspecto | QA interna (M101) | Playtesting (M114) |
|---|---|---|
| Quién | Agentes + tester interno | Jugadores externos |
| Qué busca | Bugs, regresiones, errores técnicos | Diversión, claridad, balance, frustración |
| Canal de hallazgos | Issues M102 con plantilla técnica | Cuestionario/captura de sesión de M114; lo técnico se convierte en issue M102 |
| Puente | Este módulo alimenta M114 con builds saneadas (smoke OK) | M114 devuelve señales de diseño que QA incorpora como ítems de área (ej: claridad del tutorial) |
| Regla | EA.1: una sesión de M114 nunca arranca sobre una build que falló el smoke de M101 | EA.2: los hallazgos de M114 sin repro técnico se re-checkean en la siguiente sesión de QA |

## 7. Métricas de Calidad (RF11)

Para informar a M133 (Gestión del Proyecto), cada hito reporta:

- Bugs totales reportados / abiertos / cerrados por severidad.
- Bugs por área (top áreas problemáticas).
- Tasa de regresión (bugs de regresión / total).
- Tiempo medio de sesión por área (para ajustar presupuestos de QA).
- % de ítems del checklist maestro completados por hito (progreso hacia el DoD).

Los datos salen de M102 (issues) y de las sesiones; el módulo 101 solo define el formato de resumen en `QA-SESSION.md` (bloque "Métricas").