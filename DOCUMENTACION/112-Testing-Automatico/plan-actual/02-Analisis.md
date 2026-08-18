**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 112: Testing Automático

## 1. Carácter del Componente

Módulo de **infraestructura de pruebas automatizadas** para Godot 4.x + GDScript. Es el puente entre el código de calidad definido por M111 y el pipeline de CI/CD de M118: sin una suite automatizada reproducible, el CI no puede decidir objetivamente si un commit es apto para merge o release.

## 2. Análisis del Dominio

### 2.1 Framework de testing: GUT vs GdUnit4

**Contexto:** Godot 4.x no trae framework de unit testing integrado (el ecosistema de Godot difiere del de Unity, donde el Unity Test Framework es oficial). Las dos opciones de la comunidad son GUT y GdUnit4. Ambos son addons instalables en `res://addons/` y usan GDScript.

#### GUT (Godot Unit Test)

| Criterio | Detalle |
|---|---|
| Idioma | Inglés; sintaxis `func test_x():` + aserciones `assert_eq()`, `assert_true()`, etc. |
| Runner headless | `godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` |
| Modo de trabajo | Descubre tests por convención `test_*.gd` en directorios |
| Cobertura | Soporta cobertura de línea con `--coverage` (v9.x) |
| Escenas | Permite instanciar escenas .tscn dentro de tests (`add_child_autofree()`, `add_child_autoqfree()`) |
| Madurez | Muy usado en la comunidad desde Godot 3; activo en Godot 4.x |
| Curva | Baja; similar a frameworks clásicos |

#### GdUnit4

| Criterio | Detalle |
|---|---|
| Idioma | Sintaxis con anotaciones `@is_test`/`@IsTest` y aserciones `assert_that()` (fluent API) |
| Runner headless | `godot --headless --script res://addons/gdUnit4/bin/gdUnit4cmd.gd -a --path .` |
| Modo de trabajo | Descubre tests por convención de nombre de archivo (`test_*.gd`) y directorio `test/` o `tests/` |
| Cobertura | Reportes de cobertura integrados |
| Extras | Reportes JUnit/XML (ideales para CI), watch mode, assertions richer |
| Madurez | Más joven que GUT pero muy activo y bien mantenido en 4.x |
| Curva | Media; API fluent distinta a lo clásico |

#### Decisión (pendiente de validar con el estado real del proyecto)

- **Recomendación preliminar:** **GUT**, por simplicidad, madurez y por el comando headless documentado que se alinea con el patrón común del ecosistema Godot; **GdUnit4** como alternativa si el equipo prefiere reportes JUnit nativos y API fluent.
- La decisión final debe validarse en el momento de la implementación según: versión exacta de Godot 4.x del proyecto, disponibilidad del addon, y compatibilidad con los scripts ya existentes.
- Regla de oro: **ambos son aceptables**; el contrato hacia M118 es independiente del framework (exit code + reporte), así que la decisión no bloquea el diseño del CI.

### 2.2 Test runner headless en CI

**Contexto:** Los runners de GitHub Actions no tienen display. La suite debe ejecutarse sin ventana ni GPU.

**Análisis:**

- `godot --headless` inicia el motor sin ventana, con renderer dummy para clases que lo requieran.
- Los autoloads y el SceneTree funcionan normalmente en headless; las escenas 2D/3D pueden instanciarse, aunque funciones de render no producen output visual.
- `--quit-after N` (Godot 4.2+) limita los frames; útil como salvaguarda para detectar loops infinitos en tests.
- El exit code del proceso se propaga al runner de CI: `EXIT_FAILURE` si hay tests fallidos o errores de parseo.
- Consideraciones: extraer la instancia de Godot correcta en CI (M118), caché del addon de testing, y correr la suite con `--path .` desde la raíz del proyecto para que `res://` resuelva bien.

**Decisión:** el runner oficial será el del framework elegido ejecutado con `--headless`, con wrapper propio `res://tests/run_tests.gd` que centralice argumentos (directorio, exit code, formato de reporte) y sea el único punto de entrada documentado para CI y para uso local.

### 2.3 Simulaciones de escenas

**Contexto:** muchos sistemas del juego (NPC, agricultura, construcción) viven en nodos dentro de escenas .tscn, no en clases puras.

**Análisis:**

- Los tests pueden instanciar escenas con `load("res://...tscn").instantiate()` y agregarlas al árbol con `add_child()`.
- Los nodos dentro del árbol reciben `_ready()`, `_process()` y `_physics_process()`, lo que permite simular frames reales.
- Para avanzar tiempo simulado se necesita helper: `await get_tree().process_frame` o avanzar `Engine.time_scale` (con cuidado de restaurarlo).
- Las escenas pesadas (terreno voxel completo, aldeas) no deben instanciarse completas: usar fixtures minimales con solo los nodos necesarios para el sistema probado.

**Decisión:** fixtures minimales por sistema + helper `test_helpers.gd` con funciones `await_frames(n)`, `advance_days(n)`, `load_scene(path)`. Prohibido instanciar escenas completas del juego en tests salvo que el test lo requiera explícitamente.

### 2.4 Test de sistemas sin UI

**Contexto:** M111 exige separación de responsabilidades: la lógica de gameplay no debe vivir en scripts de UI. Esto habilita testear lógica sin Canvas.

**Análisis:**

- Los sistemas bien desacoplados (inventario, crafting, economía, calendario) son clases `RefCounted` o `Resource` instanciables directamente en tests sin ningún nodo de UI.
- Cuando el sistema está atado a nodos (por ejemplo, un `Node3D` que gestiona cosecha), el test instancia el nodo pero NO su Canvas.
- Verificación en CI: la suite corre con `--headless` y no debe existir dependencia de `CanvasLayer`, `Control` ni `Viewport` en los paths de lógica pura.

**Decisión:** todo test de lógica debe poder correr sin UI. Si un test necesita UI, se marca como integration test visual y se documenta como excepción (no forma parte del bloqueo de CI por defecto).

### 2.5 Trade-offs

| Decisión | A favor | En contra | Resolución |
|---|---|---|---|
| GUT vs GdUnit4 | GUT: maduro y simple. GdUnit4: reportes JUnit nativos | Cambiar de framework después es costoso | Decidir en implementación validando contra la versión de Godot real; el wrapper propio aísla la elección |
| Framework como addon en `res://addons/` | Simple, versionable con git, portable | Aumenta tamaño del repo; import genera .meta | Aceptado; documento con un pin de versión |
| Wrapper propio `run_tests.gd` | Centraliza comandos; CI y local usan el mismo entrypoint | Mantenimiento adicional | Aceptado; pequeño y estable |
| Tests por módulo en `res://tests/{modulo}/` | Alineado con CHECKLIST-GLOBAL y el protocolo multiagente | Muchas carpetas | Aceptado; es coherente con la arquitectura del proyecto |
| Umbral global 40% / núcleo 60% | Realista para arrancar; evita falsa sensación de seguridad | No exige 100% | Aceptado; se revisa al alza en cada milestone |
| Correr todo en un job único de CI | Simple de configurar, determinista | Lento si la suite crece | Aceptado para el arranque; paralelización por módulo como mejora documentada |
| Tests de escenas pesadas deshabilitados por defecto | Suite rápida y estable | Menos cobertura visual | Compensado con fixtures minimales |

## 3. Alternativas consideradas

1. **Scripts de verificación manual por consola (sin framework):** descartado; no ofrece aserciones, ni salidas estructuradas, ni cobertura, ni integración CI.
2. **Extensión del pipeline de M118 con checks estáticos solamente:** descartado; los linters no prueban comportamiento.
3. **Framework de Unity (Unity Test Framework / NUnit):** descartado; el proyecto es Godot 4.x + GDScript y la regla global es estricta.
4. **Framework propio de testing desde cero:** descartado; duplica funcionalidad madura de GUT/GdUnit4 y agrega deuda técnica.
5. **Solo testings manuales con checklist:** descartado; el protocolo multiagente y el CI necesitan verificación objetiva y repetible.

## 4. Decisiones

- **D1:** Framework: GUT (preferido) o GdUnit4 (alternativa); decisión final en implementación validando compatibilidad con la versión real de Godot 4.x (ver Notas del Agente en 04-Codigo.md).
- **D2:** El addon se versiona dentro del repo en `res://addons/` con versión pinnada.
- **D3:** Punto de entrada único: `res://tests/run_tests.gd` (wrapper) usado por local y CI.
- **D4:** Estructura de tests por módulo del juego: `res://tests/{modulo}/test_*.gd`.
- **D5:** Umbrales de cobertura: global ≥ 40%, núcleo ≥ 60%; reporte como artefacto de CI.
- **D6:** Suite completa ≤ 10 minutos; unit tests ≤ 2 minutos.
- **D7:** Los tests corren headless y sin UI; excepciones documentadas y fuera del bloqueo de CI por defecto.
- **D8:** Fixtures centralizados en `res://tests/fixtures/` con helpers en `res://tests/helpers/`.
- **D9:** Determinismo total: seeds fijos, sin reloj real, sin locale, sin estado global compartido.
- **D10:** Preparar el terreno para regresión de flujos estables (sección 16 del AGENTS.md) con una carpeta `res://tests/regression/`.